USE WideWorldImporters;
GO

/************************************************************************
	Implementing column-level encryption using a certificate
	
	This is preferred to a symmetric key protected by a password
	because it needs to be embedded somewhere - security risk

	Missing: best practice of backing up keys and certificates
*************************************************************************/

-- Create database master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'GoodLuckWithExam!'

-- Create certificate
CREATE CERTIFICATE Cert_BAN
WITH SUBJECT = 'Bank Account Number';
GO

-- Create SMK
CREATE SYMMETRIC KEY Key_BAN
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Cert_BAN;
GO

-- Create a column to store encrypted data
ALTER TABLE Purchasing.Suppliers
ADD EncryptedBankAccountNumber varbinary(128);
GO

-- Open the SMK to encrypt data
OPEN SYMMETRIC KEY Key_BAN
DECRYPTION BY CERTIFICATE Cert_BAN;
GO

-- Encrypt Bank Account Number
UPDATE Purchasing.Suppliers
SET EncryptedBankAccountNumber = EncryptByKey(Key_GUID('Key_BAN'), BankAccountNumber);
GO

-- Close SMK
CLOSE SYMMETRIC KEY Key_BAN
GO

/*
	Verify encryption was successful
*/

-- Query 1: Check encryption has worked
SELECT TOP 5 SupplierID, SupplierName, BankAccountNumber, EncryptedBankAccountNumber, CONVERT(NVARCHAR(50), DecryptByKey(EncryptedBankAccountNumber)) AS DecryptedBankAccountNumber
FROM Purchasing.Suppliers
GO

-- Query 2: Open the SMK
OPEN SYMMETRIC KEY Key_BAN
DECRYPTION BY CERTIFICATE Cert_BAN;
GO

-- Query with decryption function
SELECT NationalIDNumber, EncryptedNationalIDNumber AS 'Encrypted ID Number', CONVERT(nvarchar, DecryptByKey(EncryptedNationalIDNumber)) AS 'Decrypted ID Number'
FROM HumanResources.Employee;
-- Results can be seen in Figure 1-3
GO

-- Close SMK
CLOSE SYMMETRIC KEY Key_BAN;
GO
