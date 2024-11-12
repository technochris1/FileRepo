--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2021-Mar-25		.7754
--						* pr_Sess_Ins
--		2021-Apr-23		.7783
--						RC
--		2021-Jun-09		.7830
--						* prCfgDvc_GetAll, [prDevice_GetByID,] prRoom_GetByUnit, prDevice_GetByUnit
--		2021-Jun-16		.7837
--						* prDevice_GetIns, prEvent_Ins
--		2021-Jun-17		.7838
--						* vwEvent_A
--		2021-Jun-23		.7844
--						* prMapCell_GetByUnit
--		2021-Jul-02		.7853
--						* tbUnitMapCell clean-up
--		2021-Jul-13		.7864
--						* prDevice_GetIns
--						* prEvent_Ins, prEvent84_Ins	(.7641	* .tiLvl:	bit values changed)
--		2021-Jul-23		.7874
--						* fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit, prMapCell_GetByUnitMap
--		2021-Jul-27		.7878
--						* prEvent95_Ins
--						* prEvent84_Ins
--		2021-Aug-02		.7884
--						* fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit
--						+ clean up sessions
--		2021-Aug-03		.7885
--						* prEvent_A_Get
--		2021-Aug-04		.7886
--						* prStaff_GetByUnit
--		2021-Aug-04		.7887
--						RC
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7887 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7887', 18, 0 )
go


go
--	----------------------------------------------------------------------------
--	Inserts a new session
--	7.06.7754	+ tracing
--	7.05.5059	+ tb_Sess.idModule
--	7.05.5044	* @idUser: smallint -> int
--	6.00	prRptSess_Ins -> pr_Sess_Ins, revised
--	5.01	encryption added
--	4.02	+ tbRptSess.sMachine, .tiLocal (prRptSess_Ins)
--	3.01
alter proc		dbo.pr_Sess_Ins
(
	@sSessID	varchar( 32 )
,	@idModule	tinyint
,	@idUser		int
,	@sIpAddr	varchar( 40 )
,	@sMachine	varchar( 32 )
,	@bLocal		bit
,	@sBrowser	varchar( 255 )
,	@idSess		int				out
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

--	select	@s =	'Sess_I( ' + isnull(cast(@idModule as varchar),'?') + ', ''' + isnull(@sSessID,'?') + ''', ' +
	select	@s =	'Sess_I( ''' + isnull(@sSessID,'?') + ''', ' +
					isnull(cast(@idUser as varchar),'?') + ', ' +
					isnull(cast(@sIpAddr as varchar),'?') +	'|' + isnull(@sMachine,'?') + ', l=' +
					isnull(cast(@bLocal as varchar),'?') + ', ''' +
					isnull(cast(@sBrowser as varchar),'?') + ''' ) '

	select	@idSess =	idSess
		from	tb_Sess		with (nolock)
		where	sSessID = @sSessID	and	idModule = @idModule	and	sIpAddr = @sIpAddr	and	sBrowser = @sBrowser

	begin	tran
---		if	@idSess > 0		return		--	SQL BUG:	return does NOT abort execution immediately as described in docs!!
		if	@idSess is null
		begin
	--		begin	tran

				insert	tb_Sess	(  sSessID,  idModule,  idUser,  sIpAddr,  sMachine,  bLocal,  sBrowser )
						values	( @sSessID, @idModule, @idUser, @sIpAddr, @sMachine, @bLocal, @sBrowser )
				select	@idSess =	scope_identity( )

				select	@s =	@s + '+'
	--		commit
		end

		select	@s =	@s + cast(@idSess as varchar)

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	0, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns 790 devices, filtered according to args
--	7.06.7830	* @tiKind streamlined across
--	7.06.7207	* switch to .cDevice from .tiStype (adding 700)
--	7.06.5855	* AID update, IP-address for GWs -> .sDial
--	7.06.5613	* 680 station types recognition
--	7.06.5414
alter proc		dbo.prCfgDvc_GetAll
(
--	@idUser		int			= null	-- null=any
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@tiKind		tinyint		= 0xFF	-- FF=any, 01=Gway, 02=Mstr, 04=Wkfl, 08=Room, 10=Zone, E0=Othr
)
	with encryption
as
begin
--	set	nocount	on
	select	idDevice, idParent, tiJID, tiRID, sSGJR, iAID, tiStype, cDevice
		,	case when	sBeds is null	then sDevice	else	sDevice + ' : ' + sBeds	end		as	sDevice
		,	case when	tiStype	< 4		then sDial
				when	len(sUnits) > 31	then substring(sUnits,1,24) + '..(' + cast((len(sUnits)+1)/4 as varchar) + ' units)'
				else	sUnits	end		as	sUnits
		,	sDial, sCodeVer, idUnit, bActive, dtCreated, dtUpdated
		from	vwDevice	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
--		and		(@tiKind & 0x01 <> 0	and	(tiStype < 4				or	tiStype = 116)											--	Gway | 7092-Gway
--			or	@tiKind & 0x02 <> 0		and	(tiStype between 4 and 7	or	tiStype = 124	or	tiStype = 126	or					--	Room | 680-BusSt | 680-Main
--											tiStype between 109 and 111	or	tiStype = 114	or	tiStype = 115	or	tiStype between 117 and 119)	--	700-Room
--			or	@tiKind & 0x04 <> 0		and	(tiStype between 8 and 11	or	tiStype = 24	or	tiStype = 26	or	tiStype = 125	or
--											tiStype = 16)																			--	Mstr | Wkfl | 680-Mstr | 7065-Mstr
--			or	@tiKind & 0x08 <> 0		and	(tiStype between 13 and 15	or	tiStype = 113)											--	Zone | 7071-Zone
--			or	@tiKind & 0x10 <> 0)									--	Other
		and	(	@tiKind = 0xFF												-- any
			or	@tiKind & 0x01 <> 0		and	cDevice = 'G'					-- Gway
			or	@tiKind & 0x02 <> 0		and	cDevice = 'M'					-- Mstr
			or	@tiKind & 0x04 <> 0		and	cDevice = 'W'					-- Wkfl
			or	@tiKind & 0x08 <> 0		and	cDevice = 'R'					-- Room
			or	@tiKind & 0x10 <> 0		and	cDevice = 'Z'					-- Zone
			or	@tiKind & 0xE0 <> 0		and	cDevice not in ('G','M','R','W','Z')	-- Othr
			)
--		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
--					from	tb_RoleUnit	ru	with (nolock)
--					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	sSGJR
end
go
--	----------------------------------------------------------------------------
--	Returns requested device/room/master's details
--	7.02	* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	7.00
alter proc		dbo.prDevice_GetByID
(
	@idDevice	smallint			-- device (PK)
,	@bActive	bit =		null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice						-- v.7.02
		where	(@bActive is null	or	d.bActive = @bActive)
		and		d.idDevice = @idDevice
--	-	order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Returns rooms/masters for given unit
--	7.06.7830	* @tiKind streamlined across
--				* switch to .cDevice from .tiStype (adding 700)
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

	insert	#tbDevice														-- add active rooms in given unit
		select	idRoom
		from	tbRoom	with (nolock)
		where	idUnit = @idUnit

	if	@bActive = 0														-- add other rooms that may belong to given unit
		insert	#tbDevice
			select	idDevice
			from	vwDevice	with (nolock)
			where	tiRID = 0												-- room/master controllers
			and		cDevice in ('R','M') 									-- Room|Mstr	(Wkfl,'W' is always @ RID=1)
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
--	7.06.7830	* @tiKind streamlined across
--	7.06.7286	* switch to .cDevice from .tiStype (adding 700)
--	7.06.5861	+ 680 masters into output
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
,	@tiKind		tinyint		= 0xFF	-- FF=any, 01=Gway, 02=Mstr, 04=Wkfl, 08=Room, 10=Zone, E0=Othr
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
	declare		@si	smallint
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
			select	@si =	charindex( ',', @sUnits )

			if	@si = 0
				select	@s =	@sUnits
			else
				select	@s =	substring( @sUnits, 1, @si - 1 )

			select	@s =	'%' + @s + '%'
	---		print	@s

			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					left join	#tbDevice t	with (nolock)	on	t.idDevice = d.idDevice
					where	(@bActive is null	or	d.bActive = @bActive)
					and	(	@tiKind = 0xFF									-- any
						or	tiRID = 0
						and	(	@tiKind & 0x02 <> 0		and	cDevice = 'M'	-- Mstr
							or	@tiKind & 0x08 <> 0		and	cDevice = 'R'	-- Room
							)
						or	tiRID = 1
						and		@tiKind & 0x04 <> 0		and	cDevice = 'W'	-- Wkfl
						)
					and		d.sUnits like @s
					and		t.idDevice is null

	---		select * from #tbDevice

			if	@si = 0
				break
			else
				select	@sUnits =	substring( @sUnits, @si + 1, len( @sUnits ) - @si )
		end
	end
	else		-- request for all units
	begin
			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					where	(@bActive is null	or	bActive = @bActive)
					and	(	@tiKind = 0xFF									-- any
						or	tiRID = 0
						and	(	@tiKind & 0x02 <> 0		and	cDevice = 'M'	-- Mstr
							or	@tiKind & 0x08 <> 0		and	cDevice = 'R'	-- Room
							)
						or	tiRID = 1
						and		@tiKind & 0x04 <> 0		and	cDevice = 'W'	-- Wkfl
						)
	end

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice						-- v.7.02
		order	by	d.sDevice,	d.bActive	desc,	d.dtCreated	desc
end
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
--	7.06.7837	* @iAID <> 0 (signed!)
--	7.06.7535	* match GW#_FAIL source (S-G-0-0) and don't complain
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

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


	-- match GW#_FAIL source?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7535
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	cDevice = 'G'

	-- match APP_FAIL source?
	if	@idDevice is null	and	@tiGID = 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7410
		select	@idDevice=	idDevice,	@bActive =	bActive,	@cDevice =	'A'	from	tbDevice	with (nolock)
			where						cSys = @cSys	and	tiGID = 0	and	tiJID = 0	and	tiRID = 0	--and	cDevice = 'M'
--	-		where						cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	--and	cDevice = 'M'


	-- match inactive devices?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.06.5560
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	cDevice = 'M'

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


--	if	@idDevice > 0																			--	7.06.5560
	if	@idDevice is not null																	--	7.06.739?
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		select	@sD =	sDevice,	@iA =	iAID												--	7.06.6758
			from	tbDevice	with (nolock)
			where	idDevice = @idDevice

		if	@tiRID = 0	and	@sD <> @sDevice
			select	@s =	@s + ' ^n:''' + @sD + ''''

		if	@iA <> @iAID
			select	@s =	@s + ' ^a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

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
				select	@s =	@s + ' !c'
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
		select	@s =	@s + ' !s'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	7.06.7837	* @iAID <> 0 (signed!)
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
	if	@iAID <> 0	or	@tiStype > 0										--	7.06.7837
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
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
--	7.06.7838	* .sGJRB ' /' -> ' #'
--	7.06.7307	* .sGJRB ' :' -> ' /'
--	7.06.6974	+ r.sDial, cb.cDial
--	7.06.6624	* vwRoomBed cannot replace tbRoom (left join may result in empty .idUnit!)
--	7.06.6500	* vwRoomBed replaces tbRoom
--				+ rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
--	7.06.6373	+ .tiLvl
--	7.06.6184	+ .tiPrism, sPrism
--	7.06.6183	+ .tiDome
--	7.06.5695	+ .tiTone, .tiToneInt
--	7.06.5529	* fix .sRoomBed: or ea.tiBed = 0xFF
--	7.06.5410	+ .sRoomBed
--	7.06.5386	* .sGJRB '-' -> ' :'
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
	,	sd.idDevice, sd.sDevice, sd.sQnDevice, sd.tiStype, sd.sSGJR + ' #' + right('0' + cast(ea.tiBtn as varchar), 2)	as	sSGJRB
	,	rm.idUnit,	ea.idRoom, r.sDevice	as	sRoom,	r.sDial,	ea.tiBed, cb.cBed, cb.cDial
	,	r.sDevice + case when ea.tiBed is null or ea.tiBed = 0xFF then '' else ' : ' + cb.cBed end		as	sRoomBed
	,	ea.idCall, c.siIdx, c.sCall, cp.iColorF, cp.iColorB, cp.tiShelf, cp.tiLvl, cp.tiSpec, cp.iFilter, cp.tiDome, cd.tiPrism, cp.tiTone, cp.tiToneInt
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit )		as	bAnswered
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) )	as	tElapsed,	ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
	from		tbEvent_A	ea	with (nolock)
	left join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
	left join	tbCall		c	with (nolock)	on	c.idCall = ea.idCall
	left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
	left join	tbCfgDome	cd	with (nolock)	on	cd.tiDome = cp.tiDome
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
--	7.06.7844	+ .tiSwing, .sUnits
--	7.05.4990	+ .tiRID[i], .tiBtn[i]
--	7.03	?
alter proc		dbo.prMapCell_GetByUnit
(
	@idUnit		smallint					-- unit id
)
	with encryption
as
begin
--	set	nocount	on
	select	c.tiMap, c.tiCell, c.sCell1, c.sCell2, c.tiRID1, c.tiBtn1,	c.tiRID2, c.tiBtn2,	c.tiRID4, c.tiBtn4
		,	c.idRoom, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.bActive
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		from	tbUnitMapCell	c	with (nolock)
		left outer join	tbDevice	d	with (nolock)	on	d.idDevice = c.idRoom	--	and	d.bActive > 0	--	and	d.tiRID = 0
--		left outer join	tbDevice	d	with (nolock)	on	d.cSys = c.cSys	and	d.tiGID = c.tiGID	and	d.tiJID = c.tiJID	and	d.tiRID = 0	and	d.bActive > 0
		where	c.idUnit = @idUnit
end
go
--	clean-up orphan data
update	tbUnitMapCell	set	tiRID1=	null,	tiBtn1=	null,	tiRID2=	null,	tiBtn2=	null,	tiRID4=	null,	tiBtn4=	null
	where	idRoom is null
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
--	7.06.7864	* optimized logging
--	7.06.7837	* @iAID <> 0 (signed!)
--	7.06.7535	* match GW#_FAIL source (S-G-0-0) and don't complain
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
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + '|' + isnull(cast(@tiStype as varchar),'?') +
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

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


	-- match GW#_FAIL source?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7535
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	cDevice = 'G'

	-- match APP_FAIL source?
	if	@idDevice is null	and	@tiGID = 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7410
		select	@idDevice=	idDevice,	@bActive =	bActive,	@cDevice =	'A'	from	tbDevice	with (nolock)
			where						cSys = @cSys	and	tiGID = 0	and	tiJID = 0	and	tiRID = 0	--and	cDevice = 'M'
--	-		where						cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	--and	cDevice = 'M'


	-- match inactive devices?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.06.5560
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	cDevice = 'M'

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


--	if	@idDevice > 0																			--	7.06.5560
	if	@idDevice is not null																	--	7.06.739?
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		select	@sD =	sDevice,	@iA =	iAID												--	7.06.6758
			from	tbDevice	with (nolock)
			where	idDevice = @idDevice

		if	@tiRID = 0	and	@sD <> @sDevice
			select	@s =	@s + ' !n:''' + @sD + ''''

		if	@iA <> @iAID
			select	@s =	@s + ' !a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

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
				select	@s =	@s + ' !c'
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
		select	@s =	@s + ' !s'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	7.06.7864	(.7641)	* .tiLvl:	bit values changed
--	7.06.7837	* @iAID <> 0 (signed!)
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
					' #' + isnull(cast(@tiBtn as varchar),'?') + ','
	if	@iAID <> 0	or	@tiStype > 0										--	7.06.7837
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
		select	@tiBed =	null,	@p =	@p + ' !b'						-- invalid bed

	if	@idUnit > 0		and													--	7.06.7412
		(@idUnit < 259	or													-- lowest possible unit
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)	)
	begin
		select	@idUnit =	null											-- suppress
		if	@tiSrcGID > 0
			select	@p =	@p + ' !u'										-- invalid unit
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

		exec		dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID,  @tiStype,  @cDevice, @sSrcDvc, null, @idSrcDvc out

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

	--		if	@idCmd = 0x84	and	@tiLvl > 2								--	7.06.6355
			if	@idCmd = 0x84	and	@tiLvl > 0x90							--	7.06.7864
				select	@idParent=	idEvent,	@dtParent=	dtEvent
					from	tbEvent_A	ea	with (nolock)
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = ea.siIdx
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		bActive > 0			and	cp.tiLvl = 0x90			-- clinic-patient	7.06.7864
	--				and		bActive > 0			and	cp.tiLvl = 2			-- clinic-patient
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
--	Inserts event [0x84] call status
--	7.06.7878	+ .tiLvl into @tiFlags to indicate clinic calls
--	7.06.7864	(.7641)	* .tiLvl:	bit values changed
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
					' #' + isnull(cast(@tiBtn as varchar),'?') +
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
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + ' !b'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	if	@bFailure = 0	and													--	7.06.7417
		(@idUnit < 259	or													-- lowest possible unit
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0))
		select	@idUnit =	null,	@p =	@p + ' !u'						-- invalid unit


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

	--				if	@tiLvl = 0											-- non-clinic call
					if	@tiLvl & 0xF0 = 0									-- non-clinic call	.7864
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
					if	@tiLvl = 0x90										-- 2 clinic-patient	.7864
						insert	tbEvent_D	(  idEvent,  dEvent,    tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, tiHH )
								values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, datepart(hh, @dtOrigin) )
					else
					if	@tiLvl = 0xA0										-- 3 clinic-staff	.7864
						update	tbEvent_D	set	idEvntS =	@idEvent
							where	idEvent = @idParent		and	idEvntS is null
					else
					if	@tiLvl = 0xB0										-- 4 clinic-doctor	.7864
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

			if	@tiLvl & 0xFF = 0											-- non-clinic call	.7864
				and	@bRounding > 0	and	@siIdxNew <> @siIdxOld	-- escalated to next stage
		--	begin
					update	tbEvent_D	set	idEvntS =	@idEvent,	tRoomS =	@dtEvent
						where	idEvent = @idOrigin		and	idEvntS is null
		--	end
			else
			if	@tiLvl & 0xF0 > 0											-- clinic call	.7864
				and	0 < @siIdxNew	and	@siIdxNew <> @siIdxOld	and	@siIdxUg is null	-- escalated to last stage
			begin
				if	@tiLvl = 0x90											-- 2 clinic-patient
	--	-			update	tbEvent_D	set	tWaitS =	@dtEvent - dEvent - tEvent		--	SQL 2016
					update	tbEvent_D	set	tWaitS =	@dtEvent - cast(dEvent as datetime) - cast(tEvent as datetime)
						where	idEvent = @idOrigin		and	tWaitS is null
				else
		--		if	@tiLvl = 0xA0											-- 3 clinic-staff
		--		else
				if	@tiLvl = 0xB0											-- 4 clinic-doctor
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

	--		if	@tiLvl = 0	--and	@bRounding > 0
			if	@tiLvl & 0xFF = 0											-- non-clinic call	.7864
			begin
				if	@tiBtn < 3	and	@tiSrcRID = 0	and	@tiBed = 0			-- 0=G, 1=O, 2=Y BadgeCalls are room-level
					update	tbRoom	set	tiCall =	tiCall	&	case when	@tiBtn = 0	then	0xFB
																	when	@tiBtn = 1	then	0xFD
																						else	0xFE	end
						where	idRoom = @idRoom							--	7.06.7464

	--	-		update	tbEvent_D	set	tWaitS =	@dtEvent - dEvent - tRoomS		--	SQL 2016
				update	tbEvent_D	set	tWaitS =	@dtEvent - cast(dEvent as datetime) - cast(tRoomS as datetime)
								,		idEvntD =	@idEvent
					where	idEvent = @idOrigin	--	and	tRoomS is not null

				delete	tbEvent_D
					where	idEvent = @idOrigin	and	idEvntD = idEvntS		-- remove 0-length rounding
			end
			else
			if	@tiLvl = 0x90	and	@siIdxUg is null						-- 2 clinic-patient
	--	-		update	tbEvent_D	set	tRoomP =	@dtEvent - dEvent - tEvent		--	SQL 2016
				update	tbEvent_D	set	tRoomP =	@dtEvent - cast(dEvent as datetime) - cast(tEvent as datetime)
					where	idEvent = @idOrigin		and	tRoomP is null
			else
			if	@tiLvl = 0xA0												-- 3 clinic-staff
				update	ed	set	tRoomS =	@dtOrigin						-- == eo.tOrigin
					from	tbEvent		ee	with (nolock)
					join	tbEvent		eo	with (nolock)	on	eo.idEvent = ee.idOrigin
					join	tbEvent_D	ed					on	ed.idEvent = eo.idParent
					where	ee.idEvent = @idEvent	and	tRoomS is null
			else
			if	@tiLvl = 0xB0												-- 4 clinic-doctor
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
						+ (@tiLvl & 0x80)									--	7.06.7878
end
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
--	7.06.7884	* revert: include Clinic calls
--	7.06.7874	+ no Clinic calls	tiLvl & 0x80 = 0
--		.6974	+ r.sDial, cb.cDial
--	--	.6500	+ rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
--		.6373	+ .tiLvl
--		.6184	+ .tiPrism, sPrism
--		.6183	+ .tiDome
--	--	.5695	+ .tiTone, .tiToneInt
--		.5410	+ .sRoomBed
--	7.06.5695	+ .tiTone, .tiToneInt
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idUnit,	idRoom, sRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiLvl, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiToneInt
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0		and	idUnit = @idUnit	--	and	tiLvl & 0x80 = 0
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given room (identified by Sys-G-J)
--	7.06.7884	* revert: include Clinic calls
--	7.06.7874	+ no Clinic calls	tiLvl & 0x80 = 0
--		.6974	+ r.sDial, cb.cDial
--	--	.6500	+ rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
--		.6373	+ .tiLvl
--		.6184	+ .tiPrism, sPrism
--		.6183	+ .tiDome
--	--	.5695	+ .tiTone, .tiToneInt
--		.5410	+ .sRoomBed
--	7.06.5695	+ .tiTone, .tiToneInt
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idUnit,	idRoom, sRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiLvl, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiToneInt
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	( tiShelf > 0	or	@bPrsnc > 0	and	tiSpec between 7 and 9 )	--	and	tiLvl & 0x80 = 0
			and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Data source for 7985
--	7.06.7884	* revert: include Clinic calls
--	7.06.7874	+ no Clinic calls	tiLvl & 0x80 = 0
--	7.06.6953	* removed 'db7983.' from object ref
--				* added 'dbo.' to function refs
--	7.06.6187	+ tiDome8, tiDome4, tiDome2, tiDome1:	fnEventA_GetDomeByRoom
--	7.06.6044	* rb.sRoom -> rb.sQnDevice for WV
--	7.06.5695	+ .tiTone, .tiToneInt
--	7.06.5528	* fix order for LV:  ea.bAnswered, ea.siIdx desc, ea.tElapsed DESC
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--				+ .dtDue[]
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* .idReg[4,2,1] -> .idUser[G,O,Y], .sAssnID[] -> .sStaffID[], .sAssn[] -> .sStaff[]
--	7.06.5464	+ .dtDue (for each staff)
--	7.06.5340	* fix retrieval logic for LV
--	7.06.5337	* optimize code
--	7.05.5154	* using [prUnit_SetTmpFlt], MV
--	7.05.5074	* fix retrieval logic for LV and MV
--	7.05.5007	* fnEventA_GetTopByRoom:	+ @bPrsnc
--	7.05.5003	+ order-by for MV
--	7.05.5000	* added .tiShelf, .tiSpec
--	7.03	+ @idMaster
--			+ @iFilter, - @tiShelf
--			* @tiShelf arg used in all branches (LV, WB, MV)
--	7.01	+ @tiShelf arg, + idStaffLvl to output
--	7.00	utilize fnEventA_GetTopByUnit(..)
--			prRoomBed_GetDataByUnits -> prRoomBed_GetByUnit
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.07	* #tbUnit's PK is only idUnit
--			* output, * MV source
--	6.05	+ LV: order by ea.bAnswered, WB: and ( ea.tiStype is null	or	ea.tiStype < 16 )
--			+ and ea.tiShelf > 0
--			+ (nolock), MapView
--	6.04
alter proc		dbo.prRoomBed_GetByUnit
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit's
,	@tiView		tinyint				-- 0=ListView, 1=WhiteBoard, 2=MapView
,	@iFilter	int					-- filter mask
,	@idMaster	smallint			-- master console, 0=global mode
)
	with encryption
as
begin
--	set	nocount on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	set	nocount off
	if	@tiView = 0			--	ListView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB
			,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
	--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
			from	vwEvent_A		ea	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = ea.idUnit
	--			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )	--	and	tiLvl & 0x80 = 0
				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed desc		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	rb.idRoom, rb.sQnDevice	as	sRoom,	rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB
			,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	p8.tiDome	as	tiDome8,	p4.tiDome	as	tiDome4,	p2.tiDome	as	tiDome2,	p1.tiDome	as	tiDome1
			from	vwRoomBed		rb	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
				outer apply	dbo.fnEventA_GetTopByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster, 0 )	ea
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 8 )	p8
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 4 )	p4
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 2 )	p2
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 1 )	p1
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB
			,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	mc.tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
			from	#tbUnit			tu	with (nolock)
				outer apply	dbo.fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
				outer apply	dbo.fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
			order	by	tu.sUnit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	7.06.7874	* order of 'r.bActive > 0 and'
--	7.06.7334	* r.sQnDevice -> r.sDevice	(there should be only rooms on any map; 7986cw limits that)
--	7.06.6953	* added 'dbo.' to function refs
--	7.06.6192	+ tiDome8, tiDome4, tiDome2, tiDome1:	has to match prRoomBed_GetByUnit!!
--	7.06.5940	* fix: room-level calls didn't show assigned staff
--	7.06.5856	* r.sDevice -> r.sQnDevice
--	7.06.5695	+ .tiTone, .tiToneInt
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--				+ .dtDue[]
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* .idReg[4,2,1] -> .idUser[G,O,Y], .sAssnID[] -> .sStaffID[], .sAssn[] -> .sStaff[]
--	7.06.5337	* optimize code
--	7.05.5154	* retrieval logic
--	7.05.5074	* fix retrieval logic
--	7.05.5007	* fnEventA_GetTopByRoom:	+ @bPrsnc
--	7.05.5000	* added .tiShelf, .tiSpec
--	7.05.4990	+ @tiRID[i], @tiBtn[i]
--	7.03	+ @idMaster
--			+ @iFilter
--	7.02	tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	7.01	+ idStaffLvl to output (matching prRoomBed_GetByUnit)
--	7.00	ea.idRoom, ea.sRoom -> r.idDevice [idRoom], r.sDevice [sRoom]
--			utilize fnEventA_GetTopByRoom(..)
--			prMapCell_GetDataByUnitMap -> prMapCell_GetByUnitMap
--			utilize tbUnit.idShift
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.07	* output col-names
--	6.05
alter proc		dbo.prMapCell_GetByUnitMap
(
	@idUnit		smallint			-- unit FK
,	@tiMap		tinyint
,	@iFilter	int					-- filter mask
,	@idMaster	smallint			-- master console, null=global mode
)
	with encryption
as
begin
	select	mc.idUnit, u.sUnit,		mc.cSys, mc.tiGID, mc.tiJID, ea.tiRID, ea.tiBtn
		,	r.idDevice as idRoom,	r.sDevice as sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB
		,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
		,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
		,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
		,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
		,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
		,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
		,	mc.tiMap
		,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
		,	mc.tiCell, mc.sCell1, mc.sCell2,	r.siBeds, r.sBeds,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	tbUnitMapCell	mc	with (nolock)
			join	tbUnit		u	with (nolock)	on	u.idUnit = mc.idUnit
			left join	vwRoom	r	with (nolock)	on	r.bActive > 0	and	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0
			outer apply	dbo.fnEventA_GetTopByRoom( mc.cSys, mc.tiGID, mc.tiJID, null, @iFilter, @idMaster, 1 )	ea		--	7.03
			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom
														and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF				--	and	ea.tiBed is null
															or	ea.tiBed is null	and	rb.tiBed in					--	7.06.5940
																	(select min(tiBed) from tbRoomBed with (nolock) where idRoom = ea.idRoom))
		where	mc.idUnit = @idUnit
			and	mc.tiMap = @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
--	7.06.7878	* remove commented extras
--	7.06.5490	* optimize tiSvc (tbEvent.tiFlags) handling
--	7.06.5487	* optimize
--	7.06.5485	- tbEvent95
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
,	@siIdx		smallint			-- call index
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
		,		@idCall		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime

	set	nocount	on

	select	@idLogType =	case when	@tiSvcSet > 0	then	201			-- set svc
								else							203	end		-- clr svc	202	-- set/clr

	exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out

	select	@idOrigin=	idEvent,	@dtOrigin=	dtEvent
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

--	-	insert	tbEvent95	( idEvent,  tiSvcSet,  tiSvcClr )
--	-			values		( @idEvent, @tiSvcSet, @tiSvcClr )

		update	tbEvent		set		idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin
								,	tiFlags =	case when	@tiSvcSet > 0	then	@tiSvcSet	else	@tiSvcClr	end
			where	idEvent = @idEvent

	commit

	select	@idEvent =	@idOrigin		--	7.05.5290	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	7.06.7884	clean up sessions	(.7110)
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
--	Returns notifiable active call properties
--	7.06.7885	+ tiLvl
--	7.06.7521	+ tiSvc
--	7.06.6974	+ sDial, cDial
--	7.06.6542	+ iColorF, iColorB
--	7.06.6500	+ idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
--	7.06.5388	- where tiShelf > 0
--	7.06.5352
alter proc		dbo.prEvent_A_Get
(
	@idEvent	int					-- null==all
)
	with encryption
as
begin
--	set	nocount	on
	select	idEvent, dtEvent, cSys, tiGID, tiJID, tiRID, tiBtn, idRoom, sRoom, sDial, tiBed, cBed, cDial, idUnit
		,	siIdx, sCall, iColorF, iColorB, tiShelf, tiLvl, tiSpec, bActive, bAnswered, tElapsed, tiSvc
		,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
		and		(idEvent = @idEvent		or	@idEvent is null)
end
go
--	----------------------------------------------------------------------------
--	Returns available staff for given unit(s)
--	7.06.7886	- .idPager, .idPhone, .idWi_Fi
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
	--	,	pg.idDvc as idPager,	pg.sDial as sPager
		,	stuff((select ', ' + pg.sDial
						from	tbDvc	pg	with (nolock)	where	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
						for xml path ('')), 1, 2, '') as sPager
	--	,	ph.idDvc as idPhone,	ph.sDial as sPhone
		,	stuff((select ', ' + ph.sDial
						from	tbDvc	ph	with (nolock)	where	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
						for xml path ('')), 1, 2, '') as sPhone
	--	,	wf.idDvc as idWi_Fi,	wf.sDial as sWi_Fi
		,	stuff((select ', ' + wf.sDial
						from	tbDvc	wf	with (nolock)	where	wf.idUser = st.idUser	and	wf.idDvcType = 8	and	wf.bActive > 0
						for xml path ('')), 1, 2, '') as sWi_Fi
		from	vwStaff	st	with (nolock)
		left join	vwRoom	r	with (nolock)	on	r.idDevice = st.idRoom
	--	left join	tbDvc	bd	with (nolock)	on	bd.idUser = st.idUser	and	bd.idDvcType = 1	and	bd.bActive > 0
	--	left join	tbDvc	pg	with (nolock)	on	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
	--	left join	tbDvc	ph	with (nolock)	on	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
	--	left join	tbDvc	wf	with (nolock)	on	wf.idUser = st.idUser	and	wf.idDvcType = 8	and	wf.bActive > 0
		where	st.bActive > 0
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@bOnDuty is null	or	st.bOnDuty = @bOnDuty)
		and		st.idUser in (select	idUser
			from	tb_UserUnit	uu	with (nolock)
			join	#tbUnit		u	with (nolock)	on	u.idUnit = uu.idUnit)
		order	by	st.idStfLvl desc, st.sStaff
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7887 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7887, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2021-08-05',	sVersion =	'db798?, *7983ls, *7980ns, *7987ca, *7986cw, *7985cw, *7981cw, *7980cw'
		where	siBuild = 7887

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7887'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.7887 )'
commit
go

checkpoint
go

use [master]
go