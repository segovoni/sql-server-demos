------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         Sample deadlock session 2                            --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO

BEGIN TRANSACTION;

INSERT INTO dbo.PostTypes
  ([Type])
VALUES
  ('Comments');
GO


SELECT
  *
FROM
  dbo.Users
WHERE
  Id = 238260;
GO


/*
ROLLBACK
*/