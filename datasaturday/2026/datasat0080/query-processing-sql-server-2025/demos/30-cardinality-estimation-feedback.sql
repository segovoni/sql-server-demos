------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2026, February 28            --
--               https://bit.ly/4qgoS6D                               --
--                                                                    --
-- Session:      Query Processing improvements in SQL Server 2025     --
--                                                                    --
-- Demo:         Cardinality estimation (CE) feedback                 --
-- Author:       Sergio Govoni                                        --
-- Notes:        Credits to Bob Ward                                  --
--               https://bit.ly/ms-ce-feedback                        --
------------------------------------------------------------------------

USE [AdventureWorks2016_EXT];
GO

-- There are 3 model assumptions to determine the selectivity of multiple
-- predicates with an AND clause:
-- 1. Full correlation
-- 2. Partial correlation
-- 3. Full independence

-- Full independence is the default behavior of the cardinality estimation
-- model of SQL Server 2012 and earlier versions

-- Query Optimizer assumed that the combination of filter predicates
-- would result in a much higher selectivity. This assumption implied
-- that there were fewer rows in the query result than what was actually
-- the case

SELECT
  AddressID
  ,AddressLine1
  ,AddressLine2
FROM Person.Address
WHERE
  StateProvinceID = 79
  AND City = 'Redmond'
OPTION (QUERYTRACEON 9481); -- CardinalityEstimationModelVersion 70 (legacy)
--OPTION(USE HINT('ASSUME_FULL_INDEPENDENCE_FOR_FILTER_ESTIMATES'), RECOMPILE)
GO


-- The cardinality estimation process depends heavily on statistics
-- when calculating row estimates. In this example, there are no multi-column
-- statistics for the Query Optimizer to leverage
SELECT
  s.[object_id]
  ,s.[name]
  ,s.auto_created
  ,COL_NAME(s.[object_id], sc.column_id) AS [col_name]
FROM
  sys.stats AS s
INNER JOIN
  sys.stats_columns AS sc ON s.stats_id = sc.stats_id
                         AND s.[object_id] = sc.[object_id]
WHERE
  s.[object_id] = OBJECT_ID('Person.Address');
GO


-- We can derive selectivities for each predicate from the associated
-- statistics objects by using the histogram or density vector information
/*
SELECT
  h.step_number
  ,h.range_high_key
  ,h.range_rows
  ,h.equal_rows
  ,h.average_range_rows
  ,h.equal_rows/19614 AS predicate_selectivity
FROM
  sys.stats AS s
CROSS APPLY
  sys.dm_db_stats_histogram(s.[object_id], s.stats_id) AS h
WHERE
  s.[name] = 'IX_Address_City'
  AND range_high_key = 'Redmond'
*/

DBCC SHOW_STATISTICS ('Person.Address', _WA_Sys_00000004_29572725); -- City Redmond
GO
-- City with a value of "Redmond" has the following histogram step:
-- Redmond 2 121 2 1
-- Dividing 121 by 19614 gives us a selectivity of 0.0061690
SELECT
  121.0 / 19614; -- City predicate selectivity


DBCC SHOW_STATISTICS ('Person.Address', IX_Address_StateProvinceID); -- StateProvinceID 79
GO
-- StateProvinceID with a value of "79" has the following histogram step:
-- 79 0 2636 0 1
-- Dividing 2636 by 19614 gives us a selectivity of 0.13439380
SELECT
  2636.0 / 19614; -- StateProvinceID predicate selectivity



-- City is more selective than StateProvinceID

-- Even though these individual columns all describe a shared location and are correlated,
-- the Query Optimizer before SQL Server 2014 assumes full independence across the columns

-- By assuming independence, the system computes the selectivity of conjunctive predicates 
-- by multiplying individual selectivities
-- 16.261483958050800
SELECT
  0.0061690 *  -- City predicate selectivity
  0.13439380 * -- StateProvinceID predicate selectivity
  19614;       -- Table cardinality
GO


-- NEW CE

-- Partial correlation is the default behavior of the cardinality estimation
-- model of SQL Server 2014 or higher

-- Re-executing the query shows the following increased row estimate
-- (44.3583 rows)
SELECT
  AddressID
  ,AddressLine1
  ,AddressLine2
FROM Person.Address
WHERE
  StateProvinceID = 79
  AND City = 'Redmond';
GO


-- Partial correlation model is based on an exponential backoff
-- 44.3578571648016
SELECT
  0.0061690 *        -- City predicate selectivity
  SQRT(0.13439380) * -- StateProvinceID predicate selectivity
  19614;             -- Table cardinality
GO


-- Let's see what CE feedback is able to do

ALTER DATABASE [AdventureWorks2016_EXT] SET QUERY_STORE = ON
(
  -- Describes the operation mode of the query store
  OPERATION_MODE = READ_WRITE

  -- STALE_QUERY_THRESHOLD_DAYS determines the number of days for which the information
  -- for a query is retained in the query store
  ,CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 7)

  -- Set the time interval at which runtime execution statistics data
  -- is aggregated into the Query Store
  ,INTERVAL_LENGTH_MINUTES = 1

  -- Determines the frequency at which data written to the query store is persisted to disk
  ,DATA_FLUSH_INTERVAL_SECONDS = 60

  ,QUERY_CAPTURE_MODE = ALL
);
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

DBCC DROPCLEANBUFFERS;
GO

DBCC FREEPROCCACHE;
GO

ALTER DATABASE [AdventureWorks2016_EXT] SET AUTOMATIC_TUNING(FORCE_LAST_GOOD_PLAN = ON);
GO


-- XE capture
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'CEFeedback_datasat80')
  DROP EVENT SESSION [CEFeedback_datasat80] ON SERVER 
GO

CREATE EVENT SESSION [CEFeedback_datasat80] ON SERVER 
  ADD EVENT
    sqlserver.query_feedback_analysis(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed, sqlserver.sql_text))
  ,ADD EVENT
    sqlserver.query_feedback_validation(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed, sqlserver.sql_text))
  ADD TARGET
    package0.event_file(SET FILENAME=N'CEFeedback_datasat80', MAX_FILE_SIZE=(10), MAX_ROLLOVER_FILES=(2))
WITH
  (
    MAX_MEMORY=4096 KB
    ,EVENT_RETENTION_MODE=NO_EVENT_LOSS
    ,MAX_DISPATCH_LATENCY=1 SECONDS
    ,MAX_EVENT_SIZE=0 KB
    ,MEMORY_PARTITION_MODE=NONE
    ,TRACK_CAUSALITY=OFF
    ,STARTUP_STATE=OFF
  );
GO

-- Start XE
ALTER EVENT SESSION [CEFeedback_datasat80] ON SERVER
  STATE = START;
GO


USE [AdventureWorks2016_EXT];
GO


-- CE feedback is only triggered for queries that are considered "ad-hoc"
-- and that are executed more than once
SELECT
  AddressID
  ,AddressLine1
  ,AddressLine2
FROM Person.Address
WHERE
  StateProvinceID = 79
  AND City = 'Redmond';
GO 15


EXEC sp_query_store_flush_db;
GO

-- Plan
SELECT
  *
FROM
  sys.dm_exec_cached_plans AS cplans
CROSS APPLY
  sys.dm_exec_sql_text(cplans.plan_handle) AS stext
CROSS APPLY
  sys.dm_exec_query_plan_stats(cplans.plan_handle) AS qplansstats
WHERE
  stext.[text] LIKE '%FROM Person.Address%'
  AND stext.[text] NOT LIKE '%sys.dm_exec_cached_plans%'
  AND stext.[text] NOT LIKE '%sys.query_store_query_text%';
GO

-- Query
SELECT
  q.query_id
  ,qt.query_text_id
  ,qt.query_sql_text
  ,qt.statement_sql_handle
FROM
  sys.query_store_query_text AS qt
join
  sys.query_store_query AS q on qt.query_text_id = q.query_text_id
WHERE
  query_sql_text LIKE '%FROM Person.Address%'
  AND query_sql_text NOT LIKE '%sys.query_store_query_text%'
  AND query_sql_text NOT LIKE '%sys.dm_exec_query_plan_stats%';
GO


-- Repeat the query again
-- query_feedback_analysis
SELECT
  AddressID
  ,AddressLine1
  ,AddressLine2
FROM Person.Address
WHERE
  StateProvinceID = 79
  AND City = 'Redmond';
GO


-- Repeat the query again
-- query_feedback_validation
SELECT
  AddressID
  ,AddressLine1
  ,AddressLine2
FROM Person.Address
WHERE
  StateProvinceID = 79
  AND City = 'Redmond';
GO


ALTER EVENT SESSION [CEFeedback_datasat80] ON SERVER
  STATE = STOP;
GO


SELECT * FROM sys.query_store_query_hints;
GO

SELECT * FROM sys.query_store_plan_feedback;
GO