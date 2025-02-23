------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
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


DROP TABLE IF EXISTS dbo.TableC;

CREATE TABLE dbo.TableC
(
  ID INTEGER NOT NULL,
  CounterValue INTEGER NULL
);

INSERT INTO dbo.TableC VALUES (1, 10), (2, 20), (3, 30);
GO


/* Session 1 */
BEGIN TRANSACTION;

UPDATE
  dbo.TableC
SET
  CounterValue = CounterValue + 10
WHERE
  ID = 1;

SELECT
  *
FROM
  sys.dm_tran_locks
WHERE
  request_session_id IN (68, @@SPID)
  AND resource_type IN ('PAGE', 'RID', 'KEY', 'XACT');

ROLLBACK;