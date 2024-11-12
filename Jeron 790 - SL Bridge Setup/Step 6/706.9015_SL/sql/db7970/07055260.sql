--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
--		2014-May-20		.5253
--						+ prUnit_GetByUser
--		2014-May-21		.5254
--						* tb_Role[1,2].sDesc
--		2014-May-22		.5255
--						* tbUnit.idShift null -> not null
--		2014-May-27		.5260
--						* prCfgLoc_SetLvl
--		2014-Jul-16		.5310
--						* fix tbUnit.idShift not null enforcement - create missing shifts
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5260 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.05.5260', 18, 0 )

go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRole_SetTmpFlt')
	drop proc	dbo.prRole_SetTmpFlt
go
--	----------------------------------------------------------------------------
--	7.05.5255
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbUnit') and name = 'idShift' and is_nullable = 1)
begin
	begin tran
		--	7.06.5310	fix: create missing shifts before enforcing the reference
		declare		@idUnit		smallint
			,		@idShift	smallint
			,		@s			varchar( 255 )
			,		@sUnit		varchar( 16 )

		declare	cur		cursor fast_forward for
			select	idUnit
				from	tbUnit
				where	idShift is null

		open	cur
		fetch next from	cur	into	@idUnit
		while	@@fetch_status = 0
		begin
			insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )			--	default to single 24hr-shift
					values	( @idUnit, 1, 'Shift 1', '07:00:00', '07:00:00' )
			select	@idShift=	scope_identity( )

			update	tbUnit	set	idShift= @idShift
				where	idUnit = @idUnit

			fetch next from	cur	into	@idUnit
		end
		close	cur
		deallocate	cur

		--	now enforce the reference
		alter table		dbo.tbUnit	alter column
			idShift		smallint		not null	-- live: current shift look-up FK
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all active units, accessible by the given user (via his roles), ordered to be loadable into a tree
--	7.05.5253
--	7.05.5043
alter proc		dbo.prUnit_GetByUser
(
	@idUser		int
--,	@bActive	bit= null			-- null=any, 0=inactive, 1=active
--,	@sUnits		varchar( 255 )
)
	with encryption
as
begin
--	set	nocount	on
/*	select	u.idUnit, u.sUnit
		from	tbUnit u	with (nolock)
		inner join	tbCfgLoc l	with (nolock)	on	l.idLoc = u.idUnit
		inner join	tb_UserUnit uu	with (nolock)	on	uu.idUnit = u.idUnit	and	uu.idUser = @idUser
		where	u.bActive > 0
		order	by	u.sUnit
*/	if	@idUser is null		or	@idUser = 0
		select	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtUpdated
			from	tbUnit	u	with (nolock)
			join	tbShift	s	with (nolock)	on	s.idShift = u.idShift
			where	u.bActive > 0
			order	by	u.sUnit
	else
/*		select	distinct	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtUpdated
			from	tbUnit	u	with (nolock)
			join	tbShift	s	with (nolock)	on	s.idShift = u.idShift
			join	tb_RoleUnit	ru	with (nolock)	on	ru.idUnit = u.idUnit
			join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser
			where	u.bActive > 0
		--	where	(@bActive is null	or	u.bActive = @bActive)
			order	by	u.sUnit
*/		select	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtUpdated
			from	(select	distinct	idUnit
						from	tb_RoleUnit	ru	with (nolock)
						join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser)	ru
			join	tbUnit	u	with (nolock)	on	ru.idUnit = u.idUnit
			join	tbShift	s	with (nolock)	on	s.idShift = u.idShift
			where	u.bActive > 0
		--	where	(@bActive is null	or	u.bActive = @bActive)
			order	by	u.sUnit
end
go
--	----------------------------------------------------------------------------
--	7.05.5254
begin tran
	update	tb_Role		set	sDesc= 'Built-in role that automatically includes every user.  Access granted to this role is inherited by everybody.'
		where	idRole = 1
	update	tb_Role		set	sDesc= 'Built-in role whose members have complete and unrestricted access to all units and components'' features.'
		where	idRole = 2
commit
go
--	----------------------------------------------------------------------------
--	[Creates] #tbRole and fills it with given idRole-s
--	7.05.5254
create proc		dbo.prRole_SetTmpFlt
(
	@sRoles		varchar( 255 )		-- comma-separated idRole-s, '*'=all or null
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbRole						-- no enforcement of FKs
	(
		idRole		smallint		not null	-- role look-up FK
--	,	sRole		varchar( 16 )	not null	-- role name

		primary key nonclustered ( idRole )
	)
*/
	if	@sRoles = '*'	or	@sRoles is null
	begin
		insert	#tbRole
			select	idRole	--, sRole
				from	tb_Role	with (nolock)
				where	bActive > 0
	end
	else
	begin
		select	@s=
		'insert	#tbRole
			select	idRole	--, sRole
				from	tb_Role	with (nolock)
				where	bActive > 0
				and		idRole in (' + @sRoles + ')'
		exec( @s )
	end
--	select	*	from	#tbUnit
end
go
grant	execute				on dbo.prRole_SetTmpFlt				to [rWriter]
grant	execute				on dbo.prRole_SetTmpFlt				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
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
	@idUser		int					-- user, performing the action
,	@idOper		int out				-- operand user, acted upon
,	@sUser		varchar( 32 )
,	@iHash		int
,	@tiFails	tinyint
,	@sFrst		varchar( 16 )
,	@sMidd		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
--,	@dtLastAct	datetime			-- pr_User_UpdAct
,	@sStaffID	varchar( 16 )
,	@idStfLvl	tinyint
,	@sBarCode	varchar( 32 )
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
,	@sRoles		varchar( 255 )
,	@bOnDuty	bit
--,	@sStaff		varchar( 16 )		-- automatic
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

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

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", i="' + isnull(cast(@sStaffID as varchar), '?') + '", l=' + isnull(cast(@idStfLvl as varchar), '?') +
				', b="' + isnull(cast(@sBarCode as varchar), '?') + '", on=' + isnull(cast(@bOnDuty as varchar), '?') +
				', a=' + cast(@bActive as varchar)
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			select	@s= 'User_I( ' + @s + ' ) = '

			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff		--,  dtLastAct
							,  sStaffID,  idStfLvl,  sBarCode,  sUnits,  sTeams,  bOnDuty,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '		--, @dtLastAct, @sStaff
							, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @sTeams, @bOnDuty, @bActive )
			select	@idOper=	scope_identity( )

			select	@s= @s + cast(@idOper as varchar)
				,	@k=	237
		end
		else
		begin
			select	@s= 'User_U( ' + @s + ' )'

			update	tb_User	set	sUser= @sUser, iHash= @iHash, tiFails= @tiFails, sFrst= @sFrst
						,	sMidd= @sMidd, sLast= @sLast, sEmail= @sEmail, sDesc= @sDesc	--, dtLastAct= @dtLastAct, sStaff= @sStaff
						,	sStaffID= @sStaffID, idStfLvl= @idStfLvl, sBarCode= @sBarCode, sUnits= @sUnits, sTeams= @sTeams, bOnDuty= @bOnDuty
						,	bActive= @bActive, dtUpdated= getdate( )
				where	idUser = @idOper

			select	@k=	238
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s

		delete	from	tb_UserUnit
			where	idUser = @idOper
			and		idUnit not in (select	idUnit	from	#tbUnit	with (nolock))

		insert	tb_UserUnit	( idUnit, idUser )
			select	idUnit, @idOper
				from	#tbUnit	with (nolock)
				where	idUnit not in (select	idUnit	from	tb_UserUnit	with (nolock)	where	idUser = @idOper)

		delete	from	tbTeamUser
			where	idUser = @idOper
			and		idTeam not in (select	idTeam	from	#tbTeam	with (nolock))

		insert	tbTeamUser	( idTeam, idUser )
			select	idTeam, @idOper
				from	#tbTeam	with (nolock)
				where	idTeam not in (select	idTeam	from	tbTeamUser	with (nolock)	where	idUser = @idOper)

		delete	from	tb_UserRole
			where	idUser = @idOper
			and		idRole not in (select	idRole	from	#tbRole	with (nolock))

		insert	tb_UserRole	( idRole, idUser )
			select	idRole, @idOper
				from	#tbRole	with (nolock)
				where	idRole not in (select	idRole	from	tb_UserRole	with (nolock)	where	idUser = @idOper)

	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5255
begin
	begin tran
		--	force everyone to 'Public' membership
		insert	tb_UserRole		(idUser, idRole)
			select	idUser, 1	-- 'Public'
				from	tb_User
				where	idUser not in (select idUser from tb_UserRole where idRole = 1)
	commit
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
--	7.05.5260	* tbShift insertion (id=0)
--				+ tb_RoleUnit init
--	7.05.5087	* deactivate tbShift
--	7.04.4967	* - tbUnit.iStamp, tbShift.iStamp
--	7.04.4923	* populating tbShift
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.01	* 'MAP ?' -> 'Map ?'
--	7.00	- tbUnit.bActive
--	6.05	+ populating tbUnit, tbUnitMap, tbUnitMapCell
--			+ tracing, transaction
--	5.01	encryption added
--	2.02
alter proc		dbo.prCfgLoc_SetLvl
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'S'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'B'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'F'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'U'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'C'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		if	@iTrace & 0x01 > 0
		begin
			select	@s= 'Loc_SL( ) ' + cast(@iCount as varchar) + ' rows'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		--	deactivate non-matching units
		update	u	set	u.bActive= 0, u.dtUpdated= getdate( )
			from	tbUnit	u
			left join 	tbCfgLoc	l	on l.idLoc = u.idUnit
			where	u.bActive = 1	and	l.idLoc is null

		--	deactivate shifts for inactive units
		update	s	set	s.bActive= 0, s.dtUpdated= getdate( )
			from	tbShift	s
			join	tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0

		declare	cur		cursor fast_forward for
			select	idLoc, sLoc
				from	tbCfgLoc
				where	tiLvl = 4
				order	by	1

		open	cur
		fetch next from	cur	into	@idUnit, @sUnit
		while	@@fetch_status = 0
		begin
			--	upsert tbUnit to match tbCfgLoc
			if	exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
				update	tbUnit	set	bActive= 1, sUnit= @sUnit, dtUpdated= getdate( )
					where	idUnit = @idUnit
			else
			begin
				insert	tbUnit	(  idUnit,  sUnit, tiShifts, idShift )
						values	( @idUnit, @sUnit, 1, 0 )
				insert	tb_RoleUnit	( idRole, idUnit )
						values		( 2, @idUnit )
				insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )			--	default to single 24hr-shift
						values	( @idUnit, 1, 'Shift 1', '07:00:00', '07:00:00' )
				select	@idShift=	scope_identity( )

				update	tbUnit	set	idShift= @idShift
					where	idUnit = @idUnit

	--	-		insert	tbRouting	(  idShift,  siIdx,  tResp0,  tResp1,  tResp2,  tResp3 )
	--	-				values		(  )
			end

			--	populate tbUnitMap
			if	not	exists	(select 1 from tbUnitMap where idUnit = @idUnit)
			begin
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
			end

			--	populate tbUnitMapCell
			if	not	exists	(select 1 from tbUnitMapCell where idUnit = @idUnit)
			begin
				select	@tiMap= 0
				while	@tiMap < 4
				begin
					select	@tiCell= 0
					while	@tiCell < 48
					begin
						insert	tbUnitMapCell	( idUnit, tiMap, tiCell )	values	( @idUnit, @tiMap, @tiCell )

						select	@tiCell= @tiCell + 1
					end
					select	@tiMap= @tiMap + 1
				end
			end

			fetch next from	cur	into	@idUnit, @sUnit
		end
		close	cur
		deallocate	cur

	commit
end
go


if	not	exists	( select 1 from tb_Version where idVersion = 705 )
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 705,	0, getdate( ), getdate( ),	'_' )
go
update	tb_Version	set	dtCreated= '2014-05-27', siBuild= 5260, dtInstall= getdate( )
	,	sVersion= '7.05.5260 - schema refactored, 7980 tables replaced, 7980cw replaced'
	where	idVersion = 705
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.05.5260'
	where	idModule = 1
go

checkpoint
go

use [master]
go
