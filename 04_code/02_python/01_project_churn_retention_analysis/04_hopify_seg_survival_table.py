# ============================================
# 📊 Hopify Churn: Segment-Level Survival Table
# ============================================

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
# 📥 Load Retention Summary from CSV
# ================================

file_path = os.path.join(
    BASE_PATH,
    "01_project_artifacts",
    "02_sql_output",
    "01_project_churn_retention_analysis",
    "06_hopify_seg_level_retention_summ.csv"
)

retention_df = pd.read_csv(file_path)

# ================================
# 🧽 Clean & Format Table
# ================================

# Rename columns to match expected keys
retention_df = retention_df.rename(columns={
    'Segment': 'customer_segment',
    'Month 1 %': 'Month 1 Retention %',
    'Month 3 %': 'Month 3 Retention %',
    'Month 6 %': 'Month 6 Retention %',
    'Month 12 %': 'Month 12 Retention %'
})

# Round retention percentages
retention_df = retention_df.round(2)

# Reorder columns (drop cohort since it's not available)
desired_order = [
    "customer_segment",
    "Month 1 Retention %", "Month 3 Retention %",
    "Month 6 Retention %", "Month 12 Retention %"
]
retention_df = retention_df[desired_order]

# ================================
# 💾 Save Clean Table to CSV
# ================================

output_path = os.path.join(
    BASE_PATH,
    "05_visuals",
    "01_project_churn_retention_analysis",
    "04a_seg_level_survival_table.csv"
)
retention_df.to_csv(output_path, index=False)

# ================================
# ✅ Display Output
# ================================

print("\n📊 Segment-Level Survival Table")
print(retention_df.head())