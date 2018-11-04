--identifying missing indexes
SELECT g.*, statement AS table_name, column_id, column_name, column_usage
FROM sys.dm_db_missing_index_details AS d
CROSS APPLY sys.dm_db_missing_index_columns (d.index_handle)
INNER JOIN sys.dm_db_missing_index_groups AS g ON g.index_handle = d.index_handle
ORDER BY g.index_group_handle, g.index_handle, column_id;
GO

--identifying underutilized indexes
SELECT DB_NAME(s.database_id) AS 'datase_name', OBJECT_NAME(s.object_id) AS 'table_name',i.name AS 'index_name',
s.user_seeks, s.user_scans, s.user_lookups, s.user_updates,s.last_user_seek, s.last_user_scan, s.last_user_lookup, s.last_user_update
FROM sys.dm_db_index_usage_stats AS s
JOIN sys.indexes AS i ON s.index_id = i.index_id
AND s.object_id = i.object_id
WHERE s.database_id = DB_ID()
AND s.user_seeks = 0 AND s.user_scans = 0 AND s.user_lookups = 0;
GO

SELECT DB_NAME(s.database_id) AS 'datase_name', OBJECT_NAME(s.object_id) AS 'table_name',
i.name AS 'index_name',s.user_seeks, s.user_scans, s.user_lookups, s.user_updates,s.last_user_seek, s.last_user_scan, s.last_user_lookup, s.last_user_update
FROM sys.dm_db_index_usage_stats AS s
JOIN sys.indexes AS i ON s.index_id = i.index_id
AND s.object_id = i.object_id
WHERE s.database_id = DB_ID()
AND s.user_updates > (s.user_seeks + s.user_scans + s.user_lookups)
AND s.index_id > 1;

--Identifying fragmentation in columnstore indexes
SELECT i.object_id,
OBJECT_NAME(i.object_id) AS table_name,
i.name AS index_name,
i.index_id,
i.type_desc,
100*(ISNULL(deleted_rows,0))/total_rows AS ‘Fragmentation’,
s.*
FROM sys.indexes AS i
JOIN sys.dm_db_column_store_row_group_physical_stats AS s
ON i.object_id = s.object_id AND i.index_id = s.index_id
ORDER BY fragmentation DESC;

--reorganizing columnstore index
USE AdventureworksDW
GO
ALTER INDEX IndFactResellerSalesXL_CCI ON dbo.FactResellerSalesXL_CCI
REORGANIZE WITH (LOB_COMPACTION = ON, COMPRESS_ALL_ROW_GROUPS = ON);

--rebuilding columnstore index
USE AdventureworksDW
GO
ALTER INDEX IndFactResellerSalesXL_CCI ON dbo.FactResellerSalesXL_CCI
REBUILD WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
/*
-- Let’s assume the [IndFactResellerSalesXL_CCI] table was partitioned
-- Rebuild only 1 partition
ALTER TABLE IndFactResellerSalesXL_CCI
REBUILD PARTITION = 1 WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE);
GO
-- Rebuild all partitions but with different data compression
ALTER TABLE [ColumnstoreTable]
REBUILD PARTITION = ALL WITH (
DATA_COMPRESSION = COLUMNSTORE ON PARTITIONS (5,6,7,8,9,10,11,12),
DATA COMPRESSION = COLUMNSTORE_ARCHIVE ON PARTITIONS (1,2,3,4)
);
*/
