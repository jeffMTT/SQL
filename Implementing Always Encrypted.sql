USE tempdb;
GO

/************************************************************************
	Implementing column-level encryption using a certificate
*************************************************************************/

-- Create table
CREATE TABLE dbo.Customers(
	CustomerID INT ,
	Name NVARCHAR(50) NULL,
	City NVARCHAR(50) NULL,
	BirthDate DATE NOT NULL
);
GO

-- Insert sample data
INSERT Customers VALUES (1, 'Victor', 'Sydney', '19800909');
INSERT Customers VALUES (2, 'Sofia', 'Stockholm', '19800909');
INSERT Customers VALUES (3, 'Marcus', 'Sydney', '19900808');
INSERT Customers VALUES (4, 'Christopher', 'Sydney', '19800808');
INSERT Customers VALUES (5, 'Isabelle', 'Sydney', '20000909');
GO

-- Query unencrypted data
SELECT * FROM Customers;
GO

/************************************************************
	Implementing Always Encrypted 
*************************************************************/

-- Create CMK
CREATE COLUMN MASTER KEY [CMK_Auto1]
WITH
(
KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
KEY_PATH = N'CurrentUser/my/21CC13CA4E733072106BF516CB7BF51939C397A6'
);
GO

-- Create CEK
CREATE COLUMN ENCRYPTION KEY [CEK_Auto1]
WITH VALUES
(
COLUMN_MASTER_KEY = [CMK_Auto1],
ALGORITHM = 'RSA_OAEP',
ENCRYPTED_VALUE = 0x016E000001630075007200720065006E0074007
5007300650072002F006D0079002F003200310063006300310033006300
…
61003400650037003300330030003700320031003000360062006600350
1E60B9B4D7E6EB28F3A834FD8435A84421A80F36C14D2B371ED55C6D0AB
37117FCE4444E64A9C6D4B1CCC8053C0FFE
)
GO

CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[City] [nvarchar](50) COLLATE Latin1_General_BIN2
	ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [CEK_Auto1],
	ENCRYPTION_TYPE = Deterministic,
	ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NULL,
	[BirthDate] [date]
	ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [CEK_Auto1],
	ENCRYPTION_TYPE = Randomized,
	ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256') NOT NULL
)
GO
