import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.font_manager import FontProperties

# Load and prepare data
df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/02_Project_Revenue_Profit_Analysis/14-hopify-ltv-seg-v-target.csv')
df.columns = df.columns.str.lower().str.strip()
df.rename(columns={'customer_segment': 'segment'}, inplace=True)
df['segment'] = df['segment'].str.title().str.strip()

# Melt for plotting
df_melted = df.melt(
    id_vars='segment',
    value_vars=['estimated_ltv', 'ltv_target'],
    var_name='metric',
    value_name='ltv_value'
)

# Plot style
sns.set_style("whitegrid")
palette = {
    'estimated_ltv': "#4631e5",
    'ltv_target': '#ff7f0e'
}

# Plot
plt.figure(figsize=(10, 6))
ax = sns.barplot(
    data=df_melted,
    x='segment',
    y='ltv_value',
    hue='metric',
    palette=palette
)

# Add value labels (skip zeros and NaNs)
for bar in ax.patches:
    height = bar.get_height()
    if pd.notna(height) and height > 0:
        ax.annotate(
            f"${height:,.0f}",
            (bar.get_x() + bar.get_width() / 2, height),
            ha='center',
            va='bottom',
            fontsize=9,
            fontweight='bold',
            xytext=(0, 5),
            textcoords='offset points'
        )

# Format
bold_font = FontProperties(weight='bold')

ax.set_title("Estimated LTV vs Target by Segment", fontsize=16, fontweight='bold')
ax.set_xlabel("Customer Segment", fontsize=12, fontweight='bold')
ax.set_ylabel("Lifetime Value ($)", fontsize=12, fontweight='bold')
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f"${x:,.0f}"))
plt.legend(
    title="Metric",
    title_fontproperties=bold_font,
    fontsize=10,
    loc='upper right'
)
plt.tight_layout()
plt.show()




