--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2023-May-30		.8550
--						* prHealth_Table, prHealth_Index
--		2023-Jun-09		.8560
--						* prRoomBed_GetByUnit, prMapCell_GetByMap
--		2023-Jun-22		.8573
--						+ tb_Module[ 21 ]	'7976 EMR Interface Service'
--						+ tb_Module[ 22 ]	'7976 EMR Interface Configurator'
--		2023-Jul-05		.8586
--						+ tbHlCall, prHlCall_GetAll, prHlCall_Upd
--						+ tbHlRoomBed, prHlRoomBed_GetAll, prHlRoomBed_Upd
--		2023-Jul-07		.8588
--						+ tb_Option[41..49], tb_OptSys[41..49]
--		2023-Jul-10		.8591
--						* prCfgDvc_UpdRmBd
--		2023-Jul-14		.8595
--						* tbPatient:	+ .sIdent, .sPatId, .sLast, .sFrst, sMidd	()
--						+ prHlEvent_Get
--		2023-Aug-30		.8642
--						+ xuPatient_PatId
--		2023-Sep-11		.8654
--						* finalized
--		2023-Sep-13		.8656
--						* fix for missing	.8147	2022-Apr-22
--							+ added 7970 tables (for single-DB scenario)
--		2023-Sep-13		.8658
--						* finalized
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 8658 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.8658', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHlEvent_Get')
	drop proc	dbo.prHlEvent_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHlRoomBed_Upd')
	drop proc	dbo.prHlRoomBed_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHlRoomBed_GetAll')
	drop proc	dbo.prHlRoomBed_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHlCall_Upd')
	drop proc	dbo.prHlCall_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHlCall_GetAll')
	drop proc	dbo.prHlCall_GetAll
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbHlRoomBed')
	drop table	dbo.tbHlRoomBed
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbHlCall')
	drop table	dbo.tbHlCall
go
--	----------------------------------------------------------------------------
--	Returns # of rows, data and index sizes for all tables in the DB
--	7.06.8550	* replaced "exec sp_msforeachtable 'sp_spaceused ''?'''" with a direct query
--	7.06.6502	+ @bActive
--	7.06.6499
alter proc		dbo.prHealth_Table
(
	@bActive	bit		=	0		-- 0=by name, 1=by size desc
)
	with encryption
as
begin
	set	nocount	on

	create table	#tb
	(
		object_id	int			not null	primary key nonclustered
,		sSchema		sysname		not null
,		sTable		sysname		not null
--,		index_id	int			null
--,		iIndex		int			null
--,		sIndex		sysname		null
,		lRows		bigint		not null
,		lTotal		bigint		not null
,		lUnused		bigint		not null
,		lData		bigint		not null
--,		lIndex		bigint		not null
	)

	set nocount off

	insert	#tb
		select	t.object_id,	min(s.name),	min(t.name)		--,	null, null, null,			--,	i.object_id, i.index_id, i.name
			,		sum(case when i.index_id > 1 then 0 else p.rows end)						--	lRows
			,	8 * sum(a.total_pages)															--	lTotal,	sum(a.used_pages),	lUsed
			,	8 * sum(case when i.index_id > 1 then 0 else a.total_pages - a.used_pages end)	--	lUnused
			,	8 * sum(case when i.index_id > 1 then 0 else a.data_pages end)					--	lData
--			,		sum(case when i.index_id > 1 then a.total_pages else 0 end)					--	lIndex
			from	sys.objects t
			join	sys.schemas s			on	s.schema_id		= t.schema_id
			join	sys.indexes i			on	i.object_id		= t.object_id
			join	sys.partitions p		on	p.object_id		= i.object_id	and	p.index_id	= i.index_id
			join	sys.allocation_units a	on	a.container_id	= p.partition_id
			where	t.type = 'U'	and	t.object_id > 255	--	AND	i.index_id <= 1
			group	by	t.object_id		--,	s.name,	t.name,		i.object_id, i.index_id, i.name

	if	@bActive = 0
		select	sSchema, sTable,	lRows	--,	index_id	as	iIdx,	sIndex
			,	lTotal,	lUnused,	lData
			,	(lTotal - lUnused - lData)	as	lIndex
			from	#tb
			order	by	1, 2	--	sSchema, sTable
	else
		select	sSchema, sTable,	lRows	--,	index_id	as	iIdx,	sIndex
			,	lTotal,	lUnused,	lData
			,	(lTotal - lUnused - lData)	as	lIndex
			from	#tb
			order	by	4	desc	--	lTotal

--	drop table #tb
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985
--	7.06.8560	+ optimized
--	7.06.8469	+ .cRoom
--				* fnEventA_GetByMaster()
--	7.06.8448	* fnUnitMapCell_GetMap -> fnMapCell_GetMap
--	7.06.8440	* .sQnRoom -> .sRoom
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--				* tbCfgPri.tiLvl -> .siFlags
--	7.06.8314	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.8280	* correction for WB:	ea. -> rb.cSys, rb.tiGID, rb.tiJID, rb.tiRID
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
			,	ea.idRoom, ea.cRoom, ea.sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
			,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStfID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStfID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStfID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	rm.idUserG, rm.idStLvlG, rm.sStfIDG, rm.sStaffG, rm.bOnDutyG, rm.dtDueG
			,	rm.idUserO, rm.idStLvlO, rm.sStfIDO, rm.sStaffO, rm.bOnDutyO, rm.dtDueO
			,	rm.idUserY, rm.idStLvlY, rm.sStfIDY, rm.sStaffY, rm.bOnDutyY, rm.dtDueY
--			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
--			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
--			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
	--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
			from	vwEvent_A		ea	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = ea.idUnit
	--			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
				left join	vwRoom		rm	with (nolock)	on	rm.idDevice = ea.idRoom
	--		where	ea.bActive > 0	and	ea.tiShelf > 0	and	tiLvl & 0x80 = 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	siFlags & 0x0100 = 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )	--	7.06.8343	not Clinic
--				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
				and	dbo.fnEventA_GetByMaster( @idMaster, ea.idRoom, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed desc		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	rb.cSys, rb.tiGID, rb.tiJID, rb.tiRID, ea.tiBtn
			,	rb.idRoom, rb.cRoom, rb.sRoom,	rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
			,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStfID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStfID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStfID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	rm.idUserG, rm.idStLvlG, rm.sStfIDG, rm.sStaffG, rm.bOnDutyG, rm.dtDueG
			,	rm.idUserO, rm.idStLvlO, rm.sStfIDO, rm.sStaffO, rm.bOnDutyO, rm.dtDueO
			,	rm.idUserY, rm.idStLvlY, rm.sStfIDY, rm.sStaffY, rm.bOnDutyY, rm.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	p8.tiDome	as	tiDome8,	p4.tiDome	as	tiDome4,	p2.tiDome	as	tiDome2,	p1.tiDome	as	tiDome1
			from	vwRoomBed		rb	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left join	vwRoom	rm	with (nolock)	on	rm.idDevice = rb.idRoom
--				outer apply	dbo.fnEventA_GetTopByRoom(  rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster, 0 )	ea
				outer apply	dbo.fnEventA_GetTopByRoom(  rb.idRoom, rb.tiBed, @iFilter, @idMaster, 0 )	ea
--				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 8 )	p8
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 8 )	p8
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 4 )	p4
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 2 )	p2
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 1 )	p1
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.cRoom, ea.sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
			,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStfID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStfID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStfID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	rm.idUserG, rm.idStLvlG, rm.sStfIDG, rm.sStaffG, rm.bOnDutyG, rm.dtDueG
			,	rm.idUserO, rm.idStLvlO, rm.sStfIDO, rm.sStaffO, rm.bOnDutyO, rm.dtDueO
			,	rm.idUserY, rm.idStLvlY, rm.sStfIDY, rm.sStaffY, rm.bOnDutyY, rm.dtDueY
			,	mc.tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
			from	#tbUnit			tu	with (nolock)
				outer apply	dbo.fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )
				left join	vwRoom		rm	with (nolock)	on	rm.idDevice = ea.idRoom
				outer apply	dbo.fnMapCell_GetMap( tu.idUnit, ea.idRoom )	mc
--				outer apply	dbo.fnMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
			order	by	tu.sUnit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	7.06.8560	+ outer apply p1,p2,p4,p8 for dome-lights on 7985cw maps
--	7.06.8469	+ .cRoom
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--				- .cSys, - .tiGID, -.tiJID
--				* prMapCell_GetByUnitMap -> prMapCell_GetByMap
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--				* tbCfgPri.tiLvl -> .siFlags
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
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
alter proc		dbo.prMapCell_GetByMap
(
	@idUnit		smallint			-- unit FK
,	@tiMap		tinyint
,	@iFilter	int					-- filter mask
,	@idMaster	smallint			-- master console, null=global mode
)
	with encryption
as
begin
	select	mc.idUnit, u.sUnit,		rm.cSys, rm.tiGID, rm.tiJID, ea.tiRID, ea.tiBtn
		,	rm.idDevice as idRoom,	rm.cDevice as cRoom, rm.sDevice as sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
		,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idUser1, rb.idStLvl1, rb.sStfID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1		-- assigned staff
		,	rb.idUser2, rb.idStLvl2, rb.sStfID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
		,	rb.idUser3, rb.idStLvl3, rb.sStfID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
		,	rm.idUserG, rm.idStLvlG, rm.sStfIDG, rm.sStaffG, rm.bOnDutyG, rm.dtDueG		-- present staff
		,	rm.idUserO, rm.idStLvlO, rm.sStfIDO, rm.sStaffO, rm.bOnDutyO, rm.dtDueO
		,	rm.idUserY, rm.idStLvlY, rm.sStfIDY, rm.sStaffY, rm.bOnDutyY, rm.dtDueY
		,	mc.tiMap
--	-	,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
		,	p8.tiDome	as	tiDome8,	p4.tiDome	as	tiDome4,	p2.tiDome	as	tiDome2,	p1.tiDome	as	tiDome1
		,	mc.tiCell, mc.sCell1, mc.sCell2,	rm.siBeds, rm.sBeds,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	dbo.tbMapCell	mc	with (nolock)
			join	dbo.tbUnit	u	with (nolock)	on	u.idUnit = mc.idUnit
			left join	dbo.vwRoom		rm	with (nolock)	on	rm.bActive > 0	and	rm.idDevice = mc.idRoom
			outer apply	dbo.fnEventA_GetTopByRoom( mc.idRoom, null, @iFilter, @idMaster, 1 )	ea		--	7.03
			left join	dbo.vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom
														and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF				--	and	ea.tiBed is null
															or	ea.tiBed is null	and	rb.tiBed in					--	7.06.5940
																	(select min(tiBed) from dbo.tbRoomBed with (nolock) where idRoom = ea.idRoom))
			outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 8 )	p8
			outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 4 )	p4
			outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 2 )	p2
			outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 1 )	p1
		where	mc.idUnit	= @idUnit
		and		mc.tiMap	= @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go
--	----------------------------------------------------------------------------
--	7.06.8573	+ [21,22]
begin tran
	update	dbo.tb_Module	set	sModule =	'J7976is',	tiModType=	4,	sDesc=	'7976 EMR Interface Service'
		where	idModule = 21
--	if	not exists	(select 1 from dbo.tb_Module where idModule = 21)
	if	@@rowcount = 0
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  21, 'J7976is',	4,	248,	0,	'7976 EMR Interface Service' )

	update	dbo.tb_Module	set	sModule =	'J7976cw',	tiModType=	2,	sDesc=	'7976 EMR Interface Configurator'
		where	idModule = 22
--	if	not exists	(select 1 from dbo.tb_Module where idModule = 22)
	if	@@rowcount = 0
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  22, 'J7976cw',	2,	248,	0,	'7977 EMR Interface Configurator' )
commit
go
--	----------------------------------------------------------------------------
--	7.06.8588	+ [41..49]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 41)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 41,  56, 'EMR retry send interval, s' )				--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 42, 167, 'HL7 version' )								--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 43, 167, 'HL7 message delimiters' )					--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 44, 167, 'HL7 message envelope - beg' )				--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 45, 167, 'HL7 message envelope - end' )				--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 46, 167, 'HL7 sending app' )							--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 47, 167, 'HL7 sending facility' )						--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 48, 167, 'HL7 receiving app' )						--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 49, 167, 'HL7 receiving facility' )					--	7.06.8588

		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 41, 5 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 42, '2.6' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 43, '|^~\&' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 44, '0B' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 45, '1C0D' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 46, 'JERON_PROVIDER^020B3CFFFED56AA9^EUI-64' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 47, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 48, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 49, '' )
	end
commit
go
--	----------------------------------------------------------------------------
--	7.06.8595	+ .sIdent, .sLast, .sFrst
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbPatient') and name = 'sIdent')
begin
	begin tran
		alter table	dbo.tbPatient	add
			sIdent		varchar( 250 )	null		-- HL7 PID.3 - Patient Identifier List (required)
		,	sPatId		varchar( 15 )	null		-- HL7 PID.3.1 - Patient Identifier (required)
		,	sLast		varchar( 50 )	null		-- HL7 PID.5.1.1 - Surname (required)
		,	sFrst		varchar( 30 )	null		-- HL7 PID.5.2 - Given Name (optional)
		,	sMidd		varchar( 30 )	null		-- HL7 PID.5.3 - 2nd Given Name or Initial (optional)
	commit
end
go
--	----------------------------------------------------------------------------
--	Call-priorities, to be exported to HL7 
--	7.06.8586
create table	dbo.tbHlCall
(
	siIdx		smallint		not null	-- priority-index
		constraint	xpHlCall	primary key clustered

,	bSend		bit				null
		constraint	tdHlCall_Send		default( 0 )
,	sSend		varchar( 255 )	null

--,	bActive		bit				not null
--		constraint	tdHlCall_Active		default( 1 )
--,	dtCreated	smalldatetime	not null
--		constraint	tdHlCall_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdHlCall_Updated	default( getdate( ) )
)
go
grant	select, insert, update			on dbo.tbHlCall			to [rWriter]
grant	select							on dbo.tbHlCall			to [rReader]
go
--	initialize
begin
	declare	@siIdx		smallint

	select	@siIdx =	0
	while	@siIdx < 1024
	begin
		if	not	exists( select 1 from tbHlCall with (nolock) where siIdx = @siIdx )
			insert	tbHlCall	(  siIdx )
					values		( @siIdx )

		select	@siIdx =	@siIdx + 1
	end
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.8586
create proc		dbo.prHlCall_GetAll
(
	@siFlags	smallint	= null	-- null=any
)
	with encryption
as
begin
--	set	nocount	on
	select	cast(siFlags & 0x0002 as bit)	as	bActive
		,	p.siIdx, siFlags, tiShelf, tiColor, sCall	--, tiSpec, iFilter
		,	bSend, sSend, c.dtUpdated
		from	tbHlCall	c	with (nolock)
		join	tbCfgPri	p	with (nolock)	on	p.siIdx	= c.siIdx
		where	@siFlags is null	or	siFlags & @siFlags	= @siFlags
--		where	@bEnabled = 0	or	siFlags & 0x02 > 0
		order	by	p.siIdx desc
end
go
grant	execute				on dbo.prHlCall_GetAll				to [rWriter]
grant	execute				on dbo.prHlCall_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates an HL7 exported call-priority
--	7.06.8586
create proc		dbo.prHlCall_Upd
(
	@siIdx		smallint			-- call-index
,	@bSend		bit
,	@sSend		varchar( 255 )
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 300 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'HlC_U( ' + isnull(cast(@siIdx as varchar),'?') +
					'|' + isnull(cast(@bSend as varchar),'?') + ', ''' + isnull(@sSend,'?') + ''' )'

	begin	tran

		if	exists	(select 1 from tbHlCall where siIdx = @siIdx)
			update	tbHlCall	set		bSend =		@bSend,		sSend =		@sSend
				,	dtUpdated =	getdate( )
				where	siIdx = @siIdx

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
grant	execute				on dbo.prHlCall_Upd					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Room-beds, to be exported to HL7 
--	7.06.8586
create table	dbo.tbHlRoomBed
(
	idRoom		smallint		not null	-- device look-up FK
		constraint	fkHlRoomBed_Room		foreign key references	tbRoom
,	tiBed		tinyint			not null	-- bed index, 0xFF == no bed in room

,	bSend		bit				null
		constraint	tdHlRoomBed_Send	default( 0 )
,	sSend		varchar( 255 )	null

--,	bActive		bit				not null
--		constraint	tdHlRoomBed_Active	default( 1 )
--,	dtCreated	smalldatetime	not null
--		constraint	tdHlRoomBed_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdHlRoomBed_Updated	default( getdate( ) )

,	constraint	xpHlRoomBed	primary key clustered	( idRoom, tiBed )
--,	constraint	fkHlRoomBed_RoomBed	foreign key	( idRoom, tiBed )	references	tbRoomBed	on delete cascade
)
go
grant	select, insert, update			on dbo.tbHlRoomBed		to [rWriter]
grant	select							on dbo.tbHlRoomBed		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns room-beds, ordered to be loadable into a table
--	7.06.8586
create proc		dbo.prHlRoomBed_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	on
	select	r.bActive, sSGJ, sQnDvc as sRoom, b.cBed
		,	h.bSend, h.sSend
		,	r.dtUpdated
		,	rb.idRoom, rb.tiBed
		from	tbHlRoomBed	rb	with (nolock)
		join	vwRoom		r	with (nolock)	on	r.idDevice	= rb.idRoom
	left join	tbCfgBed	b	with (nolock)	on	b.tiBed		= rb.tiBed
	left join	tbHlRoomBed	h	with (nolock)	on	h.idRoom	= rb.idRoom		and	h.tiBed	= rb.tiBed
		where	(@bActive is null	or	r.bActive	= @bActive)
--		where	@bEnabled = 0	or	siFlags & 0x02 > 0
		order	by	sSGJ
end
go
grant	execute				on dbo.prHlRoomBed_GetAll			to [rWriter]
grant	execute				on dbo.prHlRoomBed_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates an HL7 exported room-bed
--	7.06.8586
create proc		dbo.prHlRoomBed_Upd
(
	@idRoom		smallint
,	@tiBed		tinyint
,	@bSend		bit
,	@sSend		varchar( 255 )
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 300 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'HlR_U( ' + isnull(cast(@idRoom as varchar),'?') + ':' + isnull(cast(@tiBed as varchar),'?') +
					'|' + isnull(cast(@bSend as varchar),'?') + ', ''' + isnull(@sSend,'?') + ''' )'

	begin	tran

		if	exists	(select 1 from tbHlRoomBed where idRoom = @idRoom and tiBed = @tiBed)
			update	tbHlRoomBed	set		bSend =		@bSend,		sSend =		@sSend
				,	dtUpdated =	getdate( )
				where	idRoom = @idRoom	and	tiBed = @tiBed
		else
			insert	tbHlRoomBed	(  idRoom,  tiBed,  bSend,  sSend )
					values		( @idRoom, @tiBed, @bSend, @sSend )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
grant	execute				on dbo.prHlRoomBed_Upd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
--	7.06.8591	+ tbHlRoomBed
--	7.06.8446	* prDevice_UpdRoomBeds -> prCfgDvc_UpdRmBd
--	7.06.7279	* optimized logging
--	7.06.7265	* optimized
--	7.06.7249	* inlined 'exec prRoom_UpdStaff' (it's changed logic is now causing loss of tbRoom.idUnit during config download)
--	7.06.6225	- tbRtlsRoom
--	7.06.5939	- tbRoomBed.cBed
--	7.06.5483	* prRoom_Upd -> prRoom_UpdStaff
--				* optimized
--	7.05.5212	* reset @sBeds to null when no beds are present
--	7.05.5098	+ tbRoom.tiSvc, tbRoomBed.tiSvc reset
--	7.05.5038	- prDevice_UpdRoomBeds7980
--	7.05.4976	* tbCfgBed:		.bInUse -> .bActive
--	7.04.4916	* ?StaffLvl -> ?StfLvl
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--				tbDefLoc -> tbCfgLoc
--	7.03	* modified primary/alternate unit selection
--			* call prDevice_UpdRoomBeds7980 1 always (not by tbRoomBed) to facilitate room-name changes
--			+ 7967-P detection and handling
--	7.02	* trace: 71 -> 75	+ tb_LogType: [75]
--			* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--			+ init tbRtlsRoom
--	7.01	* fix for rooms without beds
--	7.00	* prDevice_UpdRoomBeds7980: @tiBed -> @cBedIdx
--			+ set tbDefBed.bInUse
--			+ rooms without bed
--	6.05	+ init tbRoomStaff
--			+ (nolock)
--	6.04
alter proc		dbo.prCfgDvc_UpdRmBd
(
	@idRoom		smallint			-- room id
,	@siBeds		smallint			-- beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sBeds		varchar( 10 )
		,		@dtNow		datetime
		,		@cBed		char( 1 )
		,		@cBedIdx	char( 1 )
		,		@tiBed		tinyint
		,		@siMask		smallint
		,		@idUnitP	smallint
		,		@idUnitA	smallint
		,		@sRoom		varchar( 16 )
		,		@sDial		varchar( 16 )
		,		@idDevice	smallint
		,		@tiCA0		tinyint
		,		@tiCA1		tinyint
		,		@tiCA2		tinyint
		,		@tiCA3		tinyint
		,		@tiCA4		tinyint
		,		@tiCA5		tinyint
		,		@tiCA6		tinyint
		,		@tiCA7		tinyint

	set	nocount	on

---	if	not	exists	(select 1 from tbDevice with (nolock) where idDevice = @idRoom and cDevice='R' and bActive>0)
---	and	not	exists	(select 1 from tbDevice with (nolock) where idParent = @idRoom and cDevice='W' and bActive>0)	-- and tiStype=26 and tiRID=1
---		return	0					-- only do room-beds for rooms or 7967-Ps

	if	exists	(select 1 from dbo.tbDevice with (nolock) where bActive > 0		-- only do room-beds for active rooms or 7967-Ps
					and (	idDevice = @idRoom and cDevice = 'R'
						or	idParent = @idRoom and cDevice = 'W'))
	begin

		select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

		select	@sBeds =	'',		@tiBed =	1,	@siMask =	1,	@dtNow =	getdate( )

		-- primary coverage
		select	@tiCA0 =	tiPriCA0,	@tiCA1 =	tiPriCA1,	@tiCA2 =	tiPriCA2,	@tiCA3 =	tiPriCA3
			,	@tiCA4 =	tiPriCA4,	@tiCA5 =	tiPriCA5,	@tiCA6 =	tiPriCA6,	@tiCA7 =	tiPriCA7
			,	@sRoom =	sDevice,	@sDial =	sDial
			from	dbo.tbDevice	with (nolock)
			where	idDevice = @idRoom

		if	@tiCA0 = 0xFF	--or @tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
	--	or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
			select	top 1	@idUnitP =	idUnit			-- pick min unit
				from	dbo.tbUnit		with (nolock)
				order	by	idUnit
		else
			select	@idUnitP =	idParent				-- convert PriCA0 to its unit
				from	dbo.tbCfgLoc	with (nolock)
				where	idLoc = @tiCA0

		-- alternate coverage
		select	@tiCA0 =	tiAltCA0,	@tiCA1 =	tiAltCA1,	@tiCA2 =	tiAltCA2,	@tiCA3 =	tiAltCA3
			,	@tiCA4 =	tiAltCA4,	@tiCA5 =	tiAltCA5,	@tiCA6 =	tiAltCA6,	@tiCA7 =	tiAltCA7
			from	dbo.tbDevice	with (nolock)
			where	idDevice = @idRoom

		if	@tiCA0 = 0xFF	--or @tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
	--	or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
			select	top 1 @idUnitA =	idUnit			-- pick max unit
				from	dbo.tbUnit		with (nolock)
				order	by	idUnit	desc
		else
			select	@idUnitA =	idParent				-- convert AltCA0 to its unit
				from	dbo.tbCfgLoc	with (nolock)
				where	idLoc = @tiCA0


		select	@s =	'Dvc_URB( ' + isnull(cast(@idRoom as varchar), '?') + ' ''' + isnull(@sRoom, '?') + ''' #' + isnull(@sDial, '?') +
						' P=' + isnull(cast(@idUnitP as varchar), '?') + ' A=' + isnull(cast(@idUnitA as varchar), '?') +
						', 0x' + isnull(cast(cast(@siBeds as varbinary(2)) as varchar), '?') + ' )'

		begin	tran

		---	delete	from	tbRoomBed					-- NO: removes patient-to-bed assignments!!
		---		where	idRoom = @idRoom

			if	exists	(select 1 from tbRoom with (nolock) where idRoom = @idRoom)
				update	dbo.tbRoom	set	idUnit =	@idUnitP									--	7.06.7249
					where	idRoom = @idRoom
			else
				insert	dbo.tbRoom	( idRoom,  idUnit)		-- init staff placeholder for this room	v.7.02, v.7.03
						values	(@idRoom, @idUnitP)

			if	@siBeds = 0								-- no beds in this room
			begin
				--	remove combinations with beds
				delete	from	dbo.tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
					insert	dbo.tbRoomBed	(  idRoom, tiBed )
							values			( @idRoom, 0xFF )

				select	@sBeds =	null				--	7.05.5212
			end
			else										-- there are beds
			begin
				--	remove combination with no beds
				delete	from	dbo.tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF

				while	@siMask < 1024
				begin
					select	@cBedIdx =	cast(@tiBed as char(1))

					if	@siBeds & @siMask > 0			-- @tiBed is present in @idRoom
					begin
						update	dbo.tbCfgBed	set	bActive =	1,	dtUpdated=	@dtNow
							where	tiBed = @tiBed	and	bActive = 0

						select	@cBed=	cBed,	@sBeds =	@sBeds + cBed
							from	dbo.tbCfgBed	with (nolock)
							where	tiBed = @tiBed

						if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = @tiBed)
							insert	dbo.tbRoomBed	(  idRoom,  tiBed )
									values			( @idRoom, @tiBed )

						if	not exists	(select 1 from tbHlRoomBed where idRoom = @idRoom and tiBed = @tiBed)
							insert	dbo.tbHlRoomBed	(  idRoom,  tiBed )
									values			( @idRoom, @tiBed )
					end
					else								--	@tiBed is absent in @idRoom
						delete	from	dbo.tbRoomBed	where	idRoom = @idRoom	and	tiBed = @tiBed

					select	@siMask =	@siMask * 2
						,	@tiBed =	case when @tiBed < 9 then @tiBed + 1 else 0 end
				end
			end

			if	not exists	(select 1 from tbHlRoomBed where idRoom = @idRoom and tiBed = 0xFF)
				insert	dbo.tbHlRoomBed	(  idRoom, tiBed )
						values			( @idRoom, 0xFF )

			update	dbo.tbRoom		set	dtUpdated=	@dtNow,		tiSvc=	null,	siBeds =	@siBeds,	sBeds=	@sBeds
				where	idRoom = @idRoom
			update	dbo.tbRoomBed	set	dtUpdated=	@dtNow,		tiSvc=	null	--	7.05.5098
				where	idRoom = @idRoom
			update	dbo.tbHlRoomBed	set	dtUpdated=	@dtNow						--	7.06.8591
				where	idRoom = @idRoom


			--	loop through all active 7947 - 8-Input Bed Interfaces in that room and mark
			declare		cur		cursor fast_forward for
				select	idDevice, tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
					from	dbo.tbDevice	with (nolock)
					where	idParent = @idRoom	and	tiStype = 192	and	bActive > 0

			open	cur
			fetch next from	cur	into	@idDevice, @tiCA0, @tiCA1, @tiCA2, @tiCA3, @tiCA4, @tiCA5, @tiCA6, @tiCA7
			while	@@fetch_status = 0
			begin
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA0 & 0x0F	--	button 0's bed
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA1 & 0x0F	--	button 1's bed
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA2 & 0x0F	--	button 2's bed
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA3 & 0x0F	--	button 3's bed
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA4 & 0x0F	--	button 4's bed
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA5 & 0x0F	--	button 5's bed
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA6 & 0x0F	--	button 6's bed
				update	dbo.tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA7 & 0x0F	--	button 7's bed

				fetch next from	cur	into	@idDevice, @tiCA0, @tiCA1, @tiCA2, @tiCA3, @tiCA4, @tiCA5, @tiCA6, @tiCA7
			end
			close	cur
			deallocate	cur

			if	@tiLog & 0x02 > 0												--	Config?
	--		if	@tiLog & 0x04 > 0												--	Debug?
	--		if	@tiLog & 0x08 > 0												--	Trace?
				exec	dbo.pr_Log_Ins	75, null, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Returns all items necessary for HL7 export of an event
--	7.06.8595
create proc		dbo.prHlEvent_Get
(
	@idEvent	int
)
	with encryption
as
begin
--	set	nocount	on
	select	top	1	e.idEvent, e.dtEvent, e.idCall,	c.sCall		--, c.siIdx
		,	r.sSGJR + '-' + right('0' + cast(e.tiBtn as varchar), 2)				as	sSGJRB
		,	r.sDevice,	b.cBed
--		,	r.sDevice + case when ec.tiBed is null then '' else ':' + b.cBed end	as	sRmBd	--	cast(e.tiBed as char(1))
		,	hc.sSend,	hr.sSend	--,	ec.idRoom, ec.tiBed
		,	p.idPatient, p.sPatient, p.cGender,	p.sIdent, p.sPatId, p.sLast, p.sFrst, p.sMidd
		from	dbo.tbEvent		e	with (nolock)
		join	dbo.tbEvent_C	ec	with (nolock)	on	ec.idEvent	= e.idOrigin
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
		join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbHlCall	hc	with (nolock)	on	hc.siIdx	= c.siIdx		and	hc.bSend > 0
		join	dbo.vwRoom		r	with (nolock)	on	r.idDevice	= e.idRoom
		join	dbo.tbHlRoomBed	hr	with (nolock)	on	hr.idRoom	= e.idRoom		and	hr.bSend > 0
													and	( hr.tiBed	= e.tiBed		or	hr.tiBed = 255	and	e.tiBed is null )
	left join	dbo.tbRoomBed	rb	with (nolock)	on	rb.idRoom	= e.idRoom
													and	( rb.tiBed	= e.tiBed		or	rb.tiBed = 255	and	e.tiBed is null )
	left join	dbo.tbPatient	p	with (nolock)	on	p.idPatient	= rb.idPatient
		where	e.idOrigin = @idEvent
		order	by	1 desc
--		where	e.idEvent = @idEvent
--			and	hc.bSend > 0	and	hr.bSend > 0
end
go
grant	execute				on dbo.prHlEvent_Get				to [rWriter]
grant	execute				on dbo.prHlEvent_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8642	+ xuPatient_PatId
if	not	exists	(select 1 from dbo.sysindexes where name='xuPatient_PatId')
begin
	begin tran
		create unique nonclustered index	xuPatient_PatId	on dbo.tbPatient ( sPatId )			where	sPatId is not null		-- + 7.06.8642
	commit
end
go
--	----------------------------------------------------------------------------
--	fix for missing
--		2022-Apr-22		.8147
--						+ added 7970 tables (for single-DB scenario)
--	----------------------------------------------------------------------------
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkCfg')
begin
	exec( 'create table	dbo.tbTlkCfg
		(
			idCfg		smallint		not null
				constraint	xpTlkCfg	primary key clustered		--	7.06.5548

		,	dtUpdated	datetime		not null
		,	bSpeechEnabled	bit			not null
		,	sVoice		text			null
		,	iSpeed		smallint		null
		,	iVol		smallint		null
		,	sWaveDev	text			null
		,	iRlyDev		tinyint			not null
		,	sRly1Cfg	text			null
		,	sRly2Cfg	text			null
		,	sRly3Cfg	text			null
		,	sRly4Cfg	text			null
		,	sPrealert	text			null
		,	iAnnCount	tinyint			not null
		)' )
	exec( 'grant	select, insert, update, delete	on dbo.tbTlkCfg			to [rWriter]
		grant	select							on dbo.tbTlkCfg			to [rReader]' )
	exec( 'insert	dbo.tbTlkCfg	( idCfg, dtUpdated, bSpeechEnabled, iRlyDev, iAnnCount )
				values			( 0, getdate(), 0, 0, 0 )' )
end
go
--	----------------------------------------------------------------------------
--	7.06.5610	+ .iRepeatCancel
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkMsg')
begin
	exec( 'create table	dbo.tbTlkMsg
		(
			idMsg		smallint		not null
				constraint	xpTlkMsg	primary key clustered		--	7.06.5548

		,	sDesc		text			null
		,	sSay		text			null
		,	bWillSpeak	bit				not null
		,	iRepeat		tinyint			null
		,	iRepeatCancel	tinyint		null	-- Repeat announcement on cancel count
		)' )
	exec( 'grant	select, insert, update, delete	on dbo.tbTlkMsg			to [rWriter]
		grant	select							on dbo.tbTlkMsg			to [rReader]' )
	exec( 'insert	dbo.tbTlkMsg	( idMsg, sDesc, sSay, bWillSpeak, iRepeat )
				values			( 1, ''No Announcement'', null, 0, null )' )
end
go
--	----------------------------------------------------------------------------
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkArea')
begin
	exec( 'create table	dbo.tbTlkArea
		(
			idArea		smallint		not null
				constraint	xpTlkArea	primary key clustered		--	7.06.5548

		,	sDesc		text			null
		,	sSay		text			null
		,	bWillSpeak	bit				not null
		,	bRly01		bit				not null
		,	bRly02		bit				not null
		,	bRly03		bit				not null
		,	bRly04		bit				not null
		,	bRly05		bit				not null
		,	bRly06		bit				not null
		,	bRly07		bit				not null
		,	bRly08		bit				not null
		,	bRly09		bit				not null
		,	bRly10		bit				not null
		,	bRly11		bit				not null
		,	bRly12		bit				not null
		,	bRly13		bit				not null
		,	bRly14		bit				not null
		,	bRly15		bit				not null
		,	bRly16		bit				not null
		,	bRly17		bit				not null
		,	bRly18		bit				not null
		,	bRly19		bit				not null
		,	bRly20		bit				not null
		,	bRly21		bit				not null
		,	bRly22		bit				not null
		,	bRly23		bit				not null
		,	bRly24		bit				not null
		,	bRly25		bit				not null
		,	bRly26		bit				not null
		,	bRly27		bit				not null
		,	bRly28		bit				not null
		,	bRly29		bit				not null
		,	bRly30		bit				not null
		,	bRly31		bit				not null
		,	bRly32		bit				not null
		)' )
	exec( 'grant	select, insert, update, delete	on dbo.tbTlkArea			to [rWriter]
		grant	select							on dbo.tbTlkArea			to [rReader]' )
	exec( 'insert	dbo.tbTlkArea	( idArea, sDesc, sSay, bWillSpeak
								,	bRly01,bRly02,bRly03,bRly04,bRly05,bRly06,bRly07,bRly08,bRly09,bRly10,bRly11,bRly12,bRly13,bRly14,bRly15,bRly16
								,	bRly17,bRly18,bRly19,bRly20,bRly21,bRly22,bRly23,bRly24,bRly25,bRly26,bRly27,bRly28,bRly29,bRly30,bRly31,bRly32 )
				values			( 1, ''Default Area'', null, 1
								,	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
								,	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 )' )
end
go
--	----------------------------------------------------------------------------
--	7.06.5610	* .idRoom:	smallint -> int
--					(6892 support - more than 100 room/console controllers per gateway)
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkRooms')
begin
	exec( 'create table	tbTlkRooms
		(
			idRoom		int				not null
				constraint pkTlkRooms	primary key clustered
		--		constraint fkTlkRooms_Device foreign key references tbDevice	on delete cascade
		,	sDevice		text			null
		,	idMsg		smallint		not null
				constraint	fkTlkRooms_TlkMsg	foreign key references	tbTlkMsg
		,	idArea		smallint		not null
				constraint	fkTlkRooms_TlkArea	foreign key references	tbTlkArea
		,	sSay		text			null
		,	bWillSpeak	bit				not null
		)' )
	exec( 'grant	select, insert, update, delete	on dbo.tbTlkRooms			to [rWriter]
		grant	select							on dbo.tbTlkRooms			to [rReader]' )
end
go
--	----------------------------------------------------------------------------
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkCalls')
begin
	exec( 'create table	tbTlkCalls
		(
			idCall		smallint		not null
				constraint	pkTlkCalls	primary key clustered
		,	sCall		text			null
		,	sOnSay		text			null
		,	bOnWillSpeak	bit			not null
		,	sOffSay		text			null
		,	bOffWillSpeak	bit			not null
		,	bOverrides	bit				not null	-- Added message and area (to override room values, if desired) 8/30/2012 TH
		,	idMsg		smallint		not null
				constraint	fkTlkCalls_TlkMsg	foreign key references	tbTlkMsg
		,	idArea		smallint		not null
				constraint	fkTlkCalls_TlkArea	foreign key references	tbTlkArea
		)' )
	exec( 'grant	select, insert, update, delete	on dbo.tbTlkCalls			to [rWriter]
		grant	select							on dbo.tbTlkCalls			to [rReader]' )
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 8658 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8658, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2023-09-15',	sVersion =	'EMR integration: +7976is, +7976cw'
		where	siBuild = 8658

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.8658'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, '7.6.8658.00000, [{0}]'
commit
go

--	<100,tbEvent>
exec	sp_updatestats
go

checkpoint
go

checkpoint
go

use [master]
go