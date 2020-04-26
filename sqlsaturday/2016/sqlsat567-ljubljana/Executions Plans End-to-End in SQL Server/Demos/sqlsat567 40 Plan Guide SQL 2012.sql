------------------------------------------------------------------------
-- Event:        SQL Saturday #567 Ljubljana, December 10 2016         -
--               http://www.sqlsaturday.com/567/eventhome.aspx         -
-- Session:      Executions Plans End-to-End in SQL Server             -
-- Demo:         Plan Guide                                            -
-- Author:       Sergio Govoni                                         -
-- Notes:        --                                                    -
------------------------------------------------------------------------

USE [PlanGuide]; -- ***SQL Server 2012***
GO


-- This demo is based on a real case I have experienced


DBCC FREEPROCCACHE;
GO


-- The following query deletes the closed positions around invoice and payments,
-- this is a part of the procedure and it should delete 6 thousand 5 hundred rows
-- the exact number is 6572!

-- The query is executed within a transaction that will be rolled back 
-- at the end of the execution, so that I can repeat it more than once :)

-- Each time the query is executed, it deletes a different number of rows,
-- BUT it doesn't work like that!


-- This query SHOULD delete 6572 rows!
BEGIN TRANSACTION;
GO
DELETE FROM dbo.DeadLines
WHERE
  (ISVISIBLE=-1)
  AND EXISTS (SELECT DL2.ACCOUNTID
              FROM dbo.DeadLines AS DL2 
              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)
                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  
                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)
                  AND (DeadLines.ANUMBER=DL2.ANUMBER)
				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)
  				        AND (DL2.ASTATE IS NULL)
			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER 
                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) < 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) > -0.000000100000000)
			         );
GO
ROLLBACK;
GO



-- Turn on the trace flags 3604 and 8607
-- TF 3604 enables the output to the message tab
-- TF 8607 shows the optimization output tree (output tree, PhyOps)
DBCC FREEPROCCACHE;
GO
DBCC TRACEON(3604, 8607);
GO



/*
BEGIN TRANSACTION;
GO
DELETE FROM dbo.DeadLines
WHERE
  (ISVISIBLE=-1)
  AND EXISTS (SELECT DL2.ACCOUNTID
              FROM dbo.DeadLines AS DL2 
              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)
                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  
                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)
                  AND (DeadLines.ANUMBER=DL2.ANUMBER)
				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)
  				        AND (DL2.ASTATE IS NULL)
			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER 
                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) < 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) > -0.000000100000000)
			         )
OPTION (RECOMPILE, QUERYTRACEON 8607);
GO
ROLLBACK;
GO
*/



-- USE PLAN
BEGIN TRANSACTION;
DELETE FROM dbo.DeadLines
WHERE
  (ISVISIBLE=-1)
  AND EXISTS (SELECT DL2.ACCOUNTID
              FROM dbo.DeadLines AS DL2 
              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)
                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  
                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)
                  AND (DeadLines.ANUMBER=DL2.ANUMBER)
				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)
  				        AND (DL2.ASTATE IS NULL)
			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER 
                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) < 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) > -0.000000100000000)
			         )
OPTION (USE PLAN N'<?xml version="1.0" encoding="utf-16"?>
<ShowPlanXML xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Version="1.1" Build="10.50.2500.0" xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan">
  <BatchSequence>
    <Batch>
      <Statements>
        <StmtSimple StatementCompId="1" StatementEstRows="334.187" StatementId="1" StatementOptmLevel="FULL" StatementSubTreeCost="5.89961" StatementText="DELETE FROM dbo.DeadLines&#xD;&#xA;WHERE&#xD;&#xA;  (ISVISIBLE=-1)&#xD;&#xA;  AND EXISTS (SELECT DL2.ACCOUNTID&#xD;&#xA;              FROM dbo.DeadLines AS DL2 &#xD;&#xA;              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)&#xD;&#xA;                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  &#xD;&#xA;                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)&#xD;&#xA;                  AND (DeadLines.ANUMBER=DL2.ANUMBER)&#xD;&#xA;				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)&#xD;&#xA;  				        AND (DL2.ASTATE IS NULL)&#xD;&#xA;			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER &#xD;&#xA;                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) &lt; 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) &gt; -0.000000100000000)&#xD;&#xA;			         )" StatementType="DELETE" QueryHash="0xB4557475BCF0AB0B" QueryPlanHash="0xE13A49AD4A46CD5E">
          <StatementSetOptions ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" NUMERIC_ROUNDABORT="false" QUOTED_IDENTIFIER="true" />
          <QueryPlan DegreeOfParallelism="2" MemoryGrant="1056" CachedPlanSize="64" CompileTime="125" CompileCPU="125" CompileMemory="1848">
            <MissingIndexes>
              <MissingIndexGroup Impact="47.7521">
                <MissingIndex Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]">
                  <ColumnGroup Usage="EQUALITY">
                    <Column Name="[ISVISIBLE]" ColumnId="107" />
                  </ColumnGroup>
                  <ColumnGroup Usage="INCLUDE">
                    <Column Name="[ACCOUNTID]" ColumnId="4" />
                    <Column Name="[ADATE]" ColumnId="5" />
                    <Column Name="[ANUMBER]" ColumnId="6" />
                  </ColumnGroup>
                </MissingIndex>
              </MissingIndexGroup>
            </MissingIndexes>
            <RelOp AvgRowSize="9" EstimateCPU="0.00133675" EstimateIO="1.21999" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="334.187" LogicalOp="Delete" NodeId="0" Parallel="false" PhysicalOp="Table Delete" EstimatedTotalSubtreeCost="5.89961">
              <OutputList />
              <RunTimeInformation>
                <RunTimeCountersPerThread Thread="0" ActualRows="4890" ActualEndOfScans="1" ActualExecutions="1" />
              </RunTimeInformation>
              <Update DMLRequestSort="false">
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" IndexKind="Heap" />
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_0_DeadLines]" IndexKind="NonClustered" />
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_1_DeadLines]" IndexKind="NonClustered" />
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_2_DeadLines]" IndexKind="NonClustered" />
                <RelOp AvgRowSize="15" EstimateCPU="3.34187E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="334.187" LogicalOp="Top" NodeId="1" Parallel="false" PhysicalOp="Top" EstimatedTotalSubtreeCost="4.67828">
                  <OutputList>
                    <ColumnReference Column="Bmk1000" />
                  </OutputList>
                  <RunTimeInformation>
                    <RunTimeCountersPerThread Thread="0" ActualRows="4890" ActualEndOfScans="1" ActualExecutions="1" />
                  </RunTimeInformation>
                  <Top RowCount="true" IsPercent="false" WithTies="false">
                    <TopExpression>
                      <ScalarOperator ScalarString="(0)">
                        <Const ConstValue="(0)" />
                      </ScalarOperator>
                    </TopExpression>
                    <RelOp AvgRowSize="15" EstimateCPU="4.8747E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="3341.73" LogicalOp="Filter" NodeId="3" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="4.67825">
                      <OutputList>
                        <ColumnReference Column="Bmk1000" />
                      </OutputList>
                      <RunTimeInformation>
                        <RunTimeCountersPerThread Thread="0" ActualRows="4890" ActualEndOfScans="1" ActualExecutions="1" />
                      </RunTimeInformation>
                      <Filter StartupExpression="false">
                        <RelOp AvgRowSize="23" EstimateCPU="5.53943E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="55.3943" LogicalOp="Compute Scalar" NodeId="5" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="4.6782">
                          <OutputList>
                            <ColumnReference Column="Bmk1000" />
                            <ColumnReference Column="Expr1007" />
                          </OutputList>
                          <ComputeScalar>
                            <DefinedValues>
                              <DefinedValue>
                                <ColumnReference Column="Expr1007" />
                                <ScalarOperator ScalarString="CASE WHEN [globalagg1014]=(0) THEN NULL ELSE [globalagg1016] END">
                                  <IF>
                                    <Condition>
                                      <ScalarOperator>
                                        <Compare CompareOp="EQ">
                                          <ScalarOperator>
                                            <Identifier>
                                              <ColumnReference Column="globalagg1014" />
                                            </Identifier>
                                          </ScalarOperator>
                                          <ScalarOperator>
                                            <Const ConstValue="(0)" />
                                          </ScalarOperator>
                                        </Compare>
                                      </ScalarOperator>
                                    </Condition>
                                    <Then>
                                      <ScalarOperator>
                                        <Const ConstValue="NULL" />
                                      </ScalarOperator>
                                    </Then>
                                    <Else>
                                      <ScalarOperator>
                                        <Identifier>
                                          <ColumnReference Column="globalagg1016" />
                                        </Identifier>
                                      </ScalarOperator>
                                    </Else>
                                  </IF>
                                </ScalarOperator>
                              </DefinedValue>
                            </DefinedValues>
                            <RelOp AvgRowSize="31" EstimateCPU="9.24761E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="55.3943" LogicalOp="Aggregate" NodeId="6" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="4.6782">
                              <OutputList>
                                <ColumnReference Column="Bmk1000" />
                                <ColumnReference Column="globalagg1014" />
                                <ColumnReference Column="globalagg1016" />
                              </OutputList>
                              <RunTimeInformation>
                                <RunTimeCountersPerThread Thread="0" ActualRows="7541" ActualEndOfScans="1" ActualExecutions="1" />
                              </RunTimeInformation>
                              <StreamAggregate>
                                <DefinedValues>
                                  <DefinedValue>
                                    <ColumnReference Column="globalagg1014" />
                                    <ScalarOperator ScalarString="SUM([partialagg1013])">
                                      <Aggregate AggType="SUM" Distinct="false">
                                        <ScalarOperator>
                                          <Identifier>
                                            <ColumnReference Column="partialagg1013" />
                                          </Identifier>
                                        </ScalarOperator>
                                      </Aggregate>
                                    </ScalarOperator>
                                  </DefinedValue>
                                  <DefinedValue>
                                    <ColumnReference Column="globalagg1016" />
                                    <ScalarOperator ScalarString="SUM([partialagg1015])">
                                      <Aggregate AggType="SUM" Distinct="false">
                                        <ScalarOperator>
                                          <Identifier>
                                            <ColumnReference Column="partialagg1015" />
                                          </Identifier>
                                        </ScalarOperator>
                                      </Aggregate>
                                    </ScalarOperator>
                                  </DefinedValue>
                                </DefinedValues>
                                <GroupBy>
                                  <ColumnReference Column="Bmk1000" />
                                </GroupBy>
                                <RelOp AvgRowSize="31" EstimateCPU="0.0292676" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="107.965" LogicalOp="Gather Streams" NodeId="7" Parallel="true" PhysicalOp="Parallelism" EstimatedTotalSubtreeCost="4.6781">
                                  <OutputList>
                                    <ColumnReference Column="Bmk1000" />
                                    <ColumnReference Column="partialagg1013" />
                                    <ColumnReference Column="partialagg1015" />
                                  </OutputList>
                                  <RunTimeInformation>
                                    <RunTimeCountersPerThread Thread="0" ActualRows="7541" ActualEndOfScans="1" ActualExecutions="1" />
                                  </RunTimeInformation>
                                  <Parallelism>
                                    <OrderBy>
                                      <OrderByColumn Ascending="true">
                                        <ColumnReference Column="Bmk1000" />
                                      </OrderByColumn>
                                    </OrderBy>
                                    <RelOp AvgRowSize="31" EstimateCPU="0.000114971" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="107.965" LogicalOp="Aggregate" NodeId="8" Parallel="true" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="4.64883">
                                      <OutputList>
                                        <ColumnReference Column="Bmk1000" />
                                        <ColumnReference Column="partialagg1013" />
                                        <ColumnReference Column="partialagg1015" />
                                      </OutputList>
                                      <RunTimeInformation>
                                        <RunTimeCountersPerThread Thread="1" ActualRows="3444" ActualEndOfScans="1" ActualExecutions="1" />
                                        <RunTimeCountersPerThread Thread="2" ActualRows="4097" ActualEndOfScans="1" ActualExecutions="1" />
                                        <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                      </RunTimeInformation>
                                      <StreamAggregate>
                                        <DefinedValues>
                                          <DefinedValue>
                                            <ColumnReference Column="partialagg1013" />
                                            <ScalarOperator ScalarString="COUNT_BIG([Expr1012])">
                                              <Aggregate AggType="COUNT_BIG" Distinct="false">
                                                <ScalarOperator>
                                                  <Identifier>
                                                    <ColumnReference Column="Expr1012" />
                                                  </Identifier>
                                                </ScalarOperator>
                                              </Aggregate>
                                            </ScalarOperator>
                                          </DefinedValue>
                                          <DefinedValue>
                                            <ColumnReference Column="partialagg1015" />
                                            <ScalarOperator ScalarString="SUM([Expr1012])">
                                              <Aggregate AggType="SUM" Distinct="false">
                                                <ScalarOperator>
                                                  <Identifier>
                                                    <ColumnReference Column="Expr1012" />
                                                  </Identifier>
                                                </ScalarOperator>
                                              </Aggregate>
                                            </ScalarOperator>
                                          </DefinedValue>
                                        </DefinedValues>
                                        <GroupBy>
                                          <ColumnReference Column="Bmk1000" />
                                        </GroupBy>
                                        <RelOp AvgRowSize="23" EstimateCPU="0.00192484" EstimateIO="0.00563063" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="293.266" LogicalOp="Sort" NodeId="9" Parallel="true" PhysicalOp="Sort" EstimatedTotalSubtreeCost="4.64872">
                                          <OutputList>
                                            <ColumnReference Column="Bmk1000" />
                                            <ColumnReference Column="Expr1012" />
                                          </OutputList>
                                          <MemoryFractions Input="1" Output="1" />
                                          <RunTimeInformation>
                                            <RunTimeCountersPerThread Thread="1" ActualRebinds="1" ActualRewinds="0" ActualRows="17481" ActualEndOfScans="1" ActualExecutions="1" />
                                            <RunTimeCountersPerThread Thread="2" ActualRebinds="1" ActualRewinds="0" ActualRows="18020" ActualEndOfScans="1" ActualExecutions="1" />
                                            <RunTimeCountersPerThread Thread="0" ActualRebinds="0" ActualRewinds="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                          </RunTimeInformation>
                                          <Sort Distinct="false">
                                            <OrderBy>
                                              <OrderByColumn Ascending="true">
                                                <ColumnReference Column="Bmk1000" />
                                              </OrderByColumn>
                                            </OrderBy>
                                            <RelOp AvgRowSize="23" EstimateCPU="1.46633E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="293.266" LogicalOp="Compute Scalar" NodeId="10" Parallel="true" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="4.64116">
                                              <OutputList>
                                                <ColumnReference Column="Bmk1000" />
                                                <ColumnReference Column="Expr1012" />
                                              </OutputList>
                                              <ComputeScalar>
                                                <DefinedValues>
                                                  <DefinedValue>
                                                    <ColumnReference Column="Expr1012" />
                                                    <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[TOTALDUE] as [DL2].[TOTALDUE]*CONVERT_IMPLICIT(float(53),[PlanGuide].[dbo].[DeadLines].[TRANSACTIONTYPE] as [DL2].[TRANSACTIONTYPE],0)">
                                                      <Arithmetic Operation="MULT">
                                                        <ScalarOperator>
                                                          <Identifier>
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                          </Identifier>
                                                        </ScalarOperator>
                                                        <ScalarOperator>
                                                          <Convert DataType="float" Scale="0" Style="0" Implicit="true">
                                                            <ScalarOperator>
                                                              <Identifier>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                              </Identifier>
                                                            </ScalarOperator>
                                                          </Convert>
                                                        </ScalarOperator>
                                                      </Arithmetic>
                                                    </ScalarOperator>
                                                  </DefinedValue>
                                                </DefinedValues>
                                                <RelOp AvgRowSize="26" EstimateCPU="0.000621665" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="297.447" LogicalOp="Inner Join" NodeId="11" Parallel="true" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="4.64108">
                                                  <OutputList>
                                                    <ColumnReference Column="Bmk1000" />
                                                    <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                    <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                  </OutputList>
                                                  <RunTimeInformation>
                                                    <RunTimeCountersPerThread Thread="2" ActualRows="18020" ActualEndOfScans="1" ActualExecutions="1" />
                                                    <RunTimeCountersPerThread Thread="1" ActualRows="17481" ActualEndOfScans="1" ActualExecutions="1" />
                                                    <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                  </RunTimeInformation>
                                                  <NestedLoops Optimized="false" WithUnorderedPrefetch="true">
                                                    <OuterReferences>
                                                      <ColumnReference Column="Bmk1004" />
                                                      <ColumnReference Column="Expr1021" />
                                                    </OuterReferences>
                                                    <RelOp AvgRowSize="23" EstimateCPU="0.0157607" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="297.447" LogicalOp="Inner Join" NodeId="13" Parallel="true" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="4.41911">
                                                      <OutputList>
                                                        <ColumnReference Column="Bmk1000" />
                                                        <ColumnReference Column="Bmk1004" />
                                                      </OutputList>
                                                      <RunTimeInformation>
                                                        <RunTimeCountersPerThread Thread="2" ActualRows="18591" ActualEndOfScans="1" ActualExecutions="1" />
                                                        <RunTimeCountersPerThread Thread="1" ActualRows="18296" ActualEndOfScans="1" ActualExecutions="1" />
                                                        <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                      </RunTimeInformation>
                                                      <NestedLoops Optimized="false" WithUnorderedPrefetch="true">
                                                        <OuterReferences>
                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                          <ColumnReference Column="Expr1020" />
                                                        </OuterReferences>
                                                        <RelOp AvgRowSize="38" EstimateCPU="0.0041868" EstimateIO="2.8395" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="7541" LogicalOp="Table Scan" NodeId="15" Parallel="true" PhysicalOp="Table Scan" EstimatedTotalSubtreeCost="2.84369" TableCardinality="7541">
                                                          <OutputList>
                                                            <ColumnReference Column="Bmk1000" />
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                          </OutputList>
                                                          <RunTimeInformation>
                                                            <RunTimeCountersPerThread Thread="2" ActualRows="4097" ActualEndOfScans="1" ActualExecutions="1" />
                                                            <RunTimeCountersPerThread Thread="1" ActualRows="3444" ActualEndOfScans="1" ActualExecutions="1" />
                                                            <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                          </RunTimeInformation>
                                                          <TableScan Ordered="true" ForcedIndex="false" ForceScan="false" NoExpandHint="false">
                                                            <DefinedValues>
                                                              <DefinedValue>
                                                                <ColumnReference Column="Bmk1000" />
                                                              </DefinedValue>
                                                              <DefinedValue>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                              </DefinedValue>
                                                              <DefinedValue>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                              </DefinedValue>
                                                              <DefinedValue>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                              </DefinedValue>
                                                            </DefinedValues>
                                                            <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" IndexKind="Heap" />
                                                            <Predicate>
                                                              <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ISVISIBLE]=(-1)">
                                                                <Compare CompareOp="EQ">
                                                                  <ScalarOperator>
                                                                    <Identifier>
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ISVISIBLE" />
                                                                    </Identifier>
                                                                  </ScalarOperator>
                                                                  <ScalarOperator>
                                                                    <Const ConstValue="(-1)" />
                                                                  </ScalarOperator>
                                                                </Compare>
                                                              </ScalarOperator>
                                                            </Predicate>
                                                          </TableScan>
                                                        </RelOp>
                                                        <RelOp AvgRowSize="15" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="7540" EstimateRewinds="0" EstimateRows="1" LogicalOp="Index Seek" NodeId="16" Parallel="true" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="1.55786" TableCardinality="7541">
                                                          <OutputList>
                                                            <ColumnReference Column="Bmk1004" />
                                                          </OutputList>
                                                          <RunTimeInformation>
                                                            <RunTimeCountersPerThread Thread="2" ActualRows="18591" ActualEndOfScans="4097" ActualExecutions="4097" />
                                                            <RunTimeCountersPerThread Thread="1" ActualRows="18296" ActualEndOfScans="3444" ActualExecutions="3444" />
                                                            <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                          </RunTimeInformation>
                                                          <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false">
                                                            <DefinedValues>
                                                              <DefinedValue>
                                                                <ColumnReference Column="Bmk1004" />
                                                              </DefinedValue>
                                                            </DefinedValues>
                                                            <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_2_DeadLines]" Alias="[DL2]" IndexKind="NonClustered" />
                                                            <SeekPredicates>
                                                              <SeekPredicateNew>
                                                                <SeekKeys>
                                                                  <Prefix ScanType="EQ">
                                                                    <RangeColumns>
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ACCOUNTID" />
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ADATE" />
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ANUMBER" />
                                                                    </RangeColumns>
                                                                    <RangeExpressions>
                                                                      <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ACCOUNTID]">
                                                                        <Identifier>
                                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                      <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ADATE]">
                                                                        <Identifier>
                                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                      <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ANUMBER]">
                                                                        <Identifier>
                                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                    </RangeExpressions>
                                                                  </Prefix>
                                                                </SeekKeys>
                                                              </SeekPredicateNew>
                                                            </SeekPredicates>
                                                          </IndexScan>
                                                        </RelOp>
                                                      </NestedLoops>
                                                    </RelOp>
                                                    <RelOp AvgRowSize="18" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="292.153" EstimateRewinds="4.29416" EstimateRows="293.266" LogicalOp="RID Lookup" NodeId="18" Parallel="true" PhysicalOp="RID Lookup" EstimatedTotalSubtreeCost="0.221343" TableCardinality="7541">
                                                      <OutputList>
                                                        <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                        <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                      </OutputList>
                                                      <RunTimeInformation>
                                                        <RunTimeCountersPerThread Thread="2" ActualRows="18020" ActualEndOfScans="571" ActualExecutions="18591" />
                                                        <RunTimeCountersPerThread Thread="1" ActualRows="17481" ActualEndOfScans="815" ActualExecutions="18296" />
                                                        <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                      </RunTimeInformation>
                                                      <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false">
                                                        <DefinedValues>
                                                          <DefinedValue>
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                          </DefinedValue>
                                                          <DefinedValue>
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                          </DefinedValue>
                                                        </DefinedValues>
                                                        <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" TableReferenceId="-1" IndexKind="Heap" />
                                                        <SeekPredicates>
                                                          <SeekPredicateNew>
                                                            <SeekKeys>
                                                              <Prefix ScanType="EQ">
                                                                <RangeColumns>
                                                                  <ColumnReference Column="Bmk1004" />
                                                                </RangeColumns>
                                                                <RangeExpressions>
                                                                  <ScalarOperator ScalarString="[Bmk1004]">
                                                                    <Identifier>
                                                                      <ColumnReference Column="Bmk1004" />
                                                                    </Identifier>
                                                                  </ScalarOperator>
                                                                </RangeExpressions>
                                                              </Prefix>
                                                            </SeekKeys>
                                                          </SeekPredicateNew>
                                                        </SeekPredicates>
                                                        <Predicate>
                                                          <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ASTATE] as [DL2].[ASTATE] IS NULL">
                                                            <Compare CompareOp="IS">
                                                              <ScalarOperator>
                                                                <Identifier>
                                                                  <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ASTATE" />
                                                                </Identifier>
                                                              </ScalarOperator>
                                                              <ScalarOperator>
                                                                <Const ConstValue="NULL" />
                                                              </ScalarOperator>
                                                            </Compare>
                                                          </ScalarOperator>
                                                        </Predicate>
                                                      </IndexScan>
                                                    </RelOp>
                                                  </NestedLoops>
                                                </RelOp>
                                              </ComputeScalar>
                                            </RelOp>
                                          </Sort>
                                        </RelOp>
                                      </StreamAggregate>
                                    </RelOp>
                                  </Parallelism>
                                </RelOp>
                              </StreamAggregate>
                            </RelOp>
                          </ComputeScalar>
                        </RelOp>
                        <Predicate>
                          <ScalarOperator ScalarString="[Expr1007]&gt;(-1.000000000000000e-007) AND [Expr1007]&lt;(1.000000000000000e-007)">
                            <Logical Operation="AND">
                              <ScalarOperator>
                                <Compare CompareOp="GT">
                                  <ScalarOperator>
                                    <Identifier>
                                      <ColumnReference Column="Expr1007" />
                                    </Identifier>
                                  </ScalarOperator>
                                  <ScalarOperator>
                                    <Const ConstValue="(-1.000000000000000e-007)" />
                                  </ScalarOperator>
                                </Compare>
                              </ScalarOperator>
                              <ScalarOperator>
                                <Compare CompareOp="LT">
                                  <ScalarOperator>
                                    <Identifier>
                                      <ColumnReference Column="Expr1007" />
                                    </Identifier>
                                  </ScalarOperator>
                                  <ScalarOperator>
                                    <Const ConstValue="(1.000000000000000e-007)" />
                                  </ScalarOperator>
                                </Compare>
                              </ScalarOperator>
                            </Logical>
                          </ScalarOperator>
                        </Predicate>
                      </Filter>
                    </RelOp>
                  </Top>
                </RelOp>
              </Update>
            </RelOp>
          </QueryPlan>
        </StmtSimple>
      </Statements>
    </Batch>
  </BatchSequence>
</ShowPlanXML>');
ROLLBACK;
GO




-- Creazione di una Plan Guide
DECLARE @xml_plan NVARCHAR(MAX) = '';

SET @xml_plan = N'OPTION (USE PLAN N''<?xml version="1.0" encoding="utf-16"?>
<ShowPlanXML xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Version="1.1" Build="10.50.2500.0" xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan">
  <BatchSequence>
    <Batch>
      <Statements>
        <StmtSimple StatementCompId="1" StatementEstRows="334.187" StatementId="1" StatementOptmLevel="FULL" StatementSubTreeCost="5.89961" StatementText="DELETE FROM dbo.DeadLines&#xD;&#xA;WHERE&#xD;&#xA;  (ISVISIBLE=-1)&#xD;&#xA;  AND EXISTS (SELECT DL2.ACCOUNTID&#xD;&#xA;              FROM dbo.DeadLines AS DL2 &#xD;&#xA;              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)&#xD;&#xA;                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  &#xD;&#xA;                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)&#xD;&#xA;                  AND (DeadLines.ANUMBER=DL2.ANUMBER)&#xD;&#xA;				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)&#xD;&#xA;  				        AND (DL2.ASTATE IS NULL)&#xD;&#xA;			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER &#xD;&#xA;                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) &lt; 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) &gt; -0.000000100000000)&#xD;&#xA;			         )" StatementType="DELETE" QueryHash="0xB4557475BCF0AB0B" QueryPlanHash="0xE13A49AD4A46CD5E">
          <StatementSetOptions ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" NUMERIC_ROUNDABORT="false" QUOTED_IDENTIFIER="true" />
          <QueryPlan DegreeOfParallelism="2" MemoryGrant="1056" CachedPlanSize="64" CompileTime="125" CompileCPU="125" CompileMemory="1848">
            <MissingIndexes>
              <MissingIndexGroup Impact="47.7521">
                <MissingIndex Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]">
                  <ColumnGroup Usage="EQUALITY">
                    <Column Name="[ISVISIBLE]" ColumnId="107" />
                  </ColumnGroup>
                  <ColumnGroup Usage="INCLUDE">
                    <Column Name="[ACCOUNTID]" ColumnId="4" />
                    <Column Name="[ADATE]" ColumnId="5" />
                    <Column Name="[ANUMBER]" ColumnId="6" />
                  </ColumnGroup>
                </MissingIndex>
              </MissingIndexGroup>
            </MissingIndexes>
            <RelOp AvgRowSize="9" EstimateCPU="0.00133675" EstimateIO="1.21999" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="334.187" LogicalOp="Delete" NodeId="0" Parallel="false" PhysicalOp="Table Delete" EstimatedTotalSubtreeCost="5.89961">
              <OutputList />
              <RunTimeInformation>
                <RunTimeCountersPerThread Thread="0" ActualRows="4890" ActualEndOfScans="1" ActualExecutions="1" />
              </RunTimeInformation>
              <Update DMLRequestSort="false">
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" IndexKind="Heap" />
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_0_DeadLines]" IndexKind="NonClustered" />
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_1_DeadLines]" IndexKind="NonClustered" />
                <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_2_DeadLines]" IndexKind="NonClustered" />
                <RelOp AvgRowSize="15" EstimateCPU="3.34187E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="334.187" LogicalOp="Top" NodeId="1" Parallel="false" PhysicalOp="Top" EstimatedTotalSubtreeCost="4.67828">
                  <OutputList>
                    <ColumnReference Column="Bmk1000" />
                  </OutputList>
                  <RunTimeInformation>
                    <RunTimeCountersPerThread Thread="0" ActualRows="4890" ActualEndOfScans="1" ActualExecutions="1" />
                  </RunTimeInformation>
                  <Top RowCount="true" IsPercent="false" WithTies="false">
                    <TopExpression>
                      <ScalarOperator ScalarString="(0)">
                        <Const ConstValue="(0)" />
                      </ScalarOperator>
                    </TopExpression>
                    <RelOp AvgRowSize="15" EstimateCPU="4.8747E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="3341.73" LogicalOp="Filter" NodeId="3" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="4.67825">
                      <OutputList>
                        <ColumnReference Column="Bmk1000" />
                      </OutputList>
                      <RunTimeInformation>
                        <RunTimeCountersPerThread Thread="0" ActualRows="4890" ActualEndOfScans="1" ActualExecutions="1" />
                      </RunTimeInformation>
                      <Filter StartupExpression="false">
                        <RelOp AvgRowSize="23" EstimateCPU="5.53943E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="55.3943" LogicalOp="Compute Scalar" NodeId="5" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="4.6782">
                          <OutputList>
                            <ColumnReference Column="Bmk1000" />
                            <ColumnReference Column="Expr1007" />
                          </OutputList>
                          <ComputeScalar>
                            <DefinedValues>
                              <DefinedValue>
                                <ColumnReference Column="Expr1007" />
                                <ScalarOperator ScalarString="CASE WHEN [globalagg1014]=(0) THEN NULL ELSE [globalagg1016] END">
                                  <IF>
                                    <Condition>
                                      <ScalarOperator>
                                        <Compare CompareOp="EQ">
                                          <ScalarOperator>
                                            <Identifier>
                                              <ColumnReference Column="globalagg1014" />
                                            </Identifier>
                                          </ScalarOperator>
                                          <ScalarOperator>
                                            <Const ConstValue="(0)" />
                                          </ScalarOperator>
                                        </Compare>
                                      </ScalarOperator>
                                    </Condition>
                                    <Then>
                                      <ScalarOperator>
                                        <Const ConstValue="NULL" />
                                      </ScalarOperator>
                                    </Then>
                                    <Else>
                                      <ScalarOperator>
                                        <Identifier>
                                          <ColumnReference Column="globalagg1016" />
                                        </Identifier>
                                      </ScalarOperator>
                                    </Else>
                                  </IF>
                                </ScalarOperator>
                              </DefinedValue>
                            </DefinedValues>
                            <RelOp AvgRowSize="31" EstimateCPU="9.24761E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="55.3943" LogicalOp="Aggregate" NodeId="6" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="4.6782">
                              <OutputList>
                                <ColumnReference Column="Bmk1000" />
                                <ColumnReference Column="globalagg1014" />
                                <ColumnReference Column="globalagg1016" />
                              </OutputList>
                              <RunTimeInformation>
                                <RunTimeCountersPerThread Thread="0" ActualRows="7541" ActualEndOfScans="1" ActualExecutions="1" />
                              </RunTimeInformation>
                              <StreamAggregate>
                                <DefinedValues>
                                  <DefinedValue>
                                    <ColumnReference Column="globalagg1014" />
                                    <ScalarOperator ScalarString="SUM([partialagg1013])">
                                      <Aggregate AggType="SUM" Distinct="false">
                                        <ScalarOperator>
                                          <Identifier>
                                            <ColumnReference Column="partialagg1013" />
                                          </Identifier>
                                        </ScalarOperator>
                                      </Aggregate>
                                    </ScalarOperator>
                                  </DefinedValue>
                                  <DefinedValue>
                                    <ColumnReference Column="globalagg1016" />
                                    <ScalarOperator ScalarString="SUM([partialagg1015])">
                                      <Aggregate AggType="SUM" Distinct="false">
                                        <ScalarOperator>
                                          <Identifier>
                                            <ColumnReference Column="partialagg1015" />
                                          </Identifier>
                                        </ScalarOperator>
                                      </Aggregate>
                                    </ScalarOperator>
                                  </DefinedValue>
                                </DefinedValues>
                                <GroupBy>
                                  <ColumnReference Column="Bmk1000" />
                                </GroupBy>
                                <RelOp AvgRowSize="31" EstimateCPU="0.0292676" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="107.965" LogicalOp="Gather Streams" NodeId="7" Parallel="true" PhysicalOp="Parallelism" EstimatedTotalSubtreeCost="4.6781">
                                  <OutputList>
                                    <ColumnReference Column="Bmk1000" />
                                    <ColumnReference Column="partialagg1013" />
                                    <ColumnReference Column="partialagg1015" />
                                  </OutputList>
                                  <RunTimeInformation>
                                    <RunTimeCountersPerThread Thread="0" ActualRows="7541" ActualEndOfScans="1" ActualExecutions="1" />
                                  </RunTimeInformation>
                                  <Parallelism>
                                    <OrderBy>
                                      <OrderByColumn Ascending="true">
                                        <ColumnReference Column="Bmk1000" />
                                      </OrderByColumn>
                                    </OrderBy>
                                    <RelOp AvgRowSize="31" EstimateCPU="0.000114971" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="107.965" LogicalOp="Aggregate" NodeId="8" Parallel="true" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="4.64883">
                                      <OutputList>
                                        <ColumnReference Column="Bmk1000" />
                                        <ColumnReference Column="partialagg1013" />
                                        <ColumnReference Column="partialagg1015" />
                                      </OutputList>
                                      <RunTimeInformation>
                                        <RunTimeCountersPerThread Thread="1" ActualRows="3444" ActualEndOfScans="1" ActualExecutions="1" />
                                        <RunTimeCountersPerThread Thread="2" ActualRows="4097" ActualEndOfScans="1" ActualExecutions="1" />
                                        <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                      </RunTimeInformation>
                                      <StreamAggregate>
                                        <DefinedValues>
                                          <DefinedValue>
                                            <ColumnReference Column="partialagg1013" />
                                            <ScalarOperator ScalarString="COUNT_BIG([Expr1012])">
                                              <Aggregate AggType="COUNT_BIG" Distinct="false">
                                                <ScalarOperator>
                                                  <Identifier>
                                                    <ColumnReference Column="Expr1012" />
                                                  </Identifier>
                                                </ScalarOperator>
                                              </Aggregate>
                                            </ScalarOperator>
                                          </DefinedValue>
                                          <DefinedValue>
                                            <ColumnReference Column="partialagg1015" />
                                            <ScalarOperator ScalarString="SUM([Expr1012])">
                                              <Aggregate AggType="SUM" Distinct="false">
                                                <ScalarOperator>
                                                  <Identifier>
                                                    <ColumnReference Column="Expr1012" />
                                                  </Identifier>
                                                </ScalarOperator>
                                              </Aggregate>
                                            </ScalarOperator>
                                          </DefinedValue>
                                        </DefinedValues>
                                        <GroupBy>
                                          <ColumnReference Column="Bmk1000" />
                                        </GroupBy>
                                        <RelOp AvgRowSize="23" EstimateCPU="0.00192484" EstimateIO="0.00563063" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="293.266" LogicalOp="Sort" NodeId="9" Parallel="true" PhysicalOp="Sort" EstimatedTotalSubtreeCost="4.64872">
                                          <OutputList>
                                            <ColumnReference Column="Bmk1000" />
                                            <ColumnReference Column="Expr1012" />
                                          </OutputList>
                                          <MemoryFractions Input="1" Output="1" />
                                          <RunTimeInformation>
                                            <RunTimeCountersPerThread Thread="1" ActualRebinds="1" ActualRewinds="0" ActualRows="17481" ActualEndOfScans="1" ActualExecutions="1" />
                                            <RunTimeCountersPerThread Thread="2" ActualRebinds="1" ActualRewinds="0" ActualRows="18020" ActualEndOfScans="1" ActualExecutions="1" />
                                            <RunTimeCountersPerThread Thread="0" ActualRebinds="0" ActualRewinds="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                          </RunTimeInformation>
                                          <Sort Distinct="false">
                                            <OrderBy>
                                              <OrderByColumn Ascending="true">
                                                <ColumnReference Column="Bmk1000" />
                                              </OrderByColumn>
                                            </OrderBy>
                                            <RelOp AvgRowSize="23" EstimateCPU="1.46633E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="293.266" LogicalOp="Compute Scalar" NodeId="10" Parallel="true" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="4.64116">
                                              <OutputList>
                                                <ColumnReference Column="Bmk1000" />
                                                <ColumnReference Column="Expr1012" />
                                              </OutputList>
                                              <ComputeScalar>
                                                <DefinedValues>
                                                  <DefinedValue>
                                                    <ColumnReference Column="Expr1012" />
                                                    <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[TOTALDUE] as [DL2].[TOTALDUE]*CONVERT_IMPLICIT(float(53),[PlanGuide].[dbo].[DeadLines].[TRANSACTIONTYPE] as [DL2].[TRANSACTIONTYPE],0)">
                                                      <Arithmetic Operation="MULT">
                                                        <ScalarOperator>
                                                          <Identifier>
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                          </Identifier>
                                                        </ScalarOperator>
                                                        <ScalarOperator>
                                                          <Convert DataType="float" Scale="0" Style="0" Implicit="true">
                                                            <ScalarOperator>
                                                              <Identifier>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                              </Identifier>
                                                            </ScalarOperator>
                                                          </Convert>
                                                        </ScalarOperator>
                                                      </Arithmetic>
                                                    </ScalarOperator>
                                                  </DefinedValue>
                                                </DefinedValues>
                                                <RelOp AvgRowSize="26" EstimateCPU="0.000621665" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="297.447" LogicalOp="Inner Join" NodeId="11" Parallel="true" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="4.64108">
                                                  <OutputList>
                                                    <ColumnReference Column="Bmk1000" />
                                                    <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                    <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                  </OutputList>
                                                  <RunTimeInformation>
                                                    <RunTimeCountersPerThread Thread="2" ActualRows="18020" ActualEndOfScans="1" ActualExecutions="1" />
                                                    <RunTimeCountersPerThread Thread="1" ActualRows="17481" ActualEndOfScans="1" ActualExecutions="1" />
                                                    <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                  </RunTimeInformation>
                                                  <NestedLoops Optimized="false" WithUnorderedPrefetch="true">
                                                    <OuterReferences>
                                                      <ColumnReference Column="Bmk1004" />
                                                      <ColumnReference Column="Expr1021" />
                                                    </OuterReferences>
                                                    <RelOp AvgRowSize="23" EstimateCPU="0.0157607" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="297.447" LogicalOp="Inner Join" NodeId="13" Parallel="true" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="4.41911">
                                                      <OutputList>
                                                        <ColumnReference Column="Bmk1000" />
                                                        <ColumnReference Column="Bmk1004" />
                                                      </OutputList>
                                                      <RunTimeInformation>
                                                        <RunTimeCountersPerThread Thread="2" ActualRows="18591" ActualEndOfScans="1" ActualExecutions="1" />
                                                        <RunTimeCountersPerThread Thread="1" ActualRows="18296" ActualEndOfScans="1" ActualExecutions="1" />
                                                        <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                      </RunTimeInformation>
                                                      <NestedLoops Optimized="false" WithUnorderedPrefetch="true">
                                                        <OuterReferences>
                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                          <ColumnReference Column="Expr1020" />
                                                        </OuterReferences>
                                                        <RelOp AvgRowSize="38" EstimateCPU="0.0041868" EstimateIO="2.8395" EstimateRebinds="0" EstimateRewinds="0" EstimateRows="7541" LogicalOp="Table Scan" NodeId="15" Parallel="true" PhysicalOp="Table Scan" EstimatedTotalSubtreeCost="2.84369" TableCardinality="7541">
                                                          <OutputList>
                                                            <ColumnReference Column="Bmk1000" />
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                          </OutputList>
                                                          <RunTimeInformation>
                                                            <RunTimeCountersPerThread Thread="2" ActualRows="4097" ActualEndOfScans="1" ActualExecutions="1" />
                                                            <RunTimeCountersPerThread Thread="1" ActualRows="3444" ActualEndOfScans="1" ActualExecutions="1" />
                                                            <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                          </RunTimeInformation>
                                                          <TableScan Ordered="true" ForcedIndex="false" ForceScan="false" NoExpandHint="false">
                                                            <DefinedValues>
                                                              <DefinedValue>
                                                                <ColumnReference Column="Bmk1000" />
                                                              </DefinedValue>
                                                              <DefinedValue>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                              </DefinedValue>
                                                              <DefinedValue>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                              </DefinedValue>
                                                              <DefinedValue>
                                                                <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                              </DefinedValue>
                                                            </DefinedValues>
                                                            <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" IndexKind="Heap" />
                                                            <Predicate>
                                                              <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ISVISIBLE]=(-1)">
                                                                <Compare CompareOp="EQ">
                                                                  <ScalarOperator>
                                                                    <Identifier>
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ISVISIBLE" />
                                                                    </Identifier>
                                                                  </ScalarOperator>
                                                                  <ScalarOperator>
                                                                    <Const ConstValue="(-1)" />
                                                                  </ScalarOperator>
                                                                </Compare>
                                                              </ScalarOperator>
                                                            </Predicate>
                                                          </TableScan>
                                                        </RelOp>
                                                        <RelOp AvgRowSize="15" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="7540" EstimateRewinds="0" EstimateRows="1" LogicalOp="Index Seek" NodeId="16" Parallel="true" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="1.55786" TableCardinality="7541">
                                                          <OutputList>
                                                            <ColumnReference Column="Bmk1004" />
                                                          </OutputList>
                                                          <RunTimeInformation>
                                                            <RunTimeCountersPerThread Thread="2" ActualRows="18591" ActualEndOfScans="4097" ActualExecutions="4097" />
                                                            <RunTimeCountersPerThread Thread="1" ActualRows="18296" ActualEndOfScans="3444" ActualExecutions="3444" />
                                                            <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                          </RunTimeInformation>
                                                          <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false">
                                                            <DefinedValues>
                                                              <DefinedValue>
                                                                <ColumnReference Column="Bmk1004" />
                                                              </DefinedValue>
                                                            </DefinedValues>
                                                            <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Index="[IDX_2_DeadLines]" Alias="[DL2]" IndexKind="NonClustered" />
                                                            <SeekPredicates>
                                                              <SeekPredicateNew>
                                                                <SeekKeys>
                                                                  <Prefix ScanType="EQ">
                                                                    <RangeColumns>
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ACCOUNTID" />
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ADATE" />
                                                                      <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ANUMBER" />
                                                                    </RangeColumns>
                                                                    <RangeExpressions>
                                                                      <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ACCOUNTID]">
                                                                        <Identifier>
                                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ACCOUNTID" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                      <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ADATE]">
                                                                        <Identifier>
                                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ADATE" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                      <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ANUMBER]">
                                                                        <Identifier>
                                                                          <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Column="ANUMBER" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                    </RangeExpressions>
                                                                  </Prefix>
                                                                </SeekKeys>
                                                              </SeekPredicateNew>
                                                            </SeekPredicates>
                                                          </IndexScan>
                                                        </RelOp>
                                                      </NestedLoops>
                                                    </RelOp>
                                                    <RelOp AvgRowSize="18" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="292.153" EstimateRewinds="4.29416" EstimateRows="293.266" LogicalOp="RID Lookup" NodeId="18" Parallel="true" PhysicalOp="RID Lookup" EstimatedTotalSubtreeCost="0.221343" TableCardinality="7541">
                                                      <OutputList>
                                                        <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                        <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                      </OutputList>
                                                      <RunTimeInformation>
                                                        <RunTimeCountersPerThread Thread="2" ActualRows="18020" ActualEndOfScans="571" ActualExecutions="18591" />
                                                        <RunTimeCountersPerThread Thread="1" ActualRows="17481" ActualEndOfScans="815" ActualExecutions="18296" />
                                                        <RunTimeCountersPerThread Thread="0" ActualRows="0" ActualEndOfScans="0" ActualExecutions="0" />
                                                      </RunTimeInformation>
                                                      <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false">
                                                        <DefinedValues>
                                                          <DefinedValue>
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TOTALDUE" />
                                                          </DefinedValue>
                                                          <DefinedValue>
                                                            <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="TRANSACTIONTYPE" />
                                                          </DefinedValue>
                                                        </DefinedValues>
                                                        <Object Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" TableReferenceId="-1" IndexKind="Heap" />
                                                        <SeekPredicates>
                                                          <SeekPredicateNew>
                                                            <SeekKeys>
                                                              <Prefix ScanType="EQ">
                                                                <RangeColumns>
                                                                  <ColumnReference Column="Bmk1004" />
                                                                </RangeColumns>
                                                                <RangeExpressions>
                                                                  <ScalarOperator ScalarString="[Bmk1004]">
                                                                    <Identifier>
                                                                      <ColumnReference Column="Bmk1004" />
                                                                    </Identifier>
                                                                  </ScalarOperator>
                                                                </RangeExpressions>
                                                              </Prefix>
                                                            </SeekKeys>
                                                          </SeekPredicateNew>
                                                        </SeekPredicates>
                                                        <Predicate>
                                                          <ScalarOperator ScalarString="[PlanGuide].[dbo].[DeadLines].[ASTATE] as [DL2].[ASTATE] IS NULL">
                                                            <Compare CompareOp="IS">
                                                              <ScalarOperator>
                                                                <Identifier>
                                                                  <ColumnReference Database="[PlanGuide]" Schema="[dbo]" Table="[DeadLines]" Alias="[DL2]" Column="ASTATE" />
                                                                </Identifier>
                                                              </ScalarOperator>
                                                              <ScalarOperator>
                                                                <Const ConstValue="NULL" />
                                                              </ScalarOperator>
                                                            </Compare>
                                                          </ScalarOperator>
                                                        </Predicate>
                                                      </IndexScan>
                                                    </RelOp>
                                                  </NestedLoops>
                                                </RelOp>
                                              </ComputeScalar>
                                            </RelOp>
                                          </Sort>
                                        </RelOp>
                                      </StreamAggregate>
                                    </RelOp>
                                  </Parallelism>
                                </RelOp>
                              </StreamAggregate>
                            </RelOp>
                          </ComputeScalar>
                        </RelOp>
                        <Predicate>
                          <ScalarOperator ScalarString="[Expr1007]&gt;(-1.000000000000000e-007) AND [Expr1007]&lt;(1.000000000000000e-007)">
                            <Logical Operation="AND">
                              <ScalarOperator>
                                <Compare CompareOp="GT">
                                  <ScalarOperator>
                                    <Identifier>
                                      <ColumnReference Column="Expr1007" />
                                    </Identifier>
                                  </ScalarOperator>
                                  <ScalarOperator>
                                    <Const ConstValue="(-1.000000000000000e-007)" />
                                  </ScalarOperator>
                                </Compare>
                              </ScalarOperator>
                              <ScalarOperator>
                                <Compare CompareOp="LT">
                                  <ScalarOperator>
                                    <Identifier>
                                      <ColumnReference Column="Expr1007" />
                                    </Identifier>
                                  </ScalarOperator>
                                  <ScalarOperator>
                                    <Const ConstValue="(1.000000000000000e-007)" />
                                  </ScalarOperator>
                                </Compare>
                              </ScalarOperator>
                            </Logical>
                          </ScalarOperator>
                        </Predicate>
                      </Filter>
                    </RelOp>
                  </Top>
                </RelOp>
              </Update>
            </RelOp>
          </QueryPlan>
        </StmtSimple>
      </Statements>
    </Batch>
  </BatchSequence>
</ShowPlanXML>'')';

EXEC sp_create_plan_guide
  @name=N'PlanGuide_Delete_DeadLines'
  ,@stmt=N'DELETE FROM dbo.DeadLines
WHERE
  (ISVISIBLE=-1)
  AND EXISTS (SELECT DL2.ACCOUNTID
              FROM dbo.DeadLines AS DL2 
              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)
                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  
                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)
                  AND (DeadLines.ANUMBER=DL2.ANUMBER)
				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)
  				        AND (DL2.ASTATE IS NULL)
			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER 
                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) < 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) > -0.000000100000000)
			         );'
  ,@type=N'SQL'
  ,@hints=@xml_plan;
GO



DBCC FREEPROCCACHE;
GO


-- Enable the Plan Guide events on SQL Profiler


BEGIN TRANSACTION;
GO


-- Pay attention to the query text





DELETE FROM dbo.DeadLines
WHERE
  (ISVISIBLE=-1)
  AND EXISTS (SELECT DL2.ACCOUNTID
              FROM dbo.DeadLines AS DL2 
              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)
                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  
                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)
                  AND (DeadLines.ANUMBER=DL2.ANUMBER)
				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)
  				        AND (DL2.ASTATE IS NULL)
			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER 
                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) < 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) > -0.000000100000000)
			         );



ROLLBACK;
GO


------------------------------------------------------------------------
-- System stored procedure to manage the Plan Guide objects            -
------------------------------------------------------------------------

-- @operation (DROP, DROP ALL, DISABLE, DISABLE ALL, ENABLE, ENABLE ALL)

EXEC sp_control_plan_guide
  @operation=N'ENABLE'
  ,@name=N'PlanGuide_Delete_DeadLines';
GO

EXEC sp_control_plan_guide
  @operation=N'DROP'
  ,@name=N'PlanGuide_Delete_DeadLines';
GO


SELECT * FROM sys.plan_guides;
GO


SELECT
  pg.plan_guide_id
  ,pg.name
  ,pg.hints
  ,vpg.*
FROM
  sys.plan_guides AS pg
OUTER APPLY
  sys.fn_validate_plan_guide(pg.plan_guide_id) AS vpg;
GO


--DROP INDEX [dbo].[DeadLines].[IDX_2_DeadLines];
--GO

ALTER INDEX [IDX_2_DeadLines] ON [dbo].[DeadLines] DISABLE
GO

ALTER INDEX [IDX_2_DeadLines] ON [dbo].[DeadLines] REBUILD PARTITION = ALL
  WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

DBCC FREEPROCCACHE;
GO







------------------------------------------------------------------------
-- *** Bonus queries ***                                               -
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Optimization analysis                                               -
------------------------------------------------------------------------

SELECT * INTO #query_transformation_stats_before_query
FROM sys.dm_exec_query_transformation_stats;
GO

SELECT * INTO #query_transformation_stats_after_query
FROM sys.dm_exec_query_transformation_stats;
GO

DROP TABLE #query_transformation_stats_before_query;
DROP TABLE #query_transformation_stats_after_query;
GO

-- Transformation rules
SELECT * INTO #query_transformation_stats_before_query
FROM sys.dm_exec_query_transformation_stats;
GO

-- Query
BEGIN TRANSACTION;
GO
DELETE FROM dbo.DeadLines
WHERE
  (ISVISIBLE=-1)
  AND EXISTS (SELECT DL2.ACCOUNTID
              FROM dbo.DeadLines AS DL2 
              WHERE (DeadLines.ACCOUNTID=DL2.ACCOUNTID)
                AND ((DeadLines.ADATE=DL2.ADATE) OR ((DeadLines.ADATE IS NULL) AND (DL2.ADATE IS NULL)))  
                  --ISNULL(DeadLines.ADATE,0)=ISNULL(DL2.ADATE,0)
                  AND (DeadLines.ANUMBER=DL2.ANUMBER)
				          AND (DeadLines.ISVISIBLE=DL2.ISVISIBLE)
  				        AND (DL2.ASTATE IS NULL)
			          GROUP BY DL2.ACCOUNTID, DL2.ADATE, DL2.ANUMBER 
                HAVING (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) < 0.000000100000000) AND (SUM(DL2.TOTALDUE*DL2.TRANSACTIONTYPE) > -0.000000100000000)
			         )
--OPTION (QUERYRULEOFF EnforceSort)
ROLLBACK;
GO

SELECT * INTO #query_transformation_stats_after_query
FROM sys.dm_exec_query_transformation_stats;
GO

SELECT
  a.name
  ,promised = (a.promised - b.promised)
FROM
  #query_transformation_stats_before_query AS b
JOIN
  #query_transformation_stats_after_query AS a ON a.name=b.name
WHERE
  (a.succeeded <> b.succeeded);
GO

DROP TABLE #query_transformation_stats_before_query;
DROP TABLE #query_transformation_stats_after_query;
GO


-- Stream Aggregate
/*
DBCC RULEOFF('GbAggToStrm');
DBCC RULEON('GbAggToStrm');
GO
*/