--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
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
--						* tbDvcType[3] -> [4] (phone) for bitwise filters, etc.
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
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

--if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 5373 order by idVersion desc)
if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 5396 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.5396', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_GetAll')
	drop proc	dbo.pr_Module_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStfAssnStaff')
	drop proc	dbo.prRptStfAssnStaff
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_RoleUnit_Imp')
	drop proc	dbo.pr_RoleUnit_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_RoleUnit_Exp')
	drop proc	dbo.pr_RoleUnit_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_Imp')
	drop proc	dbo.pr_UserRole_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_UserRole_Exp')
	drop proc	dbo.pr_UserRole_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_Imp')
	drop proc	dbo.pr_Role_Imp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_Exp')
	drop proc	dbo.pr_Role_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_SetTmpFlt')
	drop proc	dbo.prCfgPri_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCall_SetTmpFlt')
	drop proc	dbo.prCall_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRole_SetTmpFlt')
	drop proc	dbo.prRole_SetTmpFlt
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prEvent_A_Get')
	drop proc	dbo.prEvent_A_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetDvcs')
	drop proc	dbo.prTeam_GetDvcs
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetDvcs')
	drop proc	dbo.pr_User_GetDvcs
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetBySID')
	drop proc	dbo.pr_User_GetBySID
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetStaffOnDuty')
	drop proc	dbo.prTeam_GetStaffOnDuty
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTeam_GetByUnitPri')
	drop proc	dbo.prTeam_GetByUnitPri
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCallActExc')
	drop proc	dbo.prRptCallActExc
go
--	----------------------------------------------------------------------------
--	7.06.5326	+ .idAssn1|2|3
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'idAssn1')
begin
	begin tran
		alter table		dbo.tbEvent_C	add
			idAssn1		int				null		-- live: assignee 1
				constraint	fkEventC_Assn1		foreign key references	tb_User
		,	idAssn2		int				null		-- live: assignee 2
				constraint	fkEventC_Assn2		foreign key references	tb_User
		,	idAssn3		int				null		-- live: assignee 3
				constraint	fkEventC_Assn3		foreign key references	tb_User
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5330	+ .siBed
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgBed') and name = 'siBed')
begin
	begin tran
		alter table		dbo.tbCfgBed	add
			siBed		smallint		null		-- bed-flag (bit index)

		exec( '
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
		' )

		alter table		dbo.tbCfgBed	alter column
			siBed		smallint		not null	-- bed-flag (bit index)
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5330	+ .siBed
--	<64,tbEvent_C>
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'siBed')
begin
	begin tran
		alter table		dbo.tbEvent_C	add
			siBed		smallint		null		-- bed-flag (bit index)

		exec( '
		update	ec	set	siBed=	b.siBed
			from	tbEvent_C	ec
			join	tbCfgBed	b	on	b.tiBed = ec.tiBed
		update	ec	set	siBed=	0xFFFF
			from	tbEvent_C	ec
			where	tiBed is null
		' )

		alter table		dbo.tbEvent_C	alter column
			siBed		smallint		not null	-- bed-flag (bit index)
	commit
end
go
--	----------------------------------------------------------------------------
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
	,	d.sDevice + case when ec.tiBed is null then '' else ':' + cb.cBed end	[sRoomBed]
	,	ec.idEvtVo, ec.tVoice,	ec.idEvtSt, ec.tStaff,	ec.idUser, s.sStaff
	,	ec.idAssn1, a1.sStaff	[sAssn1]
	,	ec.idAssn2, a2.sStaff	[sAssn2]
	,	ec.idAssn3, a3.sStaff	[sAssn3]
	from		tbEvent_C	ec	with (nolock)
	join		tbCall		c	with (nolock)	on	c.idCall = ec.idCall
	join		tbUnit		u	with (nolock)	on	u.idUnit = ec.idUnit
	join		tbDevice	d	with (nolock)	on	d.idDevice = ec.idRoom
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ec.tiBed
	left join	tb_User		s	with (nolock)	on	s.idUser = ec.idUser
	left join	tb_User		a1	with (nolock)	on	a1.idUser = ec.idAssn1
	left join	tb_User		a2	with (nolock)	on	a2.idUser = ec.idAssn2
	left join	tb_User		a3	with (nolock)	on	a3.idUser = ec.idAssn3
go
--	----------------------------------------------------------------------------
--	7.06.5329	+ [9]
if	not	exists	(select 1 from dbo.tbReport where idReport = 9)
begin
	begin tran
		update	dbo.tbReport	set	siOrder= 30		where	idReport = 3
		update	dbo.tbReport	set	siOrder= 40		where	idReport = 4
		update	dbo.tbReport	set	siOrder= 50		where	idReport = 5
		update	dbo.tbReport	set	siOrder= 60		where	idReport = 6
		update	dbo.tbReport	set	siOrder= 80		where	idReport = 7
		update	dbo.tbReport	set	siOrder= 90		where	idReport = 8

		insert	dbo.tbReport ( idReport, siOrder, sClass, sReport, sRptName )
					values	(  9,  70, 'xrCallActExc',	'Call Activity (Exceptions)',	'Patient Activity Exceptions' )	--	7.06.5329
	commit
end
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
--,	@cBed		char( 1 )			-- 0=any/none, >0 =specific
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 0xFF
--		if	@cBed is null
		if	@siBeds = 0xFFFF
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
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
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
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
--				and		(ec.cBed = @cBed	or	ec.cBed is null)
				and		ec.siBed & @siBeds <> 0
				order	by	ec.sDevice, ec.idEvent
	else
--		if	@cBed is null
		if	@siBeds = 0xFFFF
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
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
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
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
--				and		(ec.cBed = @cBed	or	ec.cBed is null)
				and		ec.siBed & @siBeds <> 0
				order	by	ec.sDevice, ec.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.5331	* @cBed -> @siBeds
--	7.05.5304	+ .siIdx, .tiSpec, .tiSvc
--	7.05.5203	+ 'e.idEvent between @idFrom and @idUpto' and 'e.tiHH between @tFrom and @tUpto'
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
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
--,	@cBed		char( 1 )			-- null=any/none, >0 =specific
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int,

		idRoom		smallint,
		cBed		char(1),
		cDevice		char(1),
		sDevice		varchar(16),
		sDial		varchar(16),
		idUser		int,

		primary key nonclustered (idEvent)
	)

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

--	set	nocount	off
	if	@tiDvc = 0xFF
		if	@siBeds = 0xFFFF
			insert	#tbRpt1
				select	ec.idEvent, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @idFrom	and @idUpto
					and		ec.tiHH		between @tFrom	and @tUpto
		else
			insert	#tbRpt1
				select	ec.idEvent, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @idFrom	and @idUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
	else
		if	@siBeds = 0xFFFF
			insert	#tbRpt1
				select	ec.idEvent, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @idFrom	and @idUpto
					and		ec.tiHH		between @tFrom	and @tUpto
		else
			insert	#tbRpt1
				select	ec.idEvent, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @idFrom	and @idUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0

	set	nocount	off
	select	ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, e.idParent, e.tParent, e.idOrigin
		,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin	--, e.idCall
		,	ec.cBed, e.tiBed, e.idLogType, lt.sLogType
		,	c.siIdx, cp.tiSpec, e95.tiSvcSet | e95.tiSvcClr		[tiSvc]
		,	case when e8A.idEvent > 0 then '[' + e.cDstDvc + '] ' + e.sDstDvc
				when e41.idEvent > 0 then pd.sFqDvc
				when e95.idEvent > 0 then
					case when e95.tiSvcSet & 8 > 0 or e95.tiSvcClr & 8 > 0 then 'STAT' else
					case when e95.tiSvcSet & 4 > 0 or e95.tiSvcClr & 4 > 0 then 'Grn ' else '' end +
					case when e95.tiSvcSet & 2 > 0 or e95.tiSvcClr & 2 > 0 then 'Ora ' else '' end +
					case when e95.tiSvcSet & 1 > 0 or e95.tiSvcClr & 1 > 0 then 'Yel ' else '' end end
				end		[sEvent]
		,	case when e41.idEvent > 0 then u.sFqStaff else c.sCall end		[sCall]
		,	case when e41.idEvent > 0 and e41.idPcsType <> 0x09 then pt.sPcsType else
				case when ec.idUser > 0 then u2.sFqStaff else e.sInfo end end	[sInfo]
		,	d.sDoctor, p.sPatient
		from	#tbRpt1		ec	with (nolock)
--		join	tbEvent		e	with (nolock)	on	e.idParent = s.idEvent
		join	vwEvent		e	with (nolock)	on	e.idParent = ec.idEvent
		join	tb_LogType	lt	with (nolock)	on	lt.idLogType = e.idLogType
		left join	tbCall		c	with (nolock)	on	c.idCall = e.idCall
		left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
		left join	tbEvent41	e41	with (nolock)	on	e41.idEvent = e.idEvent
		left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType = e41.idPcsType
		left join	vwDvc		pd	with (nolock)	on	pd.idDvc = e41.idDvc
		left join	vwStaff		u	with (nolock)	on	u.idUser = e41.idUser
		left join	vwStaff		u2	with (nolock)	on	u2.idUser = ec.idUser
		left join	tbEvent84	e84	with (nolock)	on	e84.idEvent = e.idEvent
		left join	tbPatient	p	with (nolock)	on	p.idPatient = e84.idPatient
		left join	tbDoctor	d	with (nolock)	on	d.idDoctor = e84.idDoctor
		left join	tbEvent8A	e8A	with (nolock)	on	e8A.idEvent = e.idEvent
		left join	tbEvent95	e95	with (nolock)	on	e95.idEvent = e.idEvent
		where	e.idEvent	between @idFrom	and @idUpto
		and		e.tiHH		between @tFrom	and @tUpto
		order	by	ec.sDevice, ec.idEvent, e.idEvent

end
go
--	----------------------------------------------------------------------------
--	Imports a staff assignment definition
--	7.06.5332	* fix check @idStfAssn > 0 -> @@rowcount
--	7.05.5248	+ dup check (xuStfAssn_Active_RoomBedShiftIdx)
--	7.05.5087	+ trace output
--	7.05.5074
alter proc		dbo.prStfAssn_Imp
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

	select	@s=	'SA_Imp( cS=' + isnull(cast(@cSys as varchar),'?') +
				', tiG=' + isnull(cast(@tiGID as varchar),'?') + ', tiJ=' + isnull(cast(@tiJID as varchar),'?') +
				', idU=' + isnull(cast(@idUnit as varchar),'?') + ', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') +
				', sSt=' + @sStaffID + ' ) idRm=' + isnull(cast(@idRoom as varchar),'?') +
				' idSh=' + isnull(cast(@idShift as varchar),'?') + ' idSt=' + isnull(cast(@idUser as varchar),'?')

	begin	tran

		if	@idRoom is null		or	@idShift is null	or	@idUser is null
			exec	pr_Log_Ins	47, null, null, @s
		else
		begin
			if	exists	(select 1 from tbStfAssn with (nolock) where idStfAssn = @idStfAssn)
				update	tbStfAssn	set	idRoom= @idRoom, tiBed= @tiBed, idShift= @idShift, tiIdx= @tiIdx
									,	idUser= @idUser, bActive= @bActive, dtCreated= @dtCreated, dtUpdated= @dtUpdated
					where	idStfAssn = @idStfAssn
			else
			begin
				set identity_insert	dbo.tbStfAssn	on

				insert	tbStfAssn	(  idStfAssn,  idRoom,  tiBed,  idShift,  tiIdx,  idUser,  bActive,  dtCreated,  dtUpdated )
						values		( @idStfAssn, @idRoom, @tiBed, @idShift, @tiIdx, @idUser, @bActive, @dtCreated, @dtUpdated )

				set identity_insert	dbo.tbStfAssn	off
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5333	* [3] -> [4] (phone) for bitwise filters, etc.
begin tran
	if	not	exists	(select 1 from dbo.tbDvcType where idDvcType = 4)
	begin
		insert	dbo.tbDvcType ( idDvcType, sDvcType )	values	(  4, 'Phone' )

		update	dbo.tbDvc	set	idDvcType= 4	where	idDvcType = 3

		delete	from	dbo.tbDvcType	where	idDvcType = 3
	end
commit
go
--	----------------------------------------------------------------------------
--	7.06.5344	* [43,45]
--	7.06.5333	* [47,49]
begin tran
	update	dbo.tb_LogType	set	sLogType= '790 data error'		where	idLogType = 43
	update	dbo.tb_LogType	set	sLogType= 'HL7 data error'		where	idLogType = 45
	update	dbo.tb_LogType	set	sLogType= '7980 data error'		where	idLogType = 47
	update	dbo.tb_LogType	set	sLogType= 'RTLS data error'		where	idLogType = 49
commit
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
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
select	r.idUnit,	rb.idRoom, r.sDevice [sRoom], r.sQnDevice, d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, rb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	p.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idAssn1, a1.idStfLvl [idStLvl1], a1.sStaffID [sAssnID1], a1.sStaff [sAssn1], a1.bOnDuty [bOnDuty1]		--, a1.sStaffLvl [sStLvl1], a1.iColorB [iColorB1]
	,	rb.idAssn2, a2.idStfLvl [idStLvl2], a2.sStaffID [sAssnID2], a2.sStaff [sAssn2], a2.bOnDuty [bOnDuty2]		--, a2.sStaffLvl [sStLvl2], a2.iColorB [iColorB2]
	,	rb.idAssn3, a3.idStfLvl [idStLvl3], a3.sStaffID [sAssnID3], a3.sStaff [sAssn3], a3.bOnDuty [bOnDuty3]		--, a3.sStaffLvl [sStLvl3], a3.iColorB [iColorB3]
	,	r.idReg4, r.sReg4,	r.idReg2, r.sReg2,	r.idReg1, r.sReg1
	,	rb.dtUpdated
	from	tbRoomBed	rb	with (nolock)
	join	tbDevice	d	with (nolock)	on	d.idDevice = rb.idRoom		and	d.bActive > 0
	join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
---	left join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0
	left join	tbPatient	p	with (nolock)	on	p.idRoom = rb.idRoom		and	p.tiBed = rb.tiBed	--	p.idPatient = rb.idPatient
	left join	tbDoctor	dc	with (nolock)	on	dc.idDoctor = p.idDoctor
	left join	vwStaff		a1	with (nolock)	on	a1.idUser = rb.idAssn1
	left join	vwStaff		a2	with (nolock)	on	a2.idUser = rb.idAssn2
	left join	vwStaff		a3	with (nolock)	on	a3.idUser = rb.idAssn3
go
--	----------------------------------------------------------------------------
--	Returns on-duty pageable staff for given unit(s)
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
	select	st.idUser, sStaffID, sStaff
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
--	Returns available staff for given unit(s)
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
--	Returns devices filtered by unit, type and active status
--	7.06.5336	* @idDvcType is bitwise now
--	7.05.5189	+ .idRoom, sQnRoom
--	7.05.5186	+ .tiFlags & 0x01 = 0
--	7.05.5184	+ .sTeams
--	7.05.5179	* 0xFF
--	7.05.5176
alter proc		dbo.prDvc_GetByUnit
(
	@idUnit		smallint			-- null=any?
--,	@idDvcType	tinyint				-- null=any, 1=Badge, 2=Pager, 3=Phone, 0xFF=NoBadges
,	@idDvcType	tinyint				-- 1=Badge, 2=Pager, 4=Phone, 0xFF=any
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
,	@bGroup		bit			= null	-- null=any, 0=no, 1=yes
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, d.sDial, tiFlags, sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rr.idRoom, r.sQnDevice	[sQnRoom]
		,	idUser, d.idStfLvl, sStaffID, sStaff,	bOnDuty
		from		vwDvc		d	with (nolock)
		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rr.idRoom
---		where	(@idDvcType is null	or	idDvcType = @idDvcType	or	 @idDvcType = 0xFF  and	idDvcType > 1)
		where	idDvcType & @idDvcType	<> 0
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bGroup is null	or	tiFlags & 0x01 = @bGroup)
		and		(@idUnit is null	or	idDvcType = 1	or	idDvc in (select idDvc	from	tbDvcUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
begin tran
	update	dbo.tb_OptSys	set	iValue= 10	where	idOption = 2	and	iValue < 10		--	login lock-out
	update	dbo.tb_OptSys	set	iValue= 2	where	idOption = 20	and	iValue <> 0		--	cancellations
commit
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
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
		,	r.idDevice [idRoom], r.sDevice [sRoom], ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
		,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
		,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
		,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
		,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
		,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
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

	select	idAssn1, idStLvl1, sAssn1
		,	idAssn2, idStLvl2, sAssn2
		,	idAssn3, idStLvl3, sAssn3
		from	vwRoomBed	with (nolock)
		where	idRoom = @idRoom
		and		(tiBed = @tiBed		or	@tiBed = 0xFF	and	tiBed = 1)
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985
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
,	@idMaster	smallint			-- master console, null=global mode
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
			,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
			,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
			,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
			,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
			,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
			,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
			,	cast(null as tinyint) [tiMap]
	--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
			from	vwEvent_A		ea	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = ea.idUnit
	--			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )			--	7.03
				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
			,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
			,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
			,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
			,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
			,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
			,	cast(null as tinyint) [tiMap]
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
			,	rb.idAssn1, rb.idStLvl1, rb.sAssnID1, rb.sAssn1, rb.bOnDuty1
			,	rb.idAssn2, rb.idStLvl2, rb.sAssnID2, rb.sAssn2, rb.bOnDuty2
			,	rb.idAssn3, rb.idStLvl3, rb.sAssnID3, rb.sAssn3, rb.bOnDuty3
			,	r.idReg4, r.idRegLvl4, r.sRegID4, r.sReg4, r.bRegDuty4
			,	r.idReg2, r.idRegLvl2, r.sRegID2, r.sReg2, r.bRegDuty2
			,	r.idReg1, r.idRegLvl1, r.sRegID1, r.sReg1, r.bRegDuty1
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
--	Returns teams responding to a given priority in a given unit
--	7.06.5347
create proc		dbo.prTeam_GetByUnitPri
(
	@idUnit		smallint			-- not null
,	@siIdx		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idTeam, sTeam, tResp, sDesc, sCalls, sUnits, bActive, dtCreated, dtUpdated
		from	tbTeam	with (nolock)
		where	bActive > 0
		and		idTeam in (select idTeam	from	tbTeamUnit	with (nolock)	where	idUnit = @idUnit)
		and		idTeam in (select idTeam	from	tbTeamPri	with (nolock)	where	siIdx = @siIdx)
	--	order	by	idTeam
end
go
grant	execute				on dbo.prTeam_GetByUnitPri			to [rWriter]
grant	execute				on dbo.prTeam_GetByUnitPri			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns current active members on-duty
--	7.06.5347
create proc		dbo.prTeam_GetStaffOnDuty
(
	@idTeam		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaffID, sStaff, bOnDuty
		from	tb_User		with (nolock)
		where	bActive > 0		and	bOnDuty > 0
		and		idUser in (select idUser	from	tbTeamUser	with (nolock)	where	idTeam = @idTeam)
	--	order	by	idUser
end
go
grant	execute				on dbo.prTeam_GetStaffOnDuty		to [rWriter]
grant	execute				on dbo.prTeam_GetStaffOnDuty		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns staff member by the given StaffID
--	7.06.5347
create proc		dbo.pr_User_GetBySID
(
	@sStaffID	varchar( 16 )		-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idStfLvl, sStaffID, sStaff, bOnDuty
		from	tb_User		with (nolock)
		where	sStaffID = @sStaffID
	--	order	by	idUser
end
go
grant	execute				on dbo.pr_User_GetBySID				to [rWriter]
grant	execute				on dbo.pr_User_GetBySID				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active notification devices (pagers and phones), assigned to a given user
--	7.06.5347
create proc		dbo.pr_User_GetDvcs
(
	@idUser		int					-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sDial, tiFlags
		from	tbDvc	with (nolock)
		where	bActive > 0		and idDvcType > 1
		and		idUser = @idUser
	--	order	by	idUser
end
go
grant	execute				on dbo.pr_User_GetDvcs				to [rWriter]
grant	execute				on dbo.pr_User_GetDvcs				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active group notification devices (pagers only), assigned to a given team
--	7.06.5347
create proc		dbo.prTeam_GetDvcs
(
	@idTeam		smallint			-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idDvc, idDvcType, sDvc, sDial, tiFlags
		from	tbDvc	with (nolock)
		where	bActive > 0		and idDvcType > 1
		and		idDvc in (select idDvc	from	tbDvcTeam	with (nolock)	where	idTeam = @idTeam)
	--	order	by	idUser
end
go
grant	execute				on dbo.prTeam_GetDvcs				to [rWriter]
grant	execute				on dbo.prTeam_GetDvcs				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5371	* tbPcsType[0x02..0x07,0x0A,0x0B]
--	7.06.5351	+ tbPcsType[0x0C..0x0E]
begin tran
	if	not	exists	(select 1 from dbo.tbPcsType where idPcsType = 0x0C)
	begin
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x0C, 'Duplicate' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x0D, 'Busy' )
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x0E, 'Abort' )
	end

	update	dbo.tbPcsType	set	sPcsType= 'Stop'			where idPcsType = 0x02
	update	dbo.tbPcsType	set	sPcsType= 'Success'			where idPcsType = 0x03
	update	dbo.tbPcsType	set	sPcsType= 'In PBX session'	where idPcsType = 0x04
	update	dbo.tbPcsType	set	sPcsType= 'In OAI session'	where idPcsType = 0x05
	update	dbo.tbPcsType	set	sPcsType= 'Inactive'		where idPcsType = 0x06
	update	dbo.tbPcsType	set	sPcsType= 'Terminated'		where idPcsType = 0x07
	update	dbo.tbPcsType	set	sPcsType= 'Alert'			where idPcsType = 0x0A
	update	dbo.tbPcsType	set	sPcsType= 'Expired'			where idPcsType = 0x0B
commit
go
--	----------------------------------------------------------------------------
--	Returns notifiable active call properties
--	7.06.5393	- where tiShelf > 0
--	7.06.5352
create proc		dbo.prEvent_A_Get
(
	@idEvent	int					-- not null
)
	with encryption
as
begin
--	set	nocount	on
	select	idEvent, dtEvent, cSys, tiGID, tiJID, tiRID, tiBtn, idRoom, sRoom, tiBed, cBed, idUnit, siIdx, sCall, tiShelf, tiSpec, bActive, bAnswered, tElapsed	--, tiSvc
		from	vwEvent_A	with (nolock)
		where	(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
		and		(idEvent = @idEvent	or	@idEvent is null)
end
go
grant	execute				on dbo.prEvent_A_Get				to [rWriter]
grant	execute				on dbo.prEvent_A_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	Deactivates all devices, resets room state
--	7.06.5352	+ 'and tiStype is not null' - don't deactivate SIP devices
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03.4862
alter proc		dbo.prCfgDvc_Init
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
--	Inserts or updates a bed definition
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
--	Returns all receivers
--	7.06.5354	+ order by
--	7.04.4959	+ .sFqDevice
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	7.04.4892	* .idDevice -> .idRoom
--	7.03.4890
alter proc		dbo.prRtlsRcvr_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idReceiver, sReceiver, idRoom, sFqDevice	--, sRcvrType
		,	bActive, dtCreated, dtUpdated
--		,	case when bActive > 0 then 'Yes' else 'No' end [sActive]
		from	vwRtlsRcvr	with (nolock)
		order	by	idReceiver
end
go
--	----------------------------------------------------------------------------
--	Returns all badges
--	7.06.5354	+ order by
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
			,	idRoom, sSGJ + ' [' + cDevice + '] ' + sDevice		[sCurrLoc]
			,	dtEntered, cast(getdate( )-dtEntered as time(0))	[tDuration]
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge	with (nolock)
			where	( @bRoom = 0	or	idRoom is not null )
			and		idUser is not null
			order	by	sFqStaff, idBadge
	else
		select	idBadge,	idUser, sFqStaff
			,	idRoom, sSGJ + ' [' + cDevice + '] ' + sDevice		[sCurrLoc]
			,	dtEntered, cast(getdate( )-dtEntered as time(0))	[tDuration]
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge	with (nolock)
			where	( @bRoom = 0	or	idRoom is not null )
			order	by	idBadge
end
go
--	----------------------------------------------------------------------------
--	Returns all staff assignments for given unit/shift
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
--	----------------------------------------------------------------------------
--	7.06.5371	+ [62,02], AssnTeams->[62,03]
begin tran
	if	not	exists	(select 1 from dbo.tb_Feature where idModule = 62 and idFeature = 3)
	begin
		update	dbo.tb_Feature	set	sFeature= 'Assign - Badges'		where	idModule = 62 and idFeature = 2
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	03,	'Assign - Teams' )

		update	dbo.tb_Access	set	idFeature= 3	where	idModule = 62 and idFeature = 2
	end
commit
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
--	7.06.5373	+ p.tiSpec, p.tiShelf
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
		select	c.idCall, c.bEnabled, c.siIdx, c.sCall, c.tVoTrg, c.tStTrg, p.iColorF, p.iColorB, p.tiSpec, p.tiShelf, c.bActive, c.dtCreated, c.dtUpdated
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on	p.sCall = c.sCall	and p.siIdx = c.siIdx
			where	c.bActive > 0
			and		p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)		--	"medical" calls
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.siIdx	desc
	else
		select	c.idCall, c.bEnabled, c.siIdx, c.sCall, c.tVoTrg, c.tStTrg, p.iColorF, p.iColorB, p.tiSpec, p.tiShelf, c.bActive, c.dtCreated, c.dtUpdated
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on	p.sCall = c.sCall	and p.siIdx = c.siIdx
			where	c.bActive > 0
		--	and		p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.siIdx	desc
end
go
--	----------------------------------------------------------------------------
--	7.06.5379	* xp_Version(idVersion) -> xp_Version(siBuild)
--				+ xu_Version
if	not exists	(select 1 from dbo.sysindexes where name='xu_Version')
begin
	begin tran
		alter table	dbo.tb_Version	drop	constraint	xp_Version

		alter table	dbo.tb_Version	add
			constraint	xp_Version		primary key clustered ( siBuild )

		create unique nonclustered index	xu_Version	on	dbo.tb_Version ( idVersion, siBuild )
	commit
end
go
--	----------------------------------------------------------------------------
--	[Creates] #tbRole and fills it with given idRole-s
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
		idRole		smallint		not null	-- role look-up FK
--	,	sRole		varchar( 16 )	not null	-- role name

		primary key nonclustered ( idRole )
	)
*/
	if	@sRoles = ''	or	@sRoles is null
		return	0

	if	@sRoles = '*'	--	or	@sRoles = ''	or	@sRoles is null
	begin
		insert	#tbRole
			select	idRole	--, sRole
				from	tb_Role	with (nolock)
				where	bActive > 0
	end
	else
	begin
		select	@s=
		'insert	#tbRole
			select	idRole	--, sRole
				from	tb_Role	with (nolock)
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
--	[Creates] #tbUnit and fills it with given idUnit-s
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
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)
*/
	if	@sUnits = ''	or	@sUnits is null
		return	0

	if	@sUnits = '*'	--	or	@sUnits = ''	or	@sUnits is null
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
--	----------------------------------------------------------------------------
--	[Creates] #tbTeam and fills it with given idTeam-s
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
		idTeam		smallint		not null	-- team id
--	,	sTeam		varchar( 16 )	not null	-- team name

		primary key nonclustered ( idTeam )
	)
*/
	if	@sTeams = ''	or	@sTeams is null
		return	0

	if	@sTeams = '*'	--	or	@sTeams = ''	or	@sTeams is null
	begin
		insert	#tbTeam
			select	idTeam	--, sTeam
				from	tbTeam	with (nolock)
				where	bActive > 0		--	enabled only
	end
	else
	begin
		select	@s=
		'insert	#tbTeam
			select	idTeam	--, sTeam
				from	tbTeam	with (nolock)
				where	bActive > 0		--	enabled only
				and		idTeam in (' + @sTeams + ')'
		exec( @s )
	end
--	select	*	from	#tbCall
end
go
--	----------------------------------------------------------------------------
--	[Creates] #tbCall and fills it with given siIdx-s
--	7.06.5380	+ "or	@sRoles = ''"
--				* prCfgPri_SetTmpFlt -> prCall_SetTmpFlt
--	7.05.5179
create proc		dbo.prCall_SetTmpFlt
(
	@sCalls		varchar( 255 )		-- comma-separated siIdx-s, '*'=all or null
)
	with encryption
as
begin
	declare		@s			varchar( 400 )

	set	nocount on

/*	create table	#tbCall						-- no enforcement of FKs
	(
		siIdx		smallint		not null	-- priority-index
--	,	sCall		varchar( 16 )	not null	-- priority-text

		primary key nonclustered ( siIdx )
	)
*/
	if	@sCalls = ''	or	@sCalls is null
		return	0

	if	@sCalls = '*'	--	or	@sCalls = ''	or	@sCalls is null
	begin
		insert	#tbCall
			select	siIdx	--, sCall
				from	tbCfgPri	with (nolock)
				where	tiFlags & 0x02 > 0		--	enabled only
	end
	else
	begin
		select	@s=
		'insert	#tbCall
			select	siIdx	--, sCall
				from	tbCfgPri	with (nolock)
				where	tiFlags & 0x02 > 0		--	enabled only
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
--	Inserts or updates a team
--	7.06.5380	* prCfgPri_SetTmpFlt -> prCall_SetTmpFlt
--	7.05.5191	* fix tbTeamUnit insertion
--	7.05.5182	+ .sUnits, .sCalls
--	7.05.5021
alter proc		dbo.prTeam_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idTeam		smallint out		-- team, acted upon
,	@sTeam		varchar( 16 )
,	@tResp		time( 0 )
,	@sDesc		varchar( 255 )
,	@sCalls		varchar( 255 )
,	@sUnits		varchar( 255 )
,	@bActive	bit
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

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

	select	@s= '[' + isnull(cast(@idTeam as varchar), '?') + '], n="' + @sTeam + '", d=' + isnull(cast(@sDesc as varchar), '?') +
				', t=' + convert(varchar, @tResp, 108) +
				', a=' + cast(@bActive as varchar)		-- + ' ' + convert(varchar, @dtCreated, 20) + ' ' + convert(varchar, @dtUpdated, 20)
	begin	tran

		if	not exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			select	@s= 'Team_I( ' + @s + ' ) = '

			insert	tbTeam	(  sTeam,  sDesc,  tResp,  sCalls,  sUnits,  bActive )
					values	( @sTeam, @sDesc, @tResp, @sCalls, @sUnits, @bActive )
			select	@idTeam=	scope_identity( )

			select	@s= @s + cast(@idTeam as varchar)
				,	@k=	247
		end
		else
		begin
			select	@s= 'Team_U( ' + @s + ' )'

			update	tbTeam	set	sTeam= @sTeam, sDesc= @sDesc, tResp= @tResp, sCalls= @sCalls, sUnits= @sUnits, bActive= @bActive, dtUpdated= getdate( )
				where	idTeam = @idTeam

			select	@k=	248
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

		delete	from	tbTeamPri
			where	idTeam = @idTeam
			and		siIdx not in (select	siIdx	from	#tbCall	with (nolock))

		insert	tbTeamPri	( siIdx, idTeam )
			select	siIdx, @idTeam
				from	#tbCall	with (nolock)
				where	siIdx not in (select	siIdx	from	tbTeamPri	where	idTeam = @idTeam)

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
--	Updates patient's room-bed
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

	select	@sPatient= sPatient
		from	tbPatient	with (nolock)
		where	idPatient = @idPatient

	select	@idRoom= idDevice,	@sDevice= sDevice
		from	vwRoom	with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	bActive > 0		--	and	tiRID = @tiRID

	if	(@tiBed = 0	or	@tiBed is null)
		and	exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
		select	@tiBed=	0xFF			--	auto-correct for no-bed rooms from bed 0

	if	@idRoom is null		or
		not exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
	begin
		select	@s=	'Pat_UL( [' + isnull(cast(@idPatient as varchar),'?') + '] ' + isnull(@sPatient,'?') +
					', ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) +	-- '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', [' + isnull(cast(@idRoom as varchar),'?') + '] ' + isnull(@sDevice,'?') +
					', b=' + isnull(cast(@tiBed as varchar),'?') + ' ): SGJ or bed-idx'

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
--	Inserts event [0x84] call status
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

,	@idEvent	int			out		-- output: idOrigin of input event
,	@idLogType	tinyint		out
,	@idRoom		smallint	out
)
	with encryption
as
begin
	declare		@idParent	int
	--	,		@idEvent	int
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
	--	,		@idRoom		smallint
		,		@idCall		smallint
		,		@idCall0	smallint
		,		@siBed		smallint
		,		@siIdxOld	smallint
		,		@siIdxNew	smallint
		,		@idDoctor	int
		,		@idPatient	int
		,		@idOrigin	int
		,		@dtOrigin	datetime
	--	,		@idLogType	tinyint
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
	--	,		@tiRmBed	tinyint
		,		@cBed		char( 1 )
		,		@tiPurge	tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiPurge=	cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 7
	select	@iExpNrm=	iValue						from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt=	iValue						from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@idEvent=	null,	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

	if	@siIdxNew > 0			-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiShelf= tiShelf,	@tiSpec= tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

		if	@siIdxOld > 0  and  @siIdxOld <> @siIdxNew		-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0		-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiShelf= tiShelf,	@tiSpec= tiSpec		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0		--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	if	@tiSpec between 7 and 9
		select	@bPresence= 1,	@tiBed= 0xFF	--	mark 'presence' calls and force room-level
/*	else
		if	len(@sPatient) > 0					--	only 'non-presence' calls have patient data
		begin
			exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
			exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
		end
*/
	if	@tiBed > 9
		select	@cBed= null,	@siBed= 0xFFFF,	@tiBed= null
	else
		select	@cBed= cBed,	@siBed= siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed
		
	if	@tiBed is not null	and	len(@sPatient) > 0		--	only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
	end

	if	@tiTmrSt > 3		select	@tiTmrSt=	3
	if	@tiTmrRn > 3		select	@tiTmrRn=	3
	if	@tiTmrCn > 3		select	@tiTmrCn=	3
	if	@tiTmrAi > 3		select	@tiTmrAi=	3

	--	origin points to the first still active event that started call-sequence for this priority
	select	@idOrigin= idEvent, @dtOrigin= dtEvent, @bAudio= bAudio
		from	tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn
			and	bActive > 0				--	6.04
			and	(idCall = @idCall	or	idCall = @idCall0)		--	7.05.4976

	select	@idLogType= case when	@idOrigin is null	then
								case when	@bPresence > 0	then 206 else 191 end
							when	@siIdxNew = 0		then
								case when	@bPresence > 0	then 207 else 193 end
							else
								case when	@idCall0 > 0	then 192 else 194 end	end
		,	@tiSvc=		@tiTmrSt * 64 + @tiTmrRn * 16 + @tiTmrCn * 4 + @tiTmrAi

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		if	@idEvent > 0
			insert	tbEvent84	( idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew,
								tiTmrSt,  tiTmrRn,  tiTmrCn,  tiTmrAi,  idPatient,  idDoctor,  iFilter,
								tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
								siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
					values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew,
								@tiTmrSt, @tiTmrRn, @tiTmrCn, @tiTmrAi, @idPatient, @idDoctor, @iFilter,
								@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
								@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3)

		exec	dbo.prRoom_Upd		@idRoom, @idUnit, @sRn, @sCn, @sAi


		if	@idOrigin is null	--	no active origin found (=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin= @idEvent
					,	tOrigin=	dateadd(ss, @siElapsed, '0:0:0')
					,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent),	@idSrcDvc= idSrcDvc,	@idParent= idParent
				where	idEvent = @idEvent

			insert	tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
									siPri,     siIdx,     idRoom,  tiBed,  idCall, dtExpires,	tiSvc,
									tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
									@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, dateadd(ss, @iExpNrm, getdate( )), @tiSvc,
									@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

			if	@idRoom > 0		and																	--	7.05.5212
				(@tiShelf > 0	and	( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 )			--	'medical' call
				or	@bPresence > 0)																	--	or 'presence'
				begin
					select	@idUser=	case
								when @tiSpec = 7	then	idRn
								when @tiSpec = 8	then	idCn
								when @tiSpec = 9	then	idAi
								else						null	end
						from	tbRoom	with (nolock)
						where	idRoom = @idRoom

					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idRoom,  idUnit,  tiBed,  siBed,  idUser, tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idRoom, @idUnit, @tiBed, @siBed, @idUser, datepart(hh, @dtOrigin) )

					update	c	set	c.idAssn1= rb.idAssn1,	c.idAssn2= rb.idAssn2,	c.idAssn3= rb.idAssn3	--	7.06.5326
						from	tbEvent_C	c
						join	tbRoomBed	rb	on	rb.idRoom = @idRoom		and	( rb.tiBed = @tiBed	or	@tiBed is null	and	( rb.tiBed = 0xFF	or	rb.tiBed = 1 ) )
						where	c.idEvent = @idEvent
				end

			select	@idOrigin= @idEvent
		end

		else					--	active origin found		(=> call healed/escalated/cancelled)
		begin
			update	tbEvent		set	idOrigin= @idOrigin,	tOrigin= dtEvent - @dtOrigin
				where	idEvent = @idEvent

			update	tbEvent_A	set	dtExpires= dateadd(ss, @iExpNrm, getdate( ))
							,	siPri= @siPriNew,	idCall= @idCall,	tiSvc= @tiSvc
	--						,	tiSvc=	@tiTmrSt * 64 + @tiTmrRn * 16 + @tiTmrCn * 4 + @tiTmrAi
				where	idEvent = @idOrigin		--	7.05.5065
		end


		if	@siIdxNew = 0		-- call cancelled
		begin
			select	@dtOrigin=	case when @bAudio=0 then dateadd(ss, @iExpNrm, getdate( ))
													else dateadd(ss, @iExpExt, getdate( )) end

			update	tbEvent_A	set	dtExpires= @dtOrigin,	tiSvc= null,	bActive= 0
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

			select	@dtOrigin= tOrigin,	@idParent= idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent

			update	tbEvent_C	set	idEvtSt= @idEvent,	tStaff= @dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null		-- there should be only one, but just in case - use only 1st one
		end


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
				where	idRoom = @idRoom	and	tiBed = @tiBed


	---	!! @idEvent no longer points to current event !!


		select	@idEvent= null,	@tiSvc= null
		select	top 1	@idEvent= idEvent,	@tiSvc= tiSvc		--	highest oldest active call for this room
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent
	--		order	by	siIdx desc, tElapsed desc				--	call may have started before it was recorded

		update	tbRoom	set	idEvent= @idEvent,	tiSvc= @tiSvc,	dtUpdated= getdate( )
			where	idRoom = @idRoom


		declare		cur		cursor fast_forward for
			select	tiBed
				from	tbRoomBed	with (nolock)
				where	idRoom = @idRoom

		open	cur
		fetch next from	cur	into	@tiBed
		while	@@fetch_status = 0
		begin
			select	@idEvent= null,	@tiSvc= null
			select	top 1	@idEvent= idEvent,	@tiSvc= tiSvc	--	highest oldest active call for this room's bed
				from	tbEvent_A	ea	with (nolock)
				where	idRoom = @idRoom
					and	bActive > 0
					and	(tiBed is null	or tiBed = @tiBed)
				order	by	siIdx desc, idEvent
	--			order	by	siIdx desc, tElapsed desc			--	call may have started before it was recorded

			update	tbRoomBed	set	idEvent= @idEvent,	tiSvc= @tiSvc,	dtUpdated= getdate( )
	--	??			,	tiSvc= case when @siIdxNew = 0 then null else @tiSvc end	--	7.05.5204	seems unnecessary
				where	idRoom = @idRoom	and	tiBed = @tiBed

			fetch next from	cur	into	@tiBed
		end
		close	cur
		deallocate	cur

	commit

	select	@idEvent= @idOrigin			--	7.05.5267	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	Returns all active units, accessible by the given user (via his roles), ordered to be loadable into a tree
--	7.06.5385	* optimized
--	7.05.5253	* ?
--	7.05.5043
alter proc		dbo.prUnit_GetByUser
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	if	@idUser > 0
		select	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtUpdated
			from	(select	distinct	idUnit
						from	tb_RoleUnit	ru	with (nolock)
						join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser)	ru
			join	tbUnit	u	with (nolock)	on	ru.idUnit = u.idUnit
			join	tbShift	s	with (nolock)	on	s.idShift = u.idShift
			where	u.bActive > 0
			order	by	u.sUnit
	else
		select	u.idUnit, u.sUnit, u.tiShifts, u.idShift, s.tiIdx, u.bActive, u.dtUpdated
			from	tbUnit	u	with (nolock)
			join	tbShift	s	with (nolock)	on	s.idShift = u.idShift
			where	u.bActive > 0
			order	by	u.sUnit
end
go
--	----------------------------------------------------------------------------
--	Returns locations down to unit-level, accessible by a given user; ordered to be loadable into a tree
--	7.06.5385	* fix: accessibility via user's roles
--	7.05.5043
alter proc		dbo.prCfgLoc_GetByUser
(
	@idUser		int
)
	with encryption
as
begin
--	set	nocount	on
	select	idLoc, idParent, cLoc, sLoc, tiLvl
		from	tbCfgLoc	with (nolock)
			where	tiLvl < 4					-- anything above unit-level
			or		tiLvl = 4	and	idLoc in
					(select	distinct	idUnit
						from	tb_RoleUnit	ru	with (nolock)
						join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser)
		order	by	tiLvl, idLoc
end
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
		from	tb_Role		with (nolock)
		order	by	idRole
end
go
grant	execute				on dbo.pr_Role_Exp					to [rWriter]
grant	execute				on dbo.pr_Role_Exp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a role
--	7.06.5385
create proc		dbo.pr_Role_Imp
(
	@idRole		smallint
,	@sRole		varchar( 16 )
,	@sDesc		varchar( 16 )
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not	exists	(select 1 from tb_Role with (nolock) where idRole = @idRole)
		begin
			set identity_insert	dbo.tb_Role	on

			insert	tb_Role	(  idRole,  sRole,  sDesc,  bActive,  dtCreated,  dtUpdated )
					values	( @idRole, @sRole, @sDesc, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tb_Role	off
		end
		else
			update	tb_Role	set	sRole= @sRole, sDesc= @sDesc, bActive= @bActive, dtUpdated= @dtUpdated
				where	idRole = @idRole

	commit
end
go
grant	execute				on dbo.pr_Role_Imp					to [rWriter]
--grant	execute				on dbo.pr_Role_Imp					to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all user-role combinations
--	7.06.5385
create proc		dbo.pr_UserRole_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idUser, idRole, dtCreated
		from	tb_UserRole		with (nolock)
		order	by	idRole
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
			if	not	exists	(select 1 from tb_UserRole with (nolock) where idRole = @idRole and idUser = @idUser)
			begin
				insert	tb_UserRole	(  idUser,  idRole,  dtCreated )
						values		( @idUser, @idRole, @dtCreated )
			end
		end
		else
			delete	from	tb_UserRole

	commit
end
go
grant	execute				on dbo.pr_UserRole_Imp				to [rWriter]
--grant	execute				on dbo.pr_UserRole_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Exports all role-unit combinations
--	7.06.5385
create proc		dbo.pr_RoleUnit_Exp
	with encryption
as
begin
--	set	nocount	on
	select	idRole, idUnit, dtCreated
		from	tb_RoleUnit		with (nolock)
		order	by	idRole
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
			if	not	exists	(select 1 from tb_RoleUnit with (nolock) where idRole = @idRole and idUnit = @idUnit)
			begin
				insert	tb_RoleUnit	(  idRole,  idUnit,  dtCreated )
						values		( @idRole, @idUnit, @dtCreated )
			end
		end
		else
			delete	from	tb_RoleUnit

	commit
end
go
grant	execute				on dbo.pr_RoleUnit_Imp				to [rWriter]
--grant	execute				on dbo.pr_RoleUnit_Imp				to [rReader]
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	sd.idDevice, sd.sDevice, sd.sQnDevice, sd.tiStype, sd.sSGJR + ' :' + right('0' + cast(ea.tiBtn as varchar), 2) [sSGJRB]
	,	ea.idRoom, r.sDevice [sRoom],	ea.tiBed, b.cBed,	rm.idUnit
	,	ea.idCall, c.siIdx, c.sCall, p.iColorF, p.iColorB, p.tiShelf, p.tiSpec, p.iFilter
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit ) [bAnswered]
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) ) [tElapsed], ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	from		tbEvent_A	ea	with (nolock)
	left join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left join	tbCall		c	with (nolock)	on	c.idCall = ea.idCall
	left join	tbCfgPri	p	with (nolock)	on	p.siIdx = c.siIdx
	left join	tbCfgBed	b	with (nolock)	on	b.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Exports all staff assignment definitions
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

	select	idStfAssn, idUnit, idRoom, cSys, tiGID, tiJID, tiBed, idShift, tiShIdx, tiIdx, idUser, sStaffID, bActive, dtCreated, dtUpdated
		from	vwStfAssn	with (nolock)
	---	where	bActive > 0					-- must export all to ensure matching deactivation
end
go
revoke	execute				on dbo.prStfAssn_Exp				from [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5386	+ [C6,DC-DF]
if	not	exists	(select 1 from dbo.tbDefCmd with (nolock) where idCmd = 0xC6)
begin
	begin tran
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xC6, 'set remote device audio mode' )		--	7.06.5386

	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDC, 'GID alias' )							--	7.06.5386
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDD, 'test fixtr set outputs' )				--	7.06.5386
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDE, 'test fixtr input status request' )		--	7.06.5386
	--	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0xDF, 'test fixtr input status response' )	--	7.06.5386
	commit
end
go
--	----------------------------------------------------------------------------
--	enforce 'Public' membership
begin tran

		insert	dbo.tb_UserRole ( idUser, idRole )
			select	idUser, 1
				from	dbo.tb_User
				where	idUser not in (select idUser from dbo.tb_UserRole with (nolock) where idRole = 1)

commit
go
--	----------------------------------------------------------------------------
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
--	7.06.5387
create proc		dbo.prRptStfAssnStaff
(
	@idUser		int					--
)
	with encryption
as
begin
--	set	nocount	on
	select	idStfLvl, sStfLvl, sStaff, sStaffID
		from	vwStaff		with (nolock)
		where	idUser = @idUser
end
go
grant	execute				on dbo.prRptStfAssnStaff			to [rWriter]
grant	execute				on dbo.prRptStfAssnStaff			to [rReader]
go
--	----------------------------------------------------------------------------
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
--	Returns on-duty pageable staff for given unit(s)
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
	select	distinct	st.idUser, sStaffID, sStaff
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
--	Returns modules state
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
	select	idModule, sModule, sVersion, sDesc, bLicense, tiModType
		,	case when sMachine is null then sIpAddr else sMachine end	[sHost]
		,	dtStart, dtLastAct, sParams
		,	datediff( mi, dtLastAct, getdate( ) )	[siElapsed]
		from	tb_Module	with (nolock)
		where	(@bInstall = 0	or	sIpAddr is not null  or  sMachine is not null)
		and		(@bActive = 0	or	dtStart is not null)
end
go
grant	execute				on dbo.pr_Module_GetAll				to [rWriter]
grant	execute				on dbo.pr_Module_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
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
,	@sModInfo	varchar( 96 )		-- module info (e.g. 'j7983ls.exe v.M.N.DD.TTTT (built d/t)')
,	@idLogType	tinyint				-- type look-up FK (marks significant events only)
,	@dtStart	datetime			-- when running, null == stopped
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

		update	dbo.tb_Module	set	dtStart= @dtStart,	sParams= @sParams,	dtLastAct= getdate( )
			where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sModInfo

		select	@sModInfo=	sModule + ' v.' + sVersion
			from	dbo.tb_Module	with (nolock)
			where	idModule = @idModule

		exec	dbo.prEvent_Ins		0, null, null, null		---	@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	null, null, null, null, null, @sModInfo	---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

	commit
end
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tbRptSessDvc), 0=<invalid>
,	@siBeds		smallint			-- bitwise, 0xFFFF=any
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 0xFF
		if	@siBeds = 0xFFFF
			select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg
				,	ec.tVoice, ec.tStaff,	ec.sAssn1, ec.sAssn2, ec.sAssn3,	ec.sRoomBed
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
				order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
		else
			select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg
				,	ec.tVoice, ec.tStaff,	ec.sAssn1, ec.sAssn2, ec.sAssn3,	ec.sRoomBed
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
				and		ec.siBed & @siBeds <> 0
				order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
	else
		if	@siBeds = 0xFFFF
			select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg
				,	ec.tVoice, ec.tStaff,	ec.sAssn1, ec.sAssn2, ec.sAssn3,	ec.sRoomBed
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
				order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
		else
			select	ec.idEvent, ec.idRoom, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg
				,	ec.tVoice, ec.tStaff,	ec.sAssn1, ec.sAssn2, ec.sAssn3,	ec.sRoomBed
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
				where	ec.idEvent	between @idFrom	and @idUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
				and		ec.siBed & @siBeds <> 0
				order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
end
go
grant	execute				on dbo.prRptCallActExc				to [rWriter]
grant	execute				on dbo.prRptCallActExc				to [rReader]
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tb_SessDvc), 0=<invalid>
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 0xFF
		select	t.idCall, t.lCount, t.siIdx, t.tiSpec
			,	case when t.tiSpec in (7,8,9) then t.sCall + ' †' else t.sCall end	sCall		--	'†• ' +
			,	case when t.tiSpec in (7,8,9) then null else t.tVoTrg end	tVoTrg, t.tVoAvg, t.tVoMax, t.lVoNul, t.lVoOnT
			,	case when t.tiSpec in (7,8,9) then null else t.tStTrg end	tStTrg, t.tStAvg, t.tStMax, t.lStNul, t.lStOnT
			,	case when t.tVoAvg is null then null else t.lVoOnT*100/(t.lCount-t.lVoNul) end	fVoOnT
			,	case when t.tStAvg is null then null else t.lStOnT*100/(t.lCount-t.lStNul) end	fStOnT
			from
				(select	c.idCall, count(*) lCount
					,	min(f.siIdx)	siIdx,		min(f.sCall)	sCall,		min(p.tiSpec)	tiSpec
					,	min(f.tVoTrg)	tVoTrg,		min(f.tStTrg)	tStTrg
					,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) )	tVoAvg
					,	max(c.tVoice)	tVoMax
					,	sum(case when c.tVoice < f.tVoTrg then 1 else 0 end)	lVoOnT
					,	sum(case when c.tVoice is null then 1 else 0 end)	lVoNul
					,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) )	tStAvg
					,	max(c.tStaff)	tStMax
					,	sum(case when c.tStaff < f.tStTrg then 1 else 0 end)	lStOnT
					,	sum(case when c.tStaff is null then 1 else 0 end)	lStNul
				from		tbEvent_C	c	with (nolock)
					join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				group	by c.idCall)	t
			order by	t.siIdx desc
	else
		select	t.idCall, t.lCount, t.siIdx, t.tiSpec
			,	case when t.tiSpec in (7,8,9) then t.sCall + ' †' else t.sCall end	sCall
			,	case when t.tiSpec in (7,8,9) then null else t.tVoTrg end	tVoTrg, t.tVoAvg, t.tVoMax, t.lVoNul, t.lVoOnT
			,	case when t.tiSpec in (7,8,9) then null else t.tStTrg end	tStTrg, t.tStAvg, t.tStMax, t.lStNul, t.lStOnT
			,	case when t.tVoAvg is null then null else t.lVoOnT*100/(t.lCount-t.lVoNul) end	fVoOnT
			,	case when t.tStAvg is null then null else t.lStOnT*100/(t.lCount-t.lStNul) end	fStOnT
			from
				(select	c.idCall, count(*) lCount
					,	min(f.siIdx)	siIdx,		min(f.sCall)	sCall,		min(p.tiSpec)	tiSpec
					,	min(f.tVoTrg)	tVoTrg,		min(f.tStTrg)	tStTrg
					,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) )	tVoAvg
					,	max(c.tVoice)	tVoMax
					,	sum(case when c.tVoice < f.tVoTrg then 1 else 0 end)	lVoOnT
					,	sum(case when c.tVoice is null then 1 else 0 end)	lVoNul
					,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) )	tStAvg
					,	max(c.tStaff)	tStMax
					,	sum(case when c.tStaff < f.tStTrg then 1 else 0 end)	lStOnT
					,	sum(case when c.tStaff is null then 1 else 0 end)	lStNul
				from		tbEvent_C	c	with (nolock)
					join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
					join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
					join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx
				where	c.idEvent	between @idFrom	and @idUpto
					and	c.tiHH		between @tFrom	and @tUpto
				group	by c.idCall)	t
			order by	t.siIdx desc
end
go
--	----------------------------------------------------------------------------
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
,	@tiDvc		tinyint				-- 0xFF=any, 1=specific (tb_SessDvc), 0=<invalid>
--,	@bPres		bit					-- ignored
)
	with encryption
as
begin
	declare		@idFrom		int
	declare		@idUpto		int

	set	nocount	on

	exec	prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @idFrom out, @idUpto out

	set	nocount	off
	if	@tiDvc = 0xFF
		select	c.dEvent,	count(*)	[lCount]
		--		,	min(f.tVoTrg)	[tVoTrg],	min(f.tStTrg)	[tStTrg]
				,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
				,	max(c.tVoice)	[tVoMax]
				,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
				,	max(c.tStaff)	[tStMax]
			from		tbEvent_C	c	with (nolock)
				join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
				join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	and	(p.tiSpec is null	or	p.tiSpec not in (7,8,9))
			where	c.idEvent	between @idFrom	and @idUpto
				and	c.tiHH		between @tFrom	and @tUpto
			group	by c.dEvent
	else
		select	c.dEvent,	count(*)	[lCount]
		--		,	min(f.tVoTrg)	[tVoTrg],	min(f.tStTrg)	[tStTrg]
				,	cast( cast( avg( cast( cast(c.tVoice as datetime) as float) ) as datetime) as time(3) )	[tVoAvg]
				,	max(c.tVoice)	[tVoMax]
				,	cast( cast( avg( cast( cast(c.tStaff as datetime) as float) ) as datetime) as time(3) )	[tStAvg]
				,	max(c.tStaff)	[tStMax]
			from		tbEvent_C	c	with (nolock)
				join	tb_SessDvc	d	with (nolock)	on	d.idDevice = c.idRoom
				join	tb_SessCall	f	with (nolock)	on	f.idCall = c.idCall	and	f.idSess = @idSess
				join	tbCfgPri	p	with (nolock)	on	p.siIdx = f.siIdx	and	(p.tiSpec is null	or	p.tiSpec not in (7,8,9))
			where	c.idEvent	between @idFrom	and @idUpto
				and	c.tiHH		between @tFrom	and @tUpto
			group	by c.dEvent
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
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
,	@siIdx		smallint			-- call-index
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
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@sCall		varchar( 16 )
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
		,		@idUser		int
		,		@idLogType	tinyint

	set	nocount	on

	select	@siIdx=	@siIdx & 0x03FF

	if	@siIdx > 0
	begin
		select	@sCall= sCall	from	tbCfgPri	with (nolock)	where	siIdx = @siIdx
		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
	end
	else
		select	@idCall= 0				--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	if	@idDvc is null
		select	@idDvc= idDvc
			from	tbDvc	with (nolock)
			where	@idDvcType = @idDvcType		and	sDial = @sDial	and	bActive > 0

	select	@idLogType=	case
				when idDvcType = 4 then 204		-- phone
				when idDvcType = 2 then 205		-- pager
				else 82 end
		,	@idUser= idUser
		from	tbDvc	with (nolock)
		where	idDvc = @idDvc

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	null, null, null, null, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed		---	, @iAID, @tiStype, @idCall0

		insert	tbEvent41	(  idEvent,  idPcsType,  idDvc,  idUser,  tiSeqNum,  cStatus )
				values		( @idEvent, @idPcsType, @idDvc, @idUser, @tiSeqNum, @cStatus )

	commit
end
go

--	----------------------------------------------------------------------------
print	'	7980 objects'

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
--	re-save users
declare		@idUser		int					-- operand user, acted upon
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
--		,	@sRoles		varchar( 255 )
		,	@bOnDuty	bit
		,	@bActive	bit

declare		cur		cursor fast_forward for
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc, sStaffID, idStfLvl, sBarCode, sUnits, sTeams, bOnDuty, bActive
		from	tb_User		with (nolock)
		where	idUser > 15

begin tran

	update	tb_User		set	sUnits= null	where	sUnits = ''
	update	tb_User		set	sTeams= null	where	sTeams = ''

	open	cur
	fetch next from	cur	into	@idUser, @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @sTeams, @bOnDuty, @bActive
	while	@@fetch_status = 0
	begin
		exec	dbo.pr_User_InsUpd	2, @idUser, @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @sTeams, null, @bOnDuty, @bActive

		fetch next from	cur	into	@idUser, @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @sTeams, @bOnDuty, @bActive
	end
	close	cur
	deallocate	cur

commit
go
--	----------------------------------------------------------------------------
--	re-save devices
declare		@idDvc		int					-- device, acted upon
		,	@idDvcType	tinyint
		,	@sDvc		varchar( 16 )
		,	@sBarCode	varchar( 32 )
		,	@sDial		varchar( 16 )
		,	@tiFlags	tinyint
		,	@sUnits		varchar( 255 )
		,	@sTeams		varchar( 255 )
		,	@bActive	bit

declare		cur		cursor fast_forward for
	select	idDvc, idDvcType, sDvc, sBarCode, sDial, tiFlags, sUnits, sTeams, bActive
		from	tbDvc		with (nolock)
		where	idDvcType > 1

begin tran

	update	tbDvc		set	sUnits= null	where	sUnits = ''
	update	tbDvc		set	sTeams= null	where	sTeams = ''

	open	cur
	fetch next from	cur	into	@idDvc, @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @sTeams, @bActive
	while	@@fetch_status = 0
	begin
		exec	dbo.prDvc_InsUpd	2, @idDvc, @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @sTeams, @bActive

		fetch next from	cur	into	@idDvc, @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @sTeams, @bActive
	end
	close	cur
	deallocate	cur

commit
go
--	----------------------------------------------------------------------------
--	re-save teams
declare		@idTeam		smallint			-- team, acted upon
		,	@sTeam		varchar( 16 )
		,	@tResp		time( 0 )
		,	@sDesc		varchar( 255 )
		,	@sCalls		varchar( 255 )
		,	@sUnits		varchar( 255 )
		,	@bActive	bit

declare		cur		cursor fast_forward for
	select	idTeam, sTeam, tResp, sDesc, sCalls, sUnits, bActive
		from	tbTeam		with (nolock)

begin tran

	update	tbTeam		set	sUnits= null	where	sUnits = ''
	update	tbTeam		set	sCalls= null	where	sCalls = ''

	open	cur
	fetch next from	cur	into	@idTeam, @sTeam, @tResp, @sDesc, @sCalls, @sUnits, @bActive
	while	@@fetch_status = 0
	begin
		exec	dbo.prTeam_InsUpd	2, @idTeam, @sTeam, @tResp, @sDesc, @sCalls, @sUnits, @bActive

		fetch next from	cur	into	@idTeam, @sTeam, @tResp, @sDesc, @sCalls, @sUnits, @bActive
	end
	close	cur
	deallocate	cur

commit
go

--	----------------------------------------------------------------------------
--	remove healing events
--	<512,tbEvent>
exec	dbo.prEvent_Maint
go

--if	not	exists	( select 1 from tb_Version where siBuild = 5340 )
--	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
--		values	( 706,	5340, '2014-08-15', getdate( ),	'+tbEvent_C.idAssn1|2|3, +tbCfgBed.siBed, *xrCallActSum, *xrCallActDtl, +xrCallActExc' )
--go
--if	not	exists	( select 1 from tb_Version where idVersion = 706 )
--	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
--		values	( 706,	0, getdate( ), getdate( ),	'_' )
if	not	exists	( select 1 from tb_Version where siBuild = 5396 )
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 706,	5396, getdate( ), getdate( ),	'_' )
go

update	tb_Version	set	dtCreated= '2014-10-10', dtInstall= getdate( )
	,	sVersion= '+tbEvent_C.idAssn1|2|3, +tbCfgBed.siBed, *xrCallActSum, *xrCallActDtl, +xrCallActExc, *7980cw, *7980ps, *7983rh, *7980rh, *7981cw, *7985cw, *7970as'
--	where	idVersion = 706
	where	siBuild = 5396

update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.6.5396'
	where	idModule = 1

exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.5396 )'
go

checkpoint
go

use [master]
go
