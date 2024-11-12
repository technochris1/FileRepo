--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2020-Mar-04		.7368
--						* tbTeam	+ .bEmail	(prTeam_Exp, prTeam_Imp, prTeam_GetByUnit, prTeam_GetByUnitPri, prTeam_InsUpd)
--		2020-Mar-09		.7373
--						+ prTeam_GetEmails
--		2020-Mar-13		.7377
--						* pr_AccUnit_Set
--		2020-Mar-16		.7380
--						* prCall_Imp
--		2020-Mar-24		.7388
--						* pr_User_Login, pr_User_Login2, pr_User_Logout
--		2020-Mar-25		.7389
--						* prDvc_GetByUnit
--		2020-Mar-26		.7390
--						+ pr_OptUsr_GetAll
--						* pr_OptSys_Upd, pr_OptUsr_Upd
--		2020-Apr-15		.7410
--						* prDevice_GetIns
--		2020-Apr-17		.7412
--						* prEvent_Ins
--		2020-Apr-22		.7417
--						* prEvent84_Ins
--		2020-Apr-27		.7422
--						* prEvent84_Ins, prTeam_GetByUnitPri
--		2020-May-07		.7432
--						* tb_LogType[83].tiCat
--						* pr_AccUnit_Set
--		2020-May-08		.7433
--						* pr_User_InsUpd, pr_User_InsUpdAD
--		2020-May-22		.7447
--						* prEvent84_Ins
--						* pr_Role_InsUpd
--		2020-May-27		.7452
--						* prStfAssn_Imp
--						* prShift_Imp
--		2020-May-29		.7454
--						* prPatient_GetIns
--		2020-Jun-02		.7458
--						* prStfAssn_Exp
--		2020-Jun-04		.7460
--						* prShift_Imp, prStfAssn_Imp, prStfAssn_Exp
--		2020-Jun-05		.7461
--						* prCfgLoc_SetLvl
--		2020-Jun-08		.7464
--						* prEvent84_Ins
--		2020-Jun-09		.7465
--						* prStfAssn_InsUpdDel, prShift_InsUpd
--		2020-Jun-11		.7467
--						* prEvent_Maint
--						* pr_Module_Reg, pr_Module_Lic
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7467 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7467', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptUsr_GetAll')
	drop proc	dbo.pr_OptUsr_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetEmails')
	drop proc	dbo.prTeam_GetEmails
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
--	7.06.7467	* optimized logic
--	7.06.7279	* optimized logging
--	7.06.7118	* optimized logging (removal)
--	7.06.6345	+ @idModule logging (pr_Log_Ins call)
--	7.06.5617	* fix un-register condition
--	7.06.5595	* optimized logic (blanking upon un-registration), re-ordered args
--	7.00	+ @tiModType
--			pr_Module_Set -> pr_Module_Reg
--			* tb_Module.bService -> .bLicense
--	6.05
alter proc		dbo.pr_Module_Reg
(
	@idModule	tinyint
,	@tiModType	tinyint
,	@sModule	varchar( 16 )
,	@bLicense	bit
,	@sVersion	varchar( 16 )
,	@sIpAddr	varchar( 40 )
,	@sMachine	varchar( 32 )
,	@sDesc		varchar( 64 )
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
			,	@idLogType	tinyint

	set	nocount	on

	select	@s =	'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', ' + isnull(@sVersion, '?')
--					', ip=' + isnull(@sIpAddr, '?') + ', m=' + isnull(@sMachine, '?') + ', ''' + isnull(@sDesc, '?') + ''', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'
		,	@idLogType =	62

	if	@sMachine is not null												-- register
		select	@s =	@s + ', ip=' + isnull(@sIpAddr, '?') + ', m=' + isnull(@sMachine, '?') + ', ''' + isnull(@sDesc, '?') + ''', l=' + isnull(cast(@bLicense as varchar), '?')
			,	@idLogType =	61

	select	@s =	@s + ' )'

	begin	tran

		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule)
		begin
			if	@sMachine is null	--	and	@sIpAddr is null				-- un-register
--			begin
				update	tb_Module	set		sIpAddr =	null,		sMachine =	null,		sVersion =	null
										,	dtStart =	null,		sParams =	null
					where	idModule = @idModule

--				select	@s =	'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', ' + isnull(@sVersion, '?') + ' )'
--					,	@idLogType =	62
--			end
			else
				update	tb_Module	set		sIpAddr =	@sIpAddr,	sMachine =	@sMachine,	sVersion =	@sVersion
										,	sDesc =		@sDesc,		bLicense =	@bLicense
					where	idModule = @idModule
		end
		else
		begin
			insert	tb_Module	(  idModule,  tiModType,  sModule,  sDesc,  bLicense,  sVersion,  sIpAddr,  sMachine )
					values		( @idModule, @tiModType, @sModule, @sDesc, @bLicense, @sVersion, @sIpAddr, @sMachine )

			select	@s =	@s + ' +'
		end

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7368	+ .bEmail
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbTeam') and name = 'bEmail')
begin
	begin tran
		alter table	dbo.tbTeam	add
			bEmail		bit				not null	-- send email notifications?
				constraint	tdTeam_Email	default( 0 )
	commit
end
go
--	----------------------------------------------------------------------------
--	initialize built-in
if	not exists	(select 1 from dbo.tbTeam where idTeam = 1)
begin
	begin tran
		if	exists	(select 1 from dbo.tbTeam where idTeam > 15 and sTeam = 'Technical')
			update	dbo.tbTeam	set	sTeam = 'Technical_'	where	sTeam = 'Technical'

		set identity_insert	dbo.tbTeam	on

			insert	dbo.tbTeam	( idTeam, sTeam, tResp, bEmail, sDesc )	values	( 1, 'Technical', '00:30:00', 0, 'Built-in team for notifying about diagnostic events' )

		set identity_insert	dbo.tbTeam	off
	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all teams
--	7.06.7368	+ .bEmail
--	7.06.6817
alter proc		dbo.prTeam_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, bEmail, sDesc, bActive, dtCreated, dtUpdated
		from	tbTeam		with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a team
--	7.06.7368	+ .bEmail
--	7.06.6817
alter proc		dbo.prTeam_Imp
(
	@idTeam		smallint
,	@sTeam		varchar( 16 )
,	@tResp		time( 0 )
,	@bEmail		bit
,	@sDesc		varchar( 255 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not	exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			set identity_insert	dbo.tbTeam	on

			insert	tbTeam	(  idTeam,  sTeam,  tResp,  bEmail,  sDesc,  bActive,  dtCreated,  dtUpdated )
					values	( @idTeam, @sTeam, @tResp, @bEmail, @sDesc, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbTeam	off
		end
		else
			update	tbTeam	set	sTeam=	@sTeam,		tResp=	@tResp,		bEmail =	@bEmail,	sDesc=	@sDesc
						,	bActive =	@bActive,	dtUpdated=	@dtUpdated
				where	idTeam = @idTeam

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns teams filtered by unit (and active status)
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--	7.05.5191	* by unit
--	7.05.5179	+ .sUnits, .sCalls
--	7.05.5175
alter proc		dbo.prTeam_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
)
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, bEmail, sDesc, bActive, dtCreated, dtUpdated		--, sCalls, sUnits
		from	tbTeam	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idUnit is null	or	idTeam in (select idTeam	from	tbTeamUnit	with (nolock)	where	idUnit = @idUnit))
--		order	by	sTeam
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a team
--	7.06.7368	+ .bEmail
--	7.06.7279	* optimized logging
--	7.06.6814	* tbTeamPri -> tbTeamCall
--				- tbTeam.sCalls, .sUnits
--				* added logging of calls and units
--	7.06.5380	* prCfgPri_SetTmpFlt -> prCall_SetTmpFlt
--	7.05.5191	* fix tbTeamUnit insertion
--	7.05.5182	+ .sUnits, .sCalls
--	7.05.5021
alter proc		dbo.prTeam_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idTeam		smallint out		-- team, acted upon
,	@sTeam		varchar( 16 )
,	@tResp		time( 0 )
,	@bEmail		bit
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

	exec	dbo.prCall_SetTmpFlt	@sCalls
	exec	dbo.prUnit_SetTmpFlt	@sUnits

	select	@s =	isnull(cast(@idTeam as varchar), '?') + '|' + @sTeam + ' ' + convert(varchar, @tResp, 108) +
					' ''' + isnull(cast(@sDesc as varchar), '?') + ''' @=' + cast(@bEmail as varchar) + ' a=' + cast(@bActive as varchar) +
					' c=' + isnull(cast(@sCalls as varchar), '?') + ' u=' + isnull(cast(@sUnits as varchar), '?')
					-- + ' ' + convert(varchar, @dtCreated, 20) + ' ' + convert(varchar, @dtUpdated, 20)
	begin	tran

		if	not exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			insert	tbTeam	(  sTeam,  sDesc,  bEmail,  tResp,  bActive )	--,  sCalls,  sUnits
					values	( @sTeam, @sDesc, @bEmail, @tResp, @bActive )	--, @sCalls, @sUnits
			select	@idTeam =	scope_identity( )

			select	@k =	247,	@s =	'Team_I( ' + @s + ' )=' + cast(@idTeam as varchar)
		end
		else
		begin
			select	@k =	248,	@s =	'Team_U( ' + @s + ' )'

			update	tbTeam	set	sTeam=	@sTeam,		tResp=	@tResp,		sDesc=	@sDesc,		bEmail =	@bEmail
						,	bActive =	@bActive,	dtUpdated=	getdate( )	--,	sCalls=	@sCalls,	sUnits=	@sUnits
				where	idTeam = @idTeam
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62	--	J7980cw

		delete	from	tbTeamCall
			where	idTeam = @idTeam
			and		siIdx not in (select	siIdx	from	#tbCall	with (nolock))

		insert	tbTeamCall	( siIdx, idTeam )
			select	siIdx, @idTeam
				from	#tbCall	with (nolock)
				where	siIdx not in (select	siIdx	from	tbTeamCall	where	idTeam = @idTeam)

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
--	Returns unique email addresses for members of a given team
--	7.06.7432	+ 'distinct'
--	7.06.7373
create proc		dbo.prTeam_GetEmails
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	distinct	t.sEmail
		from	tbTeamUser	m	with (nolock)
		join	tb_User		t	with (nolock)	on	t.idUser = m.idUser
		where	idTeam = @idTeam
		and		len(t.sEmail) > 0		-- is not null
end
go
grant	execute				on dbo.prTeam_GetEmails				to [rWriter]
grant	execute				on dbo.prTeam_GetEmails				to [rReader]
go
--	----------------------------------------------------------------------------
--	Ensures predefined accounts have assignability to all active units
--	7.06.7432	* fix tbTeamUnit population for idTeam=1
--	7.06.7377	+ tbTeamUnit population for idTeam=1
--	7.06.6814	* pr_UserUnit_Set -> pr_AccUnit_Set
--				- tb_User.sTeams, .sUnits
--	7.06.5939	- @sUser='All Units'
--	7.06.5568	+ @sUser='*'
--	7.05.5121	* .sBarCode -> .sUnits
--	7.05.5098	* check idUnit
--	7.05.5084	* added check for null on @sUnits
--	7.05.5050
alter proc		dbo.pr_AccUnit_Set
	with encryption
as
begin
	declare	@idModule	tinyint
		,	@idFeature	tinyint
--		,	@i			int
--		,	@p			varchar( 3 )
--		,	@sUnits		varchar( 255 )
		,	@idRole		smallint

	declare		cur		cursor fast_forward for
		select	idModule, idFeature
			from	tb_Feature		with (nolock)

	set	nocount	on

	begin	tran

		--	reset tb_RoleUnit, tb_UserUnit, tbTeamUnit for all inactive units
		delete	from	dbo.tb_RoleUnit
			where	idUnit	in	(select idUnit from dbo.tbUnit where bActive = 0)

		delete	from	dbo.tb_UserUnit
			where	idUnit	in	(select idUnit from dbo.tbUnit where bActive = 0)

		delete	from	dbo.tbTeamUnit
			where	idUnit	in	(select idUnit from dbo.tbUnit where bActive = 0)

		--	enforce access to all units
		select	@idRole =	1												-- [Technical]
		insert	dbo.tbTeamUnit	( idTeam, idUnit )
			select	@idRole, idUnit
				from	dbo.tbUnit
				where	bActive > 0		and		idShift > 0
				and		idUnit	not in	(select idUnit from dbo.tbTeamUnit where idTeam = @idRole)

		select	@idRole =	2												-- [Admins]
		insert	dbo.tb_RoleUnit	( idRole, idUnit )
			select	@idRole, idUnit
				from	dbo.tbUnit
				where	bActive > 0		and		idShift > 0
				and		idUnit	not in	(select idUnit from dbo.tb_RoleUnit where idRole = @idRole)

		--	enforce [SysAdm] and [Admin] are in [Admins]
		if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 1 and idRole = @idRole)
			insert	dbo.tb_UserRole ( idUser, idRole )	values	( 1, @idRole )
		if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 2 and idRole = @idRole)
			insert	dbo.tb_UserRole ( idUser, idRole )	values	( 2, @idRole )

		--	enforce [Admins] have full permissions on all features of all modules
		open	cur
		fetch next from	cur	into	@idModule, @idFeature
		while	@@fetch_status = 0
		begin
			if	not	exists	(select 1 from dbo.tb_Access where idModule = @idModule and idFeature = @idFeature and idRole = @idRole)
				insert	dbo.tb_Access	( idModule, idFeature, idRole, tiAccess )
						values			( @idModule, @idFeature, @idRole, 1 )

			fetch next from	cur	into	@idModule, @idFeature
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	Imports enabled call-texts from tbCfgPri
--	7.06.7380	+ tbTeamCall population for idTeam=1
--	7.06.7279	* optimized logging
--	7.06.6010	* fix for updating non-matching call-texts
--	7.06.5868	+ [29,30] tbCall.tVoTrg, .tStTrg defaults
--	7.06.5865	* fix for call escalation (allow duplicated call-texts)
--	7.06.5563	- xuCall_Active_sCall (duplicate call-texts allowed, siIdx is the ID)
--	7.05.4976	* xuCall_Active_sCall, xuCall_Active_siIdx: depend on .bActive (not .bEnabled)
--		[7.02	* .bEnabled <-> .bActive (meaning)]
--	7.04.4916	* tbDefBed -> tbCfgBed
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	6.05	+ (nolock), tracing
--			prDefCall_InsUpd -> prDefCall_Imp
--	6.02	* fast_forward
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	5.01	encryption added
--	4.01
--	3.01	fix for tiFlags & 0x02 (enabled)
--	2.03
--	2.02
alter proc		dbo.prCall_Imp
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@idCall		smallint
		,		@siIdx		smallint			-- call-index
		,		@sCall		varchar( 16 )		-- call-text
		,		@pCall		varchar( 16 )		-- call-text
		,		@tVoTrg		time( 0 )
		,		@tStTrg		time( 0 )
		,		@iAdded		smallint
		,		@iRemed		smallint

	declare		cur		cursor fast_forward for
		select	siIdx, sCall
			from	tbCfgPri	with (nolock)
			where	siIdx > 0	and	tiFlags & 0x02 > 0		-- enabled
			order	by	1

	set	nocount	on

	select	@iAdded =	0,	@iRemed =	0

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tVoTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
	select	@tStTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall
		while	@@fetch_status = 0
		begin
			select	@idCall =	-1
			select	@idCall =	idCall,		@pCall =	sCall	from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0
	--		print	cast(@siIdx as varchar) + ': ' + @sCall + ' -> ' + cast(@idCall as varchar)

			if	@idCall > 0	and	@sCall <> @pCall
			begin
				update	tbCall	set	bActive =	0,	dtUpdated=	getdate( )
					where	idCall = @idCall

				select	@iRemed =	@iRemed + 1,	@idCall =	-1
			end

			if	@idCall < 0
			begin
	--			print	'  insert new'
				insert	tbCall	(  siIdx,  sCall,  tVoTrg,  tStTrg )
						values	( @siIdx, @sCall, @tVoTrg, @tStTrg )

				select	@iAdded =	@iAdded + 1
			end

			fetch next from	cur	into	@siIdx, @sCall
		end
		close	cur
		deallocate	cur

		update	c	set	c.bActive=	0,	dtUpdated=	getdate( )
			from	tbCall	c
			join	tbCfgPri	p	on	p.siIdx = c.siIdx	and	p.tiFlags & 0x02 = 0
			where	c.bActive > 0

		select	@s =	'Call_Imp( ) +' + cast(@iAdded as varchar) + ', *' + cast(@iRemed as varchar) + ', -' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0	and	@@rowcount > 0							--	Config?
--		if	@tiLog & 0x04 > 0	and	@@rowcount > 0							--	Debug?
--		if	@tiLog & 0x08 > 0	and	@@rowcount > 0							--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

		select	@idCall =	1												-- [Techies]

		delete	from	dbo.tbTeamCall
			where	idTeam = @idCall

		insert	dbo.tbTeamCall	( idTeam, siIdx )
			select	@idCall, siIdx
				from	dbo.tbCfgPri
				where	tiSpec	in	(10,11,12,13,14,15,16,17, 20,21, 23,24,25,26,27)
--				and		siIdx	not in	(select siIdx from dbo.tbTeamCall where idTeam = @idCall)

	commit
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	7.06.7388	+ [.idSess] into log
--	7.06.6543	+ @sStaffID
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.06.5969	* optimized
--	7.05.5227	- @sIpAddr, @sMachine, @sFrst, @sLast
--				+ @sStaff
--	7.05.5044	* @idUser: smallint -> int
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked
--	7.04.4966	* @iHass -> @iHash
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ @idSess, .tiFailed -> .tiFails
--			* optimize desc-string
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			tb_User: * .bEnabled -> .bActive
--	6.05	+ (nolock), transaction
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02	* tb_Log.idType rearranged
--	6.00
alter proc		dbo.pr_User_Login
(
	@idSess		int					-- session-id
,	@sUser		varchar( 32 )		-- login-name, lower-cased
,	@iHash		int					-- calculated password 32-bit hash (Murmur2)
--,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
--,	@sMachine	varchar( 32 )		-- client computer's name

,	@idUser		int				out	-- null if attempt failed
,	@sStaff		varchar( 16 )	out	-- full-name
--,	@sFrst		varchar( 32 )	out	-- first-name
--,	@sLast		varchar( 32 )	out	-- last-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
,	@sStaffID	varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@tiLog		tinyint
		,		@idModule	tinyint
		,		@iHass		int
		,		@bActive	bit
		,		@bLocked	bit
		,		@idLogType	tinyint
		,		@tiFails	tinyint
		,		@tiMaxAtt	tinyint
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )

	set	nocount	on

	select	@tiMaxAtt =		cast(iValue as tinyint)		from	dbo.tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule
		from	tb_Sess		with (nolock)
		where	idSess = @idSess

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@iHass =	iHash,	@bActive =	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff,		@sStaffID=	sStaffID
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule
		return	@idLogType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType =	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType =	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@iHass <> @iHash		--	wrong pass
	begin
		select	@idLogType =	223,	@s =	@s + ', attempt ' + cast( @tiFails + 1 as varchar )

		begin	tran

			if	@tiFails < @tiMaxAtt - 1
				update	tb_User		set	tiFails =	tiFails + 1
					where	idUser = @idUser
			else
			begin
				update	tb_User		set	tiFails =	0xFF
					where	idUser = @idUser
				select	@s =	@s + ', locked-out'
			end
			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
		return	@idLogType
	end

	select	@idLogType =	221,	@s =	@s + ' [' + cast( @idSess as varchar ) + ']',	@bAdmin =	0
	if	exists(	select 1 from tb_UserRole where idUser = @idUser and idRole = 2 )
		select	@bAdmin =	1,	@s =	@s + ' !'

	begin	tran

		update	tb_Sess		set	dtLastAct=	getdate( ),		idUser =	@idUser
			where	idSess = @idSess
		update	tb_User		set	dtLastAct=	getdate( ),		tiFails =	0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	7.06.7388	+ [.idSess] into log
--	7.06.6543	+ @sStaffID
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.06.5969
alter proc		dbo.pr_User_Login2
(
	@idSess		int					-- session-id
,	@gGUID		uniqueidentifier	-- AD GUID
--,	@iHash		int					-- calculated password 32-bit hash (Murmur2)
--,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
--,	@sMachine	varchar( 32 )		-- client computer's name

,	@sUser		varchar( 32 )	out	-- login-name, lower-cased
,	@idUser		int				out	-- null if attempt failed
,	@sStaff		varchar( 16 )	out	-- full-name
--,	@sFrst		varchar( 32 )	out	-- first-name
--,	@sLast		varchar( 32 )	out	-- last-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
,	@sStaffID	varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@tiLog		tinyint
		,		@idModule	tinyint
--		,		@iHass		int
		,		@bActive	bit
		,		@bLocked	bit
		,		@idLogType	tinyint
		,		@tiFails	tinyint
		,		@tiMaxAtt	tinyint
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )

	set	nocount	on

	select	@tiMaxAtt =		cast(iValue as tinyint)		from	dbo.tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule
		from	tb_Sess		with (nolock)
		where	idSess = @idSess

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@sUser =	sUser,	@bActive =	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff,		@sStaffID=	sStaffID
		from	tb_User		with (nolock)
		where	gGUID = @gGUID												--	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule
		return	@idLogType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType =	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType =	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

--	if	@iHass <> @iHash		--	wrong pass
--	..

	select	@idLogType =	221,	@s =	@s + ' [' + cast( @idSess as varchar ) + ']',	@bAdmin =	0
	if	exists	(select 1 from tb_UserRole where idUser = @idUser and idRole = 2)
		select	@bAdmin =	1,	@s =	@s + ' !'

	begin	tran

		update	tb_Sess		set	dtLastAct=	getdate( ),		idUser =	@idUser
			where	idSess = @idSess
		update	tb_User		set	dtLastAct=	getdate( ),		tiFails =	0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
--	7.06.7388	+ [.idSess] into log
--	7.06.7300	* Duration	(cause datediff(dd, ) swallows days)
--	7.06.7142	* optimized logging (+ [DT-dtCreated])
--	7.06.7115	* optimized logging (+ dtCreated)
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.05.5940	* optimize
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

			select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ') [' + cast( @idSess as varchar ) + '] ' + isnull(convert(varchar, @dtCreated, 121), '?') +
							' [' + isnull(cast(datediff(ss, @dtCreated, getdate())/86400 as varchar), '?') + 'd ' + isnull(convert(varchar, getdate() - @dtCreated, 114), '?') + ']'
--							' [' + isnull(cast(datediff(dd, @dtCreated, getdate( )) as varchar), '?') + 'd ' + isnull(convert(varchar, getdate( )-@dtCreated, 114), '?') + ']'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
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
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
,	@bGroup		bit			= null	-- null=any, 0=no, 1=yes
,	@bStaff		bit			= null	-- null=any, 0=no, 1=yes
,	@idStfLvl	tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDevice
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.idDvcType & @idDvcType <> 0
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bStaff is null	or	@bStaff = 0	and	d.idUser is null	or	@bStaff = 1	and	d.idUser is not null )
		and		(@idStfLvl is null	or	d.idStfLvl = @idStfLvl	or	@idStfLvl = 0	and	d.idStfLvl is null)
		and		(@bGroup is null	or	d.tiFlags & 0x01 = @bGroup)
		and		(@idUnit is null	or	d.idDvcType = 1	or	d.idDvc in (select idDvc	from	tbDvcUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Returns all user settings
--	7.06.7390
create proc		dbo.pr_OptUsr_GetAll
(
	@idUser		int
--,	@idOption	tinyint
)
	with encryption
as
begin
--	set	nocount	on
	select	os.idOption
		,	coalesce(ou.iValue,os.iValue)	as	iValue
		,	coalesce(ou.fValue,os.fValue)	as	fValue
		,	coalesce(ou.tValue,os.tValue)	as	tValue
		,	coalesce(ou.sValue,os.sValue)	as	sValue
		from		dbo.tb_OptSys	os	with (nolock)
		left join	dbo.tb_OptUsr	ou	with (nolock)	on	ou.idOption = os.idOption	and	idUser = @idUser
--	select	idOption, iValue, fValue, tValue, sValue
--		from	dbo.tb_OptUsr	with (nolock)
--		where	idUser = @idUser
	--	and		idOption = @idOption
end
go
grant	execute				on dbo.pr_OptUsr_GetAll				to [rWriter]
grant	execute				on dbo.pr_OptUsr_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
--	7.06.7390	* optimized log (@sValue)
--	7.06.7292	* tb_Option[11]<->[19]
--	7.06.6751	* optimized log (sys.fn_varbintohexstr -> convert(varbinary))
--	7.06.5913	* enhance int-to-hex, AD pass
--	7.06.5886	+ exec dbo.pr_User_sStaff_Upd
--	7.06.5596	+ hex for ints
--	7.05.5071	* @idOption: smallint -> tinyint
--				+ where idOption =
--	7.05.5044	* @idUser: smallint -> int
--	7.04.4898
alter proc		dbo.pr_OptSys_Upd
(
	@idOption	tinyint
,	@iValue		int
,	@fValue		float
,	@tValue		datetime
,	@sValue		varchar( 255 )
,	@idUser		int
)
	with encryption
as
begin
	declare		@k	tinyint
			,	@i	int
			,	@f	float
			,	@t	datetime
			,	@s	varchar( 255 )

	set	nocount	on

	select	@k =	o.tiDatatype,	@i =	os.iValue,	@f =	os.fValue,	@t =	os.tValue,	@s =	os.sValue
		from	dbo.tb_OptSys	os	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin
		begin	tran

			update	dbo.tb_OptSys	set	iValue =	@iValue,	fValue =	@fValue,	tValue =	@tValue,	sValue =	@sValue,	dtUpdated=	getdate( )
				where	idOption = @idOption	--	and	idUser = @idUser

			if	@idOption = 16	or	@idOption = 36
				select	@sValue= '************'								-- do not expose SMTP or AD pass

			select	@s =	'[' + isnull(cast(@idOption as varchar), '?') + '] '

				 if	@k = 56		select	@s =	@s + 'i=' + isnull(cast(@iValue as varchar), '?') + ' (' + convert(varchar, convert(varbinary(4), @iValue), 1) + ')'
			else if	@k = 62		select	@s =	@s + 'f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s =	@s + 't=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s =	@s + 's=''' + isnull(@sValue, '?') + ''''

			exec	dbo.pr_Log_Ins	236, @idUser, null, @s

			if	@idOption = 19		exec	dbo.pr_User_sStaff_Upd			-- staff name format

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Updates and logs user setting
--	7.06.7390	+ added removal when matches tb_OptSys
--	7.06.6751	* optimized log (sys.fn_varbintohexstr -> convert(varbinary))
--	7.06.5596	+ hex for ints
--	7.05.5071	* @idOption: smallint -> tinyint
--				+ where idOption =
--				* @idUser: smallint -> int
--	7.04.4898
alter proc		dbo.pr_OptUsr_Upd
(
	@idOption	tinyint
,	@iValue		int
,	@fValue		float
,	@tValue		datetime
,	@sValue		varchar( 255 )
,	@idUser		int
)
	with encryption
as
begin
	declare		@k	tinyint
			,	@i	int
			,	@f	float
			,	@t	datetime
			,	@s	varchar( 255 )

	set	nocount	on

	select	@k =	o.tiDatatype,	@i =	os.iValue,	@f =	os.fValue,	@t =	os.tValue,	@s =	os.sValue
		from	dbo.tb_OptSys	os	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin
		begin	tran
			update	dbo.tb_OptUsr	set	iValue =	@iValue,	fValue =	@fValue,	tValue =	@tValue,	sValue =	@sValue,	dtUpdated=	getdate( )
				where	idUser = @idUser	and	idOption = @idOption
			if	@@rowcount = 0
				insert	dbo.tb_OptUsr	( idOption,  idUser,  iValue,  fValue,  tValue,  sValue)
					values				(@idOption, @idUser, @iValue, @fValue, @tValue, @sValue)

	--		if	@idOption = 16	select	@sValue= '************'		--	do not expose SMTP pass

			select	@s= '[' + isnull(cast(@idOption as varchar), '?') + '] '

				 if	@k = 56		select	@s =	@s + 'i=' + isnull(cast(@iValue as varchar), '?') + ' (' + convert(varchar, convert(varbinary(4), @iValue), 1) + ')'
			else if	@k = 62		select	@s =	@s + 'f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s =	@s + 't=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s =	@s + 's=''' + isnull(@sValue, '?') + ''''

			exec	dbo.pr_Log_Ins	231, @idUser, null, @s
		commit
	end
	else
		delete	from	dbo.tb_OptUsr
			where	idUser = @idUser	and	idOption = @idOption
end
go
--	----------------------------------------------------------------------------
--	7.06.7110	clean up sessions
begin
	begin tran
		declare	@idModule	tinyint

		declare	cur1	cursor fast_forward for
			select	distinct	idModule
				from	tb_Sess		with (nolock)
				where	sMachine is not null 

		open	cur1
		fetch next from	cur1	into	@idModule
		while	@@fetch_status = 0
		begin
			exec	dbo.pr_Sess_Del		0, 1, @idModule

			fetch next from	cur1	into	@idModule
		end
		close	cur1
		deallocate	cur1
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7390	clean up pre-defined user options
delete	from	dbo.tb_OptUsr
	where	idUser < 16
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
--	7.06.7410	* match APP_FAIL source (S-0-0-0) and don't complain
--	7.06.7292	* tb_Option[26]->[6]
--	7.06.7279	* optimized logging
--	7.06.7115	* optimized logging (skip InvDataErr for @iAID = 0)
--	7.06.6789	* optimized mismatch logging (only for @tiRID = 0)
--	7.06.6768	* optimized mismatch logging
--	7.06.6758	* optimized log (@iAID in hex, +mismatches for iAID, sDevice)
--	7.06.6297	* optimized log
--	7.06.5633	* optimize
--	7.06.5588	* check for null cSys,tiGID,tiJID,tiRID
--	7.06.5560	* match inactive devices and re-activate, log no name/system
--	7.06.5466	* check tb_OptSys[26] for valid cSys
--				+ 'SIP:' devices are marked with 'P'
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit
		,		@sD			varchar( 16 )
		,		@iA			int

	set	nocount	on

	select	@idDevice=	null

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 6

	if	charindex('SIP:', @sDevice) = 1										-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + isnull(right('00' + cast(@tiGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiRID as varchar), 2),'?') +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					' [' + isnull(@cDevice,'?') + '] ''' + isnull(@sDevice,'?') + ''' #' + isnull(@sDial,'?') + ' )'

	-- match 7967-P workflow station's (0x1A) 'phantom' RIDs
	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow

		-- match active devices?
		select		@idDevice=	idDevice,	@bActive =	bActive									--	7.06.6758
				from	tbDevice	with (nolock)
				where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		-- match inactive devices?
		if	@idDevice is null
			select	@idDevice=	idDevice,	@bActive =	bActive
				from	tbDevice	with (nolock)
				where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice

/*			select	@sD =	sDevice,	@iA =	iAID											--	7.06.6758, .6773
				from	tbDevice
				where	idDevice = @idDevice

			if	@sD <> @sDevice
				select	@s =	@s + ' ^n:"' + @sD + '"'

			if	@iA <> @iAID
				select	@s =	@s + ' ^a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

			if	@sD <> @sDevice	or	@iA <> @iAID
				exec	dbo.pr_Log_Ins	82, null, null, @s
*/
			return	0												-- match found
		end
	end

	-- adjust AID
	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0


	-- match active devices?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.04.4969
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	cDevice = 'M'

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID > 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


	-- match inactive devices?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.06.5560
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	cDevice = 'M'

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID > 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


	-- match APP_FAIL source?
	if	@idDevice is null	and	@tiGID = 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7410
		select	@idDevice=	idDevice,	@bActive =	bActive,	@cDevice =	'A'	from	tbDevice	with (nolock)
			where						cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	--and	cDevice = 'M'


--	if	@idDevice > 0																			--	7.06.5560
	if	@idDevice is not null																	--	7.06.739?
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		select	@sD =	sDevice,	@iA =	iAID												--	7.06.6758
			from	tbDevice
			where	idDevice = @idDevice

		if	@tiRID = 0	and	@sD <> @sDevice
			select	@s =	@s + ' ^N:''' + @sD + ''''

		if	@iA <> @iAID
			select	@s =	@s + ' ^A:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

		if	@tiRID = 0	and	@sD <> @sDevice		or	@iAID <> 0	and	@iA <> @iAID
			exec	dbo.pr_Log_Ins	82, null, null, @s

		return	0															-- match found
	end

--	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	if	len(@sDevice) > 0	and	@cSys is not null												--	7.05.5186
	begin
		begin	tran

			if	charindex(@cSys, @sSysts) = 0								-- not in Allowed Systems
			begin
				select	@s =	@s + ' !cSys'
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
			else
			begin
				if	@tiRID > 0						-- R-bus device
					select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
				if	@tiJID > 0	and	@tiRID = 0		-- J-bus device
					select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	bActive > 0

				insert	tbDevice	(  idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial )
						values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial )
				select	@idDevice=	scope_identity( )

				if	@tiLog & 0x02 > 0										--	Config?
--				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
				begin
					select	@s =	@s + '=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
					exec	dbo.pr_Log_Ins	74, null, null, @s
				end
			end

		commit
	end
	else																	-- no name / system		7.06.5560
	begin
		select	@s =	@s + ' !sDvc'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	7.06.7412	* optimized logging, suppress !U for APP_FAIL, etc.
--	7.06.7279	* optimized logging
--	7.06.6373	* optimize trace logging
--				- unused vars
--	7.06.6355	+ tbCfgPri.tiLvl, selecting @idParent for clinic calls
--	7.06.6297	* optimized log
--	7.06.5562	* tbEvent: .vbCmd -> tbEvent_B, .tiLen -> tbEvent_B
--	7.06.5492	* optimize @tiBed
--	7.06.5490	* optimize @idUnit
--	7.06.5466	* optimize error logging
--	7.05.5267	* skip healing 84s
--	7.05.5211	+ 'or @idCmd = 0x8D' when selecting @idParent, otherwise AudioQuit events are not attached
--	7.05.5205	+ @idRoom out,	* @idUnit out,	arg order
--	7.05.5203	* move setting tbRoom.idUnit up
--	7.05.5141	* use @cDevice for dst-device also
--	7.05.5095	+ 'or @idCmd < 0x80' when selecting @idParent, otherwise RPP/PCS events are not attached
--	7.05.5064	+ .bActive > 0 when selecting @idParent, otherwise extra subsequent events are attached
--	7.05.4980	+ validate @idUnit
--	7.05.4976	- tbEvent_P, tbEvent_T
--				* tbCfgBed:		.bInUse -> .bActive
--	7.04.4972	* store 'presence' into tbEvent_P (otherwise tbEvent_A won't keep these calls)
--				+ @idCall0 to handle call escalation
--	7.04.4969	* flip Src and Dst for audio/svc/pat-rq commands
--	7.04.4968	* use tbEvent_A.tiRID and .tiBtn for idParent resolution
--	7.04.4965	* insert into tbEvent_P only 'medical' calls
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--				* tbDefCall -> tbCall
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	7.03	* 7967-P detection and handling
--	7.02	enforce tbEvent.idRoom to only contain valid room references
--			* setting tbRoom.idUnit (moved from tbDevice)
--	6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ extended expiration for picked calls
--			+ (nolock)
--	6.04	* tbEvent.idRoom assignment for @tiStype = 26
--			+ populating tbDevice.idUnit
--			+ populating tbEvent_S, tbEvent.idRoom
--	6.03	+ check for tiShelf,tiSpec before inserting to [tbEvent_T] - fixes 'presense' in RptCallActSum
--			+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			added 0x97 to "flipped" (src-dst) commands
--	6.02	* logic change to allow idCmd=0 without touching tbEvent_P
--			* prDevice_GetIns: + @cSys (+ tbDevice.cSys), order of @rgs (prEvent_Ins)
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			+ @idUnit
--	5.01	encryption added
--			+ tbEvent.idParent, + .tParent, now records parent ref
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			@tiBed set to 'null' when > 9
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	2.03	+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--	2.01	.idRoom -> .idDevice (FK changed also)
--	1.09	+ @idType= null
--	1.08
--	1.00
alter proc		dbo.prEvent_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message hash (32-bit)
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint				-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@sSrcDvc	varchar( 16 )		-- source device name
,	@cDstSys	char( 1 )			-- destination system
,	@tiDstGID	tinyint				-- destination G-ID - gateway
,	@tiDstJID	tinyint				-- destination J-ID - J-bus
,	@tiDstRID	tinyint				-- destination R-ID - R-bus
,	@sDstDvc	varchar( 16 )		-- destination device name
,	@sInfo		varchar( 32 )		-- info text

,	@idUnit		smallint	out		-- active unit ID
,	@idRoom		smallint	out		-- room ID
,	@idEvent	int			out		-- output: inserted idEvent
,	@idSrcDvc	smallint	out		-- output: found/inserted source device
,	@idDstDvc	smallint	out		-- output: found/inserted destination device

,	@idLogType	tinyint		= null	-- type look-up FK (marks significant events only)
,	@idCall		smallint	= null	-- call look-up FK (only 41,84,8A and 95 commands)
,	@tiBtn		tinyint		= null	-- button code (0-31)
,	@tiBed		tinyint		= null	-- bed index (0-9)
,	@iAID		int			= null	-- device A-ID (32 bits)
,	@tiStype	tinyint		= null	-- device type (1-255)
,	@idCall0	smallint	= null	-- call prior to escalation
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@p			varchar( 16 )
		,		@dtEvent	datetime
		,		@tiHH		tinyint
		,		@cDevice	char( 1 )
		,		@cSys		char( 1 )
		,		@idParent	int
		,		@dtParent	datetime
		,		@tiLvl		tinyint
		,		@iAID2		int
		,		@tiGID		tinyint
		,		@tiJID		tinyint
		,		@tiStype2	tinyint
		,		@sDvc		varchar( 16 )

	set	nocount	on

	select	@dtEvent =	getdate( ),		@p =	''
		,	@tiHH =		datepart( hh, getdate( ) )
		,	@cDevice =	case when @idCmd = 0x83 then 'G' else '?' end

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Evt_I( ' + isnull(cast(convert(varchar, convert(varbinary(1), @idCmd), 1) as varchar),'?') +	-- ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') +
					' /' + isnull(cast(@tiBtn as varchar),'?') + ','
	if	@iAID > 0	or	@tiStype > 0
		select	@s =	@s + ' ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?')
	select	@s =	@s + ' ''' + isnull(@sSrcDvc,'?') + ''''
	if	@tiBed < 10
		select	@s =	@s + ':' + cast(@tiBed as varchar)
	if	len(@cDstSys) > 0	or	@tiDstGID > 0	or	@tiDstJID > 0	or	@tiDstRID > 0
		select	@s =	@s + ', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' +
						isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiDstRID as varchar), 2),'?')	-- + ' )'
	if	len(@sInfo) > 0
		select	@s =	@s + ', i=''' + @sInfo + ''''
	select	@s =	@s + ', u=' + isnull(cast(@idUnit as varchar),'?') + ' )'

	if	@tiBed = 0xFF
		select	@tiBed =	null
	else
	if	@tiBed > 9
		select	@tiBed =	null,	@p =	@p + ' !B'						-- invalid bed

--	if	@idUnit > 0	and	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
--		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)	)
--		select	@idUnit =	null,	@p =	@p + ' !U'						-- invalid unit
	if	@idUnit > 0		and													--	7.06.7412
		(@idUnit < 259	or													-- lowest possible unit
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)	)
	begin
		select	@idUnit =	null											-- suppress
		if	@tiSrcGID > 0
			select	@p =	@p + ' !U'										-- invalid unit
	end

	begin	tran

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins1'

		if	@tiBed is not null												-- mark a bed in active use
			update	tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)					-- audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiLvl =	@tiSrcRID,	@sDvc =		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiLvl,		@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins2'

		exec		dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins3'

		if	@idCmd <> 0x84	or	@idLogType <> 194							-- skip healing 84s
		begin
			insert	tbEvent	(  idCmd,  iHash,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit
							,	cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  idSrcDvc
							,	cDstSys,  tiDstGID,  tiDstJID,  tiDstRID,  idDstDvc
							,	dtEvent,  dEvent,   tEvent,   tiHH )
					values	( @idCmd, @iHash, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit
							,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @idSrcDvc
							,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @idDstDvc
							,	@dtEvent, @dtEvent, @dtEvent, @tiHH )
			select	@idEvent =	scope_identity( )

			if	@tiLen > 0	and	@vbCmd is not null
				insert	tbEvent_B	(  idEvent,  tiLen,  vbCmd )			--	7.06.5562
						values		( @idEvent, @tiLen, @vbCmd )

			if	len(@p) > 0
			begin
				select	@s =	@s + ' ' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins4'

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

/*		if	len(@p) > 0
		begin
			select	@s =	@s + ' ' + isnull(cast(@idEvent as varchar),'?') + @p
			exec	dbo.pr_Log_Ins	82, null, null, @s
		end
*/
		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02										-- set tbEvent.idParent, .idRoom, .tParent; tbRoom.idUnit
		begin

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins5'

			select	@tiLvl =	tiLvl										--	7.06.6355
				from	tbCfgPri	cp	with (nolock)
				join	tbCall		c	with (nolock)	on	c.siIdx = cp.siIdx
				where	c.idCall = @idCall

			if	@idCmd = 0x84	and	@tiLvl > 2								--	7.06.6355
				select	@idParent=	idEvent,	@dtParent=	dtEvent
					from	tbEvent_A	ea	with (nolock)
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = ea.siIdx
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		bActive > 0			and	cp.tiLvl = 2			-- clinic-patient
			else
				select	@idParent=	idEvent,	@dtParent=	dtEvent			--	7.04.4968
					from	tbEvent_A	with (nolock)
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		( bActive > 0		or	@idCmd < 0x80	or	@idCmd = 0x8D )		--	7.05.5095, .5211
					and		( tiBtn = @tiBtn	or	@tiBtn is null )
					and		( idCall = @idCall	or	@idCall is null		or	idCall = @idCall0	and	@idCall0 is not null )

			select	@idRoom =	idDevice
				from	vwRoom		with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	bActive > 0		--	and	tiRID = 0

--			select	@s=	'Evt_i2: prnt=' + isnull(cast(@idParent as varchar),'?') + ' room=' + isnull(cast(@idRoom as varchar),'?')
--			exec	pr_Log_Ins	0, null, null, @s

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins6'

			if	@idParent > 0
				update	tbEvent		set	idParent =	@idParent,	idRoom =	@idRoom,	tParent =	dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	tbEvent		set	idParent =	@idEvent,	idRoom =	@idRoom,	tParent =	'0:0:0'
					where	idEvent = @idEvent

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins7'

			if	@idUnit > 0		and	@idRoom > 0								--	7.02	7.05.5205
				update	tbRoom		set	idUnit =	@idUnit
					where	idRoom = @idRoom

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins8'
		end

		if	@idEvent > 0													-- update event statistics
		begin
			select	@idParent=	null
			select	@idParent=	idEvent
				from	tbEvent_S	with (nolock)
				where	dEvent = cast(@dtEvent as date)		and	tiHH = @tiHH

			if	@idParent	is null
				insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
						values		( @dtEvent, @tiHH, @idEvent )
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins9'

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns active teams responding to a given priority in a given unit
--	7.06.7422	* @idUnit may be null now
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--				* tbTeamPri -> tbTeamCall
--	7.06.5347
alter proc		dbo.prTeam_GetByUnitPri
(
	@idUnit		smallint			-- null=any?
,	@siIdx		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, bEmail, sDesc, bActive, dtCreated, dtUpdated		--, sCalls, sUnits
		from	tbTeam	with (nolock)
		where	bActive > 0
		and	(	@idUnit is null
			or	idTeam in (select idTeam	from	tbTeamUnit	with (nolock)	where	idUnit = @idUnit))
--		and		idTeam in (select idTeam	from	tbTeamUnit	with (nolock)	where	idUnit = @idUnit)
		and		idTeam in (select idTeam	from	tbTeamCall	with (nolock)	where	siIdx = @siIdx)
	--	order	by	idTeam
end
go
--	----------------------------------------------------------------------------
--	7.06.7432	* [83].tiCat:	4 -> 16
begin
	begin tran
		update	dbo.tb_LogType	set	tiCat=	16		where	idLogType = 83		--	'Disconnected' should be in 'Data/Comm'
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
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
	@idUser		int					-- user, performing the action
,	@idOper		int			out		-- operand user, acted upon
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

	if	@bActive = 0		select	@bOnDuty =	0							--	7.06.7326
	if	@idStfLvl is null	select	@bOnDuty =	0,	@sUnits =	null		--	7.06.7334

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	-- enforce membership in 'Public' role
	if	not exists	(select 1 from #tbRole with (nolock) where idRole = 1)
		insert	#tbRole		(idRole)	values	( 1 )

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
			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff
							,  sStaffID,  idStfLvl,  sBarCode,  bOnDuty,  bActive )	--,  sUnits,  sTeams
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '
							, @sStaffID, @idStfLvl, @sBarCode, @bOnDuty, @bActive )	--, @sUnits, @sTeams
			select	@idOper =	scope_identity( )

			select	@k =	237,	@s =	'Usr_I( ' + @s + ' )=' + cast(@idOper as varchar)
		end
		else
		begin
			update	tb_User	set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
								,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
								,	sStaffID =	@sStaffID,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode
						--		,	sUnits =	@sUnits,	sTeams =	@sTeams
								,	bOnDuty =	case when	@bActive = 0	then	0	else	@bOnDuty	end
								,	dtDue =		case when	@bActive = 0	or	@idStfLvl is null	then	null	else	dtDue	end
								,	bActive =	@bActive,	dtUpdated=	getdate( )
						--		,	bOnDuty =	@bOnDuty,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@k =	238,	@s =	'Usr_U( ' + @s + ' )'
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s, 62	--	J7980cw

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
--	Inserts or updates an AD-user
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
--		,		@bEdit		bit
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
--					,	@k =	102,	@bEdit =	1		--	237			--	7.06.7129
			end
			else															--	7.06.7094
				select	@s =	'Usr_ADI( ' + @s + ' ) ^'					-- *inactive skipped*
					,	@k =	101		--	2								--	7.06.7129
--					,	@k =	101,	@bEdit =	1		--	2			--	7.06.7129
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
--				,	@k =	103,	@bEdit =	1		--	238				--	7.06.7129
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
		exec	dbo.pr_User_sStaff_Upd	@idOper
--		if	0 < @bEdit														--	7.06.7249
		if	@k < 104														--	7.06.7251	!! do not flood audit with 'skips' !!
			exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s, @idModule

		if	101 < @k														--	7.06.7094/79129	only import *active* users!
			-- enforce membership in 'Public' role
			if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
				insert	tb_UserRole	( idRole, idUser )
						values		( 1, @idOper )

	commit

	return	@k
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
--	7.06.7447	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6814	* added logging of units
--	7.05.5233	optimized
--	7.05.5021
alter proc		dbo.pr_Role_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idRole		smallint		out	-- role, acted upon
,	@sRole		varchar( 16 )
,	@sDesc		varchar( 255 )
,	@bActive	bit
,	@sUnits		varchar( 255 )
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	select	@s =	isnull(cast(@idRole as varchar), '?') + '|' + @sRole + ', ''' + isnull(cast(@sDesc as varchar), '?') +
					''' a=' + cast(@bActive as varchar) + ' u=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_Role where idRole = @idRole)
		begin
			insert	tb_Role	(  sRole,  sDesc,  bActive )
					values	( @sRole, @sDesc, @bActive )
			select	@idRole =	scope_identity( )

			select	@k =	242,	@s =	'Role_I( ' + @s + ' )=' + cast(@idRole as varchar)
		end
		else
		begin
			update	tb_Role	set	sRole=	@sRole,		sDesc=	@sDesc,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idRole = @idRole

			select	@k =	243,	@s =	'Role_U( ' + @s + ' )'
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62	--	J7980cw

		delete	from	tb_RoleUnit
			where	idRole = @idRole
			and		idUnit not in (select	idUnit	from	#tbUnit	with (nolock))

		insert	tb_RoleUnit	( idUnit, idRole )
			select	idUnit, @idRole
				from	#tbUnit	with (nolock)
				where	idUnit not in (select	idUnit	from	tb_RoleUnit	where	idRole = @idRole)

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
--	7.06.7454	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.7222	+ treat 'EMPTY' as 'no patient'
--				+ 0xFF gender -> 'U'
--				+ quotes in trace
--	7.05.5074	+ @idDoctor
--	7.03	- @sNote
--			* re-structure and optimize (log only changed fields - and if changed)
--	7.02	* fixed "Conversion failed when converting the varchar value '?' to data type int."
--			* @cGender null?
--			+ @sDoctor
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prPatient_GetIns
(
	@sPatient	varchar( 16 )		-- full name (HL7)
,	@cGender	char( 1 )
,	@sInfo		varchar( 32 )
--,	@sNote		varchar( 255 )
,	@sDoctor	varchar( 16 )		-- full name (HL7)

,	@idPatient	int out				-- output
,	@idDoctor	int out				-- output
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
	declare		@idDoc		int
	declare		@cGen		char( 1 )
	declare		@sInf		varchar( 32 )
--	declare		@sNot		varchar( 255 )

	set	nocount	on

	if	@cGender is null	or	ascii(@cGender) = 0xFF
		select	@cGender=	'U'

	if	@sPatient = 'EMPTY'													--	.7222	treat 'EMPTY' as 'no patient'
		select	@sPatient=	null

	if	0 < len( @sPatient )
	begin
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

		select	@idPatient=	idPatient,	@cGen= cGender,		@sInf= sInfo,	@idDoc= idDoctor	--, @sNot= sNote
			from	tbPatient	with (nolock)
			where	sPatient = @sPatient	and	bActive > 0

		begin	tran

			if	@idPatient is null											--	no active patient with given name found
			begin
				insert	tbPatient	(  sPatient,  cGender,  sInfo,  idDoctor )	--,  sNote
						values		( @sPatient, @cGender, @sInfo, @idDoctor )	--, @sNote
				select	@idPatient=	scope_identity( )

				select	@s =	'Pat_I( ' + isnull(@cGender,'?') + ': ' + isnull(@sPatient,'?')
		--						'", n="' + isnull(@sNote,'?') +
				if	len(@sInfo) > 0
					select	@s =	@s + ' i=''' + @sInfo + ''''
				select	@s =	@s + ' d=' + isnull(cast(@idDoctor as varchar),'?') + ' ) id=' + cast(@idPatient as varchar)
				exec	dbo.pr_Log_Ins	44, null, null, @s
			end
			else															--	found active patient with given name
			begin
				select	@s=	''
				if	@cGen <> @cGender	select	@s =	@s + ' g=' + isnull(@cGender,'?')
				if	@sInf <> @sInfo		select	@s =	@s + ' i="' + isnull(@sInfo,'?') + '"'
		--		if	@sNot <> @sNote		select	@s =	@s + ' n="' + isnull(@sNote,'?') + '"'
				if	@idDoc <> @idDoctor	select	@s =	@s + ' d=[' + isnull(cast(@idDoctor as varchar),'?') + ']'		-- + isnull(@sDoctor,'?')

				if	0 < len( @s )											--	smth has changed
				begin
					update	tbPatient	set	cGender =	@cGender,	sInfo=	@sInfo,	idDoctor =	@idDoctor,	dtUpdated=	getdate( )	--, sNote= @sNote
						where	idPatient = @idPatient

					select	@s =	'Pat_U( ' + cast(@idPatient as varchar) + '|' + isnull(@sPatient,'?') + @s + ' )'
					exec	dbo.pr_Log_Ins	44, null, null, @s
				end
			end

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.7460	clean up stale staff-assignments and coverage
begin
	update	dbo.tbStfCvrg	set	dtEnd=	getdate( ),		dEnd =	getdate( ),		tEnd =	getdate( )
		where	idStfCvrg is not null	and	dtEnd is null

	update	dbo.tbStfAssn	set	idStfCvrg=	null
		where	idStfCvrg is not null	and	bActive = 0
end
go
--	----------------------------------------------------------------------------
--	Imports a shift
--	7.06.7460	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5935	+ logging
--	7.06.4939	- .tiRouting
--	7.05.5087	* optimize
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4965
alter proc		dbo.prShift_Imp
(
	@idShift	smallint
,	@idUnit		smallint
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiNotify	tinyint				-- notification mode: 0=Auto, 1=SemiAuto, 2=Manual [, 3=FollowConsole]
,	@idUser		int
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Sh_Imp( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', nt=' + isnull(cast(@tiNotify as varchar),'?') + ' bk=' + isnull(cast(@idUser as varchar),'?') + ' a=' + isnull(cast(@bActive as varchar),'?') +
					' cr=' + isnull(convert(varchar, @dtCreated, 20),'?') + ' up=' + isnull(convert(varchar, @dtUpdated, 20),'?') + ' )'

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s, 94

	begin	tran

--	-	if	exists	(select 1 from tbShift with (nolock) where idShift = @idShift)
		update	tbShift	set	idUnit= @idUnit, tiIdx= @tiIdx, sShift= @sShift, tBeg= @tBeg, tEnd= @tEnd
					,	tiNotify= @tiNotify, idUser= @idUser, bActive= @bActive, dtUpdated= @dtUpdated
			where	idShift = @idShift
--	-	else
		if	@@rowcount = 0
		begin
			set identity_insert	dbo.tbShift	on

			insert	tbShift	(  idShift,  idUnit,  tiIdx,  sShift,  tBeg,  tEnd,  tiNotify,  idUser,  bActive,  dtCreated,  dtUpdated )
					values	( @idShift, @idUnit, @tiIdx, @sShift, @tBeg, @tEnd, @tiNotify, @idUser, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbShift	off
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Imports a staff assignment definition
--	7.06.7460	* disable duplicates and close their coverage
--	7.06.5940	* optimize logging
--	7.06.5332	* fix check @idStfAssn > 0 -> @@rowcount
--	7.05.5248	+ dup check (xuStfAssn_Active_RoomBedShiftIdx)
--	7.05.5087	+ trace output
--	7.05.5074
alter proc		dbo.prStfAssn_Imp
(
	@idStfAssn	int							-- null = new
,	@idUnit		smallint					-- unit look-up FK
--,	@idRoom		smallint					-- room look-up FK
,	@cSys		char( 1 )					-- corresponding to idRoom
,	@tiGID		tinyint
,	@tiJID		tinyint
,	@tiBed		tinyint						-- bed index FK
--,	@idShift	smallint					-- shift look-up FK
,	@tiShIdx	tinyint						-- shift index [1..3]
,	@tiIdx		tinyint						-- staff index [1..3]
--,	@idUser		int							-- staff look-up FK
,	@sStaffID	varchar( 16 )				-- corresponding to idUser
,	@bActive	bit							-- active?
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@idRoom		smallint
		,		@idShift	smallint
		,		@idUser		int
		,		@idAssn		int

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@idRoom =	idDevice	from	vwRoom		with (nolock)	where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID
	select	@idShift =	idShift		from	tbShift		with (nolock)	where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx
	select	@idUser =	idUser		from	tb_User		with (nolock)	where	bActive > 0		and	sStaffID = @sStaffID

	select	@s =	'SA_Imp( ' + isnull(cast(@idStfAssn as varchar),'?') + ', ' +
					isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' + right('00' + isnull(cast(@tiJID as varchar),'?'), 3) +
					', ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiShIdx as varchar),'?') + '=' + isnull(cast(@idShift as varchar),'?') + ', ' + isnull(cast(@tiIdx as varchar),'?') +
					':' + @sStaffID + '=' + isnull(cast(@idUser as varchar),'?') + ' a=' + isnull(cast(@bActive as varchar),'?') + ' ) rm=' + isnull(cast(@idRoom as varchar),'?')

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	begin	tran

	--	if	@bActive > 0	and	(@idRoom is null	or	@idShift is null	or	@idUser is null)
		if	@idRoom is null		or	@idShift is null	or	@idUser is null
		begin
			exec	dbo.pr_Log_Ins	47, null, null, @s, 94

			update	tbStfAssn	set	bActive =	@bActive,	dtCreated=	@dtCreated,		dtUpdated=	@dtUpdated
				where	idStfAssn = @idStfAssn
		end
		else
		begin
			select	@idAssn= idStfAssn										-- find a xuStfAssn_RmBdShIdx_Act match
				from	tbStfAssn
				where	idRoom = @idRoom	and	tiBed = @tiBed	and	idShift = @idShift	and	tiIdx = @tiIdx	and	bActive > 0

			if	@idAssn <> @idStfAssn										-- if that's not the argument
			begin
				update	c	set	dtEnd=	getdate( ),	dEnd =	getdate( ),	tEnd =	getdate( )
					from	tbStfCvrg	c
					join	tbStfAssn	a	on	a.idStfCvrg = c.idStfCvrg	and	a.idStfAssn = @idAssn
					where	dtEnd is null									-- close its coverage

				update	tbStfAssn	set	idStfCvrg=	null,	bActive =	0,		dtUpdated= getdate( )
					where	idStfAssn = @idAssn								-- and deactivate that match
			end

--	-		if	exists	(select 1 from tbStfAssn with (nolock) where idStfAssn = @idStfAssn)
			update	tbStfAssn	set	idRoom =	@idRoom,	tiBed =		@tiBed,		idShift =	@idShift,	tiIdx =		@tiIdx
								,	idUser =	@idUser,	bActive =	@bActive,	dtCreated=	@dtCreated,	dtUpdated=	@dtUpdated
				where	idStfAssn = @idStfAssn
--	-		else
			if	@@rowcount = 0
			begin
				set identity_insert	dbo.tbStfAssn	on

				insert	tbStfAssn	(  idStfAssn,  idRoom,  tiBed,  idShift,  tiIdx,  idUser,  bActive,  dtCreated,  dtUpdated )
						values		( @idStfAssn, @idRoom, @tiBed, @idShift, @tiIdx, @idUser, @bActive, @dtCreated, @dtUpdated )

				set identity_insert	dbo.tbStfAssn	off
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all staff assignment definitions
--	7.06.7460	+ .sRoom, .sStaff
--	7.06.6816	* move .idRoom, .idShift, .idUser to the end
--	7.06.5386	+ update tbStfAssn
--	7.05.5074	+ .dtCreated, .dtUpdated
--	7.05.5050
alter proc		dbo.prStfAssn_Exp
	with encryption, exec as owner
as
begin
	set	nocount	off

	update	tbStfAssn	set	bActive= 0
		where	bActive= 1
		and		idRoom in (select idDevice from tbDevice with (nolock) where cDevice='R' and bActive = 0)

	set	nocount	on

	select	idStfAssn, idUnit, cSys, tiGID, tiJID, tiBed, tiShIdx, tiIdx, sStaffID, bActive, dtCreated, dtUpdated,	idRoom, sRoom, idUser, sStaff, idShift
		from	vwStfAssn	with (nolock)
	---	where	bActive > 0					-- must export all to ensure matching deactivation
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
--	7.06.7461	+ finish coverage for and deactivate assignments in disabled units
--	7.06.7293	* tb_Option[38]->[31]
--	7.06.7279	* optimized logging
--	7.06.6796	+ removal from tb_UserUnit, tb_RoleUnit for inactive units
--	7.06.6017	+ re-activating shifts of re-activated unit, trace-logging
--	7.06.5934	+ tb_OptSys[38]
--	7.06.5854	* added "and l.tiLvl = 4" for unit deactivation
--				+ tbUnitMap[Cell], tbDvcUnit, tbTeamUnit clean-up for inactive units
--	7.06.5501	+ .sPath
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@tBeg		time( 0 )
		,		@sUnit		varchar( 16 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
--	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tBeg =		cast(tValue as time( 0 ))	from	dbo.tb_OptSys	with (nolock)	where	idOption = 31

	begin	tran

		-- update codes, levels and paths following parent-child relationship
		update	dbo.tbCfgLoc	set	sPath =	'0',	cLoc =	'H'
			where	idLoc = 0
		select	@iCount =	@@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'S',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	dbo.tbCfgLoc l
			join	dbo.tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'B',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	dbo.tbCfgLoc l
			join	dbo.tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'F',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	dbo.tbCfgLoc l
			join	dbo.tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'U',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	dbo.tbCfgLoc l
			join	dbo.tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'C',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	dbo.tbCfgLoc l
			join	dbo.tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		select	@s =	'Loc_SL( ) *' + cast(@iCount as varchar)

		-- deactivate non-matching units
		update	u	set	u.bActive=	0,	u.dtUpdated =	getdate( )
			from	dbo.tbUnit	u
			left join 	dbo.tbCfgLoc	l	on l.idLoc = u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1	and	l.idLoc is null
		select	@s =	@s + ', -' + cast(@@rowcount as varchar)

		-- deactivate shifts for inactive units
		update	s	set	s.bActive=	0,	s.dtUpdated =	getdate( )
			from	dbo.tbShift	s
			join	dbo.tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0
			where	s.bActive = 1
		select	@s =	@s + ' u, -' + cast(@@rowcount as varchar) + ' s'

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

		insert	#tbUnit
			select	idUnit	from	tbUnit	with (nolock)	where	bActive = 0

		-- remove items for inactive units									--	7.06.5854
--	-	delete	from	dbo.tbUnitMapCell									-- cascade
--	-		where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	dbo.tbUnitMap
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tbDvcUnit
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tbTeamUnit
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tb_UserUnit										--	7.06.6796
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tb_RoleUnit
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))

		-- finish coverage for assignments in disabled units
		update	dbo.tbStfCvrg	set	dtEnd=	getdate( ),		dEnd =	getdate( ),		tEnd =	getdate( )
			where	idStfCvrg	in	(select	idStfCvrg	from	dbo.vwStfAssn	where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock)))
			and		dtEnd is null

		-- deactivate these assignments
		update	dbo.tbStfAssn	set	idStfCvrg=	null
			where	idStfCvrg is not null	and	bActive = 0
			and		idStfAssn	in	(select	idStfAssn	from	dbo.vwStfAssn	where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock)))

		-- process current units
		declare	cur		cursor fast_forward for
			select	idLoc, sLoc
				from	dbo.tbCfgLoc	with (nolock)
				where	tiLvl = 4
				order	by	1

		open	cur
		fetch next from	cur	into	@idUnit, @sUnit
		while	@@fetch_status = 0
		begin
			-- upsert tbUnit to match tbCfgLoc
	--		if	exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
	--			update	tbUnit	set	bActive =	1,	sUnit=	@sUnit,		dtUpdated=	getdate( )
	--				where	idUnit = @idUnit
			update	dbo.tbUnit	set	sUnit=	@sUnit,		dtUpdated=	getdate( )
				where	idUnit = @idUnit
			if	@@rowcount > 0
			begin
				update	dbo.tbUnit	set	bActive =	1
					where	idUnit = @idUnit	and	bActive = 0
				if	@@rowcount > 0
				begin
					-- re-activate shifts for re-activated unit				--	7.06.6017
					update	dbo.tbShift		set	bActive =	1,	dtUpdated=	getdate( )
						where	idUnit = @idUnit	and	bActive = 0

					if	@tiLog & 0x02 > 0									--	Config?
--					if	@tiLog & 0x04 > 0									--	Debug?
--					if	@tiLog & 0x08 > 0									--	Trace?
					begin
						select	@s =	'Loc_SL( ) [' + cast(@idUnit as varchar) + '] *' + cast(@@rowcount as varchar) + ' s'
						exec	dbo.pr_Log_Ins	73, null, null, @s
					end
				end
			end
			else
			begin
				insert	dbo.tbUnit	(  idUnit,  sUnit, tiShifts, idShift )
						values		( @idUnit, @sUnit, 1, 0 )
				insert	dbo.tb_RoleUnit	( idRole, idUnit )
						values		( 2, @idUnit )
				insert	dbo.tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )	--	default to single 24hr-shift
						values		( @idUnit, 1, 'Shift 1', @tBeg, @tBeg )	--	7.06.5934	'07:00:00'
				select	@idShift =	scope_identity( )

				update	dbo.tbUnit	set	idShift =	@idShift
					where	idUnit = @idUnit
			end

			-- populate tbUnitMap
			if	not	exists	(select 1 from dbo.tbUnitMap where idUnit = @idUnit)
			begin
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
			end

			-- populate tbUnitMapCell
			if	not	exists	(select 1 from dbo.tbUnitMapCell where idUnit = @idUnit)
			begin
				select	@tiMap =	0
				while	@tiMap < 4
				begin
					select	@tiCell =	0
					while	@tiCell < 48
					begin
						insert	dbo.tbUnitMapCell	( idUnit, tiMap, tiCell )	values	( @idUnit, @tiMap, @tiCell )

						select	@tiCell =	@tiCell + 1
					end
					select	@tiMap =	@tiMap + 1
				end
			end

			fetch next from	cur	into	@idUnit, @sUnit
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
--	7.06.7464	+ reset tbRoom.tiCall when BadgeCall cancels
--	7.06.7447	* for prEvent_Ins to suppress !U for APP_FAIL, etc.: @idUnit= null
--	7.06.7422	+ @tiFlags to return state bits
--	7.06.7417	* optimized logging, suppress !U for APP_FAIL, etc.
--	7.06.7318	* remove 0-length 'rounding'
--	7.06.7307	+ 'rounding'
--	7.06.7279	* optimized logging
--	7.06.7265	* inlined 'update tbRoom.idUnit' (prRoom_UpdStaff is now only called on presence)
--	7.06.6767	* tb_LogType:	206 -> 210, 207 -> 211
--	7.06.6751	* optimized log (@iAID in hex)
--	7.06.6410	+ addressing xuEventA_Active_SGJRB errors
--	7.06.6402	* restore tbEvent_D.idShift, .dShift, .siBed, .tiBed
--	7.06.6373	* optimize trace logging
--				+ tbCfgPri.tiLvl, recording clinic calls to tbEvent_D
--	7.06.6297	* optimized
--	7.06.6051	* fix tbEvent_C.dShift calculation
--	7.06.6017	+ tbEvent_C.idShift, .dShift
--				* comment-out debug-trace
--	7.06.5865	* fix for call escalation
--	7.06.5665	* fix for 'presence': don't set tbEvent_C.idUser[i] to assigned staff
--	7.06.5647	* fix for 'presence' coming with tiBed==0x00
--	7.06.5613	* check @idUnit before inserting into tbEvent_C
--	7.06.5562	* tbEvent_C insertion: record any call with idRoom > 0
--	7.06.5534	* clear room state when there's no 'presence'
--	7.06.5529	* fix tbRoomBed.tiSvc fill: or tiBed = 0xFF
--	7.06.5492	* optimize @tiBed
--	7.06.5490	* optimize @idUnit
--	7.06.5487	* optimize
--	7.06.5483	* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--				* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--				* optimize error logging
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* prRoom_Upd -> prRoom_UpdStaff
--				* @sRn -> @sStaffG,	@sCn -> @sStaffO, @sAi -> @sStaffY
--				* tbEvent84:	.tiTmrSt -> .tiTmrA, .tiTmrRn -> .tiTmrG, .tiTmrCn -> .tiTmrO, .tiTmrAi -> .tiTmrY
--	7.06.5380	* use patient data only from bed-level calls
--	7.06.5330	+ tbEvent_C.siBed
--	7.06.5326	+ tbEvent_C.idAssn1|2|3
--	7.05.5274	+ out @idLogType
--	7.05.5267	* skip healing 84s
--				+ out @idEvent (idOrigin)
--	7.05.5212	* check @idRoom prior to insertion into tbEvent_C
--	7.05.5205	* prEvent_Ins args
--	7.05.5204	* tbLogType:	+ [194]		healing events are now explicitly marked
--	7.05.5147	* don't call prPatient_GetIns for presence calls
--	7.05.5101	+ @cGender, call prPatient_UpdLoc
--	7.05.5095	* fix tbEvent_C.idUser,
--				* do not set tbEvent.sInfo for presence calls
--	7.05.5074	* prPatient_GetIns:		+ @idDoctor
--	7.05.5066	* mark presence events, store tbEvent_C.idUser
--	7.05.4980	* @tiSrcBtn -> @tiBtn
--	7.05.4976	* origin search
--				- tbEvent_P, tbEvent_T
--	7.04.4972	* insert tbEvent_C: @idSrcDvc -> @idRoom, pass prev. call-idx into prEvent_Ins
--	7.04.4969	* no correct for devices
--	7.04.4955	* tbPatient.cGender retrieval from @sPatient
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--				* tbEvent_C:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt, .idRn -> .idEvtRn, .idCn -> .idEvtCn, .idAi -> .idEvtAi
--				* tbEvent_T:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--				* tbDefCall -> tbCall
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--				* tbDefCallP -> tbCfgPri
--	7.03	* prRoom_Upd: + @idUnit
--			+ tbEvent_A.tiCvrg[0..7] to cache values from tbEvent84
--			* fixed call [dbo.prPatient_GetIns] args (+ @sInfo)
--	7.02	* @tiTmrStat -> @tiTmrSt, @tiTmrCna -> @tiTmrCn, @tiTmrAide -> @tiTmrAi
--			* @sCna -> @sCn, @sAide -> @sAi
--			+ recording @sRn, @sCn, @sAi into tbRoom (via prRoom_Upd)
--			+ ignore @tiBed if [0x84] is 'presence'
--	7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ tbDevice.idEvent
--			+ extended expiration for picked calls
--			+ removal of healing events at once
--			+ (nolock)
--	6.04	* comment out prDefStaff_GetInsUpd call
--			now uses prPatient_GetIns, prDoctor_GetIns
--			* room-level calls will be marked for all room's beds in tbRoomBed
--			+ adjust tbEvent_A.dtEvent by @siElapsed - if call has started before
--			+ populating tbRoomBed, + new cache columns in tbEvent_A
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			upon cancellation defer removal of tbEvent_A and tbEvent_P rows
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--	6.02	tdDevice.dtLastUpd -> .dtUpdated
--			tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	6.00	tbDefDevice -> tbDevice (FKs)
--			tbEvent? -> tbEvent_? (A, C, P, T)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			@idLoc -> @idUnit
--	5.01	encryption added
--			+ tbEvent.idParent, + .tParent, code optimization, parent events
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			.idRn, .idCna, .idAide are in tbEventB4
--	4.02	+ @iAID, @tiStype; modified origination and added expiration
--	4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--			fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	2.03	+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbEventC.tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--			+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	2.02	+ tbEventC.idRn, .tRn, .idCna, .tCna, .idAide, .tAide (vwEventC, prEvent84_Ins?)
--	2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	1.08
--	1.00
alter proc		dbo.prEvent84_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint				-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@tiBtn		tinyint				-- button code
,	@siPriOld	smallint			-- old priority
,	@siPriNew	smallint			-- new priority
,	@siElapsed	smallint			-- elapsed time
,	@tiPrivacy	tinyint				-- privacy status
,	@tiTmrA		tinyint				-- STAT-need timer
,	@tiTmrG		tinyint				-- Grn-need timer
,	@tiTmrO		tinyint				-- Ora-need timer
,	@tiTmrY		tinyint				-- Yel-need timer
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
,	@sCall		varchar( 16 )		-- call text
,	@sPatient	varchar( 16 )		-- patient name
,	@cGender	char( 1 )			-- patient gender
,	@sDoctor	varchar( 16 )		-- doctor name
,	@sInfo		varchar( 32 )		-- info text
,	@sDial		varchar( 16 )		-- room dial number
,	@tiCvrg0	tinyint				-- coverage area 0
,	@tiCvrg1	tinyint				-- coverage area 1
,	@tiCvrg2	tinyint				-- coverage area 2
,	@tiCvrg3	tinyint				-- coverage area 3
,	@tiCvrg4	tinyint				-- coverage area 4
,	@tiCvrg5	tinyint				-- coverage area 5
,	@tiCvrg6	tinyint				-- coverage area 6
,	@tiCvrg7	tinyint				-- coverage area 7
,	@iFilter	int					-- call priority filter match bits
,	@siDuty0	smallint			-- duty area 0
,	@siDuty1	smallint			-- duty area 1
,	@siDuty2	smallint			-- duty area 2
,	@siDuty3	smallint			-- duty area 3
,	@siZone0	smallint			-- zone area 0
,	@siZone1	smallint			-- zone area 1
,	@siZone2	smallint			-- zone area 2
,	@siZone3	smallint			-- zone area 3
,	@cDstSys	char( 1 )			-- destination system
,	@tiDstGID	tinyint				-- destination G-ID - gateway
,	@tiDstJID	tinyint				-- destination J-ID - J-bus
,	@tiDstRID	tinyint				-- destination R-ID - R-bus
,	@idUnit		smallint			-- active unit ID
,	@iAID		int					-- device A-ID (24 bits)
,	@tiStype	tinyint				-- device type (1-255)
,	@sStaffG	varchar( 16 )		-- present Grn-staff
,	@sStaffO	varchar( 16 )		-- present Ora-staff
,	@sStaffY	varchar( 16 )		-- present Yel-staff

,	@idEvent	int			out		-- output: idOrigin of input event
,	@idLogType	tinyint		out
,	@tiFlags	tinyint		out		-- bitwise: 1=audio, 2=presence, 4=rounding, 8=failure
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@p			varchar( 16 )
		,		@idParent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idCall		smallint
		,		@idCall0	smallint
		,		@siBed		smallint
		,		@idShift	smallint
		,		@dShift		date
		,		@siIdxOld	smallint
		,		@siIdxNew	smallint
		,		@siIdxUg	smallint
		,		@idDoctor	int
		,		@idPatient	int
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@dtEvent	datetime
--		,		@tiFlags	tinyint
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiLvl		tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@bRounding	bit
		,		@bFailure	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int
		,		@idEvDup	int

	set	nocount	on

--	select	@tiLog =	tiLvl	from	tb_Module	with (nolock)	where	idModule = 1
	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bAudio =	0,	@bPresence =	0,	@bRounding =	0,	@bFailure=	0

	select	@s =	'E84_I( ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') +
					' /' + isnull(cast(@tiBtn as varchar),'?') +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					' ''' + isnull(@sDevice,'?') + ''''	-- + isnull(cast(@tiBed as varchar),'?')
	if	@tiBed < 10
		select	@s =	@s + ':' + cast(@tiBed as varchar)
	select	@s =	@s + ' #' + isnull(@sDial,'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') +
					', ' + isnull(cast(@siIdxOld as varchar),'?') + '-' + isnull(cast(@siIdxNew as varchar),'?') + '|' + isnull(@sCall,'?')	-- + ', i=''' + isnull(@sInfo,'?') +
	if	len(@sInfo) > 0
		select	@s =	@s + ', i=''' + @sInfo + ''''
	if	len(@cDstSys) > 0	or	@tiDstGID > 0	or	@tiDstJID > 0	or	@tiDstRID > 0
		select	@s =	@s + ', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' +
						isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiDstRID as varchar), 2),'?')	-- + ' )'
	select	@s =	@s + ' )'

--	if	@tiLog & 0x04 > 0													--	Debug?
--		exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins00'

/*	if	@idUnit < 259	or													-- lowest possible unit
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + ' !U'						-- invalid unit
*/

	if	@siIdxNew > 0														-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiFlags =	tiFlags,	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,		@siIdxUg =	siIdxUg
			from	tbCfgPri	with (nolock)
			where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew						-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0													-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiFlags =	tiFlags,	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,		@siIdxUg =	siIdxUg
			from	tbCfgPri	with (nolock)
			where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0													-- INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out					-- no need to call

--	if	@tiLog & 0x04 > 0													--	Debug?
--		exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins01'


	if	@tiSpec between 7 and 9
		select	@bPresence =	1,		@tiBed =	0xFF					-- mark 'presence' calls and force room-level
	else
	if	@tiSpec	in	(10,11,12,13,14,15,16,17, 20,21, 23,24,25,26,27)
		select	@bFailure =		1,		@idUnit =	null					-- mark 'failure' calls
	else
	if	@tiFlags & 0x08 > 0
		select	@bRounding =	1											-- mark 'rounding' calls

	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + ' !B'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	if	@bFailure = 0	and													--	7.06.7417
		(@idUnit < 259	or													-- lowest possible unit
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0))
		select	@idUnit =	null,	@p =	@p + ' !U'						-- invalid unit


	if	@tiBed is not null	and	len(@sPatient) > 0							-- only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
	end

--	if	@tiLog & 0x04 > 0													--	Debug?
--		exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins02'


	-- adjust need-timers (0=no need, 1=[G,O,Y] present, 2=need OT, 3=need request)
	if	@tiTmrA > 3		select	@tiTmrA =	3
	if	@tiTmrG > 3		select	@tiTmrG =	3
	if	@tiTmrO > 3		select	@tiTmrO =	3
	if	@tiTmrY > 3		select	@tiTmrY =	3


	-- origin points to the first still active event that started call-sequence for this SGJRB
	select	@idOrigin=	idEvent,	@dtOrigin=	dtEvent,	@bAudio =	bAudio
		from	tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0
			and	(siIdx = @siIdxNew	or	siIdx = @siIdxOld)					--	7.06.5855
		---	and	(idCall = @idCall	or	idCall = @idCall0)					--	7.05.4976

	select	@tiSvc =	@tiTmrA * 0x40 + @tiTmrG * 0x10 + @tiTmrO * 0x04 + @tiTmrY
		,	@idLogType =	case when	@idOrigin is null	then			-- call placed | presense-in
									case when	0 < @bPresence	then 210	else 191 end			--	7.06.6767
								when	@siIdxNew = 0		then			-- cancelled | presense-out
									case when	0 < @bPresence	then 211	else 193 end			--	7.06.6767
								else										-- escalated | healing
									case when	0 < @idCall0	then 192	else 194 end	end

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins03'

		if	@idEvent > 0
		begin
			insert	tbEvent84	( idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew
								,	tiTmrA,   tiTmrG,   tiTmrO,   tiTmrY,     idPatient,  idDoctor,  iFilter
								,	tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7
								,	siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
					values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew
								,	@tiTmrA,  @tiTmrG,  @tiTmrO,  @tiTmrY,    @idPatient, @idDoctor, @iFilter
								,	@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7
								,	@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3 )

			if	len(@p) > 0													-- invalid data detected (bed|unit)
			begin
				select	@s =	@s + ' ' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins04'

		update	tbRoom	set	idUnit =	@idUnit,	dtUpdated=	@dtEvent	--	7.06.7265
			where	idRoom = @idRoom	and	idUnit <> @idUnit

		if	@bPresence > 0													--	7.06.7265
			exec	dbo.prRoom_UpdStaff		@idRoom, @siIdxNew, @sStaffG, @sStaffO, @sStaffY	--, @idUnit

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins05'


		if	@idOrigin is null												-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss, @siElapsed, '0:0:0')
								,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent)
								,	@idSrcDvc=	idSrcDvc,	@idParent=	idParent
				where	idEvent = @idEvent

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins06'

			select		@idEvDup =	idEvent,	@siPriOld=	siIdx			-- addressing xuEventA_Active_SGJRB errors	--	7.06.6410
				from	tbEvent_A	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0

			if	@@rowcount > 0
			begin
				select	@s =	@s + ' dup=' + isnull(cast(@idEvDup as varchar),'?') + '! idx=' + isnull(cast(@siPriOld as varchar),'?')
				exec	dbo.pr_Log_Ins	82, null, null, @s

				--	what to do with current call ??
			end
			else
				insert	tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
										siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,							--,  tiLvl
										tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
						values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
										@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, @tiSvc, dateadd(ss, @iExpNrm, @dtEvent),	--, @tiLvl
										@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins07'

			if	@idRoom > 0		and	@idUnit > 0								-- record every call in tbEvent_C	--	7.06.5562, 7.06.5613
				begin
					select	@idUser =	case
								when @tiSpec = 7	then idUserG
								when @tiSpec = 8	then idUserO
								when @tiSpec = 9	then idUserY
								else					 null	end
						from	tbRoom	with (nolock)
						where	idRoom = @idRoom

					select	@idShift =	u.idShift							--	7.06.6017
						,	@dShift =	case when sh.tEnd <= sh.tBeg	and	cast(@dtOrigin as time) < sh.tEnd	then	dateadd( dd, -1, @dtOrigin )	else	@dtOrigin	end
	--	7.06.6051		,	@dShift =	case when sh.tBeg < sh.tEnd	then	@dtOrigin	else	dateadd( dd, -1, @dtOrigin )	end
						from	tbUnit	u
						join	tbShift	sh	on	sh.idShift = u.idShift
						where	u.idUnit = @idUnit	and	u.bActive > 0

					if	@tiLvl = 0											-- non-clinic call
					begin
						insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, idUser1, tiHH )
								values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, @idUser, datepart(hh, @dtOrigin) )

	--					if	@tiLog & 0x04 > 0								--	Debug?
	--						exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins08'

						if	@bRounding > 0
							insert	tbEvent_D	(  idEvent,  dEvent,    tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, tiHH )
									values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, datepart(hh, @dtOrigin) )
						else
						if	@bPresence = 0									--	7.06.5665
							update	c	set	c.idUser1=	rb.idUser1,		c.idUser2=	rb.idUser2,		c.idUser3=	rb.idUser3	--	7.06.5326
								from	tbEvent_C	c
								join	tbRoomBed	rb	on	rb.idRoom = @idRoom		and	( rb.tiBed = @tiBed		or	@tiBed is null	and	( rb.tiBed = 0xFF	or	rb.tiBed = 1 ) )
								where	c.idEvent = @idEvent
					end
					else
					if	@tiLvl = 2											-- clinic-patient
						insert	tbEvent_D	(  idEvent,  dEvent,    tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, tiHH )
								values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, datepart(hh, @dtOrigin) )
					else
					if	@tiLvl = 3											-- clinic-staff
						update	tbEvent_D	set	idEvntS =	@idEvent
							where	idEvent = @idParent		and	idEvntS is null
					else
					if	@tiLvl = 4											-- clinic-doctor
						update	tbEvent_D	set	idEvntD =	@idEvent
							where	idEvent = @idParent		and	idEvntD is null
				end

			select	@idOrigin=	@idEvent
		end

		else																-- active origin found	(=> call healed/escalated/cancelled)
		begin
			update	tbEvent		set	idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin,	@idParent=	idParent
				where	idEvent = @idEvent

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins09'

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	siIdx=	@siIdxNew,	idCall =	@idCall		--	7.06.5855
				where	idEvent = @idOrigin								--	7.05.5065

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins10'

			update	tbEvent_A	set	tiSvc=	@tiSvc							-- update state for all calls in this room
				where	idRoom = @idRoom								--	7.06.5534

			if	@tiLvl = 0	and	@bRounding > 0	and	@siIdxNew <> @siIdxOld	-- escalated to next stage
			begin
					update	tbEvent_D	set	idEvntS =	@idEvent,	tRoomS =	@dtEvent
						where	idEvent = @idOrigin		and	idEvntS is null
			end
			else

			if	0 < @tiLvl	and	0 < @siIdxNew	and	@siIdxNew <> @siIdxOld	and	@siIdxUg is null	-- escalated to last stage
			begin
				if	@tiLvl = 2												-- clinic-patient
					update	tbEvent_D	set	tWaitS =	@dtEvent - dEvent - tEvent
						where	idEvent = @idOrigin		and	tWaitS is null
				else
		--		if	@tiLvl = 3												-- clinic-staff
		--		else
				if	@tiLvl = 4												-- clinic-doctor
				begin
					update	ed	set	tWaitD =	@dtEvent - e.dtEvent
						from	tbEvent_D	ed
						join	tbEvent		e	with (nolock)	on	e.idEvent = ed.idEvntD
						where	ed.idEvent = @idParent	and	tWaitD is null

					update	tbEvent_D	set	idEvntD =	@idEvent
						where	idEvent = @idParent	--?	and	idEvntD is [not?] null
				end
			end
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins11'


		if	@siIdxNew = 0													-- call cancelled
		begin
			update	tbEvent_A	set	tiSvc=	null,	bActive =	0
								,	dtExpires=	dateadd(ss, case when @bAudio = 0 then @iExpNrm else @iExpExt end, @dtEvent)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins12'

			select	@dtOrigin=	tOrigin		--,	@idParent=	idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	tbEvent_C	set	idEvtSt =	@idEvent,	tStaff =	@dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null			-- there should be only one, but just in case - use only 1st one

			if	@tiLvl = 0	--and	@bRounding > 0
			begin
				if	@tiBtn < 3	and	@tiSrcRID = 0	and	@tiBed = 0			-- 0=G, 1=O, 2=Y BadgeCalls are room-level
					update	tbRoom	set	tiCall =	tiCall	&	case when	@tiBtn = 0	then	0xFB
																	when	@tiBtn = 1	then	0xFD
																						else	0xFE	end
						where	idRoom = @idRoom							--	7.06.7464

				update	tbEvent_D	set	tWaitS =	@dtEvent - dEvent - tRoomS
								,		idEvntD =	@idEvent
					where	idEvent = @idOrigin	--	and	tRoomS is not null

				delete	tbEvent_D
					where	idEvent = @idOrigin	and	idEvntD = idEvntS		-- remove 0-length rounding
			end
			else

			if	@tiLvl = 2	and	@siIdxUg is null							-- clinic-patient
				update	tbEvent_D	set	tRoomP =	@dtEvent - dEvent - tEvent
					where	idEvent = @idOrigin		and	tRoomP is null
			else
			if	@tiLvl = 3													-- clinic-staff
				update	ed	set	tRoomS =	@dtOrigin						-- == eo.tOrigin
					from	tbEvent		ee	with (nolock)
					join	tbEvent		eo	with (nolock)	on	eo.idEvent = ee.idOrigin
					join	tbEvent_D	ed					on	ed.idEvent = eo.idParent
					where	ee.idEvent = @idEvent	and	tRoomS is null
			else
			if	@tiLvl = 4													-- clinic-doctor
				update	ed	set	tRoomD =	@dtEvent - ep.dtEvent
					from	tbEvent		eo	with (nolock)
					join	tbEvent_D	ed					on	ed.idEvent = eo.idParent
					join	tbEvent		ep	with (nolock)	on	ep.idEvent = ed.idEvntD
					where	eo.idEvent = @idOrigin	and	tRoomD is null
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins13'


		-- only for 7947 (iBed):	if argument is a bed-level call
		if	@tiStype = 192	and	@tiBed is not null
			update	tbRoomBed	set	tiIbed=
									case when	@siIdxNew = 0	then	--	call cancelled
										tiIbed &
										case when	@tiBtn = 2	then 0xFE
											when	@tiBtn = 7	then 0xFD
											when	@tiBtn = 6	then 0xFB
											when	@tiBtn = 5	then 0xF7
											when	@tiBtn = 4	then 0xEF
											when	@tiBtn = 3	then 0xDF
											when	@tiBtn = 1	then 0xBF
											when	@tiBtn = 0	then 0x7F
											else					 0xFF	end
										else							--	call placed / being-healed
										tiIbed |
										case when	@tiBtn = 2	then 0x01
											when	@tiBtn = 7	then 0x02
											when	@tiBtn = 6	then 0x04
											when	@tiBtn = 5	then 0x08
											when	@tiBtn = 4	then 0x10
											when	@tiBtn = 3	then 0x20
											when	@tiBtn = 1	then 0x40
											when	@tiBtn = 0	then 0x80
											else					 0x00	end
										end
				where	idRoom = @idRoom	and	tiBed = @tiBed

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins14'


		---	!! @idEvent no longer points to current event !!

		-- set tbRoom.idEvent and .tiSvc to highest oldest active call for this room
		select	@idEvent =	null,	@tiSvc =	null
		select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent								-- oldest in recorded order
		---	order	by	siIdx desc, tElapsed desc							-- call may have started before it was recorded

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins15'

		update	tbRoom	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
			where	idRoom = @idRoom

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins16'

		-- clear room state when there's no 'presence'						--	7.06.5534
		if	@tiSvc is null	or	@tiSvc & 0x30 <> 0x10
			update	tbRoom	set	idUserG =	null,	sStaffG =	null	where	idRoom = @idRoom
--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins17'
		if	@tiSvc is null	or	@tiSvc & 0x0C <> 0x04
			update	tbRoom	set	idUserO =	null,	sStaffO =	null	where	idRoom = @idRoom
--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins18'
		if	@tiSvc is null	or	@tiSvc & 0x03 <> 0x01
			update	tbRoom	set	idUserY =	null,	sStaffY =	null	where	idRoom = @idRoom
--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins19'


		-- set tbRoomBed.idEvent and .tiSvc to highest oldest active call for this room-bed
		declare		cur		cursor fast_forward for
			select	tiBed
				from	tbRoomBed	with (nolock)
				where	idRoom = @idRoom

		open	cur
		fetch next from	cur	into	@tiBed
		while	@@fetch_status = 0
		begin
			select	@idEvent =	null,	@tiSvc =	null
			select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
				from	tbEvent_A	ea	with (nolock)
				where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
				order	by	siIdx desc, idEvent								-- oldest in recorded order - FASTER, more EFFICIENT
			---	order	by	siIdx desc, tElapsed desc						-- call may have started before it was recorded (no .tElapsed!)

			update	tbRoomBed	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
				where	idRoom = @idRoom	and	tiBed = @tiBed

			fetch next from	cur	into	@tiBed
		end
		close	cur
		deallocate	cur

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins20'

	commit

	select	@idEvent =	@idOrigin											--	7.05.5267	return idOrigin
		,	@tiFlags =	@bAudio + @bPresence * 2 + @bRounding * 4 + @bFailure * 8	--	7.06.7422
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
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
,	@idRoom		smallint					-- room look-up FK
,	@tiBed		tinyint						-- bed index FK
,	@tiShIdx	tinyint						-- shift index [1..3]
,	@tiIdx		tinyint						-- staff index [1..3]
,	@idUser		int							-- staff look-up FK
,	@bActive	bit							-- active?
--,	@cSys		char( 1 )		= null		-- corresponding to idRoom
--,	@tiGID		tinyint			= null
--,	@tiJID		tinyint			= null
--,	@sStaffID	varchar( 16 )	= null		-- corresponding to idUser
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sRoom		varchar( 16 )
		,		@sUser		varchar( 16 )
		,		@idShift	smallint

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

--	select	@idRoom =	idDevice	from	vwRoom		with (nolock)	where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID
	select	@idShift =	idShift		from	tbShift		with (nolock)	where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx
	select	@sRoom =	sDevice		from	tbDevice	with (nolock)	where	idDevice = @idRoom
	select	@sUser =	sUser		from	tb_User		with (nolock)	where	idUser = @idUser

/*	select	@idShift =	idShift												--	get corresponding shift
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

	select	@s =	'SA_Imp( [' + isnull(cast(@idStfAssn as varchar),'?') + '] ' +
					isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' + right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + ', ' +
					isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiShIdx as varchar),'?') + '=' + isnull(cast(@idShift as varchar),'?') + ', ' +
					isnull(cast(@tiIdx as varchar),'?') + ':' + @sStaffID + '=' + isnull(cast(@idUser as varchar),'?') + ' a=' +
					isnull(cast(@bActive as varchar),'?') + ' ) rm=' + isnull(cast(@idRoom as varchar),'?')
*/
	select	@s =	'SA( ' + isnull(cast(@idStfAssn as varchar),'?') + ', ' +
					isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiShIdx as varchar),'?') + '=' + isnull(cast(@idShift as varchar),'?') +
					', ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(cast(@sRoom as varchar),'?') + ':' + isnull(cast(@tiBed as varchar),'?') +
					', ' + isnull(cast(@tiIdx as varchar),'?') + ':' + isnull(cast(@idUser as varchar),'?') + '|' + isnull(cast(@sUser as varchar),'?') +
					' a=' + isnull(cast(@bActive as varchar),'?')

/*	if	@tiGID > 0
		select	@s =	@s + ', ' + isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) +
						'-' + right('00' + isnull(cast(@tiJID as varchar),'?'), 3)
	if	len(@sStaffID) > 0
		select	@s =	@s + ', st=[' + @sStaffID + ']'
*/
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
--	Inserts or updates a shift
--	7.06.7465	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5415	+ @idUser, logging, @idUser -> @idOper
--	7.06.4939	- .tiRouting
--	7.05.5172
alter proc		dbo.prShift_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idShift	smallint	out		-- null=new shift
,	@idUnit		smallint
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiNotify	tinyint				-- not null=set notify + bkup
,	@idOper		int					-- operand user, backup staff
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

	select	@s =	'Shft( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', nt=' + isnull(cast(@tiNotify as varchar),'?') + ' bk=' + isnull(cast(@idOper as varchar),'?') + ' a=' + isnull(cast(@bActive as varchar),'?') + ' )'
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
			if	@tiNotify is not null
				update	tbShift		set		dtUpdated=	getdate( ),	tiNotify =	@tiNotify,	idUser =	@idOper
					where	idShift = @idShift
			else	--	instead of:		if	@tBeg is not null
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
						exec	dbo.prStfAssn_Fin	@idStfAssn				--	finalize assignment

						fetch next from	cur	into	@idStfAssn
					end
					close	cur
					deallocate	cur
				end
			end

--			select	@s =	'Shft_U' + @s + ')'
			select	@k =	248
		end

		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62

	commit
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.7467	* logging: Trc -> Dbg
--	7.06.7292	* tb_Option[11]<->[19]
--	7.06.7276	* optimized tracing
--	7.06.7117	* optimized logging (- 23:59:59.990)
--	7.06.6022	* tb_Module[1].sParams updtate -> prStfCvrg_InsFin
--	7.06.5648	* fix for updating tb_OptSys[19].iValue
--	7.06.5638	* fix for updating tbEvent_C.idEvt??
--	7.06.5618	* fix for no tbEvent_S records (e.g. recent install + 7980)
--	7.06.5562	* tbEvent: .vbCmd -> tbEvent_B, .tiLen -> tbEvent_B
--	7.06.5490	* 'dat:','log:' -> 'D:','L:'
--	7.05.5169	* wipe tbEvent.vbCmd for events older than 60 days
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ reporting DB sizes in tb_Module[1].sParams
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prEvent_Maint
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@idEvent	int
		,		@iCount		int
		,		@tiPurge	tinyint			-- FF=keep everything
											-- N=remove auxiliary data older than N days (cascaded)
											-- 0=remove all inactive events from [tbEvent*] (cascaded)
	set	nocount	on

	select	@dt =	getdate( )												-- smalldatetime truncates seconds

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	ec	set	ec.idEvtVo =	null						-- implements CASCADE SET NULL
					from	tbEvent_C ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtVo
					where	a.idEvent is null

				update	ec	set	ec.idEvtSt =	null
					from	tbEvent_C ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtSt
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left join	tbEvent_A	a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@iCount =	@@rowcount

--				if	@tiLog & 0x02 > 0										--	Config?
				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
					if	0 < @iCount
					begin
						select	@s =	'Ev_M( ' + cast(@tiPurge as varchar) + ' ) -' + cast(@iCount as varchar) +
										' in ' + convert(varchar, getdate() - @dt, 114)
	--					exec	dbo.pr_Log_Ins	1, null, null, @s			--	7.06.7276	trace is enough
						exec	dbo.pr_Log_Ins	0, null, null, @s			--	7.06.7467	debug
					end
			end

			select	@idEvent =	max(idEvent)								-- get latest idEvent to be removed
				from	tbEvent_S
				where	dEvent <= dateadd(dd, -@tiPurge, @dt)
				and		tiHH <= datepart(hh, @dt)

			if	@idEvent is null											--	7.06.5618
				select	@idEvent =	min(idEvent)							-- get earliest idEvent to stay
					from	tbEvent_S
					where	dateadd(dd, -@tiPurge, @dt) < dEvent

			if	0 < @idEvent												--	7.06.5648
			begin
				delete	from	tbEvent_B
					where	idEvent < @idEvent

				update	tb_OptSys	set	iValue =	@idEvent,	dtUpdated=	@dt		where	idOption = 11
			end

		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates given module's license bit
--	7.06.7467	* optimized logic
--	7.06.6345	+ @idModule logging (pr_Log_Ins call)
--	7.06.5598
alter proc		dbo.pr_Module_Lic
(
	@idModule	tinyint
,	@bLicense	bit
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@s =	'Mod_Lic( ' + right('00' + cast(@idModule as varchar), 3) + ', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'

	begin	tran

/*		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule and bLicense <> @bLicense)
		begin
			update	tb_Module	set	bLicense =	@bLicense
				where	idModule = @idModule

			exec	dbo.pr_Log_Ins	63, null, null, @s, @idModule
		end
*/		update	tb_Module	set	bLicense =	@bLicense
			where	idModule = @idModule	and	bLicense <> @bLicense

		if	@@rowcount > 0
			exec	dbo.pr_Log_Ins	63, null, null, @s, @idModule

	commit
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7467 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7467, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2020-06-11',	dtInstall=	getdate( )
		,	sVersion =	'*798?cs, *7981ls, *798?rh, *7980ns, *7981cw, *7980cw, *7985cw, *7982cw, *7986cw'
		where	siBuild = 7467

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7467'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, 7.6.7467 )'
commit
go

checkpoint
go

use [master]
go