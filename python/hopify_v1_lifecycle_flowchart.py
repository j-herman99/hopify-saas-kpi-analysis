import os
from graphviz import Digraph

# Initialize the flowchart
dot = Digraph(comment='Hopify SaaS Customer Lifecycle Flow')

# Add nodes with styling
dot.node('A', 'Customer Signup', shape='ellipse', style='filled', color='lightblue')
dot.node('B', 'Active Customer', shape='ellipse', style='filled', color='lightgreen')
dot.node('C', 'Churn Event', shape='ellipse', style='filled', color='lightcoral')
dot.node('D', 'Retention / Upsell', shape='ellipse', style='filled', color='gold')

# Define edges (flow connections)
dot.edge('A', 'B', label='Activation')
dot.edge('B', 'C', label='Churn Risk')
dot.edge('B', 'D', label='Retention Efforts')
dot.edge('D', 'B', label='Loyalty Programs')

# Output path (repo-friendly)
output_path = os.path.join(os.path.dirname(__file__), '..', 'visuals', 'hopify_v1_lifecycle_flowchart')

# Render the flowchart to PNG
dot.render(output_path, format='png', view=False)

print('✅ Flowchart generated at /visuals/hopify_v1_lifecycle_flowchart.png')
