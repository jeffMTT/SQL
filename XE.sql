--Extended Event creation
CREATE EVENT SESSION [Page Splits] ON SERVER
ADD EVENT sqlserver.page_split(
ACTION(sqlserver.sql_text)
WHERE ([database_id]=(5)))
ADD TARGET package0.event_counter,
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

--another one
CREATE EVENT SESSION [Page Splits] ON SERVER
ADD EVENT sqlserver.page_split(
ACTION(sqlserver.sql_text)
WHERE ([database_id]=(5)))
ADD TARGET package0.event_counter,
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS, MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

USE master;
exec sp_configure ‘show advanced options’,1;
GO
RECONFIGURE;
GO
EXEC sp_configure ‘blocked process threshold’,5;
GO
RECONFIGURE;
GO

CREATE EVENT SESSION [BlockedProcesses] ON SERVER
ADD EVENT sqlserver.blocked_process_report(
ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_name))
ADD TARGET package0.event_file(
SET filename=N’C:\ExtendedEvents\BlockedProcesses.xel’,
max_rollover_files=(10)
)
WITH (STARTUP_STATE=ON)
GO

--detecting deadlocks in the server_health session
SELECT x.value('@timestamp', 'datetime') as deadlock_datetime, x.query('.') AS deadlock_payload
FROM (
SELECT CAST(target_data AS XML) AS Target_Data
FROM sys.dm_xe_session_targets AS t
JOIN sys.dm_xe_sessions AS s ON s.address = t.event_session_address
WHERE s.name = N'system_health' AND t.target_name = N'ring_buffer'
) AS XML_Data
CROSS APPLY
Target_Data.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS
XEventData(x);
