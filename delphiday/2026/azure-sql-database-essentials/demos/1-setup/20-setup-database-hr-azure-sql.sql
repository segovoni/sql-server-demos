------------------------------------------------------------------------
-- Event:        Delphi Day 2026 - June 09-10                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      Azure SQL Database Essentials                        --
--                                                                    --
-- Demo:         Setup database HR on Azure                           --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [];
GO

-- Connect to Azure SQL Database logical instance for maintenance
-- azure-sql-delphi-day-2026


-- Create HR sample database

-- HR-DB-01
IF (DB_ID('HR-DB-01') IS NOT NULL)
BEGIN
  ALTER DATABASE [HR-DB-01]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [HR-DB-01];
END
GO


CREATE DATABASE [HR-DB-01];
GO


SELECT
  D.[NAME] AS DatabaseName
  ,S.*
FROM
  sys.database_service_objectives AS S
JOIN
  sys.databases AS D ON S.database_id = D.database_id
GO


-- Change the pricing tier
ALTER DATABASE [HR-DB-01]
  MODIFY(EDITION = 'Basic');
GO