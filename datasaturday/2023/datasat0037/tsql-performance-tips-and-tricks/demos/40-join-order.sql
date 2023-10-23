------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2023 - November 18               --
--               https://bit.ly/3tKmyMM                               --
--                                                                    --
-- Session:      T-SQL performance tips & tricks!                     --
--                                                                    --
-- Demo:         Join order                                           --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


-- Customers and orders
SELECT
  C.CustomerName, C.CustomerID, O.OrderID
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
  ON O.CustomerID=C.CustomerID
INNER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
INNER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID;
GO


-- We want to preserve customers who have no orders
-- with a LEFT OUTER JOIN between the Customers and Orders
SELECT
  C.CustomerName, C.CustomerID, O.OrderID
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON O.CustomerID=C.CustomerID
INNER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
INNER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID;
GO


-- The returned rows are the same of the previous query
-- No extra Customers?


-- Let's see
SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers AS C
WHERE NOT EXISTS
  ( SELECT C.CustomerID
    FROM Sales.Orders AS O
    WHERE O.CustomerID=C.CustomerID
  )
ORDER BY
  2;
GO


-- To see extra Customers, all of the JOINs need to be LEFT OUTER JOIN
SELECT
  C.CustomerName, C.CustomerID, O.OrderID
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON O.CustomerID=C.CustomerID
LEFT OUTER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
LEFT OUTER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID;
GO


-- The logical join ordering is determined by the order of ON clauses
SELECT
  C.CustomerName, C.CustomerID, O.OrderID
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
INNER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
INNER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID
  -- Pay attention here!!
  ON O.CustomerID=C.CustomerID;
GO


-- Use round brackets to increase the readability
-- Remember: the logical join ordering is determined by the order of ON clauses
SELECT
  C.CustomerName, C.CustomerID, O.OrderID
FROM Sales.Customers AS C
LEFT OUTER JOIN
  (
    Sales.Orders AS O
    INNER JOIN Sales.OrderLines AS OL
      ON O.OrderID=OL.OrderID
    INNER JOIN Warehouse.StockItems AS S
      ON OL.StockItemID=S.StockItemID
  )
  ON O.CustomerID=C.CustomerID;
GO