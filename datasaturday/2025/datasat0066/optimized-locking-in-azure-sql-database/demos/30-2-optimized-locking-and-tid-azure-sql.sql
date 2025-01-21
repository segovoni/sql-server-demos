------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Optimized locking and transaction ID (TID) locking   --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Azure SQL Database
-- Connect to OptimizedLocking database
/*
USE [OptimizedLocking];
GO
*/

/*
ALTER DATABASE CURRENT SET ACCELERATED_DATABASE_RECOVERY = ON;
ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = OFF;
GO
*/

-- A complete view
SELECT
  IsOptimizedLockingOn = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn')
  ,RCSI = is_read_committed_snapshot_on
  ,ADR  = is_accelerated_database_recovery_on
 FROM
   sys.databases
 WHERE
   (name = DB_NAME());
GO


DROP TABLE IF EXISTS dbo.TableA;

CREATE TABLE dbo.TableA
(
  ColumnA INTEGER PRIMARY KEY NOT NULL,
  ColumnB INTEGER NOT NULL
);

INSERT INTO dbo.TableA VALUES (1, 10),(2, 20),(3, 30);
GO

-- Inspect locks with sys.dm_tran_locks on updated rows
BEGIN TRANSACTION;

UPDATE
  dbo.TableA
SET
  ColumnB = ColumnB + 10;

SELECT
  *
FROM
  sys.dm_tran_locks
WHERE
  request_session_id = @@SPID
AND
  resource_type IN ('PAGE','RID','KEY','XACT');

COMMIT TRANSACTION;
GO

DROP TABLE IF EXISTS dbo.TableA;
GO