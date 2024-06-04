------------------------------------------------------------------------
-- Event:        Delphi Day 2024 - June 11-12                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      SQL Server Encryption: Data protection in a          --
--               Delphi Applications!                                 --
--                                                                    --
-- Demo:         Setup SQL Server Always Encrypted                    --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [master];
GO

-- SQL Server encryption
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/sql-server-encryption?WT.mc_id=DP-MVP-4029181

-- Always Encrypted documentation
-- https://learn.microsoft.com/azure/azure-sql/database/always-encrypted-landing?WT.mc_id=DP-MVP-4029181

-- Analyze the impacts due to the possible change of COLLATE for the encrypted columns
-- https://learn.microsoft.com/sql/relational-databases/collations/collation-and-unicode-support?WT.mc_id=DP-MVP-4029181

-- Analyze possible impacts on client applications (parametric queries, connection strings, supported drivers)
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-client-development?WT.mc_id=DP-MVP-4029181

-- How queries against encrypted columns work
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-database-engine?WT.mc_id=DP-MVP-4029181#how-queries-against-encrypted-columns-work

-- Analyze existing Limitations
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-database-engine?WT.mc_id=DP-MVP-4029181#limitations

-- Configure Always Encrypted using SQL Server Management Studio
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/configure-always-encrypted-using-sql-server-management-studio?WT.mc_id=DP-MVP-4029181

-- Microsoft ODBC Driver for SQL Server on Windows
-- https://learn.microsoft.com/sql/connect/odbc/windows/microsoft-odbc-driver-for-sql-server-on-windows?WT.mc_id=DP-MVP-4029181

-- Working with column master key stores
-- https://learn.microsoft.com/sql/connect/odbc/using-always-encrypted-with-the-odbc-driver?WT.mc_id=DP-MVP-4029181#working-with-column-master-key-stores

-- Database permissions
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-database-engine?WT.mc_id=DP-MVP-4029181#database-permissions

USE [AlwaysEncryptedDB];
GO

-- GRANT permissions to [Delphi_User]  
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [Delphi_User];
GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [Delphi_User];
GO

SELECT
  ID
  ,FirstName
  ,LastName
  ,SocialSecurityNumber
  ,CreditCardNumber
  ,Salary
FROM
  dbo.Persons;
GO