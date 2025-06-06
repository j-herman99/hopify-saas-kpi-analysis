import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/03_Project_Product_Cust_Behavior_Insights/11-hopify-supp-tckt-vol-v-avg-resolv-seg.csv')

# Standardize column names
df.columns = df.columns.str.strip().str.lower()
df.rename(columns={
    'customer segment': 'segment',
    'total support tickets': 'total_support_tickets',
    'avg resolution days': 'avg_resolution_days'
}, inplace=True)

# Define order and color palette
segments = ["Enterprise", "Mid-Market", "SMB"]
palette = {
    "Enterprise": "#ff7f0e",     # Orange
    "Mid-Market": "#1f77b4",     # Blue
    "SMB": "#9467bd"             # Purple
}
df['segment'] = pd.Categorical(df['segment'], categories=segments, ordered=True)

# Set style
sns.set_style("whitegrid")
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Plot 1: Total Support Tickets
sns.barplot(
    data=df,
    x='segment',
    y='total_support_tickets',
    order=segments,
    palette=palette,
    ax=axes[0]
)
axes[0].set_title("Total Support Tickets", fontsize=14, fontweight='bold')
axes[0].set_xlabel("Customer Segment", fontsize=12, fontweight='bold')
axes[0].set_ylabel("Total Tickets", fontsize=12, fontweight='bold')

# Plot 2: Avg Resolution Days
sns.barplot(
    data=df,
    x='segment',
    y='avg_resolution_days',
    order=segments,
    palette=palette,
    ax=axes[1]
)
axes[1].set_title("Avg Resolution Time (Days)", fontsize=14, fontweight='bold')
axes[1].set_xlabel("Customer Segment", fontsize=12, fontweight='bold')
axes[1].set_ylabel("Avg Days", fontsize=12, fontweight='bold')

# Final layout
plt.suptitle("Support Ticket Volume and Resolution Time by Segment", fontsize=16, fontweight="bold")
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.show()
