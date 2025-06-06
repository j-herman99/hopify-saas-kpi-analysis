import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

# Load data
df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/01_Project_Churn_Retention_Analysis/08-hopify-supp-tckt-vol-v-churn-seg.csv')

# Format categories
df['Support Ticket Group'] = pd.Categorical(
    df['Support Ticket Group'],
    categories=[
        "No Support Tickets",
        "Low-Mid Support Volume (1-4 Tickets)",
        "High Support Volume (5+ Tickets)",
        "All Customers"
    ],
    ordered=True
)
df['Segment'] = pd.Categorical(df['Segment'], categories=["Enterprise", "Mid-Market", "SMB"], ordered=True)

# Create the faceted horizontal bar chart
g = sns.catplot(
    data=df,
    kind="bar",
    col="Segment",
    y="Support Ticket Group",
    x="Churn Rate %",
    hue=None,
    legend=False,
    height=4,
    aspect=1.2,
    palette="muted",
    sharex=False
)

# Add custom segment headers
for ax, segment in zip(g.axes.flatten(), df['Segment'].cat.categories):
    ax.set_title("")
    ax.text(
        0.5, 1.05,
        f"{segment}",
        fontsize=12,
        fontweight='bold',
        ha='center',
        va='center',
        transform=ax.transAxes,
        bbox=dict(facecolor='lightgray', edgecolor='gray', boxstyle='round,pad=0.3')
    )

# Add internal bar labels (churn % and customer share %)
for ax, segment in zip(g.axes.flatten(), df['Segment'].cat.categories):
    seg_data = df[df['Segment'] == segment].set_index("Support Ticket Group")
    bars = ax.patches
    for i, (group, row) in enumerate(seg_data.iterrows()):
        if i >= len(bars):
            continue
        bar = bars[i]
        label = f"{row['Churn Rate %']:.1f}%\n({int(row['Customer % of Segment'])}%)"
        ax.text(
            bar.get_width() * 0.98,
            bar.get_y() + bar.get_height() / 2,
            label,
            va='center',
            ha='right',
            fontsize=8,
            color='white',
            fontweight='bold'
        )

# Format axes
for ax in g.axes.flatten():
    ax.xaxis.set_major_formatter(mtick.PercentFormatter())
    ax.set_xlabel("Churn Rate %", fontweight='bold')
    ax.set_ylabel("Support Ticket Group", fontweight='bold')

# Global title
g.fig.suptitle("Churn Rate vs Support Ticket Volume by Segment", fontsize=16, fontweight="bold")
g.fig.subplots_adjust(top=0.88)

plt.show()