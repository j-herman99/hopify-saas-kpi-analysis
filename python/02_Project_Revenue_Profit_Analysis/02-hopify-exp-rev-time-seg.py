import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import matplotlib.dates as mdates
from matplotlib.ticker import MaxNLocator
import pandas as pd
import seaborn as sns

# Load & prep data

df = pd.read_csv("/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/02_Project_Revenue_Profit_Analysis/11-hopify-monthly-exp-rev-seg.csv")
df['Month'] = pd.to_datetime(df['Month'], errors='coerce')
df = df.sort_values(['Month', 'Customer Segment'])

# Filter to most recent 12 months
latest_month = df['Month'].max()
start_month = latest_month - pd.DateOffset(months=11)
df = df[(df['Month'] >= start_month) & (df['Month'] <= latest_month)]

# Fiscal Year + Quarter
df['Fiscal Year'] = df['Month'].dt.year
df['Quarter'] = df['Month'].dt.to_period('Q').astype(str)

# Faceted line plot per segment
g = sns.FacetGrid(df, col="Customer Segment", col_wrap=1, height=4.2, aspect=2, sharey=True)
g.map_dataframe(sns.lineplot, x="Quarter", y="Expansion Revenue", marker="o", color="#1f77b4")

# Format axes and label all points
for ax, segment in zip(g.axes.flat, df["Customer Segment"].unique()):
    segment_data = df[df['Customer Segment'] == segment].drop_duplicates(subset=["Quarter"])
    y_max = segment_data['Expansion Revenue'].max()
    ax.set_ylim(0, y_max * 1.15)

    ax.yaxis.set_major_locator(MaxNLocator(nbins='auto', steps=[1, 2, 5, 10]))
    ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x/1e6:.1f}M"))

    for _, row in segment_data.iterrows():
        ax.annotate(
            f"${row['Expansion Revenue']/1e6:.1f}M",
            xy=(row['Quarter'], row['Expansion Revenue']),
            xytext=(0, 12),
            textcoords='offset points',
            ha='center',
            va='bottom',
            fontsize=8,
            color='black'
        )

# Axis labels
g.set_axis_labels("Fiscal Quarter", "Expansion Revenue ($M)", fontweight='bold')
g.set_titles("")

# Segment labels
for ax, segment in zip(g.axes.flat, df["Customer Segment"].unique()):
    ax.text(
        0.5, 0.98, f"{segment} Segment",
        transform=ax.transAxes,
        ha='center',
        va='bottom',
        fontsize=10,
        fontweight='bold',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgrey', edgecolor='none')
    )

# Layout and title
g.fig.subplots_adjust(top=0.90, bottom=0.08)
g.fig.suptitle("Expansion Revenue Trends by Segment", fontsize=16, fontweight='bold', y=0.96)

plt.show()
