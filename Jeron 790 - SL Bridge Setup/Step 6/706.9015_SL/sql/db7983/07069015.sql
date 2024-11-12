--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2024-Apr-17		.8873
--						* tb_Module		+ [31,32]
--		2024-May-02		.8888
--						* tb_Option		+ [60..64]
--		2024-May-03		.8889
--						* tbHlCall:		.sSend -> sTxt, .bSend -> bUse	(tdHlCall_Send -> tdHlCall_Use, prHlCall_GetAll, prHlCall_Upd, prHlEvent_Get)
--						* tbHlRoomBed:	.sSend -> sLoc, .bSend -> bUse	(tdHlRoomBed_Send -> tdHlRoomBed_Use, prHlRoomBed_GetAll, prHlRoomBed_Upd, prHlEvent_Get)
--		2024-May-06		.8892
--						+ tbIbedLoc, 
--						+ vwIbedLoc
--						+ prIbedLoc_GetAll, prIbedLoc_InsUpd, prIbedLoc_UpdRoom
--		2024-May-14		.8900
--						* vwRoomBed
--						+ prRoomBed_GetAll
--						+ vwCfgBtn
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
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 9015 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.9015', 18, 0 )
go


go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwCfgBtn')
	drop view	dbo.vwCfgBtn
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Min')
	drop proc	dbo.prHealth_Min
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_GetRoom')
	drop proc	dbo.prIbedLoc_GetRoom
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_UpdRoom')
	drop proc	dbo.prIbedLoc_UpdRoom
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_InsUpd')
	drop proc	dbo.prIbedLoc_InsUpd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prIbedLoc_GetAll')
	drop proc	dbo.prIbedLoc_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwIbedLoc')
	drop view	dbo.vwIbedLoc
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbIbedLoc')
	drop table	dbo.tbIbedLoc
go
--	----------------------------------------------------------------------------
--	7.06.8873	+ [31,32]
if	not	exists	(select 1 from dbo.tb_Module where idModule = 31)
begin
	begin tran
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  31, 'J7974is',	4,	248,	0,	'7974 iBed Interface Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	(  32, 'J7974cw',	2,	248,	0,	'7974 iBed Interface Configurator' )
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8888	+ [60..65]
if	not	exists	(select 1 from dbo.tb_Option where idOption = 60)
begin
	begin tran
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 60, 167, 'Stryker iBed date/time format' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 61,  56, 'Stryker iBed data discard age, s' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 62,  56, 'Stryker iBed expiration age, s' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 63,  56, 'Stryker iBed attributes to track' )	--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 64,  56, 'Stryker iBed fowler min' )			--	7.06.8888
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 65,  56, 'Stryker iBed fowler max' )			--	7.06.8888
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 60, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 61, 660 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 62, 60 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 63, 0 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 64, -1 )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 65, 91 )
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8889	* .sSend -> sTxt
--				* .bSend -> bUse	(tdHlCall_Send -> tdHlCall_Use)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbHlCall') and name = 'bSend')
begin
	begin tran
		exec sp_rename 'tbHlCall.sSend',	'sTxt',		'column'
		exec sp_rename 'tbHlCall.bSend',	'bUse',		'column'
		exec sp_rename 'tdHlCall_Send',		'tdHlCall_Use',		'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.8889	* .sSend -> sTxt, .bSend -> bUse
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
		,	bUse, sTxt, c.dtUpdated
		from	dbo.tbHlCall	c	with (nolock)
		join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= c.siIdx
		where	@siFlags is null	or	siFlags & @siFlags	= @siFlags
--		where	@bEnabled = 0	or	siFlags & 0x02 > 0
		order	by	2 desc		--	p.siIdx
end
go
--	----------------------------------------------------------------------------
--	Updates an HL7 exported call-priority
--	7.06.8889	* .sSend -> sTxt, .bSend -> bUse
--	7.06.8586
alter proc		dbo.prHlCall_Upd
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
--	----------------------------------------------------------------------------
--	7.06.8889	* .sSend -> sLoc
--				* .bSend -> bUse	(tdHlRoomBed_Send -> tdHlRoomBed_Use)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbHlRoomBed') and name = 'bSend')
begin
	begin tran
		exec sp_rename 'tbHlRoomBed.sSend',	'sLoc',		'column'
		exec sp_rename 'tbHlRoomBed.bSend',	'bUse',		'column'
		exec sp_rename 'tdHlRoomBed_Send',	'tdHlRoomBed_Use',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8907	+ .dtExpires
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoomBed') and name = 'dtExpires')
begin
	begin tran
		alter table	dbo.tbRoomBed	add
			dtExpires	smalldatetime	null		-- expiration window for iBed state (tb_OptSys[60])
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns room-beds, ordered to be loadable into a table
--	7.06.8889	* .sSend -> sLoc, .bSend -> bUse
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
--	----------------------------------------------------------------------------
--	Updates an HL7 exported room-bed
--	7.06.8889	* .sSend -> sLoc, .bSend -> bUse
--	7.06.8586
alter proc		dbo.prHlRoomBed_Upd
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
--	----------------------------------------------------------------------------
--	Returns all items necessary for HL7 export of an event
--	7.06.8889	* tbHlCall.sSend -> sTxt, .bSend -> bUse
--				* tbHlRoomBed.sSend -> sLoc, .bSend -> bUse
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
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	7.06.8900	+ r.sSGJR, r.sSGJ, d.bActive, d.dtCreated
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
select	r.idUnit, r.sUnit,	rb.idRoom, r.cStn, r.sRoom, r.sSGJR, r.sSGJ, r.sQnRoom,		d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, b.cBed
	,	rb.idEvent,	rb.tiSvc, rb.tiIbed,	p.idPatient, p.sPatient, p.cGndr, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idUser1,  a1.idLvl as idLvl1,  a1.sStfID as sStfId1,  a1.sStaff as sStaff1,  a1.bDuty as bDuty1,  a1.dtDue as dtDue1
	,	rb.idUser2,  a2.idLvl as idLvl2,  a2.sStfID as sStfId2,  a2.sStaff as sStaff2,  a2.bDuty as bDuty2,  a2.dtDue as dtDue2
	,	rb.idUser3,  a3.idLvl as idLvl3,  a3.sStfID as sStfId3,  a3.sStaff as sStaff3,  a3.bDuty as bDuty3,  a3.dtDue as dtDue3
	,	r.idUserG,  r.idLvlG,  r.sStfIdG,  r.sStaffG,  r.bDutyG,  r.dtDueG
	,	r.idUserO,  r.idLvlO,  r.sStfIdO,  r.sStaffO,  r.bDutyO,  r.dtDueO
	,	r.idUserY,  r.idLvlY,  r.sStfIdY,  r.sStaffY,  r.bDutyY,  r.dtDueY
	,	d.bActive, d.dtCreated, rb.dtUpdated
	from	dbo.tbRoomBed	rb	with (nolock)
	join	dbo.tbCfgStn	d	with (nolock)	on	d.idStn		= rb.idRoom		and	d.bActive > 0
	join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= rb.idRoom
left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= rb.tiBed		---	and	b.bActive > 0	--	no need
left join	dbo.tbPatient	p	with (nolock)	on	p.idPatient	= rb.idPatient	--	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed
left join	dbo.tbDoctor	dc	with (nolock)	on	dc.idDoctor	= p.idDoctor
left join	dbo.vwStaff		a1	with (nolock)	on	a1.idUser	= rb.idUser1
left join	dbo.vwStaff		a2	with (nolock)	on	a2.idUser	= rb.idUser2
left join	dbo.vwStaff		a3	with (nolock)	on	a3.idUser	= rb.idUser3
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
--	7.06.8900	+ .cSys, .tiGID, .tiJID, .tiRID
--				- d.cStn, d.sStn, d.sSGJ
--	7.06.8892
create view		dbo.vwIbedLoc
	with encryption
as
select	r.idLoc, r.sLoc		--, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	r.idRoom	--, d.cStn, d.sStn, d.sSGJ, d.sSGJR
	,	d.cSys, d.tiGID, d.tiJID, d.tiRID
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
	@idLoc			smallint			-- id
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
				set		bActive =	1,	dtUpdated=	getdate( )
				where	sLoc = @sLoc
		else
		if	exists	( select 1 from dbo.tbIbedLoc with (nolock) where idLoc = @idLoc )
			update	dbo.tbIbedLoc
				set		bActive =	1,	dtUpdated=	getdate( ),	sLoc=	@sLoc
				where	idLoc = @idLoc
		else
			insert	dbo.tbIbedLoc	(  sLoc )
					values			( @sLoc )
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
	@idLoc			smallint			-- receiver id
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
--	clean up old values
update	dbo.tbRoomBed	set	tiIbed =	null
go
--	----------------------------------------------------------------------------
--	790 Station Buttons (skips masters that do not place calls, thus don't get inserted into tbRoom)
--	7.06.8900
create view		dbo.vwCfgBtn
	with encryption
as
select	r.idRoom, s.sSGJ, r.sQnRoom, 	t.idStn, s.tiRID, s.tiStype, s.sQnStn, t.tiBtn, t.siIdx, p.tiSpec, sCall, t.tiBed, b.cBed
	from	dbo.tbCfgBtn	t	with (nolock)
	join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx		= t.siIdx
	join	dbo.vwCfgStn	s	with (nolock)	on	s.idStn		= t.idStn	and	s.bActive > 0
	join	dbo.vwRoom		r	with (nolock)	on	r.idRoom	= s.idPrnt
left join	dbo.tbCfgBed	b	with (nolock)	on	b.tiBed		= t.tiBed
--	order	by	idRoom, idStn, tiBtn	--	siIdx
go
grant	select, insert, update			on dbo.vwCfgBtn			to [rWriter]
grant	select							on dbo.vwCfgBtn			to [rReader]
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
--	clean up old values
update		dbo.tbCfgStn	set	sUnits =	null	where	tiRID > 0	and	sUnits is not null
go
--	----------------------------------------------------------------------------
--	Updates DB stats (# of Size and Used pages - for data and tlog)
--	7.06.8959	* swapped recovery-model and service-name
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
				+	cast(cast(@iSizeL / 128.0 as decimal(18,1)) as varchar) + '(' + cast(cast(@iUsedL * 100.0 / @iSizeL as decimal(18)) as varchar) + '%) MiB'
				+	' [' + lower(recovery_model_desc) + '] @' + @@servicename
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
--	Clears all filter definitions
--	7.06.8959	* optimized logging
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
		select	@s =	'Flt( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a filter definition
--	7.06.8959	* optimized logging
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
--	----------------------------------------------------------------------------
--	Inserts a tone definition
--	7.06.8959	* optimized logging
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
--	----------------------------------------------------------------------------
--	Inserts a Dome Light Show definition
--	7.06.8959	* optimized logging
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
--	----------------------------------------------------------------------------
--	Clears all tone definitions
--	7.06.8959	* optimized logging
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
		select	@s =	'Tone( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
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

		select	@s =	'Call( ' + isnull(cast(@idCall as varchar), '?') + ', e=' + isnull(cast(@bEnabled as varchar), '?') +
						', v=' + convert(varchar, @tVoice, 108) + ', s=' + convert(varchar, @tStaff, 108) + ' )'
		exec	dbo.pr_Log_Ins	72, @idUser, null, @s, @idModule

	commit
end
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
--	----------------------------------------------------------------------------
--	Clears all location definitions
--	7.06.8959	* optimized logging
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
		select	@s =	'Loc( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
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
alter proc		dbo.prCfgStn_InsUpd
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
alter proc		dbo.prCfgStn_GetIns
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
--	----------------------------------------------------------------------------
--	Clears all master attributes
--	7.06.8959	* optimized logging
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
		select	@s =	'Mst( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	75, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a master attributes record
--	7.06.8959	* optimized logging
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
--	----------------------------------------------------------------------------
--	Clears all device button inputs
--	7.06.8959	* optimized logging
--	7.06.8446	* tbCfgDvcBtn -> tbCfgBtn,	prCfgDvcBtn_Clr -> prCfgBtn_Clr
--	7.06.7279	* optimized logging
--	7.06.5914	* 74->76
--	7.06.5905	* 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgBtn_Clr
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
alter proc		dbo.prCfgLoc_SetLvl
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
alter proc		dbo.prCfgStn_Init
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
--	----------------------------------------------------------------------------
--	Resets .bActive for all devices under a given GW, based on .bConfig set after Config download
--	7.06.8959	* optimized logging
--	7.06.8795	* prCfgDvc_UpdAct	->	prCfgStn_UpdAct
--	7.06.8791	* tbDevice	->	tbCfgStn	(vwDevice -> vwCfgStn, vwRoom)
--	7.06.7279	* optimized logging
--	7.06.5940	* optimize logging
--	7.06.5912	+ set current assigned staff
--	7.06.5907
alter proc		dbo.prCfgStn_UpdAct
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
alter proc		dbo.prCfgStn_UpdRmBd
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
--	----------------------------------------------------------------------------
--	7.06.8965	* [41-45,70-79,82].tiCat, .tiLvl
update	dbo.tb_LogType	set	tiCat=	64			where	idType = 41
update	dbo.tb_LogType	set	tiCat=	64			where	idType = 42
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 43
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 44
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 45
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 70
update	dbo.tb_LogType	set	tiCat=	32,	sType=	'Cfg: dbg'	where	idType = 71
update	dbo.tb_LogType	set	tiCat=	32,	tiLvl=	4			where	idType = 72
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 73
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 74
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 75
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 76
update	dbo.tb_LogType	set	tiCat=	32,	tiLvl=	16			where	idType = 79
update	dbo.tb_LogType	set	tiCat=	32			where	idType = 82
go
--	----------------------------------------------------------------------------
--	Inserts, updates or deletes an access permission
--	7.06.8965	* optimized logging
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

	select	@s =	'StfLvl( ' + isnull(cast(@idLvl as varchar), '?') + '| ' + @cLvl + ': "' + @sLvl + '" )'

	begin	tran

		update	dbo.tbStfLvl	set	cLvl =	@cLvl,	sLvl =	@sLvl
			where	idLvl = @idLvl

		if	ascii(@cLvl) < 0xF0												-- skip internal sync
			exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
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
alter proc		dbo.prDvc_InsUpd
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
--	----------------------------------------------------------------------------
--	Finds a doctor by name and inserts if necessary (not found)
--	7.06.8965	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.7222	+ quotes in trace
--	6.05	+ (nolock)
--	6.04
alter proc		dbo.prDoctor_GetIns
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
--	----------------------------------------------------------------------------
--	Updates a doctor record
--	7.06.8965	* optimized logging
--	7.06.7279	* optimized logging
--	7.06.6345	* added quotes in trace
--	6.05		* tracing
--	6.04
alter proc		dbo.prDoctor_Upd
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
alter proc		dbo.prPatient_GetIns
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
--	----------------------------------------------------------------------------
--	Cleans up invalid map cells
--	7.06.8965	* optimized logging
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
--	----------------------------------------------------------------------------
--	Updates mode and backup of a given shift
--	7.06.8965	* optimized logging
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
alter proc		dbo.prEvent_A_Exp
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
alter proc		dbo.pr_Sess_Del
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
--	----------------------------------------------------------------------------
--	Deletes sessions that are older than 24 hours
--	7.06.8972	* pr_Sess_Del
--	7.06.8796	* tb_Sess.sMachine -> .sHost, @
--	7.06.8411
alter proc		dbo.pr_Sess_Maint
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
--	----------------------------------------------------------------------------
--	UnRegisters Wi-Fi devices
--	7.06.8972	* pr_Sess_Del
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

		exec	dbo.pr_Sess_Del		@idSess, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8978	+ [70]
--				* [55..56]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 70)
	begin
		update	dbo.tb_Option	set	sOption =	'(internal) Data last bkup'	where	idOption = 55				--	7.06.8725
		update	dbo.tb_Option	set	sOption =	'(internal) Tlog last bkup'	where	idOption = 56				--	7.06.8725

		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 70,  56, 'Show JavaScript alerts()?' )				--	7.06.8978
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 70, 0 )

--		insert	dbo.tb_OptUsr ( idUser, idOption, sValue )
--			select	idUser, 70, 1
--				from	dbo.tb_User		with (nolock)
	end
commit
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
--	----------------------------------------------------------------------------
--	Updates DB stats (# of Size and Used pages - for data and tlog)
--	7.06.8978	+ data/tlog auto-growth
--	7.06.8959	* swapped recovery-model and service-name
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
--	----------------------------------------------------------------------------
--	7.06.8991	+ .sPath
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'sPath')
begin
	begin tran
		alter table	dbo.tb_Module	add
			sPath		varchar( 255 )	null		-- installed path/URL
	commit
end
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
alter proc		dbo.pr_Module_GetAll
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
--	----------------------------------------------------------------------------
--	7.06.8796	* .sMachine -> .sHost, @
--	7.06.8993	+ bAdmin
--	7.06.5399
alter view		dbo.vw_Sess
	with encryption
as
	select	s.idSess, s.dtCreated, s.sSessID, s.idModule, m.sModule, s.idUser, u.sUser, s.sIpAddr, s.sHost, s.bLocal, s.dtLastAct, s.sBrowser
		,	cast(case when 	r.idRole is null	then 0	else 1	end	as	bit)	as	bAdmin
		from	dbo.tb_Sess		s	with (nolock)
		join	dbo.tb_Module	m	with (nolock)	on	m.idModule	= s.idModule
	left join	dbo.tb_User		u	with (nolock)	on	u.idUser	= s.idUser
	left join	dbo.tb_UserRole	r	with (nolock)	on	r.idUser	= s.idUser	and	r.idRole	= 2
go
--	----------------------------------------------------------------------------
--	Returns all sessions in order of creation (ID)
--	7.06.8993	+ bAdmin
--	7.06.8796	* .sMachine -> .sHost, @
--	7.06.5399
alter proc		dbo.pr_Sess_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idSess, dtCreated, sSessID, idModule, sModule, idUser, sUser, sIpAddr, sHost, bLocal, dtLastAct, sBrowser, bAdmin
		from	dbo.vw_Sess		with (nolock)
		order	by	1 desc
end
go
--	----------------------------------------------------------------------------
--	7.06.8993	* [222-228].sType
begin
	begin tran
		update	dbo.tb_LogType	set	sType=	'Auth failed (usr)'	where	idType = 222;
		update	dbo.tb_LogType	set	sType=	'Auth failed (pwd)'	where	idType = 223;
		update	dbo.tb_LogType	set	sType=	'Auth failed (lck)'	where	idType = 224;
		update	dbo.tb_LogType	set	sType=	'Auth failed (dis)'	where	idType = 225;
		update	dbo.tb_LogType	set	sType=	'Auth failed (dvc)'	where	idType = 226;
		update	dbo.tb_LogType	set	sType=	'Auth failed (ind)'	where	idType = 227;
		update	dbo.tb_LogType	set	sType=	'Auth failed (lic)'	where	idType = 228;
	commit
end
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
--	----------------------------------------------------------------------------
--	Marks a module with latest activity
--	7.06.8994	+ @idSess
--	7.05.5059	- nocount
--	7.00
alter proc		dbo.pr_Module_Act
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
alter proc		dbo.prDvc_GetByUnit
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


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 9015 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	9015, getdate( ), getdate( ),	'' )

	update	dbo.tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2024-09-06',	sVersion =	'*798?rh, 798?cs*, *7980ns, *7981ls, *7980cw, *7985cw, *7970as'
		where	siBuild = 9015

	update	dbo.tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.9015',	sPath =	@@version
		where	idModule = 1

	exec	dbo.prHealth_Stats

	declare		@s		varchar(255)

	select	@s =	sVersion + '.00000, [' + db_name( ) + '], ' + sArgs
		from	dbo.tb_Module
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, 4, null, @s			--	4=system
commit
go

---	<100000,tbEvent>
---	<1000,tbEvent>
--exec	sp_updatestats
go

checkpoint
go

checkpoint
go

use [master]
go