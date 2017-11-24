------------------------------------------------------------------------
-- Event:        SQL Saturday #675 Parma, November 18 2017             -
--               http://www.sqlsaturday.com/675/EventHome.aspx         -
-- Session:      SQL Server 2017 Graph Database                        -
-- Demo:         Many-to-many Relationships                            -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO

-- Relational databases don't natively support many-to-many relationships

-- A common approach to realize many-to-many relationships is to introduce
-- a table that holds such relationships
-- Items and Groups in a warehouse share a many-to-many relationship,
-- an Item can belong to multiple Groups and a Group contains more Items

SELECT * FROM Warehouse.StockItems;
GO
SELECT * FROM Warehouse.StockGroups;
GO
SELECT * FROM Warehouse.StockItemStockGroups;
GO

SELECT
  P.StockItemName
  ,ATab.StockItemID
  ,ATab.StockGroupID
  ,G.StockGroupName
  ,ATab.StockItemStockGroupID
FROM
  Warehouse.StockItemStockGroups AS ATab
JOIN
  Warehouse.StockItems AS P ON P.StockItemID=ATab.StockItemID
JOIN
  Warehouse.StockGroups AS G ON G.StockGroupID=ATab.StockGroupID
ORDER BY
  ATab.StockItemStockGroupID ASC

-- An item can belong to multiple groups
SELECT
  P.StockItemID
  ,P.StockItemName
  ,G.StockGroupID
  ,G.StockGroupName
  ,G.LastEditedBy
FROM
  Warehouse.StockItems AS P
JOIN
  -- Association table
  Warehouse.StockItemStockGroups AS ATab ON ATab.StockItemID=P.StockItemID
JOIN
  Warehouse.StockGroups AS G ON G.StockGroupID=ATab.StockGroupID
WHERE
  P.StockItemName='USB food flash drive - pizza slice';
GO


-- A group can contain more items
SELECT
  G.StockGroupID
  ,G.StockGroupName
  ,P.StockItemID
  ,P.StockItemName
  ,P.LastEditedBy
FROM
  Warehouse.StockItems AS P
JOIN
  -- Association table
  Warehouse.StockItemStockGroups AS ATab ON ATab.StockItemID=P.StockItemID
JOIN
  Warehouse.StockGroups AS G ON G.StockGroupID=ATab.StockGroupID
WHERE
  G.StockGroupName='Computing Novelties';
GO


-- In the graph database theory StockItems and StockGroups are nodes
-- and StockItemStockGroups is the edge to connecting them

-- To write a query that connects StockItems with StockGroups via StockItemStockGroups,
-- instead of using JOIN operators:
FROM
  Warehouse.StockItems AS P
JOIN
  Warehouse.StockItemStockGroups AS ATab ON ATab.StockItemID=P.StockItemID
JOIN
  Warehouse.StockGroups AS G ON G.StockGroupID=ATab.StockGroupID


-- With SQL Graph you can use MATCH clause:
FROM
  Warehouse.StockItems AS P
  ,Warehouse.StockItemStockGroups AS ATab
  ,Warehouse.StockGroups AS G
MATCH (P-(ATab)->G)





-- Let's build the graph, create Nodes and Edges..

-- Create StockItems node
/*
DROP TABLE IF EXISTS Nodes.StockItems;
GO
*/
CREATE TABLE Nodes.StockItems
(
  StockItemID INTEGER IDENTITY(1, 1) NOT NULL
  ,StockItemName NVARCHAR(100) NOT NULL
  ,Barcode NVARCHAR(50) NULL
  ,Photo VARBINARY(MAX)  
  ,LastEditedBy INTEGER NOT NULL
)
AS NODE;
GO


-- Create StockGroups node
/*
DROP TABLE IF EXISTS Nodes.StockGroups;
GO
*/
CREATE TABLE Nodes.StockGroups
(
  StockGroupID INTEGER IDENTITY(1, 1) NOT NULL
  ,StockGroupName NVARCHAR(50) NOT NULL
  ,LastEditedBy INTEGER NOT NULL
)
AS NODE;


-- Create the edge from nodes StockItems and StockGroups, in the past
-- it was an association table
/*
DROP TABLE IF EXISTS Edges.ItemsBelongTo;
GO
*/
CREATE TABLE Edges.ItemsBelongTo AS EDGE;
GO


-- Let's insert some data into nodes and edges
SET IDENTITY_INSERT Nodes.StockItems ON;
GO

INSERT INTO Nodes.StockItems
(
  StockItemID
  ,StockItemName
  ,LastEditedBy
)
SELECT
  StockItemID
  ,StockItemName
  ,LastEditedBy
FROM
  Warehouse.StockItems;
GO

SET IDENTITY_INSERT Nodes.StockItems OFF;
GO


SET IDENTITY_INSERT Nodes.StockGroups ON;
GO

INSERT INTO Nodes.StockGroups
(
  StockGroupID
  ,StockGroupName
  ,LastEditedBy
)
SELECT
  StockGroupID
  ,StockGroupName
  ,LastEditedBy
FROM
  Warehouse.StockGroups;
GO

SET IDENTITY_INSERT Nodes.StockGroups OFF;
GO


-- This query to retrieves $node_id pairs to populate the edge table "ItemsBelongTo"
INSERT INTO Edges.ItemsBelongTo
(
  $from_id
  ,$to_id
)
SELECT
  P.$node_id
  ,G.$node_id
FROM
  Nodes.StockItems AS P
JOIN
  Warehouse.StockItemStockGroups AS ATab ON ATab.StockItemID=P.StockItemID
JOIN
  Nodes.StockGroups AS G ON G.StockGroupID=ATab.StockGroupID;
GO


-- Let's query the graph
SELECT
  G.StockGroupID
  ,G.StockGroupName
  ,G.LastEditedBy
FROM
  Nodes.StockItems AS P
  ,Edges.ItemsBelongTo AS BelongTo
  ,Nodes.StockGroups AS G
WHERE
  P.StockItemName='USB food flash drive - pizza slice'
  AND MATCH(P-(BelongTo)->G);
GO

-- Does the order of nodes in the MATCH clause matter?
SELECT
  G.StockGroupID
  ,G.StockGroupName
  ,G.LastEditedBy
FROM
  Nodes.StockItems AS P
  ,Edges.ItemsBelongTo AS BelongTo
  ,Nodes.StockGroups AS G
WHERE
  P.StockItemName='USB food flash drive - pizza slice'
  AND MATCH(G-(BelongTo)->P);
GO

-- No rows are returned because of the direction of the edge
-- We defined the graph has having Items belonging to Groups and not the opposite

-- The direction of the arrow matters, not the order of the nodes in the MATCH,
-- as you can see in the follow query
SELECT
  G.StockGroupID
  ,G.StockGroupName
  ,G.LastEditedBy
FROM
  Nodes.StockItems AS P
  ,Edges.ItemsBelongTo AS BelongTo
  ,Nodes.StockGroups AS G
WHERE
  P.StockItemName='USB food flash drive - pizza slice'
  AND MATCH(G<-(BelongTo)-P);
GO


SELECT
  P.StockItemID
  ,P.StockItemName
  ,P.LastEditedBy
FROM
  Nodes.StockItems AS P
  ,Edges.ItemsBelongTo AS BelongTo
  ,Nodes.StockGroups AS G
WHERE
  G.StockGroupName='Computing Novelties'
  AND MATCH(P-(BelongTo)->G);
GO