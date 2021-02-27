-------------------------------------------------------------------------
-- Event:       Data Saturday Pordenone 2021                            -
--              Feb 27 2021 - Virtual                                   -
--              https://datasaturdays.com/events/datasaturday0001.html  -
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