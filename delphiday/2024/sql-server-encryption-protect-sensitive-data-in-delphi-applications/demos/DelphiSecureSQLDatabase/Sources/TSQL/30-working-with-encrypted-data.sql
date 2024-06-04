------------------------------------------------------------------------
-- Event:        Delphi Day 2024 - June 11-12                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      SQL Server Encryption: Data protection in a          --
--               Delphi Applications!                                 --
--                                                                    --
-- Demo:         Working with Always Encrypted database               --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

USE [AlwaysEncryptedDB];
GO


-- Enable Always Encrypted (column encryption) set to disabled
-- Query the dbo.Persons

-- SSMS will not be able to decrypt the data stored in the encrypted columns;
-- the following query will return the encrypted data
SELECT * FROM dbo.Persons;
GO

SELECT * FROM dbo.Persons WHERE LastName = 'Hirtzmann';
GO

SELECT * FROM dbo.Persons WHERE SocialSecurityNumber = '4895529150';
GO


-- Enable Always Encrypted (column encryption) set to enabled
-- SSMS will attempt to decrypt the data stored in the encrypted columns
-- using the previously created cryptographic keys
SELECT * FROM dbo.Persons;
GO

SELECT * FROM dbo.Persons WHERE SocialSecurityNumber = '4895529150';
GO


-- Enabling parameterization for Always Encrypted
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-query-columns-ssms#enabling-and-disabling-parameterization-for-always-encrypted


DECLARE
  @SocialSecurityNumber CHAR(10) = '4895529150';
SELECT * FROM dbo.Persons WHERE SocialSecurityNumber = @SocialSecurityNumber;
GO


SELECT MAX(BirthDate) AS MaxBirthDate FROM dbo.Persons;
SELECT YEAR(BirthDate) AS YearBirthDate FROM dbo.Persons;
GO

SELECT 'SSN: ' + SocialSecurityNumber FROM dbo.Persons; 
GO

-- Let's try to insert a new record in the dbo.Persons

-- This query will fail
INSERT INTO dbo.Persons
  (FirstName, LastName, BirthDate, SocialSecurityNumber, CreditCardNumber, Salary)
VALUES
  ('Janice', 'Galvin', '1979-09-21 10:08:51', '6875189805', '337951212597372', $38115);
GO


-- Operand type clash: varchar is incompatible with varchar(8000)
-- encrypted with (encryption_type = 'DETERMINISTIC', 
-- encryption_algorithm_name = 'AEAD_AES_256_CBC_HMAC_SHA_256', 
-- column_encryption_key_name = 'CEK_Auto1', 
-- column_encryption_key_database_name = 'AlwaysEncryptedDB') 
-- collation_name = 'SQL_Latin1_General_CP1_CI_AS'

-- When a query tries to insert data into encrypted columns or when it attempts 
-- to filter data based on one or more encrypted columns, passing values or
-- T-SQL variables corresponding to the encrypted columns is not supported

-- Inserting values into encrypted columns is allowed only using parameters


-- Enabling parameterization for Always Encrypted
-- https://learn.microsoft.com/sql/relational-databases/security/encryption/always-encrypted-query-columns-ssms#enabling-and-disabling-parameterization-for-always-encrypted


DECLARE
  @SocialSecurityNumber CHAR(10) = '6875189805'
  ,@CreditCardNumber CHAR(15) = '337951212597372'
  ,@BirthDate DATETIME2 = '1979-09-21'
  ,@Salary DECIMAL(19, 4) = 38115;

INSERT INTO dbo.Persons
  (FirstName, LastName, BirthDate, SocialSecurityNumber, CreditCardNumber, Salary)
VALUES
  ('Janice', 'Galvin', @BirthDate, @SocialSecurityNumber, @CreditCardNumber, @Salary);
GO




-- UPDATEs into a table with encrypted columns
DECLARE
  @Salary DECIMAL(19, 4) = 38615;

UPDATE
  dbo.Persons
SET
  Salary = @Salary
WHERE
  FirstName = 'Janice';
GO


DECLARE
  @SocialSecurityNumber CHAR(10) = '6875899805';

UPDATE
  dbo.Persons
SET
  SocialSecurityNumber = @SocialSecurityNumber
WHERE
  FirstName = 'Janice';
GO