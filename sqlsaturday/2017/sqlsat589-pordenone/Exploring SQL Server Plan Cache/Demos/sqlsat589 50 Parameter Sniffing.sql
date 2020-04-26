------------------------------------------------------------------------
-- Event:        SQL Saturday #589 Pordenone, February 25, 2017        -
--               http://www.sqlsaturday.com/589/eventhome.aspx         -
-- Session:      Exploring SQL Server Plan Cache                       -
-- Demo:         Parameter Sniffing                                    -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [AdventureWorks];
GO

IF OBJECT_ID('usp_address', 'P') IS NOT NULL
  DROP PROCEDURE dbo.usp_address;
GO


CREATE PROCEDURE dbo.usp_address
(
  @city AS VARCHAR(30)
)
AS
BEGIN
  SELECT
    a.AddressID
    ,a.AddressLine1
    ,a.AddressLine2
    ,a.City
    ,sp.Name
    ,a.PostalCode
  FROM
    Person.Address AS a
  JOIN
    Person.StateProvince AS sp ON a.StateProvinceID=sp.StateProvinceID
  WHERE
    a.City = @city;
END;
GO


EXEC dbo.usp_address @city = 'London';
EXEC dbo.usp_address @city = 'Mentor';



--<ParameterList>
--    <ColumnReference Column="@city" ParameterCompiledValue="'London'"
--       ParameterRuntimeValue="'Mentor'" />
--</ParameterList>

dbcc freeproccache

-- plan_handle
SELECT
  est.text
  ,ecp.*
FROM
  sys.dm_exec_cached_plans AS ecp
CROSS APPLY
  sys.dm_exec_sql_text(ecp.plan_handle) AS est
WHERE
  est.text LIKE 'create procedure dbo.usp_address%'
  --est.text like '%dbo.usp_address%'


-- Remove plan from the cache
DBCC freeproccache(0x050007000D42C53730DB0BF30100000001000000000000000000000000000000000000000000000000000000)


-- Reverse order
EXEC dbo.usp_address @city = 'Mentor';
EXEC dbo.usp_address @city = 'London';
GO


ALTER PROCEDURE dbo.usp_address
(
  @city AS VARCHAR(30)
)
AS
BEGIN
  DECLARE @localcity VARCHAR(30);

  SET @localcity = @city

  SELECT
    a.AddressID
    ,a.AddressLine1
    ,a.AddressLine2
    ,a.City
    ,sp.Name
    ,a.PostalCode
  FROM
    Person.Address AS a
  JOIN
    Person.StateProvince AS sp ON a.StateProvinceID=sp.StateProvinceID
  WHERE
    a.City = @localcity;
END;
GO

EXEC dbo.usp_address @city = 'London';
EXEC dbo.usp_address @city = 'Mentor';

SELECT * FROM sp_cacheobjects WHERE dbid = DB_ID('AdventureWorks');
GO


ALTER PROCEDURE dbo.usp_address
(
  @city AS VARCHAR(30)
)
AS
BEGIN
  SELECT
    a.AddressID
    ,a.AddressLine1
    ,a.AddressLine2
    ,a.City
    ,sp.Name
    ,a.PostalCode
  FROM
    Person.Address AS a
  JOIN
    Person.StateProvince AS sp ON a.StateProvinceID=sp.StateProvinceID
  WHERE
    a.City = @city
  OPTION (optimize FOR (@city='London'))
END;
GO


EXEC dbo.usp_address @city = 'Mentor';
GO


ALTER PROCEDURE dbo.usp_address
(
  @city AS VARCHAR(30)
)
AS
BEGIN
  SELECT
    a.AddressID
    ,a.AddressLine1
    ,a.AddressLine2
    ,a.City
    ,sp.Name
    ,a.PostalCode
  FROM
    Person.Address AS a
  JOIN
    Person.StateProvince AS sp ON a.StateProvinceID=sp.StateProvinceID
  WHERE
    a.City = @city
  OPTION (optimize FOR (@city unknown))
END;
GO


EXEC dbo.usp_address @city = 'London';
GO