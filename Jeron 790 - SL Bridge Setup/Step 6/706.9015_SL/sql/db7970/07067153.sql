--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2019-Jul-09		.7129
--						* tb_LogType:	+[100-103]		(pr_User_InsUpdAD)
--		2019-Jul-11		.7131
--						* pr_Module_Upd
--		2019-Jul-18		.7138
--						* tb_LogType[46]
--		2019-Jul-22		.7142
--						* tb_LogType[228]
--						* pr_User_Logout
--		2019-Jul-26		.7146
--						- vwRtlsRoom
--						* tb_LogType[41,42,44,48]
--		2019-Aug-02		.7153
--						release
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7153 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7153', 18, 0 )
go


--	----------------------------------------------------------------------------
--	7.06.7129	+ [100-103]
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 100)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiCat, sLogType )	values	( 100,	16,	8,	'AD operation' )			--	7.06.7128
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiCat, sLogType )	values	( 101,	8,	8,	'AD skipped' )				--	7.06.7128
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiCat, sLogType )	values	( 102,	8,	8,	'AD insert' )				--	7.06.7128
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiCat, sLogType )	values	( 103,	8,	8,	'AD update' )				--	7.06.7128
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRtlsRoom')
	drop view	dbo.vwRtlsRoom
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
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
	@idUser		int					-- user, performing the action
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
			,	@s	varchar( 255 )
			,	@utSynched	smalldatetime		-- (UTC) time of last AD-Sync

	set	nocount	on
	set	xact_abort	on

	select	@idOper =	idUser,		@utSynched =	utSynched
		from	tb_User with (nolock)
		where	gGUID = @gGUID

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '] ut=' + isnull(convert(varchar, @utSynched, 120), '?') +
				', ' + isnull(upper(cast(@gGUID as char(38))), '?') + ', u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", k=' + cast(@tiFails as varchar) + ', a?=' + cast(@bActive as varchar) + ', ad=' + isnull(convert(varchar, @dtUpdated, 120), '?')
	begin	tran

		if	@idOper = 0		or	@idOper is null								-- user not found
		begin
			if	0 < @bActive												--	7.06.7094	only import *active* users!
			begin
				insert	tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
						values	( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
				select	@idOper =	scope_identity( )

				select	@s =	'User_ADI( ' + @s + ' ) = ' + cast(@idOper as varchar)
					,	@k =	102		--	237								--	7.06.7129
			end
			else															--	7.06.7094
				select	@s =	'User_ADI( ' + @s + ' ) ^'
					,	@k =	101		--	2			-- info				--	7.06.7129
		end
		else
		if	@utSynched < @dtUpdated											-- AD had a recent change
		begin
			update	tb_User	set		sUser =		@sUser,		sFrst=	@sFrst,		sMidd=	@sMidd,		sLast=	@sLast
								,	sEmail =	@sEmail,	sDesc=	@sDesc,		utSynched=	getutcdate( )
								,	tiFails =	case when	@tiFails = 0xFF	then	@tiFails
													when	tiFails = 0xFF	then	0
													else	tiFails		end
								,	bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'User_ADU( ' + @s + ' ) *'
				,	@k =	103		--	238									--	7.06.7129
		end
		else																-- user already up-to date
		begin
			update	tb_User	set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'User_AD( ' + @s + ' )'
				,	@k =	103		--	238									--	7.06.7129

		end
		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s

		if	101 < @k														--	7.06.7094/79129	only import *active* users!
			-- enforce membership in 'Public' role
			if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
				insert	tb_UserRole	( idRole, idUser )
						values		( 1, @idOper )

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
--	7.06.7131	* sInfo( 32 ) -> @sInfo( 64 )
--	7.06.7027	+ .iPID
--	7.06.6306	+ @idModule logging (pr_Log_Ins call)
--	7.06.5843	* sParams= null on stop
--	7.06.5632	+ @sIpAddr, @sMachine
--	7.06.5423	- @dtStart (automatic now)
--				* @sModInfo( 32 ) -> @sInfo( 32 )
--	7.06.5395	* @dtStarted -> @dtStart
--	7.05.5205	* prEvent_Ins args
--	7.05.5105	* tbEvent.sInfo format is now .sModule + ' v.' + .sVersion
--	7.05.5065	* tb_Module.dtStarted -> .dtStart
--	7.05.5059	* tb_Module.dtStart -> .dtStarted, @dtStart -> @dtStarted
--	7.03	* .dtLastAct update
--	7.00	@sModInfo format changed (removed build d/t)
--	6.04	* optimize tbEvent record with tb_Module.sVersion and .sDesc
--	6.03
alter proc		dbo.pr_Module_Upd
(
	@idModule	tinyint
,	@sInfo		varchar( 64 )		-- module info, gets logged (e.g. 'J79???? v.M.mm.bbbb @machine/IP-address')
,	@iPID		int					-- Windows PID when running
,	@idLogType	tinyint				-- type look-up FK (marks significant events only)
,	@sParams	varchar( 255 )		-- startup arguments/parameters
,	@sIpAddr	varchar( 40 )
,	@sMachine	varchar( 32 )
)
	with encryption
as
begin
	declare		@idEvent	int
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		if	@idLogType = 38		-- SvcStarted
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		iPID =	@iPID,	dtStart =	getdate( ),		sParams =	@sParams,	sIpAddr =	@sIpAddr,	sMachine =	@sMachine
				where	idModule = @idModule
		else
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		iPID =	null,	dtStart =	null,			sParams =	null
				where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sInfo, @idModule

		exec	dbo.prEvent_Ins		0, null, null, null		---	@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	null, null, null, null, null, @sInfo	---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7146	* [41,42,44,48].tiLvl:	8 -> 16
--	7.06.7142	* [228].tiLvl:	32 -> 64
--	7.06.7138	* [46].tiLvl:	8 -> 16
begin
	begin tran
--		update	dbo.tb_LogType	set	tiLvl=	16		where	idLogType = 46
		update	dbo.tb_LogType	set	tiLvl=	16		where	idLogType in (41,42,44,46,48)
		update	dbo.tb_LogType	set	tiLvl=	64		where	idLogType = 228
	commit
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
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
		,		@idModule	tinyint
		,		@idUser		int
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )
		,		@dtCreated	datetime

	set	nocount	on

	select	@idUser =	idUser,		@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule,	@dtCreated =	dtCreated
		from	tb_Sess
		where	idSess = @idSess

	if	@idUser > 0
	begin
		begin	tran

			update	tb_Sess		set	dtLastAct=	getdate( ),	idUser =	null
				where	idSess = @idSess

			select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ') ' + isnull(convert(varchar, @dtCreated, 121), '?') +
							' [' + isnull(cast(datediff(dd, @dtCreated, getdate( )) as varchar), '?') + 'd ' + isnull(convert(varchar, getdate( )-@dtCreated, 114), '?') + ']'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
	end
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7153 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7153, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2019-08-02',	dtInstall=	getdate( )
		,	sVersion =	'*7980ns, *7987ca, *798?rh, *7983ls, *798?cs, +7983ds'
		where	siBuild = 7153

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7153'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.7153 )'
commit
go

checkpoint
go

use [master]
go