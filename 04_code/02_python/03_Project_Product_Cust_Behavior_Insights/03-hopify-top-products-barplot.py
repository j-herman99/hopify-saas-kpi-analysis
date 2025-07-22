import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick

# Load and clean dataset
df = pd.read_csv("/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_output/03_Project_Product_Cust_Behavior_Insights/04_hopify_top_10_products.csv")
df["total_revenue"] = df["total_revenue"].replace('[\$,]', '', regex=True).astype(float)

# Sort products by revenue for bottom-to-top plotting
df = df.sort_values("total_revenue", ascending=True)

# Set plot style
plt.figure(figsize=(12, 6))
sns.set_style("whitegrid")

# Create horizontal barplot
ax = sns.barplot(
    data=df,
    x="total_revenue",
    y="product_name",
    palette="viridis"
)

# Format x-axis as currency
ax.xaxis.set_major_formatter(mtick.FuncFormatter(lambda x, _: f"${x/1e6:.1f}M"))

# Add labels and title
plt.title("Top 10 Products by Revenue", fontsize=16)
plt.xlabel("Total Revenue ($)", fontsize=12)
plt.ylabel("Product", fontsize=12)

# Optional: Add value labels
for i, row in df.iterrows():
    ax.text(
        row["total_revenue"] + 25000, i,  # position just beyond bar end
        f"${row['total_revenue'] / 1e6:.1f}M",
        color='black', fontsize=9, va='center'
    )

# Final layout
plt.tight_layout()
plt.show()
