------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      DMVs for Performance Tuning                           -
-- Demo:         Most costly queries                                   -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [TPC-E];
GO


-- Restituisce indicazioni sulle performance delle query recenti,
-- il cui piano di esecuzione è ancora in cache
SELECT
  dm_eqs.*
FROM
  sys.dm_exec_query_stats AS dm_eqs;
GO

/*
SELECT
  dm_eqs.execution_count
  ,dm_eqs.total_worker_time
  ,dm_eqs.total_elapsed_time
  ,dm_eqs.total_logical_reads
  ,dm_eqs.total_logical_writes
  ,dm_eqs.query_hash
  ,dm_eqs.query_plan_hash
FROM
  sys.dm_exec_query_stats AS dm_eqs
ORDER BY
  --dm_eqs.execution_count desc
  dm_eqs.total_elapsed_time DESC;
GO
*/

-- Qual'è il testo della query?
SELECT
  TOP 10
  dm_est.text
  ,dm_eqs.execution_count
  ,dm_eqs.total_elapsed_time
  ,dm_eqs.max_elapsed_time
FROM
  sys.dm_exec_query_stats AS dm_eqs
CROSS APPLY
  sys.dm_exec_sql_text(dm_eqs.sql_handle) AS dm_est
ORDER BY
  dm_eqs.total_worker_time DESC;
  --dm_eqs.max_elapsed_time DESC;
GO



-- Piani di esecuzione delle query recenti
SELECT
  -- test
  TOP 20
  [size reads] = (dm_eqs.execution_count * dm_eqs.total_logical_reads) 
  ,[size CPU] = (dm_eqs.execution_count * dm_eqs.total_worker_time) 
  ,dm_est.text
  ,dm_eqp.query_plan
  ,dm_eqp.dbid
  ,dm_eqs.execution_count
  ,dm_eqs.total_worker_time
  ,dm_eqs.total_elapsed_time
  ,dm_eqs.max_elapsed_time
  ,dm_eqs.total_logical_reads
  ,dm_eqs.total_logical_writes
  ,dm_eqs.query_plan_hash
FROM
  sys.dm_exec_query_stats AS dm_eqs
CROSS APPLY
  sys.dm_exec_query_plan(dm_eqs.plan_handle) AS dm_eqp
CROSS APPLY
  sys.dm_exec_sql_text(dm_eqs.sql_handle) AS dm_est
WHERE
  (dm_eqp.dbid = (SELECT DB_ID()))
  AND (CHARINDEX('-- test', dm_est.text) = 0)
  --AND (CHARINDEX('update', dm_est.text) > 0)
ORDER BY
  [size reads] DESC;
GO


-- Top 10 query per last_logical_reads
SELECT
  TOP 20
  qp.query_plan
  ,st.text
  ,s.*
FROM
  sys.dm_exec_query_stats AS s
CROSS APPLY
  sys.dm_exec_query_plan(s.plan_handle) AS qp
CROSS APPLY
  sys.dm_exec_sql_text(s.sql_handle) AS st
ORDER BY
  s.last_logical_reads DESC;
GO




SELECT * FROM sys.dm_exec_query_memory_grants;
GO
SELECT * FROM sys.dm_exec_query_resource_semaphores;
GO


--
SELECT
  r.wait_type
  ,r.*
FROM
  sys.dm_exec_requests AS r
JOIN
  sys.dm_exec_sessions AS s ON s.session_id=r.session_id
WHERE
  (s.session_id > 50)
  AND (s.session_id <> @@SPID);
GO


-- Memory grants
SELECT
  -- test
  er.wait_type
  ,er.status
  ,mg.request_time
  ,mg.grant_time
  ,st.text
  ,qp.query_plan
  ,mg.is_next_candidate
  ,requested_memory_mb = (mg.requested_memory_kb / 1000.0)
  ,granted_memory_mb = (mg.granted_memory_kb / 1000.0) 
  ,mg.*
FROM
  sys.dm_exec_query_memory_grants AS mg
JOIN
  sys.dm_exec_requests AS er ON er.session_id = mg.session_id
CROSS APPLY
  sys.dm_exec_sql_text(mg.sql_handle) AS st
CROSS APPLY
  sys.dm_exec_query_plan(mg.plan_handle) AS qp
WHERE
  (CHARINDEX('-- test', st.text) = 0)
GO