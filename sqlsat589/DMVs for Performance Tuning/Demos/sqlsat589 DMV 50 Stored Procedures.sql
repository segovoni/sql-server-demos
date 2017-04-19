------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      DMVs for Performance Tuning                           -
-- Demo:         Stored Procedure                                      -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [TPC-E];
GO

-- Statistiche di esecuzione Stored Procedure (SQL Server 2008+)
SELECT * FROM sys.procedures;
SELECT * FROM sys.dm_exec_procedure_stats;
GO

SELECT
  p.name
  ,w_twt = (eps.execution_count * eps.total_worker_time)
  ,w_tlr = (eps.execution_count * eps.total_logical_reads)
  ,w_tet = (eps.execution_count * eps.total_elapsed_time)
  ,p.modify_date
  ,p.is_ms_shipped
  ,eps.execution_count
  ,eps.total_worker_time
  ,eps.last_worker_time
  ,eps.min_worker_time
  ,eps.max_worker_time
  ,eps.total_physical_reads
  ,eps.last_physical_reads
  ,eps.min_physical_reads
  ,eps.max_physical_reads
  ,eps.total_logical_writes
  ,eps.last_logical_writes
  ,eps.min_logical_writes
  ,eps.max_logical_writes
  ,eps.total_logical_reads
  ,eps.last_logical_reads
  ,eps.min_logical_reads
  ,eps.max_logical_reads
  ,eps.total_elapsed_time
  ,eps.last_elapsed_time
  ,eps.min_elapsed_time
  ,eps.max_elapsed_time
FROM
  sys.procedures AS p
JOIN
  sys.dm_exec_procedure_stats AS eps ON eps.[object_id]=p.[object_id]
ORDER BY
  w_twt DESC;
GO


-- Testo e piano di esecuzione
SELECT
  p.name
  ,w_twt = (eps.execution_count * eps.total_worker_time)
  ,w_tlr = (eps.execution_count * eps.total_logical_reads)
  ,w_tet = (eps.execution_count * eps.total_elapsed_time)
  ,eqt.text AS [text]
  ,eqp.query_plan AS [plan]
  ,p.modify_date
  ,eps.execution_count
  ,eps.total_worker_time
  ,eps.total_physical_reads
  ,eps.total_logical_writes
  ,eps.total_logical_reads
  ,eps.total_elapsed_time
FROM
  sys.procedures AS p
JOIN
  sys.dm_exec_procedure_stats AS eps ON eps.[object_id]=p.[object_id]
CROSS APPLY
  sys.dm_exec_sql_text(eps.sql_handle) AS eqt
CROSS APPLY
  sys.dm_exec_query_plan(eps.plan_handle) AS eqp
ORDER BY
  w_twt DESC;
GO