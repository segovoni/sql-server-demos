------------------------------------------------------------------------
-- Event:        Delphi Day 2023 - June 06-07                          -
--               https://www.delphiday.it/                             -
--                                                                     -
-- Session:      T-SQL performance tips & tricks!                      -
--                                                                     -
-- Demo:         Query mode execution and columnstore indexes          -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2022];
GO

SET STATISTICS IO ON;
GO

-- The Adaptive Join defines a threshold used to decide when to switch
-- to a Nested Loops instead of using an Hash Match Join

-- It is able to change the join strategy when necessary
-- in order to deal with different situations


DROP INDEX IF EXISTS Person.Address.IX_Person_Address
DROP PROCEDURE IF EXISTS dbo.GetAddress;
GO

CREATE OR ALTER PROCEDURE dbo.GetAddress
(
  @City VARCHAR(30)
)
AS
BEGIN
  --DECLARE @localcity VARCHAR(30);
  --SET @localcity = @City

  SELECT
    A.AddressID
    ,A.AddressLine1
    ,A.AddressLine2
    ,A.City
    ,SP.Name
    ,A.PostalCode
  FROM
    Person.Address AS A
  JOIN
    Person.StateProvince AS SP ON A.StateProvinceID=SP.StateProvinceID
  WHERE
    --A.City = @localcity;
    A.City = @City;
END;
GO


-- High selectivity
EXEC dbo.GetAddress @city = 'Nashville';



-- plan_handle
SELECT
  ecp.*
FROM
  sys.dm_exec_cached_plans AS ecp
CROSS APPLY
  sys.dm_exec_sql_text(ecp.plan_handle) AS est
WHERE
  est.text LIKE '%CREATE PROCEDURE GetAddress%';
GO


-- Remove plan
DBCC FREEPROCCACHE(0x06000800DA068F26E08EEF135C01000001000000000000000000000000000000000000000000000000000000)
EXEC dbo.sp_recompile 'dbo.GetAddress';


-- Medium-Low selectivity
EXEC dbo.GetAddress @city = 'London';
GO

DROP INDEX IF EXISTS Person.Address.IX_Person_Address
GO

CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Person_Address
  ON Person.Address (AddressID)
  WHERE ((AddressID = -1) AND (AddressID = -2))
GO



-- High selectivity
EXEC dbo.GetAddress @city = 'Nashville';
GO

-- Medium-Low selectivity
EXEC dbo.GetAddress @city = 'London';
GO