------------------------------------------------------------------------
-- Event:        DATA SATURDAY #20 - Pordenone 2022                    -
--               http://datasaturdays.com/2022-02-26-datasaturday0020/ -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Table alias                                           -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


DROP TABLE IF EXISTS dbo.DataSatPN;
GO

CREATE TABLE dbo.DataSatPN
(
  ID INTEGER NOT NULL PRIMARY KEY
  ,ParentID INTEGER NULL
  ,ColData INTEGER NULL
);
GO


INSERT INTO dbo.DataSatPN
(ID, ParentID, ColData)
VALUES (1, 2, 99), (2, NULL, 88), (3, 4, 20), (4, NULL, 26);
GO

SELECT * FROM dbo.DataSatPN;
GO


-- In the last line of this query, "DataSatPN.ID" could in theory
-- refers to the table on the outer query, or the table in the subquery.
-- The rule is that SQL Server tries to match within the same scope 
-- and only goes to an outer scope if needed.
-- So here, the NOT EXISTS clause is not correlated; it simply checks
-- if the DataSatPN table has at least one row with ParentID equal to ID
-- and uses that to determine whether or not all rows from the outer
-- query qualify
SELECT SUM(ColData)  -- 233
FROM dbo.DataSatPN
WHERE NOT EXISTS (SELECT *
                  FROM dbo.DataSatPN
                  WHERE ParentID = DataSatPN.ID);
GO


-- When you have a query that uses more than one table
-- ALWAYS use aliases for all tables
-- ALWAYS prefix EACH column with the proper alias
SELECT SUM(A.ColData)  -- 114 (88 + 26)
FROM dbo.DataSatPN AS A
WHERE NOT EXISTS (SELECT *
                  FROM dbo.DataSatPN AS B
                  WHERE A.ParentID = B.ID);
GO


DROP TABLE IF EXISTS dbo.DataSatPN;
GO