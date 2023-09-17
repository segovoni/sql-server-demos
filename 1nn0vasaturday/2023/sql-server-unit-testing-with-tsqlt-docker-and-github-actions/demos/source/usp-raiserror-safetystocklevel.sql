-------------------------------------------------------------------------
-- Event:      1nn0va Saturday 2023 - September 30                     --
--             https://1nn0vasat2023.1nn0va.it/agenda.html             --
--                                                                     --
-- Session:    SQL Server unit testing with tSQLt, Docker and          --
--             GitHub Actions                                          --
--                                                                     --
-- Script:     Create stored procedure usp_Raiserror_SafetyStockLevel  --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

/*
DECLARE @user AS SYSNAME;
SELECT
  @user = QUOTENAME(SL.Name)
FROM
  master..sysdatabases AS SD
INNER JOIN
  master..syslogins AS SL ON SD.SID = SL.SID
WHERE
  SD.Name = DB_NAME();
EXEC('EXEC sp_changedbowner ' + @user);
GO
*/

CREATE OR ALTER PROCEDURE Production.usp_Raiserror_SafetyStockLevel
(
  @Message NVARCHAR(256)
)
AS
BEGIN
  ROLLBACK;
  RAISERROR(@Message, 16, 1);
END;
GO
