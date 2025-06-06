import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

# Load the AOV dataset
df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/03_Project_Product_Cust_Behavior_Insights/04-hopify-aov-seg-prod-cat.csv')

# Custom palette: purple for SMB
custom_palette = {
    "Enterprise": "#1f77b4",
    "Mid-Market": "#fc8d62",
    "SMB": "#9f13ef"
}

# Set up the plot
plt.figure(figsize=(12, 6))
sns.set_style("whitegrid")

# Create scatterplot
ax = sns.scatterplot(
    data=df,
    x="Product Category",
    y="Average Order Value (AOV)",
    hue="Segment",
    palette=custom_palette,
    s=100,
    legend="full"
)

# Format y-axis
ax.yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x:,.0f}"))

# Add data labels
for _, row in df.iterrows():
    plt.text(
        x=row["Product Category"],
        y=row["Average Order Value (AOV)"] + 10,
        s=f"${int(row['Average Order Value (AOV)']):,}",
        ha='center',
        va='bottom',
        fontsize=8
    )

# Titles and labels
plt.title("Average Order Value by Product Category and Segment", fontsize=14, fontweight='bold')
plt.xlabel("Product Category", fontsize=12, fontweight='bold')
plt.ylabel("Average Order Value ($)", fontsize=12, fontweight='bold')
plt.xticks(rotation=30, ha='right')

# Legend formatting
legend = plt.legend(title="Segment", bbox_to_anchor=(1.05, 1), loc="upper left")
legend.get_title().set_fontweight('bold')

plt.tight_layout()
plt.show()