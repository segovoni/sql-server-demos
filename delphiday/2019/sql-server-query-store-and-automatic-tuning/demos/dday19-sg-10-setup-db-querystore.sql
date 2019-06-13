------------------------------------------------------------------------
-- Event:        Delphi Day 2019, Piacenza, June 6 2019               --
--               https://www.delphiday.it/                            --
-- Session:      SQL Server Query Store e Automatic Tuning            --
-- Demo:         Setup [QueryStore] DB                                --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [master];
GO

-- Drop database QueryStore
IF (DB_ID('QueryStore') IS NOT NULL)
BEGIN
  ALTER DATABASE [QueryStore]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [QueryStore];
END;
GO


-- Create database QueryStore
CREATE DATABASE [QueryStore]
  ON PRIMARY 
  (
    NAME = N'QueryStore'
	,FILENAME = N'C:\SQL\DBs\QueryStore.mdf'
  )
  LOG ON 
  (
    NAME = N'QueryStorelog'
	,FILENAME = N'C:\SQL\DBs\QueryStoreLog.ldf'
  );
GO


-- Set recovery model to SIMPLE
ALTER DATABASE [QueryStore] SET RECOVERY SIMPLE;
GO


USE [QueryStore];
GO

-- dbo.Tab_A
DROP TABLE IF EXISTS dbo.Tab_A;
GO

-- Create sample table
CREATE TABLE dbo.Tab_A
(
  Col1 INTEGER
  ,Col2 INTEGER
  ,Col3 BINARY(2000)
);
GO


-- Insert some data into the sample table
SET NOCOUNT ON;

BEGIN
  BEGIN TRANSACTION

  DECLARE @i INTEGER = 0;

  WHILE (@i < 10000)
  BEGIN
    INSERT INTO dbo.Tab_A (Col1, Col2) VALUES (@i, @i);
	SET @i+=1
  END

  COMMIT TRANSACTION
END;
GO


-- There are much more rows with value 1 than rows with other values
INSERT INTO dbo.Tab_A (Col1, Col2) VALUES (1, 1)
GO 100000


SET NOCOUNT OFF;
GO


-- Create indexes
CREATE INDEX IDX_Tab_A_Col1 ON dbo.Tab_A
(
  [Col1]
);
GO


CREATE INDEX IDX_Tab_A_Col2 ON dbo.Tab_A
(
  [Col2]
);
GO


-- dbo.OrderDetail
DROP TABLE IF EXISTS dbo.OrderDetail;
GO

CREATE TABLE dbo.OrderDetail
(
  OrderDetailID INT IDENTITY(1, 1) NOT NULL
  ,OrderHeaderID INT NOT NULL
  ,ProductID INT NOT NULL
  ,RigNumber AS (OrderDetailID * 2)
  ,UnitPrice MONEY DEFAULT 0 NOT NULL
  PRIMARY KEY(OrderDetailID)
);
GO

-- dbo.OrderHeader
DROP TABLE IF EXISTS dbo.OrderHeader;
GO

CREATE TABLE dbo.OrderHeader
(
  OrderID INT IDENTITY(1, 1) NOT NULL
  ,OrderDATE DATETIME DEFAULT GETDATE() NOT NULL
  ,OrderNUMBER AS (ISNULL(N'SO' + CONVERT([nvarchar](23), [OrderID], 0), N'*** ERROR ***'))
  ,CustomerID INT DEFAULT 1 NOT NULL
  ,ShipName VARCHAR(20) DEFAULT 'Name'
  ,ShipAddress VARCHAR(40) DEFAULT 'Address'
  ,ShipVia VARCHAR(40) DEFAULT 'Via'
  ,ShipCity VARCHAR(20) DEFAULT 'City'
  ,ShipRegion VARCHAR(20) DEFAULT 'Region'
  ,ShipPostalCode VARCHAR(20) DEFAULT 'Postal code'
  ,ShipCountry VARCHAR(20) DEFAULT 'Country'
  PRIMARY KEY(OrderID)
);
GO

ALTER TABLE dbo.OrderDetail WITH CHECK
  ADD CONSTRAINT FK_OrderHeaderID FOREIGN KEY (OrderHeaderID) REFERENCES dbo.OrderHeader (OrderID);
GO

CREATE NONCLUSTERED INDEX IDX_OrderHeader_CustomerID ON dbo.OrderHeader
(
  CustomerID ASC
);
GO

DECLARE @i AS INTEGER = 0;
-- 219131
WHILE (@i < 250000)
BEGIN
  SET NOCOUNT ON;

  -- Insert dbo.OrderHeader
  INSERT INTO dbo.OrderHeader DEFAULT VALUES;

  -- Insert OrderDetail
  INSERT INTO dbo.OrderDetail
  (OrderHeaderID, ProductID, UnitPrice)
  SELECT (SELECT MAX(OrderID) FROM dbo.OrderHeader), (@i * 2)+1, ((@i * 2)+1)/2;

  SET @i = (@i + 1);

  SET NOCOUNT OFF;
END;
GO

-- Delete the detail for the order ID number 1100
DELETE FROM dbo.OrderDetail WHERE OrderHeaderID=1100;
GO