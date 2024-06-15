-------------------------------------------------------------------------
-- Event:      SQL Start 2024 - June 14                                --
--             https://www.sqlstart.it/                                --
--                                                                     --
-- Session:    SQL Server unit testing with tSQLt, Docker and          --
--             GitHub Actions                                          --
--                                                                     --
-- Demo:       Run all test cases                                      --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [AdventureWorks2022];
GO

-- Run all tests in the class
EXEC tSQLt.RunTestClass 'UnitTestTRProductSafetyStockLevel';
GO