## ==================================================
## Hopify (SaaS) - Customer Segment Behavior Summary
## ==================================================

import os
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
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
    "06_hopify_seg_behav_summ_churn_aov_sub_supp.csv"
)

df = pd.read_csv(file_path)

# ================================
# 🧼 Format Columns
# ================================

# Standardize column names
df.columns = df.columns.str.lower().str.replace(" ", "_").str.replace("%", "percent")

# Normalize segment names to match palette
df['customer_segment'] = df['customer_segment'].str.strip().str.title()
df['customer_segment'] = df['customer_segment'].replace({"Smb": "SMB"})

# ================================
# 🎨 Plot Setup
# ================================

sns.set_theme(style="whitegrid")
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

palette = {
    "Enterprise": "#1f77b4",
    "Mid-Market": "#ff7f0e",
    "SMB": "#9f13ef"
}

title_style = dict(fontsize=14, fontweight="bold", color="#1f2a44", pad=12)

# ================================
# 📊 Plot 1: Churn Rate
# ================================
sns.barplot(
    data=df, x="customer_segment", y="churn_rate_percent",
    hue="customer_segment", palette=palette, ax=axes[0], legend=False
)
axes[0].set_title("Churn Rate (%)", **title_style)
axes[0].set_ylabel("Churn Rate (%)", fontweight="bold")
axes[0].set_xlabel("Customer Segment", fontweight="bold")

# ================================
# 📊 Plot 2: Average Subscription Price
# ================================
sns.barplot(
    data=df, x="customer_segment", y="avg_subscription_price",
    hue="customer_segment", palette=palette, ax=axes[1], legend=False
)
axes[1].set_title("Average Subscription Price", **title_style)
axes[1].set_ylabel("Price ($)", fontweight="bold")
axes[1].set_xlabel("Customer Segment", fontweight="bold")
axes[1].yaxis.set_major_formatter(mtick.StrMethodFormatter("${x:,.0f}"))

# ================================
# 📊 Plot 3: Average Order Value (AOV)
# ================================
sns.barplot(
    data=df, x="customer_segment", y="avg_order_value_(aov)",
    hue="customer_segment", palette=palette, ax=axes[2], legend=False
)
axes[2].set_title("Average Order Value (AOV)", **title_style)
axes[2].set_ylabel("AOV ($)", fontweight="bold")
axes[2].set_xlabel("Customer Segment", fontweight="bold")
axes[2].yaxis.set_major_formatter(mtick.StrMethodFormatter("${x:,.0f}"))

# ================================
# 📊 Plot 4: Avg Resolution Time
# ================================
sns.barplot(
    data=df, x="customer_segment", y="avg_resolution_days",
    hue="customer_segment", palette=palette, ax=axes[3], legend=False
)
axes[3].set_title("Avg Support Resolution Time", **title_style)
axes[3].set_ylabel("Days", fontweight="bold")
axes[3].set_xlabel("Customer Segment", fontweight="bold")

# ================================
# 🧾 Final Touches
# ================================
plt.suptitle("Customer Segment Behavior Summary", fontsize=18, fontweight="bold")
plt.tight_layout(rect=[0, 0, 1, 0.95])

# ================================
# 💾 Save & Show
# ================================
output_path = os.path.join(
    BASE_PATH, "05_visuals", "03_project_product_cust_behavior_insights",
    "hopify_seg_behavior_summary.png"
)
plt.savefig(output_path, dpi=300)
plt.show()