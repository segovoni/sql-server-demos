------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2025, November 29                --
--               https://bit.ly/43exQYm                               --
--                                                                    --
-- Session:      SQL Server 2025: Optimized Locking in action         --
--                                                                    --
-- Demo:         Optimized locking and LAQ (Session 1)                --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [OptimizedLocking];
GO

-- READ_COMMITTED_SNAPSHOT ON
/*
ALTER DATABASE CURRENT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE CURRENT SET MULTI_USER;
*/


-- READ_COMMITTED_SNAPSHOT OFF
/*
ALTER DATABASE CURRENT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CURRENT SET READ_COMMITTED_SNAPSHOT OFF;
ALTER DATABASE CURRENT SET MULTI_USER;
*/


-- ALLOW_SNAPSHOT_ISOLATION ON
/*
ALTER DATABASE CURRENT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CURRENT SET ALLOW_SNAPSHOT_ISOLATION ON;
ALTER DATABASE CURRENT SET MULTI_USER;
*/


-- ALLOW_SNAPSHOT_ISOLATION OFF
/*
ALTER DATABASE CURRENT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CURRENT SET ALLOW_SNAPSHOT_ISOLATION OFF;
ALTER DATABASE CURRENT SET MULTI_USER;
*/


/*
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
*/

/*
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
*/

-- A complete view on Optimized Locking activation
SELECT
  [name]
  --,OL = is_optimized_locking_on
  ,OL = DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn')
  ,RCSI = is_read_committed_snapshot_on
  ,ADR  = is_accelerated_database_recovery_on
 FROM
   sys.databases
 WHERE
   (name = DB_NAME());
GO

-- Setup dbo.EntityCounters table
DROP TABLE IF EXISTS dbo.EntityCounters;

CREATE TABLE dbo.EntityCounters
(
  EntityID INTEGER NOT NULL,
  CounterValue INTEGER NULL
);

INSERT INTO dbo.EntityCounters VALUES (1, 10), (2, 20), (3, 30), (1, 40);
GO


/* Session 1 */
BEGIN TRANSACTION;

UPDATE
  dbo.EntityCounters
SET
  CounterValue = CounterValue + 10
WHERE
  EntityID = 1;


SELECT
  resource_type
  ,resource_database_id
  ,resource_description
  ,request_mode
  ,request_type
  ,request_status
  ,request_session_id
  ,resource_associated_entity_id
FROM
  sys.dm_tran_locks
WHERE
  request_session_id IN (55, @@SPID)
  AND resource_type IN ('PAGE', 'RID', 'KEY', 'XACT');


SELECT
  transaction_sequence_num
  ,commit_sequence_num
  ,is_snapshot
  ,t.session_id
  ,first_snapshot_sequence_num
  ,max_version_chain_traversed
  ,elapsed_time_seconds
  ,host_name
  ,login_name
  ,CASE transaction_isolation_level
     WHEN '0' THEN 'Unspecified'
     WHEN '1' THEN 'ReadUncomitted'
     WHEN '2' THEN CASE
                     WHEN
                     ( SELECT [is_read_committed_snapshot_on] 
                       FROM sys.databases 
                       WHERE [database_id] = s.[database_id] ) = 1 THEN 'ReadCommittedSnapShot'
                     ELSE 'ReadCommitted'
                   END
     WHEN '3' THEN 'Repeatable'
     WHEN '4' THEN 'Serializable'
     WHEN '5' THEN 'Snapshot'
   END AS transaction_isolation_level
FROM
  sys.dm_tran_active_snapshot_database_transactions t
JOIN
  sys.dm_exec_sessions s ON t.session_id = s.session_id;

ROLLBACK;

/*
COMMIT
*/