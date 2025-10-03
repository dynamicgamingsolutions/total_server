USE vendors
GO

-- Create the table with `uuid` allowing NULL
CREATE TABLE player_tracking (
    uuid UNIQUEIDENTIFIER NULL DEFAULT NEWID(), -- Allow NULL and auto-generate UUID not if provided
    index_key INT IDENTITY(1,1) NOT NULL, -- Auto-incrementing identity column
    reference_key NVARCHAR(25) NULL,
    insert_date DATETIME NULL DEFAULT GETDATE(),
    update_date DATETIME NULL DEFAULT GETDATE(),
    update_by VARCHAR(50) NULL,
    change_log VARCHAR(255) NULL,
    player_ptacker NVARCHAR(100) NOT NULL
)

USE vendors
GO
CREATE TRIGGER [ptg_insert_ptacker]
ON player_tracking
AFTER INSERT
AS
BEGIN
    -- Generate UUID for rows where it is NULL
    UPDATE pt
    SET pt.uuid = NEWID()
    FROM player_tracking pt
    INNER JOIN inserted i ON pt.index_key = i.index_key
    WHERE pt.uuid IS NULL;

    -- Populate reference_key and change_log for newly inserted rows
    UPDATE pt
    SET
        pt.reference_key = 'PT-' + RIGHT('00000' + CAST(pt.index_key AS VARCHAR), 5),
        pt.change_log = 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)
    FROM player_tracking pt
    INNER JOIN inserted i ON pt.index_key = i.index_key;

    -- Log the initial values into activity_logs
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name)
    SELECT 
        i.uuid AS log_id, -- Use the UUID column
        JSON_QUERY((SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS change_log,
        i.update_by AS update_by, -- Pass through the updated_by column
        'player_ptacking' AS table_name -- Hardcode the table name
    FROM inserted i
    WHERE i.uuid IS NOT NULL; -- Ensure UUID is not NULL
END
GO

USE vendors
GO
CREATE TRIGGER [dbo].[ptg_update_ptacker]
ON [dbo].[player_tracking]
AFTER UPDATE
AS
BEGIN
    -- Step 1: Update the `update_date` for all updated rows
    UPDATE pt
    SET pt.update_date = GETDATE()
    FROM player_tracking pt
    INNER JOIN inserted i ON pt.uuid = i.uuid;

    -- Step 2: Log the changes into `activity_logs`
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name, timestamp)
    SELECT 
        COALESCE(i.uuid, NEWID()) AS log_id, -- Ensure log_id is never NULL
        JSON_QUERY(( 
            SELECT 
                (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS before_values,
                (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS after_values
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS change_log, -- Log before and after values as JptN
        i.update_by AS update_by, -- Pass through the updated_by column
        'player_ptacking' AS table_name, -- Hardcode the table name
        GETDATE() AS timestamp -- Add the current timestamp
    FROM inserted i
    INNER JOIN deleted d ON i.uuid = d.uuid; -- Match updated rows

    -- Step 3: Update the `change_log` in `sales_order` with the most recent log reference
    UPDATE pt
    SET pt.change_log = 'Updated on ' + CONVERT(NVARCHAR, GETDATE(), 120) + ' Log key: (' + al.reference_key + ')'
    FROM player_tracking pt
    INNER JOIN inserted i ON pt.uuid = i.uuid
    INNER JOIN (
        SELECT log_id, reference_key, ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY timestamp DESC) AS row_num
        FROM logs.dbo.activity_logs
    ) al ON al.log_id = i.uuid AND al.row_num = 1; -- Use the most recent log enpty
END
GO
