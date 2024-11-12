--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
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
--		2020-Feb-04		.7339
--						* build # bump for HASP-wrapping
--		2020-Feb-20		.7355
--						* prRoom_UpdStaff, prRtlsBadge_UpdLoc
--		2020-Mar-03		.7367
--						* pr_User_sStaff_Upd
--
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7367 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7367', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptRndStatDtl')
	drop proc	dbo.prRptRndStatDtl
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptRndStatSum')
	drop proc	dbo.prRptRndStatSum
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prPatient_Upd')
	drop proc	dbo.prPatient_Upd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_GetOne')
	drop proc	dbo.pr_User_GetOne
go
--	----------------------------------------------------------------------------
--	7.06.7250	remove unnecessary entries
--	<64,tb_Log>
begin
	begin tran
		delete	from	dbo.tb_Log	where	idLogType in (103,238)	and	sLog like 'User_AD( % )'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns 790 devices, filtered according to args
--	7.06.7207	* switch to .cDevice from .tiStype (adding 700)
--	7.06.5855	* AID update, IP-address for GWs -> .sDial
--	7.06.5613	* 680 station types recognition
--	7.06.5414
alter proc		dbo.prCfgDvc_GetAll
(
--	@idUser		int			= null	-- null=any
	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@tiKind		tinyint		= 0xFF	-- 01=G, 02=R, 04=M|W, 08=Z, 10=*, 20=?
)
	with encryption
as
begin
--	set	nocount	on
	select	idDevice, idParent, tiJID, tiRID, sSGJR, iAID, tiStype, cDevice
		,	case when	sBeds is null	then sDevice	else	sDevice + ' : ' + sBeds	end		as	sDevice
		,	case when	tiStype	< 4		then sDial
				when	len(sUnits) > 31	then substring(sUnits,1,24) + '..(' + cast((len(sUnits)+1)/4 as varchar) + ' units)'
				else	sUnits	end		as	sUnits
		,	sDial, sCodeVer, idUnit, bActive, dtCreated, dtUpdated
		from	vwDevice	with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
--		and		(@tiKind & 0x01 <> 0	and	(tiStype < 4				or	tiStype = 116)											--	Gway | 7092-Gway
--			or	@tiKind & 0x02 <> 0		and	(tiStype between 4 and 7	or	tiStype = 124	or	tiStype = 126	or					--	Room | 680-BusSt | 680-Main
--											tiStype between 109 and 111	or	tiStype = 114	or	tiStype = 115	or	tiStype between 117 and 119)	--	700-Room
--			or	@tiKind & 0x04 <> 0		and	(tiStype between 8 and 11	or	tiStype = 24	or	tiStype = 26	or	tiStype = 125	or
--											tiStype = 16)																			--	Mstr | Wkfl | 680-Mstr | 7065-Mstr
--			or	@tiKind & 0x08 <> 0		and	(tiStype between 13 and 15	or	tiStype = 113)											--	Zone | 7071-Zone
--			or	@tiKind & 0x10 <> 0)									--	Other
		and	(	@tiKind & 0x01 <> 0		and	cDevice = 'G'				--	Gway
			or	@tiKind & 0x02 <> 0		and	cDevice = 'R'				--	Room
			or	@tiKind & 0x04 <> 0		and	cDevice in ('M','W')		--	Mstr | Wkfl
			or	@tiKind & 0x08 <> 0		and	cDevice = 'Z'				--	Zone
			or	@tiKind & 0x10 <> 0		and	cDevice not in ('G','M','R','W','Z'))	--	Other
--		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
--					from	tb_RoleUnit	ru	with (nolock)
--					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	sSGJR
end
go
--	----------------------------------------------------------------------------
--	Returns details for specified user
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
		,	dtLastAct, sStaffID, idStfLvl, sBarCode, bOnDuty, dtDue, sStaff	--, sUnits, sTeams
		,	gGUID, utSynched
		,	bActive, dtCreated, dtUpdated
		,	cast(case when	tiFails=0xFF	then 1	else 0	end	as	bit)	as	bLocked
		,	cast(case when	gGUID is null	then 0	else 1	end	as	bit)	as	bGUID
		from	tb_User		with (nolock)
		where	(@gGUID is null		or	gGUID = @gGUID)
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
end
go
grant	execute				on dbo.pr_User_GetOne				to [rWriter]
grant	execute				on dbo.pr_User_GetOne				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.7222	* fix: disable 'EMPTY' patient
begin
	declare		@sInfo		varchar( 255 )
		,		@cGender	char( 1 )
		,		@idPatient	int
		,		@idDoctor	int
		,		@sPatient	varchar( 16 )

	begin tran
		
		select	@idPatient =	idPatient
			from	tbPatient	with (nolock)
			where	sPatient = 'EMPTY'

		if	0 < @idPatient													-- found
		begin
			update	tbPatient	set	bActive =	0,		dtUpdated=	getdate( )
				where	idPatient = @idPatient

			update	tbRoomBed	set	idPatient=	null,	dtUpdated=	getdate( )
				where	idPatient = @idPatient
		end

		update	tbPatient	set	cGender =	'U'
			where	ascii(cGender) = 0xFF
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
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
			,	@tiCat		tinyint
			,	@idLog		int
			,	@idOrg		int

	set	nocount	on

	select	@tiLvl =	tiLvl,	@tiCat =	tiCat,		@dt =	getdate( ),		@hh =	datepart( hh, getdate( ) )
		from	tb_LogType	with (nolock)
		where	idLogType = @idLogType

--	set	nocount	off

	if	0 < @tiLvl & 0xC0													-- err (64) + crit (128)
	begin
		select	@idOrg =	idLog											-- get 1st event of the hour
			from	tb_Log_S	with (nolock)
			where	dLog = cast(@dt as date)	and	tiHH = @hh

		if	0 < @idOrg
			select	@idLog =	idLog										-- find 1st occurence of "sLog"
				from	tb_Log		with (nolock)
				where	idLog >= @idOrg
				and		sLog = @sLog
	end

	begin	tran

		if	0 < @tiLvl & 0xC0	and		0 < @idLog							-- same crit/err already happened
			update	tb_Log	set	tLast=	@dt
							,	tiQty=	case when tiQty < 255 then tiQty + 1 else tiQty end
				where	idLog = @idLog
		else
		begin
				insert	tb_Log	(  idLogType,  idModule,  idUser,  sLog,	dtLog,	dLog,	tLog,	tiHH,	tLast,	tiQty )
						values	( @idLogType, @idModule, @idUser, @sLog,	@dt,	@dt,	@dt,	@hh,	@dt,	1 )
				select	@idLog =	scope_identity( )

				set transaction isolation level serializable
				begin	tran
					if	not	exists(	select	1	from	tb_Log_S	with (updlock)	where	dLog = cast(@dt as date)	and	tiHH = @hh	)
						insert	tb_Log_S	( dLog,	tiHH, idLog )
								values		( @dt,	@hh, @idLog )
				commit

/*				select	@idOrg =	null									-- update event statistics
				select	@idOrg =	idLog
					from	tb_Log_S	with (nolock)
					where	dLog = cast(@dt as date)	and	tiHH = @hh

				if	@idOrg	is null
					insert	tb_Log_S	( dLog,	tiHH, idLog )
							values		( @dt,	@hh, @idLog )
*/		end

		if	0 < @tiLvl & 0x80												-- increment criticals
			update	tb_Log_S	set	siCrt=	siCrt + 1
				where	dLog = cast(@dt as date)	and	tiHH = @hh

		if	0 < @tiLvl & 0x40												-- increment errors
			update	tb_Log_S	set	siErr=	siErr + 1
				where	dLog = cast(@dt as date)	and	tiHH = @hh

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7242	* fix: remove all registered staff prior to creating unique indexes
begin
	begin tran
		update	tbRoom	set	dtUpdated=	getdate( )
						,	idUserG =	null,	sStaffG =	null
						,	idUserO =	null,	sStaffO =	null
						,	idUserY =	null,	sStaffY =	null
						,	dtExpires=	null
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7251	* [101-103]		+ [104]
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 104)
begin
	begin tran
		update	dbo.tb_LogType set	sLogType =	'AD: skipped'	where	idLogType = 101
		update	dbo.tb_LogType set	sLogType =	'AD: inserted'	where	idLogType = 102
		update	dbo.tb_LogType set	sLogType =	'AD: updated'	where	idLogType = 103

		insert	dbo.tb_LogType ( idLogType, tiLvl, tiCat, sLogType )	values	( 104,	8,	8,	'AD: no change' )			--	7.06.7251
	commit
end
go
--	----------------------------------------------------------------------------
--	Receivers
--	7.06.7262	- .cSys, .tiGID, .tiJID, .tiRID, .sSGJR
--	7.06.7261	+ .cSys, .tiGID, .tiJID, .tiRID
--	7.04.4958	- tbRtlsRcvr.idRcvrType, .sPhone
--	7.04.4892	* .idDevice -> .idRoom
--	6.04	* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	6.03
alter view		dbo.vwRtlsRcvr
	with encryption
as
select	r.idReceiver, r.sReceiver	--, r.idRcvrType, t.sRcvrType, r.sPhone, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	r.idRoom, d.cDevice, d.sDevice, d.sSGJ	--, d.sSGJR
	,	d.sSGJ + ' [' + d.cDevice + '] ' + d.sDevice	as sFqDevice
	,	r.bActive, r.dtCreated, r.dtUpdated
	from	tbRtlsRcvr r
--		inner join	tbRtlsRcvrType t	on	t.idRcvrType = r.idRcvrType
		left outer join	vwDevice d	on	d.idDevice = r.idRoom
go
--	----------------------------------------------------------------------------
--	7.06.7261	- .idRcvrLast (fkRtlsBadge_LastRcvr), .dtRcvrLast, .idRoom (fkRtlsBadge_Room)
--				* .idRcvrCurr -> .idReceiver (fkRtlsBadge_CurrRcvr -> fkRtlsBadge_Receiver), .dtRcvrCurr -> .dtReceiver
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRtlsBadge') and name = 'idRcvrLast')
begin
	begin tran
		alter table	dbo.tbRtlsBadge	drop constraint fkRtlsBadge_LastRcvr
		alter table	dbo.tbRtlsBadge	drop constraint fkRtlsBadge_Room
		alter table	dbo.tbRtlsBadge	drop column	dtRcvrLast
		alter table	dbo.tbRtlsBadge	drop column	idRcvrLast
		alter table	dbo.tbRtlsBadge	drop column	idRoom

		exec sp_rename 'tbRtlsBadge.idRcvrCurr',	'idReceiver',	'column'
		exec sp_rename 'tbRtlsBadge.dtRcvrCurr',	'dtReceiver',	'column'
		exec sp_rename 'fkRtlsBadge_CurrRcvr',	'fkRtlsBadge_Receiver',	'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
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
select	b.idBadge	--, b.idBdgType, t.sBdgType
	,	sd.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.sFqStaff
	,	b.idReceiver, r.sReceiver, b.dtReceiver
	,	r.idRoom, d.cDevice, d.sDevice, d.sSGJ, b.dtEntered	--,	b.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
--	,	b.idRcvrCurr, r.sReceiver as sRcvrCurr, b.dtRcvrCurr
--	,	b.idRcvrLast, l.sReceiver as sRcvrLast, b.dtRcvrLast
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		join	tbDvc		sd	with (nolock)	on	sd.idDvc = b.idBadge
--		join	tbRtlsBdgType	t	with (nolock)	on	t.idBdgType = b.idBdgType
		left outer join	vwStaff		s	with (nolock)	on	s.idUser =	sd.idUser
--		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = b.idRoom
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idReceiver
--		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idRcvrCurr
--		left outer join	tbRtlsRcvr	l	with (nolock)	on	l.idReceiver = b.idRcvrLast
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = r.idRoom
go
--	----------------------------------------------------------------------------
--	7.06.7292	+ .idUser4, .idUser2, .idUser1
--	7.06.7262	+ .tiCall
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoom') and name = 'tiCall')
begin
	begin tran
		alter table	dbo.tbRoom	add
			idUser4		int				null		-- RTLS: Grn
				constraint	fkRoom_User4	foreign key references tb_User
		,	idUser2		int				null		-- RTLS: Ora
				constraint	fkRoom_User2	foreign key references tb_User
		,	idUser1		int				null		-- RTLS: Yel
				constraint	fkRoom_User1	foreign key references tb_User
		,	tiCall		tinyint			not null	-- RTLS: place badge-call?	4=G, 2=O, 1=Y
				constraint	tdRoom_Call		default( 0 )
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7292	+ .idUser4, .idUser2, .idUser1
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoom') and name = 'idUser4')
begin
	begin tran
		alter table	dbo.tbRoom	add
			idUser4		int				null		-- RTLS: Grn
				constraint	fkRoom_User4	foreign key references tb_User
		,	idUser2		int				null		-- RTLS: Ora
				constraint	fkRoom_User2	foreign key references tb_User
		,	idUser1		int				null		-- RTLS: Yel
				constraint	fkRoom_User1	foreign key references tb_User
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7292	+ xuRoom_User4, xuRoom_User2, xuRoom_User1
if	not exists	(select 1 from sys.indexes where object_id = OBJECT_ID('dbo.tbRoom') and name = 'xuRoom_User4')
begin
	begin tran
		create unique nonclustered index	xuRoom_User4	on	dbo.tbRoom ( idUser4 )	where	idUser4 is not null		-- 7.06.7292
		create unique nonclustered index	xuRoom_User2	on	dbo.tbRoom ( idUser2 )	where	idUser2 is not null		-- 7.06.7292
		create unique nonclustered index	xuRoom_User1	on	dbo.tbRoom ( idUser1 )	where	idUser1 is not null		-- 7.06.7292
	commit
end
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + registered staff
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
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, d.sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)		as sSGJ
	,	'[' + cDevice + '] ' + sDevice		as sQnDevice
--	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (#' + sDial + ')' end	as sFnDevice
	,	r.idEvent,	r.tiSvc
	,	r.idUserG,	s4.idStfLvl as idStfLvlG,	s4.sStaffID as sStaffIDG,	coalesce(s4.sStaff, r.sStaffG) as sStaffG,	s4.bOnDuty as bOnDutyG,	s4.dtDue as dtDueG
	,	r.idUserO,	s2.idStfLvl as idStfLvlO,	s2.sStaffID as sStaffIDO,	coalesce(s2.sStaff, r.sStaffO) as sStaffO,	s2.bOnDuty as bOnDutyO,	s2.dtDue as dtDueO
	,	r.idUserY,	s1.idStfLvl as idStfLvlY,	s1.sStaffID as sStaffIDY,	coalesce(s1.sStaff, r.sStaffY) as sStaffY,	s1.bOnDuty as bOnDutyY,	s1.dtDue as dtDueY
	,	r.dtExpires,	r.idUser4,	r.idUser2,	r.idUser1,	r.tiCall
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	tbDevice	d	with (nolock)
	join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
	left join	vwStaff	s4	with (nolock)	on	s4.idUser = r.idUserG
	left join	vwStaff	s2	with (nolock)	on	s2.idUser = r.idUserO
	left join	vwStaff	s1	with (nolock)	on	s1.idUser = r.idUserY
go
--	----------------------------------------------------------------------------
--	Returns devices filtered by unit, type and active status
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
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDevice
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.idDvcType & @idDvcType <> 0
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bStaff is null	or	@bStaff = 0	and	d.idUser is null	or	@bStaff = 1	and	d.idUser is not null )
		and		(@bGroup is null	or	d.tiFlags & 0x01 = @bGroup)
		and		(@idUnit is null	or	d.idDvcType = 1	or	d.idDvc in (select idDvc	from	tbDvcUnit	with (nolock)	where	idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given bar-code
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
		,	rb.idRoom, r.sQnDevice
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0
		and		d.sBarCode = @sBarCode
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given dial-code
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
		,	rb.idRoom, r.sQnDevice
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.bActive > 0
		and		d.sDial = @sDial
end
go
--	----------------------------------------------------------------------------
--	Returns a Wi-Fi device by the given ID
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
		,	rb.idRoom, r.sQnDevice
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.idDvc = @idDvc
		and		d.idDvcType = 0x08			--	Wi-Fi
end
go
--	----------------------------------------------------------------------------
--	7.06.7277	clear 'System' user
update	dbo.tb_Log	set	idUser =	null
	where	idUser = 4	and	idLogType	in	(101, 102, 103, 104)
go
--	----------------------------------------------------------------------------
--	Inserts, updates or deletes an access permission
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
				select	@s= 'Acc_I( ' + @s,	@k=	247

				insert	tb_Access	(  idModule,  idFeature,  idRole,  tiAccess )
						values		( @idModule, @idFeature, @idRole, @tiAccess )
			end
			else
			begin
				select	@s= 'Acc_U( ' + @s,	@k=	248

				update	tb_Access	set	dtUpdated=	getdate( ),	tiAccess =	@tiAccess
					where	idModule = @idModule and idFeature = @idFeature and idRole = @idRole
			end
		end
		else
		begin
				select	@s= 'Acc_D( ' + @s,	@k=	249

				delete	tb_Access
					where	idModule = @idModule and idFeature = @idFeature and idRole = @idRole
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a staff level
--	7.06.7279	* optimized logging
--	7.06.7115	* optimized logging (color in hex)
--	7.05.5219
alter proc		dbo.prStfLvl_Upd
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

	select	@s =	'StfLvl_U( ' + isnull(cast(@idStfLvl as varchar), '?') + ', ' +
					isnull(convert(varchar, convert(varbinary(4), @iColorB), 1), '?') + ', ''' + @sStfLvl + ''' )'

	begin	tran

		update	tbStfLvl	set	sStfLvl =	@sStfLvl,	iColorB =	@iColorB	--,	dtUpdated=	getdate( )
			where	idStfLvl = @idStfLvl

		exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
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

		delete	from	tbCfgFlt
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

		insert	tbCfgFlt	(  idIdx,  iFilter,  sFilter )
				values		( @idIdx, @iFilter, @sFilter )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

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
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtUpdated,	vbTone
			from	tbCfgTone	with (nolock)
			order	by	1
	else
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtUpdated
			from	tbCfgTone	with (nolock)
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

		insert	tbCfgTone	(  tiTone,  sTone,  vbTone )
				values		( @tiTone, @sTone, @vbTone )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
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

		update	tbCfgDome	set	iLight0 =	@iLight0,	iLight1 =	@iLight1,	iLight2 =	@iLight2
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

		update	tbCfgPri	set	tiTone =	null							-- clear FKs

		delete	from	tbCfgTone
		select	@s =	'Tone_C( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Pri_U( ' + isnull(cast(@siIdx as varchar),'?') +
					', '  + isnull(convert(varchar, convert(varbinary(1), @tiFlags), 1),'?') +	', ''' + isnull(@sCall,'?') +
--					''', f='  + isnull(cast(@tiFlags as varchar),'?') +
					''', sh=' + isnull(cast(@tiShelf as varchar),'?') +	'|' + isnull(cast(@tiSpec as varchar),'?') +
					', ug=' + isnull(cast(@siIdxUg as varchar),'?') +
					', ot=' + isnull(cast(@siIdxOt as varchar),'?') +	'|' + isnull(cast(@tiOtInt as varchar),'?') +
					', k=' + isnull(convert(varchar, convert(varbinary(4), @iColorF), 1),'?') +
					' /' + isnull(convert(varchar, convert(varbinary(4), @iColorB), 1),'?') +
					', ' + isnull(convert(varchar, convert(varbinary(4), @iFilter), 1),'?') +
					', ls=' + isnull(cast(@tiDome as varchar),'?') +
					', t=' + isnull(cast(@tiTone as varchar),'?') +		'|' + isnull(cast(@tiToneInt as varchar),'?') +
--					', cf=' + isnull(cast(@iColorF as varchar),'?') +	', cb=' + isnull(cast(@iColorB as varchar),'?') +
--					', fm=' + isnull(cast(@iFilter as varchar),'?') +
					' )'

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

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Sets given priority's clinic level
--	7.06.7279	* optimized logging
--	7.06.6345	* update and log only changes
--	7.06.6340
alter proc		dbo.prCfgPri_SetLvl
(
	@siIdx		smallint			-- call-index
,	@tiLvl		tinyint				-- clinic level
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Pri_SL( ' + isnull(cast(@siIdx as varchar), '?') + ', l=' + isnull(cast(@tiLvl as varchar), '?') + ' )'

	begin	tran
		update	tbCfgPri	set	tiLvl=	@tiLvl,		dtUpdated=	getdate( )
			where	siIdx = @siIdx
			and		tiLvl <> @tiLvl											--	7.06.6345

		if	@tiLog & 0x02 > 0	and	@@rowcount > 0							--	Config?
--		if	@tiLog & 0x04 > 0	and	@@rowcount > 0							--	Debug?
--		if	@tiLog & 0x08 > 0	and	@@rowcount > 0							--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates target times for a given call-priority
--	7.06.7279	* optimized logging
--	7.06.7117	+ @idModule
--	7.05.5044	* @idUser: smallint -> int
--	7.04.4902
alter proc		dbo.prCall_Upd
(
	@idCall		smallint
,	@bEnabled	bit
,	@tVoTrg		time( 0 )
,	@tStTrg		time( 0 )
,	@idUser		int
,	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	begin	tran

		update	tbCall	set	bEnabled =	@bEnabled,	tVoTrg =	@tVoTrg,	tStTrg =	@tStTrg,	dtUpdated=	getdate( )
			where	idCall = @idCall

		select	@s =	'Call_U( ' + isnull(cast(@idCall as varchar), '?') + ', e=' + isnull(cast(@bEnabled as varchar), '?') +
						', v=' + convert(varchar, @tVoTrg, 108) + ', s=' + convert(varchar, @tStTrg, 108) + ' )'
--						', v=' + isnull(cast(@tVoTrg as varchar), '?') + ', s=' + isnull(cast(@tStTrg as varchar), '?') + ' )'
		exec	dbo.pr_Log_Ins	72, @idUser, null, @s, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Imports enabled call-texts from tbCfgPri
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
		,		@idCall		smallint
		,		@siIdx		smallint			-- call-index
		,		@sCall		varchar( 16 )		-- call-text
		,		@pCall		varchar( 16 )		-- call-text
		,		@tVoTrg		time( 0 )
		,		@tStTrg		time( 0 )
		,		@iAdded		smallint
		,		@iRemed		smallint

	declare		cur		cursor fast_forward for
		select	siIdx, sCall
			from	tbCfgPri	with (nolock)
			where	siIdx > 0	and	tiFlags & 0x02 > 0		-- enabled
			order	by	1

	set	nocount	on

	select	@iAdded =	0,	@iRemed =	0

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tVoTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
	select	@tStTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall
		while	@@fetch_status = 0
		begin
			select	@idCall =	-1
			select	@idCall =	idCall,		@pCall =	sCall	from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0
	--		print	cast(@siIdx as varchar) + ': ' + @sCall + ' -> ' + cast(@idCall as varchar)

			if	@idCall > 0	and	@sCall <> @pCall
			begin
				update	tbCall	set	bActive =	0,	dtUpdated=	getdate( )
					where	idCall = @idCall

				select	@iRemed =	@iRemed + 1,	@idCall =	-1
			end

			if	@idCall < 0
			begin
	--			print	'  insert new'
				insert	tbCall	(  siIdx,  sCall,  tVoTrg,  tStTrg )
						values	( @siIdx, @sCall, @tVoTrg, @tStTrg )

				select	@iAdded =	@iAdded + 1
			end

			fetch next from	cur	into	@siIdx, @sCall
		end
		close	cur
		deallocate	cur

		update	c	set	c.bActive=	0,	dtUpdated=	getdate( )
			from	tbCall	c
			join	tbCfgPri	p	on	p.siIdx = c.siIdx	and	p.tiFlags & 0x02 = 0
			where	c.bActive > 0

		select	@s =	'Call_Imp( ) +' + cast(@iAdded as varchar) + ', *' + cast(@iRemed as varchar) + ', -' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0	and	@@rowcount > 0							--	Config?
--		if	@tiLog & 0x04 > 0	and	@@rowcount > 0							--	Debug?
--		if	@tiLog & 0x08 > 0	and	@@rowcount > 0							--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds call-text and inserts if necessary (not found)
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

				insert	tbCall	(  siIdx,  sCall,  tVoTrg,  tStTrg )
						values	( @siIdx, @sCall, @tVoTrg, @tStTrg )
				select	@idCall =	scope_identity( )

				select	@s =	@s + '  id=' + cast(@idCall as varchar)
				exec	dbo.pr_Log_Ins	72, null, null, @s

			commit
		end
	end
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

		delete	from	tbCfgLoc
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
	@idLoc		smallint			-- call-index
,	@idParent	smallint			-- parent look-up FK
,	@tiLvl		tinyint				-- level: 0=Facility 1=System 2=Building 3=Floor 4=Unit 5=CoverageArea
,	@sLoc		varchar( 16 )		-- location name
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') +
					', p=' + isnull(right('00' + cast(@idParent as varchar), 3), '?') +
					', l=' + isnull(cast(@tiLvl as varchar), '?') + ', ''' + isnull(@sLoc, '?') + ''' )'

	begin	tran

		insert	tbCfgLoc	(  idLoc,  idParent,  tiLvl,  cLoc,  sLoc, sPath )
				values		( @idLoc, @idParent, @tiLvl, '?', @sLoc, '' )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a role
--	7.06.7279	* optimized logging
--	7.06.6814	* added logging of units
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

	select	@s =	'[' + isnull(cast(@idRole as varchar), '?') + '] ''' + @sRole + ''', d=' + isnull(cast(@sDesc as varchar), '?') +
					', a=' + cast(@bActive as varchar) + ', U=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_Role where idRole = @idRole)
		begin
			insert	tb_Role	(  sRole,  sDesc,  bActive )
					values	( @sRole, @sDesc, @bActive )
			select	@idRole =	scope_identity( )

			select	@k =	242,	@s =	'Role_I( ' + @s + ' )=' + cast(@idRole as varchar)
		end
		else
		begin
			update	tb_Role	set	sRole=	@sRole,		sDesc=	@sDesc,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idRole = @idRole

			select	@k =	243,	@s =	'Role_U( ' + @s + ' )'
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62	--	J7980cw

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

	select	@s =	'[' + isnull(cast(@idTeam as varchar), '?') + '] ''' + @sTeam + ''', d=' + isnull(cast(@sDesc as varchar), '?') +
					', t=' + convert(varchar, @tResp, 108) + ', a=' + cast(@bActive as varchar) +
					', c=' + isnull(cast(@sCalls as varchar), '?') + ' u=' + isnull(cast(@sUnits as varchar), '?')
					-- + ' ' + convert(varchar, @dtCreated, 20) + ' ' + convert(varchar, @dtUpdated, 20)
	begin	tran

		if	not exists	(select 1 from tbTeam with (nolock) where idTeam = @idTeam)
		begin
			insert	tbTeam	(  sTeam,  sDesc,  tResp,  bActive )	--,  sCalls,  sUnits
					values	( @sTeam, @sDesc, @tResp, @bActive )	--, @sCalls, @sUnits
			select	@idTeam =	scope_identity( )

			select	@k =	247,	@s =	'Team_I( ' + @s + ' )=' + cast(@idTeam as varchar)
		end
		else
		begin
			select	@k =	248,	@s =	'Team_U( ' + @s + ' )'

			update	tbTeam	set	sTeam=	@sTeam,	sDesc=	@sDesc,	tResp=	@tResp,	bActive =	@bActive,	dtUpdated=	getdate( )	--,	sCalls=	@sCalls,	sUnits=	@sUnits
				where	idTeam = @idTeam
		end

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62	--	J7980cw

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
--	Inserts or updates devices during 790 Config download
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@idUnit		smallint
		,		@sUnits		varchar( 255 )
		,		@iAID0		int
	
	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 26

	select	@s =	'Dvc_IU( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					' [' + isnull(@cDevice,'?') + '] ''' + isnull(@sDevice,'?') + ''' #' + isnull(@sDial,'?') + ', v=' + isnull(@sCodeVer,'?') +
					', p0=' + isnull(cast(@tiPriCA0 as varchar),'?') + ', p1=' + isnull(cast(@tiPriCA1 as varchar),'?') + ' )'

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0

--	if	@iAID <> 0
--		select	@idDevice= idDevice		from	tbDevice		where	iAID = @iAID
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0		and	@iAID <> 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	---and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0
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

		if	@tiJID = 0														-- gateway		--	7.06.5414
		begin
--			select	@sUnits =	@sDial,		@sDial =	null				-- @sDial == IP for GWs		--	7.06.5855

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

		if	@idDevice > 0													-- device found - update	--	7.06.5855
		begin
			update	tbDevice	set		bConfig =	1,	dtUpdated=	getdate( )	--, idEvent =	null
				,	idParent =	@idParent,	cSys =	@cSys,	tiGID=	@tiGID,	tiJID=	@tiJID,	tiRID=	@tiRID,	sDial=	@sDial
				,	tiStype =	@tiStype,	cDevice =	@cDevice,	sDevice =	@sDevice,	sCodeVer =	@sCodeVer,	sUnits =	@sUnits
				,	tiPriCA0 =	@tiPriCA0,	tiPriCA1 =	@tiPriCA1,	tiPriCA2 =	@tiPriCA2,	tiPriCA3 =	@tiPriCA3
				,	tiPriCA4 =	@tiPriCA4,	tiPriCA5 =	@tiPriCA5,	tiPriCA6 =	@tiPriCA6,	tiPriCA7 =	@tiPriCA7
				,	tiAltCA0 =	@tiAltCA0,	tiAltCA1 =	@tiAltCA1,	tiAltCA2 =	@tiAltCA2,	tiAltCA3 =	@tiAltCA3
				,	tiAltCA4 =	@tiAltCA4,	tiAltCA5 =	@tiAltCA5,	tiAltCA6 =	@tiAltCA6,	tiAltCA7 =	@tiAltCA7
				,	@s =	@s + '*',	@iAID0 =	isnull(iAID, 0)
				where	idDevice = @idDevice

			if	@iAID <> 0	and		@iAID <> @iAID0							--	7.06.6768
			begin
				select	@s =	@s + ' a:' + isnull(cast(convert(varchar, convert(varbinary(4), iAID), 1) as varchar),'?')
	--	-						+ '->' + cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar)		-- already logged
					from	tbDevice
					where	idDevice = @idDevice

				update	tbDevice	set		iAID= @iAID
					where	idDevice = @idDevice
			end

			if	@sCodeVer is not null
				update	tbDevice	set		sCodeVer= @sCodeVer
					where	idDevice = @idDevice
		end
		else																-- insert new device
		begin
			insert	tbDevice	( idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial,  sCodeVer,  sUnits	--,  idUnit
								,	tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
								,	tiAltCA0,  tiAltCA1,  tiAltCA2,  tiAltCA3,  tiAltCA4,  tiAltCA5,  tiAltCA6,  tiAltCA7 )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial, @sCodeVer, @sUnits	--, @idUnit
								,	@tiPriCA0, @tiPriCA1, @tiPriCA2, @tiPriCA3, @tiPriCA4, @tiPriCA5, @tiPriCA6, @tiPriCA7
								,	@tiAltCA0, @tiAltCA1, @tiAltCA2, @tiAltCA3, @tiAltCA4, @tiAltCA5, @tiAltCA6, @tiAltCA7 )
			select	@idDevice=	scope_identity( )
				,	@s =	@s + '+'

			if	@iAID <> 0													--	7.06.5855, 7.06.6768
				update	tbDevice	set		iAID= @iAID
					where	idDevice = @idDevice
		end

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
		begin
			select	@s =	@s + '=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit
		,		@sD			varchar( 16 )
		,		@iA			int

	set	nocount	on

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 26

	if	charindex('SIP:', @sDevice) = 1										-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '", #' + isnull(@sDial,'?') + ' )'

	-- match 7967-P workflow station's (0x1A) 'phantom' RIDs
	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow

		-- match active devices?
		select		@idDevice=	idDevice,	@bActive =	bActive									--	7.06.6758
				from	tbDevice	with (nolock)
				where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		-- match inactive devices?
		if	@idDevice is null
			select	@idDevice=	idDevice,	@bActive =	bActive
				from	tbDevice	with (nolock)
				where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice

/*			select	@sD =	sDevice,	@iA =	iAID											--	7.06.6758, .6773
				from	tbDevice
				where	idDevice = @idDevice

			if	@sD <> @sDevice
				select	@s =	@s + ' ^n:"' + @sD + '"'

			if	@iA <> @iAID
				select	@s =	@s + ' ^a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

			if	@sD <> @sDevice	or	@iA <> @iAID
				exec	dbo.pr_Log_Ins	82, null, null, @s
*/
			return	0												-- match found
		end
	end

	-- adjust AID
	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0


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


	if	@idDevice > 0																			--	7.06.5560
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		select	@sD =	sDevice,	@iA =	iAID												--	7.06.6758
			from	tbDevice
			where	idDevice = @idDevice

		if	@tiRID = 0	and	@sD <> @sDevice
			select	@s =	@s + ' ^N:"' + @sD + '"'

		if	@iA <> @iAID
			select	@s =	@s + ' ^A:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

		if	@tiRID = 0	and	@sD <> @sDevice		or	@iAID <> 0	and	@iA <> @iAID
			exec	dbo.pr_Log_Ins	82, null, null, @s

		return	0															-- match found
	end

	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	begin
		begin	tran

			if	charindex(@cSys, @sSysts) = 0								-- not in Allowed Systems
			begin
				select	@s =	@s + ' !cSys'
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

				if	@tiLog & 0x02 > 0										--	Config?
--				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
				begin
					select	@s =	@s + '=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
					exec	dbo.pr_Log_Ins	74, null, null, @s
				end
			end

		commit
	end
	else																	-- no name / system		7.06.5560
	begin
		select	@s =	@s + ' !sDvc'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
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

		delete	from	tbCfgMst
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

	if	not exists	(select 1 from tbCfgMst with (nolock) where idMaster = @idMaster and tiCvrg = @tiCvrg)
	begin
		begin	tran

			insert	tbCfgMst	(  idMaster,  tiCvrg,  iFilter )
					values		( @idMaster, @tiCvrg, @iFilter )

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
--	7.06.7279	* optimized logging
--	7.06.5914	* 74->76
--	7.06.5905	* 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgDvcBtn_Clr
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	begin	tran

		delete	from	tbCfgDvcBtn
		select	@s =	'DvcBtn_C( ) ' + cast(@@rowcount as varchar)

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	76, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a device button input
--	7.06.7279	* optimized logging
--	7.06.5914	* trace:0x20, 74->76
--	7.06.5905	* trace:0x04, 72->74
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'DvcBtn_I( ' + isnull(cast(@idDevice as varchar), '?') + ', bt=' + isnull(cast(@tiBtn as varchar), '?') +
					', p=' + isnull(cast(@siPri as varchar), '?') + ', bd=' + isnull(cast(@tiBed as varchar), '?') + ' )'

	if	@tiBed = 0xFF		select	@tiBed =	null						--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgDvcBtn with (nolock) where idDevice = @idDevice and tiBtn = @tiBtn)
	begin
		begin	tran

			insert	tbCfgDvcBtn	(  idDevice,  tiBtn,  siPri,  tiBed )
					values		( @idDevice, @tiBtn, @siPri, @tiBed )

			if	@tiLog & 0x02 > 0											--	Config?
--			if	@tiLog & 0x04 > 0											--	Debug?
--			if	@tiLog & 0x08 > 0											--	Trace?
				exec	dbo.pr_Log_Ins	76, null, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
--	7.06.7326	* enforce 'Other' users un-assignable and off-duty
--	7.06.7326	* inactive user can't stay on-duty
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

	if	@bActive = 0		select	@bOnDuty =	0							--	7.06.7326
	if	@idStfLvl is null	select	@bOnDuty =	0,	@sUnits =	null		--	7.06.7334

	exec	dbo.prUnit_SetTmpFlt	@sUnits
	exec	dbo.prTeam_SetTmpFlt	@sTeams
	exec	dbo.prRole_SetTmpFlt	@sRoles

	-- enforce membership in 'Public' role
	if	not exists	(select 1 from #tbRole with (nolock) where idRole = 1)
		insert	#tbRole		(idRole)	values	( 1 )

	select	@s =	isnull(cast(@idOper as varchar), '?') + '|' + @sUser + ', f="' + isnull(cast(@sFrst as varchar), '?') +
					'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
					'", e="' + isnull(cast(@sEmail as varchar), '?') + '", d="' + isnull(cast(@sDesc as varchar), '?') +
					'", I="' + isnull(cast(@sStaffID as varchar), '?') + '", L=' + isnull(cast(@idStfLvl as varchar), '?') +
					', B="' + isnull(cast(@sBarCode as varchar), '?') + '", D=' + isnull(cast(@bOnDuty as varchar), '?') +
					', a=' + cast(@bActive as varchar) + ', R=' + isnull(cast(@sRoles as varchar), '?') +
					', T=' + isnull(cast(@sTeams as varchar), '?') + ', U=' + isnull(cast(@sUnits as varchar), '?')
	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idOper)
		begin
			insert	tb_User	(  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  sStaff
							,  sStaffID,  idStfLvl,  sBarCode,  bOnDuty,  bActive )	--,  sUnits,  sTeams
					values	( @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, ' '
							, @sStaffID, @idStfLvl, @sBarCode, @bOnDuty, @bActive )	--, @sUnits, @sTeams
			select	@idOper =	scope_identity( )

			select	@k =	237,	@s =	'Usr_I( ' + @s + ' )=' + cast(@idOper as varchar)
		end
		else
		begin
			update	tb_User	set		sUser=	@sUser,		iHash=	@iHash,		tiFails =	@tiFails,	sFrst=	@sFrst
								,	sMidd=	@sMidd,		sLast=	@sLast,		sEmail =	@sEmail,	sDesc=	@sDesc
								,	sStaffID =	@sStaffID,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode
						--		,	sUnits =	@sUnits,	sTeams =	@sTeams
								,	bOnDuty =	case when	@bActive = 0	then	0	else	@bOnDuty	end
								,	dtDue =		case when	@bActive = 0	or	@idStfLvl is null	then	null	else	dtDue	end
								,	bActive =	@bActive,	dtUpdated=	getdate( )
						--		,	bOnDuty =	@bOnDuty,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@k =	238,	@s =	'Usr_U( ' + @s + ' )'
		end

		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s, 62	--	J7980cw

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
--	Inserts or updates a device
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

	if	@idDvcType = 0x08		--	Wi-Fi
		select	@sUnits =	null,	@sTeams =	null		-- enforce no Units or Teams for Wi-Fi devices
	else
	begin
		exec	dbo.prUnit_SetTmpFlt	@sUnits
		exec	dbo.prTeam_SetTmpFlt	@sTeams
	end

	select	@s =	'[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', ''' + @sDvc +
					''', b=' + isnull(cast(@sBarCode as varchar), '?') + ', #' + isnull(cast(@sDial as varchar), '?') +
					', f=' + cast(@tiFlags as varchar) + ', a=' + cast(@bActive as varchar) +
					', U=' + isnull(cast(@sUnits as varchar), '?') + ', T=' + isnull(cast(@sTeams as varchar), '?')
--	exec	dbo.pr_Log_Ins	1, @idUser, null, @s

	begin	tran

		if	not exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  bActive )	--,  sUnits,  sTeams
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @bActive )	--, @sUnits, @sTeams
			select	@idDvc =	scope_identity( )

			select	@k =	247,	@s =	'Dvc_I( ' + @s + ' )=' + cast(@idDvc as varchar)
		end
		else
		begin
			select	@k =	248,	@s =	'Dvc_U( ' + @s + ' )'

			update	tbDvc	set	idDvcType=	@idDvcType,		sDvc =		@sDvc
							,	sDial=		@sDial,			sBarCode =	@sBarCode,		tiFlags =	@tiFlags
							,	idUser =	case when	@bActive > 0	then	idUser	else	null	end		-- unassign deactivated
					--		,	sUnits =	@sUnits,		sTeams =	@sTeams
							,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc

/*			if	@idDvcType = 0x01		--	badge
				and	@bActive = 0		--	disabled
				update	tbRtlsBadge		set	dtEntered=	null
					where	idBadge = @idDvc
*/		end

		if	@idDvcType = 0x08		--	Wi-Fi
			update	tbDvc	set	sBarCode =	cast(@idDvc as varchar)		-- enforce barcode to == DvcID for Wi-Fi devices
				where	idDvc = @idDvc

		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s, 62	--	J7980cw

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
--	Returns all rooms, ordered to be loadable into a combobox (indicating inactive)
--	7.05.5161	* active -> all, + '(inactive)' indication
--	7.04.4959	prRoom_GetAct -> prRoom_LstAct
--	7.04.4953	* added ' '
--	7.03
alter proc		dbo.prRoom_LstAct
	with encryption
as
begin
--	set	nocount	on
	select	idDevice	as	idRoom
		,	sSGJ + ' ' + sQnDevice + case
				when bActive = 0 then ' -- (inactive)'
				else ''	end		as	sQnRoom
		from	vwRoom	with (nolock)
	--	where	bActive > 0
		order	by	2
end
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
			from	tbDoctor	with (nolock)
			where	sDoctor = @sDoctor	and	bActive > 0

		if	@idDoctor is null
		begin
			begin	tran
				insert	tbDoctor	(  sDoctor )
						values		( @sDoctor )
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
		update	tbDoctor	set	sDoctor= @sDoctor, bActive= @bActive
							,	dtUpdated=	getdate( )
			where	idDoctor = @idDoctor

		exec	dbo.pr_Log_Ins	44, null, null, @s
	commit
end
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
--	7.06.7279	* optimized logging
--	7.06.7222	+ treat 'EMPTY' as 'no patient'
--				+ 0xFF gender -> 'U'
--				+ quotes in trace
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
	declare		@idDoc		int
	declare		@cGen		char( 1 )
	declare		@sInf		varchar( 32 )
--	declare		@sNot		varchar( 255 )

	set	nocount	on

	if	@cGender is null	or	ascii(@cGender) = 0xFF
		select	@cGender=	'U'

	if	@sPatient = 'EMPTY'													--	.7222	treat 'EMPTY' as 'no patient'
		select	@sPatient=	null

	if	0 < len( @sPatient )
	begin
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

		select	@idPatient=	idPatient,	@cGen= cGender,		@sInf= sInfo,	@idDoc= idDoctor	--, @sNot= sNote
			from	tbPatient	with (nolock)
			where	sPatient = @sPatient	and	bActive > 0

		begin	tran

			if	@idPatient is null											--	no active patient with given name found
			begin
				insert	tbPatient	(  sPatient,  cGender,  sInfo,  idDoctor )	--,  sNote
						values		( @sPatient, @cGender, @sInfo, @idDoctor )	--, @sNote
				select	@idPatient=	scope_identity( )

				select	@s =	'Pat_I( ''' + isnull(@sPatient,'?') + ''' ''' + isnull(@cGender,'?') + ''', i="' + isnull(@sInfo,'?') +
		--						'", n="' + isnull(@sNote,'?') +
								'", d=' + isnull(cast(@idDoctor as varchar),'?') + ' ) id=' + cast(@idPatient as varchar)
				exec	dbo.pr_Log_Ins	44, null, null, @s
			end
			else															--	found active patient with given name
			begin
				select	@s=	''
				if	@cGen <> @cGender	select	@s =	@s + ', g=' + isnull(@cGender,'?')
				if	@sInf <> @sInfo		select	@s =	@s + ', i="' + isnull(@sInfo,'?') + '"'
		--		if	@sNot <> @sNote		select	@s =	@s + ', n="' + isnull(@sNote,'?') + '"'
				if	@idDoc <> @idDoctor	select	@s =	@s + ', d=[' + isnull(cast(@idDoctor as varchar),'?') + ']'		-- + isnull(@sDoctor,'?')

				if	0 < len( @s )											--	smth has changed
				begin
					update	tbPatient	set	cGender =	@cGender,	sInfo=	@sInfo,	idDoctor =	@idDoctor,	dtUpdated=	getdate( )	--, sNote= @sNote
						where	idPatient = @idPatient

					select	@s =	'Pat_U( [' + cast(@idPatient as varchar) + '] ' + isnull(@sPatient,'?') + @s + ' )'
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
			update	tbCfgBed	set	cBed =	@cBed,	cDial=	@cDial,		dtUpdated=	getdate( )
				where	tiBed = @tiBed

			select	@s =	@s + ' *'
		end
		else
		begin
			insert	tbCfgBed	(  tiBed,  cBed,  cDial,  siBed )
					values		( @tiBed, @cBed, @cDial, @siBed )

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
,	@tiRID		tinyint
,	@tiBed		tinyint
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idRoom		smallint
		,		@idPrev		smallint
		,		@tiPrev		tinyint
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

	select	@s =	'Pat_UL( ' + isnull(cast(@idPatient as varchar),'?') + '|' + isnull(@sPatient,'?') +
					', ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(@sDevice,'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + ' )'

	if	@idRoom is null
		select	@s =	@s + ' !SGJ'

	if	@sPatient is null
		select	@s =	@s + ' !P'

	if	@tiBed > 9		or
		@idRoom is not null	and
		not exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = @tiBed)
		select	@tiBed =	null,	@s =	@s + ' !B'

	if	(@tiBed = 0		or	@tiBed is null)
		and	exists	(select 1 from tbRoomBed with (nolock) where idRoom = @idRoom and tiBed = 0xFF)
		select	@tiBed =	0xFF		-- auto-correct for no-bed rooms from bed 0

	if	@idRoom is null		or	@sPatient is null	or
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

---		if	@idPatient > 1				-- exempt idPatient = 1 (EMPTY) from moving around	--	7.06.6744
		if	0 < @idPatient													--	7.06.7222
		begin
	/*		select	@idPrev =	idRoom,		@tiPrev =	tiBed
				from	tbRoomBed	with (nolock)
				where	idPatient = @idPatient

			if	@idRoom <> @idPrev	or	@tiBed <> @tiPrev		-- patient has moved?
				or	@idRoom is null	and	@idPrev > 0
				or	@idRoom > 0		and	@idPrev is null
			begin
	*/			-- clear previous location (if different) of the given patient
				update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	null
					where	idPatient = @idPatient
					and	(	idRoom <> @idRoom	or	tiBed <> @tiBed	)
				-- place the given patient into given room-bed (if he's not there already)
				update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	@idPatient
					where	idRoom = @idRoom	and	tiBed = @tiBed
					and	(	idPatient is null	or	idPatient <> @idPatient	)
	--		end
		end
		else	-- clear given room-bed
				update	tbRoomBed	set		dtUpdated=	getdate( ),	idPatient=	null
					where	idRoom = @idRoom	and	tiBed = @tiBed
					and		idPatient is not null

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
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

--	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

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

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins1'

		if	@tiBed is not null												-- mark a bed in active use
			update	tbCfgBed	set	bActive =	1,	dtUpdated=	getdate( )	where	tiBed = @tiBed	and	bActive = 0

		if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)					-- audio, set-svc, pat-dtl-req events:	flip Src and Dst devices
		begin
			select	@cSys =		@cSrcSys,	@tiGID =	@tiSrcGID,	@tiJID =	@tiSrcJID,	@tiLvl =	@tiSrcRID,	@sDvc =		@sSrcDvc,	@iAID2=	@iAID,	@tiStype2=	@tiStype
			select	@cSrcSys =	@cDstSys,	@tiSrcGID=	@tiDstGID,	@tiSrcJID=	@tiDstJID,	@tiSrcRID=	@tiDstRID,	@sSrcDvc=	@sDstDvc
			select	@cDstSys =	@cSys,		@tiDstGID=	@tiGID,		@tiDstJID=	@tiJID,		@tiDstRID=	@tiLvl,		@sDstDvc=	@sDvc,		@iAID=	null,	@tiStype =	null
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins2'

		exec		dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @iAID2, @tiStype2, @cDevice, @sDstDvc, null, @idDstDvc out

--		if	@tiLog & 0x04 > 0												--	Debug?
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

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	1, null, null, 'Evt_Ins4'

--		select	@s=	'Evt_i1: src=' + isnull(cast(@idSrcDvc as varchar),'?') + ' dst=' + isnull(cast(@idDstDvc as varchar),'?') + ' evt=' + isnull(cast(@idEvent as varchar),'?')
--		exec	pr_Log_Ins	0, null, null, @s

		if	len(@p) > 0
		begin
			select	@s =	@s + '=' + isnull(cast(@idEvent as varchar),'?') + @p
			exec	dbo.pr_Log_Ins	82, null, null, @s
		end

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	6.02										-- set tbEvent.idParent, .idRoom, .tParent; tbRoom.idUnit
		begin

--			if	@tiLog & 0x04 > 0											--	Debug?
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
--	Registers or unregisters given module
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

	select	@s =	'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', ' + isnull(@sVersion, '?') +
					', ip=' + isnull(@sIpAddr, '?') + ', m=' + isnull(@sMachine, '?') + ', d=''' + isnull(@sDesc, '?') + ''', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'
		,	@idLogType =	61

	begin	tran

		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule)
		begin
			if	@sMachine is null	--	and	@sIpAddr is null				-- un-register
			begin
				update	tb_Module	set		sIpAddr =	null,		sMachine =	null,		sVersion =	null
										,	dtStart =	null,		sParams =	null
					where	idModule = @idModule

				select	@s =	'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', ' + isnull(@sVersion, '?') + ' )'
					,	@idLogType =	62
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

			select	@s =	@s + ' +'
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

	select	@s =	'Mod_Lic( ' + right('00' + cast(@idModule as varchar), 3) + ', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'

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
--	Sets given module's logging level
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

		update	tb_Module		set	tiLvl=	@tiLvl,		@s=	sModule
			where	idModule = @idModule

		select	@s =	'Mod_SL( ' + right('00' + cast(@idModule as varchar), 3) + '::' + @s + ', l=' + isnull(cast(@tiLvl as varchar), '?') + ' )'

		exec	dbo.pr_Log_Ins	64, @idUser, null, @s, @idFeature

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
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
--,	@sCall		varchar( 16 )		-- call-text
,	@siIdx		smallint			-- call-index
--,	@dtAttempt	datetime			-- when page was sent to encoder
--,	@biPager	bigint				-- pager number
,	@idPcsType	tinyint				-- PCS action subtype
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

	if	@idUser is null
		select	@idUser= idUser
			from	tbDvc	with (nolock)
			where	idDvc = @idDvc

--	select	@idLogType =	82,		@idUser =	null
	select	@idLogType =	case when	@idDvcType = 8	then	206			-- wi-fi
								when	@idDvcType = 4	then	204			-- phone
								when	@idDvcType = 2	then	205			-- pager
								else							82	end
--		,	@idUser= idUser
--		from	tbDvc	with (nolock)
--		where	idDvc = @idDvc

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
--	Imports a shift
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
,	@tiNotify	tinyint				-- notification mode: 0=Auto, 1=SemiAuto, 2=Manual [, 3=FollowConsole]
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

	select	@s =	'Sh_Imp( ' + isnull(cast(@idShift as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', ix=' + isnull(cast(@tiIdx as varchar),'?') +
					', ''' + isnull(cast(@sShift as varchar),'?') + ''', ' + isnull(convert(varchar, @tBeg, 108),'?') + '..' + isnull(convert(varchar, @tEnd, 108),'?') +
					', nt=' + isnull(cast(@tiNotify as varchar),'?') + ', bk=' + isnull(cast(@idUser as varchar),'?') + ', a=' + isnull(cast(@bActive as varchar),'?') +
					', cr=' + isnull(convert(varchar, @dtCreated, 20),'?') + ', up=' + isnull(convert(varchar, @dtUpdated, 20),'?') + ' )'

--		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

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
--	Imports a staff assignment definition
--	7.05.5940	* optimize logging
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

	select	@idRoom =	idDevice	from	vwRoom		with (nolock)	where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID
	select	@idShift =	idShift		from	tbShift		with (nolock)	where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx
	select	@idUser =	idUser		from	tb_User		with (nolock)	where	bActive > 0		and	sStaffID = @sStaffID

	select	@s =	'SA_Imp( ' + isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) +
					'-' + right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + ', u=' + isnull(cast(@idUnit as varchar),'?') +
					', sh[' + isnull(cast(@tiShIdx as varchar),'?') + ']=' + isnull(cast(@idShift as varchar),'?') +
					', st[' + @sStaffID + ']=' + isnull(cast(@idUser as varchar),'?') + ' ) rm=' + isnull(cast(@idRoom as varchar),'?')

	begin	tran

		if	@idRoom is null		or	@idShift is null	or	@idUser is null
			exec	dbo.pr_Log_Ins	47, null, null, @s
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
--	Inserts, updates or "deletes" staff assignment definitions
--	7.06.7279	* optimized logging
--	7.05.5940	* optimize logging
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@idShift	smallint

	set	nocount	on

	select	@idShift =	idShift												--	get corresponding shift
		from	tbShift		with (nolock)
		where	bActive > 0		and	idUnit = @idUnit	and	tiIdx = @tiShIdx

	if	@idRoom = 0	or	@idRoom is null
		select	@idRoom =	idDevice										--	get corresponding room
			from	vwRoom		with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID		and	tiJID = @tiJID

	if	@idUser = 0	or	@idUser is null
		select	@idUser =	idUser											--	get corresponding user
			from	tb_User		with (nolock)
			where	bActive > 0		and	sStaffID = @sStaffID

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'SA_IUD( ID=' + isnull(cast(@idStfAssn as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') +
					', sh[' + isnull(cast(@tiShIdx as varchar),'?') + ']=' + isnull(cast(@idShift as varchar),'?') +
					', rm=' + isnull(cast(@idRoom as varchar),'?') + ', bd=' + isnull(cast(@tiBed as varchar),'?') +
					', assn[' + isnull(cast(@tiIdx as varchar),'?') + ']=' + isnull(cast(@idUser as varchar),'?') +
					', a?=' + isnull(cast(@bActive as varchar),'?')

	if	@tiGID > 0
		select	@s =	@s + ', ' + isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) +
						'-' + right('0' + isnull(cast(@tiJID as varchar),'?'), 2)
	if	len(@sStaffID) > 0
		select	@s =	@s + ', st=[' + @sStaffID + ']'

	select	@s =	@s + ' )'

	begin	tran

		if	@idStfAssn > 0	and	( @bActive = 0	or	@idUser is null )
			exec	dbo.prStfAssn_Fin	@idStfAssn							--	finalize assignment
	
		else
		if	@bActive > 0	and	@idShift > 0	and	@idRoom > 0		and	@tiBed >= 0		and	@tiShIdx > 0	and	@tiIdx > 0	and	@idUser > 0
		begin
			if	@idStfAssn > 0
				if	exists( select 1 from tbStfAssn where idStfAssn = @idStfAssn and idUser <> @idUser )
				begin
					exec	dbo.prStfAssn_Fin	@idStfAssn					--	another staff is assigned - finalize previous one

					select	@idStfAssn =	null
				end

			if	@idStfAssn = 0	or	@idStfAssn is null
			begin
				insert	tbStfAssn	(  idRoom,  tiBed,  idShift,  tiIdx,  idUser )
						values		( @idRoom, @tiBed, @idShift, @tiIdx, @idUser )
				select	@idStfAssn =	scope_identity( )
				select	@s =	@s + ': ' + cast(@idStfAssn as varchar)
			end
		end
		else
		begin
			select	@s =	@s + ' !args'
			exec	dbo.pr_Log_Ins	47, null, null, @s
			commit
			return	-1
		end

--		if	@tiLog & 0x02 > 0												--	Config?
		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	46, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a shift
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

	select	@s =	'[' + isnull(cast(@idShift as varchar), '?') + '] u=' + isnull(cast(@idUnit as varchar), '?') + ', ix=' + isnull(cast(@tiIdx as varchar), '?') +
					', ''' + isnull(cast(@sShift as varchar),'?') + ''', ' + isnull(convert(varchar, @tBeg, 108),'?') + '..' + isnull(convert(varchar, @tEnd, 108),'?') +
					', nt=' + isnull(cast(@tiNotify as varchar),'?') + ', bk=' + isnull(cast(@idOper as varchar),'?') + ', a=' + isnull(cast(@bActive as varchar),'?')

	begin	tran

		if	@idShift is null	or	@idShift < 0
		begin
			insert	tbShift	(  idUnit,  tiIdx,  sShift,  tBeg,  tEnd )
					values	( @idUnit, @tiIdx, @sShift, @tBeg, @tEnd )
			select	@idShift =	scope_identity( )

			select	@s =	'Shft_I( ' + @s + ' )=' + cast(@idShift as varchar)
				,	@k =	247
		end
		else
		begin
			if	@tiNotify is not null
				update	tbShift		set		dtUpdated=	getdate( ),	tiNotify =	@tiNotify,	idUser =	@idOper
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

			select	@s =	'Shft_U( ' + @s + ' )'
				,	@k =	248
		end

		exec	dbo.prUnit_UpdShifts	@idUnit
		exec	dbo.pr_Log_Ins	@k, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets .bConfig for all devices under a given GW, resets corresponding rooms' state
--	7.06.7279	* optimized logging
--	7.05.5940	* optimize logging
--	7.06.5914	+ don't reset tbRoomBed.idUser[i]
--	7.06.5906	+ @cSys, @tiGID
--	7.06.5854	* "cDevice <> 'P'" instead of "tiStype is not null"
--	7.06.5529	+ tbRoomBed reset
--	7.06.5465	* tbRoom:	.idRn -> .idUserG, .sRn -> .sStaffG,	.idCn -> .idUserO, .sCn -> .sStaffO,	.idAi -> .idUserY, .sAi -> .sStaffY
--	7.06.5352	+ 'and tiStype is not null' - don't deactivate SIP devices
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03.4862
alter proc		dbo.prCfgDvc_Init
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
			from	tbRoom		r
			join	tbDevice	d	on	d.idDevice = r.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
	--		where	idRoom	in (select	idDevice	from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiRID = 0)
		select	@s =	@s + cast(@@rowcount as varchar) + ' rm, '

		update	rb	set	tiIBed =	null,	idEvent =	null,	tiSvc =		null,	dtUpdated=	getdate( )
--	-				,	idUser1 =	null,	idUser2 =	null,	idUser3 =	null,	idPatient=	null
			from	tbRoomBed	rb
			join	tbDevice	d	on	d.idDevice = rb.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
	--		where	idRoom	in (select	idDevice	from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiRID = 0)
		select	@s =	@s + cast(@@rowcount as varchar) + ' rb, '

		update	tbDevice	set	bConfig =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID
	--		where	bActive > 0
	--		and		cDevice <> 'P'											--	skip SIP phones		--	7.06.5854
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
--	7.06.7279	* optimized logging
--	7.05.5940	* optimize logging
--	7.06.5912	+ set current assigned staff
--	7.06.5907
alter proc		dbo.prCfgDvc_UpdAct
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

		update	tbDevice	set	bActive =	1,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig > 0		and	bActive = 0
		select	@s =	@s + cast(@@rowcount as varchar) + ', -'

		update	tbDevice	set	bActive =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig = 0		and	bActive > 0
		select	@s =	@s + cast(@@rowcount as varchar)

		-- set current assigned staff
		update	rb	set		idUser1 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbDevice	d	on	d.idDevice = r.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 1
											and	sa.idShift = u.idShift	and	sa.bActive > 0

		update	rb	set		idUser2 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbDevice	d	on	d.idDevice = r.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 2
											and	sa.idShift = u.idShift	and	sa.bActive > 0

		update	rb	set		idUser3 =	sa.idUser
			from	tbRoomBed	rb
			join	tbRoom		r	on	r.idRoom = rb.idRoom
			join	tbDevice	d	on	d.idDevice = r.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
			join	tbUnit		u	on	u.idUnit = r.idUnit
			join	tbStfAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed	and	sa.tiIdx = 3
											and	sa.idShift = u.idShift	and	sa.bActive > 0

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
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

		update	tbRtlsRcvr	set	bActive =	0,	dtUpdated=	getdate( )
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

		update	tbRtlsBadge	set	bActive =	0,	dtUpdated=	getdate( )
			where	bActive = 1

		update	d			set	bActive =	0,	dtUpdated=	getdate( )
			from	tbDvc	d
			join	tbRtlsBadge	b	on	b.idBadge = d.idDvc
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
--	Updates room's beds and configures corresponding tbRoomBed rows
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
alter proc		dbo.prDevice_UpdRoomBeds
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


	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

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


	select	@s =	'Dvc_URB( ' + isnull(cast(@idRoom as varchar), '?') + ' ''' + isnull(@sRoom, '?') + ''' #' + isnull(@sDial, '?') +
					', uP=' + isnull(cast(@idUnitP as varchar), '?') + ', uA=' + isnull(cast(@idUnitA as varchar), '?') +
					', b=' + isnull(cast(@siBeds as varchar), '?') + ' )'

	begin	tran

	---	delete	from	tbRoomBed					-- NO: removes patient-to-bed assignments!!
	---		where	idRoom = @idRoom

		if	exists	(select 1 from tbRoom with (nolock) where idRoom = @idRoom)
--	-		exec	dbo.prRoom_UpdStaff		@idRoom, @idUnitP, null, null, null			-- reset	v.7.03
			update	tbRoom	set	idUnit =	@idUnitP									--	7.06.7249
	/*						,	idUserG =	null,	sStaffG =	null
							,	idUserO =	null,	sStaffO =	null
							,	idUserY =	null,	sStaffY =	null
							,	tiCall =	0,		dtExpires=	null					--	7.06.7277:	why touch presence?!
	*/			where	idRoom = @idRoom
		else
			insert	tbRoom	( idRoom,  idUnit)		-- init staff placeholder for this room	v.7.02, v.7.03
					values	(@idRoom, @idUnitP)

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

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	75, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns devices/rooms/masters for given unit(s)
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
alter proc		dbo.prDevice_GetByUnit
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit's | '*'=all
,	@tiKind		tinyint				-- 0=any, 1=rooms, 2=masters
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
	declare		@i	smallint
		,		@s	varchar( 16 )

	set	nocount	on

	create table	#tbDevice
	(
		idDevice	smallint

		primary key nonclustered ( idDevice )
	)

	if	(@sUnits is not null	and	@sUnits <> '*')		-- specific unit(s)
	begin
		while	len( @sUnits ) > 0
		begin
			select	@i =	charindex( ',', @sUnits )

			if	@i = 0
				select	@s =	@sUnits
			else
				select	@s =	substring( @sUnits, 1, @i - 1 )

			select	@s =	'%' + @s + '%'
	---		print	@s

			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					left join	#tbDevice t	with (nolock)	on	t.idDevice = d.idDevice
					where	(@bActive is null	or	d.bActive = @bActive)
					and	(	@tiKind = 0														-- any
						or	@tiKind = 1		and	d.tiRID = 0		and	d.cDevice = 'R'
--							and	(d.tiStype between 4 and 7										-- 790 room controllers
--								or	d.tiStype = 0x7C	or	d.tiStype = 0x7E					-- 680 rooms
--								or	d.idDevice in (select idParent from tbDevice w with (nolock) where w.tiRID = 1 and w.tiStype = 26)))
						or	@tiKind = 2		and	d.tiRID = 0		and	d.cDevice in ('M','W')	)
--							and	(d.tiStype between 8 and 11										-- 790 masters
--								or	d.tiStype = 0x7D)))											-- 680 masters
					and		d.sUnits like @s
					and		t.idDevice is null

	---		select * from #tbDevice

			if	@i = 0
				break
			else
				select	@sUnits =	substring( @sUnits, @i + 1, len( @sUnits ) - @i )
		end
	end
	else		-- request for all units
	begin
			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					where	(@bActive is null	or	bActive = @bActive)
					and	(	@tiKind = 0														-- any
						or	@tiKind = 1		and	d.tiRID = 0		and	d.cDevice = 'R'
--							and	(d.tiStype between 4 and 7										-- 790 room controllers
--								or	d.tiStype = 0x7C	or	d.tiStype = 0x7E					-- 680 rooms
--								or	d.idDevice in (select idParent from tbDevice w with (nolock) where w.tiRID = 1 and w.tiStype = 26)))
						or	@tiKind = 2		and	d.tiRID = 0		and	d.cDevice in ('M','W')	)
--							and	(d.tiStype between 8 and 11										-- 790 masters
--								or	d.tiStype = 0x7D)))											-- 680 masters
	end

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint)	as	tiSwing,	d.sUnits				-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice						-- v.7.02
		order	by	d.sDevice,	d.bActive	desc,	d.dtCreated	desc
end
go
--	----------------------------------------------------------------------------
--	7.06.7289	* [48]
--if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 104)
begin
	begin tran
		update	dbo.tb_LogType set	tiLvl =	8	where	idLogType = 48
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7293	- [38,39],	* [38]->[31], [39]->[26]
--	7.06.7292	- [6,8],	* [26]->[6], [31]->[8], [11]<->[19]
if	exists	(select 1 from dbo.tb_Option where idOption = 38)
begin
	begin tran
		update	dbo.tb_Option	set	sOption =	'Session timeout, m'					where	idOption = 1
		update	dbo.tb_Option	set	sOption =	'Failed log-ins before lock-out'		where	idOption = 2
		update	dbo.tb_Option	set	sOption =	'(internal) Allowed Systems'			where	idOption = 6
		update	dbo.tb_Option	set	sOption =	'(internal) Call healing interval, s'	where	idOption = 8
		update	dbo.tb_Option	set	sOption =	'(internal) Nrm expiration window, s'	where	idOption = 9
		update	dbo.tb_Option	set	sOption =	'(internal) Ext expiration window, s'	where	idOption = 10
		update	dbo.tb_Option	set	sOption =	'(internal) Last processed idEvent'		where	idOption = 11
		update	dbo.tb_Option	set	sOption =	'SMTP TLS?'								where	idOption = 14
		update	dbo.tb_Option	set	sOption =	'Staff full name format'				where	idOption = 19
		update	dbo.tb_Option	set	sOption =	'Announce cancellations to'				where	idOption = 20
		update	dbo.tb_Option	set	sOption =	'(internal) Call answered Tout, s'		where	idOption = 21
		update	dbo.tb_Option	set	sOption =	'(internal) STAT need OT, s'			where	idOption = 22
		update	dbo.tb_Option	set	sOption =	'(internal) Green need OT, s'			where	idOption = 23
		update	dbo.tb_Option	set	sOption =	'(internal) Orange need OT, s'			where	idOption = 24
		update	dbo.tb_Option	set	sOption =	'(internal) Yellow need OT, s'			where	idOption = 25
		update	dbo.tb_Option	set	sOption =	'Sign-On reset interval, s'				where	idOption = 27
		update	dbo.tb_Option	set	sOption =	'Active Directory 790-group GUID'		where	idOption = 33
		update	dbo.tb_Option	set	sOption =	'Active Directory sync user'			where	idOption = 35
		update	dbo.tb_Option	set	sOption =	'Active Directory sync pass'			where	idOption = 36
		update	dbo.tb_Option	set	sOption =	'Active Directory 790-group name'		where	idOption = 37
		update	dbo.tb_Option	set	sOption =	'Data refresh interval, s'				where	idOption = 40

		declare		@s	varchar( 255 )
			,		@p	varchar( 255 )
			,		@d	smalldatetime
			,		@t	smalldatetime
			,		@i	int
			,		@j	int

		select	@s =	sValue,	@d =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 26
		update	dbo.tb_OptSys	set	sValue =	@s,	dtUpdated =		@d		where	idOption = 6

		select	@i =	iValue,	@d =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 31
		update	dbo.tb_OptSys	set	iValue =	@i,	dtUpdated =		@d		where	idOption = 8

		select	@i =	iValue,	@d =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 11
		select	@j =	iValue,	@t =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 19
		update	dbo.tb_OptSys	set	iValue =	@j,	dtUpdated =		@t		where	idOption = 11
		update	dbo.tb_OptSys	set	iValue =	@i,	dtUpdated =		@d		where	idOption = 19

--		update	dbo.tb_OptSys	set	sValue =	'',	sOption =	'reserved'	where	idOption = 26
--		update	dbo.tb_OptSys	set	iValue =	0,	sOption =	'reserved'	where	idOption = 31
		update	dbo.tb_Option	set	sOption =	'(internal) Aux data keep-window, d'	where	idOption = 7
		update	dbo.tb_Option	set	sOption =	'Default level for new staff'			where	idOption = 26
		update	dbo.tb_Option	set	sOption =	'Default shift start time'				where	idOption = 31

		select	@i =	iValue,	@d =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 39
		update	dbo.tb_OptSys	set	iValue =	@i,	dtUpdated =		@d		where	idOption = 26
		update	dbo.tb_Option	set	tiDatatype =	56		where	idOption = 26
		delete	from	dbo.tb_OptSys	where	idOption = 39
		delete	from	dbo.tb_Option	where	idOption = 39

		select	@t =	tValue,	@d =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 38
		update	dbo.tb_OptSys	set	tValue =	@t,	dtUpdated =		@d,	iValue =	null		where	idOption = 31
		update	dbo.tb_Option	set	tiDatatype =	61		where	idOption = 31
		delete	from	dbo.tb_OptSys	where	idOption = 38
		delete	from	dbo.tb_Option	where	idOption = 38

		select	@s =	sValue,	@d =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 33
		select	@p =	sValue,	@t =	dtUpdated	from	dbo.tb_OptSys	where	idOption = 37
		update	dbo.tb_OptSys	set	sValue =	@p,	dtUpdated =		@t		where	idOption = 33
		update	dbo.tb_OptSys	set	sValue =	@s,	dtUpdated =		@d		where	idOption = 37

		update	dbo.vw_OptSys	set	sValue =	null						where	tiDatatype = 56
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates full formatted name
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
alter proc		dbo.pr_User_sStaff_Upd
(
	@idUser		int			= null	-- null=any
)
	with encryption
as
begin
	declare	@tiFmt		tinyint	

	set	nocount	on

	select	@tiFmt =	cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 19

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
				end, '  ', ' ' ) ) ), 16 )
			where	idUser > 15			--	protect internal accounts
			and		(idUser = @idUser	or	@idUser is null)

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
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
		from	tb_OptSys	os	with (nolock)
		join	tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin
		begin	tran

			update	tb_OptSys	set	iValue =	@iValue,	fValue =	@fValue,	tValue =	@tValue,	sValue =	@sValue,	dtUpdated=	getdate( )
				where	idOption = @idOption	--	and	idUser = @idUser

			if	@idOption = 16	or	@idOption = 36
				select	@sValue= '************'								-- do not expose SMTP or AD pass

			select	@s =	'[' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s =	@s + ', i=' + isnull(cast(@iValue as varchar), '?') + ' (' + convert(varchar, convert(varbinary(4), @iValue), 1) + ')'
			else if	@k = 62		select	@s =	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s =	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s =	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	236, @idUser, null, @s

			if	@idOption = 19		exec	dbo.pr_User_sStaff_Upd			-- staff name format

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
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
	declare		@s			varchar( 255 )
		,		@dt			datetime
		,		@idEvent	int
		,		@iCount		int
		,		@tiPurge	tinyint			-- FF=keep everything
											-- N=remove auxiliary data older than N days (cascaded)
											-- 0=remove all inactive events from [tbEvent*] (cascaded)
	set	nocount	on

	select	@dt =	getdate( )												-- smalldatetime truncates seconds

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	ec	set	ec.idEvtVo =	null						-- implements CASCADE SET NULL
					from	tbEvent_C ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtVo
					where	a.idEvent is null

				update	ec	set	ec.idEvtSt =	null
					from	tbEvent_C ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtSt
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left join	tbEvent_A	a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@iCount =	@@rowcount

				if	0 < @iCount
				begin
					select	@s =	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) -' + cast(@iCount as varchar) +
									' in ' + convert(varchar, getdate() - @dt, 114)
					exec	dbo.pr_Log_Ins	1, null, null, @s				--	7.06.7276	trace is enough
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

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@idUnit		smallint
		,		@sUnits		varchar( 255 )
		,		@iAID0		int
	
	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 6

	select	@s =	'Dvc_IU( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					' [' + isnull(@cDevice,'?') + '] ''' + isnull(@sDevice,'?') + ''' #' + isnull(@sDial,'?') + ', v=' + isnull(@sCodeVer,'?') +
					', p0=' + isnull(cast(@tiPriCA0 as varchar),'?') + ', p1=' + isnull(cast(@tiPriCA1 as varchar),'?') + ' )'

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0

--	if	@iAID <> 0
--		select	@idDevice= idDevice		from	tbDevice		where	iAID = @iAID
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0		and	@iAID <> 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	---and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0		and	@tiRID >= 0
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

		if	@tiJID = 0														-- gateway		--	7.06.5414
		begin
--			select	@sUnits =	@sDial,		@sDial =	null				-- @sDial == IP for GWs		--	7.06.5855

			if	charindex(@cSys, @sSysts) = 0								-- is @cSys in Allowed-Systems?
				update	tb_OptSys	set	sValue =	sValue + @cSys
					where	idOption = 6
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

		if	@idDevice > 0													-- device found - update	--	7.06.5855
		begin
			update	tbDevice	set		bConfig =	1,	dtUpdated=	getdate( )	--, idEvent =	null
				,	idParent =	@idParent,	cSys =	@cSys,	tiGID=	@tiGID,	tiJID=	@tiJID,	tiRID=	@tiRID,	sDial=	@sDial
				,	tiStype =	@tiStype,	cDevice =	@cDevice,	sDevice =	@sDevice,	sCodeVer =	@sCodeVer,	sUnits =	@sUnits
				,	tiPriCA0 =	@tiPriCA0,	tiPriCA1 =	@tiPriCA1,	tiPriCA2 =	@tiPriCA2,	tiPriCA3 =	@tiPriCA3
				,	tiPriCA4 =	@tiPriCA4,	tiPriCA5 =	@tiPriCA5,	tiPriCA6 =	@tiPriCA6,	tiPriCA7 =	@tiPriCA7
				,	tiAltCA0 =	@tiAltCA0,	tiAltCA1 =	@tiAltCA1,	tiAltCA2 =	@tiAltCA2,	tiAltCA3 =	@tiAltCA3
				,	tiAltCA4 =	@tiAltCA4,	tiAltCA5 =	@tiAltCA5,	tiAltCA6 =	@tiAltCA6,	tiAltCA7 =	@tiAltCA7
				,	@s =	@s + '*',	@iAID0 =	isnull(iAID, 0)
				where	idDevice = @idDevice

			if	@iAID <> 0	and		@iAID <> @iAID0							--	7.06.6768
			begin
				select	@s =	@s + ' a:' + isnull(cast(convert(varchar, convert(varbinary(4), iAID), 1) as varchar),'?')
	--	-						+ '->' + cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar)		-- already logged
					from	tbDevice
					where	idDevice = @idDevice

				update	tbDevice	set		iAID= @iAID
					where	idDevice = @idDevice
			end

			if	@sCodeVer is not null
				update	tbDevice	set		sCodeVer= @sCodeVer
					where	idDevice = @idDevice
		end
		else																-- insert new device
		begin
			insert	tbDevice	( idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial,  sCodeVer,  sUnits	--,  idUnit
								,	tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
								,	tiAltCA0,  tiAltCA1,  tiAltCA2,  tiAltCA3,  tiAltCA4,  tiAltCA5,  tiAltCA6,  tiAltCA7 )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial, @sCodeVer, @sUnits	--, @idUnit
								,	@tiPriCA0, @tiPriCA1, @tiPriCA2, @tiPriCA3, @tiPriCA4, @tiPriCA5, @tiPriCA6, @tiPriCA7
								,	@tiAltCA0, @tiAltCA1, @tiAltCA2, @tiAltCA3, @tiAltCA4, @tiAltCA5, @tiAltCA6, @tiAltCA7 )
			select	@idDevice=	scope_identity( )
				,	@s =	@s + '+'

			if	@iAID <> 0													--	7.06.5855, 7.06.6768
				update	tbDevice	set		iAID= @iAID
					where	idDevice = @idDevice
		end

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
		begin
			select	@s =	@s + '=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit
		,		@sD			varchar( 16 )
		,		@iA			int

	set	nocount	on

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 6

	if	charindex('SIP:', @sDevice) = 1										-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ':' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '", #' + isnull(@sDial,'?') + ' )'

	-- match 7967-P workflow station's (0x1A) 'phantom' RIDs
	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow

		-- match active devices?
		select		@idDevice=	idDevice,	@bActive =	bActive									--	7.06.6758
				from	tbDevice	with (nolock)
				where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		-- match inactive devices?
		if	@idDevice is null
			select	@idDevice=	idDevice,	@bActive =	bActive
				from	tbDevice	with (nolock)
				where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice

/*			select	@sD =	sDevice,	@iA =	iAID											--	7.06.6758, .6773
				from	tbDevice
				where	idDevice = @idDevice

			if	@sD <> @sDevice
				select	@s =	@s + ' ^n:"' + @sD + '"'

			if	@iA <> @iAID
				select	@s =	@s + ' ^a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

			if	@sD <> @sDevice	or	@iA <> @iAID
				exec	dbo.pr_Log_Ins	82, null, null, @s
*/
			return	0												-- match found
		end
	end

	-- adjust AID
	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID is null		--	7.06.6768
		select	@iAID=	0


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


	if	@idDevice > 0																			--	7.06.5560
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		select	@sD =	sDevice,	@iA =	iAID												--	7.06.6758
			from	tbDevice
			where	idDevice = @idDevice

		if	@tiRID = 0	and	@sD <> @sDevice
			select	@s =	@s + ' ^N:"' + @sD + '"'

		if	@iA <> @iAID
			select	@s =	@s + ' ^A:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

		if	@tiRID = 0	and	@sD <> @sDevice		or	@iAID <> 0	and	@iA <> @iAID
			exec	dbo.pr_Log_Ins	82, null, null, @s

		return	0															-- match found
	end

	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	begin
		begin	tran

			if	charindex(@cSys, @sSysts) = 0								-- not in Allowed Systems
			begin
				select	@s =	@s + ' !cSys'
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

				if	@tiLog & 0x02 > 0										--	Config?
--				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
				begin
					select	@s =	@s + '=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
					exec	dbo.pr_Log_Ins	74, null, null, @s
				end
			end

		commit
	end
	else																	-- no name / system		7.06.5560
	begin
		select	@s =	@s + ' !sDvc'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	7981 - Returns rooms for updating RTLS state
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
--	select	idDevice	as	idRoom,	cSys, tiGID, tiJID, tiRID,	sQnDevice,	dtExpires,	tiCall,	idUserG, sStaffG, idUserO, sStaffO, idUserY, sStaffY
--		from	vwRoom	with (nolock)
	select	idDevice,	cSys, tiGID, tiJID, tiRID
		,	'[' + cDevice + '] ' + sDevice		as sQnDevice
		,	dtExpires,	tiCall,	idUser4, u4.sStaff, idUser2, u2.sStaff, idUser1, u1.sStaff
		from	tbDevice	d	with (nolock)
		join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
		left join	tb_User	u4	with (nolock)	on	u4.idUser = r.idUser4
		left join	tb_User	u2	with (nolock)	on	u2.idUser = r.idUser2
		left join	tb_User	u1	with (nolock)	on	u1.idUser = r.idUser1
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

	select	@iHealin =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 8

	set	nocount	off

	update	tbRoom	set	dtExpires=	case when	0 < idUser4  or	 0 < idUser2  or  0 < idUser1
											then	dateadd( ss, @iHealin, dtExpires )
										else	null	end
		where	dtExpires <= @dtNow
end
go
--	----------------------------------------------------------------------------
--	Returns badges (filtered)
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
)
	with encryption
as
begin
--	set	nocount	on
		select	idBadge,	idUser, sFqStaff
			,	idRoom,		sSGJ + ' [' + cDevice + '] ' + sDevice		as	sCurrLoc
			,	dtEntered	--,	cast( getdate( ) - dtEntered as time( 0 ) )	as	tDuration
			,	cast(datediff(ss, dtEntered, getdate())/86400 as varchar) + '.' + convert(char(8), getdate() - dtEntered, 114)	as	tDuration
			,	bActive, dtCreated, dtUpdated
			from	vwRtlsBadge		with (nolock)
			where	( @bActive is null	or	bActive = @bActive )
			and		( @bStaff is null	or	@bStaff = 0	and	idUser is null	or	@bStaff = 1	and	idUser is not null )
			and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
			order	by	idBadge
end
go
--	----------------------------------------------------------------------------
--	Resets location attributes for all badges
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
--	Recalculates locations levels upon import
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
		,		@tBeg		time( 0 )
		,		@sUnit		varchar( 16 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tBeg =		cast(tValue as time( 0 ))	from	dbo.tb_OptSys	with (nolock)	where	idOption = 31

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

/*		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
		begin
			select	@s =	'Loc_SL( ) ' + cast(@iCount as varchar) + ' rows'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
*/		select	@s =	'Loc_SL( ) *' + cast(@iCount as varchar)

		-- deactivate non-matching units
		update	u	set	u.bActive=	0,	u.dtUpdated =	getdate( )
			from	tbUnit	u
			left join 	tbCfgLoc	l	on l.idLoc = u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1	and	l.idLoc is null
/*		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
		begin
			select	@s =	'Loc_SL( ) -' + cast(@@rowcount as varchar) + ' unit(s)'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
*/		select	@s =	@s + ', -' + cast(@@rowcount as varchar)

		-- deactivate shifts for inactive units
		update	s	set	s.bActive=	0,	s.dtUpdated =	getdate( )
			from	tbShift	s
			join	tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0
/*		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
		begin
			select	@s =	'Loc_SL( ) -' + cast(@@rowcount as varchar) + ' shift(s)'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
*/		select	@s =	@s + ' u, -' + cast(@@rowcount as varchar) + ' s'

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	73, null, null, @s

		-- remove items for inactive units									--	7.06.5854
--		delete	from	tbUnitMapCell										-- cascade
--			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbUnitMap
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbDvcUnit
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbTeamUnit
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tb_UserUnit											--	7.06.6796
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tb_RoleUnit
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)

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
	--		if	exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
	--			update	tbUnit	set	bActive =	1,	sUnit=	@sUnit,		dtUpdated=	getdate( )
	--				where	idUnit = @idUnit
			update	tbUnit	set	sUnit=	@sUnit,		dtUpdated=	getdate( )
				where	idUnit = @idUnit
			if	@@rowcount > 0
			begin
				update	tbUnit	set	bActive =	1
					where	idUnit = @idUnit	and	bActive = 0
				if	@@rowcount > 0
				begin
					-- re-activate shifts for re-activated unit				--	7.06.6017
					update	tbShift		set	bActive =	1,	dtUpdated=	getdate( )
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
				insert	tbUnit	(  idUnit,  sUnit, tiShifts, idShift )
						values	( @idUnit, @sUnit, 1, 0 )
				insert	tb_RoleUnit	( idRole, idUnit )
						values		( 2, @idUnit )
				insert	tbShift	(  idUnit, tiIdx,  sShift, tBeg, tEnd )			--	default to single 24hr-shift
						values	( @idUnit, 1, 'Shift 1', @tBeg, @tBeg )			--	7.06.5934	'07:00:00'
				select	@idShift =	scope_identity( )

				update	tbUnit	set	idShift =	@idShift
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
				select	@tiMap =	0
				while	@tiMap < 4
				begin
					select	@tiCell =	0
					while	@tiCell < 48
					begin
						insert	tbUnitMapCell	( idUnit, tiMap, tiCell )	values	( @idUnit, @tiMap, @tiCell )

						select	@tiCell =	@tiCell + 1
					end
					select	@tiMap =	@tiMap + 1
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
--	7.06.7277	force clear all presence
exec	dbo.prRtlsBadge_RstLoc
go
--	----------------------------------------------------------------------------
--	7.06.7299	+ @idModule
--	7.06.7279	* optimized logging
--	Initializes or finalizes AD-Sync
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
			update	tb_User		set		bConfig =	0,	dtUpdated=	getdate( )
				where	gGUID is not null	and	bConfig > 0

			select	@s =	@s + '*' + cast(@@rowcount as varchar)
		end
		else																-- finish AD-Sync
		begin
--			update	tb_User		set		sDesc =		convert(varchar, getdate( ), 120) + ': "' + sUser + '" no longer in AD. ' + sDesc
--				where	gGUID is not null	and	bConfig = 0		and	bActive > 0

			update	tb_User		set		bActive =	0,	dtUpdated=	getdate( )
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
--		,		@bEdit		bit
		,		@utSynched	smalldatetime		-- (UTC) time of last AD-Sync

	set	nocount	on
	set	xact_abort	on

	if	@idUser = 4															-- System
		select	@idUser =	null

	select	@idOper =	idUser,		@utSynched =	utSynched
		from	tb_User with (nolock)
		where	gGUID = @gGUID

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '] ut=' + isnull(convert(varchar, @utSynched, 120), '?') +
				' ' + isnull(upper(cast(@gGUID as char(36))), '?') + ' [' + @sUser + '] f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", k=' + cast(@tiFails as varchar) + ', a=' + cast(@bActive as varchar) + ', ad=' + isnull(convert(varchar, @dtUpdated, 120), '?')
	begin	tran

		if	@idOper = 0		or	@idOper is null								-- user not found
		begin
			if	0 < @bActive												--	7.06.7094	only import *active* users!
			begin
				insert	tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
						values	( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
				select	@idOper =	scope_identity( )

				select	@s =	'Usr_ADI( ' + @s + ' )=' + cast(@idOper as varchar)
					,	@k =	102		--	237								--	7.06.7129
--					,	@k =	102,	@bEdit =	1		--	237			--	7.06.7129
			end
			else															--	7.06.7094
				select	@s =	'Usr_ADI( ' + @s + ' ) ^'					-- *inactive skipped*
					,	@k =	101		--	2								--	7.06.7129
--					,	@k =	101,	@bEdit =	1		--	2			--	7.06.7129
		end
		else
		if	@utSynched < @dtUpdated											-- AD had a recent change
		begin
			update	tb_User	set		sUser =		@sUser,		sFrst=	@sFrst,		sMidd=	@sMidd,		sLast=	@sLast
								,	sEmail =	@sEmail,	sDesc=	@sDesc,		utSynched=	getutcdate( )
								,	tiFails =	case when	@tiFails = 0xFF	then	@tiFails
													when	tiFails = 0xFF	then	0
													else	tiFails		end
								,	bOnDuty =	case when	@bActive = 0	then	0		else	bOnDuty	end
								,	dtDue =		case when	@bActive = 0	then	null	else	dtDue	end
								,	bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'Usr_ADU( ' + @s + ' ) *'
				,	@k =	103		--	238									--	7.06.7129
--				,	@k =	103,	@bEdit =	1		--	238				--	7.06.7129
		end
		else																-- user already up-to date
		begin
			if	0 < @bActive												-- if user is active
				update	tb_User	set		sUser =		@sUser,		sDesc=	@sDesc,		utSynched=	getutcdate( )
					where	idUser = @idOper	--	and	sUser <> @sUser		-- restore his login (.sUser) and update .utSynched

			update	tb_User	set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
								,	bOnDuty =	case when	@bActive = 0	then	0		else	bOnDuty	end
								,	dtDue =		case when	@bActive = 0	then	null	else	dtDue	end
				where	idUser = @idOper									-- update .bActive and mark user 'processed'

			select	@s =	'Usr_AD( ' + @s + ' )'
				,	@k =	104		--	238									--	7.06.7129,	7.06.7251

		end
		exec	dbo.pr_User_sStaff_Upd	@idOper
--		if	0 < @bEdit														--	7.06.7249
		if	@k < 104														--	7.06.7251	!! do not flood audit with 'skips' !!
			exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s, @idModule

		if	101 < @k														--	7.06.7094/79129	only import *active* users!
			-- enforce membership in 'Public' role
			if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
				insert	tb_UserRole	( idRole, idUser )
						values		( 1, @idOper )

	commit

	return	@k
end
go
--	----------------------------------------------------------------------------
--	7.06.7300	update .idModule to J7980cs
begin
	begin tran
		update	dbo.tb_Log	set	idModule =	62	where	idLogType between 100 and 104	and	idModule = 1
	commit
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
--	7.06.7300	* Duration	(cause datediff(dd, ) swallows days)
--	7.06.7142	* optimized logging (+ [DT-dtCreated])
--	7.06.7115	* optimized logging (+ dtCreated)
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
		,		@dtCreated	datetime

	set	nocount	on

	select	@idUser =	idUser,		@sIpAddr =	sIpAddr,	@sMachine=	sMachine,	@idModule=	idModule,	@dtCreated =	dtCreated
		from	tb_Sess
		where	idSess = @idSess

	if	@idUser > 0
	begin
		begin	tran

			update	tb_Sess		set	dtLastAct=	getdate( ),	idUser =	null
				where	idSess = @idSess

			select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ') ' + isnull(convert(varchar, @dtCreated, 121), '?') +
							' [' + isnull(cast(datediff(ss, @dtCreated, getdate())/86400 as varchar), '?') + 'd ' + isnull(convert(varchar, getdate() - @dtCreated, 114), '?') + ']'
--							' [' + isnull(cast(datediff(dd, @dtCreated, getdate( )) as varchar), '?') + 'd ' + isnull(convert(varchar, getdate( )-@dtCreated, 114), '?') + ']'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s, @idModule

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	sd.idDevice, sd.sDevice, sd.sQnDevice, sd.tiStype, sd.sSGJR + ' /' + right('0' + cast(ea.tiBtn as varchar), 2)	as	sSGJRB
	,	rm.idUnit,	ea.idRoom, r.sDevice	as	sRoom,	r.sDial,	ea.tiBed, cb.cBed, cb.cDial
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
--	7.06.7310	+ [10,11], [22..24]
if	not exists	(select 1 from dbo.tbReport where idReport = 10)
begin
	begin tran
		update	dbo.tbReport	set	siOrder =	990		where	idReport = 2
		update	dbo.tbReport	set	siOrder =	220,	sReport =	'Clinic: Patient Wait Times',	sRptName =	'Clinic Patient Wait Times'		where	idReport = 22
		update	dbo.tbReport	set	siOrder =	230,	sReport =	'Clinic: Activity Summary',		sRptName =	'Summarized Clinic Activity'	where	idReport = 23
		update	dbo.tbReport	set	siOrder =	240,	sReport =	'Clinic: Activity (Detailed)',	sRptName =	'Detailed Clinic Activity'		where	idReport = 24

		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 10, 100,	1,	'xrRndStatSum',		'Rounding (Summary)',		'Summarized Rounding' )
		insert	dbo.tbReport ( idReport, siOrder, tiFlags, sClass, sReport, sRptName )
					values	( 11, 110,	1,	'xrRndStatDtl',		'Rounding (Detailed)',		'Detailed Rounding' )

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
end
go
--	----------------------------------------------------------------------------
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

	select	siIdx, lCount, sCall
		,	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
		,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	as	fStOnT
		from
			(select	sc.siIdx,	count(*) as	lCount
				,	min(sc.sCall)	as	sCall
				,	min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ep.tWaitS as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ep.tWaitS)	as	tStMax
				,	sum(case when ep.tWaitS < sc.tStTrg	then 1 else 0 end)	as	lStOnT
				,	sum(case when ep.tWaitS is null		then 1 else 0 end)	as	lStNul
				from	#tbRpt1		et	with (nolock)
				join	vwEvent_D	ep	with (nolock)	on	ep.idEvent = et.idEvent
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ep.idCall	and	sc.idSess = @idSess
				group	by	sc.siIdx)	t
		order	by	siIdx desc
end
go
grant	execute				on dbo.prRptRndStatSum				to [rWriter]
grant	execute				on dbo.prRptRndStatSum				to [rReader]
go
--	----------------------------------------------------------------------------
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

	select	e.idUnit, u.sUnit, e.idRoom, r.cDevice, r.sDevice
		,	e.dEvent, e.lCount
		,	e.siIdx, e.sCall
		,	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
		,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	as	fStOnT
		from
			(select	ep.idUnit, ep.idRoom
				,	ep.dEvent, sc.siIdx,	count(*) as	lCount
				,	min(sc.sCall)	as	sCall
				,	min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ep.tWaitS as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ep.tWaitS)	as	tStMax
				,	sum(case when ep.tWaitS < sc.tStTrg	then 1 else 0 end)	as	lStOnT
				,	sum(case when ep.tWaitS is null		then 1 else 0 end)	as	lStNul
				from	#tbRpt1		et	with (nolock)
				join	vwEvent_D	ep	with (nolock)	on	ep.idEvent = et.idEvent
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ep.idCall	and	sc.idSess = @idSess
				group	by	ep.idUnit, ep.idRoom, ep.dEvent, sc.siIdx)	e
		join	tbUnit		u	with (nolock)	on	u.idUnit = e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice = e.idRoom
		order	by	e.idUnit, e.idRoom, e.siIdx desc
end
go
grant	execute				on dbo.prRptRndStatDtl				to [rWriter]
grant	execute				on dbo.prRptRndStatDtl				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
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
,	@bEnabled	bit					-- 0=any, 1=only enabled for reporting
,	@bActive	bit			= 1		-- null=any, 0=inactive, 1=active
,	@tiLvl		tinyint		= null	-- null=any, 0=Regular, 1=Clinic, 2=Rnd/Rmd, 4=Rounding initial
)
	with encryption
as
begin
--	set	nocount	on
	if	@bVisible > 0
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, c.bActive, c.dtCreated, c.dtUpdated
			,	p.tiFlags, p.tiShelf, p.tiLvl, p.tiSpec, p.iColorF, p.iColorB
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx	--	p.sCall = c.sCall	and
			where	(@bActive is null	or	c.bActive = @bActive)
			and	(	@tiLvl is null
				or	@tiLvl = 0	and	p.tiLvl = 0	and	p.tiFlags & 0x08 = 0				--	Regular (non-Clinic, non-Rnd/Rmd)
				or	@tiLvl = 1	and	p.tiLvl > 0											--	Clinic
				or	@tiLvl = 2	and	p.tiFlags & 0x08 > 0								--	Rounding/Reminder
				or	@tiLvl = 4	and	p.siIdx in (51,54,57,60,63,66,69,72,75,78,81,84))	--	initial Rounding
		--	and		p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)		--	"medical" calls
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.idCall
	else
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, c.bActive, c.dtCreated, c.dtUpdated
			,	p.tiFlags, p.tiShelf, p.tiLvl, p.tiSpec, p.iColorF, p.iColorB
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx	--	p.sCall = c.sCall	and
			where	(@bActive is null	or	c.bActive = @bActive)
			and	(	@tiLvl is null
				or	@tiLvl = 0	and	p.tiLvl = 0	and	p.tiFlags & 0x08 = 0
				or	@tiLvl = 1	and	p.tiLvl > 0
				or	@tiLvl = 2	and	p.tiFlags & 0x08 > 0
				or	@tiLvl = 4	and	p.siIdx in (51,54,57,60,63,66,69,72,75,78,81,84))
			and		(@bEnabled = 0	or	c.bEnabled > 0)
			order	by	c.siIdx	desc,	c.idCall	desc					-- 7.06.7104
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
		,		@tiFlags	tinyint
		,		@tiShelf	tinyint
		,		@tiSpec		tinyint
		,		@tiSvc		tinyint
		,		@tiLvl		tinyint
		,		@bAudio		bit
		,		@bPresence	bit
		,		@bRounding	bit
		,		@iExpNrm	int
		,		@iExpExt	int
		,		@idUser		int
		,		@idEvDup	int

	set	nocount	on

--	select	@tiLog =	tiLvl	from	tb_Module	with (nolock)	where	idModule = 1
	select	@iExpNrm =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 9
	select	@iExpExt =	iValue	from	tb_OptSys	with (nolock)	where	idOption = 10

	select	@siIdxOld=	@siPriOld & 0x03FF,		@dtEvent =	getdate( ),		@p =	''
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bPresence =	0,	@bRounding =	0

	select	@s =	'E84_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


--	if	@tiLog & 0x04 > 0													--	Debug?
--		exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins00'

	if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + ' !U'						-- invalid unit


	if	@siIdxNew > 0														-- call placed/healed/escalated
	begin
		exec	dbo.prCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiFlags =	tiFlags,	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,		@siIdxUg =	siIdxUg
			from	tbCfgPri	with (nolock)
			where	siIdx = @siIdxNew

		if	@siIdxOld > 0	and	@siIdxOld <> @siIdxNew						-- call escalated
			exec	dbo.prCall_GetIns	@siIdxOld, null, @idCall0 out
	end
	else if	@siIdxOld > 0													-- call cancelled
	begin
		exec	dbo.prCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiFlags =	tiFlags,	@tiShelf =	tiShelf,	@tiLvl =	tiLvl,	@tiSpec =	tiSpec,		@siIdxUg =	siIdxUg
			from	tbCfgPri	with (nolock)
			where	siIdx = @siIdxOld
	end
	else
		select	@idCall= 0													-- INTERCOM call
	---	exec	dbo.prCall_GetIns	0, @sCall, @idCall out					-- no need to call

--	if	@tiLog & 0x04 > 0													--	Debug?
--		exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins01'


	if	@tiSpec between 7 and 9
		select	@bPresence =	1,		@tiBed =	0xFF					-- mark 'presence' calls and force room-level
	else
	if	@tiFlags & 0x08 > 0
		select	@bRounding =	1											-- mark 'rounding' calls

	if	@tiBed = 0xFF
		select	@siBed =	0xFFFF,		@tiBed =	null
	else
	if	@tiBed > 9
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + ' !B'
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
									case when	0 < @bPresence	then 210	else 191 end			--	7.06.6767
								when	@siIdxNew = 0		then			-- cancelled | presense-out
									case when	0 < @bPresence	then 211	else 193 end			--	7.06.6767
								else										-- escalated | healing
									case when	0 < @idCall0	then 192	else 194 end	end

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
								,	tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7
								,	siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
					values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew
								,	@tiTmrA,  @tiTmrG,  @tiTmrO,  @tiTmrY,    @idPatient, @idDoctor, @iFilter
								,	@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7
								,	@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3 )

			if	len(@p) > 0													-- invalid data detected (bed|unit)
			begin
				select	@s =	@s + ' id=' + isnull(cast(@idEvent as varchar),'?') + @p
				exec	dbo.pr_Log_Ins	82, null, null, @s
			end
		end

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins04'

		update	tbRoom	set	idUnit =	@idUnit,	dtUpdated=	@dtEvent	--	7.06.7265
			where	idRoom = @idRoom	and	idUnit <> @idUnit

		if	@bPresence > 0													--	7.06.7265
			exec	dbo.prRoom_UpdStaff		@idRoom, @siIdxNew, @sStaffG, @sStaffO, @sStaffY	--, @idUnit

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins05'


		if	@idOrigin is null												-- no active origin found	(=> call placed/discovered)
		begin
			update	tbEvent		set	idOrigin =	@idEvent
								,	tOrigin =	dateadd(ss, @siElapsed, '0:0:0')
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
										siPri,     siIdx,     idRoom,  tiBed,  idCall,  tiSvc,  dtExpires,							--,  tiLvl
										tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
						values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiBtn,
										@siPriNew, @siIdxNew, @idRoom, @tiBed, @idCall, @tiSvc, dateadd(ss, @iExpNrm, @dtEvent),	--, @tiLvl
										@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins07'

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

	--					if	@tiLog & 0x04 > 0								--	Debug?
	--						exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins08'

						if	@bRounding > 0
							insert	tbEvent_D	(  idEvent,  dEvent,    tEvent,    idCall,  idUnit,  idShift,  dShift,  idRoom,  tiBed,  siBed, tiHH )
									values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idUnit, @idShift, @dShift, @idRoom, @tiBed, @siBed, datepart(hh, @dtOrigin) )
						else
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

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins09'

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	siIdx=	@siIdxNew,	idCall =	@idCall		--	7.06.5855
				where	idEvent = @idOrigin								--	7.05.5065

--			if	@tiLog & 0x04 > 0											--	Debug?
--				exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins10'

			update	tbEvent_A	set	tiSvc=	@tiSvc							-- update state for all calls in this room
				where	idRoom = @idRoom								--	7.06.5534

			if	@tiLvl = 0	and	@bRounding > 0	and	@siIdxNew <> @siIdxOld	-- escalated to next stage
			begin
					update	tbEvent_D	set	idEvntS =	@idEvent,	tRoomS =	@dtEvent
						where	idEvent = @idOrigin		and	idEvntS is null
			end
			else

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
						where	idEvent = @idParent	--?	and	idEvntD is [not?] null
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

			if	@tiLvl = 0	--and	@bRounding > 0
			begin
				update	tbEvent_D	set	tWaitS =	@dtEvent - dEvent - tRoomS
								,		idEvntD =	@idEvent
					where	idEvent = @idOrigin	--	and	tRoomS is not null

				delete	tbEvent_D
					where	idEvent = @idOrigin	and	idEvntD = idEvntS		-- remove 0-length rounding
			end
			else

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
			order	by	siIdx desc, idEvent								-- oldest in recorded order
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
				order	by	siIdx desc, idEvent								-- oldest in recorded order - FASTER, more EFFICIENT
			---	order	by	siIdx desc, tElapsed desc						-- call may have started before it was recorded (no .tElapsed!)

			update	tbRoomBed	set	idEvent =	@idEvent,	tiSvc=	@tiSvc,		dtUpdated=	@dtEvent
				where	idRoom = @idRoom	and	tiBed = @tiBed

			fetch next from	cur	into	@tiBed
		end
		close	cur
		deallocate	cur

--		if	@tiLog & 0x04 > 0												--	Debug?
--			exec	dbo.pr_Log_Ins	0, null, null, 'E84_Ins20'

	commit

	select	@idEvent =	@idOrigin			--	7.05.5267	return idOrigin
end
go
--	----------------------------------------------------------------------------
--	7.06.7325	clear Duty-state for 'Other' staff
begin
	update	dbo.tb_User	set	bOnDuty =	0,	dtDue =	null
		where	idStfLvl is null
			or	bActive = 0
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	7.06.7334	* r.sQnDevice -> r.sDevice	(there should be only rooms on any map; 7986cw limits that)
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
		,	r.idDevice as idRoom,	r.sDevice as sRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
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
--	Updates room's staff
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

	select	@idUserG =	idUserG,	@sStaff4 =	sStaffG
		,	@idUserO =	idUserO,	@sStaff2 =	sStaffO
		,	@idUserY =	idUserY,	@sStaff1 =	sStaffY
		,	@sRoom =	sDevice,	@tiEdit =	0
		from	vwRoom	with (nolock)
		where	idDevice = @idRoom											-- get current

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
			select	@tiEdit |=	2,	@idUserG =	idUser	from	tb_User with (nolock)	where	sStaff = @sStaffG


	if	@sStaffO is null													-- Orange
	begin
		if	0 < @idUserO
			select	@tiEdit |=	4,	@idUserO =	null
	end
	else
	if	@sStaff2 is null	or	@sStaff2 <> @sStaffO
			select	@tiEdit |=	8,	@idUserO =	idUser	from	tb_User with (nolock)	where	sStaff = @sStaffO


	if	@sStaffY is null													-- Yellow
	begin
		if	0 < @idUserY
			select	@tiEdit |=	16,	@idUserY =	null
	end
	else
	if	@sStaff1 is null	or	@sStaff1 <> @sStaffY
			select	@tiEdit |=	32,	@idUserY =	idUser	from	tb_User with (nolock)	where	sStaff = @sStaffY


	if	0 < @tiEdit															-- change
	begin
		select	@tiLog =	tiLvl	from	tb_Module	with (nolock)	where	idModule = 1

		select	@dt =	getdate( )
			,	@s =	'Rm_US( ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(@sRoom,'?') +
						', ' + isnull(cast(@tiEdit as varchar),'?') +
						', G:' + isnull(cast(@idUserG as varchar),'?') + '|' + isnull(@sStaffG,'?') +
						', O:' + isnull(cast(@idUserO as varchar),'?') + '|' + isnull(@sStaffO,'?') +
						', Y:' + isnull(cast(@idUserY as varchar),'?') + '|' + isnull(@sStaffY,'?') + ' ) '

		begin	tran

			update	tbRoom	set	idUserG =	null,	sStaffG =	null,	dtUpdated=	@dt
				where	@sStaffG is not null	and	idRoom <> @idRoom	and	sStaffG = @sStaffG
			update	tbRoom	set	idUserO =	null,	sStaffO =	null,	dtUpdated=	@dt
				where	@sStaffO is not null	and	idRoom <> @idRoom	and	sStaffO = @sStaffO
			update	tbRoom	set	idUserY =	null,	sStaffY =	null,	dtUpdated=	@dt
				where	@sStaffY is not null	and	idRoom <> @idRoom	and	sStaffY = @sStaffY

			update	tbRoom	set	idUserG =	@idUserG,	sStaffG =	@sStaffG
							,	idUserO =	@idUserO,	sStaffO =	@sStaffO
							,	idUserY =	@idUserY,	sStaffY =	@sStaffY
							,	dtUpdated=	@dt
--							,	dtExpires=	case when	0 < @idUserG	or	0 < @idUserO	or	0 < @idUserY	then	@dt
--												else	null	end
				where	idRoom = @idRoom
--				and	(	0 < @siIdx	or	dtUpdated < dateadd(ss, -2, @dt)	)	-- skip after last update on exit

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
--	Updates location attributes for a given badge
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
,	@idReceiver		smallint			-- current receiver look-up FK
,	@dtReceiver		datetime			-- when registered by current rcvr
,	@bCall			bit					-- 
,	@idUser			int			out
,	@idStfLvl		tinyint		out		-- 4=RN, 2=CNA, 1=Aide, ..
,	@sStaff			varchar( 16 )	out
,	@dtEntered		datetime	out		-- when entered the room
,	@idRoom			smallint	out		-- current 790 device look-up FK
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
		,	@s =	'Bdg_UL( ' + isnull(cast(@idBadge as varchar),'?') +
					', ' + isnull(cast(@idReceiver as varchar),'?') + ', ''' + isnull(convert(char(19), @dtReceiver, 121),'?') +
					'''' + case when @bCall > 0 then ' +' else '' end + ' )'

	exec	dbo.prRtlsBadge_InsUpd	@idBadge								--	auto-insert new badges

	select	@idUser =	idUser,		@idStfLvl =		idStfLvl,	@sStaff =	sStaff
		,	@idFrom =	idRoom,		@dtEntered =	dtEntered,	@sStff =	sDevice
		from	vwRtlsBadge	with (nolock)
		where	idBadge = @idBadge											--	get assigned user's details and previous room

--	select	@idRoom =	idRoom,		@sRoom =	'[' + cDevice + '] ' + sDevice
	select	@idRoom =	idRoom,		@sRoom =	sDevice
		from	vwRtlsRcvr	with (nolock)
		where	idReceiver = @idReceiver									--	get entered room's details

--	select	@s =	@s + ' [' + isnull(cast(@idUser as varchar),'?') + '] ' + isnull(cast(@idStfLvl as varchar),'?') +' "' + isnull(cast(@sStaff as varchar),'?') +
--						'" [' + isnull(cast(@idRoom as varchar),'?') + '] "' + isnull(cast(@sRoom as varchar),'?') + '"'
--					+ ' <- [' + isnull(cast(@idFrom as varchar),'?') + '] "' + isnull(cast(@sStff as varchar),'?') + '"'
--	select	@s =	@s + ' ' + isnull(cast(@idStfLvl as varchar),'?') + '|' + isnull(cast(@idUser as varchar),'?') + ':' + isnull(cast(@sStaff as varchar),'?') +
	select	@s =	@s + '<br/> ' + case when @idStfLvl = 4 then 'G' when @idStfLvl = 2 then 'O' when @idStfLvl = 1 then 'Y' else '?' end +
						':' + isnull(cast(@idUser as varchar),'?') + '|' + isnull(cast(@sStaff as varchar),'?') +
						', ' + isnull(cast(@idFrom as varchar),'?') + '|' + isnull(cast(@sStff as varchar),'?') +
						' >> ' + isnull(cast(@idRoom as varchar),'?') + '|' + isnull(cast(@sRoom as varchar),'?')

---	if	@tiLog & 0x04 > 0													--	Debug?
---		exec	dbo.pr_Log_Ins	0, null, null, @s

	begin	tran

		update	tbRtlsBadge		set	dtUpdated=	@dt,	idReceiver =	@idReceiver,	dtReceiver =	@dtReceiver
			where	idBadge = @idBadge										--	set badge's new receiver
			and	(	0 < idReceiver	and	@idReceiver is null
				or	0 < @idReceiver	and	idReceiver is null
				or		idReceiver <> @idReceiver)							--	if different from previous

		if	0 < @bCall	and	0 < @idStfLvl
			update	tbRoom		set	dtUpdated=	@dt,	dtExpires=	@dt,	tiCall |=	@idStfLvl
				where	idRoom = @idRoom									--	raise badge-call state


		if	0 < @idFrom  and  @idRoom is null	or
			0 < @idRoom  and  @idFrom is null	or
				@idRoom <> @idFrom											--	badge moved to another room
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
--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserG =	@idStff,	sStaffG =	@sStff
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
								,	tiCall =	case when @idStff is null	then	tiCall & 0xFB	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			else
			if	@idStfLvl = 2
--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserO =	@idStff,	sStaffO =	@sStff
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
								,	tiCall =	case when @idStff is null	then	tiCall & 0xFD	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			else
		--	if	@idStfLvl = 1
--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserY =	@idStff,	sStaffY =	@sStff
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
--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserG =	null,		sStaffG =	null
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	null	--,		sStaffG =	null
					where	idUser4 = @idStff

--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt1,	idUserG =	@idStff,	sStaffG =	@sStff
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			end
			else
			if	@idStfLvl = 2
			begin
--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserO =	null,		sStaffO =	null
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	null	--,		sStaffO =	null
					where	idUser2 = @idStff

--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt1,	idUserO =	@idStff,	sStaffO =	@sStff
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			end
			else
		--	if	@idStfLvl = 1
			begin
--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUserY =	null,		sStaffY =	null
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	null	--,		sStaffY =	null
					where	idUser1 = @idStff

--				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt1,	idUserY =	@idStff,	sStaffY =	@sStff
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


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7367 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7367, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2020-03-03',	dtInstall=	getdate( )
		,	sVersion =	'*798?cs, *7981ls, *798?rh, *7981cw, *7980cw, *7985cw, *7986cw'
		where	siBuild = 7367

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7367'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, 7.06.7367 )'
commit
go

checkpoint
go

use [master]
go