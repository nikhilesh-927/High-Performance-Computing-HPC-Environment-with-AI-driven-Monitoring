#!/bin/bash
set -e # Exit on any error

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y git python3-pip docker.io

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER # Add current user to docker group

# Clone the project repository (REPLACE WITH YOUR REPO URL)
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git /home/Desktop/hpc-monitoring-project
cd /home/Desktop/hpc-monitoring-project

# Install Python dependencies
pip3 install -r requirements.txt

# Run the metrics collector in the background
export CONTROLLER_IP="[CONTROLLER_IP_PLACEHOLDER]" # This will be replaced by deploy script
nohup python3 monitoring/collector.py > collector.log 2>&1 &

# Run the HPC workload in a Docker container
# The workload range is passed as an argument to this script
WORKLOAD_START=$1
WORKLOAD_END=$2
sudo docker run --rm hpc_workload/hpc-workload:latest python hpc_workload.py $WORKLOAD_START $WORKLOAD_END