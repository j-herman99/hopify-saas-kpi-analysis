import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime

# Load data
orders = pd.read_csv('/users/jade.herman/Documents/00_github/hopify-saas-kpi-analysis/sql_outputs/03_cohort_ret_analysisorders.csv', parse_dates=['order_date'])
customers = pd.read_csv('customers.csv')

# Merge segment info
orders = orders.merge(customers[['customer_id', 'customer_segment']], on='customer_id')

# Get each customer's first order month
orders['order_month'] = orders['order_date'].dt.to_period('M')
first_orders = orders.groupby('customer_id')['order_month'].min().reset_index()
first_orders.rename(columns={'order_month': 'first_order_month'}, inplace=True)

# Merge back to orders to calculate cohort index
orders = orders.merge(first_orders, on='customer_id')
orders['cohort_index'] = (orders['order_month'] - orders['first_order_month']).apply(lambda x: x.n)

# Count active customers by segment and cohort index
survival = orders.groupby(['customer_segment', 'cohort_index'])['customer_id'].nunique().reset_index()
initial_counts = survival[survival['cohort_index'] == 0][['customer_segment', 'customer_id']]
initial_counts.rename(columns={'customer_id': 'initial_customers'}, inplace=True)

# Merge to get % retained
survival = survival.merge(initial_counts, on='customer_segment')
survival['retention_pct'] = survival['customer_id'] / survival['initial_customers']

# Pivot to wide format for display
survival_table = survival.pivot(index='customer_segment', columns='cohort_index', values='retention_pct')
survival_table = survival_table.round(3)  # Round for display

# Display table
import ace_tools as tools; tools.display_dataframe_to_user(name="Segment Survival Table", dataframe=survival_table)
