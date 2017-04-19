------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      DMVs for Performance Tuning                           -
-- Demo:         Trigger                                               -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [TPC-E];
GO

-- Statistiche di esecuzione Trigger (SQL Server 2008+)
SELECT * FROM sys.triggers;
SELECT * FROM sys.dm_exec_trigger_stats;
GO

SELECT
  t.name
  ,OBJECT_NAME(t.parent_id) AS table_name
  ,w_twt = (ets.execution_count * ets.total_worker_time)
  ,w_tlr = (ets.execution_count * ets.total_logical_reads)
  ,w_tet = (ets.execution_count * ets.total_elapsed_time)
  ,t.modify_date
  ,t.is_instead_of_trigger
  ,t.is_ms_shipped
  ,ets.execution_count
  ,avg_elapsed_time = (ets.total_elapsed_time/ets.execution_count)
  ,ets.total_worker_time
  ,ets.last_worker_time
  ,ets.min_worker_time
  ,ets.max_worker_time
  ,ets.total_physical_reads
  ,ets.last_physical_reads
  ,ets.min_physical_reads
  ,ets.max_physical_reads
  ,ets.total_logical_writes
  ,ets.last_logical_writes
  ,ets.min_logical_writes
  ,ets.max_logical_writes
  ,ets.total_logical_reads
  ,ets.last_logical_reads
  ,ets.min_logical_reads
  ,ets.max_logical_reads
  ,ets.total_elapsed_time
  ,ets.last_elapsed_time
  ,ets.min_elapsed_time
  ,ets.max_elapsed_time
FROM
  sys.triggers AS t
JOIN
  sys.dm_exec_trigger_stats AS ets ON ets.[object_id]=t.[object_id]
ORDER BY
  w_twt DESC;
GO


-- Testo e piano di esecuzione
SELECT
  t.name
  ,OBJECT_NAME(t.parent_id) AS table_name
  ,w_twot = (ets.execution_count * ets.total_worker_time)
  ,w_tlor = (ets.execution_count * ets.total_logical_reads)
  ,w_telt = (ets.execution_count * ets.total_elapsed_time)
  ,eqt.text AS [text]
  ,eqp.query_plan AS [plan]
  ,t.modify_date
  ,ets.execution_count
  ,ets.total_worker_time
  ,ets.total_physical_reads
  ,ets.total_logical_writes
  ,ets.total_logical_reads
  ,ets.total_elapsed_time
FROM
  sys.triggers AS t
JOIN
  sys.dm_exec_trigger_stats AS ets ON ets.[object_id]=t.[object_id]
CROSS APPLY
  sys.dm_exec_sql_text(ets.sql_handle) AS eqt
CROSS APPLY
  sys.dm_exec_query_plan(ets.plan_handle) AS eqp
ORDER BY
  w_twot DESC;
GO