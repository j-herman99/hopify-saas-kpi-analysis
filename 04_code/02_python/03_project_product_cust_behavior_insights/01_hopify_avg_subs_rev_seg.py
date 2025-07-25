## ==============================================================================
## 📊 Hopify SaaS – Avg Subscription Revenue & Subscriber Count by Segment
## ==============================================================================

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

## ================================
## 📥 Load Data
## ================================

file_path = os.path.join(
    BASE_PATH,
    "01_project_artifacts",
    "02_sql_output",
    "03_project_product_cust_behavior_insights",
    "09_hopify_avg_subs_rev_seg.csv"
)

df = pd.read_csv(file_path)

## ================================
## 🧼 Clean Columns
## ================================

df.columns = df.columns.str.lower().str.strip().str.replace(" ", "_")

## ================================
## 🎨 Define Color Palette
## ================================

palette = {
    "Enterprise": "#1f77b4",
    "Mid-Market": "#ff7f0e",
    "SMB": "#9f13ef"
}

## ================================
## 📊 Plotting
## ================================

sns.set_theme(style="whitegrid")
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: Average Subscription Price
sns.barplot(
    data=df,
    x="customer_segment",
    y="avg_subscription_price",
    palette=palette,
    ax=axes[0]
)
axes[0].set_title("Average Subscription Price by Segment", fontsize=14, fontweight='bold')
axes[0].set_ylabel("Price ($)", fontsize=12, fontweight='bold')
axes[0].set_xlabel("Customer Segment", fontsize=12, fontweight='bold')
axes[0].tick_params(axis='x', labelrotation=0)

# Annotate bars
for bar in axes[0].patches:
    height = bar.get_height()
    axes[0].annotate(
        f"${height:,.2f}",
        (bar.get_x() + bar.get_width() / 2., height),
        ha='center', va='bottom',
        fontsize=10, fontweight='bold'
    )

# Plot 2: Number of Customers with Subscriptions
sns.barplot(
    data=df,
    x="customer_segment",
    y="customers_with_subscriptions",
    palette=palette,
    ax=axes[1]
)
axes[1].set_title("Customers with Subscriptions by Segment", fontsize=14, fontweight='bold')
axes[1].set_ylabel("Number of Customers", fontsize=12, fontweight='bold')
axes[1].set_xlabel("Customer Segment", fontsize=12, fontweight='bold')
axes[1].tick_params(axis='x', labelrotation=0)

# Annotate bars
for bar in axes[1].patches:
    height = bar.get_height()
    axes[1].annotate(
        f"{int(height):,}",
        (bar.get_x() + bar.get_width() / 2., height),
        ha='center', va='bottom',
        fontsize=10, fontweight='bold'
    )

## ================================
## 💾 Save & Show
## ================================

plt.tight_layout()

output_path = os.path.join(
    BASE_PATH,
    "05_visuals",
    "03_project_product_cust_behavior_insights",
    "hopify_avg_subs_rev_seg.png"
)
plt.savefig(output_path, dpi=300)
plt.show()

print(f"✅ Plot saved to: {output_path}")