USE tempdb;
GO

/************************************************************************
	Implementing column-level encryption using a password
	Encrypt using a symmetric key protected by a password

	Missing: best practice of backing up keys and certificates
*************************************************************************/

-- Create sample table
CREATE TABLE Employees (
	EmployeeID		INT PRIMARY KEY,
	EmployeeName	VARCHAR(300),
	Position		VARCHAR(100),
	Salary			VARBINARY(128)
);
GO

-- Create SMK
CREATE SYMMETRIC KEY SMK_Emp
WITH ALGORITHM = AES_256 ENCRYPTION BY PASSWORD = 'Pa$$w0rd';
GO

-- Open SMK
OPEN SYMMETRIC KEY SMK_Emp DECRYPTION BY PASSWORD = 'Pa$$w0rd';
GO

-- Verify open keys
SELECT * FROM sys.openkeys;
GO

-- Insert data
INSERT Employees VALUES (1, 'Marcus', 'CTO', ENCRYPTBYKEY(KEY_GUID('SMK_Emp'),'$100000'));
INSERT Employees VALUES (2, 'Christopher', 'CIO', ENCRYPTBYKEY(KEY_GUID('SMK_Emp'),'$200000'));
INSERT Employees VALUES (3, 'Isabelle', 'CEO', ENCRYPTBYKEY(KEY_GUID('SMK_Emp'),'$300000'));
GO

-- Query table with encrypted values
SELECT * FROM Employees;
GO

-- Query table with decrypted values
SELECT *, CONVERT(VARCHAR, DECRYPTBYKEY(Salary)) AS DecryptedSalary
FROM Employees;
GO

-- Close SMK
CLOSE SYMMETRIC KEY SMK_Emp
GO

-- Query table with decrypted values after key SMK is closed
SELECT *, CONVERT(VARCHAR, DECRYPTBYKEY(Salary)) AS DecryptedSalary
FROM Employees;
GO

-- Clever CTO updates their salary to match CEO's salary
UPDATE Employees
SET Salary = (SELECT Salary FROM Employees WHERE Position = 'CEO')
WHERE EmployeeName = 'Marcus';
GO

-- Open SMK and query table with decrypted values
OPEN SYMMETRIC KEY SMK_Emp DECRYPTION BY PASSWORD = 'Pa$$w0rd';
SELECT *, CONVERT(VARCHAR, DECRYPTBYKEY(Salary)) AS DecryptedSalary
FROM Employees;
GO

-- Cleanup
DROP TABLE Employees;
DROP SYMMETRIC KEY SMK_Emp;
GO
