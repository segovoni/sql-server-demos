-------------------------------------------------------------------------
-- Event:       Data Saturday Pordenone 2021                            -
--              Feb 27 2021 - Virtual                                   -
--              https://datasaturdays.com/events/datasaturday0001.html  -
--                                                                      -
-- Session:     Database development unit test with tSQLt               -
-- Demo:        tSQLt framework setup                                   -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
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


USE [AdventureWorks2017];
GO

-- Enable TRUSTWORTHY property at the database level
-- in each database you want to install tSQLt framework
ALTER DATABASE [AdventureWorks2017] SET TRUSTWORTHY ON;
GO


/*
  1. Download the tSQLt framework from https://tsqlt.org/downloads/

  2. Execute tSQLt.class.sql in the database you want to install
     tSQLt framework
*/

SELECT * FROM tSQLt.Info();
GO