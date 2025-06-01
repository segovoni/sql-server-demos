------------------------------------------------------------------------
-- Event:        SQL Start 2025 - June 13                             --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      How SQL Server 2025 improves concurrency             --
--               with Transaction ID Locking and LAQ                  --
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