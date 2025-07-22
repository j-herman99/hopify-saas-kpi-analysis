import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pandas.tseries.offsets import DateOffset 


#Load the dataset

df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/01_Project_Churn_Retention_Analysis/07-hopify-retention-curve-signup-cohort.csv')


df = df.rename(columns={
    'Signup Cohort Month': 'signup_cohort',
    'Months Since Signup': 'months_since_signup',
    'Remaining Active Customers': 'retained_customers',
    'Customer Segment': 'customer_segment'
})

# Parse signup cohort
df['signup_cohort'] = pd.to_datetime(df['signup_cohort'])
df['activity_month'] = df.apply(
    lambda row: row['signup_cohort'] + DateOffset(months=int(row['months_since_signup'])),
    axis=1
)

segment_order = ["Enterprise", "Mid-Market", "SMB"]
df["customer_segment"] = pd.Categorical(df["customer_segment"], categories=segment_order, ordered=True)

# Plot
sns.set(style="whitegrid", rc={"axes.facecolor": "#F9F9F9"})
g = sns.relplot(
    data=df,
    kind="line",
    x="activity_month",
    y="retained_customers",
    hue="signup_cohort",
    row="customer_segment",
    marker="o",
    palette="viridis",
    height=3.5,
    aspect=3,
    facet_kws={"sharey": False}
)

g.set_titles("{row_name} Segment")
g.set_axis_labels("Month", "Retained Customers")
g.fig.subplots_adjust(top=0.9)
g.fig.suptitle("Retained Customers Over Time by Segment (Faceted)", fontsize=14)
g.add_legend(title="Cohort", bbox_to_anchor=(1.05, 0.5), loc='center left')

for ax in g.axes.flat:
    ax.tick_params(axis='x', rotation=45)

# Save
plt.savefig("/users/jade.herman/documents/00_github/hopify-saas-kpi-analysis/visuals/01_Project_Churn_Retention_Analysis/hopify_retained_cust_over_time_seg.png", bbox_inches='tight')
plt.close()
