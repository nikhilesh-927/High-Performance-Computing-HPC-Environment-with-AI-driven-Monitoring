#!/bin/bash
set -e # Exit on any error

# 1. SYSTEM SETUP
echo "Updating and installing dependencies..."
sudo apt-get update
sudo apt-get install -y git python3-pip docker.io

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# 2. CODE SETUP
echo "Cloning project repository..."
# !!! REPLACE WITH YOUR GITHUB REPO URL !!!
git clone https://github.com/nikhilesh-927/High-Performance-Computing-HPC-Environment-with-AI-driven-Monitoring /home/Desktop/hpc-monitoring-project
cd /home/Desktop/hpc-monitoring-project

# Install Python libraries
echo "Installing Python requirements..."
pip3 install -r requirements.txt

# 3. RUN THE COMPONENTS (in the background)
echo "Starting all project components..."

# A. Start the Monitoring Server (to receive metrics)
# Note: For this free version, we won't train the model on the VM.
# The server will just collect data.
nohup python3 monitoring/server.py > server.log 2>&1 &
echo "Monitoring server started."

# B. Start the Metrics Collector
# It will send data to itself (localhost)
export CONTROLLER_IP="127.0.0.1"
nohup python3 monitoring/collector.py > collector.log 2>&1 &
echo "Metrics collector started."

# C. Start the HPC Workload in a Docker Container
# Use a smaller workload for the e2-micro instance
sudo docker run --rm gcr.io/your-gcp-project-id/hpc-workload:latest python hpc_workload.py 1 50000 &
echo "HPC workload started."

# D. Start the Streamlit Dashboard
# This is the UI you will access from your browser.
nohup streamlit run monitoring/dashboard.py --server.port 8501 --server.headless true > dashboard.log 2>&1 &
echo "Streamlit dashboard started."

echo "All services are running."