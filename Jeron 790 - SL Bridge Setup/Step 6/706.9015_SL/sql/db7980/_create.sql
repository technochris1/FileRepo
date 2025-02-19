-- ========================================================
--	Database create script for Microsoft SQL Server 2005+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--		{1} - '\'-terminated path to DATA\ folder
--		{2} - .mdf initial size, MB
--		{3} - .mdf grow delta
--		{4} - .mdf grow unit
--		{5} - '\'-terminated path to LOGS\ folder
--		{6} - .ldf initial size, MB
--		{7} - .ldf grow delta
--		{8} - .ldf grow unit
--		{9} - recovery-model (simple|full)
--
--	6.4.4500	2012-Apr-27		KB -> MB, + file autogrow args, args re-ordered
--	6.04		2012-Apr-23		moved security into _secure.sql
--	6.03		2012-Feb-15		+ args [3-6]
--	3.01		2011-Jul-15	DK
-- ========================================================

use [master]
go

create database [{0}]
on primary	( name= '{0}_d', filename= '{1}{0}.mdf', size= {2}MB, filegrowth= {3}{4} )
	log on	( name= '{0}_l', filename= '{5}{0}.ldf', size= {6}MB, filegrowth= {7}{8} )
	collate SQL_Latin1_General_CP1_CI_AS
go
alter database [{0}] set compatibility_level= 100
alter database [{0}] set ansi_null_default on
alter database [{0}] set ansi_nulls off
alter database [{0}] set ansi_padding off
alter database [{0}] set ansi_warnings off
alter database [{0}] set arithabort off
alter database [{0}] set auto_close off
alter database [{0}] set auto_create_statistics on
alter database [{0}] set auto_shrink off
alter database [{0}] set auto_update_statistics on
alter database [{0}] set cursor_close_on_commit off
alter database [{0}] set cursor_default global
alter database [{0}] set concat_null_yields_null off
alter database [{0}] set numeric_roundabort off
alter database [{0}] set quoted_identifier off
alter database [{0}] set recursive_triggers off
alter database [{0}] set disable_broker
alter database [{0}] set auto_update_statistics_async off
alter database [{0}] set date_correlation_optimization off
alter database [{0}] set parameterization simple
alter database [{0}] set read_write
alter database [{0}] set recovery {9}
alter database [{0}] set multi_user
alter database [{0}] set page_verify checksum
go

use [{0}]
go
if not exists (select 1 from sys.filegroups where is_default=1 and name='PRIMARY')
	alter database [{0}] modify filegroup [PRIMARY] default
go

use [master]
go
