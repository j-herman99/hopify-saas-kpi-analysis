import sqlite3
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from datetime import datetime

# ----------------------------
# 1. Connect to SQLite Database
# ----------------------------
conn = sqlite3.connect('/Users/jade.herman/Documents/00_github/hopify-saas-db-generator/data/hopify_saas_v1.db')  # Update if path differs

# ----------------------------
# 2. SQL Query: Retained Customers Over Time (by Cohort & Segment)
# ----------------------------

query = """
WITH cohort_base AS (
    SELECT 
        c.customer_id,
        c.customer_segment,
        strftime('%Y-%m', c.signup_date) AS signup_cohort,
        DATE(c.signup_date) AS signup_date
    FROM customers c
),
months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
),
customer_months AS (
    SELECT 
        cb.customer_id,
        cb.customer_segment,
        cb.signup_cohort,
        DATE(cb.signup_date, printf('+%d months', mss.month_offset)) AS cohort_month,
        mss.month_offset
    FROM cohort_base cb
    CROSS JOIN months_since_signup mss
),
retention AS (
    SELECT 
        cm.signup_cohort,
        cm.customer_segment,
        cm.cohort_month,
        cm.month_offset,
        COUNT(DISTINCT o.customer_id) AS retained_customers
    FROM customer_months cm
    LEFT JOIN orders o 
        ON cm.customer_id = o.customer_id
        AND strftime('%Y-%m', o.order_date) = strftime('%Y-%m', cm.cohort_month)
    GROUP BY 1, 2, 3, 4
)

SELECT * FROM retention
ORDER BY customer_segment, signup_cohort, month_offset;
"""

df = pd.read_sql_query(query, conn)
conn.close()

# Parse dates
df["cohort_month"] = pd.to_datetime(df["cohort_month"])

# Sort segments for consistent row order
segment_order = ["Enterprise", "Mid-Market", "SMB"]
df["customer_segment"] = pd.Categorical(df["customer_segment"], categories=segment_order, ordered=True)

# Plot (Wide Layout: rows = segments, columns = months)
sns.set(style="whitegrid", rc={"axes.facecolor": "#F9F9F9"})
g = sns.relplot(
    data=df,
    kind="line",
    x="cohort_month",
    y="retained_customers",
    hue="signup_cohort",
    col=None,
    row="customer_segment",
    marker="o",
    palette="viridis",
    height=3.5,
    aspect=3,
    facet_kws={"sharey": False}
)

g.set_titles("{row_name} Segment")
g.set_axis_labels("Month", "Retained Customers")
g.fig.subplots_adjust(top=0.93)
g.fig.suptitle("Retained Customers Over Time by Segment (Faceted)", fontsize=14)
g.add_legend(title="Cohort", bbox_to_anchor=(1.05, 0.5), loc='center left', borderaxespad=0.)

for ax in g.axes.flat:
    for label in ax.get_xticklabels():
        label.set_rotation(45)

df = pd.read_sql_query(query, conn)
conn.close()

# ----------------------------
# 3. Plot: Retained Customers Over Time by Segment (Faceted)
# ----------------------------

# Parse dates
df["cohort_month"] = pd.to_datetime(df["cohort_month"])

# Sort segments for consistent row order
segment_order = ["Enterprise", "Mid-Market", "SMB"]
df["customer_segment"] = pd.Categorical(df["customer_segment"], categories=segment_order, ordered=True)

# Plot (Wide Layout: rows = segments, columns = months)
sns.set(style="whitegrid", rc={"axes.facecolor": "#F9F9F9"})
g = sns.relplot(
    data=df,
    kind="line",
    x="cohort_month",
    y="retained_customers",
    hue="signup_cohort",
    col=None,
    row="customer_segment",
    marker="o",
    palette="viridis",
    height=3.5,
    aspect=3,
    facet_kws={"sharey": False}
)

g.set_titles("{row_name} Segment")
g.set_axis_labels("Month", "Retained Customers")
g.fig.subplots_adjust(top=0.93)
g.fig.suptitle("Retained Customers Over Time by Segment (Faceted)", fontsize=14)
g.add_legend(title="Cohort", bbox_to_anchor=(1.05, 0.5), loc='center left', borderaxespad=0.)

for ax in g.axes.flat:
    for label in ax.get_xticklabels():
        label.set_rotation(45)

# ----------------------------
# 4. Save Plot
# ----------------------------
output_path = "/Users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/visuals/01_Project_Churn_Retention_Analysis/hopify_retained_cust_over_time_seg.png"
plt.savefig(output_path, bbox_inches='tight')
plt.close()

print(f"Chart saved to: {output_path}")
