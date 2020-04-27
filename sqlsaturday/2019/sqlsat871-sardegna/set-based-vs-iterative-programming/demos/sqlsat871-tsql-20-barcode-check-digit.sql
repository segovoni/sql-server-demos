------------------------------------------------------------------------
-- Event:        SQL Saturday #871 Sardegna 2019, May 18               -
-- Session:      Set-based vs Iterative programming                    -
-- https://www.sqlsaturday.com/871/Sessions/Details.aspx?sid=94179     -
-- Demo:         Barcode check-digit                                   -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

-- https://blogs.msdn.microsoft.com/mvpawardprogram/2017/06/20/barcode-check-digit-t-sql/


USE [AdventureWorks2017];
GO


DROP TABLE IF EXISTS Production.ProductBC;
GO

CREATE TABLE Production.ProductBC
(
  ProductID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY
  ,ProductName NVARCHAR(40) NOT NULL
  ,EAN13 VARCHAR(13) NOT NULL
   CONSTRAINT CHK_Valid_EAN
   CHECK(EAN13 LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO


SELECT * FROM Production.ProductBC;
GO


-- The UCC/EAN standard coding requires that every (well-formed) code
-- ends with a check-digit that will be used by barcode readers
-- to interpret the code properly

-- The check-digit is a number between zero and nine and it is calculated
-- according to the other digits in the code

-- The EAN13 column of the table Production.ProductBC stores the EAN13 of
-- the products

-- You want to implement a CHECK constraint to be sure that check-digit
-- of the EAN13 code is correct



-- Let's implement the algorithm using T-SQL language, the user-defined
-- scalar-valued function udf_get_check_digit_ucc_ean13 is most natural
-- and obvious solution

CREATE OR ALTER FUNCTION Production.udf_get_check_digit_ucc_ean13
(
  @ACode AS VARCHAR(12)
) 
RETURNS SMALLINT
AS BEGIN
  /*
    Author:  Sergio Govoni
    Notes:   Calculate the check-digit for an EAN13 code
    Version: 1.0
  */
  DECLARE
    @tmpCode AS VARCHAR(12)
    ,@tmpMulSup AS VARCHAR(8000)
    ,@tmp AS VARCHAR(8000)
    ,@i AS INT
    ,@j AS INT
    ,@z AS INT
    ,@SumDEven AS INT 
    ,@SumDOdd AS INT
    ,@List AS VARCHAR(8000)
    ,@tmpList AS VARCHAR(8000)
    ,@CheckSum AS SMALLINT
 
  SET @SumDEven = 0
  SET @SumDOdd = 0
  SET @List = ''
  SET @tmpList = ''
  SET @tmp = ''
  SET @tmpCode = @ACode
 
  /* 0. List builder */
  SET @j = LEN(@tmpCode) + 1
  SET @i = 1
  WHILE (@i <= LEN(@tmpCode)) BEGIN SET @List = @List + '|' + LTRIM(RTRIM(STR(@j))) + ';' + SUBSTRING(@tmpCode, @i, 1) SET @j = (@j - 1) SET @i = (@i + 1) END /* 1. Add up the digits in even position */ SET @i = 1 SET @tmpList = @List WHILE (CHARINDEX('|', @tmpList) > 0)
  BEGIN
    SET @j = CHARINDEX('|', @tmpList)
    SET @z = CHARINDEX(';', @tmpList)
    IF (CAST(SUBSTRING(@tmpList, (@j + 1), (@z - (@j + 1))) AS INTEGER) % 2) = 0
    BEGIN
      SET @SumDEven = @SumDEven + CAST(SUBSTRING(@tmpList, (@z + 1), 1) AS INTEGER)
    END
    SET @tmpList = SUBSTRING(@tmpList, (@z + 2), LEN(@tmpList))
  END
 
  /* 2. Multiply the result of the previous step (the first step) to 3 (three) */
  SET @SumDEven = (@SumDEven * 3)
 
  /* 3. Add up the digits in the odd positions */
  SET @i = 1
  SET @tmpList = @List
  WHILE (CHARINDEX('|', @tmpList) > 0)
  BEGIN
    SET @j = CHARINDEX('|', @tmpList)
    SET @z = CHARINDEX(';', @tmpList)
    IF (CAST(SUBSTRING(@tmpList, (@j + 1), (@z - (@j + 1))) AS INTEGER) % 2) <> 0
    BEGIN
      SET @SumDOdd = @SumDOdd + CAST(SUBSTRING(@tmpList, (@z + 1), 1) AS INTEGER)
    END
    SET @tmpList = SUBSTRING(@tmpList, (@z + 2), LEN(@tmpList))
  END
 
  /* 4. Add up the results obtained in steps two and three */
  SET @CheckSum = (@SumDEven + @SumDOdd)
 
 /* 5. Subtract the upper multiple of 10 from the result obtained in step four */
  IF ((@CheckSum % 10) = 0)
  BEGIN
    /* If the result of the four step is a multiple of Ten (10), like
       Twenty, Thirty, Forty and so on,
       the check-digit will be equal to zero, otherwise the check-digit will be
       the result of the fifth step
    */
    SET @CheckSum = 0
  END
  ELSE BEGIN
    SET @tmpMulSup = LTRIM(RTRIM(STR(@CheckSum)))
    
    SET @i = 0
    WHILE @i <= (LEN(@tmpMulSup) - 1)
    BEGIN
      SET @tmp = @tmp + SUBSTRING(@tmpMulSup, @i, 1)
      IF (@i = LEN(@tmpMulSup) - 1)
      BEGIN
        SET @tmp = LTRIM(RTRIM(STR(CAST(@tmp AS INTEGER) + 1)))
        SET @tmp = @tmp + '0'
      END
      SET @i = (@i + 1)
    END
    SET @CheckSum = CAST(@tmp AS INTEGER) - @CheckSum
  END
  RETURN @CheckSum
END;
GO


-- Let's create the check constraint
-- ALTER TABLE Production.ProductBC DROP CONSTRAINT CHK_Good_EAN
ALTER TABLE Production.ProductBC
  ADD CONSTRAINT CHK_Good_EAN
  CHECK(CAST(SUBSTRING(EAN13, 13, 1) AS INTEGER) = Production.udf_get_check_digit_ucc_ean13(SUBSTRING(EAN13, 1, 12)));
GO


-- Insert a new product with a right EAN13 code
INSERT INTO Production.ProductBC
(
  ProductName
  ,EAN13
)
VALUES
(
  '#sqlsat871'
  ,'8001020304057'
);
GO


-- Insert a new product with a wrong EAN13 code
INSERT INTO Production.ProductBC
(
  ProductName
  ,EAN13
)
VALUES
(
  'SQL Saturday Sardegna 2019'
  ,'8001020304050'
);
GO


SELECT * FROM Production.ProductBC;
GO


-- The first version of the function dbo.udf_get_check_digit_ucc_ean13
-- has been implemented with a row-by-row approach

-- Is it really the best solution?

-- Let's think outside the code

-- The code is just a tool

-- We have to try to find out the logical solution
-- and then translate it into T-SQL commands







-- Let's drop the check constraint
ALTER TABLE Production.ProductBC DROP CONSTRAINT CHK_Good_EAN;
GO





-- Set-based version of the function udf_get_check_digit_ucc_ean13
CREATE OR ALTER FUNCTION Production.udf_get_check_digit_ucc_ean13
(
  @ACode AS VARCHAR(12)
)
RETURNS INTEGER
AS BEGIN
  RETURN (10 - (3* CAST(SUBSTRING('0' + @ACode, 1, 1) AS INTEGER)
                + CAST(SUBSTRING('0' + @ACode, 2, 1) AS INTEGER)
                + 3* CAST(SUBSTRING('0' + @ACode, 3, 1) AS INTEGER)
                + CAST(SUBSTRING('0' + @ACode, 4, 1) AS INTEGER)
                + 3* CAST(SUBSTRING('0' + @ACode, 5, 1) AS INTEGER)
                + CAST(SUBSTRING('0' + @ACode, 6, 1) AS INTEGER)
                + 3* CAST(SUBSTRING('0' + @ACode, 7, 1) AS INTEGER)
                + CAST(SUBSTRING('0' + @ACode, 8, 1) AS INTEGER)
                + 3* CAST(SUBSTRING('0' + @ACode, 9, 1) AS INTEGER)
                + CAST(SUBSTRING('0' + @ACode, 10, 1) AS INTEGER)
                + 3* CAST(SUBSTRING('0' + @ACode, 11, 1) AS INTEGER)
                + CAST(SUBSTRING('0' + @ACode, 12, 1) AS INTEGER)
                + 3* CAST(SUBSTRING('0' + @ACode, 13, 1) AS INTEGER)
               )%10
         )%10
END;
GO


-- Creazione del vincolo CHECK
ALTER TABLE Production.ProductBC
  ADD CONSTRAINT CHK_Good_EAN
  CHECK(CAST(SUBSTRING(EAN13, 13, 1) AS INTEGER) = Production.udf_get_check_digit_ucc_ean13(SUBSTRING(EAN13, 1, 12)));
GO


INSERT INTO Production.ProductBC
(
 ProductName, EAN13
)
VALUES
('SQL Server T-SQL Fundamentals', '8000000000019'),
('T-SQL Querying', '8100011122202'),
('SQL Server MVP Deep Dives Volume 2', '8109090908066');
GO

SELECT * FROM Production.ProductBC;


SELECT
  Production.udf_get_check_digit_ucc_ean13('810909090806');
GO


-- Double check
SELECT
  *
  ,Production.udf_get_check_digit_ucc_ean13(EAN13) AS CheckDigit
FROM
  Production.ProductBC;
GO


-- Cleanup

ALTER TABLE Production.ProductBC DROP CONSTRAINT CHK_Good_EAN;
GO

DROP FUNCTION IF EXISTS Production.udf_get_check_digit_ucc_ean13;
GO

DROP TABLE IF EXISTS Production.ProductBC;
GO
