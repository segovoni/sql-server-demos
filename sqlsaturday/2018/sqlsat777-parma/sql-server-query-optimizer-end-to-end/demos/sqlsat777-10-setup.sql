------------------------------------------------------------------------
-- Event:        SQL Saturday #777 Parma, November 24, 2018            -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/777/Sessions/Details.aspx?sid=79997     -
-- Demo:         Setup on-prem                                         -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

-- Full backup of WideWorldImporters sample database is available on GitHub
-- https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0


-- Documentation about WideWorldImporters sample database for SQL Server
-- and Azure SQL Database
-- https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers


--Full backup of AdventureWorks2017 sample database is available on GitHub
-- https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks



USE [master];
GO

/*
EXEC sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO
*/


-- Drop Database
IF (DB_ID('WideWorldImporters') IS NOT NULL)
BEGIN
  ALTER DATABASE [WideWorldImporters]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [WideWorldImporters];
END;
GO

-- Restore DB
RESTORE DATABASE [WideWorldImporters]
  FROM  DISK = N'C:\SQL\DBs\Backup\WideWorldImporters-Full.bak' WITH  FILE = 1
  ,MOVE N'WWI_Primary' TO N'C:\SQL\DBs\WideWorldImporters.mdf'
  ,MOVE N'WWI_UserData' TO N'C:\SQL\DBs\WideWorldImporters_UserData.ndf'
  ,MOVE N'WWI_Log' TO N'C:\SQL\DBs\WideWorldImporters.ldf'
  ,MOVE N'WWI_InMemory_Data_1' TO N'C:\SQL\DBs\WideWorldImporters_InMemory_Data_1'
  ,NOUNLOAD
  ,STATS = 5;
GO


USE [WideWorldImporters];
GO

ALTER TABLE Warehouse.Colors WITH CHECK
  ADD CONSTRAINT CK_Warehouse_Colors_ColorName_Gray
  CHECK (ColorName <> 'Gray');
GO



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

/*
ALTER AUTHORIZATION ON DATABASE::AdventureWorks2017 TO [MARCONI\AdventureWorks2017]
GO
*/

USE [AdventureWorks2017];
GO

CREATE OR ALTER VIEW Production.vw_Get_BillOfMaterials_Tree
AS
-- BillOfMaterials not optimized
-- Level 0
SELECT
  NULL CodPadre
  ,NULL IDPadre
  ,P0.Name CodFiglio
  ,P0.ProductID IDFiglio
  ,CAST(CAST(LTRIM(RTRIM(STR(P0.ProductID))) AS VARCHAR(20)) AS VARCHAR(MAX)) as Path
  ,B0.BillOfMaterialsID
  ,0 AS Livello
FROM
  Production.BillOfMaterials B0
JOIN
  Production.Product P0 ON P0.ProductID=B0.ComponentID
WHERE
  -- Parent product identification number
  -- Foreign key to Product.ProductID
  (B0.ProductAssemblyID IS NULL)
  -- Input filter
  --AND (B0.ComponentID = @Input_Product)
  AND GETDATE() BETWEEN B0.StartDate AND ISNULL(B0.EndDate, '99991231')

UNION

-- Level 1
SELECT
  P0.Name CodPadre
  ,P0.ProductID IDPadre
  ,P1.Name CodFiglio
  ,P1.ProductID IDFiglio
  ,CAST(CAST(LTRIM(RTRIM(STR(P0.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P1.ProductID))) AS VARCHAR(20)) AS VARCHAR(MAX)) as Path
  ,B1.BillOfMaterialsID
  ,1 AS Livello
FROM
  Production.BillOfMaterials B0
JOIN
  Production.Product P0 ON P0.ProductID=B0.ComponentID
JOIN
  Production.BillOfMaterials B1 ON B1.ProductAssemblyID=B0.ComponentID
JOIN
  Production.Product P1 ON P1.ProductID=B1.ComponentID
WHERE
  (B0.ProductAssemblyID IS NULL)
  -- Input filter
  --AND (B0.ComponentID = @Input_Product)
  AND GETDATE() BETWEEN B1.StartDate AND ISNULL(B1.EndDate, '99991231')

UNION

-- Level 2
SELECT
  P1.Name CodPadre
  ,P1.ProductID IDPadre
  ,P2.Name CodFiglio
  ,P2.ProductID IDFiglio
  ,CAST(CAST(LTRIM(RTRIM(STR(P0.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P1.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P2.ProductID))) AS VARCHAR(20)) AS VARCHAR(MAX)) as Path
  ,B2.BillOfMaterialsID
  ,2 AS Livello
FROM
  Production.BillOfMaterials B0
JOIN
  Production.Product P0 ON P0.ProductID=B0.ComponentID
JOIN
  Production.BillOfMaterials B1 ON B1.ProductAssemblyID=B0.ComponentID
JOIN
  Production.Product P1 ON P1.ProductID=B1.ComponentID
JOIN
  Production.BillOfMaterials B2 ON B2.ProductAssemblyID=B1.ComponentID
JOIN
  Production.Product P2 ON P2.ProductID=B2.ComponentID
WHERE
  -- Parent product identification number
  -- Foreign key to Product.ProductID
  (B0.ProductAssemblyID IS NULL)
  -- Input filter
  --AND (B0.ComponentID = @Input_Product)
  AND GETDATE() BETWEEN B2.StartDate AND ISNULL(B2.EndDate, '99991231')

UNION

-- Level 3
SELECT
  P2.Name CodPadre
  ,P2.ProductID IDPadre
  ,P3.Name CodFiglio
  ,P3.ProductID IDFiglio
  ,CAST(CAST(LTRIM(RTRIM(STR(P0.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P1.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P2.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P3.ProductID))) AS VARCHAR(20)) AS VARCHAR(MAX)) as Path
  ,B3.BillOfMaterialsID
  ,3 AS Livello
FROM
  Production.BillOfMaterials B0
JOIN
  Production.Product P0 ON P0.ProductID=B0.ComponentID
JOIN
  Production.BillOfMaterials B1 ON B1.ProductAssemblyID=B0.ComponentID
JOIN
  Production.Product P1 ON P1.ProductID=B1.ComponentID
JOIN
  Production.BillOfMaterials B2 ON B2.ProductAssemblyID=B1.ComponentID
JOIN
  Production.Product P2 ON P2.ProductID=B2.ComponentID
JOIN
  Production.BillOfMaterials B3 ON B3.ProductAssemblyID=B2.ComponentID
JOIN
  Production.Product P3 ON P3.ProductID=B3.ComponentID
WHERE
  (B0.ProductAssemblyID IS NULL)
  -- Input filter
  --AND (B0.ComponentID = @Input_Product)
  AND GETDATE() BETWEEN B3.StartDate AND ISNULL(B3.EndDate, '99991231')

UNION

-- Level 4
SELECT
  P3.Name CodPadre
  ,P3.ProductID IDPadre
  ,P4.Name CodFiglio
  ,P4.ProductID IDFiglio
  ,CAST(CAST(LTRIM(RTRIM(STR(P0.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P1.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P2.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P3.ProductID))) AS VARCHAR(20)) + '.' + CAST(LTRIM(RTRIM(STR(P4.ProductID))) AS VARCHAR(20)) AS VARCHAR(MAX)) as Path
  ,B4.BillOfMaterialsID
  ,4 AS Livello
FROM
  Production.BillOfMaterials B0
JOIN
  Production.Product P0 ON P0.ProductID=B0.ComponentID
JOIN
  Production.BillOfMaterials B1 ON B1.ProductAssemblyID=B0.ComponentID
JOIN
  Production.Product P1 ON P1.ProductID=B1.ComponentID
JOIN
  Production.BillOfMaterials B2 ON B2.ProductAssemblyID=B1.ComponentID
JOIN
  Production.Product P2 ON P2.ProductID=B2.ComponentID
JOIN
  Production.BillOfMaterials B3 ON B3.ProductAssemblyID=B2.ComponentID
JOIN
  Production.Product P3 ON P3.ProductID=B3.ComponentID
JOIN
  Production.BillOfMaterials B4 ON B4.ProductAssemblyID=B3.ComponentID
JOIN
  Production.Product P4 ON P4.ProductID=B4.ComponentID
WHERE
  (B0.ProductAssemblyID IS NULL)
  -- Input filter
  --AND (B0.ComponentID = @Input_Product)
  AND GETDATE() BETWEEN B4.StartDate AND ISNULL(B4.EndDate, '99991231');
GO

/*
SELECT * FROM Production.vw_Get_BillOfMaterials_Tree WHERE Path LIKE '749%';
*/