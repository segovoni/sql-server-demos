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


CREATE TABLE dbo.DataSatPN
(
  ID INTEGER NOT NULL PRIMARY KEY
  ,ParentID INTEGER NULL
  ,ColData INTEGER NULL
);
GO


INSERT INTO dbo.DataSatPN
(ID, ParentID, ColData)
VALUES (1, 2, 99), (2, NULL, 88);
GO

SELECT * FROM dbo.DataSatPN;
GO



SELECT SUM(ColData)  -- 187
FROM dbo.DataSatPN
WHERE NOT EXISTS (SELECT *
                  FROM dbo.DataSatPN
                  WHERE ParentID = DataSatPN.ID);
GO

SELECT SUM(A.ColData)  -- 88
FROM dbo.DataSatPN AS A
WHERE NOT EXISTS (SELECT *
                  FROM dbo.DataSatPN AS B
                  WHERE A.ParentID = B.ID);
GO

DROP TABLE IF EXISTS dbo.DataSatPN;
GO