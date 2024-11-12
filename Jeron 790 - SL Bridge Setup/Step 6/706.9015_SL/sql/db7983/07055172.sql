--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
--		2014-Feb-28		.5172
--						* prStaff_SetDuty
--						+ prShift_InsUpd
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5172 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.05.5172', 18, 0 )

go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_SetDuty')
	drop proc	dbo.prStaff_SetDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_InsUpd')
	drop proc	dbo.prShift_InsUpd
go

go
--	----------------------------------------------------------------------------
--	Updates # of shifts for all or given unit(s)
--	7.05.5172
--	7.05.4983
alter proc		dbo.prUnit_UpdShifts
(
	@idUnit		smallint		= null	-- null==all
)
	with encryption
as
begin
--	set	nocount	on
	set	xact_abort	on

	begin tran

		if	@idUnit is null
			update	u	set	u.tiShifts= s.tiShifts
				from	tbUnit	u
				join	(select	idUnit, count(*) [tiShifts]
							from	tbShift	with (nolock)
							where	bActive > 0
							group	by	idUnit)	s	on	s.idUnit = u.idUnit
		else
			update	tbUnit	set	tiShifts=
						(select	count(*)
							from	tbShift	with (nolock)
							where	bActive > 0	and	idUnit = @idUnit)
				where	idUnit = @idUnit

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
--	7.05.5172
create proc		dbo.prShift_InsUpd
(
	@idShift	smallint	out
,	@idUnit		smallint
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiRouting	tinyint
,	@tiNotify	tinyint
,	@idUser		int
,	@bActive	bit
)
	with encryption
as
begin
	set	nocount	on
	set	xact_abort	on

	if	@idShift < 0												--	find shift by unit and index
		select	@idShift= idShift
			from	tbShift		with (nolock)
			where	idUnit = @idUnit	and	tiIdx = @tiIdx

	begin	tran

		if	@idShift is null	or	@idShift < 0
		begin
			insert	tbShift	(  idUnit,  tiIdx,  sShift,  tBeg,  tEnd )
					values	( @idUnit, @tiIdx, @sShift, @tBeg, @tEnd )
			select	@idShift=	scope_identity( )

			exec	dbo.prUnit_UpdShifts	@idUnit
		end
		else
			update	tbShift		set	sShift= @sShift, tBeg= @tBeg, tEnd= @tEnd, tiRouting= @tiRouting	--, idUnit= @idUnit, tiIdx= @tiIdx
						,	tiNotify= @tiNotify, idUser= @idUser, bActive= @bActive, dtUpdated= getdate( )
				where	idShift = @idShift

	commit
end
go
grant	execute				on dbo.prShift_InsUpd				to [rWriter]
--grant	execute				on dbo.prShift_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Sets user's Duty and Break states
--	7.05.5172	* fix @bOnDuty condition
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

	begin	tran

		if	@bOnDuty > 0
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
		else	--	@bOnDuty = 0
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


if	exists	( select 1 from tb_Version where idVersion = 705 )
	update	tb_Version	set	dtCreated= '2014-02-28', siBuild= 5172, dtInstall= getdate( )
		,	sVersion= '7.05.5172 - ??'
		where	idVersion = 705
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 705,	5172, '2014-02-28', getdate( ),	'7.05.5172 - ??' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.05.5172'
	where	idModule = 1
go

checkpoint
go

use [master]
go
