# 🧠 Hopify Product & Customer Behavior Insights – Python Scripts

This module explores how product engagement, support patterns, and behavioral traits vary by customer segment. The goal is to identify key revenue drivers and potential cross-sell opportunities.

---

## 📦 File Organization

### 🐍 Python Scripts (Zipped)
Includes plotting logic for behavior insights, cross-sell trends, CAC/payback benchmarks, and AOV comparisons.

📁 [`hopify_behavior_py_scripts.zip`](./hopify_behavior_py_scripts.zip)

Contents:
- `01_hopify_avg_subs_rev_seg.py` – Subscription revenue averages by segment
- `02_hopify_cac_v_payback_seg.py` – CAC vs payback period category breakdown
- `03_hopify_customer_seg_behavior_summary.py` – Behavior metrics summary
- `04_hopify_supp_tckt_avg_resolv_plots.py` – Support ticket volumes vs resolution time
- `05_hopify_product_aov_seg_plot.py` – AOV by product category and segment
- `06_hopify_top_products_barplot.py` – Top revenue-driving products
- `07_hopify_cross_sell_products_seg_plot.py` – Cross-sell opportunities by segment

---

### 📓 Jupyter Notebooks (`/ipynb`)
Notebook versions for interactive EDA, used for visual storytelling and slide-ready exports.

- `01_hopify_avg_subs_rev_seg.ipynb`
- `02_hopify_cac_v_payback_seg.ipynb`
- `03_hopify_customer_seg_behavior.ipynb`
- `04_hopify_supp_tckt_avg_resolv_plots.ipynb`
- `05_hopify_product_aov_seg_plot.ipynb`
- `06_hopify_top_products_seg.ipynb`
- `07_hopify_cross_sell_products_seg_plot.ipynb`

---

## 🔍 Key Use Cases

- Identifying high-revenue vs low-AOV segments
- Understanding behavior-impacting churn (e.g., support load)
- Analyzing customer engagement metrics by segment
- Surfacing cross-sell product bundles for revenue growth

---

## ✅ Tools Used

- Python (`pandas`, `matplotlib`, `seaborn`)
- Jupyter Notebooks for analysis and export
- Input: SQL-exported CSVs joined by segment and behavior flags

---