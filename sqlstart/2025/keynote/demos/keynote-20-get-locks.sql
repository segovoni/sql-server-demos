------------------------------------------------------------------------
-- Event:        SQL Start 2025 - June 13                             --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      Keynote                                              --
--                                                                    --
-- Demo:         SQL Server 2025, Database Engine, Optimized Locking  --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [StackOverflow2010];
GO


-- Get locks
SELECT 
  T.resource_type,
  T.resource_database_id,
  resource_database_name = DB_NAME(T.resource_database_id),
  T.resource_associated_entity_id,
  resource_associated_entity_name = O.[name],
  -- T.resource_description,
  T.request_mode,
  T.request_session_id,
  T.request_status,
  COUNT(*) AS lock_count
FROM 
  sys.dm_tran_locks AS T
LEFT OUTER JOIN sys.sysobjects
  AS O ON T.resource_associated_entity_id=O.id
GROUP BY 
  T.resource_type,
  T.resource_database_id,
  T.resource_associated_entity_id,
  O.[name],
  T.request_mode,
  T.request_session_id,
  T.request_status
ORDER BY 
  T.resource_type,
  T.resource_database_id,
  T.resource_associated_entity_id,
  T.request_mode,
  T.request_session_id,
  T.request_status;
GO