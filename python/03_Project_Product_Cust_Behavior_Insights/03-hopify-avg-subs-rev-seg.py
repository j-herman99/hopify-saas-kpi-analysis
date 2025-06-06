import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/03_Project_Product_Cust_Behavior_Insights/09-hopify-avg-subs-rev-seg.csv')

# Standardize column names
df.columns = df.columns.str.lower().str.replace(" ", "_")

# Set the theme
sns.set_theme(style="whitegrid")

# Define color palette
palette = {
    "Enterprise": "#1f77b4",
    "Mid-Market": "#ff7f0e",
    "SMB": "#9f13ef"
}

# Plotting side-by-side bar plots
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
axes[0].set_xlabel("Segment", fontsize=12, fontweight='bold')

# Annotate bars
for p in axes[0].patches:
    axes[0].annotate(f"${p.get_height():,.2f}", 
                     (p.get_x() + p.get_width() / 2., p.get_height()), 
                     ha='center', va='bottom', fontsize=10, fontweight='bold')

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
axes[1].set_xlabel("Segment", fontsize=12, fontweight='bold')

# Annotate bars
for p in axes[1].patches:
    axes[1].annotate(f"{int(p.get_height()):,}", 
                     (p.get_x() + p.get_width() / 2., p.get_height()), 
                     ha='center', va='bottom', fontsize=10, fontweight='bold')

plt.tight_layout()
plt.show()