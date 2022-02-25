------------------------------------------------------------------------
-- Event:        DATA SATURDAY #20 - Pordenone 2022                    -
--               http://datasaturdays.com/2022-02-26-datasaturday0020/ -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Join order                                            -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


-- Supplier-Customer that have join activity
SELECT
  C.CustomerName, PS.SupplierName
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
  ON O.CustomerID=C.CustomerID
INNER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
INNER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID
INNER JOIN Purchasing.Suppliers AS PS
  ON S.SupplierID=PS.SupplierID;
GO

-- We want to preserve customers who have no orders


SELECT
  C.CustomerName, PS.SupplierName
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON O.CustomerID=C.CustomerID
INNER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
INNER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID
INNER JOIN Purchasing.Suppliers AS PS
  ON S.SupplierID=PS.SupplierID;
GO

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
  C.CustomerName, PS.SupplierName
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
  ON O.CustomerID=C.CustomerID
LEFT OUTER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
LEFT OUTER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID
LEFT OUTER JOIN Purchasing.Suppliers AS PS
  ON S.SupplierID=PS.SupplierID;
GO



-- The logical join ordering is determined by the order of ON clauses
SELECT
  C.CustomerName, PS.SupplierName
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
INNER JOIN Sales.OrderLines AS OL
  ON O.OrderID=OL.OrderID
INNER JOIN Warehouse.StockItems AS S
  ON OL.StockItemID=S.StockItemID
INNER JOIN Purchasing.Suppliers AS PS
  ON S.SupplierID=PS.SupplierID
  ON O.CustomerID=C.CustomerID;
GO


SELECT
  C.CustomerName, PS.SupplierName
FROM Sales.Customers AS C
LEFT OUTER JOIN
  ( Sales.Orders AS O
    INNER JOIN Sales.OrderLines AS OL
      ON O.OrderID=OL.OrderID
    INNER JOIN Warehouse.StockItems AS S
      ON OL.StockItemID=S.StockItemID
    INNER JOIN Purchasing.Suppliers AS PS
      ON S.SupplierID=PS.SupplierID
  )
  ON O.CustomerID=C.CustomerID;
GO