import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


# Load sql query results

df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/01_Project_Churn_Retention_Analysis/07-hopify-retention-curve-signup-cohort.csv')

# Parse cohort month as string (for better legend control)
df['Signup Cohort Month'] = df['Signup Cohort Month'].astype(str)

# Filter to recent 8 cohorts
recent_cohorts = df['Signup Cohort Month'].drop_duplicates().sort_values(ascending=False).head(8)
df_filtered = df[df['Signup Cohort Month'].isin(recent_cohorts)]

# Identify most recent cohort
most_recent = recent_cohorts.iloc[0]
df_recent = df_filtered[df_filtered['Signup Cohort Month'] == most_recent]
df_others = df_filtered[df_filtered['Signup Cohort Month'] != most_recent]

# Set up the plot
plt.figure(figsize=(12, 6))
sns.set_style("whitegrid")

# Plot all other cohorts faintly
sns.lineplot(
    data=df_others,
    x="Months Since Signup",
    y="Retention %",
    hue="Signup Cohort Month",
    palette="tab10",
    linewidth=1.2,
    alpha=0.5,
    legend=False
)

# Highlight most recent cohort
sns.lineplot(
    data=df_recent,
    x="Months Since Signup",
    y="Retention %",
    color="orange",
    linewidth=2.5,
    marker="o",
    label=f"{most_recent} (Most Recent)"
)

# Add 80% benchmark line
plt.axhline(80, color='red', linestyle='--', linewidth=1, label="80% Benchmark")

# Final chart labels
plt.title("Retention Decay Curve by Cohort (Recent)", fontsize=16)
plt.xlabel("Months Since Signup")
plt.ylabel("Retention (%)")
plt.xticks(range(df_filtered["Months Since Signup"].max() + 1))
plt.ylim(60, 105)
plt.legend(title="Cohort", loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=3)
plt.tight_layout()

plt.show()