------------------------------------------------------------------------
-- Event:        Global Azure 2025 Veneto, May 09, Vicenza            --
--               https://veneto.globalazure.it/                       --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Lock after qualification over Transaction ID locking --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [OptimizedLocking];
GO


DROP TABLE IF EXISTS dbo.EventCounters;

CREATE TABLE dbo.EventCounters
(
  EventID INTEGER NOT NULL,
  CounterValue INTEGER NULL
);

INSERT INTO dbo.EventCounters VALUES (1, 10), (2, 20), (3, 30);
GO


/* Session 1 */
BEGIN TRANSACTION;

UPDATE
  dbo.EventCounters
SET
  CounterValue = CounterValue + 10
WHERE
  EventID = 1;

SELECT
  *
FROM
  sys.dm_tran_locks
WHERE
  request_session_id IN (68, @@SPID)
  AND resource_type IN ('PAGE', 'RID', 'KEY', 'XACT');

ROLLBACK;