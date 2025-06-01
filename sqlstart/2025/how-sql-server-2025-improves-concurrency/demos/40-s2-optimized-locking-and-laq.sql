------------------------------------------------------------------------
-- Event:        SQL Start 2025 - June 13                             --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      How SQL Server 2025 improves concurrency             --
--               with Transaction ID Locking and LAQ                  --
--                                                                    --
-- Demo:         Optimized locking and lock after qualification (LAQ) --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [OptimizedLocking];
GO

/* Session 2 */

-- Without optimized locking, session 2 is blocked because session 1 holds a U lock
-- on the row session 2 needs to update (qualification)

-- With optimized locking, session 2 isn't blocked because U locks
-- aren't taken, and because in the latest committed version of row 1, 
-- column EntityID equals to 1, which doesn't satisfy the predicate of session 2

SELECT @@SPID;
GO

BEGIN TRANSACTION;

UPDATE
  dbo.EntityCounters
SET
  CounterValue = CounterValue + 10
WHERE
  EntityID = 2;

ROLLBACK;
GO