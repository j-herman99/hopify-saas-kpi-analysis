import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

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
# 📥 Load Monthly Churn Data
# ================================

file_path = os.path.join(
    BASE_PATH,
    "01_project_artifacts",
    "02_sql_output",
    "01_project_churn_retention_analysis",
    "03_monthly_churn_rate_seg_target.csv"
)

churn_df = pd.read_csv(file_path)
churn_df["Month"] = pd.to_datetime(churn_df["Month"], errors="coerce")
churn_df = churn_df.sort_values("Month")

# ================================
# 📈 Plot: Monthly Churn by Segment
# ================================

sns.set_style("darkgrid")
plt.style.use("dark_background")

plt.figure(figsize=(12, 6))
sns.lineplot(
    data=churn_df,
    x="Month",
    y="Churn Rate %",
    hue="Segment",
    marker="o"
)

plt.title("Monthly Customer Churn Rate by Segment", fontsize=16, weight='bold')
plt.xlabel("Month")
plt.ylabel("Churn Rate (%)")
plt.xticks(rotation=45)
plt.legend(title="Segment")
plt.tight_layout()
plt.grid(visible=True, linestyle='--', alpha=0.4)

# ================================
# 💾 Optional: Save Figure
# ================================

# output_path = os.path.join(
#     BASE_PATH,
#     "05_visuals",
#     "01_project_churn_retention_analysis",
#     "02_churn_rate_over_time_seg.png"
# )
# plt.savefig(output_path, bbox_inches='tight')

# ================================
# ✅ Show Plot
# ================================

plt.show()