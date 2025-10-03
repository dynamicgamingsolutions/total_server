USE finance
GO

CREATE VIEW report_match AS

SELECT
    r.payment_method AS "Pmt Mtd",
    r.fee_structure AS "Fee Structure",
    r.invoice_number AS "Invoice#",
    tr.tribe_name AS "Tribe",
    cn.casino_short AS "Casino",
    st.state_abbreviation AS "State",
    r.date_report_received AS "Date Report Rec",
    r.amount_revenue_reported AS "Amt of Rev Rep",
    r.date_revenue_received AS "Date Rev Received",
    r.amount_revenue_received AS "Amt of Rev Received",
    r.variance AS "Variance",
    r.date_invoiced AS "Date Invoiced",
    r.date_due AS "Date Due",
    r.uuid,
    r.update_date AS "Last Update",
    r.report_month
FROM 
    finance.dbo.reports r

JOIN clients.dbo.casinos cn
    ON r.casino_id = cn.reference_key

JOIN clients.dbo.tribes tr
    ON r.tribe_id = tr.reference_key

JOIN clients.dbo.states st
    ON r.state_id = st.reference_key