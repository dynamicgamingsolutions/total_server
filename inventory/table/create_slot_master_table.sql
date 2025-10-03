USE inventory
GO

CREATE TABLE slot_master_update(
    uuid UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    index_key INT IDENTITY(1,1) NOT NULL,
    reference_key NVARCHAR(25) NULL,
    insert_date DATETIME NULL DEFAULT GETDATE(),
    update_date DATETIME NULL DEFAULT GETDATE(),
    update_by VARCHAR(50) NULL,
    change_log VARCHAR(255) NULL,
    casino_id NVARCHAR(25) NOT NULL,
    asset_id NVARCHAR(25) NOT NULL,
    theme_id NVARCHAR(25) NOT NULL,
    zone NVARCHAR(10) NULL,
    bank NVARCHAR(10) NULL,
    location NVARCHAR(10) NULL,
    asset_number NVARCHAR(25) NULL,
    denom NVARCHAR(50) NULL,
    os_version NVARCHAR(100) NULL,
    rtp DECIMAL(4,2) NULL,
    hold DECIMAL(4,2) NULL,
    prog_media NVARCHAR(100) NULL,
    paytable NVARCHAR(100) NULL,
    date_instl DATE NULL,
    golive DATE NULL,
    lastconver DATE NULL,
    rmvl_date DATE NULL,
    prog_type NVARCHAR(25) NULL,
    prog_level INT NULL,
    reset_1 DECIMAL(10,2) NULL,
    reset_2 DECIMAL(10,2) NULL,
    reset_3 DECIMAL(10,2) NULL,
    reset_4 DECIMAL(10,2) NULL,
    reset_5 DECIMAL(10,2) NULL,
    reset_6 DECIMAL(10,2) NULL,
    reset_7 DECIMAL(10,2) NULL,
    reset_8 DECIMAL(10,2) NULL,
    prog_1 DECIMAL(4,2) NULL,
    prog_2 DECIMAL(4,2) NULL,
    prog_3 DECIMAL(4,2) NULL,
    prog_4 DECIMAL(4,2) NULL,
    prog_5 DECIMAL(4,2) NULL,
    prog_6 DECIMAL(4,2) NULL,
    prog_7 DECIMAL(4,2) NULL,
    prog_8 DECIMAL(4,2) NULL,
    top_award NVARCHAR(25) NULL,
    reels NVARCHAR(25) NULL,
    no_lines NVARCHAR(25) NULL,
    bet_line NVARCHAR(100) NULL,
    maxcoinbet NVARCHAR(50) NULL,
    betconfig NVARCHAR(100) NULL,
    butt_panel NVARCHAR(50) NULL,
    top_boxtyp NVARCHAR(50) NULL,
    boot_bios NVARCHAR(50) NULL,
    print_id NVARCHAR(25) NULL,
    print_soft NVARCHAR(50) NULL,
    bill_validator_id NVARCHAR(25) NULL,
    billvalsft NVARCHAR(255) NULL,
    mon_type NVARCHAR(50) NULL,
    toppertype NVARCHAR(50) NULL,
    active NVARCHAR(25) NULL
)

USE inventory
GO
CREATE TRIGGER [trg_insert_sm_row]
ON slot_master_update
AFTER INSERT
AS
BEGIN
    -- Populate reference_key and change_log for newly inserted rows
    UPDATE sm
    SET
        sm.reference_key = 'SM-' + RIGHT('000000000' + CAST(sm.index_key AS VARCHAR), 9),
        sm.change_log = 'Created on ' + CONVERT(NVARCHAR, GETDATE(), 120)
    FROM slot_master_update sm
    INNER JOIN inserted i ON sm.index_key = i.index_key;

    -- Log the initial values into activity_logs
    INSERT INTO logs.dbo.activity_logs (log_id, change_log, update_by, table_name)
    SELECT 
        i.uuid AS log_id, -- Use the UUID column
        JSON_QUERY((SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)) AS change_log,
        COALESCE(i.update_by, 'System') AS update_by, -- Fallback to 'System' if update_by is NULL
        'slot_master_update' AS table_name -- Hardcode the table name
    FROM inserted i
    WHERE i.uuid IS NOT NULL; -- Ensure UUID is not NULL
END
GO


USE inventory
GO
CREATE TRIGGER [dbo].[trg_update_sm_row]
ON slot_master_update
AFTER UPDATE
AS
BEGIN
    -- Step 1: Update the `update_date` for all updated rows
    UPDATE sm
    SET sm.update_date = GETDATE()
    FROM slot_master_update sm
    INNER JOIN inserted i ON sm.uuid = i.uuid;

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
        'slot_master_update' AS table_name, -- Hardcode the table name
        GETDATE() AS timestamp -- Add the current timestamp
    FROM inserted i
    INNER JOIN deleted d ON i.uuid = d.uuid; -- Match updated rows

    -- Step 3: Update the `change_log` in `slot_master_update` with the most recent log reference
    UPDATE sm
    SET sm.change_log = 'Updated on ' + CONVERT(NVARCHAR, GETDATE(), 120) + ' Log key: (' + al.reference_key + ')'
    FROM slot_master_update sm
    INNER JOIN inserted i ON sm.uuid = i.uuid
    INNER JOIN (
        SELECT log_id, reference_key, ROW_NUMBER() OVER (PARTITION BY log_id ORDER BY timestamp DESC) AS row_num
        FROM logs.dbo.activity_logs
    ) al ON al.log_id = i.uuid AND al.row_num = 1; -- Use the most recent log entry
END
GO
