/**********************************************************************
	Creating logins
**********************************************************************/

USE master;

-- Create Windows login
CREATE LOGIN [SQL\Marcus] FROM WINDOWS
GO

-- Create SQL login
CREATE LOGIN Isabelle
WITH PASSWORD = 'A2c3456$#',
CHECK_EXPIRATION = ON,
CHECK_POLICY = ON;
GO

-- Create login from a certificate
CREATE CERTIFICATE ChristopherCertificate
WITH SUBJECT = 'Christopher certificate in master database',
EXPIRY_DATE = '30/01/2114';
GO

CREATE LOGIN Christopher FROM CERTIFICATE ChristopherCertificate;
GO
