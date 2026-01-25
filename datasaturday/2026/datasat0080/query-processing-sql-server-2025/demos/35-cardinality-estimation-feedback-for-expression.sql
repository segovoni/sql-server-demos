------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2026, February 28            --
--               https://bit.ly/4qgoS6D                               --
--                                                                    --
-- Session:      Query Processing improvements in SQL Server 2025     --
--                                                                    --
-- Demo:         Cardinality estimation (CE) feedback for expression  --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [AdventureWorks2016_EXT];
GO


-- Prerequisites for CE feedback for expressions

-- Compatibility level 160 or later
ALTER DATABASE [AdventureWorks2016_EXT] SET COMPATIBILITY_LEVEL = 170 
GO
-- The CE_FEEDBACK_FOR_EXPRESSIONS database-scoped configuration must be enabled (enabled by default)
ALTER DATABASE SCOPED CONFIGURATION SET CE_FEEDBACK_FOR_EXPRESSIONS = ON;
GO

/*
ALTER DATABASE SCOPED CONFIGURATION SET CE_FEEDBACK_FOR_EXPRESSIONS = OFF;
GO
*/

-- XE capture
IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'CEFeedback_datasat80')
  DROP EVENT SESSION [CEFeedback_datasat80] ON SERVER 
GO

CREATE EVENT SESSION [CEFeedback_datasat80] ON SERVER 
  ADD EVENT
    sqlserver.query_feedback_analysis(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  ,ADD EVENT
    sqlserver.query_feedback_validation(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  -- CE feedback for expression
  ,ADD EVENT
    sqlserver.adhoc_ce_feedback_query_level_telemetry(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  ,ADD EVENT
    sqlserver.query_adhoc_ce_feedback_expression_hint(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  ,ADD EVENT
    sqlserver.query_ce_feedback_begin_analysis(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  ,ADD EVENT
    sqlserver.query_ce_feedback_telemetry(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  --,ADD EVENT
  --  sqlserver.query_adhoc_ce_feedback_hint(ACTION(sqlserver.query_hash_signed, sqlserver.query_plan_hash_signed,sqlserver.sql_text))
  ADD TARGET
    package0.event_file(SET filename=N'CEFeedback_datasat80', MAX_FILE_SIZE=(10), MAX_ROLLOVER_FILES=(2))
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


DBCC FREEPROCCACHE;
GO


-- Consider this query
SELECT
  *
FROM
  Sales.Customer AS C
INNER JOIN
  Sales.SalesOrderHeader AS O ON C.CustomerID = O.CustomerID
WHERE
  O.TotalDue > 10000;
GO


SELECT
  *
FROM
  sys.query_store_query_text
WHERE
  query_sql_text LIKE '%O.TotalDue >%'
  AND query_sql_text NOT LIKE '%sys.query_store_query_text%';
GO


-- Each logical expression such as a filter or join within a query plan generates
-- a signature that contributes to a fingerprint. CE Feedback for expressions
-- uses these fingerprints to learn and apply feedback across queries that share 
-- similar subexpressions, even if the overall query structure is different

-- Fingerprint cannot be directly decrypted to retrieve the original SQL expression
SELECT
  *
FROM
  sys.dm_exec_ce_feedback_cache
WHERE
  fingerprint = 0x55E5FFF3C54D81DA AND
  database_id = DB_ID('AdventureWorks2016_EXT');
GO


ALTER EVENT SESSION [CEFeedback_datasat80] ON SERVER
  STATE = STOP;
GO

/*
SELECT * FROM sys.plan_persist_ce_feedback_for_expressions;
GO
*/