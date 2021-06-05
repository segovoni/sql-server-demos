-------------------------------------------------------------------------
-- Event:       SQL Start 2021, June 11                                 -
--              https://www.sqlstart.it/2021/Speakers/Sergio-Govoni     -
--                                                                      -
-- Session:     Database development unit test with tSQLt               -
-- Demo:        Run all test cases                                      -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

-- Run all tests in the class
EXEC tSQLt.RunTestClass 'UnitTestTRProductSafetyStockLevel';
GO