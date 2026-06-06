------------------------------------------------------------------------
-- Event:        Delphi Day 2026 - June 09-10                         --
--               https://www.delphiday.it/                            --
--                                                                    --
-- Session:      Azure SQL Database Essentials                        --
--                                                                    --
-- Demo:         Secondary replica connection                         --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------

-- https://learn.microsoft.com/azure/azure-sql/database/read-scale-out 

-- Connect to the secondary replica of an Azure SQL Database
-- using the ApplicationIntent=ReadOnly connection string parameter

-- Server=tcp:<server>.database.windows.net;Database=<mydatabase>;ApplicationIntent=ReadOnly;User ID=<myLogin>;Password=<password>;Trusted_Connection=False; Encrypt=True;


-- ApplicationIntent=ReadOnly

SELECT DATABASEPROPERTYEX(DB_NAME(), 'Updateability');
GO


CREATE TABLE dbo.TestReadOnly
(
  ID INTEGER PRIMARY KEY
  ,ContentValue NVARCHAR(100)
);
GO