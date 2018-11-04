/*********************************************************************
	DMVs for blocking, session info, query info, tempdb info
**********************************************************************/

select * from sys.dm_exec_connections;
select * from sys.dm_exec_requests;
select * from sys.dm_exec_sessions;
select * from sys.dm_tran_session_transactions;
select * from sys.dm_exec_session_wait_stats;

--can join each of the 6 by session_id
-- Query currently connected sessions with their stastics
SELECT c.session_id, c.net_transport, c.encrypt_option,
c.auth_scheme, s.host_name, s.program_name,
s.client_interface_name, s.login_name, s.nt_domain,
s.nt_user_name, c.connect_time, s.login_time,
s.reads, s.writes, s.logical_reads, s.status,
s.cpu_time, s.total_scheduled_time, s.total_elapsed_time
FROM sys.dm_exec_connections AS c
JOIN sys.dm_exec_sessions AS s ON c.session_id = s.session_id;
GO

--Identify blockers
select * from sys.dm_exec_requests ;
select * from sys.dm_os_waiting_tasks;

-- Using the sys.dm_exec_requests
SELECT session_id, blocking_session_id, open_transaction_count, wait_time, wait_type,
last_wait_type, wait_resource, transaction_isolation_level, lock_timeout
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
GO
-- Using the sys.dm_os_waiting_tasks
SELECT session_id, blocking_session_id, wait_duration_ms, wait_type, resource_description
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id IS NOT NULL

--idle sessions with open transactions
SELECT s.*
FROM sys.dm_exec_sessions AS s
WHERE EXISTS (
SELECT *
FROM sys.dm_tran_session_transactions AS t
WHERE t.session_id = s.session_id
)
AND NOT EXISTS (
SELECT *
FROM sys.dm_exec_requests AS r
WHERE r.session_id = s.session_id
);

--queries allocated the most space in tempdb
SELECT r.session_id, r.request_id, t.text AS query,
u.allocated AS task_internal_object_page_allocation_count,
u.deallocated AS task_internal_object_page_deallocation_count
FROM (
SELECT session_id, request_id,
SUM(internal_objects_alloc_page_count) AS allocated,
SUM (internal_objects_dealloc_page_count) AS deallocated
FROM sys.dm_db_task_space_usage
GROUP BY session_id, request_id) AS u
JOIN sys.dm_exec_requests AS r
ON u.session_id = r.session_id AND u.request_id = r.request_id
CROSS APPLY sys.dm_exec_sql_text (r.sql_handle) as t
ORDER BY u.allocated DESC;

