--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2018-Aug-09		.6795
--						* pr_User_GetAll, pr_Role_GetAll
--		2018-Aug-10		.6796
--						* prCfgLoc_SetLvl
--		2018-Aug-17		.6803
--						* prUnit_GetAll
--		2018-Aug-20		.6806
--						* pr_User_InsUpdAD
--		2018-Aug-21		.6807
--						* pr_Role_GetUnits
--						- pr_UserRole_GetByRole (-> pr_Role_GetUsers), pr_UserRole_GetByUser (-> pr_User_GetRoles), prTeamUser_Get (-> prTeam_GetUsers)
--						+ pr_Role_GetUsers, pr_User_GetRoles, pr_User_GetUnits, pr_User_GetTeams, prDvc_GetUnits, prDvc_GetTeams, prTeam_GetCalls, prTeam_GetUnits, prTeam_GetUsers
--		2018-Aug-22		.6808
--						- pr_UserRole_GetByUser, pr_UserRole_GetByRole
--						* prTeamUser_Get -> prTeam_GetUsers
--						+ tb_Option[40], tb_OptSys[40]
--		2018-Aug-23		.6809
--						* prStaff_GetByUnit
--		2018-Aug-28		.6814
--						- prTeamPri_InsDel
--						* tbTeamPri -> tbTeamCall	(prTeam_GetCalls, [prTeamPri_InsDel -> prTeamCall_InsDel], prTeam_InsUpd, prTeam_GetByUnitPri)
--						- tb_User.sTeams, .sUnits	(pr_User_GetAll, pr_User_Imp, vwStaff)
--						- tbTeam.sCalls, .sUnits	(prTeam_GetByUnit, prTeam_GetByUnitPri)
--						- tbDvc.sTeams, .sUnits		(vwDvc, prDvc_Exp, prDvc_Imp, prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi)
--						* pr_Role_InsUpd, pr_User_InsUpd, prTeam_InsUpd, prDvc_InsUpd
--		2018-Aug-29		.6815
--						+ tbDvc.sBrowser	(vwDvc, prDvc_Exp, prDvc_Imp, prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi, prDvc_RegWiFi)
--		2018-Aug-30		.6816
--						* prStfAssn_Exp
--						- pr_UserRole_InsDel
--						* tbDvcTeam -> tbTeamDvc	(prDvc_GetTeams, prTeam_GetDvcs, prDvc_InsUpd)
--						* pr_RoleUnit_Exp, pr_UserRole_Exp
--						+ pr_UserUnit_Exp, pr_UserUnit_Imp
--						+ prTeamUnit_Exp, prTeamUnit_Imp, prTeamUser_Exp, prTeamUser_Imp, prTeamCall_Exp, prTeamCall_Imp, prTeamDvc_Exp, prTeamDvc_Imp
--						+ prDvcUnit_Exp, prDvcUnit_Imp
--		2018-Aug-31		.6817
--						* prUnit_GetAll, pr_Role_GetUnits, pr_Role_GetUsers, pr_User_GetRoles, pr_User_GetUnits, pr_User_GetTeams, prDvc_GetUnits, prTeam_GetUnits, prTeam_GetUsers
--						+ prTeam_Exp, prTeam_Imp
--		2018-Sep-05		.6822
--						* prEvent84_Ins (fix for .6767)
--		2018-Sep-05		.6824
--						release
--		2018-Nov-19		.6897
--						* build # bump for HASP-wrapping
--						release
--		2019-Jan-17		.6956
--						removal of .sUnits (line #1345) moved into exec('..') to be re-appliable for earlier builds
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 6897 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.6897', 18, 0 )
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_Exp')
	drop proc	dbo.prTeam_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_Imp')
	drop proc	dbo.prTeam_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_AccUnit_Set')
	drop proc	dbo.pr_AccUnit_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Set')
	drop proc	dbo.pr_UserUnit_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_GetByRole')
	drop proc	dbo.pr_UserRole_GetByRole
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_GetByUser')
	drop proc	dbo.pr_UserRole_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUser_Get')
	drop proc	dbo.prTeamUser_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamPri_InsDel')
	drop proc	dbo.prTeamPri_InsDel
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetUsers')
	drop proc	dbo.prTeam_GetUsers
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetUnits')
	drop proc	dbo.prTeam_GetUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetCalls')
	drop proc	dbo.prTeam_GetCalls
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetTeams')
	drop proc	dbo.prDvc_GetTeams
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetUnits')
	drop proc	dbo.prDvc_GetUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetTeams')
	drop proc	dbo.pr_User_GetTeams
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetUnits')
	drop proc	dbo.pr_User_GetUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetRoles')
	drop proc	dbo.pr_User_GetRoles
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetUsers')
	drop proc	dbo.pr_Role_GetUsers
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@iTrace		int
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
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiLvl		tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int
		,		@idEvDup	int

	set	nocount	on

	select	@iTrace =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bPresence =	0

	select	@s =	'E84_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins00'

	if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + ' !U'						-- invalid unit


	if	@siIdxNew > 0														-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,	@siIdxUg =	siIdxUg		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew						-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0													-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,	@siIdxUg =	siIdxUg		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0													-- INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out					-- no need to call

--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins01'


	if	@tiSpec between 7 and 9
		select	@bPresence =	1,		@tiBed =	0xFF					-- mark 'presence' calls and force room-level


	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + ' !B'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed


	if	@tiBed is not null	and	len(@sPatient) > 0							-- only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
	end

--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins02'


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
									case when	@bPresence > 0	then 210	else 191 end			--	7.06.6767
								when	@siIdxNew = 0		then			-- cancelled | presense-out
									case when	@bPresence > 0	then 211	else 193 end			--	7.06.6767
								else										-- escalated | healing
									case when	@idCall0 > 0	then 192	else 194 end	end

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins03'

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
				select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins04'

		exec	dbo.prRoom_UpdStaff		@idRoom, @idUnit, @sStaffG, @sStaffO, @sStaffY

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins05'


		if	@idOrigin is null												-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss, @siElapsed, '0:0:0')
								,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent)
								,	@idSrcDvc=	idSrcDvc,	@idParent=	idParent
				where	idEvent = @idEvent

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins06'

			select		@idEvDup =	idEvent,	@siPriOld=	siIdx			-- addressing xuEventA_Active_SGJRB errors	--	7.06.6410
				from	tbEvent_A	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0

			if	@@rowcount > 0
			begin
				select	@s =	@s + '  dup=' + isnull(cast(@idEvDup as varchar),'?') + '! idx=' + isnull(cast(@siPriOld as varchar),'?')
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

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins07'

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

	--					if	@iTrace & 0x4000 > 0
	--						exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins08'

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

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins09'

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	siIdx=	@siIdxNew,	idCall =	@idCall		--	7.06.5855
				where	idEvent = @idOrigin								--	7.05.5065

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins10'

			update	tbEvent_A	set	tiSvc=	@tiSvc							-- update state for all calls in this room
				where	idRoom = @idRoom								--	7.06.5534

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
						where	idEvent = @idParent	--?	and	idEvDoc is [not?] null
				end
			end
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins11'


		if	@siIdxNew = 0													-- call cancelled
		begin
			update	tbEvent_A	set	tiSvc=	null,	bActive =	0
								,	dtExpires=	dateadd(ss, case when @bAudio = 0 then @iExpNrm else @iExpExt end, @dtEvent)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins12'

			select	@dtOrigin=	tOrigin		--,	@idParent=	idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	tbEvent_C	set	idEvtSt =	@idEvent,	tStaff =	@dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null			-- there should be only one, but just in case - use only 1st one

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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins13'


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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins14'


		---	!! @idEvent no longer points to current event !!

		-- set tbRoom.idEvent and .tiSvc to highest oldest active call for this room
		select	@idEvent =	null,	@tiSvc =	null
		select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent								-- oldest in recorded order
		---	order	by	siIdx desc, tElapsed desc							-- call may have started before it was recorded

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins15'

		update	tbRoom	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
			where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins16'

		-- clear room state when there's no 'presence'						--	7.06.5534
		if	@tiSvc is null	or	@tiSvc & 0x30 <> 0x10
			update	tbRoom	set	idUserG =	null,	sStaffG =	null	where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins17'

		if	@tiSvc is null	or	@tiSvc & 0x0C <> 0x04
			update	tbRoom	set	idUserO =	null,	sStaffO =	null	where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins18'

		if	@tiSvc is null	or	@tiSvc & 0x03 <> 0x01
			update	tbRoom	set	idUserY =	null,	sStaffY =	null	where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins19'


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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins20'

	commit

	select	@idEvent =	@idOrigin			--	7.05.5267	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	Returns details for all roles
--	7.06.6795	+ @idUnit
--	7.05.5234
alter proc		dbo.pr_Role_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUnit		smallint	= null	-- null=any
)
	with encryption
as
begin
--	set	nocount	on
	select	idRole, sRole, sDesc, bActive, dtCreated, dtUpdated
		from	tb_Role		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
	--	and		idRole > 15													--	protect internal accounts
		and		(@idUnit is null	or	idRole in (select idRole	from	tb_RoleUnit	with (nolock)	where	idUnit = @idUnit))
end
go
--	----------------------------------------------------------------------------
--	reset tb_UserUnit, tb_RoleUnit, tbTeamUnit for all inactive units
begin tran
	delete	from	tb_UserUnit
		where	idUnit	in	(select idUnit from tbUnit where bActive = 0)

	delete	from	tb_RoleUnit
		where	idUnit	in	(select idUnit from tbUnit where bActive = 0)

	delete	from	tbTeamUnit
		where	idUnit	in	(select idUnit from tbUnit where bActive = 0)
commit
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
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
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@tBeg		time( 0 )
		,		@sUnit		varchar( 16 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@tBeg =		cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 38

	begin	tran

		-- update codes, levels and paths following parent-child relationship
		update	tbCfgLoc	set	sPath =	'0',	cLoc =	'H'
			where	idLoc = 0
		select	@iCount =	@@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'S',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'B',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'F',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'U',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'C',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_SL( ) ' + cast(@iCount as varchar) + ' rows'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		-- deactivate non-matching units
		update	u	set	u.bActive=	0,	u.dtUpdated =	getdate( )
			from	tbUnit	u
			left join 	tbCfgLoc	l	on l.idLoc = u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1	and	l.idLoc is null
		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_SL( ) -' + cast(@@rowcount as varchar) + ' unit(s)'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		-- deactivate shifts for inactive units
		update	s	set	s.bActive=	0,	s.dtUpdated =	getdate( )
			from	tbShift	s
			join	tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0
		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_SL( ) -' + cast(@@rowcount as varchar) + ' shift(s)'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		-- remove items for inactive units									--	7.06.5854
--		delete	from	tbUnitMapCell										-- cascade
--			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbUnitMap
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbDvcUnit
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbTeamUnit
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tb_UserUnit											--	7.06.6796
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tb_RoleUnit
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)

		declare	cur		cursor fast_forward for
			select	idLoc, sLoc
				from	tbCfgLoc
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
			update	tbUnit	set	sUnit=	@sUnit,		dtUpdated=	getdate( )
				where	idUnit = @idUnit
			if	@@rowcount > 0
			begin
				update	tbUnit	set	bActive =	1
					where	idUnit = @idUnit	and	bActive = 0
				if	@@rowcount > 0
				begin
					-- re-activate shifts for re-activated unit				--	7.06.6017
					update	tbShift		set	bActive =	1,	dtUpdated=	getdate( )
						where	idUnit = @idUnit	and	bActive = 0

					if	@iTrace & 0x02 > 0
					begin
						select	@s= 'Loc_SL( ) [' + cast(@idUnit as varchar) + ']: *' + cast(@@rowcount as varchar) + ' shift(s)'
						exec	dbo.pr_Log_Ins	73, null, null, @s
					end
				end
			end
			else
			begin
				insert	tbUnit	(  idUnit,  sUnit, tiShifts, idShift )
						values	( @idUnit, @sUnit, 1, 0 )
				insert	tb_RoleUnit	( idRole, idUnit )
						values		( 2, @idUnit )
				insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )			--	default to single 24hr-shift
						values	( @idUnit, 1, 'Shift 1', @tBeg, @tBeg )			--	7.06.5934	'07:00:00'
				select	@idShift =	scope_identity( )

				update	tbUnit	set	idShift =	@idShift
					where	idUnit = @idUnit
			end

			-- populate tbUnitMap
			if	not	exists	(select 1 from tbUnitMap where idUnit = @idUnit)
			begin
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
			end

			-- populate tbUnitMapCell
			if	not	exists	(select 1 from tbUnitMapCell where idUnit = @idUnit)
			begin
				select	@tiMap =	0
				while	@tiMap < 4
				begin
					select	@tiCell =	0
					while	@tiCell < 48
					begin
						insert	tbUnitMapCell	( idUnit, tiMap, tiCell )	values	( @idUnit, @tiMap, @tiCell )

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
--	Returns units, accessible by the given user (via his roles)
--	7.06.6817	* order by sUnit	(revert)
--	7.06.6803	* order by idUnit
--	7.06.5567	+ @idUnit, @sUnits
--	7.06.5401	* merged prUnit_GetByUser -> prUnit_GetAll
--	7.06.5399	* optimized
--	7.06.5385	* optimized
--	7.05.5253	* ?
--	7.05.5043
alter proc		dbo.prUnit_GetAll
(
	@idUnit		int			= null	-- null=any
,	@idUser		int			= null	-- null=any
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@sUnits		varchar( 255 )=null	-- comma-separated idUnit-s, '*' or null=all
)
	with encryption
as
begin
	set	nocount	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	set	nocount	off
	select	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtCreated, u.dtUpdated
		from	tbUnit	u	with (nolock)
		join	tbShift	s	with (nolock)	on	s.idShift = u.idShift
		where	(@bActive is null	or	u.bActive = @bActive)
		and		(@idUser is null	or	u.idUnit in (select	idUnit
					from	tb_RoleUnit	ru	with (nolock)
					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		or		(@idUnit > 0		and	u.idUnit = @idUnit)
		or		(len(@sUnits) > 0	and	u.idUnit in (select idUnit from #tbUnit	with (nolock)))
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
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
			insert	tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
					values	( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
			select	@idOper =	scope_identity( )

			select	@s =	'User_IAD( ' + @s + ' ) = ' + cast(@idOper as varchar)
				,	@k =	237
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

			select	@s =	'User_UAD( ' + @s + ' ) *'
				,	@k =	238
		end
		else																-- user already up-to date
		begin
			update	tb_User	set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'User_AD( ' + @s + ' )'
				,	@k =	238

		end
		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s

		-- enforce membership in 'Public' role
		if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
			insert	tb_UserRole	( idRole, idUser )
					values		( 1, @idOper )

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6814	* tbTeamPri -> tbTeamCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='xpTeamPri')
begin
	begin tran
		exec sp_rename 'dbo.xpTeamPri',				'xpTeamCall'
		exec sp_rename 'dbo.fkTeamPri_Team',		'fkTeamCall_Team'
		exec sp_rename 'dbo.tdTeamPri_Created',		'tdTeamCall_Created'
		exec sp_rename 'dbo.tbTeamPri',				'tbTeamCall'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns units for a given role
--	7.06.6817	+ order by 2
--	7.06.6807	+ .sUnit
--	7.05.5234
alter proc		dbo.pr_Role_GetUnits
(
	@idRole		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	tb_RoleUnit	m	with (nolock)
		join	tbUnit		u	with (nolock)	on	u.idUnit = m.idUnit
		where	idRole = @idRole
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Returns users for a given role
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.pr_Role_GetUsers
(
	@idRole		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUser, t.sStaff
		from	tb_UserRole	m	with (nolock)
		join	tb_User		t	with (nolock)	on	t.idUser = m.idUser
		where	idRole = @idRole
		and		m.idUser > 1												--	protect 'sysadm' account
--	-	and		m.idUser > 15												--	protect internal accounts
		order	by	2
end
go
grant	execute				on dbo.pr_Role_GetUsers				to [rWriter]
grant	execute				on dbo.pr_Role_GetUsers				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns roles for a given user
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.pr_User_GetRoles
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idRole, t.sRole
		from	tb_UserRole	m	with (nolock)
		join	tb_Role		t	with (nolock)	on	t.idRole = m.idRole
		where	idUser = @idUser
		order	by	2
end
go
grant	execute				on dbo.pr_User_GetRoles				to [rWriter]
grant	execute				on dbo.pr_User_GetRoles				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns units for a given user
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.pr_User_GetUnits
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	tb_UserUnit	m	with (nolock)
		join	tbUnit		u	with (nolock)	on	u.idUnit = m.idUnit
		where	idUser = @idUser
		order	by	2
end
go
grant	execute				on dbo.pr_User_GetUnits				to [rWriter]
grant	execute				on dbo.pr_User_GetUnits				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns teams for a given user
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.pr_User_GetTeams
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idTeam, t.sTeam
		from	tbTeamUser	m	with (nolock)
		join	tbTeam		t	with (nolock)	on	t.idTeam = m.idTeam
		where	idUser = @idUser
		order	by	2
end
go
grant	execute				on dbo.pr_User_GetTeams				to [rWriter]
grant	execute				on dbo.pr_User_GetTeams				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns units for a given device
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.prDvc_GetUnits
(
	@idDvc		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	tbDvcUnit	m	with (nolock)
		join	tbUnit		u	with (nolock)	on	u.idUnit = m.idUnit
		where	idDvc = @idDvc
		order	by	2
end
go
grant	execute				on dbo.prDvc_GetUnits				to [rWriter]
grant	execute				on dbo.prDvc_GetUnits				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns calls for a given team
--	7.06.6814	* tbTeamPri -> tbTeamCall
--	7.06.6807
create proc		dbo.prTeam_GetCalls
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.siIdx, c.sCall
		from	tbTeamCall	m	with (nolock)
		join	tbCfgPri	c	with (nolock)	on	c.siIdx = m.siIdx
		where	idTeam = @idTeam
		order	by	1	desc
end
go
grant	execute				on dbo.prTeam_GetCalls				to [rWriter]
grant	execute				on dbo.prTeam_GetCalls				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns units for a given team
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.prTeam_GetUnits
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	tbTeamUnit	m	with (nolock)
		join	tbUnit		u	with (nolock)	on	u.idUnit = m.idUnit
		where	idTeam = @idTeam
		order	by	2
end
go
grant	execute				on dbo.prTeam_GetUnits				to [rWriter]
grant	execute				on dbo.prTeam_GetUnits				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns users for a given team
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.prTeam_GetUsers
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUser, t.sStaff
		from	tbTeamUser	m	with (nolock)
		join	tb_User		t	with (nolock)	on	t.idUser = m.idUser
		where	idTeam = @idTeam
		order	by	2
end
go
grant	execute				on dbo.prTeam_GetUsers				to [rWriter]
grant	execute				on dbo.prTeam_GetUsers				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.6808	* [62,11] Units->Shifts
begin tran
	update	dbo.tb_Feature	set	sFeature =	'Administration - Shifts'	where	idModule = 62	and	idFeature = 11

	update	dbo.tb_User		set	sUser =		'_sysadm_'			where	idUser <> 1	and	sUser = 'sysadm'

	update	dbo.tb_User		set	sUser =		'sysadm'			where	idUser = 1
	update	dbo.tb_User		set	sStaff =	'Facility Admin'	where	idUser = 2
commit
go
--	----------------------------------------------------------------------------
--	7.06.6808	+ [40]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 40)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 40,  56, 'Data refresh interval' )					--	7.06.6808
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 40, 15 )
	end
commit
go
--	----------------------------------------------------------------------------
--	Returns available staff for given unit(s)
--	7.06.6809	+ .idWi_Fi, .sWi_Fi
--	7.06.5429	+ .dtDue
--	7.06.5333	* tbDvcType[3] -> [4]
--	7.05.5246	* order by sStaffID ->	idStfLvl desc, sStaff
--	7.05.5154
alter proc		dbo.prStaff_GetByUnit
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit's, '*'=all or null
,	@idStfLvl	tinyint		= null	-- null=any, 1=Yel, 2=Ora, 4=Grn
,	@bOnDuty	bit			= null	-- null=any, 0=off, 1=on
)
	with encryption
as
begin
	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

--	set	nocount	on
	select	st.idUser, st.idStfLvl, st.sStaffID, st.sStaff, st.bOnDuty, st.dtDue
		,	st.idRoom,	r.sQnDevice as	sQnRoom
	--	,	st.sStfLvl, st.iColorB, st.sFqStaff, st.sUnits, st.sTeams
	--	,	st.bActive, st.dtCreated, st.dtUpdated
	--	,	bd.idDvc as idBadge,	bd.sDial as sBadge
		,	pg.idDvc as idPager,	pg.sDial as sPager
		,	ph.idDvc as idPhone,	ph.sDial as sPhone
		,	wf.idDvc as idWi_Fi,	wf.sDial as sWi_Fi
		from	vwStaff	st	with (nolock)
		left join	vwRoom	r	with (nolock)	on	r.idDevice = st.idRoom
	--	left join	tbDvc	bd	with (nolock)	on	bd.idUser = st.idUser	and	bd.idDvcType = 1	and	bd.bActive > 0
		left join	tbDvc	pg	with (nolock)	on	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
		left join	tbDvc	ph	with (nolock)	on	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
		left join	tbDvc	wf	with (nolock)	on	wf.idUser = st.idUser	and	wf.idDvcType = 8	and	wf.bActive > 0
		where	st.bActive > 0
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@bOnDuty is null	or	st.bOnDuty = @bOnDuty)
		and		st.idUser in (select	idUser
			from	tb_UserUnit	uu	with (nolock)
			join	#tbUnit		u	with (nolock)	on	u.idUnit = uu.idUnit)
		order	by	st.idStfLvl desc, st.sStaff
end
go
--	----------------------------------------------------------------------------
--	7.06.6956	removal of .sUnits (line #1345) moved into exec('..') to be re-appliable for earlier builds
--	7.06.6814	- tb_User.sTeams,.sUnits, tbTeam.sCalls,.sUnits, tbDvc.sTeams,.sUnits
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'sUnits')
begin
	begin tran
		exec( '
		alter table	dbo.tb_User		drop column	sTeams
		alter table	dbo.tb_User		drop column	sUnits

		alter table	dbo.tbTeam		drop column	sCalls
		alter table	dbo.tbTeam		drop column	sUnits

		alter table	dbo.tbDvc		drop column	sTeams
	--	alter table	dbo.tbDvc		drop column	sUnits
		update	dbo.tbDvc	set	sUnits =	null	where	idDvcType <> 0x08		-- blank non-Wi-Fi
		exec sp_rename ''tbDvc.sUnits'',		''sBrowser'',	''column''
			' )
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns teams filtered by unit (and active status)
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
	select	idTeam, sTeam, tResp, sDesc, bActive, dtCreated, dtUpdated		--, sCalls, sUnits
		from	tbTeam	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idUnit is null	or	idTeam in (select idTeam	from	tbTeamUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	sTeam
end
go
--	----------------------------------------------------------------------------
--	Returns teams responding to a given priority in a given unit
--	7.06.6814	- .sCalls, .sUnits
--				* tbTeamPri -> tbTeamCall
--	7.06.5347
alter proc		dbo.prTeam_GetByUnitPri
(
	@idUnit		smallint			-- not null
,	@siIdx		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, sDesc, bActive, dtCreated, dtUpdated		--, sCalls, sUnits
		from	tbTeam	with (nolock)
		where	bActive > 0
		and		idTeam in (select idTeam	from	tbTeamUnit	with (nolock)	where	idUnit = @idUnit)
		and		idTeam in (select idTeam	from	tbTeamCall	with (nolock)	where	siIdx = @siIdx)
	--	order	by	idTeam
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
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

	select	@s =	'[' + isnull(cast(@idRole as varchar), '?') + '], n="' + @sRole + '", d="' + isnull(cast(@sDesc as varchar), '?') +
					'", a=' + cast(@bActive as varchar) + ', U=' + isnull(cast(@sUnits as varchar), '?')
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
--	Inserts or updates a user
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

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	-- enforce membership in 'Public' role
	if	not exists	(select 1 from #tbRole with (nolock) where idRole = 1)
		insert	#tbRole		(idRole)	values	( 1 )

	select	@s =	'[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
					'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
					'", e="' + isnull(cast(@sEmail as varchar), '?') + '", d="' + isnull(cast(@sDesc as varchar), '?') +
					'", i="' + isnull(cast(@sStaffID as varchar), '?') + '", sl=' + isnull(cast(@idStfLvl as varchar), '?') +
					', b="' + isnull(cast(@sBarCode as varchar), '?') + '", od=' + isnull(cast(@bOnDuty as varchar), '?') +
					', a=' + cast(@bActive as varchar) + ', R=' + isnull(cast(@sRoles as varchar), '?') +
					', T=' + isnull(cast(@sTeams as varchar), '?') + ', U=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff
							,  sStaffID,  idStfLvl,  sBarCode,  bOnDuty,  bActive )	--,  sUnits,  sTeams
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '
							, @sStaffID, @idStfLvl, @sBarCode, @bOnDuty, @bActive )	--, @sUnits, @sTeams
			select	@idOper =	scope_identity( )

			select	@k =	237,	@s =	'User_I( ' + @s + ' )=' + cast(@idOper as varchar)
		end
		else
		begin
			update	tb_User	set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
								,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
								,	sStaffID =	@sStaffID,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode
						--		,	sUnits =	@sUnits,	sTeams =	@sTeams
								,	bOnDuty =	@bOnDuty,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@k =	238,	@s =	'User_U( ' + @s + ' )'
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
--	Inserts or updates a team
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

	select	@s =	'[' + isnull(cast(@idTeam as varchar), '?') + '], n="' + @sTeam + '", d=' + isnull(cast(@sDesc as varchar), '?') +
					', t=' + convert(varchar, @tResp, 108) + ', a=' + cast(@bActive as varchar) +
					', C=' + isnull(cast(@sCalls as varchar), '?') + ', U=' + isnull(cast(@sUnits as varchar), '?')
					-- + ' ' + convert(varchar, @dtCreated, 20) + ' ' + convert(varchar, @dtUpdated, 20)
	begin	tran

		if	not exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			insert	tbTeam	(  sTeam,  sDesc,  tResp,  bActive )	--,  sCalls,  sUnits
					values	( @sTeam, @sDesc, @tResp, @bActive )	--, @sCalls, @sUnits
			select	@idTeam =	scope_identity( )

			select	@k =	247,	@s =	'Team_I( ' + @s + ' )=' + cast(@idTeam as varchar)
		end
		else
		begin
			select	@k =	248,	@s =	'Team_U( ' + @s + ' )'

			update	tbTeam	set	sTeam=	@sTeam,	sDesc=	@sDesc,	tResp=	@tResp,	bActive =	@bActive,	dtUpdated=	getdate( )	--,	sCalls=	@sCalls,	sUnits=	@sUnits
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
--	Inserts or updates a device
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
	@idUser		int					-- user, performing the action
,	@idDvc		int out				-- device, acted upon
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sDial		varchar( 16 )
,	@sBarCode	varchar( 32 )
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

	if	@idDvcType = 0x08		--	Wi-Fi
		select	@sUnits =	null,	@sTeams =	null		-- enforce no Units or Teams for Wi-Fi devices
	else
	begin
		exec	dbo.prUnit_SetTmpFlt	@sUnits
		exec	dbo.prTeam_SetTmpFlt	@sTeams
	end

	select	@s =	'[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', n="' + @sDvc +
					'", b=' + isnull(cast(@sBarCode as varchar), '?') + ', d="' + isnull(cast(@sDial as varchar), '?') +
					'", f=' + cast(@tiFlags as varchar) + ', a=' + cast(@bActive as varchar) +
					', U=' + isnull(cast(@sUnits as varchar), '?') + ', T=' + isnull(cast(@sTeams as varchar), '?')
--	exec	dbo.pr_Log_Ins	1, @idUser, null, @s

	begin	tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  bActive )	--,  sUnits,  sTeams
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @bActive )	--, @sUnits, @sTeams
			select	@idDvc =	scope_identity( )

			select	@k =	247,	@s =	'Dvc_I( ' + @s + ' )=' + cast(@idDvc as varchar)
		end
		else
		begin
			select	@k =	248,	@s =	'Dvc_U( ' + @s + ' )'

			update	tbDvc	set	idDvcType=	@idDvcType,		sDvc =		@sDvc
							,	sDial=		@sDial,			sBarCode =	@sBarCode,		tiFlags =	@tiFlags
							,	idUser =	case when	@bActive > 0	then	idUser	else	null	end		-- unassign deactivated
					--		,	sUnits =	@sUnits,		sTeams =	@sTeams
							,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc

/*			if	@idDvcType = 0x01		--	badge
				and	@bActive = 0		--	disabled
				update	tbRtlsBadge		set	dtEntered=	null
					where	idBadge = @idDvc
*/		end

		if	@idDvcType = 0x08		--	Wi-Fi
			update	tbDvc	set	sBarCode =	cast(@idDvc as varchar)		-- enforce barcode to == DvcID for Wi-Fi devices
				where	idDvc = @idDvc

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62	--	J7980cw

		delete	from	tbDvcUnit
			where	idDvc = @idDvc
			and		idUnit not in (select	idUnit	from	#tbUnit	with (nolock))

		insert	tbDvcUnit	( idUnit, idDvc )
			select	idUnit, @idDvc
				from	#tbUnit	with (nolock)
				where	idUnit not in (select	idUnit	from	tbDvcUnit	with (nolock)	where	idDvc = @idDvc)

		delete	from	tbDvcTeam
			where	idDvc = @idDvc
			and		idTeam not in (select	idTeam	from	#tbTeam	with (nolock))

		insert	tbDvcTeam	( idTeam, idDvc )
			select	idTeam, @idDvc
				from	#tbTeam	with (nolock)
				where	idTeam not in (select	idTeam	from	tbDvcTeam	with (nolock)	where	idDvc = @idDvc)

	commit
end
go
--	----------------------------------------------------------------------------
--	Imports a user
--	7.06.6814	- tb_User.sTeams,.sUnits
--	7.06.5961	+ @sTeams, .gGUID, .utSynched
--	7.05.5121	+ .sUnits
--	7.05.4986	- @bLocked
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked
--	7.04.4965
alter proc		dbo.pr_User_Imp
(
	@idUser		int
,	@sUser		varchar( 32 )
,	@iHash		int
,	@tiFails	tinyint
,	@sFrst		varchar( 16 )
,	@sMidd		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
,	@dtLastAct	datetime
,	@sStaffID	varchar( 16 )
,	@idStfLvl	tinyint
,	@sBarCode	varchar( 32 )
,	@bOnDuty	bit
,	@dtDue		smalldatetime
,	@sStaff		varchar( 16 )
--,	@sUnits		varchar( 255 )
--,	@sTeams		varchar( 255 )
,	@gGUID		uniqueidentifier	-- AD GUID
,	@utSynched	smalldatetime		-- last sync with AD (UTC)
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idUser)
		begin
			set identity_insert	dbo.tb_User	on

			insert	tb_User	(  idUser,  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc
							,  dtLastAct,  sStaffID,  idStfLvl,  sBarCode,  bOnDuty,  dtDue,  sStaff	--,  sUnits,  sTeams
							,  gGUID,  utSynched,  bActive,  dtCreated,  dtUpdated )
					values	( @idUser, @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc
							, @dtLastAct, @sStaffID, @idStfLvl, @sBarCode, @bOnDuty, @dtDue, @sStaff	--, @sUnits, @sTeams
							, @gGUID, @utSynched, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tb_User	off
		end
		else
			update	tb_User	set	sUser=	@sUser,	iHash=	@iHash,	tiFails =	@tiFails,	sFrst=	@sFrst,	sMidd=	@sMidd
						,	sLast=	@sLast,	sEmail =	@sEmail,	sDesc=	@sDesc,	dtLastAct=	@dtLastAct,	sStaffID =	@sStaffID
						,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode,	bOnDuty =	@bOnDuty,	dtDue=	@dtDue
						,	sStaff =	@sStaff,	gGUID=	@gGUID		--,	sUnits =	@sUnits,	sTeams =	@sTeams
						,	utSynched=	@utSynched,	bActive =	@bActive,	dtCreated=	@dtCreated,	dtUpdated=	@dtUpdated
				where	idUser = @idUser

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns details for specified users
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
,	@idUser		int			= null	-- null=any
,	@sStaffID	varchar( 16 )= null	-- null=any
,	@idUnit		smallint	= null	-- null=any
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
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
		and		(@sStaffID is null	or	sStaffID = @sStaffID)
		and		(@idUnit is null	or	idUser in (select idUser	from	tb_UserUnit	with (nolock)	where	idUnit = @idUnit))
end
go
--	----------------------------------------------------------------------------
--	Ensures predefined accounts have assignability to all active units
--	--	Populates tb_UserUnit for each user/staff based on 7980's .sUnits
--	7.06.6814	* pr_UserUnit_Set -> pr_AccUnit_Set
--				- tb_User.sTeams, .sUnits
--	7.06.5939	- @sUser='All Units'
--	7.06.5568	+ @sUser='*'
--	7.05.5121	* .sBarCode -> .sUnits
--	7.05.5098	* check idUnit
--	7.05.5084	* added check for null on @sUnits
--	7.05.5050
create proc		dbo.pr_AccUnit_Set
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
grant	execute				on dbo.pr_AccUnit_Set				to [rWriter]
grant	execute				on dbo.pr_AccUnit_Set				to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff definitions
--	7.06.6814	- tb_User.sTeams,.sUnits
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
	,	sStaff,	l.sStfLvl + ' (' + cast(sStaffID as varchar) + ') ' + sStaff	as sFqStaff
	,	bOnDuty, dtDue,	s.idRoom	--	, s.sUnits, s.sTeams
	,	bActive, dtCreated, dtUpdated
	from	tb_User	s	with (nolock)
	join	tbStfLvl l	with (nolock)	on	l.idStfLvl = s.idStfLvl
--	where	s.idStfLvl is not null				--	only 'staff' users
go
--	----------------------------------------------------------------------------
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.06.5437	+ .dtDue
--	7.05.5184	+ .sTeams
--	7.05.5154	+ staff fields
--	7.05.5121	+ .sUnits
--	7.05.5095
alter view		dbo.vwDvc
	with encryption
as
select	d.idDvc, d.idDvcType, t.sDvcType, d.sDial, d.sDvc, d.sBarCode, d.tiFlags, d.sBrowser	--	, d.sUnits, d.sTeams
	,	t.sDvcType + ' #' + d.sDial		as	sFqDvc
	,	d.idUser, u.idStfLvl, u.sStfLvl, u.sStaffID, u.sStaff, u.sFqStaff, u.bOnDuty, u.dtDue
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDvc		d	with (nolock)
	join	tbDvcType	t	with (nolock)	on	t.idDvcType = d.idDvcType
	left join	vwStaff	u	with (nolock)	on	u.idUser = d.idUser
go
--	----------------------------------------------------------------------------
--	Exports all devices
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.05.5121	+ .sUnits
--	7.05.5099
alter proc		dbo.prDvc_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sBarCode, sDial, tiFlags, idUser, sBrowser, bActive, dtCreated, dtUpdated		--, sUnits
		from	tbDvc		with (nolock)
	--	where	idDvc >= 0x01000000
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a device
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.05.5121	+ .sUnits
--	7.05.5099
alter proc		dbo.prDvc_Imp
(
	@idDvc		int
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sBarCode	varchar( 32 )
,	@sDial		varchar( 16 )
,	@tiFlags	tinyint				-- bitwise: 1=group, 2=tech
,	@idUser		int
--,	@sUnits		varchar( 255 )
,	@sBrowser	varchar( 255 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not	exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			set identity_insert	dbo.tbDvc	on

			insert	tbDvc	(  idDvc,  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  sBrowser,  idUser,  bActive,  dtCreated,  dtUpdated )	--,  sUnits
					values	( @idDvc, @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sBrowser, @idUser, @bActive, @dtCreated, @dtUpdated )	--, @sUnits

			set identity_insert	dbo.tbDvc	off
		end
		else
			update	tbDvc	set	idDvcType=	@idDvcType,	sDvc =	@sDvc,	sBarCode =	@sBarCode,	sDial=	@sDial,	tiFlags =	@tiFlags
						,	sBrowser =	@sBrowser,	idUser =	@idUser,	bActive =	@bActive,	dtUpdated=	@dtUpdated	--, sUnits= @sUnits
				where	idDvc = @idDvc

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
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
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDevice	as	sQnRoom
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
--		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	tbRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.idDvcType & @idDvcType <> 0
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bGroup is null	or	d.tiFlags & 0x01 = @bGroup)
		and		(@idUnit is null	or	d.idDvcType = 1	or	d.idDvc in (select idDvc	from	tbDvcUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given bar-code
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.06.6282	* tbRtlsRoom -> tbRtlsBadge
--	7.06.5437	+ .dtDue
--	7.06.5428
alter proc		dbo.prDvc_GetByBC
(
	@sBarCode	varchar( 32 )		-- bar-code
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDevice	as	sQnRoom
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
--		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	tbRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0	and	d.sBarCode = @sBarCode
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given dial-code
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.06.6282	* tbRtlsRoom -> tbRtlsBadge
--	7.06.5437
alter proc		dbo.prDvc_GetByDial
(
	@sDial		varchar( 16 )		-- dialable number
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDevice	as	sQnRoom
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
--		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	tbRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0	and	d.sDial = @sDial
end
go
--	----------------------------------------------------------------------------
--	Returns a Wi-Fi device by the given ID
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.06.6656
alter proc		dbo.prDvc_GetWiFi
(
	@idDvc		int					-- device
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDevice	as	sQnRoom
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
--		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	tbRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.idDvc = @idDvc
		and		d.idDvcType = 0x08			--	Wi-Fi
end
go
--	----------------------------------------------------------------------------
--	Registers Wi-Fi devices
--	7.06.6815	+ .sBrowser
--	7.06.6710	+ exec dbo.prStaff_SetDuty
--	7.06.6646	+ @sDvc
--	7.06.6624	* reorder: 1) dvc 2) user
--	7.06.6543	+ @sStaffID
--	7.06.6459
alter proc		dbo.prDvc_RegWiFi
(
	@sSessID	varchar( 32 )
,	@idModule	tinyint
,	@sIpAddr	varchar( 40 )
,	@sDvc		varchar( 16 )		-- device name
,	@sBrowser	varchar( 128 )		-- device OS
,	@idDvc		int					-- device, acted upon
,	@sUser		varchar( 16 )		-- username or StaffID
,	@iHash		int					-- calculated password 32-bit hash (Murmur2)
,	@idSess		int				out
,	@idUser		int				out
,	@sStaff		varchar( 16 )	out	-- full-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
,	@sStaffID	varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@sDvc		varchar( 16 )
		,		@bActive	bit
		,		@idLogType	tinyint

	set	nocount	on

	select	@s =	'@ ' + isnull( @sIpAddr, '?' )	-- + ''

--	select	@sDvc=	sDvc,	@bActive =	bActive
	select	@bActive =	bActive
		from	tbDvc		with (nolock)
		where	idDvc = @idDvc
		and		idDvcType = 0x08		--	wi-fi

--	if	@sDvc is null			--	wrong dvc
	if	@bActive is null		--	wrong dvc
	begin
		select	@idLogType =	226,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@bActive = 0			--	inactive dvc
	begin
--		select	@idLogType =	227,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''', ''' + isnull( @sDvc, '?' ) + ''''
		select	@idLogType =	227,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''', [' + isnull( @idDvc, '?' ) + ']'
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	select	@idUser =	idUser
		from	tb_User		with (nolock)
		where	(sUser = lower( @sUser )	or	sStaffID = @sUser)

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule
		return	@idLogType
	end

	exec				dbo.pr_Sess_Ins		@sSessID, @idModule, null, @sIpAddr, @sDvc, 0, @sBrowser, @idSess out
	exec	@idLogType=	dbo.pr_User_Login	@idSess, @sUser, @iHash, @idUser out, @sStaff out, @bAdmin out, @sStaffID out

	if	@idLogType = 221		--	success
	begin
		begin	tran

			exec	dbo.prStaff_SetDuty		@idUser, 1, 0

			update	tbDvc	set	idUser =	@idUser,	sDvc =	@sDvc,	sBrowser =	@sBrowser
				where	idDvc = @idDvc

		commit
	end

	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Exports all staff assignment definitions
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

	select	idStfAssn, idUnit, cSys, tiGID, tiJID, tiBed, tiShIdx, tiIdx, sStaffID, bActive, dtCreated, dtUpdated,	idRoom, idShift, idUser
		from	vwStfAssn	with (nolock)
	---	where	bActive > 0					-- must export all to ensure matching deactivation
end
go
--	----------------------------------------------------------------------------
--	Returns teams for a given device
--	7.06.6816	* tbDvcTeam -> tbTeamDvc
--	7.06.6807
create proc		dbo.prDvc_GetTeams
(
	@idDvc		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idTeam, t.sTeam
		from	tbTeamDvc	m	with (nolock)
		join	tbTeam		t	with (nolock)	on	t.idTeam = m.idTeam
		where	m.idDvc = @idDvc
end
go
grant	execute				on dbo.prDvc_GetTeams				to [rWriter]
grant	execute				on dbo.prDvc_GetTeams				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active group notification devices (pagers only), assigned to a given team
--	7.06.6816	* tbDvcTeam -> tbTeamDvc
--	7.06.5347
alter proc		dbo.prTeam_GetDvcs
(
	@idTeam		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sDial, tiFlags
		from	tbDvc	with (nolock)
		where	bActive > 0		and idDvcType > 1
		and		idDvc	in	(select idDvc from tbTeamDvc with (nolock) where idTeam = @idTeam)
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a device
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
	@idUser		int					-- user, performing the action
,	@idDvc		int out				-- device, acted upon
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sDial		varchar( 16 )
,	@sBarCode	varchar( 32 )
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

	if	@idDvcType = 0x08		--	Wi-Fi
		select	@sUnits =	null,	@sTeams =	null		-- enforce no Units or Teams for Wi-Fi devices
	else
	begin
		exec	dbo.prUnit_SetTmpFlt	@sUnits
		exec	dbo.prTeam_SetTmpFlt	@sTeams
	end

	select	@s =	'[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', n="' + @sDvc +
					'", b=' + isnull(cast(@sBarCode as varchar), '?') + ', d="' + isnull(cast(@sDial as varchar), '?') +
					'", f=' + cast(@tiFlags as varchar) + ', a=' + cast(@bActive as varchar) +
					', U=' + isnull(cast(@sUnits as varchar), '?') + ', T=' + isnull(cast(@sTeams as varchar), '?')
--	exec	dbo.pr_Log_Ins	1, @idUser, null, @s

	begin	tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  bActive )	--,  sUnits,  sTeams
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @bActive )	--, @sUnits, @sTeams
			select	@idDvc =	scope_identity( )

			select	@k =	247,	@s =	'Dvc_I( ' + @s + ' )=' + cast(@idDvc as varchar)
		end
		else
		begin
			select	@k =	248,	@s =	'Dvc_U( ' + @s + ' )'

			update	tbDvc	set	idDvcType=	@idDvcType,		sDvc =		@sDvc
							,	sDial=		@sDial,			sBarCode =	@sBarCode,		tiFlags =	@tiFlags
							,	idUser =	case when	@bActive > 0	then	idUser	else	null	end		-- unassign deactivated
					--		,	sUnits =	@sUnits,		sTeams =	@sTeams
							,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc

/*			if	@idDvcType = 0x01		--	badge
				and	@bActive = 0		--	disabled
				update	tbRtlsBadge		set	dtEntered=	null
					where	idBadge = @idDvc
*/		end

		if	@idDvcType = 0x08		--	Wi-Fi
			update	tbDvc	set	sBarCode =	cast(@idDvc as varchar)		-- enforce barcode to == DvcID for Wi-Fi devices
				where	idDvc = @idDvc

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62	--	J7980cw

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

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_InsDel')
	drop proc	dbo.pr_UserRole_InsDel
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamDvc')
	drop table	dbo.tbTeamDvc
go
--	----------------------------------------------------------------------------
--	TeamStaff-Dvc membership
--	7.06.6816	* tbDvcTeam -> tbTeamDvc
--	7.05.5059
create table	dbo.tbTeamDvc
(
	idTeam		smallint		not null
		constraint	fkTeamDvc_Team		foreign key references tbTeam
,	idDvc		int				not null
		constraint	fkTeamDvc_Dvc		foreign key references tbDvc

,	dtCreated	smalldatetime	not null
		constraint	tdTeamDvc_Created	default( getdate( ) )

,	constraint	xpTeamDvc		primary key clustered ( idTeam, idDvc )
)
go
grant	select, insert,			delete	on dbo.tbTeamDvc		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamDvc		to [rReader]
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvcTeam')
begin
	begin tran
		insert	dbo.tbTeamDvc	( idTeam, idDvc, dtCreated )
			select	idTeam, idDvc, dtCreated
				from	dbo.tbDvcTeam

--		drop table	dbo.tbDvcTeam
	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all role-unit combinations
--	7.06.6816	* order by 1
--	7.06.5385
alter proc		dbo.pr_RoleUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idRole, idUnit, dtCreated
		from	tb_RoleUnit		with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Exports all user-role combinations
--	7.06.6816	* order by 1
--	7.06.5385
alter proc		dbo.pr_UserRole_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idRole, dtCreated
		from	tb_UserRole		with (nolock)
		order	by	1
end
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvcUnit_Imp')
	drop proc	dbo.prDvcUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvcUnit_Exp')
	drop proc	dbo.prDvcUnit_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamDvc_Imp')
	drop proc	dbo.prTeamDvc_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamDvc_Exp')
	drop proc	dbo.prTeamDvc_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUnit_Imp')
	drop proc	dbo.prTeamUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUnit_Exp')
	drop proc	dbo.prTeamUnit_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamCall_Imp')
	drop proc	dbo.prTeamCall_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamCall_Exp')
	drop proc	dbo.prTeamCall_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUser_Imp')
	drop proc	dbo.prTeamUser_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUser_Exp')
	drop proc	dbo.prTeamUser_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Imp')
	drop proc	dbo.pr_UserUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Exp')
	drop proc	dbo.pr_UserUnit_Exp
go
--	----------------------------------------------------------------------------
--	Exports all role-unit combinations
--	7.06.6816
create proc		dbo.pr_UserUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idUnit, dtCreated
		from	tb_UserUnit		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.pr_UserUnit_Exp				to [rWriter]
grant	execute				on dbo.pr_UserUnit_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a role-unit combination
--	7.06.6816
create proc		dbo.pr_UserUnit_Imp
(
	@idUser		int					--	0=clear table
,	@idUnit		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idUser > 0
		begin
			if	not	exists	(select 1 from tb_UserUnit with (nolock) where idUser = @idUser and idUnit = @idUnit)
			begin
				insert	tb_UserUnit	(  idUser,  idUnit,  dtCreated )
						values		( @idUser, @idUnit, @dtCreated )
			end
		end
		else
			delete	from	tb_UserUnit

	commit
end
go
grant	execute				on dbo.pr_UserUnit_Imp				to [rWriter]
--grant	execute				on dbo.pr_UserUnit_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-user combinations
--	7.06.6816
create proc		dbo.prTeamUser_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idUser, dtCreated
		from	tbTeamUser		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamUser_Exp				to [rWriter]
grant	execute				on dbo.prTeamUser_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-user combination
--	7.06.6816
create proc		dbo.prTeamUser_Imp
(
	@idTeam		smallint			--	0=clear table
,	@idUser		int
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from tbTeamUser with (nolock) where idTeam = @idTeam and idUser = @idUser)
			begin
				insert	tbTeamUser	(  idTeam,  idUser,  dtCreated )
						values		( @idTeam, @idUser, @dtCreated )
			end
		end
		else
			delete	from	tbTeamUser

	commit
end
go
grant	execute				on dbo.prTeamUser_Imp				to [rWriter]
--grant	execute				on dbo.prTeamUser_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-call combinations
--	7.06.6816
create proc		dbo.prTeamCall_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, siIdx, dtCreated
		from	tbTeamCall		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamCall_Exp				to [rWriter]
grant	execute				on dbo.prTeamCall_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-call combination
--	7.06.6816
create proc		dbo.prTeamCall_Imp
(
	@idTeam		smallint			--	0=clear table
,	@siIdx		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from tbTeamCall with (nolock) where idTeam = @idTeam and siIdx = @siIdx)
			begin
				insert	tbTeamCall	(  idTeam,  siIdx,  dtCreated )
						values		( @idTeam, @siIdx, @dtCreated )
			end
		end
		else
			delete	from	tbTeamCall

	commit
end
go
grant	execute				on dbo.prTeamCall_Imp				to [rWriter]
--grant	execute				on dbo.prTeamCall_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-unit combinations
--	7.06.6816
create proc		dbo.prTeamUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idUnit, dtCreated
		from	tbTeamUnit		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamUnit_Exp				to [rWriter]
grant	execute				on dbo.prTeamUnit_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-unit combination
--	7.06.6816
create proc		dbo.prTeamUnit_Imp
(
	@idTeam		smallint			--	0=clear table
,	@idUnit		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from tbTeamUnit with (nolock) where idTeam = @idTeam and idUnit = @idUnit)
			begin
				insert	tbTeamUnit	(  idTeam,  idUnit,  dtCreated )
						values		( @idTeam, @idUnit, @dtCreated )
			end
		end
		else
			delete	from	tbTeamUnit

	commit
end
go
grant	execute				on dbo.prTeamUnit_Imp				to [rWriter]
--grant	execute				on dbo.prTeamUnit_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-dvc combinations
--	7.06.6816
create proc		dbo.prTeamDvc_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idDvc, dtCreated
		from	tbTeamDvc		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamDvc_Exp				to [rWriter]
grant	execute				on dbo.prTeamDvc_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-dvc combination
--	7.06.6816
create proc		dbo.prTeamDvc_Imp
(
	@idTeam		smallint			--	0=clear table
,	@idDvc		int
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from tbTeamDvc with (nolock) where idTeam = @idTeam and idDvc = @idDvc)
			begin
				insert	tbTeamDvc	(  idTeam,  idDvc,  dtCreated )
						values		( @idTeam, @idDvc, @dtCreated )
			end
		end
		else
			delete	from	tbTeamDvc

	commit
end
go
grant	execute				on dbo.prTeamDvc_Imp				to [rWriter]
--grant	execute				on dbo.prTeamDvc_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all dvc-unit combinations
--	7.06.6816
create proc		dbo.prDvcUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idUnit, dtCreated
		from	tbDvcUnit		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prDvcUnit_Exp				to [rWriter]
grant	execute				on dbo.prDvcUnit_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a dvc-unit combination
--	7.06.6816
create proc		dbo.prDvcUnit_Imp
(
	@idDvc		int					--	0=clear table
,	@idUnit		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idDvc > 0
		begin
			if	not	exists	(select 1 from tbDvcUnit with (nolock) where idDvc = @idDvc and idUnit = @idUnit)
			begin
				insert	tbDvcUnit	(  idDvc,  idUnit,  dtCreated )
						values		( @idDvc, @idUnit, @dtCreated )
			end
		end
		else
			delete	from	tbDvcUnit

	commit
end
go
grant	execute				on dbo.prDvcUnit_Imp				to [rWriter]
--grant	execute				on dbo.prDvcUnit_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all teams
--	7.06.6817
create proc		dbo.prTeam_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, sDesc, bActive, dtCreated, dtUpdated
		from	tbTeam		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeam_Exp					to [rWriter]
grant	execute				on dbo.prTeam_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team
--	7.06.6817
create proc		dbo.prTeam_Imp
(
	@idTeam		smallint
,	@sTeam		varchar( 16 )
,	@tResp		time( 0 )
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

			insert	tbTeam	(  idTeam,  sTeam,  tResp,  sDesc,  bActive,  dtCreated,  dtUpdated )
					values	( @idTeam, @sTeam, @tResp, @sDesc, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbTeam	off
		end
		else
			update	tbTeam	set	sTeam=	@sTeam,		tResp=	@tResp,		sDesc=	@sDesc
						,	bActive =	@bActive,	dtUpdated=	@dtUpdated
				where	idTeam = @idTeam

	commit
end
go
grant	execute				on dbo.prTeam_Imp					to [rWriter]
--grant	execute				on dbo.prTeam_Imp					to [rReader]
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 6897 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	6897, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2018-11-19',	dtInstall=	getdate( )
		,	sVersion =	'*7983ls, *7983rh, *7980ca, *7987ca'
		where	siBuild = 6897

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.6897'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.6897 )'
commit
go

checkpoint
go

use [master]
go