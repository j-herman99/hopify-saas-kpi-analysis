
from graphviz import Digraph

# Hopify v15 Customer Lifecycle Flowchart (Graphviz-only, Mac-safe)

dot = Digraph(comment='Hopify v15 Lifecycle Flow')

dot.node('A', 'Customer Signup')
dot.node('B', 'Active Customer')
dot.node('C', 'Churn Event')
dot.node('D', 'Retention / Upsell')

dot.edge('A', 'B', label='Activation')
dot.edge('B', 'C', label='Churn Risk')
dot.edge('B', 'D', label='Retention Efforts')
dot.edge('D', 'B', label='Loyalty Programs')

dot.render('hopify_v15_lifecycle_flowchart', format='png', view=False)
print('✅ Flowchart generated: hopify_v15_lifecycle_flowchart.png')
