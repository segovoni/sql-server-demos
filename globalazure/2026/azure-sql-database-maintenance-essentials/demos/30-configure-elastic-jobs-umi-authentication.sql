------------------------------------------------------------------------
-- Event:        Global Azure 2026 - Pordenone, April 18              --
--               https://globalazure.net/                             --
--                                                                    --
-- Session:      Azure SQL Database Maintenance Essentials            --
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

USE [jobdb-dev-itn-01];
GO


-- Add a target group containing server(s)
EXEC jobs.sp_add_target_group 'tg-devtest-itn-01';
GO


-- Add a server target member
-- When using Microsoft Entra authentication,
-- omit the @refresh_credential_name parameter, which should only be provided
-- when using database-scoped credentials
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'tg-devtest-itn-01'
  ,@target_type = N'SqlServer'
  --,@refresh_credential_name = N'masterjobcredential'
  ,@server_name = N'azure-sql-showcase.database.windows.net';
GO


-- Add AdventureWorksLT2025 database target member
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'tg-devtest-itn-01'
  ,@target_type = N'SqlDatabase'
  ,@server_name = N'azure-sql-showcase.database.windows.net'
  ,@database_name = N'AdventureWorksLT2025';
GO


-- Exclude StackOverflow2010 from the server target group
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'tg-devtest-itn-01'
  ,@membership_type = N'Exclude'
  ,@target_type = N'SqlDatabase'
  ,@server_name = N'azure-sql-showcase.database.windows.net'
  ,@database_name = N'StackOverflow2010';
GO


-- Exclude jobdb-dev-itn-01 from the server target group
EXEC jobs.sp_add_target_group_member
  @target_group_name = N'tg-devtest-itn-01'
  ,@membership_type = N'Exclude'
  ,@target_type = N'SqlDatabase'
  ,@server_name = N'azure-sql-showcase.database.windows.net'
  ,@database_name = N'jobdb-dev-itn-01';
GO


-- View the recently created target group and target group members
SELECT * FROM jobs.target_groups WHERE target_group_name = 'tg-devtest-itn-01';
SELECT * FROM jobs.target_group_members WHERE target_group_name = 'tg-devtest-itn-01';
GO


-- Add job for rebuild/reorganize indexes
EXEC jobs.sp_add_job
  @job_name='IndexOptimize'
  ,@description='Rebuild or reorganize all indexes with fragmentation';
GO


DECLARE @lcommand NVARCHAR(MAX) =
  N'EXECUTE dbo.IndexOptimize ' +
     '@Databases = ''AdventureWorksLT2025'', ' +
     '@FragmentationLow = NULL, ' +
     '@FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', ' +
     '@FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', ' + 
     '@FragmentationLevel1 = 5, ' +
     '@FragmentationLevel2 = 30, ' +
     '@LogToTable = ''Y''';

/*
EXECUTE dbo.IndexOptimize @Databases = 'AdventureWorksLT2025', @FragmentationLow = NULL, @FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE', @FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30, @LogToTable = 'Y';
*/

-- Add job step for rebuild/reorganize indexes
EXEC jobs.sp_add_jobstep
  @job_name='IndexOptimize'
  ,@command=@lcommand
  ,@target_group_name='tg-devtest-itn-01';
GO


DECLARE @lcommand_upd NVARCHAR(MAX) =
  N'EXECUTE dbo.IndexOptimize ' + 
    '@Databases = ''AdventureWorksLT2025'', ' + 
    '@FragmentationLow = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', ' + 
    '@FragmentationMedium = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', ' + 
    '@FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', ' + 
    '@FragmentationLevel1 = 5, ' + 
    '@FragmentationLevel2 = 30, ' + 
    '@UpdateStatistics = ''COLUMNS'', ' + 
    '@OnlyModifiedStatistics = ''Y'', ' + 
    '@LogToTable = ''Y''';

/*
EXECUTE dbo.IndexOptimize @Databases = 'AdventureWorksLT2025', @FragmentationLow = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE', @FragmentationMedium = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE', @FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30, @UpdateStatistics = 'COLUMNS', @OnlyModifiedStatistics = 'Y', @LogToTable = 'Y';
*/

-- Update job step for rebuild/reorganize indexes
EXEC jobs.sp_update_jobstep
  @job_name='IndexOptimize'
  ,@step_id=1
  ,@command=@lcommand_upd
  ,@target_group_name='tg-devtest-itn-01';
GO


SELECT * FROM jobs.jobs;
SELECT * FROM jobs.jobsteps;
SELECT * FROM jobs.target_groups WHERE target_group_name = 'tg-devtest-itn-01';
SELECT * FROM jobs.target_group_members WHERE target_group_name = 'tg-devtest-itn-01';
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
CREATE LOGIN [umi-sqlops-maint-dev-itn-01] FROM EXTERNAL PROVIDER;
GO

-- Create a user on the master database mapped to a login
-- It prevents the error:

-- Failed to determine members of SqlServerTarget (server name 'azure-sql-...', server location 'azure-sql-...'): 
-- The server principal "926e2a2b...@1f36c249..." is not able to access the database "master" under the current security context. 
-- Cannot open database "master" requested by the login. The login failed.  Login failed for user '926e2a2b...@1f36c249...'.

-- ID Client 926e2a2b...

--CREATE USER [umi-sqlops-maint-dev-itn-01] FROM EXTERNAL PROVIDER;
--GO

CREATE USER [umi-sqlops-maint-dev-itn-01] FROM LOGIN [umi-sqlops-maint-dev-itn-01];
GO



-- Connect to the target Azure SQL Database you want to run the job against
-- Use universal with MFA authentication type


USE [master];
GO

-- Create a login on the master database mapped to a user-assigned managed identity (UMI)
CREATE LOGIN [umi-sqlops-maint-dev-itn-01] FROM EXTERNAL PROVIDER;
GO

-- Create a user on the master database mapped to a login
CREATE USER [umi-sqlops-maint-dev-itn-01] FROM LOGIN [umi-sqlops-maint-dev-itn-01];
GO



USE [AdventureWorksLT2025];
GO

-- Create a user on a user database mapped to a login
--CREATE USER [umi-sqlops-maint-dev-itn-01] FROM EXTERNAL PROVIDER;
--GO

CREATE USER [umi-sqlops-maint-dev-itn-01] FROM LOGIN [umi-sqlops-maint-dev-itn-01];
GO

ALTER ROLE db_owner ADD MEMBER [umi-sqlops-maint-dev-itn-01];
GO

GRANT VIEW DATABASE STATE TO [umi-sqlops-maint-dev-itn-01];
GO



SELECT
  u.name as 'User Name'
  ,p.[permission_name] as 'Permission'
  ,o.name as 'Object Name'
FROM
  sys.database_permissions AS p
INNER JOIN
  sys.objects AS o ON p.major_id=o.object_id
INNER JOIN
  sys.database_principals AS u ON p.grantee_principal_id=u.principal_id;
GO