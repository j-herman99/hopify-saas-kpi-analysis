import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

# Load average LTV per segment
df = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/02_Project_Revenue_Profit_Analysis/14-hopify-ltv-seg-v-target.csv')


# Define color palette based on LTV status

# Define display order
segment_order = ["SMB", "Mid-Market", "Enterprise"]
df["customer_segment"] = pd.Categorical(df["customer_segment"], categories=segment_order, ordered=True)
df = df.sort_values("customer_segment")

# Custom vibrant palette for segments
custom_palette = {
    "SMB": "#4B0082",          # Indigo
    "Mid-Market": "#1E90A2",   # Teal
    "Enterprise": "#DAA520"    # Gold
}

# Set up plot
plt.figure(figsize=(10, 6))
sns.set_style("whitegrid")

# Draw barplot
ax = sns.barplot(
    data=df,
    x="customer_segment",
    y="estimated_ltv",
    palette=custom_palette,
    order=segment_order
)

# Add benchmark (LTV target) lines and labels
xtick_labels = [tick.get_text() for tick in ax.get_xticklabels()]
for i, segment in enumerate(xtick_labels):
    target = df.loc[df["customer_segment"] == segment, "ltv_target"].values[0]
    
    ax.axhline(
        y=target,
        linestyle="--",
        color="#090101",
        linewidth=1
    )
    ax.text(
        x=i,
        y=target + 1000,
        s=f"Target: ${target:,.0f}",
        ha="center",
        va="bottom",
        fontsize=8,
        color="#F4F5E9"
    )


# Format y-axis as currency
ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x:,.0f}"))

# Title and axis labels
plt.title("Average Customer LTV by Segment vs Target", fontsize=16, fontweight='bold')
plt.xlabel(None)
plt.ylabel("Estimated LTV ($)", fontsize=12, fontweight='bold')

# Layout optimization
plt.tight_layout()
plt.show()
