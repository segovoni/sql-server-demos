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


/* Session 2 */
BEGIN TRANSACTION;

UPDATE
  dbo.TableC
SET
  CounterValue = CounterValue + 10
WHERE
  ID = 1;

ROLLBACK;