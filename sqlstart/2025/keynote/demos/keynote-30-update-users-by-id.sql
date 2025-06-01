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


SELECT * FROM dbo.Users WHERE Id < 0
GO


BEGIN TRANSACTION

UPDATE
  U
SET
  U.Reputation = U.Reputation + 1
FROM
  dbo.Users AS U
WHERE
  U.Id = -1
GO

ROLLBACK;
GO