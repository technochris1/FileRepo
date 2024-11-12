--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
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
--						* vwStaff:	* sFqStaff -> sQnStf	(prStaff_LstAct, prStaff_SetDuty, vwDvc, vwRtlsBadge, prRtlsBadge_GetAll)
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
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 8321 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.8321', 18, 0 )
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
--	----------------------------------------------------------------------------
--	7.06.8143	* [ 40 -> 36 ]
if	exists	(select	1 from dbo.tb_LogType with (nolock)		where idLogType=40)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiCat, sLogType )	values	( 36,	16,	2,	'Paused' )		--	7.06.8133

/*		if	exists		(select	1 from dbo.tb_Log with (nolock)		where idLogType=40)
			update	dbo.tb_Log		set	idLogType=	36	where	idLogType = 40

		if	exists		(select	1 from dbo.tbEvent with (nolock)	where idLogType=40)
			update	dbo.tbEvent		set	idLogType=	36	where	idLogType = 40
*/
		delete	from	dbo.tb_LogType					where	idLogType = 40
	---	update	dbo.tb_LogType	set	idLogType=	36		where	idLogType = 40
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8133	* [ 2, 33..40, 61..64 ]
--	7.06.8059	* [79].tiLvl:	16 -> 8,
--				* [79].sLogType
if	not exists	(select	1 from dbo.tb_LogType with (nolock)		where idLogType=79 and tiLvl=8)
begin
	begin tran
		update	dbo.tb_LogType	set	sLogType= 'Info'		where	idLogType = 2

		update	dbo.tb_LogType	set	sLogType= 'Stats'		where	idLogType = 33
		update	dbo.tb_LogType	set	sLogType= 'Active'		where	idLogType = 34
		update	dbo.tb_LogType	set	sLogType= 'Asleep'		where	idLogType = 35
		update	dbo.tb_LogType	set	sLogType= 'Started'		where	idLogType = 38
		update	dbo.tb_LogType	set	sLogType= 'Stopped'		where	idLogType = 39
	---	update	dbo.tb_LogType	set	sLogType= 'Paused'		where	idLogType = 40

		update	dbo.tb_LogType	set	sLogType= 'Installed'	where	idLogType = 61
		update	dbo.tb_LogType	set	sLogType= 'Removed'		where	idLogType = 62
		update	dbo.tb_LogType	set	sLogType= 'License'		where	idLogType = 63
		update	dbo.tb_LogType	set	sLogType= 'Updated'		where	idLogType = 64

		update	dbo.tb_LogType	set	sLogType= 'Config edit'				where	idLogType = 70
		update	dbo.tb_LogType	set	sLogType= 'Cfg: bed',	tiLvl= 4	where	idLogType = 71
		update	dbo.tb_LogType	set	sLogType= 'Cfg: call',	tiLvl= 4	where	idLogType = 72
		update	dbo.tb_LogType	set	sLogType= 'Cfg: loc'				where	idLogType = 73
		update	dbo.tb_LogType	set	sLogType= 'Cfg: stn',	tiLvl= 4	where	idLogType = 74
		update	dbo.tb_LogType	set	sLogType= 'Cfg: room'				where	idLogType = 75
		update	dbo.tb_LogType	set	sLogType= 'Cfg: btn',	tiLvl= 4	where	idLogType = 76

		update	dbo.tb_LogType	set	sLogType= 'Config data', tiLvl= 8	where	idLogType = 79

		update	dbo.tb_LogType	set	sLogType= 'Conn. lost'	where	idLogType = 81

		update	dbo.tb_LogType	set	sLogType= 'GW found'	where	idLogType = 189
		update	dbo.tb_LogType	set	sLogType= 'GW lost'		where	idLogType = 190

		update	dbo.tb_LogType	set	sLogType= 'ON duty'		where	idLogType = 218
		update	dbo.tb_LogType	set	sLogType= 'on break'	where	idLogType = 219
		update	dbo.tb_LogType	set	sLogType= 'off duty'	where	idLogType = 220

		update	dbo.tb_LogType	set	sLogType= 'Log-in'		where	idLogType = 221
		update	dbo.tb_LogType	set	sLogType= 'Log-out'		where	idLogType = 229

		update	dbo.tb_LogType	set	sLogType= 'User created'	where	idLogType = 237
		update	dbo.tb_LogType	set	sLogType= 'User updated'	where	idLogType = 238
		update	dbo.tb_LogType	set	sLogType= 'User unlocked'	where	idLogType = 239
		update	dbo.tb_LogType	set	sLogType= 'User enabled'	where	idLogType = 240
		update	dbo.tb_LogType	set	sLogType= 'User disabled'	where	idLogType = 241

		update	dbo.tb_LogType	set	sLogType= 'Role created'	where	idLogType = 242
		update	dbo.tb_LogType	set	sLogType= 'Role updated'	where	idLogType = 243
		update	dbo.tb_LogType	set	sLogType= 'Role members'	where	idLogType = 244
		update	dbo.tb_LogType	set	sLogType= 'Role enabled'	where	idLogType = 245
		update	dbo.tb_LogType	set	sLogType= 'Role disabled'	where	idLogType = 246

		update	dbo.tb_LogType	set	sLogType= 'Record created'	where	idLogType = 247
		update	dbo.tb_LogType	set	sLogType= 'Record updated'	where	idLogType = 248
		update	dbo.tb_LogType	set	sLogType= 'Record deleted'	where	idLogType = 249
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8143	+ [ 0 ]	J-000-000-00 '$|NURSE CALL'
if	not	exists	(select 1 from dbo.tbDevice where idDevice = 0)
begin
	begin tran
		declare		@idDevice	smallint

		select	@idDevice=	idDevice	from	dbo.tbDevice	where	sDevice = 'NURSE CALL'

		update	dbo.tbDevice	set	bActive =	0	where	idDevice = @idDevice

		set identity_insert	dbo.tbDevice	on

		insert	dbo.tbDevice ( idDevice, cSys, tiGID, tiJID, tiRID, cDevice, sDevice )	values	( 0, 'J', 0, 0, 0, '$', 'NURSE CALL' )		--	7.06.8143

		set identity_insert	dbo.tbDevice	off

		if	@idDevice > 0
		begin
			update	dbo.tbEvent		set	idSrcDvc =	0	where	idSrcDvc = @idDevice
			update	dbo.tbEvent		set	idDstDvc =	0	where	idDstDvc = @idDevice
	--		delete	from	dbo.tbDevice	where	idDevice = @idDevice
		end

		update	dbo.tbDevice	set	cDevice= 'A'			where	cDevice = 'P'		--	'Audio' for SIP-devices
	commit
end
else
	update	dbo.tbDevice	set	cDevice= '$', iAID=	null	where	idDevice = 0
go
--	----------------------------------------------------------------------------
--	Inserts a new log entry
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
	@idLogType	tinyint
,	@idUser		int						--	context user
,	@idOper		int						--	"operand" user - ignored now
,	@sLog		varchar( 512 )
,	@idModule	tinyint			=	1	--	default is J798?db
,	@idSrcDvc	int				=	0	--	source device
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
			,	@idEvent	int
			,	@idUnit		smallint
			,	@idRoom		smallint
	--		,	@idSrcDvc	smallint
			,	@idDstDvc	smallint
			,	@idCmd		tinyint
			,	@cSys		char( 1 )
			,	@tiGID		tinyint
			,	@tiJID		tinyint
			,	@tiRID		tinyint
			,	@sDevice	varchar( 16 )

	set	nocount	on

	select	@tiLvl =	tiLvl,		@tiCat =	tiCat,		@idCmd =	0,			@sDevice =	null,
			@cSys =		null,		@tiGID =	null,		@tiJID =	null,		@tiRID =	null,
			@dt =	getdate( ),		@hh =	datepart( hh, getdate( ) )
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

		if	@idLogType	between	4  and 40	or								-- wrn,err,crit + all service states
			@idLogType	between	61 and 64	or								-- install/removal
			@idLogType	in (70,79,80,81,83,90)	or							-- config, conn, schedules
			@idLogType	between	100 and 104	or								-- AD
			@idLogType	between	189 and 190	or								-- GW
			@idLogType	between	218 and 255									-- user: duty, log-in/out, activity
		begin
			if	0 < @idSrcDvc
--			if	@idLogType	between	189 and 190
			begin
				select	@idCmd =	0x83,	@sDevice =	sDevice,
						@cSys =		cSys,	@tiGID =	tiGID,	@tiJID =	tiJID,	@tiRID =	tiRID
					from	tbDevice
					where	idDevice = @idSrcDvc
			end

			exec	dbo.prEvent_Ins		@idCmd, null, @idLog, null		---	@idCmd, @tiLen, @iHash, @vbCmd
					,	@cSys, @tiGID, @tiJID, @tiRID, @sDevice			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
					,	null, null, null, null, null, @sLog				---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
					,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
					,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
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
,	@sMachine	varchar( 32 )
,	@sDesc		varchar( 64 )
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
			,	@idLogType	tinyint

	set	nocount	on

	select	@s =	'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '|' + isnull(@sModule, '?') + ', ' + isnull(@sVersion, '?')
--					', ip=' + isnull(@sIpAddr, '?') + ', m=' + isnull(@sMachine, '?') + ', ''' + isnull(@sDesc, '?') + ''', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'
		,	@idLogType =	62

	if	@sMachine is not null												-- register
		select	@s =	@s + ', ip=' + isnull(@sIpAddr, '?') + ', m=' + isnull(@sMachine, '?') + ', ''' + isnull(@sDesc, '?') + ''', l=' + isnull(cast(@bLicense as varchar), '?')
			,	@idLogType =	61

	select	@s =	@s + ' )'

	begin	tran

		if	exists	(select 1 from tb_Module with (nolock) where idModule = @idModule)
		begin
			if	@sMachine is null	--	and	@sIpAddr is null				-- un-register
--			begin
				update	tb_Module	set		sIpAddr =	null,		sMachine =	null,		sVersion =	null
										,	dtStart =	null,		sParams =	null
					where	idModule = @idModule

--				select	@s =	'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', ' + isnull(@sVersion, '?') + ' )'
--					,	@idLogType =	62
--			end
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
--	Updates a given module's state
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
,	@idLogType	tinyint				-- type look-up FK (marks significant events only)
,	@sParams	varchar( 255 )		-- startup arguments/parameters
,	@sIpAddr	varchar( 40 )
,	@sMachine	varchar( 32 )
)
	with encryption
as
begin
/*	declare		@idEvent	int
		,		@idUnit		smallint
		,		@idRoom		smallint
		,		@idSrcDvc	smallint
		,		@idDstDvc	smallint
*/
	set	nocount	on

	begin	tran

		if	@idLogType = 38		-- SvcStarted
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		iPID =	@iPID,	dtStart =	getdate( ),		sParams =	@sParams,	sIpAddr =	@sIpAddr,	sMachine =	@sMachine
				where	idModule = @idModule
		else
			update	dbo.tb_Module	set	dtLastAct=	getdate( ),		iPID =	null,	dtStart =	null,			sParams =	null
				where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sInfo, @idModule

/*		exec	dbo.prEvent_Ins		0, null, null, null		---	@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	null, null, null, null, null, @sInfo	---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0
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
		from	tb_Module
		where	idModule = @idModule

	select	@s =	'Mod_Lic( ' + right('00' + cast(@idModule as varchar), 3) + '|' + @s + ', l=' + isnull(cast(@bLicense as varchar), '?') + ' )'

	begin	tran

		update	tb_Module	set	bLicense =	@bLicense
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

		update	tb_Module		set	tiLvl=	@tiLvl,		@s =	sModule
			where	idModule = @idModule

		select	@s =	'Mod_SL( ' + right('00' + cast(@idModule as varchar), 3) + '|' + @s + ', l=' + isnull(cast(@tiLvl as varchar), '?') + ' )'

		exec	dbo.pr_Log_Ins	64, @idUser, null, @s, @idFeature

	commit
end
go
--	----------------------------------------------------------------------------
--	Marks a gateway as found or lost (and removes its active calls)
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
,	@sDevice	varchar( 16 )		-- room name
,	@idLogType	tinyint				-- 189=Found, 190=Lost
,	@idModule	tinyint				-- module id
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@idSrcDvc	smallint

	set	nocount	on

--	select	@s =	@cSys + '-' + right('00' + cast(@tiGID as varchar), 3) + ' [' + isnull(@sDevice,'?') + ']'
	select	@s =	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + ' [' + isnull(sDevice,'?') + ']',
			@idSrcDvc =		idDevice
		from	tbDevice	with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	--	and	bActive > 0

	begin	tran

		if	@idLogType = 189												-- found;  activate if inactive
			update	tbDevice	set	bActive= 1
				where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	bActive = 0
		else
	--	if	@idLogType = 190
		begin
			delete	from	tbEvent_A
				where	cSys = @cSys	and	tiGID = @tiGID

			select	@s =	@s + ', ' + cast(@@rowcount as varchar) + ' active call(s) cleared'
		end

--	--	exec	dbo.prDevice_GetIns		@cSys, @tiGID, 0, 0, 0, null, 'G', @sDevice, null, @idSrcDvc out

		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s, @idModule, @idSrcDvc

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8139	+ .cStfLvl, xuStfLvl
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStfLvl') and name = 'cStfLvl')
begin
	begin tran
		alter table	dbo.tbStfLvl	add
			cStfLvl		char( 1 )		null		-- type code
	commit
end
go
if	exists		(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStfLvl') and name = 'cStfLvl' and is_nullable=1)
begin
	begin tran
		update	dbo.tbStfLvl	set	cStfLvl =	'Y'		where	idStfLvl = 1
		update	dbo.tbStfLvl	set	cStfLvl =	'O'		where	idStfLvl = 2
		update	dbo.tbStfLvl	set	cStfLvl =	'G'		where	idStfLvl = 4
		update	dbo.tbStfLvl	set	cStfLvl =	'A'		where	idStfLvl = 8

		alter table	dbo.tbStfLvl	alter column
			cStfLvl		char( 1 )		not null
--				constraint	xuStfLvl	unique
		alter table	dbo.tbStfLvl	add
				constraint	xuStfLvl	unique	(cStfLvl)

		update	dbo.tb_OptSys	set	iValue =	0		where	idOption = 26		--	reset to '<None>'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns staff-levels
--	7.06.8139	+ .cStfLvl
--	7.06.5400
alter proc		dbo.prStfLvl_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idStfLvl, cStfLvl, sStfLvl, iColorB
		from	tbStfLvl	with (nolock)
end
go
--	----------------------------------------------------------------------------
--	Updates a staff level
--	7.06.8139	+ .cStfLvl
--	7.06.7279	* optimized logging
--	7.06.7115	* optimized logging (color in hex)
--	7.05.5219
alter proc		dbo.prStfLvl_Upd
(
	@idStfLvl	tinyint
,	@cStfLvl	char( 1 )
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
					isnull(convert(varchar, convert(varbinary(4), @iColorB), 1), '?') + ', ' + @cStfLvl + '|''' + @sStfLvl + ''' )'

	begin	tran

		update	tbStfLvl	set	cStfLvl =	@cStfLvl,	sStfLvl =	@sStfLvl,	iColorB =	@iColorB	--,	dtUpdated=	getdate( )
			where	idStfLvl = @idStfLvl

		exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Staff definitions
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
select	idUser, sStaffID, sFrst, sMidd, sLast, u.idStfLvl, l.cStfLvl, l.sStfLvl, sBarCode	--, l.iColorB
	,	sStaff,	isnull(sStaffID, '--') + ' | ' + sStaff	as	sQnStf
	,	bOnDuty, dtDue,	u.idRoom
	,	bActive, dtCreated, dtUpdated
	from	tb_User	u	with (nolock)
	join	tbStfLvl l	with (nolock)	on	l.idStfLvl = u.idStfLvl
go
--	----------------------------------------------------------------------------
--	Returns [active?] staff, ordered to be loadable into a table
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
	select	idUser, cast(1 as bit)	as	bEnabled, sStaffID, sStaff, idStfLvl, cStfLvl, sStfLvl	--, iColorB
		from	vwStaff	with (nolock)
		where	@bActive = 0	or	bActive > 0
		order	by	idStfLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	Sets user's Duty and Break states
--	7.06.8137	* sFqStaff -> sQnStf
--	7.06.6710	+ logging
--	7.05.5172	* fix @bOnDuty condition
--	7.05.5171
alter proc		dbo.prStaff_SetDuty
(
	@idUser		int
,	@bOnDuty	bit		--	=	null	--	0=OffDuty, 1=OnDuty, null=see @tiMins
,	@tiMins		tinyint					--	0=finish break, >0=break time, null=see @bOnDuty
)
	with encryption	--, exec as owner
as
begin
	declare		@s			varchar( 255 )
		,		@dtNow		smalldatetime
		,		@tNow		time( 0 )
		,		@idLogType	tinyint

	set	nocount	on
	set	xact_abort	on

	select	@dtNow =	getdate( )		-- smalldatetime truncates seconds
	select	@tNow =		@dtNow			-- time(0) truncates date, leaving HH:MM:00

	begin	tran

		if	@bOnDuty > 0
		begin
			if	exists	(select 1 from tb_User with (nolock) where idUser = @idUser and bOnDuty = 0)	-- and dtDue is not null
			begin
				-- set OnDuty staff, who finished break
				update	tb_User		set		bOnDuty =	1,	dtUpdated=	@dtNow,		dtDue=	null
					where	idUser = @idUser

				select	@s =	sQnStf
					from	vwStaff
					where	idUser = @idUser

				exec	dbo.pr_Log_Ins	218, @idUser, null, @s	--, @idModule

				-- init coverage
				exec	dbo.prStfCvrg_InsFin
			end
		end
		else	--	@bOnDuty = 0
		begin
			if	exists	(select 1 from tb_User with (nolock) where idUser = @idUser and (bOnDuty = 1 or dtDue is not null))
			begin
				-- set OffDuty and break finish due
				update	tb_User		set		bOnDuty =	0,	dtUpdated=	@dtNow
										,	dtDue=	case when @tiMins > 0 then dateadd( mi, @tiMins, @dtNow ) else null end
					where	idUser = @idUser

				-- reset coverage refs for interrupted assignments
				update	sa	set		idStfCvrg=	null,	dtUpdated=	@dtNow
					from	tbStfAssn	sa
					join	tbStfCvrg	sc	on	sc.idStfCvrg = sa.idStfCvrg	and	sc.dtEnd is null
					where	sa.idUser = @idUser

				-- finish coverage for interrupted assignments
				update	sc	set		dtEnd=	@dtNow,		dEnd =	@dtNow,		tEnd =	@tNow,	tiEnd=	datepart( hh, @tNow )
						--		,	dtDue= @dtNow		--	??	adjust to end moment
					from	tbStfCvrg	sc
					join	tbStfAssn	sa	on	sa.idStfAssn = sc.idStfAssn	and	sa.idUser = @idUser
					where	sc.dtEnd is null

				select	@s =	sQnStf +	case when @tiMins > 0 then ' for ' + cast(@tiMins as varchar) + ' min' else '' end
						,	@idLogType =	case when @tiMins > 0 then 219 else 220 end
					from	vwStaff
					where	idUser = @idUser

				exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s	--, @idModule
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
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
select	b.idBadge
	,	sd.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.sQnStf
	,	b.idReceiver, r.sReceiver, b.dtReceiver
	,	r.idRoom, d.cDevice, d.sDevice, d.sSGJ, b.dtEntered	--,	b.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		join	tbDvc		sd	with (nolock)	on	sd.idDvc = b.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idUser =	sd.idUser
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idReceiver
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = r.idRoom
go
--	----------------------------------------------------------------------------
--	7.06.8123	+ .cDvcType, xuDvcType
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDvcType') and name = 'cDvcType')
begin
	begin tran
		alter table	dbo.tbDvcType	add
			cDvcType	char( 1 )		null		-- type code
	commit
end
go
if	exists		(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDvcType') and name = 'cDvcType' and is_nullable=1)
begin
	begin tran
		update	dbo.tbDvcType	set	cDvcType =	'B'		where	idDvcType = 1
		update	dbo.tbDvcType	set	cDvcType =	'P'		where	idDvcType = 2
		update	dbo.tbDvcType	set	cDvcType =	'F'		where	idDvcType = 4
		update	dbo.tbDvcType	set	cDvcType =	'N'		where	idDvcType = 8

		alter table	dbo.tbDvcType	alter column
			cDvcType	char( 1 )		not null
		alter table	dbo.tbDvcType	add
				constraint	xuDvcType	unique	(cDvcType)
	commit
end
go
--	----------------------------------------------------------------------------
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
select	d.idDvc, d.idDvcType, t.cDvcType, t.sDvcType, d.sDial, d.sDvc, d.sBarCode, d.tiFlags, d.sBrowser
	,	t.cDvcType + ' ' + d.sDial		as	sQnDvc
	,	d.idUser, u.idStfLvl, u.sStfLvl, u.sStaffID, u.sStaff, u.sQnStf, u.bOnDuty, u.dtDue
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDvc		d	with (nolock)
	join	tbDvcType	t	with (nolock)	on	t.idDvcType = d.idDvcType
	left join	vwStaff	u	with (nolock)	on	u.idUser = d.idUser
go
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + registered staff
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
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, d.sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)		as sSGJ
--	,	cDevice + ' ' + sDevice				as sFqDvc
	,	'[' + cDevice + '] ' + sDevice		as sQnDvc
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
--	790 Devices
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
alter view		dbo.vwDevice
	with encryption
as
select	r.idUnit,	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, sUnits, r.siBeds, r.sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3) + '-' + right('0' + cast(tiRID as varchar), 2)	as sSGJR
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)												as sSGJ
--	,	cDevice + ' ' + sDevice				as sFqDvc
	,	'[' + cDevice + '] ' + sDevice		as sQnDvc
	,	r.idEvent,	r.tiSvc
	,	r.idUserG, r.sStaffG
	,	r.idUserO, r.sStaffO
	,	r.idUserY, r.sStaffY
	,	d.bActive, d.dtCreated, d.dtUpdated
	from	tbDevice	d	with (nolock)
	left join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice
go
--	----------------------------------------------------------------------------
--	Returns buttons [and corresponding devices], associated with presence (in a given room)
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
--	7.05.4990
alter proc		dbo.prCfgDvc_GetBtns
(
	@idRoom		smallint			-- device (PK)
)
	with encryption
as
begin
--	set	nocount	off
select	b.idDevice, d.sQnDvc, d.tiRID, b.tiBtn, p.tiSpec		--, d.tiGID, d.tiJID
	from	tbCfgDvcBtn	b	with (nolock)
	join	tbCfgPri	p	with (nolock)	on	p.siIdx		= b.siPri		and	p.tiSpec in (7,8,9)
	join	vwDevice	d	with (nolock)	on	d.idDevice	= b.idDevice	and	d.bActive > 0
	where	d.idParent = @idRoom
	order	by	2
end
go
--	----------------------------------------------------------------------------
--	System activity log
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
select	e.idEvent, e.idParent, tParent, idOrigin, tOrigin, dtEvent, dEvent, tEvent, tiHH
	,	idCmd, iHash, tiBtn,	e.idUnit,	e.idRoom, e.tiBed,	r.sDevice as sRoom, b.cBed
	,	case when e.tiBed is not null then r.sDevice + ' : ' + b.cBed	else r.sDevice end as sRoomBed
	,	e.idSrcDvc, sd.sSGJR as sSrcSGJR, sd.cDevice as cSrcDvc, sd.sDevice as sSrcDvc, sd.sQnDvc as sQnSrcDvc
	,	e.idDstDvc, dd.sSGJR as sDstSGJR, dd.cDevice as cDstDvc, dd.sDevice as sDstDvc, dd.sQnDvc as sQnDstDvc
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
--	Room-bed combinations
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
select	r.idUnit,	rb.idRoom, r.sDevice as sRoom, r.sQnDvc as sQnRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID,	rb.tiBed, cb.cBed
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
--	Returns devices filtered by unit, type and active status
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
,	@bActive	bit			= null	-- null=any, 0=no, 1=yes
,	@bGroup		bit			= null	-- null=any, 0=no, 1=yes
,	@bStaff		bit			= null	-- null=any, 0=no, 1=yes
,	@idStfLvl	tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
)
	with encryption
as
begin
--	set	nocount	on
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDvc
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge	= d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice	= rb.idRoom
		where	d.idDvcType & @idDvcType <> 0
		and		(@bActive is null	or	d.bActive = @bActive)
		and		(@bStaff is null	or	@bStaff = 0	and	d.idUser is null	or	@bStaff = 1	and	d.idUser is not null )
		and		(@idStfLvl is null	or	d.idStfLvl = @idStfLvl	or	@idStfLvl = 0	and	d.idStfLvl is null)
		and		(@bGroup is null	or	d.tiFlags & 0x01 = @bGroup)
		and		(@idUnit is null	or	d.idDvcType = 1		or	d.idDvcType = 8
									or	d.idDvc in (select idDvc from tbDvcUnit with (nolock) where idUnit = @idUnit))
		order	by	idDvcType, sDial
end
go
--	----------------------------------------------------------------------------
--	Returns an active device by the given bar-code
--	7.06.8139	* vwDevice:	 sQnDevice -> sQnDvc
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
		,	rb.idRoom, r.sQnDvc
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
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDvc
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
	select	d.idDvc, d.idDvcType, d.sDvc, d.sDial, d.tiFlags, d.sBarCode, d.sBrowser, d.bActive		--, d.sUnits, d.sTeams
		,	rb.idRoom, r.sQnDvc
		,	d.idUser, d.idStfLvl, d.sStaffID, d.sStaff, d.bOnDuty, d.dtDue
		from		vwDvc		d	with (nolock)
		left join	vwRtlsBadge	rb	with (nolock)	on	rb.idBadge = d.idDvc
		left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
		where	d.idDvc = @idDvc
		and		d.idDvcType = 0x08			--	Wi-Fi
end
go
--	----------------------------------------------------------------------------
--	Returns all staff assignments for given unit/shift
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
	select	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.sQnRoom
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
--	Receivers
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
	,	r.idRoom, d.cDevice, d.sDevice, d.sSGJ	--, d.sSGJR
	,	d.sSGJ + ' [' + d.cDevice + '] ' + d.sDevice	as sQnDvc
	,	r.bActive, r.dtCreated, r.dtUpdated
	from	tbRtlsRcvr r
--		inner join	tbRtlsRcvrType t	on	t.idRcvrType = r.idRcvrType
		left outer join	vwDevice d	on	d.idDevice = r.idRoom
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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

	select	@idDevice=	null

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1
	select	@sSysts =	sValue	from	dbo.tb_OptSys	with (nolock)	where	idOption = 6

	if	charindex('SIP:', @sDevice) = 1										-- SIP-phone
		select	@cDevice =	'A'												--	7.06.8167

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + isnull(right('00' + cast(@tiGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiRID as varchar), 2),'?') +
					', ' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + '|' + isnull(cast(@tiStype as varchar),'?') +
					' [' + isnull(@cDevice,'?') + '] ''' + isnull(@sDevice,'?') + ''' #' + isnull(@sDial,'?') + ' )'

	-- match 7967-P workflow station's (0x1A) 'phantom' RIDs
	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7.03
	begin
		select	@sDial =	null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype =	26			---	?? mark 'phantom' RID as workflow

		-- match active devices?
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)	--	7.06.6758
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID

		-- match inactive devices?
		if	@idDevice is null
			select	@idDevice=	idDevice,	@bActive =	bActive	from	tbDevice	with (nolock)
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
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.04.4969, .4972
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0		and	cDevice = 'M'

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


	-- match GW#_FAIL source?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7535
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	cDevice = 'G'
--			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0
--			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	tiRID = 0	and	cDevice = 'G'

	-- match APP_FAIL source?
	if	@idDevice is null	and	@tiGID = 0	and	@tiJID = 0	and	@tiRID = 0						--	7.06.7410
		select	@idDevice=	idDevice,	@bActive =	bActive,	@cDevice =	'$'	from	tbDevice	with (nolock)		--	7.06.8167
			where	bActive > 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID
--			where	bActive > 0		and	cSys = @cSys	and	tiGID = 0	and	tiJID = 0	and	tiRID = 0	--and	cDevice = '$'
--	-		where						cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	--and	cDevice = 'M'


	-- match inactive devices?
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	--and	@tiRID >= 0					--	7.06.5560
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0		and	cDevice = 'M'

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID <> 0		--	7.06.7837
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID

	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice=	idDevice,	@bActive =	bActive		from	tbDevice	with (nolock)
			where	bActive = 0		and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID


--	if	@idDevice > 0																			--	7.06.5560
	if	@idDevice is not null																	--	7.06.739?
	begin
		if	@bActive = 0
			update	tbDevice	set	bActive= 1
				where	idDevice = @idDevice

		select	@sD =	sDevice,	@iA =	iAID												--	7.06.6758
			from	tbDevice	with (nolock)
			where	idDevice = @idDevice

		if	@tiRID = 0	and	@sD <> @sDevice
			select	@s =	@s + ' !n:''' + @sD + ''''

		if	@iA <> @iAID
			select	@s =	@s + ' !a:' + cast(convert(varchar, convert(varbinary(4), @iA), 1) as varchar)

		if	@tiRID = 0	and	@sD <> @sDevice		or	@iAID <> 0	and	@iA <> @iAID
			exec	dbo.pr_Log_Ins	82, null, null, @s

		return	0															-- match found
	end

--	if	@idDevice is null	and	len(@sDevice) > 0	and	@cSys is not null						--	7.05.5186
	if	len(@sDevice) > 0	and	@cSys is not null												--	7.05.5186
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
		select	@s =	@s + ' !s'
		exec	dbo.pr_Log_Ins	82, null, null, @s
	end
end
go
--	----------------------------------------------------------------------------
--	Notification subtypes
--	7.06.8182	* added '* PCS: ', '> RPP: ', '* WiFi: ' prefixes
--if	exists	(select	1 from dbo.tbPcsType with (nolock)		where idPcsType=0x01)
begin
	begin tran
		update	dbo.tbPcsType	set	sPcsType= '> PCS: Ring'				where	idPcsType = 0x01
		update	dbo.tbPcsType	set	sPcsType= '> PCS: Stop ring'		where	idPcsType = 0x02
		update	dbo.tbPcsType	set	sPcsType= '< PCS: Success'			where	idPcsType = 0x03
		update	dbo.tbPcsType	set	sPcsType= '< PCS: in PBX session'	where	idPcsType = 0x04
		update	dbo.tbPcsType	set	sPcsType= '< PCS: in OAI session'	where	idPcsType = 0x05
		update	dbo.tbPcsType	set	sPcsType= '< PCS: Inactive'			where	idPcsType = 0x06
		update	dbo.tbPcsType	set	sPcsType= '< PCS: Terminated'		where	idPcsType = 0x07
		update	dbo.tbPcsType	set	sPcsType= '< PCS: No response'		where	idPcsType = 0x08
		update	dbo.tbPcsType	set	sPcsType= '> PCS: Alert'			where	idPcsType = 0x0A
		update	dbo.tbPcsType	set	sPcsType= '< PCS: Expired'			where	idPcsType = 0x0B
		update	dbo.tbPcsType	set	sPcsType= '< PCS: Duplicate'		where	idPcsType = 0x0C
		update	dbo.tbPcsType	set	sPcsType= '< PCS: Busy'				where	idPcsType = 0x0D
		update	dbo.tbPcsType	set	sPcsType= '< PCS: Abort'			where	idPcsType = 0x0E

		update	dbo.tbPcsType	set	sPcsType= '> RPP: Page sent'		where	idPcsType = 0x40

		update	dbo.tbPcsType	set	sPcsType= '> WiFi: Alert sent'		where	idPcsType = 0x80
		update	dbo.tbPcsType	set	sPcsType= '< WiFi: Rejected'		where	idPcsType = 0x81
		update	dbo.tbPcsType	set	sPcsType= '< WiFi: Accepted'		where	idPcsType = 0x82
		update	dbo.tbPcsType	set	sPcsType= '< WiFi: Upgraded'		where	idPcsType = 0x83
		update	dbo.tbPcsType	set	sPcsType= '< WiFi: UnRejected'		where	idPcsType = 0x84
		update	dbo.tbPcsType	set	sPcsType= '< WiFi: UnAccepted'		where	idPcsType = 0x85
	commit
end
go
--	----------------------------------------------------------------------------
--	<100,tbEvent>
--	7.06.8182	clean up messages
begin tran
	update	e	set	sInfo=	null
		from	dbo.tbEvent		e
		join	dbo.tbEvent41	e41	on	e41.idEvent = e.idEvent
		where	e41.idPcsType	between 0x02 and 0x0E	and	e41.idPcsType <> 0x0A		--	PSC only but not Ring|Alert
	--	where	e41.idPcsType	not in	(0x01, 0x0A, 0x40, 0x80,0x81,0x82,0x83,0x84,0x85)		--	Ring, Alert, RPP, WiFi
commit
go
--	----------------------------------------------------------------------------
--	<100,tbEvent>
--	7.06.8182	update symbols
begin tran
	update	e	set	sInfo=	replace( replace( replace( sInfo, '--', '~~' ), 'S-', 'S~' ), 'T-', 'T~' )
		from	dbo.tbEvent		e
		join	dbo.tbEvent41	e41	on	e41.idEvent = e.idEvent
		where	sInfo is not null
commit
go
--	----------------------------------------------------------------------------
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'tiColor')
begin
	begin tran
		alter table	dbo.tbCfgPri		add
			tiColor		tinyint			null	-- FG/BG color index

		alter table	dbo.tbCfgPri		drop column	iColorF
		alter table	dbo.tbCfgPri		drop column	iColorB
	commit
end
go
if	exists		(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'tiColor' and is_nullable=1)
begin
	begin tran
		update	dbo.tbCfgPri	set	tiColor= 0

		alter table	dbo.tbCfgPri		alter column
			tiColor		tinyint			not null
	commit
end
go
--				* .iFilter -> not null
if	exists		(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'iFilter' and is_nullable=1)
begin
	begin tran
		update	dbo.tbCfgPri	set	iFilter= 0
			where	iFilter is null

		alter table	dbo.tbCfgPri		alter column
			iFilter		int				not null
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
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
	select	siIdx, sCall, tiFlags, tiShelf, tiLvl, tiColor, tiSpec, iFilter		--, iColorF, iColorB
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
,	@tiFlags	tinyint				-- bit flags: 1=locking, 2=enabled
,	@tiShelf	tinyint				-- shelf: 0=nondisplay, 1=routine, 2=urgent, 3=emergency, 4=code
,	@tiLvl		tinyint				-- clinic level
,	@tiColor	tinyint				-- FG/BG color index
,	@iFilter	int					-- priority filter-mask
,	@tiSpec		tinyint				-- special priority
,	@siIdxUg	smallint			-- upgrade priority-index
,	@siIdxOt	smallint			-- overtime priority-index
,	@tiOtInt	tinyint				-- overtime interval, min
,	@tiDome		tinyint				-- light-show index
,	@tiTone		tinyint				-- tone index
,	@tiToneInt	tinyint				-- tone interval, min
)
	with encryption
as
begin
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )

	set	nocount	on

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@s =	'Pri_U( ' + isnull(cast(@siIdx as varchar),'?') + ', ' +
					isnull(convert(varchar, convert(varbinary(1), @tiFlags), 1),'?') + '|' +
					isnull(convert(varchar, convert(varbinary(1), @tiLvl), 1),'?') + ' ''' + isnull(@sCall,'?') + ''', k=' +
					isnull(cast(@tiColor as varchar),'?') + ', sh=' +
					isnull(cast(@tiShelf as varchar),'?') +	'|' + isnull(cast(@tiSpec as varchar),'?') + ', ug=' +
					isnull(cast(@siIdxUg as varchar),'?') + ', ot=' +
					isnull(cast(@siIdxOt as varchar),'?') +	'|' + isnull(cast(@tiOtInt as varchar),'?') + ', ' +
					isnull(convert(varchar, convert(varbinary(4), @iFilter), 1),'?') + ', ls=' +
					isnull(cast(@tiDome as varchar),'?') + ', t=' +
					isnull(cast(@tiTone as varchar),'?') +	'|' + isnull(cast(@tiToneInt as varchar),'?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgPri where siIdx = @siIdx)
			update	tbCfgPri	set			sCall =		@sCall,		tiFlags =	@tiFlags,	tiShelf =	@tiShelf
				,	tiLvl =		@tiLvl,		tiColor =	@tiColor,	tiSpec =	@tiSpec,	siIdxUg =	@siIdxUg
				,	siIdxOt =	@siIdxOt,	tiOtInt =	@tiOtInt,	tiDome =	@tiDome,	tiTone =	@tiTone
				,	tiToneInt=	@tiToneInt,	iFilter =	@iFilter
				where	siIdx = @siIdx
		else
			insert	tbCfgPri	(  siIdx,  sCall,  tiFlags,  tiShelf,  tiLvl,  tiColor,  tiSpec,  siIdxUg,  siIdxOt,  tiOtInt,  tiDome,  tiTone,  tiToneInt,  iFilter )
					values		( @siIdx, @sCall, @tiFlags, @tiShelf, @tiLvl, @tiColor, @tiSpec, @siIdxUg, @siIdxOt, @tiOtInt, @tiDome, @tiTone, @tiToneInt, @iFilter )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
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
,	@bEnabled	bit					-- 0=any, 1=only enabled for reporting
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@tiLvl		tinyint		= null	-- null=any, 0=Regular, 1=Reminder, 2=Rounding, 4=Initial, 80=Clinic-None, 90=Clinic-Patient, A0=Clinic-Staff, B0=Clinic-Doctor
)
	with encryption
as
begin
--	set	nocount	on
	if	@bVisible > 0
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, c.bActive, c.dtCreated, c.dtUpdated
			,	p.tiFlags, p.tiShelf, p.tiLvl, p.tiSpec, p.tiColor		--, p.iColorF, p.iColorB
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx	--	p.sCall = c.sCall	and
			where	(@bEnabled = 0		or	c.bEnabled > 0)
			and	(	@bActive is null	or	c.bActive = @bActive)
			and	(	@tiLvl is null
				or	@tiLvl = 0		and	p.tiLvl = 0							--	Regular
				or	@tiLvl > 0		and
					(@tiLvl & 4 = 0	and	p.tiLvl & @tiLvl > 0				--	Reminder/Rounding/Clinic
									or	p.tiLvl & @tiLvl = @tiLvl))			--	Initial
			order	by	c.idCall
	else
		select	c.idCall, c.siIdx, c.sCall, c.bEnabled, c.tVoTrg, c.tStTrg, c.bActive, c.dtCreated, c.dtUpdated
			,	p.tiFlags, p.tiShelf, p.tiLvl, p.tiSpec, p.tiColor		--, p.iColorF, p.iColorB
			from	tbCall		c	with (nolock)
			join	tbCfgPri	p	with (nolock)	on p.siIdx = c.siIdx	--	p.sCall = c.sCall	and
			where	(@bEnabled = 0		or	c.bEnabled > 0)
			and	(	@bActive is null	or	c.bActive = @bActive)
			and	(	@tiLvl is null
				or	@tiLvl = 0		and	p.tiLvl = 0
				or	@tiLvl > 0		and
					(@tiLvl & 4 = 0	and	p.tiLvl & @tiLvl > 0
									or	p.tiLvl & @tiLvl = @tiLvl))
			order	by	c.siIdx	desc,	c.idCall	desc					-- 7.06.7104
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
select	ea.idEvent, ea.dtEvent,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
	,	sd.idDevice, sd.sDevice, sd.sQnDvc, sd.tiStype, sd.sSGJR + ' #' + right('0' + cast(ea.tiBtn as varchar), 2)	as	sSGJRB
	,	rm.idUnit,	ea.idRoom, r.sQnDvc	as	sQnRoom,	r.sDial,	ea.tiBed, cb.cBed, cb.cDial
	,	r.sDevice + case when ea.tiBed is null or ea.tiBed = 0xFF then '' else ' : ' + cb.cBed end		as	sRoomBed
	,	ea.idCall, c.siIdx, c.sCall, cp.tiColor, cp.tiShelf, cp.tiLvl, cp.tiSpec, cp.iFilter, cp.tiDome, cd.tiPrism, cp.tiTone, cp.tiToneInt
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
	set	nocount off

	select	idEvent, dtEvent, idRoom, sRoomBed, siIdx, sCall, tiColor, tElapsed, iFilter, bAudio, bAnswered		--, iColorF, iColorB
		from	vwEvent_A	with (nolock)
		where	bActive > 0	and	tiShelf > 0	and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )			--	7.03
		order	by	bAnswered, siIdx desc, tElapsed desc		--	call may have been started before it was recorded (idEvent)
end
go
--	----------------------------------------------------------------------------
--	Returns notifiable active call properties
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
	select	idEvent, dtEvent, cSys, tiGID, tiJID, tiRID, tiBtn, idRoom, sQnRoom, sDial, tiBed, cBed, cDial, idUnit
		,	siIdx, sCall, tiColor, tiShelf, tiLvl, tiSpec, bActive, bAnswered, tElapsed, tiSvc
		,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	(tiSpec not in (7,8,9)	or	tiSpec is null)		--	and	tiShelf > 0		--	7.06.5388
		and		(idEvent = @idEvent		or	@idEvent is null)
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
		,	idDevice, idRoom, tiBed, sRoomBed	--, sDevice, sQnDevice, sRoom, cBed
		,	siIdx, sCall, tiColor, tiShelf
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
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idDevice, sDevice, sQnDvc, tiStype, sSGJRB
		,	idUnit,	idRoom, sQnRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, tiColor, tiShelf, tiLvl, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiToneInt
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0		and	idUnit = @idUnit	--	and	tiLvl & 0x80 = 0
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given room (identified by Sys-G-J)
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn,	idDevice, sDevice, sQnDvc, tiStype, sSGJRB
		,	idUnit,	idRoom, sQnRoom, sDial,	tiBed, cBed,	cDial,	sRoomBed
		,	idCall, siIdx, sCall, tiColor, tiShelf, tiLvl, tiSpec, iFilter, tiDome, tiPrism, tiTone, tiToneInt
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
	---	,	idPatient, sPatient, cGender, sInfo, sNote, idDoctor, sDoctor
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	( tiShelf > 0	or	@bPrsnc > 0	and	tiSpec between 7 and 9 )	--	and	tiLvl & 0x80 = 0
			and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	Returns call-routing data for given shift [and priority]
--	7.06.8189	+ .tiColor
--				- .iColorF, .iColorB
--	7.06.7587	+ .tResp4
--	7.04.4938
alter proc		dbo.prRouting_Get
(
	@idShift	smallint
,	@bEnabled	bit			=	0		-- 0=any, 1=enabled priorities only
,	@siIdx		smallint	=	null
)
	with encryption
as
begin
	select	@idShift	as	idShift,	z.siIdx, p.sCall, p.tiShelf, p.tiSpec, p.tiColor
		,	cast(case when p.tiFlags & 0x02 > 0 then 1 else 0 end as bit)	as	bEnabled
		,	coalesce( r.tiRouting, z.tiRouting )							as	tiRouting
		,	coalesce( r.bOverride, z.bOverride )							as	bOverride
		,	coalesce( r.tResp0, z.tResp0 )									as	tResp0
		,	coalesce( r.tResp1, z.tResp1 )									as	tResp1
		,	coalesce( r.tResp2, z.tResp2 )									as	tResp2
		,	coalesce( r.tResp3, z.tResp3 )									as	tResp3
		,	coalesce( r.tResp4, z.tResp4 )									as	tResp4
		,	coalesce( r.dtUpdated, z.dtUpdated )							as	dtUpdated
		,	cast( case when r.tiRouting is null then 0 else 1 end as bit )	as	bRoute
		,	cast( case when r.bOverride is null then 0 else 1 end as bit )	as	bOverr
		,	cast( case when r.tResp0 is null then 0 else 1 end as bit )		as	bResp0
		,	cast( case when r.tResp1 is null then 0 else 1 end as bit )		as	bResp1
		,	cast( case when r.tResp2 is null then 0 else 1 end as bit )		as	bResp2
		,	cast( case when r.tResp3 is null then 0 else 1 end as bit )		as	bResp3
		,	cast( case when r.tResp4 is null then 0 else 1 end as bit )		as	bResp4
		from	dbo.tbRouting	z	with (nolock)
		inner join	dbo.tbCfgPri	p	with (nolock)	on	p.siIdx = z.siIdx
				and	( @idShift = 0	and	@bEnabled = 0	or	p.tiFlags & 0x02 > 0 )
				and	( @siIdx is null	or	p.siIdx = @siidx )
		left outer join	dbo.tbRouting	r	with (nolock)	on	r.idShift = @idShift	and	z.siIdx = r.siIdx
		where	z.idShift = 0
		order	by	z.siIdx desc
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
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
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.tiColor
		,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
		,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
		,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
		,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
		,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
		,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
		,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
		,	mc.tiMap
		,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
		,	mc.tiCell, mc.sCell1, mc.sCell2,	r.siBeds, r.sBeds,	mc.tiRID1, mc.tiBtn1,	mc.tiRID2, mc.tiBtn2,	mc.tiRID4, mc.tiBtn4
		from	tbUnitMapCell	mc	with (nolock)
			join	tbUnit		u	with (nolock)	on	u.idUnit = mc.idUnit
			left join	vwRoom	r	with (nolock)	on	r.bActive > 0	and	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0
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

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	' STAT',	@sNull =	'',		@sSpc6 =	'      ',	@sGrTm =	'Group/Team',	@sSyst =	'** $YSTEM **'
	select	@sSvc4 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	' ' + sStfLvl	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	set	nocount	off

	if	@tiDvc = 0xFF
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
			,	e.idCmd,	e.tiBtn,	lt.tiLvl, e.idLogType		--,	e.idRoom, e.tiBed
			,	case	when e.idCmd = 0x83		then e.sInfo
						when c.tiSpec = 23		then @sSyst			else e.sRoomBed		end		as	sRoomBed
			,	e.idCall, c.siIdx, c.tiSpec, cp.tiColor,				e.tiFlags				as	tiSvc	--, cp.iColorB, cp.iColorF
			,	e.idSrcDvc,		e.idDstDvc, e.sDstSGJR,					e.sQnSrcDvc				as	sSrcDvc
			,	case	when e.idCmd in (0, 0x83)	then l.sModule	else e.sSrcSGJR		end		as	sSrcSGJR
	--		,	case	when e41.idEvent > 0	then nd.cDvcType	else e.cDstDvc		end		as	cDstDvc
			,	case	when e41.idEvent > 0	then nd.sQnDvc		else e.sQnDstDvc	end		as	sDstDvc
			,	case	when e41.idEvent > 0	then pt.sPcsType
						when e.idLogType > 0	then e.sLogType		else k.sCmd	end
				+	case	when e.idCmd = 0x95		then	-- ' ' +
						case	when e.tiFlags & 0x08 > 0	then @sSvc8	else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4	else @sNull	end
					+	case	when e.tiFlags & 0x02 > 0	then @sSvc2	else @sNull	end
					+	case	when e.tiFlags & 0x01 > 0	then @sSvc1	else @sNull	end	end
													else @sNull							end		as	sEvent
			,	case	when e.idCmd in (0, 0x83)	then null
						when c.tiSpec in (7, 8, 9)	then @sSpc6 + u1.sQnStf
						when c.tiSpec = 23			then null
													else e.sInfo						end		as	sInfo
			,	case	when e41.idEvent > 0	and	nd.tiFlags & 0x01 = 0 	then du.idStfLvl
																			else null	end		as	idStfLvl
			,	case	when e41.idEvent > 0	then
							case	when nd.tiFlags & 0x01 > 0	then @sGrTm	else du.sQnStf	end
						when e.idCmd > 0		then e.sCall		else l.sUser		end		as	sCall
			,	case	when c.tiSpec = 23	then e.sInfo	--	replace( e.sInfo, @sSpc6, @sNull )
											else replace( l.sLog, char(9), char(32) )	end	as	sLog
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd			= e.idCmd
			join		tb_LogType	lt	with (nolock)	on	lt.idLogType	= e.idLogType
	--	-	join		tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
	--		left join	tbCfgBed	b	with (nolock)	on	b.tiBed			= e.tiBed
			left join	vwCall		c	with (nolock)	on	c.idCall		= e.idCall
			left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent		= e.idEvent
			left join	vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent		= e.idEvent
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent		= e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType	= e41.idPcsType
			left join	vwStaff		du	with (nolock)	on	du.idUser		= e41.idUser
			left join	vwDvc		nd	with (nolock)	on	nd.idDvc		= e41.idDvc
			left join	vw_Log		l	with (nolock)	on	l.idLog			= e.iHash	and	e.idCmd in (0, 0x83)
			where	e.idEvent	between @iFrom	and @iUpto
			and		e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else if	@tiDvc = 1
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
			,	e.idCmd,	e.tiBtn,	lt.tiLvl, e.idLogType		--,	e.idRoom, e.tiBed
			,	case	when e.idCmd = 0x83		then e.sInfo
						when c.tiSpec = 23		then @sSyst			else e.sRoomBed		end		as	sRoomBed
			,	e.idCall, c.siIdx, c.tiSpec, cp.tiColor,				e.tiFlags				as	tiSvc	--, cp.iColorB, cp.iColorF
			,	e.idSrcDvc,		e.idDstDvc, e.sDstSGJR,					e.sQnSrcDvc				as	sSrcDvc
			,	case	when e.idCmd in (0, 0x83)	then l.sModule	else e.sSrcSGJR		end		as	sSrcSGJR
	--		,	case	when e41.idEvent > 0	then nd.cDvcType	else e.cDstDvc		end		as	cDstDvc
			,	case	when e41.idEvent > 0	then nd.sQnDvc		else e.sQnDstDvc	end		as	sDstDvc
			,	case	when e41.idEvent > 0	then pt.sPcsType
						when e.idLogType > 0	then e.sLogType		else k.sCmd	end
				+	case	when e.idCmd = 0x95		then	-- ' ' +
						case	when e.tiFlags & 0x08 > 0	then @sSvc8	else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4	else @sNull	end
					+	case	when e.tiFlags & 0x02 > 0	then @sSvc2	else @sNull	end
					+	case	when e.tiFlags & 0x01 > 0	then @sSvc1	else @sNull	end	end
													else @sNull							end		as	sEvent
			,	case	when e.idCmd in (0, 0x83)	then null
						when c.tiSpec in (7, 8, 9)	then @sSpc6 + u1.sQnStf
						when c.tiSpec = 23			then null
													else e.sInfo						end		as	sInfo
			,	case	when e41.idEvent > 0	and	nd.tiFlags & 0x01 = 0 	then du.idStfLvl
																			else null	end		as	idStfLvl
			,	case	when e41.idEvent > 0	then
							case	when nd.tiFlags & 0x01 > 0	then @sGrTm	else du.sQnStf	end
						when e.idCmd > 0		then e.sCall		else l.sUser		end		as	sCall
			,	case	when c.tiSpec = 23	then e.sInfo	--	replace( e.sInfo, @sSpc6, @sNull )
											else replace( l.sLog, char(9), char(32) )	end	as	sLog
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd			= e.idCmd
			join		tb_LogType	lt	with (nolock)	on	lt.idLogType	= e.idLogType
			join		tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed			= e.tiBed
			left join	vwCall		c	with (nolock)	on	c.idCall		= e.idCall
			left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent		= e.idEvent
			left join	vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent		= e.idEvent
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent		= e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType	= e41.idPcsType
			left join	vwStaff		du	with (nolock)	on	du.idUser		= e41.idUser
			left join	vwDvc		nd	with (nolock)	on	nd.idDvc		= e41.idDvc
			left join	vw_Log		l	with (nolock)	on	l.idLog			= e.iHash	and	e.idCmd in (0, 0x83)
			where	e.idEvent	between @iFrom	and @iUpto
			and		e.tiHH		between @tFrom	and @tUpto
			order	by	e.idEvent
	else
		select	e.idEvent, e.idParent, e.tParent, e.idOrigin, e.tOrigin, e.dtEvent, e.dEvent, e.tEvent	--, e.tiHH
			,	e.idCmd,	e.tiBtn,	lt.tiLvl, e.idLogType		--,	e.idRoom, e.tiBed
			,	case	when e.idCmd = 0x83		then e.sInfo
						when c.tiSpec = 23		then @sSyst			else e.sRoomBed		end		as	sRoomBed
			,	e.idCall, c.siIdx, c.tiSpec, cp.tiColor,				e.tiFlags				as	tiSvc	--, cp.iColorB, cp.iColorF
			,	e.idSrcDvc,		e.idDstDvc, e.sDstSGJR,					e.sQnSrcDvc				as	sSrcDvc
			,	case	when e.idCmd in (0, 0x83)	then l.sModule	else e.sSrcSGJR		end		as	sSrcSGJR
	--		,	case	when e41.idEvent > 0	then nd.cDvcType	else e.cDstDvc		end		as	cDstDvc
			,	case	when e41.idEvent > 0	then nd.sQnDvc		else e.sQnDstDvc	end		as	sDstDvc
			,	case	when e41.idEvent > 0	then pt.sPcsType
						when e.idLogType > 0	then e.sLogType		else k.sCmd	end
				+	case	when e.idCmd = 0x95		then	-- ' ' +
						case	when e.tiFlags & 0x08 > 0	then @sSvc8	else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4	else @sNull	end
					+	case	when e.tiFlags & 0x02 > 0	then @sSvc2	else @sNull	end
					+	case	when e.tiFlags & 0x01 > 0	then @sSvc1	else @sNull	end	end
													else @sNull							end		as	sEvent
			,	case	when e.idCmd in (0, 0x83)	then null
						when c.tiSpec in (7, 8, 9)	then @sSpc6 + u1.sQnStf
						when c.tiSpec = 23			then null
													else e.sInfo						end		as	sInfo
			,	case	when e41.idEvent > 0	and	nd.tiFlags & 0x01 = 0 	then du.idStfLvl
																			else null	end		as	idStfLvl
			,	case	when e41.idEvent > 0	then
							case	when nd.tiFlags & 0x01 > 0	then @sGrTm	else du.sQnStf	end
						when e.idCmd > 0		then e.sCall		else l.sUser		end		as	sCall
			,	case	when c.tiSpec = 23	then e.sInfo	--	replace( e.sInfo, @sSpc6, @sNull )
											else replace( l.sLog, char(9), char(32) )	end	as	sLog
			from		vwEvent		e	with (nolock)
			join		tbDefCmd	k	with (nolock)	on	k.idCmd			= e.idCmd
			join		tb_LogType	lt	with (nolock)	on	lt.idLogType	= e.idLogType
			join		tb_SessDvc	d	with (nolock)	on	d.idDevice		= e.idSrcDvc
			left join	tbCfgBed	b	with (nolock)	on	b.tiBed			= e.tiBed
			left join	vwCall		c	with (nolock)	on	c.idCall		= e.idCall
			left join	tbCfgPri	cp	with (nolock)	on	cp.siIdx		= c.siIdx
			left join	tbEvent_C	ec	with (nolock)	on	ec.idEvent		= e.idEvent
			left join	vwStaff		u1	with (nolock)	on	u1.idUser		= ec.idUser1
			left join	tbEvent84	e84	with (nolock)	on	e84.idEvent		= e.idEvent
			left join	tbEvent41	e41	with (nolock)	on	e41.idEvent		= e.idEvent
			left join	tbPcsType	pt	with (nolock)	on	pt.idPcsType	= e41.idPcsType
			left join	vwStaff		du	with (nolock)	on	du.idUser		= e41.idUser
			left join	vwDvc		nd	with (nolock)	on	nd.idDvc		= e41.idDvc
			left join	vw_Log		l	with (nolock)	on	l.idLog			= e.iHash	and	e.idCmd in (0, 0x83)
			where	e.idEvent	between @iFrom	and @iUpto
			and		e.tiHH		between @tFrom	and @tUpto
	--	-	and		(e.idSrcDvc in (select idDevice from tb_SessDvc where idSess = @idSess)	or	e.idSrcDvc is null)		-- is left join not enough??
			order	by	e.idEvent
end
go
--	----------------------------------------------------------------------------
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

	select	@sSvc8 =	'STAT',		@sNull =	'',		@sSpc6 =	'      ',	@sGrTm =	'Group/Team'
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
		,	e.idLogType, cp.tiColor,	c.siIdx		--, e.idCall, cp.iColorB, cp.iColorF
		,	case	when e41.idEvent > 0	then pt.sPcsType	else lt.sLogType	end		as	sEvent
		,	case	when e41.idEvent > 0	then e41.idPcsType	else cp.tiSpec		end		as	tiSpec
		,	case	when e41.idEvent > 0	then du.idStfLvl	else e.tiFlags		end		as	tiSvc
		,	case	when e.idLogType between 195 and 199	then e.sQnDstDvc	--	 '[' + e.cDstDvc + '] ' + e.sDstDvc		-- audio
					when e.idCmd = 0x95		then
						case	when e.tiFlags & 0x08 > 0	then @sSvc8	else
						case	when e.tiFlags & 0x04 > 0	then @sSvc4	else @sNull	end
					+	case	when e.tiFlags & 0x02 > 0	then @sSvc2	else @sNull	end
					+	case	when e.tiFlags & 0x01 > 0	then @sSvc1	else @sNull	end	end
					when e41.idEvent > 0	then nd.sQnDvc							end		as	sDvcSvc	--	 nd.sFqDvc
		,	case	when e41.idEvent > 0	then
						case	when nd.tiFlags & 0x01 > 0	then @sGrTm	else du.sQnStf	end
					else c.sCall	end		as	sCall
		,	case	--when e41.idPcsType > 0x80	then pt.sPcsType
					when c.tiSpec in (7, 8, 9)	then u1.sQnStf	else e.sInfo	end		as	sInfo
	--	,	case	when c.tiSpec between 7 and 9	then @sSpc6 + u1.sFqStaff		else e.sInfo	end		as	sInfo
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

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	c.tVoTrg, c.tStTrg
				,	sh.sShift, ec.dShift, sh.tBeg, sh.tEnd
				,	cast(cast(cast(ec.dShift as datetime) + sh.tBeg as float) * 48 as int)	as	iShSeq
				,	case when cp.tiSpec between 7 and 9	then	0 else 1 end				as	iCall
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tVoice end		as	tVoice
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tStaff end		as	tStaff
				,	case when cp.tiSpec = 7				then	ec.tStaff else null end		as	tGrn
				,	case when cp.tiSpec = 8				then	ec.tStaff else null end		as	tOra
				,	case when cp.tiSpec = 9				then	ec.tStaff else null end		as	tYel
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				join	tbShift		sh	with (nolock)	on	sh.idShift = ec.idShift
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0
				order	by	ec.idUnit, ec.idRoom, ec.idEvent
		else
			select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	c.tVoTrg, c.tStTrg
				,	sh.sShift, ec.dShift, sh.tBeg, sh.tEnd
				,	cast(cast(cast(ec.dShift as datetime) + sh.tBeg as float) * 48 as int)	as	iShSeq
				,	case when cp.tiSpec between 7 and 9	then	0 else 1 end				as	iCall
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tVoice end		as	tVoice
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tStaff end		as	tStaff
				,	case when cp.tiSpec = 7				then	ec.tStaff else null end		as	tGrn
				,	case when cp.tiSpec = 8				then	ec.tStaff else null end		as	tOra
				,	case when cp.tiSpec = 9				then	ec.tStaff else null end		as	tYel
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessShift ss	with (nolock)	on	ss.idShift = ec.idShift	and	ss.idSess = @idSess
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				join	tbShift		sh	with (nolock)	on	sh.idShift = ec.idShift
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.dShift	between @dFrom	and @dUpto
				and		ec.siBed & @siBeds <> 0
				order	by	ec.idUnit, ec.idRoom, ec.idEvent
	else
		if	@tiShift = 0xFF
			select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	c.tVoTrg, c.tStTrg
				,	sh.sShift, ec.dShift, sh.tBeg, sh.tEnd
				,	cast(cast(cast(ec.dShift as datetime) + sh.tBeg as float) * 48 as int)	as	iShSeq
				,	case when cp.tiSpec between 7 and 9	then	0 else 1 end				as	iCall
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tVoice end		as	tVoice
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tStaff end		as	tStaff
				,	case when cp.tiSpec = 7				then	ec.tStaff else null end		as	tGrn
				,	case when cp.tiSpec = 8				then	ec.tStaff else null end		as	tOra
				,	case when cp.tiSpec = 9				then	ec.tStaff else null end		as	tYel
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				join	tbShift		sh	with (nolock)	on	sh.idShift = ec.idShift
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0
				order	by	ec.idUnit, ec.idRoom, ec.idEvent
		else
			select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	c.tVoTrg, c.tStTrg
				,	sh.sShift, ec.dShift, sh.tBeg, sh.tEnd
				,	cast(cast(cast(ec.dShift as datetime) + sh.tBeg as float) * 48 as int)	as	iShSeq
				,	case when cp.tiSpec between 7 and 9	then	0 else 1 end				as	iCall
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tVoice end		as	tVoice
				,	case when cp.tiSpec between 7 and 9	then	null else ec.tStaff end		as	tStaff
				,	case when cp.tiSpec = 7				then	ec.tStaff else null end		as	tGrn
				,	case when cp.tiSpec = 8				then	ec.tStaff else null end		as	tOra
				,	case when cp.tiSpec = 9				then	ec.tStaff else null end		as	tYel
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessShift ss	with (nolock)	on	ss.idShift = ec.idShift	and	ss.idSess = @idSess
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				join	tbShift		sh	with (nolock)	on	sh.idShift = ec.idShift
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.dShift	between @dFrom	and @dUpto
				and		ec.siBed & @siBeds <> 0
				order	by	ec.idUnit, ec.idRoom, ec.idEvent
end
go
--	----------------------------------------------------------------------------
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

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			select	ec.idEvent, ec.idRoom, ec.cDevice, ec.sRoomBed, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
				,	ec.idStLvl1, ec.sStaff1,	ec.idStLvl2, ec.sStaff2,	ec.idStLvl3, ec.sStaff3
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
			select	ec.idEvent, ec.idRoom, ec.cDevice, ec.sRoomBed, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
				,	ec.idStLvl1, ec.sStaff1,	ec.idStLvl2, ec.sStaff2,	ec.idStLvl3, ec.sStaff3
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.dShift	between @dFrom	and @dUpto
				and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
				and		ec.siBed & @siBeds <> 0
				order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
	else
		if	@tiShift = 0xFF
			select	ec.idEvent, ec.idRoom, ec.cDevice, ec.sRoomBed, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
				,	ec.idStLvl1, ec.sStaff1,	ec.idStLvl2, ec.sStaff2,	ec.idStLvl3, ec.sStaff3
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
		else
			select	ec.idEvent, ec.idRoom, ec.cDevice, ec.sRoomBed, ec.dEvent, ec.tEvent, ec.cBed
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec, cp.tiColor,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
				,	ec.idStLvl1, ec.sStaff1,	ec.idStLvl2, ec.sStaff2,	ec.idStLvl3, ec.sStaff3
				from	vwEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCall		c	with (nolock)	on	c.idCall = ec.idCall
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx		and	(cp.tiSpec is null	or	cp.tiSpec not between 7 and 9)
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.dShift	between @dFrom	and @dUpto
				and		(ec.tStaff > sc.tStTrg	or	ec.tVoice > sc.tVoTrg)
				and		ec.siBed & @siBeds <> 0
				order	by	cp.siIdx desc, ec.tStaff desc, ec.idEvent
end
go
--	----------------------------------------------------------------------------
--	7.06.8237	+ [38]
if	not	exists	(select 1 from dbo.tb_Option where idOption = 38)
begin
	begin tran
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 38, 167, 'Facility Time Zone' )						--	7.06.8237
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 38, 'Central Standard Time' )
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8270	+ [39]
if	not	exists	(select 1 from dbo.tb_Option where idOption = 39)
begin
	begin tran
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 39,  56, 'RTLS mode: auto-assign?' )					--	7.06.8270
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 39, 0 )
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
	select	tiDome,		tiPrism
		,	case when	tiPrism & 8 > 0	then	'T'	else '  '	end +
			case when	tiPrism & 4 > 0	then	'U'	else '  '	end +
			case when	tiPrism & 2 > 0	then	'L'	else '  '	end +
			case when	tiPrism & 1 > 0	then	'B'	else '  '	end	as	sPrism
		,	iLight0, iLight1, iLight2
		,	iPrism0, iPrism1, iPrism2, iPrism3, iPrism4, iPrism5,	cast(1 as bit)	as	bActive,	dtUpdated
		from	tbCfgDome	with (nolock)
		order	by	1
end
go
--	----------------------------------------------------------------------------
--	Returns receivers (filtered)
--	7.06.8276	* output order
--	7.06.8139	* vwRtlsRcvr:	 sQnDevice -> sQnDvc
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
		,	idReceiver, sReceiver,	idRoom, sQnDvc
		from	vwRtlsRcvr	with (nolock)
		where	( @bActive is null	or	bActive = @bActive )
		and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
		order	by	idReceiver
end
go
--	----------------------------------------------------------------------------
--	Returns badges (filtered)
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
)
	with encryption
as
begin
--	set	nocount	on
		select	bActive, dtCreated, dtUpdated
			,	idBadge
			,	sSGJ + ' [' + cDevice + '] ' + sDevice		as	sCurrLoc
			,	dtEntered	--,	cast( getdate( ) - dtEntered as time( 0 ) )	as	tDuration
			,	right('00' + cast(datediff(ss, dtEntered, getdate())/86400 as varchar), 3) + '.' + convert(char(8), getdate() - dtEntered, 114)	as	sElapsed
			,	idUser, sQnStf
			,	idRoom
			from	vwRtlsBadge		with (nolock)
			where	( @bActive is null	or	bActive = @bActive )
			and		( @bStaff is null	or	@bStaff = 0	and	idUser is null	or	@bStaff = 1	and	idUser is not null )
			and		( @bRoom is null	or	@bRoom = 0	and	idRoom is null	or	@bRoom = 1	and	idRoom is not null )
			order	by	idBadge
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge
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
	@idBadge		int					-- id
,	@idStfLvl		tinyint				-- 4=Grn, 2=Ora, 1=Yel, 0=None
)
	with encryption, exec as owner
as
begin
	declare		@idUser	int
		,		@sUser	varchar( 32 )
		,		@sRtls	varchar( 16 )

---	set	nocount	on
	begin	tran

		if	exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
		begin
			update	tbDvc		set	bActive =	1,	dtUpdated=	getdate( ),	sDial=	cast(@idBadge as varchar)
				where	idDvc = @idBadge	and	bActive = 0

			update	tbRtlsBadge	set	bActive =	1,	dtUpdated=	getdate( )
				where	idBadge = @idBadge	and	bActive = 0
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

		if	0 < @idStfLvl
		begin
			select	@sUser =	cast(@idBadge as varchar)					--	create a new [tb_User]
				,	@sRtls =	char(0x7F) + 'RTLS'							--	with 0x7F+'RTLS' as .sFrst

			if	not exists	(select 1 from tb_User with (nolock) where sUser = @sUser)
			begin
				exec	dbo.pr_User_InsUpd	2, @idUser out, @sUser, 0, 0, @sRtls, null, @sUser, null, null, @sUser, @idStfLvl, null, null, null, null, 0, 1
										--	iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc, sStfID, idLvl, sBarCode, sUnits, sTeams, sRoles, bOnDuty, bActive

				update	u	set	dtEntered=	getdate( ),	idRoom =	null	--	clear previously assigned user's location
					from	tb_User u
					join	tbDvc	d	on	d.idUser = u.idUser
					where	idDvc = @idBadge
/*				update	tb_User		set	dtEntered=	getdate( ),	idRoom =	null
					where	idUser	in
						(select	idUser
							from	tbDvc	with (nolock)
							where	idDvc = @idBadge)
*/
				update	tbDvc		set tiFlags =	1,	idUser =	@idUser	--	mark this badge un-assignable and assign it to newly created user
					where	idDvc = @idBadge
			end
			else
			begin
				update	tbDvc		set	tiFlags =	1
					where	idDvc = @idBadge
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.8321
delete	dbo.tb_UserUnit	where	idUser	in	(select idUser from dbo.tb_User where sFrst = char(0x7F) + 'RTLS')
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge
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
	@idBadge		int					-- 24 bits: 1..16777215 - RTLS badges
,	@idStfLvl		tinyint			out	-- 4=Grn, 2=Ora, 1=Yel, 0=None
,	@idReceiver		smallint			-- current receiver look-up FK
,	@dtReceiver		datetime			-- when registered by current rcvr
,	@bCall			bit					-- 
,	@idUser			int				out
,	@sStaff			varchar( 16 )	out
,	@dtEntered		datetime		out	-- when entered the room
,	@idRoom			smallint		out	-- current 790 device look-up FK
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
		,	@s =	'Bdg_UL( ' + isnull(cast(@idBadge as varchar),'?') + ', ' +
					isnull(cast(@idReceiver as varchar),'?') + ', ''' + isnull(convert(char(19), @dtReceiver, 121),'?') + '''' +
					case when @bCall > 0 then ' +' else '' end + ' )'

	exec	dbo.prRtlsBadge_InsUpd	@idBadge, @idStfLvl						--	auto-insert new badges		--	7.06.8276

	select	@idUser =	idUser,		@idStfLvl =		idStfLvl,	@sStaff =	sStaff
		,	@idFrom =	idRoom,		@dtEntered =	dtEntered,	@sStff =	sDevice
		from	vwRtlsBadge	with (nolock)
		where	idBadge = @idBadge											--	get assigned user's details and previous room

--	select	@idRoom =	idRoom,		@sRoom =	'[' + cDevice + '] ' + sDevice
	select	@idRoom =	idRoom,		@sRoom =	sDevice
		from	vwRtlsRcvr	with (nolock)
		where	idReceiver = @idReceiver									--	get entered room's details

	select	@s =	@s + '<br/> ' + case when @idStfLvl = 4 then 'G' when @idStfLvl = 2 then 'O' when @idStfLvl = 1 then 'Y' else '?' end + ':' +
						isnull(cast(@idUser as varchar),'?') + '|' + isnull(cast(@sStaff as varchar),'?') + ', ' +
						isnull(cast(@idFrom as varchar),'?') + '|' + isnull(cast(@sStff as varchar),'?') + ' >> ' +
						isnull(cast(@idRoom as varchar),'?') + '|' + isnull(cast(@sRoom as varchar),'?')

---	if	@tiLog & 0x04 > 0													--	Debug?
---		exec	dbo.pr_Log_Ins	0, null, null, @s

	begin	tran

		update	tbRtlsBadge		set	dtUpdated=	@dt,	idReceiver =	@idReceiver,	dtReceiver =	@dtReceiver
			where	idBadge = @idBadge										--	set badge's new receiver
			and	(		idReceiver <> @idReceiver							--	if different from previous
				or	0 < idReceiver	and	@idReceiver	is null
				or	0 < @idReceiver	and	idReceiver	is null)

		if	0 < @bCall	and	0 < @idStfLvl
			update	tbRoom		set	dtUpdated=	@dt,	dtExpires=	@dt,	tiCall |=	@idStfLvl
				where	idRoom = @idRoom									--	raise badge-call state


		if			@idRoom <> @idFrom										--	badge moved to another room
			or	0 < @idFrom  and  @idRoom	is null							--	or exited
			or	0 < @idRoom  and  @idFrom	is null							--	or entered
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
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
								,	tiCall =	case when @idStff is null	then	tiCall & 0xFB	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			else
			if	@idStfLvl = 2
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
								,	tiCall =	case when @idStff is null	then	tiCall & 0xFD	else	tiCall	end
					where	idRoom = @idFrom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			else
		--	if	@idStfLvl = 1
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
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	null	--,	sStaffG =	null
					where	idUser4 = @idStff

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser4 =	@idStff	--,	sStaffG =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser4 is null
						or	@idStff is null
						or	@idStff <> idUser4	)
			end
			else
			if	@idStfLvl = 2
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	null	--,	sStaffO =	null
					where	idUser2 = @idStff

				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser2 =	@idStff	--,	sStaffO =	@sStff
					where	idRoom = @idRoom
					and	(	@idStff is not null		and	idUser2 is null
						or	@idStff is null
						or	@idStff <> idUser2	)
			end
			else
		--	if	@idStfLvl = 1
			begin
				update	tbRoom	set	dtUpdated=	@dt,	dtExpires=	@dt,	idUser1 =	null	--,	sStaffY =	null
					where	idUser1 = @idStff

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
--	----------------------------------------------------------------------------
--	Returns assignable active staff for given unit(s)
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

/*	create table	#tbUser						-- no enforcement of FKs
	(
		idUser		int				not null	-- user look-up FK
	,	idStfLvl	tinyint			null
	,	sStaffID	varchar( 16 )	null
	,	sStaff		varchar( 16 )	not null
	,	bOnDuty		bit				not null
	,	dtDue		smalldatetime	null
	,	idRoom		smallint		null
	,	sQnRoom		varchar( 16 )	null
	,	sPager		varchar( 64 )	null
	,	sPhone		varchar( 64 )	null
	,	sWi_Fi		varchar( 64 )	null

		primary key nonclustered ( idUser )
	)

--	set	nocount	on
	insert	#tbUser
*/	select	st.idUser, st.idStfLvl, st.sStaffID, st.sStaff, st.bOnDuty, st.dtDue
		,	st.idRoom,	r.sQnDvc
	--	,	st.sStfLvl, st.iColorB, st.sFqStaff, st.sUnits, st.sTeams
	--	,	st.bActive, st.dtCreated, st.dtUpdated
	--	,	bd.idDvc as idBadge,	bd.sDial as sBadge						--	results in duplication of staff
	--	,	pg.idDvc as idPager,	pg.sDial as sPager						--	with multiple devices of the same type
	--	,	ph.idDvc as idPhone,	ph.sDial as sPhone
	--	,	wf.idDvc as idWi_Fi,	wf.sDial as sWi_Fi
		,	stuff((select ', ' + pg.sDial
						from	tbDvc	pg	with (nolock)	where	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
						for xml path ('')), 1, 2, '') as sPager
		,	stuff((select ', ' + ph.sDial
						from	tbDvc	ph	with (nolock)	where	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
						for xml path ('')), 1, 2, '') as sPhone
		,	stuff((select ', ' + wf.sDial
						from	tbDvc	wf	with (nolock)	where	wf.idUser = st.idUser	and	wf.idDvcType = 8	and	wf.bActive > 0
						for xml path ('')), 1, 2, '') as sWi_Fi
		from	vwStaff	st	with (nolock)
		left join	vwRoom	r	with (nolock)	on	r.idDevice = st.idRoom
	--	left join	tbDvc	bd	with (nolock)	on	bd.idUser = st.idUser	and	bd.idDvcType = 1	and	bd.bActive > 0
	--	left join	tbDvc	pg	with (nolock)	on	pg.idUser = st.idUser	and	pg.idDvcType = 2	and	pg.bActive > 0
	--	left join	tbDvc	ph	with (nolock)	on	ph.idUser = st.idUser	and	ph.idDvcType = 4	and	ph.bActive > 0
	--	left join	tbDvc	wf	with (nolock)	on	wf.idUser = st.idUser	and	wf.idDvcType = 8	and	wf.bActive > 0
		where	st.bActive > 0
		and		substring(st.sStaff, 1, 1) <> char(0x7F)
		and		(@idStfLvl is null	or	st.idStfLvl = @idStfLvl)
		and		(@bOnDuty is null	or	st.bOnDuty = @bOnDuty)
		and		st.idUser	in
			(select	idUser
				from	tb_UserUnit	uu	with (nolock)
				join	#tbUnit		u	with (nolock)	on	u.idUnit = uu.idUnit)
		order	by	st.idStfLvl desc, st.sStaff
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985
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
			,	ea.idRoom, ea.sQnRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.tiColor	--, ea.iColorF, ea.iColorB
			,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4
			,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
	--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
			from	vwEvent_A		ea	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = ea.idUnit
	--			left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	(ea.tiBed is null	and	(rb.tiBed = 0xFF	or	rb.tiBed = 1)) )	-- 7.06.5340
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	tiLvl & 0x80 = 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )
				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed desc		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	rb.cSys, rb.tiGID, rb.tiJID, rb.tiRID, ea.tiBtn
	--		,	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
	--		,	rb.idRoom, rb.sQnDevice	as	sRoom,	rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idRoom, rb.sQnRoom,	rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.tiColor	--, ea.iColorF, ea.iColorB
			,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as	tiMap
			,	p8.tiDome	as	tiDome8,	p4.tiDome	as	tiDome4
			,	p2.tiDome	as	tiDome2,	p1.tiDome	as	tiDome1
			from	vwRoomBed		rb	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
				outer apply	dbo.fnEventA_GetTopByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster, 0 )	ea
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 8 )	p8
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 4 )	p4
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 2 )	p2
				outer apply	dbo.fnEventA_GetDomeByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @idMaster, 1 )	p1
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sQnRoom,	ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiLvl, ea.tiSpec, ea.sCall, ea.tiColor	--, ea.iColorF, ea.iColorB
			,	ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	mc.tiMap
			,	cast(null as tinyint)	as	tiDome8,	cast(null as tinyint)	as	tiDome4
			,	cast(null as tinyint)	as	tiDome2,	cast(null as tinyint)	as	tiDome1
			from	#tbUnit			tu	with (nolock)
				outer apply	dbo.fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
				outer apply	dbo.fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
			order	by	tu.sUnit
end
go
--	----------------------------------------------------------------------------
--	Returns all staff (indicating inactive) for 7981cw
--	7.06.8313	* s.sStfLvl -> s.cStfLvl
--	7.06.8284	* '(inactive)' -> '†'
--				- .iColorB
--	7.06.8137	* sFqStaff -> sQnStf
--	7.05.5161	* active -> all, + '(inactive)' indication
--	7.05.5064	+ .idDvcType = 1
--	7.05.5010	* .idStaff -> .idUser
--	7.04.4953
alter proc		dbo.prStaff_LstAct
	with encryption
as
begin
	select	s.idUser, s.cStfLvl + ' ' + s.sQnStf +
				case	when bActive = 0	then ' †'	--	' -- (inactive)'
											else ''		end +
				case	when b.lCount > 1	then ' -- [' + cast(b.idDvc as varchar) + '], +' + cast(b.lCount-1 as varchar)
						when b.lCount = 1	then ' -- [' + cast(b.idDvc as varchar) + ']'
											else ''		end		as	sQnStf
	--	,	s.iColorB
		from	vwStaff	s	with (nolock)
		left outer join	(select	idUser, count(*) as lCount, min(idDvc) as idDvc
							from	tbDvc	with (nolock)
							where	idDvcType = 1							--	badge
							group by idUser)	b	on	b.idUser = s.idUser
		order	by	idStfLvl desc, sStaff
end
go
--	----------------------------------------------------------------------------
--	Returns all rooms (indicating inactive) for 7981cw
--	7.06.8284	* '(inactive)' -> '†'
--	7.06.8139	* sQnDevice -> sQnDvc
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
		,	sSGJ + ' ' + sQnDvc +
				case	when bActive = 0	then ' †'
											else ''		end		as	sQnRoom
		from	vwRoom	with (nolock)
		order	by	2
end
go
--	----------------------------------------------------------------------------
--	Updates full formatted name
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
alter proc		dbo.pr_User_sStaff_Upd
(
	@idUser		int			= null	-- null=any
)
	with encryption
as
begin
	declare		@tiFmt	tinyint	
		,		@sRtls	varchar( 16 )

	set	nocount	on

	select	@tiFmt =	cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 19
	select	@sRtls =	char(0x7F) + 'RTLS'									--	for auto-users

	set	nocount	off

	begin	tran

		update	tb_User		set	sStaff =
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
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
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
		,		@idStfAssn	int
		,		@idStfCvrg	int

	set	nocount	on
	set	xact_abort	on

---	print	cast(@dtNow, varchar) + ', ' + cast(@tNow, varchar)

	create	table	#tbDueAssn
	(
		idStfCvrg	int			not null	primary key clustered

	,	idStfAssn	int			not null
	)

	select	@dtNow =	getdate( )											-- smalldatetime truncates seconds
		,	@s =	'@' + @@servicename + ' ' + substring(recovery_model_desc, 1, 1) +
					',' + cast(log_reuse_wait as varchar)
		from master.sys.databases
		where	database_id = db_id( )

	select	@tNow =		@dtNow												-- time(0) truncates date, leaving HH:MM:00

	select	@s +=	' ' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 0

	select	@s +=	'/' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 1

	update	tb_Module	set	sParams =	@s		where	idModule = 1		-- outside the transaction in order not to block

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
				,	case when	sh.tEnd <= sh.tBeg	and	@tNow < sh.tEnd		then	dateadd( dd, -1, @dtNow )	else	@dtNow	end
				from	tbStfAssn	sa	with (nolock)
				join	tb_User		us	with (nolock)	on	us.idUser  = sa.idUser		and	us.bOnDuty > 0	-- only OnDuty
				join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift		and	sh.bActive > 0
				where	sa.bActive > 0
				and		sa.idStfCvrg is null						--	not running now
				and		(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStfAssn, @dtDue, @dShift
		while	@@fetch_status = 0
		begin
---			print	cast(@idStfAssn, varchar) + ': ' + cast(@dtDue, varchar)
		
			insert	tbStfCvrg	(  idStfAssn, dtBeg, dBeg, tBeg, tiBeg, dtDue, dShift )
					values		( @idStfAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ), @dtDue, @dShift )
			select	@idStfCvrg =	scope_identity( )

			update	tbStfAssn	set		idStfCvrg=	@idStfCvrg,		dtUpdated=	@dtNow
				where	idStfAssn = @idStfAssn

			fetch next from	cur	into	@idStfAssn, @dtDue, @dShift
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

	select	@fPerc =	1000.0

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			select	idCall, lCount, t.siIdx, tiSpec, tiColor
				,	case when tiSpec between 7 and 9	then t.sCall + ' †'	else t.sCall	end		as	sCall
				,	case when tiSpec between 7 and 9	then null			else tVoTrg	end		as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null			else tStTrg	end		as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	cast(round(case when lVoNul = lCount	then null	else lVoOnT*@fPerc/(lCount-lVoNul)	end, 0)	as int)	as	iVoOnT
				,	cast(round(case when lStNul = lCount	then null	else lStOnT*@fPerc/(lCount-lStNul)	end, 0)	as int)	as	iStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tVoice)	as	tVoMax
						,	max(ec.tStaff)	as	tStMax
						from	tbEvent_C	ec	with (nolock)
						join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
						where	ec.idEvent	between @iFrom	and @iUpto
						and		ec.tiHH		between @tFrom	and @tUpto
						and		ec.siBed & @siBeds <> 0
						group	by ec.idCall)	t
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = t.siIdx
				order by	siIdx desc
		else
			select	idCall, lCount, t.siIdx, tiSpec, tiColor
				,	case when tiSpec between 7 and 9	then t.sCall + ' †'	else t.sCall	end		as	sCall
				,	case when tiSpec between 7 and 9	then null			else tVoTrg	end		as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null			else tStTrg	end		as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	cast(round(case when lVoNul = lCount	then null	else lVoOnT*@fPerc/(lCount-lVoNul)	end, 0)	as int)	as	iVoOnT
				,	cast(round(case when lStNul = lCount	then null	else lStOnT*@fPerc/(lCount-lStNul)	end, 0)	as int)	as	iStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tVoice)	as	tVoMax
						,	max(ec.tStaff)	as	tStMax
						from	tbEvent_C	ec	with (nolock)
						join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
						join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
						where	ec.idEvent	between @iFrom	and @iUpto
						and		ec.tiHH		between @tFrom	and @tUpto
						and		ec.dShift	between @dFrom	and @dUpto
						and		ec.siBed & @siBeds <> 0
						group	by ec.idCall)	t
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = t.siIdx
				order by	siIdx desc
	else
		if	@tiShift = 0xFF
			select	idCall, lCount, t.siIdx, tiSpec, tiColor
				,	case when tiSpec between 7 and 9	then t.sCall + ' †'	else t.sCall	end		as	sCall
				,	case when tiSpec between 7 and 9	then null			else tVoTrg	end		as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null			else tStTrg	end		as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	cast(round(case when lVoNul = lCount	then null	else lVoOnT*@fPerc/(lCount-lVoNul)	end, 0)	as int)	as	iVoOnT
				,	cast(round(case when lStNul = lCount	then null	else lStOnT*@fPerc/(lCount-lStNul)	end, 0)	as int)	as	iStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tVoice)	as	tVoMax
						,	max(ec.tStaff)	as	tStMax
						from	tbEvent_C	ec	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = ec.idRoom
						join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
						where	ec.idEvent	between @iFrom	and @iUpto
						and		ec.tiHH		between @tFrom	and @tUpto
						and		ec.siBed & @siBeds <> 0
						group	by ec.idCall)	t
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = t.siIdx
				order by	siIdx desc
		else
			select	idCall, lCount, t.siIdx, tiSpec, tiColor
				,	case when tiSpec between 7 and 9	then t.sCall + ' †'	else t.sCall	end		as	sCall
				,	case when tiSpec between 7 and 9	then null			else tVoTrg	end		as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null			else tStTrg	end		as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	cast(round(case when lVoNul = lCount	then null	else lVoOnT*@fPerc/(lCount-lVoNul)	end, 0)	as int)	as	iVoOnT
				,	cast(round(case when lStNul = lCount	then null	else lStOnT*@fPerc/(lCount-lStNul)	end, 0)	as int)	as	iStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tVoice)	as	tVoMax
						,	max(ec.tStaff)	as	tStMax
						from	tbEvent_C	ec	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = ec.idRoom
						join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
						join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
						where	ec.idEvent	between @iFrom	and @iUpto
						and		ec.tiHH		between @tFrom	and @tUpto
						and		ec.dShift	between @dFrom	and @dUpto
						and		ec.siBed & @siBeds <> 0
						group	by ec.idCall)	t
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = t.siIdx
				order by	siIdx desc
end
go
--	----------------------------------------------------------------------------
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

	create table	#tbRpt1
	(
		idCall		smallint,
		iWDay		tinyint,
		tiHH		tinyint,

		lCount		int,	lVoOnT		int,	lVoNul		int,	lStOnT		int,	lStNul		int,

		primary key nonclustered (idCall, iWDay, tiHH)
	)
	create table	#tbRpt2
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

		primary key nonclustered (idCall, tiHH)
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idCall, datepart(dw,ec.dEvent), ec.tiHH, count(*)
					,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)
					,	sum(case when ec.tVoice is null		then 1 else 0 end)
					,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)
					,	sum(case when ec.tStaff is null		then 1 else 0 end)
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
					,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)
					,	sum(case when ec.tVoice is null		then 1 else 0 end)
					,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)
					,	sum(case when ec.tStaff is null		then 1 else 0 end)
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
					and		(cp.tiSpec	is null		or	cp.tiSpec	not	between 7 and 9)
					group	by ec.idCall, datepart(dw,ec.dEvent), ec.tiHH
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idCall, datepart(dw,ec.dEvent), ec.tiHH, count(*)
					,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)
					,	sum(case when ec.tVoice is null		then 1 else 0 end)
					,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)
					,	sum(case when ec.tStaff is null		then 1 else 0 end)
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
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
					,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)
					,	sum(case when ec.tVoice is null		then 1 else 0 end)
					,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)
					,	sum(case when ec.tStaff is null		then 1 else 0 end)
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
					and		(cp.tiSpec	is null		or	cp.tiSpec	not	between 7 and 9)
					group	by ec.idCall, datepart(dw,ec.dEvent), ec.tiHH

--	select	*	from	#tbRpt1

	set		@tiHH=	@tFrom
	if	@tUpto >= 24	set		@tUpto =	23
	while	@tiHH <= @tUpto
	begin
		insert	#tbRpt2 ( idCall, tiHH )
			select	distinct idCall, @tiHH
				from	#tbRpt1		with (nolock)
		set		@tiHH=	@tiHH + 1
	end	

--	select	*	from	#tbRpt2

	update	a
		set	a.lCount1= b.lCount1,	a.lVoOnT1= b.lVoOnT1,	a.lVoNul1= b.lVoNul1,	a.lStOnT1= b.lStOnT1,	a.lStNul1= b.lStNul1
		,	a.lCount2= b.lCount2,	a.lVoOnT2= b.lVoOnT2,	a.lVoNul2= b.lVoNul2,	a.lStOnT2= b.lStOnT2,	a.lStNul2= b.lStNul2
		,	a.lCount3= b.lCount3,	a.lVoOnT3= b.lVoOnT3,	a.lVoNul3= b.lVoNul3,	a.lStOnT3= b.lStOnT3,	a.lStNul3= b.lStNul3
		,	a.lCount4= b.lCount4,	a.lVoOnT4= b.lVoOnT4,	a.lVoNul4= b.lVoNul4,	a.lStOnT4= b.lStOnT4,	a.lStNul4= b.lStNul4
		,	a.lCount5= b.lCount5,	a.lVoOnT5= b.lVoOnT5,	a.lVoNul5= b.lVoNul5,	a.lStOnT5= b.lStOnT5,	a.lStNul5= b.lStNul5
		,	a.lCount6= b.lCount6,	a.lVoOnT6= b.lVoOnT6,	a.lVoNul6= b.lVoNul6,	a.lStOnT6= b.lStOnT6,	a.lStNul6= b.lStNul6
		,	a.lCount7= b.lCount7,	a.lVoOnT7= b.lVoOnT7,	a.lVoNul7= b.lVoNul7,	a.lStOnT7= b.lStOnT7,	a.lStNul7= b.lStNul7
		from	#tbRpt2		a	with (nolock)
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
					from	#tbRpt1		with (nolock)
					group	by idCall, tiHH)
							b	on	b.idCall = a.idCall		and	b.tiHH = a.tiHH

	update	#tbRpt2
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

	select	sc.siIdx, sc.sCall, sc.tVoTrg, sc.tStTrg, cp.tiColor, dateadd(hh, t2.tiHH, '0:0:0')	as	tHour,	t2.*
		from	#tbRpt2		t2	with (nolock)
		join	tb_SessCall sc	with (nolock)	on	sc.idCall = t2.idCall	and	sc.idSess = @idSess
		join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
		order by	sc.siIdx desc, t2.tiHH
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 8321 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	8321, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2022-10-13',	sVersion =	'single-db'
		where	siBuild = 8321

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.8321'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.8321 )'
commit
go

checkpoint
go

use [master]
go