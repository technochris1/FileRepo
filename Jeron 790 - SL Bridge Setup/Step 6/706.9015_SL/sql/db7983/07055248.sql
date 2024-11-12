--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.05
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
--						+ tb_Option[20], tb_OptSys[20]
--		2014-Apr-15		.5219
--						+ prStfLvl_Upd
--		2014-Apr-16		.5220
--						* tb_User.sTeams: vc(32) -> vc(255),	pr_User_InsUpd
--		2014-Apr-18		.5222
--						* prRtlsBadge_Init, prRtlsBadge_InsUpd
--		2014-Apr-22		.5226
--						+ prShift_Upd
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
--						
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 705 and siBuild >= 5248 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.05.5248', 18, 0 )

go

if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwShift')
	drop view	dbo.vwShift
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Access_GetByUser')
	drop proc	dbo.pr_Access_GetByUser
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetPerms')
	drop proc	dbo.pr_Role_GetPerms
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetUnits')
	drop proc	dbo.pr_Role_GetUnits
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Role_GetAll')
	drop proc	dbo.pr_Role_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Access_GetByRole')
	drop proc	dbo.pr_Access_GetByRole
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Access_InsUpdDel')
	drop proc	dbo.pr_Access_InsUpdDel
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_Upd')
	drop proc	dbo.prShift_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prStfLvl_Upd')
	drop proc	dbo.prStfLvl_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetByUnit')
	drop proc	dbo.prRoom_GetByUnit
go
--	----------------------------------------------------------------------------
--	7.05.5235	+ [21-25]
--	7.05.5218	+ [20]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 20)
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 20,  56, 'Announce cancellations?'	)				--	7.05.5218
	if	not	exists	(select 1 from dbo.tb_OptSys where idOption = 20)
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 20, 1 )

	if	not	exists	(select 1 from dbo.tb_Option where idOption > 20)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 21,  56, 'Call answered Tout, sec' )					--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 22,  56, 'STAT need OT, sec' )						--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 23,  56, 'Grn need OT, sec' )							--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 24,  56, 'Ora need OT, sec' )							--	7.05.5235
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 25,  56, 'Yel need OT, sec' )							--	7.05.5235

		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 21, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 22, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 23, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 24, 120 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 25, 120 )
	end
commit
go
--	----------------------------------------------------------------------------
--	7.05.5203	* .idUser -> null	(83 may not have synched device owners yet)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent41') and name = 'idUser' and is_nullable = 0)
begin
	begin tran
		alter table		dbo.tbEvent41	alter column
			idUser		int				null		-- who was this device assigned to at that moment?
	commit
end
go
--	----------------------------------------------------------------------------
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
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
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
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
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
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
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
				where	e.idEvent	between @idFrom	and @idUpto
				and		e.tiHH		between @tFrom	and @tUpto
				order	by	s.sDevice, s.idParent, e.idEvent
end
go
--	----------------------------------------------------------------------------
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 194)
	insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 194, 1, 16, 'Call Healing' )			--	7.05.5204
go
--	----------------------------------------------------------------------------
--	mark healing events
--	7.05.5204	+ [194]
--	<128,tbEvent>
begin tran
	update	tbEvent	set	idLogType= 194
		where	idLogType is null
		and		idEvent in (select idEvent from tbEvent84 with (nolock) where siIdxNew = siIdxOld);

	if	exists	(select 1 from dbo.tb_OptSys where idOption = 7 and	iValue = 0)
		update	dbo.tb_OptSys	set	iValue= 7		-- keep 1 week
			where	idOption = 7
commit
go
--	----------------------------------------------------------------------------
--	Returns rooms/masters for given unit
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

	create table	#tbDevice
	(
		idDevice	smallint

		primary key nonclustered ( idDevice )
	)

	insert	#tbDevice
		select	idRoom
		from	tbRoom	with (nolock)
		where	idUnit = @idUnit

	if	@bActive = 0
		insert	#tbDevice
			select	idDevice
			from	vwDevice	with (nolock)
			where	tiRID = 0	and	(tiStype between 4 and 7		-- room/workflow-master controllers
					or	idDevice in (select idParent from tbDevice with (nolock) where tiRID =1 and tiStype =26))
	--		and		(idUnit = @idUnit	or	idUnit is null	and		sUnits like '%' + cast(@idUnit as varchar) + '%')
			and		(idUnit <> @idUnit	and	sUnits like '%' + cast(@idUnit as varchar) + '%')
			and		idDevice	not	in (select idDevice from #tbDevice with (nolock))

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint) [tiSwing], d.sUnits						-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice						-- v.7.02
		order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
grant	execute				on dbo.prRoom_GetByUnit				to [rReader]	--	6.05
grant	execute				on dbo.prRoom_GetByUnit				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Removes expired active events
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

	exec	pr_Module_Act	1

	begin	tran

		select	@dt=	getdate( )					--	mark starting time

		update	r	set	r.idEvent= null				--	reset tbRoom.idEvent		v.7.02
			from	tbRoom	r
			join	tbEvent_A	ea	on	ea.idEvent = r.idEvent
			where	ea.dtExpires < @dt
		update	rb	set	rb.idEvent= null			--	reset tbRoomBed.idEvent		v.7.02
			from	tbRoomBed	rb
			join	tbEvent_A	ea	on	ea.idEvent = rb.idEvent
			where	ea.dtExpires < @dt

		delete	from	tbEvent_A	where	dtExpires < @dt

		if	@tiPurge > 0
		begin
			if	@tiPurge = 255						--	remove all inactive events
			begin
				update	c	set	c.idEvtVo=	null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtVo
					where	a.idEvent is null
				update	c	set	c.idEvtSt= null
					from	tbEvent_C c
					left join	tbEvent_A a	on	a.idEvent = c.idEvtSt
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left join	tbEvent_A a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
							' inactive events in ' + convert(varchar, getdate() - @dt, 114)
				exec	pr_Log_Ins	2, null, null, @s
			end
			else	--	if	@tiPurge < 255			--	remove healing 84s
			begin
				declare		@idEvent	int

				select	@idEvent=	max(idEvent)	--	get latest idEvent before which healing 84s are to be removed
					from	tbEvent_S
					where	dEvent <= dateadd(dd, -@tiPurge, @dt)
					and		tiHH <= datepart(hh, @dt)

				delete	from	tbEvent
					where	idLogType = 194
					and		idEvent < @idEvent

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
							' healing events in ' + convert(varchar, getdate() - @dt, 114)
				exec	pr_Log_Ins	2, null, null, @s
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
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
	declare		@dtEvent	datetime
		,		@tiHH		tinyint
	--	,		@idRoom		smallint
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
		,	@cDevice=	case when @idCmd = 0x83 then 'G' else '?' end

	select	@iExpNrm= iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@tiBed= null

	if	@idUnit > 0
--		if	not exists	(select 1 from tbCfgLoc where idLoc = @idUnit and cLoc = 'U')
		if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
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

	begin	tran

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
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

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
				and		( bActive > 0		or	@idCmd < 0x80	or	@idCmd = 0x8D )		--	7.05.5095, .5211
				and		( tiBtn = @tiBtn	or	@tiBtn is null )
				and		( idCall = @idCall	or	@idCall is null		or	idCall = @idCall0	and	@idCall0 is not null )

			select	@idRoom=	idDevice
				from	vwRoom		with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	bActive > 0		--	and	tiRID = 0

--			select	@s=	'Evt_i2: prnt=' + isnull(cast(@idParent as varchar),'?') + ' room=' + isnull(cast(@idRoom as varchar),'?')
--			exec	pr_Log_Ins	0, null, null, @s

			if	@idParent > 0
				update	tbEvent		set	idParent= @idParent,	idRoom= @idRoom,	tParent= dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	tbEvent		set	idParent= @idEvent,		idRoom= @idRoom,	tParent= '0:0:0'
					where	idEvent = @idEvent

			if	@idUnit > 0		and	@idRoom > 0					--	7.02	7.05.5205
				update	tbRoom		set	idUnit=	@idUnit
					where	idRoom = @idRoom
		end

		select	@idParent= null
		select	@idParent= idEvent
			from	tbEvent_S	with (nolock)
			where	dEvent = cast(@dtEvent as date)		and	tiHH = @tiHH

		if	@idParent	is null
			insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
					values		( @dtEvent, @tiHH, @idEvent )

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
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
,	@dtStarted	datetime			-- when running, null == stopped
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

		update	dbo.tb_Module	set	dtStart= @dtStarted,	sParams= @sParams,	dtLastAct= getdate( )
			where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sModInfo

--		select	@idEvent=	charindex( ' [', @sModInfo ) + 2
	---	select	@sModInfo=	replace( substring( @sModInfo, @idEvent, charindex( ' (', @sModInfo ) - @idEvent ), ']', '' )
--		select	@sModInfo=	replace( substring( @sModInfo, @idEvent, len( @sModInfo ) - @idEvent ), ']', ' ' )

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
--	Marks a gateway as found or lost (and removes its active calls)
--	7.05.5205	* prEvent_Ins args
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
		,		@idEvent	int
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		if	@idLogType = 189
			update	tbDevice	set	bActive= 1
				where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	bActive = 0

		select	@s=	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + ' [' + isnull(sDevice,'?') + ']'
			from	tbDevice	with (nolock)
			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	bActive > 0

	---	if	@idLogType = 189
	---		select	@s= @s + ' found'
	---	else
		if	@idLogType = 190
		begin
			delete	from	tbEvent_A
				where	cSys = @cSys	and	tiGID = @tiGID

			select	@s= @s + ', ' + cast(@@rowcount as varchar) + ' active call(s) cleared'
		end

		exec	dbo.prEvent_Ins		0x83, 0, 0, null		---	@idCmd, @tiLen, @iHash, @vbCmd,
				,	@cSys, @tiGID, 0, 0, null				--- @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
				,	null, null, null, null, null, null		---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType								---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiRmBed	tinyint
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

	select	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

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
		select	@bPresence= 1,	@tiBed=	0xFF	--	'presence' calls are room-level
	else
		if	len(@sPatient) > 0					--	'presence' calls do not have patient data
		begin
			exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
			exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
		end

	if	@tiBed > 9
		select	@cBed= null,	@tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed
		
/*	if	@idUnit > 0
--		if	not exists	(select 1 from tbCfgLoc where idLoc = @idUnit and cLoc = 'U')
		if	not exists	(select 1 from tbUnit where idUnit = @idUnit and bActive > 0)
		begin
			select	@s=	'Evt_I( c=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?')
	--	-	exec	pr_Log_Ins	82, null, null, @s

			select	@idUnit=	null
		end
*/
	if	@tiTmrSt > 3		select	@tiTmrSt=	3
	if	@tiTmrRn > 3		select	@tiTmrRn=	3
	if	@tiTmrCn > 3		select	@tiTmrCn=	3
	if	@tiTmrAi > 3		select	@tiTmrAi=	3

	--	origin points to the first [still active!] event that started [healing] sequence for this priority
	select	@idOrigin= idEvent, @dtOrigin= dtEvent, @bAudio= bAudio
		from	tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn
			and	bActive > 0				--	6.04
			and	(idCall = @idCall	or	idCall = @idCall0)		--	7.05.4976

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	null, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

/*		select	@idRoom= idRoom									--	get idRoom, assigned by prEvent_Ins
			from	tbEvent		with (nolock)
			where	idEvent = @idEvent
*/
		insert	tbEvent84	(  idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew,
							tiTmrSt,  tiTmrRn,  tiTmrCn,  tiTmrAi,  idPatient,  idDoctor,  iFilter,
							tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
							siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
				values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew,
							@tiTmrSt, @tiTmrRn, @tiTmrCn, @tiTmrAi, @idPatient, @idDoctor, @iFilter,
							@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
							@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3)

/*		if	len(@s) > 0
		begin
			select	@s=	@s + ' ) id=' + cast(@idEvent as varchar)
			exec	pr_Log_Ins	82, null, null, @s
		end
*/
		exec	dbo.prRoom_Upd		@idRoom, @idUnit, @sRn, @sCn, @sAi


		if	@idOrigin is null	--	no active origin found (=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin= @idEvent
					,	idLogType=	case when @bPresence > 0 then 206 else 191 end	-- call placed
					,	tOrigin=	dateadd(ss, @siElapsed, '0:0:0')
					,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent),	@idSrcDvc= idSrcDvc,	@idParent= idParent
				where	idEvent = @idEvent

			insert	tbEvent_A	(  idEvent,   dtEvent,  cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
									siPri,     siIdx,     idRoom,  tiBed,  idCall, dtExpires,	tiSvc,
									tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
									@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, dateadd(ss, @iExpNrm, getdate( )),
									@tiTmrSt * 64 + @tiTmrRn * 16 + @tiTmrCn * 4 + @tiTmrAi,
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

					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idRoom,  idUnit,  tiBed,  idUser, tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idRoom, @idUnit, @tiBed, @idUser, datepart(hh, @dtOrigin) )
				end

			select	@idOrigin= @idEvent
		end

		else					--	active origin found		(=> call healed/escalated/cancelled)
		begin
			update	tbEvent		set	idOrigin= @idOrigin,	tOrigin= dtEvent - @dtOrigin
					,	idLogType=	case when @idCall0 > 0 then 192 else 194 end
				where	idEvent = @idEvent

			update	tbEvent_A	set	dtExpires= dateadd(ss, @iExpNrm, getdate( )),	siPri= @siPriNew,	idCall= @idCall
					,	tiSvc=	@tiTmrSt * 64 + @tiTmrRn * 16 + @tiTmrCn * 4 + @tiTmrAi
				where	idEvent = @idOrigin		--	7.05.5065

---	7.05.5204	results in high CPU time and Reads count => leave clean-up for prEvent_A_Exp/prEvent_Maint
	--		if	@tiPurge > 0					-- remove healing event at once (cascade rule must take care of other tables)
	--			delete	from	tbEvent
	--				where	idEvent = @idEvent	and	idLogType = 194		--	7.05.5204	
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

			update	tbEvent		set	idLogType=	case when @bPresence > 0 then 207 else 193 end		-- call cancelled
				where	idEvent = @idEvent
		end

---	7.05.5204	moved up
	--	else if	@siIdxNew > 0  and  @siIdxOld > 0  and  @siIdxOld <> @siIdxNew
	--		update	tbEvent		set	idLogType= 192		-- call escalated
	--			where	idEvent = @idEvent


---	7.05.5204	moved up
	--	update	tbEvent_A	set	tiSvc=	@tiTmrSt * 64 + @tiTmrRn * 16 + @tiTmrCn * 4 + @tiTmrAi
	--		where	idEvent = @idOrigin


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

---	7.05.5204	moved up
	--	if	@bPresence = 0	and	@idPatient > 0					--	7.05.5147,	7.05.5204
	--		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5101


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
		fetch next from	cur	into	@tiRmBed
		while	@@fetch_status = 0
		begin
			select	@idEvent= null,	@tiSvc= null
			select	top 1	@idEvent= idEvent,	@tiSvc= tiSvc	--	highest oldest active call for this room's bed
				from	tbEvent_A	ea	with (nolock)
				where	idRoom = @idRoom
					and	bActive > 0
					and	(tiBed is null	or tiBed = @tiRmBed)
				order	by	siIdx desc, idEvent
	--			order	by	siIdx desc, tElapsed desc			--	call may have started before it was recorded

			update	tbRoomBed	set	idEvent= @idEvent,	tiSvc= @tiSvc,	dtUpdated= getdate( )
	--	??			,	tiSvc= case when @siIdxNew = 0 then null else @tiSvc end	--	7.05.5204	seems unnecessary
				where	idRoom = @idRoom	and	tiBed = @tiRmBed

			fetch next from	cur	into	@tiRmBed
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x86, 0x87, 0x8F, 0x94]
--	7.05.5205	* prEvent_Ins args
--	5.01	encryption added
--	4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	1.00
alter proc		dbo.prEvent86_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint				-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@tiTestBits	tinyint				-- 0x86 only: number of bits to test
,	@iAID		int					-- 24 bits (3 bytes)
,	@tiStype	tinyint				-- 8 bits
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

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null
				,	null, null, null, null, null, null						---		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
		---		,	null, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		insert	tbEvent86	( idEvent, tiTestBits, iAID, tiStype )
				values		( @idEvent, @tiTestBits, @iAID, @tiStype )

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
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
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idCall		smallint
		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@cBed		char( 1 )
		,		@iExpNrm	int
		,		@idLogType	tinyint

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@iExpNrm= iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	select	@idLogType=	case when @idCmd = 0x8D then 199		-- audio quit
							when @idCmd = 0x8A then 197			-- audio grant
							when @idCmd = 0x88 then 196			-- audio busy
							else					195 end		-- audio request
		,	@siIdx=	@siPri & 0x03FF


	if	@siIdx > 0
		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
	else
		select	@idCall= 0				--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed	---	, @iAID, @tiStype, @idCall0

		insert	tbEvent8A	(  idEvent,  tiSrcJAB,  tiSrcLAB,  tiDstJAB,  tiDstLAB,  siPri,  tiFlags,  siIdx )
				values		( @idEvent, @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB, @siPri, @tiFlags, @siIdx )

		--	this one is really not origin, but parent - audio is not being healed
		select	@idOrigin= idEvent,	@dtOrigin= dtEvent
			from	tbEvent_A	with (nolock)
			where	cSys = @cDstSys
				and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiBtn
				and	idCall = @idCall		--	7.05.4976
		---		and	bActive > 0				--	6.05 (6.04 in 84!):	audio events ignore active/inactive state

		if	@idOrigin	is not null
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
				where	idEvent = @idEvent

/*			if	@idCmd = 0x89
				update	tbEvent		set	idLogType= 195						-- audio request
					where	idEvent = @idEvent

			else if	@idCmd = 0x88
				update	tbEvent		set	idLogType= 196						-- audio busy
					where	idEvent = @idEvent

			else
*/			if	@idCmd = 0x8A		-- AUDIO GRANT == voice response
			begin
				update	tbEvent_A	set	bAudio= 1							-- connected
					where	idEvent = @idOrigin

				select	@dtOrigin= tOrigin	--, @idParent= idParent
					from	tbEvent		with (nolock)
					where	idEvent = @idEvent

--				update	tbEvent		set	idLogType= 197						-- audio connected
--					where	idEvent = @idEvent

				update	tbEvent_C	set	idEvtVo= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idOrigin		and	idEvtVo is null		-- there should be only one, but just in case - use only 1st one
			end

			else if	@idCmd = 0x8D
			begin
				update	tbEvent_A	set	bAudio= 0							-- disconnected
					,	dtExpires=	case when bActive > 0 then dtExpires
										else dateadd(ss, @iExpNrm, getdate( )) end
					where	idEvent = @idOrigin

				update	tbEvent		set	idLogType= 199						-- audio quit
					where	idEvent = @idEvent
			end
		end
		else	-- no origin found
		begin
			update	tbEvent		set	idOrigin= @idEvent,	tOrigin= '0:0:0' --,	idLogType= 198	-- audio dialed
								,	idParent= @idEvent,	tParent= '0:0:0'	--	7.05.4976
/*				,	idLogType=	case when @idCmd = 0x8D then 199			-- audio quit
									when @idCmd = 0x89 then 195				-- audio request
									when @idCmd = 0x88 then 196				-- audio busy
									else					197 end			-- audio connected
*/				,	@idDstDvc= idSrcDvc,	@dtOrigin= dtEvent
				where	idEvent = @idEvent
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x8C, 0x8E]
--	7.05.5205	* prEvent_Ins args
--	5.01	encryption added
--	4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	1.00
alter proc		dbo.prEvent8C_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint		-- ignored	-- source G-ID - gateway
,	@tiSrcJID	tinyint		-- ignored	-- source J-ID - J-bus
,	@tiSrcRID	tinyint				-- source R-ID - R-bus

,	@tiInOut1	tinyint				-- A-bed input status
,	@tiInOut2	tinyint				-- A-bed DIN status
,	@tiInOut3	tinyint				-- B-bed input status
,	@tiInOut4	tinyint				-- B-bed DIN status
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

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, @tiSrcRID, null
				,	null, null, null, null, null, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
		---		,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		insert	tbEvent8C	( idEvent, tiInOut1, tiInOut2, tiInOut3, tiInOut4 )
				values		( @idEvent, @tiInOut1, @tiInOut2, @tiInOut3, @tiInOut4 )

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
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
		,		@idRoom		smallint
		,		@idCall		smallint
		,		@siIdx		smallint
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@cBed		char( 1 )
		,		@idLogType	tinyint

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbCfgBed	with (nolock)	where	tiBed = @tiBed

	select	@idLogType=	case when @tiSvcSet > 0  and  @tiSvcClr = 0 then 201	-- set svc
							when @tiSvcSet = 0  and  @tiSvcClr > 0 then 203		-- clr svc
							else 202 end										-- set/clr
		,	@siIdx=	@siPri & 0x03FF

	if	@siIdx > 0
		exec	dbo.prCall_GetIns	@siIdx, @sCall, @idCall out
	else
		select	@idCall= 0				--	INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out		--	no need to call

	select	@idOrigin= idEvent, @dtOrigin= dtEvent
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

		insert	tbEvent95	( idEvent,  tiSvcSet,  tiSvcClr )
				values		( @idEvent, @tiSvcSet, @tiSvcClr )

		update	tbEvent		set	idOrigin= @idOrigin,	tOrigin= dtEvent - @dtOrigin
			where	idEvent = @idEvent

/*		if	@tiSvcSet > 0  and  @tiSvcClr = 0
			update	tbEvent		set	idLogType= 201		-- set svc
				where	idEvent = @idEvent

		else if	@tiSvcSet = 0  and  @tiSvcClr > 0
			update	tbEvent		set	idLogType= 203		-- clear svc
				where	idEvent = @idEvent

		else --	if	@tiSvcSet > 0  and  @tiSvcClr > 0
			update	tbEvent		set	idLogType= 202		-- set/clr
				where	idEvent = @idEvent
*/
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x98, 0x9A, 0x9E, 0x9C, 0xA4, 0xAD, 0xAF]
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
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint

	set	nocount	on

	if	len( @sPatient ) > 0
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
	else	if	len( @sDoctor ) > 0
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
		---		,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		insert	tbEvent98	( idEvent,  tiMulti,  idPatient,  idDoctor )	--, tiFlags
				values		( @idEvent, @tiMulti, @idPatient, @idDoctor )	--, @tiFlags

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x99]
--	7.05.5205	* prEvent_Ins args
--	6.05	optimize
--	5.01	encryption added
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	2.01	- .siPriNew, .siPriOld
--	1.00
alter proc		dbo.prEvent99_Ins
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
,	@siIdxOld	smallint			-- old priority
,	@siIdxNew	smallint			-- new priority
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

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	null, null, @tiBtn
		---		,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		insert	tbEvent99	( idEvent,  siIdxOld,  siIdxNew )	--, tiDstBtn
				values		( @idEvent, @siIdxOld, @siIdxNew )	--, @tiDstBtn

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x9B]
--	7.05.5205	* prEvent_Ins args
--	6.05	optimize
--	5.01	encryption added
--	4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	1.00
alter proc		dbo.prEvent9B_Ins
(
	@idCmd		tinyint				-- command look-up FK
,	@tiLen		tinyint				-- message length
,	@iHash		int					-- message 32-bit hash
,	@vbCmd		varbinary( 256 )	-- entire message
,	@cSrcSys	char( 1 )			-- source system
,	@tiSrcGID	tinyint				-- source G-ID - gateway
,	@tiSrcJID	tinyint		-- ignored	-- source J-ID - J-bus
,	@tiSrcRID	tinyint		-- ignored	-- source R-ID - R-bus

,	@tiYearMSB	tinyint
,	@tiYearLSB	tinyint
,	@tiMonth	tinyint
,	@tiDay		tinyint
,	@tiHour		tinyint
,	@tiMinute	tinyint
,	@tiSecond	tinyint
,	@tiMulti	tinyint
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

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, null, null, null
				,	null, null, null, null, null, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
		---		,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		insert	tbEvent9B	( idEvent,  tiYearMSB,  tiYearLSB,  tiMonth,  tiDay,  tiHour,  tiMinute,  tiSecond,  tiMulti )
				values		( @idEvent, @tiYearMSB, @tiYearLSB, @tiMonth, @tiDay, @tiHour, @tiMinute, @tiSecond, @tiMulti )

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0xAB]
--	7.05.5205	* prEvent_Ins args
--	7.02	* .tiCvrgAX -> tiCvrgX
--	6.05	optimize
--	5.01	encryption added
--			+ .tbNtWant
--	4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--			consolidated A7(A5-A7), A9(A8,A9,AA,AC) in tbEventAB
--	3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	2.03
alter proc		dbo.prEventAB_Ins
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
,	@sSrcDvc	varchar( 16 )		-- source name
,	@sDstDvc	varchar( 16 )		-- destination name
,	@tiNtGrpID	tinyint				-- group ID (1-128)
,	@tiNtStat	tinyint				-- 0xAB: mask of currently owned consoles
,	@tiNtWant	tinyint				-- 0xA9: any or all of desired ownership bits
--,	@sDevice	varchar( 16 )		-- device name
,	@tiCvrg0	tinyint				-- coverage area 0
,	@tiCvrg1	tinyint				-- coverage area 1
,	@tiCvrg2	tinyint				-- coverage area 2
,	@tiCvrg3	tinyint				-- coverage area 3
,	@tiCvrg4	tinyint				-- coverage area 4
,	@tiCvrg5	tinyint				-- coverage area 5
,	@tiCvrg6	tinyint				-- coverage area 6
,	@tiCvrg7	tinyint				-- coverage area 7
,	@iFilter0	int					-- ownership filter bits for CA0
,	@iFilter1	int					-- ownership filter bits for CA1
,	@iFilter2	int					-- ownership filter bits for CA2
,	@iFilter3	int					-- ownership filter bits for CA3
,	@iFilter4	int					-- ownership filter bits for CA4
,	@iFilter5	int					-- ownership filter bits for CA5
,	@iFilter6	int					-- ownership filter bits for CA6
,	@iFilter7	int					-- ownership filter bits for CA7
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

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
		---		,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		insert	tbEventAB	( idEvent,  tiNtGrpID,  tiNtStat,  tiNtWant,
							tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
							iFilter0,  iFilter1,  iFilter2,  iFilter3,  iFilter4,  iFilter5,  iFilter6,  iFilter7 )
				values		( @idEvent, @tiNtGrpID, @tiNtStat, @tiNtWant,
							@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
							@iFilter0, @iFilter1, @iFilter2, @iFilter3, @iFilter4, @iFilter5, @iFilter6, @iFilter7 )

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0xB1]
--	7.05.5205	* prEvent_Ins args
--	6.05	optimize
--	5.01	encryption added
--	4.01
alter proc		dbo.prEventB1_Ins
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
,	@tiDstGrp	tinyint				-- destination group (1-255) [coverage area]
,	@tiJAB		tinyint				-- local J-bus audio channel (1-8)
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

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, null
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
		---		,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

		insert	tbEventB1	( idEvent,  tiDstGrp,  tiJAB )
				values		( @idEvent, @tiDstGrp, @tiJAB )

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
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
				when idDvcType = 3 then 204		-- phone
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
--	7.05.5212	* left join vwStaff
--	7.05.5095
alter view		dbo.vwEvent41
	with encryption
as
select	e.idEvent, h.dtEvent, h.idCmd, h.cSrcSys, h.tiSrcGID, h.tiSrcJID	--, h.tiSrcRID,	h.tiBtn
	,	h.idParent	--, h.idOrigin
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
	left join	vwStaff	u	with (nolock)	on	u.idUser = e.idUser
	left join	tbCfgBed b	with (nolock)	on	b.tiBed = h.tiBed
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
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
		,		@tiPriCA0	tinyint
		,		@tiPriCA1	tinyint
		,		@tiPriCA2	tinyint
		,		@tiPriCA3	tinyint
		,		@tiPriCA4	tinyint
		,		@tiPriCA5	tinyint
		,		@tiPriCA6	tinyint
		,		@tiPriCA7	tinyint

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
--	-		exec	prDevice_UpdRoomBeds7980	0, @idRoom, null, @sRoom, @sDial, @idUnitP, @idUnitA
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
			begin
				insert	tbRoomBed	(  idRoom, cBed, tiBed )
						values		( @idRoom, null, 0xFF )
			end
--	-		exec	prDevice_UpdRoomBeds7980	1, @idRoom, ' ', @sRoom, @sDial, @idUnitP, @idUnitA
			select	@sBeds=		null			--	7.05.5212
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

		update	tbRoom		set	dtUpdated= getdate( ), siBeds= @siBeds, sBeds= @sBeds, tiSvc= null
			where	idRoom = @idRoom
		update	tbRoomBed	set	dtUpdated= getdate( ), tiSvc= null				--	7.05.5098
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
--	reset to null
begin tran
	update	tbRoom	set	sBeds=	null
		where	siBeds < 1	and	sBeds is not null
commit
go
--	----------------------------------------------------------------------------
--	Updates a staff level
--	7.05.5219
create proc		dbo.prStfLvl_Upd
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

	select	@s= 'StfLvl_U( [' + isnull(cast(@idStfLvl as varchar), '?') + '], n="' + @sStfLvl + '", k=' + isnull(cast(@iColorB as varchar), '?') + ' )'

	begin	tran

		update	tbStfLvl	set	sStfLvl= @sStfLvl, iColorB= @iColorB	--, dtUpdated= getdate( )
			where	idStfLvl = @idStfLvl

		exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
end
go
grant	execute				on dbo.prStfLvl_Upd					to [rWriter]
grant	execute				on dbo.prStfLvl_Upd					to [rReader]
go
--	----------------------------------------------------------------------------
--	7.05.5220	* .sTeams: vc(32) -> vc(255)
if	not	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'sTeams' and max_length = 255)
begin
	begin tran
		alter table	dbo.tb_User		alter column
			sTeams		varchar( 255 )	null		-- tmp: teams
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
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
,	@sTeams		varchar( 255 )
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

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", i="' + isnull(cast(@sStaffID as varchar), '?') + '", l=' + isnull(cast(@idStfLvl as varchar), '?') +
				', b="' + isnull(cast(@sBarCode as varchar), '?') + '", on=' + isnull(cast(@bOnDuty as varchar), '?') +
				', a=' + cast(@bActive as varchar)
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			select	@s= 'User_I( ' + @s + ' ) = '

			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff		--,  dtLastAct
							,  sStaffID,  idStfLvl,  sBarCode,  sUnits,  sTeams,  bOnDuty,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '		--, @dtLastAct, @sStaff
							, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @sTeams, @bOnDuty, @bActive )
			select	@idOper=	scope_identity( )

			select	@s= @s + cast(@idOper as varchar)
				,	@k=	237
		end
		else
		begin
			select	@s= 'User_U( ' + @s + ' )'

			update	tb_User	set	sUser= @sUser, iHash= @iHash, tiFails= @tiFails, sFrst= @sFrst
						,	sMidd= @sMidd, sLast= @sLast, sEmail= @sEmail, sDesc= @sDesc	--, dtLastAct= @dtLastAct, sStaff= @sStaff
						,	sStaffID= @sStaffID, idStfLvl= @idStfLvl, sBarCode= @sBarCode, sUnits= @sUnits, sTeams= @sTeams, bOnDuty= @bOnDuty
						,	bActive= @bActive, dtUpdated= getdate( )
				where	idUser = @idOper

			select	@k=	238
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

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a device
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
,	@sBarCode	varchar( 32 )
,	@sDial		varchar( 16 )
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
--	Inserts or updates a given badge
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
				where	idBadge = @idBadge

			update	tbDvc		set	bActive= 1, dtUpdated= getdate( )
				where	idDvc = @idBadge
		end
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
--	Deactivates all badges
--	7.05.5222	+ updating tbDvc.bActive
--	7.05.5087
alter proc		dbo.prRtlsBadge_Init
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		update	tbRtlsBadge		set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1

		update	d	set	bActive= 0, dtUpdated= getdate( )
			from	tbDvc	d
			join	tbRtlsBadge	b	on	b.idBadge = d.idDvc
			where	d.bActive = 1

		select	@s= 'Badge_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.05.5226
create view		dbo.vwShift
	with encryption
as
select	sh.idUnit, u.sUnit
	,	sh.idShift, tiIdx, sShift, tBeg, tEnd, tiRouting, tiNotify
	,	sh.idUser, s.idStfLvl, s.sStaffID, s.sStaff, s.bOnDuty
	,	sh.bActive, sh.dtCreated, sh.dtUpdated
	from	tbShift	sh	with (nolock)
	join	tbUnit	u	with (nolock)	on	u.idUnit = sh.idUnit
	left join	vwStaff	s	with (nolock)	on	s.idUser = sh.idUser
go
grant	select, insert, update			on dbo.vwShift			to [rWriter]
grant	select							on dbo.vwShift			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given shift
--	7.05.5226
create proc		dbo.prShift_Upd
(
	@idShift	smallint
,	@sShift		varchar( 8 )
,	@tBeg		time( 0 )
,	@tEnd		time( 0 )
,	@tiRouting	tinyint
,	@tiNotify	tinyint
,	@idUser		int
,	@bActive	bit
)
	with encryption
as
begin
--	set	nocount	on

	begin	tran

			update	tbShift		set	sShift= @sShift, tBeg= @tBeg, tEnd= @tEnd, tiRouting= @tiRouting
						,	tiNotify= @tiNotify, idUser= @idUser, bActive= @bActive, dtUpdated= getdate( )
				where	idShift = @idShift

	commit
end
go
grant	execute				on dbo.prShift_Upd					to [rWriter]
--grant	execute				on dbo.prShift_Upd					to [rReader]
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
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
--,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
--,	@sMachine	varchar( 32 )		-- client computer's name

,	@idUser		int				out	-- null if attempt failed
,	@sStaff		varchar( 16 )	out	-- full-name
--,	@sFrst		varchar( 32 )	out	-- first-name
--,	@sLast		varchar( 32 )	out	-- last-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@iHass		int
		,		@bActive	bit
		,		@bLocked	bit
		,		@idLogType	tinyint
		,		@tiFails	tinyint
		,		@tiMaxAtt	tinyint
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )

	set	nocount	on

	select	@tiMaxAtt= cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr= sIpAddr, @sMachine= sMachine
		from	tb_Sess		with (nolock)
		where	idSess = @idSess

	select	@s= '@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser= idUser, @iHass= iHash, @bActive= bActive, @tiFails= tiFails, @sStaff= sStaff
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType=	222,	@s=	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

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

		begin	tran

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

	begin	tran

		update	tb_Sess		set	dtLastAct= getdate( ), idUser= @idUser
			where	idSess = @idSess
		update	tb_User		set	dtLastAct= getdate( ), tiFails= 0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s

	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	fix missing team-priority visualization
begin tran
	update	t	set	t.sCalls= cast(p.siIdx as varchar)
		from	dbo.tbTeam	t
		join	dbo.tbTeamPri	p	on	p.idTeam = t.idTeam
		where	t.sCalls is null
commit
go
--	----------------------------------------------------------------------------
--	fix leftovers
begin tran
	update	dbo.tb_User		set	sBarCode= null
		where	sBarCode = sUnits
commit
go
--	----------------------------------------------------------------------------
--	'All Units' -> 'ID1,ID2,ID3'
declare		@idUnit		smallint
	,		@sUnits		varchar( 255 )

select	@sUnits=	''

declare		cur		cursor fast_forward for
	select	idUnit
		from	tbUnit
		where	bActive > 0		and	idShift > 0
		order	by	sUnit

open	cur
fetch next from	cur	into	@idUnit
while	@@fetch_status = 0
begin
--	print	@idUnit
	select	@sUnits=	@sUnits + ',' + cast(@idUnit as varchar)

	fetch next from	cur	into	@idUnit
end
close	cur
deallocate	cur

if	len(@sUnits) > 0	select	@sUnits=	substring( @sUnits, 2, len(@sUnits)-1 )

begin tran

	update	dbo.tbDvc		set	sUnits=	@sUnits		where	sUnits = 'All Units'
	update	dbo.tbTeam		set	sUnits=	@sUnits		where	sUnits = 'All Units'
	update	dbo.tb_User		set	sUnits=	@sUnits		where	sUnits = 'All Units'	or	idUser < 16

	exec	pr_UserUnit_Set

commit
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
--	7.05.5233	optimized
--	7.05.5021
alter proc		dbo.pr_Role_InsUpd
(
	@idUser		int					-- user, performing the action
,	@idRole		smallint		out	-- role, acted upon
,	@sRole		varchar( 16 )
,	@sDesc		varchar( 255 )
,	@bActive	bit
,	@sUnits		varchar( 255 )
)
	with encryption, exec as owner
as
begin
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits

	select	@s= '[' + isnull(cast(@idRole as varchar), '?') + '], n="' + @sRole + '", d=' + isnull(cast(@sDesc as varchar), '?') +
				', a=' + cast(@bActive as varchar)
	begin	tran

		if	not exists	(select 1 from tb_Role where idRole = @idRole)
		begin
			select	@s= 'Role_I( ' + @s + ' ) = ',	@k=	242

			insert	tb_Role	(  sRole,  sDesc,  bActive )
					values	( @sRole, @sDesc, @bActive )
			select	@idRole=	scope_identity( )

			select	@s= @s + cast(@idRole as varchar)
		end
		else
		begin
			select	@s= 'Role_U( ' + @s + ' )',		@k=	243

			update	tb_Role	set	sRole= @sRole, sDesc= @sDesc, bActive= @bActive, dtUpdated= getdate( )
				where	idRole = @idRole
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

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
--	7.05.5233	+ [249]
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 249)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 249, 8, 8, 'Deleted record' )			--	7.05.5233
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates or deletes an access permission
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
	declare		@k	tinyint
			,	@s	varchar( 255 )

	set	nocount	on

	select	@s= 'm=' + isnull(cast(@idModule as varchar), '?') + ', f=' + isnull(cast(@idFeature as varchar), '?') +
				', r=' + isnull(cast(@idRole as varchar), '?') + ', a=' + isnull(cast(@tiAccess as varchar), '?') + ' )'
	begin	tran

		if	@tiAccess > 0
		begin
			if	not exists	(select 1 from tb_Access where idModule = @idModule and idFeature = @idFeature and idRole = @idRole)
			begin
				select	@s= 'Perm_I( ' + @s,	@k=	247

				insert	tb_Access	(  idModule,  idFeature,  idRole,  tiAccess )
						values		( @idModule, @idFeature, @idRole, @tiAccess )
			end
			else
			begin
				select	@s= 'Perm_U( ' + @s,	@k=	248

				update	tb_Access	set	dtUpdated= getdate( ), tiAccess= @tiAccess
					where	idModule = @idModule and idFeature = @idFeature and idRole = @idRole
			end
		end
		else
		begin
				select	@s= 'Perm_D( ' + @s,	@k=	249

				delete	tb_Access
					where	idModule = @idModule and idFeature = @idFeature and idRole = @idRole
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s
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
		from	tb_Module	m	with (nolock)
		join	tb_Feature	f	with (nolock)	on	f.idModule = m.idModule
		left join	tb_Access a	with (nolock)	on	a.idModule = f.idModule	and	a.idFeature = f.idFeature	and	a.idRole = @idRole
end
go
grant	execute				on dbo.pr_Access_GetByRole			to [rWriter]
grant	execute				on dbo.pr_Access_GetByRole			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns details for all roles
--	7.05.5234
create proc		dbo.pr_Role_GetAll
(
	@bActive	bit= null			-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	on
	select	idRole, sRole, sDesc, bActive, dtCreated, dtUpdated
		from	tb_Role		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
	--		and	idRole > 15			--	or 15?	protect internal accounts
end
go
grant	execute				on dbo.pr_Role_GetAll				to [rWriter]
grant	execute				on dbo.pr_Role_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns units for a given role
--	7.05.5234
create proc		dbo.pr_Role_GetUnits
(
	@idRole		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	idUnit
		from	tb_RoleUnit	with (nolock)
		where	idRole = @idRole
end
go
grant	execute				on dbo.pr_Role_GetUnits				to [rWriter]
grant	execute				on dbo.pr_Role_GetUnits				to [rReader]
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
	select	m.idModule, min(m.sDesc), sum(a.tiAccess), count(*)
		from	tb_Module	m	with (nolock)
		join	tb_Feature	f	with (nolock)	on	f.idModule = m.idModule
		left join	tb_Access a	with (nolock)	on	a.idModule = f.idModule	and	a.idFeature = f.idFeature	and	a.idRole = @idRole
		group	by	m.idModule
end
go
grant	execute				on dbo.pr_Role_GetPerms				to [rWriter]
grant	execute				on dbo.pr_Role_GetPerms				to [rReader]
go
--	----------------------------------------------------------------------------
--	Logs out a user
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
--,	@idUser		int
--,	@sIpAddr	varchar( 40 )
--,	@sMachine	varchar( 32 )
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idUser		int
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )

	set	nocount	on

	select	@idUser= idUser, @sIpAddr= sIpAddr, @sMachine= sMachine
		from	tb_Sess
		where	idSess = @idSess

	if	@idUser > 0
	begin
		begin	tran

			update	tb_Sess		set	dtLastAct= getdate( ), idUser= null
				where	idSess = @idSess

			select	@s= '@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Cleans-up a session
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
	@idSess		int			--	0 = application-end (delete all sessions)
,	@bLog		bit		=1	--	log logout (for individual session)?
,	@idModule	tinyint	=null	--	indicates app, required if @idSess=0
)
	with encryption
as
begin
	declare		@tiTout		tinyint
		,		@dtLastAct	datetime
--		,		@idUser		smallint
--		,		@sIpAddr	varchar( 40 )
--		,		@sMachine	varchar( 32 )
--		,		@idModule	tinyint

	set	nocount	on
	begin	tran

		if	@idSess > 0		-- sess-end
		begin
			if	@bLog > 0
			begin
				select	@tiTout= cast( iValue as tinyint )	from	tb_OptSys	where	idOption = 1
				select	@dtLastAct= dateadd( mi, @tiTout, dtLastAct )	--, @idUser= idUser, @sIpAddr= sIpAddr, @sMachine= sMachine
					from	tb_Sess		with (nolock)
					where	idSess = @idSess
				select	@tiTout=	case when dateadd( ss, -10, @dtLastAct ) < getdate( ) then 230 else 229 end

				exec	dbo.pr_User_Logout	@idSess, @tiTout	--, @idUser, @sIpAddr, @sMachine
			end

			exec	dbo.pr_Sess_Clr		@idSess
			delete from	tb_Sess			where	idSess = @idSess
		end
		else				-- app-end
		begin
			declare	cur		cursor fast_forward for
				select	idSess	--, idUser, sIpAddr, sMachine
					from	tb_Sess
					where	idModule = @idModule

			open	cur
			fetch next from	cur	into	@idSess	--, @idUser, @sIpAddr, @sMachine
			while	@@fetch_status = 0
			begin
				exec	dbo.pr_User_Logout	@idSess, 230	--, @idUser, @sIpAddr, @sMachine
				exec	dbo.pr_Sess_Clr		@idSess
				delete from	tb_Sess			where	idSess = @idSess
			
				fetch next from	cur	into	@idSess	--, @idUser, @sIpAddr, @sMachine
			end
			close	cur
			deallocate	cur
	--	-	exec	dbo.pr_Sess_Clr		null
	--	-	delete from	tb_Sess
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	'All Teams' -> 'ID1,ID2,ID3'
declare		@idTeam		smallint
	,		@sTeams		varchar( 255 )

select	@sTeams=	''

declare		cur		cursor fast_forward for
	select	idTeam
		from	tbTeam
		where	bActive > 0
		order	by	sTeam

open	cur
fetch next from	cur	into	@idTeam
while	@@fetch_status = 0
begin
--	print	@idTeam
	select	@sTeams=	@sTeams + ',' + cast(@idTeam as varchar)

	fetch next from	cur	into	@idTeam
end
close	cur
deallocate	cur

if	len(@sTeams) > 0	select	@sTeams=	substring( @sTeams, 2, len(@sTeams)-1 )

begin tran

	update	dbo.tb_User		set	sTeams=	@sTeams		where	sTeams = 'All Teams'

commit
go
--	----------------------------------------------------------------------------
--	7.05.5246
begin tran
	if	not	exists	(select 1 from dbo.tb_Feature where idModule = 62)
	begin
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	00,	'Assign - RoomBeds' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	01,	'Assign - Devices' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	02,	'Assign - Teams' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	10,	'Admin - Facility' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	11,	'Admin - Units' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	12,	'Admin - Roles' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	13,	'Admin - Staff' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	14,	'Admin - Devices' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	15,	'Admin - Badges' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  62,	16,	'Admin - Teams' )
	end
	if	not	exists	(select 1 from dbo.tb_Feature where idModule = 92)
	begin
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  02, 'Report - System Activity' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  03, 'Report - Call Stats (Sum)' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  04, 'Report - Call Stats (Dtl)' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  05, 'Report - Call Activity (Sum)' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  06, 'Report - Call Activity (Dtl)' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  07, 'Report - Staff Assignment' )
		insert	dbo.tb_Feature ( idModule, idFeature, sFeature )	values	(  92,  08, 'Report - Staff Coverage' )
	end

	if	not	exists	(select 1 from dbo.tb_Access where idRole = 2)
		insert	dbo.tb_Access	( idModule, idFeature, idRole, tiAccess )
			select	idModule, idFeature, 2, 1
				from	tb_Feature

	if	not	exists	(select 1 from dbo.tb_RoleUnit where idRole = 2)
		insert	dbo.tb_RoleUnit	( idRole, idUnit )
			select	2, idUnit
				from	tbUnit
				where	bActive > 0		and	idShift > 0

	update	tb_Role		set	sRole= 'Public'
		where	idRole = 1
commit
go
--	----------------------------------------------------------------------------
--	Returns available staff for given unit(s)
--	7.05.5246	order by sStaffID ->	idStfLvl desc, sStaff
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
		left join	tbDvc	ph	with (nolock)	on	ph.idUser = st.idUser	and	ph.idDvcType = 3	and	ph.bActive > 0
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
--	Imports a staff assignment definition
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
			select	@idStfAssn= idStfAssn
				from	tbStfAssn	with (nolock)
				where	bActive > 0		and	idRoom = @idRoom	and	tiBed = @tiBed	and	idShift = @idShift	and	tiIdx = @tiIdx

			if	@idStfAssn > 0
				update	tbStfAssn	set	idUser= @idUser, bActive= @bActive, dtUpdated= @dtUpdated	--, dtCreated= @dtCreated
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
--	Returns access permissions for a given role
--	7.05.5248
create proc		dbo.pr_Access_GetByUser
(
	@idModule	tinyint
,	@idUser		int
)
	with encryption
as
begin
	select	a.idFeature,	max(a.tiAccess)	[tiAccess]
		from	tb_UserRole	ur	with (nolock)
		join	tb_Access	a	with (nolock)	on	a.idRole = ur.idRole
		where	a.idModule = @idModule	and	ur.idUser = @idUser
		group	by	a.idFeature
end
go
grant	execute				on dbo.pr_Access_GetByUser			to [rWriter]
grant	execute				on dbo.pr_Access_GetByUser			to [rReader]
go


if	not	exists	( select 1 from tb_Version where idVersion = 705 )
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 705,	0, getdate( ), getdate( ),	'_' )
go
update	tb_Version	set	dtCreated= '2014-05-15', siBuild= 5248, dtInstall= getdate( )
	,	sVersion= '7.05.5248 - schema refactored, 7980 tables replaced, 7980cw replaced'
	where	idVersion = 705
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.05.5248'
	where	idModule = 1
go

checkpoint
go

use [master]
go
