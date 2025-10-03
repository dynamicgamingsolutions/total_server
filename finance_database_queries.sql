-- FINANCE DATABASE QUERIES
-- Dynamic Gaming Solutions - Financial Reporting and Revenue Tracking

USE finance;

-- 1. Reports Table
SELECT TOP 100 * FROM reports_table;

-- 2. Report Match View (Cross-database view joining reports with casino, tribe, and state data)
SELECT TOP 100 * FROM report_match;
