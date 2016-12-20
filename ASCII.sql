/********************************************************
String manipulation functions for ASCII and CHAR values
*********************************************************/

USE AdventureWorks
GO

CREATE TABLE asciiValues
(
	code	int
)

select * from asciiValues

DECLARE @i int
SET @i = 0

WHILE(@i <= 128)
BEGIN
	INSERT INTO asciiValues (code) VALUES(@i)
	SET @i = @i + 1
END

select * from asciiValues

SELECT code, CHAR(code)
FROM asciiValues

select ASCII('A')
select CHAR(97)

--UNICODE() AND NCAR() can be used the same as ASCII() AND CHAR() for Unicode values

--Cleanup
DROP TABLE asciiValues