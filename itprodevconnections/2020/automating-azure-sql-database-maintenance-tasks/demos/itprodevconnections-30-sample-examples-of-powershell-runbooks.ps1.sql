-------------------------------------------------------------------------
-- Event:       IT PRO DEV Connections 2020 - December 12, 2020         -
--              https://www.itprodevconnections.gr/                     -
--                                                                      -
-- Session:     Automating Azure SQL Database maintenance tasks         -
-- Demo:        Sample examples of PowerShell Runbooks                  -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------



-- Download Invoke-Sqlcmd
-- https://www.powershellgallery.com/packages/SqlServer/21.0.17199

-- IndexOptimize
$params = @{
  'Database' = 'ToBeMaintained'
  'ServerInstance' = 'it-pro-dev-connections.database.windows.net'
  'Username' = 'XXXXXXXXX'
  'Password' = 'XXXXXXXXX'
  'Query' = 'EXECUTE dbo.IndexOptimize @Databases = ''ToBeMaintained'', @FragmentationLow = NULL, @FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30, @UpdateStatistics = ''COLUMNS'', @OnlyModifiedStatistics = ''Y'''
  'QueryTimeout' = '0'
}
Invoke-Sqlcmd @params


-- DatabaseIntegrityCheck
$params = @{
  'Database' = 'ToBeMaintained'
  'ServerInstance' = 'it-pro-dev-connections.database.windows.net'
  'Username' = 'XXXXXXXXX'
  'Password' = 'XXXXXXXXX'
  'Query' = 'EXECUTE dbo.DatabaseIntegrityCheck @Databases = ''ToBeMaintained'', @CheckCommands = ''CHECKDB'', @ExtendedLogicalChecks = ''Y'''
  'QueryTimeout' = '0'
}
Invoke-Sqlcmd @params