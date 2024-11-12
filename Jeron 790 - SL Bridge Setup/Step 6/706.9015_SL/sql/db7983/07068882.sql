--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		db798387 - DB name
--
--	7.06
--		2024-Jan-18		.8783
--						* tb_User.sStaffID	-> sStfID	(xu_User_Act_StaffID -> xu_User_Act_StfID)
--							prStaff_Get, prStaff_GetBySID, prStaff_GetByBC, pr_User_Imp, pr_User_Login, pr_User_Login2,
--								pr_User_GetAll, pr_User_GetOne, prTeam_GetStaff, vwStaff, prStaff_GetPageable, vwEvent_C, prStfAssn_Imp, pr_User_InsUpd, prDvc_RegWiFi,
--						* tb_User.bOnDuty	-> bDuty	(td_User_OnDuty -> td_User_Duty)
--							vwDvc, pr_User_GetDvcs, prTeam_GetDvcs, vwRoom, prStaff_GetByUnit, prStaff_GetPageable, vwRoomBed, vwShift, prShift_GetAll, vwStfAssn, vwStfCvrg,
--								prStfAssn_GetByRoom, prStfAssn_GetByUnit, prStfCvrg_InsFin, prStaff_SetDuty, pr_User_SyncAD, pr_User_InsUpdAD, pr_User_InsUpd,
--								prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi, prRoomBed_GetAssn
--						* tbStfLvl.idStfLvl	->	idLvl	(prStfLvl_GetAll, prStfLvl_Upd, tb_User)
--							prStaff_Get, prStaff_GetBySID, prStaff_GetByBC, pr_User_Imp, pr_User_GetAll, pr_User_GetOne, prTeam_GetStaff, vwStaff, prStaff_GetAll, vwDvc,
--								pr_User_GetDvcs, prTeam_GetDvcs, prStaff_LstAct, vwRoom, prStaff_GetByUnit, prStaff_GetPageable, vwEvent_C, vwRoomBed, vwEvent41, vwShift, prShift_GetAll, vwStfAssn, vwStfCvrg,
--								prStfAssn_GetByRoom, prStfAssn_GetByUnit, pr_User_InsUpd, fnStfAssn_GetByShift, vwRtlsBadge, prRtlsBadge_InsUpd, prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial
--								prDvc_GetWiFi, prRtlsBadge_UpdLoc, prRoomBed_GetByUnit, prMapCell_GetByMap, prRoomBed_GetAssn,
--								prRptSysActDtl, prRptCallActDtl, prRptStfAssn, prRptStfCvrg
--						* #PKs (in #tables):	nonclustered -> clustered
--							prHealth_Table, prRole_SetTmpFlt, prCall_SetTmpFlt, prUnit_SetTmpFlt, prTeam_SetTmpFlt
--							pr_Role_InsUpd, prTeam_InsUpd, prDvc_InsUpd, prRoom_GetByUnit, prDevice_GetByUnit, prStaff_GetByUnit, prUnit_GetAll, prCfgLoc_SetLvl, pr_User_InsUpd, prRoomBed_GetByUnit,
--							prRptSysActDtl, prRptCallStatSum, prRptCallStatGfx, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl, prRptCallActExc,
--							prRptStfAssn, prRptStfCvrg, prRptRndStatSum, prRptRndStatDtl, prRptCliPatDtl, prRptCliStfDtl, prRptCliStfSum
--						* prRtlsBadge_InsUpd
--						- fnStfAssn_GetByShift		? not used ?
--		2024-Jan-19		.8784
--						* tb_User.idStfLvl	-> idLvl
--						* tbStfLvl.*StfLvl	-> *Lvl,	- .iColorB
--						* vwStaff.idStfLvli	-> idLvli
--		2024-Jan-22		.8787
--						* all prRpt*:	fix for missing join condition with [tb_SessDvc] - 'sr.idSess = @idSess'
--						* prRtlsBadge_InsUpd, prRtlsBadge_UpdLoc
--		2024-Jan-24		.8789
--						* tb_User.sBarCode	-> sCode	(xu_User_Act_BarCode -> xu_User_Act_Code)
--							prStaff_GetByBC, pr_User_Imp, pr_User_GetAll, pr_User_GetOne, vwStaff, pr_User_InsUpd
--						* tbDvc.sBarCode	-> sCode	(xuDvc_Act_BarCode -> xuDvc_Act_Code)
--							vwDvc, prDvc_Exp, prDvc_Imp, pr_User_GetDvcs, prTeam_GetDvcs, prDvc_InsUpd, prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi
--		2024-Jan-25		.8790
--						* pr_User_sStaff_Upd	->	pr_User_UpdStf
--						* prStaff_GetPageable	->	prStaff_GetOnDuty
--						- pr_OptSys_GetSmtp
--		2024-Jan-26		.8791
--						* prTeam_GetEmails
--						* tbCfgLoc	.idParent -> .idPrnt
--						* tbDevice				-> tbCfgDvc		(vwDevice -> vwCfgDvc, tbRoom, vwRoom, prRoom_UpdStaff)
--							* ?Device -> ?Stn, idParent -> idPrnt, sCodeVer -> sVersion, tiPriCA? -> tiPri?, tiAltCA? -> tiAlt?
--							* vwDevice, vwRoom:	.sQnDvc	-> sQnStn
--						* prEventC1_Ins
--		2024-Jan-29		.8794
--						* prDvc_GetByBC		->	prDvc_GetByCode
--						* prStaff_GetByBC	->	prStaff_GetByCode
--		2024-Jan-30		.8795
--						* prDevice_InsUpd	->	prCfgStn_InsUpd
--						* prDevice_GetIns	->	prCfgStn_GetIns	(prEvent_Ins, prRoomBedGetAssn)
--						* prCfgDvc_GetBtns	->	prCfgStn_GetBtns
--						* prRoom_LstAct		->	prRoom_GetAll
--						* prCfgDvc_GetAll	->	prCfgStn_GetAll
--						* prDevice_GetByUnit ->	prCfgStn_GetByUnit
--						* prDevice_GetByID	->	prCfgStn_Get
--						* prCfgDvc_Init		->	prCfgStn_Init
--						* prCfgDvc_UpdAct	->	prCfgStn_UpdAct
--						* prCfgDvc_UpdRmBd	->	prCfgStn_UpdRmBd
--						* pr_SessDvc_Ins	->	pr_SessStn_Ins
--		2024-Jan-31		.8796
--						* tbPatient:	sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--										cGender -> cGndr
--						* tb_Module:	.sMachine -> .sHost
--										.sParams -> .sArgs
--						* tb_Sess:		.sMachine -> .sHost
--						* tbStfAssn:	.idStfAssn -> .idAssn
--						* tbStfCvrg:	.idStfAssn -> .idAssn
--										.idStfCvrg -> .idCvrg
--						* tbEvent:		.idSrcDvc -> .idSrcStn, @	(fkEvent_DvcSrc -> fkEvent_StnSrc)
--										.idDstDvc -> .idDstStn, @	(fkEvent_DvcDst -> fkEvent_StnDst)
--						* tbEvent_C:*	.idEvtVo -> .idEvtV, @
--										.idEvtSt -> .idEvtS, @
--						* tbEvent_D:*	.idEvntP -> .idEvtP, @
--										.idEvntS -> .idEvtS, @
--										.idEvntD -> .idEvtD, @
--						* tbCall:		.tVoTrg -> tVoice, @
--										.tStTrg -> tStaff, @
--						* tb_SessCall:	.tVoTrg -> tVoice, @
--										.tStTrg -> tStaff, @
--		2024-Feb-01		.8797
--						* tbEvent:		+ .utEvent	(vwEvent, 
--						* tb_Log:		+ .utLog	(vw_Log, 
--		2024-Feb-05		.8801
--						* tb_LogType:	.idLogType -> idType, @
--										.sLogType -> sType, @
--						* prFilter_Del
--		2024-Feb-14		.8810
--						* vwRoom		(prRoomBed_GetByUnit)
--						* vwRoomBed
--		2024-Mar-05		.8830
--						* prSchedule_InsUpd
--		2024-Mar-20		.8845
--						* prSchedule_GetAll
--		2024-Mar-21		.8846
--						* pr_Access_InsUpdDel
--						* vwShift
--						+ vwUnit		(prStfAssn_InsUpdDel, prShift_Upd, prShift_InsUpd)
--						* prSchedule_GetToRun
--						* prRtlsBadge_UpdLoc
--		2024-Mar-22		.8847
--		2024-Mar-25		.8850
--						+ vwCall
--						+ tbFltr, tbFltrUser, tbFltrShift, tbFltrStn, tbFltrCall
--		2024-Apr-06		.8862
--						* prCall_Imp
--		2024-Apr-11		.8867
--						* prEvent_SetGwState
--		2024-Apr-26		.8882
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

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 8882 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.8882', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStfAssn_GetByShift')
	drop function	dbo.fnStfAssn_GetByShift
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetPageable')
	drop proc	dbo.prStaff_GetPageable
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetOnDuty')
	drop proc	dbo.prStaff_GetOnDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptSys_GetSmtp')
	drop proc	dbo.pr_OptSys_GetSmtp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptionSys_GetSmtp')
	drop proc	dbo.pr_OptionSys_GetSmtp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByBC')
	drop proc	dbo.pr_User_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByCode')
	drop proc	dbo.pr_User_GetByCode
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByBC')
	drop proc	dbo.prStaff_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByCode')
	drop proc	dbo.prStaff_GetByCode
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_sStaff_Upd')
	drop proc	dbo.pr_User_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_UpdStaff')
	drop proc	dbo.pr_User_UpdStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_sStaff_Upd')
	drop proc	dbo.prUser_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_InsUpd')
	drop proc	dbo.prDevice_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_InsUpd')
	drop proc	dbo.prCfgStn_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetIns')
	drop proc	dbo.prDevice_GetIns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetIns')
	drop proc	dbo.prCfgStn_GetIns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_GetBtns')
	drop proc	dbo.prCfgDvc_GetBtns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetBtns')
	drop proc	dbo.prCfgStn_GetBtns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_LstAct')
	drop proc	dbo.prRoom_LstAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetAll')
	drop proc	dbo.prRoom_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_GetAll')
	drop proc	dbo.prCfgDvc_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetAll')
	drop proc	dbo.prCfgStn_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetByID')
	drop proc	dbo.prDevice_GetByID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_Get')
	drop proc	dbo.prCfgStn_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetByUnit')
	drop proc	dbo.prDevice_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetByUnit')
	drop proc	dbo.prCfgStn_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_Init')
	drop proc	dbo.prCfgDvc_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_Init')
	drop proc	dbo.prCfgStn_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_UpdAct')
	drop proc	dbo.prCfgDvc_UpdAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByCode')
	drop proc	dbo.prDvc_GetByCode
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_UpdAct')
	drop proc	dbo.prCfgStn_UpdAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_UpdRmBd')
	drop proc	dbo.prCfgDvc_UpdRmBd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_UpdRmBd')
	drop proc	dbo.prCfgStn_UpdRmBd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessDvc_Ins')
	drop proc	dbo.pr_SessDvc_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessStn_Ins')
	drop proc	dbo.pr_SessStn_Ins
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCall')
	drop view	dbo.vwCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwUnit')
	drop view	dbo.vwUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCfgStn')
	drop view	dbo.vwCfgStn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbFltrCall')
	drop table	dbo.tbFltrCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbFltrStn')
	drop table	dbo.tbFltrStn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbFltrShift')
	drop table	dbo.tbFltrShift
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbFltrUser')
	drop table	dbo.tbFltrUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbFltr')
	drop table	dbo.tbFltr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessDvc')
	drop table	dbo.tb_SessDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessStn')
	drop table	dbo.tb_SessStn
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tvDvc_Assn')
	alter table	dbo.tbDvc	drop constraint	tvDvc_Assn
go
--	----------------------------------------------------------------------------
--	Returns # of rows, data and index sizes for all tables in the DB
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbSize
	(
		object_id	int			not null	primary key clustered
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

	insert	#tbSize
		select	t.object_id,	min(s.name),	min(t.name)		--,	null, null, null,			--,	i.object_id, i.index_id, i.name
			,		sum(case when i.index_id > 1 then 0 else p.rows end)						--	lRows
			,	8 * sum(a.total_pages)															--	lTotal,	sum(a.used_pages),	lUsed
			,	8 * sum(case when i.index_id > 1 then 0 else a.total_pages - a.used_pages end)	--	lUnused
			,	8 * sum(case when i.index_id > 1 then 0 else a.data_pages end)					--	lData
--			,		sum(case when i.index_id > 1 then a.total_pages else 0 end)					--	lIndex
			from	sys.objects		t
			join	sys.schemas		s	on	s.schema_id		= t.schema_id
			join	sys.indexes		i	on	i.object_id		= t.object_id
			join	sys.partitions	p	on	p.object_id		= i.object_id	and	p.index_id	= i.index_id
			join	sys.allocation_units	a	on	a.container_id	= p.partition_id
			where	t.type = 'U'	and	t.object_id > 255	--	AND	i.index_id <= 1
			group	by	t.object_id		--,	s.name,	t.name,		i.object_id, i.index_id, i.name

	if	@bActive = 0
		select	sSchema, sTable,	lRows	--,	index_id	as	iIdx,	sIndex
			,	lTotal,	lUnused,	lData
			,	(lTotal - lUnused - lData)	as	lIndex
			from	#tbSize
			order	by	1, 2	--	sSchema, sTable
	else
		select	sSchema, sTable,	lRows	--,	index_id	as	iIdx,	sIndex
			,	lTotal,	lUnused,	lData
			,	(lTotal - lUnused - lData)	as	lIndex
			from	#tbSize
			order	by	4	desc	--	lTotal

--	drop table #tb
end
go
--	----------------------------------------------------------------------------
--	Returns # of rows, data and index sizes for all tables in the DB
--	7.06.6502
alter proc		dbo.prHealth_Index
(
	@bActive	bit		=	0		-- 0=by name, 1=by avg-frag desc
)
	with encryption
as
begin
	if	@bActive = 0
		select	idx.object_id
			,	object_name( idx.object_id )	as	sTable
			,	idx.index_id
			,	idx.name						as	sIndex
			,	ips.index_depth
			,	idx.is_primary_key
			,	idx.is_unique
			,	idx.is_unique_constraint
			,	idx.type
			,	ips.index_type_desc				as	sType
			,	idx.fill_factor
			,	ips.page_count
			,	ips.fragment_count
			,	ips.avg_fragmentation_in_percent	as	fAvgFrg
		--	,	ips.ghost_record_count
		--	,	ips.record_count
		--	,	ips.index_level
			from	sys.dm_db_index_physical_stats( db_id(), null, null, null, null )	ips 
			join	sys.indexes	idx		on	idx.object_id = ips.object_id	and	idx.index_id = ips.index_id
			order	by	2,	3
	else
		select	idx.object_id
			,	object_name( idx.object_id )	as	sTable
			,	idx.index_id
			,	idx.name						as	sIndex
			,	ips.index_depth
			,	idx.is_primary_key
			,	idx.is_unique
			,	idx.is_unique_constraint
			,	idx.type
			,	ips.index_type_desc				as	sType
			,	idx.fill_factor
			,	ips.page_count
			,	ips.fragment_count
			,	ips.avg_fragmentation_in_percent	as	fAvgFrg
			from	sys.dm_db_index_physical_stats( db_id(), null, null, null, null )	ips 
			join	sys.indexes	idx		on	idx.object_id = ips.object_id	and	idx.index_id = ips.index_id
			order	by	fAvgFrg	desc
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .sMachine -> .sHost
--				* .sParams -> .sArgs
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'sMachine')
begin
	begin tran
		exec sp_rename 'tb_Module.sMachine',	'sHost',	'column'
		exec sp_rename 'tb_Module.sParams',		'sArgs',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Marks a module with latest activity
--	7.05.5059	- nocount
--	7.00
alter proc		dbo.pr_Module_Act
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
--	set	nocount	on
	begin	tran
		update	dbo.tb_Module	set	dtLastAct=	getdate( )
			where	idModule = @idModule
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns given module's logging level
--	7.06.7030
alter proc		dbo.pr_Module_GetLvl
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
--	set	nocount	on
	select	tiLvl
		from	dbo.tb_Module	with (nolock)
		where	idModule = @idModule
end
go
--	----------------------------------------------------------------------------
--	Returns modules state
--	7.06.8796	* .sMachine -> .sHost, sHost -> sIpHost
--				* .sParams -> .sArgs
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
	select	idModule, sModule, sDesc, bLicense, tiModType, tiLvl, sIpAddr, sHost, sVersion, iPID, dtStart, sArgs, dtLastAct
		,	case when sHost is null then sIpAddr else sHost end	as	sIpHost
		,	datediff( ss, dtLastAct, getdate( ) )				as	siElapsed
		,	cast( getdate( ) - dtStart as datetime )			as	dtRunTime
		from	dbo.tb_Module	with (nolock)
		where	(@bInstall = 0	or	sIpAddr is not null  or  sHost is not null)
		and		(@bActive = 0	or	dtStart is not null)
end
go
--	----------------------------------------------------------------------------
--	7.06.8784	- .iColorB		BG-colors are now taken from corresponding presense call-priorities (Spec=7,8,9)
--				* *StfLvl	-> *Lvl
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStfLvl') and name = 'idStfLvl')
begin
	begin tran
		alter table	dbo.tbStfLvl	drop	column	iColorB

		exec sp_rename 'tbStfLvl.idStfLvl',	'idLvl',	'column'
		exec sp_rename 'tbStfLvl.cStfLvl',	'cLvl',		'column'
		exec sp_rename 'tbStfLvl.sStfLvl',	'sLvl',		'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns staff-levels
--	7.06.8784	- .iColorB
--				* idStfLvl	-> idLvl
--				* cStfLvl	-> cLvl
--				* sStfLvl	-> sLvl
--	7.06.8139	+ .cStfLvl
--	7.06.5400
alter proc		dbo.prStfLvl_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLvl, cLvl, sLvl
		from	dbo.tbStfLvl	with (nolock)
end
go
--	----------------------------------------------------------------------------
--	7.06.8789	* .sBarCode	-> sCode	(xu_User_Act_BarCode -> xu_User_Act_Code)
--	7.06.8784	* .idStfLvl	-> idLvl
--	7.06.8783	* .sStaffID -> sStfID	(xu_User_Act_StaffID -> xu_User_Act_StfID)
--				* .bOnDuty	-> bDuty	(td_User_OnDuty -> td_User_Duty)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'sStaffID')
begin
	begin tran
		if	exists	(select 1 from dbo.sysindexes where name='xu_User_Act_StaffID')
			drop index	tb_User.xu_User_Act_StaffID
		if	exists	(select 1 from dbo.sysindexes where name='xu_User_Act_BarCode')
			drop index	tb_User.xu_User_Act_BarCode

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdUser_OnDuty')
			alter table	dbo.tb_User	drop	constraint	tdUser_OnDuty
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='td_User_OnDuty')
			alter table	dbo.tb_User	drop	constraint	td_User_OnDuty
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='td_User_Duty')
			alter table	dbo.tb_User	drop	constraint	td_User_Duty
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tv_User_Duty')
			alter table	dbo.tb_User	drop	constraint	tv_User_Duty

		exec sp_rename 'tb_User.sStaffID',	'sStfID',	'column'
		exec sp_rename 'tb_User.idStfLvl',	'idLvl',	'column'
		exec sp_rename 'tb_User.sBarCode',	'sCode',	'column'
		exec sp_rename 'tb_User.bOnDuty',	'bDuty',	'column'
	commit
end
go
if	not exists	(select 1 from dbo.sysindexes where name='xu_User_Act_StfID')
begin
	begin tran
		create unique nonclustered index	xu_User_Act_StfID		on	dbo.tb_User ( sStfID )	where	bActive > 0		and	sStfID is not null
		create unique nonclustered index	xu_User_Act_Code		on	dbo.tb_User ( sCode )	where	bActive > 0		and	sCode is not null
/*	commit
end
g o
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'bOnDuty')
begin
	begin tran
*//*	commit
end
g o
if	not exists	(select 1 from dbo.sysobjects where name='td_User_Duty')
begin
*/		alter table	dbo.tb_User	add
			constraint	td_User_Duty	default( 0 )	for	bDuty
		,	constraint	tv_User_Duty	check	( (bDuty = 0	and	(dtDue is null	or	bActive > 0))	or	bDuty > 0  and  dtDue is null  and  bActive > 0 )
/*end
g o
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'idStfLvl')
begin
	begin tran
*/	commit
end
go
--	----------------------------------------------------------------------------
--	Returns staff member by the given ID
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.5430	+ pr_User_Get -> prStaff_Get
--	7.06.5417
alter proc		dbo.prStaff_Get
(
	@idUser		int					-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.tb_User		with (nolock)
		where	idUser = @idUser
end
go
--	----------------------------------------------------------------------------
--	Returns staff details for given staff-id
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID, @
--	7.06.5429	+ .sStaffID, .bOnDuty, .dtDue
--	7.06.5428	* prStaff_GetByStfID -> prStaff_GetBySID
--	7.05.5185
alter proc		dbo.prStaff_GetBySID
(
	@sStfID		varchar( 16 )
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.tb_User		with (nolock)
		where	sStfID = @sStfID	and	bActive > 0
end
go
--	----------------------------------------------------------------------------
--	Returns staff member by the given bar-code
--	7.06.8794	* prStaff_GetByBC	-> prStaff_GetByCode
--	7.06.8789	* tb_User.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.5428
create proc		dbo.prStaff_GetByCode
(
	@sCode		varchar( 32 )		-- bar-code
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.tb_User		with (nolock)
		where	sCode = @sCode	and	bActive > 0
end
go
grant	execute				on dbo.prStaff_GetByCode			to [rWriter]
grant	execute				on dbo.prStaff_GetByCode			to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a user
--	7.06.8789	* tb_User.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl, @
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID, @
--	7.06.6814	- tb_User.sTeams,.sUnits
--	7.06.5961	+ @sTeams, .gGUID, .utSynched
--	7.05.5121	+ .sUnits
--	7.05.4986	- @bLocked
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked
--	7.04.4965
alter proc		dbo.pr_User_Imp
(
	@idUser		int
,	@sUser		varchar( 32 )
,	@iHash		int
,	@tiFails	tinyint
,	@sFrst		varchar( 16 )
,	@sMidd		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
,	@dtLastAct	datetime
,	@sStfID		varchar( 16 )
,	@idLvl		tinyint
,	@sCode		varchar( 32 )
,	@bDuty		bit
,	@dtDue		smalldatetime
,	@sStaff		varchar( 16 )
,	@gGUID		uniqueidentifier	-- AD GUID
,	@utSynched	smalldatetime		-- UTC last sync with AD
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not exists	(select 1 from dbo.tb_User with (updlock) where idUser = @idUser)
		begin
			set identity_insert	dbo.tb_User	on

			insert	dbo.tb_User	(  idUser,  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc
								,  dtLastAct,  sStfID,  idLvl,  sCode,  bDuty,  dtDue,  sStaff
								,  gGUID,  utSynched,  bActive,  dtCreated,  dtUpdated )
					values		( @idUser, @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc
								, @dtLastAct, @sStfID, @idLvl, @sCode, @bDuty, @dtDue, @sStaff
								, @gGUID, @utSynched, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tb_User	off
		end
		else
			update	dbo.tb_User	set	sUser=	@sUser,	iHash=	@iHash,	tiFails =	@tiFails
							,	sFrst=	@sFrst,		sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
							,	dtLastAct=	@dtLastAct,	sStfID =	@sStfID,	idLvl=	@idLvl
							,	sCode=	@sCode,	bDuty =	@bDuty,	dtDue=	@dtDue
							,	sStaff =	@sStaff,	gGUID=	@gGUID
							,	utSynched=	@utSynched,	bActive =	@bActive,	dtCreated=	@dtCreated,	dtUpdated=	@dtUpdated
				where	idUser = @idUser

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all roles
--	7.06.5385
alter proc		dbo.pr_Role_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idRole, sRole, sDesc, bActive, dtCreated, dtUpdated
		from	dbo.tb_Role		with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a role
--	7.06.5983	* @sDesc: vc(16) -> vc(255)
--	7.06.5385
alter proc		dbo.pr_Role_Imp
(
	@idRole		smallint
,	@sRole		varchar( 16 )
,	@sDesc		varchar( 255 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not	exists	(select 1 from dbo.tb_Role with (updlock) where idRole = @idRole)
		begin
			set identity_insert	dbo.tb_Role	on

			insert	dbo.tb_Role	(  idRole,  sRole,  sDesc,  bActive,  dtCreated,  dtUpdated )
					values		( @idRole, @sRole, @sDesc, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tb_Role	off
		end
		else
			update	dbo.tb_Role	set	sRole= @sRole, sDesc= @sDesc, bActive= @bActive, dtUpdated= @dtUpdated
				where	idRole = @idRole

	commit
end
go
--	----------------------------------------------------------------------------
--	Fills  #tbRole with given idRole-s
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.5380	+ "or	@sRoles = ''"
--	7.06.5354
alter proc		dbo.prRole_SetTmpFlt
(
	@sRoles		varchar( 255 )		-- comma-separated idRole-s, '*'=all or null
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbRole						-- no enforcement of FKs
	(
		idRole		smallint		not null	primary key clustered
--	,	sRole		varchar( 16 )	not null
	)
*/
	if	@sRoles = ''	or	@sRoles is null
		return	0

	if	@sRoles = '*'
	begin
		insert	#tbRole
			select	idRole	--, sRole
				from	dbo.tb_Role		with (nolock)
				where	bActive > 0		--	enabled
	end
	else
	begin
		select	@s=
		'insert	#tbRole
			select	idRole
				from	dbo.tb_Role		with (nolock)
				where	bActive > 0
				and		idRole in (' + @sRoles + ')'
		exec( @s )
	end
--	select	*	from	#tbUnit
end
go
--	----------------------------------------------------------------------------
--	Returns users for a given role
--	7.06.6817	+ order by 2
--	7.06.6807
--	7.06.5417	as	pr_UserRole_GetByRole
alter proc		dbo.pr_Role_GetUsers
(
	@idRole		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUser, t.sStaff
		from	dbo.tb_UserRole	m	with (nolock)
		join	dbo.tb_User		t	with (nolock)	on	t.idUser = m.idUser
		where	idRole = @idRole
		and		m.idUser > 1												--	protect 'sysadm' account
--	-	and		m.idUser > 15												--	protect internal accounts
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Returns roles for a given user
--	7.06.6817	+ order by 2
--	7.06.6807
--	7.06.5417	as	pr_UserRole_GetByUser
alter proc		dbo.pr_User_GetRoles
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idRole, t.sRole
		from	dbo.tb_UserRole	m	with (nolock)
		join	dbo.tb_Role		t	with (nolock)	on	t.idRole = m.idRole
		where	idUser = @idUser
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Exports all user-role combinations
--	7.06.6816	* order by 1
--	7.06.5385
alter proc		dbo.pr_UserRole_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idRole, dtCreated
		from	dbo.tb_UserRole		with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a user-role combination
--	7.06.5385
alter proc		dbo.pr_UserRole_Imp
(
	@idUser		int					--	0=clear table
,	@idRole		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idUser > 0
		begin
			if	not	exists	(select 1 from dbo.tb_UserRole with (updlock) where idRole = @idRole and idUser = @idUser)
			begin
				insert	dbo.tb_UserRole	(  idUser,  idRole,  dtCreated )
						values			( @idUser, @idRole, @dtCreated )
			end
		end
		else
			delete	from	dbo.tb_UserRole

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5399
alter view		dbo.vw_OptSys
	with encryption
as
	select	v.idOption, o.sOption, o.tiDatatype, v.iValue, v.fValue, v.tValue, v.sValue, v.dtUpdated
		from	dbo.tb_OptSys	v	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption	= v.idOption
go
--	----------------------------------------------------------------------------
--	Returns all system settings
--	7.04.4898
alter proc		dbo.pr_OptSys_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idOption, iValue, fValue, tValue, sValue
		from	dbo.tb_OptSys	with (nolock)
end
go
--	----------------------------------------------------------------------------
--	Updates DB stats (# of Size and Used pages - for data and tlog)
--	7.06.8796	* .sMachine -> .sHost
--				* .sParams -> .sArgs
--	7.06.8725	+ recovery_model
--				+ last backup dates
--	7.06.8712
alter proc		dbo.prHealth_Stats
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@iRM		int
		,		@iSizeD		int
		,		@iUsedD		int
		,		@iSizeL		int
		,		@iUsedL		int
		,		@dBkupD		datetime
		,		@dBkupL		datetime

	set	nocount	on

	select	@iSizeD =	size,	@iUsedD =	cast(fileproperty(name, 'spaceused') as int)
		from	sys.database_files	with (nolock)
		where	[type] = 0													-- .mdf

	select	@iSizeL =	size,	@iUsedL =	cast(fileproperty(name, 'spaceused') as int)
		from	sys.database_files	with (nolock)
		where	[type] = 1													-- .ldf

	select	@s =	cast(cast(@iSizeD / 128.0 as decimal(18,1)) as varchar) + '(' + cast(cast(@iUsedD * 100.0 / @iSizeD as decimal(18)) as varchar) + '%) / '
				+	cast(cast(@iSizeL / 128.0 as decimal(18,1)) as varchar) + '(' + cast(cast(@iUsedL * 100.0 / @iSizeL as decimal(18)) as varchar) + '%) MiB @'
				+	@@servicename + ' [' + lower(recovery_model_desc) + ']'
--				+	case when log_reuse_wait = 0 then '' else ',' + lower(log_reuse_wait_desc) end	-- cast(log_reuse_wait as varchar)
		,	@iRM =	recovery_model
		from	master.sys.databases	with (nolock)
		where	database_id = db_id( )

	select	top	1	@dBkupD =	backup_finish_date
		from	msdb.dbo.backupset	with (nolock)
		where	database_name = db_name( )	and	[type] = 'D' 				-- .mdf
		order	by	1	desc

	select	top	1	@dBkupL =	backup_finish_date
		from	msdb.dbo.backupset	with (nolock)
		where	database_name = db_name( )	and	[type] = 'L' 				-- .mdf
		order	by	1	desc

	begin	tran

		update	dbo.tb_OptSys	set	iValue =	@iRM		where	idOption = 50

		update	dbo.tb_OptSys	set	iValue =	@iSizeD		where	idOption = 51
		update	dbo.tb_OptSys	set	iValue =	@iUsedD		where	idOption = 52

		update	dbo.tb_OptSys	set	iValue =	@iSizeL		where	idOption = 53
		update	dbo.tb_OptSys	set	iValue =	@iUsedL		where	idOption = 54

		if	@dBkupD	is not null
			update	dbo.tb_OptSys	set	tValue =	@dBkupD		where	idOption = 55
		if	@dBkupL	is not null
			update	dbo.tb_OptSys	set	tValue =	@dBkupL		where	idOption = 56

		update	dbo.tb_Module	set	sArgs =	@s		where	idModule = 1

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates full formatted name
--	7.06.8790	* pr_User_sStaff_Upd	->	pr_User_UpdStaff
--	7.06.8286	* special handling for RTLS auto-users
--	7.06.7367	* predefined account protection
--	7.06.7292	* tb_Option[11]<->[19]
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
create proc		dbo.pr_User_UpdStaff
(
	@idUser		int			= null	-- null=any
)
	with encryption
as
begin
	declare		@tiFmt	tinyint	
		,		@sRtls	varchar( 16 )

	set	nocount	on

	select	@tiFmt =	cast(iValue as tinyint)		from	dbo.tb_OptSys	with (nolock)	where	idOption = 19
	select	@sRtls =	char(0x7F) + 'RTLS'									--	for auto-users

	set	nocount	off

	begin	tran

		update	dbo.tb_User		set	sStaff =
				case when sFrst = @sRtls	then	@sRtls + ' ' + sUser	--	sFrst + ' ' + sLast
					else left( ltrim( rtrim( replace( case
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
							end, '  ', ' ' ) ) ), 16 )
					end
			where	idUser > 15			--	protect internal accounts
			and		(idUser = @idUser	or	@idUser is null)

	commit
end
go
grant	execute				on dbo.pr_User_UpdStaff				to [rWriter]
grant	execute				on dbo.pr_User_UpdStaff				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5399
alter view		dbo.vw_OptUsr
	with encryption
as
	select	v.idOption, o.sOption, o.tiDatatype, v.iValue, v.fValue, v.tValue, v.sValue, v.dtUpdated, v.idUser, u.sUser
		from	dbo.tb_OptUsr	v	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption	= v.idOption
		join	dbo.tb_User		u	with (nolock)	on	u.idUser	= v.idUser
go
--	----------------------------------------------------------------------------
--	Returns all settings, overriding system defaults with user-specific values
--	7.06.7390
alter proc		dbo.pr_OptUsr_GetAll
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	s.idOption
		,	coalesce(u.iValue, s.iValue)	as	iValue
		,	coalesce(u.fValue, s.fValue)	as	fValue
		,	coalesce(u.tValue, s.tValue)	as	tValue
		,	coalesce(u.sValue, s.sValue)	as	sValue
		from		dbo.tb_OptSys	s	with (nolock)
		left join	dbo.tb_OptUsr	u	with (nolock)	on	u.idOption	= s.idOption	and	idUser	= @idUser
end
go
--	----------------------------------------------------------------------------
--	<20,tb_Log>
--	7.06.8797	+ .utLog
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Log') and name = 'utLog')
--	and	not	exists	(select 1 from dbo.sysobjects where uid=1 and name='td_Log_UTC')
begin
	begin tran
		alter table	dbo.tb_Log	add
			utLog		datetime		not null	-- auto: UTC date-time
				constraint	td_Log_UTC		default( getutcdate( ) )

		exec( 'update	dbo.tb_Log	set	utLog=	dtLog' )
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8802	* fk_Log_LogType -> fk_Log_Type
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_Log_LogType')
begin
	begin tran
		alter table	dbo.tb_Log		drop constraint	fk_Log_LogType
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8802	* fkEvent_LogType -> fkEvent_Type
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_LogType')
begin
	begin tran
		alter table	dbo.tbEvent		drop constraint	fkEvent_LogType
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_LogType') and name = 'idLogType')
begin
	begin tran
		exec sp_rename 'tb_LogType.idLogType',	'idType',	'column'
		exec sp_rename 'tb_LogType.sLogType',	'sType',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns details for all log-types
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.7123	* tb_LogType.tiSrc -> .tiCat
--	7.06.6555
alter proc		dbo.pr_LogType_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idType, tiLvl, tiCat, sType
		from	dbo.tb_LogType		with (nolock)
end
go
--	----------------------------------------------------------------------------
--	7.06.8802	* .idLogType -> idType, @
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Log') and name = 'idLogType')
begin
	begin tran
		exec sp_rename 'tb_Log.idLogType',	'idType',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8802	* fk_Log_LogType -> fk_Log_Type
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_Log_Type')
begin
	begin tran
		alter table	dbo.tb_Log		add
			constraint	fk_Log_Type		foreign key	(idType)	references	tb_LogType
	commit
end
go
--	----------------------------------------------------------------------------
--	Audit log
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8797	+ .utLog
--	7.06.6498	+ .tLast, tiQty
--	7.06.6298	+ .idModule
--	7.06.5399	* optimized
--	6.07
alter view		dbo.vw_Log
	with encryption
as
--	select	l.idLog, dtLog, dLog, tLog, l.idLogType as idType, t.sLogType as sType, l.idModule, m.sModule, sLog, tLast, tiQty, l.idUser, u.sUser
	select	l.idLog, utLog, dtLog, dLog, tLog, l.idType, t.sType, l.idModule, m.sModule, sLog, tLast, tiQty, l.idUser, u.sUser
--	select	l.idLog, l.utLog, l.dtLog, l.dLog, l.tLog, l.idType, t.sType, l.idModule, m.sModule, l.sLog, l.tLast, l.tiQty, l.idUser, u.sUser
		from	dbo.tb_Log		l	with (nolock)
--		join	dbo.tb_LogType	t	with (nolock)	on t.idLogType	= l.idLogType
		join	dbo.tb_LogType	t	with (nolock)	on t.idType		= l.idType
	left join	dbo.tb_Module	m	with (nolock)	on m.idModule	= l.idModule
	left join	dbo.tb_User		u	with (nolock)	on u.idUser		= l.idUser
go
--	----------------------------------------------------------------------------
--	Log statistics by hour
--	7.06.6498
alter view		dbo.vw_Log_S
	with encryption
as
select	dLog
	,	min(case when tiHH = 00 then idLog else null end)	as	idLog00
	,	min(case when tiHH = 01 then idLog else null end)	as	idLog01
	,	min(case when tiHH = 02 then idLog else null end)	as	idLog02
	,	min(case when tiHH = 03 then idLog else null end)	as	idLog03
	,	min(case when tiHH = 04 then idLog else null end)	as	idLog04
	,	min(case when tiHH = 05 then idLog else null end)	as	idLog05
	,	min(case when tiHH = 06 then idLog else null end)	as	idLog06
	,	min(case when tiHH = 07 then idLog else null end)	as	idLog07
	,	min(case when tiHH = 08 then idLog else null end)	as	idLog08
	,	min(case when tiHH = 09 then idLog else null end)	as	idLog09
	,	min(case when tiHH = 10 then idLog else null end)	as	idLog10
	,	min(case when tiHH = 11 then idLog else null end)	as	idLog11
	,	min(case when tiHH = 12 then idLog else null end)	as	idLog12
	,	min(case when tiHH = 13 then idLog else null end)	as	idLog13
	,	min(case when tiHH = 14 then idLog else null end)	as	idLog14
	,	min(case when tiHH = 15 then idLog else null end)	as	idLog15
	,	min(case when tiHH = 16 then idLog else null end)	as	idLog16
	,	min(case when tiHH = 17 then idLog else null end)	as	idLog17
	,	min(case when tiHH = 18 then idLog else null end)	as	idLog18
	,	min(case when tiHH = 19 then idLog else null end)	as	idLog19
	,	min(case when tiHH = 20 then idLog else null end)	as	idLog20
	,	min(case when tiHH = 21 then idLog else null end)	as	idLog21
	,	min(case when tiHH = 22 then idLog else null end)	as	idLog22
	,	min(case when tiHH = 23 then idLog else null end)	as	idLog23

	,	max(case when tiHH = 00 then siCrt else 0 end)	as	siCrt00
	,	max(case when tiHH = 01 then siCrt else 0 end)	as	siCrt01
	,	max(case when tiHH = 02 then siCrt else 0 end)	as	siCrt02
	,	max(case when tiHH = 03 then siCrt else 0 end)	as	siCrt03
	,	max(case when tiHH = 04 then siCrt else 0 end)	as	siCrt04
	,	max(case when tiHH = 05 then siCrt else 0 end)	as	siCrt05
	,	max(case when tiHH = 06 then siCrt else 0 end)	as	siCrt06
	,	max(case when tiHH = 07 then siCrt else 0 end)	as	siCrt07
	,	max(case when tiHH = 08 then siCrt else 0 end)	as	siCrt08
	,	max(case when tiHH = 09 then siCrt else 0 end)	as	siCrt09
	,	max(case when tiHH = 10 then siCrt else 0 end)	as	siCrt10
	,	max(case when tiHH = 11 then siCrt else 0 end)	as	siCrt11
	,	max(case when tiHH = 12 then siCrt else 0 end)	as	siCrt12
	,	max(case when tiHH = 13 then siCrt else 0 end)	as	siCrt13
	,	max(case when tiHH = 14 then siCrt else 0 end)	as	siCrt14
	,	max(case when tiHH = 15 then siCrt else 0 end)	as	siCrt15
	,	max(case when tiHH = 16 then siCrt else 0 end)	as	siCrt16
	,	max(case when tiHH = 17 then siCrt else 0 end)	as	siCrt17
	,	max(case when tiHH = 18 then siCrt else 0 end)	as	siCrt18
	,	max(case when tiHH = 19 then siCrt else 0 end)	as	siCrt19
	,	max(case when tiHH = 20 then siCrt else 0 end)	as	siCrt20
	,	max(case when tiHH = 21 then siCrt else 0 end)	as	siCrt21
	,	max(case when tiHH = 22 then siCrt else 0 end)	as	siCrt22
	,	max(case when tiHH = 23 then siCrt else 0 end)	as	siCrt23

	,	max(case when tiHH = 00 then siErr else 0 end)	as	siErr00
	,	max(case when tiHH = 01 then siErr else 0 end)	as	siErr01
	,	max(case when tiHH = 02 then siErr else 0 end)	as	siErr02
	,	max(case when tiHH = 03 then siErr else 0 end)	as	siErr03
	,	max(case when tiHH = 04 then siErr else 0 end)	as	siErr04
	,	max(case when tiHH = 05 then siErr else 0 end)	as	siErr05
	,	max(case when tiHH = 06 then siErr else 0 end)	as	siErr06
	,	max(case when tiHH = 07 then siErr else 0 end)	as	siErr07
	,	max(case when tiHH = 08 then siErr else 0 end)	as	siErr08
	,	max(case when tiHH = 09 then siErr else 0 end)	as	siErr09
	,	max(case when tiHH = 10 then siErr else 0 end)	as	siErr10
	,	max(case when tiHH = 11 then siErr else 0 end)	as	siErr11
	,	max(case when tiHH = 12 then siErr else 0 end)	as	siErr12
	,	max(case when tiHH = 13 then siErr else 0 end)	as	siErr13
	,	max(case when tiHH = 14 then siErr else 0 end)	as	siErr14
	,	max(case when tiHH = 15 then siErr else 0 end)	as	siErr15
	,	max(case when tiHH = 16 then siErr else 0 end)	as	siErr16
	,	max(case when tiHH = 17 then siErr else 0 end)	as	siErr17
	,	max(case when tiHH = 18 then siErr else 0 end)	as	siErr18
	,	max(case when tiHH = 19 then siErr else 0 end)	as	siErr19
	,	max(case when tiHH = 20 then siErr else 0 end)	as	siErr20
	,	max(case when tiHH = 21 then siErr else 0 end)	as	siErr21
	,	max(case when tiHH = 22 then siErr else 0 end)	as	siErr22
	,	max(case when tiHH = 23 then siErr else 0 end)	as	siErr23

	from	dbo.tb_Log_S	with (nolock)
	group	by	dLog
go
--	----------------------------------------------------------------------------
--	Returns access permissions for a given role, combined by modules
--	7.05.5234
alter proc		dbo.pr_Role_GetPerms
(
	@idRole		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idModule,	min(m.sDesc)	as	sDesc,	sum(a.tiAccess)	as	tiAccess,	count(*)	as	lCount
		from	dbo.tb_Module	m	with (nolock)
		join	dbo.tb_Feature	f	with (nolock)	on	f.idModule	= m.idModule
	left join	dbo.tb_Access	a	with (nolock)	on	a.idModule	= f.idModule	and	a.idFeature	= f.idFeature	and	a.idRole	= @idRole
		group	by	m.idModule
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates or deletes an access permission
--	7.06.8846	* fix 'dbo.dbo.tb_Access'
--	7.06.7279	* optimized logging
--	7.05.5234
alter proc		dbo.pr_Access_InsUpdDel
(
	@idUser		int					-- user, performing the action
,	@idModule	tinyint
,	@idFeature	tinyint
,	@idRole		smallint
,	@tiAccess	tinyint
)
	with encryption, exec as owner
as
begin
	declare		@idType		tinyint
			,	@s			varchar( 255 )

	set	nocount	on

	select	@s= 'm=' + isnull(cast(@idModule as varchar), '?') + ', f=' + isnull(cast(@idFeature as varchar), '?') +
				', r=' + isnull(cast(@idRole as varchar), '?') + ', a=' + isnull(cast(@tiAccess as varchar), '?') + ' )'
	begin	tran

		if	@tiAccess > 0
		begin
			if	not exists	(select 1 from dbo.tb_Access where idModule = @idModule and idFeature = @idFeature and idRole = @idRole)
			begin
				select	@s= 'Acc_I( ' + @s,	@idType=	247

				insert	dbo.tb_Access	(  idModule,  idFeature,  idRole,  tiAccess )
						values			( @idModule, @idFeature, @idRole, @tiAccess )
			end
			else
			begin
				select	@s= 'Acc_U( ' + @s,	@idType=	248

				update	dbo.tb_Access	set	dtUpdated=	getdate( ),	tiAccess =	@tiAccess
					where	idModule = @idModule	and idFeature	= @idFeature	and idRole	= @idRole
			end
		end
		else
		begin
				select	@s= 'Acc_D( ' + @s,	@idType=	249

				delete	from	dbo.tb_Access
					where	idModule = @idModule	and idFeature	= @idFeature	and idRole	= @idRole
		end

		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns access permissions for a given role
--	7.05.5234
alter proc		dbo.pr_Access_GetByRole
(
	@idRole		smallint
)
	with encryption
as
begin
	select	m.idModule, f.idFeature, m.sDesc, f.sFeature, a.tiAccess	--, m.sModule
		from	dbo.tb_Module	m	with (nolock)
		join	dbo.tb_Feature	f	with (nolock)	on	f.idModule	= m.idModule
	left join	dbo.tb_Access	a	with (nolock)	on	a.idModule	= f.idModule	and	a.idFeature	= f.idFeature	and	a.idRole	= @idRole
end
go
--	----------------------------------------------------------------------------
--	Returns access permissions for a given role
--	7.06.8789	* optimized
--	7.05.5248
alter proc		dbo.pr_Access_GetByUser
(
	@idModule	tinyint
,	@idUser		int
)
	with encryption
as
begin
	select	a.idFeature,	max(a.tiAccess)	as	tiAccess
		from	dbo.tb_UserRole	r	with (nolock)
		join	dbo.tb_Access	a	with (nolock)	on	a.idModule	= @idModule		and	a.idRole	= r.idRole
		where	r.idUser	= @idUser
		group	by	a.idFeature
end
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
--	7.06.8790	* pr_User_sStaff_Upd	->	pr_User_UpdStaff
--	7.06.7390	* optimized log (@sValue)
--	7.06.7292	* tb_Option[11]<->[19]
--	7.06.6751	* optimized log (sys.fn_varbintohexstr -> convert(varbinary))
--	7.06.5913	* enhance int-to-hex, AD pass
--	7.06.5886	+ exec dbo.pr_User_sStaff_Upd
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

	select	@k =	o.tiDatatype,	@i =	os.iValue,	@f =	os.fValue,	@t =	os.tValue,	@s =	os.sValue
		from	dbo.tb_OptSys	os	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin
		begin	tran

			update	dbo.tb_OptSys	set	iValue =	@iValue,	fValue =	@fValue,	tValue =	@tValue,	sValue =	@sValue,	dtUpdated=	getdate( )
				where	idOption = @idOption	--	and	idUser = @idUser

			if	@idOption = 16	or	@idOption = 36
				select	@sValue= '************'								-- do not expose SMTP or AD pass

			select	@s =	'[' + isnull(cast(@idOption as varchar), '?') + '] '

				 if	@k = 56		select	@s =	@s + 'i=' + isnull(cast(@iValue as varchar), '?') + ' (' + convert(varchar, convert(varbinary(4), @iValue), 1) + ')'
			else if	@k = 62		select	@s =	@s + 'f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s =	@s + 't=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s =	@s + 's=''' + isnull(@sValue, '?') + ''''

			exec	dbo.pr_Log_Ins	236, @idUser, null, @s

			if	@idOption = 19		exec	dbo.pr_User_UpdStaff			-- staff name format

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Updates and logs user setting
--	7.06.7390	+ added removal when matches tb_OptSys
--	7.06.6751	* optimized log (sys.fn_varbintohexstr -> convert(varbinary))
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

	select	@k =	o.tiDatatype,	@i =	os.iValue,	@f =	os.fValue,	@t =	os.tValue,	@s =	os.sValue
		from	dbo.tb_OptSys	os	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin
		begin	tran
			update	dbo.tb_OptUsr	set	iValue =	@iValue,	fValue =	@fValue,	tValue =	@tValue,	sValue =	@sValue,	dtUpdated=	getdate( )
				where	idUser = @idUser	and	idOption = @idOption
			if	@@rowcount = 0
				insert	dbo.tb_OptUsr	( idOption,  idUser,  iValue,  fValue,  tValue,  sValue)
					values				(@idOption, @idUser, @iValue, @fValue, @tValue, @sValue)

	--		if	@idOption = 16	select	@sValue= '************'		--	do not expose SMTP pass

			select	@s= 'OptUsr_U [' + isnull(cast(@idOption as varchar), '?') + '] '

				 if	@k = 56		select	@s =	@s + 'i=' + isnull(cast(@iValue as varchar), '?') + ' (' + convert(varchar, convert(varbinary(4), @iValue), 1) + ')'
			else if	@k = 62		select	@s =	@s + 'f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s =	@s + 't=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s =	@s + 's=''' + isnull(@sValue, '?') + ''''

			exec	dbo.pr_Log_Ins	231, @idUser, null, @s
		commit
	end
	else
		delete	from	dbo.tb_OptUsr
			where	idUser = @idUser	and	idOption = @idOption
end
go
--	----------------------------------------------------------------------------
--	Updates a staff level
--	7.06.8784	- .iColorB
--				* idStfLvl	-> idLvl, @
--				* cStfLvl	-> cLvl, @
--				* sStfLvl	-> sLvl, @
--	7.06.8504	+ skip tracing internal sync
--	7.06.8139	+ .cStfLvl
--	7.06.7279	* optimized logging
--	7.06.7115	* optimized logging (color in hex)
--	7.05.5219
alter proc		dbo.prStfLvl_Upd
(
	@idLvl		tinyint
,	@cLvl		char( 1 )
,	@sLvl		varchar( 16 )
,	@idUser		int
)
	with encryption, exec as owner
as
begin
	declare		@s	varchar( 255 )

	set	nocount	on

	select	@s =	'StfLvl_U( ' + isnull(cast(@idLvl as varchar), '?') + ', ' + @cLvl + '|''' + @sLvl + ''' )'

	begin	tran

		update	dbo.tbStfLvl	set	cLvl =	@cLvl,	sLvl =	@sLvl
			where	idLvl = @idLvl

		if	ascii(@cLvl) < 0xF0												-- skip internal sync
			exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .sMachine -> .sHost, @
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Sess') and name = 'sMachine')
begin
	begin tran
		exec sp_rename 'tb_Sess.sMachine',	'sHost',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .sMachine -> .sHost, @
--	7.06.5399
alter view		dbo.vw_Sess
	with encryption
as
	select	s.idSess, s.dtCreated, s.sSessID, s.idModule, m.sModule, s.idUser, u.sUser, s.sIpAddr, s.sHost, s.bLocal, s.dtLastAct, s.sBrowser
		from	dbo.tb_Sess		s	with (nolock)
		join	dbo.tb_Module	m	with (nolock)	on	m.idModule	= s.idModule
	left join	dbo.tb_User		u	with (nolock)	on	u.idUser	= s.idUser
go
--	----------------------------------------------------------------------------
--	Returns all sessions in order of creation (ID)
--	7.06.8796	* .sMachine -> .sHost, @
--	7.06.5399
alter proc		dbo.pr_Sess_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idSess, dtCreated, sSessID, idModule, sModule, idUser, sUser, sIpAddr, sHost, bLocal, dtLastAct, sBrowser
		from	dbo.vw_Sess		with (nolock)
		order	by	1 desc
end
go
--	----------------------------------------------------------------------------
--	Inserts a new session
--	7.06.8796	* tb_Sess.sMachine -> .sHost, @
--	7.06.8796	* tb_Module.sMachine -> .sHost, @
--				* .sParams -> .sArgs, @
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
,	@sHost		varchar( 32 )
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
					isnull(cast(@sIpAddr as varchar),'?') +	'|' + isnull(@sHost,'?') + ', l=' +
					isnull(cast(@bLocal as varchar),'?') + ', ''' +
					isnull(cast(@sBrowser as varchar),'?') + ''' ) '

	select	@idSess =	idSess
		from	dbo.tb_Sess		with (nolock)
		where	sSessID = @sSessID	and	idModule = @idModule	and	sIpAddr = @sIpAddr	and	sBrowser = @sBrowser

	begin	tran
---		if	@idSess > 0		return		--	SQL BUG:	return does NOT abort execution immediately as described in docs!!
		if	@idSess is null
		begin
			insert	dbo.tb_Sess	(  sSessID,  idModule,  idUser,  sIpAddr,  sHost,  bLocal,  sBrowser )
					values		( @sSessID, @idModule, @idUser, @sIpAddr, @sHost, @bLocal, @sBrowser )
			select	@idSess =	scope_identity( )

			select	@s =	@s + '+'
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

		exec	dbo.pr_Module_Act	1
		exec	dbo.pr_Module_Act	@idModule

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
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* tb_Sess.sMachine -> .sHost, @
--	7.06.8796	* tb_Module.sMachine -> .sHost, @
--				* .sParams -> .sArgs, @
--	7.06.8783	* .sStaffID -> sStfID, @
--	7.06.7388	+ [.idSess] into log
--	7.06.6543	+ @sStaffID
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.06.5969	* optimized
--	7.05.5227	- @sIpAddr, @sMachine, @sFrst, @sLast
--				+ @sStaff
--	7.05.5044	* @idUser: smallint -> int
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked
--	7.04.4966	* @iHass -> @iHash
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ @idSess, .tiFailed -> .tiFails
--			* optimize desc-string
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			tb_User: * .bEnabled -> .bActive
--	6.05	+ (nolock), transaction
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02	* tb_Log.idType rearranged
--	6.00
alter proc		dbo.pr_User_Login
(
	@idSess		int					-- session-id
,	@sUser		varchar( 32 )		-- login-name, lower-cased
,	@iHash		int					-- calculated password 32-bit hash (Murmur2)

,	@idUser		int				out	-- null if attempt failed
,	@sStaff		varchar( 16 )	out	-- full-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
,	@sStfID		varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@tiLog		tinyint
		,		@idModule	tinyint
		,		@iHass		int
		,		@bActive	bit
		,		@bLocked	bit
		,		@idType		tinyint
		,		@tiFails	tinyint
		,		@tiMaxAtt	tinyint
		,		@sIpAddr	varchar( 40 )
		,		@sHost		varchar( 32 )

	set	nocount	on

	select	@tiMaxAtt=	cast(iValue as tinyint)		from	dbo.tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr =	sIpAddr,	@sHost=	sHost,	@idModule=	idModule
		from	dbo.tb_Sess		with (nolock)
		where	idSess = @idSess

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	select	@s =	'@ ' + isnull( @sHost, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@iHass =	iHash,	@bActive=	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff,		@sStfID =	sStfID
		from	dbo.tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idType, null, null, @s, @idModule
		return	@idType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idType =	224
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule
		return	@idType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idType =	225
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule
		return	@idType
	end

	if	@iHass <> @iHash		--	wrong pass
	begin
		select	@idType =	223,	@s =	@s + ', attempt ' + cast( @tiFails + 1 as varchar )

		begin	tran

			if	@tiFails < @tiMaxAtt - 1
				update	dbo.tb_User		set	tiFails =	tiFails + 1
					where	idUser = @idUser
			else
			begin
				update	dbo.tb_User		set	tiFails =	0xFF
					where	idUser = @idUser
				select	@s =	@s + ', locked-out'
			end
			exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule

		commit
		return	@idType
	end

	select	@idType =	221,	@s =	@s + ' [' + cast( @idSess as varchar ) + ']',	@bAdmin =	0

	if	exists(	select 1 from dbo.tb_UserRole where idUser = @idUser and idRole = 2 )
		select	@bAdmin =	1,	@s =	@s + ' !'

	begin	tran

		update	dbo.tb_Sess		set	dtLastAct=	getdate( ),		idUser =	@idUser
			where	idSess = @idSess
		update	dbo.tb_User		set	dtLastAct=	getdate( ),		tiFails =	0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule

	commit
	return	@idType
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* tb_Sess.sMachine -> .sHost, @
--	7.06.8796	* tb_Module.sMachine -> .sHost, @
--				* .sParams -> .sArgs, @
--	7.06.8783	* .sStaffID -> sStfID, @
--	7.06.7388	+ [.idSess] into log
--	7.06.6543	+ @sStaffID
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.06.5969
alter proc		dbo.pr_User_Login2
(
	@idSess		int					-- session-id
,	@gGUID		uniqueidentifier	-- AD GUID
--,	@iHash		int					-- calculated password 32-bit hash (Murmur2)

,	@sUser		varchar( 32 )	out	-- login-name, lower-cased
,	@idUser		int				out	-- null if attempt failed
,	@sStaff		varchar( 16 )	out	-- full-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
,	@sStfID		varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@tiLog		tinyint
		,		@idModule	tinyint
--		,		@iHass		int
		,		@bActive	bit
		,		@bLocked	bit
		,		@idType		tinyint
		,		@tiFails	tinyint
		,		@tiMaxAtt	tinyint
		,		@sIpAddr	varchar( 40 )
		,		@sHost		varchar( 32 )

	set	nocount	on

	select	@tiMaxAtt=	cast(iValue as tinyint)		from	dbo.tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr =	sIpAddr,	@sHost=	sHost,	@idModule=	idModule
		from	dbo.tb_Sess		with (nolock)
		where	idSess = @idSess

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	select	@s =	'@ ' + isnull( @sHost, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@sUser =	sUser,	@bActive=	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff,		@sStfID =	sStfID
		from	dbo.tb_User		with (nolock)
		where	gGUID = @gGUID												--	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idType, null, null, @s, @idModule
		return	@idType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idType =	224
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule
		return	@idType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idType =	225
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule
		return	@idType
	end

--	if	@iHass <> @iHash		--	wrong pass
--	..

	select	@idType =	221,	@s =	@s + ' [' + cast( @idSess as varchar ) + ']',	@bAdmin =	0

	if	exists	(select 1 from dbo.tb_UserRole where idUser = @idUser and idRole = 2)
		select	@bAdmin =	1,	@s =	@s + ' !'

	begin	tran

		update	dbo.tb_Sess		set	dtLastAct=	getdate( ),		idUser =	@idUser
			where	idSess = @idSess
		update	dbo.tb_User		set	dtLastAct=	getdate( ),		tiFails =	0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule

	commit
	return	@idType
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* tb_Sess.sMachine -> .sHost, @
--	7.06.8796	* tb_Module.sMachine -> .sHost, @
--				* .sParams -> .sArgs, @
--	7.06.8719	* ?d -> 00?d
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
,	@idType		tinyint
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@tiLog		tinyint
		,		@idModule	tinyint
		,		@idUser		int
		,		@sIpAddr	varchar( 40 )
		,		@sHost		varchar( 32 )
		,		@dtCreated	datetime

	set	nocount	on

	select	@idUser =	idUser,		@sIpAddr =	sIpAddr,	@sHost=	sHost,	@idModule=	idModule,	@dtCreated =	dtCreated
		from	dbo.tb_Sess
		where	idSess = @idSess

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	if	@idUser > 0
	begin
		begin	tran

			update	dbo.tb_Sess		set	dtLastAct=	getdate( ),	idUser =	null
				where	idSess = @idSess

			select	@s =	'@ ' + isnull(@sHost, '?') + ' (' + isnull(@sIpAddr, '?') + ') [' + cast(@idSess as varchar) + '] ' + isnull(convert(varchar, @dtCreated, 120), '?') +
							' | ' + isnull(right('00' + cast(datediff(ss, @dtCreated, getdate())/86400 as varchar), 3), '?') + 'd ' + isnull(convert(varchar, getdate() - @dtCreated, 108), '?')

			exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Returns all|active beds
--	7.06.5409	+ .siBed
--	7.05.4976	+ @bActive
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
alter proc		dbo.prCfgBed_GetAll
(
	@bActive	bit					--	0=any, 1=only active
)
	with encryption
as
begin
--	set	nocount	on
	select	tiBed, cBed, cDial, siBed, bActive, dtCreated, dtUpdated
		from	dbo.tbCfgBed	with (nolock)
		where	@bActive = 0	or	bActive > 0
end
go
--	----------------------------------------------------------------------------
--	Clears all filter definitions
--	7.06.7279	* optimized logging
--	7.06.5914	* optimized
--	7.04.4898	* prCfgFlt_DelAll -> prCfgFlt_Clr
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgFlt_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	dbo.tbCfgFlt
		select	@s =	'Flt_C( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a filter definition
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	7.06.5914	* optimized
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgFlt_Ins
(
	@idIdx		tinyint				-- filter idx
,	@iFilter	int					-- filter bits
,	@sFilter	varchar( 16 )		-- filter name
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Flt_I( ' + isnull(cast(@idIdx as varchar), '?') + ', ' + convert(varchar, convert(varbinary(4), @iFilter), 1) +
					', ''' + isnull(@sFilter, '?') + ''')'	-- + isnull(cast(@iFilter as varchar), '?')

	begin	tran

		insert	dbo.tbCfgFlt	(  idIdx,  iFilter,  sFilter )
				values			( @idIdx, @iFilter, @sFilter )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all filter definitions
--	7.03
alter proc		dbo.prCfgFlt_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idIdx, iFilter, sFilter
		from	dbo.tbCfgFlt	with (nolock)
end
go
--	----------------------------------------------------------------------------
--	Returns tones, ordered to be loadable into a table
--	7.06.6177	* .dtCreated -> .dtUpdated
--	7.06.5694	+ .dtCreated, .tLen
--	7.06.5687
alter proc		dbo.prCfgTone_GetAll
(
	@bVisible	bit					--	0=exclude, 1=include - uLaw (.vbTone) is huge binary
)
	with encryption
as
begin
--	set	nocount	on
	if	@bVisible > 0
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtUpdated,	vbTone
			from	dbo.tbCfgTone	with (nolock)
			order	by	1
	else
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtUpdated
			from	dbo.tbCfgTone	with (nolock)
			order	by	1
end
go
--	----------------------------------------------------------------------------
--	Inserts a tone definition
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	7.06.5914	* optimized
--	7.06.5687
alter proc		dbo.prCfgTone_Ins
(
	@tiTone		smallint			-- tone idx
,	@sTone		varchar( 16 )		-- tone name
,	@vbTone		varbinary(max)		-- audio (uLaw-encoded)
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Tone_I( ' + isnull(cast(@tiTone as varchar), '?') + ', ''' + isnull(@sTone, '?') + ''' )'

	begin	tran

		insert	dbo.tbCfgTone	(  tiTone,  sTone,  vbTone )
				values			( @tiTone, @sTone, @vbTone )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns Dome Light Show definitions, ordered to be loadable into a table
--	7.06.8272	* output order
--	7.06.6184	+ .tiPrism, sPrism
--	7.06.6177
alter proc		dbo.prCfgDome_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	tiDome,	tiPrism
		,	case when	tiPrism & 8 > 0	then	'T'	else '  '	end +
			case when	tiPrism & 4 > 0	then	'U'	else '  '	end +
			case when	tiPrism & 2 > 0	then	'L'	else '  '	end +
			case when	tiPrism & 1 > 0	then	'B'	else '  '	end		as	sPrism
		,	iLight0, iLight1, iLight2,	iPrism0, iPrism1, iPrism2, iPrism3, iPrism4, iPrism5
		,	cast(1 as bit)	as	bActive,	dtUpdated
		from	dbo.tbCfgDome	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Inserts a Dome Light Show definition
--	7.06.7279	* optimized logging
--	7.06.6751	* optimized log (sys.fn_varbintohexstr -> convert(varbinary))
--	7.06.6186	* .tiPrism value ('<> 0' for highest bit - SQL doesn't have unsigned integers)
--	7.06.6185	* .tiPrism value
--	7.06.6184	+ .tiPrism, sPrism
--	7.06.6177
alter proc		dbo.prCfgDome_Upd
(
	@tiDome		smallint			-- dome light show idx

,	@iLight0	int					-- bytes 0-3
,	@iLight1	int					-- bytes 4-7
,	@iLight2	int					-- bytes 8-11

,	@iPrism0	int					-- bytes 0-3
,	@iPrism1	int					-- bytes 4-7
,	@iPrism2	int					-- bytes 8-11
,	@iPrism3	int					-- bytes 12-16
,	@iPrism4	int					-- bytes 17-20
,	@iPrism5	int					-- bytes 21-23
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@iPrism		int

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Dome_U( ' + isnull(cast(@tiDome as varchar), '?') + ', ' + convert(varchar, convert(varbinary(4), @iLight0), 1) + ' ' +
					convert(varchar, convert(varbinary(4), @iLight1), 1) + ' ' + convert(varchar, convert(varbinary(4), @iLight2), 1) + ', ' +
					convert(varchar, convert(varbinary(4), @iPrism0), 1) + ' ' + convert(varchar, convert(varbinary(4), @iPrism1), 1) + ' ' +
					convert(varchar, convert(varbinary(4), @iPrism2), 1) + ' ' + convert(varchar, convert(varbinary(4), @iPrism3), 1) + ' ' +
					convert(varchar, convert(varbinary(4), @iPrism4), 1) + ' ' + convert(varchar, convert(varbinary(4), @iPrism5), 1) + ' )'
		,	@iPrism =	@iPrism0 | @iPrism1 | @iPrism2 | @iPrism3 | @iPrism4 | @iPrism5

	begin	tran

		update	dbo.tbCfgDome
			set		iLight0 =	@iLight0,	iLight1 =	@iLight1,	iLight2 =	@iLight2
				,	iPrism0 =	@iPrism0,	iPrism1 =	@iPrism1,	iPrism2 =	@iPrism2
				,	iPrism3 =	@iPrism3,	iPrism4 =	@iPrism4,	iPrism5 =	@iPrism5
				,	tiPrism =	case when	@iPrism & 0xF000F000 <> 0	then	2	else	0	end	+
								case when	@iPrism & 0x0F000F00 > 0	then	1	else	0	end	+
								case when	@iPrism & 0x00F000F0 > 0	then	8	else	0	end	+
								case when	@iPrism & 0x000F000F > 0	then	4	else	0	end
			where	tiDome = @tiDome

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

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
)
	with encryption
as
begin
--	set	nocount	on
	select	siIdx, sCall, siFlags, tiShelf, tiColor, tiSpec, iFilter
		,	siIdxUg, siIdxOt, tiIntOt, tiDome, tiTone, tiIntTn
		,	dtUpdated,	cast(siFlags & 0x0002 as bit)	as	bActive
		from	dbo.tbCfgPri	with (nolock)
		where	@siFlags is null	or	siFlags & @siFlags = @siFlags
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
			update	dbo.tbCfgPri
				set	sCall =		@sCall,		siFlags =	@siFlags,	tiShelf =	@tiShelf
				,	tiColor =	@tiColor,	iFilter =	@iFilter,	tiSpec =	@tiSpec,	siIdxUg =	@siIdxUg
				,	siIdxOt =	@siIdxOt,	tiIntOt =	@tiIntOt,	tiDome =	@tiDome,	tiTone =	@tiTone
				,	tiIntTn =	@tiIntTn,	dtUpdated=	getdate( )
				where	siIdx = @siIdx
		else
			insert	dbo.tbCfgPri	(  siIdx,  sCall,  siFlags,  tiShelf,  tiColor,  iFilter,  tiSpec,  siIdxUg,  siIdxOt,  tiIntOt,  tiDome,  tiTone,  tiIntTn )
					values			( @siIdx, @sCall, @siFlags, @tiShelf, @tiColor, @iFilter, @tiSpec, @siIdxUg, @siIdxOt, @tiIntOt, @tiDome, @tiTone, @tiIntTn )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Clears all tone definitions
--	7.06.7279	* optimized logging
--	7.06.5914	* optimized
--	7.06.5702	+ reset tbCfgPri.tiTone
--	7.06.5687
alter proc		dbo.prCfgTone_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		update	dbo.tbCfgPri	set	tiTone =	null						-- clear FKs

		delete	from	dbo.tbCfgTone
		select	@s =	'Tone_C( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Fills #tbCall with enabled priorities' siIdx-s, given in a string ('*' or '1,2,3,..')
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
--				* [0] 'NO CALL' -> '<NO CALL>'
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
		siIdx		smallint		not null	primary key clustered
	)
*/
	if	@sCalls = ''	or	@sCalls is null
		return	0

	if	@sCalls = '*'
	begin
		insert	#tbCall
			select	siIdx
				from	dbo.tbCfgPri	with (nolock)
				where	siFlags & 0x0002 > 0		--	enabled only
	end
	else
	begin
		select	@s=
		'insert	#tbCall
			select	siIdx
				from	dbo.tbCfgPri	with (nolock)
				where	siFlags & 0x0002 > 0
				and		siIdx in (' + @sCalls + ')'
		exec( @s )
	end
--	select	*	from	#tbCall
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--				* xuCall_siIdx_Act -> xuCall_Act_siIdx
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCall') and name = 'tVoTrg')
begin
	begin tran
		if	exists	(select 1 from dbo.sysindexes where name='xuCall_siIdx_Act')
			drop index	tbCall.xuCall_siIdx_Act

		exec sp_rename 'tbCall.tVoTrg',	'tVoice',	'column'
		exec sp_rename 'tbCall.tStTrg',	'tStaff',	'column'
/*	commit
end
g o
if	not exists	(select 1 from dbo.sysindexes where name='xuCall_Act_siIdx')
begin
	begin tran
*/		create unique nonclustered index	xuCall_Act_siIdx	on	dbo.tbCall ( siIdx )	where	bActive > 0		--	7.06.6508
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
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
	@bVisible	bit					-- 0=order by siIdx, 1=order by idCall
,	@bEnabled	bit			= null	-- null=any, 0=disabled, 1=enabled for reporting
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@siFlags	smallint	= null	-- null=any
)
	with encryption
as
begin
--	set	nocount	on
	if	@bVisible is null
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoice, c.tStaff, c.bActive, c.dtCreated, c.dtUpdated
			,	p.siFlags, p.tiShelf, p.tiSpec, p.tiColor
			from	dbo.tbCall		c	with (nolock)
			join	dbo.tbCfgPri	p	with (nolock)	on p.siIdx	= c.siIdx
			where	(@bEnabled is null	or	c.bEnabled	= @bEnabled)
			and		(@bActive is null	or	c.bActive	= @bActive)
			and		(@siFlags is null	or	siFlags & @siFlags > 0)
			order	by	c.siIdx	desc,	c.idCall	desc					-- 7.06.7104
	else
	if	@bVisible > 0
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoice, c.tStaff, c.bActive, c.dtCreated, c.dtUpdated
			,	p.siFlags, p.tiShelf, p.tiSpec, p.tiColor
			from	dbo.tbCall		c	with (nolock)
			join	dbo.tbCfgPri	p	with (nolock)	on p.siIdx	= c.siIdx
			where	(@bEnabled is null	or	c.bEnabled	= @bEnabled)
			and		(@bActive is null	or	c.bActive	= @bActive)
			and		(@siFlags is null	or	siFlags & @siFlags = @siFlags)
			order	by	c.idCall
	else
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoice, c.tStaff, c.bActive, c.dtCreated, c.dtUpdated
			,	p.siFlags, p.tiShelf, p.tiSpec, p.tiColor
			from	dbo.tbCall		c	with (nolock)
			join	dbo.tbCfgPri	p	with (nolock)	on p.siIdx	= c.siIdx	--	p.sCall = c.sCall	and
			where	(@bEnabled is null	or	c.bEnabled	= @bEnabled)
			and		(@bActive is null	or	c.bActive	= @bActive)
			and		(@siFlags is null	or	siFlags & @siFlags = @siFlags)
			order	by	c.siIdx	desc,	c.idCall	desc					-- 7.06.7104
end
go
--	----------------------------------------------------------------------------
--	Updates target times for a given call-priority
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.06.7279	* optimized logging
--	7.06.7117	+ @idModule
--	7.05.5044	* @idUser: smallint -> int
--	7.04.4902
alter proc		dbo.prCall_Upd
(
	@idCall		smallint
,	@bEnabled	bit
,	@tVoice		time( 0 )
,	@tStaff		time( 0 )
,	@idUser		int
,	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	begin	tran

		update	dbo.tbCall	set	bEnabled =	@bEnabled,	tVoice =	@tVoice,	tStaff =	@tStaff,	dtUpdated=	getdate( )
			where	idCall = @idCall

		select	@s =	'Call_U( ' + isnull(cast(@idCall as varchar), '?') + ', e=' + isnull(cast(@bEnabled as varchar), '?') +
						', v=' + convert(varchar, @tVoice, 108) + ', s=' + convert(varchar, @tStaff, 108) + ' )'
		exec	dbo.pr_Log_Ins	72, @idUser, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
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
,	@idCall		smallint		out	-- output
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@tVoice		time( 0 )
		,		@tStaff		time( 0 )

	set	nocount	on

	select	@siIdx =	@siIdx & 0x03FF		-- mask significant bits only [0..1023]
		,	@idCall =	null				-- not in tbCall

	select	@tVoice =	cast(tValue as time( 0 ))	from	dbo.tb_OptSys	with (nolock)	where	idOption = 29
	select	@tStaff =	cast(tValue as time( 0 ))	from	dbo.tb_OptSys	with (nolock)	where	idOption = 30

	select	@s =	'Call_GI( ' + isnull(cast(@siIdx as varchar), '?') + '|' + isnull(@sCall, '?') + ' )'

	if	@siIdx > 0
	begin
		-- match by priority-index
		select	@idCall =	idCall	from	dbo.tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0

		if	@idCall is null
		begin
			begin	tran

				if	@sCall is null	or	len( @sCall ) = 0
					select	@sCall =	sCall	from	dbo.tbCfgPri	with (nolock)	where	siIdx = @siIdx

				insert	dbo.tbCall	(  siIdx,  sCall,  tVoice,  tStaff, bEnabled )
						values		( @siIdx, @sCall, @tVoice, @tStaff, 1 )
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
--	7.06.8791	* .idParent -> .idPrnt
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgLoc') and name = 'idParent')
begin
	begin tran
		exec sp_rename 'tbCfgLoc.idParent',	'idPrnt',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Coverage areas and their units
--	7.06.8791	* .idParent -> .idPrnt
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.03	* vwDefLoc_CaUnit -> vwDefLoc_Cvrg, .idCArea -> .idCvrg, .sCArea -> .sCvrg
--	7.00
alter view		dbo.vwCfgLoc_Cvrg
	with encryption
as
select	a.idLoc	as	idCvrg,	a.sLoc	as	sCvrg,	u.idLoc	as	idUnit,	u.sLoc	as	sUnit
	from	dbo.tbCfgLoc	a	with (nolock)
	join	dbo.tbCfgLoc	u	with (nolock)	on	u.idLoc		= a.idPrnt	and	u.tiLvl = 4		-- unit
	where	a.tiLvl = 5														-- coverage area
go
--	----------------------------------------------------------------------------
--	Returns all locations, ordered to be loadable into a tree
--	7.06.8791	* tbCfgLoc.idParent -> .idPrnt
--	7.06.5914	* .dtCreated -> .dtUpdated
--	7.06.5504	+ .sPath
--	7.04.4892	* tbDefLoc -> tbCfgLoc
alter proc		dbo.prCfgLoc_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLoc, idPrnt, cLoc, sLoc, tiLvl, sPath
		,	case when tiLvl = 0	then 'Facility'
				when tiLvl = 1	then 'System'
				when tiLvl = 2	then 'Building'
				when tiLvl = 3	then 'Floor'
				when tiLvl = 4	then 'Unit'
				when tiLvl = 5	then 'Cvrg Area'
								else '??'	end	as	sLvl,	cast(1 as bit)	as	bActive,	dtUpdated
		from	dbo.tbCfgLoc	with (nolock)
		order	by	6	--	sPath
end
go
--	----------------------------------------------------------------------------
--	Clears all location definitions
--	7.06.7279	* optimized logging
--	7.06.5914	* optimized
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	6.05
alter proc		dbo.prCfgLoc_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	dbo.tbCfgLoc
		select	@s =	'Loc_C( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
--	7.06.8791	* tbCfgLoc.idParent -> .idPrnt, @
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
,	@idPrnt		smallint			-- parent look-up FK
,	@tiLvl		tinyint				-- level: 0=Facility 1=System 2=Building 3=Floor 4=Unit 5=CvrgArea
,	@cLoc		char( 1 )			-- type:  H=Hospital S=System B=Building F=Floor U=Unit A=CvrgArea
,	@sLoc		varchar( 16 )		-- location name
,	@sPath		varchar( 32 )		-- node path ([idPrnt.]idLoc) - for tree-ordered reads
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', p=' +
					isnull(right('00' + cast(@idPrnt as varchar), 3), '?') + ', ' +
					isnull(cast(@tiLvl as varchar), '?') + '|' + isnull(@cLoc, '?') + '|''' + isnull(@sLoc, '?') + ''', ' + isnull(@sPath, '?') + ''' )'

	begin	tran

		insert	dbo.tbCfgLoc	(  idLoc,  idPrnt,  tiLvl,  cLoc,  sLoc,  sPath )
				values			( @idLoc, @idPrnt, @tiLvl, @cLoc, @sLoc, @sPath )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Fills #tbUnit with given idUnit-s
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.5380	+ "or	@sUnits = ''"
--	7.05.5179	'*'=all, null=none
--	7.05.5154
alter proc		dbo.prUnit_SetTmpFlt
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit-s, '*'=all or null
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)
*/
	if	@sUnits = ''	or	@sUnits is null
		return	0

	if	@sUnits = '*'
	begin
		insert	#tbUnit
			select	idUnit	--, sUnit, idShift
				from	dbo.tbUnit	with (nolock)
				where	bActive > 0	and	idShift > 0
	end
	else
	begin
		select	@s=
		'insert	#tbUnit
			select	idUnit
				from	dbo.tbUnit	with (nolock)
				where	bActive > 0	and	idShift > 0
				and		idUnit in (' + @sUnits + ')'
		exec( @s )
	end
--	select	*	from	#tbUnit
end
go
--	----------------------------------------------------------------------------
--	Exports all role-unit combinations
--	7.06.6816	* order by 1
--	7.06.5385
alter proc		dbo.pr_RoleUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idRole, idUnit, dtCreated
		from	dbo.tb_RoleUnit		with (nolock)
--		order	by	1, 2
end
go
--	----------------------------------------------------------------------------
--	Imports a role-unit combination
--	7.06.5385
alter proc		dbo.pr_RoleUnit_Imp
(
	@idRole		smallint			--	0=clear table
,	@idUnit		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idRole > 0
		begin
			if	not	exists	(select 1 from dbo.tb_RoleUnit with (nolock) where idRole = @idRole and idUnit = @idUnit)
			begin
				insert	dbo.tb_RoleUnit	(  idRole,  idUnit,  dtCreated )
						values			( @idRole, @idUnit, @dtCreated )
			end
		end
		else
			delete	from	dbo.tb_RoleUnit

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns details for all roles
--	7.06.8684	+ @sRole
--	7.06.6795	+ @idUnit
--	7.05.5234
alter proc		dbo.pr_Role_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUnit		smallint	= null	-- null=any
,	@sRole		varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
--	set	nocount	on
	select	idRole, sRole, sDesc, bActive, dtCreated, dtUpdated
		from	dbo.tb_Role		with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
	--	and		idRole > 15													--	protect internal accounts
		and		(@idUnit is null	or	idRole	in	(select idRole from dbo.tb_RoleUnit with (nolock) where idUnit = @idUnit))
		and		(@sRole is null		or	sRole like @sRole)					--	7.06.8684
end
go
--	----------------------------------------------------------------------------
--	Returns units for a given user, ordered by name
--	7.06.6817	+ order by 2
--	7.06.6807
alter proc		dbo.pr_User_GetUnits
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	dbo.tb_UserUnit	m	with (nolock)
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= m.idUnit
		where	idUser	= @idUser
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Returns details for specified users
--	7.06.8789	* tb_User.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl, @
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID -> sStfID, @
--	7.06.8686	* @sStaffID:	vc16 -> vc18, now filters sUser, sStaff, sStfID
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
	@idLvl		tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bDuty		bit			= null	-- null=any, 0=off, 1=on
,	@idUser		int			= null	-- null=any
,	@idUnit		smallint	= null	-- null=any
,	@sStfID		varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStfID, idLvl, sCode, bDuty, dtDue, sStaff,	gGUID, utSynched,	bActive, dtCreated, dtUpdated
		,	cast(case when	tiFails = 0xFF	then 1	else 0	end	as	bit)	as	bLocked
		,	cast(case when	gGUID is null	then 0	else 1	end	as	bit)	as	bGUID
		from	dbo.tb_User		with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
		and		(@idLvl is null		or	idLvl	= @idLvl	or	@idLvl = 0	and	idLvl is null)
		and		(@bDuty is null		or	bDuty	= @bDuty)
		and		(@idUser is null	or	idUser	= @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
		and		(@sStfID is null	or	sUser like @sStfID	or	sStaff like @sStfID		or	sStfID like @sStfID)
		and		(@idUnit is null	or	idUser  in  (select idUser from dbo.tb_UserUnit with (nolock) where idUnit = @idUnit))
end
go
--	----------------------------------------------------------------------------
--	Returns details for specified user
--	7.06.8789	* tb_User.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.7212
alter proc		dbo.pr_User_GetOne
(
	@gGUID		uniqueidentifier= null	-- null=any
,	@idUser		int			= null	-- null=any
)
	with encryption
as
begin
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStfID, idLvl, sCode, bDuty, dtDue, sStaff,	gGUID, utSynched,	bActive, dtCreated, dtUpdated
		,	cast(case when	tiFails = 0xFF	then 1	else 0	end	as	bit)	as	bLocked
		,	cast(case when	gGUID is null	then 0	else 1	end	as	bit)	as	bGUID
		from	tb_User		with (nolock)
		where	(@gGUID is null		or	gGUID	= @gGUID)
		and		(@idUser is null	or	idUser	= @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
end
go
--	----------------------------------------------------------------------------
--	Returns units for a given role
--	7.06.6817	+ order by 2
--	7.06.6807	+ .sUnit
--	7.05.5234
alter proc		dbo.pr_Role_GetUnits
(
	@idRole		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	dbo.tb_RoleUnit	m	with (nolock)
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit = m.idUnit
		where	idRole = @idRole
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8783	* #PK nonclustered -> clustered
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
		,		@idType		tinyint

	set	nocount	on

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered		--	7.06.8783
--	,	sUnit		varchar( 16 )	not null
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	select	@s =	isnull(cast(@idRole as varchar), '?') + '|' + @sRole + ', ''' + isnull(cast(@sDesc as varchar), '?') +
					''' a=' + cast(@bActive as varchar) + ' u=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_Role where idRole = @idRole)
		begin
			insert	dbo.tb_Role	(  sRole,  sDesc,  bActive )
					values		( @sRole, @sDesc, @bActive )
			select	@idRole =	scope_identity( )

			select	@idType =	242,	@s =	'Role_I( ' + @s + ' )=' + cast(@idRole as varchar)
		end
		else
		begin
			update	dbo.tb_Role		set	sRole=	@sRole,		sDesc=	@sDesc,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idRole = @idRole

			select	@idType =	243,	@s =	'Role_U( ' + @s + ' )'
		end

		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule

		delete	from	dbo.tb_RoleUnit
			where	idRole = @idRole
			and		idUnit  not in  (select idUnit from #tbUnit with (nolock))

		insert	dbo.tb_RoleUnit	( idUnit, idRole )
			select	idUnit, @idRole
				from	#tbUnit		with (nolock)
				where	idUnit  not in  (select idUnit from dbo.tb_RoleUnit where idRole = @idRole)

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns locations down to unit-level, accessible by a given user; ordered to be loadable into a tree
--	7.06.8791	* .idParent -> .idPrnt
--	7.06.5414	* optimize for @idUser=null
--	7.06.5385	* fix: accessibility via user's roles
--	7.05.5043
alter proc		dbo.prCfgLoc_GetByUser
(
	@idUser		int			= null	-- null=any
)
	with encryption
as
begin
--	set	nocount	on
	select	idLoc, idPrnt, cLoc, sLoc, tiLvl
		from	dbo.tbCfgLoc	with (nolock)
			where	tiLvl < 4					-- anything above unit-level
			or		tiLvl = 4	and	(@idUser is null	or	idLoc  in  (select	idUnit
						from	dbo.tb_RoleUnit	ru	with (nolock)
						join	dbo.tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order	by	tiLvl, idLoc
end
go
--	----------------------------------------------------------------------------
--	Exports all teams
--	7.06.7368	+ .bEmail
--	7.06.6817
alter proc		dbo.prTeam_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, bEmail, sDesc, bActive, dtCreated, dtUpdated
		from	dbo.tbTeam	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a team
--	7.06.7368	+ .bEmail
--	7.06.6817
alter proc		dbo.prTeam_Imp
(
	@idTeam		smallint
,	@sTeam		varchar( 16 )
,	@tResp		time( 0 )
,	@bEmail		bit
,	@sDesc		varchar( 255 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not	exists	(select 1 from dbo.tbTeam with (nolock) where idTeam = @idTeam)
		begin
			set identity_insert	dbo.tbTeam	on

			insert	dbo.tbTeam	(  idTeam,  sTeam,  tResp,  bEmail,  sDesc,  bActive,  dtCreated,  dtUpdated )
					values		( @idTeam, @sTeam, @tResp, @bEmail, @sDesc, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbTeam	off
		end
		else
			update	dbo.tbTeam
				set	sTeam=	@sTeam,		tResp=	@tResp,		bEmail =	@bEmail,	sDesc=	@sDesc,	bActive =	@bActive,	dtUpdated=	@dtUpdated
				where	idTeam = @idTeam

	commit
end
go
--	----------------------------------------------------------------------------
--	Fills  #tbTeam with given idTeam-s
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.5380	+ "or	@sTeams = ''"
--	7.05.5184
alter proc		dbo.prTeam_SetTmpFlt
(
	@sTeams		varchar( 255 )		-- comma-separated idTeam-s, '*'=all or null
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbTeam						-- no enforcement of FKs
	(
		idTeam		smallint		not null	primary key clustered
--	,	sTeam		varchar( 16 )	not null
	)
*/
	if	@sTeams = ''	or	@sTeams is null
		return	0

	if	@sTeams = '*'
	begin
		insert	#tbTeam
			select	idTeam	--, sTeam
				from	dbo.tbTeam	with (nolock)
				where	bActive > 0		--	enabled only
	end
	else
	begin
		select	@s=
		'insert	#tbTeam
			select	idTeam
				from	dbo.tbTeam	with (nolock)
				where	bActive > 0
				and		idTeam in (' + @sTeams + ')'
		exec( @s )
	end
--	select	*	from	#tbCall
end
go
--	----------------------------------------------------------------------------
--	Returns calls for a given team
--	7.06.6814	* tbTeamPri -> tbTeamCall
--	7.06.6807
alter proc		dbo.prTeam_GetCalls
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.siIdx, c.sCall
		from	dbo.tbTeamCall	m	with (nolock)
		join	dbo.tbCfgPri	c	with (nolock)	on	c.siIdx		= m.siIdx
		where	idTeam = @idTeam
		order	by	1	desc
end
go
--	----------------------------------------------------------------------------
--	Imports enabled call-texts from tbCfgPri
--	7.06.8861	+ mark Clinic (0100) available for reporting in addition to Failure (2000) or Presence (1000)
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
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
		,		@tVoOpt		time( 0 )
		,		@tStOpt		time( 0 )
		,		@tVoice		time( 0 )
		,		@tStaff		time( 0 )
		,		@iAdded		smallint
		,		@iRemed		smallint
		,		@siFlags	smallint
		,		@siIdxOt	smallint

	declare		cur		cursor fast_forward for
		select	siIdx, sCall, siFlags
			from	dbo.tbCfgPri	with (nolock)
			where	siIdx > 0	and	siFlags & 0x0002 > 0		-- enabled
			order	by	1

	set	nocount	on

	select	@iAdded =	0,	@iRemed =	0,	@dtNow =	getdate( )

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tVoOpt =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
	select	@tStOpt =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall, @siFlags
		while	@@fetch_status = 0
		begin
			select	@idCall =	-1
			select	@idCall =	idCall,		@pCall =	sCall	from	dbo.tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0
	--		print	cast(@siIdx as varchar) + ': ' + @sCall + ' -> ' + cast(@idCall as varchar)

			if	@idCall > 0	and	@sCall <> @pCall							-- found active previous with different name
			begin
				update	dbo.tbCall	set	dtUpdated=	getdate( ),	bActive =	0		-- deactivate previous
					where	idCall = @idCall

				select	@iRemed =	@iRemed + 1,	@idCall =	-1			-- prepare to insert a new one
			end

			if	@idCall < 0													-- not found - insert a new one
			begin
--	-			select	@tVoice =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
--	-			select	@tStaff =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	--			print	'  insert new'
				insert	dbo.tbCall	(  siIdx,  sCall,  tVoice,  tStaff )
						values		( @siIdx, @sCall, @tVoOpt, @tStOpt )
				select	@idCall =	scope_identity( )

				select	@iAdded =	@iAdded + 1
			end
	--	-	else

			if	@siFlags & 0x0800 > 0										-- Rounding/Reminder - Initial
			begin
				select	@tVoice =	'0:0:0',	@tStaff =	'0:0:0'

				select	@tVoice =	dateadd( mi, isnull(tiIntOt, 0), @tVoice ),		@siIdxOt =	siIdxOt
					from	dbo.tbCfgPri	with (nolock)
					where	siIdx = @siIdx									--	OT1

				select	@tVoice =	dateadd( mi, isnull(tiIntOt, 0), @tVoice ),		@siIdxOt =	siIdxOt
					from	dbo.tbCfgPri	with (nolock)
					where	siIdx = @siIdxOt								--	OT2

				select	@tStaff =	dateadd( mi, isnull(tiIntOt, 0), @tVoice )
					from	dbo.tbCfgPri	with (nolock)
					where	siIdx = @siIdxOt								--	OT

				update	dbo.tbCall	set	dtUpdated=	@dtNow,	bEnabled =	1,	tVoice =	@tVoice,	tStaff =	@tStaff
					where	idCall = @idCall
			end
			else
			if	@siFlags & 0x3100 > 0										-- Special:	Failure (2000) or Presence (1000) or Clinic (0100)
				update	dbo.tbCall	set	dtUpdated=	@dtNow,	bEnabled =	1
					where	idCall = @idCall
					and		bEnabled = 0									-- only update disabled ones

			fetch next from	cur	into	@siIdx, @sCall, @siFlags
		end
		close	cur
		deallocate	cur

		update	c	set	c.bActive =	0,	dtUpdated=	@dtNow
			from	dbo.tbCall	c
			join	dbo.tbCfgPri	p	on	p.siIdx = c.siIdx	and	p.siFlags & 0x0002 = 0	-- disabled
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
--	Returns units for a given team
--	7.06.6817	+ order by 2
--	7.06.6807
alter proc		dbo.prTeam_GetUnits
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	dbo.tbTeamUnit	m	with (nolock)
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit = m.idUnit
		where	idTeam = @idTeam
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Returns teams filtered by unit (and active status)
--	7.06.8684	+ @sTeam
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--	7.05.5191	* by unit
--	7.05.5179	+ .sUnits, .sCalls
--	7.05.5175
alter proc		dbo.prTeam_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
,	@sTeam		varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, bEmail, sDesc, bActive, dtCreated, dtUpdated
		from	dbo.tbTeam	with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
		and		(@idUnit is null	or	idTeam  in  (select idTeam from dbo.tbTeamUnit with (nolock) where idUnit = @idUnit))
		and		(@sTeam is null		or	sTeam like @sTeam)					--	7.06.8684
--		order	by	sTeam
end
go
--	----------------------------------------------------------------------------
--	Returns active teams responding to a given priority in a given unit
--	7.06.8448	* prTeam_GetByUnitPri -> prTeam_GetByCall
--	7.06.7422	* @idUnit may be null now
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--				* tbTeamPri -> tbTeamCall
--	7.06.5347
alter proc		dbo.prTeam_GetByCall
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
		join	dbo.tbTeamCall	m	with (nolock)	on	m.idTeam	= t.idTeam	and	m.siIdx		= @siIdx
		where	bActive > 0
		and		(@idUnit is null	or	t.idTeam  in  (select idTeam from dbo.tbTeamUnit with (nolock) where idUnit = @idUnit))
/*	select	t.idTeam, sTeam, tResp, bEmail, sDesc, bActive, t.dtCreated, dtUpdated
		from	dbo.tbTeam		t	with (nolock)
		join	dbo.tbTeamCall	tc	with (nolock)	on	tc.idTeam	= t.idTeam	and	tc.siIdx	= @siIdx
		join	dbo.tbTeamUnit	tu	with (nolock)	on	tu.idTeam	= t.idTeam	and	tu.idUnit	= @idUnit	or	@idUnit is null
		where	bActive > 0
*/	--	order	by	idTeam
end
go
--	----------------------------------------------------------------------------
--	Ensures predefined accounts have assignability to all active units
--	7.06.7432	* fix tbTeamUnit population for idTeam=1
--	7.06.7377	+ tbTeamUnit population for idTeam=1
--	7.06.6814	* pr_UserUnit_Set -> pr_AccUnit_Set
--				- tb_User.sTeams, .sUnits
--	7.06.5939	- @sUser='All Units'
--	7.06.5568	+ @sUser='*'
--	7.05.5121	* .sBarCode -> .sUnits
--	7.05.5098	* check idUnit
--	7.05.5084	* added check for null on @sUnits
--	7.05.5050
alter proc		dbo.pr_AccUnit_Set
	with encryption
as
begin
	declare	@idModule	tinyint
		,	@idFeature	tinyint
--		,	@i			int
--		,	@p			varchar( 3 )
--		,	@sUnits		varchar( 255 )
		,	@idRole		smallint

	set	nocount	on

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)

	insert	#tbUnit
		select	idUnit
			from	dbo.tbUnit	with (nolock)
			where	bActive = 0												--	inactive units

	declare		cur		cursor fast_forward for
		select	idModule, idFeature
			from	dbo.tb_Feature	with (nolock)

	begin	tran

		--	reset tb_RoleUnit, tb_UserUnit, tbTeamUnit for all inactive units
		delete	from	dbo.tb_RoleUnit
			where	idUnit	in	(select idUnit from #tbUnit with (nolock))
--	-		where	idUnit	in	(select idUnit from dbo.tbUnit with (nolock) where bActive = 0)

		delete	from	dbo.tb_UserUnit
			where	idUnit	in	(select idUnit from #tbUnit with (nolock))

		delete	from	dbo.tbTeamUnit
			where	idUnit	in	(select idUnit from #tbUnit with (nolock))

		--	enforce access to all units
		select	@idRole =	1												-- team [Techies]
		insert	dbo.tbTeamUnit	( idTeam, idUnit )
			select	@idRole, idUnit
				from	dbo.tbUnit
				where	bActive > 0	and	idShift > 0
				and		idUnit	not in	(select idUnit from dbo.tbTeamUnit where idTeam = @idRole)

		select	@idRole =	2												-- role [Admins]
		insert	dbo.tb_RoleUnit	( idRole, idUnit )
			select	@idRole, idUnit
				from	dbo.tbUnit
				where	bActive > 0	and	idShift > 0
				and		idUnit	not in	(select idUnit from dbo.tb_RoleUnit where idRole = @idRole)

		--	enforce [SysAdm] and [Admin] are in [Admins]
		if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 1 and idRole = @idRole)
			insert	dbo.tb_UserRole ( idUser, idRole )	values	( 1, @idRole )
		if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 2 and idRole = @idRole)
			insert	dbo.tb_UserRole ( idUser, idRole )	values	( 2, @idRole )

		--	enforce [Admins] have full permissions on all features of all modules
		open	cur
		fetch next from	cur	into	@idModule, @idFeature
		while	@@fetch_status = 0
		begin
			if	not	exists	(select 1 from dbo.tb_Access where idModule = @idModule and idFeature = @idFeature and idRole = @idRole)
				insert	dbo.tb_Access	(  idModule,  idFeature,  idRole, tiAccess )
						values			( @idModule, @idFeature, @idRole, 1 )

			fetch next from	cur	into	@idModule, @idFeature
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns teams for a given user
--	7.06.6817	+ 'order by 2'
--	7.06.6807
alter proc		dbo.pr_User_GetTeams
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idTeam, t.sTeam
		from	dbo.tbTeamUser	m	with (nolock)
		join	dbo.tbTeam		t	with (nolock)	on	t.idTeam = m.idTeam
		where	idUser = @idUser
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Returns users for a given team
--	7.06.6817	+ 'order by 2'
--	7.06.6807
alter proc		dbo.prTeam_GetUsers
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUser, t.sStaff
		from	dbo.tbTeamUser	m	with (nolock)
		join	dbo.tb_User		t	with (nolock)	on	t.idUser = m.idUser
		where	idTeam = @idTeam
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Returns unique email addresses for active members of a given team
--	7.06.8791	+ 'and	u.bActive > 0'
--	7.06.7432	+ 'distinct'
--	7.06.7373
alter proc		dbo.prTeam_GetEmails
(
	@idTeam		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	distinct	u.sEmail
		from	dbo.tbTeamUser	m	with (nolock)
		join	dbo.tb_User		u	with (nolock)	on	u.idUser	= m.idUser	and	u.bActive > 0
		where	idTeam = @idTeam
		and		len(u.sEmail) > 0		-- is not null
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a team
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8783	* #PK nonclustered -> clustered
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
,	@idTeam		smallint		out	-- team, acted upon
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
		,		@idType		tinyint

	set	nocount	on
	set	xact_abort	on

	create table	#tbCall
	(
		siIdx		smallint		not null	primary key clustered
	)
	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)

	exec	dbo.prCall_SetTmpFlt	@sCalls
	exec	dbo.prUnit_SetTmpFlt	@sUnits

	select	@s =	isnull(cast(@idTeam as varchar), '?') + '|' + @sTeam + ' ' + convert(varchar, @tResp, 108) +
					' ''' + isnull(cast(@sDesc as varchar), '?') + ''' @=' + cast(@bEmail as varchar) + ' a=' + cast(@bActive as varchar) +
					' c=' + isnull(cast(@sCalls as varchar), '?') + ' u=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from dbo.tbTeam with (nolock) where idTeam = @idTeam)
		begin
			insert	dbo.tbTeam	(  sTeam,  sDesc,  bEmail,  tResp,  bActive )
					values		( @sTeam, @sDesc, @bEmail, @tResp, @bActive )
			select	@idTeam =	scope_identity( )

			select	@idType =	247,	@s =	'Team_I( ' + @s + ' )=' + cast(@idTeam as varchar)
		end
		else
		begin
			select	@idType =	248,	@s =	'Team_U( ' + @s + ' )'

			update	dbo.tbTeam	set	sTeam=	@sTeam,	tResp=	@tResp,	bEmail =	@bEmail,	sDesc=	@sDesc,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idTeam = @idTeam
		end

		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule

		delete	from	dbo.tbTeamCall
			where	idTeam = @idTeam
			and		siIdx	not in	(select siIdx from #tbCall with (nolock))

		insert	dbo.tbTeamCall	( siIdx, idTeam )
			select	siIdx, @idTeam
				from	#tbCall	with (nolock)
				where	siIdx	not in	(select siIdx from tbTeamCall where idTeam = @idTeam)

		delete	from	dbo.tbTeamUnit
			where	idTeam = @idTeam
			and		idUnit	not in	(select idUnit from #tbUnit with (nolock))

		insert	dbo.tbTeamUnit	( idUnit, idTeam )
			select	idUnit, @idTeam
				from	#tbUnit	with (nolock)
				where	idUnit	not in	(select idUnit from tbTeamUnit where idTeam = @idTeam)

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns current active members on-duty
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.8448	* prTeam_GetStaffOnDuty -> prTeam_GetStaff
--	7.06.5429	+ .dtDue
--	7.06.5347
alter proc		dbo.prTeam_GetStaff
(
	@idTeam		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.tb_User		u	with (nolock)
		join	dbo.tbTeamUser	t	with (nolock)	on	t.idUser	= u.idUser	and	idTeam	= @idTeam
		where	bActive > 0	and	bDuty > 0
	--	order	by	1
end
go
--	----------------------------------------------------------------------------
--	7.06.8791	* tbDevice	->	tbCfgStn	(xuDevice_SGJR -> xuCfgStn_Act_SGJR,
--					tdDevice_Config -> tdCfgStn_Config, tdDevice_Active -> tdCfgStn_Active, tdDevice_Created -> tdCfgStn_Created, tdDevice_Updated -> tdCfgStn_Updated)
--				* ?Device -> ?Stn, idParent -> idPrnt, sCodeVer -> sVersion, tiPriCA? -> tiPri?, tiAltCA? -> tiAlt?
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDevice') and name = 'idDevice')
begin
	begin tran
		if	exists	(select 1 from dbo.sysindexes where name='xuDevice_SGJR')
			drop index	tbDevice.xuDevice_SGJR

		exec sp_rename 'tbDevice.idDevice',	'idStn',	'column'
		exec sp_rename 'tbDevice.idParent',	'idPrnt',	'column'
		exec sp_rename 'tbDevice.cDevice',	'cStn',		'column'
		exec sp_rename 'tbDevice.sDevice',	'sStn',		'column'
		exec sp_rename 'tbDevice.sCodeVer',	'sVersion',	'column'
		exec sp_rename 'tbDevice.tiPriCA0',	'tiPri0',	'column'
		exec sp_rename 'tbDevice.tiPriCA1',	'tiPri1',	'column'
		exec sp_rename 'tbDevice.tiPriCA2',	'tiPri2',	'column'
		exec sp_rename 'tbDevice.tiPriCA3',	'tiPri3',	'column'
		exec sp_rename 'tbDevice.tiPriCA4',	'tiPri4',	'column'
		exec sp_rename 'tbDevice.tiPriCA5',	'tiPri5',	'column'
		exec sp_rename 'tbDevice.tiPriCA6',	'tiPri6',	'column'
		exec sp_rename 'tbDevice.tiPriCA7',	'tiPri7',	'column'
		exec sp_rename 'tbDevice.tiAltCA0',	'tiAlt0',	'column'
		exec sp_rename 'tbDevice.tiAltCA1',	'tiAlt1',	'column'
		exec sp_rename 'tbDevice.tiAltCA2',	'tiAlt2',	'column'
		exec sp_rename 'tbDevice.tiAltCA3',	'tiAlt3',	'column'
		exec sp_rename 'tbDevice.tiAltCA4',	'tiAlt4',	'column'
		exec sp_rename 'tbDevice.tiAltCA5',	'tiAlt5',	'column'
		exec sp_rename 'tbDevice.tiAltCA6',	'tiAlt6',	'column'
		exec sp_rename 'tbDevice.tiAltCA7',	'tiAlt7',	'column'

		exec sp_rename 'dbo.tbDevice',	'tbCfgStn'	--,	'table'
	commit
end
go
if	not exists	(select 1 from dbo.sysindexes where name='xuCall_Act_siIdx')
begin
	begin tran
		create unique nonclustered index	xuCfgStn_Act_SGJR	on	dbo.tbCfgStn ( cSys, tiGID, tiJID, tiRID )	where	bActive > 0	-- + 6.02
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
--	7.06.8795	* prDevice_InsUpd	-> prCfgStn_InsUpd
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* ?Device -> ?Stn, idParent -> idPrnt, sCodeVer -> sVersion, tiPriCA? -> tiPri?, tiAltCA? -> tiAlt?
--				* tbCfgLoc.idParent -> .idPrnt
--	7.06.7292	* tb_Option[26]->[6]
--	7.06.7279	* optimized logging
--	7.06.6768	* AID updating and logging
--	7.06.6758	* optimized log (@iAID in hex)
--	7.06.6297	* optimized log
--	7.06.5907	* set .bConfig
--	7.06.5855	* AID update, IP-address for GWs -> .sDial
--	7.06.5843	* search only bActive > 0 devices for idParent
--	7.06.5466	* update tb_OptSys[26] for GWs
--				* optimize
--	7.06.5414	* set .sUnits= @sDial (IP) for GWs
--	7.05.5095	* skip .sUnits calculation for GWs
--	7.04.4953	* retain previous .sCodeVer values
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.02	* .siBeds, .sBeds, .idEvent, .tiSvc, .idUnit (moved to tbRoom)
--	7.00	* preset .idUnit for new rooms
--			* reset tdDevice.idEvent to null
--			+ .sUnits
--			+ @sCodeVer
--	6.07	- device matching by name
--	6.05	tracing reclassified 41 -> 74
--			+ (nolock)
--	6.04	+ @idDevice out
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02	tdDevice.dtLastUpd -> .dtUpdated
--			* .tiRID is never NULL now - added download of all stations
--			+ .cSys, xuDevice_GJR -> xuDevice_SGJR
--	6.00	tbDefDevice -> tbDevice (FKs)
--	5.01	encryption added
--	4.01
--	2.03	@tiRID ignored
--			+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--	2.02
create proc		dbo.prCfgStn_InsUpd
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiRID		tinyint				-- R-ID - R-bus
,	@iAID		int					-- device A-ID (32 bits)
,	@tiStype	tinyint				-- device type (1-255)
--,	@cDevice	char( 1 )			-- device type: G=gateway, R=room, M=master
--,	@sDevice	varchar( 16 )		-- device name
,	@cStn		char( 1 )			-- device type: G=gateway, R=room, M=master
,	@sStn		varchar( 16 )		-- device name
,	@sDial		varchar( 16 )		-- dialable number (digits only)
,	@tiPri0		tinyint				-- coverage area 0
,	@tiPri1		tinyint				-- coverage area 1
,	@tiPri2		tinyint				-- coverage area 2
,	@tiPri3		tinyint				-- coverage area 3
,	@tiPri4		tinyint				-- coverage area 4
,	@tiPri5		tinyint				-- coverage area 5
,	@tiPri6		tinyint				-- coverage area 6
,	@tiPri7		tinyint				-- coverage area 7
,	@tiAlt0		tinyint				-- alternate coverage area 0
,	@tiAlt1		tinyint				-- coverage area 1
,	@tiAlt2		tinyint				-- coverage area 2
,	@tiAlt3		tinyint				-- coverage area 3
,	@tiAlt4		tinyint				-- coverage area 4
,	@tiAlt5		tinyint				-- coverage area 5
,	@tiAlt6		tinyint				-- coverage area 6
,	@tiAlt7		tinyint				-- coverage area 7
--,	@sCodeVer	varchar( 16 )		-- device code version
,	@sVersion	varchar( 16 )		-- device code version

--,	@idDevice	smallint out		-- output: inserted/updated idDevice	--	6.04
,	@idStn		smallint		out	-- inserted/updated
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sSysts		varchar( 255 )
		,		@idPrnt		smallint
		,		@idUnit		smallint
		,		@sUnits		varchar( 255 )
		,		@iAID0		int
	
	set	nocount	on

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 6

	select	@s =	'Dvc_IU( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					' [' + isnull(@cStn,'?') + '] ''' + isnull(@sStn,'?') + ''' #' + isnull(@sDial,'?') + ', v=' + isnull(@sVersion,'?') +
					', p0=' + isnull(cast(@tiPri0 as varchar),'?') + ', p1=' + isnull(cast(@tiPri1 as varchar),'?') + ' )'

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0

---	if	@iAID <> 0
---		select	@idDevice= idDevice		from	tbDevice		where	iAID = @iAID
--	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0		and	@iAID <> 0
--		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	---and	bActive > 0
--	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0
--		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	---and	bActive > 0
	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0		and	@iAID <> 0
		select	@idStn= idStn	from	dbo.tbCfgStn	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	---and	bActive > 0
	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0
		select	@idStn= idStn	from	dbo.tbCfgStn	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	---and	bActive > 0
---	if	@idDevice is null	and	len(@sDevice) > 0	and	len(@sDial) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	and	sDial = @sDial	--and	bActive > 0
---	if	@idDevice is null	and	len(@sDevice) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	--and	bActive > 0

	if	@tiRID > 0						-- R-bus device
--		select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
		select	@idPrnt= idStn	from	dbo.tbCfgStn	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
	else
	if	@tiJID > 0	---and	@tiRID = 0	-- J-bus device
--		select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	bActive > 0
		select	@idPrnt= idStn	from	dbo.tbCfgStn	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	bActive > 0

--	select	@s =	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')

	begin	tran

		if	@tiJID = 0														-- gateway		--	7.06.5414
		begin
--			select	@sUnits =	@sDial,		@sDial =	null				-- @sDial == IP for GWs		--	7.06.5855

			if	charindex(@cSys, @sSysts) = 0								-- is @cSys in Allowed-Systems?
				update	dbo.tb_OptSys	set	sValue =	sValue + @cSys
					where	idOption = 6
		end
		else																-- calculate .sUnits
		begin
			if	@tiPri0 = 0xFF	or	@tiPri1 = 0xFF	or	@tiPri2 = 0xFF	or	@tiPri3 = 0xFF	or
				@tiPri4 = 0xFF	or	@tiPri5 = 0xFF	or	@tiPri6 = 0xFF	or	@tiPri7 = 0xFF	or
				@tiAlt0 = 0xFF	or	@tiAlt1 = 0xFF	or	@tiAlt2 = 0xFF	or	@tiAlt3 = 0xFF	or
				@tiAlt4 = 0xFF	or	@tiAlt5 = 0xFF	or	@tiAlt6 = 0xFF	or	@tiAlt7 = 0xFF
			begin
				insert	#tbUnit
					select	idLoc
						from	dbo.tbCfgLoc	with (nolock)
						where	tiLvl = 4									-- unit
			end
			else															-- specific units
			begin
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri0
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri1
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri2
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri3
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri4
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri5
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri6
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri7

				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt0
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt1
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt2
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt3
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt4
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt5
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt6
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt7
			end

			select	@sUnits =	''

			declare		cur		cursor fast_forward for
				select	distinct	idUnit
					from	#tbUnit		with (nolock)
					order	by	1

			open	cur
			fetch next from	cur	into	@idUnit
			while	@@fetch_status = 0
			begin
				select	@sUnits =	@sUnits + ',' + cast(@idUnit as varchar)

				fetch next from	cur	into	@idUnit
			end
			close	cur
			deallocate	cur

			if	len(@sUnits) > 0
				select	@sUnits =	substring(@sUnits, 2, len(@sUnits)-1)

			if	len(@sUnits) = 0
				select	@sUnits =	null
		end

--		if	@idDevice > 0													-- device found - update	--	7.06.5855
		if	@idStn > 0														-- device found - update	--	7.06.5855
		begin
			update	dbo.tbCfgStn	set		bConfig =	1,	dtUpdated=	getdate( )	--, idEvent =	null
				,	idPrnt =	@idPrnt,	cSys =	@cSys,	tiGID=	@tiGID,	tiJID=	@tiJID,	tiRID=	@tiRID,	sDial=	@sDial
				,	tiStype =	@tiStype,	cStn =	@cStn,	sStn =	@sStn,	sVersion =	@sVersion,	sUnits =	@sUnits
				,	tiPri0 =	@tiPri0,	tiPri1 =	@tiPri1,	tiPri2 =	@tiPri2,	tiPri3 =	@tiPri3
				,	tiPri4 =	@tiPri4,	tiPri5 =	@tiPri5,	tiPri6 =	@tiPri6,	tiPri7 =	@tiPri7
				,	tiAlt0 =	@tiAlt0,	tiAlt1 =	@tiAlt1,	tiAlt2 =	@tiAlt2,	tiAlt3 =	@tiAlt3
				,	tiAlt4 =	@tiAlt4,	tiAlt5 =	@tiAlt5,	tiAlt6 =	@tiAlt6,	tiAlt7 =	@tiAlt7
				,	@s =	@s + '*',	@iAID0 =	isnull(iAID, 0)
				where	idStn = @idStn

			if	@iAID <> 0	and		@iAID <> @iAID0							--	7.06.6768
			begin
				select	@s =	@s + ' a:' + isnull(cast(convert(varchar, convert(varbinary(4), iAID), 1) as varchar),'?')
	--	-						+ '->' + cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar)		-- already logged
					from	dbo.tbCfgStn	with (nolock)
					where	idStn = @idStn

				update	dbo.tbCfgStn	set		iAID= @iAID
					where	idStn = @idStn
			end

			if	@sVersion is not null
				update	dbo.tbCfgStn	set		sVersion= @sVersion
					where	idStn = @idStn
		end
		else																-- insert new device
		begin
			insert	dbo.tbCfgStn ( idPrnt,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cStn,  sStn,  sDial,  sVersion,  sUnits	--,  idUnit
								,	 tiPri0,  tiPri1,  tiPri2,  tiPri3,  tiPri4,  tiPri5,  tiPri6,  tiPri7
								,	 tiAlt0,  tiAlt1,  tiAlt2,  tiAlt3,  tiAlt4,  tiAlt5,  tiAlt6,  tiAlt7 )
					values		( @idPrnt, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cStn, @sStn, @sDial, @sVersion, @sUnits	--, @idUnit
								,	@tiPri0, @tiPri1, @tiPri2, @tiPri3, @tiPri4, @tiPri5, @tiPri6, @tiPri7
								,	@tiAlt0, @tiAlt1, @tiAlt2, @tiAlt3, @tiAlt4, @tiAlt5, @tiAlt6, @tiAlt7 )
			select	@idStn =	scope_identity( )
				,	@s =	@s + '+'

			if	@iAID <> 0													--	7.06.5855, 7.06.6768
				update	dbo.tbCfgStn	set		iAID= @iAID
					where	idStn = @idStn
		end

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
		begin
			select	@s =	@s + '=' + isnull(cast(@idStn as varchar),'?') + ', p=' + isnull(cast(@idPrnt as varchar),'?')
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end

	commit
end
go
grant	execute				on dbo.prCfgStn_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
--	7.06.8795	* prDevice_InsUpd	-> prCfgStn_InsUpd
--	7.06.8168	* fix APP_FAIL source (S-0-0-0) matching
--				+ 'SIP:' devices are marked with 'A'
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
create proc		dbo.prCfgStn_GetIns
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiRID		tinyint				-- R-ID - R-bus
,	@iAID		int					-- device A-ID (32 bits)
,	@tiStype	tinyint				-- device type (1-255)
--,	@cDevice	char( 1 )			-- device type: G=gateway, R=room, M=master
--,	@sDevice	varchar( 16 )		-- device name
,	@cStn		char( 1 )			-- device type: G=gateway, R=room, M=master
,	@sStn		varchar( 16 )		-- device name
,	@sDial		varchar( 16 )		-- dialable number (digits only)

--,	@idDevice	smallint out		-- output
,	@idStn		smallint out		-- output
)
	with	encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sSysts		varchar( 255 )
		,		@idPrnt		smallint
		,		@bActive	bit
		,		@sD			varchar( 16 )
		,		@iA			int

	set	nocount	on

	select	@idStn =	null

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 6

	if	charindex('SIP:', @sStn) = 1										-- SIP-phone
		select	@cStn =	'A'													--	7.06.8167

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + isnull(right('00' + cast(@tiGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiRID as varchar), 2),'?') +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + '|' + isnull(cast(@tiStype as varchar),'?') +
					' [' + isnull(@cStn,'?') + '] ''' + isnull(@sStn,'?') + ''' #' + isnull(@sDial,'?') + ' )'

	-- match 7967-P workflow station's (0x1A) 'phantom' RIDs
	if	@idStn is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow

		-- match active devices?
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)	--	7.06.6758
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		-- match inactive devices?
		if	@idStn is null
			select	@idStn=	idStn,	@bActive =	bActive	from	dbo.tbCfgStn	with (nolock)
				where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		if	@idStn > 0
		begin
			if	@bActive = 0
				update	dbo.tbCfgStn	set	bActive= 1
					where	idStn = @idStn

/*			select	@sD =	sStn,	@iA =	iAID							--	7.06.6758, .6773
				from	dbo.tbCfgStn
				where	idStn = @idStf

			if	@sD <> @sStn
				select	@s =	@s + ' ^n:"' + @sD + '"'

			if	@iA <> @iAID
				select	@s =	@s + ' ^a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

			if	@sD <> @sStn	or	@iA <> @iAID
				exec	dbo.pr_Log_Ins	82, null, null, @s
*/
			return	0														-- match found
		end
	end

	-- adjust AID
	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0


	-- match active devices?
	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.04.4969, .4972
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0		and	cStn = 'M'

	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


	-- match GW#_FAIL source?
	if	@idStn is null	and	@tiGID > 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7535
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	cStn = 'G'
--			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0
--			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	cDevice = 'G'

	-- match APP_FAIL source?
	if	@idStn is null	and	@tiGID = 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7410
		select	@idStn=	idStn,	@bActive =	bActive,	@cStn =	'$'	from	dbo.tbCfgStn	with (nolock)		--	7.06.8167
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID
--			where	bActive > 0		and	cSys = @cSys	and	tiGID = 0	and	tiJID = 0	and	tiRID = 0	--and	cDevice = '$'
--	-		where						cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	--and	cDevice = 'M'


	-- match inactive devices?
	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.06.5560
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0		and	cStn = 'M'

	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idStn=	idStn,	@bActive =	bActive		from	dbo.tbCfgStn	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


--	if	@idStn > 0															--	7.06.5560
	if	@idStn is not null													--	7.06.739?
	begin
		if	@bActive = 0
			update	dbo.tbCfgStn	set	bActive= 1
				where	idStn = @idStn

		select	@sD =	sStn,	@iA =	iAID												--	7.06.6758
			from	dbo.tbCfgStn	with (nolock)
			where	idStn = @idStn

		if	@tiRID = 0	and	@sD <> @sStn
			select	@s =	@s + ' !n:''' + @sD + ''''

		if	@iA <> @iAID
			select	@s =	@s + ' !a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

		if	@tiRID = 0	and	@sD <> @sStn	or	@iAID <> 0	and	@iA <> @iAID
			exec	dbo.pr_Log_Ins	82, null, null, @s

		return	0															-- match found
	end

--	if	@idStf is null	and	len(@sStn) > 0	and	@cSys is not null		--	7.05.5186
	if	len(@sStn) > 0	and	@cSys is not null							--	7.05.5186
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
					select	@idPrnt =	idStn	from	dbo.tbCfgStn	with (nolock)
						where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0

				if	@tiJID > 0	and	@tiRID = 0		-- J-bus device
					select	@idPrnt =	idStn	from	dbo.tbCfgStn	with (nolock)
						where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0

				insert	dbo.tbCfgStn	(  idPrnt,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cStn,  sStn,  sDial )
						values			( @idPrnt, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cStn, @sStn, @sDial )
				select	@idStn =	scope_identity( )

				if	@tiLog & 0x02 > 0										--	Config?
--				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
				begin
					select	@s =	@s + '=' + isnull(cast(@idStn as varchar),'?') + ', p=' + isnull(cast(@idPrnt as varchar),'?')
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
grant	execute				on dbo.prCfgStn_GetIns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* fkCfgMst_CfgDvc	->	fkCfgMst_CfgStn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkCfgMst_CfgDvc')
begin
	begin tran
		alter table	dbo.tbCfgMst	drop	constraint	fkCfgMst_CfgDvc
--g o
--if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkCfgMst_CfgStn')
		alter table	dbo.tbCfgMst	add
			constraint	fkCfgMst_CfgStn		foreign key	( idMaster )	references tbCfgStn
	commit
end
go
--	----------------------------------------------------------------------------
--	Clears all master attributes
--	7.06.7279	* optimized logging
--	7.06.5914	* 74->75, optimized
--	7.06.5905	* 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgMst_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	dbo.tbCfgMst
		select	@s =	'Mst_C( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	75, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a master attributes record
--	7.06.7279	* optimized logging
--	7.06.5914	* trace:0x08, 74->75
--	7.06.5905	* trace:0x04, 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgMst_Ins
(
	@idMaster	smallint			-- device (PK)
,	@tiCvrg		tinyint				-- CA
,	@iFilter	int					-- filter bits for this CA
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Mst_I( ' + isnull(cast(@idMaster as varchar), '?') +
					', c=' + isnull(cast(@tiCvrg as varchar), '?') +
					', ' + convert(varchar, convert(varbinary(4), @iFilter), 1) + ' )'

	if	@tiCvrg = 0xFF		select	@tiCvrg= 0		--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from dbo.tbCfgMst with (nolock) where idMaster = @idMaster and tiCvrg = @tiCvrg)
	begin
		begin	tran

			insert	dbo.tbCfgMst	(  idMaster,  tiCvrg,  iFilter )
					values			( @idMaster, @tiCvrg, @iFilter )

			if	@tiLog & 0x02 > 0											--	Config?
--			if	@tiLog & 0x04 > 0											--	Debug?
--			if	@tiLog & 0x08 > 0											--	Trace?
				exec	dbo.pr_Log_Ins	75, null, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* .idDevice	->	.idStn
--				* fkCfgBtn_CfgDvc	->	fkCfgBtn_CfgStn
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgBtn') and name = 'idDevice')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkCfgBtn_CfgDvc')
			alter table	dbo.tbCfgBtn	drop	constraint	fkCfgBtn_CfgDvc

		exec sp_rename 'tbCfgBtn.idDevice',	'idStn',	'column'
	commit
end
go
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkCfgBtn_CfgStn')
begin
	begin tran
		alter table	dbo.tbCfgBtn	add
			constraint	fkCfgBtn_CfgStn		foreign key	( idStn )	references tbCfgStn
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a device button input
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* .idDevice	->	.idStn
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn,	prCfgDvcBtn_Ins -> prCfgBtn_Ins
--				* .siPri -> .siIdx
--	7.06.7279	* optimized logging
--	7.06.5914	* trace:0x20, 74->76
--	7.06.5905	* trace:0x04, 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgBtn_Ins
(
	@idStn		smallint			-- device (PK)
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

	select	@s =	'CfgBtn_I( ' + isnull(cast(@idStn as varchar), '?') + ' #' + isnull(cast(@tiBtn as varchar), '?') +
					', p=' + isnull(cast(@siIdx as varchar), '?') + ', b=' + isnull(cast(@tiBed as varchar), '?') + ' )'

	if	@tiBed = 0xFF		select	@tiBed =	null						--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from dbo.tbCfgBtn with (nolock) where idStn = @idStn and tiBtn = @tiBtn)
	begin
		begin	tran

			insert	dbo.tbCfgBtn	(  idStn,  tiBtn,  siIdx,  tiBed )
					values			( @idStn, @tiBtn, @siIdx, @tiBed )

			if	@tiLog & 0x02 > 0											--	Config?
--			if	@tiLog & 0x04 > 0											--	Debug?
--			if	@tiLog & 0x08 > 0											--	Trace?
				exec	dbo.pr_Log_Ins	76, null, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Staff definitions (only with staff-level set!)
--	7.06.8789	* tb_User.sBarCode	-> sCode
--	7.06.8784	* tbStfLvl.*StfLvl	-> *Lvl
--				* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8783	* tb_User.sStaffID -> sStfID
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
select	idUser, sStfID,		sFrst, sMidd, sLast, u.idLvl, l.cLvl, l.sLvl, sCode
	,	sStaff,	isnull(sStfID, '--') + ' | ' + sStaff	as	sQnStf
	,	bDuty, dtDue,	u.idRoom
	,	bActive, dtCreated, dtUpdated
	from	dbo.tb_User	u	with (nolock)
	join	dbo.tbStfLvl l	with (nolock)	on	l.idLvl = u.idLvl
go
--	----------------------------------------------------------------------------
--	Returns [active?] staff, ordered to be loadable into a table
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
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
	select	idUser,	cast(1 as bit)	as	bEnabled,	sStfID, sStaff, idLvl, cLvl, sLvl
		from	dbo.vwStaff		with (nolock)
		where	@bActive = 0	or	bActive > 0
		and		substring(sStaff, 1, 1) <> char(0x7F)						-- filter out RTLS-auto
		order	by	idLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	7.06.8789	* .sBarCode	-> sCode	(xuDvc_Act_BarCode -> xuDvc_Act_Code)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDvc') and name = 'sBarCode')
begin
	begin tran
		if	exists	(select 1 from dbo.sysindexes where name='xuDvc_Act_BarCode')
			drop index	tbDvc.xuDvc_Act_BarCode

		exec sp_rename 'tbDvc.sBarCode',	'sCode',	'column'
	commit
end
go
if	not exists	(select 1 from dbo.sysindexes where name='xuDvc_Act_Code')
begin
	begin tran
		create unique nonclustered index	xuDvc_Act_Code		on	dbo.tbDvc ( sCode )		where	bActive > 0		and	sCode is not null	--	7.06.5428
	commit
end
go
/*
--	----------------------------------------------------------------------------
--	7.06.8861	* tvDvc_Assn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tvDvc_Assn')
	alter table	dbo.tbDvc		drop
		constraint	tvDvc_Assn
g o
if	not	exists	(select 1 from dbo.sysobjects where uid=1 and name='tvDvc_Assn')
	alter table	dbo.tbDvc		add
		constraint	tvDvc_Assn	check	( idDvcType > 1	and	(tiFlags & 1 = 0	or	bActive > 0)			--	only active devices can be assignable
														and	(tiFlags & 1 > 0	or	idUser is null) )		--	and only assignable can be assigned
*/
go
--	----------------------------------------------------------------------------
--	Staff notification devices (Badge|Pager|Phone|Wi-Fi)
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
select	d.idDvc, d.idDvcType, t.cDvcType, t.sDvcType, d.sDial, d.sDvc, d.sCode, d.tiFlags, d.sBrowser
	,	t.cDvcType + ' ' + d.sDial		as	sQnDvc
	,	d.idUser, s.idLvl, s.sLvl, s.sStfID, s.sStaff, s.sQnStf, s.bDuty, s.dtDue
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	dbo.tbDvc		d	with (nolock)
	join	dbo.tbDvcType	t	with (nolock)	on	t.idDvcType	= d.idDvcType
	left join	dbo.vwStaff	s	with (nolock)	on	s.idUser	= d.idUser
go
--	----------------------------------------------------------------------------
--	Updates a given notification device's assigned staff
--	7.06.8769	+ @tiFlags
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--	7.05.5010	* prStfDvc_UpdStf -> prDvc_UpdUsr
--				* idStfDvc -> idDvc, .idStaff -> .idUser, @idStaff -> @idUser
--	7.04.4897	* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.03
alter proc		dbo.prDvc_UpdUsr
(
	@idDvc		int							-- badge id
,	@tiFlags	tinyint
,	@idUser		int							-- who is this device is being assigned to?
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
			,	@idDvcType	tinyint
			,	@bActive	bit

	set	nocount	on

	select	@bActive =	0
	select	@bActive =	bActive
		from	dbo.tb_User		with (nolock)
		where	idUser = @idUser
		and		substring(sStaff, 1, 1) != char(0x7F)						-- excludes auto-RTLS badges/staff

	if	@bActive = 0		select	@idUser =	null						-- enforce no assignment for inactive staff

	select	@bActive =	bActive,	@idDvcType =	idDvcType
		from	dbo.tbDvc	with (nolock)
		where	idDvc = @idDvc

	if	@idDvcType > 2		select	@tiFlags =	@tiFlags | 0x01				-- enforce assignable for Phone, Wi-Fi

	if	@bActive = 0		select	@tiFlags =	@tiFlags & 0xFE				-- enforce unassignable for inactive

	begin	tran

		if	@tiFlags & 1 = 0
			update	dbo.tbDvc	set tiFlags =	@tiFlags,	dtUpdated=	getdate( ),	idUser =	null
				where	idDvc = @idDvc
		else
			update	dbo.tbDvc	set tiFlags =	@tiFlags,	dtUpdated=	getdate( ),	idUser =	@idUser
				where	idDvc = @idDvc
				and	(	@idUser is null		or	bActive > 0		and	@tiFlags & 1 > 0	)

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all notification devices
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.05.5121	+ .sUnits
--	7.05.5099
alter proc		dbo.prDvc_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sCode, sDial, tiFlags, idUser, sBrowser, bActive, dtCreated, dtUpdated
		from	dbo.tbDvc	with (nolock)
	--	where	idDvc >= 0x01000000
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a notification device
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.05.5121	+ .sUnits
--	7.05.5099
alter proc		dbo.prDvc_Imp
(
	@idDvc		int
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
--,	@sBarCode	varchar( 32 )
,	@sCode		varchar( 32 )
,	@sDial		varchar( 16 )
,	@tiFlags	tinyint				-- bitwise: 1=group, 2=tech
,	@idUser		int
,	@sBrowser	varchar( 255 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not	exists	(select 1 from dbo.tbDvc with (nolock) where idDvc = @idDvc)
		begin
			set identity_insert	dbo.tbDvc	on

			insert	dbo.tbDvc	(  idDvc,  idDvcType,  sDvc,  sCode,  sDial,  tiFlags,  sBrowser,  idUser,  bActive,  dtCreated,  dtUpdated )
					values		( @idDvc, @idDvcType, @sDvc, @sCode, @sDial, @tiFlags, @sBrowser, @idUser, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbDvc	off
		end
		else
			update	dbo.tbDvc	set	idDvcType=	@idDvcType,	sDvc =	@sDvc,	sCode =	@sCode,	sDial=	@sDial,	tiFlags =	@tiFlags
						,	sBrowser =	@sBrowser,	idUser =	@idUser,	bActive =	@bActive,	dtUpdated=	@dtUpdated
				where	idDvc = @idDvc

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns units for a given notification device
--	7.06.6817	+ order by 2
--	7.06.6807
alter proc		dbo.prDvc_GetUnits
(
	@idDvc		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idUnit, u.sUnit
		from	dbo.tbDvcUnit	m	with (nolock)
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit = m.idUnit
		where	idDvc = @idDvc
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Returns teams for a given device
--	7.06.6816	* tbDvcTeam -> tbTeamDvc
--	7.06.6807
alter proc		dbo.prDvc_GetTeams
(
	@idDvc		int
)
	with encryption
as
begin
--	set	nocount	on
	select	m.idTeam, t.sTeam
		from	dbo.tbTeamDvc	m	with (nolock)
		join	dbo.tbTeam		t	with (nolock)	on	t.idTeam = m.idTeam
		where	m.idDvc = @idDvc
end
go
--	----------------------------------------------------------------------------
--	Returns active notification devices of given type(s), assigned to a given user
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--				* sQnDevice	-> sQnRoom
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
	select	idDvc, idDvcType, sDvc, sDial, tiFlags, sCode, sBrowser, bActive
		,	null	as	idRoom,		null	as	sQnRoom
		,	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.vwDvc	with (nolock)
		where	bActive > 0
		and		idDvcType & @idDvcType	<> 0
		and		idUser	= @idUser
end
go
--	----------------------------------------------------------------------------
--	Returns active group notification devices (pagers only), assigned to a given team
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--				* sQnDevice	-> sQnRoom
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
	select	idDvc, idDvcType, sDvc, sDial, tiFlags, sCode, sBrowser, bActive
		,	null	as	idRoom,		null	as	sQnRoom
		,	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.vwDvc	with (nolock)
		where	bActive > 0
		and		idDvcType = 2												--	pager
		and		idDvc	in	(select idDvc from dbo.tbTeamDvc with (nolock) where idTeam = @idTeam)
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a notification device
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8745	+ make phones/wi-fi assignable
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--				+ unassign unassignable
--	7.06.8734	+ unassign deactivated
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
--,	@sBarCode	varchar( 32 )
,	@sCode		varchar( 32 )
,	@tiFlags	tinyint
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@idType		tinyint
		,		@idOper		int

	set	nocount	on
	set	xact_abort	on

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)
	create table	#tbTeam
	(
		idTeam		smallint		not null	primary key clustered
--	,	sTeam		varchar( 16 )	not null
	)

	if	@idDvcType > 2														--	7.06.8745	Phone, Wi-Fi
		select	@tiFlags =	@tiFlags | 0x01									--		enforce assignable

--	if	@idDvcType = 0x01	and	@bActive = 0								--	7.06.8431	inactive Badge
	if	@bActive = 0														--	7.06.8740	inactive
		select	@tiFlags =	@tiFlags & 0xFE									--		enforce unassignable

	if	@idDvcType & 9 > 0	or	@bActive = 0								-- Badge|Wi-Fi or inactive devices
		select	@sUnits =	null	--,	@sTeams =	null					-- enforce no Units or Teams
	else
	begin
		exec	dbo.prUnit_SetTmpFlt	@sUnits
--		exec	dbo.prTeam_SetTmpFlt	@sTeams
	end

	if	@idDvcType = 2	and	@tiFlags & 1 = 0								-- group Pagers
		exec	dbo.prTeam_SetTmpFlt	@sTeams
	else
		select	@sTeams =	null											-- enforce no Teams for everything else

	select	@s =	isnull(cast(@idDvc as varchar), '?') + '|' + cast(@idDvcType as varchar) + '|''' + @sDvc +
					''', c=' + isnull(cast(@sCode as varchar), '?') + ', #' + isnull(cast(@sDial as varchar), '?') +
					', f=' + cast(cast(@tiFlags as varbinary(2)) as varchar) + ', a=' + cast(@bActive as varchar) +
					' U=' + isnull(cast(@sUnits as varchar), '?') + ' T=' + isnull(cast(@sTeams as varchar), '?')
---	exec	dbo.pr_Log_Ins	1, @idUser, null, @s, @idModule

	select	@idOper =	idUser
		from	dbo.tbDvc	with (nolock)
		where	idDvc = @idDvc

	begin	tran

		if	not exists	(select 1 from dbo.tbDvc with (nolock) where idDvc = @idDvc)
		begin
			insert	dbo.tbDvc	(  idDvcType,  sDvc,  sCode,  sDial,  tiFlags,  bActive )
					values		( @idDvcType, @sDvc, @sCode, @sDial, @tiFlags, @bActive )
			select	@idDvc =	scope_identity( )

			select	@idType =	247,	@s =	'Dvc_I( ' + @s + ' ) =' + cast(@idDvc as varchar)

			if	@idDvcType = 8												--	Wi-Fi devices
				update	dbo.tbDvc	set	sCode=	cast(@idDvc as varchar)		--		enforce barcode to == DvcID
					where	idDvc = @idDvc
		end
		else
		begin
			select	@idType =	248,	@s =	'Dvc_U( ' + @s + ' )'

			if	@bActive = 0	or	@tiFlags & 1 = 0						--	7.06.8740	unassign inactive/deactivated
				select	@idOper =	null

			update	dbo.tbDvc	set	idDvcType=	@idDvcType,	sDvc =	@sDvc,	sDial=	@sDial,	sCode=	@sCode
								,	tiFlags =	@tiFlags,	idUser =	@idOper,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc
		end

		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule

		delete	from	dbo.tbDvcUnit
			where	idDvc = @idDvc
			and		idUnit	not in		(select idUnit from #tbUnit with (nolock))

		insert	dbo.tbDvcUnit	( idUnit, idDvc )
			select	idUnit, @idDvc
				from	#tbUnit	with (nolock)
				where	idUnit	not in	(select idUnit from dbo.tbDvcUnit with (nolock) where idDvc = @idDvc)

		delete	from	dbo.tbTeamDvc
			where	idDvc = @idDvc
			and		idTeam	not in		(select idTeam from #tbTeam with (nolock))

		insert	dbo.tbTeamDvc	( idTeam, idDvc )
			select	idTeam, @idDvc
				from	#tbTeam	with (nolock)
				where	idTeam	not in	(select idTeam from dbo.tbTeamDvc with (nolock) where idDvc = @idDvc)

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all staff (indicating inactive† and assigned badges) for 7981cw combo-box column
--	7.06.8784	* tbStfLvl.*StfLvl	-> *Lvl
--				* tb_User.idStfLvl	-> idLvl
--	7.06.8769	+ @bAuto for exclusion of auto-RTLS
--	7.06.8313	* s.sStfLvl -> s.cStfLvl
--	7.06.8284	* '(inactive)' -> '†'
--				- .iColorB
--	7.06.8137	* sFqStaff -> sQnStf
--	7.05.5161	* active -> all, + '(inactive)' indication
--	7.05.5064	+ .idDvcType = 1
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4953
alter proc		dbo.prStaff_LstAct
(
	@bAuto		bit			= 0		--	include Auto-RTLS?
)
	with encryption
as
begin
	select	s.idUser,		s.cLvl + ' ' + s.sQnStf +	case	when bActive = 0	then '†'	else ''	end +
				case	when b.lCount > 0	then ' -- [' + cast(b.idDvc as varchar) + ']'	else ''	end +
				case	when b.lCount > 1	then ', +' + cast(b.lCount-1 as varchar)		else ''	end		as	sQnStf
		from	dbo.vwStaff	s	with (nolock)
		left join
			(select	idUser,	count(*) as lCount,	min(idDvc) as idDvc			--	all badges assigned to this user
				from	dbo.tbDvc	with (nolock)
				where	idDvcType = 1										--	badge
				group by	idUser)		b	on	b.idUser	= s.idUser
		where	( @bAuto != 0	or	substring(sStaff, 1, 1) != char(0x7F) )
--		and		bActive > 0
		order	by	idLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* fkRoom_Device -> fkRoom_CfgStn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoom_Device')
begin
	begin tran
		alter table	dbo.tbRoom	drop	constraint	fkRoom_Device
--g o
--if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoom_CfgStn')
		alter table	dbo.tbRoom	add
			constraint	fkRoom_CfgStn		foreign key	( idRoom )	references tbCfgStn
	commit
end
go
--	----------------------------------------------------------------------------
--	790 Devices
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* ?Device -> ?Stn, idParent -> idPrnt, sCodeVer -> sVersion, tiPriCA? -> tiPri?, tiAltCA? -> tiAlt?
--				* sQnDvc -> sQnStn
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
create view		dbo.vwCfgStn
	with encryption
as
select	r.idUnit,	idStn, idPrnt,	cSys, tiGID, tiJID, tiRID, iAID, tiStype,	cStn, sStn, sDial, sVersion, sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)												as sSGJ
	,	'[' + cStn + '] ' + sStn		as sQnStn
	,	r.idEvent,	r.tiSvc,	r.idUserG,	r.sStaffG,		r.idUserO,	r.sStaffO,		r.idUserY,	r.sStaffY
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	dbo.tbCfgStn	d	with (nolock)
left join	dbo.tbRoom		r	with (nolock)	on	r.idRoom	= d.idStn
go
grant	select, insert, update			on dbo.vwCfgStn			to [rWriter]
grant	select							on dbo.vwCfgStn			to [rReader]
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + registered staff
--	7.06.8810	+ .sUnit
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* ?Device -> ?Stn, idParent -> idPrnt, sCodeVer -> sVersion, tiPriCA? -> tiPri?, tiAltCA? -> tiAlt?
--				* sQnDvc	-> sQnStn
--				* sStn		-> sRoom	(but not cStn!)
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8740	* tbDevice -> vwDevice		less redefinitions
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
select	r.idUnit, u.sUnit,	idStn as idRoom, idPrnt,	cSys, tiGID, tiJID, tiRID, iAID, tiStype,	cStn, sStn as sRoom, sDial, sVersion, sUnits, r.siBeds, r.sBeds
	,	sSGJR, sSGJ, sQnStn as sQnRoom,	r.idEvent,	r.tiSvc
	,	r.idUserG,  s4.idLvl as idLvlG,  s4.sStfID as sStfIdG,  coalesce(s4.sStaff, r.sStaffG) as sStaffG,  s4.bDuty as bDutyG,  s4.dtDue as dtDueG
	,	r.idUserO,  s2.idLvl as idLvlO,  s2.sStfID as sStfIdO,  coalesce(s2.sStaff, r.sStaffO) as sStaffO,  s2.bDuty as bDutyO,  s2.dtDue as dtDueO
	,	r.idUserY,  s1.idLvl as idLvlY,  s1.sStfID as sStfIdY,  coalesce(s1.sStaff, r.sStaffY) as sStaffY,  s1.bDuty as bDutyY,  s1.dtDue as dtDueY
	,	r.dtExpires,	r.idUser4,	r.idUser2,	r.idUser1,	r.tiCall
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	dbo.vwCfgStn	d	with (nolock)
	join	dbo.tbRoom		r	with (nolock)	on	r.idRoom	= d.idStn
left join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= r.idUnit
left join	dbo.vwStaff		s4	with (nolock)	on	s4.idUser	= r.idUserG
left join	dbo.vwStaff		s2	with (nolock)	on	s2.idUser	= r.idUserO
left join	dbo.vwStaff		s1	with (nolock)	on	s1.idUser	= r.idUserY
go
--	----------------------------------------------------------------------------
--	Returns buttons [and corresponding devices], associated with presence (in a given room)
--	7.06.8795	* prCfgDvc_GetBtns	->	prCfgStn_GetBtns
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* sQnDvc -> sQnStn
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn
--				* .siPri -> .siIdx
--	7.06.8433	* p.tiSpec in (7,8,9) -> p.siFlags & 0x1000 > 0
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.05.4990
create proc		dbo.prCfgStn_GetBtns
(
	@idRoom		smallint			-- device (PK)
)
	with encryption
as
begin
	--	set	nocount	off
	select	b.idStn, d.sQnStn, d.tiRID, b.tiBtn, p.tiSpec		--, d.tiGID, d.tiJID
		from	dbo.tbCfgBtn	b	with (nolock)
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx	and	p.siFlags & 0x1000 > 0	--	7.06.8433
		join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= b.idStn	and	d.bActive > 0
		where	d.idPrnt = @idRoom
		order	by	2
end
go
grant	execute				on dbo.prCfgStn_GetBtns				to [rReader]
grant	execute				on dbo.prCfgStn_GetBtns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all rooms (indicating inactive) for 7981cw
--	7.06.8795	* prRoom_LstAct		->	prRoom_GetAll
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8284	* '(inactive)' -> '†'
--	7.06.8139	* sQnDevice -> sQnDvc
--	7.05.5161	* active -> all, + '(inactive)' indication
--	7.04.4959	prRoom_GetAct -> prRoom_LstAct
--	7.04.4953	* added ' '
--	7.03
create proc		dbo.prRoom_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idRoom,		sSGJ + ' ' + sQnRoom + case when bActive = 0 then ' †' else '' end	as	sQnRoom
		from	dbo.vwRoom	with (nolock)
		order	by	2
end
go
grant	execute				on dbo.prRoom_GetAll				to [rWriter]
grant	execute				on dbo.prRoom_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates room's staff
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.7355	* optimized logging
--	7.06.7318	+ clearing other rooms
--	7.06.7292	+ tbRoom.idUser4, .idUser2, .idUser1
--	7.06.7279	* optimized logging
--	7.06.7265	- @idUnit	(now only updates staff)
--	7.06.7249	* added handling 790-set staff (names only, no .idUser?)
--	7.06.7242	+ checks for already registered staff
--				+ update tbRoom only if something changed
--	7.06.6225	* optimize
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--				* prRoom_Upd -> prRoom_UpdStaff
--	7.04.4953	* 
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.03	+ @idUnit
--	7.02	* tbRoomStaff -> tbRoom (prRoomStaff_Upd -> prRoom_Upd)
--			* fill in idStaff's as well
--	6.05
alter proc		dbo.prRoom_UpdStaff
(
	@idRoom		smallint			-- 790 device look-up FK
,	@siIdx		smallint			-- new priority (0 on cancel)
,	@sStaffG	varchar( 16 )
,	@sStaffO	varchar( 16 )
,	@sStaffY	varchar( 16 )
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@tiEdit		tinyint
		,		@idUserG	int
		,		@idUserO	int
		,		@idUserY	int
		,		@sStaff4	varchar( 16 )
		,		@sStaff2	varchar( 16 )
		,		@sStaff1	varchar( 16 )
		,		@sRoom		varchar( 16 )

	set	nocount	on

	select	@idUserG =	idUserG,	@sStaff4 =	sStaffG,	@idUserO =	idUserO,	@sStaff2 =	sStaffO
		,	@idUserY =	idUserY,	@sStaff1 =	sStaffY,	@sRoom =	sRoom,		@tiEdit =	0
		from	dbo.vwRoom	with (nolock)
		where	idRoom = @idRoom											-- get current

	if		@idUserG is null	and	@sStaff4 is null	and	@sStaffG is null
		and	@idUserO is null	and	@sStaff2 is null	and	@sStaffO is null
		and	@idUserY is null	and	@sStaff1 is null	and	@sStaffY is null
		or
			@sStaff4 = @sStaffG	and	@sStaff2 = @sStaffO	and	@sStaff1 = @sStaffY
		return	0															-- no change

	if	@sStaffG is null													-- Green
	begin
		if	0 < @idUserG
			select	@tiEdit |=	1,	@idUserG =	null
	end
	else
	if	@sStaff4 is null	or	@sStaff4 <> @sStaffG
			select	@tiEdit |=	2,	@idUserG =	idUser	from	dbo.tb_User	with (nolock)	where	sStaff = @sStaffG

	if	@sStaffO is null													-- Orange
	begin
		if	0 < @idUserO
			select	@tiEdit |=	4,	@idUserO =	null
	end
	else
	if	@sStaff2 is null	or	@sStaff2 <> @sStaffO
			select	@tiEdit |=	8,	@idUserO =	idUser	from	dbo.tb_User	with (nolock)	where	sStaff = @sStaffO

	if	@sStaffY is null													-- Yellow
	begin
		if	0 < @idUserY
			select	@tiEdit |=	16,	@idUserY =	null
	end
	else
	if	@sStaff1 is null	or	@sStaff1 <> @sStaffY
			select	@tiEdit |=	32,	@idUserY =	idUser	from	dbo.tb_User	with (nolock)	where	sStaff = @sStaffY

	if	0 < @tiEdit															-- change
	begin
		select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

		select	@dt =	getdate( )
			,	@s =	'Rm_US( ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(@sRoom,'?') +
						', ' + isnull(cast(@tiEdit as varchar),'?') +
						', G:' + isnull(cast(@idUserG as varchar),'?') + '|' + isnull(@sStaffG,'?') +
						', O:' + isnull(cast(@idUserO as varchar),'?') + '|' + isnull(@sStaffO,'?') +
						', Y:' + isnull(cast(@idUserY as varchar),'?') + '|' + isnull(@sStaffY,'?') + ' ) '

		begin	tran

			update	dbo.tbRoom	set	idUserG =	null,	sStaffG =	null,	dtUpdated=	@dt
				where	@sStaffG is not null	and	idRoom <> @idRoom	and	sStaffG = @sStaffG

			update	dbo.tbRoom	set	idUserO =	null,	sStaffO =	null,	dtUpdated=	@dt
				where	@sStaffO is not null	and	idRoom <> @idRoom	and	sStaffO = @sStaffO

			update	dbo.tbRoom	set	idUserY =	null,	sStaffY =	null,	dtUpdated=	@dt
				where	@sStaffY is not null	and	idRoom <> @idRoom	and	sStaffY = @sStaffY

			update	dbo.tbRoom	set	idUserG =	@idUserG,	sStaffG =	@sStaffG
								,	idUserO =	@idUserO,	sStaffO =	@sStaffO
								,	idUserY =	@idUserY,	sStaffY =	@sStaffY
								,	dtUpdated=	@dt
				where	idRoom = @idRoom

			select	@s =	@s + cast(@@rowcount as varchar)

--			if	@tiLog & 0x02 > 0											--	Config?
			if	@tiLog & 0x04 > 0											--	Debug?
--			if	@tiLog & 0x08 > 0											--	Trace?
				exec	dbo.pr_Log_Ins	0, null, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Returns 790 devices, filtered according to args
--		same resultset	 prCfgStn_GetAll	???, prRoom_GetByUnit, prCfgStn_GetByUnit, prCfgStn_Get
--	7.06.8795	* prCfgDvc_GetAll	->	prCfgStn_GetAll
--	7.06.8791	* tbDevice	->	tbCfgStn
--	7.06.7830	* @tiKind streamlined across
--	7.06.7207	* switch to .cDevice from .tiStype (adding 700)
--	7.06.5855	* AID update, IP-address for GWs -> .sDial
--	7.06.5613	* 680 station types recognition
--	7.06.5414
create proc		dbo.prCfgStn_GetAll
(
--	@idUser		int			= null	-- null=any
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@tiKind		tinyint		= 0xFF	-- FF=any, 01=Gway, 02=Mstr, 04=Wkfl, 08=Room, 10=Zone, E0=Othr
)
	with encryption
as
begin
--	set	nocount	on
	select	idStn, idPrnt, tiJID, tiRID, sSGJR, iAID, tiStype, cStn
		,	case when	sBeds is null	then sStn	else	sStn + ' : ' + sBeds	end		as	sStn
		,	case when	tiStype	< 4		then sDial
				when	len(sUnits) > 31	then substring(sUnits,1,24) + '..(' + cast((len(sUnits)+1)/4 as varchar) + ' units)'
										else	sUnits	end		as	sUnits
		,	sDial, sVersion, idUnit
		,	bActive, dtCreated, dtUpdated
		from	dbo.vwCfgStn	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and	(	@tiKind = 0xFF												-- any
			or	@tiKind & 0x01 <> 0		and	cStn = 'G'						-- Gway
			or	@tiKind & 0x02 <> 0		and	cStn = 'M'						-- Mstr
			or	@tiKind & 0x04 <> 0		and	cStn = 'W'						-- Wkfl
			or	@tiKind & 0x08 <> 0		and	cStn = 'R'						-- Room
			or	@tiKind & 0x10 <> 0		and	cStn = 'Z'						-- Zone
			or	@tiKind & 0xE0 <> 0		and	cStn not in ('G','M','R','W','Z')	-- Othr
			)
--		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
--					from	tb_RoleUnit	ru	with (nolock)
--					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	sSGJR
end
go
grant	execute				on dbo.prCfgStn_GetAll				to [rWriter]
grant	execute				on dbo.prCfgStn_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns rooms/masters for given unit
--		same resultset	 prCfgStn_GetAll, prRoom_GetByUnit, prCfgStn_GetByUnit, prCfgStn_Get
--	7.06.8791	* tbDevice	->	tbCfgStn
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbRoom
	(
		idRoom		smallint		not null	primary key clustered		--	7.06.8783
	)

	insert	#tbRoom															-- add active rooms in given unit
		select	idRoom
		from	dbo.tbRoom	with (nolock)
		where	idUnit = @idUnit

	if	@bActive = 0														-- add other rooms that may belong to given unit
		insert	#tbRoom
			select	idStn
			from	dbo.vwCfgStn	with (nolock)
			where	tiRID = 0												-- room/master controllers
			and		cStn in ('R','M') 										-- Room|Mstr	(Wkfl,'W' is always @ RID=1)
			and		(idUnit <> @idUnit	and	sUnits like '%' + cast(@idUnit as varchar) + '%')
			and		idStn	not	in (select idRoom from #tbRoom with (nolock))

	set	nocount	off
--	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
	select	d.idStn, d.cSys, d.tiGID, d.tiJID, d.cStn, d.sStn, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated
		from		#tbRoom		t	with (nolock)
		join	dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= t.idRoom
		left join	dbo.tbRoom	r	with (nolock)	on	r.idRoom	= d.idStn					-- v.7.02
		order	by	d.sStn, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Returns devices/rooms/masters for given unit(s)
--		same resultset	 prCfgStn_GetAll, prRoom_GetByUnit, prCfgStn_GetByUnit, prCfgStn_Get
--	7.06.8795	* prDevice_GetByUnit	->	prCfgStn_GetByUnit
--	7.06.8791	* tbDevice	->	tbCfgStn
--	7.06.8783	* #PK nonclustered -> clustered
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
create proc		dbo.prCfgStn_GetByUnit
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

	create table	#tbRoom
	(
		idRoom		smallint		not null	primary key clustered		--	7.06.8783
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

			insert	#tbRoom
				select	d.idStn
					from	dbo.tbCfgStn	d	with (nolock)
					left join	#tbRoom		t	with (nolock)	on	t.idRoom	= d.idStn	and	t.idRoom is null
					where	(@bActive is null	or	d.bActive = @bActive)
					and	(	@tiKind = 0xFF									-- any
						or	tiRID = 0	and	(	@tiKind & 0x02 <> 0		and	cStn = 'M'		-- Mstr
											or	@tiKind & 0x08 <> 0		and	cStn = 'R')		-- Room
						or	tiRID = 1	and		@tiKind & 0x04 <> 0		and	cStn = 'W'	)	-- Wkfl
					and		d.sUnits like @s
--					and		t.idRoom is null

	---		select * from #tbRoom

			if	@si = 0
				break
			else
				select	@sUnits =	substring( @sUnits, @si + 1, len( @sUnits ) - @si )
		end
	end
	else		-- request for all units
	begin
			insert	#tbRoom
				select	d.idStn
					from	dbo.tbCfgStn	d	with (nolock)
					where	(@bActive is null	or	bActive = @bActive)
					and	(	@tiKind = 0xFF									-- any
						or	tiRID = 0	and	(	@tiKind & 0x02 <> 0		and	cStn = 'M'		-- Mstr
											or	@tiKind & 0x08 <> 0		and	cStn = 'R')		-- Room
						or	tiRID = 1	and		@tiKind & 0x04 <> 0		and	cStn = 'W'	)	-- Wkfl
	end

	set	nocount	off
--	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
	select	d.idStn, d.cSys, d.tiGID, d.tiJID, d.cStn, d.sStn, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from		#tbRoom		t	with (nolock)
		join	dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= t.idRoom
	left join	dbo.tbRoom		r	with (nolock)	on	r.idRoom	= d.idStn					-- v.7.02
		order	by	d.sStn,	d.bActive desc, d.dtCreated desc
end
go
grant	execute				on dbo.prCfgStn_GetByUnit			to [rReader]	--	6.05
grant	execute				on dbo.prCfgStn_GetByUnit			to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns requested device/room/master's details
--		same resultset	 prCfgStn_GetAll, prRoom_GetByUnit, prCfgStn_GetByUnit, prCfgStn_Get
--	7.06.8795	* prDevice_GetByID	->	prCfgStn_Get
--	7.06.8791	* tbDevice	->	tbCfgStn
--	7.02	* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	7.00
create proc		dbo.prCfgStn_Get
(
	@idStn		smallint			-- device (PK)
,	@bActive	bit =		null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	off
--	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
	select	d.idStn, d.cSys, d.tiGID, d.tiJID, d.cStn, d.sStn, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated
		from	dbo.tbCfgStn	d	with (nolock)
	left join	dbo.tbRoom		r	with (nolock)	on	r.idRoom	= d.idStn					-- v.7.02
		where	(@bActive is null	or	d.bActive = @bActive)
		and		d.idStn = @idStn
--	-	order	by	d.sStn, d.bActive desc, d.dtCreated desc
end
go
grant	execute				on dbo.prCfgStn_Get					to [rReader]
grant	execute				on dbo.prCfgStn_Get					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns assignable active staff for given unit(s)
--	7.06.8784	* tb_User.idStfLvl	-> idLvl, @
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8684	+ @sStaff
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
	@sUnits		varchar(255)		-- comma-separated idUnit's, '*'=all or null
,	@idLvl		tinyint		= null	-- null=any, 1=Yel, 2=Ora, 4=Grn
,	@bDuty		bit			= null	-- null=any, 0=off, 1=on
,	@sStaff		varchar(18)	= null	-- null, or '%<name or StfID>%'
)
	with encryption
as
begin
	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)
	create table	#tbUser
	(
		idUser		int				not null	primary key clustered
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	insert	#tbUser
		select	distinct	idUser
			from	dbo.tb_UserUnit	uu	with (nolock)
			join		#tbUnit		un	with (nolock)	on	un.idUnit	= uu.idUnit

	select	s.idUser, s.idLvl, s.sStfID, s.sStaff, s.bDuty, s.dtDue
		,	s.idRoom,	r.sQnRoom
		,	stuff((select ', ' + p.sDial
						from	tbDvc	p	with (nolock)	where	p.idUser = s.idUser	and	p.bActive > 0	and	p.idDvcType = 2
						for xml path ('')), 1, 2, '')	as	sPager
		,	stuff((select ', ' + f.sDial
						from	tbDvc	f	with (nolock)	where	f.idUser = s.idUser	and	f.bActive > 0	and	f.idDvcType = 4
						for xml path ('')), 1, 2, '')	as	sPhone
		,	stuff((select ', ' + n.sDial
						from	tbDvc	n	with (nolock)	where	n.idUser = s.idUser	and	n.bActive > 0	and	n.idDvcType = 8
						for xml path ('')), 1, 2, '')	as	sWi_Fi
--		from		dbo.vwStaff	s	with (nolock)
--		join			#tbUser	u	with (nolock)	on	u.idUser	= s.idUser
		from		#tbUser	u	with (nolock)
		join	dbo.vwStaff	s	with (nolock)	on	s.idUser	= u.idUser	and	s.bActive > 0
	left join	dbo.vwRoom	r	with (nolock)	on	r.idRoom	= s.idRoom
		where	substring(s.sStaff, 1, 1) <> char(0x7F)						--	7.06.8280	filter out RTLS-auto staff
		and		(@idLvl is null		or	s.idLvl		= @idLvl)
		and		(@bDuty is null		or	s.bDuty		= @bDuty)
		and		(@sStaff is null	or	s.sStaff like @sStaff	or	s.sStfID like @sStaff)
		order	by	s.idLvl desc, s.sStaff
end
go
--	----------------------------------------------------------------------------
--	Returns active ON-duty notifyable staff for a given unit
--	7.06.8790	* prStaff_GetPageable	->	prStaff_GetOnDuty
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.5429	+ .sStaffID, .bOnDuty, .dtDue
--	7.06.5388	+ distinct
--	7.06.5333	* added staff with phones
--	7.05.5185
create proc		dbo.prStaff_GetOnDuty
(
	@idUnit		smallint			-- null=any
,	@idLvl		tinyint				-- null=any, 1=Yel, 2=Ora, 4=Grn
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUser, idLvl, sStfID, sStaff, bDuty, dtDue
--	select	distinct	u.idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.tb_User	u	with (nolock)
--		join	dbo.tbDvc	n	with (nolock)	on	n.idUser	= u.idUser	and	n.idDvcType <> 1	and	n.bActive > 0	--	any active device but a badge
		where	u.bActive > 0		and	u.bDuty > 0								--	active and ON-duty
		and		(@idLvl is null		or	u.idLvl	= @idLvl)
		and		(@idUnit is null	or	u.idUser	in	(select idUser from dbo.tb_UserUnit with (nolock) where idUnit = @idUnit)
									and	u.idUser	in	(select idUser from dbo.tbDvc with (nolock) where idDvcType <> 1 and bActive > 0))
--	-								and	n.idDvc		in	(select idDvc from dbo.tbDvcUnit with (nolock) where idUnit = @idUnit)
		order	by	sStaff
end
go
grant	execute				on dbo.prStaff_GetOnDuty			to [rWriter]
--grant	execute				on dbo.prStaff_GetOnDuty			to [rReader]
go
--	----------------------------------------------------------------------------
--	<20,tbEvent>
--	7.06.8797	+ .utEvent
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent') and name = 'utEvent')
--	and	not	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdEvent_UTC')
begin
	begin tran
		alter table	dbo.tbEvent	add
			utEvent		datetime		not null	-- auto: UTC date-time
				constraint	tdEvent_UTC		default( getutcdate( ) )

		exec( 'update	dbo.tbEvent		set	utEvent =	dtEvent' )
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_DvcSrc')
	alter table	dbo.tbEvent	drop	constraint	fkEvent_DvcSrc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_DvcDst')
	alter table	dbo.tbEvent	drop	constraint	fkEvent_DvcDst
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_StnSrc')
	alter table	dbo.tbEvent	drop	constraint	fkEvent_StnSrc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_StnDst')
	alter table	dbo.tbEvent	drop	constraint	fkEvent_StnDst
go
--	----------------------------------------------------------------------------
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent') and name = 'idSrcDvc')
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent') and name = 'idLogType')
begin
	begin tran
		exec sp_rename 'tbEvent.idLogType',	'idType',	'column'
		exec sp_rename 'tbEvent.idSrcDvc',	'idSrcStn',	'column'
		exec sp_rename 'tbEvent.idDstDvc',	'idDstStn',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	<10,tbEvent>
--	7.06.8802	* fkEvent_LogType -> fkEvent_Type
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_Type')
		alter table	dbo.tbEvent		add
			constraint	fkEvent_Type	foreign key	(idType)	references	tb_LogType
go
--	----------------------------------------------------------------------------
--	<10,tbEvent>
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_StnSrc')
		alter table	dbo.tbEvent		add
			constraint	fkEvent_StnSrc	foreign key	(idSrcStn)	references	tbCfgStn
go
--	----------------------------------------------------------------------------
--	<10,tbEvent>
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEvent_StnSrc')
		alter table	dbo.tbEvent		add
			constraint	fkEvent_StnDst	foreign key	(idDstStn)	references	tbCfgStn
go
--	----------------------------------------------------------------------------
--	System activity log
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8797	+ .utEvent
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				* ?Dvc -> ?Stn
--	7.06.8139	+ sRoomBed, sQnSrcDvc, sQnDstDvc
--	7.06.8122	+ .iHash
--	7.06.5487	+ .tiFlags
--	7.05.5066	* .c*Sys,.ti*GID,.ti*JID,.ti*RID -> .s*SGJR
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.02	* .tElapsed -> .tOrigin
--	6.05	+ (nolock)
--			* 'e.'idEvent (now that tbDevice.idEvent exists)
--	6.04	+ .idRoom, .sRoom, .cBed
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.00	tbDefDevice -> tbDevice (FKs)
--			tbDefType -> tbEvType (fkEvent_DefType -> fkEvent_EvType)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	5.01	encryption added
--			src + dst devices
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	3.01
--	2.01	.idRoom -> .idDevice (FK changed also)
--	1.09	+ .id|sType
--			+ .dEvent,.tEvent,.tiHH
--	1.03
alter view		dbo.vwEvent
	with encryption
as
--select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, dtEvent, dEvent, tEvent, tiHH
select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, utEvent, dtEvent, dEvent, tEvent, tiHH
	,	idCmd, iHash, tiBtn,	e.idUnit,	e.idRoom, e.tiBed,	r.sStn as sRoom, b.cBed
	,	r.sStn + case when e.tiBed is null then '' else ' : ' + b.cBed end	as	sRoomBed
	,	e.idSrcStn, s.sSGJR as sSrcSGJR, s.cStn as cSrcStn, s.sStn as sSrcStn, s.sQnStn as sQnSrcStn
	,	e.idDstStn, d.sSGJR as sDstSGJR, d.cStn as cDstStn, d.sStn as sDstStn, d.sQnStn as sQnDstStn
--	,	e.idSrcDvc as idSrcStn, s.sSGJR as sSrcSGJR, s.cStn as cSrcStn, s.sStn as sSrcStn, s.sQnStn as sQnSrcStn
--	,	e.idDstDvc as idDstStn, d.sSGJR as sDstSGJR, d.cStn as cDstStn, d.sStn as sDstStn, d.sQnStn as sQnDstStn
--	,	e.idLogType, t.sLogType, e.idCall, c.sCall, e.sInfo, e.tiFlags
	,	e.idType, t.sType, e.idCall, c.sCall, e.sInfo, e.tiFlags
	from		dbo.tbEvent		e	with (nolock)
	left join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
--	left join	dbo.tb_LogType	t	with (nolock)	on	t.idLogType	= e.idLogType
	left join	dbo.tb_LogType	t	with (nolock)	on	t.idType	= e.idType
	left join	dbo.vwCfgStn	s	with (nolock)	on	s.idStn		= e.idSrcStn	--	Dvc
	left join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= e.idDstStn	--	Dvc
	left join	dbo.tbCfgStn	r	with (nolock)	on	r.idStn		= e.idRoom
go
--	----------------------------------------------------------------------------
--	Event statistics by hour
--	6.05	+ (nolock)
--	6.04
alter view		dbo.vwEvent_S
	with encryption
as
select	dEvent
	,	min(case when tiHH = 00 then idEvent else null end)	as	idEvent00
	,	min(case when tiHH = 01 then idEvent else null end)	as	idEvent01
	,	min(case when tiHH = 02 then idEvent else null end)	as	idEvent02
	,	min(case when tiHH = 03 then idEvent else null end)	as	idEvent03
	,	min(case when tiHH = 04 then idEvent else null end)	as	idEvent04
	,	min(case when tiHH = 05 then idEvent else null end)	as	idEvent05
	,	min(case when tiHH = 06 then idEvent else null end)	as	idEvent06
	,	min(case when tiHH = 07 then idEvent else null end)	as	idEvent07
	,	min(case when tiHH = 08 then idEvent else null end)	as	idEvent08
	,	min(case when tiHH = 09 then idEvent else null end)	as	idEvent09
	,	min(case when tiHH = 10 then idEvent else null end)	as	idEvent10
	,	min(case when tiHH = 11 then idEvent else null end)	as	idEvent11
	,	min(case when tiHH = 12 then idEvent else null end)	as	idEvent12
	,	min(case when tiHH = 13 then idEvent else null end)	as	idEvent13
	,	min(case when tiHH = 14 then idEvent else null end)	as	idEvent14
	,	min(case when tiHH = 15 then idEvent else null end)	as	idEvent15
	,	min(case when tiHH = 16 then idEvent else null end)	as	idEvent16
	,	min(case when tiHH = 17 then idEvent else null end)	as	idEvent17
	,	min(case when tiHH = 18 then idEvent else null end)	as	idEvent18
	,	min(case when tiHH = 19 then idEvent else null end)	as	idEvent19
	,	min(case when tiHH = 20 then idEvent else null end)	as	idEvent20
	,	min(case when tiHH = 21 then idEvent else null end)	as	idEvent21
	,	min(case when tiHH = 22 then idEvent else null end)	as	idEvent22
	,	min(case when tiHH = 23 then idEvent else null end)	as	idEvent23
	from	dbo.tbEvent_S	with (nolock)
	group	by	dEvent
go
--	----------------------------------------------------------------------------
--	7.06.8796	* xuEventA_SGJRB_Act -> xuEventA_Act_SGJRB
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_A') and name = 'sStaffID')
begin
	begin tran
		if	exists	(select 1 from dbo.sysindexes where name='xuEventA_SGJRB_Act')
			drop index	tbEvent_A.xuEventA_SGJRB_Act

		if	not exists	(select 1 from dbo.sysindexes where name='xuEventA_Act_SGJRB')
			create unique nonclustered index	xuEventA_Act_SGJRB	on	dbo.tbEvent_A ( cSys, tiGID, tiJID, tiRID, tiBtn )	where	bActive > 0		-- + 6.05	--	7.06.6508
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'idEvtVo')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventC_EvtVo')
			alter table	dbo.tbEvent_C	drop	constraint	fkEventC_EvtVo
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventC_EvtSt')
			alter table	dbo.tbEvent_C	drop	constraint	fkEventC_EvtSt

		exec sp_rename 'tbEvent_C.idEvtVo',	'idEvtV',	'column'
		exec sp_rename 'tbEvent_C.idEvtSt',	'idEvtS',	'column'
	commit
end
go
if	not exists	(select 1 from dbo.sysobjects where name='fkEventC_EvtV')
begin
	begin tran
		alter table	dbo.tbEvent_C	add
			constraint	fkEventC_EvtV	foreign key	(idEvtV)	references	tbEvent
		,	constraint	fkEventC_EvtS	foreign key	(idEvtS)	references	tbEvent
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				* ?Dvc -> ?Stn
--				* .sDevice -> .sRoom
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.6031	+ tbEvent_C.idShift, tbEvent_C.dShift
--	7.06.5491	* .sRoomBed: ':' -> ' : '
--	7.06.5483	* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3,	- .idUser
--	7.06.5330	+ tbEvent_C.siBed
--				+ .sRoomBed
--	7.06.5326	+ tbEvent_C.idAssn1|2|3
--	7.05.5065	+ tbEvent_C.idUser
--	7.05.4976	* tbEvent_C:	.cBed -> .tiBed		- .idEvtRn, .tRn, .idEvtCn, .tCn, .idEvtAi, .tAi
--	7.04.4897	* tbEvent_C:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt, .idRn -> .idEvtRn, .idCn -> .idEvtCn, .idAi -> .idEvtAi
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	tbDefLoc -> tbUnit;		.sLoc -> .sUnit
--	7.02	* .idCna -> .idCn, .idAide -> .idAi
--	6.05	+ (nolock)
--	6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbDefDevice -> tbDevice (FKs)
--			tbEvent? -> tbEvent_? (A, C, P, T)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	5.01	+ .cDevice
--	4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--	2.03	+ .tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--	2.02	+ .idRn, .tRn, .idCna, .tCna, .idAide, .tAide (vwEventC, prEvent84_Ins?)
--	2.01	.idRoom -> .idDevice (FK changed also)
--	1.09	+ .id|sType
--	1.03
alter view		dbo.vwEvent_C
	with encryption
as
select	e.idEvent, e.dEvent, e.tEvent, e.tiHH, e.idCall, c.sCall
	,	e.idUnit, u.sUnit,		e.idShift, e.dShift
	,	e.idRoom, r.cStn, r.sStn as sRoom, r.sDial,	e.tiBed, b.cBed, e.siBed
	,	r.sStn + case when e.tiBed is null then '' else ' : ' + b.cBed end	as	sRoomBed
	,	e.idEvtV, e.tVoice,		e.idEvtS, e.tStaff
	,	e.idUser1,  a1.idLvl as idLvl1,  a1.sStfID as sStfID1,  a1.sStaff as sStaff1,  a1.bDuty as bDuty1,  a1.dtDue as dtDue1
	,	e.idUser2,  a2.idLvl as idLvl2,  a2.sStfID as sStfID2,  a2.sStaff as sStaff2,  a2.bDuty as bDuty2,  a2.dtDue as dtDue2
	,	e.idUser3,  a3.idLvl as idLvl3,  a3.sStfID as sStfID3,  a3.sStaff as sStaff3,  a3.bDuty as bDuty3,  a3.dtDue as dtDue3
	from		dbo.tbEvent_C	e	with (nolock)
	join		dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
	join		dbo.tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
	join		dbo.tbCfgStn	r	with (nolock)	on	r.idStn		= e.idRoom
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
	left join	dbo.tb_User		a1	with (nolock)	on	a1.idUser	= e.idUser1
	left join	dbo.tb_User		a2	with (nolock)	on	a2.idUser	= e.idUser2
	left join	dbo.tb_User		a3	with (nolock)	on	a3.idUser	= e.idUser3
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_D') and name = 'idEvntP')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventD_EvntP')
			alter table	dbo.tbEvent_D	drop	constraint	fkEventD_EvntP
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventD_EvntS')
			alter table	dbo.tbEvent_D	drop	constraint	fkEventD_EvntS
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventD_EvntD')
			alter table	dbo.tbEvent_D	drop	constraint	fkEventD_EvntD

		exec sp_rename 'tbEvent_D.idEvntP',	'idEvtP',	'column'
		exec sp_rename 'tbEvent_D.idEvntS',	'idEvtS',	'column'
		exec sp_rename 'tbEvent_D.idEvntD',	'idEvtD',	'column'
	commit
end
go
if	not exists	(select 1 from dbo.sysobjects where name='fkEventD_EvtP')
begin
	begin tran
		alter table	dbo.tbEvent_D	add
			constraint	fkEventD_EvtP	foreign key	(idEvtP)	references	tbEvent
		,	constraint	fkEventD_EvtS	foreign key	(idEvtS)	references	tbEvent
		,	constraint	fkEventD_EvtD	foreign key	(idEvtD)	references	tbEvent
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				* ?Dvc -> ?Stn
--				* .sDevice -> .sRoom
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
	,	e.idRoom, r.cStn, r.sStn as sRoom, r.sDial,	e.tiBed, b.cBed, e.siBed
	,	r.sStn + case when e.tiBed is null then '' else ' : ' + b.cBed end	as	sRoomBed
	,	e.idEvtP, e.tWaitP, e.tRoomP,	p.idCall	as	idCallP
	,	e.idEvtS, e.tWaitS, e.tRoomS,	s.idCall	as	idCallS
	,	e.idEvtD, e.tWaitD, e.tRoomD,	d.idCall	as	idCallD
	from	dbo.tbEvent_D	e	with (nolock)
	join	dbo.tbEvent		ee	with (nolock)	on	ee.idEvent	= e.idEvent
	join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
	join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
	join	dbo.tbCfgStn	r	with (nolock)	on	r.idStn		= e.idRoom
left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
left join	dbo.tbEvent		p	with (nolock)	on	p.idEvent	= e.idEvtP
left join	dbo.vwEvent		s	with (nolock)	on	s.idEvent	= e.idEvtS
left join	dbo.vwEvent		d	with (nolock)	on	d.idEvent	= e.idEvtD
go
--	----------------------------------------------------------------------------
--	Finds a doctor by name and inserts if necessary (not found)
--	7.06.7279	* optimized logging
--	7.06.7222	+ quotes in trace
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prDoctor_GetIns
(
	@sDoctor	varchar( 16 )		-- full name (HL7)

,	@idDoctor	int out				-- output
)
	with encryption
as
begin
	declare		@s		varchar( 255 )

	set	nocount	on

	if	0 < len( @sDoctor )
	begin
		select	@idDoctor= idDoctor
			from	dbo.tbDoctor	with (nolock)
			where	sDoctor = @sDoctor	and	bActive > 0

		if	@idDoctor is null
		begin
			begin	tran
				insert	dbo.tbDoctor	(  sDoctor )
						values			( @sDoctor )
				select	@idDoctor=	scope_identity( )

				select	@s =	'Doc_I( ''' + isnull(@sDoctor,'?') + ''' )=' + cast(@idDoctor as varchar)
				exec	dbo.pr_Log_Ins	44, null, null, @s
			commit
		end
	end
end
go
--	----------------------------------------------------------------------------
--	Updates a doctor record
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	6.05		* tracing
--	6.04
alter proc		dbo.prDoctor_Upd
(
	@idDoctor	int out				-- output
,	@sDoctor	varchar( 16 )		-- full name (HL7)
,	@bActive	bit
)
	with encryption
as
begin
	declare		@s		varchar( 255 )

	set	nocount	on

	select	@s =	'Doc_U( [' + isnull(cast(@idDoctor as varchar),'?') +
					'], ''' + isnull(@sDoctor,'?') + ''', a=' + cast(@bActive as varchar) + ' )'

	begin	tran
		update	dbo.tbDoctor	set	sDoctor =	@sDoctor,	bActive =	@bActive,	dtUpdated=	getdate( )
			where	idDoctor = @idDoctor

		exec	dbo.pr_Log_Ins	44, null, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbPatient') and name = 'cGender')
begin
	begin tran
		if	exists	(select 1 from dbo.sysindexes where name='xuPatient_PatId')
			drop index	tbPatient.xuPatient_PatId

		exec sp_rename 'tbPatient.cGender',	'cGndr',	'column'
		exec sp_rename 'tbPatient.sPatId',	'sPatID',	'column'
/*	commit
end
g o
if	not exists	(select 1 from dbo.sysindexes where name='xuPatient_PatID')
begin
	begin tran
*/		create unique nonclustered index	xuPatient_PatID	on	dbo.tbPatient ( sPatID )	where	sPatID is not null		-- + 7.06.8642
	commit
end
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
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
--			* @cGndr null?
--			+ @sDoctor
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prPatient_GetIns
(
	@sPatient	varchar( 16 )		-- full name (HL7)
,	@cGndr		char( 1 )
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

	if	@cGndr is null	or	ascii(@cGndr) = 0xFF
		select	@cGndr=	'U'

	if	@sPatient = 'EMPTY'													--	.7222	treat 'EMPTY' as 'no patient'
		select	@sPatient=	null

	if	0 < len( @sPatient )
	begin
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

		select	@idPatient=	idPatient,	@cGen= cGndr,		@sInf= sInfo,	@idDoc= idDoctor	--, @sNot= sNote
			from	dbo.tbPatient	with (nolock)
			where	sPatient = @sPatient	and	bActive > 0

		begin	tran

			if	@idPatient is null											--	no active patient with given name found
			begin
				insert	dbo.tbPatient	(  sPatient,  cGndr,  sInfo,  idDoctor )	--,  sNote
						values			( @sPatient, @cGndr, @sInfo, @idDoctor )	--, @sNote
				select	@idPatient=	scope_identity( )

				select	@s =	'Pat_I( ' + isnull(@cGndr,'?') + ': ' + isnull(@sPatient,'?')
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
				if	@cGen <> @cGndr		select	@s =	@s + ' g=' + isnull(@cGndr,'?')
				if	@sInf <> @sInfo		select	@s =	@s + ' i=''' + isnull(@sInfo,'?') + ''''
		--		if	@sNot <> @sNote		select	@s =	@s + ' n="' + isnull(@sNote,'?') + '"'
				if	@idDoc <> @idDoctor	select	@s =	@s + ' d=' + isnull(cast(@idDoctor as varchar),'?') + '|' + isnull(@sDoctor,'?')

				if	0 < len( @s )											--	smth has changed
				begin
					update	dbo.tbPatient	set	cGndr =	@cGndr,	sInfo=	@sInfo,	idDoctor =	@idDoctor,	dtUpdated=	getdate( )	--, sNote= @sNote
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
--	Inserts or updates a bed definition
--	7.06.7279	* optimized logging
--	7.06.6284	- tbPatient.idRoom, .tiBed
--	7.06.5939	- tbRoomBed.cBed
--	7.06.5890	+ update tbRoomBed.cBed
--	7.06.5409	* log .siBed
--	7.06.5354	+ @siBed
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--				* @tiIdx -> @tiBed
--	6.05
alter proc		dbo.prCfgBed_InsUpd
(
	@tiBed		tinyint				-- bed-index
,	@cBed		char( 1 )			-- bed-name
,	@cDial		char( 1 )			-- dialable number (digits only)
,	@siBed		smallint			-- bed-flag (bit index)
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s= 'Bed_IU( ' + isnull(cast(@tiBed as varchar), '?') +
				', ''' + isnull(@cBed, '?') + ''', #' + isnull(@cDial, '?') + ', f=' + isnull(cast(@siBed as varchar), '?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgBed where tiBed = @tiBed)
		begin
			update	dbo.tbCfgBed	set	cBed =	@cBed,	cDial=	@cDial,	dtUpdated=	getdate( )
				where	tiBed = @tiBed

			select	@s =	@s + ' *'
		end
		else
		begin
			insert	dbo.tbCfgBed	(  tiBed,  cBed,  cDial,  siBed )
					values			( @tiBed, @cBed, @cDial, @siBed )

			select	@s =	@s + ' +'
		end

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed (in response to HL7 notification via cmd x44)
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
		from	dbo.tbPatient	with (nolock)
		where	idPatient = @idPatient

	select	@idRoom =	idRoom,		@sRoom =	sRoom
		from	dbo.vwRoom		with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	bActive > 0		--	and	tiRID = @tiRID

	if	@idPatient is null
		select	@s =	'Pat_C( '
	else
		select	@s =	'Pat_L( '

	select	@s =	@s + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) +	--	'-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					':' + isnull(cast(@tiBed as varchar),'?') + ', ' + isnull(cast(@idRoom as varchar),'?')
	if	0 < len( @sRoom )
		select	@s =	@s + '|' + @sRoom

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
		and		exists	(select 1 from dbo.tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
		select	@tiBed =	0xFF
	else
	if	@tiBed > 9															-- no match for bed
		or		@idRoom is not null
		and	not	exists	(select 1 from dbo.tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
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
				update	dbo.tbRoomBed	set		dtUpdated=	@dt,	idPatient=	null
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
			update	dbo.tbRoomBed	set		dtUpdated=	@dt,	idPatient=	null
				where	idPatient = @idPatient
				and	(	idRoom <> @idRoom	or	tiBed <> @tiBed	)

			-- place given patient into given room-bed (if he's not there already - only once)
			update	dbo.tbRoomBed	set		dtUpdated=	@dt,	idPatient=	@idPatient
				where	idRoom = @idRoom	and	tiBed = @tiBed
				and	(	idPatient is null	or	idPatient <> @idPatient	)
		end
		else	-- clear given room-bed
			update	dbo.tbRoomBed	set		dtUpdated=	@dt,	idPatient=	null
				where	idRoom = @idRoom	and	tiBed = @tiBed
				and		idPatient is not null

	commit
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	7.06.8810	+ .sUnit
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
select	r.idUnit, r.sUnit,	rb.idRoom, r.cStn, r.sRoom, r.sQnRoom,		d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, b.cBed
	,	rb.idEvent,	rb.tiSvc, rb.tiIbed,	p.idPatient, p.sPatient, p.cGndr, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idUser1,  a1.idLvl as idLvl1,  a1.sStfID as sStfId1,  a1.sStaff as sStaff1,  a1.bDuty as bDuty1,  a1.dtDue as dtDue1
	,	rb.idUser2,  a2.idLvl as idLvl2,  a2.sStfID as sStfId2,  a2.sStaff as sStaff2,  a2.bDuty as bDuty2,  a2.dtDue as dtDue2
	,	rb.idUser3,  a3.idLvl as idLvl3,  a3.sStfID as sStfId3,  a3.sStaff as sStaff3,  a3.bDuty as bDuty3,  a3.dtDue as dtDue3
	,	r.idUserG,  r.idLvlG,  r.sStfIdG,  r.sStaffG,  r.bDutyG,  r.dtDueG
	,	r.idUserO,  r.idLvlO,  r.sStfIdO,  r.sStaffO,  r.bDutyO,  r.dtDueO
	,	r.idUserY,  r.idLvlY,  r.sStfIdY,  r.sStaffY,  r.bDutyY,  r.dtDueY
	,	rb.dtUpdated
	from		dbo.tbRoomBed	rb	with (nolock)
	join		dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= rb.idRoom		and	d.bActive > 0
	join		dbo.vwRoom		r	with (nolock)	on	r.idRoom	= rb.idRoom
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= rb.tiBed		---	and	b.bActive > 0	--	no need
	left join	dbo.tbPatient	p	with (nolock)	on	p.idPatient	= rb.idPatient	--	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed
	left join	dbo.tbDoctor	dc	with (nolock)	on	dc.idDoctor	= p.idDoctor
	left join	dbo.vwStaff		a1	with (nolock)	on	a1.idUser	= rb.idUser1
	left join	dbo.vwStaff		a2	with (nolock)	on	a2.idUser	= rb.idUser2
	left join	dbo.vwStaff		a3	with (nolock)	on	a3.idUser	= rb.idUser3
go
--	----------------------------------------------------------------------------
--	Patients
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.6284	- tbPatient.idRoom, .tiBed
--	7.05.5127
alter view		dbo.vwPatient
	with encryption
as
select	p.idPatient, p.sPatient, p.cGndr, p.sInfo, p.sNote
	,	p.idDoctor, d.sDoctor
	,	rb.idUnit,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed,		rb.cSys, rb.tiGID, rb.tiJID, rb.tiRID
	,	p.bActive, p.dtCreated, p.dtUpdated
	from		dbo.tbPatient	p	with (nolock)
	left join	dbo.vwRoomBed	rb	with (nolock)	on	p.idPatient	= rb.idPatient	--	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed
	left join	dbo.tbDoctor	d	with (nolock)	on	d.idDoctor	= p.idDoctor
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
select	e.idEvent, e.dtEvent,	e.cSys, e.tiGID, e.tiJID, e.tiRID, e.tiBtn
	,	d.idStn, d.sStn, d.sQnStn, d.tiStype, d.sSGJR + ' #' + right('0' + cast(e.tiBtn as varchar), 2)	as	sSGJRB
	,	rm.idUnit,	e.idRoom, r.cStn, r.sStn as sRoom /*, r.sQnDvc as sQnRoom*/,	r.sDial,	e.tiBed, b.cBed, b.cDial
	,	r.sStn + case when e.tiBed is null or e.tiBed = 0xFF then '' else ' : ' + b.cBed end	as	sRoomBed
	,	e.idCall, c.siIdx, c.sCall, p.tiColor, p.tiShelf, p.siFlags, p.tiSpec, p.iFilter, p.tiDome, cd.tiPrism, p.tiTone, p.tiIntTn
	,	e.bActive, e.bAudio,	~cast( ((e.siPri & 0x0400) / 0x0400) as bit )	as bAnswered
	,	e.tiSvc, cast( getdate( ) - e.dtEvent as time(3) )	as	tElapsed,	e.dtExpires
	,	e.tiCvrg0, e.tiCvrg1, e.tiCvrg2, e.tiCvrg3, e.tiCvrg4, e.tiCvrg5, e.tiCvrg6, e.tiCvrg7
	,	rb.idPatient, rb.sPatient, rb.cGndr, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
	from		tbEvent_A	e	with (nolock)
	left join	vwCfgStn	d	with (nolock)	on	d.cSys		= e.cSys	and	d.tiGID = e.tiGID	and	d.tiJID = e.tiJID	and	d.tiRID = e.tiRID	and	d.bActive > 0
	left join	vwCfgStn	r	with (nolock)	on	r.idStn		= e.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom	= e.idRoom
	left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom	= e.idRoom	and	( rb.tiBed = e.tiBed	or	(e.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
	left join	tbCall		c	with (nolock)	on	c.idCall	= e.idCall
	left join	tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
	left join	tbCfgDome	cd	with (nolock)	on	cd.tiDome	= p.tiDome
	left join	tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
go
--	----------------------------------------------------------------------------
--	Returns notifiable (everyting except presence) active call properties
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
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
		,	idPatient, sPatient, cGndr, sInfo, sNote, idDoctor, sDoctor
		from	dbo.vwEvent_A	with (nolock)
		where	(idEvent = @idEvent		or	@idEvent is null)
		and		siFlags & 0x1000 = 0										--	not presence	.8417
--		and		(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
end
go
--	----------------------------------------------------------------------------
--	Returns active call, filtered according to args
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
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
		,	idStn, idRoom, tiBed, sRoomBed	--, sDevice, sQnDevice, sRoom, cBed
		,	siIdx, sCall, tiColor, tiShelf
		,	tElapsed, bActive, bAnswered, bAudio
		from	vwEvent_A	with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
		and		(@bVisible > 0		or	tiShelf > 0)
		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
					from	dbo.tb_RoleUnit	ru	with (nolock)
					join	dbo.tb_UserRole	ur	with (nolock)	on	ur.idRole	= ru.idRole		and	ur.idUser	= @idUser))
		order by	siIdx desc, tElapsed
end
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idStn, sStn, sQnStn, tiStype, sSGJRB
		,	idUnit,	idRoom, cStn, sRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, tiColor, tiShelf, siFlags, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiIntTn
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGndr, sInfo, sNote, idDoctor, sDoctor
		from	dbo.vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0		and	idUnit = @idUnit	--	and	tiLvl & 0x80 = 0
		and		( @iFilter = 0	or	iFilter & @iFilter <> 0 )
		and		dbo.fnEventA_GetByMaster( @idMaster, idRoom, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given room
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idStn, sStn, sQnStn, tiStype, sSGJRB
		,	idUnit,	idRoom, cStn, sRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, tiColor, tiShelf, siFlags, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiIntTn
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGndr, sInfo, sNote, idDoctor, sDoctor
		from	dbo.vwEvent_A	with (nolock)
		where	bActive > 0			and	( tiShelf > 0	or	@bPrsnc > 0	and	siFlags & 0x1000 > 0 )
		and		idRoom = @idRoom	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
		and		( @iFilter = 0	or	iFilter & @iFilter <> 0 )
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
		from	dbo.vwEvent_A	with (nolock)
		where	bActive > 0
		and		idRoom = @idRoom	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
		and		tiPrism & @tiPrism > 0
		and		dbo.fnEventA_GetByMaster( @idMaster, idRoom, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	tiDome desc
go
--	----------------------------------------------------------------------------
--	Removes expired calls
--	7.06.6297	* optimized
--	7.06.6226	* optimized
--	7.06.5618	* optimized
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
	declare		@dt			datetime

	set	nocount	on

	exec	dbo.pr_Module_Act	1

	select	@dt =	getdate( )												-- mark starting time

	begin	tran

		update	r	set	r.idEvent =		null								-- reset tbRoom.idEvent		v.7.02
			from	dbo.tbRoom		r
			join	dbo.tbEvent_A	e	on	e.idEvent	= r.idEvent
			where	e.dtExpires < @dt

		update	rb	set	rb.idEvent =	null								-- reset tbRoomBed.idEvent	v.7.02
			from	dbo.tbRoomBed	rb
			join	dbo.tbEvent_A	e	on	e.idEvent	= rb.idEvent
			where	e.dtExpires < @dt

		delete	from	dbo.tbEvent_A	where	dtExpires < @dt				-- remove expired calls

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8795	* prDevice_InsUpd	-> prCfgStn_InsUpd
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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

,	@sSrcStn	varchar( 16 )		-- source device name
,	@cDstSys	char( 1 )			-- destination system
,	@tiDstGID	tinyint				-- destination G-ID - gateway
,	@tiDstJID	tinyint				-- destination J-ID - J-bus
,	@tiDstRID	tinyint				-- destination R-ID - R-bus
,	@sDstStn	varchar( 16 )		-- destination device name
,	@sInfo		varchar( 32 )		-- info text

,	@idUnit		smallint	out		-- active unit ID
,	@idRoom		smallint	out		-- room ID
,	@idEvent	int			out		-- output: inserted idEvent
,	@idSrcStn	smallint	out		-- output: found/inserted source device
,	@idDstStn	smallint	out		-- output: found/inserted destination device

--,	@idLogType	tinyint		= null	-- type look-up FK (marks significant events only)
,	@idType		tinyint		= null	-- type look-up FK (marks significant events only)
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
		,		@cStn		char( 1 )
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
		,	@cStn =		case when @idCmd = 0x83 then 'G' else '?' end

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Evt_I( ' + isnull(cast(convert(varchar, convert(varbinary(1), @idCmd), 1) as varchar),'?') +	-- ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') +
					' #' + isnull(cast(@tiBtn as varchar),'?') + ','
	if	@iAID <> 0	or	@tiStype > 0										--	7.06.7837
		select	@s =	@s + ' ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?')
	select	@s =	@s + ' ''' + isnull(@sSrcStn,'?') + ''''
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
		not exists	(select 1 from dbo.tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)	)
	begin
		select	@idUnit =	null											-- suppress
		if	@tiSrcGID > 0
			select	@p =	@p + ' !u'										-- invalid unit
	end

	begin	tran

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins1'

		if	@tiBed is not null												-- mark a bed in active use
			update	dbo.tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )
				where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)					-- audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiRID =	@tiSrcRID,	@sDvc =		@sSrcStn,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcStn=	@sDstStn
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiRID,		@sDstStn=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins2'

		exec		dbo.prCfgStn_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID,  @tiStype,  @cStn, @sSrcStn, null, @idSrcStn out

		if	@tiDstGID > 0
			exec	dbo.prCfgStn_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cStn, @sDstStn, null, @idDstStn out

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins3'

--		if	@idCmd <> 0x84	or	@idLogType <> 194							-- skip healing 84s
		if	@idType <> 194												-- skip healing 84s
		begin
			insert	dbo.tbEvent	(  idCmd,  iHash,  sInfo,  idType,  idCall,  tiBtn,  tiBed,  idUnit
								,	cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  idSrcStn
								,	cDstSys,  tiDstGID,  tiDstJID,  tiDstRID,  idDstStn
								,	dtEvent,  dEvent,   tEvent,   tiHH )
					values		( @idCmd, @iHash, @sInfo, @idType, @idCall, @tiBtn, @tiBed, @idUnit
								,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @idSrcStn
								,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @idDstStn
								,	@dtEvent, @dtEvent, @dtEvent, @tiHH )
			select	@idEvent =	scope_identity( )

			if	@tiLen > 0	and	@vbCmd is not null
				insert	dbo.tbEvent_B	(  idEvent,  tiLen,  vbCmd )		--	7.06.5562
						values			( @idEvent, @tiLen, @vbCmd )

			if	len(@p) > 0
			begin
				select	@s =	@s + ' ' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins4'

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcStn as varchar),'?') + ' dst=' + isnull(cast(@idDstStn as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
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
				from	dbo.tbCfgPri	p	with (nolock)
				join	dbo.tbCall		c	with (nolock)	on	c.siIdx	= p.siIdx
				where	c.idCall = @idCall

			if	@idCmd = 0x84	and											--	7.06.8500	0x0700=Doc(..0111..), 0x0500=Stf(..0101..), 0x0100=None(..0001..)
				(	@siFlags & 0x0500 = 0x0500	or	@siFlags & 0x0300 = 0x0100	)		--	@siFlags & 0x0500 = 0x0500 skips None
			begin
				select	@idParent=	idEvent,	@dtParent=	dtEvent
					from	dbo.tbEvent_A	ea	with (nolock)
					join	dbo.tbCfgPri	cp	with (nolock)	on	cp.siIdx = ea.siIdx
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		bActive > 0			and	cp.siFlags & 0x0700 = 0x0300	--	7.06.8343	0x0300=Pat(..0011..)

				if	@idParent is null
					select	@idParent=	ep.idEvent,	@dtParent=	ep.dtEvent
						from	dbo.tbEvent_A	ea	with (nolock)
						join	dbo.tbEvent		eo	with (nolock)	on	eo.idEvent	= ea.idEvent
						join	dbo.tbEvent		ep	with (nolock)	on	ep.idEvent	= eo.idParent
						where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	ea.tiBtn = @tiBtn	and	bActive > 0
						and		ea.idCall = @idCall
			end
			else
				select	@idParent=	idEvent,	@dtParent=	dtEvent			--	7.04.4968
					from	dbo.tbEvent_A	with (nolock)
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		( bActive > 0		or	@idCmd < 0x80	or	@idCmd = 0x8D )		--	7.05.5095, .5211
					and		( tiBtn = @tiBtn	or	@tiBtn is null )
					and		( idCall = @idCall	or	@idCall is null		or	@idCall0 is not null	and	idCall = @idCall0 )

			select	@idRoom =	idRoom										-- get room
				from	dbo.vwRoom	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	bActive > 0		--	and	tiRID = 0

--			select	@s=	'Evt_i2: prnt=' + isnull(cast(@idParent as varchar),'?') + ' room=' + isnull(cast(@idRoom as varchar),'?')
--			exec	pr_Log_Ins	0, null, null, @s

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins6'

			if	@idParent > 0
				update	dbo.tbEvent		set	idParent =	@idParent,	idRoom =	@idRoom,	tParent =	dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	dbo.tbEvent		set	idParent =	@idEvent,	idRoom =	@idRoom,	tParent =	'0:0:0'
					where	idEvent = @idEvent

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins7'

			if	@idUnit > 0		and	@idRoom > 0								--	7.02	7.05.5205
				update	dbo.tbRoom		set	idUnit =	@idUnit
					where	idRoom = @idRoom

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins8'
		end

		if	@idEvent > 0													-- update event statistics
		begin
			select	@idParent=	null
			select	@idParent=	idEvent
				from	dbo.tbEvent_S	with (nolock)
				where	dEvent = cast(@dtEvent as date)		and	tiHH = @tiHH

			if	@idParent	is null
				insert	dbo.tbEvent_S	(   dEvent,  tiHH,  idEvent )
						values			( @dtEvent, @tiHH, @idEvent )
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins9'

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8797	* adjusted for IDENT_SEED (1 -> 0x80000000 == -2147483648) - only for new installs
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8122	+ call [prEvent_Ins] to insert refs to important audit events for xrSysActDtl
--	7.06.7228	* fix Code=0x80131904 Err=2627 Lvl=14 St=1 Prc=pr_Log_Ins Ln=72
--					(Violation of PRIMARY KEY constraint 'xp_Log_S') on concurrent startup of multiple modules
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
	@idType		tinyint
,	@idUser		int						--	context user
,	@idOper		int						--	"operand" user - ignored now
,	@sLog		varchar( 512 )
,	@idModule	tinyint			=	1	--	default is J798?db
,	@idSrcStn	int				=	0	--	source device
--,	@idLog		int out
)
	with encryption
as
begin
	declare		@dt			datetime
			,	@dd			date
			,	@hh			tinyint
			,	@tiLvl		tinyint
			,	@tiCat		tinyint
			,	@idLog		int
			,	@idOrg		int
			,	@idEvent	int
			,	@idUnit		smallint
			,	@idRoom		smallint
	--		,	@idSrcStn	smallint
			,	@idDstStn	smallint
			,	@idCmd		tinyint
			,	@cSys		char( 1 )
			,	@tiGID		tinyint
			,	@tiJID		tinyint
			,	@tiRID		tinyint
			,	@sStn		varchar( 16 )

	set	nocount	on

	select	@tiLvl =	tiLvl,		@tiCat =	tiCat,		@idCmd =	0,			@sStn =		null
		,	@cSys =		null,		@tiGID =	null,		@tiJID =	null,		@tiRID =	null
		,	@dt =	getdate( ),		@dd =	getdate( ),		@hh =	datepart( hh, getdate( ) )
		,	@idOrg =	0x80000000,	@idLog =	0x80000000
		from	dbo.tb_LogType	with (nolock)
		where	idType = @idType

--	set	nocount	off

	if	0 < @tiLvl & 0xC0													-- err (64) + crit (128)
	begin
		select	@idOrg =	idLog											-- get 1st event of the hour
			from	dbo.tb_Log_S	with (nolock)
			where	dLog = @dd	and	tiHH = @hh

--	-	if	0 < @idOrg
		if	0x80000000 < @idOrg
			select	@idLog =	idLog										-- find 1st occurence of "sLog"
				from	dbo.tb_Log		with (nolock)
				where	idLog >= @idOrg
				and		sLog = @sLog
	end

	begin	tran

--	-	if	0 < @tiLvl & 0xC0	and		0 < @idLog							-- same crit/err already happened
		if	0 < @tiLvl & 0xC0	and		0x80000000 < @idLog					-- same crit/err already happened this hour
			update	dbo.tb_Log
				set		tLast=	@dt
					,	tiQty=	case when tiQty < 255 then tiQty + 1 else tiQty end
				where	idLog = @idLog
		else
		begin
			insert	dbo.tb_Log	(  idType,  idModule,  idUser,  sLog, dtLog, dLog, tLog, tiHH, tLast, tiQty )
					values		( @idType, @idModule, @idUser, @sLog, @dt,   @dt,  @dt,  @hh,  @dt,   1 )
			select	@idLog =	scope_identity( )

/*			select	@idOrg =	null										-- update event statistics
			select	@idOrg =	idLog
				from	dbo.tb_Log_S	with (nolock)
				where	dLog = cast(@dt as date)	and	tiHH = @hh

			if	@idOrg	is null
				insert	dbo.tb_Log_S	( dLog,	tiHH, idLog )
						values			( @dt,	@hh, @idLog )
*/
			set transaction isolation level serializable					-- update event statistics
			begin	tran
				if	not	exists( select 1 from dbo.tb_Log_S with (updlock) where dLog = @dd and tiHH = @hh )
					insert	dbo.tb_Log_S	( dLog,	tiHH, idLog )
							values			( @dt,	@hh, @idLog )
			commit
		end

		if	0 < @tiLvl & 0x80												-- increment criticals
			update	dbo.tb_Log_S
				set		siCrt=	siCrt + 1
				where	dLog = @dd	and	tiHH = @hh

		if	0 < @tiLvl & 0x40												-- increment errors
			update	dbo.tb_Log_S
				set		siErr=	siErr + 1
				where	dLog = @dd	and	tiHH = @hh

		if	@idType	between	4  and 40	or									-- wrn,err,crit + all service states
			@idType	between	61 and 64	or									-- install/removal
			@idType	in (70,79,80,81,83,90)	or								-- config, conn, schedules
			@idType	between	100 and 104	or									-- AD
			@idType	between	189 and 190	or									-- GW
			@idType	between	218 and 255										-- user: duty, log-in/out, activity
		begin
			if	0 < @idSrcStn
--			if	@idType	between	189 and 190
			begin
				select	@idCmd =	0x83,	@sStn =		sStn,	@cSys =		cSys
					,	@tiGID =	tiGID,	@tiJID =	tiJID,	@tiRID =	tiRID
					from	dbo.tbCfgStn
					where	idStn = @idSrcStn
			end

			exec	dbo.prEvent_Ins		@idCmd, null, @idLog, null		---	@idCmd, @tiLen, @iHash, @vbCmd
					,	@cSys, @tiGID, @tiJID, @tiRID, @sStn			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
					,	null, null, null, null, null, @sLog				---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
					,	@idUnit out, @idRoom out, @idEvent out, @idSrcStn out, @idDstStn out
					,	@idType			---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .sMachine -> .sHost, @
--				* .sParams -> .sArgs, @
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
,	@sHost		varchar( 32 )
,	@sDesc		varchar( 64 )
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
			,	@idType		tinyint

	set	nocount	on

	select	@idType =	62,		@s =	isnull(@sVersion, '?')

	if	@sHost is not null												-- register
	begin
		if	@sIpAddr is not null
			select	@s =	@s + ', ip=' + @sIpAddr

		select	@idType =	61
			,		@s =	@s + ', ' + isnull(@sHost, '?') + ', ''' + isnull(@sDesc, '?') + ''''	-- + isnull(cast(@bLicense as varchar), '?')

		if	@bLicense is null	or	@bLicense = 0
			select	@s =	@s + ', l=0'
	end

	begin	tran

		if	exists	(select 1 from dbo.tb_Module with (nolock) where idModule = @idModule)
		begin
			if	@sHost is null	--	and	@sIpAddr is null				-- un-register
				update	dbo.tb_Module
					set		sIpAddr =	null,	sHost=	null,	sVersion =	null,	dtStart =	null,	sArgs =	null
					where	idModule = @idModule
			else
				update	dbo.tb_Module
					set		sIpAddr =	@sIpAddr,	sHost=	@sHost,	sVersion =	@sVersion,	sDesc =		@sDesc,		bLicense =	@bLicense
					where	idModule = @idModule
		end
		else
		begin
			insert	dbo.tb_Module	(  idModule,  tiModType,  sModule,  sDesc,  bLicense,  sVersion,  sIpAddr,  sHost )
					values			( @idModule, @tiModType, @sModule, @sDesc, @bLicense, @sVersion, @sIpAddr, @sHost )

			select	@s =	@s + ' +'
		end

		exec	dbo.pr_Log_Ins	@idType, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .sMachine -> .sHost, @
--				* .sParams -> .sArgs, @
--	7.06.8122	+ no need to call [prEvent_Ins] directly
--	7.06.7131	* sInfo( 32 ) -> @sInfo( 64 )
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
,	@sInfo		varchar( 64 )		-- module info, gets logged (e.g. 'J79???? v.M.mm.bbbb @machine/IP-address')
,	@iPID		int					-- Windows PID when running
,	@idType		tinyint				-- type look-up FK (marks significant events only)
,	@sArgs		varchar( 255 )		-- startup arguments/parameters
,	@sIpAddr	varchar( 40 )
,	@sHost		varchar( 32 )
)
	with encryption
as
begin
/*	declare		@idEvent	int
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcStn	smallint
		,		@idDstStn	smallint
*/
	set	nocount	on

	begin	tran

		if	@idType = 38		-- SvcStarted
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),	iPID =	@iPID,	sArgs =	@sArgs,	dtStart =	getdate( ),	sIpAddr =	@sIpAddr,	sHost =	@sHost
				where	idModule = @idModule
		else
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),	iPID =	null,	sArgs =	null,	dtStart =	null
				where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idType, null, null, @sInfo, @idModule

/*		exec	dbo.prEvent_Ins		0, null, null, null		---	@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	null, null, null, null, null, @sInfo	---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcStn out, @idDstStn out
				,	@idType			---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0
*/
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates given module's license bit
--	7.06.8143	* optimized trace
--	7.06.7467	* optimized logic
--	7.06.6345	+ @idModule logging (pr_Log_Ins call)
--	7.06.5598
alter proc		dbo.pr_Module_Lic
(
	@idModule	tinyint
,	@bLicense	bit
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@s =	sModule
		from	dbo.tb_Module	with (nolock)
		where	idModule = @idModule

	select	@s =	'Mod_Lic( ' + right('00' + cast(@idModule as varchar), 3) + '|' + @s + ', ' + isnull(cast(@bLicense as varchar), '?') + ' )'

	begin	tran

		update	dbo.tb_Module	set	bLicense =	@bLicense
			where	idModule = @idModule	and	bLicense <> @bLicense

		if	@@rowcount > 0
			exec	dbo.pr_Log_Ins	63, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Sets given module's logging level
--	7.06.8143	* optimized trace
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

		update	dbo.tb_Module	set	tiLvl=	@tiLvl,		@s =	sModule
			where	idModule = @idModule

		select	@s =	'Mod_SL( ' + right('00' + cast(@idModule as varchar), 3) + '|' + @s + ', l=' + isnull(cast(@tiLvl as varchar), '?') + ' )'

		exec	dbo.pr_Log_Ins	64, @idUser, null, @s, @idFeature

	commit
end
go
--	----------------------------------------------------------------------------
--	Marks a gateway as found or lost (and removes its active calls)
--	7.06.8867	* fix for deferred new GW discovery by 798?cs
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8795	- @sStn	(@sDevice)
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8122	* modified [prEvent_Ins] call
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
,	@idType		tinyint				-- 189=Found, 190=Lost
,	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idStn		smallint

	set	nocount	on

	select	@s =	@cSys + '-' + right('00' + cast(@tiGID as varchar), 3)	-- a new GW may not exist yet (798?cs hasn't processed it yet)

	select	@s =	@s + ' [' + isnull(sStn,'?') + ']',						-- this will not execute in such case
			@idStn =	idStn
		from	dbo.tbCfgStn	with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	--	and	bActive > 0

	begin	tran

		if	@idType = 189													-- found;  activate if inactive
			update	dbo.tbCfgStn	set		bActive= 1
				where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	bActive = 0
		else
	--	if	@idType = 190
		begin
			delete	from	dbo.tbEvent_A
				where	cSys = @cSys	and	tiGID = @tiGID

			select	@s =	@s + ', ' + cast(@@rowcount as varchar) + ' active call(s) cleared'
		end

--	--	exec	dbo.prCfgStn_GetIns		@cSys, @tiGID, 0, 0, 0, null, 'G', @sStn, null, @idStn out

		exec	dbo.pr_Log_Ins	@idType, null, null, @s, @idModule, @idStn

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
--,	@sDevice	varchar( 16 )		-- room name
,	@sStn		varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
,	@sCall		varchar( 16 )		-- call text
,	@sPatient	varchar( 16 )		-- patient name
,	@cGndr		char( 1 )			-- patient gender
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
,	@idType		tinyint		out
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@p			varchar( 16 )
		,		@idParent	int
		,		@idSrcStn	smallint
		,		@idDstStn	smallint
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

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@iExpNrm =	iValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bAudio =	0

	select	@s =	'E84_I( ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') +
					' #' + isnull(cast(@tiBtn as varchar),'?') +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					' ''' + isnull(@sStn,'?') + ''''	-- + isnull(cast(@tiBed as varchar),'?')
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
			from	dbo.tbCfgPri	with (nolock)
			where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew						-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0													-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@siFlags =	siFlags,	@tiShelf =	tiShelf,	@tiSpec =	tiSpec,		@siIdxUg =	siIdxUg
			from	dbo.tbCfgPri	with (nolock)
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
		not exists	(select 1 from dbo.tbUnit with (nolock) where idUnit = @idUnit and bActive > 0))
		select	@idUnit =	null,	@p =	@p + ' !u'						-- invalid unit

	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + ' !b'
	else
		select	@siBed =	siBed	from	dbo.tbCfgBed	with (nolock)	where	tiBed = @tiBed


	if	@tiBed is not null	and	len(@sPatient) > 0							-- only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGndr, @sInfo, @sDoctor, @idPatient out, @idDoctor out
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
		from	dbo.tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0
			and	(siIdx = @siIdxNew	or	siIdx = @siIdxOld)					--	7.06.5855
		---	and	(idCall = @idCall	or	idCall = @idCall0)					--	7.05.4976

	select	@tiSvc =	@tiTmrA * 0x40 + @tiTmrG * 0x10 + @tiTmrO * 0x04 + @tiTmrY
		,	@idType =	case when	@idOrigin is null	then				-- call placed | presense-in
								case when	@siFlags & 0x1000 > 0	then 210	else 191 end	--	7.06.6767	0 < @bPresence	.8380
							when	@siIdxNew = 0		then				-- cancelled | presense-out
								case when	@siFlags & 0x1000 > 0	then 211	else 193 end	--	7.06.6767	0 < @bPresence	.8380
							else											-- escalated | healing
								case when	@idCall0 > 0			then 192	else 194 end	end

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sStn
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcStn out, @idDstStn out
				,	@idType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins03'

		if	@idEvent > 0
		begin
			insert	dbo.tbEvent84	( idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew
								,	tiTmrA,   tiTmrG,   tiTmrO,   tiTmrY,     idPatient,  idDoctor,  iFilter
								,	tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values			( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew
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

		update	dbo.tbRoom	set	idUnit =	@idUnit,	dtUpdated=	@dtEvent	--	7.06.7265
			where	idRoom = @idRoom	and	idUnit <> @idUnit

		if	@siFlags & 0x1000 > 0		--	@bPresence > 0					--	7.06.7265	.8380
			exec	dbo.prRoom_UpdStaff		@idRoom, @siIdxNew, @sStaffG, @sStaffO, @sStaffY	--, @idUnit

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins05'


		if	@idOrigin is null												-- no active origin found	(=> call placed/discovered)
		begin
			update	dbo.tbEvent		set	idOrigin =	@idEvent,	@idSrcStn=	idSrcStn,	@idParent=	idParent
									,	tOrigin =	dateadd(ss,  @siElapsed, '0:0:0')
									,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent)
				where	idEvent = @idEvent

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins06'

			select		@idEvDup =	idEvent,	@siPriOld=	siIdx			-- addressing xuEventA_Active_SGJRB errors	--	7.06.6410
				from	dbo.tbEvent_A	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0

			if	@@rowcount > 0
			begin
				select	@s =	@s + ' dup=' + isnull(cast(@idEvDup as varchar),'?') + '! idx=' + isnull(cast(@siPriOld as varchar),'?')
				exec	dbo.pr_Log_Ins	82, null, null, @s

				--	what to do with current call ??
			end
			else
				insert	dbo.tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
										siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,
										tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
						values			( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
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
					from	dbo.tbRoom	with (nolock)
					where	idRoom = @idRoom

				select	@idShift =	u.idShift								--	7.06.6017
					,	@dShift =	case when sh.tEnd <= sh.tBeg	and	cast(@dtOrigin as time) < sh.tEnd	then	dateadd(dd, -1, @dtOrigin)	else	@dtOrigin	end	--	7.06.6051
					from	dbo.tbUnit	u	with (nolock)
					join	dbo.tbShift	sh	with (nolock)	on	sh.idShift = u.idShift
					where	u.idUnit = @idUnit	and	u.bActive > 0

--				if	@tiLog & 0x04 > 0									--	Debug?
--					exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins08'

				if	@siFlags & 0x0800 > 0		or							-- initial rnd/rmnd		.8380
					@siFlags & 0x0700 = 0x0300								-- clinic-patient	.7864	.8380
					insert	dbo.tbEvent_D	(  idEvent,  idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed,  tiHH )
							values			( @idEvent, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, @tiHH )
				else
				if	@siFlags & 0x0100 = 0									-- non-clinic call	.7864	.8380
				begin
					insert	dbo.tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, idUser1,  tiHH )
							values			( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, @idUser, @tiHH )

					if	@siFlags & 0x1000 = 0								-- not presence		7.06.5665	.8380
						update	c	set	c.idUser1=	rb.idUser1,		c.idUser2=	rb.idUser2,		c.idUser3=	rb.idUser3	--	7.06.5326
							from	dbo.tbEvent_C	c
							join	dbo.tbRoomBed	rb	on	rb.idRoom = @idRoom		and	( rb.tiBed = @tiBed		or	@tiBed is null	and	( rb.tiBed = 0xFF	or	rb.tiBed = 1 ) )
							where	c.idEvent = @idEvent
				end
			end

			select	@idOrigin=	@idEvent
		end

		else																-- active origin found	(=> call healed/escalated/cancelled)
		begin
			update	dbo.tbEvent		set	idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin,	@idParent=	idParent
				where	idEvent = @idEvent

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins09'

			update	dbo.tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	siIdx=	@siIdxNew,	idCall =	@idCall		--	7.06.5855
				where	idEvent = @idOrigin									--	7.05.5065

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins10'

			update	dbo.tbEvent_A	set	tiSvc=	@tiSvc							-- update state for all calls in this room
				where	idRoom = @idRoom									--	7.06.5534

			if	@siFlags & 0x0100 > 0										-- clinic call	.7864	.8380
				and	0 < @siIdxNew	and	@siIdxNew <> @siIdxOld
				and	@siIdxUg is null										-- escalated to last stage
			begin
				if	@siFlags & 0x0700 = 0x0300								-- clinic-patient	.8380
				begin
					update	dbo.tbEvent_D	set	idEvtP =	@idEvent
						where	idEvent = @idParent		and	idEvtP is null

					update	d	set	tWaitP =	tParent
						from	dbo.tbEvent_D	d
						join	dbo.tbEvent		e	with (nolock)	on	e.idEvent	= @idEvent
						where	d.idEvent = @idOrigin	and	tWaitP is null
				end
				else
				if	@siFlags & 0x0700 = 0x0500								-- clinic-staff		.7864	.8380
				begin
					update	tbEvent_D	set	idEvtS =	@idEvent
						where	idEvent = @idParent		and	idEvtS is null

					update	d	set	tWaitS =	cast(e.tParent as datetime) - cast(p.tOrigin as datetime)
						from	dbo.tbEvent_D	d
						join	dbo.tbEvent		e	with (nolock)	on	e.idEvent	= @idEvent
						join	dbo.tbEvent		p	with (nolock)	on	p.idEvent	= d.idEvtS
						where	d.idEvent = @idParent	and	tWaitS is null
				end
				else
				if	@siFlags & 0x0700 = 0x0700								-- clinic-doctor	.7864	.8380
				begin
					update	dbo.tbEvent_D	set	idEvtD =	@idEvent
						where	idEvent = @idParent		and	idEvtD is null

					update	d	set	tWaitD =	cast(e.tParent as datetime) - cast(p.tOrigin as datetime)
						from	dbo.tbEvent_D	d
						join	dbo.tbEvent		e	with (nolock)	on	e.idEvent	= @idEvent
						join	dbo.tbEvent		p	with (nolock)	on	p.idEvent	= d.idEvtD
						where	d.idEvent = @idParent	and	tWaitD is null
				end
			end
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins11'


		if	@siIdxNew = 0													-- call cancelled
		begin
			update	dbo.tbEvent_A	set	tiSvc=	null,	bActive =	0
								,	dtExpires=	dateadd(ss, case when @bAudio = 0 then @iExpNrm else @iExpExt end, @dtEvent)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins12'

			select	@dtOrigin=	tOrigin		--,	@idParent=	idParent
				from	dbo.tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	dbo.tbEvent_C	set	idEvtS =	@idEvent,	tStaff =	@dtOrigin
				where	idEvent = @idOrigin		and	idEvtS is null			-- there should be only one, but just in case - use only 1st one

			if	@siFlags & 0x0800 > 0										-- initial rnd/rmnd		.8395
				delete	from	dbo.tbEvent_D
					where	idEvent = @idOrigin								-- remove incomplete rnd/rmnd
			else
			if	@siFlags & 0x0008 > 0										-- non-initial rnd/rmnd		.8380
				update	d	set	tWaitS =	@dtEvent - o.dtEvent,	idEvtS =	@idEvent
					from	dbo.tbEvent_D	d
					join	dbo.tbEvent		o	with (nolock)	on	o.idEvent	= d.idEvent
					where	d.idEvent = @idOrigin	and	tWaitS is null
			else
			if	@siFlags & 0x0700 = 0x0300									-- clinic-patient	.8380
				update	d	set	tRoomP =	@dtEvent - p.dtEvent
					from	dbo.tbEvent_D	d
					join	dbo.tbEvent		p	with (nolock)	on	p.idEvent	= d.idEvtP
					where	d.idEvent = @idOrigin	and	tRoomP is null
			else
			if	@siFlags & 0x0700 = 0x0500									-- clinic-staff		.8380
				update	d	set	tRoomS =	@dtEvent - p.dtEvent
					from	dbo.tbEvent_D	d				
					join	dbo.tbEvent		p	with (nolock)	on	p.idEvent	= d.idEvtS
					join	dbo.tbEvent		o	with (nolock)	on	o.idParent	= d.idEvent		and	o.idEvent	= @idOrigin
					where	tRoomS is null
			else
			if	@siFlags & 0x0700 = 0x0700									-- clinic-doctor	.8380
				update	d	set	tRoomD =	@dtEvent - p.dtEvent
					from	dbo.tbEvent_D	d
					join	dbo.tbEvent		p	with (nolock)	on	p.idEvent	= d.idEvtD
					join	dbo.tbEvent		o	with (nolock)	on	o.idParent	= d.idEvent		and	o.idEvent	= @idOrigin
					where	tRoomD is null
			else
			if	@siFlags & 0x0100 = 0										-- not a clinic call	.7864	.8380
			begin
				if	@tiSrcRID = 0	and	@tiBtn < 3	and	@tiBed is null		-- BadgeCalls are room-level
					update	dbo.tbRoom	set	tiCall =	tiCall & case when	@tiBtn = 0	then	0xFB		--	0x..1011	G
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
			from	dbo.tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent									-- oldest in recorded order
		---	order	by	siIdx desc, tElapsed desc							-- call may have started before it was recorded

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins15'

		update	dbo.tbRoom	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
			where	idRoom = @idRoom

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins16'

		-- clear room state when there's no 'presence'						--	7.06.5534
		if	@tiSvc is null	or	@tiSvc & 0x30 <> 0x10
			update	dbo.tbRoom	set	idUserG =	null,	sStaffG =	null	where	idRoom = @idRoom
--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins17'
		if	@tiSvc is null	or	@tiSvc & 0x0C <> 0x04
			update	dbo.tbRoom	set	idUserO =	null,	sStaffO =	null	where	idRoom = @idRoom
--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins18'
		if	@tiSvc is null	or	@tiSvc & 0x03 <> 0x01
			update	dbo.tbRoom	set	idUserY =	null,	sStaffY =	null	where	idRoom = @idRoom
--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins19'


		-- set tbRoomBed.idEvent and .tiSvc to highest oldest active call for this room-bed
		declare		cur		cursor fast_forward for
			select	tiBed
				from	dbo.tbRoomBed	with (nolock)
				where	idRoom = @idRoom

		open	cur
		fetch next from	cur	into	@tiBed
		while	@@fetch_status = 0
		begin
			select	@idEvent =	null,	@tiSvc =	null
			select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
				from	dbo.tbEvent_A	ea	with (nolock)
				where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
				order	by	siIdx desc, idEvent								-- oldest in recorded order (clustered) - FASTER, more EFFICIENT
			---	order	by	siIdx desc, tElapsed desc						-- call may have started before it was recorded (thus no .tElapsed!)

			update	dbo.tbRoomBed	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
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
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
	,	e.idSrcStn, d.sStn, e.idRoom, r.sStn as sRoom, r.sDial, e.tiBed, e.idCall, c.sCall, e.idUnit
	,	e84.siPriOld, e84.siPriNew, e84.siIdxOld, e84.siIdxNew, e84.iFilter
	,	~cast( ((e84.siPriNew & 0x0400) / 0x0400) as bit )	as bAnswered
	,	e84.siElapsed, e84.tiPrivacy, e84.tiTmrA, e84.tiTmrG, e84.tiTmrO, e84.tiTmrY
	,	e84.idPatient, p.sPatient, p.cGndr
	,	e84.idDoctor, v.sDoctor, e.sInfo
	,	e84.tiCvrg0, e84.tiCvrg1, e84.tiCvrg2, e84.tiCvrg3, e84.tiCvrg4, e84.tiCvrg5, e84.tiCvrg6, e84.tiCvrg7
	from	tbEvent84	e84
	join	tbEvent		e	on	e.idEvent	= e84.idEvent
	join	tbCall		c	on	c.idCall	= e.idCall
	join	tbCfgStn	d	on	d.idStn		= e.idSrcStn
	join	tbCfgStn	r	on	r.idStn		= e.idRoom
	left join	tbPatient	p	on	p.idPatient	= e84.idPatient
	left join	tbDoctor	v	on	v.idDoctor	= e84.idDoctor
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--				* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
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
,	@sSrcStn	varchar( 16 )		-- source name
,	@sDstStn	varchar( 16 )		-- destination name
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
		,		@idSrcStn	smallint
		,		@idDstStn	smallint
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idCall		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@iExpNrm	int
		,		@idType		tinyint

	set	nocount	on

	select	@iExpNrm =	iValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 9

	select	@idType =	case when	@idCmd = 0x8D	then	199				-- audio quit
							when	@idCmd = 0x8A	then	197				-- audio grant
							when	@idCmd = 0x88	then	196				-- audio busy
							else							195	end			-- audio request

	exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcStn
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstStn, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcStn out, @idDstStn out
				,	@idType, @idCall, @tiBtn, @tiBed	---	, @iAID, @tiStype, @idCall0

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

				update	tbEvent_C	set		idEvtV =	@idEvent,	tVoice =	@dtOrigin
					where	idEvent = @idOrigin		and	idEvtV is null		-- there should be only one, but just in case - use only 1st one
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
			update	dbo.tbEvent
				set		idOrigin =	@idEvent,	tOrigin =	'0:0:0'
					,	idParent =	@idEvent,	tParent =	'0:0:0'	--	7.05.4976
					,	@idDstStn=	idSrcStn,	@dtOrigin=	dtEvent
					,	tiFlags =	@tiFlags
				where	idEvent = @idEvent
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
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
--,	@sDevice	varchar( 16 )		-- room name
,	@sStn		varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
,	@siIdx		smallint			-- call index
,	@sCall		varchar( 16 )		-- call text
,	@sInfo		varchar( 16 )		-- tag message text
,	@idUnit		smallint			-- active unit ID

,	@idEvent	int			out		-- output: idOrigin of input event
,	@idType		tinyint		out
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@idSrcStn	smallint
		,		@idDstStn	smallint
		,		@idCall		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime

	set	nocount	on

	select	@idType =	case when	@tiSvcSet > 0	then	201				-- set svc
							else							203	end			-- clr svc	202	-- set/clr

	exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out

	select	@idOrigin=	idEvent,	@dtOrigin=	dtEvent
		from	tbEvent_A	with (nolock)
		where	cSys = @cDstSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiBtn
			and	idCall = @idCall	and	bActive > 0				--	7.05.4980

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sStn, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcStn out, @idDstStn out
				,	@idType, @idCall, @tiBtn, @tiBed		---	, @iAID, @tiStype, @idCall0

		update	tbEvent		set		idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin
								,	tiFlags =	case when	@tiSvcSet > 0	then	@tiSvcSet	else	@tiSvcClr	end
			where	idEvent = @idEvent

	commit

	select	@idEvent =	@idOrigin		--	7.05.5290	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x98, 0x9A, 0x9E, 0x9C, 0xA4, 0xAD, 0xAF]
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.5487	* optimize
--	7.06.5484	+ @tiBed, @tiBtn	- @tiMulti, @sDevice
--				+ call prPatient_UpdLoc
--	7.05.5205	* prEvent_Ins args
--	7.05.5127	+ @cGender
--	7.05.5074	* prPatient_GetIns:		+ @idDoctor
--	7.03	* fixed call [dbo.prPatient_GetIns] args, re-structured call [dbo.prDoctor_GetIns] call
--	6.05	optimize
--	6.04	now uses prPatient_GetIns, prDoctor_GetIns
--			tbDefPatient -> tbPatient (tbEvent84, prEvent84_Ins, vwEvent84, tbEvent98, prEvent98_Ins, vwEvent98, tbRoomBed, vwRoomBed, prRptCallActDtl)
--	5.01	encryption added
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			[+ @sDial for AF, no: see @sInfo]
--	4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	1.00
alter proc		dbo.prEvent98_Ins
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
,	@tiBed		tinyint				-- bed index
,	@tiBtn		tinyint				-- bed flags (privacy status)
,	@sPatient	varchar( 16 )		-- patient name
,	@cGndr		char( 1 )
,	@sDoctor	varchar( 16 )		-- doctor name
,	@sInfo		varchar( 32 )		-- info text
)
	with encryption
as
begin
	declare		@idEvent	int
		,		@idDoctor	int
		,		@idPatient	int
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcStn	smallint
		,		@idDstStn	smallint

	set	nocount	on

	if	len(@sPatient) > 0
		exec	dbo.prPatient_GetIns	@sPatient, @cGndr, @sInfo, @sDoctor, @idPatient out, @idDoctor out
	else
	if	len(@sDoctor) > 0
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcStn out, @idDstStn out
		---		,	@idType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

--		insert	tbEvent98	( idEvent,  tiMulti,  idPatient,  idDoctor )	--, tiFlags
--				values		( @idEvent, @tiMulti, @idPatient, @idDoctor )	--, @tiFlags

		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.06.5484

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
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
,	@sSrcStn	varchar( 16 )		-- source name
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
		,		@idSrcStn	smallint
		,		@idDstStn	smallint
		,		@idType		tinyint

	set	nocount	on

	select	@s =	'E41_I( ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' #' +
					isnull(cast(@tiBtn as varchar),'?') + ' ''' + isnull(@sSrcStn,'?') + ''''
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

	select	@idType =	case when	@idDvcType = 8	then	206				-- wi-fi
							when	@idDvcType = 4	then	204				-- phone
							when	@idDvcType = 2	then	205				-- pager
							else							82	end	

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcStn
				,	null, null, null, null, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcStn out, @idDstStn out
				,	@idType, @idCall, @tiBtn, @tiBed		---	, @iAID, @tiStype, @idCall0

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
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
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
	,	r.idStn, r.sSGJ, r.sStn,	e.tiBed, b.cBed
	,	e.idCall, c.sCall, c.siIdx
	,	k.idDvc, d.idDvcType, d.sDvcType, d.sDial, d.sDvc
	,	k.idNtfType, n.sNtfType, e.tiDstRID, char(e.tiFlags) as cRPP, e.sInfo
	,	k.idUser, u.sLvl, u.sStfID, u.sStaff
	from	dbo.tbEvent41	k	with (nolock)
	join	dbo.tbEvent		e	with (nolock)	on	e.idEvent	= k.idEvent
	join	dbo.tbNtfType	n	with (nolock)	on	n.idNtfType	= k.idNtfType
	join	dbo.vwCfgStn	r	with (nolock)	on	r.bActive > 0	and	r.cSys = e.cSrcSys	and	r.tiGID = e.tiSrcGID	and	r.tiJID = e.tiSrcJID	and	r.tiRID = 0
	join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall	--c.bActive > 0	and
	join	dbo.vwDvc		d	with (nolock)	on	d.idDvc		= k.idDvc	--c.bActive > 0	and
	left join dbo.vwStaff	u	with (nolock)	on	u.idUser	= k.idUser
	left join dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
go
--	----------------------------------------------------------------------------
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8791	* @sCodeVer	-> @sVersion
--	7.04.4953	* @sCodeVer: vc(16), was not sized
--	7.00
alter proc		dbo.prEventC1_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint				-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@sVersion	varchar( 16 )		-- device code version
)
	with encryption
as
begin
--	set	nocount	on
	begin	tran

		update	dbo.tbCfgStn	set	sVersion =	@sVersion,	dtUpdated=	getdate( )
			where	cSys = @cSrcSys	and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	bActive > 0
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given unit's map name
--	7.03
alter proc		dbo.prUnitMap_Upd
(
	@idUnit		smallint					-- unit id
,	@tiMap		tinyint						-- map index [0..3]
,	@sMap		varchar( 16 )				-- map name
)
	with encryption
as
begin
--	set	nocount	on
	begin	tran
		update	dbo.tbUnitMap	set	sMap= @sMap
			where	idUnit = @idUnit	and tiMap = @tiMap
	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans up invalid map cells
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8452
alter proc		dbo.prMapCell_ClnUp
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		-- remove rooms which are no longer in maps' units
		update	c	set		idRoom =	null
				,	tiRID1 =	null,	tiBtn1 =	null,	tiRID2 =	null,	tiBtn2 =	null,	tiRID4 =	null,	tiBtn4 =	null
			from	dbo.tbMapCell	c
		left join	dbo.tbRoom		r	on	r.idRoom	= c.idRoom		and	r.idUnit	= c.idUnit
			where	c.idRoom is not null	and	r.idRoom is null

		select	@s =	'MapCell_CU( ) ' + cast(@@rowcount as varchar)

		-- now remove buttons which are no longer valid
		update	c	set		tiRID1 =	null,	tiBtn1 =	null
			from	dbo.tbMapCell	c
		left join	(select	d.idPrnt, d.tiRID, b.tiBtn
						from	dbo.tbCfgBtn	b	with (nolock)
						join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx	and	p.tiSpec = 9
						join	dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= b.idStn	and	d.bActive > 0
								)	b	on	b.idPrnt	= c.idRoom		and	b.tiRID		= c.tiRID1	and	b.tiBtn		= c.tiBtn1
			where	c.idRoom is not null	and	b.idPrnt is null	and	(c.tiRID1 is not null	or	c.tiBtn1 is not null)

		select	@s =	@s + ' ' + cast(@@rowcount as varchar)

		update	c	set		tiRID2 =	null,	tiBtn2 =	null
			from	dbo.tbMapCell	c
		left join	(select	d.idPrnt, d.tiRID, b.tiBtn
						from	dbo.tbCfgBtn	b	with (nolock)
						join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx	and	p.tiSpec = 8
						join	dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= b.idStn	and	d.bActive > 0
								)	b	on	b.idPrnt	= c.idRoom		and	b.tiRID		= c.tiRID2	and	b.tiBtn		= c.tiBtn2
			where	c.idRoom is not null	and	b.idPrnt is null	and	(c.tiRID2 is not null	or	c.tiBtn2 is not null)

		select	@s =	@s + ',' + cast(@@rowcount as varchar)

		update	c	set		tiRID4 =	null,	tiBtn4 =	null
			from	dbo.tbMapCell	c
		left join	(select	d.idPrnt, d.tiRID, b.tiBtn
						from	dbo.tbCfgBtn	b	with (nolock)
						join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siIdx	and	p.tiSpec = 7
						join	dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= b.idStn	and	d.bActive > 0
								)	b	on	b.idPrnt	= c.idRoom		and	b.tiRID		= c.tiRID4	and	b.tiBtn		= c.tiBtn4
			where	c.idRoom is not null	and	b.idPrnt is null	and	(c.tiRID4 is not null	or	c.tiBtn4 is not null)

		select	@s =	@s + ',' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	76, null, null, @s

	commit
end
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
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
		,	c.idRoom, s.cSys, s.tiGID, s.tiJID, s.cStn, s.sStn, s.bActive
		,	cast((len(s.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	s.sUnits	-- # of 'swing' units
		from	dbo.tbMapCell	c	with (nolock)
	left join	dbo.tbCfgStn	s	with (nolock)	on	s.idStn		= c.idRoom	--	and	d.bActive > 0	--	and	d.tiRID = 0
		where	c.idUnit = @idUnit
end
go
--	----------------------------------------------------------------------------
--	Updates a given map-cell
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--				* prUnitMapCell_Upd -> prMapCell_Upd
--				- .cSys, - .tiGID, -.tiJID
--	7.05.4990	+ @tiRID[i], @tiBtn[i]
--	7.03	+ @idRoom, - @bSwing, @cSys, @tiGID, @tiJID
--	6.04
alter proc		dbo.prMapCell_Upd
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
		update	dbo.tbMapCell
			set		idRoom =	@idRoom,	sCell1 =	@sCell1,	sCell2 =	@sCell2
				,	tiRID4 =	@tiRID4,	tiRID2 =	@tiRID2,	tiRID1 =	@tiRID1
				,	tiBtn4 =	@tiBtn4,	tiBtn2 =	@tiBtn2,	tiBtn1 =	@tiBtn1
			where	idUnit = @idUnit	and	tiMap = @tiMap	and	tiCell = @tiCell
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns lowest map index for a given room (identified by Sys-G-J) within a given unit
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--				* fnUnitMapCell_GetMap -> fnMapCell_GetMap
--	7.00
alter function		dbo.fnMapCell_GetMap
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
--	----------------------------------------------------------------------------
--	Provides shift names with spaces replaced by underscores, and also shift details
--	7.06.8846	+ sQnSft
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8696	+ .bCurrent
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5429	+ .dtDue
--	7.06.4939	- .tiRouting
--	7.05.5226
alter view		dbo.vwShift
	with encryption
as
select	sh.idUnit, u.sUnit
	,	cast(case when	u.bActive > 0	and	u.idShift = sh.idShift	then 1	else 0	end	as	bit)	as	bCurrent
	,	sh.idShift, tiIdx, sShift, replace(sh.sShift, ' ', '_')	as	sQnSft, tBeg, tEnd, tiMode
	,	sh.idUser, s.idLvl, s.sStfID, s.sStaff, s.bDuty, s.dtDue
	,	sh.bActive, sh.dtCreated, sh.dtUpdated
	from	dbo.tbShift	sh	with (nolock)
	join	dbo.tbUnit	u	with (nolock)	on	u.idUnit	= sh.idUnit
left join	dbo.vwStaff	s	with (nolock)	on	s.idUser	= sh.idUser
go
--	----------------------------------------------------------------------------
--	Provides unit names with spaces replaced by underscores, and also current shift details
--	7.06.8846
create view		dbo.vwUnit
	with encryption
as
select	u.idUnit, u.sUnit, replace(u.sUnit, ' ', '_')	as	sQnUnt
	,	tiShifts, u.idShift, sh.sShift, sQnSft, tBeg, tEnd, tiMode
	,	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
--	,	isnull(sStfID, '--') + ' | ' + sStaff	as	sQnStf
--	,	u.bActive, u.dtCreated, u.dtUpdated
--	,	s.bActive, s.dtCreated, s.dtUpdated
	from	dbo.tbUnit	u	with (nolock)
	join	dbo.vwShift sh	with (nolock)	on	sh.idShift	= u.idShift
go
grant	select							on dbo.vwUnit			to [rWriter]
grant	select							on dbo.vwUnit			to [rReader]
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
		from	dbo.tbShift		with (nolock)
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
,	@bActive		bit
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
		update	dbo.tbShift
			set		idUnit =	@idUnit,	sShift =	@sShift,	tiIdx=	@tiIdx,	tBeg =	@tBeg,	tEnd =	@tEnd
				,	tiMode =	@tiMode,	idUser =	@idUser,	bActive =	@bActive,	dtUpdated=	@dtUpdated
			where	idShift = @idShift
--	-	else
		if	@@rowcount = 0
		begin
			set identity_insert	dbo.tbShift	on

			insert	dbo.tbShift	(  idShift,  idUnit,  tiIdx,  sShift,  tBeg,  tEnd,  tiMode,  idUser,  bActive,  dtCreated,  dtUpdated )
					values		( @idShift, @idUnit, @tiIdx, @sShift, @tBeg, @tEnd, @tiMode, @idUser, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbShift	off
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns shifts for a given unit (ordered by index) or current one or specified one
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8696	- @bCurrent
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
,	@idShift	smallint	= null	-- null=any for given unit, -1=current for given unit
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, tiMode, bActive, dtCreated, dtUpdated
		,	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.vwShift		with (nolock)
		where	(@bActive is null	or	bActive	= @bActive)
		and		(@idUnit is null	or	idUnit	= @idUnit)
		and		(@idShift is null	or	idShift	= @idShift	or	@idShift < 0	and	bCurrent > 0)
		order	by	idUnit, tiIdx
end
go
--	----------------------------------------------------------------------------
--	Updates # of shifts for all or given unit(s)
--	7.06.8693
--	7.05.5172
--	7.05.4983
alter proc		dbo.prUnit_UpdShifts
(
	@idUnit		smallint		= null	-- null==all
)
	with encryption
as
begin
--	set	nocount	on
	set	xact_abort	on

	begin tran

		if	@idUnit is null
			update	u	set	u.tiShifts= s.tiShifts
				from	dbo.tbUnit	u
				join	(select	idUnit,	count(*)	as	tiShifts
							from	dbo.tbShift	with (nolock)
							where	bActive > 0
							group	by	idUnit)	s	on	s.idUnit = u.idUnit
		else
			update	dbo.tbUnit	set	tiShifts=
						(select	count(*)
							from	dbo.tbShift	with (nolock)
							where	bActive > 0		and	idUnit = @idUnit)
				where	idUnit = @idUnit

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns units, accessible by the given user (via his roles)
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.6817	* order by sUnit	(revert)
--	7.06.6803	* order by idUser
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
,	@sUnits		varchar( 255 )=null	-- comma-separated idUnit-s, '*' or null=all
)
	with encryption
as
begin
	set	nocount	on

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	set	nocount	off
	select	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtCreated, u.dtUpdated
		from	dbo.tbUnit	u	with (nolock)
		join	dbo.tbShift	s	with (nolock)	on	s.idShift = u.idShift
		where	(@bActive is null	or	u.bActive	= @bActive)
		and		(@idUser is null	or	u.idUnit in (select	idUnit
					from	dbo.tb_RoleUnit	ru	with (nolock)
					join	dbo.tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		or		(@idUnit > 0		and	u.idUnit = @idUnit)
		or		(len(@sUnits) > 0	and	u.idUnit in (select idUnit from #tbUnit	with (nolock)))
		order	by	2
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
		join	dbo.tbRouting	z	with (nolock)	on	p.siIdx		= z.siIdx	and	z.idShift	= 0
	left join	dbo.tbRouting	r	with (nolock)	on	z.siIdx		= r.siIdx	and	r.idShift	= @idShift
		where	(@siIdx is null	or	p.siIdx = @siidx )
		and		(@idShift = 0	and	@bEnabled = 0	or	p.siFlags & 0x0002 > 0 )
		order	by	siIdx desc
end
go
--	----------------------------------------------------------------------------
--	Sets call-routing data for given shift and priority
--	7.06.7587	+ .tResp4
--	7.04.4944
--	7.04.4938
alter proc		dbo.prRouting_Set
(
	@idShift	smallint
,	@siIdx		smallint
,	@tiRouting	tinyint
,	@bOverride	bit
,	@tResp0		time( 0 )
,	@tResp1		time( 0 )
,	@tResp2		time( 0 )
,	@tResp3		time( 0 )
,	@tResp4		time( 0 )
)
	with encryption
as
begin
	declare	@bRecord	bit
		,	@_tiRouting	tinyint
		,	@_bOverride	bit
		,	@_tResp0	time( 0 )
		,	@_tResp1	time( 0 )
		,	@_tResp2	time( 0 )
		,	@_tResp3	time( 0 )
		,	@_tResp4	time( 0 )

	set	nocount	on

	if	@idShift > 0
	begin
		select	@bRecord =	0,	@_tiRouting =	tiRouting,	@_bOverride =	bOverride
			,	@_tResp0 =	tResp0,		@_tResp1 =	tResp1,		@_tResp2 =	tResp2,		@_tResp3 =	tResp3,		@_tResp4 =	tResp4
			from	dbo.tbRouting	with (nolock)
			where	idShift = 0			and	siIdx = @siIdx

		if	@tiRouting is null	or	@tiRouting = @_tiRouting
			select	@tiRouting= @_tiRouting
		else
			select	@bRecord=	1

		if	@bOverride is null	or	@bOverride = @_bOverride
			select	@bOverride= @_bOverride
		else
			select	@bRecord=	1

		if	@tResp0 is null	or	@tResp0 = @_tResp0
			select	@tResp0= null
		else
			select	@bRecord=	1

		if	@tResp1 is null	or	@tResp1 = @_tResp1
			select	@tResp1= null
		else
			select	@bRecord=	1

		if	@tResp2 is null	or	@tResp2 = @_tResp2
			select	@tResp2= null
		else
			select	@bRecord=	1

		if	@tResp3 is null	or	@tResp3 = @_tResp3
			select	@tResp3= null
		else
			select	@bRecord=	1

		if	@tResp4 is null	or	@tResp4 = @_tResp4
			select	@tResp4= null
		else
			select	@bRecord=	1
	end
--	print	@idShift
--	print	@bRecord

	begin	tran

		if	@idShift > 0
		begin
			if	@bRecord > 0
			begin
--				select count(*) from dbo.tbRouting with (nolock) where idShift = @idShift and siIdx = @siIdx

				if	not	exists	(select 1 from dbo.tbRouting with (nolock) where idShift = @idShift and siIdx = @siIdx)
				begin
--					print	'ins'
					insert	dbo.tbRouting	(  idShift,  siIdx,  tiRouting,  bOverride,  tResp0,  tResp1,  tResp2,  tResp3,  tResp4 )
							values			( @idShift, @siIdx, @tiRouting, @bOverride, @tResp0, @tResp1, @tResp2, @tResp3, @tResp4 )

					select	@bRecord=	0
				end
		--		else
		--			select	@bRecord=	1		--	no need, already 1
	--				update	dbo.tbRouting
	--					set		tiRouting= @tiRouting,	bOverride= @bOverride,	dtUpdated=	getdate( )
	--						,	tResp0= @tResp0,	tResp1= @tResp1,	tResp2= @tResp2,	tResp3= @tResp3
	--					where	idShift = @idShift	and	siIdx = @siIdx
			end
			else
			begin
--				print	'del'
				delete	from	dbo.tbRouting
					where	idShift = @idShift	and	siIdx = @siIdx
			end
		--		select	@bRecord=	0		--	no need, already 0
		end
	--	else						--	defaults
		if	@idShift = 0	or	@bRecord > 0
		begin
--			print	'upd'
			update	dbo.tbRouting
				set		tiRouting =	@tiRouting,	bOverride =	@bOverride,	dtUpdated=	getdate( ),	tResp0 =	@tResp0
					,	tResp1 =	@tResp1,	tResp2 =	@tResp2,	tResp3 =	@tResp3,	tResp4 =	@tResp4
				where	idShift = @idShift	and	siIdx = @siIdx
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStfAssn') and name = 'idStfAssn')
begin
	begin tran
		if	exists	(select 1 from dbo.sysindexes where name='xuStfAssn_RmBdShIdx_Act')
			drop index	tbStfAssn.xuStfAssn_RmBdShIdx_Act

		exec sp_rename 'tbStfAssn.idStfAssn',	'idAssn',	'column'
		exec sp_rename 'tbStfAssn.idStfCvrg',	'idCvrg',	'column'

		exec sp_rename 'tbStfCvrg.idStfAssn',	'idAssn',	'column'
		exec sp_rename 'tbStfCvrg.idStfCvrg',	'idCvrg',	'column'
/*	commit
end
g o
if	not exists	(select 1 from dbo.sysindexes where name='xuStfAssn_Act_RmBdShIdx')
begin
	begin tran
*/		create unique nonclustered index	xuStfAssn_Act_RmBdShIdx	on	dbo.tbStfAssn (idRoom, tiBed, idShift, tiIdx)	where	bActive > 0		--	7.06.6508
	commit
end
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
select	a.idAssn,	h.idUnit
	,	a.idShift, h.tiIdx as tiShIdx, h.sShift,  h.tBeg,  h.tEnd	--, h.tBeg as tShBeg, h.tEnd as tShEnd
	,	a.idRoom, d.cStn, d.sStn as sRoom, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, a.tiBed
	,	a.tiIdx, a.idUser, s.sStfID, s.idLvl, s.sLvl, s.sStaff, s.bDuty, s.dtDue
	,	c.idCvrg, c.dtBeg, c.dtEnd
	,	a.bActive, a.dtCreated, a.dtUpdated
	from	dbo.tbStfAssn	a	with (nolock)
	join	dbo.tbShift		h	with (nolock)	on	h.idShift	= a.idShift
	join	dbo.vwStaff		s	with (nolock)	on	s.idUser	= a.idUser
	join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= a.idRoom
left join	dbo.tbStfCvrg	c	with (nolock)	on	c.idCvrg	= a.idCvrg
go
--	----------------------------------------------------------------------------
--	Current (open) staff assignment history (coverage)
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				+ 'cast(tBeg as datetime)' as SQL2019 err:	Msg 402, Level 16, State 1	"The data types datetime and time are incompatible in the add operator."
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
select	a.idAssn,	h.idUnit
	,	a.idShift,  h.tiIdx as tiShIdx,  h.sShift,  h.tBeg,  h.tEnd	--, h.tBeg as tShBeg, h.tEnd as tShEnd
	,	a.idRoom, r.cStn, r.sRoom, r.sSGJ, r.cSys, r.tiGID, r.tiJID, r.tiRID, a.tiBed
	,	a.tiIdx,  a.idUser, s.sStfID, s.idLvl, s.sLvl, s.sStaff, s.bDuty, s.dtDue
	,	c.idCvrg, c.dShift, cast(cast(cast(c.dShift as datetime) + cast(h.tBeg as datetime) as float) * 48 as int)	as	iShSeq
	,	c.dtBeg, c.dtDue as dtFin	--, sc.dtEnd
	,	a.bActive, a.dtCreated, a.dtUpdated
	from	dbo.tbStfCvrg	c	with (nolock)
	join	dbo.tbStfAssn	a	with (nolock)	on	a.idAssn	= c.idAssn
	join	dbo.tbShift		h	with (nolock)	on	h.idShift	= a.idShift
	join	dbo.vwStaff		s	with (nolock)	on	s.idUser	= a.idUser
	join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= a.idRoom
--	join	dbo.vwDevice	d	with (nolock)	on	d.idDevice	= a.idRoom
	where	c.dtEnd is null													-- open assignments only
go
--	----------------------------------------------------------------------------
--	Returns staff assignements for the given shift and room-bed
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
	select	idAssn, idShift, idRoom, tiBed, tiIdx,	idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.vwStfAssn	with (nolock)
		where	bActive > 0 and idCvrg > 0	and	idShift = @idShift	and	idRoom = @idRoom
		and		(tiBed = @tiBed		or
				@tiBed	is null		and	tiBed in
					(select min(tiBed)	from	dbo.vwStfAssn	with (nolock)
						where	bActive > 0	and idCvrg > 0	and	idShift = @idShift	and	idRoom = @idRoom))
		order	by	tiIdx
end
go
--	----------------------------------------------------------------------------
--	Finalizes specified staff assignment definition by marking it inactive
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.05.5165	* reset only if current staff is from given assignment definition
--	7.04.4955	* fix logic
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn, prStaffAssn_Fin -> prStfAssn_Fin
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
--	7.01	+ resetting assinged staff in tbRoomBed
--	7.00	tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.02
alter proc		dbo.prStfAssn_Fin
(
	@idAssn			int
)
	with encryption
as
begin
	declare		@dtNow		smalldatetime
		,		@iCvrg		int

	set	nocount	on
	set	xact_abort	on

	select	@dtNow =	getdate( )

	begin	tran

		-- deactivate and close everything associated with that StaffAssn
		update	dbo.tbStfCvrg	set		dtEnd=	@dtNow,		dEnd= @dtNow,	tEnd= @dtNow,	tiEnd=	datepart(hh, @dtNow)
			where	idAssn = @idAssn
		select	@iCvrg =	@@rowcount

		-- reset assigned staff if in room
		update	r	set	idUser1 =	null
			from	dbo.tbRoomBed	r
			join	dbo.tbStfAssn	a	on	a.idRoom	= r.idRoom	and	a.tiBed	= r.tiBed	and	a.tiIdx = 1
			where	idAssn = @idAssn	and	r.idUser1 = a.idUser

		update	r	set	idUser2 =	null
			from	dbo.tbRoomBed	r
			join	dbo.tbStfAssn	a	on	a.idRoom	= r.idRoom	and	a.tiBed	= r.tiBed	and	a.tiIdx = 2
			where	idAssn = @idAssn	and	r.idUser2 = a.idUser

		update	r	set	idUser3 =	null
			from	dbo.tbRoomBed	r
			join	dbo.tbStfAssn	a	on	a.idRoom	= r.idRoom	and	a.tiBed	= r.tiBed	and	a.tiIdx = 3
			where	idAssn = @idAssn	and	r.idUser3 = a.idUser

		-- deactivate
		update	dbo.tbStfAssn	set		bActive =	0,	idCvrg=	null,	dtUpdated=	getdate( )
			where	idAssn = @idAssn

		-- purge if no coverage history
		if	@iCvrg = 0
			delete	from	dbo.tbStfAssn
				where	idAssn = @idAssn

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all staff assignment definitions
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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

	update	dbo.tbStfAssn
		set		bActive =	0				-- validation:	deactivate assignments in inactive rooms
		where	bActive = 1
		and		idRoom in (select idStn from dbo.tbCfgStn with (nolock) where cStn='R' and bActive = 0)

	set	nocount	on

	select	idAssn, idUnit, cSys, tiGID, tiJID, tiBed, tiShIdx, tiIdx, sStfID, bActive, dtCreated, dtUpdated,	idRoom, sRoom, idUser, sStaff, idShift
		from	dbo.vwStfAssn	with (nolock)
	---	where	bActive > 0					-- must export all to ensure matching deactivation
end
go
--	----------------------------------------------------------------------------
--	Imports a staff assignment definition
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8783	* .sStaffID -> sStfID, @
--	7.06.7460	* disable duplicates and close their coverage
--	7.06.5940	* optimize logging
--	7.06.5332	* fix check @idStfAssn > 0 -> @@rowcount
--	7.05.5248	+ dup check (xuStfAssn_Active_RoomBedShiftIdx)
--	7.05.5087	+ trace output
--	7.05.5074
alter proc		dbo.prStfAssn_Imp
(
	@idAssn		int							-- null = new
,	@idUnit		smallint					-- unit look-up FK
--,	@idRoom		smallint					-- room look-up FK
,	@cSys		char( 1 )					-- corresponding to idRoom
,	@tiGID		tinyint
,	@tiJID		tinyint
,	@tiBed		tinyint						-- bed index FK
--,	@idShift	smallint					-- shift look-up FK
,	@tiShIdx	tinyint						-- shift index [1..3]
,	@tiIdx		tinyint						-- staff index [1..3]
--,	@idUser		int							-- staff look-up FK
,	@sStfID		varchar( 16 )				-- corresponding to idUser
,	@bActive	bit							-- active?
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@idRoom		smallint
		,		@idShift	smallint
		,		@idUser		int
		,		@id_Asn		int

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@idRoom =	idRoom	from	dbo.vwRoom		with (nolock)	where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID
	select	@idShift =	idShift	from	dbo.tbShift		with (nolock)	where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx
	select	@idUser =	idUser	from	dbo.tb_User		with (nolock)	where	bActive > 0		and	sStfID = @sStfID

	select	@s =	'SA_Imp( ' + isnull(cast(@idAssn as varchar),'?') + ', ' +
					isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' + right('00' + isnull(cast(@tiJID as varchar),'?'), 3) +
					', ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiShIdx as varchar),'?') + '=' + isnull(cast(@idShift as varchar),'?') + ', ' + isnull(cast(@tiIdx as varchar),'?') +
					':' + @sStfID + '=' + isnull(cast(@idUser as varchar),'?') + ' a=' + isnull(cast(@bActive as varchar),'?') + ' ) rm=' + isnull(cast(@idRoom as varchar),'?')

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	begin	tran

	--	if	@bActive > 0	and	(@idRoom is null	or	@idShift is null	or	@idUser is null)
		if	@idRoom is null		or	@idShift is null	or	@idUser is null
		begin
			exec	dbo.pr_Log_Ins	47, null, null, @s, 94

			update	dbo.tbStfAssn
				set		bActive =	@bActive,	dtCreated=	@dtCreated,		dtUpdated=	@dtUpdated
				where	idAssn = @idAssn
		end
		else
		begin
			select	@id_Asn =	idAssn										-- find a xuStfAssn_RmBdShIdx_Act match
				from	dbo.tbStfAssn
				where	idRoom = @idRoom	and	tiBed = @tiBed	and	idShift = @idShift	and	tiIdx = @tiIdx	and	bActive > 0

			if	@id_Asn <> @idAssn											-- if that's not the argument
			begin
				update	c
					set		dtEnd=	getdate( ),	dEnd =	getdate( ),	tEnd =	getdate( )
					from	dbo.tbStfCvrg	c
					join	dbo.tbStfAssn	a	on	a.idCvrg	= c.idCvrg		and	a.idAssn	= @id_Asn
					where	dtEnd is null									-- close its coverage

				update	dbo.tbStfAssn
					set		idCvrg=	null,	bActive =	0,	dtUpdated= getdate( )
					where	idAssn = @id_Asn								-- and deactivate that match
			end

--	-		if	exists	(select 1 from tbStfAssn with (nolock) where idStfAssn = @idStfAssn)
			update	dbo.tbStfAssn
				set		idRoom =	@idRoom,	tiBed =		@tiBed,		idShift =	@idShift,	tiIdx =		@tiIdx
					,	idUser =	@idUser,	bActive =	@bActive,	dtCreated=	@dtCreated,	dtUpdated=	@dtUpdated
				where	idAssn = @idAssn
--	-		else
			if	@@rowcount = 0
			begin
				set identity_insert	dbo.tbStfAssn	on

				insert	dbo.tbStfAssn	(  idAssn,  idRoom,  tiBed,  idShift,  tiIdx,  idUser,  bActive,  dtCreated,  dtUpdated )
						values			( @idAssn, @idRoom, @tiBed, @idShift, @tiIdx, @idUser, @bActive, @dtCreated, @dtUpdated )

				set identity_insert	dbo.tbStfAssn	off
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all staff assignments for given unit/shift
--	7.06.8796	* .idStfAssn -> .idAssn, @	.idStAss? -> idAssn?
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
	select	rb.idRoom, rb.cStn, rb.sRoom,	rb.tiBed, rb.cBed
		,	rb.idPatient, rb.sPatient, rb.cGndr, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	a1.idAssn as idAssn1,  a1.idUser as idUser1,  a1.idLvl as idLvl1,  a1.sStfID as sStfID1,  a1.sStaff as sStaff1,  a1.bDuty as bDuty1,  a1.dtDue as dtDue1
		,	a2.idAssn as idAssn2,  a2.idUser as idUser2,  a2.idLvl as idLvl2,  a2.sStfID as sStfID2,  a2.sStaff as sStaff2,  a2.bDuty as bDuty2,  a2.dtDue as dtDue2
		,	a3.idAssn as idAssn3,  a3.idUser as idUser3,  a3.idLvl as idLvl3,  a3.sStfID as sStfID3,  a3.sStaff as sStaff3,  a3.bDuty as bDuty3,  a3.dtDue as dtDue3
		from	dbo.vwRoomBed	rb	with (nolock)
	left join	dbo.vwStfAssn	a1	with (nolock)	on	a1.idRoom = rb.idRoom	and	a1.tiBed = rb.tiBed		and	a1.idShift = @idShift	and	a1.tiIdx = 1	and	a1.bActive > 0
	left join	dbo.vwStfAssn	a2	with (nolock)	on	a2.idRoom = rb.idRoom	and	a2.tiBed = rb.tiBed		and	a2.idShift = @idShift	and	a2.tiIdx = 2	and	a2.bActive > 0
	left join	dbo.vwStfAssn	a3	with (nolock)	on	a3.idRoom = rb.idRoom	and	a3.tiBed = rb.tiBed		and	a3.idShift = @idShift	and	a3.tiIdx = 3	and	a3.bActive > 0
		where	rb.idUnit = @idUnit
		order	by	rb.sRoom, rb.cBed
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
--	7.06.8846	* optimized logging
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8690	+ @idShift
--				- @tiShIdx
--				* param order
--	7.06.7465	- @cSys, @tiGID, @tiJID, @sStaffID
--				* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5940	* optimize logging
--	7.05.5165	* 
--	7.05.5050	* change logic, remove extra args
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4955	* fix logic
--	7.04.4920	- tbStaff -> tb_User
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn, prStaffAssn_InsUpdDel -> prStfAssn_InsUpdDel
--	7.03.4884	+ trace output
--	7.00	* tbDevice.bActive > 0
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02
--	6.01
alter proc		dbo.prStfAssn_InsUpdDel
(
	@idAssn		int							-- null = new
,	@idUnit		smallint					-- unit look-up FK
,	@idShift	smallint
,	@idRoom		smallint					-- room look-up FK
,	@tiBed		tinyint						-- bed index FK
,	@tiIdx		tinyint						-- staff index [1..3]
,	@idUser		int							-- staff look-up FK
,	@bActive	bit							-- active?
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@sRoom		varchar( 16 )
		,		@sUser		varchar( 16 )
		,		@tiSft		tinyint
		,		@tBeg		time( 0 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@sUnit =	sQnUnt	from	dbo.vwUnit		with (nolock)	where	idUnit	= @idUnit
	select	@tiSft =	tiIdx,	@tBeg =	tBeg	--,	@sShift =	sShift,	@tEnd =	tEnd,	@bActive =	bActive
								from	dbo.vwShift		with (nolock)	where	@idShift= idShift	and	bActive > 0
	select	@sRoom =	sStn	from	dbo.tbCfgStn	with (nolock)	where	idStn	= @idRoom
	select	@sUser =	sUser	from	dbo.tb_User		with (nolock)	where	idUser	= @idUser

	select	@s =	'SA( ' + isnull(cast(@idAssn as varchar),'?') +
					', ' + isnull(cast(@idUnit as varchar),'?') + '|' + isnull(cast(@sUnit as varchar),'?') +	--	':' + isnull(cast(@idShift as varchar),'?') +
					' ' + isnull(cast(@idShift as varchar),'?') + '|' + isnull(cast(@tiSft as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') +
					', ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(cast(@sRoom as varchar),'?') + ':' + isnull(cast(@tiBed as varchar),'?') +
					', ' + isnull(cast(@tiIdx as varchar),'?') + ':' + isnull(cast(@idUser as varchar),'?') + '|' + isnull(cast(@sUser as varchar),'?') +
					' a=' + isnull(cast(@bActive as varchar),'?') + ' )'

	begin	tran

		if	@idAssn > 0		and	( @bActive = 0	or	@idUser is null )
			exec	dbo.prStfAssn_Fin	@idAssn								--	finalize assignment
	
		else
		if	@bActive > 0	and	@idShift > 0	and	@idRoom > 0		and	@tiBed >= 0		and	@tiIdx > 0		and	@idUser > 0
		begin
			if	@idAssn > 0
				if	exists( select 1 from dbo.tbStfAssn where idAssn = @idAssn and idUser <> @idUser )
				begin
					exec	dbo.prStfAssn_Fin	@idAssn						--	another staff is assigned - finalize previous one

					select	@idAssn =	null
				end

			if	@idAssn = 0	or	@idAssn is null
			begin
				insert	dbo.tbStfAssn	(  idRoom,  tiBed,  idShift,  tiIdx,  idUser )
						values			( @idRoom, @tiBed, @idShift, @tiIdx, @idUser )
				select	@idAssn =	scope_identity( )
				select	@s =	@s + ': ' + cast(@idAssn as varchar)
			end
		end
		else
		begin
			select	@s =	@s + ' !'
			exec	dbo.pr_Log_Ins	47, null, null, @s, 62
			commit
			return	-1
		end

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	248, null, null, @s, 62

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8712	+ prHealth_Stats call
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
		,		@idAssn		int
		,		@idCvrg		int

	set	nocount	on
	set	xact_abort	on

---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	create	table	#tbUser
	(
		idUser		int			not null	primary key clustered
	,	sQnStf		varchar(36)	not null
	)
	create	table	#tbAssn
	(
		idCvrg		int			not null	primary key clustered
	,	idAssn		int			not null
	)

	-- get recovery_model_desc and log_reuse_wait
	select	@dtNow =	getdate( )											-- smalldatetime truncates seconds
	select	@tNow =		@dtNow												-- time(0) truncates date, leaving HH:MM:00

	-- get a list of users whose break is expiring on this pass
	insert	#tbUser
		select	idUser, sQnStf	from	dbo.vwStaff		where	dtDue <= @dtNow
--		select	idUser	from	tb_User		where	dtDue <= @dtNow

	begin	tran

		exec	dbo.prHealth_Stats											-- update DB size stats
		exec	dbo.pr_Module_Act	1										-- mark DB component active (since this sproc is executed every minute)

		-- get assignments that are due to complete now
		insert	#tbAssn
			select	sc.idCvrg, sc.idAssn
				from	dbo.tbStfCvrg	sc	with (nolock)
				join	dbo.tbStfAssn	sa	with (nolock)	on	sa.idAssn = sc.idAssn	and	sa.bActive > 0	and	sa.idCvrg > 0
				where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

---		select	*	from	#tbDueAssn

		--	reset assigned staff in completed assignments
		update	rb
			set		idUser1 =	null,	idUser2 =	null,	idUser3 =	null,	dtUpdated=	@dtNow
			from	dbo.tbRoomBed	rb
			join	dbo.tbStfAssn	sa	on	sa.idRoom	= rb.idRoom		and	sa.tiBed	= rb.tiBed
			join		#tbAssn		da	on	da.idAssn	= sa.idAssn

		-- finish coverage for completed assignments
		update	sc
			set		dtEnd=	@dtNow,	dEnd =	@dtNow,	tEnd =	@tNow,	tiEnd=	datepart(hh, @tNow)
			from	dbo.tbStfCvrg	sc
			join		#tbAssn		da	on	da.idAssn	= sc.idAssn		and	da.idCvrg	= sc.idCvrg
	---		where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

		--	reset coverage refs for completed assignments
		update	sa
			set		idCvrg=	null,	dtUpdated=	@dtNow
			from	dbo.tbStfAssn	sa
			join		#tbAssn		da	on	da.idAssn	= sa.idAssn

		-- reset coverage refs for completed assignments (stale)
		update	sa
			set		idCvrg=	null,	dtUpdated=	@dtNow
			from	dbo.tbStfAssn	sa
			join	dbo.tbStfCvrg	sc	on	sc.idCvrg	= sa.idCvrg		and	sc.dtEnd < @dtNow


		-- set current shift for each active unit
		update	u
			set		idShift =	sh.idShift
			from	dbo.tbUnit		u
			join	dbo.tbShift		sh	on	sh.idUnit	= u.idUnit
			where	u.bActive > 0
			and		sh.bActive > 0	and	u.idShift <> sh.idShift
			and		(	sh.tBeg <= @tNow	and	@tNow < sh.tEnd
					or	sh.tEnd <= sh.tBeg	and	(sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		-- set staff, who finished break, to ON-duty
		update	dbo.tb_User
			set		bDuty =	1,	dtDue=	null,	dtUpdated=	@dtNow
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

		-- get assignments that should be started/running now, only for ON-duty staff
		declare	cur		cursor fast_forward for
			select	sa.idAssn,
			--		case when	sh.tBeg < sh.tEnd	then	@dtNow - @tNow + sh.tEnd		--	!! this works in SQL2008 R2, but not in SQL2012
				---		when	sh.tBeg = sh.tEnd	then	@dtNow - @tNow + sh.tEnd + 1	--	matches else (sh.tBeg > sh.tEnd) case
			--										else	@dtNow - @tNow + sh.tEnd + 1 end
					case when	sh.tBeg < sh.tEnd	then	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime)
													else	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime) + 1 end
				,	case when	sh.tEnd <= sh.tBeg	and	@tNow < sh.tEnd		then	dateadd( dd, -1, @dtNow )	else	@dtNow	end
				from	dbo.tbStfAssn	sa	with (nolock)
				join	dbo.tb_User		us	with (nolock)	on	us.idUser  = sa.idUser		and	us.bDuty > 0	-- only ON-duty
				join	dbo.tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		and	sh.bActive > 0
				where	sa.bActive > 0
				and		sa.idCvrg is null									--	not running now
				and		(	sh.tBeg <= @tNow	and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idAssn, @dtDue, @dShift
		while	@@fetch_status = 0
		begin
---			print	cast(@idAssn, varchar) + ': ' + cast(@dtDue, varchar)
		
			insert	dbo.tbStfCvrg	(  idAssn,  dtBeg,   dBeg,  tBeg,  dtDue,  dShift,  tiBeg )
					values			( @idAssn, @dtNow, @dtNow, @tNow, @dtDue, @dShift, datepart( hh, @tNow ) )
			select	@idCvrg =	scope_identity( )

			update	dbo.tbStfAssn
				set		idCvrg=	@idCvrg,	dtUpdated=	@dtNow
				where	idAssn = @idAssn

			fetch next from	cur	into	@idAssn, @dtDue, @dShift
		end
		close	cur
		deallocate	cur

		-- set current assigned staff
		update	rb	set		idUser1 =	a.idUser
			from	dbo.tbRoomBed	rb
			join	dbo.tbRoom		r	on	r.idRoom	= rb.idRoom
			join	dbo.tbUnit		u	on	u.idUnit	= r.idUnit
			join	dbo.tbStfAssn	a	on	a.idRoom	= rb.idRoom		and	a.tiBed		= rb.tiBed	and	a.tiIdx = 1	and
											a.idShift	= u.idShift		and	a.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bDuty > 0	-- only ON-duty

		update	rb	set		idUser2 =	a.idUser
			from	dbo.tbRoomBed	rb
			join	dbo.tbRoom		r	on	r.idRoom	= rb.idRoom
			join	dbo.tbUnit		u	on	u.idUnit	= r.idUnit
			join	dbo.tbStfAssn	a	on	a.idRoom	= rb.idRoom		and	a.tiBed		= rb.tiBed	and	a.tiIdx = 2	and
											a.idShift	= u.idShift		and	a.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bDuty > 0	-- only ON-duty

		update	rb	set		idUser3 =	a.idUser
			from	dbo.tbRoomBed	rb
			join	dbo.tbRoom		r	on	r.idRoom	= rb.idRoom
			join	dbo.tbUnit		u	on	u.idUnit	= r.idUnit
			join	dbo.tbStfAssn	a	on	a.idRoom	= rb.idRoom		and	a.tiBed		= rb.tiBed	and	a.tiIdx = 3	and
											a.idShift	= u.idShift		and	a.bActive > 0
	--	-	join	tb_User		us	on	us.idUser  = sa.idUser	and	us.bDuty > 0	-- only ON-duty

	commit
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)

	select	@tiLog =	tiLvl,	@dtNow =	getdate( )	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tBeg =		cast(tValue as time( 0 ))		from	dbo.tb_OptSys	with (nolock)	where	idOption = 31

	begin	tran

		select	@s =	'Loc_SL( ) *' + cast(@iCount as varchar)

		-- deactivate non-matching units
		update	u
			set		u.bActive=	0,	u.dtUpdated =	@dtNow
			from	dbo.tbUnit		u
		left join 	dbo.tbCfgLoc	l	on	l.idLoc		= u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1		and	l.idLoc is null
		select	@s =	@s + ', -' + cast(@@rowcount as varchar)

		-- deactivate shifts for inactive units
		update	s
			set		s.bActive=	0,	s.dtUpdated =	@dtNow
			from	dbo.tbShift		s
			join	dbo.tbUnit		u	on	u.idUnit	= s.idUnit		and	u.bActive = 0
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
		delete	from	dbo.tbUnitMap		where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tbDvcUnit		where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tbTeamUnit		where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))
		delete	from	dbo.tb_UserUnit		where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))	--	7.06.6796
		delete	from	dbo.tb_RoleUnit		where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock))

		-- finish coverage for assignments in disabled units
		update	dbo.tbStfCvrg
			set		dtEnd=	@dtNow,		dEnd =	@dtNow,		tEnd =	@dtNow
			where	idCvrg	in	(select	idCvrg	from	dbo.vwStfAssn
											where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock)))
			and		dtEnd is null

		-- deactivate these assignments
		update	dbo.tbStfAssn
			set		idCvrg =	null
			where	idCvrg is not null	and	bActive = 0
			and		idAssn	in	(select	idAssn	from	dbo.vwStfAssn
											where	idUnit	in	(select	idUnit	from	#tbUnit	with (nolock)))

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
--	Updates mode and backup of a given shift
--	7.06.8846	* optimized logging
--	7.06.8693
alter proc		dbo.prShift_Upd
(
	@idUser		int					-- user, performing the action
,	@idUnit		smallint
,	@idShift	smallint			-- not null
,	@tiMode		tinyint				-- not null=set notify + bkup
,	@idOper		int					-- operand user, backup staff
)
	with encryption
as
begin
	declare		@k			tinyint
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@tiIdx		tinyint
		,		@tBeg		time( 0 )
		,		@sOper		varchar( 16 )

	set	nocount	on
	set	xact_abort	on

	select	@sUnit =	sQnUnt	from	dbo.vwUnit		with (nolock)	where	idUnit	= @idUnit
	select	@tiIdx =	tiIdx,	@tBeg =	tBeg
								from	dbo.vwShift		with (nolock)	where	@idShift= idShift	and	bActive > 0
	select	@sOper =	sUser	from	dbo.tb_User		with (nolock)	where	idUser	= @idOper

	select	@s =	'Shft_U( ' + isnull(cast(@idUnit as varchar),'?') + '|' + isnull(cast(@sUnit as varchar),'?') +
					' ' + isnull(cast(@idShift as varchar),'?') + '|' + isnull(cast(@tiIdx as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') +
--					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', nm=' + isnull(cast(@tiMode as varchar),'?') + ' bk=' + isnull(cast(@idOper as varchar),'?') + '|' + isnull(cast(@sOper as varchar),'?') + ' )'

	select	@k =	248

	begin	tran

		update	dbo.tbShift
			set		tiMode =	@tiMode,	idUser =	@idOper,	dtUpdated=	getdate( )
			where	idShift = @idShift

--		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
--	7.06.8846	* optimized logging
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8693	- @tiMode, @idOper
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.7465	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5415	+ @idUser, logging, @idUser -> @idOper
--	7.06.4939	- .tiRouting
--	7.05.5172
alter proc		dbo.prShift_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idUnit		smallint
,	@idShift	smallint	out		-- null=new shift
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@bActive	bit
)
	with encryption
as
begin
	declare		@k			tinyint
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@idAssn		int

	set	nocount	on
	set	xact_abort	on

	if	@idShift is null	or	@idShift < 0
		select	@idShift =	idShift
			from	dbo.tbShift		with (nolock)
			where	idUnit = @idUnit	and	tiIdx = @tiIdx

	select	@sUnit =	sQnUnt	from	dbo.vwUnit		with (nolock)	where	idUnit	= @idUnit

	select	@s =	'Shft_IU( ' + isnull(cast(@idUnit as varchar),'?') + '|' + isnull(cast(@sUnit as varchar),'?') +
					' ' + isnull(cast(@idShift as varchar),'?') + '|' + isnull(cast(@tiIdx as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') +
--	select	@s =	'Shft_IU( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
--					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
					', a=' + isnull(cast(@bActive as varchar),'?') + ' )'
--					' cr=' + isnull(convert(varchar, @dtCreated, 20),'?') + ' up=' + isnull(convert(varchar, @dtUpdated, 20),'?') + ' )'

	begin	tran

		if	@idShift is null	or	@idShift < 0
		begin
			insert	dbo.tbShift	(  idUnit,  tiIdx,  sShift,  tBeg,  tEnd )
					values		( @idUnit, @tiIdx, @sShift, @tBeg, @tEnd )
			select	@idShift =	scope_identity( )

			select	@s =	@s + '=' + cast(@idShift as varchar)
				,	@k =	247
		end
		else
		begin
			update	dbo.tbShift
				set		dtUpdated=	getdate( ),	tBeg =	@tBeg,	tEnd =	@tEnd,	bActive =	@bActive
				where	idShift = @idShift

			if	@bActive = 0
			begin
				declare	cur		cursor fast_forward for
					select	idAssn
						from	dbo.tbStfAssn	with (nolock)
						where	idShift = @idShift	--	and	bActive > 0

				open	cur
				fetch next from	cur	into	@idAssn
				while	@@fetch_status = 0
				begin
					exec	dbo.prStfAssn_Fin	@idAssn						--	finalize assignment

					fetch next from	cur	into	@idAssn
				end
				close	cur
				deallocate	cur
			end

			select	@k =	248
		end

		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62

	commit
end
go
--	----------------------------------------------------------------------------
--	Sets user's Duty and Break states
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8783	* tb_User.bOnDuty	-> bDuty, @
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
,	@bDuty		bit		--	=	null	--	0=off-duty, 1=ON-duty, null=see @tiMins
,	@tiMins		tinyint					--	0=finish break, >0=break time from now, null=see @bDuty
)
	with encryption	--, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@dtNow		smalldatetime
		,		@tNow		time( 0 )
		,		@idType		tinyint
		,		@bOn		bit
		,		@dtDue		smalldatetime

	set	nocount	on
	set	xact_abort	on

	select	@bOn =	bDuty,	@dtDue =	dtDue,	@s =	sQnStf
		from	dbo.vwStaff	with (nolock)
		where	idUser = @idUser	and	bActive > 0

	if	@@rowcount > 0
	begin
		select	@dtNow =	getdate( )		-- smalldatetime truncates seconds
		select	@tNow =		@dtNow			-- time(0) truncates date, leaving HH:MM:00

		begin	tran

			if	@bDuty > 0													-- set ON-duty
			begin
				if	@bOn = 0												-- was off-duty|on-Break
				begin
					update	tb_User
						set		bDuty =	1,	dtUpdated=	@dtNow,		dtDue=	null
						where	idUser = @idUser	and	bActive > 0

					exec	dbo.pr_Log_Ins	218, @idUser, null, @s, @idModule

					exec	dbo.prStfCvrg_InsFin							-- init coverage
				end
			end
			else	--	@bDuty = 0											-- set off-duty
			begin
				if	@bOn > 0	or	@dtDue is not null						-- was ON-duty|on-Break
				begin
					update	tb_User
						set		bDuty =	0,	dtUpdated=	@dtNow
							,	dtDue=	case when @tiMins > 0 then dateadd( mi, @tiMins + 1, @dtNow ) else null end
						where	idUser = @idUser

					-- reset coverage refs for interrupted assignments
					update	sa
						set		idCvrg=	null,	dtUpdated=	@dtNow
						from	tbStfAssn	sa
						join	tbStfCvrg	sc	on	sc.idCvrg	= sa.idCvrg		and	sc.dtEnd is null
						where	sa.idUser = @idUser

					-- finish coverage for interrupted assignments
					update	sc
						set		dtEnd=	@dtNow,		dEnd =	@dtNow,		tEnd =	@tNow,	tiEnd=	datepart( hh, @tNow )
						from	tbStfCvrg	sc
						join	tbStfAssn	sa	on	sa.idAssn	= sc.idAssn		and	sa.idUser = @idUser
						where	sc.dtEnd is null

					select	@s =	@s +	case when @tiMins > 0 then ' for ' + cast(@tiMins as varchar) + ' min' else '' end
							,	@idType =	case when @tiMins > 0 then 219 else 220 end

					exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule
				end
			end

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Initializes or finalizes AD-Sync
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8726	+ reset duty for inactive (',	bDuty =	0,	dtDue =	null') in finish path to satisfy [tv_User_Duty]
--	7.06.7299	+ @idModule
--	7.06.7279	* optimized logging
--	7.06.7251	- 'and	bActive > 0' from that rename
--	7.06.7244	+ rename login to GUID for accounts removed from AD (left disabled in our DB)
--					prepend a comment in .sDesc, describing this and record original login
--	7.06.6019
alter proc		dbo.pr_User_SyncAD
(
	@idModule	tinyint
,	@bActive	bit					-- 1=start, 0=finish
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Usr_SAD( ' + cast(@bActive as varchar) + ' ) '

	begin	tran

		if	@bActive > 0													-- start AD-Sync
		begin
			update	dbo.tb_User
				set		bConfig =	0,	dtUpdated=	getdate( )
				where	gGUID is not null	and	bConfig > 0

			select	@s =	@s + '*' + cast(@@rowcount as varchar)
		end
		else																-- finish AD-Sync
		begin
--			update	tb_User		set		sDesc =		convert(varchar, getdate( ), 120) + ': "' + sUser + '" no longer in AD. ' + sDesc
--				where	gGUID is not null	and	bConfig = 0		and	bActive > 0

			update	dbo.tb_User
				set		bActive =	0,	dtUpdated=	getdate( ),		bDuty =	0,	dtDue =	null
					,	sDesc =		convert(varchar, getdate( ), 120) + ': [' + sUser + '] no longer authorized. ' + isnull(sDesc,'')
					,	sUser =		replace( cast(gGUID as char(36)), '-', '' )	-- rename login to GUID
				where	gGUID is not null	and	bConfig = 0	--	and	bActive > 0
				and		sUser <> replace( cast(gGUID as char(36)), '-', '' )

			select	@s =	@s + '-' + cast(@@rowcount as varchar)
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	100, null, null, @s, @idModule	--	238	--	7.06.7251

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
--	7.06.8790	* pr_User_sStaff_Upd	->	pr_User_UpdStaff
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8733	+ unassign deactivated
--	7.06.7433	* optimized logging
--	7.06.7326	* inactive user can't stay on-duty
--	7.06.7299	+ @idModule
--	7.06.7279	* optimized logging
--	7.06.7251	+ return indicating the result (idLogType of [101..104])
--	7.06.7249	* only audit when smth has changed (minimize log impact)
--	7.06.7129	+ tb_LogType[100-103]
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
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
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
		,		@s	varchar( 255 )
		,		@utSynched	smalldatetime		-- (UTC) time of last AD-Sync

	set	nocount	on
	set	xact_abort	on

	if	@idUser = 4															-- System
		select	@idUser =	null

	select	@idOper =	idUser,		@utSynched =	utSynched
		from	dbo.tb_User with (nolock)
		where	gGUID = @gGUID

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '] ut=' + isnull(convert(varchar, @utSynched, 120), '?') +
				' ' + isnull(upper(cast(@gGUID as char(36))), '?') + ' [' + @sUser + '] ''' + isnull(cast(@sFrst as varchar), '?') +
				''' ''' + isnull(cast(@sMidd as varchar), '?') + ''' ''' + isnull(cast(@sLast as varchar), '?') +
				''' ' + isnull(cast(@sEmail as varchar), '?') + ' d=''' + isnull(cast(@sDesc as varchar), '?') +
				''' k=' + cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' ad=' + isnull(convert(varchar, @dtUpdated, 120), '?')
	begin	tran

		if	@idOper = 0		or	@idOper is null								-- user not found
		begin
			if	0 < @bActive												--	7.06.7094	only import *active* users!
			begin
				insert	dbo.tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
						values		( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
				select	@idOper =	scope_identity( )

				select	@k =	102,	@s =	'Usr_ADI( ' + @s + ' )=' + cast(@idOper as varchar)		--	7.06.7129	--	237
			end
			else															--	7.06.7094
				select	@k =	101,	@s =	'Usr_ADI( ' + @s + ' ) ^'	--	7.06.7129	--	2	-- *inactive skipped*
		end
		else
		if	@utSynched < @dtUpdated											-- AD had a recent change
		begin
			update	dbo.tb_User
				set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
					,	sUser =		@sUser,		sFrst=	@sFrst,		sMidd=	@sMidd,		sLast=	@sLast
					,	sEmail =	@sEmail,	sDesc=	@sDesc,		utSynched=	getutcdate( )
					,	tiFails =	case when	@tiFails = 0xFF	then	@tiFails
										when	tiFails = 0xFF	then	0
										else	tiFails		end
					,	bDuty =		case when	@bActive = 0	then	0		else	bDuty	end
					,	dtDue =		case when	@bActive = 0	then	null	else	dtDue	end
				where	idUser = @idOper

			select	@k =	103,	@s =	'Usr_ADU( ' + @s + ' ) *'		--	7.06.7129	--	238
		end
		else																-- user already up-to date
		begin
			if	0 < @bActive												-- if user is active
				update	dbo.tb_User
					set		sUser =		@sUser,		sDesc=	@sDesc,		utSynched=	getutcdate( )
					where	idUser = @idOper	--	and	sUser <> @sUser		-- restore his login (.sUser) and update .utSynched

			update	dbo.tb_User
				set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
					,	bDuty =		case when	@bActive = 0	then	0		else	bDuty	end
					,	dtDue =		case when	@bActive = 0	then	null	else	dtDue	end
				where	idUser = @idOper									-- update .bActive and mark user 'processed'

			select	@k =	104,	@s =	'Usr_AD( ' + @s + ' )'			--	7.06.7129,	7.06.7251	--	238
		end

		if	@bActive = 0													--	.8733	unassign deactivated
		begin
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, 0, 0		-- must precede table update

			delete	from	dbo.tb_UserRole		where	idUser = @idOper	and	idRole > 1
			delete	from	dbo.tb_UserUnit		where	idUser = @idOper
			delete	from	dbo.tbTeamUser		where	idUser = @idOper

			update	dbo.tbDvc		set	idUser =	null	where	idUser = @idOper
			update	dbo.tbShift		set	idUser =	null	where	idUser = @idOper
			update	dbo.tbStfAssn	set	bActive =	0		where	idUser = @idOper
		end

		exec	dbo.pr_User_UpdStaff	@idOper

		if	@k < 104														--	7.06.7251	!! do not flood audit with 'skips' !!
			exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s, @idModule

		if	101 < @k														--	7.06.7094/7129	only import *active* users!
			-- enforce membership in 'Public' role
			if	not exists	(select 1 from dbo.tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
				insert	dbo.tb_UserRole	( idRole, idUser )
						values			( 1, @idOper )

	commit

	return	@k
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8790	* pr_User_sStaff_Upd	->	pr_User_UpdStaff
--	7.06.8789	* tb_User.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl, @
--	7.06.8783	* #PK nonclustered -> clustered
--				* tb_User.sStaffID -> sStfID, @
--				* tb_User.bOnDuty	-> bDuty, @
--	7.06.8734	+ unassign deactivated
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
,	@sStfID		varchar( 16 )
,	@idLvl		tinyint
--,	@sBarCode	varchar( 32 )
,	@sCode		varchar( 32 )
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
,	@sRoles		varchar( 255 )
,	@bDuty		bit
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@idType		tinyint

	set	nocount	on
	set	xact_abort	on

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)
	create table	#tbTeam
	(
		idTeam		smallint		not null	primary key clustered
--	,	sTeam		varchar( 16 )	not null
	)
	create table	#tbRole
	(
		idRole		smallint		not null	primary key clustered
--	,	sRole		varchar( 16 )	not null
	)

	if	@bActive = 0	select	@bDuty =	0,	@sUnits =	null,	@sTeams =	null,	@sRoles =	null	--	.8734
	if	@idLvl is null	select	@bDuty =	0,	@sUnits =	null		--	7.06.7334

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	if	not exists	(select 1 from #tbRole with (nolock) where idRole = 1)
		insert	#tbRole		(idRole)	values	( 1 )						-- enforce membership in 'Public' role

	select	@s =	isnull(cast(@idOper as varchar), '?') + '|' + @sUser + ', ''' + isnull(cast(@sFrst as varchar), '?') +
					''' ''' + isnull(cast(@sMidd as varchar), '?') + ''' ''' + isnull(cast(@sLast as varchar), '?') +
					''' ' + isnull(cast(@sEmail as varchar), '?') + ' d=''' + isnull(cast(@sDesc as varchar), '?') +
					''', I=' + isnull(cast(@sStfID as varchar), '?') + ' L=' + isnull(cast(@idLvl as varchar), '?') +
					' c=' + isnull(cast(@sCode as varchar), '?') + ', D=' + isnull(cast(@bDuty as varchar), '?') +
					' k=' + cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' R=' + isnull(cast(@sRoles as varchar), '?') +
					' T=' + isnull(cast(@sTeams as varchar), '?') + ' U=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	dbo.tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc, sStaff,  sStfID,  idLvl,  sCode,  bActive )
					values		( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc,    ' ', @sStfID, @idLvl, @sCode, @bActive )
			select	@idOper =	scope_identity( )
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bDuty, 0	--	.8488	must follow table update

			select	@idType =	237,	@s =	'Usr_I( ' + @s + ' )=' + cast(@idOper as varchar)
		end
		else
		begin
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bDuty, 0	--	.8488	must precede table update
			update	dbo.tb_User
				set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
					,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
					,	sStfID =	@sStfID,	idLvl=	@idLvl,	sCode=	@sCode
					,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@idType =	238,	@s =	'Usr_U( ' + @s + ' )'
		end

		if	@bActive = 0													--	.8733	unassign deactivated
		begin
--			delete	from	dbo.tb_UserRole		where	idUser = @idOper	and	idRole > 1
--			delete	from	dbo.tb_UserUnit		where	idUser = @idOper
--			delete	from	dbo.tbTeamUser		where	idUser = @idOper

			update	dbo.tbDvc		set	idUser =	null	where	idUser = @idOper
			update	dbo.tbShift		set	idUser =	null	where	idUser = @idOper
			update	dbo.tbStfAssn	set	bActive =	0		where	idUser = @idOper
		end

		exec	dbo.pr_User_UpdStaff	@idOper
--	-	exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bDuty, 0
		exec	dbo.pr_Log_Ins	@idType, @idUser, @idOper, @s, @idModule

		delete	from	dbo.tb_UserUnit
			where	idUser = @idOper
			and		idUnit	not in	(select	idUnit	from	#tbUnit	with (nolock))

		insert	dbo.tb_UserUnit	( idUnit, idUser )
			select	idUnit, @idOper
				from	#tbUnit	with (nolock)
				where	idUnit	not in	(select	idUnit	from	dbo.tb_UserUnit	with (nolock)	where	idUser = @idOper)

		delete	from	dbo.tbTeamUser
			where	idUser = @idOper
			and		idTeam	not in	(select	idTeam	from	#tbTeam	with (nolock))

		insert	dbo.tbTeamUser	( idTeam, idUser )
			select	idTeam, @idOper
				from	#tbTeam	with (nolock)
				where	idTeam	not in	(select	idTeam	from	dbo.tbTeamUser	with (nolock)	where	idUser = @idOper)

		delete	from	dbo.tb_UserRole
			where	idUser = @idOper
			and		idRole	not in	(select	idRole	from	#tbRole	with (nolock))

		insert	dbo.tb_UserRole	( idRole, idUser )
			select	idRole, @idOper
				from	#tbRole	with (nolock)
				where	idRole	not in	(select	idRole	from	dbo.tb_UserRole	with (nolock)	where	idUser = @idOper)

	commit
end
go
--	----------------------------------------------------------------------------
--	Receivers
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				* .sQnDvc	-> .sQnStn
--	7.06.8139	* .sQnDevice -> .sQnDvc
--	7.06.7262	- .cSys, .tiGID, .tiJID, .tiRID, .sSGJR
--	7.06.7261	+ .cSys, .tiGID, .tiJID
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	7.04.4892	* .idDevice -> .idRoom
--	6.04	* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	6.03
alter view		dbo.vwRtlsRcvr
	with encryption
as
select	r.idReceiver, r.sReceiver	--, r.idRcvrType, t.sRcvrType, r.sPhone, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	r.idRoom, d.cStn, d.sStn, d.sSGJ	--, d.sSGJR
	,	d.sSGJ + ' [' + d.cStn + '] ' + d.sStn	as sQnStn
	,	r.bActive, r.dtCreated, r.dtUpdated
	from	dbo.tbRtlsRcvr	r	with (nolock)
left join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= r.idRoom
go
--	----------------------------------------------------------------------------
--	Returns receivers (filtered)
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8139	* vwRtlsRcvr:	 sQnDevice -> sQnDvc
--	7.06.8276	* output order
--	7.06.6592	+ @bActive, @bRoom
--	7.06.5354	+ order by
--	7.04.4959	+ .sFqDevice
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	7.04.4892	* .idDevice -> .idRoom
--	7.03.4890
alter proc		dbo.prRtlsRcvr_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bRoom		bit			= null	-- null=any, 0=not-in-room, 1=assigned
)
	with encryption
as
begin
--	set	nocount	on
	select	bActive, dtCreated, dtUpdated
		,	idReceiver, sReceiver,	idRoom, sQnStn
		from	dbo.vwRtlsRcvr	with (nolock)
		where	( @bActive is null	or	bActive = @bActive )
		and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
		order	by	idReceiver
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given receiver
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	6.03
alter proc		dbo.prRtlsRcvr_InsUpd
(
	@idReceiver		smallint			-- id
,	@sReceiver		varchar( 255 )		-- name
)
	with encryption
as
begin
---	set	nocount	on
	begin	tran
		if	exists	( select 1 from dbo.tbRtlsRcvr with (nolock) where idReceiver = @idReceiver )
			update	dbo.tbRtlsRcvr
				set		sReceiver=	@sReceiver,	bActive =	1,	dtUpdated=	getdate( )
				where	idReceiver = @idReceiver
		else
			insert	dbo.tbRtlsRcvr	(  idReceiver,  sReceiver )
					values			( @idReceiver, @sReceiver )
	commit
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
		update	dbo.tbRtlsRcvr
			set		idRoom =	@idRoom,	dtUpdated=	getdate( )
			where	idReceiver = @idReceiver
--	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8753	+ n.tiFlags
--	7.06.8740	+ d.sQnDvc
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
select	b.idBadge, n.tiFlags
	,	n.idUser, s.sStfID, s.idLvl, s.sLvl, s.sStaff, s.sQnStf
	,	b.idReceiver, r.sReceiver, b.dtReceiver
	,	r.idRoom, d.cStn, d.sStn, d.sSGJ, d.sQnStn, b.dtEntered	--,	b.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	dbo.tbRtlsBadge	b	with (nolock)
	join	dbo.tbDvc		n	with (nolock)	on	n.idDvc		= b.idBadge
left join	dbo.vwStaff		s	with (nolock)	on	s.idUser	= n.idUser
left join	dbo.tbRtlsRcvr	r	with (nolock)	on	r.idReceiver= b.idReceiver
left join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= r.idRoom
go
--	----------------------------------------------------------------------------
--	Returns badges (filtered)
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8769	+ @bAuto for exclusion of auto-RTLS
--	7.06.8753	+ .tiFlags, bAssn
--	7.06.8306	* .tDuration -> sElapsed
--	7.06.8276	* output order
--	7.06.8137	* sFqStaff -> sQnStf
--	7.06.7292	* .tDuration	(cause time(0) swallows days)
--	7.06.6592	+ @bActive, reordered @rgs, optimized
--	7.06.5354	+ order by
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4959	+ .sFqStaff, @bStaff, @bRoom
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.03.4890
alter proc		dbo.prRtlsBadge_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bStaff		bit			= null	-- null=any, 0=not-assigned, 1=assigned
,	@bRoom		bit			= null	-- null=any, 0=not-in-room, 1=located
,	@bAuto		bit			= 0
)
	with encryption
as
begin
--	set	nocount	on
	select	bActive, dtCreated, dtUpdated
		,	idBadge, tiFlags, cast(tiFlags & 1 as bit)	as	bAssn
		,	sSGJ + ' [' + cStn + '] ' + sStn	as	sCurrLoc
		,	dtEntered	--,	cast( getdate( ) - dtEntered as time( 0 ) )	as	tDuration
		,	right('00' + cast(datediff(ss, dtEntered, getdate())/86400 as varchar), 3) + '.' + convert(char(8), getdate() - dtEntered, 114)	as	sElapsed
		,	idUser, sQnStf,	idRoom
		from	dbo.vwRtlsBadge		with (nolock)
		where	( @bActive is null	or	bActive = @bActive )
		and		( @bStaff is null	or	@bStaff = 0	and	idUser is null	or	@bStaff = 1	and	idUser is not null )
		and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
		and		( @bAuto != 0		or	tiFlags & 2 = 0 )		--	substring(sStaff, 1, 1) != char(0x7F) )
		order	by	idBadge
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge (used by RTLS demo)
--	7.06.8787	+ '& 0x00FFFFFF' enforcement of 24 bits: 1..16777215
--	7.06.8784	* tb_User.idStfLvl	-> idLvl, @
--	7.06.8783	* fix 'exec dbo.pr_User_InsUpd':	@idModule was missing 72==J7981ls
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
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
	@idBadge	int					-- 24 bits: 1..16777215 (0x00FFFFFF) - RTLS badges
,	@idLvl		tinyint				-- 4=Grn, 2=Ora, 1=Yel, 0=None
)
	with encryption, exec as owner
as
begin
	declare		@idUser	int
		,		@sUser	varchar( 32 )
		,		@sRtls	varchar( 16 )

---	set	nocount	on
	select	@idBadge =	@idBadge & 0x00FFFFFF								-- enforce 24 bits: 1..16777215

	begin	tran

		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
		begin
			update	dbo.tbDvc
				set		bActive =	1,	dtUpdated=	getdate( ),	sDial=	cast(@idBadge as varchar)
				where	idDvc = @idBadge	and	bActive = 0

			update	dbo.tbRtlsBadge
				set		bActive =	1,	dtUpdated=	getdate( )
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

		if	0 < @idLvl
		begin
			select	@sUser =	cast(@idBadge as varchar)					--	create a new [tb_User]
				,	@sRtls =	char(0x7F) + 'RTLS'							--	with 0x7F+'RTLS' as .sFrst

			if	not exists	(select 1 from tb_User with (nolock) where sUser = @sUser)
			begin
				exec	dbo.pr_User_InsUpd	72, 2, @idUser out, @sUser, 0, 0, @sRtls, null, @sUser, null, null, @sUser, @idLvl, null, null, null, null, 1, 1
						--	idModule, idUser, idOper out, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc, sStfID, idLvl, sCode, sUnits, sTeams, sRoles, bDuty, bActive

				update	u	set	dtEntered=	getdate( ),	idRoom =	null	--	clear previously assigned user's location
					from	dbo.tb_User u
					join	dbo.tbDvc	d	on	d.idUser = u.idUser
					where	idDvc = @idBadge

				update	dbo.tbDvc	set tiFlags =	3,	idUser =	@idUser	--	mark this badge auto and assignable, and assign it to newly created user
					where	idDvc = @idBadge
			end
			else
			begin
				update	dbo.tbDvc	set	tiFlags =	3
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

		update	dbo.tbRtlsBadge
			set		dtEntered=	@dt,	dtUpdated=	@dt	--,	idRoom =	null
				,	idReceiver =	null,	dtReceiver =	null

		update	dbo.tb_User
			set		dtEntered=	@dt,	idRoom =	null

		update	dbo.tbRoom
			set		dtUpdated=	@dt,	dtExpires=	@dt,	tiCall =	0
				,	idUser4 =	null,	idUser2 =	null,	idUser1 =	null
				,	idUserG =	null,	idUserO =	null,	idUserY =	null
				,	sStaffG =	null,	sStaffO =	null,	sStaffY =	null

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets .bConfig for all devices under a given GW, resets corresponding rooms' state
--	7.06.8795	* prCfgDvc_Init		->	prCfgStn_Init
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.7279	* optimized logging
--	7.06.5940	* optimize logging
--	7.06.5914	+ don't reset tbRoomBed.idUser[i]
--	7.06.5906	+ @cSys, @tiGID
--	7.06.5854	* "cDevice <> 'P'" instead of "tiStype is not null"
--	7.06.5529	+ tbRoomBed reset
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.06.5352	+ 'and tiStype is not null' - don't deactivate SIP devices
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03.4862
create proc		dbo.prCfgStn_Init
(
	@cSys		char( 1 )			-- source system
,	@tiGID		tinyint				-- source G-ID - gateway
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Dvc_Init( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + ' ) '

	begin	tran

		update	r	set	idUnit =	null,	idEvent =	null,	tiSvc =		null,	dtUpdated=	getdate( )
					,	idUserG =	null,	sStaffG =	null,	idUserO =	null,	sStaffO =	null,	idUserY =	null,	sStaffY =	null
			from	dbo.tbRoom		r
			join	dbo.tbCfgStn	d	on	d.idStn	= r.idRoom		and	d.cSys = @cSys	and	d.tiGID = @tiGID
		select	@s =	@s + cast(@@rowcount as varchar) + ' rm, '

		update	rb	set	tiIBed =	null,	idEvent =	null,	tiSvc =		null,	dtUpdated=	getdate( )
--	-				,	idUser1 =	null,	idUser2 =	null,	idUser3 =	null,	idPatient=	null
			from	dbo.tbRoomBed	rb
			join	dbo.tbCfgStn	d	on	d.idStn	= rb.idRoom		and	d.cSys = @cSys	and	d.tiGID = @tiGID
		select	@s =	@s + cast(@@rowcount as varchar) + ' rb, '

		update	dbo.tbCfgStn	set	bConfig =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID
	--		where	bActive > 0
	--		and		cStn <> 'P'												--	skip SIP phones		--	7.06.5854
--			and		tiStype is not null										--	7.06.5352
		select	@s =	@s + cast(@@rowcount as varchar) + ' st'

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgStn_Init				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Resets .bActive for all devices under a given GW, based on .bConfig set after Config download
--	7.06.8795	* prCfgDvc_UpdAct	->	prCfgStn_UpdAct
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.7279	* optimized logging
--	7.06.5940	* optimize logging
--	7.06.5912	+ set current assigned staff
--	7.06.5907
create proc		dbo.prCfgStn_UpdAct
(
	@cSys		char( 1 )			-- source system
,	@tiGID		tinyint				-- source G-ID - gateway
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Dvc_UA( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + ' ) +'

	begin	tran

		update	dbo.tbCfgStn	set	bActive =	1,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig > 0		and	bActive = 0
		select	@s =	@s + cast(@@rowcount as varchar) + ', -'

		update	dbo.tbCfgStn	set	bActive =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig = 0		and	bActive > 0
		select	@s =	@s + cast(@@rowcount as varchar)

		-- set current assigned staff
		update	rb	set		idUser1 =	a.idUser
			from	dbo.tbRoomBed	rb
			join	dbo.tbRoom		r	on	r.idRoom	= rb.idRoom
			join	dbo.tbCfgStn	s	on	s.idStn		= r.idRoom		and	s.cSys = @cSys	and	s.tiGID = @tiGID
			join	dbo.tbUnit		u	on	u.idUnit	= r.idUnit
			join	dbo.tbStfAssn	a	on	a.idRoom	= rb.idRoom		and	a.tiBed = rb.tiBed	and	a.tiIdx = 1
										and	a.idShift	= u.idShift		and	a.bActive > 0

		update	rb	set		idUser2 =	a.idUser
			from	dbo.tbRoomBed	rb
			join	dbo.tbRoom		r	on	r.idRoom	= rb.idRoom
			join	dbo.tbCfgStn	s	on	s.idStn		= r.idRoom		and	s.cSys = @cSys	and	s.tiGID = @tiGID
			join	dbo.tbUnit		u	on	u.idUnit	= r.idUnit
			join	dbo.tbStfAssn	a	on	a.idRoom	= rb.idRoom		and	a.tiBed = rb.tiBed	and	a.tiIdx = 2
										and	a.idShift	= u.idShift		and	a.bActive > 0

		update	rb	set		idUser3 =	a.idUser
			from	dbo.tbRoomBed	rb
			join	dbo.tbRoom		r	on	r.idRoom	= rb.idRoom
			join	dbo.tbCfgStn	s	on	s.idStn		= r.idRoom		and	s.cSys = @cSys	and	s.tiGID = @tiGID
			join	dbo.tbUnit		u	on	u.idUnit	= r.idUnit
			join	dbo.tbStfAssn	a	on	a.idRoom	= rb.idRoom		and	a.tiBed = rb.tiBed	and	a.tiIdx = 3
										and	a.idShift	= u.idShift		and	a.bActive > 0

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgStn_UpdAct				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Deactivates all receivers before RTLS config download
--	7.06.7279	* optimized logging
--	7.06.7117	+ @idModule
--	7.05.5087
alter proc		dbo.prRtlsRcvr_Init
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	begin	tran

		update	dbo.tbRtlsRcvr
			set		bActive =	0,	dtUpdated=	getdate( )
			where	bActive = 1

		select	@s =	cast(@@rowcount as varchar) + ' rcv'

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	48, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Deactivates all badges before RTLS config download
--	7.06.7279	* optimized logging
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = @idModule

	begin	tran

		update	dbo.tbRtlsBadge
			set		bActive =	0,	dtUpdated=	getdate( )
			where	bActive = 1

		update	d
			set		bActive =	0,	dtUpdated=	getdate( )
			from	dbo.tbDvc	d
			join	dbo.tbRtlsBadge	b	on	b.idBadge = d.idDvc
			where	d.bActive = 1

		select	@s =	cast(@@rowcount as varchar) + ' bdg'

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	48, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl, @
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--				- @bGroup
--	7.06.8684	+ @sDvc
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
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes	active?
,	@tiFlags	tinyint		= null	-- null=any, 0=non-assignable, 1=assignable (for pagers 0==group/team), 2=auto (badges)
,	@bStaff		bit			= null	-- null=any, 0=no, 1=yes	assigned?
,	@idLvl		tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
,	@sDvc		varchar(18)	= null	-- null, or '%<name>%'
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sCode, d.sBrowser, d.bActive
		,	b.idRoom, r.sQnRoom
		,	d.idUser, d.idLvl, d.sStfID, d.sStaff, d.bDuty, d.dtDue
		from	dbo.vwDvc		d	with (nolock)
	left join	dbo.vwRtlsBadge	b	with (nolock)	on	b.idBadge	= d.idDvc
	left join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= b.idRoom
		where	d.idDvcType & @idDvcType <> 0
--		and		(@idDvcType <> 1	or	d.tiFlags = 0x02)					--	.assignable
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@tiFlags is null	or	d.tiFlags & @tiFlags = @tiFlags)
		and		(@bStaff is null	or	@bStaff = 0	and	d.idUser is null	or	@bStaff = 1	and	d.idUser is not null )
		and		(@idLvl is null		or	@idLvl = 0	and	d.idLvl is null		or	d.idLvl = @idLvl)
		and		(@sDvc is null		or	d.sDial like @sDvc)					--	7.06.8684
		and		(@idUnit is null	or	d.idDvcType = 1		or	d.idDvcType = 8
									or	d.idDvc	in	(select idDvc from dbo.tbDvcUnit with (nolock) where idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given bar-code
--	7.06.8794	* prDvc_GetByBC		->	prDvc_GetByCode
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.06.7270	* tbRtlsBadge -> vwRtlsBadge
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.06.6282	* tbRtlsRoom -> tbRtlsBadge
--	7.06.5437	+ .dtDue
--	7.06.5428
create proc		dbo.prDvc_GetByCode
(
	@sCode		varchar( 32 )		-- bar-code
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sCode, d.sBrowser, d.bActive
		,	b.idRoom, r.sQnRoom
		,	d.idUser, d.idLvl, d.sStfID, d.sStaff, d.bDuty, d.dtDue
		from	dbo.vwDvc		d	with (nolock)
	left join	dbo.vwRtlsBadge	b	with (nolock)	on	b.idBadge	= d.idDvc
	left join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= b.idRoom
		where	d.bActive > 0
		and		d.sCode = @sCode
end
go
grant	execute				on dbo.prDvc_GetByCode				to [rWriter]
grant	execute				on dbo.prDvc_GetByCode				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given dial-code
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sCode, d.sBrowser, d.bActive
		,	b.idRoom, r.sQnRoom
		,	d.idUser, d.idLvl, d.sStfID, d.sStaff, d.bDuty, d.dtDue
		from	dbo.vwDvc		d	with (nolock)
	left join	dbo.vwRtlsBadge	b	with (nolock)	on	b.idBadge	= d.idDvc
	left join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= b.idRoom
		where	d.bActive > 0
		and		d.sDial = @sDial
end
go
--	----------------------------------------------------------------------------
--	Returns a Wi-Fi device by the given ID
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sCode, d.sBrowser, d.bActive
		,	b.idRoom, r.sQnRoom
		,	d.idUser, d.idLvl, d.sStfID, d.sStaff, d.bDuty, d.dtDue
		from	dbo.vwDvc		d	with (nolock)
	left join	dbo.vwRtlsBadge	b	with (nolock)	on	b.idBadge	= d.idDvc
	left join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= b.idRoom
		where	d.idDvc = @idDvc
		and		d.idDvcType = 0x08											--	Wi-Fi
end
go
--	----------------------------------------------------------------------------
--	7981 - Returns rooms for updating RTLS state
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				* .sQnDevice -> sQnStn
--	7.06.7292	+ tbRoom.idUser4, .idUser2, .idUser1
--	7.06.7262	+ tbRoom.tiCall
--	7.06.6246	+ .sQnDevice, .idUserG, .idUserO, .idUserY, .dtExpires
--				+ and bActive > 0
--	7.06.6226	- tbRtlsRoom (prRtlsRoom_Get -> prRoom_GetRtls)
--	7.06.6198	* only return rooms with presence!
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.05.5192	* include empty names into output
--	6.05
alter proc		dbo.prRoom_GetRtls
(
	@dtNow			datetime	out
)
	with encryption
as
begin
	set	nocount	on

	select	@dtNow =	getdate( )

	set	nocount	off
	select	idStn,	cSys, tiGID, tiJID, tiRID
		,	'[' + cStn + '] ' + sStn		as sQnStn
		,	dtExpires,	tiCall,	idUser4, u4.sStaff, idUser2, u2.sStaff, idUser1, u1.sStaff
		from	dbo.tbCfgStn	d	with (nolock)
		join	dbo.tbRoom		r	with (nolock)	on	r.idRoom	= d.idStn
	left join	dbo.tb_User		u4	with (nolock)	on	u4.idUser	= r.idUser4
	left join	dbo.tb_User		u2	with (nolock)	on	u2.idUser	= r.idUser2
	left join	dbo.tb_User		u1	with (nolock)	on	u1.idUser	= r.idUser1
		where	dtExpires <= @dtNow
		and		d.bActive > 0
end
go
--	----------------------------------------------------------------------------
--	7981 - Extends RTLS healing expiration for rooms with staff present
--	7.06.7292	+ tbRoom.idUser4, .idUser2, .idUser1
--				* tb_OptSys[31]->[8]
--	7.06.6290	* tb_OptSys[9] -> tb_OptSys[31]
--	7.06.6226
alter proc		dbo.prRoom_UpdRtls
(
	@dtNow			datetime
)
	with encryption
as
begin
	declare		@iHealin	int

	set	nocount	on

	select	@iHealin =	iValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 8

	set	nocount	off

	update	dbo.tbRoom
		set		dtExpires=	case when	0 < idUser4  or	 0 < idUser2  or  0 < idUser1
											then	dateadd( ss, @iHealin, dtExpires )
								else	null	end
		where	dtExpires <= @dtNow
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbUnit
	(
		idUnit		smallint		not null	primary key clustered
--	,	sUnit		varchar( 16 )	not null
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	set	nocount off
	if	@tiView = 0			--	ListView
		select	tu.idUnit, rm.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.cStn, ea.sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
			,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGndr, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idLvl1, rb.sStfID1, rb.sStaff1, rb.bDuty1, rb.dtDue1
			,	rb.idUser2, rb.idLvl2, rb.sStfID2, rb.sStaff2, rb.bDuty2, rb.dtDue2
			,	rb.idUser3, rb.idLvl3, rb.sStfID3, rb.sStaff3, rb.bDuty3, rb.dtDue3
			,	rm.idUserG, rm.idLvlG, rm.sStfIDG, rm.sStaffG, rm.bDutyG, rm.dtDueG
			,	rm.idUserO, rm.idLvlO, rm.sStfIDO, rm.sStaffO, rm.bDutyO, rm.dtDueO
			,	rm.idUserY, rm.idLvlY, rm.sStfIDY, rm.sStaffY, rm.bDutyY, rm.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
	--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
			from	dbo.vwEvent_A	ea	with (nolock)
			join		#tbUnit		tu	with (nolock)	on	tu.idUnit	= ea.idUnit
		left join	dbo.vwRoomBed	rb	with (nolock)	on	rb.idRoom	= ea.idRoom		and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
		left join	dbo.vwRoom		rm	with (nolock)	on	rm.idRoom	= ea.idRoom
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	siFlags & 0x0100 = 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )	--	7.06.8343	not Clinic
			and		dbo.fnEventA_GetByMaster( @idMaster, ea.idRoom, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed desc		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, rm.sUnit,	rb.cSys, rb.tiGID, rb.tiJID, rb.tiRID, ea.tiBtn
			,	rb.idRoom, rb.cStn, rb.sRoom,	rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
			,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGndr, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idLvl1, rb.sStfID1, rb.sStaff1, rb.bDuty1, rb.dtDue1
			,	rb.idUser2, rb.idLvl2, rb.sStfID2, rb.sStaff2, rb.bDuty2, rb.dtDue2
			,	rb.idUser3, rb.idLvl3, rb.sStfID3, rb.sStaff3, rb.bDuty3, rb.dtDue3
			,	rm.idUserG, rm.idLvlG, rm.sStfIDG, rm.sStaffG, rm.bDutyG, rm.dtDueG
			,	rm.idUserO, rm.idLvlO, rm.sStfIDO, rm.sStaffO, rm.bDutyO, rm.dtDueO
			,	rm.idUserY, rm.idLvlY, rm.sStfIDY, rm.sStaffY, rm.bDutyY, rm.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	p8.tiDome	as	tiDome8,	p4.tiDome	as	tiDome4,	p2.tiDome	as	tiDome2,	p1.tiDome	as	tiDome1
			from	dbo.vwRoomBed	rb	with (nolock)
			join		#tbUnit		tu	with (nolock)	on	tu.idUnit	= rb.idUnit
		left join	dbo.vwRoom		rm	with (nolock)	on	rm.idRoom	= rb.idRoom
		outer apply	dbo.fnEventA_GetTopByRoom(  rb.idRoom, rb.tiBed, @iFilter, @idMaster, 0 )	ea
		outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 8 )	p8
		outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 4 )	p4
		outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 2 )	p2
		outer apply	dbo.fnEventA_GetDomeByRoom( rb.idRoom, rb.tiBed, @idMaster, 1 )	p1
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, u.sUnit,		ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.cStn, ea.sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
			,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGndr, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idLvl1, rb.sStfID1, rb.sStaff1, rb.bDuty1, rb.dtDue1
			,	rb.idUser2, rb.idLvl2, rb.sStfID2, rb.sStaff2, rb.bDuty2, rb.dtDue2
			,	rb.idUser3, rb.idLvl3, rb.sStfID3, rb.sStaff3, rb.bDuty3, rb.dtDue3
			,	rm.idUserG, rm.idLvlG, rm.sStfIDG, rm.sStaffG, rm.bDutyG, rm.dtDueG
			,	rm.idUserO, rm.idLvlO, rm.sStfIDO, rm.sStaffO, rm.bDutyO, rm.dtDueO
			,	rm.idUserY, rm.idLvlY, rm.sStfIDY, rm.sStaffY, rm.bDutyY, rm.dtDueY
			,	mc.tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
			from		#tbUnit		tu	with (nolock)
			join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= tu.idUnit
		outer apply	dbo.fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea
		left join	dbo.vwRoomBed	rb	with (nolock)	on	rb.idRoom	= ea.idRoom		and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )
		left join	dbo.vwRoom		rm	with (nolock)	on	rm.idRoom	= ea.idRoom
		outer apply	dbo.fnMapCell_GetMap( tu.idUnit, ea.idRoom )	mc
			order	by	2	--	rm.sUnit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
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
		,	rm.idRoom,	rm.cStn, rm.sRoom,		ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.siFlags, ea.tiSpec, ea.sCall, ea.tiColor
		,	ea.tiTone, ea.tiIntTn, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, rb.sPatient, rb.cGndr, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idUser1, rb.idLvl1, rb.sStfID1, rb.sStaff1, rb.bDuty1, rb.dtDue1		-- assigned staff
		,	rb.idUser2, rb.idLvl2, rb.sStfID2, rb.sStaff2, rb.bDuty2, rb.dtDue2
		,	rb.idUser3, rb.idLvl3, rb.sStfID3, rb.sStaff3, rb.bDuty3, rb.dtDue3
		,	rm.idUserG, rm.idLvlG, rm.sStfIDG, rm.sStaffG, rm.bDutyG, rm.dtDueG		-- present staff
		,	rm.idUserO, rm.idLvlO, rm.sStfIDO, rm.sStaffO, rm.bDutyO, rm.dtDueO
		,	rm.idUserY, rm.idLvlY, rm.sStfIDY, rm.sStaffY, rm.bDutyY, rm.dtDueY
		,	mc.tiMap
--	-	,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
		,	p8.tiDome	as	tiDome8,	p4.tiDome	as	tiDome4,	p2.tiDome	as	tiDome2,	p1.tiDome	as	tiDome1
		,	mc.tiCell, mc.sCell1, mc.sCell2,	rm.siBeds, rm.sBeds,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	dbo.tbMapCell	mc	with (nolock)
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= mc.idUnit
	left join	dbo.vwRoom		rm	with (nolock)	on	rm.idRoom	= mc.idRoom		and	rm.bActive > 0
	outer apply	dbo.fnEventA_GetTopByRoom( mc.idRoom, null, @iFilter, @idMaster, 1 )	ea		--	7.03
	left join	dbo.vwRoomBed	rb	with (nolock)	on	rb.idRoom	= ea.idRoom
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
--	Data source for 7983rh.CallList.aspx (based on dbo.prRoomBed_GetByUnit)
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.6164
alter proc		dbo.prCallList_GetAll
(
	@iFilter	int					-- filter mask
)
	with encryption
as
begin
--	set	nocount off

	select	idEvent, dtEvent, idRoom, sRoomBed, siIdx, sCall, tiColor, tElapsed, iFilter, bAudio, bAnswered		--, iColorF, iColorB
		from	dbo.vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0		and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
		order	by	bAnswered, siIdx desc, tElapsed desc		--	call may have been started before it was recorded (idEvent)
end
go
--	----------------------------------------------------------------------------
--	Returns assigned staff for given room-bed
--	7.06.8795	* prDevice_InsUpd	-> prCfgStn_InsUpd
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8343	* vwStaff.sStaffID	-> sStfID
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
--,	@sDevice	varchar( 16 )		-- device name
,	@sStn		varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index (0-9, 255)
--,	@idUnit		smallint	= null	-- active unit ID
)
	with encryption
as
begin
	declare		@idRoom		int

	set	nocount	on

	select	@tiRID =	0		--	force 0 - looking for a room

	exec	dbo.prCfgStn_GetIns		@cSys, @tiGID, @tiJID, @tiRID, null, null, null, @sStn, null, @idRoom out

	set	nocount	off

	select	idUser1, idLvl1, sStfID1, sStaff1, bDuty1, dtDue1
		,	idUser2, idLvl2, sStfID2, sStaff2, bDuty2, dtDue2
		,	idUser3, idLvl3, sStfID3, sStaff3, bDuty3, dtDue3
		from	dbo.vwRoomBed	with (nolock)
		where	idRoom = @idRoom
		and		(tiBed = @tiBed		or	@tiBed = 0xFF	and	tiBed = 1)		--	for room level take assignments from bed-A
end
go
--	----------------------------------------------------------------------------
--	Returns assigned room-beds for the given staff member
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.5437
alter proc		dbo.prStaff_GetAssn
(
	@idUser		int					-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idAssn, idRoom, tiBed, cStn, sRoom, tiIdx
		from	dbo.vwStfAssn	a	with (nolock)
		join	dbo.tbUnit		u	with (nolock)	on	u.idShift	= a.idShift		and	u.bActive > 0
		where	a.bActive > 0
		and		idUser = @idUser
		order	by	sRoom, tiBed
end
go
--	----------------------------------------------------------------------------
--	Returns all report templates
--	7.06.6401	+ .tiFlags
--	7.03
alter proc		dbo.prReport_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idReport, sReport, sRptName, sClass, tiFlags
		from	dbo.tbReport	with (nolock)
		order	by	siOrder
end
go
--	----------------------------------------------------------------------------
--	Inserts/removes access record
--	7.04.4913
alter proc		dbo.pr_RoleRpt_Set
(
	@idRole		smallint
,	@idReport	smallint			-- null=all (deny only)
,	@bAccess	bit					-- 1=grant, 0=deny
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

--	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		if	@bAccess > 0
			if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole = @idRole and idReport = @idReport)
				insert	dbo.tb_RoleRpt	(  idRole,  idReport )
						values			( @idRole, @idReport )
		else
	/*		if	@idReport is null
				delete	from	tb_RoleRpt
					where	idRole = @idRole	and	idReport = @idReport
			else
	*/			delete	from	dbo.tb_RoleRpt
					where	idRole = @idRole
						and	(idReport = @idReport	or	@idReport is null)

/*		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', p=' + isnull(cast(@idParent as varchar), '?') +
						', l=' + isnull(cast(@tiLvl as varchar), '?') + ', c=' + isnull(@cLoc, '?') + ', n=' + isnull(@sLoc, '?') + ' )'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
*/	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all filters for given user, [public] first, ordered by name
--	7.05.5064	+ check user for IsAdmin
--	7.05.5044	* @idUser: smallint -> int
--	7.03
alter proc		dbo.prFilter_GetByUser
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on

	if	exists(	select 1 from dbo.tb_UserRole where idUser = @idUser and idRole = 2 )

		select	idFilter, idUser, sFilter		--, xFilter
			from	dbo.tbFilter	with (nolock)
	--		where	idUser is null
	--			or	idUser = @idUser
			order	by	idUser, sFilter
	else
		select	idFilter, idUser, sFilter		--, xFilter
			from	dbo.tbFilter	with (nolock)
			where	idUser is null
				or	idUser = @idUser
			order	by	idUser, sFilter
end
go
--	----------------------------------------------------------------------------
--	Returns an existing filter definition
--	7.03
alter proc		dbo.prFilter_Get
(
	@idFilter	smallint out
)
	with encryption
as
begin
--	set	nocount	on

	select	xFilter
		from	dbo.tbFilter	with (nolock)
		where	idFilter = @idFilter
end
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing filter
--	7.05.5044	* @idUser: smallint -> int
--	7.03
alter proc		dbo.prFilter_InsUpd
(
	@idFilter	smallint		out
,	@idUser		int					-- null == public filter
,	@sFilter	varchar( 64 )		-- filter name
,	@xFilter	xml					-- filter definition (xml)
)
	with encryption
as
begin
	declare		@id		smallint

	set	nocount	on

	-- check that filter name is unique per user
	select	@id =	idFilter
		from	dbo.tbFilter
		where	(idUser = @idUser	or	@idUser is null	and	idUser is null)
			and	sFilter = @sFilter

	if	@id <> @idFilter	return	-1		-- name is already in use

	begin	tran

		if	@idFilter > 0
		begin
			update	dbo.tbFilter
				set		idUser =	@idUser,	sFilter =	@sFilter,	xFilter =	@xFilter,	dtUpdated=	getdate( )
				where	idFilter = @idFilter
		end
		else
		begin
			insert	dbo.tbFilter	(  idUser,  sFilter,  xFilter )
					values			( @idUser, @sFilter, @xFilter )
			select	@idFilter=	scope_identity( )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_SessCall') and name = 'tVoTrg')
begin
	begin tran
		exec sp_rename 'tb_SessCall.tVoTrg',	'tVoice',	'column'
		exec sp_rename 'tb_SessCall.tStTrg',	'tStaff',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Report device filters (active during a user session)
--	7.06.8795	* tb_SessDvc	->	tb_SessStn
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	6.00	tbRptSessDvc -> tb_SessDvc, .idRptSess -> .idSess
--	2.01
create table	dbo.tb_SessStn
(
	idSess		int				not null
--		constraint	fk_SessDvc_Sess		foreign key references tb_Sess
		constraint	fk_SessStn_Sess		foreign key references tb_Sess
--,	idDevice	smallint		not null
,	idStn		smallint		not null
--		constraint	fk_SessDvc_Device	foreign key references tbDevice
		constraint	fk_SessStn_Device	foreign key references tbCfgStn
	
--,	constraint	xp_SessDvc	primary key clustered ( idSess, idDevice )
,	constraint	xp_SessStn	primary key clustered ( idSess, idStn )
)
go
grant	select, insert, update, delete	on dbo.tb_SessStn		to [rWriter]		--	7.03
grant	select, insert, update, delete	on dbo.tb_SessStn		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's module filter
--	7.06.6526	* tb_SessLog -> tb_SessMod
--	7.06.6310
alter proc		dbo.pr_SessMod_Ins
(
	@idSess		int
,	@idModule	smallint
)
	with encryption
as
begin
	set	nocount	on

	if	not	exists	(select 1 from dbo.tb_SessMod with (nolock) where idSess = @idSess and idModule = @idModule)
--	begin
--		begin	tran
			insert	dbo.tb_SessMod	(  idSess,  idModule )
					values		( @idSess, @idModule )
--		commit
--	end
	else
		return	-1		-- room is already included
end
go
--	----------------------------------------------------------------------------
--	Cleans-up session's module tables
--	7.06.6526	* tb_SessLog -> tb_SessMod
--	7.06.6310
alter proc		dbo.pr_SessMod_Clr
(
	@idSess		int
)
	with encryption
as
begin
--	set	nocount	on
--	begin	tran

		delete	from	dbo.tb_SessMod		where	idSess = @idSess

--	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a session's call filter
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.03
alter proc		dbo.pr_SessCall_Ins
(
	@idSess		int
,	@idCall		smallint
,	@siIdx		smallint
--,	@sCall		varchar( 16 )
,	@tVoice		time( 0 )
,	@tStaff		time( 0 )
)
	with encryption
as
begin
	declare		@sCall	varchar( 16 )

	set	nocount	on

	select	@sCall= sCall
		from	dbo.tbCfgPri	with (nolock)	where	siIdx = @siIdx

	begin	tran

		insert	dbo.tb_SessCall	(  idSess,  idCall,  siIdx,  sCall,  tVoice,  tStaff )
				values			( @idSess, @idCall, @siIdx, @sCall, @tVoice, @tStaff )
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a session's room filter
--	7.06.8795	* pr_SessDvc_Ins	->	pr_SessStn_Ins
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.03
create proc		dbo.pr_SessStn_Ins
(
	@idSess		int
,	@idStn		smallint
)
	with encryption
as
begin
	set	nocount	on

	if	not	exists	(select 1 from dbo.tb_SessStn with (nolock) where idSess = @idSess and idStn = @idStn)
--	begin
--		begin	tran
			insert	dbo.tb_SessStn	(  idSess,  idStn )
					values			( @idSess, @idStn )
--		commit
--	end
	else
		return	-1		-- room is already included
end
go
grant	execute				on dbo.pr_SessStn_Ins				to [rWriter]
grant	execute				on dbo.pr_SessStn_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's staff filter
--	7.05.5010	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.pr_SessUser_Ins
(
	@idSess		int
,	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
--	begin	tran

		insert	dbo.tb_SessUser		(  idSess,  idUser )
				values				( @idSess, @idUser )

--	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a session's shift filter
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.pr_SessShift_Ins
(
	@idSess		int
,	@idShift	int
)
	with encryption
as
begin
--	set	nocount	on
--	begin	tran

		insert	dbo.tb_SessShift	(  idSess,  idShift )
				values				( @idSess, @idShift )

--	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans-up session's filter tables
--	7.06.8795	* tb_SessDvc	->	tb_SessStn
--	7.06.6526	* tb_SessLog	->	tb_SessMod
--	7.06.6303	+ tb_SessLog
--	7.05.5038	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser
--				* @idSess == null, remove from all related tables (pr_Sess_Del)
--	7.04.4947	- tb_SessLoc
--	7.03
alter proc		dbo.pr_Sess_Clr
(
	@idSess		int				-- null=all
)
	with encryption
as
begin
	set	nocount	on
	begin	tran

		delete	from	dbo.tb_SessUser		where	idSess = @idSess	or	@idSess is null
		delete	from	dbo.tb_SessShift	where	idSess = @idSess	or	@idSess is null
		delete	from	dbo.tb_SessCall		where	idSess = @idSess	or	@idSess is null
		delete	from	dbo.tb_SessMod		where	idSess = @idSess	or	@idSess is null
--	-	delete	from	dbo.tb_SessLoc		where	idSess = @idSess	or	@idSess is null
		delete	from	dbo.tb_SessStn		where	idSess = @idSess	or	@idSess is null

	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans-up a given one or all sessions for a module
--	7.06.8802	* .idLogType -> idType, @
--	7.06.6737	+ @idModule <> 61 (J7980ns) check
--	7.06.5940	* optimize
--	7.05.5246	- @idUser, @sIpAddr, @sMachine
--	7.05.5227	+ @idModule
--	7.05.5038	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser
--				* use pr_Sess_Clr for both app-end and sess-end cases
--	7.04.4947	- tb_SessLoc
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ @bLog
--			* uses pr_Sess_Clr now
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02	+ clean-up tb_SessStaff, tb_SessShift
--	6.00	prRptSess_Del -> pr_Sess_Del, revised
--			calls pr_User_Logout now and utilizes timeout option
--	5.01	encryption added
--	4.01
--	2.01	+ tbRptSessDvc (prRptSess_Del)
--	1.06
alter proc		dbo.pr_Sess_Del
(
	@idSess		int					-- 0 = application-end (delete all sessions)
,	@bLog		bit		=	1		-- log-out user (for individual session)?
,	@idModule	tinyint	=	null	-- indicates app, required if @idSess=0
)
	with encryption
as
begin
	declare		@idType		tinyint
		,		@iTout		int

	set	nocount	on

	select	@iTout =	iValue	from	dbo.tb_OptSys	where	idOption = 1

	begin	tran

		if	@idSess > 0		-- sess-end
		begin
			if	@bLog > 0
			begin
				select	@idType =	case when	@idModule <> 61	and	dateadd( ss, -10, dateadd( mi, @iTout, dtLastAct ) ) < getdate( )
											then	230
											else	229	end
					from	dbo.tb_Sess		with (nolock)
					where	idSess = @idSess

				exec	dbo.pr_User_Logout	@idSess, @idType
			end

			exec	dbo.pr_Sess_Clr		@idSess

			delete	from	tb_Sess		where	idSess = @idSess
		end
		else				-- app-end
		begin
			declare	cur		cursor fast_forward for
				select	idSess
					from	dbo.tb_Sess
					where	idModule = @idModule

			open	cur
			fetch next from	cur	into	@idSess
			while	@@fetch_status = 0
			begin
				exec	dbo.pr_User_Logout	@idSess, 230
				exec	dbo.pr_Sess_Clr		@idSess

				delete	from	dbo.tb_Sess		where	idSess = @idSess
			
				fetch next from	cur	into	@idSess
			end
			close	cur
			deallocate	cur
	--	-	exec	dbo.pr_Sess_Clr		null
	--	-	delete	from	tb_Sess
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Deletes sessions that are older than 24 hours
--	7.06.8796	* tb_Sess.sMachine -> .sHost, @
--	7.06.8411
alter proc		dbo.pr_Sess_Maint
	with encryption
as
begin
	declare		@idSess		int

	set	nocount	on

	declare	cur		cursor fast_forward for
		select	idSess
			from	dbo.tb_Sess
			where	sHost is not null 
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
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
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

	select	@tiPurge =	cast(iValue as tinyint)	from	dbo.tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	c	set		c.idEvtV =	null						-- implements CASCADE SET NULL
					from	dbo.tbEvent_C	c
				left join	dbo.tbEvent_A	a	on	a.idEvent	= c.idEvtV
					where	a.idEvent is null

				update	c	set		c.idEvtS =	null
					from	dbo.tbEvent_C	c
				left join	dbo.tbEvent_A	a	on	a.idEvent	= c.idEvtS
					where	a.idEvent is null

				update	d	set		d.idEvtP =	null						-- implements CASCADE SET NULL
					from	dbo.tbEvent_D	d
				left join	dbo.tbEvent_A	a	on	a.idEvent	= d.idEvtP
					where	a.idEvent is null

				update	d	set		d.idEvtS =	null
					from	dbo.tbEvent_D	d
				left join	dbo.tbEvent_A	a	on	a.idEvent	= d.idEvtS
					where	a.idEvent is null

				update	d	set		d.idEvtD =	null
					from	dbo.tbEvent_D	d
				left join	dbo.tbEvent_A	a	on	a.idEvent	= d.idEvtD
					where	a.idEvent is null

				delete	e	from	dbo.tbEvent	e
						left join	dbo.tbEvent_A	a	on	a.idEvent	= e.idEvent
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
				from	dbo.tbEvent_S
				where	dEvent <= dateadd(dd, -@tiPurge, @dt)
				and		tiHH <= datepart(hh, @dt)

			if	@idEvent is null											--	7.06.5618
				select	@idEvent =	min(idEvent)							-- get earliest idEvent to stay
					from	dbo.tbEvent_S
					where	dateadd(dd, -@tiPurge, @dt) < dEvent

			if	0 < @idEvent												--	7.06.5648
			begin
				delete	from	dbo.tbEvent_B
					where	idEvent < @idEvent

				update	tb_OptSys	set	iValue =	@idEvent,	dtUpdated=	@dt		where	idOption = 11
			end

		end

		exec	dbo.pr_Sess_Maint

	commit
end
go
--	----------------------------------------------------------------------------
--	Registers Wi-Fi devices
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8783	* .sStaffID -> sStfID, @
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
,	@sStfID		varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@bActive	bit
		,		@idType		tinyint

	set	nocount	on

	select	@s =	'@ ' + isnull( @sIpAddr, '?' ) + ' ''' + isnull( @sUser, '?' ) + ''''

	select	@bActive =	bActive
		from	dbo.tbDvc		with (nolock)
		where	idDvc = @idDvc
		and		idDvcType = 0x08		--	wi-fi

	if	@bActive is null		--	wrong dvc
	begin
		select	@idType =	226		--,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule
		return	@idType
	end

	if	@bActive = 0			--	inactive dvc
	begin
		select	@idType =	227,	@s =	@s + ', [' + isnull( @idDvc, '?' ) + ']'
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, @idModule
		return	@idType
	end

	select	@idUser =	idUser
		from	dbo.tb_User		with (nolock)
		where	(sUser = lower( @sUser )	or	sStfID = @sUser)

	if	@idUser is null			--	wrong user
	begin
		select	@idType =	222		--,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idType, null, null, @s, @idModule
		return	@idType
	end

	exec				dbo.pr_Sess_Ins		@sSessID, @idModule, null, @sIpAddr, @sDvc, 0, @sBrowser, @idSess out
	exec	@idType =	dbo.pr_User_Login	@idSess, @sUser, @iHash, @idUser out, @sStaff out, @bAdmin out, @sStfID out

	if	@idType = 221		--	success
	begin
		begin	tran

			exec	dbo.prStaff_SetDuty		@idModule, @idUser, 1, 0

			update	dbo.tbDvc
				set		idUser =	@idUser,	sDvc =	@sDvc,	sBrowser =	@sBrowser
				where	idDvc = @idDvc

		commit
	end

	return	@idType
end
go
--	----------------------------------------------------------------------------
--	UnRegisters Wi-Fi devices
--	7.06.6737	* optimize
--	7.06.6668	+ if @idDvc > 0 branch
--	7.06.6564	+ @idSess, @idModule
--	7.06.6459
alter proc		dbo.prDvc_UnRegWiFi
(
	@idSess		int					-- 0 = application-end (delete all sessions)
,	@idDvc		int		=	0		-- 0 = any (app-end), 
,	@idModule	tinyint	=	null	-- indicates app, required if @idSess=0
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		update	dbo.tbDvc
			set		idUser =	null
			where	idDvcType = 0x08		--	wi-fi
			and		(@idDvc = 0		or	idDvc = @idDvc)

		exec	dbo.pr_Sess_Del		@idSess, 1, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering condition into tb_Log.idLog range
--	7.06.8711	* @dFrom, @dUpto:	datetime -> date
--	7.06.8705	* modified lowest @iFrom (0 -> 0x80000000 = -2147483648)
--	7.06.6534	* modified for null date-args
--	7.06.6512
alter proc		dbo.pr_Log_XltDtEvRng
(
	@dFrom		date				-- date from
,	@dUpto		date				-- date upto
,	@tFrom		tinyint				-- hour from
,	@tUpto		tinyint				-- hour upto
,	@iFrom		int			out		-- idLog from
,	@iUpto		int			out		-- idLog upto
)
	with encryption
as
begin
	set	nocount	on

	if	@dFrom is null
		select	@iFrom =	0x80000000		--	min int (-2147483648)
	else
		select	@iFrom =	min(idLog)
			from	dbo.tb_Log_S	with (nolock)
			where	@dFrom <= dLog	and	@tFrom <= tiHH

	if	@dUpto is null
		select	@iUpto =	0x7FFFFFFF		--	max int (2147483647)
	else
		select	@iUpto =	min(idLog)
			from	dbo.tb_Log_S	with (nolock)
			where	@dUpto = dLog	and	@tUpto < tiHH
				or	@dUpto < dLog

	if	@iUpto is null
		select	@iUpto =	0x7FFFFFFF		--	max int (2147483647)

--	select	@dFrom [dFrom], @iFrom [idFrom], @dUpto [dUpto], @iUpto [idUpto]
end
go
--	----------------------------------------------------------------------------
--	Returns activity log entries in a page of given size
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8711	* @dFrom, @dUpto:	datetime -> date
--				* optimized performance
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
,	@dFrom		date		=	null	-- 
,	@dUpto		date		=	null	-- 
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

	select	@iIndex =	@iIndex * @iCount + 1,	@iPages =	0				-- index of the 1st output row

	if	@bGroup = 0
	begin
		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	dbo.tb_Log	with (nolock)
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	dbo.tb_Log	with (nolock)
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					order	by	idLog desc
			end
			else										-- filter by source
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	dbo.tb_Log		l	with (nolock)
					join	dbo.tb_SessMod	m	with (nolock)	on	m.idModule	= l.idModule	and	m.idSess	= @idSess
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	dbo.tb_Log		l	with (nolock)
					join	dbo.tb_SessMod	m	with (nolock)	on	m.idModule	= l.idModule	and	m.idSess	= @idSess
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					order	by	idLog desc
			end
		else											-- filter by level or category
			if	@idSess = 0
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	dbo.tb_Log		l	with (nolock)
					join	dbo.tb_LogType	t	with (nolock)	on	t.idType	= l.idType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	dbo.tb_Log		l	with (nolock)
					join	dbo.tb_LogType	t	with (nolock)	on	t.idType	= l.idType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by	idLog desc
			end
			else										-- filter by source
			begin
				select	@iPages =	ceiling( count(*) / @iCount )
					from	dbo.tb_Log		l	with (nolock)
					join	dbo.tb_SessMod	m	with (nolock)	on	m.idModule	= l.idModule	and	m.idSess = @idSess
					join	dbo.tb_LogType	t	with (nolock)	on	t.idType	= l.idType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0

				set	rowcount	@iIndex
				select	@idLog =	idLog
					from	dbo.tb_Log		l	with (nolock)
					join	dbo.tb_SessMod	m	with (nolock)	on	m.idModule	= l.idModule	and	m.idSess = @idSess
					join	dbo.tb_LogType	t	with (nolock)	on	t.idType	= l.idType
					where	idLog	between	@iFrom	and @iUpto
					and		tiHH	between @tFrom	and @tUpto
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by	idLog desc
			end

		set	rowcount	@iCount
		set	nocount	off

		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idLog, l.dtLog, l.idType, t.sType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and	@idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					order	by 1 desc
			else										-- filter by source
				select	l.idLog, l.dtLog, l.idType, t.sType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					order	by 1 desc
		else											-- filter by level or category
			if	@idSess = 0
				select	l.idLog, l.dtLog, l.idType, t.sType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by 1 desc
			else										-- filter by source
				select	l.idLog, l.dtLog, l.idType, t.sType, t.tiLvl, t.tiCat, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					order	by 1 desc
	end
	else
	begin
		set	rowcount	0
		set	nocount	off

		if	@tiLvl = 0xFF  and  @tiCat = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sType) as sType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and	@iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					group	by	l.idType
					order	by	lQty	desc
			else										-- filter by source
				select	l.idType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sType) as sType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					group	by	l.idType
					order	by	lQty	desc
		else											-- filter by level or category
			if	@idSess = 0
				select	l.idType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sType) as sType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					group	by	l.idType
					order	by	lQty	desc
			else										-- filter by source
				select	l.idType, min(t.tiLvl) as tiLvl, min(tiCat) as tiCat, min(t.sType) as sType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	s	with (nolock)	on s.idModule	= l.idModule		and	s.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idType		= l.idType
				left join	tb_Module	m	with (nolock)	on m.idModule	= l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser		= l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiCat & @tiCat > 0
					group	by	l.idType
					order	by	lQty	desc
	end
end
go
--	----------------------------------------------------------------------------
--	Exports all role-unit combinations
--	7.06.6816
alter proc		dbo.pr_UserUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idUnit, dtCreated
		from	dbo.tb_UserUnit		with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a role-unit combination
--	7.06.6816
alter proc		dbo.pr_UserUnit_Imp
(
	@idUser		int					--	0=clear table
,	@idUnit		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idUser > 0
		begin
			if	not	exists	(select 1 from dbo.tb_UserUnit with (nolock) where idUser = @idUser and idUnit = @idUnit)
--			begin
				insert	dbo.tb_UserUnit	(  idUser,  idUnit,  dtCreated )
						values			( @idUser, @idUnit, @dtCreated )
--			end
		end
		else
			delete	from	dbo.tb_UserUnit

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all team-user combinations
--	7.06.6816
alter proc		dbo.prTeamUser_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idUser, dtCreated
		from	dbo.tbTeamUser	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a team-user combination
--	7.06.6816
alter proc		dbo.prTeamUser_Imp
(
	@idTeam		smallint			--	0=clear table
,	@idUser		int
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from dbo.tbTeamUser with (nolock) where idTeam = @idTeam and idUser = @idUser)
--			begin
				insert	dbo.tbTeamUser	(  idTeam,  idUser,  dtCreated )
						values			( @idTeam, @idUser, @dtCreated )
--			end
		end
		else
			delete	from	dbo.tbTeamUser

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all team-call combinations
--	7.06.6816
alter proc		dbo.prTeamCall_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, siIdx, dtCreated
		from	dbo.tbTeamCall	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a team-call combination
--	7.06.6816
alter proc		dbo.prTeamCall_Imp
(
	@idTeam		smallint			--	0=clear table
,	@siIdx		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from dbo.tbTeamCall with (nolock) where idTeam = @idTeam and siIdx = @siIdx)
--			begin
				insert	dbo.tbTeamCall	(  idTeam,  siIdx,  dtCreated )
						values			( @idTeam, @siIdx, @dtCreated )
--			end
		end
		else
			delete	from	dbo.tbTeamCall

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all team-unit combinations
--	7.06.6816
alter proc		dbo.prTeamUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idUnit, dtCreated
		from	dbo.tbTeamUnit	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a team-unit combination
--	7.06.6816
alter proc		dbo.prTeamUnit_Imp
(
	@idTeam		smallint			--	0=clear table
,	@idUnit		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from dbo.tbTeamUnit with (nolock) where idTeam = @idTeam and idUnit = @idUnit)
--			begin
				insert	dbo.tbTeamUnit	(  idTeam,  idUnit,  dtCreated )
						values			( @idTeam, @idUnit, @dtCreated )
--			end
		end
		else
			delete	from	dbo.tbTeamUnit

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all team-dvc combinations
--	7.06.6816
alter proc		dbo.prTeamDvc_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idDvc, dtCreated
		from	dbo.tbTeamDvc	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a team-dvc combination
--	7.06.6816
alter proc		dbo.prTeamDvc_Imp
(
	@idTeam		smallint			--	0=clear table
,	@idDvc		int
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idTeam > 0
		begin
			if	not	exists	(select 1 from dbo.tbTeamDvc with (nolock) where idTeam = @idTeam and idDvc = @idDvc)
--			begin
				insert	dbo.tbTeamDvc	(  idTeam,  idDvc,  dtCreated )
						values			( @idTeam, @idDvc, @dtCreated )
--			end
		end
		else
			delete	from	dbo.tbTeamDvc

	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all dvc-unit combinations
--	7.06.6816
alter proc		dbo.prDvcUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idUnit, dtCreated
		from	dbo.tbDvcUnit	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Imports a dvc-unit combination
--	7.06.6816
alter proc		dbo.prDvcUnit_Imp
(
	@idDvc		int					--	0=clear table
,	@idUnit		smallint
,	@dtCreated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	@idDvc > 0
		begin
			if	not	exists	(select 1 from dbo.tbDvcUnit with (nolock) where idDvc = @idDvc and idUnit = @idUnit)
--			begin
				insert	dbo.tbDvcUnit	(  idDvc,  idUnit,  dtCreated )
						values			( @idDvc, @idUnit, @dtCreated )
--			end
		end
		else
			delete	from	dbo.tbDvcUnit

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns an existing schedule
--	7.06.5886	+ .tiFmt
--	7.06.5659	+ .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_GetToRun
--	7.03
alter proc		dbo.prSchedule_Get
(
	@idSchedule	smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult, s.tiFmt, s.sSendTo
		,	s.idUser	as	idOwner,	u.sUser	as	sOwner
		,	s.idReport, r.sReport, r.sRptName, r.sClass
		,	s.idFilter,	null as idUser,	null as sFilter, null as xFilter		-- f.sFilter, f.xFilter, f.idUser
		,	s.bActive, s.dtCreated, s.dtUpdated
		from	dbo.tbSchedule	s	with (nolock)
		join	dbo.tbReport	r	with (nolock)	on	r.idReport	= s.idReport
--		join	dbo.tbFilter	f	with (nolock)	on	f.idFilter	= s.idFilter
		join	dbo.tb_User		u	with (nolock)	on	u.idUser	= s.idUser
		where	idSchedule = @idSchedule
end
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing schedule
--	7.06.5886	+ .tiFmt
--	7.05.5044	* @idUser: smallint -> int
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.prSchedule_InsUpd
(
	@idSchedule	smallint
,	@tiRecur	tinyint				-- hi 3 bits: 32=Daily, 64=Weekly, 128=Monthly;  lo 5 bits: either 1..31 (D,W), or 1=1st, 2=2nd, 4=3rd, 8=4th, 16=Last
,	@tiWkDay	tinyint				-- 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
,	@siMonth	smallint			-- 1=Jan, 2=Feb, 4=Mar, 8=Apr, 16=May, 32=Jun, 64=Jul, 128=Aug, 256=Sep, 512=Oct, 1024=Nov, 2048=Dec
,	@sSchedule	varchar( 255 )		-- auto: spelled out schedule details
--,	@dtLastRun	smalldatetime		-- when last execution started
,	@dtNextRun	smalldatetime		-- when next execution should start, HH:mm part stores the "Run @" value
--,	@iResult	smallint			-- for last run: 0=Success, !0==Error code
,	@idUser		int					-- requester
,	@idFilter	smallint
,	@idReport	smallint
,	@tiFmt		tinyint				-- 1=PDF, 2=CSV, 3=XLS
,	@sSendTo	varchar( 255 )		-- list of recipient emails
,	@bActive	bit
)
	with encryption
as
begin
	declare		@id		smallint

--	set	nocount	on

	begin	tran

		if	@idSchedule > 0
--		begin
			update	dbo.tbSchedule
				set		tiRecur =	@tiRecur,	tiWkDay =	@tiWkDay,	siMonth =	@siMonth,	sSchedule=	@sSchedule
					,	dtNextRun=	@dtNextRun,	idUser =	@idUser		--, dtLastRun= @dtLastRun, iResult= @iResult
					,	idFilter =	@idFilter,	idReport =	@idReport,	tiFmt=	@tiFmt,	sSendTo =	@sSendTo
					,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idSchedule = @idSchedule
--		end
		else
		begin
			insert	dbo.tbSchedule	(  tiRecur,  tiWkDay,  siMonth,  sSchedule,  dtNextRun,  idUser,  idFilter,  idReport,  tiFmt,  sSendTo )	--,  dtLastRun,  iResult
					values			( @tiRecur, @tiWkDay, @siMonth, @sSchedule, @dtNextRun, @idUser, @idFilter, @idReport, @tiFmt, @sSendTo )	--, @dtLastRun, @iResult
			select	@idSchedule =	scope_identity( )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates state for an existing schedule
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.prSchedule_Upd
(
	@idSchedule	smallint
--,	@tiRecur	tinyint				-- hi 3 bits: 32=Daily, 64=Weekly, 128=Monthly;  lo 5 bits: either 1..31 (D,W), or 1=1st, 2=2nd, 4=3rd, 8=4th, 16=Last
--,	@tiWkDay	tinyint				-- 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
--,	@siMonth	smallint			-- 1=Jan, 2=Feb, 4=Mar, 8=Apr, 16=May, 32=Jun, 64=Jul, 128=Aug, 256=Sep, 512=Oct, 1024=Nov, 2048=Dec
--,	@sSchedule	varchar( 255 )		-- auto: spelled out schedule details
,	@dtLastRun	smalldatetime		-- when last execution started
,	@dtNextRun	smalldatetime		-- when next execution should start, HH:mm part stores the "Run @" value
,	@iResult	smallint			-- for last run: 0=Success, !0==Error code
--,	@idUser		smallint			-- requester
--,	@idFilter	smallint
--,	@idReport	smallint
--,	@sSendTo	varchar( 255 )		-- list of recipient emails
--,	@bActive	bit				
)
	with encryption
as
begin
	update	dbo.tbSchedule
		set		dtLastRun=	@dtLastRun,	dtNextRun=	@dtNextRun,	iResult =	@iResult
		where	idSchedule = @idSchedule
end
go
--	----------------------------------------------------------------------------
--	Deletes an existing schedule
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.prSchedule_Del
(
	@idSchedule	smallint
)
	with encryption
as
begin
--	set	nocount	on

--	begin	tran

		delete	from	dbo.tbSchedule
			where	idSchedule = @idSchedule

--	commit
end
go
--	----------------------------------------------------------------------------
--	Deletes an existing filter
--	7.06.8802	* optimized
--	7.03
alter proc		dbo.prFilter_Del
(
	@idFilter	smallint
)
	with encryption
as
begin
/*	declare		@id		smallint

	set	nocount	on

	select	top 1	@id= idFilter			-- check that filter is not referenced by a schedule
		from	dbo.tbSchedule
		where	idFilter = @idFilter

	if	@id = @idFilter		return	-1		-- filter is in use

	begin	tran
*/
	if	not	exists	(select 1 from dbo.tbSchedule with (nolock) where idFilter = @idFilter)
		delete	from	dbo.tbFilter
			where	idFilter = @idFilter

--	commit
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.8586
alter proc		dbo.prHlCall_GetAll
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
		from	dbo.tbHlCall	c	with (nolock)
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
		where	@siFlags is null	or	siFlags & @siFlags	= @siFlags
--		where	@bEnabled = 0	or	siFlags & 0x02 > 0
		order	by	2 desc		--	p.siIdx
end
go
--	----------------------------------------------------------------------------
--	Updates an HL7 exported call-priority
--	7.06.8586
alter proc		dbo.prHlCall_Upd
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

--		if	exists	(select 1 from tbHlCall with (nolock) where siIdx = @siIdx)
			update	dbo.tbHlCall
				set		bSend =		@bSend,		sSend =		@sSend,		dtUpdated=	getdate( )
				where	siIdx = @siIdx

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns room-beds, ordered to be loadable into a table
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8586
alter proc		dbo.prHlRoomBed_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	on
	select	r.bActive, sSGJ, sRoom, b.cBed
		,	h.bSend, h.sSend
		,	r.dtUpdated
		,	rb.idRoom, rb.tiBed
		from	dbo.tbRoomBed	rb	with (nolock)
		join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= rb.idRoom
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= rb.tiBed
	left join	dbo.tbHlRoomBed	h	with (nolock)	on	h.idRoom	= rb.idRoom		and	h.tiBed		= rb.tiBed
		where	(@bActive is null	or	r.bActive	= @bActive)
--		where	@bEnabled = 0	or	siFlags & 0x02 > 0
		order	by	2		--	sSGJ
end
go
--	----------------------------------------------------------------------------
--	Returns all items necessary for HL7 export of an event
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8595
alter proc		dbo.prHlEvent_Get
(
	@idEvent	int
)
	with encryption
as
begin
--	set	nocount	on
	select	top	1	e.idEvent, e.dtEvent, e.idCall,	c.sCall		--, c.siIdx
		,	r.sSGJR + '-' + right('0' + cast(e.tiBtn as varchar), 2)				as	sSGJRB
		,	r.sRoom,	b.cBed
--		,	r.sDevice + case when ec.tiBed is null then '' else ':' + b.cBed end	as	sRmBd	--	cast(e.tiBed as char(1))
		,	hc.sSend,	hr.sSend	--,	ec.idRoom, ec.tiBed
		,	p.idPatient, p.sPatient, p.cGndr,	p.sIdent, p.sPatID, p.sLast, p.sFrst, p.sMidd
		from	dbo.tbEvent		e	with (nolock)
		join	dbo.tbEvent_C	ec	with (nolock)	on	ec.idEvent	= e.idOrigin
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
		join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbHlCall	hc	with (nolock)	on	hc.siIdx	= c.siIdx		and	hc.bSend > 0
		join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= e.idRoom
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
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
--	7.06.8795	* prCfgDvc_UpdRmBd	->	prCfgStn_UpdRmBd
--	7.06.8791	* tbCfgLoc.idParent -> .idPrnt
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
create proc		dbo.prCfgStn_UpdRmBd
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
		,		@idStn		smallint
		,		@tiCA0		tinyint
		,		@tiCA1		tinyint
		,		@tiCA2		tinyint
		,		@tiCA3		tinyint
		,		@tiCA4		tinyint
		,		@tiCA5		tinyint
		,		@tiCA6		tinyint
		,		@tiCA7		tinyint

	set	nocount	on

	if	exists	(select 1 from dbo.tbCfgStn with (nolock) where bActive > 0		-- only do room-beds for active rooms or 7967-Ps
					and (cStn = 'R' and idStn = @idRoom		or	cStn = 'W' and idPrnt = @idRoom))
	begin

		select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

		select	@sBeds =	'',		@tiBed =	1,	@siMask =	1,	@dtNow =	getdate( )

		-- primary coverage
		select	@tiCA0 =	tiPri0,		@tiCA1 =	tiPri1,		@tiCA2 =	tiPri2,		@tiCA3 =	tiPri3
			,	@tiCA4 =	tiPri4,		@tiCA5 =	tiPri5,		@tiCA6 =	tiPri6,		@tiCA7 =	tiPri7
			,	@sRoom =	sStn,		@sDial =	sDial
			from	dbo.tbCfgStn	with (nolock)
			where	idStn = @idRoom

		if	@tiCA0 = 0xFF	--or @tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
	--	or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
			select	top 1	@idUnitP =	idUnit			-- pick min unit
				from	dbo.tbUnit		with (nolock)
				order	by	idUnit
		else
			select	@idUnitP =	idPrnt					-- convert PriCA0 to its unit
				from	dbo.tbCfgLoc	with (nolock)
				where	idLoc = @tiCA0

		-- alternate coverage
		select	@tiCA0 =	tiAlt0,		@tiCA1 =	tiAlt1,		@tiCA2 =	tiAlt2,		@tiCA3 =	tiAlt3
			,	@tiCA4 =	tiAlt4,		@tiCA5 =	tiAlt5,		@tiCA6 =	tiAlt6,		@tiCA7 =	tiAlt7
			from	dbo.tbCfgStn	with (nolock)
			where	idStn = @idRoom

		if	@tiCA0 = 0xFF	--or @tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
	--	or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
			select	top 1 @idUnitA =	idUnit			-- pick max unit
				from	dbo.tbUnit		with (nolock)
				order	by	idUnit	desc
		else
			select	@idUnitA =	idPrnt					-- convert AltCA0 to its unit
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
				select	idStn, tiPri0,  tiPri1,  tiPri2,  tiPri3,  tiPri4,  tiPri5,  tiPri6,  tiPri7
					from	dbo.tbCfgStn	with (nolock)
					where	idPrnt = @idRoom	and	tiStype = 192	and	bActive > 0

			open	cur
			fetch next from	cur	into	@idStn, @tiCA0, @tiCA1, @tiCA2, @tiCA3, @tiCA4, @tiCA5, @tiCA6, @tiCA7
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

				fetch next from	cur	into	@idStn, @tiCA0, @tiCA1, @tiCA2, @tiCA3, @tiCA4, @tiCA5, @tiCA6, @tiCA7
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
grant	execute				on dbo.prCfgStn_UpdRmBd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering condition into tbEvent.idEvent range
--	7.06.6052	+ @tiShift
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	6.05	+ (nolock)
alter proc		dbo.prRpt_XltDtEvRng
(
	@dFrom		datetime			-- date from
,	@dUpto		datetime			-- date upto
,	@tFrom		tinyint				-- hour from
,	@tUpto		tinyint				-- hour upto
,	@tiShift	tinyint				-- 0xFF=all shifts, 0..254=specific (tb_SessShift)
,	@iFrom		int			out		-- idEvent from
,	@iUpto		int			out		-- idEvent upto
)
	with encryption
as
begin
	set	nocount	on

	select	@iFrom =	min(idEvent)
		from	dbo.tbEvent_S	with (nolock)
		where	@dFrom <= dEvent	and	@tFrom <= tiHH

	if	@tiShift <> 0xFF		select	@dUpto =	@dUpto + 1

	select	@iUpto =	min(idEvent)
		from	dbo.tbEvent_S	with (nolock)
		where	@dUpto = dEvent		and	@tUpto < tiHH
			or	@dUpto < dEvent

	if	@iUpto is null
		select	@iUpto =	2147483647	--	max int

--	select	@dFrom [dFrom], @iFrom [idFrom], @dUpto [dUpto], @iUpto [idUpto]
end
go
--	----------------------------------------------------------------------------
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
--				* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8733	* fix for tb_Log.idLog and tbEvent.idEvent IDENTITY starting at -2147483648
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	' STAT',	@sNull =	'',		@sSpc6 =	'      ',	@sGrTm =	'Group/Team',	@sSyst =	'** $YSTEM **'
	select	@sSvc4 =	' ' + sLvl	from	dbo.tbStfLvl	with (nolock)	where	idLvl = 4
	select	@sSvc2 =	' ' + sLvl	from	dbo.tbStfLvl	with (nolock)	where	idLvl = 2
	select	@sSvc1 =	' ' + sLvl	from	dbo.tbStfLvl	with (nolock)	where	idLvl = 1

	set	nocount	off

	if	@tiDvc = 0xFF
		insert	#tbEvnt
			select	e.idEvent
				from	dbo.tbEvent		e	with (nolock)
		--	-	join	dbo.tb_SessStn	d	with (nolock)	on	d.idSess	= @idSess	and	d.idStn		= e.idSrcStn
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
	else if	@tiDvc = 1
		insert	#tbEvnt
			select	e.idEvent
				from	dbo.tbEvent		e	with (nolock)
				join	dbo.tb_SessStn	d	with (nolock)	on	d.idSess	= @idSess	and	d.idStn		= e.idSrcStn
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
	else
		insert	#tbEvnt
			select	e.idEvent
				from	dbo.tbEvent		e	with (nolock)
			left join	dbo.tb_SessStn	d	with (nolock)	on	d.idSess	= @idSess	and	d.idStn		= e.idSrcStn
				where	e.idEvent	between @iFrom	and @iUpto
				and		e.tiHH		between @tFrom	and @tUpto
		--	-	and		(e.idSrcStn in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcStn is null)		-- is left join not enough??

	select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
		,	e.idCmd,	e.tiBtn,	lt.tiLvl, e.idType		--,	e.idRoom, e.tiBed
		,	case	--when e.idCmd = 0x83		then e.sInfo						-- Gway
					when cp.tiSpec = 23			then @sSyst			else e.sRoomBed		end		as	sRoomBed
		,	e.idCall, e.sCall,	c.siIdx, cp.tiSpec, cp.tiColor,		e.tiFlags					as	tiSvc
		,	e.idSrcStn,		e.idDstStn, e.sDstSGJR,					e.sQnSrcStn					as	sSrcStn
		,	case	when l.idLog is not null	then l.sModule		else e.sSrcSGJR		end		as	sSrcSGJR		--		when e.idCmd in (0, 0x83)
--		,	case	when en.idEvent is not null	then nd.cDvcType	else e.cDstDvc		end		as	cDstDvc
		,	case	when en.idEvent is not null	then nd.sQnDvc		else e.sQnDstStn	end		as	sDstStn
		,	case	when en.idEvent is not null	then nt.sNtfType
					when 0 < e.idType			then e.sType		else k.sCmd	end
			+	case	when e.idCmd = 0x95		then	-- ' ' +
					case	when 0 < e.tiFlags & 0x08	then @sSvc8	else
					case	when 0 < e.tiFlags & 0x04	then @sSvc4	else @sNull	end
				+	case	when 0 < e.tiFlags & 0x02	then @sSvc2	else @sNull	end
				+	case	when 0 < e.tiFlags & 0x01	then @sSvc1	else @sNull	end	end
												else @sNull								end		as	sEvent
		,	case	when e.idCmd = 0x84	and	cp.tiSpec = 23
						or l.idLog is not null				then null			-- Log|+-AppFail
					when 0 < cp.siFlags & 0x1000			then @sSpc6 + u1.sQnStf		-- Presence
																else e.sInfo			end		as	sInfo
		,	case	when 0 < cp.siFlags & 0x1000			then u1.idLvl
					when 0 < du.idUser 						then du.idLvl	-- Badge
																else null				end		as	idLvl
		,	case	when e.idCmd = 0x84	and	cp.tiSpec = 23		then e.sInfo	-- +-AppFail
					when l.idLog is not null	then replace(l.sLog, char(9), char(32))
																else null				end		as	sLog
		,	case	when en.idEvent is not null	then	--	du.sQnStf
						case	when 0 < nd.tiFlags & 0x01	then @sGrTm	else du.sQnStf	end
					when l.idLog is not null	then l.sUser		else null			end		as	sStaff	
		from		#tbEvnt		et	with (nolock)
		join	dbo.vwEvent		e	with (nolock)	on	e.idEvent		= et.idEvent
		join	dbo.tbDefCmd	k	with (nolock)	on	k.idCmd			= e.idCmd
		join	dbo.tb_LogType	lt	with (nolock)	on	lt.idType		= e.idType
	left join	dbo.tbCall		c	with (nolock)	on	c.idCall		= e.idCall
	left join	dbo.tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
	left join	dbo.tbEvent_C	ec	with (nolock)	on	ec.idEvent		= e.idEvent
	left join	dbo.vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
	left join	dbo.tbEvent41	en	with (nolock)	on	en.idEvent		= e.idEvent
	left join	dbo.tbNtfType	nt	with (nolock)	on	nt.idNtfType	= en.idNtfType
	left join	dbo.vwStaff		du	with (nolock)	on	du.idUser		= en.idUser
	left join	dbo.vwDvc		nd	with (nolock)	on	nd.idDvc		= en.idDvc
	left join	dbo.vw_Log		l	with (nolock)	on	l.idLog			= e.iHash	and	e.idCmd in (0, 0x83)		-- Log|Gway
		order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	select	@fPerc =	1000.0

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	select	idCall, lCount, z.siIdx, tiSpec, tiColor
		,	cast(case when tiSpec between 7 and 9	then 1	else 0	end	as tinyint)			as	tiPres
		,	case when p.siFlags & 0x1000 > 0	then z.sCall + ' †'	else z.sCall	end		as	sCall
		,	case when p.siFlags & 0x1000 > 0	then null			else tVoice		end		as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
		,	case when p.siFlags & 0x1000 > 0	then null			else tStaff		end		as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
		,	cast(round(case when lVoNul = lCount	then null	else lVoOnT*@fPerc/(lCount-lVoNul)	end, 0)	as int)	as	iVoOnT
		,	cast(round(case when lStNul = lCount	then null	else lStOnT*@fPerc/(lCount-lStNul)	end, 0)	as int)	as	iStOnT
		from
			(select	e.idCall,	count(*) as	lCount
				,	min(c.siIdx)	as	siIdx,		min(c.sCall)	as	sCall
				,	min(c.tVoice)	as	tVoice,		min(c.tStaff)	as	tStaff
				,	max(e.tVoice)	as	tVoMax,		max(e.tStaff)	as	tStMax
				,	sum(case when e.tVoice < c.tVoice	then 1 else 0 end)	as	lVoOnT
				,	sum(case when e.tVoice is null		then 1 else 0 end)	as	lVoNul
				,	sum(case when e.tStaff < c.tStaff	then 1 else 0 end)	as	lStOnT
				,	sum(case when e.tStaff is null		then 1 else 0 end)	as	lStNul
				,	cast( cast( avg( cast( cast(e.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
				,	cast( cast( avg( cast( cast(e.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				from		#tbEvnt		t	with (nolock)
				join	dbo.tbEvent_C	e	with (nolock)	on	e.idEvent	= t.idEvent
				join	dbo.tb_SessCall	c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
				group	by e.idCall)	z
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= z.siIdx
		order by	siIdx desc
end
go
--	----------------------------------------------------------------------------
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8551	* added missing 'from	#tbEvnt'
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
alter proc		dbo.prRptCallStatGfx
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tbCfgPri		p	with (nolock)	on	p.siIdx		= c.siIdx	and	p.siFlags & 0x5000 = 0x4000
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					join	dbo.tbCfgPri		p	with (nolock)	on	p.siIdx		= c.siIdx	and	p.siFlags & 0x5000 = 0x4000
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tbCfgPri		p	with (nolock)	on	p.siIdx		= c.siIdx	and	p.siFlags & 0x5000 = 0x4000
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.tbEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					join	dbo.tbCfgPri		p	with (nolock)	on	p.siIdx		= c.siIdx	and	p.siFlags & 0x5000 = 0x4000
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	select	ec.dEvent,	count(*)	as	lCount
--		,	min(cp.tVoice)	as	tVoTrg,		min(cp.tStaff)	as	tStTrg
		,	max(ec.tVoice)	as	tVoMax,		max(ec.tStaff)	as	tStMax
		,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
		,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
--		from	dbo.tbEvent_C	ec	with (nolock)
		from		#tbEvnt		et	with (nolock)
		join	dbo.tbEvent_C	ec	with (nolock)	on	ec.idEvent	= et.idEvent
--		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
		group	by ec.dEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8319	* output returns now int %, rounded to no decimals
--				+ @f100
--	7.06.8194	+ .tiColor
--	7.06.6052	+ prRpt_XltDtEvRng:	@tiShift
--	7.06.6031	+ @tiShift
--	7.06.5527	+ skip 'presence' priorities
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	7.06.5408	+ @siBeds
--	7.06.4939	* optimized
--	6.05	+ (nolock), optimize
--	6.04	* optimize event selection range using tbEvent_S
--	6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--			.idRptSess -> .idSess, tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--			@tiLocs -> @tiDvc
--	2.03
alter proc		dbo.prRptCallStatDtl
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
		,		@tiHH		tinyint
		,		@fPerc		float

	set	nocount	on

	select	@fPerc =	100.0

	create table	#tbCall
	(
		idCall		smallint,
		iWDay		tinyint,
		tiHH		tinyint,

		lCount		int,	lVoOnT		int,	lVoNul		int,	lStOnT		int,	lStNul		int,

		primary key clustered (idCall, iWDay, tiHH)
	)
	create table	#tbStat
	(
		idCall		smallint,
		tiHH		tinyint,

		lCount1		int,	lVoOnT1		int,	lVoNul1		int,	iVoOnT1		int,	lStOnT1		int,	lStNul1		int,	iStOnT1		int,
		lCount2		int,	lVoOnT2		int,	lVoNul2		int,	iVoOnT2		int,	lStOnT2		int,	lStNul2		int,	iStOnT2		int,
		lCount3		int,	lVoOnT3		int,	lVoNul3		int,	iVoOnT3		int,	lStOnT3		int,	lStNul3		int,	iStOnT3		int,
		lCount4		int,	lVoOnT4		int,	lVoNul4		int,	iVoOnT4		int,	lStOnT4		int,	lStNul4		int,	iStOnT4		int,
		lCount5		int,	lVoOnT5		int,	lVoNul5		int,	iVoOnT5		int,	lStOnT5		int,	lStNul5		int,	iStOnT5		int,
		lCount6		int,	lVoOnT6		int,	lVoNul6		int,	iVoOnT6		int,	lStOnT6		int,	lStNul6		int,	iStOnT6		int,
		lCount7		int,	lVoOnT7		int,	lVoNul7		int,	iVoOnT7		int,	lStOnT7		int,	lStNul7		int,	iStOnT7		int,

		primary key clustered (idCall, tiHH)
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbCall
				select	e.idCall, datepart(dw, e.dEvent), e.tiHH, count(*)
					,	sum(case when e.tVoice < c.tVoice	then 1 else 0 end)
					,	sum(case when e.tVoice is null		then 1 else 0 end)
					,	sum(case when e.tStaff < c.tStaff	then 1 else 0 end)
					,	sum(case when e.tStaff is null		then 1 else 0 end)
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
					group	by e.idCall, datepart(dw, e.dEvent), e.tiHH
		else
			insert	#tbCall
				select	e.idCall, datepart(dw, e.dEvent), e.tiHH, count(*)
					,	sum(case when e.tVoice < c.tVoice	then 1 else 0 end)
					,	sum(case when e.tVoice is null		then 1 else 0 end)
					,	sum(case when e.tStaff < c.tStaff	then 1 else 0 end)
					,	sum(case when e.tStaff is null		then 1 else 0 end)
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
					group	by e.idCall, datepart(dw, e.dEvent), e.tiHH
	else
		if	@tiShift = 0xFF
			insert	#tbCall
				select	e.idCall, datepart(dw, e.dEvent), e.tiHH, count(*)
					,	sum(case when e.tVoice < c.tVoice	then 1 else 0 end)
					,	sum(case when e.tVoice is null		then 1 else 0 end)
					,	sum(case when e.tStaff < c.tStaff	then 1 else 0 end)
					,	sum(case when e.tStaff is null		then 1 else 0 end)
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		d	with (nolock)	on	d.idSess	= @idSess	and	d.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
					group	by e.idCall, datepart(dw, e.dEvent), e.tiHH
		else
			insert	#tbCall
				select	e.idCall, datepart(dw, e.dEvent), e.tiHH, count(*)
					,	sum(case when e.tVoice < c.tVoice	then 1 else 0 end)
					,	sum(case when e.tVoice is null		then 1 else 0 end)
					,	sum(case when e.tStaff < c.tStaff	then 1 else 0 end)
					,	sum(case when e.tStaff is null		then 1 else 0 end)
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		d	with (nolock)	on	d.idSess	= @idSess	and	d.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
					group	by e.idCall, datepart(dw, e.dEvent), e.tiHH

--	select	*	from	#tbCall

	set		@tiHH=	@tFrom
	if	@tUpto >= 24	set		@tUpto =	23
	while	@tiHH <= @tUpto
	begin
		insert	#tbStat ( idCall, tiHH )
			select	distinct idCall, @tiHH
				from	#tbCall		with (nolock)
		set		@tiHH=	@tiHH + 1
	end	

--	select	*	from	#tbStat

	update	a
		set	a.lCount1= b.lCount1,	a.lVoOnT1= b.lVoOnT1,	a.lVoNul1= b.lVoNul1,	a.lStOnT1= b.lStOnT1,	a.lStNul1= b.lStNul1
		,	a.lCount2= b.lCount2,	a.lVoOnT2= b.lVoOnT2,	a.lVoNul2= b.lVoNul2,	a.lStOnT2= b.lStOnT2,	a.lStNul2= b.lStNul2
		,	a.lCount3= b.lCount3,	a.lVoOnT3= b.lVoOnT3,	a.lVoNul3= b.lVoNul3,	a.lStOnT3= b.lStOnT3,	a.lStNul3= b.lStNul3
		,	a.lCount4= b.lCount4,	a.lVoOnT4= b.lVoOnT4,	a.lVoNul4= b.lVoNul4,	a.lStOnT4= b.lStOnT4,	a.lStNul4= b.lStNul4
		,	a.lCount5= b.lCount5,	a.lVoOnT5= b.lVoOnT5,	a.lVoNul5= b.lVoNul5,	a.lStOnT5= b.lStOnT5,	a.lStNul5= b.lStNul5
		,	a.lCount6= b.lCount6,	a.lVoOnT6= b.lVoOnT6,	a.lVoNul6= b.lVoNul6,	a.lStOnT6= b.lStOnT6,	a.lStNul6= b.lStNul6
		,	a.lCount7= b.lCount7,	a.lVoOnT7= b.lVoOnT7,	a.lVoNul7= b.lVoNul7,	a.lStOnT7= b.lStOnT7,	a.lStNul7= b.lStNul7
		from	#tbStat		a	with (nolock)
		join	(select		idCall, tiHH
					,	sum(case when iWDay=1 then lCount end)	as	lCount1
					,	sum(case when iWDay=1 then lVoOnT end)	as	lVoOnT1,	sum(case when iWDay=1 then lVoNul end)	as	lVoNul1
					,	sum(case when iWDay=1 then lStOnT end)	as	lStOnT1,	sum(case when iWDay=1 then lStNul end)	as	lStNul1

					,	sum(case when iWDay=2 then lCount end)	as	lCount2
					,	sum(case when iWDay=2 then lVoOnT end)	as	lVoOnT2,	sum(case when iWDay=2 then lVoNul end)	as	lVoNul2
					,	sum(case when iWDay=2 then lStOnT end)	as	lStOnT2,	sum(case when iWDay=2 then lStNul end)	as	lStNul2

					,	sum(case when iWDay=3 then lCount end)	as	lCount3
					,	sum(case when iWDay=3 then lVoOnT end)	as	lVoOnT3,	sum(case when iWDay=3 then lVoNul end)	as	lVoNul3
					,	sum(case when iWDay=3 then lStOnT end)	as	lStOnT3,	sum(case when iWDay=3 then lStNul end)	as	lStNul3

					,	sum(case when iWDay=4 then lCount end)	as	lCount4
					,	sum(case when iWDay=4 then lVoOnT end)	as	lVoOnT4,	sum(case when iWDay=4 then lVoNul end)	as	lVoNul4
					,	sum(case when iWDay=4 then lStOnT end)	as	lStOnT4,	sum(case when iWDay=4 then lStNul end)	as	lStNul4

					,	sum(case when iWDay=5 then lCount end)	as	lCount5
					,	sum(case when iWDay=5 then lVoOnT end)	as	lVoOnT5,	sum(case when iWDay=5 then lVoNul end)	as	lVoNul5
					,	sum(case when iWDay=5 then lStOnT end)	as	lStOnT5,	sum(case when iWDay=5 then lStNul end)	as	lStNul5

					,	sum(case when iWDay=6 then lCount end)	as	lCount6
					,	sum(case when iWDay=6 then lVoOnT end)	as	lVoOnT6,	sum(case when iWDay=6 then lVoNul end)	as	lVoNul6
					,	sum(case when iWDay=6 then lStOnT end)	as	lStOnT6,	sum(case when iWDay=6 then lStNul end)	as	lStNul6

					,	sum(case when iWDay=7 then lCount end)	as	lCount7
					,	sum(case when iWDay=7 then lVoOnT end)	as	lVoOnT7,	sum(case when iWDay=7 then lVoNul end)	as	lVoNul7
					,	sum(case when iWDay=7 then lStOnT end)	as	lStOnT7,	sum(case when iWDay=7 then lStNul end)	as	lStNul7
					from	#tbCall		with (nolock)
					group	by idCall, tiHH)
							b	on	b.idCall = a.idCall		and	b.tiHH = a.tiHH

	update	#tbStat
		set	iVoOnT1 =	round(case when lVoNul1 = lCount1	then null	else lVoOnT1 * @fPerc / (lCount1 - lVoNul1)	end, 0)
		,	iStOnT1 =	round(case when lStNul1 = lCount1	then null	else lStOnT1 * @fPerc / (lCount1 - lStNul1)	end, 0)
		,	iVoOnT2 =	round(case when lVoNul2 = lCount2	then null	else lVoOnT2 * @fPerc / (lCount2 - lVoNul2)	end, 0)
		,	iStOnT2 =	round(case when lStNul2 = lCount2	then null	else lStOnT2 * @fPerc / (lCount2 - lStNul2)	end, 0)
		,	iVoOnT3 =	round(case when lVoNul3 = lCount3	then null	else lVoOnT3 * @fPerc / (lCount3 - lVoNul3)	end, 0)
		,	iStOnT3 =	round(case when lStNul3 = lCount3	then null	else lStOnT3 * @fPerc / (lCount3 - lStNul3)	end, 0)
		,	iVoOnT4 =	round(case when lVoNul4 = lCount4	then null	else lVoOnT4 * @fPerc / (lCount4 - lVoNul4)	end, 0)
		,	iStOnT4 =	round(case when lStNul4 = lCount4	then null	else lStOnT4 * @fPerc / (lCount4 - lStNul4)	end, 0)
		,	iVoOnT5 =	round(case when lVoNul5 = lCount5	then null	else lVoOnT5 * @fPerc / (lCount5 - lVoNul5)	end, 0)
		,	iStOnT5 =	round(case when lStNul5 = lCount5	then null	else lStOnT5 * @fPerc / (lCount5 - lStNul5)	end, 0)
		,	iVoOnT6 =	round(case when lVoNul6 = lCount6	then null	else lVoOnT6 * @fPerc / (lCount6 - lVoNul6)	end, 0)
		,	iStOnT6 =	round(case when lStNul6 = lCount6	then null	else lStOnT6 * @fPerc / (lCount6 - lStNul6)	end, 0)
		,	iVoOnT7 =	round(case when lVoNul7 = lCount7	then null	else lVoOnT7 * @fPerc / (lCount7 - lVoNul7)	end, 0)
		,	iStOnT7 =	round(case when lStNul7 = lCount7	then null	else lStOnT7 * @fPerc / (lCount7 - lStNul7)	end, 0)

	set	nocount	off

	select	c.siIdx, c.sCall, c.tVoice, c.tStaff, p.tiColor, dateadd(hh, t.tiHH, '0:0:0')	as	tHour,	t.*
		from		#tbStat		t	with (nolock)
		join	dbo.tb_SessCall c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= t.idCall
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
		order by	c.siIdx desc, t.tiHH
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	s	with (nolock)	on	s.idSess	= @idSess	and	s.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		d	with (nolock)	on	d.idSess	= @idSess	and	d.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		d	with (nolock)	on	d.idSess	= @idSess	and	d.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	s	with (nolock)	on	s.idSess	= @idSess	and	s.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	select	e.idEvent, e.idUnit, e.sUnit, e.idRoom, e.cStn, e.sRoom, e.sDial, e.dEvent, e.tEvent, e.cBed
		,	e.idCall, e.sCall, p.siIdx, p.tiSpec, p.tiColor,	c.tVoice, c.tStaff
		,	h.sShift, e.dShift, h.tBeg, h.tEnd
		,	cast(cast(cast(e.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
		,	case when p.siFlags & 0x1000 > 0	then 0			else 1			end	as	iCall
		,	case when p.siFlags & 0x1000 > 0	then null		else e.tVoice	end	as	tVoice
		,	case when p.siFlags & 0x1000 > 0	then null		else e.tStaff	end	as	tStaff
		,	case when p.tiSpec = 7				then e.tStaff	else null		end	as	tGrn
		,	case when p.tiSpec = 8				then e.tStaff	else null		end	as	tOra
		,	case when p.tiSpec = 9				then e.tStaff	else null		end	as	tYel
		from		#tbEvnt		t	with (nolock)
		join	dbo.vwEvent_C	e	with (nolock)	on	e.idEvent	= t.idEvent
		join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
		join	dbo.tbShift		h	with (nolock)	on	h.idShift	= e.idShift
		where	e.tiHH		between @tFrom	and @tUpto
--		and		e.idEvent	between @iFrom	and @iUpto
--		where	e.idEvent	between @iFrom	and @iUpto
--		and		e.tiHH		between @tFrom	and @tUpto
--		and		e.dShift	between @dFrom	and @dUpto
--		and		e.siBed & @siBeds <> 0
		order	by	e.idUnit, e.idRoom, e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
--				* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	'STAT',		@sNull =	'',		@sSpc6 =	'      ',	@sGrTm =	'Group/Team'
	select	@sSvc4 =	sLvl + ' '	from	dbo.tbStfLvl	with (nolock)	where	idLvl = 4
	select	@sSvc2 =	sLvl + ' '	from	dbo.tbStfLvl	with (nolock)	where	idLvl = 2
	select	@sSvc1 =	sLvl + ' '	from	dbo.tbStfLvl	with (nolock)	where	idLvl = 1

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	set	nocount	off

	select	ec.idUnit, ec.sUnit, ec.idRoom, ec.cStn, ec.sRoom,	ec.cBed, e.tiBed, ec.sDial
		,	e.idEvent, e.dEvent, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin
		,	e.idType, cp.tiColor,	c.siIdx		--, e.idCall
		,	case	when en.idEvent > 0		then pt.sNtfType	else lt.sType	end		as	sEvent
		,	case	when en.idEvent > 0		then en.idNtfType	else cp.tiSpec	end		as	tiSpec
		,	case	when en.idEvent > 0		then du.idLvl		else e.tiFlags	end		as	tiSvc
		,	case	when e.idType between 195 and 199	then e.sQnDstStn	--	 '[' + e.cDstDvc + '] ' + e.sDstDvc		-- audio
					when e.idCmd = 0x95		then
						case	when e.tiFlags & 0x08 > 0	then @sSvc8	else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4	else @sNull	end
					+	case	when e.tiFlags & 0x02 > 0	then @sSvc2	else @sNull	end
					+	case	when e.tiFlags & 0x01 > 0	then @sSvc1	else @sNull	end	end
					when en.idEvent > 0		then nd.sQnDvc							end		as	sDvcSvc	--	 nd.sFqDvc
		,	case	when en.idEvent > 0		then
						case	when nd.tiFlags & 0x01 > 0	then @sGrTm	else du.sQnStf	end
					else c.sCall	end		as	sCall
		,	case	--when e41.idNtfType > 0x80	then pt.sNtfType
					when cp.siFlags & 0x1000 > 0	then u1.sQnStf	else e.sInfo	end		as	sInfo
	--				when c.tiSpec in (7, 8, 9)	then u1.sQnStf	else e.sInfo	end		as	sInfo
	--	,	case	when c.tiSpec between 7 and 9	then @sSpc6 + u1.sFqStaff		else e.sInfo	end		as	sInfo
		,	d.sDoctor, p.sPatient
		from		#tbEvnt		t	with (nolock)
		join	dbo.vwEvent_C	ec	with (nolock)	on	ec.idEvent		= t.idEvent
		join	dbo.vwEvent		e	with (nolock)	on	e.idParent		= t.idEvent
		join	dbo.tb_LogType	lt	with (nolock)	on	lt.idType		= e.idType
		join	dbo.tbCall		c	with (nolock)	on	c.idCall		= e.idCall
		join	dbo.tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
	left join	dbo.tbEvent41	en	with (nolock)	on	en.idEvent		= e.idEvent
	left join	dbo.tbNtfType	pt	with (nolock)	on	pt.idNtfType	= en.idNtfType
	left join	dbo.vwDvc		nd	with (nolock)	on	nd.idDvc		= en.idDvc
	left join	dbo.vwStaff		du	with (nolock)	on	du.idUser		= en.idUser
	left join	dbo.vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
	left join	dbo.tbEvent84	ev	with (nolock)	on	ev.idEvent		= e.idEvent
	left join	dbo.tbPatient	p	with (nolock)	on	p.idPatient		= ev.idPatient
	left join	dbo.tbDoctor	d	with (nolock)	on	d.idDoctor		= ev.idDoctor
--		where	e.tiHH		between @tFrom	and @tUpto
--		and		e.idEvent	between @iFrom	and @iUpto
		order	by	ec.idUnit, ec.idRoom, ec.idEvent, t.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
					and		(c.tStaff < e.tStaff	or	c.tVoice < e.tVoice)
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
					and		(c.tStaff < e.tStaff	or	c.tVoice < e.tVoice)
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
					and		(c.tStaff < e.tStaff	or	c.tVoice < e.tVoice)
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_C		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
					and		(c.tStaff < e.tStaff	or	c.tVoice < e.tVoice)

	select	e.idEvent, e.idRoom, e.cStn, e.sRoomBed, e.dEvent, e.tEvent, e.cBed
		,	e.idCall, e.sCall, p.siIdx, p.tiSpec, p.tiColor,	c.tVoice	as	tVoTrg, c.tStaff	as	tStTrg,		e.tVoice, e.tStaff
		,	e.idLvl1, e.sStaff1,	e.idLvl2, e.sStaff2,	e.idLvl3, e.sStaff3
		from		#tbEvnt		t	with (nolock)
		join	dbo.vwEvent_C	e	with (nolock)	on	e.idEvent	= t.idEvent
		join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx		and	(p.tiSpec is null	or	p.tiSpec not between 7 and 9)
		order	by	p.siIdx desc, e.tStaff desc, e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
--				* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8388	* 
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

	create table	#tbAssn
	(
		idAssn		int				not null	primary key clustered
	)

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						where	a.bActive > 0
			else
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tb_SessUser		u	with (nolock)	on	u.idSess	= @idSess	and	u.idUser	= a.idUser
						where	a.bActive > 0
		else
			if	@tiStaff = 0xFF
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						where	a.bActive > 0
			else
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						join	dbo.tb_SessUser		u	with (nolock)	on	u.idSess	= @idSess	and	u.idUser	= a.idUser
						where	a.bActive > 0
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						where	a.bActive > 0
			else
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						join	dbo.tb_SessUser		u	with (nolock)	on	u.idSess	= @idSess	and	u.idUser	= a.idUser
						where	a.bActive > 0
		else
			if	@tiStaff = 0xFF
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						where	a.bActive > 0
			else
				insert	#tbAssn
					select	a.idAssn
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						join	dbo.tb_SessUser		u	with (nolock)	on	u.idSess	= @idSess	and	u.idUser	= a.idUser
						where	a.bActive > 0

	set	nocount	off

	select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
		,	a.idRoom, d.cStn, d.sStn, b.cBed,		t.idAssn
		,	a.tiIdx as tiStaff, s.idLvl, s.sLvl, s.sStfID, s.sStaff,		a.dtCreated, a.dtUpdated
		from		#tbAssn		t	with (nolock)
		join	dbo.tbStfAssn	a	with (nolock)	on	a.idAssn	= t.idAssn
		join	dbo.tbShift		h	with (nolock)	on	h.idShift	= a.idShift
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= h.idUnit
		join	dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= a.idRoom
		join	dbo.vwStaff		s	with (nolock)	on	s.idUser	= a.idUser
		left join dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= a.tiBed
--		where	a.bActive > 0
		order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
--				* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbCvrg
	(
		idCvrg		int				not null	primary key clustered
	)

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						where	c.dShift	between @dFrom	and @dUpto
			else
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						join	dbo.tb_SessUser		u	with (nolock)	on	u.idSess	= @idSess	and	u.idUser	= a.idUser	
						where	c.dShift	between @dFrom	and @dUpto
		else
			if	@tiStaff = 0xFF
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						where	c.dShift	between @dFrom	and @dUpto
			else
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						join	dbo.tb_SessUser		u	with (nolock)	on	u.idSess	= @idSess	and	u.idUser	= a.idUser
						where	c.dShift	between @dFrom	and @dUpto
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						where	c.dShift	between @dFrom	and @dUpto
			else
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						join	dbo.tb_SessUser		t	with (nolock)	on	t.idSess	= @idSess	and	t.idUser	= a.idUser
						where	c.dShift	between @dFrom	and @dUpto
		else
			if	@tiStaff = 0xFF
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						where	c.dShift	between @dFrom	and @dUpto
			else
				insert	#tbCvrg
					select	c.idCvrg
						from	dbo.tbStfAssn		a	with (nolock)
						join	dbo.tbStfCvrg		c	with (nolock)	on	c.idAssn	= a.idAssn
						join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= a.idRoom
						join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= a.idShift
						join	dbo.tb_SessUser		u	with (nolock)	on	u.idSess	= @idSess	and	u.idUser	= a.idUser
						where	c.dShift	between @dFrom	and @dUpto

	set	nocount	off

	select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
		,	c.idCvrg, c.dShift, cast(cast(cast(c.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
		,	a.idRoom, r.cStn, r.sStn, b.cBed		--, r.sDevice + isnull(' : ' + b.cBed, '')	as	sRoomBed
		,	a.tiIdx, s.idLvl, s.sLvl, s.sStfID, s.sStaff,	c.dtBeg, c.dtEnd
		from		#tbCvrg		t	with (nolock)
		join	dbo.tbStfCvrg	c	with (nolock)	on	c.idCvrg	= t.idCvrg
		join	dbo.tbStfAssn	a	with (nolock)	on	a.idAssn	= c.idAssn
		join	dbo.tbShift		h	with (nolock)	on	h.idShift	= a.idShift
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= h.idUnit
		join	dbo.tbCfgStn	r	with (nolock)	on	r.idStn		= a.idRoom
		join	dbo.vwStaff		s	with (nolock)	on	s.idUser	= a.idUser
		left join dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= a.tiBed
		order	by h.idUnit, a.idRoom, iShSeq, a.tiBed, a.tiIdx, c.idCvrg
end
go
--	----------------------------------------------------------------------------
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	set	nocount	off

	select	siIdx, siFlags, sCall,			tVoTrg,	tStTrg, tStAvg, tStMax,		lCount
		,	lGood,	case when tStAvg is null	then null	else	lGood * @f100 / lCount	end	as	fGood
		,	lFair,	case when tStAvg is null	then null	else	lFair * @f100 / lCount	end	as	fFair
		,	lPoor,	case when tStAvg is null	then null	else	lPoor * @f100 / lCount	end	as	fPoor
		from
			(select	c.siIdx,	count(*) as	lCount
				,	min(p.siFlags)	as	siFlags
				,	min(c.sCall)	as	sCall
				,	min(c.tVoice)	as	tVoTrg
				,	min(c.tStaff)	as	tStTrg
				,	cast(cast(avg(cast(cast(d.tWaitS as datetime) as float)) as datetime) as time(3))	as	tStAvg
				,	max(d.tWaitS)	as	tStMax
	---			,	sum(case when 						d.tWaitS is null		then 1 else 0 end)	as	lNull
				,	sum(case when 						d.tWaitS <= c.tVoice	then 1 else 0 end)	as	lGood
				,	sum(case when c.tVoice < d.tWaitS and d.tWaitS <= c.tStaff	then 1 else 0 end)	as	lFair
				,	sum(case when c.tStaff < d.tWaitS							then 1 else 0 end)	as	lPoor
				from		#tbEvnt		t	with (nolock)
				join	dbo.vwEvent_D	d	with (nolock)	on	d.idEvent	= t.idEvent
				join	dbo.tb_SessCall	c	with (nolock)	on	c.idCall	= d.idCall		and	c.idSess	= @idSess
				join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx		and	p.siFlags & 0x0800 > 0
				where	cast( dateadd( mi, p.tiIntOt, '0:0:0' ) as time(3) ) < d.tWaitS
				group	by	c.siIdx)	s
		order	by	siIdx desc
end
go
--	----------------------------------------------------------------------------
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	set	nocount	off

	select	e.idUnit, u.sUnit, e.idRoom, r.cStn, r.sRoom,	e.dEvent
		,	e.siIdx, p.siFlags, e.sCall,	tVoTrg,	tStTrg,	tStAvg, tStMax,		lCount
		,	lGood,	case when tStAvg is null	then null	else	lGood * @f100 / lCount	end	as	fGood
		,	lFair,	case when tStAvg is null	then null	else	lFair * @f100 / lCount	end	as	fFair
		,	lPoor,	case when tStAvg is null	then null	else	lPoor * @f100 / lCount	end	as	fPoor
		from
			(select	d.idUnit, d.idRoom, d.dEvent
				,	c.siIdx,	count(*) as	lCount
				,	min(p.siFlags)	as	siFlags
				,	min(c.sCall)	as	sCall
				,	min(c.tVoice)	as	tVoTrg
				,	min(c.tStaff)	as	tStTrg
				,	cast(cast(avg(cast(cast(d.tWaitS as datetime) as float)) as datetime) as time(3))	as	tStAvg
				,	max(d.tWaitS)	as	tStMax
	---			,	sum(case when 						d.tWaitS is null		then 1 else 0 end)	as	lNull
				,	sum(case when 						d.tWaitS <= c.tVoice	then 1 else 0 end)	as	lGood
				,	sum(case when c.tVoice < d.tWaitS and d.tWaitS <= c.tStaff	then 1 else 0 end)	as	lFair
				,	sum(case when c.tStaff < d.tWaitS							then 1 else 0 end)	as	lPoor
				from		#tbEvnt		t	with (nolock)
				join	dbo.vwEvent_D	d	with (nolock)	on	d.idEvent	= t.idEvent
				join	dbo.tb_SessCall	c	with (nolock)	on	c.idCall	= d.idCall		and	c.idSess	= @idSess
				join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx		and	p.siFlags & 0x0800 > 0
				where	cast( dateadd( mi, p.tiIntOt, '0:0:0' ) as time(3) ) < d.tWaitS
				group	by	d.idUnit, d.idRoom, d.dEvent, c.siIdx)	e
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
		join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= e.idRoom
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= e.siIdx
		order	by	e.idUnit, e.idRoom, e.siIdx desc
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	c.idCall	= e.idCall
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	set	nocount	off

	select	d.idUnit, d.sUnit, d.idRoom, d.cStn, d.sRoom,	d.cBed, e.tiBed
		,	e.idEvent, e.dEvent, e.tEvent as tQueue, r.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin
		,	c.siIdx, p.tiSpec, p.tiColor, c.sCall
		,	d.tWaitP, d.tRoomP,		d.tWaitS, d.tRoomS,		d.tWaitD, d.tRoomD
--		,	cast(cast(ep.tEvent as datetime) + cast(ep.tRoomP as datetime) as time(3))	as	tExit
		from		#tbEvnt		t	with (nolock)
		join	dbo.vwEvent_D	d	with (nolock)	on	d.idEvent	= t.idEvent
		join	dbo.tbEvent		e	with (nolock)	on	e.idEvent	= d.idEvent
		join	dbo.tbEvent		r	with (nolock)	on	r.idEvent	= d.idEvtP
		join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
		order	by	d.idUnit, d.idRoom, d.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)
	create table	#tbStat
	(
		idEvent		int				not null	primary key clustered
	,	tWait		time( 3 )		null		-- patient's wait-for-staff/doctor time
	,	tRoom		time( 3 )		null		-- staff/doctor's time in room
	,	tRoomP		time( 3 )		null		-- patient's time in room
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn	= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	declare		cur		cursor fast_forward for
		select	idEvent
			from	#tbEvnt	with (nolock)

	open	cur
	fetch next from	cur	into	@idEvent
	while	@@fetch_status = 0
	begin
		insert	#tbStat
			select	idEvtS, tWaitS, tRoomS,	tRoomP
				from	dbo.vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallS in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		insert	#tbStat
			select	idEvtD, tWaitD, tRoomD,	tRoomP
				from	dbo.vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallD in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		fetch next from	cur	into	@idEvent
	end
	close	cur
	deallocate	cur
	
	set	nocount	off

	select	e.idUnit, u.sUnit, e.idRoom, r.cStn, r.sRoom,	e.cBed, e.tiBed
		,	e.idEvent, e.dEvent, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin	--, e.idCall, ep.sDial
		,	c.siIdx, p.tiSpec, p.tiColor, c.sCall
		,	t.tWait, t.tRoom, t.tRoomP
		,	cast(cast(e.tEvent as datetime) + cast(t.tRoom as datetime) as time(3))	as	tExit
		from		#tbStat		t	with (nolock)
		join	dbo.vwEvent		e	with (nolock)	on	e.idEvent	= t.idEvent
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
		join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= e.idRoom
		join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8783	* #PK nonclustered -> clustered
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

	create table	#tbEvnt
	(
		idEvent		int				not null	primary key clustered
	)
	create table	#tbStat
	(
		idEvent		int				not null	primary key clustered
	,	idCall		smallint		not null
	,	tWait		time( 3 )		null		-- patient's wait-for-staff/doctor time
	,	tRoom		time( 3 )		null		-- staff/doctor's time in room
	,	tRoomP		time( 3 )		null		-- patient's time in room
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.siBed & @siBeds <> 0
		else
			insert	#tbEvnt
				select	distinct e.idEvent
					from	dbo.vwEvent_D		e	with (nolock)
					join	dbo.tb_SessStn		r	with (nolock)	on	r.idSess	= @idSess	and	r.idStn		= e.idRoom
					join	dbo.tb_SessCall		c	with (nolock)	on	c.idSess	= @idSess	and	( c.idCall	= e.idCallS		or	c.idCall	= e.idCallD )
					join	dbo.tb_SessShift	h	with (nolock)	on	h.idSess	= @idSess	and	h.idShift	= e.idShift
					where	e.idEvent	between @iFrom	and @iUpto
					and		e.tiHH		between @tFrom	and @tUpto
					and		e.dShift	between @dFrom	and @dUpto
					and		e.siBed & @siBeds <> 0

	declare		cur		cursor fast_forward for
		select	idEvent
			from	#tbEvnt	with (nolock)

	open	cur
	fetch next from	cur	into	@idEvent
	while	@@fetch_status = 0
	begin
		insert	#tbStat
			select	idEvtS, idCallS, tWaitS, tRoomS,	tRoomP
				from	dbo.vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallS in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		insert	#tbStat
			select	idEvtD, idCallD, tWaitD, tRoomD,	tRoomP
				from	dbo.vwEvent_D	ep	with (nolock)
				where	idEvent = @idEvent
				and		idCallD in (select idCall from tb_SessCall with (nolock) where idSess = @idSess)

		fetch next from	cur	into	@idEvent
	end
	close	cur
	deallocate	cur
	
	set	nocount	off

/*	select	e.idUnit, min(u.sUnit), e.idRoom, min(r.cDevice), min(r.sDevice)	--,	e.cBed, e.tiBed
		,	e.dEvent, count(e.idEvent)	--, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin	--, e.idCall, ep.sDial
	--	,	e.idType, t.sType
		,	c.siIdx, min(c.sCall)	--, cp.tiSpec
		,	avg(et.tRoom), sum(et.tRoom), sum(et.tWait), sum(et.tRoomP)
	--	,	cast(cast(e.tEvent as datetime) + cast(et.tRoom as datetime) as time(3))	as	tExit
		from		#tbStat		et	with (nolock)
		join	dbo.vwEvent		e	with (nolock)	on	e.idEvent	= et.idEvent
	--	join	dbo.tb_LogType	t	with (nolock)	on	t.idLogType	= e.idLogType
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
		join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= e.idRoom
		join	dbo.vwCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbCfgPri	cp	with (nolock)	on	cp.siIdx	= c.siIdx
		group	by	e.idUnit, e.idRoom, e.dEvent, c.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, c.siIdx	desc	--, e.idEvent
*/
	select	e.idUnit, u.sUnit, e.idRoom, r.cStn, r.sRoom
		,	e.dEvent, e.lCount,	e.siIdx, e.sCall,	p.tiColor
		,	cast(e.tRoomA as time(3))	as	tRoomA
		,	cast(e.tRoomT as time(3))	as	tRoomT
		,	cast(e.tWait  as time(3))	as	tWait
		,	cast(e.tRoomP as time(3))	as	tRoomP
		from
		(select	e.idUnit, e.idRoom
			,	e.dEvent,	count(e.idEvent)	as	lCount
			,	c.siIdx,	min(c.sCall)		as	sCall
			,	dateadd(ms, avg(datediff(ms, 0, t.tRoom)), 0)	as	tRoomA
			,	dateadd(ms, sum(datediff(ms, 0, t.tRoom)), 0)	as	tRoomT
			,	dateadd(ms, sum(datediff(ms, 0, t.tWait)), 0)	as	tWait
			,	dateadd(ms, sum(datediff(ms, 0, t.tRoomP)), 0)	as	tRoomP
			from		#tbStat		t	with (nolock)
			join	dbo.vwEvent		e	with (nolock)	on	e.idEvent	= t.idEvent
			join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		group	by	e.idUnit, e.idRoom, e.dEvent, c.siIdx
			)	e	--with (nolock)
		join	dbo.tbUnit		u	with (nolock)	on	u.idUnit	= e.idUnit
		join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= e.idRoom
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= e.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, e.siIdx	desc
end
go
--	----------------------------------------------------------------------------
--	Exports calls active at the moment
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				+ 'cast(? as datetime)' as SQL2019 err:	Msg 402, Level 16, State 1	"The data types datetime and time are incompatible in the add operator."
--	7.06.7705
alter proc		dbo.prExportCallsActive
	with encryption
as
begin
	select	c.sUnit		as	UnitName
		,	c.sRoom		as	RoomName
		,	a.cBed		as	BedName
		,	a.sCall		as	CallText
		,	a.dtEvent	as	TimePlaced
		,	cast(a.dtEvent as datetime) + cast(c.tVoice as datetime)	as	TimePicked
		,	e.sDstStn	as	ConsoleName
		,	cast(a.dtEvent as datetime) + cast(c.tStaff as datetime)	as	TimeCancelled
		from	dbo.vwEvent_A	a	with (nolock)
		join	dbo.vwEvent_C	c	with (nolock)	on	c.idEvent	= a.idEvent
	left join	dbo.vwEvent		e	with (nolock)	on	e.idEvent	= c.idEvtV
		where	a.bActive > 0
		order	by	a.idUnit, a.idRoom, a.idEvent
end
go
--	----------------------------------------------------------------------------
--	Exports calls cancelled within a given window of last N hours
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--				* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--				+ 'cast(? as datetime)' as SQL2019 err:	Msg 402, Level 16, State 1	"The data types datetime and time are incompatible in the add operator."
--	7.06.7705
alter proc		dbo.prExportCallsComplete
(
	@tiHours	tinyint		= 0		-- defines the sliding window 'N hours back from now', 0=current hour
)
	with encryption
as
begin
	declare		@iFrom		int
			,	@dtFrom		datetime
			,	@dFrom		date
			,	@tFrom		tinyint
			,	@s			varchar(255)

	set	nocount	on

	select	@dtFrom =	dateadd( hh, -@tiHours, getdate( ) )
	select	@tFrom =	datepart( hh, @dtFrom ),	@dFrom =	@dtFrom

	select	@iFrom =	min(idEvent)
		from	dbo.tbEvent_S	with (nolock)
		where	@dFrom <= dEvent	and	@tFrom <= tiHH

--	select	@s =	'd=' + isnull(convert(varchar, @dFrom, 120),'?') + ' t=' + isnull(cast(@tFrom as varchar),'?') + ' i=' + isnull(cast(@iFrom as varchar),'?')
--	print	@s

	set	nocount	off

	select	c.sUnit		as	UnitName
		,	c.sRoom		as	RoomName
		,	c.cBed		as	BedName
		,	c.sCall		as	CallText
		,	e.dtEvent	as	TimePlaced
		,	cast(e.dtEvent as datetime) + cast(c.tVoice as datetime)	as	TimePicked
		,	v.sDstStn	as	ConsoleName
		,	cast(e.dtEvent as datetime) + cast(c.tStaff as datetime)	as	TimeCancelled
		from	dbo.vwEvent_C	c	with (nolock)
		join	dbo.vwEvent		e	with (nolock)	on	e.idEvent	= c.idEvent
	left join	dbo.vwEvent		v	with (nolock)	on	v.idEvent	= c.idEvtV
	left join	dbo.vwEvent		s	with (nolock)	on	s.idEvent	= c.idEvtS
		where	c.idEvent	>= @iFrom
		and		c.idEvtS is not null
		order	by	c.idUnit, c.idRoom, c.idEvent
end
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing schedule
--	7.06.8830	* @idSchedule marked as 'out'
--	7.06.5886	+ .tiFmt
--	7.05.5044	* @idUser: smallint -> int
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.prSchedule_InsUpd
(
	@idSchedule	smallint	out
,	@tiRecur	tinyint				-- hi 3 bits: 32=Daily, 64=Weekly, 128=Monthly;  lo 5 bits: either 1..31 (D,W), or 1=1st, 2=2nd, 4=3rd, 8=4th, 16=Last
,	@tiWkDay	tinyint				-- 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
,	@siMonth	smallint			-- 1=Jan, 2=Feb, 4=Mar, 8=Apr, 16=May, 32=Jun, 64=Jul, 128=Aug, 256=Sep, 512=Oct, 1024=Nov, 2048=Dec
,	@sSchedule	varchar( 255 )		-- auto: spelled out schedule details
--,	@dtLastRun	smalldatetime		-- when last execution started
,	@dtNextRun	smalldatetime		-- when next execution should start, HH:mm part stores the "Run @" value
--,	@iResult	smallint			-- for last run: 0=Success, !0==Error code
,	@idUser		int					-- requester
,	@idFilter	smallint
,	@idReport	smallint
,	@tiFmt		tinyint				-- 1=PDF, 2=CSV, 3=XLS
,	@sSendTo	varchar( 255 )		-- list of recipient emails
,	@bActive	bit
)
	with encryption
as
begin
	declare		@id		smallint

--	set	nocount	on

	begin	tran

		if	@idSchedule > 0
--		begin
			update	dbo.tbSchedule
				set		tiRecur =	@tiRecur,	tiWkDay =	@tiWkDay,	siMonth =	@siMonth,	sSchedule=	@sSchedule
					,	dtNextRun=	@dtNextRun,	idUser =	@idUser		--, dtLastRun= @dtLastRun, iResult= @iResult
					,	idFilter =	@idFilter,	idReport =	@idReport,	tiFmt=	@tiFmt,	sSendTo =	@sSendTo
					,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idSchedule = @idSchedule
--		end
		else
		begin
			insert	dbo.tbSchedule	(  tiRecur,  tiWkDay,  siMonth,  sSchedule,  dtNextRun,  idUser,  idFilter,  idReport,  tiFmt,  sSendTo )	--,  dtLastRun,  iResult
					values			( @tiRecur, @tiWkDay, @siMonth, @sSchedule, @dtNextRun, @idUser, @idFilter, @idReport, @tiFmt, @sSendTo )	--, @dtLastRun, @iResult
			select	@idSchedule=	scope_identity( )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all existing schedules
--	7.06.8845	* sFilter to indicate public vs. private one
--	7.06.5886	+ .tiFmt
--	7.06.5694
alter proc		dbo.prSchedule_GetAll
(
	@idUser		smallint	= null	-- null=any
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult, s.tiFmt
		,	s.idUser	as	idOwner,	u.sUser	as	sOwner
		,	s.idReport, r.sReport	--, r.sRptName, r.sClass
		,	s.idFilter, case when f.idUser is null then '• ' else '† ' end + f.sFilter	as	sFilter	--,	f.idUser, f.xFilter
		,	s.bActive, s.dtCreated, s.dtUpdated
		from	dbo.tbSchedule	s	with (nolock)
		join	dbo.tbReport	r	with (nolock)	on	r.idReport	= s.idReport
		join	dbo.tbFilter	f	with (nolock)	on	f.idFilter	= s.idFilter
		join	dbo.tb_User		u	with (nolock)	on	u.idUser	= s.idUser
		where	(@idUser is null	or	s.idUser = @idUser)
		and		(@bActive is null	or	s.bActive = @bActive)
end
go
--	----------------------------------------------------------------------------
--	Returns a list of active schedules, due for execution right now
--	7.06.8846	* sUser -> sStaff
--	7.06.5886	+ .tiFmt
--	7.06.5659	+ .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_Get
--	7.05.4980	* u.sFirst + ' ' + u.sLast -> u.sStaff
--	7.03
alter proc		dbo.prSchedule_GetToRun
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult, s.tiFmt, s.sSendTo
		,	s.idUser	as	idOwner,	u.sStaff	as	sOwner
		,	s.idReport, r.sReport, r.sRptName, r.sClass
		,	s.idFilter,	f.idUser, f.sFilter, f.xFilter
		,	s.bActive, s.dtCreated, s.dtUpdated
		from	dbo.tbSchedule	s	with (nolock)
		join	dbo.tbReport	r	with (nolock)	on	r.idReport	= s.idReport
		join	dbo.tbFilter	f	with (nolock)	on	f.idFilter	= s.idFilter
		join	dbo.tb_User		u	with (nolock)	on	u.idUser	= s.idUser
		where	s.bActive > 0	and	s.dtNextRun < getdate( )
end
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge (used by RTLS demo)
--	7.06.8846	* tracelog only assigned badges
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8787	+ '& 0x00FFFFFF' enforcement of 24 bits: 1..16777215
--	7.06.8784	* tb_User.idStfLvl	-> idLvl, @
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
	@idBadge	int					-- 24 bits: 1..16777215 (0x00FFFFFF) - RTLS badges
,	@idLvl		tinyint			out	-- 4=Grn, 2=Ora, 1=Yel, 0=None
,	@idReceiver	smallint			-- current receiver look-up FK
,	@dtReceiver	datetime			-- when registered by current rcvr
,	@bCall		bit					-- 
,	@idUser		int				out
,	@sStaff		varchar( 16 )	out
,	@dtEntered	datetime		out	-- when entered the room
,	@idRoom		smallint		out	-- current 790 device look-up FK
,	@sRoom		varchar( 20 )	out
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

	select	@idBadge =	@idBadge & 0x00FFFFFF								-- enforce 24 bits: 1..16777215
		,	@dt =	getdate( ),		@dt1 =	dateadd(ss, 1, getdate( )),		@iRetVal =	0
		,	@s =	'Bdg_UL( ' + isnull(cast(@idBadge as varchar),'?') + ', ' +
					isnull(cast(@idReceiver as varchar),'?') + ', ''' + isnull(convert(char(19), @dtReceiver, 121),'?') + '''' +
					case when @bCall > 0 then ' +' else '' end + ' )'

	exec	dbo.prRtlsBadge_InsUpd	@idBadge, @idLvl						--	auto-insert new badges		--	7.06.8276

	select	@idUser =	idUser,		@sStaff =	sStaff,		@idLvl =	idLvl
		,	@idFrom =	idRoom,		@sStff =	sStn,		@dtEntered =	dtEntered
		from	dbo.vwRtlsBadge	with (nolock)
		where	idBadge = @idBadge											--	get assigned user's details and previous room

	select	@idRoom =	idRoom,		@sRoom =	sStn
		from	dbo.vwRtlsRcvr	with (nolock)
		where	idReceiver = @idReceiver									--	get entered room's details

	select	@s =	@s + '<br/> ' + case when @idLvl = 4 then 'G' when @idLvl = 2 then 'O' when @idLvl = 1 then 'Y' else '?' end + ':' +
						isnull(cast(@idUser as varchar),'?') + '|' + isnull(cast(@sStaff as varchar),'?') + ', ' +
						isnull(cast(@idFrom as varchar),'?') + '|' + isnull(cast(@sStff as varchar),'?') + ' >> ' +
						isnull(cast(@idRoom as varchar),'?') + '|' + isnull(cast(@sRoom as varchar),'?')

---	if	@tiLog & 0x04 > 0													--	Debug?
---		exec	dbo.pr_Log_Ins	0, null, null, @s

	begin	tran

		update	dbo.tbRtlsBadge
			set		dtUpdated=	@dt,	idReceiver =	@idReceiver,	dtReceiver =	@dtReceiver
			where	idBadge = @idBadge										--	set badge's new receiver
			and	(		idReceiver <> @idReceiver							--	if different from previous
				or	0 < idReceiver	and	@idReceiver	is null
				or	0 < @idReceiver	and	idReceiver	is null)

		if	0 < @bCall	and	0 < @idLvl
			update	dbo.tbRoom
				set		dtUpdated=	@dt,	dtExpires=	@dt,	tiCall |=	@idLvl
				where	idRoom = @idRoom									--	raise badge-call state


		if			@idRoom <> @idFrom										--	badge moved to another room
			or	0 < @idFrom  and  @idRoom	is null							--	or exited
			or	0 < @idRoom  and  @idFrom	is null							--	or entered
		begin

			update	dbo.tbRtlsBadge
				set		dtEntered=	@dt,	@dtEntered =	@dt,	@iRetVal =	1
				where	idBadge = @idBadge									--	set badge's new location

			update	dbo.tb_User
				set		dtEntered=	@dt,	idRoom =	@idRoom,	@iRetVal =	2
				where	idUser = @idUser									--	update user's location


			select	@idStff =	null	--,	@sStff =	null				--	get oldest staff in previous room
			select	top 1	@idStff =	idUser	--,		@sStff =	sStaff
				from	dbo.vwRtlsBadge		with (nolock)
				where	idRoom = @idFrom	and	idLvl = @idLvl
				order	by	dtEntered

			--	set previous room to the oldest staff
			if	@idLvl = 4
				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
						,	tiCall =	case when @idStff is null	then	tiCall & 0xFB	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			else
			if	@idLvl = 2
				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
						,	tiCall =	case when @idStff is null	then	tiCall & 0xFD	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			else
		--	if	@idLvl = 1
				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	@idStff	--,	sStaffY =	@sStff
						,	tiCall =	case when @idStff is null	then	tiCall & 0xFE	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser1 is null
						or	@idStff is null
						or	@idStff <> idUser1	)


			select	@idStff =	null	--,	@sStff =	null				--	get oldest staff in current room
			select	top 1	@idStff =	idUser	--,		@sStff =	sStaff
				from	dbo.vwRtlsBadge		with (nolock)
				where	idRoom = @idRoom	and	idLvl = @idLvl
				order	by	dtEntered

			--	remove that user from any [other] room and set current room to him/her
			if	@idLvl = 4
			begin
				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	null	--,	sStaffG =	null
					where	idUser4 = @idStff

				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			end
			else
			if	@idLvl = 2
			begin
				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	null	--,	sStaffO =	null
					where	idUser2 = @idStff

				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			end
			else
		--	if	@idLvl = 1
			begin
				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	null	--,	sStaffY =	null
					where	idUser1 = @idStff

				update	dbo.tbRoom
					set		dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	@idStff	--,	sStaffY =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser1 is null
						or	@idStff is null
						or	@idStff <> idUser1	)
			end

		end

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			if	@idUser > 0													--	tracelog only assigned badges
				exec	dbo.pr_Log_Ins	0, null, null, @s

	commit

	return	@iRetVal
end
go
--	----------------------------------------------------------------------------
--	Combines call-text definitions (historical) with priorities' details (790 global configuration)
--	7.06.8850
create view		dbo.vwCall
	with encryption
as
select	c.idCall,	c.siIdx, c.sCall, bEnabled, tVoice, tStaff
	,	siFlags, tiShelf, tiColor, iFilter, tiSpec
	,	bActive, dtCreated, c.dtUpdated
	from	dbo.tbCall		c	with (nolock)
	join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
go
grant	select							on dbo.vwCall			to [rWriter]
grant	select							on dbo.vwCall			to [rReader]
go
--	----------------------------------------------------------------------------
--	Report filters (new persistent approach)
--	7.06.8850
create table	dbo.tbFltr
(
	idFltr		smallint		not null	identity( 1, 1 )	--	maybe int?
		constraint	xpFltr		primary key clustered

,	idUser		int				null		-- public, if null
		constraint	fkFltr_User		foreign key references tb_User

,	sFilter		varchar( 64 )	not null	-- filter name
---	s_Filter	as	lower( sFilter )	-- filter-name, lower-cased
---		constraint	xu_Filter	unique,
,	siDRange	smallint		not null
--		constraint	tvFltr_DRange		check	(siDRange	between	-1	and	365)
,	tiHrFrom	tinyint			not null
--		constraint	tvFltr_HrFrom		check	(HrFrom		between	0	and	23)
,	tiHrUpto	tinyint			not null
--		constraint	tvFltr_HrUpto		check	(HrUpto		between	1	and	24)
,	siBeds		smallint		not null	-- [tbRooms.siBeds]: beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
,	bAllRoom	bit				not null
--		constraint	tdFltr_AllRoom		default( 1 )
,	bAllShft	bit				not null
--		constraint	tdFltr_AllShft		default( 1 )
,	bAllUser	bit				not null
--		constraint	tdFltr_AllUser		default( 1 )
,	bAllNorm	bit				not null
--		constraint	tdFltr_AllNorm		default( 1 )
,	bAllSpec	bit				not null
--		constraint	tdFltr_AllSpec		default( 1 )
,	bAllRmnd	bit				not null
--		constraint	tdFltr_AllRmnd		default( 1 )
,	bAllClin	bit				not null
--		constraint	tdFltr_AllClin		default( 1 )

,	dtCreated	smalldatetime	not null
		constraint	tdFltr_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdFltr_Updated	default( getdate( ) )
)
create unique nonclustered index	xuFltr		on dbo.tbFltr ( idUser, sFilter )
		---	filter names should be unique per user
go
grant	select, insert, update, delete	on dbo.tbFltr			to [rWriter]
grant	select, insert, update, delete	on dbo.tbFltr			to [rReader]
go
--	----------------------------------------------------------------------------
--	Report filters for staff
--	7.06.8850
create table	dbo.tbFltrUser
(
	idFltr		smallint		not null
		constraint	fkFltrUser_Fltr		foreign key references	tbFltr
,	idUser		int				not null
		constraint	fkFltrUser_User		foreign key references	tb_User
	
,	constraint	xpFltrUser		primary key clustered ( idFltr, idUser )
)
go
grant	select, insert, update, delete	on dbo.tbFltrUser		to [rWriter]
grant	select, insert, update, delete	on dbo.tbFltrUser		to [rReader]
go
--	----------------------------------------------------------------------------
--	Report filters for shifts
--	7.06.8850
create table	dbo.tbFltrShift
(
	idFltr		smallint		not null
		constraint	fkFltrShift_Fltr	foreign key references	tbFltr
,	idShift		smallint		not null
		constraint	fkFltrShift_Shft	foreign key references	tbShift
	
,	constraint	xpFltrShift		primary key clustered ( idFltr, idShift )
)
go
grant	select, insert, update, delete	on dbo.tbFltrShift		to [rWriter]
grant	select, insert, update, delete	on dbo.tbFltrShift		to [rReader]
go
--	----------------------------------------------------------------------------
--	Report filters for stations
--	7.06.8850
create table	dbo.tbFltrStn
(
	idFltr		smallint		not null
		constraint	fkFltrStn_Fltr		foreign key references	tbFltr
,	idStn		smallint		not null
		constraint	fkFltrStn_Stn		foreign key references	tbCfgStn
	
,	constraint	xpFltrStn		primary key clustered ( idFltr, idStn )
)
go
grant	select, insert, update, delete	on dbo.tbFltrStn		to [rWriter]
grant	select, insert, update, delete	on dbo.tbFltrStn		to [rReader]
go
--	----------------------------------------------------------------------------
--	Report filters for call priorities
--	7.06.8850
create table	dbo.tbFltrCall
(
	idFltr		smallint		not null
		constraint	fkFltrCall_Fltr		foreign key references	tbFltr
,	idCall		smallint		not null
		constraint	fkFltrCall_Call		foreign key references	tbCall

,	tVoice		time( 0 )		not null
,	tStaff		time( 0 )		not null
	
,	constraint	xpFltrCall		primary key clustered ( idFltr, idCall )
)
go
grant	select, insert, update, delete	on dbo.tbFltrCall		to [rWriter]
grant	select, insert, update, delete	on dbo.tbFltrCall		to [rReader]
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 8882 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8882, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2024-04-26',	sVersion =	'*7983ss, *7983rh, *7980cw, *7980ns'
		where	siBuild = 8882

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.8882'
		where	idModule = 1

	exec	dbo.prHealth_Stats

	declare		@s		varchar(255)

	select	@s =	sVersion + ', [' + db_name( ) + '], ' + sArgs
		from	dbo.tb_Module
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, 4, null, @s			--	4=system
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