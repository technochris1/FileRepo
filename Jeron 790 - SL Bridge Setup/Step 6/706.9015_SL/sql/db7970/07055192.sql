--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
--		2014-Mar-04		.5176
--						+ tb_Module[64]
--						+ prTeam_GetByUnit, prDvc_GetByUnit
--						* prStfCvrg_InsFin
--		2014-Mar-07		.5179
--						+ prCfgPri_SetTmpFlt
--						* prUnit_SetTmpFlt
--						* tbTeam:	+ .sUnits, .sCalls	(prTeam_InsUpd, prTeam_GetByUnit, dbo.Team)
--		2014-Mar-10		.5182
--						* pr_User_InsUpd, prDvc_InsUpd:	@sUnits >> tb???Unit (via prUnit_SetTmpFlt)
--		2014-Mar-12		.5184
--						+ prTeam_SetTmpFlt
--						* tbDvc:	+ .sTeams	(vwDvc, prDvc_InsUpd, prDvc_GetByUnit)
--		2014-Mar-13		.5185
--						+ prStaff_GetPageable, prStaff_GetByStfID, prRoomBed_GetAssn
--						- dbo.sp_GetStaffList
--						* tbUnitMap:	.sMap not null -> null
--		2014-Mar-14		.5186
--						* prDevice_GetIns
--						* prDvc_GetByUnit
--						* prDvc_InsUpd
--		2014-Mar-17		.5189
--						* prDvc_GetByUnit
--		2014-Mar-18		.5190
--						* pr_User_InsUpd
--		2014-Mar-19		.5191
--						* prTeam_GetByUnit
--						* prTeam_InsUpd
--		2014-Mar-20		.5192
--						* prRtlsBadge_RstLoc, prRtlsRoom_OffOne, vwRtlsRoom, prRtlsRoom_Get
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5192 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.05.5192', 18, 0 )

go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_GetStaffList')
	drop proc	dbo.sp_GetStaffList

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_GetAssn')
	drop proc	dbo.prRoomBed_GetAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetOne')
	drop proc	dbo.prStaff_GetOne
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByStfID')
	drop proc	dbo.prStaff_GetByStfID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetPageable')
	drop proc	dbo.prStaff_GetPageable
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByUnit')
	drop proc	dbo.prDvc_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetByUnit')
	drop proc	dbo.prTeam_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByUnit')
	drop proc	dbo.pr_User_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_SetTmpFlt')
	drop proc	dbo.prTeam_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_SetTmpFlt')
	drop proc	dbo.prCfgPri_SetTmpFlt
go

--	----------------------------------------------------------------------------
--	move unit-ids from .sBarCode to .sUnits
/*
begin tran
	update	dbo.tb_User		set	sUnits=	sBarCode
	update	dbo.tb_User		set	sBarCode= null
	update	dbo.tbDvc		set	sUnits=	sBarCode
	update	dbo.tbDvc		set	sBarCode= null
commit
*/
go
--	----------------------------------------------------------------------------
--	7.05.5176	+ [64]
begin tran
	if	not	exists	(select 1 from dbo.tb_Module where idModule = 64)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  64, 'J7982cw', 24, 0, '7982 Staff Sign-On' )

	update	dbo.tb_Module	set	sDesc=	'7982 Staff Sign-On'	where	idModule = 64
commit
go
--	----------------------------------------------------------------------------
--	[Creates] #tbCall and fills it with given siIdx-s
--	7.05.5179
create proc		dbo.prCfgPri_SetTmpFlt
(
	@sCalls		varchar( 255 )		-- comma-separated siIdx-s, '*'=all or null
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbCall						-- no enforcement of FKs
	(
		siIdx		smallint		not null	-- priority-index
--	,	sCall		varchar( 16 )	not null	-- priority-text

		primary key nonclustered ( siIdx )
	)
*/
	if	@sCalls is null
		return	0

	if	@sCalls = '*'		--	or	@sCalls is null
	begin
		insert	#tbCall
			select	siIdx	--, sCall
				from	tbCfgPri	with (nolock)
				where	tiFlags & 0x02 > 0		--	enabled only
	end
	else
	begin
		select	@s=
		'insert	#tbCall
			select	siIdx	--, sCall
				from	tbCfgPri	with (nolock)
				where	tiFlags & 0x02 > 0		--	enabled only
				and		siIdx in (' + @sCalls + ')'
		exec( @s )
	end
--	select	*	from	#tbCall
end
go
grant	execute				on dbo.prCfgPri_SetTmpFlt			to [rWriter]
grant	execute				on dbo.prCfgPri_SetTmpFlt			to [rReader]
go
--	----------------------------------------------------------------------------
--	[Creates] #tbUnit and fills it with given idUnit-s
--	7.05.5179
--	7.05.5154
alter proc		dbo.prUnit_SetTmpFlt
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit-s, '*' or null=all
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)
*/
	if	@sUnits is null
		return	0

	if	@sUnits = '*'		--	or	@sUnits is null
	begin
		insert	#tbUnit
			select	idUnit, sUnit	--, idShift
				from	tbUnit	with (nolock)
				where	bActive > 0		and		idShift > 0
	end
	else
	begin
		select	@s=
		'insert	#tbUnit
			select	idUnit, sUnit	--, idShift
				from	tbUnit	with (nolock)
				where	bActive > 0		and		idShift > 0
				and		idUnit in (' + @sUnits + ')'
		exec( @s )
	end
--	select	*	from	#tbUnit
end
go
--	----------------------------------------------------------------------------
--	7.05.5179	+ .sUnits, .sCalls
--				* .sDesc -> null
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbTeam') and name = 'sUnits')
begin
	begin tran
		alter table		dbo.tbTeam		add
			sCalls		varchar( 255 )	null		-- tmp: calls
		,	sUnits		varchar( 255 )	null		-- tmp: units
		alter table		dbo.tbTeam		alter column
			sDesc		varchar( 255 )	null		-- description
		exec( 'update	dbo.tbTeam	set	sUnits= sDesc
				update	dbo.tbTeam	set	sDesc= null
				update	t	set	t.sCalls= cast(p.siIdx as varchar)
					from	dbo.tbTeam	t
					join	dbo.tbTeamPri	p	on	p.idTeam = t.idTeam'
			)
	commit
end
go
alter view		dbo.Team
	with encryption
as
select	sTeam		[Name]
	,	p.siIdx
	,	c.sCall		[CallPriority]
	,	0			[CallPriorityMode]
	,	''			[GroupID]
	,	tResp
	,	substring( convert( varchar(8), tResp, 8 ), 4, 5 )	[Timer]
	,	sUnits		[Units]
	,	t.idTeam	[ID]
	,	t.bActive	[Active]
	from	dbo.tbTeam	t	with (nolock)
	left join	dbo.tbTeamPri	p	with (nolock)	on	p.idTeam = t.idTeam
	left join	dbo.tbCall		c	with (nolock)	on	c.siIdx = p.siIdx	and	c.bActive > 0
go
--	----------------------------------------------------------------------------
--	[Creates] #tbTeam and fills it with given idTeam-s
--	7.05.5184
create proc		dbo.prTeam_SetTmpFlt
(
	@sTeams		varchar( 255 )		-- comma-separated idTeam-s, '*'=all or null
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbTeam						-- no enforcement of FKs
	(
		idTeam		smallint		not null	-- team id
--	,	sTeam		varchar( 16 )	not null	-- team name

		primary key nonclustered ( idTeam )
	)
*/
	if	@sTeams is null
		return	0

	if	@sTeams = '*'		--	or	@sTeams is null
	begin
		insert	#tbTeam
			select	idTeam	--, sTeam
				from	tbTeam	with (nolock)
				where	bActive > 0		--	enabled only
	end
	else
	begin
		select	@s=
		'insert	#tbTeam
			select	idTeam	--, sTeam
				from	tbTeam	with (nolock)
				where	bActive > 0		--	enabled only
				and		idTeam in (' + @sTeams + ')'
		exec( @s )
	end
--	select	*	from	#tbCall
end
go
grant	execute				on dbo.prTeam_SetTmpFlt				to [rWriter]
grant	execute				on dbo.prTeam_SetTmpFlt				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
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

	exec	dbo.prUnit_SetTmpFlt	@sUnits

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
							,  sStaffID,  idStfLvl,  sBarCode,  sUnits,  bOnDuty,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '		--, @dtLastAct, @sStaff
							, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @bOnDuty, @bActive )
			select	@idOper=	scope_identity( )

			select	@s= @s + cast(@idOper as varchar)
				,	@k=	237
		end
		else
		begin
			select	@s= 'User_U( ' + @s + ' )'

			update	tb_User	set	sUser= @sUser, iHash= @iHash, tiFails= @tiFails, sFrst= @sFrst
						,	sMidd= @sMidd, sLast= @sLast, sEmail= @sEmail, sDesc= @sDesc	--, dtLastAct= @dtLastAct, sStaff= @sStaff
						,	sStaffID= @sStaffID, idStfLvl= @idStfLvl, sBarCode= @sBarCode, sUnits= @sUnits, bOnDuty= @bOnDuty
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
				where	idUnit not in (select	idUnit	from	tb_UserUnit	where	idUser = @idOper)

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a team
--	7.05.5191	* fix tbTeamUnit insertion
--	7.05.5182	+ @sCalls, @sUnits
--	7.05.5021
alter proc		dbo.prTeam_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idTeam		smallint out		-- team, acted upon
,	@sTeam		varchar( 16 )
,	@tResp		time( 0 )
,	@sDesc		varchar( 255 )
,	@sCalls		varchar( 255 )
,	@sUnits		varchar( 255 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on
	set	xact_abort	on

	create table	#tbCall						-- no enforcement of FKs
	(
		siIdx		smallint		not null	-- priority-index
--	,	sCall		varchar( 16 )	not null	-- priority-text

		primary key nonclustered ( siIdx )
	)
	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prCfgPri_SetTmpFlt	@sCalls
	exec	dbo.prUnit_SetTmpFlt	@sUnits

	select	@s= '[' + isnull(cast(@idTeam as varchar), '?') + '], n="' + @sTeam + '", d=' + isnull(cast(@sDesc as varchar), '?') +
				', t=' + convert(varchar, @tResp, 108) +
				', a=' + cast(@bActive as varchar)		-- + ' ' + convert(varchar, @dtCreated, 20) + ' ' + convert(varchar, @dtUpdated, 20)
	begin	tran

		if	not exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			select	@s= 'Team_I( ' + @s + ' ) = '

			insert	tbTeam	(  sTeam,  sDesc,  tResp,  sCalls,  sUnits,  bActive )
					values	( @sTeam, @sDesc, @tResp, @sCalls, @sUnits, @bActive )
			select	@idTeam=	scope_identity( )

			select	@s= @s + cast(@idTeam as varchar)
				,	@k=	247
		end
		else
		begin
			select	@s= 'Team_U( ' + @s + ' )'

			update	tbTeam	set	sTeam= @sTeam, sDesc= @sDesc, tResp= @tResp, sCalls= @sCalls, sUnits= @sUnits, bActive= @bActive, dtUpdated= getdate( )
				where	idTeam = @idTeam

			select	@k=	248
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

		delete	from	tbTeamPri
			where	idTeam = @idTeam
			and		siIdx not in (select	siIdx	from	#tbCall	with (nolock))

		insert	tbTeamPri	( siIdx, idTeam )
			select	siIdx, @idTeam
				from	#tbCall	with (nolock)
				where	siIdx not in (select	siIdx	from	tbTeamPri	where	idTeam = @idTeam)

		delete	from	tbTeamUnit
			where	idTeam = @idTeam
			and		idUnit not in (select	idUnit	from	#tbUnit	with (nolock))

		insert	tbTeamUnit	( idUnit, idTeam )
			select	idUnit, @idTeam
				from	#tbUnit	with (nolock)
				where	idUnit not in (select	idUnit	from	tbTeamUnit	where	idTeam = @idTeam)

	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5184	+ .sTeams
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDvc') and name = 'sTeams')
begin
	begin tran
		alter table		dbo.tbDvc		add
			sTeams		varchar( 255 )	null		-- tmp: teams
	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5184	+ .sTeams
--	7.05.5154	+ staff fields
--	7.05.5121	+ .sUnits
--	7.05.5095
alter view		dbo.vwDvc
	with encryption
as
select	d.idDvc, d.idDvcType, t.sDvcType, d.sDial, d.sDvc, d.sBarCode, d.tiFlags, d.sUnits, d.sTeams
	,	t.sDvcType + ' #' + d.sDial		[sFqDvc]
	,	d.idUser, u.idStfLvl, u.sStfLvl, u.sStaffID, u.sStaff, u.sFqStaff, u.bOnDuty
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDvc		d	with (nolock)
	join	tbDvcType	t	with (nolock)	on	t.idDvcType = d.idDvcType
	left join	vwStaff	u	with (nolock)	on	u.idUser = d.idUser
go
--	----------------------------------------------------------------------------
--	Inserts or updates a device
--	7.05.5186	* fix tbDvcUnit insertion
--	7.05.5184	+ .sTeams
--	7.05.5182	+ @sUnits >> tbDvcUnit (via prUnit_SetTmpFlt)
--	7.05.5121	+ .sUnits
--	7.05.5021
alter proc		dbo.prDvc_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idDvc		int out				-- device, acted upon
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sBarCode	varchar( 32 )
,	@sDial		varchar( 16 )
,	@tiFlags	tinyint
--,	@idUser		int					-- prDvc_UpdUsr
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
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

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams

	select	@s= '[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', n="' + @sDvc + '", b=' + isnull(cast(@sBarCode as varchar), '?') +
				', d=' + isnull(cast(@sDial as varchar), '?') + ', f=' + cast(@tiFlags as varchar) +
				', a=' + cast(@bActive as varchar)
	begin	tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			select	@s= 'Dvc_I( ' + @s + ' ) = '

			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  sUnits,  sTeams,  bActive )
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @sTeams, @bActive )
			select	@idDvc=		scope_identity( )

			select	@s= @s + cast(@idDvc as varchar)
				,	@k=	247
		end
		else
		begin
			select	@s= 'Dvc_U( ' + @s + ' )'

			update	tbDvc	set	idDvcType= @idDvcType, sDvc= @sDvc, sBarCode= @sBarCode, sDial= @sDial
						,	tiFlags= @tiFlags, sUnits= @sUnits, sTeams= @sTeams, bActive= @bActive, dtUpdated= getdate( )
				where	idDvc = @idDvc

			select	@k=	248
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

		delete	from	tbDvcUnit
			where	idDvc = @idDvc
			and		idUnit not in (select	idUnit	from	#tbUnit	with (nolock))

		insert	tbDvcUnit	( idUnit, idDvc )
			select	idUnit, @idDvc
				from	#tbUnit	with (nolock)
				where	idUnit not in (select	idUnit	from	tbDvcUnit	where	idDvc = @idDvc)

		delete	from	tbDvcTeam
			where	idDvc = @idDvc
			and		idTeam not in (select	idTeam	from	#tbTeam	with (nolock))

		insert	tbDvcTeam	( idTeam, idDvc )
			select	idTeam, @idDvc
				from	#tbTeam	with (nolock)
				where	idTeam not in (select	idTeam	from	tbDvcTeam	where	idDvc = @idDvc)

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns security details for all users
--	7.05.5182
create proc		dbo.pr_User_GetByUnit
(
--	@sUnits		varchar( 255 )		-- comma-separated idUnit's, '*'=all or null
	@idUnit		smallint			-- null=any?
,	@idStfLvl	tinyint		= null	-- null=any, 1=Yel, 2=Ora, 4=Grn
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUser		int			= null	-- null=any
,	@sStaffID	varchar( 16 )= null	-- null=any
)
	with encryption
as
begin
/*	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits
*/
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStaffID, idStfLvl, sBarCode, bOnDuty, dtDue, sStaff, sUnits, sTeams, bActive, dtCreated, dtUpdated
--	select	u.idUser, u.sUser, cast(case when u.tiFails=0xFF then 1 else 0 end as bit) [bLocked]
--		,	u.tiFails, u.sFrst, u.sMidd, u.sLast, u.dtLastAct, u.sStaffID, u.idStfLvl, l.sStfLvl
--		,	u.sBarCode, u.bOnDuty, u.sStaff, u.bActive, u.dtCreated, u.dtUpdated
		from	tb_User		u	with (nolock)
--		join	tbStfLvl	l	with (nolock)	on	l.idStfLvl = u.idStfLvl
		where	(@bActive is null	or	u.bActive = @bActive)
		and		(@idStfLvl is null	or	u.idStfLvl = @idStfLvl)
		and		(@idUser is null	or	u.idUser = @idUser)
		and		(@sStaffID is null	or	u.sStaffID = @sStaffID)
/*		and		u.idUser in (select	idUser
			from	tb_UserUnit	uu	with (nolock)
			join	#tbUnit		u	with (nolock)	on	u.idUnit = uu.idUnit)
*/
		and		idUser > 15			--	protect internal accounts
end
go
grant	execute				on dbo.pr_User_GetByUnit			to [rWriter]
grant	execute				on dbo.pr_User_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns teams filtered by unit (and active status)
--	7.05.5191	* by unit
--	7.05.5179	+ .sUnits, .sCalls
--	7.05.5175
create proc		dbo.prTeam_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
)
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, sDesc, sCalls, sUnits, bActive, dtCreated, dtUpdated
		from	tbTeam	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idUnit is null	or	idTeam in (select idTeam	from	tbTeamUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	sTeam
end
go
grant	execute				on dbo.prTeam_GetByUnit				to [rWriter]
grant	execute				on dbo.prTeam_GetByUnit				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
--	7.05.5189	+ .idRoom, sQnRoom
--	7.05.5186	+ .tiFlags & 0x01 = 0
--	7.05.5184	+ .sTeams
--	7.05.5179	* 0xFF
--	7.05.5176
create proc		dbo.prDvc_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@idDvcType	tinyint				-- null=any, 1=Badge, 2=Pager, 3=Phone, 0xFF=NoBadges
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
,	@bGroup		bit			= null	-- null=any, 0=no, 1=yes
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, d.sDial, tiFlags, sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rr.idRoom, r.sQnDevice	[sQnRoom]
		,	idUser, d.idStfLvl, sStaffID, sStaff,	bOnDuty
		from		vwDvc		d	with (nolock)
		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rr.idRoom
		where	(@idDvcType is null	or	idDvcType = @idDvcType
			or	 @idDvcType = 0xFF  and	idDvcType > 1)
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bGroup is null	or	tiFlags & 0x01 = @bGroup)
	--	and		tiFlags & 0x01 = 0		--	no group devices
		and		(@idUnit is null	or	idDvcType = 1	or	idDvc in (select idDvc	from	tbDvcUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
grant	execute				on dbo.prDvc_GetByUnit				to [rWriter]
grant	execute				on dbo.prDvc_GetByUnit				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.05.5185	* .sMap not null -> null
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbUnitMap') and name = 'sMap' and is_nullable = 0)
begin
	begin tran
		alter table		dbo.tbUnitMap	alter column
			sMap		varchar( 16 )	null		-- map name
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
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
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set	idAssn2=	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
											and	sa.idShift = u.idShift	and	sa.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set	idAssn3=	sa.idUser
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
--	Returns on-duty pageable staff for given unit(s)
--	7.05.5185
create proc		dbo.prStaff_GetPageable
(
	@idUnit		smallint			-- null=any
,	@idStfLvl	tinyint				-- null=any, 1=Yel, 2=Ora, 4=Grn
)
	with encryption
as
begin
--	set	nocount	on
	select	st.idUser, sStaffID, sStaff
		from	tb_User	st	with (nolock)
		join	tbDvc	pg	with (nolock)	on	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
		where	st.bActive > 0		and	st.bOnDuty > 0
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@idUnit is null	or	st.idUser in (select	idUser	from	tb_UserUnit with (nolock)	where	idUnit = @idUnit))
		order	by	sStaff
end
go
grant	execute				on dbo.prStaff_GetPageable			to [rWriter]
--grant	execute				on dbo.prStaff_GetPageable			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff details for given staff-id
--	7.05.5185
create proc		dbo.prStaff_GetByStfID
(
	@sStaffID	varchar( 16 )
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaff
		from	tb_User		with (nolock)
		where	sStaffID = @sStaffID
end
go
grant	execute				on dbo.prStaff_GetByStfID			to [rWriter]
--grant	execute				on dbo.prStaff_GetByStfID			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns assigned staff for given room-bed
--	7.05.5185
create proc		dbo.prRoomBed_GetAssn
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiRID		tinyint				-- R-ID - R-bus
,	@sDevice	varchar( 16 )		-- device name
,	@tiBed		tinyint				-- bed index (0-9, 255)
--,	@idUnit		smallint	= null	-- active unit ID
)
	with encryption
as
begin
	declare		@idRoom		int

	set	nocount	on

	select	@tiRID=	0		--	force 0 - looking for a room

	exec	dbo.prDevice_GetIns		@cSys, @tiGID, @tiJID, @tiRID, null, null, null, @sDevice, null, @idRoom out

	set	nocount	off

	select	idAssn1, idStLvl1, sAssn1
		,	idAssn2, idStLvl2, sAssn2
		,	idAssn3, idStLvl3, sAssn3
		from	vwRoomBed	with (nolock)
		where	idRoom = @idRoom	and	tiBed = @tiBed
end
go
grant	execute				on dbo.prRoomBed_GetAssn			to [rWriter]
--grant	execute				on dbo.prRoomBed_GetAssn			to [rReader]
go
--	----------------------------------------------------------------------------
--	Finds devices and inserts if necessary (not found)
--	7.05.5186	* added isnull( ,'?') to @cSys, check for @cSys is not null
--	7.05.5141	* added isnull( ,'?') to @cDevice, @sDevice
--	7.04.4972	* revert to using @tiRID, but use RID==0 for 'M'
--	7.04.4969	* resolve to RID==0 level (rooms, masters, etc.), not individual stations
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	* 7967-P detection and handling
--	6.07	- device matching by name
--	6.05	tracing reclassified 42 -> 74
--			+ (nolock)
--	6.04	* replaces 7967-P workflow station's (0x1A) 'phantom' RIDs with parent device - workflow itself
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			* use isnull(..,'?') for @iAID, @tiStype args
--	6.02	* .tiRID is never NULL now - added download of all stations
--			+ @cSys (+ tbDevice.cSys), order of @rgs (prEvent_Ins)
--	6.00	tbDefDevice -> tbDevice (FKs)
--	5.01	encryption added
--			+ @iAID, @tiStype
--	3.01
--	2.03	(prEvent*_Ins, 84, 8A, A7)
--			+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
alter proc		dbo.prDevice_GetIns
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiRID		tinyint				-- R-ID - R-bus
,	@iAID		int					-- device A-ID (32 bits)
,	@tiStype	tinyint				-- device type (1-255)
,	@cDevice	char( 1 )			-- device type: G=gateway, R=room, M=master
,	@sDevice	varchar( 16 )		-- device name
,	@sDial		varchar( 16 )		-- dialable number (digits only)

,	@idDevice	smallint out		-- output
)
	with	encryption
as
begin
	declare		@idParent	smallint
		,		@iTrace		int
		,		@s			varchar( 255 )
		,		@bActive	bit

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s=	'Dvc_I( s=' + isnull(@cSys,'?') + ', g=' + cast(@tiGID as varchar) + ', j=' + cast(@tiJID as varchar) + ', r=' + cast(@tiRID as varchar) +
				', aid=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') + ', c=' + isnull(@cDevice,'?') +
				', n=' + isnull(@sDevice,'?') + ', d=' + isnull(@sDial,'?') + ' )'

	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7967-P workflow station's (0x1A) 'phantom' RIDs		--	7.03
	begin
		select	@sDial=		null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype=	26			---	?? mark 'phantom' RID as workflow
		select	@idDevice=	idDevice, @bActive=	bActive
			from	tbDevice	with (nolock)
			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	--and	bActive > 0
		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice
			return	0
		end
	end

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID = 0
		select	@iAID=	null
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.04.4969
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	cDevice = 'M'	and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID > 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	bActive > 0
/*
---	if	@idDevice is null	and	len(@sDevice) > 0	and	len(@sDial) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	and	sDial = @sDial	and	bActive > 0
---	if	@idDevice is null	and	len(@sDevice) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	and	bActive > 0

--	if	len( @sDevice ) > 0
--		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice
--	if	@idDevice is null	and	@tiGID > 0	and	@tiJID > 0	and	@tiRID = 0
--		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0
--	if	@idDevice is null	and	@tiGID > 0	and	@tiJID > 0	and	@tiRID > 0
--		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID
--	if	@idDevice is null	and	len( @sDial ) > 0
--		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDial = @sDial

--	if	@idDevice > 0	and	@tiStype = 26	and	@tiRID > 0		--	replace 7967-P workflow station's (0x1A) 'phantom' RIDs		--	6.04
--	begin
--		select	@idDevice=	idParent	from	tbDevice	with (nolock)	where	idDevice = @idDevice
--		return	0
--	end
*/

	if	@idDevice is null	and	len( @sDevice ) > 0		and	@cSys is not null					--	7.05.5186
	begin
		if	@tiRID > 0						-- R-bus device
			select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
		if	@tiJID > 0	and	@tiRID = 0		-- J-bus device
			select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	bActive > 0

		begin	tran

			insert	tbDevice	(  idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial )
			select	@idDevice=	scope_identity( )

			if	@iTrace & 0x04 > 0
			begin
				select	@s=	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
				exec	pr_Log_Ins	74, null, null, @s
			end

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Clears notification attribute for a given room
--	7.05.5192	+	and bNotify=1
--	6.03
alter proc		dbo.prRtlsRoom_OffOne
(
	@idRoom			smallint			-- 790 device look-up FK
)
	with encryption
as
begin
---	set	nocount	on
	begin	tran

		update	tbRtlsRoom	set	dtUpdated= getdate( ), bNotify= 0
			where	idRoom = @idRoom	and	bNotify = 1

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets location attributes for all badges
--	7.05.5192	+ tbRoom
--	7.05.5099	+ tb_User.idRoom
--	7.03.4898	* prBadge_ClrAll -> prRtlsBadge_RstLoc
--	6.03
alter proc		dbo.prRtlsBadge_RstLoc
	with encryption
as
begin
	set	nocount	on

	begin	tran

		update	tbRtlsRoom	set dtUpdated= getdate( ), idBadge= null, bNotify= 1
		update	tbRtlsBadge	set dtEntered= getdate( ), idRoom= null, idRcvrCurr= null	--, dtUpdated= getdate( )
		update	tb_User		set	dtEntered= getdate( ), idRoom= null
		update	tbRoom		set	dtUpdated= getdate( ), idRn= null, sRn= null,	idCn= null, sCn= null,	idAi= null, sAi= null

	commit
end
go
--	----------------------------------------------------------------------------
--	Rooms 'presense' state (oldest badges)
--	7.05.5192	* joins
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--				* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.02	- tbRtlsBadge.idStaff (no need now, tbStaffDvc.idStaff keeps relationship)
--	7.00	.tiPtype -> .idStaffLvl
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.04	+ .idRn, .idCna, .idAide	min vs. max?
--	6.03
alter view		dbo.vwRtlsRoom
	with encryption
as
select	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	min(case when r.idStfLvl=4 then sd.idUser	else null end)	[idRn]
	,	min(case when r.idStfLvl=4 then s.sStaff	else null end)	[sRn]
	,	min(case when r.idStfLvl=2 then sd.idUser	else null end)	[idCn]
	,	min(case when r.idStfLvl=2 then s.sStaff	else null end)	[sCn]
	,	min(case when r.idStfLvl=1 then sd.idUser	else null end)	[idAi]
	,	min(case when r.idStfLvl=1 then s.sStaff	else null end)	[sAi]
	,	max(cast(r.bNotify as tinyint))								[tiNotify]
	,	min(r.dtUpdated)											[dtUpdated]
	from	tbRtlsRoom		r	with (nolock)
	join	tbDevice		d	with (nolock)	on	d.idDevice = r.idRoom
	left join	tbRtlsBadge	b	with (nolock)	on	b.idBadge = r.idBadge
	left join	tbDvc		sd	with (nolock)	on	sd.idDvc = b.idBadge
	left join	vwStaff		s	with (nolock)	on	s.idUser = sd.idUser
	group by	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
go
--	----------------------------------------------------------------------------
--	7981 - Returns rooms for updating RTLS state
--	7.05.5192	* include empty names into output
--	6.05
alter proc		dbo.prRtlsRoom_Get
(
	@siAge			smallint = 0		-- age in seconds
)
	with encryption
as
begin
--	set	nocount	on
	select	idRoom, cSys, tiGID, tiJID, tiRID, sRn, sCn, sAi
		from	vwRtlsRoom	with (nolock)
		where	@siAge > 0  and  datediff(ss, dtUpdated, getdate( )) > @siAge	--	and	(sRn is not null  or  sCn is not null  or  sAi is not null)
			or	tiNotify > 0
end
go


if	not	exists	( select 1 from tb_Version where idVersion = 705 )
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 705,	5192, getdate( ), getdate( ),	'_' )
go
update	tb_Version	set	dtCreated= '2014-03-20', siBuild= 5192, dtInstall= getdate( )
	,	sVersion= '7.05.5192 - schema refactored, 7980 tables replaced'
	where	idVersion = 705
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.05.5192'
	where	idModule = 1
go

checkpoint
go

use [master]
go
