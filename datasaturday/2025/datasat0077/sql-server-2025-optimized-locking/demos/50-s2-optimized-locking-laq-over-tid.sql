------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2025, November 29                --
--               https://bit.ly/43exQYm                               --
--                                                                    --
-- Session:      SQL Server 2025: Optimized Locking in action         --
--                                                                    --
-- Demo:         Lock after qualification over Transaction ID locking --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [OptimizedLocking];
GO


SELECT @@SPID;
GO

/* Session 2 */

BEGIN TRANSACTION;

UPDATE
  dbo.EventCounters
SET
  CounterValue = CounterValue + 10
WHERE
  EventID = 1;

ROLLBACK;
GO