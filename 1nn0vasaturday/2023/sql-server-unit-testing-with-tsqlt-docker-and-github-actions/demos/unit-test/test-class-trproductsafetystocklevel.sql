-------------------------------------------------------------------------
-- Event:      1nn0va Saturday 2023 - September 30                     --
--             https://1nn0vasat2023.1nn0va.it/agenda.html             --
--                                                                     --
-- Session:    SQL Server unit testing with tSQLt, Docker and          --
--             GitHub Actions                                          --
--                                                                     --
-- Script:     Create new test class UnitTestTRProductSafetyStockLevel --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- Create new test class
-- The test class collects test cases for this class
EXEC tSQLt.NewTestClass 'UnitTestTRProductSafetyStockLevel';
GO
