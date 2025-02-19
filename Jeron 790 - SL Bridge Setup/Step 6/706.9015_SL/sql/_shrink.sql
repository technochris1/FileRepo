-- ========================================================
--	Database shrink script for Microsoft SQL Server 2005+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05.5156	2014-Feb-12
--	7.05.5205	2014-Apr-02		+ checkpoint
--	7.05.5255	2014-May-22		+ fix filename handling
--	7.06.5526	2015-Feb-17		+ dynamic timeouts
--	7.06.6022	2016-Jun-27		* DB ID check
-- ========================================================

use [{0}]
go

checkpoint
go
--	----------------------------------------------------------------------------
--	shrink .mdf
--	<50,tbEvent>
if	exists	(select 1 from master.sys.databases where database_id = db_id( ) and recovery_model = 3)	-- SIMPLE
begin
	declare	@sDbFile	varchar(64)

	select	@sDbFile =	name	from	sys.database_files	where type = 1		-- data

	exec( 'dbcc shrinkfile (''' + @sDbFile + ''', 0)' )
end
go
--	----------------------------------------------------------------------------
--	shrink .ldf
--	<200,tbEvent>
if	exists	(select 1 from master.sys.databases where database_id = db_id( ) and recovery_model = 3)	-- SIMPLE
begin
	declare	@sDbFile	varchar(64)

	select	@sDbFile =	name	from	sys.database_files	where type = 0		-- log

	exec( 'dbcc shrinkfile (''' + @sDbFile + ''', 0)' )
end
go

use [master]
go
