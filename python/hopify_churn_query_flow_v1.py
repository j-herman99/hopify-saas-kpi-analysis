
from graphviz import Digraph

# Create a new directed graph
dot = Digraph(comment='Optimized Churn Rate Query Flow (v1)', format='png')

# Define nodes
dot.node('A', 'CUSTOMER_MONTHS\n(CTE selects months from sign-up & churn dates)')
dot.node('B', 'ACTIVE_CUSTOMERS\n(CTE joins churn events with current customers)')
dot.node('C', 'CHURNED_CUSTOMERS\n(CTE calculates churned customers by month & segment)')
dot.node('D', 'Output Result\n(Churn rate calculated per month & segment)')

# Define edges
dot.edge('A', 'B')
dot.edge('B', 'C')
dot.edge('C', 'D')

# Render and save to file
output_path = 'churn_query_flow_v1'
dot.render(output_path, view=False)

print(f"Flowchart saved as {output_path}.png")
