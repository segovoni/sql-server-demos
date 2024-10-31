------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2024, Nov 23                     --
--               https://bit.ly/datasatparma24                        --
--                                                                    --
-- Session:      SQL Server Deadlocks: Techniques to identify         --
--               and resolve them!                                    --
--                                                                    --
-- Demo:         dbo.sp_AddVote session 1                             --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO

BEGIN TRANSACTION;

EXEC dbo.sp_AddVote @PostId = 2547592, @UserId = 238260, @VoteTypeId = 2;

/*
ROLLBACK;
*/

/*
COMMIT;
*/