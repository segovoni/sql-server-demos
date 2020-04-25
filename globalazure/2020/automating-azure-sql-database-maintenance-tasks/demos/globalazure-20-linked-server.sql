-------------------------------------------------------------------------
-- Event:       Global Azure 2020 Virtual - April 24, 2020              -
--              https://cloudgen.it/global-azure/                       -
-- Session:     Automating Azure SQL Database maintenance tasks         -
-- Demo:        Linked Server                                           -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------


-- Connect to SQL Server on-premises instance

USE [master]
GO


-- Create a new Linked Server to Azure SQL Database
EXEC master.dbo.sp_addlinkedserver
  @server = N'AzureAutomation'
  ,@srvproduct=N''
  ,@provider=N'SQLNCLI11'
  ,@datasrc=N'azure-automation.database.windows.net'
  ,@catalog=N'Maintenance';

-- For security reasons the linked server remote logins password is changed
-- with ########
EXEC master.dbo.sp_addlinkedsrvlogin
  @rmtsrvname=N'AzureAutomation'
  ,@useself=N'False'
  ,@locallogin=NULL
  ,@rmtuser=N'########'
  ,@rmtpassword='########';
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'AzureAutomation', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


-- Executing maintenance activities through Linked Server

-- Integrity check
EXEC AzureAutomation.Maintenance.dbo.DatabaseIntegrityCheck
  @Databases = 'Maintenance'
  ,@CheckCommands = 'CHECKDB'
  ,@ExtendedLogicalChecks = 'Y';
GO


-- Index maintenance
EXEC AzureAutomation.Maintenance.dbo.IndexOptimize
  @Databases = 'Maintenance'
  ,@FragmentationLow = NULL
  ,@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
  ,@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
  ,@FragmentationLevel1 = 5
  ,@FragmentationLevel2 = 30
  ,@UpdateStatistics = 'COLUMNS'
  ,@OnlyModifiedStatistics = 'Y';
GO