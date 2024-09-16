-------------------------------------------------------------------------
-- Event:      1nn0va Saturday 2024 - September 28                     --
--             https://1nn0vasat2024.1nn0va.it/agenda.html             --
--                                                                     --
-- Session:    SQL Server Maintenance Plan: Fundamentals and best      --
--             practices                                               --
--                                                                     --
-- Script:     Restore database using sp_RestoreGene from Paul Brewer  --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------


-- sp_RestoreGene stored procedure is from Paul Brewer
-- It is available here: https://paulbrewer.wordpress.com/sp_restoregene/

USE [tempdb];
GO

DROP TABLE IF EXISTS #RestoreCommands;

CREATE TABLE #RestoreCommands
(
  [TSQL] NVARCHAR(MAX)
  ,BackupDate DATETIMEOFFSET
  ,BackupDevice NVARCHAR(MAX)
  ,first_lsn NUMERIC(25, 0)
  ,last_lsn NUMERIC(25, 0)
  ,fork_point_lsn NUMERIC(25, 0)
  ,first_recovery_fork_guid UNIQUEIDENTIFIER
  ,last_recovery_fork_guid UNIQUEIDENTIFIER
  ,[database_name] SYSNAME
  ,SortSequence INTEGER
)

INSERT INTO
  #RestoreCommands
EXEC [master].[dbo].[sp_RestoreGene]
  @Database = 'StackOverflowMini-LiveDemo',
  @WithRecovery = 1,
  @WithCHECKDB = 1,
  @TargetDatabase = 'StackOverflowMini-LiveDemo-Check-Restore'
GO

DECLARE @RestoreCmd AS VARCHAR(MAX) = ''

SELECT
  @RestoreCmd =
    @RestoreCmd + STRING_AGG([TSQL], '; ' + CHAR(13) + CHAR(10)) WITHIN GROUP (ORDER BY SortSequence)
FROM
  #RestoreCommands;

EXEC(@RestoreCmd);
GO