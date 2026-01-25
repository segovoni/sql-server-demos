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


-- Consider this stored procedure, an index on AnswerCount exists
CREATE OR ALTER PROCEDURE dbo.SearchPostsCounts
  @NAnswerCount INTEGER = NULL
AS
  SELECT
    Body
    ,AnswerCount
  FROM
    dbo.Posts
  WHERE
    -- Non-SARGable predicate
    ISNULL(AnswerCount, @NAnswerCount) = @NAnswerCount
GO

-- Search posts for AnswerCount
EXECUTE dbo.SearchPostsCounts @NAnswerCount = 20;
GO


CREATE OR ALTER PROCEDURE dbo.SearchPostsCounts
  @NAnswerCount INTEGER = NULL
AS
  SELECT
    Body
    ,AnswerCount
  FROM
    dbo.Posts
  WHERE
    ((AnswerCount = @NAnswerCount) OR
     (@NAnswerCount IS NULL))
GO

-- Search posts for AnswerCount
EXECUTE dbo.SearchPostsCounts @NAnswerCount = 20;
GO


-- SQL Server always chooses a plan that scans dbo.Posts,
-- even if there's an index on dbo.Posts(AnswerCount)
-- A seek plan might not be possible with NULLs


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
    ((AnswerCount = @NAnswerCount)
     OR (@NAnswerCount IS NULL))
    AND
    ((CommentCount = @NCommentCount)
     OR (@NCommentCount IS NULL))
GO

-- Search posts for AnswerCount
EXECUTE dbo.SearchPostsCounts
  @NAnswerCount = 20
  ,@NCommentCount = NULL
GO

-- Search posts for CommentCount
EXECUTE dbo.SearchPostsCounts
  @NAnswerCount = NULL
  ,@NCommentCount = 20
GO


SELECT
  qs.query_plan_hash
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
  AND (qt.[text] NOT LIKE '%sys.dm_exec_cached_plans%')
  AND (qt.[text] NOT LIKE '%sys.dm_exec_query_stats%')
ORDER BY
  qs.execution_count DESC; 
GO



-- Enables PSP optimization to generate multiple plans based on parameter value distributions
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = ON;

-- Optimizes queries with optional parameters (NULL checks)
-- Specifically targets queries with optional parameters
-- using patterns like (Column = @Param OR @Param IS NULL)
ALTER DATABASE SCOPED CONFIGURATION SET OPTIONAL_PARAMETER_OPTIMIZATION = ON;
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
  ,@NCommentCount = 20
GO


SELECT
  qs.query_plan_hash
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
  AND (qt.[text] NOT LIKE '%sys.dm_exec_cached_plans%')
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