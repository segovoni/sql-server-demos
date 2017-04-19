------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      Exploring SQL Server Plan Cache                       -
-- Demo:         Parameterization                                      -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks];
GO



SELECT name, is_parameterization_forced
FROM sys.databases
WHERE database_id = DB_ID();
GO


DBCC FREEPROCCACHE;
GO

SELECT * FROM dbo.myTransactionHistory WHERE TransactionID = 666000;
GO
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks');
GO

------------------------------------------------------------------------
-- Forced parameterization                                             -
------------------------------------------------------------------------


DBCC FREEPROCCACHE;
GO

-- Does the execution plan of this query will be parametrized?
-- The query is "safe" but not "simple"
SELECT
  *
FROM
  dbo.myTransactionHistory AS t
JOIN
  Production.Product AS p ON p.ProductID=t.ProductID
WHERE
  (t.TransactionID = 666222);
GO

SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks');
GO



-- FORCED PARAMETERIZATION for AdventureWorks database
ALTER DATABASE [AdventureWorks] SET PARAMETERIZATION FORCED;
GO


DBCC FREEPROCCACHE;
GO


SELECT
  *
FROM
  dbo.myTransactionHistory AS t
JOIN
  Production.Product AS p ON p.ProductID=t.ProductID
WHERE
  (t.TransactionID = 666222);
GO

SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks');
GO



-- Now, with FORCED parameterization, even unsafe plans are parameterized!!

DBCC FREEPROCCACHE;
GO

SELECT * FROM dbo.myTransactionHistory WHERE TransactionID < 100034;
GO
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks');
GO


SET STATISTICS IO ON;
GO

-- logical reads?
SELECT * FROM dbo.myTransactionHistory WHERE TransactionID < 100034;
GO

-- logical reads?
SELECT * FROM dbo.myTransactionHistory WHERE TransactionID < 200034
OPTION (RECOMPILE)
GO

-- How many pages would be read by a table scan?
SELECT * FROM dbo.myTransactionHistory;
GO


ALTER DATABASE AdventureWorks SET PARAMETERIZATION SIMPLE;
GO