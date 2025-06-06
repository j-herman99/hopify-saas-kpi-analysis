import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

# Load churn data (adjust the path if needed)
churn_over_time_path = '/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/01_Project_Churn_Retention_Analysis/03-monthly-churn-rate-seg-target.csv'  # Replace with full path if not in same dir
churn_df = pd.read_csv(churn_over_time_path)

# Convert Month column to datetime and sort ascending
churn_df['Month'] = pd.to_datetime(churn_df['Month'], errors='coerce')
churn_df = churn_df.sort_values('Month')

# Set dark, clean style
sns.set_style("darkgrid")
plt.style.use("dark_background")

# Plot churn rate over time by segment
plt.figure(figsize=(12, 6))
sns.lineplot(
    data=churn_df,
    x="Month",
    y="Churn Rate %",
    hue="Segment",
    marker="o"
)

# Chart aesthetics
plt.title("Monthly Customer Churn Rate by Segment", fontsize=16, weight='bold')
plt.ylabel("Churn Rate (%)")
plt.xlabel("Month")
plt.xticks(rotation=45)
plt.legend(title="Segment")
plt.tight_layout()
plt.grid(visible=True, linestyle='--', alpha=0.4)

# Show plot
plt.show()
