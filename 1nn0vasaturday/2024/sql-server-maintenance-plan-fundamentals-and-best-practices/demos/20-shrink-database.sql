-------------------------------------------------------------------------
-- Event:      1nn0va Saturday 2024 - September 28                     --
--             https://1nn0vasat2024.1nn0va.it/agenda.html             --
--                                                                     --
-- Session:    SQL Server Maintenance Plan: Fundamentals and best      --
--             practices                                               --
--                                                                     --
-- Script:     Shrink database                                         --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [ShrinkDemo];
GO

-- Check fragmentation 
SELECT
  avg_fragmentation_in_percent
  ,page_count
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('ShrinkDemo'), OBJECT_ID('ShrinkDemo.dbo.TabB'), NULL, NULL, 'DETAILED');
GO

-- Shrink DB
DBCC SHRINKDATABASE('ShrinkDemo');
GO 

-- Check fragmentation 
SELECT
  avg_fragmentation_in_percent
  ,page_count
  ,*
FROM
  sys.dm_db_index_physical_stats(DB_ID('ShrinkDemo'), OBJECT_ID('ShrinkDemo.dbo.TabB'), NULL, NULL, 'DETAILED');
GO

-- Reindex dbo.TabB
DBCC DBREINDEX('dbo.TabB');
GO