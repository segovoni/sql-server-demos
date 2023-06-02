------------------------------------------------------------------------
-- Event:        Delphi Day 2023 - June 06-07                          -
--               https://www.delphiday.it/                             -
--                                                                     -
-- Session:      T-SQL performance tips & tricks!                      -
--                                                                     -
-- Demo:         Setup databases (reset DB)                            -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

-- Full backup of AdventureWorks2022
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks

-- Full backup of WideWorldImporters and WideWorldImportersDW sample database
-- is available on GitHub
-- https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0

-- Documentation about WideWorldImporters sample database for SQL Server
-- and Azure SQL Database
-- https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers

-- Run "Thinking Big (Adventure)" script by Adam Machanic on AdventureWorks
-- http://dataeducation.com/thinking-big-adventure/


USE [master];
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO

-- Drop Database
IF (DB_ID('AdventureWorks2022') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorks2022]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorks2022];
END;
GO

RESTORE DATABASE [AdventureWorks2022]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2022.bak'
  WITH
    FILE = 1
    ,MOVE N'AdventureWorks2022' TO N'C:\SQL\DBs\AdventureWorks2022.mdf'
    ,MOVE N'AdventureWorks2022_log' TO N'C:\SQL\DBs\AdventureWorks2022_log.ldf'
    ,NOUNLOAD
    ,STATS = 5;
GO

-- Drop database WideWorldImporters
IF (DB_ID('WideWorldImporters') IS NOT NULL)
BEGIN
  ALTER DATABASE [WideWorldImporters]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [WideWorldImporters];
END;
GO

-- Restore database WideWorldImporters
RESTORE DATABASE [WideWorldImporters]
  FROM DISK = N'C:\SQL\DBs\Backup\WideWorldImporters-Full.bak' WITH FILE = 1
  ,MOVE N'WWI_Primary' TO N'C:\SQL\DBs\WideWorldImporters.mdf'
  ,MOVE N'WWI_UserData' TO N'C:\SQL\DBs\WideWorldImporters_UserData.ndf'
  ,MOVE N'WWI_Log' TO N'C:\SQL\DBs\WideWorldImporters.ldf'
  ,MOVE N'WWI_InMemory_Data_1' TO N'C:\SQL\DBs\WideWorldImporters_InMemory_Data_1'
  ,NOUNLOAD
  ,STATS = 5;
GO

-- Drop database TestLatchDB 
IF (DB_ID('TestLatchDB') IS NOT NULL)
BEGIN
  ALTER DATABASE [TestLatchDB]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [TestLatchDB];
END;
GO

-- Create database TestLatchDB
CREATE DATABASE [TestLatchDB]
  ON PRIMARY
  (
    NAME = TestLatchDB
    ,FILENAME = 'C:\SQL\DBs\TestLatchDB_Data.mdf'
  )
  LOG ON
  (
    NAME = TestLatchDB_Log
    ,FILENAME = 'C:\SQL\DBs\TestLatchDB_Log.ldf'
  );
GO


USE [WideWorldImporters];
GO

--ALTER TABLE Warehouse.Colors WITH CHECK
--  ADD CONSTRAINT CK_Warehouse_Colors_ColorName_Gray
--  CHECK (ColorName <> 'Gray');
--GO

------------------------------------------------------------------------
-- SARGable predicates demos                                           -
------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Sales_Orders_PickingCompletedWhen
  ON Sales.Orders
(
  PickingCompletedWhen
);
GO

UPDATE
  Purchasing.PurchaseOrders
SET
  ExpectedDeliveryDate = NULL
WHERE
  (ExpectedDeliveryDate BETWEEN '20160101' AND '20161231');
GO

CREATE INDEX IX_Purchasing_PurchaseOrders_ExpectedDeliveryDate
  ON Purchasing.PurchaseOrders
(
  ExpectedDeliveryDate
);
GO

CREATE INDEX IX_Warehouse_StockItems_ValidFrom
  ON Warehouse.StockItems
(
  ValidFrom
);
GO

------------------------------------------------------------------------
-- Join strategies demos                                               -
------------------------------------------------------------------------
INSERT INTO [Sales].[Customers]
(
  [CustomerName]
  ,[BillToCustomerID]
  ,[CustomerCategoryID]
  ,[BuyingGroupID]
  ,[PrimaryContactPersonID]
  ,[AlternateContactPersonID]
  ,[DeliveryMethodID]
  ,[DeliveryCityID]
  ,[PostalCityID]
  ,[CreditLimit]
  ,[AccountOpenedDate]
  ,[StandardDiscountPercentage]
  ,[IsStatementSent]
  ,[IsOnCreditHold]
  ,[PaymentDays]
  ,[PhoneNumber]
  ,[FaxNumber]
  ,[DeliveryRun]
  ,[RunPosition]
  ,[WebsiteURL]
  ,[DeliveryAddressLine1]
  ,[DeliveryAddressLine2]
  ,[DeliveryPostalCode]
  ,[DeliveryLocation]
  ,[PostalAddressLine1]
  ,[PostalAddressLine2]
  ,[PostalPostalCode]
  ,[LastEditedBy]
)
SELECT      
  'Customer #' + TRIM(STR(CustomerID)),
  BillToCustomerID,
  CustomerCategoryID,
  BuyingGroupID,
  PrimaryContactPersonID,
  AlternateContactPersonID,
  DeliveryMethodID,
  DeliveryCityID,
  PostalCityID,
  CreditLimit,
  AccountOpenedDate,
  StandardDiscountPercentage,
  IsStatementSent,
  IsOnCreditHold,
  PaymentDays,
  PhoneNumber,
  FaxNumber,
  DeliveryRun,
  RunPosition,
  WebsiteURL,
  DeliveryAddressLine1,
  DeliveryAddressLine2,
  DeliveryPostalCode,
  DeliveryLocation,
  PostalAddressLine1,
  PostalAddressLine2,
  PostalPostalCode,
  LastEditedBy
FROM Sales.Customers
WHERE (CustomerID IN (1, 2, 3, 4, 5));
GO

USE [AdventureWorks2022];
GO

-- COMPATIBILITY_LEVEL { 150 | 140 | 130 | 120 | 110 | 100 | 90 | 80 }
-- 130 for SQL Server 2016
-- 140 for SQL Server 2017
-- 150 for SQL Server 2019
ALTER DATABASE [AdventureWorks2022] SET COMPATIBILITY_LEVEL = 140;
GO

-- Disabling batch mode on rowstore
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF;
GO


USE [TestLatchDB];
GO

-- Create stored procedure dbo.usp_stress_tempdb
CREATE OR ALTER PROCEDURE dbo.usp_stress_tempdb
AS
BEGIN
  -- Create temporary table
  CREATE TABLE dbo.#TempTable
  (
    Col1 INTEGER IDENTITY(1, 1) NOT NULL
	,Col2 CHAR(4000)
	,Col3 CHAR(4000)
  );

  -- Create unique clustered index
  CREATE UNIQUE CLUSTERED INDEX uq_clidx_temptable_col1 ON dbo.#TempTable
  (
    [Col1]
  );

  -- Insert 10 records into the temporary table
  DECLARE
    @i INTEGER = 0;
  WHILE
    (@i < 10)
  BEGIN
    INSERT INTO dbo.#TempTable VALUES ('Delphi Day 2023', '#DelphiDay23');
	SET @i = (@i + 1);
  END;
END;
GO


-- Create the loop stored procedure
CREATE OR ALTER PROCEDURE dbo.usp_loop_stress_tempdb
AS
BEGIN
  DECLARE
    @j INTEGER = 0;
  WHILE
    (@j < 100)
  BEGIN
    EXECUTE dbo.usp_stress_tempdb;
	SET @j = (@j + 1);
  END;
END;
GO