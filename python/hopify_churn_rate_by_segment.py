import sqlite3
import pandas as pd
import matplotlib.pyplot as plt

#Connect to SQLite database file

conn = sqlite3.connect('/Users/jade.herman/Documents/00_github/hopify_db_v1/data/hopify_saas_v1.db')

#Run SQL Query & Load into Pandas DF

query = """

SELECT
    strftime('%Y-%m', churn_date) AS churn_month,
    customer_segment,
    COUNT(DISTINCT customer_id) AS churned_customers

FROM
    churn_events

JOIN
    customers USING (customer_id)

GROUP BY
    churn_month, customer_segment

ORDER BY
    churn_month DESC, customer_segment;

"""

df = pd.read_sql_query(query, conn)

print(df.head())

import matplotlib.pyplot as plt

# Pivot data for easier plotting
pivot_df = df.pivot(index='churn_month', columns='customer_segment', values='churned_customers')

# Plot
pivot_df.plot(kind='line', marker='o', figsize=(10,6))
plt.title('Monthly Churned Customers by Segment')
plt.ylabel('Churned Customers')
plt.xlabel('Month')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

conn.close()
