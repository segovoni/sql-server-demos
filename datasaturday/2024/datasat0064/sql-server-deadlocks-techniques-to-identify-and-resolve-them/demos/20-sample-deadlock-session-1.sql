------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2024, Nov 23                     --
--               https://bit.ly/datasatparma24                        --
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