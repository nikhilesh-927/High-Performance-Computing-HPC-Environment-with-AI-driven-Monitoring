# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Copy the workload script into the container
COPY hpc_workload.py .

# The command to run when the container starts.
# It's set to a default range, but we will override this in the deployment script.
CMD ["python", "hpc_workload.py", "1", "100000"]