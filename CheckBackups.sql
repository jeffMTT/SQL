/*******************************************************************************
Last DB Backup
******************************************************************************/

SELECT
        sdb.Name AS DatabaseName
    ,   MAX(bus.backup_finish_date) LastBackupDTM
    ,   DATEDIFF(hh,MAX(bus.backup_finish_date),GETDATE()) AgeLastBackupHrs
    ,   CASE WHEN DATEDIFF(hh , MAX(bus.backup_finish_date) , GETDATE()) > 24
             THEN 'X'
             WHEN MAX(bus.backup_finish_date) IS NULL THEN 'X'
             ELSE ''
        END AS NotBkLast24
    FROM
        sys.sysdatabases sdb
    LEFT OUTER JOIN msdb.dbo.backupset bus
    ON  bus.database_name = sdb.name
    WHERE
        bus.type NOT LIKE 'L'
        AND sdb.name NOT LIKE 'tempdb'
    GROUP BY
        sdb.Name
    ORDER BY
        sdb.Name
        
/*******************************************************************************
Last Log Backup
******************************************************************************/

SELECT
        sdb.Name AS DatabaseName
    ,   MAX(bus.backup_finish_date) LastBackupDTM
    ,   CASE WHEN DATEDIFF(hh , MAX(bus.backup_finish_date) , GETDATE()) > 4
             THEN 'X'
             WHEN MAX(bus.backup_finish_date) IS NULL THEN 'X'
             ELSE ''
        END AS NotBkLast4
    FROM
        sys.sysdatabases sdb
    LEFT OUTER JOIN msdb.dbo.backupset bus
    ON  bus.database_name = sdb.name
    WHERE
        bus.type LIKE 'L'
        AND sdb.name NOT LIKE 'tempdb'
    GROUP BY
        sdb.Name
    ORDER BY
        sdb.Name
        
        
/*******************************************************************************
Backup Detail
******************************************************************************/
SELECT
        database_name
    ,   name AS BkUpName
    ,   backup_finish_date AS LastBackup
    ,   CASE [type]
          WHEN 'D' THEN 'Database'
          WHEN 'L' THEN 'Log'
          WHEN 'I' THEN 'Differential'
          ELSE 'Other'
        END AS BkUpType
    --,   is_damaged
    --,   begins_log_chain
    --,   has_incomplete_metadata
    FROM
        msdb.dbo.backupset bus
        WHERE backup_finish_date > DATEADD(dd,-7,GETDATE())
        ORDER BY database_name,  backup_finish_date desc