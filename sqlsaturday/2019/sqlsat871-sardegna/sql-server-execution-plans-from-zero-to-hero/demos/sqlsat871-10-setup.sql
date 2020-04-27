------------------------------------------------------------------------
-- Event:        SQL Saturday #871 Sardegna 2019, May 18               -
-- Session:      SQL Server Execution Plans: From Zero to Hero         -
-- https://www.sqlsaturday.com/871/Sessions/Details.aspx?sid=91267     -
-- Demo:         Setup database                                        -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

-- Full backup di AdventureWorks2017 database di esempio
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks


USE [master];
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

USE [AdventureWorks2017];
GO

-- Stored procedures

-- dbo.usp_PO_Extra_Received
CREATE OR ALTER PROCEDURE dbo.usp_PO_Extra_Received
AS
BEGIN
  SELECT
    *
  FROM
    Purchasing.PurchaseOrderDetail AS pod
  WHERE
    (pod.ReceivedQty >= pod.OrderQty)
  ORDER BY
    pod.RejectedQty DESC;
END;
GO

-- dbo.usp_StateProvinceByTerritory
CREATE OR ALTER PROCEDURE dbo.usp_StateProvinceByTerritory
(
  @TerritoryName NVARCHAR(50)
)
AS
BEGIN
  SELECT
    p.StateProvinceID
	,p.Name
	,p.StateProvinceCode
	,p.CountryRegionCode
	,t.*
  FROM
    [Person].[StateProvince] AS p
  JOIN
    [Sales].[SalesTerritory] AS t
    ON p.TerritoryID = t.TerritoryID
  WHERE
    (t.Name = @TerritoryName)
  --OPTION (OPTIMIZE FOR (@TerritoryName UNKNOWN))
  --OPTION (OPTIMIZE FOR (@TerritoryName='Italy'))
END;
GO


-- dbo.myOrderHeader
IF OBJECT_ID('myOrderHeader', 'U') IS NOT NULL
  DROP TABLE dbo.myOrderHeader;
GO

CREATE TABLE dbo.myOrderHeader
(
 OrderID INT IDENTITY(1, 1) NOT NULL
 ,OrderDate DATETIME DEFAULT GETDATE() NOT NULL
 --,OrderNumber AS (ISNULL(N'SO' + CONVERT([nvarchar](23), [orderid], 0), N'*** ERROR ***'))
 ,CustomerID INT DEFAULT 1 NOT NULL
 ,ShipName VARCHAR(20) DEFAULT 'name'
 ,ShipAddress VARCHAR(40) DEFAULT 'address'
 ,ShipVia VARCHAR(40) DEFAULT 'via'
 ,ShipCity VARCHAR(20) DEFAULT 'city'
 ,ShipRegion VARCHAR(20) DEFAULT 'region'
 ,ShipPostalCode VARCHAR(20) DEFAULT 'postal code'
 ,ShipCountry VARCHAR(20) DEFAULT 'country'
 ,DeliveryDate DATETIME DEFAULT (GETDATE() + DATEPART(SS, GETDATE())) NOT NULL
 ,DeliveryNote VARCHAR(40)
);
GO

/*
SELECT * FROM dbo.myOrderHeader;
GO
*/

SET NOCOUNT ON;
GO

INSERT INTO dbo.myOrderHeader DEFAULT VALUES
GO 1000

SET NOCOUNT OFF;
GO

/*
DROP INDEX dbo.myOrderHeader.FIDX_myOrderHeader
*/

CREATE NONCLUSTERED INDEX FIDX_myOrderHeader on dbo.myOrderHeader
(
  [DeliveryDate]
)
WHERE
  (DeliveryDate >= '20150128');
GO