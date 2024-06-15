-------------------------------------------------------------------------
-- Event:      SQL Start 2024 - June 14                                --
--             https://www.sqlstart.it/                                --
--                                                                     --
-- Session:    SQL Server unit testing with tSQLt, Docker and          --
--             GitHub Actions                                          --
--                                                                     --
-- Demo:       tSQLt framework setup                                   --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [master];
GO

-- Enable CLR at the SQL Server instance level
-- tSQLt framework requires this option
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
GO

EXEC sp_configure 'clr enabled';
GO


USE [AdventureWorks2022];
GO


-- Enable TRUSTWORTHY property at the database level
-- in each database you want to install tSQLt framework
ALTER DATABASE [AdventureWorks2022] SET TRUSTWORTHY ON;



/*
  1. Download the tSQLt framework from https://tsqlt.org/downloads/

  2. Execute tSQLt.class.sql in the database you want to install
     tSQLt framework
*/

/*
SELECT * FROM tSQLt.Info();
GO
*/