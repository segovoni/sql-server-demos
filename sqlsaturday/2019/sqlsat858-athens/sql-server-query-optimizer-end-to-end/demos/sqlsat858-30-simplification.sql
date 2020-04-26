------------------------------------------------------------------------
-- Event:        SQL Saturday #858 Athens, June 15 2019                -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/858/Sessions/Details.aspx?sid=90801     -
-- Demo:         Simplification                                        -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO

-- Subqueries to joins
-- When possible, it converts subqueries to joins
SELECT
  OD.OrderID
  ,OD.Quantity
  ,OD.PickedQuantity
  ,OD.PickingCompletedWhen
FROM
  Sales.OrderLines AS OD
WHERE
  (OD.StockItemID IN (SELECT
                        StockItemID
                      FROM
                        Warehouse.StockItems
                      WHERE
                        StockItemName LIKE 'DBA%'));
GO


-- In this case, the inner query is a summary query
-- and the outer query is not
-- There is no way to combine the two queries by a
-- simple join
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.UnitPrice
FROM
  Warehouse.StockItems AS P
WHERE
  (P.UnitPrice < (SELECT
                    AVG(UnitPrice)
                  FROM
                    Sales.OrderLines));
GO


-- Unused table and redundant joins
-- It removes unused table, redundant inner and outer joins
-- may be removed
-- TF 3604 enables output in the messages page
-- TF 8606 enables the output of the parse tree in the different
--         phases of optimization
SELECT
  P.StockItemID
  ,P.StockItemName
FROM
  Warehouse.StockItems AS P
LEFT OUTER JOIN
  Warehouse.Colors AS CR ON CR.ColorID=P.ColorID
LEFT OUTER JOIN
  Purchasing.Suppliers AS S ON S.SupplierID=P.SupplierID
WHERE
  (P.StockItemName LIKE 'DBA%')
OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8606);
GO


-- TF 3604 enables output in the messages page
-- TF 8606 enables the output of the parse tree in the different
--         phases of optimization
WITH Sales AS
(
  SELECT
    OL.StockItemID
    ,P.StockItemName
    ,OL.OrderID
    ,OL.Quantity
    ,OL.UnitPrice
    ,O.OrderDate
    ,C.CustomerID
    ,C.CustomerName
  FROM
    Warehouse.StockItems AS P
  FULL JOIN
    Sales.OrderLines AS OL ON OL.StockItemID=P.StockItemID
  FULL JOIN
    Sales.Orders AS O ON O.OrderID=OL.OrderID
  FULL JOIN
    Sales.Customers AS C ON C.CustomerID=O.CustomerID
)
SELECT
  S.OrderID
  ,S.Quantity
  ,S.UnitPrice
FROM
  Sales AS S
WHERE
  S.StockItemID = 73
OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8606);
GO



-- Contradictions
-- Query Optimizer detects contradictions, such as opposite
-- conditions in the WHERE clause
SET STATISTICS IO ON;

SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
FROM
  Warehouse.StockItems AS P
WHERE
  (P.StockItemID > 50) AND (P.StockItemID < 40);
GO


-- Why can't the Query Optimizer, in this case, see the contradictions?
-- We don't need to access the table

-- Let's see the execution plan, it's parameterized and it's trivial

-- Simple parameterization can only occur if the plan is a trivial plan
-- Again, simple parameterization
-- is considered when the Optimizer thinks that the predicate change doesn't
-- affect the query plan

-- If we add a join, we get the plan expected
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
  ,C.ColorName
FROM
  Warehouse.StockItems AS P
LEFT OUTER JOIN
  Warehouse.Colors AS C ON C.ColorID=P.ColorID
WHERE
  (P.StockItemID > 50) AND (P.StockItemID < 40);
GO


-- :))
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
FROM
  Warehouse.StockItems AS P
WHERE
  (P.StockItemID > 50) AND (P.StockItemID < 40)
  AND 2 = (SELECT 2)
OPTION (RECOMPILE, QUERYTRACEON 3604, QUERYTRACEON 8606);
GO


-- A check constraint should negate the WHERE clause here
-- But the execution plan is trivial!
SELECT
  ColorID
FROM
  Warehouse.Colors
WHERE
  (ColorName = 'Gray');
GO




------------------------------------------------------------------------
-- Trace Flag                                                          -
------------------------------------------------------------------------

-- TF 3604 enables the output in the messages page
DBCC TRACEON(3604);
GO


-- TF 8606 enables the output of the parse tree in the different
-- phases of optimization such as "Input Tree", "Simplified Tree",
-- "Join-collapsed Tree", "Tree Before Project Normalization" and
-- "Tree After Project Normalization"
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
  ,C.ColorName
FROM
  Warehouse.StockItems AS P
JOIN
  Warehouse.Colors AS C ON P.ColorID=C.ColorID
WHERE
  (P.ColorID IS NOT NULL)
OPTION (RECOMPILE, QUERYTRACEON 8606);
GO



-- TF 8606 enables the output of the parse tree
-- TF 8605 will output the converted tree
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
  ,C.ColorName
FROM
  Warehouse.StockItems AS P
JOIN
  Warehouse.Colors AS C ON P.ColorID=C.ColorID
WHERE
  (P.ColorID IS NOT NULL)
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606);
GO


-- TF 8605 enables the output of the converted tree
-- TF 8606 enables the output of the parse tree
-- TF 8621 enables the output of the rules applied
SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.MarketingComments
  ,C.ColorName
FROM
  Warehouse.StockItems AS P
JOIN
  Warehouse.Colors AS C ON P.ColorID=C.ColorID
WHERE
  (P.ColorID IS NOT NULL)
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8621);
GO


-- Disable the output in the messages page
DBCC TRACEOFF(3604);
GO