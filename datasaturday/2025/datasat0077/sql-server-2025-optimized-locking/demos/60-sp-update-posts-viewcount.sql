------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2025, November 29                --
--               https://bit.ly/43exQYm                               --
--                                                                    --
-- Session:      SQL Server 2025: Optimized Locking in action         --
--                                                                    --
-- Demo:         Setup SP dbo.sp_update_posts_viewcount               --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [StackOverflow2010];
GO

/*
ALTER DATABASE CURRENT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CURRENT SET OPTIMIZED_LOCKING = ON/OFF;
ALTER DATABASE CURRENT SET MULTI_USER;
GO
*/

-- Random post ID

CREATE OR ALTER PROCEDURE dbo.sp_update_posts_viewcount
  (@UpdateEvenIds BIT = 1)
AS
BEGIN
  -- Update ViewCount random
  -- @UpdateEvenIds = 1 -- Update even IDs  
  -- @UpdateEvenIds = 0 -- Update odd IDs
  
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
  END;
  
  -- Start a loop to add views
  WHILE @UpdatedCount < @NumLikes
  BEGIN
    -- Generate a random ID
    SET @RandomPostId = ABS(CHECKSUM(NEWID())) % @MaxPostId + 1;

    -- Adjust ID to match even/odd requirement
    IF (@UpdateEvenIds = 1 AND @RandomPostId % 2 <> 0)
      SET @RandomPostId = @RandomPostId + 1; -- ensure even
    ELSE IF (@UpdateEvenIds = 0 AND @RandomPostId % 2 = 0)
      SET @RandomPostId = @RandomPostId + 1; -- ensure odd
  
    -- Ensure we don't exceed max ID
    IF @RandomPostId > @MaxPostId
      SET @RandomPostId = @MaxPostId;
  
    -- Attempt to update the selected post
    UPDATE
      dbo.Posts
    SET
      ViewCount = ISNULL(ViewCount, 0) + 1
    WHERE
      ID = @RandomPostId;
  
    -- Update the counter only if a row was modified
    IF @@ROWCOUNT = 1
      SET @UpdatedCount += 1;
  END;
  
  PRINT CONCAT('Script completed: ', @UpdatedCount, ' views successfully added.');
END;
GO