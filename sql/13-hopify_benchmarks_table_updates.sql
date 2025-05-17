/*
Created By: Jade Herman
Created On: 2025-05-13
Description: SaaS Benchmarks Table Updated

*/

-- 1. Clear previous benchmarks
DELETE FROM benchmarks;

-- 2. (Optional) Reset ID counter
DELETE FROM sqlite_sequence WHERE name = 'benchmarks';

-- 3. Insert updated benchmarks

INSERT INTO benchmarks (metric_category, segment, metric_name, target_value, description) VALUES
-- 🔄 NRR % Targets by Segment
('Revenue KPIs', 'Enterprise', 'NRR % Target', 125, 'Enterprise Net Revenue Retention target'),
('Revenue KPIs', 'Mid-Market', 'NRR % Target', 115, 'Mid-Market Net Revenue Retention target'),
('Revenue KPIs', 'SMB', 'NRR % Target', 105, 'SMB Net Revenue Retention target'),

-- 🔄 GRR % Targets by Segment
('Revenue KPIs', 'Enterprise', 'GRR % Target', 98, 'Enterprise Gross Revenue Retention target'),
('Revenue KPIs', 'Mid-Market', 'GRR % Target', 92, 'Mid-Market Gross Revenue Retention target'),
('Revenue KPIs', 'SMB', 'GRR % Target', 85, 'SMB Gross Revenue Retention target'),

-- 🔄 Monthly Churn % Targets by Segment
('Customer KPIs', 'Enterprise', 'Monthly Churn % Target', 1.0, 'Target monthly churn rate for Enterprise customers'),
('Customer KPIs', 'Mid-Market', 'Monthly Churn % Target', 2.5, 'Target monthly churn rate for Mid-Market customers'),
('Customer KPIs', 'SMB', 'Monthly Churn % Target', 4.5, 'Target monthly churn rate for SMB customers'),

-- 🔄 Monthly New Customer Targets by Segment
('Customer KPIs', 'Enterprise', 'Monthly New Customers Target', 200, 'Target new customer acquisition volume for Enterprise'),
('Customer KPIs', 'Mid-Market', 'Monthly New Customers Target', 600, 'Target new customer acquisition volume for Mid-Market'),
('Customer KPIs', 'SMB', 'Monthly New Customers Target', 1200, 'Target new customer acquisition volume for SMB'),

-- ✅ Global Benchmarks (applied to all segments unless overridden)
('Revenue KPIs', 'All Segments', 'MRR Target', 2000000, 'Monthly recurring revenue goal'),
('Support KPIs', 'All Segments', 'Avg Resolution Time Target (hrs)', 48, 'Target average resolution time for support tickets'),
('Support KPIs', 'All Segments', 'Support to Churn Correlation %', 0.3, 'Estimated churn correlation from high support volume'),
('Marketing KPIs', 'All Segments', 'MQL Conversion Rate %', 15, 'Marketing Qualified Lead conversion rate target'),
('Marketing KPIs', 'All Segments', 'CAC Target', 500, 'Customer Acquisition Cost target (USD)');
