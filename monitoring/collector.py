# monitoring/collector.py
import psutil
import requests
import time
import os
import socket

# The IP of your controller node. We will set this as an environment variable.
CONTROLLER_IP = os.getenv("CONTROLLER_IP", "localhost")
SERVER_URL = f"http://{CONTROLLER_IP}:8000/metrics"

def get_metrics():
    """Collects system metrics."""
    return {
        "hostname": socket.gethostname(),
        "cpu_percent": psutil.cpu_percent(interval=1),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": psutil.disk_usage('/').percent,
        "timestamp": time.time()
    }

if __name__ == "__main__":
    print(f"Starting metric collector. Sending to {SERVER_URL}")
    while True:
        try:
            metrics = get_metrics()
            response = requests.post(SERVER_URL, json=metrics, timeout=5)
            # print(f"Sent metrics: {metrics}, Status: {response.status_code}")
        except requests.exceptions.RequestException as e:
            print(f"Error sending metrics: {e}")
        
        # Collect metrics every 10 seconds
        time.sleep(10)