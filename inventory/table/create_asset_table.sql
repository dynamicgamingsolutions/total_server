USE inventory
GO
-- SELECT * FROM asset_upload

CREATE TABLE assets(
    uuid UNIQUEIDENTIFIER NULL DEFAULT NEWID(), -- Allow NULL and auto-generate UUID not if provided
    index_key INT IDENTITY(1,1) NOT NULL, -- Auto-incrementing identity column
    reference_key NVARCHAR(25) NULL,
    insert_date DATETIME NULL DEFAULT GETDATE(),
    update_date DATETIME NULL DEFAULT GETDATE(),
    update_by VARCHAR(50) NULL,
    change_log VARCHAR(255) NULL,
    serial_number NVARCHAR(50) NOT NULL,
    vendor_id NVARCHAR(25) NOT NULL,
    cabinet_id NVARCHAR(25) NOT NULL,
    cabinet_type NVARCHAR(25) NULL,
    class NVARCHAR(10) NOT NULL,
    machine_type NVARCHAR(25) NOT NULL,
    logic_box NVARCHAR(50) NULL,
    machine_cost DECIMAL(7,2) NULL,
    date_received DATE NULL,
    agreement_order NVARCHAR(50) NULL,
    agreement_date DATE NULL,
    invoice_number NVARCHAR(50) NULL,
    invoice_date DATE NULL,
    performance_warranty_period INT NULL,
    performance_warranty_active NVARCHAR(25),
    performance_warranty_end DATE NULL,
    part_warranty_period INT NULL,
    part_warranty_active NVARCHAR(25),
    part_warranty_end DATE NULL,
    sales_order NVARCHAR(50) NULL
)


USE inventory
GO
CREATE TRIGGER [trg_insert_asset]
ON assets
AFTER INSERT
AS
BEGIN
    -- Generate UUID for rows where it is NULL
    UPDATE ass
    SET ass.uuid = NEWID()
    FROM assets ass
    INNER JOIN inserted i ON ass.index_key = i.index_key
    WHERE ass.uuid IS NULL;

    -- Populate reference_key and change_log for newly inserted rows
    UPDATE ass
    SET
        ass.reference_key = 'A-' + RIGHT('0000000' + CAST(ass.index_key AS VARCHAR), 5),
        ass.change_log = 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)
    FROM assets ass
    INNER JOIN inserted i ON ass.index_key = i.index_key;

    -- Log the initial values into activity_logs
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name)
    SELECT 
        i.uuid AS log_id, -- Use the UUID column
        JSON_QUERY((SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS change_log,
        COALESCE(i.update_by, 'System') AS update_by, -- Fallback to 'System' if update_by is NULL
        'assets' AS table_name -- Hardcode the table name
    FROM inserted i
    WHERE i.uuid IS NOT NULL; -- Ensure UUID is not NULL
END
GO


USE inventory
GO
CREATE TRIGGER [dbo].[trg_update_asset]
ON assets
AFTER UPDATE
AS
BEGIN
    -- Step 1: Update the `update_date` for all updated rows
    UPDATE ass
    SET ass.update_date = GETDATE()
    FROM assets ass
    INNER JOIN inserted i ON ass.uuid = i.uuid;

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
        'assets' AS table_name, -- Hardcode the table name
        GETDATE() AS timestamp -- Add the current timestamp
    FROM inserted i
    INNER JOIN deleted d ON i.uuid = d.uuid; -- Match updated rows

    -- Step 3: Update the `change_log` in `assets` with the most recent log reference
    UPDATE ass
    SET ass.change_log = 'Updated on ' + CONVERT(NVARCHAR, GETDATE(), 120) + ' Log key: (' + al.reference_key + ')'
    FROM assets ass
    INNER JOIN inserted i ON ass.uuid = i.uuid
    INNER JOIN (
        SELECT log_id, reference_key, ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY timestamp DESC) AS row_num
        FROM logs.dbo.activity_logs
    ) al ON al.log_id = i.uuid AND al.row_num = 1; -- Use the most recent log entry
END
GO
