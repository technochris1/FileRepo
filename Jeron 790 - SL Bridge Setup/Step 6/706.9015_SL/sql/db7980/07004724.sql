--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
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
--		2012-Nov-16		.4703
--						+ populate tbStaffDvc from tbRtlsBadge during upgrade
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
--						finalized?
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 700 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.00', 18, 0 )

go


if exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStaffAssnDef_GetByShift')
	drop function	dbo.fnStaffAssnDef_GetByShift
if exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetTopByRoom')
	drop function	dbo.fnEventA_GetTopByRoom
if exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetTopByUnit')
	drop function	dbo.fnEventA_GetTopByUnit
if exists	(select 1 from dbo.sysobjects where uid=1 and name='fnUnitMapCell_GetMap')
	drop function	dbo.fnUnitMapCell_GetMap
if exists	(select 1 from dbo.sysobjects where uid=1 and name='fnStaffAssn_GetByShift')
	drop function	dbo.fnStaffAssn_GetByShift
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetDataByUnitMap')
	drop proc	dbo.prMapCell_GetDataByUnitMap
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_GetDataByUnits')
	drop proc	dbo.prRoomBed_GetDataByUnits
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetByUnitMap')
	drop proc	dbo.prMapCell_GetByUnitMap
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_GetByUnit')
	drop proc	dbo.prRoomBed_GetByUnit
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssn_InsFin')
	drop proc	dbo.prStaffAssn_InsFin
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffCover_InsFin')
	drop proc	dbo.prStaffCover_InsFin
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssn_InsUpdDel')
	drop proc	dbo.prStaffAssn_InsUpdDel
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssnDef_Fin')
	drop proc	dbo.prStaffAssnDef_Fin
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffAssn_Fin')
	drop proc	dbo.prStaffAssn_Fin
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prEventC1_Ins')
	drop proc	dbo.prEventC1_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_UpdRoomBeds7980')
	drop proc	dbo.prDevice_UpdRoomBeds7980
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetByID')
	drop proc	dbo.prDevice_GetByID
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Set')
	drop proc	dbo.pr_Module_Set
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Reg')
	drop proc	dbo.pr_Module_Reg
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Module_Act')
	drop proc	dbo.pr_Module_Act
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStaffCover')
	drop view	dbo.vwStaffCover
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwStaffAssn')
	drop view	dbo.vwStaffAssn
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDefLoc_CaUnit')
	drop view	dbo.vwDefLoc_CaUnit
go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvcUnit')
	drop table	dbo.tbStaffDvcUnit
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvc')
	drop table	dbo.tbStaffDvc
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffDvcType')
	drop table	dbo.tbStaffDvcType
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffUnit')
	drop table	dbo.tbStaffUnit
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbStaffLvl')
begin
	if exists	(select 1 from dbo.sysobjects where uid=1 and name='fkRtlsRoom_Level')
		alter table	dbo.tbRtlsRoom
			drop constraint		fkRtlsRoom_Level
	if exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaff_Level')
		alter table	dbo.tbStaff
			drop constraint		fkStaff_Level
	drop table	dbo.tbStaffLvl
end
go


--	----------------------------------------------------------------------------
--	v.7.00	+ [63]
--			+ .dtLastAct
--			* .tiAppType -> .tiModType
--			* .bService -> .bLicense
if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'bLicense')
begin
	begin tran
		alter table	dbo.tb_Module	add
			dtLastAct	datetime null				-- last activity (while started)

		exec sp_rename 'tb_Module.bService', 'bLicense', 'column'
		exec sp_rename 'tb_Module.tiAppType', 'tiModType', 'column'
	commit
end
go
begin tran
	delete	from	tb_Module	where	idModule in (4, 7, 8)
	update	tb_Module	set	tiModType=	1	where	idModule = 1
	update	tb_Module	set	tiModType=	4,	idModule= 91	where	idModule = 2
	update	tb_Module	set	tiModType=	8,	idModule= 92	where	idModule = 3
	update	tb_Module	set	tiModType=	4,	idModule= 72	where	idModule = 5
	update	tb_Module	set	tiModType=	4,	idModule= 21	where	idModule = 6
	update	tb_Module	set	tiModType=	4,	idModule= 71	where	idModule = 9
	update	tb_Module	set	tiModType=	2,	idModule= 73	where	idModule = 11
	update	tb_Module	set	tiModType=	24,	idModule= 111	where	idModule = 12
	update	tb_Module	set	tiModType=	2,	idModule= 121	where	idModule = 13
	update	tb_Module	set	tiModType=	4,	idModule= 61	where	idModule = 14
	update	tb_Module	set	tiModType= 	24,	idModule= 62, sDesc= '7980 Staff Admin Client'	where	idModule = 15

	if not exists	(select 1 from tb_Module where idModule = 21)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  21, 'J7976is', 4, 0, '7976 Integration Service' )
	if not exists	(select 1 from tb_Module where idModule = 61)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  61, 'J7980ps', 4, 0, '7980 PCS/RPP Interface Service' )
	if not exists	(select 1 from tb_Module where idModule = 62)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  62, 'J7980ch', 24, 0, '7980 Staff Admin Client' )
	if not exists	(select 1 from tb_Module where idModule = 63)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  63, 'J7980rh', 8, 0, '7980 Staff Admin Website' )
	if not exists	(select 1 from tb_Module where idModule = 71)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  71, 'J7981ds', 4, 0, '7981 Data Provider Service' )
	if not exists	(select 1 from tb_Module where idModule = 72)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  72, 'J7981ls', 4, 0, '7981 RTLS Interface Service' )
	if not exists	(select 1 from tb_Module where idModule = 73)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  73, 'J7981cw', 2, 0, '7981 RTLS Interface Configurator' )
	if not exists	(select 1 from tb_Module where idModule = 91)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  91, 'J7983ls', 4, 0, '7983 Event Logging Service' )
	if not exists	(select 1 from tb_Module where idModule = 92)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  92, 'J7983rh', 8, 0, '7983 Executive Info System' )
	if not exists	(select 1 from tb_Module where idModule = 111)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	( 111, 'J7985ch', 24, 0, '7985 PC Console Client' )
	if not exists	(select 1 from tb_Module where idModule = 121)
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	( 121, 'J7986cw', 2, 0, '7986 PCC Map Configurator' )
commit
if exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Module') and name = 'bLicense')
begin
	begin tran
		update	tb_Module	set	bLicense= 0		-- reset all
		update	tb_Module	set	bLicense= 1		-- set for DB
			where	idModule = 1
	commit
end
go
--	----------------------------------------------------------------------------
--	Marks a module with latest activity
--	v.7.00
create proc		dbo.pr_Module_Act
(
	@idModule	tinyint				-- module id
)
	with encryption
as
begin

	set	nocount	on
	begin	tran

		update	tb_Module		set	dtLastAct= getdate( )	--, bLicense= 1
			where	idModule = @idModule

	commit
end
go
grant	execute				on dbo.pr_Module_Act				to [rWriter]
grant	execute				on dbo.pr_Module_Act				to [rReader]
go
--	----------------------------------------------------------------------------
--	v.7.00	- td_User_LastAct
--			* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			* .bEnabled -> .bActive
if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'bActive')
begin
	begin tran
		alter table	dbo.tb_User	alter column
			dtLastAct	datetime null				-- last activity (while logged-in)
		alter table	dbo.tb_User	drop
			constraint	td_User_dtLastAct			-- no use for default

		exec sp_rename 'tb_User.bEnabled', 'bActive', 'column'

	---	exec sp_rename 'td_User_dtLastAct', 'td_User_LastAct', 'object'
		exec sp_rename 'td_User_dtCreated', 'td_User_Created', 'object'
		exec sp_rename 'td_User_dtUpdated', 'td_User_Updated', 'object'
	commit
end
go
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='td_User_Active')
begin
	begin tran
		alter table	dbo.tb_User	add
			constraint	td_User_Active	default( 1 )	for	bActive
		,	constraint	td_User_Locked	default( 0 )	for	bLocked
		,	constraint	td_User_Failed	default( 0 )	for	tiFailed
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00	+ .bActive
if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_Role') and name = 'bActive')
begin
	begin tran
		alter table	dbo.tb_Role	add
			bActive		bit not null				-- "deletion" marks inactive
				constraint	td_Role_Active	default( 1 )

		exec sp_rename 'td_Role_dtCreated', 'td_Role_Created', 'object'
		exec sp_rename 'td_Role_dtUpdated', 'td_Role_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='td_UserRole_Created')
begin
	begin tran
		exec sp_rename 'td_UserRole_dtCreated', 'td_UserRole_Created', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='td_OptionSys_Updated')
begin
	begin tran
		exec sp_rename 'td_OptionSys_dtUpdated', 'td_OptionSys_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='td_OptionUsr_Updated')
begin
	begin tran
		exec sp_rename 'td_OptionUsr_dtUpdated', 'td_OptionUsr_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00	+ [62], * [61].tiSource: 2 -> 1
if not exists	(select 1 from dbo.tb_LogType where idLogType = 62)
begin tran
	begin
		update	dbo.tb_LogType	set	tiSource= 1, sLogType= 'Module Installed'
			where	idLogType = 61
	--	insert	dbo.tb_LogType ( idLogType, tiLevel, tiSource, sLogType )	values	( 61,  4, 1, 'Module Installed' )		--	6.05, 7.00
		insert	dbo.tb_LogType ( idLogType, tiLevel, tiSource, sLogType )	values	( 62,  4, 1, 'Module Removed' )			--	7.00

		update	dbo.tb_Log		set	idLogType= 62
			where	idLogType = 61	and	sLog like '%, v= %';
	end
commit
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	v.7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			tb_User: * .bEnabled -> .bActive
--	v.6.05	+ (nolock), transaction
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.02	* tb_Log.idType rearranged
--	v.6.00
alter proc		dbo.pr_User_Login
(
	@sUser		varchar( 32 )		-- login-name, lower-cased
,	@iHass		int					-- calculated password 32-bit hash (Murmur2)
,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
,	@sMachine	varchar( 32 )		-- client computer's name

,	@idUser		smallint out		-- null if attempt failed
,	@sFirst		varchar( 32 ) out	-- first-name
,	@sLast		varchar( 32 ) out	-- last-name
,	@bAdmin		bit out				-- is user member of built-in Admins role?
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
	declare		@iHash		int
--	declare		@bEnabled	bit
	declare		@bActive	bit
	declare		@bLocked	bit
	declare		@idLogType	tinyint
	declare		@tiFailed	tinyint
	declare		@tiMaxAtt	tinyint

	set	nocount	on

	select	@tiMaxAtt= cast(iValue as tinyint)	from	tb_OptionSys	with (nolock)	where	idOption = 2
	select	@s= '''' + isnull( @sUser, '?' ) + ''' @ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

--	select	@idUser= idUser, @iHash= iHash, @bEnabled= bEnabled, @bLocked= bLocked, @tiFailed= tiFailed, @sFirst= sFirst, @sLast= sLast
	select	@idUser= idUser, @iHash= iHash, @bActive= bActive, @bLocked= bLocked, @tiFailed= tiFailed, @sFirst= sFirst, @sLast= sLast
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType=	222
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

	if	@bLocked = 1			--	locked-out
	begin
		select	@idLogType=	224
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

--	if	@bEnabled = 0			--	disabled
	if	@bActive = 0			--	inactive
	begin
		select	@idLogType=	225
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		return	@idLogType
	end

	if	@iHass <> @iHash		--	wrong pass
	begin
		select	@idLogType=	223,	@s=	@s + ', attempt ' + cast( @tiFailed + 1 as varchar )

		begin	tran
			if	@tiFailed < @tiMaxAtt - 1
				update	tb_User		set	tiFailed= tiFailed + 1
					where	idUser = @idUser
			else
			begin
				update	tb_User		set	tiFailed= tiFailed + 1, bLocked= 1
					where	idUser = @idUser
				select	@s=	@s + ', locked-out now'
			end
			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		commit
		return	@idLogType
	end

	select	@idLogType=	221,	@bAdmin=	0
	if	exists(	select 1 from tb_UserRole where idUser = @idUser and idRole = 2 )
		select	@bAdmin=	1

	begin	tran
		update	tb_User		set	tiFailed= 0, dtLastAct= getdate( )
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
if	not exists	(select 1 from sys.default_constraints where name='tb_Sess_Created')
begin
	begin tran
		exec sp_rename 'tb_Sess_dtLastAct', 'tb_Sess_LastAct', 'object'
		exec sp_rename 'tb_Sess_dtCreated', 'tb_Sess_Created', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Marks a session with latest activity
--	v.7.00	+ pr_Module_Act call
--	v.6.00	prRptSess_Act -> pr_Sess_Act, revised
--	v.5.01	encryption added
--			fix for @idRptSess retrieval
--	v.4.02	+ @sSessID for session recovery
--	v.3.01
alter proc		dbo.pr_Sess_Act
(
	@sSessID	varchar( 32 )		-- IIS SessionID
,	@idSess		int out
,	@idUser		smallint out
)
	with encryption
as
begin

	set	nocount	on
	begin	tran

		exec	pr_Module_Act	1
		exec	pr_Module_Act	92		-- v.7.00

		if	@idSess > 0
			update	tb_Sess		set	dtLastAct= getdate( ), @idUser= idUser
				where	idSess = @idSess
		else
			update	tb_Sess		set	dtLastAct= getdate( ), @idUser= idUser, @idSess= idSess
				where	sSessID = @sSessID

		if	@idUser > 0
			update	tb_User		set	dtLastAct= getdate( )
				where	idUser = @idUser
	commit
end
go
--	----------------------------------------------------------------------------
if	not exists	(select 1 from sys.default_constraints where name='tdDefBed_Created')
begin
	begin tran
		exec sp_rename 'tdDefBed_bInUse',    'tdDefBed_InUse', 'object'
		exec sp_rename 'tdDefBed_dtCreated', 'tdDefBed_Created', 'object'
		exec sp_rename 'tdDefBed_dtUpdated', 'tdDefBed_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdDefCallP_Created')
begin
	begin tran
		exec sp_rename 'tdDefCallP_dtCreated', 'tdDefCallP_Created', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdDefCall_Created')
begin
	begin tran
		exec sp_rename 'tdDefCall_bEnabled',  'tdDefCall_Enabled', 'object'
		exec sp_rename 'tdDefCall_tiRouting', 'tdDefCall_Routing', 'object'
		exec sp_rename 'tdDefCall_bOverride', 'tdDefCall_Override', 'object'
		exec sp_rename 'tdDefCall_bActive',   'tdDefCall_Active', 'object'
		exec sp_rename 'tdDefCall_dtCreated', 'tdDefCall_Created', 'object'
		exec sp_rename 'tdDefCall_dtUpdated', 'tdDefCall_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tbDefLoc_Created')
begin
	begin tran
		exec sp_rename 'tbDefLoc_dtCreated', 'tbDefLoc_Created', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Coverage areas and their units
--	v.7.00
create view		dbo.vwDefLoc_CaUnit
	with encryption
as
select ca.idLoc [idCArea], ca.sLoc [sCArea], u.idLoc [idUnit], u.sLoc [sUnit]
	from	tbDefLoc ca		with (nolock)
	inner join	tbDefLoc u	with (nolock)	on	u.idLoc = ca.idParent	and	u.tiLvl = 4
	where	ca.tiLvl = 5
go
grant	select, insert, update			on dbo.vwDefLoc_CaUnit	to [rWriter]
grant	select							on dbo.vwDefLoc_CaUnit	to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a location definition
--	v.7.00	* format idLoc as '000'
--	v.6.05
alter proc		dbo.prDefLoc_Ins
(
	@idLoc		smallint			-- call-index
,	@idParent	smallint			-- parent look-up FK
,	@tiLvl		tinyint				-- level: 0=Facility 1=System 2=Building 3=Floor 4=Unit 5=CoverageArea
,	@cLoc		char( 1 )			-- type:  H=Hospital S=System B=Building F=Floor U=Unit C=CoverageArea
,	@sLoc		varchar( 16 )		-- location name
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
		insert	tbDefLoc	(  idLoc,  idParent,  tiLvl,  cLoc,  sLoc )
				values		( @idLoc, @idParent, @tiLvl, @cLoc, @sLoc )

		if	@iTrace & 0x02 > 0
		begin
			select	@s= 'Loc_I( ' + isnull(right('00' + cast(@idLoc as varchar), 3), '?') + ', p=' + isnull(cast(@idParent as varchar), '?') +
						', l=' + isnull(cast(@tiLvl as varchar), '?') + ', c=' + isnull(@cLoc, '?') + ', n=' + isnull(@sLoc, '?') + ' )'
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00	+ .idShPrv
--			+ tdUnit_Active
if	not exists	(select 1 from sys.default_constraints where name='tdUnit_Created')
begin
	begin tran
		alter table	dbo.tbUnit	add
			idShPrv		smallint null				-- previous shift look-up FK
				constraint	fkUnit_PrevShift	foreign key references tbShift
		,	constraint	tdUnit_Active	default( 1 )	for	bActive

		exec sp_rename 'tdUnit_dtCreated', 'tdUnit_Created', 'object'
		exec sp_rename 'tdUnit_dtUpdated', 'tdUnit_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00	.cDevice -> NOT null, + tdDevice_Code
--			+ .sUnits, fkDevice_Unit
--			.sCodeVer -> vc(16)
--			* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
if exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDevice') and name = 'sCodeVer' and max_length < 16)
begin
--	begin tran
		alter table	dbo.tbDevice	alter column
			sCodeVer	varchar( 16 ) null			-- code version
--	commit
end
go
if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDevice') and name = 'sUnits')
begin
--	begin tran
		alter table	dbo.tbDevice	add
			sUnits		varchar( 512 ) null			-- auto: units, this device belongs to(room)/covers(master)
--	commit
end
go
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='fkDevice_Unit')
begin
	begin tran
		alter table	dbo.tbDevice	add
			constraint	fkDevice_Unit	foreign key (idUnit) references tbUnit
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdDevice_Code')
begin
	begin tran
		update	dbo.tbDevice	set	cDevice= '?'
			where	cDevice is null
		alter table	dbo.tbDevice	alter column
			cDevice		char( 1 ) not null
		alter table	dbo.tbDevice	add
			constraint	tdDevice_Code	default( '?' )	for	cDevice
	commit
end
go
--	----------------------------------------------------------------------------
--	Devices
--	v.7.00	+ .sUnits
--			+ .sCodeVer
--	v.6.05	+ (nolock)
--	v.6.04	+ .sQnDevice, .siBeds, .sBeds, .idUnit
--			* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	v.6.03	+ .cSGJ, + .sFnDevice
--	v.6.02
alter view		dbo.vwDevice
	with encryption
as
select	idDevice, idParent, cSys, tiGID, tiJID, tiRID, iAID, tiStype, cDevice, sDevice, sDial, sCodeVer, idUnit, sUnits, siBeds, sBeds
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2) + '-' + right('0' + cast(tiRID as varchar), 2)	[sSGJR]
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		[sSGJ]
	,	'[' + cDevice + '] ' + sDevice		[sQnDevice]
	,	'[' + cDevice + '] ' + sDevice + case when sDial is null then '' else ' (' + sDial + ')' end	[sFnDevice]
	,	bActive, dtCreated, dtUpdated
	from	tbDevice	with (nolock)
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices
--	v.7.00	* preset .idUnit for new rooms
--			* reset tdDevice.idEvent to null
--			+ .sUnits
--			+ @sCodeVer
--	v.6.07	- device matching by name
--	v.6.05	tracing reclassified 41 -> 74
--			+ (nolock)
--	v.6.04	+ @idDevice out
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.02	tdDevice.dtLastUpd -> .dtUpdated
--			* .tiRID is never NULL now - added download of all stations
--			+ .cSys, xuDevice_GJR -> xuDevice_SGJR
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--	v.5.01	encryption added
--	v.4.01
--	v.2.03	@tiRID ignored
--			+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--	v.2.02
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

,	@idDevice	smallint out		-- output: inserted/updated idDevice	--	v.6.04
)
	with encryption
as
begin
	declare		@idParent	smallint
	declare		@iTrace		int
	declare		@s			varchar( 255 )
	declare		@idUnit		smallint
	declare		@sUnits		varchar( 255 )
	
	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	select	@s=	'Dvc_IU( s=' + @cSys + ', g=' + cast(@tiGID as varchar) + ', j=' + cast(@tiJID as varchar) + ', r=' + cast(@tiRID as varchar) +
				', aid=' + cast(@iAID as varchar) + ', t=' + cast(@tiStype as varchar) + ', c=' + isnull(@cDevice,'?') + ', n=' + @sDevice +
				', d=' + isnull(@sDial,'?') + ', v=' + isnull(@sCodeVer,'?') + ', pCA0=' + isnull(cast(@tiPriCA0 as varchar),'?') + ' )'

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

	select	@s=	@s + '  id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')

	begin	tran

		select	@sUnits=	''

	/*	if	(@tiPriCA0 is not null	and	@tiPriCA0 = 255)	or	(@tiPriCA1 is not null	and	@tiPriCA1 = 255)	or
			(@tiPriCA2 is not null	and	@tiPriCA2 = 255)	or	(@tiPriCA3 is not null	and	@tiPriCA3 = 255)	or
			(@tiPriCA4 is not null	and	@tiPriCA4 = 255)	or	(@tiPriCA5 is not null	and	@tiPriCA5 = 255)	or
			(@tiPriCA6 is not null	and	@tiPriCA6 = 255)	or	(@tiPriCA7 is not null	and	@tiPriCA7 = 255)	or
			(@tiAltCA0 is not null	and	@tiAltCA0 = 255)	or	(@tiAltCA1 is not null	and	@tiAltCA1 = 255)	or
			(@tiAltCA2 is not null	and	@tiAltCA2 = 255)	or	(@tiAltCA3 is not null	and	@tiAltCA3 = 255)	or
			(@tiAltCA4 is not null	and	@tiAltCA4 = 255)	or	(@tiAltCA5 is not null	and	@tiAltCA5 = 255)	or
			(@tiAltCA6 is not null	and	@tiAltCA6 = 255)	or	(@tiAltCA7 is not null	and	@tiAltCA7 = 255)
	*/	if	@tiPriCA0 = 0xFF	or	@tiPriCA1 = 0xFF	or		@tiPriCA2 = 0xFF	or	@tiPriCA3 = 0xFF	or
			@tiPriCA4 = 0xFF	or	@tiPriCA5 = 0xFF	or		@tiPriCA6 = 0xFF	or	@tiPriCA7 = 0xFF	or
			@tiAltCA0 = 0xFF	or	@tiAltCA1 = 0xFF	or		@tiAltCA2 = 0xFF	or	@tiAltCA3 = 0xFF	or
			@tiAltCA4 = 0xFF	or	@tiAltCA5 = 0xFF	or		@tiAltCA6 = 0xFF	or	@tiAltCA7 = 0xFF
		begin
			declare		cur		cursor fast_forward for
				select	idLoc
					from	tbDefLoc	with (nolock)
					where	tiLvl = 4	-- unit

			open	cur
			fetch next from	cur	into	@idUnit
			while	@@fetch_status = 0
			begin
				select	@sUnits=	@sUnits + ',' + cast(@idUnit as varchar)

				fetch next from	cur	into	@idUnit
			end
			close	cur
			deallocate	cur

			if	len(@sUnits) > 0
				select	@sUnits= substring(@sUnits, 2, len(@sUnits)-1)
		end
		else							-- specific units
		begin
			create table	#tbUnit
			(
				idUnit		smallint
			)

			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA0
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA1
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA2
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA3
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA4
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA5
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA6
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiPriCA7

			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA0
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA1
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA2
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA3
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA4
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA5
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA6
			insert	#tbUnit		select	idParent	from	tbDefLoc	with (nolock)	where	idLoc = @tiAltCA7

			declare		cur		cursor fast_forward for
				select	distinct	idUnit
					from	#tbUnit		with (nolock)
					order	by	1

			open	cur
			fetch next from	cur	into	@idUnit
			while	@@fetch_status = 0
			begin
				select	@sUnits=	@sUnits + ',' + cast(@idUnit as varchar)

				fetch next from	cur	into	@idUnit
			end
			close	cur
			deallocate	cur

			if	len(@sUnits) > 0
				select	@sUnits= substring(@sUnits, 2, len(@sUnits)-1)
		end
		if	len(@sUnits) = 0
			select	@sUnits=	null

		if	@idDevice is null
		begin
			if	@cDevice = 'R'
				select	@idUnit= idParent							-- set room's current unit to primary CA's
					from	tbDefLoc	with (nolock)
					where	idLoc = @tiPriCA0
			else
				select	@idUnit= null

			insert	tbDevice	(  idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial,  sCodeVer,  idUnit,  sUnits
							,	 tiPriCA0,  tiPriCA1,  tiPriCA2,  tiPriCA3,  tiPriCA4,  tiPriCA5,  tiPriCA6,  tiPriCA7
							,	 tiAltCA0,  tiAltCA1,  tiAltCA2,  tiAltCA3,  tiAltCA4,  tiAltCA5,  tiAltCA6,  tiAltCA7 )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial, @sCodeVer, @idUnit, @sUnits
							,	@tiPriCA0, @tiPriCA1, @tiPriCA2, @tiPriCA3, @tiPriCA4, @tiPriCA5, @tiPriCA6, @tiPriCA7
							,	@tiAltCA0, @tiAltCA1, @tiAltCA2, @tiAltCA3, @tiAltCA4, @tiAltCA5, @tiAltCA6, @tiAltCA7 )
			select	@idDevice=	scope_identity( )
			select	@s=	@s + '  INS: id=' + cast(@idDevice as varchar)
		end
		else
		begin
			if	@iAID > 0
				update	tbDevice	set		iAID= @iAID				--	bActive= 1, dtUpdated= getdate( ),	-- no point repeating
					where	idDevice = @idDevice	and	iAID is null

			update	tbDevice	set		idParent= @idParent			--	bActive= 1, dtUpdated= getdate( ),	-- no point repeating
				,	cSys= @cSys, tiGID= @tiGID, tiJID= @tiJID, tiRID= @tiRID
				where	idDevice = @idDevice	and	iAID = @iAID

			update	tbDevice	set		bActive= 1, dtUpdated= getdate( ), idEvent= null					-- 'cause this executes always
				,	tiStype= @tiStype,	cDevice= @cDevice,	sDevice= @sDevice,	sDial= @sDial,	sCodeVer= @sCodeVer,	sUnits= @sUnits
				,	tiPriCA0= @tiPriCA0, tiPriCA1= @tiPriCA1, tiPriCA2= @tiPriCA2, tiPriCA3= @tiPriCA3
				,	tiPriCA4= @tiPriCA4, tiPriCA5= @tiPriCA5, tiPriCA6= @tiPriCA6, tiPriCA7= @tiPriCA7
				,	tiAltCA0= @tiAltCA0, tiAltCA1= @tiAltCA1, tiAltCA2= @tiAltCA2, tiAltCA3= @tiAltCA3
				,	tiAltCA4= @tiAltCA4, tiAltCA5= @tiAltCA5, tiAltCA6= @tiAltCA6, tiAltCA7= @tiAltCA7
				where	idDevice = @idDevice

	--		select	@s=	@s + '  UPD'
		end

		if	@iTrace & 0x04 > 0
			exec	pr_Log_Ins	74, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Deactivates all devices behind a given gateway
--	v.7.00	* format @tiGID as '000'
--			trace: Dvc_UIbG -> Dvc_UAbG
--	v.6.05
alter proc		dbo.prDevice_UpdActBySysGID
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
		update	tbDevice	set	bActive= 0, dtUpdated= getdate( )
			where	cSys = @cSys	and	tiGID = @tiGID	and	bActive = 1
		select	@s= 'Dvc_UAbG( s=' + isnull(@cSys, '?') + ', g=' + isnull(right('00' + cast(@tiGID as varchar), 3), '?') + ' ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns requested device/room/master's details
--	v.7.00
create proc		dbo.prDevice_GetByID
(
	@idDevice	smallint			-- device (PK)
,	@bActive	bit= null			-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
--	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, d.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint) [tiSwing], d.sUnits						-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		where	(@bActive is null	or	d.bActive = @bActive)
		and		d.idDevice = @idDevice
--	-	order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
grant	execute				on dbo.prDevice_GetByID				to [rReader]
grant	execute				on dbo.prDevice_GetByID				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns devices/rooms/masters for given unit
--	v.7.00	+ .sBeds, re-order output
--			* @idUnit -> @sUnits, output: .bSwing -> tiSwing
--			* @idUnit is null == all units
--			+ @bActive
--			output: idRoom -> idDevice
--	v.6.05	+ (nolock)
--	v.6.04	prDevice_GetRooms -> prDevice_GetByUnit, + @tiStype->@tiKind
--			+ .bSwing to the output
--			@idLoc -> @idUnit
--	v.6.02	* fast_forward
--			+ .bActive, .dtCreated, .dtUpdated to the output
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--	v.5.01	encryption added
--	v.2.03
alter proc		dbo.prDevice_GetByUnit
(
	@sUnits		varchar( 255 )		-- comma-separated idUnit's | '*'=all
,	@tiKind		tinyint				-- 0=any, 1=rooms, 2=masters
,	@bActive	bit= null			-- null=any, 0=inactive, 1=active
)
	with encryption
as
begin
	declare		@i			smallint
	declare		@s			varchar( 16 )

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
			select	@i=	charindex( ',', @sUnits )

			if	@i = 0
				select	@s=	@sUnits
			else
				select	@s=	substring( @sUnits, 1, @i - 1 )

			select	@s=	'%' + @s + '%'
	---		print	@s

			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					left outer join	#tbDevice t	with (nolock)	on	t.idDevice = d.idDevice
					where	(@bActive is null	or	d.bActive = @bActive)
					and		(@tiKind = 0														--	any
						or	(@tiKind = 1	and	d.tiStype between 4 and 7	and	d.tiRID = 0)	--	room controllers
						or	(@tiKind = 2	and	d.tiStype between 8 and 11	and	d.tiRID = 0))	--	masters
					and		d.sUnits like @s
					and		t.idDevice is null

	---		select * from #tbDevice

			if	@i = 0
				break
			else
				select	@sUnits=	substring( @sUnits, @i + 1, len( @sUnits ) - @i )
		end
	end
	else		-- request for all units
	begin
			insert	#tbDevice	--(  idDevice )
				select	d.idDevice
					from	tbDevice d	with (nolock)
					where	(@bActive is null	or	bActive = @bActive)
					and		(@tiKind = 0														--	any
						or	(@tiKind = 1	and	d.tiStype between 4 and 7	and	d.tiRID = 0)	--	room controllers
						or	(@tiKind = 2	and	d.tiStype between 8 and 11	and	d.tiRID = 0))	--	masters
	end

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, d.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint) [tiSwing], d.sUnits
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		inner join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Staff levels
--	v.7.00
create table	dbo.tbStaffLvl
(
	idStaffLvl	tinyint not null			-- type look-up PK
		constraint	xpStaffLvl	primary key clustered

,	sStaffLvl	varchar( 16 ) not null		-- type text
,	iColorF		int null					-- foreground color (ARGB) - text
)
go
grant	select							on dbo.tbStaffLvl		to [rWriter]
grant	select							on dbo.tbStaffLvl		to [rReader]
go
begin tran
---	if not exists	(select 1 from dbo.tbStaffLvl where idStaffLvl > 0)
	begin
		insert	dbo.tbStaffLvl ( idStaffLvl, iColorF, sStaffLvl )	values	(  4,  0xFF00FF00, 'RN' )
		insert	dbo.tbStaffLvl ( idStaffLvl, iColorF, sStaffLvl )	values	(  2,  0xFFFF8040, 'CNA' )
		insert	dbo.tbStaffLvl ( idStaffLvl, iColorF, sStaffLvl )	values	(  1,  0xFFFFFF00, 'Aide' )
	end
commit
go
if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbStaff') and name = 'idStaffLvl')
begin
	begin tran
	--		idStaffLvl	tinyint not null			-- 4=RN, 2=CNA, 1=Aide, ..
		exec sp_rename 'tbStaff.tiPtype', 'idStaffLvl', 'column'

		exec sp_rename 'tdStaff_dtCreated', 'tdStaff_Created', 'object'
		exec sp_rename 'tdStaff_dtUpdated', 'tdStaff_Updated', 'object'
	commit
end
go
if not exists	(select 1 from dbo.sysobjects where uid=1 and name='tdStaff_Active')
begin
	begin tran
		alter table	dbo.tbStaff		add
			constraint	fkStaff_Level	foreign key (idStaffLvl) references tbStaffLvl
		,	constraint	tdStaff_Active	default( 1 ) for bActive
	commit
end
go
--	----------------------------------------------------------------------------
--	Staff definitions
--	v.7.00	tbStaff.tiPtype -> .idStaffLvl
--	v.6.05	+ (nolock)
--			+ tbStaff.sStaff (new), - .sFull
--	v.6.03	* .sStaff -> sFqName, + .sStaff
--	v.6.03	+ .sStaff
--	v.6.02
alter view		dbo.vwStaff
	with encryption
as
select	s.idStaff, s.lStaffID, s.sFirst, s.sMid, s.sLast, s.idUser, s.idStaffLvl, l.sStaffLvl		---, sFull [sPtype]
	,	s.sStaff, l.sStaffLvl + ' (' + cast(lStaffID as varchar) + ') ' + s.sStaff [sFqName]
	,	s.bActive, s.dtCreated, s.dtUpdated
	from	tbStaff	s	with (nolock)
		inner join	tbStaffLvl	l	with (nolock)	on	l.idStaffLvl = s.idStaffLvl
/*	(	select	idStaff, lStaffID, sStaff, sFirst, sMid, sLast, idUser, tiPtype
			,	case when tiPtype = 4 then 'RN'
					when tiPtype = 2 then 'CNA'
					when tiPtype = 1 then 'Aide' else '?' end [sPtype]
		---	,	ltrim( isnull( sFirst, '' ) + ' ' ) + ltrim( isnull( sMid, '' ) + ' ' ) + isnull( sLast, '' ) [sFull]
			,	bActive, dtCreated, dtUpdated
			from	tbStaff		with (nolock)
	)	s
*/
go
--	----------------------------------------------------------------------------
--	Inserts or updates staff
--	v.7.00	tbStaff.tiPtype -> .idStaffLvl
--	v.6.05	fixed tbStaff insertion (required .sStaff not supplied) and prStaff_sStaff_Upd call
--			+ (nolock), + .sStaff
--	v.6.02
--	v.6.01
alter proc		dbo.prStaff_InsUpdDel
(
	@idStaff	int							-- internal
,	@bActive	bit							-- "deletion" marks inactive
,	@lStaffID	bigint						-- external Staff ID
--,	@sStaffID	varchar( 16 )				-- external Staff ID
--,	@tiPtype	tinyint						-- 4=RN, 2=CNA, 1=Aide, ..
,	@idStaffLvl	tinyint						-- 4=RN, 2=CNA, 1=Aide, ..
,	@sFirst		varchar( 16 )				-- first name
,	@sMid		varchar( 16 )				-- middle name
,	@sLast		varchar( 16 )				-- last name
,	@idUser		smallint					-- user look-up FK
,	@iStamp		int							-- row-version counter
)
	with encryption
as
begin
	set	nocount	on
	if	@idStaff is null	--	and	len(@sStaffID) > 0
		select	@idStaff= idStaff		from	tbStaff		with (nolock)
				where	bActive >0	and	lStaffID = @lStaffID

	begin	tran

		if	@bActive > 0
		begin
			if	@idStaff is null
			begin
	--			insert	tbStaff	(  bActive,  lStaffID,  tiPtype,  sFirst,  sMid,  sLast,  idUser,  iStamp, sStaff )
	--					values	( @bActive, @lStaffID, @tiPtype, @sFirst, @sMid, @sLast, @idUser, @iStamp, '?' )
				insert	tbStaff	(  bActive,  lStaffID,  idStaffLvl,  sFirst,  sMid,  sLast,  idUser,  iStamp, sStaff )
						values	( @bActive, @lStaffID, @idStaffLvl, @sFirst, @sMid, @sLast, @idUser, @iStamp, '?' )
				select	@idStaff=	scope_identity( )
			end
			else
				update	tbStaff	set
	--					bActive= @bActive, lStaffID= @lStaffID, tiPtype= @tiPtype, sFirst= @sFirst,
						bActive= @bActive, lStaffID= @lStaffID, idStaffLvl= @idStaffLvl, sFirst= @sFirst,
						sMid= @sMid, sLast= @sLast, idUser= @idUser, iStamp= @iStamp, dtUpdated= getdate( )
					where	idStaff = @idStaff

			exec	prStaff_sStaff_Upd	@idStaff, null
		end
		else
		begin
			--	TODO:	deactivate and close everything associated with that Staff

				update	tbStaff	set
						bActive= @bActive, dtUpdated= getdate( )
					where	idStaff = @idStaff
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Staff-Unit membership
--	v.7.00
create table	dbo.tbStaffUnit
(
	idStaff		int not null
		constraint	fkStaffUnit_Staff	foreign key references tbStaff
,	idUnit		smallint not null
		constraint	fkStaffUnit_Unit	foreign key references tbUnit

,	dtCreated	smalldatetime not null		-- internal: record creation
		constraint	tdStaffUnit_Created	default( getdate( ) )

,	constraint	xpStaffUnit		primary key clustered ( idStaff, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tbStaffUnit		to [rWriter]
grant	select							on dbo.tbStaffUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Staff device types
--	v.7.00
create table	dbo.tbStaffDvcType
(
	idStaffDvcType	tinyint not null			-- type look-up PK
		constraint	xpStaffDvcType	primary key clustered

,	sStaffDvcType	varchar( 16 ) not null		-- type text
)
go
grant	select							on dbo.tbStaffDvcType	to [rWriter]
grant	select							on dbo.tbStaffDvcType	to [rReader]
go
begin tran
---	if not exists	(select 1 from dbo.tbStaffDvcType where idStaffDvcType > 0)
	begin
		insert	dbo.tbStaffDvcType ( idStaffDvcType, sStaffDvcType )	values	(  1, 'Badge' )
		insert	dbo.tbStaffDvcType ( idStaffDvcType, sStaffDvcType )	values	(  2, 'Pager' )
		insert	dbo.tbStaffDvcType ( idStaffDvcType, sStaffDvcType )	values	(  3, 'Phone' )
	end
commit
go
--	----------------------------------------------------------------------------
--	Staff device definitions (Phone/Pager/Badge)
--	v.7.00
create table	dbo.tbStaffDvc
(
	idStaffDvc	int not null	identity( 65536, 1 )	--	1..65535 are reserved for RTLS badges
		constraint	xpStaffDvc	primary key clustered

,	idStaffDvcType	tinyint not null		-- device type
		constraint	fkStaffDvc_Type		foreign key references tbStaffDvcType
,	sStaffDvc	varchar( 16 ) not null		-- full name
,	idStaff		int null					-- who is this device currently assigned to?
		constraint	fkStaffDvc_Staff	foreign key references tbStaff

,	sDial		varchar( 16 ) null			-- dialable number (digits only), null for badges
,	tiLines		tinyint null				-- lines per message
,	tiChars		tinyint null				-- characters per line
,	bGroup		bit not null				-- is this a group device?
		constraint	tdStaffDvc_Group	default( 0 )
,	bTechno		bit not null				-- send technical messages?
		constraint	tdStaffDvc_Techno	default( 0 )

,	bActive		bit not null				-- currently active?
		constraint	tdStaffDvc_Active	default( 1 )
,	dtCreated	smalldatetime not null		-- internal: record creation
		constraint	tdStaffDvc_Created	default( getdate( ) )
,	dtUpdated	smalldatetime not null		-- internal: last modified
		constraint	tdStaffDvc_Updated	default( getdate( ) )
)
create unique nonclustered index	xuStaffDvc_Active	on dbo.tbStaffDvc ( sStaffDvc ) where bActive > 0
go
grant	select, insert, update			on dbo.tbStaffDvc		to [rWriter]
grant	select							on dbo.tbStaffDvc		to [rReader]
go
--	----------------------------------------------------------------------------
--	StaffDvc-Unit membership
--	v.7.00
create table	dbo.tbStaffDvcUnit
(
	idStaffDvc	int not null
		constraint	fkStaffDvcUnit_StaffDvc	foreign key references tbStaffDvc
,	idUnit		smallint not null
		constraint	fkStaffDvcUnit_Unit	foreign key references tbUnit

,	dtCreated	smalldatetime not null		-- internal: record creation
		constraint	tdStaffDvcUnit_Created	default( getdate( ) )

,	constraint	xpStaffDvcUnit	primary key clustered ( idStaffDvc, idUnit )
)
go
grant	select, insert, update, delete	on dbo.tbStaffDvcUnit	to [rWriter]
grant	select							on dbo.tbStaffDvcUnit	to [rReader]
go
if	not exists	(select 1 from sys.default_constraints where name='tdRoomStaff_Updated')
begin
	begin tran
		exec sp_rename 'tdRoomStaff_dtUpdated', 'tdRoomStaff_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdDoctor_Active')
begin
	begin tran
		exec sp_rename 'tdDoctor_bActive', 'tdDoctor_Active', 'object'
		exec sp_rename 'tdDoctor_dtCreated', 'tdDoctor_Created', 'object'
		exec sp_rename 'tdDoctor_dtUpdated', 'tdDoctor_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdEventA_Active')
begin
	begin tran
		exec sp_rename 'tdEventA_bActive', 'tdEventA_Active', 'object'
		exec sp_rename 'tdEventA_bAudio', 'tdEventA_Audio', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
--	v.7.00
create function		dbo.fnEventA_GetTopByUnit
(
	@idUnit		smallint					-- unit look-up FK
)
	returns table
	with encryption
as
return
	select	top	1	*
		from	vwEvent_A	with (nolock)
		where	bActive >0	and	idUnit = @idUnit
		order	by	siIdx desc
				,	tElapsed				-- not desc: later event trumps
go
grant	select				on dbo.fnEventA_GetTopByUnit		to [rWriter]
grant	select				on dbo.fnEventA_GetTopByUnit		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given room (identified by Sys-G-J)
--	v.7.00
create function		dbo.fnEventA_GetTopByRoom
(
	@cSys		char( 1 )					-- system ID
,	@tiGID		tinyint						-- G-ID - gateway
,	@tiJID		tinyint						-- J-ID - J-bus
)
	returns table
	with encryption
as
return
	select	top	1	*
		from	vwEvent_A	with (nolock)
		where	bActive >0	and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID
		order	by	siIdx desc
				,	tElapsed				-- not desc: later event trumps
go
grant	select				on dbo.fnEventA_GetTopByRoom		to [rWriter]
grant	select				on dbo.fnEventA_GetTopByRoom		to [rReader]
go
--	----------------------------------------------------------------------------
--	Removes expired active events
--	v.7.00	+ pr_Module_Act call
--	v.6.05	* reset tbDevice.idEvent
--			* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--			tracing
--	v.6.04	+ removal from tbRoomBed.idEvent
--			+ removal of healing 84s
--	v.6.03	+ removal of inactive events
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.01
alter proc		dbo.prEvent_A_Exp
(
	@tiPurge	tinyint	= 0			-- 0=don't remove any events
									-- N=remove healing 84s older than N days (cascaded)
									-- 255=remove all inactive events from [tbEvent*] (cascaded)
									--	[select iValue from tb_OptionSys where idOption=7]
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
	declare		@dt		datetime
	declare		@i		int

	set	nocount	on

	begin	tran

		exec	pr_Module_Act	1

		update	d	set	d.idEvent= null				--	reset tbDevice.idEvent
			from	tbDevice	d
			inner join	tbEvent_A	ea	on	ea.idEvent = d.idEvent
			where	ea.dtExpires < getdate( )
		delete	from	tbEvent_A	where	dtExpires < getdate( )
		delete	from	tbEvent_P	where	dtExpires < getdate( )

		--	remove children whose parent no longer exists
		delete	a	from	tbEvent_A a
			left outer join	tbEvent_P p	on	p.cSys = a.cSys	and	p.tiGID = a.tiGID	and	p.tiJID = a.tiJID
---			left outer join	tbEvent_P p	on	p.cSrcSys = a.cSrcSys	and	p.tiSrcGID = a.tiSrcGID	and	p.tiSrcJID = a.tiSrcJID
			where	p.idEvent is null

		--	remove parents that do not have any children
	/*	delete	from	tbEvent_P					--	WHERE col IN (SELECT ..) == INNER JOIN (SELECT ..) !!
			where	idEvent in
			(select	p.idEvent
				from	tbEvent_P p
				left outer join	tbEvent_A a	on	a.cSrcSys = p.cSrcSys	and	a.tiSrcGID = p.tiSrcGID	and	a.tiSrcJID = p.tiSrcJID
				group	by p.idEvent
				having	count(a.idEvent) = 0)	*/
		delete	p	from	tbEvent_P p				--	better statement, though same execution plan
			inner join
			(select	p.idEvent
				from	tbEvent_P p
				left outer join	tbEvent_A a	on	a.cSys = p.cSys	and	a.tiGID = p.tiGID	and	a.tiJID = p.tiJID
---				left outer join	tbEvent_A a	on	a.cSrcSys = p.cSrcSys	and	a.tiSrcGID = p.tiSrcGID	and	a.tiSrcJID = p.tiSrcJID
				group	by p.idEvent
				having	count(a.idEvent) = 0) t		on	t.idEvent = p.idEvent
	---	delete	p	from	tbEvent_P p				--	! wrong way to do it !
	---		left outer join	tbEvent_A a	on	a.cSrcSys = p.cSrcSys	and	a.tiSrcGID = p.tiSrcGID	and	a.tiSrcJID = p.tiSrcJID
	---			and	a.idEvent is null

		update	rb	set	rb.idEvent=	null, tiSvc= null
			from	tbRoomBed rb
			left outer join	tbEvent_A a	on	a.idEvent = rb.idEvent
			where	a.idEvent is null	or	a.bActive = 0

		if	@tiPurge > 0
		begin
			select	@dt=	getdate( )				--	mark starting time

			if	@tiPurge = 255						--	remove all inactive events
			begin
				update	t	set	t.idVoice= null
					from	tbEvent_T t
					left outer join	tbEvent_A a	on	a.idEvent = t.idVoice
					where	a.idEvent is null
				update	t	set	t.idStaff= null
					from	tbEvent_T t
					left outer join	tbEvent_A a	on	a.idEvent = t.idStaff
					where	a.idEvent is null

				update	c	set	c.idVoice= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idVoice
					where	a.idEvent is null
				update	c	set	c.idStaff= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idStaff
					where	a.idEvent is null
				update	c	set	c.idRn= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idRn
					where	a.idEvent is null
				update	c	set	c.idCna= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idCna
					where	a.idEvent is null
				update	c	set	c.idAide= null
					from	tbEvent_C c
					left outer join	tbEvent_A a	on	a.idEvent = c.idAide
					where	a.idEvent is null

				delete	e	from	tbEvent e
					left outer join	tbEvent_A a	on	a.idEvent = e.idEvent
					where	a.idEvent is null
				select	@i=	@@rowcount

				delete	e	from	tbEvent e
					left outer join	tbEvent_P p	on	p.idEvent = e.idEvent
					where	p.idEvent is null

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount + @i as varchar) +
							' inactive rows in ' + convert(varchar, getdate() - @dt, 114)
				exec	pr_Log_Ins	2, null, null, @s
			end
			else	--	if	@tiPurge < 255			--	remove healing 84s
			begin
				declare		@idEvent	int

				select	@idEvent=	max(idEvent)	--	get latest idEvent before which healing 84s are to be removed
					from	tbEvent_S
					where	dEvent <= dateadd(dd, -@tiPurge, getdate( ))
					and		tiHH <= datepart(hh, getdate( ))
		/*		create table	#tbHeal84			--	test run indicates slightly better performance with temp-table!?
				(
					idEvent		int
				)

				insert	#tbHeal84
					select	e.idEvent
						from	tbEvent	e
							inner join	tbEvent84	e84	on	e84.idEvent = e.idEvent
						where	e.idLogType is null
							and	e84.siIdxNew = e84.siIdxOld
							and	e.idEvent < @idEvent
				delete	e	from	tbEvent	e
					inner join	#tbHeal84 h	on	h.idEvent = e.idHealing
		*/
				delete	e	from	tbEvent	e		--	but for now leave cleaner => simpler variant
					inner join
						(select	e.idEvent
							from	tbEvent	e
								inner join	tbEvent84	e84	on	e84.idEvent = e.idEvent
							where	e.idLogType is null		and	e84.siIdxNew = e84.siIdxOld		--	healing 84
								and	e.idEvent < @idEvent
						) h	on	h.idEvent = e.idEvent

				select	@s=	'EvA_Exp( ' + cast(@tiPurge as varchar) + ' ) removed ' + cast(@@rowcount as varchar) +
							' healing rows in ' + convert(varchar, getdate() - @dt, 114)
				exec	pr_Log_Ins	2, null, null, @s
			end

		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Registers or unregisters given module
--	v.7.00	+ @tiModType
--			pr_Module_Set -> pr_Module_Reg
--			* tb_Module.bService -> .bLicense
--	v.6.05
create proc		dbo.pr_Module_Reg
(
	@idModule	tinyint				-- type look-up FK
,	@tiModType	tinyint				-- bitwise: bit0=SqlDb, bit1=WinApp, bit2=WinSvc, bit3=IisApp, bit4=WpfApp
,	@sModule	varchar( 16 )		-- module-id
,	@bLicense	bit					-- is licensed (HASP)?
,	@sDesc		varchar( 64 )		-- module's desc
,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
,	@sMachine	varchar( 32 )		-- server name
,	@sVersion	varchar( 16 )		-- module's version
--,	@dtStart	datetime			-- when running, null == stopped
--,	@sParams	varchar( 255 )		-- startup arguments/parameters
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@s= 'Mod_Reg( ' + right('00' + cast(@idModule as varchar), 3) + '::' + isnull(@sModule, '?') + ', l=' + isnull(cast(@bLicense as varchar), '?') +
				', v=' + isnull(@sVersion, '?') + ', ip=' + isnull(@sIpAddr, '?') + ', m=' + isnull(@sMachine, '?') + ', d=''' + isnull(@sDesc, '') + ''' )'

	begin	tran

		if	exists	(select 1 from tb_Module where idModule = @idModule)
		begin
			update	tb_Module	set	sDesc=	case when @sDesc is null then sDesc else @sDesc end
				,	bLicense= @bLicense, sMachine= @sMachine, sIpAddr= @sIpAddr, sVersion= @sVersion
				where	idModule = @idModule
	--	-	select	@s= @s + ' UPD'		-- no need to mark, this is most often case
		end
		else
		begin
			insert	tb_Module	(  idModule,  tiModType, sModule,  sDesc,  bLicense,  sVersion,  sIpAddr,  sMachine )
					values		( @idModule, @tiModType, @sModule, @sDesc, @bLicense, @sVersion, @sIpAddr, @sMachine )
			select	@s= @s + ' INS'
		end

		if	@sDesc is null				-- unregister
			exec	dbo.pr_Log_Ins	62, null, null, @s
		else
			exec	dbo.pr_Log_Ins	61, null, null, @s

	commit
end
go
grant	execute				on dbo.pr_Module_Reg				to [rReader]
grant	execute				on dbo.pr_Module_Reg				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
--	v.7.00	@sModInfo format changed (removed build d/t)
--	v.6.04	* optimize tbEvent record with tb_Module.sVersion and .sDesc
--	v.6.03
alter proc		dbo.pr_Module_Upd
(
	@idModule	tinyint				-- module-id
,	@sModInfo	varchar( 96 )		-- module info (e.g. 'j7983ls.exe v.M.N.DD.TTTT (built d/t)')
,	@idLogType	tinyint				-- type look-up FK (marks significant events only)
,	@dtStart	datetime			-- when running, null == stopped
,	@sParams	varchar( 255 )		-- startup arguments/parameters
)
	with encryption
as
begin
	declare		@idEvent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		update	dbo.tb_Module	set	dtStart= @dtStart, sParams= @sParams
			where	idModule = @idModule

		exec	dbo.pr_Log_Ins		@idLogType, null, null, @sModInfo

		select	@idEvent=	charindex( ' [', @sModInfo ) + 2
	---	select	@sModInfo=	replace( substring( @sModInfo, @idEvent, charindex( ' (', @sModInfo ) - @idEvent ), ']', '' )
		select	@sModInfo=	replace( substring( @sModInfo, @idEvent, len( @sModInfo ) - @idEvent ), ']', ' ' )

		exec	dbo.prEvent_Ins		0, null, null, null, null, null, null, null, null, null, null, null, null, null,
						@sModInfo, @idEvent out, @idSrcDvc out, @idDstDvc out, @idLogType
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00	+ 'on delete set null' to fkRoomBed_Event
--			+ .idAsnRn, .idAsnCn, .idAsnAi, .idRegRn, .idRegCn, .idRegAi
if	not exists	(select 1 from sys.default_constraints where name='tdRoomBed_Updated')
begin
	begin tran
		alter table	dbo.tbRoomBed		add
			idAsnRn		int null					-- live: currently assigned RN
				constraint	fkRoomBed_AsnRn		foreign key references tbStaff
		,	idAsnCn		int null					-- live: currently assigned CNA
				constraint	fkRoomBed_AsnCna	foreign key references tbStaff
		,	idAsnAi		int null					-- live: currently assigned Aide
				constraint	fkRoomBed_AsnAide	foreign key references tbStaff
		,	idRegRn		int null					-- live: currently registered RN (oldest)
				constraint	fkRoomBed_RegRn		foreign key references tbStaff
		,	idRegCn		int null					-- live: currently registered CNA (oldest)
				constraint	fkRoomBed_RegCna	foreign key references tbStaff
		,	idRegAi		int null					-- live: currently registered Aide (oldest)
				constraint	fkRoomBed_RegAide	foreign key references tbStaff
		alter table	dbo.tbRoomBed
			drop constraint		fkRoomBed_Event
		alter table	dbo.tbRoomBed		add
			constraint	fkRoomBed_Event		foreign key (idEvent) references tbEvent	on delete set null

		exec sp_rename 'tdRoomBed_dtUpdated', 'tdRoomBed_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Room-bed combinations
--	v.7.00	+ tbRoomBed.idAsnRn, .idAsnCn, .idAsnAi, .idRegRn, .idRegCn, .idRegAi
--			- vwRtlsRoom
--	v.6.05	- vwEvent_A, tbPatient, tbDoctor joins - not needed in view itself
--			+ r.cSys, r.tiGID, r.tiJID, r.tiRID
--			+ (nolock)
--	v.6.04
alter view		dbo.vwRoomBed
	with encryption
as
select	r.idUnit,	rb.idRoom, r.sDevice [sRoom], r.cSys, r.tiGID, r.tiJID, r.tiRID,	rb.tiBed, rb.cBed
	,	rb.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	rb.tiSvc, rb.tiIbed
	,	rb.idPatient	--, p.sPatient, p.cGender, p.sInfo, p.sNote
	,	rb.idDoctor		--, d.sDoctor
	,	rb.idAsnRn, ar.sStaff [sAsnRn],		rb.idAsnCn, ac.sStaff [sAsnCn],		rb.idAsnAi, aa.sStaff [sAsnAi]
	,	rb.idRegRn, rr.sStaff [sRegRn],		rb.idRegCn, rc.sStaff [sRegCn],		rb.idRegAi, ra.sStaff [sRegAi]
--	,	rr.idRn	[idRegRn],		rr.sRn	[sRegRn]
--	,	rr.idCn	[idRegCn],		rr.sCn	[sRegCn]
--	,	rr.idAi	[idRegAi],		rr.sAi	[sRegAi]
	,	/*rb.bActive, rb.dtCreated,*/ rb.dtUpdated		/*	don't exist	*/
	from	tbRoomBed	rb	with (nolock)
		inner join		tbDevice	r	with (nolock)	on	r.idDevice = rb.idRoom		and	r.bActive > 0
---		left outer join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0
---		left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
---		left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		left outer join	tbStaff		ar	with (nolock)	on	ar.idStaff = rb.idAsnRn
		left outer join	tbStaff		ac	with (nolock)	on	ac.idStaff = rb.idAsnCn
		left outer join	tbStaff		aa	with (nolock)	on	aa.idStaff = rb.idAsnAi
		left outer join	tbStaff		rr	with (nolock)	on	rr.idStaff = rb.idRegRn
		left outer join	tbStaff		rc	with (nolock)	on	rc.idStaff = rb.idRegCn
		left outer join	tbStaff		ra	with (nolock)	on	ra.idStaff = rb.idRegAi
--		left outer join	vwRtlsRoom	rr	with (nolock)	on	rr.idRoom = rb.idRoom
go
--	----------------------------------------------------------------------------
--	Inserts/deletes a StaffToPatientAssignment row
--	v.7.00
create proc		dbo.prDevice_UpdRoomBeds7980
(
	@bInsert	bit					-- insert or delete?
,	@idRoom		smallint			-- room id
,	@cBedIdx	varchar( 1 )		-- bed index: ' '=no bed, null=all combinations
,	@sRoom		varchar( 16 )
,	@sDial		varchar( 16 )
,	@idUnit1	smallint
,	@idUnit2	smallint
)
	with encryption
as
begin
	set	nocount	on
/*	begin	tran
		if	@bInsert = 0
			delete	from	StaffToPatientAssignment
				where	RoomNumber = @sDial		and	(BedIndex = @cBedIdx	or	@cBedIdx is null)
		else
			if	not exists	(select 1 from StaffToPatientAssignment where RoomNumber = @sDial and BedIndex = @cBedIdx)
				insert	StaffToPatientAssignment
						(RoomNumber, RoomName, BedIndex, DownloadCounter, PrimaryUnitID, SecondaryUnitID)
					values		( @sDial, @sRoom, @cBedIdx, 0, @idUnit1, @idUnit2 )
			else
				update	StaffToPatientAssignment
					set	PrimaryUnitID= @idUnit1, SecondaryUnitID= @idUnit2
					where	RoomNumber = @sDial and BedIndex = @cBedIdx
	commit	*/
end
go
grant	execute				on dbo.prDevice_UpdRoomBeds7980		to [rWriter]
go
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prDevice_UpdRoomBeds7980
(
	@bInsert	bit					-- insert or delete?
,	@idRoom		smallint			-- room id
,	@cBed		varchar( 1 )		-- bed name
,	@sRoom		varchar( 16 )
,	@sDial		varchar( 16 )
,	@idUnit1	smallint
,	@idUnit2	smallint
)
	with encryption
as
begin
	set	nocount	on
	begin	tran
		if	@bInsert > 0
			insert	StaffToPatientAssignment
					(RoomNumber, RoomName, BedIndex, DownloadCounter, PrimaryUnitID, SecondaryUnitID)
				values		( @sDial, @sRoom, @cBed, 0, @idUnit1, @idUnit2 )
		else
			delete	from	StaffToPatientAssignment
				where	RoomNumber = @sDial		and	BedIndex = @cBed
	commit
end' )
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
--	v.7.00	+ rooms without bed
--	v.6.05	+ filling tbRoomStaff
--			+ (nolock)
--	v.6.04
alter proc		dbo.prDevice_UpdRoomBeds
(
	@idRoom		smallint					-- room id
,	@siBeds		smallint					-- beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
)
	with encryption
as
begin
	declare		@sBeds		varchar( 10 )
	declare		@cBed		char( 1 )
			,	@idUnit1	smallint
			,	@idUnit2	smallint
			,	@sRoom		varchar( 16 )
			,	@sDial		varchar( 16 )
	declare		@idDevice	smallint
			,	@tiPriCA0	tinyint				-- coverage area 0
			,	@tiPriCA1	tinyint				-- coverage area 1
			,	@tiPriCA2	tinyint				-- coverage area 2
			,	@tiPriCA3	tinyint				-- coverage area 3
			,	@tiPriCA4	tinyint				-- coverage area 4
			,	@tiPriCA5	tinyint				-- coverage area 5
			,	@tiPriCA6	tinyint				-- coverage area 6
			,	@tiPriCA7	tinyint				-- coverage area 7

	set	nocount	on

	if	exists	(select 1 from tbDevice with (nolock) where idDevice = @idRoom and cDevice='R')	--	only for rooms
	begin
		begin	tran

	---	delete	from	tbRoomBed				--	removes patient-to-bed assignments!
	---		where	idRoom = @idRoom

		if	not exists	(select 1 from tbRoomStaff with (nolock) where idRoom = @idRoom)
			insert	tbRoomStaff	( idRoom)
					values		(@idRoom)

		select	@sBeds=	'', @sRoom= sDevice, @sDial= sDial, @tiPriCA0= tiPriCA0, @tiPriCA1= tiAltCA0
			from	tbDevice	with (nolock)
			where	idDevice = @idRoom

		if	@tiPriCA0 = 0xFF			--	all CAs/Units
			select	top 1 @idUnit1= idUnit
				from	tbUnit		with (nolock)
				order	by	idUnit
		else							--	convert specific CA to its Unit
			select	@idUnit1= idParent
				from	tbDefLoc	with (nolock)
				where	idLoc = @tiPriCA0

		if	@tiPriCA1 = 0xFF			--	all CAs/Units
			select	top 1 @idUnit2= idUnit
				from	tbUnit		with (nolock)
				order	by	idUnit
		else							--	convert specific CA to its Unit
			select	@idUnit2= idParent
				from	tbDefLoc	with (nolock)
				where	idLoc = @tiPriCA1


		if	@siBeds = 0					--	no beds in this room
		begin
			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
			begin
				insert	tbRoomBed	(  idRoom,  cBed, tiBed )
						values		( @idRoom, '*', 0xFF )
				exec	prDevice_UpdRoomBeds7980	1, @idRoom, ' ', @sRoom, @sDial, @idUnit1, @idUnit2
			end
		end
		else							--	there are beds
		begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, ' ', @sRoom, @sDial, @idUnit1, @idUnit2

			if	@siBeds & 1 > 0			--	'A'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 1

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 1)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 1 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 1
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 2 > 0			--	'B'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 2

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 2)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 2 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 2
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 4 > 0			--	'C'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 3

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 3)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 3 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 3
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 8 > 0			--	'D'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 4

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 4)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 4 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 4
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 16 > 0		--	'E'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 5

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 5)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 5 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 5
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 32 > 0		--	'F'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 6

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 6)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 6 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 6
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 64 > 0		--	'G'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 7

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 7)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 7 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 7
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 128 > 0		--	'H'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 8

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 8)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 8 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 8
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 256 > 0		--	'I'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 9

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 9)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 9 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 9
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

			if	@siBeds & 512 > 0		--	'J'
			begin
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 0

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 0 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBed, @sRoom, @sDial, @idUnit1, @idUnit2
			end

		end

		update	tbDevice	set	siBeds= @siBeds, sBeds= @sBeds, dtUpdated= getdate( )
			where	idDevice = @idRoom

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
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
--	v.7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ tbDevice.idEvent
--			+ extended expiration for picked calls
--			+ removal of healing events at once
--			+ (nolock)
--	v.6.04	* comment out prDefStaff_GetInsUpd call
--			now uses prPatient_GetIns, prDoctor_GetIns
--			* room-level calls will be marked for all room's beds in tbRoomBed
--			+ adjust tbEvent_A.dtEvent by @siElapsed - if call has started before
--			+ populating tbRoomBed, + new cache columns in tbEvent_A
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			upon cancellation defer removal of tbEvent_A and tbEvent_P rows
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--	v.6.02	tdDevice.dtLastUpd -> .dtUpdated
--			tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--			tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			@idLoc -> @idUnit
--	v.5.01	encryption added
--			+ tbEvent.idParent, + .tParent, code optimization, parent events
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			.idRn, .idCna, .idAide are in tbEventB4
--	v.4.02	+ @iAID, @tiStype; modified origination and added expiration
--	v.4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--			fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	v.2.03	+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbEventC.tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--			+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	v.2.02	+ tbEventC.idRn, .tRn, .idCna, .tCna, .idAide, .tAide (vwEventC, prEvent84_Ins?)
--	v.2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.08
--	v.1.00
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

,	@tiSrcBtn	tinyint				-- source button code
,	@siPriOld	smallint			-- old priority
,	@siPriNew	smallint			-- new priority
,	@siElapsed	smallint			-- elapsed time
,	@tiPrivacy	tinyint				-- privacy status
,	@tiTmrStat	tinyint				-- stat-need timer
,	@tiTmrRn	tinyint				-- RN-need timer
,	@tiTmrCna	tinyint				-- CNA-need timer
,	@tiTmrAide	tinyint				-- aide-need timer
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
--,	@cBed		char( 1 )			-- bed name
,	@sCall		varchar( 16 )		-- call text
,	@sPatient	varchar( 16 )		-- patient name
,	@sDoctor	varchar( 16 )		-- doctor name
,	@sInfo		varchar( 32 )		-- info text
,	@sDial		varchar( 16 )		-- room dial number
--,	@tiBed		tinyint				-- bed dial number
,	@tiCvrgA0	tinyint				-- coverage area 0
,	@tiCvrgA1	tinyint				-- coverage area 1
,	@tiCvrgA2	tinyint				-- coverage area 2
,	@tiCvrgA3	tinyint				-- coverage area 3
,	@tiCvrgA4	tinyint				-- coverage area 4
,	@tiCvrgA5	tinyint				-- coverage area 5
,	@tiCvrgA6	tinyint				-- coverage area 6
,	@tiCvrgA7	tinyint				-- coverage area 7
,	@iFilter	int					-- call priority filter match bits
,	@siDutyA0	smallint			-- duty area 0
,	@siDutyA1	smallint			-- duty area 1
,	@siDutyA2	smallint			-- duty area 2
,	@siDutyA3	smallint			-- duty area 3
,	@siZoneA0	smallint			-- zone area 0
,	@siZoneA1	smallint			-- zone area 1
,	@siZoneA2	smallint			-- zone area 2
,	@siZoneA3	smallint			-- zone area 3
,	@cDstSys	char( 1 )			-- destination system
,	@tiDstGID	tinyint				-- destination G-ID - gateway
,	@tiDstJID	tinyint				-- destination J-ID - J-bus
,	@tiDstRID	tinyint				-- destination R-ID - R-bus
,	@idUnit		smallint			-- active unit ID
,	@iAID		int					-- device A-ID (24 bits)
,	@tiStype	tinyint				-- device type (1-255)
,	@sRn		varchar( 16 )		-- RN name
,	@sCna		varchar( 16 )		-- CNA name
,	@sAide		varchar( 16 )		-- Aide name

--,	@idEventA	int out				-- output: idEvent, inserted into tbEvent_A
)
	with encryption
as
begin
	declare		@idEvent	int
	declare		@idParent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint
	declare		@idRoom		smallint
	declare		@idCall		smallint
	declare		@siIdxOld	smallint			-- old index
	declare		@siIdxNew	smallint			-- new index
	declare		@idDoctor	int
	declare		@idPatient	int
	declare		@idOrigin	int
	declare		@dtOrigin	datetime
	declare		@tiShelf	tinyint
	declare		@tiSpec		tinyint
	declare		@cBed		char( 1 )
	declare		@idRn		int
	declare		@idCna		int
	declare		@idAide		int
	declare		@tiPurge	tinyint
	declare		@bAudio		bit
	declare		@iExpNrm	int
	declare		@iExpExt	int
--	declare		@s			varchar( 255 )

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbDefBed	with (nolock)	where	idIdx = @tiBed

	select	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

	select	@tiPurge= cast(iValue as tinyint)	from	tb_OptionSys	with (nolock)	where	idOption = 7

	select	@iExpNrm= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 9
	select	@iExpExt= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 10

	if	@siIdxNew > 0			-- call placed
		exec	dbo.prDefCall_GetIns	@siIdxNew, @sCall, @idCall out
	else if	@siIdxOld > 0		-- call cancelled
		exec	dbo.prDefCall_GetIns	@siIdxOld, @sCall, @idCall out
	else
		select	@idCall= 0		--	INTERCOM call
	---	exec	dbo.prDefCall_GetIns	0, @sCall, @idCall out		--	no need to call

	exec	dbo.prPatient_GetIns	@sPatient, null, null, null, @idPatient out
	exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

	begin	tran

		if	@tiBed >= 0
			update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed	and	bInUse = 0

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiSrcBtn, @tiBed, @idUnit, @iAID, @tiStype

		if	@idSrcDvc is not null	and	len( @sDial ) > 0
			update	tbDevice	set	sDial= @sDial, dtUpdated= getdate( )
				where	idDevice = @idSrcDvc	and	( sDial <> @sDial	or sDial is null )	--!

		insert	tbEvent84	(  idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,
							tiTmrStat,  tiTmrRn,  tiTmrCna,  tiTmrAide,  siIdxOld,  siIdxNew,
							idPatient,  idDoctor,  iFilter,
							tiCvrgA0,  tiCvrgA1,  tiCvrgA2,  tiCvrgA3,  tiCvrgA4,  tiCvrgA5,  tiCvrgA6,  tiCvrgA7,
							siDutyA0,  siDutyA1,  siDutyA2,  siDutyA3,  siZoneA0,  siZoneA1,  siZoneA2,  siZoneA3 )
				values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy,
							@tiTmrStat, @tiTmrRn, @tiTmrCna, @tiTmrAide, @siIdxOld, @siIdxNew,
							@idPatient, @idDoctor, @iFilter,
							@tiCvrgA0, @tiCvrgA1, @tiCvrgA2, @tiCvrgA3, @tiCvrgA4, @tiCvrgA5, @tiCvrgA6, @tiCvrgA7,
							@siDutyA0, @siDutyA1, @siDutyA2, @siDutyA3, @siZoneA0, @siZoneA1, @siZoneA2, @siZoneA3)

---		if	len( @sRn ) > 0		exec	dbo.prDefStaff_GetInsUpd	1, null, @sRn, @idRn out
---		if	len( @sCna ) > 0	exec	dbo.prDefStaff_GetInsUpd	2, null, @sCna, @idCna out
---		if	len( @sAide ) > 0	exec	dbo.prDefStaff_GetInsUpd	4, null, @sAide, @idAide out

---		if	@idRn > 0	or	@idCna > 0	or	@idAide > 0
---			insert	tbEventB4	( idEvent, idRn, idCna, idAide )
---					values		( @idEvent, @idRn, @idCna, @idAide )

		select	@idOrigin= idEvent, @dtOrigin= dtEvent, @bAudio= bAudio
			from	tbEvent_A	with (nolock)
			where	cSys = @cSrcSys
				and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
---			where	cSrcSys = @cSrcSys
---				and	tiSrcGID = @tiSrcGID	and	tiSrcJID = @tiSrcJID	and	tiSrcRID = @tiSrcRID	and	tiSrcBtn = @tiSrcBtn
				and	bActive > 0				--	6.04
		--		and	dtExpires > getdate( )

	---	if	@siIdxOld = 0	or	@idOrigin is null	--	new call placed | no active origin found
		if	@idOrigin is null	--	no active origin found
			--	'real' new call should not have origin anyway, 'repeated' one would be linked to starting - even better
		begin
			update	tbEvent		set	idOrigin= @idEvent, idLogType= 191	-- call placed
								,	tElapsed= dateadd(ss, @siElapsed, '0:0:0')										--	v.6.05
								,	@dtOrigin= dateadd(ss, - @siElapsed, dtEvent), @idSrcDvc= idSrcDvc, @idParent= idParent		--	v.6.04
				where	idEvent = @idEvent
---			insert	tbEvent_A	(  idEvent,   dtEvent,  cSrcSys,  tiSrcGID,  tiSrcJID,  tiSrcRID,  tiSrcBtn,  siIdxOld,  siIdxNew,  tiBed, dtExpires )
			insert	tbEvent_A	(  idEvent,   dtEvent,  cSys,     tiGID,     tiJID,     tiRID,     tiBtn,     siPri,     siIdx,     tiBed, dtExpires )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiSrcBtn, @siPriNew, @siIdxNew, @tiBed,		--	v.6.04
								dateadd(ss, @iExpNrm, getdate( )) )	--@dtOrigin
			update	tbEvent_T	set	idCall= @idCall, idUnit= @idUnit, cBed= @cBed
				where	idEvent = @idParent		and	@idCall is null		-- there could be more than one, but we need to use only 1st one

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbDefCallP	with (nolock)	where	idIdx = @siIdxNew

			if	( @tiShelf > 0	and		( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 ) )	--	only save 'medical' calls
				or	@tiSpec between 7 and 9															--	or 'presence'
				begin
					if	@tiSrcRID > 0	--	is source device a station?
						select	@idSrcDvc= idParent		--	room-controller must be the station's parent!
							from	tbDevice	with (nolock)
							where	idDevice = @idSrcDvc
					insert	tbEvent_C	( idEvent, dEvent, tEvent, tiHH, idCall, idRoom, idUnit, cBed )
							values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idSrcDvc, @idUnit, @cBed )
				end
			if	@tiSpec = 7
				update	c	set	idRn= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
---					where	a.tiSrcGID = @tiSrcGID	and	a.tiSrcJID = @tiSrcJID
			else if	@tiSpec = 8
				update	c	set	idCna= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
---					where	a.tiSrcGID = @tiSrcGID	and	a.tiSrcJID = @tiSrcJID
			else if	@tiSpec = 9
				update	c	set	idAide= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
---					where	a.tiSrcGID = @tiSrcGID	and	a.tiSrcJID = @tiSrcJID

			select	@idOrigin= @idEvent		--	6.04
		end
		else	--	active origin found		(=> this must be a healing or cancellation event)
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tElapsed= dtEvent - @dtOrigin
			--		,@idSrcDvc= idSrcDvc
				where	idEvent = @idEvent
			update	tbEvent_A	set	dtExpires= dateadd(ss, @iExpNrm, getdate( ))
								,	siPri= @siPriNew
---								,	siIdxOld= @siPriNew
---				where	cSrcSys = @cSrcSys
---					and	tiSrcGID = @tiSrcGID	and	tiSrcJID = @tiSrcJID	and	tiSrcRID = @tiSrcRID	and	tiSrcBtn = @tiSrcBtn
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	bActive > 0				--	6.04
		end

		if	@siIdxNew = 0	-- call cancelled
		begin
		--	6.03:	upon cancellation mark inactive, but defer removal of tbEvent_A and tbEvent_P rows - let them expire,
		--				so that events from same sequence (that are still-unfinished) can be tied to the same origin
			select	@dtOrigin=	case when @bAudio=0 then dateadd(ss, @iExpNrm, getdate( ))				--	6.05
													else dateadd(ss, @iExpExt, getdate( )) end

			update	tbEvent_A	set	dtExpires= @dtOrigin, bActive= 0,	tiSvc= null		--	6.05
								,	tiTmrStat= null, tiTmrRn= null, tiTmrCna= null, tiTmrAide= null		--	6.04
---				where	cSrcSys = @cSrcSys
---					and	tiSrcGID = @tiSrcGID	and	tiSrcJID = @tiSrcJID	and	tiSrcRID = @tiSrcRID	and	tiSrcBtn = @tiSrcBtn
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	bActive > 0				--	6.04

			update	tbEvent_P	set	dtExpires= @dtOrigin												--	6.05
---				where	cSrcSys = @cSrcSys
---					and	tiSrcGID = @tiSrcGID	and	tiSrcJID = @tiSrcJID	--	and	tiSrcRID = @tiSrcRID	and	tiSrcBtn = @tiSrcBtn
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	dtExpires < @dtOrigin

	--		select	@s=	@cSrcSys + '-' + cast(@tiSrcGID as varchar) + '-' + cast(@tiSrcJID as varchar) +
	--					' -> ' + convert(varchar, @dtOrigin, 121) + ' rows:' + cast(@@rowcount as varchar)
	--		exec	pr_Log_Ins	0, null, null, @s

			select	@dtOrigin= tElapsed, @idParent= idParent
				from	tbEvent		with (nolock)
				where	idEvent = @idEvent
			update	tbEvent_C	set	idStaff= @idEvent, tStaff= @dtOrigin
				where	idEvent = @idOrigin		and	idStaff is null		-- there should be only one, but just in case use only 1st one
			update	tbEvent		set	idLogType= 193		-- call cleared
				where	idEvent = @idEvent

			select	@tiSpec= tiSpec	from	tbDefCallP	with (nolock)	where	idIdx = @siIdxOld

			if	@tiSpec = 7
			begin
				update	tbEvent_C	set	tRn= @dtOrigin
					where	idRn = @idOrigin
				update	tbEvent_T	set	tRn= isnull(tRn, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end
			else if	@tiSpec = 8
			begin
				update	tbEvent_C	set	tCna= @dtOrigin
					where	idCna = @idOrigin
				update	tbEvent_T	set	tCna= isnull(tCna, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end
			else if	@tiSpec = 9
			begin
				update	tbEvent_C	set	tAide= @dtOrigin
					where	idAide = @idOrigin
				update	tbEvent_T	set	tAide= isnull(tAide, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end

		--	can't do following for @tiSpec=7|8|9 (and maybe others!?..)
			if	@tiSpec is null		or @tiSpec < 7	or	@tiSpec > 9
				update	tbEvent_T	set	idStaff= @idEvent, tStaff= @dtOrigin
					where	idEvent = @idParent		and	idStaff is null			-- there should be only one, but just in case use only 1st one
		end
		else if	@siIdxNew > 0  and  @siIdxOld > 0  and  @siIdxOld <> @siIdxNew
			update	tbEvent		set	idLogType= 192		-- call escalated
				where	idEvent = @idEvent

		select	@idRoom= idRoom		--, @idCall= idCall		--	get idRoom, assigned by prEvent_Ins
			from	tbEvent		with (nolock)
			where	idEvent = @idEvent

		if	@tiPurge > 0
			delete	from	tbEvent							-- remove healing event at once (cascade rule must take care of other tables)
				where	idEvent = @idEvent
					and	idLogType is null

		if	@tiTmrStat > 3		select	@tiTmrStat=	3
		if	@tiTmrRn > 3		select	@tiTmrRn=	3
		if	@tiTmrCna > 3		select	@tiTmrCna=	3
		if	@tiTmrAide > 3		select	@tiTmrAide=	3

		update	tbEvent_A	set	idRoom= @idRoom	---, tiBed= @tiBed		--	cache necessary details in the active call (tiBed is null for room-level calls)
							,	idCall= @idCall, tiTmrStat= @tiTmrStat, tiTmrRn= @tiTmrRn, tiTmrCna= @tiTmrCna, tiTmrAide= @tiTmrAide
							,	tiSvc= @tiTmrStat*64 + @tiTmrRn*16 + @tiTmrCna*4 + @tiTmrAide		--	v.6.05
			where	idEvent = @idOrigin

	---	!! @idEvent will no longer point to the current event !!
		select	top	1	@idEvent=	idEvent					--	select an active call with highest priority in this room-bed or room
			,	@tiTmrStat= tiTmrStat, @tiTmrRn= tiTmrRn, @tiTmrCna= tiTmrCna, @tiTmrAide= tiTmrAide
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom
				and	(tiBed = @tiBed  or  tiBed is null)
				and	bActive > 0
			order	by	siIdx desc, idEvent desc
---			order	by	siIdxNew desc, idEvent desc

		if	@siIdxNew = 0	-- call cancelled
		begin
			update	tbDevice	set	idEvent= null, tiSvc= null
				where	idDevice = @idRoom

			update	tbRoomBed	set	idEvent= null	--, idPatient= @idPatient, idDoctor= @idDoctor
					,	tiSvc= null
					,	tiIbed= case when	@tiStype = 192	then		--	only for 7947 (iBed)
											tiIbed &
											case when	@tiSrcBtn = 2	then	0xFE
												when	@tiSrcBtn = 7	then	0xFD
												when	@tiSrcBtn = 6	then	0xFB
												when	@tiSrcBtn = 5	then	0xF7
												when	@tiSrcBtn = 4	then	0xEF
												when	@tiSrcBtn = 3	then	0xDF
												when	@tiSrcBtn = 1	then	0xBF
												when	@tiSrcBtn = 0	then	0x7F
												else	0xFF	end
									else	tiIbed	end					--	don't change
					,	dtUpdated= getdate( )
				where	idRoom = @idRoom
					and	(@tiBed is null		or
						@tiBed is not null	and	tiBed = @tiBed)
				---	and	(tiBed = @tiBed  or  tiBed is null)
		end
		else				--	call placed / being-healed
		begin
			update	tbDevice	set	idEvent= @idEvent, tiSvc= @tiTmrStat*64 + @tiTmrRn*16 + @tiTmrCna*4 + @tiTmrAide
				where	idDevice = @idRoom

			update	tbRoomBed	set	idEvent= @idEvent, idPatient= @idPatient, idDoctor= @idDoctor
					,	tiSvc= @tiTmrStat*64 + @tiTmrRn*16 + @tiTmrCna*4 + @tiTmrAide
					,	tiIbed= case when	@tiStype = 192	then		--	only for 7947 (iBed)
											tiIbed |
											case when	@tiSrcBtn = 2	then	0x01
												when	@tiSrcBtn = 7	then	0x02
												when	@tiSrcBtn = 6	then	0x04
												when	@tiSrcBtn = 5	then	0x08
												when	@tiSrcBtn = 4	then	0x10
												when	@tiSrcBtn = 3	then	0x20
												when	@tiSrcBtn = 1	then	0x40
												when	@tiSrcBtn = 0	then	0x80
												else	0x00	end
									else	tiIbed	end					--	don't change
					,	dtUpdated= getdate( )
				where	idRoom = @idRoom
					and	(@tiBed is null		or
						@tiBed is not null	and	tiBed = @tiBed)
				---	and	(tiBed = @tiBed  or  tiBed is null)
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x88, x89, x8A, x8D] audio
--	v.7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ extended expiration for picked calls
--			+ tagging tbEvent_A.bAudio
--			+ (nolock)
--	v.6.04	* @siPri -> @siIdx arg in call to prDefCall_GetIns
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--	v.6.02	tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.01	encryption added
--			+ tbEvent.idParent, + .tParent, parent events
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	v.4.01	fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	v.2.03	.idSrcDvc -> .idDstDvc (prEvent8A_Ins, vwEvent8A)
--			+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbEventC.tEvent (for CallActSum rpt) (prEvent84_Ins, prEvent8A_Ins, vwEventC)
--			fix for non-med EventC insertions, changed Event.idType if no origin
--			+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	v.2.01	- .idDstDvc
--			.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.08
--	v.1.00
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
,	@tiDstBtn	tinyint				-- destination button code
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
	declare		@idParent	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint
	declare		@idCall		smallint
	declare		@siIdx		smallint			-- call-index
	declare		@idOrigin	int
	declare		@dtOrigin	datetime
	declare		@tiShelf	tinyint
	declare		@tiSpec		tinyint
	declare		@cBed		char( 1 )
	declare		@iExpNrm	int

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbDefBed	with (nolock)	where	idIdx = @tiBed

	select	@siIdx=	@siPri & 0x03FF

	select	@iExpNrm= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 9

	begin	tran

		if	@tiBed >= 0
			update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed	and	bInUse = 0

		if	@siPri > 0
			exec	dbo.prDefCall_GetIns	@siIdx, @sCall, @idCall out
		else
---			exec	dbo.prDefCall_GetIns	0, @sCall, @idCall out		--	no need to call
			select	@idCall= 0				--	INTERCOM call

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDstDvc, null,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiDstBtn, @tiBed

		insert	tbEvent8A	( idEvent,  tiSrcJAB,  tiSrcLAB,  tiDstJAB,  tiDstLAB,
							siPri,  tiFlags,  siIdx )
				values		( @idEvent, @tiSrcJAB, @tiSrcLAB, @tiDstJAB, @tiDstLAB,
							@siPri, @tiFlags, @siIdx )

		select	@idOrigin= idEvent, @dtOrigin= dtEvent
			from	tbEvent_A	with (nolock)
---			where	cSrcSys = @cDstSys
---				and	tiSrcGID = @tiDstGID	and	tiSrcJID = @tiDstJID	and	tiSrcRID = @tiDstRID	and	tiSrcBtn = @tiDstBtn
			where	cSys = @cDstSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiDstBtn
		---		and	bActive > 0				--	6.05 (6.04 in 84!)

		if	@idOrigin	is not null
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tElapsed= dtEvent - @dtOrigin
				where	idEvent = @idEvent

			if	@idCmd = 0x89
				update	tbEvent		set	idLogType= 195						-- audio request
					where	idEvent = @idEvent
			else if	@idCmd = 0x88
				update	tbEvent		set	idLogType= 196						-- audio busy
					where	idEvent = @idEvent
			else if	@idCmd = 0x8A		-- AUDIO GRANT == voice response
			begin
				update	tbEvent_A	set	bAudio= 1							-- connected
					where	idEvent = @idOrigin
				select	@dtOrigin= tElapsed, @idParent= idParent
					from	tbEvent		with (nolock)
					where	idEvent = @idEvent
				update	tbEvent		set	idLogType= 197						-- audio connected
					where	idEvent = @idEvent
				update	tbEvent_C	set	idVoice= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idOrigin		and	idVoice is null		-- there should be only one, but just in case use only 1st one
				update	tbEvent_T	set	idVoice= @idEvent, tVoice= @dtOrigin
					where	idEvent = @idParent		and	idVoice is null		-- there should be only one, but just in case use only 1st one
			end
			else if	@idCmd = 0x8D
			begin
				update	tbEvent_A	set	bAudio= 0							-- disconnected
					,	dtExpires= case when bActive = 0 then dateadd(ss, @iExpNrm, getdate( ))
														else dtExpires end
					where	idEvent = @idOrigin
				update	tbEvent		set	idLogType= 199						-- audio quit
					where	idEvent = @idEvent
			end
		end
		else	-- no origin found
		begin
			update	tbEvent		set	idOrigin= @idEvent, tElapsed= '0:0:0' --,	idLogType= 198	-- audio dialed
				,	idLogType=	case when @idCmd = 0x8D then 199			-- audio quit
									when @idCmd = 0x89 then 195				-- audio request
									when @idCmd = 0x88 then 196				-- audio busy
									else					197 end,		-- audio connected
					@idDstDvc= idSrcDvc, @dtOrigin= dtEvent
				where	idEvent = @idEvent

			select	@tiShelf= tiShelf, @tiSpec= tiSpec	from	tbDefCallP	with (nolock)	where	idIdx = @siIdx

			if	@tiShelf > 0	and	(@tiSpec is null	or	@tiSpec < 6	or	@tiSpec = 18)
			begin									--	only save "medical" calls as transactions
				if	@tiDstRID > 0					--	is destination device a station?
					select	@idDstDvc= idParent		--	then room (room-controller) is station's parent!
						from	tbDevice	with (nolock)
						where	idDevice = @idSrcDvc
				insert	tbEvent_C	( idEvent, dEvent, tEvent, tiHH, idCall, idRoom, cBed )
						values		( @idEvent, @dtOrigin, @dtOrigin, datepart(hh, @dtOrigin), @idCall, @idDstDvc, @cBed )
			end
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x95]
--	v.7.00	* tbDefBed.bInUse is set only if it was 'false' before
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ (nolock)
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			+ prDefCall_GetIns: resurrected (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins, prEvent41_Ins)
--			+ @siPri (to pass in call-index from 0x95 cmd)
--	v.6.02	tbDefBed.tiUse -> .bInUse
--			tbDefCall: + .bEnabled, bActive: tinyint -> bit, + .dtUpdated
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			@idLoc -> @idUnit
--	v.5.01	encryption added
--			fix for idDstDvc
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--	v.4.01	+ tbEvent84.idLoc, (prEvent84_Ins, vwEvent84, tbEventC, vwEventC), tbEvent95.idLoc (prEvent95_Ins, vwEvent95)
--			fix (tiBed > 9): prEvent84_Ins, 8A, 95
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--			tiBed=0 will now indicate bed #10 (prEvent*_Ins: 84, 8A, 95), only 0xFF means room-level (no bed)
--	v.2.03	+ tbDefBed.tiUse (prEvent84_Ins, prEvent8A_Ins, prEvent95_Ins)
--	v.2.01	.idCall -> tbEvent.idCall (84, 8A, 95, prEvent_Ins, etc.)
--	v.1.00
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
,	@tiDstBtn	tinyint				-- destination button code
,	@tiSvcSet	tinyint				-- bit: 1=Aide,2=CNA,4=RN,8=Stat
,	@tiSvcClr	tinyint				-- bit: 1=Aide,2=CNA,4=RN,8=Stat
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
--,	@cBed		char( 1 )			-- bed name
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
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint
	declare		@idCall		smallint
			,	@siIdx		smallint			-- call-index
	declare		@idOrigin	int
	declare		@dtOrigin	datetime
	declare		@cBed		char( 1 )

	set	nocount	on

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@cBed= null, @tiBed= null
	else
		select	@cBed= cBed		from	tbDefBed	with (nolock)	where	idIdx = @tiBed

	select	@siIdx=	@siPri & 0x03FF

	begin	tran

		if	@tiBed >= 0
			update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed	and	bInUse = 0

		if	@siIdx > 0
			exec	dbo.prDefCall_GetIns	@siIdx, @sCall, @idCall out
		else
---			exec	dbo.prDefCall_GetIns	0, @sCall, @idCall out		--	no need to call
			select	@idCall= 0				--	INTERCOM call

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, null,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, @sDevice, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiDstBtn, @tiBed, @idUnit

		insert	tbEvent95	( idEvent,  tiSvcSet,  tiSvcClr )
				values		( @idEvent, @tiSvcSet, @tiSvcClr )

		begin
			select	@idOrigin= idEvent, @dtOrigin= dtEvent
				from	tbEvent_A	with (nolock)
				where	cSys = @cDstSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = @tiDstRID	and	tiBtn = @tiDstBtn
---				where	cSrcSys = @cDstSys
---					and	tiSrcGID = @tiDstGID	and	tiSrcJID = @tiDstJID	and	tiSrcRID = @tiDstRID	and	tiSrcBtn = @tiDstBtn
			update	tbEvent		set	idOrigin= @idOrigin, tElapsed= dtEvent - @dtOrigin
				where	idEvent = @idEvent

			if	@tiSvcSet > 0  and  @tiSvcClr = 0
				update	tbEvent		set	idLogType= 201		-- set svc
					where	idEvent = @idEvent
			else if	@tiSvcSet = 0  and  @tiSvcClr > 0
				update	tbEvent		set	idLogType= 203		-- clear svc
					where	idEvent = @idEvent
			else --	if	@tiSvcSet > 0  and  @tiSvcClr = 0
				update	tbEvent		set	idLogType= 202		-- set/clr
					where	idEvent = @idEvent
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00
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

,	@sCodeVer	varchar				-- device code version
)
	with encryption
as
begin
--	declare		@idEvent	int
--	declare		@idSrcDvc	smallint
--	declare		@idDstDvc	smallint

	set	nocount	on

	begin	tran

		update	dbo.tbDevice	set	sCodeVer= @sCodeVer, dtUpdated= getdate( )
			where	cSys = @cSrcSys	and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	bActive > 0
--		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
--					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sSrcDvc,
--					null, null, null, null, null, @sInfo,
--					@idEvent out, @idSrcDvc out, @idDstDvc out, 205, @idCall, @tiBtn, @tiBed

--		insert	tbEvent41	( idEvent,  siIdx,  dtAttempt,  biPager,  tiSeqNum,  cStatus )
--				values		( @idEvent, @siIdx, @dtAttempt, @biPager, @tiSeqNum, @cStatus )
	commit
end
go
grant	execute				on dbo.prEventC1_Ins				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns lowest map index for a given room (identified by Sys-G-J) within a given unit
--	v.7.00
create function		dbo.fnUnitMapCell_GetMap
(
	@idUnit		smallInt					-- unit id
,	@cSys		char( 1 )					-- system ID
,	@tiGID		tinyint						-- G-ID - gateway
,	@tiJID		tinyint						-- J-ID - J-bus
)
	returns table
	with encryption
as
return
	select	min(tiMap)	[tiMap]		--	top 1
		from	tbUnitMapCell	with (nolock)
		where	idUnit = @idUnit	and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID
	--	order	by	tiMap
go
grant	select				on dbo.fnUnitMapCell_GetMap			to [rWriter]
grant	select				on dbo.fnUnitMapCell_GetMap			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
--	v.7.00	* prDevice_UpdRoomBeds7980: @tiBed -> @cBedIdx
--			+ set tbDefBed.bInUse
--			+ rooms without bed
--	v.6.05	+ filling tbRoomStaff
--			+ (nolock)
--	v.6.04
alter proc		dbo.prDevice_UpdRoomBeds
(
	@idRoom		smallint					-- room id
,	@siBeds		smallint					-- beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
)
	with encryption
as
begin
	declare		@iTrace		int
			,	@s			varchar( 255 )
	declare		@sBeds		varchar( 10 )
			,	@cBed		char( 1 )
			,	@idUnit1	smallint
			,	@idUnit2	smallint
			,	@sRoom		varchar( 16 )
			,	@sDial		varchar( 16 )
	declare		@idDevice	smallint
			,	@tiPriCA0	tinyint				-- coverage area 0
			,	@tiPriCA1	tinyint				-- coverage area 1
			,	@tiPriCA2	tinyint				-- coverage area 2
			,	@tiPriCA3	tinyint				-- coverage area 3
			,	@tiPriCA4	tinyint				-- coverage area 4
			,	@tiPriCA5	tinyint				-- coverage area 5
			,	@tiPriCA6	tinyint				-- coverage area 6
			,	@tiPriCA7	tinyint				-- coverage area 7

	set	nocount	on

	if	exists	(select 1 from tbDevice with (nolock) where idDevice = @idRoom and cDevice='R')	--	only for rooms	// and 7967-P or tiStype=26
	begin

		select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

		select	@sBeds=	'', @sRoom= sDevice, @sDial= sDial, @tiPriCA0= tiPriCA0, @tiPriCA1= tiAltCA0
			from	tbDevice	with (nolock)
			where	idDevice = @idRoom

		if	@tiPriCA0 = 0xFF			--	all CAs/Units
			select	top 1 @idUnit1= idUnit
				from	tbUnit		with (nolock)
				order	by	idUnit
		else							--	convert specific CA to its Unit
			select	@idUnit1= idParent
				from	tbDefLoc	with (nolock)
				where	idLoc = @tiPriCA0

		if	@tiPriCA1 = 0xFF			--	all CAs/Units
			select	top 1 @idUnit2= idUnit
				from	tbUnit		with (nolock)
				order	by	idUnit
		else							--	convert specific CA to its Unit
			select	@idUnit2= idParent
				from	tbDefLoc	with (nolock)
				where	idLoc = @tiPriCA1

		select	@s= 'Dvc_URB( ' + isnull(cast(@idRoom as varchar), '?') + ', r="' + isnull(@sRoom, '?') + '", d=' + isnull(@sDial, '?') +
					', u1=' + isnull(cast(@idUnit1 as varchar), '?') + ', u2=' + isnull(cast(@idUnit2 as varchar), '?') +
					', b=' + isnull(cast(@siBeds as varchar), '?') + ' )'

		if	@iTrace & 0x08 > 0
			exec	dbo.pr_Log_Ins	71, null, null, @s

		begin	tran

	---	delete	from	tbRoomBed				--	removes patient-to-bed assignments!
	---		where	idRoom = @idRoom

		if	not exists	(select 1 from tbRoomStaff with (nolock) where idRoom = @idRoom)
			insert	tbRoomStaff	( idRoom)
					values		(@idRoom)

		if	@siBeds = 0					--	no beds in this room
		begin
			exec	prDevice_UpdRoomBeds7980	0, @idRoom, null, @sRoom, @sDial, @idUnit1, @idUnit2
			delete from	tbRoomBed	where	idRoom = @idRoom	--and	tiBed = 0xFF	---	remove all combinations

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
			begin
				insert	tbRoomBed	(  idRoom, cBed, tiBed )
						values		( @idRoom, null, 0xFF )
				exec	prDevice_UpdRoomBeds7980	1, @idRoom, ' ', @sRoom, @sDial, @idUnit1, @idUnit2
			end
		end
		else							--	there are beds
		begin

			exec	prDevice_UpdRoomBeds7980	0, @idRoom, ' ', @sRoom, @sDial, @idUnit1, @idUnit2
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF

			if	@siBeds & 1 > 0			--	'A'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 1
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 1

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 1)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 1 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '1', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '1', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 1
			end

			if	@siBeds & 2 > 0			--	'B'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 2
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 2

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 2)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 2 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '2', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '2', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 2
			end

			if	@siBeds & 4 > 0			--	'C'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 3
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 3

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 3)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 3 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '3', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '3', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 3
			end

			if	@siBeds & 8 > 0			--	'D'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 4
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 4

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 4)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 4 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '4', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '4', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 4
			end

			if	@siBeds & 16 > 0		--	'E'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 5
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 5

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 5)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 5 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '5', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '5', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 5
			end

			if	@siBeds & 32 > 0		--	'F'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 6
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 6

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 6)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 6 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '6', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '6', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 6
			end

			if	@siBeds & 64 > 0		--	'G'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 7
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 7

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 7)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 7 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '7', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '7', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 7
			end

			if	@siBeds & 128 > 0		--	'H'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 8
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 8

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 8)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 8 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '8', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '8', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 8
			end

			if	@siBeds & 256 > 0		--	'I'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 9
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 9

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 9)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 9 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '9', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '9', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 9
			end

			if	@siBeds & 512 > 0		--	'J'
			begin
				update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = 0
				select	@cBed= cBed, @sBeds= @sBeds + cBed
					from	tbDefBed	with (nolock)
					where	idIdx = 0

				if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0)
				begin
					insert	tbRoomBed	(  idRoom,  cBed, tiBed )
							values		( @idRoom, @cBed, 0 )
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, '0', @sRoom, @sDial, @idUnit1, @idUnit2
				end
			end
			else
			begin
				exec	prDevice_UpdRoomBeds7980	0, @idRoom, '0', @sRoom, @sDial, @idUnit1, @idUnit2
				delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0
			end

		end

		update	tbDevice	set	siBeds= @siBeds, sBeds= @sBeds, dtUpdated= getdate( )
			where	idDevice = @idRoom

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
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdMstrAcct_Created')
begin
	begin tran
		exec sp_rename 'tdMstrAcct_dtCreated', 'tdMstrAcct_Created', 'object'
		exec sp_rename 'tdMstrAcct_dtUpdated', 'tdMstrAcct_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdShift_Created')
begin
	begin tran
		exec sp_rename 'tdShift_tiRouting', 'tdShift_Routing', 'object'
		exec sp_rename 'tdShift_tiNotify', 'tdShift_Notify', 'object'
		exec sp_rename 'tdShift_dtCreated', 'tdShift_Created', 'object'
		exec sp_rename 'tdShift_dtUpdated', 'tdShift_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
if	not exists	(select 1 from sys.default_constraints where name='tdStaffAssnDef_Active')
begin
	begin tran
		exec sp_rename 'tbStaffAssnDef.idStaffAssn', 'idStaffCover', 'column'
		exec sp_rename 'tbStaffAssnDef.idStaffAssnDef', 'idStaffAssn', 'column'

		exec sp_rename 'fkStaffAssnDef_Device', 'fkStaffAssn_Device', 'object'
		exec sp_rename 'fkStaffAssnDef_Shift', 'fkStaffAssn_Shift', 'object'
		exec sp_rename 'fkStaffAssnDef_Staff', 'fkStaffAssn_Staff', 'object'
		exec sp_rename 'tdStaffAssnDef_bActive', 'tdStaffAssn_Active', 'object'
		exec sp_rename 'tdStaffAssnDef_dtCreated', 'tdStaffAssn_Created', 'object'
		exec sp_rename 'tdStaffAssnDef_dtUpdated', 'tdStaffAssn_Updated', 'object'

		exec sp_rename 'tbStaffAssn.idStaffAssn', 'idStaffCover', 'column'
		exec sp_rename 'tbStaffAssn.idStaffAssnDef', 'idStaffAssn', 'column'

		exec sp_rename 'fkStaffAssn_StaffAssnDef', 'fkStaffCover_StaffAssn', 'object'

		alter table	dbo.tbStaffAssn		alter column
			dtBeg		smalldatetime not null		-- coverage start
		alter table	dbo.tbStaffAssn		alter column
			dtEnd		smalldatetime null			-- coverage finish

		exec sp_rename 'dbo.tbStaffAssn', 'tbStaffCover', 'object'
		exec sp_rename 'dbo.tbStaffAssnDef', 'tbStaffAssn', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Staff assignment definitions
--	v.7.00
create view		dbo.vwStaffAssn
	with encryption
as
select	sa.idStaffAssn,	sh.idUnit
	,	sa.idShift, sh.sShift, sh.tBeg [tShBeg], sh.tEnd [tShEnd]
	,	sa.idRoom, d.cDevice, d.sDevice [sRoom], d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idStaff, s.lStaffID, s.idStaffLvl, s.sStaffLvl, s.sStaff
	,	sc.idStaffCover, sc.tBeg, sc.tEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStaffAssn		sa	with (nolock)
		inner join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift
		inner join	vwStaff		s	with (nolock)	on	s.idStaff = sa.idStaff
		inner join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
		left outer join	tbStaffCover	sc	with (nolock)	on	sc.idStaffCover = sa.idStaffCover
go
grant	select							on dbo.vwStaffAssn		to [rWriter]
grant	select							on dbo.vwStaffAssn		to [rReader]
go
--	----------------------------------------------------------------------------
--	Finalizes specified staff assignment definition by marking it inactive
--	v.7.00	tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.02
create proc		dbo.prStaffAssn_Fin
(
	@idStaffAssn	int						-- internal
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		--	TODO:	deactivate and close everything associated with that StaffAssn
		update	tbStaffCover	set
				dtEnd= getdate( ), dEnd= getdate( ), tEnd= getdate( ), tiEnd= datepart( hh, getdate( ) )
			where	idStaffAssn = @idStaffAssn

		update	tbStaffAssn	set
				bActive= 0, idStaffCover= null, dtUpdated= getdate( )
			where	idStaffAssn = @idStaffAssn

	commit
end
go
grant	execute				on dbo.prStaffAssn_Fin				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
--	v.7.00	* tbDevice.bActive >0
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.02
--	v.6.01
create proc		dbo.prStaffAssn_InsUpdDel
(
	@idStaffAssn	int						-- internal
,	@bActive	bit							-- "deletion" marks inactive
,	@idUnit		smallint					-- unit look-up FK
,	@idRoom		smallint					-- room look-up FK
,	@sRoom		varchar( 16 )				-- room name
,	@tiBed		tinyint						-- bed index FK
,	@idShift	smallint					-- internal
,	@tiShIdx	tinyint						-- shift index [1..3]
,	@tiIdx		tinyint						-- staff index [1..3]
,	@idStaff	int							-- staff look-up FK
,	@lStaffID	bigint						-- external Staff ID
--,	@sStaffID	varchar( 16 )				-- external Staff ID
,	@TempID		int							-- 7980 FK
,	@iStamp		int							-- row-version counter
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
	set	nocount	on

	if	@idRoom is null
		select	@idRoom= idDevice		from	tbDevice
				where	bActive >0	and	sDevice = @sRoom	--	and	sDial = @sDial
--	print	@idRoom

	if	@idShift is null
		select	@idShift= idShift		from	tbShift
				where	bActive >0	and	idUnit = @idUnit	and	tiIdx = @tiShIdx
--	print	@idShift

	if	@idStaff is null	--	and	len(@sStaffID) > 0
		select	@idStaff= idStaff		from	tbStaff
				where	bActive >0	and	lStaffID = @lStaffID
--	print	@idStaff

	if	@idStaffAssn is null		and	(@idRoom is null	or	@idShift is null)	--	log an error in input
	begin
		select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_1( idUnit=' + isnull(cast(@idUnit as varchar),'?') +
				', sRoom=' + isnull(@sRoom,'?') + ', tiBed=' + isnull(cast(@tiBed as varchar),'?') +
				', ixShift=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixStaff=' + isnull(cast(@tiIdx as varchar),'?') +
				', lStaffID=' + isnull(cast(@lStaffID as varchar),'?') + ', TempID=' + isnull(cast(@TempID as varchar),'?') +
				' )  idRoom=' + isnull(cast(@idRoom as varchar),'?') + ', idShift=' + isnull(cast(@idShift as varchar),'?') +
				', idStaff=' + isnull(cast(@idStaff as varchar),'?') + '.'
		exec	pr_Log_Ins	47, null, null, @s
		return	-1
	end

	if	@idStaffAssn is null
		select	@idStaffAssn= idStaffAssn		from	tbStaffAssn
				where	bActive >0	and	idRoom = @idRoom	and	tiBed = @tiBed	and	idShift = @idShift	and	tiIdx = @tiIdx
--	print	@idStaffAssn

	if	@idStaffAssn is not null	and	@idStaff is null
		select	@bActive= 0

	if	@bActive > 0	and	exists( select 1 from tbStaffAssn where idStaffAssn = @idStaffAssn and idStaff <> @idStaff )
	begin
		exec	dbo.prStaffAssn_Fin	@idStaffAssn
		select	@idStaffAssn= null
	end

	begin	tran

		if	@bActive > 0
		begin
			if	@idStaffAssn is null
	--		begin
				if	@idRoom > 0	and	@tiBed >= 0	and	@idShift > 0	and	@tiIdx > 0	and	@idStaff > 0	and	@TempID > 0
				begin
					insert	tbStaffAssn	(  bActive,  idRoom,  tiBed,  idShift,  tiIdx,  idStaff,  TempID,  iStamp )
							values			( @bActive, @idRoom, @tiBed, @idShift, @tiIdx, @idStaff, @TempID, @iStamp )
					select	@idStaffAssn=	scope_identity( )
				end
				else	--	log an error in input
				begin
					select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_2( idUnit=' + isnull(cast(@idUnit as varchar),'?') +
							', sRoom=' + isnull(@sRoom,'?') + ', tiBed=' + isnull(cast(@tiBed as varchar),'?') +
							', ixShift=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixStaff=' + isnull(cast(@tiIdx as varchar),'?') +
							', lStaffID=' + isnull(cast(@lStaffID as varchar),'?') + ', TempID=' + isnull(cast(@TempID as varchar),'?') +
							' )  idRoom=' + isnull(cast(@idRoom as varchar),'?') + ', idShift=' + isnull(cast(@idShift as varchar),'?') +
							', idStaff=' + isnull(cast(@idStaff as varchar),'?') + '.'
					exec	pr_Log_Ins	47, null, null, @s
				end
	--		end
			else
				update	tbStaffAssn	set
						TempID= @TempID, iStamp= @iStamp, dtUpdated= getdate( )	--	nothing else to update!!
				--	-	bActive= @bActive, idRoom= @idRoom, tiBed= @tiBed, idShift= @idShift,
				--	-	tiIdx= @tiIdx, idStaff= @idStaff, TempID= @TempID, dtUpdated= getdate( )
					where	idStaffAssn = @idStaffAssn
		end
		else
			exec	dbo.prStaffAssn_Fin	@idStaffAssn

	commit
end
go
grant	execute				on dbo.prStaffAssn_InsUpdDel		to [rWriter]
go
--	----------------------------------------------------------------------------
--	Current (open) staff assignment history (coverage)
--	v.7.00
create view		dbo.vwStaffCover
	with encryption
as
select	sa.idStaffAssn,	sh.idUnit
	,	sa.idShift, sh.sShift, sh.tBeg [tShBeg], sh.tEnd [tShEnd]
	,	sa.idRoom, d.cDevice, d.sDevice [sRoom], d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, sa.tiBed
	,	sa.tiIdx, sa.idStaff, s.lStaffID, s.idStaffLvl, s.sStaffLvl, s.sStaff
	,	sc.idStaffCover, sc.tBeg, sc.tEnd
	,	sa.bActive, sa.dtCreated, sa.dtUpdated
	from	tbStaffCover	sc	with (nolock)
		inner join	tbStaffAssn	sa	with (nolock)	on	sa.idStaffAssn = sc.idStaffAssn
		inner join	tbShift		sh	with (nolock)	on	sh.idShift = sa.idShift
		inner join	vwStaff		s	with (nolock)	on	s.idStaff = sa.idStaff
		inner join	vwDevice	d	with (nolock)	on	d.idDevice = sa.idRoom
	where	sc.tiEnd is null
go
grant	select							on dbo.vwStaffCover		to [rWriter]
grant	select							on dbo.vwStaffCover		to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts or finalizes staff assignments (executes every minute, as close to :00s as possible)
--	v.7.00	+ updating assinged staff in tbRoomBed
--			+ pr_Module_Act call
--			tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssn, prStaffAssn_Fin, prRptStaffCover)
--				prStaffAssn_InsFin -> prStaffCover_InsFin
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--			* set tbUnit.idShift
--	v.6.02
create proc		dbo.prStaffCover_InsFin
	with encryption
as
begin
	declare		@dtNow			datetime
	declare		@tNow			time( 0 )
	declare		@idStaffAssn	int
	declare		@idStaffCover	int

	set	nocount	on

	select	@dtNow= getdate( ), @tNow= getdate( )

	create	table	#tbCurrAssn
	(
		idStaffAssn		int not null
			primary key clustered

	,	bFinish			bit not null
	)

	begin	tran

		exec	pr_Module_Act	1

		--	assignments that are currently running (@ tNow)
		insert	#tbCurrAssn	--(idStaffAssn, bFinish)
			select	idStaffAssn, 1
				from	tbStaffAssn		with (nolock)
				where	bActive > 0		and	idStaffCover > 0

		--	remember previous shift for each active unit
		update	tbUnit	set	idShPrv= idShift		--	no .dtUpdated, because this fires every minute!!
			where	bActive > 0						--	should we skip that (for performance?), or is it even better?

		--	set current shift for each active unit
		update	u	set	u.idShift= sh.idShift
				from	tbUnit u
					inner join	tbShift	sh	on	sh.idUnit = u.idUnit
				where	u.bActive > 0	and	sh.bActive > 0
					and	(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		--	assignments that should be running @ tNow (excluding ones that should end @ tNow)
		declare	cur		cursor fast_forward for
			select	sa.idStaffAssn, sa.idStaffCover
				from	tbStaffAssn	sa		with (nolock)
					inner join	tbShift	sh	with (nolock)	on	sh.idShift = sa.idShift
				where	sa.bActive > 0
					and	(	sh.tBeg <= @tNow  and  @tNow < sh.tEnd
						or	sh.tEnd <= sh.tBeg  and  (sh.tBeg <= @tNow  or  @tNow < sh.tEnd)	)

		open	cur
		fetch next from	cur	into	@idStaffAssn, @idStaffCover
		while	@@fetch_status = 0
		begin
			if	@idStaffCover is null
			begin
				--	begin coverage
				insert	tbStaffCover	(  idStaffAssn, dtBeg, dBeg, tBeg, tiBeg )
						values		( @idStaffAssn, @dtNow, @dtNow, @tNow, datepart( hh, @tNow ) )
				select	@idStaffCover=	scope_identity( )
				update	tbStaffAssn		set	idStaffCover= @idStaffCover, dtUpdated= @dtNow
					where	idStaffAssn= @idStaffAssn
			end
			--	remove assignments that should be running, resulting in ones that need to finish
			update	#tbCurrAssn		set	bFinish= 0
				where	idStaffAssn= @idStaffAssn

			fetch next from	cur	into	@idStaffAssn, @idStaffCover
		end
		close	cur
		deallocate	cur

		--	reset assigned staff in completed assignments
		update	rb	set	rb.idAsnRn= null, rb.idAsnCn= null, rb.idAsnAi= null, dtUpdated= @dtNow
			from	tbRoomBed	rb
			inner join	tbStaffAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
			inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sa.idStaffAssn		and	ca.bFinish = 1

		--	set 'oldest' assigned staff for rooms in units whose shifts have just changed
		--	set '?' assigned staff for rooms across all units
		update	rb	set	rb.idAsnRn= asn.idOldRn, rb.idAsnCn= asn.idOldCn, rb.idAsnAi= asn.idOldAi, dtUpdated= @dtNow
			from	tbRoomBed	rb
			inner join
				(select	t.idRoom, t.tiBed
					,	max(case when t.idStaffLvl = 4 then sa.idStaff else null end) [idOldRn]
					,	max(case when t.idStaffLvl = 2 then sa.idStaff else null end) [idOldCn]
					,	max(case when t.idStaffLvl = 1 then sa.idStaff else null end) [idOldAi]
			--		,	max(case when t.idStaffLvl = 4 then sa.idShift else null end) [idShRn]
			--		,	max(case when t.idStaffLvl = 2 then sa.idShift else null end) [idShCn]
			--		,	max(case when t.idStaffLvl = 1 then sa.idShift else null end) [idShAi]
					from
						(select	rb.idRoom, rb.tiBed, st.idStaffLvl, min(sa.idStaffCover) [idStaffCover]
							from	tbRoomBed	rb
							inner join	tbStaffAssn	sa	on	sa.idRoom = rb.idRoom	and	sa.tiBed = rb.tiBed
							inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sa.idStaffAssn		and	ca.bFinish = 0
							inner join	tbStaff		st	on	st.idStaff = sa.idStaff
							inner join	tbStaffCover	sc	on	sc.idStaffCover = sa.idStaffCover
							group	by	rb.idRoom, rb.tiBed, st.idStaffLvl
						)	t
					inner join	tbStaffAssn	sa	on	sa.idStaffCover = t.idStaffCover
					inner join	tbUnit		u	on	u.idShift = sa.idShift	---	and	(u.idShPrv is null	or	u.idShPrv <> sa.idShift)
					group	by	t.idRoom, t.tiBed
				)	asn		on	asn.idRoom = rb.idRoom	and	asn.tiBed = rb.tiBed

		--	finish coverage for completed assignments
		update	sc	set		dtEnd= @dtNow, dEnd= @dtNow, tEnd= @tNow, tiEnd= datepart( hh, @tNow )
			from	tbStaffCover	sc
			inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sc.idStaffAssn		and	ca.bFinish = 1

		--	reset coverage refs for completed assignments
		update	sa	set		idStaffCover= null, dtUpdated= @dtNow
			from	tbStaffAssn		sa
			inner join	#tbCurrAssn	ca	on	ca.idStaffAssn = sa.idStaffAssn		and	ca.bFinish = 1

	commit
end
go
grant	execute				on dbo.prStaffCover_InsFin			to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns staff assigned to each room-bed (earliest responders of each kind)
--	v.7.00	.tiPtype -> .idStaffLvl
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	v.6.04
/*
create function		dbo.fnStaffAssn_GetByShift
(
	@idShift	smallint					-- shift look-up FK
)
	returns table
	with encryption
as
return
	select	r.idRoom, r.tiBed
		,	min(case when r.idStaffLvl=4 then a.idStaff	else null end)	[idAsnRn]
		,	min(case when r.idStaffLvl=4 then s.sStaff	else null end)	[sAsnRn]
		,	min(case when r.idStaffLvl=2 then a.idStaff	else null end)	[idAsnCn]
		,	min(case when r.idStaffLvl=2 then s.sStaff	else null end)	[sAsnCn]
		,	min(case when r.idStaffLvl=1 then a.idStaff	else null end)	[idAsnAi]
		,	min(case when r.idStaffLvl=1 then s.sStaff	else null end)	[sAsnAi]
		from
			(select	a.idRoom, a.tiBed, s.idStaffLvl, min(a.tiIdx) tiIdx
				from	tbStaffAssn a	with (nolock)
					inner join	tbShift sh	with (nolock)	on	sh.bActive > 0	and	sh.idShift = a.idShift	and	sh.idShift = @idShift
					inner join	tbStaff	s	with (nolock)	on	s.bActive > 0	and	s.idStaff = a.idStaff
				where	a.bActive > 0
				group	by	a.idRoom, a.tiBed, s.idStaffLvl)	r
			inner join	tbStaffAssn a	with (nolock)	on	a.bActive > 0	and	a.idRoom = r.idRoom		and	a.tiBed = r.tiBed	and	a.tiIdx = r.tiIdx
			inner join	tbShift sh		with (nolock)	on	sh.bActive > 0	and	sh.idShift = a.idShift	and	sh.idShift = @idShift
			inner join	vwStaff	s		with (nolock)	on	s.bActive > 0	and	s.idStaff = a.idStaff	and	s.idStaffLvl = r.idStaffLvl	--	s.tiPtype = r.tiPtype
		group	by	r.idRoom, r.tiBed
---		order	by	r.idRoom, r.tiBed
g o
grant	select				on dbo.fnStaffAssn_GetByShift	to [rWriter]
grant	select				on dbo.fnStaffAssn_GetByShift	to [rReader]
*/
go
if	not exists	(select 1 from sys.default_constraints where name='tdRtlsRcvr_Active')
begin
	begin tran
		exec sp_rename 'tdRtlsRcvr_bActive', 'tdRtlsRcvr_Active', 'object'
		exec sp_rename 'tdRtlsRcvr_dtCreated', 'tdRtlsRcvr_Created', 'object'
		exec sp_rename 'tdRtlsRcvr_dtUpdated', 'tdRtlsRcvr_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdRtlsColl_Active')
begin
	begin tran
		exec sp_rename 'tdRtlsColl_bActive', 'tdRtlsColl_bActive', 'object'
		exec sp_rename 'tdRtlsColl_dtCreated', 'tdRtlsColl_Created', 'object'
		exec sp_rename 'tdRtlsColl_dtUpdated', 'tdRtlsColl_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdRtlsSnsr_Active')
begin
	begin tran
		exec sp_rename 'tdRtlsSnsr_bActive', 'tdRtlsSnsr_bActive', 'object'
		exec sp_rename 'tdRtlsSnsr_dtCreated', 'tdRtlsSnsr_Created', 'object'
		exec sp_rename 'tdRtlsSnsr_dtUpdated', 'tdRtlsSnsr_Updated', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdRtlsBadgeType_Active')
begin
	begin tran
		exec sp_rename 'tdRtlsBadgeType_bActive', 'tdRtlsBadgeType_Active', 'object'
		exec sp_rename 'tdRtlsBadgeType_dtCreated', 'tdRtlsBadgeType_Created', 'object'
		exec sp_rename 'tdRtlsBadgeType_dtUpdated', 'tdRtlsBadgeType_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00	+ fkRtlsBadge_StaffDvc (* .idBadge: smallint -> int)
if	not exists	(select 1 from sys.default_constraints where name='tdRtlsBadge_Active')
begin
	begin tran
		drop index	tbRtlsRoom.xuRtlsRoom
		alter table	dbo.tbRtlsRoom
			drop constraint		fkRtlsRoom_Badge
		alter table	dbo.tbRtlsBadge
			drop constraint		xpRtlsBadge
		alter table	dbo.tbRtlsBadge		alter column
			idBadge		int not null				-- 1..65535
		alter table	dbo.tbRtlsRoom		alter column
			idBadge		int not null				-- 1..65535

		set identity_insert	dbo.tbStaffDvc	on

		insert	dbo.tbStaffDvc ( idStaffDvc, idStaff, idStaffDvcType, sStaffDvc )
			select	idBadge, idStaff, 1, 'Badge ' + right('0000' + cast(idBadge as varchar),5)
				from	dbo.tbRtlsBadge

		set identity_insert	dbo.tbStaffDvc	off

		alter table	dbo.tbRtlsBadge		add
			constraint	xpRtlsBadge		primary key clustered (idBadge)
		,	constraint	fkRtlsBadge_StaffDvc	foreign key (idBadge) references tbStaffDvc

		alter table	dbo.tbRtlsRoom		add
			constraint	fkRtlsRoom_Badge	foreign key (idBadge) references tbRtlsBadge
		create unique nonclustered index	xuRtlsRoom	on	dbo.tbRtlsRoom ( idBadge )	where	idBadge is not null

		exec sp_rename 'tdRtlsBadge_bActive', 'tdRtlsBadge_Active', 'object'
		exec sp_rename 'tdRtlsBadge_dtCreated', 'tdRtlsBadge_Created', 'object'
		exec sp_rename 'tdRtlsBadge_dtUpdated', 'tdRtlsBadge_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a given badge
--	v.7.00	* idBadge: smallint -> int
--	v.6.03
alter proc		dbo.prRtlsBadge_InsUpd
(
	@idBadge		int					-- id
,	@idBadgeType	tinyint				-- type
)
	with encryption
as
begin
---	set	nocount	on
	begin	tran
		if exists	( select 1 from tbRtlsBadge where idBadge = @idBadge )
			update	tbRtlsBadge		set	idBadgeType= @idBadgeType, bActive= 1, dtUpdated= getdate( )
				where	idBadge = @idBadge
		else
			insert	tbRtlsBadge (  idBadge,  idBadgeType )
					values		( @idBadge, @idBadgeType )
	commit
end
go
--	----------------------------------------------------------------------------
--	Badges
--	v.7.00	vwRtlsRcvr -> tbRtlsRcvr
--			.tiPtype -> .idStaffLvl
--	v.6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	v.6.04	* .cSGJR -> .sSGJR, .cSGJ -> .sSGJ
--	v.6.03
alter view		dbo.vwRtlsBadge
	with encryption
as
select	b.idBadge, b.idBadgeType, t.sBadgeType
	,	b.idStaff, s.lStaffID, s.idStaffLvl, s.sStaffLvl, s.sStaff	---, s.sFull [tiPtype]
	,	b.idRoom, d.cDevice, d.sDevice, d.sSGJ, d.cSys, d.tiGID, d.tiJID, d.tiRID, b.dtEntered
	,	b.idRcvrCurr, r.sReceiver [sRcvrCurr], b.dtRcvrCurr
	,	b.idRcvrLast, l.sReceiver [sRcvrLast], b.dtRcvrLast
	,	b.bActive, b.dtCreated, b.dtUpdated
	from	tbRtlsBadge		b	with (nolock)
		inner join	tbRtlsBadgeType t	with (nolock)	on	t.idBadgeType = b.idBadgeType
		left outer join	vwStaff		s	with (nolock)	on	s.idStaff = b.idStaff
		left outer join	vwDevice	d	with (nolock)	on	d.idDevice = b.idRoom
		left outer join	tbRtlsRcvr	r	with (nolock)	on	r.idReceiver = b.idRcvrCurr
		left outer join	tbRtlsRcvr	l	with (nolock)	on	l.idReceiver = b.idRcvrLast
go
if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRtlsRoom') and name = 'idStaffLvl')
begin
	begin tran
	--		idStaffLvl	tinyint not null			-- 4=RN, 2=CNA, 1=Aide, ..
		exec sp_rename 'tbRtlsRoom.tiPtype', 'idStaffLvl', 'column'

		alter table	dbo.tbRtlsRoom	add
			constraint	fkRtlsRoom_Level	foreign key (idStaffLvl) references tbStaffLvl

		exec sp_rename 'tdRtlsRoom_bNotify', 'tdRtlsRoom_Notify', 'object'
		exec sp_rename 'tdRtlsRoom_dtUpdated', 'tdRtlsRoom_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates 790 device assigned to a given receiver
--	v.7.00	.tiPtype -> .idStaffLvl
--	v.6.03
alter proc		dbo.prRtlsRcvr_UpdDvc
(
	@idReceiver		smallint			-- receiver look-up FK
,	@idDevice		smallint			-- 790 device look-up FK
)
	with encryption
as
begin
	set	nocount	on

	begin	tran
		if	@idDevice is not null		--	prepare room state
		begin
			if not exists (select 1 from tbRtlsRoom where idRoom=@idDevice and idStaffLvl=1)
				insert tbRtlsRoom (idRoom, idStaffLvl) values (@idDevice, 1)

			if not exists (select 1 from tbRtlsRoom where idRoom=@idDevice and idStaffLvl=2)
				insert tbRtlsRoom (idRoom, idStaffLvl) values (@idDevice, 2)

			if not exists (select 1 from tbRtlsRoom where idRoom=@idDevice and idStaffLvl=4)
				insert tbRtlsRoom (idRoom, idStaffLvl) values (@idDevice, 4)
		end

		update	tbRtlsRcvr	set	dtUpdated= getdate( ), idDevice= @idDevice
			where	idReceiver = @idReceiver
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates location attributes for a given badge
--	v.7.00	.tiPtype -> .idStaffLvl
--	v.6.03
alter proc		dbo.prBadge_UpdLoc
(
	@idBadge		smallint			-- 1-65535 (unsigned)
,	@idRcvrCurr		smallint			-- current receiver look-up FK
,	@dtRcvrCurr		datetime			-- when registered by current rcvr
,	@idRcvrLast		smallint			-- last receiver look-up FK
,	@dtRcvrLast		datetime			-- when registered by last rcvr

,	@idRoomPrev		smallint out		-- previous 790 device look-up FK
,	@idRoomCurr		smallint out		-- current 790 device look-up FK
,	@dtEntered		datetime out		-- when entered the room
,	@idStaffLvl		tinyint out			-- 4=RN, 2=CNA, 1=Aide, ..
,	@cSys			char( 1 ) out		-- system
,	@tiGID			tinyint out			-- G-ID - gateway
,	@tiJID			tinyint out			-- J-ID - J-bus
,	@tiRID			tinyint out			-- R-ID - R-bus
)
	with encryption
as
begin
	declare		@iRetVal		smallint
	declare		@dtNow			datetime
	declare		@idReceiver		smallint
	declare		@idOldest		smallint
	declare		@s		varchar( 255 )

	set	nocount	on

	select	@dtNow= getdate( ), @idOldest= null		--, @tiPtype= null, @cSys= null, @tiGID= null, @tiJID= null, @tiRID= null

	if not exists( select 1 from tbRtlsBadge where idBadge = @idBadge )
	begin
		select	@s=	'Bdg_Loc( B=' + isnull(cast(@idBadge as varchar),'?') +
					' CR=' + isnull(cast(@idRcvrCurr as varchar),'?') + ' CD=' + isnull(convert(varchar, @dtRcvrCurr, 121),'?') +
					' LR=' + isnull(cast(@idRcvrLast as varchar),'?') + ' LD=' + isnull(convert(varchar, @dtRcvrLast, 121),'?') + ' )'

		exec	pr_Log_Ins	49, null, null, @s

		return	-1		--	?? badge does not exist !!
	end

	if	@idRcvrCurr = 0		select	@idRcvrCurr= null
	if	@idRcvrLast = 0		select	@idRcvrLast= null

	select	@idReceiver= idRcvrCurr, @idRoomPrev= idRoom, @dtEntered= dtEntered, @idRoomCurr= null
		,	@idStaffLvl= idStaffLvl, @cSys= cSys, @tiGID= tiGID, @tiJID= tiJID, @tiRID= tiRID		--	previous!!
		from	vwRtlsBadge		where	idBadge = @idBadge

---	select	@s=	@s + ' R=' + isnull(cast(@idReceiver as varchar),'?') + ' P=' + isnull(cast(@idRoomPrev as varchar),'?')
---	exec	pr_Log_Ins	0, null, null, @s

	if	@idReceiver = @idRcvrCurr	return	0		--	badge already at same location => skip

	select	@iRetVal= 1, @idRoomCurr= idDevice		--	new room
		from	tbRtlsRcvr		where	idReceiver = @idRcvrCurr

	begin	tran
		if	@idRoomPrev > 0  and  @idRoomCurr is null	or
			@idRoomCurr > 0  and  @idRoomPrev is null	or
			@idRoomCurr <> @idRoomPrev										--	badge moved [to another room]
		begin
			update	tbRtlsBadge		set	idRoom= @idRoomCurr, dtEntered= @dtNow, @dtEntered= @dtNow
				where	idBadge = @idBadge
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= null		--	remove badge from any room
				where	idBadge = @idBadge
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= @idBadge	--	set for current room [if first]
				where	idRoom = @idRoomCurr	and	idStaffLvl = @idStaffLvl	and	idBadge is null

			select	top 1	@idOldest= idBadge								--	get oldest badge of same type for prev room
				from	vwRtlsBadge
				where	idRoom = @idRoomPrev	and	idStaffLvl = @idStaffLvl	---	and	idBadge is not null		--	not necessary!
				order	by	dtEntered
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= null		--	remove that oldest from any room
				where	idBadge = @idOldest
			update	tbRtlsRoom		set	bNotify= 1, dtUpdated= @dtNow, idBadge= @idOldest	--	set prev room to the oldest badge
				where	idRoom = @idRoomPrev	and	idStaffLvl = @idStaffLvl
			select	@iRetVal= 2, @cSys= null, @tiGID= null, @tiJID= null, @tiRID= null
			select	@cSys= cSys, @tiGID= tiGID, @tiJID= tiJID, @tiRID= tiRID
				from	tbDevice
				where	idDevice = @idRoomCurr
		end

		update	tbRtlsBadge		set	dtUpdated= @dtNow
			,	idRcvrCurr= @idRcvrCurr, dtRcvrCurr= @dtRcvrCurr, idRcvrLast= @idRcvrLast, dtRcvrLast= @dtRcvrLast
			where	idBadge = @idBadge
	commit

	return	@iRetVal
end
go
--	----------------------------------------------------------------------------
--	Rooms 'presense' state (oldest badges)
--	v.7.00	.tiPtype -> .idStaffLvl
--	v.6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	v.6.04	+ .idRn, .idCna, .idAide	min vs. max?
--	v.6.03
alter view		dbo.vwRtlsRoom
	with encryption
as
select	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	min(case when r.idStaffLvl=4 then b.idStaff	else null end)	[idRn]
	,	min(case when r.idStaffLvl=4 then s.sStaff	else null end)	[sRn]
	,	min(case when r.idStaffLvl=2 then b.idStaff	else null end)	[idCn]
	,	min(case when r.idStaffLvl=2 then s.sStaff	else null end)	[sCn]
	,	min(case when r.idStaffLvl=1 then b.idStaff	else null end)	[idAi]
	,	min(case when r.idStaffLvl=1 then s.sStaff	else null end)	[sAi]
	,	max(cast(r.bNotify as tinyint))							[tiNotify]
	,	min(r.dtUpdated)										[dtUpdated]
	from	tbRtlsRoom		r	with (nolock)
		inner join	tbDevice		d	with (nolock)	on	d.idDevice = r.idRoom
		left outer join	tbRtlsBadge	b	with (nolock)	on	b.idBadge = r.idBadge
		left outer join	vwStaff		s	with (nolock)	on	s.idStaff = b.idStaff
	group by	r.idRoom, d.cSys, d.tiGID, d.tiJID, d.tiRID
go
--	----------------------------------------------------------------------------
--	Data source for 7985
--	v.7.00	utilize fnEventA_GetTopByUnit(..)
--			prRoomBed_GetDataByUnits -> prRoomBed_GetByUnit
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.07	* #tbUnit's PK is only idUnit
--			* output, * MV source
--	v.6.05	+ LV: order by ea.bAnswered, WB: and ( ea.tiStype is null	or	ea.tiStype < 16 )
--			+ and ea.tiShelf > 0
--			+ (nolock), MapView
--	v.6.04
create proc		dbo.prRoomBed_GetByUnit
(
--	@idUnit		smallint			-- unit FK
	@sUnits		varchar( 255 )		-- comma-separated idUnit's
,	@tiView		tinyint				-- 0=ListView, 1=WhiteBoard, 2=MapView
)
	with encryption
as
begin
	declare		@i			smallint
	declare		@s			varchar( 400 )
	declare		@idUnit		smallint			-- unit FK
	declare		@idShift	smallint
	declare		@tNow		time( 0 )

	set	nocount on

	create table	#tbUnit						-- no enforcement of FKs
	(
		idUnit		smallint not null			-- unit look-up FK
	,	sUnit		varchar( 16 ) not null		-- unit name
--	,	idShift		smallint null				-- current shift look-up FK

		primary key nonclustered ( idUnit )
	)

	if	@sUnits = '*'	or	@sUnits is null
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
			select	idUnit, sUnit
				from	tbUnit	with (nolock)
				where	bActive > 0		and		idShift > 0
				and		idUnit in (' + @sUnits + ')'
		exec( @s )
	end
--	select	*	from	#tbUnit

	set	nocount off
	if	@tiView = 0			--	ListView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
			,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	cast(null as tinyint) [tiMap]
			from	vwEvent_A				ea	with (nolock)
				inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = ea.idUnit
				left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
				left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
				left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	ea.bActive > 0	and	ea.tiShelf > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed	--	not ea.idEvent because the call may have started earlier than it was 1st recorded!

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
			,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	cast(null as tinyint) [tiMap]
			from	vwRoomBed				rb	with (nolock)
				inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = rb.idUnit
				left outer join	vwEvent_A	ea	with (nolock)	on	ea.idEvent = rb.idEvent		and	ea.bActive > 0	and	ea.tiShelf > 0
				left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
				left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	rb.idUnit is not null
	--?			and	( ea.tiStype is null	or	ea.tiStype < 16 )
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	cast(null as int) [idPatient], cast(null as varchar(16)) [sPatient], cast(null as char(1)) [cGender]
				,	cast(null as varchar(16)) [sInfo], cast(null as varchar(255)) [sNote], cast(null as int) [idDoctor], cast(null as varchar(16)) [sDoctor]
			,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	mc.tiMap
			from	#tbUnit					tu	with (nolock)
				outer apply	fnEventA_GetTopByUnit( tu.idUnit )	ea
				left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
				outer apply	fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
	--			left outer join	tbUnitMapCell	mc	with (nolock)
	--				on	mc.idUnit = tu.idUnit	and	mc.cSys = ea.cSys	and	mc.tiGID = ea.tiGID	and	mc.tiJID = ea.tiJID
end
go
--grant	execute				on dbo.prRoomBed_GetByUnit			to [rWriter]
grant	execute				on dbo.prRoomBed_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	v.7.00	ea.idRoom, ea.sRoom -> r.idDevice [idRoom], r.sDevice [sRoom]
--			utilize fnEventA_GetTopByRoom(..)
--			prMapCell_GetDataByUnitMap -> prMapCell_GetByUnitMap
--			utilize tbUnit.idShift
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.07	* output col-names
--	v.6.05
create proc		dbo.prMapCell_GetByUnitMap
(
	@idUnit		smallint			-- unit FK
,	@tiMap		tinyint
)
	with encryption
as
begin
	select	mc.idUnit, u.sUnit,		mc.cSys, mc.tiGID, mc.tiJID, ea.tiRID, ea.tiBtn
		,	r.idDevice [idRoom], r.sDevice [sRoom], ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
		,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
		,	rb.idAsnRn, rb.sAsnRn,	rb.idAsnCn, rb.sAsnCn,	rb.idAsnAi, rb.sAsnAi
		,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
		,	mc.tiMap, mc.tiCell, mc.sCell1, mc.sCell2, r.siBeds, r.sBeds
		from	tbUnitMapCell			mc	with (nolock)
	---		inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = mc.idUnit
			inner join	tbUnit			u	with (nolock)	on	u.idUnit = mc.idUnit
			left outer join	tbDevice	r	with (nolock)
				on	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0		and	r.bActive > 0
			outer apply	fnEventA_GetTopByRoom( mc.cSys, mc.tiGID, mc.tiJID )	ea
			left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
			left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
			left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		where	mc.idUnit = @idUnit
			and	mc.tiMap = @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go
--grant	execute				on dbo.prMapCell_GetByUnitMap		to [rWriter]
grant	execute				on dbo.prMapCell_GetByUnitMap		to [rReader]
go
if	not exists	(select 1 from sys.default_constraints where name='td_RoleReport_Created')
begin
	begin tran
		exec sp_rename 'td_RoleReport_dtCreated', 'td_RoleReport_Created', 'object'
	commit
end
go
if	not exists	(select 1 from sys.default_constraints where name='tdFilter_Created')
begin
	begin tran
		exec sp_rename 'tdFilter_dtCreated', 'tdFilter_Created', 'object'
		exec sp_rename 'tdFilter_dtUpdated', 'tdFilter_Updated', 'object'
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.00	+ "Room-Bed" -> "Room : Bed";  sorting: idRoom -> sDevice
--			.tiPtype -> .idStaffLvl
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	v.6.02
alter proc		dbo.prRptStaffAssn
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 255=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 255=any, 1=specific (tb_SessStaff), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 255
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
	else
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx [tiShift], h.tBeg, h.tEnd, h.idStaff [idStaffBkup]
					,	d.sDevice + ' : ' + b.cBed [sRoomBed], a.tiIdx [tiStaff], a.dtCreated, a.dtUpdated, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
				---	where	c.dEvent between @dFrom and @dUpto		--	ignore for this report
				---		and	c.tiHH between @tFrom and @tUpto
					order	by h.idUnit, h.tiIdx, d.sDevice, b.cBed, a.tiIdx
end
go
--	----------------------------------------------------------------------------
--	v.7.00	.tiPtype -> .idStaffLvl
--			tbStaffAssn -> tbStaffCover (prStaffAssn_InsFin, prRptStaffCover, tbStaffAssnDef, prStaffAssn_Fin, prRptStaffCover)
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.05	* vwStaff: + tbStaff.sStaff (new), - .sFull;  sFull -> sStaff
--			+ (nolock)
--	v.6.02
alter proc		dbo.prRptStaffCover
(
	@idSess		int					--
,	@dFrom		datetime			-- 
,	@dUpto		datetime			-- 
,	@tFrom		tinyint				-- 
,	@tUpto		tinyint				-- 
,	@tiDvc		tinyint				-- 255=any, 1=specific (tb_SessDvc), 0=<invalid>
,	@tiShift	tinyint				-- 255=any, 1=specific (tb_SessShift), 0=<invalid>
,	@tiStaff	tinyint				-- 255=any, 1=specific (tb_SessStaff), 0=<invalid>
)
	with encryption
as
begin
	if	@tiDvc = 255
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
				--	,	a.idShift, h.idStaff [idStaffBkup], h.tiIdx [tiShift], a.idStaffAssn, a.dtCreated, a.dtUpdated
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
				--		inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
	else
		if	@tiShift = 255
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
				--		inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
		else
			if	@tiStaff = 255
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
				--		inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
			else
				select	h.idUnit, u.sUnit, a.idRoom, d.sDevice, a.tiBed, b.cBed, d.sDevice + '-' + b.cBed [sRoomBed]
					,	p.dBeg, p.tBeg, p.dEnd, p.tEnd, h.sShift, a.tiIdx [tiStaff], a.idStaff, s.lStaffID, s.sStaff, s.sStaffLvl
					from			tbStaffAssn		a	with (nolock)
						inner join	tbStaffCover	p	with (nolock)	on	p.idStaffAssn = a.idStaffAssn
						inner join	tb_SessDvc		sr	with (nolock)	on	sr.idDevice = a.idRoom	and	sr.idSess = @idSess
						inner join	tb_SessShift	sh	with (nolock)	on	sh.idShift = a.idShift	and	sh.idSess = @idSess
						inner join	tb_SessStaff	st	with (nolock)	on	st.idStaff = a.idStaff	and	st.idSess = @idSess
						inner join	tbShift			h	with (nolock)	on	h.idShift = a.idShift
						inner join	tbUnit			u	with (nolock)	on	u.idUnit = h.idUnit
						inner join	tbDevice		d	with (nolock)	on	d.idDevice = a.idRoom
						inner join	tbDefBed		b	with (nolock)	on	b.idIdx = a.tiBed
						inner join	vwStaff			s	with (nolock)	on	s.idStaff = a.idStaff
					where	p.dBeg between @dFrom and @dUpto
						or	p.dEnd between @dFrom and @dUpto
					order	by h.idUnit, a.idRoom, b.cBed, p.idStaffCover, a.tiIdx
end
go


if	exists	( select 1 from tb_Version where idVersion = 700 )
	update	dbo.tb_Version	set	dtCreated= '2012-12-07', siBuild= 4724, dtInstall= getdate( )
		,	sVersion= '7.00.4724 - stn-vers; staff levels, devices; auto: stn-units, current shifts'
		where	idVersion = 700
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 700,	4724, '2012-12-07', getdate( ),	'7.00.4724 - stn-vers; staff levels, devices; auto: stn-units, current shifts' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.0.4724'
	where	idModule = 1
go

checkpoint
go

use [master]
go
