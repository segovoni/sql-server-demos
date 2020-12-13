-------------------------------------------------------------------------
-- Event:       IT PRO DEV Connections 2020 - December 12, 2020         -
--              https://www.itprodevconnections.gr/                     -
--                                                                      -
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
  @server = N'it-pro-dev-connections'
  ,@srvproduct=N''
  ,@provider=N'SQLNCLI11'
  ,@datasrc=N'it-pro-dev-connections.database.windows.net'
  ,@catalog=N'ToBeMaintained';

-- Replace "########" with your credentials (remote logins and password)
EXEC master.dbo.sp_addlinkedsrvlogin
  @rmtsrvname=N'it-pro-dev-connections'
  ,@useself=N'False'
  ,@locallogin=NULL
  ,@rmtuser=N'XXXXXXXXX'
  ,@rmtpassword='XXXXXXXXX';
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'it-pro-dev-connections', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO


-- Executing maintenance activities through Linked Server

-- Integrity check
EXEC [it-pro-dev-connections].ToBeMaintained.dbo.DatabaseIntegrityCheck
  @Databases = 'ToBeMaintained'
  ,@CheckCommands = 'CHECKDB'
  ,@ExtendedLogicalChecks = 'Y'
  ,@LogToTable = 'Y';
GO


-- Index maintenance
EXEC [it-pro-dev-connections].ToBeMaintained.dbo.IndexOptimize
  @Databases = 'ToBeMaintained'
  ,@FragmentationLow = NULL
  ,@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
  ,@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'
  ,@FragmentationLevel1 = 5
  ,@FragmentationLevel2 = 30
  ,@UpdateStatistics = 'COLUMNS'
  ,@OnlyModifiedStatistics = 'Y';
GO

-- Log commands
SELECT * FROM [dbo].[CommandLog];
GO