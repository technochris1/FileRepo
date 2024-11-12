--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2023-Oct-11		.8684
--						* prStaff_GetByUnit, pr_Role_GetAll, prTeam_GetByUnit, prDvc_GetByUnit
--		2023-Oct-13		.8686
--						* pr_User_GetAll
--		2023-Oct-17		.8690
--						* prStfAssn_InsUpdDel
--		2023-Oct-20		.8693
--						* prUnit_UpdShifts, prShift_InsUpd
--						+ prShift_Upd
--		2023-Oct-23		.8696
--						* vwShift, prShift_GetAll
--		2023-Nov-01		.8705
--						* (tb_Log's IDENTITY:	1 -> 0x80000000 == -2147483648)	(pr_Log_XltDtEvRng)
--		2023-Nov-07		.8711
--						* pr_Log_Get, pr_Log_XltDtEvRng
--						+ tb_Option[50..53], tb_OptSys[50..53]
--		2023-Nov-08		.8712
--						+ prHealth_Stats
--						* prStfCvrg_InsFin
--		2023-Nov-14		.8718
--						* pr_Version_GetAll
--		2023-Nov-15		.8719
--						* pr_User_Logout
--		2023-Nov-21		.8725
--						* prHealth_Stats
--		2023-Nov-22		.8726
--						* pr_User_SyncAD
--		2023-Nov-29		.8733
--						* prRptSysActDtl
--		2023-Nov-30		.8734
--						* pr_User_InsUpdAD, pr_User_InsUpd, prDvc_InsUpd
--		2023-Dec-06		.8740
--						* vwRoom, vwRtlsBadge
--						* tbDvc:	.tiFlags	(prDvc_UpdUsr, prDvc_InsUpd, prDvc_GetByUnit, prRtlsBadge_InsUpd)
--		2023-Dec-08		.8742
--						* finalized
--		2023-Dec-19		.8753
--						* vwRtlsBadge, prRtlsBadge_GetAll
--		2024-Jan-04		.8769
--						* prRtlsBadge_GetAll, prStaff_LstAct, prDvc_UpdUsr
--						* finalized
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 8769 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.8769', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Stats')
	drop proc	dbo.prHealth_Stats
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Upd')
	drop proc	dbo.prShift_Upd
go
--	----------------------------------------------------------------------------
--	Returns assignable active staff for given unit(s)
--	7.06.8684	+ @sStaff
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8280	+ filter out RTLS-auto staff:	substring(st.sStaff, 1, 1) <> char(0x7F)
--	7.06.8139	* vwDevice:	 sQnDevice -> sFqDvc
--				* .sQnRoom -> .sQnDvc
--	7.06.7886	- .idPager, .idPhone, .idWi_Fi
--	7.06.6809	+ .idWi_Fi, .sWi_Fi
--	7.06.5429	+ .dtDue
--	7.06.5333	* tbDvcType[3] -> [4]
--	7.05.5246	* order by sStaffID ->	idStfLvl desc, sStaff
--	7.05.5154
alter proc		dbo.prStaff_GetByUnit
(
	@sUnits		varchar(255)		-- comma-separated idUnit's, '*'=all or null
,	@idStfLvl	tinyint		= null	-- null=any, 1=Yel, 2=Ora, 4=Grn
,	@bOnDuty	bit			= null	-- null=any, 0=off, 1=on
,	@sStaff		varchar(18)	= null	-- null, or '%<name or StfID>%'
)
	with encryption
as
begin
	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	create table	#tbUser
	(
		idUser		int				not null

		primary key nonclustered ( idUser )
	)

	insert	#tbUser
		select	distinct	idUser
			from	tb_UserUnit	uu	with (nolock)
			join	#tbUnit		un	with (nolock)	on	un.idUnit	= uu.idUnit

	select	st.idUser, st.idStfLvl, st.sStfID, st.sStaff, st.bOnDuty, st.dtDue
		,	st.idRoom,	r.sQnDvc
		,	stuff((select ', ' + pg.sDial
						from	tbDvc	pg	with (nolock)	where	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
						for xml path ('')), 1, 2, '')	as	sPager
		,	stuff((select ', ' + ph.sDial
						from	tbDvc	ph	with (nolock)	where	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
						for xml path ('')), 1, 2, '')	as	sPhone
		,	stuff((select ', ' + wf.sDial
						from	tbDvc	wf	with (nolock)	where	wf.idUser = st.idUser	and	wf.idDvcType = 8	and	wf.bActive > 0
						for xml path ('')), 1, 2, '')	as	sWi_Fi
		from	vwStaff	st	with (nolock)
		join	#tbUser	u	with (nolock)	on	u.idUser	= st.idUser
	left join	vwRoom	r	with (nolock)	on	r.idDevice	= st.idRoom
		where	st.bActive > 0
		and		substring(st.sStaff, 1, 1) <> char(0x7F)					--	7.06.8280	filter out RTLS-auto staff
		and		(@idStfLvl is null	or	st.idStfLvl	= @idStfLvl)
		and		(@bOnDuty is null	or	st.bOnDuty	= @bOnDuty)
		and		(@sStaff is null	or	st.sStaff like @sStaff	or	st.sStfID like @sStaff)
		order	by	st.idStfLvl desc, st.sStaff
end
go
--	----------------------------------------------------------------------------
--	Returns details for all roles
--	7.06.8684	+ @sRole
--	7.06.6795	+ @idUnit
--	7.05.5234
alter proc		dbo.pr_Role_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUnit		smallint	= null	-- null=any
,	@sRole		varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
--	set	nocount	on
	select	idRole, sRole, sDesc, bActive, dtCreated, dtUpdated
		from	tb_Role		with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
	--	and		idRole > 15													--	protect internal accounts
		and		(@idUnit is null	or	idRole	in	(select idRole from tb_RoleUnit with (nolock) where idUnit = @idUnit))
		and		(@sRole is null		or	sRole like @sRole)					--	7.06.8684

end
go
--	----------------------------------------------------------------------------
--	Returns teams filtered by unit (and active status)
--	7.06.8684	+ @sTeam
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--	7.05.5191	* by unit
--	7.05.5179	+ .sUnits, .sCalls
--	7.05.5175
alter proc		dbo.prTeam_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
,	@sTeam		varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, bEmail, sDesc, bActive, dtCreated, dtUpdated		--, sCalls, sUnits
		from	tbTeam	with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
		and		(@idUnit is null	or	idTeam	in	(select idTeam from tbTeamUnit with (nolock) where idUnit = @idUnit))
		and		(@sTeam is null		or	sTeam like @sTeam)					--	7.06.8684
--		order	by	sTeam
end
go
--	----------------------------------------------------------------------------
--	Returns details for specified users
--	7.06.8686	* @sStaffID:	vc16 -> vc18, now filters sUser, sStaff, sStfID
--	7.06.8413	+ @bOnDuty
--	7.06.6814	- tb_User.sTeams,.sUnits
--	7.06.6795	+ @idUnit
--	7.06.6080	+ .bGUID
--	7.06.5961	+ .bLocked	(7983rh uses it)
--	7.06.5960	- .bLocked
--	7.06.5954	+ .gGUID, .utSynched
--	7.06.5785	+ 'Other' @idStfLvl handling
--	7.06.5567	* merged pr_User_GetByUnit -> pr_User_GetAll
--	7.06.5563	+ '@idUser <= 15' to allow returning predifined system user-accounts
--	7.06.5399	* optimized
--	7.05.5182
alter proc		dbo.pr_User_GetAll
(
	@idStfLvl	tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bOnDuty	bit			= null	-- null=any, 0=off, 1=on
,	@idUser		int			= null	-- null=any
,	@idUnit		smallint	= null	-- null=any
,	@sStaffID	varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStaffID, idStfLvl, sBarCode, bOnDuty, dtDue, sStaff	--, sUnits, sTeams
		,	gGUID, utSynched
		,	bActive, dtCreated, dtUpdated
		,	cast(case when	tiFails=0xFF	then 1	else 0	end	as	bit)	as	bLocked
		,	cast(case when	gGUID is null	then 0	else 1	end	as	bit)	as	bGUID
		from	tb_User		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idStfLvl is null	or	idStfLvl = @idStfLvl	or	@idStfLvl = 0	and	idStfLvl is null)
		and		(@bOnDuty is null	or	bOnDuty = @bOnDuty)
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
--		and		(@sStaffID is null	or	sStaffID = @sStaffID)				--	7.06.8684
		and		(@sStaffID is null	or	sUser like @sStaffID	or	sStaff like @sStaffID	or	sStaffID like @sStaffID)
		and		(@idUnit is null	or	idUser in (select idUser from tb_UserUnit with (nolock) where idUnit = @idUnit))
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
--	7.06.8690	- @tiShIdx
--				+ @idShift
--				* param order
--	7.06.7465	- @cSys, @tiGID, @tiJID, @sStaffID
--				* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5940	* optimize logging
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
--,	@tiShIdx	tinyint						-- shift index [1..3]
,	@idShift	smallint
,	@idRoom		smallint					-- room look-up FK
,	@tiBed		tinyint						-- bed index FK
,	@tiIdx		tinyint						-- staff index [1..3]
,	@idUser		int							-- staff look-up FK
,	@bActive	bit							-- active?
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@sRoom		varchar( 16 )
		,		@sUser		varchar( 16 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@sUnit =	sUnit		from	tbUnit		with (nolock)	where	idUnit = @idUnit
--	select	@idShift =	idShift		from	tbShift		with (nolock)	where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx
	select	@sRoom =	sDevice		from	tbDevice	with (nolock)	where	idDevice = @idRoom
	select	@sUser =	sUser		from	tb_User		with (nolock)	where	idUser = @idUser

	select	@s =	'SA( ' + isnull(cast(@idStfAssn as varchar),'?') +
--					', ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiShIdx as varchar),'?') + '=' + isnull(cast(@idShift as varchar),'?') +
					', ' + isnull(cast(@idUnit as varchar),'?') + '|' + isnull(cast(@sUnit as varchar),'?') + ':' + isnull(cast(@idShift as varchar),'?') +
					', ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(cast(@sRoom as varchar),'?') + ':' + isnull(cast(@tiBed as varchar),'?') +
					', ' + isnull(cast(@tiIdx as varchar),'?') + ':' + isnull(cast(@idUser as varchar),'?') + '|' + isnull(cast(@sUser as varchar),'?') +
					' a=' + isnull(cast(@bActive as varchar),'?') + ' )'

	begin	tran

		if	@idStfAssn > 0	and	( @bActive = 0	or	@idUser is null )
			exec	dbo.prStfAssn_Fin	@idStfAssn							--	finalize assignment
	
		else
--		if	@bActive > 0	and	@idShift > 0	and	@idRoom > 0		and	@tiBed >= 0		and	@tiShIdx > 0	and	@tiIdx > 0		and	@idUser > 0
		if	@bActive > 0	and	@idShift > 0	and	@idRoom > 0		and	@tiBed >= 0		and	@tiIdx > 0		and	@idUser > 0
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
			select	@s =	@s + ' !'
			exec	dbo.pr_Log_Ins	47, null, null, @s, 62
			commit
			return	-1
		end

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	248, null, null, @s, 62

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates # of shifts for all or given unit(s)
--	7.06.8693
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
				join	(select	idUnit,	count(*)	as	tiShifts
							from	tbShift	with (nolock)
							where	bActive > 0
							group	by	idUnit)	s	on	s.idUnit = u.idUnit
		else
			update	tbUnit	set	tiShifts=
						(select	count(*)
							from	tbShift	with (nolock)
							where	bActive > 0		and	idUnit = @idUnit)
				where	idUnit = @idUnit

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates mode and backup of a given shift
--	7.06.8693
create proc		dbo.prShift_Upd
(
	@idUser		int					-- user, performing the action
,	@idUnit		smallint
,	@idShift	smallint			-- not null
,	@tiMode		tinyint				-- not null=set notify + bkup
,	@idOper		int					-- operand user, backup staff
)
	with encryption
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )
			,	@idStfAssn	int
			,	@tiIdx		tinyint
--			,	@sShift		varchar( 8 )
--			,	@tBeg		time( 0 )
--			,	@tEnd		time( 0 )
--			,	@bActive	bit

	set	nocount	on
	set	xact_abort	on

	select	@tiIdx =	tiIdx	--,	@sShift =	sShift,	tBeg =	@tBeg,	tEnd =	@tEnd,	@bActive =	bActive
		from	tbShift		with (nolock)
		where	@idShift = idShift	and	bActive > 0

	select	@s =	'Shft_U( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
--					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', nm=' + isnull(cast(@tiMode as varchar),'?') + ' bk=' + isnull(cast(@idOper as varchar),'?') + ' )'

	select	@k =	248

	begin	tran

		update	tbShift		set		tiMode =	@tiMode,	idUser =	@idOper,	dtUpdated=	getdate( )
			where	idShift = @idShift

--		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62

	commit
end
go
grant	execute				on dbo.prShift_Upd					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
--	7.06.8693	- @tiMode, @idOper
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.7465	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5415	+ @idUser, logging, @idUser -> @idOper
--	7.06.4939	- .tiRouting
--	7.05.5172
alter proc		dbo.prShift_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idUnit		smallint
,	@idShift	smallint	out		-- null=new shift
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@bActive	bit
)
	with encryption
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )
			,	@idStfAssn	int

	set	nocount	on
	set	xact_abort	on

	if	@idShift is null	or	@idShift < 0
		select	@idShift =	idShift
			from	tbShift		with (nolock)
			where	idUnit = @idUnit	and	tiIdx = @tiIdx

	select	@s =	'Shft_IU( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', a=' + isnull(cast(@bActive as varchar),'?') + ' )'
--					' cr=' + isnull(convert(varchar, @dtCreated, 20),'?') + ' up=' + isnull(convert(varchar, @dtUpdated, 20),'?') + ' )'

	begin	tran

		if	@idShift is null	or	@idShift < 0
		begin
			insert	tbShift	(  idUnit,  tiIdx,  sShift,  tBeg,  tEnd )
					values	( @idUnit, @tiIdx, @sShift, @tBeg, @tEnd )
			select	@idShift =	scope_identity( )

			select	@s =	@s + '=' + cast(@idShift as varchar)
				,	@k =	247
		end
		else
		begin
			update	tbShift		set		dtUpdated=	getdate( ),	tBeg =	@tBeg,	tEnd =	@tEnd,	bActive =	@bActive
				where	idShift = @idShift

			if	@bActive = 0
			begin
				declare	cur		cursor fast_forward for
					select	idStfAssn
						from	tbStfAssn	with (nolock)
						where	idShift = @idShift	--	and	bActive > 0

				open	cur
				fetch next from	cur	into	@idStfAssn
				while	@@fetch_status = 0
				begin
					exec	dbo.prStfAssn_Fin	@idStfAssn					--	finalize assignment

					fetch next from	cur	into	@idStfAssn
				end
				close	cur
				deallocate	cur
			end

			select	@k =	248
		end

		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8696	+ .bCurrent
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5429	+ .dtDue
--	7.06.4939	- .tiRouting
--	7.05.5226
alter view		dbo.vwShift
	with encryption
as
select	sh.idUnit, u.sUnit
	,	cast(case when	u.bActive > 0 and u.idShift = sh.idShift	then 1	else 0	end	as	bit)	as	bCurrent
	,	sh.idShift, tiIdx, sShift, tBeg, tEnd, tiMode
	,	sh.idUser, s.idStfLvl, s.sStfID, s.sStaff, s.bOnDuty, s.dtDue
	,	sh.bActive, sh.dtCreated, sh.dtUpdated
	from	tbShift	sh	with (nolock)
	join	tbUnit	u	with (nolock)	on	u.idUnit = sh.idUnit
left join	vwStaff	s	with (nolock)	on	s.idUser = sh.idUser
go
--	----------------------------------------------------------------------------
--	Returns shifts for a given unit (ordered by index) or current one or specified one
--	7.06.8696	- @bCurrent
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5429	+ .dtDue
--	7.06.5401	* merged prShift_GetByUnit -> prShift_GetAll
--	7.05.5275	+ @bCurrent
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4938
alter proc		dbo.prShift_GetAll
(
	@idUnit		smallint	= null	-- null=any
,	@idShift	smallint	= null	-- null=any for given unit, -1=current for given unit
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, tiMode, bActive, dtCreated, dtUpdated, idUser, idStfLvl, sStfID, sStaff, bOnDuty, dtDue
		from	vwShift		with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
		and		(@idUnit is null	or	idUnit	= @idUnit)
		and		(@idShift is null	or	idShift	= @idShift	or	@idShift < 0	and	bCurrent > 0)
		order	by	idUnit, tiIdx
end
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering condition into tb_Log.idLog range
--	7.06.8711	* @dFrom, @dUpto:	datetime -> date
--	7.06.8705	* modified lowest @iFrom (0 -> 0x80000000 = -2147483648)
--	7.06.6534	* modified for null date-args
--	7.06.6512
alter proc		dbo.pr_Log_XltDtEvRng
(
	@dFrom		date				-- date from
,	@dUpto		date				-- date upto
,	@tFrom		tinyint				-- hour from
,	@tUpto		tinyint				-- hour upto
,	@iFrom		int			out		-- idLog from
,	@iUpto		int			out		-- idLog upto
)
	with encryption
as
begin
	set	nocount	on

	if	@dFrom is null
		select	@iFrom =	0x80000000		--	min int (-2147483648)
	else
		select	@iFrom =	min(idLog)
			from	tb_Log_S	with (nolock)
			where	@dFrom <= dLog	and	@tFrom <= tiHH

	if	@dUpto is null
		select	@iUpto =	0x7FFFFFFF		--	max int (2147483647)
	else
		select	@iUpto =	min(idLog)
			from	tb_Log_S	with (nolock)
			where	@dUpto = dLog	and	@tUpto < tiHH
				or	@dUpto < dLog

	if	@iUpto is null
		select	@iUpto =	0x7FFFFFFF		--	max int (2147483647)

--	select	@dFrom [dFrom], @iFrom [idFrom], @dUpto [dUpto], @iUpto [idUpto]
end
go
--	----------------------------------------------------------------------------
--	Returns activity log entries in a page of given size
--	7.06.8711	* @dFrom, @dUpto:	datetime -> date
--				* optimized performance
--	7.06.7123	* tb_LogType.tiSrc -> .tiCat
--	7.06.6534	* modified for null args
--	7.06.6533	+ @bGroup
--	7.06.6526	* tb_SessLog -> tb_SessMod
--				+ @dFrom, @dUpto, @tFrom, @tUpto
--	7.06.6311	+ #pages filtered by @idSess
--	7.06.6306	+ .idModule, .sModule
--	7.06.5611	* @iPages moved last, optimized joins
--	7.05.4975	* .tiLevel -> .tiLvl, .tiSource -> tiSrc
--	6.05	* @tiLvl, @tiSrc take action now
--			+ (nolock)
--	6.04	+ @tiLvl, @tiSrc
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02
alter proc		dbo.pr_Log_Get
(
	@iIndex		int					-- index of the page to show
,	@iCount		int					-- page size (in rows)
,	@tiLvl		tinyint				-- bitwise tb_LogType.tiLvl, 0xFF=include all
,	@tiCat		tinyint				-- bitwise tb_LogType.tiCat, 0xFF=include all
,	@iPages		int				out	-- total # of pages
,	@idSess		int			=	0	-- when not 0 filter sources using tb_SessLog
,	@dFrom		date		=	null	-- 
,	@dUpto		date		=	null	-- 
,	@tFrom		tinyint		=	null	-- 
,	@tUpto		tinyint		=	null	-- 
,	@bGroup		bit			=	0	-- 0=paged log, else=stats
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@idLog		int

	set	nocount	on

	exec	dbo.pr_Log_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	select	@iIndex =	@iIndex * @iCount + 1		-- index of the 1st output row
		,	@iPages =	0

	if	@bGroup = 0
	begin
		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	tb_Log	with (nolock)
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	tb_Log	with (nolock)
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					order	by	idLog desc
			end
			else										-- filter by source
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					order	by	idLog desc
			end
		else											-- filter by level or category
			if	@idSess = 0
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	tb_Log l	with (nolock)
					join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	tb_Log l	with (nolock)
					join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by	idLog desc
			end
			else										-- filter by source
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on	t.idLogType = l.idLogType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on	t.idLogType = l.idLogType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by	idLog desc
			end

		set	rowcount	@iCount
		set	nocount	off

		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and	@idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					order	by 1 desc
			else										-- filter by source
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					order	by 1 desc
		else											-- filter by level or category
			if	@idSess = 0
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by 1 desc
			else										-- filter by source
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by 1 desc
	end
	else
	begin
		set	rowcount	0
		set	nocount	off

		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and	@iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					group	by	l.idLogType
					order	by	lQty	desc
			else										-- filter by source
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					group	by	l.idLogType
					order	by	lQty	desc
		else											-- filter by level or category
			if	@idSess = 0
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					group	by	l.idLogType
					order	by	lQty	desc
			else										-- filter by source
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					group	by	l.idLogType
					order	by	lQty	desc
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.8725	+ [55..56]
--	7.06.8711	+ [50..54]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 50)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 50,  56, '(internal) DB recovery model' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 51,  56, '(internal) Data size, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 52,  56, '(internal) Data used, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 53,  56, '(internal) Tlog size, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 54,  56, '(internal) Tlog used, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 55,  61, '(internal) Last Data bkup' )				--	7.06.8725
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 56,  61, '(internal) Last Tlog bkup' )				--	7.06.8725

		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 50, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 51, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 52, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 53, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 54, 0 )
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 55, '1900-01-01' )
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 56, '1900-01-01' )
	end
commit
go
--	----------------------------------------------------------------------------
--	Updates DB stats (# of Size and Used pages - for data and tlog)
--	7.06.8725	+ recovery_model
--				+ last backup dates
--	7.06.8712
create proc		dbo.prHealth_Stats
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@iRM		int
		,		@iSizeD		int
		,		@iUsedD		int
		,		@iSizeL		int
		,		@iUsedL		int
		,		@dBkupD		datetime
		,		@dBkupL		datetime

	set	nocount	on

	select	@iSizeD =	size,	@iUsedD =	cast(fileproperty(name, 'spaceused') as int)
		from	sys.database_files	with (nolock)
		where	[type] = 0													-- .mdf

	select	@iSizeL =	size,	@iUsedL =	cast(fileproperty(name, 'spaceused') as int)
		from	sys.database_files	with (nolock)
		where	[type] = 1													-- .ldf

	select	@s =	cast(cast(@iSizeD / 128.0 as decimal(18,1)) as varchar) + '(' + cast(cast(@iUsedD * 100.0 / @iSizeD as decimal(18)) as varchar) + '%) / '
				+	cast(cast(@iSizeL / 128.0 as decimal(18,1)) as varchar) + '(' + cast(cast(@iUsedL * 100.0 / @iSizeL as decimal(18)) as varchar) + '%) MiB @'
				+	@@servicename + ' [' + lower(recovery_model_desc) + ']'
--				+	case when log_reuse_wait = 0 then '' else ',' + lower(log_reuse_wait_desc) end	-- cast(log_reuse_wait as varchar)
		,	@iRM =	recovery_model
		from	master.sys.databases	with (nolock)
		where	database_id = db_id( )

	select	top	1	@dBkupD =	backup_finish_date
		from	msdb.dbo.backupset	with (nolock)
		where	database_name = db_name( )	and	[type] = 'D' 				-- .mdf
		order	by	1	desc

	select	top	1	@dBkupL =	backup_finish_date
		from	msdb.dbo.backupset	with (nolock)
		where	database_name = db_name( )	and	[type] = 'L' 				-- .mdf
		order	by	1	desc

	begin	tran

		update	dbo.tb_OptSys	set	iValue =	@iRM		where	idOption = 50

		update	dbo.tb_OptSys	set	iValue =	@iSizeD		where	idOption = 51
		update	dbo.tb_OptSys	set	iValue =	@iUsedD		where	idOption = 52

		update	dbo.tb_OptSys	set	iValue =	@iSizeL		where	idOption = 53
		update	dbo.tb_OptSys	set	iValue =	@iUsedL		where	idOption = 54

		if	@dBkupD	is not null
			update	dbo.tb_OptSys	set	tValue =	@dBkupD		where	idOption = 55
		if	@dBkupL	is not null
			update	dbo.tb_OptSys	set	tValue =	@dBkupL		where	idOption = 56

		update	dbo.tb_Module	set	sParams =	@s			where	idModule = 1

	commit
end
go
grant	execute				on dbo.prHealth_Stats				to [rWriter]
grant	execute				on dbo.prHealth_Stats				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
--	7.06.8712	+ prHealth_Stats call
--	7.06.8426	+ log staff returning to duty from break
--	7.06.8318	* optimized tracing
--	7.06.6053	+ tbStfCvrg.dShift
--	7.06.6022	+ reporting DB recovery-model, file-sizes and log-reuse-wait in tb_Module[1].sParams
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.05.5176	* OnDuty does not affect currently assigned staff
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
	declare		@s			varchar( 255 )
		,		@dtNow		smalldatetime
		,		@dtDue		smalldatetime
		,		@tNow		time( 0 )
		,		@dShift		date
		,		@idUser		int
		,		@idStfAssn	int
		,		@idStfCvrg	int

	set	nocount	on
	set	xact_abort	on

---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	create	table	#tbUser
	(
		idUser		int			not null	primary key clustered

	,	sQnStf		varchar(36)	not null
	)
	create	table	#tbDueAssn
	(
		idStfCvrg	int			not null	primary key clustered

	,	idStfAssn	int			not null
	)

	-- get recovery_model_desc and log_reuse_wait
	select	@dtNow =	getdate( )											-- smalldatetime truncates seconds
	select	@tNow =		@dtNow												-- time(0) truncates date, leaving HH:MM:00

	-- get a list of users whose break is expiring on this pass
	insert	#tbUser
		select	idUser, sQnStf	from	dbo.vwStaff		where	dtDue <= @dtNow
--		select	idUser	from	tb_User		where	dtDue <= @dtNow

	begin	tran

		exec	dbo.prHealth_Stats											-- update DB size stats
		exec	dbo.pr_Module_Act	1										-- mark DB component active (since this sproc is executed every minute)

		-- get assignments that are due to complete now
		insert	#tbDueAssn
			select	sc.idStfCvrg, sc.idStfAssn
				from	tbStfCvrg	sc	with (nolock)
				join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn	and	sa.bActive > 0	and	sa.idStfCvrg > 0
				where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

---		select	*	from	#tbDueAssn

		--	reset assigned staff in completed assignments
		update	rb	set		idUser1 =	null,	idUser2 =	null,	idUser3 =	null,	dtUpdated=	@dtNow
			from	tbRoomBed	rb
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		-- finish coverage for completed assignments
		update	sc	set		dtEnd=	@dtNow,	dEnd =	@dtNow,	tEnd =	@tNow,	tiEnd=	datepart(hh, @tNow)
			from	tbStfCvrg	sc
			join	#tbDueAssn	da	on	da.idStfAssn = sc.idStfAssn	and	da.idStfCvrg = sc.idStfCvrg
	---		where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

		--	reset coverage refs for completed assignments
		update	sa	set		idStfCvrg=	null,	dtUpdated=	@dtNow
			from	tbStfAssn	sa
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		-- reset coverage refs for completed assignments (stale)
		update	sa	set		idStfCvrg=	null,	dtUpdated=	@dtNow
			from	tbStfAssn	sa
			join	tbStfCvrg	sc	on	sc.idStfCvrg = sa.idStfCvrg	and	sc.dtEnd < @dtNow


		-- set current shift for each active unit
		update	u	set		idShift =	sh.idShift
			from	tbUnit	u
			join	tbShift	sh	on	sh.idUnit = u.idUnit
			where	u.bActive > 0
			and		sh.bActive > 0	and	u.idShift <> sh.idShift
			and		(	sh.tBeg <= @tNow	and	@tNow < sh.tEnd
					or	sh.tEnd <= sh.tBeg	and	(sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		-- set OnDuty staff, who finished break
		update	tb_User		set		bOnDuty =	1,	dtDue=	null,	dtUpdated=	@dtNow
			where	dtDue <= @dtNow

		-- log these staff transitions
		declare	cur		cursor fast_forward for
			select	idUser, sQnStf
				from	#tbUser

		open	cur
		fetch next from	cur	into	@idUser, @s
		while	@@fetch_status = 0
		begin
			exec	dbo.pr_Log_Ins	218, @idUser, null, @s	--, @idModule

			fetch next from	cur	into	@idUser, @s
		end
		close	cur
		deallocate	cur

		-- get assignments that should be started/running now, only for OnDuty staff
		declare	cur		cursor fast_forward for
			select	sa.idStfAssn,
			--		case when	sh.tBeg < sh.tEnd	then	@dtNow - @tNow + sh.tEnd		--	!! this works in 2008 R2, but not in 2012
				---		when	sh.tBeg = sh.tEnd	then	@dtNow - @tNow + sh.tEnd + 1	--	matches else (sh.tBeg > sh.tEnd) case
			--										else	@dtNow - @tNow + sh.tEnd + 1 end
					case when	sh.tBeg < sh.tEnd	then	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime)
													else	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime) + 1 end
				,	case when	sh.tEnd <= sh.tBeg	and	@tNow < sh.tEnd		then	dateadd( dd, -1, @dtNow )	else	@dtNow	end
				from	tbStfAssn	sa	with (nolock)
				join	tb_User		us	with (nolock)	on	us.idUser  = sa.idUser		and	us.bOnDuty > 0	-- only OnDuty
				join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		and	sh.bActive > 0
				where	sa.bActive > 0
				and		sa.idStfCvrg is null						--	not running now
				and		(	sh.tBeg <= @tNow	and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStfAssn, @dtDue, @dShift
		while	@@fetch_status = 0
		begin
---			print	cast(@idStfAssn, varchar) + ': ' + cast(@dtDue, varchar)
		
			insert	tbStfCvrg	(  idStfAssn, dtBeg, dBeg, tBeg, tiBeg, dtDue, dShift )
					values		( @idStfAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ), @dtDue, @dShift )
			select	@idStfCvrg =	scope_identity( )

			update	tbStfAssn	set		idStfCvrg=	@idStfCvrg,		dtUpdated=	@dtNow
				where	idStfAssn = @idStfAssn

			fetch next from	cur	into	@idStfAssn, @dtDue, @dShift
		end
		close	cur
		deallocate	cur

		-- set current assigned staff
		update	rb	set		idUser1 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
											and	sa.idShift = u.idShift	and	sa.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set		idUser2 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
											and	sa.idShift = u.idShift	and	sa.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set		idUser3 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
											and	sa.idShift = u.idShift	and	sa.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

	commit
end
go
--	----------------------------------------------------------------------------
--	<100,tb_Log>
--	clean-up
begin tran
	delete	from	dbo.tb_Log	where	sLog like 'EvA_Exp( 0 ) removed 0 inactive events in %'
	print	@@rowcount
commit
go
--	----------------------------------------------------------------------------
--	Returns installation history
--	7.06.8718	* only show dtInstall for the builds, corresponding to upgrade dates
--	7.06.6953	* removed 'db7983.' from object refs
--	7.06.6509
alter proc		dbo.pr_Version_GetAll
	with encryption
as
begin
	select	idVersion, v.siBuild, dtCreated, sVersion
		,	case when i.siBuild > 0 then v.dtInstall else null end	as	dtInstall
		,	isnull( i.siBuild, 0 )	as	miBuild
		from	dbo.tb_Version	v	with (nolock)
		left join	(select		dtInstall,	max(siBuild)	as	siBuild
						from	dbo.tb_Version	with (nolock)
						group	by	dtInstall)	i	on	i.siBuild = v.siBuild
		order	by	2	desc
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
--	7.06.8719	* ?d -> 00?d
--	7.06.8472	* 121 -> 120, 114 -> 108 (no ms)
--	7.06.7388	+ [.idSess] into log
--	7.06.7300	* Duration	(cause datediff(dd, ) swallows days)
--	7.06.7142	* optimized logging (+ [DT-dtCreated])
--	7.06.7115	* optimized logging (+ dtCreated)
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.06.5940	* optimize
--	7.05.5246	- @idUser
--	7.05.5227	- @sIpAddr, @sMachine
--	7.05.5044	* @idUser: smallint -> int
--	7.03	+ @idSess
--			* optimize desc-string
--	6.05	+ (nolock)
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.00
alter proc		dbo.pr_User_Logout
(
	@idSess		int
,	@idLogType	tinyint
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@tiLog		tinyint
		,		@idModule	tinyint
		,		@idUser		int
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )
		,		@dtCreated	datetime

	set	nocount	on

	select	@idUser =	idUser,		@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule,	@dtCreated =	dtCreated
		from	tb_Sess
		where	idSess = @idSess

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	if	@idUser > 0
	begin
		begin	tran

			update	tb_Sess		set	dtLastAct=	getdate( ),	idUser =	null
				where	idSess = @idSess

			select	@s =	'@ ' + isnull(@sMachine, '?') + ' (' + isnull(@sIpAddr, '?') + ') [' + cast(@idSess as varchar) + '] ' + isnull(convert(varchar, @dtCreated, 120), '?') +
							' | ' + isnull(right('00' + cast(datediff(ss, @dtCreated, getdate())/86400 as varchar), 3), '?') + 'd ' + isnull(convert(varchar, getdate()-@dtCreated, 108), '?')

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Initializes or finalizes AD-Sync
--	7.06.8726	+ reset duty for inactive (',	bOnDuty =	0,	dtDue =	null') in finish path to satisfy [tv_User_Duty]
--	7.06.7299	+ @idModule
--	7.06.7279	* optimized logging
--	7.06.7251	- 'and	bActive > 0' from that rename
--	7.06.7244	+ rename login to GUID for accounts removed from AD (left disabled in our DB)
--					prepend a comment in .sDesc, describing this and record original login
--	7.06.6019
alter proc		dbo.pr_User_SyncAD
(
	@idModule	tinyint
,	@bActive	bit					-- 1=start, 0=finish
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Usr_SAD( ' + cast(@bActive as varchar) + ' ) '

	begin	tran

		if	@bActive > 0													-- start AD-Sync
		begin
			update	tb_User		set		bConfig =	0,	dtUpdated=	getdate( )
				where	gGUID is not null	and	bConfig > 0

			select	@s =	@s + '*' + cast(@@rowcount as varchar)
		end
		else																-- finish AD-Sync
		begin
--			update	tb_User		set		sDesc =		convert(varchar, getdate( ), 120) + ': "' + sUser + '" no longer in AD. ' + sDesc
--				where	gGUID is not null	and	bConfig = 0		and	bActive > 0

			update	tb_User		set		bActive =	0,	dtUpdated=	getdate( ),		bOnDuty =	0,	dtDue =	null
				,	sDesc =		convert(varchar, getdate( ), 120) + ': [' + sUser + '] no longer authorized. ' + isnull(sDesc,'')
				,	sUser =		replace( cast(gGUID as char(36)), '-', '' )	-- rename login to GUID
				where	gGUID is not null	and	bConfig = 0	--	and	bActive > 0
				and		sUser <> replace( cast(gGUID as char(36)), '-', '' )

			select	@s =	@s + '-' + cast(@@rowcount as varchar)
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	100, null, null, @s, @idModule	--	238	--	7.06.7251

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
--	7.06.8733	+ unassign deactivated
--	7.06.7433	* optimized logging
--	7.06.7326	* inactive user can't stay on-duty
--	7.06.7299	+ @idModule
--	7.06.7279	* optimized logging
--	7.06.7251	+ return indicating the result (idLogType of [101..104])
--	7.06.7249	* only audit when smth has changed (minimize log impact)
--	7.06.7129	+ tb_LogType[100-103]
--	7.06.7094	* only import *active* users
--	7.06.6806	* reset .tiFails when user is unlocked in AD
--	7.06.6088	* " placement in trace
--	7.06.6046	+ set .bConfig when no update is done,
--				* optimize tracing
--	7.06.6019	* set .bConfig
--	7.06.5963	* cast(GUID as char(38))
--	7.06.5960	+ @tiFails, UTC
--	7.06.5955
alter proc		dbo.pr_User_InsUpdAD
(
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
,	@idOper		int			out		-- operand user, acted upon
,	@gGUID		uniqueidentifier	-- AD GUID
,	@dtUpdated	smalldatetime		-- (UTC) AD's 'whenChanged'
,	@sUser		varchar( 32 )
,	@sFrst		varchar( 16 )
,	@sMidd		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
,	@tiFails	tinyint
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
		,		@s	varchar( 255 )
		,		@utSynched	smalldatetime		-- (UTC) time of last AD-Sync

	set	nocount	on
	set	xact_abort	on

	if	@idUser = 4															-- System
		select	@idUser =	null

	select	@idOper =	idUser,		@utSynched =	utSynched
		from	tb_User with (nolock)
		where	gGUID = @gGUID

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '] ut=' + isnull(convert(varchar, @utSynched, 120), '?') +
				' ' + isnull(upper(cast(@gGUID as char(36))), '?') + ' [' + @sUser + '] ''' + isnull(cast(@sFrst as varchar), '?') +
				''' ''' + isnull(cast(@sMidd as varchar), '?') + ''' ''' + isnull(cast(@sLast as varchar), '?') +
				''' ' + isnull(cast(@sEmail as varchar), '?') + ' d=''' + isnull(cast(@sDesc as varchar), '?') +
				''' k=' + cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' ad=' + isnull(convert(varchar, @dtUpdated, 120), '?')
	begin	tran

		if	@idOper = 0		or	@idOper is null								-- user not found
		begin
			if	0 < @bActive												--	7.06.7094	only import *active* users!
			begin
				insert	tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
						values	( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
				select	@idOper =	scope_identity( )

				select	@s =	'Usr_ADI( ' + @s + ' )=' + cast(@idOper as varchar)
					,	@k =	102		--	237								--	7.06.7129
			end
			else															--	7.06.7094
				select	@s =	'Usr_ADI( ' + @s + ' ) ^'					-- *inactive skipped*
					,	@k =	101		--	2								--	7.06.7129
		end
		else
		if	@utSynched < @dtUpdated											-- AD had a recent change
		begin
			update	tb_User	set		sUser =		@sUser,		sFrst=	@sFrst,		sMidd=	@sMidd,		sLast=	@sLast
								,	sEmail =	@sEmail,	sDesc=	@sDesc,		utSynched=	getutcdate( )
								,	tiFails =	case when	@tiFails = 0xFF	then	@tiFails
													when	tiFails = 0xFF	then	0
													else	tiFails		end
								,	bOnDuty =	case when	@bActive = 0	then	0		else	bOnDuty	end
								,	dtDue =		case when	@bActive = 0	then	null	else	dtDue	end
								,	bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'Usr_ADU( ' + @s + ' ) *'
				,	@k =	103		--	238									--	7.06.7129
		end
		else																-- user already up-to date
		begin
			if	0 < @bActive												-- if user is active
				update	tb_User	set		sUser =		@sUser,		sDesc=	@sDesc,		utSynched=	getutcdate( )
					where	idUser = @idOper	--	and	sUser <> @sUser		-- restore his login (.sUser) and update .utSynched

			update	tb_User	set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
								,	bOnDuty =	case when	@bActive = 0	then	0		else	bOnDuty	end
								,	dtDue =		case when	@bActive = 0	then	null	else	dtDue	end
				where	idUser = @idOper									-- update .bActive and mark user 'processed'

			select	@s =	'Usr_AD( ' + @s + ' )'
				,	@k =	104		--	238									--	7.06.7129,	7.06.7251

		end

		if	@bActive = 0													--	.8733	unassign deactivated
		begin
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, 0, 0		-- must precede table update

			delete	from	tb_UserRole					where	idUser = @idOper	and	idRole > 1
			delete	from	tb_UserUnit					where	idUser = @idOper
			delete	from	tbTeamUser					where	idUser = @idOper
			update	tbDvc		set	idUser =	null	where	idUser = @idOper
			update	tbShift		set	idUser =	null	where	idUser = @idOper
			update	tbStfAssn	set	bActive =	0		where	idUser = @idOper
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper

		if	@k < 104														--	7.06.7251	!! do not flood audit with 'skips' !!
			exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s, @idModule

		if	101 < @k														--	7.06.7094/7129	only import *active* users!
			-- enforce membership in 'Public' role
			if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
				insert	tb_UserRole	( idRole, idUser )
						values		( 1, @idOper )

	commit

	return	@k
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
--	7.06.8734	+ unassign deactivated
--	7.06.8488	* fix prStaff_SetDuty call
--	7.06.8432	+ @idModule for prStaff_SetDuty
--				+ exec dbo.prStaff_SetDuty
--	7.06.7433	* optimized logging
--	7.06.7326	* enforce 'Other' users un-assignable and off-duty
--				* inactive user can't stay on-duty
--	7.06.7279	* optimized logging
--	7.06.6814	- tb_User.sTeams, .sUnits
--				* added logging of roles, teams and units
--	7.06.6373	* optimized logging
--	7.06.5955	* optimized logging
--	7.06.5494	* enforce membership in 'Public' role
--	7.06.5415	* optimized
--	7.05.5254	+ @sRoles
--	7.05.5220	+ @sTeams
--	7.05.5190	* fix tb_UserUnit insertion
--	7.05.5182	+ @sUnits >> tb_UserUnit (via prUnit_SetTmpFlt)
--	7.05.5123	* prUser_sStaff_Upd -> pr_User_sStaff_Upd
--	7.05.5121	+ .sUnits
--	7.05.5029	* .sStaff is required
--	7.05.5021
alter proc		dbo.pr_User_InsUpd
(
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
,	@idOper		int			out		-- operand user, acted upon
,	@sUser		varchar( 32 )
,	@iHash		int
,	@tiFails	tinyint
,	@sFrst		varchar( 16 )
,	@sMidd		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
,	@sStaffID	varchar( 16 )
,	@idStfLvl	tinyint
,	@sBarCode	varchar( 32 )
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
,	@sRoles		varchar( 255 )
,	@bOnDuty	bit
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@idLogType	tinyint

	set	nocount	on
	set	xact_abort	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)
	create table	#tbTeam						-- no enforcement of FKs
	(
		idTeam		smallint		not null	-- team id
--	,	sTeam		varchar( 16 )	not null	-- team name

		primary key nonclustered ( idTeam )
	)
	create table	#tbRole						-- no enforcement of FKs
	(
		idRole		smallint		not null	-- role id
--	,	sRole		varchar( 16 )	not null	-- role name

		primary key nonclustered ( idRole )
	)

	if	@bActive = 0		select	@bOnDuty =	0,	@sUnits =	null,	@sTeams =	null,	@sRoles =	null	--	.8734
	if	@idStfLvl is null	select	@bOnDuty =	0,	@sUnits =	null		--	7.06.7334

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	if	not exists	(select 1 from #tbRole with (nolock) where idRole = 1)
		insert	#tbRole		(idRole)	values	( 1 )						-- enforce membership in 'Public' role

	select	@s =	isnull(cast(@idOper as varchar), '?') + '|' + @sUser + ', ''' + isnull(cast(@sFrst as varchar), '?') +
					''' ''' + isnull(cast(@sMidd as varchar), '?') + ''' ''' + isnull(cast(@sLast as varchar), '?') +
					''' ' + isnull(cast(@sEmail as varchar), '?') + ' d=''' + isnull(cast(@sDesc as varchar), '?') +
					''', I=' + isnull(cast(@sStaffID as varchar), '?') + ' L=' + isnull(cast(@idStfLvl as varchar), '?') +
					' B=' + isnull(cast(@sBarCode as varchar), '?') + ', D=' + isnull(cast(@bOnDuty as varchar), '?') +
					' k=' + cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' R=' + isnull(cast(@sRoles as varchar), '?') +
					' T=' + isnull(cast(@sTeams as varchar), '?') + ' U=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc, sStaff,  sStaffID,  idStfLvl,  sBarCode,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc,    ' ', @sStaffID, @idStfLvl, @sBarCode, @bActive )
			select	@idOper =	scope_identity( )
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bOnDuty, 0	--	.8488	must follow table update

			select	@idLogType =	237,	@s =	'Usr_I( ' + @s + ' )=' + cast(@idOper as varchar)
		end
		else
		begin
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bOnDuty, 0	--	.8488	must precede table update
			update	tb_User	set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
								,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
								,	sStaffID =	@sStaffID,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode
								,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@idLogType =	238,	@s =	'Usr_U( ' + @s + ' )'
		end

		if	@bActive = 0													--	.8733	unassign deactivated
		begin
--			delete	from	tb_UserRole					where	idUser = @idOper	and	idRole > 1
--			delete	from	tb_UserUnit					where	idUser = @idOper
--			delete	from	tbTeamUser					where	idUser = @idOper
			update	tbDvc		set	idUser =	null	where	idUser = @idOper
			update	tbShift		set	idUser =	null	where	idUser = @idOper
			update	tbStfAssn	set	bActive =	0		where	idUser = @idOper
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper
--	-	exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bOnDuty, 0
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, @idOper, @s, @idModule

		delete	from	tb_UserUnit
			where	idUser = @idOper
			and		idUnit	not in	(select	idUnit	from	#tbUnit	with (nolock))

		insert	tb_UserUnit	( idUnit, idUser )
			select	idUnit, @idOper
				from	#tbUnit	with (nolock)
				where	idUnit	not in	(select	idUnit	from	tb_UserUnit	with (nolock)	where	idUser = @idOper)

		delete	from	tbTeamUser
			where	idUser = @idOper
			and		idTeam	not in	(select	idTeam	from	#tbTeam	with (nolock))

		insert	tbTeamUser	( idTeam, idUser )
			select	idTeam, @idOper
				from	#tbTeam	with (nolock)
				where	idTeam	not in	(select	idTeam	from	tbTeamUser	with (nolock)	where	idUser = @idOper)

		delete	from	tb_UserRole
			where	idUser = @idOper
			and		idRole	not in	(select	idRole	from	#tbRole	with (nolock))

		insert	tb_UserRole	( idRole, idUser )
			select	idRole, @idOper
				from	#tbRole	with (nolock)
				where	idRole	not in	(select	idRole	from	tb_UserRole	with (nolock)	where	idUser = @idOper)

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8733	* fix for tb_Log.idLog and tbEvent.idEvent IDENTITY starting at -2147483648
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.8458	* fix output
--	7.06.8388	* 
--	7.06.8369	* vwCall -> tbCall, tbCfgPri.tiFlags -> .siFlags
--	7.06.8194	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.8143	* finalized output
--	7.06.8137	* vwStaff.sFqStaff -> sQnStf
--	7.06.8130	+ t.cDvcType
--	7.06.8123	* vwDvc
--	7.06.8122	+ tb_Log now keeps refs to important audit events
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.5491	* optimize audio / notification handling
--	7.06.5490	* optimize tiSvc (tbEvent.tiFlags) handling
--	7.06.5487	* - tbEvent8A, tbEvent95, tbEvent98
--	7.06.5483	* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.06.5421	* optimized
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--				+ @siBeds (ignored for now)
--	7.05.5304	+ .siIdx, .tiSpec, .tiSvc
--	7.05.5095	* tbEvent41
--	7.05.5066	* redesign output (vwEvent)
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.02	tbEvent.tElapsed -> .tOrigin
--	6.05	+ (nolock), optimize
--	6.04	* optimize output to localize data manipulations to sproc
--			* optimize event selection range using tbEvent_S
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.00	.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiDvcs -> @tiDvc
--	5.02
alter proc		dbo.prRptSysActDtl
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=include no-device events
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@sSvc8		varchar( 16 )
		,		@sSvc4		varchar( 16 )
		,		@sSvc2		varchar( 16 )
		,		@sSvc1		varchar( 16 )
		,		@sNull		char( 1 )
		,		@sSpc6		char( 6 )
		,		@sGrTm		varchar( 16 )
		,		@sSyst		varchar( 16 )

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	' STAT',	@sNull =	'',		@sSpc6 =	'      ',	@sGrTm =	'Group/Team',	@sSyst =	'** $YSTEM **'
	select	@sSvc4 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	set	nocount	off

	if	@tiDvc = 0xFF
		insert	#tbRpt1
			select	e.idEvent
				from		vwEvent		e	with (nolock)
		--	-	join		tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
--				order	by	e.idEvent
	else if	@tiDvc = 1
		insert	#tbRpt1
			select	e.idEvent
				from		vwEvent		e	with (nolock)
				join		tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
--				order	by	e.idEvent
	else
		insert	#tbRpt1
			select	e.idEvent
				from		vwEvent		e	with (nolock)
				left join	tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
		--	-	and		(e.idSrcDvc in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcDvc is null)		-- is left join not enough??
--				order	by	e.idEvent

	select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
		,	e.idCmd,	e.tiBtn,	lt.tiLvl, e.idLogType		--,	e.idRoom, e.tiBed
		,	case	--when e.idCmd = 0x83		then e.sInfo						-- Gway
					when cp.tiSpec = 23			then @sSyst			else e.sRoomBed		end		as	sRoomBed
		,	e.idCall, e.sCall,	c.siIdx, cp.tiSpec, cp.tiColor,		e.tiFlags					as	tiSvc
		,	e.idSrcDvc,		e.idDstDvc, e.sDstSGJR,					e.sQnSrcDvc					as	sSrcDvc
		,	case	when l.idLog is not null	then l.sModule		else e.sSrcSGJR		end		as	sSrcSGJR		--		when e.idCmd in (0, 0x83)
--		,	case	when en.idEvent is not null	then nd.cDvcType	else e.cDstDvc		end		as	cDstDvc
		,	case	when en.idEvent is not null	then nd.sQnDvc		else e.sQnDstDvc	end		as	sDstDvc
		,	case	when en.idEvent is not null	then nt.sNtfType
					when 0 < e.idLogType		then e.sLogType		else k.sCmd	end
			+	case	when e.idCmd = 0x95		then	-- ' ' +
					case	when 0 < e.tiFlags & 0x08	then @sSvc8	else
					case	when 0 < e.tiFlags & 0x04	then @sSvc4	else @sNull	end
				+	case	when 0 < e.tiFlags & 0x02	then @sSvc2	else @sNull	end
				+	case	when 0 < e.tiFlags & 0x01	then @sSvc1	else @sNull	end	end
												else @sNull								end		as	sEvent
		,	case	when e.idCmd = 0x84	and	cp.tiSpec = 23
						or l.idLog is not null				then null			-- Log|+-AppFail
					when 0 < cp.siFlags & 0x1000			then @sSpc6 + u1.sQnStf		-- Presence
																else e.sInfo			end		as	sInfo
		,	case	when 0 < cp.siFlags & 0x1000			then u1.idStfLvl
					when 0 < du.idUser 						then du.idStfLvl	-- Badge
																else null				end		as	idStfLvl
		,	case	when e.idCmd = 0x84	and	cp.tiSpec = 23		then e.sInfo	-- +-AppFail
					when l.idLog is not null	then replace(l.sLog, char(9), char(32))
																else null				end		as	sLog
		,	case	when en.idEvent is not null	then	--	du.sQnStf
						case	when 0 < nd.tiFlags & 0x01	then @sGrTm	else du.sQnStf	end
					when l.idLog is not null	then l.sUser		else null			end		as	sStaff	
		from		#tbRpt1		et	with (nolock)
		join		vwEvent		e	with (nolock)	on	e.idEvent		= et.idEvent
		join		tbDefCmd	k	with (nolock)	on	k.idCmd			= e.idCmd
		join		tb_LogType	lt	with (nolock)	on	lt.idLogType	= e.idLogType
		left join	tbCall		c	with (nolock)	on	c.idCall		= e.idCall
		left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
		left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent		= e.idEvent
		left join	vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
		left join	tbEvent41	en	with (nolock)	on	en.idEvent		= e.idEvent
		left join	tbNtfType	nt	with (nolock)	on	nt.idNtfType	= en.idNtfType
		left join	vwStaff		du	with (nolock)	on	du.idUser		= en.idUser
		left join	vwDvc		nd	with (nolock)	on	nd.idDvc		= en.idDvc
		left join	vw_Log		l	with (nolock)	on	l.idLog			= e.iHash	and	e.idCmd in (0, 0x83)		-- Log|Gway
		order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
--	<100,tb_User>
--	clean-up
create table	#tbCln
(
	idUser		int		primary key clustered
)

insert	#tbCln
	select	idUser
		from	tb_User	with (nolock)
		where	bActive = 0

begin tran
	begin
		delete	from	tb_UserRole		where	idUser in (select idUser from #tbCln with (nolock))		and	idRole > 1
		delete	from	tb_UserUnit		where	idUser in (select idUser from #tbCln with (nolock))
		delete	from	tbTeamUser		where	idUser in (select idUser from #tbCln with (nolock))

		update	d	set	idUser =	null
			from	tbDvc	d
			join	#tbCln	u	on	u.idUser = d.idUser
		update	s	set	idUser =	null
			from	tbShift	s
			join	#tbCln	u	on	u.idUser = s.idUser
		update	a	set	bActive =	0
			from	tbStfAssn	a
			join	#tbCln	u	on	u.idUser = a.idUser
	end
commit

drop table	#tbCln
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + registered staff
--	7.06.8740	* tbDevice -> vwDevice		less redefinitions
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--				* idStfLvl? -> idStLvl?, sStaffID? -> sStfID?
--	7.06.8139	* sQnDevice -> sQnDvc
--	7.06.7292	+ .idUser4, .idUser2, .idUser1
--	7.06.7262	+ .tiCall
--	7.06.6225	+ .dtExpires
--	7.06.5990	* sSGJR,sSGJ: S-GGG-JJ-RR -> S-GGG-JJJ-RR (in 680 J range is upto 133)
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* .idReg[4,2,1] -> .idUser[G,O,Y], .idRegLvl[] -> .idStfLvl[], .sRegID[] -> .sStaffID[], .sReg[] -> .sStaff[], .bRegDuty[] -> .bOnDuty[]
--	7.06.5464	+ .dtDue (for each staff)
--	7.05.5154	+ .idRegN, .idRegLvlN, .sRegIDN, .sRegN, .bRegDutyN
--	7.05.5095	* d.dtUpdated -> r.dtUpdated
--				- .sFnDevice
--	7.04.4892	* vwRoomAct -> vwRoom,	match output to vwDevice
--	7.03		vwRoom -> vwRoomAct
alter view		dbo.vwRoom
	with encryption
as
select	r.idUnit,	idDevice, idParent,		cSys, tiGID, tiJID, tiRID, iAID, tiStype,	cDevice, sDevice, sDial, sCodeVer, sUnits, r.siBeds, r.sBeds
--	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
--	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)												as sSGJ
--	,	'[' + cDevice + '] ' + sDevice		as sQnDvc		--	,	cDevice + ' ' + sDevice				as sFqDvc
	,	sSGJR, sSGJ, sQnDvc
	,	r.idEvent,	r.tiSvc
	,	r.idUserG,	s4.idStfLvl	as	idStLvlG,	s4.sStfID	as	sStfIdG,	coalesce(s4.sStaff, r.sStaffG)	as	sStaffG,	s4.bOnDuty	as	bOnDutyG,	s4.dtDue	as	dtDueG
	,	r.idUserO,	s2.idStfLvl	as	idStLvlO,	s2.sStfID	as	sStfIdO,	coalesce(s2.sStaff, r.sStaffO)	as	sStaffO,	s2.bOnDuty	as	bOnDutyO,	s2.dtDue	as	dtDueO
	,	r.idUserY,	s1.idStfLvl	as	idStLvlY,	s1.sStfID	as	sStfIdY,	coalesce(s1.sStaff, r.sStaffY)	as	sStaffY,	s1.bOnDuty	as	bOnDutyY,	s1.dtDue	as	dtDueY
	,	r.dtExpires,	r.idUser4,	r.idUser2,	r.idUser1,	r.tiCall
	,	d.bActive, d.dtCreated, r.dtUpdated
--	from	tbDevice	d	with (nolock)
	from	vwDevice	d	with (nolock)
	join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
	left join	vwStaff	s4	with (nolock)	on	s4.idUser = r.idUserG
	left join	vwStaff	s2	with (nolock)	on	s2.idUser = r.idUserO
	left join	vwStaff	s1	with (nolock)	on	s1.idUser = r.idUserY
go
--	----------------------------------------------------------------------------
--	7.06.8875	- tvDvc_Assn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tvDvc_Assn')
	alter table	dbo.tbDvc	drop constraint	tvDvc_Assn
go
--	----------------------------------------------------------------------------
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--				+ tvDvc_Assn
--if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='tvDvc_Assn')
begin
	begin tran
		update	tbDvc	set	tiFlags =											--	enforce assignability
					case when	(idDvcType = 1	and tiFlags > 0
							or	idDvcType = 2	and	tiFlags & 1 = 0
							or	idDvcType > 2)	and	bActive > 0		then	1	else	0	end

		update	tbDvc	set	tiFlags =	tiFlags | 2								--	set RTLS-auto
			where	idUser	in	(select idUser from	dbo.tb_User (nolock) where substring(sStaff, 1, 1) = char(0x7F))

		update	tbDvc	set	idUser =	null									--	enforce unassigned
			where	bActive = 0		or	tiFlags = 0								--	inactive or unassignable devices

--		alter table	dbo.tbDvc	add
--			constraint	tvDvc_Assn	check	( idDvcType > 1	and	(tiFlags & 1 = 0	or	bActive > 0)			--	only active devices can be assignable
--															and	(tiFlags & 1 > 0	or	idUser is null) )		--	and only assignable can be assigned
	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
--	7.06.8753	+ n.tiFlags
--	7.06.8740	+ d.sQnDvc
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8137	* sFqStaff -> sQnStf
--	7.06.7261	- .idRcvrLast (fkRtlsBadge_LastRcvr), .dtRcvrLast, .idRoom (fkRtlsBadge_Room)
--				* .idRcvrCurr -> .idReceiver (fkRtlsBadge_CurrRcvr -> fkRtlsBadge_Receiver), .dtRcvrCurr -> .dtReceiver
--				- .cSys, .tiGID, .tiJID, .tiRID
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4953	+ vwStaff.sFqStaff
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--				* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.02	- tbRtlsBadge.idStaff (no need now, tbStaffDvc.idStaff keeps relationship)
--	7.00	vwRtlsRcvr -> tbRtlsRcvr
--			.tiPtype -> .idStaffLvl
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.04	* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	6.03
alter view		dbo.vwRtlsBadge
	with encryption
as
select	b.idBadge, n.tiFlags
	,	n.idUser, s.sStfID, s.idStfLvl, s.sStfLvl, s.sStaff, s.sQnStf
	,	b.idReceiver, r.sReceiver, b.dtReceiver
	,	r.idRoom, d.cDevice, d.sDevice, d.sSGJ, d.sQnDvc, b.dtEntered	--,	b.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		join	tbDvc		n	with (nolock)	on	n.idDvc = b.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idUser =	n.idUser
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idReceiver
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = r.idRoom
go
--	----------------------------------------------------------------------------
--	Inserts or updates a notification device
--	7.06.8745	+ make phones/wi-fi assignable
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--				+ unassign unassignable
--	7.06.8734	+ unassign deactivated
--	7.06.8432	+ @idModule
--	7.06.8431	+ reset user for group device (pager)
--	7.06.6814	- tb_User.sUnits, .sTeams
--				* added logging of units and teams
--	7.06.6780	* Wi-Fi devices: ensure proper sBarCode, clear sUnits,sTeams
--	7.06.6459	+ Wi-Fi devices
--				+ unassign deactivated
--	7.06.5457	* swap @sDial <-> @sBarCode
--	7.05.5186	* fix tbDvcUnit insertion
--	7.05.5184	+ .sTeams
--	7.05.5182	+ @sUnits >> tbDvcUnit (via prUnit_SetTmpFlt)
--	7.05.5121	+ .sUnits
--	7.05.5021
alter proc		dbo.prDvc_InsUpd
(
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
,	@idDvc		int out				-- device, acted upon
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sDial		varchar( 16 )
,	@sBarCode	varchar( 32 )
,	@tiFlags	tinyint
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@idLogType	tinyint
		,		@idOper		int

	set	nocount	on
	set	xact_abort	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)
	create table	#tbTeam						-- no enforcement of FKs
	(
		idTeam		smallint		not null	-- team id
--	,	sTeam		varchar( 16 )	not null	-- team name

		primary key nonclustered ( idTeam )
	)

	if	@idDvcType > 2														--	7.06.8745	Phone, Wi-Fi
		select	@tiFlags =	@tiFlags | 0x01									--		enforce assignable

--	if	@idDvcType = 0x01	and	@bActive = 0								--	7.06.8431	inactive Badge
	if	@bActive = 0														--	7.06.8740	inactive
		select	@tiFlags =	@tiFlags & 0xFE									--		enforce unassignable

	if	@idDvcType & 9 > 0	or	@bActive = 0								-- Badge|Wi-Fi or inactive devices
		select	@sUnits =	null	--,	@sTeams =	null					-- enforce no Units or Teams
	else
	begin
		exec	dbo.prUnit_SetTmpFlt	@sUnits
--		exec	dbo.prTeam_SetTmpFlt	@sTeams
	end

	if	@idDvcType = 2	and	@tiFlags & 1 = 0								-- group Pagers
		exec	dbo.prTeam_SetTmpFlt	@sTeams
	else
		select	@sTeams =	null											-- enforce no Teams for everything else

	select	@s =	isnull(cast(@idDvc as varchar), '?') + '|' + cast(@idDvcType as varchar) + '|''' + @sDvc +
					''', b=' + isnull(cast(@sBarCode as varchar), '?') + ', #' + isnull(cast(@sDial as varchar), '?') +
					', f=' + cast(cast(@tiFlags as varbinary(2)) as varchar) + ', a=' + cast(@bActive as varchar) +
					' U=' + isnull(cast(@sUnits as varchar), '?') + ' T=' + isnull(cast(@sTeams as varchar), '?')
---	exec	dbo.pr_Log_Ins	1, @idUser, null, @s, @idModule

	select	@idOper =	idUser
		from	tbDvc	with (nolock)
		where	idDvc = @idDvc

	begin	tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  bActive )
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @bActive )
			select	@idDvc =	scope_identity( )

			select	@idLogType =	247,	@s =	'Dvc_I( ' + @s + ' ) =' + cast(@idDvc as varchar)

			if	@idDvcType = 8												--	Wi-Fi devices
				update	tbDvc	set	sBarCode =	cast(@idDvc as varchar)		--		enforce barcode to == DvcID
					where	idDvc = @idDvc
		end
		else
		begin
			select	@idLogType =	248,	@s =	'Dvc_U( ' + @s + ' )'

			if	@bActive = 0	or	@tiFlags & 1 = 0						--	7.06.8740	unassign inactive/deactivated
				select	@idOper =	null

			update	tbDvc	set	idDvcType=	@idDvcType,		sDvc =		@sDvc,		sDial=		@sDial,		sBarCode =	@sBarCode
							,	tiFlags =	@tiFlags,		idUser =	@idOper,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc
		end

		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		delete	from	tbDvcUnit
			where	idDvc = @idDvc
			and		idUnit	not in		(select idUnit from #tbUnit with (nolock))

		insert	tbDvcUnit	( idUnit, idDvc )
			select	idUnit, @idDvc
				from	#tbUnit	with (nolock)
				where	idUnit	not in	(select idUnit from tbDvcUnit with (nolock) where idDvc = @idDvc)

		delete	from	tbTeamDvc
			where	idDvc = @idDvc
			and		idTeam	not in		(select idTeam from #tbTeam with (nolock))

		insert	tbTeamDvc	( idTeam, idDvc )
			select	idTeam, @idDvc
				from	#tbTeam	with (nolock)
				where	idTeam	not in	(select idTeam from tbTeamDvc with (nolock) where idDvc = @idDvc)

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--				- @bGroup
--	7.06.8684	+ @sDvc
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.06.7531	* added Wi-Fi devices
--	7.06.7389	+ @idStfLvl
--	7.06.7270	* tbRtlsBadge -> vwRtlsBadge
--				+ @bStaff
--	7.06.7261	- .idRcvrLast (fkRtlsBadge_LastRcvr), .dtRcvrLast, .idRoom (fkRtlsBadge_Room)
--				* .idRcvrCurr -> .idReceiver (fkRtlsBadge_CurrRcvr -> fkRtlsBadge_Receiver), .dtRcvrCurr -> .dtReceiver
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.06.6282	* tbRtlsRoom -> tbRtlsBadge
--	7.06.5437	+ .dtDue
--	7.06.5336	* @idDvcType is bitwise now
--	7.05.5189	+ .idRoom, sQnRoom
--	7.05.5186	+ .tiFlags & 0x01 = 0
--	7.05.5184	+ .sTeams
--	7.05.5179	* 0xFF
--	7.05.5176
alter proc		dbo.prDvc_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@idDvcType	tinyint				-- 1=Badge, 2=Pager, 4=Phone, 0xFF=any
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes	active?
,	@tiFlags	tinyint		= null	-- null=any, 0=non-assignable, 1=assignable (for pagers 0==group/team), 2=auto (badges)
,	@bStaff		bit			= null	-- null=any, 0=no, 1=yes	assigned?
,	@idStfLvl	tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
,	@sDvc		varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive
		,	rb.idRoom, rb.sQnDvc
		,	d.idUser, d.idStfLvl, d.sStfID, d.sStaff, d.bOnDuty, d.dtDue
		from	vwDvc		d	with (nolock)
	left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge	= d.idDvc
--	left join	vwRoom		r	with (nolock)	on	r.idDevice	= rb.idRoom
		where	d.idDvcType & @idDvcType <> 0
--		and		(@idDvcType <> 1	or	d.tiFlags = 0x02)					--	.assignable
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@tiFlags is null	or	d.tiFlags & @tiFlags = @tiFlags)
		and		(@bStaff is null	or	@bStaff = 0	and	d.idUser is null	or	@bStaff = 1	and	d.idUser is not null )
		and		(@idStfLvl is null	or	d.idStfLvl = @idStfLvl	or	@idStfLvl = 0	and	d.idStfLvl is null)
		and		(@sDvc is null		or	d.sDial like @sDvc)					--	7.06.8684
		and		(@idUnit is null	or	d.idDvcType = 1		or	d.idDvcType = 8
									or	d.idDvc	in	(select idDvc from tbDvcUnit with (nolock) where idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge (used by RTLS demo)
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--	7.06.8434	* put RTLS auto-badges ON duty
--	7.06.8320	* no units for RTLS auto-badges
--	7.06.8276	+ @idStfLvl:	when > 0, a new [tb_User] is created with 0x7F + '.idBadge' as .sStaff
--	7.06.5424	* set tbDvc.sDial
--	7.05.5308	+ 'and	bActive = 0'
--	7.05.5222	+ updating tbDvc.bActive
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4968	* exec as owner
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4919	* tbStfDvcType -> tbDvcType, .idStfDvcType -> .idDvcType, .sStfDvcType -> .sDvcType
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.02	* inserting into tbStaffDvc (requires 'alter' permission)
--	7.00	* idBadge: smallint -> int
--	6.03
alter proc		dbo.prRtlsBadge_InsUpd
(
	@idBadge		int					-- id
,	@idStfLvl		tinyint				-- 4=Grn, 2=Ora, 1=Yel, 0=None
)
	with encryption, exec as owner
as
begin
	declare		@idUser	int
		,		@sUser	varchar( 32 )
		,		@sRtls	varchar( 16 )

---	set	nocount	on
	begin	tran

		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
		begin
			update	dbo.tbDvc		set	bActive =	1,	dtUpdated=	getdate( ),	sDial=	cast(@idBadge as varchar)
				where	idDvc = @idBadge	and	bActive = 0

			update	dbo.tbRtlsBadge	set	bActive =	1,	dtUpdated=	getdate( )
				where	idBadge = @idBadge	and	bActive = 0
		end
		else
		begin
			set identity_insert	dbo.tbDvc	on

			insert	dbo.tbDvc	( idDvc, idDvcType, sDial, sDvc )
					values		( @idBadge, 1, cast(@idBadge as varchar), 'Badge ' + right('00000000' + cast(@idBadge as varchar), 8) )

			set identity_insert	dbo.tbDvc	off

			insert	dbo.tbRtlsBadge	( idBadge )
					values		( @idBadge )
		end

		if	0 < @idStfLvl
		begin
			select	@sUser =	cast(@idBadge as varchar)					--	create a new [tb_User]
				,	@sRtls =	char(0x7F) + 'RTLS'							--	with 0x7F+'RTLS' as .sFrst

			if	not exists	(select 1 from tb_User with (nolock) where sUser = @sUser)
			begin
				exec	dbo.pr_User_InsUpd	2, @idUser out, @sUser, 0, 0, @sRtls, null, @sUser, null, null, @sUser, @idStfLvl, null, null, null, null, 1, 1
										--	iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc, sStfID, idLvl, sBarCode, sUnits, sTeams, sRoles, bOnDuty, bActive

				update	u	set	dtEntered=	getdate( ),	idRoom =	null	--	clear previously assigned user's location
					from	dbo.tb_User u
					join	dbo.tbDvc	d	on	d.idUser = u.idUser
					where	idDvc = @idBadge

				update	dbo.tbDvc	set tiFlags =	3,	idUser =	@idUser	--	mark this badge auto and assignable, and assign it to newly created user
					where	idDvc = @idBadge
			end
			else
			begin
				update	dbo.tbDvc	set	tiFlags =	3
					where	idDvc = @idBadge
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	clean-up inactive teams' membership and devices
begin tran
	delete	from	dbo.tbTeamUser
		where	idTeam in (select idTeam from tbTeam with (nolock) where bActive = 0)
	delete	from	dbo.tbTeamDvc
		where	idTeam in (select idTeam from tbTeam with (nolock) where bActive = 0)
commit
go
--	----------------------------------------------------------------------------
--	Returns badges (filtered)
--	7.06.8769	+ @bAuto for exclusion of auto-RTLS
--	7.06.8753	+ .tiFlags, bAssn
--	7.06.8306	* .tDuration -> sElapsed
--	7.06.8276	* output order
--	7.06.8137	* sFqStaff -> sQnStf
--	7.06.7292	* .tDuration	(cause time(0) swallows days)
--	7.06.6592	+ @bActive, reordered @rgs, optimized
--	7.06.5354	+ order by
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4959	+ .sFqStaff, @bStaff, @bRoom
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.03.4890
alter proc		dbo.prRtlsBadge_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bStaff		bit			= null	-- null=any, 0=not-assigned, 1=assigned
,	@bRoom		bit			= null	-- null=any, 0=not-in-room, 1=located
,	@bAuto		bit			= 0
)
	with encryption
as
begin
--	set	nocount	on
		select	bActive, dtCreated, dtUpdated
			,	idBadge, tiFlags, cast(tiFlags & 1 as bit)	as	bAssn
			,	sSGJ + ' [' + cDevice + '] ' + sDevice		as	sCurrLoc
			,	dtEntered	--,	cast( getdate( ) - dtEntered as time( 0 ) )	as	tDuration
			,	right('00' + cast(datediff(ss, dtEntered, getdate())/86400 as varchar), 3) + '.' + convert(char(8), getdate() - dtEntered, 114)	as	sElapsed
			,	idUser, sQnStf
			,	idRoom
			from	vwRtlsBadge		with (nolock)
			where	( @bActive is null	or	bActive = @bActive )
			and		( @bStaff is null	or	@bStaff = 0	and	idUser is null	or	@bStaff = 1	and	idUser is not null )
			and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
			and		( @bAuto != 0		or	tiFlags & 2 = 0 )		--	substring(sStaff, 1, 1) != char(0x7F) )
			order	by	idBadge
end
go
--	----------------------------------------------------------------------------
--	Returns all staff (indicating inactive) for 7981cw
--	7.06.8769	+ @bAuto for exclusion of auto-RTLS
--	7.06.8313	* s.sStfLvl -> s.cStfLvl
--	7.06.8284	* '(inactive)' -> '†'
--				- .iColorB
--	7.06.8137	* sFqStaff -> sQnStf
--	7.05.5161	* active -> all, + '(inactive)' indication
--	7.05.5064	+ .idDvcType = 1
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4953
alter proc		dbo.prStaff_LstAct
(
	@bAuto		bit			= 0
)
	with encryption
as
begin
	select	s.idUser, s.cStfLvl + ' ' + s.sQnStf +
				case	when bActive = 0	then ' †'	--	' -- (inactive)'
											else ''		end +
				case	when b.lCount > 1	then ' -- [' + cast(b.idDvc as varchar) + '], +' + cast(b.lCount-1 as varchar)
						when b.lCount = 1	then ' -- [' + cast(b.idDvc as varchar) + ']'
											else ''		end		as	sQnStf
	--	,	s.iColorB
		from	vwStaff	s	with (nolock)
		left outer join	(select	idUser, count(*) as lCount, min(idDvc) as idDvc
							from	tbDvc	with (nolock)
							where	idDvcType = 1							--	badge
							group by	idUser) b	on	b.idUser = s.idUser
		where	( @bAuto != 0		or	substring(sStaff, 1, 1) != char(0x7F) )
--		and		bActive > 0
		order	by	idStfLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	Updates a given notification device's assigned staff
--	7.06.8769	+ @tiFlags
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--	7.05.5010	* prStfDvc_UpdStf -> prDvc_UpdUsr
--				* idStfDvc -> idDvc, .idStaff -> .idUser, @idStaff -> @idUser
--	7.04.4897	* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.03
alter proc		dbo.prDvc_UpdUsr
(
	@idDvc		int							-- badge id
,	@tiFlags	tinyint
,	@idUser		int							-- who is this device is being assigned to?
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
			,	@idDvcType	tinyint
			,	@bActive	bit

	set	nocount	on

	select	@bActive =	0
	select	@bActive =	bActive
		from	tb_User	with (nolock)
		where	idUser = @idUser
		and		substring(sStaff, 1, 1) != char(0x7F)						-- excludes auto-RTLS badges/staff

	if	@bActive = 0		select	@idUser =	null						-- enforce no assignment for inactive staff

	select	@bActive =	bActive,	@idDvcType =	idDvcType
		from	tbDvc	with (nolock)
		where	idDvc = @idDvc

	if	@idDvcType > 2		select	@tiFlags =	@tiFlags | 0x01				-- enforce assignable for Phone, Wi-Fi

	if	@bActive = 0		select	@tiFlags =	@tiFlags & 0xFE				-- enforce unassignable for inactive

	begin	tran

		if	@tiFlags & 1 = 0
			update	tbDvc	set tiFlags =	@tiFlags,	idUser =	null,	dtUpdated=	getdate( )
				where	idDvc = @idDvc
		else
			update	tbDvc	set tiFlags =	@tiFlags,	idUser =	@idUser,	dtUpdated=	getdate( )
				where	idDvc = @idDvc
				and	(	@idUser is null		or	bActive > 0		and	@tiFlags & 1 > 0	)

	commit
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 8769 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8769, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2024-01-04',	sVersion =	'EMR integration: +7976is, +7976cw, *db798?, *798?rh, *7980cw, *7985cw, *7981cw'
		where	siBuild = 8769

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.8769'
		where	idModule = 1

	exec	dbo.prHealth_Stats

	declare		@s		varchar(255)

	select	@s =	'7.6.8769.00000, [' + db_name( ) + '], ' + sParams
		from	dbo.tb_Module
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, @s
commit
go

--	<100,tbEvent>
exec	sp_updatestats
go

checkpoint
go

checkpoint
go

use [master]
go