--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
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
--						* fix tbShift [tiIdx=#3]:  .tEnd must equal .tBeg of 1st shift
--		2015-Aug-25		.5715
--		2015-Sep-16		.5737
--		2015-Oct-26		.5777
--						* pr_Module_GetAll
--		2015-Nov-03		.5785
--						* pr_User_GetAll
--						* pr_Module_GetAll
--						* fix built-in roles' descriptions
--		2015-Nov-06		.5788
--						* prRtlsBadge_UpdLoc
--						* reset unit-access for system accounts
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
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 5963 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.5963', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Exp')
	drop proc	dbo.pr_User_Exp
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_InsUpdAD')
	drop proc	dbo.pr_User_InsUpdAD
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_InsUpd')
	drop proc	dbo.prCfgPri_InsUpd
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_Ins')
	drop proc	dbo.prCfgPri_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgPri_Clr')
	drop proc	dbo.prCfgPri_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_UpdAct')
	drop proc	dbo.prCfgDvc_UpdAct
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_GetAll')
	drop proc	dbo.prSchedule_GetAll
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgTone_Clr')
	drop proc	dbo.prCfgTone_Clr
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgTone_Ins')
	drop proc	dbo.prCfgTone_Ins
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgTone_GetAll')
	drop proc	dbo.prCfgTone_GetAll
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgTone')
begin
--	begin tran
		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkCfgPri_Tone')
			alter table	dbo.tbCfgPri	drop constraint fkCfgPri_Tone
		drop table	dbo.tbCfgTone
--	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5665	* [8]
begin tran
	begin
		update	dbo.tb_Option	set	sOption =	'(internal) Trace/Debug mode'	where	idOption = 8			--	6.05	--	7.03	--	7.06.5665
	end
commit
go
--	----------------------------------------------------------------------------
--	Tone definitions (790 global configuration)
--	7.06.5694	+ .dtCreated
--	7.06.5687
create table	dbo.tbCfgTone
(
	tiTone		tinyint			not null	-- tone idx
		constraint	xpCfgTone	primary key clustered

,	sTone		varchar( 16 )	not null	-- tone name
,	vbTone		varbinary(max)	null		-- audio (uLaw-encoded)

,	dtCreated	smalldatetime not null	
		constraint	tdCfgTone_Created	default( getdate( ) )
--,	dtUpdated	smalldatetime not null	
--		constraint	tdCfgTone_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tbCfgTone		to [rWriter]
grant	select							on dbo.tbCfgTone		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns tones, ordered to be loadable into a table
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
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtCreated
			,	vbTone
			from	tbCfgTone	with (nolock)
			order	by	1
	else
		select	tiTone, sTone, len(vbTone) as	lLen,	cast(dateadd(ms, len(vbTone)/8,'0:0:0') as time(3))	as	tLen,	cast(1 as bit)	as	bActive,	dtCreated
			from	tbCfgTone	with (nolock)
			order	by	1
end
go
grant	execute				on dbo.prCfgTone_GetAll				to [rWriter]
grant	execute				on dbo.prCfgTone_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a tone definition
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
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
	--	begin
			insert	tbCfgTone	(  tiTone,  sTone,  vbTone )
					values		( @tiTone, @sTone, @vbTone )
	--		select	@s= @s + ' INS.'
	--	end

--		if	@iTrace & 0x40 > 0
		if	@iTrace & 0x01 > 0
		begin
			select	@s= 'Tone_I( ' + isnull(cast(@tiTone as varchar), '?') + ', n=' + isnull(@sTone, '?') + ' )'
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgTone_Ins				to [rWriter]
go
--	----------------------------------------------------------------------------
--	7.06.5687	+ .siIdxUg, .siIdxOt, .tiOtInt, .tiLight, .tiTone, .tiToneInt
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'tiTone')
begin
	begin tran
		alter table	dbo.tbCfgPri	add
			siIdxUg		smallint		null		-- upgrade priority-index
		,	siIdxOt		smallint		null		-- overtime priority-index
		,	tiOtInt		tinyint			null		-- overtime interval, min
		,	tiLight		tinyint			null		-- light-show index
		,	tiTone		tinyint			null		-- tone index
				constraint	fkCfgPri_Tone		foreign key references tbCfgTone
		,	tiToneInt	tinyint			null		-- tone interval, .25 sec
	commit
end
go
--	----------------------------------------------------------------------------
--	Clears all tone definitions
--	7.06.5702	+ reset tbCfgPri.tiTone
--	7.06.5687
create proc		dbo.prCfgTone_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran
		update	tbCfgPri	set	tiTone =	null							-- clear FKs

		delete	from	tbCfgTone
		select	@s= 'Tone_C( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgTone_Clr				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all existing schedules
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
	select	s.idSchedule, s.dtNextRun, s.sSchedule, r.sReport, f.sFilter,	s.idUser	as	idOwner,	u.sUser	as	sOwner,		s.dtLastRun, s.iResult
		,	s.bActive, s.dtCreated, s.dtUpdated
		from	tbSchedule s	with (nolock)
		join	tbReport r	with (nolock)	on	r.idReport = s.idReport
		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User u	with (nolock)	on	u.idUser = s.idUser
		where	(@idUser is null	or	s.idUser = @idUser)
		and		(@bActive is null	or	s.bActive = @bActive)
end
go
grant	execute				on dbo.prSchedule_GetAll			to [rWriter]
grant	execute				on dbo.prSchedule_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.5694	* [9] default: 30 -> 60, high-volume traffic scenario increases healing interval 1.5x on 790 side
--				  [10] default: 60 -> 90
begin tran
	begin
		update	dbo.tb_OptSys	set	iValue =	60	where	idOption = 9	--	30, 45, 60 [75, 90, 120]?	cannot be lower than 30s (790's call healing time is 28s)
		update	dbo.tb_OptSys	set	iValue =	90	where	idOption = 10	--	60, 75, 90 [120, 150, 180, 210, 240, 270, 300]?	cannot be lower than OptionSys[9]
	end
commit
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
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
	,	ea.idCall, c.siIdx, c.sCall, cp.iColorF, cp.iColorB, cp.tiShelf, cp.tiSpec, cp.iFilter, cp.tiTone, cp.tiToneInt
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit )		as	bAnswered
	,	ea.tiSvc, cast( getdate( ) - ea.dtEvent as time(3) )	as	tElapsed,	ea.dtExpires
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
--	Returns topmost event for a given unit
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idRoom, sRoom,	tiBed, cBed,	idUnit
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, iFilter, tiTone, tiToneInt
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
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idRoom, sRoom,	tiBed, cBed,	idUnit
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, iFilter, tiTone, tiToneInt
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
--	Data source for 7985
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
			,	rb.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, rb.sPatient, rb.cGender, rb.sInfo, rb.sNote, rb.idDoctor, rb.sDoctor
			,	rb.idUser1, rb.idStLvl1, rb.sStaffID1, rb.sStaff1, rb.bOnDuty1, rb.dtDue1
			,	rb.idUser2, rb.idStLvl2, rb.sStaffID2, rb.sStaff2, rb.bOnDuty2, rb.dtDue2
			,	rb.idUser3, rb.idStLvl3, rb.sStaffID3, rb.sStaff3, rb.bOnDuty3, rb.dtDue3
			,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
			,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
			,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
			,	cast(null as tinyint)	as	tiMap
			from	vwRoomBed		rb	with (nolock)
				join	#tbUnit		tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
				outer apply	fnEventA_GetTopByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster, 0 )	ea		--	7.03
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
			from	#tbUnit			tu	with (nolock)
				outer apply	fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea									--	7.03
				left join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed = 0xFF )	--	and	ea.tiBed is null
				left join	vwRoom		r	with (nolock)	on	r.idDevice = ea.idRoom
				outer apply	fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
			order	by	tu.sUnit
end
go
--	----------------------------------------------------------------------------
--	7.06.5701	* [39] tiLvl:	4 -> 8
begin
	begin tran
		update	dbo.tb_LogType	set	tiLvl=	8	where	idLogType = 39	--	'Component Stopped'	--	7.05.5045, 7.06.5701
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5708	* fix tbShift [tiIdx=#3]:  .tEnd must equal .tBeg of 1st shift
begin
	begin tran
		update	s3	set	s3.tEnd =	s1.tBeg
			from	dbo.tbShift	s3
			join	dbo.tbShift	s1	on	s1.idUnit = s3.idUnit	and	s1.tiIdx = 1	and	s1.bActive > 0
			where	s3.tiIdx = 3	and	s3.bActive > 0
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns modules state
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
	select	idModule, sModule, sDesc, bLicense, tiModType, sIpAddr, sMachine, sVersion, dtStart, sParams, dtLastAct
		,	case when sMachine is null then sIpAddr else sMachine end	as	sHost
		,	datediff( ss, dtLastAct, getdate( ) )	as	siElapsed
		,	cast( getdate( ) - dtStart as datetime )	as	dtRunTime
		from	tb_Module	with (nolock)
		where	(@bInstall = 0	or	sIpAddr is not null  or  sMachine is not null)
		and		(@bActive = 0	or	dtStart is not null)
end
go
--	----------------------------------------------------------------------------
--	Returns security details for all users
--	7.06.5785	+ 'Other' @idStfLvl handling
--	7.06.5567	* merged pr_User_GetByUnit -> pr_User_GetAll
--	7.06.5563	+ '@idUser <= 15' to allow returning predifined system user-accounts
--	7.06.5399	* optimized
--	7.05.5182
alter proc		dbo.pr_User_GetAll
(
	@idStfLvl	tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUser		int			= null	-- null=any
,	@sStaffID	varchar( 16 )= null	-- null=any
)
	with encryption
as
begin
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStaffID, idStfLvl, sBarCode, bOnDuty, dtDue, sStaff, sUnits, sTeams
		,	cast(case when tiFails=0xFF then 1 else 0 end as bit)	as	bLocked
		,	bActive, dtCreated, dtUpdated
		from	tb_User		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idStfLvl is null	or	idStfLvl = @idStfLvl	or	@idStfLvl = 0	and	idStfLvl is null)
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)			--	protect internal accounts
		and		(@sStaffID is null	or	sStaffID = @sStaffID)
end
go
--	----------------------------------------------------------------------------
--	7.06.5785	* fix built-in roles' descriptions
begin
	begin tran
		update	dbo.tb_Role		set	sDesc=	'Built-in role that automatically includes every user.  Access granted to this role is inherited by everybody.'	where	idRole = 1
		update	dbo.tb_Role		set	sDesc=	'Built-in role whose members have complete and unrestricted access to all units and components'' features.'		where	idRole = 2
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5788	* fix: reset unit-access for system accounts
begin tran
	update	dbo.tb_User		set	sUnits= '*'		where	idUser < 16

	exec	dbo.pr_UserUnit_Set
commit
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge
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
		,		@dtNow		datetime
		,		@idReceiver	smallint
		,		@idOldest	int

	set	nocount	on

	select	@dtNow =	getdate( ),		@iRetVal =	0,	@idOldest=	null	--, @tiPtype= null, @cSys= null, @tiGID= null, @tiJID= null, @tiRID= null
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

		return	@iRetVal		--	?? badge or receiver does not exist !!
	end


/*	if		not	exists( select 1 from tbRtlsBadge with (nolock) where idBadge = @idBadge )
		or	@idRcvrCurr > 0		and	not	exists( select 1 from tbRtlsRcvr with (nolock) where idReceiver = @idRcvrCurr )
		or	@idRcvrLast > 0		and	not	exists( select 1 from tbRtlsRcvr with (nolock) where idReceiver = @idRcvrLast )
	begin
		exec	dbo.pr_Log_Ins	82, null, null, @s

		return	-1		--	?? badge or receiver does not exist !!
	end
*/
	if	@idRcvrCurr = 0		select	@idRcvrCurr= null
	if	@idRcvrLast = 0		select	@idRcvrLast= null

	select	@idReceiver =	idRcvrCurr,		@idRoomPrev =	idRoom,		@dtEntered =	dtEntered,	@idRoomCurr =	null
		,	@idStfLvl =		idStfLvl,		@cSys =		cSys,	@tiGID =	tiGID,	@tiJID =	tiJID,	@tiRID =	tiRID	--	previous!!
		from	vwRtlsBadge		where	idBadge = @idBadge

---	select	@s=	@s + ' R=' + isnull(cast(@idReceiver as varchar),'?') + ' P=' + isnull(cast(@idRoomPrev as varchar),'?')
---	exec	dbo.pr_Log_Ins	0, null, null, @s

	if	@idReceiver = @idRcvrCurr	return	0		--	badge already at same location => skip

	select	@iRetVal =	1,	@idRoomCurr =	idRoom		--	new receiver
		from	tbRtlsRcvr		where	idReceiver = @idRcvrCurr

	begin	tran

		if	@idRoomPrev > 0  and  @idRoomCurr is null	or
			@idRoomCurr > 0  and  @idRoomPrev is null	or
			@idRoomCurr <> @idRoomPrev				--	badge moved [to another room]
		begin
			--	set new location
			update	tbRtlsBadge		set	idRoom =	@idRoomCurr,	dtEntered=	@dtNow,		@dtEntered =	@dtNow
				where	idBadge = @idBadge

			--	set user location
			update	u	set	idRoom =	@idRoomCurr,	dtEntered=	@dtNow
				from	tb_User		u
				join	tbDvc		d	on	d.idUser = u.idUser
			--	join	tbRtlsBadge	b	on	b.idBadge = d.idDvc
				where	d.idDvc = @idBadge

			--	remove this badge from any room
			update	tbRtlsRoom		set	bNotify =	1,	dtUpdated=	@dtNow,		idBadge =	null
				where	idBadge = @idBadge

			--	set for current room [if first]
			update	tbRtlsRoom		set	bNotify =	1,	dtUpdated=	@dtNow,		idBadge =	@idBadge
				where	idRoom = @idRoomCurr	and	idStfLvl = @idStfLvl	and	idBadge is null

			--	get oldest badge of same type for prev room
			select	top 1	@idOldest=	idBadge
				from	vwRtlsBadge	with (nolock)
				where	idRoom = @idRoomPrev	and	idStfLvl = @idStfLvl	---	and	idBadge is not null		--	not necessary!
				order	by	dtEntered

			--	remove that oldest from any room
			update	tbRtlsRoom		set	bNotify =	1,	dtUpdated=	@dtNow,		idBadge =	null
				where	idBadge = @idOldest

			--	set prev room to the oldest badge
			update	tbRtlsRoom		set	bNotify =	1,	dtUpdated=	@dtNow,		idBadge =	@idOldest
				where	idRoom = @idRoomPrev	and	idStfLvl = @idStfLvl

			select	@cSys=	null,	@tiGID =	null,	@tiJID =	null,	@tiRID =	null,	@iRetVal =	2

			select	@cSys=	cSys,	@tiGID =	tiGID,	@tiJID =	tiJID,	@tiRID =	tiRID
				from	tbDevice	with (nolock)
				where	idDevice = @idRoomCurr
		end

		update	tbRtlsBadge		set	dtUpdated=	@dtNow
			,	idRcvrCurr =	@idRcvrCurr,	dtRcvrCurr =	@dtRcvrCurr
			,	idRcvrLast =	@idRcvrLast,	dtRcvrLast =	@dtRcvrLast
			where	idBadge = @idBadge

	commit

	return	@iRetVal
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
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
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
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
--	Updates a given module's state
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

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sInfo

		exec	dbo.prEvent_Ins		0, null, null, null		---	@idCmd, @tiLen, @iHash, @vbCmd
				,	null, null, null, null, null			---	@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice
				,	null, null, null, null, null, @sInfo	---	@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo
				,	@idUnit out, @idRoom out, @idEvent out, @idSrcDvc out, @idDstDvc out
				,	@idLogType		---	, @idCall, @tiBtn, @tiBed, @iAID, @tiStype, @idCall0

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5843	* fix: set license bit for DB module
begin tran
	exec	dbo.pr_Module_Lic	1, 1
commit
go
--	----------------------------------------------------------------------------
--	7.06.5854	+ "on delete cascade" to fkUnitMapCell_UnitMap
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUnitMapCell_UnitMap')
begin
	begin tran
		alter table	dbo.tbUnitMapCell	drop constraint fkUnitMapCell_UnitMap

		alter table	dbo.tbUnitMapCell	add
			constraint	fkUnitMapCell_UnitMap	foreign key ( idUnit, tiMap ) references tbUnitMap	on delete cascade
	commit
end
go
--	----------------------------------------------------------------------------
--	Deactivates all devices, resets room state
--	7.06.5854	* "cDevice <> 'P'" instead of "tiStype is not null"
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

		update	tbDevice	set	bActive =	0,	dtUpdated=	getdate( )
			where	bActive = 1
			and		cDevice <> 'P'											--	skip SIP phones		--	7.06.5854
--			and		tiStype is not null										--	7.06.5352

		select	@s= 'Dvc_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	enforce tbUnitMap[Cell], tbDvcUnit, tbTeamUnit clean-up for inactive units
exec	dbo.prCfgLoc_SetLvl
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
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
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
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
			update	tbDevice	set		bActive= 1, dtUpdated= getdate( )	--, idEvent= null
				,	idParent= @idParent,	cSys= @cSys, tiGID= @tiGID, tiJID= @tiJID, tiRID= @tiRID
				,	tiStype= @tiStype,	cDevice= @cDevice,	sDevice= @sDevice,	sDial= @sDial,	sCodeVer= @sCodeVer,	sUnits= @sUnits
				,	tiPriCA0= @tiPriCA0, tiPriCA1= @tiPriCA1, tiPriCA2= @tiPriCA2, tiPriCA3= @tiPriCA3
				,	tiPriCA4= @tiPriCA4, tiPriCA5= @tiPriCA5, tiPriCA6= @tiPriCA6, tiPriCA7= @tiPriCA7
				,	tiAltCA0= @tiAltCA0, tiAltCA1= @tiAltCA1, tiAltCA2= @tiAltCA2, tiAltCA3= @tiAltCA3
				,	tiAltCA4= @tiAltCA4, tiAltCA5= @tiAltCA5, tiAltCA6= @tiAltCA6, tiAltCA7= @tiAltCA7
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
--	Returns 790 devices, filtered according to args
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
		and		(@tiKind & 0x01 <> 0	and	tiStype	< 4					--	G-way
			or	@tiKind & 0x02 <> 0		and	(tiStype between 4 and 7	or	tiStype = 124	or	tiStype = 126)	--	Room | 680-BusSt | 680-Main
			or	@tiKind & 0x04 <> 0		and	(tiStype between 8 and 11	or	tiStype = 24	or	tiStype = 26	or	tiStype = 125)	--	Master | Workflow | 680-Master
			or	@tiKind & 0x08 <> 0		and	tiStype between 13 and 15	--	Zone
			or	@tiKind & 0x10 <> 0)									--	Other
--		and		(@idUser is null	or	idUnit is null	or	idUnit in (select	idUnit
--					from	tb_RoleUnit	ru	with (nolock)
--					join	tb_UserRole	ur	with (nolock)	on	ur.idRole = ru.idRole	and	ur.idUser = @idUser))
		order by	sSGJR
end
go
--	----------------------------------------------------------------------------
--	update IP-address placement for gateways
update	dbo.tbDevice	set	sDial=	sUnits,	sUnits =	null	where	cDevice = 'G'
go
--	----------------------------------------------------------------------------
--	Returns devices/rooms/masters for given unit(s)
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
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiRID = 0
							and	(d.tiStype between 4 and 7										-- 790 room controllers
								or	d.tiStype = 0x7C	or	d.tiStype = 0x7E					-- 680 rooms
								or	d.idDevice in (select idParent from tbDevice w with (nolock) where w.tiRID = 1 and w.tiStype = 26)))
						or	(@tiKind = 2	and	d.tiRID = 0
							and	(d.tiStype between 8 and 11										-- 790 masters
								or	d.tiStype = 0x7D)))											-- 680 masters
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
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiRID = 0
							and	(d.tiStype between 4 and 7										-- 790 room controllers
								or	d.tiStype = 0x7C	or	d.tiStype = 0x7E					-- 680 rooms
								or	d.idDevice in (select idParent from tbDevice w with (nolock) where w.tiRID = 1 and w.tiStype = 26)))
						or	(@tiKind = 2	and	d.tiRID = 0
							and	(d.tiStype between 8 and 11										-- 790 masters
								or	d.tiStype = 0x7D)))											-- 680 masters
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
--	Inserts event [0x84] call status
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
		,	@siIdxNew=	@siPriNew & 0x03FF,		@idEvent =	null,			@bPresence =	0

	select	@s =	'E84_I( k=' + isnull(cast(@idCmd as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(@iAID as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(cast(@tiDstGID as varchar),'?') + '-' + isnull(cast(@tiDstJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


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

					insert	tbEvent_C	(  idEvent,  dEvent,	tEvent,    idCall,  idRoom,  idUnit,  tiBed,  siBed, idUser1, tiHH )
							values		( @idEvent, @dtOrigin, @dtOrigin, @idCall, @idRoom, @idUnit, @tiBed, @siBed, @idUser, datepart(hh, @dtOrigin) )

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

			update	tbEvent_A	set	dtExpires=	dateadd(ss, @iExpNrm, @dtEvent)
								,	siPri=	@siPriNew,	siIdx=	@siIdxNew,	idCall =	@idCall		--	7.06.5855
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
--	7.06.5868	+ [29,30] tbCall.tVoTrg, .tStTrg defaults
begin tran
	if	not	exists	(select 1 from dbo.tb_OptSys where idOption = 29)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 29,  61, 'Default Voice TRT for tCall.tVoTrg' )		--	7.06.5868
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 30,  61, 'Default Staff TRT for tCall.tStTrg' )		--	7.06.5868

		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 29, '00:01:00' )	--	tbCall.tVoTrg default
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 30, '00:02:00' )	--	tbCall.tStTrg default

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdCall_tVoTrg')
		begin
		--	begin tran
				alter table	dbo.tbCall	drop constraint	tdCall_tVoTrg
				alter table	dbo.tbCall	drop constraint	tdCall_tStTrg
		--	commit
		end
	end
commit
go
--	----------------------------------------------------------------------------
--	Imports enabled call-texts from tbCfgPri
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
	declare		@s			varchar( 255 )
--		,		@dtNow		smalldatetime
		,		@idIdx		smallint
		,		@siIdx		smallint			-- call-index
		,		@sCall		varchar( 16 )		-- call-text
		,		@tVoTrg		time( 0 )
		,		@tStTrg		time( 0 )
		,		@iCount		smallint

	declare		cur		cursor fast_forward for
		select	siIdx, sCall
			from	tbCfgPri	with (nolock)
			where	siIdx > 0	and	tiFlags & 0x02 > 0		-- enabled
			order	by	1

	set	nocount	on

	select	@iCount =	0
--		,	@dtNow =	getdate( )									-- smalldatetime truncates seconds

	select	@tVoTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 29
	select	@tStTrg =	cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 30

	begin	tran

		open	cur
		fetch next from	cur	into	@siIdx, @sCall
		while	@@fetch_status = 0
		begin
			select	@idIdx =	-1
			select	@idIdx =	idCall		from	tbCall	with (nolock)	where	siIdx = @siIdx	and	bActive > 0
	--		print	cast(@siIdx as varchar) + ': ' + @sCall + ' -> ' + cast(@idIdx as varchar)

			if	@idIdx < 0
			begin
	--			print	'  insert new'
				insert	tbCall	(  siIdx,  sCall,  tVoTrg,  tStTrg )
						values	( @siIdx, @sCall, @tVoTrg, @tStTrg )

				select	@iCount =	@iCount + 1
			end

			fetch next from	cur	into	@siIdx, @sCall
		end
		close	cur
		deallocate	cur

		select	@s =	'Call_Imp( ) +' + cast(@iCount as varchar) + ' row(s)'
		exec	dbo.pr_Log_Ins	72, null, null, @s

		update	c	set	c.bActive=	0
			from	tbCall	c
			join	tbCfgPri	p	on	p.siIdx = c.siIdx	and	p.tiFlags & 0x02 = 0
			where	c.bActive > 0

		select	@s =	'Call_Imp( ) -' + cast(@@rowcount as varchar) + ' row(s)'
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

	select	@s =	'Call_GI( ' + isnull(cast(@siIdx as varchar), '?') + ':' + isnull(@sCall, '?') + ' )'

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
--	7.06.5869	+ [31-36]
begin tran
	if	not	exists	(select 1 from dbo.tb_OptSys where idOption = 31)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 31,  56, 'Enable AD integration?' )					--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 32, 167, 'AD root domain' )							--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 33, 167, 'AD root''s DN' )							--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 34,  56, 'AD LDAP port' )								--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 35, 167, 'AD I/O user' )								--	7.06.5869
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 36, 167, 'AD I/O pass' )								--	7.06.5869

		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 31, 0 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 32, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 33, '' )
		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 34, 0 )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 35, '' )
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 36, '' )
	end
commit
go
--	----------------------------------------------------------------------------
--	7.06.5886	+ .tiFmt
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbSchedule') and name = 'tiFmt')
begin
	begin tran
		alter table	dbo.tbSchedule	add
			tiFmt		tinyint			not null	-- 1=PDF, 2=CSV, 3=XLS
				constraint	tdSchedule_Format	default( 1 )
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns an existing schedule
--	7.06.5886	+ .tiFmt
--	7.06.5659	+ .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_GetToRun
--	7.03
alter proc		dbo.prSchedule_Get
(
	@idSchedule	smallint out
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
		from	tbSchedule	s	with (nolock)
		join	tbReport r	with (nolock)	on	r.idReport = s.idReport
--		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User	u	with (nolock)	on	u.idUser = s.idUser
		where	idSchedule = @idSchedule
end
go
--	----------------------------------------------------------------------------
--	Returns all existing schedules
--	7.06.5886	+ .tiFmt
--	7.06.5694
alter proc		dbo.prSchedule_GetAll
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
		,	s.idFilter, f.sFilter	--,	f.idUser, f.xFilter
		,	s.bActive, s.dtCreated, s.dtUpdated
		from	tbSchedule s	with (nolock)
		join	tbReport r	with (nolock)	on	r.idReport = s.idReport
		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User u	with (nolock)	on	u.idUser = s.idUser
		where	(@idUser is null	or	s.idUser = @idUser)
		and		(@bActive is null	or	s.bActive = @bActive)
end
go
--	----------------------------------------------------------------------------
--	Returns a list of active schedules, due for execution right now
--	7.06.5886	+ .tiFmt
--	7.06.5659	+ .sReport, r.sRptName, r.sClass
--	7.06.5616	* standardize output with prSchedule_Get
--	7.05.4980	* u.sFirst + ' ' + u.sLast -> u.sStaff
--	7.03
alter proc		dbo.prSchedule_GetToRun
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult, s.tiFmt, s.sSendTo
		,	s.idUser	as	idOwner,	u.sUser	as	sOwner
		,	s.idReport, r.sReport, r.sRptName, r.sClass
		,	s.idFilter,	f.idUser, f.sFilter, f.xFilter
		,	s.bActive, s.dtCreated, s.dtUpdated
		from	tbSchedule	s	with (nolock)
		join	tbReport r	with (nolock)	on	r.idReport = s.idReport
		join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		join	tb_User u	with (nolock)	on	u.idUser = s.idUser
		where	s.bActive > 0	and	s.dtNextRun < getdate( )
end
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing schedule
--	7.06.5886	+ .tiFmt
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
,	@tiFmt		tinyint				-- 1=PDF, 2=CSV, 3=XLS
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

	begin	tran

		if	@idSchedule > 0
		begin
			update	tbSchedule	set	tiRecur =	@tiRecur,	tiWkDay =	@tiWkDay,	siMonth =	@siMonth,	sSchedule=	@sSchedule
				,	dtNextRun=	@dtNextRun,	idUser =	@idUser		--, dtLastRun= @dtLastRun, iResult= @iResult
				,	idFilter =	@idFilter,	idReport =	@idReport,	tiFmt=	@tiFmt,	sSendTo =	@sSendTo,	bActive =	@bActive
				,	dtUpdated=	getdate( )
				where	idSchedule = @idSchedule
		end
		else
		begin
			insert	tbSchedule	(  tiRecur,  tiWkDay,  siMonth,  sSchedule,  dtNextRun,  idUser,  idFilter,  idReport,  tiFmt,  sSendTo )	--,  dtLastRun,  iResult
					values		( @tiRecur, @tiWkDay, @siMonth, @sSchedule, @dtNextRun, @idUser, @idFilter, @idReport, @tiFmt, @sSendTo )	--, @dtLastRun, @iResult
			select	@idSchedule =	scope_identity( )
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5900	+ [60,90]
begin tran
	delete	from	dbo.tb_Module	where idModule = 94

	if	not	exists	(select 1 from dbo.tb_Module where idModule = 60)
	begin
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )			--	7.06.5900
			values	(  60, 'J7980cs', 4, 0, '7980 Config Sync Service' )
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )			--	7.06.5900
			values	(  90, 'J7983cs', 4, 0, '7983 Config Sync Service' )
	end
	else
	begin
		update	dbo.tb_Module	set	sModule =	'J7980cs',	sDesc=	'7980 Config Sync Service'	where	idModule = 60
		update	dbo.tb_Module	set	sModule =	'J7983cs',	sDesc=	'7983 Config Sync Service'	where	idModule = 90
	end
commit
go
--	----------------------------------------------------------------------------
--	Removes expired calls
--	7.06.5618	* optimize
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

	begin	tran

		select	@dt =	getdate( )											-- mark starting time

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
--	790 device/station definitions (local configuration)
--	7.06.5905	+ .bConfig
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDevice') and name = 'bConfig')
begin
	begin tran
		alter table	dbo.tbDevice	add
			bConfig		bit				not null	-- discovery during Config download
				constraint	tdDevice_Config		default( 1 )
	commit
end
go
--	----------------------------------------------------------------------------
--	Resets .bConfig for all devices under a given GW, resets corresponding rooms' state
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
	declare		@s			varchar( 255 )
		,		@iTrace		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Dvc_I( ' + isnull(@cSys,'?') + '-' + isnull(cast(@tiGID as varchar),'?') + ' ): '

	begin	tran

		update	r	set	idUnit =	null,	idEvent =	null,	tiSvc =		null,	dtUpdated=	getdate( )
					,	idUserG =	null,	sStaffG =	null,	idUserO =	null,	sStaffO =	null,	idUserY =	null,	sStaffY =	null
			from	tbRoom		r
			join	tbDevice	d	on	d.idDevice = r.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
	--		where	idRoom	in (select	idDevice	from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiRID = 0)
		select	@s =	@s + cast(@@rowcount as varchar) + ' room(s), '

		update	rb	set	tiIBed =	null,	idEvent =	null,	tiSvc =		null,	dtUpdated=	getdate( )
--	-				,	idUser1 =	null,	idUser2 =	null,	idUser3 =	null,	idPatient=	null
			from	tbRoomBed	rb
			join	tbDevice	d	on	d.idDevice = rb.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
	--		where	idRoom	in (select	idDevice	from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiRID = 0)
		select	@s =	@s + cast(@@rowcount as varchar) + ' room-bed(s), '

		update	tbDevice	set	bConfig =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID
	--		where	bActive > 0
	--		and		cDevice <> 'P'											--	skip SIP phones		--	7.06.5854
--	-		and		tiStype is not null										--	7.06.5352
		select	@s =	@s + cast(@@rowcount as varchar) + ' dvc(s)'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets .bActive for all devices under a given GW, based on .bConfig set after Config download
--	7.06.5912	+ set current assigned staff
--	7.06.5907
create proc		dbo.prCfgDvc_UpdAct
(
	@cSys		char( 1 )			-- source system
,	@tiGID		tinyint				-- source G-ID - gateway
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
		,		@iTrace		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Dvc_UA( ' + isnull(@cSys,'?') + '-' + isnull(cast(@tiGID as varchar),'?') + ' ): +'

	begin	tran

		update	tbDevice	set	bActive =	1,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig > 0		and	bActive = 0
		select	@s =	@s + cast(@@rowcount as varchar) + ' dvc(s), -'

		update	tbDevice	set	bActive =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig = 0		and	bActive > 0
		select	@s =	@s + cast(@@rowcount as varchar) + ' dvc(s)'

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

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgDvc_UpdAct				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
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
					right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
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
--	Inserts a call-priority definition
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
,	@tiFlags	tinyint				-- bit flags: 1=locking, 2=enabled
,	@tiShelf	tinyint				-- shelf: 0=nondisplay, 1=routine, 2=urgent, 3=emergency, 4=code
,	@tiSpec		tinyint				-- special priority [0..22]
,	@siIdxUg	smallint			-- upgrade priority-index
,	@siIdxOt	smallint			-- overtime priority-index
,	@tiOtInt	tinyint				-- overtime interval, min
,	@tiLight	tinyint				-- light-show index
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
				', oi=' + isnull(cast(@tiOtInt as varchar), '?') +	', ls=' + isnull(cast(@tiLight as varchar), '?') +
				', tn=' + isnull(cast(@tiTone as varchar), '?') +	', ti=' + isnull(cast(@tiToneInt as varchar), '?') +
				', sp=' + isnull(cast(@tiSpec as varchar), '?') +	', cf=' + isnull(cast(@iColorF as varchar), '?') +
				', cb=' + isnull(cast(@iColorB as varchar), '?') +	', fm=' + isnull(cast(@iFilter as varchar), '?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgPri where siIdx = @siIdx)
			update	tbCfgPri	set		sCall=	@sCall,		tiFlags =	@tiFlags
				,	tiShelf =	@tiShelf,	tiSpec =	@tiSpec,	siIdxUg =	@siIdxUg,	siIdxOt =	@siIdxOt
				,	tiOtInt =	@tiOtInt,	tiLight =	@tiLight,	tiTone =	@tiTone,	tiToneInt=	@tiToneInt
				,	iColorF =	@iColorF,	iColorB =	@iColorB,	iFilter =	@iFilter
				where	siIdx = @siIdx
		else
			insert	tbCfgPri	(  siIdx,  sCall,  tiFlags,  tiShelf,  tiSpec,  siIdxUg,  siIdxOt,  tiOtInt,  tiLight,  tiTone,  tiToneInt,  iColorF,  iColorB,  iFilter )
					values		( @siIdx, @sCall, @tiFlags, @tiShelf, @tiSpec, @siIdxUg, @siIdxOt, @tiOtInt, @tiLight, @tiTone, @tiToneInt, @iColorF, @iColorB, @iFilter )

		if	@iTrace & 0x40 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
grant	execute				on dbo.prCfgPri_InsUpd				to [rWriter]
go
--	----------------------------------------------------------------------------
--	7.06.5912	+ .gGUID, .utSynched
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'gGUID')
begin
	begin tran
		alter table	dbo.tb_User	add
			gGUID		uniqueidentifier	null	-- AD GUID
		,	utSynched	smalldatetime	null		-- last sync with AD
	commit
end
go
--	7.06.5961	* .dtSynched -> .utSynched
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'dtSynched')
begin
	begin tran
		exec sp_rename 'tb_User.dtSynched',		'utSynched',	'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5913	* [5]
begin
	update	dbo.tb_Option	set	sOption =	'(internal) Gateway IP-mask'	where	idOption = 5			--	7.05.5095	.5913
end
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
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

			select	@s =	'OptSys_U [' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s =	@s + ', i=' + isnull(cast(@iValue as varchar), '?') + ' (0x' + upper(substring(sys.fn_varbintohexstr(@iValue),3,8)) + ')'
			else if	@k = 62		select	@s =	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s =	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s =	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	236, @idUser, null, @s

			if	@idOption = 11		exec	dbo.pr_User_sStaff_Upd			-- staff name format

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.5914	+ [76]
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 76)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 76,  2, 16, 'Button definition' )		--	7.06.5914
	commit
end
go
--	----------------------------------------------------------------------------
--	Clears all filter definitions
--	7.06.5914	* optimized
--	7.04.4898	* prCfgFlt_DelAll -> prCfgFlt_Clr
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgFlt_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		delete	from	tbCfgFlt
		select	@s= 'Flt_C( ) ' + cast(@@rowcount as varchar) + ' row(s)'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a filter definition
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

	select	@s= 'Flt_I( ' + isnull(cast(@idIdx as varchar), '?') + ', f=' + isnull(cast(@iFilter as varchar), '?') + ', n=' + isnull(@sFilter, '?') + ' )'

	begin	tran

		insert	tbCfgFlt	(  idIdx,  iFilter,  sFilter )
				values		( @idIdx, @iFilter, @sFilter )

		if	@iTrace & 0x40 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Clears all tone definitions
--	7.06.5914	* optimized
--	7.06.5702	+ reset tbCfgPri.tiTone
--	7.06.5687
alter proc		dbo.prCfgTone_Clr
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		update	tbCfgPri	set	tiTone =	null							-- clear FKs

		delete	from	tbCfgTone
		select	@s= 'Tone_C( ) ' + cast(@@rowcount as varchar) + ' row(s)'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a tone definition
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

	select	@s= 'Tone_I( ' + isnull(cast(@tiTone as varchar), '?') + ', n=' + isnull(@sTone, '?') + ' )'

	begin	tran

		insert	tbCfgTone	(  tiTone,  sTone,  vbTone )
				values		( @tiTone, @sTone, @vbTone )

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Clears all location definitions
--	7.06.5914	* optimized
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.04.4892	* tbDefLoc -> tbCfgLoc
--	6.05
alter proc		dbo.prCfgLoc_Clr
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		delete	from	tbCfgLoc
		select	@s= 'Loc_C( ) ' + cast(@@rowcount as varchar) + ' row(s)'

		if	@iTrace & 0x02 > 0
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
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
				', l=' + isnull(cast(@tiLvl as varchar), '?') + ', n=' + isnull(@sLoc, '?') + ' )'

	begin	tran

		insert	tbCfgLoc	(  idLoc,  idParent,  tiLvl,  cLoc,  sLoc, sPath )
				values		( @idLoc, @idParent, @tiLvl, '?', @sLoc, '' )

		if	@iTrace & 0x02 > 0
			exec	dbo.pr_Log_Ins	73, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5914	* [0].sUnit 'INTERNAL UNIT 00' -> '00_internal_unit'
--	7.06.5914	* [0].sShift 'SHIFT 00' -> '00_shift'
begin tran
	update	dbo.tbUnit	set	sUnit =		'00_internal_unit'	where	idUnit = 0
	update	dbo.tbShift	set	sShift =	'00_shift'			where	idShift = 0
commit
go
--	----------------------------------------------------------------------------
--	Clears all master attributes
--	7.06.5914	* 74->75, optimized
--	7.06.5905	* 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgMst_Clr
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		delete	from	tbCfgMst
		select	@s= 'Mst_C( ) ' + cast(@@rowcount as varchar) + ' row(s)'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	75, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a master attributes record
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
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Mst_I( ' + isnull(cast(@idMaster as varchar), '?') +
				', c=' + isnull(cast(@tiCvrg as varchar), '?') + ', f=' + isnull(cast(@iFilter as varchar), '?') + ' )'

	if	@tiCvrg = 0xFF		select	@tiCvrg= 0		--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgMst with (nolock) where idMaster = @idMaster and tiCvrg = @tiCvrg)
	begin
		begin	tran

			insert	tbCfgMst	(  idMaster,  tiCvrg,  iFilter )
					values		( @idMaster, @tiCvrg, @iFilter )

			if	@iTrace & 0x08 > 0
				exec	dbo.pr_Log_Ins	75, null, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Clears all device button inputs
--	7.06.5914	* 74->76
--	7.06.5905	* 72->74
--	7.04.4896	* tb_OptionSys -> tb_OptSys
--	7.03
alter proc		dbo.prCfgDvcBtn_Clr
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	begin	tran

		delete	from	tbCfgDvcBtn
		select	@s= 'DvcBtn_C( ) ' + cast(@@rowcount as varchar) + ' row(s)'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	76, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a device button input
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
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'DvcBtn_I( ' + isnull(cast(@idDevice as varchar), '?') + ', b=' + isnull(cast(@tiBtn as varchar), '?') +
				', p=' + isnull(cast(@siPri as varchar), '?') + ', b=' + isnull(cast(@tiBed as varchar), '?') + ' )'

	if	@tiBed = 0xFF		select	@tiBed= null	--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgDvcBtn with (nolock) where idDevice = @idDevice and tiBtn = @tiBtn)
	begin
		begin	tran

			insert	tbCfgDvcBtn	(  idDevice,  tiBtn,  siPri,  tiBed )
					values		( @idDevice, @tiBtn, @siPri, @tiBed )

			if	@iTrace & 0x20 > 0
				exec	dbo.pr_Log_Ins	76, null, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	7.06.5914	* .dtCreated -> .dtUpdated
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgPri') and name = 'dtUpdated')
begin
	begin tran
		exec sp_rename 'tbCfgPri.dtCreated',	'dtUpdated',	'column'

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdCfgPri_Created')
			exec sp_rename 'dbo.tdCfgPri_Created',		'tdCfgPri_Updated'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns priorities, ordered to be loadable into a table
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
		,	cast(tiFlags & 0x01 as bit) [bLocking]
		,	cast(tiFlags & 0x02 as bit) [bEnabled]
		,	cast(tiFlags & 0x04 as bit) [bControl]
		,	cast(tiFlags & 0x08 as bit) [bRndRmnd]
		,	siIdxUg, siIdxOt, tiOtInt, tiLight, tiTone, tiToneInt
		,	dtUpdated
		from	tbCfgPri	with (nolock)
		where	@bEnabled = 0	or	tiFlags & 0x02 > 0
		order	by	1 desc
end
go
--	----------------------------------------------------------------------------
--	7.06.5914	* .dtCreated -> .dtUpdated
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbCfgLoc') and name = 'dtUpdated')
begin
	begin tran
		exec sp_rename 'tbCfgLoc.dtCreated',	'dtUpdated',	'column'

		if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdCfgLoc_Created')
			exec sp_rename 'dbo.tdCfgLoc_Created',		'tdCfgLoc_Updated'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all locations, ordered to be loadable into a tree
--	7.06.5914	* .dtCreated -> .dtUpdated
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
				when tiLvl = 5	then 'Cvrg Area'
				else	'??'	end		as	sLvl
		,	cast(1 as bit)	as bActive
		,	dtUpdated
		from	tbCfgLoc	with (nolock)
		order	by	sPath
end
go
--	----------------------------------------------------------------------------
--	7.06.5924	+ [37]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 37)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 37, 167, 'AD *790* group GUID' )						--	7.06.5924
		insert	dbo.tb_OptSys ( idOption, sValue )	values	( 37, '' )
	end
commit
go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
--	7.06.5926	* optimize log
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

	select	@s =	'E41_I( s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' :' + isnull(cast(@tiBtn as varchar),'?') + ' "' + isnull(@sSrcDvc,'?') +
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
--	7.06.5931	* [62,00] Patients->Room-Beds
begin tran
	update	dbo.tb_Feature	set	sFeature =	'Assignments - Room-Beds'	where	idModule = 62	and	idFeature = 00		--	7.06.5931
commit
go
--	----------------------------------------------------------------------------
--	7.06.5934	+ [38]
begin tran
	if	not	exists	(select 1 from dbo.tb_Option where idOption = 38)
	begin
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 38,  61, 'Default .tBeg for new shifts' )				--	7.06.5934
		insert	dbo.tb_OptSys ( idOption, tValue )	values	( 38, '07:00:00' )	--	tbShift.tBeg default
	end
commit
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
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
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@tBeg		time( 0 )
		,		@sUnit		varchar( 16 )
		,		@iCount		smallint
		,		@idUnit		smallint
		,		@tiMap		tinyint
		,		@tiCell		tinyint
		,		@idShift	smallint

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@tBeg =		cast(tValue as time( 0 ))	from	tb_OptSys	with (nolock)	where	idOption = 38

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
		update	u	set	u.bActive=	0,	u.dtUpdated =	getdate( )
			from	tbUnit	u
			left join 	tbCfgLoc	l	on l.idLoc = u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1	and	l.idLoc is null

		-- deactivate shifts for inactive units
		update	s	set	s.bActive=	0,	s.dtUpdated =	getdate( )
			from	tbShift	s
			join	tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0

		-- remove items for inactive units									--	7.06.5854
--		delete	from	tbUnitMapCell										-- cascade
--			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbUnitMap
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbDvcUnit
			where	idUnit	in	(select	idUnit	from	tbUnit	where	bActive = 0)
		delete	from	tbTeamUnit
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
						values	( @idUnit, 1, 'Shift 1', @tBeg, @tBeg )			--	7.06.5934	'07:00:00'
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
--	Imports a shift
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
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s =	'Sh_Imp( sh=' + isnull(cast(@idShift as varchar),'?') + ', u=' + isnull(cast(@idUnit as varchar),'?') + ', ix=' + isnull(cast(@tiIdx as varchar),'?') +
					', sh="' + isnull(cast(@sShift as varchar),'?') + '", tB=' + isnull(convert(varchar, @tBeg, 108),'?') + ', tE=' + isnull(convert(varchar, @tEnd, 108),'?') +
					', nm=' + isnull(cast(@tiNotify as varchar),'?') + ', bk=' + isnull(cast(@idUser as varchar),'?') +
					', a?=' + isnull(cast(@bActive as varchar),'?') + ', cr=' + isnull(convert(varchar, @dtCreated, 20),'?') + ', up=' + isnull(convert(varchar, @dtUpdated, 20),'?') + ' )'

	if	@iTrace & 0x01 > 0
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
--	Populates tb_UserUnit for each user/staff based on 7980's .sUnits
--	7.06.5939	- @sUser='All Units'
--	7.06.5568	+ @sUser='*'
--	7.05.5121	* .sBarCode -> .sUnits
--	7.05.5098	* check idUnit
--	7.05.5084	* added check for null on @sUnits
--	7.05.5050
alter proc		dbo.pr_UserUnit_Set
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

	begin	tran

		open	cur
		fetch next from	cur	into	@id, @sUnits
		while	@@fetch_status = 0
		begin
	--		print	char(10) + cast( @id as varchar )
			if	@sUnits = '*'	--	or	@sUnits = 'All Units'
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
--	----------------------------------------------------------------------------
--	7.06.5939	* fix: remove 'All Units' and enforce unit-access for system accounts
begin tran
	update	dbo.tb_User		set	sUnits= '*'		where	sUnits = 'All Units'
	update	dbo.tb_User		set	sUnits= '*'		where	idUser < 16

	exec	dbo.pr_UserUnit_Set
commit
go
--	----------------------------------------------------------------------------
--	7.06.5939	- .cBed
if	exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRoomBed') and name = 'cBed')
begin
	exec( 'alter table	dbo.tbRoomBed	drop	column	cBed'
		)
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a bed definition
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
--	,	rb.idAssn1, a1.idStfLvl [idStLvl1], a1.sStaffID [sAssnID1], a1.sStaff [sAssn1], a1.bOnDuty [bOnDuty1]
--	,	rb.idAssn2, a2.idStfLvl [idStLvl2], a2.sStaffID [sAssnID2], a2.sStaff [sAssn2], a2.bOnDuty [bOnDuty2]
--	,	rb.idAssn3, a3.idStfLvl [idStLvl3], a3.sStaffID [sAssnID3], a3.sStaff [sAssn3], a3.bOnDuty [bOnDuty3]
	,	rb.idUser1,	a1.idStfLvl as idStLvl1,	a1.sStaffID as sStaffID1,	a1.sStaff as sStaff1,	a1.bOnDuty as bOnDuty1,	a1.dtDue as dtDue1
	,	rb.idUser2,	a2.idStfLvl as idStLvl2,	a2.sStaffID as sStaffID2,	a2.sStaff as sStaff2,	a2.bOnDuty as bOnDuty2,	a2.dtDue as dtDue2
	,	rb.idUser3,	a3.idStfLvl as idStLvl3,	a3.sStaffID as sStaffID3,	a3.sStaff as sStaff3,	a3.bOnDuty as bOnDuty3,	a3.dtDue as dtDue3
--	,	r.idReg4, r.sReg4,	r.idReg2, r.sReg2,	r.idReg1, r.sReg1
	,	r.idUserG, r.idStfLvlG, r.sStaffIDG, r.sStaffG, r.bOnDutyG, r.dtDueG
	,	r.idUserO, r.idStfLvlO, r.sStaffIDO, r.sStaffO, r.bOnDutyO, r.dtDueO
	,	r.idUserY, r.idStfLvlY, r.sStaffIDY, r.sStaffY, r.bOnDutyY, r.dtDueY
	,	rb.dtUpdated
	from	tbRoomBed	rb	with (nolock)
	join	tbDevice	d	with (nolock)	on	d.idDevice = rb.idRoom		and	d.bActive > 0
	join	vwRoom		r	with (nolock)	on	r.idDevice = rb.idRoom
	left join	tbCfgBed	cb	with (nolock)	on	rb.tiBed = cb.tiBed		---	and	cb.bActive > 0	--	no need
---	left join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0
	left join	tbPatient	p	with (nolock)	on	p.idRoom = rb.idRoom		and	p.tiBed = rb.tiBed	--	p.idPatient = rb.idPatient
	left join	tbDoctor	dc	with (nolock)	on	dc.idDoctor = p.idDoctor
	left join	vwStaff		a1	with (nolock)	on	a1.idUser = rb.idUser1
	left join	vwStaff		a2	with (nolock)	on	a2.idUser = rb.idUser2
	left join	vwStaff		a3	with (nolock)	on	a3.idUser = rb.idUser3
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
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
--	Logs out a user
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
		,		@idUser		int
		,		@sIpAddr	varchar( 40 )
		,		@sMachine	varchar( 32 )

	set	nocount	on

	select	@idUser =	idUser,		@sIpAddr =	sIpAddr,	@sMachine=	sMachine
		from	tb_Sess
		where	idSess = @idSess

	if	@idUser > 0
	begin
		begin	tran

			update	tb_Sess		set	dtLastAct=	getdate( ),	idUser =	null
				where	idSess = @idSess

			select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s

		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Cleans-up a session
--	7.05.5940	* optimize
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
	@idSess		int					--	0 = application-end (delete all sessions)
,	@bLog		bit		=	1		--	log-out user (for individual session)?
,	@idModule	tinyint	=	null	--	indicates app, required if @idSess=0
)
	with encryption
as
begin
	declare		@idLogType	tinyint
		,		@iTout		int

	set	nocount	on

	select	@iTout =	iValue		from	tb_OptSys	where	idOption = 1

	begin	tran

		if	@idSess > 0		-- sess-end
		begin
			if	@bLog > 0
			begin
				select	@idLogType =	case when	dateadd( ss, -10, dateadd( mi, @iTout, dtLastAct ) ) < getdate( )
												then	230
												else	229	end
					from	tb_Sess		with (nolock)
					where	idSess = @idSess

				exec	dbo.pr_User_Logout	@idSess, @idLogType
			end

			exec	dbo.pr_Sess_Clr		@idSess

			delete	from	tb_Sess		where	idSess = @idSess
		end
		else				-- app-end
		begin
			declare	cur		cursor fast_forward for
				select	idSess
					from	tb_Sess
					where	idModule = @idModule

			open	cur
			fetch next from	cur	into	@idSess
			while	@@fetch_status = 0
			begin
				exec	dbo.pr_User_Logout	@idSess, 230
				exec	dbo.pr_Sess_Clr		@idSess

				delete	from	tb_Sess		where	idSess = @idSess
			
				fetch next from	cur	into	@idSess
			end
			close	cur
			deallocate	cur
	--	-	exec	dbo.pr_Sess_Clr		null
	--	-	delete	from	tb_Sess
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.5940	* fix: remove stale sessions
begin
	begin tran
			exec	dbo.pr_Sess_Clr		null
			delete	from	tb_Sess
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed
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

	select	@s=	'Pat_UL( [' + isnull(cast(@idPatient as varchar),'?') + '] "' + isnull(@sPatient,'?') +
				'", ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
				right('0' + isnull(cast(@tiJID as varchar),'?'), 2) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
				', [' + isnull(cast(@idRoom as varchar),'?') + '] ' + isnull(@sDevice,'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + ' )'

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

	select	@s=	'SA_Imp( ' + isnull(cast(@cSys as varchar),'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) +
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
	declare		@idShift	smallint
		,		@s			varchar( 255 )
		,		@iTrace		int

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
			select	@s =	@s + ' invalid args'
			exec	dbo.pr_Log_Ins	47, null, null, @s
			commit
			return	-1
		end

		select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

		if	@iTrace & 0x80 > 0
			exec	dbo.pr_Log_Ins	46, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets .bConfig for all devices under a given GW, resets corresponding rooms' state
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
	declare		@s			varchar( 255 )
		,		@iTrace		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Dvc_I( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + ' ): '

	begin	tran

		update	r	set	idUnit =	null,	idEvent =	null,	tiSvc =		null,	dtUpdated=	getdate( )
					,	idUserG =	null,	sStaffG =	null,	idUserO =	null,	sStaffO =	null,	idUserY =	null,	sStaffY =	null
			from	tbRoom		r
			join	tbDevice	d	on	d.idDevice = r.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
	--		where	idRoom	in (select	idDevice	from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiRID = 0)
		select	@s =	@s + cast(@@rowcount as varchar) + ' room(s), '

		update	rb	set	tiIBed =	null,	idEvent =	null,	tiSvc =		null,	dtUpdated=	getdate( )
--	-				,	idUser1 =	null,	idUser2 =	null,	idUser3 =	null,	idPatient=	null
			from	tbRoomBed	rb
			join	tbDevice	d	on	d.idDevice = rb.idRoom	and	d.cSys = @cSys	and	d.tiGID = @tiGID
	--		where	idRoom	in (select	idDevice	from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiRID = 0)
		select	@s =	@s + cast(@@rowcount as varchar) + ' room-bed(s), '

		update	tbDevice	set	bConfig =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID
	--		where	bActive > 0
	--		and		cDevice <> 'P'											--	skip SIP phones		--	7.06.5854
--			and		tiStype is not null										--	7.06.5352
		select	@s =	@s + cast(@@rowcount as varchar) + ' dvc(s)'

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Resets .bActive for all devices under a given GW, based on .bConfig set after Config download
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
	declare		@s			varchar( 255 )
		,		@iTrace		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Dvc_UA( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + ' ): +'

	begin	tran

		update	tbDevice	set	bActive =	1,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig > 0		and	bActive = 0
		select	@s =	@s + cast(@@rowcount as varchar) + ' dvc(s), -'

		update	tbDevice	set	bActive =	0,	dtUpdated=	getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID		and	bConfig = 0		and	bActive > 0
		select	@s =	@s + cast(@@rowcount as varchar) + ' dvc(s)'

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

		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	74, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
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
		,	r.idDevice as idRoom,	r.sQnDevice as sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.tiShelf, ea.tiSpec, ea.sCall, ea.iColorF, ea.iColorB, ea.tiTone, ea.tiToneInt, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
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
--	7.06.5954	+ xu_User_GUID
if	not	exists	(select 1 from dbo.sysindexes where name='xu_User_GUID')
begin
	begin tran
		create unique nonclustered index	xu_User_GUID	on	dbo.tb_User ( gGUID )	where	gGUID is not null	--	all must be unique (including inactive)!!
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a user
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

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
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
revoke	execute				on dbo.pr_User_InsUpd				from [rReader]
go
--	----------------------------------------------------------------------------
--	Returns security details for all users
--	7.06.5961	+ .bLocked	(7983rh uses it)
--	7.06.5960	- .bLocked
--	7.06.5954	+ .gGUID, .utSynched
--	7.06.5785	+ 'Other' @idStfLvl handling
--	7.06.5567	* merged pr_User_GetByUnit -> pr_User_GetAll
--	7.06.5563	+ '@idUser <= 15' to allow returning predifined system user-accounts
--	7.06.5399	* optimized
--	7.05.5182
alter proc		dbo.pr_User_GetAll
(
	@idStfLvl	tinyint		= null	-- null=any, 0=Other, 1=Yel, 2=Ora, 4=Grn
,	@bActive	bit			= null	-- null=any, 0=inactive, 1=active
,	@idUser		int			= null	-- null=any
,	@sStaffID	varchar( 16 )= null	-- null=any
)
	with encryption
as
begin
	set	nocount	on
	select	idUser, sUser, iHash, tiFails, sFrst, sMidd, sLast, sEmail, sDesc
		,	dtLastAct, sStaffID, idStfLvl, sBarCode, bOnDuty, dtDue, sStaff, sUnits, sTeams
		,	gGUID, utSynched
		,	bActive, dtCreated, dtUpdated
		,	cast(case when tiFails=0xFF then 1 else 0 end as bit)	as	bLocked
		from	tb_User		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idStfLvl is null	or	idStfLvl = @idStfLvl	or	@idStfLvl = 0	and	idStfLvl is null)
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
		and		(@sStaffID is null	or	sStaffID = @sStaffID)
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
--	7.06.5963	* cast(GUID as char(38))
--	7.06.5960	+ @tiFails, UTC
--	7.06.5955
create proc		dbo.pr_User_InsUpdAD
(
	@idUser		int					-- user, performing the action
,	@idOper		int			out		-- operand user, acted upon
,	@gGUID		uniqueidentifier	-- AD GUID
,	@dtUpdated	smalldatetime		-- when changed in AD (UTC)
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
			,	@s	varchar( 255 )
			,	@utSynched	smalldatetime		-- last sync with AD

	set	nocount	on
	set	xact_abort	on

	select	@idOper =	idUser,		@utSynched =	utSynched
		from	tb_User with (nolock)
		where	gGUID = @gGUID

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '], u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", a=' + cast(@bActive as varchar) +
				', ' + isnull(cast(@gGUID as char(38)), '?') + ', ' + isnull(convert(varchar, @dtUpdated, 120), '?')
	begin	tran

		if	@idOper = 0		or	@idOper is null
		begin
			insert	tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
					values	( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
			select	@idOper =	scope_identity( )

			select	@s =	'User_IAD( ' + @s + ' ) = ' + cast(@idOper as varchar)
				,	@k =	237
		end
		else
		if	@utSynched < @dtUpdated
		begin
			update	tb_User	set		sUser =		@sUser,		sFrst=	@sFrst,		sMidd=	@sMidd,		sLast=	@sLast
								,	sEmail =	@sEmail,	sDesc=	@sDesc,	utSynched=	getutcdate( )
								,	tiFails =	case when @tiFails = 0xFF then @tiFails else tiFails end
								,	bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'User_UAD( ' + @s + ' )'
				,	@k =	238
		end
		else
			select	@s =	'User_AD( ' + @s + ' ) skiped'					--	already up-to date
				,	@k =	248

		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s

		-- enforce membership in 'Public' role
		if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
			insert	tb_UserRole	( idRole, idUser )
					values		( 1, @idOper )

	commit
end
go
grant	execute				on dbo.pr_User_InsUpdAD				to [rWriter]
--grant	execute				on dbo.pr_User_InsUpdAD				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a staff level
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

	select	@s= 'StfLvl_U( [' + isnull(cast(@idStfLvl as varchar), '?') + '], n="' + @sStfLvl + '", k=' + isnull(cast(@iColorB as varchar), '?') + ' )'

	begin	tran

		update	tbStfLvl	set	sStfLvl =	@sStfLvl,	iColorB =	@iColorB	--,	dtUpdated=	getdate( )
			where	idStfLvl = @idStfLvl

		exec	dbo.pr_Log_Ins	248, @idUser, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Imports a user
--	7.06.5961	+ @sTeams, .gGUID, .utSynched
--	7.05.5121	+ .sUnits
--	7.05.4986	- @bLocked
--	7.05.4976	* .sFirst -> .sFrst, .sMid -> .sMidd
--				- .bLocked
--	7.04.4965
alter proc		dbo.pr_User_Imp
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
,	@bOnDuty	bit
,	@dtDue		smalldatetime
,	@sStaff		varchar( 16 )
,	@sUnits		varchar( 255 )
,	@sTeams		varchar( 255 )
,	@gGUID		uniqueidentifier	-- AD GUID
,	@utSynched	smalldatetime		-- last sync with AD (UTC)
,	@bActive	bit
,	@dtCreated	smalldatetime
,	@dtUpdated	smalldatetime
)
	with encryption, exec as owner
as
begin
--	set	nocount	on

	begin	tran

		if	not exists	(select 1 from tb_User with (nolock) where idUser = @idUser)
		begin
			set identity_insert	dbo.tb_User	on

			insert	tb_User	(  idUser,  sUser,  iHash,  tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc
							,  dtLastAct,  sStaffID,  idStfLvl,  sBarCode,  bOnDuty,  dtDue,  sStaff,  sUnits
							,  sTeams,  gGUID,  utSynched,  bActive,  dtCreated,  dtUpdated )
					values	( @idUser, @sUser, @iHash, @tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc
							, @dtLastAct, @sStaffID, @idStfLvl, @sBarCode, @bOnDuty, @dtDue, @sStaff, @sUnits
							, @sTeams, @gGUID, @utSynched, @bActive, @dtCreated, @dtUpdated )

			set identity_insert	dbo.tb_User	off
		end
		else
			update	tb_User	set	sUser=	@sUser,	iHash=	@iHash,	tiFails =	@tiFails,	sFrst=	@sFrst,	sMidd=	@sMidd
						,	sLast=	@sLast,	sEmail =	@sEmail,	sDesc=	@sDesc,	dtLastAct=	@dtLastAct,	sStaffID =	@sStaffID
						,	idStfLvl =	@idStfLvl,	sBarCode =	@sBarCode,	bOnDuty =	@bOnDuty,	dtDue=	@dtDue
						,	sStaff =	@sStaff,	sUnits =	@sUnits,	sTeams =	@sTeams,	gGUID=	@gGUID
						,	utSynched=	@utSynched,	bActive =	@bActive,	dtCreated=	@dtCreated,	dtUpdated=	@dtUpdated
				where	idUser = @idUser

	commit
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 5963 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	5963, getdate( ), getdate( ),	'?' )

	update	tb_Version	set	dtCreated= '2016-04-29', dtInstall= getdate( )
		,	sVersion= '+call tones, +svc event tracing, +Windows 10 support, *AppSuite, +680 support, *7981ls: log rejected, *790 config, *7983rh, *7985cw, *7982cw, *7980cw'
		where	siBuild = 5963

	update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.6.5963'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.5963 )'
commit
go

checkpoint
go

use [master]
go