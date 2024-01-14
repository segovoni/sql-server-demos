------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2024 - February 24           --
--               https://bit.ly/3R8aAEM                               --
--                                                                    --
-- Session:      Database maintenance with Azure SQL Elastic Jobs     --
--                                                                    --
-- Demo:         Configure elastic jobs (UMI Authentication)          --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

 -- Create a target group and add targets for the jobs
 -- Define the target group and targets (the databases you want to 
 -- run the job against)

-- https://learn.microsoft.com/azure/azure-sql/database/elastic-jobs-tsql-create-manage?view=azuresql#define-target-servers-and-databases

-- Connect to the job database specified when creating the job agent

USE [DBJobsDataSaturdayPordenone2024];
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
  -- Credential required to refresh the databases in server
  --,@refresh_credential_name = N'masterjobcredential'
  ,@server_name = N'azure-sql-data-sat-pn-2024.database.windows.net';
GO


-- Exclude a database target member from the server target group
/*
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'ServerGroupDemo'
  ,@membership_type = N'Exclude'
  ,@target_type = N'SqlDatabase'
  ,@server_name = N'azure-automation.database.windows.net'
  ,@database_name = N'DBJobs';
GO
*/


EXEC jobs.sp_add_target_group_member
  @target_group_name = N'ServerGroupDemo'
  ,@membership_type = N'Exclude'
  ,@target_type = N'SqlDatabase'
  ,@server_name = N'azure-sql-data-sat-pn-2024.database.windows.net'
  ,@database_name = N'DBJobsDataSaturdayPordenone2024';
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
  ,@command=N'EXECUTE dbo.IndexOptimize @Databases = ''StackOverflow2010'', @FragmentationLow = NULL, @FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30'
  --,@credential_name='jobcredential'
  ,@target_group_name='ServerGroupDemo';
GO


EXEC jobs.sp_update_jobstep
  @job_name='IndexOptimize'
  ,@step_id = 1
  ,@command=N'EXECUTE dbo.IndexOptimize @Databases = ''StackOverflow2010'', @FragmentationLow = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationMedium = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30, @UpdateStatistics = ''COLUMNS'', @OnlyModifiedStatistics = ''Y'''
  --,@credential_name='jobcredential'
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

-- Create a login on the master database mapped to a user-assigned managed identity (UMI)
CREATE LOGIN [umi-data-sat-pn-2024] FROM EXTERNAL PROVIDER;
GO

-- Create a user on the master database mapped to a login
-- It prevents the error:

-- Failed to determine members of SqlServerTarget (server name 'azure-automation.database.windows.net', server location 'azure-automation.database.windows.net'): 
-- The server principal "926e2a2b...@1f36c249..." is not able to access the database "master" under the current security context. 
-- Cannot open database "master" requested by the login. The login failed.  Login failed for user '926e2a2b-b428-40fc-aa68-f891efbd644b@1f36c249-867f-46da-aa43-70a6ded1401e.'.

-- ID Client 926e2a2b...

CREATE USER [umi-data-sat-pn-2024] FROM EXTERNAL PROVIDER;
GO

-- Verificare perchè ho anche dati i diritti di collaboratore su tutte
-- le risorse del resource group.. forse si può anche togliere


USE [StackOverflow2010];
GO

-- Create a user on a user database mapped to a login
CREATE USER [umi-data-sat-pn-2024] FROM EXTERNAL PROVIDER;
GO


-- Grant permissions as necessary to execute your jobs. For example, ALTER and CREATE TABLE:
GRANT EXECUTE ON OBJECT::[dbo].[IndexOptimize] TO [umi-data-sat-pn-2024];
GRANT EXECUTE ON OBJECT::[dbo].[CommandExecute] TO [umi-data-sat-pn-2024];

--GRANT ALTER ON SCHEMA::dbo TO [UMI-Data-Saturday-Pordenone-2024];
GO


