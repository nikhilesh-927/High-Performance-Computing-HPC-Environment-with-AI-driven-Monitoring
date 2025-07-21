# monitoring/dashboard.py
import streamlit as st
import pandas as pd
import time

st.set_page_config(
    page_title="HPC Cluster Monitoring",
    layout="wide",
    auto_update_interval=5 # Check for updates every 5 seconds
)

METRICS_FILE = 'metrics.csv'

st.title("HPC Environment: AI-driven Monitoring")

def load_data():
    try:
        df = pd.read_csv(METRICS_FILE)
        df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')
        return df
    except FileNotFoundError:
        return None

data = load_data()

if data is None:
    st.warning("No monitoring data found. Is the cluster running and collecting metrics?")
else:
    # Get the latest entry for each host
    latest_data = data.sort_values('timestamp').groupby('hostname').last().reset_index()

    st.subheader("Cluster Node Status")

    cols = st.columns(len(latest_data))

    for i, row in latest_data.iterrows():
        with cols[i]:
            st.metric(label=f"Node: {row['hostname']}", value=f"{row['cpu_percent']:.1f}% CPU", delta=f"{row['memory_percent']:.1f}% RAM")
            if row['is_anomaly'] == 1:
                st.error("Status: ANOMALY DETECTED")
            else:
                st.success("Status: OK")

    st.subheader("CPU Usage Over Time")
    
    # Pivot data for charting
    cpu_chart_data = data.pivot(index='timestamp', columns='hostname', values='cpu_percent')
    st.line_chart(cpu_chart_data)

    st.subheader("Raw Metrics Log")
    st.dataframe(data.sort_values('timestamp', ascending=False))