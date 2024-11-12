--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2019-Jan-14		.6953
--						* pr_Version_GetAll, prRoomBed_GetByUnit
--						* prMapCell_GetByUnitMap
--		2019-Feb-04		.6974
--						* vwEvent_A, prEvent_A_Get
--		2019-Mar-29		.7027
--						* tb_Module:	+ .iPID		(pr_Module_Get, pr_Module_GetAll, pr_Module_Upd)
--		2019-Apr-01		.7030
--						- pr_Module_Get
--						+ pr_Module_GetLvl
--		2019-Jun-04		.7094
--						* pr_User_InsUpdAD
--		2019-Jun-11		.7101
--						release
--		2019-Jun-14		.7104
--						+ tb_LogType[83]
--						* tdCall_Enabled
--						* prCall_GetAll
--		2019-Jun-20		.7110
--						* pr_Module_SetLvl
--						+ clean up sessions
--		2019-Jun-21		.7111
--						release
--		2019-Jun-24		.7114
--						* pr_Module_SetLvl
--						* pr_Sess_Act
--		2019-Jun-25		.7115
--						* prStfLvl_Upd
--						* prEvent_SetGwState
--						* pr_User_Logout
--						* prDevice_GetIns
--		2019-Jun-27		.7117
--						* prEvent_Maint
--						* tb_User[4]:	'appuser' -> 'system'
--						* prCall_Upd, prRtlsRcvr_Init, prRtlsBadge_Init
--		2019-Jun-28		.7118
--						* pr_Module_Reg
--		2019-Jul-02		.7122
--						* tb_Module:	-[71]	+[94]
--		2019-Jul-03		.7123
--						* tb_LogType.tiLvl, .tiSrc -> .tiCat, -[51]		(pr_LogType_GetAll, pr_Log_Ins, pr_Log_Get)
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7123 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7123', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_GetLvl')
	drop proc	dbo.pr_Module_GetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Get')
	drop proc	dbo.pr_Module_Get
go
--	----------------------------------------------------------------------------
--	Returns installation history
--	7.06.6953	* removed 'db7983.' from object refs
--	7.06.6509
alter proc		dbo.pr_Version_GetAll
--(
--	@bActive	bit		=	0		-- 0=by name, 1=by avg-frag desc
--)
	with encryption
as
begin
	select	idVersion, v.siBuild, dtCreated, v.dtInstall, sVersion
		,	isnull( i.siBuild, 0 )	as	miBuild
		from	dbo.tb_Version	v	with (nolock)
		left join	(select		dtInstall,	max(siBuild)	as	siBuild
						from	dbo.tb_Version	with (nolock)
						group	by	dtInstall)	i	on	i.siBuild = v.siBuild
		order	by	2	desc
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985
--	7.06.6953	* removed 'db7983.' from object refs
--				* added 'dbo.' to object refs
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
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
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
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )			--	7.03
				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed desc		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	rb.idRoom, rb.sQnDevice	as	sRoom,	rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
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
				outer apply	dbo.fnEventA_GetTopByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster, 0 )	ea		--	7.03
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 8 )	p8
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 4 )	p4
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 2 )	p2
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 1 )	p1
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
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
				outer apply	dbo.fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea									--	7.03
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
				outer apply	dbo.fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
			order	by	tu.sUnit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	7.06.6953	* added 'dbo.' to function refs
--	7.06.6192	+ tiDome8, tiDome4, tiDome2, tiDome1:	has to match prRoomBed_GetByUnit!!
--	7.05.5940	* fix: room-level calls didn't show assigned staff
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
		,	r.idDevice as idRoom,	r.sQnDevice as sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
		,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
		,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
		,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
		,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
		,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
		,	mc.tiMap
		,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
		,	mc.tiCell, mc.sCell1, mc.sCell2, r.siBeds, r.sBeds	-- rr.siBeds, rr.sBeds
		,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	tbUnitMapCell	mc	with (nolock)
			join	tbUnit		u	with (nolock)	on	u.idUnit = mc.idUnit
			left join	vwRoom	r	with (nolock)
				on	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0		and	r.bActive > 0
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
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
--	7.06.5386	* sGJRB '-' -> ' :'
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
	,	sd.idDevice, sd.sDevice, sd.sQnDevice, sd.tiStype, sd.sSGJR + ' :' + right('0' + cast(ea.tiBtn as varchar), 2)	as	sSGJRB
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
--	Returns notifiable active call properties
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
		,	siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, bActive, bAnswered, tElapsed	--, tiSvc
		,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
		and		(idEvent = @idEvent		or	@idEvent is null)
end
go
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'iPID')
begin
	begin tran
		alter table	dbo.tb_Module	add
			iPID		int				null		-- Windows PID when running

		update	dbo.tb_Module	set	tiLvl=	248		-- reset all to 'Trace'
	commit
end
go
/*
--	----------------------------------------------------------------------------
--	Returns given module's state
--	7.06.7027	+ .iPID
--	7.06.6555
alter proc		dbo.pr_Module_Get
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
--	set	nocount	on
	select	idModule, sModule, sDesc, bLicense, tiModType, tiLvl, sIpAddr, sMachine, sVersion, iPID, dtStart, sParams, dtLastAct
		,	case when sMachine is null then sIpAddr else sMachine end	as	sHost
		,	datediff( ss, dtLastAct, getdate( ) )						as	siElapsed
		,	cast( getdate( ) - dtStart as datetime )					as	dtRunTime
		from	tb_Module	with (nolock)
		where	idModule = @idModule
end
*/
go
--	----------------------------------------------------------------------------
--	Returns modules state
--	7.06.7027	+ .iPID
--	7.06.6284	+ .tiLvl
--	7.06.5785	* .tRunTime -> .dtRunTime
--	7.06.5777	+ .tRunTime
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
	select	idModule, sModule, sDesc, bLicense, tiModType, tiLvl, sIpAddr, sMachine, sVersion, iPID, dtStart, sParams, dtLastAct
		,	case when sMachine is null then sIpAddr else sMachine end	as	sHost
		,	datediff( ss, dtLastAct, getdate( ) )						as	siElapsed
		,	cast( getdate( ) - dtStart as datetime )					as	dtRunTime
		from	tb_Module	with (nolock)
		where	(@bInstall = 0	or	sIpAddr is not null  or  sMachine is not null)
		and		(@bActive = 0	or	dtStart is not null)
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
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
,	@sInfo		varchar( 32 )		-- module info, gets logged (e.g. 'J79???? v.M.mm.bbbb @machine/IP-address')
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
--	Returns given module's logging level
--	7.06.7030
create proc		dbo.pr_Module_GetLvl
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
--	set	nocount	on
	select	tiLvl
		from	tb_Module	with (nolock)
		where	idModule = @idModule
end
go
grant	execute				on dbo.pr_Module_GetLvl				to [rWriter]
grant	execute				on dbo.pr_Module_GetLvl				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
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

				select	@s =	'User_IAD( ' + @s + ' ) = ' + cast(@idOper as varchar)
					,	@k =	237
			end
			else															--	7.06.7094
				select	@s =	'User_IAD( ' + @s + ' ) ^'
					,	@k =	2											-- info
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

		if	2 < @k															--	7.06.7094	only import *active* users!
			-- enforce membership in 'Public' role
			if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
				insert	tb_UserRole	( idRole, idUser )
						values		( 1, @idOper )

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7104	+ [83]
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 83)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 83,  4, 16, 'Disconnected' )			--	7.06.7104
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7104	* tdCall_Enabled: 1 -> 0
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdCall_Enabled')
begin
	begin tran
		alter table	dbo.tbCall	drop constraint tdCall_Enabled

		alter table	dbo.tbCall	add
			constraint	tdCall_Enabled	default( 0 )	for	bEnabled
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
--	7.06.7104	+ , c.idCall desc
--	7.06.6400	+ @tiLvl
--	7.06.6397	* @bVisible now controls order-by
--	7.06.5373	+ p.tiSpec, p.tiShelf
--	7.05.5085	+ @bVisible
--	7.04.4913	+ @bEnabled
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefCallP -> tbCfgPri
alter proc		dbo.prCall_GetAll
(
	@bVisible	bit					-- 0=order by siIdx, 1=order by idCall
,	@bEnabled	bit					-- 0=any, 1=only enabled for reporting
,	@bActive	bit			= 1		-- null=any, 0=inactive, 1=active
,	@tiLvl		tinyint		= null	-- null=any, 0=Only Non-Clinic, 1=Only Clinic (any of 1=Clinic-None, 2=Clinic-Patient, 3=Clinic-Staff, 4=Clinic-Doctor)
)
	with encryption
as
begin
--	set	nocount	on
	if	@bVisible > 0
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, p.tiShelf, p.tiLvl, p.tiSpec, p.iColorF, p.iColorB, c.bActive, c.dtCreated, c.dtUpdated
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx	--	p.sCall = c.sCall	and
			where	(@bActive is null	or	c.bActive = @bActive)
			and		(@tiLvl is null		or	@tiLvl = 0	and	p.tiLvl = 0		or	p.tiLvl > 0)
		--	and		p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)		--	"medical" calls
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.idCall
	else
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, p.tiShelf, p.tiLvl, p.tiSpec, p.iColorF, p.iColorB, c.bActive, c.dtCreated, c.dtUpdated
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx	--	p.sCall = c.sCall	and
			where	(@bActive is null	or	c.bActive = @bActive)
			and		(@tiLvl is null		or	@tiLvl = 0	and	p.tiLvl = 0		or	p.tiLvl > 0)
		--	and		p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.siIdx	desc,	c.idCall	desc					-- 7.06.7104
end
go
--	----------------------------------------------------------------------------
--	7.06.7110	clean up sessions
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
--	Sets given module's logging level
--	7.06.7114	+ @idFeature
--	7.06.7110	* log
--	7.06.6284
alter proc		dbo.pr_Module_SetLvl
(
	@idModule	tinyint				-- module id
,	@tiLvl		tinyint				-- bitwise tb_LogType.tiLvl, 0xFF=include all
,	@idUser		int
,	@idFeature	tinyint				-- module id (from where the edit is made)
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	begin	tran
		update	tb_Module		set	tiLvl=	@tiLvl,		@s=	sModule
			where	idModule = @idModule

		select	@s= 'Mod_SL( ' + right('00' + cast(@idModule as varchar), 3) + '::' + @s + ', l=' + isnull(cast(@tiLvl as varchar), '?') + ' )'

		exec	dbo.pr_Log_Ins	64, @idUser, null, @s, @idFeature
	commit
end
go
--	----------------------------------------------------------------------------
--	Marks a session with latest activity
--	7.06.7114	+ @idModule
--	7.05.5044	* @idUser: smallint -> int
--	7.03	+ pr_Module_Act 63 call
--	7.00	+ pr_Module_Act 92 call
--	6.00	prRptSess_Act -> pr_Sess_Act, revised
--	5.01	encryption added
--			fix for @idRptSess retrieval
--	4.02	+ @sSessID for session recovery
--	3.01
alter proc		dbo.pr_Sess_Act
(
	@idModule	tinyint				-- module id
,	@sSessID	varchar( 32 )		-- IIS SessionID
,	@idSess		int				out
,	@idUser		int				out
)
	with encryption
as
begin

	set	nocount	on
	begin	tran

		exec	pr_Module_Act	1
		exec	pr_Module_Act	@idModule

		if	@idSess > 0
			update	dbo.tb_Sess		set	dtLastAct=	getdate( ),		@idUser =	idUser
				where	idSess = @idSess
		else
			update	dbo.tb_Sess		set	dtLastAct=	getdate( ),		@idUser =	idUser,		@idSess =	idSess
				where	sSessID = @sSessID

		if	@idUser > 0
			update	dbo.tb_User		set	dtLastAct=	getdate( )
				where	idUser = @idUser
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a staff level
--	7.06.7115	* optimized logging (color in hex)
--	7.05.5219
alter proc		dbo.prStfLvl_Upd
(
	@idStfLvl	tinyint
,	@sStfLvl	varchar( 16 )
,	@iColorB	int
,	@idUser		int
)
	with encryption, exec as owner
as
begin
	declare		@s	varchar( 255 )

	set	nocount	on

	select	@s= 'StfLvl_U( [' + isnull(cast(@idStfLvl as varchar), '?') + '], n="' + @sStfLvl + '", k=0x' + isnull(convert(varchar, convert(varbinary(4), @iColorB), 1), '?') + ' )'

	begin	tran

		update	tbStfLvl	set	sStfLvl =	@sStfLvl,	iColorB =	@iColorB	--,	dtUpdated=	getdate( )
			where	idStfLvl = @idStfLvl

		exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Marks a gateway as found or lost (and removes its active calls)
--	7.06.7115	+ @idModule
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
,	@idModule	tinyint				-- module id
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

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
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

			select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ') ' + isnull(convert(varchar, @dtCreated, 121), '?')

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit
		,		@sD			varchar( 16 )
		,		@iA			int

	set	nocount	on

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	if	charindex('SIP:', @sDevice) = 1										-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a=' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ' )'

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


	if	@idDevice > 0																			--	7.06.5560
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		select	@sD =	sDevice,	@iA =	iAID												--	7.06.6758
			from	tbDevice
			where	idDevice = @idDevice

		if	@tiRID = 0	and	@sD <> @sDevice
			select	@s =	@s + ' ^N:"' + @sD + '"'

		if	@iA <> @iAID
			select	@s =	@s + ' ^A:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

		if	@tiRID = 0	and	@sD <> @sDevice		or	@iAID <> 0	and	@iA <> @iAID
			exec	dbo.pr_Log_Ins	82, null, null, @s

		return	0															-- match found
	end

	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	begin
		begin	tran

			if	charindex(@cSys, @sSysts) = 0								-- not in Allowed Systems
			begin
				select	@s =	@s + ' !cSys'
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
					select	@s =	@s + ' id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
					exec	dbo.pr_Log_Ins	74, null, null, @s
				end
			end

		commit
	end
	else																	-- no name / system		7.06.5560
	begin
		select	@s =	@s + ' !sDvc'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.7117	* optimized logging (- 23:59:59.990)
--	7.06.6022	* tb_Module[1].sParams updtate -> prStfCvrg_InsFin
--	7.06.5648	* fix for updating tb_OptSys[19].iValue
--	7.06.5638	* fix for updating tbEvent_C.idEvt??
--	7.06.5618	* fix for no tbEvent_S records (e.g. recent install + 7980)
--	7.06.5562	* tbEvent: .vbCmd -> tbEvent_B, .tiLen -> tbEvent_B
--	7.06.5490	* 'dat:','log:' -> 'D:','L:'
--	7.05.5169	* wipe tbEvent.vbCmd for events older than 60 days
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ reporting DB sizes in tb_Module[1].sParams
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prEvent_Maint
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@dt			datetime
		,		@idEvent	int
		,		@iCount		int
		,		@tiPurge	tinyint			-- FF=keep everything
											-- N=remove auxiliary data older than N days (cascaded)
											-- 0=remove all inactive events from [tbEvent*] (cascaded)
	set	nocount	on

	select	@dt =	getdate( )												-- smalldatetime truncates seconds

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	ec	set	ec.idEvtVo =	null						-- implements CASCADE SET NULL
					from	tbEvent_C ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtVo
					where	a.idEvent is null

				update	ec	set	ec.idEvtSt =	null
					from	tbEvent_C ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtSt
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left join	tbEvent_A	a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@iCount =	@@rowcount

				if	0 < @iCount
				begin
					select	@s =	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) -' + cast(@iCount as varchar) +
									' in ' + convert(varchar, getdate() - @dt, 114)
					exec	dbo.pr_Log_Ins	2, null, null, @s
				end
			end

			select	@idEvent =	max(idEvent)								-- get latest idEvent to be removed
				from	tbEvent_S
				where	dEvent <= dateadd(dd, -@tiPurge, @dt)
				and		tiHH <= datepart(hh, @dt)

			if	@idEvent is null											--	7.06.5618
				select	@idEvent =	min(idEvent)							-- get earliest idEvent to stay
					from	tbEvent_S
					where	dateadd(dd, -@tiPurge, @dt) < dEvent

			if	0 < @idEvent												--	7.06.5648
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
--	7.06.7117	* [4] 'appuser' -> 'system'
begin tran
	update	dbo.tb_User		set	sUser=	'_system_'			where	idUser <> 4	and	sUser = 'system'

	update	dbo.tb_User		set	sUser=	'system',	sFrst=	'System',	sLast=	'Internal',	sStaff =	'System User'
		where	idUser = 4
commit
go
--	----------------------------------------------------------------------------
--	Updates target times for a given call-priority
--	7.06.7117	+ @idModule
--	7.05.5044	* @idUser: smallint -> int
--	7.04.4902
alter proc		dbo.prCall_Upd
(
	@idCall		smallint
,	@bEnabled	bit
,	@tVoTrg		time( 0 )
,	@tStTrg		time( 0 )
,	@idUser		int
,	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	begin	tran
		update	tbCall	set	bEnabled =	@bEnabled,	tVoTrg =	@tVoTrg,	tStTrg =	@tStTrg,	dtUpdated=	getdate( )
			where	idCall = @idCall

		select	@s= 'Call_U( ' + isnull(cast(@idCall as varchar), '?') + ', e=' + isnull(cast(@bEnabled as varchar), '?') +
					', v=' + isnull(cast(@tVoTrg as varchar), '?') + ', s=' + isnull(cast(@tStTrg as varchar), '?') + ' )'
		exec	dbo.pr_Log_Ins	72, @idUser, null, @s, @idModule
	commit
end
go
--	----------------------------------------------------------------------------
--	Deactivates all receivers
--	7.06.7117	+ @idModule
--	7.05.5087
alter proc		dbo.prRtlsRcvr_Init
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		update	tbRtlsRcvr	set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1

		select	@s= 'Rcvr_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s, @idModule
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Deactivates all badges
--	7.06.7117	+ @idModule
--	7.05.5222	+ updating tbDvc.bActive
--	7.05.5087
alter proc		dbo.prRtlsBadge_Init
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		update	tbRtlsBadge	set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1

		update	d			set	bActive= 0, dtUpdated= getdate( )
			from	tbDvc	d
			join	tbRtlsBadge	b	on	b.idBadge = d.idDvc
			where	d.bActive = 1

		select	@s= 'Bdge_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	74, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
--	7.06.7118	* optimized logging (removal)
--	7.06.6345	+ @idModule logging (pr_Log_Ins call)
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

				select	@s= 'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', v=' + isnull(@sVersion, '?') + ' )'
					,	@idLogType =	62
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

			select	@s =	@s + ' +'
		end

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	App modules
--	7.06.7122	- [71]	+ [94]
if	not	exists	(select 1 from dbo.tb_Module where idModule = 94)
begin
	begin tran
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  94, 'J7983ds',	4,	248,	0,	'7983 Data Sync Service' )				--	7.06.7122
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7123	* tb_LogType.tiLvl, .tiSrc -> .tiCat
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_LogType') and name = 'tiCat')
begin
	begin tran
		delete	from	dbo.tb_Log		where	idLogType = 51
		delete	from	dbo.tb_LogType	where	idLogType = 51

--		update	dbo.tb_LogType	set	tiLvl=	4		where	idLogType = 83		--	'Disconnected' should be an 'Info'

		update	dbo.tb_LogType	set	tiLvl=	128		where	tiLvl = 32
		update	dbo.tb_LogType	set	tiLvl=	64		where	tiLvl = 16
		update	dbo.tb_LogType	set	tiLvl=	32		where	tiLvl = 8
		update	dbo.tb_LogType	set	tiLvl=	16		where	tiLvl = 4
		update	dbo.tb_LogType	set	tiLvl=	8		where	tiLvl = 2
		update	dbo.tb_LogType	set	tiLvl=	4		where	tiLvl = 1

		exec sp_rename 'tb_LogType.tiSrc',		'tiCat',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns details for all log-types
--	7.06.7123	* tb_LogType.tiSrc -> .tiCat
--	7.06.6555
alter proc		dbo.pr_LogType_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLogType, tiLvl, tiCat, sLogType
		from	dbo.tb_LogType		with (nolock)
end
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
--	7.06.7123	* tb_LogType.tiSrc -> .tiCat
--	7.06.6498	+ .tLast, tiQty
--				* check @idLogType for .tiLvl (err/crit)
--	7.06.6304	- .idOper
--	7.06.6302	+ @idModule
--	7.05.5044	* @idUser: smallint -> int
--	6.05	tb_Log.sLog widened to [512]
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.00
alter proc		dbo.pr_Log_Ins
(
	@idLogType	tinyint
,	@idUser		int						--	context user
,	@idOper		int						--	"operand" user - ignored now
,	@sLog		varchar( 512 )
,	@idModule	tinyint			=	1	--	default is J798?db
--,	@idLog		int out
)
	with encryption
as
begin
	declare		@dt			datetime
			,	@hh			tinyint
			,	@tiLvl		tinyint
			,	@tiCat		tinyint
			,	@idLog		int
			,	@idOrg		int

	set	nocount	on

	select	@tiLvl =	tiLvl,	@tiCat =	tiCat,		@dt =	getdate( ),		@hh =	datepart( hh, getdate( ) )
		from	tb_LogType	with (nolock)
		where	idLogType = @idLogType

--	set	nocount	off

	if	@tiLvl & 0xC0 > 0													-- err (64) + crit (128)
	begin
		select	@idOrg =	idLog											-- get 1st event of the hour
			from	tb_Log_S	with (nolock)
			where	dLog = cast(@dt as date)	and	tiHH = @hh

		if	@idOrg > 0
			select	@idLog =	idLog										-- find 1st occurence of "sLog"
				from	tb_Log		with (nolock)
				where	idLog >= @idOrg
				and		sLog = @sLog
	end

	begin	tran

		if	@tiLvl & 0xC0 > 0	and
			@idLog > 0														-- same crit/err already happened
			update	tb_Log	set	tLast=	@dt
							,	tiQty=	case when tiQty < 255 then tiQty + 1 else tiQty end
				where	idLog = @idLog
		else
		begin
				insert	tb_Log	(  idLogType,  idModule,  idUser,  sLog,	dtLog,	dLog,	tLog,	tiHH,	tLast,	tiQty )
						values	( @idLogType, @idModule, @idUser, @sLog,	@dt,	@dt,	@dt,	@hh,	@dt,	1 )
				select	@idLog =	scope_identity( )

				select	@idOrg =	null									-- update event statistics
				select	@idOrg =	idLog
					from	tb_Log_S	with (nolock)
					where	dLog = cast(@dt as date)	and	tiHH = @hh

				if	@idOrg	is null
					insert	tb_Log_S	( dLog,	tiHH, idLog )
							values		( @dt,	@hh, @idLog )
		end

		if	@tiLvl & 0x80 > 0												-- increment criticals
			update	tb_Log_S	set	siCrt=	siCrt + 1
				where	dLog = cast(@dt as date)	and	tiHH = @hh

		if	@tiLvl & 0x40 > 0												-- increment errors
			update	tb_Log_S	set	siErr=	siErr + 1
				where	dLog = cast(@dt as date)	and	tiHH = @hh

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns activity log entries in a page of given size
--	7.06.7123	* tb_LogType.tiSrc -> .tiCat
--	7.06.6534	* modified for null args
--	7.06.6533	+ @bGroup
--	7.06.6526	* tb_SessLog -> tb_SessMod
--				+ @dFrom, @dUpto, @tFrom, @tUpto
--	7.06.6311	+ #pages filtered by @idSess
--	7.06.6306	+ .idModule, .sModule
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
,	@tiCat		tinyint				-- bitwise tb_LogType.tiCat, 0xFF=include all
,	@iPages		int				out	-- total # of pages
,	@idSess		int			=	0	-- when not 0 filter sources using tb_SessLog
,	@dFrom		datetime	=	null	-- 
,	@dUpto		datetime	=	null	-- 
,	@tFrom		tinyint		=	null	-- 
,	@tUpto		tinyint		=	null	-- 
,	@bGroup		bit			=	0	-- 0=paged log, 1=stat summary
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@idLog		int

	set	nocount	on

	exec	dbo.pr_Log_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	select	@iIndex =	@iIndex * @iCount + 1		-- index of the 1st output row

	if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
		if	@idSess = 0
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log	with (nolock)
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log	with (nolock)
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				order	by	idLog desc
		end
		else										-- filter by source
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log		l	with (nolock)
				join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log		l	with (nolock)
				join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				order	by	idLog desc
		end
	else											-- filter by level or category
		if	@idSess = 0
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log l	with (nolock)
				join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				and		t.tiLvl & @tiLvl > 0
				and		t.tiCat & @tiCat > 0

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log l	with (nolock)
				join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				and		t.tiLvl & @tiLvl > 0
				and		t.tiCat & @tiCat > 0
				order	by	idLog desc
		end
		else										-- filter by source
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log		l	with (nolock)
				join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on	t.idLogType = l.idLogType
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				and		t.tiLvl & @tiLvl > 0
				and		t.tiCat & @tiCat > 0

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log		l	with (nolock)
				join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on	t.idLogType = l.idLogType
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				and		t.tiLvl & @tiLvl > 0
				and		t.tiCat & @tiCat > 0
				order	by	idLog desc
		end

	set	rowcount	@iCount
	set	nocount	off

	if	@bGroup = 0
		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and	@idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					order	by 1 desc
			else										-- filter by source
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					order	by 1 desc
		else											-- filter by level or category
			if	@idSess = 0
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by 1 desc
			else										-- filter by source
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by 1 desc

	set	rowcount	0

	if	@bGroup > 0
		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and	@iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					group	by	l.idLogType
					order	by	lQty	desc
			else										-- filter by source
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					group	by	l.idLogType
					order	by	lQty	desc
		else											-- filter by level or category
			if	@idSess = 0
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					group	by	l.idLogType
					order	by	lQty	desc
			else										-- filter by source
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					group	by	l.idLogType
					order	by	lQty	desc
end
go

begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7123 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7123, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2019-07-03',	dtInstall=	getdate( )
		,	sVersion =	'*7980ns, *7987ca, *798?rh, *7983ls, *798?cs, +7983ds'
		where	siBuild = 7123

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7123'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.7123 )'
commit
go

checkpoint
go

use [master]
go