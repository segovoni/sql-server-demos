------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2024, Nov 23                     --
--               https://bit.ly/datasatparma24                        --
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