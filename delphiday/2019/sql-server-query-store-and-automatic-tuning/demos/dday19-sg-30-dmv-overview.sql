------------------------------------------------------------------------
-- Event:        Delphi Day 2019, Piacenza, June 6 2019               --
--               https://www.delphiday.it/                            --
-- Session:      SQL Server Query Store e Automatic Tuning            --
-- Demo:         Query Store DMV overview                             --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [QueryStore];
GO

-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-query-text-transact-sql?view=sql-server-2017
-- Contains the Transact-SQL text and the SQL handle of the query

-- Every time I run a query, the engine knows the query's text, so
-- the Query Store can store it into the sys.query_store_query_text
-- that is the starting point of the Query Store DMVs
SELECT * FROM sys.query_store_query_text;
GO


-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-query-transact-sql?view=sql-server-2017
-- Contains information about the query and its associated overall
-- aggregated runtime execution statistics

-- For each row of the sys.query_store_query_text I can have several different
-- rows in the sys.query_store_query
-- one row for each UNIQUE COMBINATION of the ANSI options
SELECT * FROM sys.query_store_query;
GO


-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-plan-transact-sql?view=sql-server-2017
-- Contains information about each execution plan associated with a query

-- For each unique combination of ANSI options I can have several different
-- execution plans stored in the sys.query_store_plan
SELECT * FROM sys.query_store_plan;
GO



-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-runtime-stats-transact-sql?view=sql-server-2017
-- Contains information about the runtime execution statistics information for the query

-- The DMV sys.query_store_runtime_stats contains the execution metrics,
-- they are memorized in this way: One row per plan per time granularity
SELECT * FROM sys.query_store_runtime_stats order by runtime_stats_id;
GO


-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-runtime-stats-interval-transact-sql?view=sql-server-2017
-- Contains information about the start and end time of each interval over which runtime
-- execution statistics information for a query has been collected
SELECT * FROM sys.query_store_runtime_stats_interval;
GO


-- https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-context-settings-transact-sql?view=sql-server-2017
-- Contains information about the semantics affecting context settings associated with a query
-- There are a number of context settings available in SQL Server that influence the query semantics
-- (defining the correct result of the query). The same query text compiled under different settings
-- may produce different results (depending on the underlying data)
SELECT * FROM sys.query_context_settings;
GO