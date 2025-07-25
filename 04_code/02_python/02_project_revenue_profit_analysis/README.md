# 💰 Hopify SaaS - Part 2: Revenue & Profitability Analysis – Python Scripts

This module focuses on key SaaS financial metrics such as ARPU, MRR, NRR/GRR, and LTV. Python scripts are used to generate visualizations and insights across customer segments and time periods.

---

## 📦 File Organization

### 🐍 Python Scripts (Zipped)
Core analytics logic for generating time-series plots, benchmarks, and executive visual summaries.

📁 [`hopify_revenue_py_scripts.zip`](./hopify_revenue_py_scripts.zip)

Contents:
- `01_hopify_arpu_time_plot.py` – ARPU over time by segment
- `02_hopify_exp_rev_time_seg.py` – Expected revenue trends
- `03_hopify_3_mo_rolling_avg_v_monthly_active_cust_time.py` – Activity vs revenue
- `04_hopify_mrr_v_target_seg.py` – MRR vs target benchmarks
- `05_hopify_nrr_grr_grid_plots.py` – NRR/GRR matrix charts
- `06_hopify_ltv_exec_summ_barplot.py` – LTV summary visualization
- `07_hopify_ltv_v_target_seg.py` – LTV actual vs target by segment

---

### 📓 Jupyter Notebooks (`/ipynb`)
Notebook versions for interactive storytelling and exploratory visualization.

- `01_hopify_arpu_time_series_plot.ipynb`
- `02_hopify_exp_rev_time_series_seg.ipynb`
- `03_hopify_3mo_rolling_avg_v_monthly_active_cust_plot.ipynb`
- `04_hopify_mrr_v_target_seg.ipynb`
- `05_hopify_nrr_grr_grid_plots.ipynb`
- `06_hopify_ltv_exec_summ_barplot.ipynb`
- `07_hopify_ltv_v_target_seg.ipynb`

---

## 🧠 Use Cases

- Benchmarking ARPU and MRR by customer type
- Visualizing net revenue retention (NRR) and gross retention (GRR)
- Evaluating lifetime value (LTV) and customer profitability
- Tracking engagement-revenue alignment using rolling averages

---

## ✅ Tools Used

- Python (`pandas`, `seaborn`, `matplotlib`)
- Jupyter Notebooks for interactive reporting
- SQL-exported CSVs for data source inputs
