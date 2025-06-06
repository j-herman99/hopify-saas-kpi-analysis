import pandas as pd

# Calculate churn summary KPIs
kpi_table = churn_df.groupby('Segment').agg({
    'Churn Rate %': ['mean', lambda x: x.iloc[-1]],
    'Benchmark Churn Rate %': 'first'
}).reset_index()

# Flatten columns
kpi_table.columns = ['Segment', 'Avg Actual Churn (%)', 'Most Recent Churn (%)', 'Benchmark Churn Rate (%)']

# Calculate variance
kpi_table['Variance to Benchmark'] = kpi_table['Most Recent Churn (%)'] - kpi_table['Benchmark Churn Rate (%)']

# Format nicely
kpi_table['Avg Actual Churn (%)'] = kpi_table['Avg Actual Churn (%)'].apply(lambda x: f"{x:.2%}")
kpi_table['Most Recent Churn (%)'] = kpi_table['Most Recent Churn (%)'].apply(lambda x: f"{x:.2%}")
kpi_table['Benchmark Churn Rate (%)'] = kpi_table['Benchmark Churn Rate (%)'].apply(lambda x: f"{x:.2%}")
kpi_table['Variance to Benchmark'] = kpi_table['Variance to Benchmark'].apply(lambda x: f"{x:+.2f} pts")

# Show table
import ace_tools as tools; tools.display_dataframe_to_user(name="Churn KPI Table", dataframe=kpi_table)
