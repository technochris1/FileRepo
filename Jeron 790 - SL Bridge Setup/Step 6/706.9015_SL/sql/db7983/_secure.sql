-- ========================================================
--	Database create script for Microsoft SQL Server 2005+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--		{1} - writer-account
--		{2} - writer-account's password
--		{3} - client-account
--		{4} - client-account's password
--
--	6.04	2012-Apr-23	DK
--	7.06
--		2021-Feb-04		.7705
--						+ [rExporter]
-- ========================================================

use [{0}]
go

if not exists (select 1 from sys.database_principals where [name]='rWriter' and [type]='R')
	create role [rWriter] authorization [db_owner]
go
if not exists (select 1 from sys.database_principals where [name]='rReader' and [type]='R')
	create role [rReader] authorization [db_owner]
go
if not exists (select 1 from sys.database_principals where [name]='rExporter' and [type]='R')
	create role [rExporter] authorization [db_owner]
go

if not exists (select 1 from master.dbo.syslogins where loginname='{1}')
	create login [{1}] with password='{2}', default_database=[{0}], check_expiration=off, check_policy=off
go
if not exists (select 1 from sys.database_principals where [name]='{1}' and [type]='S')
begin
	create user [{1}] for login [{1}] with default_schema=[dbo]
	grant connect to [{1}]
end
go
exec sp_addrolemember 'rWriter', '{1}'
go

if not exists (select 1 from master.dbo.syslogins where loginname='{3}')
	create login [{3}] with password='{4}', default_database=[{0}], check_expiration=off, check_policy=off
go
if not exists (select 1 from sys.database_principals where [name]='{3}' and [type]='S')
begin
	create user [{3}] for login [{3}] with default_schema=[dbo]
	grant connect to [{3}]
end
go
exec sp_addrolemember 'rReader', '{3}'
go

use [master]
go
