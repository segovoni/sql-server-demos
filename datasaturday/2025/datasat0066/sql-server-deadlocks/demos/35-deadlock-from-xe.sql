------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         Deadlocks on extended events                         --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [master];
GO

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'deadlock_catcher')
  DROP EVENT SESSION [deadlock_catcher] ON SERVER 
GO

CREATE EVENT SESSION [deadlock_catcher] ON SERVER 
  ADD EVENT
    sqlserver.database_xml_deadlock_report(ACTION(sqlserver.sql_text))
  ,ADD EVENT
    sqlserver.lock_deadlock(ACTION(sqlserver.sql_text))
  ,ADD EVENT
    sqlserver.lock_deadlock_chain(ACTION(sqlserver.sql_text))
  
  ADD TARGET
    package0.event_file(SET filename=N'deadlock_catcher', max_file_size=(10), max_rollover_files=(2))
WITH
  (
    MAX_MEMORY=4096 KB
    ,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS
    ,MAX_DISPATCH_LATENCY=30 SECONDS
    ,MAX_EVENT_SIZE=0 KB
    ,MEMORY_PARTITION_MODE=NONE
    ,TRACK_CAUSALITY=OFF
    ,STARTUP_STATE=ON
  )
GO

/*
SELECT
  p.name AS [Package-Name]
  ,o.object_type
  ,o.name AS [Object-Name]
  ,o.description AS [Object-Descr]
  ,p.guid AS [Package-Guid]
FROM
  sys.dm_xe_packages AS p
INNER JOIN
  sys.dm_xe_objects AS o ON p.guid = o.package_guid
WHERE
  o.object_type = 'event'
  AND p.name LIKE '%'
  AND o.name LIKE '%deadlock%'
ORDER BY
  p.name
  ,o.object_type
  ,o.name;
*/

SELECT
  s.name
  ,t.target_name
  ,CAST(t.target_data AS XML) AS [XML-Cast]
FROM
  sys.dm_xe_session_targets AS t
JOIN
  sys.dm_xe_sessions AS s ON s.address = t.event_session_address
WHERE
  s.name = 'deadlock_catcher';
GO


SELECT
  --f.module_guid
  --,f.package_guid
  f.timestamp_utc
  ,f.object_name
  ,f.file_name
  ,f.file_offset
  ,CAST(f.event_data AS XML) AS [Event-Data-As-XML]
FROM
  sys.fn_xe_file_target_read_file('deadlock_catcher_0_133748868416980000.xel', NULL, NULL, NULL) AS f;
GO