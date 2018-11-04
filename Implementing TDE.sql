/***************************************************************
	Implementing TDE
****************************************************************/

USE master;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'T0p$3cr3t';
GO

CREATE CERTIFICATE TDECertificate WITH SUBJECT = 'TDE self-signed certificate';
GO

USE WideWorldImporters;
GO

CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDECertificate;
GO

ALTER DATABASE WorldWideImporters SET ENCRYPTION ON;
GO
/*
-- Use the following command to disable TDE
ALTER DATABASE WorldWideImporters SET ENCRYPTION OFF;
*/
GO

/***************************************************************
	backing up TDE certificates and keys
****************************************************************/

USE master;
GO

-- Backup SMK
BACKUP SERVICE MASTER KEY
TO FILE = 'S:\SecureLocation\ServerMasterKey.key' 
BY PASSWORD = 'T0p$3cr3t';
GO

-- Backup DMK
BACKUP MASTER KEY
TO FILE = 'S:\SecureLocation\DatabaseMasterKey.key'
BY PASSWORD = 'T0p$3cr3t';
GO

-- Backup TDECertificate
BACKUP CERTIFICATE TDECertificate
TO FILE = 'S:\SecureLocation\TDECertificate.cer'
WITH PRIVATE KEY(
FILE = 'S:\SecureLocation\TDECertificate.key',
ENCRYPTION BY PASSWORD = 'T0p$3cr3t'
);
