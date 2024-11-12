--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
--		2014-Jun-03		.5267
--						* prEvent_Ins, prEvent84_Ins
--		2014-Jun-04		.5268
--					--	* prCall_GetIns
--		2014-Jun-10		.5274
--						* prEvent84_Ins
--		2014-Jun-11		.5275
--						* prShift_GetByUnit
--		2014-Jun-19		.5283
--						* vwEvent_A		(fnEventA_GetTopByUnit, fnEventA_GetTopByRoom)
--		2014-Jun-26		.5290
--						--	+ tb_LogType[208]
--						* prEvent8A_Ins, prEvent95_Ins
--		2014-Jul-03		.5297
--						* prRptCallStatSum, prRptCallStatSumGraph
--		2014-Jul-08		.5302
--						* prRptCallActSum
--		2014-Jul-10		.5304
--						* prRptCallActDtl, prRptSysActDtl
--		2014-Jul-14		.5308
--						* prRtlsBadge_InsUpd
--	7.06
--		2014-Jul-15		.5309
--						- tb_Feature[idModule=92]:	no sync with 7983 yet
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 5309 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.06.5309', 18, 0 )

go

go
--	----------------------------------------------------------------------------
--	Inserts common event header
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
	declare		@dtEvent	datetime
		,		@tiHH		tinyint
		,		@cDevice	char( 1 )
		,		@cSys		char( 1 )
		,		@idParent	int
		,		@dtParent	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@iExpNrm	int
		,		@iAID2		int
		,		@tiGID		tinyint
		,		@tiJID		tinyint
		,		@tiStype2	tinyint
		,		@sDvc		varchar( 16 )
		,		@s			varchar( 255 )

	set	nocount	on

	select	@dtEvent=	getdate( )
		,	@tiHH=		datepart( hh, getdate( ) )
		,	@cDevice=	case when @idCmd = 0x83 then 'G' else '?' end

	select	@iExpNrm= iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@tiBed= null

	if	@idUnit > 0
--		if	not exists	(select 1 from tbCfgLoc where idLoc = @idUnit and cLoc = 'U')
		if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		begin
			select	@s=	'Evt_I( c=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?')
	--	-	exec	pr_Log_Ins	82, null, null, @s

			select	@idUnit=	null
		end

--	select	@s=	'Evt_I( cmd=' + isnull(cast(@idCmd as varchar),'?') + ', unit=' + isnull(cast(@idUnit as varchar),'?') + ' typ=' + isnull(cast(@tiStype as varchar),'?') +
--				', src=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sSrcDvc,'?') +
--				'], dst=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sDstDvc,'?') +
--				'], btn=' + isnull(cast(@tiBtn as varchar),'?') + ', bed=' + isnull(cast(@tiBed as varchar),'?') + ' )'		--	 + ' i=' + isnull(@sInfo,'?')
--	exec	pr_Log_Ins	0, null, null, @s

	begin	tran

		if	@tiBed is not null		-- >= 0
			update	tbCfgBed	set	bActive= 1, dtUpdated= getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)	--	audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys=		@cSrcSys,	@tiGID=		@tiSrcGID,	@tiJID=		@tiSrcJID,	@tiShelf=	@tiSrcRID,	@sDvc=		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys=	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys=	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiShelf,	@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype=	null
		end

		exec	dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

		if	@idCmd <> 0x84	or	@idLogType <> 194		--	skip healing 84s
		begin

			insert	tbEvent	(  idCmd,  tiLen,  iHash,  vbCmd,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit,
							 cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  idSrcDvc,
							 cDstSys,  tiDstGID,  tiDstJID,  tiDstRID,  idDstDvc,
							 dtEvent,  dEvent,  tEvent,  tiHH )
					values	( @idCmd, @tiLen, @iHash, @vbCmd, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit,
							@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @idSrcDvc,
							@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @idDstDvc,
							@dtEvent, @dtEvent, @dtEvent, @tiHH )

			select	@idEvent=	scope_identity( )

		end

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

		if	len(@s) > 0
		begin
			select	@s=	@s + ' ) id=' + cast(@idEvent as varchar)
			exec	pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02
		begin

			select	@idParent= idEvent, @dtParent= dtEvent		--	7.04.4968
				from	tbEvent_A	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
				and		( bActive > 0		or	@idCmd < 0x80	or	@idCmd = 0x8D )		--	7.05.5095, .5211
				and		( tiBtn = @tiBtn	or	@tiBtn is null )
				and		( idCall = @idCall	or	@idCall is null		or	idCall = @idCall0	and	@idCall0 is not null )

			select	@idRoom=	idDevice
				from	vwRoom		with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	bActive > 0		--	and	tiRID = 0

--			select	@s=	'Evt_i2: prnt=' + isnull(cast(@idParent as varchar),'?') + ' room=' + isnull(cast(@idRoom as varchar),'?')
--			exec	pr_Log_Ins	0, null, null, @s

			if	@idParent > 0
				update	tbEvent		set	idParent= @idParent,	idRoom= @idRoom,	tParent= dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	tbEvent		set	idParent= @idEvent,		idRoom= @idRoom,	tParent= '0:0:0'
					where	idEvent = @idEvent

			if	@idUnit > 0		and	@idRoom > 0					--	7.02	7.05.5205
				update	tbRoom		set	idUnit=	@idUnit
					where	idRoom = @idRoom
		end

		if	@idEvent > 0
		begin
			select	@idParent= null
			select	@idParent= idEvent
				from	tbEvent_S	with (nolock)
				where	dEvent = cast(@dtEvent as date)		and	tiHH = @tiHH

			if	@idParent	is null
				insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
						values		( @dtEvent, @tiHH, @idEvent )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
,	@tiTmrSt	tinyint				-- stat-need timer
,	@tiTmrRn	tinyint				-- RN-need timer
,	@tiTmrCn	tinyint				-- CNA-need timer
,	@tiTmrAi	tinyint				-- Aide-need timer
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
,	@sCall		varchar( 16 )		-- call text
,	@sPatient	varchar( 16 )		-- patient name
,	@cGender	char( 1 )
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
,	@sRn		varchar( 16 )		-- RN name
,	@sCn		varchar( 16 )		-- CNA name
,	@sAi		varchar( 16 )		-- Aide name

,	@idEvent	int			out		-- output: idOrigin of input event
,	@idLogType	tinyint		out
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@idParent	int
	--	,		@idEvent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
	--	,		@idRoom		smallint
		,		@idCall		smallint
		,		@idCall0	smallint
		,		@siIdxOld	smallint
		,		@siIdxNew	smallint
		,		@idDoctor	int
		,		@idPatient	int
		,		@idOrigin	int
		,		@dtOrigin	datetime
	--	,		@idLogType	tinyint
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
	--	,		@tiRmBed	tinyint
		,		@cBed		char( 1 )
		,		@tiPurge	tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiPurge=	cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 7
	select	@iExpNrm=	iValue						from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt=	iValue						from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@idEvent=	null,	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

	if	@siIdxNew > 0			-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiShelf= tiShelf,	@tiSpec= tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

		if	@siIdxOld > 0  and  @siIdxOld <> @siIdxNew		-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0		-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiShelf= tiShelf,	@tiSpec= tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0		--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	if	@tiSpec between 7 and 9
		select	@bPresence= 1,	@tiBed= 0xFF	--	mark 'presence' calls and force room-level
	else
		if	len(@sPatient) > 0					--	only 'non-presence' calls have patient data
		begin
			exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
			exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
		end

	if	@tiBed > 9
		select	@cBed= null,	@tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed
		
	if	@tiTmrSt > 3		select	@tiTmrSt=	3
	if	@tiTmrRn > 3		select	@tiTmrRn=	3
	if	@tiTmrCn > 3		select	@tiTmrCn=	3
	if	@tiTmrAi > 3		select	@tiTmrAi=	3

	--	origin points to the first still active event that started call-sequence for this priority
	select	@idOrigin= idEvent, @dtOrigin= dtEvent, @bAudio= bAudio
		from	tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn
			and	bActive > 0				--	6.04
			and	(idCall = @idCall	or	idCall = @idCall0)		--	7.05.4976

	select	@idLogType= case when	@idOrigin is null	then
								case when	@bPresence > 0	then 206 else 191 end
							when	@siIdxNew = 0		then
								case when	@bPresence > 0	then 207 else 193 end
							else
								case when	@idCall0 > 0	then 192 else 194 end	end
		,	@tiSvc=		@tiTmrSt * 64 + @tiTmrRn * 16 + @tiTmrCn * 4 + @tiTmrAi

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		if	@idEvent > 0
			insert	tbEvent84	( idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew,
								tiTmrSt,  tiTmrRn,  tiTmrCn,  tiTmrAi,  idPatient,  idDoctor,  iFilter,
								tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
								siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
					values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew,
								@tiTmrSt, @tiTmrRn, @tiTmrCn, @tiTmrAi, @idPatient, @idDoctor, @iFilter,
								@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
								@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3)

		exec	dbo.prRoom_Upd		@idRoom, @idUnit, @sRn, @sCn, @sAi


		if	@idOrigin is null	--	no active origin found (=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin= @idEvent
					,	tOrigin=	dateadd(ss, @siElapsed, '0:0:0')
					,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent),	@idSrcDvc= idSrcDvc,	@idParent= idParent
				where	idEvent = @idEvent

			insert	tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
									siPri,     siIdx,     idRoom,  tiBed,  idCall, dtExpires,	tiSvc,
									tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
									@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, dateadd(ss, @iExpNrm, getdate( )), @tiSvc,
									@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

			if	@idRoom > 0		and																	--	7.05.5212
				(@tiShelf > 0	and	( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 )			--	'medical' call
				or	@bPresence > 0)																	--	or 'presence'
				begin
					select	@idUser=	case
								when @tiSpec = 7	then	idRn
								when @tiSpec = 8	then	idCn
								when @tiSpec = 9	then	idAi
								else						null	end
						from	tbRoom	with (nolock)
						where	idRoom = @idRoom

					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idRoom,  idUnit,  tiBed,  idUser, tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idRoom, @idUnit, @tiBed, @idUser, datepart(hh, @dtOrigin) )
				end

			select	@idOrigin= @idEvent
		end

		else					--	active origin found		(=> call healed/escalated/cancelled)
		begin
			update	tbEvent		set	idOrigin= @idOrigin,	tOrigin= dtEvent - @dtOrigin
				where	idEvent = @idEvent

--			if	exists( select 1 from tbEvent_A with (nolock) where idEvent = @idOrigin and tiSvc <> @tiSvc )
									--	( siPri <> @siPriNew or idCall <> @idCall or  )
--				select	@idLogType=	208		--	state changed

			update	tbEvent_A	set	dtExpires= dateadd(ss, @iExpNrm, getdate( ))
							,	siPri= @siPriNew,	idCall= @idCall,	tiSvc= @tiSvc
	--						,	tiSvc=	@tiTmrSt * 64 + @tiTmrRn * 16 + @tiTmrCn * 4 + @tiTmrAi
				where	idEvent = @idOrigin		--	7.05.5065
		end


		if	@siIdxNew = 0		-- call cancelled
		begin
			select	@dtOrigin=	case when @bAudio=0 then dateadd(ss, @iExpNrm, getdate( ))
													else dateadd(ss, @iExpExt, getdate( )) end

			update	tbEvent_A	set	dtExpires= @dtOrigin,	tiSvc= null,	bActive= 0
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

			select	@dtOrigin= tOrigin,	@idParent= idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent

			update	tbEvent_C	set	idEvtSt= @idEvent,	tStaff= @dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null		-- there should be only one, but just in case - use only 1st one

	--		update	tbEvent		set	idLogType=	case when @bPresence > 0 then 207 else 193 end	-- pres-out/call cancelled
	--			where	idEvent = @idEvent
		end


		if	@tiStype = 192	and	@tiBed is not null				--	only for 7947 (iBed):	if argument is a bed-level call
			update	tbRoomBed	set	tiIbed=
									case when	@siIdxNew = 0	then	--	call cancelled
										tiIbed &
										case when	@tiBtn = 2	then	0xFE
											when	@tiBtn = 7	then	0xFD
											when	@tiBtn = 6	then	0xFB
											when	@tiBtn = 5	then	0xF7
											when	@tiBtn = 4	then	0xEF
											when	@tiBtn = 3	then	0xDF
											when	@tiBtn = 1	then	0xBF
											when	@tiBtn = 0	then	0x7F
											else	0xFF	end
										else							--	call placed / being-healed
										tiIbed |
										case when	@tiBtn = 2	then	0x01
											when	@tiBtn = 7	then	0x02
											when	@tiBtn = 6	then	0x04
											when	@tiBtn = 5	then	0x08
											when	@tiBtn = 4	then	0x10
											when	@tiBtn = 3	then	0x20
											when	@tiBtn = 1	then	0x40
											when	@tiBtn = 0	then	0x80
											else	0x00	end
										end
				where	idRoom = @idRoom	and	tiBed = @tiBed


	---	!! @idEvent no longer points to current event !!


		select	@idEvent= null,	@tiSvc= null
		select	top 1	@idEvent= idEvent,	@tiSvc= tiSvc		--	highest oldest active call for this room
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent
	--		order	by	siIdx desc, tElapsed desc				--	call may have started before it was recorded

		update	tbRoom	set	idEvent= @idEvent,	tiSvc= @tiSvc,	dtUpdated= getdate( )
			where	idRoom = @idRoom


		declare		cur		cursor fast_forward for
			select	tiBed
				from	tbRoomBed	with (nolock)
				where	idRoom = @idRoom

		open	cur
		fetch next from	cur	into	@tiBed
		while	@@fetch_status = 0
		begin
			select	@idEvent= null,	@tiSvc= null
			select	top 1	@idEvent= idEvent,	@tiSvc= tiSvc	--	highest oldest active call for this room's bed
				from	tbEvent_A	ea	with (nolock)
				where	idRoom = @idRoom
					and	bActive > 0
					and	(tiBed is null	or tiBed = @tiBed)
				order	by	siIdx desc, idEvent
	--			order	by	siIdx desc, tElapsed desc			--	call may have started before it was recorded

			update	tbRoomBed	set	idEvent= @idEvent,	tiSvc= @tiSvc,	dtUpdated= getdate( )
	--	??			,	tiSvc= case when @siIdxNew = 0 then null else @tiSvc end	--	7.05.5204	seems unnecessary
				where	idRoom = @idRoom	and	tiBed = @tiBed

			fetch next from	cur	into	@tiBed
		end
		close	cur
		deallocate	cur

	commit

	select	@idEvent= @idOrigin			--	7.05.5267	return idOrigin
end
go
/*--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.05.5268	+ check for @sCall
--	7.04.4896	* tbDefCall -> tbCall
--	6.05	+ (nolock), tracing
--	6.03
--	--	2.03
alter proc		dbo.prCall_GetIns
(
	@siIdx		smallint			-- call-index
,	@sCall		varchar( 16 )		-- call-text
,	@idCall		smallint out		-- output
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@idCall= idCall
			from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0

	if	@idCall is null
		select	@idCall= idCall
			from	tbCall	with (nolock)	where	sCall = @sCall	and	bActive > 0

	if	@idCall is null
	begin
		begin	tran

			select	@s= 'Call_I( ' + isnull(cast(@siIdx as varchar), '?') + ', n=' + isnull(@sCall, '?')

			if	len( @sCall ) > 0
			begin
				insert	tbCall	(  siIdx,  sCall )
						values		( @siIdx, @sCall )
				select	@idCall=	scope_identity( )

				select	@s= @s + ' )  id=' + cast(@idCall as varchar)
				exec	pr_Log_Ins	72, null, null, @s
			end
			else
			begin
				select	@s= @s + ' ): call-txt'
				exec	pr_Log_Ins	82, null, null, @s
			end
		commit
	end
end
*/
go
--	----------------------------------------------------------------------------
--	Returns all active shifts for a given unit (ordered by index) or current one
--	7.05.5275	+ @bCurrent
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4938
alter proc		dbo.prShift_GetByUnit
(
	@idUnit		smallint
,	@bCurrent	bit			=	0		--	0=all, 1=current only
)
	with encryption
as
begin
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, tiNotify, bActive, dtUpdated, idUser, idStfLvl, sStaffID, sStaff, bOnDuty
		from	vwShift		with (nolock)
		where	idUnit = @idUnit	and	bActive > 0
			and	(@bCurrent = 0	or	idShift in (select idShift from tbUnit with (nolock) where idUnit = @idUnit))
		order	by	tiIdx
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
--	7.05.5283	* cast(tElapsed as time(3))
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--				* tbDefCallP -> tbCfgPri
--	7.03	+ .sSGJRB, + .iFilter, + .tiCvrg[0..7]
--	7.02	- .tiTmr* (no need anymore, .tiSvc satisfies)
--	6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--			+ sd.tiStype, p.tiShelf, p.tiSpec
--			- .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide (no longer needed)
--			+ .tiSvc, .bAudio, .idUnit
--			+ (nolock)
--	6.04	+ .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide, .bAnswered
--			tbEvent.idRoom --> tbEvent_A.idRoom, .tiBed, .idCall
--			.idDevice,.sDevice,.sFnDevice -> .idRoom,.sRoom
--			+ .sDevice, .tiBed, .cBed
--	6.03
alter view		dbo.vwEvent_A
	with encryption
as
select	ea.idEvent, ea.dtEvent,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
	,	sd.idDevice, sd.sDevice, sd.sQnDevice, sd.tiStype, sd.sSGJR + '-' + right('0' + cast(ea.tiBtn as varchar), 2) [sSGJRB]
	,	ea.idRoom, r.sDevice [sRoom],	ea.tiBed, b.cBed,	rm.idUnit
	,	ea.idCall, c.siIdx, c.sCall, p.iColorF, p.iColorB, p.tiShelf, p.tiSpec, p.iFilter
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit ) [bAnswered]
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) ) [tElapsed], ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	from		tbEvent_A	ea	with (nolock)
	left join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left join	tbCall		c	with (nolock)	on	c.idCall = ea.idCall
	left join	tbCfgPri	p	with (nolock)	on	p.siIdx = c.siIdx
	left join	tbCfgBed	b	with (nolock)	on	b.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
--	7.05.5000	+ .tiShelf, .tiSpec
--	7.03	+ @idMaster
--			- @tiShelf, + @iFilter, + .iFilter, + .tiCvrg[0..7]
--			* expanded * -> list of all vwEvent_A columns	http://stackoverflow.com/questions/15693359/
--			+ @tiShelf arg
--	7.00
alter function		dbo.fnEventA_GetTopByUnit
(
	@idUnit		smallint			-- unit look-up FK
,	@iFilter	int					-- filter mask
,	@idMaster	smallint			-- device look-up FK
)
	returns table
	with encryption
as
return
	select	top	1	--*				--	7.03
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idRoom, sRoom,	tiBed, cBed,	idUnit
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, iFilter
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0		and	idUnit = @idUnit
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given room (identified by Sys-G-J)
--	7.05.5007	+ @bPrsnc
--	7.05.5000	* added presence events, otherwise indicators are not bubbling up (7985 MV will filter 'em out)
--	7.03	+ @idMaster
--			+ @iFilter, + .iFilter, + .tiCvrg[0..7]
--			* expanded * -> list of all vwEvent_A columns	http://stackoverflow.com/questions/15693359/
--	7.00
alter function		dbo.fnEventA_GetTopByRoom
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiBed		tinyint				-- bed-idx, 0xFF=room
,	@iFilter	int					-- filter mask
,	@idMaster	smallint			-- device look-up FK
,	@bPrsnc		bit					-- include presence events?
)
	returns table
	with encryption
as
return
	select	top	1	--*				--	7.03
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idRoom, sRoom,	tiBed, cBed,	idUnit
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, iFilter
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	( tiShelf > 0	or	@bPrsnc > 0	and	tiSpec between 7 and 9 )
			and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
--	7.05.5290	* optimized
--	7.05.5205	* prEvent_Ins args
--	7.05.4976	* origin search
--				- tbEvent_P, tbEvent_T
--	7.05.4974	* audio doesn't start a transaction - no tbEvent_C insertion
--	7.04.4972	* insert tbEvent_C: @idSrcDvc -> @idRoom
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--				* tbEvent_C:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt, .idRn -> .idEvtRn, .idCn -> .idEvtCn, .idAi -> .idEvtAi
--				* tbEvent_T:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--				* tbDefCall -> tbCall
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.02	* tbEvent.tElapsed -> .tOrigin
--	7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ extended expiration for picked calls
--			+ tagging tbEvent_A.bAudio
--			+ (nolock)
--	6.04	* @siPri -> @siIdx arg in call to prDefCall_GetIns
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--	6.02	tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	5.01	encryption added
--			+ tbEvent.idParent, + .tParent, parent events
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	4.01	fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	2.03	.idSrcDvc -> .idDstDvc (prEvent8A_Ins, vwEvent8A)
--			+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbEventC.tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--			fix for non-med EventC insertions, changed Event.idType if no origin
--			+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	2.01	- .idDstDvc
--			.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	1.08
--	1.00
alter proc		dbo.prEvent8A_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint				-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@cDstSys	char( 1 )			-- destination system
,	@tiDstGID	tinyint				-- destination G-ID - gateway
,	@tiDstJID	tinyint				-- destination J-ID - J-bus
,	@tiDstRID	tinyint				-- destination R-ID - R-bus
,	@tiBtn		tinyint				-- destination button code
,	@tiSrcJAB	tinyint				-- source J audio-bus?
,	@tiSrcLAB	tinyint				-- source L audio-bus?
,	@tiDstJAB	tinyint				-- destination J audio-bus?
,	@tiDstLAB	tinyint				-- destination L audio-bus?
,	@sSrcDvc	varchar( 16 )		-- source name
,	@sDstDvc	varchar( 16 )		-- destination name
,	@tiBed		tinyint				-- bed index
--,	@cBed		char( 1 )			-- bed name
,	@siPri		smallint			-- call-priority
,	@sCall		varchar( 16 )		-- call-text
,	@tiFlags	tinyint				-- bed flags (privacy status)

--	@idEvent	int out				-- output: inserted idEvent
)
	with encryption
as
begin
	declare		@idEvent	int
		,		@idParent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idCall		smallint
		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
--		,		@cBed		char( 1 )
		,		@iExpNrm	int
		,		@idLogType	tinyint

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@tiBed= null	--, @cBed= null
--	else
--		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@iExpNrm= iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	select	@idLogType= case when	@idCmd = 0x8D	then	199			-- audio quit
							when	@idCmd = 0x8A	then	197			-- audio grant
							when	@idCmd = 0x88	then	196			-- audio busy
							else							195	end		-- audio request
		,	@siIdx=	@siPri & 0x03FF


	if	@siIdx > 0
		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
	else
		select	@idCall= 0				--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed	---	, @iAID, @tiStype, @idCall0

		insert	tbEvent8A	(  idEvent,  tiSrcJAB,  tiSrcLAB,  tiDstJAB,  tiDstLAB,  siPri,  tiFlags,  siIdx )
				values		( @idEvent, @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB, @siPri, @tiFlags, @siIdx )

		--	this one is really not origin, but parent - audio is not being healed
		select	@idOrigin= idEvent,	@dtOrigin= dtEvent
			from	tbEvent_A	with (nolock)
			where	cSys = @cDstSys
				and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiBtn
				and	idCall = @idCall		--	7.05.4976
		---		and	bActive > 0				--	6.05 (6.04 in 84!):	audio events ignore active/inactive state

		if	@idOrigin	is not null
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
				where	idEvent = @idEvent

			if	@idCmd = 0x8A		-- AUDIO GRANT == voice response
			begin
				update	tbEvent_A	set	bAudio= 1							-- connected
					where	idEvent = @idOrigin

				select	@dtOrigin= tOrigin	--, @idParent= idParent
					from	tbEvent		with (nolock)
					where	idEvent = @idEvent

				update	tbEvent_C	set	idEvtVo= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idOrigin		and	idEvtVo is null		-- there should be only one, but just in case - use only 1st one
			end

			else if	@idCmd = 0x8D	-- AUDIO QUIT
			begin
				update	tbEvent_A	set	bAudio= 0							-- disconnected
								,	dtExpires=	case when bActive > 0 then dtExpires
													else dateadd(ss, @iExpNrm, getdate( )) end
					where	idEvent = @idOrigin
			end
		end
		else	-- no origin found
		begin
			update	tbEvent		set	idOrigin= @idEvent,	tOrigin= '0:0:0'
								,	idParent= @idEvent,	tParent= '0:0:0'	--	7.05.4976
								,	@idDstDvc= idSrcDvc,	@dtOrigin= dtEvent
				where	idEvent = @idEvent
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
--	7.05.5290	+ out @idLogType, @idRoom
--				+ out @idEvent (idOrigin)
--	7.05.5205	* prEvent_Ins args
--	7.05.4981	* origin search
--	7.05.4976	- tbEvent_P, tbEvent_T
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.02	* tbEvent.tElapsed -> .tOrigin
--	7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ (nolock)
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--			+ @siPri (to pass in call-index from 0x95 cmd)
--	6.02	tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			@idLoc -> @idUnit
--	5.01	encryption added
--			fix for idDstDvc
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--			fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	2.03	+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	1.00
alter proc		dbo.prEvent95_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint				-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@cDstSys	char( 1 )			-- destination system
,	@tiDstGID	tinyint				-- destination G-ID - gateway
,	@tiDstJID	tinyint				-- destination J-ID - J-bus
,	@tiDstRID	tinyint				-- destination R-ID - R-bus
,	@tiBtn		tinyint				-- destination button code
,	@tiSvcSet	tinyint				-- bit: 1=Aide,2=CNA,4=RN,8=Stat
,	@tiSvcClr	tinyint				-- bit: 1=Aide,2=CNA,4=RN,8=Stat
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
,	@siPri		smallint			-- call index
,	@sCall		varchar( 16 )		-- call text
,	@sInfo		varchar( 16 )		-- tag message text
,	@idUnit		smallint			-- active unit ID

,	@idEvent	int			out		-- output: idOrigin of input event
,	@idLogType	tinyint		out
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@idSrcDvc	smallint
		,		@idDstDvc	smallint
	--	,		@idEvent	int
	--	,		@idLogType	tinyint
	--	,		@idRoom		smallint
		,		@idCall		smallint
		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@cBed		char( 1 )

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@idLogType=	case when @tiSvcSet > 0  and  @tiSvcClr = 0 then 201	-- set svc
							when @tiSvcSet = 0  and  @tiSvcClr > 0 then 203		-- clr svc
							else 202 end										-- set/clr
		,	@siIdx=	@siPri & 0x03FF

	if	@siIdx > 0
		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
	else
		select	@idCall= 0				--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	select	@idOrigin= idEvent, @dtOrigin= dtEvent
		from	tbEvent_A	with (nolock)
		where	cSys = @cDstSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiBtn
			and	idCall = @idCall		--	7.05.4980
			and	bActive > 0				--	7.05.4980

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDevice, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed		---	, @iAID, @tiStype, @idCall0

		insert	tbEvent95	( idEvent,  tiSvcSet,  tiSvcClr )
				values		( @idEvent, @tiSvcSet, @tiSvcClr )

		update	tbEvent		set	idOrigin= @idOrigin,	tOrigin= dtEvent - @dtOrigin
			where	idEvent = @idEvent

	commit

	select	@idEvent= @idOrigin			--	7.05.52??	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	7.05.5297	presence calls
--	7.05.4981	* - tbEvent_T, tEvent_C.tRn|tCn|tAi
--	7.02	tbEvent_C.idCna -> .idCn, .idAide -> .idAi, .tCna -> .tCn, .tAide -> .tAi
--	6.05	+ (nolock), optimize
--	6.04	* optimize event selection range using tbEvent_S
--	6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiLocs -> @tiDvc
--	5.02
alter proc		dbo.prRptCallStatSum
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
--,	@bPres		bit					-- 
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
		select	--	t.*, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg
				t.idCall, t.lCount, t.siIdx, t.sCall, t.tiSpec
			,	case when t.tiSpec in (7,8,9) then null else t.tVoTrg end	tVoTrg, t.tVoAvg, t.tVoMax, t.lVoNul, t.lVoOnT
			,	case when t.tiSpec in (7,8,9) then null else t.tStTrg end	tStTrg, t.tStAvg, t.tStMax, t.lStNul, t.lStOnT
			,	case when t.tVoAvg is null then null else t.lVoOnT*100/(t.lCount-t.lVoNul) end	fVoOnT
			,	case when t.tStAvg is null then null else t.lStOnT*100/(t.lCount-t.lStNul) end	fStOnT
		--	,	f.tVoMax, f.tStMax, t.lVoOut*100/t.lCount fVoOut, t.lStOut*100/t.lCount fStOut
			from
				(select	c.idCall, count(*) lCount
					,	min(f.siIdx)	siIdx,		min(f.sCall)	sCall,		min(p.tiSpec)	tiSpec
					,	min(f.tVoTrg)	tVoTrg,		min(f.tStTrg)	tStTrg
--					,	min(c.siIdx) siIdx, min(c.sCall) sCall, min(c.tVoTrg) tVoTrg, min(c.tStTrg) tStTrg
					,	case when min(p.tiSpec) in (7,8,9) then null
							else cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) ) end	tVoAvg
	--				,	cast(dateadd(ss, avg( datepart(mi,c.tVoice)*60+datepart(ss,c.tVoice)+1 ), '0:0:0') as time(0)) tVoAvg
					,	max(c.tVoice)	tVoMax
					,	sum(case when c.tVoice < f.tVoTrg then 1 else 0 end)	lVoOnT
		--			,	sum(case when c.tVoice > f.tVoMax then 1 else 0 end)	lVoOut
					,	sum(case when c.tVoice is null then 1 else 0 end)	lVoNul
					,	case when min(p.tiSpec) in (7,8,9) then null
							else cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) ) end	tStAvg
	--				,	cast(dateadd(ss, avg( datepart(mi,c.tStaff)*60+datepart(ss,c.tStaff)+1 ), '0:0:0') as time(0)) tStAvg
					,	max(c.tStaff)	tStMax
					,	sum(case when c.tStaff < f.tStTrg then 1 else 0 end)	lStOnT
		--			,	sum(case when c.tStaff > f.tStMax then 1 else 0 end)	lStOut
					,	sum(case when c.tStaff is null then 1 else 0 end)	lStNul
		/*			,	cast( cast( avg( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) )	tAvgRn
					,	cast( cast( avg( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) )	tAvgCn
					,	cast( cast( avg( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) )	tAvgAi
					,	cast( cast( sum( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) )	tTotRn
					,	cast( cast( sum( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) )	tTotCn
					,	cast( cast( sum( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) )	tTotAi
					,	sum(case when c.tRn is not null then 1 else 0 end)	lCntRn
					,	sum(case when c.tCn is not null then 1 else 0 end)	lCntCn
					,	sum(case when c.tAi is not null then 1 else 0 end)	lCntAi
		*/		from			tbEvent_C	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	--and
		/*										(@bPres = 0		and	(p.tiSpec is null	or	p.tiSpec not in (7,8,9))
												or	@bPres > 0	and	p.tiSpec in (7,8,9))
				from	(select	c.idCall, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg, c.tVoice, c.tStaff
							,	case when p.tiSpec = 7 then	tStaff else null end	[tRn]
							,	case when p.tiSpec = 8 then	tStaff else null end	[tCn]
							,	case when p.tiSpec = 9 then	tStaff else null end	[tAi]
							from			tbEvent_C	c	with (nolock)
								inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
								inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	--and	p.tiSpec not in (7,8,9)
							where	c.idEvent	between @idFrom	and @idUpto
								and	c.tiHH		between @tFrom	and @tUpto)	c	--with (nolock)
		*/		where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				group	by c.idCall--, sCall
				)	t
		--		inner join	tb_SessCall f	on	f.idCall = t.idCall	and	f.idSess = @idSess
			order by	t.siIdx desc		--lCount desc
	else
		select	--	t.*, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg
				t.idCall, t.lCount, t.siIdx, t.sCall, t.tiSpec
			,	case when t.tiSpec in (7,8,9) then null else t.tVoTrg end	tVoTrg, t.tVoAvg, t.tVoMax, t.lVoNul, t.lVoOnT
			,	case when t.tiSpec in (7,8,9) then null else t.tStTrg end	tStTrg, t.tStAvg, t.tStMax, t.lStNul, t.lStOnT
			,	case when t.tVoAvg is null then null else t.lVoOnT*100/(t.lCount-t.lVoNul) end	fVoOnT
			,	case when t.tStAvg is null then null else t.lStOnT*100/(t.lCount-t.lStNul) end	fStOnT
		--	,	f.tVoMax, f.tStMax, t.lVoOut*100/t.lCount fVoOut, t.lStOut*100/t.lCount fStOut
			from
				(select	c.idCall, count(*) lCount
					,	min(f.siIdx)	siIdx,		min(f.sCall)	sCall,		min(p.tiSpec)	tiSpec
					,	min(f.tVoTrg)	tVoTrg,		min(f.tStTrg)	tStTrg
--					,	min(c.siIdx) siIdx, min(c.sCall) sCall, min(c.tVoTrg) tVoTrg, min(c.tStTrg) tStTrg
					,	cast( cast( avg( cast( --case when p.tiSpec in (7,8,9) then null else end
							cast(c.tVoice as datetime) as float) ) as datetime) as time(3) )	tVoAvg
					,	max(c.tVoice)	tVoMax
					,	sum(case when c.tVoice < f.tVoTrg then 1 else 0 end)	lVoOnT
		--			,	sum(case when c.tVoice > f.tVoMax then 1 else 0 end)	lVoOut
					,	sum(case when c.tVoice is null then 1 else 0 end)	lVoNul
					,	cast( cast( avg( cast( --case when p.tiSpec in (7,8,9) then null else end
							cast(c.tStaff as datetime) as float) ) as datetime) as time(3) )	tStAvg
					,	max(c.tStaff)	tStMax
					,	sum(case when c.tStaff < f.tStTrg then 1 else 0 end)	lStOnT
		--			,	sum(case when c.tStaff > f.tStMax then 1 else 0 end)	lStOut
					,	sum(case when c.tStaff is null then 1 else 0 end)	lStNul
		/*			,	cast( cast( avg( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) )	tAvgRn
					,	cast( cast( avg( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) )	tAvgCn
					,	cast( cast( avg( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) )	tAvgAi
					,	cast( cast( sum( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) )	tTotRn
					,	cast( cast( sum( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) )	tTotCn
					,	cast( cast( sum( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) )	tTotAi
					,	sum(case when c.tRn is not null then 1 else 0 end)	lCntRn
					,	sum(case when c.tCn is not null then 1 else 0 end)	lCntCn
					,	sum(case when c.tAi is not null then 1 else 0 end)	lCntAi
		*/		from			tbEvent_C	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	--and
		/*										(@bPres = 0		and	(p.tiSpec is null	or	p.tiSpec not in (7,8,9))
												or	@bPres > 0	and	p.tiSpec in (7,8,9))
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
				from	(select	c.idCall, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg, c.tVoice, c.tStaff
							,	case when p.tiSpec = 7 then	tStaff else null end	[tRn]
							,	case when p.tiSpec = 8 then	tStaff else null end	[tCn]
							,	case when p.tiSpec = 9 then	tStaff else null end	[tAi]
							from			tbEvent_C	c	with (nolock)
								inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
								inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	--and	p.tiSpec not in (7,8,9)
								inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
							where	c.idEvent	between @idFrom	and @idUpto
								and	c.tiHH		between @tFrom	and @tUpto)	c	--with (nolock)
		*/		where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				group	by c.idCall--, sCall
				)	t
		--		inner join	tb_SessCall f	on	f.idCall = t.idCall	and	f.idSess = @idSess
			order by	t.siIdx desc		--lCount desc
end
go
--	----------------------------------------------------------------------------
--	7.05.5297	presence calls
--	6.05	+ (nolock), optimize
--	6.04	* optimize event selection range using tbEvent_S
--	6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiLocs -> @tiDvc
--	5.02
alter proc		dbo.prRptCallStatSumGraph
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tbRptSessDvc), 0=<invalid>
--,	@bPres		bit					-- ignored
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
		select	c.dEvent,	count(*)	[lCount]
		--		,	min(f.tVoTrg)	[tVoTrg],	min(f.tStTrg)	[tStTrg]
				,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
				,	max(c.tVoice)	[tVoMax]
				,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
				,	max(c.tStaff)	[tStMax]
			from			tbEvent_C	c	with (nolock)
				inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
				inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	and	(p.tiSpec is null	or	p.tiSpec not in (7,8,9))
			where	c.idEvent	between @idFrom	and @idUpto
				and	c.tiHH		between @tFrom	and @tUpto
			group	by c.dEvent
	else
		select	c.dEvent,	count(*)	[lCount]
		--		,	min(f.tVoTrg)	[tVoTrg],	min(f.tStTrg)	[tStTrg]
				,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
				,	max(c.tVoice)	[tVoMax]
				,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
				,	max(c.tStaff)	[tStMax]
			from			tbEvent_C	c	with (nolock)
				inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
				inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
				inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	and	(p.tiSpec is null	or	p.tiSpec not in (7,8,9))
			where	c.idEvent	between @idFrom	and @idUpto
				and	c.tiHH		between @tFrom	and @tUpto
			group	by c.dEvent
end
go
--	----------------------------------------------------------------------------
--	7.05.5302	presence calls
--	7.05.4981	* - tbEvent_T, tEvent_C.tRn|tCn|tAi
--	7.02	tbEvent_C.idCna -> .idCn, .idAide -> .idAi, .tCna -> .tCn, .tAide -> .tAi
--	6.05	+ (nolock), optimize
--	6.04	* optimize event selection range using tbEvent_S
--	6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiLocs -> @tiDvc
--	5.01
alter proc		dbo.prRptCallActSum
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@cBed		char( 1 )			-- 0=any/none, >0 =specific
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
		if	@cBed is null
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall, p.siIdx, p.tiSpec
				,	case when p.tiSpec between 7 and 9	then	0 else 1 end	[iCall]
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tGrn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tOra]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tYel]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				order	by	c.sDevice, c.idEvent
		else
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall, p.siIdx, p.tiSpec
				,	case when p.tiSpec between 7 and 9	then	0 else 1 end	[iCall]
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tGrn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tOra]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tYel]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
					and	(c.cBed = @cBed	or	c.cBed is null)
				order	by	c.sDevice, c.idEvent
	else
		if	@cBed is null
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall, p.siIdx, p.tiSpec
				,	case when p.tiSpec between 7 and 9	then	0 else 1 end	[iCall]
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tGrn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tOra]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tYel]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				order	by	c.sDevice, c.idEvent
		else
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall, p.siIdx, p.tiSpec
				,	case when p.tiSpec between 7 and 9	then	0 else 1 end	[iCall]
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tGrn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tOra]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tYel]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
					and	(c.cBed = @cBed	or	c.cBed is null)
				order	by	c.sDevice, c.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.05.5304	+ .siIdx, .tiSpec, .tiSvc
--	7.05.5203	+ 'e.idEvent between @idFrom and @idUpto' and 'e.tiHH between @tFrom and @tUpto'
--	7.05.5095	* tbEvent41
--	7.05.5065	* .sCall, .sInfo
--	7.05.4981	* - tbEvent_T, tEvent_C.tRn|tCn|tAi
--	7.04.4896	* tbDefCall -> tbCall
--	7.02	tbEvent.tElapsed -> .tOrigin
--	6.05	+ (nolock), optimize
--	6.04	* optimize event selection range using tbEvent_S
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			tbDefType -> tbEvType (fkEvent_DefType -> fkEvent_EvType)
--			@tiLocs -> @tiDvc
--	5.02
alter proc		dbo.prRptCallActDtl
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@cBed		char( 1 )			-- null=any/none, >0 =specific
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
--		if	@cBed is null
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	c.siIdx, pr.tiSpec, e95.tiSvcSet | e95.tiSvcClr	[tiSvc]
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbCfgPri	pr	with (nolock)	on	pr.siIdx = c.siIdx
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
				order	by	s.sDevice, s.idParent, e.idEvent
/*		else
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
						and		(t.cBed = @cBed	or	t.cBed is null)
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
				order	by	s.sDevice, s.idParent, e.idEvent
*/	else
--		if	@cBed is null
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	c.siIdx, pr.tiSpec, e95.tiSvcSet | e95.tiSvcClr	[tiSvc]
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = t.idRoom
						join	tb_SessCall f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbCfgPri	pr	with (nolock)	on	pr.siIdx = c.siIdx
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
				order	by	s.sDevice, s.idParent, e.idEvent
/*		else
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = t.idRoom
						join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
						and		(t.cBed = @cBed	or	t.cBed is null)
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
				order	by	s.sDevice, s.idParent, e.idEvent
*/
end
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 255=any, 1=specific (tbRptSessDvc), 0=include no-device events
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

/*	select	@idFrom=	min(idEvent)
		from	tbEvent_S
		where	@dFrom <= dEvent	and	@tFrom <= tiHH
	select	@idUpto=	min(idEvent)
		from	tbEvent_S
		where	@dUpto = dEvent		and	@tUpto < tiHH
			or	@dUpto < dEvent
	if	@idUpto is null
		select	@idUpto=	2147483647	--	max int
---	select	@dFrom dFrom, @idFrom idFrom, @dUpto dUpto, @idUpto idUpto
*/
	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent, e.tiHH
			,	e.idCmd, k.sCmd, e.tiBtn, e.sRoom, b.cBed	--, e.idRoom, e.tiBed
			,	e.idLogType, e.sLogType, e.idCall
			,	c.siIdx, pr.tiSpec, e95.tiSvcSet | e95.tiSvcClr	[tiSvc]
			,	case when e.idLogType > 0 then e.sLogType else k.sCmd end +
				case when e95.idEvent > 0 then ' ' +
					case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
					else '' end	[sEvent]
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc	--, e.sSrcDial
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case when e41.idEvent > 0 then pd.sFqDvc else e.sDstDvc end	[sDstDvc]
	--		,	case when e41.idEvent > 0 then pt.sPcsType else e.sInfo end	[sInfo]
			,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
					case when ec.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
	--		,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)		[siIdx]
			,	case when e.idCmd > 0 then e.sCall else k.sCmd end	[sCall]
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
			left join	tbCfgPri	pr	with (nolock)	on	pr.siIdx = c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u	with (nolock)	on	u.idUser = ec.idUser
			left join	vwStaff		u2	with (nolock)	on	u2.idUser = ec.idUser
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
			left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
			left join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
			left join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
	---		where	e.dEvent	between @dFrom	and @dUpto
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else if	@tiDvc = 1
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent, e.tiHH
			,	e.idCmd, k.sCmd, e.tiBtn, e.sRoom, b.cBed	--, e.idRoom, e.tiBed
			,	e.idLogType, e.sLogType, e.idCall
			,	c.siIdx, pr.tiSpec, e95.tiSvcSet | e95.tiSvcClr	[tiSvc]
			,	case when e.idLogType > 0 then e.sLogType else k.sCmd end +
				case when e95.idEvent > 0 then ' ' +
					case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
					else '' end	[sEvent]
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc	--, e.sSrcDial
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case when e41.idEvent > 0 then pd.sFqDvc else e.sDstDvc end	[sDstDvc]
	--		,	case when e41.idEvent > 0 then pt.sPcsType else e.sInfo end	[sInfo]
			,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
					case when ec.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
	--		,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)		[siIdx]
			,	case when e.idCmd > 0 then e.sCall else k.sCmd end	[sCall]
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			join		tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
			left join	tbCfgPri	pr	with (nolock)	on	pr.siIdx = c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u	with (nolock)	on	u.idUser = ec.idUser
			left join	vwStaff		u2	with (nolock)	on	u2.idUser = ec.idUser
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
			left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
			left join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
			left join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent, e.tiHH
			,	e.idCmd, k.sCmd, e.tiBtn, e.sRoom, b.cBed	--, e.idRoom, e.tiBed
			,	e.idLogType, e.sLogType, e.idCall
			,	c.siIdx, pr.tiSpec, e95.tiSvcSet | e95.tiSvcClr	[tiSvc]
			,	case when e.idLogType > 0 then e.sLogType else k.sCmd end +
				case when e95.idEvent > 0 then ' ' +
					case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
					else '' end	[sEvent]
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc	--, e.sSrcDial
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case when e41.idEvent > 0 then pd.sFqDvc else e.sDstDvc end	[sDstDvc]
	--		,	case when e41.idEvent > 0 then pt.sPcsType else e.sInfo end	[sInfo]
			,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
					case when ec.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
	--		,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)		[siIdx]
			,	case when e.idCmd > 0 then e.sCall else k.sCmd end	[sCall]
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			left join	tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
			left join	tbCfgPri	pr	with (nolock)	on	pr.siIdx = c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u	with (nolock)	on	u.idUser = ec.idUser
			left join	vwStaff		u2	with (nolock)	on	u2.idUser = ec.idUser
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
			left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
			left join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
			left join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
				and	(e.idSrcDvc in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcDvc is null)
			order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge
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
)
	with encryption, exec as owner
as
begin
---	set	nocount	on
	begin	tran

		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
		begin
			update	tbRtlsBadge	set	bActive= 1, dtUpdated= getdate( )
				where	idBadge = @idBadge	and	bActive = 0

			update	tbDvc		set	bActive= 1, dtUpdated= getdate( )
				where	idDvc = @idBadge	and	bActive = 0
		end
		else
		begin
			set identity_insert	dbo.tbDvc	on

			insert	tbDvc	( idDvc, idDvcType, sDvc )
					values		( @idBadge, 1, 'Badge ' + right('00000000' + cast(@idBadge as varchar), 8) )

			set identity_insert	dbo.tbDvc	off

			insert	tbRtlsBadge	(  idBadge )
					values		( @idBadge )
		end

	commit
end
go
--	----------------------------------------------------------------------------
begin tran
	delete	from	dbo.tb_Access	where	idModule = 92
	delete	from	dbo.tb_Feature	where	idModule = 92
commit
go


if	not	exists	( select 1 from tb_Version where idVersion = 706 )
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 706,	0, getdate( ), getdate( ),	'_' )
go
update	tb_Version	set	dtCreated= '2014-07-15', siBuild= 5309, dtInstall= getdate( )
	,	sVersion= '7.06.5309 - healing events not stored, reports modified, full 7980cw features'
	where	idVersion = 706
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.6.5309'
	where	idModule = 1
go
exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.5309 )'
go

checkpoint
go

use [master]
go
