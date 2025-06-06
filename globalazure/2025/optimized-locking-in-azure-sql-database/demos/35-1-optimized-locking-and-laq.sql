------------------------------------------------------------------------
-- Event:        Global Azure 2025 Veneto, May 09, Vicenza            --
--               https://veneto.globalazure.it/                       --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Optimized locking and lock after qualification (LAQ) --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [OptimizedLocking];
GO


/* Session 1 */

DROP TABLE IF EXISTS dbo.EntityCounters;

CREATE TABLE dbo.EntityCounters
(
  EntityID INTEGER NOT NULL,
  CounterValue INTEGER NULL
);


INSERT INTO dbo.EntityCounters VALUES (1, 10), (2, 20), (3, 30);
GO


BEGIN TRANSACTION;

UPDATE
  dbo.EntityCounters
SET
  CounterValue = CounterValue + 10
WHERE
  EntityID = 1;


SELECT
  resource_type
  ,resource_database_id
  ,resource_description
  ,request_mode
  ,request_type
  ,request_status
  ,request_session_id
  ,resource_associated_entity_id
FROM
  sys.dm_tran_locks
WHERE
  request_session_id IN (74, @@SPID)
  AND resource_type IN ('PAGE', 'RID', 'KEY', 'XACT');


ROLLBACK;