------------------------------------------------------------------------
-- Event:        SQL Saturday #264 - Ancona
-- Session:      Trigger: Utili o Dannosi?
-- Demo:         Statistiche di esecuzione
-- Author:       Sergio Govoni
-- Notes:        -
------------------------------------------------------------------------

USE [AdventureWorks2012];
GO

------------------------------------------------------------------------
-- Statistiche di esecuzione Trigger
------------------------------------------------------------------------

SELECT * FROM sys.dm_exec_trigger_stats;
GO


SELECT
  OBJECT_NAME(trs.object_id, trs.database_id) AS trigger_name
  ,t.text
  ,trs.last_execution_time
  ,trs.execution_count
  ,trs.total_elapsed_time
  ,trs.last_elapsed_time
  ,(trs.total_elapsed_time/trs.execution_count) AS avg_elapsed_time
  ,p.query_plan
  --,trs.*
FROM
  sys.dm_exec_trigger_stats  AS trs
CROSS APPLY
  sys.dm_exec_sql_text(trs.sql_handle) AS t
CROSS APPLY
  sys.dm_exec_query_plan(trs.plan_handle) AS p
ORDER BY
  trs.total_worker_time DESC;
GO


SELECT * FROM sys.triggers;
SELECT * FROM sys.server_triggers;