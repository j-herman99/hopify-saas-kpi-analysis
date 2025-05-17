import sqlite3
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

# Connect to Hopify DB
conn = sqlite3.connect("/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/data/hopify_saas_v1.db")

# SQL Query for Retention % with Segment
query = """
WITH cohort_base AS (
    SELECT 
        c.customer_id,
        c.customer_segment,
        strftime('%Y-%m', c.signup_date) AS signup_cohort,
        julianday(c.signup_date) AS signup_jd
    FROM 
        customers c
),
months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
),
active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS remaining_customers
    FROM 
        cohort_base cb
    JOIN months_since_signup mss
    LEFT JOIN churn_events ce
        ON cb.customer_id = ce.customer_id
        AND julianday(ce.churn_date) <= cb.signup_jd + (mss.month_offset * 30)
    WHERE ce.churn_id IS NULL
    GROUP BY cb.signup_cohort, cb.customer_segment, mss.month_offset
),
cohort_sizes AS (
    SELECT 
        signup_cohort,
        customer_segment,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM cohort_base
    GROUP BY signup_cohort, customer_segment
)
SELECT
    ac.signup_cohort,
    ac.customer_segment,
    ac.month_offset,
    ac.remaining_customers,
    cs.total_customers,
    ROUND(ac.remaining_customers * 1.0 / cs.total_customers * 100, 2) AS retention_percent
FROM 
    active_customers_per_cohort ac
JOIN 
    cohort_sizes cs
    ON ac.signup_cohort = cs.signup_cohort
    AND ac.customer_segment = cs.customer_segment
ORDER BY 
    ac.signup_cohort DESC,
    ac.customer_segment,
    ac.month_offset ASC;
"""

# Load DataFrame
df = pd.read_sql_query(query, conn)

# Filter: Last 24 months cohorts only
recent_cutoff = (datetime.now() - timedelta(days=730)).strftime('%Y-%m')
df_recent = df[df['signup_cohort'] >= recent_cutoff]

# Generate Heatmap per Segment
for segment in df_recent['customer_segment'].unique():
    segment_df = df_recent[df_recent['customer_segment'] == segment]
    
    # Pivot to Heatmap format
    heatmap_data = segment_df.pivot(index='signup_cohort', columns='month_offset', values='retention_percent')
    
    # Plot Heatmap
    plt.figure(figsize=(12, 8))
    sns.heatmap(heatmap_data, annot=True, fmt=".1f", cmap="YlGnBu", linewidths=.5, cbar_kws={'label': 'Retention %'})
    
    plt.title(f'Cohort Retention Heatmap | {segment} Segment')
    plt.ylabel('Signup Cohort')
    plt.xlabel('Months Since Signup')
    plt.tight_layout()
    
    # Save as PNG
    plt.savefig(f'{segment.lower().replace(" ", "_")}_retention_heatmap.png')
    plt.show()

# Close DB connection
conn.close()

