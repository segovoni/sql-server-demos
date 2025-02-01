------------------------------------------------------------------------
-- Event:        Data Saturday Pordenone 2025, Feb 22                 --
--               https://bit.ly/datasatpordenone25                    --
--                                                                    --
-- Session:      Optimized Locking in Azure SQL Database:             --
--               Concurrency and performance at the next level!       --
--                                                                    --
-- Demo:         Setup SP dbo.sp_update_posts_viewcount               --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

/*
USE [StackOverflow2010];
GO
*/


-- Random post ID

CREATE OR ALTER PROCEDURE dbo.sp_update_posts_viewcount
AS BEGIN
  -- Update ViewCount random
  
  -- Configure the number of posts to update
  DECLARE @NumLikes INT = 5000;
  
  -- Variables for the loop
  DECLARE @UpdatedCount INT = 0;
  DECLARE @MaxPostId INT;
  DECLARE @RandomPostId INT;
  
  -- Determine the maximum value of ID
  SELECT @MaxPostId = MAX(ID) FROM dbo.Posts;
  
  -- Check if there are enough posts in the database
  IF @MaxPostId IS NULL
  BEGIN
    PRINT 'The Posts table is empty or does not exist. Add data before running this script.';
    RETURN;
  END
  
  -- Start a loop to add views
  WHILE @UpdatedCount < @NumLikes
  BEGIN
    -- Generate a random ID
    SET @RandomPostId = ABS(CHECKSUM(NEWID())) % @MaxPostId + 1;
  
    -- Attempt to update the selected post
    UPDATE
	  dbo.Posts
    SET
	  ViewCount = ISNULL(ViewCount, 0) + 1
    WHERE
	  ID = @RandomPostId;
  
    -- Check if the update was successful
	-- Update the counter only if a row was modified
    IF @@ROWCOUNT = 1
    BEGIN
      SET @UpdatedCount += 1;
    END;
  END;
  
  PRINT CONCAT('Script completed: ', @UpdatedCount, ' views successfully added.');
END;
GO

/*
-- Sequential post ID
CREATE OR ALTER PROCEDURE dbo.sp_update_posts_viewcount
AS BEGIN
  -- Update ViewCount sequentially
  
  -- Configure the number of posts to update
  DECLARE @NumLikes INT = 5000;
  
  -- Variables for the loop
  DECLARE @CurrentPostId INT = 1;
  DECLARE @UpdatedCount INT = 0;

  -- Start a loop to add views
  WHILE @UpdatedCount < @NumLikes
  BEGIN
    -- Attempt to update the selected post
    UPDATE
      dbo.Posts
    SET
      ViewCount = ISNULL(ViewCount, 0) + 1
    WHERE
      ID = @CurrentPostId;
  
    -- Check if the update was successful
    IF @@ROWCOUNT = 1
    BEGIN
      -- Update the counter only if a row was modified
      SET @UpdatedCount += 1;
    END;

    SET @CurrentPostId += 1;
  END;
  
  PRINT CONCAT('Script completed: ', @UpdatedCount, ' views successfully added.');
END;
GO
*/