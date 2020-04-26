--------------------------------------------------------------------------
-- Event:        SQL Saturday #264 - Ancona
-- Session:      Trigger: Utili o Dannosi?
-- Demo:         Trigger settings
-- Author:       Sergio Govoni
-- Notes:        -
--------------------------------------------------------------------------

USE [master];
GO


EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO


EXEC sp_configure;
GO


-- Default settings
EXEC sp_configure 'nested triggers', 1;
EXEC sp_configure 'disallow results from triggers', 0; --> Allow
EXEC sp_configure 'server trigger recursion', 1;
GO
RECONFIGURE;
GO
ALTER DATABASE [AdventureWorks2012] SET RECURSIVE_TRIGGERS OFF;
GO