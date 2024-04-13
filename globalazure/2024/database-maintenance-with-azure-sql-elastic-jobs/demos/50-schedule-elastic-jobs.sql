------------------------------------------------------------------------
-- Event:        Global Azure 2024 - Pordenone, April 20              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Database maintenance with Azure SQL Elastic Jobs     --
--                                                                    --
-- Demo:         Schedule Elastic Jobs                                --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to the job database specified when creating the job agent
USE [DBJobsGlobalAzure2024];
GO


EXEC jobs.sp_update_job
  @job_name='IndexOptimize'
  ,@enabled=1
  ,@schedule_interval_type='Days'
  ,@schedule_start_time='2024-04-20 23:30:00.0000000'
  ,@schedule_end_time='9999-12-31 11:59:59.0000000';
GO