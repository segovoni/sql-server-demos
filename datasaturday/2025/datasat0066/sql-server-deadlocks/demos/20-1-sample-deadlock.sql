------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         Sample deadlock session 1                            --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO

BEGIN TRANSACTION;

UPDATE
  dbo.Users
SET
  WebsiteUrl = NULL
WHERE
  Id = 238260;
GO

SELECT * FROM dbo.PostTypes;
GO

/*
ROLLBACK
*/