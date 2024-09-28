-------------------------------------------------------------------------
-- Event:      1nn0va Saturday 2024 - September 28                     --
--             https://1nn0vasat2024.1nn0va.it/agenda.html             --
--                                                                     --
-- Session:    SQL Server Maintenance Plan: Fundamentals and best      --
--             practices                                               --
--                                                                     --
-- Script:     View data pages                                         --
-- Author:     Sergio Govoni                                           --
-- Notes:      --                                                      --
-------------------------------------------------------------------------

USE [StackOverflowMini-LiveDemo];
GO


/*

88888888ba,                              d8'                    88                  88           
88      `"8b                            d8'  ,d                 88                  ""    ,d     
88        `8b                          ""    88                 88                        88     
88         88   ,adPPYba,   8b,dPPYba,     MM88MMM      ,adPPYb,88   ,adPPYba,      88  MM88MMM  
88         88  a8"     "8a  88P'   `"8a      88        a8"    `Y88  a8"     "8a     88    88     
88         8P  8b       d8  88       88      88        8b       88  8b       d8     88    88     
88      .a8P   "8a,   ,a8"  88       88      88,       "8a,   ,d88  "8a,   ,a8"     88    88,    
88888888Y"'     `"YbbdP"'   88       88      "Y888      `"8bbdP"Y8   `"YbbdP"'      88    "Y888  

*/                                                 


DBCC TRACEON (3604);
GO

-- Body "The most important differences for plain T-SQL are"
SELECT
  sys.fn_PhysLocFormatter(%%physloc%%) PageId
  ,*
FROM
  [dbo].[Posts]
WHERE
  ID = 41847
ORDER BY
  ID DESC;
GO


/*
DBCC PAGE ( {'dbname' | dbid}, filenum, pagenum [, printopt={0|1|2|3} ])
*/
-- Body: The most important differences for plain T-SQL are:
-- (1:207590:3)
DBCC PAGE ('StackOverflowMini-LiveDemo', 1, 207590, 3);
GO