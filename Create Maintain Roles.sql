/*********************************************************
	Create and Maintain Roles
**********************************************************/

-- Add Windows login to fixed server role
USE master;
GO

ALTER SERVER ROLE sysadmin ADD MEMBER [SQL\Marcus]
GO

-- Add database user
USE [WideWorldImporters]
GO

CREATE USER [Isabelle] FOR LOGIN [Isabelle]
GO

-- Add database user to fixed database roles
ALTER ROLE [db_datareader] ADD MEMBER [Isabelle]
GO

ALTER ROLE [db_datawriter] ADD MEMBER [Isabelle]
GO
