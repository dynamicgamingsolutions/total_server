-- ALL DATABASE QUERIES - Dynamic Gaming Solutions
-- Complete SELECT TOP 100 statements for all tables and views
-- Run these queries and save results to analyze data relationships

-- ==============================================
-- CLIENT DATABASE QUERIES
-- ==============================================
USE clients;

-- 1. Casinos Table
SELECT TOP 100 * FROM casinos;

-- 2. Clients Table  
SELECT TOP 100 * FROM clients;

-- 3. Casino Table (if different from casinos)
SELECT TOP 100 * FROM casino_table;

-- 4. Projects Table
SELECT TOP 100 * FROM projects;

-- 5. Sales Order Table
SELECT TOP 100 * FROM sales_order;

-- 6. Order Detail Table
SELECT TOP 100 * FROM order_detail;

-- 7. Notes Table
SELECT TOP 100 * FROM notes;

-- 8. States Table
SELECT TOP 100 * FROM states;

-- 9. Tribe Table
SELECT TOP 100 * FROM tribe;

-- ==============================================
-- INVENTORY DATABASE QUERIES
-- ==============================================
USE inventory;

-- 1. Slot Master Update Table (Main EGM inventory)
SELECT TOP 100 * FROM slot_master_update;

-- 2. Asset Table
SELECT TOP 100 * FROM asset_table;

-- 3. Slot Master Table (if different from slot_master_update)
SELECT TOP 100 * FROM slot_master_table;

-- 4. Slot Master Performance View
SELECT TOP 100 * FROM slot_master_performance;

-- 5. Slot Master View
SELECT TOP 100 * FROM slot_master_view;

-- ==============================================
-- VENDOR DATABASE QUERIES
-- ==============================================
USE vendors;

-- 1. Vendors Table
SELECT TOP 100 * FROM vendors;

-- 2. Bill Validators Table
SELECT TOP 100 * FROM bill_validators_table;

-- 3. Cabinet Table
SELECT TOP 100 * FROM cabinet_table;

-- 4. Player Tracking Table
SELECT TOP 100 * FROM player_tracking_table;

-- 5. Printer Table
SELECT TOP 100 * FROM printer_table;

-- 6. Themes Table
SELECT TOP 100 * FROM themes;

-- ==============================================
-- FINANCE DATABASE QUERIES
-- ==============================================
USE finance;

-- 1. Reports Table
SELECT TOP 100 * FROM reports_table;

-- 2. Report Match View (Cross-database view joining reports with casino, tribe, and state data)
SELECT TOP 100 * FROM report_match;

-- ==============================================
-- LOGS DATABASE QUERIES
-- ==============================================
USE logs;

-- 1. Activity Logs Table (Central audit trail for all database changes)
SELECT TOP 100 * FROM activity_logs;
