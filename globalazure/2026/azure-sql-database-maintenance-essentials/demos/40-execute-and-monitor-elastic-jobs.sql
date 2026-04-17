------------------------------------------------------------------------
-- Event:        Global Azure 2026 - Pordenone, April 18              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Azure SQL Database Maintenance Essentials            --
--                                                                    --
-- Demo:         Execute and monitor Elastic Jobs                     --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to the job database specified when creating the job agent
USE [jobdb-dev-itn-01];
GO


-- Execute the latest version of a job and receive the execution ID
DECLARE @je UNIQUEIDENTIFIER
EXEC jobs.sp_start_job 'IndexOptimize', @job_execution_id = @je OUTPUT
SELECT @je
GO


SELECT
  lifecycle
  ,*
FROM
  jobs.job_executions
WHERE
  job_execution_id = '1B962FFF-4CB5-4562-B2F4-C83AD1BAD02D';
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
ORDER BY
  start_time DESC;
GO


-- Cancel job execution with the specified job execution ID
EXEC jobs.sp_stop_job '0FEF2EE9-BDC7-4B13-BCD1-8935B9F85014';
GO