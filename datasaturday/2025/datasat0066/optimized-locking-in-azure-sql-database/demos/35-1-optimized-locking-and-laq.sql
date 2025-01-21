------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
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

DROP TABLE IF EXISTS dbo.TableB;

CREATE TABLE dbo.TableB
(
  ID INTEGER NOT NULL,
  CounterValue INTEGER NULL
);

INSERT INTO dbo.TableB VALUES (1, 10), (2, 20), (3, 30);
GO


BEGIN TRANSACTION;

UPDATE
  dbo.TableB
SET
  CounterValue = CounterValue + 10
WHERE
  ID = 1;


SELECT
  *
FROM
  sys.dm_tran_locks
WHERE
  request_session_id IN (58, @@SPID)
  AND resource_type IN ('PAGE','RID','KEY','XACT');

ROLLBACK;