## ======================================================================
## 🔄 Hopify SaaS – CAC Payback Period by Segment (in Days)
## ======================================================================

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.font_manager import FontProperties

## ================================
## 📁 Set Base Path to Project Root
## ================================

try:
    BASE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
except NameError:
    # Jupyter or interactive context
    BASE_PATH = os.path.abspath(os.path.join(os.getcwd(), "..", "..", ".."))

print("📁 Base path set to:", BASE_PATH)

# ================================
# 📥 Load Data
# ================================

file_path = os.path.join(
    BASE_PATH,
    "01_project_artifacts",
    "02_sql_output",
    "03_project_product_cust_behavior_insights",
    "10_hopify_cac_payback_seg.csv"
)

df = pd.read_csv(file_path)

# ================================
# 🧼 Clean Columns
# ================================

df.columns = df.columns.str.strip().str.lower()

# ================================
# 📊 Calculate CAC Payback Days
# ================================

agg_df = df.groupby("segment", as_index=False)["cac_payback_months"].mean()
agg_df["cac_payback_days"] = agg_df["cac_payback_months"] * 30.44

# ================================
# 🎨 Plotting
# ================================

sns.set_style("white")
palette = {
    "Enterprise": "#1f77b4",
    "Mid-Market": "#ff7f0e",
    "SMB": "#2ca02c"
}

plt.figure(figsize=(8, 5))
ax = sns.barplot(data=agg_df, x="segment", y="cac_payback_days", palette=palette)

# Add labels
for i, row in agg_df.iterrows():
    ax.text(
        i,
        row["cac_payback_days"] + 0.8,
        f"{row['cac_payback_days']:.1f} days",
        ha="center",
        va="bottom",
        fontweight="bold",
        fontsize=10
    )

# ================================
# ✨ Format Chart
# ================================

plt.title("CAC Payback Period by Segment", fontsize=16, fontweight="bold")
plt.ylabel("Payback Period (Days)", fontsize=12, fontweight="bold")
plt.xlabel("Customer Segment", fontsize=12, fontweight="bold")
plt.ylim(0, agg_df["cac_payback_days"].max() + 10)
plt.grid(False)
plt.tight_layout()

# ================================
# 💾 Save & Show
# ================================

output_path = os.path.join(
    BASE_PATH,
    "05_visuals",
    "03_project_product_customer_insights",
    "hopify_cac_payback_seg.png"
)
plt.savefig(output_path, dpi=300)
plt.show()

print(f"✅ Plot saved to: {output_path}")