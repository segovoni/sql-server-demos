------------------------------------------------------------------------
-- Event:        Delphi Day 2026 - June 09-10                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      Azure SQL Database Essentials                        --
--                                                                    --
-- Demo:         Schedule Elastic Jobs                                --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- Connect to the job database specified when creating the job agent
USE [jobdb-dev-itn-01];
GO


EXEC jobs.sp_update_job
  @job_name='IndexOptimize'
  ,@enabled=1
  ,@schedule_interval_type='Days'
  ,@schedule_start_time='2026-06-09 23:30:00.0000000'
  ,@schedule_end_time='9999-12-31 11:59:59.0000000';
GO