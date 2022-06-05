------------------------------------------------------------------------
-- Event:    SQL Start 2022, June 10                                  --
--           https://www.sqlstart.it/2022/Speakers/Sergio-Govoni      --
--                                                                    --
-- Session:  SQL Server 2022 Parameter Sensitive Plan Optimization    --
--                                                                    --
-- Demo:     Parameterization                                         --
-- Author:   Sergio Govoni                                            --
-- Notes:    --                                                       --
------------------------------------------------------------------------

USE [AdventureWorks2019];
GO


SELECT name, is_parameterization_forced
FROM sys.databases
WHERE database_id = DB_ID();
GO


DBCC FREEPROCCACHE;
GO

SELECT * FROM dbo.myTransactionHistory WHERE TransactionID = 666000;
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO

-- Forced parameterization

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

SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO



-- FORCED PARAMETERIZATION for AdventureWorks database
ALTER DATABASE [AdventureWorks2019] SET PARAMETERIZATION FORCED;
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

SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO



-- Now, with FORCED parameterization, even unsafe plans are parameterized!!