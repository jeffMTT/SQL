/****************************************************************************************************
	List of useful DMVs for Azure and On-Premise SQL Server Instances
*****************************************************************************************************/

USE AdventureWorks2016;
GO

/**********************
	Azure ONLY!
***********************/
select * from sys.dm_db_resource_stats;		--returns data every 15 seconds for monitoring DB
select * from sys.dm_db_wait_stats;			--monitor wait stats on the current db, does not collect CPU / Memory / Disk
select * from sys.resource_stats;			--runs at the master db level, used for collecting db performance stats over a long period of time
select * from sys.event_log;				--filter on event_type for deadlocks and other things
select * from sys.database_firewall_rules;	--returns info about db level firewall settings
select * from sys.dm_db_operation_stats		--returns info about operations performed on the database


/****************************************
	Both Azure and On Premise
*****************************************/
--General System DMVs
select * from sys.dm_db_xtp_object_stats;		--monitors in-memory and memory-optimized tables
select * from sys.dm_io_virtual_file_stats;			--returns I/O stats for data and xact log files
select * from sys.dm_os_performance_counters;	--returns object data from the Windows Performance Counter libraries
select * from sys.dm_os_schedulers;				--returns 1 row per SQL Server scheduler, each scheduled is mapped to an individual CPU
select * from sys.dm_os_wait_stats;				--returns data about all waits encountered by SQL Server processor threads
select * from sys.dm_db_stats_properties;		--collects stats about db objects

--See the objects in the cache and plans 	
SELECT [cp].[refcounts] 
, [cp].[usecounts] 
, [cp].[objtype] 
, [st].[dbid] 
, [st].[objectid] 
, [st].[text] 
, [qp].[query_plan] 
FROM sys.dm_exec_cached_plans cp 
CROSS APPLY sys.dm_exec_sql_text ( cp.plan_handle ) st 
CROSS APPLY sys.dm_exec_query_plan ( cp.plan_handle ) qp;

--Query Store DMVs
select * from sys.database_query_store_options	--shows configured options
select * from sys.query_store_plan				--shows plan info
select * from sys.query_store_query_text		--shows actual T-SQL and handles
select * from sys.query_store_wait_stats		--shows wait stats
select * from sys.query_context_settings		--shows info about semantics affecting context settings
select * from sys.query_store_query				--shows query info and aggregated runtime stats
select * from sys.query_store_stats				--shows query runtime stats

--Missing Index DMVs
select * from sys.dm_db_missing_index_details		--missing index info
select * from sys.dm_db_missing_index_columns		--table columns missing an index
select * from sys.dm_db_missing_index_groups		--missing indexes contained in a specific missing index group
select * from sys.dm_db_missing_index_group_stats	--groups of missing indexes

--General Index DMVs
select * from sys.dm_db_index_usage_stats						--shows different types of index operations and last time performed
select * from sys.dm_db_index_operation_stats					--shows low-level I/O, locking, latching, etc.
select * from sys.dm_db_index_physical_stats					--shows data and index size and fragmentation
select * from sys.dm_db_column_store_row_group_physical_stats	--clustered columnstore index info

--Wait Statistics DMVs
select * from sys.dm_os_wait_stats				--aggregated historical look at the wait stats
select * from sys.dm_os_waiting_tasks			--wait stats for currently executing requests that are experiencing resource waits
select * from sys.dm_exec_session_wait_status	--returns info about all the waits by threads that executed for each session

--Execution DMVs
select * from sys.dm_exec_query_stats			--returns aggregated performance stats for cached query plans
select * from sys.dm_exec_sesssion_wait_stats	--provides info about all waits
select * from sys.dm_exec_sql_text				--shows the plain SQL executed
select * from sys.dm_exec_requests				--returns info about every request currently executing
select * from sys.dm_exec_sessions				--shows 1 row per sessions
select * from sys.dm_exec_text_query_plan		--returns query in plain text for a batch
select * from sys.dm_exec_connections			--displays detailed info about each connection
select * from sys.dm_io_pending_io_requests		--returns a row for each pending I/O request

--Transactions
select * from sys.dm_tran_locks					--shows info about active locks
select * from sys.dm_tran_database_transactions --displays info about transactions and their sessions
select * from sys.dm_tran_session_transactions	--shows related info about transactions
select * from sys.dm_tran_active_transactions	--displays a single row of state info on the transaction

