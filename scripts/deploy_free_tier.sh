#!/bin/bash

# --- Configuration for FREE TIER ---
export GCP_PROJECT_ID="your-gcp-project-id"
export GCP_REGION="us-central1" # Must be a US region for the free e2-micro
export GCP_ZONE="us-central1-a"
export NODE_NAME="hpc-free-node"

echo "--- Starting FREE TIER HPC Node Deployment ---"

# Set GCP Project
gcloud config set project $GCP_PROJECT_ID

# --- Step 1: Build and Push Docker Image (if not already done) ---
echo "Building and pushing workload Docker image..."
docker build -t gcr.io/$GCP_PROJECT_ID/hpc-workload:latest ./hpc_workload
# Authenticate Docker with gcloud
gcloud auth configure-docker
docker push gcr.io/$GCP_PROJECT_ID/hpc-workload:latest
echo "Image pushed successfully."

# --- Step 2: Create the Single Free Node ---
echo "Creating the free node: $NODE_NAME..."
gcloud compute instances create $NODE_NAME \
    --zone=$GCP_ZONE \
    --machine-type=e2-micro \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --metadata-from-file startup-script=./scripts/startup_single_node.sh

# --- Step 3: Create Firewall Rule ---
echo "Creating firewall rule to allow web traffic..."
# Use a clear name for the free tier rule
gcloud compute firewall-rules create allow-streamlit-dashboard-8501 \
    --allow tcp:8501 \
    --description="Allow incoming traffic on port 8501 for the Streamlit dashboard"

# Add a network tag to the instance so the rule applies to it
gcloud compute instances add-tags $NODE_NAME --tags=streamlit-server --zone=$GCP_ZONE

echo "--- Deployment Complete ---"
NODE_EXTERNAL_IP=$(gcloud compute instances describe $NODE_NAME --zone=$GCP_ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "✅ Success! Your single-node environment is running."
echo "Access your live monitoring dashboard at: http://$NODE_EXTERNAL_IP:8501"