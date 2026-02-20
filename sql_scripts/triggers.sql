USE [OguzErenDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 1. YENİ SİPARİŞ EKLENDİĞİNDE ÇALIŞAN TETİKLEYİCİ (A)
CREATE TRIGGER [dbo].[trg_AfterInsertOrder]
ON [dbo].[Orders]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Orders_Log (operation_type, table_name, data_json, created_at, is_processed)
    SELECT 
        'INSERT', 
        'Orders', 
        (SELECT * FROM inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), 
        GETDATE(), 
        0
    FROM inserted;
END;
GO

ALTER TABLE [dbo].[Orders] ENABLE TRIGGER [trg_AfterInsertOrder]
GO


-- 2. SİPARİŞ SİLİNDİĞİNDE (DELETE) ÇALIŞAN TETİKLEYİCİ
CREATE TRIGGER [dbo].[trg_orders_delete]
ON [dbo].[Orders]
AFTER DELETE
AS
BEGIN
    DECLARE @json_data NVARCHAR(MAX);
    SELECT @json_data = (SELECT * FROM deleted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    INSERT INTO Orders_Log (operation_type, table_name, record_id, log_data)
    SELECT 'DELETE', 'Orders', order_id, @json_data FROM deleted;
END;
GO

ALTER TABLE [dbo].[Orders] ENABLE TRIGGER [trg_orders_delete]
GO


-- 3. YENİ SİPARİŞ EKLENDİĞİNDE ÇALIŞAN TETİKLEYİCİ (B)
CREATE TRIGGER [dbo].[trg_orders_insert]
ON [dbo].[Orders]
AFTER INSERT
AS
BEGIN
    DECLARE @json_data NVARCHAR(MAX);
    SELECT @json_data = (SELECT order_id, customer_id, product, amount, status FROM inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    INSERT INTO Orders_Log (operation_type, table_name, record_id, log_data)
    SELECT 'INSERT', 'Orders', order_id, @json_data FROM inserted;
END;
GO

ALTER TABLE [dbo].[Orders] ENABLE TRIGGER [trg_orders_insert]
GO


-- 4. SİPARİŞ GÜNCELLENDİĞİNDE (UPDATE) ÇALIŞAN TETİKLEYİCİ
CREATE TRIGGER [dbo].[trg_orders_update]
ON [dbo].[Orders]
AFTER UPDATE
AS
BEGIN
    DECLARE @json_data NVARCHAR(MAX);
    SELECT @json_data = (SELECT * FROM inserted FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
    INSERT INTO Orders_Log (operation_type, table_name, record_id, log_data)
    SELECT 'UPDATE', 'Orders', order_id, @json_data FROM inserted;
END;
GO

ALTER TABLE [dbo].[Orders] ENABLE TRIGGER [trg_orders_update]
GO