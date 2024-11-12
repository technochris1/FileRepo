--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
--		2014-Feb-25		.5169
--						* tbReport [7],[8]	.sClass
--						* tdUser_OnDuty -> td_User_OnDuty, tvUser_Name -> tv_User_Name, tvUser_Duty -> tv_User_Duty
--						+ tb_Option[19], tb_OptSys[19]
--						* prEvent_Maint
--		2014-Feb-27		.5171
--						* pr_User_SetBreak -> prStaff_SetDuty
--						* vwStaff:	+ .dtDue
--
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tb_Version') and name='idVersion' and user_type_id=52)	--	smallint
	--	!!	version must already be at least 6.00	!!
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5171 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.05.5171', 18, 0 )

go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_SetDuty')
	drop proc	dbo.prStaff_SetDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_SetBreak')
	drop proc	dbo.pr_User_SetBreak
go

--	----------------------------------------------------------------------------
--	7.05.5169	+ [19]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 19)
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 19,  56, '(internal) Last processed idEvent' )		--	7.05.5169
	if	not	exists	(select 1 from dbo.tb_OptSys where idOption = 19)
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 19, 0 )
commit
go
--	----------------------------------------------------------------------------
--	7.05.5169	* tdUser_OnDuty -> td_User_OnDuty, tvUser_Name -> tv_User_Name, tvUser_Duty -> tv_User_Duty
begin tran
	if	exists	(select 1 from sys.check_constraints where object_id = OBJECT_ID('dbo.tdUser_OnDuty'))
		exec sp_rename	'tdUser_OnDuty',	'td_User_OnDuty',	'object'
	if	exists	(select 1 from sys.check_constraints where object_id = OBJECT_ID('dbo.tvUser_Name'))
		exec sp_rename	'tvUser_Name',		'tv_User_Name',		'object'
	if	exists	(select 1 from sys.check_constraints where object_id = OBJECT_ID('dbo.tvUser_Duty'))
		exec sp_rename	'tvUser_Duty',		'tv_User_Duty',		'object'
commit
go
--	----------------------------------------------------------------------------
--	Staff definitions
--	7.05.5171	+ .dtDue
--	7.05.5126	+ .idRoom
--	7.05.5121	+ .sUnits
--	7.05.5042	+ .sTeams
--	7.05.5010	* .idStaff -> .idUser
--	7.05.5008	+ .sBarCode
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--	7.04.4953	* .sFqName -> .sFqStaff
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.03	+ .bOnDuty
--	7.00	tbStaff.tiPtype -> .idStaffLvl
--	6.05	+ (nolock)
--			+ tbStaff.sStaff (new), - .sFull
--	6.03	* .sStaff -> sFqName, + .sStaff
--	6.03	+ .sStaff
--	6.02
alter view		dbo.vwStaff
	with encryption
as
select	idUser, sStaffID, sFrst, sMidd, sLast, s.idStfLvl, l.sStfLvl, l.iColorB, sBarCode
	,	sStaff, l.sStfLvl + ' (' + cast(sStaffID as varchar) + ') ' + sStaff [sFqStaff]
	,	s.sUnits, bOnDuty, dtDue, s.sTeams,	s.idRoom
	,	bActive, dtCreated, dtUpdated
	from	tb_User	s	with (nolock)
	join	tbStfLvl l	with (nolock)	on	l.idStfLvl = s.idStfLvl
--	where	s.idStfLvl is not null				--	only 'staff' users
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, should be called on a schedule every hour
--	7.05.5169	* wipe tbEvent.vbCmd for events older than 60 days
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ reporting DB sizes in tb_Module[1]
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prEvent_Maint
	with encryption
as
begin
	declare	@iSizeDat		int
		,	@iSizeLog		int
		,	@tiPurge		tinyint
		,	@dtNow			smalldatetime

	set	nocount	on

	select	@dtNow= getdate( )		--	smalldatetime truncates seconds

	select	@iSizeDat= size/128
		from	sys.database_files	with (nolock)
		where	file_id = 1		--	type = 0
	select	@iSizeLog= size/128
		from	sys.database_files	with (nolock)
		where	file_id = 2		--	type = 1

	update	tb_Module	set	sParams=	'@ ' + @@servicename + ', dat:' + cast(@iSizeDat as varchar) + ', log:' + cast(@iSizeLog as varchar)
		where	idModule=	1

	select	@tiPurge= cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	if	@tiPurge > 0
		exec	prEvent_A_Exp	@tiPurge

	begin tran

		select	@iSizeDat= iValue	from	tb_OptSys	with (nolock)	where	idOption = 19

		select	@iSizeLog= idEvent
			from	tbEvent_S
			where	dEvent < dateadd(dd, -60, @dtNow)	and	tiHH = datepart(hh, @dtNow)

		update	tbEvent		set	vbCmd= null
			where	idEvent between @iSizeDat and @iSizeLog
			and		vbCmd is not null

		update	tb_OptSys	set	iValue= @iSizeLog, dtUpdated= @dtNow	where	idOption = 19

	commit
end
go
--	----------------------------------------------------------------------------
--	Sets user's Duty and Break states
--	7.05.5171
create proc		dbo.prStaff_SetDuty
(
	@idUser		int
,	@bOnDuty	bit		--	=	null	--	0=OffDuty, 1=OnDuty, null=see @tiMins
,	@tiMins		tinyint					--	0=finish break, >0=break time, null=see @bOnDuty
)
	with encryption	--, exec as owner
as
begin
	declare	@dtNow			smalldatetime
--	,		@dtDue			smalldatetime
	,		@tNow			time( 0 )
--	,		@idStfAssn		int
--	,		@idStfCvrg		int

	set	nocount	on
	set	xact_abort	on

	select	@dtNow= getdate( )		--	smalldatetime truncates seconds
	select	@tNow= @dtNow			--	time(0) truncates date, leaving HH:MM:00
---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	if	@bOnDuty > 0
		select	@tiMins=	0

	begin	tran

		if	@tiMins = 0		or	@tiMins is null		--or	@bOnDuty > 0
		begin
			if	exists	(select 1 from tb_User with (nolock) where idUser = @idUser and bOnDuty = 0)	-- and dtDue is not null
			begin
					--	set OnDuty staff, who finished break
					update	tb_User		set		bOnDuty= 1, dtDue= null, dtUpdated= @dtNow
						where	idUser = @idUser

					--	init coverage
					exec	dbo.prStfCvrg_InsFin
			end
		end
		else	--	@tiMins > 0		or	@bOnDuty = 0
		begin
			if	exists	(select 1 from tb_User with (nolock) where idUser = @idUser and (bOnDuty = 1 or dtDue is not null))
			begin
				--	set OffDuty and break finish due
				update	tb_User		set		bOnDuty= 0, dtUpdated= @dtNow
										,	dtDue= case when @tiMins > 0 then dateadd( mi, @tiMins, @dtNow ) else null end
					where	idUser = @idUser

			--	reset coverage refs for interrupted assignments
				update	sa	set		idStfCvrg= null, dtUpdated= @dtNow
					from	tbStfAssn	sa
					join	tbStfCvrg	sc	on	sc.idStfCvrg = sa.idStfCvrg	and	sc.dtEnd is null
					where	sa.idUser = @idUser

				--	finish coverage for interrupted assignments
				update	sc	set		dtEnd= @dtNow, dEnd= @dtNow, tEnd= @tNow, tiEnd= datepart( hh, @tNow )
						--		,	dtDue= @dtNow		--	??	adjust to end moment
					from	tbStfCvrg	sc
					join	tbStfAssn	sa	on	sa.idStfAssn = sc.idStfAssn	and	sa.idUser = @idUser
					where	sc.dtEnd is null
			end
		end

	commit
end
go
grant	execute				on dbo.prStaff_SetDuty				to [rWriter]
--grant	execute				on dbo.prStaff_SetDuty				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.05.5169	* [7],[8]	.sClass
begin tran
	update	tbReport	set	sClass= 'xrStfAssn'		where	idReport = 7
	update	tbReport	set	sClass= 'xrStfCvrg'		where	idReport = 8
commit
go


if	exists	( select 1 from tb_Version where idVersion = 705 )
	update	tb_Version	set	dtCreated= '2014-02-27', siBuild= 5171, dtInstall= getdate( )
		,	sVersion= '7.05.5171 - ??'
		where	idVersion = 705
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 705,	5171, '2014-02-27', getdate( ),	'7.05.5171 - ??' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.05.5171'
	where	idModule = 1
go

checkpoint
go

use [master]
go
