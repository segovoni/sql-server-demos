------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2025, November 29                --
--               https://bit.ly/43exQYm                               --
--                                                                    --
-- Session:      SQL Server 2025: Optimized Locking in action         --
--                                                                    --
-- Demo:         Concurrent updates with LAQ (Session 2)              --
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
  dbo.SalesOrder
SET
  [Status] = 'C'
WHERE
  (CustomerID = 123)
  AND (TotalDue > 1000);

ROLLBACK;
GO