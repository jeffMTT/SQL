-- Create user-defined server role
USE master;
GO

CREATE SERVER ROLE CustomerServeRole
GO

-- Add members to user-defined server role
ALTER SERVER ROLE CustomerServeRole ADD MEMBER Christopher
ALTER SERVER ROLE processadmin ADD MEMBER CustomerServeRole
ALTER SERVER ROLE securityadmin ADD MEMBER CustomerServeRole
--
GRANT SHUTDOWN TO CustomerServeRole
GRANT VIEW SERVER STATE TO CustomerServeRole
GO
-- Deny control to logins
DENY CONTROL ON LOGIN::[NT SERVICE\SQLSERVERAGENT] TO CustomerServeRole
DENY CONTROL ON LOGIN::sa TO CustomerServeRole
DENY CONTROL ON LOGIN::[NT SERVICE\MSSQLSERVER] TO CustomerServeRole
DENY CONTROL ON LOGIN::[SQL\Administrator] TO CustomerServeRole
GO
