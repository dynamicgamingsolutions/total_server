USE finance
GO
CREATE TABLE reports(
    uuid UNIQUEIDENTIFIER NULL DEFAULT NEWID(), -- Allow NULL and auto-generate UUID not if provided
    index_key INT IDENTITY(1,1) NOT NULL, -- Auto-incrementing identity column
    reference_key NVARCHAR(25) NULL,
    insert_date DATETIME NULL DEFAULT GETDATE(),
    update_date DATETIME NULL DEFAULT GETDATE(),
    update_by VARCHAR(50) NULL,
    change_log VARCHAR(255) NULL,
    payment_method NVARCHAR(50) NULL,
    fee_structure NVARCHAR(25) NULL,
    invoice_number INT NULL,
    casino_id NVARCHAR(25) NOT NULL,
    date_report_received DATE NULL,
    amount_revenue_reported DECIMAL(12, 2) NULL,
    date_revenue_received DATE NULL,
    amount_revenue_received DECIMAL(12, 2) NULL,
    variance AS (amount_revenue_reported - amount_revenue_received),
    date_invoiced DATE NULL,
    date_due DATE NULL
)


USE finance
GO
CREATE TRIGGER [trg_insert_report]
ON reports
AFTER INSERT
AS
BEGIN
    -- Generate UUID for rows where it is NULL
    UPDATE rep
    SET rep.uuid = NEWID()
    FROM reports rep
    INNER JOIN inserted i ON rep.index_key = i.index_key
    WHERE rep.uuid IS NULL;

    -- Populate reference_key and change_log for newly inserted rows
    UPDATE rep
    SET
        rep.reference_key = 'REP-' + RIGHT('000000000' + CAST(rep.index_key AS VARCHAR), 9),
        rep.change_log = 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)
    FROM reports rep
    INNER JOIN inserted i ON rep.index_key = i.index_key;

    -- Log the initial values into activity_logs
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name)
    SELECT 
        i.uuid AS log_id, -- Use the UUID column
        JSON_QUERY((SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS change_log,
        COALESCE(i.update_by, 'System') AS update_by, -- Fallback to 'System' if update_by is NULL
        'reports' AS table_name -- Hardcode the table name
    FROM inserted i
    WHERE i.uuid IS NOT NULL; -- Ensure UUID is not NULL
END
GO


USE finance
GO
CREATE TRIGGER [dbo].[trg_update_report]
ON reports
AFTER UPDATE
AS
BEGIN
    -- Step 1: Update the `update_date` for all updated rows
    UPDATE rep
    SET rep.update_date = GETDATE()
    FROM reports rep
    INNER JOIN inserted i ON rep.uuid = i.uuid;

    -- Step 2: Log the changes into `activity_logs`
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name, timestamp)
    SELECT 
        COALESCE(i.uuid, NEWID()) AS log_id, -- Ensure log_id is never NULL
        JSON_QUERY(( 
            SELECT 
                (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS before_values,
                (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS after_values
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS change_log, -- Log before and after values as JSON
        COALESCE(i.update_by, 'System') AS update_by, -- Fallback to 'System' if update_by is NULL
        'reports' AS table_name, -- Hardcode the table name
        GETDATE() AS timestamp -- Add the current timestamp
    FROM inserted i
    INNER JOIN deleted d ON i.uuid = d.uuid; -- Match updated rows

    -- Step 3: Update the `change_log` in `reports` with the most recent log reference
    UPDATE rep
    SET rep.change_log = 'Updated on ' + CONVERT(NVARCHAR, GETDATE(), 120) + ' Log key: (' + al.reference_key + ')'
    FROM reports rep
    INNER JOIN inserted i ON rep.uuid = i.uuid
    INNER JOIN (
        SELECT log_id, reference_key, ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY timestamp DESC) AS row_num
        FROM logs.dbo.activity_logs
    ) al ON al.log_id = i.uuid AND al.row_num = 1; -- Use the most recent log entry
END
GO
