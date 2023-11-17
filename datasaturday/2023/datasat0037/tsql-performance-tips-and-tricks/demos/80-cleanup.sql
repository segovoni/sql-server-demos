------------------------------------------------------------------------
-- Event:        Data Saturday Parma 2023 - November 18               --
--               https://bit.ly/3tKmyMM                               --
--                                                                    --
-- Session:      T-SQL performance tips & tricks!                     --
--                                                                    --
-- Demo:         Cleanup                                              --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [master];
GO


-- Drop Database
IF (DB_ID('AdventureWorks2022') IS NOT NULL)
BEGIN
  ALTER DATABASE [AdventureWorks2022]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AdventureWorks2022];
END;
GO

-- Drop database WideWorldImporters
IF (DB_ID('WideWorldImporters') IS NOT NULL)
BEGIN
  ALTER DATABASE [WideWorldImporters]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [WideWorldImporters];
END;
GO

-- Drop database TestLatchDB 
IF (DB_ID('TestLatchDB') IS NOT NULL)
BEGIN
  ALTER DATABASE [TestLatchDB]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [TestLatchDB];
END;
GO