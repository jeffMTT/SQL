USE AdventureWorks2014;
GO

--Make table with millions of records
CREATE TABLE Colors
(
	colA	varchar(10)
);

INSERT INTO Colors (colA) VALUES('Red');
GO 1000000

select * from Colors; --1,000,000

--copy the table for demo
select * into bkupColors from Colors;
select * from bkupColors;
select * into Colors from bkupColors;

--Delete in batches
declare @rc int; --record count
set @rc = 1;

while @rc > 0
begin
	--deleting by sets of 10,000
	delete top (10000) from Colors;
	set @rc = @@ROWCOUNT;
end

--======================================================================

--Delete in batches with progress printed
declare @rc int; --record count
set @rc = 1;

while @rc > 0
begin
	--deleting by sets of 10,000
	delete top (10000) from Colors;
	set @rc = @@ROWCOUNT;
	raiserror('deleted 10,000 rows',10,1) with nowait;
end

--======================================================================

/*
	Delete in batches with progress put into table
*/

--make table for holding progress
create table progress
(
	 tableName varchar(128)
	,totalRecords int
	,recordsDeleted int
	,datetimestamp	datetime
);

insert into progress (tableName, recordsDeleted) values('Colors',0);

declare @totalRecords int;
select @totalRecords = count(*) from Colors;

update progress
set totalRecords = @totalRecords;

select * from progress;

--begin to delete
declare @rc int; --record count
set @rc = 1;

while @rc > 0
begin
	--deleting by sets of 10,000
	delete top (10000) from Colors;
	set @rc = @@ROWCOUNT;

	update progress
	set recordsDeleted += @rc
		,datetimestamp  = getdate();
end

--View in another query thread
select * from progress with(nolock)

--======================================================================

/*
	Delete in batches (parameter) with progress put into table
	Keep same progress table logic as abvoe
*/

declare @sql nvarchar(max);

set @sql = '
	declare @batchSize int;
	declare @rc int; --record count

	set @batchSize = 10000;
	set @rc = 1;

	while @rc > 0
	begin
		delete top (@batchSize) from Colors;
		set @rc = @@ROWCOUNT;

		update progress
		set recordsDeleted += @rc
		   ,datetimestamp = getdate()
	end';

	--print @sql; --debug
	exec sp_executesql @sql;

--======================================================================

drop table Colors;
drop table progress;

update progress
set recordsDeleted = 0;

select * from Colors;
select * from progress;

--======================================================================

/**************************************
	INSERT SEGMENT
***************************************/

--Source table
CREATE TABLE sourceTable
(
	colA	varchar(10)
);


--Target table
CREATE TABLE targetTable
(
	colA	varchar(10)
);

INSERT INTO sourceTable(colA) VALUES('Red');
GO 1000000

select * from sourceTable;
select * from targetTable;

--WRONG!
declare @rc int; --record count
set @rc = 1;

while @rc > 0
begin
	insert into targetTable select top 10000 * from sourceTable;
	set @rc = @@ROWCOUNT;
end

--======================================================================

--Keeping track of inserts - rowcounts
declare @rc int; --record count
declare @tableRows int;
declare @batchSize int;
declare @start int;
declare @end int;

set @rc = 1;
select @tableRows = count(*) from sourceTable; --initialize to total number of rows in table
set @batchSize = 10000;
set @start = 1;
set @end = @start + @batchSize - 1;

while @rc < @tableRows
begin
	with cte(colA, RowNbr) as
	(
		select ColA, ROW_NUMBER() over(order by colA) as 'RowNbr' 
		from sourceTable
	)

	insert into targetTable(colA)
	select colA
	from cte
	where RowNbr between @start and @end;

	set @rc += @batchSize;
	set @start = @end + 1 ;
	set @end = @start + @batchSize - 1;
end


--======================================================================

--Keeping track of inserts - temp tables
--load batch, insert, delete, clear temp table
create table #tmp
(
	 rownbr int
	,colA varchar(10)
);

select * from sourceTable;
insert into sourceTable
select ROW_NUMBER() over (order by colA) from sourceTable;

declare @rc int; --record count
declare @tableRows int;
declare @batchSize int;

set @rc = 1;
select @tableRows = count(*) from sourceTable; --initialize to total number of rows in table
set @batchSize = 10000;

while @rc < @tableRows
begin
	--Load records into temp table
	with cteInsertingRows as
	(
		select ColA, ROW_NUMBER() over(order by colA) as 'RowNbr' 
		from sourceTable
	)
	--select * from cteInsertingRows where RowNbr between 1 and 10000 --@rc and @rc+10000
	insert into #tmp (rownbr, colA) 
	select RowNbr, ColA from cteInsertingRows where RowNbr between @rc and @batchSize;

	--insert into target table
	insert into targetTable 
	select colA from #tmp;
	
	--delete from source table
	delete st
	--select st.*
	from 
		(select colA, ROW_NUMBER() over(order by colA) as 'rownbr' from sourceTable) st 
		inner join #tmp t on st.colA = t.colA and st.rownbr = t.rownbr

	--clear temp table for next iteration
	truncate table #tmp;
end

select * from sourceTable;
select * from targetTable with(nolock);
select * from #tmp;
truncate table targetTable;

--======================================================================

--Updates
--Keep track of row numbers and update in batches
select * from Colors;

declare @rc int; 
declare @tableRows int;
declare @batchSize int;
declare @start int;
declare @end int;

set @rc = 1;
select @tableRows = count(*) from Colors; 
set @batchSize = 10000;
set @start = 1;
set @end = @start + @batchSize - 1;

while @rc < @tableRows
begin
	with cte(colA, RowNbr) as
	(
		select ColA, ROW_NUMBER() over(order by colA) as 'RowNbr' 
		from Colors
	)

	update Colors
	set colA = 'Blue'
	from cte
	where RowNbr between @start and @end;

	set @rc += @batchSize;
	set @start = @end + 1 ;
	set @end = @start + @batchSize - 1;
end
