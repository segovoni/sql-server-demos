------------------------------------------------------------------------
-- Event:        Delphi Day 2019, Piacenza, June 6 2019               --
--               https://www.delphiday.it/                            --
-- Session:      SQL Server Query Store e Automatic Tuning            --
-- Demo:         Automatic Plan Correction                            --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [QueryStore];
GO


-- Check the automatic tuning information on-prem DB
-- Options here are different than Azure SQL Database
SELECT * FROM sys.database_automatic_tuning_mode;
SELECT * FROM sys.database_automatic_tuning_options;
GO


-- Enable Automatic Plan Correction
ALTER DATABASE [QueryStore] SET AUTOMATIC_TUNING
(
  FORCE_LAST_GOOD_PLAN = ON
);
GO



-- Cleaning up the space
DBCC FREEPROCCACHE;
DBCC FREESESSIONCACHE;
DBCC DROPCLEANBUFFERS;
GO

ALTER DATABASE [QueryStore] SET QUERY_STORE CLEAR;
GO

-- Check status of the Query Store
SELECT
  *
FROM
  sys.database_query_store_options;
GO




/*
-- Generate the workload

cmd: C:\Tools\QueryStoreWorkLoad.exe -usa -pPassword -sServerName -dQueryStore
*/


-- View all the forced plans
SELECT
  CAST(query_plan AS XML) AS xml_query_plan
  ,*
FROM
  sys.query_store_plan
WHERE
  (is_forced_plan = 1);
GO

/*
-- Force a plan @plan_id = N for a particular query @query_id = N

EXEC sp_query_store_force_plan @query_id = N, @plan_id = N;
GO
*/

/*
-- Unforce a plan for a particular query

EXEC sp_query_store_unforce_plan @query_id = 1, @plan_id = 1;
GO
*/
