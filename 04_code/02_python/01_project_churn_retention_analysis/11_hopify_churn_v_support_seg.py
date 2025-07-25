## ==========================================================
## 📊 Hopify Churn vs Support Volume by Segment
## ==========================================================

import os
import pandas as pd
import plotly.express as px

# ================================
# 📁 Set Base Path to Project Root
# ================================

try:
    BASE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
except NameError:
    # Jupyter or interactive context
    BASE_PATH = os.path.abspath(os.path.join(os.getcwd(), "..", "..", ".."))

print("📁 Base path set to:", BASE_PATH)

# ================================
# 📥 Load & Clean Data
# ================================


# Load your final support_df (assumes it's already cleaned)
support_path = os.path.join(
    BASE_PATH,
    "01_project_artifacts",
    "02_sql_output",
    "01_project_churn_retention_analysis",
    "08_hopify_supp_tckt_vol_v_churn_seg.csv"
)

df = pd.read_csv(support_path)

# ================================
# 📊 Plotly Faceted Bar Chart
# ================================

# Use categorical ordering
df["Segment"] = pd.Categorical(df["Segment"], categories=["Enterprise", "Mid-Market", "SMB"], ordered=True)
df["Support Ticket Group"] = pd.Categorical(
    df["Support Ticket Group"],
    categories=[
        "No Support Tickets",
        "Low-Mid Support Volume (1-4 Tickets)",
        "High Support Volume (5+ Tickets)"
    ],
    ordered=True
)

# Create a hover label string column
df["Label"] = df.apply(
    lambda row: f"Churn Rate: {row['Churn Rate %']:.1f}%<br>Customer % of Segment: {row['Customer % of Segment']:.0f}%", axis=1
)

fig = px.bar(
    df,
    x="Churn Rate %",
    y="Support Ticket Group",
    color="Support Ticket Group",
    facet_col="Segment",
    orientation="h",
    hover_name="Support Ticket Group",
    hover_data={"Churn Rate %": False, "Support Ticket Group": False, "Label": True},
    color_discrete_sequence=px.colors.sequential.Viridis
)

# ================================
# 🖌️ Formatting
# ================================

fig.update_traces(
    text=df["Churn Rate %"].round(1).astype(str) + "%",
    textposition='inside',
    insidetextanchor='middle',
    textfont=dict(color="white", size=12)
)

fig.update_layout(
    title="Churn Rate vs Support Ticket Volume by Segment",
    title_font_size=20,
    height=500,
    barmode='group',
    margin=dict(t=80, b=80),
    legend_title_text="Support Volume Group",
    legend=dict(
        bgcolor="rgba(255,255,255,0.9)",
        bordercolor="gray",
        borderwidth=1,
        x=1.02,
        y=0.5,
        xanchor='left',
        yanchor='middle',
        font=dict(size=12)
    )
)

fig.update_xaxes(title_text="Churn Rate (%)", title_font=dict(size=14), tickformat=".0%")
fig.update_yaxes(title_text="")

# ================================
# 💾 Save & Show
# ================================

output_html = os.path.join(BASE_PATH, "05_visuals", "hopify_churn_vs_support_plotly.html")
fig.write_html(output_html)

fig.show()