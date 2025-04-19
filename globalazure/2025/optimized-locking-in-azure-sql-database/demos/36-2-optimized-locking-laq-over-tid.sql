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