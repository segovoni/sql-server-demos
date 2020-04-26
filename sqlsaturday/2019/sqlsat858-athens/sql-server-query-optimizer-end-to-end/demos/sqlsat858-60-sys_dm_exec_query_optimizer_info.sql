------------------------------------------------------------------------
-- Event:        SQL Saturday #858 Athens, June 15 2019                -
-- Session:      SQL Server Query Optimizer end-to-end                 -
-- https://www.sqlsaturday.com/858/Sessions/Details.aspx?sid=90801     -
-- Demo:         Optimization process                                  -
--               How to obtain information about the optimization      -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO

------------------------------------------------------------------------
-- How to obtain information about the optimization                    -
-- applied to a particular query                                       -
------------------------------------------------------------------------

-- Because the DMV stores cumulative values since the SQL Server service
-- starts we must use the following technique:

-- 1) Saving optimization values in a particular moment
--    before the execution of the query we are focusing on
-- 2) Execute the query
-- 3) Another saving of the optimization values
-- 4) Make a SUBTRACTION of the values in step 1 and 3


-- To let the system know the query used in the first and third steps,
-- we have to execute them at the very beginning, discarding the results


DBCC FREEPROCCACHE;
GO

SELECT * INTO #optimizer_info_before_query FROM sys.dm_exec_query_optimizer_info;
GO

SELECT * INTO #optimizer_info_after_query FROM sys.dm_exec_query_optimizer_info;
GO

DROP TABLE #optimizer_info_before_query;
DROP TABLE #optimizer_info_after_query;
GO

SELECT * INTO #optimizer_info_before_query FROM sys.dm_exec_query_optimizer_info;
GO

-- 2. This query retrieves sales order starting from 01/01/2016
-- grouped by OrderID, ordered by total
SELECT
  h.OrderID
  ,SUM(d.UnitPrice * d.Quantity) AS LinesTotal
FROM
  Sales.Orders AS h
JOIN
  Sales.OrderLines AS d
  ON h.OrderID=d.OrderID
WHERE
  (h.OrderDate >= '20160101')
GROUP BY
  h.OrderID
ORDER BY
  LinesTotal DESC;
GO

SELECT * INTO #optimizer_info_after_query FROM sys.dm_exec_query_optimizer_info;
GO

-- SUBTRACTION of the values in step 1 and 3
SELECT
  a.counter
  ,occurrence = (a.occurrence - b.occurrence)
  ,value = ((a.occurrence * a.value) - (b.occurrence * b.value))
FROM
  #optimizer_info_before_query AS b
JOIN
  #optimizer_info_after_query AS a ON a.counter=b.counter
WHERE
  (a.occurrence <> b.occurrence);
GO

DROP TABLE #optimizer_info_before_query;
DROP TABLE #optimizer_info_after_query;
GO



------------------------------------------------------------------------
-- Transformation rules                                                -
------------------------------------------------------------------------

DBCC TRACEON(3604);
GO

-- 404 rules on SQL Server 2017
SELECT * FROM sys.dm_exec_query_transformation_stats;
GO

DBCC FREEPROCCACHE;
GO

SELECT * INTO #query_transformation_stats_before_query
FROM sys.dm_exec_query_transformation_stats;
GO

SELECT * INTO #query_transformation_stats_after_query
FROM sys.dm_exec_query_transformation_stats;
GO

DROP TABLE #query_transformation_stats_before_query;
DROP TABLE #query_transformation_stats_after_query;
GO


SELECT * INTO #query_transformation_stats_before_query
FROM sys.dm_exec_query_transformation_stats;
GO


SELECT
  P.FullName
  ,C.CustomerName
FROM
  Application.People AS P
JOIN
  Sales.Customers AS C ON C.PrimaryContactPersonID=P.PersonID
  OPTION (RECOMPILE, LOOP JOIN, MERGE JOIN)
--OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8621)
GO

-- Query
-- 0,769501 with GbAggToHS ON
-- 2,48905  with GbAggToHS OFF
--SELECT
--  t.TerritoryID
--  ,COUNT(*)
--FROM
--  Sales.SalesTerritory AS t
--JOIN
--  Sales.SalesOrderHeader AS h ON h.TerritoryID=t.TerritoryID
--GROUP BY
--  t.TerritoryID;
--GO


--SELECT
--  P.FirstName
--  ,P.LastName
--  ,C.AccountNumber
--FROM
--  Person.Person AS P
--JOIN
--  Sales.Customer AS C ON C.PersonID = P.BusinessEntityID
----OPTION (RECOMPILE);
----OPTION (RECOMPILE, LOOP JOIN, MERGE JOIN);
--OPTION(RECOMPILE, QUERYRULEOFF JNtoHS, QUERYRULEOFF JNtoSM);


SELECT * INTO #query_transformation_stats_after_query
FROM sys.dm_exec_query_transformation_stats;
GO

SELECT
  a.name
  ,promised = (a.promised - b.promised)
FROM
  #query_transformation_stats_before_query AS b
JOIN
  #query_transformation_stats_after_query AS a ON a.name=b.name
WHERE
  (a.succeeded <> b.succeeded);
GO

DROP TABLE #query_transformation_stats_before_query;
DROP TABLE #query_transformation_stats_after_query;
GO


------------------------------------------------------------------------
-- Disable/Enable transformation rules                                 -
--                                                                     -
-- DBCC RULEON(), DBCC RULEOFF()                                       -
------------------------------------------------------------------------

DBCC RULEOFF('GbAggBeforeJoin');
DBCC RULEOFF('GbAggToStrm'); -- Group By Aggregate to
DBCC RULEOFF('JNtoHS')
GO

DBCC RULEON('GbAggBeforeJoin');
DBCC RULEON('GbAggToStrm'); -- Group By Aggregate to
DBCC RULEON('JNtoHS')
GO

DBCC SHOWOFFRULES;
GO

DBCC SHOWONRULES;
GO