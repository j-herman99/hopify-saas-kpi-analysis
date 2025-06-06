import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import font_manager


# Load CSV
churn_df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/01_Project_Churn_Retention_Analysis/03-monthly-churn-rate-seg-target.csv')

# Format Month as datetime and create Quarter label
churn_df['Month'] = pd.to_datetime(churn_df['Month'], format='%Y-%m')
churn_df['QuarterLabel'] = churn_df['Month'].dt.to_period('Q').astype(str)  # e.g., '2022Q3'
churn_df = churn_df.sort_values('Month')


# Define segment order and palette
segments = ['Enterprise', 'Mid-Market', 'SMB']
palette = {
    'Enterprise': '#1f77b4',
    'Mid-Market': '#ff7f0e',
    'SMB': '#9f13ef'
}

# Set style
sns.set_theme(style="whitegrid")
plt.figure(figsize=(12, 6))

# Plot with new x-axis label
sns.lineplot(
    data=churn_df,
    x="QuarterLabel",
    y="Churn Rate %",
    hue="Segment",
    hue_order=segments,
    palette=palette,
    marker="o",
    linewidth=2
)

# Add benchmark lines
for segment in segments:
    seg_df = churn_df[churn_df['Segment'] == segment]
    benchmark = seg_df['Benchmark Churn Rate %'].iloc[0]
    plt.axhline(
        y=benchmark,
        linestyle='--',
        color=palette[segment],
        alpha=0.4,
        label=f"{segment} Threshold ({benchmark:.2f}%)"
    )

# Add variance shading
for segment in segments:
    seg_df = churn_df[churn_df['Segment'] == segment]
    for _, row in seg_df.iterrows():
        if row['Churn Rate %'] > row['Benchmark Churn Rate %']:
            plt.fill_between(
                [row['QuarterLabel']],
                row['Benchmark Churn Rate %'],
                row['Churn Rate %'],
                color=palette[segment],
                alpha=0.2
            )

# Annotations on latest points
latest_points = churn_df.sort_values('Month').groupby('Segment').tail(1)
for _, row in latest_points.iterrows():
    plt.text(
        row['QuarterLabel'],
        row['Churn Rate %'] + 0.05,
        f"{row['Churn Rate %']:.2f}%",
        color=palette[row['Segment']],
        weight='bold',
        fontsize=10,
        ha='center'
    )

# Final formatting
bold_font = font_manager.FontProperties(weight='bold')

plt.title("Quarterly Churn Rate vs Threshold by Segment", fontsize=16, weight='bold')
plt.ylabel("Churn Rate (%)", fontweight='bold')
plt.xlabel("Quarter", fontweight='bold')
plt.legend(title="Legend", title_fontproperties=bold_font, bbox_to_anchor=(1.05, 1), loc='upper left')
plt.xticks(rotation=45)
plt.tight_layout()
plt.grid(True, linestyle='--', alpha=0.4)

plt.show()
