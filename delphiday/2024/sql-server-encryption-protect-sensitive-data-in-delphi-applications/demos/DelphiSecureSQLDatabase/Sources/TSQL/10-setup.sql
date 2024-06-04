------------------------------------------------------------------------
-- Event:        Delphi Day 2024 - June 11-12                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      SQL Server Encryption: Data protection in a          --
--               Delphi Applications!                                 --
--                                                                    --
-- Demo:         Setup databases (reset DB)                           --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [master];
GO


-- Drop sample database
IF (DB_ID('AlwaysEncryptedDB') IS NOT NULL)
BEGIN
  ALTER DATABASE [AlwaysEncryptedDB]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [AlwaysEncryptedDB];
END;
GO


-- Create login with SID
IF EXISTS (SELECT principal_id FROM sys.sql_logins WHERE name = 'Delphi_User')
  DROP LOGIN [Delphi_User];

CREATE LOGIN [Delphi_User] WITH
  PASSWORD = 'DelphiDay2024!'
  ,SID = 0x7427B4ADC1F5F041AAD461C29DCDA151;

SELECT
  [name]
  ,principal_id
  ,[sid]
  ,[type_desc]
FROM
  sys.sql_logins
WHERE [name] = 'Delphi_User';
GO


CREATE DATABASE [AlwaysEncryptedDB]
 ON  PRIMARY 
 (
   NAME = N'AlwaysEncryptedDB'
   ,FILENAME = N'C:\SQL\DBs\AlwaysEncryptedDB.mdf'
   ,SIZE = 8192KB
   ,FILEGROWTH = 65536KB
 )
 LOG ON 
 (
   NAME = N'AlwaysEncryptedDB_log'
   ,FILENAME = N'C:\SQL\DBs\AlwaysEncryptedDB_log.ldf'
   ,SIZE = 8192KB
   ,FILEGROWTH = 65536KB
  )
GO


USE [AlwaysEncryptedDB];
GO


CREATE TABLE dbo.Persons
(
  ID INTEGER IDENTITY(1, 1) NOT NULL
  ,FirstName NVARCHAR(16) NOT NULL
  ,LastName NVARCHAR(16) NOT NULL
  ,BirthDate DATETIME2 NOT NULL
  ,SocialSecurityNumber CHAR(10) NOT NULL
   -- COLLATE Latin1_General_BIN2 NOT NULL
  ,CreditCardNumber CHAR(15)
   -- COLLATE Latin1_General_BIN2 NOT NULL
  ,Salary DECIMAL(19, 4) NOT NULL
   -- COLLATE Latin1_General_BIN2 NOT NULL
);
GO


INSERT INTO dbo.Persons
  (FirstName, LastName, BirthDate, SocialSecurityNumber, CreditCardNumber, Salary)
VALUES
  ('Rob', 'Walters', '1975-09-17 11:02:51', '1520273859', '372305256328259', 31692)
  ,('Gail', 'Erickson', '1978-09-18 15:03:55', '4520283752', '502301225345239', 40984);
GO


SELECT
  ID
  ,FirstName
  ,LastName
  ,BirthDate
  ,SocialSecurityNumber
  ,CreditCardNumber
  ,Salary
FROM
  dbo.Persons;
GO


-- Create database user from login
CREATE USER [Delphi_User] FOR LOGIN [Delphi_User]
  WITH DEFAULT_SCHEMA = dbo;

EXEC sp_addrolemember 'db_datareader', 'Delphi_User';
EXEC sp_addrolemember 'db_datawriter', 'Delphi_User';


SELECT * FROM master.sys.server_principals WHERE [sid] = 0x7427B4ADC1F5F041AAD461C29DCDA151
GO


-- Database master key (CMK)
SELECT * FROM sys.column_master_keys;

-- Column encryption keys (CEK)
SELECT * FROM sys.column_encryption_keys;
GO