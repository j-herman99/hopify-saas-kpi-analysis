import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load data
df = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/02_Project_Revenue_Profit_Analysis/06-hopify-cac-payback-seg.csv')
df.columns = df.columns.str.lower()

# Aggregate average CAC payback period by segment
agg_df = df.groupby("segment", as_index=False)["cac_payback_months"].mean()
agg_df["cac_payback_days"] = agg_df["cac_payback_months"] * 30.44

# Define color palette
palette = {
    "Enterprise": "#1f77b4",
    "Mid-Market": "#ff7f0e",
    "SMB": "#2ca02c"
}

# Plotting
plt.figure(figsize=(8, 5))
sns.set_style("white")

barplot = sns.barplot(
    data=agg_df,
    x="segment",
    y="cac_payback_days",
    palette=palette
)

# Add labels on top of bars
for i, row in agg_df.iterrows():
    barplot.text(
        i,
        row["cac_payback_days"] + 0.4,
        f"{row['cac_payback_days']:.1f} days",
        ha="center",
        va="bottom",
        fontweight="bold"
    )

# Titles and labels
plt.title("CAC Payback Period by Segment", fontsize=16, fontweight="bold")
plt.ylabel("Payback Period (Days)", fontsize=12, fontweight="bold")
plt.xlabel("Customer Segment", fontsize=12, fontweight="bold")
plt.ylim(0, agg_df["cac_payback_days"].max() + 5)
plt.grid(False)
plt.tight_layout()
plt.show()
