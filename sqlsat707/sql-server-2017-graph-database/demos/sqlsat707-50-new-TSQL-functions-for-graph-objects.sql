------------------------------------------------------------------------
-- Event:        SQL Saturday #707 Pordenone, February 17 2018         -
--               http://www.sqlsaturday.com/707/eventhome.aspx         -
-- Session:      SQL Server 2017 Graph Database                        -
-- Demo:         New T-SQL functions for graph objects                 -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [WideWorldImporters];
GO


-- New columns have been added in the sys.tables system view
SELECT
  is_node
  ,is_edge
  ,[schema_name] = SCHEMA_NAME(schema_id)
  ,*
FROM
  sys.tables
WHERE
  ((is_node = 1) OR (is_edge = 1));
GO


-- New columns heve been added in sys.columns, they are used
-- to retrieve information about the type of the column in a
-- node or edge table
SELECT
  table_name = OBJECT_NAME([object_id])
  ,[name]
  ,graph_type
  ,graph_type_desc
  ,is_hidden
  ,collation_name
FROM
  sys.columns
WHERE
  (graph_type IS NOT NULL);
GO


SELECT * FROM Nodes.Person;
GO


-- GRAPH_ID_FROM_NODE_ID
-- OBJECT_ID_FROM_NODE_ID
-- NODE_ID_FROM_PARTS
SELECT
  graph_id_from_node_id = GRAPH_ID_FROM_NODE_ID($node_id)
  ,object_id_from_node_id = OBJECT_ID_FROM_NODE_ID($node_id)
  ,table_name = OBJECT_NAME(OBJECT_ID_FROM_NODE_ID($node_id))
  ,node_id = NODE_ID_FROM_PARTS(OBJECT_ID_FROM_NODE_ID($node_id),
                                GRAPH_ID_FROM_NODE_ID($node_id))
  ,$node_id
FROM
  Nodes.Person;
GO


SELECT * FROM Edges.Friends;
GO


-- GRAPH_ID_FROM_EDGE_ID
-- OBJECT_ID_FROM_EDGE_ID
-- EDGE_ID_FROM_PARTS
SELECT
  graph_id_from_edge_id = GRAPH_ID_FROM_EDGE_ID($edge_id)
  ,object_id_from_edge_id = OBJECT_ID_FROM_EDGE_ID($edge_id)
  ,table_name = OBJECT_NAME(OBJECT_ID_FROM_EDGE_ID($edge_id))
  ,edge_id = EDGE_ID_FROM_PARTS(OBJECT_ID_FROM_EDGE_ID($edge_id),
                                GRAPH_ID_FROM_EDGE_ID($edge_id))
  ,$edge_id
FROM
  Edges.Friends;
GO