------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2024 - February 24           --
--               https://bit.ly/3R8aAEM                               --
--                                                                    --
-- Session:      Database maintenance with Azure SQL Elastic Jobs     --
--                                                                    --
-- Demo:         Execute and monitor Elastic Jobs                     --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to the job database specified when creating the job agent
USE [DBJobsDataSaturdayPordenone2024];
GO


/*
-- Execute the latest version of a job
EXEC jobs.sp_start_job 'IndexOptimize';
GO
*/


-- Execute the latest version of a job and receive the execution ID
DECLARE @je UNIQUEIDENTIFIER
EXEC jobs.sp_start_job 'IndexOptimize', @job_execution_id = @je OUTPUT
SELECT @je
GO



SELECT
  *
FROM
  jobs.job_executions
WHERE
  job_execution_id = 'F8457B55-D287-414D-BD3C-DC2552032C9A';
GO


-- View top-level execution status for the job named 'IndexOptimize'
SELECT
  *
FROM
  jobs.job_executions 
WHERE
  job_name = 'IndexOptimize'
  AND step_id IS NULL
ORDER BY
  start_time DESC;
GO


-- View all top-level execution status for all jobs
SELECT
  *
FROM
  jobs.job_executions
WHERE
  step_id IS NULL
ORDER BY
  start_time DESC;
GO


-- View all execution statuses for job named 'IndexOptimize'
SELECT
  *
FROM
  jobs.job_executions 
WHERE
  job_name = 'IndexOptimize' 
ORDER BY
  start_time DESC;
GO


-- View all active executions to determine job execution id
SELECT
  *
FROM
  jobs.job_executions 
WHERE
  is_active = 1
  --AND job_name = 'IndexOptimize'
ORDER BY
  start_time DESC;
GO


-- Cancel job execution with the specified job execution ID
EXEC jobs.sp_stop_job '23B2897A-CE0C-4A63-BE03-09FC8E10D2AF';
GO