# ===============================================
# 🔥 Hopify Segment-Aware Churn Rate Heatmap
# ===============================================

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ================================
# 📁 Set Base Path to Project Root
# ================================

try:
    # Script context
    BASE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
except NameError:
    # Jupyter or interactive context
    BASE_PATH = os.path.abspath(os.path.join(os.getcwd(), "..", "..", ".."))

print("📁 Base path set to:", BASE_PATH)

# ================================
# 📥 Load Data from Both CSVs
# ================================

file_path_ret_curve = os.path.join(
    BASE_PATH, "01_project_artifacts", "02_sql_output",
    "01_project_churn_retention_analysis", "07_hopify_retention_curve_signup_cohort.csv"
)

file_path_churn_var = os.path.join(
    BASE_PATH, "01_project_artifacts", "02_sql_output",
    "01_project_churn_retention_analysis", "04_hopify_cohort_churn_var_seg.csv"
)

df_curve = pd.read_csv(file_path_ret_curve)
df_churn = pd.read_csv(file_path_churn_var)

# ================================
# 🧼 Clean & Normalize Column Names
# ================================

for df in [df_curve, df_churn]:
    df.columns = (
        df.columns
        .str.strip()
        .str.replace(" ", "_")
        .str.replace("%", "percent")
        .str.replace("-", "_")
        .str.lower()
    )

print("🧪 Retention Curve Columns:", df_curve.columns.tolist())
print("🧪 Churn Var Columns:", df_churn.columns.tolist())

# ================================
# 🧮 Compute Churn Rate
# ================================

# Use only df_curve for the heatmap (more granular: cohort × segment × month offset)
df_curve["churn_rate"] = 1 - (df_curve["retention_percent"] / 100)

# ================================
# 🎯 Segment Loop: Heatmap per Segment
# ================================

segments = df_curve["customer_segment"].unique()

for segment in segments:
    seg_df = df_curve[df_curve["customer_segment"] == segment].copy()

    # Pivot data to matrix: rows = cohort month, columns = months since signup
    heatmap_data = seg_df.pivot_table(
        index="signup_cohort_month",
        columns="months_since_signup",
        values="churn_rate",
        aggfunc="mean"
    )

    # ================
    # 🎨 Plot Heatmap
    # ================
    sns.set(style="white")
    plt.figure(figsize=(20, 10))

    ax = sns.heatmap(
        heatmap_data,
        cmap="viridis",
        annot=True,
        fmt=".0%",
        linewidths=0.5,
        linecolor='gray',
        cbar_kws={"label": "Churn Rate (%)"},
        annot_kws={"size": 7},
        vmin=0,
        vmax=0.50
    )

    ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha="right")
    ax.set_yticklabels(ax.get_yticklabels(), rotation=0)

    plt.title(f"Churn Rate Heatmap – {segment}", fontsize=16, fontweight="bold")
    plt.xlabel("Months Since Signup", fontsize=12, fontweight="bold")
    plt.ylabel("Signup Cohort Month", fontsize=12, fontweight="bold")
    plt.tight_layout()

    # =====================
    # 💾 Save Each Segment
    # =====================
    output_path = os.path.join(
        BASE_PATH,
        "05_visuals",
        "01_project_churn_retention_analysis",
        f"hopify_churn_heatmap_{segment.lower().replace('-', '').replace(' ', '_')}.png"
    )
    plt.savefig(output_path, dpi=300)
    plt.show()

    # ===============================================
# ✅ Hopify Churn Rate Heatmap by Cohort & Month
# ===============================================

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# ================================
# 📁 Set Base Path to Project Root
# ================================

BASE_PATH = os.path.expanduser("~/Documents/00_github/hopify_saas_kpi_analysis")

# ================================
# 📥 Load Raw Data
# ================================

file_path = os.path.join(
    BASE_PATH,
    "01_project_artifacts",
    "02_sql_output",
    "01_project_churn_retention_analysis",
    "07_hopify_retention_curve_signup_cohort.csv"
)

df = pd.read_csv(file_path)

# ================================
# 🧼 Clean Column Names
# ================================

df.columns = (
    df.columns
    .str.strip()
    .str.replace(" ", "_")
    .str.replace("%", "percent")
    .str.replace("-", "_")
    .str.lower()
)

print("🧪 Cleaned columns:", df.columns.tolist())

# ================================
# 🎯 Filter for Segment (optional)
# ================================

df = df[df["customer_segment"] == "Mid-Market"]

# ================================
# 🧮 Compute Churn Rate
# ================================

df["churn_rate"] = 1 - (df["remaining_active_customers"] / df["total_cohort_customers"])
df["churn_rate"] = df["churn_rate"].clip(lower=0).round(4)

# Pivot data to matrix format
heatmap_data = df.pivot_table(
    index="signup_cohort_month",
    columns="months_since_signup",
    values="churn_rate",
    aggfunc="mean"
)

# ================================
# 🎨 Plot Heatmap with Accessible Palette
# ================================

sns.set(style="white")
plt.figure(figsize=(20, 10))

ax = sns.heatmap(
    heatmap_data,
    cmap="viridis",
    annot=True,
    fmt=".0%",
    linewidths=0.5,
    linecolor='gray',
    cbar_kws={"label": "Churn Rate (%)"},
    annot_kws={"size": 7},
    vmin=0,
    vmax=0.50
)

# Clean tick labels
ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha="right")
ax.set_yticklabels(ax.get_yticklabels(), rotation=0)

plt.title("Churn Rate Heatmap – Mid-Market", fontsize=16, fontweight="bold")
plt.xlabel("Months Since Signup", fontsize=12, fontweight="bold")
plt.ylabel("Signup Cohort Month", fontsize=12, fontweight="bold")
plt.tight_layout()
