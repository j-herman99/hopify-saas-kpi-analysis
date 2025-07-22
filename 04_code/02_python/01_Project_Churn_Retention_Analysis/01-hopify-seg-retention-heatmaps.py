import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


#Load the data

df = pd.read_csv("/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_outputs/01_churn_analysis/01_hopify_retention_cohort_seg_churn.csv")

heatmap_data = df.pivot_table(
    index = 'Segment',
    columns = 'Churn Month',
    values =  'Retention %',
    aggfunc = 'mean'
)

# Set plot size
plt.figure(figsize=(16, 8))

# Create the heatmap
ax = sns.heatmap(heatmap_data, annot=True, annot_kws={"size": 8}, fmt=".1f", cmap="YlGnBu", cbar_kws={'label': 'Retention %'})
ax.set_xticks(ax.get_xticks()[::2])

# Customize titles and axes
plt.title("Segment Survival Heatmap by Churn Month")
plt.xlabel("Churn Month")
plt.ylabel("Customer Segment")
plt.xticks(rotation=45, ha='right')
plt.tight_layout()

# Show the plot
plt.show()