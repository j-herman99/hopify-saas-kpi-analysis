import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

# Load data
df = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/02_Project_Revenue_Profit_Analysis/09-hopify-nrr-grr-seg-over-time.csv')
# Parse dates and sort
df['Month'] = pd.to_datetime(df['Month'])
df = df.sort_values(['Customer Segment', 'Month'])

# Create Quarter column
df['Quarter'] = df['Month'].dt.to_period('Q').astype(str)

# Aggregate to one row per Quarter per Segment
df = df.groupby(['Customer Segment', 'Quarter'], as_index=False).agg({
    'NRR %': 'mean',
    'GRR %': 'mean'
})

# Load benchmarks
df_bench = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/benchmarks/hopify-benchmarks-seg-table.csv')
nrr_bench = df_bench[df_bench["metric_name"] == "NRR Target (%)"].set_index("segment")["target_value"].to_dict()
grr_bench = df_bench[df_bench["metric_name"] == "GRR Target (%)"].set_index("segment")["target_value"].to_dict()

# Plot setup
segments = ["Enterprise", "Mid-Market", "SMB"]
colors = {
    "NRR": "#1f77b4",
    "GRR": "#ff7f0e",
    "NRR Target": "#a6cee3",
    "GRR Target": "#fdbf6f"
}

fig, axs = plt.subplots(nrows=3, ncols=1, figsize=(14, 8), sharex=True, sharey=True)

for ax, segment in zip(axs, segments):
    seg_df = df[df["Customer Segment"] == segment]

    # Plot NRR & GRR lines by Quarter
    ax.plot(seg_df["Quarter"], seg_df["NRR %"], marker='o', color=colors["NRR"], label="NRR %", linewidth=2, zorder=2)
    ax.plot(seg_df["Quarter"], seg_df["GRR %"], marker='o', color=colors["GRR"], label="GRR %", linewidth=2, zorder=2)

    # Benchmark lines
    if segment in nrr_bench:
        ax.axhline(y=nrr_bench[segment], linestyle=(0, (5, 5)), color=colors["NRR Target"], linewidth=2, zorder=1)
    if segment in grr_bench:
        ax.axhline(y=grr_bench[segment], linestyle=(0, (5, 5)), color=colors["GRR Target"], linewidth=2, zorder=1)

    # Remove top border
    ax.spines['top'].set_visible(False)

    # Segment label
    ax.text(0.5, 1.05, segment,
            transform=ax.transAxes,
            ha='center', va='center',
            fontsize=12, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgrey', edgecolor='none'))

    ax.set_ylabel("Revenue Retention (%)", fontweight='bold')
    ax.set_ylim(35, 165)
    ax.set_title("")

# Label bottom axis only once
axs[-1].set_xlabel("Quarter", fontweight='bold')

# Shared legend on side
handles, labels = axs[0].get_legend_handles_labels()
fig.legend(handles, labels, loc='center right', bbox_to_anchor=(1.12, 0.5), title="Legend")

# Final layout
fig.suptitle("NRR & GRR Over Time by Customer Segment", fontsize=16, fontweight='bold')
fig.tight_layout(rect=[0, 0, 0.95, 0.95])
plt.show()
