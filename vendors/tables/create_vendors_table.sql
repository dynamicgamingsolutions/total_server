USE vendors --Use vendors database
GO

-- Create the table with `uuid` allowing NULL
CREATE TABLE vendors (
    uuid UNIQUEIDENTIFIER NULL DEFAULT NEWID(), -- Allow NULL and auto-generate UUID not if provided
    index_key INT IDENTITY(1,1) NOT NULL, -- Auto-incrementing identity column
    reference_key NVARCHAR(25) NULL,
    insert_date DATETIME NULL DEFAULT GETDATE(),
    update_date DATETIME NULL DEFAULT GETDATE(),
    update_by VARCHAR(50) NULL,
    change_log VARCHAR(255) NULL,
    vendor_name NVARCHAR(100) NOT NULL
)

USE vendors
GO

-- Alter the trigger for inserting into vendors
CREATE TRIGGER [trg_insert_vendor]
ON vendors
AFTER INSERT
AS
BEGIN
    -- Generate UUID for rows where it is NULL
    UPDATE ven
    SET ven.uuid = NEWID()
    FROM vendors ven
    INNER JOIN inserted i ON ven.index_key = i.index_key
    WHERE ven.uuid IS NULL;

    -- Populate reference_key and change_log for newly inserted rows
    UPDATE ven
    SET
        ven.reference_key = 'VT-' + RIGHT('000' + CAST(ven.index_key AS VARCHAR), 3),
        ven.change_log = 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)
    FROM vendors ven
    INNER JOIN inserted i ON ven.index_key = i.index_key;

    -- Log the initial values into activity_logs
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name)
    SELECT 
        i.uuid AS log_id, -- Ensure UUID is not NULL
        JSON_QUERY((SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS change_log,
        i.update_by AS update_by, -- Pass through the updated_by column
        'vendors' AS table_name -- Hardcode the table name
    FROM inserted i
    WHERE i.uuid IS NOT NULL; -- Prevent NULL values for log_id
END
GO


USE vendors
GO
CREATE TRIGGER [dbo].[trg_update_vendor]
ON [dbo].[vendors]
AFTER UPDATE
AS
BEGIN
    -- Step 1: Update the `update_date` for all updated rows
    UPDATE ven
    SET ven.update_date = GETDATE()
    FROM vendors ven
    INNER JOIN inserted i ON ven.uuid = i.uuid;

    -- Step 2: Log the changes into `activity_logs`
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name, timestamp)
    SELECT 
        COALESCE(i.uuid, NEWID()) AS log_id, -- Ensure log_id is never NULL
        JSON_QUERY(( 
            SELECT 
                (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS before_values,
                (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS after_values
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS change_log, -- Log before and after values as JvenN
        i.update_by AS update_by, -- Pass through the updated_by column
        'vendors' AS table_name, -- Hardcode the table name
        GETDATE() AS timestamp -- Add the current timestamp
    FROM inserted i
    INNER JOIN deleted d ON i.uuid = d.uuid; -- Match updated rows

    -- Step 3: Update the `change_log` in `sales_order` with the most recent log reference
    UPDATE ven
    SET ven.change_log = 'Updated on ' + CONVERT(NVARCHAR, GETDATE(), 120) + ' Log key: (' + al.reference_key + ')'
    FROM vendors ven
    INNER JOIN inserted i ON ven.uuid = i.uuid
    INNER JOIN (
        SELECT log_id, reference_key, ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY timestamp DESC) AS row_num
        FROM logs.dbo.activity_logs
    ) al ON al.log_id = i.uuid AND al.row_num = 1; -- Use the most recent log entry
END
GO
