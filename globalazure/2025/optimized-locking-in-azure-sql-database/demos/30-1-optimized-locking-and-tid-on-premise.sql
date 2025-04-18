------------------------------------------------------------------------
-- Event:        Global Azure 2025 Veneto, May 09, Vicenza            --
--               https://veneto.globalazure.it/                       --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Optimized locking and transaction ID (TID) locking   --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- On-premises SQL Server 2022
USE [OptimizedLocking];
GO

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


-- Enable trace flags 3604 and 1200 (globally)

-- Trace flag 3604 prints output to the console
DBCC TRACEON(3604)
-- Trace flag 1200 prints detailed lock information
DBCC TRACEON(1200, -1);
GO

DBCC TRACESTATUS;
GO
DBCC TRACEOFF(1200, -1);
GO


DROP TABLE IF EXISTS dbo.TableA;

CREATE TABLE dbo.TableA
(
  ColumnA INTEGER PRIMARY KEY NOT NULL,
  ColumnB INTEGER NOT NULL
);

INSERT INTO dbo.TableA VALUES (1, 10),(2, 20),(3, 30);
GO


-- Inspect page ID with sys.fn_PhysLocFormatter and DBCC PAGE
SELECT
  *
  ,PageId = sys.fn_PhysLocFormatter(%%physloc%%)
FROM
  dbo.TableA
GO

/*
DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])
*/
-- (1:568:0)
DBCC PAGE ('OptimizedLocking', 1, 568, 3);
GO

/*
(8194443284a0)                                                                                                                                                                                                                                                  
(61a06abd401c)                                                                                                                                                                                                                                                  
(98ec012aa510)                                                                                                                                                                                                                                                  
*/


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

COMMIT;
GO

DROP TABLE IF EXISTS dbo.TableA;
GO