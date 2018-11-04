/***********************************************************************
	Implementing Dynamic Data Masking (DDM)
************************************************************************/

USE WideWorldImporters
GO

-- Create non-privileged user
CREATE USER NonPrivilegedUser WITHOUT LOGIN
GO
ALTER ROLE db_datareader ADD MEMBER NonPrivilegedUser
GO

-- Mask email address
ALTER TABLE Application.People
ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'EMAIL()')

-- Mask phone number
ALTER TABLE Application.People
ALTER COLUMN PhoneNumber ADD MASKED WITH (FUNCTION = 'PARTIAL(0,"XXX-XXX-",4)')
GO

-- Query table as dbo
SELECT TOP 5 FullName, PhoneNumber, FaxNumber, EmailAddress FROM Application.People;

-- Query table as non-privileged user
EXECUTE AS USER = 'NonPrivilegedUser';

SELECT TOP 5 FullName, PhoneNumber, FaxNumber, EmailAddress FROM Application.People;
REVERT;
GO
