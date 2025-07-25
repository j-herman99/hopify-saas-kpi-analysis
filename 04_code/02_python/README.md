# 🐍 Hopify KPI Visualization Scripts (Python)

This folder contains Python scripts and notebooks used to generate business-ready visualizations, flowcharts, and simulations for the Hopify SaaS KPI Analysis Project. These visuals support executive summaries and presentations across all portfolio themes.

---

## 📁 Folder Structure

| Folder/File | Description |
|-------------|-------------|
| `01_part_churn_retention/` | Python scripts for churn rate, retention cohorts, lifecycle flows, and funnel visualization |
| `02_part_revenue_profitability/` | Scripts generating ARPU trends, expansion revenue, NRR/GRR visualizations, and CAC payback |
| `03_part_product_cust_insights/` | Visuals showing AOV, customer behavior summaries, top products, and support metrics |
| `ipynb/` | Jupyter notebook versions of finalized scripts (same structure as folders above) |
| `sandbox/` | Exploratory scripts such as burndown charts and experimental visual prototypes |

---

## 🧪 Script Examples

| Script | Summary |
|--------|---------|
| `hopify_arpu_vs_target_seg.py` | ARPU trend vs. target per segment |
| `hopify_nrr_grr_over_time.py` | NRR & GRR line plot with benchmark overlays |
| `hopify_avg_subs_rev_seg.py` | Bar plots for average subscription price and customer count |
| `hopify_top_10_products.py` | Horizontal bar plot of top 10 products by revenue |
| `hopify_top_cross_sell_combos.py` | Top 2 cross-sell combos per segment |

---

## 🖼 Output

All plots and diagrams are exported to: /05_visuals/[project_folder]/[figure_name].png


These visuals are used in executive reports and presentation slides stored under `/02_documentation/`.

---

## ⚙️ Requirements

Install dependencies using:

```bash
pip install -r requirements.txt

### 📦 Dependencies

| Package     | Purpose                                                   |
|-------------|-----------------------------------------------------------|
| `pandas`    | Data manipulation and analysis                            |
| `matplotlib`| Static plotting for detailed customization                |
| `seaborn`   | High-level statistical plotting                           |
| `plotly`    | Interactive visualizations (optional usage)               |
| `graphviz`  | Generating flow diagrams (requires system installation)   |

---

### 📝 Notes

- Visual scripts are organized by analysis theme (`churn`, `revenue`, `product behavior`) for clarity and reuse.
- Jupyter notebooks mirror Python scripts for interactive use, testing, or tweaking.
- The `/sandbox/` folder includes early-stage or experimental visual ideas.
- Most plots are exported as `.png` files to the `05_visuals/` directory and embedded in executive slides.
- For `graphviz`, installation may require OS-level setup (e.g., `brew install graphviz` on macOS).

---

