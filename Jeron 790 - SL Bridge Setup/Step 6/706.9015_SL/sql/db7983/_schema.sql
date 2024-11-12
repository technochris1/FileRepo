--	============================================================================
--	Database schema script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 790 Applications
--
--	Arguments:
--		{0} - DB name
--
--	01	2011-Jan-19
--	02	2011-Jan-27		tbEvent83 incorporated into tbEvent
--						cascading changes to other objects (.idRoom)
--	03	2011-Jan-27		tbEvent9C incorporated into tbEvent9E
--						commented lines removed
--	04	2011-Feb-01		tbEvent96 incorporated into tbEvent98
--						commented lines removed
--						tbDefCall: + .tVoice, .tStaff
--	05	2011-Feb-09		tbDefCall: + .bActive, default constraints
--		2011-Feb-10		tbEventC: + .cBed
--		2011-Feb-11		+ tbFltVal
--	06	2011-Feb-17		tbDefCall: .tVoice -> .tVoTrg, .tVoMax; .tStaff -> .tStTrg, .tStMax
--						same for (tbRptFilter?? and) tbRptFltVal
--		2011-Feb-21		+ tbRptSess, tbFltVal (tbRptFltVal) linked to it now
--	07	2011-Mar-09		+ tbEventT, tbDefType (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--		2011-Mar-10		+ tbEventC.xtEventC_dEvent_tiHH
--		2011-Mar-11		+ tbRptSess.sBrowser (prRptSess_Ins)
--	08	2011-Mar-11		+ tbEvent.iHash (prEvent*_Ins)
--						tbEvent.vbCmd: vc(252) -> vc(256) (prEvent*_Ins)
--		2011-Mar-14		+ tbEvent8A.tiFlags
--		2011-Mar-15		+ tbDefCall.siIdx (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins?, vwEvent8A)
--						tbEventT.idType -> + tbEvent.idType, - tbEventT
--		2011-Mar-16		- tbRptFilter.idRptMaster:  filters no longer bound to specific report
--						renamed tbRptFltVal -> tbRptSessCall
--						+ xuRptUser, + xuRptFilter
--		2011-Mar-17		+ tbDefRoom.sDial (- tbEvent84.idRoom2, prEvent84_Ins)
--						tbEvent84.cBed2 -> .tiBed (prEvent84_Ins, vwEvent84)
--	09	2011-Mar-21		+ tbEvent.sInfo (<- tbEvent84,95,98)
--						+ vwEvent.id|sType
--						+ vwEventC.id|sType
--						+ tbRptSessLoc
--		2011-Mar-22		prEvent_Ins( + idType= null )
--		2011-Mar-23		+ vwEvent.dEvent,.tEvent
--						+ tbEvent.tiHH (vwEvent)
--	2.01				[.tiHH -> .tiHour]
--						+ tbDefRoom (new), vwDefRoom, tbDefMaster
--		2011-Mar-24		tbEvent.idRoom -> .idDevice (FK changed also)
--						tbRptMaster -> tbRptTempl
--						- .tVoMax, .tStMax (tbDefCall, tbRptSessCall)
--						tbEventC.idRoom -> .idDevice (FK changed also)
--		2011-Mar-25		- tbEvent99.siPriNew, .siPriOld (prEvent99_Ins)
--						- tbEvent8A.idDstDvc (prEvent8A_Ins, vwEvent8A)
--						.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--		2011-Mar-28		+ tbRptSessDvc (prRptSess_Del)
--				?		- tbDefRoom, - vwDefRoom, - tbDefMaster
--				?		+ tbDefDevice (combines all)
--		2011-Mar-30		tbRptFilter.sXmlFilter: vc(4096) -> vc(8000)
--						- tbRptFilter.nXmlFilter
--		2011-Mar-31		+ tbRptSessCall.siIdx
--		2011-Apr-01		+ tbDefDevice.cDevice (prEvent_Ins)
--						+ tbDefLoc.cLoc
--						+ dbroles: rWriter, rReader in <*create-db.sql>
--						+ object permissions
--						+ logins, dbusers: e_logger, e_client in <*create-db.sql>
--	2.02
--		2011-Apr-04		+ tbEventC.idRn, .tRn, .idCna, .tCna, .idAide, .tAide (vwEventC, prEvent84_Ins?)
--		2011-Apr-05		+ tbDefBed, tbDefCallP, prDefCall_InsUpd?
--						[+ tbDefCall.dtCreated? - not needed]
--						+ prDefLoc_SetLvl, prDefDevice_InsUpd
--	2.03
--		2011-Apr-06		+ tbEventA1, prEventA1_Ins, tbEventA2, prEventA2_Ins, tbEventA3, prEventA3_Ins (not in use)
--						.tiCArea* -> .tiPriCA*, + .tiSecCA*
--		2011-Apr-07		+ tbEventA7, prEventA7_Ins, tbEventA9, prEventA9_Ins, tbEventAB, prEventAB_Ins
--						tbEvent8A.idSrcDvc -> .idDstDvc (prEvent8A_Ins, vwEvent8A)
--						+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A)
--						prDefDevice_InsUpd: RID ignored
--						prDefCall_InsUpd:
--		2011-Apr-11		[+ prDefCall_GetIns? - left out for now]
--						+ xtDefCall_sCall(sCall, bActive), xpDefCall(idCall), - xuDefCall(sCall)
--		2011-Apr-12		+ prDefDevice_GetRooms
--		2011-Apr-14		+ tbEventC.tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--		2011-Apr-15		prEvent8A_Ins: fix for non-med EventC insertions, changed Event.idType if no origin
--		2011-Apr-20		+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--						+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	3.01
--		2011-Apr-21		move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--						- tbEvent84.cBed, cBed -> tiBed (84, 8A, 95)
--		2011-Apr-22		tbDefDevice: xpDefDevice now clustered, + xuDefDevice_GJ
--		2011-May-02		tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--		2011-May-03		prRptSess_Ins, + tbRptSess.dtLastAct, + xuRptSess, + prRptSess_Act
--		2011-May-04		prDefCall_InsUpd: fix for tiFlags & 0x02 (enabled)
--	4.01
--		2011-May-11		- tbEvent91, prEvent91_Ins (commented)
--						+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--						fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--						.tiSecCA* -> .tiAltCA*, .tiPriCA* -> .tiCvrgA*, siDArea* -> siDutyA*, siZArea* -> siZoneA*
--						fix (tiBed > 9): prEvent84_Ins, 8A, 95
--						consolidated A7(A5-A7), A9(A8,A9,AA,AC) in tbEventAB
--						+ tbEventB1 (prEventB1_Ins)
--						vwEvent98
--		2011-May-20		prRptSess_Del: added app-clean-up, prRptSess_Ins: fix for mutliple rows with same SessID
--	4.02
--		2011-May-24		+ tbEventA.dtExpires
--						prEvent84_Ins: + @iAID, @tiStype; modified origination and added expiration
--		2011-May-25		+ tbRptSess.sMachine, .tiLocal (prRptSess_Ins)
--						prRptSess_Act: + @sSessID for session recovery
--	5.01
--		2011-Jun-02		+ tbEventP, + tbEvent.idParent, + .tParent
--						prEvent_Ins: now records parent ref
--						prEvent84_Ins: code optimization, parent events
--						prEvent8A_Ins: parent events
--		2011-Jun-07		+ prEventA_Exp
--						+ tbEventT, vwEventT
--		2011-Jun-09		prEvent95_Ins: fix for idDstDvc
--						+ prRptSessCall_Set
--		2011-Jun-13		+ tbEvent41, prEvent41_Ins
--						all views and sprocs are now 'with encryption'
--						prDefDevice_GetIns: + @iAID, @tiStype
--		2011-Jun-14		prRptSess_Act: fix for @idRptSess retrieval
--		2011-Jun-15		tb_Version.idVersion: smallint -> real to accomodate revision
--						.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--						.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--		2011-Jun-16		+ tbEventAB.tiNtWant (prEventAB_Ins)
--						+ tbDefStaff, prDefStaff_GetInsUpd
--						+ tbEventB4, prEventB4_Ins, vwEventB4
--						+ tbEventB7, prEventB7_Ins, vwEventB7
--		2011-Jun-17		tb_Version.pkVersion -> xp_Version
--						- tbEvent98.tiFlags (now stored in .tMulti)	(prEvent98_Ins)
--		2011-Jun-22		prEvent_Ins: @tiBed set to 'null' when > 9
--						finalized
--	5.02
--		2011-Jul-21		tb_Version.idVersion:  real -> smallint (5.02 is now stored as 502)
--		2011-Aug-03		tbDefCmd.sCmd -> lowercase now (readability in reports)
--						tbDefType.sType adjusted for idType in [10,30,31,33,40,41,50]
--						integrated report sprocs:	prRptSysActDtl,
--							prRptCallStatSum, prRptCallStatDtl,
--							prRptCallActSum, prRptCallActDtl
--						+ prRptCallStatSumGraph
--		2011-Aug-04		.idLoc -> tbEvent.idUnit from tbEvent84,95,B7 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--		2011-Aug-22		finalized
--	6.00
--		2011-Aug-25		tbRptUser -> tb_User, .idRptUser -> .idUser, xpRptUser -> xp_User, xuRptUser -> xu_User
--						tbRptSess -> tb_Sess, .idRptSess -> .idSess, xpRptSess -> xp_Sess, xuRptSess -> xu_Sess
--						tbRptSessCall -> tb_SessCall, tbRptSessDvc -> tb_SessDvc, tbRptSessLoc -> tb_SessLoc
--						all: (pr_Sess_Ins, pr_Sess_Act, pr_SessCall_Set, pr_Sess_Del)
--						+ tb_Role, tb_UserRole, tb_Log
--						tbRptTempl -> tbReport
--		2011-Aug-26		tbRptFilter -> tbFilter: .idRptFilter -> .idFilter, .sRptFilter -> .sFilter, .sXmlFilter -> .xFilter, xuRptFilter -> xuFilter
--						tbDefType -> tbEvType (fkEvent_DefType -> fkEvent_EvType)
--						tbEvent? -> tbEvent_? (A, C, P, T)
--						tbDefDevice -> tbDevice (FKs)
--						- xuDefCmd, - xuEvType	- centrally managed tables, no enforcement necessary
--		2011-Sep-06		+ pr_Log_Ins, pr_User_Login, pr_User_Logout
--		2011-Sep-07		pr_Sess_Del now calls pr_User_Logout
--		2011-Sep-08		+ tb_Option, tb_OptionSys, tb_OptionUsr
--		2011-Sep-12		+ tbUnit, tbStaff, tbShift, tbStaffAssnDef, tbStaffAssn
--		2011-Sep-14		pr_User_Login: + @bAdmin out
--						pr_User_Logout: skips null @idUser
--						3 built-in user accounts are provided: 'sysadmin', 'admin' and 'user'
--						permission grants moved up to immediately follow their objects
--		2011-Sep-15		prRptSysActDtl: @tiDvcs -> @tiDvc
--						prRpt*: @tiLocs -> @tiDvc
--						finalized
--	6.01
--		2011-Sep-21		tb_Type: + [20,21]
--		2011-Oct-11		finalized
--	6.02
--		2011-Oct-13		set tb_User.iHash for built-in user accounts to match 'Password'
--		2011-Oct-18		* prStaffAssnDef_InsUpdDel: added logic for auto-finalization
--						+ prStaffAssnDef_Fin
--						+ tbStaffAssn.idStaffAssnDef, replaces <idRoom, tiBed, idShift, tiIdx, idStaff>
--						+ tbStaffAssnDef.iStamp - helps finding rows not covered by last sync with 7980
--						+ tbStaffAssnDef.idStaffAssn, fkStaffAssnDef_StaffAssn
--		2011-Oct-19		+ tbStaff.iStamp, tbUnit.iStamp, tbShift.iStamp
--						+ prStaffAssn_InsFin
--						* fast_forward for cursor: prDefCall_InsUpd, prDevice_GetRooms
--		2011-Oct-20		tb_Option: + <5, 56, iStamp>
--						tb_OptionSys: + <5, 0>
--						tb_Type: + <30, imported 7980 data>, <31, 7980 data import error>
--						tbDevice: + .bActive, + .dtCreated, .dtLastUpd -> .dtUpdated, tdDevice_dtLastUpd -> tdDevice_dtUpdated
--						* prDevice_InsUpd, prEvent84_Ins
--						tbDefBed: + .dtCreated, + .dtUpdated, .tiUse -> .bInUse
--						tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--		2011-Oct-21		tb_User: + .dtUpdated
--						tb_Role: + .dtUpdated
--						tb_UserRole: + .dtCreated
--						tdDefCallP: + .dtCreated
--						tdDefLoc: + .dtCreated
--		2011-Oct-24		tbFilter: + .dtCreated, .dtUpdated
--						tbReportRole: + .dtCreated
--						tb_OptionSys: + .dtUpdated
--						tb_OptionUsr: + .dtUpdated
--						* tbDevice: .tiRID is never NULL now - added download of all stations
--		2011-Oct-26		tbUnit: + .sUnit
--						tbShift.sShift: vc(24) -> vc(8), prShift_InsUpdDel
--						+ tb_SessStaff, tb_SessShift
--						+ vwStaff
--						tbReport, tbReportRole: + <7, ..>, <8, ..>
--						+ prRptStaffAssn
--		2011-Oct-27		+ prRptStaffCover
--		2011-Nov-03		pr_Log_Ins: + exec for [rWriter]
--		2011-Nov-04		prDevice_GetRooms: + bActive, dtCreated, dtUpdated to the output
--		2011-Nov-07		tbEvType: + [6,7], tbDefCmd: + [0]
--						* prEvent_Ins: logic change to allow idCmd=0 without touching tbEvent_P
--		2011-Nov-08		+ tbDevice.cSys, xuDevice_GJR -> xuDevice_SGJR
--						tb_Type: + [30-31,40-42]
--						prDevice_GetIns: + @cSys (+ tbDevice.cSys), order of @rgs (prEvent_Ins)
--						* prStaffAssnDef_InsUpdDel
--						* prShift_InsUpdDel
--		2011-Nov-10		pr_Sess_Del: + clean-up tb_SessStaff, tb_SessShift
--		2011-Nov-11		+ pr_Log_Get
--		2011-Nov-14		tb_Type: + [37-38]
--		2011-Nov-15		tb_Type: rearranged IDs
--						+ vwDevice
--		2011-Nov-30		re-ordered .bActive in tbDevice and tbStaff to end
--	6.03
--		2011-Dec-01		+ vwStaff.sStaff, redefined vwStaff
--		2011-Dec-07		tb_Type: + [71]
--		2011-Dec-13,27	tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--		2011-Dec-21		+ prRtlsRcvr_UpdDvc, prBadge_UpdLoc
--		2011-Dec-27		+ prEvent_Ins, prEvent84_Ins, prEvent8A_Ins, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl
--		2011-Dec-28		+ tbRtlsRoom.bNotify, vwRtlsRoom.bNotify (prRtlsRcvr_UpdDvc, prBadge_UpdLoc)
--		2011-Dec-29		+ prRtlsRcvr_InsUpd, prRtlsColl_InsUpd, prRtlsSnsr_InsUpd, prRtlsBadgeType_InsUpd, prRtlsBadge_InsUpd,
--						+ prRtlsRoom_OffOne, prBadge_ClrAll
--						* prEvent84_Ins: upon cancellation defer removal of tbEvent_A and tbEvent_P rows
--						* prEvent_Ins: added 0x97 to "flipped" (src-dst) commands
--		2012-Jan-09		tbRtlsRoom.dtUpdated -> datetime (from smalldatetime), need 1 sec accuracy
--						* prBadge_UpdLoc: get cSys,GID,JID,RID for current room when badge moved
--		2012-Jan-11		tb_Option: + [6], tb_OptionSys: + [6]
--						* prRptCallStatSum, prRptCallStatSumGraph: .idDevice -> .idRoom
--						+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--						* prEvent95_Ins: + @siPri (to pass in call-index from 0x95 cmd)
--		2012-Jan-12		tbEvent_A: + .bActive - upon 'cancel' a call is marked for deferred expiration (prEvent84_Ins)
--						+ xuEventA_SysGJRB
--		2012-Jan-16		+ tb_Module, pr_Module_Upd
--		2012-Jan-18		* prBadge_UpdLoc: fix setting iRetVal= 2 (SELECT doesn't have any effect when WHERE filters no rows)
--		2012-Jan-23		+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType),	re-"index"
--							(pr_Log_Ins, pr_User_Login, pr_User_Logout, prEvent_Ins, pr_Module_Upd,
--		2012-Jan-31			vwEvent, prRptSysActDtl, prDevice_InsUpd, prDevice_GetIns, prShift_InsUpdDel, prStaffAssnDef_InsUpdDel, pr_Sess_Del)
--						+ vwDevice.cSGJ
--						tbDefCallP: + .iForeColor, .iBackColor
--		2012-Feb-01		+ on delete cascade: fkEventA_Event, P, C, T, 84, 86, 8A, 8C, 95, 98, 99, 9B, AB, B1, B4, B7, 41
--		2012-Feb-02		+ vwEvent_A
--						vwDevice: + .sFnDevice
--		2012-Feb-06		* prDevice_GetRooms: grant exec to [rWriter]
--		2012-Feb-08		tb_Option: + [7], tb_OptionSys: + [7]
--						* prRptCallActDtl: fix for -- tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--		2012-Feb-15		prEvent_A_Exp: + inactive events removal
--		2012-Feb-16		* prEvent_Ins: + check for tiShelf,tiSpec before inserting to [tbEvent_T] - fixes 'presense' in RptCallActSum
--						* prEvent41_Ins: idType=50 -> idLogType=205
--		2012-Feb-16		finalized
--	6.04
--		2012-Mar-20		+ vwEvent.idRoom, sRoom
--		2012-Mar-19		+ tbEvent.idRoom
--		2012-Feb-20		+ tbUnitMap, tbUnitMapCell
--						+ prUnit_InsUpdDel
--		2012-Feb-22		* vwEvent_A: + .sDevice
--		2012-Feb-23		* prDevice_GetRooms: + .bSwing to the output; @idLoc -> @idUnit
--		2012-Feb-24		* vwDevice: + .sQnDevice; .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--		2012-Mar-05		+ tbRoomBed, vwRoomBed
--		2012-Mar-08		* vwRtlsRoom: + .idRn, .idCna, .idAide		min vs. max?
--						+ fnStaffAssnDef_GetByShift
--		2012-Mar-09		* vwEvent_A: + .tiBed
--		2012-Mar-14		(Feb-24) vwDevice -> * vwRtlsRcvr, vwRtlsBadge: .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--		2012-Mar-15		+ tbEvent_S (prEvent_Ins)
--						+ tbEvent.idRoom (prEvent_Ins)
--						* prEvent84_Ins: populating tbRoomBed
--		2012-Mar-16		+ prDevice_GetByUnit (based on prDevice_GetRooms), + @tiStype->@tiKind
--		2012-Mar-20		* vwEvent: + .idRoom, .sRoom, .cBed
--		2012-Mar-21		+ prEvent_Maint
--						* tbDevice: + .siBeds, .sBeds
--						* vwDevice: + .sQnDevice, .siBeds
--		2012-Mar-26		+ prDevice_UpdRoomBeds
--						* prDevice_InsUpd: + @idDevice out
--		2012-Mar-29		* optimize event selection range using tbEvent_S:
--							prRptSysActDtl, prRptCallStatSum, prRptCallStatSumGraph, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl
--		2012-Mar-30		+ tbRoomBed.tiIbed (vwRoomBed)
--		2012-Apr-02		* vwRoomBed: + .idRn, .idCna, .idAide
--						* tbEvent_A: + .idCall, .idRoom, .tiBed, .tiTmrStat, .tiTmrRn, .tiTmrAide
--						* vwEvent_A: + .cBed
--		2012-Apr-03		* prEvent_A_Exp: + removal from tbRoomBed
--						* prEvent84_Ins: + populating tbRoomBed, + new cache columns in tbEvent_A
--		2012-Apr-04		* xuEventA_SysGJRB to only include active calls -> xuEventA_Active_SGJRB
--						+ prRoomBed_GetDataByUnit
--		2012-Apr-09		* prEvent8A_Ins: @siPri -> @siIdx arg in call to prDefCall_GetIns
--						* tbDevice: + .idUnit
--						* prEvent_Ins: + populating tbDevice.idUnit
--						* vwDevice: + .sBeds, .idUnit
--						* prEvent84_Ins: + adjust tbEvent_A.dtEvent by @siElapsed - if call has started before
--		2012-Apr-10		* prEvent84_Ins: room-level calls will be marked for all room's beds in tbRoomBed
--						* prRptSysActDtl: optimize output to localize data manipulations to sproc
--						* tbDefPatient: + .bMale, .sInfo, .sNote, .bActive, .dtCreated, .dtUpdated
--							set xpPatient as clustered
--						* tb_Option[6], tb_LogType[1,189,190], tbDefCmd[0x00,0x98]
--		2012-Apr-11		* pr_Module_Upd: optimize tbEvent record with tb_Module.sVersion and .sDesc
--						tbDefPatient -> tbPatient (tbEvent84, prEvent84_Ins, vwEvent84, tbEvent98, prEvent98_Ins, vwEvent98, tbRoomBed, vwRoomBed, prRptCallActDtl)
--		2012-Apr-12		tbDefDoctor -> tbDoctor (tbEvent84, prEvent84_Ins, vwEvent84, tbEvent98, prEvent98_Ins, vwEvent98, tbRoomBed, vwRoomBed, prRptCallActDtl)
--						+ prRoomBed_GetDataByUnits
--		2012-Apr-16		* vwEvent_A: + .bAnswered
--		2012-Apr-17		+ prPatient_GetIns, prPatient_Upd, prDoctor_GetIns, prDoctor_Upd (prEvent84_Ins, prEvent98_Ins)
--						* prEvent_Ins: tbEvent.idRoom assignment for @tiStype = 26
--		2012-Apr-19		tb_LogType: + [44, 45]
--						- prDevice_GetRooms, tbDefStaff, prDefStaff_GetInsUpd, tbEventB4, prEventB4_Ins, vwEventB4, tbEventB7, prEventB7_Ins, vwEventB7
--		2012-Apr-20		* pr_Log_Get: + @tiLvl, @tiSrc
--						* prDevice_GetIns: replaces 7967-P workflow station's (0x1A) 'phantom' RIDs with parent device - workflow itself
--						tb_Module: + [8]
--		2012-Apr-23		* prPatient_GetIns, prDoctor_GetIns: added 'if @s is not null' to skip over empty attempts
--						* prEvent84_Ins: comment out prDefStaff_GetInsUpd call
--		2012-Apr-24		finalized - 6.04.4497
--		2012-May-02		fix: do not remove prDevice_GetRooms - 7983rh still uses it
--		2012-May-02		finalized - 6.04.4505
--	6.05
--		2012-Apr-27		tb_Log.sLog widened to [512] (pr_Log_Ins)
--		2012-May-02		- prDevice_GetRooms
--						* tb_LogType: .tiLevel, .tiSource bumped to allow bitwise combining for retrieval filters
--		2012-May-03		* pr_Log_Get: @tiLvl, @tiSrc take action now
--						tbReportRole -> tb_RoleReport
--						+ pr_Module_Set, + tb_LogType[61]
--		2012-May-04		+ prDefBed_InsUpd, + tb_LogType[71..74]
--						* prDevice_InsUpd, prDevice_GetIns: tracing reclassified 41,42 -> 74
--						* prDevice_GetByUnit: tracing
--						+ prDefBed_InsUpd, prDefCallP_DelAll, prDefCallP_Ins, prDefLoc_DelAll
--						+ prDefLoc_Ins, prDevice_UpdInactiveByGID, prRtlsRoom_Get
--		2012-May-09		+ tb_Option[8] (prDefBed_InsUpd, prDefCallP_DelAll, prDefCallP_Ins,
--							prDefLoc_DelAll, prDefLoc_Ins, prDefLoc_SetLvl,
--							prDevice_InsUpd, prDevice_GetIns, prDevice_UpdInactiveByGID)
--						+ (nolock): pr_User_Login, pr_User_Logout, prDefCall_InsUpd -> prDefCall_Imp,
--							prDevice_InsUpd, prDevice_GetIns, prDevice_GetByUnit, prPatient_GetIns, prDoctor_GetIns,
--							prDevice_UpdRoomBeds, prEvent_Maint, prEvent_Ins, prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins
--						* prPatient_Upd, prDoctor_Upd
--						+ tracing: prDefCall_Imp, prDefCall_GetIns, prPatient_Upd, prDoctor_Upd, prEvent_A_Exp
--						+ tb_Module[9]: 7981ds
--		2012-May-10		* optimize: prEvent98_Ins, prEvent99_Ins, prEvent9B_Ins, prEventAB_Ins, prEventB1_Ins, prEvent41_Ins
--						+ (nolock): fnStaffAssnDef_GetByShift, vwRoomBed, prRoomBed_GetDataByUnits, pr_SessCall_Set,
--							prRptSysActDtl, prRptCallStatSum, prRptCallStatSumGraph, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl, prRptStaffAssn, prRptStaffCover
--						+ prRpt_XltDtEvRng
--		2012-May-11		* pr_Module_Set, prDefCallP_DelAll, prDefLoc_DelAll, prDefLoc_SetLvl, prDevice_UpdInactiveByGID
--						* prDevice_UpdInactiveByGID -> prDevice_UpdActBySysGID, + @cSys
--						+ prEvent_A_DelBySysGID
--		2012-May-14		prEvent_A_DelBySysGID -> prEvent_SetGwState
--		2012-May-15		* prEvent84_Ins: + removal of healing events at once
--						+ tb_LogType[70,79]
--		2012-May-17		* tbEvent_A: + .bAudio (vwEvent_A, prEvent8A_Ins)
--		2012-May-18		+ extended expiration for picked calls (prEvent_Ins, prEvent84_Ins, prEvent8A_Ins)
--						* tb_Option[7] (sOption)
--						+ tb_Option[9,10] (tb_OptionSys)
--						* tb_LogType[1,231,236] (sLogType)
--						+ tb_LogType[80,81]
--		2012-Jun-01		* tb_LogType[221-230] (sLogType)
--						moved tbStaff (vwStaff, prStaff_InsUpdDel) before tbDoctor
--						+ tbRoomStaff, prRoomStaff_Upd (prDevice_UpdRoomBeds)
--						* tbStaff: + .sStaff
--		2012-Jun-04		+ prStaff_sStaff_Upd
--		2012-Jun-11		* vwEvent_A: + .idUnit, - .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide (no longer needed)
--						+ prMapCell_GetDataByUnitMap
--						* tbDevice: + .idEvent, .tiSvc (vwEvent, prEvent84_Ins, prMapCell_GetDataByUnitMap)
--		2012-Jun-22		* tb_Module: + [9,11,12,13]
--		2012-Jun-28		* prRoomBed_GetDataByUnits: + MV
--		2012-Jul-10		* prDevice_UpdActBySysGID: + 'and bActive=1'
--		2012-Jul-20		* vwEvent_A: + sd.tiStype, p.tiShelf, p.tiSpec
--						* prRoomBed_GetDataByUnits: + ea.tiShelf > 0
--		2012-Jul-23		* prRoomBed_GetDataByUnits: + LV: order by ea.bAnswered, WB: and ( ea.tiStype is null	or	ea.tiStype < 16 )
--		2012-Jul-30		* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--							(vwEvent_A, prEvent_A_Exp, prEvent_Ins, prEvent_SetGwState, prEvent84_Ins, 8A, 95)
--						* tbEvent_A: - .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide (no longer needed)
--						* tbShift: + .tiRouting, .tiNotify
--						* tbDefCall: + .tiRouting, .bOverride, .tResp0, .tResp1, .tResp2, .tResp3
--		2012-Jul-31		prDefLoc_SetLvl: + populating tbUnit, tbUnitMap, tbUnitMapCell
--		2012-Aug-06		* vwStaff: + tbStaff.sStaff (new), - .sFull
--							(fnStaffAssnDef_GetByShift, vwRtlsBadge, vwRtlsRoom, prRptStaffAssn, prRptStaffCover)
--							[prRoomBed_GetDataByUnits, prMapCell_GetDataByUnitMap]
--						* vwRtlsBadge, vwRtlsRoom: + (nolock)
--						* vwRoomBed (- extra joins)
--		2012-Aug-10		+ with (nolock): vwDevice, vwStaff, vwEvent, vwEvent_S, vwEvent_A, vwEvent_C, tbEvent_T
--						* tb_Module: + [14]
--						+ tbPhPgDvc
--		2012-Aug-15		* prEvent_A_Exp: reset tbDevice.idEvent (prEvent84_Ins)
--		2012-Aug-29		* prStaff_InsUpdDel: fixed tbStaff insertion (required .sStaff not supplied) and prStaff_sStaff_Upd call
--		2012-Aug-30		* prEvent41_Ins: replaced '@'
--		2012-Sep-10		+ tb_Version.siBuild
--	6.06
--		2012-Sep-19		finalized, 1st official release
--	6.07
--		2012-Oct-03		.4659
--		2012-Oct-10		.4666
--						+ vw_Log
--						* prDevice_InsUpd, prDevice_GetIns: - device matching by name
--						* prEvent_SetGwState: + isnull(sDevice,'?')
--						* prRoomBed_GetDataByUnits: #tbUnit's PK is only idUnit, output, MV source
--						* prMapCell_GetDataByUnitMap: output col-names
--						+ tbUnit.idShift, fkUnit_CurrShift
--						+ tbDevice.sCodeVer
--						+ tb_Module.tiAppType
--		2012-Oct-12		.4668
--						finalized
--	7.00
--		2012-Sep-24		+ tbStaffLvl (tbStaff.tiPtype -> .idStaffLvl, vwStaff, prStaff_InsUpdDel, fnStaffAssnDef_GetByShift), tbStaffUnit
--						+ tbStaffDvcType, tbStaffDvc, tbStaffDvcUnit, tbRtlsBadge.fkRtlsBadge_StaffDvc (* .idBadge: smallint -> int)
--		2012-Oct-01		* tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssnDef, prStaffAssn_Fin, prRptStaffCover)
--							.idStaffAssn -> .idStaffCover, xpStaffAssn -> xpStaffCover, fkStaffAssn_StaffAssnDef -> fkStaffCover_StaffAssn, fkStaffAssnDef_StaffAssn -> fkStaffAssn_StaffCover
--						* tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--							(prRoomBed_GetDataByUnits, prMapCell_GetDataByUnitMap)
--						* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--							tb_User: * .bEnabled -> .bActive, td_User_dtLastAct, td_User_dtCreated, td_User_dtUpdated, + td_User_Locked, td_User_Failed, + td_User_Active
--							td_Role: td_Role_dtCreated, td_Role_dtUpdated, + .bActive, + td_Role_Active
--							, td_UserRole_dtCreated
--							, td_OptionSys_dtUpdated, td_OptionUsr_dtUpdated
--							, tb_Sess_dtLastAct, tb_Sess_dtCreated
--							, tdDefBed_bInUse, tdDefBed_dtCreated, tdDefBed_dtUpdated
--							, tdDefCallP_dtCreated
--							, tdDefCall_bEnabled, tdDefCall_tiRouting, tdDefCall_bOverride, tdDefCall_bActive, tdDefCall_dtCreated, tdDefCall_dtUpdated
--							, tbDefLoc_dtCreated
--							, tdUnit_dtCreated, tdUnit_dtUpdated, + tdUnit_Active
--							, tdDevice_bActive, tdDevice_dtCreated, tdDevice_dtUpdated
--							, tdPatient_cGender, tdPatient_bActive, tdPatient_dtCreated, tdPatient_dtUpdated
--							, tdStaff_dtCreated, tdStaff_dtUpdated, + tdStaff_Active
--							, tdRoomStaff_dtUpdated
--							, tdDoctor_bActive, tdDoctor_dtCreated, tdDoctor_dtUpdated
--							, tdEventA_bAudio, tdEventA_bActive
--							, tdRoomBed_dtUpdated
--							, tdMstrAcct_dtCreated, tdMstrAcct_dtUpdated
--							, tdShift_tiRouting, tdShift_tiNotify, tdShift_dtCreated, tdShift_dtUpdated, + tdShift_Active
--							, tdRtlsRcvr_bActive, tdRtlsRcvr_dtCreated, tdRtlsRcvr_dtUpdated
--							, tdRtlsColl_bActive, tdRtlsColl_dtCreated, tdRtlsColl_dtUpdated
--							, tdRtlsSnsr_bActive, tdRtlsSnsr_dtCreated, tdRtlsSnsr_dtUpdated
--							, tdRtlsBadgeType_bActive, tdRtlsBadgeType_dtCreated, tdRtlsBadgeType_dtUpdated
--							, tdRtlsBadge_bActive, tdRtlsBadge_dtCreated, tdRtlsBadge_dtUpdated
--							, tdRtlsRoom_bNotify, tdRtlsRoom_dtUpdated
--							, td_RoleReport_dtCreated
--							, tdFilter_dtCreated, tdFilter_dtUpdated
--		2012-Oct-15		.4671
--							merged with 6.07
--		2012-Oct-17		.4673
--						* tbDevice.sCodeVer -> vc(16)
--						+ prEventC1_Ins
--		2012-Oct-18		.4674
--						* prDevice_GetByUnit
--						* tbDevice: + .sUnits (prDevice_InsUpd), fkDevice_Unit
--						+ vwDefLoc_CaUnit
--		2012-Oct-19		.4675
--						* prDevice_InsUpd: reset tdDevice.idEvent to null
--						* prDevice_UpdActBySysGID: trace
--						* prStaffCover_InsFin: set tbUnit.idShift
--		2012-Oct-22		.4678
--						* vwDevice: + .sUnits
--						* tbRtlsRoom: tiPtype -> .idStaffLvl
--		2012-Oct-23		.4679
--						* vwRtlsRoom: tiPtype -> .idStaffLvl
--		2012-Oct-24		.4680
--						* prDevice_GetByUnit: @idUnit -> @sUnits, output: .bSwing -> tiSwing
--						* prRoomBed_GetDataByUnits -> prRoomBed_GetByUnit
--						* prMapCell_GetDataByUnitMap -> prMapCell_GetByUnitMap
--		2012-Oct-25		.4681
--						* tbRoomBed: + 'on delete set null' to fkRoomBed_Event
--							+ .idAsnRn, .idAsnCn, .idAsnAi, .idRegRn, .idRegCn, .idRegAi (vwRoomBed)
--						* prBadge_UpdLoc: .tiPtype -> .idStaffLvl
--						+ fnEventA_GetTopByRoom
--		2012-Oct-26		.4682
--						+ fnEventA_GetTopByUnit
--						+ fnUnitMapCell_GetMap
--		2012-Oct-29		.4685
--						* tb_Module.bService -> .bLicense (pr_Module_Set)
--		2012-Oct-31		.4687
--						* tb_Module: + .dtLastAct
--						* tb_User: - td_User_LastAct
--						+ pr_Module_Act (pr_Sess_Act)
--		2012-Nov-02		.4689
--						* tb_LogType:	+ [62], * [61].tiSource: 2 -> 1
--						* pr_Module_Set -> pr_Module_Reg
--		2012-Nov-06		.4693
--						* tbStaffCover: .dtBeg,.dtEnd: datetime -> smalldatetime (no need for ms precision)
--						* prStaffCover_InsFin: + updating assinged staff in tbRoomBed
--		2012-Nov-12		.4699
--						* pr_Module_Reg: + @tiModType
--		2012-Nov-14		.4701
--						* prMapCell_GetByUnitMap: ea.idRoom, ea.sRoom -> r.idDevice [idRoom], r.sDevice [sRoom]
--		2012-Nov-15		.4702
--						* tb_Module:	+ [63]
--		2012-Nov-19		.4706
--		2012-Nov-20		.4707
--						* tbDevice.cDevice -> NOT null, + tdDevice_Code
--		2012-Nov-28		.4715
--						* prDefLoc_Ins: format idLoc as '000'
--						* prDevice_UpdActBySysGID: format @tiGID as '000'
--						+ prDevice_GetByID
--						* prDevice_UpdRoomBeds, + prDevice_UpdRoomBeds7980 - ver-independent <7980\_config.sql>
--		2012-Nov-30		.4717
--						* fnEventA_GetTopByUnit, fnEventA_GetTopByRoom: + tbEvent_A.bActive >0
--						* prStaffAssn_InsUpdDel: + tbDevice.bActive >0
--						+ vwStaffAssn, vwStaffCover
--		2012-Dec-03		.4720
--						* prDevice_InsUpd: preset .idUnit for new rooms
--		2012-Dec-04		.4721
--						* tbDefBed.bInUse is set only if it was 'false' before (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--		2012-Dec-05		.4722
--						* prDevice_UpdRoomBeds7980: ins/upd
--						* prDevice_UpdRoomBeds: @tiBed -> @cBedIdx
--		2012-Dec-07		.4724
--						finalized
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
--						+ tb_User[4]:	'appuser'
--						+ [rWriter]:	grant	exec	on pr_User_Login, pr_User_Logout, pr_Sess_Ins, pr_Sess_Act
--						+ [rWriter]:	grant	sel, ins, upd, del	on tb_Sess
--						* tbStaffLvl: .iColorF -> .iColorB
--						finalized
--	7.02
--		2013-Jan-08		.4756
--						* tbRtlsRoom.idBadge: not null -> null
--						* prDevice_UpdRoomBeds: initialize tbRtlsRoom
--		2013-Jan-09		.4757
--						* prEvent84_Ins: present staff recorded to tbRoomStaff (via prRoomStaff_Upd), ignore bed-idx for presence calls
--						* vwRoomBed: registered staff now comes from tbRoomStaff (not from tbRoomBed)
--		2013-Jan-10		.4758
--						* prEvent_A_Exp: try addressing (DELETE conflicted with ref constraint "fkEventC_Event_Aide")
--		2013-Jan-11		.4759
--						* prEvent84_Ins: @tiTmrXxxx -> @tiTmrXx
--		2013-Jan-14		.4762
--						* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom (vwDevice, prDevice_UpdRoomBeds, prMapCell_GetByUnitMap)
--						* fkRoom_Cn -> fkRoom_Cna, fkRoom_Ai -> fkRoom_Aide
--						* tbRoomStaff -> tbRoom (prRoomStaff_Upd -> prRoom_Upd, prStaffCover_InsFin)
--						* tbRoomBed.idDoctor moved to tbPatient (prPatient_GetIns)
--						- fkEvent_Device_Room, + fkEvent_Room
--						* tbEvent.tElapsed -> .tOrigin (vwEvent, prEvent8A_Ins, prEvent95_Ins, prRptSysActDtl, prRptCallActDtl)
--							fkEvent_Device_Src -> fkEvent_DvcSrc, fkEvent_Device_Dst -> fkEvent_DvcDst
--						- fkEventA_Device_Room, + fkEventA_Room
--							- tbEvent_A.tiTmr* (no need anymore, .tiSvc satisfies) (vwEvent_A)
--						+ fkEventC_Unit
--							- fkEventC_Device, + fkEventC_Room
--							* tbEvent_C.idCna -> .idCn, .idAide -> .idAi (vwEvent_C, prRptCallStatSum, prRptCallActSum)
--						+ fkEventT_Unit
--							- fkEventT_Device, + fkEventT_Room
--							* tbEvent_T.idCna -> .idCn, .idAide -> .idAi (vwEvent_T)
--						- tbRoomBed.idDoctor (moved into tbPatient) (vwRoomBed)
--							- .idReg* (no need anymore, tbRoom satisfies)
--							- fkRoomBed_Device, + fkRoomBed_Room
--						* vwRoomBed: registered staff now comes from tbRoom (not from tbRoomBed)
--						* prEvent_A_Exp
--						* prEvent_Ins
--						* tbEvent84.tiCvrgA* -> .tiCvrg*, siDutyA* -> siDuty*, siZoneA* -> siZone* (vwEvent84)
--							.tiTmrStat -> .tiTmrSt, .tiTmrCna -> .tiTmrCn, .tiTmrAide -> .tiTmrAi
--						* prEvent84_Ins
--						* vwEvent95: outputs
--						* tbEventAB.tiCvrgAX -> tiCvrgX (prEventAB_Ins)
--						prUnit_InsUpdDel, prDefLoc_SetLvl
--						- fkStaffAssn_Device, + fkStaffAssn_Room
--						- fkRtlsRoom_Device, + fkRtlsRoom_Room
--		2013-Jan-22		.4770
--						+ tbSchedule
--		2013-Jan-23		.4771
--						* prDevice_GetByID, * prDevice_GetByUnit (tbDevice.sBeds moved to tbRoom)
--		2013-Jan-28		.4776
--						* prRtlsBadge_InsUpd: inserting into tbStaffDvc (requires 'alter' permission)
--		2013-Jan-29		.4777
--						* tbDefCmd: [BA-C1]
--						* tbDefCall: .bEnabled <-> .bActive (meaning)
--						* prBadge_UpdLoc: @idBadge: smallint -> int
--						- tbRtlsBadge.idStaff (no need now, tbStaffDvc.idStaff keeps relationship) (vwRtlsBadge, vwRtlsRoom)
--						* tb_LogType: [80,81].tiSource: 32 -> 16
--		2013-Jan-30		.4778
--						+ tb_LogType: [75]	(prDevice_UpdRoomBeds)
--						* prBadge_UpdLoc: commented out tracing non-existing badges - too much output
--		2013-Jan-31		.4779
--						* vwDevice: '(#.sDial)' instead of '(.sDial)'
--		2013-Feb-13		.4792
--						* prDevice_InsUpd
--						* prPatient_GetIns: fixed "Conversion failed when converting the varchar value '?' to data type int."
--	7.03
--		2013-Feb-15		.4794
--						+ prFilter_Get, prFilter_InsUpd, prFilter_Del
--						+ prSchedule_Get, prSchedule_InsUpd, prSchedule_Upd, prSchedule_Del
--						* tb_Option, tb_OptionSys: + [12,13,14]	* [5-10]
--						+ tdSchedule_Result
--		2013-Feb-18		.4797
--						+ pr_Sess_Clr (pr_Sess_Del)
--		2013-Feb-19		.4798
--						* tb_Option, tb_OptionSys: + [15]
--						+ prSchedule_GetToRun
--		2013-Feb-21		.4800
--						+ prDefBed_GetAll, prDefLoc_GetAll, prUnit_GetAll, prDevice_GetAll, prShift_GetAll
--		2013-Feb-24		.4803
--						+ fix for prEvent_Ins (v.7.02)
--		2013-Feb-25		.4804
--						* prRoomBed_GetByUnit, fnEventA_GetTopByUnit
--		2013-Mar-12		.4819
--						* tb_Option, tb_OptionSys: + [16]
--		2013-Mar-13		.4820
--						* tb_LogType: + [34,35,90]
--						+ pr_OptionSys_GetSmtp
--						* tbSchedule.iResult: smallint -> int
--		2013-Mar-15		.4822
--						+ prReport_GetAll, prFilter_GetByUser
--						+ pr_SessCall_Ins, pr_SessLoc_Ins, pr_SessDvc_Ins, pr_SessStaff_Ins, pr_SessShift_Ins
--		2013-Mar-20		.4827
--						* prDevice_GetIns
--						* tb_Option, tb_OptionSys: + [17]
--						* prEvent_Ins
--		2013-Mar-21		.4828
--						* prDevice_UpdRoomBeds
--		2013-Mar-26		.4833
--						* pr_Sess_Del: + @bLog= 1
--						* pr_Sess_Act, pr_Module_Upd
--		2013-Mar-27		.4834
--						* prPatient_GetIns, prEvent84_Ins, prEvent98_Ins
--		2013-Mar-28		.4835
--						* pr_User_Login, pr_User_Logout
--						* prEvent_Maint
--						* tb_LogType: [231,236]
--		2013-Mar-29		.4836
--						http://stackoverflow.com/questions/15693359/tvf-output-is-missing-computed-column-from-view-it-references
--						* fnEventA_GetTopByUnit, fnEventA_GetTopByRoom: expanded * -> list of all vwEvent_A columns
--		2013-Apr-02		.4840
--						* tb_Module: + [20]
--		2013-Apr-05		.4843
--						+ tbCfgFlt, prCfgFlt_DelAll, prCfgFlt_Ins, prCfgFlt_GetAll
--						+ tbDefCallP.iFilter (prDefCallP_Ins)
--		2013-Apr-08		.4846
--						+ tbCfgFlt.idIdx - PK [bitmask 0x80000000 becomes -2147483648] (prCfgFlt_Ins, prCfgFlt_GetAll)
--		2013-Apr-09		.4847
--						* vwEvent_A, fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit
--		2013-Apr-09		.4848
--						* prMapCell_GetByUnitMap
--		2013-Apr-15		.4853
--						* prDevice_UpdRoomBeds7980: fix for room renames
--		2012-Apr-16		.4854
--						* prDevice_UpdRoomBeds: fix for room renames
--		2012-Apr-19		.4857
--						+ tbCfgMst, prCfgMst_Clr, prCfgMst_Ins
--						* tbRoom: explicit PK name - xpRoom!
--						* tbEvent_A: + .tiCvrg[0..7] (vwEvent_A, prEvent84_Ins, fnEventA_GetTopByUnit, fnEventA_GetTopByRoom)
--						* vwDefLoc_CaUnit -> vwDefLoc_Cvrg, .idCArea -> .idCvrg, .sCArea -> .sCvrg
--		2012-Apr-22		.4860
--						+ fnEventA_GetByMaster (fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit, prMapCell_GetByUnitMap)
--		2012-Apr-24		.4862
--						+ vwRoom
--						+ prCfgDvc_Init
--		2012-Apr-25		.4863
--						* prRoom_Upd: + @idUnit (prEvent84_Ins)
--		2012-Apr-26		.4864
--						* fnEventA_GetByMaster fix
--		2012-Apr-29		.4867
--						* tbStaff: + .bOnDuty (vwStaff)
--		2012-Apr-30		.4868
--						* fnEventA_GetByMaster: fix @idMaster
--		2013-May-07		.4875
--						+ tbCfgDvcBtn, prCfgDvcBtn_Clr, prCfgDvcBtn_Ins
--		2013-May-09		.4877
--						* tbUnitMapCell: + .tiRID1, tiBtn1, .tiRID2, .tiBtn2, .tiRID4, .tiBtn4
--						* prPatient_GetIns (prEvent84_Ins, prEvent98_Ins)
--						+ prRoomBed_UpdPat
--		2013-May-10		.4878
--						* vwRoom -> vwRoomAct
--						* tbDoctor (prDoctor_GetIns, prDoctor_Upd), tbPatient (prPatient_GetIns, prPatient_Upd) moved after tbRoomBed
--							tbRoomBed.idPatient -> tbPatient.idRoom + .tiBed (+ tbPatient.fkPatient_RoomBed)
--						* tbStaffAssn: fkStaffAssn_Room -> fkStaffAssn_RoomBed
--						* prRoomBed_UpdPat -> prPatient_UpdLoc
--		2013-May-15		.4883
--						* pr_Sess_Del: fix pr_User_Logout call (was not passing @idSess)
--						- fkStaffAssn_StaffCover: no longer supported - causes trouble for deletes!
--		2013-May-22		.4890
--						* prStaff_GetAll (order by)
--						+ prRoom_GetAct, prRtlsRcvr_GetAll, prRtlsSnsr_GetAll, prRtlsBadge_GetAll, prStaffDvc_UpdStf
--						* prRtlsRcvr_UpdDvc
--						* tbStaffDvc:	ID seed -> 16777215
--		2013-May-23		.4891
--						* vwRoomAct: + .cDevice
--						+ prUnitMap_GetAll, prUnitMap_Upd, prMapCell_GetByUnit
--						* tbUnitMapCell: + .idRoom, -.bSwing
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
--							(vwStaffAssn -> vwStfAssn, prStaffAssn_Fin -> prStfAssn_Fin, prStaffAssn_InsUpdDel -> prStfAssn_InsUpdDel, fnStaffAssn_GetByShift -> fnStfAssn_GetByShift,
--							prRptStaffAssn, prRptStaffCover)
--						* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--							(vwStaffCover -> vwStfCvrg, prStaffCover_InsFin -> prStfCvrg_InsFin, prRptStaffCover)
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
--						* tbStfDvc:		.bTechno -> .bTech (tdStfDvc_Techno -> tdStfDvc_Tech), - .tiLines, - .tiChars
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
--						* tbUnit:	- .iStamp
--		2013-Aug-08		.4968
--						* prRtlsBadge_InsUpd:	exec as owner
--						* tb_OptSys[9,10] := 30
--						* prEvent_Ins
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
--	7.05
--		2013-Aug-16		.4975
--						* tb_LogType:	.tiLevel -> .tiLvl, tiSource -> tiSrc	(pr_Log_Get)
--		2013-Aug-16		.4976
--						* tb_User:		- .bLocked, td_User_Fails -> td_User_Failed
--							.sFirst -> .sFrst, .sMid -> .sMidd (prUser_Exp, prUser_Imp, pr_User_Login, vwStaff)
--						* tb_OptSys[10]:= 60
--						* tbCfgBed:		.bInUse -> .bActive, tdCfgBed_InUse -> tdCfgBed_Active	(prEvent_Ins, prDevice_UpdRoomBeds)
--						* prCfgBed_GetAll:	+ @bActive
--						* tbCall:		xuCall_Active_sCall, xuCall_Active_siIdx: depend on .bActive (not .bEnabled)
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
--		2013-Oct-10		.5031
--						+ pr_UserRole_InsDel, prTeamPri_InsUpd
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
--		2014-Feb-17		.5161
--						* prRoom_LstAct, prStaff_LstAct
--		2014-Feb-21		.5165
--						* tb_Module[61] ->	'7980/79 Notification Service'
--						* tb_User:	+ .dtDue, tvUser_Duty	(dbo.Staff)
--						* prStfAssn_InsUpdDel, prStfAssn_Fin, prStfCvrg_InsFin
--						+ pr_User_SetBreak
--		2014-Feb-25		.5169
--						* tbReport [7],[8]	.sClass
--						* tdUser_OnDuty -> td_User_OnDuty, tvUser_Name -> tv_User_Name, tvUser_Duty -> tv_User_Duty
--						+ tb_Option[19], tb_OptSys[19]
--						* prEvent_Maint:	wipe tbEvent.vbCmd for events older than 60 days
--		2014-Feb-27		.5171
--						* pr_User_SetBreak -> prStaff_SetDuty
--						* vwStaff:	+ .dtDue
--		2014-Feb-28		.5172
--						* prStaff_SetDuty
--						+ prShift_InsUpd
--		2014-Mar-04		.5176
--						+ tb_Module[64]
--						+ prTeam_GetByUnit, prDvc_GetByUnit
--						* prStfCvrg_InsFin
--		2014-Mar-07		.5179
--						+ prCfgPri_SetTmpFlt
--						* prUnit_SetTmpFlt
--						* tbTeam:	+ .sUnits, .sCalls	(prTeam_InsUpd, prTeam_GetByUnit, dbo.Team)
--		2014-Mar-10		.5182
--						* pr_User_InsUpd, prDvc_InsUpd:	@sUnits >> tb???Unit (via prUnit_SetTmpFlt)
--		2014-Mar-12		.5184
--						+ prTeam_SetTmpFlt
--						* tbDvc:	+ .sTeams	(vwDvc, prDvc_InsUpd, prDvc_GetByUnit)
--		2014-Mar-13		.5185
--						+ prStaff_GetPageable, prStaff_GetByStfID, prRoomBed_GetAssn
--						- dbo.sp_GetStaffList
--						* tbUnitMap:	.sMap not null -> null
--		2014-Mar-14		.5186
--						* prDevice_GetIns
--						* prDvc_GetByUnit
--						* prDvc_InsUpd
--		2014-Mar-17		.5189
--						* prDvc_GetByUnit
--		2014-Mar-18		.5190
--						* pr_User_InsUpd
--		2014-Mar-19		.5191
--						* prTeam_GetByUnit
--						* prTeam_InsUpd
--		2014-Mar-20		.5192
--						* prRtlsBadge_RstLoc, prRtlsRoom_OffOne, vwRtlsRoom, prRtlsRoom_Get
--		2014-Mar-31		.5203
--						* tbEvent41:	.idUser -> null
--						* prRptCallActDtl:	+ filter conditions on main data source (vwEvent)
--		2014-Apr-01		.5204
--						+ tb_LogType[ 194 ]		(prEvent_A_Exp, prEvent84_Ins)
--		2014-Apr-02		.5205
--						* prEvent_Ins:	+ @idRoom out,	* @idUnit out,	arg order
--							(pr_Module_Upd, prEvent_SetGwState, prEvent84_Ins, prEvent86_Ins, prEvent8A_Ins, prEvent8C_Ins, prEvent95_Ins,
--							prEvent98_Ins, prEvent99_Ins, prEvent9B_Ins, prEventAB_Ins, prEventB1_Ins, prEvent41_Ins)
--						* @tiDstBtn -> @tiBtn	(prEvent8A_Ins, prEvent95_Ins, prEvent99_Ins)
--		2014-Apr-08		.5211
--						* prEvent_Ins
--		2014-Apr-09		.5212
--						* prEvent84_Ins
--						+ prRoom_GetByUnit
--						* prDevice_UpdRoomBeds
--						* vwEvent41
--		2014-Apr-14		.5218
--						+ tb_Option[20], tb_OptSys[20]:		Announce call cancellations?
--		2014-Apr-15		.5219
--						+ prStfLvl_Upd
--		2014-Apr-16		.5220
--						* tb_User.sTeams: vc(32) -> vc(255),	pr_User_InsUpd
--		2014-Apr-18		.5222
--						* prRtlsBadge_Init, prRtlsBadge_InsUpd
--		2014-Apr-22		.5226
--						+ prShift_Upd, vwShift
--		2014-Apr-23		.5227
--						* pr_User_Login, pr_User_Logout, pr_Sess_Del
--		2014-Apr-30		.5233
--						* pr_Role_InsUpd
--		2014-May-01		.5234
--						+ pr_Access_InsUpdDel, pr_Access_GetByRole, pr_Role_GetAll, pr_Role_GetUnits, pr_Role_GetPerms
--		2014-May-02		.5235
--						+ tb_Option[21-25], tb_OptSys[21-25]
--		2014-May-12		.5245
--		2014-May-13		.5246
--						* pr_User_Logout, pr_Sess_Del
--						* prStaff_GetByUnit
--		2014-May-15		.5248
--						+ pr_Access_GetByUser
--						* prStfAssn_Imp
--		2014-May-20		.5253
--						+ prUnit_GetByUser
--		2014-May-21		.5254
--						* tb_Role[1,2].sDesc
--						* pr_User_InsUpd
--		2014-May-22		.5255
--						* tbUnit.idShift null -> not null
--		2014-May-27		.5260
--						* prCfgLoc_SetLvl
--		2014-Jun-03		.5267
--						* prEvent_Ins, prEvent84_Ins
--		2014-Jun-04		.5268
--					--	* prCall_GetIns
--		2014-Jun-10		.5274
--						* prEvent84_Ins
--		2014-Jun-11		.5275
--						* prShift_GetByUnit
--		2014-Jun-19		.5283
--						* vwEvent_A		(fnEventA_GetTopByUnit, fnEventA_GetTopByRoom)
--		2014-Jun-26		.5290
--						--	+ tb_LogType[208]
--						* prEvent8A_Ins, prEvent95_Ins
--		2014-Jul-03		.5297
--						* prRptCallStatSum, prRptCallStatSumGraph
--		2014-Jul-08		.5302
--						* prRptCallActSum
--		2014-Jul-10		.5304
--						* prRptCallActDtl, prRptSysActDtl
--		2014-Jul-14		.5308
--						* prRtlsBadge_InsUpd
--	7.06
--		2014-Jul-15		.5309
--						- tb_Feature[idModule=92]:	no sync with 7983 yet
--		2014-Aug-01		.5326
--						+ tbEvent_C.idAssn1|2|3		(prEvent84_Ins, vwEvent_C)
--		2014-Aug-04		.5329
--						+ tbReport[9], re-order .siOrder
--						+ prRptCallActExc
--		2014-Aug-05		.5330
--						+ prRptCallActExc
--						* prRptCallActSum
--						+ tbCfgBed.siBed	(tbEvent_C, vwEvent_C, prEvent84_Ins)
--		2014-Aug-06		.5331
--						* prRptCallActSum, prRptCallActDtl, prRptCallActExc
--		2014-Aug-07		.5332
--						* prStfAssn_Imp
--		2014-Aug-08		.5333
--						* tbDvcType[3] -> [4] (phone) for bitwise filters, etc.	(prStaff_GetByUnit)
--						* tb_LogType[43,45]
--						* vwRoomBed:	+ .cDevice	(prStfAssn_GetByUnit:	+ vwRoomBed.cRoom)
--						* prStaff_GetPageable
--		2014-Aug-11		.5336
--						* prDvc_GetByUnit:	@idDvcType is bitwise now
--		2014-Aug-12		.5337
--						* prRoomBed_GetByUnit, prMapCell_GetByUnitMap
--						* prRoomBed_GetAssn:	return staff assigned to bed A for room-level calls
--		2014-Aug-15		.5340
--						* prRoomBed_GetByUnit
--		2014-Aug-19		.5344
--						* tb_LogType[43,45]
--		2014-Aug-22		.5347
--						+ prTeam_GetByUnitPri, prTeam_GetStaffOnDuty, pr_User_GetBySID, pr_User_GetDvcs, prTeam_GetDvcs
--		2014-Aug-26		.5351
--						+ tbPcsType[0x0C..0x0E]
--		2014-Aug-27		.5352
--						+ prEvent_A_Get
--						* prCfgDvc_Init
--		2014-Aug-28		.5353
--						* vwRoomBed
--		2014-Aug-29		.5354
--						+ prRole_SetTmpFlt
--						* prCfgBed_InsUpd
--						* prRtlsRcvr_GetAll
--						* prRtlsBadge_GetAll
--		2014-Sep-15		.5371
--						* vwRoomBed, prStfAssn_GetByUnit
--						* tbPcsType[0x02..0x07,0x0A,0x0B]
--		2014-Sep-16		.5372
--						* removed 7980 objects
--						* prRptCallActExc
--		2014-Sep-17		.5373
--						* prCall_GetAll
--						* prRptCallStatSum
--		2014-Sep-23		.5379
--						* tb_Version: xp_Version(idVersion) -> xp_Version(siBuild), + xu_Version
--		2014-Sep-24		.5380
--						* prRole_SetTmpFlt, prCfgPri_SetTmpFlt, prUnit_SetTmpFlt, prTeam_SetTmpFlt
--						* prCfgPri_SetTmpFlt -> prCall_SetTmpFlt	(prTeam_InsUpd)
--						* prEvent84_Ins, prPatient_UpdLoc
--		2014-Sep-29		.5385
--						* prUnit_GetByUser, prCfgLoc_GetByUser
--						+ pr_Role_Exp, pr_Role_Imp, pr_UserRole_Exp, pr_UserRole_Imp, pr_RoleUnit_Exp, pr_RoleUnit_Imp
--		2014-Sep-30		.5386
--						* vwEvent_A
--						* prStfAssn_Exp
--						* tbDefCmd:	+ [C6,DC-DF]
--		2014-Oct-01		.5387
--						* prRptStfAssn, prRptStfCvrg
--						+ prRptStfAssnStaff
--		2014-Oct-02		.5388
--						* prStaff_GetPageable
--						* prEvent_A_Get
--		2014-Oct-09		.5395
--						+ pr_Module_GetAll
--						* pr_Module_Upd
--						* prRptCallActExc, prRptCallStatSum, prRptCallStatSumGraph
--		2014-Oct-10		.5396
--						* prEvent41_Ins
--		2014-Oct-13		.5399
--						* vw_Log
--						+ vw_OptSys, vw_OptUsr, vw_Sess, pr_Sess_GetAll
--						* pr_User_GetByUnit
--		2014-Oct-14		.5400
--						+ prStfLvl_GetAll
--						* prUnit_GetByUser
--		2014-Oct-15		.5401
--						* merged prUnit_GetByUser -> prUnit_GetAll
--						* merged prShift_GetByUnit -> prShift_GetAll
--		2014-Oct-22		.5408
--						- tbShift.tiRouting	(vwShift, prShift_Exp, prShift_Imp, prShift_Upd, prShift_InsUpd)
--						- prShift_Upd
--						* prRptCallStatSum, prRptCallStatSumGraph, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl, prRptCallActExc
--		2014-Oct-23		.5409
--						* prRpt_XltDtEvRng, prRptSysActDtl
--						* prRptCallStatSum, prRptCallStatSumGraph, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl, prRptCallActExc
--						* prRptStfAssn, prRptStfCvrg
--						* prCfgBed_GetAll, prCfgBed_InsUpd
--		2014-Oct-24		.5410
--						* vwEvent_A, prEvent_A_GetAll
--		2014-Oct-28		.5414
--						+ prCfgDvc_GetAll, - prDevice_GetAll
--						* prCfgLoc_GetByUser
--						* prDevice_InsUpd
--		2014-Oct-29		.5415
--						* pr_User_InsUpd
--						* prShift_InsUpd
--						* tb_LogType[247].tiLvl=	4->8
--		2014-Oct-31		.5417
--						* prUnitMap_GetAll -> prUnitMap_GetByUnit
--						+ pr_UserRole_GetByUser, pr_UserRole_GetByRole
--						+ pr_User_Get
--		2014-Nov-03		.5420
--						+ prStfAssn_GetByRoom
--						+ prTeamUser_Get
--		2014-Nov-05		.5422
--						* prRptSysActDtl
--		2014-Nov-06		.5423
--						* pr_Module_Upd
--		2014-Nov-07		.5424
--						- tvDvc_Dial, * prRtlsBadge_InsUpd
--		2014-Nov-11		.5428
--						+ xu_User_Act_BarCode, xuDvc_Act_BarCode
--						* xu_User_Active_StaffID -> xu_User_Act_StaffID
--						+ prStaff_GetByBC, prDvc_GetByBC
--						* prStaff_GetByStfID -> prStaff_GetBySID
--		2014-Nov-12		.5429
--						* vwShift, prShift_GetAll,	vwStfAssn, vwStfCvrg, prStfAssn_GetByRoom, prStfAssn_GetByUnit,	prTeam_GetStaffOnDuty,	prStaff_GetByUnit
--						* prStaff_GetPageable,	prStaff_GetBySID
--		2014-Nov-13		.5430
--						* pr_User_Get -> prStaff_Get
--						- pr_User_GetBySID, pr_User_GetByBC
--		2014-Nov-19		.5436
--						+ prStaff_GetAssn
--		2014-Nov-20		.5437
--						* vwDvc, prDvc_GetByUnit
--						+ prDvc_GetByDial
--		2014-Nov-25		.5442
--						* pr_User_GetDvcs
--		2014-Dec-10		.5457
--						* tbDvc.sDial: null -> not null,	- xuDvc_TypeDial,	+ xuDvc_Type_Dial
--						* prDvc_InsUpd
--		2014-Dec-17		.5464
--						* prEvent41_Ins
--		2014-Dec-18		.5465
--						* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--							(vwRoom, vwDevice, prRoom_Upd -> prRoom_UpdStaff, vwRoomBed, prEvent84_Ins, prRtlsBadge_RstLoc, prCfgDvc_Init, prRoomBed_GetByUnit)
--						* tbEvent84:	.tiTmrSt -> .tiTmrA, .tiTmrRn -> .tiTmrG, .tiTmrCn -> .tiTmrO, .tiTmrAi -> .tiTmrY
--							(prEvent84_Ins, vwEvent84)
--		2014-Dec-19		.5466
--						+ tb_Option[26]
--						* prDevice_InsUpd, prDevice_GetIns
--						* prEvent_Ins
--		2015-Jan-05		.5483
--						* prEvent84_Ins
--						* prRtlsRoom_Get, prRoomBed_GetByUnit, prMapCell_GetByUnitMap, prRoomBed_GetAssn
--						* prDevice_UpdRoomBeds
--						+ vwCall
--						* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3,	- .idUser
--						* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--							(vwEvent_C, vwRoomBed, prEvent84_Ins, prStfAssn_Fin, prStfCvrg_InsFin, prRoomBed_GetByUnit, prMapCell_GetByUnitMap, prRoomBed_GetAssn)
--		2015-Jan-06		.5484
--						- fkUnitMapCell_Unit (fkUnitMapCell_UnitMap is transitive)
--						- tbEvent86, prEvent86_Ins, tbEvent8C, prEvent8C_Ins, tbEvent99, prEvent99_Ins, tbEvent9B, prEvent9B_Ins, tbEventAB, prEventAB_Ins, tbEventB1, prEventB1_Ins
--						- tbEvent98,	* prEvent98_Ins,	* prPatient_UpdLoc
--		2015-Jan-09		.5487
--						+ tbEvent.tiFlags,	- tbEvent95, -tbEvent8A,	- tbEvent41.tiSeqNum, .cStatus,		* prCall_GetIns
--							(vwEvent, prEvent_Ins, prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent98_Ins, prEvent41_Ins, vwEvent41)
--		2015-Jan-12		.5490
--						* prEvent95_Ins, prRptSysActDtl, prRptCallActDtl
--						* prEvent_Ins
--						* prEvent_Maint
--		2015-Jan-13		.5491
--						* vwEvent_C
--						* prRptSysActDtl, prRptCallActDtl
--						* tbPcsType:	[1,2,9,A,D,E]
--		2015-Jan-14		.5492
--						* prEvent_Ins, prEvent84_Ins
--		2015-Jan-16		.5494
--						* prRptStfAssn
--						* pr_User_InsUpd
--		2015-Jan-21		.5499
--						* prUnitMap_GetByUnit
--		2015-Jan-23		.5501
--						* tbCfgLoc:	+ .sPath	(prCfgLoc_GetAll, prCfgLoc_Ins, prCfgLoc_SetLvl)
--		2015-Jan-26		.5504
--						* prCfgLoc_GetAll
--		2015-Feb-04		.5513
--		2015-Feb-13		.5522
--		2015-Feb-17		.5526
--						+ tb_Option[27,28]
--		2015-Feb-18		.5527
--						* prRptCallStatDtl
--		2015-Feb-19		.5528
--						* prCall_GetIns
--						* prRoomBed_GetByUnit
--		2015-Feb-20		.5529
--						* vwEvent_A, prEvent84_Ins
--						* prCfgDvc_Init
--		2015-Feb-25		.5534
--						* prEvent84_Ins
--		2015-Feb-27		.5536
--						* finalized
--		2015-Mar-23		.5560
--						* tb_Module[61,62,64,111]
--						* prDevice_GetIns
--		2015-Mar-25		.5562
--						+ tbEvent_B, * tbEvent: .vbCmd -> tbEvent_B, .tiLen -> tbEvent_B
--							* prEvent_A_Exp, prEvent_Maint, prEvent_Ins
--		2015-Mar-26		.5563
--						* tbCall[0] INTERCOM -> NO CALL
--						- tbCall.xuCall_Active_sCall (prCall_Imp)
--						* prEvent_A_GetAll
--						+ tbStfLvl[8]
--						* pr_User_GetByUnit
--		2015-Mar-30		.5567
--						* pr_User_GetByUnit -> pr_User_GetAll (merge)
--						* pr_User_sStaff_Upd
--						+ prUnit_GetAll
--						* xu_User -> xu_User_Login--
--		2015-Mar-31		.5568
--						* pr_UserUnit_Set
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
--						release
--
--		2015-Jul-02		.5661
--						* tb_Feature[*]
--		2015-Jul-06		.5665
--						* tb_Option[8]
--						* prEvent84_Ins
--		2015-Jul-28		.5687
--						+ tbCfgTone		(+ prCfgTone_Clr, prCfgTone_GetAll, prCfgTone_Ins)
--						* tbCfgPri:		+ .siIdxUg, .siIdxOt, .tiOtInt, .tiLight, .tiTone, .tiToneInt
--							(prCfgPri_Ins, prCfgPri_GetAll)
--		2015-Aug-04		.5694
--						+ tbCfgTone.dtCreated	(prCfgTone_GetAll)
--						+ prSchedule_GetAll
--						* tb_OptSys[9] default: 30 -> 60, high-volume traffic scenario increases healing interval 1.5x on 790 side
--		2015-Aug-05		.5695
--						* prRoomBed_GetByUnit (vwEvent_A, fnEventA_GetTopByUnit, fnEventA_GetTopByRoom), prMapCell_GetByUnitMap
--		2015-Aug-11		.5701
--						* tb_LogType[39] tiLvl: 4 -> 8
--		2015-Aug-12		.5702
--						* prCfgTone_Clr
--		2015-Aug-18		.5708
--		2015-Aug-25		.5715
--		2015-Sep-16		.5737
--		2015-Oct-26		.5777
--						* pr_Module_GetAll
--		2015-Nov-03		.5785
--						* pr_User_GetAll
--						* pr_Module_GetAll
--		2015-Nov-06		.5788
--						* prRtlsBadge_UpdLoc
--		2015-Dec-31		.5843
--						* prDevice_InsUpd
--						* pr_Module_Upd
--		2016-Jan-11		.5854
--						tbUnitMapCell.fkUnitMapCell_UnitMap
--						* prCfgDvc_Init, prCfgLoc_SetLvl
--		2016-Jan-12		.5855
--						* prDevice_InsUpd
--						* prCfgDvc_GetAll
--		2016-Jan-13		.5856
--						* prMapCell_GetByUnitMap
--		2016-Jan-18		.5861
--						* prDevice_GetByUnit
--		2016-Jan-22		.5865
--						* prCall_Imp, prEvent84_Ins
--						* prCall_GetIns
--		2016-Jan-25		.5868
--						+ tb_Option[29,30], tb_OptSys[29,30], prCall_Imp, prCall_GetIns
--							- tdCall_tVoTrg, tdCall_tStTrg
--		2016-Jan-26		.5869
--						+ tb_Option[31-36], tb_OptSys[31-36]
--		2016-Feb-12		.5886
--						+ tbSchedule.tiFmt
--							(prSchedule_Get, prSchedule_GetToRun, prSchedule_GetAll, prSchedule_InsUpd)
--						* pr_OptSys_Upd
--		2016-Feb-16		.5890
--						* prCfgBed_InsUpd
--		2016-Feb-26		.5900
--						+ tb_Module[60,90]
--		2016-Mar-02		.5905
--						* prCfgMst_Clr, prCfgMst_Ins, prCfgDvcBtn_Clr, prCfgDvcBtn_Ins
--						+ tdDevice.bConfig
--		2016-Mar-03		.5906
--						* prCfgDvc_Init
--		2016-Mar-04		.5907
--						+ prCfgDvc_UpdAct
--						* prDevice_InsUpd
--		2016-Mar-07		.5910
--						- prCfgPri_Clr
--						* prCfgPri_Ins -> prCfgPri_InsUpd
--		2016-Mar-09		.5912
--						* tb_User:	+ .gGUID, .utSynched
--						* prCfgDvc_UpdAct
--		2016-Mar-10		.5913
--						* tb_Option[5].sOption
--						* pr_OptSys_Upd
--		2016-Mar-11		.5914
--						+ tb_LogType[76]
--						* prCfgFlt_Clr, prCfgFlt_Ins, prCfgTone_Clr, prCfgTone_Ins, prCfgLoc_Clr, prCfgLoc_Ins, prCfgMst_Clr, prCfgMst_Ins
--						* prCfgDvcBtn_Clr, prCfgDvcBtn_Ins
--						* tbCfgPri: .dtCreated -> .dtUpdated	(prCfgPri_GetAll)
--						* tbCfgLoc: .dtCreated -> .dtUpdated	(prCfgLoc_GetAll)
--						* prCfgDvc_Init
--		2016-Mar-21		.5924
--						+ tb_Option[37], tb_OptSys[37]
--		2016-Mar-23		.5926
--						* prEvent41_Ins
--		2016-Mar-28		.5931
--						* tb_Feature[62,00]
--		2016-Mar-31		.5934
--						+ tb_Option[38], tb_OptSys[38]
--						* prCfgLoc_SetLvl
--		2016-Apr-01		.5935
--						* prShift_Imp
--		2016-Apr-05		.5939
--						* pr_UserUnit_Set
--						- tbRoomBed.cBed	(prCfgBed_InsUpd, vwRoomBed, prDevice_UpdRoomBeds)
--		2016-Apr-06		.5940
--						* pr_User_Logout, pr_Sess_Del
--						* prPatient_UpdLoc, prStfAssn_Imp, prStfAssn_InsUpdDel, prCfgDvc_Init, prCfgDvc_UpdAct
--						* prMapCell_GetByUnitMap
--		2016-Apr-07		.5941
--		2016-Apr-20		.5954
--						+ tb_User.xu_User_GUID
--						* pr_User_GetAll
--		2016-Apr-21		.5955
--						* pr_User_InsUpd
--						+ pr_User_InsUpdAD
--		2016-Apr-26		.5960
--						* pr_User_GetAll, pr_User_InsUpdAD
--		2016-Apr-27		.5961
--						- pr_User_Exp, * pr_User_Imp
--						* pr_User_GetAll
--		2016-Apr-29		.5963
--						* pr_User_InsUpdAD
--						release
--
--		2016-May-05		.5969
--						+ pr_User_Login2, * pr_User_Login
--		2016-May-19		.5983
--						* pr_Role_Imp
--		2016-May-26		.5990
--						* vwRoom, vwDevice
--		2016-Jun-15		.6010
--						* prCall_Imp
--		2016-Jun-22		.6017
--						* tbEvent_C:	+ .idShift, .dShift		(prEvent84_Ins)
--						* prCfgLoc_SetLvl
--		2016-Jun-24		.6019
--						+ tb_User.bConfig	(pr_User_InsUpdAD)
--						+ pr_User_SyncAD
--						* fkUser_Level -> fk_User_Level
--		2016-Jun-27		.6022
--						* prEvent_Maint, prStfCvrg_InsFin
--		2016-Jul-05		.6030
--						* prRptCallStatSum, prRptCallStatSumGraph
--		2016-Jul-06		.6031
--						* vwEvent_C, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl, prRptCallActExc
--		2016-Jul-12		.6037
--						* prRptCallActSum
--		2016-Jul-18		.6043
--						* prRptCallActDtl
--		2016-Jul-19		.6044
--						* prRptCallActSum, prRptCallActDtl
--						* prRoomBed_GetByUnit
--		2016-Jul-21		.6046
--						* pr_User_InsUpdAD
--		2016-Jul-26		.6051
--						* prEvent84_Ins
--		2016-Jul-27		.6052
--						* prRpt_XltDtEvRng, prRptSysActDtl, prRptCallStatSum, prRptCallStatSumGraph, prRptCallStatDtl, prRptCallActSum, prRptCallActDtl, prRptCallActExc
--		2016-Jul-28		.6053
--						* tbStfCvrg:	+ .dShift	(vwStfCvrg, prStfCvrg_InsFin)
--		2016-Jul-29		.6054
--						- prRptStfAssnStaff
--						* prRptStfAssn, prRptStfCvrg
--		2016-Aug-03		.6059
--						* tbReport[7]
--		2016-Aug-24		.6080
--						* pr_User_GetAll
--		2016-Sep-01		.6088
--						* tb_Option[31]
--						* pr_User_InsUpdAD
--		2016-Sep-19		.6106
--						release
--		2016-Nov-16		.6164
--						+ prCallList_GetAll
--		2016-Nov-29		.6177
--						* tbCfgTone.dtCreated -> .dtUpdated		(prCfgTone_GetAll)
--						+ tbCfgDome		(+ prCfgDome_GetAll, prCfgDome_Upd)
--						* tbCfgPri.tiLight -> .tiDome	(+ fkCfgPri_Dome,	prCfgPri_GetAll, prCfgPri_InsUpd)
--		2016-Dec-05		.6183
--						* vwEvent_A		(+ .tiDome)
--		2016-Dec-06		.6184
--						+ tbCfgDome.tiPrism	(prCfgDome_GetAll, prCfgDome_Upd, vwEvent_A)
--		2016-Dec-07		.6185
--						* prCfgDome_Upd
--		2016-Dec-08		.6186
--						+ fnEventA_GetDomeByRoom
--						* prCfgDome_Upd
--		2016-Dec-09		.6187
--						* prRoomBed_GetByUnit
--		2016-Dec-14		.6192
--						* prMapCell_GetByUnitMap
--		2016-Dec-20		.6198
--						* prRtlsRoom_Get
--		2017-Jan-16		.6225
--						+ tbRoom.dtExpires	(vwRoom, prRtlsBadge_RstLoc, prRoom_UpdStaff, prRtlsBadge_UpdLoc)
--						- tbRtlsRoom.bNotify
--						- tbRtlsRoom	(-prRtlsRoom_OffOne, -vwRtlsRoom, *prDevice_UpdRoomBeds, prRtlsRcvr_UpdDvc, prRtlsBadge_UpdLoc)
--		2017-Jan-17		.6226
--						* prRtlsRoom_Get -> prRoom_GetRtls
--						- prRtlsRoom_OffOne
--						+ prRoom_UpdRtls
--						* prEvent_A_Exp
--		2017-Feb-06		.6246
--						* prRoom_GetRtls
--						* prRtlsBadge_UpdLoc
--		2017-Mar-14		.6282
--						* prRtlsBadge_RstLoc
--						* prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial
--						+ tb_Module.tiLvl
--		2017-Mar-16		.6284
--						* pr_Module_GetAll
--						+ pr_Module_SetLvl, tb_LogType[64]
--						* tbPatient:	- .idRoom, .tiBed, fkPatient_RoomBed	(prCfgBed_InsUpd, prPatient_UpdLoc, vwRoomBed, vwPatient)
--		2017-Mar-22		.6290
--						* tb_Option[31] redefined
--						* prRoom_UpdRtls
--		2017-Mar-29		.6297
--						* prRtlsBadge_UpdLoc
--						* prRtlsBadge_RstLoc, prRtlsRcvr_UpdDvc
--						* prEvent_A_Exp, prDevice_InsUpd, prDevice_GetIns, prPatient_UpdLoc, prEvent_Ins, prEvent84_Ins, prEvent41_Ins
--		2017-Mar-30		.6298
--						+ tb_Log.idModule	null for now	+ fk_Log_LogType		(vw_Log)
--		2017-Apr-03		.6302
--						* pr_Log_Ins
--		2017-Apr-04		.6303
--						+ tb_SessLog	(* pr_Sess_Clr)
--		2017-Apr-05		.6304
--						- tb_Log.idOper	(pr_Log_Ins)
--		2017-Apr-07		.6306
--						* pr_Module_Upd
--		2017-Apr-11		.6310
--						+ pr_SessLog_Ins, pr_SessLog_Clr
--		2017-Apr-12		.6311
--						* pr_Log_Get
--						* pr_User_Login, pr_User_Login2, pr_User_Logout
--		2017-May-11		.6340
--						+ tbCfgPri.tiLvl	(prCfgPri_InsUpd, + prCfgPri_SetLvl)
--		2017-May-16		.6345
--						* prCfgPri_SetLvl
--						* prCfgFlt_Ins, prCfgTone_Ins, prCfgPri_InsUpd, prCfgLoc_Ins, prDoctor_Upd, prPatient_Upd
--						* pr_Module_Reg, pr_Module_Lic
--						+ tbEvent_D
--		2017-May-26		.6355
--						+ tbEvent_A.tiLvl
--		2017-Jun-13		.6373
--						- tbEvent_A.tiLvl	(vwEvent_A)
--						* pr_User_InsUpd
--						* prEvent_Ins, prEvent84_Ins
--		2017-Jul-10		.6400
--						* prCall_GetAll
--		2017-Jul-11		.6401
--						+ tbReport.tiFlags	(prReport_GetAll)
--		2017-Jul-12		.6402
--						* tbEvent_D		(prEvent84_Ins)
--						+ fkEventD_Shift
--						+ vwEvent_D
--		2017-Jul-20		.6410
--						* prEvent84_Ins - addressing xuEventA_Active_SGJRB errors
--						* vwEvent_D
--		2017-Jul-27		.6417
--						* prRptCallActDtl
--						+ prRptCliPatDtl, prRptCliStfDtl, prRptCliStfSum
--		2017-Aug-25		.6446
--						* tbReport[22]
--		2017-Aug-31		.6452
--						+ tbDvcType[8]
--		2017-Sep-07		.6459
--						+ tb_LogType[226,227]
--						* prDvc_InsUpd
--						+ prDvc_RegWiFi, prDvc_UnRegWiFi
--		2017-Oct-16		.6498
--						+ tb_Log_S, vw_Log_S
--						* tb_Log:	+ .tLast, tiQty		(vw_Log, pr_Log_Ins)
--		2017-Oct-17		.6499
--						+ prTable_Health
--		2017-Oct-18		.6500
--						* vwEvent_A, prEvent_A_Get
--		2017-Oct-20		.6502
--						* prTable_Health -> prHealth_Table
--						+ prHealth_Index
--		2017-Oct-26		.6508
--						* xpReportRole -> xp_RoleRpt
--						* xuCall_Active_siIdx -> xuCall_siIdx_Act
--						* xuEventA_Active_SGJRB -> xuEventA_SGJRB_Act
--						* xuShift_Active_UnitIdx -> xuShift_UnitIdx_Act
--						* xuStfAssn_Active_RoomBedShiftIdx -> xuStfAssn_RmBdShIdx_Act
--		2017-Oct-27		.6509
--						+ pr_Version_GetAll
--		2017-Oct-30		.6512
--						+ pr_Log_XltDtEvRng
--		2017-Nov-13		.6526
--						* tb_SessLog -> tb_SessMod	(pr_SessLog_Ins -> pr_SessMod_Ins, pr_SessLog_Clr -> pr_SessMod_Clr, pr_Sess_Clr)
--						* pr_Log_Get
--		2017-Nov-21		.6534
--						* pr_Log_XltDtEvRng, pr_Log_Get
--		2017-Nov-29		.6542
--						* prEvent_A_Get
--		2017-Nov-30		.6543
--						* pr_User_Login, pr_User_Login2, prDvc_RegWiFi
--		2017-Dec-12		.6555
--						+ pr_LogType_GetAll
--						+ pr_Module_Get
--		2017-Dec-21		.6564
--						* prDvc_UnRegWiFi
--		2018-Jan-18		.6592
--						* prRtlsRcvr_GetAll, prRtlsBadge_GetAll
--		2018-Feb-19		.6624
--						* prDvc_RegWiFi
--						* prPatient_UpdLoc
--						* vwEvent_A
--						release
--		2018-Mar-13		.6646
--						* prDvc_RegWiFi
--		2018-Mar-23		.6656
--						+ prDvc_GetWiFi
--		2018-May-16		.6710
--						* tb_LogType[230]	+ [218-220]
--						* prStaff_SetDuty, prDvc_RegWiFi
--		2018-Jun-12		.6737
--						* pr_Sess_Del, prDvc_UnRegWiFi
--		2018-Jun-19		.6744
--						* prPatient_UpdLoc
--		2018-Jun-25		.6750
--						+ tb_Module[65]
--		2018-Jun-26		.6751
--						* pr_OptSys_Upd, pr_OptUsr_Upd, prCfgDome_Upd, prDevice_InsUpd, prEvent84_Ins
--		2018-Jul-03		.6758
--						* prDevice_InsUpd, prDevice_GetIns
--		2018-Jul-12		.6767
--						+ tbPcsType[0x80..0x82],	* [9] -> [0x40]
--						* tb_LogType	* [34],	+ [210,211], * 206 -> 210, 207 -> 211,	* [205..207]	(prEvent84_Ins)
--		2018-Jul-18		.6773
--						* prEvent41_Ins
--						* fkRoom_Event:		+ on delete set null
--						* prDevice_InsUpd, prDevice_GetIns
--		2018-Jul-19		.6774
--						+ tbDefCmd[4B], * tbDefCmd[41]
--						* prRptCallActDtl
--		2018-Jul-23		.6778
--						* tb_OptSys[20]
--						+ tb_Option[39], tb_OptSys[39]
--		2018-Jul-25		.6780
--						* tb_Module: - [65]	+ [131]
--						* prDvc_InsUpd
--		2018-Aug-01		.6787
--						+ tb_LogType[228]
--		2018-Aug-03		.6789
--						* prDevice_GetIns
--						release
--		2018-Aug-09		.6795
--						* pr_User_GetAll, pr_Role_GetAll
--		2018-Aug-10		.6796
--						* prCfgLoc_SetLvl
--		2018-Aug-17		.6803
--						* prUnit_GetAll
--		2018-Aug-20		.6806
--						* pr_User_InsUpdAD
--		2018-Aug-21		.6807
--						* pr_Role_GetUnits
--						- pr_UserRole_GetByRole (-> pr_Role_GetUsers), pr_UserRole_GetByUser (-> pr_User_GetRoles), prTeamUser_Get (-> prTeam_GetUsers)
--						+ pr_Role_GetUsers, pr_User_GetRoles, pr_User_GetUnits, pr_User_GetTeams, prDvc_GetUnits, prDvc_GetTeams, prTeam_GetCalls, prTeam_GetUnits, prTeam_GetUsers
--		2018-Aug-22		.6808
--						- pr_UserRole_GetByUser, pr_UserRole_GetByRole
--						* prTeamUser_Get -> prTeam_GetUsers
--						+ tb_Option[40], tb_OptSys[40]
--		2018-Aug-23		.6809
--						* prStaff_GetByUnit
--		2018-Aug-28		.6814
--						- prTeamPri_InsDel
--						* tbTeamPri -> tbTeamCall	(prTeam_GetCalls, [prTeamPri_InsDel -> prTeamCall_InsDel], prTeam_InsUpd, prTeam_GetByUnitPri)
--						- tb_User.sTeams, .sUnits	(pr_User_GetAll, pr_User_Imp, vwStaff)
--						- tbTeam.sCalls, .sUnits	(prTeam_GetByUnit, prTeam_GetByUnitPri)
--						- tbDvc.sTeams, .sUnits		(vwDvc, prDvc_Exp, prDvc_Imp, prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi)
--						* pr_Role_InsUpd, pr_User_InsUpd, prTeam_InsUpd, prDvc_InsUpd
--		2018-Aug-29		.6815
--						+ tbDvc.sBrowser	(vwDvc, prDvc_Exp, prDvc_Imp, prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi, prDvc_RegWiFi)
--		2018-Aug-30		.6816
--						* prStfAssn_Exp
--						- pr_UserRole_InsDel
--						* tbDvcTeam -> tbTeamDvc	(prDvc_GetTeams, prTeam_GetDvcs, prDvc_InsUpd)
--						* pr_RoleUnit_Exp, pr_UserRole_Exp
--						+ pr_UserUnit_Exp, pr_UserUnit_Imp
--						+ prTeamUnit_Exp, prTeamUnit_Imp, prTeamUser_Exp, prTeamUser_Imp, prTeamCall_Exp, prTeamCall_Imp, prTeamDvc_Exp, prTeamDvc_Imp
--						+ prDvcUnit_Exp, prDvcUnit_Imp
--		2018-Aug-31		.6817
--						* prUnit_GetAll, pr_Role_GetUnits, pr_Role_GetUsers, pr_User_GetRoles, pr_User_GetUnits, pr_User_GetTeams, prDvc_GetUnits, prTeam_GetUnits, prTeam_GetUsers
--						+ prTeam_Exp, prTeam_Imp
--		2018-Sep-05		.6822
--						* prEvent84_Ins (fix for .6767)
--		2018-Sep-05		.6824
--						release
--		2018-Nov-19		.6897
--						* build # bump for HASP-wrapping
--						release
--
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
--		2019-Jul-09		.7129
--						* tb_LogType:	+[100-103]		(pr_User_InsUpdAD)
--		2019-Jul-11		.7131
--						* pr_Module_Upd
--		2019-Jul-18		.7138
--						* tb_LogType[46]
--		2019-Jul-22		.7142
--						* tb_LogType[228]
--						* pr_User_Logout
--		2019-Jul-26		.7146
--						* tb_LogType[41,42,44,48]
--		2019-Aug-02		.7153
--						release
--		2019-Sep-25		.7207
--						* prCfgDvc_GetAll
--		2019-Sep-30		.7212
--						* pr_User_GetOne
--		2019-Oct-10		.7222
--						- tbPatient[?]:	('EMPTY', 'O')
--						- prPatient_Upd
--						* prDoctor_GetIns, prPatient_GetIns, prPatient_UpdLoc
--		2019-Oct-16		.7228
--						* pr_Log_Ins
--		2019-Oct-30		.7242
--						* tbRoom:	+ xuRoom_UserG, xuRoom_UserO, xuRoom_UserY
--						* prRoom_UpdStaff
--		2019-Nov-01		.7244
--						* pr_User_SyncAD
--		2019-Nov-05		.7248
--						* prRtlsBadge_RstLoc, prRtlsBadge_UpdLoc
--		2019-Nov-06		.7249
--						* pr_User_InsUpdAD
--						* prRoom_UpdStaff
--						* prDevice_UpdRoomBeds
--		2019-Nov-08		.7251
--						* pr_User_SyncAD
--						* tb_LogType:	+[104]		(pr_User_InsUpdAD)
--		2019-Nov-13		.7256
--		2019-Nov-14		.7257
--						* tbRoom:	- xuRoom_UserG, xuRoom_UserO, xuRoom_UserY		7983 (prEvent84_Ins) not ready for this yet
--		2019-Nov-18		.7261
--						* vwRtlsRcvr
--						* tbRtlsBadge:	- .idRcvrLast, .dtRcvrLast, .idRoom
--										* .idRcvrCurr -> idReceiver, dtRcvrCurr -> dtReceiver
--											(vwRtlsBadge, prRtlsBadge_RstLoc, prDvc_GetByUnit)
--						* prRtlsBadge_UpdLoc
--		2019-Nov-19		.7262
--						+ tbRoom.tiCall	(vwRoom, prRtlsBadge_RstLoc, prRtlsBadge_UpdLoc, prRoom_GetRtls)
--						* vwRtlsRcvr
--						* tbRoom:	+ xuRoom_UserG, xuRoom_UserO, xuRoom_UserY
--		2019-Nov-22		.7265
--						* prRtlsBadge_UpdLoc
--						* prRoom_UpdStaff
--						* prEvent84_Ins
--						* prDevice_UpdRoomBeds
--		2019-Nov-27		.7270
--						* prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi
--		2019-Dec-03		.7276
--						* prCfgBed_InsUpd, prEvent_Maint
--		2019-Dec-04		.7277
--						* prRoom_UpdStaff, prEvent84_Ins, prDevice_UpdRoomBeds, prRtlsBadge_UpdLoc
--		2019-Dec-06		.7279
--						* 
--		2019-Dec-13		.7286
--						* prDevice_GetByUnit
--		2019-Dec-19		.7292
--						* tb_Option:	[11]<->[19]	(pr_User_sStaff_Upd, pr_OptSys_Upd, prEvent_Maint)
--										[26]->[6]	(prDevice_GetIns, prDevice_InsUpd)
--										[31]->[8]	(prRoom_UpdRtls)
--						* tbRoom:	+ .idUser4, .idUser2, .idUser1
--								(vwRoom, prRoom_GetRtls, prRoom_UpdRtls, prRoom_UpdStaff, prRtlsBadge_RstLoc, prRtlsBadge_UpdLoc)
--						* prRtlsBadge_GetAll
--		2019-Dec-20		.7293
--						* tb_Option:	[38]->[31]	(prCfgLoc_SetLvl)
--										[39]->[26]	()
--		2019-Dec-26		.7299
--						* pr_User_SyncAD, pr_User_InsUpdAD
--		2019-Dec-27		.7300
--						* pr_User_Logout
--		2020-Jan-03		.7307
--						* vwEvent_A
--						* prEvent84_Ins
--		2020-Jan-06		.7310
--						* tbReport:	+ [10,11], [22..24]
--		2020-Jan-07		.7311
--						+ prRptRndStatSum, prRptRndStatDtl
--		2020-Jan-13		.7317
--						* prCall_GetAll
--		2020-Jan-14		.7318
--						* prRoom_UpdStaff
--						* prEvent84_Ins
--		2020-Jan-22		.7326
--						* pr_User_InsUpd, pr_User_InsUpdAD
--		2020-Jan-30		.7334
--						* prMapCell_GetByUnitMap
--		2020-Jan-31		.7335
--						RC
--
--		2020-Feb-04		.7339
--						* build # bump for HASP-wrapping
--		2020-Feb-20		.7355
--						* prRoom_UpdStaff, prRtlsBadge_UpdLoc
--		2020-Mar-03		.7367
--						* pr_User_sStaff_Upd
--		2020-Mar-04		.7368
--						* tbTeam	+ .bEmail	(prTeam_Exp, prTeam_Imp, prTeam_GetByUnit, prTeam_GetByUnitPri, prTeam_InsUpd)
--		2020-Mar-09		.7373
--						+ prTeam_GetEmails
--		2020-Mar-13		.7377
--						* pr_AccUnit_Set
--		2020-Mar-16		.7380
--						* prCall_Imp
--		2020-Mar-24		.7388
--						* pr_User_Login, pr_User_Login2, pr_User_Logout
--		2020-Mar-25		.7389
--						* prDvc_GetByUnit
--		2020-Mar-26		.7390
--						+ pr_OptUsr_GetAll
--						* pr_OptSys_Upd, pr_OptUsr_Upd
--		2020-Apr-15		.7410
--						* prDevice_GetIns
--		2020-Apr-17		.7412
--						* prEvent_Ins
--		2020-Apr-22		.7417
--						* prEvent84_Ins
--		2020-Apr-27		.7422
--						* prEvent84_Ins, prTeam_GetByUnitPri
--		2020-May-07		.7432
--						* tb_LogType[83].tiCat
--						* pr_AccUnit_Set
--		2020-May-08		.7433
--						* pr_User_InsUpd, pr_User_InsUpdAD
--		2020-May-22		.7447
--						* prEvent84_Ins
--						* pr_Role_InsUpd
--		2020-May-27		.7452
--						* prStfAssn_Imp
--						* prShift_Imp
--		2020-May-29		.7454
--						* prPatient_GetIns
--		2020-Jun-02		.7458
--						* prStfAssn_Exp
--		2020-Jun-04		.7460
--						* prShift_Imp, prStfAssn_Imp, prStfAssn_Exp
--		2020-Jun-05		.7461
--						* prCfgLoc_SetLvl
--		2020-Jun-08		.7464
--						* prEvent84_Ins
--		2020-Jun-09		.7465
--						* prStfAssn_InsUpdDel, prShift_InsUpd
--		2020-Jun-11		.7467
--						* prEvent_Maint
--						* pr_Module_Reg, pr_Module_Lic
--		2020-Jul-22		.7508
--						* tb_LogType[44,45,46,48]
--						* prPatient_GetIns, prPatient_UpdLoc
--		2020-Aug-04		.7521
--						* prEvent_A_Get
--		2020-Aug-14		.7531
--						* pr_User_GetDvcs, prTeam_GetDvcs, prDvc_GetByUnit
--		2020-Sep-09		.7557
--						* prEvent41_Ins
--		2020-Oct-09		.7587
--						* tbRouting	+ .tResp4	(prRouting_Get, prRouting_Set)
--		2020-Nov-05		.7614
--						* prRptRndStatSum, prRptRndStatDtl
--		2020-Nov-09		.7618
--						* prEvent_Maint
--		2020-Nov-18		.7627
--						+ xtCfgPri_tiLvl
--		2020-Dec-02		.7641
--						* tbCfgPri.tiLvl	(prCfgPri_InsUpd)
--		2020-Dec-04		.7643
--						* prCall_GetAll
--		2020-Dec-08		.7647
--						- xtCfgPri_tiLvl
--		2020-Dec-10		.7649
--						* prRptCallStatSum, prRptStfAssn
--		2021-Feb-04		.7705
--						+ [rExporter]
--						+ prExportCallsActive, prExportCallsComplete
--		2021-Mar-25		.7754
--						* pr_Sess_Ins
--		2021-Apr-23		.7783
--						RC
--
--		2021-Jun-09		.7830
--						* prCfgDvc_GetAll, [prDevice_GetByID,] prRoom_GetByUnit, prDevice_GetByUnit
--		2021-Jun-16		.7837
--						* prDevice_GetIns, prEvent_Ins
--		2021-Jun-17		.7838
--						* vwEvent_A
--		2021-Jun-23		.7844
--						* prMapCell_GetByUnit
--		2021-Jul-02		.7853
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
--		2021-Aug-03		.7885
--						* prEvent_A_Get
--		2021-Aug-04		.7886
--						* prStaff_GetByUnit
--		2021-Aug-04		.7887
--						RC
--
--		2021-Oct-13		.7956
--						* added 'go' after prDevice_GetByUnit, prCfgDvc_GetAll (were missing in the .7887 build, resulting in skipped permissions)
--
--		2022-Jan-24		.8059
--						* tb_LogType[ 79 ].tiLvl:	16 -> 8,	.sLogType= 'Config data'
--		2022-Mar-28		.8122
--						* pr_Log_Ins, pr_Module_Upd, prEvent_SetGwState, vwEvent
--		2022-Mar-29		.8123
--						* tbDvcType:	+ .cDvcType, xuDvcType
--						* vwDvc:	* sFqDvc
--		2022-Apr-05		.8130
--						* vwDvc:	+ cDvcType
--		2022-Apr-12		.8137
--						* vwStaff:	* sFqStaff -> sQnStf	(prStaff_LstAct, prStaff_SetDuty, vwDvc, vwRtlsBadge, prRtlsBadge_GetAll, prRptSysActDtl)
--						* vwDvc:	* sQnDvc
--		2022-Apr-14		.8139
--						+ tbStfLvl.cStfLvl, xuStfLvl	(prStfLvl_GetAll, prStfLvl_Upd)
--						* vwRoom,vwDevice:	* sQnDevice -> sFqDvc,	+ sQnDvc	(prCfgDvc_GetBtns, prRoom_LstAct)
--							vwEvent_A	(prDvc_GetByUnit, prDvc_GetByBC, prDvc_GetByDial, prDvc_GetWiFi)
--							vwRoomBed	(prStfAssn_GetByUnit)
--						* vwRtlsRcvr:	* sQnDevice -> sQnDvc	(prRtlsRcvr_GetAll)
--						* vwEvent:	+ sRoomBed, sQnSrcDvc, sQnDstDvc
--		2022-Apr-18		.8143
--						* prRptSysActDtl
--						+ tbDevice[ 0 ]	J-000-000-00 '$|NURSE CALL'
--		2022-Apr-22		.8147
--						* finalized tbDevice update
--						+ added 7970 tables (for single-DB scenario)
--		2022-May-13		.8168
--						* prDevice_GetIns
--		2022-Jun-03		.8189
--						* tbCfgPri:		+ .tiColor	- .iColorF, .iColorB
--											(prCfgPri_InsUpd, prCfgPri_GetAll, prCall_GetAll, vwEvent_A, prEvent_A_Get, prEvent_A_GetAll,
--												prCallList_GetAll, fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRouting_Get, prMapCell_GetByUnitMap)
--										* .iFilter -> not null
--		2022-Jun-08		.8194
--						* prRptSysActDtl, prRptCallActDtl
--		2022-Jun-13		.8199
--						* prRptCallActExc, prRptCallActSum
--		2022-Jul-21		.8237
--						+ tb_Option[38], tb_OptSys[38]
--		2022-Aug-23		.8270
--						+ tb_Option[39], tb_OptSys[39]
--		2022-Aug-25		.8272
--						* prCfgDome_GetAll
--		2022-Aug-29		.8276
--						* prRtlsRcvr_GetAll, prRtlsBadge_GetAll
--						* prRtlsBadge_InsUpd, prRtlsBadge_UpdLoc
--		2022-Sep-02		.8280
--						* prStaff_GetByUnit
--						* prRoomBed_GetByUnit
--		2022-Sep-06		.8284
--						* prStaff_LstAct, prRoom_LstAct
--		2022-Sep-08		.8286
--						* pr_User_sStaff_Upd
--		2022-Sep-28		.8306
--						* prRtlsBadge_GetAll
--		2022-Oct-05		.8313
--						* prStaff_LstAct
--		2022-Oct-06		.8314
--						* prRoomBed_GetByUnit
--		2022-Oct-11		.8319
--						* prRptCallStatSum, prRptCallStatDtl
--		2022-Oct-12		.8320
--						* prRtlsBadge_InsUpd
--		2022-Oct-13		.8321
--						* finalized
--
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
--						* fnEventA_GetTopByUnit, fnEventA_GetDomeByRoom
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
--						* tbPatient:	+ .sIdent, .sPatID, .sLast, .sFrst, sMidd	()
--						+ prHlEvent_Get
--		2023-Aug-30		.8642
--						+ xuPatient_PatId
--		2023-Sep-11		.8654
--						* finalized
--
--		2023-Sep-13		.8656
--						* fix for missing	.8147	2022-Apr-22
--							+ added 7970 tables (for single-DB scenario)
--		2023-Sep-13		.8658
--						* finalized
--
--		2023-Oct-11		.8684
--						* prStaff_GetByUnit, pr_Role_GetAll, prTeam_GetByUnit, prDvc_GetByUnit
--		2023-Oct-13		.8686
--						* pr_User_GetAll
--		2023-Oct-17		.8690
--						* prStfAssn_InsUpdDel
--		2023-Oct-20		.8693
--						* prUnit_UpdShifts, prShift_InsUpd
--						+ prShift_Upd
--		2023-Oct-23		.8696
--						* vwShift, prShift_GetAll
--		2023-Nov-01		.8705
--						* tb_Log's IDENTITY:	1 -> 0x80000000 == -2147483648	(pr_Log_XltDtEvRng)
--		2023-Nov-07		.8711
--						* pr_Log_Get, pr_Log_XltDtEvRng
--						+ tb_Option[50..53], tb_OptSys[50..53]
--		2023-Nov-08		.8712
--						+ prHealth_Stats
--						* prStfCvrg_InsFin
--		2023-Nov-14		.8718
--						* pr_Version_GetAll
--		2023-Nov-15		.8719
--						* pr_User_Logout
--		2023-Nov-21		.8725
--						* prHealth_Stats
--		2023-Nov-22		.8726
--						* pr_User_SyncAD
--		2023-Nov-29		.8733
--						* prRptSysActDtl
--		2023-Nov-30		.8734
--						* pr_User_InsUpdAD, pr_User_InsUpd, prDvc_InsUpd
--		2023-Dec-06		.8740
--						* vwRoom, vwRtlsBadge
--						* tbDvc:	.tiFlags	(prDvc_UpdUsr, prDvc_InsUpd, prDvc_GetByUnit, prRtlsBadge_InsUpd)
--		2023-Dec-08		.8742
--						* finalized
--		2023-Dec-19		.8753
--						* vwRtlsBadge, prRtlsBadge_GetAll
--		2024-Jan-04		.8769
--						* prRtlsBadge_GetAll, prStaff_LstAct, prDvc_UpdUsr
--						* finalized
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
--		2024-Apr-17		.8873
--						* tb_Module		+ [31,32]
--		2024-May-02		.8888
--						* tb_Option		+ [60..65]
--		2024-May-03		.8889
--						* tbHlCall:		.sSend -> sTxt, .bSend -> bUse	(tdHlCall_Send -> tdHlCall_Use, prHlCall_GetAll, prHlCall_Upd, prHlEvent_Get)
--						* tbHlRoomBed:	.sSend -> sLoc, .bSend -> bUse	(tdHlRoomBed_Send -> tdHlRoomBed_Use, prHlRoomBed_GetAll, prHlRoomBed_Upd, prHlEvent_Get)
--		2024-May-06		.8892
--						+ tbIbedLoc, 
--		2024-May-21		.8907
--						* tbRoomBed:	+ .dtExpires	(vwRoomBed)
--		2024-Jul-08		.8955
--						* prRtlsBadge_InsUpd
--		2024-Jul-10		.8957
--						* prCfgStn_InsUpd
--		2024-Jul-12		.8959
--						* prHealth_Stats
--						* prCfgBed_InsUpd
--						* prCfgFlt_Clr
--						* prCfgFlt_Ins
--						* prCfgTone_Ins
--						* prCfgDome_Upd
--						* prCfgPri_InsUpd
--						* prCfgTone_Clr
--						* prCall_Upd
--						* prCall_GetIns
--						* prCfgLoc_Clr
--						* prCfgLoc_Ins
--						* prCall_Imp
--						* prCfgStn_InsUpd
--						* prCfgStn_GetIns
--						* prCfgMst_Clr
--						* prCfgMst_Ins
--						* prCfgBtn_Clr
--						* prCfgBtn_Ins
--						* prCfgBed_InsUpd
--						* prCfgLoc_SetLvl
--						* prCfgStn_Init
--						* prCfgStn_UpdAct
--						* prCfgStn_UpdRmBd
--		2024-Jul-16		.8963
--						* prRptCallActSum
--						* prRptCallStatSum
--		2024-Jul-18		.8965
--						* pr_Access_InsUpdDel
--						* prStfLvl_Upd
--						* pr_Sess_Ins
--						* pr_Role_InsUpd
--						* prTeam_InsUpd
--						* prDvc_InsUpd
--						* prRoom_UpdStaff
--						* prDoctor_GetIns
--						* prDoctor_Upd
--						* prPatient_GetIns
--						* prPatient_UpdLoc
--						* prEvent_Ins
--						* prEvent84_Ins
--						* prEvent41_Ins
--						* prMapCell_ClnUp
--						* prStfAssn_Imp
--						* prStfAssn_InsUpdDel
--						* prShift_InsUpd
--						* pr_User_SyncAD
--						* pr_User_InsUpdAD
--						* pr_User_InsUpd
--		2024-Jul-19		.8966					CloudStrike (m) day
--						* pr_User_Login
--						* prEvent_A_Exp
--						* prStfCvrg_InsFin	-> prHealth_Min	(prStaff_SetDuty)
--		2024-Jul-25		.8972
--						* pr_Sess_Ins
--						* pr_Sess_Del
--						* pr_Sess_Maint
--						* prDvc_UnRegWiFi
--		2024-Jul-31		.8978
--						+ tb_Option[70]	->	tb_OptSys, tb_OptUsr
--						* pr_OptUsr_Upd
--						* prHealth_Stats
--		2024-Aug-08		.8986
--						? finalized
--		2024-Aug-13		.8991
--						* tb_Module		+ .sPath	(pr_Module_GetAll, pr_Module_Reg)
--		2024-Aug-15		.8993
--						* vw_Sess, pr_Sess_GetAll
--						* pr_User_Login, prDvc_RegWiFi
--		2024-Aug-16		.8994
--						* pr_Module_Act
--		2024-Aug-23		.9001
--						* prRptCallActDtl
--		2024-Aug-27		.9005
--						* pr_User_InsUpd, prRtlsBadge_InsUpd
--		2024-Aug-29		.9007
--						* prDvc_GetByUnit
--		2024-Sep-06		.9015
--						* finalized
--
--		TODO:
--						[	* tbRouting:	make tiRouting, bOverride nullable,		tdRouting_Routing, tdRouting_Override	->	single tcRouting_NotNull on all fields	]
--						[	* tb_Log.idLog	-> bigint (int64)	]
--						[	* prPatient_UpdLoc:	- @tiRID	]
--	============================================================================

use [{0}]
go
set	xact_abort			on
set ansi_null_dflt_on	on
set nocount				on
set quoted_identifier	on
go

--	============================================================================
print	char(10) + '###	Dropping objects..'
--	(must go in reverse order)
go

--	----------------------------------------------------------------------------
print	'	7980 objects'
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='sp_GetStaffList')
	drop proc	dbo.sp_GetStaffList

if exists	(select 1 from dbo.sysobjects where uid=1 and name='DeviceToStaffAssignment')
	drop view	dbo.DeviceToStaffAssignment
if exists	(select 1 from dbo.sysobjects where uid=1 and name='StaffToPatientAssn')
	drop view	dbo.StaffToPatientAssn
if exists	(select 1 from dbo.sysobjects where uid=1 and name='StaffToPatientAssignment')
	drop view	dbo.StaffToPatientAssignment
if exists	(select 1 from dbo.sysobjects where uid=1 and name='Device')
	drop view	dbo.Device
if exists	(select 1 from dbo.sysobjects where uid=1 and name='Team')
	drop view	dbo.Team
if exists	(select 1 from dbo.sysobjects where uid=1 and name='StaffRole')
	drop view	dbo.StaffRole
if exists	(select 1 from dbo.sysobjects where uid=1 and name='Units')
	drop view	dbo.Units
if exists	(select 1 from dbo.sysobjects where uid=1 and name='Staff')
	drop view	dbo.Staff
if exists	(select 1 from dbo.sysobjects where uid=1 and name='BedDefinition')
	drop view	dbo.BedDefinition
if exists	(select 1 from dbo.sysobjects where uid=1 and name='ArchitecturalConfig')
	drop view	dbo.ArchitecturalConfig

if exists	(select 1 from dbo.sysobjects where uid=1 and name='CallPriority')
	drop table	dbo.CallPriority
if exists	(select 1 from dbo.sysobjects where uid=1 and name='Facility')
	drop table	dbo.Facility
if exists	(select 1 from dbo.sysobjects where uid=1 and name='Access')
	drop table	dbo.Access
go

--	----------------------------------------------------------------------------
print	'	functions'
go

--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStaffAssnDef_GetByShift')
--	drop function	dbo.fnStaffAssnDef_GetByShift
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStfAssn_GetByShift')
	drop function	dbo.fnStfAssn_GetByShift
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStaffAssn_GetByShift')
	drop function	dbo.fnStaffAssn_GetByShift
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetPrismByRoom')
	drop function	dbo.fnEventA_GetPrismByRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetDomeByRoom')
	drop function	dbo.fnEventA_GetDomeByRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetTopByRoom')
	drop function	dbo.fnEventA_GetTopByRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetTopByUnit')
	drop function	dbo.fnEventA_GetTopByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetByMaster')
	drop function	dbo.fnEventA_GetByMaster
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnUnitMapCell_GetMap')
	drop function	dbo.fnUnitMapCell_GetMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnMapCell_GetMap')
	drop function	dbo.fnMapCell_GetMap
go

--	----------------------------------------------------------------------------
print	'	procedures'
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_GetRoom')
	drop proc	dbo.prIbedLoc_GetRoom
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_UpdRoom')
	drop proc	dbo.prIbedLoc_UpdRoom
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_InsUpd')
	drop proc	dbo.prIbedLoc_InsUpd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_GetAll')
	drop proc	dbo.prIbedLoc_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prExportCallsComplete')
	drop proc	dbo.prExportCallsComplete
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prExportCallsActive')
	drop proc	dbo.prExportCallsActive
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCliStfSum')
	drop proc	dbo.prRptCliStfSum
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCliStfDtl')
	drop proc	dbo.prRptCliStfDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCliPatDtl')
	drop proc	dbo.prRptCliPatDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptRndStatDtl')
	drop proc	dbo.prRptRndStatDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptRndStatSum')
	drop proc	dbo.prRptRndStatSum
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStfCvrg')
	drop proc	dbo.prRptStfCvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStfAssnStaff')
	drop proc	dbo.prRptStfAssnStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStfAssn')
	drop proc	dbo.prRptStfAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStaffCvrg')
	drop proc	dbo.prRptStaffCvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStaffCover')
	drop proc	dbo.prRptStaffCover
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStaffAssn')
	drop proc	dbo.prRptStaffAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallActExc')
	drop proc	dbo.prRptCallActExc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallActDtl')
	drop proc	dbo.prRptCallActDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallActSum')
	drop proc	dbo.prRptCallActSum
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallStatDtl')
	drop proc	dbo.prRptCallStatDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallStatSumGraph')
	drop proc	dbo.prRptCallStatSumGraph
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallStatGfx')
	drop proc	dbo.prRptCallStatGfx
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallStatSum')
	drop proc	dbo.prRptCallStatSum
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptSysActDtl')
	drop proc	dbo.prRptSysActDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRpt_XltDtEvRng')
	drop proc	dbo.prRpt_XltDtEvRng
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
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_Del')
	drop proc	dbo.prFilter_Del
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_Del')
	drop proc	dbo.prSchedule_Del
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_Upd')
	drop proc	dbo.prSchedule_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_InsUpd')
	drop proc	dbo.prSchedule_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_GetToRun')
	drop proc	dbo.prSchedule_GetToRun
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_GetAll')
	drop proc	dbo.prSchedule_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_Get')
	drop proc	dbo.prSchedule_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_InsUpd')
	drop proc	dbo.prFilter_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_Get')
	drop proc	dbo.prFilter_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_GetByUser')
	drop proc	dbo.prFilter_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_RoleRpt_Set')
	drop proc	dbo.pr_RoleRpt_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prReport_GetAll')
	drop proc	dbo.prReport_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvcUnit_Imp')
	drop proc	dbo.prDvcUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvcUnit_Exp')
	drop proc	dbo.prDvcUnit_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamDvc_Imp')
	drop proc	dbo.prTeamDvc_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamDvc_Exp')
	drop proc	dbo.prTeamDvc_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUnit_Imp')
	drop proc	dbo.prTeamUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUnit_Exp')
	drop proc	dbo.prTeamUnit_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamCall_Imp')
	drop proc	dbo.prTeamCall_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamCall_Exp')
	drop proc	dbo.prTeamCall_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUser_Imp')
	drop proc	dbo.prTeamUser_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUser_Exp')
	drop proc	dbo.prTeamUser_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Imp')
	drop proc	dbo.pr_UserUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Exp')
	drop proc	dbo.pr_UserUnit_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByUnit')
	drop proc	dbo.pr_User_GetByUnit
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Log_Get')
	drop proc	dbo.pr_Log_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Log_XltDtEvRng')
	drop proc	dbo.pr_Log_XltDtEvRng
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_UnRegWiFi')
	drop proc	dbo.prDvc_UnRegWiFi
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_RegWiFi')
	drop proc	dbo.prDvc_RegWiFi
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_Maint')
	drop proc	dbo.pr_Sess_Maint
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_Del')
	drop proc	dbo.pr_Sess_Del
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_Clr')
	drop proc	dbo.pr_Sess_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessCall_Set')
	drop proc	dbo.pr_SessCall_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessShift_Ins')
	drop proc	dbo.pr_SessShift_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessStaff_Ins')
	drop proc	dbo.pr_SessStaff_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessUser_Ins')
	drop proc	dbo.pr_SessUser_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessDvc_Ins')
	drop proc	dbo.pr_SessDvc_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessStn_Ins')
	drop proc	dbo.pr_SessStn_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLoc_Ins')
	drop proc	dbo.pr_SessLoc_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessCall_Ins')
	drop proc	dbo.pr_SessCall_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLog_Clr')
	drop proc	dbo.pr_SessLog_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLog_Ins')
	drop proc	dbo.pr_SessLog_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessMod_Clr')
	drop proc	dbo.pr_SessMod_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessMod_Ins')
	drop proc	dbo.pr_SessMod_Ins
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetAssn')
	drop proc	dbo.prStaff_GetAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_GetAssn')
	drop proc	dbo.prRoomBed_GetAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCallList_GetAll')
	drop proc	dbo.prCallList_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetDataByUnitMap')
	drop proc	dbo.prMapCell_GetDataByUnitMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_GetDataByUnits')
	drop proc	dbo.prRoomBed_GetDataByUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetByUnitMap')
	drop proc	dbo.prMapCell_GetByUnitMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetByMap')
	drop proc	dbo.prMapCell_GetByMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_GetByUnit')
	drop proc	dbo.prRoomBed_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_UpdRtls')
	drop proc	dbo.prRoom_UpdRtls
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetRtls')
	drop proc	dbo.prRoom_GetRtls
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRoom_Get')
	drop proc	dbo.prRtlsRoom_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_UpdLoc')
	drop proc	dbo.prRtlsBadge_UpdLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prBadge_UpdLoc')
	drop proc	dbo.prBadge_UpdLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRcvr_UpdDvc')
	drop proc	dbo.prRtlsRcvr_UpdDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_UpdRoomBeds7980')
	drop proc	dbo.prDevice_UpdRoomBeds7980
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_UpdRoomBeds')
	drop proc	dbo.prDevice_UpdRoomBeds
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_UpdRmBd')
	drop proc	dbo.prCfgDvc_UpdRmBd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_UpdRmBd')
	drop proc	dbo.prCfgStn_UpdRmBd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_Init')
	drop proc	dbo.prRtlsBadge_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRcvr_Init')
	drop proc	dbo.prRtlsRcvr_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_UpdAct')
	drop proc	dbo.prCfgDvc_UpdAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_UpdAct')
	drop proc	dbo.prCfgStn_UpdAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_Init')
	drop proc	dbo.prCfgDvc_Init
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_Init')
	drop proc	dbo.prCfgStn_Init
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_RstLoc')
	drop proc	dbo.prRtlsBadge_RstLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prBadge_ClrAll')
	drop proc	dbo.prBadge_ClrAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRoom_OffOne')
	drop proc	dbo.prRtlsRoom_OffOne
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_InsUpd')
	drop proc	dbo.prRtlsBadge_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_GetAll')
	drop proc	dbo.prRtlsBadge_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBdgType_InsUpd')
	drop proc	dbo.prRtlsBdgType_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadgeType_InsUpd')
	drop proc	dbo.prRtlsBadgeType_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsSnsr_InsUpd')
	drop proc	dbo.prRtlsSnsr_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsSnsr_GetAll')
	drop proc	dbo.prRtlsSnsr_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsColl_InsUpd')
	drop proc	dbo.prRtlsColl_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRcvr_InsUpd')
	drop proc	dbo.prRtlsRcvr_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRcvr_GetAll')
	drop proc	dbo.prRtlsRcvr_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_InsUpd')
	drop proc	dbo.pr_User_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_InsUpdAD')
	drop proc	dbo.pr_User_InsUpdAD
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_SyncAD')
	drop proc	dbo.pr_User_SyncAD
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_SetDuty')
	drop proc	dbo.prStaff_SetDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_InsUpd')
	drop proc	dbo.prShift_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Upd')
	drop proc	dbo.prShift_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Min')
	drop proc	dbo.prHealth_Min
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfCvrg_InsFin')
	drop proc	dbo.prStfCvrg_InsFin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffCover_InsFin')
	drop proc	dbo.prStaffCover_InsFin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_InsUpdDel')
	drop proc	dbo.prStfAssn_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_GetByUnit')
	drop proc	dbo.prStfAssn_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_Imp')
	drop proc	dbo.prStfAssn_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_Exp')
	drop proc	dbo.prStfAssn_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssn_InsUpdDel')
	drop proc	dbo.prStaffAssn_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_Fin')
	drop proc	dbo.prStfAssn_Fin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssn_Fin')
	drop proc	dbo.prStaffAssn_Fin
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_GetByRoom')
	drop proc	dbo.prStfAssn_GetByRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRouting_Set')
	drop proc	dbo.prRouting_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRouting_Clr')
	drop proc	dbo.prRouting_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRouting_Get')
	drop proc	dbo.prRouting_Get
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_UpdShifts')
	drop proc	dbo.prUnit_UpdShifts
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_InsUpdDel')
	drop proc	dbo.prShift_InsUpdDel
--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_GetByUnit')
--	drop proc	dbo.prShift_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_GetAll')
	drop proc	dbo.prShift_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Upd')
	drop proc	dbo.prShift_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Imp')
	drop proc	dbo.prShift_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Exp')
	drop proc	dbo.prShift_Exp
--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_GetAll')
--	drop proc	dbo.prShift_GetAll
--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMstrAcct_InsUpd')
--	drop proc	dbo.prMstrAcct_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgLoc_SetLvl')
	drop proc	dbo.prCfgLoc_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefLoc_SetLvl')
	drop proc	dbo.prDefLoc_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_InsUpdDel')
	drop proc	dbo.prUnit_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMapCell_Upd')
	drop proc	dbo.prUnitMapCell_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_Upd')
	drop proc	dbo.prMapCell_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetByUnit')
	drop proc	dbo.prMapCell_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMap_Upd')
	drop proc	dbo.prUnitMap_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMap_GetByUnit')
	drop proc	dbo.prUnitMap_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_ClnUp')
	drop proc	dbo.prMapCell_ClnUp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMap_GetAll')
	drop proc	dbo.prUnitMap_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventC1_Ins')
	drop proc	dbo.prEventC1_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent41_Ins')
	drop proc	dbo.prEvent41_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventB7_Ins')
	drop proc	dbo.prEventB7_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventB4_Ins')
	drop proc	dbo.prEventB4_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventB1_Ins')
	drop proc	dbo.prEventB1_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventAB_Ins')
	drop proc	dbo.prEventAB_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventA9_Ins')
	drop proc	dbo.prEventA9_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventA7_Ins')
	drop proc	dbo.prEventA7_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventA3_Ins')
	drop proc	dbo.prEventA3_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventA2_Ins')
	drop proc	dbo.prEventA2_Ins
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventA1_Ins')
	drop proc	dbo.prEventA1_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent9B_Ins')
	drop proc	dbo.prEvent9B_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent99_Ins')
	drop proc	dbo.prEvent99_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent98_Ins')
	drop proc	dbo.prEvent98_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent95_Ins')
	drop proc	dbo.prEvent95_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent91_Ins')
	drop proc	dbo.prEvent91_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent8C_Ins')
	drop proc	dbo.prEvent8C_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent8A_Ins')
	drop proc	dbo.prEvent8A_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent86_Ins')
	drop proc	dbo.prEvent86_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent84_Ins')
	drop proc	dbo.prEvent84_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_SetGwState')
	drop proc	dbo.prEvent_SetGwState
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_SetLvl')
	drop proc	dbo.pr_Module_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Lic')
	drop proc	dbo.pr_Module_Lic
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Upd')
	drop proc	dbo.pr_Module_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Set')
	drop proc	dbo.pr_Module_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Reg')
	drop proc	dbo.pr_Module_Reg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_Ins')
	drop proc	dbo.prEvent_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_Maint')
	drop proc	dbo.prEvent_Maint
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_A_Exp')
	drop proc	dbo.prEvent_A_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prPatient_UpdLoc')
	drop proc	dbo.prPatient_UpdLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_UpdPat')
	drop proc	dbo.prRoomBed_UpdPat
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prPatient_Upd')
	drop proc	dbo.prPatient_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prPatient_GetIns')
	drop proc	dbo.prPatient_GetIns
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDoctor_Upd')
	drop proc	dbo.prDoctor_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDoctor_GetIns')
	drop proc	dbo.prDoctor_GetIns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetOne')
	drop proc	dbo.prStaff_GetOne
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBed_InsUpd')
	drop proc	dbo.prCfgBed_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefBed_InsUpd')
	drop proc	dbo.prDefBed_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_A_GetAll')
	drop proc	dbo.prEvent_A_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_A_Get')
	drop proc	dbo.prEvent_A_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetPageable')
	drop proc	dbo.prStaff_GetPageable
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetOnDuty')
	drop proc	dbo.prStaff_GetOnDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByUnit')
	drop proc	dbo.prStaff_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetByUnit')
	drop proc	dbo.prDevice_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetByUnit')
	drop proc	dbo.prCfgStn_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomStaff_Upd')
	drop proc	dbo.prRoomStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_Upd')
	drop proc	dbo.prRoom_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_UpdStaff')
	drop proc	dbo.prRoom_UpdStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetAct')
	drop proc	dbo.prRoom_GetAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_LstAct')
	drop proc	dbo.prRoom_LstAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetAll')
	drop proc	dbo.prRoom_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_GetBtns')
	drop proc	dbo.prCfgDvc_GetBtns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetBtns')
	drop proc	dbo.prCfgStn_GetBtns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfDvc_UpdStf')
	drop proc	dbo.prStfDvc_UpdStf
--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffDvc_UpdStf')
--	drop proc	dbo.prStaffDvc_UpdStf
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_InsUpdDel')
	drop proc	dbo.prStaff_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_sStaff_Upd')
	drop proc	dbo.prStaff_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetAll')
	drop proc	dbo.prStaff_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_LstAct')
	drop proc	dbo.prStaff_LstAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_InsUpd')
	drop proc	dbo.prDvc_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetDvcs')
	drop proc	dbo.prTeam_GetDvcs
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetDvcs')
	drop proc	dbo.pr_User_GetDvcs
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetWiFi')
	drop proc	dbo.prDvc_GetWiFi
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByDial')
	drop proc	dbo.prDvc_GetByDial
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByBC')
	drop proc	dbo.prDvc_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByCode')
	drop proc	dbo.prDvc_GetByCode
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByUnit')
	drop proc	dbo.prDvc_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetTeams')
	drop proc	dbo.prDvc_GetTeams
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetUnits')
	drop proc	dbo.prDvc_GetUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_Imp')
	drop proc	dbo.prDvc_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_Exp')
	drop proc	dbo.prDvc_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_UpdUsr')
	drop proc	dbo.prDvc_UpdUsr
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvcBtn_Ins')
	drop proc	dbo.prCfgDvcBtn_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvcBtn_Clr')
	drop proc	dbo.prCfgDvcBtn_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBtn_Clr')
	drop proc	dbo.prCfgBtn_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBtn_Ins')
	drop proc	dbo.prCfgBtn_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgMst_Ins')
	drop proc	dbo.prCfgMst_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgMst_Clr')
	drop proc	dbo.prCfgMst_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByUnit')
	drop proc	dbo.prStaff_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetByUnit')
	drop proc	dbo.prRoom_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_GetAll')
	drop proc	dbo.prCfgDvc_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetAll')
	drop proc	dbo.prCfgStn_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetByID')
	drop proc	dbo.prDevice_GetByID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_Get')
	drop proc	dbo.prCfgStn_Get
--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_UpdActBySysGID')
--	drop proc	dbo.prDevice_UpdActBySysGID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetRooms')
	drop proc	dbo.prDevice_GetRooms
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetIns')
	drop proc	dbo.prDevice_GetIns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_GetIns')
	drop proc	dbo.prCfgStn_GetIns
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_InsUpd')
	drop proc	dbo.prDevice_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgStn_InsUpd')
	drop proc	dbo.prCfgStn_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetAll')
	drop proc	dbo.prDevice_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetStaffOnDuty')
	drop proc	dbo.prTeam_GetStaffOnDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetStaff')
	drop proc	dbo.prTeam_GetStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUser_Get')
	drop proc	dbo.prTeamUser_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetEmails')
	drop proc	dbo.prTeam_GetEmails
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetUsers')
	drop proc	dbo.prTeam_GetUsers
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetTeams')
	drop proc	dbo.pr_User_GetTeams
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetUnits')
	drop proc	dbo.prTeam_GetUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamPri_InsDel')
	drop proc	dbo.prTeamPri_InsDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_Imp')
	drop proc	dbo.prCall_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetCalls')
	drop proc	dbo.prTeam_GetCalls
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_SetTmpFlt')
	drop proc	dbo.prTeam_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetByUnitPri')
	drop proc	dbo.prTeam_GetByUnitPri
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetByCall')
	drop proc	dbo.prTeam_GetByCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_Exp')
	drop proc	dbo.prTeam_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_Imp')
	drop proc	dbo.prTeam_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetByUnit')
	drop proc	dbo.prTeam_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_InsUpd')
	drop proc	dbo.prTeam_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgLoc_GetByUser')
	drop proc	dbo.prCfgLoc_GetByUser
--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_GetByUser')
--	drop proc	dbo.prUnit_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_GetAll')
	drop proc	dbo.prUnit_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_InsUpd')
	drop proc	dbo.pr_Role_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetUnits')
	drop proc	dbo.pr_Role_GetUnits
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_AccUnit_Set')
	drop proc	dbo.pr_AccUnit_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserUnit_Set')
	drop proc	dbo.pr_UserUnit_Set
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetOne')
	drop proc	dbo.pr_User_GetOne
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetAll')
	drop proc	dbo.pr_User_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetUnits')
	drop proc	dbo.pr_User_GetUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetAll')
	drop proc	dbo.pr_Role_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_RoleUnit_Imp')
	drop proc	dbo.pr_RoleUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_RoleUnit_Exp')
	drop proc	dbo.pr_RoleUnit_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_SetTmpFlt')
	drop proc	dbo.prUnit_SetTmpFlt
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
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCall_Imp')
	drop proc	dbo.prDefCall_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_Upd')
	drop proc	dbo.prCall_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_GetAll')
	drop proc	dbo.prCall_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCall_GetAll')
	drop proc	dbo.prDefCall_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_SetTmpFlt')
	drop proc	dbo.prCfgPri_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_SetTmpFlt')
	drop proc	dbo.prCall_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_SetLvl')
	drop proc	dbo.prCfgPri_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_InsUpd')
	drop proc	dbo.prCfgPri_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_Ins')
	drop proc	dbo.prCfgPri_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCallP_Ins')
	drop proc	dbo.prDefCallP_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_GetAll')
	drop proc	dbo.prCfgPri_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_Clr')
	drop proc	dbo.prCfgPri_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDome_Upd')
	drop proc	dbo.prCfgDome_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDome_GetAll')
	drop proc	dbo.prCfgDome_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgTone_Ins')
	drop proc	dbo.prCfgTone_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgTone_GetAll')
	drop proc	dbo.prCfgTone_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgTone_Clr')
	drop proc	dbo.prCfgTone_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCallP_DelAll')
	drop proc	dbo.prDefCallP_DelAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_GetAll')
	drop proc	dbo.prCfgFlt_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_Ins')
	drop proc	dbo.prCfgFlt_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_Clr')
	drop proc	dbo.prCfgFlt_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_DelAll')
	drop proc	dbo.prCfgFlt_DelAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBed_GetAll')
	drop proc	dbo.prCfgBed_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgBed_GetAct')
	drop proc	dbo.prCfgBed_GetAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefBed_GetAll')
	drop proc	dbo.prDefBed_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_Act')
	drop proc	dbo.pr_Sess_Act
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_Ins')
	drop proc	dbo.pr_Sess_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_GetAll')
	drop proc	dbo.pr_Sess_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Logout')
	drop proc	dbo.pr_User_Logout
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Login2')
	drop proc	dbo.pr_User_Login2
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Login')
	drop proc	dbo.pr_User_Login
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfLvl_Upd')
	drop proc	dbo.prStfLvl_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptUsr_Upd')
	drop proc	dbo.pr_OptUsr_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptSys_Upd')
	drop proc	dbo.pr_OptSys_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Access_GetByUser')
	drop proc	dbo.pr_Access_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Access_GetByRole')
	drop proc	dbo.pr_Access_GetByRole
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Access_InsUpdDel')
	drop proc	dbo.pr_Access_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetPerms')
	drop proc	dbo.pr_Role_GetPerms
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Log_Ins')
	drop proc	dbo.pr_Log_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_LogType_GetAll')
	drop proc	dbo.pr_LogType_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptUsr_GetAll')
	drop proc	dbo.pr_OptUsr_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptSys_GetSmtp')
	drop proc	dbo.pr_OptSys_GetSmtp
--if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptionSys_GetSmtp')
--	drop proc	dbo.pr_OptionSys_GetSmtp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptSys_GetAll')
	drop proc	dbo.pr_OptSys_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_InsDel')
	drop proc	dbo.pr_UserRole_InsDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_Imp')
	drop proc	dbo.pr_UserRole_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_Exp')
	drop proc	dbo.pr_UserRole_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetRoles')
	drop proc	dbo.pr_User_GetRoles
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetUsers')
	drop proc	dbo.pr_Role_GetUsers
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_GetByRole')
	drop proc	dbo.pr_UserRole_GetByRole
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_GetByUser')
	drop proc	dbo.pr_UserRole_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRole_SetTmpFlt')
	drop proc	dbo.prRole_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_Imp')
	drop proc	dbo.pr_Role_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_Exp')
	drop proc	dbo.pr_Role_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_Imp')
	drop proc	dbo.prUser_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_Exp')
	drop proc	dbo.prUser_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Imp')
	drop proc	dbo.pr_User_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Exp')
	drop proc	dbo.pr_User_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfLvl_GetAll')
	drop proc	dbo.prStfLvl_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByStfID')
	drop proc	dbo.prStaff_GetByStfID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByBC')
	drop proc	dbo.pr_User_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByCode')
	drop proc	dbo.pr_User_GetByCode
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetBySID')
	drop proc	dbo.pr_User_GetBySID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Get')
	drop proc	dbo.pr_User_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByBC')
	drop proc	dbo.prStaff_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByCode')
	drop proc	dbo.prStaff_GetByCode
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetBySID')
	drop proc	dbo.prStaff_GetBySID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_Get')
	drop proc	dbo.prStaff_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_sStaff_Upd')
	drop proc	dbo.pr_User_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_UpdStaff')
	drop proc	dbo.pr_User_UpdStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUser_sStaff_Upd')
	drop proc	dbo.prUser_sStaff_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_GetAll')
	drop proc	dbo.pr_Module_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_GetLvl')
	drop proc	dbo.pr_Module_GetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Get')
	drop proc	dbo.pr_Module_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Act')
	drop proc	dbo.pr_Module_Act
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Version_GetAll')
	drop proc	dbo.pr_Version_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Index')
	drop proc	dbo.prHealth_Index
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Table')
	drop proc	dbo.prHealth_Table
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Stats')
	drop proc	dbo.prHealth_Stats
go

--	----------------------------------------------------------------------------
print	'	views'
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwIbedLoc')
	drop view	dbo.vwIbedLoc
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwPatient')
	drop view	dbo.vwPatient
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRoomBed')
	drop view	dbo.vwRoomBed
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRtlsRoom')
	drop view	dbo.vwRtlsRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRtlsBadge')
	drop view	dbo.vwRtlsBadge
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRtlsSnsr')
	drop view	dbo.vwRtlsSnsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRtlsRcvr')
	drop view	dbo.vwRtlsRcvr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStfCvrg')
	drop view	dbo.vwStfCvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStaffCover')
	drop view	dbo.vwStaffCover
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStfAssn')
	drop view	dbo.vwStfAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStaffAssn')
	drop view	dbo.vwStaffAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwUnit')
	drop view	dbo.vwUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwShift')
	drop view	dbo.vwShift
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent41')
	drop view	dbo.vwEvent41
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEventB7')
	drop view	dbo.vwEventB7
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEventB4')
	drop view	dbo.vwEventB4
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent98')
	drop view	dbo.vwEvent98
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent95')
	drop view	dbo.vwEvent95
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent8A')
	drop view	dbo.vwEvent8A
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent84')
	drop view	dbo.vwEvent84
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent_T')
	drop view	dbo.vwEvent_T
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent_D')
	drop view	dbo.vwEvent_D
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent_C')
	drop view	dbo.vwEvent_C
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent_A')
	drop view	dbo.vwEvent_A
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent_S')
	drop view	dbo.vwEvent_S
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent')
	drop view	dbo.vwEvent
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRoomAct')
	drop view	dbo.vwRoomAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRoom')
	drop view	dbo.vwRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDevice')
	drop view	dbo.vwDevice
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCfgStn')
	drop view	dbo.vwCfgStn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDvc')
	drop view	dbo.vwDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStaff')
	drop view	dbo.vwStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDefLoc_CaUnit')
	drop view	dbo.vwDefLoc_CaUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCfgLoc_Cvrg')
	drop view	dbo.vwCfgLoc_Cvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDefLoc_Cvrg')
	drop view	dbo.vwDefLoc_Cvrg
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCall')
	drop view	dbo.vwCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_Sess')
	drop view	dbo.vw_Sess
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_OptUsr')
	drop view	dbo.vw_OptUsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_OptSys')
	drop view	dbo.vw_OptSys
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_Log_S')
	drop view	dbo.vw_Log_S
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_Log')
	drop view	dbo.vw_Log
go

--	----------------------------------------------------------------------------
print	'	tables'
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkCalls')
	drop table	dbo.tbTlkCalls
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkRooms')
	drop table	dbo.tbTlkRooms
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkArea')
	drop table	dbo.tbTlkArea
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkMsg')
	drop table	dbo.tbTlkMsg
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTlkCfg')
	drop table	dbo.tbTlkCfg
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbIbedLoc')
	drop table	dbo.tbIbedLoc
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbHlRoomBed')
	drop table	dbo.tbHlRoomBed
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbHlCall')
	drop table	dbo.tbHlCall
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbSchedule')
	drop table	dbo.tbSchedule
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessShift')
	drop table	dbo.tb_SessShift
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessStaff')
	drop table	dbo.tb_SessStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessUser')
	drop table	dbo.tb_SessUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessDvc')
	drop table	dbo.tb_SessDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessStn')
	drop table	dbo.tb_SessStn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessLog')
	drop table	dbo.tb_SessLog
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessMod')
	drop table	dbo.tb_SessMod
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessLoc')
	drop table	dbo.tb_SessLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessCall')
	drop table	dbo.tb_SessCall
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
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbFilter')
	drop table	dbo.tbFilter
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_RoleRpt')
	drop table	dbo.tb_RoleRpt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_RoleReport')
	drop table	dbo.tb_RoleReport
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbReport')
	drop table	dbo.tbReport
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsRoom')
	drop table	dbo.tbRtlsRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsBadge')
	drop table	dbo.tbRtlsBadge
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsBdgType')
	drop table	dbo.tbRtlsBdgType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsBadgeType')
	drop table	dbo.tbRtlsBadgeType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsSnsr')
	drop table	dbo.tbRtlsSnsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsSnsrType')
	drop table	dbo.tbRtlsSnsrType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsColl')
	drop table	dbo.tbRtlsColl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsRcvrDvc')
	drop table	dbo.tbRtlsRcvrDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsRcvr')
	drop table	dbo.tbRtlsRcvr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsRcvrType')
	drop table	dbo.tbRtlsRcvrType
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfCvrg')
begin
--	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStfAssn_StfCvrg')
			alter table	dbo.tbStfAssn	drop constraint fkStfAssn_StfCvrg
		drop table	dbo.tbStfCvrg
--	commit
end
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffCover')
begin
--	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffAssn_StaffCover')
			alter table	dbo.tbStaffAssn	drop constraint fkStaffAssn_StaffCover
		drop table	dbo.tbStaffCover
--	commit
end
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfAssn')
	drop table	dbo.tbStfAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffAssn')
	drop table	dbo.tbStaffAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRouting')
	drop table	dbo.tbRouting
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbShift')
begin
--	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventD_Shift')
			alter table	dbo.tbEvent_D	drop constraint fkEventD_Shift
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkEventC_Shift')
			alter table	dbo.tbEvent_C	drop constraint fkEventC_Shift
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnit_PrevShift')
			alter table	dbo.tbUnit	drop constraint fkUnit_PrevShift
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnit_CurrShift')
			alter table	dbo.tbUnit	drop constraint fkUnit_CurrShift
		drop table	dbo.tbShift
--	commit
end
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbMstrAcct')
	drop table	dbo.tbMstrAcct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbUnitMapCell')
	drop table	dbo.tbUnitMapCell
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbMapCell')
	drop table	dbo.tbMapCell
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbUnitMap')
	drop table	dbo.tbUnitMap
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent41')
	drop table	dbo.tbEvent41
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbPcsType')
	drop table	dbo.tbPcsType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbNtfType')
	drop table	dbo.tbNtfType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventB7')
	drop table	dbo.tbEventB7
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventB4')
	drop table	dbo.tbEventB4
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventB1')
	drop table	dbo.tbEventB1
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventAB')
	drop table	dbo.tbEventAB
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventA9')
	drop table	dbo.tbEventA9
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventA7')
	drop table	dbo.tbEventA7
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventA3')
	drop table	dbo.tbEventA3
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventA2')
	drop table	dbo.tbEventA2
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventA1')
	drop table	dbo.tbEventA1
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent9B')
	drop table	dbo.tbEvent9B
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent99')
	drop table	dbo.tbEvent99
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent98')
	drop table	dbo.tbEvent98
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent95')
	drop table	dbo.tbEvent95
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent91')
	drop table	dbo.tbEvent91
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent8C')
	drop table	dbo.tbEvent8C
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent8A')
	drop table	dbo.tbEvent8A
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent86')
	drop table	dbo.tbEvent86
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent84')
	drop table	dbo.tbEvent84
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRoomBed')
	drop table	dbo.tbRoomBed
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbPatient')
	drop table	dbo.tbPatient
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDoctor')
	drop table	dbo.tbDoctor
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_T')
	drop table	dbo.tbEvent_T
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_D')
	drop table	dbo.tbEvent_D
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_C')
	drop table	dbo.tbEvent_C
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_P')
	drop table	dbo.tbEvent_P
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_A')
	drop table	dbo.tbEvent_A
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_S')
	drop table	dbo.tbEvent_S
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_B')
	drop table	dbo.tbEvent_B
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent')
begin
--	begin tran
--		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkDevice_Event')
--			alter table	dbo.tbDevice	drop constraint fkDevice_Event
--		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRoomStaff')	and
--			exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoom_Event')
--			alter table	dbo.tbRoomStaff	drop constraint fkRoom_Event
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRoom_Event')
			alter table	dbo.tbRoom		drop constraint fkRoom_Event
		drop table	dbo.tbEvent
--	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRoom')
begin
--	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_User_Room')
			alter table	dbo.tb_User		drop constraint fk_User_Room
		drop table	dbo.tbRoom
--	commit
end
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvcTeam')
	drop table	dbo.tbDvcTeam
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamDvc')
	drop table	dbo.tbTeamDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvcUnit')
	drop table	dbo.tbDvcUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvcUnit')
	drop table	dbo.tbStfDvcUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvc')
	drop table	dbo.tbDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvc')
	drop table	dbo.tbStfDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDvcType')
	drop table	dbo.tbDvcType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfDvcType')
	drop table	dbo.tbStfDvcType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfUnit')
	drop table	dbo.tbStfUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffUnit')
	drop table	dbo.tbStaffUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaff')
	drop table	dbo.tbStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffLvl')
	drop table	dbo.tbStaffLvl
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgDvcBtn')
	drop table	dbo.tbCfgDvcBtn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgBtn')
	drop table	dbo.tbCfgBtn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgMst')
	drop table	dbo.tbCfgMst
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgDvc')
	drop table	dbo.tbCfgDvc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDevice')
	drop table	dbo.tbDevice
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgStn')
	drop table	dbo.tbCfgStn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamStaff')
	drop table	dbo.tbTeamStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_UserTeam')
	drop table	dbo.tb_UserTeam
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamUser')
	drop table	dbo.tbTeamUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamUnit')
	drop table	dbo.tbTeamUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamCall')
	drop table	dbo.tbTeamCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeamPri')
	drop table	dbo.tbTeamPri
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbTeam')
	drop table	dbo.tbTeam
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_UserUnit')
	drop table	dbo.tb_UserUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_RoleUnit')
	drop table	dbo.tb_RoleUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbUnit')
	drop table	dbo.tbUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgLoc')
	drop table	dbo.tbCfgLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefLoc')
	drop table	dbo.tbDefLoc
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCall')
	drop table	dbo.tbCall
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefCall')
	drop table	dbo.tbDefCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgPri')
	drop table	dbo.tbCfgPri
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefCallP')
	drop table	dbo.tbDefCallP
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgDome')
	drop table	dbo.tbCfgDome
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgTone')
	drop table	dbo.tbCfgTone
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgFlt')
	drop table	dbo.tbCfgFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgBed')
	drop table	dbo.tbCfgBed
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefBed')
	drop table	dbo.tbDefBed
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvType')
	drop table	dbo.tbEvType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbDefCmd')
	drop table	dbo.tbDefCmd
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Sess')
	drop table	dbo.tb_Sess
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Log_S')
	drop table	dbo.tb_Log_S
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Log')
	drop table	dbo.tb_Log
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_LogType')
	drop table	dbo.tb_LogType
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Type')
	drop table	dbo.tb_Type
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_OptUsr')
	drop table	dbo.tb_OptUsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_OptionUsr')
	drop table	dbo.tb_OptionUsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_OptSys')
	drop table	dbo.tb_OptSys
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_OptionSys')
	drop table	dbo.tb_OptionSys
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Option')
	drop table	dbo.tb_Option
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_UserRole')
	drop table	dbo.tb_UserRole
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Access')
	drop table	dbo.tb_Access
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Role')
	drop table	dbo.tb_Role
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_User')
	drop table	dbo.tb_User
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStfLvl')
	drop table	dbo.tbStfLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Feature')
	drop table	dbo.tb_Feature
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Module')
	drop table	dbo.tb_Module
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Version')
	drop table	dbo.tb_Version
go

--	============================================================================
print	char(10) + '###	Creating tables..'
go
grant	view database state										to [rWriter]
grant	view database state										to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns # of rows, data and index sizes for all tables in the DB
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8550	* replaced "exec sp_msforeachtable 'sp_spaceused ''?'''" with a direct query
--	7.06.6502	+ @bActive
--	7.06.6499
create proc		dbo.prHealth_Table
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
grant	execute				on dbo.prHealth_Table				to [rWriter]
grant	execute				on dbo.prHealth_Table				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns # of rows, data and index sizes for all tables in the DB
--	7.06.6502
create proc		dbo.prHealth_Index
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
grant	execute				on dbo.prHealth_Index				to [rWriter]
grant	execute				on dbo.prHealth_Index				to [rReader]
go
--	----------------------------------------------------------------------------
--	Database version
--	7.06.5379	* xp_Version(idVersion) -> xp_Version(siBuild)
--				+ xu_Version
--	6.05	+ .siBuild
--	5.02	.idVersion: real -> smallint for precision (FP-math), 5.02 is now stored as 502
--	5.01	.idVersion: smallint -> real to accomodate revision
--			pkVersion -> xp_Version
--	1.00
create table	dbo.tb_Version
(
	idVersion	smallint		not null	-- VVRR format: VV=version, RR=revision
--	-	constraint xp_Version primary key clustered

,	siBuild		smallint		not null	-- build # (build-date - 2000-Jan-01)
		constraint xp_Version primary key clustered		--	7.06.5379

,	dtCreated	smalldatetime	not null
,	dtInstall	smalldatetime	not null
,	sVersion	varchar( 255 )	not null	-- description
)
create unique nonclustered index	xu_Version	on	dbo.tb_Version ( idVersion, siBuild )		--	7.06.5379
go
grant	select							on dbo.tb_Version		to public
go
--	initialize
begin tran
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 101,	4087, '2011-03-11', getdate( ),	'1.01 - initial release' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 201,	4099, '2011-03-23', getdate( ),	'2.01 - devices combined with rooms' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 202,	4108, '2011-04-01', getdate( ),	'2.02 - object permissions set' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 203,	4127, '2011-04-20', getdate( ),	'2.03 - defs extended' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 301,	4128, '2011-04-21', getdate( ),	'3.01 - dst device in tbEvent' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 401,	4148, '2011-05-11', getdate( ),	'4.01 - A5-A7,A8-AC combined, AD-B3 added, cols renamed' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 402,	4161, '2011-05-24', getdate( ),	'4.02 - expiration, session mgmt' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 501,	4185, '2011-06-17', getdate( ),	'5.01 - parent events, 41,B4-B7 added, schema refactored' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 502,	4233, '2011-08-04', getdate( ),	'5.02 - DB versioning revised, DefCmds, DefTypes, .idLoc -> tbEvent.idUnit' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 600,	4254, '2011-08-25', getdate( ),	'6.00 - authentication, authorization, options, schema refactored' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 601,	4281, '2011-09-21', getdate( ),	'6.01 - intermediate' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 602,	4339, '2011-11-18', getdate( ),	'6.02 - 7980 integration, all 790 devices, error logging' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 603,	4391, '2012-02-16', getdate( ),	'6.03 - RTLS integration, fix for all 790 devices' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 604,	4505, '2012-05-02', getdate( ),	'6.04.4505 - 7985/86' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		--	values	( 605,	4626, '2012-08-31', getdate( ),	'6.05.4626 - deadlocks?, event expiration, 7985, 7980' )
			values	( 605,	4644, '2012-09-18', getdate( ),	'6.05.4644 - event expiration, 7985, 7980' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 606,	4645, '2012-09-19', getdate( ),	'6.06.4645 - 1st official release' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 607,	4666, '2012-10-12', getdate( ),	'6.07.4668 - vw_Log, no device matching by name' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 700,	4724, '2012-12-07', getdate( ),	'7.00.4724 - stn-vers; staff levels, devices; auto: stn-units, current shifts' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 701,	4738, '2012-12-21', getdate( ),	'7.01.4738 - rooms w/o beds, assigned staff' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 702,	4779, '2013-01-31', getdate( ),	'7.02.4779 - RTLS presense fix, schema refactored, scheduled reports' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 703,	4891, '2013-05-23', getdate( ),	'7.03.4891 - report scheduler, schema refactored, filters' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 704,	4972, '2013-08-12', getdate( ),	'7.04.4972 - schema refactored, 7980 custom routing, event transactions, expiration' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 705,	5308, '2014-07-14', getdate( ),	'7.05.5308 - schema refactored, 7980 tables replaced, 7980ch replaced' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5396, '2014-10-10', getdate( ),	'+tbEvent_C.idAssn1|2|3, +tbCfgBed.siBed, *xrCallActSum, *xrCallActDtl, +xrCallActExc, *7980cw, *7980ps, *7983rh, *7980rh, *7981cw, *7985cw, *7970as' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5568, '2015-03-31', getdate( ),	'+tbEvent_B, re-activate dvcs' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5659, '2015-06-30', getdate( ),	'module registration, 7981ls: notify only active rooms, 7980: explicit skips, 680 support, 7983ss, 7970as, 7980cw' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5963, '2016-04-29', getdate( ),	'+call tones, +svc event tracing, +Windows 10 support, *AppSuite, +680 support, *7981ls: log rejected, *790 config, *7983rh, *7985cw, *7982cw, *7980cw' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	6106, '2016-09-19', getdate( ),	'+AD support, *7980cw, *798?cs, 798?rh, AppSuite' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	6646, '2018-03-13', getdate( ),	'+798?rh (CallList,ActLog), *7980ns, +tbCfgDome, *7985cw, *7981ls, *7980cw, *7983r' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	6789, '2018-08-03', getdate( ),	'*7983ls, *7983rh, *7980ns, *7980ca, *7980rh, +7987ca, *7981ls' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		--	values	( 706,	6824, '2018-09-07', getdate( ),	'*7983ls, *7983rh, *7980ca, *7987ca' )
			values	( 706,	6897, '2018-11-19', getdate( ),	'*7983ls, *7983rh, *7980ca, *7987ca' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		--	values	( 706,	6974, '2019-02-04', getdate( ),	'*7980ns, *7987ca' )
			values	( 706,	7153, '2019-08-02', getdate( ),	'*7980ns, *7987ca, *798?rh, *7983ls, *798?cs, +7983ds' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7467, '2020-06-11', getdate( ),	'*798?cs, *7981ls, *798?rh, *7980ns, *7981cw, *7980cw, *7985cw, *7982cw, *7986cw' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7531, '2020-08-14', getdate( ),	'*7980ns, *7987ca' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7649, '2020-12-10', getdate( ),	'*798?cs, *7980ns, *7983ls, *798?rh' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7705, '2021-02-04', getdate( ),	'exp' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8321, '2022-10-13', getdate( ),	'single-db' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8508, '2023-04-18', getdate( ),	'RTLS auto-badges, rnd/rmnd, clinic, reporting, RPP 1.09, AD-sync, UI enh' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8769, '2024-01-04', getdate( ),	'EMR integration: +7976is, +7976cw, *db79??, *798?rh, *7980cw, *7985cw, *7981cw' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8882, '2024-04-26', getdate( ),	'*7983ss, *7983rh, *7980cw, *7980ns' )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	9015, '2024-09-06', getdate( ),	'*798?rh, 798?cs*, *7980ns, *7981ls, *7980cw, *7985cw, *7970as' )
--		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
--			values	( 706,	8979, '2024-08-01', getdate( ),	'+7974is' )
commit
go
--	----------------------------------------------------------------------------
--	Returns installation history
--	7.06.8718	* only show dtInstall for the builds, corresponding to upgrade dates
--	7.06.6953	* removed 'db7983.' from object refs
--	7.06.6509
create proc		dbo.pr_Version_GetAll
	with encryption
as
begin
	select	idVersion, v.siBuild, dtCreated, sVersion
		,	case when i.siBuild > 0 then v.dtInstall else null end	as	dtInstall
		,	isnull( i.siBuild, 0 )	as	miBuild
		from	dbo.tb_Version	v	with (nolock)
		left join	(select		dtInstall,	max(siBuild)	as	siBuild
						from	dbo.tb_Version	with (nolock)
						group	by	dtInstall)	i	on	i.siBuild = v.siBuild
		order	by	2	desc
end
go
grant	execute				on dbo.pr_Version_GetAll			to [rWriter]
grant	execute				on dbo.pr_Version_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	App modules
--	7.06.8991	+ .sPath
--	7.06.8873	+ [31,32]
--	7.06.8796	* .sMachine -> .sHost
--				* .sParams -> .sArgs
--	7.06.8573	+ [21,22]
--	7.06.7122	- [71]	+ [94]
--	7.06.7027	+ .iPID
--				* .tiLvl:	60 -> 248	(initial value)
--	7.06.6780	- [65]	+ [131]
--	7.06.6750	+ [65]
--	7.06.6282	+ .tiLvl
--	7.06.5900	+ [60,90]
--	7.06.5560	* [61,62,64,111]
--	7.05.5176	+ [64]
--	7.05.5165	* [61]
--	7.05.5065	* revert:	.dtStarted -> .dtStart (pr_Module_Upd)
--	7.05.5059	* .dtStart -> .dtStarted (pr_Module_Upd)
--				revoke insert,delete
--	7.03	+ [20]
--			+ [93] reactivated
--	7.00	+ [63]
--			+ .dtLastAct
--			* .tiAppType -> .tiModType
--			* .bService -> .bLicense
--	6.07	+ .tiAppType
--	6.05	+ [9,11,12,13,14,15]
--	6.04	+ [8]
--	6.03
create table	dbo.tb_Module
(
	idModule	tinyint			not null
		constraint	xp_Module	primary key clustered

,	sModule		varchar( 16 )	not null	-- IDENT
,	sDesc		varchar( 64 )	null
,	bLicense	bit				not null	-- is licensed (HASP)?
,	tiModType	tinyint			not null	-- bitwise: 1=SqlDb, 2=WinApp, 4=WinSvc, 8=IisApp, 16=WpfApp, 32=Android
,	tiLvl		tinyint			not null	-- bitwise: 1=Sproc, 2=Comm, 4=Debug, 8=Trace, 16=Info, 32=Warn, 64=Error, 128=Fatal
,	sIpAddr		varchar( 40 )	null		-- IPv4 (15) or IPv6 (39) address
,	sHost		varchar( 32 )	null		-- hosting server name
,	sPath		varchar( 255 )	null		-- installed path/URL
,	sVersion	varchar( 16 )	null
,	iPID		int				null		-- Windows PID when running
,	dtStart		datetime		null
,	sArgs		varchar( 255 )	null		-- startup arguments/parameters
,	dtLastAct	datetime		null		-- last activity (while started)
)
go
grant	select, update					on dbo.tb_Module		to [rWriter]
grant	select, update					on dbo.tb_Module		to [rReader]
go
--	initialize
begin tran
--		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc, sVersion, dtStart, sMachine, sParams )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc, sVersion, dtStart, sHost, sArgs, sPath )
			values	(   1, 'J7983db',	1,	248,	1,	'7983 Database [' + db_name( ) + ']', '7.6.9015', getdate( ), @@servername, '@ ' + @@servicename, @@version )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  20, 'J7970as',	4,	248,	0,	'7970 Voice Prompt Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  21, 'J7976is',	4,	248,	0,	'7976 EMR Interface Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  22, 'J7976cw',	2,	248,	0,	'7976 EMR Interface Configurator' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  31, 'J7974is',	4,	248,	0,	'7974 iBed Interface Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  32, 'J7974cw',	2,	248,	0,	'7974 iBed Interface Configurator' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )			--	7.06.5900
			values	(  60, 'J7980cs',	4,	248,	0,	'7980 Config Sync Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  61, 'J7980ns',	4,	248,	0,	'7980/79 Notification Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  62, 'J7980cw',	24,	248,	0,	'7980 Staff Admin Client' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  63, 'J7980rh',	8,	248,	0,	'7980 Staff Admin Website' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  64, 'J7982cw',	24,	248,	0,	'7982 Staff Sign-On' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  72, 'J7981ls',	4,	248,	0,	'7981 RTLS Interface Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  73, 'J7981cw',	2,	248,	0,	'7981 RTLS Interface Configurator' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )			--	7.06.5900
			values	(  90, 'J7983cs',	4,	248,	0,	'7983 Config Sync Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  91, 'J7983ls',	4,	248,	0,	'7983 Event Logging Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  92, 'J7983rh',	8,	248,	0,	'7983 Executive Info System' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )			--	7.03
			values	(  93, 'J7983ss',	4,	248,	0,	'7983 Scheduler Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  94, 'J7983ds',	4,	248,	0,	'7983 Data Sync Service' )				--	7.06.7122
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	( 111, 'J7985cw',	24,	248,	0,	'7985 PC Console Client' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	( 121, 'J7986cw',	2,	248,	0,	'7986 PCC Map Configurator' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	( 131, 'J7987ca',	40,	248,	0,	'7987 Noti-Fi App (Android)' )			--	7.06.6750, 7.06.6780
commit
go
--	----------------------------------------------------------------------------
--	Marks a module with latest activity
--	7.06.8994	+ @idSess
--	7.05.5059	- nocount
--	7.00
create proc		dbo.pr_Module_Act
(
	@idModule	tinyint				-- module id
,	@idSess		int			= null	-- session-id
)
	with encryption
as
begin
--	set	nocount	on
	begin tran

		update	dbo.tb_Module	set	dtLastAct=	getdate( )
			where	idModule = @idModule
		update	dbo.tb_Sess		set	dtLastAct=	getdate( )
			where	idSess	= @idSess

	commit
end
go
grant	execute				on dbo.pr_Module_Act				to [rWriter]
grant	execute				on dbo.pr_Module_Act				to [rReader]
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
		from	dbo.tb_Module	with (nolock)
		where	idModule = @idModule
end
go
grant	execute				on dbo.pr_Module_GetLvl				to [rWriter]
grant	execute				on dbo.pr_Module_GetLvl				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns modules state
--	7.06.8991	+ .sPath
--	7.06.8796	* .sMachine -> .sHost, sHost -> sIpHost
--				* .sParams -> .sArgs
--	7.06.7027	+ .iPID
--	7.06.6284	+ .tiLvl
--	7.06.5785	* .tRunTime -> .dtRunTime
--	7.06.5777	+ .tRunTime
--	7.06.5617	+ .sMachine, .sIpAddr
--	7.06.5395
create proc		dbo.pr_Module_GetAll
(
	@bInstall	bit					-- installed?
,	@bActive	bit					-- running?
)
	with encryption
as
begin
--	set	nocount	on
	select	idModule, sModule, sDesc, bLicense, tiModType, tiLvl, sIpAddr, sHost, sPath, sVersion, iPID, dtStart, sArgs, dtLastAct
		,	case when sHost is null then sIpAddr else sHost end	as	sIpHost
		,	datediff( ss, dtLastAct, getdate( ) )				as	siElapsed
		,	cast( getdate( ) - dtStart as datetime )			as	dtRunTime
		from	dbo.tb_Module	with (nolock)
		where	(@bInstall = 0	or	sIpAddr is not null  or  sHost is not null)
		and		(@bActive = 0	or	dtStart is not null)
end
go
grant	execute				on dbo.pr_Module_GetAll				to [rWriter]
grant	execute				on dbo.pr_Module_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	App module Features
--	7.06.6808	* [62,11] Units->Shifts
--	7.06.5931	* [62,00] Patients->Room-Beds
--	7.06.5661	* [*] expand
--	7.06.5371	+ [62,02], AssnTeams->[62,03]
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
--	initialize
begin tran
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	00,	'Assignments - Room-Beds' )		--	7.06.5931
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	01,	'Assignments - Devices' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	02,	'Assignments - Badges' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	03,	'Assignments - Teams' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	10,	'Administration - Facility' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	11,	'Administration - Shifts' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	12,	'Administration - Roles' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	13,	'Administration - Staff' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	14,	'Administration - Devices' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	15,	'Administration - Badges' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	16,	'Administration - Teams' )
	--	insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  02, 'Report - System Activity' )
	--	insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  03, 'Report - Call Stats (Sum)' )
	--	insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  04, 'Report - Call Stats (Dtl)' )
	--	insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  05, 'Report - Call Activity (Sum)' )
	--	insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  06, 'Report - Call Activity (Dtl)' )
	--	insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  07, 'Report - Staff Assignment' )
	--	insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  08, 'Report - Staff Coverage' )
commit
go
--	----------------------------------------------------------------------------
--	Staff levels
--	7.06.8784	- .iColorB		BG-colors are now taken from corresponding presense call-priorities (Spec=7,8,9)
--				* *StfLvl	-> *Lvl
--	7.06.8426	* [8]		'A' -> '*'
--	7.06.8139	+ .cStfLvl, xuStfLvl
--	7.06.5563	+ [8]
--	7.04.4897	* tbStaffLvl -> tbStfLvl, .idStaffLvl -> .idStfLvl, .sStaffLvl -> .sStfLvl
--	7.01	* .iColorF -> .iColorB
--	7.00
create table	dbo.tbStfLvl
(
	idLvl		tinyint			not null	-- type look-up PK
		constraint	xpStfLvl	primary key clustered

,	cLvl		char( 1 )		not null	-- code
		constraint	xuStfLvl	unique			--	all must be unique
,	sLvl		varchar( 16 )	not null	-- type text
)
--create unique nonclustered index	xuStfLvl			on	dbo.tbStfLvl ( cLvl )
go
grant	select							on dbo.tbStfLvl			to [rWriter]
grant	select							on dbo.tbStfLvl			to [rReader]
go
--	initialize
begin tran
		insert	dbo.tbStfLvl ( idLvl, cLvl, sLvl )		values	(  1, 'Y', 'Yellow' )	--	iColorB, 0xFFFFFF78, 0xFFFFFACD  0xFFFFFF00, 'Aide'
		insert	dbo.tbStfLvl ( idLvl, cLvl, sLvl )		values	(  2, 'O', 'Orange' )	--	iColorB, 0xFFFFA850, 0xFFF5DEB3  0xFFFF8040, 'CNA'
		insert	dbo.tbStfLvl ( idLvl, cLvl, sLvl )		values	(  4, 'G', 'Green' )	--	iColorB, 0xFF78FF78, 0xFF98FB98  0xFF00FF00, 'RN'
		insert	dbo.tbStfLvl ( idLvl, cLvl, sLvl )		values	(  8, 'A', 'STAT' )		--	iColorB, 0xFFFF5050, 0xFFFF4500
commit
go
--	----------------------------------------------------------------------------
--	Returns staff-levels
--	7.06.8784	- .iColorB
--				* idStfLvl	-> idLvl
--				* cStfLvl	-> cLvl
--				* sStfLvl	-> sLvl
--	7.06.8139	+ .cStfLvl
--	7.06.5400
create proc		dbo.prStfLvl_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLvl, cLvl, sLvl
		from	dbo.tbStfLvl	with (nolock)
end
go
grant	execute				on dbo.prStfLvl_GetAll				to [rWriter]
grant	execute				on dbo.prStfLvl_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	App users
--	7.06.8789	* .sBarCode	-> sCode	(xu_User_Act_BarCode -> xu_User_Act_Code)
--	7.06.8784	* .idStfLvl	-> idLvl
--	7.06.8783	* .sStaffID -> sStfID	(xu_User_Act_StaffID -> xu_User_Act_StfID)
--				* .bOnDuty	-> bDuty	(td_User_OnDuty -> td_User_Duty)
--	7.06.8432	* tv_User_Duty:		ony active staff may be ON-duty|on-Break
--	7.06.6814	- .sTeams, .sUnits
--	7.06.6019	+ .bConfig
--				* fkUser_Level -> fk_User_Level
--	7.06.5954	+ xu_User_GUID
--	7.06.5912	+ .gGUID, .utSynched
--	7.06.5567	* xu_User -> xu_User_Login
--	7.06.5428	+ xu_User_Active_BarCode
--				* xu_User_Active_StaffID -> xu_User_Act_StaffID
--	7.05.5220	* .sTeams: vc(32) -> vc(255)
--	7.05.5169	* tdUser_OnDuty -> td_User_OnDuty, tvUser_Name -> tv_User_Name, tvUser_Duty -> tv_User_Duty
--	7.05.5165	+ .dtDue, tvUser_Duty
--	7.05.5121	+ .sUnits
--	7.05.5099	+ .idRoom, .dtEntered
--	7.05.5042	+ .sTeams
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked (tiFails == 0xFF indicates locked-out), td_User_Fails -> td_User_Failed
--	7.04.4939	+ .sBarCode
--	7.04.4919	.idUser: smallint -> int,	.sFirst,.sLast: vc(32) -> vc(16),
--				+ .sMid, .sStaffID, .idStfLvl, .sStaff, .bOnDuty
--	7.00	- td_User_LastAct
--			* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			* .bEnabled -> .bActive
--			set idUser seed to 16:  IDs 1..15 are reserved
--	6.02	+ .dtUpdated
--	6.00	tbRptUser -> tb_User, .idRptUser -> .idUser, xpRptUser -> xp_User, xuRptUser -> xu_User
--	1.08	+ xuRptUser
--	1.00
create table	dbo.tb_User
(
	idUser		int				not null	identity( 16, 1 )
		constraint	xp_User		primary key clustered

,	sUser		varchar( 32 )	not null	-- login-name, lower-cased (forced)
,	iHash		int				not null	-- calculated 32-bit password hash (Murmur2)
,	tiFails		tinyint			not null	-- # of failed log-in attempts, 0xFF == locked-out
		constraint	td_User_Fails	default( 0 )
,	sFrst		varchar( 16 )	null		-- first name
,	sMidd		varchar( 16 )	null		-- middle name
,	sLast		varchar( 16 )	null		-- last name
,	sEmail		varchar( 64 )	null		-- email address
,	sDesc		varchar( 255 )	null		-- description / note / comment
,	dtLastAct	datetime		null		-- last activity (while logged-in)

,	sStfID		varchar( 16 )	null		-- external Staff ID
,	idLvl		tinyint			null		-- 4=Green(Nurse), 2=Orange(CNA), 1=Yellow(Aide)
		constraint	fk_User_Level	foreign key references	tbStfLvl
,	sCode		varchar( 32 )	null		-- bar-code
,	bDuty		bit				not null	-- 1=ON-duty, 0=off-duty|on-Break (if dtDue is not null)
		constraint	td_User_Duty	default( 0 )
,	dtDue		smalldatetime	null		-- due finish break (not null == on-break)
,	sStaff		varchar( 16 )	not null	-- auto: persisted name, formatted by tb_OptSys[11]
,	dtEntered	datetime		null		-- live: when entered the room
,	idRoom		smallint		null		-- live: room look-up FK
	---	constraint	fk_User_Room	foreign key references	tbRoom		(established later)
,	gGUID		uniqueidentifier	null	-- AD GUID
,	utSynched	smalldatetime	null		-- UTC last sync with AD
,	bConfig		bit				not null	-- discovery during AD sync
		constraint	td_User_Config	default( 1 )

,	bActive		bit				not null
		constraint	td_User_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	td_User_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	td_User_Updated	default( getdate( ) )

,	constraint	tv_User_Name	check	( sFrst is not null		or	sMidd is not null	or	sLast is not null )
		--	at least one of {{first|middle|last}} names is required
,	constraint	tv_User_Duty	check	( (bDuty = 0  and  (dtDue is null	or	bActive > 0))	or	(bDuty > 0  and  dtDue is null  and  bActive > 0) )
		--	ony active staff may be ON-duty|on-Break
)
create unique nonclustered index	xu_User_Login			on	dbo.tb_User ( sUser )
		--	all usernames==logins must be unique (including inactive)!!
create unique nonclustered index	xu_User_GUID			on	dbo.tb_User ( gGUID )	where	gGUID is not null
		--	when set, GUIDs must be unique (including inactive)!!
create unique nonclustered index	xu_User_Act_StfID		on	dbo.tb_User ( sStfID )	where	bActive > 0		and	sStfID is not null
		--	when set, Staff-IDs must be unique between active users
--create unique nonclustered index	xu_User_Act_BarCode		on	dbo.tb_User ( sBarCode )	where	bActive > 0	and	sBarCode is not null
create unique nonclustered index	xu_User_Act_Code		on	dbo.tb_User ( sCode )	where	bActive > 0		and	sCode is not null
		--	when set, BarCodes must be unique between active users
go
grant	select, insert, update, delete	on dbo.tb_User			to [rWriter]
grant	select							on dbo.tb_User			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff member by the given ID
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.5430	+ pr_User_Get -> prStaff_Get
--	7.06.5417
create proc		dbo.prStaff_Get
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
grant	execute				on dbo.prStaff_Get					to [rWriter]
grant	execute				on dbo.prStaff_Get					to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff details for given staff-id
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID, @
--	7.06.5429	+ .sStaffID, .bOnDuty, .dtDue
--	7.06.5428	* prStaff_GetByStfID -> prStaff_GetBySID
--	7.05.5185
create proc		dbo.prStaff_GetBySID
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
grant	execute				on dbo.prStaff_GetBySID				to [rWriter]
grant	execute				on dbo.prStaff_GetBySID				to [rReader]
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
grant	execute				on dbo.pr_User_Imp					to [rWriter]
--grant	execute				on dbo.pr_User_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	App roles
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			+ .bActive
--			set idUser seed to 16:  IDs 1..15 are reserved
--	6.02	+ .dtUpdated
--	6.00
create table	dbo.tb_Role
(
	idRole		smallint		not null	identity( 16, 1 )
		constraint	xp_Role		primary key clustered

,	sRole		varchar( 16 )	not null	-- role-name
,	sDesc		varchar( 255 )	not null	-- description

,	s_Role		as	lower( sRole )			-- auto: lower-cased (forced)
		constraint	xu_Role	unique			-- auto-index on automatic field

,	bActive		bit				not null
		constraint	td_Role_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	td_Role_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	td_Role_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tb_Role			to [rWriter]
grant	select							on dbo.tb_Role			to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all roles
--	7.06.5385
create proc		dbo.pr_Role_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idRole, sRole, sDesc, bActive, dtCreated, dtUpdated
		from	dbo.tb_Role		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.pr_Role_Exp					to [rWriter]
grant	execute				on dbo.pr_Role_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a role
--	7.06.5983	* @sDesc: vc(16) -> vc(255)
--	7.06.5385
create proc		dbo.pr_Role_Imp
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
grant	execute				on dbo.pr_Role_Imp					to [rWriter]
--grant	execute				on dbo.pr_Role_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Fills  #tbRole with given idRole-s
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.5380	+ "or	@sRoles = ''"
--	7.06.5354
create proc		dbo.prRole_SetTmpFlt
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
grant	execute				on dbo.prRole_SetTmpFlt				to [rWriter]
grant	execute				on dbo.prRole_SetTmpFlt				to [rReader]
go
--	----------------------------------------------------------------------------
--	App module Feature Permissions by Roles
--	7.05.5059
create table	dbo.tb_Access
(
	idModule	tinyint			not null
--		constraint	fk_Access_Module	foreign key references	tb_Module
,	idFeature	tinyint			not null
--		constraint	fk_Access_Feature	foreign key references	tb_Feature
,	idRole		smallint		not null
		constraint	fk_Access_Role		foreign key references	tb_Role

,	tiAccess	tinyint			not null
--		constraint	td_Access_Access	default( 0 )
,	dtCreated	smalldatetime	not null
		constraint	td_Access_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	td_Access_Updated	default( getdate( ) )

,	constraint	xp_Access		primary key clustered ( idModule, idFeature, idRole )
,	constraint	fk_Access_Feature	foreign key ( idModule, idFeature ) references	tb_Feature
)
go
grant	select, insert, update, delete	on dbo.tb_Access		to [rWriter]
grant	select							on dbo.tb_Access		to [rReader]
go
--	----------------------------------------------------------------------------
--	User-role membership
--	7.04.4919	.idUser: smallint -> int
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.02	+ .dtCreated
--	6.00
create table	dbo.tb_UserRole
(
	idUser		int				not null
		constraint	fk_UserRole_User	foreign key references	tb_User
,	idRole		smallint		not null
		constraint	fk_UserRole_Role	foreign key references	tb_Role

,	dtCreated	smalldatetime	not null
		constraint	td_UserRole_Created	default( getdate( ) )

,	constraint	xp_UserRole		primary key clustered ( idUser, idRole )
)
go
grant	select, insert, update, delete	on dbo.tb_UserRole		to [rWriter]
grant	select							on dbo.tb_UserRole		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns users for a given role
--	7.06.6817	+ order by 2
--	7.06.6807
--	7.06.5417	as	pr_UserRole_GetByRole
create proc		dbo.pr_Role_GetUsers
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
grant	execute				on dbo.pr_Role_GetUsers				to [rWriter]
grant	execute				on dbo.pr_Role_GetUsers				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns roles for a given user
--	7.06.6817	+ order by 2
--	7.06.6807
--	7.06.5417	as	pr_UserRole_GetByUser
create proc		dbo.pr_User_GetRoles
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
grant	execute				on dbo.pr_User_GetRoles				to [rWriter]
grant	execute				on dbo.pr_User_GetRoles				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all user-role combinations
--	7.06.6816	* order by 1
--	7.06.5385
create proc		dbo.pr_UserRole_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idRole, dtCreated
		from	dbo.tb_UserRole		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.pr_UserRole_Exp				to [rWriter]
grant	execute				on dbo.pr_UserRole_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a user-role combination
--	7.06.5385
create proc		dbo.pr_UserRole_Imp
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
grant	execute				on dbo.pr_UserRole_Imp				to [rWriter]
--grant	execute				on dbo.pr_UserRole_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	initialize
begin tran
	set identity_insert	dbo.tb_User	on

		insert	dbo.tb_User ( idUser, sUser, iHash, sFrst, sLast, sEmail, sDesc, sStaff )
			values	( 1, 'sysadm',	1398052681,		'System',	'Administrator',	'support@jeron.com', 'Built-in account for administering the system.',	'System Admin' )

		insert	dbo.tb_User ( idUser, sUser, iHash, sFrst, sLast, sEmail, sDesc, sStaff )			--	1603527090
			values	( 2, 'admin',	-89734999,		'Facility',	'Administrator',	'support@jeron.com', 'Built-in account for administering the system.',	'Facility Admin' )

		insert	dbo.tb_User ( idUser, sUser, iHash, sFrst, sLast, sEmail, sDesc, sStaff )			--	1084166086
			values	( 3, 'user',	-582600978,		'Sample',	'User',				'support@jeron.com', 'Built-in account for demonstrating the system.',	'Sample User' )

		insert	dbo.tb_User ( idUser, sUser, iHash, sFrst, sLast, sEmail, sDesc, sStaff )
			values	( 4, 'system',	-1571697235,	'System',	'Internal',			'support@jeron.com', 'Built-in account for internal application usage.', 'System User' )

	set identity_insert	dbo.tb_User	off
commit
go
begin tran
	set identity_insert	dbo.tb_Role	on

		insert	dbo.tb_Role ( idRole, sRole, sDesc )
			values	( 1, 'Public',	'Built-in role that automatically includes every user.  Access granted to this role is inherited by everybody.' )	--	7.05.5254

		insert	dbo.tb_Role ( idRole, sRole, sDesc )
			values	( 2, 'Admins',	'Built-in role whose members have complete and unrestricted access to all units and components'' features.' )		--	7.05.5254

	set identity_insert	dbo.tb_Role	off
commit
go
begin tran

		insert	dbo.tb_UserRole ( idUser, idRole )
			select	idUser, 1	from	dbo.tb_User

		insert	dbo.tb_UserRole ( idUser, idRole )
			select	idUser, 2	from	dbo.tb_User		where	idUser in ( 1, 2 )
/*
--	if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 1 and idRole = 1)
		insert	dbo.tb_UserRole ( idUser, idRole )	values	( 1, 1 )
--	if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 1 and idRole = 2)
		insert	dbo.tb_UserRole ( idUser, idRole )	values	( 1, 2 )
--	if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 2 and idRole = 1)
		insert	dbo.tb_UserRole ( idUser, idRole )	values	( 2, 1 )
--	if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 2 and idRole = 2)
		insert	dbo.tb_UserRole ( idUser, idRole )	values	( 2, 2 )
--	if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 3 and idRole = 1)
		insert	dbo.tb_UserRole ( idUser, idRole )	values	( 3, 1 )
--	if	not	exists	(select 1 from dbo.tb_UserRole where idUser = 3 and idRole = 1)
		insert	dbo.tb_UserRole ( idUser, idRole )	values	( 4, 1 )
*/
commit
go
begin tran
--	if	not	exists	(select 1 from dbo.tb_Access where idRole = 2)
		insert	dbo.tb_Access	( idModule, idFeature, idRole, tiAccess )
			select	idModule, idFeature, 2, 1
				from	dbo.tb_Feature
commit
go
--	----------------------------------------------------------------------------
--	Option definitions
--	7.06.8978	+ [70]
--				* [55..56]
--	7.06.8888	+ [60..65]
--	7.06.8725	+ [55..56]
--	7.06.8711	+ [50..54]
--	7.06.8588	+ [41..49]
--	7.06.8270	+ [39]
--	7.06.8237	+ [38]
--	7.06.7293	- [38,39],	* [38]->[31], [39]->[26]
--	7.06.7292	- [6,8],	* [26]->[6], [31]->[8], [11]<->[19]
--	7.06.6808	+ [40]
--	7.06.6778	+ [39]
--	7.06.6290	* [31] redefined
--	7.06.6088	* [31] reserved
--	7.06.5934	+ [38]
--	7.06.5924	+ [37]
--	7.06.5913	* [5]
--	7.06.5869	+ [31-36]
--	7.06.5868	+ [29,30]
--	7.06.5665	* [8]
--	7.06.5526	+ [27]
--	7.06.5466	+ [26]
--	7.05.5235	+ [21-25]
--	7.05.5218	+ [20]
--	7.05.5169	+ [19]
--	7.05.5095	* [5] redefined
--	7.05.5002	+ [18]
--	7.03	+ [12-17]	* [5-10]
--	6.05	+ [8,9,10]
--	6.04	* [7]
--	6.03	+ [6,7]
--	6.00
create table	dbo.tb_Option
(
	idOption	tinyint			not null
		constraint	xp_Option	primary key clustered

,	sOption		varchar( 64 )	not null	-- option text
,	tiDatatype	tinyint			not null	-- == sys_type_id: 56=int, 62=float, 61=datetime, 167=varchar
)
go
grant	select							on dbo.tb_Option		to [rWriter]
grant	select							on dbo.tb_Option		to [rReader]
go
--	initialize
--	if	not	exists	(select 1 from dbo.tb_Option where idOption > 0)
begin tran
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  1,  56, 'Session timeout, m' )
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  2,  56, 'Failed log-ins before lock-out' )
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  3, 167, 'Date format' )
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  4, 167, 'Time format' )
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  5,  56, '(internal) Gateway IP-mask' )				--	7.05.5095	.5913
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  6, 167, 'Logs folder path (''\''-terminated)' )		--	6.04	--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  6, 167, '(internal) Allowed Systems' )				--	7.06.5466,	.7292
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  7,  56, '(internal) Event recording mode' )			--	6.03	--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  7,  56, '(internal) Aux data keep-window, d' )		--	6.03	--	7.03
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  8,  56, '(internal) Trace/Debug mode' )				--	6.05	--	7.03	--	7.06.5665,	.7292
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  8,  56, '(internal) Call healing interval, s' )		--	7.06.5869,	.6088,	.6290,	.7292
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	(  9,  56, '(internal) Nrm expiration window, s' )		--	6.05	--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 10,  56, '(internal) Ext expiration window, s' )		--	6.05	--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 11,  56, '(internal) Last processed idEvent' )		--	7.05.5169
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 12, 167, 'SMTP host' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 13,  56, 'SMTP port' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 14,  56, 'SMTP TLS?' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 15, 167, 'SMTP user' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 16, 167, 'SMTP pass' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 17, 167, 'SMTP from' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 18,  56, 'Enable Remote Presence?' )					--	7.05.5002
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 19,  56, 'Staff full name format' )					--	6.05
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 20,  56, 'Announce cancellations to' )				--	7.05.5218
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 21,  56, '(internal) Call answered Tout, s' )			--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 22,  56, '(internal) STAT need OT, s' )				--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 23,  56, '(internal) Grn need OT, s' )				--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 24,  56, '(internal) Ora need OT, s' )				--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 25,  56, '(internal) Yel need OT, s' )				--	7.05.5235
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 26, 167, '(internal) Allowed Systems' )				--	7.06.5466,	.7292
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 26,  56, 'Default level for new staff' )				--	7.06.6778,	.7292
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 27,  56, 'Sign-On reset interval, s' )				--	7.06.5526
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 28,  56, 'Sign-On dbl-scan clears assignment?' )		--	7.06.5526
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 29,  61, 'Default Voice TRT for tCall.tVoTrg' )		--	7.06.5868
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 30,  61, 'Default Staff TRT for tCall.tStTrg' )		--	7.06.5868
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 31,  56, '(internal) Presence healing, sec' )			--	7.06.5869,	.6088,	.6290,	.7292
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 31,  61, 'Default shift start time' )					--	7.06.5934,	.6778,	.7292
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 32, 167, 'Active Directory root domain' )				--	7.06.5869
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 33, 167, 'Active Directory 790-group name' )			--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 33, 167, 'Active Directory 790-group GUID' )			--	7.06.5924
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 34,  56, 'Active Directory LDAP port' )				--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 35, 167, 'Active Directory sync user' )				--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 36, 167, 'Active Directory sync pass' )				--	7.06.5869
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 37, 167, 'Active Directory 790-group GUID' )			--	7.06.5924
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 37, 167, 'Active Directory 790-group name' )			--	7.06.5869
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 38,  61, 'Default shift start time' )					--	7.06.5934,	.6778,	.7292
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 39,  56, 'Default staff level' )						--	7.06.6778,	.7292
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 38, 167, 'Facility Time Zone' )						--	7.06.8237
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 39,  56, 'RTLS mode: auto-assign?' )					--	7.06.8270

		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 40,  56, 'Data refresh interval, s' )					--	7.06.6808
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 41,  56, 'EMR retry send interval, s' )				--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 42, 167, 'HL7 version' )								--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 43, 167, 'HL7 message delimiters' )					--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 44, 167, 'HL7 message envelope - beg' )				--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 45, 167, 'HL7 message envelope - end' )				--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 46, 167, 'HL7 sending app' )							--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 47, 167, 'HL7 sending facility' )						--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 48, 167, 'HL7 receiving app' )						--	7.06.8588
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 49, 167, 'HL7 receiving facility' )					--	7.06.8588

		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 50,  56, '(internal) DB recovery model' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 51,  56, '(internal) Data size, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 52,  56, '(internal) Data used, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 53,  56, '(internal) Tlog size, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 54,  56, '(internal) Tlog used, ext' )				--	7.06.8711
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 55,  61, '(internal) Data last bkup' )				--	7.06.8725	.8978
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 56,  61, '(internal) Tlog last bkup' )				--	7.06.8725	.8978

		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 60, 167, 'Stryker iBed date/time format' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 61,  56, 'Stryker iBed data discard age, s' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 62,  56, 'Stryker iBed expiration age, s' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 63,  56, 'Stryker iBed attributes to track' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 64,  56, 'Stryker iBed fowler min' )			--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 65,  56, 'Stryker iBed fowler max' )			--	7.06.8888

		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 70,  56, 'Show JavaScript alerts()?' )				--	7.06.8978
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 51, 167, 'EMR host' )									--	7.06.8588
	--	insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 52,  56, 'EMR port' )									--	7.06.8588
commit
go
--	----------------------------------------------------------------------------
--	System-wide options
--	7.06.8978	+ [70]
--	7.06.8888	+ [60..65]
--	7.06.8725	+ [55..56]
--	7.06.8711	+ [50..54]
--	7.06.8588	+ [41..49]
--	7.06.8270	+ [39]
--	7.06.8237	+ [38]
--	7.06.7293	- [38,39],	* [38]->[31], [39]->[26]
--	7.06.7292	- [6,8],	* [26]->[6], [31]->[8], [11]<->[19]
--	7.06.6808	+ [40]
--	7.06.6778	+ [39]
--	7.06.6778	* [20]
--	7.06.5934	+ [38]
--	7.06.5924	+ [37]
--	7.06.5869	+ [31-36]
--	7.06.5868	+ [29,30] tbCall.tVoTrg, .tStTrg defaults
--	7.06.5694	* [9] default: 30 -> 60, high-volume traffic scenario increases healing interval 1.5x on 790 side
--				  [10] default: 60 -> 90
--	7.06.5618	* [7] default: 0 -> 30, semantics reversed
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.00
create table	dbo.tb_OptSys
(
	idOption	tinyint			not null
		constraint	xp_OptSys	primary key clustered
		constraint	fk_OptSys_Option	foreign key references tb_Option

,	iValue		int				null		-- option value
,	fValue		float			null		-- option value
,	tValue		datetime		null		-- option value
,	sValue		varchar( 255 )	null		-- option value

,	dtUpdated	smalldatetime not null	
		constraint	td_OptSys_Updated	default( getdate( ) )

,	constraint	vc_OptSys_Value	check ( iValue is not null	or fValue is not null	or tValue is not null	or sValue is not null )
)
go
grant	select,	update					on dbo.tb_OptSys		to [rWriter]
grant	select,	update					on dbo.tb_OptSys		to [rReader]
go
--	initialize
--	if	not	exists	(select 1 from dbo.tb_OptSys where idOption > 0)
begin tran
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 1, 5 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 2, 5 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 3, 'yyyy-MMM-dd' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 4, 'HH:mm:ss' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 5, 0 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 6, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 7, 30 )	--	0=purge all, N=remove aux events data older than N days, 0xFF=keep everything
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 8, 30 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 9, 60 )	--	30, 45, 60 [75, 90, 120]?	cannot be lower than 30s (790's call healing time is 28s)
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 10, 90 )	--	60, 75, 90 [120, 150, 180, 210, 240, 270, 300]?	cannot be lower than OptionSys[9]
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 11, 0 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 12, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 13, 25 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 14, 0 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 15, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 16, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 17, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 18, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 19, 0 )	--	0=F L, 1=L, F, ..
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 20, 0x0E )	--	0=none, [1=badge], 2=pager, 4=phone, 8=wi-fi, 14=pager|phone|wi-fi
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 21, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 22, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 23, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 24, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 25, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 26, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 27, 20 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 28, 1 )
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 29, '00:01:00' )	--	tbCall.tVoTrg default
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 30, '00:02:00' )	--	tbCall.tStTrg default
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 31, '07:00:00' )	--	tbShift.tBeg default
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 32, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 33, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 34, 0 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 35, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 36, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 37, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 38, 'Central Standard Time' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 39, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 40, 15 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 41, 5 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 42, '2.6' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 43, '|^~\&' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 44, '0B' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 45, '1C0D' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 46, 'JERON_PROVIDER^020B3CFFFED56AA9^EUI-64' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 47, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 48, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 49, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 50, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 51, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 52, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 53, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 54, 0 )
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 55, '1900-01-01' )
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 56, '1900-01-01' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 60, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 61, 660 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 62, 60 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 63, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 64, -1 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 65, 91 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 70, 0 )
commit
go
--	----------------------------------------------------------------------------
--	7.06.5399
create view		dbo.vw_OptSys
	with encryption
as
	select	v.idOption, o.sOption, o.tiDatatype, v.iValue, v.fValue, v.tValue, v.sValue, v.dtUpdated
		from	dbo.tb_OptSys	v	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption	= v.idOption
go
grant	select							on dbo.vw_OptSys		to [rWriter]
grant	select							on dbo.vw_OptSys		to [rReader]
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
		from	dbo.tb_OptSys	with (nolock)
end
go
grant	execute				on dbo.pr_OptSys_GetAll				to [rWriter]
grant	execute				on dbo.pr_OptSys_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates DB stats (# of Size and Used pages - for data and tlog)
--	7.06.8978	+ data/tlog auto-growth
--	7.06.8959	* swapped recovery-model and service-name
--	7.06.8796	* .sMachine -> .sHost
--				* .sParams -> .sArgs
--	7.06.8725	+ recovery_model
--				+ last backup dates
--	7.06.8712
create proc		dbo.prHealth_Stats
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@iRM		int
		,		@iSizeD		int
		,		@iGrowD		int
		,		@cGrowD		varchar( 1 )
		,		@iUsedD		int
		,		@iSizeL		int
		,		@iGrowL		int
		,		@cGrowL		varchar( 1 )
		,		@iUsedL		int
		,		@dBkupD		datetime
		,		@dBkupL		datetime

	set	nocount	on

	select	@iSizeD =	size,	@iGrowD =	growth,	@cGrowD =	case when is_percent_growth > 0 then '%' else '' end,	@iUsedD =	cast(fileproperty(name, 'spaceused') as int)
		from	sys.database_files	with (nolock)
		where	[type] = 0													-- .mdf

	select	@iSizeL =	size,	@iGrowL =	growth,	@cGrowL =	case when is_percent_growth > 0 then '%' else '' end,	@iUsedL =	cast(fileproperty(name, 'spaceused') as int)
		from	sys.database_files	with (nolock)
		where	[type] = 1													-- .ldf

	select	@s =	cast(cast(@iSizeD / 128.0 as decimal(18,1)) as varchar) + '+' + cast(@iGrowD / 128 as varchar) + @cGrowD + '|'
				+	cast(cast(@iUsedD * 100.0 / @iSizeD as decimal(18)) as varchar) + '% / '
				+	cast(cast(@iSizeL / 128.0 as decimal(18,1)) as varchar) + '+' + cast(@iGrowL / 128 as varchar) + @cGrowL + '|'
				+	cast(cast(@iUsedL * 100.0 / @iSizeL as decimal(18)) as varchar) + '% ['
				+	lower(recovery_model_desc) + '] @' + @@servicename
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
grant	execute				on dbo.prHealth_Stats				to [rWriter]
grant	execute				on dbo.prHealth_Stats				to [rReader]
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
--	User options
--	7.04.4919	.idUser: smallint -> int
--	7.04.4896	* tb_OptionUsr -> tb_OptUsr
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.00
create table	dbo.tb_OptUsr
(
	idOption	tinyint			not null
		constraint	fk_OptUsr_Option	foreign key references tb_Option
,	idUser		int				not null
		constraint	fk_OptUsr_User		foreign key references tb_User

,	iValue		int				null		-- option value
,	fValue		float			null		-- option value
,	tValue		datetime		null		-- option value
,	sValue		varchar( 255 )	null		-- option value

,	dtUpdated	smalldatetime	not null
		constraint	td_OptUsr_Updated	default( getdate( ) )

,	constraint	xp_OptUsr	primary key clustered ( idUser, idOption )
,	constraint	vc_OptUsr_Value	check ( iValue is not null	or fValue is not null	or tValue is not null	or sValue is not null )
)
go
grant	select,	update					on dbo.tb_OptUsr		to [rWriter]
grant	select,	update					on dbo.tb_OptUsr		to [rReader]
go
--	initialize
/*
if	not	exists	(select 1 from dbo.tb_OptUsr where idOption > 0)
begin
	begin tran
		insert	dbo.tb_OptUsr ( idUser, idOption, sValue )	values	( 1, 3, 'yyyy-MMM-dd' )
		insert	dbo.tb_OptUsr ( idUser, idOption, sValue )	values	( 1, 4, 'HH:mm:ss' )
		insert	dbo.tb_OptUsr ( idUser, idOption, sValue )	values	( 2, 3, 'yyyy-MMM-dd' )
		insert	dbo.tb_OptUsr ( idUser, idOption, sValue )	values	( 2, 4, 'HH:mm:ss' )
	commit
end
*/
go
--	----------------------------------------------------------------------------
--	7.06.5399
create view		dbo.vw_OptUsr
	with encryption
as
	select	v.idOption, o.sOption, o.tiDatatype, v.iValue, v.fValue, v.tValue, v.sValue, v.dtUpdated, v.idUser, u.sUser
		from	dbo.tb_OptUsr	v	with (nolock)
		join	dbo.tb_Option	o	with (nolock)	on	o.idOption	= v.idOption
		join	dbo.tb_User		u	with (nolock)	on	u.idUser	= v.idUser
go
grant	select							on dbo.vw_OptUsr		to [rWriter]
grant	select							on dbo.vw_OptUsr		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all settings, overriding system defaults with user-specific values
--	7.06.7390
create proc		dbo.pr_OptUsr_GetAll
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
grant	execute				on dbo.pr_OptUsr_GetAll				to [rWriter]
grant	execute				on dbo.pr_OptUsr_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	User-audit-log and 790-event entry types
--	7.06.8993	* [222-228].sType
--	7.06.8965	* [41-45,70-79,82].tiCat, .tiLvl
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8399	* [many].sLogType
--	7.06.8059	* [79].tiLvl:	16 -> 8,
--				* [79].sLogType
--	7.06.7508	* [44].tiLvl:	16 -> 4
--				* [44,45].tiCat:	32 -> 16
--				* [44,46,48].sLogType
--	7.06.7432	* [83].tiCat:	4 -> 16
--	7.06.7289	* [48].tiLvl:	16 -> 8
--	7.06.7146	* [41,42,44,48].tiLvl:	8 -> 16
--	7.06.7142	* [228].tiLvl:	32 -> 64
--	7.06.7138	* [46].tiLvl:	8 -> 16
--	7.06.7129	+ [100-103]
--	7.06.7123	* .tiLvl bumped to match Audit.EnLvl
--				* .tiSrc -> .tiCat
--				- [51]
--	7.06.7104	+ [83]
--	7.06.6787	+ [228]
--	7.06.6767	* [34]
--				+ [210,211],
--				* 206 -> 210, 207 -> 211
--				* [205..207]
--	7.06.6710	+ [218-220]
--				* [230] -> 'Log-out (forced)'
--	7.06.6459	+ [226,227]
--	7.06.6284	+ [64]
--	7.06.6053	* [81].tiLvl:	8 -> 32
--	7.06.5914	+ [76]
--	7.06.5701	* [39] tiLvl:	4 -> 8
--	7.06.5652	* [62].tiLvl:	4 -> 8
--	7.06.5651	* [90].tiLvl:	2 -> 4
--	7.06.5613	* [82].tiLvl:	8 -> 16
--	7.06.5598	+ [63]
--	7.06.5596	* [44,46,48]
--	7.06.5415	* [247]: tiLvl= 4->8
--	7.05.5233	+ [249]
--	7.05.5204	+ [194]
--	7.05.5147	* [82] -> 'Invalid data'
--	7.05.5095	+ [204],	* [203]
--	7.05.5066	* [80,81]
--	7.05.5065	+ [206,207]
--	7.05.5045	* [33,38,39,61,62] 'Service' -> 'Component', 'Module' -> 'Component'
--	7.05.5021	+ [247,248]
--	7.05.4980	+ [82]
--	7.05.4975	.tiLevel -> .tiLvl, tiSource -> tiSrc
--	7.03	* [231,236]
--			+ [34,35,90]
--	7.02	* [80,81].tiSource: 32 -> 16
--	7.00	+ [62], * [61].tiSource: 2 -> 1
--	6.05	.tiLevel, .tiSource bumped to allow bitwise combining for retrieval filters
--	6.03
create table	dbo.tb_LogType
(
	idType		tinyint			not null	-- type look-up PK
		constraint	xp_LogType	primary key clustered
,	tiLvl		tinyint			not null	-- 1=Sproc, 2=Comm, 4=Debug, 8=Trace, 16=Info, 32=Warn, 64=Error, 128=Fatal
,	tiCat		tinyint			not null	-- 1=General, 2=Service, 4=Auth, 8=Admin, 16=Comm, 32=Data, 64=Apps

,	sType		varchar( 32 )	not null	-- type text
)
go
grant	select							on dbo.tb_LogType		to [rWriter]
grant	select							on dbo.tb_LogType		to [rReader]
go
--	initialize
begin tran
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	(  0,	4,	1,	'Internal' )				--	6.04
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	(  1,	8,	1,	'Trace' )					--	6.05
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	(  2,	16,	1,	'Info' )									--	rmation
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	(  4,	32,	1,	'Warning' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	(  8,	64,	1,	'Error' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 16,  128,	1,	'Critical' )
	---	insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 32,	64,	1,	'reserved' )

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 33,	8,	2,	'Stats' )					--	7.05.5045				Component 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 34,	8,	2,	'Active' )					--	7.03, 7.06.6767			Service 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 35,	8,	2,	'Asleep' )					--	7.03					Service 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 36,	16,	2,	'Paused' )					--	7.06.8133				Service 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 38,	16,	2,	'Started' )					--	7.05.5045				Component 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 39,	32,	2,	'Stopped' )					--	7.05.5045, 7.06.5701	Component 
	--	insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 40,	16,	2,	'Paused' )											--	Service 

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 41,	16,	64,	'790 data imported (config load)' )	--	7.06.7146
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 42,	16,	64,	'790 data imported (at run-time)' )	--	7.06.7146
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 43,	32,	32,	'790 data error' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 44,	4,	32,	'HL7 data' )				--	6.04, 7.06.7146, .7508
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 45,	32,	32,	'HL7 data error' )			--	6.04
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 46,	16,	32,	'7980 data' )				--	7.06.7138, .7508
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 47,	32,	32,	'7980 data error' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 48,	8,	32,	'RTLS data' )				--	7.06.7146,	.7289, .7508
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 49,	32,	32,	'RTLS data error' )

	--	insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 51,	16,	4,	'MasterAccount ins/upd' )	--	6.04

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 61,	16,	1,	'Installed' )				--	6.05, 7.00, 7.05.5045		Component 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 62,	32,	1,	'Removed' )					--	7.00, 7.05.5045, 7.06.5652	Component 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 63,	16,	1,	'License' )					--	7.06.5598					Component 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 64,	16,	1,	'Updated' )					--	7.06.6284					Component 

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 70,	32,	32,	'Config edit' )				--	6.05	Changed
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 71,	4,	32,	'Cfg: dbg' )				--	6.05	definition
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 72,	4,	32,	'Cfg: call' )				--	6.05	definition
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 73,	8,	32,	'Cfg: loc' )				--	6.05	definition
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 74,	4,	32,	'Cfg: stn' )				--	6.05	definition
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 75,	8,	32,	'Cfg: room' )				--	7.02	definition
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 76,	4,	32,	'Cfg: btn' )				--	7.06.5914	definition
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 79,	16,	32,	'Config data' )				--	6.05, 7.06.8059

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 80,	16,	16,	'Connected' )				--	6.05, 7.02, 7.05.5066
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 81,	64,	16,	'Conn. lost' )				--	6.05, 7.02, 7.05.5066, 7.06.6053	 connection
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 82,	64,	32,	'Invalid data' )			--	7.05.4980, 7.05.5147, 7.06.5613
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 83,	16,	16,	'Disconnected' )			--	7.06.7104

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 90,	16,	2,	'Exec Schedule' )			--	7.03, 7.06.5651

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 100,	16,	8,	'AD operation' )			--	7.06.7128
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 101,	8,	8,	'AD: skipped' )				--	7.06.7128
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 102,	8,	8,	'AD: inserted' )			--	7.06.7128
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 103,	8,	8,	'AD: updated' )				--	7.06.7128
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 104,	8,	8,	'AD: no change' )			--	7.06.7251

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 189,	16,	16,	'GW found' )				--	6.04	ateway
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 190,	32,	16,	'GW lost' )					--	6.04	ateway
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 191,	4,	16,	'Call Placed' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 192,	4,	16,	'Call Escalated' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 193,	4,	16,	'Call Cancelled' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 194,	4,	16,	'Call Healing' )			--	7.05.5204
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 195,	4,	16,	'Audio Requested' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 196,	4,	16,	'Audio Busy' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 197,	4,	16,	'Audio Connected' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 198,	4,	16,	'Audio Dialed' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 199,	4,	16,	'Audio Cancelled' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 201,	4,	16,	'Service Set' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 202,	4,	16,	'Service Set/Clr' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 203,	4,	16,	'Service Clr' )				--	7.05.5095
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 204,	4,	16,	'Phone Action' )			--	7.05.5095
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 205,	4,	16,	'Pager Action' )			--	7.05.5095, 7.06.6767
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 206,	4,	16,	'Wi-Fi Action' )			--	7.06.6767
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 207,	4,	16,	'Badge Action' )			--	7.06.6767

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 210,	4,	16,	'Presence - In' )			--	7.05.5064 [206], 7.06.6767
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 211,	4,	16,	'Presence - Out' )			--	7.05.5064 [207], 7.06.6767

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 218,	16,	4,	'ON duty' )					--	7.06.6710	Went 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 219,	16,	4,	'on break' )				--	7.06.6710	Went 
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 220,	16,	4,	'off duty' )				--	7.06.6710	Went 

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 221,	16,	4,	'Log-in' )					-- successful
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 222,	32,	4,	'Auth failed (usr)' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 223,	32,	4,	'Auth failed (pwd)' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 224,	32,	4,	'Auth failed (lck)' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 225,	32,	4,	'Auth failed (dis)' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 226,	32,	4,	'Auth failed (dvc)' )		--	7.06.6459
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 227,	32,	4,	'Auth failed (ind)' )		--	7.06.6459
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 228,	64,	4,	'Auth failed (lic)' )		--	7.06.6787
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 229,	16,	4,	'Log-out' )					-- (explicit)
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 230,	16,	4,	'Log-out (forced)' )

		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 231,	32,	8,	'Upd settings (usr)' )		--	7.03
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 236,	32,	8,	'Upd settings (sys)' )		--	7.03
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 237,	16,	8,	'User created' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 238,	32,	8,	'User updated' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 239,	32,	8,	'User unlocked' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 240,	32,	8,	'User enabled' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 241,	32,	8,	'User disabled' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 242,	16,	8,	'Role created' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 243,	32,	8,	'Role updated' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 244,	32,	8,	'Role members' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 245,	32,	8,	'Role enabled' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 246,	32,	8,	'Role disabled' )
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 247,	16,	8,	'Record created' )			--	7.05.5021, 7.06.5415,	.8472
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 248,	32,	8,	'Record updated' )			--	7.05.5021
		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( 249,	32,	8,	'Record deleted' )			--	7.05.5233

---		insert	dbo.tb_LogType ( idType, tiLvl, tiCat, sType )	values	( , , , '' )
commit
go
--	----------------------------------------------------------------------------
--	Returns details for all log-types
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.7123	* tb_LogType.tiSrc -> .tiCat
--	7.06.6555
create proc		dbo.pr_LogType_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idType, tiLvl, tiCat, sType
		from	dbo.tb_LogType		with (nolock)
end
go
grant	execute				on dbo.pr_LogType_GetAll			to [rWriter]
grant	execute				on dbo.pr_LogType_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Audit log
--	7.06.8802	* .idLogType -> idType, @
--				* fk_Log_LogType -> fk_Log_Type
--	7.06.8797	+ .utLog
--	7.06.8705	* modified IDENT_SEED (1 -> 0x80000000 == -2147483648) - only for new installs
--	7.06.6498	+ .tLast, tiQty
--	7.06.6304	- .idOper
--	7.06.6298	+ .idModule
--	7.04.4919	.idUser: smallint -> int
--	6.05	tb_Log.sLog widened to [512]
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.00
create table	dbo.tb_Log
(
	idLog		int				not null	identity( -2147483648, 1 )		--	ID has to be spelled in decimal, 0x80000000 == min int32,	(bigint == int64 later)
		constraint	xp_Log	primary key clustered

,	utLog		datetime		not null	-- auto: UTC date-time
		constraint	td_Log_UTC		default( getutcdate( ) )
,	dtLog		datetime		not null
--,	idLogType	tinyint			not null	-- type look-up FK
,	idType		tinyint			not null	-- type look-up FK
		constraint	fk_Log_Type		foreign key references	tb_LogType
,	idModule	tinyint			null		-- module performing the action	--	7.06.6298
		constraint	fk_Log_Module	foreign key references	tb_Module
,	dLog		date			not null	-- date
,	tLog		time( 3 )		not null	-- time of first occurence
,	tiHH		tinyint			not null	-- HH (hour)
,	tLast		time( 3 )		not null	-- time of last occurence
,	tiQty		tinyint			not null	-- count of same entry, repeated within the hour

,	idUser		int				null		-- user performing the action
		constraint	fk_Log_User		foreign key references	tb_User
--,	idOper		int				null		-- operand user					--	7.06.6304
--		constraint	fk_Log_Oper		foreign key references	tb_User
,	sLog		varchar( 512 )	not null	-- description
)
go
grant	select, insert					on dbo.tb_Log			to [rWriter]
grant	select, insert					on dbo.tb_Log			to [rReader]
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
create view		dbo.vw_Log
	with encryption
as
	select	l.idLog, l.utLog, l.dtLog, l.dLog, l.tLog, l.idType, t.sType, l.idModule, m.sModule, l.sLog, l.tLast, l.tiQty, l.idUser, u.sUser
		from	dbo.tb_Log		l	with (nolock)
		join	dbo.tb_LogType	t	with (nolock)	on t.idType		= l.idType
	left join	dbo.tb_Module	m	with (nolock)	on m.idModule	= l.idModule
	left join	dbo.tb_User		u	with (nolock)	on u.idUser		= l.idUser
go
grant	select							on dbo.vw_Log			to [rWriter]
grant	select							on dbo.vw_Log			to [rReader]
go
--	----------------------------------------------------------------------------
--	Log statistics by date and hour
--	7.06.6498
create table	dbo.tb_Log_S
(
	dLog		date			not null	-- date
,	tiHH		tinyint			not null	-- HH (hour)

,	idLog		int				not null	-- 1st Event in this hour FK (no enforcement)
--		constraint	fk_LogS_Log		foreign key references	tb_Log
,	siCrt		smallint		not null	-- count of criticals within the hour
		constraint	td_LogS_Crt		default( 0 )
,	siErr		smallint		not null	-- count of errors within the hour
		constraint	td_LogS_Err		default( 0 )
--,	siWrn		smallint		not null	-- count of warnings within the hour
--		constraint	td_LogS_Wrn		default( 0 )

	constraint	xp_Log_S	primary key clustered	( dLog, tiHH )
)
go
grant	select, insert, update			on dbo.tb_Log_S			to [rWriter]
grant	select							on dbo.tb_Log_S			to [rReader]
go
--	----------------------------------------------------------------------------
--	Log statistics by hour
--	7.06.6498
create view		dbo.vw_Log_S
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
grant	select							on dbo.vw_Log_S			to [rWriter]
grant	select							on dbo.vw_Log_S			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
--	7.06.8802	* .idLogType -> idType, @
--				* .sLogType -> sType, @
--	7.06.8797	* stub:		real definition follows that of [dbo.prEvent_Ins]
create proc		dbo.pr_Log_Ins
(
--	@idLogType	tinyint
	@idType		tinyint
,	@idUser		int						--	context user
,	@idOper		int						--	"operand" user - ignored now
,	@sLog		varchar( 512 )
,	@idModule	tinyint			=	1	--	default is J798?db
--,	@idLog		int out
)
	with encryption
as
begin
	return	0
/*	declare		@dt			datetime
			,	@dd			date
			,	@hh			tinyint
			,	@tiLvl		tinyint
			,	@tiCat		tinyint
			,	@idLog		int
			,	@idOrg		int
	declare		@idEvent	int
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
--		,		@idCmd		tinyint

	set	nocount	on

	select	@tiLvl =	tiLvl,		@tiCat =	tiCat,	--	@idCmd =	0,
			@dt =	getdate( ),		@dd =	getdate( ),		@hh =	datepart( hh, getdate( ) )
		from	dbo.tb_LogType	with (nolock)
		where	idLogType = @idLogType

--	set	nocount	off

	if	0 < @tiLvl & 0xC0													-- err (64) + crit (128)
	begin
		select	@idOrg =	idLog											-- get 1st event of the hour
			from	dbo.tb_Log_S	with (nolock)
			where	dLog = cast(@dt as date)	and	tiHH = @hh

		if	0 < @idOrg
			select	@idLog =	idLog										-- find 1st occurence of "sLog"
				from	dbo.tb_Log		with (nolock)
				where	idLog >= @idOrg
				and		sLog = @sLog
	end

	begin	tran

		if	0 < @tiLvl & 0xC0	and		0 < @idLog							-- same crit/err already happened
			update	dbo.tb_Log	set	tLast=	@dt
							,	tiQty=	case when tiQty < 255 then tiQty + 1 else tiQty end
				where	idLog = @idLog
		else
		begin
				insert	dbo.tb_Log	(  idLogType,  idModule,  idUser,  sLog,	dtLog,	dLog,	tLog,	tiHH,	tLast,	tiQty )
						values		( @idLogType, @idModule, @idUser, @sLog,	@dt,	@dt,	@dt,	@hh,	@dt,	1 )
				select	@idLog =	scope_identity( )

				set transaction isolation level serializable
				begin	tran
					if	not	exists( select 1 from dbo.tb_Log_S with (updlock) where dLog = @dd and tiHH = @hh )
						insert	dbo.tb_Log_S	( dLog,	tiHH, idLog )
								values			( @dt,	@hh, @idLog )
				commit

/ *				select	@idOrg =	null									-- update event statistics
				select	@idOrg =	idLog
					from	tb_Log_S	with (nolock)
					where	dLog = cast(@dt as date)	and	tiHH = @hh

				if	@idOrg	is null
					insert	tb_Log_S	( dLog,	tiHH, idLog )
							values		( @dt,	@hh, @idLog )
* /		end

		if	0 < @tiLvl & 0x80												-- increment criticals
			update	dbo.tb_Log_S	set	siCrt=	siCrt + 1
				where	dLog = @dd	and	tiHH = @hh

		if	0 < @tiLvl & 0x40												-- increment errors
			update	dbo.tb_Log_S	set	siErr=	siErr + 1
				where	dLog = @dd	and	tiHH = @hh

/ *		if	@idLogType	between	4  and 40	or								-- wrn,err,crit + all service states
			@idLogType	between	61 and 64	or								-- install/removal
			@idLogType	in (70,79,80,81,83,90)	or							-- config, conn, schedules
			@idLogType	between	100 and 104	or								-- AD
--	-		@idLogType	between	189 and 190	or								-- GW - handled by prEvent_SetGwState
			@idLogType	between	218 and 255									-- user: duty, log-in/out, activity
		begin
--			if	@idLogType	between	189 and 190
--				select	@idCmd =	0x83

			exec	dbo.prEvent_Ins		0, null, @idLog, null	---	@idCmd, @tiLen, @iHash, @vbCmd
					,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
					,	null, null, null, null, null, @sLog		---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
					,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
					,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0
		end
* /
	commit
*/
end
go
grant	execute				on dbo.pr_Log_Ins					to [rWriter]		--	7.01
grant	execute				on dbo.pr_Log_Ins					to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns access permissions for a given role, combined by modules
--	7.05.5234
create proc		dbo.pr_Role_GetPerms
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
grant	execute				on dbo.pr_Role_GetPerms				to [rWriter]
grant	execute				on dbo.pr_Role_GetPerms				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts, updates or deletes an access permission
--	7.06.8965	* optimized logging
--	7.06.8846	* fix 'dbo.dbo.tb_Access'
--	7.06.7279	* optimized logging
--	7.05.5234
create proc		dbo.pr_Access_InsUpdDel
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

--	select	@s= 'm=' + isnull(cast(@idModule as varchar), '?') + ', f=' + isnull(cast(@idFeature as varchar), '?') +
--				', r=' + isnull(cast(@idRole as varchar), '?') + ', a=' + isnull(cast(@tiAccess as varchar), '?') + ' )'
	select	@s= 'Acc( ' + isnull(cast(@idModule as varchar), '?') + ', ' + isnull(cast(@idFeature as varchar), '?') +
				', ' + isnull(cast(@idRole as varchar), '?') + ', ' + isnull(cast(@tiAccess as varchar), '?') + ' )'
	begin	tran

		if	@tiAccess > 0
		begin
			if	not exists	(select 1 from dbo.tb_Access where idModule = @idModule and idFeature = @idFeature and idRole = @idRole)
			begin
				select	@idType=	247,	@s =	@s + '+'
--				select	@s= 'Acc_I( ' + @s,	@idType=	247

				insert	dbo.tb_Access	(  idModule,  idFeature,  idRole,  tiAccess )
						values			( @idModule, @idFeature, @idRole, @tiAccess )
			end
			else
			begin
				select	@idType=	248,	@s =	@s + '*'
--				select	@s= 'Acc_U( ' + @s,	@idType=	248

				update	dbo.tb_Access	set	dtUpdated=	getdate( ),	tiAccess =	@tiAccess
					where	idModule = @idModule	and idFeature	= @idFeature	and idRole	= @idRole
			end
		end
		else
		begin
				select	@idType=	249,	@s =	@s + '-'
--				select	@s= 'Acc_D( ' + @s,	@idType=	249

				delete	from	dbo.tb_Access
					where	idModule = @idModule	and idFeature	= @idFeature	and idRole	= @idRole
		end

		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s

	commit
end
go
grant	execute				on dbo.pr_Access_InsUpdDel			to [rWriter]
grant	execute				on dbo.pr_Access_InsUpdDel			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns access permissions for a given role
--	7.05.5234
create proc		dbo.pr_Access_GetByRole
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
grant	execute				on dbo.pr_Access_GetByRole			to [rWriter]
grant	execute				on dbo.pr_Access_GetByRole			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns access permissions for a given role
--	7.06.8789	* optimized
--	7.05.5248
create proc		dbo.pr_Access_GetByUser
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
grant	execute				on dbo.pr_Access_GetByUser			to [rWriter]
grant	execute				on dbo.pr_Access_GetByUser			to [rReader]
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
create proc		dbo.pr_OptSys_Upd
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
grant	execute				on dbo.pr_OptSys_Upd				to [rWriter]
grant	execute				on dbo.pr_OptSys_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates and logs user setting
--	7.06.8978	* optimized
--	7.06.7390	+ added removal when matches tb_OptSys
--	7.06.6751	* optimized log (sys.fn_varbintohexstr -> convert(varbinary))
--	7.06.5596	+ hex for ints
--	7.05.5071	* @idOption: smallint -> tinyint
--				+ where idOption =
--				* @idUser: smallint -> int
--	7.04.4898
create proc		dbo.pr_OptUsr_Upd
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

			select	@s= '[' + isnull(cast(@idOption as varchar), '?') + '] '

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
grant	execute				on dbo.pr_OptUsr_Upd				to [rWriter]
grant	execute				on dbo.pr_OptUsr_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a staff level
--	7.06.8965	* optimized logging
--	7.06.8784	- .iColorB
--				* idStfLvl	-> idLvl, @
--				* cStfLvl	-> cLvl, @
--				* sStfLvl	-> sLvl, @
--	7.06.8504	+ skip tracing internal sync
--	7.06.8139	+ .cStfLvl
--	7.06.7279	* optimized logging
--	7.06.7115	* optimized logging (color in hex)
--	7.05.5219
create proc		dbo.prStfLvl_Upd
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

	select	@s =	'StfLvl( ' + isnull(cast(@idLvl as varchar), '?') + '| ' + @cLvl + ': "' + @sLvl + '" )'

	begin	tran

		update	dbo.tbStfLvl	set	cLvl =	@cLvl,	sLvl =	@sLvl
			where	idLvl = @idLvl

		if	ascii(@cLvl) < 0xF0												-- skip internal sync
			exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
end
go
grant	execute				on dbo.prStfLvl_Upd					to [rWriter]
grant	execute				on dbo.prStfLvl_Upd					to [rReader]
go
--	----------------------------------------------------------------------------
--	App module User sessions
--	7.06.8796	* .sMachine -> .sHost, @
--	7.05.5059	+ .idModule
--				* tb_Sess_User -> fk_Sess_User, tb_Sess_LastAct -> td_Sess_LastAct, tb_Sess_Created -> td_Sess_Created
--	7.04.4919	.idUser: smallint -> int
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.00	tbRptSess -> tb_Sess, .idRptSess -> .idSess, xpRptSess -> xp_Sess, xuRptSess -> xu_Sess
--			revised field order, datatypes, sizes
--	4.02	+ .sMachine, .tiLocal (prRptSess_Ins)
--	3.01	+ .dtLastAct, xuRptSess
--	1.07	+ .sBrowser (prRptSess_Ins)
--	1.06
create table	dbo.tb_Sess
(
	idSess		int				not null	identity( 1, 1 )
		constraint	xp_Sess		primary key clustered

,	sSessID		varchar( 32 )	not null	-- IIS SessionID / App SessID

,	idModule	tinyint			not null
		constraint	fk_Sess_Module	foreign key references	tb_Module
,	idUser		int				null		-- session user
		constraint	fk_Sess_User	foreign key references	tb_User
,	sIpAddr		varchar( 40 )	not null	-- IPv4 (15) or IPv6 (39) address
--,	sMachine	varchar( 32 )	null		-- client computer's name
,	sHost		varchar( 32 )	null		-- client computer's name
,	bLocal		bit				not null	-- is client local? (e.g. 127.0.0.1)
,	sBrowser	varchar( 255 )	null		-- browser IDENT-string

,	dtLastAct	datetime		not null	-- last activity
		constraint	td_Sess_LastAct	default( getdate( ) )
,	dtCreated	datetime		not null
		constraint	td_Sess_Created	default( getdate( ) )
)
create unique nonclustered index	xu_Sess		on	dbo.tb_Sess ( sSessID )
		--	all session IDs must be unique!!
go
grant	select, insert, update, delete	on dbo.tb_Sess			to [rWriter]		--	7.01
grant	select, insert, update, delete	on dbo.tb_Sess			to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8796	* .sMachine -> .sHost, @
--	7.06.8993	+ bAdmin
--	7.06.5399
create view		dbo.vw_Sess
	with encryption
as
	select	s.idSess, s.dtCreated, s.sSessID, s.idModule, m.sModule, s.idUser, u.sUser, s.sIpAddr, s.sHost, s.bLocal, s.dtLastAct, s.sBrowser
		,	cast(case when 	r.idRole is null	then 0	else 1	end	as	bit)	as	bAdmin
		from	dbo.tb_Sess		s	with (nolock)
		join	dbo.tb_Module	m	with (nolock)	on	m.idModule	= s.idModule
	left join	dbo.tb_User		u	with (nolock)	on	u.idUser	= s.idUser
	left join	dbo.tb_UserRole	r	with (nolock)	on	r.idUser	= s.idUser	and	r.idRole	= 2
go
grant	select							on dbo.vw_Sess			to [rWriter]
grant	select							on dbo.vw_Sess			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all sessions in order of creation (ID)
--	7.06.8993	+ bAdmin
--	7.06.8796	* .sMachine -> .sHost, @
--	7.06.5399
create proc		dbo.pr_Sess_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idSess, dtCreated, sSessID, idModule, sModule, idUser, sUser, sIpAddr, sHost, bLocal, dtLastAct, sBrowser, bAdmin
		from	dbo.vw_Sess		with (nolock)
		order	by	1 desc
end
go
grant	execute				on dbo.pr_Sess_GetAll				to [rWriter]
grant	execute				on dbo.pr_Sess_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a new session
--	7.06.8972	* optimized logging
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
create proc		dbo.pr_Sess_Ins
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
		,		@s			varchar( 512 )

	set	nocount	on

	if	0 < len( @sBrowser )
	begin
		select	@tiLog =	patindex('% (built %', @sBrowser)
		select	@s =	case when	0 < @tiLog	then	substring( @sBrowser, 1, @tiLog - 1 )	else	@sBrowser	end
	end

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1	--	!DB module!

	select	@s =	'Sess( ''' + isnull(@sSessID,'?') + ''', ' + isnull(cast(@idUser as varchar),'?')+ ', ' + isnull(cast(@sIpAddr as varchar),'?') + '| ' + isnull(@sHost,'?') +
					case when @bLocal > 0 then '*' else '' end + ', "' + isnull(cast(@s as varchar(64)),'?') + '" ) '

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
grant	execute				on dbo.pr_Sess_Ins					to [rWriter]		--	7.01
grant	execute				on dbo.pr_Sess_Ins					to [rReader]
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
create proc		dbo.pr_Sess_Act
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
grant	execute				on dbo.pr_Sess_Act					to [rWriter]		--	7.01
grant	execute				on dbo.pr_Sess_Act					to [rReader]
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	7.06.8993	+ added "	or	sStfID = @sUser"
--	7.06.8966	+ check for @idModule (=> @idSess too) being null
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
create proc		dbo.pr_User_Login
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

	select	@s =	'@ ' + isnull(@sHost,'?') + ' (' + isnull(@sIpAddr,'?') + ')'

	select	@idUser =	idUser,		@iHass =	iHash,	@bActive=	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff,		@sStfID =	sStfID
		from	dbo.tb_User		with (nolock)
		where	sUser = lower(@sUser)	or	sStfID = @sUser

	if	@idModule is null		--	IIS issue (login.aspx refresh?)
	begin
		select	@idType =	4,		@s =	@s + ', "' + isnull(@sUser,'?') + '" [' + isnull(cast(@idSess as varchar),'?') + ']'
		exec	dbo.pr_Log_Ins	@idType, @idUser, null, @s, 1
		return	@idType
	end

	if	@idUser is null			--	wrong user
	begin
		select	@idType =	222,	@s =	@s + ', "' + isnull(@sUser,'?') + '"'
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
		select	@idType =	223,	@s =	@s + ', attempt ' + cast(@tiFails + 1 as varchar)

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

	select	@idType =	221,	@s =	@s + ' [' + cast(@idSess as varchar ) + ']',	@bAdmin =	0

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
grant	execute				on dbo.pr_User_Login				to [rWriter]		--	7.01
grant	execute				on dbo.pr_User_Login				to [rReader]
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
create proc		dbo.pr_User_Login2
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
grant	execute				on dbo.pr_User_Login2				to [rWriter]
grant	execute				on dbo.pr_User_Login2				to [rReader]
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
create proc		dbo.pr_User_Logout
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
		from	dbo.tb_Sess		with (nolock)
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
grant	execute				on dbo.pr_User_Logout				to [rWriter]		--	7.01
grant	execute				on dbo.pr_User_Logout				to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating definition tables..'
go
--	----------------------------------------------------------------------------
--	J790 Command definitions
--	7.06.6774	+ [4B], * [41]
--	7.06.5386	+ [C6,DC-DF]
--	7.05.5095	+ [40,42-44,C2-C5]
--	7.02	* [BA-C1]
--	6.04	* [0]
--	6.02	+ [0]
--	5.02	+ [B8-B9]
--	5.01	+ [B4-B7,41]
--	1.00
create table	dbo.tbDefCmd
(
	idCmd		tinyint not null			-- command look-up PK
		constraint	xpDefCmd	primary key clustered

,	sCmd		varchar( 32 ) not null		-- command text
)
---	create unique index	xuDefCmd on dbo.tbDefCmd ( sCmd )
go
grant	select							on dbo.tbDefCmd			to [rWriter]
grant	select							on dbo.tbDefCmd			to [rReader]
go
--	initialize
begin tran
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x00, 'internal' )							--	6.02, 6.04

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x40, '790 config changed' )					--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x41, 'pager activity' )						--	5.01, 7.06.6774
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x42, '7980 data changed' )					--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x43, 'phone activity' )						--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x44, 'hl7 notification' )					--	7.05.5095
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x45, 'app-id/keep-alive' )					--	7.06.6774
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x46, 'app-id/licensed' )						--	7.06.6774
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x49, 'event changed' )						--	7.06.6774
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x4A, 'service changed' )						--	7.06.6774
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x4B, 'wi-fi activity' )						--	7.06.6774

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x81, 'stop polling request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x83, 'station health' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x84, 'call status' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x85, 'versus status' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x86, 'request station discovery' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x87, 'assign station id' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x8F, 'unconfigured device found' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x88, 'audio busy' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x89, 'audio connect request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x8A, 'audio connect grant' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x8D, 'audio quit' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x8C, 'set patient station outputs' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x8E, 'rcv patient station input status' )

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x90, 'request local config' )
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x91, 'local config data' )
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x92, 'element select (patient station)' )
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x93, 'change global config banks' )
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x94, 'auto config device' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x95, 'set/clr service request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x96, 'call upgrade request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x97, 'patient details request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x98, 'patient details response' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x9A, 'set patient details' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x99, 'set 3-p''s status' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x9B, 'time sync' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x9C, 'write nv station flags' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x9D, 'query room number' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x9E, 'room number response' )

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA0, 'set time/date' )
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA1, 'request mode/shift' )
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA2, 'mode/shift status' )
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA3, 'set mode/shift' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA4, 'set/clr bed flags' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA5, 'request swing room match' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA6, 'swing room status' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA7, 'change swing room status' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA8, 'night transfer info request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xA9, 'night transfer take request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xAA, 'night transfer take grant' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xAB, 'night transfer info' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xAC, 'write night transfer status' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xAD, 'set remote volume' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xAE, 'query device' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xAF, 'device response' )

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB0, 'group page request' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB1, 'group page grant' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB2, 'group page busy' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB3, 'group page quit' )
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB4, 'badge presence' )						--	5.01
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB5, 'remote place call' )					--	5.01
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB6, 'request staff list' )					--	5.01
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB7, 'staff list response' )					--	5.01
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB8, 'staff assigned to bed response' )		--	5.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xB9, 'remote audio connect request' )		--	5.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBA, 'remote rnd/rmnd status request' )		--	7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBB, 'remote rnd/rmnd status response' )		--	7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBC, 'remote rnd/rmnd status set/clr' )		--	7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBD, 'remote audio quit request' )			--	7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBE, 'staff details request' )				--	7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xBF, 'staff details response' )				--	7.02

		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC0, 'station code version request' )		--	7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC1, 'station code version response' )		--	7.02
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC2, 'ringback status' )						--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC3, 'exit semi-privacy' )					--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC4, 'advanced diagnostics response' )		--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC5, 'advanced diagnostics request' )		--	7.05.5095
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC6, 'set remote device audio mode' )		--	7.06.5386

	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDC, 'GID alias' )							--	7.06.5386
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDD, 'test fixtr set outputs' )				--	7.06.5386
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDE, 'test fixtr input status request' )		--	7.06.5386
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDF, 'test fixtr input status response' )	--	7.06.5386
commit
go
--	----------------------------------------------------------------------------
--	Bed designators (790 global configuration)
--	7.06.5330	+ .siBed
--	7.05.4976	* .bInUse -> .bActive, tdCfgBed_InUse -> tdCfgBed_Active
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.02	+ .dtCreated, .dtUpdated, .tiUse -> .bInUse
--	2.03	+ .tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	2.02
create table	dbo.tbCfgBed
(
	tiBed		tinyint			not null	-- bed-index
		constraint	xpCfgBed	primary key clustered

,	cBed		char( 1 )		not null	-- bed-name
,	cDial		char( 1 )		not null	-- dialable number (digits only)
--,	bInUse		bit				not null	-- in-use indicator
--		constraint	tdCfgBed_InUse		default( 0 )
,	siBed		smallint		not null	-- bed-flag (bit index)

,	bActive		bit				not null
		constraint	tdCfgBed_Active		default( 0 )
,	dtCreated	smalldatetime	not null
		constraint	tdCfgBed_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdCfgBed_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tbCfgBed			to [rWriter]
grant	select							on dbo.tbCfgBed			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all|active beds
--	7.06.5409	+ .siBed
--	7.05.4976	+ @bActive
--	7.04.4892	* tbDefBed -> tbCfgBed,	.idIdx -> .tiBed
create proc		dbo.prCfgBed_GetAll
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
grant	execute				on dbo.prCfgBed_GetAll				to [rWriter]
grant	execute				on dbo.prCfgBed_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Filter definitions (790 global configuration)
--	7.03
create table	dbo.tbCfgFlt
(
	idIdx		tinyint			not null	-- filter idx
		constraint	xpCfgFlt	primary key clustered

,	iFilter		int				not null	-- filter bits
,	sFilter		varchar( 16 )	not null	-- filter name
)
go
grant	select, insert, update, delete	on dbo.tbCfgFlt			to [rWriter]
grant	select							on dbo.tbCfgFlt			to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all filter definitions
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5914	* optimized
--	7.04.4898	* prCfgFlt_DelAll -> prCfgFlt_Clr
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgFlt_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	dbo.tbCfgFlt
		select	@s =	'Flt( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgFlt_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a filter definition
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	7.06.5914	* optimized
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgFlt_Ins
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

	select	@s =	'Flt( ' + isnull(cast(@idIdx as varchar), '?') + ', ' + convert(varchar, convert(varbinary(4), @iFilter), 1) +
					', "' + isnull(@sFilter, '?') + '" )'	-- + isnull(cast(@iFilter as varchar), '?')

	begin	tran

		insert	dbo.tbCfgFlt	(  idIdx,  iFilter,  sFilter )
				values			( @idIdx, @iFilter, @sFilter )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgFlt_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all filter definitions
--	7.03
create proc		dbo.prCfgFlt_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idIdx, iFilter, sFilter
		from	dbo.tbCfgFlt	with (nolock)
end
go
grant	execute				on dbo.prCfgFlt_GetAll				to [rWriter]
grant	execute				on dbo.prCfgFlt_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Tone definitions (790 global configuration)
--	7.06.6177	* .dtCreated -> .dtUpdated
--	7.06.5694	+ .dtCreated
--	7.06.5687
create table	dbo.tbCfgTone
(
	tiTone		tinyint			not null	-- tone idx
		constraint	xpCfgTone	primary key clustered

,	sTone		varchar( 16 )	not null	-- tone name
,	vbTone		varbinary(max)	null		-- audio (uLaw-encoded)

,	dtUpdated	smalldatetime	not null	
		constraint	tdCfgTone_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tbCfgTone		to [rWriter]
grant	select							on dbo.tbCfgTone		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns tones, ordered to be loadable into a table
--	7.06.6177	* .dtCreated -> .dtUpdated
--	7.06.5694	+ .dtCreated, .tLen
--	7.06.5687
create proc		dbo.prCfgTone_GetAll
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
grant	execute				on dbo.prCfgTone_GetAll				to [rWriter]
grant	execute				on dbo.prCfgTone_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a tone definition
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	7.06.5914	* optimized
--	7.06.5687
create proc		dbo.prCfgTone_Ins
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

	select	@s =	'Tone( ' + isnull(cast(@tiTone as varchar), '?') +
					', ' + isnull(cast(cast(dateadd(ms, cast(len(@vbTone) as int)/8, '0:0:0') as time(3)) as varchar) + '|' + cast(len(@vbTone) as varchar), '?') +
					', "' + isnull(@sTone, '?') + '" )'

	begin	tran

		insert	dbo.tbCfgTone	(  tiTone,  sTone,  vbTone )
				values			( @tiTone, @sTone, @vbTone )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgTone_Ins				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Dome Light Show definitions (790 global configuration)
--	7.06.6184	+ .tiPrism
--	7.06.6177
create table	dbo.tbCfgDome
(
	tiDome		tinyint			not null	-- dome light show idx
		constraint	xpCfgDome	primary key clustered

,	iLight0		int				not null	-- bytes 0-3
,	iLight1		int				not null	-- bytes 4-7
,	iLight2		int				not null	-- bytes 8-11
--,	iLight3		int				not null	-- bytes 12-16 (reserved)

,	tiPrism		tinyint			not null	-- prism segments (bitwise: 8=T, 4=U, 2=L, 1=B)
,	iPrism0		int				not null	-- bytes 0-3
,	iPrism1		int				not null	-- bytes 4-7
,	iPrism2		int				not null	-- bytes 8-11
,	iPrism3		int				not null	-- bytes 12-16
,	iPrism4		int				not null	-- bytes 17-20
,	iPrism5		int				not null	-- bytes 21-23
--,	iPrism6		int				not null	-- bytes 24-27 (reserved)
--,	iPrism7		int				not null	-- bytes 28-31 (reserved)

,	dtUpdated	smalldatetime not null	
		constraint	tdCfgDome_Updated	default( getdate( ) )
)
go
grant	select, update					on dbo.tbCfgDome		to [rWriter]		--	, insert, delete
grant	select							on dbo.tbCfgDome		to [rReader]
go
--	initialize
begin tran
		declare	@siDome		smallint
		select	@siDome =	0
		while	@siDome <= 255
		begin
			insert	tbCfgDome	(  tiDome, iLight0, iLight1, iLight2, tiPrism, iPrism0, iPrism1, iPrism2, iPrism3, iPrism4, iPrism5 )
					values		( @siDome, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
			select	@siDome =	@siDome + 1
		end
commit
go
--	----------------------------------------------------------------------------
--	Returns Dome Light Show definitions, ordered to be loadable into a table
--	7.06.8272	* output order
--	7.06.6184	+ .tiPrism, sPrism
--	7.06.6177
create proc		dbo.prCfgDome_GetAll
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
grant	execute				on dbo.prCfgDome_GetAll				to [rWriter]
grant	execute				on dbo.prCfgDome_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a Dome Light Show definition
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6751	* optimized log (sys.fn_varbintohexstr -> convert(varbinary))
--	7.06.6186	* .tiPrism value ('<> 0' for highest bit - SQL doesn't have unsigned integers)
--	7.06.6185	* .tiPrism value
--	7.06.6184	+ .tiPrism, sPrism
--	7.06.6177
create proc		dbo.prCfgDome_Upd
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

	select	@s =	'Dome( ' + right('00' + isnull(cast(@tiDome as varchar), '?'), 3) + ', ' + convert(varchar, convert(varbinary(4), @iLight0), 1) + ' ' +
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

		if	@tiLog & 0x06 = 6												--	Config & Debug?
--		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgDome_Upd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Call priorities (790 global configuration)
--	7.06.8343	* .tiFlags -> .siFlags,	.tiOtInt -> .tiIntOt, .tiToneInt -> .tiIntTn
--				- .tiLvl
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--				* .iFilter -> not null
--	7.06.7647	- xtCfgPri_tiLvl
--	7.06.7641	* .tiLvl:	bit values changed		(prCfgPri_InsUpd,	.7864: prEvent_Ins, prEvent84_Ins)
--	7.06.7627	+ xtCfgPri_tiLvl
--	7.06.7619	* .tiLvl:	+ 16,32,64
--	7.06.6340	+ .tiLvl
--	7.06.6177	* .tiLight -> .tiDome
--				+ fkCfgPri_Dome
--	7.06.5914	* .dtCreated -> .dtUpdated
--	7.06.5687	+ .siIdxUg, .siIdxOt, .tiOtInt, .tiLight, .tiTone, .tiToneInt
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.04.4892	* tbDefCallP -> tbCfgPri
--	7.03	//* .iColorF,.iColorB,.iFilter -> not null
--			+ .iFilter
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.03	+ .iColorF, .iColorB
--	6.02	+ .dtCreated
--	2.02
create table	dbo.tbCfgPri
(
	siIdx		smallint		not null	-- priority-index
		constraint	xpCfgPri	primary key clustered

,	sCall		varchar( 16 )	not null	-- priority-text
,	siFlags		smallint		not null	-- bitwise:	x80=Reserved, x40=G-cancel, x20=O-cancel, x10=Y-cancel, x08=Rnd/Rmnd, x04=Control, x02=Enabled, x01=Locking
											--			x8000=Regular, x4000=Failure, x2000=Present, x1000=Rnd-Init, x0900=Clin-Doc, x0500=Clin-Stf, x0300=Clin-Pat, x0100=Clinic
,	tiShelf		tinyint			not null	-- 0=Invisible, 1=Routine, 2=Urgent, 3=Emergency, 4=Code
,	tiColor		tinyint			not null	-- FG/BG color index
,	iFilter		int				not null	-- priority filter-mask
,	tiSpec		tinyint			null		-- special priority [0..36]
,	siIdxUg		smallint		null		-- upgrade priority-index
,	siIdxOt		smallint		null		-- overtime priority-index
,	tiIntOt		tinyint			null		-- overtime interval, min
,	tiDome		tinyint			null		-- dome light show index
		constraint	fkCfgPri_Dome		foreign key references tbCfgDome
,	tiTone		tinyint			null		-- tone index
		constraint	fkCfgPri_Tone		foreign key references tbCfgTone
,	tiIntTn		tinyint			null		-- tone interval, .25 sec

,	dtUpdated	smalldatetime	not null
		constraint	tdCfgPri_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tbCfgPri			to [rWriter]
grant	select							on dbo.tbCfgPri			to [rReader]
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
create proc		dbo.prCfgPri_GetAll
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
grant	execute				on dbo.prCfgPri_GetAll				to [rWriter]
grant	execute				on dbo.prCfgPri_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
--	7.06.8959	* optimized logging
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
create proc		dbo.prCfgPri_InsUpd
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

	select	@s =	'Pri( fl=' + isnull(convert(varchar, convert(varbinary(2), @siFlags), 1),'?') +
					', sh=' + isnull(cast(@tiShelf as varchar),'?') +	'|' + isnull(cast(@tiSpec as varchar),'?') +
					', k=' + isnull(cast(@tiColor as varchar),'?') +
					', ' + isnull(convert(varchar, convert(varbinary(4), @iFilter), 1),'?') +
					', ' + isnull(cast(@siIdx as varchar),'?') + '|"' + isnull(@sCall,'?') +
					'"' + isnull(', ug=' + cast(@siIdxUg as varchar),'') +
					isnull(', ot=' + cast(@siIdxOt as varchar),'') +	isnull('|' + cast(@tiIntOt as varchar),'') +
					isnull(', dm=' + cast(@tiDome as varchar),'') +
					', tn=' + isnull(cast(@tiTone as varchar),'?') +	isnull('|' + cast(@tiIntTn as varchar),'') + ' )'

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

		if	@tiLog & 0x06 = 6												--	Config & Debug?
--		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgPri_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Clears all tone definitions
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5914	* optimized
--	7.06.5702	+ reset tbCfgPri.tiTone
--	7.06.5687
create proc		dbo.prCfgTone_Clr
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
		select	@s =	'Tone( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgTone_Clr				to [rWriter]
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
create proc		dbo.prCall_SetTmpFlt
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
grant	execute				on dbo.prCall_SetTmpFlt				to [rWriter]
grant	execute				on dbo.prCall_SetTmpFlt				to [rReader]
go
--	----------------------------------------------------------------------------
--	Call-text definitions (historical)
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--				* xuCall_siIdx_Act -> xuCall_Act_siIdx
--	7.06.7104	* tdCall_Enabled: 1 -> 0
--	7.06.6508	* xuCall_Active_siIdx -> xuCall_siIdx_Act
--	7.06.5868	+ [29,30] tbCall.tVoTrg, .tStTrg defaults
--				- tdCall_tVoTrg, tdCall_tStTrg
--	7.06.5563	- xuCall_Active_sCall (duplicate call-texts allowed, siIdx is the ID)
--				* [0] INTERCOM -> NO CALL
--	7.05.4976	* xuCall_Active_sCall, xuCall_Active_siIdx: depend on .bActive (not .bEnabled)
--	7.04.4917	* .tiRouting, .bOverride, .tResp0, .tResp1, .tResp2, .tResp3 -> + tbRouting
--	7.04.4896	* tbDefCall -> tbCall
--	7.02	* .bEnabled <-> .bActive (meaning)
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.05	+ .tiRouting, .bOverride, .tResp0, .tResp1, .tResp2, .tResp3
--	6.02	+ .bEnabled, bActive: tinyint -> bit
--			+ .dtUpdated
--	2.03	+ xtDefCall_sCall(sCall, bActive), xpDefCall(idCall), - xuDefCall(sCall)
--	2.01	- .tVoMax, .tStMax
--	1.08	+ .siIdx (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins?, vwEvent8A)
--	1.06	.tVoice -> .tVoTrg, .tVoMax; .tStaff -> .tStTrg, .tStMax
--	1.05	+ .bActive, default constraints
--	1.04	+ .tVoice, .tStaff
--	1.00
create table	dbo.tbCall
(
	idCall		smallint		not null	identity( 1, 1 )
		constraint	xpCall	primary key clustered

,	siIdx		smallint		not null	-- call-index
,	sCall		varchar( 16 )	not null	-- call-text
,	bEnabled	bit				not null	-- selectable for Reports (controlled by Admins)
		constraint	tdCall_Enabled	default( 0 )
,	tVoice		time( 0 )		not null	-- std voice-response target time
,	tStaff		time( 0 )		not null	-- std staff-response target time

,	bActive		bit				not null	-- currently enabled (i.e. "matches 790 [tbCfgPri]")
		constraint	tdCall_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdCall_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdCall_Updated	default( getdate( ) )
)
create unique nonclustered index	xuCall_Act_siIdx	on	dbo.tbCall ( siIdx )	where	bActive > 0		--	7.06.6508
		--	when active, priority-indexes must be unique!!
go
grant	select, insert, update			on dbo.tbCall			to [rWriter]
grant	select, update					on dbo.tbCall			to [rReader]
go
--	initialize
begin tran
	set identity_insert	dbo.tbCall	on

		insert	dbo.tbCall ( idCall, siIdx, sCall, tVoice, tStaff, bActive )	values	( 0, 0,	'<NO CALL>', '00:01:00', '00:02:00', 0 )

	set identity_insert	dbo.tbCall	off
commit
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
create proc		dbo.prCall_GetAll
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
grant	execute				on dbo.prCall_GetAll				to [rWriter]
grant	execute				on dbo.prCall_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates target times for a given call-priority
--	7.06.8959	* optimized logging
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.06.7279	* optimized logging
--	7.06.7117	+ @idModule
--	7.05.5044	* @idUser: smallint -> int
--	7.04.4902
create proc		dbo.prCall_Upd
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

		select	@s =	'Call( ' + isnull(cast(@idCall as varchar), '?') + ', e=' + isnull(cast(@bEnabled as varchar), '?') +
						', v=' + convert(varchar, @tVoice, 108) + ', s=' + convert(varchar, @tStaff, 108) + ' )'
		exec	dbo.pr_Log_Ins	72, @idUser, null, @s, @idModule

	commit
end
go
grant	execute				on dbo.prCall_Upd					to [rWriter]
grant	execute				on dbo.prCall_Upd					to [rReader]
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.06.8959	* optimized logging
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
create proc		dbo.prCall_GetIns
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

	select	@s =	'Call( ' + isnull(cast(@siIdx as varchar), '?') + '|' + isnull(@sCall, '?') + ' )'

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

				select	@s =	@s + '=' + cast(@idCall as varchar)
				exec	dbo.pr_Log_Ins	72, null, null, @s

			commit
		end
		else
			update	tbCall	set	bEnabled =	1	where	idCall = @idCall	--	7.06.8405
	end
end
go
grant	execute				on dbo.prCall_GetIns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Location definitions (a.k.a. Architecture in 790)
--	7.06.8791	* .idParent -> .idPrnt
--	7.06.5914	* .dtCreated -> .dtUpdated
--	7.06.5501	+ .sPath	(prCfgLoc_GetAll, prCfgLoc_Ins, prCfgLoc_SetLvl)
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.02	+ .dtCreated
--	2.01
create table	dbo.tbCfgLoc
(
	idLoc		smallint		not null
		constraint	xpCfgLoc	primary key clustered

,	idPrnt		smallint		null
		constraint	fkCfgLoc_Parent		foreign key references tbCfgLoc
,	tiLvl		tinyint			not null	-- level: 0=Facility 1=System 2=Building 3=Floor 4=Unit 5=CvrgArea
,	cLoc		char( 1 )		not null	-- type:  H=Hospital S=System B=Building F=Floor U=Unit A=CvrgArea
,	sLoc		varchar( 16 )	not null	-- location name
,	sPath		varchar( 32 )	not null	-- node path ([idPrnt.]idLoc) - for tree-ordered reads

,	dtUpdated	smalldatetime	not null
		constraint	tdCfgLoc_Updated	default( getdate( ) )
)
--create unique index	xuDefLoc on dbo.tbCfgLoc ( sLoc )
go
grant	select, insert, update, delete	on dbo.tbCfgLoc			to [rWriter]
grant	select							on dbo.tbCfgLoc			to [rReader]
go
--	----------------------------------------------------------------------------
--	Coverage areas and their units
--	7.06.8791	* .idParent -> .idPrnt
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.03	* vwDefLoc_CaUnit -> vwDefLoc_Cvrg, .idCArea -> .idCvrg, .sCArea -> .sCvrg
--	7.00
create view		dbo.vwCfgLoc_Cvrg
	with encryption
as
select	a.idLoc	as	idCvrg,	a.sLoc	as	sCvrg,	u.idLoc	as	idUnit,	u.sLoc	as	sUnit
	from	dbo.tbCfgLoc	a	with (nolock)
	join	dbo.tbCfgLoc	u	with (nolock)	on	u.idLoc		= a.idPrnt	and	u.tiLvl = 4		-- unit
	where	a.tiLvl = 5														-- coverage area
go
grant	select, insert, update			on dbo.vwCfgLoc_Cvrg	to [rWriter]
grant	select							on dbo.vwCfgLoc_Cvrg	to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all locations, ordered to be loadable into a tree
--	7.06.8791	* tbCfgLoc.idParent -> .idPrnt
--	7.06.5914	* .dtCreated -> .dtUpdated
--	7.06.5504	+ .sPath
--	7.04.4892	* tbDefLoc -> tbCfgLoc
create proc		dbo.prCfgLoc_GetAll
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
grant	execute				on dbo.prCfgLoc_GetAll				to [rWriter]
grant	execute				on dbo.prCfgLoc_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all location definitions
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5914	* optimized
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	6.05
create proc		dbo.prCfgLoc_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	dbo.tbCfgLoc
		select	@s =	'Loc( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgLoc_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
--	7.06.8959	* optimized logging
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
create proc		dbo.prCfgLoc_Ins
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

	select	@s =	'Loc( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', ' + isnull(right('00' + cast(@idPrnt as varchar), 3), '?') +
					', ' + isnull(cast(@tiLvl as varchar), '?') + ' [' + isnull(@cLoc, '?') + '] "' + isnull(@sLoc, '?') + '", ' + isnull(@sPath, '?') + ' )'

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
grant	execute				on dbo.prCfgLoc_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Units
--	7.06.5914	* [0].sUnit 'INTERNAL UNIT 00' -> '00_internal_unit'
--	7.05.5255	.idShift null -> not null
--	7.05.5086	- .idShPrv
--	7.04.4967	- .iStamp
--	7.00	+ .idShPrv
--			* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			+ tdUnit_Active
--	6.07	+ .idShift, fkUnit_CurrShift
--	6.02	+ .sUnit
--	6.00
create table	dbo.tbUnit
(
	idUnit		smallint		not null
		constraint	xpUnit	primary key clustered
	---	constraint	fkUnit_DefLoc	foreign key references tbCfgLoc		-- no enforcement: tbCfgLoc is not persistent

,	sUnit		varchar( 16 )	not null	-- auto: unit name,		== 'select sLoc from tbCfgLoc where idLoc = @idUnit'
,	tiShifts	tinyint			not null	-- auto: # of shifts,	== 'select count(*) from tbShift where idUnit = @idUnit'
,	idShift		smallint		not null	-- live: current shift look-up FK
	---	constraint	fkUnit_CurrShift	foreign key references tbShift	(established later)

,	bActive		bit				not null
		constraint	tdUnit_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdUnit_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdUnit_Updated	default( getdate( ) )
)
go
grant	select, insert, update			on dbo.tbUnit			to [rWriter]
grant	select							on dbo.tbUnit			to [rReader]
go
--	initialize
begin tran
		insert	dbo.tbUnit	( idUnit, sUnit, tiShifts, idShift, bActive )	values	( 0, '00_internal_unit', 1, 0, 0 )
commit
go
--	----------------------------------------------------------------------------
--	Fills #tbUnit with given idUnit-s
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.5380	+ "or	@sUnits = ''"
--	7.05.5179	'*'=all, null=none
--	7.05.5154
create proc		dbo.prUnit_SetTmpFlt
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
grant	execute				on dbo.prUnit_SetTmpFlt				to [rWriter]
grant	execute				on dbo.prUnit_SetTmpFlt				to [rReader]
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

,	dtCreated	smalldatetime	not null
		constraint	td_RoleUnit_Created	default( getdate( ) )

,	constraint	xp_RoleUnit	primary key clustered ( idRole, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tb_RoleUnit		to [rWriter]
grant	select							on dbo.tb_RoleUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all role-unit combinations
--	7.06.6816	* order by 1
--	7.06.5385
create proc		dbo.pr_RoleUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idRole, idUnit, dtCreated
		from	dbo.tb_RoleUnit		with (nolock)
--		order	by	1, 2
end
go
grant	execute				on dbo.pr_RoleUnit_Exp				to [rWriter]
grant	execute				on dbo.pr_RoleUnit_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a role-unit combination
--	7.06.5385
create proc		dbo.pr_RoleUnit_Imp
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
grant	execute				on dbo.pr_RoleUnit_Imp				to [rWriter]
--grant	execute				on dbo.pr_RoleUnit_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns details for all roles
--	7.06.8684	+ @sRole
--	7.06.6795	+ @idUnit
--	7.05.5234
create proc		dbo.pr_Role_GetAll
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
grant	execute				on dbo.pr_Role_GetAll				to [rWriter]
grant	execute				on dbo.pr_Role_GetAll				to [rReader]
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
--	Returns units for a given user, ordered by name
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.pr_User_GetUnits
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
grant	execute				on dbo.pr_User_GetUnits				to [rWriter]
grant	execute				on dbo.pr_User_GetUnits				to [rReader]
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
create proc		dbo.pr_User_GetAll
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
grant	execute				on dbo.pr_User_GetAll				to [rWriter]
grant	execute				on dbo.pr_User_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns details for specified user
--	7.06.8789	* tb_User.sBarCode	-> sCode
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
--	7.06.7212
create proc		dbo.pr_User_GetOne
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
grant	execute				on dbo.pr_User_GetOne				to [rWriter]
grant	execute				on dbo.pr_User_GetOne				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns units for a given role
--	7.06.6817	+ order by 2
--	7.06.6807	+ .sUnit
--	7.05.5234
create proc		dbo.pr_Role_GetUnits
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
grant	execute				on dbo.pr_Role_GetUnits				to [rWriter]
grant	execute				on dbo.pr_Role_GetUnits				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
--	7.06.8965	* optimized logging
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8432	+ @idModule
--	7.06.7447	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6814	* added logging of units
--	7.05.5233	optimized
--	7.05.5021
create proc		dbo.pr_Role_InsUpd
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

	select	@s =	'Role( ' + isnull(cast(@idRole as varchar), '?') + '|' + @sRole + ', "' + isnull(cast(@sDesc as varchar), '?') +
					'" a=' + cast(@bActive as varchar) + ' U=' + isnull(cast(@sUnits as varchar), '?') + ' )'
	begin	tran

		if	not exists	(select 1 from tb_Role where idRole = @idRole)
		begin
			insert	dbo.tb_Role	(  sRole,  sDesc,  bActive )
					values		( @sRole, @sDesc, @bActive )
			select	@idRole =	scope_identity( )

			select	@idType =	242,	@s =	@s + '=' + cast(@idRole as varchar)
--			select	@idType =	242,	@s =	'Role( ' + @s + ' )=' + cast(@idRole as varchar)
		end
		else
		begin
			update	dbo.tb_Role		set	sRole=	@sRole,		sDesc=	@sDesc,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idRole = @idRole

			select	@idType =	243	--,	@s =	'Role( ' + @s + ' )'
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
grant	execute				on dbo.pr_Role_InsUpd				to [rWriter]
grant	execute				on dbo.pr_Role_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns locations down to unit-level, accessible by a given user; ordered to be loadable into a tree
--	7.06.8791	* .idParent -> .idPrnt
--	7.06.5414	* optimize for @idUser=null
--	7.06.5385	* fix: accessibility via user's roles
--	7.05.5043
create proc		dbo.prCfgLoc_GetByUser
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
grant	execute				on dbo.prCfgLoc_GetByUser			to [rWriter]
grant	execute				on dbo.prCfgLoc_GetByUser			to [rReader]
go
--	----------------------------------------------------------------------------
--	Teams
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--	7.05.5179	+ .sUnits, .sCalls
--				* .sDesc -> null
--	7.04.4947	set idTeam seed to 16:  IDs 1..15 are reserved
create table	dbo.tbTeam
(
	idTeam		smallint		not null	identity( 16, 1 )
		constraint	xpTeam		primary key clustered

,	sTeam		varchar( 16 )	not null	-- team-name
,	s_Team		as	lower( sTeam )			-- team-name, lower-cased (forced)
		constraint	xuTeam	unique			--	auto-index on automatic field
,	tResp		time( 0 )		not null	-- response time
		constraint	tdTeam_Resp		default( '00:02:00' )

,	bEmail		bit				not null	-- send email notifications?
		constraint	tdTeam_Email	default( 0 )
,	sDesc		varchar( 255 )	null		-- description

,	bActive		bit				not null
		constraint	tdTeam_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdTeam_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdTeam_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tbTeam			to [rWriter]
grant	select, insert, update			on dbo.tbTeam			to [rReader]
go
--	initialize
begin tran
	set identity_insert	dbo.tbTeam	on

		insert	dbo.tbTeam	( idTeam, sTeam, tResp, bEmail, sDesc )	values	( 1, 'Technical', '01:00:00', 0, 'Built-in team for notifying about diagnostic events' )

	set identity_insert	dbo.tbTeam	off
commit
go
--	----------------------------------------------------------------------------
--	Exports all teams
--	7.06.7368	+ .bEmail
--	7.06.6817
create proc		dbo.prTeam_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, bEmail, sDesc, bActive, dtCreated, dtUpdated
		from	dbo.tbTeam	with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeam_Exp					to [rWriter]
grant	execute				on dbo.prTeam_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team
--	7.06.7368	+ .bEmail
--	7.06.6817
create proc		dbo.prTeam_Imp
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
grant	execute				on dbo.prTeam_Imp					to [rWriter]
--grant	execute				on dbo.prTeam_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Fills  #tbTeam with given idTeam-s
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.5380	+ "or	@sTeams = ''"
--	7.05.5184
create proc		dbo.prTeam_SetTmpFlt
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
grant	execute				on dbo.prTeam_SetTmpFlt				to [rWriter]
grant	execute				on dbo.prTeam_SetTmpFlt				to [rReader]
go
--	----------------------------------------------------------------------------
--	Call priority-team membership
--	7.06.6814	* tbTeamPri -> tbTeamCall
--	7.05.5010	* xpTeamPri -> ( idTeam, siIdx )
--	7.04.4947
create table	dbo.tbTeamCall
(
	idTeam		smallint		not null
		constraint	fkTeamCall_Team	foreign key references tbTeam
,	siIdx		smallint		not null
--	-	constraint	fkTeamPri_Pri		foreign key references tbCfgPri

,	dtCreated	smalldatetime	not null
		constraint	tdTeamCall_Created	default( getdate( ) )

,	constraint	xpTeamCall		primary key clustered ( idTeam, siIdx )
)
go
grant	select, insert,			delete	on dbo.tbTeamCall		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamCall		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns calls for a given team
--	7.06.6814	* tbTeamPri -> tbTeamCall
--	7.06.6807
create proc		dbo.prTeam_GetCalls
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
grant	execute				on dbo.prTeam_GetCalls				to [rWriter]
grant	execute				on dbo.prTeam_GetCalls				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports enabled call-texts from tbCfgPri
--	7.06.8959	* optimized logging
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
create proc		dbo.prCall_Imp
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

		select	@s =	'Calls( ) +' + cast(@iAdded as varchar) + ', *' + cast(@iRemed as varchar) + ', -' + cast(@@rowcount as varchar)

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
grant	execute				on dbo.prCall_Imp					to [rWriter]
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
--	Returns units for a given team
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.prTeam_GetUnits
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
grant	execute				on dbo.prTeam_GetUnits				to [rWriter]
grant	execute				on dbo.prTeam_GetUnits				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns teams filtered by unit (and active status)
--	7.06.8684	+ @sTeam
--	7.06.7368	+ .bEmail
--	7.06.6814	- .sCalls, .sUnits
--	7.05.5191	* by unit
--	7.05.5179	+ .sUnits, .sCalls
--	7.05.5175
create proc		dbo.prTeam_GetByUnit
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
grant	execute				on dbo.prTeam_GetByUnit				to [rWriter]
grant	execute				on dbo.prTeam_GetByUnit				to [rReader]
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
grant	execute				on dbo.prTeam_GetByCall				to [rWriter]
grant	execute				on dbo.prTeam_GetByCall				to [rReader]
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
create proc		dbo.pr_AccUnit_Set
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
grant	execute				on dbo.pr_AccUnit_Set				to [rWriter]
grant	execute				on dbo.pr_AccUnit_Set				to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff-team membership
--	7.05.5059	* tb_UserTeam -> tbTeamUser
--	7.05.5010	* tbTeamStaff -> tb_UserTeam, .idStaff -> .idUser
--	7.04.4947
create table	dbo.tbTeamUser
(
	idTeam		smallint		not null
		constraint	fkTeamUser_Team		foreign key references tbTeam
,	idUser		int				not null
		constraint	fkTeamUser_User		foreign key references tb_User

,	dtCreated	smalldatetime	not null
		constraint	tdTeamUser_Created	default( getdate( ) )

,	constraint	xpTeamUser		primary key clustered ( idTeam, idUser )
)
go
grant	select, insert,			delete	on dbo.tbTeamUser		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamUser		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns teams for a given user
--	7.06.6817	+ 'order by 2'
--	7.06.6807
create proc		dbo.pr_User_GetTeams
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
grant	execute				on dbo.pr_User_GetTeams				to [rWriter]
grant	execute				on dbo.pr_User_GetTeams				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns users for a given team
--	7.06.6817	+ 'order by 2'
--	7.06.6807
create proc		dbo.prTeam_GetUsers
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
grant	execute				on dbo.prTeam_GetUsers				to [rWriter]
grant	execute				on dbo.prTeam_GetUsers				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns unique email addresses for active members of a given team
--	7.06.8791	+ 'and	u.bActive > 0'
--	7.06.7432	+ 'distinct'
--	7.06.7373
create proc		dbo.prTeam_GetEmails
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
grant	execute				on dbo.prTeam_GetEmails				to [rWriter]
grant	execute				on dbo.prTeam_GetEmails				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a team
--	7.06.8965	* optimized logging
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
create proc		dbo.prTeam_InsUpd
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

	select	@s =	'Team( ' + isnull(cast(@idTeam as varchar), '?') + '|' + @sTeam + ' ' + convert(varchar, @tResp, 108) +
					' "' + isnull(@sDesc, '?') + '" @=' + cast(@bEmail as varchar) + ' a=' + cast(@bActive as varchar) +
					' C=' + isnull(@sCalls, '?') + ' U=' + isnull(@sUnits, '?') + ' )'
	begin	tran

		if	not exists	(select 1 from dbo.tbTeam with (nolock) where idTeam = @idTeam)
		begin
			insert	dbo.tbTeam	(  sTeam,  sDesc,  bEmail,  tResp,  bActive )
					values		( @sTeam, @sDesc, @bEmail, @tResp, @bActive )
			select	@idTeam =	scope_identity( )

			select	@idType =	247,	@s =	@s + '=' + cast(@idTeam as varchar)
--			select	@idType =	247,	@s =	'Team_I( ' + @s + ' )=' + cast(@idTeam as varchar)
		end
		else
		begin
			select	@idType =	248	--,	@s =	'Team_U( ' + @s + ' )'

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
grant	execute				on dbo.prTeam_InsUpd				to [rWriter]
grant	execute				on dbo.prTeam_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns current active members on-duty
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--				* tb_User.sStaffID	-> sStfID
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
	select	u.idUser, idLvl, sStfID, sStaff, bDuty, dtDue
		from	dbo.tb_User		u	with (nolock)
		join	dbo.tbTeamUser	t	with (nolock)	on	t.idUser	= u.idUser	and	idTeam	= @idTeam
		where	bActive > 0	and	bDuty > 0
	--	order	by	1
end
go
grant	execute				on dbo.prTeam_GetStaff				to [rWriter]
grant	execute				on dbo.prTeam_GetStaff				to [rReader]
go
--	----------------------------------------------------------------------------
--	790 device/station definitions (local configuration)
--	7.06.8791	* tbDevice	->	tbCfgStn	(xuDevice_SGJR -> xuCfgStn_Act_SGJR,
--					tdDevice_Config -> tdCfgStn_Config, tdDevice_Active -> tdCfgStn_Active, tdDevice_Created -> tdCfgStn_Created, tdDevice_Updated -> tdCfgStn_Updated)
--				* ?Device -> ?Stn, idParent -> idPrnt, sCodeVer -> sVersion, tiPriCA? -> tiPri?, tiAltCA? -> tiAlt?
--	7.06.8143	+ [ 0 ]	J-000-000-00 '$|NURSE CALL'
--	7.06.5905	+ .bConfig
--	7.02	- .siBeds, .sBeds, .idEvent, .tiSvc, .idUnit (moved to tbRoom)
--	7.00	.cDevice -> NOT null, + tdDevice_Code
--			+ .sUnits, fkDevice_Unit
--			.sCodeVer -> vc(16)
--			* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.07	+ .sCodeVer
--	6.05	+ .idEvent, .tiSvc
--	6.04	+ .siBeds, .sBeds, .idUnit
--	6.02	+ .bActive, .dtCreated
--			.dtLastUpd -> .dtUpdated, tdDevice_dtLastUpd -> tdDevice_dtUpdated
--			.tiRID *not* null now
--			+ .cSys, xuDevice_GJR -> xuDevice_SGJR
--	6.00	tbDefDevice -> tbDevice (FKs)
--	4.02	- xuDevice_sDevice
--	4.01	.tiSecCA* -> .tiAltCA*
--	3.01	xpDefDevice now clustered, + xuDefDevice_GJ
--	2.03	+ .idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--	2.01	+ .cDevice (prEvent_Ins)
create table	dbo.tbCfgStn
(
	idStn		smallint		not null	identity( 1, 1 )
		constraint	xpCfgStn	primary key clustered

,	idPrnt		smallint		null		-- parent look-up FK
		constraint	fkCfgStn_Parent		foreign key references tbCfgStn
,	cSys		char( 1 )		not null	-- system ID
,	tiGID		tinyint			not null	-- G-ID - gateway
,	tiJID		tinyint			not null	-- J-ID - J-bus
,	tiRID		tinyint			not null	-- R-ID - R-bus
,	iAID		int				null		-- device A-ID (32 bits, including tiStype byte [highest])
,	tiStype		tinyint			null		-- explicit station type (1-255)
,	cStn		char( 1 )		not null	-- ?=unknown, $=system, G=gateway, R=room, M=master, Z=zone, W=workflow, A=audio, *=other
		constraint	tdCfgStn_Code		default( '?' )
,	sStn		varchar( 16 )	not null	-- device name
,	sDial		varchar( 16 )	null		-- dialable number (digits only) / gateway IP address
,	sVersion	varchar( 16 )	null		-- device code version
,	sUnits		varchar( 512 )	null		-- auto: units, this device belongs to(room)/covers(master)

,	tiPri0		tinyint			null		-- primary coverage area (rooms) or stacked button inputs (first 16 stations)
,	tiPri1		tinyint			null
,	tiPri2		tinyint			null
,	tiPri3		tinyint			null
,	tiPri4		tinyint			null
,	tiPri5		tinyint			null
,	tiPri6		tinyint			null
,	tiPri7		tinyint			null
,	tiAlt0		tinyint			null		-- alternate coverage area (rooms) or stacked button inputs (next 16 stations)
,	tiAlt1		tinyint			null
,	tiAlt2		tinyint			null
,	tiAlt3		tinyint			null
,	tiAlt4		tinyint			null
,	tiAlt5		tinyint			null
,	tiAlt6		tinyint			null
,	tiAlt7		tinyint			null

,	bConfig		bit				not null	-- discovery during Config download
		constraint	tdCfgStn_Config		default( 1 )

,	bActive		bit				not null
		constraint	tdCfgStn_Active		default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdCfgStn_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdCfgStn_Updated	default( getdate( ) )
)
create unique nonclustered index	xuCfgStn_Act_SGJR	on	dbo.tbCfgStn ( cSys, tiGID, tiJID, tiRID )	where	bActive > 0	-- + 6.02
		--	when active, combination of (cSys, tiGID, tiJID, tiRID) must be unique!!
go
grant	select, insert, update			on dbo.tbCfgStn			to [rWriter]
grant	select							on dbo.tbCfgStn			to [rReader]
go
--	initialize
begin tran
	set identity_insert	dbo.tbCfgStn	on

		insert	dbo.tbCfgStn ( idStn, cSys, tiGID, tiJID, tiRID, cStn, sStn )	values	( 0, 'J', 0, 0, 0, '$', 'NURSE CALL' )		--	7.06.8143

	set identity_insert	dbo.tbCfgStn	off
commit
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
--	7.06.8959	* optimized logging
--	7.06.8957	+ if @tiRID = 0 - process coverage-areas-to-units only for rooms and skip duplicates
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
--	6.07	- station matching by name
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
,	@iAID		int					-- station A-ID (32 bits)
,	@tiStype	tinyint				-- station type (1-255)
,	@cStn		char( 1 )			-- station type: G=gateway, R=room, M=master
,	@sStn		varchar( 16 )		-- station name
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
,	@sVersion	varchar( 16 )		-- station code version
,	@idStn		smallint		out	-- inserted/updated
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@k			tinyint
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

	select	@s =	'Stn( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) + ' [' + isnull(@cStn,'?') + '] ' +
					isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ' :' + isnull(cast(@tiStype as varchar),'?') +
					' "' + isnull(@sStn,'?') + '"' + isnull(' #' + @sDial,'') + isnull(', v=' + @sVersion,'') +
					isnull(', c0=' + cast(@tiPri0 as varchar),'') + isnull(', c1=' + cast(@tiPri1 as varchar),'') +
					isnull(', c2=' + cast(@tiPri2 as varchar),'') + isnull(', c3=' + cast(@tiPri3 as varchar),'') +
					isnull(', c4=' + cast(@tiPri4 as varchar),'') + isnull(', c5=' + cast(@tiPri5 as varchar),'') +
					isnull(', c6=' + cast(@tiPri6 as varchar),'') + isnull(', c7=' + cast(@tiPri7 as varchar),'') +
					isnull(', a0=' + cast(@tiAlt0 as varchar),'') + isnull(', a1=' + cast(@tiAlt1 as varchar),'') +
					isnull(', a2=' + cast(@tiAlt2 as varchar),'') + isnull(', a3=' + cast(@tiAlt3 as varchar),'') +
					isnull(', a4=' + cast(@tiAlt4 as varchar),'') + isnull(', a5=' + cast(@tiAlt5 as varchar),'') +
					isnull(', a6=' + cast(@tiAlt6 as varchar),'') + isnull(', a7=' + cast(@tiAlt7 as varchar),'') + ' )'

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0

	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0		and	@iAID <> 0
		select	@idStn= idStn	from	dbo.tbCfgStn	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	---and	bActive > 0
	if	@idStn is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0
		select	@idStn= idStn	from	dbo.tbCfgStn	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	---and	bActive > 0

	if	@tiRID > 0						-- R-bus station
		select	@idPrnt= idStn	from	dbo.tbCfgStn	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
	else
	if	@tiJID > 0	---and	@tiRID = 0	-- J-bus station
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
		if	@tiRID = 0														-- room-level	--	7.06.8957
		begin
			if	@tiPri0 = 0xFF	or	@tiPri1 = 0xFF	or	@tiPri2 = 0xFF	or	@tiPri3 = 0xFF	or
				@tiPri4 = 0xFF	or	@tiPri5 = 0xFF	or	@tiPri6 = 0xFF	or	@tiPri7 = 0xFF	or
				@tiAlt0 = 0xFF	or	@tiAlt1 = 0xFF	or	@tiAlt2 = 0xFF	or	@tiAlt3 = 0xFF	or
				@tiAlt4 = 0xFF	or	@tiAlt5 = 0xFF	or	@tiAlt6 = 0xFF	or	@tiAlt7 = 0xFF
			begin
				insert	#tbUnit												-- if any coverage area is set to 'ALL'
					select	idLoc
						from	dbo.tbCfgLoc	with (nolock)
						where	tiLvl = 4									-- all units
			end
			else															-- specific units for individual coverage areas	tiLvl = 5	and
			begin
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri0		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri1		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri2		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri3		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri4		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri5		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri6		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiPri7		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))

				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt0		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt1		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt2		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt3		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt4		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt5		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt6		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
				insert	#tbUnit		select	idPrnt	from	dbo.tbCfgLoc	with (nolock)	where	idLoc = @tiAlt7		and	idPrnt	not in	(select idUnit from #tbUnit with (nolock))
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

		if	@idStn > 0														-- station found - update	--	7.06.5855
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
					from	dbo.tbCfgStn	with (nolock)
					where	idStn = @idStn

				update	dbo.tbCfgStn	set		iAID= @iAID
					where	idStn = @idStn
			end

			if	@sVersion is not null
				update	dbo.tbCfgStn	set		sVersion= @sVersion
					where	idStn = @idStn
		end
		else																-- insert new station
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
			select	@k =	case when @tiRID = 0	then	75	else	74	end		--	room | stn?

			select	@s =	@s + '=' + isnull(cast(@idStn as varchar),'?') + isnull(', p=' + cast(@idPrnt as varchar),'')	-- + ', u=' + isnull(@sUnits,'?')
			exec	dbo.pr_Log_Ins	@k, null, null, @s
		end

		if	@tiJID > 0	and	@tiRID = 0	and	@sUnits is null					-- room-level	--	7.06.8957
		begin
--			select	@s =	'No coverage for room ' + cast(@idStn as varchar) + '| ' + sSGJ + ' "' + sRoom + '"'
--				from	dbo.vwRoom	with (nolock)
--				where	idRoom = @idStn
			select	@s =	'No coverage areas for ' + cast(@idStn as varchar) + '| ' + isnull(@cSys,'?') + '-' +
							right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
							right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + ' [' + isnull(@cStn,'?') + '] "' + @sStn + '"'
			exec	dbo.pr_Log_Ins	43, null, null, @s
		end

	commit
end
go
grant	execute				on dbo.prCfgStn_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
--	7.06.8959	* optimized logging
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
,	@cStn		char( 1 )			-- device type: G=gateway, R=room, M=master
,	@sStn		varchar( 16 )		-- device name
,	@sDial		varchar( 16 )		-- dialable number (digits only)
,	@idStn		smallint		out	-- output
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

	select	@s =	'Stn( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) + ' [' + isnull(@cStn,'?') + '] ' +
					isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ' :' + isnull(cast(@tiStype as varchar),'?') +
					' "' + isnull(@sStn,'?') + '"' + isnull(' #' + @sDial,'') + ' )'

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
			select	@s =	@s + ' !n:"' + @sD + '"'

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

--				if	@tiLog & 0x02 > 0										--	Config?
				if	@tiLog & 0x04 > 0										--	Debug?
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
--	Master attributes (790 local configuration)
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* fkCfgMst_CfgDvc	->	fkCfgMst_CfgStn
--	7.03
create table	dbo.tbCfgMst
(
	idMaster	smallint not null			-- 790 device look-up FK
--		constraint	xpCfgMst	primary key clustered
--		constraint	fkCfgMst_CfgDvc		foreign key references tbDevice
		constraint	fkCfgMst_CfgStn		foreign key references tbCfgStn
,	tiCvrg		tinyint not null			-- CA (0xFF == all, store as 0? - to force reading it first!?)

,	iFilter		int not null				-- filter bits for this CA

,	constraint	xpCfgMst	primary key clustered ( idMaster, tiCvrg )
)
go
grant	select, insert, update, delete	on dbo.tbCfgMst			to [rWriter]
grant	select							on dbo.tbCfgMst			to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all master attributes
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5914	* 74->75, optimized
--	7.06.5905	* 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgMst_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	dbo.tbCfgMst
		select	@s =	'Mst( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	75, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgMst_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a master attributes record
--	7.06.8959	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.5914	* trace:0x08, 74->75
--	7.06.5905	* trace:0x04, 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgMst_Ins
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

--	select	@s =	'Mst( ' + isnull(cast(@idMaster as varchar), '?') + ', c=' + isnull(cast(@tiCvrg as varchar), '?') +
	select	@s =	'Mst( ' + isnull(cast(@idMaster as varchar), '?') + isnull(', ca=' + cast(@tiCvrg as varchar), '') +
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
grant	execute				on dbo.prCfgMst_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Device button inputs (790 local configuration)
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* .idDevice	->	.idStn
--				* fkCfgBtn_CfgDvc	->	fkCfgBtn_CfgStn
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn
--				* .siPri -> .siIdx
--	7.03
create table	dbo.tbCfgBtn
(
	idStn		smallint not null			-- 790 device look-up FK
		constraint	fkCfgBtn_CfgStn		foreign key references tbCfgStn
,	tiBtn		tinyint not null			-- button code (0-31)

,	siIdx		smallint not null			-- priority			-- no FK enforcement
---		constraint	fkCfgDvcBtn_CfgPri		foreign key references tbCfgPri
,	tiBed		tinyint null				-- bed index		-- no FK enforcement
---		constraint	fkCfgDvcBtn_CfgBed		foreign key references tbCfgBed

,	constraint	xpCfgBtn		primary key clustered ( idStn, tiBtn )
)
go
grant	select, insert, update, delete	on dbo.tbCfgBtn			to [rWriter]
grant	select							on dbo.tbCfgBtn			to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all device button inputs
--	7.06.8959	* optimized logging
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
		select	@s =	'Btn( ) ' + cast(@@rowcount as varchar)

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
--	7.06.8959	* optimized logging
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* .idDevice	->	.idStn
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn,	prCfgDvcBtn_Ins -> prCfgBtn_Ins
--				* .siPri -> .siIdx
--	7.06.7279	* optimized logging
--	7.06.5914	* trace:0x20, 74->76
--	7.06.5905	* trace:0x04, 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
create proc		dbo.prCfgBtn_Ins
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

	select	@s =	'Btn( ' + isnull(cast(@idStn as varchar), '?') + isnull(' #' + cast(@tiBtn as varchar), '') +
					isnull(', p=' + cast(@siIdx as varchar), '') + isnull(', b=' + cast(@tiBed as varchar), '') + ' )'

	if	@tiBed = 0xFF		select	@tiBed =	null						--	store ALL as NULL to force retrieval order

	if	not exists	(select 1 from dbo.tbCfgBtn with (nolock) where idStn = @idStn and tiBtn = @tiBtn)
	begin
		begin	tran

			insert	dbo.tbCfgBtn	(  idStn,  tiBtn,  siIdx,  tiBed )
					values			( @idStn, @tiBtn, @siIdx, @tiBed )

			if	@tiLog & 0x06 = 6											--	Config & Debug?
--			if	@tiLog & 0x02 > 0											--	Config?
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
create view		dbo.vwStaff
	with encryption
as
select	idUser, sStfID,		sFrst, sMidd, sLast, u.idLvl, l.cLvl, l.sLvl, sCode
	,	sStaff,	isnull(sStfID, '--') + ' | ' + sStaff	as	sQnStf
	,	bDuty, dtDue,	u.idRoom
	,	bActive, dtCreated, dtUpdated
	from	dbo.tb_User	u	with (nolock)
	join	dbo.tbStfLvl l	with (nolock)	on	l.idLvl = u.idLvl
go
grant	select, insert, update			on dbo.vwStaff			to [rWriter]
grant	select							on dbo.vwStaff			to [rReader]
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
create proc		dbo.prStaff_GetAll
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
grant	execute				on dbo.prStaff_GetAll				to [rWriter]
grant	execute				on dbo.prStaff_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff [notification] device types (Badge/Pager/Phone/Wi-Fi)
--	7.06.8123	+ .cDvcType, xuDvcType
--	7.06.6452	+ [8]
--	7.06.5333	* [3] -> [4] (phone) for bitwise filters, etc.
--	7.04.4919	* tbStfDvcType -> tbDvcType, .idStfDvcType -> .idDvcType, .sStfDvcType -> .sDvcType
--	7.04.4897	* tbStaffDvcType -> tbStfDvcType, .idStaffDvcType -> .idStfDvcType, .sStaffDvcType -> .sStfDvcType
--	7.00
create table	dbo.tbDvcType
(
	idDvcType		tinyint			not null	-- look-up PK
		constraint	xpDvcType	primary key clustered

,	cDvcType		char( 1 )		not null	-- code
		constraint	xuDvcType	unique
,	sDvcType		varchar( 16 )	not null	-- name
)
go
grant	select							on dbo.tbDvcType		to [rWriter]
grant	select							on dbo.tbDvcType		to [rReader]
go
--	initialize
begin tran
		insert	dbo.tbDvcType ( idDvcType, cDvcType, sDvcType )	values	(  1, 'B', 'Badge' )
		insert	dbo.tbDvcType ( idDvcType, cDvcType, sDvcType )	values	(  2, 'P', 'Pager' )
		insert	dbo.tbDvcType ( idDvcType, cDvcType, sDvcType )	values	(  4, 'F', 'Phone' )
		insert	dbo.tbDvcType ( idDvcType, cDvcType, sDvcType )	values	(  8, 'N', 'Wi-Fi' )	--	7.06.6452
commit
go
--	----------------------------------------------------------------------------
--	Staff notification device definitions (Badge|Pager|Phone|Wi-Fi)
--	7.06.8861	* tvDvc_Assn
--	7.06.8789	* .sBarCode	-> sCode	(xuDvc_Act_BarCode -> xuDvc_Act_Code)
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--				+ tvDvc_Assn
--	7.06.8431	* .tiFlags:	2=assignable (badges)
--	7.06.6815	+ .sBrowser
--	7.06.6814	- .sTeams, .sUnits
--	7.06.5457	+ .sDial: null -> not null,		- xuDvc_TypeDial,	+ xuDvc_Type_Dial
--	7.06.5428	+ xuDvc_Active_BarCode
--	7.06.5424	- tvDvc_Dial
--	7.05.5184	+ .sTeams
--	7.05.5121	+ .sUnits
--	7.05.5085	- xuDvc_Active	- no need to enforce unique description
--	7.05.5074	+ xuDvc_TypeDial
--	7.05.5050	ID seed -> 16777216 (0x01000000)
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser
--					xpStfDvc -> xpDvc, fkStfDvc_Type -> fkDvc_Type, tdStfDvc_Flags -> tdDvc_Flags, fkStfDvc_Staff -> fkDvc_User
--					tdStfDvc_Active -> tdDvc_Active, tdStfDvc_Created -> tdDvc_Created, tdStfDvc_Updated -> tdDvc_Updated
--					xuStfDvc_Active -> xuDvc_Active
--				- revoke alter - not necessary for 'insert identity on'! (exec proc with owner permissions)
--	7.04.4947	.bGroup, .bTech -> .tiFlags
--	7.04.4939	+ .sBarCode
--	7.04.4919	* tbStfDvcType -> tbDvcType, .idStfDvcType -> .idDvcType, .sStfDvcType -> .sDvcType
--				.idStaff: FK -> tb_User
--				* .bTechno -> .bTech (tdStfDvc_Techno -> tdStfDvc_Tech), - .tiLines, - .tiChars
--	7.04.4897	* tbStaffDvcType -> tbStfDvcType, .idStaffDvcType -> .idStfDvcType, .sStaffDvcType -> .sStfDvcType
--				* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.03	ID seed -> 16777215
--	7.02	+ grant alter - necessary for 'insert identity on'!
--	7.00
create table	dbo.tbDvc
(
	idDvc		int				not null	identity( 16777216, 1 )	-- 0x01000000	1..16777215 (24 bits) are reserved for RTLS badges
		constraint	xpDvc	primary key clustered

,	idDvcType	tinyint			not null	-- device type
		constraint	fkDvc_Type	foreign key references	tbDvcType
,	sDvc		varchar( 16 )	not null	-- full name

,	sDial		varchar( 16 )	not null	-- dialable number (digits only) or badge id
--,	sBarCode	varchar( 32 )	null		-- bar-code
,	sCode		varchar( 32 )	null		-- bar-code
,	tiFlags		tinyint			not null	-- bitwise: 1=assignable (for pagers 0==group/team), 2=auto (badges)		group (pagers), 2=assignable (badges)
		constraint	tdDvc_Flags		default( 0 )
,	idUser		int				null		-- live: who is this device currently assigned to?
		constraint	fkDvc_User	foreign key references	tb_User
,	sBrowser	varchar( 255 )	null		-- Wi-Fi IDENT-string

,	bActive		bit				not null	-- currently active?
		constraint	tdDvc_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdDvc_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdDvc_Updated	default( getdate( ) )

--,	constraint	tvDvc_Dial	check	( idDvcType = 1 and sDial is null	or	sDial is not null )		--	7.06.5424
--,	constraint	tvDvc_Assn	check	( (bActive > 0	or	tiFlags & 1 = 0)	and						--	only active devices can be assignable
--												(	tiFlags & 1 > 0		or	idUser is null	) )		--	and only assignable can be assigned
--,	constraint	tvDvc_Assn	check	( idDvcType > 1	and	(tiFlags & 1 = 0	or	bActive > 0)		--	only active devices can be assignable
--													and	(tiFlags & 1 > 0	or	idUser is null) )	--	and only assignable can be assigned
)
create unique nonclustered index	xuDvc_Type_Dial		on	dbo.tbDvc ( idDvcType, sDial )			--	7.06.5457
		--	dial #s must be unique within each device type
create unique nonclustered index	xuDvc_Act_Code		on	dbo.tbDvc ( sCode )		where	bActive > 0		and	sCode is not null	--	7.06.5428
		--	when set, BarCodes must be unique between active devices [of all types!!]
go
grant	select, insert, update			on dbo.tbDvc			to [rWriter]
grant	select							on dbo.tbDvc			to [rReader]
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
create view		dbo.vwDvc
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
grant	select							on dbo.vwDvc			to [rWriter]
grant	select							on dbo.vwDvc			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given notification device's assigned staff
--	7.06.8769	+ @tiFlags
--	7.06.8740	* .tiFlags: 1=assignable (for pagers 0==group/team), 2=auto (badges)
--	7.05.5010	* prStfDvc_UpdStf -> prDvc_UpdUsr
--				* idStfDvc -> idDvc, .idStaff -> .idUser, @idStaff -> @idUser
--	7.04.4897	* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.03
create proc		dbo.prDvc_UpdUsr
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
grant	execute				on dbo.prDvc_UpdUsr					to [rWriter]
grant	execute				on dbo.prDvc_UpdUsr					to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all notification devices
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.05.5121	+ .sUnits
--	7.05.5099
create proc		dbo.prDvc_Exp
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
grant	execute				on dbo.prDvc_Exp					to [rWriter]
grant	execute				on dbo.prDvc_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a notification device
--	7.06.8789	* tbDvc.sBarCode	-> sCode
--	7.06.6815	+ .sBrowser
--	7.06.6814	- tbDvc.sTeams,.sUnits
--	7.05.5121	+ .sUnits
--	7.05.5099
create proc		dbo.prDvc_Imp
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
grant	execute				on dbo.prDvc_Imp					to [rWriter]
--grant	execute				on dbo.prDvc_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	StfDvc-Unit membership
--	7.05.5010	* tbStfDvcUnit -> tbDvcUnit,	xpStfDvcUnit -> xpDvcUnit, fkStfDvcUnit_StfDvc -> fkDvcUnit_Dvc, fkStfDvcUnit_Unit -> fkDvcUnit_Unit, tdStfDvcUnit_Created -> tdDvcUnit_Created
--	7.04.4897	* tbStaffDvcUnit -> tbStfDvcUnit, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.00
create table	dbo.tbDvcUnit
(
	idDvc		int				not null
		constraint	fkDvcUnit_Dvc		foreign key references tbDvc
,	idUnit		smallint		not null
		constraint	fkDvcUnit_Unit		foreign key references tbUnit

,	dtCreated	smalldatetime	not null
		constraint	tdDvcUnit_Created	default( getdate( ) )

,	constraint	xpDvcUnit	primary key clustered ( idDvc, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tbDvcUnit		to [rWriter]
grant	select, insert, delete			on dbo.tbDvcUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns units for a given notification device
--	7.06.6817	+ order by 2
--	7.06.6807
create proc		dbo.prDvc_GetUnits
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
grant	execute				on dbo.prDvc_GetUnits				to [rWriter]
grant	execute				on dbo.prDvc_GetUnits				to [rReader]
go
--	----------------------------------------------------------------------------
--	Team-StfDvc membership
--	7.06.6816	* tbDvcTeam -> tbTeamDvc
--	7.05.5059
create table	dbo.tbTeamDvc
(
	idTeam		smallint		not null
		constraint	fkTeamDvc_Team		foreign key references tbTeam
,	idDvc		int				not null
		constraint	fkTeamDvc_Dvc		foreign key references tbDvc

,	dtCreated	smalldatetime	not null
		constraint	tdTeamDvc_Created	default( getdate( ) )

,	constraint	xpTeamDvc		primary key clustered ( idTeam, idDvc )
)
go
grant	select, insert,			delete	on dbo.tbTeamDvc		to [rWriter]
grant	select, insert, 		delete	on dbo.tbTeamDvc		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns teams for a given device
--	7.06.6816	* tbDvcTeam -> tbTeamDvc
--	7.06.6807
create proc		dbo.prDvc_GetTeams
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
grant	execute				on dbo.prDvc_GetTeams				to [rWriter]
grant	execute				on dbo.prDvc_GetTeams				to [rReader]
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
create proc		dbo.pr_User_GetDvcs
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
grant	execute				on dbo.pr_User_GetDvcs				to [rWriter]
grant	execute				on dbo.pr_User_GetDvcs				to [rReader]
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
create proc		dbo.prTeam_GetDvcs
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
grant	execute				on dbo.prTeam_GetDvcs				to [rWriter]
grant	execute				on dbo.prTeam_GetDvcs				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a notification device
--	7.06.8965	* optimized logging
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
create proc		dbo.prDvc_InsUpd
(
	@idModule	tinyint
,	@idUser		int					-- user, performing the action
,	@idDvc		int out				-- device, acted upon
,	@idDvcType	tinyint
,	@sDvc		varchar( 16 )
,	@sDial		varchar( 16 )
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
		,		@cDvc		varchar( 1 )
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

	select	@cDvc =		cDvcType
		from	dbo.tbDvcType	with (nolock)
		where	idDvcType = @idDvcType

	select	@s =	'Dvc( ' + isnull(cast(@idDvc as varchar), '?') + '|' + cast(@idDvcType as varchar) + ':' + @cDvc + ' "' + @sDvc + '"' +
					isnull(', c=' + @sCode, '') + isnull(' #' + @sDial, '') +
					' f=' + convert(varchar, convert(varbinary(2), @tiFlags), 1) + ' a=' + cast(@bActive as varchar) +
					isnull(' U=' + @sUnits, '') + isnull(' T=' + @sTeams, '') + ' )'
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

			select	@idType =	247,	@s =	@s + '=' + cast(@idDvc as varchar)
--			select	@idType =	247,	@s =	'Dvc_I( ' + @s + ' ) =' + cast(@idDvc as varchar)

			if	@idDvcType = 8												--	Wi-Fi devices
				update	dbo.tbDvc	set	sCode=	cast(@idDvc as varchar)		--		enforce barcode to == DvcID
					where	idDvc = @idDvc
		end
		else
		begin
			select	@idType =	248	--,	@s =	'Dvc_U( ' + @s + ' )'

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
grant	execute				on dbo.prDvc_InsUpd					to [rWriter]
grant	execute				on dbo.prDvc_InsUpd					to [rReader]
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
create proc		dbo.prStaff_LstAct
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
grant	execute				on dbo.prStaff_LstAct				to [rWriter]
grant	execute				on dbo.prStaff_LstAct				to [rReader]
go
--	----------------------------------------------------------------------------
--	Rooms state (keeps track via 7981 of staff, "oldest" in each room)
--	7.06.8791	* tbDevice	->	tbCfgStn
--				* fkRoom_Device -> fkRoom_CfgStn
--	7.06.7292	+ .idUser4, .idUser2, .idUser1
--				+ xuRoom_User4, xuRoom_User2, xuRoom_User1
--	7.06.7262	+ .tiCall
--	7.06.7257	- xuRoom_UserG, xuRoom_UserO, xuRoom_UserY		7983 (prEvent84_Ins) not ready for this yet
--	7.06.7242	+ xuRoom_UserG, xuRoom_UserO, xuRoom_UserY
--	7.06.6225	+ .dtExpires
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.04.4919	.idStaff: FK -> tb_User
--	7.03	* xpRoom: explicit PK name!
--	7.02	* fkRoom_Cn -> fkRoom_Cna, fkRoom_Ai -> fkRoom_Aide
--			* tbRoomStaff -> tbRoom
--			+ .siBeds, .sBeds, .idEvent, .tiSvc, .idUnit (moved from tbDevice)
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.05
create table	dbo.tbRoom
(
	idRoom		smallint		not null	-- 790 room controller
		constraint	xpRoom		primary key clustered
--		constraint	fkRoom_Device	foreign key references tbDevice
		constraint	fkRoom_CfgStn	foreign key references tbCfgStn

,	idUnit		smallint		null		-- live: current unit
		constraint	fkRoom_Unit		foreign key references tbUnit
,	siBeds		smallint		null		-- auto: beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
,	sBeds		varchar( 10 )	null		-- auto: beds 'A'.. 'ABCDEFGHIJ'
,	idEvent		int				null		-- live: highest active call FK
	---	constraint	fkRoom_Event	foreign key references tbEvent	on delete set null		(established later)
,	tiSvc		tinyint			null		-- live: service state

,	idUserG		int				null		-- live: Grn
		constraint	fkRoom_UserG	foreign key references tb_User
,	idUserO		int				null		-- live: Ora
		constraint	fkRoom_UserO	foreign key references tb_User
,	idUserY		int				null		-- live: Yel
		constraint	fkRoom_UserY	foreign key references tb_User
,	sStaffG		varchar( 16 )	null		-- live: Grn
,	sStaffO		varchar( 16 )	null		-- live: Ora
,	sStaffY		varchar( 16 )	null		-- live: Yel

,	idUser4		int				null		-- RTLS: Grn
		constraint	fkRoom_User4	foreign key references tb_User
,	idUser2		int				null		-- RTLS: Ora
		constraint	fkRoom_User2	foreign key references tb_User
,	idUser1		int				null		-- RTLS: Yel
		constraint	fkRoom_User1	foreign key references tb_User
,	tiCall		tinyint			not null	-- RTLS: place badge-call?	4=G, 2=O, 1=Y
		constraint	tdRoom_Call		default( 0 )
,	dtExpires	datetime		null		-- expiration window for healing (tb_OptSys[8])

,	dtUpdated	datetime		not null
		constraint	tdRoom_Updated	default( getdate( ) )
)
create unique nonclustered index	xuRoom_User4	on	dbo.tbRoom ( idUser4 )	where	idUser4 is not null		-- 7.06.7292
create unique nonclustered index	xuRoom_User2	on	dbo.tbRoom ( idUser2 )	where	idUser2 is not null		-- 7.06.7292
create unique nonclustered index	xuRoom_User1	on	dbo.tbRoom ( idUser1 )	where	idUser1 is not null		-- 7.06.7292
		--	enforce that any staff member can only be present in one room
go
grant	select, insert, update			on dbo.tbRoom			to [rWriter]
grant	select							on dbo.tbRoom			to [rReader]
go
--	7.05.5099
alter table		dbo.tb_User		add
	constraint	fk_User_Room	foreign key (idRoom)	references	tbRoom
go
--	----------------------------------------------------------------------------
--	790 Stations
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
create view		dbo.vwRoom
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
grant	select, insert, update			on dbo.vwRoom			to [rWriter]
grant	select							on dbo.vwRoom			to [rReader]
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
--	7.06.8965	* optimized logging
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
create proc		dbo.prRoom_UpdStaff
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
			,	@s =	'Room( ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(@sRoom,'?') + ', ' + isnull(cast(@tiEdit as varchar),'?') +
						isnull(', G:' + cast(@idUserG as varchar),'') + isnull('|' + @sStaffG,'') +
						isnull(', O:' + cast(@idUserO as varchar),'') + isnull('|' + @sStaffO,'') +
						isnull(', Y:' + cast(@idUserY as varchar),'') + isnull('|' + @sStaffY,'') + ' ) '
				--		', G:' + isnull(cast(@idUserG as varchar),'?') + '|' + isnull(@sStaffG,'?') +
				--		', O:' + isnull(cast(@idUserO as varchar),'?') + '|' + isnull(@sStaffO,'?') +
				--		', Y:' + isnull(cast(@idUserY as varchar),'?') + '|' + isnull(@sStaffY,'?') + ' ) '

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
grant	execute				on dbo.prRoom_UpdStaff				to [rWriter]
--grant	execute				on dbo.prRoom_UpdStaff				to [rReader]
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
create proc		dbo.prRoom_GetByUnit
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
grant	execute				on dbo.prRoom_GetByUnit				to [rReader]	--	6.05
grant	execute				on dbo.prRoom_GetByUnit				to [rWriter]
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
create proc		dbo.prStaff_GetByUnit
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
grant	execute				on dbo.prStaff_GetByUnit			to [rWriter]
grant	execute				on dbo.prStaff_GetByUnit			to [rReader]
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

--	============================================================================
print	char(10) + '###	Creating event tables & sprocs..'
go
--	----------------------------------------------------------------------------
--	System activity log: [0x83, 0x96, 0x97, 0x9D, 0xA7, 0xAE]
--	7.06.8802	* .idLogType -> idType, @
--				* fkEvent_LogType -> fkEvent_Type
--	7.06.8797	+ .utEvent
--	7.06.8796	* .idSrcDvc -> .idSrcStn, @
--				* .idDstDvc -> .idDstStn, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.5561	* .vbCmd -> tbEvent_B
--	7.06.5487	+ .tiFlags
--				re-order columns
--	7.04.4896	* tbDefCall -> tbCall
--	7.04.4892	+ fkEvent_Unit
--	7.02	optimize column order
--			- fkEvent_Device_Room, + fkEvent_Room
--			* .tElapsed -> .tOrigin, fkEvent_Device_Src -> fkEvent_DvcSrc, fkEvent_Device_Dst -> fkEvent_DvcDst
--	6.04	+ tbEvent.idRoom
--	6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	6.00	tbDefDevice -> tbDevice (FKs)
--			tbDefType -> tbEvType (fkEvent_DefType -> fkEvent_EvType)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95,B7 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	5.01	+ .idParent, + .tParent
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			96, 97 are now stored entirely here (from 98)
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	2.01	.idRoom -> .idDevice (FK changed also)
--	1.09	+ .sInfo (<- tbEvent84,95,98)
--			+ .tiHH (vwEvent)
--	1.08	+ .iHash (prEvent*_Ins)
--			.vbCmd: vc(252) -> vc(256) (prEvent*_Ins)
--			+ .idType
--	1.00
create table	dbo.tbEvent
(
	idEvent		int				not null	identity( 1, 1 )	-- ?? bigint
		constraint	xpEvent	primary key clustered

,	idOrigin	int				null		-- auto: origin idEvent
		constraint	fkEvent_Origin	foreign key references	tbEvent
,	idParent	int				null		-- auto: parent idEvent
		constraint	fkEvent_Parent	foreign key references	tbEvent
--,	idLogType	tinyint			null		-- type look-up FK (marks significant events only)
,	idType		tinyint			null		-- type look-up FK (marks significant events only)
		constraint	fkEvent_Type	foreign key references	tb_LogType

,	utEvent		datetime		not null	-- auto: UTC date-time
		constraint	tdEvent_UTC		default( getutcdate( ) )
,	dtEvent		datetime		not null	-- auto: date-time
--		constraint	tdEvent_dtEvent	default( getdate( ) )	-- along with .dEvent,.tEvent,.tiHH
--,	vbCmd		varbinary( 256 )	null	-- message

,	idCmd		tinyint			not null	-- command look-up FK
		constraint	tdEvent_Cmd		default( 0 )
		constraint	fkEvent_DefCmd	foreign key references	tbDefCmd
--,	tiLen		tinyint			null		-- message length
--		constraint	tdEvent_Len		default( 0 )
,	iHash		int				null		-- message hash (32-bit) (Murmur2)
--		constraint	tdEvent_Hash	default( 0 )
,	idCall		smallint		null		-- call look-up FK (only x84, x8A and x95 commands)
		constraint	fkEvent_Call	foreign key references	tbCall

,	dEvent		date			not null	-- auto: date (only)
,	tEvent		time( 3 )		not null	-- auto: time (only)
,	tiHH		tinyint			not null	-- auto: hour (24HH)
,	tOrigin		time( 3 )		null		-- auto: from origin event
,	tParent		time( 3 )		null		-- auto: from parent event

,	cSrcSys		char( 1 )		null		-- source system
,	tiSrcGID	tinyint			null		-- source G-ID - gateway
,	tiSrcJID	tinyint			null		-- source J-ID - J-bus
,	tiSrcRID	tinyint			null		-- source R-ID - R-bus
--,	idSrcDvc	smallint		null		-- source device look-up FK
--		constraint	fkEvent_DvcSrc	foreign key references	tbCfgStn
,	idSrcStn	smallint		null		-- source device look-up FK
		constraint	fkEvent_StnSrc	foreign key references	tbCfgStn
,	cDstSys		char( 1 )		null		-- target system
,	tiDstGID	tinyint			null		-- target G-ID - gateway
,	tiDstJID	tinyint			null		-- target J-ID - J-bus
,	tiDstRID	tinyint			null		-- target R-ID - R-bus
--,	idDstDvc	smallint		null		-- target device look-up FK
--		constraint	fkEvent_DvcDst	foreign key references	tbCfgStn
,	idDstStn	smallint		null		-- target device look-up FK
		constraint	fkEvent_StnDst	foreign key references	tbCfgStn
,	tiBtn		tinyint			null		-- src|dst button code (0-31)

,	idUnit		smallint		null		-- active unit look-up FK
		constraint	fkEvent_Unit	foreign key references	tbUnit	--	on delete set null		--	7.04.4892
,	idRoom		smallint		null		-- room FK
		constraint	fkEvent_Room	foreign key references	tbRoom	on delete set null
,	tiBed		tinyint			null		-- bed index
,	sInfo		varchar( 32 )	null		-- info text
,	tiFlags		tinyint			null		-- additional data
)
go
grant	select, insert, update, delete	on dbo.tbEvent			to [rWriter]
grant	select							on dbo.tbEvent			to [rReader]
go
--	----------------------------------------------------------------------------
--	now that the [tbEvent] is defined add FKs to it
--alter table		dbo.tbDevice	add
--	constraint	fkDevice_Event	foreign key (idEvent)	references	tbEvent
alter table		dbo.tbRoom		add
	constraint	fkRoom_Event	foreign key (idEvent)	references	tbEvent	on delete set null
go
--	----------------------------------------------------------------------------
--	System activity binary log
--	7.06.5562
create table	dbo.tbEvent_B
(
	idEvent		int				not null	-- ?? bigint
		constraint	xpEventB	primary key clustered
		constraint	fkEventB_Event	foreign key references	tbEvent	on delete cascade

,	tiLen		tinyint			not null	-- message length
--		constraint	tdEvent_Len		default( 0 )
,	vbCmd		varbinary( 256 ) not null	-- message
)
go
grant	select, insert, update, delete	on dbo.tbEvent_B		to [rWriter]
grant	select							on dbo.tbEvent_B		to [rReader]
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
create view		dbo.vwEvent
	with encryption
as
select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, utEvent, dtEvent, dEvent, tEvent, tiHH
	,	idCmd, iHash, tiBtn,	e.idUnit,	e.idRoom, e.tiBed,	r.sStn as sRoom, b.cBed
	,	r.sStn + case when e.tiBed is null then '' else ' : ' + b.cBed end	as	sRoomBed
	,	e.idSrcStn, s.sSGJR as sSrcSGJR, s.cStn as cSrcStn, s.sStn as sSrcStn, s.sQnStn as sQnSrcStn
	,	e.idDstStn, d.sSGJR as sDstSGJR, d.cStn as cDstStn, d.sStn as sDstStn, d.sQnStn as sQnDstStn
	,	e.idType, t.sType, e.idCall, c.sCall, e.sInfo, e.tiFlags
	from		dbo.tbEvent		e	with (nolock)
	left join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
	left join	dbo.tb_LogType	t	with (nolock)	on	t.idType	= e.idType
	left join	dbo.vwCfgStn	s	with (nolock)	on	s.idStn		= e.idSrcStn
	left join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= e.idDstStn
	left join	dbo.tbCfgStn	r	with (nolock)	on	r.idStn		= e.idRoom
go
grant	select, insert, update, delete	on dbo.vwEvent			to [rWriter]
grant	select							on dbo.vwEvent			to [rReader]
go
--	----------------------------------------------------------------------------
--	Event statistics by date and hour
--	6.04
create table	dbo.tbEvent_S
(
	dEvent		date			not null	-- date
,	tiHH		tinyint			not null	-- HH (hour)

,	idEvent		int				not null	-- 1st Event in this hour FK (no enforcement)
--		constraint	fkEventS_Event	foreign key references	tbEvent

	constraint	xpEvent_S	primary key clustered	( dEvent, tiHH )
)
go
grant	select, insert, update			on dbo.tbEvent_S		to [rWriter]
grant	select							on dbo.tbEvent_S		to [rReader]
go
--	----------------------------------------------------------------------------
--	Event statistics by hour
--	6.05	+ (nolock)
--	6.04
create view		dbo.vwEvent_S
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
grant	select							on dbo.vwEvent_S		to [rWriter]
grant	select							on dbo.vwEvent_S		to [rReader]
go
--	----------------------------------------------------------------------------
--	System activity log: active events
--	7.06.8796	* xuEventA_SGJRB_Act -> xuEventA_Act_SGJRB
--	7.06.6508	* xuEventA_Active_SGJRB -> xuEventA_SGJRB_Act
--	7.06.6373	- .tiLvl no benefit
--	7.06.6355	+ .tiLvl
--	7.04.4896	* tbDefCall -> tbCall
--	7.03	+ .tiCvrg[0..7] to cache values from tbEvent84
--	7.02	- fkEventA_Device_Room, + fkEventA_Room
--			- .tiTmr* (no need anymore, .tiSvc satisfies)
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--			+ .tiSvc, .bAudio
--	6.04	+ tbEvent_A.idCall, .idRoom, .tiBed, .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide
--	6.03	+ on delete cascade
--			+ .bActive, + xuEventA_SysGJRB
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	4.02	+ .dtExpires
--	1.00
create table	dbo.tbEvent_A
(
	idEvent		int				not null	-- ?? bigint
		constraint	xpEventA	primary key clustered
		constraint	fkEventA_Event	foreign key references tbEvent	on delete cascade

,	dtEvent		datetime		not null	-- original call placement (corrected for delays via tbEvent84.siElapsed - e.g. late startup)
,	cSys		char( 1 )		not null	-- source system
,	tiGID		tinyint			not null	-- source G-ID - gateway
,	tiJID		tinyint			not null	-- source J-ID - J-bus
,	tiRID		tinyint			not null	-- source R-ID - R-bus
,	tiBtn		tinyint			not null	-- source button code
,	siPri		smallint		not null	-- call-priority (all bits)
,	siIdx		smallint		not null	-- call-index (masked 0x3FF)

,	idCall		smallint		null		-- call look-up FK
		constraint	fkEventA_Call	foreign key references tbCall
--,	tiLvl		tinyint			null		-- 0=Non-Clinic, 1=Clinic-None, 2=Clinic-Patient, 3=Clinic-Staff, 4=Clinic-Doctor
,	idRoom		smallint		null			-- room FK
		constraint	fkEventA_Room	foreign key references tbRoom
,	tiBed		tinyint			null		-- bed index
,	tiSvc		tinyint			null		-- service state
,	bAudio		bit				not null	-- audio connected?
		constraint	tdEventA_Audio	default( 0 )
,	tiCvrg0		tinyint			null		-- coverage area 0
,	tiCvrg1		tinyint			null		-- coverage area 1
,	tiCvrg2		tinyint			null		-- coverage area 2
,	tiCvrg3		tinyint			null		-- coverage area 3
,	tiCvrg4		tinyint			null		-- coverage area 4
,	tiCvrg5		tinyint			null		-- coverage area 5
,	tiCvrg6		tinyint			null		-- coverage area 6
,	tiCvrg7		tinyint			null		-- coverage area 7

,	dtExpires	datetime		not null	-- expiration window (30s from last healing message)
,	bActive		bit				not null	-- actively healed?
		constraint	tdEventA_Active	default( 1 )
)
create unique nonclustered index	xuEventA_Act_SGJRB	on	dbo.tbEvent_A ( cSys, tiGID, tiJID, tiRID, tiBtn )	where	bActive > 0		-- + 6.05	--	7.06.6508
		--	there can only be no more than one active event (call) placed by each Sys-G-J-R-B [at a time]
go
grant	select, insert, update, delete	on dbo.tbEvent_A		to [rWriter]
grant	select							on dbo.tbEvent_A		to [rReader]
go
--	----------------------------------------------------------------------------
--	System activity log: call events
--	7.06.8796	* .idEvtVo -> .idEvtV, @
--				* .idEvtSt -> .idEvtS, @
--	7.06.6017	+ .idShift, .dShift
--	7.06.5638	* fkEventC_Event_Voice -> fkEventC_EvtVo, fkEventC_Event_Staff -> fkEventC_EvtSt
--	7.06.5483	* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--				- .idUser	(use .idUser1)
--	7.06.5330	+ .siBed
--	7.06.5326	+ .idAssn1|2|3
--	7.05.5065	+ .idUser
--	7.05.4976	* .cBed -> .tiBed
--				- .idEvtRn, .tRn, .idEvtCn, .tCn, .idEvtAi, .tAi
--	7.04.4897	* tbEvent_C:	.idVoice -> .idEvtVo, .idStaff -> .idEvtSt, .idRn -> .idEvtRn, .idCn -> .idEvtCn, .idAi -> .idEvtAi
--	7.04.4896	* tbDefCall -> tbCall
--	7.02	+ fkEventC_Unit
--			- fkEventC_Device, + fkEventC_Room
--			* .idCna -> .idCn, .idAide -> .idAi
--	6.03	+ on delete cascade ('on delete set null' can't work because of multiple columns - BS, but SQL doesn't accept)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--	6.00	tbDefDevice -> tbDevice (FKs)
--	6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--	2.03	+ .tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--	2.02	+ .idRn, .tRn, .idCna, .tCna, .idAide, .tAide (vwEventC, prEvent84_Ins?)
--	2.01	.idRoom -> .idDevice (FK changed also)
--	1.07	+ xtEventC_dEvent_tiHH
--	1.05	+ .cBed
--	1.03
create table	dbo.tbEvent_C
(
	idEvent		int				not null	-- ?? bigint
		constraint	xpEventC	primary key clustered
		constraint	fkEventC_Event		foreign key references	tbEvent	on delete cascade

,	dEvent		date			not null
,	tEvent		time( 3 )		not null
,	tiHH		tinyint			not null	-- HH (hour)
,	idCall		smallint		not null
		constraint	fkEventC_Call		foreign key references	tbCall
,	idUnit		smallint		not null	-- room must be in a unit (active)
		constraint	fkEventC_Unit		foreign key references	tbUnit
,	idShift		smallint		not null	-- unit's shift at origination
	---	constraint	fkEventC_Shift		foreign key references	tbShift	(established later)
,	dShift		date			not null	-- shift-started date
,	idRoom		smallint		not null	-- call must come from a room
		constraint	fkEventC_Room		foreign key references	tbRoom
,	siBed		smallint		not null	-- bed-flag (bit index)
,	tiBed		tinyint			null		-- bed index
--,	cBed		char( 1 )		null		-- bed name
,	idEvtV		int				null		-- voice response
		constraint	fkEventC_EvtV		foreign key references	tbEvent	--on delete set null
,	tVoice		time( 3 )		null		-- elapsed
,	idEvtS		int				null		-- staff response
		constraint	fkEventC_EvtS		foreign key references	tbEvent	--on delete set null
,	tStaff		time( 3 )		null		-- elapsed
--,	idUser		int				null		-- staff (for registration events)
--		constraint	fkEventC_User		foreign key references	tb_User
,	idUser1		int				null		-- history: assignee 1
		constraint	fkEventC_User1		foreign key references	tb_User
,	idUser2		int				null		-- history: assignee 2
		constraint	fkEventC_User2		foreign key references	tb_User
,	idUser3		int				null		-- history: assignee 3
		constraint	fkEventC_User3		foreign key references	tb_User
)
create index	xtEventC_dEvent_tiHH	on	dbo.tbEvent_C ( dEvent, tiHH )
go
grant	select, insert, update, delete	on dbo.tbEvent_C		to [rWriter]
grant	select							on dbo.tbEvent_C		to [rReader]
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
create view		dbo.vwEvent_C
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
grant	select, insert, update, delete	on dbo.vwEvent_C		to [rWriter]
grant	select							on dbo.vwEvent_C		to [rReader]
go
--	----------------------------------------------------------------------------
--	Clinic activity log: patient events.  Also Rounding/Reminder events.
--	7.06.8796	* .idEvntP -> .idEvtP, @
--				* .idEvntS -> .idEvtS, @
--				* .idEvntD -> .idEvtD, @
--	7.06.8500	- .dEvent, .tEvent	no need
--				- xtEventD_dEvent_tiHH
--				+ .idEvntP, .tWaitP
--	7.06.6402	restore .idShift, .dShift, .siBed, .tiBed
--	7.06.6345
create table	dbo.tbEvent_D
(
	idEvent		int				not null	-- ?? bigint
		constraint	xpEventD	primary key clustered
		constraint	fkEventD_Event		foreign key references	tbEvent	on delete cascade

--,	dEvent		date			not null
--,	tEvent		time( 3 )		not null
,	tiHH		tinyint			not null	-- HH (hour)
,	idCall		smallint		not null
		constraint	fkEventD_Call		foreign key references	tbCall
,	idUnit		smallint		not null	-- room must be in a unit (active)
		constraint	fkEventD_Unit		foreign key references	tbUnit
,	idShift		smallint		not null	-- unit's shift at origination
	---	constraint	fkEventD_Shift		foreign key references	tbShift	(established later)
,	dShift		date			not null	-- shift-started date
,	idRoom		smallint		not null	-- call must come from a room
		constraint	fkEventD_Room		foreign key references	tbRoom
,	siBed		smallint		not null	-- bed-flag (bit index)
,	tiBed		tinyint			null		-- bed index
--,	cBed		char( 1 )		null		-- bed name
,	idEvtP		int				null		-- patient entered
		constraint	fkEventD_EvtP		foreign key references	tbEvent	--on delete set null
,	tWaitP		time( 3 )		null		-- patient's wait-for-room time
,	tRoomP		time( 3 )		null		-- patient's time in room
,	idEvtS		int				null		-- staff entered
		constraint	fkEventD_EvtS		foreign key references	tbEvent	--on delete set null
,	tWaitS		time( 3 )		null		-- patient's wait-for-staff time
,	tRoomS		time( 3 )		null		-- staff's time in room
,	idEvtD		int				null		-- doctor extered
		constraint	fkEventD_EvtD		foreign key references	tbEvent	--on delete set null
,	tWaitD		time( 3 )		null		-- patient's wait-for-doctor time
,	tRoomD		time( 3 )		null		-- doctor's time in room
)
--create index	xtEventD_dEvent_tiHH	on	dbo.tbEvent_D ( dEvent, tiHH )
go
grant	select, insert, update, delete	on dbo.tbEvent_D		to [rWriter]
grant	select							on dbo.tbEvent_D		to [rReader]
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
create view		dbo.vwEvent_D
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
grant	select, insert, update, delete	on dbo.vwEvent_D		to [rWriter]
grant	select							on dbo.vwEvent_D		to [rReader]
go
--	----------------------------------------------------------------------------
--	Doctor definitions
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.04	tbDefDoctor -> tbDoctor (tbEvent84, prEvent84_Ins, vwEvent84, tbEvent98, prEvent98_Ins, vwEvent98, tbRoomBed, vwRoomBed, prRptCallActDtl)
--	1.00
create table	dbo.tbDoctor
(
	idDoctor	int			not null	identity( 1, 1 )
		constraint	xpDoctor	primary key clustered		--	6.04

,	sDoctor		varchar( 16 )	not null	-- full name

,	bActive		bit			not null
		constraint	tdDoctor_Active		default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdDoctor_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdDoctor_Updated	default( getdate( ) )
)
--	create unique clustered index	xuDefDoctor on	dbo.tbDefDoctor ( sDoctor )		--	- 6.04
create unique nonclustered index	xuDoctor	on	dbo.tbDoctor ( sDoctor )	where	bActive > 0	-- + 6.04
		--	names must be unique between all active docs
go
grant	select, insert, update			on dbo.tbDoctor			to [rWriter]
grant	select							on dbo.tbDoctor			to [rReader]
go
--	----------------------------------------------------------------------------
--	Finds a doctor by name and inserts if necessary (not found)
--	7.06.8965	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.7222	+ quotes in trace
--	6.05	+ (nolock)
--	6.04
create proc		dbo.prDoctor_GetIns
(
	@sDoctor	varchar( 16 )		-- full name (HL7)

,	@idDoctor	int				out	-- output
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

				select	@s =	'Doc( "' + isnull(@sDoctor,'?') + '" )=' + cast(@idDoctor as varchar)
				exec	dbo.pr_Log_Ins	44, null, null, @s
			commit
		end
	end
end
go
grant	execute				on dbo.prDoctor_GetIns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates a doctor record
--	7.06.8965	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	6.05		* tracing
--	6.04
create proc		dbo.prDoctor_Upd
(
	@idDoctor	int			out		-- output
,	@sDoctor	varchar( 16 )		-- full name (HL7)
,	@bActive	bit
)
	with encryption
as
begin
	declare		@s		varchar( 255 )

	set	nocount	on

	select	@s =	'Doc( ' + isnull(cast(@idDoctor as varchar),'?') + '| "' + isnull(@sDoctor,'?') + '", a=' + cast(@bActive as varchar) + ' )'

	begin	tran
		update	dbo.tbDoctor	set	sDoctor =	@sDoctor,	bActive =	@bActive,	dtUpdated=	getdate( )
			where	idDoctor = @idDoctor

		exec	dbo.pr_Log_Ins	44, null, null, @s
	commit
end
go
grant	execute				on dbo.prDoctor_Upd					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Patient definitions
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8642	+ xuPatient_PatID
--	7.06.8595	+ .sIdent, .sPatID, .sLast, .sFrst, sMidd
--	7.06.6284	- .idRoom, .tiBed, fkPatient_RoomBed	(tbRoomBed gives patient's location)
--	7.05.5079	+ on delete set null to fkPatient_RoomBed
--	7.04.4955	+ xuPatient_Loc
--	7.03	tbRoomBed.idPatient -> tbPatient.idRoom + .tiBed (+ tbPatient.fkPatient_RoomBed)
--			+ fkPatient_RoomBed
--	7.02	+ .idDoctor (moved from tbRoomBed)
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.04	tbDefPatient -> tbPatient (tbEvent84, prEvent84_Ins, vwEvent84, tbEvent98, prEvent98_Ins, vwEvent98, tbRoomBed, vwRoomBed, prRptCallActDtl)
--	1.00
create table	dbo.tbPatient
(
	idPatient	int				not null	identity( 1, 1 )
		constraint	xpPatient	primary key clustered		--	6.04

,	sPatient	varchar( 16 )	not null	-- full name
,	cGndr		char( 1 )		not null	-- HL7 PID.8 - Administrative Sex (optional):	U=Unknown, A=Ambiguous, M=Male, F=Female, N=Not applicable, O=Other
		constraint	tdPatient_Gender	default( 'U' )
,	sInfo		varchar( 32 )	null		-- info (from 98/9A cmd)
,	sNote		varchar( 255 )	null		-- notes editable in 7985
,	sIdent		varchar( 250 )	null		-- HL7 PID.3 - Patient Identifier List (required)
,	sPatID		varchar( 15 )	null		-- HL7 PID.3.1 - Patient Identifier (required)
,	sLast		varchar( 50 )	null		-- HL7 PID.5.1.1 - Surname (required)
,	sFrst		varchar( 30 )	null		-- HL7 PID.5.2 - Given Name (optional)
,	sMidd		varchar( 30 )	null		-- HL7 PID.5.3 - 2nd Given Name or Initial (optional)

--,	idRoom		smallint		null		-- device look-up FK
--,	tiBed		tinyint			null		-- bed index FK
--,		constraint	fkPatient_RoomBed	foreign key	( idRoom, tiBed )	references tbRoomBed	on delete set null
,	idDoctor	int null					-- current doctor look-up FK
		constraint	fkPatient_Doctor	foreign key	references tbDoctor

,	bActive		bit				not null
		constraint	tdPatient_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdPatient_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdPatient_Updated	default( getdate( ) )
)
create unique nonclustered index	xuPatient		on	dbo.tbPatient ( sPatient )	where	bActive > 0		-- + 6.04
		--	full names must be unique between all active patients
create unique nonclustered index	xuPatient_PatID	on	dbo.tbPatient ( sPatID )	where	sPatID is not null		-- + 7.06.8642
		--	when set, PatIDs must be unique
--create unique nonclustered index	xuPatient_Loc	on	dbo.tbPatient ( idRoom, tiBed )	where	idRoom is not null	and tiBed is not null	-- + 7.04.4955
go
grant	select, insert, update			on dbo.tbPatient		to [rWriter]
grant	select							on dbo.tbPatient		to [rReader]
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
--	7.06.8965	* optimized logging
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
create proc		dbo.prPatient_GetIns
(
	@sPatient	varchar( 16 )		-- full name (HL7)
,	@cGndr		char( 1 )
,	@sInfo		varchar( 32 )
--,	@sNote		varchar( 255 )
,	@sDoctor	varchar( 16 )		-- full name (HL7)

,	@idPatient	int			out		-- output
,	@idDoctor	int			out		-- output
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

	if	@cGndr = ''		or	@cGndr is null	or	ascii(@cGndr) = 0xFF
		select	@cGndr=	'U'

	if	@sPatient = 'EMPTY'													--	.7222	treat 'EMPTY' as 'no patient'
		select	@sPatient=	null

	if	@sInfo = ''
		select	@sInfo =	null

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

				select	@s =	'Pat( ' + isnull(@cGndr,'?') + ': ' + isnull(@sPatient,'?') +
								isnull(', i="' + @sInfo + '"','') +		-- isnull(', n="' + @sNote,'') + '"' +
								isnull(', d=' + cast(@idDoctor as varchar) + '|' + isnull(@sDoctor,'?'),'') + ' )=' + cast(@idPatient as varchar)

--				if	@tiLog & 0x02 > 0										--	Config?
--				if	@tiLog & 0x04 > 0										--	Debug?
				if	@tiLog & 0x08 > 0										--	Trace?
					exec	dbo.pr_Log_Ins	44, null, null, @s
			end
			else															--	found active patient with given name
			begin
				select	@s=	''
				if	@cGen <> @cGndr		select	@s =	@s + isnull(' :' + @cGndr,'')
				if	@sInf is not null	and	@sInfo is not null	and	@sInf <> @sInfo
				or	@sInf is not null	and	@sInfo is null
				or	@sInf is null		and	@sInfo is not null
										select	@s =	@s + isnull(', i="' + @sInfo + '"','')
		--		if	@sNot <> @sNote		select	@s =	@s + isnull(', n="' + @sNote,'') + '"'
				if	@idDoc <> @idDoctor	select	@s =	@s + isnull(', d=' + cast(@idDoctor as varchar) + '|' + isnull(@sDoctor,'?'),'')

				if	0 < len( @s )											--	smth has changed
				begin
					update	dbo.tbPatient	set	cGndr =	@cGndr,	sInfo=	@sInfo,	idDoctor =	@idDoctor,	dtUpdated=	getdate( )	--, sNote= @sNote
						where	idPatient = @idPatient

					select	@s =	'Pat( ' + cast(@idPatient as varchar) + '|' + isnull(@sPatient,'?') + @s + ' )'
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
grant	execute				on dbo.prPatient_GetIns				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	7.06.8907	+ .dtExpires
--	7.06.5939	- .cBed
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
--	7.04.4919	.idStaff: FK -> tb_User
--	7.04.4896	* tbRoomBed: .idAsnRn|Cn|Ai -> .idAssn1|2|3
--	7.03	* tbRoomBed.idPatient -> tbPatient.idRoom + .tiBed (+ tbPatient.fkPatient_RoomBed)
--			+ xuRoomBed_Patient
--	7.02	- fkRoomBed_Device, + fkRoomBed_Room
--			- .idDoctor (moved into tbPatient)
--			- .idReg* (no need anymore, tbRoom satisfies)
--	7.00	+ 'on delete set null' to fkRoomBed_Event
--			+ .idAsnRn, .idAsnCn, .idAsnAi, .idRegRn, .idRegCn, .idRegAi
--			* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.04
create table	dbo.tbRoomBed
(
	idRoom		smallint		not null	-- device look-up FK
		constraint	fkRoomBed_Room		foreign key references	tbRoom
,	tiBed		tinyint			not null	-- bed index, 0xFF == no bed in room

--,	cBed		char( 1 )		null		-- bed designator
,	idPatient	int				null		-- current patient look-up FK
		constraint	fkRoomBed_Patient	foreign key references tbPatient
--,	idDoctor	int			null			-- current doctor look-up FK
--		constraint	fkRoomBed_Doctor	foreign key references tbDoctor

,	idEvent		int				null		-- live: currently active highest call
		constraint	fkRoomBed_Event		foreign key references	tbEvent	on delete set null
,	tiSvc		tinyint			null		-- live: current service state
,	tiIbed		tinyint			null		-- live: current iBed state
,	idUser1		int				null		-- live: assignee 1
		constraint	fkRoomBed_User1		foreign key references	tb_User
,	idUser2		int				null		-- live: assignee 2
		constraint	fkRoomBed_User2		foreign key references	tb_User
,	idUser3		int				null		-- live: assignee 3
		constraint	fkRoomBed_User3		foreign key references	tb_User
,	dtExpires	smalldatetime	null		-- expiration window for iBed state (tb_OptSys[60])

--,	bActive		bit				not null	
--		constraint	tdRoomBed_Active	default( 1 )
--,	dtCreated		smalldatetime	not null
--		constraint	tdRoomBed_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdRoomBed_Updated	default( getdate( ) )

,	constraint	xpRoomBed	primary key clustered	( idRoom, tiBed )
)
go
create unique nonclustered index	xuRoomBed_Patient	on	dbo.tbRoomBed ( idPatient )		where	idPatient is not null		-- 7.03
		--	a patient can only be in single room-bed [at a time]
go
grant	select, insert, update, delete	on dbo.tbRoomBed		to [rWriter]
grant	select, update					on dbo.tbRoomBed		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a bed definition
--	7.06.8959	* optimized logging
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
create proc		dbo.prCfgBed_InsUpd
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

	select	@s= 'Bed( ' + isnull(cast(@tiBed as varchar), '?') + ' :' + isnull(@cBed, '?') + ', #' + isnull(@cDial, '?') +
	--	-		', f=' + isnull(cast(convert(varchar, convert(varbinary(2), @siBed), 1) as varchar),'?') + '|' +
				', f=' + isnull(cast(@siBed as varchar), '?') + ' )'

	begin	tran

/*		if	exists	(select 1 from tbCfgBed where tiBed = @tiBed)
		begin
			update	dbo.tbCfgBed	set	cBed =	@cBed,	cDial=	@cDial,	dtUpdated=	getdate( )
				where	tiBed = @tiBed

--			select	@s =	@s + '*'
		end
		else
*/		update	dbo.tbCfgBed	set	cBed =	@cBed,	cDial=	@cDial,	dtUpdated=	getdate( )
			where	tiBed = @tiBed
		if	@@rowcount = 0
		begin
			insert	dbo.tbCfgBed	(  tiBed,  cBed,  cDial,  siBed )
					values			( @tiBed, @cBed, @cDial, @siBed )

			select	@s =	@s + '+'
		end

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgBed_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed (in response to HL7 notification via cmd x44)
--	7.06.8965	* optimized logging
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
create proc		dbo.prPatient_UpdLoc
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

/*	if	@idPatient is null
		select	@s =	'Pat_C( '
	else
		select	@s =	'Pat_L( '
*/
	select	@s =	'Pat( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) +	--	'-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					':' + isnull(cast(@tiBed as varchar),'?') + isnull(', ' + cast(@idRoom as varchar) + '|' + @sRoom,'') +
					isnull(', ' + cast(@idPatient as varchar) + '|' + @sPatient,'') + ' )'
/*	if	0 < len( @sRoom )
		select	@s =	@s + '|' + @sRoom

	if	@idPatient is not null
	begin
		select	@s =	@s + ', ' + isnull(cast(@idPatient as varchar),'?')
		if	0 < len( @sPatient )
			select	@s =	@s + '|' + @sPatient
	end
	select	@s =	@s + ' )'
*/

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

	if	@idRoom is null		or	@tiBed is null	--	or	@sPatient is null
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
grant	execute				on dbo.prPatient_UpdLoc				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	7.06.8901	+ r.sSGJR, r.sSGJ, d.bActive, d.dtCreated
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
create view		dbo.vwRoomBed
	with encryption
as
select	r.idUnit, r.sUnit,	rb.idRoom, r.cStn, r.sRoom, r.sSGJR, r.sSGJ, r.sQnRoom,		d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, b.cBed
	,	rb.idEvent,	rb.tiSvc, rb.tiIbed,	p.idPatient, p.sPatient, p.cGndr, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idUser1,  a1.idLvl as idLvl1,  a1.sStfID as sStfId1,  a1.sStaff as sStaff1,  a1.bDuty as bDuty1,  a1.dtDue as dtDue1
	,	rb.idUser2,  a2.idLvl as idLvl2,  a2.sStfID as sStfId2,  a2.sStaff as sStaff2,  a2.bDuty as bDuty2,  a2.dtDue as dtDue2
	,	rb.idUser3,  a3.idLvl as idLvl3,  a3.sStfID as sStfId3,  a3.sStaff as sStaff3,  a3.bDuty as bDuty3,  a3.dtDue as dtDue3
	,	r.idUserG,  r.idLvlG,  r.sStfIdG,  r.sStaffG,  r.bDutyG,  r.dtDueG
	,	r.idUserO,  r.idLvlO,  r.sStfIdO,  r.sStaffO,  r.bDutyO,  r.dtDueO
	,	r.idUserY,  r.idLvlY,  r.sStfIdY,  r.sStaffY,  r.bDutyY,  r.dtDueY
	,	d.bActive, d.dtCreated, rb.dtUpdated
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
grant	select, insert, update			on dbo.vwRoomBed		to [rWriter]
grant	select							on dbo.vwRoomBed		to [rReader]
go
--	----------------------------------------------------------------------------
--	Patients
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.6284	- tbPatient.idRoom, .tiBed
--	7.05.5127
create view		dbo.vwPatient
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
grant	select, insert, update			on dbo.vwPatient		to [rWriter]
grant	select							on dbo.vwPatient		to [rReader]
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
create view		dbo.vwEvent_A
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
grant	select, insert, update, delete	on dbo.vwEvent_A		to [rWriter]
grant	select							on dbo.vwEvent_A		to [rReader]
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
create proc		dbo.prEvent_A_Get
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
grant	execute				on dbo.prEvent_A_Get				to [rWriter]
grant	execute				on dbo.prEvent_A_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active call, filtered according to args
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.5563	+ .tiShelf
--	7.06.5410
create proc		dbo.prEvent_A_GetAll
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
grant	execute				on dbo.prEvent_A_GetAll				to [rWriter]
grant	execute				on dbo.prEvent_A_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns indication whether given master should visualize a call from given coverage areas
--	7.06.8469	* @cSys,@tiGID,@tiJID -> @idRoom
--	7.05.5070	* > 0 -> <> 0	- signed operands produce signed result
--	7.03
create function		dbo.fnEventA_GetByMaster
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
grant	exec				on dbo.fnEventA_GetByMaster			to [rWriter]
grant	exec				on dbo.fnEventA_GetByMaster			to [rReader]
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
create function		dbo.fnEventA_GetTopByUnit
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
grant	select				on dbo.fnEventA_GetTopByUnit		to [rWriter]
grant	select				on dbo.fnEventA_GetTopByUnit		to [rReader]
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
create function		dbo.fnEventA_GetTopByRoom
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
grant	select				on dbo.fnEventA_GetTopByRoom		to [rWriter]
grant	select				on dbo.fnEventA_GetTopByRoom		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns topmost prism show for a given room and segment
--	7.06.8469	* fnEventA_GetByMaster()
--	7.06.8448	* @cSys,@tiGID,@tiJID -> @idRoom
--	7.06.6186
create function		dbo.fnEventA_GetDomeByRoom
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
grant	select				on dbo.fnEventA_GetDomeByRoom		to [rWriter]
grant	select				on dbo.fnEventA_GetDomeByRoom		to [rReader]
go
--	----------------------------------------------------------------------------
--	System activity log: [0x84] call status
--	7.06.8409	- .siDuty0-3, .siZone0-3
--	7.06.5465	* .tiTmrSt -> .tiTmrA, .tiTmrRn -> .tiTmrG, .tiTmrCn -> .tiTmrO, .tiTmrAi -> .tiTmrY
--	7.02	.tiCvrgA* -> .tiCvrg*, siDutyA* -> siDuty*, siZoneA* -> siZone*
--			.tiTmrStat -> .tiTmrSt, .tiTmrCna -> .tiTmrCn, .tiTmrAide -> .tiTmrAi
--	6.03	+ on delete cascade
--	5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--	5.01	.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			.idRn, .idCna, .idAide are in tbEventB4
--	4.01	+ .idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--			.tiPriCA* -> .tiCvrgA*, siDArea* -> siDutyA*, siZArea* -> siZoneA*
--	3.01	- .cBed, cBed -> tiBed (84, 8A, 95)
--	2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	1.08	.cBed2 -> .tiBed (prEvent84_Ins, vwEvent84)
--	1.00
create table	dbo.tbEvent84
(
	idEvent		int				not null
		constraint	xpEvent84	primary key clustered
		constraint	fkEvent84_Event	foreign key references	tbEvent	on delete cascade

,	siPriOld	smallint		not null	-- old priority
,	siPriNew	smallint		not null	-- new priority
,	siIdxOld	smallint		not null	-- old call-index (calculated)
,	siIdxNew	smallint		not null	-- new call-index (calculated)
,	siElapsed	smallint		not null	-- elapsed time (in seconds)
,	tiPrivacy	tinyint			not null	-- privacy status
,	tiTmrA		tinyint			not null	-- STAT-need timer
,	tiTmrG		tinyint			not null	-- Grn-need timer
,	tiTmrO		tinyint			not null	-- Ora-need timer
,	tiTmrY		tinyint			not null	-- Yel-need timer
,	idDoctor	int				null		-- doctor look-up FK
		constraint	fkEvent84_Doctor	foreign key references tbDoctor
,	idPatient	int				null		-- patient look-up FK
		constraint	fkEvent84_Patient	foreign key references tbPatient
,	iFilter		int				not null	-- priority filter mask
,	tiCvrg0		tinyint			not null	-- coverage area 0
,	tiCvrg1		tinyint			not null	-- coverage area 1
,	tiCvrg2		tinyint			not null	-- coverage area 2
,	tiCvrg3		tinyint			not null	-- coverage area 3
,	tiCvrg4		tinyint			not null	-- coverage area 4
,	tiCvrg5		tinyint			not null	-- coverage area 5
,	tiCvrg6		tinyint			not null	-- coverage area 6
,	tiCvrg7		tinyint			not null	-- coverage area 7
)
go
grant	select, insert, update, delete	on dbo.tbEvent84		to [rWriter]
grant	select							on dbo.tbEvent84		to [rReader]
go
--	----------------------------------------------------------------------------
--	Removes expired calls
--	7.06.8966	* optimized
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
create proc		dbo.prEvent_A_Exp
	with encryption
as
begin
	declare		@dt			datetime

	set	nocount	on

	exec	dbo.pr_Module_Act	1											-- mark DB component active

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
grant	execute				on dbo.prEvent_A_Exp				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	7.06.8965	* optimized logging
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
create proc		dbo.prEvent_Ins
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

	select	@s =	'Evt( ' + isnull(cast(convert(varchar, convert(varbinary(1), @idCmd), 1) as varchar),'?') +	-- ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') +
					' #' + isnull(cast(@tiBtn as varchar),'?') + ','
	if	@iAID <> 0	or	@tiStype > 0										--	7.06.7837
		select	@s =	@s + ' ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?')
	select	@s =	@s + ' "' + isnull(@sSrcStn,'?') + '"'
	if	@tiBed < 10
		select	@s =	@s + ':' + cast(@tiBed as varchar)
	if	len(@cDstSys) > 0	or	@tiDstGID > 0	or	@tiDstJID > 0	or	@tiDstRID > 0
		select	@s =	@s + ', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' +
						isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiDstRID as varchar), 2),'?')	-- + ' )'
	if	len(@sInfo) > 0
		select	@s =	@s + ', i="' + @sInfo + '"'
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
grant	execute				on dbo.prEvent_Ins					to [rWriter]
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
--	7.06.8991	+ @sPath
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
create proc		dbo.pr_Module_Reg
(
	@idModule	tinyint
,	@tiModType	tinyint
,	@sModule	varchar( 16 )
,	@bLicense	bit
,	@sVersion	varchar( 16 )
,	@sIpAddr	varchar( 40 )
,	@sHost		varchar( 32 )
,	@sDesc		varchar( 64 )
,	@sPath		varchar( 255 )
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
--		if	@sIpAddr is not null
--			select	@s =	@s + ', ip=' + @sIpAddr

		select	@idType =	61
			,		@s =	@s + ', ' + isnull(@sIpAddr + '|', '') + isnull(@sHost, '?') + ', "' + isnull(@sDesc, '?') + '"'	-- + isnull(cast(@bLicense as varchar), '?')

		if	@bLicense is null	or	@bLicense = 0
			select	@s =	@s + ', l=0'
	end

	begin	tran

		if	exists	(select 1 from dbo.tb_Module with (nolock) where idModule = @idModule)
		begin
			if	@sHost is null	--	and	@sIpAddr is null				-- un-register
				update	dbo.tb_Module
					set		sIpAddr =	null,	sHost=	null,	sVersion =	null,	dtStart =	null,	sArgs =	null,	sPath =	null
					where	idModule = @idModule
			else
				update	dbo.tb_Module
					set		sIpAddr =	@sIpAddr,	sHost=	@sHost,	sPath=	@sPath,	sVersion =	@sVersion,	sDesc =		@sDesc,		bLicense =	@bLicense
					where	idModule = @idModule
		end
		else
		begin
			insert	dbo.tb_Module	(  idModule,  tiModType,  sModule,  sDesc,  bLicense,  sVersion,  sIpAddr,  sHost,  sPath )
					values			( @idModule, @tiModType, @sModule, @sDesc, @bLicense, @sVersion, @sIpAddr, @sHost, @sPath )

			select	@s =	@s + ' +'
		end

		exec	dbo.pr_Log_Ins	@idType, null, null, @s, @idModule

	commit
end
go
grant	execute				on dbo.pr_Module_Reg				to [rWriter]
grant	execute				on dbo.pr_Module_Reg				to [rReader]
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
create proc		dbo.pr_Module_Upd
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
grant	execute				on dbo.pr_Module_Upd				to [rWriter]
grant	execute				on dbo.pr_Module_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates given module's license bit
--	7.06.8143	* optimized trace
--	7.06.7467	* optimized logic
--	7.06.6345	+ @idModule logging (pr_Log_Ins call)
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
grant	execute				on dbo.pr_Module_Lic				to [rWriter]
grant	execute				on dbo.pr_Module_Lic				to [rReader]
go
--	----------------------------------------------------------------------------
--	Sets given module's logging level
--	7.06.8143	* optimized trace
--	7.06.7114	+ @idFeature
--	7.06.7110	* log
--	7.06.6284
create proc		dbo.pr_Module_SetLvl
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
grant	execute				on dbo.pr_Module_SetLvl				to [rWriter]
grant	execute				on dbo.pr_Module_SetLvl				to [rReader]
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
create proc		dbo.prEvent_SetGwState
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
grant	execute				on dbo.prEvent_SetGwState			to [rWriter]
--grant	execute				on dbo.prEvent_SetGwState			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
--	7.06.8965	* optimized logging
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
create proc		dbo.prEvent84_Ins
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

	select	@s =	'E84( ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') +
					' #' + isnull(cast(@tiBtn as varchar),'?') +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					' "' + isnull(@sStn,'?') + '"'	-- + isnull(cast(@tiBed as varchar),'?')
	if	@tiBed < 10
		select	@s =	@s + ':' + cast(@tiBed as varchar)
	select	@s =	@s + ' #' + isnull(@sDial,'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') +
					', ' + isnull(cast(@siIdxOld as varchar),'?') + '-' + isnull(cast(@siIdxNew as varchar),'?') + '|' + isnull(@sCall,'?')	-- + ', i=''' + isnull(@sInfo,'?') +
	if	len(@sInfo) > 0
		select	@s =	@s + ', i="' + @sInfo + '"'
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
grant	execute				on dbo.prEvent84_Ins				to [rWriter]
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
create view		dbo.vwEvent84
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
grant	select, insert, update, delete	on dbo.vwEvent84		to [rWriter]
grant	select							on dbo.vwEvent84		to [rReader]
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
create proc		dbo.prEvent8A_Ins
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
grant	execute				on dbo.prEvent8A_Ins				to [rWriter]
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
create proc		dbo.prEvent95_Ins
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
grant	execute				on dbo.prEvent95_Ins				to [rWriter]
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
create proc		dbo.prEvent98_Ins
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
grant	execute				on dbo.prEvent98_Ins				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Notification subtypes
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.8182	* added '* PCS: ', '> RPP: ', '* WiFi: ' prefixes
--	7.06.6767	+ [0x80..0x82]
--				* [9] -> [0x40]
--	7.06.5491	* [1,2,9,A,D,E]
--	7.06.5371	* tbPcsType[0x02..0x07,0x0A,0x0B]
--	7.06.5351	+ tbPcsType[0x0C..0x0E]
--	7.05.5095
create table	dbo.tbNtfType
(
	idNtfType		tinyint			not null	-- type look-up PK
		constraint	xpNtfType	primary key clustered

,	sNtfType		varchar( 32 )	not null	-- type text
)
go
grant	select							on dbo.tbNtfType		to [rWriter]
grant	select							on dbo.tbNtfType		to [rReader]
go
--	initialize
begin tran
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x01, '> PCS: Ring' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x02, '> PCS: Stop ring' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x03, '< PCS: Success' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x04, '< PCS: in PBX session' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x05, '< PCS: in OAI session' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x06, '< PCS: Inactive' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x07, '< PCS: Terminated' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x08, '< PCS: No response' )
	---	insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x09, 'Page (RPP)' )		--	7.06.6767
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x0A, '> PCS: Alert' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x0B, '< PCS: Expired' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x0C, '< PCS: Duplicate' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x0D, '< PCS: Busy' )
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x0E, '< PCS: Abort' )

		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x40, '> RPP: Page sent' )		--	7.06.6767

		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x80, '> WiFi: Alert sent' )		--	7.06.6767
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x81, '< WiFi: Rejected' )		--	7.06.6767
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x82, '< WiFi: Accepted' )		--	7.06.6767
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x83, '< WiFi: Upgraded' )		--	7.06.6767
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x84, '< WiFi: UnRejected' )		--	7.06.6767
		insert	dbo.tbNtfType ( idNtfType, sNtfType )	values	(  0x85, '< WiFi: UnAccepted' )		--	7.06.6767
commit
go
--	----------------------------------------------------------------------------
--	System activity log: [0x41] pager and phone activity
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.5487	- .tiSeqNum (-> tbEvent.tiDstRID), - .cStatus (-> tbEvent.tiFlags)
--	7.05.5203	* .idUser -> null	(83 may not have synched device owners yet)
--	7.05.5095	+ .idPcsType, .idDvc, .idUser;	- .siIdx, .dtAttempt, .biPager
--				* .cStatus not null -> null
--	6.03	+ on delete cascade
--	5.01
create table	dbo.tbEvent41
(
	idEvent		int				not null
		constraint	xpEvent41	primary key clustered
		constraint	fkEvent41_Event	foreign key references	tbEvent	on delete cascade

,	idNtfType	tinyint			not null	-- PCS action subtype
		constraint	fkEvent41_Type	foreign key references	tbNtfType
,	idDvc		int				not null	-- device look-up FK
		constraint	fkEvent41_Dvc	foreign key references	tbDvc
,	idUser		int				null		-- who was this device assigned to at that moment?
		constraint	fkEvent41_User	foreign key references	tb_User
)
go
grant	select, insert, update, delete	on dbo.tbEvent41		to [rWriter]
grant	select							on dbo.tbEvent41		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
--	7.06.8965	* optimized logging
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
create proc		dbo.prEvent41_Ins
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

	select	@s =	'E41( ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' #' +
					isnull(cast(@tiBtn as varchar),'?') + ' "' + isnull(@sSrcStn,'?') + '"'
	if	@tiBed < 10
		select	@s =	@s + ':' + cast(@tiBed as varchar)
	select	@s =	@s + ', ' + isnull(cast(@idNtfType as varchar),'?') + ' #' + isnull(@sDial,'?') +
					' ' + isnull(cast(@idDvcType as varchar),'?') + '|' + isnull(cast(@idDvc as varchar),'?')
	if	@idNtfType = 64														-- RPP page sent
		select	@s =	@s + ' <' + isnull(cast(@tiSeqNum as varchar),'?') + ':' + isnull(@cStatus,'?') + '>'
	if	len(@sInfo) > 0
		select	@s =	@s + ', "' + @sInfo + '"'
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
grant	execute				on dbo.prEvent41_Ins				to [rWriter]
go
--	----------------------------------------------------------------------------
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8784	* tbStfLvl.idStfLvl	-> idLvl
--	7.06.8475	* tbPcsType -> tbNtfType
--	7.06.8343	* vwStaff.sStaffID -> sStfID
--	7.06.5487	- .tiSeqNum (-> tbEvent.tiDstRID), - .cStatus (-> tbEvent.tiFlags)
--	7.05.5212	* left join vwStaff
--	7.05.5095
create view		dbo.vwEvent41
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
grant	select							on dbo.vwEvent41		to [rWriter]
grant	select							on dbo.vwEvent41		to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8791	* @sCodeVer	-> @sVersion
--	7.04.4953	* @sCodeVer: vc(16), was not sized
--	7.00
create proc		dbo.prEventC1_Ins
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
grant	execute				on dbo.prEventC1_Ins				to [rWriter]
go

--	============================================================================
print	char(10) + '###	Creating 7980 integration objects..'
go
--	----------------------------------------------------------------------------
--	Unit maps
--	7.05.5185	* .sMap not null -> null
--	6.04
create table	dbo.tbUnitMap
(
	idUnit		smallint		not null	-- unit look-up FK
		constraint	fkUnitMap_Unit	foreign key references tbUnit
,	tiMap		tinyint			not null	-- map index [0..3]

,	sMap		varchar( 16 )	null		-- map name

--,	bActive		bit not null			
--		constraint	tdUnitMap_Active		default( 1 )
--,	dtCreated	smalldatetime not null	
--		constraint	tdUnitMap_Created		default( getdate( ) )
--,	dtUpdated	smalldatetime not null	
--		constraint	tdUnitMap_Updated		default( getdate( ) )

	constraint	xpUnitMap	primary key clustered	( idUnit, tiMap )
)
--create unique nonclustered index	xuUnitMap_Active_UnitMap on dbo.tbUnitMap ( idUnit, tiMap )	where	bActive > 0
go
grant	select, insert, update			on dbo.tbUnitMap		to [rWriter]
grant	select, update					on dbo.tbUnitMap		to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given unit's map name
--	7.03
create proc		dbo.prUnitMap_Upd
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
grant	execute				on dbo.prUnitMap_Upd				to [rWriter]
grant	execute				on dbo.prUnitMap_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Unit map cells
--	7.06.8448	* tbUnitMapCell -> tbMapCell	(xpUnitMapCell -> xpMapCell, fkUnitMapCell_Room -> fkMapCell_Room, fkUnitMapCell_UnitMap -> fkMapCell_UnitMap)
--				- .cSys, - .tiGID, -.tiJID
--	7.06.5854	+ "on delete cascade" to fkUnitMapCell_UnitMap
--	7.06.5484	- fkUnitMapCell_Unit (fkUnitMapCell_UnitMap is transitive)
--	7.03	+ .idRoom, -.bSwing
--			+ .tiRID1, tiBtn1, .tiRID2, .tiBtn2, .tiRID4, .tiBtn4
--	6.04
create table	dbo.tbMapCell
(
	idUnit		smallint		not null	-- unit look-up FK
---		constraint	fkMapCell_Unit	foreign key references	tbUnit	-- not necessary
,	tiMap		tinyint			not null	-- map index [0..3]
,	tiCell		tinyint			not null	-- cell index [0..47]
,	constraint	xpMapCell	primary key clustered	( idUnit, tiMap, tiCell )

--,	cSys		char( 1 )		null		-- system ID			-- must point to 'current' device
--,	tiGID		tinyint			null		-- G-ID - gateway
--,	tiJID		tinyint			null		-- J-ID - J-bus
,	idRoom		smallint		null		-- device look-up FK
		constraint	fkMapCell_Room	foreign key references	tbRoom
,	sCell1		varchar( 8 )	null		-- cell name line 1
,	sCell2		varchar( 8 )	null		-- cell name line 2
,	tiRID1		tinyint			null		-- R-ID for Aide LED
,	tiBtn1		tinyint			null		-- button code (0-31)
,	tiRID2		tinyint			null		-- R-ID for CNA LED
,	tiBtn2		tinyint			null		-- button code (0-31)
,	tiRID4		tinyint			null		-- R-ID for RN LED
,	tiBtn4		tinyint			null		-- button code (0-31)

,	constraint	fkMapCell_UnitMap	foreign key ( idUnit, tiMap ) references	tbUnitMap	on delete cascade
)
go
grant	select, insert, update			on dbo.tbMapCell		to [rWriter]
grant	select, update					on dbo.tbMapCell		to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans up invalid map cells
--	7.06.8965	* optimized logging
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
		update	c	set		idRoom =	null
				,	tiRID1 =	null,	tiBtn1 =	null,	tiRID2 =	null,	tiBtn2 =	null,	tiRID4 =	null,	tiBtn4 =	null
			from	dbo.tbMapCell	c
		left join	dbo.tbRoom		r	on	r.idRoom	= c.idRoom		and	r.idUnit	= c.idUnit
			where	c.idRoom is not null	and	r.idRoom is null

		select	@s =	'MapCell( ) ' + cast(@@rowcount as varchar)

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
grant	execute				on dbo.prMapCell_ClnUp				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit with a count of assigned rooms
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--	7.06.5499	+ .iCells
--	7.06.5417	* prUnitMap_GetAll -> prUnitMap_GetByUnit
--				+ .idUnit
--	7.03
create proc		dbo.prUnitMap_GetByUnit
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
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8448	* tbUnitMapCell -> tbMapCell
--	7.06.7844	+ .tiSwing, .sUnits
--	7.05.4990	+ .tiRID[i], .tiBtn[i]
--	7.03	?
create proc		dbo.prMapCell_GetByUnit
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
		update	dbo.tbMapCell
			set		idRoom =	@idRoom,	sCell1 =	@sCell1,	sCell2 =	@sCell2
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
--	Shift definitions
--	7.06.8466	* .tiNotify -> .tiMode (tdShift_Notify -> tdShift_Mode)
--	7.06.6508	* xuShift_Active_UnitIdx -> xuShift_UnitIdx_Act
--	7.06.5914	* [0].sShift 'SHIFT 00' -> '00_shift'
--	7.06.4939	- .tiRouting	(vwShift, prShift_Exp, prShift_Imp, prShift_Upd, prShift_InsUpd)
--	7.05.5010	* .idStaff -> .idUser, fkShift_Staff -> fkShift_User
--	7.04.4966	- .iStamp
--	7.04.4939	[- .tiRouting]
--	7.04.4919	.idStaff: FK -> tb_User
--	7.04.4917	tdShift_Routing 0x0F -> 0x00
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.05	+ .tiRouting, .tiNotify
--	6.02	.sShift: vc(24) -> vc(8)
--	6.00
create table	dbo.tbShift
(
	idShift		smallint		not null	identity( 1, 1 )
		constraint	xpShift		primary key clustered

,	idUnit		smallint		not null	-- unit look-up FK
		constraint	fkShift_Unit	foreign key references tbUnit
,	tiIdx		tinyint			not null	-- shift index [1..3]

,	sShift		varchar( 8 )	not null	-- shift name
,	tBeg		time( 0 )		not null	-- start time
,	tEnd		time( 0 )		not null	-- finish time, automatic (== tBeg of previous shift)
,	tiMode	tinyint				not null	-- notification mode: 0=Auto, 1=SemiAuto, 2=Manual [, 3=FollowConsole]
		constraint	tdShift_Mode	default( 0 )
,	idUser		int				null		-- backup staff look-up FK
		constraint	fkShift_User	foreign key references tb_User

,	bActive		bit				not null
		constraint	tdShift_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdShift_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdShift_Updated	default( getdate( ) )
)
create unique nonclustered index	xuShift_UnitIdx_Act		on	dbo.tbShift ( idUnit, tiIdx )	where	bActive > 0		--	7.06.6508
		--	each unit's active shifts must have unique index
go
grant	select, insert, update			on dbo.tbShift			to [rWriter]
grant	select							on dbo.tbShift			to [rReader]
go
--	initialize
begin tran
	set identity_insert	dbo.tbShift	on

		insert	dbo.tbShift ( idShift, idUnit, tiIdx, sShift, tBeg, tEnd, bActive )	values	( 0, 0, 1, '00_shift', '0:0:0', '0:0:0', 0 )

	set identity_insert	dbo.tbShift	off
commit
go
--	----------------------------------------------------------------------------
--	now that the [tbShift] is defined add FKs to it
alter table	tbUnit	add
	constraint	fkUnit_CurrShift	foreign key (idShift) references tbShift
--,	constraint	fkUnit_PrevShift	foreign key (idShPrv) references tbShift		--	7.05.5086
--	now that the second table is defined add FK
alter table	tbEvent_C	add
	constraint	fkEventC_Shift		foreign key (idShift) references tbShift		--	7.05.6017
alter table	tbEvent_D	add
	constraint	fkEventD_Shift		foreign key (idShift) references tbShift		--	7.06.6402
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
create view		dbo.vwShift
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
grant	select, insert, update			on dbo.vwShift			to [rWriter]
grant	select							on dbo.vwShift			to [rReader]
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
create proc		dbo.prShift_Exp
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
grant	execute				on dbo.prShift_Exp					to [rWriter]
grant	execute				on dbo.prShift_Exp					to [rReader]
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
create proc		dbo.prShift_Imp
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
grant	execute				on dbo.prShift_Imp					to [rWriter]
--grant	execute				on dbo.prShift_Imp					to [rReader]
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
create proc		dbo.prShift_GetAll
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
grant	execute				on dbo.prShift_GetAll				to [rWriter]
grant	execute				on dbo.prShift_GetAll				to [rReader]
--grant	execute				on dbo.prShift_GetByUnit			to [rWriter]
--grant	execute				on dbo.prShift_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates # of shifts for all or given unit(s)
--	7.06.8693
--	7.05.5172
--	7.05.4983
create proc		dbo.prUnit_UpdShifts
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
grant	execute				on dbo.prUnit_UpdShifts				to [rWriter]
grant	execute				on dbo.prUnit_UpdShifts				to [rReader]
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
create proc		dbo.prUnit_GetAll
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
grant	execute				on dbo.prUnit_GetAll				to [rWriter]
grant	execute				on dbo.prUnit_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Call-type routing (per shift)
--	7.06.7587	+ .tResp4:	backup moves into [4], now [0] is for initial delay
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
,	tResp0		time( 0 )		null		-- initial delay
,	tResp1		time( 0 )		null		-- wait interval after 1st responder
,	tResp2		time( 0 )		null		-- wait interval after 2nd responder
,	tResp3		time( 0 )		null		-- wait interval after 3rd responder
,	tResp4		time( 0 )		null		-- wait interval after shift backup

--,	bActive		bit				not null
--		constraint	tdRouting_Active	default( 1 )
--,	dtCreated	smalldatetime	not null
--		constraint	tdRouting_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdRouting_Updated	default( getdate( ) )
)
go
grant	select, insert, update			on dbo.tbRouting		to [rWriter]
grant	select, update					on dbo.tbRouting		to [rReader]
go
--	initialize global defaults
begin
		declare	@siIdx		smallint
			,	@tResp		time( 0 )

		select	@siIdx =	0,	@tResp =	'00:02:00'
		while	@siIdx < 1024
		begin
			if	not	exists( select 1 from tbRouting with (nolock) where idShift = 0 and siIdx = @siIdx )
				insert	tbRouting	( idShift,	siIdx,	tResp0,		tResp1, tResp2, tResp3, tResp4 )
						values		( 0,		@siIdx,	'00:00:00',	@tResp, @tResp, @tResp, @tResp )

			select	@siIdx =	@siIdx + 1
		end
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
create proc		dbo.prRouting_Get
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
--	7.06.7587	+ .tResp4
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
grant	execute				on dbo.prRouting_Set				to [rWriter]
grant	execute				on dbo.prRouting_Set				to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.6508	* xuStfAssn_Active_RoomBedShiftIdx -> xuStfAssn_RmBdShIdx_Act
--	7.05.5079	+ on delete cascade to fkStfAssn_RoomBed
--	7.05.5010	* .idStaff -> .idUser, fkStfAssn_Staff -> fkStfAssn_User
--				- .iStamp, .TempID
--	7.04.4919	.idStaff: FK -> tb_User
--	7.04.4897	* tbStaffAssn -> tbStfAssn, .idStaffAssn -> .idStfAssn
--	7.03	- fkStaffAssn_StaffCover: no longer supported - causes trouble for deletes!
--			- fkStaffAssn_Room, + fkStaffAssn_RoomBed
--	7.02	- fkStaffAssn_Device, + fkStaffAssn_Room
--	7.00	tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssnDef, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--				.idStaffAssnDef -> .idStaffAssn, xpStaffAssnDef -> xpStaffAssn, fkStaffAssn_Device, fkStaffAssn_Shift, fkStaffAssn_Staff,
--					tdStaffAssn_Active, tdStaffAssn_Created, tdStaffAssn_Updated, xuStaffAssnDef_Active_RoomBedShiftIdx -> xuStaffAssn_Active_RoomBedShiftIdx
--			td*_bActive -> td*_bActive, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.02
--	6.00
create table	dbo.tbStfAssn
(
	idAssn		int				not null	identity( 1, 1 )		-- better PK than composite; plus allows 'inactive' records
		constraint	xpStfAssn	primary key clustered

,	idRoom		smallint		not null	-- device look-up FK
	---	constraint	fkStfAssn_Room		foreign key references tbRoom	(replaced by fkStfAssn_RoomBed)
,	tiBed		tinyint			not null	-- bed index FK
,		constraint	fkStfAssn_RoomBed	foreign key	( idRoom, tiBed )	references	tbRoomBed	on delete cascade

,	idShift		smallint		not null	-- shift look-up FK
		constraint	fkStfAssn_Shift		foreign key references	tbShift
,	tiIdx		tinyint			not null	-- responder index [1..3]

,	idUser		int				not null	-- staff look-up FK
		constraint	fkStfAssn_User		foreign key references	tb_User
,	idCvrg		int				null		-- live: currently active coverage ref
	---	constraint	fkStfAssn_StfCvrg	foreign key references	tbStfCvrg	(established later)	CIRCULAR DEPENDENCE IS BAD -- NOT ESTABLISHED

,	bActive		bit				not null							-- need to keep inactive assignments because of coverage history
		constraint	tdStfAssn_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdStfAssn_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdStfAssn_Updated	default( getdate( ) )

---,	constraint	xpStfAssn		primary key clustered ( idRoom, tiBed, idShift, tiIdx )
)
create unique nonclustered index	xuStfAssn_Act_RmBdShIdx	on	dbo.tbStfAssn (idRoom, tiBed, idShift, tiIdx)	where	bActive > 0		--	7.06.6508
		--	no more than one active assignment can exist for each room-bed + shift + index
go
grant	select, insert, update			on dbo.tbStfAssn		to [rWriter]
grant	select							on dbo.tbStfAssn		to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff assignment history (coverage)
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.6053	+ .dShift
--	7.05.5086	+ .dtDue
--	7.05.5079	+ on delete cascade to fkStfCvrg_StfAssn
--	7.04.4897	* tbStaffCover -> tbStfCvrg, .idStaffCover -> .idStfCvrg
--	7.00	.dtBeg,.dtEnd: datetime -> smalldatetime (no need for ms precision)
--			tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--				.idStaffAssn -> .idStaffCover, xpStaffAssn -> xpStaffCover, fkStaffAssn_StaffAssnDef -> fkStaffCover_StaffAssn, fkStaffAssnDef_StaffAssn -> fkStaffAssn_StaffCover
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	6.02
--	6.00
create table	dbo.tbStfCvrg
(
	idCvrg		int				not null	identity( 1, 1 )
		constraint	xpStfCvrg	primary key clustered

,	idAssn		int				not null	-- assignment look-up FK
		constraint	fkStfCvrg_StfAssn	foreign key references	tbStfAssn	on delete cascade
,	dShift		date			not null	-- shift-started date

,	dtBeg		smalldatetime	not null	-- coverage start
,	dBeg		date			not null	-- (date only)
,	tBeg		time( 0 )		not null	-- (time only)
,	tiBeg		tinyint			not null	-- (hour only)
,	dtDue		smalldatetime	not null	-- due finish

,	dtEnd		smalldatetime	null		-- coverage finish
,	dEnd		date			null		-- (date only)
,	tEnd		time( 0 )		null		-- (time only)
,	tiEnd		tinyint			null		-- (hour only)
)
go
grant	select, insert, update			on dbo.tbStfCvrg		to [rWriter]
grant	select							on dbo.tbStfCvrg		to [rReader]
go
--	now that the second table is defined add FK		--	7.03.4883:	no longer supported - causes trouble for deletes!
---alter table		dbo.tbStaffAssn	add
---	constraint	fkStaffAssn_StaffCover	foreign key (idStaffCover) references tbStaffCover
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
create view		dbo.vwStfAssn
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
grant	select							on dbo.vwStfAssn		to [rWriter]
grant	select							on dbo.vwStfAssn		to [rReader]
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
create view		dbo.vwStfCvrg
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
grant	select							on dbo.vwStfCvrg		to [rWriter]
grant	select							on dbo.vwStfCvrg		to [rReader]
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
create proc		dbo.prStfAssn_GetByRoom
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
grant	execute				on dbo.prStfAssn_GetByRoom			to [rWriter]
grant	execute				on dbo.prStfAssn_GetByRoom			to [rReader]
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
create proc		dbo.prStfAssn_Fin
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
grant	execute				on dbo.prStfAssn_Fin				to [rWriter]
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
create proc		dbo.prStfAssn_Exp
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
grant	execute				on dbo.prStfAssn_Exp				to [rWriter]
--grant	execute				on dbo.prStfAssn_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a staff assignment definition
--	7.06.8965	* optimized logging
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8783	* .sStaffID -> sStfID, @
--	7.06.7460	* disable duplicates and close their coverage
--	7.06.5940	* optimize logging
--	7.06.5332	* fix check @idStfAssn > 0 -> @@rowcount
--	7.05.5248	+ dup check (xuStfAssn_Active_RoomBedShiftIdx)
--	7.05.5087	+ trace output
--	7.05.5074
create proc		dbo.prStfAssn_Imp
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

	select	@s =	'SA( ' + isnull(cast(@idAssn as varchar),'?') + ', ' +
					isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' + right('00' + isnull(cast(@tiJID as varchar),'?'), 3) +
					':' + isnull(cast(@tiBed as varchar),'?') +
					', ' + isnull(cast(@idShift as varchar),'?') + '|' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiShIdx as varchar),'?') + ', ' + isnull(cast(@tiIdx as varchar),'?') +
					':' + @sStfID + '=' + isnull(cast(@idUser as varchar),'?') + ' a=' + isnull(cast(@bActive as varchar),'?') + ' ) rm=' + isnull(cast(@idRoom as varchar),'?')

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	begin	tran

	--	if	@bActive > 0	and	(@idRoom is null	or	@idShift is null	or	@idUser is null)
		if	@idRoom is null		or	@idShift is null	or	@idUser is null
		begin
			if	@bActive > 0												--	7.06.896
				exec	dbo.pr_Log_Ins	47, null, null, @s, 94				-- error only if assn is active!

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
grant	execute				on dbo.prStfAssn_Imp				to [rWriter]
--grant	execute				on dbo.prStfAssn_Imp				to [rReader]
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
create proc		dbo.prStfAssn_GetByUnit
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
grant	execute				on dbo.prStfAssn_GetByUnit			to [rWriter]
grant	execute				on dbo.prStfAssn_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
--	7.06.8965	* optimized logging
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
create proc		dbo.prStfAssn_InsUpdDel
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
				select	@s =	@s + '=' + cast(@idAssn as varchar)
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
grant	execute				on dbo.prStfAssn_InsUpdDel			to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignment coverage (executes every minute, as close to :00s as possible)
--	7.06.8966	* prStfCvrg_InsFin	-> prHealth_Min
--				+ exec prEvent_A_Exp
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
create proc		dbo.prHealth_Min
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

	begin	tran

		exec	dbo.prHealth_Stats											-- update DB size stats
	--	exec	dbo.pr_Module_Act	1										-- mark DB component active (since this sproc is executed every minute)
		exec	dbo.prEvent_A_Exp											-- remove expired calls (moved from Config svc)

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
grant	execute				on dbo.prHealth_Min					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
--	7.06.8959	* optimized logging
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
create proc		dbo.prCfgLoc_SetLvl
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@dtNow		datetime
		,		@tBeg		time( 0 )
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

		select	@s =	'Locs( ) -'

		-- deactivate non-matching units
		update	u
			set		u.bActive=	0,	u.dtUpdated =	@dtNow
			from	dbo.tbUnit		u
		left join 	dbo.tbCfgLoc	l	on	l.idLoc		= u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1		and	l.idLoc is null
		select	@s =	@s + cast(@@rowcount as varchar) + ' u, -'

		-- deactivate shifts for inactive units
		update	s
			set		s.bActive=	0,	s.dtUpdated =	@dtNow
			from	dbo.tbShift		s
			join	dbo.tbUnit		u	on	u.idUnit	= s.idUnit		and	u.bActive = 0
			where	s.bActive = 1
		select	@s =	@s + cast(@@rowcount as varchar) + ' s'

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
						select	@s =	'Loc( ) [' + cast(@idUnit as varchar) + '] *' + cast(@@rowcount as varchar) + ' sh'
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
grant	execute				on dbo.prCfgLoc_SetLvl				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates mode and backup of a given shift
--	7.06.8965	* optimized logging
--	7.06.8846	* optimized logging
--	7.06.8693
create proc		dbo.prShift_Upd
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

	select	@s =	'Shft( ' + isnull(cast(@idUnit as varchar),'?') + '|' + isnull(cast(@sUnit as varchar),'?') +
					' ' + isnull(cast(@idShift as varchar),'?') + '|' + isnull(cast(@tiIdx as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') +
					', nm=' + isnull(cast(@tiMode as varchar),'?') + ' bk=' + isnull(cast(@idOper as varchar),'?') + '|' + isnull(cast(@sOper as varchar),'?') + ' )'
--					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +

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
grant	execute				on dbo.prShift_Upd					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
--	7.06.8965	* optimized logging
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
create proc		dbo.prShift_InsUpd
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

	select	@s =	'Shft( ' + isnull(cast(@idUnit as varchar),'?') + '|' + isnull(cast(@sUnit as varchar),'?') +
					' ' + isnull(cast(@idShift as varchar),'?') + '|' + isnull(cast(@tiIdx as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') +
					', a=' + isnull(cast(@bActive as varchar),'?') + ' )'
--	select	@s =	'Shft_IU( ' + isnull(cast(@idUnit as varchar),'?') + ':' + isnull(cast(@tiIdx as varchar),'?') + ' ' + isnull(cast(@idShift as varchar),'?') +
--					'|' + isnull(cast(@sShift as varchar),'?') + '|' + isnull(convert(char(5), @tBeg, 108),'?') + '-' + isnull(convert(char(5), @tEnd, 108),'?') +
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
grant	execute				on dbo.prShift_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Sets user's Duty and Break states
--	7.06.8966	* prStfCvrg_InsFin	-> prHealth_Min
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
create proc		dbo.prStaff_SetDuty
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

					exec	dbo.prHealth_Min								-- init coverage
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
grant	execute				on dbo.prStaff_SetDuty				to [rWriter]
--grant	execute				on dbo.prStaff_SetDuty				to [rReader]
go
--	----------------------------------------------------------------------------
--	Initializes or finalizes AD-Sync
--	7.06.8965	* optimized logging
--	7.06.8783	* tb_User.bOnDuty	-> bDuty
--	7.06.8726	+ reset duty for inactive (',	bDuty =	0,	dtDue =	null') in finish path to satisfy [tv_User_Duty]
--	7.06.7299	+ @idModule
--	7.06.7279	* optimized logging
--	7.06.7251	- 'and	bActive > 0' from that rename
--	7.06.7244	+ rename login to GUID for accounts removed from AD (left disabled in our DB)
--					prepend a comment in .sDesc, describing this and record original login
--	7.06.6019
create proc		dbo.pr_User_SyncAD
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

	select	@s =	'Usrs( ' + cast(@bActive as varchar) + ' ) '

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
grant	execute				on dbo.pr_User_SyncAD				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
--	7.06.8986	+ reset tb_User.tiFails when active user is unlocked in AD but gets failed/locked in DB (being out of AD-comm)
--	7.06.8965	* optimized logging
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
create proc		dbo.pr_User_InsUpdAD
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
	declare		@k			tinyint
		,		@s			varchar( 255 )
		,		@ti			tinyint
		,		@utSynched	smalldatetime		-- (UTC) time of last AD-Sync

	set	nocount	on
	set	xact_abort	on

	if	@idUser = 4															-- System
		select	@idUser =	null

	select	@idOper =	idUser,		@utSynched =	utSynched,	@ti =	tiFails
		from	dbo.tb_User with (nolock)
		where	gGUID = @gGUID

	select	@s =	'Usr( ' + isnull(cast(@idOper as varchar), '?') + '|' + @sUser +
					' ' + isnull(upper(cast(@gGUID as char(36))), '?') + ' ut=' + isnull(convert(varchar, @utSynched, 120), '?') +
					isnull(' "' + @sFrst + '"', '') + isnull(' ''' + @sMidd + '''', '') + isnull(' "' + @sLast + '"', '') +
					isnull(', ' + @sEmail, '')		+ isnull(', d="' + @sDesc + '"', '') +
					' k='	+ cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' ad=' + isnull(convert(varchar, @dtUpdated, 120), '?') + ' )'
	begin	tran

		if	@idOper = 0		or	@idOper is null								-- user not found
		begin
			if	0 < @bActive												--	7.06.7094	only import *active* users!
			begin
				insert	dbo.tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
						values		( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
				select	@idOper =	scope_identity( )

				select	@k =	102,	@s =	@s + '=' + cast(@idOper as varchar)		--	7.06.7129	--	237
			end
			else															--	7.06.7094
				select	@k =	101,	@s =	@s + '^'	--	7.06.7129	--	2	-- *inactive skipped*
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

				select	@k =	103,	@s =	@s + '*'	--	7.06.7129	--	238
		end
		else
		if	0 < @bActive	and	@tiFails = 0	and	0 < @ti					-- active unlocked user in AD is failed/locked in DB (out of AD-comm)
		begin
			update	dbo.tb_User
				set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
					,	tiFails =	0,		utSynched=	getutcdate( )
				where	idUser = @idOper

				select	@k =	103,	@s =	@s + '*'	--	7.06.8986
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

				select	@k =	104	--,	@s =	'Usr_AD( ' + @s + ' )'		--	7.06.7129,	7.06.7251	--	238
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
grant	execute				on dbo.pr_User_InsUpdAD				to [rWriter]
--grant	execute				on dbo.pr_User_InsUpdAD				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
--	7.06.9005	* deferred prStaff_SetDuty call for tracing order
--	7.06.8965	* optimized logging
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
create proc		dbo.pr_User_InsUpd
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
		,		@bNew		bit

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

	select	@s =	'User( ' + isnull(cast(@idOper as varchar), '?') + '|' + @sUser,	@bNew=	0

	if	@sFrst = char(0x7F) + 'RTLS'
		select	@s =	@s + ' "' + @sFrst + '"'
	else
		select	@s =	@s + isnull(' "' + @sFrst + isnull('|' + @sMidd, '') + isnull('|' + @sLast, '') + '"', '') +
					--	isnull(' "' + @sFrst + '"', '') + isnull(' ''' + @sMidd + '''', '') + isnull(' "' + @sLast + '"', '') +
						isnull(', ' + @sEmail, '')		+ isnull(' d="' + @sDesc + '"', '') +
						isnull(' I=' + @sStfID, '')

	select	@s =	@s								+ isnull(' L=' + cast(@idLvl as varchar), '') +
					isnull(' c=' + @sCode, '')		+ isnull(' D=' + cast(@bDuty as varchar), '') +
					isnull(' R=' + @sRoles, '')		+ isnull(' T=' + @sTeams, '')		+ isnull(', U=' + @sUnits, '') +
					' k='	+ cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' )'
/*	select	@s =	'User( ' + isnull(cast(@idOper as varchar), '?') + '|' + @sUser +
					isnull(' "' + @sFrst + isnull('|' + @sMidd, '') + isnull('|' + @sLast, '') + '"', '') +
				--	isnull(' "' + @sFrst + '"', '') + isnull(' ''' + @sMidd + '''', '') + isnull(' "' + @sLast + '"', '') +
					isnull(', ' + @sEmail, '')		+ isnull(' d="' + @sDesc + '"', '') +
					isnull(' I=' + @sStfID, '')		+ isnull(' L=' + cast(@idLvl as varchar), '') +
					isnull(' c=' + @sCode, '')		+ isnull(' D=' + cast(@bDuty as varchar), '') +
					isnull(' R=' + @sRoles, '')		+ isnull(' T=' + @sTeams, '')		+ isnull(', U=' + @sUnits, '') +
					' k='	+ cast(@tiFails as varchar) + ' a=' + cast(@bActive as varchar) + ' )'
*/	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	dbo.tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc, sStaff,  sStfID,  idLvl,  sCode,  bActive )
					values		( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc,    ' ', @sStfID, @idLvl, @sCode, @bActive )
			select	@idOper =	scope_identity( ),	@bNew=	1
--	-		exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bDuty, 0	--	.8488	must follow table update

			select	@idType =	237,	@s =	@s + '=' + cast(@idOper as varchar)
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

			select	@idType =	238
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

		if	0 < @bNew
			exec	dbo.prStaff_SetDuty		@idModule, @idOper, @bDuty, 0	--	.8488	must follow table update	/.9005	deferred for tracing order

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
grant	execute				on dbo.pr_User_InsUpd				to [rWriter]
--grant	execute				on dbo.pr_User_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff assigned to each room-bed (earliest responders of each kind)
--	7.06.8784	* tb_User.idStfLvl	-> idLvl
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
/*
create function		dbo.fnStfAssn_GetByShift
(
	@idShift	smallint					-- shift look-up FK
)
	returns table
	with encryption
as
return
	select	r.idRoom, r.tiBed
		,	min(case when r.idLvl=4 then a.idUser	else null end)	as	idUser4
		,	min(case when r.idLvl=4 then s.sStaff	else null end)	as	sStaff4
		,	min(case when r.idLvl=2 then a.idUser	else null end)	as	idUser2
		,	min(case when r.idLvl=2 then s.sStaff	else null end)	as	sStaff2
		,	min(case when r.idLvl=1 then a.idUser	else null end)	as	idUser1
		,	min(case when r.idLvl=1 then s.sStaff	else null end)	as	sStaff1
		from
			(select	sa.idRoom, sa.tiBed, s.idLvl, min(sa.tiIdx) tiIdx			-- (earliest responders of each kind)
				from	dbo.tbStfAssn sa	with (nolock)
				join	dbo.tbShift sh		with (nolock)	on	sh.bActive > 0	and	sh.idShift	= sa.idShift	and	sh.idShift	= @idShift
				join	dbo.vwStaff	s		with (nolock)	on	s.bActive > 0	and	s.idUser	= sa.idUser
				where	sa.bActive > 0
				group	by	sa.idRoom, sa.tiBed, s.idLvl)	r
			join	dbo.tbStfAssn	a	with (nolock)	on	a.bActive > 0	and	a.idRoom	= r.idRoom		and	a.tiBed		= r.tiBed	and	a.tiIdx = r.tiIdx
			join	dbo.tbShift		sh	with (nolock)	on	sh.bActive > 0	and	sh.idShift	= a.idShift		and	sh.idShift	= @idShift
			join	dbo.vwStaff		s	with (nolock)	on	s.bActive > 0	and	s.idUser	= a.idUser		and	s.idLvl		= r.idLvl
		group	by	r.idRoom, r.tiBed
---		order	by	r.idRoom, r.tiBed
g o
grant	select				on dbo.fnStfAssn_GetByShift			to [rWriter]
grant	select				on dbo.fnStfAssn_GetByShift			to [rReader]
*/
go

--	============================================================================
print	char(10) + '###	Creating RTLS integration objects..'
go
--	----------------------------------------------------------------------------
--	Receivers
--	7.04.4958	- .idRcvrType, fkRtlsRcvr_Type, .sPhone
--	7.04.4892	* .idDevice -> .idRoom, - fkRtlsRcvr_Device, + fkRtlsRcvr_Room
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.03
create table	dbo.tbRtlsRcvr
(
	idReceiver	smallint		not null	-- 1-65535 (unsigned)
		constraint	xpRtlsRcvr	primary key clustered

,	sReceiver	varchar( 255 )	null		-- name
,	idRoom		smallint		null		-- 790 device look-up FK
		constraint	fkRtlsRcvr_Room		foreign key references tbRoom

,	bActive		bit				not null
		constraint	tdRtlsRcvr_Active	default( 1 )
,	dtCreated	smalldatetime	not null	
		constraint	tdRtlsRcvr_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null	
		constraint	tdRtlsRcvr_Updated	default( getdate( ) )
)
go
grant	select, insert, update			on dbo.tbRtlsRcvr		to [rWriter]
grant	select, update					on dbo.tbRtlsRcvr		to [rReader]
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
create view		dbo.vwRtlsRcvr
	with encryption
as
select	r.idReceiver, r.sReceiver	--, r.idRcvrType, t.sRcvrType, r.sPhone, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	r.idRoom, d.cStn, d.sStn, d.sSGJ	--, d.sSGJR
	,	d.sSGJ + ' [' + d.cStn + '] ' + d.sStn	as sQnStn
	,	r.bActive, r.dtCreated, r.dtUpdated
	from	dbo.tbRtlsRcvr	r	with (nolock)
left join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= r.idRoom
go
grant	select, insert, update, delete	on dbo.vwRtlsRcvr		to [rWriter]
grant	select							on dbo.vwRtlsRcvr		to [rReader]
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
create proc		dbo.prRtlsRcvr_GetAll
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
grant	execute				on dbo.prRtlsRcvr_GetAll			to [rWriter]
grant	execute				on dbo.prRtlsRcvr_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given receiver
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	6.03
create proc		dbo.prRtlsRcvr_InsUpd
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
grant	execute				on dbo.prRtlsRcvr_InsUpd			to [rWriter]
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
create proc		dbo.prRtlsRcvr_UpdDvc
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
grant	execute				on dbo.prRtlsRcvr_UpdDvc			to [rWriter]
grant	execute				on dbo.prRtlsRcvr_UpdDvc			to [rReader]
go
--	----------------------------------------------------------------------------
--	Badges
--	7.06.7261	- .idRcvrLast (fkRtlsBadge_LastRcvr), .dtRcvrLast, .idRoom (fkRtlsBadge_Room)
--				* .idRcvrCurr -> .idReceiver (fkRtlsBadge_CurrRcvr -> fkRtlsBadge_Receiver), .dtRcvrCurr -> .dtReceiver
--	7.05.5010	* tbStfDvc -> tbDvc,	idStfDvc -> idDvc, sdStfDvc -> sdDvc,	.idStaff -> .idUser,	fkRtlsBadge_StfDvc -> fkRtlsBadge_Dvc
--	7.04.4968	- alter
--	7.04.4958	- .idBdgType, fkRtlsBadge_Type
--	7.04.4898	- fkRtlsBadge_Device, + fkRtlsBadge_Room
--	7.04.4897	* tbRtlsBadgeType -> tbRtlsBdgType, .idBadgeType -> .idBdgType, .sBadgeType -> .sBdgType
--				* tbStaffDvc -> tbStfDvc, .idStaffDvc -> .idStfDvc, .sStaffDvc -> .sStfDvc
--	7.02	- .idStaff (no need now, tbStaffDvc.idStaff keeps relationship)
--			* prRtlsBadge_InsUpd: inserting into tbStaffDvc (requires 'alter' permission)
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			+ fkRtlsBadge_StaffDvc (* .idBadge: smallint -> int)
--	6.03
create table	dbo.tbRtlsBadge
(
	idBadge		int				not null	-- 24 bits: 1..16777215 (0x00FFFFFF) - RTLS badges
		constraint	xpRtlsBadge	primary key clustered
		constraint	fkRtlsBadge_Dvc		foreign key references	tbDvc

,	dtEntered	datetime		null		-- live: when entered the room
--,	idRoom		smallint		null		-- live: room look-up FK
--		constraint	fkRtlsBadge_Room	foreign key references	tbRoom
	---	constraint	fkRtlsBadge_Device	foreign key references	tbDevice
,	idReceiver	smallint		null		-- live: current receiver look-up FK
		constraint	fkRtlsBadge_Receiver	foreign key references	tbRtlsRcvr
,	dtReceiver	datetime		null		-- live: when registered by current rcvr
--,	idRcvrCurr	smallint		null		-- live: current receiver look-up FK
--		constraint	fkRtlsBadge_CurrRcvr	foreign key references	tbRtlsRcvr
--,	dtRcvrCurr	datetime		null		-- live: when registered by current rcvr
--,	idRcvrLast	smallint		null		-- live: last receiver look-up FK
--		constraint	fkRtlsBadge_LastRcvr	foreign key references	tbRtlsRcvr
--,	dtRcvrLast	datetime		null		-- live: when registered by last rcvr

,	bActive		bit				not null
		constraint	tdRtlsBadge_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdRtlsBadge_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdRtlsBadge_Updated	default( getdate( ) )
)
go
grant	select, insert, update			on dbo.tbRtlsBadge		to [rWriter]
grant	select							on dbo.tbRtlsBadge		to [rReader]
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
create view		dbo.vwRtlsBadge
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
grant	select, insert, update, delete	on dbo.vwRtlsBadge		to [rWriter]
grant	select							on dbo.vwRtlsBadge		to [rReader]
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
create proc		dbo.prRtlsBadge_GetAll
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
grant	execute				on dbo.prRtlsBadge_GetAll			to [rWriter]
grant	execute				on dbo.prRtlsBadge_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge (used by RTLS demo)
--	7.06.9005	* action by '2|admin' -> '4|system'
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
create proc		dbo.prRtlsBadge_InsUpd
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
				exec	dbo.pr_User_InsUpd	72, 4, @idUser out, @sUser, 0, 0, @sRtls, null, @sUser, null, null, @sUser, @idLvl, null, null, null, null, 1, 1
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
grant	execute				on dbo.prRtlsBadge_InsUpd			to [rWriter]
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
create proc		dbo.prRtlsBadge_RstLoc
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
grant	execute				on dbo.prRtlsBadge_RstLoc			to [rWriter]
--grant	execute				on dbo.prRtlsBadge_RstLoc			to [rReader]
go
--	----------------------------------------------------------------------------
--	Resets .bConfig for all devices under a given GW, resets corresponding rooms' state
--	7.06.8959	* optimized logging
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

	select	@s =	'Init( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + ' ) '

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
--	7.06.8959	* optimized logging
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

	select	@s =	'Act( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + ' ) +'

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
create proc		dbo.prRtlsRcvr_Init
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
grant	execute				on dbo.prRtlsRcvr_Init				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Deactivates all badges before RTLS config download
--	7.06.7279	* optimized logging
--	7.06.7117	+ @idModule
--	7.05.5222	+ updating tbDvc.bActive
--	7.05.5087
create proc		dbo.prRtlsBadge_Init
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
grant	execute				on dbo.prRtlsBadge_Init				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
--	7.06.9007	* skip RTLS auto-badges if @tiFlags & 0x80 > 0
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
create proc		dbo.prDvc_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@idDvcType	tinyint				-- 1=Badge, 2=Pager, 4=Phone, 0xFF=any
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes	active?
,	@tiFlags	tinyint		= null	-- null=any, 0=non-assignable, 1=assignable (for pagers 0==group/team), 2=auto (badges), 0x80=skip auto (badges)
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
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@tiFlags is null	or	d.tiFlags & @tiFlags = @tiFlags & 0x7F	and	(@tiFlags & 0x80 = 0	or	d.tiFlags & 0x02 = 0))
		and		(@bStaff is null	or	@bStaff = 0	and	d.idUser is null	or	@bStaff = 1	and	d.idUser is not null )
		and		(@idLvl is null		or	@idLvl = 0	and	d.idLvl is null		or	d.idLvl = @idLvl)
		and		(@sDvc is null		or	d.sDial like @sDvc)					--	7.06.8684
		and		(@idUnit is null	or	d.idDvcType = 1		or	d.idDvcType = 8
									or	d.idDvc	in	(select idDvc from dbo.tbDvcUnit with (nolock) where idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
grant	execute				on dbo.prDvc_GetByUnit				to [rWriter]
grant	execute				on dbo.prDvc_GetByUnit				to [rReader]
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
create proc		dbo.prDvc_GetByDial
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
grant	execute				on dbo.prDvc_GetByDial				to [rWriter]
grant	execute				on dbo.prDvc_GetByDial				to [rReader]
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
create proc		dbo.prDvc_GetWiFi
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
grant	execute				on dbo.prDvc_GetWiFi				to [rWriter]
grant	execute				on dbo.prDvc_GetWiFi				to [rReader]
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
create proc		dbo.prRtlsBadge_UpdLoc
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
grant	execute				on dbo.prRtlsBadge_UpdLoc			to [rWriter]
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
create proc		dbo.prRoom_GetRtls
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
grant	execute				on dbo.prRoom_GetRtls				to [rWriter]
grant	execute				on dbo.prRoom_GetRtls				to [rReader]
go
--	----------------------------------------------------------------------------
--	7981 - Extends RTLS healing expiration for rooms with staff present
--	7.06.7292	+ tbRoom.idUser4, .idUser2, .idUser1
--				* tb_OptSys[31]->[8]
--	7.06.6290	* tb_OptSys[9] -> tb_OptSys[31]
--	7.06.6226
create proc		dbo.prRoom_UpdRtls
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
grant	execute				on dbo.prRoom_UpdRtls				to [rWriter]
grant	execute				on dbo.prRoom_UpdRtls				to [rReader]
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
create proc		dbo.prRoomBed_GetByUnit
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
--grant	execute				on dbo.prRoomBed_GetByUnit			to [rWriter]
grant	execute				on dbo.prRoomBed_GetByUnit			to [rReader]
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
--grant	execute				on dbo.prMapCell_GetByMap			to [rWriter]
grant	execute				on dbo.prMapCell_GetByMap			to [rReader]
go
--	----------------------------------------------------------------------------
--	Data source for 7983rh.CallList.aspx (based on dbo.prRoomBed_GetByUnit)
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.6164
create proc		dbo.prCallList_GetAll
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
--grant	execute				on dbo.prCallList_GetAll			to [rWriter]
grant	execute				on dbo.prCallList_GetAll			to [rReader]
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
create proc		dbo.prRoomBed_GetAssn
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
grant	execute				on dbo.prRoomBed_GetAssn			to [rWriter]
--grant	execute				on dbo.prRoomBed_GetAssn			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns assigned room-beds for the given staff member
--	7.06.8796	* .idStfAssn -> .idAssn, @
--				* .idStfCvrg -> .idCvrg, @
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.5437
create proc		dbo.prStaff_GetAssn
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
grant	execute				on dbo.prStaff_GetAssn				to [rWriter]
grant	execute				on dbo.prStaff_GetAssn				to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating report objects..'
go
--	----------------------------------------------------------------------------
--	Report templates
--	7.06.8495	* [11]
--	7.06.8417	* [23]
--	7.06.7310	+ [10,11],	* [2,22]
--	7.06.6446	* [22]
--	7.06.6417	+ [22..24]
--	7.06.6401	+ .tiFlags
--	7.06.6059	* [7]
--	7.06.5329	+ [9]
--	7.05.5169	* [7],[8]	.sClass
--	6.02	+ <7, ..>, <8, ..>
--	6.00	tbRptTempl -> tbReport, revised
--	2.01	tbRptMaster -> tbRptTempl
--	1.00
create table	dbo.tbReport
(
	idReport	smallint		not null
		constraint	xpReport	primary key clustered

,	siOrder		smallint		not null	-- display order
,	tiFlags		tinyint			not null	-- 1=Regular, 2=Clinic
,	sReport		varchar( 64 )	not null	-- template name
,	sRptName	varchar( 64 )	not null	-- user-friendly name
,	sClass		varchar( 32 )	not null	-- implementation class name
)
---	create unique nonclustered index	xuReport	on dbo.tbReport ( sReport )
go
--grant	select							on dbo.tbReport			to [rWriter]
grant	select							on dbo.tbReport			to [rReader]
go
--	initialize
begin tran
	---	insert	dbo.tbReport ( idReport, siOrder, sClass, sReport, sRptName )
	---				values	(  1, 200,	3,	'xrSysActSum',		'System Activity (Summary)',	'Summary System Activity' )
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  2, 990,	3,	'xrSysActDtl',		'System Activity (Detailed)',	'Detailed System Activity' )

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  3,  30,	1,	'xrCallStatSum',	'Call Statistics (Summary)',	'Summarized Call Statistics' )
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  4,  40,	1,	'xrCallStatDtl',	'Call Statistics (Detailed)',	'Hourly Call Statistics' )

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  5,  50,	1,	'xrCallActSum',		'Call Activity (Summary)',		'Summarized Patient Activity' )
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  6,  60,	1,	'xrCallActDtl',		'Call Activity (Detailed)',		'Detailed Patient Activity' )

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  7,  80,	1,	'xrStfAssn',		'Staff Assignment (Current)',	'Current Staff Assignment' )	--	7.06.6059
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  8,  90,	1,	'xrStfCvrg',		'Staff Coverage (History)',		'Staff Coverage History' )		--	6.03

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	(  9,  70,	1,	'xrCallActExc',		'Call Activity (Exceptions)',	'Patient Activity Exceptions' )	--	7.06.5329

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 10, 100,	1,	'xrRndStatSum',		'Rounding (Summary)',			'Summarized Rounding' )
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 11, 110,	1,	'xrRndStatDtl',		'Rounding (Daily)',				'Daily Rounding' )

	---	insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
	---				values	( 21,  10,	2,	'xrCliPatSum',		'Patient Wait Times (Summary)',	'Summarized Patient Wait Times' )	--	7.06.6402
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 22, 220,	2,	'xrCliPatDtl',		'Clinic: Patient Wait Times',	'Clinic Patient Wait Times' )		--	.6446

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 23, 230,	2,	'xrCliStfSum',		'Clinic: Activity (Summary)',	'Summarized Clinic Activity' )
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 24, 240,	2,	'xrCliStfDtl',		'Clinic: Activity (Detailed)',	'Detailed Clinic Activity' )
commit
go
--	----------------------------------------------------------------------------
--	Returns all report templates
--	7.06.6401	+ .tiFlags
--	7.03
create proc		dbo.prReport_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idReport, sReport, sRptName, sClass, tiFlags
		from	dbo.tbReport	with (nolock)
		order	by	siOrder
end
go
grant	execute				on dbo.prReport_GetAll				to [rWriter]
grant	execute				on dbo.prReport_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Role report access permissions
--	7.06.7310	+ [10,11], [22..24]
--	7.06.6508	* xpReportRole -> xp_RoleRpt
--	7.04.4897	* tb_RoleReport -> tb_RoleRpt
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.05	tbReportRole -> tb_RoleReport
--	6.02	+ .dtCreated
--			+ <7, ..>, <8, ..>
--	6.00
create table	dbo.tb_RoleRpt
(
	idRole		smallint		not null
		constraint	fk_RoleRpt_Role		foreign key references	tb_Role
,	idReport	smallint		not null
		constraint	fk_RoleRpt_Report	foreign key references	tbReport

,	dtCreated	smalldatetime	not null
		constraint	td_RoleRpt_Created	default( getdate( ) )

,	constraint	xp_RoleRpt	primary key clustered ( idRole, idReport )
)
go
--grant	select							on dbo.tb_RoleRpt		to [rWriter]
grant	select, insert, update, delete	on dbo.tb_RoleRpt		to [rReader]
go
--	initialize
begin tran
	--	if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=1)
	--		insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 1 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=2)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 2 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=3)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 3 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=4)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 4 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=5)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 5 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=6)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 6 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=7)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 7 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=8)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 8 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=9)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 9 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=10)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 10 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=11)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 11 )

		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=22)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 22 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=23)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 23 )
		if	not	exists	(select 1 from dbo.tb_RoleRpt where idRole=1 and idReport=24)
			insert	dbo.tb_RoleRpt	( idRole, idReport )	values	( 1, 24 )
commit
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
grant	execute				on dbo.pr_RoleRpt_Set				to [rWriter]
grant	execute				on dbo.pr_RoleRpt_Set				to [rReader]
go
--	----------------------------------------------------------------------------
--	Report filters
--	7.04.4919	.idUser: smallint -> int
--	7.03	* .xFilter: vc(8000) -> xml
--	7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--	6.02	+ .dtCreated, .dtUpdated
--	6.00	* tbRptFilter -> tbFilter: .idRptFilter -> .idFilter, .sRptFilter -> .sFilter, .sXmlFilter -> .xFilter, xuRptFilter -> xuFilter
--	2.01	* .sXmlFilter: vc(4096) -> vc(8000)
--			- .nXmlFilter
--	1.08	- .idRptMaster:  filters no longer bound to specific report
--			+ xuRptFilter
--	1.00
create table	dbo.tbFilter
(
	idFilter	smallint		not null	identity( 1, 1 )	--	maybe int?
		constraint	xpFilter	primary key clustered

,	idUser		int				null		-- public, if null
		constraint	fkFilter_User	foreign key references tb_User

,	sFilter		varchar( 64 )	not null	-- filter name
---	s_Filter	as	lower( sFilter )	-- filter-name, lower-cased
---		constraint	xu_Filter	unique,
--,	xFilter		varchar( 8000 ) not null	-- filter definition (xml)
,	xFilter		xml				null		-- filter definition (xml)

,	dtCreated	smalldatetime	not null
		constraint	tdFilter_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdFilter_Updated	default( getdate( ) )
)
create unique nonclustered index	xuFilter	on dbo.tbFilter ( idUser, sFilter )
		---	filter names should be unique per user
go
--grant	select							on dbo.tbFilter			to [rWriter]
grant	select, insert, update, delete	on dbo.tbFilter			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all filters for given user, [public] first, ordered by name
--	7.05.5064	+ check user for IsAdmin
--	7.05.5044	* @idUser: smallint -> int
--	7.03
create proc		dbo.prFilter_GetByUser
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
grant	execute				on dbo.prFilter_GetByUser			to [rWriter]
grant	execute				on dbo.prFilter_GetByUser			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns an existing filter definition
--	7.03
create proc		dbo.prFilter_Get
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
grant	execute				on dbo.prFilter_Get					to [rWriter]
grant	execute				on dbo.prFilter_Get					to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing filter
--	7.05.5044	* @idUser: smallint -> int
--	7.03
create proc		dbo.prFilter_InsUpd
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
grant	execute				on dbo.prFilter_InsUpd				to [rWriter]
grant	execute				on dbo.prFilter_InsUpd				to [rReader]
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
--	----------------------------------------------------------------------------
--	Report call filters (active during a user session)
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.04.4896	* tbDefCall -> tbCall
--	6.00	tbRptSessCall -> tb_SessCall, .idRptSess -> .idSess
--	2.01	- .tVoMax, .tStMax
--			+ .siIdx
--	1.08	renamed tbRptFltVal -> tbRptSessCall
--	1.06	tbFltVal (tbRptFltVal) linked to tbRptSess now
--	1.05
create table	dbo.tb_SessCall
(
	idSess		int				not null
		constraint	fk_SessCall_Sess	foreign key references	tb_Sess
,	idCall		smallint		not null
		constraint	fk_SessCall_Call	foreign key references	tbCall

,	siIdx		smallint		not null		-- call-index
,	sCall		varchar( 16 )	not null	-- call-text
,	tVoice		time( 0 )		not null
,	tStaff		time( 0 )		not null
--,	bActive		tinyint			not null,
--,	tVoMax		time( 0 )		not null,
--,	tStMax		time( 0 )		not null,
	
,	constraint	xp_SessCall		primary key clustered ( idSess, idCall )
)
go
grant	select, insert, update, delete	on dbo.tb_SessCall		to [rWriter]		--	7.03
grant	select, insert, update, delete	on dbo.tb_SessCall		to [rReader]
go
--	----------------------------------------------------------------------------
--	Audit log module filters (active during a user session)
--	7.06.6526	* tb_SessLog -> tb_SessMod
--	7.06.6303
create table	dbo.tb_SessMod
(
	idSess		int				not null
		constraint	fk_SessMod_Sess		foreign key references	tb_Sess
,	idModule	tinyint			not null
		constraint	fk_SessMod_Module	foreign key references	tb_Module
	
,	constraint	xp_SessMod	primary key clustered ( idSess, idModule )
)
go
grant	select, insert, update, delete	on dbo.tb_SessMod		to [rWriter]
grant	select, insert, update, delete	on dbo.tb_SessMod		to [rReader]
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
		constraint	fk_SessStn_Sess		foreign key references	tb_Sess
,	idStn		smallint		not null
		constraint	fk_SessStn_Device	foreign key references	tbCfgStn
	
,	constraint	xp_SessStn	primary key clustered ( idSess, idStn )
)
go
grant	select, insert, update, delete	on dbo.tb_SessStn		to [rWriter]		--	7.03
grant	select, insert, update, delete	on dbo.tb_SessStn		to [rReader]
go
--	----------------------------------------------------------------------------
--	Report staff filters (active during a user session)
--	7.05.5010	* tb_SessStaff -> tb_SessUser,	.idStaff -> .idUser,	xp_SessStaff -> xp_SessUser
--	7.04.4919	.idStaff: FK -> tb_User
--	6.02
create table	dbo.tb_SessUser
(
	idSess		int				not null
		constraint	fk_SessUser_Sess	foreign key references	tb_Sess
,	idUser		int				not null
		constraint	fk_SessUser_User	foreign key references	tb_User
	
,	constraint	xp_SessUser		primary key clustered ( idSess, idUser )
)
go
grant	select, insert, update, delete	on dbo.tb_SessUser		to [rWriter]		--	7.03
grant	select, insert, update, delete	on dbo.tb_SessUser		to [rReader]
go
--	----------------------------------------------------------------------------
--	Report shift filters (active during a user session)
--	6.02
create table	dbo.tb_SessShift
(
	idSess		int				not null
		constraint	fk_SessShift_Sess	foreign key references tb_Sess
,	idShift		smallint		not null
		constraint	fk_SessShift_Shift	foreign key references tbShift
	
,	constraint	xp_SessShift	primary key clustered ( idSess, idShift )
)
go
grant	select, insert, update, delete	on dbo.tb_SessShift		to [rWriter]		--	7.03
grant	select, insert, update, delete	on dbo.tb_SessShift		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's module filter
--	7.06.6526	* tb_SessLog -> tb_SessMod
--	7.06.6310
create proc		dbo.pr_SessMod_Ins
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
grant	execute				on dbo.pr_SessMod_Ins				to [rWriter]
grant	execute				on dbo.pr_SessMod_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans-up session's module tables
--	7.06.6526	* tb_SessLog -> tb_SessMod
--	7.06.6310
create proc		dbo.pr_SessMod_Clr
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
grant	execute				on dbo.pr_SessMod_Clr				to [rWriter]
grant	execute				on dbo.pr_SessMod_Clr				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's call filter
--	7.06.8796	* .tVoTrg -> tVoice, @
--				* .tStTrg -> tStaff, @
--	7.04.4897	* tbDefCallP.idIdx -> .siIdx
--	7.03
create proc		dbo.pr_SessCall_Ins
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
grant	execute				on dbo.pr_SessCall_Ins				to [rWriter]
grant	execute				on dbo.pr_SessCall_Ins				to [rReader]
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
create proc		dbo.pr_SessUser_Ins
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
grant	execute				on dbo.pr_SessUser_Ins				to [rWriter]
grant	execute				on dbo.pr_SessUser_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's shift filter
--	7.05.4980	* -- nocount
--	7.03
create proc		dbo.pr_SessShift_Ins
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
grant	execute				on dbo.pr_SessShift_Ins				to [rWriter]
grant	execute				on dbo.pr_SessShift_Ins				to [rReader]
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
create proc		dbo.pr_Sess_Clr
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
grant	execute				on dbo.pr_Sess_Clr					to [rWriter]
grant	execute				on dbo.pr_Sess_Clr					to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans-up a given one or all sessions for a module
--	7.06.8972	* optimize logic
--				- @bLogout
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
create proc		dbo.pr_Sess_Del
(
	@idSess		int					-- 0 = application-end (delete all sessions)
,	@idModule	tinyint	=	null	-- indicates app, required if @idSess=0
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 512 )
		,		@idType		tinyint
		,		@iTout		int
		,		@sIpAddr	varchar( 40 )
		,		@sHost		varchar( 32 )
		,		@dtTout		datetime
		,		@dtLast		datetime

	set	nocount	on

	select	@iTout =	iValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 1

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1	--	!DB module!

	select	@dtTout =	dateadd( ss, 10 - 60 * @iTout, getdate( ) )			-- moment of T-out for 'now'

	select	@s =	'Sess( ' + isnull(cast(@idModule as varchar),'?') +
					', ' + isnull(cast(@idSess as varchar),'?') + ' )-'

	if	@idSess is null		select	@idSess =	0

	begin	tran

		declare	cur		cursor fast_forward for
			select	idSess, dtLastAct
				from	dbo.tb_Sess
				where	0 < idSess	and	idSess = @idSess
					or	0 = idSess	and	idModule = @idModule

		open	cur
		fetch next from	cur	into	@idSess, @dtLast
		while	@@fetch_status = 0
		begin
			select	@idType =	230										-- log-out (forced)
			if	@idModule <> 61		and	@dtLast < @dtTout				-- J7980ns and 
				select	@idType =	229									-- log-out

			if	@idModule <> 93											-- J7983ss
				exec	dbo.pr_User_Logout	@idSess, @idType

			exec	dbo.pr_Sess_Clr		@idSess

			delete	from	dbo.tb_Sess		where	idSess = @idSess
			
			fetch next from	cur	into	@idSess, @dtLast
		end
		close	cur
		deallocate	cur

		if	@idModule is null		select	@idModule=	1

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	0, null, null, @s, @idModule

	commit
end
go
grant	execute				on dbo.pr_Sess_Del					to [rWriter]		--	7.03
grant	execute				on dbo.pr_Sess_Del					to [rReader]
go
--	----------------------------------------------------------------------------
--	Deletes sessions that are older than 24 hours
--	7.06.8972	* pr_Sess_Del
--	7.06.8796	* tb_Sess.sMachine -> .sHost, @
--	7.06.8411
create proc		dbo.pr_Sess_Maint
	with encryption
as
begin
	declare		@idSess		int

	set	nocount	on

	declare	kur		cursor fast_forward for
		select	idSess
			from	dbo.tb_Sess
			where	sHost is not null 
			and		dateadd(hh, 24, dtLastAct) < getdate( )

--	begin	tran

	open	kur
	fetch next from	kur	into	@idSess
	while	@@fetch_status = 0
	begin
		exec	dbo.pr_Sess_Del		@idSess
	
		fetch next from	kur	into	@idSess
	end
	close	kur
	deallocate	kur

--	commit
end
go
grant	execute				on dbo.pr_Sess_Maint				to [rWriter]
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
create proc		dbo.prEvent_Maint
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
grant	execute				on dbo.prEvent_Maint				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Registers Wi-Fi devices
--	7.06.8993	* optimized
--	7.06.8802	* .idLogType -> idType, @
--	7.06.8783	* .sStaffID -> sStfID, @
--	7.06.8432	+ @idModule for prStaff_SetDuty
--	7.06.6815	+ .sBrowser
--	7.06.6710	+ exec dbo.prStaff_SetDuty
--	7.06.6646	+ @sDvc
--	7.06.6624	* reorder: 1) dvc 2) user
--	7.06.6543	+ @sStaffID
--	7.06.6459
create proc		dbo.prDvc_RegWiFi
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

	select	@s =	'@ ' + isnull( @sIpAddr, '?' ) + ' "' + isnull( @sUser, '?' ) + '"'

	select	@bActive =	bActive
		from	dbo.tbDvc		with (nolock)
		where	idDvc = @idDvc
		and		idDvcType = 0x08		--	wi-fi

	if	@bActive is null		--	wrong dvc
	begin
		select	@idType =	226		--,	@s =	@s + ' "' + isnull( @sUser, '?' ) + '"'
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
		where	sUser = lower(@sUser)	or	sStfID = @sUser

	if	@idUser is null			--	wrong user
	begin
		select	@idType =	222		--,	@s =	@s + ' "' + isnull( @sUser, '?' ) + '"'
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
grant	execute				on dbo.prDvc_RegWiFi				to [rWriter]
grant	execute				on dbo.prDvc_RegWiFi				to [rReader]
go
--	----------------------------------------------------------------------------
--	UnRegisters Wi-Fi devices
--	7.06.8972	* pr_Sess_Del
--	7.06.6737	* optimize
--	7.06.6668	+ if @idDvc > 0 branch
--	7.06.6564	+ @idSess, @idModule
--	7.06.6459
create proc		dbo.prDvc_UnRegWiFi
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

		exec	dbo.pr_Sess_Del		@idSess, @idModule

	commit
end
go
grant	execute				on dbo.prDvc_UnRegWiFi				to [rWriter]
grant	execute				on dbo.prDvc_UnRegWiFi				to [rReader]
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering condition into tb_Log.idLog range
--	7.06.8711	* @dFrom, @dUpto:	datetime -> date
--	7.06.8705	* modified lowest @iFrom (0 -> 0x80000000 = -2147483648)
--	7.06.6534	* modified for null date-args
--	7.06.6512
create proc		dbo.pr_Log_XltDtEvRng
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
grant	execute				on dbo.pr_Log_XltDtEvRng			to [rWriter]
grant	execute				on dbo.pr_Log_XltDtEvRng			to [rReader]
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
create proc		dbo.pr_Log_Get
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
grant	execute				on dbo.pr_Log_Get					to [rWriter]		--	7.01
grant	execute				on dbo.pr_Log_Get					to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating membership sprocs..'
go
--	----------------------------------------------------------------------------
--	Exports all role-unit combinations
--	7.06.6816
create proc		dbo.pr_UserUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idUnit, dtCreated
		from	dbo.tb_UserUnit		with (nolock)
		order	by	1
end
go
grant	execute				on dbo.pr_UserUnit_Exp				to [rWriter]
grant	execute				on dbo.pr_UserUnit_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a role-unit combination
--	7.06.6816
create proc		dbo.pr_UserUnit_Imp
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
grant	execute				on dbo.pr_UserUnit_Imp				to [rWriter]
--grant	execute				on dbo.pr_UserUnit_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-user combinations
--	7.06.6816
create proc		dbo.prTeamUser_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idUser, dtCreated
		from	dbo.tbTeamUser	with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamUser_Exp				to [rWriter]
grant	execute				on dbo.prTeamUser_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-user combination
--	7.06.6816
create proc		dbo.prTeamUser_Imp
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
grant	execute				on dbo.prTeamUser_Imp				to [rWriter]
--grant	execute				on dbo.prTeamUser_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-call combinations
--	7.06.6816
create proc		dbo.prTeamCall_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, siIdx, dtCreated
		from	dbo.tbTeamCall	with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamCall_Exp				to [rWriter]
grant	execute				on dbo.prTeamCall_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-call combination
--	7.06.6816
create proc		dbo.prTeamCall_Imp
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
grant	execute				on dbo.prTeamCall_Imp				to [rWriter]
--grant	execute				on dbo.prTeamCall_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-unit combinations
--	7.06.6816
create proc		dbo.prTeamUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idUnit, dtCreated
		from	dbo.tbTeamUnit	with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamUnit_Exp				to [rWriter]
grant	execute				on dbo.prTeamUnit_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-unit combination
--	7.06.6816
create proc		dbo.prTeamUnit_Imp
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
grant	execute				on dbo.prTeamUnit_Imp				to [rWriter]
--grant	execute				on dbo.prTeamUnit_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all team-dvc combinations
--	7.06.6816
create proc		dbo.prTeamDvc_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, idDvc, dtCreated
		from	dbo.tbTeamDvc	with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prTeamDvc_Exp				to [rWriter]
grant	execute				on dbo.prTeamDvc_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a team-dvc combination
--	7.06.6816
create proc		dbo.prTeamDvc_Imp
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
grant	execute				on dbo.prTeamDvc_Imp				to [rWriter]
--grant	execute				on dbo.prTeamDvc_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all dvc-unit combinations
--	7.06.6816
create proc		dbo.prDvcUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idUnit, dtCreated
		from	dbo.tbDvcUnit	with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prDvcUnit_Exp				to [rWriter]
grant	execute				on dbo.prDvcUnit_Exp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a dvc-unit combination
--	7.06.6816
create proc		dbo.prDvcUnit_Imp
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
grant	execute				on dbo.prDvcUnit_Imp				to [rWriter]
--grant	execute				on dbo.prDvcUnit_Imp				to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating schedule sprocs..'
go
--	----------------------------------------------------------------------------
--	Report schedules
--	7.06.5886	+ .tiFmt
--	7.04.4919	.idUser: smallint -> int
--	7.03	* .iResult: smallint -> int
--			+ tdSchedule_Result
--	7.02
create table	dbo.tbSchedule
(
	idSchedule	smallint		not null	identity( 1, 1 )	--	maybe int?
		constraint	xpSchedule	primary key clustered

,	tiRecur		tinyint			not null	-- hi 3 bits: 32=Daily, 64=Weekly, 128=Monthly;  lo 5 bits: either 1..31 (D,W), or 1=1st, 2=2nd, 4=3rd, 8=4th, 16=Last
,	tiWkDay		tinyint			null		-- 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
,	siMonth		smallint		null		-- 1=Jan, 2=Feb, 4=Mar, 8=Apr, 16=May, 32=Jun, 64=Jul, 128=Aug, 256=Sep, 512=Oct, 1024=Nov, 2048=Dec
,	sSchedule	varchar( 255 )	not null	-- auto: spelled out schedule details
,	dtLastRun	smalldatetime	null		-- when last execution started
,	dtNextRun	smalldatetime	not null	-- when next execution should start, HH:mm part stores the "Run @" value
,	iResult		int				not null			-- for last run: 0=Success, !0==Error code
		constraint	tdSchedule_Result	default( 0 )

,	idUser		int				null		-- owner
		constraint	fkSchedule_User		foreign key references tb_User
,	idReport	smallint		not null
		constraint	fkSchedule_Report	foreign key references tbReport
,	idFilter	smallint		not null
		constraint	fkSchedule_Filter	foreign key references tbFilter
,	tiFmt		tinyint			not null	-- 1=PDF, 2=CSV, 3=XLS
		constraint	tdSchedule_Format	default( 1 )
,	sSendTo		varchar( 255 )	null		-- list of recipient emails

,	bActive		bit				not null
		constraint	tdSchedule_Active	default( 1 )
,	dtCreated	smalldatetime	not null
		constraint	tdSchedule_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null
		constraint	tdSchedule_Updated	default( getdate( ) )
)
--create unique nonclustered index	xuSchedule	on dbo.tbSchedule ( idUser, sSchedule )
		---	schedules should be unique per user
go
grant	select, update					on dbo.tbSchedule		to [rWriter]
grant	select, insert, update, delete	on dbo.tbSchedule		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns an existing schedule
--	7.06.5886	+ .tiFmt
--	7.06.5659	+ .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_GetToRun
--	7.03
create proc		dbo.prSchedule_Get
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
grant	execute				on dbo.prSchedule_Get				to [rWriter]
grant	execute				on dbo.prSchedule_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all existing schedules
--	7.06.8845	* sFilter to indicate public vs. private one
--	7.06.5886	+ .tiFmt
--	7.06.5694
create proc		dbo.prSchedule_GetAll
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
grant	execute				on dbo.prSchedule_GetAll			to [rWriter]
grant	execute				on dbo.prSchedule_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns a list of active schedules, due for execution right now
--	7.06.8846	* sUser -> sStaff
--	7.06.5886	+ .tiFmt
--	7.06.5659	+ .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_Get
--	7.05.4980	* u.sFirst + ' ' + u.sLast -> u.sStaff
--	7.03
create proc		dbo.prSchedule_GetToRun
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
grant	execute				on dbo.prSchedule_GetToRun			to [rWriter]
grant	execute				on dbo.prSchedule_GetToRun			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing schedule
--	7.06.8830	* @idSchedule marked as 'out'
--	7.06.5886	+ .tiFmt
--	7.05.5044	* @idUser: smallint -> int
--	7.05.4980	* -- nocount
--	7.03
create proc		dbo.prSchedule_InsUpd
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
			select	@idSchedule =	scope_identity( )
		end

	commit
end
go
grant	execute				on dbo.prSchedule_InsUpd			to [rWriter]
grant	execute				on dbo.prSchedule_InsUpd			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates state for an existing schedule
--	7.05.4980	* -- nocount
--	7.03
create proc		dbo.prSchedule_Upd
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
grant	execute				on dbo.prSchedule_Upd				to [rWriter]
grant	execute				on dbo.prSchedule_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Deletes an existing schedule
--	7.05.4980	* -- nocount
--	7.03
create proc		dbo.prSchedule_Del
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
grant	execute				on dbo.prSchedule_Del				to [rWriter]
grant	execute				on dbo.prSchedule_Del				to [rReader]
go
--	----------------------------------------------------------------------------
--	Deletes an existing filter
--	7.06.8802	* optimized
--	7.03
create proc		dbo.prFilter_Del
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
grant	execute				on dbo.prFilter_Del					to [rWriter]
grant	execute				on dbo.prFilter_Del					to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating Hl7 tables..'
go
--	----------------------------------------------------------------------------
--	Call-priorities, to be exported to HL7 
--	7.06.8889	* .sSend -> sTxt
--				* .bSend -> bUse	(tdHlCall_Send -> tdHlCall_Use)
--	7.06.8586
create table	dbo.tbHlCall
(
	siIdx		smallint		not null	-- priority-index
		constraint	xpHlCall	primary key clustered

,	sTxt		varchar( 255 )	null
,	bUse		bit				null
		constraint	tdHlCall_Use		default( 0 )

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
			if	not	exists	(select 1 from dbo.tbHlCall with (nolock) where siIdx = @siIdx)
				insert	dbo.tbHlCall	(  siIdx )
						values			( @siIdx )

			select	@siIdx =	@siIdx + 1
		end
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.8889	* .sSend -> sTxt, .bSend -> bUse
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
		,	bUse, sTxt, c.dtUpdated
		from	dbo.tbHlCall	c	with (nolock)
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
		where	@siFlags is null	or	siFlags & @siFlags	= @siFlags
--		where	@bEnabled = 0	or	siFlags & 0x02 > 0
		order	by	2 desc		--	p.siIdx
end
go
grant	execute				on dbo.prHlCall_GetAll				to [rWriter]
grant	execute				on dbo.prHlCall_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates an HL7 exported call-priority
--	7.06.8889	* .sSend -> sTxt, .bSend -> bUse
--	7.06.8586
create proc		dbo.prHlCall_Upd
(
	@siIdx		smallint			-- call-index
,	@bUse		bit
,	@sTxt		varchar( 255 )
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 300 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'HlC_U( ' + isnull(cast(@siIdx as varchar),'?') +
					'|' + isnull(cast(@bUse as varchar),'?') + ', ''' + isnull(@sTxt,'?') + ''' )'

	begin	tran

--		if	exists	(select 1 from tbHlCall with (nolock) where siIdx = @siIdx)
			update	dbo.tbHlCall
				set		bUse =		@bUse,		sTxt =		@sTxt,		dtUpdated=	getdate( )
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
--	7.06.8889	* .sSend -> sLoc
--				* .bSend -> bUse	(tdHlRoomBed_Send -> tdHlRoomBed_Use)
--	7.06.8586
create table	dbo.tbHlRoomBed
(
	idRoom		smallint		not null	-- device look-up FK
		constraint	fkHlRoomBed_Room	foreign key references	tbRoom
,	tiBed		tinyint			not null	-- bed index, 0xFF == no bed in room

,	sLoc		varchar( 255 )	null		-- HL7 location reference
,	bUse		bit				null
		constraint	tdHlRoomBed_Send	default( 0 )

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
--	7.06.8889	* .sSend -> sLoc, .bSend -> bUse
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.8586
create proc		dbo.prHlRoomBed_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	on
	select	r.bActive, sSGJ, sRoom, b.cBed
		,	h.bUse, h.sLoc
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
grant	execute				on dbo.prHlRoomBed_GetAll			to [rWriter]
grant	execute				on dbo.prHlRoomBed_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates an HL7 exported room-bed
--	7.06.8889	* .sSend -> sLoc, .bSend -> bUse
--	7.06.8586
create proc		dbo.prHlRoomBed_Upd
(
	@idRoom		smallint
,	@tiBed		tinyint
,	@bUse		bit
,	@sLoc		varchar( 255 )
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 300 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'HlR_U( ' + isnull(cast(@idRoom as varchar),'?') + ':' + isnull(cast(@tiBed as varchar),'?') +
					'|' + isnull(cast(@bUse as varchar),'?') + ', ''' + isnull(@sLoc,'?') + ''' )'

	begin	tran

		if	exists	(select 1 from tbHlRoomBed where idRoom = @idRoom and tiBed = @tiBed)
			update	tbHlRoomBed	set		bUse =		@bUse,		sLoc =		@sLoc
				,	dtUpdated =	getdate( )
				where	idRoom = @idRoom	and	tiBed = @tiBed
		else
			insert	tbHlRoomBed	(  idRoom,  tiBed,  bUse,  sLoc )
					values		( @idRoom, @tiBed, @bUse, @sLoc )

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
--	Returns all items necessary for HL7 export of an event
--	7.06.8889	* tbHlCall.sSend -> sTxt, .bSend -> bUse
--				* tbHlRoomBed.sSend -> sLoc, .bSend -> bUse
--	7.06.8796	* sPatId -> sPatID	(xuPatient_PatId -> xuPatient_PatID)
--				* cGender -> cGndr
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
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
		,	r.sRoom,	b.cBed
--		,	r.sDevice + case when ec.tiBed is null then '' else ':' + b.cBed end	as	sRmBd	--	cast(e.tiBed as char(1))
		,	hc.sTxt,	hr.sLoc		--,	ec.idRoom, ec.tiBed
		,	p.idPatient, p.sPatient, p.cGndr,	p.sIdent, p.sPatID, p.sLast, p.sFrst, p.sMidd
		from	dbo.tbEvent		e	with (nolock)
		join	dbo.tbEvent_C	ec	with (nolock)	on	ec.idEvent	= e.idOrigin
	left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= e.tiBed
		join	dbo.tbCall		c	with (nolock)	on	c.idCall	= e.idCall
		join	dbo.tbHlCall	hc	with (nolock)	on	hc.siIdx	= c.siIdx		and	hc.bUse > 0
		join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= e.idRoom
		join	dbo.tbHlRoomBed	hr	with (nolock)	on	hr.idRoom	= e.idRoom		and	hr.bUse > 0
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
--	Updates room's beds and configures corresponding tbRoomBed rows
--	7.06.8959	* optimized logging
--	7.06.8795	* prCfgDvc_UpdRmBd	->	prCfgStn_UpdRmBd
--	7.06.8791	* tbCfgLoc.idParent -> .idPrnt
--	7.06.8591	+ tbHlRoomBed
--	7.06.8446	* prDevice_UpdRoomBeds -> prCfgDvc_UpdRmBd
--	7.06.7279	* optimized logging
--	7.06.7265	* optimized
--	7.06.7249	* inlined 'exec prRoom_UpdStaff' (its changed logic is now causing loss of tbRoom.idUnit during config download)
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
			from	dbo.tbCfgStn	with (nolock)
			where	idStn = @idRoom

		if	@tiCA0 = 0xFF	or	@tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
		or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
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

		if	@tiCA0 = 0xFF	or	@tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
		or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
			select	top 1 @idUnitA =	idUnit			-- pick max unit
				from	dbo.tbUnit		with (nolock)
				order	by	idUnit	desc
		else
			select	@idUnitA =	idPrnt					-- convert AltCA0 to its unit
				from	dbo.tbCfgLoc	with (nolock)
				where	idLoc = @tiCA0

		if	@idUnitP is null	and	@idUnitA is not null		-- if pri is not set
			select	@idUnitP =	@idUnitA,	@idUnitA =	null	-- swap pri and alt


		select	@s =	'Beds( ' + isnull(cast(@idRoom as varchar), '?') +		--	'|"' + isnull(@sRoom, '?') +	isnull('" #' + @sDial, '?')
						', ' + isnull(cast(convert(varchar, convert(varbinary(2), @siBeds), 1) as varchar),'?') + ' )' +
						' pu=' + isnull(cast(@idUnitP as varchar), '?') + isnull(' au=' + cast(@idUnitA as varchar), '')

		begin	tran

		---	delete	from	tbRoomBed					-- NO: removes patient-to-bed assignments!!
		---		where	idRoom = @idRoom

			if	exists	(select 1 from tbRoom with (nolock) where idRoom = @idRoom)
				update	dbo.tbRoom	set	idUnit =	@idUnitP									--	7.06.7249
					where	idRoom = @idRoom
			else
				insert	dbo.tbRoom	( idRoom,  idUnit)	-- init staff placeholder for this room	v.7.02, v.7.03
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

				select	@s =	@s + ' bd=' + @sBeds
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
--	Stryker iBed Locations
--	7.06.8892
create table	dbo.tbIbedLoc
(
	idLoc		smallint		not null	identity( 1, 1 )	-- 1-32767 (unsigned)
		constraint	xpIbedLoc	primary key clustered

,	sLoc		varchar( 255 )	null		-- name
,	idRoom		smallint		null		-- 790 device look-up FK
		constraint	fkIbedLoc_Room		foreign key references tbRoom
--,	dtExpires	smalldatetime	null		-- expiration window for deactivation of old (tb_OptSys[?])

,	bActive		bit				not null
		constraint	tdIbedLoc_Active	default( 1 )
,	dtCreated	smalldatetime	not null	
		constraint	tdIbedLoc_Created	default( getdate( ) )
,	dtUpdated	smalldatetime	not null	
		constraint	tdIbedLoc_Updated	default( getdate( ) )
)
create unique nonclustered index	xuIbedLoc_Loc			on	dbo.tbIbedLoc ( sLoc )
		--	all location references must be unique (including inactive)!!
go
grant	select, insert, update			on dbo.tbIbedLoc		to [rWriter]
grant	select, update					on dbo.tbIbedLoc		to [rReader]
go
--	----------------------------------------------------------------------------
--	Stryker iBed Locations
--	7.06.8892
create view		dbo.vwIbedLoc
	with encryption
as
select	r.idLoc, r.sLoc		--, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	r.idRoom, d.cStn, d.sStn, d.sSGJ	--, d.sSGJR
	,	d.sSGJ + ' [' + d.cStn + '] ' + d.sStn	as sQnStn
	,	r.bActive, r.dtCreated, r.dtUpdated
	from	dbo.tbIbedLoc	r	with (nolock)
left join	dbo.vwCfgStn	d	with (nolock)	on	d.idStn		= r.idRoom
go
grant	select, insert, update, delete	on dbo.vwIbedLoc		to [rWriter]
grant	select							on dbo.vwIbedLoc		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns Stryker iBed Locations (filtered)
--	7.06.8892
create proc		dbo.prIbedLoc_GetAll
(
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@bRoom		bit			= null	-- null=any, 0=not-in-room, 1=assigned
)
	with encryption
as
begin
--	set	nocount	on
	select	bActive, dtCreated, dtUpdated
		,	idLoc, sLoc,	idRoom, sQnStn
		from	dbo.vwIbedLoc	with (nolock)
		where	( @bActive is null	or	bActive = @bActive )
		and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
		order	by	idLoc
end
go
grant	execute				on dbo.prIbedLoc_GetAll				to [rWriter]
grant	execute				on dbo.prIbedLoc_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given Stryker iBed Location
--	7.06.8892
create proc		dbo.prIbedLoc_InsUpd
(
	@idLoc			smallint		out	-- loc id
,	@sLoc			varchar( 255 )		-- name
)
	with encryption
as
begin
---	set	nocount	on
	begin	tran
		if	@idLoc is null
		and	exists	( select 1 from dbo.tbIbedLoc with (nolock) where sLoc = @sLoc )
			update	dbo.tbIbedLoc
				set		bActive =	1,	dtUpdated=	getdate( ),	@idLoc =	idLoc
				where	sLoc = @sLoc
		else
		if	exists	( select 1 from dbo.tbIbedLoc with (nolock) where idLoc = @idLoc )
			update	dbo.tbIbedLoc
				set		bActive =	1,	dtUpdated=	getdate( ),	sLoc =	@sLoc
				where	idLoc = @idLoc
		else
		begin
			insert	dbo.tbIbedLoc	(  sLoc )
					values			( @sLoc )
			select	@idLoc =	scope_identity( )
		end
	commit
end
go
grant	execute				on dbo.prIbedLoc_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates 790 device assigned to a given Stryker iBed Location
--	7.06.8892
create proc		dbo.prIbedLoc_UpdRoom
(
	@idLoc			smallint			-- loc id
,	@idRoom			smallint			-- room id
)
	with encryption
as
begin
--	set	nocount	on

--	begin	tran
		update	dbo.tbIbedLoc
			set		idRoom =	@idRoom,	dtUpdated=	getdate( )
			where	idLoc = @idLoc
--	commit
end
go
grant	execute				on dbo.prIbedLoc_UpdRoom			to [rWriter]
grant	execute				on dbo.prIbedLoc_UpdRoom			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates 790 device assigned to a given Stryker iBed Location
--	7.06.8892
create proc		dbo.prIbedLoc_GetRoom
(
	@sLoc			varchar( 255 )		-- name
,	@idRoom			smallint		out	-- room id
)
	with encryption
as
begin
	declare		@idLoc		smallint

--	set	nocount	on

	exec	dbo.prIbedLoc_InsUpd	@idLoc out, @sLoc

--	set	nocount	off

	select	idRoom
		from	dbo.tbIbedLoc	with (nolock)
		where	idLoc = @idLoc
end
go
grant	execute				on dbo.prIbedLoc_GetRoom			to [rWriter]
grant	execute				on dbo.prIbedLoc_GetRoom			to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating TTS tables..'
go
--	----------------------------------------------------------------------------
create table	dbo.tbTlkCfg
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
)
go
grant	select, insert, update, delete	on dbo.tbTlkCfg			to [rWriter]
grant	select							on dbo.tbTlkCfg			to [rReader]
go
insert	dbo.tbTlkCfg	( idCfg, dtUpdated, bSpeechEnabled, iRlyDev, iAnnCount )
		values			( 0, getdate(), 0, 0, 0 )
go
--	----------------------------------------------------------------------------
--	7.06.5610	+ .iRepeatCancel
create table	dbo.tbTlkMsg
(
	idMsg		smallint		not null
		constraint	xpTlkMsg	primary key clustered		--	7.06.5548

,	sDesc		text			null
,	sSay		text			null
,	bWillSpeak	bit				not null
,	iRepeat		tinyint			null
,	iRepeatCancel	tinyint		null	-- Repeat announcement on cancel count
)
go
grant	select, insert, update, delete	on dbo.tbTlkMsg			to [rWriter]
grant	select							on dbo.tbTlkMsg			to [rReader]
go
insert	dbo.tbTlkMsg	( idMsg, sDesc, sSay, bWillSpeak, iRepeat )
		values			( 1, 'No Announcement', null, 0, null )
go
--	----------------------------------------------------------------------------
create table	dbo.tbTlkArea
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
)
go
grant	select, insert, update, delete	on dbo.tbTlkArea			to [rWriter]
grant	select							on dbo.tbTlkArea			to [rReader]
go
insert	dbo.tbTlkArea	( idArea, sDesc, sSay, bWillSpeak
						,	bRly01,bRly02,bRly03,bRly04,bRly05,bRly06,bRly07,bRly08,bRly09,bRly10,bRly11,bRly12,bRly13,bRly14,bRly15,bRly16
						,	bRly17,bRly18,bRly19,bRly20,bRly21,bRly22,bRly23,bRly24,bRly25,bRly26,bRly27,bRly28,bRly29,bRly30,bRly31,bRly32 )
		values			( 1, 'Default Area', null, 1
						,	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
						,	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 )
go
--	----------------------------------------------------------------------------
--	7.06.5610	* .idRoom:	smallint -> int
--					(6892 support - more than 100 room/console controllers per gateway)
create table	tbTlkRooms
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
)
go
grant	select, insert, update, delete	on dbo.tbTlkRooms			to [rWriter]
grant	select							on dbo.tbTlkRooms			to [rReader]
go
--	----------------------------------------------------------------------------
create table	tbTlkCalls
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
)
go
grant	select, insert, update, delete	on dbo.tbTlkCalls			to [rWriter]
grant	select							on dbo.tbTlkCalls			to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating report sprocs..'
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering condition into tbEvent.idEvent range
--	7.06.6052	+ @tiShift
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	6.05	+ (nolock)
create proc		dbo.prRpt_XltDtEvRng
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
grant	execute				on dbo.prRpt_XltDtEvRng				to [rWriter]		--	7.03
grant	execute				on dbo.prRpt_XltDtEvRng				to [rReader]
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
create proc		dbo.prRptSysActDtl
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
grant	execute				on dbo.prRptSysActDtl				to [rWriter]		--	7.03
grant	execute				on dbo.prRptSysActDtl				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8963	* .tVoTrg, .tStTrg
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
create proc		dbo.prRptCallStatSum
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
		,	case when p.siFlags & 0x1000 > 0	then null			else tVoTrg		end		as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
		,	case when p.siFlags & 0x1000 > 0	then null			else tStTrg		end		as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
		,	cast(round(case when lVoNul = lCount	then null	else lVoOnT*@fPerc/(lCount-lVoNul)	end, 0)	as int)	as	iVoOnT
		,	cast(round(case when lStNul = lCount	then null	else lStOnT*@fPerc/(lCount-lStNul)	end, 0)	as int)	as	iStOnT
		from
			(select	e.idCall,	count(*) as	lCount
				,	min(c.siIdx)	as	siIdx,		min(c.sCall)	as	sCall
				,	min(c.tVoice)	as	tVoTrg,		min(c.tStaff)	as	tStTrg
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
grant	execute				on dbo.prRptCallStatSum				to [rWriter]		--	7.03
grant	execute				on dbo.prRptCallStatSum				to [rReader]
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
grant	execute				on dbo.prRptCallStatGfx				to [rWriter]		--	7.03
grant	execute				on dbo.prRptCallStatGfx				to [rReader]
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
create proc		dbo.prRptCallStatDtl
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
grant	execute				on dbo.prRptCallStatDtl				to [rWriter]		--	7.03
grant	execute				on dbo.prRptCallStatDtl				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8963	* fix dup output .tVoice, .tStaff
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
create proc		dbo.prRptCallActSum
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
		,	e.idCall, e.sCall, p.siIdx, p.tiSpec, p.tiColor,	c.tVoice	as	tVoTrg, c.tStaff	as	tStTrg
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
grant	execute				on dbo.prRptCallActSum				to [rWriter]		--	7.03
grant	execute				on dbo.prRptCallActSum				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.9001	* fix Group/Team pagers:	when nd.tiFlags & 0x01 = 0
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
create proc		dbo.prRptCallActDtl
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
						case	when nd.tiFlags & 0x01 = 0	then @sGrTm	else du.sQnStf	end
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
		order	by	ec.idUnit, ec.idRoom, ec.idEvent	--, t.idEvent
end
go
grant	execute				on dbo.prRptCallActDtl				to [rWriter]		--	7.03
grant	execute				on dbo.prRptCallActDtl				to [rReader]
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
create proc		dbo.prRptCallActExc
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
grant	execute				on dbo.prRptCallActExc				to [rWriter]
grant	execute				on dbo.prRptCallActExc				to [rReader]
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
create proc		dbo.prRptStfAssn
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
grant	execute				on dbo.prRptStfAssn					to [rWriter]		--	7.03
grant	execute				on dbo.prRptStfAssn					to [rReader]
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
create proc		dbo.prRptStfCvrg
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
grant	execute				on dbo.prRptStfCvrg					to [rWriter]		--	7.03
grant	execute				on dbo.prRptStfCvrg					to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8385	* 
--	7.06.8368	* .tiFlags -> .siFlags
--	7.06.7614	* Vo|St -> Good|Fair|Poor
--	7.06.7311
create proc		dbo.prRptRndStatSum
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
grant	execute				on dbo.prRptRndStatSum				to [rWriter]
grant	execute				on dbo.prRptRndStatSum				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.8783	* #PK nonclustered -> clustered
--	7.06.8385	* 
--	7.06.8368	* .tiFlags -> .siFlags
--	7.06.7614	* Vo|St -> Good|Fair|Poor
--	7.06.7311
create proc		dbo.prRptRndStatDtl
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
grant	execute				on dbo.prRptRndStatDtl				to [rWriter]
grant	execute				on dbo.prRptRndStatDtl				to [rReader]
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
create proc		dbo.prRptCliPatDtl
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
grant	execute				on dbo.prRptCliPatDtl				to [rWriter]
grant	execute				on dbo.prRptCliPatDtl				to [rReader]
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
create proc		dbo.prRptCliStfDtl
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
grant	execute				on dbo.prRptCliStfDtl				to [rWriter]
grant	execute				on dbo.prRptCliStfDtl				to [rReader]
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
create proc		dbo.prRptCliStfSum
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
grant	execute				on dbo.prRptCliStfSum				to [rWriter]
grant	execute				on dbo.prRptCliStfSum				to [rReader]
go

--	============================================================================
print	char(10) + '###	Creating export sprocs..'
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
create proc		dbo.prExportCallsActive
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
grant	execute				on dbo.prExportCallsActive			to [rExporter]
grant	execute				on dbo.prExportCallsActive			to [rExporter]
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
create proc		dbo.prExportCallsComplete
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
grant	execute				on dbo.prExportCallsComplete		to [rExporter]
grant	execute				on dbo.prExportCallsComplete		to [rExporter]
go


exec	dbo.prHealth_Stats

declare		@s		varchar(255)

select	@s =	sVersion + '.00000, [' + db_name( ) + '], ' + sArgs
	from	dbo.tb_Module
	where	idModule = 1

exec	dbo.pr_Log_Ins	61, 4, null, @s			--	4=system

go

checkpoint
go

checkpoint
go

use [master]
go

--	============================================================================
--print	char(10) + '###	Creating views..'
--go

--	============================================================================
--print	char(10) + '###	Creating stored procedures and triggers..'
--go

--	============================================================================
--print	char(10) + '###	Granting permissions..'
--go

--	============================================================================
print	char(10) + '###	Complete.'
go