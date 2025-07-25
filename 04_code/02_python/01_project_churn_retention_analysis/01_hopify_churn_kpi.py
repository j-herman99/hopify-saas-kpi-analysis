# ================================
# 📊 Hopify Churn KPI Visual
# ================================

import os
import pandas as pd

# ================================
# 📁 Set Base Path to Project Root
# ================================

try:
    BASE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
except NameError:
    # Jupyter or interactive context
    BASE_PATH = os.path.abspath(os.path.join(os.getcwd(), "..", "..", ".."))

print("📁 Base path set to:", BASE_PATH)

# ================================
# 📥 Load Churn Data
# ================================

# Relative path inside the repo
file_path = os.path.join(
    BASE_PATH,
    "01_project_artifacts",
    "02_sql_output",
    "01_project_churn_retention_analysis",
    "01_hopify_exec_sum_churn.csv"
)

# Load data
churn_df = pd.read_csv(file_path)
print("✅ File loaded successfully!")

# ================================
# 📊 Churn Summary KPI Calculator
# ================================

kpi_table = churn_df.groupby('Segment').agg({
    'Churn Rate %': ['mean', lambda x: x.iloc[-1]],
    'Benchmark %': 'first'
}).reset_index()

kpi_table.columns = [
    'Segment',
    'Avg Actual Churn (%)',
    'Most Recent Churn (%)',
    'Benchmark Churn Rate (%)'
]

kpi_table['Variance to Benchmark'] = (
    kpi_table['Most Recent Churn (%)'] - kpi_table['Benchmark Churn Rate (%)']
)

# ================================
# 🎨 Format KPI Metrics for Display
# ================================

kpi_table['Avg Actual Churn (%)'] = kpi_table['Avg Actual Churn (%)'].apply(lambda x: f"{x:.2%}")
kpi_table['Most Recent Churn (%)'] = kpi_table['Most Recent Churn (%)'].apply(lambda x: f"{x:.2%}")
kpi_table['Benchmark Churn Rate (%)'] = kpi_table['Benchmark Churn Rate (%)'].apply(lambda x: f"{x:.2%}")
kpi_table['Variance to Benchmark'] = kpi_table['Variance to Benchmark'].apply(lambda x: f"{x:+.2f} pts")

# ================================
# ✅ Preview KPI Table
# ================================

print("\n📌 Churn KPI Summary Table:\n")
print(kpi_table)