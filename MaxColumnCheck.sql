USE Scratchpad;
GO

/*
	Test the limit of columns in a table
*/

CREATE TABLE ManyColumns
(
	col1 int
);

select * from ManyColumns;

DECLARE @counter as int;
SET @counter = 2;

DECLARE @sql as varchar(max);

WHILE @counter <= 1025 --limit is 1,024
BEGIN
	SET @sql = 'ALTER TABLE ManyColumns ADD col' + CONVERT(varchar,@counter) + ' int';
	--print @sql;
	EXEC(@sql);
	SET @counter = @counter + 1;
END

--Cleanup
DROP TABLE ManyColumns;
