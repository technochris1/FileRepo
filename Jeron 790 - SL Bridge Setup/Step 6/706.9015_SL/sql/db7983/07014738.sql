--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.01
--		2012-Dec-13		.4730
--						* prDevice_UpdRoomBeds, prDevice_UpdRoomBeds7980:  fix for rooms without beds
--		2012-Dec-14		.4731
--						* fix prStaff_sStaff_Upd:  width enforcement
--		2012-Dec-17		.4734
--						* vwRoomBed, prRoomBed_GetByUnit, prMapCell_GetByUnitMap:
--							assigned staff:	tbStaff -> vwStaff,	+ idStaffLvl, sStaffLvl
--		2012-Dec-18		.4735
--						* prStaffAssn_Fin, prStaffCover_InsFin:  updating assigned staff in tbRoomBed
--		2012-Dec-19		.4736
--		2012-Dec-21		.4738
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 701 and siBuild >= 4738 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.01.4738', 18, 0 )

go


begin tran
	set identity_insert	dbo.tb_User	on

	if not exists	(select 1 from dbo.tb_User where idUser=4)
		insert	dbo.tb_User ( idUser, sUser, iHash, sFirst, sLast, sEmail, sDesc )
			values	( 4, 'appuser',	-1571697235,	'Application',	'User',			'support@jeron.com', 'Built-in account for internal application usage.' )

	set identity_insert	dbo.tb_User	off

	if not exists	(select 1 from dbo.tb_UserRole where idUser=4 and idRole=1)
		insert	dbo.tb_UserRole ( idUser, idRole )	values	( 4, 1 )
commit
go

grant	execute				on dbo.pr_Log_Ins					to [rWriter]		--	7.01
grant	execute				on dbo.pr_Log_Get					to [rWriter]		--	7.01
grant	execute				on dbo.pr_User_Login				to [rWriter]		--	7.01
grant	execute				on dbo.pr_User_Logout				to [rWriter]		--	7.01
grant	select, insert, update, delete	on dbo.tb_Sess			to [rWriter]		--	7.01
grant	execute				on dbo.pr_Sess_Act					to [rWriter]		--	7.01
grant	execute				on dbo.pr_Sess_Ins					to [rWriter]		--	7.01
go

if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStaffLvl') and name = 'iColorB')
begin
	begin tran
		exec sp_rename 'tbStaffLvl.iColorF', 'iColorB', 'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates staff's formatted name
--	v.7.01	* add width enforcement
--	v.6.05
alter proc		dbo.prStaff_sStaff_Upd
(
	@idStaff	int							-- null = entire table
,	@tiFmt		tinyint						-- null = use tb_OptionSys[11]
)
	with encryption
as
begin
	set	nocount	on

	create	table	#tbStaff
	(
		idStaff		int
	)

	if	@idStaff > 0						--	single
	begin
		insert	#tbStaff
			values	(@idStaff)

		select	@tiFmt= cast(iValue as tinyint)		from	tb_OptionSys	with (nolock)	where	idOption = 11
	end
	else									--	update all
	begin
		if	@tiFmt is null
			return	-1						--	must be specified

		insert	#tbStaff
			select	idStaff
				from	tbStaff		with (nolock)
	end

	begin	tran

		update	tbStaff		set	sStaff=
			left( case
				when @tiFmt=0	then isnull(sFirst, '?') + ' ' + isnull(sMid, '?') + ' ' + isnull(sLast, '?')							--	First Mid Last
				when @tiFmt=1	then isnull(sFirst, '?') + ' ' + left(isnull(sMid, '?'), 1) + '. ' + isnull(sLast, '?')					--	First M. Last
				when @tiFmt=2	then isnull(sFirst, '?') + ' ' + isnull(sLast, '?')														--	First Last
				when @tiFmt=3	then left(isnull(sFirst, '?'), 1) + '.' + left(isnull(sMid, '?'), 1) + '. ' + isnull(sLast, '?')		--	F.M. Last
				when @tiFmt=4	then left(isnull(sFirst, '?'), 1) + '. ' + isnull(sLast, '?')											--	F. Last

				when @tiFmt=5	then isnull(sLast, '?') + ', ' + isnull(sFirst, '?') + ', ' + isnull(sMid, '?')							--	Last, First, Mid
				when @tiFmt=6	then isnull(sLast, '?') + ', ' + isnull(sFirst, '?') + ', ' + left(isnull(sMid, '?'), 1) + '.'			--	Last, First, M.
				when @tiFmt=7	then isnull(sLast, '?') + ', ' + isnull(sFirst, '?')													--	Last, First
				when @tiFmt=8	then isnull(sLast, '?') + ' ' + left(isnull(sFirst, '?'), 1) + '.' + left(isnull(sMid, '?'), 1) + '.'	--	Last F.M.
				when @tiFmt=9	then isnull(sLast, '?') + ' ' + left(isnull(sFirst, '?'), 1) + '.'										--	Last F.
				end, 16 )
			from	tbStaff	s
			inner join	#tbStaff	t	on	t.idStaff = s.idStaff

		if	@idStaff is null				--	update all
			update	tb_OptionSys	set	iValue= @tiFmt	where	idOption = 11

	commit
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
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
select	r.idUnit,	rb.idRoom, r.sDevice [sRoom], r.cSys, r.tiGID, r.tiJID, r.tiRID,	rb.tiBed, rb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	rb.idPatient	--, p.sPatient, p.cGender, p.sInfo, p.sNote
	,	rb.idDoctor		--, d.sDoctor
--	,	rb.idAsnRn, ar.sStaff [sAsnRn],		rb.idAsnCn, ac.sStaff [sAsnCn],		rb.idAsnAi, aa.sStaff [sAsnAi]
	,	rb.idAsnRn [idAssn1], a1.sStaff [sAssn1], a1.idStaffLvl [idStLvl1]	--, a1.sStaffLvl [sStLvl1], a1.iColorB [iColorB1]
	,	rb.idAsnCn [idAssn2], a2.sStaff [sAssn2], a2.idStaffLvl [idStLvl2]	--, a2.sStaffLvl [sStLvl2], a2.iColorB [iColorB2]
	,	rb.idAsnAi [idAssn3], a3.sStaff [sAssn3], a3.idStaffLvl [idStLvl3]	--, a3.sStaffLvl [sStLvl3], a3.iColorB [iColorB3]
	,	rb.idRegRn, rr.sStaff [sRegRn],		rb.idRegCn, rc.sStaff [sRegCn],		rb.idRegAi, ra.sStaff [sRegAi]
--	,	rr.idRn	[idRegRn],		rr.sRn	[sRegRn]
--	,	rr.idCn	[idRegCn],		rr.sCn	[sRegCn]
--	,	rr.idAi	[idRegAi],		rr.sAi	[sRegAi]
	,	/*rb.bActive, rb.dtCreated,*/ rb.dtUpdated		/*	don't exist	*/
	from	tbRoomBed	rb	with (nolock)
		inner join		tbDevice	r	with (nolock)	on	r.idDevice = rb.idRoom		and	r.bActive > 0
---		left outer join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0
---		left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
---		left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		left outer join	vwStaff		a1	with (nolock)	on	a1.idStaff = rb.idAsnRn
		left outer join	vwStaff		a2	with (nolock)	on	a2.idStaff = rb.idAsnCn
		left outer join	vwStaff		a3	with (nolock)	on	a3.idStaff = rb.idAsnAi
		left outer join	tbStaff		rr	with (nolock)	on	rr.idStaff = rb.idRegRn
		left outer join	tbStaff		rc	with (nolock)	on	rc.idStaff = rb.idRegCn
		left outer join	tbStaff		ra	with (nolock)	on	ra.idStaff = rb.idRegAi
--		left outer join	vwRtlsRoom	rr	with (nolock)	on	rr.idRoom = rb.idRoom
go
--	----------------------------------------------------------------------------
--	Inserts/deletes a StaffToPatientAssignment row
--	v.7.01	* fix for rooms without beds
--	v.7.00
alter proc		dbo.prDevice_UpdRoomBeds7980
(
	@bInsert	bit					-- insert or delete?
,	@idRoom		smallint			-- room id
,	@cBedIdx	varchar( 1 )		-- bed index: ' '=no bed, null=all combinations
,	@sRoom		varchar( 16 )
,	@sDial		varchar( 16 )
,	@idUnit1	smallint
,	@idUnit2	smallint
)
	with encryption
as
begin
	set	nocount	on
/*	begin	tran
		if	@bInsert = 0
			delete	from	StaffToPatientAssignment
				where	RoomNumber = @sDial
					and	(BedIndex = @cBedIdx
					or	BedIndex <> ' '  and  @cBedIdx is null)
		else
			if	not exists	(select 1 from StaffToPatientAssignment where RoomNumber = @sDial and BedIndex = @cBedIdx)
				insert	StaffToPatientAssignment
						(RoomNumber, RoomName, BedIndex, DownloadCounter, PrimaryUnitID, SecondaryUnitID)
					values		( @sDial, @sRoom, @cBedIdx, 0, @idUnit1, @idUnit2 )
			else
				update	StaffToPatientAssignment
					set	PrimaryUnitID= @idUnit1, SecondaryUnitID= @idUnit2
					where	RoomNumber = @sDial and BedIndex = @cBedIdx
	commit	*/
end
go
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prDevice_UpdRoomBeds7980
(
	@bInsert	bit					-- insert or delete?
,	@idRoom		smallint			-- room id
,	@cBedIdx	varchar( 1 )		-- bed index
,	@sRoom		varchar( 16 )
,	@sDial		varchar( 16 )
,	@idUnit1	smallint
,	@idUnit2	smallint
)
	with encryption
as
begin
	set	nocount	on
	begin	tran
		if	@bInsert = 0
			delete	from	StaffToPatientAssignment
				where	RoomNumber = @sDial
					and	(BedIndex = @cBedIdx
					or	BedIndex <> '' ''  and  @cBedIdx is null)
		else
			if	not exists	(select 1 from StaffToPatientAssignment where RoomNumber = @sDial and BedIndex = @cBedIdx)
				insert	StaffToPatientAssignment
						(RoomNumber, RoomName, BedIndex, DownloadCounter, PrimaryUnitID, SecondaryUnitID)
					values		( @sDial, @sRoom, @cBedIdx, 0, @idUnit1, @idUnit2 )
			else
				update	StaffToPatientAssignment
					set	PrimaryUnitID= @idUnit1, SecondaryUnitID= @idUnit2
					where	RoomNumber = @sDial and BedIndex = @cBedIdx
	commit
end' )
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
--	v.7.01	* fix for rooms without beds
--	v.7.00	* prDevice_UpdRoomBeds7980: @tiBed -> @cBedIdx
--			+ set tbDefBed.bInUse
--			+ rooms without bed
--	v.6.05	+ filling tbRoomStaff
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
			exec	dbo.pr_Log_Ins	71, null, null, @s

		begin	tran

	---	delete	from	tbRoomBed				--	removes patient-to-bed assignments!
	---		where	idRoom = @idRoom

		if	not exists	(select 1 from tbRoomStaff with (nolock) where idRoom = @idRoom)
			insert	tbRoomStaff	( idRoom)
					values		(@idRoom)

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
/*
			if	@siBeds & 1 > 0			--	'A'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 1
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 1

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 1)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 1 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '1', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '1', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 1
			end

			if	@siBeds & 2 > 0			--	'B'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 2
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 2

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 2)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 2 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '2', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '2', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 2
			end

			if	@siBeds & 4 > 0			--	'C'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 3
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 3

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 3)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 3 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '3', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '3', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 3
			end

			if	@siBeds & 8 > 0			--	'D'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 4
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 4

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 4)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 4 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '4', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '4', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 4
			end

			if	@siBeds & 16 > 0		--	'E'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 5
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 5

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 5)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 5 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '5', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '5', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 5
			end

			if	@siBeds & 32 > 0		--	'F'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 6
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 6

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 6)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 6 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '6', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '6', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 6
			end

			if	@siBeds & 64 > 0		--	'G'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 7
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 7

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 7)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 7 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '7', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '7', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 7
			end

			if	@siBeds & 128 > 0		--	'H'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 8
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 8

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 8)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 8 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '8', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '8', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 8
			end

			if	@siBeds & 256 > 0		--	'I'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 9
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 9

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 9)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 9 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '9', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '9', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 9
			end

			if	@siBeds & 512 > 0		--	'J'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 0
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 0

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 0 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '0', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '0', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0
			end
*/
		end

		update	tbDevice	set	siBeds= @siBeds, sBeds= @sBeds, dtUpdated= getdate( )
			where	idDevice = @idRoom

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
--	Finalizes specified staff assignment definition by marking it inactive
--	v.7.01	+ resetting assinged staff in tbRoomBed
--	v.7.00	tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.02
alter proc		dbo.prStaffAssn_Fin
(
	@idStaffAssn	int						-- internal
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		--	deactivate and close everything associated with that StaffAssn
		update	tbStaffCover	set
				dtEnd= getdate( ), dEnd= getdate( ), tEnd= getdate( ), tiEnd= datepart( hh, getdate( ) )
			where	idStaffAssn = @idStaffAssn

		update	tbStaffAssn	set
				bActive= 0, idStaffCover= null, dtUpdated= getdate( )
			where	idStaffAssn = @idStaffAssn

		--	reset assigned staff
		update	rb	set	idAsnRn= null
			from	tbRoomBed	rb
			inner join	tbStaffAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
			where	idStaffAssn = @idStaffAssn
		update	rb	set	idAsnCn= null
			from	tbRoomBed	rb
			inner join	tbStaffAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
			where	idStaffAssn = @idStaffAssn
		update	rb	set	idAsnAi= null
			from	tbRoomBed	rb
			inner join	tbStaffAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
			where	idStaffAssn = @idStaffAssn

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
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

/*		---	set 'oldest' assigned staff for rooms in units whose shifts have just changed
		--	set '?' assigned staff for rooms across all units
		update	rb	set	rb.idAsnRn= asn.idOldRn, rb.idAsnCn= asn.idOldCn, rb.idAsnAi= asn.idOldAi, dtUpdated= @dtNow
			from	tbRoomBed	rb
			inner join
				(select	t.idRoom, t.tiBed
					,	max(case when t.idStaffLvl = 4 then sa.idStaff else null end) [idOldRn]
					,	max(case when t.idStaffLvl = 2 then sa.idStaff else null end) [idOldCn]
					,	max(case when t.idStaffLvl = 1 then sa.idStaff else null end) [idOldAi]
			--		,	max(case when t.idStaffLvl = 4 then sa.idShift else null end) [idShRn]
			--		,	max(case when t.idStaffLvl = 2 then sa.idShift else null end) [idShCn]
			--		,	max(case when t.idStaffLvl = 1 then sa.idShift else null end) [idShAi]
					from
						(select	rb.idRoom, rb.tiBed, st.idStaffLvl, min(sa.idStaffCover) [idStaffCover]
							from	tbRoomBed	rb
							inner join	tbStaffAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
							inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sa.idStaffAssn		and	ca.bFinish = 0
							inner join	tbStaff		st	on	st.idStaff = sa.idStaff
							inner join	tbStaffCover	sc	on	sc.idStaffCover = sa.idStaffCover
							group	by	rb.idRoom, rb.tiBed, st.idStaffLvl
						)	t
					inner join	tbStaffAssn	sa	on	sa.idStaffCover = t.idStaffCover
					inner join	tbUnit		u	on	u.idShift = sa.idShift	---	and	(u.idShPrv is null	or	u.idShPrv <> sa.idShift)
					group	by	t.idRoom, t.tiBed
				)	asn		on	asn.idRoom = rb.idRoom	and	asn.tiBed = rb.tiBed
*/
		---	set assigned staff
		update	rb	set	idAsnRn= sa.idStaff
			from	tbRoomBed	rb
			inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStaffAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 1	and	sa.bActive > 0
		update	rb	set	idAsnCn= sa.idStaff
			from	tbRoomBed	rb
			inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStaffAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 2	and	sa.bActive > 0
		update	rb	set	idAsnAi= sa.idStaff
			from	tbRoomBed	rb
			inner join	tbDevice	r	on	r.idDevice = rb.idRoom
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
--	Data source for 7985
--	v.7.01	+ @tiShelf arg, + idStaffLvl to output
--	v.7.00	utilize fnEventA_GetTopByUnit(..)
--			prRoomBed_GetDataByUnits -> prRoomBed_GetByUnit
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.07	* #tbUnit's PK is only idUnit
--			* output, * MV source
--	v.6.05	+ LV: order by ea.bAnswered, WB: and ( ea.tiStype is null	or	ea.tiStype < 16 )
--			+ and ea.tiShelf > 0
--			+ (nolock), MapView
--	v.6.04
alter proc		dbo.prRoomBed_GetByUnit
(
--	@idUnit		smallint			-- unit FK
	@sUnits		varchar( 255 )		-- comma-separated idUnit's
,	@tiView		tinyint				-- 0=ListView, 1=WhiteBoard, 2=MapView
,	@tiShelf	tinyint				-- 0=all calls, 4=code shelf only
)
	with encryption
as
begin
--	declare		@i			smallint
	declare		@s			varchar( 400 )
--	declare		@idUnit		smallint			-- unit FK
--	declare		@idShift	smallint
	declare		@siIdx		smallint
--	declare		@tNow		time( 0 )

	set	nocount on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint not null			-- unit look-up FK
	,	sUnit		varchar( 16 ) not null		-- unit name
--	,	idShift		smallint null				-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)

	if	@sUnits = '*'	or	@sUnits is null
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
			select	idUnit, sUnit
				from	tbUnit	with (nolock)
				where	bActive > 0		and		idShift > 0
				and		idUnit in (' + @sUnits + ')'
		exec( @s )
	end
--	select	*	from	#tbUnit

	if	@tiShelf > 0
		select	@siIdx=	min(idIdx)
			from	tbDefCallP
			where	tiShelf = @tiShelf
	else
		select	@siIdx=	0

	set	nocount off
	if	@tiView = 0			--	ListView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
--			,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
			,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	cast(null as tinyint) [tiMap]
			from	vwEvent_A				ea	with (nolock)
				inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = ea.idUnit
				left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
				left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
				left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	ea.siIdx >= @siIdx
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed	--	not ea.idEvent because the call may have started earlier than it was 1st recorded!

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
--			,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
			,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	cast(null as tinyint) [tiMap]
			from	vwRoomBed				rb	with (nolock)
				inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left outer join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0	and	ea.tiShelf > 0
				left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
				left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	rb.idUnit is not null
	--?			and	( ea.tiStype is null	or	ea.tiStype < 16 )
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	cast(null as int) [idPatient], cast(null as varchar(16)) [sPatient], cast(null as char(1)) [cGender]
				,	cast(null as varchar(16)) [sInfo], cast(null as varchar(255)) [sNote], cast(null as int) [idDoctor], cast(null as varchar(16)) [sDoctor]
--			,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
			,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	mc.tiMap
			from	#tbUnit					tu	with (nolock)
				outer apply	fnEventA_GetTopByUnit( tu.idUnit )	ea
				left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
				outer apply	fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
	--			left outer join	tbUnitMapCell	mc	with (nolock)
	--				on	mc.idUnit = tu.idUnit	and	mc.cSys = ea.cSys	and	mc.tiGID = ea.tiGID	and	mc.tiJID = ea.tiJID
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
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
--		,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
		,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
		,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
		,	mc.tiMap, mc.tiCell, mc.sCell1, mc.sCell2, r.siBeds, r.sBeds
		from	tbUnitMapCell			mc	with (nolock)
	---		inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = mc.idUnit
			inner join	tbUnit			u	with (nolock)	on	u.idUnit = mc.idUnit
			left outer join	tbDevice	r	with (nolock)
				on	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0		and	r.bActive > 0
			outer apply	fnEventA_GetTopByRoom( mc.cSys, mc.tiGID, mc.tiJID )	ea
			left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
			left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
			left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		where	mc.idUnit = @idUnit
			and	mc.tiMap = @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go


if	exists	( select 1 from tb_Version where idVersion = 701 )
	update	dbo.tb_Version	set	dtCreated= '2012-12-21', siBuild= 4738, dtInstall= getdate( )
		,	sVersion= '7.01.4738 - rooms w/o beds, assigned staff'
		where	idVersion = 701
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 701,	4738, '2012-12-21', getdate( ),	'7.01.4738 - rooms w/o beds, assigned staff' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.1.4738'
	where	idModule = 1
go

checkpoint
go

use [master]
go
