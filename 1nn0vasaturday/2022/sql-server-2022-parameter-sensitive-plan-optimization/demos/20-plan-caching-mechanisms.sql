------------------------------------------------------------------------
-- Event:    1nn0va Saturday 2022 - September 24                      --
--                                                                    --
-- Session:  SQL Server 2022 Parameter Sensitive Plan Optimization    --
--                                                                    --
-- Demo:     Introduction to plan caching mechanisms                  --
-- Author:   Sergio Govoni                                            --
-- Notes:    --                                                       --
------------------------------------------------------------------------

USE [AdventureWorks2019];
GO


-- Don't run this on production servers!!
DBCC FREEPROCCACHE;
GO

SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO


-- Ad-hoc queries
SELECT * FROM dbo.myTransactionHistory WHERE Quantity = 29;
GO
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO


SELECT * FROM dbo.myTransactionHistory WHERE Quantity = 61;
GO
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO








-- Optimize for ad hoc workloads
EXEC sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
GO


DBCC FREEPROCCACHE;
GO
/*
DBCC FLUSHPROCINDB(9);
GO
*/


-- Ad-hoc queries again
SELECT * FROM dbo.myTransactionHistory WHERE Quantity = 29;
GO
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO


SELECT * FROM dbo.myTransactionHistory WHERE Quantity = 61;
GO
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO



SELECT * FROM dbo.myTransactionHistory WHERE TransactionID = 666777;
GO
SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks2019');
GO







-- Why is this query plan not an ad-hoc plan?
-- Why is this query different?




-- How many rows would return when I put a filter on TransactionID?
-- ONE or ZERO!

-- In the previous queries, different values would return different numbers of rows, so..

-- We saw an Ad-hoc plan because the plan for one parameter is not necessary
-- the right plan for a different parameter value

-- That is what makes this query different!
SELECT * FROM dbo.myTransactionHistory WHERE TransactionID = 666777;




SELECT * FROM sys.dm_exec_cached_plans;
SELECT * FROM sys.dm_exec_plan_attributes(0x06000500411A230FB0F01B91C501000001000000000000000000000000000000000000000000000000000000);
GO


-- cacheobjtype = 'Compiled Plan'
-- objtype = 'Adhoc'
-- usecounts = 1
SELECT
  est.text
  ,qp.query_plan
  ,ecp.size_in_bytes/1000.0/1000.0 AS size_in_mb
  ,eqs.last_execution_time
FROM
  sys.dm_exec_cached_plans AS ecp
JOIN
  sys.dm_exec_query_stats AS eqs ON eqs.plan_handle=ecp.plan_handle
CROSS APPLY
  sys.dm_exec_sql_text(ecp.plan_handle) AS est
CROSS APPLY
  sys.dm_exec_query_plan(ecp.plan_handle) AS qp
WHERE
  (ecp.cacheobjtype = 'Compiled Plan')
  AND (ecp.objtype = 'Adhoc')
  AND (ecp.usecounts = 1)
ORDER BY
  eqs.last_execution_time;
GO


-- size_in_MB = Memory allocated for the Ad-hoc plans
SELECT
  ecp.objtype
  ,ecp.usecounts
  ,COUNT(*) AS nplan
  ,SUM(ecp.size_in_bytes)/1000.00/1000.00 AS [size_in_MB]
FROM
  sys.dm_exec_cached_plans AS ecp
WHERE
  (ecp.cacheobjtype = 'Compiled Plan')
  AND (ecp.objtype = 'Adhoc')
GROUP BY
  ecp.objtype
  ,ecp.usecounts
ORDER BY
  ecp.usecounts ASC;
GO

-- Set "Optimize for ad hoc workloads" to default
EXEC sp_configure 'optimize for ad hoc workloads', 0;
GO
RECONFIGURE;
GO