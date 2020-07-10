-------------------------------------------------------------------------
-- Event:       SQL Start 2020 - June 26, 2020                          -
--              https://www.sqlstart.it/2020/Speakers/Sergio-Govoni     -
-- Session:     Automating Azure SQL Database maintenance tasks         -
-- Demo:        Schedule Elastic Jobs                                   -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

-- Connect to the job database specified when creating the job agent
USE [DBJobs];
GO

EXEC jobs.sp_update_job
  @job_name='IndexOptimize'
  ,@enabled=1
  ,@schedule_interval_type='Days'
  ,@schedule_start_time='20200627 02:00:00.0000000'
  ,@schedule_end_time='9999-12-31 11:59:59.0000000';
GO