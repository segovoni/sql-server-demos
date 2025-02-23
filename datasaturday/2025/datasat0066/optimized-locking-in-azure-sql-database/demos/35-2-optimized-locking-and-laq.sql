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


/* Session 2 */

-- Without optimized locking, session 2 is blocked because session 1 holds a U lock
-- on the row session 2 needs to update (qualification)

-- With optimized locking, session 2 isn't blocked because U locks
-- aren't taken, and because in the latest committed version of row 1, 
-- column ID equals to 1, which doesn't satisfy the predicate of session 2

SELECT @@SPID;
GO

BEGIN TRANSACTION;

UPDATE
  dbo.TableB
SET
  CounterValue = CounterValue + 10
WHERE
  ID = 2;

ROLLBACK;
GO