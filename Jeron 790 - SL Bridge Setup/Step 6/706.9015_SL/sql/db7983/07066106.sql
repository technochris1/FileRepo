--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
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
--		2016-Jul-11		.6036
--						* stale app-session clean-up
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
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 6106 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.6106', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_SyncAD')
	drop proc	dbo.pr_User_SyncAD
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_User_Login2')
	drop proc	dbo.pr_User_Login2
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prRptStfAssnStaff')
	drop proc	dbo.prRptStfAssnStaff
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
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

	select	@tiMaxAtt =		cast(iValue as tinyint)		from	tb_OptSys	with (nolock)	where	idOption = 2

	select	@sIpAddr =	sIpAddr,	@sMachine=	sMachine
		from	tb_Sess		with (nolock)
		where	idSess = @idSess

	select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@iHass =	iHash,	@bActive =	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType =	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType =	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
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
			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s

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
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s

	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	7.06.5969
create proc		dbo.pr_User_Login2
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
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
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

	select	@sIpAddr =	sIpAddr,	@sMachine=	sMachine
		from	tb_Sess		with (nolock)
		where	idSess = @idSess

	select	@s =	'@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser =	idUser,		@sUser =	sUser,	@bActive =	bActive,	@tiFails =	tiFails,	@sStaff =	sStaff
		from	tb_User		with (nolock)
		where	gGUID = @gGUID												--	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType =	222,	@s =	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

	if	@tiFails = 0xFF			--	locked-out
	begin
		select	@idLogType =	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

	if	@bActive = 0			--	inactive
	begin
		select	@idLogType =	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

/*	if	@iHass <> @iHash		--	wrong pass
	..
*/
	select	@idLogType =	221,	@bAdmin =	0
	if	exists	(select 1 from tb_UserRole where idUser = @idUser and idRole = 2)
		select	@bAdmin =	1

	begin	tran

		update	tb_Sess		set	dtLastAct=	getdate( ),		idUser =	@idUser
			where	idSess = @idSess
		update	tb_User		set	dtLastAct=	getdate( ),		tiFails =	0
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s

	commit
	return	@idLogType
end
go
grant	execute				on dbo.pr_User_Login2				to [rWriter]
grant	execute				on dbo.pr_User_Login2				to [rReader]
go
--	----------------------------------------------------------------------------
--	Imports a role
--	7.06.5983	* @sDesc: vc(16) -> vc(255)
--	7.06.5385
alter proc		dbo.pr_Role_Imp
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
--	----------------------------------------------------------------------------
--	Same as vwDevice, but inner join-ed - only 'rooms' + assigned staff
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
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	tbDevice	d	with (nolock)
	join	tbRoom		r	with (nolock)	on	r.idRoom = d.idDevice
	left join	vwStaff		s4	with (nolock)	on	s4.idUser = r.idUserG
	left join	vwStaff		s2	with (nolock)	on	s2.idUser = r.idUserO
	left join	vwStaff		s1	with (nolock)	on	s1.idUser = r.idUserY
go
--	----------------------------------------------------------------------------
--	790 Devices
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
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('00' + cast(tiJID as varchar), 3)		as sSGJ
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
--	Imports enabled call-texts from tbCfgPri
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
	declare		@s			varchar( 255 )
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

		select	@s =	'Call_Imp( ) +' + cast(@iAdded as varchar) + ', *' + cast(@iRemed as varchar) + ' row(s)'
		exec	dbo.pr_Log_Ins	72, null, null, @s

		update	c	set	c.bActive=	0,	dtUpdated=	getdate( )
			from	tbCall	c
			join	tbCfgPri	p	on	p.siIdx = c.siIdx	and	p.tiFlags & 0x02 = 0
			where	c.bActive > 0

		select	@s =	'Call_Imp( ) -' + cast(@@rowcount as varchar) + ' row(s)'
		exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6017	+ .idShift, .dShift
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_C') and name = 'idShift')
begin
	begin tran
		alter table	dbo.tbEvent_C	add
			idShift		smallint		not null	-- unit's shift at origination
				constraint	fkEventC_Shift		foreign key references	tbShift
				constraint	tdEventC_Shift		default( 0 )
		,	dShift		date			not null	-- shift-started date
				constraint	tdEventC_dShift		default( '00:00' )
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdEventC_Shift')
begin
	begin tran
		update	ec	set	ec.idShift =	sh.idShift
					,	ec.dShift =		case when	sh.tEnd <= sh.tBeg	and	ec.tEvent < sh.tEnd		then	dateadd( dd, -1, ec.dEvent )	else	ec.dEvent	end
			from	dbo.tbEvent_C	ec
			join	dbo.tbShift		sh	on	sh.idUnit = ec.idUnit	and	---	sh.bActive > 0	and		--	for disabled units/shifts too
										(	sh.tBeg < sh.tEnd	and	sh.tBeg <= ec.tEvent	and	ec.tEvent < sh.tEnd
										or	sh.tEnd <= sh.tBeg	and	(sh.tBeg <= ec.tEvent	or	ec.tEvent < sh.tEnd)	)

		alter table	dbo.tbEvent_C	drop constraint tdEventC_Shift
		alter table	dbo.tbEvent_C	drop constraint tdEventC_dShift
	commit
end
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
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

		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_SL( ) ' + cast(@iCount as varchar) + ' rows'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		-- deactivate non-matching units
		update	u	set	u.bActive=	0,	u.dtUpdated =	getdate( )
			from	tbUnit	u
			left join 	tbCfgLoc	l	on l.idLoc = u.idUnit	and	l.tiLvl = 4		-- unit		--	7.06.5854
			where	u.bActive = 1	and	l.idLoc is null
		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_SL( ) -' + cast(@@rowcount as varchar) + ' unit(s)'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		-- deactivate shifts for inactive units
		update	s	set	s.bActive=	0,	s.dtUpdated =	getdate( )
			from	tbShift	s
			join	tbUnit	u	on	u.idUnit = s.idUnit	and	u.bActive = 0
		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_SL( ) -' + cast(@@rowcount as varchar) + ' shift(s)'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

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

					if	@iTrace & 0x02 > 0
					begin
						select	@s= 'Loc_SL( ) [' + cast(@idUnit as varchar) + ']: *' + cast(@@rowcount as varchar) + ' shift(s)'
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
--	7.06.6019	+ .bConfig
--				* fkUser_Level -> fk_User_Level
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'bConfig')
begin
	begin tran
		alter table	dbo.tb_User		add
			bConfig		bit				not null	-- discovery during AD-Sync
				constraint	td_User_Config	default( 1 )
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkUser_Level')
begin
	begin tran
--		exec sp_rename 'tb_User.fkUser_Level',	'fk_User_Level',	'object'	--	--
		alter table	dbo.tb_User		drop constraint fkUser_Level

		alter table	dbo.tb_User		add
			constraint	fk_User_Level	foreign key ( idStfLvl ) references	tbStfLvl
	commit
end
go
--	----------------------------------------------------------------------------
--	Initializes or finalizes AD-Sync
--	7.06.6019
create proc		dbo.pr_User_SyncAD
(
	@bActive	bit					-- 1=initialize, 0=finalize
)
	with encryption
as
begin
	declare		@iTrace		int
		,		@s			varchar( 255 )

	set	nocount	on

--	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s =	'User_SyncAD( ' + cast(@bActive as varchar) + ' ) '

	begin	tran

		if	@bActive > 0													-- start AD-Sync
		begin
			update	tb_User		set		bConfig =	0,	dtUpdated=	getdate( )
				where	gGUID is not null	and	bConfig > 0
			select	@s =	@s + '*' + cast(@@rowcount as varchar) + ' user(s)'
		end
		else																-- finalize
		begin
			update	tb_User		set		bActive =	0,	dtUpdated=	getdate( )
				where	gGUID is not null	and	bConfig = 0		and	bActive > 0
			select	@s =	@s + '-' + cast(@@rowcount as varchar) + ' user(s)'
		end

--		if	@iTrace & 0x01 > 0
			exec	dbo.pr_Log_Ins	238, null, null, @s

	commit
end
go
grant	execute				on dbo.pr_User_SyncAD				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
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
		,		@dt			smalldatetime
		,		@idEvent	int
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

				select	@s =	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
								' inactive events in ' + convert(varchar, getdate() - @dt, 114)
				exec	dbo.pr_Log_Ins	2, null, null, @s
			end

			select	@idEvent =	max(idEvent)								-- get latest idEvent to be removed
				from	tbEvent_S
				where	dEvent <= dateadd(dd, -@tiPurge, @dt)
				and		tiHH <= datepart(hh, @dt)

			if	@idEvent is null											--	7.06.5618
				select	@idEvent =	min(idEvent)							-- get earliest idEvent to stay
					from	tbEvent_S
					where	dateadd(dd, -@tiPurge, @dt) < dEvent

			if	@idEvent > 0												--	7.06.5648
			begin
				delete	from	tbEvent_B
					where	idEvent < @idEvent

				update	tb_OptSys	set	iValue =	@idEvent,	dtUpdated=	@dt		where	idOption = 19
			end

		end

	commit
end
go
--	----------------------------------------------------------------------------
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
alter view		dbo.vwEvent_C
	with encryption
as
select	ec.idEvent, ec.dEvent, ec.tEvent, ec.tiHH, ec.idCall, c.sCall
	,	ec.idUnit, u.sUnit,		ec.idShift, ec.dShift
	,	ec.idRoom, d.cDevice, d.sDevice, d.sDial,	ec.tiBed, cb.cBed, ec.siBed
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
--	7.06.5936	* fix: remove stale sessions
begin
	begin tran
			exec	dbo.pr_Sess_Clr		null
			delete	from	tb_Sess
	commit
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985
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
--	Inserts event [0x84] call status
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
					', s=' + isnull(@cSrcSys,'?') + '-' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ' "' + isnull(@sDevice,'?') + '" :' + isnull(cast(@tiBtn as varchar),'?') +
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(@iAID as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(cast(@tiDstGID as varchar),'?') + '-' + isnull(cast(@tiDstJID as varchar),'?') + '-' +
					isnull(cast(@tiSrcRID as varchar),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
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
--	7.06.6053	* [81] tiLvl:	8 -> 32
begin
	begin tran
		update	dbo.tb_LogType	set	tiLvl=	32	where	idLogType = 81	--	'Lost connection'	--	6.05, 7.02, 7.05.5066, 7.06.6053
	commit
end
go
--	----------------------------------------------------------------------------
--	Translates date/hour filtering condition into tbEvent.idEvent range
--	7.06.6052	+ @tiShift
--	7.06.5409	* @idFrom -> @iFrom, @idUpto -> @iUpto
--	6.05	+ (nolock)
alter proc		dbo.prRpt_XltDtEvRng
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
		from	tbEvent_S	with (nolock)
		where	@dFrom <= dEvent	and	@tFrom <= tiHH

	if	@tiShift <> 0xFF		select	@dUpto =	@dUpto + 1

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
		,		@sNull		varchar( 1 )

	set	nocount	on

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

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

	set	nocount	on

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			select	idCall, lCount, siIdx, tiSpec
				,	case when tiSpec between 7 and 9	then sCall + ' †' else sCall end		as	sCall
				,	case when tiSpec between 7 and 9	then null else tVoTrg end				as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null else tStTrg end				as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	case when tVoAvg is null	then null else lVoOnT*100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	as	fStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall,	min(cp.tiSpec)	as	tiSpec
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	max(ec.tVoice)	as	tVoMax
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tStaff)	as	tStMax
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
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
				,	case when tiSpec between 7 and 9	then sCall + ' †' else sCall end		as	sCall
				,	case when tiSpec between 7 and 9	then null else tVoTrg end				as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null else tStTrg end				as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	case when tVoAvg is null	then null else lVoOnT*100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	as	fStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall,	min(cp.tiSpec)	as	tiSpec
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	max(ec.tVoice)	as	tVoMax
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tStaff)	as	tStMax
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
						from	tbEvent_C	ec	with (nolock)
						join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
						join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
						join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
						where	ec.idEvent	between @iFrom	and @iUpto
						and		ec.tiHH		between @tFrom	and @tUpto
						and		ec.dShift	between @dFrom	and @dUpto
						and		ec.siBed & @siBeds <> 0
						group	by ec.idCall)	t
				order by	siIdx desc
	else
		if	@tiShift = 0xFF
			select	idCall, lCount, siIdx, tiSpec
				,	case when tiSpec between 7 and 9	then sCall + ' †' else sCall end		as	sCall
				,	case when tiSpec between 7 and 9	then null else tVoTrg end				as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null else tStTrg end				as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	case when tVoAvg is null	then null else lVoOnT*100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	as	fStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall,	min(cp.tiSpec)	as	tiSpec
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	max(ec.tVoice)	as	tVoMax
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tStaff)	as	tStMax
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
						from	tbEvent_C	ec	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = ec.idRoom
						join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
						join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
						where	ec.idEvent	between @iFrom	and @iUpto
						and		ec.tiHH		between @tFrom	and @tUpto
						and		ec.siBed & @siBeds <> 0
						group	by ec.idCall)	t
				order by	siIdx desc
		else
			select	idCall, lCount, siIdx, tiSpec
				,	case when tiSpec between 7 and 9	then sCall + ' †' else sCall end		as	sCall
				,	case when tiSpec between 7 and 9	then null else tVoTrg end				as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null else tStTrg end				as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	case when tVoAvg is null	then null else lVoOnT*100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*100/(lCount-lStNul) end	as	fStOnT
				from
					(select	ec.idCall, count(*) as	lCount
						,	min(sc.siIdx)	as	siIdx,	min(sc.sCall)	as	sCall,	min(cp.tiSpec)	as	tiSpec
						,	min(sc.tVoTrg)	as	tVoTrg,	min(sc.tStTrg)	as	tStTrg
						,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
						,	max(ec.tVoice)	as	tVoMax
						,	sum(case when ec.tVoice < sc.tVoTrg	then 1 else 0 end)	as	lVoOnT
						,	sum(case when ec.tVoice is null		then 1 else 0 end)	as	lVoNul
						,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
						,	max(ec.tStaff)	as	tStMax
						,	sum(case when ec.tStaff < sc.tStTrg	then 1 else 0 end)	as	lStOnT
						,	sum(case when ec.tStaff is null		then 1 else 0 end)	as	lStNul
						from	tbEvent_C	ec	with (nolock)
						join	tb_SessDvc	d	with (nolock)	on	d.idDevice = ec.idRoom
						join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
						join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
						join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
						where	ec.idEvent	between @iFrom	and @iUpto
						and		ec.tiHH		between @tFrom	and @tUpto
						and		ec.dShift	between @dFrom	and @dUpto
						and		ec.siBed & @siBeds <> 0
						group	by ec.idCall)	t
				order by	siIdx desc
end
go
--	----------------------------------------------------------------------------
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
alter proc		dbo.prRptCallStatSumGraph
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

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			select	ec.dEvent,	count(*)	as	lCount
		--		,	min(sc.tVoTrg)	as	tVoTrg,		min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
				,	max(ec.tVoice)	as	tVoMax
				,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ec.tStaff)	as	tStMax
				from	tbEvent_C	ec	with (nolock)
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0
				group	by ec.dEvent
		else
			select	ec.dEvent,	count(*)	as	lCount
		--		,	min(sc.tVoTrg)	as	tVoTrg,		min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
				,	max(ec.tVoice)	as	tVoMax
				,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ec.tStaff)	as	tStMax
				from	tbEvent_C	ec	with (nolock)
				join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.dShift	between @dFrom	and @dUpto
				and		ec.siBed & @siBeds <> 0
				group	by ec.dEvent
	else
		if	@tiShift = 0xFF
			select	ec.dEvent,	count(*)	as	lCount
		--		,	min(sc.tVoTrg)	as	tVoTrg,		min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
				,	max(ec.tVoice)	as	tVoMax
				,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ec.tStaff)	as	tStMax
				from	tbEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.siBed & @siBeds <> 0
				group	by ec.dEvent
		else
			select	ec.dEvent,	count(*)	as	lCount
		--		,	min(sc.tVoTrg)	as	tVoTrg,		min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ec.tVoice as datetime) as float) ) as datetime) as time(3) )	as	tVoAvg
				,	max(ec.tVoice)	as	tVoMax
				,	cast( cast( avg( cast( cast(ec.tStaff as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ec.tStaff)	as	tStMax
				from	tbEvent_C	ec	with (nolock)
				join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
				join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx	and	(cp.tiSpec is null	or	cp.tiSpec not in (7,8,9))
				where	ec.idEvent	between @iFrom	and @iUpto
				and		ec.tiHH		between @tFrom	and @tUpto
				and		ec.dShift	between @dFrom	and @dUpto
				and		ec.siBed & @siBeds <> 0
				group	by ec.dEvent
end
go
--	----------------------------------------------------------------------------
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

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
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
		set	a.lCount1= b.lCount1,	a.lVoOnT1= b.lVoOnT1,	a.lVoNul1= b.lVoNul1,	a.lStOnT1= b.lStOnT1,	a.lStNul1= b.lStNul1,
			a.lCount2= b.lCount2,	a.lVoOnT2= b.lVoOnT2,	a.lVoNul2= b.lVoNul2,	a.lStOnT2= b.lStOnT2,	a.lStNul2= b.lStNul2,
			a.lCount3= b.lCount3,	a.lVoOnT3= b.lVoOnT3,	a.lVoNul3= b.lVoNul3,	a.lStOnT3= b.lStOnT3,	a.lStNul3= b.lStNul3,
			a.lCount4= b.lCount4,	a.lVoOnT4= b.lVoOnT4,	a.lVoNul4= b.lVoNul4,	a.lStOnT4= b.lStOnT4,	a.lStNul4= b.lStNul4,
			a.lCount5= b.lCount5,	a.lVoOnT5= b.lVoOnT5,	a.lVoNul5= b.lVoNul5,	a.lStOnT5= b.lStOnT5,	a.lStNul5= b.lStNul5,
			a.lCount6= b.lCount6,	a.lVoOnT6= b.lVoOnT6,	a.lVoNul6= b.lVoNul6,	a.lStOnT6= b.lStOnT6,	a.lStNul6= b.lStNul6,
			a.lCount7= b.lCount7,	a.lVoOnT7= b.lVoOnT7,	a.lVoNul7= b.lVoNul7,	a.lStOnT7= b.lStOnT7,	a.lStNul7= b.lStNul7
		from	#tbRpt2	a	with (nolock)
		join	(select	idCall, tiHH,	-- min(sCall),
					sum(case when iWDay=1 then lCount end)	as	lCount1,
					sum(case when iWDay=1 then lVoOnT end)	as	lVoOnT1,	sum(case when iWDay=1 then lVoNul end)	as	lVoNul1,
					sum(case when iWDay=1 then lStOnT end)	as	lStOnT1,	sum(case when iWDay=1 then lStNul end)	as	lStNul1,
		--			sum(case when iWDay=1 then lVoOut end),
		--			sum(case when iWDay=1 then lStOut end),

					sum(case when iWDay=2 then lCount end)	as	lCount2,
					sum(case when iWDay=2 then lVoOnT end)	as	lVoOnT2,	sum(case when iWDay=2 then lVoNul end)	as	lVoNul2,
					sum(case when iWDay=2 then lStOnT end)	as	lStOnT2,	sum(case when iWDay=2 then lStNul end)	as	lStNul2,

					sum(case when iWDay=3 then lCount end)	as	lCount3,
					sum(case when iWDay=3 then lVoOnT end)	as	lVoOnT3,	sum(case when iWDay=3 then lVoNul end)	as	lVoNul3,
					sum(case when iWDay=3 then lStOnT end)	as	lStOnT3,	sum(case when iWDay=3 then lStNul end)	as	lStNul3,

					sum(case when iWDay=4 then lCount end)	as	lCount4,
					sum(case when iWDay=4 then lVoOnT end)	as	lVoOnT4,	sum(case when iWDay=4 then lVoNul end)	as	lVoNul4,
					sum(case when iWDay=4 then lStOnT end)	as	lStOnT4,	sum(case when iWDay=4 then lStNul end)	as	lStNul4,

					sum(case when iWDay=5 then lCount end)	as	lCount5,
					sum(case when iWDay=5 then lVoOnT end)	as	lVoOnT5,	sum(case when iWDay=5 then lVoNul end)	as	lVoNul5,
					sum(case when iWDay=5 then lStOnT end)	as	lStOnT5,	sum(case when iWDay=5 then lStNul end)	as	lStNul5,

					sum(case when iWDay=6 then lCount end)	as	lCount6,
					sum(case when iWDay=6 then lVoOnT end)	as	lVoOnT6,	sum(case when iWDay=6 then lVoNul end)	as	lVoNul6,
					sum(case when iWDay=6 then lStOnT end)	as	lStOnT6,	sum(case when iWDay=6 then lStNul end)	as	lStNul6,

					sum(case when iWDay=7 then lCount end)	as	lCount7,
					sum(case when iWDay=7 then lVoOnT end)	as	lVoOnT7,	sum(case when iWDay=7 then lVoNul end)	as	lVoNul7,
					sum(case when iWDay=7 then lStOnT end)	as	lStOnT7,	sum(case when iWDay=7 then lStNul end)	as	lStNul7
				from	#tbRpt1		with (nolock)
				group	by idCall, tiHH
				)	b	on	b.idCall = a.idCall	and	b.tiHH = a.tiHH

	set	nocount	off

	select	t.*, sc.siIdx, sc.sCall, sc.tVoTrg, sc.tStTrg	--, f.tVoMax, f.tStMax
		,	dateadd(hh, t.tiHH, '0:0:0')	as	tHour
		,	case when t.lVoNul1 = t.lCount1 then null else t.lVoOnT1*100/(t.lCount1-t.lVoNul1) end	as	fVoOnT1		--,	lVoOnT1*100/lCount1 fVoOnT1
		,	case when t.lStNul1 = t.lCount1 then null else t.lStOnT1*100/(t.lCount1-t.lStNul1) end	as	fStOnT1		--,	lStOnT1*100/lCount1 fStOnT1
		,	case when t.lVoNul2 = t.lCount2 then null else t.lVoOnT2*100/(t.lCount2-t.lVoNul2) end	as	fVoOnT2		--,	lVoOnT2*100/lCount2 fVoOnT2
		,	case when t.lStNul2 = t.lCount2 then null else t.lStOnT2*100/(t.lCount2-t.lStNul2) end	as	fStOnT2		--,	lStOnT2*100/lCount2 fStOnT2
		,	case when t.lVoNul3 = t.lCount3 then null else t.lVoOnT3*100/(t.lCount3-t.lVoNul3) end	as	fVoOnT3		--,	lVoOnT3*100/lCount3 fVoOnT3
		,	case when t.lStNul3 = t.lCount3 then null else t.lStOnT3*100/(t.lCount3-t.lStNul3) end	as	fStOnT3		--,	lStOnT3*100/lCount3 fStOnT3
		,	case when t.lVoNul4 = t.lCount4 then null else t.lVoOnT4*100/(t.lCount4-t.lVoNul4) end	as	fVoOnT4		--,	lVoOnT4*100/lCount4 fVoOnT4
		,	case when t.lStNul4 = t.lCount4 then null else t.lStOnT4*100/(t.lCount4-t.lStNul4) end	as	fStOnT4		--,	lStOnT4*100/lCount4 fStOnT4
		,	case when t.lVoNul5 = t.lCount5 then null else t.lVoOnT5*100/(t.lCount5-t.lVoNul5) end	as	fVoOnT5		--,	lVoOnT5*100/lCount5 fVoOnT5
		,	case when t.lStNul5 = t.lCount5 then null else t.lStOnT5*100/(t.lCount5-t.lStNul5) end	as	fStOnT5		--,	lStOnT5*100/lCount5 fStOnT5
		,	case when t.lVoNul6 = t.lCount6 then null else t.lVoOnT6*100/(t.lCount6-t.lVoNul6) end	as	fVoOnT6		--,	lVoOnT6*100/lCount6 fVoOnT6
		,	case when t.lStNul6 = t.lCount6 then null else t.lStOnT6*100/(t.lCount6-t.lStNul6) end	as	fStOnT6		--,	lStOnT6*100/lCount6 fStOnT6
		,	case when t.lVoNul7 = t.lCount7 then null else t.lVoOnT7*100/(t.lCount7-t.lVoNul7) end	as	fVoOnT7		--,	lVoOnT7*100/lCount7 fVoOnT7
		,	case when t.lStNul7 = t.lCount7 then null else t.lStOnT7*100/(t.lCount7-t.lStNul7) end	as	fStOnT7		--,	lStOnT7*100/lCount7 fStOnT7
	--	,	lVoOut*100/lCount	as	fVoOut,		lStOut*100/lCount	as	fStOut
		from	#tbRpt2		t	with (nolock)
		join	tb_SessCall sc	with (nolock)	on	sc.idCall = t.idCall	and	sc.idSess = @idSess
		order by	sc.siIdx desc, t.tiHH
end
go
--	----------------------------------------------------------------------------
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	c.tVoTrg, c.tStTrg
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	c.tVoTrg, c.tStTrg
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	c.tVoTrg, c.tStTrg
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	c.tVoTrg, c.tStTrg
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

		idUnit		smallint,
		sUnit		varchar( 16 ),
		idRoom		smallint,
		cBed		char( 1 ),
		cDevice		char( 1 ),
		sDevice		varchar( 16 ),
		sDial		varchar( 16 ),
		idUser1		int,
	)

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	select	@sSvc8 =	'STAT',		@sNull =	''
	select	@sSvc4 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 4
	select	@sSvc2 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 2
	select	@sSvc1 =	sStfLvl + ' '	from	tbStfLvl	with (nolock)	where	idStfLvl = 1

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0
	else
		if	@tiShift = 0xFF
			insert	#tbRpt1
				select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.siBed & @siBeds <> 0
		else
			insert	#tbRpt1
				select	ec.idEvent, ec.idUnit, ec.sUnit, ec.idRoom, ec.cBed, ec.cDevice, ec.sDevice, ec.sDial, ec.idUser1	--, ec.dEvent, ec.tEvent, ec.idCall, ec.sCall
					from	vwEvent_C	ec	with (nolock)
					join	tb_SessDvc	sd	with (nolock)	on	sd.idDevice = ec.idRoom
					join	tb_SessShift sh	with (nolock)	on	sh.idShift = ec.idShift	and	sh.idSess = @idSess
					join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ec.idCall	and	sc.idSess = @idSess
					where	ec.idEvent	between @iFrom	and @iUpto
					and		ec.tiHH		between @tFrom	and @tUpto
					and		ec.dShift	between @dFrom	and @dUpto
					and		ec.siBed & @siBeds <> 0

	set	nocount	off

	select	ec.idUnit, ec.sUnit, ec.idRoom, ec.cDevice, ec.sDevice, ec.sDial, e.idParent, e.tParent, e.idOrigin
		,	e.idEvent, e.dEvent, e.tEvent, e.tOrigin,	ec.cBed, e.tiBed, e.idLogType	--, e.idCall
		,	case	when e41.idEvent > 0	then pt.sPcsType	else lt.sLogType	end		as	sEvent
		,	c.siIdx, cp.tiSpec
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
		order	by	ec.idUnit, ec.idRoom, ec.idEvent, e.idEvent
end
go
--	----------------------------------------------------------------------------
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
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
				,	ec.idCall, ec.sCall, cp.siIdx, cp.tiSpec,	sc.tVoTrg, sc.tStTrg,	ec.tVoice, ec.tStaff
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
--	7.06.6053	+ .dShift
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStfCvrg') and name = 'dShift')
begin
	begin tran
		alter table	dbo.tbStfCvrg	add
			dShift		date			not null	-- shift-started date
				constraint	tdStfCvrg_dShift	default( '00:00' )
	commit
end
go
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStfCvrg_dShift')
begin
	begin tran
		update	sc	set	sc.dShift =		case when	sh.tEnd <= sh.tBeg	and	sc.tBeg < sh.tEnd		then	dateadd( dd, -1, sc.dBeg )	else	sc.dBeg	end
			from	dbo.tbStfCvrg	sc
			join	dbo.tbStfAssn	sa	on	sa.idStfAssn = sc.idStfAssn	---	and	sa.bActive > 0	and		--	for inactive assignments too
			join	dbo.tbShift		sh	on	sh.idShift = sa.idShift		---	and	sh.bActive > 0	and		--	for inactive units/shifts too

		alter table	dbo.tbStfCvrg	drop constraint tdStfCvrg_dShift
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
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
		,	@s =	'@' + @@servicename + ' (' + substring(recovery_model_desc, 1, 1) +
					':' + cast(log_reuse_wait as varchar)
		from master.sys.databases
		where	database_id = db_id( )

	select	@tNow =		@dtNow												-- time(0) truncates date, leaving HH:MM:00

	select	@s +=	') ' + cast(sum(cast(size/128 as int)) as varchar)
		from	sys.database_files	with (nolock)
		where	[type] = 0

	select	@s +=	',' + cast(sum(cast(size/128 as int)) as varchar)
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
--	Current (open) staff assignment history (coverage)
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
alter view		dbo.vwStfCvrg
	with encryption
as
select	sa.idStfAssn,	sh.idUnit
	,	sa.idShift, sh.tiIdx as tiShIdx, sh.sShift, sh.tBeg as tShBeg, sh.tEnd as tShEnd
	,	sa.idRoom, d.cDevice, d.sDevice as sRoom, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idUser, s.sStaffID, s.idStfLvl, s.sStfLvl, s.sStaff, s.bOnDuty, s.dtDue
	,	sc.idStfCvrg, sc.dShift, cast(cast(cast(sc.dShift as datetime) + sh.tBeg as float) * 48 as int)	as	iShSeq
	,	sc.dtBeg, sc.dtDue as dtFin	--, sc.dtEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStfCvrg	sc	with (nolock)
	join	tbStfAssn	sa	with (nolock)	on	sa.idStfAssn = sc.idStfAssn
	join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift
	join	vwStaff		s	with (nolock)	on	s.idUser = sa.idUser
	join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
	where	sc.dtEnd is null
go
--	----------------------------------------------------------------------------
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
alter proc		dbo.prRptStfAssn
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
	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed,		a.idStfAssn
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
					order	by h.idUnit, h.tiIdx, a.idRoom, a.tiBed, a.tiIdx
end
go
--	----------------------------------------------------------------------------
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
alter proc		dbo.prRptStfCvrg
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
	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed	--, d.sDevice + isnull(' : ' + b.cBed, '')	as	sRoomBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd	--, a.idUser
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
	else
		if	@tiShift = 0xFF
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
		else
			if	@tiStaff = 0xFF
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser
					,	p.idStfCvrg, p.dShift, cast(cast(cast(p.dShift as datetime) + h.tBeg as float) * 48 as int)	as	iShSeq
					,	a.idRoom, d.cDevice, d.sDevice, b.cBed
					,	a.tiIdx as tiStaff, s.idStfLvl, s.sStfLvl, s.sStaffID, s.sStaff,	p.dtBeg, p.dtEnd
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
	--				where	p.dBeg	between @dFrom and @dUpto
	--					or	p.dEnd	between @dFrom and @dUpto
					where	p.dShift	between @dFrom	and @dUpto
					order	by h.idUnit, a.idRoom, 11, a.tiBed, a.tiIdx, p.idStfCvrg
end
go
--	----------------------------------------------------------------------------
--	7.06.6059	* [7]
begin
	begin tran
		update	dbo.tbReport	set	sRptName =	'Current Staff Assignment'	where	idReport = 7
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns security details for all users
--	7.06.6080	+ .bGUID
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
		,	cast(case when gGUID is null then 0 else 1 end as bit)	as	bGUID
		from	tb_User		with (nolock)
		where	(@bActive is null	or	bActive = @bActive)
		and		(@idStfLvl is null	or	idStfLvl = @idStfLvl	or	@idStfLvl = 0	and	idStfLvl is null)
		and		(@idUser is null	or	idUser = @idUser)
		and		(@idUser <= 15		or	idUser > 15)						--	protect internal accounts
		and		(@sStaffID is null	or	sStaffID = @sStaffID)
end
go
--	----------------------------------------------------------------------------
--	7.06.6088	* [31] reserved
begin
	begin tran
		update	dbo.tb_Option	set	sOption =	'(internal) reserved'	where	idOption = 31		--	7.06.5869,	.6088
		update	dbo.tb_OptSys	set	iValue =	31	where	idOption = 31
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates an AD-user
--	7.06.6088	* " placement in trace
--	7.06.6046	+ set .bConfig when no update is done,
--				* optimize tracing
--	7.06.6019	* set .bConfig
--	7.06.5963	* cast(GUID as char(38))
--	7.06.5960	+ @tiFails, UTC
--	7.06.5955
alter proc		dbo.pr_User_InsUpdAD
(
	@idUser		int					-- user, performing the action
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
			,	@s	varchar( 255 )
			,	@utSynched	smalldatetime		-- (UTC) time of last AD-Sync

	set	nocount	on
	set	xact_abort	on

	select	@idOper =	idUser,		@utSynched =	utSynched
		from	tb_User with (nolock)
		where	gGUID = @gGUID

	select	@s= '[' + isnull(cast(@idOper as varchar), '?') + '] ut=' + isnull(convert(varchar, @utSynched, 120), '?') +
				', ' + isnull(lower(cast(@gGUID as char(38))), '?') + ', u="' + @sUser + '", f="' + isnull(cast(@sFrst as varchar), '?') +
				'", m="' + isnull(cast(@sMidd as varchar), '?') + '", l="' + isnull(cast(@sLast as varchar), '?') +
				'", e=' + isnull(cast(@sEmail as varchar), '?') + ', d="' + isnull(cast(@sDesc as varchar), '?') +
				'", a?=' + cast(@bActive as varchar) + ', ad=' + isnull(convert(varchar, @dtUpdated, 120), '?')
	begin	tran

		if	@idOper = 0		or	@idOper is null								-- user not found
		begin
			insert	tb_User	(  sUser, iHash, tiFails,  sFrst,  sMidd,  sLast,  sEmail,  sDesc,  gGUID,  bActive,  utSynched, sStaff )
					values	( @sUser,	0,	@tiFails, @sFrst, @sMidd, @sLast, @sEmail, @sDesc, @gGUID, @bActive, getutcdate( ), ' ' )
			select	@idOper =	scope_identity( )

			select	@s =	'User_IAD( ' + @s + ' ) = ' + cast(@idOper as varchar)
				,	@k =	237
		end
		else
		if	@utSynched < @dtUpdated											-- AD had a recent change
		begin
			update	tb_User	set		sUser =		@sUser,		sFrst=	@sFrst,		sMidd=	@sMidd,		sLast=	@sLast
								,	sEmail =	@sEmail,	sDesc=	@sDesc,		utSynched=	getutcdate( )
								,	tiFails =	case when @tiFails = 0xFF then @tiFails else tiFails end
								,	bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'User_UAD( ' + @s + ' ) *'
				,	@k =	238
		end
		else																-- user already up-to date
		begin
			update	tb_User	set		bConfig =	1,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idUser = @idOper

			select	@s =	'User_AD( ' + @s + ' )'
				,	@k =	238

		end
		exec	dbo.pr_User_sStaff_Upd	@idOper
		exec	dbo.pr_Log_Ins	@k, @idUser, @idOper, @s

		-- enforce membership in 'Public' role
		if	not exists	(select 1 from tb_UserRole with (nolock) where idRole = 1 and idUser = @idOper)
			insert	tb_UserRole	( idRole, idUser )
					values		( 1, @idOper )

	commit
end
go


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 6106 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	6106, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2016-09-19',	dtInstall=	getdate( )
		,	sVersion =	'+AD support, *7980cw, *798?cs, 798?rh, AppSuite'
		where	siBuild = 6106

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.6106'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.6106 )'
commit
go

checkpoint
go

use [master]
go