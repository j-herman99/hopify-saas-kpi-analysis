# 🌀 Hopify Churn & Retention Analysis – Python Scripts

This module contains the Python-based logic and visualizations for analyzing customer churn, retention trends, and cohort behaviors across Hopify's B2B SaaS segments.

---

## 📦 File Organization

### 🐍 Python Scripts (Zipped)
All core logic scripts are written as reusable `.py` modules for automation, reporting, and integration into larger workflows.

📁 [`hopify_churn_py_scripts.zip`](./hopify_churn_py_scripts.zip)

Contents:
- `01_hopify_churn_kpi.py` – Core KPIs by segment
- `02_hopify_churn_visual.py` – Monthly churn bars & lines
- `03_hopify_churn_time_series_line_chart.py` – Time series plot
- `04_hopify_seg_survival_table.py` – Segment survival tracking
- `05_hopify_seg_retention_heatmaps.py` – Heatmaps by segment
- `06_hopify_retention_curve_plot.py` – Retention decay curves
- `07_hopify_retention_curve_seg_8_line_chart.py` – Retention overlay
- `08_hopify_cohort_reten_v_churn.py` – Cohort vs churn comparison
- `09_hopify_retained_cust_over_time_seg.py` – Retained customer plot
- `10_hopify_cohort_ret_curve_decay_visual.py` – Cohort retention decay
- `11_hopify_churn_v_support_seg.py` – Churn vs support volume

---

### 📓 Jupyter Notebooks (`/ipynb`)
Visual analysis notebooks for interactive review, presentation, and stakeholder sharing.

Each notebook mirrors a `.py` script with rendered charts and inline commentary.

- `01_hopify_churn_kpi.ipynb`
- `02_hopify_monthly_churn_visual.ipynb`
- `03_hopify_churn_time_series_line_plot.ipynb`
- `04_hopify_seg_survival_table.ipynb`
- `05_hopify_seg_retention_heatmaps.ipynb`
- `06_hopify_retention_curve_plot.ipynb`
- `07_hopify_retention_curve_seg_8_line_plot.ipynb`
- `08_hopify_cohort_reten_v_churn_plot.ipynb`
- `09_hopify_retained_cust_over_time_seg.ipynb`
- `10_hopify_cohort_ret_curve_decay_visual.ipynb`
- `11_hopify_churn_v_support_seg_plot.ipynb`

---

## 🧠 Use Cases

- Churn rate benchmarking and trends
- Retention decay and survival analysis
- Support ticket correlation with churn
- Segment-level and cohort-level retention patterns

---

## ✅ Tools Used

- Python (`pandas`, `matplotlib`, `seaborn`)
- Jupyter Notebooks for storytelling
- GitHub version control