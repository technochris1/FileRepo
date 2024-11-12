--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.04
--		2013-May-24		.4892
--						* [db7980.]dbo.Staff:	+ .bLoggedIn
--						* tbRtlsRcvr:	.idDevice -> .idRoom (vwRtlsRcvr, prRtlsRcvr_GetAll, prRtlsRcvr_UpdDvc, prBadge_UpdLoc)
--							- fkRtlsRcvr_Device, + fkRtlsRcvr_Room
--						* vwDevice: + output cols from tbRoom, reorder columns
--						* vwRoomAct -> vwRoom,	match output to vwDevice
--						* tbDefBed -> tbCfgBed		(prDefBed_GetAll -> prCfgBed_GetAll, prDefBed_InsUpd -> prCfgBed_InsUpd,
--							vwEvent, vwEvent_A, prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prDevice_UpdRoomBeds, prRptSysActDtl, prRptStaffAssn, prRptStaffCover)
--						* tbDefCallP -> tbCfgPri	(prDefCallP_DelAll -> prCfgPri_Clr, prDefCallP_Ins -> prCfgPri_Ins,
--							prDefCall_GetAll, prDefCall_Imp, vwEvent_A, prEvent_Ins, prEvent84_Ins, prEvent8A_Ins, prEvent41_Ins, pr_SessCall_Set, pr_SessCall_Ins)
--						* tbDefLoc -> tbCfgLoc		(vwDefLoc_Cvrg -> vwCfgLoc_Cvrg, prDefLoc_GetAll -> prCfgLoc_GetAll, prDefLoc_DelAll -> prCfgLoc_Clr,
--							prDefLoc_Ins -> prCfgLoc_Ins, prUnit_GetAll, prDevice_InsUpd, prRoom_Upd, vwEvent_C, vwEvent_T, vwEvent95, prDefLoc_SetLvl -> prCfgLoc_SetLvl, prDevice_UpdRoomBeds)
--							+ tbEvent.fkEvent_Unit
--		2013-May-28		.4896
--						* tbDefCall -> tbCall	(prDefCall_GetAll -> prCall_GetAll, prDefCall_Imp -> prCall_Imp, prDefCall_GetIns -> prCall_GetIns,
--							tbEvent:fk, vwEvent, tbEvent_A:FK, vwEvent_A, tbEvent_C:FK, vwEvent_C, tbEvent_T:FK, vwEvent_T
--							prEvent_Ins, prEvent84_Ins, vwEvent84, prEvent8A_Ins, vwEvent8A, prEvent95_Ins, vwEvent95, prEvent41_Ins,
--							tb_SessCall:FK, pr_SessCall_Set, prRptCallActDtl)
--						* tb_OptionSys -> tb_OptSys		(pr_OptionSys_GetSmtp -> pr_OptSys_GetSmtp, pr_User_Login, prCfgBed_InsUpd,
--							prCfgFlt_DelAll, prCfgFlt_Ins, prCfgPri_Clr, prCfgPri_Ins, prCfgLoc_Clr, prCfgLoc_Ins
--							prDevice_InsUpd, prDevice_GetIns, prCfgMst_Clr, prCfgMst_Ins, prCfgDvcBtn_Clr, prCfgDvcBtn_Ins,
--							prStaff_sStaff_Upd, prEvent_Maint, prEvent_Ins, prCfgLoc_SetLvl, prCfgDvc_Init, prDevice_UpdRoomBeds, pr_Sess_Del)
--						* tb_OptionUsr -> tb_OptUsr
--						* tbRoomBed:	.idAsnRn|Cn|Ai -> .idAsn1|2|3	:FKs	(vwRoomBed, prStaffAssn_Fin, prStaffCover_InsFin)
--		2013-May-29		.4897
--						* tbEvent_C:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt, .idRn -> .idEvtRn, .idCn -> .idEvtCn, .idAi -> .idEvtAi
--							* tbEvent_T:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt
--								(vwEvent_C, prEvent_A_Exp, prEvent8A_Ins)
--						* tbDefCallP:	.idIdx -> .siIdx	(prCfgPri_Ins,
--							prCall_GetAll, prCall_Imp, vwEvent_A, prEvent_Ins, prEvent84_Ins, prEvent8A_Ins, prEvent41_Ins, pr_SessCall_Set, pr_SessCall_Ins)
--						* tbStaffDvcType -> tbStfDvcType, .idStaffDvcType -> .idStfDvcType, .sStaffDvcType -> .sStfDvcType
--							* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc (prStaffDvc_UpdStf -> prStfDvc_UpdStf *)
--							* tbStaffDvcUnit -> tbStfDvcUnit
--						* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType (prRtlsBadgeType_InsUpd -> prRtlsBdgType_InsUpd, tbRtlsBadge, vwRtlsBadge)
--						- prDevice_UpdActBySysGID	(-> prDevice_UpdActBySG)
--						* tbStaffLvl -> tbStfLvl	(tbStaff, vwStaff, prStaff_GetAll, prStaff_InsUpdDel, vwRoomBed, vwStaffAssn, vwStaffCover,
--							fnStaffAssn_GetByShift, tbRtlsRoom, prRtlsRcvr_UpdDvc, prBadge_UpdLoc, vwRtlsRoom, prRptStaffAssn, prRptStaffCover)
--						* tb_RoleReport -> tb_RoleRpt
--						* tbStaffUnit -> tbStfUnit
--						* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--							(vwStaffAssn -> vwStfAssn, prStaffAssn_Fin -> prStfAssn_Fin, prStaffAssn_InsUpdDel -> prStfAssn_InsUpdDel, fnStaffAssn_GetByShift -> fnStfAssn_GetByShift)
--						* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg	(vwStaffCover -> vwStfCvrg, prStaffCover_InsFin -> prStfCvrg_InsFin)
--		2013-May-30		.4898
--						* prBadge_ClrAll -> prRtlsBadge_RstLoc
--						* tbRtlsBadge:	- fkRtlsBadge_Device, + fkRtlsBadge_Room
--						* prBadge_UpdLoc -> prRtlsBadge_UpdLoc
--						+ pr_OptSys_GetAll, pr_OptUsr_Upd, pr_OptSys_Upd
--						* prCfgFlt_DelAll -> prCfgFlt_Clr
--						+ prCfgPri_GetAll
--		2013-Jun-03		.4902
--						+ prCall_Upd
--		2013-Jun-14		.4913
--						* prCall_GetAll:	+ @bEnabled
--						* prStaff_GetAll:	+ @bActive
--						+ pr_RoleRpt_Set
--		2013-Jun-17		.4916
--						* StaffToPatient:	+ .idRoom
--							* prDevice_UpdRoomBeds7980:	fix for renamed rooms/dial#s
--						* prDevice_UpdRoomBeds:		?StaffLvl -> ?StfLvl
--						* prCall_Imp:	tbDefBed -> tbCfgBed
--		2013-Jun-18		.4917
--						+ tbRouting:
--							* tbCall	.tiRouting, .bOverride, .tResp0, .tResp1, .tResp2, .tResp3 -> tbRouting
--						* tbShift:		tdShift_Routing 0x0F -> 0x00
--						+ tbUnit[ 0 ], + tbShift[ 0 ]
--		2013-Jun-20		.4919
--						* tb_User:		.idUser: smallint -> int	(tb_UserRole, tb_OptUsr, tb_Log, tb_Sess, tbStaff, tbFilter, tbSchedule),
--										.sFirst,.sLast: vc(32) -> vc(16),
--										+ .sMid, .sStaffID, .idStfLvl, .sStaff, .bOnDuty
--						+ prUser_sStaff_Upd
--						.idStaff: FK -> tb_User		(tbStfUnit, tbStfDvc, tbRoom, tbRoomBed, tbShift, tbStfAssn, tb_SessStaff)
--						+ tb_RoleUnit
--						* tbStfUnit -> tb_UserUnit
--						* tbStfDvcType -> tbDvcType, .idStfDvcType -> .idDvcType, .sStfDvcType -> .sDvcType		(prRtlsBadge_InsUpd)
--						* tbStfDvc:		.bTechno -> .bTech, - .tiLines, - .tiChars
--		2013-Jun-21		.4920
--						- tbStaff -> tb_User	(vwStaff, prStaff_GetAll, - prStaff_sStaff_Upd, - prStaff_InsUpdDel, vwStfAssn, vwStfCvrg, fnStfAssn_GetByShift,
--							.., prStfAssn_InsUpdDel)
--		2013-Jun-26		.4884		not 4925 'cause only 2 objects are changed!
--						* prStaffAssn_InsUpdDel (now prStfAssn_InsUpdDel)
--						* prStaffAssnDef_Exp	(7980\_config.sql)
--		2013-Jul-09		.4938
--						+ prRouting_Get, prRouting_Set, prShift_GetByUnit
--		2013-Jul-10		.4939
--						* tb_User: + .sBarCode
--						* tbStfDvc: + .sBarCode
--		2013-Jul-11		.4940
--		2013-Jul-14		.4943
--		2013-Jul-15		.4944
--						+ prRouting_Clr
--						* prRouting_Set
--		2013-Jul-18		.4947
--						+ tbTeam, tbTeamPri, tbTeamUnit, tbTeamStaff
--						- tb_SessLoc (pr_Sess_Clr, pr_Sess_Del)
--						* tbStfDvc:	.bGroup, .bTech -> .tiFlags
--		2013-Jul-23		.4952
--						+ 7980.Staff:	prStaff_Imp, * UpdateStaffD2S, * InsertStaffD2S
--		2013-Jul-24		.4953
--						* prRoom_GetAct
--						+ prStaff_LstAct
--						* vwStaff:	.sFqName -> .sFqStaff
--						* vwRtlsBadge:	+ vwStaff.sFqStaff
--						* prEventC1_Ins:	@sCodeVer vc(16)
--						* prDevice_InsUpd:	retain previous .sCodeVer values
--						* prRoom_Upd
--						* prPatient_UpdLoc
--		2013-Jul-26		.4955
--						* tbPatient:	+ xuPatient_Loc
--						* prPatient_UpdLoc
--						* prStfAssn_InsUpdDel, prStfAssn_Fin
--						* prStaffAssnDef_Exp	(7980\_config.sql)
--						* prEvent84_Ins:	gender handling
--		2013-Jul-29		.4958
--						- tbRtlsRcvrType, tbRtlsColl, prRtlsColl_InsUpd, tbRtlsSnsrType, tbRtlsSnsr, vwRtlsSnsr, prRtlsSnsr_GetAll, prRtlsSnsr_InsUpd, tbRtlsBdgType, prRtlsBdgType_InsUpd
--						* tbRtlsRcvr:	- .idRcvrType, .sPhone, fkRtlsRcvr_Type		(vwRtlsRcvr, prRtlsRcvr_GetAll, prRtlsRcvr_InsUpd)
--						* tbRtlsBadge:	- .idBdgType, fkRtlsBadge_Type	(vwRtlsBadge, prRtlsBadge_GetAll, prRtlsBadge_InsUpd)
--		2013-Jul-30		.4959
--						prRoom_GetAct -> prRoom_LstAct
--		2013-Jul-31		.4960
--						* prEvent_SetGwState
--		2013-Aug-05		.4965
--						* prDevice_GetAll
--						* prEvent_Ins
--						+ prShift_Exp, prShift_Imp,		prUser_Exp, prUser_Imp
--		2013-Aug-06		.4966
--						* pr_User_Login:	@iHass -> @iHash
--						* tbShift:	- .iStamp
--		2013-Aug-07		.4967
--						* prEvent_Ins
--						* tbUnit:	- .iStamp
--		2013-Aug-08		.4968
--						* prRtlsBadge_InsUpd:	exec as owner
--						* tb_OptSys[9,10] := 30
--		2013-Aug-09		.4969
--						* prDevice_GetIns:	resolve to RID==0 level
--						* prEvent_Ins:	flip Src and Dst for audio/svc/pat-rq commands
--						* prEvent84_Ins:	no correct for devices
--						- prShift_InsUpdDel, prUnit_InsUpdDel
--		2013-Aug-12		.4972
--						* prDevice_GetIns:	revert to using @tiRID, but use RID==0 for 'M'
--						* prEvent_Ins:	store 'presence' into tbEvent_P (otherwise tbEvent_A won't keep these calls), + @idCall0 to handle call escalation (prEvent84_Ins)
--						* prEvent84_Ins:	insert tbEvent_C: @idSrcDvc -> @idRoom, pass prev. call-idx into prEvent_Ins
--						* prEvent8A_Ins:	insert tbEvent_C: @idSrcDvc -> @idRoom
--		2013-Aug-14		.4974
--						* vwRoom added to <0704.sql>

--						finalized?
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tb_Version') and name='idVersion' and user_type_id=52)	--	smallint
	--	!!	version must already be at least 6.00	!!
	if	exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 704 and siBuild >= 4974 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.04.4974', 18, 0 )

go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStfAssn_GetByShift')
	drop function	dbo.fnStfAssn_GetByShift
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStaffAssn_GetByShift')
	drop function	dbo.fnStaffAssn_GetByShift
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLoc_Ins')
	drop proc	dbo.pr_SessLoc_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_RoleRpt_Set')
	drop proc	dbo.pr_RoleRpt_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_Init')
	drop proc	dbo.prCfgDvc_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_RstLoc')
	drop proc	dbo.prRtlsBadge_RstLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prBadge_ClrAll')
	drop proc	dbo.prBadge_ClrAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_UpdLoc')
	drop proc	dbo.prRtlsBadge_UpdLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prBadge_UpdLoc')
	drop proc	dbo.prBadge_UpdLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_GetAll')
	drop proc	dbo.prRtlsBadge_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBdgType_InsUpd')
	drop proc	dbo.prRtlsBdgType_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadgeType_InsUpd')
	drop proc	dbo.prRtlsBadgeType_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRcvr_GetAll')
	drop proc	dbo.prRtlsRcvr_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfCvrg_InsFin')
	drop proc	dbo.prStfCvrg_InsFin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffCover_InsFin')
	drop proc	dbo.prStaffCover_InsFin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_InsUpdDel')
	drop proc	dbo.prStfAssn_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssn_InsUpdDel')
	drop proc	dbo.prStaffAssn_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_Fin')
	drop proc	dbo.prStfAssn_Fin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssn_Fin')
	drop proc	dbo.prStaffAssn_Fin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRouting_Set')
	drop proc	dbo.prRouting_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRouting_Clr')
	drop proc	dbo.prRouting_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRouting_Get')
	drop proc	dbo.prRouting_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_InsUpdDel')
	drop proc	dbo.prShift_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_GetByUnit')
	drop proc	dbo.prShift_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Imp')
	drop proc	dbo.prShift_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Exp')
	drop proc	dbo.prShift_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_InsUpdDel')
	drop proc	dbo.prUnit_InsUpdDel
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgLoc_SetLvl')
	drop proc	dbo.prCfgLoc_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefLoc_SetLvl')
	drop proc	dbo.prDefLoc_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetAct')
	drop proc	dbo.prRoom_GetAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_LstAct')
	drop proc	dbo.prRoom_LstAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfDvc_UpdStf')
	drop proc	dbo.prStfDvc_UpdStf
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffDvc_UpdStf')
	drop proc	dbo.prStaffDvc_UpdStf
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_UpdActBySysGID')
	drop proc	dbo.prDevice_UpdActBySysGID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_sStaff_Upd')
	drop proc	dbo.prStaff_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetAll')
	drop proc	dbo.prStaff_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_LstAct')
	drop proc	dbo.prStaff_LstAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_LstAct')
	drop proc	dbo.prStaff_LstAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgLoc_Ins')
	drop proc	dbo.prCfgLoc_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefLoc_Ins')
	drop proc	dbo.prDefLoc_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgLoc_Clr')
	drop proc	dbo.prCfgLoc_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefLoc_DelAll')
	drop proc	dbo.prDefLoc_DelAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgLoc_GetAll')
	drop proc	dbo.prCfgLoc_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefLoc_GetAll')
	drop proc	dbo.prDefLoc_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_GetIns')
	drop proc	dbo.prCall_GetIns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCall_GetIns')
	drop proc	dbo.prDefCall_GetIns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCall_InsUpd')
	drop proc	dbo.prDefCall_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_Imp')
	drop proc	dbo.prCall_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCall_Imp')
	drop proc	dbo.prDefCall_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_Upd')
	drop proc	dbo.prCall_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_GetAll')
	drop proc	dbo.prCall_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCall_GetAll')
	drop proc	dbo.prDefCall_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_Ins')
	drop proc	dbo.prCfgPri_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCallP_Ins')
	drop proc	dbo.prDefCallP_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_GetAll')
	drop proc	dbo.prCfgPri_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_Clr')
	drop proc	dbo.prCfgPri_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCallP_DelAll')
	drop proc	dbo.prDefCallP_DelAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_Clr')
	drop proc	dbo.prCfgFlt_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_DelAll')
	drop proc	dbo.prCfgFlt_DelAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBed_InsUpd')
	drop proc	dbo.prCfgBed_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefBed_InsUpd')
	drop proc	dbo.prDefBed_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBed_GetAll')
	drop proc	dbo.prCfgBed_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefBed_GetAll')
	drop proc	dbo.prDefBed_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_sStaff_Upd')
	drop proc	dbo.prUser_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptUsr_Upd')
	drop proc	dbo.pr_OptUsr_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptSys_Upd')
	drop proc	dbo.pr_OptSys_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptSys_GetSmtp')
	drop proc	dbo.pr_OptSys_GetSmtp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptionSys_GetSmtp')
	drop proc	dbo.pr_OptionSys_GetSmtp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptSys_GetAll')
	drop proc	dbo.pr_OptSys_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_Imp')
	drop proc	dbo.prUser_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_Exp')
	drop proc	dbo.prUser_Exp
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStfCvrg')
	drop view	dbo.vwStfCvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStaffCover')
	drop view	dbo.vwStaffCover
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStfAssn')
	drop view	dbo.vwStfAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStaffAssn')
	drop view	dbo.vwStaffAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRoomAct')
	drop view	dbo.vwRoomAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRoom')
	drop view	dbo.vwRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDefLoc_CaUnit')
	drop view	dbo.vwDefLoc_CaUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCfgLoc_Cvrg')
	drop view	dbo.vwCfgLoc_Cvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDefLoc_Cvrg')
	drop view	dbo.vwDefLoc_Cvrg
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffUnit')
	drop table	dbo.tbStaffUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfUnit')
	drop table	dbo.tbStfUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvcUnit')
	drop table	dbo.tbStaffDvcUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvcUnit')
	drop table	dbo.tbStfDvcUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRouting')
	drop table	dbo.tbRouting
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamStaff')
	drop table	dbo.tbTeamStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamUnit')
	drop table	dbo.tbTeamUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamPri')
	drop table	dbo.tbTeamPri
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeam')
	drop table	dbo.tbTeam
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_RoleUnit')
	drop table	dbo.tb_RoleUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_UserUnit')
	drop table	dbo.tb_UserUnit
go

go
--	----------------------------------------------------------------------------
--	v.7.03	+ .idRoom, -.bSwing
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
--	System-wide options
--	7.04.4896	* tb_OptionSys -> tb_OptSys
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_OptionSys')
begin
	begin tran
		exec sp_rename 'tb_OptionSys',			'tb_OptSys',			'object'
		exec sp_rename 'td_OptionSys_Updated',	'td_OptSys_Updated',	'object'
		exec sp_rename 'vc_OptionSys_Value',	'vc_OptSys_Value',		'object'
	commit
end
go
begin tran
	update	dbo.tb_OptSys	set	iValue= 30	where	idOption in (9,10)
commit
go
--	----------------------------------------------------------------------------
--	Returns all system settings
--	7.04.4898
create proc		dbo.pr_OptSys_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idOption, iValue, fValue, tValue, sValue
		from	tb_OptSys	with (nolock)
end
go
grant	execute				on dbo.pr_OptSys_GetAll				to [rWriter]
grant	execute				on dbo.pr_OptSys_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns SMTP settings
--	7.03.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.pr_OptSys_GetSmtp
	with encryption
as
begin
--	set	nocount	on
	select	idOption, iValue, fValue, tValue, sValue
		from	tb_OptSys	with (nolock)
		where	idOption	between 12 and 17
end
go
grant	execute				on dbo.pr_OptSys_GetSmtp			to [rWriter]
grant	execute				on dbo.pr_OptSys_GetSmtp			to [rReader]
go
--	----------------------------------------------------------------------------
--	User options
--	7.04.4896	* tb_OptionUsr -> tb_OptUsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_OptionUsr')
begin
	begin tran
		exec sp_rename 'tb_OptionUsr',			'tb_OptUsr',			'object'
		exec sp_rename 'td_OptionUsr_Updated',	'td_OptUsr_Updated',	'object'
		exec sp_rename 'vc_OptionUsr_Value',	'vc_OptUsr_Value',		'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
--	7.04.4898
create proc		dbo.pr_OptSys_Upd
(
	@idOption	smallint
,	@iValue		int
,	@fValue		float
,	@tValue		datetime
,	@sValue		varchar( 255 )
,	@idUser		smallint
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

				 if	@k = 56		select	@s=	@s + ', i=' + isnull(cast(@iValue as varchar), '?')
			else if	@k = 62		select	@s=	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s=	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s=	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	236, @idUser, null, @s
		commit
	end
end
go
grant	execute				on dbo.pr_OptSys_Upd				to [rWriter]
grant	execute				on dbo.pr_OptSys_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates and logs user setting
--	7.04.4898
create proc		dbo.pr_OptUsr_Upd
(
	@idOption	smallint
,	@iValue		int
,	@fValue		float
,	@tValue		datetime
,	@sValue		varchar( 255 )
,	@idUser		smallint
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

				 if	@k = 56		select	@s=	@s + ', i=' + isnull(cast(@iValue as varchar), '?')
			else if	@k = 62		select	@s=	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s=	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s=	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	231, @idUser, null, @s
		commit
	end
end
go
grant	execute				on dbo.pr_OptUsr_Upd				to [rWriter]
grant	execute				on dbo.pr_OptUsr_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff levels
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffLvl')
begin
	begin tran
		exec sp_rename 'tbStaffLvl.idStaffLvl',	'idStfLvl',		'column'
		exec sp_rename 'tbStaffLvl.sStaffLvl',	'sStfLvl',		'column'

		exec sp_rename 'tbStaff.idStaffLvl',	'idStfLvl',		'column'
		exec sp_rename 'tbRtlsRoom.idStaffLvl',	'idStfLvl',		'column'

		exec sp_rename 'tbStaffLvl',			'tbStfLvl',		'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	App users
--	7.04.4919	.idUser: smallint -> int,	.sFirst,.sLast: vc(32) -> vc(16),
--				+ .sMid, .sStaffID, .idStfLvl, .sStaff, .bOnDuty
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'idStfLvl')
begin
	begin tran

		alter table	dbo.tbSchedule	drop constraint	fkSchedule_User
		drop index	dbo.tbFilter.xuFilter
		alter table	dbo.tbFilter	drop constraint	fkFilter_User
		alter table	dbo.tbStaff		drop constraint	fkStaff_User
		alter table	dbo.tb_Sess		drop constraint	tb_Sess_User
		alter table	dbo.tb_Log		drop constraint	fk_Log_Oper
		alter table	dbo.tb_Log		drop constraint	fk_Log_User
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_OptionUsr_User')
			alter table	dbo.tb_OptUsr	drop constraint	fk_OptionUsr_User
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='xp_OptionUsr')
			alter table	dbo.tb_OptUsr	drop constraint	xp_OptionUsr
		alter table	dbo.tb_UserRole	drop constraint	fk_UserRole_User
		alter table	dbo.tb_UserRole	drop constraint	xp_UserRole
		alter table	dbo.tb_User		drop constraint	xp_User

		alter table	dbo.tb_User			alter column
			idUser		int				not null
		alter table	dbo.tb_UserRole		alter column
			idUser		int				not null
		alter table	dbo.tb_OptUsr		alter column
			idUser		int				not null
		alter table	dbo.tb_Log			alter column
			idUser		int				null
		alter table	dbo.tb_Log			alter column
			idOper		int				null
		alter table	dbo.tb_Sess			alter column
			idUser		int				null
		alter table	dbo.tbFilter		alter column
			idUser		int				null
		alter table	dbo.tbSchedule		alter column
			idUser		int				null

		alter table	dbo.tb_User			add
			constraint	xp_User				primary key clustered (idUser)
		alter table	dbo.tb_UserRole		add
			constraint	fk_UserRole_User	foreign key (idUser)	references tb_User
		,	constraint	xp_UserRole			primary key clustered ( idUser, idRole )
		alter table	dbo.tb_OptUsr		add
			constraint	fk_OptUsr_User		foreign key (idUser)	references tb_User
		,	constraint	xp_OptUsr			primary key clustered ( idUser, idOption )
		alter table	dbo.tb_Log			add
			constraint	fk_Log_User			foreign key (idUser)	references tb_User
		,	constraint	fk_Log_Oper			foreign key (idOper)	references tb_User
		alter table	dbo.tb_Sess			add
			constraint	tb_Sess_User		foreign key (idUser)	references tb_User
		alter table	dbo.tbFilter		add
			constraint	fkFilter_User		foreign key (idUser)	references tb_User
		create unique nonclustered index	xuFilter	on dbo.tbFilter ( idUser, sFilter )

		alter table	dbo.tbSchedule		add
			constraint	fkSchedule_User		foreign key (idUser)	references tb_User

		alter table	dbo.tb_User		alter column
			sFirst		varchar( 16 )	null		-- first name
		alter table	dbo.tb_User		alter column
			sLast		varchar( 16 )	null		-- last name

		alter table	dbo.tb_User		add
			sMid		varchar( 16 )	null		-- middle name
		,	sStaffID	varchar( 16 )	null		-- external Staff ID
		,	idStfLvl	tinyint			null		-- 4=RN, 2=CNA, 1=Aide, ..
				constraint	fkUser_Level	foreign key references	tbStfLvl
		,	sBarCode	varchar( 32 )	null		-- bar-code
		,	bOnDuty		bit				not null	-- on-duty?
				constraint	tdUser_OnDuty	default( 0 )
		,	sStaff		varchar( 16 )	null		-- auto: persisted name, formatted by tb_OptSys[11]
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates staff's formatted name
--	7.04.4919	* prStaff_sStaff_Upd -> prUser_sStaff_Upd
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.01	* add width enforcement
--	6.05
create proc		dbo.prUser_sStaff_Upd
(
	@idUser		int							-- null = entire table
,	@tiFmt		tinyint						-- null = use tb_OptSys[11]
)
	with encryption
as
begin
	set	nocount	on

	create	table	#tbStaff
	(
		idStaff		int
	)

	if	@idUser > 0							--	single
	begin
		insert	#tbStaff
			values	(@idUser)

		select	@tiFmt= cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 11
	end
	else									--	update all
	begin
		if	@tiFmt is null
			return	-1						--	must be specified

		insert	#tbStaff
			select	idUser
				from	tb_User		with (nolock)
	end

	begin	tran

		update	u	set	sStaff=
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
			from	tb_User	u
			inner join	#tbStaff	t	on	t.idStaff = u.idUser

		if	@idUser is null					--	update all
			update	tb_OptSys	set	iValue= @tiFmt	where	idOption = 11

	commit
end
go
grant	execute				on dbo.prUser_sStaff_Upd			to [rWriter]
grant	execute				on dbo.prUser_sStaff_Upd			to [rReader]
go
--	----------------------------------------------------------------------------
--	clean up staff references
begin tran

	if	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbRoomBed') and name='idAsnRn')

		exec( 'update	tbRoomBed	set	idAsnRn= null	where	idAsnRn not in (select idUser from tb_User)
				update	tbRoomBed	set	idAsnCn= null	where	idAsnCn not in (select idUser from tb_User)
				update	tbRoomBed	set	idAsnAi= null	where	idAsnAi not in (select idUser from tb_User)

				update	tbRoom		set	idRn= null		where	idRn not in (select idUser from tb_User)
				update	tbRoom		set	idCn= null		where	idCn not in (select idUser from tb_User)
				update	tbRoom		set	idAi= null		where	idAi not in (select idUser from tb_User)' )
/*	else
		exec( 'update	tbRoomBed	set	idAssn1= null	where	idAssn1 not in (select idUser from tb_User)
				update	tbRoomBed	set	idAssn2= null	where	idAssn2 not in (select idUser from tb_User)
				update	tbRoomBed	set	idAssn3= null	where	idAssn3 not in (select idUser from tb_User)' )
*/

	update	tbShift		set	idStaff= null	where	idStaff not in (select idUser from tb_User)

	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffCover')
		exec( 'delete	from	tbStaffCover
				delete	from	tbStaffAssn' )

commit
go
--	----------------------------------------------------------------------------
--	Exports all users
--	7.04.4965
create proc		dbo.prUser_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, sUser, iHash, bLocked, tiFails, sFirst, sMid, sLast, sEmail, sDesc, dtLastAct
		,	sStaffID, idStfLvl, sBarCode, bOnDuty, sStaff, bActive, dtCreated, dtUpdated
		from	tb_User		with (nolock)
		where	idUser > 16
		order	by	idUser
end
go
grant	execute				on dbo.prUser_Exp					to [rWriter]
grant	execute				on dbo.prUser_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a user
--	7.04.4965
create proc		dbo.prUser_Imp
(
	@idUser		int
,	@sUser		varchar( 32 )
,	@iHash		int
,	@bLocked	bit
,	@tiFails	tinyint
,	@sFirst		varchar( 16 )
,	@sMid		varchar( 16 )
,	@sLast		varchar( 16 )
,	@sEmail		varchar( 64 )
,	@sDesc		varchar( 255 )
,	@dtLastAct	datetime
,	@sStaffID	varchar( 16 )
,	@idStfLvl	tinyint
,	@sBarCode	varchar( 32 )
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

	begin	tran

		if	exists	(select 1 from tb_User with (nolock) where idUser = @idUser)
		begin
			update	tb_User	set	sUser= @sUser, iHash= @iHash, bLocked= @bLocked, tiFails= @tiFails, sFirst= @sFirst
						,	sMid= @sMid, sLast= @sLast, sEmail= @sEmail, sDesc= @sDesc, dtLastAct= @dtLastAct
						,	sStaffID= @sStaffID, idStfLvl= @idStfLvl, sBarCode= @sBarCode, bOnDuty= @bOnDuty
						,	sStaff= @sStaff, bActive= @bActive, dtUpdated= @dtUpdated
				where	idUser = @idUser
		end
		else
		begin
			set identity_insert	dbo.tb_User	on

			insert	tb_User	(  idUser,  sUser,  iHash,  bLocked,  tiFails,  sFirst,  sMid,  sLast,  sEmail,  sDesc,  dtLastAct
							,  sStaffID,  idStfLvl,  sBarCode,  bOnDuty,  sStaff,  bActive,  dtCreated,  dtUpdated )
					values	( @idUser, @sUser, @iHash, @bLocked, @tiFails, @sFirst, @sMid, @sLast, @sEmail, @sDesc, @dtLastAct
							, @sStaffID, @idStfLvl, @sBarCode, @bOnDuty, @sStaff, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tb_User	off
		end

	commit
end
go
grant	execute				on dbo.prUser_Imp					to [rWriter]
--grant	execute				on dbo.prUser_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	import Staff -> tb_User
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaff')
	exec( 'declare	@idStf		int
	,	@lStID		int
	,	@sFrst		varchar( 16 )
	,	@sMidl		varchar( 16 )
	,	@sLast		varchar( 16 )
	,	@tiLvl		tinyint
	,	@bActv		bit
	,	@dtCre		smalldatetime
	,	@dtUpd		smalldatetime
	,	@sUser		varchar( 16 )
--	,	@sPass		varchar( 16 )

declare	cur		cursor fast_forward for
	select	idStaff, cast(lStaffID as int), sFirst, sMid, sLast, idStfLvl, bActive, dtCreated, dtUpdated
		from	tbStaff	with (nolock)

begin tran
	set identity_insert	dbo.tb_User	on

	open	cur
	fetch next from	cur	into	@idStf, @lStID, @sFrst, @sMidl, @sLast, @tiLvl, @bActv, @dtCre, @dtUpd
	while	@@fetch_status = 0
	begin
		if	not	exists	(select 1 from dbo.tb_User where idUser = @lStID)
		begin
--			if	@sUser is null	or	len(@sUser) = 0
				select	@sUser=	''usr'' + cast(@lStID as varchar)
--			if	len(@sPass) = 0							select	@sPass=	null

			insert	tb_User	( idUser, sUser, iHash, sFirst, sMid, sLast, sStaffID, idStfLvl, bActive, dtCreated, dtUpdated, sStaff )
					values	( @lStID, @sUser, 0, @sFrst, @sMidl, @sLast, @lStID, @tiLvl, @bActv, @dtCre, @dtUpd, ''_'' )
		end

		fetch next from	cur	into	@idStf, @lStID, @sFrst, @sMidl, @sLast, @tiLvl, @bActv, @dtCre, @dtUpd
	end
	close	cur
	deallocate	cur

	set identity_insert	dbo.tb_User	off

	exec	dbo.prUser_sStaff_Upd	null, 0
commit' )
go
/*
--	----------------------------------------------------------------------------
--	Staff definitions
--	7.04.4920	- tbStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaff')
begin
	begin tran
/ *		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvc')
		begin
			alter table	dbo.tbStaffDvc	drop constraint	fkStaffDvc_Staff
			alter table	dbo.tbStaffDvc	add
				constraint	fkStfDvc_Staff	foreign key	(idStaff)	references	tb_User
		end
		else
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvc')
		begin
* /			alter table	dbo.tbStfDvc	drop constraint	fkStfDvc_Staff
			alter table	dbo.tbStfDvc	add
				constraint	fkStfDvc_Staff	foreign key	(idStaff)	references	tb_User
--		end

		alter table	dbo.tbRoom		drop constraint	fkRoom_Rn
		alter table	dbo.tbRoom		drop constraint	fkRoom_Cna
		alter table	dbo.tbRoom		drop constraint	fkRoom_Aide
		alter table	dbo.tbRoom		add
			constraint	fkRoom_Rn		foreign key	(idRn)	references tb_User
		,	constraint	fkRoom_Cna		foreign key	(idCn)	references tb_User
		,	constraint	fkRoom_Aide		foreign key	(idAi)	references tb_User

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_Assn1')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_Assn1
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_Assn2')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_Assn2
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_Assn3')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_Assn3
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_AsnRn')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_AsnRn
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_AsnCna')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_AsnCna
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_AsnAide')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_AsnAide
		alter table	dbo.tbRoomBed	add
			constraint	fkRoomBed_Assn1	foreign key	(idAssn1)	references tb_User
		,	constraint	fkRoomBed_Assn2	foreign key	(idAssn2)	references tb_User
		,	constraint	fkRoomBed_Assn3	foreign key	(idAssn3)	references tb_User

		alter table	dbo.tbShift		drop constraint	fkShift_Staff
		alter table	dbo.tbShift		add
			constraint	fkShift_Staff	foreign key	(idStaff)	references tb_User

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStfAssn_Staff')
			alter table	dbo.tbStfAssn	drop constraint	fkStfAssn_Staff
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffAssn_Staff')
			alter table	dbo.tbStfAssn	drop constraint	fkStaffAssn_Staff
		alter table	dbo.tbStfAssn	add
			constraint	fkStfAssn_Staff		foreign key	(idStaff)	references	tb_User

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_SessStaff_User')
			alter table	dbo.tb_SessStaff	drop constraint	fk_SessStaff_User
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_SessStaff_Shift')
			alter table	dbo.tb_SessStaff	drop constraint	fk_SessStaff_Shift
		alter table	dbo.tb_SessStaff	add
			constraint	fk_SessStaff_User	foreign key	(idStaff)	references tb_User

		drop table	dbo.tbStaff
	commit
end
*/
go
--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_Imp')
	drop proc	dbo.prStaff_Imp
go
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	exec( 'create proc		dbo.prStaff_Imp
--(
--	@idUser		int							-- null = entire table
--)
	with encryption
as
begin
	set	nocount	on
	declare	@sID		varchar( 16 )
	--	,	@lStID		int
		,	@sFrst		varchar( 16 )
		,	@sMidl		varchar( 16 )
		,	@sLast		varchar( 16 )
		,	@tiLvl		tinyint
		,	@bActv		bit
	--	,	@sLvl		varchar( 20 )
		,	@sAccL		varchar( 20 )
		,	@sUser		varchar( 12 )
		,	@sPass		varchar( 12 )
		,	@sUnts		varchar( 32 )
	--	,	@dtUpd		smalldatetime
	--	,	@tmpID		int

	declare	cur		cursor fast_forward for
		select	ID
	--		,	cast(ID as int)
			,	case when len(FirstName)=0 then null	else cast(rtrim(FirstName) as varchar(16)) end	[sFrst]
			,	case when len(MiddleName)=0 then null	else cast(rtrim(MiddleName) as varchar(16)) end	[sMidl]
			,	case when len(LastName)=0 then null		else cast(rtrim(LastName) as varchar(16)) end	[sLast]
			,	cast(case when StaffRole=''RN'' then 4 when StaffRole=''CNA'' then 2 when StaffRole=''AIDE'' then 1 else null end as tinyint)	[tiLvl]
			,	Active		[bActv]
			,	AccessLevel	[sAccL]
			,	UserName	[sUser]
			,	[Password]	[sPass]
			,	cast(Units as varchar(32))		[sUnts]
	--		,	dtUpdate	[dtUpd]
			from	Staff	with (nolock)

	begin tran
--	-	set identity_insert	dbo.tb_User	on

		open	cur
		fetch next from	cur	into	@sID, @sFrst, @sMidl, @sLast, @tiLvl, @bActv, @sAccL, @sUser, @sPass, @sUnts--, @lStID, @dtUpd
		while	@@fetch_status = 0
		begin
	--	-	if	not	exists	(select 1 from dbo.tb_User where idUser = @lStID)
			if	not	exists	(select 1 from dbo.tb_User where sStaffID = @sID)
			begin
				if	@sUser is null	or	len(@sUser) = 0		select	@sUser=	''usr'' + @sID
				if	len(@sPass) = 0							select	@sPass=	null

--	-			insert	tb_User	( idUser, sUser, iHash, sFirst, sMid, sLast, sEmail, sDesc, sStaffID, idStfLvl, bActive, dtUpdated, sStaff, sBarCode )
--	-					values	( @lStID, @sUser, 0, @sFrst, @sMidl, @sLast, @sPass, @sAccL, @sID, @tiLvl, @bActv, getdate( ), ''_'', @sUnts )
				insert	tb_User	(		sUser, iHash, sFirst, sMid, sLast, sEmail, sDesc, sStaffID, idStfLvl, bActive, dtUpdated, sStaff, sBarCode )
						values	(		@sUser, 0, @sFrst, @sMidl, @sLast, @sPass, @sAccL, @sID, @tiLvl, @bActv, getdate( ), ''_'', @sUnts )
			end

			fetch next from	cur	into	@sID, @sFrst, @sMidl, @sLast, @tiLvl, @bActv, @sAccL, @sUser, @sPass, @sUnts--, @lStID, @dtUpd
		end
		close	cur
		deallocate	cur

--	-	set identity_insert	dbo.tb_User	off

		exec	dbo.prUser_sStaff_Upd	null, 0
	commit
end' )
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_Imp')
begin
	grant	execute				on dbo.prStaff_Imp					to [rWriter]
	grant	execute				on dbo.prStaff_Imp					to [rReader]
end
go
--	----------------------------------------------------------------------------
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	and	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='Staff')
	exec( 'alter trigger	dbo.UpdateStaffD2S   on  dbo.Staff   after update
as
begin
	set nocount on
	
	declare	@newStaffID		nvarchar(12)
	declare	@newUnits		nvarchar(max)
	declare	@StaffRole		nvarchar(20)
	declare	@FullName		nvarchar(50)
	declare	@ActiveStatus	bit
	declare	@iNameFmt		int

	select	@iNameFmt=	StaffNameFormatIndex 
		from	Facility

	select	@newStaffID = ID, @newUnits = Units, @StaffRole = StaffRole, @ActiveStatus = Active,
			@FullName = case
				when @iNameFmt = 0 then LastName + '', '' + FirstName
				when @iNameFmt = 1 then FirstName + '', '' + LastName
				when @iNameFmt = 2 then FirstName +'', '' + substring(MiddleName, 1, 1) + '', '' + LastName
				when @iNameFmt = 3 then substring(FirstName, 1, 1) + '', '' + LastName
				when @iNameFmt = 4 then FirstName +'', ''+ substring(LastName, 1, 1)
			end
		from inserted

	declare	@sStfID		nvarchar(12)

	select	@sStfID = StaffID
		from	DeviceToStaffAssignment
		where	StaffID = @newStaffID
	
	if	@sStfID is not null
	begin
		update	DeviceToStaffAssignment		set	Units = @newUnits, StaffRole = @StaffRole, StaffName = @FullName
			where	StaffID = @newStaffID
	end
	
	if	@ActiveStatus = 0
	begin
		delete	from	DeviceToStaffAssignment		where	StaffID = @newStaffID
		
		--delete the staff from staff to patient assignment if any
		update	StaffToPatientAssignment	set	FirstRspndrIDShift1 = '' ''	where	FirstRspndrIDShift1 = @newStaffID
		update	StaffToPatientAssignment	set	FirstRspndrIDShift2 = '' ''	where	FirstRspndrIDShift2 = @newStaffID
		update	StaffToPatientAssignment	set	FirstRspndrIDShift3 = '' ''	where	FirstRspndrIDShift3 = @newStaffID
		update	StaffToPatientAssignment	set	SecondRspndrIDShift1 = '' ''	where	SecondRspndrIDShift1 = @newStaffID
		update	StaffToPatientAssignment	set	SecondRspndrIDShift2 = '' ''	where	SecondRspndrIDShift2 = @newStaffID
		update	StaffToPatientAssignment	set SecondRspndrIDShift3 = '' ''	where	SecondRspndrIDShift3 = @newStaffID
		update	StaffToPatientAssignment	set	ThirdRspndrIDShift1 = '' ''	where	ThirdRspndrIDShift1 = @newStaffID
		update	StaffToPatientAssignment	set	ThirdRspndrIDShift2 = '' ''	where	ThirdRspndrIDShift2 = @newStaffID
		update	StaffToPatientAssignment	set	ThirdRspndrIDShift3 = '' ''	where	ThirdRspndrIDShift3 = @newStaffID
		
/*		--delete the backup staff if it has been assigned to any units
		update	Units	set	BackupStaffIDShift1 = '' ''	where	BackupStaffIDShift1 = @newStaffID
		update	Units	set	BackupStaffIDShift2 = '' ''	where	BackupStaffIDShift2 = @newStaffID
		update	Units	set	BackupStaffIDShift2 = '' ''	where	BackupStaffIDShift3 = @newStaffID			
*/
	end
	else
--	if	@ActiveStatus = 1
	begin
		if	@sStfID is null
			insert	DeviceToStaffAssignment (StaffID, Units, StaffRole, StaffName)
				values	(@newStaffID, @newUnits, @StaffRole, @FullName)
	end

	exec	prStaff_Imp
end' )
go
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	and	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='Staff')
	exec( 'alter trigger	dbo.InsertStaffD2S   on  dbo.Staff   after insert
as 
begin
	set nocount on
		
	declare @newStaffID		nvarchar (12)
	declare @newUnits		nvarchar(max) 
	declare @StaffRole		nvarchar(20)
	declare @FullName		nvarchar(50)
	declare	@iNameFmt		int

	select	@iNameFmt=	StaffNameFormatIndex 
		from	Facility
	
	select	@newStaffID = ID, @newUnits = Units, @StaffRole = StaffRole, --@ActiveStatus = Active,
			@FullName = case
				when @iNameFmt = 0 then LastName + '', '' + FirstName
				when @iNameFmt = 1 then FirstName + '', '' + LastName
				when @iNameFmt = 2 then FirstName +'', '' + substring(MiddleName, 1, 1) + '', '' + LastName
				when @iNameFmt = 3 then substring(FirstName, 1, 1) + '', '' + LastName
				when @iNameFmt = 4 then FirstName +'', ''+ substring(LastName, 1, 1)
			end
		from inserted
	 
	declare	@sStfID		nvarchar(12)

	select	@sStfID = StaffID
		from	DeviceToStaffAssignment
		where	StaffID = @newStaffID

	if @sStfID is null
	begin
		insert	DeviceToStaffAssignment (StaffID, Units, StaffRole, StaffName, dtUpdate)
			values	(@newStaffID, @newUnits, @StaffRole, @FullName, getdate())
	end 

	exec	prStaff_Imp
end' )
go
--	----------------------------------------------------------------------------
begin
	begin tran
		exec	dbo.prUser_sStaff_Upd	null, 0

		alter table	dbo.tb_User		alter column
			sStaff		varchar( 16 )	not null	-- auto: persisted name, formatted by tb_OptSys[11]
	commit
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
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
,	@sFirst		varchar( 32 ) out	-- first-name
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

	select	@idUser= idUser, @iHass= iHash, @bActive= bActive, @bLocked= bLocked, @tiFails= tiFails, @sFirst= sFirst, @sLast= sLast
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType=	222,	@s=	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

	if	@bLocked = 1			--	locked-out
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

		begin	tran
			if	@tiFails < @tiMaxAtt - 1
				update	tb_User		set	tiFails= tiFails + 1
					where	idUser = @idUser
			else
			begin
				update	tb_User		set	tiFails= tiFails + 1, bLocked= 1
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

	begin	tran
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
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefBed')
begin
	begin tran
		exec sp_rename 'tbDefBed.idIdx',	'tiBed',			'column'

		exec sp_rename 'tbDefBed',			'tbCfgBed',			'object'
		exec sp_rename 'tdDefBed_InUse',	'tdCfgBed_InUse',	'object'
		exec sp_rename 'tdDefBed_Created',	'tdCfgBed_Created',	'object'
		exec sp_rename 'tdDefBed_Updated',	'tdCfgBed_Updated',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all beds, ordered to be loadable into a tree
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
create proc		dbo.prCfgBed_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	tiBed
		from	dbo.tbCfgBed	with (nolock)
		where	bInUse > 0
end
go
grant	execute				on dbo.prCfgBed_GetAll				to [rWriter]
grant	execute				on dbo.prCfgBed_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a bed definition
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--				* @tiIdx -> @tiBed
--	6.05
create proc		dbo.prCfgBed_InsUpd
(
	@tiBed		tinyint				-- bed-index
,	@cBed		char( 1 )			-- bed-name
,	@cDial		char( 1 )			-- dialable number (digits only)
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Bed_IU( ' + isnull(cast(@tiBed as varchar), '?') +
				', c=' + isnull(@cBed, '?') + ', d=' + isnull(@cDial, '?') + ' )'

	begin	tran
		if	exists	(select 1 from tbCfgBed where tiBed = @tiBed)
		begin
			update	tbCfgBed	set	cBed= @cBed, cDial= @cDial, dtUpdated= getdate( )
				where	tiBed = @tiBed
			select	@s= @s + ' UPD'
		end
		else
		begin
			insert	tbCfgBed	(  tiBed,  cBed,  cDial )
					values		( @tiBed, @cBed, @cDial )
			select	@s= @s + ' INS'
		end

		if	@iTrace & 0x08 > 0
			exec	dbo.pr_Log_Ins	71, null, null, @s
	commit
end
go
grant	execute				on dbo.prCfgBed_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Clears all filter definitions
--	7.04.4898	* prCfgFlt_DelAll -> prCfgFlt_Clr
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgFlt_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgFlt
		select	@s= 'CfgFlt_Clr( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgFlt_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a filter definition
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
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
	--	begin
			insert	tbCfgFlt	(  idIdx,  iFilter,  sFilter )
					values		( @idIdx, @iFilter, @sFilter )
	--		select	@s= @s + ' INS.'
	--	end

		if	@iTrace & 0x40 > 0
		begin
			select	@s= 'CfgFlt_I( ' + isnull(cast(@idIdx as varchar), '?') + ', f=' + isnull(cast(@iFilter as varchar), '?') + ', n=' + isnull(@sFilter, '?') + ' )'
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgFlt_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Call priorities (current 790 global configuration)
--	7.04.4897	* tbDefCallP -> tbCfgPri, .idIdx -> .siIdx
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefCallP')
begin
	begin tran
		exec sp_rename 'tbDefCallP.idIdx',	'siIdx',			'column'

		exec sp_rename 'tbDefCallP',		'tbCfgPri',			'object'
		exec sp_rename 'tdDefCallP_Created','tdCfgPri_Created',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Clears all call-priority definitions
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	6.05
create proc		dbo.prCfgPri_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgPri
		select	@s= 'Pri_C( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgPri_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all locations, ordered to be loadable into a tree
--	7.04.4898
create proc		dbo.prCfgPri_GetAll
(
	@bEnabled	bit					--	0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	siIdx, sCall, tiFlags, tiShelf, tiSpec, iColorF, iColorB, iFilter, dtCreated
		,	cast(case when tiFlags & 0x02 > 0 then 1 else 0 end as bit) [bEnabled]
		,	cast(tiFlags & 0x01 as bit) [bLocking]
		from	tbCfgPri	with (nolock)
		where	@bEnabled = 0	or	tiFlags & 0x02 > 0
		order	by	1 desc
end
go
grant	execute				on dbo.prCfgPri_GetAll				to [rWriter]
grant	execute				on dbo.prCfgPri_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	7.03	+ @iFilter
--	6.05
create proc		dbo.prCfgPri_Ins
(
	@siIdx		smallint			-- call-index
,	@sCall		varchar( 16 )		-- call-text
,	@tiFlags	tinyint				-- bit flags: 1=locking, 2=enabled
,	@tiShelf	tinyint				-- shelf: 0=nondisplay, 1=routine, 2=urgent, 3=emergency, 4=code
,	@tiSpec		tinyint				-- 0=, 1=, .. , 18=
,	@iColorF	int					-- foreground color (ARGB) - text
,	@iColorB	int					-- background color (ARGB)
,	@iFilter	int					-- priority filter-mask
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
	--	begin
			insert	tbCfgPri	(  siIdx,  sCall,  tiFlags,  tiShelf,  tiSpec,  iColorF,  iColorB,  iFilter )
					values		( @siIdx, @sCall, @tiFlags, @tiShelf, @tiSpec, @iColorF, @iColorB, @iFilter )
	--		select	@s= @s + ' INS.'
	--	end

		if	@iTrace & 0x40 > 0
		begin
			select	@s= 'Pri_I( ' + isnull(cast(@siIdx as varchar), '?') + ', n=' + isnull(@sCall, '?') +
						', f=' + isnull(cast(@tiFlags as varchar), '?') + ', sh=' + isnull(cast(@tiShelf as varchar), '?') +
						', sp=' + isnull(cast(@tiSpec as varchar), '?') + ', cf=' + isnull(cast(@iColorF as varchar), '?') +
						', cb=' + isnull(cast(@iColorB as varchar), '?') + ', fm=' + isnull(cast(@iFilter as varchar), '?') + ' )'
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgPri_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Call-text definitions (historical)
--	7.04.4896	* tbDefCall -> tbCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefCall')
begin
	begin tran
		drop index	tbDefCall.xuDefCall_Active_sCall
		drop index	tbDefCall.xuDefCall_Active_siIdx

		exec sp_rename 'tbDefCall',			'tbCall',			'object'

		exec sp_rename 'tdDefCall_Enabled',	'tdCall_Enabled',	'object'
		exec sp_rename 'tdDefCall_tVoTrg',	'tdCall_tVoTrg',	'object'
		exec sp_rename 'tdDefCall_tStTrg',	'tdCall_tStTrg',	'object'
		exec sp_rename 'tdDefCall_Routing',	'tdCall_Routing',	'object'
		exec sp_rename 'tdDefCall_Override','tdCall_Override',	'object'
		exec sp_rename 'tdDefCall_tResp0',	'tdCall_tResp0',	'object'
		exec sp_rename 'tdDefCall_tResp1',	'tdCall_tResp1',	'object'
		exec sp_rename 'tdDefCall_tResp2',	'tdCall_tResp2',	'object'
		exec sp_rename 'tdDefCall_tResp3',	'tdCall_tResp3',	'object'
		exec sp_rename 'tdDefCall_Active',	'tdCall_Active',	'object'
		exec sp_rename 'tdDefCall_Created',	'tdCall_Created',	'object'
		exec sp_rename 'tdDefCall_Updated',	'tdCall_Updated',	'object'
	commit
end
go
if	not	exists	(select 1 from dbo.sysindexes where name='xuCall_Active_sCall')
begin
	begin tran
		create unique nonclustered index	xuCall_Active_sCall	on	dbo.tbCall ( sCall )	where	bEnabled > 0
		create unique nonclustered index	xuCall_Active_siIdx	on	dbo.tbCall ( siIdx )	where	bEnabled > 0
	commit
end
go
--	----------------------------------------------------------------------------
--	Call-text definitions (historical)
--	7.04.4917	* .tiRouting, .bOverride, .tResp0, .tResp1, .tResp2, .tResp3 -> + tbRouting
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCall') and name = 'tiRouting')
begin
	begin tran
		alter table	dbo.tbCall	drop constraint	tdCall_Routing
		alter table	dbo.tbCall	drop constraint	tdCall_Override
		alter table	dbo.tbCall	drop constraint	tdCall_tResp0
		alter table	dbo.tbCall	drop constraint	tdCall_tResp1
		alter table	dbo.tbCall	drop constraint	tdCall_tResp2
		alter table	dbo.tbCall	drop constraint	tdCall_tResp3

		alter table	dbo.tbCall	drop column	tiRouting
		alter table	dbo.tbCall	drop column	bOverride
		alter table	dbo.tbCall	drop column	tResp0
		alter table	dbo.tbCall	drop column	tResp1
		alter table	dbo.tbCall	drop column	tResp2
		alter table	dbo.tbCall	drop column	tResp3
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all call-priorities, ordered to be loadable into a table
--	7.04.4913	+ @bEnabled
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefCallP -> tbCfgPri
create proc		dbo.prCall_GetAll
(
	@bEnabled	bit					-- 0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	c.idCall, c.bEnabled, c.siIdx, c.sCall, c.tVoTrg, c.tStTrg, p.iColorF, p.iColorB, c.bActive, c.dtCreated, c.dtUpdated
		from	tbCall	c	with (nolock)
		inner join	tbCfgPri	p	with (nolock)	on	p.sCall = c.sCall	and p.siIdx = c.siIdx
		where	c.bActive > 0	and	p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)
		and		(@bEnabled = 0	or	c.bEnabled > 0)
		order	by	c.siIdx	desc
end
go
grant	execute				on dbo.prCall_GetAll				to [rWriter]
grant	execute				on dbo.prCall_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.04.4902
create proc		dbo.prCall_Upd
(
	@idCall		smallint
,	@bEnabled	bit
,	@tVoTrg		time( 0 )
,	@tStTrg		time( 0 )
,	@idUser		smallint
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	begin	tran
		update	tbCall	set	bEnabled= @bEnabled, tVoTrg= @tVoTrg, tStTrg= @tStTrg, dtUpdated= getdate( )
			where	idCall = @idCall

		select	@s= 'Call_U( ' + isnull(cast(@idCall as varchar), '?') + ', e=' + isnull(cast(@bEnabled as varchar), '?') +
					', v=' + isnull(cast(@tVoTrg as varchar), '?') + ', s=' + isnull(cast(@tStTrg as varchar), '?') + ' )'
		exec	dbo.pr_Log_Ins	72, @idUser, null, @s
	commit
end
go
grant	execute				on dbo.prCall_Upd					to [rWriter]
grant	execute				on dbo.prCall_Upd					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports call-texts from tbCfgPri
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
create proc		dbo.prCall_Imp
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

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall
		while	@@fetch_status = 0
		begin
	--		print	cast(@siIdx as varchar) + ': ' + @sCall
	--		select	@idCall= null, @idIdx= null
			select	@idCall= -1, @idIdx= -1
			select	@idIdx=  idCall		from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bEnabled > 0
			select	@idCall= idCall		from	tbCall	with (nolock)	where	sCall = @sCall	and	bEnabled > 0
	--		select	@idCall= isnull(@idCall,-1), @idIdx= isnull(@idIdx,-1)
	--		print	' byTxt=' + cast(@idCall as varchar) + ', byIdx=' + cast(@idIdx as varchar)

			if	@idCall < 0	or	@idIdx < 0	or	@idCall <> @idIdx
			begin
				if	@idCall > 0
	--				print	'  mark inactive byTxt ' + cast(@idCall as varchar)
					update	tbCall	set	bEnabled= 0, dtUpdated= getdate( )	where	idCall = @idCall
				if	@idIdx > 0
	--				print	'  mark inactive byIdx ' + cast(@idIdx as varchar)
					update	tbCall	set	bEnabled= 0, dtUpdated= getdate( )	where	idCall = @idIdx

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

/*		delete	from	BedDefinition
		insert	BedDefinition	(BedDefinitionID, Designator, DialableNumber)
			select	idIdx, cBed, cDial
			from	tbCfgBed	with (nolock)
*/
		select	@s= 'Call_Imp( ) added ' + cast(@iCount as varchar) + ' rows'
		exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prCall_Imp
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

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall
		while	@@fetch_status = 0
		begin
			select	@idCall= -1, @idIdx= -1
			select	@idIdx=  idCall		from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bEnabled > 0
			select	@idCall= idCall		from	tbCall	with (nolock)	where	sCall = @sCall	and	bEnabled > 0

			if	@idCall < 0	or	@idIdx < 0	or	@idCall <> @idIdx
			begin
				if	@idCall > 0
					update	tbCall	set	bEnabled= 0, dtUpdated= getdate( )	where	idCall = @idCall
				if	@idIdx > 0
					update	tbCall	set	bEnabled= 0, dtUpdated= getdate( )	where	idCall = @idIdx

				insert	tbCall	(  siIdx,  sCall )
						values	( @siIdx, @sCall )

				select	@iCount=	@iCount + 1
			end

			if	exists	(select 1 from dbo.CallPriority where ID = @siIdx)
				update	CallPriority	set	Name= @sCall
					where ID = @siIdx
			else
				insert	CallPriority	(ID, Name, FirstResponderTimer, SecondResponderTimer, ThirdResponderTimer, BackupTimer,
										CustomRouting, PageOverride, IsSpecial, ToneIndex, ToneInterval, BkColorIndex)
					values	( @siIdx, @sCall, ''02:00'', ''02:00'', ''02:00'', ''02:00'', 0, 0, 0, null, null, null)		

			fetch next from	cur	into	@siIdx, @sCall
		end
		close	cur
		deallocate	cur

/*		delete	from	BedDefinition
		insert	BedDefinition	(BedDefinitionID, Designator, DialableNumber)
			select	idIdx, cBed, cDial
			from	tbCfgBed	with (nolock)
*/
		select	@s= ''Call_Imp( ) added '' + cast(@iCount as varchar) + '' rows''
		exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end' )
go
grant	execute				on dbo.prCall_Imp					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.04.4896	* tbDefCall -> tbCall
--	6.05	+ (nolock), tracing
--	6.03
--	--	2.03
create proc		dbo.prCall_GetIns
(
	@siIdx		smallint			-- call-index
,	@sCall		varchar( 16 )		-- call-text
,	@idCall		smallint out		-- output
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@idCall= idCall
			from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0

	if	@idCall is null
		select	@idCall= idCall
			from	tbCall	with (nolock)	where	sCall = @sCall	and	bActive > 0

	if	@idCall is null
	begin
		begin	tran
			insert	tbCall	(  siIdx,  sCall )
					values		( @siIdx, @sCall )
			select	@idCall=	scope_identity( )

			select	@s= 'Call_I( ' + isnull(cast(@siIdx as varchar), '?') + ', n=' + isnull(@sCall, '?') + ' )  id=' + cast(@idCall as varchar)
			exec	dbo.pr_Log_Ins	72, null, null, @s
		commit
	end
end
go
grant	execute				on dbo.prCall_GetIns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Location definitions
--	7.04.4892	* tbDefLoc -> tbCfgLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefLoc')
begin
	begin tran
		exec sp_rename 'tbDefLoc',			'tbCfgLoc',			'object'

		exec sp_rename 'tbDefLoc_Created',	'tdCfgLoc_Created',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Coverage areas and their units
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.03	* vwDefLoc_CaUnit -> vwDefLoc_Cvrg, .idCArea -> .idCvrg, .sCArea -> .sCvrg
--	7.00
create view		dbo.vwCfgLoc_Cvrg
	with encryption
as
select ca.idLoc [idCvrg], ca.sLoc [sCvrg], u.idLoc [idUnit], u.sLoc [sUnit]
	from	tbCfgLoc	ca	with (nolock)
	inner join	tbCfgLoc u	with (nolock)	on	u.idLoc = ca.idParent	and	u.tiLvl = 4
	where	ca.tiLvl = 5
go
grant	select, insert, update			on dbo.vwCfgLoc_Cvrg	to [rWriter]
grant	select							on dbo.vwCfgLoc_Cvrg	to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all locations, ordered to be loadable into a tree
--	7.04.4892	* tbDefLoc -> tbCfgLoc
create proc		dbo.prCfgLoc_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLoc, idParent, cLoc, sLoc, tiLvl
		,	case when tiLvl = 0 then 'Facility'
				when tiLvl = 1 then 'System'
				when tiLvl = 2 then 'Building'
				when tiLvl = 3 then 'Floor'
				when tiLvl = 4 then 'Unit'
				when tiLvl = 5 then 'Cvrg Area'	end [sLvl]
		,	dtCreated,	cast(1 as bit) [bActive]
		from	tbCfgLoc	with (nolock)
	--	where	tiLvl < 5		--	everything but coverage areas
		order	by	tiLvl, idLoc
end
go
grant	execute				on dbo.prCfgLoc_GetAll				to [rWriter]
grant	execute				on dbo.prCfgLoc_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all location definitions
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	6.05
create proc		dbo.prCfgLoc_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgLoc
		select	@s= 'Loc_C( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgLoc_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.00	* format idLoc as '000'
--	6.05
create proc		dbo.prCfgLoc_Ins
(
	@idLoc		smallint			-- call-index
,	@idParent	smallint			-- parent look-up FK
,	@tiLvl		tinyint				-- level: 0=Facility 1=System 2=Building 3=Floor 4=Unit 5=CoverageArea
,	@cLoc		char( 1 )			-- type:  H=Hospital S=System B=Building F=Floor U=Unit C=CoverageArea
,	@sLoc		varchar( 16 )		-- location name
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		insert	tbCfgLoc	(  idLoc,  idParent,  tiLvl,  cLoc,  sLoc )
				values		( @idLoc, @idParent, @tiLvl, @cLoc, @sLoc )

		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', p=' + isnull(cast(@idParent as varchar), '?') +
						', l=' + isnull(cast(@tiLvl as varchar), '?') + ', c=' + isnull(@cLoc, '?') + ', n=' + isnull(@sLoc, '?') + ' )'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgLoc_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Units
--	7.04.4967	- .iStamp
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbUnit') and name = 'iStamp')
begin
	begin tran
		alter table	dbo.tbUnit		drop column		iStamp
	commit
end
go
--	----------------------------------------------------------------------------
/*declare	@idUnit		smallint
	,	@s			varchar( 255 )

select	@idUnit= min( idUnit )
	from	tbUnit

select	@s=	'insert	tbShift	( idShift, idUnit, tiIdx, sShift, tBeg, tEnd, iStamp, bActive )
					values	( 0, ' + cast(@idUnit as varchar) + ', 0, ''SHIFT 00'', ''0:0:0'', ''0:0:0'', 0, 0 )'
*/
go
--	----------------------------------------------------------------------------
--	create Unit-0 and Shift-0
begin tran

	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnit_CurrShift')
		alter table	dbo.tbUnit	drop constraint fkUnit_CurrShift
	if exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnit_PrevShift')
		alter table	dbo.tbUnit	drop constraint fkUnit_PrevShift


	if	not	exists	(select 1 from dbo.tbUnit where idUnit = 0)
	begin
		if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbUnit') and name = 'iStamp')
			exec( 'insert	tbUnit	( idUnit, sUnit, tiShifts, idShift, idShPrv, iStamp, bActive )
					values	( 0, ''INTERNAL UNIT 00'', 1, 0, 0, 0, 0 )' )
		else
			insert	tbUnit	( idUnit, sUnit, tiShifts, idShift, idShPrv, bActive )
					values	( 0, 'INTERNAL UNIT 00', 1, 0, 0, 0 )
	end

	if	not	exists	(select 1 from dbo.tbShift where idShift = 0)
	begin
		set identity_insert	dbo.tbShift	on

		if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbShift') and name = 'iStamp')
			exec( 'insert	tbShift	( idShift, idUnit, tiIdx, sShift, tBeg, tEnd, iStamp, bActive )
					values	( 0, 0, 0, ''SHIFT 00'', ''0:0:0'', ''0:0:0'', 0, 0 )' )
		else
			insert	tbShift	( idShift, idUnit, tiIdx, sShift, tBeg, tEnd, bActive )
					values	( 0, 0, 0, 'SHIFT 00', '0:0:0', '0:0:0', 0 )

		set identity_insert	dbo.tbShift	off
	end

	update	tbShift		set	idUnit= 0
		where	idShift = 0


	if	not	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnit_CurrShift')
		alter table	tbUnit	add
			constraint	fkUnit_CurrShift	foreign key (idShift) references tbShift
		,	constraint	fkUnit_PrevShift	foreign key (idShPrv) references tbShift

commit
go
--	----------------------------------------------------------------------------
--	Returns all units, ordered to be loadable into a tree
--	7.04.4892	* tbDefLoc -> tbCfgLoc
alter proc		dbo.prUnit_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	u.idUnit, u.sUnit
		from	tbUnit u	with (nolock)
		inner join	tbCfgLoc l	with (nolock)	on	l.idLoc = u.idUnit
		where	u.bActive > 0
		order	by	u.sUnit
end
go
--	----------------------------------------------------------------------------
--	Role-Unit access
--	7.04.4919
create table	dbo.tb_RoleUnit
(
	idRole		smallint		not null
		constraint	fk_RoleUnit_Role	foreign key references	tb_Role
,	idUnit		smallint		not null
		constraint	fk_RoleUnit_Unit	foreign key references	tbUnit

,	dtCreated	smalldatetime	not null	-- internal: record creation
		constraint	td_RoleUnit_Created	default( getdate( ) )

,	constraint	xp_RoleUnit	primary key clustered ( idRole, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tb_RoleUnit		to [rWriter]
grant	select							on dbo.tb_RoleUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Teams
--	7.04.4947	set idTeam seed to 16:  IDs 1..15 are reserved
create table	dbo.tbTeam
(
	idTeam		smallint not null	identity( 16, 1 )
		constraint	xpTeam		primary key clustered

,	sTeam		varchar( 16 ) not null		-- team-name
,	s_Team		as	lower( sTeam )			-- team-name, lower-cased (forced)
		constraint	xuTeam	unique				--	auto-index on automatic field
,	sDesc		varchar( 255 ) not null		-- description

,	tResp		time( 0 ) not null			-- response time
		constraint	tdTeam_Resp		default( '00:02:00' )

,	bActive		bit not null				-- "deletion" marks inactive
		constraint	tdTeam_Active	default( 1 )
,	dtCreated	smalldatetime not null		-- internal: record creation
		constraint	tdTeam_Created	default( getdate( ) )
,	dtUpdated	smalldatetime not null		-- internal: last modified
		constraint	tdTeam_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tbTeam			to [rWriter]
grant	select, insert, update			on dbo.tbTeam			to [rReader]
go
--	----------------------------------------------------------------------------
--	Call priority-team membership
--	7.04.4947
create table	dbo.tbTeamPri
(
	siIdx		smallint		not null
		constraint	fkTeamPri_Pri		foreign key references tbCfgPri
,	idTeam		smallint		not null
		constraint	fkTeamPri_Team	foreign key references tbTeam

,	dtCreated	smalldatetime	not null	-- internal: record creation
		constraint	tdTeamPri_Created	default( getdate( ) )

,	constraint	xpTeamPri		primary key clustered ( siIdx, idTeam )
)
go
grant	select, insert,			delete	on dbo.tbTeamPri		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamPri		to [rReader]
go
--	----------------------------------------------------------------------------
--	Call priority-team membership
--	7.04.4947
create table	dbo.tbTeamUnit
(
	idUnit		smallint		not null
		constraint	fkTeamUnit_Unit		foreign key references tbUnit
,	idTeam		smallint		not null
		constraint	fkTeamUnit_Team	foreign key references tbTeam

,	dtCreated	smalldatetime	not null	-- internal: record creation
		constraint	tdTeamUnit_Created	default( getdate( ) )

,	constraint	xpTeamUnit		primary key clustered ( idUnit, idTeam )
)
go
grant	select, insert,			delete	on dbo.tbTeamUnit		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff-team membership
--	7.04.4947
create table	dbo.tbTeamStaff
(
	idStaff		int				not null
		constraint	fkTeamStaff_Staff	foreign key references tb_User
,	idTeam		smallint		not null
		constraint	fkTeamStaff_Team	foreign key references tbTeam

,	dtCreated	smalldatetime	not null	-- internal: record creation
		constraint	tdTeamStaff_Created	default( getdate( ) )

,	constraint	xpTeamStaff		primary key clustered ( idStaff, idTeam )
)
go
grant	select, insert,			delete	on dbo.tbTeamStaff		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamStaff		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all devices, ordered to be loadable into a tree
--	7.04.4965	* restrict to known 790-devices
--	7.03
alter proc		dbo.prDevice_GetAll
(
	@tiKind		tinyint		-- 0 = top-level (no parent), >0 = children
)
	with encryption
as
begin
--	set	nocount	on
	if	@tiKind = 0
		select	idDevice, idParent, cDevice, sDevice, sDial
			from	tbDevice	with (nolock)
			where	idParent is null
			and		tiStype > 0
	--		and		bActive > 0
			order	by	tiGID, sDevice
	else
		select	idDevice, idParent, cDevice, sDevice, sDial
			from	tbDevice	with (nolock)
			where	idParent > 0
			and		tiStype > 0
	--		and		bActive > 0
			order	by	idParent, sDevice
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices
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
	declare		@iTrace		int
	declare		@s			varchar( 255 )
	declare		@idUnit		smallint
	declare		@sUnits		varchar( 255 )
	
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

	begin	tran

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
				', aid=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') + ', c=' + @cDevice +
				', n=' + @sDevice + ', d=' + isnull(@sDial,'?') + ' )'

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
--	Clears all master attributes
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgMst_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgMst
		select	@s= 'Mst_C( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a master attributes record
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
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	if	@tiCvrg = 0xFF		select	@tiCvrg= 0		--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgMst with (nolock) where idMaster = @idMaster and tiCvrg = @tiCvrg)
	begin
		begin	tran
			insert	tbCfgMst	(  idMaster,  tiCvrg,  iFilter )
					values		( @idMaster, @tiCvrg, @iFilter )

			if	@iTrace & 0x40 > 0
			begin
				select	@s= 'Mst_I( ' + isnull(cast(@idMaster as varchar), '?') +
							', c=' + isnull(cast(@tiCvrg as varchar), '?') + ', f=' + isnull(cast(@iFilter as varchar), '?') + ' )'
				exec	dbo.pr_Log_Ins	72, null, null, @s
			end
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Clears all device button inputs
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgDvcBtn_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgDvcBtn
		select	@s= 'DvcBtn_C( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a device button input
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgDvcBtn_Ins
(
	@idDevice	smallint			-- device (PK)
,	@tiBtn		tinyint				-- button code (0-31)
,	@siPri		smallint			-- priority (0-1023)
,	@tiBed		tinyint				-- bed index (0-9, null==None)
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	if	@tiBed = 0xFF		select	@tiBed= null	--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgDvcBtn with (nolock) where idDevice = @idDevice and tiBtn = @tiBtn)
	begin
		begin	tran
			insert	tbCfgDvcBtn	(  idDevice,  tiBtn,  siPri,  tiBed )
					values		( @idDevice, @tiBtn, @siPri, @tiBed )

			if	@iTrace & 0x40 > 0
			begin
				select	@s= 'DvcBtn_I( ' + isnull(cast(@idDevice as varchar), '?') + ', b=' + isnull(cast(@tiBtn as varchar), '?') +
							', p=' + isnull(cast(@siPri as varchar), '?') + ', b=' + isnull(cast(@tiBed as varchar), '?') + ' )'
				exec	dbo.pr_Log_Ins	72, null, null, @s
			end
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Staff definitions
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
select	idUser [idStaff], sStaffID, sFirst, sMid, sLast, s.idStfLvl, l.sStfLvl, l.iColorB, bOnDuty
	,	sStaff, l.sStfLvl + ' (' + cast(sStaffID as varchar) + ') ' + sStaff [sFqStaff]
	,	bActive, dtCreated, dtUpdated
	from	tb_User	s	with (nolock)
		inner join	tbStfLvl	l	with (nolock)	on	l.idStfLvl = s.idStfLvl
	where	s.idStfLvl is not null				--	only 'staff' users
go
--	----------------------------------------------------------------------------
--	Returns active staff, ordered to be loadable into a dropdown
--	7.04.4953
create proc		dbo.prStaff_LstAct
	with encryption
as
begin
	select	s.idStaff, s.sFqStaff + case
				when b.lCount = 1 then ' -- [' + cast(b.idStfDvc as varchar) + ']'
	--			when b.lCount > 1 then ' -- ' + cast(b.lCount as varchar) + ' badges'
				when b.lCount > 1 then ' -- [' + cast(b.idStfDvc as varchar) + '], +' + cast(b.lCount-1 as varchar)
				else '' end		[sFqStaff]
		,	s.iColorB
		from	vwStaff	s	with (nolock)
		left outer join	(select	idStaff, count(*) [lCount], min(idStfDvc) [idStfDvc]	from	tbStfDvc	with (nolock)	group by idStaff) b	on	b.idStaff = s.idStaff
		where	bActive > 0
		order	by	idStfLvl desc, sStaff
end
go
grant	execute				on dbo.prStaff_LstAct				to [rWriter]
grant	execute				on dbo.prStaff_LstAct				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns [active?] staff, ordered to be loadable into a table
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4913	+ @bActive
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.03
create proc		dbo.prStaff_GetAll
(
	@bActive	bit					-- 0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	idStaff, cast(1 as bit) [bInclude], sStaffID, sStaff, sStfLvl, iColorB
		from	vwStaff	with (nolock)
		where	(@bActive = 0	or	bActive > 0)
		order	by	idStfLvl desc, sStaff
end
go
grant	execute				on dbo.prStaff_GetAll				to [rWriter]
grant	execute				on dbo.prStaff_GetAll				to [rReader]
go
/*
--	----------------------------------------------------------------------------
--	Updates staff's formatted name
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.01	* add width enforcement
--	6.05
alter proc		dbo.prStaff_sStaff_Upd
(
	@idStaff	int							-- null = entire table
,	@tiFmt		tinyint						-- null = use tb_OptSys[11]
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

		select	@tiFmt= cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 11
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
			update	tb_OptSys	set	iValue= @tiFmt	where	idOption = 11

	commit
end
*/
go
/*
--	----------------------------------------------------------------------------
--	Inserts or updates staff
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.00	tbStaff.tiPtype -> .idStaffLvl
--	6.05	fixed tbStaff insertion (required .sStaff not supplied) and prStaff_sStaff_Upd call
--			+ (nolock), + .sStaff
--	6.02
--	6.01
alter proc		dbo.prStaff_InsUpdDel
(
	@idStaff	int							-- internal
,	@bActive	bit							-- "deletion" marks inactive
,	@lStaffID	bigint						-- external Staff ID
--,	@sStaffID	varchar( 16 )				-- external Staff ID
,	@idStfLvl	tinyint						-- 4=RN, 2=CNA, 1=Aide, ..
,	@sFirst		varchar( 16 )				-- first name
,	@sMid		varchar( 16 )				-- middle name
,	@sLast		varchar( 16 )				-- last name
,	@idUser		smallint					-- user look-up FK
,	@iStamp		int							-- row-version counter
)
	with encryption
as
begin
	set	nocount	on
	if	@idStaff is null	--	and	len(@sStaffID) > 0
		select	@idStaff= idStaff		from	tbStaff		with (nolock)
				where	bActive >0	and	lStaffID = @lStaffID

	begin	tran

		if	@bActive > 0
		begin
			if	@idStaff is null
			begin
				insert	tbStaff	(  bActive,  lStaffID,  idStfLvl,  sFirst,  sMid,  sLast,  idUser,  iStamp, sStaff )
						values	( @bActive, @lStaffID, @idStfLvl, @sFirst, @sMid, @sLast, @idUser, @iStamp, '?' )
				select	@idStaff=	scope_identity( )
			end
			else
				update	tbStaff	set
						bActive= @bActive, lStaffID= @lStaffID, idStfLvl= @idStfLvl, sFirst= @sFirst,
						sMid= @sMid, sLast= @sLast, idUser= @idUser, iStamp= @iStamp, dtUpdated= getdate( )
					where	idStaff = @idStaff

			exec	prStaff_sStaff_Upd	@idStaff, null
		end
		else
		begin
			--	TODO:	deactivate and close everything associated with that Staff

				update	tbStaff	set
						bActive= @bActive, dtUpdated= getdate( )
					where	idStaff = @idStaff
		end

	commit
end
*/
go
--	----------------------------------------------------------------------------
--	User-Unit membership
--	7.04.4919	* tbStfUnit -> tb_UserUnit
--				.idStaff: FK -> tb_User
--	7.04.4897	* tbStaffUnit -> tbStfUnit
--	7.00
create table	dbo.tb_UserUnit
(
	idStaff		int				not null
--		constraint	fkStfUnit_Staff		foreign key references	tbStaff
		constraint	fk_UserUnit_User	foreign key references	tb_User
,	idUnit		smallint		not null
		constraint	fk_UserUnit_Unit	foreign key references	tbUnit

,	dtCreated	smalldatetime	not null	-- internal: record creation
		constraint	td_UserUnit_Created	default( getdate( ) )

,	constraint	xp_UserUnit		primary key clustered ( idStaff, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tb_UserUnit		to [rWriter]
grant	select							on dbo.tb_UserUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff device types
--	7.04.4919	* tbStfDvcType -> tbDvcType, .idStfDvcType -> .idDvcType, .sStfDvcType -> .sDvcType
--	7.04.4897	* tbStaffDvcType -> tbStfDvcType, .idStaffDvcType -> .idStfDvcType, .sStaffDvcType -> .sStfDvcType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvcType')
begin
	begin tran
		exec sp_rename 'tbStaffDvcType.idStaffDvcType',	'idDvcType',	'column'
		exec sp_rename 'tbStaffDvcType.sStaffDvcType',	'sDvcType',		'column'

		exec sp_rename 'tbStaffDvcType',		'tbDvcType',			'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Staff device definitions (Badge/Pager/Phone)
--	7.04.4947	.bGroup, .bTech -> .tiFlags
--	7.04.4939	+ .sBarCode
--	7.04.4919	* tbStfDvcType -> tbDvcType, .idStfDvcType -> .idDvcType, .sStfDvcType -> .sDvcType
--				.idStaff: FK -> tb_User
--				* .bTechno -> .bTech (tdStfDvc_Techno -> tdStfDvc_Tech), - .tiLines, - .tiChars
--	7.04.4897	* tbStaffDvcType -> tbStfDvcType, .idStaffDvcType -> .idStfDvcType, .sStaffDvcType -> .sStfDvcType
--				* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvc')
begin
	begin tran
		drop index	tbStaffDvc.xuStaffDvc_Active

		exec sp_rename 'tbStaffDvc.idStaffDvcType',	'idDvcType',	'column'
		exec sp_rename 'tbStaffDvc.idStaffDvc',		'idStfDvc',		'column'
		exec sp_rename 'tbStaffDvc.sStaffDvc',		'sStfDvc',		'column'
		exec sp_rename 'tbStaffDvc.bTechno',		'bTech',		'column'

		exec sp_rename 'tbStaffDvc',		'tbStfDvc',			'object'

		exec sp_rename 'tdStaffDvc_Group',	'tdStfDvc_Group',	'object'
		exec sp_rename 'tdStaffDvc_Techno',	'tdStfDvc_Tech',	'object'
		exec sp_rename 'tdStaffDvc_Active',	'tdStfDvc_Active',	'object'
		exec sp_rename 'tdStaffDvc_Created','tdStfDvc_Created',	'object'
		exec sp_rename 'tdStaffDvc_Updated','tdStfDvc_Updated',	'object'

	commit
	begin tran
		alter table	dbo.tbStfDvc	drop column	tiLines
		alter table	dbo.tbStfDvc	drop column	tiChars

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffDvc_Staff')
		begin
			alter table	dbo.tbStfDvc	drop constraint	fkStaffDvc_Staff
			alter table	dbo.tbStfDvc	add
				constraint	fkStfDvc_Staff	foreign key	(idStaff)	references tb_User
		end
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvc')
	and	not	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbStfDvc') and name='tiFlags')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStfDvc_Group')
			alter table	dbo.tbStfDvc	drop constraint	tdStfDvc_Group
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStfDvc_Tech')
			alter table	dbo.tbStfDvc	drop constraint	tdStfDvc_Tech
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStfDvc_Techno')
			alter table	dbo.tbStfDvc	drop constraint	tdStfDvc_Techno
		alter table	dbo.tbStfDvc	drop column	bGroup
		alter table	dbo.tbStfDvc	drop column	bTech
		alter table	dbo.tbStfDvc	add
			tiFlags		tinyint			not null	-- 1=group, 2=tech
				constraint	tdStfDvc_Flags		default( 0 )
	commit
end
go
if	not	exists	(select 1 from dbo.sysindexes where name='xuStfDvc_Active')
begin
	begin tran
		create unique nonclustered index	xuStfDvc_Active		on dbo.tbStfDvc ( sStfDvc )		where bActive > 0
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given device's staff
--	7.04.4897	* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.03
create proc		dbo.prStfDvc_UpdStf
(
	@idStfDvc	int							-- badge id
,	@idStaff	int							-- who is this device currently assigned to?
)
	with encryption
as
begin
--	set	nocount	on
	begin	tran
		update	tbStfDvc	set idStaff= @idStaff,	dtUpdated= getdate( )
			where	idStfDvc = @idStfDvc
	commit
end
go
grant	execute				on dbo.prStfDvc_UpdStf				to [rWriter]
grant	execute				on dbo.prStfDvc_UpdStf				to [rReader]
go
--	----------------------------------------------------------------------------
--	StaffDvc-Unit membership
--	7.04.4897	* tbStaffDvcUnit -> tbStfDvcUnit, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.00
create table	dbo.tbStfDvcUnit
(
	idStfDvc	int			not null
		constraint	fkStfDvcUnit_StfDvc	foreign key references tbStfDvc
,	idUnit		smallint	not null
		constraint	fkStfDvcUnit_Unit	foreign key references tbUnit

,	dtCreated	smalldatetime	not null	-- internal: record creation
		constraint	tdStfDvcUnit_Created	default( getdate( ) )

,	constraint	xpStfDvcUnit	primary key clustered ( idStfDvc, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tbStfDvcUnit		to [rWriter]
grant	select							on dbo.tbStfDvcUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms'
--	7.04.4892	* vwRoomAct -> vwRoom,	match output to vwDevice
--	7.03		vwRoom -> vwRoomAct
create view		dbo.vwRoom
	with encryption
as
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2) + '-' + right('0' + cast(tiRID as varchar), 2)	[sSGJR]
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		[sSGJ]
	,	'[' + cDevice + '] ' + sDevice		[sQnDevice]
	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	[sFnDevice]
	,	r.idEvent,	r.tiSvc,	r.idRn, r.sRn,	r.idCn, r.sCn,	r.idAi, r.sAi
	,	bActive, dtCreated, d.dtUpdated
	from	tbDevice d	with (nolock)
	inner join	tbRoom r	with (nolock)	on	r.idRoom = d.idDevice
go
grant	select, insert, update			on dbo.vwRoom			to [rWriter]
grant	select							on dbo.vwRoom			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active rooms, ordered to be loadable into a combobox
--	7.04.4959	prRoom_GetAct -> prRoom_LstAct
--	7.04.4953	* added ' '
--	7.03
create proc		dbo.prRoom_LstAct
	with encryption
as
begin
--	set	nocount	on
	select	idDevice	[idRoom],		sSGJ + ' ' + sQnDevice	[sQnRoom]
		from	vwRoom	with (nolock)
		where	bActive > 0
		order	by	2
end
go
grant	execute				on dbo.prRoom_LstAct				to [rWriter]
grant	execute				on dbo.prRoom_LstAct				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates room's staff
--	7.04.4953	* 
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.03	+ @idUnit
--	7.02	* tbRoomStaff -> tbRoom (prRoomStaff_Upd -> prRoom_Upd)
--			* fill in idStaff's as well
--	6.05
alter proc		dbo.prRoom_Upd
(
	@idRoom		smallint			-- 790 device look-up FK
,	@idUnit		smallint			-- active unit ID
,	@sRn		varchar( 16 )
,	@sCn		varchar( 16 )
,	@sAi		varchar( 16 )
)
	with encryption
as
begin
	declare		@idRn		int
	declare		@idCn		int
	declare		@idAi		int

	set	nocount	on

--	if	not	exists	(select 1 from tbCfgLoc where idLoc = @idUnit and tiLvl = 4)	select	@idUnit= null
	if	not	exists	(select 1 from tbUnit where idUnit = @idUnit)	select	@idUnit= null

--	if	len( @sRn ) > 0		select	@idRn= idStaff	from	tbStaff with (nolock)	where	sStaff = @sRn
--	if	len( @sCn ) > 0		select	@idCn= idStaff	from	tbStaff with (nolock)	where	sStaff = @sCn
--	if	len( @sAi ) > 0		select	@idAi= idStaff	from	tbStaff with (nolock)	where	sStaff = @sAi

	if	len( @sRn ) > 0		select	@idRn= idUser	from	tb_User with (nolock)	where	sStaff = @sRn
	if	len( @sCn ) > 0		select	@idCn= idUser	from	tb_User with (nolock)	where	sStaff = @sCn
	if	len( @sAi ) > 0		select	@idAi= idUser	from	tb_User with (nolock)	where	sStaff = @sAi

	begin	tran
		update	tbRoom	set	idUnit= @idUnit,	dtUpdated= getdate( )
						,	idRn= @idRn, sRn= @sRn,	idCn= @idCn, sCn= @sCn,	idAi= @idAi, sAi= @sAi
			where	idRoom = @idRoom
	commit
end
go
--	----------------------------------------------------------------------------
if	not	exists	(select 1 from dbo.sysindexes where name='xuPatient_Loc')
begin
	begin tran
		update	tbPatient	set	idRoom= null, tiBed= null
		update	tbRoomBed	set	idPatient= null

		create unique nonclustered index	xuPatient_Loc	on dbo.tbPatient ( idRoom, tiBed )	where	idRoom is not null	and tiBed is not null	-- + 7.04.4955
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed
--	7.04.4953	* fix comparison logic for nulls
--	7.03
alter proc		dbo.prPatient_UpdLoc
(
	@idPatient	int
,	@cSys		char( 1 )			-- system
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiRID		tinyint				-- R-ID - R-bus
,	@tiBed		tinyint				-- bed index, 0xFF == no bed in room
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
	,			@idRoom		smallint
	,			@idCurr		smallint
	,			@tiCurr		tinyint

	set	nocount	on

--	select	@s=	'Pat_U( id=' + isnull(cast(@idPatient as varchar),'?') +
--				', p=' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
--				', n=' + isnull(@sNote,'?') + ', a=' + cast(@bActive as varchar) + ' )'

	select	@idRoom= idDevice
		from	vwRoom	with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	bActive > 0
	select	@idCurr= idRoom, @tiCurr= tiBed
		from	tbPatient	with (nolock)
		where	idPatient = @idPatient

	if	@idRoom <> @idCurr	or	@tiBed <> @tiCurr
		or	@idRoom is null	and	@idCurr > 0
		or	@idRoom > 0	and	@idCurr is null
		or	@tiBed is null	and	@tiCurr > 0
		or	@tiBed > 0	and	@tiCurr is null
	begin
		begin	tran
			--	bump any other patient from the given room-bed
			update	tbPatient	set	dtUpdated= getdate( ),	idRoom= null, tiBed= null
				where	idRoom = @idRoom	and	tiBed = @tiBed	and	idPatient <> @idPatient

			--	record the given patient into the given room-bed
			update	tbPatient	set	dtUpdated= getdate( ),	idRoom= @idRoom, tiBed= @tiBed
				where	idPatient = @idPatient

			--	update the given room-bed with the given patient
			update	tbRoomBed	set	idPatient= @idPatient
				where	idRoom = @idRoom	and	tiBed = @tiBed
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	System activity log
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
select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, dtEvent, dEvent, tEvent, tiHH, idCmd, tiBtn, e.idRoom, r.sDevice [sRoom], e.tiBed, b.cBed, e.idUnit,
		e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID, e.idSrcDvc, sd.sDevice [sSrcDvc], sd.cDevice [cSrcDvc], sd.sDial [sSrcDial],
		e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID, e.idDstDvc, dd.sDevice [sDstDvc], dd.cDevice [cDstDvc], dd.sDial [sDstDial],
		e.idLogType, et.sLogType, e.idCall, c.sCall, sInfo
	from	tbEvent	e	with (nolock)
	left outer join	tbCall	c	with (nolock)	on	c.idCall = e.idCall
	left outer join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
	left outer join	tb_LogType	et	with (nolock)	on	et.idLogType = e.idLogType
	left outer join	tbDevice	sd	with (nolock)	on	sd.idDevice = e.idSrcDvc
	left outer join	tbDevice	dd	with (nolock)	on	dd.idDevice = e.idDstDvc
	left outer join	tbDevice	r	with (nolock)	on	r.idDevice = e.idRoom
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	sd.idDevice, sd.sDevice, sd.sQnDevice, sd.tiStype, sd.sSGJR + '-' + right('0' + cast(ea.tiBtn as varchar), 2) [sSGJRB]
	,	ea.idRoom, r.sDevice [sRoom],	ea.tiBed, b.cBed,	rm.idUnit
	,	ea.idCall, c.siIdx, c.sCall, p.iColorF, p.iColorB, p.tiShelf, p.tiSpec, p.iFilter
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit ) [bAnswered]
	,	ea.tiSvc, getdate( ) - ea.dtEvent [tElapsed], ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	from	tbEvent_A	ea	with (nolock)
	left outer join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left outer join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left outer join	tbRoom	rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left outer join	tbCall	c	with (nolock)	on	c.idCall = ea.idCall
	left outer join	tbCfgPri	p	with (nolock)	on	p.siIdx = c.siIdx
	left outer join	tbCfgBed	b	with (nolock)	on	b.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	System activity log: call events
--	7.04.4897	* tbEvent_C:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt, .idRn -> .idEvtRn, .idCn -> .idEvtCn, .idAi -> .idEvtAi
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'idVoice')
begin
	begin tran
		exec sp_rename 'tbEvent_C.idVoice',	'idEvtVo',	'column'
		exec sp_rename 'tbEvent_C.idStaff',	'idEvtSt',	'column'
		exec sp_rename 'tbEvent_C.idRn',	'idEvtRn',	'column'
		exec sp_rename 'tbEvent_C.idCn',	'idEvtCn',	'column'
		exec sp_rename 'tbEvent_C.idAi',	'idEvtAi',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
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
select	ec.idEvent, ec.dEvent, ec.tEvent, ec.tiHH, ec.idCall, c.sCall,
		ec.idRoom, d.cDevice, d.sDevice, d.sDial, ec.idUnit, u.sUnit,
		ec.cBed, ec.idEvtVo, ec.tVoice, ec.idEvtSt, ec.tStaff,
		ec.idEvtRn, ec.tRn, ec.idEvtCn, ec.tCn, ec.idEvtAi, ec.tAi
	from	tbEvent_C	ec	with (nolock)
	inner join	tbCall	c	with (nolock)	on	c.idCall = ec.idCall
	inner join	tbDevice	d	with (nolock)	on	d.idDevice = ec.idRoom
	left outer join	tbUnit	u	with (nolock)	on	u.idUnit = ec.idUnit
go
--	----------------------------------------------------------------------------
--	System activity log: parent events
--	7.04.4897	* tbEvent_T:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_T') and name = 'idVoice')
begin
	begin tran
		exec sp_rename 'tbEvent_T.idVoice',	'idEvtVo',	'column'
		exec sp_rename 'tbEvent_T.idStaff',	'idEvtSt',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.04.4897	* tbEvent_T:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	tbDefLoc -> tbUnit;		.sLoc -> .sUnit
--	7.02	* .idCna -> .idCn, .idAide -> .idAi
--	6.05	+ (nolock)
--	6.03	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbDefDevice -> tbDevice (FKs)
--			tbEvent? -> tbEvent_? (A, C, P, T)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	5.01
alter view		dbo.vwEvent_T
	with encryption
as
select	et.idEvent, et.dEvent, et.tEvent, et.tiHH, et.idCall, c.sCall,
		et.idRoom, d.cDevice, d.sDevice, d.sDial, et.idUnit, u.sUnit,
		et.cBed, et.idEvtVo, et.tVoice, et.idEvtSt, et.tStaff,
		et.tRn, et.tCn, et.tAi
	from	tbEvent_T	et	with (nolock)
	inner join	tbCall	c	with (nolock)	on	c.idCall = et.idCall
	inner join	tbDevice	d	with (nolock)	on	d.idDevice = et.idRoom
	left outer join	tbUnit	u	with (nolock)	on	u.idUnit = et.idUnit
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoomBed') and name = 'idAsnRn')
begin
	begin tran
		exec sp_rename 'tbRoomBed.idAsnRn',	'idAssn1',	'column'
		exec sp_rename 'tbRoomBed.idAsnCn',	'idAssn2',	'column'
		exec sp_rename 'tbRoomBed.idAsnAi',	'idAssn3',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
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
	,	p.idPatient	--, p.sPatient, p.cGender, p.sInfo, p.sNote
	,	p.idDoctor		--, d.sDoctor
	,	rb.idAssn1, a1.sStaff [sAssn1], a1.idStfLvl [idStLvl1]	--, a1.sStaffLvl [sStLvl1], a1.iColorB [iColorB1]
	,	rb.idAssn2, a2.sStaff [sAssn2], a2.idStfLvl [idStLvl2]	--, a2.sStaffLvl [sStLvl2], a2.iColorB [iColorB2]
	,	rb.idAssn3, a3.sStaff [sAssn3], a3.idStfLvl [idStLvl3]	--, a3.sStaffLvl [sStLvl3], a3.iColorB [iColorB3]
	,	r.idRn [idRegRn], r.sRn [sRegRn],	r.idCn [idRegCn], r.sCn [sRegCn],	r.idAi [idRegAi], r.sAi [sRegAi]
	,	/*rb.bActive, rb.dtCreated,*/ rb.dtUpdated		/*	don't exist	*/
	from	tbRoomBed	rb	with (nolock)
		inner join		tbDevice	d	with (nolock)	on	d.idDevice = rb.idRoom		and	d.bActive > 0
		inner join		tbRoom		r	with (nolock)	on	r.idRoom = rb.idRoom
---		left outer join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0
		left outer join	tbPatient	p	with (nolock)	on	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed	--	p.idPatient = rb.idPatient
---		left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		left outer join	vwStaff		a1	with (nolock)	on	a1.idStaff = rb.idAssn1
		left outer join	vwStaff		a2	with (nolock)	on	a2.idStaff = rb.idAssn2
		left outer join	vwStaff		a3	with (nolock)	on	a3.idStaff = rb.idAssn3
go
--	----------------------------------------------------------------------------
--	Removes expired active events
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

	--	update	rb	set	rb.idEvent=	null, tiSvc= null	--	7.02: no need to reset tbRoomBed here
	--		from	tbRoomBed rb
	--		left outer join	tbEvent_A a	on	a.idEvent = rb.idEvent
	--		where	a.idEvent is null	or	a.bActive = 0

		if	@tiPurge > 0
		begin
			if	@tiPurge = 255						--	remove all inactive events
			begin
				update	t	set	t.idEvtVo=	null
					from	tbEvent_T t
					left outer join	tbEvent_A a	on	a.idEvent = t.idEvtVo
					where	a.idEvent is null
				update	t	set	t.idEvtSt=	null
					from	tbEvent_T t
					left outer join	tbEvent_A a	on	a.idEvent = t.idEvtSt
					where	a.idEvent is null

				update	c	set	c.idEvtVo=	null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idEvtVo
					where	a.idEvent is null
				update	c	set	c.idEvtSt= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idEvtSt
					where	a.idEvent is null
				update	c	set	c.idEvtRn=	null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idEvtRn
					where	a.idEvent is null
				update	c	set	c.idEvtCn=	null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idEvtCn
					where	a.idEvent is null
				update	c	set	c.idEvtAi=	null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idEvtAi
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left outer join	tbEvent_A a	on	a.idEvent = e.idEvent
					where	a.idEvent is null
				select	@i=	@@rowcount

		--		delete	e	from	tbEvent e		--	7.02: DELETE conflicted with ref constraint "fkEventC_Event_Aide"
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
--	Removes no longer needed events, should be called on a schedule every hour
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ reporting DB sizes in tb_Module[1]
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prEvent_Maint
	with encryption
as
begin
	declare		@iSizeDat	int
	declare		@iSizeLog	int
	declare		@tiPurge	tinyint

	set	nocount	on

	select	@iSizeDat= size/128
		from	sys.database_files	with (nolock)
		where	file_id = 1		--	type = 0
	select	@iSizeLog= size/128
		from	sys.database_files	with (nolock)
		where	file_id = 2		--	type = 1

	update	tb_Module	set	sParams=	'@ ' + @@servicename + ', dat:' + cast(@iSizeDat as varchar) + ', log:' + cast(@iSizeLog as varchar)
		where	idModule=	1

	select	@tiPurge= cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	if	@tiPurge > 0
		exec	prEvent_A_Exp	@tiPurge
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
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

,	@idLogType	tinyint = null		-- type look-up FK (marks significant events only)
,	@idCall		smallint = null		-- call look-up FK (only 41,84,8A and 95 commands)
,	@tiBtn		tinyint = null		-- src|dst button code (0-31)
,	@tiBed		tinyint = null		-- bed index
,	@idUnit		smallint = null		-- active unit ID
,	@iAID		int = null			-- device A-ID (32 bits)
,	@tiStype	tinyint = null		-- device type (1-255)
,	@idCall0	smallint = null		-- call prior to escalation
)
	with encryption
as
begin
	declare		@dtEvent	datetime
		,		@tiHH		tinyint
		,		@idRoom		smallint
		,		@cDevice	char( 1 )
		,		@idParent	int
		,		@dtParent	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@iExpNrm	int

	set	nocount	on

	select	@dtEvent=	getdate( )
		,	@tiHH=		datepart( hh, getdate( ) )
		,	@cDevice=	case when @idCmd = 0x83 then 'G' else '?' end		--	null

	select	@iExpNrm= iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@tiBed= null

	begin	tran

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)	--	audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cDevice=	@cSrcSys		select	@cSrcSys=	@cDstSys		select	@cDstSys=	@cDevice
			select	@tiShelf=	@tiSrcGID		select	@tiSrcGID=	@tiDstGID		select	@tiDstGID=	@tiShelf
			select	@tiShelf=	@tiSrcJID		select	@tiSrcJID=	@tiDstJID		select	@tiDstJID=	@tiShelf
			select	@tiShelf=	@tiSrcRID		select	@tiSrcRID=	@tiDstRID		select	@tiDstRID=	@tiShelf
		end

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

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02
		begin

			select	@idParent= idEvent, @dtParent= dtEvent		--	7.04.4968
				from	tbEvent_A	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
				and		( tiBtn = @tiBtn	or	@tiBtn is null )
				and		( idCall = @idCall	or	@idCall is null )

			select	@idRoom=	idDevice
				from	vwRoom		with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	bActive > 0		--	and	tiRID = 0

			if	@idParent is null	--	no parent found
			begin
				update	tbEvent		set	idParent= @idEvent,		idRoom= @idRoom,	tParent= '0:0:0',	@dtParent= dtEvent
					where	idEvent = @idEvent

				if	@idCall > 0		--	6.03
				begin
					--	!!	exclude ROUND and REMINDER priorities from starting transactions	!!
					select	@tiSpec= p.tiSpec,	@tiShelf= case when p.tiFlags & 0x08 > 0 then 0 else p.tiShelf end			--	7.04.4965
						from	tbCfgPri	p	with (nolock)
						inner join	tbCall	c	with (nolock)	on	c.siIdx = p.siIdx	and	c.idCall = @idCall

					if	( @tiShelf > 0	and		( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 ) )	--	only 'medical' calls can be 'parents'
		--	-		--	!!	'presence' works for prEvent84_Ins;  but it should be excluded from tbEvent_T and/or tbEvent_P	!!
						or	@tiSpec between 7 and 9															--	or 'presence'
					--	!!	cannot exclude 'presence' from tbEvent_P, breaks the chaining logic	!!
						begin
							insert	tbEvent_P	( idEvent, dtEvent, cSys, tiGID, tiJID, dtExpires )			--	7.04.4965
									values		( @idEvent, @dtParent, @cSrcSys, @tiSrcGID, @tiSrcJID, dateadd(ss, @iExpNrm, @dtParent) )
							insert	tbEvent_T	( idEvent, dEvent, tEvent, tiHH, idRoom, idCall )
									values		( @idEvent, @dtParent, @dtParent, datepart( hh, @dtParent ), @idRoom, @idCall )		--	6.04:	@idRoom
						end
				end
			end
			else	--	parent found
			begin
				update	tbEvent		set	idParent= @idParent,	idRoom= @idRoom,	tParent= dtEvent - @dtParent
					where	idEvent = @idEvent

				select	@dtParent=	dateadd(ss, @iExpNrm, getdate( ))	--	6.05
				update	tbEvent_P	set	dtExpires= @dtParent
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
						and	dtExpires < @dtParent						--	6.05
			end
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
--	Marks a gateway as found or lost (and removes its active calls)
--	7.04.4960	* activate a GW if necessary
--	6.07	+ isnull(sDevice,'?')
--	6.05
alter proc		dbo.prEvent_SetGwState
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@idLogType	tinyint				-- 190=Lost, 189=Found
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
	declare		@idEvent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		if	@idLogType = 189
			update	tbDevice	set	bActive= 1
				where	bActive = 0
					and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	---	and	tiRID = 0

		select	@s=	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + ' [' + isnull(sDevice,'?') + ']'
			from	tbDevice	with (nolock)
			where	bActive > 0
				and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	---	and	tiRID = 0

	---	if	@idLogType = 189
	---		select	@s= @s + ' found'
	---	else
		if	@idLogType = 190
		begin
			delete	from	tbEvent_A
				where	cSys = @cSys	and	tiGID = @tiGID
---				where	cSrcSys = @cSys	and	tiSrcGID = @tiGID
	---		select	@s= @s + ' lost, ' + cast(@@rowcount as varchar) + ' active call(s) cleared'
			select	@s= @s + ', ' + cast(@@rowcount as varchar) + ' active call(s) cleared'
		end

		exec	dbo.prEvent_Ins		0x83, 0, 0, null,		---	@idCmd, @tiLen, @iHash, @vbCmd,
					@cSys, @tiGID, 0, 0, null,				--- @tiSrcJID, @tiSrcRID, @sDevice,
					null, null, null, null, null, null,		---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, @idLogType		---	, @idCall, @tiSrcBtn, @tiBed, @idUnit, @iAID, @tiStype

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
			,	@idParent	int
			,	@idSrcDvc	smallint
			,	@idDstDvc	smallint
			,	@idRoom		smallint
			,	@idCall		smallint
			,	@idCall0	smallint
			,	@siIdxOld	smallint
			,	@siIdxNew	smallint
			,	@idDoctor	int
			,	@idPatient	int
			,	@cGender	char( 1 )
			,	@idOrigin	int
			,	@dtOrigin	datetime
			,	@tiShelf	tinyint
			,	@tiSpec		tinyint
			,	@tiSvc		tinyint
			,	@tiRmBed	tinyint
			,	@cBed		char( 1 )
			,	@tiPurge	tinyint
			,	@bAudio		bit
			,	@iExpNrm	int
			,	@iExpExt	int
	--		,	@s			varchar( 255 )

	set	nocount	on

	select	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

	select	@tiPurge=	cast(iValue as tinyint)
		from	tb_OptSys	with (nolock)	where	idOption = 7
	select	@iExpNrm=	iValue
		from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt=	iValue
		from	tb_OptSys	with (nolock)	where	idOption = 10

	if	@siIdxNew > 0			-- call placed
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiSpec= tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

		if	@siIdxOld > 0  and  @siIdxOld <> @siIdxNew	-- call escalated
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

	if	@tiBed > 9	--	= 0xFF	or	@tiBed = 0
		select	@cBed= null,	@tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	if	len(@sPatient) > 15
		select	@cGender= substring( @sPatient, 15, 1 )
	else
		select	@cGender= null
		
--	exec	dbo.prPatient_GetIns	@sPatient, null, @sInfo, null, @sDoctor, @idPatient out
	exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out

	begin	tran

		if	@tiBed is not null		-- >= 0
			update	tbCfgBed	set	bInUse= 1, dtUpdated= getdate( )	where	tiBed = @tiBed	and	bInUse = 0

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiSrcBtn, @tiBed, @idUnit, @iAID, @tiStype, @idCall0

		select	@idRoom= idRoom		--, @idCall= idCall		--	get idRoom, assigned by prEvent_Ins
			from	tbEvent		with (nolock)
			where	idEvent = @idEvent

	--	if	@idSrcDvc is not null	and	len( @sDial ) > 0		--	7.04.4972
	--		update	tbDevice	set	sDial= @sDial, dtUpdated= getdate( )
	--			where	idDevice = @idSrcDvc	and	( sDial <> @sDial	or sDial is null )	--!

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
--				and	idCall = @idCall		--	7.04.4972
				and	bActive > 0				--	6.04

	---	if	@siIdxOld = 0	or	@idOrigin is null	--	new call placed | no active origin found
		if	@idOrigin is null	--	no active origin found
			--	'real' new call should not have origin anyway, 'repeated' one would be linked to starting - even better
		begin
			update	tbEvent		set	idOrigin= @idEvent, idLogType= 191	-- call placed
								,	tOrigin= dateadd(ss, @siElapsed, '0:0:0')										--	6.05
								,	@dtOrigin= dateadd(ss, - @siElapsed, dtEvent), @idSrcDvc= idSrcDvc, @idParent= idParent		--	6.04
				where	idEvent = @idEvent

			insert	tbEvent_A	(  idEvent,   dtEvent,  cSys,     tiGID,     tiJID,     tiRID,     tiBtn,     siPri,     siIdx,     tiBed, dtExpires,
								tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiSrcBtn, @siPriNew, @siIdxNew, @tiBed,		--	6.04
								dateadd(ss, @iExpNrm, getdate( )),
								@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )	--@dtOrigin

			update	tbEvent_T	set	idCall= @idCall, idUnit= @idUnit, cBed= @cBed
				where	idEvent = @idParent		and	@idCall is null		-- there could be more than one, but we need to use only 1st one

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

			if	( @tiShelf > 0	and		( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 ) )	--	only save 'medical' calls
				or	@tiSpec between 7 and 9															--	or 'presence'
	--			begin
	/*				if	@tiSrcRID > 0	--	is source device a station?								--	7.04.4969
						select	@idSrcDvc= idParent		--	room-controller must be the station's parent!
							from	tbDevice	with (nolock)
							where	idDevice = @idSrcDvc
	*/				insert	tbEvent_C	( idEvent, dEvent, tEvent, tiHH, idCall, idRoom, idUnit, cBed )
							values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idRoom, @idUnit, @cBed )
	--			end
			if	@tiSpec = 7
				update	c	set	idEvtRn=	@idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
			else if	@tiSpec = 8
				update	c	set	idEvtCn=	@idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
			else if	@tiSpec = 9
				update	c	set	idEvtAi=	@idEvent
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
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	bActive > 0				--	6.04

			update	tbEvent_P	set	dtExpires= @dtOrigin												--	6.05
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	dtExpires < @dtOrigin

			select	@dtOrigin= tOrigin, @idParent= idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	tbEvent_C	set	idEvtSt= @idEvent, tStaff= @dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null		-- there should be only one, but just in case - use only 1st one
			update	tbEvent		set	idLogType= 193		-- call cleared
				where	idEvent = @idEvent

			select	@tiSpec= tiSpec	from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld

			if	@tiSpec = 7
			begin
				update	tbEvent_C	set	tRn= @dtOrigin
					where	idEvtRn = @idOrigin
				update	tbEvent_T	set	tRn= isnull(tRn, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end
			else if	@tiSpec = 8
			begin
				update	tbEvent_C	set	tCn= @dtOrigin
					where	idEvtCn = @idOrigin
				update	tbEvent_T	set	tCn= isnull(tCn, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end
			else if	@tiSpec = 9
			begin
				update	tbEvent_C	set	tAi= @dtOrigin
					where	idEvtAi = @idOrigin
				update	tbEvent_T	set	tAi= isnull(tAi, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end

		--	can't do following for @tiSpec=7|8|9 (and maybe others!?..)
			if	@tiSpec is null		or @tiSpec < 7	or	@tiSpec > 9
				update	tbEvent_T	set	idEvtSt= @idEvent, tStaff= @dtOrigin
					where	idEvent = @idParent		and	idEvtSt is null			-- there should be only one, but just in case - use only 1st one
		end
		else if	@siIdxNew > 0  and  @siIdxOld > 0  and  @siIdxOld <> @siIdxNew
			update	tbEvent		set	idLogType= 192		-- call escalated
				where	idEvent = @idEvent

		exec	dbo.prRoom_Upd		@idRoom, @idUnit, @sRn, @sCn, @sAi

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

		if	@tiBed is not null								--	if argument is a bed-level call
			update	tbRoomBed	set	idPatient= @idPatient, dtUpdated= getdate( )		--, idDoctor= @idDoctor	--	7.02
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
	,	e.idSrcDvc, d.sDevice, e.idRoom, r.sDevice [sRoom], r.sDial, e.tiBed, e.idCall, c.sCall, e.idUnit
	,	e84.siPriOld, e84.siPriNew, e84.siIdxOld, e84.siIdxNew, e84.iFilter
	,	cast( case when e84.siPriNew & 0x0400 > 0 then 0 else 1 end as bit ) [bAnswered]
	,	e84.siElapsed, e84.tiPrivacy, e84.tiTmrSt, e84.tiTmrRn, e84.tiTmrCn, e84.tiTmrAi
	,	e84.idPatient, p.sPatient, p.cGender
	,	e84.idDoctor, v.sDoctor, e.sInfo
	,	e84.tiCvrg0, e84.tiCvrg1, e84.tiCvrg2, e84.tiCvrg3, e84.tiCvrg4, e84.tiCvrg5, e84.tiCvrg6, e84.tiCvrg7
	,	e84.siDuty0, e84.siDuty1, e84.siDuty2, e84.siDuty3, e84.siZone0, e84.siZone1, e84.siZone2, e84.siZone3
	from	tbEvent84	e84
	inner join	tbEvent	e	on	e.idEvent = e84.idEvent
	inner join	tbCall	c	on	c.idCall = e.idCall
	inner join	tbDevice	d	on	d.idDevice = e.idSrcDvc
	inner join	tbDevice	r	on	r.idDevice = e.idRoom
	left outer join	tbPatient	p	on	p.idPatient = e84.idPatient
	left outer join	tbDoctor	v	on	v.idDoctor = e84.idDoctor
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
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
		,		@siIdx		smallint			-- call-index
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

	begin	tran

		if	@tiBed >= 0
			update	tbCfgBed	set	bInUse= 1, dtUpdated= getdate( )	where	tiBed = @tiBed	and	bInUse = 0

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

		select	@idOrigin= idEvent, @dtOrigin= dtEvent
			from	tbEvent_A	with (nolock)
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
				update	tbEvent_C	set	idEvtVo= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idOrigin		and	idEvtVo is null		-- there should be only one, but just in case - use only 1st one
				update	tbEvent_T	set	idEvtVo= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idParent		and	idEvtVo is null		-- there should be only one, but just in case - use only 1st one
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

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx

			if	@tiShelf > 0	and	(@tiSpec is null	or	@tiSpec < 6	or	@tiSpec = 18)
			begin									--	only save "medical" calls as transactions
	--			if	@tiDstRID > 0					--	is destination device a station?
	--				select	@idDstDvc= idParent		--	then room (room-controller) is station's parent!
	--					from	tbDevice	with (nolock)
	--					where	idDevice = @idSrcDvc
				insert	tbEvent_C	( idEvent, dEvent, tEvent, tiHH, idCall, idRoom, cBed )
						values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idRoom, @cBed )
	--			insert	tbEvent_C	( idEvent, dEvent, tEvent, tiHH, idCall, idRoom, idUnit, cBed )
	--					values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idRoom, @idUnit, @cBed )
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.04.4896	* tbDefCall -> tbCall
--	5.01	encryption added
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	3.01
--	2.03	.idSrcDvc -> .idDstDvc (prEvent8A_Ins, vwEvent8A)
--	2.01	- .idDstDvc
--	1.00
alter view		dbo.vwEvent8A
	with encryption
as
select	e.idEvent, h.dtEvent, h.idCmd, h.cSrcSys, h.tiSrcGID, h.tiSrcJID, h.tiSrcRID,
		cDstSys, tiDstGID, tiDstJID, tiDstRID,
		h.tiBtn, tiSrcJAB, tiSrcLAB, tiDstJAB, tiDstLAB,
		h.tiBed, e.siPri, h.idCall, c.sCall, e.siIdx, c.siIdx [siCallIdx]
	from	tbEvent8A	e
	inner join	tbEvent	h	on	h.idEvent = e.idEvent
	inner join	tbCall	c	on	c.idCall = h.idCall
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
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
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@siIdx=	@siPri & 0x03FF

	begin	tran

		if	@tiBed >= 0
			update	tbCfgBed	set	bInUse= 1, dtUpdated= getdate( )	where	tiBed = @tiBed	and	bInUse = 0

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
	from	tbEvent95	e
	inner join	tbEvent	h	on	h.idEvent = e.idEvent
	inner join	tbCall	c	on	c.idCall = h.idCall
	left outer join	tbDevice	d	on	d.idDevice = h.idSrcDvc
	left outer join	tbUnit	u	with (nolock)	on	u.idUnit = h.idUnit
go
--	----------------------------------------------------------------------------
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
,	@dtAttempt	datetime			-- when page was sent to encoder
,	@biPager	bigint				-- pager number
,	@tiSeqNum	tinyint				-- [rotating] sequence number (0-255)
,	@cStatus	char( 1 )			-- Q=Queued, R=Rejected, U=unknown
,	@sInfo		varchar( 32 )		-- page message (28 chars max?)
)
	with encryption
as
begin
	declare		@idEvent	int
	declare		@idCall		smallint
	declare		@sCall		varchar( 16 )
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint

	set	nocount	on

	select	@siIdx=	@siIdx & 0x03FF

	begin	tran

		if	@siIdx > 0
		begin
			select	@sCall= sCall	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx
			exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
		end
		else
---			exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call
			select	@idCall= 0				--	INTERCOM call

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
					null, null, null, null, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, 205, @idCall, @tiBtn, @tiBed

		insert	tbEvent41	( idEvent,  siIdx,  dtAttempt,  biPager,  tiSeqNum,  cStatus )
				values		( @idEvent, @siIdx, @dtAttempt, @biPager, @tiSeqNum, @cStatus )
	commit
end
go
--	----------------------------------------------------------------------------
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

,	@sCodeVer	varchar( 16 )		-- device code version
)
	with encryption
as
begin
--	declare		@idEvent	int
--	declare		@idSrcDvc	smallint
--	declare		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		update	dbo.tbDevice	set	sCodeVer= @sCodeVer, dtUpdated= getdate( )
			where	cSys = @cSrcSys	and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	bActive > 0
--		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
--					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
--					null, null, null, null, null, @sInfo,
--					@idEvent out, @idSrcDvc out, @idDstDvc out, 205, @idCall, @tiBtn, @tiBed

--		insert	tbEvent41	( idEvent,  siIdx,  dtAttempt,  biPager,  tiSeqNum,  cStatus )
--				values		( @idEvent, @siIdx, @dtAttempt, @biPager, @tiSeqNum, @cStatus )
	commit
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
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
create proc		dbo.prCfgLoc_SetLvl
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

	begin	tran

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

		--	disable non-matching units
		update	u	set	u.bActive= 0, dtUpdated= getdate( )
			from	tbUnit u
				left outer join 	tbCfgLoc l	on l.idLoc = u.idUnit
			where	u.bActive = 1	and	l.idLoc is null

--		update	Units	set	DownloadCounter= -1

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
				update	tbUnit	set	bActive= 1, sUnit= @sUnit, dtUpdated= getdate( )	--	, tiShifts= 0, iStamp= 0
					where	idUnit = @idUnit
			else
			begin
				insert	tbUnit	(  idUnit,  sUnit, tiShifts )
						values	( @idUnit, @sUnit, 1 )
				insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )			--	default to single 24hr-shift
						values	( @idUnit, 1, 'Shift 1', '07:00', '07:00' )
				select	@idShift=	scope_identity( )

				update	tbUnit	set	idShift= @idShift
					where	idUnit = @idUnit

	--	-		insert	tbRouting	(  idShift,  siIdx,  tResp0,  tResp1,  tResp2,  tResp3 )
	--	-				values		(  )
			end

/*			if	exists	(select 1 from dbo.Units where ID = @idUnit)
				update	Units	set	Name= @sUnit,	DownloadCounter= 0
					where ID = @idUnit
			else
				insert	Units	(ID, Name, ShiftsPerDay, DownloadCounter,
								StartTimeShift1, EndTimeShift1, StartTimeShift2, EndTimeShift2, StartTimeShift3, EndTimeShift3,
								NotificationModeShift1, NotificationModeShift2, NotificationModeShift3,
								BackupStaffIDShift1, BackupStaffIDShift2, BackupStaffIDShift3, 
								CustomRoutingShift1, CustomRoutingShift2, CustomRoutingShift3) 
						values	(@idUnit, @sUnit, 3, 0,
								'07:00', '15:00', '15:00', '23:00', '23:00', '07:00',
								0, 0, 0, '', '','', 1, 1, 1)
*/
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

--		delete	from	Units	where	DownloadCounter < 0

	commit
end
go
/*
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prCfgLoc_SetLvl
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

	begin	tran

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''S''
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''B''
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''F''
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''U''
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''C''
			from	tbCfgLoc l
			inner join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		if	@iTrace & 0x01 > 0
		begin
			select	@s= ''Loc_SL( ) '' + cast(@iCount as varchar) + '' rows''
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		--	disable non-matching units
		update	u	set	u.bActive= 0, dtUpdated= getdate( )
			from	tbUnit u
				left outer join 	tbCfgLoc l	on l.idLoc = u.idUnit
			where	u.bActive = 1	and	l.idLoc is null

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
				update	tbUnit	set	bActive= 1, sUnit= @sUnit, dtUpdated= getdate( )	--	, tiShifts= 0, iStamp= 0
					where	idUnit = @idUnit
			else
			begin
				insert	tbUnit	(  idUnit,  sUnit, tiShifts, iStamp )
						values	( @idUnit, @sUnit, 1, 0 )
				insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd, iStamp )			--	default to single 24hr-shift
						values	( @idUnit, 1, ''Shift 1'', ''07:00'', ''07:00'', 0 )
				select	@idShift=	scope_identity( )

				update	tbUnit	set	idShift= @idShift
					where	idUnit = @idUnit

			end

			if	exists	(select 1 from dbo.Units where ID = @idUnit)
				update	Units	set	Name= @sUnit,	DownloadCounter= 0
					where ID = @idUnit
			else
				insert	Units	(ID, Name, ShiftsPerDay, DownloadCounter,
								StartTimeShift1, EndTimeShift1, StartTimeShift2, EndTimeShift2, StartTimeShift3, EndTimeShift3,
								NotificationModeShift1, NotificationModeShift2, NotificationModeShift3,
								BackupStaffIDShift1, BackupStaffIDShift2, BackupStaffIDShift3, 
								CustomRoutingShift1, CustomRoutingShift2, CustomRoutingShift3) 
						values	(@idUnit, @sUnit, 3, 0,
								''07:00'', ''15:00'', ''15:00'', ''23:00'', ''23:00'', ''07:00'',
								0, 0, 0, '''', '''','''', 1, 1, 1)

			--	populate tbUnitMap
			if	not	exists	(select 1 from tbUnitMap where idUnit = @idUnit)
			begin
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, ''Map 1'' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, ''Map 2'' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, ''Map 3'' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, ''Map 4'' )
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
end' )
*/
go
grant	execute				on dbo.prCfgLoc_SetLvl				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Shift definitions
--	7.04.4939	[- .tiRouting]
--	7.04.4919	.idStaff: FK -> tb_User
--	7.04.4917	tdShift_Routing 0x0F -> 0x00
begin
	begin tran
		alter table	dbo.tbShift		drop constraint	tdShift_Routing
		alter table	dbo.tbShift		add constraint	tdShift_Routing	default( 0 ) for tiRouting
	--	alter table	dbo.tbShift		drop column		tiRouting

		alter table	dbo.tbShift		drop constraint	fkShift_Staff
		alter table	dbo.tbShift		add
			constraint	fkShift_Staff	foreign key	(idStaff)	references tb_User
	commit
end
go
--	----------------------------------------------------------------------------
--	Shift definitions
--	7.04.4966	- .iStamp
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbShift') and name = 'iStamp')
begin
	begin tran
		alter table	dbo.tbShift		drop column		iStamp
	commit
end
go
--	----------------------------------------------------------------------------
--	Exports all shifts
--	7.04.4965
create proc		dbo.prShift_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idShift, idUnit, tiIdx, sShift, tBeg, tEnd, tiRouting, tiNotify, idStaff, bActive, dtCreated, dtUpdated
		from	tbShift		with (nolock)
		where	idShift > 0
		order	by	idShift
end
go
grant	execute				on dbo.prShift_Exp					to [rWriter]
grant	execute				on dbo.prShift_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a shift
--	7.04.4965
create proc		dbo.prShift_Imp
(
	@idShift	smallint
,	@idUnit		smallint
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiRouting	tinyint				-- 0=Standard, 1=Custom
,	@tiNotify	tinyint				-- notification mode: 0=Auto, 1=SemiAuto, 2=Manual [, 3=FollowConsole]
,	@idStaff	int
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	exists	(select 1 from tbShift with (nolock) where idShift = @idShift)
		begin
			update	tbShift	set	idUnit= @idUnit, tiIdx= @tiIdx, sShift= @sShift, tBeg= @tBeg, tEnd= @tEnd, tiRouting= @tiRouting
						,	tiNotify= @tiNotify, idStaff= @idStaff, bActive= @bActive, dtUpdated= @dtUpdated
				where	idShift = @idShift
		end
		else
		begin
			set identity_insert	dbo.tbShift	on

			insert	tbShift	(  idShift,  idUnit,  tiIdx,  sShift,  tBeg,  tEnd,  tiRouting,  tiNotify,  idStaff,  bActive,  dtCreated,  dtUpdated )
					values	( @idShift, @idUnit, @tiIdx, @sShift, @tBeg, @tEnd, @tiRouting, @tiNotify, @idStaff, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbShift	off
		end

	commit
end
go
grant	execute				on dbo.prShift_Imp					to [rWriter]
--grant	execute				on dbo.prShift_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all shifts for a given unit (ordered)
--	7.04.4938
create proc		dbo.prShift_GetByUnit
(
	@idUnit		smallint
)
	with encryption
as
begin
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, cast(0 as bit) bRouting, tiNotify, idStaff, bActive, dtUpdated
		from	tbShift		with (nolock)
		where	idUnit = @idUnit	and	bActive > 0
		order	by	tiIdx
end
go
grant	execute				on dbo.prShift_GetByUnit			to [rWriter]
grant	execute				on dbo.prShift_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Call-type routing (per shift)
--	7.04.4917
create table	dbo.tbRouting
(
	idShift		smallint		not null
		constraint	fkRouting_Shift		foreign key references tbShift
,	siIdx		smallint		not null	-- call-index
,	constraint	xpRouting	primary key clustered	( idShift, siIdx )

,	tiRouting	tinyint			not null	-- 1=Standard (1-2-3-B), 0..7=Custom (8 patterns)
		constraint	tdRouting_Routing	default( 1 )
,	bOverride	bit				not null	-- page override?
		constraint	tdRouting_Override	default( 0 )
,	tResp0		time( 0 )		null		-- backup responder interval
,	tResp1		time( 0 )		null		-- 1st responder interval
,	tResp2		time( 0 )		null		-- 2nd responder interval
,	tResp3		time( 0 )		null		-- 3rd responder interval

--,	bActive		bit				not null	-- currently enabled
--		constraint	tdRouting_Active	default( 1 )
--,	dtCreated	smalldatetime	not null	-- internal: record creation
--		constraint	tdRouting_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null	-- internal: last modified
		constraint	tdRouting_Updated	default( getdate( ) )
)
go
grant	select, insert, update			on dbo.tbRouting		to [rWriter]
grant	select, update					on dbo.tbRouting		to [rReader]
go
begin
	set	nocount	on

	declare	@siIdx		smallint
		,	@tResp		time( 0 )

	select	@siIdx=	0,	@tResp=	'00:02:00'
	while	@siIdx < 1024
	begin
		if	not	exists( select 1 from tbRouting with (nolock) where idShift = 0 and siIdx = @siIdx )
			insert	tbRouting	( idShift,	siIdx, tResp0, tResp1, tResp2, tResp3 )
					values		( 0,		@siIdx, @tResp, @tResp, @tResp, @tResp )

		select	@siIdx=	@siIdx + 1
	end

	set	nocount	off
end
go
--	----------------------------------------------------------------------------
--	Returns call-routing data for given shift [and priority]
--	7.04.4938
create proc		dbo.prRouting_Get
(
	@idShift	smallint
,	@bEnabled	bit			=	0		-- 0=any, 1=enabled priorities only
,	@siIdx		smallint	=	null
)
	with encryption
as
begin
	select	@idShift	[idShift],	z.siIdx, p.sCall, p.tiShelf, p.tiSpec, p.iColorF, p.iColorB
		,	cast(case when p.tiFlags & 0x02 > 0 then 1 else 0 end as bit)	[bEnabled]
		,	coalesce( r.tiRouting, z.tiRouting )	[tiRouting]
		,	coalesce( r.bOverride, z.bOverride )	[bOverride]
		,	coalesce( r.tResp0, z.tResp0 )			[tResp0]
		,	coalesce( r.tResp1, z.tResp1 )			[tResp1]
		,	coalesce( r.tResp2, z.tResp2 )			[tResp2]
		,	coalesce( r.tResp3, z.tResp3 )			[tResp3]
		,	coalesce( r.dtUpdated, z.dtUpdated )	[dtUpdated]
		,	cast( case when r.tiRouting is null then 0 else 1 end as bit )	[bRoute]
		,	cast( case when r.bOverride is null then 0 else 1 end as bit )	[bOverr]
		,	cast( case when r.tResp0 is null then 0 else 1 end as bit )		[bResp0]
		,	cast( case when r.tResp1 is null then 0 else 1 end as bit )		[bResp1]
		,	cast( case when r.tResp2 is null then 0 else 1 end as bit )		[bResp2]
		,	cast( case when r.tResp3 is null then 0 else 1 end as bit )		[bResp3]
		from	dbo.tbRouting	z	with (nolock)
		inner join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx = z.siIdx
				and	( @idShift = 0	and	@bEnabled = 0	or	p.tiFlags & 0x02 > 0 )
				and	( @siIdx is null	or	p.siIdx = @siidx )
		left outer join	dbo.tbRouting	r	with (nolock)	on	r.idShift = @idShift	and	z.siIdx = r.siIdx
		where	z.idShift = 0
		order	by	z.siIdx desc
end
go
grant	execute				on dbo.prRouting_Get				to [rWriter]
grant	execute				on dbo.prRouting_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	Resets custom call-routing data for given shift
--	7.04.4944
create proc		dbo.prRouting_Clr
(
	@idShift	smallint
)
	with encryption
as
begin
	begin	tran

		delete	from	dbo.tbRouting
			where	idShift = @idShift

	commit
end
go
grant	execute				on dbo.prRouting_Clr				to [rWriter]
grant	execute				on dbo.prRouting_Clr				to [rReader]
go
--	----------------------------------------------------------------------------
--	Sets call-routing data for given shift and priority
--	7.04.4944
--	7.04.4938
create proc		dbo.prRouting_Set
(
	@idShift	smallint
,	@siIdx		smallint
,	@tiRouting	tinyint
,	@bOverride	bit
,	@tResp0		time( 0 )
,	@tResp1		time( 0 )
,	@tResp2		time( 0 )
,	@tResp3		time( 0 )
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

	set	nocount	on

	if	@idShift > 0
	begin
		select	@bRecord= 0,	@_tiRouting= tiRouting,	@_bOverride= bOverride
			,	@_tResp0= tResp0, @_tResp1= tResp1, @_tResp2= tResp2, @_tResp3= tResp3
			from	tbRouting	with (nolock)
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
	end
--	print	@idShift
--	print	@bRecord

	begin	tran

		if	@idShift > 0
		begin
			if	@bRecord > 0
			begin
--				select count(*) from tbRouting with (nolock) where idShift = @idShift and siIdx = @siIdx

				if	not	exists	(select 1 from tbRouting with (nolock) where idShift = @idShift and siIdx = @siIdx)
				begin
--					print	'ins'
					insert	tbRouting	(  idShift,  siIdx,  tiRouting,  bOverride,  tResp0,  tResp1,  tResp2,  tResp3 )
							values		( @idShift, @siIdx, @tiRouting, @bOverride, @tResp0, @tResp1, @tResp2, @tResp3 )

					select	@bRecord=	0
				end
		--		else
		--			select	@bRecord=	1		--	no need, already 1
	--				update	tbRouting	set
	--						tiRouting= @tiRouting,	bOverride= @bOverride,	dtUpdated=	getdate( )
	--					,	tResp0= @tResp0,	tResp1= @tResp1,	tResp2= @tResp2,	tResp3= @tResp3
	--					where	idShift = @idShift	and	siIdx = @siIdx
			end
			else
			begin
--				print	'del'
				delete	from	tbRouting
					where	idShift = @idShift	and	siIdx = @siIdx
			end
		--		select	@bRecord=	0		--	no need, already 0
		end
	--	else						--	defaults
		if	@idShift = 0	or	@bRecord > 0
		begin
--			print	'upd'
			update	tbRouting	set
					tiRouting= @tiRouting,	bOverride= @bOverride,	dtUpdated=	getdate( )
				,	tResp0= @tResp0,	tResp1= @tResp1,	tResp2= @tResp2,	tResp3= @tResp3
				where	idShift = @idShift	and	siIdx = @siIdx
		end

	commit
end
go
grant	execute				on dbo.prRouting_Set				to [rWriter]
grant	execute				on dbo.prRouting_Set				to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--	Staff assignment history (coverage)
--	7.04.4897	* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffAssn')
begin
	begin tran
		exec sp_rename 'tbStaffAssn.idStaffAssn',	'idStfAssn',	'column'
		exec sp_rename 'tbStaffCover.idStaffAssn',	'idStfAssn',	'column'
		exec sp_rename 'tbStaffAssn.idStaffCover',	'idStfCvrg',	'column'
		exec sp_rename 'tbStaffCover.idStaffCover',	'idStfCvrg',	'column'

		exec sp_rename 'tbStaffAssn',				'tbStfAssn',	'object'
		exec sp_rename 'tbStaffCover',				'tbStfCvrg',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Finalizes specified staff assignment definition by marking it inactive
--	7.04.4955	* fix logic
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn, prStaffAssn_Fin -> prStfAssn_Fin
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
--	7.01	+ resetting assinged staff in tbRoomBed
--	7.00	tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.02
create proc		dbo.prStfAssn_Fin
(
	@idStfAssn		int
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		--	deactivate and close everything associated with that StaffAssn
		update	tbStfCvrg	set
				dtEnd= getdate( ), dEnd= getdate( ), tEnd= getdate( ), tiEnd= datepart( hh, getdate( ) )
			where	idStfAssn = @idStfAssn

		update	tbStfAssn	set
				bActive= 0, idStfCvrg= null, dtUpdated= getdate( )
			where	idStfAssn = @idStfAssn

		--	reset assigned staff
		update	rb	set	idAssn1=	null
			from	tbRoomBed	rb
			inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
			where	idStfAssn = @idStfAssn

		update	rb	set	idAssn2=	null
			from	tbRoomBed	rb
			inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
			where	idStfAssn = @idStfAssn

		update	rb	set	idAssn3=	null
			from	tbRoomBed	rb
			inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
			where	idStfAssn = @idStfAssn

	commit
end
go
grant	execute				on dbo.prStfAssn_Fin				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
--	7.04.4955	* fix logic
--	7.04.4920	- tbStaff -> tb_User
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn, prStaffAssn_InsUpdDel -> prStfAssn_InsUpdDel
--	7.03.4884	+ trace output
--	7.00	* tbDevice.bActive > 0
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.02
--	6.01
create proc		dbo.prStfAssn_InsUpdDel
(
	@idStfAssn	int							-- internal
,	@bActive	bit							-- "deletion" marks inactive
,	@idUnit		smallint					-- unit look-up FK
,	@idRoom		smallint					-- room look-up FK
,	@sRoom		varchar( 16 )				-- room name
,	@tiBed		tinyint						-- bed index FK
,	@idShift	smallint					-- internal
,	@tiShIdx	tinyint						-- shift index [1..3]
,	@tiIdx		tinyint						-- staff index [1..3]
,	@idStaff	int							-- staff look-up FK
,	@lStaffID	bigint						-- external Staff ID
--,	@sStaffID	varchar( 16 )				-- external Staff ID
,	@TempID		int							-- 7980 FK
,	@iStamp		int							-- row-version counter
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
	declare		@iTrace		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	if	@iTrace & 0x80 > 0
	begin
		select	@s=	cast(@iStamp as varchar) + ' SAD_IUD( idU=' + isnull(cast(@idUnit as varchar),'?') +
				', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
				', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
				', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
				', idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
				', idSt=' + isnull(cast(@idStaff as varchar),'?') + ' )'
		exec	dbo.pr_Log_Ins	46, null, null, @s
	end

	if	@idRoom is null
		select	@idRoom= idDevice		from	vwRoom		with (nolock)
				where	bActive > 0	and	sDevice = @sRoom	--	and	sDial = @sDial
--	print	@idRoom

	if	@idShift is null
		select	@idShift= idShift		from	tbShift		with (nolock)
				where	bActive > 0	and	idUnit = @idUnit	and	tiIdx = @tiShIdx
--	print	@idShift

	if	@idStaff is null	--	and	len(@sStaffID) > 0
		select	@idStaff= idUser		from	tb_User		with (nolock)
				where	bActive > 0	and	sStaffID = cast(@lStaffID as varchar)
--	print	@idStaff

	if	@idStfAssn is null		and	(@idRoom is null	or	@idShift is null)	--	log an error in input
	begin
		select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_1( idU=' + isnull(cast(@idUnit as varchar),'?') +
				', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
				', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
				', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
				', idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
				', idSt=' + isnull(cast(@idStaff as varchar),'?') + ' )'
		exec	pr_Log_Ins	47, null, null, @s
		return	-1
	end

	if	@idStfAssn is null
		select	@idStfAssn= idStfAssn		from	tbStfAssn
				where	bActive > 0	and	idRoom = @idRoom	and	tiBed = @tiBed	and	idShift = @idShift	and	tiIdx = @tiIdx
--	print	@idStfAssn

	if	@idStfAssn is not null	and	@idStaff is null
		select	@bActive= 0

	if	@bActive > 0	and	exists( select 1 from tbStfAssn where idStfAssn = @idStfAssn and idStaff <> @idStaff )
	begin
		exec	dbo.prStfAssn_Fin	@idStfAssn
		select	@idStfAssn= null
	end

	begin	tran

		if	@bActive > 0
		begin
			if	@idStfAssn is null
	--		begin
				if	@idRoom > 0	and	@tiBed >= 0	and	@idShift > 0	and	@tiIdx > 0	and	@idStaff > 0	and	@TempID > 0
				begin
					if	@iTrace & 0x80 > 0
					begin
						select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_0( idU=' + isnull(cast(@idUnit as varchar),'?') +
								', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
								', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
								', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
								' ) idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
								', idSt=' + isnull(cast(@idStaff as varchar),'?') + '.'
						exec	dbo.pr_Log_Ins	46, null, null, @s
					end

					insert	tbStfAssn	(  bActive,  idRoom,  tiBed,  idShift,  tiIdx,  idStaff,  TempID,  iStamp )
							values		( @bActive, @idRoom, @tiBed, @idShift, @tiIdx, @idStaff, @TempID, @iStamp )
					select	@idStfAssn=	scope_identity( )
				end
				else	--	log an error in input
				begin
					select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_2( idU=' + isnull(cast(@idUnit as varchar),'?') +
							', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
							', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
							', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
							' ) idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
							', idSt=' + isnull(cast(@idStaff as varchar),'?') + '.'
					exec	pr_Log_Ins	47, null, null, @s
				end
	--		end
			else
				update	tbStfAssn	set
						TempID= @TempID, iStamp= @iStamp, dtUpdated= getdate( )	--	nothing else to update!!
				--	-	bActive= @bActive, idRoom= @idRoom, tiBed= @tiBed, idShift= @idShift,
				--	-	tiIdx= @tiIdx, idStaff= @idStaff, TempID= @TempID, dtUpdated= getdate( )
					where	idStfAssn = @idStfAssn
		end
		else
			exec	dbo.prStfAssn_Fin	@idStfAssn

	commit
end
go
grant	execute				on dbo.prStfAssn_InsUpdDel			to [rWriter]
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--				* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.00
create view		dbo.vwStfAssn
	with encryption
as
select	sa.idStfAssn,	sh.idUnit
	,	sa.idShift, sh.sShift, sh.tBeg [tShBeg], sh.tEnd [tShEnd]
	,	sa.idRoom, d.cDevice, d.sDevice [sRoom], d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idStaff, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff
	,	sc.idStfCvrg, sc.tBeg, sc.tEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfAssn	sa	with (nolock)
		inner join	tbShift	sh	with (nolock)	on	sh.idShift = sa.idShift
		inner join	vwStaff	s	with (nolock)	on	s.idStaff = sa.idStaff
		inner join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
		left outer join	tbStfCvrg	sc	with (nolock)	on	sc.idStfCvrg = sa.idStfCvrg
go
grant	select							on dbo.vwStfAssn		to [rWriter]
grant	select							on dbo.vwStfAssn		to [rReader]
go
--	----------------------------------------------------------------------------
--	Current (open) staff assignment history (coverage)
--	7.04.4920	* tbStaff -> tb_User (lStaffID -> sStaffID)
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--				* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.00
create view		dbo.vwStfCvrg
	with encryption
as
select	sa.idStfAssn,	sh.idUnit
	,	sa.idShift, sh.sShift, sh.tBeg [tShBeg], sh.tEnd [tShEnd]
	,	sa.idRoom, d.cDevice, d.sDevice [sRoom], d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idStaff, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff
	,	sc.idStfCvrg, sc.tBeg, sc.tEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfCvrg	sc	with (nolock)
		inner join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn
		inner join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift
		inner join	vwStaff		s	with (nolock)	on	s.idStaff = sa.idStaff
		inner join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
	where	sc.tiEnd is null
go
grant	select							on dbo.vwStfCvrg		to [rWriter]
grant	select							on dbo.vwStfCvrg		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
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
create proc		dbo.prStfCvrg_InsFin
	with encryption
as
begin
	declare		@dtNow			datetime
	declare		@tNow			time( 0 )
	declare		@idStfAssn		int
	declare		@idStfCvrg		int

	set	nocount	on

	select	@dtNow= getdate( ), @tNow= getdate( )

	create	table	#tbCurrAssn
	(
		idStfAssn		int not null
			primary key clustered

	,	bFinish			bit not null
	)

	begin	tran

		exec	pr_Module_Act	1

		--	assignments that are currently running (@ tNow)
		insert	#tbCurrAssn	--(idStfAssn, bFinish)
			select	idStfAssn, 1
				from	tbStfAssn		with (nolock)
				where	bActive > 0		and	idStfCvrg > 0

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
			select	sa.idStfAssn, sa.idStfCvrg
				from	tbStfAssn	sa		with (nolock)
					inner join	tbShift	sh	with (nolock)	on	sh.idShift = sa.idShift
				where	sa.bActive > 0
					and	(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStfAssn, @idStfCvrg
		while	@@fetch_status = 0
		begin
			if	@idStfCvrg is null
			begin
				--	begin coverage
				insert	tbStfCvrg	(  idStfAssn, dtBeg, dBeg, tBeg, tiBeg )
						values		( @idStfAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ) )
				select	@idStfCvrg=	scope_identity( )
				update	tbStfAssn		set	idStfCvrg= @idStfCvrg, dtUpdated= @dtNow
					where	idStfAssn= @idStfAssn
			end
			--	remove assignments that should be running, resulting in ones that need to finish
			update	#tbCurrAssn		set	bFinish= 0
				where	idStfAssn= @idStfAssn

			fetch next from	cur	into	@idStfAssn, @idStfCvrg
		end
		close	cur
		deallocate	cur

		--	reset assigned staff in completed assignments
		update	rb	set	rb.idAssn1= null, rb.idAssn2= null, rb.idAssn3= null, dtUpdated= @dtNow
			from	tbRoomBed	rb
			inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
			inner join	#tbCurrAssn	ca	on	ca.idStfAssn = sa.idStfAssn		and	ca.bFinish = 1

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
						(select	rb.idRoom, rb.tiBed, st.idStaffLvl, min(sa.idStfCvrg) [idStfCvrg]
							from	tbRoomBed	rb
							inner join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
							inner join	#tbCurrAssn	ca	on	ca.idStfAssn = sa.idStfAssn		and	ca.bFinish = 0
							inner join	tbStaff		st	on	st.idStaff = sa.idStaff
							inner join	tbStfCvrg	sc	on	sc.idStfCvrg = sa.idStfCvrg
							group	by	rb.idRoom, rb.tiBed, st.idStaffLvl
						)	t
					inner join	tbStfAssn	sa	on	sa.idStfCvrg = t.idStfCvrg
					inner join	tbUnit		u	on	u.idShift = sa.idShift	---	and	(u.idShPrv is null	or	u.idShPrv <> sa.idShift)
					group	by	t.idRoom, t.tiBed
				)	asn		on	asn.idRoom = rb.idRoom	and	asn.tiBed = rb.tiBed
*/
		---	set assigned staff
		update	rb	set	idAssn1=	sa.idStaff
			from	tbRoomBed	rb
	--		inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbRoom		r	on	r.idRoom = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStfAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 1	and	sa.bActive > 0
		update	rb	set	idAssn2=	sa.idStaff
			from	tbRoomBed	rb
	--		inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbRoom		r	on	r.idRoom = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStfAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 2	and	sa.bActive > 0
		update	rb	set	idAssn3=	sa.idStaff
			from	tbRoomBed	rb
	--		inner join	tbDevice	r	on	r.idDevice = rb.idRoom
			inner join	tbRoom		r	on	r.idRoom = rb.idRoom
			inner join	tbUnit		u	on	u.idUnit = r.idUnit
			inner join	tbStfAssn	sa	on	sa.idShift = u.idShift	and	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
										and	sa.tiIdx = 3	and	sa.bActive > 0

		--	finish coverage for completed assignments
		update	sc	set		dtEnd= @dtNow, dEnd= @dtNow, tEnd= @tNow, tiEnd= datepart( hh, @tNow )
			from	tbStfCvrg	sc
			inner join	#tbCurrAssn	ca	on	ca.idStfAssn = sc.idStfAssn		and	ca.bFinish = 1

		--	reset coverage refs for completed assignments
		update	sa	set		idStfCvrg= null, dtUpdated= @dtNow
			from	tbStfAssn		sa
			inner join	#tbCurrAssn	ca	on	ca.idStfAssn = sa.idStfAssn		and	ca.bFinish = 1

	commit
end
go
grant	execute				on dbo.prStfCvrg_InsFin				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns staff assigned to each room-bed (earliest responders of each kind)
--	7.04.4920	* tbStaff -> tb_User
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--				* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--				* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.00	.tiPtype -> .idStaffLvl
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.04
create function		dbo.fnStfAssn_GetByShift
(
	@idShift	smallint					-- shift look-up FK
)
	returns table
	with encryption
as
return
	select	r.idRoom, r.tiBed
		,	min(case when r.idStfLvl=4 then a.idStaff	else null end)	[idAsnRn]
		,	min(case when r.idStfLvl=4 then s.sStaff	else null end)	[sAsnRn]
		,	min(case when r.idStfLvl=2 then a.idStaff	else null end)	[idAsnCn]
		,	min(case when r.idStfLvl=2 then s.sStaff	else null end)	[sAsnCn]
		,	min(case when r.idStfLvl=1 then a.idStaff	else null end)	[idAsnAi]
		,	min(case when r.idStfLvl=1 then s.sStaff	else null end)	[sAsnAi]
		from
			(select	sa.idRoom, sa.tiBed, s.idStfLvl, min(sa.tiIdx) tiIdx			-- (earliest responders of each kind)
				from	tbStfAssn sa	with (nolock)
					inner join	tbShift sh	with (nolock)	on	sh.bActive > 0	and	sh.idShift = sa.idShift	and	sh.idShift = @idShift
					inner join	vwStaff	s	with (nolock)	on	s.bActive > 0	and	s.idStaff = sa.idStaff
				where	sa.bActive > 0
				group	by	sa.idRoom, sa.tiBed, s.idStfLvl)	r
			inner join	tbStfAssn	a	with (nolock)	on	a.bActive > 0	and	a.idRoom = r.idRoom		and	a.tiBed = r.tiBed	and	a.tiIdx = r.tiIdx
			inner join	tbShift		sh	with (nolock)	on	sh.bActive > 0	and	sh.idShift = a.idShift	and	sh.idShift = @idShift
			inner join	vwStaff		s	with (nolock)	on	s.bActive > 0	and	s.idStaff = a.idStaff	and	s.idStfLvl = r.idStfLvl
		group	by	r.idRoom, r.tiBed
---		order	by	r.idRoom, r.tiBed
go
grant	select				on dbo.fnStfAssn_GetByShift			to [rWriter]
grant	select				on dbo.fnStfAssn_GetByShift			to [rReader]
go
--	----------------------------------------------------------------------------
--	Receivers
--	7.04.4892	* .idDevice -> .idRoom, - fkRtlsRcvr_Device, + fkRtlsRcvr_Room
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRtlsRcvr') and name = 'idDevice')
begin
	begin tran
		alter table	dbo.tbRtlsRcvr		drop constraint	fkRtlsRcvr_Device
		exec sp_rename 'tbRtlsRcvr.idDevice',	'idRoom',	'column'
		alter table	dbo.tbRtlsRcvr		add
			constraint	fkRtlsRcvr_Room		foreign key	(idRoom)	references	tbRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	Badge types
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsBadgeType')
begin
	begin tran
		exec sp_rename 'tbRtlsBadgeType.idBadgeType','idBdgType',	'column'
		exec sp_rename 'tbRtlsBadgeType.sBadgeType','sBdgType',		'column'
		exec sp_rename 'tbRtlsBadge.idBadgeType',	'idBdgType',	'column'

		exec sp_rename 'tbRtlsBadgeType',		'tbRtlsBdgType',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Receivers
--	7.04.4958	- .idRcvrType, fkRtlsRcvr_Type, .sPhone
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRtlsRcvr') and name = 'idRcvrType')
begin
	begin tran
		alter table	dbo.tbRtlsRcvr		drop constraint	fkRtlsRcvr_Type
		alter table	dbo.tbRtlsRcvr		drop column	idRcvrType
		alter table	dbo.tbRtlsRcvr		drop column	sPhone

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsSnsr')
			drop table	dbo.tbRtlsSnsr
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsSnsrType')
			drop table	dbo.tbRtlsSnsrType
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsColl')
			drop table	dbo.tbRtlsColl
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsRcvrType')
			drop table	dbo.tbRtlsRcvrType
	commit
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRtlsRcvr') and name = 'sPhone')
begin
	begin tran
		alter table	dbo.tbRtlsRcvr		drop column	sPhone
	commit
end
go
--	----------------------------------------------------------------------------
--	Receivers
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	7.04.4892	* .idDevice -> .idRoom
--	6.04	* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	6.03
alter view		dbo.vwRtlsRcvr
	with encryption
as
select	r.idReceiver, r.sReceiver	--, r.idRcvrType, t.sRcvrType, r.sPhone
	,	r.idRoom, d.cDevice, d.sDevice, d.sSGJR, d.sSGJ	--, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	d.sSGJ + ' [' + d.cDevice + '] ' + d.sDevice [sFqDevice]
	,	r.bActive, r.dtCreated, r.dtUpdated
	from	tbRtlsRcvr r
--		inner join	tbRtlsRcvrType t	on	t.idRcvrType = r.idRcvrType
		left outer join	vwDevice d	on	d.idDevice = r.idRoom
go
--	----------------------------------------------------------------------------
--	Returns all receivers
--	7.04.4959	+ .sFqDevice
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	7.04.4892	* .idDevice -> .idRoom
--	7.03.4890
create proc		dbo.prRtlsRcvr_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idReceiver, sReceiver, idRoom, sFqDevice	--, sRcvrType
		,	bActive, dtCreated, dtUpdated
--		,	case when bActive > 0 then 'Yes' else 'No' end [sActive]
		from	vwRtlsRcvr	with (nolock)
end
go
grant	execute				on dbo.prRtlsRcvr_GetAll			to [rWriter]
grant	execute				on dbo.prRtlsRcvr_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given receiver
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	6.03
alter proc		dbo.prRtlsRcvr_InsUpd
(
	@idReceiver		smallint			-- id
--,	@idRcvrType		tinyint				-- type
,	@sReceiver		varchar( 255 )		-- name
--,	@sPhone			varchar( 255 )		-- phone
)
	with encryption
as
begin
---	set	nocount	on
	begin	tran
		if	exists	( select 1 from tbRtlsRcvr where idReceiver = @idReceiver )
	--		update	tbRtlsRcvr	set	idRcvrType= @idRcvrType, sReceiver= @sReceiver, sPhone= @sPhone, bActive= 1, dtUpdated= getdate( )
			update	tbRtlsRcvr	set	sReceiver= @sReceiver, bActive= 1, dtUpdated= getdate( )
				where	idReceiver = @idReceiver
		else
	--		insert	tbRtlsRcvr ( idReceiver, idRcvrType, sReceiver, sPhone )
	--			values	( @idReceiver, @idRcvrType, @sReceiver, @sPhone )
			insert	tbRtlsRcvr	(  idReceiver,  sReceiver )
					values		( @idReceiver, @sReceiver )
	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
--	7.04.4898	- fkRtlsBadge_Device, + fkRtlsBadge_Room
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRtlsBadge_Device')
begin
	begin tran
		alter table	dbo.tbRtlsBadge		drop constraint	fkRtlsBadge_Device
		alter table	dbo.tbRtlsBadge		add
			constraint	fkRtlsBadge_Room	foreign key	(idRoom)	references	tbRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge type
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	6.03
/*
create proc		dbo.prRtlsBdgType_InsUpd
(
	@idBdgType		tinyint				-- id
,	@sBdgType		varchar( 32 )		-- desc
)
	with encryption
as
begin
---	set	nocount	on
	begin	tran
		if	exists	( select 1 from tbRtlsBdgType where idBdgType = @idBdgType )
			update	tbRtlsBdgType		set	sBdgType= @sBdgType, bActive= 1, dtUpdated= getdate( )
				where	idBdgType = @idBdgType
		else
			insert	tbRtlsBdgType ( idBdgType, sBdgType )
				values ( @idBdgType, @sBdgType )
	commit
end
g o
grant	execute				on dbo.prRtlsBdgType_InsUpd			to [rWriter]
*/
go
--	----------------------------------------------------------------------------
--	Badges
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRtlsBadge') and name = 'idBdgType')
begin
	begin tran
		alter table	dbo.tbRtlsBadge		drop constraint	fkRtlsBadge_Type
		alter table	dbo.tbRtlsBadge		drop column	idBdgType

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsBdgType')
			drop table	dbo.tbRtlsBdgType
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsBadgeType')
			drop table	dbo.tbRtlsBadgeType
	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
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
	,	sd.idStaff, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.sFqStaff
	,	b.idRoom, d.cDevice, d.sDevice, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, b.dtEntered
	,	b.idRcvrCurr, r.sReceiver [sRcvrCurr], b.dtRcvrCurr
	,	b.idRcvrLast, l.sReceiver [sRcvrLast], b.dtRcvrLast
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		inner join	tbStfDvc	sd	with (nolock)	on	sd.idStfDvc = b.idBadge
--		inner join	tbRtlsBdgType	t	with (nolock)	on	t.idBdgType = b.idBdgType
		left outer join	vwStaff		s	with (nolock)	on	s.idStaff =	sd.idStaff
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = b.idRoom
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idRcvrCurr
		left outer join	tbRtlsRcvr	l	with (nolock)	on	l.idReceiver = b.idRcvrLast
go
--	----------------------------------------------------------------------------
--	Returns all badges
--	7.04.4959	+ .sFqStaff, @bStaff, @bRoom
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--	7.03.4890
create proc		dbo.prRtlsBadge_GetAll
(
	@bStaff		bit
,	@bRoom		bit
)
	with encryption
as
begin
--	set	nocount	on
	if	@bStaff > 0
		select	idBadge,	idStaff, sFqStaff
			,	idRoom, sSGJ + ' [' + cDevice + '] ' + sDevice [sCurrLoc]
			,	dtEntered, cast(getdate( )-dtEntered as time(0)) [tDuration]	--,	sBdgType
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge	with (nolock)
			where	( @bRoom = 0	or	idRoom is not null )
			and		idStaff is not null
			order	by	sFqStaff, idBadge
	else
		select	idBadge,	idStaff, sFqStaff
			,	idRoom, sSGJ + ' [' + cDevice + '] ' + sDevice [sCurrLoc]
			,	dtEntered, cast(getdate( )-dtEntered as time(0)) [tDuration]	--,	sBdgType
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge	with (nolock)
			where	( @bRoom = 0	or	idRoom is not null )
end
go
grant	execute				on dbo.prRtlsBadge_GetAll			to [rWriter]
grant	execute				on dbo.prRtlsBadge_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge
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
--,	@idBdgType		tinyint				-- type
)
	with encryption, exec as owner
as
begin
---	set	nocount	on
	begin	tran
		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
--			update	dbo.tbRtlsBadge		set	idBdgType= @idBdgType, bActive= 1, dtUpdated= getdate( )
			update	tbRtlsBadge		set	bActive= 1, dtUpdated= getdate( )
				where	idBadge = @idBadge
		else
		begin
			set identity_insert	dbo.tbStfDvc	on

			insert	tbStfDvc	( idStfDvc, idDvcType, sStfDvc )
					values		( @idBadge, 1, 'Badge ' + right('00000000' + cast(@idBadge as varchar), 8) )

			set identity_insert	dbo.tbStfDvc	off

			insert	tbRtlsBadge	(  idBadge )	--,  idBdgType
					values		( @idBadge )	--, @idBdgType
		end
	commit
end
go
deny	alter							on dbo.tbRtlsBadge		to [rWriter]
go
--	----------------------------------------------------------------------------
--	Resets location attributes for all badges
--	7.03.4898	* prBadge_ClrAll -> prRtlsBadge_RstLoc
--	6.03
create proc		dbo.prRtlsBadge_RstLoc
	with encryption
as
begin
	set	nocount	on

	begin	tran
		update	tbRtlsRoom	set idBadge= null, bNotify= 1, dtUpdated= getdate( )
		update	tbRtlsBadge	set idRoom= null, idRcvrCurr= null, dtEntered= getdate( ), dtUpdated= getdate( )
	commit
end
go
grant	execute				on dbo.prRtlsBadge_RstLoc			to [rWriter]
--grant	execute				on dbo.prRtlsBadge_RstLoc			to [rReader]
go
--	----------------------------------------------------------------------------
--	Deactivates all devices, resets room state
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03.4862
create proc		dbo.prCfgDvc_Init
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		update	tbRoom		set	idUnit= null, idEvent= null, tiSvc= null,	dtUpdated= getdate( )
							,	idRn= null,	sRn= null,	idCn= null,	sCn= null,	idAi= null,	sAi= null

		update	tbDevice	set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1

		select	@s= 'Dvc_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgDvc_Init				to [rWriter]
go
--	----------------------------------------------------------------------------
--	* dbo.StaffToPatientAssignment:	+ .idRoom
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	and	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='StaffToPatientAssignment')
	and	not	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.StaffToPatientAssignment') and name='idRoom')
begin
	exec( 'alter table	dbo.StaffToPatientAssignment	add
				idRoom					smallint null' )
	exec( 'update	sa	set	sa.idRoom= rb.idRoom
				from	dbo.StaffToPatientAssignment sa
				inner join	dbo.vwRoomBed rb	on	rb.sRoom = sa.RoomName	and	(rb.tiBed = sa.BedIndex		or	rb.tiBed = 255	and	sa.BedIndex = '''')' )
	exec( 'delete	from	dbo.StaffToPatientAssignment	where	idRoom is null' )
	exec( 'alter table	dbo.StaffToPatientAssignment	alter column
				idRoom					smallint not null' )
end
go
--	----------------------------------------------------------------------------
--	Inserts/deletes a StaffToPatientAssignment row
--	7.04.4916	* fix for duplicate rows when dial#s are changed
--	7.03	* fix for updating room-names
--	7.01	* fix for rooms without beds
--	7.00
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prDevice_UpdRoomBeds7980
(
	@bInsert	bit					-- insert or delete?
,	@idRoom		smallint			-- room id
,	@cBedIdx	varchar( 1 )		-- bed index: '' ''=no bed, null=all combinations
,	@sRoom		varchar( 16 )
,	@sDial		varchar( 16 )
,	@idUnitP	smallint
,	@idUnitA	smallint
)
	with encryption
as
begin
	set	nocount	on
	begin	tran
		if	@bInsert = 0
			delete	from	StaffToPatientAssignment
				where	idRoom = @idRoom		--	RoomNumber = @sDial
					and	(BedIndex = @cBedIdx
						or	@cBedIdx is null	and	(BedIndex is null	or	BedIndex <> '' ''))
		else
			if	not exists	(select 1 from StaffToPatientAssignment where RoomNumber = @sDial and BedIndex = @cBedIdx)
				insert	StaffToPatientAssignment
						( idRoom, RoomNumber, RoomName, BedIndex, DownloadCounter, PrimaryUnitID, SecondaryUnitID )
					values		( @idRoom, @sDial, @sRoom, @cBedIdx, 0, @idUnitP, @idUnitA )
			else
				update	StaffToPatientAssignment
					set	RoomName= @sRoom,	PrimaryUnitID= @idUnitP, SecondaryUnitID= @idUnitA
					where	idRoom = @idRoom		--	RoomNumber = @sDial
						and	BedIndex = @cBedIdx
	commit
end' )
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
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

	begin	tran

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
			exec	prDevice_UpdRoomBeds7980	0, @idRoom, null, @sRoom, @sDial, @idUnitP, @idUnitA
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
			begin
				insert	tbRoomBed	(  idRoom, cBed, tiBed )
						values		( @idRoom, null, 0xFF )
			end
			exec	prDevice_UpdRoomBeds7980	1, @idRoom, ' ', @sRoom, @sDial, @idUnitP, @idUnitA
		end
		else							--	there are beds
		begin
			--	remove combination with no beds
			exec	prDevice_UpdRoomBeds7980	0, @idRoom, ' ', @sRoom, @sDial, @idUnitP, @idUnitA
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF

			while	@siMask < 1024
			begin
				select	@cBedIdx= cast(@tiBed as char(1))

				if	@siBeds & @siMask > 0		--	@tiBed is present in @idRoom
				begin
					update	tbCfgBed	set	bInUse= 1, dtUpdated= getdate( )	where	tiBed = @tiBed
					select	@cBed= cBed, @sBeds= @sBeds + cBed
						from	tbCfgBed	with (nolock)
						where	tiBed = @tiBed

					if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = @tiBed)
					begin
						insert	tbRoomBed	(  idRoom,  cBed,  tiBed )
								values		( @idRoom, @cBed, @tiBed )
					end
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnitP, @idUnitA
				end
				else							--	@tiBed is absent in @idRoom
				begin
						exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnitP, @idUnitA
						delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = @tiBed
				end

				select	@siMask= @siMask * 2
					,	@tiBed=  case when @tiBed < 9 then @tiBed + 1 else 0 end
			end
		end

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
go
--	----------------------------------------------------------------------------
--	Updates 790 device assigned to a given receiver
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
	set	nocount	on

	begin	tran
		if	@idRoom is not null		--	prepare room state
			and	exists	(select 1 from tbRoom with (nolock) where idRoom = @idRoom)		--	7.04
		begin
			if	not	exists	(select 1 from tbRtlsRoom with (nolock) where idRoom = @idRoom and idStfLvl = 1)
				insert	tbRtlsRoom	(idRoom, idStfLvl)	values (@idRoom, 1)

			if	not	exists	(select 1 from tbRtlsRoom with (nolock) where idRoom = @idRoom and idStfLvl = 2)
				insert	tbRtlsRoom	(idRoom, idStfLvl)	values (@idRoom, 2)

			if	not	exists	(select 1 from tbRtlsRoom with (nolock) where idRoom = @idRoom and idStfLvl = 4)
				insert	tbRtlsRoom	(idRoom, idStfLvl)	values (@idRoom, 4)
		end

		update	tbRtlsRcvr	set		dtUpdated= getdate( ),	idRoom= @idRoom
			where	idReceiver = @idReceiver
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge
--	7.04.4898	* prBadge_UpdLoc -> prRtlsBadge_UpdLoc
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.04.4892	* tbRtlsRcvr:	.idDevice -> .idRoom
--	7.02	* commented out tracing non-existing badges - too much output
--			* @idBadge: smallint -> int
--	7.00	.tiPtype -> .idStaffLvl
--	6.03
create proc		dbo.prRtlsBadge_UpdLoc
(
	@idBadge		int					-- 1-65535 (unsigned)
,	@idRcvrCurr		smallint			-- current receiver look-up FK
,	@dtRcvrCurr		datetime			-- when registered by current rcvr
,	@idRcvrLast		smallint			-- last receiver look-up FK
,	@dtRcvrLast		datetime			-- when registered by last rcvr

,	@idRoomPrev		smallint out		-- previous 790 device look-up FK
,	@idRoomCurr		smallint out		-- current 790 device look-up FK
,	@dtEntered		datetime out		-- when entered the room
,	@idStfLvl		tinyint out			-- 4=RN, 2=CNA, 1=Aide, ..
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
		,	@idStfLvl= idStfLvl, @cSys= cSys, @tiGID= tiGID, @tiJID= tiJID, @tiRID= tiRID		--	previous!!
		from	vwRtlsBadge		where	idBadge = @idBadge

---	select	@s=	@s + ' R=' + isnull(cast(@idReceiver as varchar),'?') + ' P=' + isnull(cast(@idRoomPrev as varchar),'?')
---	exec	pr_Log_Ins	0, null, null, @s

	if	@idReceiver = @idRcvrCurr	return	0		--	badge already at same location => skip

	select	@iRetVal= 1, @idRoomCurr= idRoom		--	new room
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
				where	idRoom = @idRoomCurr	and	idStfLvl = @idStfLvl	and	idBadge is null

			select	top 1	@idOldest= idBadge								--	get oldest badge of same type for prev room
				from	vwRtlsBadge
				where	idRoom = @idRoomPrev	and	idStfLvl = @idStfLvl	---	and	idBadge is not null		--	not necessary!
				order	by	dtEntered
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= null		--	remove that oldest from any room
				where	idBadge = @idOldest
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= @idOldest	--	set prev room to the oldest badge
				where	idRoom = @idRoomPrev	and	idStfLvl = @idStfLvl
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
grant	execute				on dbo.prRtlsBadge_UpdLoc			to [rWriter]
go
--	----------------------------------------------------------------------------
--	Rooms 'presense' state (oldest badges)
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
	,	min(case when r.idStfLvl=4 then sd.idStaff	else null end)	[idRn]
	,	min(case when r.idStfLvl=4 then s.sStaff	else null end)	[sRn]
	,	min(case when r.idStfLvl=2 then sd.idStaff	else null end)	[idCn]
	,	min(case when r.idStfLvl=2 then s.sStaff	else null end)	[sCn]
	,	min(case when r.idStfLvl=1 then sd.idStaff	else null end)	[idAi]
	,	min(case when r.idStfLvl=1 then s.sStaff	else null end)	[sAi]
	,	max(cast(r.bNotify as tinyint))							[tiNotify]
	,	min(r.dtUpdated)										[dtUpdated]
	from	tbRtlsRoom		r	with (nolock)
		inner join	tbDevice		d	with (nolock)	on	d.idDevice = r.idRoom
		left outer join	tbRtlsBadge	b	with (nolock)	on	b.idBadge = r.idBadge
		left outer join	tbStfDvc	sd	with (nolock)	on	sd.idStfDvc = b.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idStaff = sd.idStaff
	group by	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
go
--	----------------------------------------------------------------------------
--	Role report access permissions
--	7.04.4897	* tb_RoleReport -> tb_RoleRpt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_RoleReport')
begin
	begin tran
		exec sp_rename 'tb_RoleReport',				'tb_RoleRpt',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts/removes access record
--	7.04.4913
create proc		dbo.pr_RoleRpt_Set
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
			if	not	exists	(select 1 from tb_RoleRpt where idRole = @idRole and idReport = @idReport)
				insert	tb_RoleRpt	(  idRole,  idReport )
						values		( @idRole, @idReport )
		else
	/*		if	@idReport is null
				delete	from	tb_RoleRpt
					where	idRole = @idRole	and	idReport = @idReport
			else
	*/			delete	from	tb_RoleRpt
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
grant	execute				on dbo.pr_RoleRpt_Set				to [rWriter]
grant	execute				on dbo.pr_RoleRpt_Set				to [rReader]
go
--	----------------------------------------------------------------------------
--	Adds call-priorities necessary to report presence events
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	6.05	+ (nolock), optimize
--	6.00	tbRptSessCall -> tb_SessCall, .idRptSess -> .idSess
--	5.01
alter proc		dbo.pr_SessCall_Set
(
	@idSess		int
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		insert	tb_SessCall		( idSess, idCall, siIdx, tVoTrg, tStTrg, sCall )
			select	@idSess, c.idCall, c.siIdx, c.tVoTrg, c.tStTrg, c.sCall
				from		tbCall	c	with (nolock)
				inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = c.siIdx
				where	p.tiSpec = 7		-- RN

		insert	tb_SessCall		( idSess, idCall, siIdx, tVoTrg, tStTrg, sCall )
			select	@idSess, c.idCall, c.siIdx, c.tVoTrg, c.tStTrg, c.sCall
				from		tbCall	c	with (nolock)
				inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = c.siIdx
				where	p.tiSpec = 8		-- CNA

		insert	tb_SessCall		( idSess, idCall, siIdx, tVoTrg, tStTrg, sCall )
			select	@idSess, c.idCall, c.siIdx, c.tVoTrg, c.tStTrg, c.sCall
				from		tbCall	c	with (nolock)
				inner join	tbCfgPri	p	with (nolock)	on	p.siIdx = c.siIdx
				where	p.tiSpec = 9		-- Aide
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a session's call filter
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.03
alter proc		dbo.pr_SessCall_Ins
(
	@idSess		int
,	@idCall		smallint
,	@siIdx		smallint			-- call-index
--,	@sCall		varchar( 16 )		-- call-text
,	@tVoTrg		time( 0 )
,	@tStTrg		time( 0 )
)
	with encryption
as
begin
	declare		@sCall	varchar( 16 )

	set	nocount	on

	select	@sCall= sCall
		from	tbCfgPri	with (nolock)	where	siIdx = @siIdx

	begin	tran

		insert	tb_SessCall	(  idSess,  idCall,  siIdx,  sCall,  tVoTrg,  tStTrg )
				values		( @idSess, @idCall, @siIdx, @sCall, @tVoTrg, @tStTrg )

	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans-up session's filter tables
--	7.04.4947	- tb_SessLoc
--	7.03
alter proc		dbo.pr_Sess_Clr
(
	@idSess		int
)
	with encryption
as
begin
	set	nocount	on
	begin	tran

		delete from	tb_SessStaff	where	idSess = @idSess
		delete from	tb_SessShift	where	idSess = @idSess
		delete from	tb_SessCall		where	idSess = @idSess
--	-	delete from	tb_SessLoc		where	idSess = @idSess
		delete from	tb_SessDvc		where	idSess = @idSess

	commit
end
go
--	----------------------------------------------------------------------------
--	Cleans-up a session
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
	begin	tran

		if	@idSess = 0		-- app-end
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

			delete from	tb_SessStaff
			delete from	tb_SessShift
			delete from	tb_SessCall
	--	-	delete from	tb_SessLoc
			delete from	tb_SessDvc
			delete from	tb_Sess
		end
		else				-- sess-end
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
	--	-	delete from	tb_SessStaff	where	idSess = @idSess
	--	-	delete from	tb_SessShift	where	idSess = @idSess
	--	-	delete from	tb_SessCall		where	idSess = @idSess
	--	-	delete from	tb_SessLoc		where	idSess = @idSess
	--	-	delete from	tb_SessDvc		where	idSess = @idSess
			delete from	tb_Sess			where	idSess = @idSess
		end

	commit
end
go
--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessLoc')
	drop table	dbo.tb_SessLoc
go
--	----------------------------------------------------------------------------
--	Staff definitions
--	7.04.4920	- tbStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaff')
begin
	begin tran
		alter table	dbo.tbStfDvc	drop constraint	fkStfDvc_Staff
		alter table	dbo.tbStfDvc	add
			constraint	fkStfDvc_Staff	foreign key	(idStaff)	references	tb_User

		alter table	dbo.tbRoom		drop constraint	fkRoom_Rn
		alter table	dbo.tbRoom		drop constraint	fkRoom_Cna
		alter table	dbo.tbRoom		drop constraint	fkRoom_Aide
		alter table	dbo.tbRoom		add
			constraint	fkRoom_Rn		foreign key	(idRn)	references tb_User
		,	constraint	fkRoom_Cna		foreign key	(idCn)	references tb_User
		,	constraint	fkRoom_Aide		foreign key	(idAi)	references tb_User

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_Assn1')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_Assn1
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_Assn2')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_Assn2
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_Assn3')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_Assn3
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_AsnRn')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_AsnRn
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_AsnCna')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_AsnCna
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoomBed_AsnAide')
			alter table	dbo.tbRoomBed	drop constraint	fkRoomBed_AsnAide
		alter table	dbo.tbRoomBed	add
			constraint	fkRoomBed_Assn1	foreign key	(idAssn1)	references tb_User
		,	constraint	fkRoomBed_Assn2	foreign key	(idAssn2)	references tb_User
		,	constraint	fkRoomBed_Assn3	foreign key	(idAssn3)	references tb_User

		alter table	dbo.tbShift		drop constraint	fkShift_Staff
		alter table	dbo.tbShift		add
			constraint	fkShift_Staff	foreign key	(idStaff)	references tb_User

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStfAssn_Staff')
			alter table	dbo.tbStfAssn	drop constraint	fkStfAssn_Staff
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffAssn_Staff')
			alter table	dbo.tbStfAssn	drop constraint	fkStaffAssn_Staff
		alter table	dbo.tbStfAssn	add
			constraint	fkStfAssn_Staff		foreign key	(idStaff)	references	tb_User

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_SessStaff_User')
			alter table	dbo.tb_SessStaff	drop constraint	fk_SessStaff_User
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_SessStaff_Shift')
			alter table	dbo.tb_SessStaff	drop constraint	fk_SessStaff_Shift
		alter table	dbo.tb_SessStaff	add
			constraint	fk_SessStaff_User	foreign key	(idStaff)	references tb_User

		drop table	dbo.tbStaff
	commit
end
go
--	----------------------------------------------------------------------------
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
				left outer join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
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
				left outer join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
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
				left outer join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
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
					left outer join	tbCall	c	with (nolock)	on	c.idCall = e.idCall
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
					left outer join	tbCall	c	with (nolock)	on	c.idCall = e.idCall
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
					left outer join	tbCall	c	with (nolock)	on	c.idCall = e.idCall
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
					left outer join	tbCall	c	with (nolock)	on	c.idCall = e.idCall
					left outer join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
					left outer join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
					left outer join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
					left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
					left outer join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
					left outer join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
				order	by	s.sDevice, s.idParent, e.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--				* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.00	+ "Room-Bed" -> "Room : Bed";  sorting: idRoom -> sDevice
--			.tiPtype -> .idStaffLvl
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	6.02
alter proc		dbo.prRptStaffAssn
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 255=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 255=any, 1=specific (tb_SessStaff), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 255
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
	else
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
				---	where	c.dEvent between @dFrom and @dUpto		--	ignore for this report
				---		and	c.tiHH between @tFrom and @tUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
end
go
--	----------------------------------------------------------------------------
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
alter proc		dbo.prRptStaffCover
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 255=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 255=any, 1=specific (tb_SessStaff), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 255
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
				--	,	a.idShift, h.idStaff [idStaffBkup], h.tiIdx [tiShift], a.idStaffAssn, a.dtCreated, a.dtUpdated
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
	else
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.sStaffID [lStaffID], s.sStaff, s.sStfLvl
					from			tbStfAssn		a	with (nolock)
						inner join	tbStfCvrg		p	with (nolock)	on	p.idStfAssn = a.idStfAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbCfgBed		b	with (nolock)	on	b.tiBed = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStfCvrg, a.tiIdx
end
go

--	----------------------------------------------------------------------------
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_InsertExceptionLog')
	drop proc	dbo.sp_InsertExceptionLog
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_Exp')
	drop proc	dbo.prUnit_Exp
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_Exp')
	drop proc	dbo.prStaff_Exp
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='ArchitecturalConfig')
	drop table	dbo.ArchitecturalConfig
if	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='BedDefinition')
	drop table	dbo.BedDefinition
if	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='ExceptionLog')
	drop table	dbo.ExceptionLog
if	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='UserMember')
	drop table	dbo.UserMember
if	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='DBVersion')
	drop table	dbo.DBVersion
if	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='User7985')
	drop table	dbo.User7985
if	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='Units')
	drop table	dbo.Units
go
--	----------------------------------------------------------------------------
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	and	not	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='V' and name='ArchitecturalConfig')
begin
exec( 'create view		dbo.ArchitecturalConfig
--	with encryption
as
select	cast(idLoc as int)		[ID]
	,	sLoc					[Name]
	,	cast(idParent as int)	[Parent_ID]
--	,	tiLvl, cLoc
	,	case
			when tiLvl = 0 then ''Facility''
			when tiLvl = 1 then ''System''
			when tiLvl = 2 then ''Bldg''
			when tiLvl = 3 then ''Floor''
			when tiLvl = 4 then ''Unit''
			when tiLvl = 5 then ''CArea''
		end			[ArchitecturalLevel]
from	dbo.tbCfgLoc	with (nolock)' )

grant	select							on dbo.ArchitecturalConfig	to [rWriter]
grant	select							on dbo.ArchitecturalConfig	to [rReader]
end
go
--	----------------------------------------------------------------------------
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	and	not	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='V' and name='BedDefinition')
begin
exec( 'create view		dbo.BedDefinition
--	with encryption
as
select	cast(tiBed as int)	[BedDefinitionID]
	,	cBed	[Designator]
	,	cDial	[DialableNumber]
from	dbo.tbCfgBed	with (nolock)' )

grant	select							on dbo.BedDefinition		to [rWriter]
grant	select							on dbo.BedDefinition		to [rReader]
end
go
--	----------------------------------------------------------------------------
--	Exports staff assignment definitions
--	7.04.4955
--	6.05
--	6.02
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prStaffAssnDef_Exp
--	with encryption
as
begin
	select	cast(rtrim(RoomName) as varchar(16))	[sRoom]
		,	cast(rtrim(RoomNumber) as varchar(16))	[sDial]
		,	cast(case when BedIndex=''0'' or BedIndex='''' or BedIndex='' '' then ''255'' else BedIndex end as tinyint)	[tiBed]
		,	cast(case when PrimaryUnitID=256	or PrimaryUnitID=0		then null	else PrimaryUnitID end		as smallint)	[idUnit1]
		,	cast(case when SecondaryUnitID=256	or SecondaryUnitID=0	then null	else SecondaryUnitID end	as smallint)	[idUnit2]
		,	dtUpdate [dtUpdated]
		,	TempID

		,	case when len(FirstRspndrIDShift1)=0	then null else cast(rtrim(FirstRspndrIDShift1) as bigint) end	[lStaffID11]
		,	case when len(SecondRspndrIDShift1)=0	then null else cast(rtrim(SecondRspndrIDShift1) as bigint) end	[lStaffID12]
		,	case when len(ThirdRspndrIDShift1)=0	then null else cast(rtrim(ThirdRspndrIDShift1) as bigint) end	[lStaffID13]

		,	case when len(FirstRspndrIDShift2)=0	then null else cast(rtrim(FirstRspndrIDShift2) as bigint) end	[lStaffID21]
		,	case when len(SecondRspndrIDShift2)=0	then null else cast(rtrim(SecondRspndrIDShift2) as bigint) end	[lStaffID22]
		,	case when len(ThirdRspndrIDShift2)=0	then null else cast(rtrim(ThirdRspndrIDShift2) as bigint) end	[lStaffID23]

		,	case when len(FirstRspndrIDShift3)=0	then null else cast(rtrim(FirstRspndrIDShift3) as bigint) end	[lStaffID31]
		,	case when len(SecondRspndrIDShift3)=0	then null else cast(rtrim(SecondRspndrIDShift3) as bigint) end	[lStaffID32]
		,	case when len(ThirdRspndrIDShift3)=0	then null else cast(rtrim(ThirdRspndrIDShift3) as bigint) end	[lStaffID33]

		from	StaffToPatientAssignment
		where	PrimaryUnitID >= 259	or	SecondaryUnitID >= 259		--	enforce only valid Unit IDs
		order	by	sRoom, tiBed
end' )
go
--	----------------------------------------------------------------------------
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	and	not	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='V' and name='Units')
begin
exec( 'create view		dbo.Units
	with encryption
as
select	cast(u.idUnit as int) [ID], u.sUnit [Name], cast(u.tiShifts as int) [ShiftsPerDay]
	,	cast(s1.tiRouting as int) [CustomRoutingShift1], cast(s1.tiNotify as int) as [NotificationModeShift1]
	,		cast(s1.tBeg as varchar) [StartTimeShift1], cast(s1.tEnd as varchar) [EndTimeShift1],	isnull(t1.sStaffID, '''') [BackupStaffIDShift1]
	,	cast(s2.tiRouting as int) [CustomRoutingShift2], cast(s2.tiNotify as int) as [NotificationModeShift2]
	,		cast(s2.tBeg as varchar) [StartTimeShift2], cast(s2.tEnd as varchar) [EndTimeShift2],	isnull(t2.sStaffID, '''') [BackupStaffIDShift2]
	,	cast(s3.tiRouting as int) [CustomRoutingShift3], cast(s3.tiNotify as int) as [NotificationModeShift3]
	,		cast(s3.tBeg as varchar) [StartTimeShift3], cast(s3.tEnd as varchar) [EndTimeShift3],	isnull(t3.sStaffID, '''') [BackupStaffIDShift3]
	,	u.dtUpdated [dtUpdate], cast(0 as int) [DownloadCounter]
	from	dbo.tbUnit	u	with (nolock)
	left outer join	dbo.tbShift	s1	with (nolock)	on	u.idUnit = s1.idUnit	and	s1.tiIdx = 1	and	s1.bActive > 0
	left outer join	dbo.tb_User	t1	with (nolock)	on	t1.idUser = s1.idStaff
	left outer join	dbo.tbShift	s2	with (nolock)	on	u.idUnit = s2.idUnit	and	s2.tiIdx = 2	and	s2.bActive > 0
	left outer join	dbo.tb_User	t2	with (nolock)	on	t2.idUser = s2.idStaff
	left outer join	dbo.tbShift	s3	with (nolock)	on	u.idUnit = s3.idUnit	and	s3.tiIdx = 3	and	s3.bActive > 0
	left outer join	dbo.tb_User	t3	with (nolock)	on	t3.idUser = s3.idStaff
	where	u.idUnit > 0		--	exclude internal unit' )

grant	select, update					on dbo.Units			to [rWriter]
grant	select, update					on dbo.Units			to [rReader]
end
go
--	----------------------------------------------------------------------------
--	* dbo.Staff:	+ .bLoggedIn
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
	and	exists	(select 1 from dbo.sysobjects where uid=1 and xtype='U' and name='Staff')
	and	not	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.Staff') and name='bLoggedIn')
exec( 'alter table	dbo.Staff	add
			bLoggedIn				bit not null
				constraint	tdStaff_LoggedIn	default(0)' )
go


if	exists	( select 1 from tb_Version where idVersion = 704 )
	update	dbo.tb_Version	set	dtCreated= '2013-08-14', siBuild= 4974, dtInstall= getdate( )
		,	sVersion= '7.04.4974 - schema refactored, 7980 custom routing, event transactions, expiration'
		where	idVersion = 704
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 704,	4974, '2013-08-14', getdate( ),	'7.04.4974 - schema refactored, 7980 custom routing, event transactions, expiration' )
--go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.4.4974'
	where	idModule = 1
/**/
go

checkpoint
go

use [master]
go
