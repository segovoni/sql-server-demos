------------------------------------------------------------------------
-- Event:        Global Azure 2024 - Pordenone, April 20              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Database maintenance with Azure SQL Elastic Jobs     --
--                                                                    --
-- Demo:         Configure elastic jobs with UMI authentication       --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

 -- Create a target group and add targets for the jobs
 -- Define the target group and targets (the databases you want to 
 -- run the job against)

-- https://learn.microsoft.com/azure/azure-sql/database/elastic-jobs-tsql-create-manage?view=azuresql#define-target-servers-and-databases

-- Connect to the job database specified when creating the job agent

USE [DBJobsGlobalAzure2024];
GO


-- Add a target group containing server(s)
EXEC jobs.sp_add_target_group 'ServerGroupDemo';
GO


-- Add a server target member
-- When using Microsoft Entra authentication,
-- omit the @refresh_credential_name parameter, which should only be provided
-- when using database-scoped credentials
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'ServerGroupDemo'
  ,@target_type = N'SqlServer'
  --,@refresh_credential_name = N'masterjobcredential'
  ,@server_name = N'azure-sql-showcase.database.windows.net';
GO


-- Add StackOverflow2010 database target member
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'ServerGroupDemo'
  ,@target_type = N'SqlDatabase'
  ,@server_name = N'azure-sql-showcase.database.windows.net'
  ,@database_name = N'StackOverflow2010';
GO


-- Exclude DBJobsGlobalAzure2024 from the server target group
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'ServerGroupDemo'
  ,@membership_type = N'Exclude'
  ,@target_type = N'SqlDatabase'
  ,@server_name = N'azure-sql-showcase.database.windows.net'
  ,@database_name = N'DBJobsGlobalAzure2024';
GO


-- View the recently created target group and target group members
SELECT * FROM jobs.target_groups WHERE target_group_name = 'ServerGroupDemo';
SELECT * FROM jobs.target_group_members WHERE target_group_name = 'ServerGroupDemo';
GO


-- Add job for rebuild/reorganize indexes
EXEC jobs.sp_add_job
  @job_name='IndexOptimize'
  ,@description='Rebuild or reorganize all indexes with fragmentation';
GO


-- Add job step for create table
EXEC jobs.sp_add_jobstep
  @job_name='IndexOptimize'
  ,@command=N'EXECUTE dbo.IndexOptimize @Databases = ''StackOverflow2010'', @FragmentationLow = NULL, @FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30, @LogToTable = ''Y'''
  ,@target_group_name='ServerGroupDemo';
GO


EXEC jobs.sp_update_jobstep
  @job_name='IndexOptimize'
  ,@step_id = 1
  ,@command=N'EXECUTE dbo.IndexOptimize @Databases = ''StackOverflow2010'', @FragmentationLow = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationMedium = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30, @UpdateStatistics = ''COLUMNS'', @OnlyModifiedStatistics = ''Y'', @LogToTable = ''Y'''
  ,@target_group_name='ServerGroupDemo';
GO


SELECT * FROM jobs.jobs;
SELECT * FROM jobs.jobsteps;
SELECT * FROM jobs.target_groups WHERE target_group_name = 'ServerGroupDemo';
SELECT * FROM jobs.target_group_members WHERE target_group_name = 'ServerGroupDemo';
GO


/*
-- Drop job
EXEC jobs.sp_delete_job
  @job_name='IndexOptimize';
GO
*/

-- Authentication

-- There are two options for authentication of an elastic job agent to targets:

-- The the recommended method: use database users mapped to user-assigned
-- managed identity (UMI) to authenticate to target server(s)/database(s)

-- The previous method: use database users mapped to database-scoped
-- credentials in each database. Previously, database-scoped credentials were the
-- only option for the elastic job agent to authenticate to targets


-- In each of the target server(s)/database(s), create a contained user mapped to the UMI
-- or database-scoped credential, using T-SQL or PowerShell

-- https://learn.microsoft.com/azure/azure-sql/database/elastic-jobs-tsql-create-manage?view=azuresql#create-the-job-authentication

-- https://learn.microsoft.com/azure/azure-sql/database/elastic-jobs-tutorial?view=azuresql#create-job-agent-authentication


-- Connect to the master database of the Azure SQL logical instance of job agent
-- Use universal with MFA authentication type

USE [master];
GO

-- Create a login on the master database mapped to a user-assigned managed identity (UMI)
CREATE LOGIN [umi-sgovoni] FROM EXTERNAL PROVIDER;
GO

-- Create a user on the master database mapped to a login
-- It prevents the error:

-- Failed to determine members of SqlServerTarget (server name 'azure-sql-...', server location 'azure-sql-...'): 
-- The server principal "926e2a2b...@1f36c249..." is not able to access the database "master" under the current security context. 
-- Cannot open database "master" requested by the login. The login failed.  Login failed for user '926e2a2b...@1f36c249...'.

-- ID Client 926e2a2b...

CREATE USER [umi-sgovoni] FROM EXTERNAL PROVIDER;
GO

-- Verificare perchè ho anche dati i diritti di collaboratore su tutte
-- le risorse del resource group.. forse si può anche togliere


USE [StackOverflow2010];
GO

-- Create a user on a user database mapped to a login
CREATE USER [umi-sgovoni] FROM EXTERNAL PROVIDER;
GO


-- Grant permissions as necessary to execute your jobs. For example, ALTER and CREATE TABLE:
GRANT EXECUTE ON OBJECT :: [dbo].[IndexOptimize] TO [umi-sgovoni];
GRANT EXECUTE ON OBJECT :: [dbo].[CommandExecute] TO [umi-sgovoni];
--GRANT INSERT, SELECT, UPDATE ON OBJECT :: [dbo].[CommandLog] TO [umi-sgovoni];
--GRANT INSERT, SELECT, UPDATE ON OBJECT :: [dbo].[Queue] TO [umi-sgovoni];
--GRANT INSERT, SELECT, UPDATE ON OBJECT :: [dbo].[QueueDatabase] TO [umi-sgovoni];

GRANT ALTER ON SCHEMA :: dbo TO [umi-sgovoni];

EXEC sp_addrolemember 'db_owner', 'umi-sgovoni';
GO


