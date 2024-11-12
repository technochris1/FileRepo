--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2020-Jul-22		.7508
--						* tb_LogType[44,45,46,48]
--						* prPatient_GetIns, prPatient_UpdLoc
--		2020-Aug-04		.7521
--						* prEvent_A_Get
--		2020-Aug-14		.7531
--						* pr_User_GetDvcs, prTeam_GetDvcs, prDvc_GetByUnit
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7531 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7531', 18, 0 )
go


go
--	----------------------------------------------------------------------------
--	7.06.7508	re-classify
begin
	begin tran
		update	dbo.tb_LogType	set	tiLvl=	4,	sLogType =	'HL7 data'		where	idLogType = 44
		update	dbo.tb_LogType	set	tiCat= 16								where	idLogType in (44,45)
		update	dbo.tb_LogType	set				sLogType =	'7980 data'		where	idLogType = 46
		update	dbo.tb_LogType	set				sLogType =	'RTLS data'		where	idLogType = 48
	commit
end
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
--	7.06.7508	* optimized logging (log-level)
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@idDoc		int
		,		@cGen		char( 1 )
		,		@sInf		varchar( 32 )
--		,		@sNot		varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

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
				select	@s =	@s + ' d=' + isnull(cast(@idDoctor as varchar),'?') + '|' + isnull(@sDoctor,'?') + ' ) id=' + cast(@idPatient as varchar)

--				if	@tiLog & 0x02 > 0										--	Config?
--				if	@tiLog & 0x04 > 0										--	Debug?
				if	@tiLog & 0x08 > 0										--	Trace?
					exec	dbo.pr_Log_Ins	44, null, null, @s
			end
			else															--	found active patient with given name
			begin
				select	@s=	''
				if	@cGen <> @cGender	select	@s =	@s + ' g=' + isnull(@cGender,'?')
				if	@sInf <> @sInfo		select	@s =	@s + ' i=''' + isnull(@sInfo,'?') + ''''
		--		if	@sNot <> @sNote		select	@s =	@s + ' n="' + isnull(@sNote,'?') + '"'
				if	@idDoc <> @idDoctor	select	@s =	@s + ' d=' + isnull(cast(@idDoctor as varchar),'?') + '|' + isnull(@sDoctor,'?')

				if	0 < len( @s )											--	smth has changed
				begin
					update	tbPatient	set	cGender =	@cGender,	sInfo=	@sInfo,	idDoctor =	@idDoctor,	dtUpdated=	getdate( )	--, sNote= @sNote
						where	idPatient = @idPatient

					select	@s =	'Pat_U( ' + cast(@idPatient as varchar) + '|' + isnull(@sPatient,'?') + @s + ' )'
--					if	@tiLog & 0x02 > 0									--	Config?
					if	@tiLog & 0x04 > 0									--	Debug?
--					if	@tiLog & 0x08 > 0									--	Trace?
						exec	dbo.pr_Log_Ins	44, null, null, @s
				end
			end

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed (in response to HL7 notification via cmd x44)
--	7.06.7508	* optimized logging (log-level, C vs L)
--				* make sure patient gets cleared if room is vaild
--	7.06.7279	* optimized logging
--	7.06.7222	+ treat 'EMPTY' as 'no patient'
--				* optimize room-bed placement logic
--	7.06.6744	* exempt idPatient = 1 (EMPTY) from moving around
--				+ !P (no patient)
--	7.06.6624	* optimized log (missing bed)
--	7.06.6297	* optimized log
--	7.06.6284	- tbPatient.idRoom, .tiBed
--	7.05.5940	* optimize logging
--	7.06.5484	* optimize logging
--	7.06.5380	* use patient data only from bed-level calls
--	7.05.5147	* don't move patient for room-level calls
--	7.05.5135	* check if room-bed exists and log errors
--	7.05.5127	* ignore @tiRID
--	7.05.5105	* clear room upon no patient
--	7.05.5101	* if room doesn't have beds treat @tiBed=0 as =0xFF
--	7.04.4955	* adjust tbRoomBed also
--	7.04.4953	* fix comparison logic for nulls
--	7.03
alter proc		dbo.prPatient_UpdLoc
(
	@idPatient	int					-- 0,null=no/clear patient
,	@cSys		char( 1 )
,	@tiGID		tinyint
,	@tiJID		tinyint
,	@tiRID		tinyint				-- ignored (should be 0 for rooms)
,	@tiBed		tinyint				-- 0 ('J') is auto-corrected to 0xFF for "no-bed" rooms
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@idRoom		smallint
--		,		@idPrev		smallint
--		,		@tiPrev		tinyint
		,		@sPatient	varchar( 16 )
		,		@sRoom		varchar( 16 )

	set	nocount	on
	set	xact_abort	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@dt =	getdate( )

	select	@sPatient=	sPatient
		from	tbPatient	with (nolock)
		where	idPatient = @idPatient

	select	@idRoom =	idDevice,	@sRoom =	sDevice
		from	vwRoom		with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	bActive > 0		--	and	tiRID = @tiRID

--	select	@s =	'Pat_L( ' + isnull(cast(@idPatient as varchar),'?') + '|' + isnull(@sPatient,'?') +
--					', ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
--					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) +	--	'-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
--					', ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(@sRoom,'?') + ':' + isnull(cast(@tiBed as varchar),'?') + ' )'

--	select	@s =	'Pat_L( ' + isnull(cast(@idPatient as varchar),'?')
	if	@idPatient is null
		select	@s =	'Pat_C( '
	else
		select	@s =	'Pat_L( '

	select	@s =	@s + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) +	--	'-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					':' + isnull(cast(@tiBed as varchar),'?') + ', ' + isnull(cast(@idRoom as varchar),'?')
	if	0 < len( @sRoom )
		select	@s =	@s + '|' + @sRoom
--	select	@s =	@s + ':' + isnull(cast(@tiBed as varchar),'?')

	if	@idPatient is not null
	begin
		select	@s =	@s + ', ' + isnull(cast(@idPatient as varchar),'?')
		if	0 < len( @sPatient )
			select	@s =	@s + '|' + @sPatient
	end
	select	@s =	@s + ' )'


	if	@idRoom is null														-- no match for SGJ-coords
		select	@s =	@s + ' !R'

--	if	@sPatient is null
--		select	@s =	@s + ' !P'

	if	@tiBed = 0															-- auto-correct for no-bed rooms from bed 0
		and		@idRoom is not null
		and		exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
		select	@tiBed =	0xFF
	else
	if	@tiBed > 9															-- no match for bed
		or		@idRoom is not null
		and	not	exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
		select	@s =	@s + ' !B',		@tiBed =	null

--	if	(@tiBed = 0		or	@tiBed is null)
--		and	exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
--		select	@tiBed =	0xFF		-- auto-correct for no-bed rooms from bed 0

	if	@idRoom is null		or	--@sPatient is null	or
		@tiBed is null
--		not exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
	begin
		begin tran

			-- clear given patient's previous location
			if	@idPatient is not null
				update	tbRoomBed	set		dtUpdated=	@dt,	idPatient=	null
					where	idPatient = @idPatient
			-- clear given room-bed											NO CAN DO: EITHER room OR bed IS NULL!
	--		else
	--		if	@idRoom is not null
	--			update	tbRoomBed	set		dtUpdated=	@dt,	idPatient=	null
	--				where	idRoom = @idRoom	and	tiBed = @tiBed

			exec	dbo.pr_Log_Ins	45, null, null, @s

		commit

		return	-1
	end

	begin	tran

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	44, null, null, @s

---		if	@idPatient > 1				-- exempt idPatient = 1 (EMPTY) from moving around	--	7.06.6744
		if	0 < @idPatient													--	7.06.7222
		begin
			-- clear given patient's previous location (if different)
			update	tbRoomBed	set		dtUpdated=	@dt,	idPatient=	null
				where	idPatient = @idPatient
				and	(	idRoom <> @idRoom	or	tiBed <> @tiBed	)

			-- place given patient into given room-bed (if he's not there already - only once)
			update	tbRoomBed	set		dtUpdated=	@dt,	idPatient=	@idPatient
				where	idRoom = @idRoom	and	tiBed = @tiBed
				and	(	idPatient is null	or	idPatient <> @idPatient	)
		end
		else	-- clear given room-bed
			update	tbRoomBed	set		dtUpdated=	@dt,	idPatient=	null
				where	idRoom = @idRoom	and	tiBed = @tiBed
				and		idPatient is not null

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns notifiable active call properties
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
		,	siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, bActive, bAnswered, tElapsed, tiSvc
		,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
		and		(idEvent = @idEvent		or	@idEvent is null)
end
go
--	----------------------------------------------------------------------------
--	Returns active devices, assigned to a given user
--	7.06.7531	+ .fields to match prDvc_GetByUnit output
--	7.06.5442	+ @idDvcType
--	7.06.5347
alter proc		dbo.pr_User_GetDvcs
(
	@idUser		int					-- not null
,	@idDvcType	tinyint				-- 1=Badge, 2=Pager, 4=Phone, 8=Wi-Fi, 0xFF=any
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sDial, tiFlags, sBarCode, sBrowser, bActive		--, d.sUnits, d.sTeams
		,	null	as	idRoom,		null	as	sQnDevice
		,	idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	vwDvc	with (nolock)
		where	bActive > 0
		and		idDvcType & @idDvcType	<> 0
		and		idUser = @idUser
end
go
--	----------------------------------------------------------------------------
--	Returns active group notification devices (pagers only), assigned to a given team
--	7.06.7531	+ .fields to match prDvc_GetByUnit output
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
	select	idDvc, idDvcType, sDvc, sDial, tiFlags, sBarCode, sBrowser, bActive		--, d.sUnits, d.sTeams
		,	null	as	idRoom,		null	as	sQnDevice
		,	idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	vwDvc	with (nolock)
		where	bActive > 0
		and		idDvcType = 2
		and		idDvc	in	(select idDvc from tbTeamDvc with (nolock) where idTeam = @idTeam)
end
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
--	7.06.7531	* added Wi-Fi devices
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
		and		(@idUnit is null	or	d.idDvcType = 1		or	d.idDvcType = 8
									or	d.idDvc in (select idDvc from tbDvcUnit with (nolock) where idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7531 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7531, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2020-08-14',	dtInstall=	getdate( )
		,	sVersion =	'*7980ns, *7987ca'
		where	siBuild = 7531

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7531'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.7531 )'
commit
go

checkpoint
go

use [master]
go