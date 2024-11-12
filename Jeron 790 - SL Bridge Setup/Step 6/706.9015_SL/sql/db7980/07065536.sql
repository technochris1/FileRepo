--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
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
--						* fix tbFilter.xFilter
--		2015-Feb-13		.5522
--						+ command execution timeouts
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
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 5536 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.5536', 18, 0 )
go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_Upd')
	drop proc	dbo.prRoom_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_UpdStaff')
	drop proc	dbo.prRoom_UpdStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByDial')
	drop proc	dbo.prDvc_GetByDial
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetByBC')
	drop proc	dbo.prDvc_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetAssn')
	drop proc	dbo.prStaff_GetAssn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_Get')
	drop proc	dbo.prStaff_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByStfID')
	drop proc	dbo.prStaff_GetByStfID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetBySID')
	drop proc	dbo.prStaff_GetBySID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetBySID')
	drop proc	dbo.pr_User_GetBySID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetByBC')
	drop proc	dbo.pr_User_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetByBC')
	drop proc	dbo.prStaff_GetByBC
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeamUser_Get')
	drop proc	dbo.prTeamUser_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfAssn_GetByRoom')
	drop proc	dbo.prStfAssn_GetByRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Get')
	drop proc	dbo.pr_User_Get
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_GetByRole')
	drop proc	dbo.pr_UserRole_GetByRole
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_GetByUser')
	drop proc	dbo.pr_UserRole_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMap_GetByUnit')
	drop proc	dbo.prUnitMap_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMap_GetAll')
	drop proc	dbo.prUnitMap_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetAll')
	drop proc	dbo.prDevice_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_GetAll')
	drop proc	dbo.prCfgDvc_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_A_GetAll')
	drop proc	dbo.prEvent_A_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_InsUpd')
	drop proc	dbo.prShift_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Upd')
	drop proc	dbo.prShift_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_GetByUnit')
	drop proc	dbo.prShift_GetByUnit
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_GetByUser')
	drop proc	dbo.prUnit_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfLvl_GetAll')
	drop proc	dbo.prStfLvl_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_GetAll')
	drop proc	dbo.pr_Sess_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCall')
	drop view	dbo.vwCall
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_Sess')
	drop view	dbo.vw_Sess
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_OptUsr')
	drop view	dbo.vw_OptUsr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_OptSys')
	drop view	dbo.vw_OptSys
go
--	----------------------------------------------------------------------------
--	Audit log
--	7.06.5399	* optimized
--	6.07
alter view		dbo.vw_Log
	with encryption
as
	select	l.idLog, l.dLog, l.tLog, l.idLogType, t.sLogType, l.sLog, l.dtLog, l.idUser, u.sUser
		from	tb_Log	l	with (nolock)
		join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
		left join	tb_User	u	with (nolock)	on u.idUser = l.idUser
go
--	----------------------------------------------------------------------------
--	7.06.5399
create view		dbo.vw_OptSys
	with encryption
as
	select	os.idOption, o.sOption, o.tiDatatype, os.iValue, os.fValue, os.tValue, os.sValue, os.dtUpdated
		from	tb_OptSys	os	with (nolock)
		join	tb_Option	o	with (nolock)	on	o.idOption = os.idOption
go
grant	select							on dbo.vw_OptSys		to [rWriter]
grant	select							on dbo.vw_OptSys		to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5399
create view		dbo.vw_OptUsr
	with encryption
as
	select	ou.idOption, o.sOption, o.tiDatatype, ou.iValue, ou.fValue, ou.tValue, ou.sValue, ou.dtUpdated, ou.idUser, u.sUser
		from	tb_OptUsr	ou	with (nolock)
		join	tb_Option	o	with (nolock)	on	o.idOption = ou.idOption
		join	tb_User		u	with (nolock)	on	u.idUser = ou.idUser
go
grant	select							on dbo.vw_OptUsr		to [rWriter]
grant	select							on dbo.vw_OptUsr		to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5399
create view		dbo.vw_Sess
	with encryption
as
	select	s.idSess, s.dtCreated, s.sSessID, s.idModule, m.sModule, s.idUser, u.sUser, s.sIpAddr, s.sMachine, s.bLocal, s.dtLastAct, s.sBrowser
		from	tb_Sess	s	with (nolock)
		join	tb_Module	m	with (nolock)	on	m.idModule = s.idModule
		left join	tb_User	u	with (nolock)	on	u.idUser = s.idUser
go
grant	select							on dbo.vw_Sess			to [rWriter]
grant	select							on dbo.vw_Sess			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns sessions
--	7.06.5399
create proc		dbo.pr_Sess_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	s.idSess, s.dtCreated, s.sSessID, s.idModule, s.sModule, s.idUser, s.sUser, s.sIpAddr, s.sMachine, s.bLocal, s.dtLastAct, s.sBrowser
		from	vw_Sess	s	with (nolock)
		order	by	1 desc
end
go
grant	execute				on dbo.pr_Sess_GetAll				to [rWriter]
grant	execute				on dbo.pr_Sess_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns security details for all users
--	7.06.5399	* optimized
--	7.05.5182
alter proc		dbo.pr_User_GetByUnit
(
	@idUnit		smallint			-- null=any?
,	@idStfLvl	tinyint		= null	-- null=any, 1=Yel, 2=Ora, 4=Grn
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUser		int			= null	-- null=any
,	@sStaffID	varchar( 16 )= null	-- null=any
)
	with encryption
as
begin
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStaffID, idStfLvl, sBarCode, bOnDuty, dtDue, sStaff, sUnits
		,	sTeams, bActive, dtCreated, dtUpdated
		from	tb_User	u	with (nolock)
		where	(@bActive is null	or	u.bActive = @bActive)
		and		(@idStfLvl is null	or	u.idStfLvl = @idStfLvl)
		and		(@idUser is null	or	u.idUser = @idUser)
		and		(@sStaffID is null	or	u.sStaffID = @sStaffID)
		and		idUser > 15			--	protect internal accounts
end
go
--	----------------------------------------------------------------------------
--	Returns staff-levels
--	7.06.5400
create proc		dbo.prStfLvl_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idStfLvl, sStfLvl, iColorB
		from	tbStfLvl	with (nolock)
end
go
grant	execute				on dbo.prStfLvl_GetAll				to [rWriter]
grant	execute				on dbo.prStfLvl_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns units, accessible by the given user (via his roles)
--	7.06.5401	* merged prUnit_GetByUser -> prUnit_GetAll
--	7.06.5399	* optimized
--	7.06.5385	* optimized
--	7.05.5253	* ?
--	7.05.5043
alter proc		dbo.prUnit_GetAll
(
	@idUser		int			= null	-- null=any
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtCreated, u.dtUpdated
		from	tbUnit	u	with (nolock)
		join	tbShift	s	with (nolock)	on	s.idShift = u.idShift
		where	(@bActive is null	or	u.bActive = @bActive)
		and		(@idUser is null	or	u.idUnit in (select	idUnit
					from	tb_RoleUnit	ru	with (nolock)
					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order	by	u.sUnit
end
go
--	----------------------------------------------------------------------------
--	Returns shifts for a given unit (ordered by index) or current one
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
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, tiNotify, bActive, dtCreated, dtUpdated, idUser, idStfLvl, sStaffID, sStaff, bOnDuty
		from	vwShift		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idUnit is null	or	idUnit = @idUnit)
		and		(@bCurrent = 0		or	idShift in (select idShift from tbUnit with (nolock) where idUnit = @idUnit))
		order	by	idUnit, tiIdx
end
go
--	----------------------------------------------------------------------------
--	7.06.4939	- .tiRouting	(vwShift, prShift_Exp, prShift_Imp, prShift_Upd, prShift_InsUpd)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbShift') and name = 'tiRouting')
begin
	begin tran
		alter table	dbo.tbShift		drop constraint	tdShift_Routing
		alter table	dbo.tbShift		drop column		tiRouting
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.4939	- .tiRouting
--	7.05.5226
alter view		dbo.vwShift
	with encryption
as
select	sh.idUnit, u.sUnit
	,	sh.idShift, tiIdx, sShift, tBeg, tEnd, tiNotify
	,	sh.idUser, s.idStfLvl, s.sStaffID, s.sStaff, s.bOnDuty
	,	sh.bActive, sh.dtCreated, sh.dtUpdated
	from	tbShift	sh	with (nolock)
	join	tbUnit	u	with (nolock)	on	u.idUnit = sh.idUnit
	left join	vwStaff	s	with (nolock)	on	s.idUser = sh.idUser
go
--	----------------------------------------------------------------------------
--	Exports all shifts
--	7.06.4939	- .tiRouting
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4965
alter proc		dbo.prShift_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idShift, idUnit, tiIdx, sShift, tBeg, tEnd, tiNotify, idUser, bActive, dtCreated, dtUpdated
		from	tbShift		with (nolock)
		where	idShift > 0
		order	by	idShift
end
go
--	----------------------------------------------------------------------------
--	Imports a shift
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

	begin	tran

		if	not	exists	(select 1 from tbShift with (nolock) where idShift = @idShift)
		begin
			set identity_insert	dbo.tbShift	on

			insert	tbShift	(  idShift,  idUnit,  tiIdx,  sShift,  tBeg,  tEnd,  tiNotify,  idUser,  bActive,  dtCreated,  dtUpdated )
					values	( @idShift, @idUnit, @tiIdx, @sShift, @tBeg, @tEnd, @tiNotify, @idUser, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tbShift	off
		end
		else
			update	tbShift	set	idUnit= @idUnit, tiIdx= @tiIdx, sShift= @sShift, tBeg= @tBeg, tEnd= @tEnd
						,	tiNotify= @tiNotify, idUser= @idUser, bActive= @bActive, dtUpdated= @dtUpdated
				where	idShift = @idShift

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
--	7.06.4939	- .tiRouting
--	7.05.5172
create proc		dbo.prShift_InsUpd
(
	@idShift	smallint	out			-- null,<0==new shift
,	@idUnit		smallint
,	@tiIdx		tinyint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiNotify	tinyint
,	@idUser		int						-- backup staff
,	@bActive	bit
)
	with encryption
as
begin
	set	nocount	on
	set	xact_abort	on

	if	@idShift < 0												--	find shift by unit and index
		select	@idShift= idShift
			from	tbShift		with (nolock)
			where	idUnit = @idUnit	and	tiIdx = @tiIdx

	begin	tran

		if	@idShift is null	or	@idShift < 0
		begin
			insert	tbShift	(  idUnit,  tiIdx,  sShift,  tBeg,  tEnd )
					values	( @idUnit, @tiIdx, @sShift, @tBeg, @tEnd )
			select	@idShift=	scope_identity( )
		end
		else
		begin
	--	-	update	tbShift		set	sShift= @sShift, tBeg= @tBeg, tEnd= @tEnd		--, idUnit= @idUnit, tiIdx= @tiIdx
	--	-				,	tiNotify= @tiNotify, idUser= @idUser, bActive= @bActive, dtUpdated= getdate( )
	--	-		where	idShift = @idShift
			if	@tBeg is not null
				update	tbShift		set	tBeg= @tBeg, tEnd= @tEnd, bActive= @bActive, dtUpdated= getdate( )
					where	idShift = @idShift
			if	@tiNotify is not null
				update	tbShift		set	tiNotify= @tiNotify, idUser= @idUser, dtUpdated= getdate( )
					where	idShift = @idShift
		end

		exec	dbo.prUnit_UpdShifts	@idUnit

	commit
end
go
grant	execute				on dbo.prShift_InsUpd				to [rWriter]
--grant	execute				on dbo.prShift_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5409	fix tbCfgBed.siBed
--	<4,tbEvent_C>
begin
	begin tran
		update	dbo.tbCfgBed	set	siBed= 0x0001	where	tiBed = 1
		update	dbo.tbCfgBed	set	siBed= 0x0002	where	tiBed = 2
		update	dbo.tbCfgBed	set	siBed= 0x0004	where	tiBed = 3
		update	dbo.tbCfgBed	set	siBed= 0x0008	where	tiBed = 4
		update	dbo.tbCfgBed	set	siBed= 0x0010	where	tiBed = 5
		update	dbo.tbCfgBed	set	siBed= 0x0020	where	tiBed = 6
		update	dbo.tbCfgBed	set	siBed= 0x0040	where	tiBed = 7
		update	dbo.tbCfgBed	set	siBed= 0x0080	where	tiBed = 8
		update	dbo.tbCfgBed	set	siBed= 0x0100	where	tiBed = 9
		update	dbo.tbCfgBed	set	siBed= 0x0200	where	tiBed = 0

		update	ec	set	ec.siBed= cb.siBed
			from	tbEvent_C	ec
			join	tbCfgBed	cb	on	cb.tiBed = ec.tiBed
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns [active?] beds, ordered to be loadable into a tree
--	7.06.5409	+ .siBed
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
	select	tiBed, cBed, cDial, siBed, bActive, dtCreated, dtUpdated
		from	dbo.tbCfgBed	with (nolock)
		where	@bActive = 0	or	bActive > 0
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a bed definition
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
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Bed_IU( ' + isnull(cast(@tiBed as varchar), '?') +
				', c=' + isnull(@cBed, '?') + ', d=' + isnull(@cDial, '?') + ', f=' + isnull(cast(@siBed as varchar), '?') + ' )'

	begin	tran
		if	exists	(select 1 from tbCfgBed where tiBed = @tiBed)
		begin
			update	tbCfgBed	set	cBed= @cBed, cDial= @cDial, dtUpdated= getdate( )
				where	tiBed = @tiBed
			select	@s= @s + ' UPD'
		end
		else
		begin
			insert	tbCfgBed	(  tiBed,  cBed,  cDial,  siBed )
					values		( @tiBed, @cBed, @cDial, @siBed )
			select	@s= @s + ' INS'
		end

		if	@iTrace & 0x08 > 0
			exec	dbo.pr_Log_Ins	71, null, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	Call-text definitions (active)
--	7.06.5483
create view		dbo.vwCall
	with encryption
as
select	c.idCall, c.sCall, c.siIdx, c.bEnabled, c.tStTrg, c.tVoTrg
	,	p.tiSpec, p.tiShelf, p.tiFlags
	from	tbCall		c	with (nolock)
	join	tbCfgPri	p	with (nolock)	on	p.siIdx = c.siIdx
	where	c.bActive > 0
go
grant	select, insert, update			on dbo.vwCall			to [rWriter]
grant	select							on dbo.vwCall			to [rReader]
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering criteria into tbEvent.idEvent range
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	6.05	+ (nolock)
alter proc		dbo.prRpt_XltDtEvRng
(
	@dFrom		datetime			-- date from
,	@dUpto		datetime			-- date upto
,	@tFrom		tinyint				-- hour from
,	@tUpto		tinyint				-- hour upto
,	@iFrom		int			out		-- idEvent from
,	@iUpto		int			out		-- idEvent upto
)
	with encryption
as
begin
	set	nocount	on

	select	@iFrom =	min(idEvent)
		from	tbEvent_S	with (nolock)
		where	@dFrom <= dEvent	and	@tFrom <= tiHH

	select	@iUpto =	min(idEvent)
		from	tbEvent_S	with (nolock)
		where	@dUpto = dEvent		and	@tUpto < tiHH
			or	@dUpto < dEvent

	if	@iUpto is null
		select	@iUpto =	2147483647	--	max int

--	select	@dFrom [dFrom], @iFrom [idFrom], @dUpto [dUpto], @iUpto [idUpto]
end
go
--	----------------------------------------------------------------------------
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
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		select	idCall, lCount, siIdx, tiSpec
			,	case when tiSpec between 7 and 9	then sCall + ' †' else sCall end	[sCall]
			,	case when tiSpec between 7 and 9	then null else tVoTrg end	[tVoTrg],	tVoAvg, tVoMax, lVoNul, lVoOnT
			,	case when tiSpec between 7 and 9	then null else tStTrg end	[tStTrg],	tStAvg, tStMax, lStNul, lStOnT
			,	case when tVoAvg is null	then null else lVoOnT*100/(lCount-lVoNul) end	[fVoOnT]
			,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	[fStOnT]
			from
				(select	ec.idCall, count(*) [lCount]
					,	min(sc.siIdx)	[siIdx],	min(sc.sCall)	[sCall],	min(cp.tiSpec)	[tiSpec]
					,	min(sc.tVoTrg)	[tVoTrg],	min(sc.tStTrg)	[tStTrg]
					,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
					,	max(ec.tVoice)	[tVoMax]
					,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	[lVoOnT]
					,	sum(case when ec.tVoice is null		then 1 else 0 end)	[lVoNul]
					,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
					,	max(ec.tStaff)	[tStMax]
					,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	[lStOnT]
					,	sum(case when ec.tStaff is null		then 1 else 0 end)	[lStNul]
					from	tbEvent_C	ec	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
					group	by ec.idCall)	t
			order by	siIdx desc
	else
		select	idCall, lCount, siIdx, tiSpec
			,	case when tiSpec between 7 and 9	then sCall + ' †' else sCall end	[sCall]
			,	case when tiSpec between 7 and 9	then null else tVoTrg end	[tVoTrg],	tVoAvg, tVoMax, lVoNul, lVoOnT
			,	case when tiSpec between 7 and 9	then null else tStTrg end	[tStTrg],	tStAvg, tStMax, lStNul, lStOnT
			,	case when tVoAvg is null	then null else lVoOnT*100/(lCount-lVoNul) end	[fVoOnT]
			,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	[fStOnT]
			from
				(select	ec.idCall, count(*) [lCount]
					,	min(sc.siIdx)	[siIdx],	min(sc.sCall)	[sCall],	min(cp.tiSpec)	[tiSpec]
					,	min(sc.tVoTrg)	[tVoTrg],	min(sc.tStTrg)	[tStTrg]
					,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
					,	max(ec.tVoice)	[tVoMax]
					,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	[lVoOnT]
					,	sum(case when ec.tVoice is null		then 1 else 0 end)	[lVoNul]
					,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
					,	max(ec.tStaff)	[tStMax]
					,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	[lStOnT]
					,	sum(case when ec.tStaff is null		then 1 else 0 end)	[lStNul]
					from	tbEvent_C	ec	with (nolock)
					join	tb_SessDvc	d	with (nolock)	on	d.idDevice = ec.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
					group	by ec.idCall)	t
			order by	siIdx desc
end
go
--	----------------------------------------------------------------------------
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
alter proc		dbo.prRptCallStatSumGraph
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tb_SessDvc), 0=<invalid>
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		select	ec.dEvent,	count(*)	[lCount]
	--		,	min(sc.tVoTrg)	[tVoTrg],	min(sc.tStTrg)	[tStTrg]
			,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
			,	max(ec.tVoice)	[tVoMax]
			,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
			,	max(ec.tStaff)	[tStMax]
			from	tbEvent_C	ec	with (nolock)
			join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
			join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
			where	ec.idEvent	between @iFrom	and @iUpto
			and		ec.tiHH		between @tFrom	and @tUpto
			and		ec.siBed & @siBeds <> 0
			group	by ec.dEvent
	else
		select	ec.dEvent,	count(*)	[lCount]
	--		,	min(sc.tVoTrg)	[tVoTrg],	min(sc.tStTrg)	[tStTrg]
			,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
			,	max(ec.tVoice)	[tVoMax]
			,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
			,	max(ec.tStaff)	[tStMax]
			from	tbEvent_C	ec	with (nolock)
			join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
			join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
			join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
			where	ec.idEvent	between @iFrom	and @iUpto
			and		ec.tiHH		between @tFrom	and @tUpto
			and		ec.siBed & @siBeds <> 0
			group	by ec.dEvent
end
go
--	----------------------------------------------------------------------------
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
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
			,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	c.tVoTrg, c.tStTrg
			,	case when cp.tiSpec between 7 and 9	then	0 else 1 end	[iCall]
			,	case when cp.tiSpec between 7 and 9	then	null else ec.tVoice end	[tVoice]
			,	case when cp.tiSpec between 7 and 9	then	null else ec.tStaff end	[tStaff]
			,	case when cp.tiSpec = 7				then	ec.tStaff else null end	[tGrn]
			,	case when cp.tiSpec = 8				then	ec.tStaff else null end	[tOra]
			,	case when cp.tiSpec = 9				then	ec.tStaff else null end	[tYel]
			from	vwEvent_C	ec	with (nolock)
			join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
			join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
			join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
			where	ec.idEvent	between @iFrom	and @iUpto
			and		ec.tiHH		between @tFrom	and @tUpto
			and		ec.siBed & @siBeds <> 0
			order	by	ec.sDevice, ec.idEvent
	else
		select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
			,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	c.tVoTrg, c.tStTrg
			,	case when cp.tiSpec between 7 and 9	then	0 else 1 end	[iCall]
			,	case when cp.tiSpec between 7 and 9	then	null else ec.tVoice end	[tVoice]
			,	case when cp.tiSpec between 7 and 9	then	null else ec.tStaff end	[tStaff]
			,	case when cp.tiSpec = 7				then	ec.tStaff else null end	[tGrn]
			,	case when cp.tiSpec = 8				then	ec.tStaff else null end	[tOra]
			,	case when cp.tiSpec = 9				then	ec.tStaff else null end	[tYel]
			from	vwEvent_C	ec	with (nolock)
			join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
			join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
			join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
			join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
			where	ec.idEvent	between @iFrom	and @iUpto
			and		ec.tiHH		between @tFrom	and @tUpto
			and		ec.siBed & @siBeds <> 0
			order	by	ec.sDevice, ec.idEvent
end
go
--	----------------------------------------------------------------------------
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
,	@tiShift	tinyint				-- 0xFF=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 0xFF=any, 1=specific (tb_SessUser), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
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
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
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
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
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
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
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
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
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
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
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
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
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
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
end
go
--	----------------------------------------------------------------------------
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
,	@tiShift	tinyint				-- 0xFF=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 0xFF=any, 1=specific (tb_SessUser), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '') [sRoomBed]
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd	--, a.idUser
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed
					,	a.tiIdx [tiStaff], s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		p.dtBeg, p.dtEnd
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
					where	p.dBeg	between @dFrom and @dUpto
						or	p.dEnd	between @dFrom and @dUpto
					order	by h.idUnit, d.sDevice, b.cBed, p.idStfCvrg
end
go
--	----------------------------------------------------------------------------
--	Returns locations down to unit-level, accessible by a given user; ordered to be loadable into a tree
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
	select	idLoc, idParent, cLoc, sLoc, tiLvl
		from	tbCfgLoc	with (nolock)
			where	tiLvl < 4					-- anything above unit-level
			or		tiLvl = 4	and	(@idUser is null	or	idLoc in (select	idUnit
						from	tb_RoleUnit	ru	with (nolock)
						join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order	by	tiLvl, idLoc
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
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
,	@tiNotify	tinyint				-- not null=set notify + bkup
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

	select	@s= '[' + isnull(cast(@idShift as varchar), '?') + '], u=' + isnull(cast(@idUnit as varchar), '?') +
				', i=' + isnull(cast(@tiIdx as varchar), '?') + ', sh="' + @sShift +
				'", b=' + isnull(cast(@tBeg as varchar), '?') + ', e=' + isnull(cast(@tEnd as varchar), '?') +
				', n=' + isnull(cast(@tiNotify as varchar), '?') + ', bk=' + isnull(cast(@idOper as varchar), '?') +
				', a=' + cast(@bActive as varchar)

	begin	tran

		if	@idShift is null	or	@idShift < 0
		begin
			insert	tbShift	(  idUnit,  tiIdx,  sShift,  tBeg,  tEnd )
					values	( @idUnit, @tiIdx, @sShift, @tBeg, @tEnd )
			select	@idShift =	scope_identity( )

			select	@s =	'Shft_I( ' + @s + ' ) = ' + cast(@idShift as varchar)
				,	@k =	247
		end
		else
		begin
			if	@tiNotify is not null
				update	tbShift		set		dtUpdated=	getdate( ),	tiNotify =	@tiNotify,	idUser =	@idOper
					where	idShift = @idShift
			else	--	instead of:		if	@tBeg is not null
			begin
				update	tbShift		set		dtUpdated=	getdate( ),	tBeg =	@tBeg,	tEnd =	@tEnd,	bActive=	@bActive
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

			select	@s =	'Shft_U( ' + @s + ' )'
				,	@k =	248
		end

		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5415	* [247]: tiLvl= 4->8
update	dbo.tb_LogType	set	tiLvl= 8	where	idLogType = 247
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
--	7.06.5417	* prUnitMap_GetAll -> prUnitMap_GetByUnit
--				+ .idUnit
--	7.03
create proc		dbo.prUnitMap_GetByUnit
(
	@idUnit		smallint			-- unit id
)
	with encryption
as
begin
--	set	nocount	on
	select	idUnit, tiMap, sMap
		from	tbUnitMap	with (nolock)
		where	idUnit = @idUnit
end
go
grant	execute				on dbo.prUnitMap_GetByUnit			to [rWriter]
grant	execute				on dbo.prUnitMap_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns roles, given user is member of
--	7.06.5417
create proc		dbo.pr_UserRole_GetByUser
(
	@idUser		int					-- unit id
)
	with encryption
as
begin
--	set	nocount	on
	select	r.idRole, r.sRole
		from	tb_Role		r	with (nolock)
		join	tb_UserRole	ur	with (nolock)	on	ur.idRole = r.idRole	and	ur.idUser = @idUser
end
go
grant	execute				on dbo.pr_UserRole_GetByUser		to [rWriter]
grant	execute				on dbo.pr_UserRole_GetByUser		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns users, members of a given role
--	7.06.5417
create proc		dbo.pr_UserRole_GetByRole
(
	@idRole		smallint				-- unit id
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUser, u.sStaff
		from	tb_User		u	with (nolock)
		join	tb_UserRole	ur	with (nolock)	on	ur.idUser = u.idUser	and	ur.idRole = @idRole
end
go
grant	execute				on dbo.pr_UserRole_GetByRole		to [rWriter]
grant	execute				on dbo.pr_UserRole_GetByRole		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff member by the given ID
--	7.06.5417
create proc		dbo.pr_User_Get
(
	@idUser		int					-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaffID, sStaff, bOnDuty
		from	tb_User		with (nolock)
		where	idUser = @idUser
end
go
grant	execute				on dbo.pr_User_Get					to [rWriter]
grant	execute				on dbo.pr_User_Get					to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff members of the given team
--	7.06.5421
create proc		dbo.prTeamUser_Get
(
	@idTeam		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	u.idUser, sStaff
		from	tbTeamUser	tu	with (nolock)
		join	tb_User		u	with (nolock)	on	u.idUser = tu.idUser
		where	idTeam = @idTeam
end
go
grant	execute				on dbo.prTeamUser_Get				to [rWriter]
grant	execute				on dbo.prTeamUser_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	fix missing event types
--	<4,tbEvent>
begin tran
	update	dbo.tbEvent	set idLogType= 204	where	idCmd = 0x43	and	idLogType is null
	update	dbo.tbEvent	set idLogType= 205	where	idCmd = 0x41	and	idLogType is null
commit
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
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
,	@sInfo		varchar( 32 )		-- module info (e.g. 'J79???? v.M.mm.bbbb @machine/IP-address')
,	@idLogType	tinyint				-- type look-up FK (marks significant events only)
--,	@dtStart	datetime			-- when running, null == stopped
,	@sParams	varchar( 255 )		-- startup arguments/parameters
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
			update	dbo.tb_Module	set	dtLastAct= getdate( ), dtStart= getdate( ), sParams= @sParams
				where	idModule = @idModule
		else
			update	dbo.tb_Module	set	dtLastAct= getdate( ), dtStart= null	--, sParams= null
				where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sInfo

--		select	@sModInfo=	sModule + ' v.' + sVersion
--			from	dbo.tb_Module	with (nolock)
--			where	idModule = @idModule

		exec	dbo.prEvent_Ins		0, null, null, null		---	@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	null, null, null, null, null, @sInfo	---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5424	- tvDvc_Dial
if	exists	(select 1 from sys.check_constraints where object_id = OBJECT_ID('dbo.tvDvc_Dial'))
begin
	begin tran
		alter table		dbo.tbDvc	drop constraint	tvDvc_Dial

		update	dbo.tbDvc	set	sDial= cast(idDvc as varchar)
			where	idDvcType = 1
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge
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
)
	with encryption, exec as owner
as
begin
---	set	nocount	on
	begin	tran

		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
		begin
			update	tbRtlsBadge	set	bActive= 1, dtUpdated= getdate( )
				where	idBadge = @idBadge	and	bActive = 0

			update	tbDvc		set	bActive= 1, dtUpdated= getdate( ), sDial= cast(@idBadge as varchar)
				where	idDvc = @idBadge	and	bActive = 0
		end
		else
		begin
			set identity_insert	dbo.tbDvc	on

			insert	tbDvc	( idDvc, idDvcType, sDial, sDvc )
					values		( @idBadge, 1, cast(@idBadge as varchar), 'Badge ' + right('00000000' + cast(@idBadge as varchar), 8) )

			set identity_insert	dbo.tbDvc	off

			insert	tbRtlsBadge	(  idBadge )
					values		( @idBadge )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5428	+ xu_User_Act_BarCode
--				* xu_User_Active_StaffID -> xu_User_Act_StaffID
if	not exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tb_User') and name = 'xu_User_Act_BarCode')
begin
	begin tran
		if	exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tb_User') and name = 'xu_User_Active_StaffID')
	--		drop index	tb_User.xu_User_Active_StaffID
			exec sp_rename	'tb_User.xu_User_Active_StaffID', 'xu_User_Act_StaffID', 'index'
	--	create unique nonclustered index	xu_User_Act_StaffID		on dbo.tb_User ( sStaffID )		where	bActive > 0		and	sStaffID is not null	--	7.06.5428
		create unique nonclustered index	xu_User_Act_BarCode		on dbo.tb_User ( sBarCode )		where	bActive > 0		and	sBarCode is not null	--	7.06.5428
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5428	+ xuDvc_Active_BarCode
if	not exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tbDvc') and name = 'xuDvc_Act_BarCode')
begin
	begin tran
		create unique nonclustered index	xuDvc_Act_BarCode	on dbo.tbDvc ( sBarCode )	where	bActive > 0		and	sBarCode is not null	--	7.06.5428
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns staff member by the given bar-code
--	7.06.5428
create proc		dbo.prStaff_GetByBC
(
	@sBarCode	varchar( 32 )		-- bar-code
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	tb_User		with (nolock)
		where	sBarCode = @sBarCode	and	bActive > 0
end
go
grant	execute				on dbo.prStaff_GetByBC				to [rWriter]
grant	execute				on dbo.prStaff_GetByBC				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5429	+ .dtDue
--	7.06.4939	- .tiRouting
--	7.05.5226
alter view		dbo.vwShift
	with encryption
as
select	sh.idUnit, u.sUnit
	,	sh.idShift, tiIdx, sShift, tBeg, tEnd, tiNotify
	,	sh.idUser, s.idStfLvl, s.sStaffID, s.sStaff, s.bOnDuty, s.dtDue
	,	sh.bActive, sh.dtCreated, sh.dtUpdated
	from	tbShift	sh	with (nolock)
	join	tbUnit	u	with (nolock)	on	u.idUnit = sh.idUnit
	left join	vwStaff	s	with (nolock)	on	s.idUser = sh.idUser
go
--	----------------------------------------------------------------------------
--	Returns shifts for a given unit (ordered by index) or current one
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
	select	idShift, idUnit, tiIdx, sShift,	tBeg, tEnd, tiNotify, bActive, dtCreated, dtUpdated, idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	vwShift		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idUnit is null	or	idUnit = @idUnit)
		and		(@bCurrent = 0		or	idShift in (select idShift from tbUnit with (nolock) where idUnit = @idUnit))
		order	by	idUnit, tiIdx
end
go
--	----------------------------------------------------------------------------
--	Returns current active members on-duty
--	7.06.5429	+ .dtDue
--	7.06.5347
alter proc		dbo.prTeam_GetStaffOnDuty
(
	@idTeam		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	tb_User		with (nolock)
		where	bActive > 0		and	bOnDuty > 0
		and		idUser	in	(select idUser from tbTeamUser with (nolock) where idTeam = @idTeam)
	--	order	by	idUser
end
go
--	----------------------------------------------------------------------------
--	Returns staff details for given staff-id
--	7.06.5429	+ .sStaffID, .bOnDuty, .dtDue
--	7.06.5428	* prStaff_GetByStfID -> prStaff_GetBySID
--	7.05.5185
create proc		dbo.prStaff_GetBySID
(
	@sStaffID	varchar( 16 )
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	tb_User		with (nolock)
		where	sStaffID = @sStaffID	and	bActive > 0
end
go
grant	execute				on dbo.prStaff_GetBySID				to [rWriter]
grant	execute				on dbo.prStaff_GetBySID				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff member by the given ID
--	7.06.5430
create proc		dbo.prStaff_Get
(
	@idUser		int					-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	tb_User		with (nolock)
		where	idUser = @idUser
end
go
grant	execute				on dbo.prStaff_Get					to [rWriter]
grant	execute				on dbo.prStaff_Get					to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5437	+ .dtDue
--	7.05.5184	+ .sTeams
--	7.05.5154	+ staff fields
--	7.05.5121	+ .sUnits
--	7.05.5095
alter view		dbo.vwDvc
	with encryption
as
select	d.idDvc, d.idDvcType, t.sDvcType, d.sDial, d.sDvc, d.sBarCode, d.tiFlags, d.sUnits, d.sTeams
	,	t.sDvcType + ' #' + d.sDial		as	sFqDvc
	,	d.idUser, u.idStfLvl, u.sStfLvl, u.sStaffID, u.sStaff, u.sFqStaff, u.bOnDuty, u.dtDue
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDvc		d	with (nolock)
	join	tbDvcType	t	with (nolock)	on	t.idDvcType = d.idDvcType
	left join	vwStaff	u	with (nolock)	on	u.idUser = d.idUser
go
--	----------------------------------------------------------------------------
--	Returns active devices, assigned to a given user
--	7.06.5442	+ @idDvcType
--	7.06.5347
alter proc		dbo.pr_User_GetDvcs
(
	@idUser		int					-- not null
,	@idDvcType	tinyint				-- 1=Badge, 2=Pager, 4=Phone, 0xFF=any
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sDial, tiFlags
		from	tbDvc	with (nolock)
		where	bActive > 0		and idDvcType & @idDvcType	<> 0
		and		idUser = @idUser
	--	order	by	idUser
end
go
--	----------------------------------------------------------------------------
--	7.06.5457	+ .sDial: null -> not null,	- xuDvc_TypeDial,	+ xuDvc_Type_Dial
--if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDvc') and name = 'sDial' and is_nullable = 1)
--if	not exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tbDvc') and name = 'xuDvc_Type_Dial')
if	exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tbDvc') and name = 'xuDvc_TypeDial')
begin
	begin tran
		drop index	dbo.tbDvc.xuDvc_TypeDial

		update	dbo.tbDvc	set	sDial= cast(idDvc as varchar)
			where	idDvcType = 1

		alter table		dbo.tbDvc	alter column
			sDial		varchar( 16 )	not null	-- dialable number (digits only) or badge id

		create unique nonclustered index	xuDvc_Type_Dial		on dbo.tbDvc ( idDvcType, sDial )	--	enforce uniqueness within each type		--	7.06.5457
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a device
--	7.06.5457	* swap @sDial <-> @sBarCode
--	7.05.5186	* fix tbDvcUnit insertion
--	7.05.5184	+ .sTeams
--	7.05.5182	+ @sUnits >> tbDvcUnit (via prUnit_SetTmpFlt)
--	7.05.5121	+ .sUnits
--	7.05.5021
alter proc		dbo.prDvc_InsUpd
(
	@idUser		int					-- user, performing the action
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
	declare		@k	tinyint
			,	@s	varchar( 255 )

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

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams

	select	@s= '[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', n="' + @sDvc + '", b=' + isnull(cast(@sBarCode as varchar), '?') +
				', d=' + isnull(cast(@sDial as varchar), '?') + ', f=' + cast(@tiFlags as varchar) +
				', a=' + cast(@bActive as varchar)
	begin	tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			select	@s= 'Dvc_I( ' + @s + ' ) = '

			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  sUnits,  sTeams,  bActive )
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @sTeams, @bActive )
			select	@idDvc=		scope_identity( )

			select	@s= @s + cast(@idDvc as varchar)
				,	@k=	247
		end
		else
		begin
			select	@s= 'Dvc_U( ' + @s + ' )'

			update	tbDvc	set	idDvcType= @idDvcType, sDvc= @sDvc, sBarCode= @sBarCode, sDial= @sDial
						,	tiFlags= @tiFlags, sUnits= @sUnits, sTeams= @sTeams, bActive= @bActive, dtUpdated= getdate( )
				where	idDvc = @idDvc

			select	@k=	248
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

		delete	from	tbDvcUnit
			where	idDvc = @idDvc
			and		idUnit not in (select	idUnit	from	#tbUnit	with (nolock))

		insert	tbDvcUnit	( idUnit, idDvc )
			select	idUnit, @idDvc
				from	#tbUnit	with (nolock)
				where	idUnit not in (select	idUnit	from	tbDvcUnit	with (nolock)	where	idDvc = @idDvc)

		delete	from	tbDvcTeam
			where	idDvc = @idDvc
			and		idTeam not in (select	idTeam	from	#tbTeam	with (nolock))

		insert	tbDvcTeam	( idTeam, idDvc )
			select	idTeam, @idDvc
				from	#tbTeam	with (nolock)
				where	idTeam not in (select	idTeam	from	tbDvcTeam	with (nolock)	where	idDvc = @idDvc)

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoom') and name = 'idRn')
begin
	begin tran
		exec sp_rename 'tbRoom.idRn',		'idUserG',		'column'
		exec sp_rename 'tbRoom.sRn',		'sStaffG',		'column'
		exec sp_rename 'dbo.fkRoom_Rn',		'fkRoom_UserG'
		exec sp_rename 'tbRoom.idCn',		'idUserO',		'column'
		exec sp_rename 'tbRoom.sCn',		'sStaffO',		'column'
		exec sp_rename 'dbo.fkRoom_Cna',	'fkRoom_UserO'
		exec sp_rename 'tbRoom.idAi',		'idUserY',		'column'
		exec sp_rename 'tbRoom.sAi',		'sStaffY',		'column'
		exec sp_rename 'dbo.fkRoom_Aide',	'fkRoom_UserY'
	commit
end
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + assigned staff
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
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, d.sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		as sSGJ
	,	'[' + cDevice + '] ' + sDevice		as sQnDevice
--	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	as	sFnDevice
	,	r.idEvent,	r.tiSvc
	,	r.idUserG,	s4.idStfLvl as idStfLvlG,	s4.sStaffID as sStaffIDG,	coalesce(s4.sStaff, r.sStaffG) as sStaffG,	s4.bOnDuty as bOnDutyG,	s4.dtDue as dtDueG
	,	r.idUserO,	s2.idStfLvl as idStfLvlO,	s2.sStaffID as sStaffIDO,	coalesce(s2.sStaff, r.sStaffO) as sStaffO,	s2.bOnDuty as bOnDutyO,	s2.dtDue as dtDueO
	,	r.idUserY,	s1.idStfLvl as idStfLvlY,	s1.sStaffID as sStaffIDY,	coalesce(s1.sStaff, r.sStaffY) as sStaffY,	s1.bOnDuty as bOnDutyY,	s1.dtDue as dtDueY
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	tbDevice	d	with (nolock)
	join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
	left join	vwStaff		s4	with (nolock)	on	s4.idUser = r.idUserG
	left join	vwStaff		s2	with (nolock)	on	s2.idUser = r.idUserO
	left join	vwStaff		s1	with (nolock)	on	s1.idUser = r.idUserY
go
--	----------------------------------------------------------------------------
--	790 Devices
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
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		as sSGJ
	,	'[' + cDevice + '] ' + sDevice		as sQnDevice
--	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	as sFnDevice
	,	r.idEvent,	r.tiSvc
	,	r.idUserG, r.sStaffG
	,	r.idUserO, r.sStaffO
	,	r.idUserY, r.sStaffY
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDevice	d	with (nolock)
	left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	rm.idUnit,	ea.idRoom, r.sDevice	as	sRoom,	ea.tiBed, cb.cBed
	,	r.sDevice + case when ea.tiBed is null or ea.tiBed = 0xFF then '' else ' : ' + cb.cBed end		as	sRoomBed
	,	ea.idCall, c.siIdx, c.sCall, cp.iColorF, cp.iColorB, cp.tiShelf, cp.tiSpec, cp.iFilter
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit )		as	bAnswered
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) )	as	tElapsed,	 ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	from		tbEvent_A	ea	with (nolock)
	left join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left join	tbCall		c	with (nolock)	on	c.idCall = ea.idCall
	left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Returns active call, filtered according to args
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
		,	idDevice, idRoom, tiBed, sRoomBed	--, sDevice, sQnDevice, sRoom, cBed
		,	siIdx, sCall, iColorF, iColorB
		,	tElapsed, bActive, bAnswered, bAudio
		from	vwEvent_A	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@bVisible > 0		or	tiShelf > 0)
		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
					from	tb_RoleUnit	ru	with (nolock)
					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	siIdx desc, tElapsed
end
go
grant	execute				on dbo.prEvent_A_GetAll				to [rWriter]
grant	execute				on dbo.prEvent_A_GetAll				to [rReader]
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
--	7.06.5483	* tbEvent_C:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'idAssn1')
begin
	begin tran
		exec( 'update	tbEvent_C	set	idAssn1 =	idUser
				where	idCall in	(select idCall from vwCall where tiSpec between 7 and 9)
			' )

		alter table	dbo.tbEvent_C	drop constraint	fkEventC_User
		alter table	dbo.tbEvent_C	drop column		idUser

		exec sp_rename 'tbEvent_C.idAssn1',		'idUser1',		'column'
		exec sp_rename 'dbo.fkEventC_Assn1',	'fkEventC_User1'
		exec sp_rename 'tbEvent_C.idAssn2',		'idUser2',		'column'
		exec sp_rename 'dbo.fkEventC_Assn2',	'fkEventC_User2'
		exec sp_rename 'tbEvent_C.idAssn3',		'idUser3',		'column'
		exec sp_rename 'dbo.fkEventC_Assn3',	'fkEventC_User3'
	commit
end
go
--	----------------------------------------------------------------------------
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
select	ec.idEvent, ec.dEvent, ec.tEvent, ec.tiHH, ec.idCall, c.sCall
	,	ec.idRoom, d.cDevice, d.sDevice, d.sDial, ec.idUnit, u.sUnit, ec.tiBed, cb.cBed, ec.siBed
	,	d.sDevice + case when ec.tiBed is null then '' else ' : ' + cb.cBed end	as	sRoomBed
	,	ec.idEvtVo, ec.tVoice,	ec.idEvtSt, ec.tStaff
--	,	ec.idUser,	s.idStfLvl,					s.sStaffID,					s.sStaff,				s.bOnDuty,				s.dtDue
	,	ec.idUser1, a1.idStfLvl as idStLvl1,	a1.sStaffID as sStaffID1,	a1.sStaff as sStaff1,	a1.bOnDuty as bOnDuty1,	a1.dtDue as dtDue1
	,	ec.idUser2, a2.idStfLvl as idStLvl2,	a2.sStaffID as sStaffID2,	a2.sStaff as sStaff2,	a2.bOnDuty as bOnDuty2,	a2.dtDue as dtDue2
	,	ec.idUser3, a3.idStfLvl as idStLvl3,	a3.sStaffID as sStaffID3,	a3.sStaff as sStaff3,	a3.bOnDuty as bOnDuty3,	a3.dtDue as dtDue3
	from		tbEvent_C	ec	with (nolock)
	join		tbCall		c	with (nolock)	on	c.idCall = ec.idCall
	join		tbUnit		u	with (nolock)	on	u.idUnit = ec.idUnit
	join		tbDevice	d	with (nolock)	on	d.idDevice = ec.idRoom
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ec.tiBed
--	left join	tb_User		s	with (nolock)	on	s.idUser = ec.idUser
	left join	tb_User		a1	with (nolock)	on	a1.idUser = ec.idUser1
	left join	tb_User		a2	with (nolock)	on	a2.idUser = ec.idUser2
	left join	tb_User		a3	with (nolock)	on	a3.idUser = ec.idUser3
go
--	----------------------------------------------------------------------------
--	7.06.5483	* tbRoomBed:	.idAssn1 -> .idUser1,	.idAssn2 -> .idUser2,	.idAssn3 -> .idUser3
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoomBed') and name = 'idAssn1')
begin
	begin tran
		exec sp_rename 'tbRoomBed.idAssn1',		'idUser1',		'column'
		exec sp_rename 'dbo.fkRoomBed_Assn1',	'fkRoomBed_User1'
		exec sp_rename 'tbRoomBed.idAssn2',		'idUser2',		'column'
		exec sp_rename 'dbo.fkRoomBed_Assn2',	'fkRoomBed_User2'
		exec sp_rename 'tbRoomBed.idAssn3',		'idUser3',		'column'
		exec sp_rename 'dbo.fkRoomBed_Assn3',	'fkRoomBed_User3'
	commit
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
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
select	r.idUnit,	rb.idRoom, r.sDevice as sRoom, r.sQnDevice, d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, rb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	p.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idUser1,	a1.idStfLvl as idStLvl1,	a1.sStaffID as sStaffID1,	a1.sStaff as sStaff1,	a1.bOnDuty as bOnDuty1,	a1.dtDue as dtDue1
	,	rb.idUser2,	a2.idStfLvl as idStLvl2,	a2.sStaffID as sStaffID2,	a2.sStaff as sStaff2,	a2.bOnDuty as bOnDuty2,	a2.dtDue as dtDue2
	,	rb.idUser3,	a3.idStfLvl as idStLvl3,	a3.sStaffID as sStaffID3,	a3.sStaff as sStaff3,	a3.bOnDuty as bOnDuty3,	a3.dtDue as dtDue3
--	,	r.idUserG, r.sStaffG,	r.idUserO, r.sStaffO,	r.idUserY, r.sStaffY
	,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
	,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
	,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
	,	rb.dtUpdated
	from	tbRoomBed	rb	with (nolock)
	join	tbDevice	d	with (nolock)	on	d.idDevice = rb.idRoom		and	d.bActive > 0
	join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
---	left join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0
	left join	tbPatient	p	with (nolock)	on	p.idRoom = rb.idRoom		and	p.tiBed = rb.tiBed	--	p.idPatient = rb.idPatient
	left join	tbDoctor	dc	with (nolock)	on	dc.idDoctor = p.idDoctor
	left join	vwStaff		a1	with (nolock)	on	a1.idUser = rb.idUser1
	left join	vwStaff		a2	with (nolock)	on	a2.idUser = rb.idUser2
	left join	vwStaff		a3	with (nolock)	on	a3.idUser = rb.idUser3
go
--	----------------------------------------------------------------------------
--	7.06.5465	* .tiTmrSt -> .tiTmrA, .tiTmrRn -> .tiTmrG, .tiTmrCn -> .tiTmrO, .tiTmrAi -> .tiTmrY
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent84') and name = 'tiTmrSt')
begin
	begin tran
		exec sp_rename 'tbEvent84.tiTmrSt',	'tiTmrA',		'column'
		exec sp_rename 'tbEvent84.tiTmrRn',	'tiTmrG',		'column'
		exec sp_rename 'tbEvent84.tiTmrCn',	'tiTmrO',		'column'
		exec sp_rename 'tbEvent84.tiTmrAi',	'tiTmrY',		'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns 790 devices, filtered according to args
--	7.06.5414
create proc		dbo.prCfgDvc_GetAll
(
--	@idUser		int			= null	-- null=any
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@tiKind		tinyint		= 0xFF	-- 01=G, 02=M|W, 04=R, 08=Z, 10=*, 20=?
)
	with encryption
as
begin
--	set	nocount	on
	select	idDevice, idParent, tiJID, tiRID, sSGJR, iAID, tiStype, cDevice
		,	case when	sBeds is null	then sDevice	else	sDevice + ' : ' + sBeds	end		as	sDevice
		,	case when	len(sUnits) > 31	then substring(sUnits,1,24) + '..(' + cast((len(sUnits)+1)/4 as varchar) + ' units)'	else sUnits	end		as	sUnits
		,	sDial, sCodeVer, idUnit, bActive, dtCreated, dtUpdated
		from	vwDevice	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@tiKind & 0x01 <> 0	and	tiStype	< 4					--	G-way
			or	@tiKind & 0x02 <> 0		and	tiStype between 4 and 7		--	Room
			or	@tiKind & 0x04 <> 0		and	(tiStype between 8 and 11	or	tiStype = 24	or	tiStype = 26)	--	Master | Workflow
			or	@tiKind & 0x08 <> 0		and	tiStype between 13 and 15	--	Zone
			or	@tiKind & 0x10 <> 0)									--	Other
--		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
--					from	tb_RoleUnit	ru	with (nolock)
--					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	sSGJR
end
go
grant	execute				on dbo.prCfgDvc_GetAll				to [rWriter]
grant	execute				on dbo.prCfgDvc_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
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
	,	sa.tiIdx, sa.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.bOnDuty, s.dtDue
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
	,	sa.tiIdx, sa.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.bOnDuty, s.dtDue
	,	sc.idStfCvrg, sc.dtBeg, sc.dtDue as dtFin	--, sc.dtEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfCvrg	sc	with (nolock)
	join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn
	join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift
	join	vwStaff		s	with (nolock)	on	s.idUser = sa.idUser
	join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
	where	sc.dtEnd is null
go
--	----------------------------------------------------------------------------
--	Returns staff assignements for the given shift and room-bed
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
	select	idStfAssn, idShift, idRoom, tiBed, tiIdx,	idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	vwStfAssn	with (nolock)
		where	bActive > 0 and idStfCvrg > 0	and	idShift = @idShift	and	idRoom = @idRoom
		and		(tiBed = @tiBed		or
				@tiBed	is null		and	tiBed in	(select min(tiBed)	from	vwStfAssn with (nolock)
					where	bActive > 0	and idStfCvrg > 0	and	idShift = @idShift	and	idRoom = @idRoom))
		order	by	tiIdx
end
go
grant	execute				on dbo.prStfAssn_GetByRoom			to [rWriter]
grant	execute				on dbo.prStfAssn_GetByRoom			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all staff assignments for given unit/shift
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
	select	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.sQnDevice
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	a1.idStfAssn as idStfAssn1,	a1.idUser as idUser1, a1.idStfLvl as idStfLvl1, a1.sStaffID as sStaffID1, a1.sStaff as sStaff1, a1.bOnDuty as bOnDuty1, a1.dtDue as dtDue1
		,	a2.idStfAssn as idStfAssn2,	a2.idUser as idUser2, a2.idStfLvl as idStfLvl2, a2.sStaffID as sStaffID2, a2.sStaff as sStaff2, a2.bOnDuty as bOnDuty2, a2.dtDue as dtDue2
		,	a3.idStfAssn as idStfAssn3,	a3.idUser as idUser3, a3.idStfLvl as idStfLvl3, a3.sStaffID as sStaffID3, a3.sStaff as sStaff3, a3.bOnDuty as bOnDuty3, a3.dtDue as dtDue3
		from	vwRoomBed	rb	with (nolock)
--		left join	tbPatient	pt	with (nolock)	on	pt.idPatient = rb.idPatient
		left join	vwStfAssn	a1	with (nolock)	on	a1.idRoom = rb.idRoom	and	a1.tiBed = rb.tiBed	and	a1.idShift = @idShift	and	a1.tiIdx = 1	and	a1.bActive > 0
		left join	vwStfAssn	a2	with (nolock)	on	a2.idRoom = rb.idRoom	and	a2.tiBed = rb.tiBed	and	a2.idShift = @idShift	and	a2.tiIdx = 2	and	a2.bActive > 0
		left join	vwStfAssn	a3	with (nolock)	on	a3.idRoom = rb.idRoom	and	a3.tiBed = rb.tiBed	and	a3.idShift = @idShift	and	a3.tiIdx = 3	and	a3.bActive > 0
		where	rb.idUnit = @idUnit
		order	by	rb.sRoom, rb.cBed
end
go
--	----------------------------------------------------------------------------
--	Returns available staff for given unit(s)
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
		,	pg.idDvc as idPager,	pg.sDial as sPager
		,	ph.idDvc as idPhone,	ph.sDial as sPhone
	--	,	bd.idDvc as idBadge,	bd.sDial as sBadge
		from	vwStaff	st	with (nolock)
		left join	vwRoom	r	with (nolock)	on	r.idDevice = st.idRoom
	--	left join	tbDvc	bd	with (nolock)	on	bd.idUser = st.idUser	and	bd.idDvcType = 1	and	bd.bActive > 0
		left join	tbDvc	pg	with (nolock)	on	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
		left join	tbDvc	ph	with (nolock)	on	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
		where	st.bActive > 0
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@bOnDuty is null	or	st.bOnDuty = @bOnDuty)
		and		st.idUser in (select	idUser
			from	tb_UserUnit	uu	with (nolock)
			join	#tbUnit		u	with (nolock)	on	u.idUnit = uu.idUnit)
		order	by	st.idStfLvl desc, st.sStaff
end
go
--	----------------------------------------------------------------------------
--	Returns on-duty pageable staff for given unit(s)
--	7.06.5429	+ .sStaffID, .bOnDuty, .dtDue
--	7.06.5388	+ distinct
--	7.06.5333	* added staff with phones
--	7.05.5185
alter proc		dbo.prStaff_GetPageable
(
	@idUnit		smallint			-- null=any
,	@idStfLvl	tinyint				-- null=any, 1=Yel, 2=Ora, 4=Grn
)
	with encryption
as
begin
--	set	nocount	on
	select	distinct	st.idUser, idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from	tb_User	st	with (nolock)
	--	join	tbDvc	pg	with (nolock)	on	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
		join	tbDvc	nd	with (nolock)	on	nd.idUser = st.idUser	and	nd.idDvcType <> 1	and	nd.bActive > 0
		where	st.bActive > 0		and	st.bOnDuty > 0
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@idUnit is null	or	st.idUser	in	(select idUser from tb_UserUnit with (nolock) where idUnit = @idUnit))
		order	by	sStaff
end
go
--	----------------------------------------------------------------------------
--	Returns assigned room-beds for the given staff member
--	7.06.5437
create proc		dbo.prStaff_GetAssn
(
	@idUser		int					-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idStfAssn, idRoom, tiBed, cDevice, sRoom, tiIdx
		from	vwStfAssn	sa	with (nolock)
		join	tbUnit	u	with (nolock)	on	u.idShift = sa.idShift	and	u.bActive > 0
		where	sa.bActive > 0
		and		idUser = @idUser
		order	by	sRoom, tiBed
end
go
grant	execute				on dbo.prStaff_GetAssn				to [rWriter]
grant	execute				on dbo.prStaff_GetAssn				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
--	7.06.5437	+ .dtDue
--	7.06.5336	* @idDvcType is bitwise now
--	7.05.5189	+ .idRoom, .sQnRoom
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
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rr.idRoom, r.sQnDevice	[sQnRoom]
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rr.idRoom
		where	idDvcType & @idDvcType	<> 0
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bGroup is null	or	tiFlags & 0x01 = @bGroup)
		and		(@idUnit is null	or	idDvcType = 1	or	idDvc in (select idDvc	from	tbDvcUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given bar-code
--	7.06.5437	+ .dtDue
--	7.06.5428
create proc		dbo.prDvc_GetByBC
(
	@sBarCode	varchar( 32 )		-- bar-code
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, d.sDial, tiFlags, sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rr.idRoom, r.sQnDevice	[sQnRoom]
		,	idUser, d.idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from		vwDvc		d	with (nolock)
		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rr.idRoom
		where	d.bActive > 0	and	sBarCode = @sBarCode
end
go
grant	execute				on dbo.prDvc_GetByBC				to [rWriter]
grant	execute				on dbo.prDvc_GetByBC				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given dial-code
--	7.06.5437
create proc		dbo.prDvc_GetByDial
(
	@sDial		varchar( 16 )		-- dialable number
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, d.sDial, tiFlags, sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rr.idRoom, r.sQnDevice	[sQnRoom]
		,	idUser, d.idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from		vwDvc		d	with (nolock)
		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rr.idRoom
		where	d.bActive > 0	and	d.sDial = @sDial
end
go
grant	execute				on dbo.prDvc_GetByDial				to [rWriter]
grant	execute				on dbo.prDvc_GetByDial				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates room's staff
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
,	@idUnit		smallint			-- active unit ID
,	@sStaffG	varchar( 16 )
,	@sStaffO	varchar( 16 )
,	@sStaffY	varchar( 16 )
)
	with encryption
as
begin
	declare		@idUserG	int
		,		@idUserO	int
		,		@idUserY	int

	set	nocount	on

--	if	not	exists	(select 1 from tbCfgLoc where idLoc = @idUnit and tiLvl = 4)	select	@idUnit= null
--	if	not	exists	(select 1 from tbUnit where idUnit = @idUnit and bActive > 0)	select	@idUnit= null

--	if	len( @sRn ) > 0		select	@idRn= idUser	from	tb_User with (nolock)	where	sStaff = @sStaffG
--	if	len( @sCn ) > 0		select	@idCn= idUser	from	tb_User with (nolock)	where	sStaff = @sCn
--	if	len( @sAi ) > 0		select	@idAi= idUser	from	tb_User with (nolock)	where	sStaff = @sAi
	select	@idUserG =	idUser	from	tb_User with (nolock)	where	sStaff = @sStaffG
	select	@idUserO =	idUser	from	tb_User with (nolock)	where	sStaff = @sStaffO
	select	@idUserY =	idUser	from	tb_User with (nolock)	where	sStaff = @sStaffY

--	begin	tran

		update	tbRoom	set	idUnit =	@idUnit,	dtUpdated=	getdate( )
						,	idUserG =	@idUserG,	sStaffG =	@sStaffG
						,	idUserO =	@idUserO,	sStaffO =	@sStaffO
						,	idUserY =	@idUserY,	sStaffY =	@sStaffY
			where	idRoom = @idRoom

--	commit
end
go
grant	execute				on dbo.prRoom_UpdStaff				to [rWriter]
--grant	execute				on dbo.prRoom_UpdStaff				to [rReader]
go
--	----------------------------------------------------------------------------
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
	,	cast( case when e84.siPriNew & 0x0400 > 0 then 0 else 1 end as bit )	as bAnswered
	,	e84.siElapsed, e84.tiPrivacy, e84.tiTmrA, e84.tiTmrG, e84.tiTmrO, e84.tiTmrY
	,	e84.idPatient, p.sPatient, p.cGender
	,	e84.idDoctor, v.sDoctor, e.sInfo
	,	e84.tiCvrg0, e84.tiCvrg1, e84.tiCvrg2, e84.tiCvrg3, e84.tiCvrg4, e84.tiCvrg5, e84.tiCvrg6, e84.tiCvrg7
	,	e84.siDuty0, e84.siDuty1, e84.siDuty2, e84.siDuty3, e84.siZone0, e84.siZone1, e84.siZone2, e84.siZone3
	from	tbEvent84	e84
	join	tbEvent		e	on	e.idEvent = e84.idEvent
	join	tbCall		c	on	c.idCall = e.idCall
	join	tbDevice	d	on	d.idDevice = e.idSrcDvc
	join	tbDevice	r	on	r.idDevice = e.idRoom
	left join	tbPatient	p	on	p.idPatient = e84.idPatient
	left join	tbDoctor	v	on	v.idDoctor = e84.idDoctor
go
--	----------------------------------------------------------------------------
--	Resets location attributes for all badges
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.05.5192	+ tbRoom
--	7.05.5099	+ tb_User.idRoom
--	7.03.4898	* prBadge_ClrAll -> prRtlsBadge_RstLoc
--	6.03
alter proc		dbo.prRtlsBadge_RstLoc
	with encryption
as
begin
	set	nocount	on

	begin	tran

		update	tbRtlsRoom	set dtUpdated=	getdate( ),		idBadge =	null,	bNotify =	1
		update	tbRtlsBadge	set dtEntered=	getdate( ),		idRoom =	null,	idRcvrCurr =	null	--, dtUpdated= getdate( )
		update	tb_User		set	dtEntered=	getdate( ),		idRoom =	null
		update	tbRoom		set	dtUpdated=	getdate( ),		idUserG =	null,	sStaffG =	null,	idUserO =	null,	sStaffO =	null,	idUserY =	null,	sStaffY =	null

	commit
end
go
--	----------------------------------------------------------------------------
--	Deactivates all devices, resets room state
--	7.06.5529	+ tbRoomBed reset
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.06.5352	+ 'and tiStype is not null' - don't deactivate SIP devices
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03.4862
alter proc		dbo.prCfgDvc_Init
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@iTrace		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		update	tbRoom		set	idUnit= null,	idEvent= null,	tiSvc= null,	dtUpdated=	getdate( )
							,	idUserG= null,	sStaffG= null,	idUserO= null,	sStaffO= null,	idUserY= null,	sStaffY= null

		update	tbRoomBed	set	tiIBed= null,	idEvent= null,	tiSvc= null,	dtUpdated=	getdate( )
							,	idUser1= null,	idUser2= null,	idUser3= null,	idPatient=	null

		update	tbDevice	set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1
			and		tiStype is not null										--	7.06.5352

		select	@s= 'Dvc_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Rooms 'presence' state (oldest badges)
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.05.5192	* joins
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
	,	min(case when r.idStfLvl = 4	then sd.idUser	else null end)	as	idUserG
	,	min(case when r.idStfLvl = 4	then s.sStaff	else null end)	as	sStaffG
	,	min(case when r.idStfLvl = 2	then sd.idUser	else null end)	as	idUserO
	,	min(case when r.idStfLvl = 2	then s.sStaff	else null end)	as	sStaffO
	,	min(case when r.idStfLvl = 1	then sd.idUser	else null end)	as	idUserY
	,	min(case when r.idStfLvl = 1	then s.sStaff	else null end)	as	sStaffY
	,	max(cast(r.bNotify as tinyint))									as	tiNotify
	,	min(r.dtUpdated)												as	dtUpdated
	from	tbRtlsRoom		r	with (nolock)
	join	tbDevice		d	with (nolock)	on	d.idDevice = r.idRoom
	left join	tbRtlsBadge	b	with (nolock)	on	b.idBadge = r.idBadge
	left join	tbDvc		sd	with (nolock)	on	sd.idDvc = b.idBadge
	left join	vwStaff		s	with (nolock)	on	s.idUser = sd.idUser
	group by	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
go
revoke	insert, update, delete			on dbo.vwRtlsRoom		from [rWriter]
go
--	----------------------------------------------------------------------------
--	7.06.5466	+ [26]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 26)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 26, 167, 'Allowed System(s)' )						--	7.06.5466
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 26, '' )
	end
commit
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@idUnit		smallint
		,		@sUnits		varchar( 255 )
	
	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	select	@s =	'Dvc_IU( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ', v=' + isnull(@sCodeVer,'?') +
					', p0=' + isnull(cast(@tiPriCA0 as varchar),'?') + ', p1=' + isnull(cast(@tiPriCA1 as varchar),'?') + ' )'

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

--	select	@s =	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')

	begin	tran

		if	@tiJID = 0												-- gateway		-- v.7.06.5414
		begin
			select	@sUnits =	@sDial,		@sDial =	null

			if	charindex(@cSys, @sSysts) = 0						-- add cSys to Allowed Systems
				update	tb_OptSys	set	sValue =	sValue + @cSys
					where	idOption = 26
		end
		else														-- calculate .sUnits
		begin
			create table	#tbUnit
			(
				idUnit		smallint
			)

			if	@tiPriCA0 = 0xFF	or	@tiPriCA1 = 0xFF	or	@tiPriCA2 = 0xFF	or	@tiPriCA3 = 0xFF	or
				@tiPriCA4 = 0xFF	or	@tiPriCA5 = 0xFF	or	@tiPriCA6 = 0xFF	or	@tiPriCA7 = 0xFF	or
				@tiAltCA0 = 0xFF	or	@tiAltCA1 = 0xFF	or	@tiAltCA2 = 0xFF	or	@tiAltCA3 = 0xFF	or
				@tiAltCA4 = 0xFF	or	@tiAltCA5 = 0xFF	or	@tiAltCA6 = 0xFF	or	@tiAltCA7 = 0xFF
			begin
				insert	#tbUnit
					select	idLoc
						from	tbCfgLoc	with (nolock)
						where	tiLvl = 4	-- unit
			end
			else													-- specific units
			begin
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

		if	@idDevice > 0											-- device found - update
		begin
			if	@iAID > 0
				update	tbDevice	set		iAID= @iAID
					where	idDevice = @idDevice	and	iAID is null

			update	tbDevice	set		idParent= @idParent,	cSys= @cSys, tiGID= @tiGID, tiJID= @tiJID, tiRID= @tiRID
				where	idDevice = @idDevice	and	iAID = @iAID

			if	@sCodeVer is not null								-- retain previous values
				update	tbDevice	set		sCodeVer= @sCodeVer
					where	idDevice = @idDevice

			update	tbDevice	set		bActive= 1, dtUpdated= getdate( )	--, idEvent= null
				,	tiStype= @tiStype,	cDevice= @cDevice,	sDevice= @sDevice,	sDial= @sDial,	sCodeVer= @sCodeVer,	sUnits= @sUnits
				,	tiPriCA0= @tiPriCA0, tiPriCA1= @tiPriCA1, tiPriCA2= @tiPriCA2, tiPriCA3= @tiPriCA3
				,	tiPriCA4= @tiPriCA4, tiPriCA5= @tiPriCA5, tiPriCA6= @tiPriCA6, tiPriCA7= @tiPriCA7
				,	tiAltCA0= @tiAltCA0, tiAltCA1= @tiAltCA1, tiAltCA2= @tiAltCA2, tiAltCA3= @tiAltCA3
				,	tiAltCA4= @tiAltCA4, tiAltCA5= @tiAltCA5, tiAltCA6= @tiAltCA6, tiAltCA7= @tiAltCA7
				where	idDevice = @idDevice

	--		select	@s =	@s + '  UPD'
		end
		else														-- insert new device
		begin
/*			if	@tiRID = 0		--	@cDevice = 'R'					--	7.06.5466 - since .idUnit is skipped in INSERT below
				select	@idUnit =	idParent						-- set room's current unit to primary CA's
					from	tbCfgLoc	with (nolock)
					where	idLoc = @tiPriCA0
			else
				select	@idUnit =	null
*/
			insert	tbDevice	( idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial,  sCodeVer,  sUnits	--,  idUnit
								,	tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
								,	tiAltCA0,  tiAltCA1,  tiAltCA2,  tiAltCA3,  tiAltCA4,  tiAltCA5,  tiAltCA6,  tiAltCA7 )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial, @sCodeVer, @sUnits	--, @idUnit
								,	@tiPriCA0, @tiPriCA1, @tiPriCA2, @tiPriCA3, @tiPriCA4, @tiPriCA5, @tiPriCA6, @tiPriCA7
								,	@tiAltCA0, @tiAltCA1, @tiAltCA2, @tiAltCA3, @tiAltCA4, @tiAltCA5, @tiAltCA6, @tiAltCA7 )
			select	@idDevice=	scope_identity( )

--			select	@s =	@s + '  id=' + cast(@idDevice as varchar)
		end

		if	@iTrace & 0x04 > 0
		begin
			select	@s =	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds devices and inserts if necessary (during run-time)
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

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	if	charindex('SIP:', @sDevice) = 1					-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ' )'

	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow
		select	@idDevice=	idDevice, @bActive=	bActive
			from	tbDevice	with (nolock)
			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	--and	bActive > 0

		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice

			return	0												--	7967-P workflow station's (0x1A) 'phantom' RIDs
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

	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	begin
		begin	tran

			if	charindex(@cSys, @sSysts) = 0						-- not in Allowed Systems
			begin
				select	@s =	@s + '  cSys'
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
					select	@s =	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
					exec	dbo.pr_Log_Ins	74, null, null, @s
				end
			end

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	fix	existing SIP devices
update	dbo.tbDevice	set	cDevice =	'P'
	where	cDevice = '?'	and	charindex('SIP:', sDevice) = 1;
go
--	----------------------------------------------------------------------------
--	7981 - Returns rooms for updating RTLS state
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.05.5192	* include empty names into output
--	6.05
alter proc		dbo.prRtlsRoom_Get
(
	@siAge			smallint = 0		-- age in seconds
)
	with encryption
as
begin
--	set	nocount	on
	select	idRoom, cSys, tiGID, tiJID, tiRID, sStaffG, sStaffO, sStaffY
		from	vwRtlsRoom	with (nolock)
		where	@siAge > 0  and  datediff(ss, dtUpdated, getdate( )) > @siAge
			or	tiNotify > 0
end
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
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
alter proc		dbo.prDevice_UpdRoomBeds
(
	@idRoom		smallint			-- room id
,	@siBeds		smallint			-- beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
)
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@sBeds		varchar( 10 )
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

	if	not	exists	(select 1 from tbDevice with (nolock) where idDevice = @idRoom and cDevice='R' and bActive>0)
	and	not	exists	(select 1 from tbDevice with (nolock) where idParent = @idRoom and cDevice='W' and bActive>0)	-- and tiStype=26 and tiRID=1
		return	0					-- only do room-beds for rooms or 7967-Ps


	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	-- primary coverage
	select	@sBeds =	'',	@tiBed =	1,	@siMask =	1,	@sRoom =	sDevice,	@sDial =	sDial
		,	@tiCA0=	tiPriCA0,	@tiCA1=	tiPriCA1,	@tiCA2=	tiPriCA2,	@tiCA3=	tiPriCA3
		,	@tiCA4=	tiPriCA4,	@tiCA5=	tiPriCA5,	@tiCA6=	tiPriCA6,	@tiCA7=	tiPriCA7
		from	tbDevice	with (nolock)
		where	idDevice = @idRoom

	if	@tiCA0 = 0xFF	--or @tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
--	or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
		select	top 1	@idUnitP =	idUnit			-- pick min unit
			from	tbUnit		with (nolock)
			order	by	idUnit
	else
		select	@idUnitP =	idParent				-- convert PriCA0 to its unit
			from	tbCfgLoc	with (nolock)
			where	idLoc = @tiCA0

	-- alternate coverage
	select	@tiCA0=	tiAltCA0,	@tiCA1=	tiAltCA1,	@tiCA2=	tiAltCA2,	@tiCA3=	tiAltCA3
		,	@tiCA4=	tiAltCA4,	@tiCA5=	tiAltCA5,	@tiCA6=	tiAltCA6,	@tiCA7=	tiAltCA7
		from	tbDevice	with (nolock)
		where	idDevice = @idRoom

	if	@tiCA0 = 0xFF	--or @tiCA1 = 0xFF	or	@tiCA2 = 0xFF	or	@tiCA3 = 0xFF	-- all CAs/Units
--	or	@tiCA4 = 0xFF	or	@tiCA5 = 0xFF	or	@tiCA6 = 0xFF	or	@tiCA7 = 0xFF
		select	top 1 @idUnitA =	idUnit			-- pick max unit
			from	tbUnit		with (nolock)
			order	by	idUnit	desc
	else
		select	@idUnitA =	idParent				-- convert AltCA0 to its unit
			from	tbCfgLoc	with (nolock)
			where	idLoc = @tiCA0


	select	@s= 'Dvc_URB( ' + isnull(cast(@idRoom as varchar), '?') + ', r="' + isnull(@sRoom, '?') + '", d=' + isnull(@sDial, '?') +
				', uP=' + isnull(cast(@idUnitP as varchar), '?') + ', uA=' + isnull(cast(@idUnitA as varchar), '?') +
				', b=' + isnull(cast(@siBeds as varchar), '?') + ' )'

	if	@iTrace & 0x08 > 0
		exec	dbo.pr_Log_Ins	75, null, null, @s

	begin	tran

	---	delete	from	tbRoomBed					-- NO: removes patient-to-bed assignments!!
	---		where	idRoom = @idRoom

		if	exists	(select 1 from tbRoom with (nolock) where idRoom = @idRoom)
			exec	dbo.prRoom_UpdStaff		@idRoom, @idUnitP, null, null, null			-- reset	v.7.03
		else
			insert	tbRoom	( idRoom,  idUnit)		-- init staff placeholder for this room	v.7.02, v.7.03
					values	(@idRoom, @idUnitP)

		delete	from	tbRtlsRoom					-- reinit staff presence placeholders		v.7.02
			where	idRoom = @idRoom
		insert	tbRtlsRoom	(idRoom, idStfLvl, bNotify)
				select		@idRoom, idStfLvl, 1
					from	tbStfLvl	with (nolock)

		if	@siBeds = 0								-- no beds in this room
		begin
			--	remove combinations with beds
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
				insert	tbRoomBed	(  idRoom, cBed, tiBed )
						values		( @idRoom, null, 0xFF )

			select	@sBeds =	null				--	7.05.5212
		end
		else										-- there are beds
		begin
			--	remove combination with no beds
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF

			while	@siMask < 1024
			begin
				select	@cBedIdx =	cast(@tiBed as char(1))

				if	@siBeds & @siMask > 0			-- @tiBed is present in @idRoom
				begin
					update	tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )
						where	tiBed = @tiBed	and	bActive = 0

					select	@cBed=	cBed,	@sBeds =	@sBeds + cBed
						from	tbCfgBed	with (nolock)
						where	tiBed = @tiBed

					if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = @tiBed)
						insert	tbRoomBed	(  idRoom,  cBed,  tiBed )
								values		( @idRoom, @cBed, @tiBed )
				end
				else								--	@tiBed is absent in @idRoom
					delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = @tiBed

				select	@siMask =	@siMask * 2
					,	@tiBed =	case when @tiBed < 9 then @tiBed + 1 else 0 end
			end
		end

		update	tbRoom		set	dtUpdated=	getdate( ),	tiSvc=	null,	siBeds =	@siBeds,	sBeds=	@sBeds
			where	idRoom = @idRoom
		update	tbRoomBed	set	dtUpdated=	getdate( ),	tiSvc=	null	--	7.05.5098
			where	idRoom = @idRoom


		--	loop through all active 7947 - 8-Input Bed Interfaces in that room and mark
		declare		cur		cursor fast_forward for
			select	idDevice, tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
				from	tbDevice	with (nolock)
				where	idParent = @idRoom	and	tiStype = 192	and	bActive > 0

		open	cur
		fetch next from	cur	into	@idDevice, @tiCA0, @tiCA1, @tiCA2, @tiCA3, @tiCA4, @tiCA5, @tiCA6, @tiCA7
		while	@@fetch_status = 0
		begin
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA0 & 0x0F	--	button 0's bed
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA1 & 0x0F	--	button 1's bed
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA2 & 0x0F	--	button 2's bed
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA3 & 0x0F	--	button 3's bed
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA4 & 0x0F	--	button 4's bed
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA5 & 0x0F	--	button 5's bed
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA6 & 0x0F	--	button 6's bed
			update	tbRoomBed	set	tiIbed =	0	where	idRoom = @idRoom	and	tiBed = @tiCA7 & 0x0F	--	button 7's bed

			fetch next from	cur	into	@idDevice, @tiCA0, @tiCA1, @tiCA2, @tiCA3, @tiCA4, @tiCA5, @tiCA6, @tiCA7
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	Finalizes specified staff assignment definition by marking it inactive
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
	@idStfAssn		int
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
		update	tbStfCvrg	set		dtEnd=	@dtNow,		dEnd= @dtNow,	tEnd= @dtNow,	tiEnd=	datepart(hh, @dtNow)
			where	idStfAssn = @idStfAssn
		select	@iCvrg =	@@rowcount

		-- reset assigned staff if in room
		update	rb	set	idUser1 =	null		
			from	tbRoomBed	rb
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
			where	idStfAssn = @idStfAssn
			and		rb.idUser1 = sa.idUser

		update	rb	set	idUser2 =	null
			from	tbRoomBed	rb
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
			where	idStfAssn = @idStfAssn
			and		rb.idUser2 = sa.idUser

		update	rb	set	idUser3 =	null
			from	tbRoomBed	rb
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
			where	idStfAssn = @idStfAssn
			and		rb.idUser3 = sa.idUser

		-- deactivate
		update	tbStfAssn	set		bActive =	0,	idStfCvrg=	null,	dtUpdated=	getdate( )
			where	idStfAssn = @idStfAssn

		-- purge if no coverage history
		if	@iCvrg = 0
			delete	from	tbStfAssn
				where	idStfAssn = @idStfAssn

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
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
	declare		@dtNow		smalldatetime
		,		@dtDue		smalldatetime
		,		@tNow		time( 0 )
		,		@idStfAssn	int
		,		@idStfCvrg	int

	set	nocount	on
	set	xact_abort	on

	select	@dtNow =	getdate( )		-- smalldatetime truncates seconds
	select	@tNow =		@dtNow			-- time(0) truncates date, leaving HH:MM:00

---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	create	table	#tbDueAssn
	(
		idStfCvrg	int			not null	primary key clustered

	,	idStfAssn	int			not null
	)

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


		-- get assignments that should be started/running now, only for OnDuty staff
		declare	cur		cursor fast_forward for
			select	sa.idStfAssn,
			--		case when	sh.tBeg < sh.tEnd	then	@dtNow - @tNow + sh.tEnd		--	!! this works in 2008 R2, but not in 2012
				---		when	sh.tBeg = sh.tEnd	then	@dtNow - @tNow + sh.tEnd + 1	--	matches else (sh.tBeg > sh.tEnd) case
			--										else	@dtNow - @tNow + sh.tEnd + 1 end
					case when	sh.tBeg < sh.tEnd	then	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime)
													else	@dtNow - cast(@tNow as smalldatetime) + cast(sh.tEnd as smalldatetime) + 1 end
				from	tbStfAssn	sa	with (nolock)
				join	tb_User		us	with (nolock)	on	us.idUser  = sa.idUser		and	us.bOnDuty > 0	-- only OnDuty
				join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		and	sh.bActive > 0
				where	sa.bActive > 0
				and		sa.idStfCvrg is null						--	not running now
				and		(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStfAssn, @dtDue
		while	@@fetch_status = 0
		begin
---			print	cast(@idStfAssn, varchar) + ': ' + cast(@dtDue, varchar)
		
			insert	tbStfCvrg	(  idStfAssn, dtBeg, dBeg, tBeg, tiBeg, dtDue )
					values		( @idStfAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ), @dtDue )
			select	@idStfCvrg =	scope_identity( )

			update	tbStfAssn	set		idStfCvrg=	@idStfCvrg,		dtUpdated=	@dtNow
				where	idStfAssn = @idStfAssn

			fetch next from	cur	into	@idStfAssn, @dtDue
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
--	Data source for 7985
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
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
--			,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
--			,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
--			,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
--			,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
--			,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
--			,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as tiMap
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
			,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as tiMap
			from	vwRoomBed		rb	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
				outer apply	fnEventA_GetTopByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster, 0 )	ea		--	7.03
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	mc.tiMap
			from	#tbUnit			tu	with (nolock)
				outer apply	fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea									--	7.03
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
				outer apply	fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
			order	by	tu.sUnit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
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
		,	r.idDevice as idRoom,	r.sDevice as sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
		,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
		,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
		,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
		,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
		,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
		,	mc.tiMap, mc.tiCell, mc.sCell1, mc.sCell2, r.siBeds, r.sBeds	-- rr.siBeds, rr.sBeds
		,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	tbUnitMapCell	mc	with (nolock)
			join	tbUnit		u	with (nolock)	on	u.idUnit = mc.idUnit
			left join	vwRoom	r	with (nolock)
				on	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0		and	r.bActive > 0
			outer apply	fnEventA_GetTopByRoom( mc.cSys, mc.tiGID, mc.tiJID, null, @iFilter, @idMaster, 1 )	ea		--	7.03
			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
		where	mc.idUnit = @idUnit
			and	mc.tiMap = @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go
--	----------------------------------------------------------------------------
--	Returns assigned staff for given room-bed
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
	select	idUser1, idStLvl1, sStaffID1, sStaff1, bOnDuty1, dtDue1
		,	idUser2, idStLvl2, sStaffID2, sStaff2, bOnDuty2, dtDue2
		,	idUser3, idStLvl3, sStaffID3, sStaff3, bOnDuty3, dtDue3
		from	vwRoomBed	with (nolock)
		where	idRoom = @idRoom
		and		(tiBed = @tiBed		or	@tiBed = 0xFF	and	tiBed = 1)
end
go
--	----------------------------------------------------------------------------
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
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
			,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg
			,	ec.tVoice, ec.tStaff,	ec.sStaff1, ec.sStaff2, ec.sStaff3,		ec.sRoomBed
			from	vwEvent_C	ec	with (nolock)
			join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
			join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
			join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
			where	ec.idEvent	between @iFrom	and @iUpto
			and		ec.tiHH		between @tFrom	and @tUpto
			and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
			and		ec.siBed & @siBeds <> 0
			order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
	else
		select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
			,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg
			,	ec.tVoice, ec.tStaff,	ec.sStaff1, ec.sStaff2, ec.sStaff3,		ec.sRoomBed
			from	vwEvent_C	ec	with (nolock)
			join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
			join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
			join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
			join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
			where	ec.idEvent	between @iFrom	and @iUpto
			and		ec.tiHH		between @tFrom	and @tUpto
			and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
			and		ec.siBed & @siBeds <> 0
			order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.5484	- fkUnitMapCell_Unit (fkUnitMapCell_UnitMap is transitive)
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnitMapCell_Unit')
begin
	begin tran
		alter table	dbo.tbUnitMapCell	drop constraint	fkUnitMapCell_Unit
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5484	- tbEvent86, prEvent86_Ins, tbEvent8C, prEvent8C_Ins, tbEvent99, prEvent99_Ins, tbEvent9B, prEvent9B_Ins, tbEventAB, prEventAB_Ins, tbEventB1, prEventB1_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventB1_Ins')
	drop proc	dbo.prEventB1_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventAB_Ins')
	drop proc	dbo.prEventAB_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent9B_Ins')
	drop proc	dbo.prEvent9B_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent99_Ins')
	drop proc	dbo.prEvent99_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent8C_Ins')
	drop proc	dbo.prEvent8C_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent86_Ins')
	drop proc	dbo.prEvent86_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventB1')
	drop table	dbo.tbEventB1
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventAB')
	drop table	dbo.tbEventAB
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent9B')
	drop table	dbo.tbEvent9B
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent99')
	drop table	dbo.tbEvent99
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent8C')
	drop table	dbo.tbEvent8C
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent86')
	drop table	dbo.tbEvent86
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed
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

	select	@sPatient=	sPatient
		from	tbPatient	with (nolock)
		where	idPatient = @idPatient

	select	@idRoom =	idDevice,	@sDevice =	sDevice
		from	vwRoom		with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	bActive > 0		--	and	tiRID = @tiRID

	select	@s=	'Pat_UL( [' + isnull(cast(@idPatient as varchar),'?') + '] "' + isnull(@sPatient,'?') +
				'", ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
				right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
				', [' + isnull(cast(@idRoom as varchar),'?') + '] ' + isnull(@sDevice,'?') +
				', b=' + isnull(cast(@tiBed as varchar),'?') + ' )'

	if	@idRoom is null
		select	@s =	@s + '  SGJ'

	if	@tiBed > 9
		select	@tiBed =	null,	@s =	@s + '  bed'

	if	(@tiBed = 0		or	@tiBed is null)
		and	exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
		select	@tiBed =	0xFF		-- auto-correct for no-bed rooms from bed 0

	if	@idRoom is null		or
		not exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
	begin
		begin tran

			exec	dbo.pr_Log_Ins	82, null, null, @s

			-- bump this patient from his last given room-bed
			update	tbPatient	set		dtUpdated=	getdate( ),	idRoom =	null,	tiBed=	null
				where	idPatient = @idPatient

			update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	null
				where	idPatient = @idPatient

		commit

		return	-1
	end

	begin	tran

		if	@idPatient > 0
		begin
			select	@idCurr =	idRoom,		@tiCurr =	tiBed
				from	tbPatient	with (nolock)
				where	idPatient = @idPatient

			if	@idRoom <> @idCurr	or	@tiBed <> @tiCurr		-- patient has moved?
				or	@idRoom is null	and	@idCurr > 0
				or	@idRoom > 0		and	@idCurr is null
		---		or	@tiBed is null	and	@tiCurr > 0				--	7.05.5147
		---		or	@tiBed > 0		and	@tiCurr is null			-- room-level calls shouldn't move patient
			begin
				-- bump any other patient from the given room-bed
				update	tbPatient	set		dtUpdated=	getdate( ),	idRoom =	null,	tiBed=	null
					where	idRoom = @idRoom	and	tiBed = @tiBed	and	idPatient <> @idPatient

				-- record the given patient into the given room-bed
				update	tbPatient	set		dtUpdated=	getdate( ),	idRoom =	@idRoom,	tiBed=	@tiBed
					where	idPatient = @idPatient

				-- update the given room-bed with the given patient
				update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	@idPatient
					where	idRoom = @idRoom	and	tiBed = @tiBed
			end
		end
		else	-- clear patient
		begin
				-- bump any patient from the given room-bed
				update	tbPatient	set		dtUpdated=	getdate( ),	idRoom =	null,	tiBed=	null
					where	idRoom = @idRoom	and	tiBed = @tiBed	and	idPatient > 0

				-- update the given room-bed with no patient
				update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	null
					where	idRoom = @idRoom	and	tiBed = @tiBed
		end

	commit
end
go
--	----------------------------------------------------------------------------
if	not	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdEvent_Cmd')
--if	exists	(select * from sys.columns where object_id = OBJECT_ID('dbo.tbEvent') and name = 'idCmd' and is_nullable = 0)
begin
	begin tran
		alter table	dbo.tbEvent			add
				constraint	tdEvent_Cmd		default( 0 )	for	idCmd
	--		,	constraint	tdEvent_Len		default( 0 )	for	tiLen
	--		,	constraint	tdEvent_Hash	default( 0 )	for	iHash

		update	dbo.tbEvent		set		idCmd=	0		where	idCmd is null
	--	update	dbo.tbEvent		set		tiLen=	0		where	tiLen is null
	--	update	dbo.tbEvent		set		iHash=	0		where	iHash is null

		alter table	dbo.tbEvent			alter column
			idCmd		tinyint			not null	-- command look-up FK
	--	alter table	dbo.tbEvent			alter column
	--		tiLen		tinyint			not null	-- message length
	--	alter table	dbo.tbEvent			alter column
	--		iHash		int				not null	-- message hash (32-bit) (Murmur2)
	commit
end
go
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent') and name = 'tiFlags')
begin
	begin tran
		alter table	dbo.tbEvent		add
			tiFlags		tinyint			null		-- additional data
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent95')
begin
	begin tran
		update	e	set		e.tiFlags=	case when	e95.tiSvcSet > 0	then	e95.tiSvcSet
											else								e95.tiSvcClr	end
			from	tbEvent		e
			join	tbEvent95	e95	on	e95.idEvent = e.idEvent

		drop table	dbo.tbEvent95
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent98')
begin
	begin tran
		update	e	set		e.tiFlags=	e98.tiMulti
			from	tbEvent		e
			join	tbEvent98	e98	on	e98.idEvent = e.idEvent

		drop table	dbo.tbEvent98
	commit
end
go
--	----------------------------------------------------------------------------
--	System activity log
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
select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, dtEvent, dEvent, tEvent, tiHH
	,	idCmd, tiBtn,	e.idRoom, r.sDevice as sRoom, e.tiBed, b.cBed, e.idUnit
--	,	e.cSrcSys, e.tiSrcGID, e.tiSrcJID, e.tiSrcRID	--, sd.sDial as sSrcDial	--, sd.sQnDevice as sSrcQn, sd.sFnDevice as sSrcFn
	,	e.idSrcDvc, sd.sSGJR as sSrcSGJR, sd.cDevice as cSrcDvc, sd.sDevice as sSrcDvc
--	,	e.cDstSys, e.tiDstGID, e.tiDstJID, e.tiDstRID	--, dd.sDial as sDstDial	--, dd.sQnDevice as sDstQn, dd.sFnDevice as sDstFn
	,	e.idDstDvc, dd.sSGJR as sDstSGJR, dd.cDevice as cDstDvc, dd.sDevice as sDstDvc
	,	e.idLogType, et.sLogType, e.idCall, c.sCall, e.sInfo, e.tiFlags
	from		tbEvent		e	with (nolock)
	left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
	left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
	left join	tb_LogType	et	with (nolock)	on	et.idLogType = e.idLogType
	left join	vwDevice	sd	with (nolock)	on	sd.idDevice = e.idSrcDvc
	left join	vwDevice	dd	with (nolock)	on	dd.idDevice = e.idDstDvc
	left join	tbDevice	r	with (nolock)	on	r.idDevice = e.idRoom
go
--	----------------------------------------------------------------------------
--	7.06.5487	- .tiSeqNum (-> tbEvent.tiBed), - .cStatus (-> tbEvent.tiFlags)
--	<16,tbEvent41>
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'tiSeqNum')
begin
	begin tran
		exec( 'update	e	set		e.tiBed =	e41.tiSeqNum,	e.tiFlags=	ascii(e41.cStatus)
				from	tbEvent		e
				join	tbEvent41	e41	on	e41.idEvent = e.idEvent
			' )
		alter table	dbo.tbEvent41		drop column		tiSeqNum
		alter table	dbo.tbEvent41		drop column		cStatus
	commit
end
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
--	7.06.5528	* @idCall= null, not 0
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

	set	nocount	on

	select	@siIdx =	@siIdx & 0x03FF		-- mask significant bits only [0..1023]
		,	@idCall =	null				-- not in tbCall

	select	@s=	'Call_GI( ' + isnull(cast(@siIdx as varchar), '?') + ':' + isnull(@sCall, '?') + ' )'

	if	@siIdx > 0
	begin
		-- match by priority-index
			select	@idCall =	idCall	from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0

		if	@idCall is null					-- match by call-text
			select	@idCall =	idCall	from	tbCall	with (nolock)	where	sCall = @sCall	and	bActive > 0

		if	@idCall is null
		begin
			begin	tran

				if	len( @sCall ) > 0
					select	@sCall =	sCall	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx

				insert	tbCall		(  siIdx,  sCall )
						values		( @siIdx, @sCall )
				select	@idCall =	scope_identity( )

				select	@s =	@s + '  id=' + cast(@idCall as varchar)
				exec	dbo.pr_Log_Ins	72, null, null, @s
	/*			end
				else
				begin
					select	@s= @s + ' ): call-txt'
					exec	dbo.pr_Log_Ins	82, null, null, @s
				end
	*/
			commit
		end
	end
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, should be called on a schedule every hour
--	7.06.5490	* 'dat:','log:' -> 'D:','L:'
--	7.05.5169	* wipe tbEvent.vbCmd for events older than 60 days
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03	+ reporting DB sizes in tb_Module[1]
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prEvent_Maint
	with encryption
as
begin
	declare	@iSizeDat		int
		,	@iSizeLog		int
		,	@tiPurge		tinyint
		,	@dtNow			smalldatetime

	set	nocount	on

	select	@dtNow =	getdate( )		--	smalldatetime truncates seconds

	select	@iSizeDat=	size/128	from	sys.database_files	with (nolock)	where	file_id = 1		--	type = 0
	select	@iSizeLog=	size/128	from	sys.database_files	with (nolock)	where	file_id = 2		--	type = 1

	update	tb_Module	set	sParams =	'@ ' + @@servicename + ', D:' + cast(@iSizeDat as varchar) + ', L:' + cast(@iSizeLog as varchar)
		where	idModule = 1

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	if	@tiPurge > 0
		exec	prEvent_A_Exp	@tiPurge

	begin tran

		select	@iSizeDat=	iValue	from	tb_OptSys	with (nolock)	where	idOption = 19

		select	@iSizeLog=	idEvent
			from	tbEvent_S
			where	dEvent < dateadd(dd, -60, @dtNow)	and	tiHH = datepart(hh, @dtNow)

		update	tbEvent		set	vbCmd=	null
			where	idEvent between @iSizeDat and @iSizeLog
			and		vbCmd is not null

		update	tb_OptSys	set	iValue =	@iSizeLog,	dtUpdated=	@dtNow	where	idOption = 19

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
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
	declare		@s			varchar( 255 )
		,		@p			varchar( 16 )
		,		@dtEvent	datetime
		,		@tiHH		tinyint
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

	set	nocount	on

	select	@dtEvent =	getdate( ),		@p =	''
		,	@tiHH =		datepart( hh, getdate( ) )
		,	@cDevice =	case when @idCmd = 0x83 then 'G' else '?' end

	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	select	@s =	'Evt_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sSrcDvc,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(cast(@tiDstGID as varchar),'?') + '-' + isnull(cast(@tiDstJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sDstDvc,'?') + '", b=' + isnull(cast(@tiBed as varchar),'?') + ', i="' + isnull(@sInfo,'?') + '" )'

	if	@tiBed = 0xFF
		select	@tiBed =	null
	else
	if	@tiBed > 9
		select	@tiBed =	null,	@p =	@p + '  bed'

	if	@idUnit > 0	and
		not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
--		not exists	(select 1 from tbCfgLoc where idLoc = @idUnit and cLoc = 'U')
		select	@idUnit =	null,	@p =	@p + '  unit'

	begin	tran

		if	@tiBed is not null								-- mark a bed in active use
			update	tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)	-- audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiShelf =	@tiSrcRID,	@sDvc =		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiShelf,	@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

		exec	dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

		if	@idCmd <> 0x84	or	@idLogType <> 194			-- skip healing 84s
		begin
			insert	tbEvent	( idCmd,  tiLen,  iHash,  vbCmd,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit
							,	cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  idSrcDvc
							,	cDstSys,  tiDstGID,  tiDstJID,  tiDstRID,  idDstDvc
							,	dtEvent,  dEvent,   tEvent,   tiHH )
					values	( @idCmd, @tiLen, @iHash, @vbCmd, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit
							,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @idSrcDvc
							,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @idDstDvc
							,	@dtEvent, @dtEvent, @dtEvent, @tiHH )
			select	@idEvent =	scope_identity( )
		end

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

		if	len(@p) > 0
		begin
			select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
			exec	dbo.pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02						-- update tbEvent_A, tbRoom
		begin

			select	@idParent=	idEvent,	@dtParent=	dtEvent		--	7.04.4968
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

			if	@idParent > 0
				update	tbEvent		set	idParent =	@idParent,	idRoom =	@idRoom,	tParent =	dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	tbEvent		set	idParent =	@idEvent,	idRoom =	@idRoom,	tParent =	'0:0:0'
					where	idEvent = @idEvent

			if	@idUnit > 0		and	@idRoom > 0					--	7.02	7.05.5205
				update	tbRoom		set	idUnit =	@idUnit
					where	idRoom = @idRoom
		end

		if	@idEvent > 0									-- update event statistics
		begin
			select	@idParent=	null
			select	@idParent=	idEvent
				from	tbEvent_S	with (nolock)
				where	dEvent = cast(@dtEvent as date)		and	tiHH = @tiHH

			if	@idParent	is null
				insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
						values		( @dtEvent, @tiHH, @idEvent )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@p			varchar( 16 )
		,		@idParent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idCall		smallint
		,		@idCall0	smallint
		,		@siBed		smallint
		,		@siIdxOld	smallint
		,		@siIdxNew	smallint
		,		@idDoctor	int
		,		@idPatient	int
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@dtEvent	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiPurge	tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int

	set	nocount	on

	select	@tiPurge =	cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 7
	select	@iExpNrm =	iValue						from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue						from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null

	select	@s =	'E84_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(@iAID as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(cast(@tiDstGID as varchar),'?') + '-' + isnull(cast(@tiDstJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + '  bed'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed


	if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + '  unit'


	if	@siIdxNew > 0										-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiSpec =	tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew		-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0									-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiSpec =	tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0									-- INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out	-- no need to call


	if	@tiSpec between 7 and 9
		select	@bPresence =	1,	@tiBed =	0xFF		-- mark 'presence' calls and force room-level


	if	@tiBed is not null	and	len(@sPatient) > 0			-- only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
	end


	-- adjust need-timers (0=no need, 1=[G,O,Y] present, 2=need OT, 3=need request)
	if	@tiTmrA > 3		select	@tiTmrA =	3
	if	@tiTmrG > 3		select	@tiTmrG =	3
	if	@tiTmrO > 3		select	@tiTmrO =	3
	if	@tiTmrY > 3		select	@tiTmrY =	3


	-- origin points to the first still active event that started call-sequence for this SGJRB
	select	@idOrigin=	idEvent,	@dtOrigin=	dtEvent,	@bAudio =	bAudio
		from	tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0
			and	(idCall = @idCall	or	idCall = @idCall0)		--	7.05.4976

	select	@tiSvc =	@tiTmrA * 0x40 + @tiTmrG * 0x10 + @tiTmrO * 0x04 + @tiTmrY
		,	@idLogType =	case when	@idOrigin is null	then							-- call placed
									case when	@bPresence > 0	then 206	else 191 end
								when	@siIdxNew = 0		then							-- cancelled
									case when	@bPresence > 0	then 207	else 193 end
								else														-- escalated or healing
									case when	@idCall0 > 0	then 192	else 194 end	end

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

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

			if	len(@p) > 0
			begin
				select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

		exec	dbo.prRoom_UpdStaff		@idRoom, @idUnit, @sStaffG, @sStaffO, @sStaffY


		if	@idOrigin is null								-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss, @siElapsed, '0:0:0')
								,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent)
								,	@idSrcDvc=	idSrcDvc,	@idParent=	idParent
				where	idEvent = @idEvent

			insert	tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
									siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,
									tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
									@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, @tiSvc, dateadd(ss, @iExpNrm, @dtEvent),
									@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

			if	@idRoom > 0		and							-- 'medical' call or 'presence'		--	7.05.5212
				(@tiShelf > 0	and	( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 )
				or	@bPresence > 0)
				begin
					select	@idUser =	case
								when @tiSpec = 7	then idUserG
								when @tiSpec = 8	then idUserO
								when @tiSpec = 9	then idUserY
								else					 null	end
						from	tbRoom	with (nolock)
						where	idRoom = @idRoom

					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idRoom,  idUnit,  tiBed,  siBed, idUser1, tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idRoom, @idUnit, @tiBed, @siBed, @idUser, datepart(hh, @dtOrigin) )

					update	c	set	c.idUser1=	rb.idUser1,		c.idUser2=	rb.idUser2,		c.idUser3=	rb.idUser3	--	7.06.5326
						from	tbEvent_C	c
						join	tbRoomBed	rb	on	rb.idRoom = @idRoom		and	( rb.tiBed = @tiBed		or	@tiBed is null	and	( rb.tiBed = 0xFF	or	rb.tiBed = 1 ) )
						where	c.idEvent = @idEvent
				end

			select	@idOrigin=	@idEvent
		end

		else												-- active origin found	(=> call healed/escalated/cancelled)
		begin
			update	tbEvent		set	idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin
				where	idEvent = @idEvent

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	idCall =	@idCall
				where	idEvent = @idOrigin					--	7.05.5065

			update	tbEvent_A	set	tiSvc=	@tiSvc			-- update state for all calls in this room
				where	idRoom = @idRoom					--	7.06.5534
		end


		if	@siIdxNew = 0									-- call cancelled
		begin
	--		select	@dtOrigin=	case when @bAudio = 0 then dateadd(ss, @iExpNrm, @dtEvent)
	--												else dateadd(ss, @iExpExt, @dtEvent) end

			update	tbEvent_A	set	dtExpires=	case when @bAudio = 0 then dateadd(ss, @iExpNrm, @dtEvent)
																	else dateadd(ss, @iExpExt, @dtEvent) end	--@dtOrigin
							,	tiSvc=	null,	bActive =	0
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

			select	@dtOrigin=	tOrigin,	@idParent=	idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent

			update	tbEvent_C	set	idEvtSt =	@idEvent,	tStaff =	@dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null		-- there should be only one, but just in case - use only 1st one
		end


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


		---	!! @idEvent no longer points to current event !!

		-- set tbRoom.idEvent and .tiSvc to highest oldest active call for this room
		select	@idEvent =	null,	@tiSvc =	null
		select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent							-- oldest in recorded order
		---	order	by	siIdx desc, tElapsed desc					-- call may have started before it was recorded

		update	tbRoom	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
			where	idRoom = @idRoom

		-- clear room state when there's no 'presence'		--	7.06.5534
		if	@tiSvc is null	or	@tiSvc & 0x30 <> 0x10
			update	tbRoom	set	idUserG= null, sStaffG= null	where	idRoom = @idRoom
		if	@tiSvc is null	or	@tiSvc & 0x0C <> 0x04
			update	tbRoom	set	idUserO= null, sStaffO= null	where	idRoom = @idRoom
		if	@tiSvc is null	or	@tiSvc & 0x03 <> 0x01
			update	tbRoom	set	idUserY= null, sStaffY= null	where	idRoom = @idRoom


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
				order	by	siIdx desc, idEvent							-- oldest in recorded order
			---	order	by	siIdx desc, tElapsed desc					-- call may have started before it was recorded

			update	tbRoomBed	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
				where	idRoom = @idRoom	and	tiBed = @tiBed

			fetch next from	cur	into	@tiBed
		end
		close	cur
		deallocate	cur

	commit

	select	@idEvent =	@idOrigin			--	7.05.5267	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
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
,	@tiSrcJAB	tinyint				-- source J audio-bus?
,	@tiSrcLAB	tinyint				-- source L audio-bus?
,	@tiDstJAB	tinyint				-- destination J audio-bus?
,	@tiDstLAB	tinyint				-- destination L audio-bus?
,	@sSrcDvc	varchar( 16 )		-- source name
,	@sDstDvc	varchar( 16 )		-- destination name
,	@tiBed		tinyint				-- bed index
--,	@cBed		char( 1 )			-- bed name
,	@siIdx		smallint			-- call-priority
--,	@siPri		smallint			-- call-priority
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
--		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
--		,		@cBed		char( 1 )
		,		@iExpNrm	int
		,		@idLogType	tinyint

	set	nocount	on

---	if	@tiBed > 9	--	= 255	or	@tiBed = 0
---		select	@tiBed= null	--, @cBed= null
--	else
--		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	select	@idLogType =	case when	@idCmd = 0x8D	then	199			-- audio quit
								when	@idCmd = 0x8A	then	197			-- audio grant
								when	@idCmd = 0x88	then	196			-- audio busy
								else							195	end		-- audio request
---		,	@siIdx=	@siPri & 0x03FF


--	if	@siIdx > 0
--		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
--	else
--		select	@idCall =	0			--	INTERCOM call
--	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call
	exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed	---	, @iAID, @tiStype, @idCall0

---		insert	tbEvent8A	(  idEvent,  tiSrcJAB,  tiSrcLAB,  tiDstJAB,  tiDstLAB,  siPri,  tiFlags,  siIdx )
---				values		( @idEvent, @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB, @siPri, @tiFlags, @siIdx )
--	-	insert	tbEvent8A	(  idEvent,  tiSrcJAB,  tiSrcLAB,  tiDstJAB,  tiDstLAB,  siIdx )
--	-			values		( @idEvent, @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB, @siIdx )

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
--	Inserts event [0x95]
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
--,	@siPri		smallint			-- call index
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
--		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
	--	,		@cBed		char( 1 )

	set	nocount	on

--	if	@tiBed > 9	--	= 255	or	@tiBed = 0
--		select	@cBed= null, @tiBed= null
--	else
--		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

--	select	@idLogType =	case when	@tiSvcSet > 0  and  @tiSvcClr = 0	then	201		-- set svc
--								when	@tiSvcSet = 0  and  @tiSvcClr > 0	then	203		-- clr svc
	select	@idLogType =	case when	@tiSvcSet > 0	then	201			-- set svc
--								when	@tiSvcClr > 0	then	203			-- clr svc
								else							203	end		-- clr svc	202	-- set/clr
--		,	@siIdx=	@siPri & 0x03FF

--	if	@siIdx > 0
--		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
--	else
--		select	@idCall= 0				--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call
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

	select	@idEvent =	@idOrigin		--	7.05.52??	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x98, 0x9A, 0x9E, 0x9C, 0xA4, 0xAD, 0xAF]
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
,	@cGender	char( 1 )
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
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint

	set	nocount	on

	if	len(@sPatient) > 0
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
	else
	if	len(@sDoctor) > 0
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
		---		,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

--		insert	tbEvent98	( idEvent,  tiMulti,  idPatient,  idDoctor )	--, tiFlags
--				values		( @idEvent, @tiMulti, @idPatient, @idDoctor )	--, @tiFlags

		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.06.5484

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
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
	declare		@s			varchar( 255 )
		,		@idEvent	int
		,		@idCall		smallint
		,		@idUnit		smallint
		,		@idRoom		smallint
--		,		@sCall		varchar( 16 )
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idUser		int
		,		@idLogType	tinyint

	set	nocount	on

	select	@s =	'E41_I( ' + isnull(cast(@idEvent as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sSrcDvc,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
			--		', r=' + isnull(cast(@idRoom as varchar),'?') +
					', b=' + isnull(cast(@tiBed as varchar),'?') + ', d=' + isnull(cast(@idDvc as varchar),'?') +
					', k=' + isnull(cast(@idPcsType as varchar),'?') + ', t=' + isnull(cast(@idDvcType as varchar),'?') + ', #' + isnull(@sDial,'?') +
					', <' + isnull(cast(@tiSeqNum as varchar),'?') + '> ' + isnull(@cStatus,'?') + ', i="' + isnull(@sInfo,'?') + '" )'

--	select	@siIdx=	@siIdx & 0x03FF
--
--	if	@siIdx > 0
--	begin
--		select	@sCall= sCall	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx
--		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
--	end
--	else
--		select	@idCall= 0				--	INTERCOM call
--	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call
	exec	dbo.prCall_GetIns	@siIdx, null, @idCall out		--	@sCall

	if	@idDvc is null
		select	@idDvc= idDvc
			from	tbDvc	with (nolock)
			where	@idDvcType = @idDvcType		and	sDial = @sDial	and	bActive > 0

	select	@idLogType =	82,		@idUser =	null
	select	@idLogType =	case when	idDvcType = 4	then	204			-- phone
								when	idDvcType = 2	then	205			-- pager
								else							82	end
		,	@idUser= idUser
		from	tbDvc	with (nolock)
		where	idDvc = @idDvc

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	null, null, null, null, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed		---	, @iAID, @tiStype, @idCall0

		update	tbEvent		set	tiDstRID =	@tiSeqNum,	tiFlags =	ascii(@cStatus)
			where	idEvent = @idEvent

		if	@idDvc > 0
--			insert	tbEvent41	(  idEvent,  idPcsType,  idDvc,  idUser,  tiSeqNum,  cStatus )
--					values		( @idEvent, @idPcsType, @idDvc, @idUser, @tiSeqNum, @cStatus )
			insert	tbEvent41	(  idEvent,  idPcsType,  idDvc,  idUser )
					values		( @idEvent, @idPcsType, @idDvc, @idUser )
		else
			exec	dbo.pr_Log_Ins	82, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5487	- .tiSeqNum (-> tbEvent.tiDstRID), - .cStatus (-> tbEvent.tiFlags)
--	7.05.5212	* left join vwStaff
--	7.05.5095
alter view		dbo.vwEvent41
	with encryption
as
select	e41.idEvent, e.dtEvent, e.idCmd, e.cSrcSys, e.tiSrcGID, e.tiSrcJID	--, e.tiSrcRID,	e.tiBtn
	,	e.idParent	--, e.idOrigin
	,	r.idDevice, r.sSGJ, r.sDevice,	e.tiBed, b.cBed
	,	e.idCall, c.sCall, c.siIdx
	,	e41.idDvc, d.idDvcType, d.sDvcType, d.sDial, d.sDvc, e41.idPcsType, t.sPcsType, e.tiDstRID, char(e.tiFlags) as cRPP, e.sInfo
	,	e41.idUser, u.sStfLvl, u.sStaffID, u.sStaff
	from	tbEvent41	e41	with (nolock)
	join	tbEvent		e	with (nolock)	on	e.idEvent = e41.idEvent
	join	tbPcsType	t	with (nolock)	on	t.idPcsType = e41.idPcsType
	join	vwDevice	r	with (nolock)	on	r.bActive > 0	and	r.cSys = e.cSrcSys	and	r.tiGID = e.tiSrcGID	and	r.tiJID = e.tiSrcJID	and	r.tiRID = 0	--h.tiSrcRID
	join	tbCall		c	with (nolock)	on	c.idCall = e.idCall	--c.bActive > 0	and
	join	vwDvc		d	with (nolock)	on	d.idDvc = e41.idDvc	--c.bActive > 0	and
	left join	vwStaff	u	with (nolock)	on	u.idUser = e41.idUser
	left join	tbCfgBed b	with (nolock)	on	b.tiBed = e.tiBed
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventB1')
	drop table	dbo.tbEventB1
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEventAB')
	drop table	dbo.tbEventAB
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent9B')
	drop table	dbo.tbEvent9B
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent99')
	drop table	dbo.tbEvent99
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent8C')
	drop table	dbo.tbEvent8C
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent8A')
	drop table	dbo.tbEvent8A
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent86')
	drop table	dbo.tbEvent86
go
--	----------------------------------------------------------------------------
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

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	select	@sSvc8 =	' STAT',	@sNull =	''
	select	@sSvc4 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	set	nocount	off

	if	@tiDvc = 0xFF
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
			,	e.idCmd,	e.tiBtn, e.sRoom, b.cBed,	e.idLogType		--, k.sCmd, e.sLogType, e.idRoom, e.tiBed
--			,	e.idCall, case when e41.idEvent > 0	then cast(e41.idPcsType as smallint) else c.siIdx end	as	siIdx,	cp.tiSpec
			,	e.idCall, c.siIdx,	cp.tiSpec
			,	e.tiFlags	as	tiSvc
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case	when e41.idEvent > 0	then pt.sPcsType
						when e.idLogType > 0	then e.sLogType		else k.sCmd		end +
				case	when e.idCmd = 0x95		then	-- ' ' +
					case	when e.tiFlags & 0x08 > 0	then @sSvc8		else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4		else @sNull		end +
						case	when e.tiFlags & 0x02 > 0	then @sSvc2		else @sNull		end +
						case	when e.tiFlags & 0x01 > 0	then @sSvc1		else @sNull		end		end
					else @sNull		end		as	sEvent
			,	case	when e41.idEvent > 0	then nd.sFqDvc		else e.sDstDvc	end		as	sDstDvc
			,	case	when c.tiSpec between 7 and 9	then u1.sFqStaff	else e.sInfo	end		as	sInfo
			,	case	when e41.idEvent > 0	then
							case	when nd.tiFlags & 0x01 > 0	then 'Group/Team'	else du.sFqStaff	end
						when e.idCmd > 0		then e.sCall		else k.sCmd		end		as	sCall
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
	--	-	join		tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
			left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u1	with (nolock)	on	u1.idUser = ec.idUser1
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwStaff		du	with (nolock)	on	du.idUser = e41.idUser
			left join	vwDvc		nd	with (nolock)	on	nd.idDvc = e41.idDvc
			where	e.idEvent	between @iFrom	and @iUpto
			and		e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else if	@tiDvc = 1
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
			,	e.idCmd,	e.tiBtn, e.sRoom, b.cBed,	e.idLogType		--, k.sCmd, e.sLogType, e.idRoom, e.tiBed
--			,	e.idCall, case when e41.idEvent > 0	then cast(e41.idPcsType as smallint) else c.siIdx end	as	siIdx,	cp.tiSpec
			,	e.idCall, c.siIdx,	cp.tiSpec
			,	e.tiFlags	as	tiSvc
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case	when e41.idEvent > 0	then pt.sPcsType
						when e.idLogType > 0	then e.sLogType		else k.sCmd		end +
				case	when e.idCmd = 0x95		then	-- ' ' +
					case	when e.tiFlags & 0x08 > 0	then @sSvc8		else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4		else @sNull		end +
						case	when e.tiFlags & 0x02 > 0	then @sSvc2		else @sNull		end +
						case	when e.tiFlags & 0x01 > 0	then @sSvc1		else @sNull		end		end
					else @sNull		end		as	sEvent
			,	case	when e41.idEvent > 0	then nd.sFqDvc		else e.sDstDvc	end		as	sDstDvc
			,	case	when c.tiSpec between 7 and 9	then u1.sFqStaff	else e.sInfo	end		as	sInfo
			,	case	when e41.idEvent > 0	then
							case	when nd.tiFlags & 0x01 > 0	then 'Group/Team'	else du.sFqStaff	end
						when e.idCmd > 0		then e.sCall		else k.sCmd		end		as	sCall
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			join		tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
			left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u1	with (nolock)	on	u1.idUser = ec.idUser1
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwStaff		du	with (nolock)	on	du.idUser = e41.idUser
			left join	vwDvc		nd	with (nolock)	on	nd.idDvc = e41.idDvc
			where	e.idEvent	between @iFrom	and @iUpto
			and		e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
			,	e.idCmd,	e.tiBtn, e.sRoom, b.cBed,	e.idLogType		--, k.sCmd, e.sLogType, e.idRoom, e.tiBed
--			,	e.idCall, case when e41.idEvent > 0	then cast(e41.idPcsType as smallint) else c.siIdx end	as	siIdx,	cp.tiSpec
			,	e.idCall, c.siIdx,	cp.tiSpec
			,	e.tiFlags	as	tiSvc
			,	e.idSrcDvc, e.sSrcSGJR, e.cSrcDvc, e.sSrcDvc
			,	e.idDstDvc, e.sDstSGJR, e.cDstDvc
			,	case	when e41.idEvent > 0	then pt.sPcsType
						when e.idLogType > 0	then e.sLogType		else k.sCmd		end +
				case	when e.idCmd = 0x95		then	-- ' ' +
					case	when e.tiFlags & 0x08 > 0	then @sSvc8		else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4		else @sNull		end +
						case	when e.tiFlags & 0x02 > 0	then @sSvc2		else @sNull		end +
						case	when e.tiFlags & 0x01 > 0	then @sSvc1		else @sNull		end		end
					else @sNull		end		as	sEvent
			,	case	when e41.idEvent > 0	then nd.sFqDvc		else e.sDstDvc	end		as	sDstDvc
			,	case	when c.tiSpec between 7 and 9	then u1.sFqStaff	else e.sInfo	end		as	sInfo
			,	case	when e41.idEvent > 0	then
							case	when nd.tiFlags & 0x01 > 0	then 'Group/Team'	else du.sFqStaff	end
						when e.idCmd > 0		then e.sCall		else k.sCmd		end		as	sCall
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd = e.idCmd
			left join	tb_SessDvc	d	with (nolock)	on	d.idDevice = e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed = e.tiBed
			left join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
			left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent = e.idEvent
			left join	vwStaff		u1	with (nolock)	on	u1.idUser = ec.idUser1
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
			left join	vwStaff		du	with (nolock)	on	du.idUser = e41.idUser
			left join	vwDvc		nd	with (nolock)	on	nd.idDvc = e41.idDvc
			where	e.idEvent	between @iFrom	and @iUpto
			and		e.tiHH		between @tFrom	and @tUpto
	--	-	and		(e.idSrcDvc in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcDvc is null)		-- is left join not enough??
			order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
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

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered,

		idRoom		smallint,
		cBed		char( 1 ),
		cDevice		char( 1 ),
		sDevice		varchar( 16 ),
		sDial		varchar( 16 ),
		idUser1		int,
	)

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	select	@sSvc8 =	'STAT',		@sNull =	''
	select	@sSvc4 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	if	@tiDvc = 0xFF
		insert	#tbRpt1
			select	ec.idEvent, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0
	else
		insert	#tbRpt1
			select	ec.idEvent, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0

	set	nocount	off

	select	ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, e.idParent, e.tParent, e.idOrigin
		,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin,	ec.cBed, e.tiBed, e.idLogType	--, e.idCall
		,	case	when e41.idEvent > 0	then pt.sPcsType	else lt.sLogType	end		as	sEvent
		,	c.siIdx, cp.tiSpec,		e.tiFlags	as	tiSvc
		,	case	when e.idLogType between 195 and 199	then '[' + e.cDstDvc + '] ' + e.sDstDvc		-- audio
					when e41.idEvent > 0	then nd.sFqDvc
					when e.idCmd = 0x95		then
						case	when e.tiFlags & 0x08 > 0	then @sSvc8		else
							case	when e.tiFlags & 0x04 > 0	then @sSvc4		else @sNull		end +
							case	when e.tiFlags & 0x02 > 0	then @sSvc2		else @sNull		end +
							case	when e.tiFlags & 0x01 > 0	then @sSvc1		else @sNull		end		end
					end		as	sDvcSvc
		,	case	when e41.idEvent > 0	then
						case	when nd.tiFlags & 0x01 > 0	then 'Group/Team'	else du.sFqStaff	end
					else c.sCall	end		as	sCall
		,	case	when c.tiSpec between 7 and 9	then u1.sFqStaff	else e.sInfo	end		as	sInfo
		,	d.sDoctor, p.sPatient
		from	#tbRpt1		ec	with (nolock)
		join	vwEvent		e	with (nolock)	on	e.idParent = ec.idEvent
		join	tb_LogType	lt	with (nolock)	on	lt.idLogType = e.idLogType
		join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
		left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
		left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
		left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
		left join	vwDvc		nd	with (nolock)	on	nd.idDvc = e41.idDvc
		left join	vwStaff		du	with (nolock)	on	du.idUser = e41.idUser
		left join	vwStaff		u1	with (nolock)	on	u1.idUser = ec.idUser1
		left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
		left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
		left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
		where	e.idEvent	between @iFrom	and @iUpto
		and		e.tiHH		between @tFrom	and @tUpto
		order	by	ec.sDevice, ec.idEvent, e.idEvent
end
go
--	----------------------------------------------------------------------------
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
,	@tiShift	tinyint				-- 0xFF=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 0xFF=any, 1=specific (tb_SessUser), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
			--		join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
			--		join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
			--		join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,		a.dtCreated, a.dtUpdated
					from	tbStfAssn		a	with (nolock)
					join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
					join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
					join	tb_SessUser		st	with (nolock)	on	st.idUser = a.idUser	and	st.idSess = @idSess
					join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
					join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
					join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
					join	vwStaff			s	with (nolock)	on	s.idUser = a.idUser
					left join	tbCfgBed	b	with (nolock)	on	b.tiBed = a.tiBed
					where	a.bActive > 0
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
end
go
--	----------------------------------------------------------------------------
--	7.06.5491	* [1,2,9,A,D,E]
begin tran
	update	dbo.tbPcsType	set	sPcsType =	'Ring (PCS)'	where	idPcsType = 0x01
	update	dbo.tbPcsType	set	sPcsType =	'Stop Ring'		where	idPcsType = 0x02
	update	dbo.tbPcsType	set	sPcsType =	'Page (RPP)'	where	idPcsType = 0x09
	update	dbo.tbPcsType	set	sPcsType =	'Alert (PCS)'	where	idPcsType = 0x0A
	update	dbo.tbPcsType	set	sPcsType =	'Busy (PCS)'	where	idPcsType = 0x0D
	update	dbo.tbPcsType	set	sPcsType =	'Abort (PCS)'	where	idPcsType = 0x0E
commit
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
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
	@idUser		int					-- user, performing the action
,	@idOper		int			out		-- operand user, acted upon
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
,	@sTeams		varchar( 255 )
,	@sRoles		varchar( 255 )
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

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	-- enforce membership in 'Public' role
	if	not exists	(select 1 from #tbRole with (nolock) where idRole = 1)
		insert	#tbRole		(idRole)	values	( 1 )

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", i="' + isnull(cast(@sStaffID as varchar), '?') + '", l=' + isnull(cast(@idStfLvl as varchar), '?') +
				', b="' + isnull(cast(@sBarCode as varchar), '?') + '", on=' + isnull(cast(@bOnDuty as varchar), '?') +
				', a=' + cast(@bActive as varchar)
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff		--,  dtLastAct
							,  sStaffID,  idStfLvl,  sBarCode,  sUnits,  sTeams,  bOnDuty,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '		--, @dtLastAct, @sStaff
							, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @sTeams, @bOnDuty, @bActive )
			select	@idOper =	scope_identity( )

			select	@s =	'User_I( ' + @s + ' ) = ' + cast(@idOper as varchar)
				,	@k =	237
		end
		else
		begin
			update	tb_User	set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
								,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc	--, dtLastAct= @dtLastAct, sStaff= @sStaff
								,	sStaffID =	@sStaffID,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode
								,	sUnits =	@sUnits,	sTeams =	@sTeams,	bOnDuty =	@bOnDuty
								,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'User_U( ' + @s + ' )'
				,	@k =	238
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s

		delete	from	tb_UserUnit
			where	idUser = @idOper
			and		idUnit not in (select	idUnit	from	#tbUnit	with (nolock))

		insert	tb_UserUnit	( idUnit, idUser )
			select	idUnit, @idOper
				from	#tbUnit	with (nolock)
				where	idUnit not in (select	idUnit	from	tb_UserUnit	with (nolock)	where	idUser = @idOper)

		delete	from	tbTeamUser
			where	idUser = @idOper
			and		idTeam not in (select	idTeam	from	#tbTeam	with (nolock))

		insert	tbTeamUser	( idTeam, idUser )
			select	idTeam, @idOper
				from	#tbTeam	with (nolock)
				where	idTeam not in (select	idTeam	from	tbTeamUser	with (nolock)	where	idUser = @idOper)

		delete	from	tb_UserRole
			where	idUser = @idOper
			and		idRole not in (select	idRole	from	#tbRole	with (nolock))

		insert	tb_UserRole	( idRole, idUser )
			select	idRole, @idOper
				from	#tbRole	with (nolock)
				where	idRole not in (select	idRole	from	tb_UserRole	with (nolock)	where	idUser = @idOper)

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
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
		from	tbUnitMap	um	with (nolock)
		left join	(select	idUnit, tiMap, count(*) as iCells
						from	tbUnitMapCell	with (nolock)
						where	idRoom is not null
						group	by	idUnit, tiMap)	mc	on	mc.idUnit = um.idUnit	and	mc.tiMap = um.tiMap
		where	um.idUnit = @idUnit
end
go
--	----------------------------------------------------------------------------
--	7.06.5501	+ .sPath	()
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgLoc') and name = 'sPath')
begin
	begin tran
		alter table	dbo.tbCfgLoc	add
			sPath		varchar( 32 )	null		-- node path ([idParent.]idLoc) - for tree-ordered reads
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
--	7.06.5501	+ .sPath,	- @cLoc
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	7.00	* format idLoc as '000'
--	6.05
alter proc		dbo.prCfgLoc_Ins
(
	@idLoc		smallint			-- call-index
,	@idParent	smallint			-- parent look-up FK
,	@tiLvl		tinyint				-- level: 0=Facility 1=System 2=Building 3=Floor 4=Unit 5=CoverageArea
--,	@cLoc		char( 1 )			-- type:  H=Hospital S=System B=Building F=Floor U=Unit C=CoverageArea
,	@sLoc		varchar( 16 )		-- location name
)
	with encryption
as
begin
	declare		@iTrace		int
			,	@s			varchar( 255 )

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		insert	tbCfgLoc	(  idLoc,  idParent,  tiLvl,  cLoc,  sLoc, sPath )
				values		( @idLoc, @idParent, @tiLvl, '?', @sLoc, '' )

		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', p=' + isnull(cast(@idParent as varchar), '?') +
--						', l=' + isnull(cast(@tiLvl as varchar), '?') + ', c=' + isnull(@cLoc, '?') + ', n=' + isnull(@sLoc, '?') + ' )'
						', l=' + isnull(cast(@tiLvl as varchar), '?') + ', n=' + isnull(@sLoc, '?') + ' )'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
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
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@sUnit		varchar( 16 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		-- update codes, levels and paths following parent-child relationship
		update	tbCfgLoc	set	sPath =	'0',	cLoc =	'H'
			where	idLoc = 0
		select	@iCount =	@@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'S',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'B',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'F',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'U',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		update	l	set	l.tiLvl =	p.tiLvl + 1,	l.cLoc =	'C',	l.sPath =	p.sPath + '.' + cast(l.idLoc as varchar)
			from	tbCfgLoc l
			join	tbCfgLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 0xFF
			where	l.tiLvl = 0xFF
		select	@iCount =	@iCount + @@rowcount

		if	@iTrace & 0x01 > 0
		begin
			select	@s= 'Loc_SL( ) ' + cast(@iCount as varchar) + ' rows'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		-- deactivate non-matching units
		update	u	set	u.bActive=	0,	u.dtUpdated=	getdate( )
			from	tbUnit	u
			left join 	tbCfgLoc	l	on l.idLoc = u.idUnit
			where	u.bActive = 1	and	l.idLoc is null

		-- deactivate shifts for inactive units
		update	s	set	s.bActive=	0,	s.dtUpdated=	getdate( )
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
			-- upsert tbUnit to match tbCfgLoc
			if	exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
				update	tbUnit	set	bActive =	1,	sUnit=	@sUnit,		dtUpdated=	getdate( )
					where	idUnit = @idUnit
			else
			begin
				insert	tbUnit	(  idUnit,  sUnit, tiShifts, idShift )
						values	( @idUnit, @sUnit, 1, 0 )
				insert	tb_RoleUnit	( idRole, idUnit )
						values		( 2, @idUnit )
				insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )			--	default to single 24hr-shift
						values	( @idUnit, 1, 'Shift 1', '07:00:00', '07:00:00' )
				select	@idShift =	scope_identity( )

				update	tbUnit	set	idShift= @idShift
					where	idUnit = @idUnit
			end

			-- populate tbUnitMap
			if	not	exists	(select 1 from tbUnitMap where idUnit = @idUnit)
			begin
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, 'Map 1' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, 'Map 2' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, 'Map 3' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, 'Map 4' )
			end

			-- populate tbUnitMapCell
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
--	Returns all locations, ordered to be loadable into a tree
--	7.06.5504	+ .sPath
--	7.04.4892	* tbDefLoc -> tbCfgLoc
alter proc		dbo.prCfgLoc_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLoc, idParent, cLoc, sLoc, tiLvl, sPath
		,	case when tiLvl = 0	then 'Facility'
				when tiLvl = 1	then 'System'
				when tiLvl = 2	then 'Building'
				when tiLvl = 3	then 'Floor'
				when tiLvl = 4	then 'Unit'
				when tiLvl = 5	then 'Cvrg Area'	end	as sLvl
		,	cast(1 as bit)	as bActive,		dtCreated
		from	tbCfgLoc	with (nolock)
		order	by	sPath
end
go
--	----------------------------------------------------------------------------
update	dbo.tbFilter
	set	xFilter =	cast(replace(cast(xFilter as varchar(max)), ' u="24"/>', ' u="23"/>') as xml)
go
--	----------------------------------------------------------------------------
--	7.06.5526	+ [27]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 27)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 27,  56, 'Sign-On reset interval (in seconds)' )		--	7.06.5526
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 27, 20 )
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 28,  56, 'Sign-On dbl-scan clears assignment?' )		--	7.06.5526
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 28, 1 )
	end
commit
go
--	----------------------------------------------------------------------------
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
)
	with encryption
as
begin
	declare		@iFrom		int
		,		@iUpto		int
		,		@tiHH		tinyint

	set	nocount	on

	create table	#tbRpt1
	(
		idCall		smallint,
	--	sCall		varchar(16),
		iWDay		tinyint,
		tiHH		tinyint,

		lCount		int,
	--	tVoAvg		time(3),
	--	tVoTop		time(3),
		lVoOnT		int,
	--	lVoOut		int,
		lVoNul		int,
	--	tStAvg		time(3),
	--	tStTop		time(3),
		lStOnT		int,
	--	lStOut		int,
		lStNul		int,

		primary key nonclustered (idCall, iWday, tiHH)
	)
	create table	#tbRpt2
	(
		idCall		smallint,
	--	sCall		varchar(16),
		tiHH		tinyint,

		lCount1		int,
	--	tVoAvg		time(3),
	--	tVoTop		time(3),
		lVoOnT1		int,
	--	lVoOut1		int,
		lVoNul1		int,
	--	tStAvg		time(3),
	--	tStTop		time(3),
		lStOnT1		int,
	--	lStOut1		int,
		lStNul1		int,

		lCount2		int,		lVoOnT2		int,		lVoNul2		int,		lStOnT2		int,		lStNul2		int,
		lCount3		int,		lVoOnT3		int,		lVoNul3		int,		lStOnT3		int,		lStNul3		int,
		lCount4		int,		lVoOnT4		int,		lVoNul4		int,		lStOnT4		int,		lStNul4		int,
		lCount5		int,		lVoOnT5		int,		lVoNul5		int,		lStOnT5		int,		lStNul5		int,
		lCount6		int,		lVoOnT6		int,		lVoNul6		int,		lStOnT6		int,		lStNul6		int,
		lCount7		int,		lVoOnT7		int,		lVoNul7		int,		lStOnT7		int,		lStNul7		int,

		primary key nonclustered (idCall, tiHH)
	)

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		insert	#tbRpt1
			select	ec.idCall, datepart(dw,ec.dEvent), ec.tiHH, count(*)
		--		,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )
		--		,	max(ec.tVoice)
				,	sum(case when ec.tVoice < sc.tVoTrg then 1 else 0 end)
		--		,	sum(case when ec.tVoice > sc.tVoMax then 1 else 0 end)
				,	sum(case when ec.tVoice is null then 1 else 0 end)
		--		,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )
		--		,	max(ec.tStaff)
				,	sum(case when ec.tStaff < sc.tStTrg then 1 else 0 end)
		--		,	sum(case when ec.tStaff > sc.tStMax then 1 else 0 end)
				,	sum(case when ec.tStaff is null then 1 else 0 end)
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0
				and		(cp.tiSpec	is null		or	cp.tiSpec	not	between 7 and 9)
				group	by ec.idCall, datepart(dw,ec.dEvent), ec.tiHH
	else
		insert	#tbRpt1
			select	ec.idCall, datepart(dw,ec.dEvent), ec.tiHH, count(*)
		--		,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )
		--		,	max(ec.tVoice)
				,	sum(case when ec.tVoice < sc.tVoTrg then 1 else 0 end)
		--		,	sum(case when ec.tVoice > sc.tVoMax then 1 else 0 end)
				,	sum(case when ec.tVoice is null then 1 else 0 end)
		--		,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )
		--		,	max(ec.tStaff)
				,	sum(case when ec.tStaff < sc.tStTrg then 1 else 0 end)
		--		,	sum(case when ec.tStaff > sc.tStMax then 1 else 0 end)
				,	sum(case when ec.tStaff is null then 1 else 0 end)
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0
				and		(cp.tiSpec	is null		or	cp.tiSpec	not	between 7 and 9)
				group	by ec.idCall, datepart(dw,ec.dEvent), ec.tiHH

--	select	*	from	#tbRpt1

	set		@tiHH=	@tFrom
	if	@tUpto >= 24	set		@tUpto=	23
	while	@tiHH <= @tUpto
	begin
		insert	#tbRpt2 ( idCall, tiHH )
			select	distinct idCall, @tiHH
				from	#tbRpt1		with (nolock)
		set		@tiHH= @tiHH + 1
	end	

--	select	*	from	#tbRpt2

	update	a
		set	a.lCount1= b.lCount1, a.lVoOnT1= b.lVoOnT1, a.lVoNul1= b.lVoNul1, a.lStOnT1= b.lStOnT1, a.lStNul1= b.lStNul1,
			a.lCount2= b.lCount2, a.lVoOnT2= b.lVoOnT2, a.lVoNul2= b.lVoNul2, a.lStOnT2= b.lStOnT2, a.lStNul2= b.lStNul2,
			a.lCount3= b.lCount3, a.lVoOnT3= b.lVoOnT3, a.lVoNul3= b.lVoNul3, a.lStOnT3= b.lStOnT3, a.lStNul3= b.lStNul3,
			a.lCount4= b.lCount4, a.lVoOnT4= b.lVoOnT4, a.lVoNul4= b.lVoNul4, a.lStOnT4= b.lStOnT4, a.lStNul4= b.lStNul4,
			a.lCount5= b.lCount5, a.lVoOnT5= b.lVoOnT5, a.lVoNul5= b.lVoNul5, a.lStOnT5= b.lStOnT5, a.lStNul5= b.lStNul5,
			a.lCount6= b.lCount6, a.lVoOnT6= b.lVoOnT6, a.lVoNul6= b.lVoNul6, a.lStOnT6= b.lStOnT6, a.lStNul6= b.lStNul6,
			a.lCount7= b.lCount7, a.lVoOnT7= b.lVoOnT7, a.lVoNul7= b.lVoNul7, a.lStOnT7= b.lStOnT7, a.lStNul7= b.lStNul7
		from	#tbRpt2	a	with (nolock)
		join	(select	idCall, tiHH,	-- min(sCall),
					sum(case when iWDay=1 then lCount end) lCount1,
					sum(case when iWDay=1 then lVoOnT end) lVoOnT1,		sum(case when iWDay=1 then lVoNul end) lVoNul1,
					sum(case when iWDay=1 then lStOnT end) lStOnT1,		sum(case when iWDay=1 then lStNul end) lStNul1,
		--			sum(case when iWDay=1 then lVoOut end),
		--			sum(case when iWDay=1 then lStOut end),

					sum(case when iWDay=2 then lCount end) lCount2,
					sum(case when iWDay=2 then lVoOnT end) lVoOnT2,		sum(case when iWDay=2 then lVoNul end) lVoNul2,
					sum(case when iWDay=2 then lStOnT end) lStOnT2,		sum(case when iWDay=2 then lStNul end) lStNul2,

					sum(case when iWDay=3 then lCount end) lCount3,
					sum(case when iWDay=3 then lVoOnT end) lVoOnT3,		sum(case when iWDay=3 then lVoNul end) lVoNul3,
					sum(case when iWDay=3 then lStOnT end) lStOnT3,		sum(case when iWDay=3 then lStNul end) lStNul3,

					sum(case when iWDay=4 then lCount end) lCount4,
					sum(case when iWDay=4 then lVoOnT end) lVoOnT4,		sum(case when iWDay=4 then lVoNul end) lVoNul4,
					sum(case when iWDay=4 then lStOnT end) lStOnT4,		sum(case when iWDay=4 then lStNul end) lStNul4,

					sum(case when iWDay=5 then lCount end) lCount5,
					sum(case when iWDay=5 then lVoOnT end) lVoOnT5,		sum(case when iWDay=5 then lVoNul end) lVoNul5,
					sum(case when iWDay=5 then lStOnT end) lStOnT5,		sum(case when iWDay=5 then lStNul end) lStNul5,

					sum(case when iWDay=6 then lCount end) lCount6,
					sum(case when iWDay=6 then lVoOnT end) lVoOnT6,		sum(case when iWDay=6 then lVoNul end) lVoNul6,
					sum(case when iWDay=6 then lStOnT end) lStOnT6,		sum(case when iWDay=6 then lStNul end) lStNul6,

					sum(case when iWDay=7 then lCount end) lCount7,
					sum(case when iWDay=7 then lVoOnT end) lVoOnT7,		sum(case when iWDay=7 then lVoNul end) lVoNul7,
					sum(case when iWDay=7 then lStOnT end) lStOnT7,		sum(case when iWDay=7 then lStNul end) lStNul7
				from	#tbRpt1		with (nolock)
				group	by idCall, tiHH
				)	b	on	b.idCall = a.idCall	and	b.tiHH = a.tiHH

	set	nocount	off

	select	t.*, sc.siIdx, sc.sCall, sc.tVoTrg, sc.tStTrg	--, f.tVoMax, f.tStMax
		,	dateadd(hh, t.tiHH, '0:0:0')	[tHour]
		,	case when t.lVoNul1 = t.lCount1 then null else t.lVoOnT1*100/(t.lCount1-t.lVoNul1) end	[fVoOnT1]	--,	lVoOnT1*100/lCount1 fVoOnT1
		,	case when t.lStNul1 = t.lCount1 then null else t.lStOnT1*100/(t.lCount1-t.lStNul1) end	[fStOnT1]	--,	lStOnT1*100/lCount1 fStOnT1
		,	case when t.lVoNul2 = t.lCount2 then null else t.lVoOnT2*100/(t.lCount2-t.lVoNul2) end	[fVoOnT2]	--,	lVoOnT2*100/lCount2 fVoOnT2
		,	case when t.lStNul2 = t.lCount2 then null else t.lStOnT2*100/(t.lCount2-t.lStNul2) end	[fStOnT2]	--,	lStOnT2*100/lCount2 fStOnT2
		,	case when t.lVoNul3 = t.lCount3 then null else t.lVoOnT3*100/(t.lCount3-t.lVoNul3) end	[fVoOnT3]	--,	lVoOnT3*100/lCount3 fVoOnT3
		,	case when t.lStNul3 = t.lCount3 then null else t.lStOnT3*100/(t.lCount3-t.lStNul3) end	[fStOnT3]	--,	lStOnT3*100/lCount3 fStOnT3
		,	case when t.lVoNul4 = t.lCount4 then null else t.lVoOnT4*100/(t.lCount4-t.lVoNul4) end	[fVoOnT4]	--,	lVoOnT4*100/lCount4 fVoOnT4
		,	case when t.lStNul4 = t.lCount4 then null else t.lStOnT4*100/(t.lCount4-t.lStNul4) end	[fStOnT4]	--,	lStOnT4*100/lCount4 fStOnT4
		,	case when t.lVoNul5 = t.lCount5 then null else t.lVoOnT5*100/(t.lCount5-t.lVoNul5) end	[fVoOnT5]	--,	lVoOnT5*100/lCount5 fVoOnT5
		,	case when t.lStNul5 = t.lCount5 then null else t.lStOnT5*100/(t.lCount5-t.lStNul5) end	[fStOnT5]	--,	lStOnT5*100/lCount5 fStOnT5
		,	case when t.lVoNul6 = t.lCount6 then null else t.lVoOnT6*100/(t.lCount6-t.lVoNul6) end	[fVoOnT6]	--,	lVoOnT6*100/lCount6 fVoOnT6
		,	case when t.lStNul6 = t.lCount6 then null else t.lStOnT6*100/(t.lCount6-t.lStNul6) end	[fStOnT6]	--,	lStOnT6*100/lCount6 fStOnT6
		,	case when t.lVoNul7 = t.lCount7 then null else t.lVoOnT7*100/(t.lCount7-t.lVoNul7) end	[fVoOnT7]	--,	lVoOnT7*100/lCount7 fVoOnT7
		,	case when t.lStNul7 = t.lCount7 then null else t.lStOnT7*100/(t.lCount7-t.lStNul7) end	[fStOnT7]	--,	lStOnT7*100/lCount7 fStOnT7
	--	,	lVoOut*100/lCount 'fVoOut', lStOut*100/lCount 'fStOut'
		from	#tbRpt2		t	with (nolock)
		join	tb_SessCall sc	with (nolock)	on	sc.idCall = t.idCall	and	sc.idSess = @idSess
		order by	sc.siIdx desc, t.tiHH
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 5536 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5536, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated= '2015-02-27', dtInstall= getdate( )
		,	sVersion =	'-86,8A,8C,95,98,99,9B,AB,B1, +validation, *AppSuite, *7983rh, *7983ss, *7980ps, *7980cw, *7980rh, *7981ls, *7982cw, *7985cw, *7986cw, *7970as'
		where	siBuild = 5536

	update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.6.5536'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.5536 )'
commit
go

checkpoint
go

use [master]
go
