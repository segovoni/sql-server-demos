------------------------------------------------------------------------
-- Event:        #DataWeekender CU5 - May 14th 2022                    -
--               A Pop-up and Online Microsoft Data Conference         -
--               https://www.dataweekender.com/                        -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Table alias                                           -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
GO

DROP TABLE IF EXISTS dbo.DataWeekender;
GO
CREATE TABLE dbo.DataWeekender
(
  ID INTEGER NOT NULL PRIMARY KEY
  ,ParentID INTEGER NULL
  ,ColData INTEGER NULL
);
GO
INSERT INTO dbo.DataWeekender
(ID, ParentID, ColData)
VALUES (1, 2, 99), (2, NULL, 88), (3, 4, 20), (4, NULL, 26);
GO
SELECT * FROM dbo.DataWeekender;
GO

-- You want to sum the all leaf levels
SELECT * FROM dbo.DataWeekender;
GO
SELECT SUM(ColData)  -- 233
FROM dbo.DataWeekender
WHERE NOT EXISTS (SELECT *
                  FROM dbo.DataWeekender
                  WHERE ParentID = DataWeekender.ID);
GO



-- In the last line of the query, DataWeekender.ID could in theory
-- refers to the table on the outer query, or the table in the subquery
-- The rule is that SQL Server tries to match within the same scope 
-- and only goes to an outer scope if needed

-- So here, the NOT EXISTS clause is not correlated; it simply checks
-- if the DataWeekender table has at least one row with ParentID equal to ID
-- and uses that to determine whether or not all rows from the outer
-- query qualify



-- When you have a query that uses more than one table
-- ALWAYS use aliases for all tables
-- ALWAYS prefix EACH column with the proper alias
SELECT SUM(A.ColData)  -- 114 (88 + 26)
FROM dbo.DataWeekender AS A
WHERE NOT EXISTS (SELECT *
                  FROM dbo.DataWeekender AS B
                  WHERE A.ParentID = B.ID);
GO


DROP TABLE IF EXISTS dbo.DataWeekender;
GO