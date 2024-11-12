--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
--		2014-Feb-17		.5161
--						* prRoom_LstAct, prStaff_LstAct
--						+ tb_Access	- was omitted by mistake in original .5059 build
--		2014-Feb-21		.5165
--						* tb_Module[61] ->	'7980/79 Notification Service'
--						* tb_User:	+ .dtDue, tvUser_Duty	(dbo.Staff)
--						* prStfAssn_InsUpdDel, prStfAssn_Fin, prStfCvrg_InsFin
--						+ pr_User_SetBreak
--
--						finalized?
--
--	7.06
--		2014-Dec-03		.5450
--						* update tb_User from wtStaff
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5165 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.05.5165', 18, 0 )

go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_SetBreak')
	drop proc	dbo.pr_User_SetBreak
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Access')
	drop table	dbo.tb_Access
go

go
--	----------------------------------------------------------------------------
--	7.05.5165	* [61]
begin tran
	update	tb_Module	set	sDesc= '7980/79 Notification Service'	where	idModule = 61
commit
go
--	----------------------------------------------------------------------------
begin tran
	update	tbStfLvl	set	iColorB= 0xFFFFFACD		where	idStfLvl = 1
	update	tbStfLvl	set	iColorB= 0xFFF5DEB3		where	idStfLvl = 2
	update	tbStfLvl	set	iColorB= 0xFF98FB98		where	idStfLvl = 4
commit
go
--	----------------------------------------------------------------------------
--	App users
--	7.05.5165	+ .dtDue
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'dtDue')
begin
	begin tran
		alter table		dbo.tb_User		add
			dtDue		smalldatetime	null		-- due finish
		,	constraint	tvUser_Duty	check	( bOnDuty = 1  and  dtDue is null	or	bOnDuty = 0 )
	commit
end
go
--	update users
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='wtStaff')
begin
	begin tran
		exec( 'update	u	set	u.sDesc= s.AccessLevel, u.sUnits= s.Units, u.sMidd= s.MiddleName
				from	tb_User u
				join	wtStaff s	on	s.ID = u.sStaffID
			update	u	set	u.sEmail= s.Password	--, u.sUser= s.UserName			--	7.06.5450	removed: causes dups for xu_User
				from	tb_User u
				join	wtStaff s	on	s.ID = u.sStaffID	and	len( s.UserName ) > 0
			' )
	commit
end
begin tran
	update	tb_User		set	bOnDuty= 1		where	idUser > 15

	--	7.06.5450	added to enforce proper name storage
	update	tb_User		set
			sFrst= case when len(sFrst)	> 0 then ltrim(rtrim(sFrst)) else null end
		,	sMidd= case when len(sMidd)	> 0 then ltrim(rtrim(sMidd)) else null end
		,	sLast= case when len(sLast)	> 0 then ltrim(rtrim(sLast)) else null end

	exec	dbo.pr_User_sStaff_Upd	null
commit
go
--	----------------------------------------------------------------------------
--	App module Feature Permissions by Roles
--	7.05.5059
create table	dbo.tb_Access
(
	idModule	tinyint			not null
--		constraint	fk_Access_Module	foreign key references	tb_Module
,	idFeature	tinyint			not null
--		constraint	fk_Access_Feature	foreign key references	tb_Feature
,	idRole		smallint		not null
		constraint	fk_Access_Role		foreign key references	tb_Role

,	tiAccess	tinyint			not null
--		constraint	td_Access_Access	default( 0 )
,	dtCreated	smalldatetime	not null
		constraint	td_Access_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	td_Access_Updated	default( getdate( ) )

,	constraint	xp_Access		primary key clustered ( idModule, idFeature, idRole )
,	constraint	fk_Access_Feature	foreign key ( idModule, idFeature ) references	tb_Feature
)
go
grant	select, insert, update, delete	on dbo.tb_Access		to [rWriter]
grant	select							on dbo.tb_Access		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active staff, ordered to be loadable into a dropdown
--	7.05.5161	* active -> all, + '(inactive)' indication
--	7.05.5064	+ .idDvcType = 1
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4953
alter proc		dbo.prStaff_LstAct
	with encryption
as
begin
	select	s.idUser, s.sFqStaff + case
				when b.lCount = 1 then ' -- [' + cast(b.idDvc as varchar) + ']'
	--			when b.lCount > 1 then ' -- ' + cast(b.lCount as varchar) + ' badges'
				when b.lCount > 1 then ' -- [' + cast(b.idDvc as varchar) + '], +' + cast(b.lCount-1 as varchar)
				else '' end + case
				when bActive = 0 then ' -- (inactive)'
				else ''	end		[sFqStaff]
		,	s.iColorB
		from	vwStaff	s	with (nolock)
		left outer join	(select	idUser, count(*) [lCount], min(idDvc) [idDvc]	from	tbDvc	with (nolock)	where	idDvcType = 1	group by idUser) b	on	b.idUser = s.idUser
	--	where	bActive > 0
		order	by	idStfLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	Returns all rooms, ordered to be loadable into a combobox (indicating inactive)
--	7.05.5161	* active -> all, + '(inactive)' indication
--	7.04.4959	prRoom_GetAct -> prRoom_LstAct
--	7.04.4953	* added ' '
--	7.03
alter proc		dbo.prRoom_LstAct
	with encryption
as
begin
--	set	nocount	on
	select	idDevice	[idRoom],		sSGJ + ' ' + sQnDevice + case
				when bActive = 0 then ' -- (inactive)'
				else ''	end		[sQnRoom]
		from	vwRoom	with (nolock)
	--	where	bActive > 0
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Finalizes specified staff assignment definition by marking it inactive
--	7.05.5165	* reset only if current staff is from given assignment definition
--	7.04.4955	* fix logic
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn, prStaffAssn_Fin -> prStfAssn_Fin
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
--	7.01	+ resetting assinged staff in tbRoomBed
--	7.00	tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.02
alter proc		dbo.prStfAssn_Fin
(
	@idStfAssn		int
)
	with encryption
as
begin
	declare		@iCvrg		int

	set	nocount	on
	set	xact_abort	on

	begin	tran

		--	deactivate and close everything associated with that StaffAssn
		update	tbStfCvrg	set
				dtEnd= getdate( ), dEnd= getdate( ), tEnd= getdate( ), tiEnd= datepart( hh, getdate( ) )
			where	idStfAssn = @idStfAssn
		select	@iCvrg= @@rowcount

		update	rb	set	idAssn1=	null				--	reset assigned staff if in room
			from	tbRoomBed	rb
			inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
			where	idStfAssn = @idStfAssn
			and		rb.idAssn1 = sa.idUser

		update	rb	set	idAssn2=	null
			from	tbRoomBed	rb
			inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
			where	idStfAssn = @idStfAssn
			and		rb.idAssn2 = sa.idUser

		update	rb	set	idAssn3=	null
			from	tbRoomBed	rb
			inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
			where	idStfAssn = @idStfAssn
			and		rb.idAssn3 = sa.idUser

		update	tbStfAssn	set							--	deactivate
				bActive= 0, idStfCvrg= null, dtUpdated= getdate( )
			where	idStfAssn = @idStfAssn

		if	@iCvrg = 0									--	purge if no coverage history
			delete	from	tbStfAssn
				where	idStfAssn = @idStfAssn

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
--	7.05.5165	* 
--	7.05.5050	* change logic, remove extra args
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4955	* fix logic
--	7.04.4920	- tbStaff -> tb_User
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn, prStaffAssn_InsUpdDel -> prStfAssn_InsUpdDel
--	7.03.4884	+ trace output
--	7.00	* tbDevice.bActive > 0
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02
--	6.01
alter proc		dbo.prStfAssn_InsUpdDel
(
	@idStfAssn	int							-- null = new
,	@idUnit		smallint					-- unit look-up FK
,	@idRoom		smallint					-- room look-up FK
,	@tiBed		tinyint						-- bed index FK
,	@tiShIdx	tinyint						-- shift index [1..3]
,	@tiIdx		tinyint						-- staff index [1..3]
,	@idUser		int							-- staff look-up FK
,	@bActive	bit							-- active?
,	@cSys		char( 1 )		= null		-- corresponding to idRoom
,	@tiGID		tinyint			= null
,	@tiJID		tinyint			= null
,	@sStaffID	varchar( 16 )	= null		-- corresponding to idUser
)
	with encryption
as
begin
	declare		@idShift	smallint
		,		@s			varchar( 255 )
		,		@iTrace		int

	set	nocount	on

	select	@idShift =	idShift												--	get corresponding shift
		from	tbShift		with (nolock)
		where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx

	if	@idRoom = 0	or	@idRoom is null
		select	@idRoom =	idDevice										--	get corresponding room
			from	vwRoom		with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID		and	tiJID = @tiJID

	if	@idUser = 0	or	@idUser is null
		select	@idUser =	idUser											--	get corresponding user
			from	tb_User		with (nolock)
			where	bActive > 0		and	sStaffID = @sStaffID

	select	@s =	'SA_IUD( ID=' + isnull(cast(@idStfAssn as varchar),'?') + ' ,idU=' + isnull(cast(@idUnit as varchar),'?') +
					', idR=' + isnull(cast(@idRoom as varchar),'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
					', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
					', ixSt=' + isnull(cast(@tiIdx as varchar),'?') + ', idSt=' + isnull(cast(@idUser as varchar),'?') +
					', bAct=' + isnull(cast(@bActive as varchar),'?')

	if	@tiGID > 0
		select	@s =	@s + ', cS=' + isnull(cast(@cSys as varchar),'?') + ', tiG=' + isnull(cast(@tiGID as varchar),'?') +
						', tiJ=' + isnull(cast(@tiJID as varchar),'?') + ', sSt=' + isnull(cast(@sStaffID as varchar),'?')

	select	@s =	@s + ' )'

	begin	tran

		if	@idStfAssn > 0	and	( @bActive = 0	or	@idUser is null )
			exec	dbo.prStfAssn_Fin	@idStfAssn							--	finalize assignment
	
		else
		if	@bActive > 0	and	@idShift > 0	and	@idRoom > 0		and	@tiBed >= 0		and	@tiShIdx > 0	and	@tiIdx > 0	and	@idUser > 0
		begin
			if	@idStfAssn > 0
				if	exists( select 1 from tbStfAssn where idStfAssn = @idStfAssn and idUser <> @idUser )
				begin
					exec	dbo.prStfAssn_Fin	@idStfAssn					--	another staff is assigned - finalize previous one

					select	@idStfAssn =	null
				end

			if	@idStfAssn = 0	or	@idStfAssn is null
			begin
				insert	tbStfAssn	(  idRoom,  tiBed,  idShift,  tiIdx,  idUser )
						values		( @idRoom, @tiBed, @idShift, @tiIdx, @idUser )
				select	@idStfAssn =	scope_identity( )
				select	@s =	@s + ': ' + cast(@idStfAssn as varchar)
			end
		end
		else
		begin
			select	@s =	@s + ' invalid args'
			exec	dbo.pr_Log_Ins	47, null, null, @s
			commit
			return	-1
		end

		select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

		if	@iTrace & 0x80 > 0
			exec	dbo.pr_Log_Ins	46, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
--	7.05.5165	* set only OnDuty current staff, reset stale coverage
--	7.05.5123	* fix datetime arithmetics for 2012
--	7.05.5099	* fix #tbDueAssn logic
--	7.05.5086	* logic redesign involving new tbStfCvrg.dtDue
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg, prStaffCover_InsFin -> prStfCvrg_InsFin
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
--	7.02	* tbRoomStaff -> tbRoom
--	7.01	* updating assinged staff in tbRoomBed
--	7.00	+ updating assinged staff in tbRoomBed
--			+ pr_Module_Act call
--			tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--				prStaffAssn_InsFin -> prStaffCover_InsFin
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--			* set tbUnit.idShift
--	6.02
alter proc		dbo.prStfCvrg_InsFin
	with encryption
as
begin
	declare	@dtNow			smalldatetime
	,		@dtDue			smalldatetime
	,		@tNow			time( 0 )
	,		@idStfAssn		int
	,		@idStfCvrg		int

	set	nocount	on
	set	xact_abort	on

	select	@dtNow= getdate( )		--	smalldatetime truncates seconds
	select	@tNow= @dtNow			--	time(0) truncates date, leaving HH:MM:00

---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	create	table	#tbDueAssn
	(
		idStfCvrg	int			not null	primary key clustered

	,	idStfAssn	int			not null
	)

	begin	tran

		--	mark DB component active (since this sproc is executed every minute)
		exec	pr_Module_Act	1

		--	get assignments that are due to complete now
		insert	#tbDueAssn
			select	sc.idStfCvrg, sc.idStfAssn
				from	tbStfCvrg	sc	with (nolock)
				join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn	and	sa.bActive > 0	and	sa.idStfCvrg > 0
				where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

---		select	*	from	#tbDueAssn

		--	reset assigned staff in completed assignments
		update	rb	set		idAssn1= null, idAssn2= null, idAssn3= null, dtUpdated= @dtNow
			from	tbRoomBed	rb
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		--	finish coverage for completed assignments
		update	sc	set		dtEnd= @dtNow, dEnd= @dtNow, tEnd= @tNow, tiEnd= datepart( hh, @tNow )
			from	tbStfCvrg	sc
			join	#tbDueAssn	da	on	da.idStfAssn = sc.idStfAssn	and	da.idStfCvrg = sc.idStfCvrg
	---		where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

		--	reset coverage refs for completed assignments
		update	sa	set		idStfCvrg= null, dtUpdated= @dtNow
			from	tbStfAssn	sa
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		--	reset coverage refs for completed assignments (stale)
		update	sa	set		idStfCvrg= null, dtUpdated= @dtNow
			from	tbStfAssn	sa
			join	tbStfCvrg	sc	on	sc.idStfCvrg = sa.idStfCvrg	and	sc.dtEnd < @dtNow


		--	set current shift for each active unit
		update	u	set		idShift= sh.idShift
			from	tbUnit	u
			join	tbShift	sh	on	sh.idUnit = u.idUnit
			where	u.bActive > 0
			and		sh.bActive > 0	and	u.idShift <> sh.idShift
			and		(	sh.tBeg <= @tNow	and	@tNow < sh.tEnd
					or	sh.tEnd <= sh.tBeg	and	(sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		--	set OnDuty staff, who finished break
		update	tb_User		set		bOnDuty= 1, dtDue= null, dtUpdated= @dtNow
			where	dtDue <= @dtNow


		--	get assignments that should be started/running now, only for OnDuty staff
		declare	cur		cursor fast_forward for
			select	sa.idStfAssn,
			--		case when	sh.tBeg < sh.tEnd	then	@dtNow - @tNow + sh.tEnd		--	!! this works in 2008 R2, but not in 2012
				---		when	sh.tBeg = sh.tEnd	then	@dtNow - @tNow + sh.tEnd + 1	--	matches else (sh.tBeg > sh.tEnd) case
			--										else	@dtNow - @tNow + sh.tEnd + 1 end
					case when	sh.tBeg < sh.tEnd	then	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime)
													else	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime) + 1 end
				from	tbStfAssn	sa	with (nolock)
				join	tb_User		us	with (nolock)	on	us.idUser  = sa.idUser		and	us.bOnDuty > 0	-- only OnDuty
				join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		and	sh.bActive > 0
				where	sa.bActive > 0
				and		sa.idStfCvrg is null						--	not running now
				and		(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStfAssn, @dtDue
		while	@@fetch_status = 0
		begin
---			print	cast(@idStfAssn, varchar) + ': ' + cast(@dtDue, varchar)
		
			insert	tbStfCvrg	(  idStfAssn, dtBeg, dBeg, tBeg, tiBeg, dtDue )
					values		( @idStfAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ), @dtDue )
			select	@idStfCvrg=	scope_identity( )

			update	tbStfAssn		set	idStfCvrg= @idStfCvrg, dtUpdated= @dtNow
				where	idStfAssn= @idStfAssn

			fetch next from	cur	into	@idStfAssn, @dtDue
		end
		close	cur
		deallocate	cur

		---	set current assigned staff
		update	rb	set	idAssn1=	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
											and	sa.idShift = u.idShift	and	sa.bActive > 0
			join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set	idAssn2=	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
											and	sa.idShift = u.idShift	and	sa.bActive > 0
			join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set	idAssn3=	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
											and	sa.idShift = u.idShift	and	sa.bActive > 0
			join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

	commit
end
go
--	----------------------------------------------------------------------------
--	Puts a user on break
--	7.05.5165
create proc		dbo.pr_User_SetBreak
(
	@idUser		int
--,	@siMins		smallint
,	@tiMins		tinyint				--	0=finish break
)
	with encryption, exec as owner
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

	if	@tiMins = 0		or	@tiMins is null
	begin
		if	exists	(select 1 from tb_User with (nolock) where idUser = @idUser and dtDue is not null)
		begin
			begin	tran

				--	set OnDuty staff, who finished break
				update	tb_User		set		bOnDuty= 1, dtDue= null, dtUpdated= @dtNow
					where	idUser = @idUser

				--	reinit coverage
				exec	dbo.prStfCvrg_InsFin

			commit
		end
	end
	else	--	@tiMins > 0
	begin
		if	exists	(select 1 from tb_User with (nolock) where idUser = @idUser and (bOnDuty = 1 or dtDue is not null))
		begin
			begin	tran

				--	set OffDuty and break finish due
				update	tb_User		set		bOnDuty= 0, dtDue= dateadd( mi, @tiMins, @dtNow ), dtUpdated= @dtNow
					where	idUser = @idUser

		/*		--	reset assigned staff in interrupted assignments
				update	rb	set		rb.idAssn1= null, dtUpdated= @dtNow
					from	tbRoomBed	rb
					where	idAssn1 = @idUser
				update	rb	set		rb.idAssn2= null, dtUpdated= @dtNow
					from	tbRoomBed	rb
					where	idAssn2 = @idUser
				update	rb	set		rb.idAssn3= null, dtUpdated= @dtNow
					from	tbRoomBed	rb
					where	idAssn3 = @idUser
		*/
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

			commit
		end
	end
end
go
grant	execute				on dbo.pr_User_SetBreak				to [rWriter]
--grant	execute				on dbo.pr_User_SetBreak				to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='Staff')
	drop view	dbo.Staff
go
create view		dbo.Staff
	with encryption
as
select	sStaffID	[ID]
	,	sLast		[LastName]
	,	sMidd		[MiddleName]
	,	sFrst		[FirstName]
	,	bActive		[Active]
	,	l.sStfLvl	[StaffRole]
	,	sDesc		[AccessLevel]
	,	sUser		[UserName]
	,	sEmail		[Password]
	,	sUnits		[Units]
	,	dtUpdated	[dtUpdate]
	,	idUser		[tempID]
	,	sBarCode
	,	bOnDuty
	,	dtDue
	from	dbo.tb_User		u	with (nolock)
	join	dbo.tbStfLvl	l	with (nolock)	on	l.idStfLvl = u.idStfLvl
go
grant	select, update					on dbo.Staff			to [rWriter]
grant	select, update					on dbo.Staff			to [rReader]
go

--	----------------------------------------------------------------------------
--	import staff devices
/*		done in .5155
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='wtDevice')
exec( '
insert	tbDvc	( idDvcType, sDvc, sUnits, sDial, tiFlags, idUser )
select	case when [Type]=''Pager'' then 2 when [Type]=''Phone'' then 3 end	[idDvcType]
	,	case when len(d.Description) > 0 then d.Description else [Type] + '' '' + ExtensionID end	[sDvc]
	,	d.Units			[sUnits]
	,	ExtensionID		[sDial]
	,	case when GroupID > 0 then 1 else 0 end + case when TechNotifications > 0 then 2 else 0 end		[tiFlags]
--	,	coalesce( pg.StaffID, ph.StaffID )	[sStaffID]		--	,	pg.StaffID, ph.StaffID
	,	s.idUser
	from	dbo.wtDevice	d	with (nolock)
		left outer join	dbo.wtDeviceToStaffAssignment	pg	with (nolock)	on	pg.PagerID = d.ID	and	d.[Type] = ''Pager''
		left outer join	dbo.wtDeviceToStaffAssignment	ph	with (nolock)	on	ph.PhoneExt = d.ID	and	d.[Type] = ''Phone''
		left outer join	dbo.vwStaff	s	with (nolock)	on	s.sStaffID = coalesce( pg.StaffID, ph.StaffID )
	where	[Type] + '' '' + ExtensionID	not in	(select	sDvcType + '' '' + isnull(sDial,idDvc) from vwDvc where bActive > 0)
	order	by	[Type], ExtensionID

declare		@id	int
	,		@i			int
	,		@sUnits		varchar( 255 )
	,		@p			varchar( 3 )
	,		@idUnit		smallint

declare		cur		cursor fast_forward for
	select	idDvc, sUnits
		from	tbDvc	with (nolock)
		where	idDvcType > 1	and	sUnits is not null

begin tran

	open	cur
	fetch next from	cur	into	@id, @sUnits
	while	@@fetch_status = 0
	begin
--		print	char(10) + cast( @id as varchar )
		if	@sUnits = ''All Units''
		begin
			delete	from	tbDvcUnit
				where	idDvc = @id
			insert	tbDvcUnit	( idDvc, idUnit )
				select	@id, idUnit
					from	tbUnit
					where	bActive > 0		and		idShift > 0
--			print	''all units''
		end
		else
		begin
			select	@i=	0
	_again:
--			print	@sUnits
			select	@i=	charindex( '','', @sUnits )
			select	@p= case when @i > 0 then substring( @sUnits, 1, @i - 1 ) else @sUnits end
--			print	''i='' + cast( @i as varchar ) + '', p='' + @p

			select	@idUnit=	cast( @p as smallint )
				,	@sUnits=	case when @i > 0 then substring( @sUnits, @i + 1, 32 ) else null end
--			print	''u='' + cast( @idUnit as varchar )
			if	not	exists	(select 1 from tbDvcUnit where idDvc=@id and idUnit=@idUnit)
				insert	tbDvcUnit	( idDvc, idUnit )
						values	( @id, @idUnit )
			if	@i > 0		goto	_again
		end

		fetch next from	cur	into	@id, @sUnits
	end
	close	cur
	deallocate	cur

commit

' )
*/
go


if	exists	( select 1 from tb_Version where idVersion = 705 )
	update	dbo.tb_Version	set	dtCreated= '2014-02-21', siBuild= 5165, dtInstall= getdate( )
		,	sVersion= '7.05.5165 - schema refactored, 7980 tables replaced'
		where	idVersion = 705
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 705,	5165, '2014-02-21', getdate( ),	'7.05.5165 - schema refactored, 7980 tables replaced' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.5.5165'
	where	idModule = 1
go

checkpoint
go

use [master]
go
