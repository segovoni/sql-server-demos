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

USE [master];
GO

-- Full backup of AdventureWorks2017
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks

-- Full backup of WideWorldImporters and WideWorldImportersDW sample database
-- is available on GitHub
-- https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0

-- Documentation about WideWorldImporters sample database for SQL Server
-- and Azure SQL Database
-- https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers

-- Run "Thinking Big (Adventure)" script by Adam Machanicon on AdventureWorks
-- http://dataeducation.com/thinking-big-adventure/


USE [master];
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO

-- Drop Database
IF (DB_ID('AdventureWorks2017') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorks2017]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorks2017];
END;
GO

RESTORE DATABASE [AdventureWorks2017]
  FROM DISK = N'C:\SQL\DBs\Backup\AdventureWorks2017.bak'
  WITH
    FILE = 1
    ,MOVE N'AdventureWorks2017' TO N'C:\SQL\DBs\AdventureWorks2017.mdf'
    ,MOVE N'AdventureWorks2017_log' TO N'C:\SQL\DBs\AdventureWorks2017_log.ldf'
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


USE [AdventureWorks2017];
GO

-- Disabling batch mode on rowstore
ALTER DATABASE SCOPED CONFIGURATION SET BATCH_MODE_ON_ROWSTORE = OFF;
GO