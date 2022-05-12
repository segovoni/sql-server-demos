------------------------------------------------------------------------
-- Event:        #DataWeekender CU5 - May 14th 2022                    -
--               A Pop-up and Online Microsoft Data Conference         -
--               https://www.dataweekender.com/                        -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Join order                                            -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
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
SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers AS C
WHERE NOT EXISTS
  ( SELECT C.CustomerID
    FROM Sales.Orders AS O
    WHERE O.CustomerID=c.CustomerID
  )
ORDER BY
  2;
GO



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
  ON O.CustomerID=C.CustomerID;
GO



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