import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as mtick

# Load data
df = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/03_Project_Product_Cust_Behavior_Insights/06-hopify-seg-behav-summ-churn-aov-sub-supp.csv')


# Standardize column names
df.columns = df.columns.str.lower().str.replace(" ", "_")

# Set style
sns.set_theme(style="whitegrid")

# Create subplots
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()

# Define color palette
palette = {"Enterprise": "#1f77b4", "Mid-Market": "#ff7f0e", "SMB": "#9f13ef"}

# Common formatting
title_style = dict(fontsize=14, fontweight="bold", color="#1f2a44", pad=12)

# Plot 1: Churn Rate
sns.barplot(
    data=df, x="customer_segment", y="churn_rate_%", hue="customer_segment",
    palette=palette, ax=axes[0], legend=False
)
axes[0].set_title("Churn Rate (%)", **title_style)
axes[0].set_ylabel("Churn Rate (%)", fontweight="bold")
axes[0].set_xlabel("Customer Segment", fontweight="bold")

# Plot 2: Average Subscription Price
sns.barplot(
    data=df, x="customer_segment", y="avg_subscription_price", hue="customer_segment",
    palette=palette, ax=axes[1], legend=False
)
axes[1].set_title("Average Subscription Price", **title_style)
axes[1].set_ylabel("Price ($)", fontweight="bold")
axes[1].set_xlabel("Customer Segment", fontweight="bold")
axes[1].yaxis.set_major_formatter(mtick.StrMethodFormatter("${x:,.0f}"))

# Plot 3: Average Order Value (AOV)
sns.barplot(
    data=df, x="customer_segment", y="avg_order_value_(aov)", hue="customer_segment",
    palette=palette, ax=axes[2], legend=False
)
axes[2].set_title("Average Order Value (AOV)", **title_style)
axes[2].set_ylabel("AOV ($)", fontweight="bold")
axes[2].set_xlabel("Customer Segment", fontweight="bold")
axes[2].yaxis.set_major_formatter(mtick.StrMethodFormatter("${x:,.0f}"))

# Plot 4: Average Resolution Time
sns.barplot(
    data=df, x="customer_segment", y="avg_resolution_days", hue="customer_segment",
    palette=palette, ax=axes[3], legend=False
)
axes[3].set_title("Average Resolution Time", **title_style)
axes[3].set_ylabel("Days", fontweight="bold")
axes[3].set_xlabel("Customer Segment", fontweight="bold")

# Overall title and layout
plt.suptitle("Customer Segment Behavior Summary", fontsize=18, fontweight="bold")
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.show()