#!/bin/bash
set -e # Exit on any error

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y git python3-pip

# Clone the project repository (REPLACE WITH YOUR REPO URL)
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git /home/Desktop/hpc-monitoring-project
cd /home/Desktop/hpc-monitoring-project

# Install Python dependencies
pip3 install -r requirements.txt

# Run the Flask monitoring server using Gunicorn
# It will host the model and dashboard
nohup gunicorn --bind 0.0.0.0:8000 monitoring.server:app > server.log 2>&1 &