--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2022-Nov-04		.8343
--						* tbCfgPri.tiFlags -> .siFlags
--								(prCfgPri_GetAll, prCfgPri_InsUpd, prCall_SetTmpFlt, prCall_GetAll, prCall_Imp, vwEvent_A, prEvent_A_Get, fnEventA_GetTopByUnit, fnEventA_GetTopByRoom,
--								prEvent_Ins, prEvent84_Ins, prRouting_Get, prRoomBed_GetByUnit, prMapCell_GetByUnitMap)
--						- prCfgPri_SetLvl
--						- vwCall
--						* vwStaff.sStaffID -> sStfID
--								(prStaff_GetAll, prStaff_GetByUnit, vwDvc, pr_User_GetDvcs, prTeam_GetDvcs, vwRoom, vwRoomBed, vwEvent41, vwShift, prShift_GetAll, vwStfAssn, vwStfCvrg,
--								prStfAssn_GetByRoom, prStfAssn_Exp, prStfAssn_GetByUnit, vwRtlsBadge, prRoomBed_GetByUnit, prMapCell_GetByUnitMap, prRoomBed_GetAssn,
--								prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi, prRptStfAssn, prRptStfCvrg)
--						* vwRoom.idStfLvl? -> idStLvl?, sStaffID? -> sStfID?, idStfAssn? -> idStAsn?	(vwRoomBed, prStfAssn_GetByUnit)
--						* vwEvent_A.bAnswered, vwEvent84.bAnswered
--		2022-Nov-10		.8349
--						* prCfgLoc_Ins
--		2022-Nov-23		.8362
--						* prCfgPri_GetAll
--						* prCfgPri_InsUpd
--		2022-Nov-29		.8368
--						* prRptRndStatSum, prRptRndStatDtl
--						* prCall_Imp
--		2022-Dec-06		.8375
--						* prStaff_GetAll
--		2022-Dec-08		.8377
--						* prCall_Imp
--		2022-Dec-15		.8384
--						* prEvent_Ins, prEvent84_Ins
--		2022-Dec-16		.8385
--						* prRptCallActSum, prRptCallActDtl, prRptCallActExc, prRptRndStatSum, prRptRndStatDtl
--		2022-Dec-19		.8388
--						* prRptCallStatSum, prRptCallStatSumGraph
--						* prRptSysActDtl
--		2022-Dec-20		.8389
--						* prRptCliPatDtl, prRptCliStfDtl, prRptCliStfSum
--		2022-Dec-30		.8399
--						* tb_LogType.sLogType
--		2023-Jan-05		.8405
--						* prRptCallActExc, prRptStfCvrg
--						* prCall_GetIns
--		2023-Jan-09		.8409
--						* tbEvent84, prEvent8A_Ins
--						* tbEvent84: - siDuty?, siZone?		(vwEvent84)
--		2023-Jan-11		.8411
--						* prCall_Imp
--		2023-Jan-12		.8412
--						+ pr_Sess_Maint, * prEvent_Maint
--		2023-Jan-13		.8413
--						* pr_User_GetAll
--		2023-Jan-17		.8417
--						* tbReport[ 23 ]
--						* prEvent_A_Get
--		2023-Jan-26		.8426
--						* tbStfLvl[ 8 ]
--						* prStfCvrg_InsFin
--		2023-Jan-31		.8431
--						* tbDvc.tiFlags
--		2023-Feb-01		.8432
--						* tv_User_Duty
--						* pr_User_InsUpd, prStaff_SetDuty
--						* prDvc_RegWiFi
--						* pr_Role_InsUpd, prTeam_InsUpd, prDvc_InsUpd
--		2023-Feb-02		.8433
--						* prEvent41_Ins
--						* prCfgDvc_GetBtns
--		2023-Feb-03		.8434
--						* prRtlsBadge_InsUpd
--		2023-Feb-08		.8439
--						* vwEvent_A, prEvent_A_Get
--		2023-Feb-09		.8440
--						- pr_SessCall_Set
--						* prStfAssn_GetByUnit
--						* fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit
--		2023-Feb-13		.8444
--						* pr_Module_Reg
--						* prCfgLoc_SetLvl
--		2023-Feb-15		.8446
--						* tbCfgDvcBtn -> tbCfgBtn	(prCfgDvcBtn_Clr -> prCfgBtn_Clr, prCfgDvcBtn_Ins -> prCfgBtn_Ins)
--						* prDevice_UpdRoomBeds -> prCfgDvc_UpdRmBd
--		2023-Feb-17		.8448
--						* prTeam_GetByUnitPri -> prTeam_GetByCall
--						* prTeam_GetStaffOnDuty -> prTeam_GetStaff
--						* fnEventA_GetTopByRoom, fnEventA_GetDomeByRoom
--						* tbUnitMapCell -> tbMapCell	(prUnitMapCell_Upd -> prMapCell_Upd, prCfgLoc_SetLvl, prMapCell_GetByUnitMap -> prMapCell_GetByMap,
--															fnUnitMapCell_GetMap -> fnMapCell_GetMap [prRoomBed_GetByUnit], prCfgLoc_SetLvl)
--						- tbUnitMapCell.cSys, - .tiGID, -.tiJID
--						* prRptCallStatSumGraph -> prRptCallStatGfx
--		2023-Feb-21		.8452
--						* prMapCell_ClnUp
--		2023-Feb-27		.8458
--						* prRptSysActDtl
--		2023-Mar-07		.8466
--						* tbShift:	.tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode, vwShift, prShift_Exp, prShift_Imp, prShift_GetAll, prShift_InsUpd)
--		2023-Mar-09		.8468
--						* prRouting_Get
--		2023-Mar-10		.8469
--						* vwRoomBed, vwEvent_A
--						* fnEventA_GetTopByUnit, fnEventA_GetDomeByRoom, prRoomBed_GetByUnit, prMapCell_GetByMap
--						* fnEventA_GetByMaster
--						* prStfAssn_GetByUnit
--		2023-Mar-13		.8472
--						* pr_User_Logout
--		2023-Mar-16		.8475
--						* tbPcsType -> tbNtfType	(prEvent41_Ins, vwEvent41, prRptSysActDtl, prRptCallActDtl)
--		2023-Mar-21		.8480
--						* prCall_Imp
--		2023-Mar-29		.8488
--						* pr_User_InsUpd
--		2023-Mar-30		.8489
--						* prStaff_SetDuty
--		2023-Apr-10		.8500
--						* tbEvent_D:	- xtEventD_dEvent_tiHH	- .dEvent, tEvent	+ .idEvntP	(vwEvent_D, prEvent_Maint)
--						* prEvent_Ins, prEvent84_Ins
--						* prRptCliPatDtl, prRptCliStfDtl, prRptCliStfSum
--		2023-Apr-11		.8501
--						* prEvent_Maint
--		2023-Apr-12		.8502
--						* clean-up
--		2023-Apr-14		.8504
--						* prStfLvl_Upd
--		2023-Apr-18		.8508
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

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 8508 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.8508', 18, 0 )
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnUnitMapCell_GetMap')
	drop function	dbo.fnUnitMapCell_GetMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnMapCell_GetMap')
	drop function	dbo.fnMapCell_GetMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallStatSumGraph')
	drop proc	dbo.prRptCallStatSumGraph
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallStatGfx')
	drop proc	dbo.prRptCallStatGfx
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetByUnitMap')
	drop proc	dbo.prMapCell_GetByUnitMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetByMap')
	drop proc	dbo.prMapCell_GetByMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMapCell_Upd')
	drop proc	dbo.prUnitMapCell_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_Upd')
	drop proc	dbo.prMapCell_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_ClnUp')
	drop proc	dbo.prMapCell_ClnUp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetStaffOnDuty')
	drop proc	dbo.prTeam_GetStaffOnDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetStaff')
	drop proc	dbo.prTeam_GetStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetByUnitPri')
	drop proc	dbo.prTeam_GetByUnitPri
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetByCall')
	drop proc	dbo.prTeam_GetByCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_UpdRoomBeds')
	drop proc	dbo.prDevice_UpdRoomBeds
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_UpdRmBd')
	drop proc	dbo.prCfgDvc_UpdRmBd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessCall_Set')
	drop proc	dbo.pr_SessCall_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_Maint')
	drop proc	dbo.pr_Sess_Maint
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvcBtn_Clr')
	drop proc	dbo.prCfgDvcBtn_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvcBtn_Ins')
	drop proc	dbo.prCfgDvcBtn_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_GetBtns')
	drop proc	dbo.prCfgDvc_GetBtns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBtn_Clr')
	drop proc	dbo.prCfgBtn_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBtn_Ins')
	drop proc	dbo.prCfgBtn_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgDvcBtn')
	drop table	dbo.tbCfgDvcBtn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgBtn')
	drop table	dbo.tbCfgBtn
go
--	----------------------------------------------------------------------------
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'siFlags')
begin
	begin tran
		exec( '
		alter table	dbo.tbCfgPri		alter column
			tiFlags		smallint		not null

		update	dbo.tbCfgPri	set	tiFlags =	tiFlags |
									case	when tiLvl = 0x80		then	0x0100		--	80=Clinic-None
											when tiLvl = 0x90		then	0x0300		--	90=Clinic-Patient
											when tiLvl = 0xA0		then	0x0500		--	A0=Clinic-Staff
											when tiLvl = 0xB0		then	0x0700		--	B0=Clinic-Doctor
											when tiLvl & 0x04 > 0	then	0x0800		--	4=Initial
											when tiLvl & 0x03 > 0	then	0x0080		--	2=Rounding, 1=Reminder
											when tiSpec in (7,8,9)	then	0x1000		--	Presence
											when tiSpec in (10,11,12,13,14,15,16,17, 20,21, 23,24,25,26,27)
																	then	0x2000		--	Failure
																	else	0x4000	end	--	Regular

		alter table	dbo.tbCfgPri		drop column	tiLvl
			' )

		exec sp_rename 'tbCfgPri.tiFlags',		'siFlags',	'column'
		exec sp_rename 'tbCfgPri.tiOtInt',		'tiIntOt',	'column'
		exec sp_rename 'tbCfgPri.tiToneInt',	'tiIntTn',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.8362	+ .bActive
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
--				* @bEnabled -> @siFlags
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.6340	+ .tiLvl
--	7.06.6177	* .tiLight -> .tiDome
--	7.06.5914	* .dtCreated -> .dtUpdated
--	7.06.5687	+ .siIdxUg, .siIdxOt, .tiOtInt, .tiLight, .tiTone, .tiToneInt
--	7.04.4898
alter proc		dbo.prCfgPri_GetAll
(
	@siFlags	smallint	= null	-- null=any
--	@bEnabled	bit					--	0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	siIdx, sCall, siFlags, tiShelf, tiColor, tiSpec, iFilter
		,	siIdxUg, siIdxOt, tiIntOt, tiDome, tiTone, tiIntTn
		,	dtUpdated,	cast(siFlags & 0x0002 as bit)	as	bActive
		from	tbCfgPri	with (nolock)
		where	@siFlags is null	or	siFlags & @siFlags = @siFlags
--		where	@bEnabled = 0	or	siFlags & 0x02 > 0
		order	by	1 desc
end
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
--	7.06.8362	* set .dtUpdated
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
--	7.06.8189	+ @tiColor
--				- .iColorF, .iColorB
--	7.06.7641	+ @tiLvl
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	7.06.6340	+ .tiLvl
--	7.06.6177	* .tiLight -> .tiDome,	@tiLight -> @tiDome
--	7.06.5910	* prCfgPri_Ins -> prCfgPri_InsUpd
--	7.06.5907	* modify logic to update tbCfgPri instead of always inserting
--	7.06.5687	+ .siIdxUg, .siIdxOt, .tiOtInt, .tiLight, .tiTone, .tiToneInt
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	7.03	+ @iFilter
--	6.05
alter proc		dbo.prCfgPri_InsUpd
(
	@siIdx		smallint			-- call-index
,	@sCall		varchar( 16 )		-- call-text
,	@siFlags	smallint			-- bitwise:	x80=Reserved, x40=G-cancel, x20=O-cancel, x10=Y-cancel, x08=Rnd/Rmnd, x04=Control, x02=Enabled, x01=Locking
									--			x0900=Clin-Doc, x0500=Clin-Stf, x0300=Clin-Pat, x0100=Clinic, x1000=Rnd-Init
,	@tiShelf	tinyint				-- 0=Invisible, 1=Routine, 2=Urgent, 3=Emergency, 4=Code
,	@tiColor	tinyint				-- FG/BG color index
,	@iFilter	int					-- priority filter-mask
,	@tiSpec		tinyint				-- special priority
,	@siIdxUg	smallint			-- upgrade priority-index
,	@siIdxOt	smallint			-- overtime priority-index
,	@tiIntOt	tinyint				-- overtime interval, min
,	@tiDome		tinyint				-- light-show index
,	@tiTone		tinyint				-- tone index
,	@tiIntTn	tinyint				-- tone interval, min
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Pri_U( ' + isnull(cast(@siIdx as varchar),'?') + '|''' + isnull(@sCall,'?') + ''', fl=' +
					isnull(convert(varchar, convert(varbinary(2), @siFlags), 1),'?') + ', k=' +
					isnull(cast(@tiColor as varchar),'?') + ', sh=' +
					isnull(cast(@tiShelf as varchar),'?') +	'|' + isnull(cast(@tiSpec as varchar),'?') + ', ug=' +
					isnull(cast(@siIdxUg as varchar),'?') + ', ot=' +
					isnull(cast(@siIdxOt as varchar),'?') +	'|' + isnull(cast(@tiIntOt as varchar),'?') + ', ' +
					isnull(convert(varchar, convert(varbinary(4), @iFilter), 1),'?') + ', dm=' +
					isnull(cast(@tiDome as varchar),'?') + ', tn=' +
					isnull(cast(@tiTone as varchar),'?') +	'|' + isnull(cast(@tiIntTn as varchar),'?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgPri where siIdx = @siIdx)
			update	tbCfgPri	set			sCall =		@sCall,		siFlags =	@siFlags,	tiShelf =	@tiShelf
				,	tiColor =	@tiColor,	iFilter =	@iFilter,	tiSpec =	@tiSpec,	siIdxUg =	@siIdxUg
				,	siIdxOt =	@siIdxOt,	tiIntOt =	@tiIntOt,	tiDome =	@tiDome,	tiTone =	@tiTone
				,	tiIntTn =	@tiIntTn,	dtUpdated =	getdate( )
				where	siIdx = @siIdx
		else
			insert	tbCfgPri	(  siIdx,  sCall,  siFlags,  tiShelf,  tiColor,  iFilter,  tiSpec,  siIdxUg,  siIdxOt,  tiIntOt,  tiDome,  tiTone,  tiIntTn )
					values		( @siIdx, @sCall, @siFlags, @tiShelf, @tiColor, @iFilter, @tiSpec, @siIdxUg, @siIdxOt, @tiIntOt, @tiDome, @tiTone, @tiIntTn )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Fills #tbCall with enabled priorities' siIdx-s, given in a string ('*' or '1,2,3,..')
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
--	7.06.5380	+ "or	@sRoles = ''"
--				* prCfgPri_SetTmpFlt -> prCall_SetTmpFlt
--	7.05.5179
alter proc		dbo.prCall_SetTmpFlt
(
	@sCalls		varchar( 255 )		-- comma-separated siIdx-s, '*'=all
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbCall						-- no enforcement of FKs
	(
		siIdx		smallint		not null	-- priority-index

		primary key nonclustered ( siIdx )
	)
*/
	if	@sCalls = ''	or	@sCalls is null
		return	0

	if	@sCalls = '*'
	begin
		insert	#tbCall
			select	siIdx
				from	tbCfgPri	with (nolock)
				where	siFlags & 0x0002 > 0		--	enabled only
	end
	else
	begin
		select	@s=
		'insert	#tbCall
			select	siIdx
				from	tbCfgPri	with (nolock)
				where	siFlags & 0x0002 > 0
				and		siIdx in (' + @sCalls + ')'
		exec( @s )
	end
--	select	*	from	#tbCall
end
go
--	----------------------------------------------------------------------------
--	7.06.8343	* [0] 'NO CALL' -> '<NO CALL>'
begin tran
	update	dbo.tbCfgPri	set	sCall= '<NO CALL>'	where	siIdx = 0
	update	dbo.tbCall		set	sCall= '<NO CALL>'	where	idCall = 0
commit
go
--	----------------------------------------------------------------------------
--	7.06.8343	- removed
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_SetLvl')
	drop proc		dbo.prCfgPri_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCall')
	drop view		dbo.vwCall
go
--	----------------------------------------------------------------------------
--	7.06.8399	* [many].sLogType
begin tran
	update	dbo.tb_LogType	set	sLogType= 'Stats'		where	idLogType = 33
	update	dbo.tb_LogType	set	sLogType= 'Active'		where	idLogType = 34
	update	dbo.tb_LogType	set	sLogType= 'Asleep'		where	idLogType = 35
	update	dbo.tb_LogType	set	sLogType= 'Paused'		where	idLogType = 36
	update	dbo.tb_LogType	set	sLogType= 'Started'		where	idLogType = 38
	update	dbo.tb_LogType	set	sLogType= 'Stopped'		where	idLogType = 39
	update	dbo.tb_LogType	set	sLogType= 'Installed'	where	idLogType = 61
	update	dbo.tb_LogType	set	sLogType= 'Removed'		where	idLogType = 62
	update	dbo.tb_LogType	set	sLogType= 'License'		where	idLogType = 63
	update	dbo.tb_LogType	set	sLogType= 'Updated'		where	idLogType = 64
	update	dbo.tb_LogType	set	sLogType= 'Config edit'		where	idLogType = 70
	update	dbo.tb_LogType	set	sLogType= 'Cfg: bed'		where	idLogType = 71
	update	dbo.tb_LogType	set	sLogType= 'Cfg: call'		where	idLogType = 72
	update	dbo.tb_LogType	set	sLogType= 'Cfg: loc'		where	idLogType = 73
	update	dbo.tb_LogType	set	sLogType= 'Cfg: stn'		where	idLogType = 74
	update	dbo.tb_LogType	set	sLogType= 'Cfg: room'		where	idLogType = 75
	update	dbo.tb_LogType	set	sLogType= 'Cfg: btn'		where	idLogType = 76
	update	dbo.tb_LogType	set	sLogType= 'Conn. lost'	where	idLogType = 81
	update	dbo.tb_LogType	set	sLogType= 'GW found'	where	idLogType = 189
	update	dbo.tb_LogType	set	sLogType= 'GW lost'		where	idLogType = 190
	update	dbo.tb_LogType	set	sLogType= 'ON duty'		where	idLogType = 218
	update	dbo.tb_LogType	set	sLogType= 'on break'	where	idLogType = 219
	update	dbo.tb_LogType	set	sLogType= 'off duty'	where	idLogType = 220
	update	dbo.tb_LogType	set	sLogType= 'Log-in'		where	idLogType = 221
	update	dbo.tb_LogType	set	sLogType= 'Log-out'		where	idLogType = 229
	update	dbo.tb_LogType	set	sLogType= 'User created'	where	idLogType = 237
	update	dbo.tb_LogType	set	sLogType= 'User updated'	where	idLogType = 238
	update	dbo.tb_LogType	set	sLogType= 'User unlocked'	where	idLogType = 239
	update	dbo.tb_LogType	set	sLogType= 'User enabled'	where	idLogType = 240
	update	dbo.tb_LogType	set	sLogType= 'User disabled'	where	idLogType = 241
	update	dbo.tb_LogType	set	sLogType= 'Role created'	where	idLogType = 242
	update	dbo.tb_LogType	set	sLogType= 'Role updated'	where	idLogType = 243
	update	dbo.tb_LogType	set	sLogType= 'Role members'	where	idLogType = 244
	update	dbo.tb_LogType	set	sLogType= 'Role enabled'	where	idLogType = 245
	update	dbo.tb_LogType	set	sLogType= 'Role disabled'	where	idLogType = 246
	update	dbo.tb_LogType	set	sLogType= 'Record created'	where	idLogType = 247
	update	dbo.tb_LogType	set	sLogType= 'Record updated'	where	idLogType = 248
	update	dbo.tb_LogType	set	sLogType= 'Record deleted'	where	idLogType = 249
commit
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
--	7.06.8411	* @bVisible meaning
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
--				* @tiLvl -> @siFlags
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.7643	* @tiLvl
--	7.06.7317	+ .tiFlags
--				* @tiLvl meaning (+2, 4)
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
	@bVisible	bit			= null	-- null=, 0=order by siIdx, 1=order by idCall
,	@bEnabled	bit			= null	-- null=any, 0=disabled, 1=enabled for reporting
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@siFlags	smallint	= null	-- null=any
)
	with encryption
as
begin
	set	nocount	on
	if	@bVisible is null
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, c.bActive, c.dtCreated, c.dtUpdated
			,	p.siFlags, p.tiShelf, p.tiSpec, p.tiColor
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx
			where	(@bEnabled is null	or	c.bEnabled = @bEnabled)
				and	(@bActive is null	or	c.bActive = @bActive)
				and	(@siFlags is null	or	siFlags & @siFlags > 0)
			order	by	c.siIdx	desc,	c.idCall	desc					-- 7.06.7104
	else
	if	@bVisible > 0
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, c.bActive, c.dtCreated, c.dtUpdated
			,	p.siFlags, p.tiShelf, p.tiSpec, p.tiColor
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx
			where	(@bEnabled is null	or	c.bEnabled = @bEnabled)
				and	(@bActive is null	or	c.bActive = @bActive)
				and	(@siFlags is null	or	siFlags & @siFlags = @siFlags)
			order	by	c.idCall
	else
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, c.bActive, c.dtCreated, c.dtUpdated
			,	p.siFlags, p.tiShelf, p.tiSpec, p.tiColor
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx	--	p.sCall = c.sCall	and
			where	(@bEnabled is null	or	c.bEnabled = @bEnabled)
				and	(@bActive is null	or	c.bActive = @bActive)
				and	(@siFlags is null	or	siFlags & @siFlags = @siFlags)
			order	by	c.siIdx	desc,	c.idCall	desc					-- 7.06.7104

end
go
--	----------------------------------------------------------------------------
--	Imports enabled call-texts from tbCfgPri
--	7.06.8480	* fix null .tVoTrg, .tStTrg (hijacked Rounding/Reminder)
--	7.06.8411	* fix Failure-to-Team assignment	siFlags = 0x2000	->	siFlags & 0x2000 > 0
--				* Rounding/Reminder .tVoTrg, .tStTrg
--	7.06.8377	+ Rounding/Reminder, Special:	bEnabled:= true
--	7.06.8368	+ Rounding/Reminder .tVoTrg, .tStTrg
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
--	7.06.7380	+ tbTeamCall population for idTeam=1
--	7.06.7279	* optimized logging
--	7.06.6010	* fix for updating non-matching call-texts
--	7.06.5868	+ [29,30] tbCall.tVoTrg, .tStTrg defaults
--	7.06.5865	* fix for call escalation (allow duplicated call-texts)
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dtNow		datetime
		,		@idCall		smallint
		,		@siIdx		smallint			-- call-index
		,		@sCall		varchar( 16 )		-- call-text
		,		@pCall		varchar( 16 )		-- call-text
		,		@tVoTrg		time( 0 )
		,		@tStTrg		time( 0 )
		,		@iAdded		smallint
		,		@iRemed		smallint
		,		@siFlags	smallint
		,		@siIdxOt	smallint

	declare		cur		cursor fast_forward for
		select	siIdx, sCall, siFlags
			from	tbCfgPri	with (nolock)
			where	siIdx > 0	and	siFlags & 0x0002 > 0		-- enabled
			order	by	1

	set	nocount	on

	select	@iAdded =	0,	@iRemed =	0,	@dtNow =	getdate( )

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

--	select	@tVoTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
--	select	@tStTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall, @siFlags
		while	@@fetch_status = 0
		begin
			select	@idCall =	-1
			select	@idCall =	idCall,		@pCall =	sCall	from	tbCall		with (nolock)	where	siIdx = @siIdx	and	bActive > 0
	--		print	cast(@siIdx as varchar) + ': ' + @sCall + ' -> ' + cast(@idCall as varchar)

			if	@idCall > 0	and	@sCall <> @pCall							-- found active previous with different name
			begin
				update	tbCall	set	dtUpdated=	getdate( ),	bActive =	0	-- deactivate previous
					where	idCall = @idCall

				select	@iRemed =	@iRemed + 1,	@idCall =	-1			-- prepare to insert a new one
			end

			if	@idCall < 0													-- not found - insert a new one
			begin
				select	@tVoTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
				select	@tStTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	--			print	'  insert new'
				insert	tbCall	(  siIdx,  sCall,  tVoTrg,  tStTrg )
						values	( @siIdx, @sCall, @tVoTrg, @tStTrg )
				select	@idCall =	scope_identity( )

				select	@iAdded =	@iAdded + 1
			end
	--	-	else

			if	@siFlags & 0x0800 > 0										-- Rounding/Reminder - Initial
			begin
				select	@tVoTrg =	'0:0:0',	@tStTrg =	'0:0:0'

				select	@tVoTrg =	dateadd( mi, isnull(tiIntOt, 0), @tVoTrg ),		@siIdxOt =	siIdxOt
					from	tbCfgPri	with (nolock)
					where	siIdx = @siIdx									--	OT1

				select	@tVoTrg =	dateadd( mi, isnull(tiIntOt, 0), @tVoTrg ),		@siIdxOt =	siIdxOt
					from	tbCfgPri	with (nolock)
					where	siIdx = @siIdxOt								--	OT2

				select	@tStTrg =	dateadd( mi, isnull(tiIntOt, 0), @tVoTrg )
					from	tbCfgPri	with (nolock)
					where	siIdx = @siIdxOt								--	OT

				update	tbCall	set	dtUpdated=	@dtNow,	bEnabled =	1,	tVoTrg =	@tVoTrg,	tStTrg =	@tStTrg
					where	idCall = @idCall
			end
			else
			if	@siFlags & 0x3000 > 0										-- Special:	Failure (2000) or Presence (1000)
				update	tbCall	set	dtUpdated=	@dtNow,	bEnabled =	1
					where	idCall = @idCall
					and		bEnabled = 0									-- only update disabled ones

			fetch next from	cur	into	@siIdx, @sCall, @siFlags
		end
		close	cur
		deallocate	cur

		update	c	set	c.bActive=	0,	dtUpdated=	@dtNow
			from	tbCall	c
			join	tbCfgPri	p	on	p.siIdx = c.siIdx	and	p.siFlags & 0x0002 = 0	-- disabled
			where	c.bActive > 0

		select	@s =	'Call_Imp( ) +' + cast(@iAdded as varchar) + ', *' + cast(@iRemed as varchar) + ', -' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0	and	@@rowcount > 0							--	Config?
--		if	@tiLog & 0x04 > 0	and	@@rowcount > 0							--	Debug?
--		if	@tiLog & 0x08 > 0	and	@@rowcount > 0							--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

		select	@idCall =	1												-- [Techies] team

		delete	from	dbo.tbTeamCall										-- re-init coverage
			where	idTeam = @idCall

		insert	dbo.tbTeamCall	( idTeam, siIdx )							-- in case anything changed
			select	@idCall, siIdx
				from	dbo.tbCfgPri
				where	siFlags & 0x2000 > 0								-- Failure
--				where	tiSpec	in	(10,11,12,13,14,15,16,17, 20,21, 23,24,25,26,27)
--				and		siIdx	not in	(select siIdx from dbo.tbTeamCall where idTeam = @idCall)

	commit
end
go
--	----------------------------------------------------------------------------
--	Staff definitions
--	7.06.8343	* sStaffID -> sStfID
--	7.06.8139	+ .cStfLvl,	- .iColorB
--	7.06.8137	* sFqStaff -> sQnStf,
--				- sStfLvl from it,
--				+ isnull(sStaffID, ..)
--	7.06.6814	- tb_User.sTeams, .sUnits
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
--select	idUser, sStaffID, sFrst, sMidd, sLast, u.idStfLvl, l.cStfLvl, l.sStfLvl, sBarCode	--, l.iColorB
select	idUser, sStaffID	as	sStfID,		sFrst, sMidd, sLast, u.idStfLvl, l.cStfLvl, l.sStfLvl, sBarCode
	,	sStaff,	isnull(sStaffID, '--') + ' | ' + sStaff	as	sQnStf
	,	bOnDuty, dtDue,	u.idRoom
	,	bActive, dtCreated, dtUpdated
	from	tb_User	u	with (nolock)
	join	tbStfLvl l	with (nolock)	on	l.idStfLvl = u.idStfLvl
go
--	----------------------------------------------------------------------------
--	Returns [active?] staff, ordered to be loadable into a table
--	7.06.8375	+ filter out RTLS-auto staff:	substring(sStaff, 1, 1) <> char(0x7F)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8139	+ .idStfLvl, .cStfLvl
--				- .iColorB
--	7.05.5010	* .idStaff -> .idUser
--	7.05.4983	* .bInclude -> .bEnabled
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4913	+ @bActive
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.03
alter proc		dbo.prStaff_GetAll
(
	@bActive	bit					-- 0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, cast(1 as bit)	as	bEnabled, sStfID, sStaff, idStfLvl, cStfLvl, sStfLvl	--, iColorB
		from	vwStaff	with (nolock)
		where	@bActive = 0	or	bActive > 0
		and		substring(sStaff, 1, 1) <> char(0x7F)
		order	by	idStfLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	Staff notification devices (Badge|Pager|Phone|Wi-Fi)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8137	* sFqDvc -> sQnDvc
--				* vwStaff.sFqStaff -> sQnStf,
--	7.06.8130	+ t.cDvcType
--	7.06.8123	* sFqDvc: t.sDvcType -> .cDvcType
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
select	d.idDvc, d.idDvcType, t.cDvcType, t.sDvcType, d.sDial, d.sDvc, d.sBarCode, d.tiFlags, d.sBrowser
	,	t.cDvcType + ' ' + d.sDial		as	sQnDvc
	,	d.idUser, u.idStfLvl, u.sStfLvl, u.sStfID, u.sStaff, u.sQnStf, u.bOnDuty, u.dtDue
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDvc		d	with (nolock)
	join	tbDvcType	t	with (nolock)	on	t.idDvcType = d.idDvcType
	left join	vwStaff	u	with (nolock)	on	u.idUser = d.idUser
go
--	----------------------------------------------------------------------------
--	Returns active devices, assigned to a given user
--	7.06.8343	* vwStaff.sStaffID -> sStfID
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
		,	idUser, idStfLvl, sStfID, sStaff, bOnDuty, dtDue
		from	vwDvc	with (nolock)
		where	bActive > 0
		and		idDvcType & @idDvcType	<> 0
		and		idUser = @idUser
end
go
--	----------------------------------------------------------------------------
--	Returns active group notification devices (pagers only), assigned to a given team
--	7.06.8343	* vwStaff.sStaffID -> sStfID
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
		,	idUser, idStfLvl, sStfID, sStaff, bOnDuty, dtDue
		from	vwDvc	with (nolock)
		where	bActive > 0
		and		idDvcType = 2
		and		idDvc	in	(select idDvc from tbTeamDvc with (nolock) where idTeam = @idTeam)
end
go
--	----------------------------------------------------------------------------
--	790 Devices
--	7.06.8139	* sQnDevice -> sQnDvc
--	7.06.5990	* sSGJR,sSGJ: S-GGG-JJ-RR -> S-GGG-JJJ-RR (in 680 J range is upto 133)
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.05.5095	- .sFnDevice
--	7.03	+ output cols from tbRoom, reorder columns
--	7.02	* '(#.sDial)' instead of '(.sDial)'
--			* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	7.00	+ .sUnits
--			+ .sCodeVer
--	6.05	+ (nolock)
--	6.04	+ .sQnDevice, .siBeds, .sBeds, .idUnit
--			* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	6.03	+ .cSGJ, + .sFnDevice
--	6.02
alter view		dbo.vwDevice
	with encryption
as
select	r.idUnit,	idDevice, idParent,		cSys, tiGID, tiJID, tiRID, iAID, tiStype,	cDevice, sDevice, sDial, sCodeVer, sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)												as sSGJ
	,	'[' + cDevice + '] ' + sDevice		as sQnDvc		--	,	cDevice + ' ' + sDevice				as sFqDvc
	,	r.idEvent,	r.tiSvc
	,	r.idUserG,	r.sStaffG
	,	r.idUserO,	r.sStaffO
	,	r.idUserY,	r.sStaffY
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDevice	d	with (nolock)
	left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + registered staff
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--				* idStfLvl? -> idStLvl?, sStaffID? -> sStfID?
--	7.06.8139	* sQnDevice -> sQnDvc
--	7.06.7292	+ .idUser4, .idUser2, .idUser1
--	7.06.7262	+ .tiCall
--	7.06.6225	+ .dtExpires
--	7.06.5990	* sSGJR,sSGJ: S-GGG-JJ-RR -> S-GGG-JJJ-RR (in 680 J range is upto 133)
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* .idReg[4,2,1] -> .idUser[G,O,Y], .idRegLvl[] -> .idStfLvl[], .sRegID[] -> .sStaffID[], .sReg[] -> .sStaff[], .bRegDuty[] -> .bOnDuty[]
--	7.06.5464	+ .dtDue (for each staff)
--	7.05.5154	+ .idRegN, .idRegLvlN, .sRegIDN, .sRegN, .bRegDutyN
--	7.05.5095	* d.dtUpdated -> r.dtUpdated
--				- .sFnDevice
--	7.04.4892	* vwRoomAct -> vwRoom,	match output to vwDevice
--	7.03		vwRoom -> vwRoomAct
alter view		dbo.vwRoom
	with encryption
as
select	r.idUnit,	idDevice, idParent,		cSys, tiGID, tiJID, tiRID, iAID, tiStype,	cDevice, sDevice, sDial, sCodeVer, sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)												as sSGJ
	,	'[' + cDevice + '] ' + sDevice		as sQnDvc		--	,	cDevice + ' ' + sDevice				as sFqDvc
	,	r.idEvent,	r.tiSvc
	,	r.idUserG,	s4.idStfLvl	as	idStLvlG,	s4.sStfID	as	sStfIdG,	coalesce(s4.sStaff, r.sStaffG)	as	sStaffG,	s4.bOnDuty	as	bOnDutyG,	s4.dtDue	as	dtDueG
	,	r.idUserO,	s2.idStfLvl	as	idStLvlO,	s2.sStfID	as	sStfIdO,	coalesce(s2.sStaff, r.sStaffO)	as	sStaffO,	s2.bOnDuty	as	bOnDutyO,	s2.dtDue	as	dtDueO
	,	r.idUserY,	s1.idStfLvl	as	idStLvlY,	s1.sStfID	as	sStfIdY,	coalesce(s1.sStaff, r.sStaffY)	as	sStaffY,	s1.bOnDuty	as	bOnDutyY,	s1.dtDue	as	dtDueY
	,	r.dtExpires,	r.idUser4,	r.idUser2,	r.idUser1,	r.tiCall
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	tbDevice	d	with (nolock)
	join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
	left join	vwStaff	s4	with (nolock)	on	s4.idUser = r.idUserG
	left join	vwStaff	s2	with (nolock)	on	s2.idUser = r.idUserO
	left join	vwStaff	s1	with (nolock)	on	s1.idUser = r.idUserY
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	7.06.8469	+ cRoom
--	7.06.8343	* vwRoom.idStfLvl? -> idStLvl?, sStaffID? -> sStfID?
--				* vwStaff.sStaffID? -> sStfID?
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.06.6284	- tbPatient.idRoom, .tiBed
--	7.06.5939	- tbRoomBed.cBed -> tbCfgBed.cBed	(cb.cBed will be null for rb.tiBed == 0xFF)
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* .idReg[4,2,1] -> .idUser[G,O,Y], .sAssnID[] -> .sStaffID[], .sAssn[] -> .sStaff[]
--	7.06.5464	+ .dtDue (for each staff)
--	7.06.5371	+ r.sQnDevice
--	7.06.5353	* r.idRoom -> r.idDevice
--	7.06.5333	+ .cDevice
--	7.05.5154	+ .idRegN, .idRegLvlN, .sRegIDN, .sRegN, .bRegDutyN
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
--	7.02	* .idDoctor now comes from tbPatient
--			* registered staff now comes from tbRoom (not from tbRoomBed)
--	7.01	* assigned staff: tbStaff -> vwStaff,	+ idStaffLvl, sStaffLvl
--	7.00	+ tbRoomBed.idAsnRn, .idAsnCn, .idAsnAi, .idRegRn, .idRegCn, .idRegAi
--			- vwRtlsRoom
--	6.05	- vwEvent_A, tbPatient, tbDoctor joins - not needed in view itself
--			+ r.cSys, r.tiGID, r.tiJID, r.tiRID
--			+ (nolock)
--	6.04
alter view		dbo.vwRoomBed
	with encryption
as
select	r.idUnit,	rb.idRoom, r.cDevice as cRoom, r.sDevice as sRoom, r.sQnDvc as sQnRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, cb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	p.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idUser1,	a1.idStfLvl	as	idStLvl1,	a1.sStfID	as	sStfId1,	a1.sStaff	as	sStaff1,	a1.bOnDuty	as	bOnDuty1,	a1.dtDue	as	dtDue1
	,	rb.idUser2,	a2.idStfLvl	as	idStLvl2,	a2.sStfID	as	sStfId2,	a2.sStaff	as	sStaff2,	a2.bOnDuty	as	bOnDuty2,	a2.dtDue	as	dtDue2
	,	rb.idUser3,	a3.idStfLvl	as	idStLvl3,	a3.sStfID	as	sStfId3,	a3.sStaff	as	sStaff3,	a3.bOnDuty	as	bOnDuty3,	a3.dtDue	as	dtDue3
--	,	r.idReg4, r.sReg4,	r.idReg2, r.sReg2,	r.idReg1, r.sReg1
	,	r.idUserG,	r.idStLvlG,	r.sStfIdG,	r.sStaffG,	r.bOnDutyG,	r.dtDueG
	,	r.idUserO,	r.idStLvlO,	r.sStfIdO,	r.sStaffO,	r.bOnDutyO,	r.dtDueO
	,	r.idUserY,	r.idStLvlY,	r.sStfIdY,	r.sStaffY,	r.bOnDutyY,	r.dtDueY
	,	rb.dtUpdated
	from	tbRoomBed	rb	with (nolock)
	join	tbDevice	d	with (nolock)	on	d.idDevice	= rb.idRoom		and	d.bActive > 0
	join	vwRoom		r	with (nolock)	on	r.idDevice	= rb.idRoom
	left join	tbCfgBed	cb	with (nolock)	on	rb.tiBed	= cb.tiBed		---	and	cb.bActive > 0	--	no need
	left join	tbPatient	p	with (nolock)	on	p.idPatient	= rb.idPatient	--	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed
	left join	tbDoctor	dc	with (nolock)	on	dc.idDoctor	= p.idDoctor
	left join	vwStaff		a1	with (nolock)	on	a1.idUser	= rb.idUser1
	left join	vwStaff		a2	with (nolock)	on	a2.idUser	= rb.idUser2
	left join	vwStaff		a3	with (nolock)	on	a3.idUser	= rb.idUser3
go
--	----------------------------------------------------------------------------
--	Returns assignable active staff for given unit(s)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8280	+ filter out RTLS-auto staff:	substring(st.sStaff, 1, 1) <> char(0x7F)
--	7.06.8139	* vwDevice:	 sQnDevice -> sFqDvc
--				* .sQnRoom -> .sQnDvc
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

	select	st.idUser, st.idStfLvl, st.sStfID, st.sStaff, st.bOnDuty, st.dtDue
		,	st.idRoom,	r.sQnDvc
	--	,	st.sStfLvl, st.iColorB, st.sFqStaff, st.sUnits, st.sTeams
	--	,	st.bActive, st.dtCreated, st.dtUpdated
	--	,	bd.idDvc as idBadge,	bd.sDial as sBadge						--	results in duplication of staff
	--	,	pg.idDvc as idPager,	pg.sDial as sPager						--	with multiple devices of the same type
	--	,	ph.idDvc as idPhone,	ph.sDial as sPhone
	--	,	wf.idDvc as idWi_Fi,	wf.sDial as sWi_Fi
		,	stuff((select ', ' + pg.sDial
						from	tbDvc	pg	with (nolock)	where	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
						for xml path ('')), 1, 2, '') as sPager
		,	stuff((select ', ' + ph.sDial
						from	tbDvc	ph	with (nolock)	where	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
						for xml path ('')), 1, 2, '') as sPhone
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
		and		substring(st.sStaff, 1, 1) <> char(0x7F)
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@bOnDuty is null	or	st.bOnDuty = @bOnDuty)
		and		st.idUser	in
			(select	idUser
				from	tb_UserUnit	uu	with (nolock)
				join	#tbUnit		u	with (nolock)	on	u.idUnit = uu.idUnit)
		order	by	st.idStfLvl desc, st.sStaff
end
go
--	----------------------------------------------------------------------------
--	Returns call-routing data for given shift [and priority]
--	7.06.8468	* join order,	+ '@idShift = 0 or '
--	7.06.8343	* tbCfgPri.tiLvl -> .siFlags
--				* optimized bEnabled
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.7587	+ .tResp4
--	7.04.4938
alter proc		dbo.prRouting_Get
(
	@idShift	smallint
,	@bEnabled	bit			=	null	-- null=any, 0=disabled, 1=enabled priorities only
,	@siIdx		smallint	=	null
)
	with encryption
as
begin
	select	@idShift	as	idShift,	p.siIdx, p.sCall, p.tiShelf, p.tiSpec, p.tiColor
		,	cast(((p.siFlags & 0x0002) / 2) as bit)							as	bEnabled
		,	coalesce( r.tiRouting,	z.tiRouting )							as	tiRouting
		,	coalesce( r.bOverride,	z.bOverride )							as	bOverride
		,	coalesce( r.tResp0,		z.tResp0 )								as	tResp0
		,	coalesce( r.tResp1,		z.tResp1 )								as	tResp1
		,	coalesce( r.tResp2,		z.tResp2 )								as	tResp2
		,	coalesce( r.tResp3,		z.tResp3 )								as	tResp3
		,	coalesce( r.tResp4,		z.tResp4 )								as	tResp4
		,	coalesce( r.dtUpdated,	z.dtUpdated )							as	dtUpdated
		,	cast( case when @idShift = 0 or r.tiRouting	is null then 0 else 1 end as bit )	as	bRoute
		,	cast( case when @idShift = 0 or r.bOverride	is null then 0 else 1 end as bit )	as	bOverr
		,	cast( case when @idShift = 0 or r.tResp0	is null then 0 else 1 end as bit )	as	bResp0
		,	cast( case when @idShift = 0 or r.tResp1	is null then 0 else 1 end as bit )	as	bResp1
		,	cast( case when @idShift = 0 or r.tResp2	is null then 0 else 1 end as bit )	as	bResp2
		,	cast( case when @idShift = 0 or r.tResp3	is null then 0 else 1 end as bit )	as	bResp3
		,	cast( case when @idShift = 0 or r.tResp4	is null then 0 else 1 end as bit )	as	bResp4
		from	dbo.tbCfgPri	p	with (nolock)
		join	dbo.tbRouting	z	with (nolock)	on	z.idShift = 0	and	p.siIdx = z.siIdx
		left join	dbo.tbRouting	r	with (nolock)	on	r.idShift = @idShift	and	z.siIdx = r.siIdx
		where	(@siIdx is null	or	p.siIdx = @siidx )
		and		(@idShift = 0	and	@bEnabled = 0	or	p.siFlags & 0x0002 > 0 )
		order	by	siIdx desc
end
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5429	+ .dtDue
--	7.05.5127	+ .bOnDuty
--				* sc.tBeg -> sc.dtBeg, sc.tEnd -> sc.dtEnd
--	7.05.5010	* .idStaff -> .idUser
--	7.05.5008	+ .tiShIdx
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--				* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.00
alter view		dbo.vwStfAssn
	with encryption
as
select	sa.idStfAssn,	sh.idUnit
	,	sa.idShift, sh.tiIdx as tiShIdx, sh.sShift, sh.tBeg as tShBeg, sh.tEnd as tShEnd
	,	sa.idRoom, d.cDevice, d.sDevice as sRoom, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idUser, s.sStfID, s.idStfLvl, s.sStfLvl, s.sStaff, s.bOnDuty, s.dtDue
	,	sc.idStfCvrg, sc.dtBeg, sc.dtEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfAssn	sa	with (nolock)
	join	tbShift		sh	with (nolock)	on	sh.idShift	= sa.idShift
	join	vwStaff		s	with (nolock)	on	s.idUser	= sa.idUser
	join	vwDevice	d	with (nolock)	on	d.idDevice	= sa.idRoom
	left join	tbStfCvrg	sc	with (nolock)	on	sc.idStfCvrg	= sa.idStfCvrg
go
--	----------------------------------------------------------------------------
--	Current (open) staff assignment history (coverage)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.6053	+ .dShift
--	7.06.5429	+ .dtDue
--	7.05.5127	+ .bOnDuty
--				* - sc.dtEnd (null by selection criteria)
--	7.05.5086	+ sc.dtDue, sc.tBeg -> sc.dtBeg, sc.tEnd -> sc.dtEnd
--	7.05.5079	+ .tiShIdx
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--				* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.00
alter view		dbo.vwStfCvrg
	with encryption
as
select	sa.idStfAssn,	sh.idUnit
	,	sa.idShift, sh.tiIdx as tiShIdx, sh.sShift, sh.tBeg as tShBeg, sh.tEnd as tShEnd
	,	sa.idRoom, d.cDevice, d.sDevice as sRoom, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idUser, s.sStfID, s.idStfLvl, s.sStfLvl, s.sStaff, s.bOnDuty, s.dtDue
	,	sc.idStfCvrg, sc.dShift, cast(cast(cast(sc.dShift as datetime) + sh.tBeg as float) * 48 as int)	as	iShSeq
	,	sc.dtBeg, sc.dtDue as dtFin	--, sc.dtEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfCvrg	sc	with (nolock)
	join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn	= sc.idStfAssn
	join	tbShift		sh	with (nolock)	on	sh.idShift	= sa.idShift
	join	vwStaff		s	with (nolock)	on	s.idUser	= sa.idUser
	join	vwDevice	d	with (nolock)	on	d.idDevice	= sa.idRoom
	where	sc.dtEnd is null
go
--	----------------------------------------------------------------------------
--	Returns staff assignements for the given shift and room-bed
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5429	+ .dtDue
--	7.06.5421
alter proc		dbo.prStfAssn_GetByRoom
(
	@idShift	smallint			-- not null
,	@idRoom		smallint			-- not null
,	@tiBed		tinyint				-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idStfAssn, idShift, idRoom, tiBed, tiIdx,	idUser, idStfLvl, sStfID, sStaff, bOnDuty, dtDue
		from	vwStfAssn	with (nolock)
		where	bActive > 0 and idStfCvrg > 0	and	idShift = @idShift	and	idRoom = @idRoom
		and		(tiBed = @tiBed		or
				@tiBed	is null		and	tiBed in	(select min(tiBed)	from	vwStfAssn with (nolock)
					where	bActive > 0	and idStfCvrg > 0	and	idShift = @idShift	and	idRoom = @idRoom))
		order	by	tiIdx
end
go
--	----------------------------------------------------------------------------
--	Exports all staff assignment definitions
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.7460	+ .sRoom, .sStaff
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

	select	idStfAssn, idUnit, cSys, tiGID, tiJID, tiBed, tiShIdx, tiIdx, sStfID, bActive, dtCreated, dtUpdated,	idRoom, sRoom, idUser, sStaff, idShift
		from	vwStfAssn	with (nolock)
	---	where	bActive > 0					-- must export all to ensure matching deactivation
end
go
--	----------------------------------------------------------------------------
--	Returns all staff assignments for given unit/shift
--	7.06.8469	* .sQnRoom -> .cRoom
--	7.06.8440	* .sQnRoom -> .sRoom
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--				* idStfLvl? -> idStLvl?, sStaffID? -> sStfID?, idStfAssn? -> idStAsn?
--	7.06.8139	* vwRoomBed.sQnDevice -> sQnRoom
--	7.06.5429	+ .dtDue
--	7.06.5371	+ rb.sQnDevice
--	7.05.5154
alter proc		dbo.prStfAssn_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@idShift	smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	rb.idRoom, rb.cRoom, rb.sRoom,	rb.tiBed, rb.cBed
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	a1.idStfAssn	as	idStAsn1,	a1.idUser	as	idUser1,	a1.idStfLvl	as	idStLvl1,	a1.sStfID	as	sStfId1,	a1.sStaff	as	sStaff1,	a1.bOnDuty	as	bOnDuty1,	a1.dtDue	as	dtDue1
		,	a2.idStfAssn	as	idStAsn2,	a2.idUser	as	idUser2,	a2.idStfLvl	as	idStLvl2,	a2.sStfID	as	sStfId2,	a2.sStaff	as	sStaff2,	a2.bOnDuty	as	bOnDuty2,	a2.dtDue	as	dtDue2
		,	a3.idStfAssn	as	idStAsn3,	a3.idUser	as	idUser3,	a3.idStfLvl	as	idStLvl3,	a3.sStfID	as	sStfId3,	a3.sStaff	as	sStaff3,	a3.bOnDuty	as	bOnDuty3,	a3.dtDue	as	dtDue3
		from	vwRoomBed	rb	with (nolock)
		left join	vwStfAssn	a1	with (nolock)	on	a1.idRoom = rb.idRoom	and	a1.tiBed = rb.tiBed		and	a1.idShift = @idShift	and	a1.tiIdx = 1	and	a1.bActive > 0
		left join	vwStfAssn	a2	with (nolock)	on	a2.idRoom = rb.idRoom	and	a2.tiBed = rb.tiBed		and	a2.idShift = @idShift	and	a2.tiIdx = 2	and	a2.bActive > 0
		left join	vwStfAssn	a3	with (nolock)	on	a3.idRoom = rb.idRoom	and	a3.tiBed = rb.tiBed		and	a3.idShift = @idShift	and	a3.tiIdx = 3	and	a3.bActive > 0
		where	rb.idUnit = @idUnit
		order	by	rb.sRoom, rb.cBed
end
go
--	----------------------------------------------------------------------------
--	Badges
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8137	* sFqStaff -> sQnStf
--	7.06.7261	- .idRcvrLast (fkRtlsBadge_LastRcvr), .dtRcvrLast, .idRoom (fkRtlsBadge_Room)
--				* .idRcvrCurr -> .idReceiver (fkRtlsBadge_CurrRcvr -> fkRtlsBadge_Receiver), .dtRcvrCurr -> .dtReceiver
--				- .cSys, .tiGID, .tiJID, .tiRID
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4953	+ vwStaff.sFqStaff
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--				* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.02	- tbRtlsBadge.idStaff (no need now, tbStaffDvc.idStaff keeps relationship)
--	7.00	vwRtlsRcvr -> tbRtlsRcvr
--			.tiPtype -> .idStaffLvl
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.04	* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	6.03
alter view		dbo.vwRtlsBadge
	with encryption
as
select	b.idBadge
	,	n.idUser, s.sStfID, s.idStfLvl, s.sStfLvl, s.sStaff, s.sQnStf
	,	b.idReceiver, r.sReceiver, b.dtReceiver
	,	r.idRoom, d.cDevice, d.sDevice, d.sSGJ, b.dtEntered	--,	b.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		join	tbDvc		n	with (nolock)	on	n.idDvc = b.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idUser =	n.idUser
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idReceiver
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = r.idRoom
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
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
		,	rb.idRoom, r.sQnDvc
		,	d.idUser, d.idStfLvl, d.sStfID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge	= d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice	= rb.idRoom
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
--	----------------------------------------------------------------------------
--	Returns an active device by the given bar-code
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.06.7270	* tbRtlsBadge -> vwRtlsBadge
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
		,	rb.idRoom, r.sQnDvc
		,	d.idUser, d.idStfLvl, d.sStfID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0
		and		d.sBarCode = @sBarCode
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given dial-code
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.06.7270	* tbRtlsBadge -> vwRtlsBadge
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
		,	rb.idRoom, r.sQnDvc
		,	d.idUser, d.idStfLvl, d.sStfID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0
		and		d.sDial = @sDial
end
go
--	----------------------------------------------------------------------------
--	Returns a Wi-Fi device by the given ID
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.06.7270	* tbRtlsBadge -> vwRtlsBadge
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
		,	rb.idRoom, r.sQnDvc
		,	d.idUser, d.idStfLvl, d.sStfID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.idDvc = @idDvc
		and		d.idDvcType = 0x08			--	Wi-Fi
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
--	7.06.8469	* sQnRoom -> cRoom
--	7.06.8439	+ r.sDevice as sRoom
--	7.06.8343	* tbCfgPri.tiLvl -> .siFlags
--				* optimized bAnswered
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.8139	* vwDevice.sQnDevice -> sQnDvc
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
	,	d.idDevice, d.sDevice, d.sQnDvc, d.tiStype, d.sSGJR + ' #' + right('0' + cast(ea.tiBtn as varchar), 2)	as	sSGJRB
	,	rm.idUnit,	ea.idRoom, r.sDevice as sRoom, r.cDevice as cRoom /*, r.sQnDvc as sQnRoom*/,	r.sDial,	ea.tiBed, cb.cBed, cb.cDial
	,	r.sDevice + case when ea.tiBed is null or ea.tiBed = 0xFF then '' else ' : ' + cb.cBed end		as	sRoomBed
	,	ea.idCall, c.siIdx, c.sCall, cp.tiColor, cp.tiShelf, cp.siFlags, cp.tiSpec, cp.iFilter, cp.tiDome, cd.tiPrism, cp.tiTone, cp.tiIntTn
	,	ea.bActive, ea.bAudio	--, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit )		as	bAnswered
	,	~cast( ((ea.siPri & 0x0400) / 0x0400) as bit )	as bAnswered
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) )	as	tElapsed,	ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
	from		tbEvent_A	ea	with (nolock)
	left join	vwDevice	d	with (nolock)	on	d.cSys = ea.cSys	and	d.tiGID = ea.tiGID	and	d.tiJID = ea.tiJID	and	d.tiRID = ea.tiRID	and	d.bActive > 0
	left join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
	left join	tbCall		c	with (nolock)	on	c.idCall = ea.idCall
	left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
	left join	tbCfgDome	cd	with (nolock)	on	cd.tiDome = cp.tiDome
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Returns assigned staff for given room-bed
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--				+ .sStaffID[], .bOnDuty[], .dtDue[]
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* .idReg[4,2,1] -> .idUser[G,O,Y], .sAssnID[] -> .sStaffID[], .sAssn[] -> .sStaff[]
--	7.06.5337	* return staff assigned to bed A for room-level calls
--	7.05.5185
alter proc		dbo.prRoomBed_GetAssn
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiRID		tinyint				-- R-ID - R-bus
,	@sDevice	varchar( 16 )		-- device name
,	@tiBed		tinyint				-- bed index (0-9, 255)
--,	@idUnit		smallint	= null	-- active unit ID
)
	with encryption
as
begin
	declare		@idRoom		int

	set	nocount	on

	select	@tiRID=	0		--	force 0 - looking for a room

	exec	dbo.prDevice_GetIns		@cSys, @tiGID, @tiJID, @tiRID, null, null, null, @sDevice, null, @idRoom out

	set	nocount	off

--	select	idAssn1, idStLvl1, sAssn1
--		,	idAssn2, idStLvl2, sAssn2
--		,	idAssn3, idStLvl3, sAssn3
	select	idUser1, idStLvl1, sStfID1, sStaff1, bOnDuty1, dtDue1
		,	idUser2, idStLvl2, sStfID2, sStaff2, bOnDuty2, dtDue2
		,	idUser3, idStLvl3, sStfID3, sStaff3, bOnDuty3, dtDue3
		from	vwRoomBed	with (nolock)
		where	idRoom = @idRoom
		and		(tiBed = @tiBed		or	@tiBed = 0xFF	and	tiBed = 1)
end
go
--	----------------------------------------------------------------------------
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.7649	+ h.dtCreated, h.dtUpdated
--	7.06.6054	+ a.idStfAssn
--	7.06.6052	+ a.idRoom, d.cDevice
--	7.06.5494	+ 'where a.bActive > 0'
--	7.06.5409	+ @siBeds (ignored for now)
--	7.06.5387	+ .idStfLvl
--	7.05.5086	* prRptStaffAssn -> prRptStfAssn
--				- .sRoomBed
--	7.05.5077	* fix bed designation (join -> left outer join for tbCfgBed)
--	7.05.5038	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--				* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.00	+ "Room-Bed" -> "Room : Bed";  sorting: idRoom -> sDevice
--			.tiPtype -> .idStaffLvl
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.02
alter proc		dbo.prRptStfAssn
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
,	@tiStaff	tinyint				-- 0xFF=any, 1=specific (tb_SessUser), 0=<invalid>
)
	with encryption
as
begin
	set	nocount	on

	create table	#tbRpt1
	(
		idStfAssn	int		primary key nonclustered
	)

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
				--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0
			else
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
				--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0
		else
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
				--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0
			else
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
				--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0
			else
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0
		else
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0
			else
				insert	#tbRpt1
					select	a.idStfAssn
						from	tbStfAssn		a	with (nolock)
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
						where	a.bActive > 0

	set	nocount	off

	select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
		,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		t.idStfAssn
		,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStfID, s.sStaff,		a.dtCreated, a.dtUpdated
		from	#tbRpt1			t	with (nolock)
		join	tbStfAssn		a	with (nolock)	on	a.idStfAssn = t.idStfAssn
		join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
		join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
		join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
		join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
		left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
--		where	a.bActive > 0
		order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
end
go
--	----------------------------------------------------------------------------
--	7.06.8405	* 
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.6054	* 
--	7.06.6052	+ a.idRoom, d.cDevice
--	7.06.5409	+ @siBeds (ignored for now)
--	7.06.5387	+ .idStfLvl
--				- order by h.tiIdx - should be chronological
--	7.05.5086	* prRptStaffCover -> prRptStfCvrg
--				- .sRoomBed
--	7.05.5077	* fix bed designation (join -> left outer join for tbCfgBed)
--	7.05.5038	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--				* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.00	.tiPtype -> .idStaffLvl
--			tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssnDef, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.02
alter proc		dbo.prRptStfCvrg
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
,	@tiStaff	tinyint				-- 0xFF=any, 1=specific (tb_SessUser), 0=<invalid>
)
	with encryption
as
begin
	set	nocount	on

	create table	#tbRpt1
	(
		idStfCvrg	int		primary key nonclustered
	)

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						where	p.dShift	between @dFrom	and @dUpto
			else
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						join	tb_SessUser		st	with (nolock)	on	st.idUser	= a.idUser		and	st.idSess = @idSess
						where	p.dShift	between @dFrom	and @dUpto
		else
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= a.idShift		and	sh.idSess = @idSess
						where	p.dShift	between @dFrom	and @dUpto
			else
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= a.idShift		and	sh.idSess = @idSess
						join	tb_SessUser		st	with (nolock)	on	st.idUser	= a.idUser		and	st.idSess = @idSess
						where	p.dShift	between @dFrom	and @dUpto
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice	= a.idRoom		and	sr.idSess = @idSess
						where	p.dShift	between @dFrom	and @dUpto
			else
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice	= a.idRoom		and	sr.idSess = @idSess
						join	tb_SessUser		st	with (nolock)	on	st.idUser	= a.idUser		and	st.idSess = @idSess
						where	p.dShift	between @dFrom	and @dUpto
		else
			if	@tiStaff = 0xFF
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice	= a.idRoom		and	sr.idSess = @idSess
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= a.idShift		and	sh.idSess = @idSess
						where	p.dShift	between @dFrom	and @dUpto
			else
				insert	#tbRpt1
					select	p.idStfCvrg
						from	tbStfAssn		a	with (nolock)
						join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn	= a.idStfAssn
						join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice	= a.idRoom		and	sr.idSess = @idSess
						join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= a.idShift		and	sh.idSess = @idSess
						join	tb_SessUser		st	with (nolock)	on	st.idUser	= a.idUser		and	st.idSess = @idSess
						where	p.dShift	between @dFrom	and @dUpto

	set	nocount	off

	select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
		,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
		,	a.idRoom, d.cDevice, d.sDevice, b.cBed		--, d.sDevice + isnull(' : ' + b.cBed, '')	as	sRoomBed
		,	a.tiIdx, s.idStfLvl, s.sStfLvl, s.sStfID, s.sStaff,	p.dtBeg, p.dtEnd
		from	#tbRpt1			t	with (nolock)
		join	tbStfCvrg		p	with (nolock)	on	p.idStfCvrg	= t.idStfCvrg
		join	tbStfAssn		a	with (nolock)	on	a.idStfAssn	= p.idStfAssn
		join	tbShift			h	with (nolock)	on	h.idShift	= a.idShift
		join	tbUnit			u	with (nolock)	on	u.idUnit	= h.idUnit
		join	tbDevice		d	with (nolock)	on	d.idDevice	= a.idRoom
		join	vwStaff			s	with (nolock)	on	s.idUser	= a.idUser
		left join	tbCfgBed	b	with (nolock)	on	b.tiBed		= a.tiBed
		order	by h.idUnit, a.idRoom, iShSeq, a.tiBed, a.tiIdx, p.idStfCvrg
end
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
--	7.06.8349	+ @cLoc, @sPath
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	7.06.5914	* optimized
--	7.06.5501	+ .sPath,	- @cLoc
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.00	* format idLoc as '000'
--	6.05
alter proc		dbo.prCfgLoc_Ins
(
	@idLoc		smallint
,	@idParent	smallint			-- parent look-up FK
,	@tiLvl		tinyint				-- level: 0=Facility 1=System 2=Building 3=Floor 4=Unit 5=CvrgArea
,	@cLoc		char( 1 )			-- type:  H=Hospital S=System B=Building F=Floor U=Unit A=CvrgArea
,	@sLoc		varchar( 16 )		-- location name
,	@sPath		varchar( 32 )		-- node path ([idParent.]idLoc) - for tree-ordered reads
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', p=' +
					isnull(right('00' + cast(@idParent as varchar), 3), '?') + ', ' +
					isnull(cast(@tiLvl as varchar), '?') + '|' + isnull(@cLoc, '?') + '|''' + isnull(@sLoc, '?') + ''', ' + isnull(@sPath, '?') + ''' )'

	begin	tran

		insert	tbCfgLoc	(  idLoc,  idParent,  tiLvl,  cLoc,  sLoc,  sPath )
				values		( @idLoc, @idParent, @tiLvl, @cLoc, @sLoc, @sPath )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8385	* 
--	7.06.8199	+ .tiColor
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.6044	+ .cDevice
--	7.06.6039	+ .idUnit, .sUnit, .iShSeq, .sShift, .dShift, .tBeg, .tEnd
--	7.06.6031	+ @tiShift
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	7.06.5408	* optimize @siBeds
--	7.06.5331	* @cBed -> @siBeds
--	7.06.5330	+ .tVoTrg, .tStTrg
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
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
			--		join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice = ec.idRoom
			--		join	tb_SessShift	ss	with (nolock)	on	ss.idShift = ec.idShift	and	ss.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
			--		and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
			--		join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessShift	ss	with (nolock)	on	ss.idShift = ec.idShift	and	ss.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice = ec.idRoom
			--		join	tb_SessShift	ss	with (nolock)	on	ss.idShift = ec.idShift	and	ss.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
			--		and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessShift	ss	with (nolock)	on	ss.idShift = ec.idShift	and	ss.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0

	select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
		,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	c.tVoTrg, c.tStTrg
		,	sh.sShift, ec.dShift, sh.tBeg, sh.tEnd
		,	cast(cast(cast(ec.dShift as datetime) + sh.tBeg as float) * 48 as int)	as	iShSeq
		,	case when cp.siFlags & 0x1000 > 0	then 0			else 1			end	as	iCall
		,	case when cp.siFlags & 0x1000 > 0	then null		else ec.tVoice	end	as	tVoice
		,	case when cp.siFlags & 0x1000 > 0	then null		else ec.tStaff	end	as	tStaff
		,	case when cp.tiSpec = 7				then ec.tStaff	else null		end	as	tGrn
		,	case when cp.tiSpec = 8				then ec.tStaff	else null		end	as	tOra
		,	case when cp.tiSpec = 9				then ec.tStaff	else null		end	as	tYel
		from	#tbRpt1		et	with (nolock)
		join	vwEvent_C	ec	with (nolock)	on	ec.idEvent = et.idEvent
		join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
		join	tbShift		sh	with (nolock)	on	sh.idShift = ec.idShift
		where	ec.idEvent	between @iFrom	and @iUpto
		and		ec.tiHH		between @tFrom	and @tUpto
		and		ec.dShift	between @dFrom	and @dUpto
		and		ec.siBed & @siBeds <> 0
		order	by	ec.idUnit, ec.idRoom, ec.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8405	* 
--	7.06.8385	* 
--	7.06.8199	+ .tiColor
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.6031	+ @tiShift
--	7.06.5483	* tbEvent_C:	.sAssn1 -> .sStaff1,	.sAssn2 -> .sStaff2,	.sAssn3 -> .sStaff3
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	7.06.5408	* optimize @siBeds
--	7.06.5395	* c.t??Trg -> sc.t??Trg in where
--	7.06.5372	* c.t??Trg -> sc.t??Trg
--	7.06.5331	* @cBed -> @siBeds
--	7.06.5329
alter proc		dbo.prRptCallActExc
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
					and		(sc.tStTrg < ec.tStaff	or	sc.tVoTrg < ec.tVoice)
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
					and		(sc.tStTrg < ec.tStaff	or	sc.tVoTrg < ec.tVoice)
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ec.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
					and		(sc.tStTrg < ec.tStaff	or	sc.tVoTrg < ec.tVoice)
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ec.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
					and		(sc.tStTrg < ec.tStaff	or	sc.tVoTrg < ec.tVoice)

	select	ec.idEvent, ec.idRoom, ec.cDevice, ec.sRoomBed, ec.dEvent, ec.tEvent, ec.cBed
		,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	c.tVoTrg, c.tStTrg,		ec.tVoice, ec.tStaff
		,	ec.idStLvl1, ec.sStaff1,	ec.idStLvl2, ec.sStaff2,	ec.idStLvl3, ec.sStaff3
		from	#tbRpt1			et	with (nolock)
		join	vwEvent_C		ec	with (nolock)	on	ec.idEvent	= et.idEvent
		join	tbCall			c	with (nolock)	on	c.idCall	= ec.idCall
		join	tbCfgPri		cp	with (nolock)	on	cp.siIdx	= c.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
--		where	ec.idEvent	between @iFrom	and @iUpto
--		and		ec.tiHH		between @tFrom	and @tUpto
--		and		ec.dShift	between @dFrom	and @dUpto
--		and		(sc.tStTrg < ec.tStaff	or	sc.tVoTrg < ec.tVoice)
--		and		ec.siBed & @siBeds <> 0
		order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8385	* 
--	7.06.8368	* .tiFlags -> .siFlags
--	7.06.7614	* Vo|St -> Good|Fair|Poor
--	7.06.7311
alter proc		dbo.prRptRndStatSum
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@f100		float

	set	nocount	on

	select	@f100 =		100

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0

	set	nocount	off

	select	siIdx, siFlags, sCall,			tVoTrg,	tStTrg, tStAvg, tStMax,		lCount
		,	lGood,	case when tStAvg is null	then null	else	lGood * @f100 / lCount	end	as	fGood
		,	lFair,	case when tStAvg is null	then null	else	lFair * @f100 / lCount	end	as	fFair
		,	lPoor,	case when tStAvg is null	then null	else	lPoor * @f100 / lCount	end	as	fPoor
		from
			(select	sc.siIdx,	count(*) as	lCount
				,	min(cp.siFlags)	as	siFlags
				,	min(sc.sCall)	as	sCall
				,	min(sc.tVoTrg)	as	tVoTrg
				,	min(sc.tStTrg)	as	tStTrg
				,	cast(cast(avg(cast(cast(ep.tWaitS as datetime) as float)) as datetime) as time(3))	as	tStAvg
				,	max(ep.tWaitS)	as	tStMax
	---			,	sum(case when 							ep.tWaitS is null		then 1 else 0 end)	as	lNull
				,	sum(case when 							ep.tWaitS <= sc.tVoTrg	then 1 else 0 end)	as	lGood
				,	sum(case when sc.tVoTrg < ep.tWaitS and ep.tWaitS <= sc.tStTrg	then 1 else 0 end)	as	lFair
				,	sum(case when sc.tStTrg < ep.tWaitS								then 1 else 0 end)	as	lPoor
				from	#tbRpt1		et	with (nolock)
				join	vwEvent_D	ep	with (nolock)	on	ep.idEvent	= et.idEvent
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall	= ep.idCall		and	sc.idSess	= @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx	= sc.siIdx		and	cp.siFlags & 0x0800 > 0
				where	cast( dateadd( mi, cp.tiIntOt, '0:0:0' ) as time(3) ) < ep.tWaitS
				group	by	sc.siIdx)	s
		order	by	siIdx desc
end
go
--	----------------------------------------------------------------------------
--	7.06.8385	* 
--	7.06.8368	* .tiFlags -> .siFlags
--	7.06.7614	* Vo|St -> Good|Fair|Poor
--	7.06.7311
alter proc		dbo.prRptRndStatDtl
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@f100		float

	set	nocount	on

	select	@f100 =		100

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0

	set	nocount	off

	select	e.idUnit, u.sUnit, e.idRoom, r.cDevice, r.sDevice,	e.dEvent
		,	e.siIdx, cp.siFlags, e.sCall,	tVoTrg,	tStTrg,	tStAvg, tStMax,		lCount
		,	lGood,	case when tStAvg is null	then null	else	lGood * @f100 / lCount	end	as	fGood
		,	lFair,	case when tStAvg is null	then null	else	lFair * @f100 / lCount	end	as	fFair
		,	lPoor,	case when tStAvg is null	then null	else	lPoor * @f100 / lCount	end	as	fPoor
		from
			(select	ep.idUnit, ep.idRoom, ep.dEvent
				,	sc.siIdx,	count(*) as	lCount
				,	min(cp.siFlags)	as	siFlags
				,	min(sc.sCall)	as	sCall
				,	min(sc.tVoTrg)	as	tVoTrg
				,	min(sc.tStTrg)	as	tStTrg
				,	cast(cast(avg(cast(cast(ep.tWaitS as datetime) as float)) as datetime) as time(3))	as	tStAvg
				,	max(ep.tWaitS)	as	tStMax
	---			,	sum(case when 							ep.tWaitS is null		then 1 else 0 end)	as	lNull
				,	sum(case when 							ep.tWaitS <= sc.tVoTrg	then 1 else 0 end)	as	lGood
				,	sum(case when sc.tVoTrg < ep.tWaitS and ep.tWaitS <= sc.tStTrg	then 1 else 0 end)	as	lFair
				,	sum(case when sc.tStTrg < ep.tWaitS								then 1 else 0 end)	as	lPoor
				from	#tbRpt1		et	with (nolock)
				join	vwEvent_D	ep	with (nolock)	on	ep.idEvent	= et.idEvent
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall	= ep.idCall		and	sc.idSess	= @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx	= sc.siIdx		and	cp.siFlags & 0x0800 > 0
				where	cast( dateadd( mi, cp.tiIntOt, '0:0:0' ) as time(3) ) < ep.tWaitS
				group	by	ep.idUnit, ep.idRoom, ep.dEvent, sc.siIdx)	e
		join	tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice	= e.idRoom
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx	= e.siIdx
		order	by	e.idUnit, e.idRoom, e.siIdx desc
end
go
--	----------------------------------------------------------------------------
--	7.06.8388	* 
--	7.06.8319	* output returns now int 10* %, rounded to no decimals
--	7.06.8194	+ .tiColor
--	7.06.7649	+ @f100
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.6030	+ @tiShift
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	7.06.5408	+ @siBeds
--	7.06.5395	* join tb_SessDvc
--	7.06.5373	* presence calls
--	7.05.5297	* presence calls
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
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@fPerc		float

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	select	@fPerc =	1000.0

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessDvc		d	with (nolock)	on	d.idDevice	= ec.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessDvc		d	with (nolock)	on	d.idDevice	= ec.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0

	select	idCall, lCount, t.siIdx, tiSpec, tiColor
		,	cast(case when tiSpec between 7 and 9	then 1	else 0	end	as tinyint)			as	tiPres
		,	case when cp.siFlags & 0x1000 > 0	then t.sCall + ' †'	else t.sCall	end		as	sCall
		,	case when cp.siFlags & 0x1000 > 0	then null			else tVoTrg		end		as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
		,	case when cp.siFlags & 0x1000 > 0	then null			else tStTrg		end		as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
		,	cast(round(case when lVoNul = lCount	then null	else lVoOnT*@fPerc/(lCount-lVoNul)	end, 0)	as int)	as	iVoOnT
		,	cast(round(case when lStNul = lCount	then null	else lStOnT*@fPerc/(lCount-lStNul)	end, 0)	as int)	as	iStOnT
		from
			(select	ec.idCall, count(*) as	lCount
				,	min(sc.siIdx)	as	siIdx,		min(sc.sCall)	as	sCall
				,	min(sc.tVoTrg)	as	tVoTrg,		min(sc.tStTrg)	as	tStTrg
				,	max(ec.tVoice)	as	tVoMax,		max(ec.tStaff)	as	tStMax
				,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
				,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
				,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
				,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
				,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
				,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				from	#tbRpt1			et	with (nolock)
				join	tbEvent_C		ec	with (nolock)	on	ec.idEvent	= et.idEvent
				join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
				group	by ec.idCall)	t
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx	= t.siIdx
		order by	siIdx desc
end
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.06.8405	* tbCall.bEnabled= true (available for Rpts)
--	7.06.5868	+ [29,30] tbCall.tVoTrg, .tStTrg defaults
--	7.06.5865	* fix for call escalation (allow duplicated call-texts)
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
		,		@tVoTrg		time( 0 )
		,		@tStTrg		time( 0 )

	set	nocount	on

	select	@siIdx =	@siIdx & 0x03FF		-- mask significant bits only [0..1023]
		,	@idCall =	null				-- not in tbCall

	select	@tVoTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
	select	@tStTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	select	@s =	'Call_GI( ' + isnull(cast(@siIdx as varchar), '?') + '|' + isnull(@sCall, '?') + ' )'

	if	@siIdx > 0
	begin
		-- match by priority-index
			select	@idCall =	idCall	from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0

---		if	@idCall is null					-- match by call-text			--	7.06.5865
---			select	@idCall =	idCall	from	tbCall	with (nolock)	where	sCall = @sCall	and	bActive > 0

		if	@idCall is null
		begin
			begin	tran

				if	@sCall is null	or	len( @sCall ) = 0
					select	@sCall =	sCall	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx

				insert	tbCall	(  siIdx,  sCall,  tVoTrg,  tStTrg, bEnabled )
						values	( @siIdx, @sCall, @tVoTrg, @tStTrg, 1 )
				select	@idCall =	scope_identity( )

				select	@s =	@s + '  id=' + cast(@idCall as varchar)
				exec	dbo.pr_Log_Ins	72, null, null, @s

			commit
		end
		else
			update	tbCall	set	bEnabled =	1	where	idCall = @idCall	--	7.06.8405
	end
end
go
--	----------------------------------------------------------------------------
--	<10,tbEvent84>
--	7.06.8409	- .siDuty0-3, .siZone0-3
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent84') and name = 'siDuty0')
begin
	begin tran
		exec( '
		alter table	dbo.tbEvent84		drop column	siZone3
		alter table	dbo.tbEvent84		drop column	siZone2
		alter table	dbo.tbEvent84		drop column	siZone1
		alter table	dbo.tbEvent84		drop column	siZone0
		alter table	dbo.tbEvent84		drop column	siDuty3
		alter table	dbo.tbEvent84		drop column	siDuty2
		alter table	dbo.tbEvent84		drop column	siDuty1
		alter table	dbo.tbEvent84		drop column	siDuty0
			' )
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8409	- @siDuty0-3, @siZone0-3
--	7.04.8343	* optimized bAnswered
--	7.06.5465	* tbEvent84:	.tiTmrSt -> .tiTmrA, .tiTmrRn -> .tiTmrG, .tiTmrCn -> .tiTmrO, .tiTmrAi -> .tiTmrY
--	7.04.4896	* tbDefCall -> tbCall
--	7.02	.tiCvrgA* -> .tiCvrg*, siDutyA* -> siDuty*, siZoneA* -> siZone*
--			.tiTmrStat -> .tiTmrSt, .tiTmrCna -> .tiTmrCn, .tiTmrAide -> .tiTmrAi
--	6.04	+ .bAnswered, + .cGender
--	6.00	tbDefDevice -> tbDevice (FKs)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	5.01	encryption added
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--	2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	1.00
alter view		dbo.vwEvent84
	with encryption
as
select	e84.idEvent, e.dtEvent, e.idCmd, e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID, e.tiBtn
	,	e.idSrcDvc, d.sDevice, e.idRoom, r.sDevice as sRoom, r.sDial, e.tiBed, e.idCall, c.sCall, e.idUnit
	,	e84.siPriOld, e84.siPriNew, e84.siIdxOld, e84.siIdxNew, e84.iFilter
	,	~cast( ((e84.siPriNew & 0x0400) / 0x0400) as bit )	as bAnswered
	,	e84.siElapsed, e84.tiPrivacy, e84.tiTmrA, e84.tiTmrG, e84.tiTmrO, e84.tiTmrY
	,	e84.idPatient, p.sPatient, p.cGender
	,	e84.idDoctor, v.sDoctor, e.sInfo
	,	e84.tiCvrg0, e84.tiCvrg1, e84.tiCvrg2, e84.tiCvrg3, e84.tiCvrg4, e84.tiCvrg5, e84.tiCvrg6, e84.tiCvrg7
	from	tbEvent84	e84
	join	tbEvent		e	on	e.idEvent = e84.idEvent
	join	tbCall		c	on	c.idCall = e.idCall
	join	tbDevice	d	on	d.idDevice = e.idSrcDvc
	join	tbDevice	r	on	r.idDevice = e.idRoom
	left join	tbPatient	p	on	p.idPatient = e84.idPatient
	left join	tbDoctor	v	on	v.idDoctor = e84.idDoctor
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
--	7.06.8409	- @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB
--	7.06.5487	* optimize
--	7.06.5485	- .siPri
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
,	@sSrcDvc	varchar( 16 )		-- source name
,	@sDstDvc	varchar( 16 )		-- destination name
,	@tiBed		tinyint				-- bed index
,	@siIdx		smallint			-- call-priority
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
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@iExpNrm	int
		,		@idLogType	tinyint

	set	nocount	on

	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	select	@idLogType =	case when	@idCmd = 0x8D	then	199			-- audio quit
								when	@idCmd = 0x8A	then	197			-- audio grant
								when	@idCmd = 0x88	then	196			-- audio busy
								else							195	end		-- audio request

	exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed	---	, @iAID, @tiStype, @idCall0

		--	this one is really not origin, but parent - audio is not being healed
		select	@idOrigin=	idEvent,	@dtOrigin=	dtEvent
			from	tbEvent_A	with (nolock)
			where	cSys = @cDstSys
				and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiBtn
				and	idCall = @idCall		--	7.05.4976
		---		and	bActive > 0				--	6.05 (6.04 in 84!):	audio events ignore active/inactive state

		if	@idOrigin	is not null
		begin
			update	tbEvent		set		idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin
				where	idEvent = @idEvent

			if	@idCmd = 0x8A		-- AUDIO GRANT == voice response
			begin
				update	tbEvent_A	set		bAudio =	1					-- connected
					where	idEvent = @idOrigin

				select	@dtOrigin=	tOrigin		--,	@idParent=	idParent
					from	tbEvent		with (nolock)
					where	idEvent = @idEvent

				update	tbEvent_C	set		idEvtVo =	@idEvent,	tVoice =	@dtOrigin
					where	idEvent = @idOrigin		and	idEvtVo is null		-- there should be only one, but just in case - use only 1st one
			end

			else if	@idCmd = 0x8D	-- AUDIO QUIT
			begin
				update	tbEvent_A	set		bAudio =	0					-- disconnected
								,	dtExpires=	case when bActive > 0 then dtExpires
													else dateadd(ss, @iExpNrm, getdate( )) end
					where	idEvent = @idOrigin
			end
		end
		else	-- no origin found
		begin
			update	tbEvent		set		idOrigin =	@idEvent,	tOrigin =	'0:0:0'
									,	idParent =	@idEvent,	tParent =	'0:0:0'	--	7.05.4976
									,	@idDstDvc=	idSrcDvc,	@dtOrigin=	dtEvent
									,	tiFlags =	@tiFlags
				where	idEvent = @idEvent
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Deletes sessions that are older than 24 hours
--	7.06.8412
create proc		dbo.pr_Sess_Maint
	with encryption
as
begin
	declare		@idSess		int

	set	nocount	on

	declare	cur		cursor fast_forward for
		select	idSess
			from	tb_Sess
			where	sMachine is not null 
			and		dateadd(hh, 24, dtLastAct) < getdate( )

--	begin	tran

	open	cur
	fetch next from	cur	into	@idSess
	while	@@fetch_status = 0
	begin
		exec	dbo.pr_Sess_Del		@idSess
	
		fetch next from	cur	into	@idSess
	end
	close	cur
	deallocate	cur

--	commit
end
go
grant	execute				on dbo.pr_Sess_Maint				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.8412	+ exec pr_Sess_Maint
--	7.06.7618	+ tbEvent_D cascade null
--	7.06.7467	* logging: Trc -> Dbg
--	7.06.7292	* tb_Option[11]<->[19]
--	7.06.7276	* optimized tracing
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@idEvent	int
		,		@iCount		int
		,		@tiPurge	tinyint			-- FF=keep everything
											-- N=remove auxiliary data older than N days (cascaded)
											-- 0=remove all inactive events from [tbEvent*] (cascaded)
	set	nocount	on

	select	@dt =	getdate( )												-- smalldatetime truncates seconds

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	ec	set	ec.idEvtVo =	null						-- implements CASCADE SET NULL
					from	tbEvent_C	ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtVo
					where	a.idEvent is null

				update	ec	set	ec.idEvtSt =	null
					from	tbEvent_C	ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtSt
					where	a.idEvent is null

				update	ed	set	ed.idEvntS =	null						-- implements CASCADE SET NULL
					from	tbEvent_D	ed
					left join	tbEvent_A	a	on	a.idEvent = ed.idEvntS
					where	a.idEvent is null

				update	ed	set	ed.idEvntD =	null
					from	tbEvent_D	ed
					left join	tbEvent_A	a	on	a.idEvent = ed.idEvntD
					where	a.idEvent is null

				delete	e	from	tbEvent	e
					left join	tbEvent_A	a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@iCount =	@@rowcount

--				if	@tiLog & 0x02 > 0										--	Config?
				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
					if	0 < @iCount
					begin
						select	@s =	'Ev_M( ' + cast(@tiPurge as varchar) + ' ) -' + cast(@iCount as varchar) +
										' in ' + convert(varchar, getdate() - @dt, 114)
	--					exec	dbo.pr_Log_Ins	1, null, null, @s			--	7.06.7276	trace is enough
						exec	dbo.pr_Log_Ins	0, null, null, @s			--	7.06.7467	debug
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

				update	tb_OptSys	set	iValue =	@idEvent,	dtUpdated=	@dt		where	idOption = 11
			end

		end

		exec	dbo.pr_Sess_Maint

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns details for specified users
--	7.06.8413	+ @bOnDuty
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
,	@bOnDuty	bit			= null	-- null=any, 0=off, 1=on
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
		and		(@bOnDuty is null	or	bOnDuty = @bOnDuty)
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
		and		(@sStaffID is null	or	sStaffID = @sStaffID)
		and		(@idUnit is null	or	idUser in (select idUser	from	tb_UserUnit	with (nolock)	where	idUnit = @idUnit))
end
go
--	----------------------------------------------------------------------------
--	7.06.8417	* [23]
begin tran
	update	dbo.tbReport	set	sReport =	'Clinic: Activity (Summary)'	where	idReport = 23
commit
go
--	----------------------------------------------------------------------------
--	Returns notifiable (everyting except presence) active call properties
--	7.06.8439	* .sDevice -> .sRoom
--	7.06.8417	* .sQnRoom -> .sDevice
--				- "or tiSpec is null" - useless condition
--	7.06.8343	* tbCfgPri.tiLvl -> .siFlags
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
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
		,	siIdx, sCall, tiColor, tiShelf, siFlags, tiSpec, bActive, bAnswered, tElapsed, tiSvc
		,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	(idEvent = @idEvent		or	@idEvent is null)
		and		siFlags & 0x1000 = 0										--	not presence	.8417
--		and		(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
end
go
--	----------------------------------------------------------------------------
--	7.06.8426	* [8]
begin tran
	update	dbo.tbStfLvl	set	cStfLvl =	'*'		where	idStfLvl = 8
commit
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
--	7.06.8426	+ log staff returning to duty from break
--	7.06.8318	* optimized tracing
--	7.06.6053	+ tbStfCvrg.dShift
--	7.06.6022	+ reporting DB recovery-model, file-sizes and log-reuse-wait in tb_Module[1].sParams
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.05.5176	* OnDuty does not affect currently assigned staff
--	7.05.5165	* set only OnDuty current staff, reset stale coverage
--	7.05.5123	* fix datetime arithmetics for 2012
--	7.05.5099	* fix #tbDueAssn logic
--	7.05.5086	* logic redesign involving new tbStfCvrg.dtDue
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg, prStaffCover_InsFin -> prStfCvrg_InsFin
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
--	7.02	* tbRoomStaff -> tbRoom
--	7.01	* updating assinged staff in tbRoomBed
--	7.00	+ updating assinged staff in tbRoomBed
--			+ pr_Module_Act call
--			tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--				prStaffAssn_InsFin -> prStaffCover_InsFin
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--			* set tbUnit.idShift
--	6.02
alter proc		dbo.prStfCvrg_InsFin
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@dtNow		smalldatetime
		,		@dtDue		smalldatetime
		,		@tNow		time( 0 )
		,		@dShift		date
		,		@idUser		int
		,		@idStfAssn	int
		,		@idStfCvrg	int

	set	nocount	on
	set	xact_abort	on

---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	create	table	#tbUser
	(
		idUser		int			not null	primary key clustered

	,	sQnStf		varchar( 36 )	not null
	)
	create	table	#tbDueAssn
	(
		idStfCvrg	int			not null	primary key clustered

	,	idStfAssn	int			not null
	)

	-- get recovery_model_desc and log_reuse_wait
	select	@dtNow =	getdate( )											-- smalldatetime truncates seconds
		,	@s =	'@' + @@servicename + ' ' + substring(recovery_model_desc, 1, 1) +
					',' + cast(log_reuse_wait as varchar)
		from master.sys.databases
		where	database_id = db_id( )

	select	@tNow =		@dtNow												-- time(0) truncates date, leaving HH:MM:00

	-- get a list of users whose break is expiring on this pass
	insert	#tbUser
		select	idUser, sQnStf	from	dbo.vwStaff		where	dtDue <= @dtNow
--		select	idUser	from	tb_User		where	dtDue <= @dtNow

	-- get .mdf (data) size
	select	@s +=	' ' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 0

	-- get .ldf (Tlog) size
	select	@s +=	'/' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 1

	update	tb_Module	set	sParams =	@s		where	idModule = 1		-- outside the transaction in order not to block

	begin	tran

		-- mark DB component active (since this sproc is executed every minute)
		exec	dbo.pr_Module_Act	1

		-- get assignments that are due to complete now
		insert	#tbDueAssn
			select	sc.idStfCvrg, sc.idStfAssn
				from	tbStfCvrg	sc	with (nolock)
				join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn	and	sa.bActive > 0	and	sa.idStfCvrg > 0
				where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

---		select	*	from	#tbDueAssn

		--	reset assigned staff in completed assignments
		update	rb	set		idUser1 =	null,	idUser2 =	null,	idUser3 =	null,	dtUpdated=	@dtNow
			from	tbRoomBed	rb
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		-- finish coverage for completed assignments
		update	sc	set		dtEnd=	@dtNow,	dEnd =	@dtNow,	tEnd =	@tNow,	tiEnd=	datepart(hh, @tNow)
			from	tbStfCvrg	sc
			join	#tbDueAssn	da	on	da.idStfAssn = sc.idStfAssn	and	da.idStfCvrg = sc.idStfCvrg
	---		where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

		--	reset coverage refs for completed assignments
		update	sa	set		idStfCvrg=	null,	dtUpdated=	@dtNow
			from	tbStfAssn	sa
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		-- reset coverage refs for completed assignments (stale)
		update	sa	set		idStfCvrg=	null,	dtUpdated=	@dtNow
			from	tbStfAssn	sa
			join	tbStfCvrg	sc	on	sc.idStfCvrg = sa.idStfCvrg	and	sc.dtEnd < @dtNow


		-- set current shift for each active unit
		update	u	set		idShift =	sh.idShift
			from	tbUnit	u
			join	tbShift	sh	on	sh.idUnit = u.idUnit
			where	u.bActive > 0
			and		sh.bActive > 0	and	u.idShift <> sh.idShift
			and		(	sh.tBeg <= @tNow	and	@tNow < sh.tEnd
					or	sh.tEnd <= sh.tBeg	and	(sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		-- set OnDuty staff, who finished break
		update	tb_User		set		bOnDuty =	1,	dtDue=	null,	dtUpdated=	@dtNow
			where	dtDue <= @dtNow

		-- log these staff transitions
		declare	cur		cursor fast_forward for
			select	idUser, sQnStf
				from	#tbUser

		open	cur
		fetch next from	cur	into	@idUser, @s
		while	@@fetch_status = 0
		begin
			exec	dbo.pr_Log_Ins	218, @idUser, null, @s	--, @idModule

			fetch next from	cur	into	@idUser, @s
		end
		close	cur
		deallocate	cur

		-- get assignments that should be started/running now, only for OnDuty staff
		declare	cur		cursor fast_forward for
			select	sa.idStfAssn,
			--		case when	sh.tBeg < sh.tEnd	then	@dtNow - @tNow + sh.tEnd		--	!! this works in 2008 R2, but not in 2012
				---		when	sh.tBeg = sh.tEnd	then	@dtNow - @tNow + sh.tEnd + 1	--	matches else (sh.tBeg > sh.tEnd) case
			--										else	@dtNow - @tNow + sh.tEnd + 1 end
					case when	sh.tBeg < sh.tEnd	then	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime)
													else	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime) + 1 end
				,	case when	sh.tEnd <= sh.tBeg	and	@tNow < sh.tEnd		then	dateadd( dd, -1, @dtNow )	else	@dtNow	end
				from	tbStfAssn	sa	with (nolock)
				join	tb_User		us	with (nolock)	on	us.idUser  = sa.idUser		and	us.bOnDuty > 0	-- only OnDuty
				join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		and	sh.bActive > 0
				where	sa.bActive > 0
				and		sa.idStfCvrg is null						--	not running now
				and		(	sh.tBeg <= @tNow	and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStfAssn, @dtDue, @dShift
		while	@@fetch_status = 0
		begin
---			print	cast(@idStfAssn, varchar) + ': ' + cast(@dtDue, varchar)
		
			insert	tbStfCvrg	(  idStfAssn, dtBeg, dBeg, tBeg, tiBeg, dtDue, dShift )
					values		( @idStfAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ), @dtDue, @dShift )
			select	@idStfCvrg =	scope_identity( )

			update	tbStfAssn	set		idStfCvrg=	@idStfCvrg,		dtUpdated=	@dtNow
				where	idStfAssn = @idStfAssn

			fetch next from	cur	into	@idStfAssn, @dtDue, @dShift
		end
		close	cur
		deallocate	cur

		-- set current assigned staff
		update	rb	set		idUser1 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
											and	sa.idShift = u.idShift	and	sa.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set		idUser2 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
											and	sa.idShift = u.idShift	and	sa.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

		update	rb	set		idUser3 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
											and	sa.idShift = u.idShift	and	sa.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bOnDuty > 0	-- only OnDuty

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8426	adjust for new range of choices in 7980cw
begin tran
	update	dbo.tbTeam	set	tResp=	'00:03:00'		where	tResp = '00:03:30'
	update	dbo.tbTeam	set	tResp=	'00:04:00'		where	tResp = '00:04:30'
	update	dbo.tbTeam	set	tResp=	'00:05:00'		where	tResp between '00:06:00' and '00:09:00'
	update	dbo.tbTeam	set	tResp=	'00:20:00'		where	tResp = '00:25:00'
	update	dbo.tbTeam	set	tResp=	'00:30:00'		where	tResp = '00:35:00'
	update	dbo.tbTeam	set	tResp=	'00:45:00'		where	tResp between '00:50:00' and '00:55:00'
commit
go
--	----------------------------------------------------------------------------
--	7.06.8431	* .tiFlags:	0x02=assignable (badges)
begin tran
	update	dbo.tbDvc	set	tiFlags =	0x02					where	idDvcType = 1	and	tiFlags = 0
	update	dbo.tbDvc	set	tiFlags =	0,	idUser =	null	where	idDvcType = 1	and	bActive = 0
commit
go
--	----------------------------------------------------------------------------
--	7.06.8432	* tv_User_Duty:		ony active staff may be OnDuty|OnBreak
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tv_User_Duty')
begin
	begin tran
		update	dbo.tb_User	set	bOnDuty =	0,	dtDue=	null,	dtUpdated=	getdate( )
			where	bActive = 0		and	(bOnDuty > 0	or	dtDue is not null)

		alter table	dbo.tb_User	drop constraint	tv_User_Duty

		alter table	dbo.tb_User	add
			constraint	tv_User_Duty	check	( (bOnDuty = 0	and	(dtDue is null	or	bActive > 0))	or	bOnDuty > 0  and  dtDue is null  and  bActive > 0 )
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
--	7.06.8432	+ @idModule
--	7.06.7447	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6814	* added logging of units
--	7.05.5233	optimized
--	7.05.5021
alter proc		dbo.pr_Role_InsUpd
(
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
,	@idRole		smallint		out	-- role, acted upon
,	@sRole		varchar( 16 )
,	@sDesc		varchar( 255 )
,	@bActive	bit
,	@sUnits		varchar( 255 )
)
	with encryption, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@idLogType	tinyint

	set	nocount	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	select	@s =	isnull(cast(@idRole as varchar), '?') + '|' + @sRole + ', ''' + isnull(cast(@sDesc as varchar), '?') +
					''' a=' + cast(@bActive as varchar) + ' u=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_Role where idRole = @idRole)
		begin
			insert	tb_Role	(  sRole,  sDesc,  bActive )
					values	( @sRole, @sDesc, @bActive )
			select	@idRole =	scope_identity( )

			select	@idLogType =	242,	@s =	'Role_I( ' + @s + ' )=' + cast(@idRole as varchar)
		end
		else
		begin
			update	tb_Role	set	sRole=	@sRole,		sDesc=	@sDesc,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idRole = @idRole

			select	@idLogType =	243,	@s =	'Role_U( ' + @s + ' )'
		end

		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

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
--	Inserts or updates a team
--	7.06.8432	+ @idModule
--	7.06.7368	+ .bEmail
--	7.06.7279	* optimized logging
--	7.06.6814	* tbTeamPri -> tbTeamCall
--				- tbTeam.sCalls, .sUnits
--				* added logging of calls and units
--	7.06.5380	* prCfgPri_SetTmpFlt -> prCall_SetTmpFlt
--	7.05.5191	* fix tbTeamUnit insertion
--	7.05.5182	+ .sUnits, .sCalls
--	7.05.5021
alter proc		dbo.prTeam_InsUpd
(
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
,	@idTeam		smallint out		-- team, acted upon
,	@sTeam		varchar( 16 )
,	@tResp		time( 0 )
,	@bEmail		bit
,	@sDesc		varchar( 255 )
,	@sCalls		varchar( 255 )
,	@sUnits		varchar( 255 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@idLogType	tinyint

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

	select	@s =	isnull(cast(@idTeam as varchar), '?') + '|' + @sTeam + ' ' + convert(varchar, @tResp, 108) +
					' ''' + isnull(cast(@sDesc as varchar), '?') + ''' @=' + cast(@bEmail as varchar) + ' a=' + cast(@bActive as varchar) +
					' c=' + isnull(cast(@sCalls as varchar), '?') + ' u=' + isnull(cast(@sUnits as varchar), '?')
					-- + ' ' + convert(varchar, @dtCreated, 20) + ' ' + convert(varchar, @dtUpdated, 20)
	begin	tran

		if	not exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			insert	tbTeam	(  sTeam,  sDesc,  bEmail,  tResp,  bActive )	--,  sCalls,  sUnits
					values	( @sTeam, @sDesc, @bEmail, @tResp, @bActive )	--, @sCalls, @sUnits
			select	@idTeam =	scope_identity( )

			select	@idLogType =	247,	@s =	'Team_I( ' + @s + ' )=' + cast(@idTeam as varchar)
		end
		else
		begin
			select	@idLogType =	248,	@s =	'Team_U( ' + @s + ' )'

			update	tbTeam	set	sTeam=	@sTeam,		tResp=	@tResp,		bEmail =	@bEmail,		sDesc=	@sDesc
						,	bActive =	@bActive,	dtUpdated=	getdate( )	--,	sCalls=	@sCalls,	sUnits=	@sUnits
				where	idTeam = @idTeam
		end

		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

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
--	Inserts or updates a notification device
--	7.06.8432	+ @idModule
--	7.06.8431	+ reset user for group device (pager)
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
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
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
	declare		@s			varchar( 255 )
		,		@idLogType	tinyint

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

	if	@idDvcType & 0x09 > 0		--	Badge|Wi-Fi
		select	@sUnits =	null,	@sTeams =	null						-- enforce no Units or Teams for Badges|Wi-Fi devices
	else
	begin
		exec	dbo.prUnit_SetTmpFlt	@sUnits
		exec	dbo.prTeam_SetTmpFlt	@sTeams
	end

	select	@s =	isnull(cast(@idDvc as varchar), '?') + '| t=' + cast(@idDvcType as varchar) + ', ''' + @sDvc +
					''', b=' + isnull(cast(@sBarCode as varchar), '?') + ', #' + isnull(cast(@sDial as varchar), '?') +
					', f=' + cast(cast(@tiFlags as varbinary(2)) as varchar) + ', a=' + cast(@bActive as varchar) +
					', U=' + isnull(cast(@sUnits as varchar), '?') + ', T=' + isnull(cast(@sTeams as varchar), '?')
---	exec	dbo.pr_Log_Ins	1, @idUser, null, @s, @idModule

	begin	tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  bActive )
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @bActive )
			select	@idDvc =	scope_identity( )

			select	@idLogType =	247,	@s =	'Dvc_I( ' + @s + ' )=' + cast(@idDvc as varchar)
		end
		else
		begin
			select	@idLogType =	248,	@s =	'Dvc_U( ' + @s + ' )'

			update	tbDvc	set	idDvcType=	@idDvcType,		sDvc =		@sDvc
							,	sDial=		@sDial,			sBarCode =	@sBarCode,		tiFlags =	@tiFlags
							,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc

			if	@bActive = 0												-- unassign deactivated
			begin
				if	@idDvcType = 0x01		--	Badge						--	7.06.8431
					update	tbDvc	set	tiFlags =	0						-- make inactive badge unassignable
						where	idDvc = @idDvc
	--				update	tbRtlsBadge		set	dtEntered=	null
	--					where	idBadge = @idDvc

				update	tbDvc	set	idUser =	null
					where	idDvc = @idDvc	and	idUser is not null
			end
		end

		if	@idDvcType = 0x02		--	Pager								--	7.06.8431
			and	@tiFlags = 1		--	group
			update	tbDvc	set	idUser =	null							-- reset user for group device (pager)
				where	idDvc = @idDvc	and	idUser is not null
		else
		if	@idDvcType = 0x08		--	Wi-Fi
			update	tbDvc	set	sBarCode =	cast(@idDvc as varchar)			-- enforce barcode to == DvcID for Wi-Fi devices
				where	idDvc = @idDvc

		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

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
--	----------------------------------------------------------------------------
--	Sets user's Duty and Break states
--	7.06.8489	* round to next minute when going on break (@tiMin + 1)
--	7.06.8432	+ verification of bActive > 0
--	7.06.8137	* sFqStaff -> sQnStf
--	7.06.6710	+ logging
--	7.05.5172	* fix @bOnDuty condition
--	7.05.5171
alter proc		dbo.prStaff_SetDuty
(
	@idModule	tinyint
,	@idUser		int
,	@bOnDuty	bit		--	=	null	--	0=OffDuty, 1=OnDuty, null=see @tiMins
,	@tiMins		tinyint					--	0=finish break, >0=break time, null=see @bOnDuty
)
	with encryption	--, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@dtNow		smalldatetime
		,		@tNow		time( 0 )
		,		@idLogType	tinyint
		,		@bOn		bit
		,		@dtDue		smalldatetime

	set	nocount	on
	set	xact_abort	on

	select	@bOn =	bOnDuty,	@dtDue =	dtDue,	@s =	sQnStf
		from	dbo.vwStaff	with (nolock)
		where	idUser = @idUser	and	bActive > 0

	if	@@rowcount > 0
	begin
		select	@dtNow =	getdate( )		-- smalldatetime truncates seconds
		select	@tNow =		@dtNow			-- time(0) truncates date, leaving HH:MM:00

		begin	tran

			if	@bOnDuty > 0												-- set OnDuty
			begin
				if	@bOn = 0												-- was Off|OnBreak
				begin
					update	tb_User		set		bOnDuty =	1,	dtUpdated=	@dtNow,		dtDue=	null
						where	idUser = @idUser	and	bActive > 0

					exec	dbo.pr_Log_Ins	218, @idUser, null, @s, @idModule

					exec	dbo.prStfCvrg_InsFin							-- init coverage
				end
			end
			else	--	@bOnDuty = 0										-- set OffDuty
			begin
				if	@bOn > 0	or	@dtDue is not null						-- was OnDuty|OnBreak
				begin
					update	tb_User		set		bOnDuty =	0,	dtUpdated=	@dtNow
											,	dtDue=	case when @tiMins > 0 then dateadd( mi, @tiMins + 1, @dtNow ) else null end
						where	idUser = @idUser

					-- reset coverage refs for interrupted assignments
					update	sa	set		idStfCvrg=	null,	dtUpdated=	@dtNow
						from	tbStfAssn	sa
						join	tbStfCvrg	sc	on	sc.idStfCvrg = sa.idStfCvrg	and	sc.dtEnd is null
						where	sa.idUser = @idUser

					-- finish coverage for interrupted assignments
					update	sc	set		dtEnd=	@dtNow,		dEnd =	@dtNow,		tEnd =	@tNow,	tiEnd=	datepart( hh, @tNow )
						from	tbStfCvrg	sc
						join	tbStfAssn	sa	on	sa.idStfAssn = sc.idStfAssn	and	sa.idUser = @idUser
						where	sc.dtEnd is null

					select	@s =		@s +	case when @tiMins > 0 then ' for ' + cast(@tiMins as varchar) + ' min' else '' end
							,	@idLogType =	case when @tiMins > 0 then 219 else 220 end

					exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
				end
			end

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
--	7.06.8488	* fix prStaff_SetDuty call
--	7.06.8432	+ @idModule for prStaff_SetDuty
--				+ exec dbo.prStaff_SetDuty
--	7.06.7433	* optimized logging
--	7.06.7326	* enforce 'Other' users un-assignable and off-duty
--				* inactive user can't stay on-duty
--	7.06.7279	* optimized logging
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
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
,	@idOper		int			out		-- operand user, acted upon
,	@sUser		varchar( 32 )
,	@iHash		int
,	@tiFails	tinyint
,	@sFrst		varchar( 16 )
,	@sMidd		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
,	@sStaffID	varchar( 16 )
,	@idStfLvl	tinyint
,	@sBarCode	varchar( 32 )
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
,	@sRoles		varchar( 255 )
,	@bOnDuty	bit
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@idLogType	tinyint

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

	if	@bActive = 0		select	@bOnDuty =	0							--	7.06.7326
	if	@idStfLvl is null	select	@bOnDuty =	0,	@sUnits =	null		--	7.06.7334

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	if	not exists	(select 1 from #tbRole with (nolock) where idRole = 1)
		insert	#tbRole		(idRole)	values	( 1 )						-- enforce membership in 'Public' role

	select	@s =	isnull(cast(@idOper as varchar), '?') + '|' + @sUser + ', ''' + isnull(cast(@sFrst as varchar), '?') +
					''' ''' + isnull(cast(@sMidd as varchar), '?') + ''' ''' + isnull(cast(@sLast as varchar), '?') +
					''' ' + isnull(cast(@sEmail as varchar), '?') + ' d=''' + isnull(cast(@sDesc as varchar), '?') +
					''', I=' + isnull(cast(@sStaffID as varchar), '?') + ' L=' + isnull(cast(@idStfLvl as varchar), '?') +
					' B=' + isnull(cast(@sBarCode as varchar), '?') + ', D=' + isnull(cast(@bOnDuty as varchar), '?') +
					' k=' + cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' R=' + isnull(cast(@sRoles as varchar), '?') +
					' T=' + isnull(cast(@sTeams as varchar), '?') + ' U=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc, sStaff,  sStaffID,  idStfLvl,  sBarCode,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc,    ' ', @sStaffID, @idStfLvl, @sBarCode, @bActive )
			select	@idOper =	scope_identity( )
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bOnDuty, 0		--	.8488	must follow table update

			select	@idLogType =	237,	@s =	'Usr_I( ' + @s + ' )=' + cast(@idOper as varchar)
		end
		else
		begin
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bOnDuty, 0		--	.8488	must precede table update
			update	tb_User	set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
								,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
								,	sStaffID =	@sStaffID,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode
								,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@idLogType =	238,	@s =	'Usr_U( ' + @s + ' )'
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper
--	-	exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bOnDuty, 0
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, @idOper, @s, @idModule

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
--	Registers Wi-Fi devices
--	7.06.8432	+ @idModule for prStaff_SetDuty
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
		,		@bActive	bit
		,		@idLogType	tinyint

	set	nocount	on

	select	@s =	'@ ' + isnull( @sIpAddr, '?' ) + ' ''' + isnull( @sUser, '?' ) + ''''

	select	@bActive =	bActive
		from	dbo.tbDvc		with (nolock)
		where	idDvc = @idDvc
		and		idDvcType = 0x08		--	wi-fi

	if	@bActive is null		--	wrong dvc
	begin
		select	@idLogType =	226		--,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@bActive = 0			--	inactive dvc
	begin
		select	@idLogType =	227,	@s =	@s + ', [' + isnull( @idDvc, '?' ) + ']'
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	select	@idUser =	idUser
		from	dbo.tb_User		with (nolock)
		where	(sUser = lower( @sUser )	or	sStaffID = @sUser)

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222		--,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule
		return	@idLogType
	end

	exec				dbo.pr_Sess_Ins		@sSessID, @idModule, null, @sIpAddr, @sDvc, 0, @sBrowser, @idSess out
	exec	@idLogType=	dbo.pr_User_Login	@idSess, @sUser, @iHash, @idUser out, @sStaff out, @bAdmin out, @sStaffID out

	if	@idLogType = 221		--	success
	begin
		begin	tran

			exec	dbo.prStaff_SetDuty		@idModule, @idUser, 1, 0

			update	dbo.tbDvc	set	idUser =	@idUser,	sDvc =	@sDvc,	sBrowser =	@sBrowser
				where	idDvc = @idDvc

		commit
	end

	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Updates 790 device assigned to a given receiver (used by RTLS demo)
--	7.06.6297	* optimized
--	7.06.6225	- tbRtlsRoom
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.04.4892	* tbRtlsRcvr:	.idDevice -> .idRoom
--				@idDevice -> @idRoom
--				+ check for tbRoom
--	7.00	.tiPtype -> .idStaffLvl
--	6.03
alter proc		dbo.prRtlsRcvr_UpdDvc
(
	@idReceiver		smallint			-- receiver id
,	@idRoom			smallint			-- room id
)
	with encryption
as
begin
--	set	nocount	on

--	begin	tran
		update	tbRtlsRcvr	set	idRoom =	@idRoom,	dtUpdated=	getdate( )
			where	idReceiver = @idReceiver
--	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge (used by RTLS demo)
--	7.06.8434	* put RTLS auto-badges ON duty
--	7.06.8320	* no units for RTLS auto-badges
--	7.06.8276	+ @idStfLvl:	when > 0, a new [tb_User] is created with 0x7F + '.idBadge' as .sStaff
--	7.06.5424	* set tbDvc.sDial
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
,	@idStfLvl		tinyint				-- 4=Grn, 2=Ora, 1=Yel, 0=None
)
	with encryption, exec as owner
as
begin
	declare		@idUser	int
		,		@sUser	varchar( 32 )
		,		@sRtls	varchar( 16 )

---	set	nocount	on
	begin	tran

		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
		begin
			update	dbo.tbDvc		set	bActive =	1,	dtUpdated=	getdate( ),	sDial=	cast(@idBadge as varchar)
				where	idDvc = @idBadge	and	bActive = 0

			update	dbo.tbRtlsBadge	set	bActive =	1,	dtUpdated=	getdate( )
				where	idBadge = @idBadge	and	bActive = 0
		end
		else
		begin
			set identity_insert	dbo.tbDvc	on

			insert	dbo.tbDvc	( idDvc, idDvcType, sDial, sDvc )
					values		( @idBadge, 1, cast(@idBadge as varchar), 'Badge ' + right('00000000' + cast(@idBadge as varchar), 8) )

			set identity_insert	dbo.tbDvc	off

			insert	dbo.tbRtlsBadge	( idBadge )
					values		( @idBadge )
		end

		if	0 < @idStfLvl
		begin
			select	@sUser =	cast(@idBadge as varchar)					--	create a new [tb_User]
				,	@sRtls =	char(0x7F) + 'RTLS'							--	with 0x7F+'RTLS' as .sFrst

			if	not exists	(select 1 from tb_User with (nolock) where sUser = @sUser)
			begin
				exec	dbo.pr_User_InsUpd	2, @idUser out, @sUser, 0, 0, @sRtls, null, @sUser, null, null, @sUser, @idStfLvl, null, null, null, null, 1, 1
										--	iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc, sStfID, idLvl, sBarCode, sUnits, sTeams, sRoles, bOnDuty, bActive

				update	u	set	dtEntered=	getdate( ),	idRoom =	null	--	clear previously assigned user's location
					from	dbo.tb_User u
					join	dbo.tbDvc	d	on	d.idUser = u.idUser
					where	idDvc = @idBadge

				update	dbo.tbDvc	set tiFlags =	1,	idUser =	@idUser	--	mark this badge un-assignable and assign it to newly created user
					where	idDvc = @idBadge
			end
			else
			begin
				update	dbo.tbDvc	set	tiFlags =	1
					where	idDvc = @idBadge
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets location attributes for all badges (used by RTLS demo)
--	7.06.7292	+ tbRoom.idUser4, .idUser2, .idUser1
--	7.06.7262	+ tbRoom.tiCall
--	7.06.7261	- .idRcvrLast (fkRtlsBadge_LastRcvr), .dtRcvrLast, .idRoom (fkRtlsBadge_Room)
--				* .idRcvrCurr -> .idReceiver (fkRtlsBadge_CurrRcvr -> fkRtlsBadge_Receiver), .dtRcvrCurr -> .dtReceiver
--	7.06.7248	+ reset idRcvrCurr, dtRcvrCurr, idRcvrLast, dtRcvrLast
--	7.06.6297	* optimized
--	7.06.6282	* tbRoom.dtExpires:= @dt
--	7.06.6225	+ tbRoom.dtExpires
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.05.5192	+ tbRoom
--	7.05.5099	+ tb_User.idRoom
--	7.03.4898	* prBadge_ClrAll -> prRtlsBadge_RstLoc
--	6.03
alter proc		dbo.prRtlsBadge_RstLoc
	with encryption
as
begin
	declare		@dt			datetime

	set	nocount	on

	select	@dt =	getdate( )

	begin	tran

		update	tbRtlsBadge	set dtEntered=	@dt,	dtUpdated=	@dt	--,	idRoom =	null
							,	idReceiver =	null,	dtReceiver =	null
--							,	idRcvrCurr =	null,	dtRcvrCurr =	null
--							,	idRcvrLast =	null,	dtRcvrLast =	null

		update	tb_User		set	dtEntered=	@dt,	idRoom =	null

		update	tbRoom		set	dtUpdated=	@dt,	dtExpires=	@dt,	tiCall =	0
							,	idUser4 =	null,	idUser2 =	null,	idUser1 =	null
							,	idUserG =	null,	idUserO =	null,	idUserY =	null
							,	sStaffG =	null,	sStaffO =	null,	sStaffY =	null

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge (used by RTLS demo)
--	7.06.8276	* @idStfLvl:	out -> in,	param order
--	7.06.7355	+ reset previous room's .tiCall
--	7.06.7292	+ tbRoom.idUser4, .idUser2, .idUser1
--	7.06.7277	* optimized logging
--	7.06.7265	* set entry tbRoom.dtExpires for 1s later
--	7.06.7262	+ tbRoom.tiCall
--	7.06.7261	* optimized logic, changed @rgs
--	7.06.7248	+ @idUser, @sStaff, @sRoomPrev, @sRoomCurr
--	7.06.6297	* setting tbRoom.idUser?
--	7.06.6246	+ clear tbRoom.idUser?, .sStaff?
--				* optimized
--	7.06.6225	+ tbRoom.dtExpires
--				- tbRtlsRoom
--	7.06.5788	* return value indicates rejected ID;  logging is trace-bit controlled
--	7.05.5147	+ check+log receiver IDs
--	7.05.5102	* @idOldest smallint -> int
--	7.05.5099	+ tb_User.idRoom
--	7.04.4898	* prBadge_UpdLoc -> prRtlsBadge_UpdLoc
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.04.4892	* tbRtlsRcvr:	.idDevice -> .idRoom
--	7.02	* commented out tracing non-existing badges - too much output
--			* @idBadge: smallint -> int
--	7.00	.tiPtype -> .idStaffLvl
--	6.03
alter proc		dbo.prRtlsBadge_UpdLoc
(
	@idBadge		int					-- 24 bits: 1..16777215 - RTLS badges
,	@idStfLvl		tinyint			out	-- 4=Grn, 2=Ora, 1=Yel, 0=None
,	@idReceiver		smallint			-- current receiver look-up FK
,	@dtReceiver		datetime			-- when registered by current rcvr
,	@bCall			bit					-- 
,	@idUser			int				out
,	@sStaff			varchar( 16 )	out
,	@dtEntered		datetime		out	-- when entered the room
,	@idRoom			smallint		out	-- current 790 device look-up FK
,	@sRoom			varchar( 20 )	out
)
	with encryption
as
begin
	declare		@iRetVal	smallint
		,		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@dt1		datetime
		,		@idFrom		smallint		--	room, from which the badge moved
		,		@idStff		int				--	oldest staff in room
		,		@sStff		varchar( 16 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	tb_Module	with (nolock)	where	idModule = 1

	select	@dt =	getdate( ),		@dt1 =	dateadd(ss, 1, getdate( )),		@iRetVal =	0
		,	@s =	'Bdg_UL( ' + isnull(cast(@idBadge as varchar),'?') + ', ' +
					isnull(cast(@idReceiver as varchar),'?') + ', ''' + isnull(convert(char(19), @dtReceiver, 121),'?') + '''' +
					case when @bCall > 0 then ' +' else '' end + ' )'

	exec	dbo.prRtlsBadge_InsUpd	@idBadge, @idStfLvl						--	auto-insert new badges		--	7.06.8276

	select	@idUser =	idUser,		@idStfLvl =		idStfLvl,	@sStaff =	sStaff
		,	@idFrom =	idRoom,		@dtEntered =	dtEntered,	@sStff =	sDevice
		from	vwRtlsBadge	with (nolock)
		where	idBadge = @idBadge											--	get assigned user's details and previous room

--	select	@idRoom =	idRoom,		@sRoom =	'[' + cDevice + '] ' + sDevice
	select	@idRoom =	idRoom,		@sRoom =	sDevice
		from	vwRtlsRcvr	with (nolock)
		where	idReceiver = @idReceiver									--	get entered room's details

	select	@s =	@s + '<br/> ' + case when @idStfLvl = 4 then 'G' when @idStfLvl = 2 then 'O' when @idStfLvl = 1 then 'Y' else '?' end + ':' +
						isnull(cast(@idUser as varchar),'?') + '|' + isnull(cast(@sStaff as varchar),'?') + ', ' +
						isnull(cast(@idFrom as varchar),'?') + '|' + isnull(cast(@sStff as varchar),'?') + ' >> ' +
						isnull(cast(@idRoom as varchar),'?') + '|' + isnull(cast(@sRoom as varchar),'?')

---	if	@tiLog & 0x04 > 0													--	Debug?
---		exec	dbo.pr_Log_Ins	0, null, null, @s

	begin	tran

		update	tbRtlsBadge		set	dtUpdated=	@dt,	idReceiver =	@idReceiver,	dtReceiver =	@dtReceiver
			where	idBadge = @idBadge										--	set badge's new receiver
			and	(		idReceiver <> @idReceiver							--	if different from previous
				or	0 < idReceiver	and	@idReceiver	is null
				or	0 < @idReceiver	and	idReceiver	is null)

		if	0 < @bCall	and	0 < @idStfLvl
			update	tbRoom		set	dtUpdated=	@dt,	dtExpires=	@dt,	tiCall |=	@idStfLvl
				where	idRoom = @idRoom									--	raise badge-call state


		if			@idRoom <> @idFrom										--	badge moved to another room
			or	0 < @idFrom  and  @idRoom	is null							--	or exited
			or	0 < @idRoom  and  @idFrom	is null							--	or entered
		begin

			update	tbRtlsBadge		set	dtEntered=	@dt,	@dtEntered =	@dt,	@iRetVal =	1
				where	idBadge = @idBadge									--	set badge's new location

			update	tb_User			set	dtEntered=	@dt,	idRoom =	@idRoom,	@iRetVal =	2
				where	idUser = @idUser									--	update user's location


			select	@idStff =	null	--,	@sStff =	null				--	get oldest staff in previous room
			select	top 1	@idStff =	idUser	--,		@sStff =	sStaff
				from	vwRtlsBadge		with (nolock)
				where	idRoom = @idFrom	and	idStfLvl = @idStfLvl
				order	by	dtEntered

			--	set previous room to the oldest staff
			if	@idStfLvl = 4
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
								,	tiCall =	case when @idStff is null	then	tiCall & 0xFB	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			else
			if	@idStfLvl = 2
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
								,	tiCall =	case when @idStff is null	then	tiCall & 0xFD	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			else
		--	if	@idStfLvl = 1
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	@idStff	--,	sStaffY =	@sStff
								,	tiCall =	case when @idStff is null	then	tiCall & 0xFE	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser1 is null
						or	@idStff is null
						or	@idStff <> idUser1	)


			select	@idStff =	null	--,	@sStff =	null				--	get oldest staff in current room
			select	top 1	@idStff =	idUser	--,		@sStff =	sStaff
				from	vwRtlsBadge		with (nolock)
				where	idRoom = @idRoom	and	idStfLvl = @idStfLvl
				order	by	dtEntered

			--	remove that user from any [other] room and set current room to him/her
			if	@idStfLvl = 4
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	null	--,	sStaffG =	null
					where	idUser4 = @idStff

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			end
			else
			if	@idStfLvl = 2
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	null	--,	sStaffO =	null
					where	idUser2 = @idStff

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			end
			else
		--	if	@idStfLvl = 1
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	null	--,	sStaffY =	null
					where	idUser1 = @idStff

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	@idStff	--,	sStaffY =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser1 is null
						or	@idStff is null
						or	@idStff <> idUser1	)
			end

		end

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	0, null, null, @s

	commit

	return	@iRetVal
end
go
--	----------------------------------------------------------------------------
--	7.06.8434	* put RTLS auto-badges ON duty
begin tran
	update	dbo.tb_User	set	bOnDuty =	1,	dtDue=	null	where	sFrst = char(0x7F) + 'RTLS'
commit
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
--	7.06.8444	* optimized trace
--	7.06.8143	* optimized trace
--	7.06.7467	* optimized logic
--	7.06.7279	* optimized logging
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

--	select	@s =	'Mod_Reg( ' + isnull(@sVersion, '?')	-- + ', ' + isnull(@sModule, '?') + right('00' + cast(@idModule as varchar), 3) + '|'
	select	@s =	isnull(@sVersion, '?')	-- + ', ' + isnull(@sModule, '?') + right('00' + cast(@idModule as varchar), 3) + '|'
		,	@idLogType =	62

	if	@sMachine is not null												-- register
	begin
		if	@sIpAddr is not null
			select	@s =	@s + ', ip=' + @sIpAddr

		select	@s =	@s + ', ' + isnull(@sMachine, '?') + ', ''' + isnull(@sDesc, '?') + ''''	-- + isnull(cast(@bLicense as varchar), '?')
			,	@idLogType =	61

		if	@bLicense is null	or	@bLicense = 0
			select	@s =	@s + ', l=0'
	end

--	select	@s =	@s + ' )'

	begin	tran

		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule)
		begin
			if	@sMachine is null	--	and	@sIpAddr is null				-- un-register
--			begin
				update	tb_Module	set		sIpAddr =	null,		sMachine =	null,		sVersion =	null
										,	dtStart =	null,		sParams =	null
					where	idModule = @idModule

--				select	@s =	'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', ' + isnull(@sVersion, '?') + ' )'
--					,	@idLogType =	62
--			end
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
--	Device button inputs (790 local configuration)
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn
--				* .siPri -> .siIdx
--	7.03
create table	dbo.tbCfgBtn
(
	idDevice	smallint not null			-- 790 device look-up FK
		constraint	fkCfgBtn_CfgDvc		foreign key references tbDevice
,	tiBtn		tinyint not null			-- button code (0-31)

,	siIdx		smallint not null			-- priority			-- no FK enforcement
---		constraint	fkCfgDvcBtn_CfgPri		foreign key references tbCfgPri	-- tbCfgPri
,	tiBed		tinyint null				-- bed index		-- no FK enforcement
---		constraint	fkCfgDvcBtn_CfgBed		foreign key references tbCfgBed	-- tbCfgBed

,	constraint	xpCfgBtn		primary key clustered ( idDevice, tiBtn )
)
go
grant	select, insert, update, delete	on dbo.tbCfgBtn			to [rWriter]
grant	select							on dbo.tbCfgBtn			to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all device button inputs
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn,	prCfgDvcBtn_Clr -> prCfgBtn_Clr
--	7.06.7279	* optimized logging
--	7.06.5914	* 74->76
--	7.06.5905	* 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgBtn_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	dbo.tbCfgBtn
		select	@s =	'CfgBtn_C( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	76, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgBtn_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a device button input
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn,	prCfgDvcBtn_Ins -> prCfgBtn_Ins
--				* .siPri -> .siIdx
--	7.06.7279	* optimized logging
--	7.06.5914	* trace:0x20, 74->76
--	7.06.5905	* trace:0x04, 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgBtn_Ins
(
	@idDevice	smallint			-- device (PK)
,	@tiBtn		tinyint				-- button code (0-31)
,	@siIdx		smallint			-- priority (0-1023)
,	@tiBed		tinyint				-- bed index (0-9, null==None)
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'CfgBtn_I( ' + isnull(cast(@idDevice as varchar), '?') + ' #' + isnull(cast(@tiBtn as varchar), '?') +
					', p=' + isnull(cast(@siIdx as varchar), '?') + ', b=' + isnull(cast(@tiBed as varchar), '?') + ' )'

	if	@tiBed = 0xFF		select	@tiBed =	null						--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgBtn with (nolock) where idDevice = @idDevice and tiBtn = @tiBtn)
	begin
		begin	tran

			insert	tbCfgBtn	(  idDevice,  tiBtn,  siIdx,  tiBed )
					values		( @idDevice, @tiBtn, @siIdx, @tiBed )

			if	@tiLog & 0x02 > 0											--	Config?
--			if	@tiLog & 0x04 > 0											--	Debug?
--			if	@tiLog & 0x08 > 0											--	Trace?
				exec	dbo.pr_Log_Ins	76, null, null, @s

		commit
	end
end
go
grant	execute				on dbo.prCfgBtn_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns buttons [and corresponding devices], associated with presence (in a given room)
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn
--				* .siPri -> .siIdx
--	7.06.8433	* p.tiSpec in (7,8,9) -> p.siFlags & 0x1000 > 0
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.05.4990
create proc		dbo.prCfgDvc_GetBtns
(
	@idRoom		smallint			-- device (PK)
)
	with encryption
as
begin
	--	set	nocount	off
	select	b.idDevice, d.sQnDvc, d.tiRID, b.tiBtn, p.tiSpec		--, d.tiGID, d.tiJID
		from	tbCfgBtn	b	with (nolock)
		join	tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx		and	p.siFlags & 0x1000 > 0	--	7.06.8433
		join	vwDevice	d	with (nolock)	on	d.idDevice	= b.idDevice	and	d.bActive > 0
		where	d.idParent = @idRoom
		order	by	2
end
go
grant	execute				on dbo.prCfgDvc_GetBtns				to [rReader]
grant	execute				on dbo.prCfgDvc_GetBtns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
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
create proc		dbo.prCfgDvc_UpdRmBd
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
					end
					else								--	@tiBed is absent in @idRoom
						delete	from	dbo.tbRoomBed	where	idRoom = @idRoom	and	tiBed = @tiBed

					select	@siMask =	@siMask * 2
						,	@tiBed =	case when @tiBed < 9 then @tiBed + 1 else 0 end
				end
			end

			update	dbo.tbRoom		set	dtUpdated=	@dtNow,		tiSvc=	null,	siBeds =	@siBeds,	sBeds=	@sBeds
				where	idRoom = @idRoom
			update	dbo.tbRoomBed	set	dtUpdated=	@dtNow,		tiSvc=	null	--	7.05.5098
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
grant	execute				on dbo.prCfgDvc_UpdRmBd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns active teams responding to a given priority in a given unit
--	7.06.8448	* prTeam_GetByUnitPri -> prTeam_GetByCall
--	7.06.7422	* @idUnit may be null now
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--				* tbTeamPri -> tbTeamCall
--	7.06.5347
create proc		dbo.prTeam_GetByCall
(
	@idUnit		smallint			-- null=any?
,	@siIdx		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	t.idTeam, sTeam, tResp, bEmail, sDesc, bActive, t.dtCreated, dtUpdated
		from	dbo.tbTeam		t	with (nolock)
		join	dbo.tbTeamCall	tc	with (nolock)	on	tc.idTeam	= t.idTeam	and	tc.siIdx	= @siIdx
		where	bActive > 0
		and	(	@idUnit is null
			or	t.idTeam	in	(select idTeam	from	dbo.tbTeamUnit	with (nolock)	where	idUnit = @idUnit))
/*	select	t.idTeam, sTeam, tResp, bEmail, sDesc, bActive, t.dtCreated, dtUpdated
		from	dbo.tbTeam		t	with (nolock)
		join	dbo.tbTeamCall	tc	with (nolock)	on	tc.idTeam	= t.idTeam	and	tc.siIdx	= @siIdx
		join	dbo.tbTeamUnit	tu	with (nolock)	on	tu.idTeam	= t.idTeam	and	tu.idUnit	= @idUnit	or	@idUnit is null
		where	bActive > 0
*/	--	order	by	idTeam
end
go
grant	execute				on dbo.prTeam_GetByCall				to [rWriter]
grant	execute				on dbo.prTeam_GetByCall				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns current active members on-duty
--	7.06.8448	* prTeam_GetStaffOnDuty -> prTeam_GetStaff
--	7.06.5429	+ .dtDue
--	7.06.5347
create proc		dbo.prTeam_GetStaff
(
	@idTeam		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	dbo.tb_User		u	with (nolock)
		join	dbo.tbTeamUser	t	with (nolock)	on	t.idUser	= u.idUser	and	idTeam = @idTeam
		where	bActive > 0		and	bOnDuty > 0
	--	order	by	idUser
end
go
grant	execute				on dbo.prTeam_GetStaff				to [rWriter]
grant	execute				on dbo.prTeam_GetStaff				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns indication whether given master should visualize a call from given coverage areas
--	7.06.8469	* @cSys,@tiGID,@tiJID -> @idRoom
--	7.05.5070	* > 0 -> <> 0	- signed operands produce signed result
--	7.03
alter function		dbo.fnEventA_GetByMaster
(
	@idMaster	smallint			-- master look-up FK
,	@idRoom		smallint			-- origin's room
--,	@cSys		char( 1 )			-- origin's system ID
--,	@tiGID		tinyint				-- origin's G-ID - gateway
--,	@tiJID		tinyint				-- origin's J-ID - J-bus
,	@iFilter	int					-- call's filter bits
,	@tiCvrg0	tinyint				-- coverage area 0
,	@tiCvrg1	tinyint				-- coverage area 1
,	@tiCvrg2	tinyint				-- coverage area 2
,	@tiCvrg3	tinyint				-- coverage area 3
,	@tiCvrg4	tinyint				-- coverage area 4
,	@tiCvrg5	tinyint				-- coverage area 5
,	@tiCvrg6	tinyint				-- coverage area 6
,	@tiCvrg7	tinyint				-- coverage area 7
)
	returns bit
	with encryption
as
begin
	declare		@tiCvrg		tinyint
		,		@iCaFlt		int
		,		@bResult	bit

	if	@idMaster = 0	or	@iFilter = 0	return	1		--	global mode or show all

---	if	exists	(select 1 from tbDevice with (nolock) where cSys=@cSys and tiGID=@tiGID and tiJID=@tiJID and tiRID=0 and bActive >0	and	idDevice=@idMaster)	--	and cDevice='M'
	if	@idRoom = @idMaster
---	or	exists	(select 1 from tbDevice with (nolock) where idDevice=@idRoom and bActive >0	and	idDevice=@idMaster)	--	and cDevice='M'
		return	0											--	suppress calls placed by the master itself (or its child phantom devices - workflow)

	select	@bResult =	0

	declare	cur		cursor local fast_forward for
		select	tiCvrg, iFilter
			from	dbo.tbCfgMst
			where	idMaster = @idMaster
		--	order	by	1, 2

	open	cur
	fetch next from	cur	into	@tiCvrg, @iCaFlt
	while	@@fetch_status = 0
	begin
		if	@tiCvrg = 0			--	ALL CAs
		or	@tiCvrg = @tiCvrg0	or	@tiCvrg = @tiCvrg1	or	@tiCvrg = @tiCvrg2	or	@tiCvrg = @tiCvrg3
		or	@tiCvrg = @tiCvrg4	or	@tiCvrg = @tiCvrg5	or	@tiCvrg = @tiCvrg6	or	@tiCvrg = @tiCvrg7
		begin
			if	@iCaFlt = 0	or	@iFilter & @iCaFlt <> 0		--	7.05.5070
			begin
				select	@bResult=	1
				break
			end
		end

		fetch next from	cur	into	@tiCvrg, @iCaFlt
	end
	close	cur
	deallocate	cur

	return	@bResult
end
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
--	7.06.8469	+ .cRoom
--				* fnEventA_GetByMaster()
--	7.06.8440	* .sQnRoom -> .sRoom
--	7.06.8343	* tbCfgPri.tiLvl -> .siFlags
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.8139	* vwEvent_A.sQnDevice -> sQnDvc
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idDevice, sDevice, sQnDvc, tiStype, sSGJRB
		,	idUnit,	idRoom, cRoom, sRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, tiColor, tiShelf, siFlags, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiIntTn
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0		and	idUnit = @idUnit
		and		( @iFilter = 0	or	iFilter & @iFilter <> 0 )
--		and		dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		and		dbo.fnEventA_GetByMaster( @idMaster, idRoom, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given room (identified by Sys-G-J)
--	7.06.8469	+ .cRoom
--				* fnEventA_GetByMaster()
--	7.06.8448	* @cSys,@tiGID,@tiJID -> @idRoom
--	7.06.8440	* .sQnRoom -> .sRoom
--	7.06.8343	* tbCfgPri.tiLvl -> .siFlags
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.8139	* vwEvent_A.sQnDevice -> sQnDvc
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
	@idRoom		smallint
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idDevice, sDevice, sQnDvc, tiStype, sSGJRB
		,	idUnit,	idRoom, cRoom, sRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, tiColor, tiShelf, siFlags, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiIntTn
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	bActive > 0			and		( tiShelf > 0	or	@bPrsnc > 0	and	siFlags & 0x1000 > 0 )
		and		idRoom = @idRoom	and		(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
		and		( @iFilter = 0	or	iFilter & @iFilter <> 0 )
--		and		dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		and		dbo.fnEventA_GetByMaster( @idMaster, @idRoom, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns topmost prism show for a given room and segment
--	7.06.8469	* fnEventA_GetByMaster()
--	7.06.8448	* @cSys,@tiGID,@tiJID -> @idRoom
--	7.06.6186
alter function		dbo.fnEventA_GetDomeByRoom
(
	@idRoom		smallint
,	@tiBed		tinyint				-- bed-idx, 0xFF=room
,	@idMaster	smallint			-- device look-up FK
,	@tiPrism	tinyint				-- prism segment (bitwise: 8=T, 4=U, 2=L, 1=B)
)
	returns table
	with encryption
as
return
	select	top	1	tiDome
		from	vwEvent_A	with (nolock)
		where	bActive > 0
		and		idRoom = @idRoom	and		(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
		and		tiPrism & @tiPrism > 0
--		and		dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		and		dbo.fnEventA_GetByMaster( @idMaster, idRoom, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	tiDome desc
go
--	----------------------------------------------------------------------------
--	7.06.8448	* tbUnitMapCell -> tbMapCell	(xpUnitMapCell -> xpMapCell, fkUnitMapCell_Room -> fkMapCell_Room, fkUnitMapCell_UnitMap -> fkMapCell_UnitMap)
--				- .cSys, - .tiGID, -.tiJID
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbUnitMapCell') and name = 'cSys')
begin
	begin tran
		exec( '
		alter table	dbo.tbUnitMapCell	drop column	tiJID
		alter table	dbo.tbUnitMapCell	drop column	tiGID
		alter table	dbo.tbUnitMapCell	drop column	cSys
			' )

		exec sp_rename 'fkUnitMapCell_UnitMap',	'fkMapCell_UnitMap',	'object'
		exec sp_rename 'fkUnitMapCell_Room',	'fkMapCell_Room',		'object'
		exec sp_rename 'xpUnitMapCell',			'xpMapCell',			'object'

		exec sp_rename 'tbUnitMapCell',			'tbMapCell',			'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans up invalid map cells
--	7.06.8452
create proc		dbo.prMapCell_ClnUp
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		-- remove rooms which are no longer in maps' units
		update	mc	set		idRoom =	null
				,	tiRID1 =	null,	tiBtn1 =	null,	tiRID2 =	null,	tiBtn2 =	null,	tiRID4 =	null,	tiBtn4 =	null
			from	dbo.tbMapCell	mc
			left join	dbo.tbRoom	rm	on	rm.idRoom = mc.idRoom	and	rm.idUnit = mc.idUnit
			where	mc.idRoom is not null	and	rm.idRoom is null

		select	@s =	'MapCell_CU( ) ' + cast(@@rowcount as varchar)

		-- now remove buttons which are no longer valid
		update	mc	set		tiRID1 =	null,	tiBtn1 =	null
			from	dbo.tbMapCell	mc
			left join	(select	d.idParent, d.tiRID, b.tiBtn
							from	dbo.tbCfgBtn	b	with (nolock)
							join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx		and	p.tiSpec = 9
							join	dbo.tbDevice	d	with (nolock)	on	d.idDevice	= b.idDevice	and	d.bActive > 0)	rb
								on	rb.idParent = mc.idRoom		and	rb.tiRID = mc.tiRID1	and	rb.tiBtn = mc.tiBtn1
			where	mc.idRoom is not null	and	rb.idParent is null		and	(mc.tiRID1 is not null	or	mc.tiBtn1 is not null)

		select	@s =	@s + ' ' + cast(@@rowcount as varchar)

		update	mc	set		tiRID2 =	null,	tiBtn2 =	null
			from	dbo.tbMapCell	mc
			left join	(select	d.idParent, d.tiRID, b.tiBtn
							from	dbo.tbCfgBtn	b	with (nolock)
							join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx		and	p.tiSpec = 8
							join	dbo.tbDevice	d	with (nolock)	on	d.idDevice	= b.idDevice	and	d.bActive > 0)	rb
								on	rb.idParent = mc.idRoom		and	rb.tiRID = mc.tiRID2	and	rb.tiBtn = mc.tiBtn2
			where	mc.idRoom is not null	and	rb.idParent is null		and	(mc.tiRID2 is not null	or	mc.tiBtn2 is not null)

		select	@s =	@s + ',' + cast(@@rowcount as varchar)

		update	mc	set		tiRID4 =	null,	tiBtn4 =	null
			from	dbo.tbMapCell	mc
			left join	(select	d.idParent, d.tiRID, b.tiBtn
							from	dbo.tbCfgBtn	b	with (nolock)
							join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx		and	p.tiSpec = 7
							join	dbo.tbDevice	d	with (nolock)	on	d.idDevice	= b.idDevice	and	d.bActive > 0)	rb
								on	rb.idParent = mc.idRoom		and	rb.tiRID = mc.tiRID4	and	rb.tiBtn = mc.tiBtn4
			where	mc.idRoom is not null	and	rb.idParent is null		and	(mc.tiRID4 is not null	or	mc.tiBtn4 is not null)

		select	@s =	@s + ',' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	76, null, null, @s

	commit
end
go
grant	execute				on dbo.prMapCell_ClnUp				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit with a count of assigned rooms
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--	7.06.5499	+ .iCells
--	7.06.5417	* prUnitMap_GetAll -> prUnitMap_GetByUnit
--				+ .idUnit
--	7.03
alter proc		dbo.prUnitMap_GetByUnit
(
	@idUnit		smallint					-- unit id
)
	with encryption
as
begin
--	set	nocount	on
	select	um.idUnit, um.tiMap, um.sMap,	mc.iCells
		from	dbo.tbUnitMap	um	with (nolock)
		left join	(select		tiMap,	count(*)	as	iCells
						from	dbo.tbMapCell	with (nolock)
						where	idUnit = @idUnit	and	idRoom is not null
						group	by	tiMap)	mc	on	mc.tiMap = um.tiMap
		where	um.idUnit = @idUnit
end
go
grant	execute				on dbo.prUnitMap_GetByUnit			to [rWriter]
grant	execute				on dbo.prUnitMap_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
--	7.06.8448	* tbUnitMapCell -> tbMapCell
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
		from	dbo.tbMapCell	c	with (nolock)
		left join	dbo.tbDevice	d	with (nolock)	on	d.idDevice = c.idRoom	--	and	d.bActive > 0	--	and	d.tiRID = 0
		where	c.idUnit = @idUnit
end
go
grant	execute				on dbo.prMapCell_GetByUnit			to [rWriter]
grant	execute				on dbo.prMapCell_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given map-cell
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--				* prUnitMapCell_Upd -> prMapCell_Upd
--				- .cSys, - .tiGID, -.tiJID
--	7.05.4990	+ @tiRID[i], @tiBtn[i]
--	7.03	+ @idRoom, - @bSwing, @cSys, @tiGID, @tiJID
--	6.04
create proc		dbo.prMapCell_Upd
(
	@idUnit		smallInt					-- unit id
,	@tiMap		tinyint						-- map index [0..3]
,	@tiCell		tinyint						-- cell index [0..47]
,	@idRoom		smallInt					-- room id
,	@sCell1		varchar( 8 )				-- cell name line 1
,	@sCell2		varchar( 8 )				-- cell name line 2
,	@tiRID1		tinyint						-- R-ID for Lvl1 LED (Yel)
,	@tiBtn1		tinyint						-- button code (0-31)
,	@tiRID2		tinyint						-- R-ID for Lvl2 LED (Ora)
,	@tiBtn2		tinyint						-- button code (0-31)
,	@tiRID4		tinyint						-- R-ID for Lvl4 LED (Grn)
,	@tiBtn4		tinyint						-- button code (0-31)
)
	with encryption
as
begin
--	set	nocount	off
	begin	tran
		update	dbo.tbMapCell	set
				idRoom =	@idRoom,	sCell1 =	@sCell1,	sCell2 =	@sCell2
			,	tiRID4 =	@tiRID4,	tiRID2 =	@tiRID2,	tiRID1 =	@tiRID1
			,	tiBtn4 =	@tiBtn4,	tiBtn2 =	@tiBtn2,	tiBtn1 =	@tiBtn1
			where	idUnit = @idUnit	and	tiMap = @tiMap	and	tiCell = @tiCell
	commit
end
go
grant	execute				on dbo.prMapCell_Upd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns lowest map index for a given room (identified by Sys-G-J) within a given unit
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--				* fnUnitMapCell_GetMap -> fnMapCell_GetMap
--	7.00
create function		dbo.fnMapCell_GetMap
(
	@idUnit		smallInt					-- unit id
,	@idRoom		smallint
)
	returns table
	with encryption
as
return
	select	min(tiMap)	as	tiMap		--	top 1
		from	dbo.tbMapCell	with (nolock)
		where	idUnit = @idUnit	and	idRoom = @idRoom
go
grant	select				on dbo.fnMapCell_GetMap				to [rWriter]
grant	select				on dbo.fnMapCell_GetMap				to [rReader]
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--				- .cSys, - .tiGID, -.tiJID
--	7.06.8444	+ clean up of tbUnitMapCell
--	7.06.8349	* commented code and path calculation
--	7.06.7461	+ finish coverage for and deactivate assignments in disabled units
--	7.06.7293	* tb_Option[38]->[31]
--	7.06.7279	* optimized logging
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@dtNow		datetime
		,		@tBeg		time( 0 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
--	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	select	@tiLog =	tiLvl,	@dtNow =	getdate( )	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tBeg =		cast(tValue as time( 0 ))		from	dbo.tb_OptSys	with (nolock)	where	idOption = 31

	begin	tran

		select	@s =	'Loc_SL( ) *' + cast(@iCount as varchar)

		-- deactivate non-matching units
		update	u	set	u.bActive=	0,	u.dtUpdated =	@dtNow
			from	dbo.tbUnit	u
			left join 	dbo.tbCfgLoc	l	on l.idLoc = u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1	and	l.idLoc is null
		select	@s =	@s + ', -' + cast(@@rowcount as varchar)

		-- deactivate shifts for inactive units
		update	s	set	s.bActive=	0,	s.dtUpdated =	@dtNow
			from	dbo.tbShift	s
			join	dbo.tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0
			where	s.bActive = 1
		select	@s =	@s + ' u, -' + cast(@@rowcount as varchar) + ' s'

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

		-- remove items for inactive units									--	7.06.5854
		insert	#tbUnit
			select	idUnit	from	tbUnit	with (nolock)	where	bActive = 0

--	-	delete	from	dbo.tbMapCell										-- cascade
--	-		where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	dbo.tbUnitMap
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tbDvcUnit
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tbTeamUnit
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tb_UserUnit										--	7.06.6796
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tb_RoleUnit
			where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))

		-- finish coverage for assignments in disabled units
		update	dbo.tbStfCvrg	set	dtEnd=	@dtNow,		dEnd =	@dtNow,		tEnd =	@dtNow
			where	idStfCvrg	in	(select	idStfCvrg	from	dbo.vwStfAssn	where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock)))
			and		dtEnd is null

		-- deactivate these assignments
		update	dbo.tbStfAssn	set	idStfCvrg=	null
			where	idStfCvrg is not null	and	bActive = 0
			and		idStfAssn	in	(select	idStfAssn	from	dbo.vwStfAssn	where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock)))

		-- process current units
		declare	cur		cursor fast_forward for
			select	idLoc, sLoc
				from	dbo.tbCfgLoc	with (nolock)
				where	tiLvl = 4
				order	by	1

		open	cur
		fetch next from	cur	into	@idUnit, @sUnit
		while	@@fetch_status = 0
		begin
			-- upsert tbUnit to match tbCfgLoc
	--		if	exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
	--			update	tbUnit	set	bActive =	1,	sUnit=	@sUnit,		dtUpdated=	@dtNow
	--				where	idUnit = @idUnit
			update	dbo.tbUnit	set	sUnit=	@sUnit,		dtUpdated=	@dtNow
				where	idUnit = @idUnit
			if	@@rowcount > 0
			begin
				update	dbo.tbUnit	set	bActive =	1
					where	idUnit = @idUnit	and	bActive = 0
				if	@@rowcount > 0
				begin
					-- re-activate shifts for re-activated unit				--	7.06.6017
					update	dbo.tbShift		set	bActive =	1,	dtUpdated=	@dtNow
						where	idUnit = @idUnit	and	bActive = 0

					if	@tiLog & 0x02 > 0									--	Config?
--					if	@tiLog & 0x04 > 0									--	Debug?
--					if	@tiLog & 0x08 > 0									--	Trace?
					begin
						select	@s =	'Loc_SL( ) [' + cast(@idUnit as varchar) + '] *' + cast(@@rowcount as varchar) + ' s'
						exec	dbo.pr_Log_Ins	73, null, null, @s
					end
				end
			end
			else
			begin
				insert	dbo.tbUnit	(  idUnit,  sUnit, tiShifts, idShift )
						values		( @idUnit, @sUnit, 1, 0 )
				insert	dbo.tb_RoleUnit	( idRole, idUnit )
						values		( 2, @idUnit )
				insert	dbo.tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )	--	default to single 24hr-shift
						values		( @idUnit, 1, 'Shift 1', @tBeg, @tBeg )	--	7.06.5934	'07:00:00'
				select	@idShift =	scope_identity( )

				update	dbo.tbUnit	set	idShift =	@idShift
					where	idUnit = @idUnit
			end

			-- populate tbUnitMap
			if	not	exists	(select 1 from dbo.tbUnitMap where idUnit = @idUnit)
			begin
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
				insert	dbo.tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
			end

			-- populate tbMapCell
			if	not	exists	(select 1 from dbo.tbMapCell where idUnit = @idUnit)
			begin
				select	@tiMap =	0
				while	@tiMap < 4
				begin
					select	@tiCell =	0
					while	@tiCell < 48
					begin
						insert	dbo.tbMapCell	( idUnit, tiMap, tiCell )	values	( @idUnit, @tiMap, @tiCell )

						select	@tiCell =	@tiCell + 1
					end
					select	@tiMap =	@tiMap + 1
				end
			end
			else
				update	dbo.tbMapCell	set									-- leave .sCell? intact
						tiRID4 =	null,	tiRID2 =	null,	tiRID1 =	null
					,	tiBtn4 =	null,	tiBtn2 =	null,	tiBtn1 =	null
					where	idRoom is null

			fetch next from	cur	into	@idUnit, @sUnit
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985
--	7.06.8469	+ .cRoom
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
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4
			,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
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
			,	p8.tiDome	as	tiDome8,	p4.tiDome	as	tiDome4
			,	p2.tiDome	as	tiDome2,	p1.tiDome	as	tiDome1
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
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4
			,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
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
create proc		dbo.prMapCell_GetByMap
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
		,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
		,	mc.tiCell, mc.sCell1, mc.sCell2,	rm.siBeds, rm.sBeds,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	dbo.tbMapCell	mc	with (nolock)
			join	dbo.tbUnit	u	with (nolock)	on	u.idUnit = mc.idUnit
			left join	dbo.vwRoom		rm	with (nolock)	on	rm.bActive > 0	and	rm.idDevice = mc.idRoom
			outer apply	dbo.fnEventA_GetTopByRoom( mc.idRoom, null, @iFilter, @idMaster, 1 )	ea		--	7.03
			left join	dbo.vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom
														and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF				--	and	ea.tiBed is null
															or	ea.tiBed is null	and	rb.tiBed in					--	7.06.5940
																	(select min(tiBed) from dbo.tbRoomBed with (nolock) where idRoom = ea.idRoom))
		where	mc.idUnit	= @idUnit
		and		mc.tiMap	= @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go
--grant	execute				on dbo.prMapCell_GetByMap			to [rWriter]
grant	execute				on dbo.prMapCell_GetByMap			to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8448	* prRptCallStatSumGraph -> prRptCallStatGfx
--	7.06.8388	* 
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.6030	+ @tiShift
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	7.06.5408	+ @siBeds
--	7.06.5395	* optimize
--	7.05.5297	* presence calls
--	6.05	+ (nolock), optimize
--	6.04	* optimize event selection range using tbEvent_S
--	6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiLocs -> @tiDvc
--	5.02
create proc		dbo.prRptCallStatGfx
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					join	tbCfgPri		cp	with (nolock)	on	cp.siIdx	= sc.siIdx		and	cp.siFlags & 0x5000 = 0x4000
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					join	tbCfgPri		cp	with (nolock)	on	cp.siIdx	= sc.siIdx		and	cp.siFlags & 0x5000 = 0x4000
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ec.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					join	tbCfgPri		cp	with (nolock)	on	cp.siIdx	= sc.siIdx		and	cp.siFlags & 0x5000 = 0x4000
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	tbEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ec.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift	= ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall		sc	with (nolock)	on	sc.idCall	= ec.idCall		and	sc.idSess = @idSess
					join	tbCfgPri		cp	with (nolock)	on	cp.siIdx	= sc.siIdx		and	cp.siFlags & 0x5000 = 0x4000
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0

	select	ec.dEvent,	count(*)	as	lCount
--		,	min(cp.tVoTrg)	as	tVoTrg,		min(cp.tStTrg)	as	tStTrg
		,	max(ec.tVoice)	as	tVoMax,		max(ec.tStaff)	as	tStMax
		,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
		,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
		from	tbEvent_C	ec	with (nolock)
--		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
		group	by ec.dEvent
end
go
grant	execute				on dbo.prRptCallStatGfx				to [rWriter]		--	7.03
grant	execute				on dbo.prRptCallStatGfx				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.846	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbShift') and name = 'tiMode')
begin
	begin tran
--		exec( '
--			' )

		exec sp_rename 'tbShift.tiNotify',		'tiMode',		'column'
		exec sp_rename 'tdShift_Notify',		'tdShift_Mode',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5429	+ .dtDue
--	7.06.4939	- .tiRouting
--	7.05.5226
alter view		dbo.vwShift
	with encryption
as
select	sh.idUnit, u.sUnit
	,	sh.idShift, tiIdx, sShift, tBeg, tEnd, tiMode
	,	sh.idUser, s.idStfLvl, s.sStfID, s.sStaff, s.bOnDuty, s.dtDue
	,	sh.bActive, sh.dtCreated, sh.dtUpdated
	from	tbShift	sh	with (nolock)
	join	tbUnit	u	with (nolock)	on	u.idUnit = sh.idUnit
	left join	vwStaff	s	with (nolock)	on	s.idUser = sh.idUser
go
--	----------------------------------------------------------------------------
--	Exports all shifts
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.4939	- .tiRouting
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4965
alter proc		dbo.prShift_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idShift, idUnit, tiIdx, sShift, tBeg, tEnd, tiMode, idUser, bActive, dtCreated, dtUpdated
		from	tbShift		with (nolock)
		where	idShift > 0
		order	by	idShift
end
go
--	----------------------------------------------------------------------------
--	Imports a shift
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.7460	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5935	+ logging
--	7.06.4939	- .tiRouting
--	7.05.5087	* optimize
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4965
alter proc		dbo.prShift_Imp
(
	@idShift	smallint
,	@idUnit		smallint
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiMode		tinyint				-- notification mode: 0=Auto, 1=SemiAuto, 2=Manual [, 3=FollowConsole]
,	@idUser		int
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Sh_Imp( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', nt=' + isnull(cast(@tiMode as varchar),'?') + ' bk=' + isnull(cast(@idUser as varchar),'?') + ' a=' + isnull(cast(@bActive as varchar),'?') +
					' cr=' + isnull(convert(varchar, @dtCreated, 20),'?') + ' up=' + isnull(convert(varchar, @dtUpdated, 20),'?') + ' )'

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s, 94

	begin	tran

--	-	if	exists	(select 1 from tbShift with (nolock) where idShift = @idShift)
		update	tbShift	set	idUnit =	@idUnit,	tiIdx=	@tiIdx,	sShift =	@sShift,	tBeg =	@tBeg,	tEnd =	@tEnd
					,	tiMode =	@tiMode,	idUser =	@idUser,	bActive =	@bActive,	dtUpdated=	@dtUpdated
			where	idShift = @idShift
--	-	else
		if	@@rowcount = 0
		begin
			set identity_insert	dbo.tbShift	on

			insert	tbShift	(  idShift,  idUnit,  tiIdx,  sShift,  tBeg,  tEnd,  tiMode,  idUser,  bActive,  dtCreated,  dtUpdated )
					values	( @idShift, @idUnit, @tiIdx, @sShift, @tBeg, @tEnd, @tiMode, @idUser, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbShift	off
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns shifts for a given unit (ordered by index) or current one
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5429	+ .dtDue
--	7.06.5401	* merged prShift_GetByUnit -> prShift_GetAll
--	7.05.5275	+ @bCurrent
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4938
alter proc		dbo.prShift_GetAll
(
	@idUnit		smallint	= null	-- null=any
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bCurrent	bit			= 0		-- 0=all, 1=current (single)
)
	with encryption
as
begin
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, tiMode, bActive, dtCreated, dtUpdated, idUser, idStfLvl, sStfID, sStaff, bOnDuty, dtDue
		from	vwShift		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idUnit is null	or	idUnit = @idUnit)
		and		(@bCurrent = 0		or	idShift in (select idShift from tbUnit with (nolock) where idUnit = @idUnit))
		order	by	idUnit, tiIdx
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.7465	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5415	+ @idUser, logging, @idUser -> @idOper
--	7.06.4939	- .tiRouting
--	7.05.5172
alter proc		dbo.prShift_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idShift	smallint	out		-- null=new shift
,	@idUnit		smallint
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiMode		tinyint				-- not null=set notify + bkup
,	@idOper		int					-- operand user, backup staff
,	@bActive	bit
)
	with encryption
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )
			,	@idStfAssn	int

	set	nocount	on
	set	xact_abort	on

	if	@idShift is null	or	@idShift < 0
		select	@idShift =	idShift
			from	tbShift		with (nolock)
			where	idUnit = @idUnit	and	tiIdx = @tiIdx

	select	@s =	'Shft( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', nt=' + isnull(cast(@tiMode as varchar),'?') + ' bk=' + isnull(cast(@idOper as varchar),'?') + ' a=' + isnull(cast(@bActive as varchar),'?') + ' )'
--					' cr=' + isnull(convert(varchar, @dtCreated, 20),'?') + ' up=' + isnull(convert(varchar, @dtUpdated, 20),'?') + ' )'

	begin	tran

		if	@idShift is null	or	@idShift < 0
		begin
			insert	tbShift	(  idUnit,  tiIdx,  sShift,  tBeg,  tEnd )
					values	( @idUnit, @tiIdx, @sShift, @tBeg, @tEnd )
			select	@idShift =	scope_identity( )

			select	@s =	@s + '=' + cast(@idShift as varchar)
				,	@k =	247
		end
		else
		begin
			if	@tiMode is not null
				update	tbShift		set		dtUpdated=	getdate( ),	tiMode =	@tiMode,	idUser =	@idOper
					where	idShift = @idShift
			else	--	instead of:		if	@tBeg is not null
			begin
				update	tbShift		set		dtUpdated=	getdate( ),	tBeg =	@tBeg,	tEnd =	@tEnd,	bActive =	@bActive
					where	idShift = @idShift

				if	@bActive = 0
				begin
					declare	cur		cursor fast_forward for
						select	idStfAssn
							from	tbStfAssn	with (nolock)
							where	idShift = @idShift	--	and	bActive > 0

					open	cur
					fetch next from	cur	into	@idStfAssn
					while	@@fetch_status = 0
					begin
						exec	dbo.prStfAssn_Fin	@idStfAssn				--	finalize assignment

						fetch next from	cur	into	@idStfAssn
					end
					close	cur
					deallocate	cur
				end
			end

--			select	@s =	'Shft_U' + @s + ')'
			select	@k =	248
		end

		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8468	* .tiFlags:	0x02=assignable (badges)
begin tran
	update	dbo.tbStfLvl	set	iColorB =	0xFFFFFF78		where	idStfLvl = 1
	update	dbo.tbStfLvl	set	iColorB =	0xFFFFA850		where	idStfLvl = 2
	update	dbo.tbStfLvl	set	iColorB =	0xFF78FF78		where	idStfLvl = 4
	update	dbo.tbStfLvl	set	iColorB =	0xFFFF5050		where	idStfLvl = 8

	if	exists	(select 1 from tbCfgPri where tiSpec = 7 and tiColor = 8)
		update	dbo.tbStfLvl	set	iColorB =	0xFF78FFFF		where	idStfLvl = 4

	if	exists	(select 1 from tbCfgPri where tiSpec = 8 and tiColor = 6)
		update	dbo.tbStfLvl	set	iColorB =	0xFF78FF78		where	idStfLvl = 2
commit
go
--	----------------------------------------------------------------------------
--	Logs out a user
--	7.06.8472	* 121 -> 120, 114 -> 108 (no ms)
--	7.06.7388	+ [.idSess] into log
--	7.06.7300	* Duration	(cause datediff(dd, ) swallows days)
--	7.06.7142	* optimized logging (+ [DT-dtCreated])
--	7.06.7115	* optimized logging (+ dtCreated)
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.06.5940	* optimize
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
--		,		@tiLog		tinyint
		,		@idModule	tinyint
		,		@idUser		int
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )
		,		@dtCreated	datetime

	set	nocount	on

	select	@idUser =	idUser,		@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule,	@dtCreated =	dtCreated
		from	tb_Sess
		where	idSess = @idSess

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	if	@idUser > 0
	begin
		begin	tran

			update	tb_Sess		set	dtLastAct=	getdate( ),	idUser =	null
				where	idSess = @idSess

			select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ') [' + cast( @idSess as varchar ) + '] ' + isnull(convert(varchar, @dtCreated, 120), '?') +
							' [' + isnull(cast(datediff(ss, @dtCreated, getdate())/86400 as varchar), '?') + 'd ' + isnull(convert(varchar, getdate() - @dtCreated, 108), '?') + ']'
--							' [' + isnull(cast(datediff(dd, @dtCreated, getdate( )) as varchar), '?') + 'd ' + isnull(convert(varchar, getdate( )-@dtCreated, 114), '?') + ']'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.8472	* [81]
begin tran
	update	dbo.tb_LogType	set	tiLvl=	64	where	idLogType = 81
	update	dbo.tb_LogType	set	tiLvl=	16	where	idLogType = 247
commit
go
--	----------------------------------------------------------------------------
--	7.06.8475	* tbPcsType -> tbNtfType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbPcsType')
begin
	begin tran
--		exec( '
--			' )

		exec sp_rename 'tbEvent41.idPcsType',	'idNtfType',	'column'
		exec sp_rename 'tbPcsType.idPcsType',	'idNtfType',	'column'
		exec sp_rename 'tbPcsType.sPcsType',	'sNtfType',		'column'
		exec sp_rename 'xpPcsType',				'xpNtfType',	'object'
		exec sp_rename 'dbo.tbPcsType',			'tbNtfType'
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.8433	* removed commented
--	7.06.7557	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6773	+ @idUser
--				+ idLogType= 206
--	7.06.6297	* optimized log
--	7.06.5926	* optimized log
--	7.06.5487	- .tiSeqNum (-> tbEvent.tiDstRID), - .cStatus (-> tbEvent.tiFlags)
--	7.06.5487	* optimize
--	7.06.5464	+ log invalid args
--	7.06.5396	* .idDvcType=4, not 3!
--	7.05.5205	* prEvent_Ins args
--	7.05.5102	+ @idDvcType
--	7.05.5095	+ @idPcsType, @idDvc, @sDial;	- @dtAttempt, @biPager;
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	6.05	optimized, replaced '@'
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--	6.02	tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	5.01
alter proc		dbo.prEvent41_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint				-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@tiBtn		tinyint				-- button code (0-31)
,	@sSrcDvc	varchar( 16 )		-- source name
,	@tiBed		tinyint				-- bed index
,	@siIdx		smallint			-- call index
,	@idNtfType	tinyint				-- notification subtype
,	@idDvc		int					-- if null use @sDial
,	@idDvcType	tinyint
,	@sDial		varchar( 16 )
,	@idUser		int					-- 
,	@tiSeqNum	tinyint				-- RPP sequence number (0-255)
,	@cStatus	char( 1 )			-- Q=Queued, R=Rejected, U=unknown
,	@sInfo		varchar( 32 )		-- page message
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idEvent	int
		,		@idCall		smallint
		,		@idUnit		smallint
		,		@idRoom		smallint
--		,		@sCall		varchar( 16 )
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
--		,		@idUser		int
		,		@idLogType	tinyint

	set	nocount	on

	select	@s =	'E41_I( ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' /' +
					isnull(cast(@tiBtn as varchar),'?') + ' ''' + isnull(@sSrcDvc,'?') + ''''
	if	@tiBed < 10
		select	@s =	@s + ':' + cast(@tiBed as varchar)
	select	@s =	@s + ', ' + isnull(cast(@idNtfType as varchar),'?') + ' #' + isnull(@sDial,'?') +
					' ' + isnull(cast(@idDvcType as varchar),'?') + '|' + isnull(cast(@idDvc as varchar),'?')
	if	@idNtfType = 64														-- RPP page sent
		select	@s =	@s + ' <' + isnull(cast(@tiSeqNum as varchar),'?') + ':' + isnull(@cStatus,'?') + '>'
	if	len(@sInfo) > 0
		select	@s =	@s + ', ''' + @sInfo + ''''
	select	@s =	@s + ' )'

	exec	dbo.prCall_GetIns	@siIdx, null, @idCall out		--	@sCall

	if	@idDvc is null
		select	@idDvc= idDvc
			from	tbDvc	with (nolock)
			where	@idDvcType = @idDvcType		and	sDial = @sDial	and	bActive > 0

	if	@idUser is null
		select	@idUser= idUser
			from	tbDvc	with (nolock)
			where	idDvc = @idDvc

	select	@idLogType =	case when	@idDvcType = 8	then	206			-- wi-fi
								when	@idDvcType = 4	then	204			-- phone
								when	@idDvcType = 2	then	205			-- pager
								else							82	end

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	null, null, null, null, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed		---	, @iAID, @tiStype, @idCall0

		select	@s =	@s + '=' + isnull(cast(@idEvent as varchar),'?') +	--- ', u=' + isnull(cast(@idUnit as varchar),'?') +
						', r=' + isnull(cast(@idRoom as varchar),'?')

		update	tbEvent		set	tiDstRID =	@tiSeqNum,	tiFlags =	ascii(@cStatus)
			where	idEvent = @idEvent

		if	@idDvc > 0
			insert	tbEvent41	(  idEvent,  idNtfType,  idDvc,  idUser )
					values		( @idEvent, @idNtfType, @idDvc, @idUser )
		else
			exec	dbo.pr_Log_Ins	82, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5487	- .tiSeqNum (-> tbEvent.tiDstRID), - .cStatus (-> tbEvent.tiFlags)
--	7.05.5212	* left join vwStaff
--	7.05.5095
alter view		dbo.vwEvent41
	with encryption
as
select	k.idEvent, e.dtEvent, e.idCmd, e.cSrcSys, e.tiSrcGID, e.tiSrcJID	--, e.tiSrcRID,	e.tiBtn
	,	e.idParent	--, e.idOrigin
	,	r.idDevice, r.sSGJ, r.sDevice,	e.tiBed, b.cBed
	,	e.idCall, c.sCall, c.siIdx
	,	k.idDvc, d.idDvcType, d.sDvcType, d.sDial, d.sDvc
	,	k.idNtfType, n.sNtfType, e.tiDstRID, char(e.tiFlags) as cRPP, e.sInfo
	,	k.idUser, u.sStfLvl, u.sStfID, u.sStaff
	from	tbEvent41	k	with (nolock)
	join	tbEvent		e	with (nolock)	on	e.idEvent = k.idEvent
	join	tbNtfType	n	with (nolock)	on	n.idNtfType = k.idNtfType
	join	vwDevice	r	with (nolock)	on	r.bActive > 0	and	r.cSys = e.cSrcSys	and	r.tiGID = e.tiSrcGID	and	r.tiJID = e.tiSrcJID	and	r.tiRID = 0	--h.tiSrcRID
	join	tbCall		c	with (nolock)	on	c.idCall = e.idCall	--c.bActive > 0	and
	join	vwDvc		d	with (nolock)	on	d.idDvc = k.idDvc	--c.bActive > 0	and
	left join	vwStaff	u	with (nolock)	on	u.idUser = k.idUser
	left join	tbCfgBed b	with (nolock)	on	b.tiBed = e.tiBed
go
--	----------------------------------------------------------------------------
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.8458	* fix output
--	7.06.8388	* 
--	7.06.8369	* vwCall -> tbCall, tbCfgPri.tiFlags -> .siFlags
--	7.06.8194	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.8143	* finalized output
--	7.06.8137	* vwStaff.sFqStaff -> sQnStf
--	7.06.8130	+ t.cDvcType
--	7.06.8123	* vwDvc
--	7.06.8122	+ tb_Log now keeps refs to important audit events
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.5491	* optimize audio / notification handling
--	7.06.5490	* optimize tiSvc (tbEvent.tiFlags) handling
--	7.06.5487	* - tbEvent8A, tbEvent95, tbEvent98
--	7.06.5483	* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.06.5421	* optimized
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--				+ @siBeds (ignored for now)
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
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=include no-device events
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@sSvc8		varchar( 16 )
		,		@sSvc4		varchar( 16 )
		,		@sSvc2		varchar( 16 )
		,		@sSvc1		varchar( 16 )
		,		@sNull		char( 1 )
		,		@sSpc6		char( 6 )
		,		@sGrTm		varchar( 16 )
		,		@sSyst		varchar( 16 )

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	' STAT',	@sNull =	'',		@sSpc6 =	'      ',	@sGrTm =	'Group/Team',	@sSyst =	'** $YSTEM **'
	select	@sSvc4 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	set	nocount	off

	if	@tiDvc = 0xFF
		insert	#tbRpt1
			select	e.idEvent
				from		vwEvent		e	with (nolock)
		--	-	join		tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
--				order	by	e.idEvent
	else if	@tiDvc = 1
		insert	#tbRpt1
			select	e.idEvent
				from		vwEvent		e	with (nolock)
				join		tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
--				order	by	e.idEvent
	else
		insert	#tbRpt1
			select	e.idEvent
				from		vwEvent		e	with (nolock)
				left join	tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
		--	-	and		(e.idSrcDvc in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcDvc is null)		-- is left join not enough??
--				order	by	e.idEvent

	select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
		,	e.idCmd,	e.tiBtn,	lt.tiLvl, e.idLogType		--,	e.idRoom, e.tiBed
		,	case	--when e.idCmd = 0x83		then e.sInfo						-- Gway
					when cp.tiSpec = 23		then @sSyst			else e.sRoomBed		end		as	sRoomBed
		,	e.idCall, e.sCall,	c.siIdx, cp.tiSpec, cp.tiColor,		e.tiFlags				as	tiSvc
		,	e.idSrcDvc,		e.idDstDvc, e.sDstSGJR,					e.sQnSrcDvc				as	sSrcDvc
		,	case	when 0 < l.idLog		then l.sModule		else e.sSrcSGJR		end		as	sSrcSGJR		--		when e.idCmd in (0, 0x83)
--		,	case	when 0 < en.idEvent		then nd.cDvcType	else e.cDstDvc		end		as	cDstDvc
		,	case	when 0 < en.idEvent		then nd.sQnDvc		else e.sQnDstDvc	end		as	sDstDvc
		,	case	when 0 < en.idEvent		then nt.sNtfType
					when 0 < e.idLogType	then e.sLogType		else k.sCmd	end
			+	case	when e.idCmd = 0x95		then	-- ' ' +
					case	when 0 < e.tiFlags & 0x08	then @sSvc8	else
					case	when 0 < e.tiFlags & 0x04	then @sSvc4	else @sNull	end
				+	case	when 0 < e.tiFlags & 0x02	then @sSvc2	else @sNull	end
				+	case	when 0 < e.tiFlags & 0x01	then @sSvc1	else @sNull	end	end
												else @sNull							end		as	sEvent
		,	case	when e.idCmd = 0x84	and	cp.tiSpec = 23
						or 0 < l.idLog						then null			-- Log|+-AppFail
					when 0 < cp.siFlags & 0x1000			then @sSpc6 + u1.sQnStf		-- Presence
																else e.sInfo		end		as	sInfo
		,	case	when 0 < cp.siFlags & 0x1000			then u1.idStfLvl
					when 0 < du.idUser 						then du.idStfLvl	-- Badge
																else null			end		as	idStfLvl
		,	case	when e.idCmd = 0x84	and	cp.tiSpec = 23		then e.sInfo	-- +-AppFail
					when 0 < l.idLog		then replace(l.sLog, char(9), char(32))
																else null			end		as	sLog
		,	case	when 0 < en.idEvent		then	--	du.sQnStf
						case	when 0 < nd.tiFlags & 0x01	then @sGrTm	else du.sQnStf	end
					when 0 < l.idLog		then l.sUser		else null			end		as sStaff	
		from		#tbRpt1		et	with (nolock)
		join		vwEvent		e	with (nolock)	on	e.idEvent		= et.idEvent
		join		tbDefCmd	k	with (nolock)	on	k.idCmd			= e.idCmd
		join		tb_LogType	lt	with (nolock)	on	lt.idLogType	= e.idLogType
		left join	tbCall		c	with (nolock)	on	c.idCall		= e.idCall
		left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
		left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent		= e.idEvent
		left join	vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
		left join	tbEvent41	en	with (nolock)	on	en.idEvent		= e.idEvent
		left join	tbNtfType	nt	with (nolock)	on	nt.idNtfType	= en.idNtfType
		left join	vwStaff		du	with (nolock)	on	du.idUser		= en.idUser
		left join	vwDvc		nd	with (nolock)	on	nd.idDvc		= en.idDvc
		left join	vw_Log		l	with (nolock)	on	l.idLog			= e.iHash	and	e.idCmd in (0, 0x83)		-- Log|Gway
		order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.8385	* 
--	7.06.8369	* vwCall -> tbCall, tbCfgPri.tiFlags -> .siFlags
--	7.06.8194	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.6774	+ e41.idPcsType .. as tiSpec
--	7.06.6417	* optimized data retrieval
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.6044	+ when e41.idEvent > 0 then du.idStfLvl .. as tiSvc
--	7.06.6043	+ .idUnit, .sUnit
--	7.06.6031	+ @tiShift
--	7.06.5491	* optimize audio / notification handling
--	7.06.5490	* optimize tiSvc (tbEvent.tiFlags) handling
--	7.06.5487	* - tbEvent8A, tbEvent95, tbEvent98
--	7.06.5483	* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	7.06.5408	* optimize @siBeds
--	7.06.5331	* @cBed -> @siBeds
--	7.05.5304	+ .siIdx, .tiSpec, .tiSvc
--	7.05.5203	+ 'e.idEvent between @iFrom and @iUpto' and 'e.tiHH between @tFrom and @tUpto'
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
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@sSvc8		varchar( 16 )
		,		@sSvc4		varchar( 16 )
		,		@sSvc2		varchar( 16 )
		,		@sSvc1		varchar( 16 )
		,		@sNull		varchar( 1 )
		,		@sSpc6		char( 6 )
		,		@sGrTm		varchar( 16 )

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	'STAT',		@sNull =	'',		@sSpc6 =	'      ',	@sGrTm =	'Group/Team'
	select	@sSvc4 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift = ec.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ec.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent
					from	vwEvent_C		ec	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ec.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift = ec.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0

	set	nocount	off

	select	ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice,	ec.cBed, e.tiBed, ec.sDial
		,	e.idEvent, e.dEvent, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin
		,	e.idLogType, cp.tiColor,	c.siIdx		--, e.idCall
		,	case	when e41.idEvent > 0	then pt.sNtfType	else lt.sLogType	end		as	sEvent
		,	case	when e41.idEvent > 0	then e41.idNtfType	else cp.tiSpec		end		as	tiSpec
		,	case	when e41.idEvent > 0	then du.idStfLvl	else e.tiFlags		end		as	tiSvc
		,	case	when e.idLogType between 195 and 199	then e.sQnDstDvc	--	 '[' + e.cDstDvc + '] ' + e.sDstDvc		-- audio
					when e.idCmd = 0x95		then
						case	when e.tiFlags & 0x08 > 0	then @sSvc8	else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4	else @sNull	end
					+	case	when e.tiFlags & 0x02 > 0	then @sSvc2	else @sNull	end
					+	case	when e.tiFlags & 0x01 > 0	then @sSvc1	else @sNull	end	end
					when e41.idEvent > 0	then nd.sQnDvc							end		as	sDvcSvc	--	 nd.sFqDvc
		,	case	when e41.idEvent > 0	then
						case	when nd.tiFlags & 0x01 > 0	then @sGrTm	else du.sQnStf	end
					else c.sCall	end		as	sCall
		,	case	--when e41.idNtfType > 0x80	then pt.sNtfType
					when cp.siFlags & 0x1000 > 0	then u1.sQnStf	else e.sInfo	end		as	sInfo
	--				when c.tiSpec in (7, 8, 9)	then u1.sQnStf	else e.sInfo	end		as	sInfo
	--	,	case	when c.tiSpec between 7 and 9	then @sSpc6 + u1.sFqStaff		else e.sInfo	end		as	sInfo
		,	d.sDoctor, p.sPatient
		from		#tbRpt1		et	with (nolock)
		join		vwEvent_C	ec	with (nolock)	on	ec.idEvent		= et.idEvent
		join		vwEvent		e	with (nolock)	on	e.idParent		= et.idEvent
		join		tb_LogType	lt	with (nolock)	on	lt.idLogType	= e.idLogType
		join		tbCall		c	with (nolock)	on	c.idCall		= e.idCall
		join		tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
		left join	tbEvent41	e41	with (nolock)	on	e41.idEvent		= e.idEvent
		left join	tbNtfType	pt	with (nolock)	on	pt.idNtfType	= e41.idNtfType
		left join	vwDvc		nd	with (nolock)	on	nd.idDvc		= e41.idDvc
		left join	vwStaff		du	with (nolock)	on	du.idUser		= e41.idUser
		left join	vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
		left join	tbEvent84	e84	with (nolock)	on	e84.idEvent		= e.idEvent
		left join	tbPatient	p	with (nolock)	on	p.idPatient		= e84.idPatient
		left join	tbDoctor	d	with (nolock)	on	d.idDoctor		= e84.idDoctor
		where	e.idEvent	between @iFrom	and @iUpto
		and		e.tiHH		between @tFrom	and @tUpto
		order	by	ec.idUnit, ec.idRoom, ec.idEvent, e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8495	* [11]
begin tran
	update	dbo.tbReport	set	sReport =	'Rounding (Daily)',	sRptName =	'Daily Rounding'	where	idReport = 11
commit
go
--	----------------------------------------------------------------------------
--	7.06.8500	- .dEvent, .tEvent	no need
--				- xtEventD_dEvent_tiHH
--				+ .idEvntP, .tWaitP
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_D') and name = 'dEvent')
begin
	begin tran
		exec( '
		drop index	dbo.tbEvent_D.xtEventD_dEvent_tiHH
		alter table	dbo.tbEvent_D	drop column	dEvent
		alter table	dbo.tbEvent_D	drop column	tEvent
			' )

		alter table	dbo.tbEvent_D	add
			idEvntP		int				null		-- patient entered
				constraint	fkEventD_EvntP		foreign key references	tbEvent	--on delete set null
		,	tWaitP		time( 3 )		null		-- patient's wait-for-room time
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8500	- .dEvent, .tEvent	no need
--				- xtEventD_dEvent_tiHH
--				+ .idEvntP, .tWaitP
--	7.06.6410	+ .idCallS, .idCallD
--	7.06.6402
alter view		dbo.vwEvent_D
	with encryption
as
select	e.idEvent, ee.dEvent, ee.tEvent, e.tiHH, e.idCall, c.sCall		--	, ep.dEvent, ep.tEvent
	,	e.idUnit, u.sUnit,		e.idShift, e.dShift
	,	e.idRoom, d.cDevice, d.sDevice, d.sDial,	e.tiBed, cb.cBed, e.siBed
	,	d.sDevice + case when e.tiBed is null then '' else ' : ' + cb.cBed end	as	sRoomBed
	,	e.idEvntP, e.tWaitP, e.tRoomP,	ep.idCall	as	idCallP
	,	e.idEvntS, e.tWaitS, e.tRoomS,	es.idCall	as	idCallS
	,	e.idEvntD, e.tWaitD, e.tRoomD,	ed.idCall	as	idCallD
	from		tbEvent_D	e	with (nolock)
	join		tbEvent		ee	with (nolock)	on	ee.idEvent	= e.idEvent
	join		tbCall		c	with (nolock)	on	c.idCall	= e.idCall
	join		tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
	join		tbDevice	d	with (nolock)	on	d.idDevice	= e.idRoom
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed	= e.tiBed
	left join	tbEvent		ep	with (nolock)	on	ep.idEvent	= e.idEvntP
	left join	vwEvent		es	with (nolock)	on	es.idEvent	= e.idEvntS
	left join	vwEvent		ed	with (nolock)	on	ed.idEvent	= e.idEvntD
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	7.06.8500	* fixed setting parent/origin for rnd/rmnd and clinic calls
--	7.06.8380	* removed extra check for idCmd <> 0x84
--				* simplified @idParent selection (?)
--	7.06.8343	* tbCfgPri.tiLvl -> .siFlags,	also bit values changed
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
		,		@siFlags	smallint
		,		@iAID2		int
		,		@tiGID		tinyint
		,		@tiJID		tinyint
		,		@tiRID		tinyint
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
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiRID =	@tiSrcRID,	@sDvc =		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiRID,		@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins2'

		exec		dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID,  @tiStype,  @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins3'

--		if	@idCmd <> 0x84	or	@idLogType <> 194							-- skip healing 84s
		if	@idLogType <> 194												-- skip healing 84s
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

			select	@siFlags =	siFlags										--	7.06.8343
				from	tbCfgPri	cp	with (nolock)
				join	tbCall		c	with (nolock)	on	c.siIdx = cp.siIdx
				where	c.idCall = @idCall

			if	@idCmd = 0x84	and											--	7.06.8500	0x0700=Doc(..0111..), 0x0500=Stf(..0101..), 0x0100=None(..0001..)
				(	@siFlags & 0x0500 = 0x0500	or	@siFlags & 0x0300 = 0x0100	)		--	@siFlags & 0x0500 = 0x0500 skips None
			begin
				select	@idParent=	idEvent,	@dtParent=	dtEvent
					from	tbEvent_A	ea	with (nolock)
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = ea.siIdx
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		bActive > 0			and	cp.siFlags & 0x0700 = 0x0300	--	7.06.8343	0x0300=Pat(..0011..)

				if	@idParent is null
					select	@idParent=	ep.idEvent,	@dtParent=	ep.dtEvent
						from	tbEvent_A	ea	with (nolock)
						join	tbEvent		eo	with (nolock)	on	eo.idEvent	= ea.idEvent
						join	tbEvent		ep	with (nolock)	on	ep.idEvent	= eo.idParent
						where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	ea.tiBtn = @tiBtn	and	bActive > 0
						and		ea.idCall = @idCall
			end
			else
				select	@idParent=	idEvent,	@dtParent=	dtEvent			--	7.04.4968
					from	tbEvent_A	with (nolock)
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		( bActive > 0		or	@idCmd < 0x80	or	@idCmd = 0x8D )		--	7.05.5095, .5211
					and		( tiBtn = @tiBtn	or	@tiBtn is null )
					and		( idCall = @idCall	or	@idCall is null		or	@idCall0 is not null	and	idCall = @idCall0 )

			select	@idRoom =	idDevice									-- get room
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
--	7.06.8500	* fixed setting details for rnd/rmnd and clinic calls
--	7.06.8409	- @siDuty0-3, @siZone0-3
--	7.06.8380	- @tiLvl, @tiFlags is not set for return
--	7.06.8343	* tbCfgPri.tiLvl -> .siFlags,	also bit values changed
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
		,		@tiHH		tinyint
		,		@siFlags	smallint
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@bAudio		bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int
		,		@idEvDup	int

	set	nocount	on

--	select	@tiLog =	tiLvl	from	tb_Module	with (nolock)	where	idModule = 1
	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bAudio =	0

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
		select	@siFlags =	siFlags,	@tiShelf =	tiShelf,	@tiSpec =	tiSpec,		@siIdxUg =	siIdxUg
			from	tbCfgPri	with (nolock)
			where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew						-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0													-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@siFlags =	siFlags,	@tiShelf =	tiShelf,	@tiSpec =	tiSpec,		@siIdxUg =	siIdxUg
			from	tbCfgPri	with (nolock)
			where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0													-- INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out					-- no need to call

--	if	@tiLog & 0x04 > 0													--	Debug?
--		exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins01'


	if	@siFlags & 0x1000 > 0		--	@tiSpec between 7 and 9				--	7.06.8380
		select	@tiBed =	0xFF											-- force room-level for 'presence' calls
	else
	if	@siFlags & 0x2000 > 0		--	@tiSpec	in	(10,11,12,13,14,15,16,17, 20,21, 23,24,25,26,27)
		select	@idUnit =	null											-- blank unit for 'failure' calls

	if	@siFlags & 0x2000 = 0	and	--	@bFailure = 0						--	7.06.7417	.8380
		(@idUnit < 259	or													-- lowest possible unit
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0))
		select	@idUnit =	null,	@p =	@p + ' !u'						-- invalid unit

	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + ' !b'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed


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
									case when	@siFlags & 0x1000 > 0	then 210	else 191 end	--	7.06.6767	0 < @bPresence	.8380
								when	@siIdxNew = 0		then			-- cancelled | presense-out
									case when	@siFlags & 0x1000 > 0	then 211	else 193 end	--	7.06.6767	0 < @bPresence	.8380
								else										-- escalated | healing
									case when	@idCall0 > 0			then 192	else 194 end	end

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
								,	tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew
								,	@tiTmrA,  @tiTmrG,  @tiTmrO,  @tiTmrY,    @idPatient, @idDoctor, @iFilter
								,	@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

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

		if	@siFlags & 0x1000 > 0		--	@bPresence > 0					--	7.06.7265	.8380
			exec	dbo.prRoom_UpdStaff		@idRoom, @siIdxNew, @sStaffG, @sStaffO, @sStaffY	--, @idUnit

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins05'


		if	@idOrigin is null												-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss,  @siElapsed, '0:0:0')
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
										siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,
										tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
						values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
										@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, @tiSvc, dateadd(ss, @iExpNrm, @dtEvent),
										@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins07'

			if	@idRoom > 0		and	@idUnit > 0								-- record every call in tbEvent_C	--	7.06.5562, 7.06.5613
			begin
				select	@tiHH =		datepart(hh, @dtOrigin)
					,	@idUser =	case									-- get staff currently in room, associated with this call if presence, or null
							when @tiSpec = 7	then idUserG
							when @tiSpec = 8	then idUserO
							when @tiSpec = 9	then idUserY
												else null	end
					from	tbRoom	with (nolock)
					where	idRoom = @idRoom

				select	@idShift =	u.idShift								--	7.06.6017
					,	@dShift =	case when sh.tEnd <= sh.tBeg	and	cast(@dtOrigin as time) < sh.tEnd	then	dateadd(dd, -1, @dtOrigin)	else	@dtOrigin	end	--	7.06.6051
					from	tbUnit	u	with (nolock)
					join	tbShift	sh	with (nolock)	on	sh.idShift = u.idShift
					where	u.idUnit = @idUnit	and	u.bActive > 0

--				if	@tiLog & 0x04 > 0									--	Debug?
--					exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins08'

				if	@siFlags & 0x0800 > 0		or							-- initial rnd/rmnd		.8380
					@siFlags & 0x0700 = 0x0300								-- clinic-patient	.7864	.8380
					insert	tbEvent_D	(  idEvent,  idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed,  tiHH )
							values		( @idEvent, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, @tiHH )
				else
				if	@siFlags & 0x0100 = 0									-- non-clinic call	.7864	.8380
				begin
					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, idUser1,  tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, @idUser, @tiHH )

					if	@siFlags & 0x1000 = 0								-- not presence		7.06.5665	.8380
						update	c	set	c.idUser1=	rb.idUser1,		c.idUser2=	rb.idUser2,		c.idUser3=	rb.idUser3	--	7.06.5326
							from	tbEvent_C	c
							join	tbRoomBed	rb	on	rb.idRoom = @idRoom		and	( rb.tiBed = @tiBed		or	@tiBed is null	and	( rb.tiBed = 0xFF	or	rb.tiBed = 1 ) )
							where	c.idEvent = @idEvent
				end
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
				where	idEvent = @idOrigin									--	7.05.5065

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins10'

			update	tbEvent_A	set	tiSvc=	@tiSvc							-- update state for all calls in this room
				where	idRoom = @idRoom									--	7.06.5534

			if	@siFlags & 0x0100 > 0										-- clinic call	.7864	.8380
				and	0 < @siIdxNew	and	@siIdxNew <> @siIdxOld
				and	@siIdxUg is null										-- escalated to last stage
			begin
				if	@siFlags & 0x0700 = 0x0300								-- clinic-patient	.8380
				begin
					update	tbEvent_D	set	idEvntP =	@idEvent
						where	idEvent = @idParent		and	idEvntP is null

					update	ed	set	tWaitP =	tParent
						from	tbEvent_D	ed
						join	tbEvent		ee	with (nolock)	on	ee.idEvent	= @idEvent
						where	ed.idEvent = @idOrigin	and	tWaitP is null
				end
				else
				if	@siFlags & 0x0700 = 0x0500								-- clinic-staff		.7864	.8380
				begin
					update	tbEvent_D	set	idEvntS =	@idEvent
						where	idEvent = @idParent		and	idEvntS is null

					update	ed	set	tWaitS =	cast(ee.tParent as datetime) - cast(ep.tOrigin as datetime)
						from	tbEvent_D	ed
						join	tbEvent		ee	with (nolock)	on	ee.idEvent	= @idEvent
						join	tbEvent		ep	with (nolock)	on	ep.idEvent	= ed.idEvntP
						where	ed.idEvent = @idParent	and	tWaitS is null
				end
				else
				if	@siFlags & 0x0700 = 0x0700								-- clinic-doctor	.7864	.8380
				begin
					update	tbEvent_D	set	idEvntD =	@idEvent
						where	idEvent = @idParent		and	idEvntD is null

					update	ed	set	tWaitD =	cast(ee.tParent as datetime) - cast(ep.tOrigin as datetime)
						from	tbEvent_D	ed
						join	tbEvent		ee	with (nolock)	on	ee.idEvent	= @idEvent
						join	tbEvent		ep	with (nolock)	on	ep.idEvent	= ed.idEvntP
						where	ed.idEvent = @idParent	and	tWaitD is null
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

			if	@siFlags & 0x0800 > 0										-- initial rnd/rmnd		.8395
				delete	tbEvent_D
					where	idEvent = @idOrigin								-- remove incomplete rnd/rmnd
			else
			if	@siFlags & 0x0008 > 0										-- non-initial rnd/rmnd		.8380
				update	ed	set	tWaitS =	@dtEvent - eo.dtEvent,	idEvntS =	@idEvent
					from	tbEvent_D	ed
					join	tbEvent		eo	with (nolock)	on	eo.idEvent	= ed.idEvent
					where	ed.idEvent = @idOrigin	and	tWaitS is null
			else
			if	@siFlags & 0x0700 = 0x0300									-- clinic-patient	.8380
				update	ed	set	tRoomP =	@dtEvent - ep.dtEvent
					from	tbEvent_D	ed
					join	tbEvent		ep	with (nolock)	on	ep.idEvent	= ed.idEvntP
					where	ed.idEvent = @idOrigin	and	tRoomP is null
			else
			if	@siFlags & 0x0700 = 0x0500									-- clinic-staff		.8380
				update	ed	set	tRoomS =	@dtEvent - ep.dtEvent
					from	tbEvent_D	ed				
					join	tbEvent		ep	with (nolock)	on	ep.idEvent	= ed.idEvntS
					join	tbEvent		eo	with (nolock)	on	eo.idParent	= ed.idEvent	and	eo.idEvent	= @idOrigin
					where	tRoomS is null
			else
			if	@siFlags & 0x0700 = 0x0700									-- clinic-doctor	.8380
				update	ed	set	tRoomD =	@dtEvent - ep.dtEvent
					from	tbEvent_D	ed
					join	tbEvent		ep	with (nolock)	on	ep.idEvent	= ed.idEvntD
					join	tbEvent		eo	with (nolock)	on	eo.idParent	= ed.idEvent	and	eo.idEvent	= @idOrigin
					where	tRoomD is null
			else
			if	@siFlags & 0x0100 = 0										-- not a clinic call	.7864	.8380
			begin
				if	@tiSrcRID = 0	and	@tiBtn < 3	and	@tiBed is null		-- BadgeCalls are room-level
					update	tbRoom	set	tiCall =	tiCall	&	case when	@tiBtn = 0	then	0xFB		--	0x..1011	G
																	when	@tiBtn = 1	then	0xFD		--	0x..1101	O
																		/*	@tiBtn =2*/	else	0xFE	end	--	0x..1110	Y
						where	idRoom = @idRoom							--	7.06.7464
			end
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
			order	by	siIdx desc, idEvent									-- oldest in recorded order
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
				order	by	siIdx desc, idEvent								-- oldest in recorded order (clustered) - FASTER, more EFFICIENT
			---	order	by	siIdx desc, tElapsed desc						-- call may have started before it was recorded (thus no .tElapsed!)

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
end
go
--	----------------------------------------------------------------------------
--	7.06.8500	* 
--	7.06.8389	* 
--	7.06.6417
alter proc		dbo.prRptCliPatDtl
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	sc.idCall	= ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0

	set	nocount	off

	select	ep.idUnit, ep.sUnit, ep.idRoom, ep.cDevice, ep.sDevice,		ep.cBed, e.tiBed
		,	e.idEvent, e.dEvent, e.tEvent as tQueue, er.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin
		,	c.siIdx, cp.tiSpec, cp.tiColor, c.sCall
		,	ep.tWaitP, ep.tRoomP,	ep.tWaitS, ep.tRoomS,	ep.tWaitD, ep.tRoomD
--		,	cast(cast(ep.tEvent as datetime) + cast(ep.tRoomP as datetime) as time(3))	as	tExit
		from	#tbRpt1		et	with (nolock)
		join	vwEvent_D	ep	with (nolock)	on	ep.idEvent	= et.idEvent
		join	tbEvent		e	with (nolock)	on	e.idEvent	= ep.idEvent
		join	tbEvent		er	with (nolock)	on	er.idEvent	= ep.idEvntP
		join	tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx	= c.siIdx
		order	by	ep.idUnit, ep.idRoom, ep.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8500	* 
--	7.06.8389	* 
--	7.06.6417
alter proc		dbo.prRptCliStfDtl
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@idEvent	int

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	create table	#tbRpt2
	(
		idEvent		int		primary key nonclustered
	,	tWait		time( 3 )		null		-- patient's wait-for-staff/doctor time
	,	tRoom		time( 3 )		null		-- staff/doctor's time in room
	,	tRoomP		time( 3 )		null		-- patient's time in room
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0

	declare		cur		cursor fast_forward for
		select	idEvent
			from	#tbRpt1	with (nolock)

	open	cur
	fetch next from	cur	into	@idEvent
	while	@@fetch_status = 0
	begin
		insert	#tbRpt2
			select	idEvntS, tWaitS, tRoomS,	tRoomP
				from	vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallS in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		insert	#tbRpt2
			select	idEvntD, tWaitD, tRoomD,	tRoomP
				from	vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallD in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		fetch next from	cur	into	@idEvent
	end
	close	cur
	deallocate	cur
	
	set	nocount	off

	select	e.idUnit, u.sUnit, e.idRoom, r.cDevice, r.sDevice,	e.cBed, e.tiBed
		,	e.idEvent, e.dEvent, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin	--, e.idCall, ep.sDial
		,	c.siIdx, cp.tiSpec, cp.tiColor, c.sCall
		,	et.tWait, et.tRoom, et.tRoomP
		,	cast(cast(e.tEvent as datetime) + cast(et.tRoom as datetime) as time(3))	as	tExit
		from	#tbRpt2		et	with (nolock)
		join	vwEvent		e	with (nolock)	on	e.idEvent	= et.idEvent
		join	tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice	= e.idRoom
		join	tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx	= c.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8500	* 
--	7.06.8389	* 
--	7.06.6417
alter proc		dbo.prRptCliStfSum
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@idEvent	int

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	create table	#tbRpt2
	(
		idEvent		int		primary key nonclustered
	,	idCall		smallint		not null
	,	tWait		time( 3 )		null		-- patient's wait-for-staff/doctor time
	,	tRoom		time( 3 )		null		-- staff/doctor's time in room
	,	tRoomP		time( 3 )		null		-- patient's time in room
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D		ep	with (nolock)
					join	tb_SessDvc		sd	with (nolock)	on	sd.idDevice	= ep.idRoom
					join	tb_SessShift	sh	with (nolock)	on	sh.idSess	= @idSess		and	sh.idShift	= ep.idShift
					join	tb_SessCall		sc	with (nolock)	on	sc.idSess	= @idSess		and	( sc.idCall	= ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0

	declare		cur		cursor fast_forward for
		select	idEvent
			from	#tbRpt1	with (nolock)

	open	cur
	fetch next from	cur	into	@idEvent
	while	@@fetch_status = 0
	begin
		insert	#tbRpt2
			select	idEvntS, idCallS, tWaitS, tRoomS,	tRoomP
				from	vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallS in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		insert	#tbRpt2
			select	idEvntD, idCallD, tWaitD, tRoomD,	tRoomP
				from	vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallD in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		fetch next from	cur	into	@idEvent
	end
	close	cur
	deallocate	cur
	
	set	nocount	off

	select	e.idUnit, u.sUnit, e.idRoom, r.cDevice, r.sDevice
		,	e.dEvent, e.lCount,	e.siIdx, e.sCall,	cp.tiColor
		,	cast(e.tRoomA as time(3))	as	tRoomA
		,	cast(e.tRoomT as time(3))	as	tRoomT
		,	cast(e.tWait  as time(3))	as	tWait
		,	cast(e.tRoomP as time(3))	as	tRoomP
		from
		(select	e.idUnit, e.idRoom
			,	e.dEvent,				count(e.idEvent)	as	lCount
			,	c.siIdx,					min(c.sCall)	as	sCall
			,	dateadd(ms,avg(datediff(ms,0,et.tRoom)),0)	as	tRoomA
			,	dateadd(ms,sum(datediff(ms,0,et.tRoom)),0)	as	tRoomT
			,	dateadd(ms,sum(datediff(ms,0,et.tWait)),0)	as	tWait
			,	dateadd(ms,sum(datediff(ms,0,et.tRoomP)),0)	as	tRoomP
			from	#tbRpt2		et	with (nolock)
			join	vwEvent		e	with (nolock)	on	e.idEvent = et.idEvent
			join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
		group	by	e.idUnit, e.idRoom, e.dEvent, c.siIdx
			)	e	--with (nolock)
		join	tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice	= e.idRoom
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = e.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, e.siIdx	desc
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.8501	+ tbEvent_D.idEvntP
--	7.06.8412	+ exec pr_Sess_Maint
--	7.06.7618	+ tbEvent_D cascade null
--	7.06.7467	* logging: Trc -> Dbg
--	7.06.7292	* tb_Option[11]<->[19]
--	7.06.7276	* optimized tracing
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@idEvent	int
		,		@iCount		int
		,		@tiPurge	tinyint			-- FF=keep everything
											-- N=remove auxiliary data older than N days (cascaded)
											-- 0=remove all inactive events from [tbEvent*] (cascaded)
	set	nocount	on

	select	@dt =	getdate( )												-- smalldatetime truncates seconds

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	ec	set	ec.idEvtVo =	null						-- implements CASCADE SET NULL
					from	tbEvent_C	ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtVo
					where	a.idEvent is null

				update	ec	set	ec.idEvtSt =	null
					from	tbEvent_C	ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtSt
					where	a.idEvent is null

				update	ed	set	ed.idEvntP =	null						-- implements CASCADE SET NULL
					from	tbEvent_D	ed
					left join	tbEvent_A	a	on	a.idEvent = ed.idEvntP
					where	a.idEvent is null

				update	ed	set	ed.idEvntS =	null
					from	tbEvent_D	ed
					left join	tbEvent_A	a	on	a.idEvent = ed.idEvntS
					where	a.idEvent is null

				update	ed	set	ed.idEvntD =	null
					from	tbEvent_D	ed
					left join	tbEvent_A	a	on	a.idEvent = ed.idEvntD
					where	a.idEvent is null

				delete	e	from	tbEvent	e
					left join	tbEvent_A	a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@iCount =	@@rowcount

--				if	@tiLog & 0x02 > 0										--	Config?
				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
					if	0 < @iCount
					begin
						select	@s =	'Ev_M( ' + cast(@tiPurge as varchar) + ' ) -' + cast(@iCount as varchar) +
										' in ' + convert(varchar, getdate() - @dt, 114)
	--					exec	dbo.pr_Log_Ins	1, null, null, @s			--	7.06.7276	trace is enough
						exec	dbo.pr_Log_Ins	0, null, null, @s			--	7.06.7467	debug
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

				update	tb_OptSys	set	iValue =	@idEvent,	dtUpdated=	@dt		where	idOption = 11
			end

		end

		exec	dbo.pr_Sess_Maint

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a staff level
--	7.06.8504	+ skip tracing internal sync
--	7.06.8139	+ .cStfLvl
--	7.06.7279	* optimized logging
--	7.06.7115	* optimized logging (color in hex)
--	7.05.5219
alter proc		dbo.prStfLvl_Upd
(
	@idStfLvl	tinyint
,	@cStfLvl	char( 1 )
,	@sStfLvl	varchar( 16 )
,	@iColorB	int
,	@idUser		int
)
	with encryption, exec as owner
as
begin
	declare		@s	varchar( 255 )

	set	nocount	on

	select	@s =	'StfLvl_U( ' + isnull(cast(@idStfLvl as varchar), '?') + ', ' +
					isnull(convert(varchar, convert(varbinary(4), @iColorB), 1), '?') + ', ' + @cStfLvl + '|''' + @sStfLvl + ''' )'

	begin	tran

		update	tbStfLvl	set	cStfLvl =	@cStfLvl,	sStfLvl =	@sStfLvl,	iColorB =	@iColorB	--,	dtUpdated=	getdate( )
			where	idStfLvl = @idStfLvl

		if	ascii(@cStfLvl) < 0xF0											-- skip internal sync
			exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 8508 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8508, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2023-04-18',	sVersion =	'RTLS auto-badges, rnd/rmnd, clinic, reporting, RPP 1.09, AD-sync, UI enh'
		where	siBuild = 8508

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.8508'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, '7.6.8508.00000, [{0}]'
commit
go

--	<100,tbEvent>
exec	sp_updatestats
go

checkpoint
go

use [master]
go