--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.02
--		2013-Jan-08		.4756
--						* tbRtlsRoom.idBadge: not null -> null
--						* prDevice_UpdRoomBeds: initialize tbRtlsRoom
--		2013-Jan-09		.4757
--						* prEvent84_Ins: present staff recorded to tbRoomStaff (via prRoomStaff_Upd), ignore bed-idx for presence calls
--						* vwRoomBed: registered staff now comes from tbRoomStaff (not from tbRoomBed)
--		2013-Jan-10		.4758
--						* prEvent_A_Exp: try addressing (DELETE conflicted with ref constraint "fkEventC_Event_Aide")
--		2013-Jan-11		.4759
--						* prEvent84_Ins: @tiTmrXxxx -> @tiTmrXx
--		2013-Jan-14		.4762
--						* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom (vwDevice, prDevice_UpdRoomBeds, prMapCell_GetByUnitMap)
--						* fkRoom_Cn -> fkRoom_Cna, fkRoom_Ai -> fkRoom_Aide
--						* tbRoomStaff -> tbRoom (prRoomStaff_Upd -> prRoom_Upd, prStaffCover_InsFin)
--						* tbRoomBed.idDoctor moved to tbPatient (prPatient_GetIns)
--						- fkEvent_Device_Room, + fkEvent_Room
--						* tbEvent.tElapsed -> .tOrigin (vwEvent, prEvent8A_Ins, prEvent95_Ins, prRptSysActDtl, prRptCallActDtl)
--							fkEvent_Device_Src -> fkEvent_DvcSrc, fkEvent_Device_Dst -> fkEvent_DvcDst
--						- fkEventA_Device_Room, + fkEventA_Room
--							- tbEvent_A.tiTmr* (no need anymore, .tiSvc satisfies) (vwEvent_A)
--						+ fkEventC_Unit
--							- fkEventC_Device, + fkEventC_Room
--							* tbEvent_C.idCna -> .idCn, .idAide -> .idAi (vwEvent_C, prRptCallStatSum, prRptCallActSum)
--						+ fkEventT_Unit
--							- fkEventT_Device, + fkEventT_Room
--							* tbEvent_T.idCna -> .idCn, .idAide -> .idAi (vwEvent_T)
--						- tbRoomBed.idDoctor (moved into tbPatient) (vwRoomBed)
--							- .idReg* (no need anymore, tbRoom satisfies)
--							- fkRoomBed_Device, + fkRoomBed_Room
--						* vwRoomBed: registered staff now comes from tbRoom (not from tbRoomBed)
--						* prEvent_A_Exp
--						* prEvent_Ins
--						* tbEvent84.tiCvrgA* -> .tiCvrg*, siDutyA* -> siDuty*, siZoneA* -> siZone* (vwEvent84)
--							.tiTmrStat -> .tiTmrSt, .tiTmrCna -> .tiTmrCn, .tiTmrAide -> .tiTmrAi
--						* prEvent84_Ins
--						* vwEvent95: outputs
--						* tbEventAB.tiCvrgAX -> tiCvrgX (prEventAB_Ins)
--						prUnit_InsUpdDel, prDefLoc_SetLvl
--						- fkStaffAssn_Device, + fkStaffAssn_Room
--						- fkRtlsRoom_Device, + fkRtlsRoom_Room
--		2013-Jan-22		.4770
--						+ tbSchedule
--		2013-Jan-23		.4771
--						* prDevice_GetByID, * prDevice_GetByUnit (tbDevice.sBeds moved to tbRoom)
--		2013-Jan-28		.4776
--						* prRtlsBadge_InsUpd: inserting into tbStaffDvc (requires 'alter' permission)
--		2013-Jan-29		.4777
--						* tbDefCmd: [BA-C1]
--						* tbDefCall: .bEnabled <-> .bActive (meaning)
--						* prBadge_UpdLoc: @idBadge: smallint -> int
--						- tbRtlsBadge.idStaff (no need now, tbStaffDvc.idStaff keeps relationship) (vwRtlsBadge, vwRtlsRoom)
--						* tb_LogType: [80,81].tiSource: 32 -> 16
--		2013-Jan-30		.4778
--						+ tb_LogType: [75]	(prDevice_UpdRoomBeds)
--						* prBadge_UpdLoc: commented out tracing non-existing badges - too much output
--		2013-Jan-31		.4779
--						* vwDevice: '(#.sDial)' instead of '(.sDial)'
--		2013-Feb-13		.4792
--						* prDevice_InsUpd
--						* prPatient_GetIns: fixed "Conversion failed when converting the varchar value '?' to data type int."
--		2013-Feb-22		.4801
--						+ fix for establishing fkEventA_Room, fkEventC_Room, fkEventT_Room constraints
--		2013-Feb-24		.4803
--						+ fix for prEvent_Ins
--		2013-May-14		.4882
--						+ fix for tbStaffAssn non-room devices resulting from 7980 using room-name only (and duplicate names present)
--						finalized?
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 702 and siBuild >= 4882 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.02.4882', 18, 0 )

go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='prMstrAcct_InsUpd')
	drop proc	dbo.prMstrAcct_InsUpd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomStaff_Upd')
	drop proc	dbo.prRoomStaff_Upd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_Upd')
	drop proc	dbo.prRoom_Upd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbMstrAcct')
	drop table	dbo.tbMstrAcct
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbSchedule')
	drop table	dbo.tbSchedule
go

if not exists	(select 1 from dbo.tb_LogType where idLogType=80 and tiSource=16)
begin
	begin tran
		update	dbo.tb_LogType	set	tiSource= 16	where	idLogType in (80, 81)
	commit
end
go
if not exists	(select 1 from dbo.tb_LogType where idLogType=75)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLevel, tiSource, sLogType )	values	( 75,  2, 16, 'Room definition' )		--	7.02
	commit
end
go
--	----------------------------------------------------------------------------
--	tbDefCmd
--	v.7.02	* [BA-C1]
if not exists	(select 1 from dbo.tbDefCmd where idCmd = 0xBA)
begin
	begin tran
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBA, 'remote rnd/rmnd status request' )		--	v.7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBB, 'remote rnd/rmnd status response' )		--	v.7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBC, 'remote rnd/rmnd status set/clr' )		--	v.7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBD, 'remote audio quit request' )			--	v.7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBE, 'staff details request' )				--	v.7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBF, 'staff details response' )				--	v.7.02

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC0, 'station code version request' )		--	v.7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC1, 'station code version response' )		--	v.7.02
	commit
end
go
--	----------------------------------------------------------------------------
--	tbDevice
--	v.7.02	- .siBeds, .sBeds, .idEvent, .tiSvc, .idUnit (moved to tbRoom)
--	tbRoom
--	v.7.02	* fkRoom_Cn -> fkRoom_Cna, fkRoom_Ai -> fkRoom_Aide
--			* tbRoomStaff -> tbRoom (prRoomStaff_Upd -> prRoom_Upd, prStaffCover_InsFin)
--			+ .siBeds, .sBeds, .idEvent, .tiSvc, .idUnit (moved from tbDevice)
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRoom')
begin
	begin tran
		alter table	dbo.tbRoomStaff		add
			idUnit		smallint null				-- live: current unit (for rooms) FK
				constraint	fkRoom_Unit		foreign key references tbUnit
		,	siBeds		smallint null				-- auto: beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
		,	sBeds		varchar( 10 ) null			-- auto: beds 'A'.. 'ABCDEFGHIJ'
		,	idEvent		int null					-- live: highest active call FK
				constraint	fkRoom_Event	foreign key references tbEvent
		,	tiSvc		tinyint null				-- live: service state
		alter table	dbo.tbRoomStaff		drop constraint fkRoomStaff_Rn
		alter table	dbo.tbRoomStaff		add constraint	fkRoom_Rn	foreign key	(idRn) references tbStaff
		alter table	dbo.tbRoomStaff		drop constraint fkRoomStaff_Cn
		alter table	dbo.tbRoomStaff		add constraint	fkRoom_Cna	foreign key	(idCn) references tbStaff
		alter table	dbo.tbRoomStaff		drop constraint fkRoomStaff_Ai
		alter table	dbo.tbRoomStaff		add constraint	fkRoom_Aide	foreign key	(idAi) references tbStaff
		alter table	dbo.tbRoomStaff		drop constraint fkRoomStaff_Device
		alter table	dbo.tbRoomStaff		add constraint	fkRoom_Device	foreign key	(idRoom) references tbDevice

		alter table	dbo.tbDevice		drop constraint fkDevice_Event
		alter table	dbo.tbDevice		drop constraint fkDevice_Unit
		alter table	dbo.tbDevice		drop column		siBeds
		alter table	dbo.tbDevice		drop column		sBeds
		alter table	dbo.tbDevice		drop column		idEvent
		alter table	dbo.tbDevice		drop column		tiSvc
		alter table	dbo.tbDevice		drop column		idUnit

		insert	dbo.tbRoomStaff	(idRoom)
			select	idDevice
				from	dbo.tbDevice
				where	cDevice='R'
					and	idDevice not in (select idRoom from dbo.tbRoomStaff)

		exec sp_rename 'dbo.tbRoomStaff', 'tbRoom', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices
--	v.7.02	* .siBeds, .sBeds, .idEvent, .tiSvc, .idUnit (moved to tbRoom)
--	v.7.00	* preset .idUnit for new rooms
--			* reset tdDevice.idEvent to null
--			+ .sUnits
--			+ @sCodeVer
--	v.6.07	- device matching by name
--	v.6.05	tracing reclassified 41 -> 74
--			+ (nolock)
--	v.6.04	+ @idDevice out
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.02	tdDevice.dtLastUpd -> .dtUpdated
--			* .tiRID is never NULL now - added download of all stations
--			+ .cSys, xuDevice_GJR -> xuDevice_SGJR
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--	v.5.01	encryption added
--	v.4.01
--	v.2.03	@tiRID ignored
--			+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--	v.2.02
alter proc		dbo.prDevice_InsUpd
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
,	@tiPriCA0	tinyint				-- coverage area 0
,	@tiPriCA1	tinyint				-- coverage area 1
,	@tiPriCA2	tinyint				-- coverage area 2
,	@tiPriCA3	tinyint				-- coverage area 3
,	@tiPriCA4	tinyint				-- coverage area 4
,	@tiPriCA5	tinyint				-- coverage area 5
,	@tiPriCA6	tinyint				-- coverage area 6
,	@tiPriCA7	tinyint				-- coverage area 7
,	@tiAltCA0	tinyint				-- alternate coverage area 0
,	@tiAltCA1	tinyint				-- coverage area 1
,	@tiAltCA2	tinyint				-- coverage area 2
,	@tiAltCA3	tinyint				-- coverage area 3
,	@tiAltCA4	tinyint				-- coverage area 4
,	@tiAltCA5	tinyint				-- coverage area 5
,	@tiAltCA6	tinyint				-- coverage area 6
,	@tiAltCA7	tinyint				-- coverage area 7
,	@sCodeVer	varchar( 16 )		-- device code version

,	@idDevice	smallint out		-- output: inserted/updated idDevice	--	v.6.04
)
	with encryption
as
begin
	declare		@idParent	smallint
	declare		@iTrace		int
	declare		@s			varchar( 255 )
	declare		@idUnit		smallint
	declare		@sUnits		varchar( 255 )
	
	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	select	@s=	'Dvc_IU( s=' + @cSys + ', g=' + cast(@tiGID as varchar) + ', j=' + cast(@tiJID as varchar) + ', r=' + cast(@tiRID as varchar) +
				', aid=' + cast(@iAID as varchar) + ', t=' + cast(@tiStype as varchar) + ', c=' + isnull(@cDevice,'?') + ', n=' + @sDevice +
				', d=' + isnull(@sDial,'?') + ', v=' + isnull(@sCodeVer,'?') + ', pCA0=' + isnull(cast(@tiPriCA0 as varchar),'?') + ' )'

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID = 0
		select	@iAID=	null
--	if	@iAID > 0
--		select	@idDevice= idDevice		from	tbDevice		where	iAID = @iAID
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID > 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	--and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	--and	bActive > 0
---	if	@idDevice is null	and	len(@sDevice) > 0	and	len(@sDial) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	and	sDial = @sDial	--and	bActive > 0
---	if	@idDevice is null	and	len(@sDevice) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	--and	bActive > 0

	if	@tiRID > 0						-- R-bus device
		select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	---	and	bActive > 0
	if	@tiJID > 0	and	@tiRID = 0		-- J-bus device
		select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	---	and	bActive > 0

	select	@s=	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')

	begin	tran

		select	@sUnits=	''

	/*	if	(@tiPriCA0 is not null	and	@tiPriCA0 = 255)	or	(@tiPriCA1 is not null	and	@tiPriCA1 = 255)	or
			(@tiPriCA2 is not null	and	@tiPriCA2 = 255)	or	(@tiPriCA3 is not null	and	@tiPriCA3 = 255)	or
			(@tiPriCA4 is not null	and	@tiPriCA4 = 255)	or	(@tiPriCA5 is not null	and	@tiPriCA5 = 255)	or
			(@tiPriCA6 is not null	and	@tiPriCA6 = 255)	or	(@tiPriCA7 is not null	and	@tiPriCA7 = 255)	or
			(@tiAltCA0 is not null	and	@tiAltCA0 = 255)	or	(@tiAltCA1 is not null	and	@tiAltCA1 = 255)	or
			(@tiAltCA2 is not null	and	@tiAltCA2 = 255)	or	(@tiAltCA3 is not null	and	@tiAltCA3 = 255)	or
			(@tiAltCA4 is not null	and	@tiAltCA4 = 255)	or	(@tiAltCA5 is not null	and	@tiAltCA5 = 255)	or
			(@tiAltCA6 is not null	and	@tiAltCA6 = 255)	or	(@tiAltCA7 is not null	and	@tiAltCA7 = 255)
	*/	if	@tiPriCA0 = 0xFF	or	@tiPriCA1 = 0xFF	or	@tiPriCA2 = 0xFF	or	@tiPriCA3 = 0xFF	or
			@tiPriCA4 = 0xFF	or	@tiPriCA5 = 0xFF	or	@tiPriCA6 = 0xFF	or	@tiPriCA7 = 0xFF	or
			@tiAltCA0 = 0xFF	or	@tiAltCA1 = 0xFF	or	@tiAltCA2 = 0xFF	or	@tiAltCA3 = 0xFF	or
			@tiAltCA4 = 0xFF	or	@tiAltCA5 = 0xFF	or	@tiAltCA6 = 0xFF	or	@tiAltCA7 = 0xFF
		begin
			declare		cur		cursor fast_forward for
				select	idLoc
					from	tbDefLoc	with (nolock)
					where	tiLvl = 4	-- unit

			open	cur
			fetch next from	cur	into	@idUnit
			while	@@fetch_status = 0
			begin
				select	@sUnits=	@sUnits + ',' + cast(@idUnit as varchar)

				fetch next from	cur	into	@idUnit
			end
			close	cur
			deallocate	cur

			if	len(@sUnits) > 0
				select	@sUnits= substring(@sUnits, 2, len(@sUnits)-1)
		end
		else							-- specific units
		begin
			create table	#tbUnit
			(
				idUnit		smallint
			)

			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA0
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA1
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA2
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA3
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA4
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA5
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA6
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA7

			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA0
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA1
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA2
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA3
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA4
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA5
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA6
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA7

			declare		cur		cursor fast_forward for
				select	distinct	idUnit
					from	#tbUnit		with (nolock)
					order	by	1

			open	cur
			fetch next from	cur	into	@idUnit
			while	@@fetch_status = 0
			begin
				select	@sUnits=	@sUnits + ',' + cast(@idUnit as varchar)

				fetch next from	cur	into	@idUnit
			end
			close	cur
			deallocate	cur

			if	len(@sUnits) > 0
				select	@sUnits= substring(@sUnits, 2, len(@sUnits)-1)
		end
		if	len(@sUnits) = 0
			select	@sUnits=	null

		if	@idDevice is null
		begin
			if	@cDevice = 'R'
				select	@idUnit= idParent							-- set room's current unit to primary CA's
					from	tbDefLoc	with (nolock)
					where	idLoc = @tiPriCA0
			else
				select	@idUnit= null

			insert	tbDevice	(  idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial,  sCodeVer,  sUnits	--,  idUnit
							,	 tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
							,	 tiAltCA0,  tiAltCA1,  tiAltCA2,  tiAltCA3,  tiAltCA4,  tiAltCA5,  tiAltCA6,  tiAltCA7 )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial, @sCodeVer, @sUnits	--, @idUnit
							,	@tiPriCA0, @tiPriCA1, @tiPriCA2, @tiPriCA3, @tiPriCA4, @tiPriCA5, @tiPriCA6, @tiPriCA7
							,	@tiAltCA0, @tiAltCA1, @tiAltCA2, @tiAltCA3, @tiAltCA4, @tiAltCA5, @tiAltCA6, @tiAltCA7 )
			select	@idDevice=	scope_identity( )
			select	@s=	@s + '  INS: id=' + cast(@idDevice as varchar)
		end
		else
		begin
			if	@iAID > 0
				update	tbDevice	set		iAID= @iAID				--	bActive= 1, dtUpdated= getdate( ),	-- no point repeating
					where	idDevice = @idDevice	and	iAID is null

			update	tbDevice	set		idParent= @idParent			--	bActive= 1, dtUpdated= getdate( ),	-- no point repeating
				,	cSys= @cSys, tiGID= @tiGID, tiJID= @tiJID, tiRID= @tiRID
				where	idDevice = @idDevice	and	iAID = @iAID

			update	tbDevice	set		bActive= 1, dtUpdated= getdate( )	--, idEvent= null				-- 'cause this executes always
				,	tiStype= @tiStype,	cDevice= @cDevice,	sDevice= @sDevice,	sDial= @sDial,	sCodeVer= @sCodeVer,	sUnits= @sUnits
				,	tiPriCA0= @tiPriCA0, tiPriCA1= @tiPriCA1, tiPriCA2= @tiPriCA2, tiPriCA3= @tiPriCA3
				,	tiPriCA4= @tiPriCA4, tiPriCA5= @tiPriCA5, tiPriCA6= @tiPriCA6, tiPriCA7= @tiPriCA7
				,	tiAltCA0= @tiAltCA0, tiAltCA1= @tiAltCA1, tiAltCA2= @tiAltCA2, tiAltCA3= @tiAltCA3
				,	tiAltCA4= @tiAltCA4, tiAltCA5= @tiAltCA5, tiAltCA6= @tiAltCA6, tiAltCA7= @tiAltCA7
				where	idDevice = @idDevice

	--		select	@s=	@s + '  UPD'
		end

		if	@iTrace & 0x04 > 0
			exec	pr_Log_Ins	74, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns requested device/room/master's details
--	v.7.02	* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	v.7.00
alter proc		dbo.prDevice_GetByID
(
	@idDevice	smallint			-- device (PK)
,	@bActive	bit= null			-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint) [tiSwing], d.sUnits						-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		left outer join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice					-- v.7.02
		where	(@bActive is null	or	d.bActive = @bActive)
		and		d.idDevice = @idDevice
--	-	order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Returns devices/rooms/masters for given unit
--	v.7.02	* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	v.7.00	+ .sBeds, re-order output
--			* @idUnit -> @sUnits, output: .bSwing -> tiSwing
--			* @idUnit is null == all units
--			+ @bActive
--			output: idRoom -> idDevice
--	v.6.05	+ (nolock)
--	v.6.04	prDevice_GetRooms -> prDevice_GetByUnit, + @tiStype->@tiKind
--			+ .bSwing to the output
--			@idLoc -> @idUnit
--	v.6.02	* fast_forward
--			+ .bActive, .dtCreated, .dtUpdated to the output
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--	v.5.01	encryption added
--	v.2.03
alter proc		dbo.prDevice_GetByUnit
(
--	@idUnit		smallint			-- unit (FK to tbDefLoc, tiLvl=4)
	@sUnits		varchar( 255 )		-- comma-separated idUnit's | '*'=all
,	@tiKind		tinyint				-- 0=any, 1=rooms, 2=masters
,	@bActive	bit= null			-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
	declare		@i			smallint
	declare		@s			varchar( 16 )

	set	nocount	on

	create table	#tbDevice
	(
		idDevice	smallint

		primary key nonclustered ( idDevice )
	)

	if	(@sUnits is not null	and	@sUnits <> '*')		-- specific unit(s)
	begin
		while	len( @sUnits ) > 0
		begin
			select	@i=	charindex( ',', @sUnits )

			if	@i = 0
				select	@s=	@sUnits
			else
				select	@s=	substring( @sUnits, 1, @i - 1 )

			select	@s=	'%' + @s + '%'
	---		print	@s

			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					left outer join	#tbDevice t	with (nolock)	on	t.idDevice = d.idDevice
					where	(@bActive is null	or	d.bActive = @bActive)
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiStype between 4 and 7	and	d.tiRID = 0)	-- room controllers
						or	(@tiKind = 2	and	d.tiStype between 8 and 11	and	d.tiRID = 0))	-- masters
					and		d.sUnits like @s
					and		t.idDevice is null

	---		select * from #tbDevice

			if	@i = 0
				break
			else
				select	@sUnits=	substring( @sUnits, @i + 1, len( @sUnits ) - @i )
		end
	end
	else		-- request for all units
	begin
			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					where	(@bActive is null	or	bActive = @bActive)
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiStype between 4 and 7	and	d.tiRID = 0)	-- room controllers
						or	(@tiKind = 2	and	d.tiStype between 8 and 11	and	d.tiRID = 0))	-- masters
	end

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint) [tiSwing], d.sUnits						-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		inner join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		left outer join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice					-- v.7.02
		order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Devices
--	v.7.02	* '(#.sDial)' instead of '(.sDial)'
--			* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	v.7.00	+ .sUnits
--			+ .sCodeVer
--	v.6.05	+ (nolock)
--	v.6.04	+ .sQnDevice, .siBeds, .sBeds, .idUnit
--			* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	v.6.03	+ .cSGJ, + .sFnDevice
--	v.6.02
alter view		dbo.vwDevice
	with encryption
as
select	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, sUnits, r.idUnit, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2) + '-' + right('0' + cast(tiRID as varchar), 2)	[sSGJR]
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		[sSGJ]
	,	'[' + cDevice + '] ' + sDevice		[sQnDevice]
	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	[sFnDevice]
	,	bActive, dtCreated, d.dtUpdated
	from	tbDevice d	with (nolock)
	left outer join	tbRoom r	with (nolock)	on	r.idRoom = d.idDevice
go
--	----------------------------------------------------------------------------
--	Updates rooms staff
--	v.7.02	* tbRoomStaff -> tbRoom (prRoomStaff_Upd -> prRoom_Upd)
--			* fill in idStaff's as well
--	v.6.05
create proc		dbo.prRoom_Upd
(
	@idRoom			smallint			-- 790 device look-up FK
,	@sRn			varchar( 16 )
,	@sCn			varchar( 16 )
,	@sAi			varchar( 16 )
)
	with encryption
as
begin
	declare		@idRn		int
	declare		@idCn		int
	declare		@idAi		int

	set	nocount	on

	if	len( @sRn ) > 0		select	@idRn= idStaff	from	tbStaff with (nolock)	where	sStaff = @sRn
	if	len( @sCn ) > 0		select	@idCn= idStaff	from	tbStaff with (nolock)	where	sStaff = @sCn
	if	len( @sAi ) > 0		select	@idAi= idStaff	from	tbStaff with (nolock)	where	sStaff = @sAi

	begin	tran
		update	tbRoom	set	idRn= @idRn, sRn= @sRn, idCn= @idCn, sCn= @sCn, idAi= @idAi, sAi= @sAi
							,	dtUpdated= getdate( )
			where	idRoom = @idRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	tbPatient
--	v.7.02	+ .idDoctor (moved from tbRoomBed)
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbPatient') and name = 'idDoctor')
begin
	alter table	dbo.tbPatient	add
		idDoctor	int null					-- current doctor look-up FK
			constraint	fkPatient_Doctor	foreign key references tbDoctor
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoomBed') and name = 'idDoctor')
exec( 'begin tran
	update	p	set	p.idDoctor= rb.idDoctor
		from	dbo.tbPatient	p
		inner join	dbo.tbRoomBed	rb	on	rb.idPatient = p.idPatient
		where	rb.idDoctor is not null
commit' )
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
--	v.7.02	* fixed "Conversion failed when converting the varchar value '?' to data type int."
--			* @cGender null?
--			+ @sDoctor
--	v.6.05	+ (nolock)
--	v.6.04
alter proc		dbo.prPatient_GetIns
(
	@sPatient	varchar( 16 )		-- full name (HL7)
,	@cGender	char( 1 )
,	@sInfo		varchar( 32 )
,	@sNote		varchar( 255 )
,	@sDoctor	varchar( 16 )		-- full name (HL7)

,	@idPatient	int out				-- output
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
			,	@idDoctor	int

	set	nocount	on

	if	@cGender is null
		select	@cGender=	'U'

	if	len( @sPatient ) > 0
	begin
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

		select	@idPatient= idPatient
			from	tbPatient	with (nolock)
			where	sPatient = @sPatient	and	bActive > 0

		if	@idPatient is null
		begin
			if	@cGender is null
				select	@cGender=	substring( @sPatient, len(@sPatient), 1 )

			begin	tran
				insert	tbPatient	(  sPatient,  cGender,  sInfo,  sNote,  idDoctor )
						values		( @sPatient, @cGender, @sInfo, @sNote, @idDoctor )
				select	@idPatient=	scope_identity( )

				select	@s=	'Pat_I( p=' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
							', n=' + isnull(@sNote,'?') + ', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] )  id=' + cast(@idPatient as varchar)
				exec	pr_Log_Ins	44, null, null, @s
			commit
		end
		else
		begin
			begin	tran
				update	tbPatient	set	cGender= @cGender, sInfo= @sInfo, sNote= @sNote, idDoctor= @idDoctor, dtUpdated= getdate( )
					where	idPatient = @idPatient

				select	@s=	'Pat_U( [' + cast(@idPatient as varchar) + '] ' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
							', n=' + isnull(@sNote,'?') + ', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] ' + isnull(@sDoctor,'?') + ' )'
				exec	pr_Log_Ins	44, null, null, @s
			commit
		end
	end
end
go
--	----------------------------------------------------------------------------
--	v.7.02	+ grant alter - necessary for 'insert identity on'!
grant	alter							on dbo.tbStaffDvc		to [rWriter]
go
--	----------------------------------------------------------------------------
--	tbEvent
--	v.7.02	- fkEvent_Device_Room, + fkEvent_Room
--			* .tElapsed -> .tOrigin, fkEvent_Device_Src -> fkEvent_DvcSrc, fkEvent_Device_Dst -> fkEvent_DvcDst
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent') and name = 'tOrigin')
begin
	begin tran
		exec sp_rename 'tbEvent.tElapsed', 'tOrigin', 'column'

		update	dbo.tbEvent	set	idRoom= null
			where	idRoom not in (select idDevice from dbo.tbDevice where cDevice='R')

		alter table	dbo.tbEvent		drop constraint fkEvent_Device_Room
		alter table	dbo.tbEvent		add constraint	fkEvent_Room	foreign key	(idRoom) references tbRoom on delete set null
		alter table	dbo.tbEvent		drop constraint fkEvent_Device_Src
		alter table	dbo.tbEvent		add constraint	fkEvent_DvcSrc	foreign key	(idSrcDvc) references tbDevice
		alter table	dbo.tbEvent		drop constraint fkEvent_Device_Dst
		alter table	dbo.tbEvent		add constraint	fkEvent_DvcDst	foreign key	(idDstDvc) references tbDevice
	commit
end
go
--	----------------------------------------------------------------------------
--	System activity log
--	v.7.02	* .tElapsed -> .tOrigin
--	v.6.05	+ (nolock)
--			* 'e.'idEvent (now that tbDevice.idEvent exists)
--	v.6.04	+ .idRoom, .sRoom, .cBed
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--			tbDefType -> tbEvType (fkEvent_DefType -> fkEvent_EvType)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	v.5.01	encryption added
--			src + dst devices
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	v.3.01
--	v.2.01	.idRoom -> .idDevice (FK changed also)
--	v.1.09	+ .id|sType
--			+ .dEvent,.tEvent,.tiHH
--	v.1.03
alter view		dbo.vwEvent
	with encryption
as
select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, dtEvent, dEvent, tEvent, tiHH, idCmd, tiBtn, e.idRoom, r.sDevice [sRoom], tiBed, b.cBed, e.idUnit,
		e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID, e.idSrcDvc, sd.sDevice [sSrcDvc], sd.cDevice [cSrcDvc], sd.sDial [sSrcDial],
		e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID, e.idDstDvc, dd.sDevice [sDstDvc], dd.cDevice [cDstDvc], dd.sDial [sDstDial],
		e.idLogType, et.sLogType, e.idCall, c.sCall, sInfo
	from	tbEvent	e				with (nolock)
	left outer join	tbDefCall	c	with (nolock)	on	c.idCall = e.idCall
	left outer join	tbDefBed	b	with (nolock)	on	b.idIdx = e.tiBed
	left outer join	tb_LogType	et	with (nolock)	on	et.idLogType = e.idLogType
	left outer join	tbDevice	sd	with (nolock)	on	sd.idDevice = e.idSrcDvc
	left outer join	tbDevice	dd	with (nolock)	on	dd.idDevice = e.idDstDvc
	left outer join	tbDevice	r	with (nolock)	on	r.idDevice = e.idRoom
go
--	----------------------------------------------------------------------------
--	tbEvent_A
--	v.7.02	- fkEventA_Device_Room, + fkEventA_Room
--			- .tiTmr* (no need anymore, .tiSvc satisfies)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_A') and name = 'tiTmrStat')
begin
	begin tran
		alter table	dbo.tbEvent_A	drop column		tiTmrStat
		alter table	dbo.tbEvent_A	drop column		tiTmrRn
		alter table	dbo.tbEvent_A	drop column		tiTmrCna
		alter table	dbo.tbEvent_A	drop column		tiTmrAide

		update	a	set	a.idRoom= null
			from	dbo.tbEvent_A a
			left outer join	dbo.tbRoom r	on	r.idRoom = a.idRoom
			where	r.idRoom is null

		alter table	dbo.tbEvent_A	drop constraint fkEventA_Device_Room
		alter table	dbo.tbEvent_A	add constraint	fkEventA_Room	foreign key	(idRoom) references tbRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--	v.7.02	- .tiTmr* (no need anymore, .tiSvc satisfies)
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--			+ sd.tiStype, p.tiShelf, p.tiSpec
--			- .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide (no longer needed)
--			+ .tiSvc, .bAudio, .idUnit
--			+ (nolock)
--	v.6.04	+ .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide, .bAnswered
--			tbEvent.idRoom --> tbEvent_A.idRoom, .tiBed, .idCall
--			.idDevice,.sDevice,.sFnDevice -> .idRoom,.sRoom
--			+ .sDevice, .tiBed, .cBed
--	v.6.03
alter view		dbo.vwEvent_A
	with encryption
as
select	ea.idEvent, ea.dtEvent,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
	,	sd.idDevice, sd.sDevice, sd.sQnDevice
	,	ea.idRoom, r.sDevice [sRoom],	ea.tiBed, b.cBed,	rr.idUnit
	,	ea.idCall, c.siIdx, c.sCall, p.iColorF, p.iColorB, getdate( ) - ea.dtEvent [tElapsed], ea.bActive
--	,	a.tiTmrStat, a.tiTmrRn, a.tiTmrCna, a.tiTmrAide
	,	ea.tiSvc, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit ) [bAnswered], ea.dtExpires
	,	sd.tiStype, p.tiShelf, p.tiSpec
	from	tbEvent_A		ea		with (nolock)
---	inner join	tbEvent		e		with (nolock)	on	e.idEvent = a.idEvent		--	very expensive join, not needed!!
---	left outer join	vwDevice	d	with (nolock)	on	d.idDevice = e.idSrcDvc
	left outer join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
---	left outer join	vwDevice	sd	with (nolock)	on	sd.tiGID = a.tiSrcGID	and	sd.tiJID = a.tiSrcJID	and	sd.tiRID = a.tiSrcRID	and	sd.bActive > 0
	left outer join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left outer join	tbRoom		rr	with (nolock)	on	rr.idRoom = ea.idRoom
	left outer join	tbDefCall	c	with (nolock)	on	c.idCall = ea.idCall		--	c.siIdx = a.siIdxNew
	left outer join	tbDefCallP	p	with (nolock)	on	p.idIdx = c.siIdx
	left outer join	tbDefBed	b	with (nolock)	on	b.idIdx = ea.tiBed
go
--	----------------------------------------------------------------------------
--	tbEvent_C
--	v.7.02	+ fkEventC_Unit
--			- fkEventC_Device, + fkEventC_Room
--			* .idCna -> .idCn, .idAide -> .idAi
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'idCn')
begin
	begin tran
		exec sp_rename 'tbEvent_C.idCna', 'idCn', 'column'
		exec sp_rename 'tbEvent_C.idAide', 'idAi', 'column'
		exec sp_rename 'tbEvent_C.tCna', 'tCn', 'column'
		exec sp_rename 'tbEvent_C.tAide', 'tAi', 'column'

		update	c	set	c.idRoom= null
			from	dbo.tbEvent_C c
			left outer join	dbo.tbRoom r	on	r.idRoom = c.idRoom
			where	r.idRoom is null

		alter table	dbo.tbEvent_C	drop constraint fkEventC_Device
		alter table	dbo.tbEvent_C	add constraint	fkEventC_Room	foreign key	(idRoom) references tbRoom
		alter table	dbo.tbEvent_C	add constraint	fkEventC_Unit	foreign key	(idUnit) references tbUnit
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.02	* .idCna -> .idCn, .idAide -> .idAi
--	v.6.05	+ (nolock)
--	v.6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--			tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	v.5.01	+ .cDevice
--	v.4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--	v.2.03	+ .tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--	v.2.02	+ .idRn, .tRn, .idCna, .tCna, .idAide, .tAide (vwEventC, prEvent84_Ins?)
--	v.2.01	.idRoom -> .idDevice (FK changed also)
--	v.1.09	+ .id|sType
--	v.1.03
alter view		dbo.vwEvent_C
	with encryption
as
select	ec.idEvent, ec.dEvent, ec.tEvent, ec.tiHH, ec.idCall, c.sCall,
		ec.idRoom, d.cDevice, d.sDevice, d.sDial, ec.idUnit, l.sLoc,
		ec.cBed, ec.idVoice, ec.tVoice, ec.idStaff, ec.tStaff,
		ec.idRn, ec.tRn, ec.idCn, ec.tCn, ec.idAi, ec.tAi
	from		tbEvent_C	ec	with (nolock)
	inner join	tbDevice	d	with (nolock)	on	d.idDevice = ec.idRoom
	inner join	tbDefCall	c	with (nolock)	on	c.idCall = ec.idCall
	left outer join	tbDefLoc l	with (nolock)	on	l.idLoc = ec.idUnit
go
--	----------------------------------------------------------------------------
--	tbEvent_T
--	v.7.02	+ fkEventT_Unit
--			- fkEventT_Device, + fkEventT_Room
--			* .idCna -> .idCn, .idAide -> .idAi
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_T') and name = 'tCn')
begin
	begin tran
---		exec sp_rename 'tbEvent_T.idCna', 'idCn', 'column'
---		exec sp_rename 'tbEvent_T.idAide', 'idAi', 'column'
		exec sp_rename 'tbEvent_T.tCna', 'tCn', 'column'
		exec sp_rename 'tbEvent_T.tAide', 'tAi', 'column'

		update	t	set	t.idRoom= null
			from	dbo.tbEvent_T t
			left outer join	dbo.tbRoom r	on	r.idRoom = t.idRoom
			where	r.idRoom is null

		alter table	dbo.tbEvent_T	drop constraint fkEventT_Device
		alter table	dbo.tbEvent_T	add constraint	fkEventT_Room	foreign key	(idRoom) references tbRoom
		alter table	dbo.tbEvent_T	add constraint	fkEventT_Unit	foreign key	(idUnit) references tbUnit
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.02	* .idCna -> .idCn, .idAide -> .idAi
--	v.6.05	+ (nolock)
--	v.6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--			tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	v.5.01
alter view		dbo.vwEvent_T
	with encryption
as
select	et.idEvent, et.dEvent, et.tEvent, et.tiHH, et.idCall, c.sCall,
		et.idRoom, d.cDevice, d.sDevice, d.sDial, et.idUnit, l.sLoc,
		et.cBed, et.idVoice, et.tVoice, et.idStaff, et.tStaff,
		et.tRn, et.tCn, et.tAi
	from		tbEvent_T	et	with (nolock)
	inner join	tbDevice	d	with (nolock)	on	d.idDevice = et.idRoom
	inner join	tbDefCall	c	with (nolock)	on	c.idCall = et.idCall
	left outer join	tbDefLoc l	with (nolock)	on	l.idLoc = et.idUnit
go
--	----------------------------------------------------------------------------
--	tbRoomBed
--	v.7.02	- fkRoomBed_Device, + fkRoomBed_Room
--			- .idDoctor (moved into tbPatient)
--			- .idReg* (no need anymore, tbRoom satisfies)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoomBed') and name = 'idDoctor')
begin
	begin tran
		alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_RegRn
		alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_RegCna
		alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_RegAide
		alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_Doctor
		alter table	dbo.tbRoomBed	drop column		idRegRn
		alter table	dbo.tbRoomBed	drop column		idRegCn
		alter table	dbo.tbRoomBed	drop column		idRegAi
		alter table	dbo.tbRoomBed	drop column		idDoctor

		alter table	dbo.tbRoomBed	drop constraint fkRoomBed_Device
		alter table	dbo.tbRoomBed	add constraint	fkRoomBed_Room	foreign key	(idRoom) references tbRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	v.7.02	* .idDoctor now comes from tbPatient
--			* registered staff now comes from tbRoom (not from tbRoomBed)
--	v.7.01	* assigned staff: tbStaff -> vwStaff,	+ idStaffLvl, sStaffLvl
--	v.7.00	+ tbRoomBed.idAsnRn, .idAsnCn, .idAsnAi, .idRegRn, .idRegCn, .idRegAi
--			- vwRtlsRoom
--	v.6.05	- vwEvent_A, tbPatient, tbDoctor joins - not needed in view itself
--			+ r.cSys, r.tiGID, r.tiJID, r.tiRID
--			+ (nolock)
--	v.6.04
alter view		dbo.vwRoomBed
	with encryption
as
select	r.idUnit,	rb.idRoom, d.sDevice [sRoom], d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, rb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	rb.idPatient	--, p.sPatient, p.cGender, p.sInfo, p.sNote
	,	p.idDoctor		--, d.sDoctor
	,	rb.idAsnRn [idAssn1], a1.sStaff [sAssn1], a1.idStaffLvl [idStLvl1]	--, a1.sStaffLvl [sStLvl1], a1.iColorB [iColorB1]
	,	rb.idAsnCn [idAssn2], a2.sStaff [sAssn2], a2.idStaffLvl [idStLvl2]	--, a2.sStaffLvl [sStLvl2], a2.iColorB [iColorB2]
	,	rb.idAsnAi [idAssn3], a3.sStaff [sAssn3], a3.idStaffLvl [idStLvl3]	--, a3.sStaffLvl [sStLvl3], a3.iColorB [iColorB3]
	,	r.idRn [idRegRn], r.sRn [sRegRn],	r.idCn [idRegCn], r.sCn [sRegCn],	r.idAi [idRegAi], r.sAi [sRegAi]
	,	/*rb.bActive, rb.dtCreated,*/ rb.dtUpdated		/*	don't exist	*/
	from	tbRoomBed	rb	with (nolock)
		inner join		tbDevice	d	with (nolock)	on	d.idDevice = rb.idRoom		and	d.bActive > 0
		inner join		tbRoom		r	with (nolock)	on	r.idRoom = rb.idRoom
		left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
		left outer join	vwStaff		a1	with (nolock)	on	a1.idStaff = rb.idAsnRn
		left outer join	vwStaff		a2	with (nolock)	on	a2.idStaff = rb.idAsnCn
		left outer join	vwStaff		a3	with (nolock)	on	a3.idStaff = rb.idAsnAi
go
--	----------------------------------------------------------------------------
--	Removes expired active events
--	v.7.02	refactor
--			* commented resetting tbRoomBed (prEvent84_Ins should deal with that)
--			* commented removal with no tbEvent_P (DELETE conflicted with ref constraint "fkEventC_Event_Aide")
--	v.7.00	+ pr_Module_Act call
--	v.6.05	* reset tbDevice.idEvent
--			* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--			tracing
--	v.6.04	+ removal from tbRoomBed.idEvent
--			+ removal of healing 84s
--	v.6.03	+ removal of inactive events
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.01
alter proc		dbo.prEvent_A_Exp
(
	@tiPurge	tinyint	= 0			-- 0=don't remove any events
									-- N=remove healing 84s older than N days (cascaded)
									-- 255=remove all inactive events from [tbEvent*] (cascaded)
									--	[select iValue from tb_OptionSys where idOption=7]
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
	declare		@dt		datetime
	declare		@i		int

	set	nocount	on

	begin	tran

		exec	pr_Module_Act	1
		select	@dt=	getdate( )					--	mark starting time

	--	update	d	set	d.idEvent= null				--	reset tbDevice.idEvent
	--		from	tbDevice	d
	--		inner join	tbEvent_A	ea	on	ea.idEvent = d.idEvent
	--		where	ea.dtExpires < getdate( )
		update	r	set	r.idEvent= null				--	reset tbRoom.idEvent		v.7.02
			from	tbRoom	r
			inner join	tbEvent_A	ea	on	ea.idEvent = r.idEvent
			where	ea.dtExpires < @dt
		update	rb	set	rb.idEvent= null			--	reset tbRoomBed.idEvent		v.7.02
			from	tbRoomBed	rb
			inner join	tbEvent_A	ea	on	ea.idEvent = rb.idEvent
			where	ea.dtExpires < @dt

		delete	from	tbEvent_A	where	dtExpires < @dt
		delete	from	tbEvent_P	where	dtExpires < @dt

		delete	a	from	tbEvent_A a				--	remove children whose parent no longer exists
			left outer join	tbEvent_P p	on	p.cSys = a.cSys	and	p.tiGID = a.tiGID	and	p.tiJID = a.tiJID
			where	p.idEvent is null

	/*	delete	from	tbEvent_P					--	WHERE col IN (SELECT ..) == INNER JOIN (SELECT ..) !!
			where	idEvent in
			(select	p.idEvent
				from	tbEvent_P p
				left outer join	tbEvent_A a	on	a.cSrcSys = p.cSrcSys	and	a.tiSrcGID = p.tiSrcGID	and	a.tiSrcJID = p.tiSrcJID
				group	by p.idEvent
				having	count(a.idEvent) = 0)	*/
		delete	p	from	tbEvent_P p				--	remove parents that do not have any children
			inner join
			(select	p.idEvent						--	better statement, though same execution plan
				from	tbEvent_P p
				left outer join	tbEvent_A a	on	a.cSys = p.cSys	and	a.tiGID = p.tiGID	and	a.tiJID = p.tiJID
				group	by p.idEvent
				having	count(a.idEvent) = 0) t		on	t.idEvent = p.idEvent

	--	update	rb	set	rb.idEvent=	null, tiSvc= null	--	v.7.02: no need to reset tbRoomBed here
	--		from	tbRoomBed rb
	--		left outer join	tbEvent_A a	on	a.idEvent = rb.idEvent
	--		where	a.idEvent is null	or	a.bActive = 0

		if	@tiPurge > 0
		begin
			if	@tiPurge = 255						--	remove all inactive events
			begin
				update	t	set	t.idVoice= null
					from	tbEvent_T t
					left outer join	tbEvent_A a	on	a.idEvent = t.idVoice
					where	a.idEvent is null
				update	t	set	t.idStaff= null
					from	tbEvent_T t
					left outer join	tbEvent_A a	on	a.idEvent = t.idStaff
					where	a.idEvent is null

				update	c	set	c.idVoice= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idVoice
					where	a.idEvent is null
				update	c	set	c.idStaff= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idStaff
					where	a.idEvent is null
				update	c	set	c.idRn= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idRn
					where	a.idEvent is null
				update	c	set	c.idCn= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idCn
					where	a.idEvent is null
				update	c	set	c.idAi= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idAi
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left outer join	tbEvent_A a	on	a.idEvent = e.idEvent
					where	a.idEvent is null
				select	@i=	@@rowcount

		--		delete	e	from	tbEvent e		--	v.7.02: DELETE conflicted with ref constraint "fkEventC_Event_Aide"
		--			left outer join	tbEvent_P p	on	p.idEvent = e.idEvent
		--			where	p.idEvent is null

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount + @i as varchar) +
							' inactive rows in ' + convert(varchar, getdate() - @dt, 114)
				exec	pr_Log_Ins	2, null, null, @s
			end
			else	--	if	@tiPurge < 255			--	remove healing 84s
			begin
				declare		@idEvent	int

				select	@idEvent=	max(idEvent)	--	get latest idEvent before which healing 84s are to be removed
					from	tbEvent_S
					where	dEvent <= dateadd(dd, -@tiPurge, getdate( ))
					and		tiHH <= datepart(hh, getdate( ))
		/*		create table	#tbHeal84			--	test run indicates slightly better performance with temp-table!?
				(
					idEvent		int
				)

				insert	#tbHeal84
					select	e.idEvent
						from	tbEvent	e
							inner join	tbEvent84	e84	on	e84.idEvent = e.idEvent
						where	e.idLogType is null
							and	e84.siIdxNew = e84.siIdxOld
							and	e.idEvent < @idEvent
				delete	e	from	tbEvent	e
					inner join	#tbHeal84 h	on	h.idEvent = e.idHealing		*/
				delete	e	from	tbEvent	e		--	but for now leave cleaner => simpler variant
					inner join
						(select	e.idEvent
							from	tbEvent	e
								inner join	tbEvent84	e84	on	e84.idEvent = e.idEvent
							where	e.idLogType is null		and	e84.siIdxNew = e84.siIdxOld		--	healing 84
								and	e.idEvent < @idEvent
						) h	on	h.idEvent = e.idEvent

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
							' healing rows in ' + convert(varchar, getdate() - @dt, 114)
				exec	pr_Log_Ins	2, null, null, @s
			end

		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	v.7.02	enforce tbEvent.idRoom to only contain valid room references
--			* setting tbRoom.idUnit (moved from tbDevice)
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ extended expiration for picked calls
--			+ (nolock)
--	v.6.04	* tbEvent.idRoom assignment for @tiStype = 26
--			+ populating tbDevice.idUnit
--			+ populating tbEvent_S, tbEvent.idRoom
--	v.6.03	+ check for tiShelf,tiSpec before inserting to [tbEvent_T] - fixes 'presense' in RptCallActSum
--			+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			added 0x97 to "flipped" (src-dst) commands
--	v.6.02	* logic change to allow idCmd=0 without touching tbEvent_P
--			* prDevice_GetIns: + @cSys (+ tbDevice.cSys), order of @rgs (prEvent_Ins)
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			+ @idUnit
--	v.5.01	encryption added
--			+ tbEvent.idParent, + .tParent, now records parent ref
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			@tiBed set to 'null' when > 9
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	v.2.03	+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--	v.2.01	.idRoom -> .idDevice (FK changed also)
--	v.1.09	+ @idType= null
--	v.1.08
--	v.1.00
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

,	@idEvent	int out				-- output: inserted idEvent
,	@idSrcDvc	smallint out		-- output: found/inserted source device
,	@idDstDvc	smallint out		-- output: found/inserted destination device

,	@idLogType	tinyint = null		-- type look-up FK (marks significant events only)
,	@idCall		smallint = null		-- call look-up FK (only 41,84,8A and 95 commands)
,	@tiBtn		tinyint = null		-- src|dst button code (0-31)
,	@tiBed		tinyint = null		-- bed index
,	@idUnit		smallint = null		-- active unit ID
,	@iAID		int = null			-- device A-ID (32 bits)
,	@tiStype	tinyint = null		-- device type (1-255)
)
	with encryption
as
begin
	declare		@dtEvent	datetime
	declare		@tiHH		tinyint
	declare		@idRoom		smallint
	declare		@cDevice	char( 1 )
	declare		@idParent	int
	declare		@dtParent	datetime
	declare		@tiShelf	tinyint
	declare		@tiSpec		tinyint
	declare		@iExpNrm	int
--	declare		@s			varchar( 255 )

	set	nocount	on

	select	@dtEvent=	getdate( )
		,	@tiHH=		datepart( hh, getdate( ) )
		,	@cDevice=	case when @idCmd = 0x83 then 'G' else '?' end		--	null

	select	@iExpNrm= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 9

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@tiBed= null

--	-if	@idUnit is not null			--	no need to validate (FK not enforced) - just log the value!
--	-	if	0 <= @idUnit	and	@idUnit < 0x01FF
--	-		if	not exists	(select 1 from tbDefLoc where idLoc = @idUnit)	-- and cLoc = 'U'
--	-			select	@idUnit=	null

--	select	@s=	'Evt_I( cmd=' + isnull(cast(@idCmd as varchar),'?') + ', unit=' + isnull(cast(@idUnit as varchar),'?') + ' typ=' + isnull(cast(@tiStype as varchar),'?') +
--				', src=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sSrcDvc,'?') +
--				'], dst=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sDstDvc,'?') +
--				'], btn=' + isnull(cast(@tiBtn as varchar),'?') + ', bed=' + isnull(cast(@tiBed as varchar),'?') + ' )'		--	 + ' i=' + isnull(@sInfo,'?')
--	exec	pr_Log_Ins	0, null, null, @s

	begin	tran

		exec	dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, null, null, @sDstDvc, null, @idDstDvc out

		insert	tbEvent	(  idCmd,  tiLen,  iHash,  vbCmd,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit,
						 cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  idSrcDvc,
						 cDstSys,  tiDstGID,  tiDstJID,  tiDstRID,  idDstDvc,
						 dtEvent,  dEvent,  tEvent,  tiHH )
				values	( @idCmd, @tiLen, @iHash, @vbCmd, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit,
						@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @idSrcDvc,
						@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @idDstDvc,
						@dtEvent, @dtEvent, @dtEvent, @tiHH )
		select	@idEvent=	scope_identity( )

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	v.6.02
		begin
			if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)	--	audio, set-svc, pat-dtl-req events link to parent via destination
			begin
				select	@idParent= idEvent, @dtParent= dtEvent
					from	tbEvent_P	with (nolock)
					where	cSys = @cSrcSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	--and	tiRID = @tiDstRID	and	tiBtn = @tiDstBtn
				--		and	dtExpires > getdate( )

				if	@tiSrcJID = 0	--and	@tiSrcRID = 0		--	Gateway			v.7.02
					select	@idRoom=	null
				else
				if	@tiSrcRID = 0	or	@tiStype = 26			--	Room-Ctrlr	or	7967-P - Patient Workflow	v.6.04
					select	@idRoom=	idDevice
						from	tbDevice	with (nolock)
						where	idDevice = @idDstDvc	and	cDevice = 'R'		--	v.7.02
				else
					select	@idRoom=	p.idDevice
						from	tbDevice d		with (nolock)
						inner join	tbDevice p	with (nolock)	on	p.idDevice = d.idParent	and	p.cDevice = 'R'
						where	d.idDevice = @idDstDvc							--	v.7.02
			end
			else
			begin
				select	@idParent= idEvent, @dtParent= dtEvent
					from	tbEvent_P	with (nolock)
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn

				if	@tiSrcJID = 0	--and	@tiSrcRID = 0		--	Gateway			v.7.02
					select	@idRoom=	null
				else
				if	@tiSrcRID = 0	or	@tiStype = 26			--	Room-Ctrlr	or	7967-P - Patient Workflow	v.6.04
					select	@idRoom=	idDevice								-- @idSrcDvc
						from	tbDevice	with (nolock)
						where	idDevice = @idSrcDvc	and	cDevice = 'R'		--	v.7.02
				else
					select	@idRoom=	p.idDevice
						from	tbDevice d		with (nolock)
						inner join	tbDevice p	with (nolock)	on	p.idDevice = d.idParent	and	p.cDevice = 'R'
						where	d.idDevice = @idSrcDvc							--	v.7.02
			end

--			select	@s=	'Evt_i2: prnt=' + isnull(cast(@idParent as varchar),'?') + ' room=' + isnull(cast(@idRoom as varchar),'?')
--			exec	pr_Log_Ins	0, null, null, @s

			if	@idParent is null	--	no parent found
			begin
				update	tbEvent		set	idParent= @idEvent,		idRoom= @idRoom,	tParent= '0:0:0',	@dtParent= dtEvent
					where	idEvent = @idEvent
				insert	tbEvent_P	( idEvent, dtEvent, cSys, tiGID, tiJID, dtExpires )	--, tiRID, tiBtn
						values		( @idEvent, @dtParent, @cSrcSys, @tiSrcGID, @tiSrcJID,
									dateadd(ss, @iExpNrm, @dtParent) )	--, @tiSrcRID, @tiSrcBtn

				if	@idCall > 0		--	v.6.03
				begin
					select	@tiShelf= p.tiShelf, @tiSpec= p.tiSpec
						from	tbDefCallP	p	with (nolock)
						inner join	tbDefCall	c	with (nolock)	on	c.siIdx = p.idIdx	and	c.idCall = @idCall

					if	( @tiShelf > 0	and		( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 ) )	--	only save 'medical' calls
		--	-		--	!!	'presence' works for prEvent84_Ins;  but it should be excluded from tbEvent_T	!!
		--	-			or	@tiSpec between 7 and 9															--	or 'presence'
						begin
							insert	tbEvent_T	( idEvent, dEvent, tEvent, tiHH, idRoom, idCall )
									values		( @idEvent, @dtParent, @dtParent, datepart( hh, @dtParent ), @idRoom, @idCall )		--	v.6.04:	@idRoom
						end
				end
			end
			else	--	parent found
			begin
				update	tbEvent		set	idParent= @idParent,	idRoom= @idRoom,	tParent= dtEvent - @dtParent
					where	idEvent = @idEvent

				select	@dtParent=	dateadd(ss, @iExpNrm, getdate( ))	--	v.6.05
				update	tbEvent_P	set	dtExpires= @dtParent
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
						and	dtExpires < @dtParent						--	v.6.05
			end
		end

		select	@idParent= null			--	v.6.04
		select	@idParent= idEvent
			from	tbEvent_S	with (nolock)
			where	dEvent = cast(@dtEvent as date)
				and	tiHH = @tiHH
		if	@idParent	is null
			insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
					values		( @dtEvent, @tiHH, @idEvent )

		if	@idUnit > 0								--	v.7.02
			update	tbRoom		set	idUnit=	@idUnit
				where	idRoom = @idRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	tbEvent84
--	v.7.02	.tiCvrgA* -> .tiCvrg*, siDutyA* -> siDuty*, siZoneA* -> siZone*
--			.tiTmrStat -> .tiTmrSt, .tiTmrCna -> .tiTmrCn, .tiTmrAide -> .tiTmrAi
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent84') and name = 'tiTmrSt')
begin
	begin tran
		exec sp_rename 'tbEvent84.tiTmrStat', 'tiTmrSt', 'column'
		exec sp_rename 'tbEvent84.tiTmrCna', 'tiTmrCn', 'column'
		exec sp_rename 'tbEvent84.tiTmrAide', 'tiTmrAi', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA0', 'tiCvrg0', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA1', 'tiCvrg1', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA2', 'tiCvrg2', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA3', 'tiCvrg3', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA4', 'tiCvrg4', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA5', 'tiCvrg5', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA6', 'tiCvrg6', 'column'
		exec sp_rename 'tbEvent84.tiCvrgA7', 'tiCvrg7', 'column'
		exec sp_rename 'tbEvent84.siDutyA0', 'siDuty0', 'column'
		exec sp_rename 'tbEvent84.siDutyA1', 'siDuty1', 'column'
		exec sp_rename 'tbEvent84.siDutyA2', 'siDuty2', 'column'
		exec sp_rename 'tbEvent84.siDutyA3', 'siDuty3', 'column'
		exec sp_rename 'tbEvent84.siZoneA0', 'siZone0', 'column'
		exec sp_rename 'tbEvent84.siZoneA1', 'siZone1', 'column'
		exec sp_rename 'tbEvent84.siZoneA2', 'siZone2', 'column'
		exec sp_rename 'tbEvent84.siZoneA3', 'siZone3', 'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
--	v.7.02	* @tiTmrStat -> @tiTmrSt, @tiTmrCna -> @tiTmrCn, @tiTmrAide -> @tiTmrAi
--			* @sCna -> @sCn, @sAide -> @sAi
--			+ recording @sRn, @sCn, @sAi into tbRoom (via prRoom_Upd)
--			+ ignore @tiBed if [0x84] is 'presence'
--	v.7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ tbDevice.idEvent
--			+ extended expiration for picked calls
--			+ removal of healing events at once
--			+ (nolock)
--	v.6.04	* comment out prDefStaff_GetInsUpd call
--			now uses prPatient_GetIns, prDoctor_GetIns
--			* room-level calls will be marked for all room's beds in tbRoomBed
--			+ adjust tbEvent_A.dtEvent by @siElapsed - if call has started before
--			+ populating tbRoomBed, + new cache columns in tbEvent_A
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			upon cancellation defer removal of tbEvent_A and tbEvent_P rows
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--	v.6.02	tdDevice.dtLastUpd -> .dtUpdated
--			tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--			tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			@idLoc -> @idUnit
--	v.5.01	encryption added
--			+ tbEvent.idParent, + .tParent, code optimization, parent events
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			.idRn, .idCna, .idAide are in tbEventB4
--	v.4.02	+ @iAID, @tiStype; modified origination and added expiration
--	v.4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--			fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	v.2.03	+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbEventC.tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--			+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	v.2.02	+ tbEventC.idRn, .tRn, .idCna, .tCna, .idAide, .tAide (vwEventC, prEvent84_Ins?)
--	v.2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.08
--	v.1.00
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

,	@tiSrcBtn	tinyint				-- source button code
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
--,	@cBed		char( 1 )			-- bed name
,	@sCall		varchar( 16 )		-- call text
,	@sPatient	varchar( 16 )		-- patient name
,	@sDoctor	varchar( 16 )		-- doctor name
,	@sInfo		varchar( 32 )		-- info text
,	@sDial		varchar( 16 )		-- room dial number
--,	@tiBed		tinyint				-- bed dial number
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

--,	@idEventA	int out				-- output: idEvent, inserted into tbEvent_A
)
	with encryption
as
begin
	declare		@idEvent	int
	declare		@idParent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint
	declare		@idRoom		smallint
	declare		@idCall		smallint
	declare		@siIdxOld	smallint			-- old index
	declare		@siIdxNew	smallint			-- new index
	declare		@idDoctor	int
	declare		@idPatient	int
	declare		@idOrigin	int
	declare		@dtOrigin	datetime
	declare		@tiShelf	tinyint
	declare		@tiSpec		tinyint
	declare		@tiSvc		tinyint
	declare		@tiRmBed	tinyint
	declare		@cBed		char( 1 )
	declare		@tiPurge	tinyint
	declare		@bAudio		bit
	declare		@iExpNrm	int
	declare		@iExpExt	int
--	declare		@s			varchar( 255 )

	set	nocount	on

	select	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

	select	@tiPurge= cast(iValue as tinyint)	from	tb_OptionSys	with (nolock)	where	idOption = 7

	select	@iExpNrm= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 9
	select	@iExpExt= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 10

	if	@siIdxNew > 0			-- call placed
	begin
		exec	dbo.prDefCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiSpec= tiSpec		from	tbDefCallP	with (nolock)	where	idIdx = @siIdxNew
	end
	else if	@siIdxOld > 0		-- call cancelled
	begin
		exec	dbo.prDefCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiSpec= tiSpec		from	tbDefCallP	with (nolock)	where	idIdx = @siIdxOld
	end
	else
		select	@idCall= 0		--	INTERCOM call
	---	exec	dbo.prDefCall_GetIns	0, @sCall, @idCall out		--	no need to call

	if	@tiSpec between 7 and 9
		select	@tiBed=	0xFF	--	drop bed-index for 'presence' calls

	if	@tiBed > 9	--	= 0xFF	or	@tiBed = 0
		select	@cBed= null,	@tiBed= null
	else
		select	@cBed= cBed		from	tbDefBed	with (nolock)	where	idIdx = @tiBed

	exec	dbo.prPatient_GetIns	@sPatient, null, null, null, @sDoctor, @idPatient out
--	exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out		--	v.7.02

	begin	tran

		if	@tiBed is not null		-- >= 0
			update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed	and	bInUse = 0

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiSrcBtn, @tiBed, @idUnit, @iAID, @tiStype

		if	@idSrcDvc is not null	and	len( @sDial ) > 0
			update	tbDevice	set	sDial= @sDial, dtUpdated= getdate( )
				where	idDevice = @idSrcDvc	and	( sDial <> @sDial	or sDial is null )	--!

		insert	tbEvent84	(  idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew,
							tiTmrSt,  tiTmrRn,  tiTmrCn,  tiTmrAi,  idPatient,  idDoctor,  iFilter,
							tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
							siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
				values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew,
							@tiTmrSt, @tiTmrRn, @tiTmrCn, @tiTmrAi, @idPatient, @idDoctor, @iFilter,
							@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
							@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3)

		select	@idOrigin= idEvent, @dtOrigin= dtEvent, @bAudio= bAudio
			from	tbEvent_A	with (nolock)
			where	cSys = @cSrcSys
				and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
				and	bActive > 0				--	6.04

	---	if	@siIdxOld = 0	or	@idOrigin is null	--	new call placed | no active origin found
		if	@idOrigin is null	--	no active origin found
			--	'real' new call should not have origin anyway, 'repeated' one would be linked to starting - even better
		begin
			update	tbEvent		set	idOrigin= @idEvent, idLogType= 191	-- call placed
								,	tOrigin= dateadd(ss, @siElapsed, '0:0:0')										--	v.6.05
								,	@dtOrigin= dateadd(ss, - @siElapsed, dtEvent), @idSrcDvc= idSrcDvc, @idParent= idParent		--	v.6.04
				where	idEvent = @idEvent
			insert	tbEvent_A	(  idEvent,   dtEvent,  cSys,     tiGID,     tiJID,     tiRID,     tiBtn,     siPri,     siIdx,     tiBed, dtExpires )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiSrcBtn, @siPriNew, @siIdxNew, @tiBed,		--	v.6.04
								dateadd(ss, @iExpNrm, getdate( )) )	--@dtOrigin
			update	tbEvent_T	set	idCall= @idCall, idUnit= @idUnit, cBed= @cBed
				where	idEvent = @idParent		and	@idCall is null		-- there could be more than one, but we need to use only 1st one

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbDefCallP	with (nolock)	where	idIdx = @siIdxNew

			if	( @tiShelf > 0	and		( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 ) )	--	only save 'medical' calls
				or	@tiSpec between 7 and 9															--	or 'presence'
				begin
					if	@tiSrcRID > 0	--	is source device a station?
						select	@idSrcDvc= idParent		--	room-controller must be the station's parent!
							from	tbDevice	with (nolock)
							where	idDevice = @idSrcDvc
					insert	tbEvent_C	( idEvent, dEvent, tEvent, tiHH, idCall, idRoom, idUnit, cBed )
							values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idSrcDvc, @idUnit, @cBed )
				end
			if	@tiSpec = 7
				update	c	set	idRn= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
			else if	@tiSpec = 8
				update	c	set	idCn= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
			else if	@tiSpec = 9
				update	c	set	idAi= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID

			select	@idOrigin= @idEvent		--	6.04
		end
		else	--	active origin found		(=> this must be a healing or cancellation event)
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
			--		,@idSrcDvc= idSrcDvc
				where	idEvent = @idEvent
			update	tbEvent_A	set	dtExpires= dateadd(ss, @iExpNrm, getdate( ))
								,	siPri= @siPriNew
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	bActive > 0				--	6.04
		end

		if	@siIdxNew = 0	-- call cancelled
		begin
		--	6.03:	upon cancellation mark inactive, but defer removal of tbEvent_A and tbEvent_P rows - let them expire,
		--				so that events from same sequence (that are still-unfinished) can be tied to the same origin
			select	@dtOrigin=	case when @bAudio=0 then dateadd(ss, @iExpNrm, getdate( ))				--	6.05
													else dateadd(ss, @iExpExt, getdate( )) end

			update	tbEvent_A	set	dtExpires= @dtOrigin, bActive= 0,	tiSvc= null		--	6.05
	--							,	tiTmrStat= null, tiTmrRn= null, tiTmrCna= null, tiTmrAide= null		--	6.04
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	bActive > 0				--	6.04

			update	tbEvent_P	set	dtExpires= @dtOrigin												--	6.05
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	dtExpires < @dtOrigin

	--		select	@s=	@cSrcSys + '-' + cast(@tiSrcGID as varchar) + '-' + cast(@tiSrcJID as varchar) +
	--					' -> ' + convert(varchar, @dtOrigin, 121) + ' rows:' + cast(@@rowcount as varchar)
	--		exec	pr_Log_Ins	0, null, null, @s

			select	@dtOrigin= tOrigin, @idParent= idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	tbEvent_C	set	idStaff= @idEvent, tStaff= @dtOrigin
				where	idEvent = @idOrigin		and	idStaff is null		-- there should be only one, but just in case use only 1st one
			update	tbEvent		set	idLogType= 193		-- call cleared
				where	idEvent = @idEvent

			select	@tiSpec= tiSpec	from	tbDefCallP	with (nolock)	where	idIdx = @siIdxOld

			if	@tiSpec = 7
			begin
				update	tbEvent_C	set	tRn= @dtOrigin
					where	idRn = @idOrigin
				update	tbEvent_T	set	tRn= isnull(tRn, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end
			else if	@tiSpec = 8
			begin
				update	tbEvent_C	set	tCn= @dtOrigin
					where	idCn = @idOrigin
				update	tbEvent_T	set	tCn= isnull(tCn, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end
			else if	@tiSpec = 9
			begin
				update	tbEvent_C	set	tAi= @dtOrigin
					where	idAi = @idOrigin
				update	tbEvent_T	set	tAi= isnull(tAi, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end

		--	can't do following for @tiSpec=7|8|9 (and maybe others!?..)
			if	@tiSpec is null		or @tiSpec < 7	or	@tiSpec > 9
				update	tbEvent_T	set	idStaff= @idEvent, tStaff= @dtOrigin
					where	idEvent = @idParent		and	idStaff is null			-- there should be only one, but just in case use only 1st one
		end
		else if	@siIdxNew > 0  and  @siIdxOld > 0  and  @siIdxOld <> @siIdxNew
			update	tbEvent		set	idLogType= 192		-- call escalated
				where	idEvent = @idEvent

		select	@idRoom= idRoom		--, @idCall= idCall		--	get idRoom, assigned by prEvent_Ins
			from	tbEvent		with (nolock)
			where	idEvent = @idEvent

		exec	dbo.prRoom_Upd		@idRoom, @sRn, @sCn, @sAi

		if	@tiPurge > 0
			delete	from	tbEvent							-- remove healing event at once (cascade rule must take care of other tables)
				where	idEvent = @idEvent
					and	idLogType is null

		if	@tiTmrSt > 3		select	@tiTmrSt=	3
		if	@tiTmrRn > 3		select	@tiTmrRn=	3
		if	@tiTmrCn > 3		select	@tiTmrCn=	3
		if	@tiTmrAi > 3		select	@tiTmrAi=	3

		update	tbEvent_A	set	idRoom= @idRoom				--	cache necessary details in the active call (tiBed is null for room-level calls)
							,	idCall= @idCall	--, tiTmrStat= @tiTmrSt, tiTmrRn= @tiTmrRn, tiTmrCna= @tiTmrCn, tiTmrAide= @tiTmrAi
							,	tiSvc= @tiTmrSt*64 + @tiTmrRn*16 + @tiTmrCn*4 + @tiTmrAi	---, tiBed= @tiBed	--	v.6.05
			where	idEvent = @idOrigin

		if	@tiBed is not null								--	if argument is a bed-level call
			update	tbRoomBed	set	idPatient= @idPatient, dtUpdated= getdate( )		--, idDoctor= @idDoctor	--	v.7.02
				,	tiIbed= case when	@tiStype = 192	then		--	only for 7947 (iBed)
									case when	@siIdxNew = 0	then	--	call cancelled
										tiIbed &
										case when	@tiSrcBtn = 2	then	0xFE
											when	@tiSrcBtn = 7	then	0xFD
											when	@tiSrcBtn = 6	then	0xFB
											when	@tiSrcBtn = 5	then	0xF7
											when	@tiSrcBtn = 4	then	0xEF
											when	@tiSrcBtn = 3	then	0xDF
											when	@tiSrcBtn = 1	then	0xBF
											when	@tiSrcBtn = 0	then	0x7F
											else	0xFF	end
										else							--	call placed / being-healed
										tiIbed |
										case when	@tiSrcBtn = 2	then	0x01
											when	@tiSrcBtn = 7	then	0x02
											when	@tiSrcBtn = 6	then	0x04
											when	@tiSrcBtn = 5	then	0x08
											when	@tiSrcBtn = 4	then	0x10
											when	@tiSrcBtn = 3	then	0x20
											when	@tiSrcBtn = 1	then	0x40
											when	@tiSrcBtn = 0	then	0x80
											else	0x00	end
										end
								else	tiIbed	end					--	don't change
				where	idRoom = @idRoom
					and	tiBed = @tiBed

	---	!! @idEvent will no longer point to the current event !!

		select	@idEvent= null, @tiSvc= null
		select	top 1	@idEvent= idEvent, @tiSvc= tiSvc	--	select highest visible(?) active call for this room-bed (room- or bed-level)
			from	tbEvent_A	ea	with (nolock)
	--		inner join	tbDefCallP	cp	with (nolock)	on	cp.idIdx = ea.siIdx		and	cp.tiShelf > 0
			where	idRoom = @idRoom
				and	bActive > 0
				and	(tiBed is null	or tiBed = @tiBed)
			order	by	siIdx desc, idEvent desc

	--	update	tbDevice	set	idEvent= @idEvent,	tiSvc= @tiSvc
	--		where	idDevice = @idRoom
		update	tbRoom	set	idEvent= @idEvent,	tiSvc= @tiSvc
			where	idRoom = @idRoom

		declare		cur		cursor fast_forward for
			select	tiBed
				from	tbRoomBed
				where	idRoom = @idRoom

		open	cur
		fetch next from	cur	into	@tiRmBed
		while	@@fetch_status = 0
		begin
			select	@idEvent= null, @tiSvc= null
			select	top 1	@idEvent= idEvent, @tiSvc= tiSvc	--	select highest visible(?) active call (room- or bed-level)
				from	tbEvent_A	ea	with (nolock)
	--			inner join	tbDefCallP	cp	with (nolock)	on	cp.idIdx = ea.siIdx		and	cp.tiShelf > 0
				where	idRoom = @idRoom
					and	bActive > 0
					and	(tiBed is null	or tiBed = @tiRmBed)
				order	by	siIdx desc, idEvent desc

	--		if	@idEvent is not null
			update	tbRoomBed	set	idEvent= @idEvent, dtUpdated= getdate( )
				,	tiSvc= case when @siIdxNew = 0 then null else @tiSvc end
				where	idRoom = @idRoom
					and	tiBed = @tiRmBed

			fetch next from	cur	into	@tiRmBed
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.02	.tiCvrgA* -> .tiCvrg*, siDutyA* -> siDuty*, siZoneA* -> siZone*
--			.tiTmrStat -> .tiTmrSt, .tiTmrCna -> .tiTmrCn, .tiTmrAide -> .tiTmrAi
--	v.6.04	+ .bAnswered, + .cGender
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	v.5.01	encryption added
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	v.4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--	v.2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.00
alter view		dbo.vwEvent84
	with encryption
as
select	e84.idEvent, e.dtEvent, e.idCmd, e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID, e.tiBtn
	,	e.idSrcDvc, d.sDevice, e.idRoom, r.sDevice [sRoom], r.sDial, e.tiBed, e.idCall, c.sCall, e.idUnit	--, l.sLoc [sUnit]
	,	e84.siPriOld, e84.siPriNew, e84.siIdxOld, e84.siIdxNew, e84.iFilter
	,	cast( case when e84.siPriNew & 0x0400 > 0 then 0 else 1 end as bit ) [bAnswered]
	,	e84.siElapsed, e84.tiPrivacy, e84.tiTmrSt, e84.tiTmrRn, e84.tiTmrCn, e84.tiTmrAi
	,	e84.idPatient, p.sPatient, p.cGender
	,	e84.idDoctor, v.sDoctor, e.sInfo
	,	e84.tiCvrg0, e84.tiCvrg1, e84.tiCvrg2, e84.tiCvrg3, e84.tiCvrg4, e84.tiCvrg5, e84.tiCvrg6, e84.tiCvrg7
	,	e84.siDuty0, e84.siDuty1, e84.siDuty2, e84.siDuty3, e84.siZone0, e84.siZone1, e84.siZone2, e84.siZone3
	from	tbEvent84	e84
	inner join	tbEvent	e	on	e.idEvent = e84.idEvent
	inner join	tbDevice	d	on	d.idDevice = e.idSrcDvc
	inner join	tbDevice	r	on	r.idDevice = e.idRoom
	inner join	tbDefCall	c	on	c.idCall = e.idCall
---	left outer join	tbDefLoc	l	on	l.idLoc = e.idUnit
	left outer join	tbPatient	p	on	p.idPatient = e84.idPatient
	left outer join	tbDoctor	v	on	v.idDoctor = e84.idDoctor
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
--	v.7.02	* tbEvent.tElapsed -> .tOrigin
--	v.7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ extended expiration for picked calls
--			+ tagging tbEvent_A.bAudio
--			+ (nolock)
--	v.6.04	* @siPri -> @siIdx arg in call to prDefCall_GetIns
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--	v.6.02	tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.01	encryption added
--			+ tbEvent.idParent, + .tParent, parent events
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	v.4.01	fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	v.2.03	.idSrcDvc -> .idDstDvc (prEvent8A_Ins, vwEvent8A)
--			+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbEventC.tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--			fix for non-med EventC insertions, changed Event.idType if no origin
--			+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	v.2.01	- .idDstDvc
--			.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.08
--	v.1.00
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
,	@tiDstBtn	tinyint				-- destination button code
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
	declare		@idParent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint
	declare		@idCall		smallint
	declare		@siIdx		smallint			-- call-index
	declare		@idOrigin	int
	declare		@dtOrigin	datetime
	declare		@tiShelf	tinyint
	declare		@tiSpec		tinyint
	declare		@cBed		char( 1 )
	declare		@iExpNrm	int

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbDefBed	with (nolock)	where	idIdx = @tiBed

	select	@siIdx=	@siPri & 0x03FF

	select	@iExpNrm= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 9

	begin	tran

		if	@tiBed >= 0
			update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed	and	bInUse = 0

		if	@siPri > 0
			exec	dbo.prDefCall_GetIns	@siIdx, @sCall, @idCall out
		else
---			exec	dbo.prDefCall_GetIns	0, @sCall, @idCall out		--	no need to call
			select	@idCall= 0				--	INTERCOM call

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiDstBtn, @tiBed

		insert	tbEvent8A	( idEvent,  tiSrcJAB,  tiSrcLAB,  tiDstJAB,  tiDstLAB,
							siPri,  tiFlags,  siIdx )
				values		( @idEvent, @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB,
							@siPri, @tiFlags, @siIdx )

		select	@idOrigin= idEvent, @dtOrigin= dtEvent
			from	tbEvent_A	with (nolock)
---			where	cSrcSys = @cDstSys
---				and	tiSrcGID = @tiDstGID	and	tiSrcJID = @tiDstJID	and	tiSrcRID = @tiDstRID	and	tiSrcBtn = @tiDstBtn
			where	cSys = @cDstSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiDstBtn
		---		and	bActive > 0				--	6.05 (6.04 in 84!)

		if	@idOrigin	is not null
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
				where	idEvent = @idEvent

			if	@idCmd = 0x89
				update	tbEvent		set	idLogType= 195						-- audio request
					where	idEvent = @idEvent
			else if	@idCmd = 0x88
				update	tbEvent		set	idLogType= 196						-- audio busy
					where	idEvent = @idEvent
			else if	@idCmd = 0x8A		-- AUDIO GRANT == voice response
			begin
				update	tbEvent_A	set	bAudio= 1							-- connected
					where	idEvent = @idOrigin
				select	@dtOrigin= tOrigin, @idParent= idParent
					from	tbEvent		with (nolock)
					where	idEvent = @idEvent
				update	tbEvent		set	idLogType= 197						-- audio connected
					where	idEvent = @idEvent
				update	tbEvent_C	set	idVoice= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idOrigin		and	idVoice is null		-- there should be only one, but just in case use only 1st one
				update	tbEvent_T	set	idVoice= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idParent		and	idVoice is null		-- there should be only one, but just in case use only 1st one
			end
			else if	@idCmd = 0x8D
			begin
				update	tbEvent_A	set	bAudio= 0							-- disconnected
					,	dtExpires= case when bActive = 0 then dateadd(ss, @iExpNrm, getdate( ))
														else dtExpires end
					where	idEvent = @idOrigin
				update	tbEvent		set	idLogType= 199						-- audio quit
					where	idEvent = @idEvent
			end
		end
		else	-- no origin found
		begin
			update	tbEvent		set	idOrigin= @idEvent, tOrigin= '0:0:0' --,	idLogType= 198	-- audio dialed
				,	idLogType=	case when @idCmd = 0x8D then 199			-- audio quit
									when @idCmd = 0x89 then 195				-- audio request
									when @idCmd = 0x88 then 196				-- audio busy
									else					197 end,		-- audio connected
					@idDstDvc= idSrcDvc, @dtOrigin= dtEvent
				where	idEvent = @idEvent

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbDefCallP	with (nolock)	where	idIdx = @siIdx

			if	@tiShelf > 0	and	(@tiSpec is null	or	@tiSpec < 6	or	@tiSpec = 18)
			begin									--	only save "medical" calls as transactions
				if	@tiDstRID > 0					--	is destination device a station?
					select	@idDstDvc= idParent		--	then room (room-controller) is station's parent!
						from	tbDevice	with (nolock)
						where	idDevice = @idSrcDvc
				insert	tbEvent_C	( idEvent, dEvent, tEvent, tiHH, idCall, idRoom, cBed )
						values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idDstDvc, @cBed )
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
--	v.7.02	* tbEvent.tElapsed -> .tOrigin
--	v.7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ (nolock)
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--			+ @siPri (to pass in call-index from 0x95 cmd)
--	v.6.02	tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			@idLoc -> @idUnit
--	v.5.01	encryption added
--			fix for idDstDvc
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	v.4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--			fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	v.2.03	+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	v.2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.00
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
,	@tiDstBtn	tinyint				-- destination button code
,	@tiSvcSet	tinyint				-- bit: 1=Aide,2=CNA,4=RN,8=Stat
,	@tiSvcClr	tinyint				-- bit: 1=Aide,2=CNA,4=RN,8=Stat
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
--,	@cBed		char( 1 )			-- bed name
,	@siPri		smallint			-- call index
,	@sCall		varchar( 16 )		-- call text
,	@sInfo		varchar( 16 )		-- tag message text
,	@idUnit		smallint			-- active unit ID

--,	@idEvent	int out				-- output: inserted idEvent
)
	with encryption
as
begin
	declare		@idEvent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint
	declare		@idCall		smallint
			,	@siIdx		smallint			-- call-index
	declare		@idOrigin	int
	declare		@dtOrigin	datetime
	declare		@cBed		char( 1 )

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbDefBed	with (nolock)	where	idIdx = @tiBed

	select	@siIdx=	@siPri & 0x03FF

	begin	tran

		if	@tiBed >= 0
			update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed	and	bInUse = 0

		if	@siIdx > 0
			exec	dbo.prDefCall_GetIns	@siIdx, @sCall, @idCall out
		else
---			exec	dbo.prDefCall_GetIns	0, @sCall, @idCall out		--	no need to call
			select	@idCall= 0				--	INTERCOM call

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDevice, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiDstBtn, @tiBed, @idUnit

		insert	tbEvent95	( idEvent,  tiSvcSet,  tiSvcClr )
				values		( @idEvent, @tiSvcSet, @tiSvcClr )

		begin
			select	@idOrigin= idEvent, @dtOrigin= dtEvent
				from	tbEvent_A	with (nolock)
				where	cSys = @cDstSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiDstBtn
---				where	cSrcSys = @cDstSys
---					and	tiSrcGID = @tiDstGID	and	tiSrcJID = @tiDstJID	and	tiSrcRID = @tiDstRID	and	tiSrcBtn = @tiDstBtn
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
				where	idEvent = @idEvent

			if	@tiSvcSet > 0  and  @tiSvcClr = 0
				update	tbEvent		set	idLogType= 201		-- set svc
					where	idEvent = @idEvent
			else if	@tiSvcSet = 0  and  @tiSvcClr > 0
				update	tbEvent		set	idLogType= 203		-- clear svc
					where	idEvent = @idEvent
			else --	if	@tiSvcSet > 0  and  @tiSvcClr = 0
				update	tbEvent		set	idLogType= 202		-- set/clr
					where	idEvent = @idEvent
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.02	* .ti*Stat -> .ti*St, .ti*Cna -> .ti*Cn, .ti*Aide -> .ti*Ai
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	v.5.01	encryption added
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	v.4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--	v.2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.00
alter view		dbo.vwEvent95
	with encryption
as
select	e.idEvent, h.dtEvent, h.idCmd, h.cSrcSys, h.tiSrcGID, h.tiSrcJID, h.tiSrcRID,
		h.cDstSys, h.tiDstGID, h.tiDstJID, h.tiDstRID, h.tiBtn, e.tiSvcSet, e.tiSvcClr,
		h.idSrcDvc, d.sDevice, d.sDial, h.tiBed, h.idCall, c.sCall, h.sInfo, h.idUnit, l.sLoc,
		tiSvcSet & 0x08 [tiSetSt],	tiSvcSet & 0x04 [tiSetRn],	tiSvcSet & 0x02 [tiSetCn],	tiSvcSet & 0x01 [tiSetAi],
		tiSvcClr & 0x08 [tiClrSt],	tiSvcClr & 0x04 [tiClrRn],	tiSvcClr & 0x02 [tiClrCn],	tiSvcClr & 0x01 [tiClrAi]
	from	tbEvent95	e
--	inner join	vwEvent	h	on	h.idEvent = e.idEvent
	inner join	tbEvent	h	on	h.idEvent = e.idEvent
	inner join	tbDefCall	c	on	c.idCall = h.idCall
	left outer join	tbDevice	d	on	d.idDevice = h.idSrcDvc
	left outer join	tbDefLoc	l	on	l.idLoc = h.idUnit
go
--	----------------------------------------------------------------------------
--	tbEventAB
--	v.7.02	* .tiCvrgAX -> tiCvrgX
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEventAB') and name = 'tiCvrg0')
begin
	begin tran
		exec sp_rename 'tbEventAB.tiCvrgA0', 'tiCvrg0', 'column'
		exec sp_rename 'tbEventAB.tiCvrgA1', 'tiCvrg1', 'column'
		exec sp_rename 'tbEventAB.tiCvrgA2', 'tiCvrg2', 'column'
		exec sp_rename 'tbEventAB.tiCvrgA3', 'tiCvrg3', 'column'
		exec sp_rename 'tbEventAB.tiCvrgA4', 'tiCvrg4', 'column'
		exec sp_rename 'tbEventAB.tiCvrgA5', 'tiCvrg5', 'column'
		exec sp_rename 'tbEventAB.tiCvrgA6', 'tiCvrg6', 'column'
		exec sp_rename 'tbEventAB.tiCvrgA7', 'tiCvrg7', 'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.02	* .tiCvrgAX -> tiCvrgX
--	v.6.05	optimize
--	v.5.01	encryption added
--			+ .tbNtWant
--	v.4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--			consolidated A7(A5-A7), A9(A8,A9,AA,AC) in tbEventAB
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	v.2.03
alter proc		dbo.prEventAB_Ins
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
,	@sSrcDvc	varchar( 16 )		-- source name
,	@sDstDvc	varchar( 16 )		-- destination name
,	@tiNtGrpID	tinyint				-- group ID (1-128)
,	@tiNtStat	tinyint				-- 0xAB: mask of currently owned consoles
,	@tiNtWant	tinyint				-- 0xA9: any or all of desired ownership bits
--,	@sDevice	varchar( 16 )		-- device name
,	@tiCvrg0	tinyint				-- coverage area 0
,	@tiCvrg1	tinyint				-- coverage area 1
,	@tiCvrg2	tinyint				-- coverage area 2
,	@tiCvrg3	tinyint				-- coverage area 3
,	@tiCvrg4	tinyint				-- coverage area 4
,	@tiCvrg5	tinyint				-- coverage area 5
,	@tiCvrg6	tinyint				-- coverage area 6
,	@tiCvrg7	tinyint				-- coverage area 7
,	@iFilter0	int					-- ownership filter bits for CA0
,	@iFilter1	int					-- ownership filter bits for CA1
,	@iFilter2	int					-- ownership filter bits for CA2
,	@iFilter3	int					-- ownership filter bits for CA3
,	@iFilter4	int					-- ownership filter bits for CA4
,	@iFilter5	int					-- ownership filter bits for CA5
,	@iFilter6	int					-- ownership filter bits for CA6
,	@iFilter7	int					-- ownership filter bits for CA7
)
	with encryption
as
begin
	declare		@idEvent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null,
					@idEvent out, @idSrcDvc out, @idDstDvc out

		insert	tbEventAB	( idEvent,  tiNtGrpID,  tiNtStat,  tiNtWant,
							tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
							iFilter0,  iFilter1,  iFilter2,  iFilter3,  iFilter4,  iFilter5,  iFilter6,  iFilter7 )
				values		( @idEvent, @tiNtGrpID, @tiNtStat, @tiNtWant,
							@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
							@iFilter0, @iFilter1, @iFilter2, @iFilter3, @iFilter4, @iFilter5, @iFilter6, @iFilter7 )
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates [or "deletes" - not yet] units
--	v.7.01	* 'MAP ?' -> 'Map ?'
--	v.6.04
alter proc		dbo.prUnit_InsUpdDel
(
	@idUnit		smallInt					-- unit id
,	@sUnit		varchar( 16 )				-- unit name
,	@tiShifts	tinyint						-- # of shifts
,	@iStamp		int							-- import stamp
)
	with encryption
as
begin
	declare		@tiMap	tinyint
	declare		@tiCell	tinyint
--	declare		@s		varchar( 255 )
	set	nocount	on

	begin	tran
		if exists	(select 1 from tbUnit where idUnit=@idUnit)
			update	tbUnit	set	sUnit= @sUnit, tiShifts= @tiShifts, iStamp= @iStamp, dtUpdated= getdate( )
--			update	tbUnit	set	sUnit= @sUnit, tiShifts= @tiShifts, dtUpdated= getdate( )
				where	idUnit=@idUnit
		else
			insert	tbUnit	( idUnit,  sUnit,  tiShifts,  iStamp, bActive)
				values		(@idUnit, @sUnit, @tiShifts, @iStamp, 1)

		if not exists	(select 1 from tbUnitMap where idUnit=@idUnit)
		begin
			insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
			insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
			insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
			insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
		end

		if not exists	(select 1 from tbUnitMapCell where idUnit=@idUnit)
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
	commit
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
--	v.7.01	* 'MAP ?' -> 'Map ?'
--	v.7.00	- tbUnit.bActive
--	v.6.05	+ populating tbUnit, tbUnitMap, tbUnitMapCell
--			+ tracing, transaction
--	v.5.01	encryption added
--	v.2.02
alter proc		dbo.prDefLoc_SetLvl
	with encryption
as
begin
	declare		@iTrace		int
	declare		@iCount		smallint
	declare		@s			varchar( 255 )
	declare		@idUnit		smallint
	declare		@sUnit		varchar( 16 )
	declare		@tiMap		tinyint
	declare		@tiCell		tinyint

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'S'
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'B'
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'F'
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'U'
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'C'
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		if	@iTrace & 0x01 > 0
		begin
			select	@s= 'Loc_SetLvl( ) ' + cast(@iCount as varchar) + ' rows'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		--	disable non-matching units
		update	u	set	u.bActive= 0, dtUpdated= getdate( )
			from	tbUnit u
				left outer join 	tbDefLoc l	on l.idLoc = u.idUnit
			where	u.bActive = 1	and	l.idLoc is null

		declare	cur		cursor fast_forward for
			select	idLoc, sLoc
				from	tbDefLoc
				where	tiLvl = 4
				order	by	1

		open	cur
		fetch next from	cur	into	@idUnit, @sUnit
		while	@@fetch_status = 0
		begin
			--	upsert tbUnit to match tbDefLoc
			if	not exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
--				insert	tbUnit	( idUnit,  sUnit, tiShifts, iStamp, bActive)
--					values		(@idUnit, @sUnit, 0, 0, 1)				-- # of shifts will be set in 7980
				insert	tbUnit	( idUnit,  sUnit, tiShifts, iStamp)
					values		(@idUnit, @sUnit, 0, 0)				-- # of shifts will be set in 7980
			else
				update	tbUnit	set	bActive= 1, sUnit= @sUnit, dtUpdated= getdate( )	--	, tiShifts= 0, iStamp= 0
					where	idUnit = @idUnit

			--	populate tbUnitMap
			if not exists	(select 1 from tbUnitMap where idUnit = @idUnit)
			begin
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
			end

			--	populate tbUnitMapCell
			if not exists	(select 1 from tbUnitMapCell where idUnit = @idUnit)
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
--	----------------------------------------------------------------------------
--	tbStaffAssn
--	v.7.02	- fkStaffAssn_Device, + fkStaffAssn_Room
if	exists	(select 1 from sys.all_objects where parent_object_id = OBJECT_ID('dbo.tbStaffAssn') and name = 'fkStaffAssn_Device')
begin
	begin tran
		alter table	dbo.tbStaffAssn		drop constraint fkStaffAssn_Device

		update	sa	set	sa.idRoom= r.idRoom				--	try fixing references from non-rooms to rooms by room-name match
			from	dbo.tbStaffAssn	sa
			inner join	dbo.tbDevice d	on	d.idDevice = sa.idRoom	and	d.cDevice <> 'R'
			inner join	dbo.tbDevice rd	on	rd.sDevice = d.sDevice	and	rd.cDevice = 'R'	and	rd.idDevice <> d.idDevice	and	rd.bActive > 0
			inner join	dbo.tbRoom	r	on	r.idRoom = rd.idDevice

		delete	sa										--	remove any leftovers so FK can be established
			from	dbo.tbStaffAssn	sa
			inner join	dbo.tbDevice d	on	d.idDevice = sa.idRoom	and	d.cDevice <> 'R'

		alter table	dbo.tbStaffAssn		add constraint	fkStaffAssn_Room	foreign key	(idRoom) references tbRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
--	v.7.02	* tbRoomStaff -> tbRoom
--	v.7.01	* updating assinged staff in tbRoomBed
--	v.7.00	+ updating assinged staff in tbRoomBed
--			+ pr_Module_Act call
--			tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--				prStaffAssn_InsFin -> prStaffCover_InsFin
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--			* set tbUnit.idShift
--	v.6.02
alter proc		dbo.prStaffCover_InsFin
	with encryption
as
begin
	declare		@dtNow			datetime
	declare		@tNow			time( 0 )
	declare		@idStaffAssn	int
	declare		@idStaffCover	int

	set	nocount	on

	select	@dtNow= getdate( ), @tNow= getdate( )

	create	table	#tbCurrAssn
	(
		idStaffAssn		int not null
			primary key clustered

	,	bFinish			bit not null
	)

	begin	tran

		exec	pr_Module_Act	1

		--	assignments that are currently running (@ tNow)
		insert	#tbCurrAssn	--(idStaffAssn, bFinish)
			select	idStaffAssn, 1
				from	tbStaffAssn		with (nolock)
				where	bActive > 0		and	idStaffCover > 0

		--	remember previous shift for each active unit
		update	tbUnit	set	idShPrv= idShift		--	no .dtUpdated, because this fires every minute!!
			where	bActive > 0						--	should we skip that (for performance?), or is it even better?

		--	set current shift for each active unit
		update	u	set	u.idShift= sh.idShift
				from	tbUnit u
					inner join	tbShift	sh	on	sh.idUnit = u.idUnit
				where	u.bActive > 0	and	sh.bActive > 0
					and	(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		--	assignments that should be running @ tNow (excluding ones that should end @ tNow)
		declare	cur		cursor fast_forward for
			select	sa.idStaffAssn, sa.idStaffCover
				from	tbStaffAssn	sa		with (nolock)
					inner join	tbShift	sh	with (nolock)	on	sh.idShift = sa.idShift
				where	sa.bActive > 0
					and	(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStaffAssn, @idStaffCover
		while	@@fetch_status = 0
		begin
			if	@idStaffCover is null
			begin
				--	begin coverage
				insert	tbStaffCover	(  idStaffAssn, dtBeg, dBeg, tBeg, tiBeg )
						values		( @idStaffAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ) )
				select	@idStaffCover=	scope_identity( )
				update	tbStaffAssn		set	idStaffCover= @idStaffCover, dtUpdated= @dtNow
					where	idStaffAssn= @idStaffAssn
			end
			--	remove assignments that should be running, resulting in ones that need to finish
			update	#tbCurrAssn		set	bFinish= 0
				where	idStaffAssn= @idStaffAssn

			fetch next from	cur	into	@idStaffAssn, @idStaffCover
		end
		close	cur
		deallocate	cur

		--	reset assigned staff in completed assignments
		update	rb	set	rb.idAsnRn= null, rb.idAsnCn= null, rb.idAsnAi= null, dtUpdated= @dtNow
			from	tbRoomBed	rb
			inner join	tbStaffAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
			inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sa.idStaffAssn		and	ca.bFinish = 1

		---	set assigned staff
		update	rb	set	idAsnRn= sa.idStaff
			from	tbRoomBed	rb
	--		inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbRoom		r	on	r.idRoom = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStaffAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 1	and	sa.bActive > 0
		update	rb	set	idAsnCn= sa.idStaff
			from	tbRoomBed	rb
	--		inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbRoom		r	on	r.idRoom = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStaffAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 2	and	sa.bActive > 0
		update	rb	set	idAsnAi= sa.idStaff
			from	tbRoomBed	rb
	--		inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbRoom		r	on	r.idRoom = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStaffAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 3	and	sa.bActive > 0

		--	finish coverage for completed assignments
		update	sc	set		dtEnd= @dtNow, dEnd= @dtNow, tEnd= @tNow, tiEnd= datepart( hh, @tNow )
			from	tbStaffCover	sc
			inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sc.idStaffAssn		and	ca.bFinish = 1

		--	reset coverage refs for completed assignments
		update	sa	set		idStaffCover= null, dtUpdated= @dtNow
			from	tbStaffAssn		sa
			inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sa.idStaffAssn		and	ca.bFinish = 1

	commit
end
go
--	----------------------------------------------------------------------------
--	tbRtlsBadge
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRtlsBadge') and name = 'idStaff')
begin
	begin tran
		alter table	dbo.tbRtlsBadge		drop constraint fkRtlsBadge_Staff
		alter table	dbo.tbRtlsBadge		drop column	idStaff
	commit
end
go
grant	alter							on dbo.tbRtlsBadge		to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge
--	v.7.02	* inserting into tbStaffDvc (requires 'alter' permission)
--	v.7.00	* idBadge: smallint -> int
--	v.6.03
alter proc		dbo.prRtlsBadge_InsUpd
(
	@idBadge		int					-- id
,	@idBadgeType	tinyint				-- type
)
	with encryption
as
begin
---	set	nocount	on
	begin	tran
		if exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
			update	dbo.tbRtlsBadge		set	idBadgeType= @idBadgeType, bActive= 1, dtUpdated= getdate( )
				where	idBadge = @idBadge
		else
		begin
			set identity_insert	dbo.tbStaffDvc	on
			insert	dbo.tbStaffDvc	( idStaffDvc, idStaffDvcType, sStaffDvc )
					values		( @idBadge, 1, 'Badge ' + right('0000' + cast(@idBadge as varchar), 5) )
			set identity_insert	dbo.tbStaffDvc	off

			insert	dbo.tbRtlsBadge	(  idBadge,  idBadgeType )
					values		( @idBadge, @idBadgeType )
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
--	v.7.02	- tbRtlsBadge.idStaff (no need now, tbStaffDvc.idStaff keeps relationship)
--	v.7.00	vwRtlsRcvr -> tbRtlsRcvr
--			.tiPtype -> .idStaffLvl
--	v.6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	v.6.04	* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	v.6.03
alter view		dbo.vwRtlsBadge
	with encryption
as
select	b.idBadge, b.idBadgeType, t.sBadgeType
	,	sd.idStaff, s.lStaffID, s.idStaffLvl, s.sStaffLvl, s.sStaff	---, s.sFull [tiPtype]
	,	b.idRoom, d.cDevice, d.sDevice, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, b.dtEntered
	,	b.idRcvrCurr, r.sReceiver [sRcvrCurr], b.dtRcvrCurr
	,	b.idRcvrLast, l.sReceiver [sRcvrLast], b.dtRcvrLast
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		inner join	tbRtlsBadgeType t	with (nolock)	on	t.idBadgeType = b.idBadgeType
		inner join	tbStaffDvc		sd	with (nolock)	on	sd.idStaffDvc = b.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idStaff =	sd.idStaff	-- b.idStaff
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = b.idRoom
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idRcvrCurr
		left outer join	tbRtlsRcvr	l	with (nolock)	on	l.idReceiver = b.idRcvrLast
go
--	----------------------------------------------------------------------------
--	tbRtlsRoom
--	v.7.02	- fkRtlsRoom_Device, + fkRtlsRoom_Room
if	exists	(select 1 from sys.all_objects where parent_object_id = OBJECT_ID('dbo.tbRtlsRoom') and name = 'fkRtlsRoom_Device')
begin
	begin tran
		alter table	dbo.tbRtlsRoom		drop constraint fkRtlsRoom_Device
		alter table	dbo.tbRtlsRoom		add constraint	fkRtlsRoom_Room		foreign key	(idRoom) references tbRoom
	commit
end
go
--			* .idBadge: not null -> null
if	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbRtlsRoom') and name='idBadge' and user_type_id=56 and is_nullable=0)
begin
	begin tran
		drop index	tbRtlsRoom.xuRtlsRoom
		alter table	dbo.tbRtlsRoom		alter column
			idBadge		int null					-- 1..65535
		create unique nonclustered index	xuRtlsRoom	on	dbo.tbRtlsRoom ( idBadge )	where	idBadge is not null
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge
--	v.7.02	* commented out tracing non-existing badges - too much output
--			* @idBadge: smallint -> int
--	v.7.00	.tiPtype -> .idStaffLvl
--	v.6.03
alter proc		dbo.prBadge_UpdLoc
(
	@idBadge		int					-- 1-65535 (unsigned)
,	@idRcvrCurr		smallint			-- current receiver look-up FK
,	@dtRcvrCurr		datetime			-- when registered by current rcvr
,	@idRcvrLast		smallint			-- last receiver look-up FK
,	@dtRcvrLast		datetime			-- when registered by last rcvr

,	@idRoomPrev		smallint out		-- previous 790 device look-up FK
,	@idRoomCurr		smallint out		-- current 790 device look-up FK
,	@dtEntered		datetime out		-- when entered the room
,	@idStaffLvl		tinyint out			-- 4=RN, 2=CNA, 1=Aide, ..
,	@cSys			char( 1 ) out		-- system
,	@tiGID			tinyint out			-- G-ID - gateway
,	@tiJID			tinyint out			-- J-ID - J-bus
,	@tiRID			tinyint out			-- R-ID - R-bus
)
	with encryption
as
begin
	declare		@iRetVal		smallint
	declare		@dtNow			datetime
	declare		@idReceiver		smallint
	declare		@idOldest		smallint
	declare		@s		varchar( 255 )

	set	nocount	on

	select	@dtNow= getdate( ), @idOldest= null		--, @tiPtype= null, @cSys= null, @tiGID= null, @tiJID= null, @tiRID= null

	if not exists( select 1 from tbRtlsBadge where idBadge = @idBadge )
	begin
--		select	@s=	'Bdg_Loc( B=' + isnull(cast(@idBadge as varchar),'?') +
--					' CR=' + isnull(cast(@idRcvrCurr as varchar),'?') + ' CD=' + isnull(convert(varchar, @dtRcvrCurr, 121),'?') +
--					' LR=' + isnull(cast(@idRcvrLast as varchar),'?') + ' LD=' + isnull(convert(varchar, @dtRcvrLast, 121),'?') + ' )'

--		exec	pr_Log_Ins	49, null, null, @s

		return	-1		--	?? badge does not exist !!
	end

	if	@idRcvrCurr = 0		select	@idRcvrCurr= null
	if	@idRcvrLast = 0		select	@idRcvrLast= null

	select	@idReceiver= idRcvrCurr, @idRoomPrev= idRoom, @dtEntered= dtEntered, @idRoomCurr= null
		,	@idStaffLvl= idStaffLvl, @cSys= cSys, @tiGID= tiGID, @tiJID= tiJID, @tiRID= tiRID		--	previous!!
		from	vwRtlsBadge		where	idBadge = @idBadge

---	select	@s=	@s + ' R=' + isnull(cast(@idReceiver as varchar),'?') + ' P=' + isnull(cast(@idRoomPrev as varchar),'?')
---	exec	pr_Log_Ins	0, null, null, @s

	if	@idReceiver = @idRcvrCurr	return	0		--	badge already at same location => skip

	select	@iRetVal= 1, @idRoomCurr= idDevice		--	new room
		from	tbRtlsRcvr		where	idReceiver = @idRcvrCurr

	begin	tran
		if	@idRoomPrev > 0  and  @idRoomCurr is null	or
			@idRoomCurr > 0  and  @idRoomPrev is null	or
			@idRoomCurr <> @idRoomPrev										--	badge moved [to another room]
		begin
			update	tbRtlsBadge		set	idRoom= @idRoomCurr, dtEntered= @dtNow, @dtEntered= @dtNow
				where	idBadge = @idBadge
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= null		--	remove badge from any room
				where	idBadge = @idBadge
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= @idBadge	--	set for current room [if first]
				where	idRoom = @idRoomCurr	and	idStaffLvl = @idStaffLvl	and	idBadge is null

			select	top 1	@idOldest= idBadge								--	get oldest badge of same type for prev room
				from	vwRtlsBadge
				where	idRoom = @idRoomPrev	and	idStaffLvl = @idStaffLvl	---	and	idBadge is not null		--	not necessary!
				order	by	dtEntered
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= null		--	remove that oldest from any room
				where	idBadge = @idOldest
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= @idOldest	--	set prev room to the oldest badge
				where	idRoom = @idRoomPrev	and	idStaffLvl = @idStaffLvl
			select	@iRetVal= 2, @cSys= null, @tiGID= null, @tiJID= null, @tiRID= null
			select	@cSys= cSys, @tiGID= tiGID, @tiJID= tiJID, @tiRID= tiRID
				from	tbDevice
				where	idDevice = @idRoomCurr
		end

		update	tbRtlsBadge		set	dtUpdated= @dtNow
			,	idRcvrCurr= @idRcvrCurr, dtRcvrCurr= @dtRcvrCurr, idRcvrLast= @idRcvrLast, dtRcvrLast= @dtRcvrLast
			where	idBadge = @idBadge
	commit

	return	@iRetVal
end
go
--	----------------------------------------------------------------------------
--	Rooms 'presense' state (oldest badges)
--	v.7.02	- tbRtlsBadge.idStaff (no need now, tbStaffDvc.idStaff keeps relationship)
--	v.7.00	.tiPtype -> .idStaffLvl
--	v.6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	v.6.04	+ .idRn, .idCna, .idAide	min vs. max?
--	v.6.03
alter view		dbo.vwRtlsRoom
	with encryption
as
select	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	min(case when r.idStaffLvl=4 then sd.idStaff	else null end)	[idRn]
	,	min(case when r.idStaffLvl=4 then s.sStaff		else null end)	[sRn]
	,	min(case when r.idStaffLvl=2 then sd.idStaff	else null end)	[idCn]
	,	min(case when r.idStaffLvl=2 then s.sStaff		else null end)	[sCn]
	,	min(case when r.idStaffLvl=1 then sd.idStaff	else null end)	[idAi]
	,	min(case when r.idStaffLvl=1 then s.sStaff		else null end)	[sAi]
	,	max(cast(r.bNotify as tinyint))							[tiNotify]
	,	min(r.dtUpdated)										[dtUpdated]
	from	tbRtlsRoom		r	with (nolock)
		inner join	tbDevice		d	with (nolock)	on	d.idDevice = r.idRoom
		left outer join	tbRtlsBadge	b	with (nolock)	on	b.idBadge = r.idBadge
		left outer join	tbStaffDvc	sd	with (nolock)	on	sd.idStaffDvc = b.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idStaff = sd.idStaff
	group by	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
--	v.7.02	* trace: 71 -> 75	+ tb_LogType: [75]
--			* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--			+ init tbRtlsRoom
--	v.7.01	* fix for rooms without beds
--	v.7.00	* prDevice_UpdRoomBeds7980: @tiBed -> @cBedIdx
--			+ set tbDefBed.bInUse
--			+ rooms without bed
--	v.6.05	+ init tbRoomStaff
--			+ (nolock)
--	v.6.04
alter proc		dbo.prDevice_UpdRoomBeds
(
	@idRoom		smallint					-- room id
,	@siBeds		smallint					-- beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
)
	with encryption
as
begin
	declare		@iTrace		int
			,	@s			varchar( 255 )
	declare		@sBeds		varchar( 10 )
			,	@cBed		char( 1 )
			,	@cBedIdx	char( 1 )
			,	@tiBed		tinyint
			,	@siMask		smallint
			,	@idUnit1	smallint
			,	@idUnit2	smallint
			,	@sRoom		varchar( 16 )
			,	@sDial		varchar( 16 )
	declare		@idDevice	smallint
			,	@tiPriCA0	tinyint				-- coverage area 0
			,	@tiPriCA1	tinyint				-- coverage area 1
			,	@tiPriCA2	tinyint				-- coverage area 2
			,	@tiPriCA3	tinyint				-- coverage area 3
			,	@tiPriCA4	tinyint				-- coverage area 4
			,	@tiPriCA5	tinyint				-- coverage area 5
			,	@tiPriCA6	tinyint				-- coverage area 6
			,	@tiPriCA7	tinyint				-- coverage area 7

	set	nocount	on

	if	exists	(select 1 from tbDevice with (nolock) where idDevice = @idRoom and cDevice='R')	--	only for rooms	// and 7967-P or tiStype=26
	begin

		select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

		select	@sBeds=	'', @tiBed= 1, @siMask= 1, @sRoom= sDevice, @sDial= sDial, @tiPriCA0= tiPriCA0, @tiPriCA1= tiAltCA0
			from	tbDevice	with (nolock)
			where	idDevice = @idRoom

		if	@tiPriCA0 = 0xFF			--	all CAs/Units
			select	top 1 @idUnit1= idUnit
				from	tbUnit		with (nolock)
				order	by	idUnit
		else							--	convert specific CA to its Unit
			select	@idUnit1= idParent
				from	tbDefLoc	with (nolock)
				where	idLoc = @tiPriCA0

		if	@tiPriCA1 = 0xFF			--	all CAs/Units
			select	top 1 @idUnit2= idUnit
				from	tbUnit		with (nolock)
				order	by	idUnit
		else							--	convert specific CA to its Unit
			select	@idUnit2= idParent
				from	tbDefLoc	with (nolock)
				where	idLoc = @tiPriCA1

		select	@s= 'Dvc_URB( ' + isnull(cast(@idRoom as varchar), '?') + ', r="' + isnull(@sRoom, '?') + '", d=' + isnull(@sDial, '?') +
					', u1=' + isnull(cast(@idUnit1 as varchar), '?') + ', u2=' + isnull(cast(@idUnit2 as varchar), '?') +
					', b=' + isnull(cast(@siBeds as varchar), '?') + ' )'

		if	@iTrace & 0x08 > 0
			exec	dbo.pr_Log_Ins	75, null, null, @s

		begin	tran

	---	delete	from	tbRoomBed				--	removes patient-to-bed assignments!
	---		where	idRoom = @idRoom

		if	not exists	(select 1 from tbRoom with (nolock) where idRoom = @idRoom)
			insert	tbRoom	( idRoom)			--	init staff placeholder for this room	v.7.02
					values	(@idRoom)

		delete	from	tbRtlsRoom				--	reinit staff presence placeholders		v.7.02
			where	idRoom = @idRoom
		insert	tbRtlsRoom	(idRoom, idStaffLvl, bNotify)
				select		@idRoom, idStaffLvl, 1
					from	tbStaffLvl	with (nolock)

		if	@siBeds = 0					--	no beds in this room
		begin
			exec	prDevice_UpdRoomBeds7980	0, @idRoom, null, @sRoom, @sDial, @idUnit1, @idUnit2
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF	---	remove combinations with beds

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
			begin
				insert	tbRoomBed	(  idRoom, cBed, tiBed )
						values		( @idRoom, null, 0xFF )
				exec	prDevice_UpdRoomBeds7980	1, @idRoom, ' ', @sRoom, @sDial, @idUnit1, @idUnit2
			end
		end
		else							--	there are beds
		begin

			exec	prDevice_UpdRoomBeds7980	0, @idRoom, ' ', @sRoom, @sDial, @idUnit1, @idUnit2
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF	---	remove combination with no beds

			while	@siMask < 1024
			begin
				select	@cBedIdx= cast(@tiBed as char(1))

				if	@siBeds & @siMask > 0		--	@tiBed is present in @idRoom
				begin
					update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed
					select	@cBed= cBed, @sBeds= @sBeds + cBed
						from	tbDefBed	with (nolock)
						where	idIdx = @tiBed

					if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = @tiBed)
					begin
						insert	tbRoomBed	(  idRoom,  cBed,  tiBed )
								values		( @idRoom, @cBed, @tiBed )
						exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnit1, @idUnit2
					end
				end
				else							--	@tiBed is absent in @idRoom
				begin
						exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnit1, @idUnit2
						delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = @tiBed
				end

				select	@siMask= @siMask * 2
					,	@tiBed=  case when @tiBed < 9 then @tiBed + 1 else 0 end
			end
		end

	--	update	tbDevice	set	siBeds= @siBeds, sBeds= @sBeds, dtUpdated= getdate( )
	--		where	idDevice = @idRoom
		update	tbRoom	set	siBeds= @siBeds, sBeds= @sBeds, dtUpdated= getdate( )
			where	idRoom = @idRoom

		--	loop through all active 7947 - 8-Input Bed Interfaces in that room and mark
		declare		cur		cursor fast_forward for
			select	idDevice, tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
				from	tbDevice	with (nolock)
				where	idParent = @idRoom	and	tiStype = 192	and	bActive > 0

		open	cur
		fetch next from	cur	into	@idDevice, @tiPriCA0, @tiPriCA1, @tiPriCA2, @tiPriCA3, @tiPriCA4, @tiPriCA5, @tiPriCA6, @tiPriCA7
		while	@@fetch_status = 0
		begin
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA0 & 0x0F	--	button 0's bed
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA1 & 0x0F	--	button 1's bed
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA2 & 0x0F	--	button 2's bed
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA3 & 0x0F	--	button 3's bed
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA4 & 0x0F	--	button 4's bed
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA5 & 0x0F	--	button 5's bed
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA6 & 0x0F	--	button 6's bed
			update	tbRoomBed	set	tiIbed=	0
				where	idRoom = @idRoom	and	tiBed = @tiPriCA7 & 0x0F	--	button 7's bed

			fetch next from	cur	into	@idDevice, @tiPriCA0, @tiPriCA1, @tiPriCA2, @tiPriCA3, @tiPriCA4, @tiPriCA5, @tiPriCA6, @tiPriCA7
		end
		close	cur
		deallocate	cur

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	v.7.02	tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	v.7.01	+ idStaffLvl to output (matching prRoomBed_GetByUnit)
--	v.7.00	ea.idRoom, ea.sRoom -> r.idDevice [idRoom], r.sDevice [sRoom]
--			utilize fnEventA_GetTopByRoom(..)
--			prMapCell_GetDataByUnitMap -> prMapCell_GetByUnitMap
--			utilize tbUnit.idShift
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.07	* output col-names
--	v.6.05
alter proc		dbo.prMapCell_GetByUnitMap
(
	@idUnit		smallint			-- unit FK
,	@tiMap		tinyint
)
	with encryption
as
begin
	select	mc.idUnit, u.sUnit,		mc.cSys, mc.tiGID, mc.tiJID, ea.tiRID, ea.tiBtn
		,	r.idDevice [idRoom], r.sDevice [sRoom], ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
		,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
		,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
		,	mc.tiMap, mc.tiCell, mc.sCell1, mc.sCell2, rr.siBeds, rr.sBeds	-- r.siBeds, r.sBeds
		from	tbUnitMapCell			mc	with (nolock)
			inner join	tbUnit			u	with (nolock)	on	u.idUnit = mc.idUnit
			left outer join	tbDevice	r	with (nolock)
				on	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0		and	r.bActive > 0
			left outer join	tbRoom		rr	with (nolock)	on	rr.idRoom = r.idDevice
			outer apply	fnEventA_GetTopByRoom( mc.cSys, mc.tiGID, mc.tiJID )	ea
			left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
			left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
			left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		where	mc.idUnit = @idUnit
			and	mc.tiMap = @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go
--	----------------------------------------------------------------------------
--	Report schedules
--	v.7.02
create table	dbo.tbSchedule
(
	idSchedule	smallint not null	identity( 1, 1 )	--	maybe int?
		constraint	xpSchedule	primary key clustered

,	tiRecur		tinyint not null		-- hi 3 bits: 32=Daily, 64=Weekly, 128=Monthly;  lo 5 bits: either 1..31 (D,W), or 1=1st, 2=2nd, 4=3rd, 8=4th, 16=Last
,	tiWkDay		tinyint null			-- 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
,	siMonth		smallint null			-- 1=Jan, 2=Feb, 4=Mar, 8=Apr, 16=May, 32=Jun, 64=Jul, 128=Aug, 256=Sep, 512=Oct, 1024=Nov, 2048=Dec
,	sSchedule	varchar( 255 ) not null	-- auto: spelled out schedule details
,	dtLastRun	smalldatetime null		-- when last execution started
,	dtNextRun	smalldatetime not null	-- when next execution should start, HH:mm part stores the "Run @" value
,	iResult		smallint not null		-- for last run: 0=Success, !0==Error code

,	idUser		smallint null			-- owner
		constraint	fkSchedule_User		foreign key references tb_User
,	idReport	smallint not null
		constraint	fkSchedule_Report	foreign key references tbReport
,	idFilter	smallint not null
		constraint	fkSchedule_Filter	foreign key references tbFilter
,	sSendTo		varchar( 255 ) null		-- list of recipient emails

,	bActive		bit not null				-- "deletion" marks inactive
		constraint	tdSchedule_Active	default( 1 )
,	dtCreated	smalldatetime not null		-- internal: record creation
		constraint	tdSchedule_Created	default( getdate( ) )
,	dtUpdated	smalldatetime not null		-- internal: last modified
		constraint	tdSchedule_Updated	default( getdate( ) )
)
--create unique nonclustered index	xuSchedule	on dbo.tbSchedule ( idUser, sSchedule )
		---	schedules should be unique per user
go
grant	select, update					on dbo.tbSchedule		to [rWriter]
grant	select, insert, update, delete	on dbo.tbSchedule		to [rReader]
go
--	----------------------------------------------------------------------------
--	v.7.02	tbEvent.tElapsed -> .tOrigin
--	v.6.05	+ (nolock), optimize
--	v.6.04	* optimize output to localize data manipulations to sproc
--			* optimize event selection range using tbEvent_S
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.00	.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiDvcs -> @tiDvc
--	v.5.02
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
			,	e.idCmd, k.sCmd, e.tiBtn	--, e.idRoom, e.sRoom, e.tiBed, b.cBed
			,	e.sRoom + case when e.tiBed is null then '' else ' : ' + b.cBed end [sRoomBed]
			,	e.idLogType, e.sLogType, e.idCall
			,	e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID, e.idSrcDvc	--, e.sSrcDvc, e.cSrcDvc, e.sSrcDial
			,	case when e.cSrcDvc is not null then '[' + e.cSrcDvc + '] ' else '' end +
					e.sSrcDvc +
					case when e.sSrcDial is not null then ' (' + e.sSrcDial + ')' else '' end [sQnSrcDvc]
			,	e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID, e.idDstDvc
			,	case when e41.idEvent > 0 then '[P] # (' + cast(e41.biPager as varchar) + ')' else 
					case when e.cDstDvc is not null then '[' + e.cDstDvc + '] ' else '' end +
					e.sDstDvc +
					case when e.sDstDial is not null then ' (' + e.sDstDial + ')' else '' end end [sQnDstDvc]
			,	case when e41.idEvent > 0 then '(' + convert(varchar, e41.siIdx) + ') ' + e41.cStatus + ' @ ' + convert(varchar, e41.dtAttempt, 108) else
					case when e.idCall is not null then e.sCall + ' (' + convert(varchar, coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)) + ')' end end [sCallTxt]
			,	e.sInfo
			,	case when e95.idEvent is null then null else
				rtrim(--case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'Stat ' else '' end +
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'RN ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'CNA ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Aide ' else '' end) end [sSvc]
			from				vwEvent		e	with (nolock)
				inner join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
				left outer join	tbDefBed	b	with (nolock)	on	b.idIdx = e.tiBed
				left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
				left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
				left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
				left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				left outer join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
				left outer join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
	---		where	e.dEvent	between @dFrom	and @dUpto
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else if	@tiDvc = 1
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent, e.tiHH
			,	e.idCmd, k.sCmd, e.tiBtn	--, e.idRoom, e.sRoom, e.tiBed, b.cBed
			,	e.sRoom + case when e.tiBed is null then '' else ' : ' + b.cBed end [sRoomBed]
			,	e.idLogType, e.sLogType, e.idCall
			,	e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID, e.idSrcDvc	--, e.sSrcDvc, e.cSrcDvc, e.sSrcDial
			,	case when e.cSrcDvc is not null then '[' + e.cSrcDvc + '] ' else '' end +
					e.sSrcDvc +
					case when e.sSrcDial is not null then ' (' + e.sSrcDial + ')' else '' end [sQnSrcDvc]
			,	e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID, e.idDstDvc
			,	case when e41.idEvent > 0 then '[P] # (' + cast(e41.biPager as varchar) + ')' else 
					case when e.cDstDvc is not null then '[' + e.cDstDvc + '] ' else '' end +
					e.sDstDvc +
					case when e.sDstDial is not null then ' (' + e.sDstDial + ')' else '' end end [sQnDstDvc]
			,	case when e41.idEvent > 0 then '(' + convert(varchar, e41.siIdx) + ') ' + e41.cStatus + ' @ ' + convert(varchar, e41.dtAttempt, 108) else
					case when e.idCall is not null then e.sCall + ' (' + convert(varchar, coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)) + ')' end end [sCallTxt]
			,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew) 'siIdx'		--, e41.siIdx
			,	case when e95.idEvent is null then null else
				rtrim(--case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'Stat ' else '' end +
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'RN ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'CNA ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Aide ' else '' end) end sSvc
			from				vwEvent		e	with (nolock)
				inner join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
				inner join		tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
				left outer join	tbDefBed	b	with (nolock)	on	b.idIdx = e.tiBed
				left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
				left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
				left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
				left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				left outer join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
				left outer join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
	---		where	e.dEvent	between @dFrom	and @dUpto
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent, e.tiHH
			,	e.idCmd, k.sCmd, e.tiBtn	--, e.idRoom, e.sRoom, e.tiBed, b.cBed
			,	e.sRoom + case when e.tiBed is null then '' else ' : ' + b.cBed end [sRoomBed]
			,	e.idLogType, e.sLogType, e.idCall
			,	e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID, e.idSrcDvc	--, e.sSrcDvc, e.cSrcDvc, e.sSrcDial
			,	case when e.cSrcDvc is not null then '[' + e.cSrcDvc + '] ' else '' end +
					e.sSrcDvc +
					case when e.sSrcDial is not null then ' (' + e.sSrcDial + ')' else '' end [sQnSrcDvc]
			,	e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID, e.idDstDvc
			,	case when e41.idEvent > 0 then '[P] # (' + cast(e41.biPager as varchar) + ')' else 
					case when e.cDstDvc is not null then '[' + e.cDstDvc + '] ' else '' end +
					e.sDstDvc +
					case when e.sDstDial is not null then ' (' + e.sDstDial + ')' else '' end end [sQnDstDvc]
			,	case when e41.idEvent > 0 then '(' + convert(varchar, e41.siIdx) + ') ' + e41.cStatus + ' @ ' + convert(varchar, e41.dtAttempt, 108) else
					case when e.idCall is not null then e.sCall + ' (' + convert(varchar, coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)) + ')' end end [sCallTxt]
			,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew) 'siIdx'		--, e41.siIdx
			,	case when e95.idEvent is null then null else
				rtrim(--case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'Stat ' else '' end +
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'RN ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'CNA ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Aide ' else '' end) end sSvc
			from				vwEvent		e	with (nolock)
				inner join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
				left outer join	tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
				left outer join	tbDefBed	b	with (nolock)	on	b.idIdx = e.tiBed
				left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
				left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
				left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
				left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				left outer join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
				left outer join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
	---		where	e.dEvent	between @dFrom	and @dUpto
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
				and	(e.idSrcDvc in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcDvc is null)
			order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
--	v.7.02	tbEvent_C.idCna -> .idCn, .idAide -> .idAi, .tCna -> .tCn, .tAide -> .tAi
--	v.6.05	+ (nolock), optimize
--	v.6.04	* optimize event selection range using tbEvent_S
--	v.6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiLocs -> @tiDvc
--	v.5.02
alter proc		dbo.prRptCallStatSum
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tbRptSessDvc), 0=<invalid>
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
		select	t.*	--, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg
			,	case when t.tVoAvg is null then null else t.lVoOnT*100/(t.lCount-t.lVoNul) end fVoOnT
			,	case when t.tStAvg is null then null else t.lStOnT*100/(t.lCount-t.lStNul) end fStOnT
		--	,	f.tVoMax, f.tStMax, t.lVoOut*100/t.lCount fVoOut, t.lStOut*100/t.lCount fStOut
			from
				(select	c.idCall, count(*) lCount
					,	min(f.siIdx) siIdx, min(f.sCall) sCall, min(f.tVoTrg) tVoTrg, min(f.tStTrg) tStTrg
					,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) ) tVoAvg
	--				,	cast(dateadd(ss, avg( datepart(mi,c.tVoice)*60+datepart(ss,c.tVoice)+1 ), '0:0:0') as time(0)) tVoAvg
					,	max(c.tVoice) tVoMax
					,	sum(case when c.tVoice < f.tVoTrg then 1 else 0 end) lVoOnT
		--			,	sum(case when c.tVoice > f.tVoMax then 1 else 0 end) lVoOut
					,	sum(case when c.tVoice is null then 1 else 0 end) lVoNul
					,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) ) tStAvg
	--				,	cast(dateadd(ss, avg( datepart(mi,c.tStaff)*60+datepart(ss,c.tStaff)+1 ), '0:0:0') as time(0)) tStAvg
					,	max(c.tStaff) tStMax
					,	sum(case when c.tStaff < f.tStTrg then 1 else 0 end) lStOnT
		--			,	sum(case when c.tStaff > f.tStMax then 1 else 0 end) lStOut
					,	sum(case when c.tStaff is null then 1 else 0 end) lStNul
					,	cast( cast( avg( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) ) tAvgRn
					,	cast( cast( avg( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) ) tAvgCn
					,	cast( cast( avg( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) ) tAvgAi
					,	cast( cast( sum( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) ) tTotRn
					,	cast( cast( sum( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) ) tTotCn
					,	cast( cast( sum( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) ) tTotAi
					,	sum(case when c.tRn is not null then 1 else 0 end) lCntRn
					,	sum(case when c.tCn is not null then 1 else 0 end) lCntCn
					,	sum(case when c.tAi is not null then 1 else 0 end) lCntAi
				from			tbEvent_C	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
		---		where	c.dEvent	between @dFrom	and @dUpto
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				group	by c.idCall--, sCall
				)	t
		--		inner join	tb_SessCall f	on	f.idCall = t.idCall	and	f.idSess = @idSess
			order by	t.siIdx desc		--lCount desc
	else
		select	t.*	--, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg
			,	case when t.tVoAvg is null then null else t.lVoOnT*100/(t.lCount-t.lVoNul) end fVoOnT
			,	case when t.tStAvg is null then null else t.lStOnT*100/(t.lCount-t.lStNul) end fStOnT
		--	,	f.tVoMax, f.tStMax, t.lVoOut*100/t.lCount fVoOut, t.lStOut*100/t.lCount fStOut
			from
				(select	c.idCall, count(*) lCount
					,	min(f.siIdx) siIdx, min(f.sCall) sCall, min(f.tVoTrg) tVoTrg, min(f.tStTrg) tStTrg
					,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) ) tVoAvg
					,	max(c.tVoice) tVoMax
					,	sum(case when c.tVoice < f.tVoTrg then 1 else 0 end) lVoOnT
		--			,	sum(case when c.tVoice > f.tVoMax then 1 else 0 end) lVoOut
					,	sum(case when c.tVoice is null then 1 else 0 end) lVoNul
					,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) ) tStAvg
					,	max(c.tStaff) tStMax
					,	sum(case when c.tStaff < f.tStTrg then 1 else 0 end) lStOnT
		--			,	sum(case when c.tStaff > f.tStMax then 1 else 0 end) lStOut
					,	sum(case when c.tStaff is null then 1 else 0 end) lStNul
					,	cast( cast( avg( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) ) tAvgRn
					,	cast( cast( avg( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) ) tAvgCn
					,	cast( cast( avg( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) ) tAvgAi
					,	cast( cast( sum( cast( cast(c.tRn as datetime) as float) ) as datetime) as time(3) ) tTotRn
					,	cast( cast( sum( cast( cast(c.tCn as datetime) as float) ) as datetime) as time(3) ) tTotCn
					,	cast( cast( sum( cast( cast(c.tAi as datetime) as float) ) as datetime) as time(3) ) tTotAi
					,	sum(case when c.tRn is not null then 1 else 0 end) lCntRn
					,	sum(case when c.tCn is not null then 1 else 0 end) lCntCn
					,	sum(case when c.tAi is not null then 1 else 0 end) lCntAi
				from			tbEvent_C	c	with (nolock)
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
		---		where	c.dEvent	between @dFrom	and @dUpto
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				group	by c.idCall--, sCall
				)	t
		--		inner join	tb_SessCall f	on	f.idCall = t.idCall	and	f.idSess = @idSess
			order by	t.siIdx desc		--lCount desc
end
go
--	----------------------------------------------------------------------------
--	v.7.02	tbEvent_C.idCna -> .idCn, .idAide -> .idAi, .tCna -> .tCn, .tAide -> .tAi
--	v.6.05	+ (nolock), optimize
--	v.6.04	* optimize event selection range using tbEvent_S
--	v.6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiLocs -> @tiDvc
--	v.5.01
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
		if	@cBed is null
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall,
					c.tVoice, c.tStaff, c.tRn, c.tCn, c.tAi
				from			vwEvent_T	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
		---		where	c.dEvent	between @dFrom	and @dUpto
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				order	by	c.sDevice, c.idEvent
		else
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall,
					c.tVoice, c.tStaff, c.tRn, c.tCn, c.tAi
				from			vwEvent_T	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
		---		where	c.dEvent	between @dFrom	and @dUpto
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
					and	(c.cBed = @cBed	or	c.cBed is null)
				order	by	c.sDevice, c.idEvent
	else
		if	@cBed is null
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall,
					c.tVoice, c.tStaff, c.tRn, c.tCn, c.tAi
				from			vwEvent_T	c	with (nolock)
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
		---		where	c.dEvent	between @dFrom	and @dUpto
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				order	by	c.sDevice, c.idEvent
		else
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall,
					c.tVoice, c.tStaff, c.tRn, c.tCn, c.tAi
				from			vwEvent_T	c	with (nolock)
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
		---		where	c.dEvent	between @dFrom	and @dUpto
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
					and	(c.cBed = @cBed	or	c.cBed is null)
				order	by	c.sDevice, c.idEvent
end
go
--	----------------------------------------------------------------------------
--	v.7.02	tbEvent.tElapsed -> .tOrigin
--	v.6.05	+ (nolock), optimize
--	v.6.04	* optimize event selection range using tbEvent_S
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			tbDefType -> tbEvType (fkEvent_DefType -> fkEvent_EvType)
--			@tiLocs -> @tiDvc
--	v.5.02
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
		if	@cBed is null
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin,
					e.idEvent, e.dEvent, e.tEvent, e.tOrigin, e.idCall,
					case when e41.idEvent > 0 then e.sInfo else c.sCall end [sCall],
					s.cBed, e.tiBed, e.idLogType, t.sLogType,
					case when e41.idEvent > 0 then 'P: ' + cast(e41.biPager as varchar)
					when e95.idEvent > 0 then
					rtrim(case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'Stat ' else '' end +
						case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'RN ' else '' end +
						case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'CNA ' else '' end +
						case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Aide ' else '' end)
					when e8A.idEvent > 0 then e.cSrcDvc + ': ' + e.sSrcDvc
					else null end [sSvc],
			--		case when e41.idEvent > 0 then e41.cStatus + ' @ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					case when e41.idEvent > 0 then '@ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from			vwEvent_T	t	with (nolock)
							inner join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
				---		where	t.dEvent	between @dFrom	and @dUpto
						where	t.idEvent	between @idFrom	and @idUpto
							and	t.tiHH		between @tFrom	and @tUpto
					)	s
			--		inner join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left outer join	tbDefCall	c	with (nolock)	on	c.idCall = e.idCall
					left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left outer join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
		else
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin,
					e.idEvent, e.dEvent, e.tEvent, e.tOrigin, e.idCall,
					case when e41.idEvent > 0 then e.sInfo else c.sCall end [sCall],
					s.cBed, e.tiBed, e.idLogType, t.sLogType,
					case when e41.idEvent > 0 then 'P: ' + cast(e41.biPager as varchar)
					when e95.idEvent > 0 then
					rtrim(case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'Stat ' else '' end +
						case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'RN ' else '' end +
						case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'CNA ' else '' end +
						case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Aide ' else '' end)
					when e8A.idEvent > 0 then e.cSrcDvc + ': ' + e.sSrcDvc
					else null end [sSvc],
			--		case when e41.idEvent > 0 then e41.cStatus + ' @ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					case when e41.idEvent > 0 then '@ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from			vwEvent_T	t	with (nolock)
							inner join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
				---		where	t.dEvent	between @dFrom	and @dUpto
						where	t.idEvent	between @idFrom	and @idUpto
							and	t.tiHH		between @tFrom	and @tUpto
							and	(t.cBed = @cBed	or	t.cBed is null)
					) s
			--		inner join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left outer join	tbDefCall	c	with (nolock)	on	c.idCall = e.idCall
					left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left outer join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
	else
		if	@cBed is null
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin,
					e.idEvent, e.dEvent, e.tEvent, e.tOrigin, e.idCall,
					case when e41.idEvent > 0 then e.sInfo else c.sCall end [sCall],
					s.cBed, e.tiBed, e.idLogType, t.sLogType,
					case when e41.idEvent > 0 then 'P: ' + cast(e41.biPager as varchar)
					when e95.idEvent > 0 then
					rtrim(case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'Stat ' else '' end +
						case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'RN ' else '' end +
						case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'CNA ' else '' end +
						case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Aide ' else '' end)
					when e8A.idEvent > 0 then e.cSrcDvc + ': ' + e.sSrcDvc
					else null end [sSvc],
			--		case when e41.idEvent > 0 then e41.cStatus + ' @ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					case when e41.idEvent > 0 then '@ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from			vwEvent_T	t	with (nolock)
							inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = t.idRoom
							inner join	tb_SessCall f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
				---		where	t.dEvent	between @dFrom	and @dUpto
						where	t.idEvent	between @idFrom	and @idUpto
							and	t.tiHH		between @tFrom	and @tUpto
					) s
			--		inner join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left outer join	tbDefCall	c	with (nolock)	on	c.idCall = e.idCall
					left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left outer join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
		else
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin,
					e.idEvent, e.dEvent, e.tEvent, e.tOrigin, e.idCall,
					case when e41.idEvent > 0 then e.sInfo else c.sCall end [sCall],
					s.cBed, e.tiBed, e.idLogType, t.sLogType,
					case when e41.idEvent > 0 then 'P: ' + cast(e41.biPager as varchar)
					when e95.idEvent > 0 then
					rtrim(case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'Stat ' else '' end +
						case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'RN ' else '' end +
						case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'CNA ' else '' end +
						case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Aide ' else '' end)
					when e8A.idEvent > 0 then e.cSrcDvc + ': ' + e.sSrcDvc
					else null end [sSvc],
			--		case when e41.idEvent > 0 then e41.cStatus + ' @ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					case when e41.idEvent > 0 then '@ ' + convert(varchar, e41.dtAttempt, 108) else e.sInfo end [sInfo],
					d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from			vwEvent_T	t	with (nolock)
							inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = t.idRoom
							inner join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
				---		where	t.dEvent	between @dFrom	and @dUpto
						where	t.idEvent	between @idFrom	and @idUpto
							and	t.tiHH		between @tFrom	and @tUpto
							and	(t.cBed = @cBed	or	t.cBed is null)
					) s
			--		inner join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					inner join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left outer join	tbDefCall	c	with (nolock)	on	c.idCall = e.idCall
					left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left outer join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
end
go


if	exists	( select 1 from tb_Version where idVersion = 702 )
	update	dbo.tb_Version	set	dtCreated= '2013-02-24', siBuild= 4882, dtInstall= getdate( )
		,	sVersion= '7.02.4803 +4882 - RTLS presense fix, schema refactored, scheduled reports'
		where	idVersion = 702
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 702,	4882, '2013-02-24', getdate( ),	'7.02.4803 +4882 - RTLS presense fix, schema refactored, scheduled reports' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.2.4882'
	where	idModule = 1
go

checkpoint
go

use [master]
go
