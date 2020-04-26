------------------------------------------------------------------------
-- Event:        SQL Saturday #567 Ljubljana, December 10 2016         -
--               http://www.sqlsaturday.com/567/eventhome.aspx         -
-- Session:      Executions Plans End-to-End in SQL Server             -
-- Demo:         Setup SQL ***Server 2012***                           -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [master]; -- ***SQL Server 2012***
GO


------------------------------------------------------------------------
-- Restore databases from Snapshot                                     -
------------------------------------------------------------------------

-- AdventureWorks2012
IF (DB_ID('AdventureWorks2012') IS NOT NULL)
BEGIN
  ALTER DATABASE AdventureWorks2012
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  -- Reverting AdventureWorks2012 from AdventureWorks2012_Snapshot
  RESTORE DATABASE AdventureWorks2012
    FROM DATABASE_SNAPSHOT = 'AdventureWorks2012_Snapshot';

  ALTER DATABASE AdventureWorks2012
    SET MULTI_USER;
END
GO


-- PlanGuide
IF (DB_ID('PlanGuide') IS NOT NULL)
BEGIN
  ALTER DATABASE PlanGuide
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  -- Reverting PlanGuide from PlanGuide_Snapshot
  RESTORE DATABASE PlanGuide
    FROM DATABASE_SNAPSHOT = 'PlanGuide_Snapshot';

  ALTER DATABASE PlanGuide
    SET MULTI_USER;
END
GO


EXEC sp_configure 'max degree of parallelism', 0;
GO
RECONFIGURE;
GO

EXEC sp_configure 'cost threshold for parallelism', 5;
GO
RECONFIGURE;
GO