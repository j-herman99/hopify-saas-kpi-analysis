# 📊 Universal KPI Script Overview

This document explains the logic behind the [`universal_kpi_script.sql`](../sql/universal_kpi_script.sql) file used to dynamically compare actual KPIs against benchmarks by segment and month.

---

## ✅ Purpose of Each Section in `universal_kpi_script.sql`

### 1️⃣ `WITH monthly_metrics AS (...)`

Calculates raw KPIs per month and segment:

- ARPU  
- Churn Rate %  
- NRR % and GRR % *(placeholders included)*  

---

### 2️⃣ `benchmarks_universal AS (...)`

Combines:

- Segment-specific benchmarks (e.g., SMB, Mid-Market, Enterprise)  
- Global fallback values from `"All Segments"`

---

### 3️⃣ `benchmarks_resolved AS (...)`

Ensures that each KPI pulls the most specific benchmark available:

- ✅ Uses **segment-specific** benchmarks if available  
- 🔄 Falls back to **"All Segments"** if not

---

### 4️⃣ `SELECT ... FROM monthly_metrics`

Final query joins actual KPI values with benchmarks to produce output-ready rows.

#### 📥 Output Columns Include:
- `month`
- `segment`
- `actual_arpu`, `benchmark_arpu`
- `actual_churn_rate`, `benchmark_churn_rate`
- *(and others, as added)*

---

## ✅ Summary

This script is already optimized for:

- KPI grouping by segment  
- Smart fallback resolution to global benchmarks  
- Output-ready tables for executive reporting, dashboards, or charts

For full functionality, open the SQL file:  
📄 [`universal_kpi_script.sql`](../sql/hopify_universal_kpi_script.sql)