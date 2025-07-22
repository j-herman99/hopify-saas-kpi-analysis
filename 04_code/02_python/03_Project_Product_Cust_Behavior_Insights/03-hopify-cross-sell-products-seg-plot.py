import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.font_manager import FontProperties

# Load and prep data
df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/03_Project_Product_Cust_Behavior_Insights/05-hopify-top-cross-sell-prod-combo-seg.csv')
df = df[df["Combo Frequency"] > 0]

# Select top 2 combos per segment
top2 = (
    df.sort_values(["Customer Segment", "Combo Frequency"], ascending=[True, False])
      .groupby("Customer Segment")
      .head(2)
)

# Custom color palette
custom_palette = {
    "Enterprise": "#1f77b4",    # blue
    "Mid-Market": "#ff7f0e",    # orange
    "SMB": "#9f13ef"            # purple
}

# Plotting setup
sns.set(style="whitegrid")
plt.figure(figsize=(12, 6))

ax = sns.barplot(
    data=top2,
    y="Category Combo",
    x="Combo Frequency",
    hue="Customer Segment",
    dodge=True,
    palette=custom_palette
)

# Format labels
bold_title = FontProperties(weight='bold')
plt.title("Top 2 Cross-Sell Category Combos by Segment", fontsize=14, fontweight='bold')
plt.xlabel("Combo Frequency", fontweight='bold')
plt.ylabel("Combo Product Categories", fontweight='bold')
plt.legend(title="Customer Segment", title_fontproperties=bold_title, bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()