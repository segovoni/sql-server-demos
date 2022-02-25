------------------------------------------------------------------------
-- Event:        DATA SATURDAY #20 - Pordenone 2022                    -
--               http://datasaturdays.com/2022-02-26-datasaturday0020/ -
-- Session:      T-SQL magic tricks!                                   -
--                                                                     -
-- Demo:         Query mode processing                                 -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks2017];
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
DBCC FREEPROCCACHE(0x060008001E78B718E059AFA5EC01000001000000000000000000000000000000000000000000000000000000)
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
