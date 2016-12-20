USE [master]
GO
/****** 
Objective	: Get database size, used space, free space within an instance of SQL Server (version 2012)
Date		: 22/04/2014
Author		: Trevor Makoni
******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[proc_ShowDbSpaceUsage](@User varchar(250)=null)
AS
BEGIN;
SET NOCOUNT ON;
SET @User = LTRIM(RTRIM(ISNULL(@User, '')));
DECLARE @domain table(name varchar(250), domain varchar(250));
insert into @domain
	exec master.dbo.xp_loginconfig 'default domain';

IF @User <> ''
	IF @User NOT LIKE '%\%'
	BEGIN;
		SET @User = (select domain from @domain )+'\' + @User; 
	END;

DECLARE @T TABLE(NUID INT IDENTITY(1,1), dbName SYSNAME);
DECLARE @RESULT TABLE(
	[Name]		VARCHAR(500),
	[Drive]		VARCHAR(10),
	[Filename]	VARCHAR(500),
	[FileSizeMB]	INT,
	[SpaceUsedMB]	INT,
	[FreeSpaceMB]	INT,
	[% Free]	DECIMAL(12,2),
	[Created	]	DATETIME,
	[Modified]	DATETIME,
	[Owner]		VARCHAR(500));
DECLARE
	@i INT = 1,
	@db	SYSNAME,
	@SQL	VARCHAR(MAX);
INSERT INTO @T
(dbName)
SELECT name
FROM         sys.databases
where state_desc = 'ONLINE';

WHILE @i <= (SELECT COUNT(1) FROM @T)
BEGIN;
	SELECT @db = dbName FROM @T WHERE NUID = @i;

IF @User <> ''
SET @SQL = '
	USE ['+@db+']
	SELECT
		a.name,
		UPPER(left(a.filename,1)) as [Drive],
		a.filename,
		convert(decimal(12,2),round(a.size/128.000,2)) FileSizeMB,
		CONVERT(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2)) SpaceUsedMB,
		CONVERT(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2)) FreeSpaceMB,
		CONVERT(decimal(12,2),100*(CONVERT(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2))/convert(decimal(12,2),round(a.size/128.000,2)))) [% Free],
		info.create_date [Created],
		info.modify_date [Modified],
		suser_sname(owner_sid) [Owner]
	FROM sys.sysfiles a
	LEFT OUTER JOIN sys.databases b on a.name = b.name COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN (SELECT     s.TABLE_CATALOG, MIN(o.create_date) AS create_date, MAX(o.modify_date) AS modify_date
						FROM         sys.objects AS o INNER JOIN
											  sys.tables AS t ON t.object_id = o.object_id INNER JOIN
											  INFORMATION_SCHEMA.TABLES AS s ON s.TABLE_NAME = t.name COLLATE Latin1_General_CI_AS
						GROUP BY s.TABLE_CATALOG) info on info.TABLE_CATALOG = b.name COLLATE Latin1_General_CI_AS
	WHERE b.state_desc = ''ONLINE'' and suser_sname(owner_sid) = '''+@User+''' and a.filename LIKE ''%.MDF'';';
ELSE
SET @SQL = '
	USE ['+@db+']
	SELECT
		a.name,
		UPPER(left(a.filename,1)) as [Drive],
		a.filename,
		convert(decimal(12,2),round(a.size/128.000,2)) FileSizeMB,
		CONVERT(decimal(12,2),round(fileproperty(a.name,''SpaceUsed'')/128.000,2)) SpaceUsedMB,
		CONVERT(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2)) FreeSpaceMB,
		CONVERT(decimal(12,2),100*(CONVERT(decimal(12,2),round((a.size-fileproperty(a.name,''SpaceUsed''))/128.000,2))/convert(decimal(12,2),round(a.size/128.000,2)))) [% Free],
		info.create_date [Created],
		info.modify_date [Modified],
		suser_sname(owner_sid) [Owner]
	FROM sys.sysfiles a
	LEFT OUTER JOIN sys.databases b on a.name = b.name COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN (SELECT     s.TABLE_CATALOG, MIN(o.create_date) AS create_date, MAX(o.modify_date) AS modify_date
						FROM         sys.objects AS o INNER JOIN
											  sys.tables AS t ON t.object_id = o.object_id INNER JOIN
											  INFORMATION_SCHEMA.TABLES AS s ON s.TABLE_NAME = t.name COLLATE Latin1_General_CI_AS
						GROUP BY s.TABLE_CATALOG) info on info.TABLE_CATALOG = b.name COLLATE Latin1_General_CI_AS
	WHERE b.state_desc = ''ONLINE'' and a.filename LIKE ''%.MDF'';';
	
INSERT INTO @RESULT
EXEC (@SQL);
SET @i += 1;

END;

SELECT *
FROM @RESULT
ORDER BY FreeSpaceMB DESC;
SET NOCOUNT OFF;
END;
GO