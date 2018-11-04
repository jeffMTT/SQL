/*********************************************************************
	Identifying Problematic Execution Plans
**********************************************************************/

select * from sys.dm_exec_query_plan; --takes a plan handle
select * from sys.dm_exec_sql_text; --takes a plan handle
select * from sys.dm_exec_cached_plans;
select * from sys.dm_exec_query_stats;
select * from sys.dm_exec_plan_attributes; --take a plan handle

--most expensive cached plans by average execution time
SELECT TOP(100) OBJECT_NAME(t.objectid, t.dbid) AS object_name,
s.total_elapsed_time / s.execution_count AS average_duration,
s.execution_count,
s.last_execution_time,
total_worker_time,
SUBSTRING (t.[text],
(s.statement_start_offset/2)+1,
(( CASE statement_end_offset
WHEN -1 THEN DATALENGTH(t.[text])
ELSE s.statement_end_offset
END - s.statement_start_offset)/2)+1
) AS statement,
[text] as query,
query_plan
FROM sys.dm_exec_query_stats AS s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) AS p
ORDER BY average_duration DESC;
GO

--cached plans with missing indexes
;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT p.usecounts, p.refcounts, p.objtype, p.cacheobjtype,
db_name(t.dbid) as database_name, t.text as query, q.query_plan
FROM sys.dm_exec_cached_plans AS p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(p.plan_handle) AS q
WHERE q.query_plan.exist(N'/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan/MissingIndexes/MissingIndexGroup') <> 0
ORDER BY p.usecounts DESC

--cached plans with implicit warnings
;WITH XMLNAMESPACES(DEFAULT N'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT
operators.value('@ConvertIssue', 'nvarchar(250)') as convert_issue,
operators.value('@Expression', 'nvarchar(250)') AS convert_expression,
t.text AS query, p.query_plan
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) p
CROSS APPLY query_plan.nodes('//Warnings/PlanAffectingConvert') rel(operators)
CROSS APPLY sys.dm_exec_sql_text(s.plan_handle) AS t
ORDER BY p.usecounts DESC
