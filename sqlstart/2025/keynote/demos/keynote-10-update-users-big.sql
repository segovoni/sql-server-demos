------------------------------------------------------------------------
-- Event:        SQL Start 2025 - June 13                             --
--               https://www.sqlstart.it/                             --
--                                                                    --
-- Session:      Keynote                                              --
--                                                                    --
-- Demo:         SQL Server 2025, Database Engine, Optimized Locking  --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [StackOverflow2010];
GO


SELECT COUNT(*) FROM dbo.Users;
GO


-- Disable optimized locking
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = OFF WITH ROLLBACK IMMEDIATE;
GO


-- Enable optimized locking
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = ON WITH ROLLBACK IMMEDIATE;
GO


BEGIN TRANSACTION

UPDATE
  U
SET
  U.Reputation = U.Reputation + 1
FROM
  dbo.Users AS U
WHERE
  U.Id <= 270000
GO

ROLLBACK;
GO