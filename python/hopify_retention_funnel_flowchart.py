// Hopify SaaS Retention Funnel Flow
digraph {
	A [label="New Signup" color=lightblue shape=ellipse style=filled]
	B [label="Trial User" color=lavender shape=ellipse style=filled]
	C [label="Active Customer" color=lightgreen shape=ellipse style=filled]
	D [label="Churned Customer" color=lightcoral shape=ellipse style=filled]
	E [label="Retained Customer" color=gold shape=ellipse style=filled]
	A -> B [label="Trial Conversion"]
	B -> C [label="Activation Success"]
	C -> D [label="Churn Risk"]
	C -> E [label="Retention Programs"]
	E -> C [label="Loyalty Loop"]
}
