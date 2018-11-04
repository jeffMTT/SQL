--configure query store
ALTER DATABASE [WideWorldImporters]
SET QUERY_STORE (OPERATION_MODE = READ_WRITE,
CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 366),
DATA_FLUSH_INTERVAL_SECONDS = 3600,
INTERVAL_LENGTH_MINUTES = 5,
MAX_STORAGE_SIZE_MB = 5000);
GO

--Query Store tables
select * from sys.query_context_settings;
select * from sys.query_store_plan
select * from sys.query_store_query
select * from sys.query_store_query_text
select * from sys.query_store_runtime_stats
select * from sys.query_store_runtime_stats_interval
select * from sys.query_store_wait_stats; --new for SQL 2017

--analyzing and managing the query store
-- Determine the top 100 queries with the longest average duration for the last week
SELECT TOP 100 r.avg_duration, r.last_execution_time, t.query_sql_text
FROM sys.query_store_query_text AS t
JOIN sys.query_store_query AS q ON t.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS r ON p.plan_id = r.plan_id
WHERE r.last_execution_time > DATEADD(day, -7, GETUTCDATE())
ORDER BY r.avg_duration DESC;
GO

-- Delete ad-hoc queries (single use plans) older than 24 hours
DECLARE @query_id INT;
DECLARE adhoc_queries_cursor CURSOR FOR
SELECT q.query_id
FROM sys.query_store_query_text AS t
JOIN sys.query_store_query AS q ON q.query_text_id = t.query_text_id
JOIN sys.query_store_plan AS p ON p.query_id = q.query_id
JOIN sys.query_store_runtime_stats AS r ON r.plan_id = p.plan_id
GROUP BY q.query_id
HAVING SUM(r.count_executions) < 2
AND MAX(r.last_execution_time) < DATEADD (hour, -24, GETUTCDATE())
ORDER BY q.query_id;
OPEN adhoc_queries_cursor;
FETCH NEXT FROM adhoc_queries_cursor INTO @query_id;
WHILE (@@FETCH_STATUS = 0) BEGIN
EXEC sp_query_store_remove_query @query_id
FETCH NEXT FROM adhoc_queries_cursor INTO @query_id
END
CLOSE adhoc_queries_cursor;
DEALLOCATE adhoc_queries_cursor;
GO

-- Force a query to use a specific plan
EXEC sp_query_store_force_plan @query_id = 66, @plan_id = 69;
GO

-- Unforce a query to use a specific plan
EXEC sp_query_store_unforce_plan @query_id = 66, @plan_id = 69;
GO
