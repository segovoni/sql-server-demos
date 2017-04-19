------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      DMVs for Performance Tuning                           -
-- Demo:         Connessioni attive e richieste in corso               -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [master];
GO


-- Chi è connesso all'istanza in questo momento?
-- Restituisce informazioni sulle connessioni attive
SELECT * FROM sys.dm_exec_connections;
GO


SELECT
  session_id
  ,most_recent_session_id
  ,most_recent_sql_handle
  ,connect_time
  ,num_reads
  ,num_writes
  ,last_read
  ,last_write
FROM
  sys.dm_exec_connections;
GO


-- Quali sono le sessioni attive?
-- Restituisce informazioni su tutte le attività,
-- utilizzata per visualizzare il carico di lavoro del sistema
-- in un determinato momento e individuare una sessione
SELECT * FROM sys.dm_exec_sessions WHERE (is_user_process = 1);
GO


-- Numero di connessioni attive per IP
SELECT
  num_connection = COUNT(c.session_id)
  ,c.client_net_address
  ,s.[program_name]
  ,s.[host_name]
  ,s.login_name
FROM
  sys.dm_exec_sessions s
JOIN
  sys.dm_exec_connections c ON s.session_id=c.session_id
GROUP BY
  c.client_net_address
  ,s.[program_name]
  ,s.[host_name]
  ,s.login_name
HAVING
  (COUNT(c.session_id) > 2);
GO


-- Utenti connessi e numero di sessioni attive
SELECT
  login_name
  ,n_active_session = COUNT(session_id)
FROM
  sys.dm_exec_sessions
GROUP BY
  login_name
ORDER BY
  COUNT(session_id) DESC;
GO


-- Quali sono le richieste in corso?
-- Restituisce informazioni su ogni richiesta in esecuzione
SELECT
  *
FROM
  sys.dm_exec_requests
WHERE
  (session_id > 50)
  and (session_id <> @@SPID);
GO

SELECT * FROM sys.dm_exec_sql_text(0x0200000040E79B0EC2AA431DF552FF4DE86A93FF6376862F0000000000000000000000000000000000000000)


-- Ho eseguito DBCC CHECKDB in produzione, durante la pausa pranzo,
-- mancano 5 minuti al termine del0x0200000040E79B0EC2AA431DF552FF4DE86A93FF6376862F0000000000000000000000000000000000000000la pausa pranzo, a che punto è l'analisi?
SELECT
  percent_complete
  ,cpu_time
  ,row_count
  ,session_id
  ,start_time
  ,command
  ,status
  ,DBNAME = DB_NAME(database_id)
  ,wait_type
  ,wait_time
  ,wait_resource
  ,prev_error
FROM
  sys.dm_exec_requests
WHERE
  (session_id > 50)
  and (session_id <> @@SPID);
GO




-- http://sqlblog.com/blogs/adam_machanic/archive/tags/sp_5F00_whoisactive/default.aspx
-- sp_WhoIsActive
EXEC master.dbo.sp_WhoIsActive;
GO




-- Lock
BEGIN TRANSACTION;

UPDATE [dbo].[E_ADDRESS] SET [AD_ZC_CODE] = '12236' WHERE [AD_ID] = 4;

ROLLBACK;


SELECT * FROM [dbo].[E_ADDRESS];
GO


-- E' stato acquisito un lock, una o più query sono bloccate
-- Cosa sta succedendo?
SELECT
  s.session_id
  ,r.blocking_session_id
  ,s.program_name
  ,r.sql_handle
  ,r.plan_handle
  ,r.command
  ,r.wait_type
  ,r.wait_time
  ,r.open_transaction_count
  ,s.host_name
  ,s.login_name
  ,[session status] = s.status
  ,[request status] = r.status
  ,s.last_request_start_time
  ,DBNAME = DB_NAME(r.database_id)
  ,r.wait_type
  ,r.wait_time
  ,r.wait_resource
  ,r.prev_error
FROM
  sys.dm_exec_sessions s
JOIN
  sys.dm_exec_requests r ON r.session_id=s.session_id
WHERE
  (s.is_user_process = 1)
  AND (s.session_id <> @@SPID);
GO


SELECT
  *
FROM
  sys.dm_exec_requests
WHERE
  (session_id > 50)
  AND (session_id <> @@SPID)


-- Sessione che sta bloccando
SELECT
  *
FROM
  sys.dm_exec_sessions
WHERE
  (session_id = 78);
GO


-- Recuperiamo l'handle del comando SQL (già concluso)
-- la cui transazione sta bloccando una o più query
SELECT
  session_id
  ,most_recent_sql_handle
FROM
  sys.dm_exec_connections
WHERE
  (session_id = 78);
GO


SELECT * FROM sys.dm_exec_sql_text(0x020000005D17FC06DCF23B0F29011D9F9EA11ECD983708CA0000000000000000000000000000000000000000)

SELECT * FROM sys.dm_exec_connections

-- Recuperiamo il testo del comando T-SQL e
-- il piano di esecuzione della query (già eseguita)
-- la cui transazione è in attesa di un Commit o di un Rollback
-- e genera il lock
SELECT
  qt.text
  ,qp.query_plan
  ,qs.*
FROM
  sys.dm_exec_query_stats AS qs
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (sql_handle = 0x020000005D17FC06DCF23B0F29011D9F9EA11ECD983708CA0000000000000000000000000000000000000000)
GO



-- Richieste bloccate con informazioni sul testo
-- del comando T-SQL e sul piano di esecuzione
SELECT
  s.session_id
  ,r.blocking_session_id
  ,t.text
  ,p.query_plan
  ,s.login_time
  ,s.host_name
  ,s.program_name
  ,s.login_name
  ,s.status
  ,s.last_request_start_time
  ,s.reads
  ,s.logical_reads
  ,r.command
  ,r.wait_type
  ,r.wait_time
  ,r.open_transaction_count
  ,r.sql_handle
  ,r.query_plan_hash
FROM
  sys.dm_exec_sessions s
JOIN
  sys.dm_exec_requests r on r.session_id=s.session_id
CROSS APPLY
  sys.dm_exec_sql_text(r.sql_handle) as t
CROSS APPLY
  sys.dm_exec_query_plan(r.plan_handle) as p
WHERE
  (s.is_user_process = 1)
  AND (r.blocking_session_id > 0);
GO


-- http://www.sommarskog.se/sqlutil/beta_lockinfo.html

EXEC master.dbo.beta_lockinfo;
GO



-- Siamo ora interessati alle query in attesa
-- Ci sono richieste in attesa? Perchè?
SELECT
  *
FROM
  sys.dm_os_waiting_tasks
WHERE
  (session_id > 50);
GO


SELECT
  s.session_id
  ,w.blocking_session_id
  ,s.program_name
  ,s.last_request_start_time
  ,w.waiting_task_address
  ,w.blocking_task_address
  ,w.wait_type
  ,w.wait_duration_ms
  ,w.resource_description
  ,w.resource_address
  ,s.login_time
  ,s.host_name
FROM
  sys.dm_os_waiting_tasks w
JOIN
  sys.dm_exec_sessions s ON s.session_id=w.session_id
WHERE
  (s.is_user_process = 1);
GO


SELECT
  request_session_id
  ,DB_NAME(resource_database_id) AS DB
  ,resource_type
  ,resource_subtype
  ,request_type
  ,request_mode
  ,resource_description
  ,request_mode
  ,request_owner_type
FROM
  sys.dm_tran_locks
WHERE
  (request_session_id > 50)
  AND (resource_database_id = DB_ID('TPC-E'))
  AND (request_session_id <> @@SPID)
ORDER BY
  request_session_id;
GO


-- Looks
SELECT
  tl.resource_type
  ,tl.resource_database_id
  ,tl.resource_associated_entity_id
  ,tl.request_mode
  ,tl.request_session_id
  ,wt.blocking_session_id
  ,wt.wait_type
  ,wt.wait_duration_ms
FROM
  sys.dm_tran_locks AS tl
JOIN
  sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
ORDER BY
  wait_duration_ms DESC;
GO