------------------------------------------------------------------------
-- Event:        SQL Start 2025 - June 13                             --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      How SQL Server 2025 improves concurrency             --
--               with Transaction ID Locking and LAQ                  --
--                                                                    --
-- Demo:         Monitoring locks and waits                           --
-- Author:       Sergio Govoni                                        --
-- Notes:        Credits to Aaron Bertrand                            --
--               www.red-gate.com/simple-talk/author/aaron-bertrand   --
------------------------------------------------------------------------
 
USE [StackOverflow2010];
GO


-- Azure SQL default time zone is UTC
WAITFOR TIME '11:53';

DROP TABLE IF EXISTS #LockStatus;
GO

CREATE TABLE #LockStatus
 (
   event_time DATETIME2
   , spid SMALLINT
   , resource_type NVARCHAR(60)
   , request_mode NVARCHAR(60)
   , resource_description NVARCHAR(MAX)
 );
 
DROP TABLE IF EXISTS #WaitStatus;

CREATE TABLE #WaitStatus
(
  event_time DATETIME2
  , spid SMALLINT
  , wait_type NVARCHAR(60)
  , wait_time_ms BIGINT
  , [status] NVARCHAR(30)
  , blocker SMALLINT
  , wait_resource NVARCHAR(256)
);

DROP TABLE IF EXISTS #PerformanceCounterStatus;

CREATE TABLE #PerformanceCounterStatus
(
  counter_name NCHAR(128) 
  , cntr_value BIGINT 
  , counter_time DATETIME2 
);
INSERT INTO #PerformanceCounterStatus
(
  counter_name 
  , cntr_value 
  , counter_time 
)
SELECT
  counter_name
  , cntr_value
  , SYSUTCDATETIME()
FROM
  sys.dm_os_performance_counters 
WHERE
  counter_name = N'Lock Memory (KB)';

DROP TABLE IF EXISTS #SPIDToMonitor;

CREATE TABLE #SPIDToMonitor
(
  spid SMALLINT
);
INSERT #SPIDToMonitor VALUES (155), (165);


GO
DECLARE @now DATETIME2 = SYSUTCDATETIME();

INSERT #LockStatus 
SELECT
  @now
  , request_session_id 
  , resource_type 
  , request_mode 
  , resource_description
 FROM
   sys.dm_tran_locks
 WHERE
   resource_database_id = DB_ID(N'StackOverflow2010')
 AND
   request_session_id IN (SELECT spid FROM #SPIDToMonitor)
 AND
   resource_type <> N'DATABASE';

INSERT #WaitStatus
SELECT
  @now 
  , ws.[session_id] 
  , ws.wait_type 
  , ws.wait_time_ms
  , r.[status] 
  , r.blocking_session_id 
  , r.wait_resource
FROM
  sys.dm_exec_session_wait_stats AS ws
LEFT OUTER JOIN
  sys.dm_exec_requests AS r ON ws.[session_id] = r.[session_id]
WHERE
  ws.[session_id] IN (SELECT spid FROM #SPIDToMonitor)
AND
  ws.wait_time_ms >= 1000
AND
  ws.wait_type <> N'WAITFOR';

WAITFOR DELAY '00:00:00.25';
GO 500


SELECT
  spid 
  , rt = CASE resource_type 
           /* XACT = TID, else key/page = more granular lock (key/page) */
           WHEN 'XACT' THEN 'XACT' ELSE 'key/page'
         END 
  , LockCount = COUNT(*)
FROM
  #LockStatus
GROUP BY
  spid
  , CASE resource_type 
      WHEN 'XACT' THEN 'XACT' ELSE 'key/page'
    END;

SELECT
  spid 
  , wait_type 
  , WaitTime = MAX(wait_time_ms)
FROM
  #WaitStatus
GROUP BY
  spid
  , wait_type;

INSERT INTO #PerformanceCounterStatus
(
  counter_name 
  , cntr_value 
  , counter_time 
)
SELECT
  counter_name
  , cntr_value
  , SYSUTCDATETIME()
FROM
  sys.dm_os_performance_counters 
WHERE
  counter_name = N'Lock Memory (KB)';

SELECT
  *
FROM
  #PerformanceCounterStatus;
GO