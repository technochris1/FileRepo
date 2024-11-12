--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
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
--						release
--		2018-Jan-18		.6592
--						* prRtlsRcvr_GetAll, prRtlsBadge_GetAll
--		2018-Feb-19		.6624
--						* prDvc_RegWiFi
--						* prPatient_UpdLoc
--						* vwEvent_A
--						release
--		2018-Mar-13		.6646
--						* prDvc_RegWiFi
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 6646 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.6646', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Get')
	drop proc	dbo.pr_Module_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_LogType_GetAll')
	drop proc	dbo.pr_LogType_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLog_Clr')
	drop proc	dbo.pr_SessLog_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLog_Ins')
	drop proc	dbo.pr_SessLog_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessMod_Clr')
	drop proc	dbo.pr_SessMod_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessMod_Ins')
	drop proc	dbo.pr_SessMod_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Version_GetAll')
	drop proc	dbo.pr_Version_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Log_XltDtEvRng')
	drop proc	dbo.pr_Log_XltDtEvRng
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Index')
	drop proc	dbo.prHealth_Index
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prHealth_Table')
	drop proc	dbo.prHealth_Table
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prTable_Health')
	drop proc	dbo.prTable_Health
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_UnRegWiFi')
	drop proc	dbo.prDvc_UnRegWiFi
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_RegWiFi')
	drop proc	dbo.prDvc_RegWiFi
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCliStfSum')
	drop proc	dbo.prRptCliStfSum
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCliStfDtl')
	drop proc	dbo.prRptCliStfDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptCliPatDtl')
	drop proc	dbo.prRptCliPatDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_SetLvl')
	drop proc	dbo.prCfgPri_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLog_Clr')
	drop proc	dbo.pr_SessLog_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLog_Ins')
	drop proc	dbo.pr_SessLog_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_UpdRtls')
	drop proc	dbo.prRoom_UpdRtls
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_SetLvl')
	drop proc	dbo.pr_Module_SetLvl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetRtls')
	drop proc	dbo.prRoom_GetRtls
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRoom_Get')
	drop proc	dbo.prRtlsRoom_Get
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRoom_OffOne')
	drop proc	dbo.prRtlsRoom_OffOne
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCallList_GetAll')
	drop proc	dbo.prCallList_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetPrismByRoom')
	drop function	dbo.fnEventA_GetPrismByRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetDomeByRoom')
	drop function	dbo.fnEventA_GetDomeByRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDome_Upd')
	drop proc	dbo.prCfgDome_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDome_GetAll')
	drop proc	dbo.prCfgDome_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='wtCallPriority')
	drop table	dbo.wtCallPriority
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessLog')
	drop table	dbo.tb_SessLog
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessMod')
	drop table	dbo.tb_SessMod
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vw_Log_S')
	drop view	dbo.vw_Log_S
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_Log_S')
	drop table	dbo.tb_Log_S
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='vwEvent_D')
	drop view	dbo.vwEvent_D
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbEvent_D')
	drop table	dbo.tbEvent_D
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tb_SessLog')
	drop table	dbo.tb_SessLog
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbRtlsRoom')
	drop table	dbo.tbRtlsRoom
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgDome')
begin
	if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkCfgPri_Dome')
		alter table	dbo.tbCfgPri	drop constraint	fkCfgPri_Dome
	drop table	dbo.tbCfgDome
end
go
--	----------------------------------------------------------------------------
--	7.06.6177	* .dtCreated -> .dtUpdated
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgTone') and name = 'dtUpdated')
begin
	begin tran
		exec sp_rename 'tbCfgTone.dtCreated',	'dtUpdated',	'column'

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdCfgTone_Created')
			exec sp_rename 'dbo.tdCfgTone_Created',		'tdCfgTone_Updated'
	commit
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
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtUpdated
			,	vbTone
			from	tbCfgTone	with (nolock)
			order	by	1
	else
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtUpdated
			from	tbCfgTone	with (nolock)
			order	by	1
end
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

--,	dtCreated	smalldatetime not null	
--		constraint	tdCfgDome_Created	default( getdate( ) )
,	dtUpdated	smalldatetime not null	
		constraint	tdCfgDome_Updated	default( getdate( ) )
)
go
grant	select, update					on dbo.tbCfgDome		to [rWriter]		--	, insert, delete
grant	select							on dbo.tbCfgDome		to [rReader]
go
--	populate
declare		@siDome		smallint
select	@siDome =	0
while	@siDome <= 255
begin
	insert	tbCfgDome	(  tiDome, iLight0, iLight1, iLight2, tiPrism, iPrism0, iPrism1, iPrism2, iPrism3, iPrism4, iPrism5 )
			values		( @siDome, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 )
	select	@siDome =	@siDome + 1
end
go
--	----------------------------------------------------------------------------
--	Returns Dome Light Show definitions, ordered to be loadable into a table
--	7.06.6184	+ .tiPrism, sPrism
--	7.06.6177
create proc		dbo.prCfgDome_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	tiDome,		iLight0, iLight1, iLight2,	tiPrism
		,	case when	tiPrism & 8 > 0	then	'T'	else '  '	end +
			case when	tiPrism & 4 > 0	then	'U'	else '  '	end +
			case when	tiPrism & 2 > 0	then	'L'	else '  '	end +
			case when	tiPrism & 1 > 0	then	'B'	else '  '	end	as	sPrism
		,	iPrism0, iPrism1, iPrism2, iPrism3, iPrism4, iPrism5,	cast(1 as bit)	as	bActive,	dtUpdated
		from	tbCfgDome	with (nolock)
		order	by	1
end
go
grant	execute				on dbo.prCfgDome_GetAll				to [rWriter]
grant	execute				on dbo.prCfgDome_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a Dome Light Show definition
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
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@iPrism		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Dome_U( ' + isnull(cast(@tiDome as varchar), '?') + ', 0x' + upper(substring(sys.fn_varbintohexstr(@iLight0),3,8)) +
				' 0x' + upper(substring(sys.fn_varbintohexstr(@iLight1),3,8)) + ' 0x' + upper(substring(sys.fn_varbintohexstr(@iLight2),3,8)) +
				', 0x' + upper(substring(sys.fn_varbintohexstr(@iPrism0),3,8)) + ' 0x' + upper(substring(sys.fn_varbintohexstr(@iPrism1),3,8)) +
				' 0x' + upper(substring(sys.fn_varbintohexstr(@iPrism2),3,8)) + ' 0x' + upper(substring(sys.fn_varbintohexstr(@iPrism3),3,8)) +
				' 0x' + upper(substring(sys.fn_varbintohexstr(@iPrism4),3,8)) + ' 0x' + upper(substring(sys.fn_varbintohexstr(@iPrism5),3,8)) + ' )'
		,	@iPrism =	@iPrism0 | @iPrism1 | @iPrism2 | @iPrism3 | @iPrism4 | @iPrism5

	begin	tran

		update	tbCfgDome	set	iLight0 =	@iLight0,	iLight1 =	@iLight1,	iLight2 =	@iLight2
							,	iPrism0 =	@iPrism0,	iPrism1 =	@iPrism1,	iPrism2 =	@iPrism2
							,	iPrism3 =	@iPrism3,	iPrism4 =	@iPrism4,	iPrism5 =	@iPrism5
							,	tiPrism =	case when	@iPrism & 0xF000F000 <> 0	then	2	else	0	end	+
											case when	@iPrism & 0x0F000F00 > 0	then	1	else	0	end	+
											case when	@iPrism & 0x00F000F0 > 0	then	8	else	0	end	+
											case when	@iPrism & 0x000F000F > 0	then	4	else	0	end
				where	tiDome = @tiDome

		if	@iTrace & 0x40 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgDome_Upd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	7.06.6177	* .tiLight -> .tiDome
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'tiDome')
begin
	begin tran
		exec sp_rename 'tbCfgPri.tiLight',		'tiDome',	'column'
	commit
end
go
--				+ fkCfgPri_Dome
if	not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkCfgPri_Dome')
	alter table	dbo.tbCfgPri	add
		constraint	fkCfgPri_Dome		foreign key (tiDome) references tbCfgDome
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.6177	* .tiLight -> .tiDome
--	7.06.5914	* .dtCreated -> .dtUpdated
--	7.06.5687	+ .siIdxUg, .siIdxOt, .tiOtInt, .tiLight, .tiTone, .tiToneInt
--	7.04.4898
alter proc		dbo.prCfgPri_GetAll
(
	@bEnabled	bit					--	0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	siIdx, sCall, tiFlags, tiShelf, tiSpec, iColorF, iColorB, iFilter
		,	cast(tiFlags & 0x01 as bit)		as	bLocking
		,	cast(tiFlags & 0x02 as bit)		as	bEnabled
		,	cast(tiFlags & 0x04 as bit)		as	bControl
		,	cast(tiFlags & 0x08 as bit)		as	bRndRmnd
		,	cast(tiFlags & 0x10 as bit)		as	bSequenc
		,	cast(tiFlags & 0x20 as bit)		as	bXclusiv
		,	cast(tiFlags & 0x40 as bit)		as	bTargett
		,	cast(tiFlags & 0x80 as bit)		as	bReservd
		,	siIdxUg, siIdxOt, tiOtInt, tiDome, tiTone, tiToneInt
		,	dtUpdated
		from	tbCfgPri	with (nolock)
		where	@bEnabled = 0	or	tiFlags & 0x02 > 0
		order	by	1 desc
end
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
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
,	@tiFlags	tinyint				-- bit flags: 1=locking, 2=enabled
,	@tiShelf	tinyint				-- shelf: 0=nondisplay, 1=routine, 2=urgent, 3=emergency, 4=code
,	@tiSpec		tinyint				-- special priority [0..22]
,	@siIdxUg	smallint			-- upgrade priority-index
,	@siIdxOt	smallint			-- overtime priority-index
,	@tiOtInt	tinyint				-- overtime interval, min
,	@tiDome		tinyint				-- light-show index
,	@tiTone		tinyint				-- tone index
,	@tiToneInt	tinyint				-- tone interval, min
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

	select	@s= 'Pri_U( ' + isnull(cast(@siIdx as varchar), '?') +	', n=' + isnull(@sCall, '?') +
				', f='  + isnull(cast(@tiFlags as varchar), '?') +	', sh=' + isnull(cast(@tiShelf as varchar), '?') +
				', ug=' + isnull(cast(@siIdxUg as varchar), '?') +	', ot=' + isnull(cast(@siIdxOt as varchar), '?') +
				', oi=' + isnull(cast(@tiOtInt as varchar), '?') +	', ls=' + isnull(cast(@tiDome as varchar), '?') +
				', tn=' + isnull(cast(@tiTone as varchar), '?') +	', ti=' + isnull(cast(@tiToneInt as varchar), '?') +
				', sp=' + isnull(cast(@tiSpec as varchar), '?') +	', cf=' + isnull(cast(@iColorF as varchar), '?') +
				', cb=' + isnull(cast(@iColorB as varchar), '?') +	', fm=' + isnull(cast(@iFilter as varchar), '?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgPri where siIdx = @siIdx)
			update	tbCfgPri	set		sCall=	@sCall,		tiFlags =	@tiFlags
				,	tiShelf =	@tiShelf,	tiSpec =	@tiSpec,	siIdxUg =	@siIdxUg,	siIdxOt =	@siIdxOt
				,	tiOtInt =	@tiOtInt,	tiDome =	@tiDome,	tiTone =	@tiTone,	tiToneInt=	@tiToneInt
				,	iColorF =	@iColorF,	iColorB =	@iColorB,	iFilter =	@iFilter
				where	siIdx = @siIdx
		else
			insert	tbCfgPri	(  siIdx,  sCall,  tiFlags,  tiShelf,  tiSpec,  siIdxUg,  siIdxOt,  tiOtInt,  tiDome,  tiTone,  tiToneInt,  iColorF,  iColorB,  iFilter )
					values		( @siIdx, @sCall, @tiFlags, @tiShelf, @tiSpec, @siIdxUg, @siIdxOt, @tiOtInt, @tiDome, @tiTone, @tiToneInt, @iColorF, @iColorB, @iFilter )

		if	@iTrace & 0x40 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	rm.idUnit,	ea.idRoom, r.sDevice	as	sRoom,	ea.tiBed, cb.cBed
	,	r.sDevice + case when ea.tiBed is null or ea.tiBed = 0xFF then '' else ' : ' + cb.cBed end		as	sRoomBed
	,	ea.idCall, c.siIdx, c.sCall, cp.iColorF, cp.iColorB, cp.tiShelf, cp.tiSpec, cp.iFilter, cp.tiDome, cd.tiPrism, cp.tiTone, cp.tiToneInt
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit )		as	bAnswered
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) )	as	tElapsed,	ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	from		tbEvent_A	ea	with (nolock)
	left join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left join	tbCall		c	with (nolock)	on	c.idCall = ea.idCall
	left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
	left join	tbCfgDome	cd	with (nolock)	on	cd.tiDome = cp.tiDome
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Returns topmost prism show for a given room (identified by Sys-G-J) and segment
--	7.06.6186
create function		dbo.fnEventA_GetDomeByRoom
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiBed		tinyint				-- bed-idx, 0xFF=room
--,	@iFilter	int					-- filter mask (ignored)
,	@idMaster	smallint			-- device look-up FK
--,	@bPrsnc		bit					-- include presence events? (ignored)
,	@tiPrism	tinyint				-- prism segment (bitwise: 8=T, 4=U, 2=L, 1=B)
)
	returns table
	with encryption
as
return
	select	top	1	tiDome
		from	vwEvent_A	with (nolock)
		where	bActive > 0	--	and	( tiShelf > 0	or	@bPrsnc > 0	and	tiSpec between 7 and 9 )	--	7.06.6186
			and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
	--	-	and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	tiPrism & @tiPrism > 0
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	tiDome desc
go
grant	select				on dbo.fnEventA_GetDomeByRoom	to [rWriter]
grant	select				on dbo.fnEventA_GetDomeByRoom	to [rReader]
go
--	----------------------------------------------------------------------------
--	Data source for 7983rh.CallList.aspx (based on dbo.prRoomBed_GetByUnit)
--	7.06.6164
create proc		dbo.prCallList_GetAll
(
--	@sUnits		varchar( 255 )		-- comma-separated idUnit's
	@iFilter	int					-- filter mask
--,	@idMaster	smallint			-- master console, 0=global mode
)
	with encryption
as
begin
--	set	nocount on

/*	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint		not null	-- unit look-up FK
	,	sUnit		varchar( 16 )	not null	-- unit name
--	,	idShift		smallint		null		-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)

	exec	dbo.prUnit_SetTmpFlt	@sUnits
*/
	set	nocount off

	select	ea.idEvent, ea.dtEvent, ea.idRoom, ea.sRoomBed, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.tElapsed, ea.iFilter, ea.bAudio, ea.bAnswered

/*			tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
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
--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
*/		from	vwEvent_A		ea	with (nolock)
/*			join	#tbUnit		tu	with (nolock)	on	tu.idUnit = ea.idUnit
--			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
			left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
*/		where	ea.bActive > 0	and	ea.tiShelf > 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )			--	7.03
---				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
		order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed desc		--	call may have been started before it was recorded (ea.idEvent)
end
go
--grant	execute				on dbo.prCallList_GetAll			to [rWriter]
grant	execute				on dbo.prCallList_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	7981 - Returns rooms for updating RTLS state
--	7.06.6198	* only return rooms with presence!
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.05.5192	* include empty names into output
--	6.05
/*
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
				and		( idUserG > 0	or	idUserO > 0		or	idUserY > 0 )		-- 7.06.6198
			or	tiNotify > 0
end
*/
go
--	----------------------------------------------------------------------------
--	7.06.6225	+ .dtExpires
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoom') and name = 'dtExpires')
begin
	begin tran
		alter table	dbo.tbRoom	add
			dtExpires	datetime		null		-- healing expiration window (30s from last xB4)
	commit
end
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + assigned staff
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
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, d.sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)		as sSGJ
	,	'[' + cDevice + '] ' + sDevice		as sQnDevice
--	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	as sFnDevice
	,	r.idEvent,	r.tiSvc
	,	r.idUserG,	s4.idStfLvl as idStfLvlG,	s4.sStaffID as sStaffIDG,	coalesce(s4.sStaff, r.sStaffG) as sStaffG,	s4.bOnDuty as bOnDutyG,	s4.dtDue as dtDueG
	,	r.idUserO,	s2.idStfLvl as idStfLvlO,	s2.sStaffID as sStaffIDO,	coalesce(s2.sStaff, r.sStaffO) as sStaffO,	s2.bOnDuty as bOnDutyO,	s2.dtDue as dtDueO
	,	r.idUserY,	s1.idStfLvl as idStfLvlY,	s1.sStaffID as sStaffIDY,	coalesce(s1.sStaff, r.sStaffY) as sStaffY,	s1.bOnDuty as bOnDutyY,	s1.dtDue as dtDueY
	,	r.dtExpires
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	tbDevice	d	with (nolock)
	join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
	left join	vwStaff	s4	with (nolock)	on	s4.idUser = r.idUserG
	left join	vwStaff	s2	with (nolock)	on	s2.idUser = r.idUserO
	left join	vwStaff	s1	with (nolock)	on	s1.idUser = r.idUserY
go
--	----------------------------------------------------------------------------
--	Updates room's staff
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
			from	tbRoom	r
			join	tbEvent_A	ea	on	ea.idEvent = r.idEvent
			where	ea.dtExpires < @dt

		update	rb	set	rb.idEvent =	null								-- reset tbRoomBed.idEvent	v.7.02
			from	tbRoomBed	rb
			join	tbEvent_A	ea	on	ea.idEvent = rb.idEvent
			where	ea.dtExpires < @dt

		delete	from	tbEvent_A	where	dtExpires < @dt					-- remove expired calls

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets location attributes for all badges
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

		update	tbRtlsBadge	set dtEntered=	@dt,	idRoom =	null,	idRcvrCurr =	null,	dtUpdated=	@dt
		update	tb_User		set	dtEntered=	@dt,	idRoom =	null
		update	tbRoom		set	dtUpdated=	@dt,	dtExpires=	@dt
							,	idUserG =	null,	idUserO =	null,	idUserY =	null
							,	sStaffG =	null,	sStaffO =	null,	sStaffY =	null

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
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

/*		delete	from	tbRtlsRoom					-- reinit staff presence placeholders		v.7.02
			where	idRoom = @idRoom
		insert	tbRtlsRoom	(idRoom, idStfLvl)			--, bNotify
				select		@idRoom, idStfLvl			--, 1
					from	tbStfLvl	with (nolock)
*/
		if	@siBeds = 0								-- no beds in this room
		begin
			--	remove combinations with beds
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
				insert	tbRoomBed	(  idRoom, tiBed )
						values		( @idRoom, 0xFF )
--				insert	tbRoomBed	(  idRoom, cBed, tiBed )
--						values		( @idRoom, null, 0xFF )

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
						insert	tbRoomBed	(  idRoom,  tiBed )
								values		( @idRoom, @tiBed )
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
--	Updates 790 device assigned to a given receiver
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
--	7981 - Returns rooms for updating RTLS state
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
	select	idDevice	as	idRoom,	cSys, tiGID, tiJID, tiRID,	sQnDevice,	idUserG, sStaffG, idUserO, sStaffO, idUserY, sStaffY,	dtExpires
		from	vwRoom	with (nolock)
		where	dtExpires <= @dtNow
		and		bActive > 0
end
go
grant	execute				on dbo.prRoom_GetRtls				to [rWriter]
grant	execute				on dbo.prRoom_GetRtls				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
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
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rb.idRoom, r.sQnDevice	[sQnRoom]
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
--		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	tbRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	idDvcType & @idDvcType	<> 0
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bGroup is null	or	tiFlags & 0x01 = @bGroup)
		and		(@idUnit is null	or	idDvcType = 1	or	idDvc in (select idDvc	from	tbDvcUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given bar-code
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
	select	idDvc, idDvcType, sDvc, d.sDial, tiFlags, sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rb.idRoom, r.sQnDevice	[sQnRoom]
		,	idUser, d.idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from		vwDvc		d	with (nolock)
--		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	tbRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0	and	sBarCode = @sBarCode
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given dial-code
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
	select	idDvc, idDvcType, sDvc, d.sDial, tiFlags, sBarCode, d.sUnits, d.sTeams, d.bActive
		,	rb.idRoom, r.sQnDevice	[sQnRoom]
		,	idUser, d.idStfLvl, sStaffID, sStaff, bOnDuty, dtDue
		from		vwDvc		d	with (nolock)
--		left join	tbRtlsRoom	rr	with (nolock)	on	rr.idBadge = d.idDvc
		left join	tbRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0	and	d.sDial = @sDial
end
go
--	----------------------------------------------------------------------------
--	7.06.6282	+ .tiLvl
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'tiLvl')
begin
	begin tran
		alter table	dbo.tb_Module	add
			tiLvl		tinyint			null		-- 1=internal, 2=trace, 4=info, 8=warn, 16=err, 32=critical, 64+=reserved
	commit
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'tiLvl' and is_nullable=1)
begin
	begin tran
		update	tb_Module	set	tiLvl=	60			-- 4=info + 8=warn + 16=err + 32=critical

		alter table	dbo.tb_Module	alter column
			tiLvl		tinyint			not null
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns modules state
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
	select	idModule, sModule, sDesc, bLicense, tiModType, tiLvl, sIpAddr, sMachine, sVersion, dtStart, sParams, dtLastAct
		,	case when sMachine is null then sIpAddr else sMachine end	as	sHost
		,	datediff( ss, dtLastAct, getdate( ) )						as	siElapsed
		,	cast( getdate( ) - dtStart as datetime )					as	dtRunTime
		from	tb_Module	with (nolock)
		where	(@bInstall = 0	or	sIpAddr is not null  or  sMachine is not null)
		and		(@bActive = 0	or	dtStart is not null)
end
go
--	----------------------------------------------------------------------------
--	7.06.6284	+ [64]
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 64)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 64,  4, 1, 'Component Updated' )		--	7.06.6284
	commit
end
go
--	----------------------------------------------------------------------------
--	Sets given module's logging level
--	7.06.6284
create proc		dbo.pr_Module_SetLvl
(
	@idModule	tinyint				-- module id
,	@tiLvl		tinyint				-- bitwise tb_LogType.tiLvl, 0xFF=include all
,	@idUser		int
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@s= 'Mod_SL( ' + right('00' + cast(@idModule as varchar), 3) + ', l=' + isnull(cast(@tiLvl as varchar), '?') + ' )'

	begin	tran
		update	tb_Module		set	tiLvl=	@tiLvl
			where	idModule = @idModule

		exec	dbo.pr_Log_Ins	64, @idUser, null, @s
	commit
end
go
grant	execute				on dbo.pr_Module_SetLvl				to [rWriter]
grant	execute				on dbo.pr_Module_SetLvl				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.6284	- .idRoom, .tiBed, fkPatient_RoomBed	(tbRoomBed gives patient's location)
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbPatient') and name = 'idRoom')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkPatient_RoomBed')
			alter table	dbo.tbPatient	drop constraint	fkPatient_RoomBed
		if	exists	(select 1 from dbo.sysindexes where name='xuPatient_Loc')
			drop index	tbPatient.xuPatient_Loc

		alter table	dbo.tbPatient	drop column	idRoom
		alter table	dbo.tbPatient	drop column	tiBed
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a bed definition
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
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Bed_IU( ' + isnull(cast(@tiBed as varchar), '?') +
				', c=' + isnull(@cBed, '?') + ', d=' + isnull(@cDial, '?') + ', f=' + isnull(cast(@siBed as varchar), '?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgBed where tiBed = @tiBed)
		begin
			update	tbCfgBed	set	cBed =	@cBed,	cDial=	@cDial,	dtUpdated=	getdate( )
				where	tiBed = @tiBed

--			update	tbRoomBed	set	cBed =	@cBed		--,	dtUpdated=	getdate( )
--				where	tiBed = @tiBed

			select	@s =	@s + ' UPD'
		end
		else
		begin
			insert	tbCfgBed	(  tiBed,  cBed,  cDial,  siBed )
					values		( @tiBed, @cBed, @cDial, @siBed )

			select	@s =	@s + ' INS'
		end

		if	@iTrace & 0x08 > 0
			exec	dbo.pr_Log_Ins	71, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
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
select	r.idUnit,	rb.idRoom, r.sDevice as sRoom, r.sQnDevice, d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, cb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	p.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, p.idDoctor, dc.sDoctor
	,	rb.idUser1,	a1.idStfLvl as idStLvl1,	a1.sStaffID as sStaffID1,	a1.sStaff as sStaff1,	a1.bOnDuty as bOnDuty1,	a1.dtDue as dtDue1
	,	rb.idUser2,	a2.idStfLvl as idStLvl2,	a2.sStaffID as sStaffID2,	a2.sStaff as sStaff2,	a2.bOnDuty as bOnDuty2,	a2.dtDue as dtDue2
	,	rb.idUser3,	a3.idStfLvl as idStLvl3,	a3.sStaffID as sStaffID3,	a3.sStaff as sStaff3,	a3.bOnDuty as bOnDuty3,	a3.dtDue as dtDue3
--	,	r.idReg4, r.sReg4,	r.idReg2, r.sReg2,	r.idReg1, r.sReg1
	,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
	,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
	,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
	,	rb.dtUpdated
	from	tbRoomBed	rb	with (nolock)
	join	tbDevice	d	with (nolock)	on	d.idDevice = rb.idRoom	and	d.bActive > 0
	join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
	left join	tbCfgBed	cb	with (nolock)	on	rb.tiBed = cb.tiBed		---	and	cb.bActive > 0	--	no need
	left join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient	--	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed
	left join	tbDoctor	dc	with (nolock)	on	dc.idDoctor = p.idDoctor
	left join	vwStaff		a1	with (nolock)	on	a1.idUser = rb.idUser1
	left join	vwStaff		a2	with (nolock)	on	a2.idUser = rb.idUser2
	left join	vwStaff		a3	with (nolock)	on	a3.idUser = rb.idUser3
go
--	----------------------------------------------------------------------------
--	Patients
--	7.06.6284	- tbPatient.idRoom, .tiBed
--	7.05.5127
alter view		dbo.vwPatient
	with encryption
as
select	p.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote
	,	p.idDoctor, d.sDoctor
	,	rb.idUnit,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed,		rb.cSys, rb.tiGID, rb.tiJID, rb.tiRID
	,	p.bActive, p.dtCreated, p.dtUpdated
	from	tbPatient	p	with (nolock)
	left join	vwRoomBed	rb	with (nolock)	on	p.idPatient = rb.idPatient	--	p.idRoom = rb.idRoom	and	p.tiBed = rb.tiBed
	left join	tbDoctor	d	with (nolock)	on	d.idDoctor = p.idDoctor
go
--	----------------------------------------------------------------------------
--	Data source for 7985
--	7.06.6953	* removed 'db7983.' from object refs
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
--	7.06.6289	fix tbShift .tBeg and .tEnd (possibly messed up by .5934)
begin
	begin tran
		update	tb_OptSys	set	tValue =	'07:00:00'	where	idOption = 38

		update	tbShift		set	tBeg =		'07:00:00'	where	tBeg =	'00:07:00'
		update	tbShift		set	tEnd =		'07:00:00'	where	tEnd =	'00:07:00'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6290	* [31] redefined
begin tran
	begin
		update	tb_Option	set	sOption =	'Enable Remote Presence?'			where	idOption = 18
		update	tb_Option	set	sOption =	'(internal) Presence healing, sec'	where	idOption = 31
		update	tb_Option	set	sOption =	'Active Directory root domain'		where	idOption = 32
		update	tb_Option	set	sOption =	'Active Directory root''s DN'		where	idOption = 33
		update	tb_Option	set	sOption =	'Active Directory LDAP port'		where	idOption = 34
		update	tb_Option	set	sOption =	'Active Directory I/O user'			where	idOption = 35
		update	tb_Option	set	sOption =	'Active Directory I/O pass'			where	idOption = 36
		update	tb_Option	set	sOption =	'Active Directory *790* group GUID'	where	idOption = 37

		update	tb_OptSys	set	iValue =	30		where	idOption = 31
	end
commit
go
--	----------------------------------------------------------------------------
--	7981 - Extends RTLS healing expiration for rooms with staff present
--	7.06.6290	* tb_OptSys[9] -> tb_OptSys[31]
--	7.06.6226
create proc		dbo.prRoom_UpdRtls
(
	@dtNow			datetime
)
	with encryption
as
begin
	declare		@iExpNrm	int

	set	nocount	on

	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 31

	set	nocount	off
	update	tbRoom	set	dtExpires=
						case when	0 < idUserG  or	 0 < idUserO  or  0 < idUserY
									then	dateadd( ss, @iExpNrm, dtExpires )
							else	null	end
		where	dtExpires <= @dtNow
end
go
grant	execute				on dbo.prRoom_UpdRtls				to [rWriter]
grant	execute				on dbo.prRoom_UpdRtls				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge
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
		,		@iTrace		int
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@idReceiver	smallint
		,		@idOldest	int
		,		@idUser		int
		,		@sStaff		varchar( 16 )

	set	nocount	on

	select	@dt =	getdate( ),		@iRetVal =	0,	@idOldest=	null	--, @cSys= null, @tiGID= null, @tiJID= null, @tiRID= null
		,	@s=	'Bdg_UL( b=' + isnull(cast(@idBadge as varchar),'?') +
				', cr=' + isnull(cast(@idRcvrCurr as varchar),'?') + ' ' + isnull(convert(varchar, @dtRcvrCurr, 121),'?') +
				', lr=' + isnull(cast(@idRcvrLast as varchar),'?') + ' ' + isnull(convert(varchar, @dtRcvrLast, 121),'?') + ' )'

	if	@idBadge > 0		and not	exists( select 1 from tbRtlsBadge with (nolock) where idBadge = @idBadge )
		select	@iRetVal =	-1,		@s =	@s + ' bdg'
	else
	if	@idRcvrCurr > 0		and	not	exists( select 1 from tbRtlsRcvr with (nolock) where idReceiver = @idRcvrCurr )
		select	@iRetVal =	-2,		@s =	@s + ' cr'
	else
	if	@idRcvrLast > 0		and	not	exists( select 1 from tbRtlsRcvr with (nolock) where idReceiver = @idRcvrLast )
		select	@iRetVal =	-3,		@s =	@s + ' lr'

	if	@iRetVal < 0
	begin
		select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

		if	@iTrace & 0x10 > 0
			exec	dbo.pr_Log_Ins	82, null, null, @s

		return	@iRetVal													--	?? badge or receiver does not exist !!
	end


	if	@idRcvrCurr = 0		select	@idRcvrCurr= null
	if	@idRcvrLast = 0		select	@idRcvrLast= null

	select	@idReceiver =	idRcvrCurr,		@idRoomPrev =	idRoom,		@idRoomCurr =	null,	@dtEntered =	dtEntered
		,	@idStfLvl =		idStfLvl,		@cSys =		cSys,	@tiGID =	tiGID,	@tiJID =	tiJID,	@tiRID =	tiRID	--	previous!!
		from	vwRtlsBadge		where	idBadge = @idBadge

	if	@idReceiver = @idRcvrCurr	return	0								--	badge already at same location => skip

	select	@iRetVal =	1,	@idRoomCurr =	idRoom							--	new receiver
		from	tbRtlsRcvr		where	idReceiver = @idRcvrCurr

	begin	tran

		if	@idRoomPrev > 0  and  @idRoomCurr is null	or
			@idRoomCurr > 0  and  @idRoomPrev is null	or
			@idRoomCurr <> @idRoomPrev										--	badge moved to another room
		begin
			--	set new location for the badge
			update	tbRtlsBadge		set	idRoom =	@idRoomCurr,	dtEntered=	@dt,	@dtEntered =	@dt
				where	idBadge = @idBadge

			--	update user's location
			update	u	set	idRoom =	@idRoomCurr,	dtEntered=	@dt
				from	tb_User		u
				join	tbDvc		d	on	d.idUser = u.idUser
				where	d.idDvc = @idBadge

			--	get oldest staff in previous room
			select	@idUser =	null,	@sStaff =	null
			select	top 1	@idUser =	sd.idUser,	@sStaff =	u.sStaff
				from	tbRtlsBadge	rb	with (nolock)
				join	tbDvc		sd	with (nolock)	on	sd.idDvc = rb.idBadge
				join	tb_User		u	with (nolock)	on	u.idUser = sd.idUser
				where	rb.idRoom = @idRoomPrev		and	u.idStfLvl = @idStfLvl
				order	by	rb.dtEntered

			--	set previous room to the oldest staff
			if	@idStfLvl = 4
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserG =	@idUser,	sStaffG =	@sStaff
					where	idRoom = @idRoomPrev
					and	(	@idUser is not null		and	idUserG is null
						or	@idUser is null
						or	@idUser <> idUserG	)
			else
			if	@idStfLvl = 2
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserO =	@idUser,	sStaffO =	@sStaff
					where	idRoom = @idRoomPrev
					and	(	@idUser is not null		and	idUserO is null
						or	@idUser is null
						or	@idUser <> idUserO	)
			else
		--	if	@idStfLvl = 1
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserY =	@idUser,	sStaffY =	@sStaff
					where	idRoom = @idRoomPrev
					and	(	@idUser is not null		and	idUserY is null
						or	@idUser is null
						or	@idUser <> idUserY	)

			--	get oldest staff in current room
			select	@idUser =	null,	@sStaff =	null
			select	top 1	@idUser =	sd.idUser,	@sStaff =	u.sStaff
				from	tbRtlsBadge	rb	with (nolock)
				join	tbDvc		sd	with (nolock)	on	sd.idDvc = rb.idBadge
				join	tb_User		u	with (nolock)	on	u.idUser = sd.idUser
				where	rb.idRoom = @idRoomCurr		and	u.idStfLvl = @idStfLvl
				order	by	rb.dtEntered

			--	remove that user from any [other] room and set current room to him/her
			if	@idStfLvl = 4
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserG =	null,		sStaffG =	null
					where	idUserG = @idUser

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserG =	@idUser,	sStaffG =	@sStaff
					where	idRoom = @idRoomCurr
					and	(	@idUser is not null		and	idUserG is null
						or	@idUser is null
						or	@idUser <> idUserG	)
			end
			else
			if	@idStfLvl = 2
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserO =	null,		sStaffO =	null
					where	idUserO = @idUser

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserO =	@idUser,	sStaffO =	@sStaff
					where	idRoom = @idRoomCurr
					and	(	@idUser is not null		and	idUserO is null
						or	@idUser is null
						or	@idUser <> idUserO	)
			end
			else
		--	if	@idStfLvl = 1
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserY =	null,		sStaffY =	null
					where	idUserY = @idUser

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserY =	@idUser,	sStaffY =	@sStaff
					where	idRoom = @idRoomCurr
					and	(	@idUser is not null		and	idUserY is null
						or	@idUser is null
						or	@idUser <> idUserY	)
			end

			--	select S-G-J-R for current room
			select	@cSys=	null,	@tiGID =	null,	@tiJID =	null,	@tiRID =	null,	@iRetVal =	2

			select	@cSys=	cSys,	@tiGID =	tiGID,	@tiJID =	tiJID,	@tiRID =	tiRID
				from	tbDevice	with (nolock)
				where	idDevice = @idRoomCurr
		end

		update	tbRtlsBadge		set	dtUpdated=	@dt
			,	idRcvrCurr =	@idRcvrCurr,	dtRcvrCurr =	@dtRcvrCurr
			,	idRcvrLast =	@idRcvrLast,	dtRcvrLast =	@dtRcvrLast
			where	idBadge = @idBadge

	commit

	return	@iRetVal
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
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
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ', v=' + isnull(@sCodeVer,'?') +
					', p0=' + isnull(cast(@tiPriCA0 as varchar),'?') + ', p1=' + isnull(cast(@tiPriCA1 as varchar),'?') + ' )'

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID = 0
		select	@iAID=	null
--	if	@iAID > 0
--		select	@idDevice= idDevice		from	tbDevice		where	iAID = @iAID
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID > 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	---and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	---and	bActive > 0
---	if	@idDevice is null	and	len(@sDevice) > 0	and	len(@sDial) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	and	sDial = @sDial	--and	bActive > 0
---	if	@idDevice is null	and	len(@sDevice) > 0
---		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	sDevice = @sDevice	--and	bActive > 0

	if	@tiRID > 0						-- R-bus device
		select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
	else
	if	@tiJID > 0	---and	@tiRID = 0	-- J-bus device
		select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	bActive > 0

--	select	@s =	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')

	begin	tran

		if	@tiJID = 0														-- gateway		--	v.7.06.5414
		begin
--			select	@sUnits =	@sDial,		@sDial =	null				-- @sDial == IP for GWs		--	v.7.06.5855

			if	charindex(@cSys, @sSysts) = 0								-- is @cSys in Allowed-Systems?
				update	tb_OptSys	set	sValue =	sValue + @cSys
					where	idOption = 26
		end
		else																-- calculate .sUnits
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
						where	tiLvl = 4									-- unit
			end
			else															-- specific units
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

		if	@idDevice > 0													-- device found - update	--	v.7.06.5855
		begin
			update	tbDevice	set		bConfig =	1,	dtUpdated=	getdate( )	--, idEvent =	null
				,	idParent =	@idParent,	cSys =	@cSys,	tiGID=	@tiGID,	tiJID=	@tiJID,	tiRID=	@tiRID,	sDial=	@sDial
				,	tiStype =	@tiStype,	cDevice =	@cDevice,	sDevice =	@sDevice,	sCodeVer =	@sCodeVer,	sUnits =	@sUnits
				,	tiPriCA0 =	@tiPriCA0,	tiPriCA1 =	@tiPriCA1,	tiPriCA2 =	@tiPriCA2,	tiPriCA3 =	@tiPriCA3
				,	tiPriCA4 =	@tiPriCA4,	tiPriCA5 =	@tiPriCA5,	tiPriCA6 =	@tiPriCA6,	tiPriCA7 =	@tiPriCA7
				,	tiAltCA0 =	@tiAltCA0,	tiAltCA1 =	@tiAltCA1,	tiAltCA2 =	@tiAltCA2,	tiAltCA3 =	@tiAltCA3
				,	tiAltCA4 =	@tiAltCA4,	tiAltCA5 =	@tiAltCA5,	tiAltCA6 =	@tiAltCA6,	tiAltCA7 =	@tiAltCA7
				where	idDevice = @idDevice

			if	@iAID > 0
			begin
				select	@s =	@s + ' AID:' + isnull(cast(iAID as varchar),'?') + '->' + cast(@iAID as varchar)
					from	tbDevice
					where	idDevice = @idDevice
				update	tbDevice	set		iAID= @iAID
					where	idDevice = @idDevice
			end

--			update	tbDevice	set		idParent= @idParent,	cSys= @cSys, tiGID= @tiGID, tiJID= @tiJID, tiRID= @tiRID
--				where	idDevice = @idDevice	and	iAID = @iAID

			if	@sCodeVer is not null
				update	tbDevice	set		sCodeVer= @sCodeVer
					where	idDevice = @idDevice

	--		select	@s =	@s + '  UPD'
		end
		else																-- insert new device
		begin
/*			if	@tiRID = 0		--	@cDevice = 'R'							--	7.06.5466 - since .idUnit is skipped in INSERT below
				select	@idUnit =	idParent								-- set room's current unit to primary CA's
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

			if	@iAID > 0													--	v.7.06.5855
				update	tbDevice	set		iAID= @iAID
					where	idDevice = @idDevice

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
--	Finds devices and re-activates or inserts if necessary (during run-time)
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

	set	nocount	on

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	if	charindex('SIP:', @sDevice) = 1										-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ' )'

	-- match 7967-P workflow station's (0x1A) 'phantom' RIDs
	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow
		select	@idDevice=	idDevice,	@bActive =	bActive
			from	tbDevice	with (nolock)
			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	--and	bActive > 0

		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice

			return	0												-- match found
		end
	end

	-- adjust AID
	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID = 0
		select	@iAID=	null


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

	if	@idDevice > 0																			--	7.06.5560
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		return	0															-- match found
	end

	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	begin
		begin	tran

			if	charindex(@cSys, @sSysts) = 0								-- not in Allowed Systems
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
	else																	-- no name / system		7.06.5560
	begin
		select	@s =	@s + '  sDvc'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed (in response to HL7 notification via cmd x44)
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

	select	@s =	'Pat_UL( [' + isnull(cast(@idPatient as varchar),'?') + '] "' + isnull(@sPatient,'?') +
					'", ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', [' + isnull(cast(@idRoom as varchar),'?') + '] ' + isnull(@sDevice,'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + ' )'

	if	@idRoom is null
		select	@s =	@s + ' SGJ'

	if	@tiBed > 9		or
		@idRoom is not null	and
		not exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
		select	@tiBed =	null,	@s =	@s + ' bed'

	if	(@tiBed = 0		or	@tiBed is null)
		and	exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
		select	@tiBed =	0xFF		-- auto-correct for no-bed rooms from bed 0

	if	@idRoom is null		or
		not exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
	begin
		begin tran

			exec	dbo.pr_Log_Ins	82, null, null, @s

			update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	null
				where	idPatient = @idPatient

		commit

		return	-1
	end

	begin	tran

		if	@idPatient > 0
		begin
			select	@idCurr =	idRoom,		@tiCurr =	tiBed
				from	tbRoomBed	with (nolock)
				where	idPatient = @idPatient

			if	@idRoom <> @idCurr	or	@tiBed <> @tiCurr		-- patient has moved?
				or	@idRoom is null	and	@idCurr > 0
				or	@idRoom > 0		and	@idCurr is null

				-- update the given room-bed with the given patient
				update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	@idPatient
					where	idRoom = @idRoom	and	tiBed = @tiBed
		end
		else	-- clear patient
				update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	null
					where	idRoom = @idRoom	and	tiBed = @tiBed

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@p			varchar( 16 )
		,		@dtEvent	datetime
		,		@tiHH		tinyint
		,		@cDevice	char( 1 )
		,		@cSys		char( 1 )
		,		@idParent	int
		,		@dtParent	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
--		,		@iExpNrm	int
		,		@iAID2		int
		,		@tiGID		tinyint
		,		@tiJID		tinyint
		,		@tiStype2	tinyint
		,		@sDvc		varchar( 16 )

	set	nocount	on

	select	@dtEvent =	getdate( ),		@p =	''
		,	@tiHH =		datepart( hh, getdate( ) )
		,	@cDevice =	case when @idCmd = 0x83 then 'G' else '?' end

	select	@iTrace =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 8
--	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9

	select	@s =	'Evt_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sSrcDvc,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sDstDvc,'?') + '", b=' + isnull(cast(@tiBed as varchar),'?') + ', i="' + isnull(@sInfo,'?') + '" )'

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

		if	@iTrace & 0x4000 > 0
			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins1'

		if	@tiBed is not null										-- mark a bed in active use
			update	tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)			-- audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiShelf =	@tiSrcRID,	@sDvc =		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiShelf,	@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

		if	@iTrace & 0x4000 > 0
			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins2'

		exec		dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

		if	@iTrace & 0x4000 > 0
			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins3'

		if	@idCmd <> 0x84	or	@idLogType <> 194					-- skip healing 84s
		begin
	--		insert	tbEvent	(  idCmd,  tiLen,  iHash,  vbCmd,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit
			insert	tbEvent	(  idCmd,  iHash,  sInfo,  idLogType,  idCall,  tiBtn,  tiBed,  idUnit
							,	cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  idSrcDvc
							,	cDstSys,  tiDstGID,  tiDstJID,  tiDstRID,  idDstDvc
							,	dtEvent,  dEvent,   tEvent,   tiHH )
	--				values	( @idCmd, @tiLen, @iHash, @vbCmd, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit
					values	( @idCmd, @iHash, @sInfo, @idLogType, @idCall, @tiBtn, @tiBed, @idUnit
							,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @idSrcDvc
							,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @idDstDvc
							,	@dtEvent, @dtEvent, @dtEvent, @tiHH )
			select	@idEvent =	scope_identity( )

			if	@tiLen > 0	and	@vbCmd is not null
				insert	tbEvent_B	(  idEvent,  tiLen,  vbCmd )			--	7.06.5562
						values		( @idEvent, @tiLen, @vbCmd )
		end

		if	@iTrace & 0x4000 > 0
			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins4'

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

		if	len(@p) > 0
		begin
			select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
			exec	dbo.pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02								-- set tbEvent.idParent, .idRoom, .tParent; tbRoom.idUnit
		begin

			if	@iTrace & 0x4000 > 0
				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins5'

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

			if	@iTrace & 0x4000 > 0
				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins6'

			if	@idParent > 0
				update	tbEvent		set	idParent =	@idParent,	idRoom =	@idRoom,	tParent =	dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	tbEvent		set	idParent =	@idEvent,	idRoom =	@idRoom,	tParent =	'0:0:0'
					where	idEvent = @idEvent

			if	@iTrace & 0x4000 > 0
				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins7'

			if	@idUnit > 0		and	@idRoom > 0						--	7.02	7.05.5205
				update	tbRoom		set	idUnit =	@idUnit
					where	idRoom = @idRoom

			if	@iTrace & 0x4000 > 0
				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins8'
		end

		if	@idEvent > 0											-- update event statistics
		begin
			select	@idParent=	null
			select	@idParent=	idEvent
				from	tbEvent_S	with (nolock)
				where	dEvent = cast(@dtEvent as date)		and	tiHH = @tiHH

			if	@idParent	is null
				insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
						values		( @dtEvent, @tiHH, @idEvent )
		end

		if	@iTrace & 0x4000 > 0
			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins9'

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
--	7.06.6297	* optimized log
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
		,		@iTrace		int
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
		,		@idDoctor	int
		,		@idPatient	int
		,		@idOrigin	int
		,		@dtOrigin	datetime
		,		@dtEvent	datetime
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int

	set	nocount	on

	select	@iTrace =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bPresence =	0

	select	@s =	'E84_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(@iAID as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins00'

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

--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins01'


	if	@tiSpec between 7 and 9
		select	@bPresence =	1,		@tiBed =	0xFF	-- mark 'presence' calls and force room-level


	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + '  bed'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed


	if	@tiBed is not null	and	len(@sPatient) > 0			-- only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
	end

--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins02'


	-- adjust need-timers (0=no need, 1=[G,O,Y] present, 2=need OT, 3=need request)
	if	@tiTmrA > 3		select	@tiTmrA =	3
	if	@tiTmrG > 3		select	@tiTmrG =	3
	if	@tiTmrO > 3		select	@tiTmrO =	3
	if	@tiTmrY > 3		select	@tiTmrY =	3


	-- origin points to the first still active event that started call-sequence for this SGJRB
	select	@idOrigin=	idEvent,	@dtOrigin=	dtEvent,	@bAudio =	bAudio
		from	tbEvent_A	with (nolock)
		where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0
			and	(siIdx = @siIdxNew	or	siIdx = @siIdxOld)		--	7.06.5855
---			and	(idCall = @idCall	or	idCall = @idCall0)		--	7.05.4976

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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins03'

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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins04'

		exec	dbo.prRoom_UpdStaff		@idRoom, @idUnit, @sStaffG, @sStaffO, @sStaffY

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins05'


		if	@idOrigin is null								-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss, @siElapsed, '0:0:0')
								,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent)
								,	@idSrcDvc=	idSrcDvc,	@idParent=	idParent
				where	idEvent = @idEvent

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins06'

			insert	tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
									siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,
									tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
									@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, @tiSvc, dateadd(ss, @iExpNrm, @dtEvent),
									@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins07'

	--		if	@idRoom > 0		and							-- 'medical' call or 'presence'		--	7.05.5212
	--			(@tiShelf > 0	and	( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 )
	--			or	@bPresence > 0)
			if	@idRoom > 0		and	@idUnit > 0				-- record every call in tbEvent_C	--	7.06.5562, 7.06.5613
				begin
					select	@idUser =	case
								when @tiSpec = 7	then idUserG
								when @tiSpec = 8	then idUserO
								when @tiSpec = 9	then idUserY
								else					 null	end
						from	tbRoom	with (nolock)
						where	idRoom = @idRoom

					select	@idShift =	u.idShift			--	7.06.6017
						,	@dShift =	case when sh.tEnd <= sh.tBeg	and	cast(@dtOrigin as time) < sh.tEnd	then	dateadd( dd, -1, @dtOrigin )	else	@dtOrigin	end
	--	7.06.6051		,	@dShift =	case when sh.tBeg < sh.tEnd	then	@dtOrigin	else	dateadd( dd, -1, @dtOrigin )	end
						from	tbUnit	u
						join	tbShift	sh	on	sh.idShift = u.idShift
						where	u.idUnit = @idUnit	and	u.bActive > 0

					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, idUser1, tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, @idUser, datepart(hh, @dtOrigin) )

--					if	@iTrace & 0x4000 > 0
--						exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins08'

					if	@bPresence = 0						--	7.06.5665
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

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins09'

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	siIdx=	@siIdxNew,	idCall =	@idCall		--	7.06.5855
				where	idEvent = @idOrigin					--	7.05.5065

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins10'

			update	tbEvent_A	set	tiSvc=	@tiSvc			-- update state for all calls in this room
				where	idRoom = @idRoom					--	7.06.5534
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins11'


		if	@siIdxNew = 0									-- call cancelled
		begin
	--		select	@dtOrigin=	case when @bAudio = 0 then dateadd(ss, @iExpNrm, @dtEvent)
	--												else dateadd(ss, @iExpExt, @dtEvent) end

			update	tbEvent_A	set	dtExpires=	case when @bAudio = 0 then dateadd(ss, @iExpNrm, @dtEvent)
																	else dateadd(ss, @iExpExt, @dtEvent) end	--@dtOrigin
							,	tiSvc=	null,	bActive =	0
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins12'

			select	@dtOrigin=	tOrigin,	@idParent=	idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent

			update	tbEvent_C	set	idEvtSt =	@idEvent,	tStaff =	@dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null		-- there should be only one, but just in case - use only 1st one
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins13'


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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins14'


		---	!! @idEvent no longer points to current event !!

		-- set tbRoom.idEvent and .tiSvc to highest oldest active call for this room
		select	@idEvent =	null,	@tiSvc =	null
		select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent							-- oldest in recorded order
		---	order	by	siIdx desc, tElapsed desc					-- call may have started before it was recorded

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins15'

		update	tbRoom	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
			where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins16'

		-- clear room state when there's no 'presence'		--	7.06.5534
		if	@tiSvc is null	or	@tiSvc & 0x30 <> 0x10
			update	tbRoom	set	idUserG= null, sStaffG= null	where	idRoom = @idRoom
--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins17'
		if	@tiSvc is null	or	@tiSvc & 0x0C <> 0x04
			update	tbRoom	set	idUserO= null, sStaffO= null	where	idRoom = @idRoom
--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins18'
		if	@tiSvc is null	or	@tiSvc & 0x03 <> 0x01
			update	tbRoom	set	idUserY= null, sStaffY= null	where	idRoom = @idRoom
--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins19'


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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins20'

	commit

	select	@idEvent =	@idOrigin			--	7.05.5267	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
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

	select	@s =	'E41_I( s=' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' :' + isnull(cast(@tiBtn as varchar),'?') + ' "' + isnull(@sSrcDvc,'?') +
					'", b=' + isnull(cast(@tiBed as varchar),'?') + ', d=' + isnull(cast(@idDvc as varchar),'?') +
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

		select	@s =	@s + ' id=' + isnull(cast(@idEvent as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') +
						', r=' + isnull(cast(@idRoom as varchar),'?')

		update	tbEvent		set	tiDstRID =	@tiSeqNum,	tiFlags =	ascii(@cStatus)
			where	idEvent = @idEvent

		if	@idDvc > 0
			insert	tbEvent41	(  idEvent,  idPcsType,  idDvc,  idUser )
					values		( @idEvent, @idPcsType, @idDvc, @idUser )
		else
			exec	dbo.pr_Log_Ins	82, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6298	+ .idModule
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Log') and name = 'idModule')
begin
	begin tran
		alter table	dbo.tb_Log	add
			idModule	tinyint			null		-- module performing the action
				constraint	fk_Log_Module	foreign key references	tb_Module
	commit
end
go
--	----------------------------------------------------------------------------
--	<512,tb_Log>
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Log') and name = 'idModule' and is_nullable=1)
begin
	declare	@s	varchar(32)

	select	@s =	name	from	master.sys.databases	where	database_id = db_id( )

	begin tran
/*		update	tb_Log	set	idModule =	20	where	sLog like '%J7970as%'
		update	tb_Log	set	idModule =	21	where	sLog like '%J7976is%'
		update	tb_Log	set	idModule =	60	where	sLog like '%J7980cs%'
		update	tb_Log	set	idModule =	61	where	sLog like '%J7980ns%'	or	idLogType in (189,190)	and	@s = 'db7980'
		update	tb_Log	set	idModule =	62	where	sLog like '%J7980cw%'	or	idLogType between 231 and 249	and	@s = 'db7980'
		update	tb_Log	set	idModule =	63	where	sLog like '%J7980rh%'	or	idLogType between 221 and 230	and	@s = 'db7980'
		update	tb_Log	set	idModule =	64	where	sLog like '%J7982cw%'
--		update	tb_Log	set	idModule =	71	where	sLog like '%J7981ds%'
		update	tb_Log	set	idModule =	72	where	sLog like '%J7981ls%'	or	idLogType in (48,49)
		update	tb_Log	set	idModule =	73	where	sLog like '%J7981cw%'
		update	tb_Log	set	idModule =	90	where	sLog like '%J7983cs%'
		update	tb_Log	set	idModule =	91	where	sLog like '%J7983ls%'	or	(idLogType between 231 and 249	or	idLogType in (189,190))	and	@s = 'db7983'	or	idLogType in (46,47)
		update	tb_Log	set	idModule =	92	where	sLog like '%J7983rh%'	or	idLogType between 221 and 230	and	@s = 'db7983'
		update	tb_Log	set	idModule =	93	where	sLog like '%J7983ss%'	or	idLogType in (90)	or	sLog like '%SMTP%'
		update	tb_Log	set	idModule =	111	where	sLog like '%J7985cw%'
		update	tb_Log	set	idModule =	121	where	sLog like '%J7986cw%'
--		update	tb_Log	set	idModule =		where	sLog like '%%'
*/
		if	@s = 'db7970'
		begin
			update	tb_Log	set	idModule =	20	where	sLog like '%J7970as%'
		end
		else
		if	@s = 'db7980'
		begin
			update	tb_Log	set	idModule =	60	where	sLog like '%J7980cs%'
			update	tb_Log	set	idModule =	61	where	sLog like '%J7980ns%'	or	idLogType in (189,190)
			update	tb_Log	set	idModule =	62	where	sLog like '%J7980cw%'	or	idLogType between 231 and 249
			update	tb_Log	set	idModule =	63	where	sLog like '%J7980rh%'	or	idLogType between 221 and 230
			update	tb_Log	set	idModule =	72	where	sLog like '%J7981ls%'	or	idLogType in (48,49)
			update	tb_Log	set	idModule =	73	where	sLog like '%J7981cw%'
			update	tb_Log	set	idModule =	64	where	sLog like '%J7982cw%'
			update	tb_Log	set	idModule =	111	where	sLog like '%J7985cw%'
			update	tb_Log	set	idModule =	121	where	sLog like '%J7986cw%'
		end
		else
--	-	if	@s = 'db7983'
		begin
			update	tb_Log	set	idModule =	21	where	sLog like '%J7976is%'
			update	tb_Log	set	idModule =	90	where	sLog like '%J7983cs%'
			update	tb_Log	set	idModule =	91	where	sLog like '%J7983ls%'	or	idLogType in (46,47)	or	(idLogType between 231 and 249	or	idLogType in (189,190))
			update	tb_Log	set	idModule =	92	where	sLog like '%J7983rh%'	or	idLogType between 221 and 230
			update	tb_Log	set	idModule =	93	where	sLog like '%J7983ss%'	or	idLogType in (90)	or	sLog like '%SMTP%'
		end

		update	tb_Log	set	idModule =	1	where	idModule is null		--	mark the rest as DB-level

		alter table	dbo.tb_Log	alter column
			idModule	tinyint			not null
	commit
end
go
--	----------------------------------------------------------------------------
--	Audit log
--	7.06.6298	+ .idModule
--	7.06.5399	* optimized
--	6.07
alter view		dbo.vw_Log
	with encryption
as
	select	l.idLog, l.dLog, l.tLog, l.idLogType, t.sLogType, l.idModule, m.sModule, l.sLog, l.dtLog, l.idUser, u.sUser
		from	tb_Log		l	with (nolock)
		join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
		left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
		left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
go
--	----------------------------------------------------------------------------
--	Audit log module filters (active during a user session)
--	7.06.6303
create table	dbo.tb_SessLog
(
	idSess		int				not null
		constraint	fk_SessLog_Sess		foreign key references tb_Sess
,	idModule	tinyint			not null
		constraint	fk_SessLog_Module	foreign key references tb_Module
	
,	constraint	xp_SessLog	primary key clustered ( idSess, idModule )
)
go
grant	select, insert, update, delete	on dbo.tb_SessLog		to [rWriter]
grant	select, insert, update, delete	on dbo.tb_SessLog		to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans-up session's filter tables
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

		delete from	tb_SessUser		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessShift	where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessCall		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessLog		where	idSess = @idSess	or	@idSess is null
--	-	delete from	tb_SessLoc		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessDvc		where	idSess = @idSess	or	@idSess is null

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6304	- .idOper
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Log') and name = 'idOper')
begin
	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fk_Log_Oper')
			alter table	dbo.tb_Log	drop constraint	fk_Log_Oper

		alter table	dbo.tb_Log	drop column	idOper
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
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

	set	nocount	on

	select	@dt =	getdate( )

	set	nocount	off

--	begin	tran

		insert	tb_Log	(  idLogType,  idModule,  idUser,  sLog,	dtLog,	dLog,	tLog,	tiHH )
				values	( @idLogType, @idModule, @idUser, @sLog,	@dt,	@dt,	@dt,	datepart( hh, @dt ) )
	--	select	@idLog=	scope_identity( )

--	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
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
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		dtStart =	getdate( ),		sParams =	@sParams,	sIpAddr =	@sIpAddr,	sMachine =	@sMachine
				where	idModule = @idModule
		else
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		dtStart =	null,			sParams =	null
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
--	Inserts a session's room filter
--	7.06.6310
create proc		dbo.pr_SessLog_Ins
(
	@idSess		int
,	@idModule	smallint
)
	with encryption
as
begin
	set	nocount	on

	if	not	exists	(select 1 from tb_SessLog with (nolock) where idSess=@idSess and idModule=@idModule)
	begin
--		begin	tran
			insert	tb_SessLog	(  idSess,  idModule )
					values		( @idSess, @idModule )
--		commit
	end
	else
		return	-1		-- room is already included
end
go
grant	execute				on dbo.pr_SessLog_Ins				to [rWriter]
grant	execute				on dbo.pr_SessLog_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans-up session's module tables
--	7.06.6310
create proc		dbo.pr_SessLog_Clr
(
	@idSess		int
)
	with encryption
as
begin
--	set	nocount	on
--	begin	tran

		delete from	tb_SessLog		where	idSess = @idSess

--	commit
end
go
grant	execute				on dbo.pr_SessLog_Clr				to [rWriter]
grant	execute				on dbo.pr_SessLog_Clr				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns log entries in a page of given size
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
,	@tiSrc		tinyint				-- bitwise tb_LogType.tiSrc, 0xFF=include all
,	@iPages		int				out	-- total # of pages
,	@idSess		int			=	0	-- when not 0 filter sources using tb_SessLog
)
	with encryption
as
begin
	declare		@idLog		int

	set	nocount	on

	select	@iIndex =	@iIndex * @iCount + 1		-- index of the 1st output row

	if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no level or category filtering
		if	@idSess = 0
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log	with (nolock)

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log	with (nolock)
				order	by	idLog desc
		end
		else										-- filter by source
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log		l	with (nolock)
				join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log		l	with (nolock)
				join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess
				order	by	idLog desc
		end
	else											-- filter by level or category
		if	@idSess = 0
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log l	with (nolock)
				join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
				where	t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log l	with (nolock)
				join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
				where	t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0
				order	by	idLog desc
		end
		else										-- filter by source
		begin
			select	@iPages =	ceiling( count(*) / @iCount )
				from	tb_Log		l	with (nolock)
				join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on	t.idLogType = l.idLogType
				where	t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log		l	with (nolock)
				join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on	t.idLogType = l.idLogType
				where	t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0
				order	by	idLog desc
		end

	set	rowcount	@iCount
	set	nocount	off
	if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no level or category filtering
		if	@idSess = 0
			select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser
				from	tb_Log		l	with (nolock)
		--	-	join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
				left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
				where	idLog <= @idLog
				order	by 1 desc
		else										-- filter by source
			select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser
				from	tb_Log		l	with (nolock)
				join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
				left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
				where	idLog <= @idLog
				order	by 1 desc
	else											-- filter by level or category
		if	@idSess = 0
			select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser
				from	tb_Log		l	with (nolock)
		--	-	join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
				left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
				where	idLog <= @idLog
				and		t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0
				order	by 1 desc
		else										-- filter by source
			select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser
				from	tb_Log		l	with (nolock)
				join	tb_SessLog	sl	with (nolock)	on sl.idModule = l.idModule		and	sl.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
				left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
				left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
				where	idLog <= @idLog
				and		t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0
				order	by 1 desc

	set	rowcount	0
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
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
--,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
--,	@sMachine	varchar( 32 )		-- client computer's name

,	@idUser		int				out	-- null if attempt failed
,	@sStaff		varchar( 16 )	out	-- full-name
--,	@sFrst		varchar( 32 )	out	-- first-name
--,	@sLast		varchar( 32 )	out	-- last-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
,	@sStaffID	varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idModule	tinyint
		,		@iHass		int
		,		@bActive	bit
		,		@bLocked	bit
		,		@idLogType	tinyint
		,		@tiFails	tinyint
		,		@tiMaxAtt	tinyint
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )

	set	nocount	on

	select	@tiMaxAtt =		cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule
		from	tb_Sess		with (nolock)
		where	idSess = @idSess

	select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@iHass =	iHash,	@bActive =	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff,		@sStaffID=	sStaffID
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule
		return	@idLogType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType =	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType =	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@iHass <> @iHash		--	wrong pass
	begin
		select	@idLogType =	223,	@s =	@s + ', attempt ' + cast( @tiFails + 1 as varchar )

		begin	tran

			if	@tiFails < @tiMaxAtt - 1
				update	tb_User		set	tiFails =	tiFails + 1
					where	idUser = @idUser
			else
			begin
				update	tb_User		set	tiFails =	0xFF
					where	idUser = @idUser
				select	@s =	@s + ', locked-out'
			end
			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
		return	@idLogType
	end

	select	@idLogType =	221,	@bAdmin =	0
	if	exists(	select 1 from tb_UserRole where idUser = @idUser and idRole = 2 )
		select	@bAdmin =	1

	begin	tran

		update	tb_Sess		set	dtLastAct=	getdate( ),		idUser =	@idUser
			where	idSess = @idSess
		update	tb_User		set	dtLastAct=	getdate( ),		tiFails =	0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	7.06.6543	+ @sStaffID
--	7.06.6311	+ @idModule logging (pr_Log_Ins call)
--	7.06.5969
alter proc		dbo.pr_User_Login2
(
	@idSess		int					-- session-id
,	@gGUID		uniqueidentifier	-- AD GUID
--,	@iHash		int					-- calculated password 32-bit hash (Murmur2)
--,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
--,	@sMachine	varchar( 32 )		-- client computer's name

,	@sUser		varchar( 32 )	out	-- login-name, lower-cased
,	@idUser		int				out	-- null if attempt failed
,	@sStaff		varchar( 16 )	out	-- full-name
--,	@sFrst		varchar( 32 )	out	-- first-name
--,	@sLast		varchar( 32 )	out	-- last-name
,	@bAdmin		bit				out	-- is user member of built-in Admins role?
,	@sStaffID	varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idModule	tinyint
--		,		@iHass		int
		,		@bActive	bit
		,		@bLocked	bit
		,		@idLogType	tinyint
		,		@tiFails	tinyint
		,		@tiMaxAtt	tinyint
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )

	set	nocount	on

	select	@tiMaxAtt =		cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule
		from	tb_Sess		with (nolock)
		where	idSess = @idSess

	select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@sUser =	sUser,	@bActive =	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff,		@sStaffID=	sStaffID
		from	tb_User		with (nolock)
		where	gGUID = @gGUID												--	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule
		return	@idLogType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType =	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType =	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

--	if	@iHass <> @iHash		--	wrong pass
--	..

	select	@idLogType =	221,	@bAdmin =	0
	if	exists	(select 1 from tb_UserRole where idUser = @idUser and idRole = 2)
		select	@bAdmin =	1

	begin	tran

		update	tb_Sess		set	dtLastAct=	getdate( ),		idUser =	@idUser
			where	idSess = @idSess
		update	tb_User		set	dtLastAct=	getdate( ),		tiFails =	0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
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

	set	nocount	on

	select	@idUser =	idUser,		@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule
		from	tb_Sess
		where	idSess = @idSess

	if	@idUser > 0
	begin
		begin	tran

			update	tb_Sess		set	dtLastAct=	getdate( ),	idUser =	null
				where	idSess = @idSess

			select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.6340	+ .tiLvl
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'tiLvl')
begin
	begin tran
		alter table	dbo.tbCfgPri	add
			tiLvl		tinyint			null		-- 0=Non-Clinic, 1=Clinic-None, 2=Clinic-Patient, 3=Clinic-Staff, 4=Clinic-Doctor
	commit
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'tiLvl' and is_nullable=1)
begin
	begin tran
		update	tbCfgPri	set	tiLvl=	0			-- Non-Clinic

		alter table	dbo.tbCfgPri	alter column
			tiLvl		tinyint			not null
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.6340	+ .tiLvl
--	7.06.6177	* .tiLight -> .tiDome
--	7.06.5914	* .dtCreated -> .dtUpdated
--	7.06.5687	+ .siIdxUg, .siIdxOt, .tiOtInt, .tiLight, .tiTone, .tiToneInt
--	7.04.4898
alter proc		dbo.prCfgPri_GetAll
(
	@bEnabled	bit					--	0=any, 1=only
)
	with encryption
as
begin
--	set	nocount	on
	select	siIdx, sCall, tiFlags, tiShelf, tiLvl, tiSpec, iColorF, iColorB, iFilter
	/*	,	cast(tiFlags & 0x01 as bit)		as	bLocking
		,	cast(tiFlags & 0x02 as bit)		as	bEnabled
		,	cast(tiFlags & 0x04 as bit)		as	bControl
		,	cast(tiFlags & 0x08 as bit)		as	bRndRmnd
		,	cast(tiFlags & 0x10 as bit)		as	bSequenc
		,	cast(tiFlags & 0x20 as bit)		as	bXclusiv
		,	cast(tiFlags & 0x40 as bit)		as	bTargett
		,	cast(tiFlags & 0x80 as bit)		as	bReservd
	*/	,	siIdxUg, siIdxOt, tiOtInt, tiDome, tiTone, tiToneInt
		,	dtUpdated
		from	tbCfgPri	with (nolock)
		where	@bEnabled = 0	or	tiFlags & 0x02 > 0
		order	by	1 desc
end
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
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
,	@tiFlags	tinyint				-- bit flags: 1=locking, 2=enabled
,	@tiShelf	tinyint				-- shelf: 0=nondisplay, 1=routine, 2=urgent, 3=emergency, 4=code
,	@tiSpec		tinyint				-- special priority
,	@siIdxUg	smallint			-- upgrade priority-index
,	@siIdxOt	smallint			-- overtime priority-index
,	@tiOtInt	tinyint				-- overtime interval, min
,	@tiDome		tinyint				-- light-show index
,	@tiTone		tinyint				-- tone index
,	@tiToneInt	tinyint				-- tone interval, min
,	@iColorF	int					-- foreground color (ARGB) - text
,	@iColorB	int					-- background color (ARGB)
,	@iFilter	int					-- priority filter-mask
)
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Pri_U( ' + isnull(cast(@siIdx as varchar), '?') +	', n="' + isnull(@sCall, '?') +
				'", f='  + isnull(cast(@tiFlags as varchar), '?') +	', sh=' + isnull(cast(@tiShelf as varchar), '?') +
				', sp=' + isnull(cast(@tiSpec as varchar), '?') +
				', ug=' + isnull(cast(@siIdxUg as varchar), '?') +	', ot=' + isnull(cast(@siIdxOt as varchar), '?') +
				', oi=' + isnull(cast(@tiOtInt as varchar), '?') +	', ls=' + isnull(cast(@tiDome as varchar), '?') +
				', tn=' + isnull(cast(@tiTone as varchar), '?') +	', ti=' + isnull(cast(@tiToneInt as varchar), '?') +
				', cf=' + isnull(cast(@iColorF as varchar), '?') +	', cb=' + isnull(cast(@iColorB as varchar), '?') +
				', fm=' + isnull(cast(@iFilter as varchar), '?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgPri where siIdx = @siIdx)
			update	tbCfgPri	set		sCall=	@sCall,		tiFlags =	@tiFlags
				,	tiShelf =	@tiShelf,	tiSpec =	@tiSpec,	siIdxUg =	@siIdxUg,	siIdxOt =	@siIdxOt
				,	tiOtInt =	@tiOtInt,	tiDome =	@tiDome,	tiTone =	@tiTone,	tiToneInt=	@tiToneInt
				,	iColorF =	@iColorF,	iColorB =	@iColorB,	iFilter =	@iFilter
				where	siIdx = @siIdx
		else
			insert	tbCfgPri	(  siIdx,  sCall,  tiFlags,  tiShelf, tiLvl,  tiSpec,  siIdxUg,  siIdxOt,  tiOtInt,  tiDome,  tiTone,  tiToneInt,  iColorF,  iColorB,  iFilter )
					values		( @siIdx, @sCall, @tiFlags, @tiShelf,     0, @tiSpec, @siIdxUg, @siIdxOt, @tiOtInt, @tiDome, @tiTone, @tiToneInt, @iColorF, @iColorB, @iFilter )

		if	@iTrace & 0x40 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Sets given priority's clinic level
--	7.06.6345	* update and log only changes
--	7.06.6340
create proc		dbo.prCfgPri_SetLvl
(
	@siIdx		smallint			-- call-index
,	@tiLvl		tinyint				-- clinic level
)
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Pri_SL( ' + isnull(cast(@siIdx as varchar), '?') + ', l=' + isnull(cast(@tiLvl as varchar), '?') + ' )'

	begin	tran
		update	tbCfgPri	set	tiLvl=	@tiLvl,	dtUpdated=	getdate( )
			where	siIdx = @siIdx	and	tiLvl <> @tiLvl

		if	@iTrace & 0x40 > 0	and	@@rowcount > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s
	commit
end
go
grant	execute				on dbo.prCfgPri_SetLvl				to [rWriter]
grant	execute				on dbo.prCfgPri_SetLvl				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a filter definition
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
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Flt_I( ' + isnull(cast(@idIdx as varchar), '?') + ', f=' + isnull(cast(@iFilter as varchar), '?') + ', n="' + isnull(@sFilter, '?') + '" )'

	begin	tran

		insert	tbCfgFlt	(  idIdx,  iFilter,  sFilter )
				values		( @idIdx, @iFilter, @sFilter )

		if	@iTrace & 0x40 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a tone definition
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
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Tone_I( ' + isnull(cast(@tiTone as varchar), '?') + ', n="' + isnull(@sTone, '?') + '" )'

	begin	tran

		insert	tbCfgTone	(  tiTone,  sTone,  vbTone )
				values		( @tiTone, @sTone, @vbTone )

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
--	7.06.6345	* added quotes in trace
--	7.06.5914	* optimized
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
,	@sLoc		varchar( 16 )		-- location name
)
	with encryption
as
begin
	declare		@iTrace		int
			,	@s			varchar( 255 )

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', p=' + isnull(cast(@idParent as varchar), '?') +
				', l=' + isnull(cast(@tiLvl as varchar), '?') + ', n="' + isnull(@sLoc, '?') + '" )'

	begin	tran

		insert	tbCfgLoc	(  idLoc,  idParent,  tiLvl,  cLoc,  sLoc, sPath )
				values		( @idLoc, @idParent, @tiLvl, '?', @sLoc, '' )

		if	@iTrace & 0x02 > 0
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a doctor record
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

	select	@s=	'Doc_U( id=' + isnull(cast(@idDoctor as varchar),'?') +
				', n="' + isnull(@sDoctor,'?') + '", a=' + cast(@bActive as varchar) + ' )'

	begin	tran
		update	tbDoctor	set	sDoctor= @sDoctor, bActive= @bActive
							,	dtUpdated=	getdate( )
			where	idDoctor = @idDoctor

		exec	dbo.pr_Log_Ins	44, null, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a patient record
--	7.06.6345	* added quotes in trace
--	6.05		* tracing
--	6.04
alter proc		dbo.prPatient_Upd
(
	@idPatient	int out				-- output
,	@sPatient	varchar( 16 )		-- full name (HL7)
,	@cGender	char( 1 )
,	@sInfo		varchar( 32 )
,	@sNote		varchar( 255 )
,	@bActive	bit
)
	with encryption
as
begin
	declare		@s		varchar( 255 )

	set	nocount	on

	select	@s=	'Pat_U( id=' + isnull(cast(@idPatient as varchar),'?') +
				', p="' + isnull(@sPatient,'?') + '", g=' + isnull(@cGender,'?') + ', i="' + isnull(@sInfo,'?') +
				'", n="' + isnull(@sNote,'?') + '", a=' + cast(@bActive as varchar) + ' )'

	begin	tran
		update	tbPatient	set	sPatient= @sPatient, cGender= @cGender, sInfo= @sInfo, sNote= @sNote, bActive= @bActive
							,	dtUpdated=	getdate( )
			where	idPatient = @idPatient

		exec	dbo.pr_Log_Ins	44, null, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
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

				select	@idLogType =	62
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

			select	@s =	@s + ' INS'
		end

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates given module's license bit
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

	select	@s= 'Mod_Lic( ' + right('00' + cast(@idModule as varchar), 3) + ', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'

	begin	tran

		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule and bLicense <> @bLicense)
		begin
			update	tb_Module	set	bLicense =	@bLicense
				where	idModule = @idModule

			exec	dbo.pr_Log_Ins	63, null, null, @s, @idModule
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Clinic activity log: patient events
--	7.06.6402	restore .idShift, .dShift, .siBed, .tiBed
--	7.06.6345
create table	dbo.tbEvent_D
(
	idEvent		int				not null	-- ?? bigint
		constraint	xpEventD	primary key clustered
		constraint	fkEventD_Event		foreign key references	tbEvent	on delete cascade

,	dEvent		date			not null
,	tEvent		time( 3 )		not null
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
,	tRoomP		time( 3 )		null		-- patient's time in room
,	idEvntS		int				null		-- staff entered
		constraint	fkEventD_EvntS		foreign key references	tbEvent	--on delete set null
,	tWaitS		time( 3 )		null		-- patient's wait-for-staff time
,	tRoomS		time( 3 )		null		-- staff's time in room
,	idEvntD		int				null		-- doctor extered
		constraint	fkEventD_EvntD		foreign key references	tbEvent	--on delete set null
,	tWaitD		time( 3 )		null		-- patient's wait-for-doctor time
,	tRoomD		time( 3 )		null		-- doctor's time in room
)
create index	xtEventD_dEvent_tiHH	on	dbo.tbEvent_D ( dEvent, tiHH )
go
grant	select, insert, update, delete	on dbo.tbEvent_D		to [rWriter]
grant	select							on dbo.tbEvent_D		to [rReader]
go
alter table	tbEvent_D	add
	constraint	fkEventD_Shift		foreign key (idShift) references tbShift		--	7.06.6402
go
--	----------------------------------------------------------------------------
--	7.06.6410	+ .idCallS, .idCallD
--	7.06.6402
create view		dbo.vwEvent_D
	with encryption
as
select	ep.idEvent, ep.dEvent, ep.tEvent, ep.tiHH, ep.idCall, c.sCall
	,	ep.idUnit, u.sUnit,		ep.idShift, ep.dShift
	,	ep.idRoom, d.cDevice, d.sDevice, d.sDial,	ep.tiBed, cb.cBed, ep.siBed
	,	d.sDevice + case when ep.tiBed is null then '' else ' : ' + cb.cBed end	as	sRoomBed
	,	ep.tRoomP
	,	ep.idEvntS, ep.tWaitS, ep.tRoomS, es.idCall	as	idCallS
	,	ep.idEvntD, ep.tWaitD, ep.tRoomD, ed.idCall	as	idCallD
	from		tbEvent_D	ep	with (nolock)
	join		tbCall		c	with (nolock)	on	c.idCall = ep.idCall
	join		tbUnit		u	with (nolock)	on	u.idUnit = ep.idUnit
	join		tbDevice	d	with (nolock)	on	d.idDevice = ep.idRoom
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ep.tiBed
	left join	vwEvent		es	with (nolock)	on	es.idEvent = ep.idEvntS
	left join	vwEvent		ed	with (nolock)	on	ed.idEvent = ep.idEvntD
go
grant	select, insert, update, delete	on dbo.vwEvent_D		to [rWriter]
grant	select							on dbo.vwEvent_D		to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.6355	+ .tiLvl
/*
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_A') and name = 'tiLvl')
begin
	begin tran
		alter table	dbo.tbEvent_A	add
			tiLvl		tinyint			null		-- 0=Non-Clinic, 1=Clinic-None, 2=Clinic-Patient, 3=Clinic-Staff, 4=Clinic-Doctor
	commit
end
*/
go
--	7.06.6373	- .tiLvl
/*
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_A') and name = 'tiLvl')
begin
	begin tran
		alter table	dbo.tbEvent_A	drop column		tiLvl
	commit
end
*/
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
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

	select	@s =	'[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
					'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
					'", e="' + isnull(cast(@sEmail as varchar), '?') + '", d="' + isnull(cast(@sDesc as varchar), '?') +
					'", i="' + isnull(cast(@sStaffID as varchar), '?') + '", sl=' + isnull(cast(@idStfLvl as varchar), '?') +
					', b="' + isnull(cast(@sBarCode as varchar), '?') + '", od=' + isnull(cast(@bOnDuty as varchar), '?') +
					', a=' + cast(@bActive as varchar)
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff
							,  sStaffID,  idStfLvl,  sBarCode,  sUnits,  sTeams,  bOnDuty,  bActive )
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '
							, @sStaffID, @idStfLvl, @sBarCode, @sUnits, @sTeams, @bOnDuty, @bActive )
			select	@idOper =	scope_identity( )

			select	@s =	'User_I( ' + @s + ' ) = ' + cast(@idOper as varchar)
				,	@k =	237
		end
		else
		begin
			update	tb_User	set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
								,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
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
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	rm.idUnit,	ea.idRoom, r.sDevice	as	sRoom,	ea.tiBed, cb.cBed
	,	r.sDevice + case when ea.tiBed is null or ea.tiBed = 0xFF then '' else ' : ' + cb.cBed end		as	sRoomBed
	,	ea.idCall, c.siIdx, c.sCall, cp.iColorF, cp.iColorB, cp.tiShelf, cp.tiLvl, cp.tiSpec, cp.iFilter, cp.tiDome, cd.tiPrism, cp.tiTone, cp.tiToneInt
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit )		as	bAnswered
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) )	as	tElapsed,	ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	from		tbEvent_A	ea	with (nolock)
	left join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left join	tbRoom		rm	with (nolock)	on	rm.idRoom = ea.idRoom
	left join	tbCall		c	with (nolock)	on	c.idCall = ea.idCall
	left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
	left join	tbCfgDome	cd	with (nolock)	on	cd.tiDome = cp.tiDome
	left join	tbCfgBed	cb	with (nolock)	on	cb.tiBed = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Inserts common event header
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@p			varchar( 16 )
		,		@dtEvent	datetime
		,		@tiHH		tinyint
		,		@cDevice	char( 1 )
		,		@cSys		char( 1 )
		,		@idParent	int
		,		@dtParent	datetime
		,		@tiLvl		tinyint
		,		@iAID2		int
		,		@tiGID		tinyint
		,		@tiJID		tinyint
		,		@tiStype2	tinyint
		,		@sDvc		varchar( 16 )

	set	nocount	on

	select	@dtEvent =	getdate( ),		@p =	''
		,	@tiHH =		datepart( hh, getdate( ) )
		,	@cDevice =	case when @idCmd = 0x83 then 'G' else '?' end

	select	@iTrace =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s =	'Evt_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sSrcDvc,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sDstDvc,'?') + '", b=' + isnull(cast(@tiBed as varchar),'?') + ', i="' + isnull(@sInfo,'?') + '" )'

	if	@tiBed = 0xFF
		select	@tiBed =	null
	else
	if	@tiBed > 9
		select	@tiBed =	null,	@p =	@p + ' !B'						-- invalid bed

	if	@idUnit > 0	and	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + ' !U'						-- invalid unit

	begin	tran

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins1'

		if	@tiBed is not null												-- mark a bed in active use
			update	tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)					-- audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiLvl =	@tiSrcRID,	@sDvc =		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiLvl,		@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins2'

		exec		dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins3'

		if	@idCmd <> 0x84	or	@idLogType <> 194							-- skip healing 84s
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
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins4'

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

		if	len(@p) > 0
		begin
			select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
			exec	dbo.pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02										-- set tbEvent.idParent, .idRoom, .tParent; tbRoom.idUnit
		begin

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins5'

			select	@tiLvl =	tiLvl										--	7.06.6355
				from	tbCfgPri	cp	with (nolock)
				join	tbCall		c	with (nolock)	on	c.siIdx = cp.siIdx
				where	c.idCall = @idCall

			if	@idCmd = 0x84	and	@tiLvl > 2								--	7.06.6355
				select	@idParent=	idEvent,	@dtParent=	dtEvent
					from	tbEvent_A	ea	with (nolock)
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = ea.siIdx
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID
					and		bActive > 0			and	cp.tiLvl = 2			-- clinic-patient
			else
				select	@idParent=	idEvent,	@dtParent=	dtEvent			--	7.04.4968
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

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins6'

			if	@idParent > 0
				update	tbEvent		set	idParent =	@idParent,	idRoom =	@idRoom,	tParent =	dtEvent - @dtParent
					where	idEvent = @idEvent
			else
				update	tbEvent		set	idParent =	@idEvent,	idRoom =	@idRoom,	tParent =	'0:0:0'
					where	idEvent = @idEvent

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins7'

			if	@idUnit > 0		and	@idRoom > 0								--	7.02	7.05.5205
				update	tbRoom		set	idUnit =	@idUnit
					where	idRoom = @idRoom

--			if	@iTrace & 0x4000 > 0
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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins9'

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
		,		@iTrace		int
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
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiLvl		tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int
		,		@idEvDup	int

	set	nocount	on

	select	@iTrace =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bPresence =	0

	select	@s =	'E84_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(@iAID as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins00'

	if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + '  !U'						-- invalid unit


	if	@siIdxNew > 0														-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,	@siIdxUg =	siIdxUg		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew						-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0													-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,	@siIdxUg =	siIdxUg		from	tbCfgPri	with (nolock)	where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0													-- INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out					-- no need to call

--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins01'


	if	@tiSpec between 7 and 9
		select	@bPresence =	1,		@tiBed =	0xFF					-- mark 'presence' calls and force room-level


	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + '  !B'
	else
		select	@siBed =	siBed	from	tbCfgBed	with (nolock)	where	tiBed = @tiBed


	if	@tiBed is not null	and	len(@sPatient) > 0							-- only bed-level calls have meaningful patient data
	begin
		exec	dbo.prPatient_GetIns	@sPatient, @cGender, @sInfo, @sDoctor, @idPatient out, @idDoctor out
		exec	dbo.prPatient_UpdLoc	@idPatient, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBed		--	7.05.5204
	end

--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins02'


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
		,	@idLogType =	case when	@idOrigin is null	then			-- call placed
									case when	@bPresence > 0	then 206	else 191 end
								when	@siIdxNew = 0		then			-- cancelled
									case when	@bPresence > 0	then 207	else 193 end
								else										-- escalated or healing
									case when	@idCall0 > 0	then 192	else 194 end	end

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd
				,	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins03'

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

			if	len(@p) > 0													-- invalid data detected (bed|unit)
			begin
				select	@s =	@s + '  id=' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins04'

		exec	dbo.prRoom_UpdStaff		@idRoom, @idUnit, @sStaffG, @sStaffO, @sStaffY

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins05'


		if	@idOrigin is null												-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss, @siElapsed, '0:0:0')
								,	@dtOrigin=	dateadd(ss, -@siElapsed, dtEvent)
								,	@idSrcDvc=	idSrcDvc,	@idParent=	idParent
				where	idEvent = @idEvent

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins06'

			select		@idEvDup =	idEvent,	@siPriOld=	siIdx			-- addressing xuEventA_Active_SGJRB errors	--	7.06.6410
				from	tbEvent_A	with (nolock)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn	and	bActive > 0

			if	@@rowcount > 0
			begin
				select	@s =	@s + '  dup=' + isnull(cast(@idEvDup as varchar),'?') + '! idx=' + isnull(cast(@siPriOld as varchar),'?')
				exec	dbo.pr_Log_Ins	82, null, null, @s

				--	what to do with current call ??
			end
			else
				insert	tbEvent_A	( idEvent,  dtEvent,   cSys,     tiGID,     tiJID,     tiRID,     tiBtn,
										siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,							--,  tiLvl
										tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
						values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
										@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, @tiSvc, dateadd(ss, @iExpNrm, @dtEvent),	--, @tiLvl
										@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins07'

			if	@idRoom > 0		and	@idUnit > 0								-- record every call in tbEvent_C	--	7.06.5562, 7.06.5613
				begin
					select	@idUser =	case
								when @tiSpec = 7	then idUserG
								when @tiSpec = 8	then idUserO
								when @tiSpec = 9	then idUserY
								else					 null	end
						from	tbRoom	with (nolock)
						where	idRoom = @idRoom

					select	@idShift =	u.idShift							--	7.06.6017
						,	@dShift =	case when sh.tEnd <= sh.tBeg	and	cast(@dtOrigin as time) < sh.tEnd	then	dateadd( dd, -1, @dtOrigin )	else	@dtOrigin	end
	--	7.06.6051		,	@dShift =	case when sh.tBeg < sh.tEnd	then	@dtOrigin	else	dateadd( dd, -1, @dtOrigin )	end
						from	tbUnit	u
						join	tbShift	sh	on	sh.idShift = u.idShift
						where	u.idUnit = @idUnit	and	u.bActive > 0

					if	@tiLvl = 0											-- non-clinic call
					begin
						insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, idUser1, tiHH )
								values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, @idUser, datepart(hh, @dtOrigin) )

	--					if	@iTrace & 0x4000 > 0
	--						exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins08'

						if	@bPresence = 0									--	7.06.5665
							update	c	set	c.idUser1=	rb.idUser1,		c.idUser2=	rb.idUser2,		c.idUser3=	rb.idUser3	--	7.06.5326
								from	tbEvent_C	c
								join	tbRoomBed	rb	on	rb.idRoom = @idRoom		and	( rb.tiBed = @tiBed		or	@tiBed is null	and	( rb.tiBed = 0xFF	or	rb.tiBed = 1 ) )
								where	c.idEvent = @idEvent
					end
					else
					if	@tiLvl = 2											-- clinic-patient
						insert	tbEvent_D	(  idEvent,  dEvent,    tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, tiHH )
								values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, datepart(hh, @dtOrigin) )
					else
					if	@tiLvl = 3											-- clinic-staff
						update	tbEvent_D	set	idEvntS =	@idEvent
							where	idEvent = @idParent		and	idEvntS is null
					else
					if	@tiLvl = 4											-- clinic-doctor
						update	tbEvent_D	set	idEvntD =	@idEvent
							where	idEvent = @idParent		and	idEvntD is null
				end

			select	@idOrigin=	@idEvent
		end

		else																-- active origin found	(=> call healed/escalated/cancelled)
		begin
			update	tbEvent		set	idOrigin =	@idOrigin,	tOrigin =	dtEvent - @dtOrigin,	@idParent=	idParent
				where	idEvent = @idEvent

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins09'

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	siIdx=	@siIdxNew,	idCall =	@idCall		--	7.06.5855
				where	idEvent = @idOrigin								--	7.05.5065

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins10'

			update	tbEvent_A	set	tiSvc=	@tiSvc							-- update state for all calls in this room
				where	idRoom = @idRoom								--	7.06.5534

			if	0 < @tiLvl	and	0 < @siIdxNew	and	@siIdxNew <> @siIdxOld	and	@siIdxUg is null	-- escalated to last stage
			begin
				if	@tiLvl = 2												-- clinic-patient
					update	tbEvent_D	set	tWaitS =	@dtEvent - dEvent - tEvent
						where	idEvent = @idOrigin		and	tWaitS is null
				else
		--		if	@tiLvl = 3												-- clinic-staff
		--		else
				if	@tiLvl = 4												-- clinic-doctor
				begin
					update	ed	set	tWaitD =	@dtEvent - e.dtEvent
						from	tbEvent_D	ed
						join	tbEvent		e	with (nolock)	on	e.idEvent = ed.idEvntD
						where	ed.idEvent = @idParent	and	tWaitD is null

					update	tbEvent_D	set	idEvntD =	@idEvent
						where	idEvent = @idParent	--?	and	idEvDoc is [not?] null
				end
			end
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins11'


		if	@siIdxNew = 0													-- call cancelled
		begin
			update	tbEvent_A	set	tiSvc=	null,	bActive =	0
								,	dtExpires=	dateadd(ss, case when @bAudio = 0 then @iExpNrm else @iExpExt end, @dtEvent)
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID
					and	tiRID = @tiSrcRID	and	tiBtn = @tiBtn		and	bActive > 0

--			if	@iTrace & 0x4000 > 0
--				exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins12'

			select	@dtOrigin=	tOrigin		--,	@idParent=	idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	tbEvent_C	set	idEvtSt =	@idEvent,	tStaff =	@dtOrigin
				where	idEvent = @idOrigin		and	idEvtSt is null			-- there should be only one, but just in case - use only 1st one

			if	@tiLvl = 2	and	@siIdxUg is null							-- clinic-patient
				update	tbEvent_D	set	tRoomP =	@dtEvent - dEvent - tEvent
					where	idEvent = @idOrigin		and	tRoomP is null
			else
			if	@tiLvl = 3													-- clinic-staff
				update	ed	set	tRoomS =	@dtOrigin						-- == eo.tOrigin
					from	tbEvent		ee	with (nolock)
					join	tbEvent		eo	with (nolock)	on	eo.idEvent = ee.idOrigin
					join	tbEvent_D	ed					on	ed.idEvent = eo.idParent
					where	ee.idEvent = @idEvent	and	tRoomS is null
			else
			if	@tiLvl = 4													-- clinic-doctor
				update	ed	set	tRoomD =	@dtEvent - ep.dtEvent
					from	tbEvent		eo	with (nolock)
					join	tbEvent_D	ed					on	ed.idEvent = eo.idParent
					join	tbEvent		ep	with (nolock)	on	ep.idEvent = ed.idEvntD
					where	eo.idEvent = @idOrigin	and	tRoomD is null
		end

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins13'


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

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins14'


		---	!! @idEvent no longer points to current event !!

		-- set tbRoom.idEvent and .tiSvc to highest oldest active call for this room
		select	@idEvent =	null,	@tiSvc =	null
		select	top 1	@idEvent =	idEvent,	@tiSvc =	tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or	tiBed = 0xFF	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent								-- oldest in recorded order
		---	order	by	siIdx desc, tElapsed desc							-- call may have started before it was recorded

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins15'

		update	tbRoom	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
			where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins16'

		-- clear room state when there's no 'presence'						--	7.06.5534
		if	@tiSvc is null	or	@tiSvc & 0x30 <> 0x10
			update	tbRoom	set	idUserG =	null,	sStaffG =	null	where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins17'

		if	@tiSvc is null	or	@tiSvc & 0x0C <> 0x04
			update	tbRoom	set	idUserO =	null,	sStaffO =	null	where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins18'

		if	@tiSvc is null	or	@tiSvc & 0x03 <> 0x01
			update	tbRoom	set	idUserY =	null,	sStaffY =	null	where	idRoom = @idRoom

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins19'


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
				order	by	siIdx desc, idEvent								-- oldest in recorded order - FASTER, more EFFICIENT
			---	order	by	siIdx desc, tElapsed desc						-- call may have started before it was recorded (no .tElapsed!)

			update	tbRoomBed	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
				where	idRoom = @idRoom	and	tiBed = @tiBed

			fetch next from	cur	into	@tiBed
		end
		close	cur
		deallocate	cur

--		if	@iTrace & 0x4000 > 0
--			exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins20'

	commit

	select	@idEvent =	@idOrigin			--	7.05.5267	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
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
			order	by	c.siIdx	desc
end
go
--	----------------------------------------------------------------------------
--	7.06.6401	+ .tiFlags
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbReport') and name = 'tiFlags')
begin
	begin tran
		alter table	dbo.tbReport	add
			tiFlags		tinyint			null		-- 1=Regular, 2=Clinic
	commit
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbReport') and name = 'tiFlags' and is_nullable=1)
begin
	begin tran
		update	tbReport	set	tiFlags =	1		-- Regular
		update	tbReport	set	tiFlags =	3		-- Regular | Clinic
			where	idReport = 2

		alter table	dbo.tbReport	alter column
			tiFlags		tinyint			not null
	commit
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
		from	tbReport	with (nolock)
		order	by	siOrder
end
go
--	----------------------------------------------------------------------------
--	7.06.6446	* [22]
--	7.06.6417	+ [22..24]
if	not exists	(select 1 from dbo.tbReport where idReport = 22)
begin
	begin tran
	---	insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
	---				values	( 21,  10,	2,	'xrCliPatSum',		'Patient Wait Times Summary',	'Summarized Patient Wait Times' )	--	7.06.6402
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 22,  20,	2,	'xrCliPatDtl',		'Patient Wait Times',			'Detailed Patient Wait Times' )		--	.6446

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 23,  30,	2,	'xrCliStfSum',		'Staff Activity Summary',		'Summarized Staff Activity' )
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 24,  40,	2,	'xrCliStfDtl',		'Staff Activity (Detailed)',	'Detailed Staff Activity' )
	commit
end
else
begin
	begin tran
		update	dbo.tbReport	set	sReport =	'Patient Wait Times',	sRptName =	'Detailed Patient Wait Times'	where	idReport = 22
	commit
end
go
--	----------------------------------------------------------------------------
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

	set	nocount	on

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered,

/*		idUnit		smallint,
		sUnit		varchar( 16 ),
		idRoom		smallint,
		cBed		char( 1 ),
		cDevice		char( 1 ),
		sDevice		varchar( 16 ),
		sDial		varchar( 16 ),
		idUser1		int,
*/	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	'STAT',		@sNull =	''
	select	@sSvc4 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent	--, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent	--, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ec.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent	--, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent	--, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ec.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ec.idCall
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0

	set	nocount	off

	select	ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice,	ec.cBed, e.tiBed, ec.sDial
		,	e.idEvent, e.dEvent, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin
		,	e.idLogType
		,	case	when e41.idEvent > 0	then pt.sPcsType	else lt.sLogType	end		as	sEvent
		,	c.siIdx, cp.tiSpec	--, e.idCall
		,	case	when e41.idEvent > 0	then du.idStfLvl	else e.tiFlags		end		as	tiSvc
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
		from	#tbRpt1		et	with (nolock)
		join	vwEvent_C	ec	with (nolock)	on	ec.idEvent = et.idEvent
		join	vwEvent		e	with (nolock)	on	e.idParent = et.idEvent
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
		order	by	ec.idUnit, ec.idRoom, ec.idEvent, e.idEvent
end
go
--	----------------------------------------------------------------------------
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

	create table	#tbRpt1
	(
		idEvent		int		primary key nonclustered
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ep.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ep.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ep.idRoom
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ep.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	sc.idCall = ep.idCall
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0

	set	nocount	off

	select	ep.idUnit, ep.sUnit, ep.idRoom, ep.cDevice, ep.sDevice,		ep.cBed, e.tiBed
		,	e.idEvent, e.dEvent, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin	--, e.idCall, ep.sDial
	--	,	e.idLogType, lt.sLogType
		,	c.siIdx, cp.tiSpec, c.sCall
		,	ep.tRoomP,	ep.tWaitS, ep.tRoomS,	ep.tWaitD, ep.tRoomD
		,	cast(cast(ep.tEvent as datetime) + cast(ep.tRoomP as datetime) as time(3))	as	tExit
		from	#tbRpt1		et	with (nolock)
		join	vwEvent_D	ep	with (nolock)	on	ep.idEvent = et.idEvent
		join	vwEvent		e	with (nolock)	on	e.idEvent = ep.idEvent
	--	join	tb_LogType	lt	with (nolock)	on	lt.idLogType = e.idLogType
		join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
--		where	e.idEvent	between @iFrom	and @iUpto
--		and		e.tiHH		between @tFrom	and @tUpto
		order	by	ep.idUnit, ep.idRoom, ep.idEvent
end
go
grant	execute				on dbo.prRptCliPatDtl				to [rWriter]
grant	execute				on dbo.prRptCliPatDtl				to [rReader]
go
--	----------------------------------------------------------------------------
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
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ep.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ep.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ep.idRoom
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ep.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
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
	--	,	e.idLogType, lt.sLogType
		,	c.siIdx, cp.tiSpec, c.sCall
		,	et.tWait, et.tRoom, et.tRoomP
		,	cast(cast(e.tEvent as datetime) + cast(et.tRoom as datetime) as time(3))	as	tExit
		from	#tbRpt2		et	with (nolock)
		join	vwEvent		e	with (nolock)	on	e.idEvent = et.idEvent
	--	join	tb_LogType	lt	with (nolock)	on	lt.idLogType = e.idLogType
		join	tbUnit		u	with (nolock)	on	u.idUnit = e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice = e.idRoom
		join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, e.idEvent
end
go
grant	execute				on dbo.prRptCliStfDtl				to [rWriter]
grant	execute				on dbo.prRptCliStfDtl				to [rReader]
go
--	----------------------------------------------------------------------------
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
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ep.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.dShift	between @dFrom	and @dUpto
					and		ep.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ep.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
					where	ep.idEvent	between @iFrom	and @iUpto
					and		ep.tiHH		between @tFrom	and @tUpto
					and		ep.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	distinct ep.idEvent
					from	vwEvent_D	ep	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ep.idRoom
					join	tb_SessShift sh	with (nolock)	on	sh.idSess = @idSess		and	sh.idShift = ep.idShift
					join	tb_SessCall	sc	with (nolock)	on	sc.idSess = @idSess		and	( sc.idCall = ep.idCallS	or	sc.idCall = ep.idCallD )
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

/*	select	e.idUnit, min(u.sUnit), e.idRoom, min(r.cDevice), min(r.sDevice)	--,	e.cBed, e.tiBed
		,	e.dEvent, count(e.idEvent)	--, e.tEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin	--, e.idCall, ep.sDial
	--	,	e.idLogType, lt.sLogType
		,	c.siIdx, min(c.sCall)	--, cp.tiSpec
		,	avg(et.tRoom), sum(et.tRoom), sum(et.tWait), sum(et.tRoomP)
	--	,	cast(cast(e.tEvent as datetime) + cast(et.tRoom as datetime) as time(3))	as	tExit
		from	#tbRpt2		et	with (nolock)
		join	vwEvent		e	with (nolock)	on	e.idEvent = et.idEvent
	--	join	tb_LogType	lt	with (nolock)	on	lt.idLogType = e.idLogType
		join	tbUnit		u	with (nolock)	on	u.idUnit = e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice = e.idRoom
		join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = c.siIdx
		group	by	e.idUnit, e.idRoom, e.dEvent, c.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, c.siIdx	desc	--, e.idEvent
*/
	select	e.idUnit, u.sUnit, e.idRoom, r.cDevice, r.sDevice
		,	e.dEvent, e.lCount
		,	e.siIdx, e.sCall
		,	cast(e.tRoomA as time(3))	as	tRoomA,	cast(e.tRoomT as time(3))	as	tRoomT,	cast(e.tWait as time(3))	as	tWait,	cast(e.tRoomP as time(3))	as	tRoomP
		from
		(select	e.idUnit, e.idRoom
			,	e.dEvent, count(e.idEvent)	as	lCount
			,	c.siIdx, min(c.sCall)	as	sCall
			,	dateadd(ms,avg(datediff(ms,0,et.tRoom)),0)	as	tRoomA
			,	dateadd(ms,sum(datediff(ms,0,et.tRoom)),0)	as	tRoomT
			,	dateadd(ms,sum(datediff(ms,0,et.tWait)),0)	as	tWait
			,	dateadd(ms,sum(datediff(ms,0,et.tRoomP)),0)	as	tRoomP
			from	#tbRpt2		et	with (nolock)
			join	vwEvent		e	with (nolock)	on	e.idEvent = et.idEvent
			join	vwCall		c	with (nolock)	on	c.idCall = e.idCall
		group	by	e.idUnit, e.idRoom, e.dEvent, c.siIdx
			)	e	--with (nolock)
		join	tbUnit		u	with (nolock)	on	u.idUnit = e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice = e.idRoom
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = e.siIdx
		order	by	e.idUnit, e.idRoom, e.dEvent, e.siIdx	desc
end
go
grant	execute				on dbo.prRptCliStfSum				to [rWriter]
grant	execute				on dbo.prRptCliStfSum				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.6452	+ [8]
if	not exists	(select 1 from dbo.tbDvcType where idDvcType = 8)
begin
	begin tran
		insert	dbo.tbDvcType ( idDvcType, sDvcType )	values	(  8, 'Wi-Fi' )		--	7.06.6452

		update	dbo.tb_OptSys	set	iValue= iValue & 0x07	where	idOption = 20;
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6459	+ [226,227]
if	not exists	(select 1 from dbo.tb_LogType where idLogType = 226)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 226, 8, 4, 'Log-in failed (dvc)' )	--	7.06.6459
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 227, 8, 4, 'Log-in failed (ind)' )	--	7.06.6459
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a device
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

	if	@idDvcType <> 0x08		--	Wi-Fi
	begin
		exec	dbo.prUnit_SetTmpFlt	@sUnits
		exec	dbo.prTeam_SetTmpFlt	@sTeams
	end

	select	@s= '[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', n="' + @sDvc +
				'", b=' + isnull(cast(@sBarCode as varchar), '?') + ', d="' + isnull(cast(@sDial as varchar), '?') +
				'", f=' + cast(@tiFlags as varchar) + ', a=' + cast(@bActive as varchar)
	exec	dbo.pr_Log_Ins	1, @idUser, null, @s
	begin	tran

		if	exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			select	@s= 'Dvc_U( ' + @s + ' )'
				,	@k=	248

			update	tbDvc	set	idDvcType=	@idDvcType,	sDvc =		@sDvc,		sBarCode =	@sBarCode,	sDial=		@sDial
							,	tiFlags =	@tiFlags,	idUser =	case when @bActive > 0 then idUser else null end
							,	sUnits =	@sUnits,	sTeams =	@sTeams,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc
		end
		else
		begin
			select	@s= 'Dvc_I( ' + @s + ' ) = '

			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  sUnits,  sTeams,  bActive )
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @sTeams, @bActive )
			select	@idDvc =	scope_identity( )

			if	@idDvcType = 0x08		--	Wi-Fi
				update	tbDvc	set	sBarCode =	cast(@idDvc as varchar)		where	idDvc = @idDvc

			select	@s= @s + cast(@idDvc as varchar)
				,	@k=	247
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
--	Registers Wi-Fi devices
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
,	@sStaffID	varchar( 16 )	out	-- staff-ID
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
--		,		@sDvc		varchar( 16 )
		,		@bActive	bit
		,		@idLogType	tinyint

	set	nocount	on

	select	@s =	'@ ' + isnull( @sIpAddr, '?' )	-- + ''

--	select	@sDvc=	sDvc,	@bActive =	bActive
	select	@bActive =	bActive
		from	tbDvc		with (nolock)
		where	idDvc = @idDvc
		and		idDvcType = 0x08		--	wi-fi

--	if	@sDvc is null			--	wrong dvc
	if	@bActive is null		--	wrong dvc
	begin
		select	@idLogType =	226,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	if	@bActive = 0			--	inactive dvc
	begin
--		select	@idLogType =	227,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''', ''' + isnull( @sDvc, '?' ) + ''''
		select	@idLogType =	227,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''', [' + isnull( @idDvc, '?' ) + ']'
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule
		return	@idLogType
	end

	select	@idUser =	idUser
		from	tb_User		with (nolock)
		where	(sUser = lower( @sUser )	or	sStaffID = @sUser)

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ' ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule
		return	@idLogType
	end

	exec				dbo.pr_Sess_Ins		@sSessID, @idModule, null, @sIpAddr, @sDvc, 0, @sBrowser, @idSess out
	exec	@idLogType=	dbo.pr_User_Login	@idSess, @sUser, @iHash, @idUser out, @sStaff out, @bAdmin out, @sStaffID out

	if	@idLogType = 221		--	success
--	begin
--		begin	tran

			update	tbDvc	set	idUser =	@idUser,	sDvc =	@sDvc,	sUnits =	@sBrowser
				where	idDvc = @idDvc

--		commit
--	end

	return	@idLogType
end
go
grant	execute				on dbo.prDvc_RegWiFi				to [rWriter]
grant	execute				on dbo.prDvc_RegWiFi				to [rReader]
go
--	----------------------------------------------------------------------------
--	UnRegisters Wi-Fi devices
--	7.06.6564	+ @idSess, @idModule
--	7.06.6459
create proc		dbo.prDvc_UnRegWiFi
(
	@idSess		int					-- 0 = application-end (delete all sessions)
,	@idDvc		int		=	null	-- null=any
,	@idModule	tinyint	=	null	-- indicates app, required if @idSess=0
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		if	@idSess > 0		-- sess-end
		begin
			update	tbDvc	set	idUser =	null
				where	idDvcType = 0x08		--	wi-fi
				and		idDvc = @idDvc

			exec	dbo.pr_Sess_Del		@idSess
		end
		else				-- app-end
		begin
			update	tbDvc	set	idUser =	null
				where	idDvcType = 0x08		--	wi-fi
		--	-	and		(@idDvc is null		or	idDvc = @idDvc)

			exec	dbo.pr_Sess_Del		@idSess, 0, @idModule
		end

	commit
end
go
grant	execute				on dbo.prDvc_UnRegWiFi				to [rWriter]
grant	execute				on dbo.prDvc_UnRegWiFi				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.6498	+ .tLast, tiQty
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Log') and name = 'tLast')
begin
	begin tran
		alter table	dbo.tb_Log	add
			tLast		time( 3 )					-- time of last occurence
		,	tiQty		tinyint						-- count of same entry, repeated within the hour
	commit
end
go
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Log') and name = 'tLast' and is_nullable=1)
begin
	begin tran
		update	tb_Log	set	tLast=	tLog,	tiQty=	1

		alter table	dbo.tb_Log	alter column
			tLast		time( 3 )		not null	-- time of last occurence
		alter table	dbo.tb_Log	alter column
			tiQty		tinyint			not null	-- count of same entry, repeated within the hour
	commit
end
go
--	----------------------------------------------------------------------------
--	Audit log
--	7.06.6498	+ .tLast, tiQty
--	7.06.6298	+ .idModule
--	7.06.5399	* optimized
--	6.07
alter view		dbo.vw_Log
	with encryption
as
	select	l.idLog, l.dtLog, l.dLog, l.tLog, l.idLogType, t.sLogType, l.idModule, m.sModule, l.sLog, l.tLast, l.tiQty, l.idUser, u.sUser
		from	tb_Log		l	with (nolock)
		join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
		left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
		left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
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
--	Initialize tb_Log_S based on existing data
	begin tran
		insert	tb_Log_S	( dLog, tiHH, idLog, siCrt, siErr )
			select	dLog, tiHH
				,	min(idLog)
				,	sum(case when tiLvl & 0x20 > 0 then 1 else 0 end)
				,	sum(case when tiLvl & 0x10 > 0 then 1 else 0 end)
				from	tb_Log	l
				join	tb_LogType	lt	on	lt.idLogType = l.idLogType
				group	by	dLog, tiHH
				order	by	dLog, tiHH
	commit
go
--	----------------------------------------------------------------------------
--	Log statistics by hour
--	7.06.6498
create view		dbo.vw_Log_S
	with encryption
as
select	dLog
	,	min(case when tiHH = 00 then idLog else null end)		[idLog00]
	,	min(case when tiHH = 01 then idLog else null end)		[idLog01]
	,	min(case when tiHH = 02 then idLog else null end)		[idLog02]
	,	min(case when tiHH = 03 then idLog else null end)		[idLog03]
	,	min(case when tiHH = 04 then idLog else null end)		[idLog04]
	,	min(case when tiHH = 05 then idLog else null end)		[idLog05]
	,	min(case when tiHH = 06 then idLog else null end)		[idLog06]
	,	min(case when tiHH = 07 then idLog else null end)		[idLog07]
	,	min(case when tiHH = 08 then idLog else null end)		[idLog08]
	,	min(case when tiHH = 09 then idLog else null end)		[idLog09]
	,	min(case when tiHH = 10 then idLog else null end)		[idLog10]
	,	min(case when tiHH = 11 then idLog else null end)		[idLog11]
	,	min(case when tiHH = 12 then idLog else null end)		[idLog12]
	,	min(case when tiHH = 13 then idLog else null end)		[idLog13]
	,	min(case when tiHH = 14 then idLog else null end)		[idLog14]
	,	min(case when tiHH = 15 then idLog else null end)		[idLog15]
	,	min(case when tiHH = 16 then idLog else null end)		[idLog16]
	,	min(case when tiHH = 17 then idLog else null end)		[idLog17]
	,	min(case when tiHH = 18 then idLog else null end)		[idLog18]
	,	min(case when tiHH = 19 then idLog else null end)		[idLog19]
	,	min(case when tiHH = 20 then idLog else null end)		[idLog20]
	,	min(case when tiHH = 21 then idLog else null end)		[idLog21]
	,	min(case when tiHH = 22 then idLog else null end)		[idLog22]
	,	min(case when tiHH = 23 then idLog else null end)		[idLog23]

	,	max(case when tiHH = 00 then siCrt else 0 end)		[siCrt00]
	,	max(case when tiHH = 01 then siCrt else 0 end)		[siCrt01]
	,	max(case when tiHH = 02 then siCrt else 0 end)		[siCrt02]
	,	max(case when tiHH = 03 then siCrt else 0 end)		[siCrt03]
	,	max(case when tiHH = 04 then siCrt else 0 end)		[siCrt04]
	,	max(case when tiHH = 05 then siCrt else 0 end)		[siCrt05]
	,	max(case when tiHH = 06 then siCrt else 0 end)		[siCrt06]
	,	max(case when tiHH = 07 then siCrt else 0 end)		[siCrt07]
	,	max(case when tiHH = 08 then siCrt else 0 end)		[siCrt08]
	,	max(case when tiHH = 09 then siCrt else 0 end)		[siCrt09]
	,	max(case when tiHH = 10 then siCrt else 0 end)		[siCrt10]
	,	max(case when tiHH = 11 then siCrt else 0 end)		[siCrt11]
	,	max(case when tiHH = 12 then siCrt else 0 end)		[siCrt12]
	,	max(case when tiHH = 13 then siCrt else 0 end)		[siCrt13]
	,	max(case when tiHH = 14 then siCrt else 0 end)		[siCrt14]
	,	max(case when tiHH = 15 then siCrt else 0 end)		[siCrt15]
	,	max(case when tiHH = 16 then siCrt else 0 end)		[siCrt16]
	,	max(case when tiHH = 17 then siCrt else 0 end)		[siCrt17]
	,	max(case when tiHH = 18 then siCrt else 0 end)		[siCrt18]
	,	max(case when tiHH = 19 then siCrt else 0 end)		[siCrt19]
	,	max(case when tiHH = 20 then siCrt else 0 end)		[siCrt20]
	,	max(case when tiHH = 21 then siCrt else 0 end)		[siCrt21]
	,	max(case when tiHH = 22 then siCrt else 0 end)		[siCrt22]
	,	max(case when tiHH = 23 then siCrt else 0 end)		[siCrt23]

	,	max(case when tiHH = 00 then siErr else 0 end)		[siErr00]
	,	max(case when tiHH = 01 then siErr else 0 end)		[siErr01]
	,	max(case when tiHH = 02 then siErr else 0 end)		[siErr02]
	,	max(case when tiHH = 03 then siErr else 0 end)		[siErr03]
	,	max(case when tiHH = 04 then siErr else 0 end)		[siErr04]
	,	max(case when tiHH = 05 then siErr else 0 end)		[siErr05]
	,	max(case when tiHH = 06 then siErr else 0 end)		[siErr06]
	,	max(case when tiHH = 07 then siErr else 0 end)		[siErr07]
	,	max(case when tiHH = 08 then siErr else 0 end)		[siErr08]
	,	max(case when tiHH = 09 then siErr else 0 end)		[siErr09]
	,	max(case when tiHH = 10 then siErr else 0 end)		[siErr10]
	,	max(case when tiHH = 11 then siErr else 0 end)		[siErr11]
	,	max(case when tiHH = 12 then siErr else 0 end)		[siErr12]
	,	max(case when tiHH = 13 then siErr else 0 end)		[siErr13]
	,	max(case when tiHH = 14 then siErr else 0 end)		[siErr14]
	,	max(case when tiHH = 15 then siErr else 0 end)		[siErr15]
	,	max(case when tiHH = 16 then siErr else 0 end)		[siErr16]
	,	max(case when tiHH = 17 then siErr else 0 end)		[siErr17]
	,	max(case when tiHH = 18 then siErr else 0 end)		[siErr18]
	,	max(case when tiHH = 19 then siErr else 0 end)		[siErr19]
	,	max(case when tiHH = 20 then siErr else 0 end)		[siErr20]
	,	max(case when tiHH = 21 then siErr else 0 end)		[siErr21]
	,	max(case when tiHH = 22 then siErr else 0 end)		[siErr22]
	,	max(case when tiHH = 23 then siErr else 0 end)		[siErr23]
	from	tb_Log_S	with (nolock)
	group	by	dLog
go
grant	select							on dbo.vw_Log_S			to [rWriter]
grant	select							on dbo.vw_Log_S			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
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
			,	@tiSrc		tinyint
			,	@idLog		int
			,	@idOrg		int

	set	nocount	on

	select	@tiLvl =	tiLvl,	@tiSrc =	tiSrc,		@dt =	getdate( ),		@hh =	datepart( hh, getdate( ) )
		from	tb_LogType	with (nolock)
		where	idLogType = @idLogType

--	set	nocount	off

	if	@tiLvl & 0x30 > 0													-- err (16) + crit (32)
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

		if	@tiLvl & 0x30 > 0	and
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

		if	@tiLvl & 0x20 > 0												-- increment criticals
			update	tb_Log_S	set	siCrt=	siCrt + 1
				where	dLog = cast(@dt as date)	and	tiHH = @hh

		if	@tiLvl & 0x10 > 0												-- increment errors
			update	tb_Log_S	set	siErr=	siErr + 1
				where	dLog = cast(@dt as date)	and	tiHH = @hh

	commit
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	rm.idUnit,	ea.idRoom, r.sDevice	as	sRoom,	ea.tiBed, cb.cBed
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
	select	idEvent, dtEvent, cSys, tiGID, tiJID, tiRID, tiBtn, idRoom, sRoom, tiBed, cBed, idUnit
		,	siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, bActive, bAnswered, tElapsed	--, tiSvc
		,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
		and		(idEvent = @idEvent	or	@idEvent is null)
end
go
grant	view database state										to [rWriter]
grant	view database state										to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns # of rows, data and index sizes for all tables in the DB
--	7.06.6502	+ @bActive
--	7.06.6499
create proc		dbo.prHealth_Table
(
	@bActive	bit		=	0		-- 0=by name, 1=by avg-frag desc
)
	with encryption
as
begin
	set	nocount	on

	create table	#tb
	(
		sTable		sysname
,		lRows		bigint
,		sRsrvd		varchar( 50 )
,		sData		varchar( 50 )
,		sIndex		varchar( 50 )
,		sUnused		varchar( 50 )
	)

	insert	#tb
		exec	sp_msforeachtable	'sp_spaceused ''?'''

	set nocount off

	if	@bActive = 0
		select	sTable, lRows
			,	cast(replace(sRsrvd, ' kb', '') as bigint)	as	lRsrvd
		--	,	cast(replace(sData, ' kb', '') as bigint) +
		--		cast(replace(sIndex, ' kb', '') as bigint) +
		--		cast(replace(sUnused, ' kb', '') as bigint)	as	lTotal
			,	cast(replace(sData, ' kb', '') as bigint)	as	lData
			,	cast(replace(sIndex, ' kb', '') as bigint)	as	lIndex
			,	cast(replace(sUnused, ' kb', '') as bigint)	as	lUnused
		--	,	sData,	sIndex,	sUnused
			from	#tb
			order	by	1	-- desc
	else
		select	sTable, lRows
			,	cast(replace(sRsrvd, ' kb', '') as bigint)	as	lRsrvd
			,	cast(replace(sData, ' kb', '') as bigint)	as	lData
			,	cast(replace(sIndex, ' kb', '') as bigint)	as	lIndex
			,	cast(replace(sUnused, ' kb', '') as bigint)	as	lUnused
			from	#tb
			order	by	lRsrvd	desc

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
--	7.06.6508	* xpReportRole -> xp_RoleRpt
if	exists	(select 1 from dbo.sysindexes where id = OBJECT_ID('dbo.tb_RoleRpt') and name='xpReportRole')
begin
	begin tran
		exec sp_rename 'tb_RoleRpt.xpReportRole',	'xp_RoleRpt',	'index'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6508	* xuCall_Active_siIdx -> xuCall_siIdx_Act
if	exists	(select 1 from dbo.sysindexes where id = OBJECT_ID('dbo.tbCall') and name='xuCall_Active_siIdx')
begin
	begin tran
		exec sp_rename 'tbCall.xuCall_Active_siIdx',	'xuCall_siIdx_Act',	'index'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6508	* xuEventA_Active_SGJRB -> xuEventA_SGJRB_Act
if	exists	(select 1 from dbo.sysindexes where id = OBJECT_ID('dbo.tbEvent_A') and name='xuEventA_Active_SGJRB')
begin
	begin tran
		exec sp_rename 'tbEvent_A.xuEventA_Active_SGJRB',	'xuEventA_SGJRB_Act',	'index'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6508	* xuShift_Active_UnitIdx -> xuShift_UnitIdx_Act
if	exists	(select 1 from dbo.sysindexes where id = OBJECT_ID('dbo.tbShift') and name='xuShift_Active_UnitIdx')
begin
	begin tran
		exec sp_rename 'tbShift.xuShift_Active_UnitIdx',	'xuShift_UnitIdx_Act',	'index'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6508	* xuStfAssn_Active_RoomBedShiftIdx -> xuStfAssn_RmBdShIdx_Act
if	exists	(select 1 from dbo.sysindexes where id = OBJECT_ID('dbo.tbStfAssn') and name='xuStfAssn_Active_RoomBedShiftIdx')
begin
	begin tran
		exec sp_rename 'tbStfAssn.xuStfAssn_Active_RoomBedShiftIdx',	'xuStfAssn_RmBdShIdx_Act',	'index'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns installation history
--	7.06.6953	* removed 'db7983.' from object refs
--	7.06.6509
create proc		dbo.pr_Version_GetAll
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
grant	execute				on dbo.pr_Version_GetAll			to [rWriter]
grant	execute				on dbo.pr_Version_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Audit log module filters (active during a user session)
--	7.06.6526	* tb_SessLog -> tb_SessMod
--	7.06.6303
create table	dbo.tb_SessMod
(
	idSess		int				not null
		constraint	fk_SessMod_Sess		foreign key references tb_Sess
,	idModule	tinyint			not null
		constraint	fk_SessMod_Module	foreign key references tb_Module
	
,	constraint	xp_SessMod	primary key clustered ( idSess, idModule )
)
go
grant	select, insert, update, delete	on dbo.tb_SessMod		to [rWriter]
grant	select, insert, update, delete	on dbo.tb_SessMod		to [rReader]
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

	if	not	exists	(select 1 from tb_SessMod with (nolock) where idSess=@idSess and idModule=@idModule)
	begin
--		begin	tran
			insert	tb_SessMod	(  idSess,  idModule )
					values		( @idSess, @idModule )
--		commit
	end
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

		delete from	tb_SessMod		where	idSess = @idSess

--	commit
end
go
grant	execute				on dbo.pr_SessMod_Clr				to [rWriter]
grant	execute				on dbo.pr_SessMod_Clr				to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans-up session's filter tables
--	7.06.6526	* tb_SessLog -> tb_SessMod
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

		delete from	tb_SessUser		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessShift	where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessCall		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessMod		where	idSess = @idSess	or	@idSess is null
--	-	delete from	tb_SessLoc		where	idSess = @idSess	or	@idSess is null
		delete from	tb_SessDvc		where	idSess = @idSess	or	@idSess is null

	commit
end
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering condition into tb_Log.idLog range
--	7.06.6534	* modified for null args
--	7.06.6512
create proc		dbo.pr_Log_XltDtEvRng
(
	@dFrom		datetime			-- date from
,	@dUpto		datetime			-- date upto
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
		select	@iFrom =	0
	else
		select	@iFrom =	min(idLog)
			from	tb_Log_S	with (nolock)
			where	@dFrom <= dLog	and	@tFrom <= tiHH

	if	@dUpto is null
		select	@iUpto =	0x7FFFFFFF		--	max int (2147483647)
	else
		select	@iUpto =	min(idLog)
			from	tb_Log_S	with (nolock)
			where	@dUpto = dLog		and	@tUpto < tiHH
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
--	7.06.6534	* modified for null args
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
,	@tiSrc		tinyint				-- bitwise tb_LogType.tiSrc, 0xFF=include all
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

	if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no level or category filtering
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
				and		t.tiSrc & @tiSrc > 0

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log l	with (nolock)
				join	tb_LogType t	with (nolock)	on	t.idLogType = l.idLogType
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				and		t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0
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
				and		t.tiSrc & @tiSrc > 0

			set	rowcount	@iIndex
			select	@idLog =	idLog
				from	tb_Log		l	with (nolock)
				join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
				join	tb_LogType	t	with (nolock)	on	t.idLogType = l.idLogType
				where	idLog	between	@iFrom	and @iUpto
				and		tiHH	between @tFrom	and @tUpto
				and		t.tiLvl & @tiLvl > 0
				and		t.tiSrc & @tiSrc > 0
				order	by	idLog desc
		end

	set	rowcount	@iCount
	set	nocount	off

	if	@bGroup = 0
		if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
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
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
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
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiSrc & @tiSrc > 0
					order	by 1 desc
			else										-- filter by source
				select	l.idLog, l.dtLog, l.idLogType, t.sLogType, t.tiLvl, t.tiSrc, l.idModule, m.sModule, l.sLog, l.idUser, u.sUser, l.tiQty, l.tLast, l.tLog
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @idLog	-- @iUpto
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiSrc & @tiSrc > 0
					order	by 1 desc

	set	rowcount	0

	if	@bGroup > 0
		if	@tiLvl = 0xFF  and  @tiSrc = 0xFF			-- no level or category filtering
			if	@idSess = 0
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiSrc) as tiSrc, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
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
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiSrc) as tiSrc, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
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
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiSrc) as tiSrc, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
			--	-	join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiSrc & @tiSrc > 0
					group	by	l.idLogType
					order	by	lQty	desc
			else										-- filter by source
				select	l.idLogType, min(t.tiLvl) as tiLvl, min(tiSrc) as tiSrc, min(t.sLogType) as sLogType, min(dtLog) as dtFrom, max(dtLog) as dtUpto, sum(tiQty) as lQty, count(*) as lCount
					from	tb_Log		l	with (nolock)
					join	tb_SessMod	sm	with (nolock)	on sm.idModule = l.idModule		and	sm.idSess = @idSess
					join	tb_LogType	t	with (nolock)	on t.idLogType = l.idLogType
					left join	tb_Module	m	with (nolock)	on m.idModule = l.idModule
					left join	tb_User		u	with (nolock)	on u.idUser = l.idUser
					where	idLog	between	@iFrom	and @iUpto	-- @idLog
					and		tiHH	between @tFrom	and @tUpto
		--			where	idLog <= @idLog
					and		t.tiLvl & @tiLvl > 0
					and		t.tiSrc & @tiSrc > 0
					group	by	l.idLogType
					order	by	lQty	desc
end
go
--	----------------------------------------------------------------------------
--	clean up
update	dbo.vw_OptSys	set	sValue= null	where	tiDatatype <> 167	and	sValue = ''
go
--	----------------------------------------------------------------------------
--	Returns details for all log-types
--	7.06.6555
create proc		dbo.pr_LogType_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLogType, tiLvl, tiSrc, sLogType
		from	tb_LogType		with (nolock)
end
go
grant	execute				on dbo.pr_LogType_GetAll			to [rWriter]
grant	execute				on dbo.pr_LogType_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns given module's state
--	7.06.6555
create proc		dbo.pr_Module_Get
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin
--	set	nocount	on
	select	idModule, sModule, sDesc, bLicense, tiModType, tiLvl, sIpAddr, sMachine, sVersion, dtStart, sParams, dtLastAct
		,	case when sMachine is null then sIpAddr else sMachine end	as	sHost
		,	datediff( ss, dtLastAct, getdate( ) )						as	siElapsed
		,	cast( getdate( ) - dtStart as datetime )					as	dtRunTime
		from	tb_Module	with (nolock)
		where	idModule = @idModule
end
go
grant	execute				on dbo.pr_Module_Get				to [rWriter]
grant	execute				on dbo.pr_Module_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns receivers (filtered)
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
	select	idReceiver, sReceiver,	idRoom, sFqDevice
		,	bActive, dtCreated, dtUpdated
		from	vwRtlsRcvr	with (nolock)
		where	( @bActive is null	or	bActive = @bActive )
		and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Returns badges (filtered)
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
)
	with encryption
as
begin
--	set	nocount	on
		select	idBadge,	idUser, sFqStaff
			,	idRoom,		sSGJ + ' [' + cDevice + '] ' + sDevice		as	sCurrLoc
			,	dtEntered,	cast( getdate( )-dtEntered as time( 0 ) )	as	tDuration
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge		with (nolock)
			where	( @bActive is null	or	bActive = @bActive )
			and		( @bStaff is null	or	@bStaff = 0	and	idUser is null	or	@bStaff = 1	and	idUser is not null )
			and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
			order	by	idBadge
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 6646 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	6646, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2018-03-13',	dtInstall=	getdate( )
		,	sVersion =	'+798?rh (CallList,ActLog), *7980ns, +tbCfgDome, *7985cw, *7981ls, *7980cw, *7983r'
		where	siBuild = 6646

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.6646'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.6646 )'
commit
go

checkpoint
go

use [master]
go