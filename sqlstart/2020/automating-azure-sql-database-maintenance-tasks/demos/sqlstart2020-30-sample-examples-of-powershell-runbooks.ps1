-------------------------------------------------------------------------
-- Event:       SQL Start 2020 - June 26, 2020                          -
--              https://www.sqlstart.it/2020/Speakers/Sergio-Govoni     -
-- Session:     Automating Azure SQL Database maintenance tasks         -
-- Demo:        Sample examples of PowerShell Runbooks                  -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------



-- Invoke-Sqlcmd
-- https://www.powershellgallery.com/packages/SqlServer/21.0.17199

-- IndexOptimize
$params = @{
  'Database' = 'Maintenance'
  'ServerInstance' = '<Your-Azure-SQL-Database>.database.windows.net'
  'Username' = '<Your-User-Name>'
  'Password' = '<Your-Strong-Password>'
  'Query' = 'EXECUTE dbo.IndexOptimize @Databases = ''Maintenance'', @FragmentationLow = NULL, @FragmentationMedium = ''INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationHigh = ''INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE'', @FragmentationLevel1 = 5, @FragmentationLevel2 = 30, @UpdateStatistics = ''COLUMNS'', @OnlyModifiedStatistics = ''Y'''
  'QueryTimeout' = '0'
}
Invoke-Sqlcmd @params


-- DatabaseIntegrityCheck
$params = @{
  'Database' = 'Maintenance'
  'ServerInstance' = '<Your-Azure-SQL-Database>.database.windows.net'
  'Username' = '<Your-User-Name>'
  'Password' = '<Your-Strong-Password>'
  'Query' = 'EXECUTE dbo.DatabaseIntegrityCheck @Databases = ''Maintenance'', @CheckCommands = ''CHECKDB'', @ExtendedLogicalChecks = ''Y'''
  'QueryTimeout' = '0'
}
Invoke-Sqlcmd @params