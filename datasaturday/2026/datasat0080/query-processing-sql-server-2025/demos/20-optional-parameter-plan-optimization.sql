------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2026, February 28            --
--               https://bit.ly/4qgoS6D                               --
--                                                                    --
-- Session:      Query Processing improvements in SQL Server 2025     --
--                                                                    --
-- Demo:         Optional Parameter Plan Optimization (OPPO)          --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [StackOverflow2010];
GO

SET STATISTICS IO ON;
GO


ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 170;

ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = OFF;

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = OFF;
GO


-- Consider this stored procedure, OPPO is for those generic stored procedures
-- where one query has optional parameters that might or might not be called at runtime
-- An index on AnswerCount exists
CREATE OR ALTER PROCEDURE dbo.SearchPostsCounts
  @NAnswerCount INTEGER = NULL
AS
  SELECT
    Body
    ,AnswerCount
  FROM
    dbo.Posts
  WHERE
    ((AnswerCount = @NAnswerCount) OR (@NAnswerCount IS NULL))
GO

-- Search posts for AnswerCount
EXECUTE dbo.SearchPostsCounts @NAnswerCount = 20;
GO


/*
(502 rows affected)
Table 'Posts'. Scan count 3, logical reads 8589, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 17, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/


-- SQL Server always chooses a plan that scans dbo.Posts, even if there's an index
-- on dbo.Posts(AnswerCount). A seek plan might not be possible with NULLs


-- Enables PSP optimization to generate multiple plans based on parameter value distributions
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON;

-- Optimizes queries with optional parameters (NULL checks)
-- Using patterns like (Column = @Param OR @Param IS NULL)
ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = ON;
GO

DBCC FREEPROCCACHE;
GO


-- Search posts for AnswerCount
EXECUTE dbo.SearchPostsCounts @NAnswerCount = 20;
GO


/*
(502 rows affected)
Table 'Posts'. Scan count 1, logical reads 2052, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 15, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/


EXECUTE dbo.SearchPostsCounts;
GO


SELECT
  qt.text
  ,qs.query_plan_hash
  ,qs.query_hash
  ,qs.execution_count
  ,qs.min_elapsed_time
  ,qs.max_elapsed_time
  ,qs.min_rows
  ,qs.max_rows
  ,qs.last_dop
  ,qs.last_grant_kb
  ,qs.last_worker_time
  ,qp.query_plan
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.[text] LIKE '%Posts%')
  AND (qt.[text] NOT LIKE '%sys.dm_exec_sql_text%')
  AND (qt.[text] NOT LIKE '%sys.dm_exec_query_stats%')
ORDER BY
  qs.execution_count DESC; 
GO



-- Now consider a more complex query with two optional parameters, and indexes on both columns
CREATE OR ALTER PROCEDURE dbo.SearchPostsCounts
  @NAnswerCount INTEGER = NULL
  ,@NCommentCount INTEGER = NULL
AS
  SELECT
    Body
    ,AnswerCount
    ,CommentCount
  FROM
    dbo.Posts
  WHERE
    ((AnswerCount = @NAnswerCount) OR (@NAnswerCount IS NULL))
    AND
    ((CommentCount = @NCommentCount) OR (@NCommentCount IS NULL))
GO


DBCC FREEPROCCACHE;
GO


-- Search posts for AnswerCount
EXECUTE dbo.SearchPostsCounts
  @NAnswerCount = 20
  ,@NCommentCount = NULL
GO


-- Search posts for CommentCount
EXECUTE dbo.SearchPostsCounts
  @NAnswerCount = NULL
  ,@NCommentCount = 40
GO


SELECT
  qt.text
  ,qs.query_plan_hash
  ,qs.query_hash
  ,qs.execution_count
  ,qs.min_elapsed_time
  ,qs.max_elapsed_time
  ,qs.min_rows
  ,qs.max_rows
  ,qs.last_dop
  ,qs.last_grant_kb
  ,qs.last_worker_time
  ,qp.query_plan
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.[text] LIKE '%Posts%')
  AND (qt.[text] NOT LIKE '%sys.dm_exec_sql_text%')
  AND (qt.[text] NOT LIKE '%sys.dm_exec_query_stats%')
ORDER BY
  qs.execution_count DESC; 
GO



DBCC FREEPROCCACHE;
GO


-- Now let's test the same query with parameters swapped, 
-- to see if we get different plans based on parameter sensitivity

-- Search posts for CommentCount
EXECUTE dbo.SearchPostsCounts
  @NAnswerCount = NULL
  ,@NCommentCount = 40
GO


-- Search posts for AnswerCount
EXECUTE dbo.SearchPostsCounts
  @NAnswerCount = 20
  ,@NCommentCount = NULL
GO


-- OPPO currently works best with single optional parameters
-- Multi-parameter scenarios need further optimization in future SQL Server versions


SELECT
  qt.text
  ,qs.query_plan_hash
  ,qs.query_hash
  ,qs.execution_count
  ,qs.min_elapsed_time
  ,qs.max_elapsed_time
  ,qs.min_rows
  ,qs.max_rows
  ,qs.last_dop
  ,qs.last_grant_kb
  ,qs.last_worker_time
  ,qp.query_plan
FROM
  sys.dm_exec_query_stats AS qs   
CROSS APPLY
  sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY
  sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE
  (qt.[text] LIKE '%Posts%')
  AND (qt.[text] NOT LIKE '%sys.dm_exec_sql_text%')
  AND (qt.[text] NOT LIKE '%sys.dm_exec_query_stats%')
ORDER BY
  qs.execution_count DESC; 
GO


-- There are currently 45 reasons listed in the XE "opo_skipped_reason_enum"
SELECT
  *
FROM
  sys.dm_xe_map_values
WHERE
  [name] = 'opo_skipped_reason_enum'
ORDER BY
  map_key;
GO