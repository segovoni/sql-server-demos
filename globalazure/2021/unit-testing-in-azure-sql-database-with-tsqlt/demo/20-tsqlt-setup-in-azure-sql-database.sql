-------------------------------------------------------------------------
-- Event:       Global Azure 2021                                       -
--              Apr 15th-17th 2021 - Virtual                            -
--              https://globalazure.net/                                -
--                                                                      -
-- Session:     Unit testing in Azure SQL Database with tSQLt           -
-- Demo:        tSQLt framework setup                                   -
-- Author:      Sergio Govoni                                           -
-- Notes:       --                                                      -
-------------------------------------------------------------------------

/*
USE [AdventureWorks2017];
GO
*/


/*
  1. Download the tSQLt framework from https://tsqlt.org/downloads/
     (the version working with SQL 2005 and currently Azure SQL Databases)

  2. Execute tSQLt.class.sql in each Azure SQL database you want to install
     tSQLt framework
*/

SELECT * FROM tSQLt.Info();
GO