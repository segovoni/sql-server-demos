------------------------------------------------------------------------
-- Event:        SQL Saturday #567 Ljubljana, December 10 2016         -
--               http://www.sqlsaturday.com/567/eventhome.aspx         -
-- Session:      Executions Plans End-to-End in SQL Server             -
-- Demo:         Hints and Trace Flags                                 -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2016];
GO

------------------------------------------------------------------------
-- Query hints                                                         -
------------------------------------------------------------------------

DBCC FREEPROCCACHE;
GO


-- Trace Flag
-- TF 3604 enables output in the messages page
DBCC TRACEON(3604);
GO


-- Trace flags
-- Query hint QUERYTRACEON
-- TF 8757 is used to skip the trivial plan, it forces the full optimization

-- Without the query hint, this query would be executed with a trivial plan
SELECT * FROM Production.Product
OPTION (RECOMPILE, QUERYTRACEON 8757);
GO


-- Trace flags
-- Query hint QUERYTRACEON
-- TF 8757 is used to skip the trivial plan, it forces the full optimization
-- TF 8675 shows the query optimization phases
SELECT
  *
FROM
  Production.udf_Get_BillOfMaterials_Tree(749)
ORDER BY
  [Path]
OPTION (RECOMPILE, QUERYTRACEON 8757, QUERYTRACEON 8675);
GO



-- Trace flags
-- Query hint QUERYTRACEON
-- TFs 2372 and 2373 show memory consumption during the optimization process 
SELECT
  *
FROM
  Production.udf_Get_BillOfMaterials_Tree(749)
ORDER BY
  [Path]
--OPTION (RECOMPILE, QUERYTRACEON 2372);
OPTION (RECOMPILE, QUERYTRACEON 2373);
GO



-- Query hints for join operators

SET STATISTICS IO ON;
GO


SELECT
  P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID; --
GO


-- In this particular case, the join from Person and Customer
-- is implemented with a Nested Loops Join

-- We have one access to the "outer" input (top input = Customer table)
-- The "inner input" (bottom input = Person table) is accessed for each row in the outer input (!!)
-- The cost of the join is: SizeOf(outer input) * SizeOf(inner input)



-- We can restrict the available join operators for the query specifying the
-- operators that we want the query optimizer to use

-- The join from Person and Customer is now implemented with an "Hash Match Join"
-- Input operators run once
SELECT
  P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID
OPTION (RECOMPILE, HASH JOIN, MERGE JOIN /*LOOP JOIN*/);
GO


-- Query hint QUERYRULEOFF
-- We can also disable a particular trasformation rule
SELECT
  P.FirstName
  ,P.LastName
  ,C.AccountNumber
FROM
  Person.Person AS P
JOIN
  Sales.Customer AS C ON C.PersonID=P.BusinessEntityID
OPTION(RECOMPILE, QUERYRULEOFF JNtoIdxLookup);
GO



-- Some types of join like "Nested Loops Join", used with a "Key Lookup",
-- can't be forced!
SELECT
  T.TransactionID
  ,P.ProductNumber
  ,P.SafetyStockLevel
  ,T.Quantity
  ,SUM(CASE (T.TransactionType) WHEN 'S' THEN (T.Quantity * -1) ELSE (T.Quantity)END)
     OVER (PARTITION BY T.ProductID ORDER BY T.TransactionID
	       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM
  Production.Product AS P
JOIN
  Production.TransactionHistory AS T ON T.ProductID=P.ProductID
WHERE
  ProductNumber = 'BK-R19B-48'
ORDER BY
  T.TransactionDate
OPTION (MERGE JOIN);
GO



-- ROBUST PLAN query hint

-- ROBUST PLAN query hint is useful on queries that retrieve large dimension rows,
-- with LOBs data types like XML, TEXT and VARCHAR(MAX). In this case, some operators
-- in the execution plan might encounter errors

DBCC FREEPROCCACHE;
GO

SELECT * FROM dbo.DatabaseLog;
GO

SELECT
  DBLog.DatabaseLogID
  ,DBLog.DatabaseUser
  ,DBLog.[Event]
  ,DBLog.[Object]
  ,DBLog.PostTime
  ,DBLog.[Schema]
  ,DBLog.[TSQL]
  ,DBLog.[Text]
  ,ROW_NUMBER()
     OVER(PARTITION BY DBLog.[Schema], DBLog.[Object]
	      ORDER BY DBLog.[Schema], DBLog.[Object]) AS #ROW
  ,DBLog.XmlEvent
  ,T.TABLE_CATALOG
  ,T.TABLE_SCHEMA
  --,T.TABLE_NAME
  --,T.TABLE_TYPE
FROM
  dbo.DatabaseLog DBLog
JOIN
  INFORMATION_SCHEMA.TABLES AS T ON T.TABLE_SCHEMA=DBLog.[Schema] AND T.TABLE_NAME=DBLog.[Object]
OPTION (RECOMPILE);
GO


SELECT
  DBLog.DatabaseLogID
  ,DBLog.DatabaseUser
  ,DBLog.[Event]
  ,DBLog.[Object]
  ,DBLog.PostTime
  ,DBLog.[Schema]
  ,DBLog.[TSQL]
  ,DBLog.[Text]
  ,ROW_NUMBER()
     OVER(PARTITION BY DBLog.[Schema], DBLog.[Object]
	      ORDER BY DBLog.[Schema], DBLog.[Object]) AS #ROW
  ,DBLog.XmlEvent
  ,T.TABLE_CATALOG
  ,T.TABLE_SCHEMA
  --,T.TABLE_NAME
  --,T.TABLE_TYPE
FROM
  dbo.DatabaseLog DBLog
JOIN
  INFORMATION_SCHEMA.TABLES AS T ON T.TABLE_SCHEMA=DBLog.[Schema] AND T.TABLE_NAME=DBLog.[Object]
OPTION (RECOMPILE, ROBUST PLAN);
GO




------------------------------------------------------------------------
-- *** Bonus queries ***                                               -
------------------------------------------------------------------------


-- FORCE ORDER query hint
SELECT
  *
FROM
  Sales.SalesOrderHeader AS H
JOIN
  Sales.SalesOrderDetail AS D ON D.SalesOrderID=h.SalesOrderID
JOIN
  Production.Product AS P ON P.ProductID=D.ProductID
WHERE
  P.ProductID = 707
OPTION (RECOMPILE, FORCE ORDER);
GO




------------------------------------------------------------------------
-- Join hints                                                          -
------------------------------------------------------------------------

DBCC FREEPROCCACHE;
GO

-- E' possibile influire solo su uno specifico Join (e non sull'intera query)
-- La sintassi del join deve essere ANSI

SELECT
  *
FROM
  Sales.SalesOrderHeader AS H
JOIN
  Sales.SalesOrderDetail AS D ON D.SalesOrderID=h.SalesOrderID
JOIN
  Production.Product AS P ON P.ProductID=D.ProductID
WHERE
  P.ProductID = 707;
GO


-- Hash Join with Production.Product
SELECT
  *
FROM
  Sales.SalesOrderHeader AS H
JOIN
  Sales.SalesOrderDetail AS D ON D.SalesOrderID=h.SalesOrderID
INNER HASH JOIN /* Join hints */
  Production.Product AS P ON P.ProductID=D.ProductID
WHERE
  P.ProductID = 707;
GO



------------------------------------------------------------------------
-- Table hints                                                         -
------------------------------------------------------------------------


-- Seek on the index IX_TransactionHistory_ProductID
-- Key Lookup for TransactionType, TransactionDate and Quantity
SELECT
  ProductID
  ,TransactionID
  ,TransactionType
  ,TransactionDate
  ,Quantity
FROM
  Production.TransactionHistory
WHERE
  (ProductID = 849);
GO


-- Indexes defined on Production.TransactionHistory
SELECT * FROM sys.indexes
WHERE [object_id] = OBJECT_ID('Production.TransactionHistory', 'U');
GO


-- In this query we have forced the use of the cluster index (ID = 1)
SELECT
  ProductID
  ,TransactionID
  ,TransactionType
  ,TransactionDate
  ,Quantity
FROM
  Production.TransactionHistory
WITH
  (INDEX(1))
WHERE
  (ProductID = 849);
GO


-- In this query we have forced the use of a particual index
SELECT
  ProductID
  ,TransactionID
  ,TransactionType
  ,TransactionDate
  ,Quantity
FROM
  Production.TransactionHistory
WITH
  (INDEX(IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID))
WHERE
  (ProductID = 849 /* 870 */ );
GO


-- In this query we have forced a particular operation (Seek) on a particual index
SELECT
  ProductID
  ,TransactionID
  ,TransactionType
  ,TransactionDate
  ,Quantity
FROM
  Production.TransactionHistory
WITH
  (FORCESEEK, INDEX(IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID))
WHERE
  (ProductID = 849);
GO


-- FORCESEEK table hint
SELECT
  *
FROM
  Production.TransactionHistory WITH (FORCESEEK)
WHERE
 ProductID IN (SELECT ProductID FROM Production.Product WHERE ProductID < 300);
GO



------------------------------------------------------------------------
-- Cleanup                                                             -
------------------------------------------------------------------------

DBCC FREEPROCCACHE;
GO

-- Informazioni sulle regole di trasformazione disabilitate
DBCC TRACEON (3604);
DBCC SHOWOFFRULES;
GO