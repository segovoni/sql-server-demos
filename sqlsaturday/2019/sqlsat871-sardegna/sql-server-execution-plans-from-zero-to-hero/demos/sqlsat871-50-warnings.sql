------------------------------------------------------------------------
-- Event:        SQL Saturday #871 Sardegna 2019, May 18               -
-- Session:      SQL Server Execution Plans: From Zero to Hero         -
-- https://www.sqlsaturday.com/871/Sessions/Details.aspx?sid=91267     -
-- Demo:         Warnings in the Execution Plan                        -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- Type conversion warning
SELECT
  h.SalesOrderNumber
  ,SUM(d.LineTotal) AS LinesTotal
FROM
  Sales.SalesOrderHeader AS h
JOIN
  Sales.SalesOrderDetail AS d
  ON h.SalesOrderID=d.SalesOrderID
WHERE
  (h.OrderDate >= '20071001')
GROUP BY
  h.SalesOrderNumber
ORDER BY
  LinesTotal DESC;
GO


-- No join predicate warning
-- Display the estimated execution plan
SELECT
  *
FROM
  Production.TransactionHistory AS th
  ,Production.Product AS p;
GO



-- Sort warning
-- Cardinality estimation
-- ActualRows <> EstimateRows
SELECT
  *
FROM
  Purchasing.PurchaseOrderDetail AS pod
WHERE
  (pod.ReceivedQty >= pod.OrderQty)
ORDER BY
  pod.RejectedQty DESC;
GO



-- UnmatchedIndexes warning

EXEC sp_helpindex 'dbo.myOrderHeader';
GO

DECLARE @DateTo VARCHAR(8) = '20150128';

SELECT
  DeliveryDate
  ,OrderID
  ,OrderDate
FROM
  dbo.myOrderHeader
WHERE
  --(DeliveryDate BETWEEN '20150127' AND '20150128')
  (DeliveryDate BETWEEN '20150127' AND @DateTo)
  AND (DeliveryNote IS NOT NULL);
GO




-- Warnings from the plan cache
WITH XMLNAMESPACES 
(
  DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)  
SELECT
  --stat.last_execution_time
  st.text AS QueryText
  ,plan_handle
  ,tp.query_plan.query('//Warnings') AS Warning
  ,query_plan
FROM
  (
    SELECT DISTINCT plan_handle 
	FROM sys.dm_exec_cached_plans WITH(NOLOCK)
  ) AS qs  
OUTER APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS tp
OUTER APPLY
  sys.dm_exec_sql_text(qs.plan_handle) AS st
--CROSS APPLY
--  (SELECT s.last_execution_time FROM sys.dm_exec_query_stats AS s WHERE s.plan_handle=qs.plan_handle) AS stat
WHERE
  tp.query_plan.exist('//Warnings')=1
--ORDER BY
--  stat.last_execution_time DESC
GO