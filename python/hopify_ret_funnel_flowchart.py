import os
from graphviz import Digraph

# Initialize the flowchart
dot = Digraph(comment='Hopify SaaS Retention Funnel Flow')

# Add funnel stages with styling
dot.node('A', 'New Signup', shape='ellipse', style='filled', color='lightblue')
dot.node('B', 'Trial User', shape='ellipse', style='filled', color='lavender')
dot.node('C', 'Active Customer', shape='ellipse', style='filled', color='lightgreen')
dot.node('D', 'Churned Customer', shape='ellipse', style='filled', color='lightcoral')
dot.node('E', 'Retained Customer', shape='ellipse', style='filled', color='gold')

# Define funnel flow edges
dot.edge('A', 'B', label='Trial Conversion')
dot.edge('B', 'C', label='Activation Success')
dot.edge('C', 'D', label='Churn Risk')
dot.edge('C', 'E', label='Retention Programs')
dot.edge('E', 'C', label='Loyalty Loop')

# Output path to /visuals/
output_path = os.path.join(os.path.dirname(__file__), '..', 'visuals', 'hopify_v1_retention_funnel_flowchart')

# Render to PNG
dot.render(output_path, format='png', view=False)

print('✅ Retention Funnel Flowchart generated at /visuals/hopify_v1_retention_funnel_flowchart.png')
