USE logs
GO
CREATE TABLE [dbo].[activity_logs](
    [uuid] [uniqueidentifier] DEFAULT NEWID() NOT NULL, -- Auto-generate UUID
    [index_key] [int] IDENTITY(1,1) NOT NULL,
    [reference_key] AS ('LT-' + RIGHT('0000000000' + CAST([index_key] AS NVARCHAR(9)), 9)), -- Computed column for reference_key
    [timestamp] [datetime2](7) DEFAULT GETDATE() NOT NULL, -- Compute insert_date on insert
    [update_by] [nvarchar](100) NOT NULL,
    [table_name] [nvarchar](50) NOT NULL,
    [log_id] [nvarchar](50) NOT NULL,
    [change_log] [nvarchar](MAX) NOT NULL
)
