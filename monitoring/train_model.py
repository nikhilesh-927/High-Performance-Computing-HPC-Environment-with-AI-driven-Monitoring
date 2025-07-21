# monitoring/train_model.py
import pandas as pd
from sklearn.ensemble import IsolationForest
import joblib

METRICS_FILE = 'metrics.csv'
MODEL_FILE = 'anomaly_model.joblib'

print(f"Loading data from {METRICS_FILE}...")
try:
    df = pd.read_csv(METRICS_FILE)
except FileNotFoundError:
    print(f"Error: {METRICS_FILE} not found. Generate some normal data first.")
    exit()

# We only want to train on normal operational data
# For this example, we assume the initial data collected is normal
# In a real scenario, you would clean this data first.
features = ['cpu_percent', 'memory_percent', 'disk_percent']
X = df[features]

print("Training Isolation Forest model...")
# contamination='auto' is a good starting point. It means the model
# will estimate the proportion of outliers in the data.
model = IsolationForest(contamination='auto', random_state=42)
model.fit(X)

print(f"Saving model to {MODEL_FILE}...")
joblib.dump(model, MODEL_FILE)

print("Model training complete and saved.")