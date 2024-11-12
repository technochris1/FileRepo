--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2015-Mar-23		.5560
--						* tb_Module[61,62,64,111]
--						* prDevice_GetIns
--		2015-Mar-25		.5562
--						+ tbEvent_B, * tbEvent: .vbCmd -> tbEvent_B, .tiLen -> tbEvent_B
--							* prEvent_A_Exp, prEvent_Maint, prEvent_Ins
--		2015-Mar-26		.5563
--						* tbCall[0] INTERCOM -> NO CALL
--						- tbCall.xuCall_Active_sCall (prCall_Imp)
--						* prEvent_A_GetAll
--						+ tbStfLvl[8]
--						* pr_User_GetByUnit
--		2015-Mar-30		.5567
--						* pr_User_GetByUnit -> pr_User_GetAll (merge)
--						* pr_User_sStaff_Upd
--						+ prUnit_GetAll
--						* xu_User -> xu_User_Login--
--		2015-Mar-31		.5568
--						* pr_UserUnit_Set
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 5568 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.5568', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByUnit')
	drop proc	dbo.pr_User_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_B')
	drop view	dbo.tbEvent_B
go
--	----------------------------------------------------------------------------
--	7.06.5560	* [61,62,64,111]
begin tran
	update	tb_Module	set	sModule= 'J7980ns'	where	idModule = 61
	update	tb_Module	set	sModule= 'J7980cw'	where	idModule = 62
	update	tb_Module	set	sModule= 'J7982cw'	where	idModule = 64
	update	tb_Module	set	sModule= 'J7985cw'	where	idModule = 111
commit
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	if	charindex('SIP:', @sDevice) = 1								-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ' )'

	-- match 7967-P workflow station's (0x1A) 'phantom' RIDs
	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow
		select	@idDevice=	idDevice,	@bActive =	bActive
			from	tbDevice	with (nolock)
			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	--and	bActive > 0

		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice

			return	0												-- match found
		end
	end

	-- adjust AID
	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID = 0
		select	@iAID=	null


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

	if	@idDevice > 0																			--	7.06.5560
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		return	0													-- match found
	end

	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	begin
		begin	tran

			if	charindex(@cSys, @sSysts) = 0						-- not in Allowed Systems
			begin
				select	@s =	@s + '  cSys'
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

				if	@iTrace & 0x04 > 0
				begin
					select	@s =	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
					exec	dbo.pr_Log_Ins	74, null, null, @s
				end
			end

		commit
	end
	else															-- no name / system				7.06.5560
	begin
		select	@s =	@s + '  sDvc,cSys'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	System activity binary log
--	7.06.5562
create table	dbo.tbEvent_B
(
	idEvent		int				not null	-- ?? bigint
		constraint	xpEventB	primary key clustered
		constraint	fkEventB_Event	foreign key references tbEvent	on delete cascade

,	tiLen		tinyint			not null	-- message length
--		constraint	tdEvent_Len		default( 0 )
,	vbCmd		varbinary( 256 ) not null	-- message
)
go
grant	select, insert, update, delete	on dbo.tbEvent_B		to [rWriter]
grant	select							on dbo.tbEvent_B		to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5562	* tbEvent: .vbCmd -> tbEvent_B, .tiLen -> tbEvent_B
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent') and name = 'vbCmd')
begin
	begin tran
		exec( 'insert	tbEvent_B	(idEvent, tiLen, vbCmd)
					select	idEvent, tiLen, vbCmd
						from	tbEvent
						where	tiLen	is not null
						and		vbCmd	is not null
			' )

		alter table	dbo.tbEvent		drop column		tiLen
		alter table	dbo.tbEvent		drop column		vbCmd
	commit
end
go
--	----------------------------------------------------------------------------
--	Removes expired calls
--	7.06.5562	- @tiPurge, - event removal (-> prEvent_Maint)
--	7.05.5204	* tbLogType:	+ [194]		healing events are now explicitly marked => no lookup into tbEvent84 is needed
--	7.05.4976	- tbEvent_P, tbEvent_T
--	7.04.4897	* tbEvent_C:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt, .idRn -> .idEvtRn, .idCn -> .idEvtCn, .idAi -> .idEvtAi
--				* tbEvent_T:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt
--	7.02	refactor
--			* commented resetting tbRoomBed (prEvent84_Ins should deal with that)
--			* commented removal with no tbEvent_P (DELETE conflicted with ref constraint "fkEventC_Event_Aide")
--	7.00	+ pr_Module_Act call
--	6.05	* reset tbDevice.idEvent
--			* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--			tracing
--	6.04	+ removal from tbRoomBed.idEvent
--			+ removal of healing 84s
--	6.03	+ removal of inactive events
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	5.01
alter proc		dbo.prEvent_A_Exp
	with encryption
as
begin
	declare		@dt		datetime
--		,		@s		varchar( 255 )
--		,		@i		int

	set	nocount	on

	exec	dbo.pr_Module_Act	1

	begin	tran

		select	@dt =	getdate( )									-- mark starting time

		update	r	set	r.idEvent =		null						-- reset tbRoom.idEvent		v.7.02
			from	tbRoom	r
			join	tbEvent_A	ea	on	ea.idEvent = r.idEvent
			where	ea.dtExpires < @dt

		update	rb	set	rb.idEvent =	null						-- reset tbRoomBed.idEvent	v.7.02
			from	tbRoomBed	rb
			join	tbEvent_A	ea	on	ea.idEvent = rb.idEvent
			where	ea.dtExpires < @dt

		delete	from	tbEvent_A	where	dtExpires < @dt			-- remove expired calls

/*		if	@tiPurge > 0
		begin
			if	@tiPurge = 255										-- remove all inactive events
			begin
				update	c	set	c.idEvtVo=	null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtVo
					where	a.idEvent is null

				update	c	set	c.idEvtSt=	null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtSt
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left join	tbEvent_A a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
							' inactive events in ' + convert(varchar, getdate() - @dt, 114)
				exec	dbo.pr_Log_Ins	2, null, null, @s
			end
			else	--	if	@tiPurge < 255			--	remove healing 84s
			begin
				declare		@idEvent	int

				select	@idEvent=	max(idEvent)	--	get latest idEvent before which healing 84s are to be removed
					from	tbEvent_S
					where	dEvent <= dateadd(dd, -@tiPurge, @dt)
					and		tiHH <= datepart(hh, @dt)

				delete	from	tbEvent
					where	idLogType = 194
					and		idEvent < @idEvent

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
							' healing events in ' + convert(varchar, getdate() - @dt, 114)
				exec	dbo.pr_Log_Ins	2, null, null, @s
			end
		end
*/
	commit
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.5562	* tbEvent: .vbCmd -> tbEvent_B, .tiLen -> tbEvent_B
--	7.06.5490	* 'dat:','log:' -> 'D:','L:'
--	7.05.5169	* wipe tbEvent.vbCmd for events older than 60 days
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ reporting DB sizes in tb_Module[1]
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prEvent_Maint
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@dt			smalldatetime
--		,		@iSizeDat	int
--		,		@iSizeLog	int
		,		@idEvent	int
		,		@tiPurge	tinyint
--		,		@tiPurge	tinyint			-- 0=don't remove any events
											-- N=remove healing 84s older than N days (cascaded)
											-- 255=remove all inactive events from [tbEvent*] (cascaded)

	set	nocount	on

	select	@dt =	getdate( )										-- smalldatetime truncates seconds
		,	@s =	'@' + @@servicename

--	select	@iSizeDat=	size/128	from	sys.database_files	with (nolock)	where	file_id = 1		--	type = 0
--	select	@iSizeLog=	size/128	from	sys.database_files	with (nolock)	where	file_id = 2		--	type = 1

	select	@s +=	', D:' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 0

	select	@s +=	', L:' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 1

--	update	tb_Module	set	sParams =	'@ ' + @@servicename + ', D:' + cast(@iSizeDat as varchar) + ', L:' + cast(@iSizeLog as varchar)
--		where	idModule = 1
	update	tb_Module	set	sParams =	@s		where	idModule = 1

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

--	if	@tiPurge > 0												--	7.06.5562
--		exec	dbo.prEvent_A_Exp	@tiPurge
	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge = 0											-- remove all inactive events
		begin
/*			update	c	set	c.idEvtVo=	null
				from	tbEvent_C c
				left join	tbEvent_A a	on	a.idEvent = c.idEvtVo
				where	a.idEvent is null

			update	c	set	c.idEvtSt=	null
				from	tbEvent_C c
				left join	tbEvent_A a	on	a.idEvent = c.idEvtSt
				where	a.idEvent is null
*/
			delete	e	from	tbEvent e
				left join	tbEvent_A a	on	a.idEvent = e.idEvent
				where	a.idEvent is null

			select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
						' inactive events in ' + convert(varchar, getdate() - @dt, 114)
			exec	dbo.pr_Log_Ins	2, null, null, @s
		end

		select	@idEvent =	max(idEvent)							-- get latest idEvent to be removed
			from	tbEvent_S
			where	dEvent <= dateadd(dd, -@tiPurge, @dt)
			and		tiHH <= datepart(hh, @dt)

		delete	from	tbEvent_B
			where	idEvent < @idEvent

		update	tb_OptSys	set	iValue =	@idEvent,	dtUpdated=	@dt		where	idOption = 19

/*		select	@iSizeDat=	iValue	from	tb_OptSys	with (nolock)	where	idOption = 19

		select	@iSizeLog=	idEvent
			from	tbEvent_S
			where	dEvent < dateadd(dd, -60, @dt)	and	tiHH = datepart(hh, @dt)

		update	tbEvent		set	vbCmd=	null
			where	idEvent between @iSizeDat and @iSizeLog
			and		vbCmd is not null

		update	tb_OptSys	set	iValue =	@iSizeLog,	dtUpdated=	@dt		where	idOption = 19
*/
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
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
	declare		@s			varchar( 255 )
		,		@p			varchar( 16 )
		,		@dtEvent	datetime
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

	set	nocount	on

	select	@dtEvent =	getdate( ),		@p =	''
		,	@tiHH =		datepart( hh, getdate( ) )
		,	@cDevice =	case when @idCmd = 0x83 then 'G' else '?' end

	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	select	@s =	'Evt_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sSrcDvc,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(cast(@tiDstGID as varchar),'?') + '-' + isnull(cast(@tiDstJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sDstDvc,'?') + '", b=' + isnull(cast(@tiBed as varchar),'?') + ', i="' + isnull(@sInfo,'?') + '" )'

	if	@tiBed = 0xFF
		select	@tiBed =	null
	else
	if	@tiBed > 9
		select	@tiBed =	null,	@p =	@p + '  bed'

	if	@idUnit > 0	and
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
--		not exists	(select 1 from tbCfgLoc where idLoc = @idUnit and cLoc = 'U')
		select	@idUnit =	null,	@p =	@p + '  unit'

	begin	tran

		if	@tiBed is not null										-- mark a bed in active use
			update	tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)			-- audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiShelf =	@tiSrcRID,	@sDvc =		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiShelf,	@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

		exec		dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

		if	@idCmd <> 0x84	or	@idLogType <> 194					-- skip healing 84s
		begin
	--		insert	tbEvent	(  idCmd,  tiLen,  iHash,  vbCmd,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit
			insert	tbEvent	(  idCmd,  iHash,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit
							,	cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  idSrcDvc
							,	cDstSys,  tiDstGID,  tiDstJID,  tiDstRID,  idDstDvc
							,	dtEvent,  dEvent,   tEvent,   tiHH )
	--				values	( @idCmd, @tiLen, @iHash, @vbCmd, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit
					values	( @idCmd, @iHash, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit
							,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @idSrcDvc
							,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @idDstDvc
							,	@dtEvent, @dtEvent, @dtEvent, @tiHH )
			select	@idEvent =	scope_identity( )

			if	@tiLen > 0	and	@vbCmd is not null
				insert	tbEvent_B	(  idEvent,  tiLen,  vbCmd )			--	7.06.5562
						values		( @idEvent, @tiLen, @vbCmd )
		end

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

		if	len(@p) > 0
		begin
			select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
			exec	dbo.pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02								-- set tbEvent.idParent, .idRoom, .tParent; tbRoom.idUnit
		begin

			select	@idParent=	idEvent,	@dtParent=	dtEvent		--	7.04.4968
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

			if	@idParent > 0
				update	tbEvent		set	idParent =	@idParent,	idRoom =	@idRoom,	tParent =	dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	tbEvent		set	idParent =	@idEvent,	idRoom =	@idRoom,	tParent =	'0:0:0'
					where	idEvent = @idEvent

			if	@idUnit > 0		and	@idRoom > 0						--	7.02	7.05.5205
				update	tbRoom		set	idUnit =	@idUnit
					where	idRoom = @idRoom
		end

		if	@idEvent > 0											-- update event statistics
		begin
			select	@idParent=	null
			select	@idParent=	idEvent
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
		,		@p			varchar( 16 )
		,		@idParent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idCall		smallint
		,		@idCall0	smallint
		,		@siBed		smallint
		,		@siIdxOld	smallint
		,		@siIdxNew	smallint
		,		@idDoctor	int
		,		@idPatient	int
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@dtEvent	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiPurge	tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int

	set	nocount	on

	select	@tiPurge =	cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 7
	select	@iExpNrm =	iValue						from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue						from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null

	select	@s =	'E84_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(@iAID as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(cast(@tiDstGID as varchar),'?') + '-' + isnull(cast(@tiDstJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + '  bed'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed


	if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + '  unit'


	if	@siIdxNew > 0										-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiSpec =	tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew		-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0									-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiSpec =	tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0									-- INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out	-- no need to call


	if	@tiSpec between 7 and 9
		select	@bPresence =	1,	@tiBed =	0xFF		-- mark 'presence' calls and force room-level


	if	@tiBed is not null	and	len(@sPatient) > 0			-- only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
	end


	-- adjust need-timers (0=no need, 1=[G,O,Y] present, 2=need OT, 3=need request)
	if	@tiTmrA > 3		select	@tiTmrA =	3
	if	@tiTmrG > 3		select	@tiTmrG =	3
	if	@tiTmrO > 3		select	@tiTmrO =	3
	if	@tiTmrY > 3		select	@tiTmrY =	3


	-- origin points to the first still active event that started call-sequence for this SGJRB
	select	@idOrigin=	idEvent,	@dtOrigin=	dtEvent,	@bAudio =	bAudio
		from	tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0
			and	(idCall = @idCall	or	idCall = @idCall0)		--	7.05.4976

	select	@tiSvc =	@tiTmrA * 0x40 + @tiTmrG * 0x10 + @tiTmrO * 0x04 + @tiTmrY
		,	@idLogType =	case when	@idOrigin is null	then							-- call placed
									case when	@bPresence > 0	then 206	else 191 end
								when	@siIdxNew = 0		then							-- cancelled
									case when	@bPresence > 0	then 207	else 193 end
								else														-- escalated or healing
									case when	@idCall0 > 0	then 192	else 194 end	end

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

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

			if	len(@p) > 0
			begin
				select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

		exec	dbo.prRoom_UpdStaff		@idRoom, @idUnit, @sStaffG, @sStaffO, @sStaffY


		if	@idOrigin is null								-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss, @siElapsed, '0:0:0')
								,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent)
								,	@idSrcDvc=	idSrcDvc,	@idParent=	idParent
				where	idEvent = @idEvent

			insert	tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
									siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,
									tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
									@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, @tiSvc, dateadd(ss, @iExpNrm, @dtEvent),
									@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

	--		if	@idRoom > 0		and							-- 'medical' call or 'presence'		--	7.05.5212
	--			(@tiShelf > 0	and	( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 )
	--			or	@bPresence > 0)
			if	@idRoom > 0									-- record every call in tbEvent_C	--	7.06.5562
				begin
					select	@idUser =	case
								when @tiSpec = 7	then idUserG
								when @tiSpec = 8	then idUserO
								when @tiSpec = 9	then idUserY
								else					 null	end
						from	tbRoom	with (nolock)
						where	idRoom = @idRoom

					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idRoom,  idUnit,  tiBed,  siBed, idUser1, tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idRoom, @idUnit, @tiBed, @siBed, @idUser, datepart(hh, @dtOrigin) )

					update	c	set	c.idUser1=	rb.idUser1,		c.idUser2=	rb.idUser2,		c.idUser3=	rb.idUser3	--	7.06.5326
						from	tbEvent_C	c
						join	tbRoomBed	rb	on	rb.idRoom = @idRoom		and	( rb.tiBed = @tiBed		or	@tiBed is null	and	( rb.tiBed = 0xFF	or	rb.tiBed = 1 ) )
						where	c.idEvent = @idEvent
				end

			select	@idOrigin=	@idEvent
		end

		else												-- active origin found	(=> call healed/escalated/cancelled)
		begin
			update	tbEvent		set	idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin
				where	idEvent = @idEvent

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	idCall =	@idCall
				where	idEvent = @idOrigin					--	7.05.5065

			update	tbEvent_A	set	tiSvc=	@tiSvc			-- update state for all calls in this room
				where	idRoom = @idRoom					--	7.06.5534
		end


		if	@siIdxNew = 0									-- call cancelled
		begin
	--		select	@dtOrigin=	case when @bAudio = 0 then dateadd(ss, @iExpNrm, @dtEvent)
	--												else dateadd(ss, @iExpExt, @dtEvent) end

			update	tbEvent_A	set	dtExpires=	case when @bAudio = 0 then dateadd(ss, @iExpNrm, @dtEvent)
																	else dateadd(ss, @iExpExt, @dtEvent) end	--@dtOrigin
							,	tiSvc=	null,	bActive =	0
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

			select	@dtOrigin=	tOrigin,	@idParent=	idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent

			update	tbEvent_C	set	idEvtSt =	@idEvent,	tStaff =	@dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null		-- there should be only one, but just in case - use only 1st one
		end


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


		---	!! @idEvent no longer points to current event !!

		-- set tbRoom.idEvent and .tiSvc to highest oldest active call for this room
		select	@idEvent =	null,	@tiSvc =	null
		select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent							-- oldest in recorded order
		---	order	by	siIdx desc, tElapsed desc					-- call may have started before it was recorded

		update	tbRoom	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
			where	idRoom = @idRoom

		-- clear room state when there's no 'presence'		--	7.06.5534
		if	@tiSvc is null	or	@tiSvc & 0x30 <> 0x10
			update	tbRoom	set	idUserG= null, sStaffG= null	where	idRoom = @idRoom
		if	@tiSvc is null	or	@tiSvc & 0x0C <> 0x04
			update	tbRoom	set	idUserO= null, sStaffO= null	where	idRoom = @idRoom
		if	@tiSvc is null	or	@tiSvc & 0x03 <> 0x01
			update	tbRoom	set	idUserY= null, sStaffY= null	where	idRoom = @idRoom


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
				order	by	siIdx desc, idEvent							-- oldest in recorded order
			---	order	by	siIdx desc, tElapsed desc					-- call may have started before it was recorded

			update	tbRoomBed	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
				where	idRoom = @idRoom	and	tiBed = @tiBed

			fetch next from	cur	into	@tiBed
		end
		close	cur
		deallocate	cur

	commit

	select	@idEvent =	@idOrigin			--	7.05.5267	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	7.06.5563	- xuCall_Active_sCall (duplicate call-texts allowed, siIdx is the ID)
--				* [0] INTERCOM -> NO CALL
if	exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tbCall') and name = 'xuCall_Active_sCall')
begin
	begin tran
--		alter table		dbo.tbCall	drop index	xuCall_Active_sCall
		drop index	tbCall.xuCall_Active_sCall

		update	dbo.tbCall	set	sCall=	'NO CALL'	where	idCall = 0
	commit
end
go
--	----------------------------------------------------------------------------
--	Imports enabled call-texts from tbCfgPri
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
	declare		@s			varchar( 255 )
		,		@dtNow		smalldatetime
		,		@idTxt		smallint
		,		@idIdx		smallint
		,		@siIdx		smallint			-- call-index
		,		@sCall		varchar( 16 )		-- call-text
		,		@iCount		smallint

	declare		cur		cursor fast_forward for
		select	siIdx, sCall
			from	tbCfgPri	with (nolock)
			where	siIdx > 0	and	tiFlags & 0x02 > 0		-- enabled
/*		select	min(siIdx), sCall									--	7.06.5563
			from	tbCfgPri	with (nolock)
			where	siIdx > 0	and	tiFlags & 0x02 > 0		-- enabled
			group	by sCall
*/
	set	nocount	on

	select	@dtNow =	getdate( )									-- smalldatetime truncates seconds
		,	@iCount =	0

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall
		while	@@fetch_status = 0
		begin
	--		print	cast(@siIdx as varchar) + ': ' + @sCall
			select	@idTxt =	-1,		@idIdx =	-1
			select	@idIdx =	idCall		from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0
			select	@idTxt =	idCall		from	tbCall	with (nolock)	where	sCall = @sCall	and	bActive > 0
	--		print	' byTxt=' + cast(@idTxt as varchar) + ', byIdx=' + cast(@idIdx as varchar)

			if	@idTxt < 0	or	@idIdx < 0	or	@idTxt <> @idIdx
			begin
				if	@idTxt > 0
					update	tbCall	set	bActive =	0,	dtUpdated=	@dtNow		where	idCall = @idTxt
	--				print	'  mark inactive byTxt ' + cast(@idTxt as varchar)
				if	@idIdx > 0
					update	tbCall	set	bActive =	0,	dtUpdated=	@dtNow		where	idCall = @idIdx
	--				print	'  mark inactive byIdx ' + cast(@idIdx as varchar)

	--			print	'  insert new'
				insert	tbCall	(  siIdx,  sCall )
						values	( @siIdx, @sCall )

				select	@iCount =	@iCount + 1
			end

			fetch next from	cur	into	@siIdx, @sCall
		end
		close	cur
		deallocate	cur

		select	@s =	'Call_Imp( ) added ' + cast(@iCount as varchar) + ' rows'
		exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns active call, filtered according to args
--	7.06.5563	+ .tiShelf
--	7.06.5410
alter proc		dbo.prEvent_A_GetAll
(
	@idUser		int			= null	-- null=any
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bVisible	bit			= 0		-- 0=exclude, 1=include (Invisible shelf)
)
	with encryption
as
begin
--	set	nocount	on
	select	idEvent, dtEvent, sSGJRB	--, cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, idRoom, tiBed, sRoomBed	--, sDevice, sQnDevice, sRoom, cBed
		,	siIdx, sCall, iColorF, iColorB, tiShelf
		,	tElapsed, bActive, bAnswered, bAudio
		from	vwEvent_A	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@bVisible > 0		or	tiShelf > 0)
		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
					from	tb_RoleUnit	ru	with (nolock)
					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	siIdx desc, tElapsed
end
go
--	----------------------------------------------------------------------------
--	Staff levels
--	7.06.5563	+ [8]
begin tran
	if	not	exists	(select 1 from dbo.tbStfLvl where idStfLvl = 8)
		insert	dbo.tbStfLvl ( idStfLvl, iColorB, sStfLvl )		values	(  8,  0xFFFF4500, 'STAT' )		--	7.06.5563
commit
go
--	----------------------------------------------------------------------------
--	Returns security details for all users
--	7.06.5567	* merged pr_User_GetByUnit -> pr_User_GetAll
--	7.06.5563	+ '@idUser <= 15' to allow returning predifined system user-accounts
--	7.06.5399	* optimized
--	7.05.5182
alter proc		dbo.pr_User_GetAll
(
	@idStfLvl	tinyint		= null	-- null=any, 1=Yel, 2=Ora, 4=Grn
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUser		int			= null	-- null=any
,	@sStaffID	varchar( 16 )= null	-- null=any
)
	with encryption
as
begin
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStaffID, idStfLvl, sBarCode, bOnDuty, dtDue, sStaff, sUnits, sTeams
		,	cast(case when tiFails=0xFF then 1 else 0 end as bit)	as	bLocked
		,	bActive, dtCreated, dtUpdated
		from	tb_User		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idStfLvl is null	or	idStfLvl = @idStfLvl)
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)			--	protect internal accounts
		and		(@sStaffID is null	or	sStaffID = @sStaffID)
end
go
--	----------------------------------------------------------------------------
--	Updates full formatted name
--	7.06.5567	+ predefined account protection
--				+ @idUser= null
--	7.05.5123	* prUser_sStaff_Upd -> pr_User_sStaff_Upd
--				- @tiFmt:	always use tb_OptSys[11]
--	7.05.5010	* .idStaff -> .idUser
--	7.05.4983	* ' ?' -> ' ' (remove question-marks)
--	7.04.4919	* prStaff_sStaff_Upd -> prUser_sStaff_Upd
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.01	* add width enforcement
--	6.05
alter proc		dbo.pr_User_sStaff_Upd
(
	@idUser		int			= null	-- null=any
)
	with encryption
as
begin
	declare	@tiFmt		tinyint	

	set	nocount	on

	select	@tiFmt =	cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 11

	set	nocount	off

	begin	tran

		update	tb_User		set	sStaff=		left( ltrim( rtrim( replace( case
				when @tiFmt=0	then isnull(sFrst, '') + ' ' + isnull(sMidd, '') + ' ' + isnull(sLast, '')							--	First Mid Last
				when @tiFmt=1	then isnull(sFrst, '') + ' ' + left(isnull(sMidd, ''), 1) + '. ' + isnull(sLast, '')				--	First M. Last
				when @tiFmt=2	then isnull(sFrst, '') + ' ' + isnull(sLast, '')													--	First Last
				when @tiFmt=3	then left(isnull(sFrst, ''), 1) + '.' + left(isnull(sMidd, ''), 1) + '. ' + isnull(sLast, '')		--	F.M. Last
				when @tiFmt=4	then left(isnull(sFrst, ''), 1) + '. ' + isnull(sLast, '')											--	F. Last

				when @tiFmt=5	then isnull(sLast, '') + ', ' + isnull(sFrst, '') + ', ' + isnull(sMidd, '')						--	Last, First, Mid
				when @tiFmt=6	then isnull(sLast, '') + ', ' + isnull(sFrst, '') + ', ' + left(isnull(sMidd, ''), 1) + '.'			--	Last, First, M.
				when @tiFmt=7	then isnull(sLast, '') + ', ' + isnull(sFrst, '')													--	Last, First
				when @tiFmt=8	then isnull(sLast, '') + ' ' + left(isnull(sFrst, ''), 1) + '.' + left(isnull(sMidd, ''), 1) + '.'	--	Last F.M.
				when @tiFmt=9	then isnull(sLast, '') + ' ' + left(isnull(sFrst, ''), 1) + '.'										--	Last F.

/*				when @tiFmt=0	then isnull(sFrst, '?') + ' ' + isnull(sMidd, '?') + ' ' + isnull(sLast, '?')							--	First Mid Last
				when @tiFmt=1	then isnull(sFrst, '?') + ' ' + left(isnull(sMidd, '?'), 1) + '. ' + isnull(sLast, '?')					--	First M. Last
				when @tiFmt=2	then isnull(sFrst, '?') + ' ' + isnull(sLast, '?')														--	First Last
				when @tiFmt=3	then left(isnull(sFrst, '?'), 1) + '.' + left(isnull(sMidd, '?'), 1) + '. ' + isnull(sLast, '?')		--	F.M. Last
				when @tiFmt=4	then left(isnull(sFrst, '?'), 1) + '. ' + isnull(sLast, '?')											--	F. Last

				when @tiFmt=5	then isnull(sLast, '?') + ', ' + isnull(sFrst, '?') + ', ' + isnull(sMidd, '?')							--	Last, First, Mid
				when @tiFmt=6	then isnull(sLast, '?') + ', ' + isnull(sFrst, '?') + ', ' + left(isnull(sMidd, '?'), 1) + '.'			--	Last, First, M.
				when @tiFmt=7	then isnull(sLast, '?') + ', ' + isnull(sFrst, '?')														--	Last, First
				when @tiFmt=8	then isnull(sLast, '?') + ' ' + left(isnull(sFrst, '?'), 1) + '.' + left(isnull(sMidd, '?'), 1) + '.'	--	Last F.M.
				when @tiFmt=9	then isnull(sLast, '?') + ' ' + left(isnull(sFrst, '?'), 1) + '.'										--	Last F.
*/
				end, '  ', ' ' ) ) ), 16 )
			where	idUser = @idUser
			or		@idUser is null		and	idUser > 15			--	protect internal accounts
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5567	* 
begin tran
	update	tb_User		set	sStaff =	'System Admin'					where	idUser = 1
	update	tb_User		set	sStaff =	'Facility Admin'				where	idUser = 2
	update	tb_User		set	sStaff =	'Sample User'					where	idUser = 3
	update	tb_User		set	sStaff =	'Internal AppUser'
							,	sFrst=	'Internal',	sLast=	'AppUser'	where	idUser = 4

	exec	dbo.pr_User_sStaff_Upd
commit
go
--	----------------------------------------------------------------------------
--	Returns units, accessible by the given user (via his roles)
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
,	@sUnits		varchar( 255 )=null	-- comma-separated idUnit-s, '*'=all or null
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
		order	by	u.sUnit
end
go
--	----------------------------------------------------------------------------
--	7.06.5567	* xu_User -> xu_User_Login
if	not exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tb_User') and name = 'xu_User_Login')
--if	exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tb_User') and name = 'xu_User')
begin
	exec sp_rename	'tb_User.xu_User', 'xu_User_Login', 'index'
end
go
--	----------------------------------------------------------------------------
--	Populates tb_UserUnit for each user/staff based on 7980's .sUnits
--	7.06.5568	+ @sUser='*'
--	7.05.5121	* .sBarCode -> .sUnits
--	7.05.5098	* check idUnit
--	7.05.5084	* added check for null on @sUnits
--	7.05.5050
alter proc		dbo.pr_UserUnit_Set
	with encryption
as
begin
	declare	@id			int
		,	@i			int
		,	@p			varchar( 3 )
		,	@sUnits		varchar( 255 )
		,	@idUnit		smallint

	declare		cur		cursor fast_forward for
		select	idUser, sUnits
			from	tb_User		with (nolock)
	--		where	idUser > 16

	set	nocount	on

	begin	tran

		open	cur
		fetch next from	cur	into	@id, @sUnits
		while	@@fetch_status = 0
		begin
	--		print	char(10) + cast( @id as varchar )
			if	@sUnits = '*'	or	@sUnits = 'All Units'
			begin
				delete	from	tb_UserUnit
					where	idUser = @id
				insert	tb_UserUnit	( idUser, idUnit )
					select	@id, idUnit
						from	tbUnit
						where	bActive > 0		and		idShift > 0
	--			print	'all units'
			end
			else	if	@sUnits is not null		--	7.05.5084
			begin
				select	@i=	0
		_again:
	--			print	@sUnits
				select	@i=	charindex( ',', @sUnits )
				select	@p= case when @i > 0 then substring( @sUnits, 1, @i - 1 ) else @sUnits end
	--			print	'i=' + cast( @i as varchar ) + ', p=' + @p

				select	@idUnit=	cast( @p as smallint )
					,	@sUnits=	case when @i > 0 then substring( @sUnits, @i + 1, 32 ) else null end
	--			print	'u=' + cast( @idUnit as varchar )
				if	exists	(select 1 from tbUnit where idUnit=@idUnit)
				and	not	exists	(select 1 from tb_UserUnit where idUser=@id and idUnit=@idUnit)
					insert	tb_UserUnit	( idUser, idUnit )
							values	( @id, @idUnit )
				if	@i > 0		goto	_again
			end

			fetch next from	cur	into	@id, @sUnits
		end
		close	cur
		deallocate	cur

	commit
end
go
--	preset unit-access for system accounts
begin tran
	update	dbo.tb_User		set	sUnits= '*'		where	idUser < 16

	exec	pr_UserUnit_Set
commit
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 5568 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5568, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated= '2015-03-31', dtInstall= getdate( )
		,	sVersion= '+tbEvent_B, re-activate dvcs'
		where	siBuild = 5568

	update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.6.5568'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.5568 )'
commit
go

checkpoint
go

use [master]
go