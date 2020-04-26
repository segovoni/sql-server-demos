------------------------------------------------------------------------
-- Event:        SQL Saturday Parma 2016, November 26                 --
--               http://www.sqlsaturday.com/566/EventHome.aspx        --
-- Session:      Common non-configured options on a Database Server   --
-- Demo:         Setup                                                --
-- Author:       Sergio Govoni                                        --
-- Notes:        --                                                   --
------------------------------------------------------------------------


USE [master];
GO

------------------------------------------------------------------------
-- TestLatchDB                                                        --
------------------------------------------------------------------------

-- Drop database TestLatchDB 
IF (DB_ID('TestLatchDB') IS NOT NULL)
BEGIN
  ALTER DATABASE [TestLatchDB]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

  DROP DATABASE [TestLatchDB];
END;
GO


-- Create database
CREATE DATABASE [TestLatchDB];
GO

/*
CREATE DATABASE [TestLatchDB]
  ON PRIMARY
  (
    NAME = TestLatchDB
    ,FILENAME = 'C:\SQL\DBs\TestLatchDB_Data.mdf'
  )
  LOG ON
  (
    NAME = TestLatchDB_Log
    ,FILENAME = 'C:\SQL\DBs\TestLatchDB_Log.ldf'
  );
GO
*/

USE [TestLatchDB];
GO


-- Create stored procedure
CREATE PROCEDURE dbo.usp_stress_tempdb
AS
BEGIN
  -- Create temporary table
  CREATE TABLE dbo.#TempTable
  (
    Col1 INTEGER IDENTITY(1, 1) NOT NULL
	,Col2 CHAR(4000)
	,Col3 CHAR(4000)
  );

  -- Create unique clustered index
  CREATE UNIQUE CLUSTERED INDEX uq_clidx_temptable_col1 ON dbo.#TempTable
  (
    [Col1]
  );

  -- Insert 10 records into the temporary table
  DECLARE
    @i INTEGER = 0;
  WHILE
    (@i < 10)
  BEGIN
    INSERT INTO dbo.#TempTable VALUES ('SQL Saturday Parma 2016', '#sqlsat566');
	SET @i = (@i + 1);
  END;
END;
GO


-- Create the loop stored procedure
CREATE PROCEDURE dbo.usp_loop_stress_tempdb
AS
BEGIN
  DECLARE
    @j INTEGER = 0;
  WHILE
    (@j < 100)
  BEGIN
    EXECUTE dbo.usp_stress_tempdb;
	SET @j = (@j + 1);
  END;
END;
GO


------------------------------------------------------------------------
-- tempdb                                                             --
------------------------------------------------------------------------

USE [tempdb];
GO
/*
DBCC SHRINKFILE (tempdev4, EmptyFile);
GO
ALTER DATABASE tempdb REMOVE FILE tempdev4;
GO
DBCC SHRINKFILE (tempdev3, EmptyFile);
GO
ALTER DATABASE tempdb REMOVE FILE tempdev3;
GO
DBCC SHRINKFILE (tempdev2, EmptyFile);
GO
ALTER DATABASE tempdb REMOVE FILE tempdev2;
GO
*/
SELECT
  name, physical_name AS CurrentLocation, *
FROM
  sys.master_files
WHERE
  (database_id = DB_ID(N'tempdb'));
GO

/*
-- Alter the tempdb data file size
ALTER DATABASE tempdb
  MODIFY FILE
  (
    NAME = 'tempdev'
    ,SIZE = 8MB
  );
GO

ALTER DATABASE tempdb
  MODIFY FILE
  (
    NAME = 'templog'
    ,SIZE = 8MB
  );
GO
*/