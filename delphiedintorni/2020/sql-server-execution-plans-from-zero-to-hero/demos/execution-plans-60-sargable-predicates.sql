------------------------------------------------------------------------
-- Event:        Delphi & Dintorni - July 09, 2020                     -
-- Session:      SQL Server Execution Plans: From Zero to Hero         -
--               https://bit.ly/3e9vLAB                                -
-- Demo:         Search ARGument predicate                             -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


SELECT * FROM Warehouse.StockItems;
GO


-- SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID = 104;
GO


-- NON SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID + 1 = 104;
GO


-- SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID = (105 - 1);
GO


-- ???
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemID + 0 = 104;
GO



-- SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  StockItemName = 'DBA joke mug - it depends (Black)';
GO


-- NON SARGable
SELECT
  StockItemID
  ,SupplierID
  ,LeadTimeDays
FROM
  Warehouse.StockItems
WHERE
  UPPER(StockItemName) = UPPER('DBA joke mug - it depends (Black)');
GO


-- NON SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  LEFT(StockItemName, 3) = 'DBA';
GO


-- NON SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  YEAR(ValidFrom) = YEAR(GETDATE());
GO


/*
SELECT DATEDIFF(yy, 0, GETDATE());
SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
SELECT DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, 0)
*/


-- SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  ValidFrom >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
	AND ValidFrom < DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, 0);
GO



-- ??? 
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  StockItemName LIKE 'DBA%';
GO


-- NON SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  ISNULL(Size, 'M') = 'M';
GO


-- SARGable
SELECT
  COUNT(*)
FROM
  Warehouse.StockItems
WHERE
  (Size = 'M') OR (Size IS NULL);
GO