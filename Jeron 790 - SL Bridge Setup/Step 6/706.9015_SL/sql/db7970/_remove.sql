-- ========================================================
--	Database remove script for Microsoft SQL Server 2005+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	3.01	2011-Jul-18	DK
-- ========================================================

use [master]
go

if exists( select 1 from master.sys.databases where [name]='{0}' )
begin
--	exec msdb.dbo.sp_delete_database_backuphistory '{0}'

	drop database [{0}]
end
go
