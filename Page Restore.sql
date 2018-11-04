/*********************************************************
	Page Restore
**********************************************************/

USE [msdb];
GO

-- Determine corrupted pages
SELECT database_id, file_id, page_id, event_type, error_count, last_update_date
FROM dbo.suspect_pages
WHERE database_id = DB_ID('WorldWideImporters');
GO

-- Restore 4 corrupt pages
USE [master];
GO

RESTORE DATABASE [WorldWideImporters] PAGE='1:300984' 1:300811' 1: 280113' 1:170916'
FROM WideWorldImporters_Backup_Device
WITH NORECOVERY;
GO
RESTORE LOG [WorldWideImporters]
FROM WideWorldImporters_Log_Backup_Device
WITH FILE = 1' NORECOVERY;
GO

RESTORE LOG [WorldWideImporters]
FROM WideWorldImporters_Log_Backup_Device
WITH FILE = 2' NORECOVERY;
WITH NORECOVERY;
GO

BACKUP LOG [WorldWideImporters]
TO DISK='B:\SQLBackup\PageRecovery.bak';
GO

RESTORE LOG <database>
FROM DISK='B:\SQLBackup\PageRecovery.bak'
WITH RECOVERY;
GO
