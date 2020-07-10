------------------------------------------------------------------------
-- Event:        Delphi & Dintorni - July 09, 2020                     -
-- Session:      SQL Server Execution Plans: From Zero to Hero         -
--               https://bit.ly/3e9vLAB                                -
-- Demo:         Index Scan VS Index Seek                              -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO


DBCC FREEPROCCACHE;
GO


EXEC sp_helpindex 'Sales.SalesOrderDetail';
GO


SET STATISTICS IO ON;
GO

-- Logical reads:
SELECT
  h.CustomerID
  ,h.OrderDate
  ,h.SalesOrderNumber
  ,d.ProductID
  ,d.LineTotal
  ,d.UnitPrice
FROM
  Sales.SalesOrderHeader AS h
JOIN
  Sales.SalesOrderDetail AS d 
    ON h.SalesOrderID=d.SalesOrderID;
GO

-- Force using an Index Seek
-- logical reads:
SELECT
  h.CustomerID
  ,h.OrderDate
  ,h.SalesOrderNumber
  ,d.ProductID
  ,d.LineTotal
  ,d.UnitPrice
FROM
  Sales.SalesOrderHeader AS h
JOIN
  Sales.SalesOrderDetail AS d WITH (FORCESEEK)
    ON h.SalesOrderID=d.SalesOrderID;
GO