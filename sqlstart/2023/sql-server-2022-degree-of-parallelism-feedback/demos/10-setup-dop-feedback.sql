------------------------------------------------------------------------
-- Event:    SQL Start 2023, June 16                                  --
--           https://www.sqlstart.it/2023/Speakers/Sergio-Govoni      --
--                                                                    --
-- Session:  SQL Server 2022 Degree of Parallelism Feedback           --
-- Demo:     Test environment setup                                   --
-- Author:   Sergio Govoni                                            --
-- Notes:    --                                                       --
------------------------------------------------------------------------

-- The test environment is based on Bob Ward demo test environment
-- https://github.com/segovoni/bobsql/tree/master/demos/sqlserver2022/IQP/dopfeedback


USE [master];
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'max degree of parallelism', 0;
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'cost threshold for parallelism', 5;
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE WITH OVERRIDE;
GO

-- Restore database
-- Full backup of WideWorldImporters
-- https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

IF (DB_ID('WideWorldImporters') IS NOT NULL)
BEGIN
  ALTER DATABASE [WideWorldImporters]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [WideWorldImporters];
END;
GO

RESTORE DATABASE [WideWorldImporters]
  FROM DISK = 'C:\SQL\DBs\Backup\WideWorldImporters-Full.bak'
  WITH
    MOVE 'WWI_Primary' TO 'C:\SQL\DBs\WideWorldImporters.mdf',
    MOVE 'WWI_UserData' TO 'C:\SQL\DBs\WideWorldImporters_UserData.ndf',
    MOVE 'WWI_Log' TO 'C:\SQL\DBs\WideWorldImporters.ldf',
    MOVE 'WWI_InMemory_Data_1' TO 'C:\SQL\DBs\WideWorldImporters_InMemory_Data_1',
    STATS=5;
GO

ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 160;


-- Populate data
-- https://github.com/segovoni/bobsql/blob/master/demos/sqlserver2022/IQP/dopfeedback/populatedata.sql

USE [WideWorldImporters];
GO

-- Add StockItems to cause a data skew in Suppliers
DECLARE @StockItemID INT
DECLARE @StockItemName VARCHAR(100)
DECLARE @SupplierID INT
SELECT @StockItemID = 228
SET @StockItemName = 'Dallas Cowboys Shirt'+CONVERT(VARCHAR(10), @StockItemID)
SET @SupplierID = 4
DELETE FROM Warehouse.StockItems WHERE StockItemID >= @StockItemID
SET NOCOUNT ON
BEGIN TRANSACTION
WHILE @StockItemID <= 20000000
BEGIN
  INSERT INTO Warehouse.StockItems
  (
    StockItemID, StockItemName, SupplierID, UnitPackageID, OuterPackageID, LeadTimeDays,
    QuantityPerOuter, IsChillerStock, TaxRate, UnitPrice, TypicalWeightPerUnit, LastEditedBy
  )
  VALUES (@StockItemID, @StockItemName, @SupplierID, 10, 9, 12, 100, 0, 15.00, 100.00, 0.300, 1)
  SET @StockItemID = @StockItemID + 1
  SET @StockItemName = 'Dallas Cowboys Shirt'+convert(varchar(10), @StockItemID)
END
COMMIT TRANSACTION
SET NOCOUNT OFF
GO


-- Enables query store and set runtime collection lower than default
-- https://github.com/segovoni/bobsql/blob/master/demos/sqlserver2022/IQP/dopfeedback/dopfeedback.sql
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options

USE [WideWorldImporters];
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON
(
  -- Describes the operation mode of the query store
  OPERATION_MODE = READ_WRITE

  -- Determines the frequency at which data written to the query store
  -- is persisted to disk
  ,DATA_FLUSH_INTERVAL_SECONDS = 60

  -- Set the time interval at which runtime execution statistics data
  -- is aggregated into the Query Store
  ,INTERVAL_LENGTH_MINUTES = 1

  ,QUERY_CAPTURE_MODE = ALL
);
GO
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR ALL;
GO
ALTER DATABASE SCOPED CONFIGURATION SET DOP_FEEDBACK = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO


-- Create stored procedure Warehouse.GetStockItemsbySupplier
-- https://github.com/segovoni/bobsql/blob/master/demos/sqlserver2022/IQP/dopfeedback/proc.sql

 USE [WideWorldImporters];
 GO

 CREATE OR ALTER PROCEDURE [Warehouse].[GetStockItemsbySupplier] @SupplierID INT
 AS
 BEGIN
   SELECT StockItemID, SupplierID, StockItemName, TaxRate, LeadTimeDays
   FROM Warehouse.StockItems s
   WHERE SupplierID = @SupplierID
   ORDER BY StockItemName
 END;
 GO


-- Create and start an Extended Events (XE) session to monitor the DOP feature
-- https://github.com/segovoni/bobsql/blob/master/demos/sqlserver2022/IQP/dopfeedback/dopxe.sql

USE [master];
GO

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'DOPFeedback')
  DROP EVENT SESSION [DOPFeedback] ON SERVER;
GO

CREATE EVENT SESSION [DOPFeedback] ON SERVER 
  ADD EVENT sqlserver.dop_feedback_eligible_query(
      ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
  ADD EVENT sqlserver.dop_feedback_provided(
      ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
  ADD EVENT sqlserver.dop_feedback_reverted(
      ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
  ADD EVENT sqlserver.dop_feedback_stabilized(
      ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text)),
  ADD EVENT sqlserver.dop_feedback_validation(
      ACTION(sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  WITH
    (
	  MAX_MEMORY=4096 KB
	  ,EVENT_RETENTION_MODE=NO_EVENT_LOSS
	  ,MAX_DISPATCH_LATENCY=1 SECONDS
	  ,MAX_EVENT_SIZE=0 KB
	  ,MEMORY_PARTITION_MODE=NONE
	  ,TRACK_CAUSALITY=OFF
	  ,STARTUP_STATE=OFF
	);
GO

-- Start XE session
ALTER EVENT SESSION [DOPFeedback] ON SERVER
  STATE = START;
GO