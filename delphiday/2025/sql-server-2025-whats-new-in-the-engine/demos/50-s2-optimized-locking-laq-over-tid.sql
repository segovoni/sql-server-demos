------------------------------------------------------------------------
-- Event:        Delphi Day 2025 - June 19-20                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      SQL Server 2025: What's new in the database Engine   --
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