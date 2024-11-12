--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
--		2013-Aug-16		.4975
--						* tb_LogType:	.tiLevel -> .tiLvl, tiSource -> tiSrc	(pr_Log_Get)
--		2013-Aug-16		.4976
--						* tb_User:		- .bLocked, td_User_Fails -> td_User_Failed
--							.sFirst -> .sFrst, .sMid -> .sMidd (prUser_Exp, prUser_Imp, pr_User_Login, vwStaff)
--						* tb_OptSys[10]:= 60
--						* tbCfgBed:		.bInUse -> .bActive, tdCfgBed_InUse -> tdCfgBed_Active	(prEvent_Ins, prDevice_UpdRoomBeds)
--						* prCfgBed_GetAll:	+ @bActive
--						* tbCall:		xuCall_Active_sCall, xuCall_Active_siIdx: depend on .bActive, not .bEnabled	(prCall_Imp)
--						- tbEvent_P, tbEvent_T	(vwEvent_T, prEvent_A_Exp, prEvent_Ins, prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins
--						* tbEvent_C:	.cBed -> .tiBed,	- .idEvtRn, .tRn, .idEvtCn, .tCn, .idEvtAi, .tAi	(vwEvent_C)
--						- prUnit_InsUpdDel, prShift_InsUpdDel
--		2013-Aug-20		.4980
--						* tb_LogType:	+ [82]
--						* pr_SessStaff_Ins, pr_SessShift_Ins, prSchedule_InsUpd, prSchedule_Upd, prSchedule_Del:	-- nocount
--						* prSchedule_GetToRun:	u.sStaff
--		2013-Aug-21		.4981
--						* prRptCallStatSum, prRptCallActSum, prRptCallActDtl
--		2013-Aug-23		.4983
--						* prUser_Exp -> pr_User_Exp, prUser_Imp -> pr_User_Imp
--						+ pr_User_GetAll
--						* prStaff_GetAll:	.bInclude -> .bEnabled
--						* prUser_sStaff_Upd:	' ?' -> ' ' (remove question-marks)
--						+ prUnit_UpdShifts
--		2013-Aug-27		.4987
--						* pr_User_Imp:	- @bLocked
--		2013-Aug-28		.4988
--						* prStaff_Imp
--						* tb_User.tvUser_Name redefined
--		2013-Aug-30		.4990
--						* prMapCell_GetByUnit, prUnitMapCell_Upd:	+ @tiRID[i], @tiBtn[i]
--						+ prCfgDvc_GetBtns
--		2013-Sep-09		.5000
--						* added .tiShelf, .tiSpec:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit, prMapCell_GetByUnitMap
--		2013-Sep-11		.5002
--						* tb_Option, tb_OptionSys: + [18]
--		2013-Sep-12		.5003
--						* prRoomBed_GetByUnit
--		2013-Sep-16		.5007
--						* fnEventA_GetTopByRoom:	+ @bPrsnc	(prRoomBed_GetByUnit, prMapCell_GetByUnitMap)
--		2013-Sep-17		.5008
--						* vwStfAssn:	+ .tiShIdx
--						* vwStaff:		+ .sBarCode
--		2013-Sep-19		.5010
--						* tbTeamStaff -> tb_UserTeam,	.idStaff -> .idUser
--						* tbTeamUnit:	xpTeamUnit -> ( idTeam, idUnit )
--						* tbTeamPri:	xpTeamPri -> ( idTeam, siIdx )
--						* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--							xpStfDvc -> xpDvc, fkStfDvc_Type -> fkDvc_Type, tdStfDvc_Flags -> tdDvc_Flags, fkStfDvc_Staff -> fkDvc_User
--							tdStfDvc_Active -> tdDvc_Active, tdStfDvc_Created -> tdDvc_Created, tdStfDvc_Updated -> tdDvc_Updated
--							xuStfDvc_Active -> xuDvc_Active,	fkRtlsBadge_StfDvc -> fkRtlsBadge_Dvc
--							(prStfDvc_UpdStf, tbStfDvcUnit, prStaff_LstAct, tbRtlsBadge, vwRtlsBadge, prRtlsBadge_InsUpd, vwRtlsRoom, prRtlsBadge_GetAll)
--						* prStfDvc_UpdStf -> prDvc_UpdUsr
--						* tbStfDvcUnit -> tbDvcUnit
--							xpStfDvcUnit -> xpDvcUnit, fkStfDvcUnit_StfDvc -> fkDvcUnit_Dvc, fkStfDvcUnit_Unit -> fkDvcUnit_Unit, tdStfDvcUnit_Created -> tdDvcUnit_Created
--						* vwStaff:	.idStaff -> .idUser
--							(prStaff_GetAll, prStaff_LstAct, vwRoomBed, vwStfAssn, vwStfCvrg, fnStfAssn_GetByShift, vwRtlsBadge, vwRtlsRoom, prRptStaffAssn, prRptStaffCover, prUser_sStaff_Upd)
--						* tb_UserUnit:	.idStaff -> .idUser
--						* tbShift:	.idStaff -> .idUser,	fkShift_Staff -> fkShift_User	(prShift_Exp, prShift_Imp, prShift_GetByUnit)
--						* tbStfAssn:	.idStaff -> .idUser, fkStfAssn_Staff -> fkStfAssn_User
--							- .iStamp, .TempID
--							(vwStfAssn, vwStfCvrg, prStfAssn_InsUpdDel, prStfCvrg_InsFin, fnStfAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--						* tb_SessStaff -> tb_SessUser,		.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser
--							(pr_SessStaff_Ins -> pr_SessUser_Ins)
--		2013-Sep-30		.5021
--						+ pr_User_InsUpd, pr_Role_InsUpd, prTeam_InsUpd, prDvc_InsUpd
--						+ tb_LogType:	[247,248]
--		2013-Oct-08		.5029
--						* dbo.Team expanded;	pr_User_InsUpd, prTeam_InsUpd fixed
--						* dbo.Units redefined
--		2013-Oct-10		.5031
--						+ pr_UserRole_InsDel
--		2013-Oct-17		.5038
--						- prDevice_UpdRoomBeds7980, * prDevice_UpdRoomBeds
--						[* tb_SessStaff -> tb_SessUser,		.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser]
--							(pr_Sess_Clr, pr_Sess_Del, prRptStaffAssn, prRptStaffCover)
--		2013-Oct-21		.5042
--						+ tb_User.sTeams	(vwStaff, DeviceToStaffAssignment)
--		2013-Oct-22		.5043
--						+ prUnit_GetByUser, prCfgLoc_GetByUser
--		2013-Oct-23		.5044
--						* @idUser: smallint -> int
--							(pr_Log_Ins, pr_OptSys_Upd, pr_Sess_Ins, pr_Sess_Act, pr_User_Login, pr_User_Logout, prFilter_GetByUser, prFilter_InsUpd, prCall_Upd, prSchedule_InsUpd)
--		2013-Oct-24		.5045
--						* tb_LogType:	[33,38,39,61,62]
--		2013-Oct-29		.5050
--						* DeviceToStaffAssignment
--						* prStfAssn_InsUpdDel
--						+ prStfAssn_Exp
--						+ pr_UserUnit_Set
--		2013-Nov-06		.5058
--						+ prTeamUnit_Set
--						* dbo.Team:	.Timer
--						* fix tbStfAssn PK,FK names
--		2013-Nov-07		.5059
--						* tb_UserTeam -> tbTeamUser
--						+ tbDvcTeam
--						* pr_Module_Act
--						* tb_Module:	.dtStart -> .dtStarted (pr_Module_Upd), revoke insert,delete
--						+ tb_Feature, tb_Access
--						* tb_Sess:	+ .idModule	(pr_Sess_Ins)
--							tb_Sess_User -> fk_Sess_User, tb_Sess_LastAct -> td_Sess_LastAct, tb_Sess_Created -> td_Sess_Created
--		2013-Nov-12		.5064
--						* prStaff_LstAct:	.idDvcType = 1
--						* prFilter_GetByUser:	check for IsAdmin
--						* prEvent_Ins:	.bActive > 0 when selecting @idParent
--		2013-Nov-13		.5065
--						* tb_Module:	revert .dtStarted -> .dtStart (pr_Module_Upd)
--						* tbEvent_C:	+ .idUser	(vwEvent_C)
--		2013-Nov-14		.5066
--						* pr_User_Exp:	fix >= 16
--						* vwEvent	(prRptSysActDtl, vwEvent98)
--						* prEvent84_Ins:	mark presence events, store tbEvent_C.idUser
--						* tb_LogType:	[80,81]
--		2013-Nov-18		.5070
--						* fnEventA_GetByMaster:		> 0 -> <> 0	- signed operands produce signed result
--		2013-Nov-19		.5071
--						* pr_OptSys_Upd, pr_OptUsr_Upd
--		2013-Nov-22		.5074
--						+ tbDvc.xuDvc_TypeDial, tvDvc_Dial
--						* prPatient_GetIns:		+ @idDoctor	(prEvent84_Ins, prEvent98_Ins)
--						+ prStfAssn_Imp,	* prStfAssn_Exp
--						* dbo.Team:		+ .tResp
--						* prRoomBed_GetByUnit, prMapCell_GetByUnitMap
--		2013-Nov-25		.5077
--						* prRptStaffAssn, prRptStaffCover:	fix bed designation (inner join -> left outer join)
--		2013-Nov-27		.5079
--						+ on delete cascade for tbStfAssn.fkStfAssn_RoomBed, tbStfCvrg.fkStfCvrg_StfAssn
--						+ on delete set null for tbPatient.fkPatient_RoomBed
--		2013-Dec-02		.5084
--						* pr_UserUnit_Set:	fix for null @sUnits
--		2013-Dec-03		.5085
--						* prCall_GetAll:	+ @bVisible
--						- tbDvc.xuDvc_Active:	no need to enforce unique description
--		2013-Dec-04		.5086
--						+ tbStfCvrg.dtDue	(prStfCvrg_InsFin, vwStfCvrg)
--						- tbUnit.idShPrv	(- tbUnit.fkUnit_PrevShift)
--						* prRptStaffAssn -> prRptStfAssn, prRptStaffCover -> prRptStfCvrg,	- .sRoomBed
--		2013-Dec-05		.5087
--						* prShift_Imp, prStfAssn_Imp
--						+ prRtlsRcvr_Init, prRtlsBadge_Init
--						* prCfgLoc_SetLvl:	deactivate tbShift
--		2013-Dec-13		.5095
--						+ tbPcsType
--						* tbEvent41:	+ .idDvc, .idUser;	- .siIdx, .dtAttempt, .biPager;		(prEvent41_Ins, prRptSysActDtl, prRptCallActDtl)
--										* .tiSeqNum -> .tiSeqAct, null -> not null;		.cStatus not null -> null
--						+ vwDvc, vwEvent41
--						+ tb_LogType[ 204 ]
--						+ tbDefCmd[ 40, 42-44, C2-C5 ]
--						* prEvent_Ins:	'or @idCmd < 0x80' when selecting @idParent
--						* vwRoom:	use tbRoom.dtUpdated
--						* prEvent84_Ins:	fix tbEvent_C.idUser
--						* prDevice_InsUpd:	skip .sUnits calculation for gateways
--						* tb_Option[ 5 ]:	redefined
--						* vwRoom, vwDevice:		- .sFnDevice
--						* vwEvent95, vwEvent98:	+ 'with (nolock)'
--		2013-Dec-16		.5098
--						* pr_UserUnit_Set:	+ check idUnit
--						* prDevice_UpdRoomBeds:	+ tbRoom.tiSvc, tbRoomBed.tiSvc reset
--		2013-Dec-17		.5099
--						* prStfCvrg_InsFin:	fix #tbDueAssn logic
--						+ prDvc_Exp, prDvc_Imp
--						+ tb_User:	.idRoom, .dtEntered		(prRtlsBadge_RstLoc, prRtlsBadge_UpdLoc)
--		2013-Dec-19		.5101
--						* prPatient_UpdLoc:		force no-bed for rooms with no beds
--						* prEvent84_Ins:	+ @cGender, call prPatient_UpdLoc
--		2013-Dec-20		.5102
--						* prRtlsBadge_UpdLoc:	
--						* prEvent41_Ins:	+ @idDvcType
--		2013-Dec-23		.5105
--						* prPatient_UpdLoc:		clear room upon no patient
--						* pr_Module_Upd:	tbEvent.sInfo format is now .sModule + ' v.' + .sVersion
--		2014-Jan-08		.5121
--						* tb_User:	+ .sUnits	(pr_User_Exp, pr_User_Imp, pr_User_InsUpd, pr_UserUnit_Set, vwStaff, dbo.Staff)
--						* tbDvc:	+ .sUnits	(vwDvc, prDvc_InsUpd, prDvc_Exp, prDvc_Imp, dbo.Device)
--		2014-Jan-10		.5123
--						* prUser_sStaff_Upd -> pr_User_sStaff_Upd,	- @tiFmt
--						* prStfCvrg_InsFin:		fix datetime arithmetics for 2012
--		2014-Jan-13		.5126
--						* vwStaff:	+ .idRoom
--		2014-Jan-14		.5127
--						* prEvent98_Ins:	+ @cGender
--						* prPatient_UpdLoc:		ignore @tiRID
--						+ vwPatient
--						* vwStfAssn:	+ .bOnDuty,		sc.tBeg -> sc.dtBeg, sc.tEnd -> sc.dtEnd
--						* vwStfCvrg:	+ .bOnDuty,		- sc.dtEnd (null by selection criteria)
--						+ StaffToPatientAssn	(means to utilize tb_User.bOnDuty by 7980ps without redesign)
--						* DeviceToStaffAssignment:	+ .bOnDuty, sFqStaff
--		2014-Jan-22		.5135
--						* prPatient_UpdLoc:	check if room-bed exists and log errors
--		2014-Jan-28		.5141
--						* prEvent_Ins:	use @cDevice for dst-device also
--						* prDevice_GetIns:	added isnull( ,'?') to @cDevice, @sDevice
--		2014-Feb-03		.5147
--						* tb_LogType[82] -> 'Invalid data'
--						* prEvent84_Ins:	don't call prPatient_GetIns for presence calls
--						* prPatient_UpdLoc:	don't move patient for room-level calls
--						* prRtlsBadge_UpdLoc:	+ check+log receiver IDs
--		2014-Feb-10		.5154
--						* vwRoom, vwRoomBed:	+ .idRegN, .idRegLvlN, .sRegIDN, .sRegN, .bRegDutyN
--						+ prUnit_SetTmpFlt
--						* prRoomBed_GetByUnit,	prMapCell_GetByUnitMap
--						+ prStaff_GetByUnit
--						+ prStfAssn_GetByUnit
--						* vwDvc
--		2014-Feb-11		.5155
--						finalized?
--
--	7.06
--		2014-Dec-03		.5450
--						* update tb_User from wtStaff
--						* deactivate all tbCall dups by .sCall and .siIdx
--		2014-Dec-17		.5464
--						+ drop fk_Access_Feature before drop tb_Feature
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5155 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.05.5155', 18, 0 )

go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertExceptionLog')
	drop proc	dbo.sp_InsertExceptionLog
if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertRoomBedCoverage')
	drop proc	dbo.sp_InsertRoomBedCoverage
if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertUnit')
	drop proc	dbo.sp_InsertUnit
if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertBedDefinition')
	drop proc	dbo.sp_InsertBedDefinition
if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_UpdateSpecialCallPriority')
	drop proc	dbo.sp_UpdateSpecialCallPriority
if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertCallPriority')
	drop proc	dbo.sp_InsertCallPriority
if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertArchticturalConfig')
	drop proc	dbo.sp_InsertArchticturalConfig
if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertSvcReqTimer')
	drop proc	dbo.sp_InsertSvcReqTimer
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssnDef_Exp')
	drop proc	dbo.prStaffAssnDef_Exp
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_Exp')
	drop proc	dbo.prUnit_Exp
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_Exp')
	drop proc	dbo.prStaff_Exp
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='DeviceToStaffAssignment')
begin
	if	objectproperty( object_id('dbo.SetD2SUpdateTime'), 'IsTrigger' ) > 0
		drop trigger	dbo.SetD2SUpdateTime
	exec sp_rename 'dbo.DeviceToStaffAssignment',	'wtDeviceToStaffAssignment',	'object'
--	drop table	dbo.DeviceToStaffAssignment
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='StaffToPatientAssignment')
begin
	if	objectproperty( object_id('dbo.trStaffToPatientAssignment_AfInsUpd'), 'IsTrigger' ) > 0
		drop trigger	dbo.trStaffToPatientAssignment_AfInsUpd
	exec sp_rename 'dbo.StaffToPatientAssignment',	'wtStaffToPatientAssignment',	'object'
--	drop table	dbo.StaffToPatientAssignment
end
go
--if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='Access')
--	drop table	dbo.Access
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='Device')
begin
	if	objectproperty( object_id('dbo.DeleteDevice'), 'IsTrigger' ) > 0
		drop trigger	dbo.DeleteDevice
	if	objectproperty( object_id('dbo.UpdateActiveStatus'), 'IsTrigger' ) > 0
		drop trigger	dbo.UpdateActiveStatus
	exec sp_rename 'dbo.Device',		'wtDevice',			'object'
--	drop table	dbo.Device
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='Team')
	exec sp_rename 'dbo.Team',			'wtTeam',			'object'
--	drop table	dbo.Team
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='wtTeam')
	and	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.wtTeam') and name = 'siIdx')
begin
	exec( 'alter table	dbo.wtTeam	add
			siIdx		smallint		null
		,	idTeam		smallint		null'
		)
	exec( 'update	t	set	t.siIdx= p.siIdx
			from	dbo.wtTeam	t
			join	dbo.tbCfgPri	p	on	p.sCall = t.CallPriority'
		)
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='StaffRole')
	exec sp_rename 'dbo.StaffRole',		'wtStaffRole',		'object'
--	drop table	dbo.StaffRole
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='UserMember')
	drop table	dbo.UserMember
go
--if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='Units')
--	drop view	dbo.Units
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='Staff')
begin
	if	objectproperty( object_id('dbo.UpdateStaffD2S'), 'IsTrigger' ) > 0
		drop trigger	dbo.UpdateStaffD2S
	if	objectproperty( object_id('dbo.SetStaffUpdateTime'), 'IsTrigger' ) > 0
		drop trigger	dbo.SetStaffUpdateTime
	if	objectproperty( object_id('dbo.InsertStaffD2S'), 'IsTrigger' ) > 0
		drop trigger	dbo.InsertStaffD2S
	if	objectproperty( object_id('dbo.DeleteStaffD2S'), 'IsTrigger' ) > 0
		drop trigger	dbo.DeleteStaffD2S
	exec sp_rename 'dbo.Staff',			'wtStaff',			'object'
--	drop table	dbo.Staff
end
go
--if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='BedDefinition')
--	drop view	dbo.BedDefinition
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='CallPriority')
	exec sp_rename 'dbo.CallPriority',	'wtCallPriority',	'object'
go
--	drop table	dbo.CallPriority
--if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='ArchitecturalConfig')
--	drop view	dbo.ArchitecturalConfig
if exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='Facility')
begin
	if	objectproperty( object_id('dbo.tr_NameFormatChanged2'), 'IsTrigger' ) > 0
		drop trigger	dbo.tr_NameFormatChanged2
--	drop table	dbo.Facility
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='DBVersion')
	drop table	dbo.DBVersion
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='ExceptionLog')
	drop table	dbo.ExceptionLog
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='User7985')
	drop table	dbo.User7985
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwPatient')
	drop view	dbo.vwPatient
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent41')
	drop view	dbo.vwEvent41
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDvc')
	drop view	dbo.vwDvc
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStfCvrg')
	drop proc	dbo.prRptStfCvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStfAssn')
	drop proc	dbo.prRptStfAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStaffCvrg')
	drop proc	dbo.prRptStaffCvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStaffCover')
	drop proc	dbo.prRptStaffCover
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStaffAssn')
	drop proc	dbo.prRptStaffAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Set')
	drop proc	dbo.pr_UserUnit_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_UpdRoomBeds7980')
	drop proc	dbo.prDevice_UpdRoomBeds7980
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessStaff_Ins')
	drop proc	dbo.pr_SessStaff_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessUser_Ins')
	drop proc	dbo.pr_SessUser_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_Init')
	drop proc	dbo.prRtlsBadge_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRcvr_Init')
	drop proc	dbo.prRtlsRcvr_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_GetByUnit')
	drop proc	dbo.prStfAssn_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_Imp')
	drop proc	dbo.prStfAssn_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_Exp')
	drop proc	dbo.prStfAssn_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfDvc_UpdStf')
	drop proc	dbo.prStfDvc_UpdStf
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_Imp')
	drop proc	dbo.prDvc_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_Exp')
	drop proc	dbo.prDvc_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_UpdUsr')
	drop proc	dbo.prDvc_UpdUsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_InsUpd')
	drop proc	dbo.prDvc_InsUpd
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgLoc_GetByUser')
	drop proc	dbo.prCfgLoc_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_GetByUser')
	drop proc	dbo.prUnit_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Set')
	drop proc	dbo.pr_UserUnit_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_GetBtns')
	drop proc	dbo.prCfgDvc_GetBtns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByUnit')
	drop proc	dbo.prStaff_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUnit_Set')
	drop proc	dbo.prTeamUnit_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamPri_InsDel')
	drop proc	dbo.prTeamPri_InsDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_InsUpd')
	drop proc	dbo.prTeam_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_SetTmpFlt')
	drop proc	dbo.prUnit_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_UpdShifts')
	drop proc	dbo.prUnit_UpdShifts
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_InsDel')
	drop proc	dbo.pr_UserRole_InsDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_Imp')
	drop proc	dbo.prUser_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_Exp')
	drop proc	dbo.prUser_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_InsUpd')
	drop proc	dbo.pr_Role_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_InsUpd')
	drop proc	dbo.pr_User_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Imp')
	drop proc	dbo.pr_User_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Exp')
	drop proc	dbo.pr_User_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetAll')
	drop proc	dbo.pr_User_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_sStaff_Upd')
	drop proc	dbo.pr_User_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_sStaff_Upd')
	drop proc	dbo.prUser_sStaff_Upd
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessStaff')
	drop table	dbo.tb_SessStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessUser')
	drop table	dbo.tb_SessUser
/*if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbPcsType')
	drop table	dbo.tbPcsType
begin
--	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_User_Room')
			alter table	dbo.tb_User		drop constraint fk_User_Room
		drop table	dbo.tbPcsType
--	commit
end
*/
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvcUnit')
	drop table	dbo.tbStaffDvcUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffUnit')
	drop table	dbo.tbStaffUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvcUnit')
	drop table	dbo.tbStfDvcUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvcTeam')
	drop table	dbo.tbDvcTeam
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvcUnit')
	drop table	dbo.tbDvcUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_UserUnit')
	drop table	dbo.tb_UserUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamStaff')
	drop table	dbo.tbTeamStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_UserTeam')
	drop table	dbo.tb_UserTeam
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamUser')
	drop table	dbo.tbTeamUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamUnit')
	drop table	dbo.tbTeamUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamPri')
	drop table	dbo.tbTeamPri
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Feature')
begin
--	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_Access_Feature')
			alter table	dbo.tb_Access	drop constraint fk_Access_Feature
		drop table	dbo.tb_Feature
--	commit
end
go

go
/*if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'dtStart')
begin
	begin tran
		exec sp_rename 'tb_Module.dtStart',	'dtStarted',		'column'
	commit
end
*/
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'dtStarted')
begin
	begin tran
		exec sp_rename 'tb_Module.dtStarted',	'dtStart',		'column'
	commit
end
go
revoke	insert, delete					on dbo.tb_Module		from [rWriter]
revoke	insert							on dbo.tb_Module		from [rReader]
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
	begin tran
		update	tb_Module		set	dtLastAct= getdate( )
			where	idModule = @idModule
	commit
end
go
--	----------------------------------------------------------------------------
--	App module Features
--	7.05.5059
create table	dbo.tb_Feature
(
	idModule	tinyint			not null
		constraint	fk_Feature_Module	foreign key references	tb_Module
,	idFeature	tinyint			not null

,	sFeature	varchar( 32 )	not null
,	sDesc		varchar( 255 )	null		-- description / note / comment

,	constraint	xp_Feature		primary key clustered ( idModule, idFeature )
)
go
grant	select							on dbo.tb_Feature		to [rWriter]
grant	select							on dbo.tb_Feature		to [rReader]
go
--	----------------------------------------------------------------------------
begin tran
	update	tbStfLvl	set	iColorB= 0xFFFFFFE0		where	idStfLvl = 1
	update	tbStfLvl	set	iColorB= 0xFFFFE4C4		where	idStfLvl = 2
	update	tbStfLvl	set	iColorB= 0xFF98FB98		where	idStfLvl = 4
commit
go
--	----------------------------------------------------------------------------
--	App users
--	7.05.5121	+ .sUnits
--	7.05.5099	+ .idRoom, .dtEntered
--	7.05.5042	+ .sTeams
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked (tiFails == 0xFF indicates locked-out), td_User_Fails -> td_User_Failed
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'sFirst')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tvUser_Name')
			alter table	dbo.tb_User		drop constraint	tvUser_Name

		exec sp_rename 'tb_User.sFirst',	'sFrst',			'column'
		exec sp_rename 'tb_User.sMid',		'sMidd',			'column'
	--	exec sp_rename 'td_User_Fails',		'td_User_Failed',	'object'

		exec( 'alter table	dbo.tb_User		add
			constraint	tvUser_Name	check ( sFrst is not null or sMidd is not null or sLast is not null )'
			)

		if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'bLocked')
			exec( 'update	dbo.tb_User	set	tiFails= 0xFF	where	bLocked > 0

				alter table	dbo.tb_User		drop constraint	td_User_Locked
				alter table	dbo.tb_User		drop column		bLocked'
				)
	commit
end
go
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'sTeams')
begin
	begin tran
		alter table		dbo.tb_User		add
			sTeams		varchar( 32 )	null		-- tmp: teams
	commit
end
go
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'sUnits')
begin
	begin tran
		alter table		dbo.tb_User		add
			sUnits		varchar( 255 )	null		-- tmp: units
		exec( 'update	dbo.tb_User	set	sUnits= sBarCode
				update	dbo.tb_User	set	sBarCode= null' )
	commit
end
go
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'idRoom')
begin
	begin tran
		alter table		dbo.tb_User		add
			dtEntered	datetime		null		-- live: when entered the room
		,	idRoom		smallint		null		-- live: room look-up FK
				constraint	fk_User_Room	foreign key references	tbRoom
	commit
end
go
--	update users
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='wtStaff')
begin
	begin tran
		exec( 'update	u	set	u.sDesc= s.AccessLevel, u.sUnits= s.Units, u.sMidd= s.MiddleName
				from	tb_User u
				join	wtStaff s	on	s.ID = u.sStaffID
			update	u	set	u.sEmail= s.Password	--, u.sUser= s.UserName			--	7.06.5450	removed: causes dups for xu_User
				from	tb_User u
				join	wtStaff s	on	s.ID = u.sStaffID	and	len( s.UserName ) > 0
			' )
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns security details for all users
--	7.05.4983
create proc		dbo.pr_User_GetAll
(
	@bActive	bit= null			-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUser, u.sUser, cast(case when u.tiFails=0xFF then 1 else 0 end as bit) [bLocked]
		,	u.tiFails, u.sFrst, u.sMidd, u.sLast, u.dtLastAct, u.sStaffID, u.idStfLvl, l.sStfLvl
		,	u.sBarCode, u.bOnDuty, u.sStaff, u.bActive, u.dtCreated, u.dtUpdated
		from	tb_User		u	with (nolock)
		left outer join	tbStfLvl	l	with (nolock)	on	l.idStfLvl = u.idStfLvl
		where	(@bActive is null	or	u.bActive = @bActive)
			and	idUser > 1			--	or 16?	protect internal accounts
end
go
grant	execute				on dbo.pr_User_GetAll				to [rWriter]
grant	execute				on dbo.pr_User_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all users
--	7.05.5121	+ .sUnits
--	7.05.5066	* >= 16
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked
--	7.04.4965
create proc		dbo.pr_User_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc, dtLastAct
		,	sStaffID, idStfLvl, sBarCode, sUnits, bOnDuty, sStaff, bActive, dtCreated, dtUpdated
		from	tb_User		with (nolock)
		where	idUser >= 16
		order	by	idUser
end
go
grant	execute				on dbo.pr_User_Exp					to [rWriter]
grant	execute				on dbo.pr_User_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a user
--	7.05.5121	+ .sUnits
--	7.05.4986	- @bLocked
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked
--	7.04.4965
create proc		dbo.pr_User_Imp
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
,	@sStaffID	varchar( 16 )
,	@idStfLvl	tinyint
,	@sBarCode	varchar( 32 )
,	@sUnits		varchar( 255 )
,	@bOnDuty	bit
,	@sStaff		varchar( 16 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idUser)
		begin
			set identity_insert	dbo.tb_User	on

			insert	tb_User	(  idUser,  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  dtLastAct
							,  sStaffID,  idStfLvl,  sBarCode,  sUnits,  bOnDuty,  sStaff,  bActive,  dtCreated,  dtUpdated )
					values	( @idUser, @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @dtLastAct
							, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @bOnDuty, @sStaff, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tb_User	off
		end
		else
			update	tb_User	set	sUser= @sUser, iHash= @iHash, tiFails= @tiFails, sFrst= @sFrst, sMidd= @sMidd
						,	sLast= @sLast, sEmail= @sEmail, sDesc= @sDesc, dtLastAct= @dtLastAct, sStaffID= @sStaffID
						,	idStfLvl= @idStfLvl, sBarCode= @sBarCode, sUnits= @sUnits, bOnDuty= @bOnDuty
						,	sStaff= @sStaff, bActive= @bActive, dtCreated= @dtCreated, dtUpdated= @dtUpdated
				where	idUser = @idUser

	commit
end
go
grant	execute				on dbo.pr_User_Imp					to [rWriter]
--grant	execute				on dbo.pr_User_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts one or deletes one or all user-role membership records
--	7.05.5031
create proc		dbo.pr_UserRole_InsDel
(
	@bIns		bit				-- 0=Del, 1=Ins
,	@idUser		int
,	@idRole		smallint= null	-- null=clear
)
	with encryption
as
begin
--	set	nocount	on
	begin tran
		if	@bIns = 0
			delete	from	tb_UserRole
				where	idUser = @idUser
				and		(idRole = @idRole	or	@idRole is null)
		else
			if	not	exists	(select 1 from tb_UserRole where idUser = @idUser and idRole = @idRole)
				insert	tb_UserRole	(  idUser,  idRole )
						values		( @idUser, @idRole )
	commit
end
go
grant	execute				on dbo.pr_UserRole_InsDel			to [rWriter]
grant	execute				on dbo.pr_UserRole_InsDel			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates full formatted name
--	7.05.5123	* prUser_sStaff_Upd -> pr_User_sStaff_Upd
--				- @tiFmt:	always use tb_OptSys[11]
--	7.05.5010	* .idStaff -> .idUser
--	7.05.4983	* ' ?' -> ' ' (remove question-marks)
--	7.04.4919	* prStaff_sStaff_Upd -> prUser_sStaff_Upd
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.01	* add width enforcement
--	6.05
create proc		dbo.pr_User_sStaff_Upd
(
	@idUser		int							-- null = entire table
)
	with encryption
as
begin
	declare	@tiFmt		tinyint	

	set	nocount	on

	select	@tiFmt= cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 11

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
			where	idUser = @idUser	or	@idUser is null

	commit
end
go
grant	execute				on dbo.pr_User_sStaff_Upd			to [rWriter]
grant	execute				on dbo.pr_User_sStaff_Upd			to [rReader]
go
--	force update
begin tran
	exec	dbo.pr_User_sStaff_Upd	null
commit
go
--	----------------------------------------------------------------------------
--	7.05.4988	* tb_User: .sFirst -> .sFrst, .sMid -> .sMidd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_Imp')
	drop proc	dbo.prStaff_Imp
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
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
,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
,	@sMachine	varchar( 32 )		-- client computer's name

,	@idUser		smallint out		-- null if attempt failed
,	@sFrst		varchar( 32 ) out	-- first-name
,	@sLast		varchar( 32 ) out	-- last-name
,	@bAdmin		bit out				-- is user member of built-in Admins role?
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
	declare		@iHass		int
	declare		@bActive	bit
	declare		@bLocked	bit
	declare		@idLogType	tinyint
	declare		@tiFails	tinyint
	declare		@tiMaxAtt	tinyint

	set	nocount	on

	select	@tiMaxAtt= cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 2

	select	@s= '@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

--	select	@idUser= idUser, @iHass= iHash, @bActive= bActive, @bLocked= bLocked, @tiFails= tiFails, @sFrst= sFrst, @sLast= sLast
	select	@idUser= idUser, @iHass= iHash, @bActive= bActive, @tiFails= tiFails, @sFrst= sFrst, @sLast= sLast
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType=	222,	@s=	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

--	if	@bLocked = 1			--	locked-out
	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType=	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType=	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

	if	@iHass <> @iHash		--	wrong pass
	begin
		select	@idLogType=	223,	@s=	@s + ', attempt ' + cast( @tiFails + 1 as varchar )

		begin tran
			if	@tiFails < @tiMaxAtt - 1
				update	tb_User		set	tiFails= tiFails + 1
					where	idUser = @idUser
			else
			begin
--				update	tb_User		set	tiFails= tiFails + 1, bLocked= 1
				update	tb_User		set	tiFails= 0xFF
					where	idUser = @idUser
				select	@s=	@s + ', locked-out'
			end
			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		commit
		return	@idLogType
	end

	select	@idLogType=	221,	@bAdmin=	0
	if	exists(	select 1 from tb_UserRole where idUser = @idUser and idRole = 2 )
		select	@bAdmin=	1

	begin tran
		update	tb_Sess		set	idUser= @idUser
			where	idSess = @idSess
		update	tb_User		set	tiFails= 0, dtLastAct= getdate( )
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Bed designators (790 global configuration)
--	7.05.4976	* .bInUse -> .bActive, tdCfgBed_InUse -> tdCfgBed_Active
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgBed') and name = 'bInUse')
begin
	begin tran
		exec sp_rename 'tbCfgBed.bInUse',	'bActive',			'column'
		exec sp_rename 'tdCfgBed_InUse',	'tdCfgBed_Active',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	User-audit-log and 790-event entry types
--	7.05.5095	+ [204],	* [203]
--	7.05.5066	* [80,81]
--	7.05.5065	+ [206,207]
--	7.05.5045	* [33,38,39,61,62] 'Service' -> 'Component', 'Module' -> 'Component'
--	7.05.5021	+ [247,248]
--	7.05.4980	+ [82]
--	7.05.4975	.tiLevel -> .tiLvl, tiSource -> tiSrc
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_LogType') and name = 'tiLevel')
begin
	begin tran
		exec sp_rename 'tb_LogType.tiLevel',	'tiLvl',		'column'
		exec sp_rename 'tb_LogType.tiSource',	'tiSrc',		'column'
	commit
end
go
begin tran
	if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 82)
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 82,  8, 16, 'Invalid data item' )		--	7.05.4980

	if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 204)
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 204, 1, 16, 'Phone Action' )			--	7.05.5095

	if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 206)
	begin
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 206, 1, 16, 'Presence - In' )			--	7.05.5064
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 207, 1, 16, 'Presence - Out' )		--	7.05.5064
	end

	if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 247)
	begin
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 247, 4, 8, 'Created record' )			--	7.05.5021
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 248, 8, 8, 'Updated record' )			--	7.05.5021
	end

	update	dbo.tb_LogType	set	sLogType= 'Component Stats'		where	idLogType = 33
	update	dbo.tb_LogType	set	sLogType= 'Component Started'	where	idLogType = 38
	update	dbo.tb_LogType	set	sLogType= 'Component Stopped'	where	idLogType = 39
	update	dbo.tb_LogType	set	sLogType= 'Component Installed'	where	idLogType = 61
	update	dbo.tb_LogType	set	sLogType= 'Component Removed'	where	idLogType = 62
	update	dbo.tb_LogType	set	sLogType= 'Connected'			where	idLogType = 80
	update	dbo.tb_LogType	set	sLogType= 'Lost connection'		where	idLogType = 81
	update	dbo.tb_LogType	set	sLogType= 'Invalid data'		where	idLogType = 82		--	7.05.5147
	update	dbo.tb_LogType	set	sLogType= 'Service Clr'			where	idLogType = 203
commit
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
--	7.05.5044	* @idUser: smallint -> int
--	6.05	tb_Log.sLog widened to [512]
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.00
alter proc		dbo.pr_Log_Ins
(
	@idLogType	tinyint
,	@idUser		int
,	@idOper		int
,	@sLog		varchar( 512 )
--,	@idLog		int out
)
	with encryption
as
begin
--	set	nocount	on

	begin tran

		insert	tb_Log	(  idLogType,  idUser,  idOper,  sLog,  dtLog,  dLog,  tLog,  tiHH )
				values	( @idLogType, @idUser, @idOper, @sLog, getdate( ), getdate( ), getdate( ), datepart( hh, getdate( ) ) )
	--	select	@idLog=	scope_identity( )

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns log entries in a page of given size
--	7.05.4975	.tiLevel -> .tiLvl, tiSource -> tiSrc
--	6.05	@tiLvl, @tiSrc take action now
--			+ (nolock)
--	6.04	+ @tiLvl, @tiSrc
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02
alter proc		dbo.pr_Log_Get
(
	@iIndex		int					-- index of the page to show
,	@iCount		int					-- page size (in rows)
,	@iPages		int out				-- total # of pages
,	@tiLvl		tinyint				-- bitwise tb_LogType.tiLvl, 0xFF=include all
,	@tiSrc		tinyint				-- bitwise tb_LogType.tiSrc, 0xFF=include all
)
	with encryption
as
begin
	declare		@idLog		int

	set	nocount	on

	select	@iIndex=	@iIndex * @iCount + 1		-- index of the 1st output row

	if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no filtering
	begin
		select	@iPages=	ceiling( count(*) / @iCount )
			from	tb_Log	with (nolock)

		set	rowcount	@iIndex
		select	@idLog= idLog
			from	tb_Log	with (nolock)
			order	by	idLog desc
	end
	else
	begin
		select	@iPages=	ceiling( count(*) / @iCount )
			from	tb_Log l	with (nolock)
			inner join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			where	t.tiLvl & @tiLvl > 0
				and	t.tiSrc & @tiSrc > 0

		set	rowcount	@iIndex
		select	@idLog= idLog
			from	tb_Log l	with (nolock)
			inner join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			where	t.tiLvl & @tiLvl > 0
				and	t.tiSrc & @tiSrc > 0
			order	by	idLog desc
	end

	set	rowcount	@iCount
	set	nocount	off
	if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no filtering
		select	l.idLog, l.dtLog, l.idLogType, t.sLogType, u.sUser, o.sUser [sOper], l.sLog, t.tiLvl, t.tiSrc
			from	tb_Log l	with (nolock)
			inner join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			left outer join	tb_User u	with (nolock)	on	u.idUser = l.idUser
			left outer join	tb_User o	with (nolock)	on	o.idUser = l.idOper
			where	idLog <= @idLog
			order	by 1 desc
	else
		select	l.idLog, l.dtLog, l.idLogType, t.sLogType, u.sUser, o.sUser [sOper], l.sLog, t.tiLvl, t.tiSrc
			from	tb_Log l	with (nolock)
			inner join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
			left outer join	tb_User u	with (nolock)	on	u.idUser = l.idUser
			left outer join	tb_User o	with (nolock)	on	o.idUser = l.idOper
			where	idLog <= @idLog
				and	t.tiLvl & @tiLvl > 0
				and	t.tiSrc & @tiSrc > 0
			order	by 1 desc

	set	rowcount	0
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
--	7.05.5123	* prUser_sStaff_Upd -> pr_User_sStaff_Upd
--	7.05.5121	+ .sUnits
--	7.05.5029	* .sStaff is required
--	7.05.5021
create proc		dbo.pr_User_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idOper		int out				-- operand user, acted upon
,	@sUser		varchar( 32 )
,	@iHash		int
,	@tiFails	tinyint
,	@sFrst		varchar( 16 )
,	@sMidd		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
--,	@dtLastAct	datetime			-- pr_User_UpdAct
,	@sStaffID	varchar( 16 )
,	@idStfLvl	tinyint
,	@sBarCode	varchar( 32 )
,	@sUnits		varchar( 255 )
,	@bOnDuty	bit
--,	@sStaff		varchar( 16 )		-- automatic
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", i="' + isnull(cast(@sStaffID as varchar), '?') + '", l=' + isnull(cast(@idStfLvl as varchar), '?') +
				', b="' + isnull(cast(@sBarCode as varchar), '?') + '", on=' + isnull(cast(@bOnDuty as varchar), '?') +
				', a=' + cast(@bActive as varchar)
	begin tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			select	@s= 'User_I( ' + @s + ' ) = '

			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff		--,  dtLastAct
							,  sStaffID,  idStfLvl,  sBarCode,  sUnits,  bOnDuty,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '		--, @dtLastAct, @sStaff
							, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @bOnDuty, @bActive )
			select	@idOper=	scope_identity( )

			select	@s= @s + cast(@idOper as varchar)
				,	@k=	237
		end
		else
		begin
			select	@s= 'User_U( ' + @s + ' )'

			update	tb_User	set	sUser= @sUser, iHash= @iHash, tiFails= @tiFails, sFrst= @sFrst
						,	sMidd= @sMidd, sLast= @sLast, sEmail= @sEmail, sDesc= @sDesc	--, dtLastAct= @dtLastAct, sStaff= @sStaff
						,	sStaffID= @sStaffID, idStfLvl= @idStfLvl, sBarCode= @sBarCode, sUnits= @sUnits, bOnDuty= @bOnDuty
						,	bActive= @bActive, dtUpdated= getdate( )
				where	idUser = @idOper

			select	@k=	238
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s
	commit
end
go
grant	execute				on dbo.pr_User_InsUpd				to [rWriter]
grant	execute				on dbo.pr_User_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
--	7.05.5021
create proc		dbo.pr_Role_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idRole		smallint out		-- role, acted upon
,	@sRole		varchar( 16 )
,	@sDesc		varchar( 255 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on

	select	@s= '[' + isnull(cast(@idRole as varchar), '?') + '], n="' + @sRole + '", d=' + isnull(cast(@sDesc as varchar), '?') +
				', a=' + cast(@bActive as varchar)
	begin tran

		if	not exists	(select 1 from tb_Role with (nolock) where idRole = @idRole)
		begin
			select	@s= 'Role_I( ' + @s + ' ) = '

			insert	tb_Role	(  sRole,  sDesc,  bActive )
					values	( @sRole, @sDesc, @bActive )
			select	@idRole=	scope_identity( )

			select	@s= @s + cast(@idRole as varchar)
				,	@k=	242
		end
		else
		begin
			select	@s= 'Role_U( ' + @s + ' )'

			update	tb_Role	set	sRole= @sRole, sDesc= @sDesc, bActive= @bActive, dtUpdated= getdate( )
				where	idRole = @idRole

			select	@k=	243
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s
	commit
end
go
grant	execute				on dbo.pr_Role_InsUpd				to [rWriter]
grant	execute				on dbo.pr_Role_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Option definitions
--	7.05.5095	[5] redefined
--	7.05.5002	+ [18]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 18)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 18,  56, 'Enable remote presence?' )					--	7.05.5002
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 18, 0 )
	end
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 5)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  5,  56, '(internal) IP-address of 1st Gateway' )		--	7.05.5095
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 5, 0 )
	end
	else
	begin
		update	dbo.tb_Option	set	sOption=	'(internal) IP-address of 1st Gateway'	where	idOption = 5
		update	dbo.tb_OptSys	set	iValue=		0	where	idOption = 5
	end
commit
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
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
		inner join	tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin

		begin tran
			update	tb_OptSys	set	iValue= @iValue, fValue= @fValue, tValue= @tValue, sValue= @sValue, dtUpdated= getdate( )
				where	idOption = @idOption	--	and	idUser = @idUser

			if	@idOption = 16	select	@sValue= '************'		--	do not expose SMTP pass

			select	@s= 'OptSys_U [' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s=	@s + ', i=' + isnull(cast(@iValue as varchar), '?')
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

		begin tran
			update	tb_OptUsr	set	iValue= @iValue, fValue= @fValue, tValue= @tValue, sValue= @sValue, dtUpdated= getdate( )
				where	idOption = @idOption	and	idUser = @idUser

	--		if	@idOption = 16	select	@sValue= '************'		--	do not expose SMTP pass

			select	@s= 'OptUsr_U [' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s=	@s + ', i=' + isnull(cast(@iValue as varchar), '?')
			else if	@k = 62		select	@s=	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s=	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s=	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	231, @idUser, null, @s
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	App module User sessions
--	7.05.5059	+ .idModule	(pr_Sess_Ins)
--				* tb_Sess_User -> fk_Sess_User, tb_Sess_LastAct -> td_Sess_LastAct, tb_Sess_Created -> td_Sess_Created
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Sess') and name = 'idModule')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Sess_User')
			exec sp_rename 'dbo.tb_Sess_User',			'fk_Sess_User'
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Sess_LastAct')
			exec sp_rename 'dbo.tb_Sess_LastAct',		'td_Sess_LastAct'
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Sess_Created')
			exec sp_rename 'dbo.tb_Sess_Created',		'td_Sess_Created'

		delete from	dbo.tb_Sess
		--	tb_Sess should be empty at the time of upgrade!!
		alter table	dbo.tb_Sess		add
			idModule	tinyint			not null
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a new session
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
,	@idSess		int out
)
	with encryption
as
begin
	set	nocount	on

	select	@idSess=	idSess
		from	tb_Sess		with (nolock)
		where	sSessID = @sSessID	and	idModule = @idModule	and	sIpAddr = @sIpAddr	and	sBrowser = @sBrowser

---	if	@idSess > 0		return		--	SQL BUG:	return does NOT abort execution immediately as described in docs!!
	if	@idSess is null
	begin
		begin tran

			insert	tb_Sess	(  sSessID,  idModule,  idUser,  sIpAddr,  sMachine,  bLocal,  sBrowser )
					values	( @sSessID, @idModule, @idUser, @sIpAddr, @sMachine, @bLocal, @sBrowser )
			select	@idSess=	scope_identity( )

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Marks a session with latest activity
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
	@sSessID	varchar( 32 )		-- IIS SessionID
,	@idSess		int out
,	@idUser		int out
)
	with encryption
as
begin

	set	nocount	on
	begin tran

		exec	pr_Module_Act	1
		exec	pr_Module_Act	63		-- v.7.03
		exec	pr_Module_Act	92		-- v.7.00

		if	@idSess > 0
			update	tb_Sess		set	dtLastAct= getdate( ), @idUser= idUser
				where	idSess = @idSess
		else
			update	tb_Sess		set	dtLastAct= getdate( ), @idUser= idUser, @idSess= idSess
				where	sSessID = @sSessID

		if	@idUser > 0
			update	tb_User		set	dtLastAct= getdate( )
				where	idUser = @idUser
	commit
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
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
,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
,	@sMachine	varchar( 32 )		-- client computer's name

,	@idUser		int out				-- null if attempt failed
,	@sFrst		varchar( 32 ) out	-- first-name
,	@sLast		varchar( 32 ) out	-- last-name
,	@bAdmin		bit out				-- is user member of built-in Admins role?
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
	declare		@iHass		int
	declare		@bActive	bit
	declare		@bLocked	bit
	declare		@idLogType	tinyint
	declare		@tiFails	tinyint
	declare		@tiMaxAtt	tinyint

	set	nocount	on

	select	@tiMaxAtt= cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 2

	select	@s= '@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

--	select	@idUser= idUser, @iHass= iHash, @bActive= bActive, @bLocked= bLocked, @tiFails= tiFails, @sFrst= sFrst, @sLast= sLast
	select	@idUser= idUser, @iHass= iHash, @bActive= bActive, @tiFails= tiFails, @sFrst= sFrst, @sLast= sLast
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType=	222,	@s=	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

--	if	@bLocked = 1			--	locked-out
	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType=	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType=	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

	if	@iHass <> @iHash		--	wrong pass
	begin
		select	@idLogType=	223,	@s=	@s + ', attempt ' + cast( @tiFails + 1 as varchar )

		begin tran
			if	@tiFails < @tiMaxAtt - 1
				update	tb_User		set	tiFails= tiFails + 1
					where	idUser = @idUser
			else
			begin
--				update	tb_User		set	tiFails= tiFails + 1, bLocked= 1
				update	tb_User		set	tiFails= 0xFF
					where	idUser = @idUser
				select	@s=	@s + ', locked-out'
			end
			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		commit
		return	@idLogType
	end

	select	@idLogType=	221,	@bAdmin=	0
	if	exists(	select 1 from tb_UserRole where idUser = @idUser and idRole = 2 )
		select	@bAdmin=	1

	begin tran
		update	tb_Sess		set	idUser= @idUser
			where	idSess = @idSess
		update	tb_User		set	tiFails= 0, dtLastAct= getdate( )
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
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
,	@idUser		int
,	@sIpAddr	varchar( 40 )
,	@sMachine	varchar( 32 )
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	if	@idUser > 0
	begin
		begin tran
			update	tb_Sess		set	idUser= null
				where	idSess = @idSess

			select	@s= '@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	J790 Command definitions
--	7.05.5095	+ [40,42-44,C2-C5]
if	not	exists	(select 1 from dbo.tbDefCmd where idCmd = 0x40)
begin
	begin tran
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x40, '790 config changed' )					--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x42, '7980 data changed' )					--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x43, 'phone activity' )						--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x44, 'hl7 notification' )					--	7.05.5095

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC2, 'ringback status' )						--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC3, 'exit semi-privacy' )					--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC4, 'advanced diagnostics response' )		--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC5, 'advanced diagnostics request' )		--	7.05.5095
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns [active?] beds, ordered to be loadable into a tree
--	7.05.4976	+ @bActive
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
alter proc		dbo.prCfgBed_GetAll
(
	@bActive	bit					--	0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	tiBed, cBed, cDial, bActive, dtCreated, dtUpdated
		from	dbo.tbCfgBed	with (nolock)
		where	@bActive = 0	or	bActive > 0
end
go
--	----------------------------------------------------------------------------
--	Call-text definitions (historical)
--	7.05.4976	* xuCall_Active_sCall, xuCall_Active_siIdx: depend on .bActive (not .bEnabled)
begin tran
	if	exists	(select 1 from dbo.sysindexes where name='xuCall_Active_sCall')
		drop index	tbCall.xuCall_Active_sCall
	if	exists	(select 1 from dbo.sysindexes where name='xuCall_Active_siIdx')
		drop index	tbCall.xuCall_Active_siIdx

	update	tbCall	set	bActive= 0
		where	sCall	in	(select sCall from tbCall group by sCall having count(*) > 1)
	update	tbCall	set	bActive= 0
		where	siIdx	in	(select siIdx from tbCall group by siIdx having count(*) > 1)

/*		--	7.06.5450	removed: causes dups for following indexes (xuCall_Active_sCall, xuCall_Active_siIdx) in some cases
	update	c	set	bActive= 1
		from	tbCall	c
		join	(select siIdx, max(idCall) [idCall] from tbCall group by siIdx having count(*) > 1)	si	on	si.idCall = c.idCall

/ *		--	7.05.5084	commented, causes extra .bActive to be set, resulting in duplicates -> breaking index creation:
	update	tbCall	set	bActive= 0
		where	sCall	in	(select sCall from tbCall group by sCall having count(*) > 1)
	update	c	set	bActive= 1
		from	tbCall	c
		join	(select sCall, max(idCall) [idCall] from tbCall group by sCall having count(*) > 1)	si	on	si.idCall = c.idCall
*/
	create unique nonclustered index	xuCall_Active_sCall	on	dbo.tbCall ( sCall )	where	bActive > 0
	create unique nonclustered index	xuCall_Active_siIdx	on	dbo.tbCall ( siIdx )	where	bActive > 0
commit
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
--	7.05.5085	+ @bVisible
--	7.04.4913	+ @bEnabled
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefCallP -> tbCfgPri
alter proc		dbo.prCall_GetAll
(
	@bVisible	bit					-- 0=all, 1=only visible shelves
,	@bEnabled	bit					-- 0=any, 1=only enabled for reporting
)
	with encryption
as
begin
--	set	nocount	on
	if	@bVisible > 0
		select	c.idCall, c.bEnabled, c.siIdx, c.sCall, c.tVoTrg, c.tStTrg, p.iColorF, p.iColorB, c.bActive, c.dtCreated, c.dtUpdated
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on	p.sCall = c.sCall	and p.siIdx = c.siIdx
			where	c.bActive > 0	and	p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)
	--		where	c.bActive > 0	and	(p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)		or p.tiSpec between 7 and 9)
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.siIdx	desc
	else
		select	c.idCall, c.bEnabled, c.siIdx, c.sCall, c.tVoTrg, c.tStTrg, p.iColorF, p.iColorB, c.bActive, c.dtCreated, c.dtUpdated
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on	p.sCall = c.sCall	and p.siIdx = c.siIdx
			where	c.bActive > 0	--and	p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.siIdx	desc
end
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.05.5044	* @idUser: smallint -> int
--	7.04.4902
alter proc		dbo.prCall_Upd
(
	@idCall		smallint
,	@bEnabled	bit
,	@tVoTrg		time( 0 )
,	@tStTrg		time( 0 )
,	@idUser		int
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	begin tran
		update	tbCall	set	bEnabled= @bEnabled, tVoTrg= @tVoTrg, tStTrg= @tStTrg, dtUpdated= getdate( )
			where	idCall = @idCall

		select	@s= 'Call_U( ' + isnull(cast(@idCall as varchar), '?') + ', e=' + isnull(cast(@bEnabled as varchar), '?') +
					', v=' + isnull(cast(@tVoTrg as varchar), '?') + ', s=' + isnull(cast(@tStTrg as varchar), '?') + ' )'
		exec	dbo.pr_Log_Ins	72, @idUser, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	Imports call-texts from tbCfgPri
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
	declare		@idCall		smallint
	declare		@idIdx		smallint
	declare		@siIdx		smallint			-- call-index
	declare		@sCall		varchar( 16 )		-- call-text
	declare		@iCount		smallint
	declare		@s			varchar( 255 )

	declare		cur		cursor fast_forward for
		select	min(siIdx), sCall
			from	tbCfgPri	with (nolock)
			where	siIdx > 0	and	tiFlags & 0x02 > 0		-- enabled
			group	by sCall

	set	nocount	on

	select	@iCount=	0

	begin tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall
		while	@@fetch_status = 0
		begin
	--		print	cast(@siIdx as varchar) + ': ' + @sCall
	--		select	@idCall= null, @idIdx= null
			select	@idCall= -1, @idIdx= -1
			select	@idIdx=  idCall		from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0
			select	@idCall= idCall		from	tbCall	with (nolock)	where	sCall = @sCall	and	bActive > 0
--	-		select	@idIdx=  idCall		from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bEnabled > 0
--	-		select	@idCall= idCall		from	tbCall	with (nolock)	where	sCall = @sCall	and	bEnabled > 0
	--		select	@idCall= isnull(@idCall,-1), @idIdx= isnull(@idIdx,-1)
	--		print	' byTxt=' + cast(@idCall as varchar) + ', byIdx=' + cast(@idIdx as varchar)

			if	@idCall < 0	or	@idIdx < 0	or	@idCall <> @idIdx
			begin
				if	@idCall > 0
	--				print	'  mark inactive byTxt ' + cast(@idCall as varchar)
					update	tbCall	set	bActive= 0, dtUpdated= getdate( )	where	idCall = @idCall
--	-				update	tbCall	set	bEnabled= 0, dtUpdated= getdate( )	where	idCall = @idCall
				if	@idIdx > 0
	--				print	'  mark inactive byIdx ' + cast(@idIdx as varchar)
					update	tbCall	set	bActive= 0, dtUpdated= getdate( )	where	idCall = @idIdx
--	-				update	tbCall	set	bEnabled= 0, dtUpdated= getdate( )	where	idCall = @idIdx

	--			print	'  insert new'
				insert	tbCall	(  siIdx,  sCall )
						values	( @siIdx, @sCall )

				select	@iCount=	@iCount + 1
			end

/*			if	exists	(select 1 from dbo.CallPriority where ID = @siIdx)
				update	CallPriority	set	Name= @sCall
					where ID = @siIdx
			else
				insert	CallPriority	(ID, Name, FirstResponderTimer, SecondResponderTimer, ThirdResponderTimer, BackupTimer,
										CustomRouting, PageOverride, IsSpecial, ToneIndex, ToneInterval, BkColorIndex)
					values	( @siIdx, @sCall, '02:00', '02:00', '02:00', '02:00', 0, 0, 0, null, null, null)		
*/
			fetch next from	cur	into	@siIdx, @sCall
		end
		close	cur
		deallocate	cur

		select	@s= 'Call_Imp( ) added ' + cast(@iCount as varchar) + ' rows'
		exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbUnit') and name = 'idShPrv')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnit_PrevShift')
			alter table	dbo.tbUnit	drop constraint	fkUnit_PrevShift

		alter table	dbo.tbUnit	drop column		idShPrv
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates # of shifts for all or given unit(s)
--	7.05.4983
create proc		dbo.prUnit_UpdShifts
(
	@idUnit		smallint		= null	-- null==all
)
	with encryption
as
begin
--	set	nocount	on
	begin tran

		if	@idUnit is null
			update	u	set	u.tiShifts= s.tiShifts
				from	tbUnit	u
				inner join	(select	idUnit, count(*) [tiShifts]	from	tbShift	where	bActive > 0	group	by	idUnit)	s	on	s.idUnit = u.idUnit
		else
			update	tbUnit	set	tiShifts=
							(select	count(*)	from	tbShift	where	bActive > 0	and	idUnit = @idUnit)
				where	idUnit = @idUnit
	commit
end
go
grant	execute				on dbo.prUnit_UpdShifts				to [rWriter]
grant	execute				on dbo.prUnit_UpdShifts				to [rReader]
go
--	----------------------------------------------------------------------------
--	[Creates] #tbUnit and fills it with given idUnit-s
--	7.05.5154
create proc		dbo.prUnit_SetTmpFlt
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit-s, '*' or null=all
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)
*/
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
			select	idUnit, sUnit	--, idShift
				from	tbUnit	with (nolock)
				where	bActive > 0		and		idShift > 0
				and		idUnit in (' + @sUnits + ')'
		exec( @s )
	end
--	select	*	from	#tbUnit
end
go
grant	execute				on dbo.prUnit_SetTmpFlt				to [rWriter]
grant	execute				on dbo.prUnit_SetTmpFlt				to [rReader]
go
--	----------------------------------------------------------------------------
--	User-unit membership
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4919	* tbStfUnit -> tb_UserUnit
--				.idStaff: FK -> tb_User
--	7.04.4897	* tbStaffUnit -> tbStfUnit
--	7.00
create table	dbo.tb_UserUnit
(
	idUser		int				not null
		constraint	fk_UserUnit_User	foreign key references	tb_User
,	idUnit		smallint		not null
		constraint	fk_UserUnit_Unit	foreign key references	tbUnit

,	dtCreated	smalldatetime	not null
		constraint	td_UserUnit_Created	default( getdate( ) )

,	constraint	xp_UserUnit		primary key clustered ( idUser, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tb_UserUnit		to [rWriter]
grant	select							on dbo.tb_UserUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Populates tb_UserUnit for each user/staff based on 7980's .Units [.sBarCode]
--	7.05.5121	* .sBarCode -> .sUnits
--	7.05.5098	* check idUnit
--	7.05.5084	* added check for null on @sUnits
--	7.05.5050
create proc		dbo.pr_UserUnit_Set
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

	begin tran

		open	cur
		fetch next from	cur	into	@id, @sUnits
		while	@@fetch_status = 0
		begin
	--		print	char(10) + cast( @id as varchar )
			if	@sUnits = 'All Units'
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
grant	execute				on dbo.pr_UserUnit_Set				to [rWriter]
grant	execute				on dbo.pr_UserUnit_Set				to [rReader]
go
--	preset unit-access for system accounts
if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5121 order by idVersion desc)
begin
	begin tran
	--	update	dbo.tb_User		set	sBarCode= 'All Units'	where	idUser < 16
		update	dbo.tb_User		set	sUnits= 'All Units'		where	idUser < 16

		exec	pr_UserUnit_Set
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all units, ordered to be loadable into a tree
--	7.05.5043
create proc		dbo.prUnit_GetByUser
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUnit, u.sUnit
		from	tbUnit u	with (nolock)
		inner join	tbCfgLoc l	with (nolock)	on	l.idLoc = u.idUnit
		inner join	tb_UserUnit uu	with (nolock)	on	uu.idUnit = u.idUnit	and	uu.idUser = @idUser
		where	u.bActive > 0
		order	by	u.sUnit
end
go
grant	execute				on dbo.prUnit_GetByUser				to [rWriter]
grant	execute				on dbo.prUnit_GetByUser				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all locations, accesible by a given user, ordered to be loadable into a tree
--	7.05.5043
create proc		dbo.prCfgLoc_GetByUser
(
	@idUser		int
)
	with encryption
as
begin
	set	nocount	on

	create table	#tbLoc						-- no enforcement of FKs
	(
		idLoc		smallint not null			-- unit look-up FK

		primary key nonclustered ( idLoc )
	)

	insert	#tbLoc
		select	idLoc
			from	tbCfgLoc	with (nolock)
			where	tiLvl < 4

	insert	#tbLoc
		select	idLoc
			from	tbCfgLoc cl	with (nolock)
			inner join	tb_UserUnit uu	with (nolock)	on	uu.idUnit = cl.idLoc	and	uu.idUser = @idUser
			where	tiLvl = 4

	set	nocount	off

	select	cl.idLoc, idParent, cLoc, sLoc, tiLvl
	/*	,	case when tiLvl = 0 then 'Facility'
				when tiLvl = 1 then 'System'
				when tiLvl = 2 then 'Building'
				when tiLvl = 3 then 'Floor'
				when tiLvl = 4 then 'Unit'
				when tiLvl = 5 then 'Cvrg Area'	end [sLvl]
		,	dtCreated,	cast(1 as bit) [bActive]
	*/	from	tbCfgLoc cl	with (nolock)
		inner join	#tbLoc l	with (nolock)	on	l.idLoc = cl.idLoc
	---	where	tiLvl < 5		--	everything but coverage areas
		order	by	tiLvl, cl.idLoc
end
go
grant	execute				on dbo.prCfgLoc_GetByUser			to [rWriter]
grant	execute				on dbo.prCfgLoc_GetByUser			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a team
--	7.05.5021
create proc		dbo.prTeam_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idTeam		smallint out		-- team, acted upon
,	@sTeam		varchar( 16 )
,	@sDesc		varchar( 255 )
,	@tResp		time( 0 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on

	select	@s= '[' + isnull(cast(@idTeam as varchar), '?') + '], n="' + @sTeam + '", d=' + isnull(cast(@sDesc as varchar), '?') +
				', t=' + convert(varchar, @tResp, 108) +
				', a=' + cast(@bActive as varchar)		-- + ' ' + convert(varchar, @dtCreated, 20) + ' ' + convert(varchar, @dtUpdated, 20)
	begin tran

		if	not exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			select	@s= 'Team_I( ' + @s + ' ) = '

			insert	tbTeam	(  sTeam,  sDesc,  tResp,  bActive )
					values	( @sTeam, @sDesc, @tResp, @bActive )
			select	@idTeam=	scope_identity( )

			select	@s= @s + cast(@idTeam as varchar)
				,	@k=	247
		end
		else
		begin
			select	@s= 'Team_U( ' + @s + ' )'

			update	tbTeam	set	sTeam= @sTeam, sDesc= @sDesc, tResp= @tResp, bActive= @bActive, dtUpdated= getdate( )
				where	idTeam = @idTeam

			select	@k=	248
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s
	commit
end
go
grant	execute				on dbo.prTeam_InsUpd				to [rWriter]
grant	execute				on dbo.prTeam_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Call priority-team membership
--	7.05.5010	* xpTeamPri -> ( idTeam, siIdx )
--	7.04.4947
create table	dbo.tbTeamPri
(
	idTeam		smallint		not null
		constraint	fkTeamPri_Team	foreign key references tbTeam
,	siIdx		smallint		not null
--	-	constraint	fkTeamPri_Pri		foreign key references tbCfgPri

,	dtCreated	smalldatetime	not null
		constraint	tdTeamPri_Created	default( getdate( ) )

,	constraint	xpTeamPri		primary key clustered ( idTeam, siIdx )
)
go
grant	select, insert,			delete	on dbo.tbTeamPri		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamPri		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts one or deletes one or all team-priority relationship records
--	7.05.5031
create proc		dbo.prTeamPri_InsDel
(
	@bIns		bit				-- 0=Del, 1=Ins
,	@idTeam		smallint
,	@siIdx		smallint= null	-- null=clear
)
	with encryption
as
begin
--	set	nocount	on
	begin tran
		if	@bIns = 0
			delete	from	tbTeamPri
				where	idTeam = @idTeam
				and		(siIdx = @siIdx		or	@siIdx is null)
		else
			if	not	exists	(select 1 from tbTeamPri where idTeam = @idTeam and siIdx = @siIdx)
				insert	tbTeamPri	(  idTeam,  siIdx )
						values		( @idTeam, @siIdx )
	commit
end
go
grant	execute				on dbo.prTeamPri_InsDel				to [rWriter]
grant	execute				on dbo.prTeamPri_InsDel				to [rReader]
go
--	----------------------------------------------------------------------------
--	Call priority-team membership
--	7.05.5010	* xpTeamUnit -> ( idTeam, idUnit )
--	7.04.4947
create table	dbo.tbTeamUnit
(
	idTeam		smallint		not null
		constraint	fkTeamUnit_Team	foreign key references tbTeam
,	idUnit		smallint		not null
		constraint	fkTeamUnit_Unit		foreign key references tbUnit

,	dtCreated	smalldatetime	not null
		constraint	tdTeamUnit_Created	default( getdate( ) )

,	constraint	xpTeamUnit		primary key clustered ( idTeam, idUnit )
)
go
grant	select, insert,			delete	on dbo.tbTeamUnit		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Populates tbTeamUnit for each team based on 7980's .Units [.sDesc]
--	7.05.5058
create proc		dbo.prTeamUnit_Set
	with encryption
as
begin
	declare		@id			int
		,		@i			int
		,		@p			varchar( 3 )
		,		@sUnits		varchar( 32 )
		,		@idUnit		smallint

	declare		cur		cursor fast_forward for
		select	idTeam, sDesc
			from	tbTeam		with (nolock)

	set	nocount	on

	begin tran

		open	cur
		fetch next from	cur	into	@id, @sUnits
		while	@@fetch_status = 0
		begin
	--		print	char(10) + cast( @id as varchar )
			if	@sUnits = 'All Units'
			begin
				delete	from	tbTeamUnit
					where	idTeam = @id
				insert	tbTeamUnit	( idTeam, idUnit )
					select	@id, idUnit
						from	tbUnit
						where	bActive > 0		and		idShift > 0
	--			print	'all units'
			end
			else
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
				if	not	exists	(select 1 from tbTeamUnit where idTeam=@id and idUnit=@idUnit)
					insert	tbTeamUnit	( idTeam, idUnit )
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
grant	execute				on dbo.prTeamUnit_Set				to [rWriter]
grant	execute				on dbo.prTeamUnit_Set				to [rReader]
go
--	import teams
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='wtTeam')
begin
	exec( '
	begin tran
		declare	@idTeam		smallint
			,	@sTeam		varchar( 16 )
			,	@sTimer		varchar( 5 )
			,	@sUnits		varchar( 255 )
			,	@siIdx		smallint
			,	@id			int
			,	@tResp		time( 0 )

		declare	cur		cursor fast_forward for
			select	Name, Timer, Units, siIdx, ID
				from	wtTeam	with (nolock)
				where	siIdx > 0

		open	cur
		fetch next from	cur	into	@sTeam, @sTimer, @sUnits, @siIdx, @id
		while	@@fetch_status = 0
		begin
			if	not	exists( select 1 from tbTeam where sTeam = @sTeam )
			begin
				select	@idTeam= null,	@tResp= cast( ''00:'' + @sTimer as time(0) )
				exec	prTeam_InsUpd	2, @idTeam out, @sTeam, @sUnits, @tResp, 1
				exec	prTeamPri_InsDel	1, @idTeam, @siIdx
				update	wtTeam	set	idTeam= @idTeam		where	ID = @id
			end

			fetch next from	cur	into	@sTeam, @sTimer, @sUnits, @siIdx, @id
		end
		close	cur
		deallocate	cur

		exec	prTeamUnit_Set
	commit' )
end
go
--	----------------------------------------------------------------------------
--	Staff-team membership
--	7.05.5059	* tb_UserTeam -> tbTeamUser
--	7.05.5010	* tbTeamStaff -> tb_UserTeam, .idStaff -> .idUser
--	7.04.4947
create table	dbo.tbTeamUser
(
	idUser		int				not null
		constraint	fkTeamUser_User		foreign key references tb_User
,	idTeam		smallint		not null
		constraint	fkTeamUser_Team		foreign key references tbTeam

,	dtCreated	smalldatetime	not null
		constraint	tdTeamUser_Created	default( getdate( ) )

,	constraint	xpTeamUser		primary key clustered ( idUser, idTeam )
)
go
grant	select, insert,			delete	on dbo.tbTeamUser		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamUser		to [rReader]
go
--	import team-memberships
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='wtDeviceToStaffAssignment')
begin
	exec( '
	begin tran
		declare	@idTeam		smallint
			,	@sTeam		varchar( 16 )
			,	@sUnits		varchar( 255 )
			,	@idUser		int
			,	@id			int
			,	@sTeams		varchar( 32 )
			,	@sStaffID	varchar( 16 )
			,	@i			int
			,	@p			varchar( 3 )

		declare	cur		cursor fast_forward for
			select	StaffID, AssignedTeam
				from	wtDeviceToStaffAssignment	with (nolock)

		open	cur
		fetch next from	cur	into	@sStaffID, @sUnits
		while	@@fetch_status = 0
		begin
			select	@idUser=	idUser	from	tb_User	where	sStaffID = @sStaffID

			delete	from	tbTeamUser
				where	idUser = @idUser
			update	tb_User	set	sTeams= null
				where	idUser = @idUser

			if	len(@sUnits) > 0
			begin
				if	@sUnits = ''All Teams''
				begin
					insert	tbTeamUser	( idUser, idTeam )
						select	@idUser, idTeam
							from	tbTeam
							where	bActive > 0
					select	@sTeams= '',All Teams''
				end
				else
				begin
					select	@i=	0, @sTeams= ''''
		_again:
		--			print	@sUnits
					select	@i=	charindex( '','', @sUnits )
					select	@p= case when @i > 0 then substring( @sUnits, 1, @i - 1 ) else @sUnits end
		--			print	''i='' + cast( @i as varchar ) + '', p='' + @p

					select	@id=	cast( @p as int )
						,	@sUnits=	case when @i > 0 then substring( @sUnits, @i + 1, 32 ) else null end
		--			print	''t='' + cast( @id as varchar )
				
					select	@idTeam= idTeam		from	wtTeam		where	ID = @id
					select	@sTeams= @sTeams + '','' + cast(@idTeam as varchar)

					if	@idTeam > 0		and
						not	exists	(select 1 from tbTeamUser where idUser = @idUser and idTeam=@idTeam)
						insert	tbTeamUser	( idUser, idTeam )
							select	@idUser, @idTeam
					if	@i > 0		goto	_again
				end

				update	tb_User	set	sTeams= substring( @sTeams, 2, 32 )
					where	idUser = @idUser
			end

			fetch next from	cur	into	@sStaffID, @sUnits
		end
		close	cur
		deallocate	cur

	commit' )
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices
--	7.05.5095	* skip .sUnits calculation for gateways
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

,	@idDevice	smallint out		-- output: inserted/updated idDevice	--	6.04
)
	with encryption
as
begin
	declare		@idParent	smallint
		,		@iTrace		int
		,		@s			varchar( 255 )
		,		@idUnit		smallint
		,		@sUnits		varchar( 255 )
	
	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

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

	begin tran

		if	@cDevice <> 'G'											-- calculate .sUnits for non-gateways
		begin
			select	@sUnits=	''

			if	@tiPriCA0 = 0xFF	or	@tiPriCA1 = 0xFF	or	@tiPriCA2 = 0xFF	or	@tiPriCA3 = 0xFF	or
				@tiPriCA4 = 0xFF	or	@tiPriCA5 = 0xFF	or	@tiPriCA6 = 0xFF	or	@tiPriCA7 = 0xFF	or
				@tiAltCA0 = 0xFF	or	@tiAltCA1 = 0xFF	or	@tiAltCA2 = 0xFF	or	@tiAltCA3 = 0xFF	or
				@tiAltCA4 = 0xFF	or	@tiAltCA5 = 0xFF	or	@tiAltCA6 = 0xFF	or	@tiAltCA7 = 0xFF
			begin
				declare		cur		cursor fast_forward for
					select	idLoc
						from	tbCfgLoc	with (nolock)
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

				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA0
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA1
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA2
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA3
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA4
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA5
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA6
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiPriCA7

				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA0
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA1
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA2
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA3
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA4
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA5
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA6
				insert	#tbUnit		select	idParent	from	tbCfgLoc	with (nolock)	where	idLoc = @tiAltCA7

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
		end

		if	@idDevice is null
		begin
			if	@cDevice = 'R'
				select	@idUnit= idParent							-- set room's current unit to primary CA's
					from	tbCfgLoc	with (nolock)
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

			if	@sCodeVer is not null																		-- retain previous values
				update	tbDevice	set		sCodeVer= @sCodeVer
					where	idDevice = @idDevice

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
--	Finds devices and inserts if necessary (not found)
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
	declare		@idParent	smallint
		,		@iTrace		int
		,		@s			varchar( 255 )
		,		@bActive	bit

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s=	'Dvc_I( s=' + @cSys + ', g=' + cast(@tiGID as varchar) + ', j=' + cast(@tiJID as varchar) + ', r=' + cast(@tiRID as varchar) +
				', aid=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') + ', c=' + isnull(@cDevice,'?') +
				', n=' + isnull(@sDevice,'?') + ', d=' + isnull(@sDial,'?') + ' )'

	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7967-P workflow station's (0x1A) 'phantom' RIDs		--	7.03
	begin
		select	@sDial=		null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype=	26			---	?? mark 'phantom' RID as workflow
		select	@idDevice=	idDevice, @bActive=	bActive
			from	tbDevice	with (nolock)
			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	--and	bActive > 0
		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice
			return	0
		end
	end

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID = 0
		select	@iAID=	null
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.04.4969
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	cDevice = 'M'	and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID > 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	bActive > 0
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

	if	@idDevice is null	and	len( @sDevice ) > 0
	begin
		if	@tiRID > 0						-- R-bus device
			select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
		if	@tiJID > 0	and	@tiRID = 0		-- J-bus device
			select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	bActive > 0

		begin	tran
			insert	tbDevice	(  idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial )
			select	@idDevice=	scope_identity( )

			if	@iTrace & 0x04 > 0
			begin
				select	@s=	@s + '  id=' + cast(@idDevice as varchar) + ', p=' + isnull(cast(@idParent as varchar),'?')
				exec	pr_Log_Ins	74, null, null, @s
			end
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Returns buttons [and corresponding devices], associated with presence (in a given room)
--	7.05.4990
create proc		dbo.prCfgDvc_GetBtns
(
	@idRoom		smallint			-- device (PK)
)
	with encryption
as
begin
--	set	nocount	off
select	b.idDevice, d.sQnDevice, d.tiRID, b.tiBtn, p.tiSpec		--, d.tiGID, d.tiJID
	from	dbo.tbCfgDvcBtn	b	with (nolock)
		inner join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx = b.siPri	and	p.tiSpec in (7,8,9)
		inner join	dbo.vwDevice	d	with (nolock)	on	d.idDevice = b.idDevice		and	d.bActive > 0
	where	d.idParent = @idRoom
	order	by	2
end
go
grant	execute				on dbo.prCfgDvc_GetBtns				to [rReader]
grant	execute				on dbo.prCfgDvc_GetBtns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Staff definitions
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
select	idUser, sStaffID, sFrst, sMidd, sLast, s.idStfLvl, l.sStfLvl, l.iColorB, sBarCode
	,	sStaff, l.sStfLvl + ' (' + cast(sStaffID as varchar) + ') ' + sStaff [sFqStaff]
	,	s.sUnits, bOnDuty, s.sTeams,	s.idRoom
	,	bActive, dtCreated, dtUpdated
	from	tb_User	s	with (nolock)
		inner join	tbStfLvl	l	with (nolock)	on	l.idStfLvl = s.idStfLvl
	where	s.idStfLvl is not null				--	only 'staff' users
go
--	----------------------------------------------------------------------------
--	Returns [active?] staff, ordered to be loadable into a table
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
	select	idUser, cast(1 as bit) [bEnabled], sStaffID, sStaff, sStfLvl, iColorB
		from	vwStaff	with (nolock)
		where	@bActive = 0	or	bActive > 0
		order	by	idStfLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	Staff device definitions (Badge/Pager/Phone)
--	7.05.5121	+ .sUnits
--	7.05.5085	- xuDvc_Active	- no need to enforce unique description
--	7.05.5074	+ xuDvc_TypeDial
--	7.05.5050	ID seed -> 16777216 (0x01000000)
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--					xpStfDvc -> xpDvc, fkStfDvc_Type -> fkDvc_Type, tdStfDvc_Flags -> tdDvc_Flags, fkStfDvc_Staff -> fkDvc_User
--					tdStfDvc_Active -> tdDvc_Active, tdStfDvc_Created -> tdDvc_Created, tdStfDvc_Updated -> tdDvc_Updated
--					xuStfDvc_Active -> xuDvc_Active
--				- revoke alter - not necessary for 'insert identity on'! (exec proc with owner permissions)
if	not	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvc')
exec( 'create table	dbo.tbDvc
	(
		idDvc		int				not null	identity( 16777216, 1 )	--	1..16777215 [65535] are reserved for RTLS badges - 24 bits [16]
			constraint	xpDvc	primary key clustered

	,	idDvcType	tinyint			not null	-- device type
			constraint	fkDvc_Type	foreign key references	tbDvcType
	,	sDvc		varchar( 16 )	not null	-- full name
	,	sBarCode	varchar( 32 )	null		-- bar-code

	,	sDial		varchar( 16 )	null		-- dialable number (digits only), null for badges
	--,	tiLines		tinyint			null		-- lines per message
	--,	tiChars		tinyint			null		-- characters per line
	--,	idTeam		smallint		null		-- responder team
	--		constraint	fkStfDvc_Team	foreign key references	tbStfTeam
	,	tiFlags		tinyint			not null	-- 1=group, 2=tech
			constraint	tdDvc_Flags		default( 0 )
	,	idUser		int				null		-- live: who is this device currently assigned to?
			constraint	fkDvc_User	foreign key references	tb_User
	,	sUnits		varchar( 255 )	null		-- tmp: units

	,	bActive		bit				not null	-- currently active?
			constraint	tdDvc_Active	default( 1 )
	,	dtCreated	smalldatetime	not null
			constraint	tdDvc_Created	default( getdate( ) )
	,	dtUpdated	smalldatetime	not null
			constraint	tdDvc_Updated	default( getdate( ) )

	,	constraint	tvDvc_Dial	check ( idDvcType = 1 and sDial is null		or	sDial is not null )
	)
---	create unique nonclustered index	xuDvc_Active		on dbo.tbDvc ( sDvc )		where bActive > 0
	create unique nonclustered index	xuDvc_TypeDial		on dbo.tbDvc ( idDvcType, sDial )	where sDial is not null

	grant	select, insert, update			on dbo.tbDvc			to [rWriter]
	grant	select							on dbo.tbDvc			to [rReader]
' )
go
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='tvDvc_Dial')
begin
	begin tran
		alter table	dbo.tbDvc	add
			constraint	tvDvc_Dial	check ( idDvcType = 1 and sDial is null		or	sDial is not null )
	commit
end
go
if	not	exists	(select 1 from dbo.sysindexes where name='xuDvc_TypeDial')
begin
	begin tran
		create unique nonclustered index	xuDvc_TypeDial		on dbo.tbDvc ( idDvcType, sDial )	where idDvcType > 1
	commit
end
go
if	exists	(select 1 from dbo.sysindexes where name='xuDvc_Active')
	drop index	tbDvc.xuDvc_Active
go
--	populate tbDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvc')
begin
	begin tran
		set identity_insert	dbo.tbDvc	on

		insert	tbDvc	( idDvc, idDvcType, sDvc, sDial, tiFlags, idUser, bActive, dtCreated, dtUpdated )
				select	idStfDvc, idDvcType, sStfDvc, sDial, tiFlags, idStaff, bActive, dtCreated, dtUpdated
					from	tbStfDvc

		set identity_insert	dbo.tbDvc	off

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRtlsBadge_StaffDvc')
			alter table	dbo.tbRtlsBadge		drop	constraint	fkRtlsBadge_StaffDvc

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRtlsBadge_StfDvc')
			alter table	dbo.tbRtlsBadge		drop	constraint	fkRtlsBadge_StfDvc

		alter table	dbo.tbRtlsBadge		add
			constraint	fkRtlsBadge_Dvc	foreign key (idBadge) references tbDvc

		if	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbStfDvc') and name='sBarCode')
			exec( 'update	d	set	d.sBarCode= sd.sBarCode
				from	tbDvc	d
				join	tbStfDvc	sd	on	sd.idStfDvc = d.idDvc' )

		drop table	tbStfDvc
	commit
end
go
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDvc') and name = 'sUnits')
begin
	begin tran
		alter table		dbo.tbDvc		add
			sUnits		varchar( 255 )	null		-- tmp: units
		exec( 'update	dbo.tbDvc	set	sUnits= sBarCode
				update	dbo.tbDvc	set	sBarCode= null'
			)
	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5154	+ staff fields
--	7.05.5121	+ .sUnits
--	7.05.5095
create view		dbo.vwDvc
	with encryption
as
select	d.idDvc, d.idDvcType, t.sDvcType, d.sDial, d.sDvc, d.sBarCode, d.tiFlags, d.sUnits
	,	t.sDvcType + ' #' + d.sDial		[sFqDvc]
	,	d.idUser, u.idStfLvl, u.sStfLvl, u.sStaffID, u.sStaff, u.sFqStaff, u.bOnDuty
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDvc		d	with (nolock)
	join	tbDvcType	t	with (nolock)	on	t.idDvcType = d.idDvcType
	left join	vwStaff	u	with (nolock)	on	u.idUser = d.idUser
go
grant	select							on dbo.vwDvc			to [rWriter]
grant	select							on dbo.vwDvc			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a device
--	7.05.5121	+ .sUnits
--	7.05.5021
create proc		dbo.prDvc_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idDvc		int out				-- device, acted upon
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sBarCode	varchar( 32 )
,	@sDial		varchar( 16 )
,	@tiFlags	tinyint
--,	@idUser		int					-- prDvc_UpdUsr
,	@sUnits		varchar( 255 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on

	select	@s= '[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', n="' + @sDvc + '", b=' + isnull(cast(@sBarCode as varchar), '?') +
				', d=' + isnull(cast(@sDial as varchar), '?') + ', f=' + cast(@tiFlags as varchar) +
				', a=' + cast(@bActive as varchar)
	begin tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			select	@s= 'Dvc_I( ' + @s + ' ) = '

			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  sUnits,  bActive )
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @bActive )
			select	@idDvc=		scope_identity( )

			select	@s= @s + cast(@idDvc as varchar)
				,	@k=	247
		end
		else
		begin
			select	@s= 'Dvc_U( ' + @s + ' )'

			update	tbDvc	set	idDvcType= @idDvcType, sDvc= @sDvc, sBarCode= @sBarCode, sDial= @sDial
						,	tiFlags= @tiFlags, sUnits= @sUnits, bActive= @bActive, dtUpdated= getdate( )
				where	idDvc = @idDvc

			select	@k=	248
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s
	commit
end
go
grant	execute				on dbo.prDvc_InsUpd					to [rWriter]
grant	execute				on dbo.prDvc_InsUpd					to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given device's staff
--	7.05.5010	* prStfDvc_UpdStf -> prDvc_UpdUsr
--				* idStfDvc -> idDvc, .idStaff -> .idUser, @idStaff -> @idUser
--	7.04.4897	* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.03
create proc		dbo.prDvc_UpdUsr
(
	@idDvc		int							-- badge id
,	@idUser		int							-- who is this device currently assigned to?
)
	with encryption
as
begin
--	set	nocount	on
	begin tran
		update	tbDvc	set idUser= @idUser,	dtUpdated= getdate( )
			where	idDvc = @idDvc
	commit
end
go
grant	execute				on dbo.prDvc_UpdUsr					to [rWriter]
grant	execute				on dbo.prDvc_UpdUsr					to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all devices
--	7.05.5121	+ .sUnits
--	7.05.5099
create proc		dbo.prDvc_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sBarCode, sDial, tiFlags, idUser, sUnits, bActive, dtCreated, dtUpdated
		from	tbDvc		with (nolock)
	--	where	idDvc >= 0x01000000
		order	by	idDvc
end
go
grant	execute				on dbo.prDvc_Exp					to [rWriter]
grant	execute				on dbo.prDvc_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a device
--	7.05.5121	+ .sUnits
--	7.05.5099
create proc		dbo.prDvc_Imp
(
	@idDvc		int
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sBarCode	varchar( 32 )
,	@sDial		varchar( 16 )
,	@tiFlags	tinyint				-- bitwise: 1=group, 2=tech
,	@idUser		int
,	@sUnits		varchar( 255 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin tran

		if	not	exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			set identity_insert	dbo.tbDvc	on

			insert	tbDvc	(  idDvc,  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  idUser,  sUnits,  bActive,  dtCreated,  dtUpdated )
					values	( @idDvc, @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @idUser, @sUnits, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbDvc	off
		end
		else
			update	tbDvc	set	idDvcType= @idDvcType, sDvc= @sDvc, sBarCode= @sBarCode, sDial= @sDial, tiFlags= @tiFlags
						,	idUser= @idUser, sUnits= @sUnits, bActive= @bActive, dtUpdated= @dtUpdated
				where	idDvc = @idDvc

	commit
end
go
grant	execute				on dbo.prDvc_Imp					to [rWriter]
--grant	execute				on dbo.prDvc_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	StaffDvc-Unit membership
--	7.05.5010	* tbStfDvcUnit -> tbDvcUnit,	xpStfDvcUnit -> xpDvcUnit, fkStfDvcUnit_StfDvc -> fkDvcUnit_Dvc, fkStfDvcUnit_Unit -> fkDvcUnit_Unit, tdStfDvcUnit_Created -> tdDvcUnit_Created
--	7.04.4897	* tbStaffDvcUnit -> tbStfDvcUnit, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.00
create table	dbo.tbDvcUnit
(
	idDvc		int				not null
		constraint	fkDvcUnit_Dvc	foreign key references tbDvc
,	idUnit		smallint		not null
		constraint	fkDvcUnit_Unit	foreign key references tbUnit

,	dtCreated	smalldatetime	not null
		constraint	tdDvcUnit_Created	default( getdate( ) )

,	constraint	xpDvcUnit	primary key clustered ( idDvc, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tbDvcUnit		to [rWriter]
grant	select, insert, delete			on dbo.tbDvcUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	StaffDvc-Team membership
--	7.05.5059
create table	dbo.tbDvcTeam
(
	idDvc		int				not null
		constraint	fkDvcTeam_Dvc		foreign key references tbDvc
,	idTeam		smallint		not null
		constraint	fkDvcTeam_Team		foreign key references tbTeam

,	dtCreated	smalldatetime	not null
		constraint	tdDvcTeam_Created	default( getdate( ) )

,	constraint	xpDvcTeam		primary key clustered ( idDvc, idTeam )
)
go
grant	select, insert,			delete	on dbo.tbDvcTeam		to [rWriter]
grant	select, insert, 		delete	on dbo.tbDvcTeam		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active staff, ordered to be loadable into a dropdown
--	7.05.5064	+ .idDvcType = 1
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4953
alter proc		dbo.prStaff_LstAct
	with encryption
as
begin
	select	s.idUser, s.sFqStaff + case
				when b.lCount = 1 then ' -- [' + cast(b.idDvc as varchar) + ']'
	--			when b.lCount > 1 then ' -- ' + cast(b.lCount as varchar) + ' badges'
				when b.lCount > 1 then ' -- [' + cast(b.idDvc as varchar) + '], +' + cast(b.lCount-1 as varchar)
				else '' end		[sFqStaff]
		,	s.iColorB
		from	vwStaff	s	with (nolock)
		left outer join	(select	idUser, count(*) [lCount], min(idDvc) [idDvc]	from	tbDvc	with (nolock)	where	idDvcType = 1	group by idUser) b	on	b.idUser = s.idUser
		where	bActive > 0
		order	by	idStfLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	Devices
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
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2) + '-' + right('0' + cast(tiRID as varchar), 2)	[sSGJR]
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		[sSGJ]
	,	'[' + cDevice + '] ' + sDevice		[sQnDevice]
--	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	[sFnDevice]
	,	r.idEvent,	r.tiSvc,	r.idRn, r.sRn,	r.idCn, r.sCn,	r.idAi, r.sAi
	,	bActive, dtCreated, d.dtUpdated
	from	tbDevice	d	with (nolock)
	left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms'
--	7.05.5154	+ .idRegN, .idRegLvlN, .sRegIDN, .sRegN, .bRegDutyN
--	7.05.5095	* d.dtUpdated -> r.dtUpdated
--				- .sFnDevice
--	7.04.4892	* vwRoomAct -> vwRoom,	match output to vwDevice
--	7.03		vwRoom -> vwRoomAct
alter view		dbo.vwRoom
	with encryption
as
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, d.sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2) + '-' + right('0' + cast(tiRID as varchar), 2)	[sSGJR]
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		[sSGJ]
	,	'[' + cDevice + '] ' + sDevice		[sQnDevice]
--	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	[sFnDevice]
	,	r.idEvent,	r.tiSvc
	,	r.idRn [idReg4], rn.idStfLvl [idRegLvl4], rn.sStaffID [sRegID4], rn.sStaff [sReg4], rn.bOnDuty [bRegDuty4]		--, r.sRn
	,	r.idCn [idReg2], cn.idStfLvl [idRegLvl2], cn.sStaffID [sRegID2], cn.sStaff [sReg2], cn.bOnDuty [bRegDuty2]		--, r.sCn
	,	r.idAi [idReg1], ai.idStfLvl [idRegLvl1], ai.sStaffID [sRegID1], ai.sStaff [sReg1], ai.bOnDuty [bRegDuty1]		--, r.sAi
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	tbDevice	d	with (nolock)
	join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
	left join	vwStaff		rn	with (nolock)	on	rn.idUser = r.idRn
	left join	vwStaff		cn	with (nolock)	on	cn.idUser = r.idCn
	left join	vwStaff		ai	with (nolock)	on	ai.idUser = r.idAi
go
--	----------------------------------------------------------------------------
--	Returns available staff for given unit(s)
--	7.05.5154
create proc		dbo.prStaff_GetByUnit
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit's, '*' or null=all
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
	select	st.idUser, st.idStfLvl, st.sStaffID, st.sStaff, st.bOnDuty
		,	st.idRoom,	r.sQnDevice	[sQnRoom]
	--	,	st.sStfLvl, st.iColorB, st.sFqStaff, st.sUnits, st.sTeams
	--	,	st.bActive, st.dtCreated, st.dtUpdated
		,	pg.idDvc	[idPager],	pg.sDial	[sPager]
		,	ph.idDvc	[idPhone],	ph.sDial	[sPhone]
	--	,	bd.idDvc	[idBadge]	--,	bd.sDial	[sBadge]
		from	vwStaff	st	with (nolock)
		left join	vwRoom	r	with (nolock)	on	r.idDevice = st.idRoom
	--	left join	tbDvc	bd	with (nolock)	on	bd.idUser = st.idUser	and	bd.idDvcType = 1	and	bd.bActive > 0
		left join	tbDvc	pg	with (nolock)	on	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
		left join	tbDvc	ph	with (nolock)	on	ph.idUser = st.idUser	and	ph.idDvcType = 3	and	ph.bActive > 0
		where	st.bActive > 0
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@bOnDuty is null	or	st.bOnDuty = @bOnDuty)
		and		st.idUser in (select	idUser
			from	tb_UserUnit	uu	with (nolock)
			join	#tbUnit		u	with (nolock)	on	u.idUnit = uu.idUnit)
		order	by	st.sStaffID
end
go
grant	execute				on dbo.prStaff_GetByUnit			to [rWriter]
grant	execute				on dbo.prStaff_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	System activity log
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
select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, dtEvent, dEvent, tEvent, tiHH
	,	idCmd, tiBtn,	e.idRoom, r.sDevice [sRoom], e.tiBed, b.cBed, e.idUnit
--	,	e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID	--, sd.sDial [sSrcDial]	--, sd.sQnDevice [sSrcQn], sd.sFnDevice [sSrcFn]
	,	e.idSrcDvc, sd.sSGJR [sSrcSGJR], sd.cDevice [cSrcDvc], sd.sDevice [sSrcDvc]
--	,	e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID	--, dd.sDial [sDstDial]	--, dd.sQnDevice [sDstQn], dd.sFnDevice [sDstFn]
	,	e.idDstDvc, dd.sSGJR [sDstSGJR], dd.cDevice [cDstDvc], dd.sDevice [sDstDvc]
	,	e.idLogType, et.sLogType, e.idCall, c.sCall, sInfo
	from		tbEvent		e	with (nolock)
	left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
	left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
	left join	tb_LogType	et	with (nolock)	on	et.idLogType = e.idLogType
	left join	vwDevice	sd	with (nolock)	on	sd.idDevice = e.idSrcDvc
	left join	vwDevice	dd	with (nolock)	on	dd.idDevice = e.idDstDvc
	left join	tbDevice	r	with (nolock)	on	r.idDevice = e.idRoom
go
--	----------------------------------------------------------------------------
--	Returns indication whether given master should visualize a call from given coverage areas
--	7.05.5070	* > 0 -> <> 0	- signed operands produce signed result
--	7.03
alter function		dbo.fnEventA_GetByMaster
(
	@idMaster	smallint			-- master look-up FK
,	@cSys		char( 1 )			-- origin's system ID
,	@tiGID		tinyint				-- origin's G-ID - gateway
,	@tiJID		tinyint				-- origin's J-ID - J-bus
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

	if	exists	(select 1 from tbDevice with (nolock) where cSys=@cSys and tiGID=@tiGID and tiJID=@tiJID and tiRID=0 and bActive >0	and	idDevice=@idMaster)	--	and cDevice='M'
		return	0											--	suppress calls placed by the master itself (or its child phantom devices - workflow)

	select	@bResult=	0

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
--	System activity log: call events
--	7.05.5065	+ .idUser
--	7.05.4976	* .cBed -> .tiBed,		- .idEvtRn, .tRn, .idEvtCn, .tCn, .idEvtAi, .tAi
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'tiBed')
begin
	begin tran
		alter table	dbo.tbEvent_C	add
			tiBed		tinyint			null		-- bed index
	commit
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'tiBed')		and
	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'cBed')
	exec( 'update	c	set	c.tiBed= b.tiBed
			from	tbEvent_C	c
			join	tbCfgBed	b	on	b.cBed = c.cBed'
	)
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'cBed')
begin
	exec( '
		alter table	dbo.tbEvent_C	drop	constraint	fkEventC_Event_Rn
		alter table	dbo.tbEvent_C	drop	constraint	fkEventC_Event_Cna
		alter table	dbo.tbEvent_C	drop	constraint	fkEventC_Event_Aide

		alter table	dbo.tbEvent_C	drop	column		idEvtRn
		alter table	dbo.tbEvent_C	drop	column		idEvtCn
		alter table	dbo.tbEvent_C	drop	column		idEvtAi
		alter table	dbo.tbEvent_C	drop	column		tRn
		alter table	dbo.tbEvent_C	drop	column		tCn
		alter table	dbo.tbEvent_C	drop	column		tAi
		alter table	dbo.tbEvent_C	drop	column		cBed
	' )
end
go
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'idUser')
begin
	begin tran
		alter table	dbo.tbEvent_C	add
			idUser		int				null		-- staff (for registration events)
				constraint	fkEventC_User		foreign key references	tb_User
	commit
end
go
--	fix prEvent84_Ins .5066 bug
--	<100,tbEvent_C>
begin tran
	update	ec	set	idUser= null
		from	dbo.tbEvent_C	ec
		join	dbo.tbEvent		e	on	e.idEvent = ec.idEvent
		join	dbo.tbCall		c	on	c.idCall = e.idCall
		join	dbo.tbCfgPri	p	on	p.siIdx = c.siIdx
		where	p.tiSpec not in ( 7, 8, 9 )
commit
go
--	----------------------------------------------------------------------------
--	7.05.5065	+ .idUser
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
select	ec.idEvent, ec.dEvent, ec.tEvent, ec.tiHH, ec.idCall, c.sCall
	,	ec.idRoom, d.cDevice, d.sDevice, d.sDial, ec.idUnit, u.sUnit
	,	ec.tiBed, b.cBed, ec.idEvtVo, ec.tVoice, ec.idEvtSt, ec.tStaff
	,	ec.idUser, s.sStaff
--	,	ec.idEvtRn, ec.tRn, ec.idEvtCn, ec.tCn, ec.idEvtAi, ec.tAi
	from		tbEvent_C	ec	with (nolock)
	join		tbCall		c	with (nolock)	on	c.idCall = ec.idCall
	join		tbUnit		u	with (nolock)	on	u.idUnit = ec.idUnit
	join		tbDevice	d	with (nolock)	on	d.idDevice = ec.idRoom
	left join	tbCfgBed	b	with (nolock)	on	b.tiBed = ec.tiBed
	left join	tb_User		s	with (nolock)	on	s.idUser = ec.idUser
go
--	----------------------------------------------------------------------------
--	7.05.5079	+ on delete set null to fkPatient_RoomBed
begin
	begin tran
		alter table tbPatient drop constraint fkPatient_RoomBed
		alter table tbPatient add
			constraint	fkPatient_RoomBed	foreign key	( idRoom, tiBed )	references tbRoomBed	on delete set null
	commit
end
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
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
	declare		@s			varchar( 255 )
--	declare		@idDoctor	int
	declare		@idDoc		int
	declare		@cGen		char( 1 )
	declare		@sInf		varchar( 32 )
--	declare		@sNot		varchar( 255 )

	set	nocount	on

	if	@cGender is null
		select	@cGender=	'U'

	if	len( @sPatient ) > 0
	begin
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

		select	@idPatient= idPatient,	@cGen= cGender, @sInf= sInfo, @idDoc= idDoctor	--, @sNot= sNote
			from	tbPatient	with (nolock)
			where	sPatient = @sPatient	and	bActive > 0

		begin tran
			if	@idPatient is null
			begin
		--		if	@cGender is null							--	7.03	no point: already 'U' above
		--			select	@cGender=	substring( @sPatient, len(@sPatient), 1 )

				insert	tbPatient	(  sPatient,  cGender,  sInfo,  idDoctor )	--,  sNote
						values		( @sPatient, @cGender, @sInfo, @idDoctor )	--, @sNote
				select	@idPatient=	scope_identity( )

				select	@s=	'Pat_I( p=' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
		--					', n=' + isnull(@sNote,'?') +
							', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] )  id=' + cast(@idPatient as varchar)
				exec	pr_Log_Ins	44, null, null, @s
			end
			else
			begin
				select	@s=	''
				if	@cGen <> @cGender	select	@s=	@s + ', g=' + isnull(@cGender,'?')
				if	@sInf <> @sInfo		select	@s=	@s + ', i=' + isnull(@sInfo,'?')
		--		if	@sNot <> @sNote		select	@s=	@s + ', n=' + isnull(@sNote,'?')
				if	@idDoc <> @idDoctor	select	@s=	@s + ', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] ' + isnull(@sDoctor,'?')
				if	len(@s) > 0
				begin
					update	tbPatient	set	cGender= @cGender, sInfo= @sInfo, idDoctor= @idDoctor, dtUpdated= getdate( )	--, sNote= @sNote
						where	idPatient = @idPatient

					select	@s=	'Pat_U( [' + cast(@idPatient as varchar) + '] ' + isnull(@sPatient,'?') + @s + ' )'
					exec	pr_Log_Ins	44, null, null, @s
				end

		--		select	@s=	'Pat_U( [' + cast(@idPatient as varchar) + '] ' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
		--					', n=' + isnull(@sNote,'?') + ', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] ' + isnull(@sDoctor,'?') + ' )'
		--		exec	pr_Log_Ins	44, null, null, @s
			end
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed
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
	@idPatient	int
,	@cSys		char( 1 )
,	@tiGID		tinyint
,	@tiJID		tinyint
,	@tiRID		tinyint
,	@tiBed		tinyint
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idRoom		smallint
		,		@idCurr		smallint
		,		@tiCurr		tinyint
		,		@sPatient	varchar( 16 )
		,		@sDevice	varchar( 16 )

	set	nocount	on
	set	xact_abort	on

	select	@idRoom= idDevice,	@sDevice= sDevice
		from	vwRoom	with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	bActive > 0		--	and	tiRID = @tiRID

	select	@sPatient= sPatient
		from	tbPatient	with (nolock)
		where	idPatient = @idPatient

	if	(@tiBed = 0	or	@tiBed is null)
		and	exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
		select	@tiBed=	0xFF			--	auto-correct for no-bed rooms from bed 0

	if	not exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
	begin								-- log invalid bed-index
		begin
			select	@s=	'Pat_UL( [' + isnull(cast(@idPatient as varchar),'?') + '] ' + isnull(@sPatient,'?') +
						', ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
						right('0' + isnull(cast(@tiJID as varchar),'?'), 2) +	-- '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
						', [' + isnull(cast(@idRoom as varchar),'?') + '] ' + isnull(@sDevice,'?') +
						', b=' + isnull(cast(@tiBed as varchar),'?') + ' ): bed-idx'
			exec	pr_Log_Ins	82, null, null, @s

			begin tran

				--	bump this patient from his last given room-bed
				update	tbPatient	set	dtUpdated= getdate( ),	idRoom= null, tiBed= null
					where	idPatient = @idPatient

				update	tbRoomBed	set	dtUpdated= getdate( ),	idPatient= null
					where	idPatient = @idPatient

			commit

			return	-1
		end
	end

	if	@idPatient > 0
	begin
		select	@idCurr= idRoom, @tiCurr= tiBed
			from	tbPatient	with (nolock)
			where	idPatient = @idPatient

		if	@idRoom <> @idCurr	or	@tiBed <> @tiCurr		--	has moved?
			or	@idRoom is null	and	@idCurr > 0
			or	@idRoom > 0		and	@idCurr is null
	--	-	or	@tiBed is null	and	@tiCurr > 0				--	7.05.5147
	--	-	or	@tiBed > 0		and	@tiCurr is null			--		room-level calls shouldn't move patient
		begin
			begin	tran

				--	bump any other patient from the given room-bed
				update	tbPatient	set	dtUpdated= getdate( ),	idRoom= null, tiBed= null
					where	idRoom = @idRoom	and	tiBed = @tiBed	and	idPatient <> @idPatient

				--	record the given patient into the given room-bed
				update	tbPatient	set	dtUpdated= getdate( ),	idRoom= @idRoom, tiBed= @tiBed
					where	idPatient = @idPatient

				--	update the given room-bed with the given patient
				update	tbRoomBed	set	dtUpdated= getdate( ),	idPatient= @idPatient
					where	idRoom = @idRoom	and	tiBed = @tiBed

			commit
		end
	end
	else		--	if	@idPatient is null
	begin
		begin tran

			--	bump any patient from the given room-bed
			update	tbPatient	set	dtUpdated= getdate( ),	idRoom= null, tiBed= null
				where	idRoom = @idRoom	and	tiBed = @tiBed	and	idPatient > 0

			--	update the given room-bed with no patient
			update	tbRoomBed	set	dtUpdated= getdate( ),	idPatient= null
				where	idRoom = @idRoom	and	tiBed = @tiBed

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
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
select	r.idUnit,	rb.idRoom, d.sDevice [sRoom], d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, rb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	p.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idAssn1, a1.idStfLvl [idStLvl1], a1.sStaffID [sAssnID1], a1.sStaff [sAssn1], a1.bOnDuty [bOnDuty1]		--, a1.sStaffLvl [sStLvl1], a1.iColorB [iColorB1]
	,	rb.idAssn2, a2.idStfLvl [idStLvl2], a2.sStaffID [sAssnID2], a2.sStaff [sAssn2], a2.bOnDuty [bOnDuty2]		--, a2.sStaffLvl [sStLvl2], a2.iColorB [iColorB2]
	,	rb.idAssn3, a3.idStfLvl [idStLvl3], a3.sStaffID [sAssnID3], a3.sStaff [sAssn3], a3.bOnDuty [bOnDuty3]		--, a3.sStaffLvl [sStLvl3], a3.iColorB [iColorB3]
	,	r.idRn [idRegRn], r.sRn [sRegRn]
	,	r.idCn [idRegCn], r.sCn [sRegCn]
	,	r.idAi [idRegAi], r.sAi [sRegAi]
	,	rb.dtUpdated
	from	tbRoomBed	rb	with (nolock)
	join	tbDevice	d	with (nolock)	on	d.idDevice = rb.idRoom		and	d.bActive > 0
	join	tbRoom		r	with (nolock)	on	r.idRoom = rb.idRoom
---	left join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0
	left join	tbPatient	p	with (nolock)	on	p.idRoom = rb.idRoom		and	p.tiBed = rb.tiBed	--	p.idPatient = rb.idPatient
	left join	tbDoctor	dc	with (nolock)	on	dc.idDoctor = p.idDoctor
	left join	vwStaff		a1	with (nolock)	on	a1.idUser = rb.idAssn1
	left join	vwStaff		a2	with (nolock)	on	a2.idUser = rb.idAssn2
	left join	vwStaff		a3	with (nolock)	on	a3.idUser = rb.idAssn3
go
--	----------------------------------------------------------------------------
--	Patients
--	7.05.5127
create view		dbo.vwPatient
	with encryption
as
select	p.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote
	,	p.idDoctor, d.sDoctor
	,	rb.idUnit,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed,		rb.cSys, rb.tiGID, rb.tiJID, rb.tiRID
	,	p.bActive, p.dtCreated, p.dtUpdated
	from	tbPatient	p	with (nolock)
	left join	vwRoomBed	rb	with (nolock)	on	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed
	left join	tbDoctor	d	with (nolock)	on	d.idDoctor = p.idDoctor
go
grant	select, insert, update			on dbo.vwPatient		to [rWriter]
grant	select							on dbo.vwPatient		to [rReader]
go
--	----------------------------------------------------------------------------
--	Removes expired active events
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
(
	@tiPurge	tinyint	= 0			-- 0=don't remove any events
									-- N=remove healing 84s older than N days (cascaded)
									-- 255=remove all inactive events from [tbEvent*] (cascaded)
									--	[select iValue from tb_OptSys where idOption=7]
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
		,		@dt		datetime
		,		@i		int

	set	nocount	on

	begin tran

		exec	pr_Module_Act	1
		select	@dt=	getdate( )					--	mark starting time

	--	update	d	set	d.idEvent= null				--	reset tbDevice.idEvent
	--		from	tbDevice	d
	--		inner join	tbEvent_A	ea	on	ea.idEvent = d.idEvent
	--		where	ea.dtExpires < getdate( )
		update	r	set	r.idEvent= null				--	reset tbRoom.idEvent		v.7.02
			from	tbRoom	r
			join	tbEvent_A	ea	on	ea.idEvent = r.idEvent
			where	ea.dtExpires < @dt
		update	rb	set	rb.idEvent= null			--	reset tbRoomBed.idEvent		v.7.02
			from	tbRoomBed	rb
			join	tbEvent_A	ea	on	ea.idEvent = rb.idEvent
			where	ea.dtExpires < @dt

		delete	from	tbEvent_A	where	dtExpires < @dt
--		delete	from	tbEvent_P	where	dtExpires < @dt

--		delete	a	from	tbEvent_A a				--	remove children whose parent no longer exists
--			left join	tbEvent_P p	on	p.cSys = a.cSys	and	p.tiGID = a.tiGID	and	p.tiJID = a.tiJID
--			where	p.idEvent is null

	/*	delete	from	tbEvent_P					--	WHERE col IN (SELECT ..) == INNER JOIN (SELECT ..) !!
			where	idEvent in
			(select	p.idEvent
				from	tbEvent_P p
				left join	tbEvent_A a	on	a.cSrcSys = p.cSrcSys	and	a.tiSrcGID = p.tiSrcGID	and	a.tiSrcJID = p.tiSrcJID
				group	by p.idEvent
				having	count(a.idEvent) = 0)	*/
/*		delete	p	from	tbEvent_P p				--	remove parents that do not have any children
			inner join
			(select	p.idEvent						--	better statement, though same execution plan
				from	tbEvent_P p
				left join	tbEvent_A a	on	a.cSys = p.cSys	and	a.tiGID = p.tiGID	and	a.tiJID = p.tiJID
				group	by p.idEvent
				having	count(a.idEvent) = 0) t		on	t.idEvent = p.idEvent
*/
	--	update	rb	set	rb.idEvent=	null, tiSvc= null	--	7.02: no need to reset tbRoomBed here
	--		from	tbRoomBed rb
	--		left join	tbEvent_A a	on	a.idEvent = rb.idEvent
	--		where	a.idEvent is null	or	a.bActive = 0

		if	@tiPurge > 0
		begin
			if	@tiPurge = 255						--	remove all inactive events
			begin
/*				update	t	set	t.idEvtVo=	null
					from	tbEvent_T t
					left join	tbEvent_A a	on	a.idEvent = t.idEvtVo
					where	a.idEvent is null
				update	t	set	t.idEvtSt=	null
					from	tbEvent_T t
					left join	tbEvent_A a	on	a.idEvent = t.idEvtSt
					where	a.idEvent is null
*/
				update	c	set	c.idEvtVo=	null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtVo
					where	a.idEvent is null
				update	c	set	c.idEvtSt= null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtSt
					where	a.idEvent is null
/*				update	c	set	c.idEvtRn=	null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtRn
					where	a.idEvent is null
				update	c	set	c.idEvtCn=	null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtCn
					where	a.idEvent is null
				update	c	set	c.idEvtAi=	null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtAi
					where	a.idEvent is null
*/
				delete	e	from	tbEvent e
					left join	tbEvent_A a	on	a.idEvent = e.idEvent
					where	a.idEvent is null
		--		select	@i=	@@rowcount

		--		delete	e	from	tbEvent e		--	7.02: DELETE conflicted with ref constraint "fkEventC_Event_Aide"
		--			left join	tbEvent_P p	on	p.idEvent = e.idEvent
		--			where	p.idEvent is null		+ @i

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
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
						join	tbEvent84	e84	on	e84.idEvent = e.idEvent
						where	e.idLogType is null
						and		e84.siIdxNew = e84.siIdxOld
						and		e.idEvent < @idEvent
				delete	e	from	tbEvent	e
					inner	#tbHeal84 h	on	h.idEvent = e.idHealing		*/
				delete	e	from	tbEvent	e		--	but for now leave cleaner => simpler variant
					join
						(select	e.idEvent
							from	tbEvent		e
							join	tbEvent84	e84	on	e84.idEvent = e.idEvent
							where	e.idLogType is null		and	e84.siIdxNew = e84.siIdxOld		--	healing 84
							and		e.idEvent < @idEvent
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

,	@idEvent	int out				-- output: inserted idEvent
,	@idSrcDvc	smallint out		-- output: found/inserted source device
,	@idDstDvc	smallint out		-- output: found/inserted destination device

,	@idLogType	tinyint		= null	-- type look-up FK (marks significant events only)
,	@idCall		smallint	= null	-- call look-up FK (only 41,84,8A and 95 commands)
,	@tiBtn		tinyint		= null	-- button code (0-31)
,	@tiBed		tinyint		= null	-- bed index (0-9)
,	@idUnit		smallint	= null	-- active unit ID
,	@iAID		int			= null	-- device A-ID (32 bits)
,	@tiStype	tinyint		= null	-- device type (1-255)
,	@idCall0	smallint	= null	-- call prior to escalation
)
	with encryption
as
begin
	declare		@dtEvent	datetime
		,		@tiHH		tinyint
		,		@idRoom		smallint
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
		,		@s			varchar( 255 )

	set	nocount	on

	select	@dtEvent=	getdate( )
		,	@tiHH=		datepart( hh, getdate( ) )
		,	@cDevice=	case when @idCmd = 0x83 then 'G' else '?' end		--	null

	select	@iExpNrm= iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@tiBed= null

	if	@idUnit > 0
--		if	not exists	(select 1 from tbCfgLoc where idLoc = @idUnit and cLoc = 'U')
		if	not exists	(select 1 from tbUnit where idUnit = @idUnit and bActive > 0)
		begin
			select	@s=	'Evt_I( c=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?')
	--	-	exec	pr_Log_Ins	82, null, null, @s

			select	@idUnit=	null
		end

--	select	@s=	'Evt_I( cmd=' + isnull(cast(@idCmd as varchar),'?') + ', unit=' + isnull(cast(@idUnit as varchar),'?') + ' typ=' + isnull(cast(@tiStype as varchar),'?') +
--				', src=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sSrcDvc,'?') +
--				'], dst=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sDstDvc,'?') +
--				'], btn=' + isnull(cast(@tiBtn as varchar),'?') + ', bed=' + isnull(cast(@tiBed as varchar),'?') + ' )'		--	 + ' i=' + isnull(@sInfo,'?')
--	exec	pr_Log_Ins	0, null, null, @s

	begin tran

		if	@tiBed is not null		-- >= 0
			update	tbCfgBed	set	bActive= 1, dtUpdated= getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)	--	audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys=		@cSrcSys,	@tiGID=		@tiSrcGID,	@tiJID=		@tiSrcJID,	@tiShelf=	@tiSrcRID,	@sDvc=		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys=	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys=	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiShelf,	@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype=	null
		end

		exec	dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, null, @cDevice, @sDstDvc, null, @idDstDvc out

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

		if	len(@s) > 0
		begin
			select	@s=	@s + ' ) id=' + cast(@idEvent as varchar)
			exec	pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02
		begin

			select	@idParent= idEvent, @dtParent= dtEvent		--	7.04.4968
				from	tbEvent_A	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
				and		( bActive > 0		or	@idCmd < 0x80 )		--	7.05.5095
				and		( tiBtn = @tiBtn	or	@tiBtn is null )
				and		( idCall = @idCall	or	@idCall is null		or	idCall = @idCall0	and	@idCall0 is not null )

			select	@idRoom=	idDevice
				from	vwRoom		with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	bActive > 0		--	and	tiRID = 0

--			select	@s=	'Evt_i2: prnt=' + isnull(cast(@idParent as varchar),'?') + ' room=' + isnull(cast(@idRoom as varchar),'?')
--			exec	pr_Log_Ins	0, null, null, @s

			if	@idParent is null	--	no parent found
				update	tbEvent		set	idParent= @idEvent,		idRoom= @idRoom,	tParent= '0:0:0'	--,	@dtParent= dtEvent
					where	idEvent = @idEvent

			else	--	parent found
				update	tbEvent		set	idParent= @idParent,	idRoom= @idRoom,	tParent= dtEvent - @dtParent
					where	idEvent = @idEvent
		end

		select	@idParent= null			--	6.04
		select	@idParent= idEvent
			from	tbEvent_S	with (nolock)
			where	dEvent = cast(@dtEvent as date)
				and	tiHH = @tiHH
		if	@idParent	is null
			insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
					values		( @dtEvent, @tiHH, @idEvent )

		if	@idUnit > 0								--	7.02
			update	tbRoom		set	idUnit=	@idUnit
				where	idRoom = @idRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
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
,	@sModInfo	varchar( 96 )		-- module info (e.g. 'j7983ls.exe v.M.N.DD.TTTT (built d/t)')
,	@idLogType	tinyint				-- type look-up FK (marks significant events only)
,	@dtStarted	datetime			-- when running, null == stopped
,	@sParams	varchar( 255 )		-- startup arguments/parameters
)
	with encryption
as
begin
	declare		@idEvent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint

	set	nocount	on

	begin tran

		update	dbo.tb_Module	set	dtStart= @dtStarted, sParams= @sParams, dtLastAct= getdate( )
			where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sModInfo

--		select	@idEvent=	charindex( ' [', @sModInfo ) + 2
	---	select	@sModInfo=	replace( substring( @sModInfo, @idEvent, charindex( ' (', @sModInfo ) - @idEvent ), ']', '' )
--		select	@sModInfo=	replace( substring( @sModInfo, @idEvent, len( @sModInfo ) - @idEvent ), ']', ' ' )

		select	@sModInfo=	sModule + ' v.' + sVersion
			from	dbo.tb_Module	with (nolock)
			where	idModule = @idModule

		exec	dbo.prEvent_Ins		0, null, null, null, null, null, null, null, null, null, null, null, null, null,
						@sModInfo, @idEvent out, @idSrcDvc out, @idDstDvc out, @idLogType
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idRoom, sRoom,	tiBed, cBed,	idUnit
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, iFilter
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0		and	idUnit = @idUnit
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given room (identified by Sys-G-J)
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idRoom, sRoom,	tiBed, cBed,	idUnit
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, iFilter
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	( tiShelf > 0	or	@bPrsnc > 0	and	tiSpec between 7 and 9 )
			and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
,	@tiTmrSt	tinyint				-- stat-need timer
,	@tiTmrRn	tinyint				-- RN-need timer
,	@tiTmrCn	tinyint				-- CNA-need timer
,	@tiTmrAi	tinyint				-- Aide-need timer
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
,	@sCall		varchar( 16 )		-- call text
,	@sPatient	varchar( 16 )		-- patient name
,	@cGender	char( 1 )
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
,	@sRn		varchar( 16 )		-- RN name
,	@sCn		varchar( 16 )		-- CNA name
,	@sAi		varchar( 16 )		-- Aide name

--,	@idEventA	int out				-- output: idEvent, inserted into tbEvent_A
)
	with encryption
as
begin
	declare		@idEvent	int
		,		@idParent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idRoom		smallint
		,		@idCall		smallint
		,		@idCall0	smallint
		,		@siIdxOld	smallint
		,		@siIdxNew	smallint
		,		@idDoctor	int
		,		@idPatient	int
--		,		@cGender	char( 1 )
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiRmBed	tinyint
		,		@cBed		char( 1 )
		,		@tiPurge	tinyint
		,		@bAudio		bit
		,		@iExpNrm	int
		,		@iExpExt	int
--		,		@idUser		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

	select	@tiPurge=	cast(iValue as tinyint)
		from	tb_OptSys	with (nolock)	where	idOption = 7
	select	@iExpNrm=	iValue
		from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt=	iValue
		from	tb_OptSys	with (nolock)	where	idOption = 10

	if	@siIdxNew > 0			-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiSpec= tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

/*		if	@siIdxOld = 0  and  @tiSpec between 7 and 9		-- call placed		--	7.05.5095 commented out
			select	@sInfo=	case when	@tiSpec = 7	then	@sRn
								when	@tiSpec = 8	then	@sCn
								when	@tiSpec = 9	then	@sAi
								else	@sInfo	end
*/
		if	@siIdxOld > 0  and  @siIdxOld <> @siIdxNew		-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0		-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiSpec= tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0		--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	if	@tiSpec between 7 and 9
		select	@tiBed=	0xFF	--	drop bed-index for 'presence' calls
	else
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out

	if	@tiBed > 9	--	= 0xFF	or	@tiBed = 0
		select	@cBed= null,	@tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

--	if	len(@sPatient) > 15
--		select	@cGender= substring( @sPatient, 15, 1 )
--	else
--		select	@cGender= null
		
	if	@idUnit > 0
--		if	not exists	(select 1 from tbCfgLoc where idLoc = @idUnit and cLoc = 'U')
		if	not exists	(select 1 from tbUnit where idUnit = @idUnit and bActive > 0)
		begin
			select	@s=	'Evt_I( c=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?')
	--	-	exec	pr_Log_Ins	82, null, null, @s

			select	@idUnit=	null
		end

	begin tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiBtn, @tiBed, @idUnit, @iAID, @tiStype, @idCall0

		select	@idRoom= idRoom		--, @idCall= idCall		--	get idRoom, assigned by prEvent_Ins
			from	tbEvent		with (nolock)
			where	idEvent = @idEvent

		insert	tbEvent84	(  idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew,
							tiTmrSt,  tiTmrRn,  tiTmrCn,  tiTmrAi,  idPatient,  idDoctor,  iFilter,
							tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
							siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
				values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew,
							@tiTmrSt, @tiTmrRn, @tiTmrCn, @tiTmrAi, @idPatient, @idDoctor, @iFilter,
							@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
							@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3)

		if	len(@s) > 0
		begin
			select	@s=	@s + ' ) id=' + cast(@idEvent as varchar)
			exec	pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prRoom_Upd		@idRoom, @idUnit, @sRn, @sCn, @sAi


		--	origin points to the first [still active!] event that started [healing] sequence for this priority
		select	@idOrigin= idEvent, @dtOrigin= dtEvent, @bAudio= bAudio
			from	tbEvent_A	with (nolock)
			where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn
				and	bActive > 0				--	6.04
				and	(idCall = @idCall	or	idCall = @idCall0)		--	7.05.4976


	---	if	@siIdxOld = 0	or	@idOrigin is null	--	new call placed | no active origin found
		if	@idOrigin is null	--	no active origin found
			--	'real' new call should not have origin anyway, 'repeated' one would be linked to starting - even better
		begin
			update	tbEvent		set	idOrigin= @idEvent, idLogType= 191	-- call placed
								,	tOrigin= dateadd(ss, @siElapsed, '0:0:0')										--	6.05
								,	@dtOrigin= dateadd(ss, - @siElapsed, dtEvent), @idSrcDvc= idSrcDvc, @idParent= idParent		--	6.04
				where	idEvent = @idEvent

			insert	tbEvent_A	(  idEvent,   dtEvent,  cSys,     tiGID,     tiJID,     tiRID,     tiBtn,  siPri,     siIdx,     tiBed, dtExpires,
								tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn, @siPriNew, @siIdxNew, @tiBed,		--	6.04
								dateadd(ss, @iExpNrm, getdate( )),
								@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )	--@dtOrigin

--			update	tbEvent_T	set	idCall= @idCall, idUnit= @idUnit, cBed= @cBed
--				where	idEvent = @idParent		and	@idCall is null		-- there could be more than one, but we need to use only 1st one

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

			if	( @tiShelf > 0	and		( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 ) )	--	only save 'medical' calls
				or	@tiSpec between 7 and 9															--	or 'presence'
				begin
					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,   tiHH,						idCall,  idRoom,  idUnit,  tiBed )
							values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idRoom, @idUnit, @tiBed )

					if	@tiSpec between 7 and 9
					begin
						update	tbEvent		set	idLogType= 206	-- presence-in
							where	idEvent = @idEvent

						update	ec	set	ec.idUser=	case								--	7.05.5066
								when @tiSpec = 7	then	r.idRn
								when @tiSpec = 8	then	r.idCn
								else						r.idAi	end
							from	tbEvent_C	ec
							join	tbRoom		r	on	r.idRoom = ec.idRoom
							where	ec.idEvent = @idEvent								--	7.05.5095
					end
				end

			select	@idOrigin= @idEvent		--	6.04
		end

		else	--	active origin found		(=> this must be a healing or cancellation event)
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin		--	,@idSrcDvc= idSrcDvc
				where	idEvent = @idEvent
			update	tbEvent_A	set	dtExpires= dateadd(ss, @iExpNrm, getdate( )),	siPri= @siPriNew
				where	idEvent = @idOrigin		--	7.05.5065
--				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn
--					and	bActive > 0				--	6.04
		end


		if	@siIdxNew = 0	-- call cancelled
		begin
		--	6.03:	upon cancellation mark inactive, but defer removal of tbEvent_A and tbEvent_P rows - let them expire,
		--				so that events from same sequence (that are still-unfinished) can be tied to the same parent
			select	@dtOrigin=	case when @bAudio=0 then dateadd(ss, @iExpNrm, getdate( ))				--	6.05
													else dateadd(ss, @iExpExt, getdate( )) end

			select	@tiSpec= tiSpec	from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld

			update	tbEvent_A	set	dtExpires= @dtOrigin, bActive= 0,	tiSvc= null		--	6.05
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn
					and	bActive > 0				--	6.04

--			update	tbEvent_P	set	dtExpires= @dtOrigin												--	6.05
--				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
--					and	dtExpires < @dtOrigin

	--		select	@s=	@cSrcSys + '-' + cast(@tiSrcGID as varchar) + '-' + cast(@tiSrcJID as varchar) +
	--					' -> ' + convert(varchar, @dtOrigin, 121) + ' rows:' + cast(@@rowcount as varchar)
	--		exec	pr_Log_Ins	0, null, null, @s

			select	@dtOrigin= tOrigin, @idParent= idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	tbEvent_C	set	idEvtSt= @idEvent, tStaff= @dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null		-- there should be only one, but just in case - use only 1st one
			update	tbEvent		set	idLogType=	case when @tiSpec between 7 and 9 then 207 else 193 end	-- call cancelled
				where	idEvent = @idEvent
		end

		else if	@siIdxNew > 0  and  @siIdxOld > 0  and  @siIdxOld <> @siIdxNew
			update	tbEvent		set	idLogType= 192		-- call escalated
				where	idEvent = @idEvent


		if	@tiPurge > 0
			delete	from	tbEvent							-- remove healing event at once (cascade rule must take care of other tables)
				where	idEvent = @idEvent
					and	idLogType is null

		if	@tiTmrSt > 3		select	@tiTmrSt=	3
		if	@tiTmrRn > 3		select	@tiTmrRn=	3
		if	@tiTmrCn > 3		select	@tiTmrCn=	3
		if	@tiTmrAi > 3		select	@tiTmrAi=	3

		update	tbEvent_A	set	idRoom= @idRoom				--	cache necessary details in the active call (tiBed is null for room-level calls)
							,	idCall= @idCall, tiSvc= @tiTmrSt*64 + @tiTmrRn*16 + @tiTmrCn*4 + @tiTmrAi	---, tiBed= @tiBed	--	6.05
			where	idEvent = @idOrigin

		if	@tiStype = 192	and	@tiBed is not null				--	only for 7947 (iBed):	if argument is a bed-level call
			update	tbRoomBed	set	tiIbed=
									case when	@siIdxNew = 0	then	--	call cancelled
										tiIbed &
										case when	@tiBtn = 2	then	0xFE
											when	@tiBtn = 7	then	0xFD
											when	@tiBtn = 6	then	0xFB
											when	@tiBtn = 5	then	0xF7
											when	@tiBtn = 4	then	0xEF
											when	@tiBtn = 3	then	0xDF
											when	@tiBtn = 1	then	0xBF
											when	@tiBtn = 0	then	0x7F
											else	0xFF	end
										else							--	call placed / being-healed
										tiIbed |
										case when	@tiBtn = 2	then	0x01
											when	@tiBtn = 7	then	0x02
											when	@tiBtn = 6	then	0x04
											when	@tiBtn = 5	then	0x08
											when	@tiBtn = 4	then	0x10
											when	@tiBtn = 3	then	0x20
											when	@tiBtn = 1	then	0x40
											when	@tiBtn = 0	then	0x80
											else	0x00	end
										end
				where	idRoom = @idRoom	and		tiBed = @tiBed

		if	not	@tiSpec between 7 and 9							--	7.05.5147
			exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5101

	---	!! @idEvent no longer points to current event !!

		select	@idEvent= null, @tiSvc= null
		--	select highest oldest active call for this room (room- or bed-level)
		select	top 1	@idEvent= idEvent, @tiSvc= tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent desc
	--		order	by	siIdx desc, tElapsed desc		--	call may have been started before it was recorded (idEvent)

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
			--	select highest oldest active call for this room (room- or bed-level)
			select	top 1	@idEvent= idEvent, @tiSvc= tiSvc
				from	tbEvent_A	ea	with (nolock)
				where	idRoom = @idRoom
					and	bActive > 0
					and	(tiBed is null	or tiBed = @tiRmBed)
				order	by	siIdx desc, idEvent desc
	--			order	by	siIdx desc, tElapsed desc		--	call may have been started before it was recorded (idEvent)

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
--	Inserts event [0x88, x89, x8A, x8D] audio
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
		,		@idParent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idRoom		smallint
		,		@idCall		smallint
		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@cBed		char( 1 )
		,		@iExpNrm	int

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@siIdx=	@siPri & 0x03FF

	select	@iExpNrm= iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	begin tran

		if	@siPri > 0
			exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
		else
---			exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call
			select	@idCall= 0				--	INTERCOM call

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiDstBtn, @tiBed

		select	@idRoom= idRoom		--, @idCall= idCall		--	get idRoom, assigned by prEvent_Ins
			from	tbEvent		with (nolock)
			where	idEvent = @idEvent

		insert	tbEvent8A	(  idEvent,  tiSrcJAB,  tiSrcLAB,  tiDstJAB,  tiDstLAB,  siPri,  tiFlags,  siIdx )
				values		( @idEvent, @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB, @siPri, @tiFlags, @siIdx )

		--	this one is really not origin, but parent - audio is not being healed
		select	@idOrigin= idEvent, @dtOrigin= dtEvent
			from	tbEvent_A	with (nolock)
			where	cSys = @cDstSys
				and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiDstBtn
		---		and	bActive > 0				--	6.05 (6.04 in 84!):	audio events ignore active/inactive state
				and	idCall = @idCall		--	7.05.4976

		if	@idOrigin	is not null
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
					--			,	idParent= @idOrigin, tParent= dtEvent - @dtOrigin		--	7.05.4976
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

				update	tbEvent_C	set	idEvtVo= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idOrigin		and	idEvtVo is null		-- there should be only one, but just in case - use only 1st one
			end
			else if	@idCmd = 0x8D
			begin
				update	tbEvent_A	set	bAudio= 0							-- disconnected
					,	dtExpires=	case when bActive = 0 then dateadd(ss, @iExpNrm, getdate( ))
														else dtExpires end
					where	idEvent = @idOrigin
				update	tbEvent		set	idLogType= 199						-- audio quit
					where	idEvent = @idEvent
			end
		end
		else	-- no origin found
		begin
			update	tbEvent		set	idOrigin= @idEvent, tOrigin= '0:0:0' --,	idLogType= 198	-- audio dialed
								,	idParent= @idEvent, tParent= '0:0:0'	--	7.05.4976
				,	idLogType=	case when @idCmd = 0x8D then 199			-- audio quit
									when @idCmd = 0x89 then 195				-- audio request
									when @idCmd = 0x88 then 196				-- audio busy
									else					197 end,		-- audio connected
					@idDstDvc= idSrcDvc, @dtOrigin= dtEvent
				where	idEvent = @idEvent

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
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
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idCall		smallint
		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@cBed		char( 1 )

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@siIdx=	@siPri & 0x03FF

	begin tran

--		if	@tiBed >= 0
--			update	tbCfgBed	set	bActive= 1, dtUpdated= getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@siIdx > 0
			exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
		else
---			exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call
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
				and	bActive > 0				--	7.05.4980
				and	idCall = @idCall		--	7.05.4980

			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
					--			,	idParent= @idOrigin, tParent= dtEvent - @dtOrigin		--	7.05.4981
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
--	7.05.5095	+ 'with (nolock)'
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	tbDefLoc -> tbUnit;		.sLoc -> .sUnit
--	7.02	* .ti*Stat -> .ti*St, .ti*Cna -> .ti*Cn, .ti*Aide -> .ti*Ai
--	6.00	tbDefDevice -> tbDevice (FKs)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	5.01	encryption added
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--	2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	1.00
alter view		dbo.vwEvent95
	with encryption
as
select	e.idEvent, h.dtEvent, h.idCmd, h.cSrcSys, h.tiSrcGID, h.tiSrcJID, h.tiSrcRID,
		h.cDstSys, h.tiDstGID, h.tiDstJID, h.tiDstRID, h.tiBtn, e.tiSvcSet, e.tiSvcClr,
		h.idSrcDvc, d.sDevice, d.sDial, h.tiBed, h.idCall, c.sCall, h.sInfo, h.idUnit, u.sUnit,
		tiSvcSet & 0x08 [tiSetSt],	tiSvcSet & 0x04 [tiSetRn],	tiSvcSet & 0x02 [tiSetCn],	tiSvcSet & 0x01 [tiSetAi],
		tiSvcClr & 0x08 [tiClrSt],	tiSvcClr & 0x04 [tiClrRn],	tiSvcClr & 0x02 [tiClrCn],	tiSvcClr & 0x01 [tiClrAi]
	from	tbEvent95	e	with (nolock)
	join	tbEvent		h	with (nolock)	on	h.idEvent = e.idEvent
	join	tbCall		c	with (nolock)	on	c.idCall = h.idCall
	left join	tbDevice	d	with (nolock)	on	d.idDevice = h.idSrcDvc
	left join	tbUnit		u	with (nolock)	on	u.idUnit = h.idUnit
go
--	----------------------------------------------------------------------------
--	Inserts event [0x98, 0x9A, 0x9E, 0x9C, 0xA4, 0xAD, 0xAF]
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
,	@tiMulti	tinyint				-- depends on command
--,	@tiFlags	tinyint				-- bed flags (privacy status)
,	@sPatient	varchar( 16 )		-- patient name
,	@cGender	char( 1 )
,	@sDoctor	varchar( 16 )		-- doctor name
,	@sInfo		varchar( 32 )		-- info text, 0xAF: dialable room number
,	@sDevice	varchar( 16 )		-- 0x9E: destination room name
)
	with encryption
as
begin
	declare		@idEvent	int
		,		@idDoctor	int
		,		@idPatient	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint

	set	nocount	on

	if	len( @sPatient ) > 0
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
	else	if	len( @sDoctor ) > 0
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out

		insert	tbEvent98	( idEvent,  tiMulti,  idPatient,  idDoctor )	--, tiFlags
				values		( @idEvent, @tiMulti, @idPatient, @idDoctor )	--, @tiFlags

	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5095	+ 'with (nolock)'
--	7.05.5066	* .c*Sys,.ti*GID,.ti*JID,.ti*RID -> .s*SGJR
--	6.04	tbDefPatient -> tbPatient (tbEvent84, prEvent84_Ins, vwEvent84, tbEvent98, prEvent98_Ins, vwEvent98, tbRoomBed, vwRoomBed, prRptCallActDtl)
--	5.01	encryption added
--	4.01
--	1.00
alter view		dbo.vwEvent98
	with encryption
as
select	e98.idEvent, e.dtEvent, e.idCmd
	,	e.sSrcSGJR, e.idSrcDvc, e.sSrcDvc	--, e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID
	,	e.sDstSGJR, e.idDstDvc, e.sDstDvc	--, e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID
	,	e.tiBtn, e.tiBed, e.sInfo, e98.tiMulti
	,	e98.idPatient, p.sPatient
	,	e98.idDoctor, d.sDoctor
	from		tbEvent98	e98	with (nolock)
	join		vwEvent		e	with (nolock)	on	e.idEvent = e98.idEvent
	left join	tbPatient	p	with (nolock)	on	p.idPatient = e98.idPatient
	left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e98.idDoctor
go
if	not	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbPcsType')
	exec( '
--	----------------------------------------------------------------------------
--	PSC command subtypes
--	7.05.5095
create table	dbo.tbPcsType
(
	idPcsType		tinyint			not null	-- type look-up PK
		constraint	xpPcsType	primary key clustered

,	sPcsType		varchar( 32 )	not null	-- type text
)
	' )
go
grant	select							on dbo.tbPcsType		to [rWriter]
grant	select							on dbo.tbPcsType		to [rReader]
go
begin tran
	if	not	exists	(select 1 from dbo.tbPcsType where idPcsType > 0)
	begin
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x01, 'Ring' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x02, 'Stop ring' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x03, 'Ring successful' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x04, 'Handset in PBX session' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x05, 'Handset in OAI session' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x06, 'Handset inactive' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x07, 'Ring terminated' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x08, 'No response' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x09, 'Radio Pocket Page' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x0A, 'Alert only (team ring)' )
	end
	if	not	exists	(select 1 from dbo.tbPcsType where idPcsType = 0x0B)
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x0B, 'Alert only (ring expired)' )
commit
go
--	----------------------------------------------------------------------------
--	System activity log: [0x41] pager and phone activity
--	7.05.5095	+ .idDvc, .idUser;	- .siIdx, .dtAttempt, .biPager
--				* .cStatus not null -> null
--if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'idDvc')
begin
	begin tran
		if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'siIdx')
			alter table	dbo.tbEvent41	drop	column		siIdx,	dtAttempt

		if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'cStatus')
			alter table	dbo.tbEvent41	alter	column		cStatus		char( 1 )		null

		if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'tiSeqAct')
			exec sp_rename 'tbEvent41.tiSeqAct',	'tiSeqNum',		'column'

		if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'idPcsType')
			alter table	dbo.tbEvent41	add
				idPcsType	tinyint			null
					constraint	fkEvent41_Type	foreign key references	tbPcsType

		if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'idDvc')
			alter table	dbo.tbEvent41	add
				idDvc		int				null
					constraint	fkEvent41_Dvc	foreign key references	tbDvc

		if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'idUser')
			alter table	dbo.tbEvent41	add
				idUser		int				null
					constraint	fkEvent41_User	foreign key references	tb_User
	commit
end
go
--	fill .idDvc
--	<1,tbEvent41>
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'idDvc')		and
	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'biPager')
	exec( '
	begin tran
		update	dbo.tbEvent41	set	idPcsType= 0x09, idUser= 3		-- Sample User, since no history is available

		update	e	set	e.idDvc= d.idDvc
			from	tbEvent41	e
			join	tbDvc		d	on	d.sDial = e.biPager		and	d.idDvcType = 2		-- pager

		if	exists	(select 1 from dbo.tbEvent41 where idDvc is null)
		begin
			declare	@id		int

			insert	dbo.tbDvc	( idDvcType, bActive, sDvc, sDial )
				values	( 2, 0, ''Pager 9999999999'',	''9999999999'' )
			select	@id =	scope_identity( )

			update	dbo.tbEvent41	set	idDvc= @id
				where	idDvc is null
		end

		alter table	dbo.tbEvent41	alter	column		idPcsType	tinyint			not null
		alter table	dbo.tbEvent41	alter	column		idUser		int				not null
		alter table	dbo.tbEvent41	alter	column		idDvc		int				not null
		alter table	dbo.tbEvent41	drop	column		biPager
	commit
	' )
go
--	----------------------------------------------------------------------------
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
--,	@sCall		varchar( 16 )		-- call-text
,	@siIdx		smallint			-- call-index
--,	@dtAttempt	datetime			-- when page was sent to encoder
--,	@biPager	bigint				-- pager number
,	@idPcsType	tinyint				-- PCS action subtype
,	@idDvc		int					-- if null use @sDial
,	@idDvcType	tinyint
,	@sDial		varchar( 16 )
,	@tiSeqNum	tinyint				-- RPP sequence number (0-255)
,	@cStatus	char( 1 )			-- Q=Queued, R=Rejected, U=unknown
,	@sInfo		varchar( 32 )		-- page message
)
	with encryption
as
begin
	declare		@idEvent	int
		,		@idCall		smallint
		,		@sCall		varchar( 16 )
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idUser		int
		,		@idLogType	tinyint

	set	nocount	on

	select	@siIdx=	@siIdx & 0x03FF

	begin tran

		if	@siIdx > 0
		begin
			select	@sCall= sCall	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx
			exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
		end
		else
---			exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call
			select	@idCall= 0				--	INTERCOM call

		if	@idDvc is null
			select	@idDvc= idDvc
				from	tbDvc	with (nolock)
				where	@idDvcType = @idDvcType		and	sDial = @sDial	and	bActive > 0

		select	@idLogType=	case
					when idDvcType = 3 then 204		-- phone
					when idDvcType = 2 then 205		-- pager
					else 82 end
			,	@idUser= idUser
			from	tbDvc	with (nolock)
			where	idDvc = @idDvc

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
					null, null, null, null, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, @idLogType, @idCall, @tiBtn, @tiBed

		insert	tbEvent41	(  idEvent,  idPcsType,  idDvc,  idUser,  tiSeqNum,  cStatus )
				values		( @idEvent, @idPcsType, @idDvc, @idUser, @tiSeqNum, @cStatus )
	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5095
create view		dbo.vwEvent41
	with encryption
as
select	e.idEvent, h.dtEvent, h.idCmd, h.cSrcSys, h.tiSrcGID, h.tiSrcJID	--, h.tiSrcRID,	h.tiBtn
	,	h.idParent--, h.idOrigin
	,	r.idDevice, r.sSGJ, r.sDevice,	h.tiBed, b.cBed
	,	h.idCall, c.sCall, c.siIdx
	,	e.idDvc, d.idDvcType, d.sDvcType, d.sDial, d.sDvc, e.idPcsType, t.sPcsType, e.tiSeqNum, e.cStatus,	h.sInfo
	,	e.idUser, u.sStfLvl, u.sStaffID, u.sStaff
	from	tbEvent41	e	with (nolock)
	join	tbEvent		h	with (nolock)	on	h.idEvent = e.idEvent
	join	tbPcsType	t	with (nolock)	on	t.idPcsType = e.idPcsType
	join	vwDevice	r	with (nolock)	on	r.bActive > 0	and	r.cSys = h.cSrcSys	and	r.tiGID = h.tiSrcGID	and	r.tiJID = h.tiSrcJID	and	r.tiRID = 0	--h.tiSrcRID
	join	tbCall		c	with (nolock)	on	c.idCall = h.idCall	--c.bActive > 0	and
	join	vwDvc		d	with (nolock)	on	d.idDvc = e.idDvc	--c.bActive > 0	and
	join	vwStaff		u	with (nolock)	on	u.idUser = e.idUser
	left join	tbCfgBed b	with (nolock)	on	b.tiBed = h.tiBed
go
grant	select							on dbo.vwEvent41		to [rWriter]
grant	select							on dbo.vwEvent41		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
--	7.05.4990	+ @tiRID[i], @tiBtn[i]
--	7.03
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
		from	tbUnitMapCell	c	with (nolock)
		left outer join	tbDevice	d	with (nolock)	on	d.idDevice = c.idRoom	--	and	d.bActive > 0	--	and	d.tiRID = 0
--		left outer join	tbDevice	d	with (nolock)	on	d.cSys = c.cSys	and	d.tiGID = c.tiGID	and	d.tiJID = c.tiJID	and	d.tiRID = 0	and	d.bActive > 0
		where	c.idUnit = @idUnit
end
go
--	----------------------------------------------------------------------------
--	Updates a given map-cell
--	7.05.4990	+ @tiRID[i], @tiBtn[i]
--	7.03	+ @idRoom, - @bSwing, @cSys, @tiGID, @tiJID
--	6.04
alter proc		dbo.prUnitMapCell_Upd
(
	@idUnit		smallInt					-- unit id
,	@tiMap		tinyint						-- map index [0..3]
,	@tiCell		tinyint						-- cell index [0..47]
,	@idRoom		smallInt					-- room id
,	@sCell1		varchar( 8 )				-- cell name line 1
,	@sCell2		varchar( 8 )				-- cell name line 2
,	@tiRID1		tinyint						-- R-ID for Aide LED
,	@tiBtn1		tinyint						-- button code (0-31)
,	@tiRID2		tinyint						-- R-ID for CNA LED
,	@tiBtn2		tinyint						-- button code (0-31)
,	@tiRID4		tinyint						-- R-ID for RN LED
,	@tiBtn4		tinyint						-- button code (0-31)
)
	with encryption
as
begin
	declare		@cSys		char( 1 )					-- system ID
			,	@tiGID		tinyint						-- G-ID - gateway
			,	@tiJID		tinyint						-- J-ID - J-bus

	set	nocount	on
	select	@cSys= cSys, @tiGID= tiGID, @tiJID= tiJID
		from	tbDevice	with (nolock)
		where	idDevice = @idRoom

	set	nocount	off
	begin tran
		update	tbUnitMapCell	set	cSys= @cSys, tiGID= @tiGID, tiJID= @tiJID,	idRoom= @idRoom, sCell1= @sCell1, sCell2= @sCell2
								,	tiRID1= @tiRID1, tiBtn1= @tiBtn1,	tiRID2= @tiRID2, tiBtn2= @tiBtn2,	tiRID4= @tiRID4, tiBtn4= @tiBtn4
			where	idUnit = @idUnit	and	tiMap = @tiMap	and	tiCell = @tiCell
	commit
end
go
--	----------------------------------------------------------------------------
--	Shift definitions
--	7.05.5010	* .idStaff -> .idUser, fkShift_Staff -> fkShift_User
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbShift') and name = 'idUser')
begin
	begin tran
		alter table	dbo.tbShift		drop
			constraint	fkShift_Staff
		exec sp_rename 'tbShift.idStaff',	'idUser',		'column'
		alter table	dbo.tbShift		add
			constraint	fkShift_User	foreign key (idUser) references tb_User
	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all shifts
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4965
alter proc		dbo.prShift_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idShift, idUnit, tiIdx, sShift, tBeg, tEnd, tiRouting, tiNotify, idUser, bActive, dtCreated, dtUpdated
		from	tbShift		with (nolock)
		where	idShift > 0
		order	by	idShift
end
go
--	----------------------------------------------------------------------------
--	Imports a shift
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
,	@tiRouting	tinyint				-- 0=Standard, 1=Custom
,	@tiNotify	tinyint				-- notification mode: 0=Auto, 1=SemiAuto, 2=Manual [, 3=FollowConsole]
,	@idUser		int
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin tran

		if	not	exists	(select 1 from tbShift with (nolock) where idShift = @idShift)
		begin
			set identity_insert	dbo.tbShift	on

			insert	tbShift	(  idShift,  idUnit,  tiIdx,  sShift,  tBeg,  tEnd,  tiRouting,  tiNotify,  idUser,  bActive,  dtCreated,  dtUpdated )
					values	( @idShift, @idUnit, @tiIdx, @sShift, @tBeg, @tEnd, @tiRouting, @tiNotify, @idUser, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbShift	off
		end
		else
			update	tbShift	set	idUnit= @idUnit, tiIdx= @tiIdx, sShift= @sShift, tBeg= @tBeg, tEnd= @tEnd, tiRouting= @tiRouting
						,	tiNotify= @tiNotify, idUser= @idUser, bActive= @bActive, dtUpdated= @dtUpdated
				where	idShift = @idShift

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all shifts for a given unit (ordered)
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4938
alter proc		dbo.prShift_GetByUnit
(
	@idUnit		smallint
)
	with encryption
as
begin
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, cast(0 as bit) bRouting, tiNotify, idUser, bActive, dtUpdated
		from	tbShift		with (nolock)
		where	idUnit = @idUnit	and	bActive > 0
		order	by	tiIdx
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
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
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin tran

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'S'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'B'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'F'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'U'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= 'C'
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		if	@iTrace & 0x01 > 0
		begin
			select	@s= 'Loc_SL( ) ' + cast(@iCount as varchar) + ' rows'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		--	deactivate non-matching units
		update	u	set	u.bActive= 0, u.dtUpdated= getdate( )
			from	tbUnit	u
			left join 	tbCfgLoc	l	on l.idLoc = u.idUnit
			where	u.bActive = 1	and	l.idLoc is null

		--	deactivate shifts for inactive units
		update	s	set	s.bActive= 0, s.dtUpdated= getdate( )
			from	tbShift	s
			join	tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0

		declare	cur		cursor fast_forward for
			select	idLoc, sLoc
				from	tbCfgLoc
				where	tiLvl = 4
				order	by	1

		open	cur
		fetch next from	cur	into	@idUnit, @sUnit
		while	@@fetch_status = 0
		begin
			--	upsert tbUnit to match tbCfgLoc
			if	exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
				update	tbUnit	set	bActive= 1, sUnit= @sUnit, dtUpdated= getdate( )
					where	idUnit = @idUnit
			else
			begin
				insert	tbUnit	(  idUnit,  sUnit, tiShifts )
						values	( @idUnit, @sUnit, 1 )
				insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )			--	default to single 24hr-shift
						values	( @idUnit, 1, 'Shift 1', '07:00:00', '07:00:00' )
				select	@idShift=	scope_identity( )

				update	tbUnit	set	idShift= @idShift
					where	idUnit = @idUnit

	--	-		insert	tbRouting	(  idShift,  siIdx,  tResp0,  tResp1,  tResp2,  tResp3 )
	--	-				values		(  )
			end

			--	populate tbUnitMap
			if	not	exists	(select 1 from tbUnitMap where idUnit = @idUnit)
			begin
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
			end

			--	populate tbUnitMapCell
			if	not	exists	(select 1 from tbUnitMapCell where idUnit = @idUnit)
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
--	Staff assignment definitions
begin tran
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='xpStaffAssn')
		exec sp_rename 'dbo.xpStaffAssn',			'xpStfAssn'
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffAssn_Shift')
		exec sp_rename 'dbo.fkStaffAssn_Shift',		'fkStfAssn_Shift'
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffAssn_RoomBed')
		exec sp_rename 'dbo.fkStaffAssn_RoomBed',	'fkStfAssn_RoomBed'
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffAssn_Staff')
		exec sp_rename 'dbo.fkStaffAssn_Staff',		'fkStfAssn_Staff'

	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStaffAssn_Active')
		exec sp_rename 'tdStaffAssn_Active',		'tdStfAssn_Active'
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStaffAssn_Created')
		exec sp_rename 'tdStaffAssn_Created',		'tdStfAssn_Created'
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStaffAssn_Updated')
		exec sp_rename 'tdStaffAssn_Updated',		'tdStfAssn_Updated'
	if	exists	(select 1 from dbo.sysindexes where name='xuStaffAssn_Active_RoomBedShiftIdx')
		exec sp_rename 'dbo.tbStfAssn.xuStaffAssn_Active_RoomBedShiftIdx',	'xuStfAssn_Active_RoomBedShiftIdx'
commit
go
--	7.05.5010	* .idStaff -> .idUser, fkStfAssn_Staff -> fkStfAssn_User
--				- .iStamp, .TempID
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStfAssn') and name = 'idUser')
begin
	begin tran
		alter table	dbo.tbStfAssn	drop
			constraint	fkStfAssn_Staff
		alter table	dbo.tbStfAssn	drop
			column	iStamp, TempID
		exec sp_rename 'tbStfAssn.idStaff',	'idUser',		'column'
		alter table	dbo.tbStfAssn	add
			constraint	fkStfAssn_User	foreign key (idUser) references tb_User
	commit
end
go
--	7.05.5079	+ on delete cascade to fkStfAssn_RoomBed
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStfAssn_RoomBed')
			alter table tbStfAssn drop constraint fkStfAssn_RoomBed

		alter table tbStfAssn add
			constraint	fkStfAssn_RoomBed	foreign key	( idRoom, tiBed )	references	tbRoomBed	on delete cascade
	commit
end
go
--	----------------------------------------------------------------------------
--	Staff assignment history (coverage)
begin tran
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='xpStaffCover')
		exec sp_rename 'dbo.xpStaffCover',			'xpStfCvrg'
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffCover_StaffAssn')
		exec sp_rename 'dbo.fkStaffCover_StaffAssn','fkStfCvrg_StfAssn'
commit
go
--	7.05.5079	+ on delete cascade to fkStfCvrg_StfAssn
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStfCvrg_StfAssn')
			alter table tbStfCvrg drop constraint fkStfCvrg_StfAssn

		alter table tbStfCvrg add
			constraint	fkStfCvrg_StfAssn	foreign key ( idStfAssn )	references	tbStfAssn	on delete cascade
	commit
end
go
--	7.05.5086	+ .dtDue
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStfCvrg') and name = 'dtDue')
begin
	begin tran
		alter table	dbo.tbStfCvrg	add
			dtDue		smalldatetime	null	-- due finish
	commit
end
go
--	set .dtDue for all existing assignments
--	<1,tbStfCvrg>
begin
	declare	@dtNow			smalldatetime
	,		@tNow			time( 0 )

	select	@dtNow= getdate( )		--	smalldatetime truncates seconds
	select	@tNow= @dtNow			--	time(0) truncates date, leaving HH:MM:00

	begin tran
		update	sc	set	sc.dtDue= case when sc.dtEnd is not null then sc.dtEnd else
			--			case when	sh.tBeg < sh.tEnd	then	@dtNow - @tNow + sh.tEnd			--	!! this works in 2008 R2, but not in 2012
			--											else	@dtNow - @tNow + sh.tEnd + 1 end
						case when	sh.tBeg < sh.tEnd	then	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime)
														else	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime) + 1 end
						end
			from	tbStfCvrg	sc
			join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn	--and	sa.bActive > 0
			join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		--and	sh.bActive > 0
			where	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
					or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)

		update	sc	set	sc.dtEnd=	sc.dBeg + cast(sh.tEnd as smalldatetime)
					,	sc.dEnd=	sc.dBeg
					,	sc.tEnd=	sh.tEnd
					,	sc.tiEnd=	datepart( hh, sh.tEnd )
			from	tbStfCvrg	sc
			join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn	--and	sa.bActive > 0
			join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		--and	sh.bActive > 0
			where	sc.dtEnd is null	and	sc.dtBeg < @dtNow - 1

		update	tbStfCvrg	set	dtDue= dtEnd
			where	dtEnd is not null	and	dtDue is null

		update	tbStfCvrg	set	dtDue= '2001-01-01'
			where	dtDue is null

		alter table	dbo.tbStfCvrg	alter column
			dtDue		smalldatetime	not null	-- due finish
	commit
end
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
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
	,	sa.idShift, sh.tiIdx [tiShIdx], sh.sShift, sh.tBeg [tShBeg], sh.tEnd [tShEnd]
	,	sa.idRoom, d.cDevice, d.sDevice [sRoom], d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.bOnDuty
	,	sc.idStfCvrg, sc.dtBeg, sc.dtEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfAssn	sa	with (nolock)
	join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift
	join	vwStaff		s	with (nolock)	on	s.idUser = sa.idUser
	join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
	left join	tbStfCvrg	sc	with (nolock)	on	sc.idStfCvrg = sa.idStfCvrg
go
--	----------------------------------------------------------------------------
--	Current (open) staff assignment history (coverage)
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
	,	sa.idShift, sh.tiIdx [tiShIdx], sh.sShift, sh.tBeg [tShBeg], sh.tEnd [tShEnd]
	,	sa.idRoom, d.cDevice, d.sDevice [sRoom], d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.bOnDuty
	,	sc.idStfCvrg, sc.dtBeg, sc.dtDue	--, sc.dtEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfCvrg	sc	with (nolock)
	join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn
	join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift
	join	vwStaff		s	with (nolock)	on	s.idUser = sa.idUser
	join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
	where	sc.dtEnd is null
go
--	----------------------------------------------------------------------------
--	Exports all staff assignment definitions
--	7.05.5074	+ .dtCreated, .dtUpdated
--	7.05.5050
create proc		dbo.prStfAssn_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idStfAssn, idUnit, idRoom, cSys, tiGID, tiJID, tiBed, idShift, tiShIdx, tiIdx, idUser, sStaffID, bActive, dtCreated, dtUpdated
		from	vwStfAssn	with (nolock)
	---	where	bActive > 0					-- must export all to ensure matching deactivation
end
go
grant	execute				on dbo.prStfAssn_Exp				to [rWriter]
grant	execute				on dbo.prStfAssn_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a staff assignment definition
--	7.05.5087	+ trace output
--	7.05.5074
create proc		dbo.prStfAssn_Imp
(
	@idStfAssn	int							-- null = new
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
,	@sStaffID	varchar( 16 )				-- corresponding to idUser
,	@bActive	bit							-- active?
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
	declare		@idRoom		smallint
		,		@idShift	smallint
		,		@idUser		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@idRoom= idDevice	from	vwRoom		with (nolock)	where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID
	select	@idShift= idShift	from	tbShift		with (nolock)	where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx
	select	@idUser= idUser		from	tb_User		with (nolock)	where	bActive > 0		and	sStaffID = @sStaffID

	if	@idRoom is null		or	@idShift is null	or	@idUser is null
		select	@s=	'SA_Imp( cS=' + isnull(cast(@cSys as varchar),'?') +
					', tiG=' + isnull(cast(@tiGID as varchar),'?') + ', tiJ=' + isnull(cast(@tiJID as varchar),'?') +
					', idU=' + isnull(cast(@idUnit as varchar),'?') + ', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') +
					', sSt=' + @sStaffID + ' ) idRm=' + isnull(cast(@idRoom as varchar),'?') +
					' idSh=' + isnull(cast(@idShift as varchar),'?') + ' idSt=' + isnull(cast(@idUser as varchar),'?')
	begin tran

		if	len(@s) > 0
			exec	pr_Log_Ins	47, null, null, @s
		else
		begin
			if	not exists	(select 1 from tbStfAssn with (nolock) where idStfAssn = @idStfAssn)
			begin
				set identity_insert	dbo.tbStfAssn	on

				insert	tbStfAssn	(  idStfAssn,  idRoom,  tiBed,  idShift,  tiIdx,  idUser,  bActive,  dtCreated,  dtUpdated )
						values		( @idStfAssn, @idRoom, @tiBed, @idShift, @tiIdx, @idUser, @bActive, @dtCreated, @dtUpdated )

				set identity_insert	dbo.tbStfAssn	off
			end
			else
				update	tbStfAssn	set	idRoom= @idRoom, tiBed= @tiBed, idShift= @idShift, tiIdx= @tiIdx
							,	idUser= @idUser, bActive= @bActive, dtCreated= @dtCreated, dtUpdated= @dtUpdated
					where	idStfAssn = @idStfAssn
		end

	commit
end
go
grant	execute				on dbo.prStfAssn_Imp				to [rWriter]
--grant	execute				on dbo.prStfAssn_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all staff assignments for given unit/shift
--	7.05.5154
create proc		dbo.prStfAssn_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@idShift	smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	a1.idStfAssn [idStfAssn1],	a1.idUser [idUser1], a1.idStfLvl [idStfLvl1], a1.sStaffID [sStaffID1], a1.sStaff [sStaff1], a1.bOnDuty [bOnDuty1]
		,	a2.idStfAssn [idStfAssn2],	a2.idUser [idUser2], a2.idStfLvl [idStfLvl2], a2.sStaffID [sStaffID2], a2.sStaff [sStaff2], a2.bOnDuty [bOnDuty2]
		,	a3.idStfAssn [idStfAssn3],	a3.idUser [idUser3], a3.idStfLvl [idStfLvl3], a3.sStaffID [sStaffID3], a3.sStaff [sStaff3], a3.bOnDuty [bOnDuty3]
		from	vwRoomBed	rb	with (nolock)
--		left join	tbPatient	pt	with (nolock) on pt.idPatient = rb.idPatient
		left join	vwStfAssn	a1	with (nolock) on a1.idRoom = rb.idRoom	and	a1.tiBed = rb.tiBed	and	a1.idShift = @idShift	and	a1.tiIdx = 1	and	a1.bActive > 0
		left join	vwStfAssn	a2	with (nolock) on a2.idRoom = rb.idRoom	and	a2.tiBed = rb.tiBed	and	a2.idShift = @idShift	and	a2.tiIdx = 2	and	a2.bActive > 0
		left join	vwStfAssn	a3	with (nolock) on a3.idRoom = rb.idRoom	and	a3.tiBed = rb.tiBed	and	a3.idShift = @idShift	and	a3.tiIdx = 3	and	a3.bActive > 0
		where	rb.idUnit = @idUnit
		order	by	rb.sRoom, rb.cBed
end
go
grant	execute				on dbo.prStfAssn_GetByUnit			to [rWriter]
grant	execute				on dbo.prStfAssn_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
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
	@idStfAssn	int							-- null = new
,	@idUnit		smallint					-- unit look-up FK
,	@idRoom		smallint					-- room look-up FK
,	@tiBed		tinyint						-- bed index FK
,	@tiShIdx	tinyint						-- shift index [1..3]
,	@tiIdx		tinyint						-- staff index [1..3]
,	@idUser		int							-- staff look-up FK
,	@bActive	bit							-- active?
,	@cSys		char( 1 )		= null		-- corresponding to idRoom
,	@tiGID		tinyint			= null
,	@tiJID		tinyint			= null
,	@sStaffID	varchar( 16 )	= null		-- corresponding to idUser
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
	declare		@iTrace		int
			,	@idShift	smallint

	set	nocount	on

	select	@idShift= idShift							--	get corresponding shift
		from	tbShift		with (nolock)
		where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx

	if	@idRoom is null
		select	@idRoom= idDevice						--	get corresponding room
			from	vwRoom		with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID		and	tiJID = @tiJID

	if	@idUser is null
		select	@idUser= idUser							--	get corresponding user
			from	tb_User		with (nolock)
			where	bActive > 0		and	sStaffID = @sStaffID

	select	@s=	'SA_IUD( ID=' + isnull(cast(@idStfAssn as varchar),'?') + ' ,idU=' + isnull(cast(@idUnit as varchar),'?') +
			', idR=' + isnull(cast(@idRoom as varchar),'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
			', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
			', ixSt=' + isnull(cast(@tiIdx as varchar),'?') + ', idSt=' + isnull(cast(@idUser as varchar),'?') +
			', bAct=' + isnull(cast(@bActive as varchar),'?')

	if	@tiGID > 0
		select	@s=	@s + ', cS=' + isnull(cast(@cSys as varchar),'?') + ', tiG=' + isnull(cast(@tiGID as varchar),'?') +
					', tiJ=' + isnull(cast(@tiJID as varchar),'?') + ', sSt=' + isnull(cast(@sStaffID as varchar),'?')

	select	@s=	@s + ' )'

	begin tran

		if	@idStfAssn > 0	and	( @bActive = 0	or	@idUser is null )
			exec	dbo.prStfAssn_Fin	@idStfAssn				--	finalize assignment
	
		else
		if	@bActive > 0	and	@idShift > 0	and	@idRoom > 0		and	@tiBed >= 0		and	@tiShIdx > 0	and	@tiIdx > 0	and	@idUser > 0
		begin
			if	@idStfAssn > 0
				if	exists( select 1 from tbStfAssn where idStfAssn = @idStfAssn and idUser <> @idUser )
				begin
					exec	dbo.prStfAssn_Fin	@idStfAssn		--	another staff is assigned - finalize previous one

					select	@idStfAssn= null
				end

			if	@idStfAssn is null
			begin
				insert	tbStfAssn	(  idRoom,  tiBed,  idShift,  tiIdx,  idUser )
						values		( @idRoom, @tiBed, @idShift, @tiIdx, @idUser )
				select	@idStfAssn=	scope_identity( )
				select	@s=	@s + ': ' + cast(@idStfAssn as varchar)
			end
		end
		else
		begin
			select	@s=	@s + ' invalid args'
			exec	pr_Log_Ins	47, null, null, @s
			return	-1
		end

		select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

		if	@iTrace & 0x80 > 0
			exec	dbo.pr_Log_Ins	46, null, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
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
	declare	@dtNow			smalldatetime
	,		@dtDue			smalldatetime
	,		@tNow			time( 0 )
	,		@idStfAssn		int
	,		@idStfCvrg		int

	set	nocount	on

	select	@dtNow= getdate( )		--	smalldatetime truncates seconds
	select	@tNow= @dtNow			--	time(0) truncates date, leaving HH:MM:00

---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	create	table	#tbDueAssn
	(
--		idStfAssn	int not null
		idStfCvrg	int not null
			primary key clustered

	,	idStfAssn	int not null
--	,	idStfCvrg	int not null
	)

	begin tran

		--	mark DB component active (since this sproc is executed every minute)
		exec	pr_Module_Act	1

		--	get assignments that are due to complete now
/*		insert	#tbDueAssn
			select	sa.idStfAssn, sa.idStfCvrg
				from	tbStfAssn	sa	with (nolock)
				join	tbStfCvrg	sc	with (nolock)	on	sc.idStfAssn = sa.idStfAssn
				where	sa.bActive > 0	and	sa.idStfCvrg > 0
				and		sc.dtDue <= @dtNow
*/		insert	#tbDueAssn
			select	sc.idStfCvrg, sc.idStfAssn
				from	tbStfCvrg	sc	with (nolock)
				join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn	and	sa.bActive > 0	and	sa.idStfCvrg > 0	-- = sc.idStfCvrg?
				where	sc.dtEnd is null	and	sc.dtDue <= @dtNow
---		select	*	from	#tbDueAssn

		--	reset assigned staff in completed assignments
		update	rb	set	rb.idAssn1= null, rb.idAssn2= null, rb.idAssn3= null, dtUpdated= @dtNow
			from	tbRoomBed	rb
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		--	finish coverage for completed assignments
		update	sc	set		dtEnd= @dtNow, dEnd= @dtNow, tEnd= @tNow, tiEnd= datepart( hh, @tNow )
			from	tbStfCvrg	sc
			join	#tbDueAssn	da	on	da.idStfAssn = sc.idStfAssn	and	da.idStfCvrg = sc.idStfCvrg
	---		where	sc.dtEnd is null	and	sc.dtDue <= @dtNow

		--	reset coverage refs for completed assignments
		update	sa	set		idStfCvrg= null, dtUpdated= @dtNow
			from	tbStfAssn	sa
			join	#tbDueAssn	da	on	da.idStfAssn = sa.idStfAssn

		--	set current shift for each active unit
		update	u	set	u.idShift= sh.idShift
			from	tbUnit	u
			join	tbShift	sh	on	sh.idUnit = u.idUnit
			where	u.bActive > 0	and	sh.bActive > 0	and	u.idShift <> sh.idShift
				and	(	sh.tBeg <= @tNow	and	@tNow < sh.tEnd
					or	sh.tEnd <= sh.tBeg	and	(sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		--	get assignments that should be started now
		declare	cur		cursor fast_forward for
			select	sa.idStfAssn,
			--		case when	sh.tBeg < sh.tEnd	then	@dtNow - @tNow + sh.tEnd				--	!! this works in 2008 R2, but not in 2012
				---		when	sh.tBeg = sh.tEnd	then	@dtNow - @tNow + sh.tEnd + 1	--	matches else (sh.tBeg > sh.tEnd) case
			--										else	@dtNow - @tNow + sh.tEnd + 1 end
					case when	sh.tBeg < sh.tEnd	then	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime)
													else	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime) + 1 end
				from	tbStfAssn	sa	with (nolock)
				join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		and	sh.bActive > 0
				where	sa.bActive > 0
				and		sa.idStfCvrg is null
				and		(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStfAssn, @dtDue
		while	@@fetch_status = 0
		begin
---			print	cast(@idStfAssn, varchar) + ': ' + cast(@dtDue, varchar)
		
			insert	tbStfCvrg	(  idStfAssn, dtBeg, dBeg, tBeg, tiBeg, dtDue )
					values		( @idStfAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ), @dtDue )
			select	@idStfCvrg=	scope_identity( )
			update	tbStfAssn		set	idStfCvrg= @idStfCvrg, dtUpdated= @dtNow
				where	idStfAssn= @idStfAssn

			fetch next from	cur	into	@idStfAssn, @dtDue
		end
		close	cur
		deallocate	cur

		---	set current assigned staff
		update	rb	set	idAssn1=	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 1	and	sa.bActive > 0
		update	rb	set	idAssn2=	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 2	and	sa.bActive > 0
		update	rb	set	idAssn3=	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 3	and	sa.bActive > 0

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns staff assigned to each room-bed (earliest responders of each kind)
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4920	* tbStaff -> tb_User
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--				* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.00	.tiPtype -> .idStaffLvl
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.04
alter function		dbo.fnStfAssn_GetByShift
(
	@idShift	smallint					-- shift look-up FK
)
	returns table
	with encryption
as
return
	select	r.idRoom, r.tiBed
		,	min(case when r.idStfLvl=4 then a.idUser	else null end)	[idAsnRn]
		,	min(case when r.idStfLvl=4 then s.sStaff	else null end)	[sAsnRn]
		,	min(case when r.idStfLvl=2 then a.idUser	else null end)	[idAsnCn]
		,	min(case when r.idStfLvl=2 then s.sStaff	else null end)	[sAsnCn]
		,	min(case when r.idStfLvl=1 then a.idUser	else null end)	[idAsnAi]
		,	min(case when r.idStfLvl=1 then s.sStaff	else null end)	[sAsnAi]
		from
			(select	sa.idRoom, sa.tiBed, s.idStfLvl, min(sa.tiIdx) tiIdx			-- (earliest responders of each kind)
				from	tbStfAssn sa	with (nolock)
					inner join	tbShift sh	with (nolock)	on	sh.bActive > 0	and	sh.idShift = sa.idShift	and	sh.idShift = @idShift
					inner join	vwStaff	s	with (nolock)	on	s.bActive > 0	and	s.idUser = sa.idUser
				where	sa.bActive > 0
				group	by	sa.idRoom, sa.tiBed, s.idStfLvl)	r
			inner join	tbStfAssn	a	with (nolock)	on	a.bActive > 0	and	a.idRoom = r.idRoom		and	a.tiBed = r.tiBed	and	a.tiIdx = r.tiIdx
			inner join	tbShift		sh	with (nolock)	on	sh.bActive > 0	and	sh.idShift = a.idShift	and	sh.idShift = @idShift
			inner join	vwStaff		s	with (nolock)	on	s.bActive > 0	and	s.idUser = a.idUser	and	s.idStfLvl = r.idStfLvl
		group	by	r.idRoom, r.tiBed
---		order	by	r.idRoom, r.tiBed
go
--	----------------------------------------------------------------------------
--	v.7.03	+ .idRoom
if	not exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbUnitMapCell') and name='idRoom')
begin
	begin tran
		alter table	dbo.tbUnitMapCell	drop constraint	tdUnitMapCell_bSwing
		alter table	dbo.tbUnitMapCell	drop column		bSwing
		alter table	dbo.tbUnitMapCell	add
			idRoom		smallint null				-- device look-up FK
				constraint	fkUnitMapCell_Room	foreign key references tbRoom
	commit
end
go
begin tran
	update	c	set	c.idRoom= r.idRoom
		from	tbUnitMapCell c	with (nolock)
		inner join	tbDevice d	with (nolock)	on	d.cSys = c.cSys	and	d.tiGID = c.tiGID	and	d.tiJID = c.tiJID	and	d.tiRID = 0	and	d.bActive > 0
		inner join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice
commit
go
--	v.7.03	+ .tiRID1, tiBtn1, .tiRID2, .tiBtn2, .tiRID4, .tiBtn4
if	not exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbUnitMapCell') and name='tiRID1')
begin
	begin tran
		alter table	dbo.tbUnitMapCell	add
			tiRID1		tinyint null				-- R-ID for Aide LED
		,	tiBtn1		tinyint null				-- button code (0-31)
		,	tiRID2		tinyint null				-- R-ID for CNA LED
		,	tiBtn2		tinyint null				-- button code (0-31)
		,	tiRID4		tinyint null				-- R-ID for RN LED
		,	tiBtn4		tinyint null				-- button code (0-31)
	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
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
select	b.idBadge	--, b.idBdgType, t.sBdgType
	,	sd.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.sFqStaff
	,	b.idRoom, d.cDevice, d.sDevice, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, b.dtEntered
	,	b.idRcvrCurr, r.sReceiver [sRcvrCurr], b.dtRcvrCurr
	,	b.idRcvrLast, l.sReceiver [sRcvrLast], b.dtRcvrLast
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		inner join	tbDvc	sd	with (nolock)	on	sd.idDvc = b.idBadge
--		inner join	tbRtlsBdgType	t	with (nolock)	on	t.idBdgType = b.idBdgType
		left outer join	vwStaff		s	with (nolock)	on	s.idUser =	sd.idUser
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = b.idRoom
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idRcvrCurr
		left outer join	tbRtlsRcvr	l	with (nolock)	on	l.idReceiver = b.idRcvrLast
go
--	----------------------------------------------------------------------------
--	Returns all badges
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--	7.04.4959	+ .sFqStaff, @bStaff, @bRoom
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.03.4890
alter proc		dbo.prRtlsBadge_GetAll
(
	@bStaff		bit				-- order by: 0= badge, 1=staff
,	@bRoom		bit				-- 0=any, 1=in room
)
	with encryption
as
begin
--	set	nocount	on
	if	@bStaff > 0
		select	idBadge,	idUser, sFqStaff
			,	idRoom, sSGJ + ' [' + cDevice + '] ' + sDevice [sCurrLoc]
			,	dtEntered, cast(getdate( )-dtEntered as time(0)) [tDuration]
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge	with (nolock)
			where	( @bRoom = 0	or	idRoom is not null )
			and		idUser is not null
			order	by	sFqStaff, idBadge
	else
		select	idBadge,	idUser, sFqStaff
			,	idRoom, sSGJ + ' [' + cDevice + '] ' + sDevice [sCurrLoc]
			,	dtEntered, cast(getdate( )-dtEntered as time(0)) [tDuration]
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge	with (nolock)
			where	( @bRoom = 0	or	idRoom is not null )
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge
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
)
	with encryption, exec as owner
as
begin
---	set	nocount	on
	begin tran
		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
			update	tbRtlsBadge		set	bActive= 1, dtUpdated= getdate( )
				where	idBadge = @idBadge
		else
		begin
			set identity_insert	dbo.tbDvc	on

			insert	tbDvc	( idDvc, idDvcType, sDvc )
					values		( @idBadge, 1, 'Badge ' + right('00000000' + cast(@idBadge as varchar), 8) )

			set identity_insert	dbo.tbDvc	off

			insert	tbRtlsBadge	(  idBadge )
					values		( @idBadge )
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Resets location attributes for all badges
--	7.05.5099	+ tb_User.idRoom
--	7.03.4898	* prBadge_ClrAll -> prRtlsBadge_RstLoc
--	6.03
alter proc		dbo.prRtlsBadge_RstLoc
	with encryption
as
begin
	set	nocount	on

	begin tran

		update	tbRtlsRoom	set idBadge= null, bNotify= 1, dtUpdated= getdate( )
		update	tbRtlsBadge	set idRoom= null, dtEntered= getdate( ), idRcvrCurr= null, dtUpdated= getdate( )
		update	tb_User		set	idRoom= null, dtEntered= getdate( )

	commit
end
go
--	----------------------------------------------------------------------------
--	Deactivates all receivers
--	7.05.5087
create proc		dbo.prRtlsRcvr_Init
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin tran
		update	tbRtlsRcvr	set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1

		select	@s= 'Rcvr_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prRtlsRcvr_Init				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Deactivates all badges
--	7.05.5087
create proc		dbo.prRtlsBadge_Init
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin tran
		update	tbRtlsBadge		set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1

		select	@s= 'Badge_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prRtlsBadge_Init				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
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
alter proc		dbo.prDevice_UpdRoomBeds
(
	@idRoom		smallint			-- room id
,	@siBeds		smallint			-- beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
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
			,	@idUnitP	smallint
			,	@idUnitA	smallint
			,	@sRoom		varchar( 16 )
			,	@sDial		varchar( 16 )
	declare		@idDevice	smallint
			,	@tiPriCA0	tinyint
			,	@tiPriCA1	tinyint
			,	@tiPriCA2	tinyint
			,	@tiPriCA3	tinyint
			,	@tiPriCA4	tinyint
			,	@tiPriCA5	tinyint
			,	@tiPriCA6	tinyint
			,	@tiPriCA7	tinyint

	set	nocount	on

	if	not	exists	(select 1 from tbDevice with (nolock) where idDevice = @idRoom and cDevice='R' and bActive>0)
	and	not	exists	(select 1 from tbDevice with (nolock) where idParent = @idRoom and cDevice='W' and bActive>0)	-- and tiStype=26 and tiRID=1
		return	0					--	do room-beds only for rooms and 7967-Ps

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8


	select	@sBeds=	'', @tiBed= 1, @siMask= 1, @sRoom= sDevice, @sDial= sDial
		,	@tiPriCA0= tiPriCA0,	@tiPriCA1= tiPriCA1,	@tiPriCA2= tiPriCA2,	@tiPriCA3= tiPriCA3		--	primary coverage
		,	@tiPriCA4= tiPriCA4,	@tiPriCA5= tiPriCA5,	@tiPriCA6= tiPriCA6,	@tiPriCA7= tiPriCA7
		from	tbDevice	with (nolock)
		where	idDevice = @idRoom

	if	@tiPriCA0 = 0xFF	--or	@tiPriCA1 = 0xFF	or	@tiPriCA2 = 0xFF	or	@tiPriCA3 = 0xFF
--	or	@tiPriCA4 = 0xFF	or	@tiPriCA5 = 0xFF	or	@tiPriCA6 = 0xFF	or	@tiPriCA7 = 0xFF			--	all CAs/Units
		select	top 1 @idUnitP= idUnit
			from	tbUnit		with (nolock)
			order	by	idUnit																				--	pick min unit
	else							--	convert PriCA0 to its unit
		select	@idUnitP= idParent
			from	tbCfgLoc	with (nolock)
			where	idLoc = @tiPriCA0


	select	@tiPriCA0= tiAltCA0,	@tiPriCA1= tiAltCA1,	@tiPriCA2= tiAltCA2,	@tiPriCA3= tiAltCA3		--	alternate coverage
		,	@tiPriCA4= tiAltCA4,	@tiPriCA5= tiAltCA5,	@tiPriCA6= tiAltCA6,	@tiPriCA7= tiAltCA7
		from	tbDevice	with (nolock)
		where	idDevice = @idRoom

	if	@tiPriCA0 = 0xFF	--or	@tiPriCA1 = 0xFF	or	@tiPriCA2 = 0xFF	or	@tiPriCA3 = 0xFF
--	or	@tiPriCA4 = 0xFF	or	@tiPriCA5 = 0xFF	or	@tiPriCA6 = 0xFF	or	@tiPriCA7 = 0xFF			--	all CAs/Units
		select	top 1 @idUnitA= idUnit
			from	tbUnit		with (nolock)
			order	by	idUnit	desc																		--	pick max unit
	else							--	convert AltCA0 to its unit
		select	@idUnitA= idParent
			from	tbCfgLoc	with (nolock)
			where	idLoc = @tiPriCA0


	select	@s= 'Dvc_URB( ' + isnull(cast(@idRoom as varchar), '?') + ', r="' + isnull(@sRoom, '?') + '", d=' + isnull(@sDial, '?') +
				', u1=' + isnull(cast(@idUnitP as varchar), '?') + ', u2=' + isnull(cast(@idUnitA as varchar), '?') +
				', b=' + isnull(cast(@siBeds as varchar), '?') + ' )'

	if	@iTrace & 0x08 > 0
		exec	dbo.pr_Log_Ins	75, null, null, @s

	begin tran

	---	delete	from	tbRoomBed				--	NO: removes patient-to-bed assignments!!
	---		where	idRoom = @idRoom

		if	exists	(select 1 from tbRoom with (nolock) where idRoom = @idRoom)
	--		update	tbRoom	set	idUnit= @idUnitP, dtUpdated= getdate( )					--	7.03
	--			where	idRoom = @idRoom
			exec	dbo.prRoom_Upd		@idRoom, @idUnitP, null, null, null		--	reset	v.7.03
		else
			insert	tbRoom	( idRoom,  idUnit)	--	init staff placeholder for this room	v.7.02, v.7.03
					values	(@idRoom, @idUnitP)

		delete	from	tbRtlsRoom				--	reinit staff presence placeholders		v.7.02
			where	idRoom = @idRoom
		insert	tbRtlsRoom	(idRoom, idStfLvl, bNotify)
				select		@idRoom, idStfLvl, 1
					from	tbStfLvl	with (nolock)

		if	@siBeds = 0					--	no beds in this room
		begin
			--	remove combinations with beds
--	-		exec	prDevice_UpdRoomBeds7980	0, @idRoom, null, @sRoom, @sDial, @idUnitP, @idUnitA
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
			begin
				insert	tbRoomBed	(  idRoom, cBed, tiBed )
						values		( @idRoom, null, 0xFF )
			end
--	-		exec	prDevice_UpdRoomBeds7980	1, @idRoom, ' ', @sRoom, @sDial, @idUnitP, @idUnitA
		end
		else							--	there are beds
		begin
			--	remove combination with no beds
--	-		exec	prDevice_UpdRoomBeds7980	0, @idRoom, ' ', @sRoom, @sDial, @idUnitP, @idUnitA
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF

			while	@siMask < 1024
			begin
				select	@cBedIdx= cast(@tiBed as char(1))

				if	@siBeds & @siMask > 0		--	@tiBed is present in @idRoom
				begin
					update	tbCfgBed	set	bActive= 1, dtUpdated= getdate( )	where	tiBed = @tiBed

					select	@cBed= cBed, @sBeds= @sBeds + cBed
						from	tbCfgBed	with (nolock)
						where	tiBed = @tiBed

					if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = @tiBed)
					begin
						insert	tbRoomBed	(  idRoom,  cBed,  tiBed )
								values		( @idRoom, @cBed, @tiBed )
					end
--	-				exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnitP, @idUnitA
				end
				else							--	@tiBed is absent in @idRoom
				begin
--	-					exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnitP, @idUnitA
						delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = @tiBed
				end

				select	@siMask= @siMask * 2
					,	@tiBed=  case when @tiBed < 9 then @tiBed + 1 else 0 end
			end
		end

		update	tbRoom	set	siBeds= @siBeds, sBeds= @sBeds, tiSvc= null, dtUpdated= getdate( )
			where	idRoom = @idRoom
		update	tbRoomBed	set	tiSvc= null, dtUpdated= getdate( )				--	7.05.5098
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
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge
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
	@idBadge		int					-- 1-65535 (unsigned)
,	@idRcvrCurr		smallint			-- current receiver look-up FK
,	@dtRcvrCurr		datetime			-- when registered by current rcvr
,	@idRcvrLast		smallint			-- last receiver look-up FK
,	@dtRcvrLast		datetime			-- when registered by last rcvr

,	@idRoomPrev		smallint	out		-- previous 790 device look-up FK
,	@idRoomCurr		smallint	out		-- current 790 device look-up FK
,	@dtEntered		datetime	out		-- when entered the room
,	@idStfLvl		tinyint		out		-- 4=RN, 2=CNA, 1=Aide, ..
,	@cSys			char( 1 )	out		-- system
,	@tiGID			tinyint		out		-- G-ID - gateway
,	@tiJID			tinyint		out		-- J-ID - J-bus
,	@tiRID			tinyint		out		-- R-ID - R-bus
)
	with encryption
as
begin
	declare		@iRetVal	smallint
		,		@dtNow		datetime
		,		@idReceiver	smallint
		,		@idOldest	int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@dtNow= getdate( ), @idOldest= null		--, @tiPtype= null, @cSys= null, @tiGID= null, @tiJID= null, @tiRID= null

	if		not	exists( select 1 from tbRtlsBadge with (nolock) where idBadge = @idBadge )
		or	@idRcvrCurr > 0		and	not	exists( select 1 from tbRtlsRcvr with (nolock) where idReceiver = @idRcvrCurr )
		or	@idRcvrLast > 0		and	not	exists( select 1 from tbRtlsRcvr with (nolock) where idReceiver = @idRcvrLast )
	begin
		select	@s=	'Bdg_UL( b=' + isnull(cast(@idBadge as varchar),'?') +
					', cr=' + isnull(cast(@idRcvrCurr as varchar),'?') + ' ' + isnull(convert(varchar, @dtRcvrCurr, 121),'?') +
					', lr=' + isnull(cast(@idRcvrLast as varchar),'?') + ' ' + isnull(convert(varchar, @dtRcvrLast, 121),'?') + ' )'
		exec	pr_Log_Ins	82, null, null, @s

		return	-1		--	?? badge or receiver does not exist !!
	end

	if	@idRcvrCurr = 0		select	@idRcvrCurr= null
	if	@idRcvrLast = 0		select	@idRcvrLast= null

	select	@idReceiver= idRcvrCurr, @idRoomPrev= idRoom, @dtEntered= dtEntered, @idRoomCurr= null
		,	@idStfLvl= idStfLvl, @cSys= cSys, @tiGID= tiGID, @tiJID= tiJID, @tiRID= tiRID		--	previous!!
		from	vwRtlsBadge		where	idBadge = @idBadge

---	select	@s=	@s + ' R=' + isnull(cast(@idReceiver as varchar),'?') + ' P=' + isnull(cast(@idRoomPrev as varchar),'?')
---	exec	pr_Log_Ins	0, null, null, @s

	if	@idReceiver = @idRcvrCurr	return	0		--	badge already at same location => skip

	select	@iRetVal= 1, @idRoomCurr= idRoom		--	new room
		from	tbRtlsRcvr		where	idReceiver = @idRcvrCurr

	begin tran

		if	@idRoomPrev > 0  and  @idRoomCurr is null	or
			@idRoomCurr > 0  and  @idRoomPrev is null	or
			@idRoomCurr <> @idRoomPrev				--	badge moved [to another room]
		begin
			--	set new location
			update	tbRtlsBadge		set	idRoom= @idRoomCurr, dtEntered= @dtNow, @dtEntered= @dtNow
				where	idBadge = @idBadge

			--	set user location
			update	u	set	idRoom= @idRoomCurr, dtEntered= @dtNow
				from	tb_User		u
				join	tbDvc		d	on	d.idUser = u.idUser
			--	join	tbRtlsBadge	b	on	b.idBadge = d.idDvc
				where	d.idDvc = @idBadge

			--	remove this badge from any room
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= null
				where	idBadge = @idBadge

			--	set for current room [if first]
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= @idBadge
				where	idRoom = @idRoomCurr	and	idStfLvl = @idStfLvl	and	idBadge is null

			--	get oldest badge of same type for prev room
			select	top 1	@idOldest= idBadge
				from	vwRtlsBadge	with (nolock)
				where	idRoom = @idRoomPrev	and	idStfLvl = @idStfLvl	---	and	idBadge is not null		--	not necessary!
				order	by	dtEntered

			--	remove that oldest from any room
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= null
				where	idBadge = @idOldest

			--	set prev room to the oldest badge
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= @idOldest
				where	idRoom = @idRoomPrev	and	idStfLvl = @idStfLvl

			select	@cSys= null, @tiGID= null, @tiJID= null, @tiRID= null, @iRetVal= 2

			select	@cSys= cSys, @tiGID= tiGID, @tiJID= tiJID, @tiRID= tiRID
				from	tbDevice	with (nolock)
				where	idDevice = @idRoomCurr
		end

		update	tbRtlsBadge		set	dtUpdated= @dtNow
			,	idRcvrCurr= @idRcvrCurr, dtRcvrCurr= @dtRcvrCurr
			,	idRcvrLast= @idRcvrLast, dtRcvrLast= @dtRcvrLast
			where	idBadge = @idBadge

	commit

	return	@iRetVal
end
go
--	----------------------------------------------------------------------------
--	Rooms 'presense' state (oldest badges)
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
	,	min(case when r.idStfLvl=4 then sd.idUser	else null end)	[idRn]
	,	min(case when r.idStfLvl=4 then s.sStaff	else null end)	[sRn]
	,	min(case when r.idStfLvl=2 then sd.idUser	else null end)	[idCn]
	,	min(case when r.idStfLvl=2 then s.sStaff	else null end)	[sCn]
	,	min(case when r.idStfLvl=1 then sd.idUser	else null end)	[idAi]
	,	min(case when r.idStfLvl=1 then s.sStaff	else null end)	[sAi]
	,	max(cast(r.bNotify as tinyint))							[tiNotify]
	,	min(r.dtUpdated)										[dtUpdated]
	from	tbRtlsRoom		r	with (nolock)
		inner join	tbDevice		d	with (nolock)	on	d.idDevice = r.idRoom
		left outer join	tbRtlsBadge	b	with (nolock)	on	b.idBadge = r.idBadge
		left outer join	tbDvc	sd	with (nolock)	on	sd.idDvc = b.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idUser = sd.idUser
	group by	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
go
--	----------------------------------------------------------------------------
--	Data source for 7985
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
,	@idMaster	smallint			-- master console, null=global mode
)
	with encryption
as
begin
--	declare		@s			varchar( 400 )

--	set	nocount on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)

/*	if	@sUnits = '*'	or	@sUnits is null
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
*/
	exec	dbo.prUnit_SetTmpFlt	@sUnits

	set	nocount off
	if	@tiView = 0			--	ListView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
--			,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
	--		,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
			,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
			,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
	--		,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
--			,	r.idRn [idRegRn], r.sRn [sRegRn],	r.idCn [idRegCn], r.sCn [sRegCn],	r.idAi idRegAi, r.sAi [sRegAi]
			,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
			,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
			,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
			,	cast(null as tinyint) [tiMap]
	--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
			from	vwEvent_A		ea	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = ea.idUnit
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 255 )	--	and	ea.tiBed is null
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
	--			left join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
	--			left join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )			--	7.03
				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
--			,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
	--		,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
			,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
			,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
--			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
			,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
			,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
			,	cast(null as tinyint) [tiMap]
			from	vwRoomBed		rb	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
				outer apply	fnEventA_GetTopByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster, 0 )	ea		--	7.03
--				left join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
--				left join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
--			,	cast(null as int) [idPatient], cast(null as varchar(16)) [sPatient], cast(null as char(1)) [cGender]
--				,	cast(null as varchar(16)) [sInfo], cast(null as varchar(255)) [sNote], cast(null as int) [idDoctor], cast(null as varchar(16)) [sDoctor]
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
	--		,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
			,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
			,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
	--		,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
--			,	r.idRn [idRegRn], r.sRn [sRegRn],	r.idCn [idRegCn], r.sCn [sRegCn],	r.idAi idRegAi, r.sAi [sRegAi]
			,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
			,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
			,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
			,	mc.tiMap
			from	#tbUnit			tu	with (nolock)
				outer apply	fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea									--	7.03
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 255 )	--	and	ea.tiBed is null
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
				outer apply	fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
			order	by	tu.sUnit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
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
		,	r.idDevice [idRoom], r.sDevice [sRoom], ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
--		,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
		,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
		,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
--		,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
--		,	r.idRn [idRegRn], r.sRn [sRegRn],	r.idCn [idRegCn], r.sCn [sRegCn],	r.idAi [idRegAi], r.sAi [sRegAi]
		,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
		,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
		,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
		,	mc.tiMap, mc.tiCell, mc.sCell1, mc.sCell2, r.siBeds, r.sBeds	-- rr.siBeds, rr.sBeds
		,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	tbUnitMapCell		mc	with (nolock)
			inner join	tbUnit		u	with (nolock)	on	u.idUnit = mc.idUnit
			left join	vwRoom		r	with (nolock)
				on	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0		and	r.bActive > 0
	--		left join	tbRoom		rr	with (nolock)	on	rr.idRoom = r.idDevice
			outer apply	fnEventA_GetTopByRoom( mc.cSys, mc.tiGID, mc.tiJID, null, @iFilter, @idMaster, 1 )	ea		--	7.03
			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 255 )	--	and	ea.tiBed is null
--			left join	vwStaff		rn	with (nolock)	on	rn.idUser = r.idReg4
--			left join	vwStaff		cn	with (nolock)	on	cn.idUser = r.idReg2
--			left join	vwStaff		ai	with (nolock)	on	ai.idUser = r.idReg1
--			left join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
--			left join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		where	mc.idUnit = @idUnit
			and	mc.tiMap = @tiMap
		order	by	mc.tiMap, mc.tiCell
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

	if	exists(	select 1 from tb_UserRole where idUser = @idUser and idRole = 2 )

		select	idFilter, idUser, sFilter		--, xFilter
			from	tbFilter	with (nolock)
	--		where	idUser is null
	--			or	idUser = @idUser
			order	by	idUser, sFilter
	else
		select	idFilter, idUser, sFilter		--, xFilter
			from	tbFilter	with (nolock)
			where	idUser is null
				or	idUser = @idUser
			order	by	idUser, sFilter
end
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing filter
--	7.05.5044	* @idUser: smallint -> int
--	7.03
alter proc		dbo.prFilter_InsUpd
(
	@idFilter	smallint out
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
	select	@id= idFilter
		from	tbFilter
		where	(idUser = @idUser	or	@idUser is null	and	idUser is null)
			and	sFilter = @sFilter

	if	@id <> @idFilter	return	-1		-- name is already in use

	begin tran

		if	@idFilter > 0
		begin
			update	tbFilter	set	idUser= @idUser, sFilter= @sFilter, xFilter= @xFilter, dtUpdated= getdate( )
				where	idFilter = @idFilter
		end
		else
		begin
			insert	tbFilter	(  idUser,  sFilter,  xFilter )
					values		( @idUser, @sFilter, @xFilter )
			select	@idFilter=	scope_identity( )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Report staff filters (active during a user session)
--	7.05.5010	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser
--	7.04.4919	.idStaff: FK -> tb_User
--	6.02
create table	dbo.tb_SessUser
(
	idSess		int not null
		constraint	fk_SessUser_Sess	foreign key references tb_Sess
,	idUser		int not null				-- staff look-up FK
		constraint	fk_SessUser_User	foreign key references tb_User
	
,	constraint	xp_SessUser		primary key clustered ( idSess, idUser )
)
go
grant	select, insert, update, delete	on dbo.tb_SessUser		to [rWriter]		--	7.03
grant	select, insert, update, delete	on dbo.tb_SessUser		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's staff filter
--	7.05.5010	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser
--	7.05.4980	* -- nocount
--	7.03
create proc		dbo.pr_SessUser_Ins
(
	@idSess		int
,	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	begin tran

		insert	tb_SessUser		(  idSess,  idUser )
				values			( @idSess, @idUser )
	commit
end
go
grant	execute				on dbo.pr_SessUser_Ins				to [rWriter]
grant	execute				on dbo.pr_SessUser_Ins				to [rReader]
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
	begin tran

		insert	tb_SessShift	(  idSess,  idShift )
				values			( @idSess, @idShift )
	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans-up session's filter tables
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
	begin tran

		delete from	tb_SessUser		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessShift	where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessCall		where	idSess = @idSess	or	@idSess is null
--	-	delete from	tb_SessLoc		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessDvc		where	idSess = @idSess	or	@idSess is null

	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans-up a session
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
	@idSess		int
,	@bLog		bit=	1	--	log logout (for individual session)?
)
	with encryption
as
begin
	declare		@idUser		smallint
	declare		@sIpAddr	varchar( 40 )
	declare		@sMachine	varchar( 32 )
	declare		@tiTout		tinyint
	declare		@dtLastAct	datetime

	set	nocount	on
	begin tran

		if	@idSess > 0		-- sess-end
		begin
			if	@bLog > 0
			begin
				select	@tiTout= cast( iValue as tinyint )	from	tb_OptSys	where	idOption = 1
				select	@idUser= idUser, @sIpAddr= sIpAddr, @sMachine= sMachine, @dtLastAct= dtLastAct
					from	tb_Sess
					where	idSess = @idSess
				select	@tiTout=	case when dateadd( ss, -10, dateadd( mi, @tiTout, @dtLastAct ) ) < getdate( ) then 230 else 229 end
				exec	dbo.pr_User_Logout	@idSess, @tiTout, @idUser, @sIpAddr, @sMachine
			end

			exec	dbo.pr_Sess_Clr		@idSess
			delete from	tb_Sess			where	idSess = @idSess
		end
		else				-- app-end
		begin
			declare	cur		cursor fast_forward for
				select	idUser, sIpAddr, sMachine
					from	tb_Sess

			open	cur
			fetch next from	cur	into	@idUser, @sIpAddr, @sMachine
			while	@@fetch_status = 0
			begin
				exec	dbo.pr_User_Logout	@idSess, 230, @idUser, @sIpAddr, @sMachine
			
				fetch next from	cur	into	@idUser, @sIpAddr, @sMachine
			end
			close	cur
			deallocate	cur

			exec	dbo.pr_Sess_Clr		null
			delete from	tb_Sess
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns a list of schedules, waiting to be executed
--	7.05.4980	* u.sFirst + ' ' + u.sLast -> u.sStaff
--	7.03
alter proc		dbo.prSchedule_GetToRun
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, dtLastRun, dtNextRun		--, iResult
		,	s.idUser [idAuthor], u.sStaff [sAuthor], s.idReport, s.sSendTo	--, bActive, dtCreated, dtUpdated
		,	s.idFilter, f.idUser, f.sFilter, f.xFilter
		from	tbSchedule	s	with (nolock)
		inner join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		inner join	tb_User u	with (nolock)	on	u.idUser = s.idUser
		where	s.bActive > 0	and	s.dtNextRun < getdate( )
end
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing schedule
--	7.05.5044	* @idUser: smallint -> int
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.prSchedule_InsUpd
(
	@idSchedule	smallint out
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
,	@sSendTo	varchar( 255 )		-- list of recipient emails
,	@bActive	bit
)
	with encryption
as
begin
	declare		@id		smallint

--	set	nocount	on

	-- check that filter name is unique per user
--	select	@id= idSchedule
--		from	tbSchedule
--		where	sSchedule = @sSchedule

--	if	@id <> @idSchedule	return	-1		-- schedule already exists

	begin tran

		if	@idSchedule > 0
		begin
			update	tbSchedule	set	tiRecur= @tiRecur, tiWkDay= @tiWkDay, siMonth= @siMonth, sSchedule= @sSchedule
				,	dtNextRun= @dtNextRun, idUser= @idUser		--, dtLastRun= @dtLastRun, iResult= @iResult
				,	idFilter= @idFilter, idReport= @idReport, sSendTo= @sSendTo, bActive= @bActive, dtUpdated= getdate( )
				where	idSchedule = @idSchedule
		end
		else
		begin
			insert	tbSchedule	(  tiRecur,  tiWkDay,  siMonth,  sSchedule,  dtNextRun,  idUser,  idFilter,  idReport,  sSendTo )	--,  dtLastRun,  iResult
					values		( @tiRecur, @tiWkDay, @siMonth, @sSchedule, @dtNextRun, @idUser, @idFilter, @idReport, @sSendTo )	--, @dtLastRun, @iResult
			select	@idSchedule=	scope_identity( )
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
	@idSchedule	smallint out
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
--	declare		@id		smallint

--	set	nocount	on

	-- check that filter name is unique per user
--	select	@id= idSchedule
--		from	tbSchedule
--		where	sSchedule = @sSchedule

--	if	@id <> @idSchedule	return	-1		-- schedule already exists

	begin tran

		update	tbSchedule	set	dtLastRun= @dtLastRun, dtNextRun= @dtNextRun, iResult= @iResult
			where	idSchedule = @idSchedule
	commit
end
go
--	----------------------------------------------------------------------------
--	Deletes an existing schedule
--	7.05.4980	* -- nocount
--	7.03
alter proc		dbo.prSchedule_Del
(
	@idSchedule	smallint out
)
	with encryption
as
begin
--	set	nocount	on

	begin tran

		delete	from	tbSchedule
			where	idSchedule = @idSchedule
	commit
end
go
--	----------------------------------------------------------------------------
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
			,	e.idCmd, k.sCmd, e.tiBtn, e.sRoom, b.cBed	--, e.idRoom, e.tiBed
			,	e.idLogType, e.sLogType, e.idCall
			,	case when e.idLogType > 0 then e.sLogType else k.sCmd end +
				case when e95.idEvent > 0 then ' ' +
					case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
					else '' end	[sEvent]
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc	--, e.sSrcDial
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case when e41.idEvent > 0 then pd.sFqDvc else e.sDstDvc end	[sDstDvc]
	--		,	case when e41.idEvent > 0 then pt.sPcsType else e.sInfo end	[sInfo]
			,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
					case when ec.idUser > 0 then u.sFqStaff else e.sInfo end end	[sInfo]
	--		,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)		[siIdx]
			,	case when e.idCmd > 0 then e.sCall else k.sCmd end	[sCall]
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u	with (nolock)	on	u.idUser = ec.idUser
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
			left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
			left join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
			left join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
	---		where	e.dEvent	between @dFrom	and @dUpto
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else if	@tiDvc = 1
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent, e.tiHH
			,	e.idCmd, k.sCmd, e.tiBtn, e.sRoom, b.cBed	--, e.idRoom, e.tiBed
			,	e.idLogType, e.sLogType, e.idCall
			,	case when e.idLogType > 0 then e.sLogType else k.sCmd end +
				case when e95.idEvent > 0 then ' ' +
					case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
					else '' end	[sEvent]
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc	--, e.sSrcDial
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case when e41.idEvent > 0 then pd.sFqDvc else e.sDstDvc end	[sDstDvc]
	--		,	case when e41.idEvent > 0 then pt.sPcsType else e.sInfo end	[sInfo]
			,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
					case when ec.idUser > 0 then u.sFqStaff else e.sInfo end end	[sInfo]
	--		,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)		[siIdx]
			,	case when e.idCmd > 0 then e.sCall else k.sCmd end	[sCall]
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			join		tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u	with (nolock)	on	u.idUser = ec.idUser
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
			left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
			left join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
			left join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent, e.tiHH
			,	e.idCmd, k.sCmd, e.tiBtn, e.sRoom, b.cBed	--, e.idRoom, e.tiBed
			,	e.idLogType, e.sLogType, e.idCall
			,	case when e.idLogType > 0 then e.sLogType else k.sCmd end +
				case when e95.idEvent > 0 then ' ' +
					case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
					else '' end	[sEvent]
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc	--, e.sSrcDial
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case when e41.idEvent > 0 then pd.sFqDvc else e.sDstDvc end	[sDstDvc]
	--		,	case when e41.idEvent > 0 then pt.sPcsType else e.sInfo end	[sInfo]
			,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
					case when ec.idUser > 0 then u.sFqStaff else e.sInfo end end	[sInfo]
	--		,	e.sInfo
			,	coalesce(e84.siIdxNew, e8A.siIdx, e99.siIdxNew)		[siIdx]
			,	case when e.idCmd > 0 then e.sCall else k.sCmd end	[sCall]
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			left join	tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u	with (nolock)	on	u.idUser = ec.idUser
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
			left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
			left join	tbEvent98	e98	with (nolock)	on	e98.idEvent = e.idEvent
			left join	tbEvent99	e99	with (nolock)	on	e99.idEvent = e.idEvent
			where	e.idEvent	between @idFrom	and @idUpto
				and	e.tiHH		between @tFrom	and @tUpto
				and	(e.idSrcDvc in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcDvc is null)
			order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
		select	t.*	--, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg
			,	case when t.tVoAvg is null then null else t.lVoOnT*100/(t.lCount-t.lVoNul) end fVoOnT
			,	case when t.tStAvg is null then null else t.lStOnT*100/(t.lCount-t.lStNul) end fStOnT
		--	,	f.tVoMax, f.tStMax, t.lVoOut*100/t.lCount fVoOut, t.lStOut*100/t.lCount fStOut
			from
				(select	c.idCall, count(*) lCount
--					,	min(f.siIdx) siIdx, min(f.sCall) sCall, min(f.tVoTrg) tVoTrg, min(f.tStTrg) tStTrg
					,	min(c.siIdx) siIdx, min(c.sCall) sCall, min(c.tVoTrg) tVoTrg, min(c.tStTrg) tStTrg
					,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) ) tVoAvg
	--				,	cast(dateadd(ss, avg( datepart(mi,c.tVoice)*60+datepart(ss,c.tVoice)+1 ), '0:0:0') as time(0)) tVoAvg
					,	max(c.tVoice) tVoMax
					,	sum(case when c.tVoice < c.tVoTrg then 1 else 0 end) lVoOnT
		--			,	sum(case when c.tVoice > f.tVoMax then 1 else 0 end) lVoOut
					,	sum(case when c.tVoice is null then 1 else 0 end) lVoNul
					,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) ) tStAvg
	--				,	cast(dateadd(ss, avg( datepart(mi,c.tStaff)*60+datepart(ss,c.tStaff)+1 ), '0:0:0') as time(0)) tStAvg
					,	max(c.tStaff) tStMax
					,	sum(case when c.tStaff < c.tStTrg then 1 else 0 end) lStOnT
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
--				from			tbEvent_C	c	with (nolock)
--					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
				from	(select	c.idCall, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg, c.tVoice, c.tStaff
							,	case when p.tiSpec = 7 then	tStaff else null end	[tRn]
							,	case when p.tiSpec = 8 then	tStaff else null end	[tCn]
							,	case when p.tiSpec = 9 then	tStaff else null end	[tAi]
							from			tbEvent_C	c	with (nolock)
								inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
								inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
							where	c.idEvent	between @idFrom	and @idUpto
								and	c.tiHH		between @tFrom	and @tUpto)	c	--with (nolock)
--				where	c.idEvent	between @idFrom	and @idUpto
--					and	c.tiHH		between @tFrom	and @tUpto
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
--					,	min(f.siIdx) siIdx, min(f.sCall) sCall, min(f.tVoTrg) tVoTrg, min(f.tStTrg) tStTrg
					,	min(c.siIdx) siIdx, min(c.sCall) sCall, min(c.tVoTrg) tVoTrg, min(c.tStTrg) tStTrg
					,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) ) tVoAvg
					,	max(c.tVoice) tVoMax
					,	sum(case when c.tVoice < c.tVoTrg then 1 else 0 end) lVoOnT
		--			,	sum(case when c.tVoice > f.tVoMax then 1 else 0 end) lVoOut
					,	sum(case when c.tVoice is null then 1 else 0 end) lVoNul
					,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) ) tStAvg
					,	max(c.tStaff) tStMax
					,	sum(case when c.tStaff < c.tStTrg then 1 else 0 end) lStOnT
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
--				from			tbEvent_C	c	with (nolock)
--					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
--					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
				from	(select	c.idCall, f.siIdx, f.sCall, f.tVoTrg, f.tStTrg, c.tVoice, c.tStaff
							,	case when p.tiSpec = 7 then	tStaff else null end	[tRn]
							,	case when p.tiSpec = 8 then	tStaff else null end	[tCn]
							,	case when p.tiSpec = 9 then	tStaff else null end	[tAi]
							from			tbEvent_C	c	with (nolock)
								inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
								inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
								inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
							where	c.idEvent	between @idFrom	and @idUpto
								and	c.tiHH		between @tFrom	and @tUpto)	c	--with (nolock)
--				where	c.idEvent	between @idFrom	and @idUpto
--					and	c.tiHH		between @tFrom	and @tUpto
				group	by c.idCall--, sCall
				)	t
		--		inner join	tb_SessCall f	on	f.idCall = t.idCall	and	f.idSess = @idSess
			order by	t.siIdx desc		--lCount desc
end
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 255=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@cBed		char( 1 )			-- 0=any/none, >0 =specific
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
		if	@cBed is null
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall
		--		,	c.tVoice, c.tStaff	--, c.tRn, c.tCn, c.tAi
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tRn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tCn]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tAi]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				order	by	c.sDevice, c.idEvent
		else
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall
		--		,	c.tVoice, c.tStaff	--, c.tRn, c.tCn, c.tAi
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tRn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tCn]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tAi]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
					and	(c.cBed = @cBed	or	c.cBed is null)
				order	by	c.sDevice, c.idEvent
	else
		if	@cBed is null
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall
		--		,	c.tVoice, c.tStaff	--, c.tRn, c.tCn, c.tAi
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tRn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tCn]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tAi]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				order	by	c.sDevice, c.idEvent
		else
			select	c.idEvent, c.idRoom, c.sDevice, c.sDial, c.dEvent, c.tEvent, c.cBed, c.idCall, c.sCall
		--		,	c.tVoice, c.tStaff	--, c.tRn, c.tCn, c.tAi
				,	case when p.tiSpec between 7 and 9	then	null else c.tVoice end	[tVoice]
				,	case when p.tiSpec between 7 and 9	then	null else c.tStaff end	[tStaff]
				,	case when p.tiSpec = 7				then	c.tStaff else null end	[tRn]
				,	case when p.tiSpec = 8				then	c.tStaff else null end	[tCn]
				,	case when p.tiSpec = 9				then	c.tStaff else null end	[tAi]
				from			vwEvent_C	c	with (nolock)
					inner join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					inner join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
					and	(c.cBed = @cBed	or	c.cBed is null)
				order	by	c.sDevice, c.idEvent
end
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 255=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@cBed		char( 1 )			-- null=any/none, >0 =specific
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 255
		if	@cBed is null
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
		--		,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else e.sInfo end	[sInfo]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
		else
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
		--		,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else e.sInfo end	[sInfo]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
						and		(t.cBed = @cBed	or	t.cBed is null)
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
	else
		if	@cBed is null
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
		--		,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else e.sInfo end	[sInfo]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = t.idRoom
						join	tb_SessCall f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
		else
			select	s.idRoom, s.cDevice, s.sDevice, s.sDial, e.idParent, e.tParent, e.idOrigin
				,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
				,	s.cBed, e.tiBed, e.idLogType, t.sLogType
				,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
						when e41.idEvent > 0 then pd.sFqDvc
						when e95.idEvent > 0 then
							case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
							case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
							case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
							case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
						end		[sEvent]
				,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
		--		,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else e.sInfo end	[sInfo]
				,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
						case when s.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
				,	d.sDoctor, p.sPatient
				from
					(select	t.idEvent idParent, t.idRoom, t.cBed, t.cDevice, t.sDevice, t.sDial, t.idUser	--, c.dEvent, c.tEvent, c.idCall, c.sCall
						from	vwEvent_C	t	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = t.idRoom
						join	tb_SessCall	f	with (nolock)	on	f.idCall = t.idCall	and	f.idSess = @idSess
						where	t.idEvent	between @idFrom	and @idUpto
						and		t.tiHH		between @tFrom	and @tUpto
						and		(t.cBed = @cBed	or	t.cBed is null)
					)	s
			--		join		tbEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		vwEvent		e	with (nolock)	on	e.idParent = s.idParent
					join		tb_LogType	t	with (nolock)	on	t.idLogType = e.idLogType
					left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
					left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
					left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
					left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
					left join	vwStaff		u2	with (nolock)	on	u2.idUser = s.idUser
					left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
end
go
--	----------------------------------------------------------------------------
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
create proc		dbo.prRptStfAssn
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 255=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 255=any, 1=specific (tb_SessUser), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 255
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
	else
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
				---	where	c.dEvent between @dFrom and @dUpto		--	ignore for this report
				---		and	c.tiHH between @tFrom and @tUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
end
go
grant	execute				on dbo.prRptStfAssn					to [rWriter]		--	7.03
grant	execute				on dbo.prRptStfAssn					to [rReader]
go
--	----------------------------------------------------------------------------
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
create proc		dbo.prRptStfCvrg
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 255=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 255=any, 1=specific (tb_SessUser), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 255
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
				--	,	a.idShift, h.idUser, h.tiIdx [tiShift], a.idStaffAssn, a.dtCreated, a.dtUpdated
		--		select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
		--			,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idUser, s.sStaffID, s.sStaff, s.sStfLvl
				--	,	a.idShift, h.idUser, h.tiIdx [tiShift], a.idStaffAssn, a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
	else
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
					from	tbStfAssn		a	with (nolock)
					join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, p.idStfCvrg
end
go
grant	execute				on dbo.prRptStfCvrg					to [rWriter]		--	7.03
grant	execute				on dbo.prRptStfCvrg					to [rReader]
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='Access')
begin
exec( 'update	dbo.Access	set	SecurityLevel= ''Admins''
		where	ID = 1
' )
end
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='ArchitecturalConfig')
	drop view	dbo.ArchitecturalConfig
go
create view		dbo.ArchitecturalConfig
	with encryption
as
select	cast(idLoc as int)		[ID]
	,	sLoc					[Name]
	,	cast(idParent as int)	[Parent_ID]
--	,	tiLvl, cLoc
	,	case
			when tiLvl = 0 then 'Facility'
			when tiLvl = 1 then 'System'
			when tiLvl = 2 then 'Bldg'
			when tiLvl = 3 then 'Floor'
			when tiLvl = 4 then 'Unit'
			when tiLvl = 5 then 'CArea'
		end			[ArchitecturalLevel]
	from	dbo.tbCfgLoc	with (nolock)
go
grant	select							on dbo.ArchitecturalConfig	to [rWriter]
grant	select							on dbo.ArchitecturalConfig	to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='BedDefinition')
	drop view	dbo.BedDefinition
go
create view		dbo.BedDefinition
	with encryption
as
select	cast(tiBed as int)	[BedDefinitionID]
	,	cBed	[Designator]
	,	cDial	[DialableNumber]
	from	dbo.tbCfgBed	with (nolock)
go
grant	select							on dbo.BedDefinition	to [rWriter]
grant	select							on dbo.BedDefinition	to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='Staff')
	drop view	dbo.Staff
go
create view		dbo.Staff
	with encryption
as
select	sStaffID	[ID]
	,	sLast		[LastName]
	,	sMidd		[MiddleName]
	,	sFrst		[FirstName]
	,	bActive		[Active]
	,	l.sStfLvl	[StaffRole]
	,	sDesc		[AccessLevel]
	,	sUser		[UserName]
	,	sEmail		[Password]
	,	sUnits		[Units]
	,	dtUpdated	[dtUpdate]
	,	idUser		[tempID]
	,	sBarCode
	,	bOnDuty
	from	dbo.tb_User		u	with (nolock)
	join	dbo.tbStfLvl	l	with (nolock)	on	l.idStfLvl = u.idStfLvl
go
grant	select, update					on dbo.Staff			to [rWriter]
grant	select, update					on dbo.Staff			to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='Units')
	drop view	dbo.Units
go
create view		dbo.Units
	with encryption
as
select	isnull(cast(u.idUnit as int),0) [ID], u.sUnit [Name], cast(u.tiShifts as int) [ShiftsPerDay]
	,	cast(s1.tiRouting as int) [CustomRoutingShift1], cast(s1.tiNotify as int) as [NotificationModeShift1]
	,		cast(s1.tBeg as varchar) [StartTimeShift1], cast(s1.tEnd as varchar) [EndTimeShift1],	isnull(t1.sStaffID, '') [BackupStaffIDShift1]
	,	cast(s2.tiRouting as int) [CustomRoutingShift2], cast(s2.tiNotify as int) as [NotificationModeShift2]
	,		cast(s2.tBeg as varchar) [StartTimeShift2], cast(s2.tEnd as varchar) [EndTimeShift2],	isnull(t2.sStaffID, '') [BackupStaffIDShift2]
	,	cast(s3.tiRouting as int) [CustomRoutingShift3], cast(s3.tiNotify as int) as [NotificationModeShift3]
	,		cast(s3.tBeg as varchar) [StartTimeShift3], cast(s3.tEnd as varchar) [EndTimeShift3],	isnull(t3.sStaffID, '') [BackupStaffIDShift3]
	,	u.dtUpdated [dtUpdate], cast(0 as int) [DownloadCounter]
	from	dbo.tbUnit	u	with (nolock)
	left outer join	dbo.tbShift	s1	with (nolock)	on	u.idUnit = s1.idUnit	and	s1.tiIdx = 1	and	s1.bActive > 0
	left outer join	dbo.tb_User	t1	with (nolock)	on	t1.idUser = s1.idUser
	left outer join	dbo.tbShift	s2	with (nolock)	on	u.idUnit = s2.idUnit	and	s2.tiIdx = 2	and	s2.bActive > 0
	left outer join	dbo.tb_User	t2	with (nolock)	on	t2.idUser = s2.idUser
	left outer join	dbo.tbShift	s3	with (nolock)	on	u.idUnit = s3.idUnit	and	s3.tiIdx = 3	and	s3.bActive > 0
	left outer join	dbo.tb_User	t3	with (nolock)	on	t3.idUser = s3.idUser
	where	u.idUnit > 0		--	exclude internal unit
go
grant	select, update					on dbo.Units			to [rWriter]
grant	select, update					on dbo.Units			to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='StaffRole')
	drop view	dbo.StaffRole
go
create view		dbo.StaffRole
	with encryption
as
select	sStfLvl		[Role]
	,	cast(iColorB as varchar)	[Level]
	,	idStfLvl	[ID]
	from	dbo.tbStfLvl	with (nolock)
go
grant	select							on dbo.StaffRole		to [rWriter]
grant	select							on dbo.StaffRole		to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='Team')
	drop view	dbo.Team
go
create view		dbo.Team
	with encryption
as
select	sTeam		[Name]
	,	p.siIdx
	,	c.sCall		[CallPriority]
	,	0			[CallPriorityMode]
	,	''			[GroupID]
	,	tResp
	,	substring( convert( varchar(8), tResp, 8 ), 4, 5 )	[Timer]
	,	sDesc		[Units]
	,	t.idTeam	[ID]
	,	t.bActive	[Active]
	from	dbo.tbTeam	t	with (nolock)
	left outer join	dbo.tbTeamPri	p	with (nolock)	on	p.idTeam = t.idTeam
	left outer join	dbo.tbCall		c	with (nolock)	on	c.siIdx = p.siIdx	and	c.bActive > 0
go
grant	select, update					on dbo.Team				to [rWriter]
grant	select, update					on dbo.Team				to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='Device')
	drop view	dbo.Device
go
create view		dbo.Device
	with encryption
as
select	sDvcType	[Type]
	,	sDial		[ExtensionID]
	,	sDvc		[Description]
	,	sUnits		[Units]
	,	bActive		[Active]
--	,	2			[LinesPerMsg]
--	,	18			[CharsPerLine]
	,	cast(tiFlags & 1 as bit)	[GroupID]
	,	cast((tiFlags & 2)/2 as bit)	[TechNotifications]
	,	idDvc		[ID]
	,	sBarCode
	,	sFqStaff
	from	dbo.vwDvc	with (nolock)
	where	idDvcType > 1
go
grant	select, update					on dbo.Device			to [rWriter]
grant	select, update					on dbo.Device			to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='StaffToPatientAssignment')
	drop view	dbo.StaffToPatientAssignment
go
create view		dbo.StaffToPatientAssignment
	with encryption
as
select	rb.idRoom, rb.tiBed
	,	d.sDial		[RoomNumber]
	,	case when rb.tiBed = 255 then '' else cast(rb.tiBed as varchar) end	[BedIndex]
	,	d.sDevice	[RoomName]
	,	a11.idStfAssn	id11,	isnull( a11.sStaffID, '' )	[FirstRspndrIDShift1]
	,	a12.idStfAssn	id12,	isnull( a12.sStaffID, '' )	[SecondRspndrIDShift1]
	,	a13.idStfAssn	id13,	isnull( a13.sStaffID, '' )	[ThirdRspndrIDShift1]
	,	a21.idStfAssn	id21,	isnull( a21.sStaffID, '' )	[FirstRspndrIDShift2]
	,	a22.idStfAssn	id22,	isnull( a22.sStaffID, '' )	[SecondRspndrIDShift2]
	,	a23.idStfAssn	id23,	isnull( a23.sStaffID, '' )	[ThirdRspndrIDShift2]
	,	a31.idStfAssn	id31,	isnull( a31.sStaffID, '' )	[FirstRspndrIDShift3]
	,	a32.idStfAssn	id32,	isnull( a32.sStaffID, '' )	[SecondRspndrIDShift3]
	,	a33.idStfAssn	id33,	isnull( a33.sStaffID, '' )	[ThirdRspndrIDShift3]
	,	r.idUnit	[PrimaryUnitID]
	,	0			[SecondaryUnitID]
	,	rb.dtUpdated	[dtUpdate]
	,	rb.idRoom * 10 + case when rb.tiBed = 255 then 0 else rb.tiBed end	[TempID]
	,	0			[DownloadCounter]
	from	dbo.tbRoomBed	rb	with (nolock)
	join	dbo.vwDevice	d	with (nolock)	on	d.idDevice = rb.idRoom
	join	dbo.vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
	left join	dbo.vwStfAssn	a11	with (nolock)	on	a11.idRoom = rb.idRoom	and	a11.tiBed = rb.tiBed	and	a11.tiShIdx = 1		and	a11.tiIdx = 1	and	a11.bActive > 0
	left join	dbo.vwStfAssn	a12	with (nolock)	on	a12.idRoom = rb.idRoom	and	a12.tiBed = rb.tiBed	and	a12.tiShIdx = 1		and	a12.tiIdx = 2	and	a12.bActive > 0
	left join	dbo.vwStfAssn	a13	with (nolock)	on	a13.idRoom = rb.idRoom	and	a13.tiBed = rb.tiBed	and	a13.tiShIdx = 1		and	a13.tiIdx = 3	and	a13.bActive > 0
	left join	dbo.vwStfAssn	a21	with (nolock)	on	a21.idRoom = rb.idRoom	and	a21.tiBed = rb.tiBed	and	a21.tiShIdx = 2		and	a21.tiIdx = 1	and	a21.bActive > 0
	left join	dbo.vwStfAssn	a22	with (nolock)	on	a22.idRoom = rb.idRoom	and	a22.tiBed = rb.tiBed	and	a22.tiShIdx = 2		and	a22.tiIdx = 2	and	a22.bActive > 0
	left join	dbo.vwStfAssn	a23	with (nolock)	on	a23.idRoom = rb.idRoom	and	a23.tiBed = rb.tiBed	and	a23.tiShIdx = 2		and	a23.tiIdx = 3	and	a23.bActive > 0
	left join	dbo.vwStfAssn	a31	with (nolock)	on	a31.idRoom = rb.idRoom	and	a31.tiBed = rb.tiBed	and	a31.tiShIdx = 3		and	a31.tiIdx = 1	and	a31.bActive > 0
	left join	dbo.vwStfAssn	a32	with (nolock)	on	a32.idRoom = rb.idRoom	and	a32.tiBed = rb.tiBed	and	a32.tiShIdx = 3		and	a32.tiIdx = 2	and	a32.bActive > 0
	left join	dbo.vwStfAssn	a33	with (nolock)	on	a33.idRoom = rb.idRoom	and	a33.tiBed = rb.tiBed	and	a33.tiShIdx = 3		and	a33.tiIdx = 3	and	a33.bActive > 0
go
grant	select							on dbo.StaffToPatientAssignment	to [rWriter]
grant	select							on dbo.StaffToPatientAssignment	to [rReader]
go
--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='StaffToPatientAssn')
	drop view	dbo.StaffToPatientAssn
go
create view		dbo.StaffToPatientAssn
	with encryption
as
select	rb.idRoom, rb.tiBed
	,	d.sDial		[RoomNumber]
	,	case when rb.tiBed = 255 then '' else cast(rb.tiBed as varchar) end	[BedIndex]
	,	d.sDevice	[RoomName]
	,	a11.idStfAssn	id11,	case when a11.bOnDuty = 0 then '' else isnull( a11.sStaffID, '' ) end	[FirstRspndrIDShift1]
	,	a12.idStfAssn	id12,	case when a12.bOnDuty = 0 then '' else isnull( a12.sStaffID, '' ) end	[SecondRspndrIDShift1]
	,	a13.idStfAssn	id13,	case when a13.bOnDuty = 0 then '' else isnull( a13.sStaffID, '' ) end	[ThirdRspndrIDShift1]
	,	a21.idStfAssn	id21,	case when a21.bOnDuty = 0 then '' else isnull( a21.sStaffID, '' ) end	[FirstRspndrIDShift2]
	,	a22.idStfAssn	id22,	case when a22.bOnDuty = 0 then '' else isnull( a22.sStaffID, '' ) end	[SecondRspndrIDShift2]
	,	a23.idStfAssn	id23,	case when a23.bOnDuty = 0 then '' else isnull( a23.sStaffID, '' ) end	[ThirdRspndrIDShift2]
	,	a31.idStfAssn	id31,	case when a31.bOnDuty = 0 then '' else isnull( a31.sStaffID, '' ) end	[FirstRspndrIDShift3]
	,	a32.idStfAssn	id32,	case when a32.bOnDuty = 0 then '' else isnull( a32.sStaffID, '' ) end	[SecondRspndrIDShift3]
	,	a33.idStfAssn	id33,	case when a33.bOnDuty = 0 then '' else isnull( a33.sStaffID, '' ) end	[ThirdRspndrIDShift3]
	,	r.idUnit	[PrimaryUnitID]
	,	0			[SecondaryUnitID]
	,	rb.dtUpdated	[dtUpdate]
	,	rb.idRoom * 10 + case when rb.tiBed = 255 then 0 else rb.tiBed end	[TempID]
	,	0			[DownloadCounter]
	from	dbo.tbRoomBed	rb	with (nolock)
	join	dbo.vwDevice	d	with (nolock)	on	d.idDevice = rb.idRoom
	join	dbo.vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
	left join	dbo.vwStfAssn	a11	with (nolock)	on	a11.idRoom = rb.idRoom	and	a11.tiBed = rb.tiBed	and	a11.tiShIdx = 1		and	a11.tiIdx = 1	and	a11.bActive > 0
	left join	dbo.vwStfAssn	a12	with (nolock)	on	a12.idRoom = rb.idRoom	and	a12.tiBed = rb.tiBed	and	a12.tiShIdx = 1		and	a12.tiIdx = 2	and	a12.bActive > 0
	left join	dbo.vwStfAssn	a13	with (nolock)	on	a13.idRoom = rb.idRoom	and	a13.tiBed = rb.tiBed	and	a13.tiShIdx = 1		and	a13.tiIdx = 3	and	a13.bActive > 0
	left join	dbo.vwStfAssn	a21	with (nolock)	on	a21.idRoom = rb.idRoom	and	a21.tiBed = rb.tiBed	and	a21.tiShIdx = 2		and	a21.tiIdx = 1	and	a21.bActive > 0
	left join	dbo.vwStfAssn	a22	with (nolock)	on	a22.idRoom = rb.idRoom	and	a22.tiBed = rb.tiBed	and	a22.tiShIdx = 2		and	a22.tiIdx = 2	and	a22.bActive > 0
	left join	dbo.vwStfAssn	a23	with (nolock)	on	a23.idRoom = rb.idRoom	and	a23.tiBed = rb.tiBed	and	a23.tiShIdx = 2		and	a23.tiIdx = 3	and	a23.bActive > 0
	left join	dbo.vwStfAssn	a31	with (nolock)	on	a31.idRoom = rb.idRoom	and	a31.tiBed = rb.tiBed	and	a31.tiShIdx = 3		and	a31.tiIdx = 1	and	a31.bActive > 0
	left join	dbo.vwStfAssn	a32	with (nolock)	on	a32.idRoom = rb.idRoom	and	a32.tiBed = rb.tiBed	and	a32.tiShIdx = 3		and	a32.tiIdx = 2	and	a32.bActive > 0
	left join	dbo.vwStfAssn	a33	with (nolock)	on	a33.idRoom = rb.idRoom	and	a33.tiBed = rb.tiBed	and	a33.tiShIdx = 3		and	a33.tiIdx = 3	and	a33.bActive > 0
go
grant	select							on dbo.StaffToPatientAssn		to [rWriter]
grant	select							on dbo.StaffToPatientAssn		to [rReader]
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='DeviceToStaffAssignment')
	drop view	dbo.DeviceToStaffAssignment
go
create view		dbo.DeviceToStaffAssignment
	with encryption
as
select	s.idUser
	,	sStaffID	[StaffID]
	,	cast(pg.idDvc as varchar)	[PagerID]	,	pg.sDial	[sPager]
	,	cast(ph.idDvc as varchar)	[PhoneExt]	,	ph.sDial	[sPhone]
	,	cast(bd.idDvc as varchar)	[LocatorID]
	,	s.sTeams	[AssignedTeam]
	,	s.sUnits	[Units]
	,	sStfLvl		[StaffRole]
	,	sStaff		[StaffName]
	,	s.bOnDuty
	,	s.sFqStaff
	,	s.dtUpdated	[dtUpdate]
	from	dbo.vwStaff	s	with (nolock)
	left join	dbo.tbDvc	bd	with (nolock)	on	bd.idUser = s.idUser	and	bd.idDvcType = 1	and	bd.bActive > 0
	left join	dbo.tbDvc	pg	with (nolock)	on	pg.idUser = s.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
	left join	dbo.tbDvc	ph	with (nolock)	on	ph.idUser = s.idUser	and	ph.idDvcType = 3	and	ph.bActive > 0
	where	s.bActive > 0
go
grant	select, update					on dbo.DeviceToStaffAssignment	to [rWriter]
grant	select, update					on dbo.DeviceToStaffAssignment	to [rReader]
go

--if	not	exists	(select 1 from dbo.sysobjects where uid=1 and type='V' and name='')
--exec( '' )
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and type='U' and name='wtDevice')
exec( '
insert	tbDvc	( idDvcType, sDvc, sUnits, sDial, tiFlags, idUser )
select	case when [Type]=''Pager'' then 2 when [Type]=''Phone'' then 3 end	[idDvcType]
	,	substring( case when len(d.Description) > 0 then d.Description else [Type] + '' '' + ExtensionID end, 1, 16 )	[sDvc]
	,	d.Units			[sUnits]
	,	ExtensionID		[sDial]
	,	case when GroupID > 0 then 1 else 0 end + case when TechNotifications > 0 then 2 else 0 end		[tiFlags]
--	,	coalesce( pg.StaffID, ph.StaffID )	[sStaffID]		--	,	pg.StaffID, ph.StaffID
	,	s.idUser
	from	dbo.wtDevice	d	with (nolock)
		left outer join	dbo.wtDeviceToStaffAssignment	pg	with (nolock)	on	pg.PagerID = d.ID	and	d.[Type] = ''Pager''
		left outer join	dbo.wtDeviceToStaffAssignment	ph	with (nolock)	on	ph.PhoneExt = d.ID	and	d.[Type] = ''Phone''
		left outer join	dbo.vwStaff	s	with (nolock)	on	s.sStaffID = coalesce( pg.StaffID, ph.StaffID )	and	s.bActive > 0
	where	[Type] + '' '' + ExtensionID	not in	(select	sDvcType + '' '' + isnull(sDial,idDvc) from vwDvc where bActive > 0)
	order	by	[Type], ExtensionID

declare		@id	int
	,		@i			int
	,		@sUnits		varchar( 255 )
	,		@p			varchar( 3 )
	,		@idUnit		smallint

declare		cur		cursor fast_forward for
	select	idDvc, sUnits
		from	tbDvc	with (nolock)
		where	idDvcType > 1	and	sUnits is not null

begin tran

	open	cur
	fetch next from	cur	into	@id, @sUnits
	while	@@fetch_status = 0
	begin
--		print	char(10) + cast( @id as varchar )
		if	@sUnits = ''All Units''
		begin
			delete	from	tbDvcUnit
				where	idDvc = @id
			insert	tbDvcUnit	( idDvc, idUnit )
				select	@id, idUnit
					from	tbUnit
					where	bActive > 0		and		idShift > 0
--			print	''all units''
		end
		else
		begin
			select	@i=	0
	_again:
--			print	@sUnits
			select	@i=	charindex( '','', @sUnits )
			select	@p= case when @i > 0 then substring( @sUnits, 1, @i - 1 ) else @sUnits end
--			print	''i='' + cast( @i as varchar ) + '', p='' + @p

			select	@idUnit=	cast( @p as smallint )
				,	@sUnits=	case when @i > 0 then substring( @sUnits, @i + 1, 32 ) else null end
--			print	''u='' + cast( @idUnit as varchar )
			if	not	exists	(select 1 from tbDvcUnit where idDvc=@id and idUnit=@idUnit)
				insert	tbDvcUnit	( idDvc, idUnit )
						values	( @id, @idUnit )
			if	@i > 0		goto	_again
		end

		fetch next from	cur	into	@id, @sUnits
	end
	close	cur
	deallocate	cur

commit
' )
go


if	exists	( select 1 from tb_Version where idVersion = 705 )
	update	dbo.tb_Version	set	dtCreated= '2014-02-11', siBuild= 5155, dtInstall= getdate( )
		,	sVersion= '7.05.5155 - schema refactored, 7980 tables replaced'
		where	idVersion = 705
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 705,	5155, '2014-02-11', getdate( ),	'7.05.5155 - schema refactored, 7980 tables replaced' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.5.5155'
	where	idModule = 1
go

checkpoint
go

use [master]
go
