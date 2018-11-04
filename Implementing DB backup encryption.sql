/******************************************************************************************
	Implementing database backup encryption 
*******************************************************************************************/

USE master;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '1@IT1xl@t$0v@lFf3V3i3ntldr';
GO

CREATE CERTIFICATE BackupCertificate
WITH SUBJECT = 'Backup self-signed certificate';
GO

BACKUP DATABASE WideWorldImporters
	TO DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\WorldWideImporters.bak'
	WITH ENCRYPTION (
		ALGORITHM = AES_256,
		SERVER CERTIFICATE = BackupCertificate
);
GO
