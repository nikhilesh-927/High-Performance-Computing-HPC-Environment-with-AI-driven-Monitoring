#!/bin/bash

# --- Configuration ---
export GCP_PROJECT_ID="your-gcp-project-id"
export GCP_ZONE="us-central1-a"
export CONTROLLER_NAME="hpc-controller"
export WORKER_PREFIX="hpc-worker"
export NUM_WORKERS=2

echo "--- Starting HPC Cluster Deployment ---"

# Set GCP Project
gcloud config set project $GCP_PROJECT_ID

# --- Step 1: Build and Push Docker Image ---
echo "Building and pushing workload Docker image..."
docker build -t gcr.io/$GCP_PROJECT_ID/hpc-workload:latest ./hpc_workload
docker push gcr.io/$GCP_PROJECT_ID/hpc-workload:latest
echo "Image pushed successfully."

# --- Step 2: Create Controller Node ---
echo "Creating controller node: $CONTROLLER_NAME..."
gcloud compute instances create $CONTROLLER_NAME \
    --zone=$GCP_ZONE \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --metadata-from-file startup-script=./scripts/startup-controller.sh

# --- Step 3: Get Controller's Internal IP ---
echo "Fetching controller IP..."
CONTROLLER_IP=$(gcloud compute instances describe $CONTROLLER_NAME --zone=$GCP_ZONE --format='get(networkInterfaces[0].networkIP)')
echo "Controller IP is: $CONTROLLER_IP"

# --- Step 4: Create Worker Nodes ---
echo "Creating $NUM_WORKERS worker nodes..."
for i in $(seq 1 $NUM_WORKERS)
do
  WORKER_NAME="$WORKER_PREFIX-$i"
  # Define a unique workload for each worker
  WORKLOAD_START=$(( ($i - 1) * 100000 + 1 ))
  WORKLOAD_END=$(( $i * 100000 ))
  
  # Prepare the startup script by replacing the placeholder IP
  sed "s/\[CONTROLLER_IP_PLACEHOLDER\]/$CONTROLLER_IP/" ./scripts/startup-worker.sh > /tmp/startup-worker-temp.sh
  
  gcloud compute instances create $WORKER_NAME \
    --zone=$GCP_ZONE \
    --machine-type=e2-medium \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --metadata-from-file startup-script=/tmp/startup-worker-temp.sh \
    --metadata "workload-start=$WORKLOAD_START,workload-end=$WORKLOAD_END" &
done

wait # Wait for all background jobs to finish

# --- Step 5: Create Firewall Rule ---
echo "Creating firewall rule to allow traffic to controller..."
gcloud compute firewall-rules create http-allow-8000 \
    --allow tcp:8000 \
    --description="Allow incoming traffic on port 8000 for monitoring server" \
    --target-tags=http-server

# Add the tag to the controller instance
gcloud compute instances add-tags $CONTROLLER_NAME --tags=http-server --zone=$GCP_ZONE

echo "--- Deployment Complete ---"
echo "Controller IP: $CONTROLLER_IP"
echo "Access the monitoring server API at http://$CONTROLLER_IP:8000"