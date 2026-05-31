------------------------------------------------------------------------
-- Event:        Delphi Day 2026 - June 09-10                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      Azure SQL Database Essentials                        --
--                                                                    --
-- Demo:         Setup database job on Azure                          --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [];
GO

-- Connect to Azure SQL Database logical instance for database job

-- Create job database, it's the msdb of Azure SQL logical instance,
-- where the job metadata is stored

-- jobdb-dev-itn-01
IF (DB_ID('jobdb-dev-itn-01') IS NOT NULL)
BEGIN
  ALTER DATABASE [jobdb-dev-itn-01]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [jobdb-dev-itn-01];
END
GO

CREATE DATABASE [jobdb-dev-itn-01];
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

-- The edition is the tier like Basic, Standard, Premium

-- The Basic edition has only Basic as a service object
-- In the Standard edition, we have S0 to S12 service objectives

-- For the Premium tier, you have P1 to P15 service objects

ALTER DATABASE [jobdb-dev-itn-01]
  MODIFY(EDITION = 'Standard', SERVICE_OBJECTIVE = 'S1');
GO