import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as mtick

# Load and prep data
df = pd.read_csv('/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/03_Project_Product_Cust_Behavior_Insights/15-hopify-3mo-rolling-avg-active-cust-over-time.csv')
df.columns = df.columns.str.lower()
df['month'] = pd.to_datetime(df['month'])
df = df.sort_values('month')
df['fiscal_quarter'] = df['month'].dt.to_period('Q').astype(str)
df['fiscal_quarter'] = pd.Categorical(df['fiscal_quarter'], categories=sorted(df['fiscal_quarter'].unique()), ordered=True)

# Plot
sns.set_theme(style="whitegrid")
plt.figure(figsize=(14, 6))

# Line plots
line1 = sns.lineplot(data=df, x='fiscal_quarter', y='active_customers', label='Monthly Active Customers', marker='o', linewidth=2, color='#4c1d95')
line2 = sns.lineplot(data=df, x='fiscal_quarter', y='rolling_avg_3mo', label='3-Month Rolling Average', marker='o', linewidth=2, color='#fb923c')

# Dynamic label offset for legibility
for i, row in df.iterrows():
    plt.text(i, row['active_customers'] + 250, f"{row['active_customers']:,.0f}", 
             ha='center', fontsize=9, color='#4c1d95')
    plt.text(i, row['rolling_avg_3mo'] - 250, f"{row['rolling_avg_3mo']:,.0f}", 
             ha='center', fontsize=9, color='#fb923c')

# Formatting
plt.title("Monthly Active Customers vs 3-Month Rolling Average", fontsize=16, fontweight='bold')
plt.xlabel("Fiscal Quarter", fontsize=12, fontweight='bold')
plt.ylabel("Active Customers", fontsize=12, fontweight='bold')
plt.xticks(rotation=45)
plt.gca().yaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"{int(x):,}"))
plt.legend(title="Metric", title_fontsize=11, fontsize=10)
plt.tight_layout()
plt.show()
