/********************************************************************
	Orphaned Log Experiment
*********************************************************************/

-- Set up experiment: Run selectively as and if required
/* You might have to enable xp_cmdshell by running the following:
EXEC sp_configure 'show advanced'' 1;
RECONFIGURE;
GO
EXEC sp_configure 'xp_cmdshell'' 1;
RECONFIGURE;
GO
-- Create directory for experiment
EXEC xp_cmdshell' 'md C:\Exam764Ch2\';
GO
*/
-- Create database
CREATE DATABASE TailLogExperimentDB
ON PRIMARY (NAME = N'TailLogExperimentDB_data'' FILENAME = N'C:\Exam764Ch2\
TailLogExperimentDB.mdf')
LOG ON (NAME = N'TailLogExperimentDB_log'' FILENAME = N'C:\Exam764Ch2\
TailLogExperimentDB.ldf')
GO
-- Create table
USE [TailLogExperimentDB]
GO
CREATE TABLE [MyTable] (Payload VARCHAR(1000));
GO
-- Insert first record
INSERT [MyTable] VALUES ('Before full backup');
GO
-- Perform full backup
BACKUP DATABASE [TailLogExperimentDB] TO DISK = 'C:\Exam764Ch2\TailLogExperimentDB_FULL.
bak' WITH INIT;
GO
-- Insert second record
INSERT [MyTable] VALUES ('Before log backup');
GO
-- Perform log backup
BACKUP LOG [TailLogExperimentDB] TO DISK = 'C:\Exam764Ch2\TailLogExperimentDB_LOG.bak'
WITH INIT;
GO
-- Insert third record
INSERT [MyTable] VALUES ('After log backup');
GO
-- Simulate disaster
SHUTDOWN;
/*
Perform the following actions:
1. Use Windows Explorer to delete C:\Exam764Ch2\TailLogExperimentDB.mdf
2. Use SQL Server Configuration Manager to start SQL Server
The [TailLogExperimentDB] database should now be damaged as you deleted the primary data
file.
*/

/*
	At this stage, you have a full and log backup that contains only the first two records that
	were inserted. The third record was inserted after the log backup. If you restore the database at
	this stage, you lose the third record. Consequently, you need to back up the orphaned transaction
	log.
*/

USE master;
SELECT name, state_desc FROM sys.databases WHERE name = 'TailLogExperimentDB';
GO
-- Try to back up the orphaned tail-log
BACKUP LOG [TailLogExperimentDB] TO DISK = 'C:\Exam764Ch2\TailLogExperimentDB_OrphanedLog.bak' WITH INIT;

/*
	The database engine is not able to back up the log because it normally requires access to
	the database’s MDF file, which contains the location of the database’s LDF files in the system
	tables. The following error is generated:
	Msg 945' Level 14' State 2' Line 56
	Database 'TailLogExperimentDB' cannot be opened due to inaccessible files or
	insufficient memory or disk space. See the SQL Server errorlog for details.
	Msg 3013' Level 16' State 1' Line 56
	BACKUP LOG is terminating abnormally.
*/

--Proper way to backup tail log
-- Try to back up the orphaned tail-log again
BACKUP LOG [TailLogExperimentDB] TO DISK = 'C:\Exam764Ch2\TailLogExperimentDB_OrphanedLog.bak' WITH NO_TRUNCATE;

-- Cleanup experiment: Run selectively as and if required

EXEC xp_cmdshell 'rd /q C:\Exam764Ch2\';
GO

EXEC sp_configure 'xp_cmdshell'' 0;
RECONFIGURE;
GO
EXEC sp_configure 'show advanced'' 0;
RECONFIGURE;
GO

USE [master];
DROP DATABASE [TailLogExperimentDB];

