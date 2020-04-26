------------------------------------------------------------------------
-- Event:        SQL Saturday #675 Parma, November 18 2017             -
--               http://www.sqlsaturday.com/675/EventHome.aspx         -
-- Session:      SQL Server 2017 Graph Database                        -
-- Demo:         Nodes and Edges                                       -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


------------------------------------------------------------------------
-- Nodes                                                               -
------------------------------------------------------------------------

DROP TABLE IF EXISTS Nodes.Person;
GO

-- Create a node table
CREATE TABLE Nodes.Person
(
  PersonID INTEGER NOT NULL PRIMARY KEY
  ,FullName NVARCHAR(50) NOT NULL
  ,[Language] NVARCHAR(50) NOT NULL
) AS NODE;
GO


SELECT * FROM sys.tables WHERE is_node = 1;
GO

SELECT
  *
FROM
  INFORMATION_SCHEMA.COLUMNS
WHERE
  Table_Schema = 'Nodes'
  AND Table_Name = 'Person';
GO


/*
SELECT FullName, CustomFields, * 
FROM [Application].[People];
GO
*/

INSERT INTO Nodes.Person
(
  PersonID
  ,FullName
  ,[Language]
)
SELECT
  PersonID
  ,FullName
  ,[Language] = Languages.[Value]
FROM
  [Application].[People]
CROSS APPLY
  (SELECT * FROM OPENJSON (CustomFields, '$.OtherLanguages')) As Languages
WHERE
  Languages.[key] = 0;
GO


SELECT * FROM Nodes.Person


------------------------------------------------------------------------
-- Edges                                                               -
------------------------------------------------------------------------

DROP TABLE IF EXISTS Edges.Friends;

-- Create an edge table
CREATE TABLE Edges.Friends
(
  StartDate DATETIME NOT NULL
)
AS EDGE;
GO


SELECT * FROM sys.tables WHERE is_edge = 1;
GO

SELECT
  C.*
FROM
  sys.tables AS T
JOIN
  INFORMATION_SCHEMA.COLUMNS AS C ON C.Table_Name = T.[name] AND C.Table_Schema = SCHEMA_NAME(T.[schema_id])
WHERE
  (T.is_edge = 1)
ORDER BY
  C.Table_Schema, C.Table_Name
GO



-- Insert friends who speak the same language
-- (one direction)
-- If a person speaks Finnish, I take for granted that
-- their friends speak Finnish 
WITH Friends_Same_Language AS
(
  SELECT
    P1.$node_id AS From_Node_Id
    ,P2.$node_id AS To_Node_Id
    ,GETDATE() AS StartDate
    ,Direction = ROW_NUMBER() OVER (PARTITION BY P1.[Language], P2.[language] ORDER BY (SELECT NULL))
    ,From_FullName = P1.FullName
    ,From_Language = P1.[Language]
    ,To_FullName = P2.FullName
    ,To_Language = P2.[Language]
  FROM
    Nodes.Person AS P1
  INNER JOIN
    Nodes.Person AS P2 ON P1.[Language] = P2.[Language]
  WHERE
    -- The person itself isn't included
    (P1.$node_id <> P2.$node_id)
)
INSERT INTO Edges.Friends
(
  $from_id
  ,$to_id
  ,StartDate
)
SELECT
  From_Node_Id
  ,To_Node_Id
  ,StartDate
FROM
  Friends_Same_Language
WHERE
  (Direction = 1);
GO


SELECT * FROM Nodes.Person;
GO


-- Insert some random connections
INSERT INTO Edges.Friends
(
  $from_id
  ,$to_id
  ,StartDate
)
SELECT
  From_Node_Id
  ,To_Node_Id
  ,StartDate
FROM
(
  SELECT DISTINCT TOP 40
    New_ID = NEWID()
    ,P1.$node_id AS From_Node_Id
    ,P2.$node_id AS To_Node_Id
    ,GETDATE() AS StartDate
  FROM
    Nodes.Person AS P1
  INNER JOIN
    Nodes.Person AS P2 ON P1.[Language] < P2.[Language]
  WHERE
    (P1.$node_id <> P2.$node_id)
  ORDER BY
    New_ID
) AS T;
GO


SELECT * FROM Edges.Friends;

-- List of all guys that speak finnish with friends
-- Pattern: Node > Relationship > Node
SELECT
  P1.FullName
  ,P1.[Language]
  ,Friends_Number = COUNT(*)
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS Friends
  ,Nodes.Person AS P2
WHERE
  MATCH(P1-(Friends)->P2)
  AND (P1.[Language] = 'Finnish')
GROUP BY
  P1.FullName, P1.[Language]
ORDER BY
  Friends_Number DESC, P1.[Language];
GO




-- List of the top 5 people who have friends that speak Greek
-- in the first and second connections
SELECT
  TOP 5
  P1.FullName
  ,P1.[Language]
  ,GreekFriends = COUNT(*)
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS F1
  ,Nodes.Person AS P2
  ,Edges.Friends AS F2
  ,Nodes.Person AS P3
WHERE
  MATCH(P1-(F1)-> P2-(F2)-> P3)
  AND ((P2.[Language] = 'Greek') OR (P3.[Language] = 'Greek'))
GROUP BY
  P1.FullName, P1.[Language]
ORDER BY
  GreekFriends DESC, P1.[Language];
GO


-- People who have common friends that speak Croatian
SELECT
  P1.FullName
  ,P2.FullName
  ,P2.[Language]
  --,P3.FullName
FROM
  Nodes.Person AS P1
  ,Edges.Friends AS F1
  ,Nodes.Person AS P2
  ,Edges.Friends AS F2
  ,Nodes.Person AS P3
WHERE
  MATCH(P1-(F1)-> P2 <-(F2)-P3)
  AND (P2.[Language] = 'Croatian')
  AND (P1.$node_id <> P3.$node_id);
GO
