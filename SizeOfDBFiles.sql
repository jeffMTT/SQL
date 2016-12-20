---Objetivo: Size of database files for an instance of SQL Server (version 2014)
---Fecha: 10/04/2014
---Autor: Amndrés Noé Michaca Trujillo
-- Creo la tabla temporaria donde guardaré la salida del cursor   
IF NOT OBJECT_ID('tempdb.dbo.#spaces') IS NULL  
DROP TABLE dbo.#spaces   
  
CREATE TABLE #spaces   
    ( FileName VARCHAR(200) NULL,    
      PhysicalName VARCHAR(200) NULL,    
      TotalSize decimal null,    
      AvalableSpace decimal null,    
      FileId int null,    
      FilegroupName Varchar(200) NULL
	)    
GO

DECLARE @db      NVARCHAR(100) -- Base de datos
DECLARE db_cursor CURSOR FOR  
        SELECT name
        FROM sys.databases 
--        WHERE name NOT IN ('master','model','msdb','tempdb','ReportServer$SQLSERVER2014','ReportServer$SQLSERVER2014TempDB') 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @db
WHILE @@FETCH_STATUS = 0   
   BEGIN 
     insert into #spaces
     EXECUTE ('USE '+ @db + 
     ' SELECT df.name AS [File Name], 
	       df.physical_name AS [Physical Name], 
           CAST((df.size/128.0) AS decimal(15,2)) AS [Total Size in MB],
           CAST(df.size/128.0 - CAST(FILEPROPERTY(df.name, ''SpaceUsed'') AS int)/128.0 AS decimal(15,2)) AS [Available Space In MB], 
	       [file_id], 
	       ds.name AS [Filegroup Name]
      FROM sys.database_files AS df WITH (NOLOCK) 
      LEFT JOIN sys.data_spaces AS ds WITH (NOLOCK) 
      ON df.data_space_id =ds.data_space_id OPTION (RECOMPILE);')
   FETCH NEXT FROM db_cursor INTO @db 
END  
CLOSE db_cursor   
DEALLOCATE db_cursor

select * from #spaces order by TotalSize desc
go