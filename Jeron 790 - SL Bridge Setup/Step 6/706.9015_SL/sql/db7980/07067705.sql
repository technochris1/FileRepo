--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2021-Feb-04		.7705
--						+ [rExporter]
--						+ prExportCallsActive, prExportCallsComplete
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7705 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7705', 18, 0 )
go


--	----------------------------------------------------------------------------
if not exists (select 1 from sys.database_principals where [name]='rExporter' and [type]='R')
	create role [rExporter] authorization [db_owner]
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prExportCallsComplete')
	drop proc	dbo.prExportCallsComplete
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prExportCallsActive')
	drop proc	dbo.prExportCallsActive
go
--	----------------------------------------------------------------------------
--	Exports calls active at the moment
--	7.06.7705
create proc		dbo.prExportCallsActive
	with encryption
as
begin
	select	ec.sUnit	as	UnitName
		,	ec.sDevice	as	RoomName
		,	ea.cBed		as	BedName
		,	ea.sCall	as	CallText
		,	ea.dtEvent	as	TimePlaced
		,	ea.dtEvent + ec.tVoice	as	TimePicked
		,	e.sDstDvc	as	ConsoleName
		,	ea.dtEvent + ec.tStaff	as	TimeCancelled
		from	dbo.vwEvent_A	ea	with (nolock)
		join	dbo.vwEvent_C	ec	with (nolock)	on	ec.idEvent = ea.idEvent
		left join	dbo.vwEvent	e	with (nolock)	on	e.idEvent = ec.idEvtVo
		where	ea.bActive > 0
		order	by	ea.idUnit, ea.idRoom, ea.idEvent
end
go
grant	execute				on dbo.prExportCallsActive			to [rExporter]
grant	execute				on dbo.prExportCallsActive			to [rExporter]
go
--	----------------------------------------------------------------------------
--	Exports calls cancelled within a given window of last N hours
--	7.06.7705
create proc		dbo.prExportCallsComplete
(
	@tiHours	tinyint		= 0		-- defines the sliding window 'N hours back from now', 0=current hour
)
	with encryption
as
begin
	declare		@iFrom		int
			,	@dtFrom		datetime
			,	@dFrom		date
			,	@tFrom		tinyint
			,	@s			varchar(255)

	set	nocount	on

	select	@dtFrom =	dateadd( hh, -@tiHours, getdate( ) )
	select	@dFrom =	@dtFrom
		,	@tFrom =	datepart( hh, @dtFrom )

	select	@iFrom =	min(idEvent)
		from	tbEvent_S	with (nolock)
		where	@dFrom <= dEvent	and	@tFrom <= tiHH

--	select	@s =	'd=' + isnull(convert(varchar, @dFrom, 120),'?') + ' t=' + isnull(cast(@tFrom as varchar),'?') + ' i=' + isnull(cast(@iFrom as varchar),'?')
--	print	@s

	set	nocount	off

	select	ec.sUnit	as	UnitName
		,	ec.sDevice	as	RoomName
		,	ec.cBed		as	BedName
		,	ec.sCall	as	CallText
		,	e.dtEvent	as	TimePlaced
		,	e.dtEvent + ec.tVoice	as	TimePicked
		,	ev.sDstDvc	as	ConsoleName
		,	e.dtEvent + ec.tStaff	as	TimeCancelled
		from	dbo.vwEvent_C	ec	with (nolock)
		join	dbo.vwEvent		e	with (nolock)	on	e.idEvent = ec.idEvent
		left join	dbo.vwEvent	ev	with (nolock)	on	ev.idEvent = ec.idEvtVo
		left join	dbo.vwEvent	es	with (nolock)	on	es.idEvent = ec.idEvtSt
		where	ec.idEvent	>= @iFrom
		and		ec.idEvtSt is not null
		order	by	ec.idUnit, ec.idRoom, ec.idEvent
end
go
grant	execute				on dbo.prExportCallsComplete		to [rExporter]
grant	execute				on dbo.prExportCallsComplete		to [rExporter]
go



begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7705 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7705, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2021-02-04',	sVersion =	'exp'
		where	siBuild = 7705

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7705'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.7705 )'
commit
go

checkpoint
go

use [master]
go