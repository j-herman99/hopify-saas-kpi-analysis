import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as mtick
import matplotlib.dates as mdates

# Load and prepare data
df = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/02_Project_Revenue_Profit_Analysis/04-hopify-mrr-act-v-mrr-target-seg.csv')
df.columns = df.columns.str.lower()
df['month'] = pd.to_datetime(df['month'])
df['fiscal_quarter'] = df['month'].dt.to_period('Q').astype(str)

# Filter last 12 months
latest_month = df['month'].max()
start_month = latest_month - pd.DateOffset(months=11)
df = df[(df['month'] >= start_month) & (df['month'] <= latest_month)]

# Keep only the most recent month per quarter + segment
df = df.sort_values('month')
df = df.groupby(['segment', 'fiscal_quarter']).tail(1)

# Define order and format
segments = ["Enterprise", "Mid-Market", "SMB"]
df['segment'] = pd.Categorical(df['segment'], categories=segments, ordered=True)

sns.set_theme(style="white")
ymax = df['mrr_actual'].max()

# Plot setup
g = sns.FacetGrid(df, col='segment', col_wrap=1, height=4, aspect=2, sharey=True)
g.map_dataframe(sns.lineplot, x='fiscal_quarter', y='mrr_actual', marker="o", color="#1f77b4", label="MRR")

# Format each subplot
for ax, segment in zip(g.axes.flat, segments):
    seg_df = df[df['segment'] == segment]
    target = seg_df['mrr_target'].iloc[0]
    
    ax.axhline(y=target, linestyle='--', color="#aec7e8", linewidth=2, label="Target")
    ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x/1000:.0f}K"))
    ax.set_ylim(0, ymax * 1.15)
    ax.tick_params(axis='x', rotation=0)

    # Segment title box
    ax.text(0.5, 1.02, f"{segment} Segment",
            transform=ax.transAxes, ha='center', va='bottom',
            fontsize=11, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgrey', edgecolor='none'))

    # Annotate data points clearly
    for _, row in seg_df.iterrows():
        ax.text(
            row['fiscal_quarter'], row['mrr_actual'] + (ymax * 0.03),
            f"${row['mrr_actual']/1000:.0f}K",
            ha='center', va='bottom', fontsize=8,
            fontweight='bold', color='#1f3b73'
        )

# Axis labels and legend
g.set_axis_labels("Fiscal Quarter", "MRR ($)", fontsize=12, fontweight="bold")
g.set_titles("")
g.fig.subplots_adjust(top=0.88)
g.add_legend(title="Metric", fontsize=9, title_fontsize=10)
g._legend.set_bbox_to_anchor((0.85, -0.05))
g._legend.set_frame_on(False)

# Title
g.fig.suptitle("Monthly MRR vs Target by Segment", fontsize=16, fontweight="bold")
plt.tight_layout()
plt.show()