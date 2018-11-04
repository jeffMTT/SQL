USE WideWorldImporters;
GO

select * from sys.dm_db_log_space_usage; --info about database log usage
select * from sys.dm_db_file_space_usage; --info about each file in the database
select * from sys.dm_db_task_space_usage; --info about page allocation and deallocation activity by task for tempdb
select * from sys.dm_db_session_space_usage; --info about page allocation and deallocation activity by session for tempdb


dbcc checkdb with physical_only;
dbcc checkdb with estimate_only;
dbcc checkdb with extended_logical_checks;

select * from sys.dm_os_wait_stats;
