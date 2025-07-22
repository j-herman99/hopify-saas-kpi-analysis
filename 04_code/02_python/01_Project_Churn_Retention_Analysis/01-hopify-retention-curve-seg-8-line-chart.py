import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


# Load and prep data
df = pd.read_csv("/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/01_Project_Churn_Retention_Analysis/07-hopify-retention-curve-signup-cohort.csv")

df['Signup Cohort Month'] = pd.to_datetime(df['Signup Cohort Month'], format="%Y-%m")
df = df.sort_values(['Customer Segment', 'Signup Cohort Month', 'Months Since Signup'])

# Get 8 most recent cohorts per segment
recent_cohorts = (
    df[['Customer Segment', 'Signup Cohort Month']]
    .drop_duplicates()
    .groupby('Customer Segment', group_keys=False)
    .apply(lambda x: x.nlargest(8, 'Signup Cohort Month'))
    .reset_index(drop=True)
)

# Filter original data to only include those cohorts
filtered_df = df.merge(recent_cohorts, on=['Customer Segment', 'Signup Cohort Month'])

# Create readable label for legend
filtered_df['Cohort Label'] = filtered_df['Signup Cohort Month'].dt.strftime('%Y-%m')

# Set visual style
sns.set_theme(style="whitegrid")

# Faceted line plot
g = sns.FacetGrid(
    filtered_df,
    col='Customer Segment',
    col_wrap=1,
    height=4,
    aspect=2,
    sharey=False
)

g.map_dataframe(
    sns.lineplot,
    x='Months Since Signup',
    y='Remaining Active Customers',
    hue='Cohort Label',
    style='Cohort Label',
    marker='o',
    linewidth=1.5,
    markersize=4
)

# External legend formatting
g.add_legend(title='Signup Cohort')
for ax in g.axes.flatten():
    ax.legend(
        loc='center left',
        bbox_to_anchor=(1.02, 0.5),
        frameon=False,
        fontsize=9,
        title_fontsize=10
    )

# Titles and formatting
g.set_titles("{col_name} Segment")
g.set_axis_labels("Months Since Signup", "Retained Customers", fontweight='bold')
g.fig.suptitle("Retained Customers Over Time by Segment (Most Recent 8 Cohorts)", fontsize=16, weight='bold')

# Style facet headers
for ax in g.axes.flatten():
    title = ax.get_title()
    ax.set_title(title, fontsize=12, weight='bold', backgroundcolor='#f0f0f0', pad=10)

# Adjust spacing
plt.tight_layout()
plt.subplots_adjust(top=0.92, right=0.85)
plt.show()

# Show or export
plt.show()