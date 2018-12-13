--------------------------------------------------------------------------
-- Event:        SQL Saturday #264 - Ancona
-- Session:      Trigger: Utili o Dannosi?
-- Demo:         Setup database
-- Author:       Sergio Govoni
-- Notes:        -
--------------------------------------------------------------------------

USE [master];
GO

--------------------------------------------------------------------------
-- Database snapshot
--------------------------------------------------------------------------

-- Drop database snapshot if it already exists
--IF EXISTS (SELECT name FROM sys.databases WHERE name = N'AdventureWorks2012_Snapshot')
--  DROP DATABASE AdventureWorks2012_Snapshot;
--GO

-- Create the database snapshot
--CREATE DATABASE AdventureWorks2012_Snapshot ON
--(
--  NAME = AdventureWorks2012_Data
--  ,FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\AdventureWorks2012_Snapshot.ss'
--)
--AS SNAPSHOT OF AdventureWorks2012;
--GO

IF (DB_ID('AdventureWorks2012') IS NOT NULL)
BEGIN
  ALTER DATABASE AdventureWorks2012
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  -- Reverting AdventureWorks from AdventureWorks2012_Snapshot
  RESTORE DATABASE AdventureWorks2012
    FROM DATABASE_SNAPSHOT = 'AdventureWorks2012_Snapshot';

  ALTER DATABASE AdventureWorks2012
    SET MULTI_USER;
END
GO

USE [AdventureWorks2012];
GO

--------------------------------------------------------------------------
-- Create tables
--------------------------------------------------------------------------

/*
IF OBJECT_ID('Sales.MyOrderDetail') IS NOT NULL
  DROP TABLE Sales.MyOrderDetail;
GO

IF OBJECT_ID('Sales.MyOrderHeader') IS NOT NULL
  DROP TABLE Sales.MyOrderHeader;
GO
*/

CREATE TABLE Sales.MyOrderHeader
(
  OrderNumber VARCHAR(20) NOT NULL
    PRIMARY KEY
  ,TotalDue NUMERIC(12, 2) NOT NULL
    DEFAULT (0)
);
GO

CREATE TABLE Sales.MyOrderDetail
(
  OrderNumber VARCHAR(20) NOT NULL
    CONSTRAINT FK_MyOrderHeader FOREIGN KEY REFERENCES Sales.MyOrderHeader(OrderNumber)
  ,OrderDate DATETIME NOT NULL DEFAULT GETDATE()
  ,ProductID INT NOT NULL DEFAULT(707)
    CONSTRAINT FK_Product FOREIGN KEY REFERENCES Production.Product(ProductID)
  ,RowTotal NUMERIC(12, 2) NOT NULL
  ,Qty INTEGER NOT NULL DEFAULT(1)
  ,UnitPrice AS (RowTotal/Qty)
  ,RowNumber VARCHAR(20) NOT NULL
  CONSTRAINT PK_OrderNumber_RowNumber PRIMARY KEY(OrderNumber, RowNumber)
);
GO

--------------------------------------------------------------------------
-- Drop check constraints
--------------------------------------------------------------------------

ALTER TABLE Production.Product DROP CONSTRAINT CK_Product_SafetyStockLevel;
GO

ALTER TABLE Production.Product DROP CONSTRAINT CK_Product_ListPrice;
GO

--------------------------------------------------------------------------
-- Create triggers
--------------------------------------------------------------------------

CREATE TRIGGER Sales.TR_SalesOrderHeader_Update ON Sales.SalesOrderHeader
AFTER UPDATE AS 
BEGIN
  DECLARE @Count INT;

  SET @Count = @@ROWCOUNT;
  IF (@Count = 0)
    RETURN;

  SET NOCOUNT ON;

  PRINT('UPDATE: Message from Trigger TR_SalesOrderHeader_Update');
END;
GO

CREATE TRIGGER Sales.TR_SalesOrderHeader_Update1 ON Sales.SalesOrderHeader
AFTER UPDATE AS 
BEGIN
  DECLARE @Count INT;

  SET @Count = @@ROWCOUNT;
  IF (@Count = 0)
    RETURN;

  SET NOCOUNT ON;

  PRINT('UPDATE: Message from Trigger TR_SalesOrderHeader_Update1');
END;
GO

CREATE TRIGGER Sales.TR_SalesOrderHeader_Update2 ON Sales.SalesOrderHeader
AFTER UPDATE AS 
BEGIN
  DECLARE @Count INT;

  SET @Count = @@ROWCOUNT;
  IF (@Count = 0)
    RETURN;

  SET NOCOUNT ON;

  PRINT('UPDATE: Message from Trigger TR_SalesOrderHeader_Update2');
END;
GO

CREATE TRIGGER Sales.TR_SalesOrderHeader_Insert ON Sales.SalesOrderHeader
AFTER INSERT AS 
BEGIN
  DECLARE @Count INT;

  SET @Count = @@ROWCOUNT;
  IF (@Count = 0)
    RETURN;

  SET NOCOUNT ON;

  PRINT('INSERT: Message from Trigger TR_SalesOrderHeader_Insert');
END;
GO

CREATE TRIGGER Sales.TR_SalesOrderHeader_Insert1 ON Sales.SalesOrderHeader
AFTER INSERT AS 
BEGIN
  DECLARE @Count INT;

  SET @Count = @@ROWCOUNT;
  IF (@Count = 0)
    RETURN;

  SET NOCOUNT ON;

  PRINT('INSERT: Message from Trigger TR_SalesOrderHeader_Insert1');
END;
GO

CREATE TRIGGER Sales.TR_SalesOrderHeader_UpdDel ON Sales.SalesOrderHeader
AFTER DELETE, UPDATE AS 
BEGIN
  DECLARE @Count INT;

  SET @Count = @@ROWCOUNT;
  IF (@Count = 0)
    RETURN;

  SET NOCOUNT ON;

  PRINT('DELETE/UPDATE: Message from Trigger TR_SalesOrderHeader_UpdDel');
END;
GO

CREATE TRIGGER Sales.TR_SalesOrderHeader_Disable ON Sales.SalesOrderHeader
AFTER DELETE AS 
BEGIN
  DECLARE @Count INT;

  SET @Count = @@ROWCOUNT;
  IF (@Count = 0)
    RETURN;

  SET NOCOUNT ON;

  PRINT('DELETE: Message from Trigger TR_SalesOrderHeader_Disable');
END;
GO
ALTER TABLE Sales.SalesOrderHeader DISABLE TRIGGER TR_SalesOrderHeader_Disable;
GO

--------------------------------------------------------------------------
-- Disable trigger
--------------------------------------------------------------------------

ALTER TABLE Production.WorkOrder DISABLE TRIGGER iWorkOrder;
GO

ALTER TABLE Production.WorkOrder DISABLE TRIGGER uWorkOrder;
GO

ALTER TABLE Sales.SalesOrderDetail DISABLE TRIGGER iduSalesOrderDetail;
GO

--------------------------------------------------------------------------
-- Insert in Sales.SalesOrderDetail
--------------------------------------------------------------------------

INSERT INTO Sales.SalesOrderDetail
(
  SalesOrderID
  ,CarrierTrackingNumber
  ,OrderQty
  ,ProductID
  ,SpecialOfferID
  ,UnitPrice
  ,UnitPriceDiscount
  ,rowguid
  ,ModifiedDate
)
VALUES
(
  75123, NULL, 1, 707/*ProductID*/, 1, 8.9900/*UnitPrice*/,
  0.0000, NEWID(), GETDATE()
);
GO