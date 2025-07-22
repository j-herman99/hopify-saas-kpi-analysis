import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.ticker as mtick

# Load & prep
df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/02_Project_Revenue_Profit_Analysis/05-hopify-monthly-arpu-act-v-target-seg.csv')

# Prepare data
df['Month'] = pd.to_datetime(df['Month'], errors='coerce')
df['Quarter'] = df['Month'].dt.to_period('Q').astype(str)

# Sort by Segment and Quarter (descending)
df = df.sort_values(['Segment', 'Quarter'], ascending=[True, False])

# Enforce descending quarter order
quarter_order = sorted(df['Quarter'].unique(), reverse=True)
df['Quarter'] = pd.Categorical(df['Quarter'], categories=quarter_order, ordered=True)

# Segment order
segments = ["Enterprise", "Mid-Market", "SMB"]
df['Segment'] = pd.Categorical(df['Segment'], categories=segments, ordered=True)

# Define color palette
colors = {
    "ARPU": "#1f77b4",
    "Target": "#aec7e8"
}

sns.set_style("white")

# Create FacetGrid
g = sns.FacetGrid(df, col='Segment', col_wrap=1, height=3.5, aspect=2, sharey=True)
g.map_dataframe(sns.lineplot, x='Quarter', y='ARPU', marker='o', color=colors['ARPU'], ci=None)

# Customize each subplot
for ax, segment in zip(g.axes.flat, segments):
    seg_df = df[df['Segment'] == segment]
    if not seg_df.empty:
        target = seg_df['ARPU Target'].iloc[0]
        ax.axhline(y=target, linestyle='--', color=colors['Target'], linewidth=1.5, alpha=0.6)

        ax.text(
            0.5, 0.93, f"{segment} Segment",
            transform=ax.transAxes,
            ha='center', va='bottom',
            fontsize=10, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgrey', edgecolor='none')
        )

        # Set fixed y-axis range for consistency and padding
        ax.set_ylim(1100, 2000)

        for _, row in seg_df.drop_duplicates(subset=["Quarter"]).iterrows():
            ax.annotate(
                f"${row['ARPU']:,.0f}",
                xy=(row['Quarter'], row['ARPU']),
                xytext=(0, 8),
                textcoords='offset points',
                ha='center',
                fontsize=8,
                color='black'
            )

        ax.grid(False)

    ax.set_title("")
    ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x:,.0f}"))
    ax.tick_params(axis='x', labelrotation=0)
    ax.invert_xaxis()

# Axis labels
g.set_axis_labels("Fiscal Quarter", "ARPU ($)")
for ax in g.axes.flat:
    ax.set_xlabel("Fiscal Quarter", fontsize=12, fontweight='bold')
    ax.set_ylabel("ARPU ($)", fontsize=12, fontweight='bold')

# Title and layout
g.fig.subplots_adjust(top=0.88, bottom=0.08)
g.fig.suptitle("Monthly ARPU vs Target by Segment", fontsize=16, fontweight='bold')

plt.tight_layout()
plt.show()
