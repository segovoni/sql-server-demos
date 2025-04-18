------------------------------------------------------------------------
-- Event:        Global Azure 2025 Veneto, May 09, Vicenza            --
--               https://veneto.globalazure.it/                       --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Behavior changes with optimized locking and RCSI     --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

/*
USE [StackOverflow2010];
GO
*/

DROP TABLE IF EXISTS dbo.TableD;

CREATE TABLE dbo.TableD
(
  ID INTEGER PRIMARY KEY NOT NULL,
  CounterValue INTEGER NOT NULL
);

INSERT INTO dbo.TableD VALUES (1, 1);
GO

/* Session 1 */
BEGIN TRANSACTION T1;

UPDATE
  dbo.TableD
SET
  CounterValue = 2
WHERE
  ID = 1;

/* Session 2 */
BEGIN TRANSACTION T2;

UPDATE
  dbo.TableD
SET
  CounterValue = 3
WHERE
  CounterValue = 2;