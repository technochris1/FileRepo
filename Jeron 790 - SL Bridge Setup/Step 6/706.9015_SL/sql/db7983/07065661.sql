--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2015-Apr-20		.5588
--						* prDevice_GetIns
--						* vwRtlsRoom
--		2015-Apr-27		.5595
--						* pr_Module_Reg
--		2015-Apr-28		.5596
--						* tb_LogType[44,46,48]
--						* pr_OptSys_Upd, pr_OptUsr_Upd
--		2015-Apr-30		.5598
--						+ tb_LogType[63]
--		2015-May-08		.5606
--						* tbRouting.tiRouting value update
--		2015-May-12		.5610
--						[db7970] only:
--						+ tbTlkMsg.iRepeatCancel
--						* tbTlkRooms.idRoom:	smallint -> int
--		2015-May-13		.5611
--						* pr_Log_Get
--		2015-May-15		.5613
--						* prCfgDvc_GetAll
--						* prEvent_SetGwState
--						* tb_LogType[82].tiLvl:	8 -> 16
--						* prEvent84_Ins
--		2015-May-18		.5616
--						* prSchedule_Get, prSchedule_GetToRun
--		2015-May-19		.5617
--						* pr_Module_GetAll
--						* pr_Module_Reg
--		2015-May-20		.5618
--						* tb_OptSys[7] default: 0 -> 30, semantics reversed
--						* prEvent_A_Exp, prEvent_Maint
--		2015-May-26		.5624
--						* prRoom_GetByUnit, prDevice_GetByUnit
--		2015-Jun-03		.5632
--						* pr_Module_Upd
--		2015-Jun-04		.5633
--						* prDevice_GetIns
--		2015-Jun-09		.5638
--						* prEvent_Maint
--		2015-Jun-12		.5641
--						* prCall_GetIns
--		2015-Jun-18		.5647
--						* prEvent84_Ins
--		2015-Jun-19		.5648
--						* prEvent_Maint
--		2015-Jun-22		.5651
--						* [90].tiLvl:	2 -> 4
--		2015-Jun-23		.5652
--						* [62].tiLvl:	4 -> 8
--		2015-Jun-30		.5659
--						* prSchedule_Get, prSchedule_GetToRun
--		2015-Jul-02		.5661
--						* tb_Feature[*]
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

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 5661 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.5661', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Lic')
	drop proc	dbo.pr_Module_Lic
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit

	set	nocount	on

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0													-- empty device

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
--	Rooms 'presence' state (oldest badges)
--	7.06.5588	+ 'and	d.bActive > 0' - return only active rooms
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
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
	,	min(case when r.idStfLvl = 4	then sd.idUser	else null end)	as	idUserG
	,	min(case when r.idStfLvl = 4	then s.sStaff	else null end)	as	sStaffG
	,	min(case when r.idStfLvl = 2	then sd.idUser	else null end)	as	idUserO
	,	min(case when r.idStfLvl = 2	then s.sStaff	else null end)	as	sStaffO
	,	min(case when r.idStfLvl = 1	then sd.idUser	else null end)	as	idUserY
	,	min(case when r.idStfLvl = 1	then s.sStaff	else null end)	as	sStaffY
	,	max(cast(r.bNotify as tinyint))									as	tiNotify
	,	min(r.dtUpdated)												as	dtUpdated
	from	tbRtlsRoom		r	with (nolock)
	join	tbDevice		d	with (nolock)	on	d.idDevice = r.idRoom	and	d.bActive > 0
	left join	tbRtlsBadge	b	with (nolock)	on	b.idBadge = r.idBadge
	left join	tbDvc		sd	with (nolock)	on	sd.idDvc = b.idBadge
	left join	vwStaff		s	with (nolock)	on	s.idUser = sd.idUser
	group by	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
go
--	----------------------------------------------------------------------------
--	7.06.5596	* [44,46,48]
begin tran
	update	dbo.tb_LogType	set	sLogType= 'HL7 data import'		where	idLogType = 44
	update	dbo.tb_LogType	set	sLogType= '7980 data import'	where	idLogType = 46
	update	dbo.tb_LogType	set	sLogType= 'RTLS data import'	where	idLogType = 48
commit
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
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

	select	@k= o.tiDatatype, @i= os.iValue, @f= os.fValue, @t= os.tValue, @s= os.sValue
		from	tb_OptSys	os	with (nolock)
		join	tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin

		begin	tran
			update	tb_OptSys	set	iValue= @iValue, fValue= @fValue, tValue= @tValue, sValue= @sValue, dtUpdated= getdate( )
				where	idOption = @idOption	--	and	idUser = @idUser

			if	@idOption = 16	select	@sValue= '************'		--	do not expose SMTP pass

			select	@s= 'OptSys_U [' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s=	@s + ', i=' + isnull(cast(@iValue as varchar), '?') + ' (' + sys.fn_varbintohexstr(@iValue) + ')'
			else if	@k = 62		select	@s=	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s=	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s=	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	236, @idUser, null, @s
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Updates and logs user setting
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

	select	@k= o.tiDatatype, @i= os.iValue, @f= os.fValue, @t= os.tValue, @s= os.sValue
		from	tb_OptSys	os	with (nolock)
		inner join	tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin

		begin	tran
			update	tb_OptUsr	set	iValue= @iValue, fValue= @fValue, tValue= @tValue, sValue= @sValue, dtUpdated= getdate( )
				where	idOption = @idOption	and	idUser = @idUser

	--		if	@idOption = 16	select	@sValue= '************'		--	do not expose SMTP pass

			select	@s= 'OptUsr_U [' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s=	@s + ', i=' + isnull(cast(@iValue as varchar), '?') + ' (' + sys.fn_varbintohexstr(@iValue) + ')'
			else if	@k = 62		select	@s=	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s=	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s=	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	231, @idUser, null, @s
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.5598	+ [63]
if	not exists	(select 1 from dbo.tb_LogType where idLogType = 63)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 63,  4, 1, 'Component License' )		--	7.06.5598

		update	dbo.tb_Module	set	bLicense =	0		-- reset all licenses, so we have a record now
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates given module's license bit
--	7.06.5598
create proc		dbo.pr_Module_Lic
(
	@idModule	tinyint
,	@bLicense	bit
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@s= 'Mod_Lic( ' + right('00' + cast(@idModule as varchar), 3) + ', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'

	begin	tran

		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule and bLicense <> @bLicense)
		begin
			update	tb_Module	set	bLicense =	@bLicense
				where	idModule = @idModule

			exec	dbo.pr_Log_Ins	63, null, null, @s
		end

	commit
end
go
grant	execute				on dbo.pr_Module_Lic				to [rWriter]
grant	execute				on dbo.pr_Module_Lic				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5606	
begin tran
	update	dbo.tbRouting	set	tiRouting= 1		where	tiRouting > 3
commit
go
--	----------------------------------------------------------------------------
--	7.06.5610	+ .iRepeatCancel
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbTlkMsg') and name = 'iRepeatCancel')
	and exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkMsg')
begin
	begin tran

		exec( '
		alter table	dbo.tbTlkMsg	add
			iRepeatCancel	tinyint		null	-- Repeat announcement on cancel count
			' )

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5610	* .idRoom:	smallint -> int
--					(6892 support - more than 100 room/console controllers per gateway)
if		exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbTlkRooms') and name='idRoom' and user_type_id=52)	--	smallint
	and exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkRooms')
begin
	begin tran

		exec( '
		alter table	dbo.tbTlkRooms	drop
			constraint	pkTlkRooms

		alter table	dbo.tbTlkRooms	alter column
			idRoom		int not null

		alter table dbo.tbTlkRooms	add
			iNewIdx		int null
			' )

		exec( '
		update	dbo.tbTlkRooms	set	iNewIdx =	((floor(idRoom / 100) * 10000) + (idRoom % 100))
			where	idRoom	in	(select idRoom from dbo.tbTlkRooms)

		update	dbo.tbTlkRooms	set	idRoom = iNewIdx
			where	iNewIdx	in	(select iNewIdx from dbo.tbTlkRooms)

		alter table	dbo.tbTlkRooms	drop
			column	iNewIdx

		alter table	dbo.tbTlkRooms	add
			constraint pkTlkRooms	primary key clustered (idRoom)
			' )

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns log entries in a page of given size
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
,	@tiSrc		tinyint				-- bitwise tb_LogType.tiSrc, 0xFF=include all
,	@iPages		int				out	-- total # of pages
)
	with encryption
as
begin
	declare		@idLog		int

	set	nocount	on

	select	@iIndex =	@iIndex * @iCount + 1		-- index of the 1st output row

	if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no filtering
	begin
		select	@iPages =	ceiling( count(*) / @iCount )
			from	tb_Log	with (nolock)

		set	rowcount	@iIndex
		select	@idLog =	idLog
			from	tb_Log	with (nolock)
			order	by	idLog desc
	end
	else
	begin
		select	@iPages =	ceiling( count(*) / @iCount )
			from	tb_Log l	with (nolock)
			join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			where	t.tiLvl & @tiLvl > 0
			and		t.tiSrc & @tiSrc > 0

		set	rowcount	@iIndex
		select	@idLog =	idLog
			from	tb_Log l	with (nolock)
			join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			where	t.tiLvl & @tiLvl > 0
			and		t.tiSrc & @tiSrc > 0
			order	by	idLog desc
	end

	set	rowcount	@iCount
	set	nocount	off
	if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no filtering
		select	l.idLog, l.dtLog, l.idLogType, t.sLogType, u.sUser, o.sUser [sOper], l.sLog, t.tiLvl, t.tiSrc
			from	tb_Log l	with (nolock)
			join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			left join	tb_User u	with (nolock)	on	u.idUser = l.idUser
			left join	tb_User o	with (nolock)	on	o.idUser = l.idOper
			where	idLog <= @idLog
			order	by 1 desc
	else
		select	l.idLog, l.dtLog, l.idLogType, t.sLogType, u.sUser, o.sUser [sOper], l.sLog, t.tiLvl, t.tiSrc
			from	tb_Log l	with (nolock)
			join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			left join	tb_User u	with (nolock)	on	u.idUser = l.idUser
			left join	tb_User o	with (nolock)	on	o.idUser = l.idOper
			where	idLog <= @idLog
			and		t.tiLvl & @tiLvl > 0
			and		t.tiSrc & @tiSrc > 0
			order	by 1 desc

	set	rowcount	0
end
go
--	----------------------------------------------------------------------------
--	Returns 790 devices, filtered according to args
--	7.06.5613	* 680 station types recognition
--	7.06.5414
alter proc		dbo.prCfgDvc_GetAll
(
--	@idUser		int			= null	-- null=any
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@tiKind		tinyint		= 0xFF	-- 01=G, 02=R, 04=M|W, 08=Z, 10=*, 20=?
)
	with encryption
as
begin
--	set	nocount	on
	select	idDevice, idParent, tiJID, tiRID, sSGJR, iAID, tiStype, cDevice
		,	case when	sBeds is null	then sDevice	else	sDevice + ' : ' + sBeds	end		as	sDevice
		,	case when	len(sUnits) > 31	then substring(sUnits,1,24) + '..(' + cast((len(sUnits)+1)/4 as varchar) + ' units)'	else sUnits	end		as	sUnits
		,	sDial, sCodeVer, idUnit, bActive, dtCreated, dtUpdated
		from	vwDevice	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@tiKind & 0x01 <> 0	and	tiStype	< 4					--	G-way
			or	@tiKind & 0x02 <> 0		and	(tiStype between 4 and 7	or	tiStype = 124	or	tiStype = 126)	--	Room | 680-BusSt | 680-Main
			or	@tiKind & 0x04 <> 0		and	(tiStype between 8 and 11	or	tiStype = 24	or	tiStype = 26	or	tiStype = 125)	--	Master | Workflow | 680-Master
			or	@tiKind & 0x08 <> 0		and	tiStype between 13 and 15	--	Zone
			or	@tiKind & 0x10 <> 0)									--	Other
--		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
--					from	tb_RoleUnit	ru	with (nolock)
--					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	sSGJR
end
go
--	----------------------------------------------------------------------------
--	Marks a gateway as found or lost (and removes its active calls)
--	7.06.5613	* fix for non-existing device
--				+ @sDevice
--	7.05.5205	* prEvent_Ins args
--	7.04.4960	* activate a GW if necessary
--	6.07	+ isnull(sDevice,'?')
--	6.05
alter proc		dbo.prEvent_SetGwState
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@sDevice	varchar( 16 )		-- room name
,	@idLogType	tinyint				-- 189=Found, 190=Lost
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idEvent	int
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		select	@s =	@cSys + '-' + right('00' + cast(@tiGID as varchar), 3) + ' [' + isnull(@sDevice,'?') + ']'
--		select	@s=	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + ' [' + isnull(@sDevice,'?') + ']'
--			from	tbDevice	with (nolock)
--			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	bActive > 0

		if	@idLogType = 189
			update	tbDevice	set	bActive= 1
				where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	bActive = 0
		else
	--	if	@idLogType = 190
		begin
			delete	from	tbEvent_A
				where	cSys = @cSys	and	tiGID = @tiGID

			select	@s =	@s + ', ' + cast(@@rowcount as varchar) + ' active call(s) cleared'
		end

		exec	dbo.prEvent_Ins		0x83, 0, 0, null		---	@idCmd, @tiLen, @iHash, @vbCmd,
				,	@cSys, @tiGID, 0, 0, @sDevice			--- @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
				,	null, null, null, null, null, null		---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType								---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5652	* [62].tiLvl:	4 -> 8
--	7.06.5651	* [90].tiLvl:	2 -> 4
--	7.06.5613	* [82].tiLvl:	8 -> 16
begin
	begin tran
		update	dbo.tb_LogType	set	tiLvl=	16	where	idLogType = 82	--	'Invalid data'		--	7.05.4980, 7.05.5147, 7.06.5613
		update	dbo.tb_LogType	set	tiLvl=	4	where	idLogType = 90	--	'Exec Schedule'		--	7.03, 7.06.5651
		update	dbo.tb_LogType	set	tiLvl=	8	where	idLogType = 62	--	'Component Removed'	--	7.00, 7.05.5045, 7.06.5652
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
		select	@bPresence =	1,		@tiBed =	0xFF	-- mark 'presence' calls and force room-level


	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + '  bed'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed


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
			if	@idRoom > 0		and	@idUnit > 0				-- record every call in tbEvent_C	--	7.06.5562, 7.06.5613
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
--	Returns an existing schedule
--	7.06.5616	* standardize output with prSchedule_GetToRun
--	7.03
alter proc		dbo.prSchedule_Get
(
	@idSchedule	smallint out
)
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult
		,	s.idUser as idOwner, u.sUser as sOwner
		,	s.idReport,		s.idFilter, null as idUser, null as sFilter, null as xFilter	-- f.sFilter, f.xFilter, f.idUser
		,	s.sSendTo, s.bActive, s.dtCreated, s.dtUpdated
		from	tbSchedule	s	with (nolock)
--		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User	u	with (nolock)	on	u.idUser = s.idUser
		where	idSchedule = @idSchedule
end
go
--	----------------------------------------------------------------------------
--	Returns a list of active schedules, due for execution right now
--	7.06.5616	* standardize output with prSchedule_Get
--	7.05.4980	* u.sFirst + ' ' + u.sLast -> u.sStaff
--	7.03
alter proc		dbo.prSchedule_GetToRun
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult
		,	s.idUser as idOwner, u.sUser as sOwner
		,	s.idReport,		s.idFilter, f.idUser, f.sFilter, f.xFilter
		,	s.sSendTo, s.bActive, s.dtCreated, s.dtUpdated
--	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, dtLastRun, dtNextRun		--, iResult
--		,	s.idUser as idAuthor, u.sStaff as sAuthor,	s.idReport, s.sSendTo	--, bActive, dtCreated, dtUpdated
--		,	s.idFilter, f.idUser, f.sFilter, f.xFilter
		from	tbSchedule	s	with (nolock)
		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User u	with (nolock)	on	u.idUser = s.idUser
		where	s.bActive > 0	and	s.dtNextRun < getdate( )
end
go
--	----------------------------------------------------------------------------
--	Returns modules state
--	7.06.5617	+ .sMachine, .sIpAddr
--	7.06.5395
alter proc		dbo.pr_Module_GetAll
(
	@bInstall	bit					-- installed?
,	@bActive	bit					-- running?
)
	with encryption
as
begin
--	set	nocount	on
	select	idModule, sModule, sDesc, bLicense, tiModType, sIpAddr, sMachine, sVersion, dtStart, sParams, dtLastAct
		,	case when sMachine is null then sIpAddr else sMachine end	as	sHost
		,	datediff( mi, dtLastAct, getdate( ) )	as	siElapsed
		from	tb_Module	with (nolock)
		where	(@bInstall = 0	or	sIpAddr is not null  or  sMachine is not null)
		and		(@bActive = 0	or	dtStart is not null)
end
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
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

	select	@s= 'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', l=' + isnull(cast(@bLicense as varchar), '?') +
				', v=' + isnull(@sVersion, '?') + ', ip=' + isnull(@sIpAddr, '?') + ', m=' + isnull(@sMachine, '?') + ', d=''' + isnull(@sDesc, '?') + ''' )'
		,	@idLogType =	61

	begin	tran

		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule)
		begin
			if	@sMachine is null	--	and	@sIpAddr is null				-- un-register
			begin
				update	tb_Module	set		sIpAddr =	null,		sMachine =	null,		sVersion =	null
										,	dtStart =	null,		sParams =	null
					where	idModule = @idModule

				select	@idLogType =	62
			end
			else
				update	tb_Module	set		sIpAddr =	@sIpAddr,	sMachine =	@sMachine,	sVersion =	@sVersion
										,	sDesc =		@sDesc,		bLicense =	@bLicense
					where	idModule = @idModule
		end
		else
		begin
			insert	tb_Module	(  idModule,  tiModType,  sModule,  sDesc,  bLicense,  sVersion,  sIpAddr,  sMachine )
					values		( @idModule, @tiModType, @sModule, @sDesc, @bLicense, @sVersion, @sIpAddr, @sMachine )

			select	@s =	@s + ' INS'
		end

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5618	* [7] default: 0 -> 30, semantics reversed
begin tran
--		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 7, 30 )	--	0=purge all, N=remove aux events data older than N days, 0xFF=keep everything
	begin
		declare		@s	varchar( 255 )

		select	@s =	sDesc	from	dbo.tb_Module	with (nolock)	where	idModule = 1

		if	charindex('7980 Database', @s) = 1
			update	dbo.tb_OptSys	set	iValue =	0
				where	idOption = 7
		else
			update	dbo.tb_OptSys	set	iValue =	case when	iValue = 0xFF	then	0	else	30	end
				where	idOption = 7
	end
commit
go
--	----------------------------------------------------------------------------
--	Removes expired calls
--	7.06.5618	* optimize
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

	set	nocount	on

	exec	dbo.pr_Module_Act	1

	begin	tran

		select	@dt =	getdate( )											-- mark starting time

		update	r	set	r.idEvent =		null								-- reset tbRoom.idEvent		v.7.02
			from	tbRoom	r
			join	tbEvent_A	ea	on	ea.idEvent = r.idEvent
			where	ea.dtExpires < @dt

		update	rb	set	rb.idEvent =	null								-- reset tbRoomBed.idEvent	v.7.02
			from	tbRoomBed	rb
			join	tbEvent_A	ea	on	ea.idEvent = rb.idEvent
			where	ea.dtExpires < @dt

		delete	from	tbEvent_A	where	dtExpires < @dt					-- remove expired calls

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns rooms/masters for given unit
--	7.06.5624	+ 680 rooms into output
--	7.05.5212
alter proc		dbo.prRoom_GetByUnit
(
	@idUnit		smallint			-- 
,	@bActive	bit= 1				-- 0=add inactive, 1=active only
)
	with encryption
as
begin
	set	nocount	on

	create table	#tbDevice
	(
		idDevice	smallint

		primary key nonclustered ( idDevice )
	)

	insert	#tbDevice
		select	idRoom
		from	tbRoom	with (nolock)
		where	idUnit = @idUnit

	if	@bActive = 0
		insert	#tbDevice
			select	idDevice
			from	vwDevice	with (nolock)
--			where	tiRID = 0	and	(tiStype between 4 and 7		-- room/workflow-master controllers
--					or	idDevice in (select idParent from tbDevice with (nolock) where tiRID =1 and tiStype =26))
			where	tiRID = 0										-- room/workflow-master controllers
							and	(tiStype between 4 and 7										-- 790 room controllers
								or	tiStype = 0x7C	or	tiStype = 0x7E							-- 680 rooms
								or	idDevice in (select idParent from tbDevice w with (nolock) where w.tiRID = 1 and w.tiStype = 26))
	--		and		(idUnit = @idUnit	or	idUnit is null	and		sUnits like '%' + cast(@idUnit as varchar) + '%')
			and		(idUnit <> @idUnit	and	sUnits like '%' + cast(@idUnit as varchar) + '%')
			and		idDevice	not	in (select idDevice from #tbDevice with (nolock))

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice						-- v.7.02
		order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Returns devices/rooms/masters for given unit(s)
--	7.06.5624	+ 680 rooms into output
--	7.03	+ added 7967-P to 'rooms' output
--	7.02	* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	7.00	+ .sBeds, re-order output
--			* @idUnit -> @sUnits, output: .bSwing -> tiSwing
--			* @idUnit is null == all units
--			+ @bActive
--			output: idRoom -> idDevice
--	6.05	+ (nolock)
--	6.04	prDevice_GetRooms -> prDevice_GetByUnit, + @tiStype->@tiKind
--			+ .bSwing to the output
--			@idLoc -> @idUnit
--	6.02	* fast_forward
--			+ .bActive, .dtCreated, .dtUpdated to the output
--	6.00	tbDefDevice -> tbDevice (FKs)
--	5.01	encryption added
--	2.03
alter proc		dbo.prDevice_GetByUnit
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit's | '*'=all
,	@tiKind		tinyint				-- 0=any, 1=rooms, 2=masters
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
	declare		@i	smallint
		,		@s	varchar( 16 )

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
			select	@i =	charindex( ',', @sUnits )

			if	@i = 0
				select	@s =	@sUnits
			else
				select	@s =	substring( @sUnits, 1, @i - 1 )

			select	@s =	'%' + @s + '%'
	---		print	@s

			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					left outer join	#tbDevice t	with (nolock)	on	t.idDevice = d.idDevice
					where	(@bActive is null	or	d.bActive = @bActive)
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiRID = 0
							and	(d.tiStype between 4 and 7										-- 790 room controllers
								or	d.tiStype = 0x7C	or	d.tiStype = 0x7E					-- 680 rooms
								or	d.idDevice in (select idParent from tbDevice w with (nolock) where w.tiRID = 1 and w.tiStype = 26)))
						or	(@tiKind = 2	and	d.tiRID = 0	and	d.tiStype between 8 and 11))	-- masters
					and		d.sUnits like @s
					and		t.idDevice is null

	---		select * from #tbDevice

			if	@i = 0
				break
			else
				select	@sUnits =	substring( @sUnits, @i + 1, len( @sUnits ) - @i )
		end
	end
	else		-- request for all units
	begin
			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					where	(@bActive is null	or	bActive = @bActive)
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiRID = 0
							and	(d.tiStype between 4 and 7										-- 790 room controllers
								or	d.tiStype = 0x7C	or	d.tiStype = 0x7E					-- 680 rooms
								or	d.idDevice in (select idParent from tbDevice w with (nolock) where w.tiRID = 1 and w.tiStype = 26)))
						or	(@tiKind = 2	and	d.tiRID = 0	and	d.tiStype between 8 and 11))	-- masters
	end

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		inner join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		left outer join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice					-- v.7.02
		order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
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
,	@sInfo		varchar( 32 )		-- module info, gets logged (e.g. 'J79???? v.M.mm.bbbb @machine/IP-address')
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
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		dtStart =	getdate( ),		sParams =	@sParams,	sIpAddr =	@sIpAddr,	sMachine =	@sMachine
				where	idModule = @idModule
		else
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		dtStart =	null	--,		sParams =	null
				where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sInfo

		exec	dbo.prEvent_Ins		0, null, null, null		---	@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	null, null, null, null, null, @sInfo	---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit

	set	nocount	on

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0													-- empty device

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	if	charindex('SIP:', @sDevice) = 1								-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
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
		select	@s =	@s + '  sDvc'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.5638	* fkEventC_Event_Voice -> fkEventC_EvtVo, fkEventC_Event_Staff -> fkEventC_EvtSt
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventC_EvtVo')
begin
	begin tran
		exec sp_rename 'fkEventC_Event_Voice',	'fkEventC_EvtVo',	'object'
		exec sp_rename 'fkEventC_Event_Staff',	'fkEventC_EvtSt',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.5648	* fix for updating tb_OptSys[19].iValue
--	7.06.5638	* fix for updating tbEvent_C.idEvt??
--	7.06.5618	* fix for no tbEvent_S records (e.g. recent install + 7980)
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
		,		@idEvent	int
		,		@tiPurge	tinyint			-- FF=keep everything
											-- N=remove auxiliary data older than N days (cascaded)
											-- 0=remove all inactive events from [tbEvent*] (cascaded)
	set	nocount	on

	select	@dt =	getdate( )												-- smalldatetime truncates seconds
		,	@s =	'@' + @@servicename

	select	@s +=	', D:' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 0

	select	@s +=	', L:' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 1

	update	tb_Module	set	sParams =	@s		where	idModule = 1

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	ec	set	ec.idEvtVo =	null						-- implements CASCADE SET NULL
					from	tbEvent_C ec
					left join	tbEvent_A a	on	a.idEvent = ec.idEvtVo
					where	a.idEvent is null

				update	ec	set	ec.idEvtSt =	null
					from	tbEvent_C ec
					left join	tbEvent_A a	on	a.idEvent = ec.idEvtSt
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left join	tbEvent_A a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
							' inactive events in ' + convert(varchar, getdate() - @dt, 114)
				exec	dbo.pr_Log_Ins	2, null, null, @s
			end

			select	@idEvent =	max(idEvent)								-- get latest idEvent to be removed
				from	tbEvent_S
				where	dEvent <= dateadd(dd, -@tiPurge, @dt)
				and		tiHH <= datepart(hh, @dt)

			if	@idEvent is null											--	7.06.5618
				select	@idEvent =	min(idEvent)							-- get earliest idEvent to stay
					from	tbEvent_S
					where	dateadd(dd, -@tiPurge, @dt) < dEvent

			if	@idEvent > 0												--	7.06.5648
			begin
				delete	from	tbEvent_B
					where	idEvent < @idEvent

				update	tb_OptSys	set	iValue =	@idEvent,	dtUpdated=	@dt		where	idOption = 19
			end

		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.06.5641	* fix @idCall ?= null check
--	7.06.5528	* @idCall = null, not 0
--	7.06.5487	* logging
--	7.05.5268	+ check for @sCall
--	7.04.4896	* tbDefCall -> tbCall
--	6.05	+ (nolock), tracing
--	6.03
--	--	2.03
alter proc		dbo.prCall_GetIns
(
	@siIdx		smallint			-- call-index
,	@sCall		varchar( 16 )		-- call-text
,	@idCall		smallint	out		-- output
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@siIdx =	@siIdx & 0x03FF		-- mask significant bits only [0..1023]
		,	@idCall =	null				-- not in tbCall

	select	@s =	'Call_GI( ' + isnull(cast(@siIdx as varchar), '?') + ':' + isnull(@sCall, '?') + ' )'

	if	@siIdx > 0
	begin
		-- match by priority-index
			select	@idCall =	idCall	from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0

		if	@idCall is null					-- match by call-text
			select	@idCall =	idCall	from	tbCall	with (nolock)	where	sCall = @sCall	and	bActive > 0

		if	@idCall is null
		begin
			begin	tran

				if	@sCall is null	or	len( @sCall ) = 0
					select	@sCall =	sCall	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx

				insert	tbCall		(  siIdx,  sCall )
						values		( @siIdx, @sCall )
				select	@idCall =	scope_identity( )

				select	@s =	@s + '  id=' + cast(@idCall as varchar)
				exec	dbo.pr_Log_Ins	72, null, null, @s
	/*			end
				else
				begin
					select	@s= @s + ' ): call-txt'
					exec	dbo.pr_Log_Ins	82, null, null, @s
				end
	*/
			commit
		end
	end
end
go
--	----------------------------------------------------------------------------
--	Returns an existing schedule
--	7.06.5659	* + .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_GetToRun
--	7.03
alter proc		dbo.prSchedule_Get
(
	@idSchedule	smallint out
)
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult
		,	s.idUser as idOwner, u.sUser as sOwner
		,	s.idReport, r.sReport, r.sRptName, r.sClass,	s.idFilter, null as idUser, null as sFilter, null as xFilter	-- f.sFilter, f.xFilter, f.idUser
		,	s.sSendTo, s.bActive, s.dtCreated, s.dtUpdated
		from	tbSchedule	s	with (nolock)
		join	tbReport r	with (nolock)	on	r.idReport = s.idReport
--		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User	u	with (nolock)	on	u.idUser = s.idUser
		where	idSchedule = @idSchedule
end
go
--	----------------------------------------------------------------------------
--	Returns a list of active schedules, due for execution right now
--	7.06.5659	* + .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_Get
--	7.05.4980	* u.sFirst + ' ' + u.sLast -> u.sStaff
--	7.03
alter proc		dbo.prSchedule_GetToRun
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult
		,	s.idUser as idOwner, u.sUser as sOwner
		,	s.idReport, r.sReport, r.sRptName, r.sClass,	s.idFilter, f.idUser, f.sFilter, f.xFilter
		,	s.sSendTo, s.bActive, s.dtCreated, s.dtUpdated
		from	tbSchedule	s	with (nolock)
		join	tbReport r	with (nolock)	on	r.idReport = s.idReport
		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User u	with (nolock)	on	u.idUser = s.idUser
		where	s.bActive > 0	and	s.dtNextRun < getdate( )
end
go
--	----------------------------------------------------------------------------
--	7.06.5661	* [*] expand
begin tran
---	if	not	exists	(select 1 from dbo.tb_Feature where idModule = 62 and idFeature = ?)
	begin
		update	dbo.tb_Feature	set	sFeature =	'Assignments - Patients'	where	idModule = 62	and	idFeature = 00
		update	dbo.tb_Feature	set	sFeature =	'Assignments - Devices'		where	idModule = 62	and	idFeature = 01
		update	dbo.tb_Feature	set	sFeature =	'Assignments - Badges'		where	idModule = 62	and	idFeature = 02
		update	dbo.tb_Feature	set	sFeature =	'Assignments - Teams'		where	idModule = 62	and	idFeature = 03

		update	dbo.tb_Feature	set	sFeature =	'Administration - Facility'	where	idModule = 62	and	idFeature = 10
		update	dbo.tb_Feature	set	sFeature =	'Administration - Units'	where	idModule = 62	and	idFeature = 11
		update	dbo.tb_Feature	set	sFeature =	'Administration - Roles'	where	idModule = 62	and	idFeature = 12
		update	dbo.tb_Feature	set	sFeature =	'Administration - Staff'	where	idModule = 62	and	idFeature = 13
		update	dbo.tb_Feature	set	sFeature =	'Administration - Devices'	where	idModule = 62	and	idFeature = 14
		update	dbo.tb_Feature	set	sFeature =	'Administration - Badges'	where	idModule = 62	and	idFeature = 15
		update	dbo.tb_Feature	set	sFeature =	'Administration - Teams'	where	idModule = 62	and	idFeature = 16
	end
commit
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 5661 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5661, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated= '2015-07-02', dtInstall= getdate( )
		,	sVersion= 'module registration, 7981ls: notify only active rooms, 7980: explicit skips, 680 support, 7983ss, 7970as, 7980cw'
		where	siBuild = 5661

	update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.6.5661'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.5661 )'
commit
go

checkpoint
go

use [master]
go