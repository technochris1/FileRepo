--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.03
--		2013-Feb-15		.4794
--						+ prFilter_Get, prFilter_InsUpd, prFilter_Del
--						+ prSchedule_Get, prSchedule_InsUpd, prSchedule_Upd, prSchedule_Del
--						* tb_Option, tb_OptionSys: + [12,13,14]	* [5-10]
--						+ tdSchedule_Result
--		2013-Feb-18		.4797
--						+ pr_Sess_Clr (pr_Sess_Del)
--		2013-Feb-19		.4798
--						* tb_Option, tb_OptionSys: + [15]
--						+ prSchedule_GetToRun
--		2013-Feb-21		.4800
--						+ prDefBed_GetAll, prDefLoc_GetAll, prUnit_GetAll, prDevice_GetAll, prShift_GetAll
--		2013-Feb-25		.4804
--						* prRoomBed_GetByUnit, fnEventA_GetTopByUnit
--		2013-Mar-12		.4819
--						* tb_Option, tb_OptionSys: + [16]
--		2013-Mar-13		.4820
--						* tb_LogType: + [34,35,90]
--						+ pr_OptionSys_GetSmtp
--						* tbSchedule.iResult: smallint -> int
--		2013-Mar-15		.4822
--						+ prReport_GetAll, prFilter_GetByUser
--						+ pr_SessCall_Ins, pr_SessLoc_Ins, pr_SessDvc_Ins, pr_SessStaff_Ins, pr_SessShift_Ins
--		2013-Mar-20		.4827
--						* prDevice_GetIns
--						* tb_Option, tb_OptionSys: + [17]
--						* prEvent_Ins
--		2013-Mar-21		.4828
--						* prDevice_UpdRoomBeds
--		2013-Mar-26		.4833
--						* pr_Sess_Del: + @bLog= 1
--						* pr_Sess_Act, pr_Module_Upd
--		2013-Mar-27		.4834
--						* prPatient_GetIns, prEvent84_Ins, prEvent98_Ins
--		2013-Mar-28		.4835
--						* pr_User_Login, pr_User_Logout
--						* prEvent_Maint
--		2013-Mar-29		.4836
--						http://stackoverflow.com/questions/15693359/tvf-output-is-missing-computed-column-from-view-it-references
--						* fnEventA_GetTopByUnit, fnEventA_GetTopByRoom: expanded * -> list of all vwEvent_A columns
--		2013-Apr-02		.4840
--						* tb_Module: + [20]
--		2013-Apr-05		.4843
--						+ tbCfgFlt, prCfgFlt_DelAll, prCfgFlt_Ins, prCfgFlt_GetAll
--						+ tbDefCallP.iFilter (prDefCallP_Ins)
--		2013-Apr-08		.4846
--						+ tbCfgFlt.idIdx - PK [bitmask 0x80000000 becomes -2147483648] (prCfgFlt_Ins, prCfgFlt_GetAll)
--		2013-Apr-09		.4847
--						* vwEvent_A, fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit
--		2013-Apr-09		.4848
--						* prMapCell_GetByUnitMap
--		2013-Apr-15		.4853
--						* prDevice_UpdRoomBeds7980: fix for room renames
--		2012-Apr-16		.4854
--						* prDevice_UpdRoomBeds: fix for room renames
--		2012-Apr-19		.4857
--						+ tbCfgMst, prCfgMst_Clr, prCfgMst_Ins
--					//	* tbRoom: explicit PK name - xpRoom!	not adjusted
--						* tbEvent_A: + .tiCvrg[0..7] (vwEvent_A, prEvent84_Ins, fnEventA_GetTopByUnit, fnEventA_GetTopByRoom)
--						* vwDefLoc_CaUnit -> vwDefLoc_Cvrg, .idCArea -> .idCvrg, .sCArea -> .sCvrg
--		2012-Apr-22		.4860
--						+ fnEventA_GetByMaster (fnEventA_GetTopByUnit, fnEventA_GetTopByRoom, prRoomBed_GetByUnit, prMapCell_GetByUnitMap)
--		2012-Apr-24		.4862
--						* permissions adjust for db7980 (Jeremy's tables)
--						* db7980::prDefLoc_SetLvl
--						+ vwRoom
--						+ prCfgDvc_Init
--		2012-Apr-25		.4863
--						* prRoom_Upd: + @idUnit (prEvent84_Ins)
--		2012-Apr-26		.4864
--						* fnEventA_GetByMaster fix
--		2012-Apr-29		.4867
--						* tbStaff: + .bOnDuty (vwStaff)
--		2012-Apr-30		.4868
--						* fnEventA_GetByMaster: fix @idMaster
--		2013-May-07		.4875
--						+ tbCfgDvcBtn, prCfgDvcBtn_Clr, prCfgDvcBtn_Ins
--		2013-May-09		.4877
--						* tbUnitMapCell: + .tiRID1, tiBtn1, .tiRID2, .tiBtn2, .tiRID4, .tiBtn4
--						* prPatient_GetIns (prEvent84_Ins, prEvent98_Ins)
--						+ prRoomBed_UpdPat, 
--		2013-May-10		.4878
--						* vwRoom -> vwRoomAct
--						* tbDoctor (prDoctor_GetIns, prDoctor_Upd), tbPatient (prPatient_GetIns, prPatient_Upd) moved after tbRoomBed
--							tbRoomBed.idPatient -> tbPatient.idRoom + .tiBed (+ tbPatient.fkPatient_RoomBed)
--						* tbStaffAssn: fkStaffAssn_Room -> fkStaffAssn_RoomBed
--						* prRoomBed_UpdPat -> prPatient_UpdLoc
--		2013-May-15		.4883
--						* pr_Sess_Del: fix pr_User_Logout call (was not passing @idSess)
--						- fkStaffAssn_StaffCover: no longer supported - causes trouble for deletes!
--		2013-May-22		.4890
--						* prStaff_GetAll (order by)
--						+ prRoom_GetAct, prRtlsRcvr_GetAll, prRtlsSnsr_GetAll, prRtlsBadge_GetAll, prStaffDvc_UpdStf
--						* prRtlsRcvr_UpdDvc
--		2013-May-23		.4891
--						* vwRoomAct: + .cDevice
--						+ prUnitMap_GetAll, prUnitMap_Upd, prMapCell_GetByUnit
--						* tbUnitMapCell: + .idRoom, -.bSwing
--		2013-Jun-26		.4925 (4884)
--						* prStaffAssn_InsUpdDel
--						* prStaffAssnDef_Exp
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
	if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 703 and siBuild >= 4925 order by idVersion desc)
		raiserror( 'DB is already at target version - 7.03.4925', 18, 0 )

go

if exists	(select 1 from dbo.sysobjects where uid=1 and name='fnEventA_GetByMaster')
	drop function	dbo.fnEventA_GetByMaster
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_Sess_Clr')
	drop proc	dbo.pr_Sess_Clr
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessShift_Ins')
	drop proc	dbo.pr_SessShift_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessStaff_Ins')
	drop proc	dbo.pr_SessStaff_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessDvc_Ins')
	drop proc	dbo.pr_SessDvc_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessLoc_Ins')
	drop proc	dbo.pr_SessLoc_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_SessCall_Ins')
	drop proc	dbo.pr_SessCall_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_Del')
	drop proc	dbo.prSchedule_Del
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_Upd')
	drop proc	dbo.prSchedule_Upd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_InsUpd')
	drop proc	dbo.prSchedule_InsUpd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_GetToRun')
	drop proc	dbo.prSchedule_GetToRun
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prSchedule_Get')
	drop proc	dbo.prSchedule_Get
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_Del')
	drop proc	dbo.prFilter_Del
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_InsUpd')
	drop proc	dbo.prFilter_InsUpd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_Get')
	drop proc	dbo.prFilter_Get
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prFilter_GetByUser')
	drop proc	dbo.prFilter_GetByUser
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prReport_GetAll')
	drop proc	dbo.prReport_GetAll
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsBadge_GetAll')
	drop proc	dbo.prRtlsBadge_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsSnsr_GetAll')
	drop proc	dbo.prRtlsSnsr_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRtlsRcvr_GetAll')
	drop proc	dbo.prRtlsRcvr_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvc_Init')
	drop proc	dbo.prCfgDvc_Init
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prShift_GetAll')
	drop proc	dbo.prShift_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoomBed_UpdPat')
	drop proc	dbo.prRoomBed_UpdPat
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prMapCell_GetByUnit')
	drop proc	dbo.prMapCell_GetByUnit
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMap_Upd')
	drop proc	dbo.prUnitMap_Upd
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnitMap_GetAll')
	drop proc	dbo.prUnitMap_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prPatient_UpdLoc')
	drop proc	dbo.prPatient_UpdLoc
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prRoom_GetAct')
	drop proc	dbo.prRoom_GetAct
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaffDvc_UpdStf')
	drop proc	dbo.prStaffDvc_UpdStf
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prStaff_GetAll')
	drop proc	dbo.prStaff_GetAll
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvcBtn_Ins')
	drop proc	dbo.prCfgDvcBtn_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgDvcBtn_Clr')
	drop proc	dbo.prCfgDvcBtn_Clr
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgMst_Ins')
	drop proc	dbo.prCfgMst_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgMst_Clr')
	drop proc	dbo.prCfgMst_Clr
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prDevice_GetAll')
	drop proc	dbo.prDevice_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prUnit_GetAll')
	drop proc	dbo.prUnit_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefLoc_GetAll')
	drop proc	dbo.prDefLoc_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefCall_GetAll')
	drop proc	dbo.prDefCall_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_GetAll')
	drop proc	dbo.prCfgFlt_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_Ins')
	drop proc	dbo.prCfgFlt_Ins
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prCfgFlt_DelAll')
	drop proc	dbo.prCfgFlt_DelAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='prDefBed_GetAll')
	drop proc	dbo.prDefBed_GetAll
if exists	(select 1 from dbo.sysobjects where uid=1 and name='pr_OptionSys_GetSmtp')
	drop proc	dbo.pr_OptionSys_GetSmtp
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRoom')
	drop view	dbo.vwRoom
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwRoomAct')
	drop view	dbo.vwRoomAct
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDefLoc_CaUnit')
	drop view	dbo.vwDefLoc_CaUnit
if exists	(select 1 from dbo.sysobjects where uid=1 and name='vwDefLoc_Cvrg')
	drop view	dbo.vwDefLoc_Cvrg
go
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgDvcBtn')
	drop table	dbo.tbCfgDvcBtn
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgMst')
	drop table	dbo.tbCfgMst
if exists	(select 1 from dbo.sysobjects where uid=1 and name='tbCfgFlt')
	drop table	dbo.tbCfgFlt
go

--	----------------------------------------------------------------------------
--	v.7.03	+ [12-16]	* [5-10]
if not exists	(select 1 from dbo.tb_Option where idOption > 11)
begin
	begin tran
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 12, 167, 'SMTP host' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 13,  56, 'SMTP port' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 14,  56, 'SMTP SSL?' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 15, 167, 'SMTP user' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 16, 167, 'SMTP pass' )								--	7.03
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 17, 167, 'SMTP from' )								--	7.03

		update	dbo.tb_Option	set	sOption=	'(internal) Data-import iStamp'				where	idOption = 5
		update	dbo.tb_Option	set	sOption=	'Logs folder path (''\''-terminated)'		where	idOption = 6
		update	dbo.tb_Option	set	sOption=	'(internal) Event recording mode'			where	idOption = 7
		update	dbo.tb_Option	set	sOption=	'(internal) 790 config trace mode'			where	idOption = 8
		update	dbo.tb_Option	set	sOption=	'(internal) Expiration window (Nrm)'		where	idOption = 9
		update	dbo.tb_Option	set	sOption=	'(internal) Expiration window (Ext)'		where	idOption = 10

		insert	dbo.tb_OptionSys ( idOption, sValue )	values	( 12, '' )
		insert	dbo.tb_OptionSys ( idOption, iValue )	values	( 13, 25 )
		insert	dbo.tb_OptionSys ( idOption, iValue )	values	( 14, 0 )
		insert	dbo.tb_OptionSys ( idOption, sValue )	values	( 15, '' )
		insert	dbo.tb_OptionSys ( idOption, sValue )	values	( 16, '' )
		insert	dbo.tb_OptionSys ( idOption, sValue )	values	( 17, '' )
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.03	+ [20]
--			+ [93] reactivated
if not exists	(select 1 from dbo.tb_Module where idModule=93)
begin
	begin tran
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )			--	v.7.03
			values	(  93, 'J7983ss', 4, 0, '7983 Scheduler Service' )
	commit
end
go
if not exists	(select 1 from dbo.tb_Module where idModule=93)
begin
	begin tran
		insert	dbo.tb_Module ( idModule, sModule, tiModType, bLicense, sDesc )
			values	(  20, 'J7970as', 4, 0, '7970 Voice Prompt Service' )
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns SMTP settings
--	v.7.03
create proc		dbo.pr_OptionSys_GetSmtp
	with encryption
as
begin
--	set	nocount	on
	select	idOption, iValue, fValue, tValue, sValue
		from	tb_OptionSys	with (nolock)
		where	idOption	between 12 and 17
end
go
grant	execute				on dbo.pr_OptionSys_GetSmtp			to [rWriter]
grant	execute				on dbo.pr_OptionSys_GetSmtp			to [rReader]
go
--	----------------------------------------------------------------------------
--	v.7.03	* [231,236]
--			+ [34,35,90]
begin tran
	if not exists	(select 1 from dbo.tb_LogType where idLogType = 34)
		insert	dbo.tb_LogType ( idLogType, tiLevel, tiSource, sLogType )	values	( 34,  2, 2, 'Service Woke-up' )		--	7.03
	else
		update	dbo.tb_LogType	set	tiLevel= 2, tiSource= 2, sLogType= 'Service Woke-up'	where	idLogType = 34

	if not exists	(select 1 from dbo.tb_LogType where idLogType = 35)
		insert	dbo.tb_LogType ( idLogType, tiLevel, tiSource, sLogType )	values	( 35,  2, 2, 'Service Asleep' )			--	7.03
	else
		update	dbo.tb_LogType	set	tiLevel= 2, tiSource= 2, sLogType= 'Service Asleep'		where	idLogType = 35

	if not exists	(select 1 from dbo.tb_LogType where idLogType = 90)
		insert	dbo.tb_LogType ( idLogType, tiLevel, tiSource, sLogType )	values	( 90,  2, 2, 'Exec Schedule' )			--	7.03
	else
		update	dbo.tb_LogType	set	tiLevel= 2, tiSource= 2, sLogType= 'Exec Schedule'		where	idLogType = 90

	update	dbo.tb_LogType	set	sLogType= 'Upd settings (user)'		where	idLogType = 231
	update	dbo.tb_LogType	set	sLogType= 'Upd settings (sys)'		where	idLogType = 236
commit
go
if not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tb_User') and name = 'tiFails')
begin
	begin tran
		exec sp_rename 'tb_User.tiFailed', 'tiFails', 'column'
	commit
end
go
--	----------------------------------------------------------------------------
--	Logs in a user and provides certain details about him.  Returns tb_Type.idType
--	v.7.03	+ @idSess, .tiFailed -> .tiFails
--			* optimize desc-string
--	v.7.00	* td*_bActive -> td*_Active, td*_dtCreated -> td*_Created, td*_dtUpdated -> td*_Updated
--			tb_User: * .bEnabled -> .bActive
--	v.6.05	+ (nolock), transaction
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.02	* tb_Log.idType rearranged
--	v.6.00
alter proc		dbo.pr_User_Login
(
	@idSess		int					-- session-id
,	@sUser		varchar( 32 )		-- login-name, lower-cased
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
	declare		@bActive	bit
	declare		@bLocked	bit
	declare		@idLogType	tinyint
	declare		@tiFails	tinyint
	declare		@tiMaxAtt	tinyint

	set	nocount	on

	select	@tiMaxAtt= cast(iValue as tinyint)	from	tb_OptionSys	with (nolock)	where	idOption = 2

	select	@s= '@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

	select	@idUser= idUser, @iHash= iHash, @bActive= bActive, @bLocked= bLocked, @tiFails= tiFails, @sFirst= sFirst, @sLast= sLast
		from	tb_User		with (nolock)
		where	sUser = lower( @sUser )

	if	@idUser is null			--	wrong user
	begin
		select	@idLogType=	222,	@s=	@s + ', ''' + isnull( @sUser, '?' ) + ''''
		exec	dbo.pr_Log_Ins	@idLogType, null, null, @s
		return	@idLogType
	end

	if	@bLocked = 1			--	locked-out
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
				update	tb_User		set	tiFails= tiFails + 1, bLocked= 1
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
		update	tb_Sess		set	idUser= @idUser
			where	idSess = @idSess
		update	tb_User		set	tiFails= 0, dtLastAct= getdate( )
			where	idUser = @idUser
		exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
	commit
	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Logs out a user
--	v.7.03	+ @idSess
--			* optimize desc-string
--	v.6.05	+ (nolock)
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.00
alter proc		dbo.pr_User_Logout
(
	@idSess		int
,	@idLogType	tinyint				-- type look-up FK
,	@idUser		smallint			-- user look-up FK
,	@sIpAddr	varchar( 40 )		-- IPv4 (15) or IPv6 (39) address
,	@sMachine	varchar( 32 )		-- client computer's name
)
	with encryption
as
begin
	declare		@s			varchar( 255 )

	set	nocount	on

	if	@idUser > 0
	begin
		begin	tran
			update	tb_Sess		set	idUser= null
				where	idSess = @idSess

			select	@s= '@ ' + isnull( @sMachine, '?' ) + ' (' + isnull( @sIpAddr, '?' ) + ')'

			exec	dbo.pr_Log_Ins	@idLogType, @idUser, null, @s
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Marks a session with latest activity
--	v.7.03	+ pr_Module_Act 63 call
--	v.7.00	+ pr_Module_Act 92 call
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
		exec	pr_Module_Act	63		-- v.7.03
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
--	Returns all beds, ordered to be loadable into a tree
--	v.7.03
create proc		dbo.prDefBed_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idIdx
		from	dbo.tbDefBed	with (nolock)
		where	bInUse > 0
end
go
grant	execute				on dbo.prDefBed_GetAll				to [rWriter]
grant	execute				on dbo.prDefBed_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Filter definitions (790 global configuration)
--	v.7.03
create table	dbo.tbCfgFlt
(
	idIdx		tinyint not null			-- filter idx
		constraint	xpCfgFlt	primary key clustered

,	iFilter		int not null				-- filter bits
,	sFilter		varchar( 16 ) not null		-- filter name

,	dtCreated	smalldatetime not null		-- internal: record creation
		constraint	tdCfgFlt_Created	default( getdate( ) )
--,	dtUpdated	smalldatetime not null		-- internal: last modified
--		constraint	tdCfgFlt_Updated	default( getdate( ) )
)
go
grant	select, insert, update, delete	on dbo.tbCfgFlt			to [rWriter]
grant	select							on dbo.tbCfgFlt			to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all filter definitions
--	v.7.03
create proc		dbo.prCfgFlt_DelAll
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgFlt
		select	@s= 'CfgFlt_Clear( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgFlt_DelAll				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a filter definition
--	v.7.03
create proc		dbo.prCfgFlt_Ins
(
	@idIdx		tinyint				-- filter idx
,	@iFilter	int					-- filter bits
,	@sFilter	varchar( 16 )		-- filter name
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
	--	begin
			insert	tbCfgFlt	(  idIdx,  iFilter,  sFilter )
					values		( @idIdx, @iFilter, @sFilter )
	--		select	@s= @s + ' INS.'
	--	end

		if	@iTrace & 0x40 > 0
		begin
			select	@s= 'CfgFlt_I( ' + isnull(cast(@idIdx as varchar), '?') + ', f=' + isnull(cast(@iFilter as varchar), '?') + ', n=' + isnull(@sFilter, '?') + ' )'
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgFlt_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all filter definitions
--	v.7.03
create proc		dbo.prCfgFlt_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idIdx, iFilter, sFilter
		from	dbo.tbCfgFlt	with (nolock)
end
go
grant	execute				on dbo.prCfgFlt_GetAll				to [rWriter]
grant	execute				on dbo.prCfgFlt_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	v.7.03	+ .iFilter
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbDefCallP') and name = 'iFilter')
begin
	begin tran
		alter table	dbo.tbDefCallP		add
			iFilter		int null					-- priority filter-mask
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
--	v.7.03	+ @iFilter
--	v.6.05
alter proc		dbo.prDefCallP_Ins
(
	@siIdx		smallint			-- call-index
,	@sCall		varchar( 16 )		-- call-text
,	@tiFlags	tinyint				-- bit flags: 1=locking, 2=enabled
,	@tiShelf	tinyint				-- shelf: 0=nondisplay, 1=routine, 2=urgent, 3=emergency, 4=code
,	@tiSpec		tinyint				-- 0=, 1=, .. , 18=
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

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
	--	begin
			insert	tbDefCallP	(  idIdx,  sCall,  tiFlags,  tiShelf,  tiSpec,  iColorF,  iColorB,  iFilter )
					values		( @siIdx, @sCall, @tiFlags, @tiShelf, @tiSpec, @iColorF, @iColorB, @iFilter )
	--		select	@s= @s + ' INS.'
	--	end

		if	@iTrace & 0x40 > 0
		begin
			select	@s= 'CallP_I( ' + isnull(cast(@siIdx as varchar), '?') + ', n=' + isnull(@sCall, '?') +
						', f=' + isnull(cast(@tiFlags as varchar), '?') + ', sh=' + isnull(cast(@tiShelf as varchar), '?') +
						', sp=' + isnull(cast(@tiSpec as varchar), '?') + ', cf=' + isnull(cast(@iColorF as varchar), '?') +
						', cb=' + isnull(cast(@iColorB as varchar), '?') + ', fm=' + isnull(cast(@iFilter as varchar), '?') + ' )'
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all call-priorities, ordered to be loadable into a table
--	v.7.03
create proc		dbo.prDefCall_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idCall, cast(1 as bit) [bInclude], siIdx, c.sCall, tVoTrg, tStTrg, iColorF, iColorB
		from	tbDefCall	c	with (nolock)
		inner join	tbDefCallP	p	with (nolock)	on	p.sCall = c.sCall	and p.idIdx = c.siIdx
		where	bActive > 0	and	bEnabled > 0	and	p.tiShelf > 0	and	(p.tiSpec is null or p.tiSpec < 6 or p.tiSpec = 18)
		order	by	siIdx desc
end
go
grant	execute				on dbo.prDefCall_GetAll				to [rWriter]
grant	execute				on dbo.prDefCall_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Coverage areas and their units
--	v.7.03	* vwDefLoc_CaUnit -> vwDefLoc_Cvrg, .idCArea -> .idCvrg, .sCArea -> .sCvrg
--	v.7.00
create view		dbo.vwDefLoc_Cvrg
	with encryption
as
select ca.idLoc [idCvrg], ca.sLoc [sCvrg], u.idLoc [idUnit], u.sLoc [sUnit]
	from	tbDefLoc ca		with (nolock)
	inner join	tbDefLoc u	with (nolock)	on	u.idLoc = ca.idParent	and	u.tiLvl = 4
	where	ca.tiLvl = 5
go
grant	select, insert, update			on dbo.vwDefLoc_Cvrg	to [rWriter]
grant	select							on dbo.vwDefLoc_Cvrg	to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all locations, ordered to be loadable into a tree
--	v.7.03
create proc		dbo.prDefLoc_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idLoc, idParent, cLoc, sLoc, tiLvl
		from	tbDefLoc	with (nolock)
		where	tiLvl < 5		--	everything but coverage areas
		order	by	tiLvl, idLoc
end
go
grant	execute				on dbo.prDefLoc_GetAll				to [rWriter]
grant	execute				on dbo.prDefLoc_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all units, ordered to be loadable into a tree
--	v.7.03
create proc		dbo.prUnit_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	u.idUnit, u.sUnit
		from	tbUnit u	with (nolock)
		inner join	tbDefLoc l	with (nolock)	on	l.idLoc = u.idUnit
		where	u.bActive > 0
		order	by	u.sUnit
end
go
grant	execute				on dbo.prUnit_GetAll				to [rWriter]
grant	execute				on dbo.prUnit_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all devices, ordered to be loadable into a tree
--	v.7.03
create proc		dbo.prDevice_GetAll
(
	@tiKind		tinyint		-- 0 = top-level (no parent), >0 = children
)
	with encryption
as
begin
--	set	nocount	on
	if	@tiKind = 0
		select	idDevice, idParent, cDevice, sDevice, sDial
			from	tbDevice	with (nolock)
			where	idParent is null
			order	by	tiGID, sDevice
	else
		select	idDevice, idParent, cDevice, sDevice, sDial
			from	tbDevice	with (nolock)
			where	idParent > 0
			order	by	idParent, sDevice
end
go
grant	execute				on dbo.prDevice_GetAll				to [rWriter]
grant	execute				on dbo.prDevice_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
update	tbDevice	set	sDial=	null
	where	iAID is null	and tiStype = 0
go
--	----------------------------------------------------------------------------
--	Finds devices and inserts if necessary (not found)
--	v.7.03	* 7967-P detection and handling
--	v.6.07	- device matching by name
--	v.6.05	tracing reclassified 42 -> 74
--			+ (nolock)
--	v.6.04	* replaces 7967-P workflow station's (0x1A) 'phantom' RIDs with parent device - workflow itself
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			* use isnull(..,'?') for @iAID, @tiStype args
--	v.6.02	* .tiRID is never NULL now - added download of all stations
--			+ @cSys (+ tbDevice.cSys), order of @rgs (prEvent_Ins)
--	v.6.00	tbDefDevice -> tbDevice (FKs)
--	v.5.01	encryption added
--			+ @iAID, @tiStype
--	v.3.01
--	v.2.03	(prEvent*_Ins, 84, 8A, A7)
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
	declare		@idParent	smallint
	declare		@iTrace		int
	declare		@s			varchar( 255 )
	declare		@bActive	bit

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	select	@s=	'Dvc_I( s=' + @cSys + ', g=' + cast(@tiGID as varchar) + ', j=' + cast(@tiJID as varchar) + ', r=' + cast(@tiRID as varchar) +
				', aid=' + isnull(cast(@iAID as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') + ', c=' + @cDevice +
				', n=' + @sDevice + ', d=' + isnull(@sDial,'?') + ' )'

	if	@idDevice is null	and	@tiStype = 0	and	@iAID = 0	and	@tiRID between 2 and 7		--	7967-P workflow station's (0x1A) 'phantom' RIDs		--	v.7.03
	begin
		select	@sDial=		null		---	force no dial# for 'phantom' RIDs
			--,	@tiStype=	26			---	?? mark 'phantom' RID as workflow
		select	@idDevice=	idDevice, @bActive=	bActive
			from	tbDevice	with (nolock)
			where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	--and	bActive > 0
		if	@idDevice > 0
		begin
			if	@bActive = 0
				update	tbDevice	set	bActive= 1
					where	idDevice = @idDevice
			return	0
		end
	end

	if	@iAID = 0xFFFFFFFF	or	@iAID = 0x00FFFFFF	or	@iAID = 0
		select	@iAID=	null
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0	and	@iAID > 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	iAID = @iAID	and	bActive > 0
	if	@idDevice is null	and	@tiGID > 0	and	@tiJID >= 0	and	@tiRID >= 0
		select	@idDevice= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = @tiRID	and	bActive > 0
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

--	if	@idDevice > 0	and	@tiStype = 26	and	@tiRID > 0		--	replace 7967-P workflow station's (0x1A) 'phantom' RIDs		--	v.6.04
--	begin
--		select	@idDevice=	idParent	from	tbDevice	with (nolock)	where	idDevice = @idDevice
--		return	0
--	end

	if	@idDevice is null	and	len( @sDevice ) > 0
	begin
		if	@tiRID > 0						-- R-bus device
			select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	tiRID = 0	and	bActive > 0
		if	@tiJID > 0	and	@tiRID = 0		-- J-bus device
			select	@idParent= idDevice		from	tbDevice	with (nolock)	where	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = 0	and	bActive > 0

		begin	tran
			insert	tbDevice	(  idParent,  cSys,  tiGID,  tiJID,  tiRID,  iAID,  tiStype,  cDevice,  sDevice,  sDial )
					values		( @idParent, @cSys, @tiGID, @tiJID, @tiRID, @iAID, @tiStype, @cDevice, @sDevice, @sDial )
			select	@idDevice=	scope_identity( )

			if	@iTrace & 0x04 > 0
			begin
				select	@s=	@s + '  id=' + cast(@idDevice as varchar) + ', p=' + isnull(cast(@idParent as varchar),'?')
				exec	pr_Log_Ins	74, null, null, @s
			end
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Returns devices/rooms/masters for given unit
--	v.7.03	+ added 7967-P to 'rooms' output
--	v.7.02	* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
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
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiRID =0	and	(d.tiStype between 4 and 7		-- room controllers
								or	d.idDevice in (select idParent from tbDevice with (nolock) where tiRID =1 and tiStype =26)))
						or	(@tiKind = 2	and	d.tiRID =0	and	d.tiStype between 8 and 11))	-- masters
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
					and		(@tiKind = 0														-- any
						or	(@tiKind = 1	and	d.tiRID =0	and	(d.tiStype between 4 and 7		-- room controllers
								or	d.idDevice in (select idParent from tbDevice with (nolock) where tiRID =1 and tiStype =26)))
			--			or	(@tiKind = 1	and	d.tiStype between 4 and 7	and	d.tiRID = 0)	-- room controllers
						or	(@tiKind = 2	and	d.tiStype between 8 and 11	and	d.tiRID = 0))	-- masters
	end

	set	nocount	off
	select	d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.sDial, r.sBeds
		,	cast((len(d.sUnits) + 1) / 4 as tinyint) [tiSwing], d.sUnits						-- # of 'swing' units
		,	d.bActive, d.dtCreated, d.dtUpdated		--, d.sQnDevice, d.sFnDevice
		from	tbDevice	d	with (nolock)
		inner join	#tbDevice	t	with (nolock)	on	t.idDevice = d.idDevice
		left outer join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice					-- v.7.02
		order	by	d.sDevice, d.bActive desc, d.dtCreated desc
end
go
--	----------------------------------------------------------------------------
--	Master attributes (790 global configuration)
--	v.7.03
create table	dbo.tbCfgMst
(
	idMaster	smallint not null			-- 790 device look-up FK
--		constraint	xpCfgMst	primary key clustered
		constraint	fkCfgMst_CfgDvc		foreign key references tbDevice
--,	tiIdx		tinyint not null			-- CA index
,	tiCvrg		tinyint not null			-- CA (0xFF == all, store as 0? - to force reading it first!?)

,	iFilter		int not null				-- filter bits for this CA

,	constraint	xpCfgMst	primary key clustered ( idMaster, tiCvrg )
/*
,	dtCreated	smalldatetime not null		-- internal: record creation
		constraint	tdCfgMst_Created	default( getdate( ) )
--,	dtUpdated	smalldatetime not null		-- internal: last modified
--		constraint	tdCfgMst_Updated	default( getdate( ) )
*/
)
go
grant	select, insert, update, delete	on dbo.tbCfgMst			to [rWriter]
grant	select							on dbo.tbCfgMst			to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all master attributes
--	v.7.03
create proc		dbo.prCfgMst_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgMst
		select	@s= 'CfgMst_Clr( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgMst_Clr					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a master attributes record
--	v.7.03
create proc		dbo.prCfgMst_Ins
(
	@idMaster	smallint			-- device (PK)
,	@tiCvrg		tinyint				-- CA
,	@iFilter	int					-- filter bits for this CA
)
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	if	@tiCvrg = 0xFF		select	@tiCvrg= 0		--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgMst with (nolock) where idMaster = @idMaster and tiCvrg = @tiCvrg)
	begin
		begin	tran
			insert	tbCfgMst	(  idMaster,  tiCvrg,  iFilter )
					values		( @idMaster, @tiCvrg, @iFilter )
	--		select	@s= @s + ' INS.'

			if	@iTrace & 0x40 > 0
			begin
				select	@s= 'CfgMst_I( ' + isnull(cast(@idMaster as varchar), '?') +
							', c=' + isnull(cast(@tiCvrg as varchar), '?') + ', f=' + isnull(cast(@iFilter as varchar), '?') + ' )'
				exec	dbo.pr_Log_Ins	72, null, null, @s
			end
		commit
	end
end
go
grant	execute				on dbo.prCfgMst_Ins					to [rWriter]
go
--	----------------------------------------------------------------------------
--	Device button inputs (790 local configuration)
--	v.7.03
create table	dbo.tbCfgDvcBtn
(
	idDevice	smallint not null			-- 790 device look-up FK
		constraint	fkCfgDvcBtn_CfgDvc		foreign key references tbDevice
,	tiBtn		tinyint not null			-- button code (0-31)

,	siPri		smallint not null			-- priority			-- no FK enforcement
---		constraint	fkCfgDvcBtn_CfgPri		foreign key references tbCfgPri	-- tbDefCallP
,	tiBed		tinyint null				-- bed index		-- no FK enforcement
---		constraint	fkCfgDvcBtn_CfgBed		foreign key references tbCfgBed	-- tbDefBed

,	constraint	xpCfgDvcBtn		primary key clustered ( idDevice, tiBtn )
)
go
grant	select, insert, update, delete	on dbo.tbCfgDvcBtn		to [rWriter]
grant	select							on dbo.tbCfgDvcBtn		to [rReader]
go
--	----------------------------------------------------------------------------
--	Clears all device button inputs
--	v.7.03
create proc		dbo.prCfgDvcBtn_Clr
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
		delete	from	tbCfgDvcBtn
		select	@s= 'CfgDvcBtn_Clr( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	72, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgDvcBtn_Clr				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Inserts a device button input
--	v.7.03
create proc		dbo.prCfgDvcBtn_Ins
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
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	if	@tiBed = 0xFF		select	@tiBed= null	--	store ALL as 0 to force retrieval order

	if	not exists	(select 1 from tbCfgDvcBtn with (nolock) where idDevice = @idDevice and tiBtn = @tiBtn)
	begin
		begin	tran
			insert	tbCfgDvcBtn	(  idDevice,  tiBtn,  siPri,  tiBed )
					values		( @idDevice, @tiBtn, @siPri, @tiBed )

			if	@iTrace & 0x40 > 0
			begin
				select	@s= 'CfgDvcBtn_I( ' + isnull(cast(@idDevice as varchar), '?') + ', b=' + isnull(cast(@tiBtn as varchar), '?') +
							', p=' + isnull(cast(@siPri as varchar), '?') + ', b=' + isnull(cast(@tiBed as varchar), '?') + ' )'
				exec	dbo.pr_Log_Ins	72, null, null, @s
			end
		commit
	end
end
go
grant	execute				on dbo.prCfgDvcBtn_Ins				to [rWriter]
go
--	----------------------------------------------------------------------------
--	v.7.03	+ .bOnDuty
if	not exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbStaff') and name='bOnDuty')
begin
	begin tran
		alter table	dbo.tbStaff		add
			bOnDuty		bit not null				-- on-duty?
				constraint	tdStaff_OnDuty	default( 1 )
	commit
end
go
--	----------------------------------------------------------------------------
--	Staff definitions
--	v.7.03	+ .bOnDuty
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
	,	s.bOnDuty, s.bActive, s.dtCreated, s.dtUpdated
	from	tbStaff	s	with (nolock)
		inner join	tbStaffLvl	l	with (nolock)	on	l.idStaffLvl = s.idStaffLvl
go
--	----------------------------------------------------------------------------
--	Returns active staff, ordered to be loadable into a table
--	v.7.03
create proc		dbo.prStaff_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	s.idStaff, cast(1 as bit) [bInclude], s.lStaffID, s.sStaffLvl, s.sStaff, sl.iColorB
		from	vwStaff	s	with (nolock)
		inner join	tbStaffLvl sl	with (nolock)	on	sl.idStaffLvl = s.idStaffLvl
		where	s.bActive > 0
		order	by	s.idStaffLvl desc, s.sStaff
end
go
grant	execute				on dbo.prStaff_GetAll				to [rWriter]
grant	execute				on dbo.prStaff_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given device's staff
--	v.7.03
create proc		dbo.prStaffDvc_UpdStf
(
	@idBadge	int							-- badge id
,	@idStaff	int							-- who is this device currently assigned to?
)
	with encryption
as
begin
--	set	nocount	on
	begin	tran
		update	tbStaffDvc	set idStaff= @idStaff,	dtUpdated= getdate( )
			where	idStaffDvc = @idBadge
	commit
end
go
grant	execute				on dbo.prStaffDvc_UpdStf			to [rWriter]
grant	execute				on dbo.prStaffDvc_UpdStf			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all shifts, ordered to be loadable into a tree
--	v.7.03
create proc		dbo.prShift_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idUnit, tiIdx, idShift, sShift, tBeg, tEnd
		from	tbShift	with (nolock)
		where	bActive > 0
		order	by	idUnit, tiIdx
end
go
grant	execute				on dbo.prShift_GetAll				to [rWriter]
grant	execute				on dbo.prShift_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Finds a patient by name and inserts if necessary (not found)
--	v.7.03	- @sNote
--			* re-structure and optimize (log only changed fields - and if changed)
--	v.7.02	* fixed "Conversion failed when converting the varchar value '?' to data type int."
--			* @cGender null?
--			+ @sDoctor
--	v.6.05	+ (nolock)
--	v.6.04
alter proc		dbo.prPatient_GetIns
(
	@sPatient	varchar( 16 )		-- full name (HL7)
,	@cGender	char( 1 )
,	@sInfo		varchar( 32 )
--,	@sNote		varchar( 255 )
,	@sDoctor	varchar( 16 )		-- full name (HL7)

,	@idPatient	int out				-- output
)
	with encryption
as
begin
	declare		@s			varchar( 255 )
	declare		@idDoctor	int
	declare		@idDoc		int
	declare		@cGen		char( 1 )
	declare		@sInf		varchar( 32 )
--	declare		@sNot		varchar( 255 )

	set	nocount	on

	if	@cGender is null
		select	@cGender=	'U'

	if	len( @sPatient ) > 0
	begin
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

		select	@idPatient= idPatient,	@cGen= cGender, @sInf= sInfo, @idDoc= idDoctor	--, @sNot= sNote
			from	tbPatient	with (nolock)
			where	sPatient = @sPatient	and	bActive > 0

		begin	tran
			if	@idPatient is null
			begin
		--		if	@cGender is null							--	v.7.03	no point: already 'U' above
		--			select	@cGender=	substring( @sPatient, len(@sPatient), 1 )

				insert	tbPatient	(  sPatient,  cGender,  sInfo,  idDoctor )	--,  sNote
						values		( @sPatient, @cGender, @sInfo, @idDoctor )	--, @sNote
				select	@idPatient=	scope_identity( )

				select	@s=	'Pat_I( p=' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
		--					', n=' + isnull(@sNote,'?') +
							', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] )  id=' + cast(@idPatient as varchar)
				exec	pr_Log_Ins	44, null, null, @s
			end
			else
			begin
				select	@s=	''
				if	@cGen <> @cGender	select	@s=	@s + ', g=' + isnull(@cGender,'?')
				if	@sInf <> @sInfo		select	@s=	@s + ', i=' + isnull(@sInfo,'?')
		--		if	@sNot <> @sNote		select	@s=	@s + ', n=' + isnull(@sNote,'?')
				if	@idDoc <> @idDoctor	select	@s=	@s + ', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] ' + isnull(@sDoctor,'?')
				if	len(@s) > 0
				begin
					update	tbPatient	set	cGender= @cGender, sInfo= @sInfo, idDoctor= @idDoctor, dtUpdated= getdate( )	--, sNote= @sNote
						where	idPatient = @idPatient

					select	@s=	'Pat_U( [' + cast(@idPatient as varchar) + '] ' + isnull(@sPatient,'?') + @s + ' )'
					exec	pr_Log_Ins	44, null, null, @s
				end

		--		select	@s=	'Pat_U( [' + cast(@idPatient as varchar) + '] ' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
		--					', n=' + isnull(@sNote,'?') + ', d=[' + isnull(cast(@idDoctor as varchar),'?') + '] ' + isnull(@sDoctor,'?') + ' )'
		--		exec	pr_Log_Ins	44, null, null, @s
			end
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Active room details
--	v.7.03
create view		dbo.vwRoomAct
	with encryption
as
select	r.idUnit,	r.idRoom, d.cDevice, d.sDevice [sRoom], d.cSys, d.tiGID, d.tiJID, d.tiRID
	,	cSys + '-' + right('00' + cast(tiGID as varchar), 3) + '-' + right('0' + cast(tiJID as varchar), 2)		[sSGJ]
--	,	cSys + ':' + cast(tiGID as varchar) + ':' + cast(tiJID as varchar)		[sSGJ]
	,	r.idEvent	--, ea.dtEvent, ea.sCall, ea.iColorF, ea.iColorB, ea.siIdx, ea.tElapsed
	,	r.tiSvc
	,	r.idRn [idRegRn], r.sRn [sRegRn],	r.idCn [idRegCn], r.sCn [sRegCn],	r.idAi [idRegAi], r.sAi [sRegAi]
	,	d.bActive, d.dtCreated, r.dtUpdated
	from	tbRoom	r	with (nolock)
		inner join		tbDevice	d	with (nolock)	on	d.idDevice = r.idRoom		and	d.bActive > 0
go
grant	select, insert, update			on dbo.vwRoomAct		to [rWriter]
grant	select							on dbo.vwRoomAct		to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns active rooms, ordered to be loadable into a combobox
--	v.7.03
create proc		dbo.prRoom_GetAct
	with encryption
as
begin
--	set	nocount	on
	select	idRoom, sSGJ + '  [' + cDevice + '] ' + sRoom	[sQnRoom]
		from	vwRoomAct	with (nolock)
		order	by	2
end
go
grant	execute				on dbo.prRoom_GetAct				to [rWriter]
grant	execute				on dbo.prRoom_GetAct				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates room's staff
--	v.7.03	+ @idUnit
--	v.7.02	* tbRoomStaff -> tbRoom (prRoomStaff_Upd -> prRoom_Upd)
--			* fill in idStaff's as well
--	v.6.05
alter proc		dbo.prRoom_Upd
(
	@idRoom		smallint			-- 790 device look-up FK
,	@idUnit		smallint			-- active unit ID
,	@sRn		varchar( 16 )
,	@sCn		varchar( 16 )
,	@sAi		varchar( 16 )
)
	with encryption
as
begin
	declare		@idRn		int
	declare		@idCn		int
	declare		@idAi		int

	set	nocount	on

	if	not	exists	(select 1 from tbDefLoc where idLoc = @idUnit and tiLvl = 4)	select	@idUnit= null

	if	len( @sRn ) > 0		select	@idRn= idStaff	from	tbStaff with (nolock)	where	sStaff = @sRn
	if	len( @sCn ) > 0		select	@idCn= idStaff	from	tbStaff with (nolock)	where	sStaff = @sCn
	if	len( @sAi ) > 0		select	@idAi= idStaff	from	tbStaff with (nolock)	where	sStaff = @sAi

	begin	tran
		update	tbRoom	set	idUnit= @idUnit,	dtUpdated= getdate( )
						,	idRn= @idRn, sRn= @sRn,	idCn= @idCn, sCn= @sCn,	idAi= @idAi, sAi= @sAi
			where	idRoom = @idRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	v.7.03	+ .tiCvrg[0..7] to cache values from tbEvent84
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbEvent_A') and name = 'tiCvrg0')
begin
	begin tran
		alter table	dbo.tbEvent_A		add
				tiCvrg0		tinyint null				-- coverage area 0
			,	tiCvrg1		tinyint null				-- coverage area 1
			,	tiCvrg2		tinyint null				-- coverage area 2
			,	tiCvrg3		tinyint null				-- coverage area 3
			,	tiCvrg4		tinyint null				-- coverage area 4
			,	tiCvrg5		tinyint null				-- coverage area 5
			,	tiCvrg6		tinyint null				-- coverage area 6
			,	tiCvrg7		tinyint null				-- coverage area 7
	commit
end
go
--	----------------------------------------------------------------------------
--	Currently active call events
--		immediate dependants:	fnEventA_GetTopByUnit, fnEventA_GetTopByRoom
--	v.7.03	+ .sSGJRB, + .iFilter, + .tiCvrg[0..7]
--	v.7.02	- .tiTmr* (no need anymore, .tiSvc satisfies)
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*, .siIdxOld->.siPri, .siIdxNew->.siIdx
--			+ sd.tiStype, p.tiShelf, p.tiSpec
--			- .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide (no longer needed)
--			+ .tiSvc, .bAudio, .idUnit
--			+ (nolock)
--	v.6.04	+ .tiTmrStat, .tiTmrRn, .tiTmrCna, .tiTmrAide, .bAnswered
--			tbEvent.idRoom --> tbEvent_A.idRoom, .tiBed, .idCall
--			.idDevice,.sDevice,.sFnDevice -> .idRoom,.sRoom
--			+ .sDevice, .tiBed, .cBed
--	v.6.03
alter view		dbo.vwEvent_A
	with encryption
as
select	ea.idEvent, ea.dtEvent,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
	,	sd.idDevice, sd.sDevice, sd.sQnDevice, sd.tiStype, sd.sSGJR + '-' + right('0' + cast(ea.tiBtn as varchar), 2) [sSGJRB]
	,	ea.idRoom, r.sDevice [sRoom],	ea.tiBed, b.cBed,	rr.idUnit
	,	ea.idCall, c.siIdx, c.sCall, p.iColorF, p.iColorB, p.tiShelf, p.tiSpec, p.iFilter
	,	ea.bActive, ea.bAudio, cast( case when ea.siPri & 0x0400 = 0 then 1 else 0 end as bit ) [bAnswered]
	,	ea.tiSvc, getdate( ) - ea.dtEvent [tElapsed], ea.dtExpires
	,	ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7
	from	tbEvent_A		ea		with (nolock)
	left outer join	vwDevice	sd	with (nolock)	on	sd.cSys = ea.cSys	and	sd.tiGID = ea.tiGID	and	sd.tiJID = ea.tiJID	and	sd.tiRID = ea.tiRID	and	sd.bActive > 0
	left outer join	vwDevice	r	with (nolock)	on	r.idDevice = ea.idRoom
	left outer join	tbRoom		rr	with (nolock)	on	rr.idRoom = ea.idRoom
	left outer join	tbDefCall	c	with (nolock)	on	c.idCall = ea.idCall
	left outer join	tbDefCallP	p	with (nolock)	on	p.idIdx = c.siIdx
	left outer join	tbDefBed	b	with (nolock)	on	b.idIdx = ea.tiBed
go
--	----------------------------------------------------------------------------
--	Returns indication whether given master should visualize a call from given coverage areas
--	v.7.03
create function		dbo.fnEventA_GetByMaster
(
	@idMaster	smallint			-- master look-up FK
,	@cSys		char( 1 )			-- origin's system ID
,	@tiGID		tinyint				-- origin's G-ID - gateway
,	@tiJID		tinyint				-- origin's J-ID - J-bus
,	@iFilter	int					-- call's filter bits
,	@tiCvrg0	tinyint				-- coverage area 0
,	@tiCvrg1	tinyint				-- coverage area 1
,	@tiCvrg2	tinyint				-- coverage area 2
,	@tiCvrg3	tinyint				-- coverage area 3
,	@tiCvrg4	tinyint				-- coverage area 4
,	@tiCvrg5	tinyint				-- coverage area 5
,	@tiCvrg6	tinyint				-- coverage area 6
,	@tiCvrg7	tinyint				-- coverage area 7
)
	returns bit
	with encryption
as
begin
	declare		@tiCvrg		tinyint
		,		@iCaFlt		int
		,		@bResult	bit

	if	@idMaster = 0	or	@iFilter = 0	return	1		--	global mode or show all

	if	exists	(select 1 from tbDevice with (nolock) where cSys=@cSys and tiGID=@tiGID and tiJID=@tiJID and tiRID=0 and bActive >0 and idDevice=@idMaster)	--	and cDevice='M'
		return	0											--	suppress calls placed by the master itself (or its child phantom devices - workflow)

	select	@bResult=	0

	declare	cur		cursor local fast_forward for
		select	tiCvrg, iFilter
			from	dbo.tbCfgMst
			where	idMaster = @idMaster
		--	order	by	1, 2

	open	cur
	fetch next from	cur	into	@tiCvrg, @iCaFlt
	while	@@fetch_status = 0
	begin
		if	@tiCvrg = 0			--	ALL CAs
		or	@tiCvrg = @tiCvrg0	or	@tiCvrg = @tiCvrg1	or	@tiCvrg = @tiCvrg2	or	@tiCvrg = @tiCvrg3
		or	@tiCvrg = @tiCvrg4	or	@tiCvrg = @tiCvrg5	or	@tiCvrg = @tiCvrg6	or	@tiCvrg = @tiCvrg7
		begin
			if	@iCaFlt = 0	or	@iFilter & @iCaFlt > 0
			begin
				select	@bResult=	1
				break
			end
		end

		fetch next from	cur	into	@tiCvrg, @iCaFlt
	end
	close	cur
	deallocate	cur

	return	@bResult
end
go
grant	exec				on dbo.fnEventA_GetByMaster			to [rWriter]
grant	exec				on dbo.fnEventA_GetByMaster			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns topmost event for a given unit
--	v.7.03	+ @idMaster
--			- @tiShelf, + @iFilter, + .iFilter, + .tiCvrg[0..7]
--			* expanded * -> list of all vwEvent_A columns	http://stackoverflow.com/questions/15693359/
--			+ @tiShelf arg
--	v.7.00
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
	select	top	1	--*				--	v.7.03
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
--	v.7.03	+ @idMaster
--			+ @iFilter, + .iFilter, + .tiCvrg[0..7]
--			* expanded * -> list of all vwEvent_A columns	http://stackoverflow.com/questions/15693359/
--	v.7.00
alter function		dbo.fnEventA_GetTopByRoom
(
	@cSys		char( 1 )			-- system ID
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiBed		tinyint				-- bed-idx, 0xFF=room
,	@iFilter	int					-- filter mask
,	@idMaster	smallint			-- device look-up FK
)
	returns table
	with encryption
as
return
	select	top	1	--*				--	v.7.03
			idEvent, dtEvent,	cSys, tiGID, tiJID, tiRID, tiBtn
		,	idDevice, sDevice, sQnDevice, tiStype, sSGJRB
		,	idRoom, sRoom,	tiBed, cBed,	idUnit
		,	idCall, siIdx, sCall, iColorF, iColorB, tiShelf, tiSpec, iFilter
		,	bActive, bAudio, bAnswered, tiSvc, tElapsed, dtExpires
	---	,	tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7
		from	vwEvent_A	with (nolock)
		where	bActive > 0		and	tiShelf > 0
			and	cSys = @cSys	and	tiGID = @tiGID	and	tiJID = @tiJID	and	(tiBed is null	or	@tiBed is null	or	tiBed = @tiBed)
			and	( @iFilter = 0	or	iFilter & @iFilter <> 0 )
			and	dbo.fnEventA_GetByMaster( @idMaster, cSys, tiGID, tiJID, iFilter, tiCvrg0, tiCvrg1, tiCvrg2, tiCvrg3, tiCvrg4, tiCvrg5, tiCvrg6, tiCvrg7 ) > 0
		order	by	siIdx desc,		tElapsed					-- not desc: later event trumps
go
--	----------------------------------------------------------------------------
--	v.7.03	* tbRoomBed.idPatient -> tbPatient.idRoom + .tiBed (+ tbPatient.fkPatient_RoomBed)
--			[	+ xuRoomBed_Patient		]
if exists	(select 1 from dbo.sysindexes where name='xuRoomBed_Patient')
begin
	begin tran
		drop index	dbo.tbRoomBed.xuRoomBed_Patient
	commit
end
go
/*
if not exists	(select 1 from dbo.sysindexes where name='xuRoomBed_Patient')
begin
	begin tran
		create unique nonclustered index	xuRoomBed_Patient	on	dbo.tbRoomBed ( idPatient )	where	idPatient is not null		-- 7.03
	commit
end
*/
go
--	----------------------------------------------------------------------------
--	Patient definitions
--	v.7.03	tbRoomBed.idPatient -> tbPatient.idRoom + .tiBed (+ tbPatient.fkPatient_RoomBed)
if	not exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbPatient') and name='idRoom')
begin
	begin tran
		alter table	dbo.tbPatient	add
			idRoom		smallint null				-- device look-up FK
		,	tiBed		tinyint null				-- bed index FK
		,	constraint	fkPatient_RoomBed		foreign key	( idRoom, tiBed )	references tbRoomBed
	commit
end
go
begin tran
	update	p	set	p.idRoom= rb.idRoom, p.tiBed= rb.tiBed
		from	tbPatient	p
		inner join	tbRoomBed	rb	on	rb.idPatient = p.idPatient
commit
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed
--	v.7.03
create proc		dbo.prPatient_UpdLoc
(
	@idPatient	int
,	@cSys		char( 1 )			-- system
,	@tiGID		tinyint				-- G-ID - gateway
,	@tiJID		tinyint				-- J-ID - J-bus
,	@tiRID		tinyint				-- R-ID - R-bus
,	@tiBed		tinyint				-- bed index, 0xFF == no bed in room
)
	with encryption
as
begin
	declare		@s		varchar( 255 )
	,			@idRoom		smallint
	,			@idCurr		smallint
	,			@tiCurr		tinyint

	set	nocount	on

--	select	@s=	'Pat_U( id=' + isnull(cast(@idPatient as varchar),'?') +
--				', p=' + isnull(@sPatient,'?') + ', g=' + isnull(@cGender,'?') + ', i=' + isnull(@sInfo,'?') +
--				', n=' + isnull(@sNote,'?') + ', a=' + cast(@bActive as varchar) + ' )'

	select	@idRoom= idRoom
		from	vwRoomAct	with (nolock)
		where	cSys = @cSys	and	tiGID = @tiGID	and	tiRID = @tiRID	and	tiJID = @tiJID
	select	@idCurr= idRoom, @tiCurr= tiBed
		from	tbPatient	with (nolock)
		where	idPatient = @idPatient

	if	@idRoom <> @idCurr	or	@tiBed <> @tiCurr
	begin
		begin	tran
			update	tbPatient	set	dtUpdated= getdate( ),	idRoom= @idRoom, tiBed= @tiBed
				where	idPatient = @idPatient
		commit
	end
end
go
grant	execute				on dbo.prPatient_UpdLoc				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, should be called on a schedule every hour
--	v.7.03	+ reporting DB sizes in tb_Module[1]
--	v.6.05	+ (nolock)
--	v.6.04
alter proc		dbo.prEvent_Maint
	with encryption
as
begin
	declare		@iSizeDat	int
	declare		@iSizeLog	int
	declare		@tiPurge	tinyint

	set	nocount	on

	select	@iSizeDat= size/128
		from	sys.database_files	with (nolock)
		where	file_id = 1		--	type = 0
	select	@iSizeLog= size/128
		from	sys.database_files	with (nolock)
		where	file_id = 2		--	type = 1

	update	tb_Module	set	sParams=	'@ ' + @@servicename + ', dat:' + cast(@iSizeDat as varchar) + ', log:' + cast(@iSizeLog as varchar)
		where	idModule=	1

	select	@tiPurge= cast(iValue as tinyint)	from	tb_OptionSys	with (nolock)	where	idOption = 7

	if	@tiPurge > 0
		exec	prEvent_A_Exp	@tiPurge
end
go
--	----------------------------------------------------------------------------
--	Inserts common event header
--	v.7.03	* 7967-P detection and handling
--	v.7.02	enforce tbEvent.idRoom to only contain valid room references
--			* setting tbRoom.idUnit (moved from tbDevice)
--	v.6.05	* tbEvent_A, tbEvent_P: rename .?Src* -> .?*
--			+ extended expiration for picked calls
--			+ (nolock)
--	v.6.04	* tbEvent.idRoom assignment for @tiStype = 26
--			+ populating tbDevice.idUnit
--			+ populating tbEvent_S, tbEvent.idRoom
--	v.6.03	+ check for tiShelf,tiSpec before inserting to [tbEvent_T] - fixes 'presense' in RptCallActSum
--			+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--			tbEvent_C, tbEvent_T, vwEvent_C, vwEvent_T:	.idDevice -> .idRoom
--			added 0x97 to "flipped" (src-dst) commands
--	v.6.02	* logic change to allow idCmd=0 without touching tbEvent_P
--			* prDevice_GetIns: + @cSys (+ tbDevice.cSys), order of @rgs (prEvent_Ins)
--	v.6.00	tbEvent? -> tbEvent_? (A, C, P, T)
--	v.5.02	.idLoc -> tbEvent.idUnit from tbEvent84,95 (prEvent_Ins 84,95,B7; vwEvent 84,95,B7; tbEventC, vwEventC, tbEventT, vwEventT)
--			+ @idUnit
--	v.5.01	encryption added
--			+ tbEvent.idParent, + .tParent, now records parent ref
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			@tiBed set to 'null' when > 9
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	v.2.03	+ prDefDevice_GetIns (prEvent*_Ins, 84, 8A, A7)
--			+ tbDefDevice.idParent (prDefDevice_InsUpd, prDefDevice_GetIns, prEvent_Ins)
--	v.2.01	.idRoom -> .idDevice (FK changed also)
--	v.1.09	+ @idType= null
--	v.1.08
--	v.1.00
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

,	@idEvent	int out				-- output: inserted idEvent
,	@idSrcDvc	smallint out		-- output: found/inserted source device
,	@idDstDvc	smallint out		-- output: found/inserted destination device

,	@idLogType	tinyint = null		-- type look-up FK (marks significant events only)
,	@idCall		smallint = null		-- call look-up FK (only 41,84,8A and 95 commands)
,	@tiBtn		tinyint = null		-- src|dst button code (0-31)
,	@tiBed		tinyint = null		-- bed index
,	@idUnit		smallint = null		-- active unit ID
,	@iAID		int = null			-- device A-ID (32 bits)
,	@tiStype	tinyint = null		-- device type (1-255)
)
	with encryption
as
begin
	declare		@dtEvent	datetime
	declare		@tiHH		tinyint
	declare		@idRoom		smallint
	declare		@cDevice	char( 1 )
	declare		@idParent	int
	declare		@dtParent	datetime
	declare		@tiShelf	tinyint
	declare		@tiSpec		tinyint
	declare		@iExpNrm	int
--	declare		@s			varchar( 255 )

	set	nocount	on

	select	@dtEvent=	getdate( )
		,	@tiHH=		datepart( hh, getdate( ) )
		,	@cDevice=	case when @idCmd = 0x83 then 'G' else '?' end		--	null

	select	@iExpNrm= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 9

	if	@tiBed > 9	--	= 255	or	@tiBed = 0
		select	@tiBed= null

--	-if	@idUnit is not null			--	no need to validate (FK not enforced) - just log the value!
--	-	if	0 <= @idUnit	and	@idUnit < 0x01FF
--	-		if	not exists	(select 1 from tbDefLoc where idLoc = @idUnit)	-- and cLoc = 'U'
--	-			select	@idUnit=	null

--	select	@s=	'Evt_I( cmd=' + isnull(cast(@idCmd as varchar),'?') + ', unit=' + isnull(cast(@idUnit as varchar),'?') + ' typ=' + isnull(cast(@tiStype as varchar),'?') +
--				', src=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sSrcDvc,'?') +
--				'], dst=' + isnull(cast(@tiSrcGID as varchar),'?') + '-' + isnull(cast(@tiSrcJID as varchar),'?') + '-' + isnull(cast(@tiSrcRID as varchar),'?') + '[' + isnull(@sDstDvc,'?') +
--				'], btn=' + isnull(cast(@tiBtn as varchar),'?') + ', bed=' + isnull(cast(@tiBed as varchar),'?') + ' )'		--	 + ' i=' + isnull(@sInfo,'?')
--	exec	pr_Log_Ins	0, null, null, @s

	begin	tran

		exec	dbo.prDevice_GetIns		@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @iAID, @tiStype, @cDevice, @sSrcDvc, null, @idSrcDvc out

		if	@tiDstGID > 0
			exec	dbo.prDevice_GetIns		@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, null, null, @sDstDvc, null, @idDstDvc out

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

		exec	dbo.prEvent_A_Exp

		if	@idCmd > 0		--	v.6.02
		begin
			if	@idCmd in (0x88, 0x89, 0x8A, 0x8D, 0x95, 0x97)	--	audio, set-svc, pat-dtl-req events link to parent via destination
			begin
				select	@idParent= idEvent, @dtParent= dtEvent
					from	tbEvent_P	with (nolock)
					where	cSys = @cSrcSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	--and	tiRID = @tiDstRID	and	tiBtn = @tiDstBtn
				--		and	dtExpires > getdate( )

				if	@tiSrcJID = 0	--and	@tiSrcRID = 0			--	Gateway		v.7.02
					select	@idRoom=	null
				else
				if	@tiStype = 0	and	@iAID = 0					--	7967-P?		v.7.03
					select	@idRoom=	idDevice
						from	tbDevice	with (nolock)
						where	cSys = @cSrcSys		and	tiGID = @tiDstGID	and	tiJID = @tiDstJID	and	tiRID = 0	and	bActive > 0
				else
				if	@tiSrcRID = 0	---or	@tiStype = 26			--	Room-Ctrlr	[or	7967-P - Patient Workflow]	v.6.04
					select	@idRoom=	idDevice
						from	tbDevice	with (nolock)
						where	idDevice = @idDstDvc	and	cDevice = 'R'		--	v.7.02
				else
					select	@idRoom=	p.idDevice
						from	tbDevice d		with (nolock)
						inner join	tbDevice p	with (nolock)	on	p.idDevice = d.idParent	and	p.cDevice = 'R'
						where	d.idDevice = @idDstDvc							--	v.7.02
			end
			else
			begin
				select	@idParent= idEvent, @dtParent= dtEvent
					from	tbEvent_P	with (nolock)
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn

				if	@tiSrcJID = 0	--and	@tiSrcRID = 0			--	Gateway		v.7.02
					select	@idRoom=	null
				else
				if	@tiStype = 0	and	@iAID = 0					--	7967-P?		v.7.03
					select	@idRoom=	idDevice
						from	tbDevice	with (nolock)
						where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = 0	and	bActive > 0
				else
				if	@tiSrcRID = 0	---or	@tiStype = 26			--	Room-Ctrlr	[or	7967-P - Patient Workflow]	v.6.04
					select	@idRoom=	idDevice
						from	tbDevice	with (nolock)
						where	idDevice = @idSrcDvc	and	cDevice = 'R'		--	v.7.02
				else
					select	@idRoom=	p.idDevice
						from	tbDevice d		with (nolock)
						inner join	tbDevice p	with (nolock)	on	p.idDevice = d.idParent	and	p.cDevice = 'R'
						where	d.idDevice = @idSrcDvc							--	v.7.02
			end

--			select	@s=	'Evt_i2: prnt=' + isnull(cast(@idParent as varchar),'?') + ' room=' + isnull(cast(@idRoom as varchar),'?')
--			exec	pr_Log_Ins	0, null, null, @s

			if	@idParent is null	--	no parent found
			begin
				update	tbEvent		set	idParent= @idEvent,		idRoom= @idRoom,	tParent= '0:0:0',	@dtParent= dtEvent
					where	idEvent = @idEvent
				insert	tbEvent_P	( idEvent, dtEvent, cSys, tiGID, tiJID, dtExpires )	--, tiRID, tiBtn
						values		( @idEvent, @dtParent, @cSrcSys, @tiSrcGID, @tiSrcJID,
									dateadd(ss, @iExpNrm, @dtParent) )	--, @tiSrcRID, @tiSrcBtn

				if	@idCall > 0		--	v.6.03
				begin
					select	@tiShelf= p.tiShelf, @tiSpec= p.tiSpec
						from	tbDefCallP	p	with (nolock)
						inner join	tbDefCall	c	with (nolock)	on	c.siIdx = p.idIdx	and	c.idCall = @idCall

					if	( @tiShelf > 0	and		( @tiSpec is null  or  @tiSpec < 6  or  @tiSpec = 18 ) )	--	only save 'medical' calls
		--	-		--	!!	'presence' works for prEvent84_Ins;  but it should be excluded from tbEvent_T	!!
		--	-			or	@tiSpec between 7 and 9															--	or 'presence'
						begin
							insert	tbEvent_T	( idEvent, dEvent, tEvent, tiHH, idRoom, idCall )
									values		( @idEvent, @dtParent, @dtParent, datepart( hh, @dtParent ), @idRoom, @idCall )		--	v.6.04:	@idRoom
						end
				end
			end
			else	--	parent found
			begin
				update	tbEvent		set	idParent= @idParent,	idRoom= @idRoom,	tParent= dtEvent - @dtParent
					where	idEvent = @idEvent

				select	@dtParent=	dateadd(ss, @iExpNrm, getdate( ))	--	v.6.05
				update	tbEvent_P	set	dtExpires= @dtParent
					where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
						and	dtExpires < @dtParent						--	v.6.05
			end
		end

		select	@idParent= null			--	v.6.04
		select	@idParent= idEvent
			from	tbEvent_S	with (nolock)
			where	dEvent = cast(@dtEvent as date)
				and	tiHH = @tiHH
		if	@idParent	is null
			insert	tbEvent_S	(   dEvent,  tiHH,  idEvent )
					values		( @dtEvent, @tiHH, @idEvent )

		if	@idUnit > 0								--	v.7.02
			update	tbRoom		set	idUnit=	@idUnit
				where	idRoom = @idRoom
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
--	v.7.03	* prRoom_Upd: + @idUnit
--			+ tbEvent_A.tiCvrg[0..7] to cache values from tbEvent84
--			* fixed call [dbo.prPatient_GetIns] args (+ @sInfo)
--	v.7.02	* @tiTmrStat -> @tiTmrSt, @tiTmrCna -> @tiTmrCn, @tiTmrAide -> @tiTmrAi
--			* @sCna -> @sCn, @sAide -> @sAi
--			+ recording @sRn, @sCn, @sAi into tbRoom (via prRoom_Upd)
--			+ ignore @tiBed if [0x84] is 'presence'
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
,	@tiTmrSt	tinyint				-- stat-need timer
,	@tiTmrRn	tinyint				-- RN-need timer
,	@tiTmrCn	tinyint				-- CNA-need timer
,	@tiTmrAi	tinyint				-- Aide-need timer
,	@sDevice	varchar( 16 )		-- room name
,	@tiBed		tinyint				-- bed index
--,	@cBed		char( 1 )			-- bed name
,	@sCall		varchar( 16 )		-- call text
,	@sPatient	varchar( 16 )		-- patient name
,	@sDoctor	varchar( 16 )		-- doctor name
,	@sInfo		varchar( 32 )		-- info text
,	@sDial		varchar( 16 )		-- room dial number
--,	@tiBed		tinyint				-- bed dial number
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
	declare		@tiSvc		tinyint
	declare		@tiRmBed	tinyint
	declare		@cBed		char( 1 )
	declare		@tiPurge	tinyint
	declare		@bAudio		bit
	declare		@iExpNrm	int
	declare		@iExpExt	int
--	declare		@s			varchar( 255 )

	set	nocount	on

	select	@siIdxOld=	@siPriOld & 0x03FF,		@siIdxNew=	@siPriNew & 0x03FF

	select	@tiPurge= cast(iValue as tinyint)	from	tb_OptionSys	with (nolock)	where	idOption = 7

	select	@iExpNrm= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 9
	select	@iExpExt= iValue	from	tb_OptionSys	with (nolock)	where	idOption = 10

	if	@siIdxNew > 0			-- call placed
	begin
		exec	dbo.prDefCall_GetIns	@siIdxNew, @sCall, @idCall out
		select	@tiSpec= tiSpec		from	tbDefCallP	with (nolock)	where	idIdx = @siIdxNew
	end
	else if	@siIdxOld > 0		-- call cancelled
	begin
		exec	dbo.prDefCall_GetIns	@siIdxOld, @sCall, @idCall out
		select	@tiSpec= tiSpec		from	tbDefCallP	with (nolock)	where	idIdx = @siIdxOld
	end
	else
		select	@idCall= 0		--	INTERCOM call
	---	exec	dbo.prDefCall_GetIns	0, @sCall, @idCall out		--	no need to call

	if	@tiSpec between 7 and 9
		select	@tiBed=	0xFF	--	drop bed-index for 'presence' calls

	if	@tiBed > 9	--	= 0xFF	or	@tiBed = 0
		select	@cBed= null,	@tiBed= null
	else
		select	@cBed= cBed		from	tbDefBed	with (nolock)	where	idIdx = @tiBed

--	exec	dbo.prPatient_GetIns	@sPatient, null, @sInfo, null, @sDoctor, @idPatient out
	exec	dbo.prPatient_GetIns	@sPatient, null, @sInfo, @sDoctor, @idPatient out

	begin	tran

		if	@tiBed is not null		-- >= 0
			update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed	and	bInUse = 0

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out, null, @idCall, @tiSrcBtn, @tiBed, @idUnit, @iAID, @tiStype

		if	@idSrcDvc is not null	and	len( @sDial ) > 0
			update	tbDevice	set	sDial= @sDial, dtUpdated= getdate( )
				where	idDevice = @idSrcDvc	and	( sDial <> @sDial	or sDial is null )	--!

		insert	tbEvent84	(  idEvent,  siPriOld,  siPriNew,  siElapsed,  tiPrivacy,  siIdxOld,  siIdxNew,
							tiTmrSt,  tiTmrRn,  tiTmrCn,  tiTmrAi,  idPatient,  idDoctor,  iFilter,
							tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7,
							siDuty0,  siDuty1,  siDuty2,  siDuty3,  siZone0,  siZone1,  siZone2,  siZone3 )
				values		( @idEvent, @siPriOld, @siPriNew, @siElapsed, @tiPrivacy, @siIdxOld, @siIdxNew,
							@tiTmrSt, @tiTmrRn, @tiTmrCn, @tiTmrAi, @idPatient, @idDoctor, @iFilter,
							@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7,
							@siDuty0, @siDuty1, @siDuty2, @siDuty3, @siZone0, @siZone1, @siZone2, @siZone3)

		select	@idOrigin= idEvent, @dtOrigin= dtEvent, @bAudio= bAudio
			from	tbEvent_A	with (nolock)
			where	cSys = @cSrcSys
				and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
				and	bActive > 0				--	6.04

	---	if	@siIdxOld = 0	or	@idOrigin is null	--	new call placed | no active origin found
		if	@idOrigin is null	--	no active origin found
			--	'real' new call should not have origin anyway, 'repeated' one would be linked to starting - even better
		begin
			update	tbEvent		set	idOrigin= @idEvent, idLogType= 191	-- call placed
								,	tOrigin= dateadd(ss, @siElapsed, '0:0:0')										--	v.6.05
								,	@dtOrigin= dateadd(ss, - @siElapsed, dtEvent), @idSrcDvc= idSrcDvc, @idParent= idParent		--	v.6.04
				where	idEvent = @idEvent
			insert	tbEvent_A	(  idEvent,   dtEvent,  cSys,     tiGID,     tiJID,     tiRID,     tiBtn,     siPri,     siIdx,     tiBed, dtExpires,
								tiCvrg0,  tiCvrg1,  tiCvrg2,  tiCvrg3,  tiCvrg4,  tiCvrg5,  tiCvrg6,  tiCvrg7 )
					values		( @idEvent, @dtOrigin, @cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @tiSrcBtn, @siPriNew, @siIdxNew, @tiBed,		--	v.6.04
								dateadd(ss, @iExpNrm, getdate( )),
								@tiCvrg0, @tiCvrg1, @tiCvrg2, @tiCvrg3, @tiCvrg4, @tiCvrg5, @tiCvrg6, @tiCvrg7 )	--@dtOrigin
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
			else if	@tiSpec = 8
				update	c	set	idCn= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID
			else if	@tiSpec = 9
				update	c	set	idAi= @idEvent
					from	tbEvent_C	c
						inner join	tbEvent_A	a	on	a.idEvent = c.idEvent
					where	a.tiGID = @tiSrcGID		and	a.tiJID = @tiSrcJID

			select	@idOrigin= @idEvent		--	6.04
		end
		else	--	active origin found		(=> this must be a healing or cancellation event)
		begin
			update	tbEvent		set	idOrigin= @idOrigin, tOrigin= dtEvent - @dtOrigin
			--		,@idSrcDvc= idSrcDvc
				where	idEvent = @idEvent
			update	tbEvent_A	set	dtExpires= dateadd(ss, @iExpNrm, getdate( ))
								,	siPri= @siPriNew
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
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	bActive > 0				--	6.04

			update	tbEvent_P	set	dtExpires= @dtOrigin												--	6.05
				where	cSys = @cSrcSys		and	tiGID = @tiSrcGID	and	tiJID = @tiSrcJID	--	and	tiRID = @tiSrcRID	and	tiBtn = @tiSrcBtn
					and	dtExpires < @dtOrigin

	--		select	@s=	@cSrcSys + '-' + cast(@tiSrcGID as varchar) + '-' + cast(@tiSrcJID as varchar) +
	--					' -> ' + convert(varchar, @dtOrigin, 121) + ' rows:' + cast(@@rowcount as varchar)
	--		exec	pr_Log_Ins	0, null, null, @s

			select	@dtOrigin= tOrigin, @idParent= idParent
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
				update	tbEvent_C	set	tCn= @dtOrigin
					where	idCn = @idOrigin
				update	tbEvent_T	set	tCn= isnull(tCn, '0:0:0') + @dtOrigin
					where	idEvent = @idParent
			end
			else if	@tiSpec = 9
			begin
				update	tbEvent_C	set	tAi= @dtOrigin
					where	idAi = @idOrigin
				update	tbEvent_T	set	tAi= isnull(tAi, '0:0:0') + @dtOrigin
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

		exec	dbo.prRoom_Upd		@idRoom, @idUnit, @sRn, @sCn, @sAi

		if	@tiPurge > 0
			delete	from	tbEvent							-- remove healing event at once (cascade rule must take care of other tables)
				where	idEvent = @idEvent
					and	idLogType is null

		if	@tiTmrSt > 3		select	@tiTmrSt=	3
		if	@tiTmrRn > 3		select	@tiTmrRn=	3
		if	@tiTmrCn > 3		select	@tiTmrCn=	3
		if	@tiTmrAi > 3		select	@tiTmrAi=	3

		update	tbEvent_A	set	idRoom= @idRoom				--	cache necessary details in the active call (tiBed is null for room-level calls)
							,	idCall= @idCall, tiSvc= @tiTmrSt*64 + @tiTmrRn*16 + @tiTmrCn*4 + @tiTmrAi	---, tiBed= @tiBed	--	v.6.05
			where	idEvent = @idOrigin

		if	@tiBed is not null								--	if argument is a bed-level call
			update	tbRoomBed	set	idPatient= @idPatient, dtUpdated= getdate( )		--, idDoctor= @idDoctor	--	v.7.02
				,	tiIbed= case when	@tiStype = 192	then		--	only for 7947 (iBed)
									case when	@siIdxNew = 0	then	--	call cancelled
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
										else							--	call placed / being-healed
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
										end
								else	tiIbed	end					--	don't change
				where	idRoom = @idRoom
					and	tiBed = @tiBed

	---	!! @idEvent no longer points to current event !!

		select	@idEvent= null, @tiSvc= null
		--	select highest oldest active call for this room (room- or bed-level)
		select	top 1	@idEvent= idEvent, @tiSvc= tiSvc
			from	tbEvent_A	with (nolock)
			where	idRoom = @idRoom	and	(tiBed is null	or tiBed = @tiBed)	and	bActive > 0
			order	by	siIdx desc, idEvent desc
	--		order	by	siIdx desc, tElapsed desc		--	call may have been started before it was recorded (idEvent)

		update	tbRoom	set	idEvent= @idEvent,	tiSvc= @tiSvc
			where	idRoom = @idRoom

		declare		cur		cursor fast_forward for
			select	tiBed
				from	tbRoomBed
				where	idRoom = @idRoom

		open	cur
		fetch next from	cur	into	@tiRmBed
		while	@@fetch_status = 0
		begin
			select	@idEvent= null, @tiSvc= null
			--	select highest oldest active call for this room (room- or bed-level)
			select	top 1	@idEvent= idEvent, @tiSvc= tiSvc
				from	tbEvent_A	ea	with (nolock)
				where	idRoom = @idRoom
					and	bActive > 0
					and	(tiBed is null	or tiBed = @tiRmBed)
				order	by	siIdx desc, idEvent desc
	--			order	by	siIdx desc, tElapsed desc		--	call may have been started before it was recorded (idEvent)

	--		if	@idEvent is not null
			update	tbRoomBed	set	idEvent= @idEvent, dtUpdated= getdate( )
				,	tiSvc= case when @siIdxNew = 0 then null else @tiSvc end
				where	idRoom = @idRoom
					and	tiBed = @tiRmBed

			fetch next from	cur	into	@tiRmBed
		end
		close	cur
		deallocate	cur

	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x98, 0x9A, 0x9E, 0x9C, 0xA4, 0xAD, 0xAF]
--	v.7.03	* fixed call [dbo.prPatient_GetIns] args, re-structured call [dbo.prDoctor_GetIns] call
--	v.6.05	optimize
--	v.6.04	now uses prPatient_GetIns, prDoctor_GetIns
--			tbDefPatient -> tbPatient (tbEvent84, prEvent84_Ins, vwEvent84, tbEvent98, prEvent98_Ins, vwEvent98, tbRoomBed, vwRoomBed, prRptCallActDtl)
--	v.5.01	encryption added
--			.tiBed -> tbEvent from tbEvent84,8A,95,41 (prEvent_Ins, 41, 84, 8A, 95)
--			.tiBtn -> tbEvent from tbEvent84,8A,95,99,41 (prEvent_Ins, 41, 84, 8A, 95, 99)
--			[+ @sDial for AF, no: see @sInfo]
--	v.4.01	fix (prEvent_Ins args): prEvent86_Ins, 8C, 98, 99, 9B, A1,A2,A3, A7, A9, AB
--	v.3.01	move .DstSGJR, .idDstDvc to tbEvent (prEvent*_Ins)
--	v.1.00
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
,	@sDoctor	varchar( 16 )		-- doctor name
,	@sInfo		varchar( 32 )		-- info text, 0xAF: dialable room number
,	@sDevice	varchar( 16 )		-- 0x9E: destination room name
)
	with encryption
as
begin
	declare		@idEvent	int
	declare		@idDoctor	int
	declare		@idPatient	int
	declare		@idSrcDvc	smallint
	declare		@idDstDvc	smallint

	set	nocount	on

	if	len( @sPatient ) > 0
--		exec	dbo.prPatient_GetIns	@sPatient, null, @sInfo, null, @sDoctor, @idPatient out
		exec	dbo.prPatient_GetIns	@sPatient, null, @sInfo, @sDoctor, @idPatient out
	else	if	len( @sDoctor ) > 0
		exec	dbo.prDoctor_GetIns		@sDoctor, @idDoctor out

	begin	tran

		exec	dbo.prEvent_Ins		@idCmd, @tiLen, @iHash, @vbCmd,
					@cSrcSys, @tiSrcGID, @tiSrcJID, @tiSrcRID, @sDevice,
					@cDstSys, @tiDstGID, @tiDstJID, @tiDstRID, null, @sInfo,
					@idEvent out, @idSrcDvc out, @idDstDvc out

		insert	tbEvent98	( idEvent,  tiMulti,  idPatient,  idDoctor )	--, tiFlags
				values		( @idEvent, @tiMulti, @idPatient, @idDoctor )	--, @tiFlags
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates a given module's state
--	v.7.03	* .dtLastAct update
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

		update	dbo.tb_Module	set	dtStart= @dtStart, sParams= @sParams, dtLastAct= getdate( )
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
--	v.7.03	- fkStaffAssn_StaffCover: no longer supported - causes trouble for deletes!
if	exists	(select 1 from dbo.sysobjects where uid=1 and name='fkStaffAssn_StaffCover')
begin
	begin tran
		alter table	dbo.tbStaffAssn	drop
			constraint	fkStaffAssn_StaffCover
	commit
end
go
--	----------------------------------------------------------------------------
--	tbStaffAssn
--	v.7.03	- fkStaffAssn_Room, + fkStaffAssn_RoomBed
if	exists	(select 1 from sys.all_objects where parent_object_id = OBJECT_ID('dbo.tbStaffAssn') and name = 'fkStaffAssn_Room')
begin
	begin tran
		alter table	dbo.tbStaffAssn		drop constraint fkStaffAssn_Room

		delete	sc										--	remove any leftovers so FK can be established
			from	dbo.tbStaffCover	sc
			inner join	dbo.tbStaffAssn		sa	on	sa.idStaffAssn = sc.idStaffAssn
			left outer join	dbo.tbRoomBed	rb	on	rb.idRoom = sa.idRoom	and	rb.tiBed = sa.tiBed
			where	rb.idRoom is null

		delete	sa										--	remove any leftovers so FK can be established
			from	dbo.tbStaffAssn	sa
			left outer join	dbo.tbRoomBed	rb	on	rb.idRoom = sa.idRoom	and	rb.tiBed = sa.tiBed
			where	rb.idRoom is null

		update	sa	set	sa.idStaffCover= null			--	reset any leftovers
			from	dbo.tbStaffAssn	sa
			left outer join	dbo.tbStaffCover	sc	on	sa.idStaffAssn = sc.idStaffAssn
			where	sc.idStaffCover is null

		alter table	dbo.tbStaffAssn		add
			constraint	fkStaffAssn_RoomBed		foreign key	( idRoom, tiBed )	references tbRoomBed
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts, updates or "deletes" staff assignment definitions
--	7.03.4884	+ trace output
--	v.7.00	* tbDevice.bActive > 0
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.02
--	v.6.01
alter proc		dbo.prStaffAssn_InsUpdDel
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
	declare		@iTrace		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	if	@iTrace & 0x80 > 0
	begin
		select	@s=	cast(@iStamp as varchar) + ' SAD_IUD( idU=' + isnull(cast(@idUnit as varchar),'?') +
				', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
				', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
				', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
				', idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
				', idSt=' + isnull(cast(@idStaff as varchar),'?') + ' )'
		exec	dbo.pr_Log_Ins	46, null, null, @s
	end

	if	@idRoom is null
	--	select	@idRoom= idDevice		from	tbDevice	with (nolock)
		select	@idRoom= r.idRoom		from	tbRoom	r	with (nolock)
			inner join	tbDevice	d	with (nolock)	on	d.idDevice = r.idRoom
				where	d.bActive > 0	and	d.sDevice = @sRoom	--	and	sDial = @sDial
--	print	@idRoom

	if	@idShift is null
		select	@idShift= idShift		from	tbShift		with (nolock)
				where	bActive > 0	and	idUnit = @idUnit	and	tiIdx = @tiShIdx
--	print	@idShift

	if	@idStaff is null	--	and	len(@sStaffID) > 0
		select	@idStaff= idStaff		from	tbStaff		with (nolock)
				where	bActive > 0	and	lStaffID = @lStaffID
--	print	@idStaff

	if	@idStaffAssn is null	and	@bActive > 0	and	(@idRoom is null	or	@idShift is null)	--	log an error in input
	begin
		select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_1( idU=' + isnull(cast(@idUnit as varchar),'?') +
				', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
				', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
				', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
				', idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
				', idSt=' + isnull(cast(@idStaff as varchar),'?') + ' )'
		exec	pr_Log_Ins	47, null, null, @s
		return	-1
	end

	if	@idStaffAssn is null
		select	@idStaffAssn= idStaffAssn		from	tbStaffAssn
				where	bActive > 0	and	idRoom = @idRoom	and	tiBed = @tiBed	and	idShift = @idShift	and	tiIdx = @tiIdx
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
					if	@iTrace & 0x80 > 0
					begin
						select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_0( idU=' + isnull(cast(@idUnit as varchar),'?') +
								', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
								', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
								', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
								' ) idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
								', idSt=' + isnull(cast(@idStaff as varchar),'?') + '.'
						exec	dbo.pr_Log_Ins	46, null, null, @s
					end

					insert	tbStaffAssn	(  bActive,  idRoom,  tiBed,  idShift,  tiIdx,  idStaff,  TempID,  iStamp )
							values			( @bActive, @idRoom, @tiBed, @idShift, @tiIdx, @idStaff, @TempID, @iStamp )
					select	@idStaffAssn=	scope_identity( )
				end
				else	--	log an error in input
				begin
					select	@s=	cast(@iStamp as varchar) + ' SAD_IUD_2( idU=' + isnull(cast(@idUnit as varchar),'?') +
							', sR=' + isnull(@sRoom,'?') + ', tiB=' + isnull(cast(@tiBed as varchar),'?') +
							', ixSh=' + isnull(cast(@tiShIdx as varchar),'?') + ', ixSt=' + isnull(cast(@tiIdx as varchar),'?') +
							', lID=' + isnull(cast(@lStaffID as varchar),'?') + ', bAct=' + isnull(cast(@bActive as varchar),'?') +
							' ) idR=' + isnull(cast(@idRoom as varchar),'?') + ', idSh=' + isnull(cast(@idShift as varchar),'?') +
							', idSt=' + isnull(cast(@idStaff as varchar),'?') + '.'
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
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
--	v.7.03
create proc		dbo.prUnitMap_GetAll
(
	@idUnit		smallint					-- unit id
)
	with encryption
as
begin
--	set	nocount	on
	select	tiMap, sMap
		from	tbUnitMap	with (nolock)
		where	idUnit = @idUnit
end
go
grant	execute				on dbo.prUnitMap_GetAll				to [rWriter]
grant	execute				on dbo.prUnitMap_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given unit's map name
--	v.7.03
create proc		dbo.prUnitMap_Upd
(
	@idUnit		smallint					-- unit id
,	@tiMap		tinyint						-- map index [0..3]
,	@sMap		varchar( 16 )				-- map name
)
	with encryption
as
begin
--	set	nocount	on
	begin	tran
		update	tbUnitMap	set	sMap= @sMap
			where	idUnit = @idUnit	and tiMap = @tiMap
	commit
end
go
grant	execute				on dbo.prUnitMap_Upd				to [rWriter]
grant	execute				on dbo.prUnitMap_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	v.7.03	+ .idRoom, -.bSwing
if	not exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbUnitMapCell') and name='idRoom')
begin
	begin tran
		alter table	dbo.tbUnitMapCell	drop constraint	tdUnitMapCell_bSwing
		alter table	dbo.tbUnitMapCell	drop column		bSwing
		alter table	dbo.tbUnitMapCell	add
			idRoom		smallint null				-- device look-up FK
				constraint	fkUnitMapCell_Room	foreign key references tbRoom
	commit
end
go
begin tran
	update	c	set	c.idRoom= r.idRoom
		from	tbUnitMapCell c	with (nolock)
		inner join	tbDevice d	with (nolock)	on	d.cSys = c.cSys	and	d.tiGID = c.tiGID	and	d.tiJID = c.tiJID	and	d.tiRID = 0	and	d.bActive > 0
		inner join	tbRoom	r	with (nolock)	on	r.idRoom = d.idDevice
commit
go
--	v.7.03	+ .tiRID1, tiBtn1, .tiRID2, .tiBtn2, .tiRID4, .tiBtn4
if	not exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbUnitMapCell') and name='tiRID1')
begin
	begin tran
		alter table	dbo.tbUnitMapCell	add
			tiRID1		tinyint null				-- R-ID for Aide LED
		,	tiBtn1		tinyint null				-- button code (0-31)
		,	tiRID2		tinyint null				-- R-ID for CNA LED
		,	tiBtn2		tinyint null				-- button code (0-31)
		,	tiRID4		tinyint null				-- R-ID for RN LED
		,	tiBtn4		tinyint null				-- button code (0-31)
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all maps for a given unit
--	v.7.03
create proc		dbo.prMapCell_GetByUnit
(
	@idUnit		smallint					-- unit id
)
	with encryption
as
begin
--	set	nocount	on
	select	c.tiMap, c.tiCell, c.sCell1, c.sCell2, d.idDevice, d.cSys, d.tiGID, d.tiJID, d.cDevice, d.sDevice, d.bActive	--	, c.bSwing
		from	tbUnitMapCell	c	with (nolock)
		left outer join	tbDevice	d	with (nolock)	on	d.idDevice = c.idRoom	--	and	d.bActive > 0	--	and	d.tiRID = 0
--		left outer join	tbDevice	d	with (nolock)	on	d.cSys = c.cSys	and	d.tiGID = c.tiGID	and	d.tiJID = c.tiJID	and	d.tiRID = 0	and	d.bActive > 0
		where	c.idUnit = @idUnit
end
go
grant	execute				on dbo.prMapCell_GetByUnit			to [rWriter]
grant	execute				on dbo.prMapCell_GetByUnit			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates a given map-cell
--	v.7.03	+ @idRoom, - @bSwing, @cSys, @tiGID, @tiJID
--	v.6.04
alter proc		dbo.prUnitMapCell_Upd
(
	@idUnit		smallInt					-- unit id
,	@tiMap		tinyint						-- map index [0..3]
,	@tiCell		tinyint						-- cell index [0..47]
,	@idRoom		smallInt					-- room id
--,	@bSwing		bit							-- swing-able?
,	@sCell1		varchar( 8 )				-- cell name line 1
,	@sCell2		varchar( 8 )				-- cell name line 2
)
	with encryption
as
begin
	declare		@cSys		char( 1 )					-- system ID
			,	@tiGID		tinyint						-- G-ID - gateway
			,	@tiJID		tinyint						-- J-ID - J-bus

	select	@cSys= cSys, @tiGID= tiGID, @tiJID= tiJID
		from	tbDevice	with (nolock)
		where	idDevice = @idRoom

--	set	nocount	on
	begin	tran
		update	tbUnitMapCell	set	idRoom= @idRoom, cSys= @cSys, tiGID= @tiGID, tiJID= @tiJID, sCell1= @sCell1, sCell2= @sCell2	--, bSwing= @bSwing
			where	idUnit = @idUnit	and	tiMap = @tiMap	and	tiCell = @tiCell
	commit
end
go
--	----------------------------------------------------------------------------
--	permission adjustment
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'grant	select, insert, update, delete	on dbo.Facility			to [rReader]
grant	select, insert, update, delete	on dbo.ArchitecturalConfig	to [rReader]
grant	execute				on dbo.sp_InsertArchticturalConfig	to [rReader]
grant	select, insert, update, delete	on dbo.CallPriority		to [rReader]
grant	execute				on dbo.sp_InsertCallPriority		to [rReader]
grant	execute				on dbo.sp_UpdateSpecialCallPriority	to [rReader]
grant	select, insert, update, delete	on dbo.BedDefinition	to [rReader]
grant	execute				on dbo.sp_InsertBedDefinition		to [rReader]
grant	select, insert, update, delete	on dbo.Staff			to [rReader]
grant	select, insert, update, delete	on dbo.Units			to [rReader]
grant	execute				on dbo.sp_InsertUnit				to [rReader]
grant	select, insert, update, delete	on dbo.UserMember		to [rReader]
grant	select, insert, update, delete	on dbo.StaffRole		to [rReader]
grant	select, insert, update, delete	on dbo.Team				to [rReader]
grant	select, insert, update, delete	on dbo.Device			to [rReader]
grant	select, insert, update, delete	on dbo.Access			to [rReader]
grant	select, insert, update, delete	on dbo.StaffToPatientAssignment	to [rReader]
grant	execute				on dbo.sp_InsertRoomBedCoverage		to [rReader]
grant	select, insert, update, delete	on dbo.DeviceToStaffAssignment	to [rReader]
grant	select, insert, update, delete	on dbo.User7985			to [rReader]
grant	select, insert, update, delete	on dbo.ExceptionLog		to [rReader]
grant	execute				on dbo.sp_InsertExceptionLog		to [rReader]
grant	execute				on dbo.sp_GetStaffList				to [rReader]' )
go
--	----------------------------------------------------------------------------
--	Recalculates locations levels upon import
--	v.7.01	* 'MAP ?' -> 'Map ?'
--	v.7.00	- tbUnit.bActive
--	v.6.07	* populating Units
--	v.6.05	+ populating tbUnit, tbUnitMap, tbUnitMapCell
--			+ tracing, transaction
--	v.5.01	encryption added
--	v.2.02
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prDefLoc_SetLvl
	with encryption
as
begin
	declare		@iTrace		int
	declare		@iCount		smallint
	declare		@s			varchar( 255 )
	declare		@idUnit		smallint
	declare		@sUnit		varchar( 16 )
	declare		@tiMap		tinyint
	declare		@tiCell		tinyint

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''S''
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''B''
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''F''
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''U''
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		update	l	set	l.tiLvl= p.tiLvl + 1, l.cLoc= ''C''
			from	tbDefLoc l
			inner join	tbDefLoc p	on	l.idParent = p.idLoc	and	p.tiLvl <> 255
			where	l.tiLvl = 255
		select	@iCount=	@iCount + @@rowcount

		if	@iTrace & 0x01 > 0
		begin
			select	@s= ''Loc_SetLvl( ) '' + cast(@iCount as varchar) + '' rows''
			exec	dbo.pr_Log_Ins	73, null, null, @s
		end

		--	disable non-matching units
		update	u	set	u.bActive= 0, dtUpdated= getdate( )
			from	tbUnit u
				left outer join 	tbDefLoc l	on l.idLoc = u.idUnit
			where	u.bActive = 1	and	l.idLoc is null

		update	Units	set	DownloadCounter= -1

		declare	cur		cursor fast_forward for
			select	idLoc, sLoc
				from	tbDefLoc
				where	tiLvl = 4
				order	by	1

		open	cur
		fetch next from	cur	into	@idUnit, @sUnit
		while	@@fetch_status = 0
		begin
			--	upsert tbUnit to match tbDefLoc
			if	not exists	(select 1 from dbo.tbUnit where idUnit = @idUnit)
--				insert	tbUnit	( idUnit,  sUnit, tiShifts, iStamp, bActive)
--						values	(@idUnit, @sUnit, 0, 0, 1)				-- # of shifts will be set in 7980
				insert	tbUnit	( idUnit,  sUnit, tiShifts, iStamp)
						values	(@idUnit, @sUnit, 0, 0)				-- # of shifts will be set in 7980
			else
				update	tbUnit	set	bActive= 1, sUnit= @sUnit, dtUpdated= getdate( )	--	, tiShifts= 0, iStamp= 0
					where	idUnit = @idUnit

			if	exists	(select 1 from dbo.Units where ID = @idUnit)
				update	Units	set	Name= @sUnit,	DownloadCounter= 0
					where ID = @idUnit
			else
				insert	Units	(ID, Name, ShiftsPerDay, DownloadCounter,
								StartTimeShift1, EndTimeShift1, StartTimeShift2, EndTimeShift2, StartTimeShift3, EndTimeShift3,
								NotificationModeShift1, NotificationModeShift2, NotificationModeShift3,
								BackupStaffIDShift1, BackupStaffIDShift2, BackupStaffIDShift3, 
								CustomRoutingShift1, CustomRoutingShift2, CustomRoutingShift3) 
						values	(@idUnit, @sUnit, 3, 0,
								''07:00'', ''15:00'', ''15:00'', ''23:00'', ''23:00'', ''07:00'',
								0, 0, 0, '''', '''','''', 1, 1, 1)

			--	populate tbUnitMap
			if not exists	(select 1 from tbUnitMap where idUnit = @idUnit)
			begin
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 0, ''Map 1'' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 1, ''Map 2'' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 2, ''Map 3'' )
				insert	tbUnitMap	( idUnit, tiMap, sMap )		values	( @idUnit, 3, ''Map 4'' )
			end

			--	populate tbUnitMapCell
			if not exists	(select 1 from tbUnitMapCell where idUnit = @idUnit)
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

		delete	from	Units	where	DownloadCounter < 0

		delete	from	ArchitecturalConfig
		insert	ArchitecturalConfig	(ID, Name, Parent_ID, ArchitecturalLevel)
			select	idLoc, sLoc, idParent		--	,	tiLvl, cLoc
				,	case when tiLvl = 0 then ''Facility''
						when tiLvl = 1 then ''System''
						when tiLvl = 2 then ''Bldg''
						when tiLvl = 3 then ''Floor''
						when tiLvl = 4 then ''Unit''
						when tiLvl = 5 then ''CArea''
					end
			from	dbo.tbDefLoc	with (nolock)
	commit
end' )
go
--	----------------------------------------------------------------------------
--	Deactivates all devices, resets room state
--	v.7.03.4862
create proc		dbo.prCfgDvc_Init
	with encryption
as
begin
	declare		@iTrace		int
	declare		@s			varchar( 255 )

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8

	begin	tran
		update	tbRoom		set	idUnit= null, idEvent= null, tiSvc= null,	dtUpdated= getdate( )
							,	idRn= null,	sRn= null,	idCn= null,	sCn= null,	idAi= null,	sAi= null

		update	tbDevice	set	bActive= 0, dtUpdated= getdate( )
			where	bActive = 1

		select	@s= 'Dvc_Init( ) ' + cast(@@rowcount as varchar) + ' rows'

		if	@iTrace & 0x01 > 0
		begin
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end
	commit
end
go
grant	execute				on dbo.prCfgDvc_Init				to [rWriter]
go
--	----------------------------------------------------------------------------
--	Returns all recivers
--	v.7.03
create proc		dbo.prRtlsRcvr_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idReceiver, sRcvrType, sReceiver, idDevice
		,	bActive, dtCreated, dtUpdated
--		,	case when bActive > 0 then 'Yes' else 'No' end [sActive]
		from	vwRtlsRcvr	with (nolock)
end
go
grant	execute				on dbo.prRtlsRcvr_GetAll			to [rWriter]
grant	execute				on dbo.prRtlsRcvr_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all sensors
--	v.7.03
create proc		dbo.prRtlsSnsr_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idCollector, sCollector, idSensor, sSnsrType, idReceiver, sReceiver
		,	bActive, dtCreated, dtUpdated
--		,	case when bActive > 0 then 'Yes' else 'No' end [sActive]
		from	vwRtlsSnsr	with (nolock)
end
go
grant	execute				on dbo.prRtlsSnsr_GetAll			to [rWriter]
grant	execute				on dbo.prRtlsSnsr_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns all badges
--	v.7.03
create proc		dbo.prRtlsBadge_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idBadge, sBadgeType, dtEntered, cast(getdate( )-dtEntered as time(0)) [tDuration]
		,	idStaff, sSGJ + ' [' + cDevice + '] ' + sDevice [sCurrLoc]
		,	bActive, dtCreated, dtUpdated
--		,	case when bActive > 0 then 'Yes' else 'No' end [sActive]
		from	vwRtlsBadge	with (nolock)
end
go
grant	execute				on dbo.prRtlsBadge_GetAll			to [rWriter]
grant	execute				on dbo.prRtlsBadge_GetAll			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates 790 device assigned to a given receiver
--	v.7.03	+ check for tbRoom
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
			and	exists	(select 1 from tbRoom with (nolock) where idRoom = @idDevice)		--	v.7.03
		begin
			if	not	exists	(select 1 from tbRtlsRoom with (nolock) where idRoom = @idDevice and idStaffLvl = 1)
				insert tbRtlsRoom (idRoom, idStaffLvl) values (@idDevice, 1)

			if	not	exists	(select 1 from tbRtlsRoom with (nolock) where idRoom = @idDevice and idStaffLvl = 2)
				insert tbRtlsRoom (idRoom, idStaffLvl) values (@idDevice, 2)

			if	not	exists	(select 1 from tbRtlsRoom with (nolock) where idRoom = @idDevice and idStaffLvl = 4)
				insert tbRtlsRoom (idRoom, idStaffLvl) values (@idDevice, 4)
		end

		update	tbRtlsRcvr	set	dtUpdated= getdate( ), idDevice= @idDevice
			where	idReceiver = @idReceiver
	commit
end
go
--	----------------------------------------------------------------------------
--	Exports staff assignment definitions
--	7.03.4884	* BedIndex correction (0->255)
--	6.05
--	6.02
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prStaffAssnDef_Exp
--	with encryption
as
begin
	select	cast(rtrim(RoomName) as varchar(16))	[sRoom]
		,	cast(rtrim(RoomNumber) as varchar(16))	[sDial]
		,	cast(case when BedIndex='''' then ''255'' else BedIndex end as tinyint)	[tiBed]
		,	cast(case when PrimaryUnitID=256	or PrimaryUnitID=0		then null	else PrimaryUnitID end		as smallint)	[idUnit1]
		,	cast(case when SecondaryUnitID=256	or SecondaryUnitID=0	then null	else SecondaryUnitID end	as smallint)	[idUnit2]
		,	dtUpdate [dtUpdated]
		,	TempID

		,	case when len(FirstRspndrIDShift1)=0	then null else cast(rtrim(FirstRspndrIDShift1) as bigint) end	[lStaffID11]
		,	case when len(SecondRspndrIDShift1)=0	then null else cast(rtrim(SecondRspndrIDShift1) as bigint) end	[lStaffID12]
		,	case when len(ThirdRspndrIDShift1)=0	then null else cast(rtrim(ThirdRspndrIDShift1) as bigint) end	[lStaffID13]

		,	case when len(FirstRspndrIDShift2)=0	then null else cast(rtrim(FirstRspndrIDShift2) as bigint) end	[lStaffID21]
		,	case when len(SecondRspndrIDShift2)=0	then null else cast(rtrim(SecondRspndrIDShift2) as bigint) end	[lStaffID22]
		,	case when len(ThirdRspndrIDShift2)=0	then null else cast(rtrim(ThirdRspndrIDShift2) as bigint) end	[lStaffID23]

		,	case when len(FirstRspndrIDShift3)=0	then null else cast(rtrim(FirstRspndrIDShift3) as bigint) end	[lStaffID31]
		,	case when len(SecondRspndrIDShift3)=0	then null else cast(rtrim(SecondRspndrIDShift3) as bigint) end	[lStaffID32]
		,	case when len(ThirdRspndrIDShift3)=0	then null else cast(rtrim(ThirdRspndrIDShift3) as bigint) end	[lStaffID33]

		from	StaffToPatientAssignment
		where	PrimaryUnitID >= 259	or	SecondaryUnitID >= 259		--	enforce only valid Unit IDs
		order	by	sRoom, tiBed
end' )
go
--	----------------------------------------------------------------------------
--	Inserts/deletes a StaffToPatientAssignment row
--	v.7.03	* fix for updating room-names
--	v.7.01	* fix for rooms without beds
--	v.7.00
if	exists	(select 1 from tb_Module where idModule = 1 and sDesc like '7980%')
exec( 'alter proc		dbo.prDevice_UpdRoomBeds7980
(
	@bInsert	bit					-- insert or delete?
,	@idRoom		smallint			-- room id
,	@cBedIdx	varchar( 1 )		-- bed index: '' ''=no bed, null=all combinations
,	@sRoom		varchar( 16 )
,	@sDial		varchar( 16 )
,	@idUnitP	smallint
,	@idUnitA	smallint
)
	with encryption
as
begin
	set	nocount	on
	begin	tran
		if	@bInsert = 0
			delete	from	StaffToPatientAssignment
				where	RoomNumber = @sDial
					and	(BedIndex = @cBedIdx
						or	@cBedIdx is null	and	(BedIndex is null	or	BedIndex <> '' ''))
		else
			if	not exists	(select 1 from StaffToPatientAssignment where RoomNumber = @sDial and BedIndex = @cBedIdx)
				insert	StaffToPatientAssignment
						(RoomNumber, RoomName, BedIndex, DownloadCounter, PrimaryUnitID, SecondaryUnitID)
					values		( @sDial, @sRoom, @cBedIdx, 0, @idUnitP, @idUnitA )
			else
				update	StaffToPatientAssignment
					set	RoomName= @sRoom,	PrimaryUnitID= @idUnitP, SecondaryUnitID= @idUnitA
					where	RoomNumber = @sDial and BedIndex = @cBedIdx
	commit
end' )
go
--	----------------------------------------------------------------------------
--	Updates room's beds and configures corresponding tbRoomBed rows
--	v.7.03	* modified primary/alternate unit selection
--			* call prDevice_UpdRoomBeds7980 1 always (not by tbRoomBed) to facilitate room-name changes
--			+ 7967-P detection and handling
--	v.7.02	* trace: 71 -> 75	+ tb_LogType: [75]
--			* tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--			+ init tbRtlsRoom
--	v.7.01	* fix for rooms without beds
--	v.7.00	* prDevice_UpdRoomBeds7980: @tiBed -> @cBedIdx
--			+ set tbDefBed.bInUse
--			+ rooms without bed
--	v.6.05	+ init tbRoomStaff
--			+ (nolock)
--	v.6.04
alter proc		dbo.prDevice_UpdRoomBeds
(
	@idRoom		smallint			-- room id
,	@siBeds		smallint			-- beds (bitwise) bit0(1)=A, bit1(2)=B,.. bit9(512)=J
)
	with encryption
as
begin
	declare		@iTrace		int
			,	@s			varchar( 255 )
	declare		@sBeds		varchar( 10 )
			,	@cBed		char( 1 )
			,	@cBedIdx	char( 1 )
			,	@tiBed		tinyint
			,	@siMask		smallint
			,	@idUnitP	smallint
			,	@idUnitA	smallint
			,	@sRoom		varchar( 16 )
			,	@sDial		varchar( 16 )
	declare		@idDevice	smallint
			,	@tiPriCA0	tinyint
			,	@tiPriCA1	tinyint
			,	@tiPriCA2	tinyint
			,	@tiPriCA3	tinyint
			,	@tiPriCA4	tinyint
			,	@tiPriCA5	tinyint
			,	@tiPriCA6	tinyint
			,	@tiPriCA7	tinyint

	set	nocount	on

	if	not	exists	(select 1 from tbDevice with (nolock) where idDevice = @idRoom and cDevice='R' and bActive>0)
	and	not	exists	(select 1 from tbDevice with (nolock) where idParent = @idRoom and cDevice='W' and bActive>0)	-- and tiStype=26 and tiRID=1
		return	0					--	do room-beds only for rooms and 7967-Ps

	select	@iTrace= iValue		from	tb_OptionSys	with (nolock)	where	idOption = 8


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
			from	tbDefLoc	with (nolock)
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
			from	tbDefLoc	with (nolock)
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
	--		update	tbRoom	set	idUnit= @idUnitP, dtUpdated= getdate( )					--	v.7.03
	--			where	idRoom = @idRoom
			exec	dbo.prRoom_Upd		@idRoom, @idUnitP, null, null, null		--	reset	v.7.03
		else
			insert	tbRoom	( idRoom,  idUnit)	--	init staff placeholder for this room	v.7.02, v.7.03
					values	(@idRoom, @idUnitP)

		delete	from	tbRtlsRoom				--	reinit staff presence placeholders		v.7.02
			where	idRoom = @idRoom
		insert	tbRtlsRoom	(idRoom, idStaffLvl, bNotify)
				select		@idRoom, idStaffLvl, 1
					from	tbStaffLvl	with (nolock)

		if	@siBeds = 0					--	no beds in this room
		begin
			--	remove combinations with beds
			exec	prDevice_UpdRoomBeds7980	0, @idRoom, null, @sRoom, @sDial, @idUnitP, @idUnitA
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed <> 0xFF

			if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = 0xFF)
			begin
				insert	tbRoomBed	(  idRoom, cBed, tiBed )
						values		( @idRoom, null, 0xFF )
			end
			exec	prDevice_UpdRoomBeds7980	1, @idRoom, ' ', @sRoom, @sDial, @idUnitP, @idUnitA
		end
		else							--	there are beds
		begin
			--	remove combination with no beds
			exec	prDevice_UpdRoomBeds7980	0, @idRoom, ' ', @sRoom, @sDial, @idUnitP, @idUnitA
			delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = 0xFF

			while	@siMask < 1024
			begin
				select	@cBedIdx= cast(@tiBed as char(1))

				if	@siBeds & @siMask > 0		--	@tiBed is present in @idRoom
				begin
					update	tbDefBed	set	bInUse= 1, dtUpdated= getdate( )	where	idIdx = @tiBed
					select	@cBed= cBed, @sBeds= @sBeds + cBed
						from	tbDefBed	with (nolock)
						where	idIdx = @tiBed

					if	not exists	(select 1 from tbRoomBed where idRoom = @idRoom and tiBed = @tiBed)
					begin
						insert	tbRoomBed	(  idRoom,  cBed,  tiBed )
								values		( @idRoom, @cBed, @tiBed )
					end
					exec	prDevice_UpdRoomBeds7980	1, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnitP, @idUnitA
				end
				else							--	@tiBed is absent in @idRoom
				begin
						exec	prDevice_UpdRoomBeds7980	0, @idRoom, @cBedIdx, @sRoom, @sDial, @idUnitP, @idUnitA
						delete from	tbRoomBed	where	idRoom = @idRoom	and	tiBed = @tiBed
				end

				select	@siMask= @siMask * 2
					,	@tiBed=  case when @tiBed < 9 then @tiBed + 1 else 0 end
			end
		end

		update	tbRoom	set	siBeds= @siBeds, sBeds= @sBeds, dtUpdated= getdate( )
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
--	Data source for 7985
--	v.7.03	+ @idMaster
--			+ @iFilter, - @tiShelf
--			* @tiShelf arg used in all branches (LV, WB, MV)
--	v.7.01	+ @tiShelf arg, + idStaffLvl to output
--	v.7.00	utilize fnEventA_GetTopByUnit(..)
--			prRoomBed_GetDataByUnits -> prRoomBed_GetByUnit
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.07	* #tbUnit's PK is only idUnit
--			* output, * MV source
--	v.6.05	+ LV: order by ea.bAnswered, WB: and ( ea.tiStype is null	or	ea.tiStype < 16 )
--			+ and ea.tiShelf > 0
--			+ (nolock), MapView
--	v.6.04
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
	declare		@s			varchar( 400 )

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
			,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	cast(null as tinyint) [tiMap]
	--		,	ea.iFilter, ea.iFilter & @iFilter [iFltBits]
			from	vwEvent_A				ea	with (nolock)
				inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = ea.idUnit
				left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
				left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
				left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	ea.bActive > 0	and	ea.tiShelf > 0	and	( @iFilter = 0	or	ea.iFilter & @iFilter <> 0 )			--	v.7.03
				and	dbo.fnEventA_GetByMaster( @idMaster, ea.cSys, ea.tiGID, ea.tiJID, ea.iFilter, ea.tiCvrg0, ea.tiCvrg1, ea.tiCvrg2, ea.tiCvrg3, ea.tiCvrg4, ea.tiCvrg5, ea.tiCvrg6, ea.tiCvrg7 ) > 0
			order	by	ea.bAnswered, ea.siIdx desc, ea.tElapsed		--	call may have been started before it was recorded (ea.idEvent)

	else if	@tiView = 1		--	WhiteBoard
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	rb.idRoom, rb.sRoom, rb.tiBed, rb.cBed, rb.tiSvc, rb.tiIbed
			,	rb.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
			,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	cast(null as tinyint) [tiMap]
			from	vwRoomBed				rb	with (nolock)
				inner join	#tbUnit			tu	with (nolock)	on	tu.idUnit = rb.idUnit
				outer apply	fnEventA_GetTopByRoom( rb.cSys, rb.tiGID, rb.tiJID, rb.tiBed, @iFilter, @idMaster )	ea		--	v.7.03
				left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
				left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
			where	rb.idUnit is not null
			order	by	rb.sRoom, rb.cBed

	else if	@tiView = 2		--	MapView
		select	tu.idUnit, tu.sUnit,	ea.cSys, ea.tiGID, ea.tiJID, ea.tiRID, ea.tiBtn
			,	ea.idRoom, ea.sRoom, ea.tiBed, ea.cBed, ea.tiSvc, rb.tiIbed
			,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
			,	cast(null as int) [idPatient], cast(null as varchar(16)) [sPatient], cast(null as char(1)) [cGender]
				,	cast(null as varchar(16)) [sInfo], cast(null as varchar(255)) [sNote], cast(null as int) [idDoctor], cast(null as varchar(16)) [sDoctor]
			,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
			,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
			,	mc.tiMap
			from	#tbUnit					tu	with (nolock)
				outer apply	fnEventA_GetTopByUnit( tu.idUnit, @iFilter, @idMaster )	ea									--	v.7.03
				left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
				outer apply	fnUnitMapCell_GetMap( tu.idUnit, ea.cSys, ea.tiGID, ea.tiJID )	mc
end
go
--	----------------------------------------------------------------------------
--	Data source for 7985 (MapView)
--	v.7.03	+ @idMaster
--			+ @iFilter
--	v.7.02	tbDevice.siBeds, .sBeds, .idEvent, .tiSvc, .idUnit moved to tbRoom
--	v.7.01	+ idStaffLvl to output (matching prRoomBed_GetByUnit)
--	v.7.00	ea.idRoom, ea.sRoom -> r.idDevice [idRoom], r.sDevice [sRoom]
--			utilize fnEventA_GetTopByRoom(..)
--			prMapCell_GetDataByUnitMap -> prMapCell_GetByUnitMap
--			utilize tbUnit.idShift
--			tbStaffAssnDef -> tbStaffAssn (prStaffAssn_Fin, prStaffAssn_InsUpdDel, prStaffCover_InsFin, fnStaffAssn_GetByShift, prRptStaffAssn, prRptStaffCover)
--	v.6.07	* output col-names
--	v.6.05
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
		,	ea.idEvent, ea.siIdx, ea.sCall, ea.iColorF, ea.iColorB, ea.dtEvent, ea.tElapsed, ea.dtExpires, ea.bAudio, ea.bAnswered
		,	rb.idPatient, p.sPatient, p.cGender, p.sInfo, p.sNote, rb.idDoctor, d.sDoctor
		,	rb.idAssn1, rb.sAssn1,	rb.idAssn2, rb.sAssn2,	rb.idAssn3, rb.sAssn3,	rb.idStLvl1, rb.idStLvl2, rb.idStLvl3
		,	rb.idRegRn, rb.sRegRn,	rb.idRegCn, rb.sRegCn,	rb.idRegAi, rb.sRegAi
		,	mc.tiMap, mc.tiCell, mc.sCell1, mc.sCell2, rr.siBeds, rr.sBeds	-- r.siBeds, r.sBeds
		from	tbUnitMapCell			mc	with (nolock)
			inner join	tbUnit			u	with (nolock)	on	u.idUnit = mc.idUnit
			left outer join	tbDevice	r	with (nolock)
				on	r.cSys = mc.cSys	and	r.tiGID = mc.tiGID	and	r.tiJID = mc.tiJID	and	r.tiRID = 0		and	r.bActive > 0
			left outer join	tbRoom		rr	with (nolock)	on	rr.idRoom = r.idDevice
			outer apply	fnEventA_GetTopByRoom( mc.cSys, mc.tiGID, mc.tiJID, null, @iFilter, @idMaster )	ea		--	v.7.03
			left outer join	vwRoomBed	rb	with (nolock)	on	rb.idRoom = ea.idRoom	and	( rb.tiBed = ea.tiBed	or	rb.tiBed is null )
			left outer join	tbPatient	p	with (nolock)	on	p.idPatient = rb.idPatient
			left outer join	tbDoctor	d	with (nolock)	on	d.idDoctor = rb.idDoctor
		where	mc.idUnit = @idUnit
			and	mc.tiMap = @tiMap
		order	by	mc.tiMap, mc.tiCell
end
go
--	----------------------------------------------------------------------------
--	Returns all report templates
--	v.7.03
create proc		dbo.prReport_GetAll
	with encryption
as
begin
--	set	nocount	on
	select	idReport, sReport, sRptName, sClass
		from	tbReport	with (nolock)
		order	by	siOrder
end
go
grant	execute				on dbo.prReport_GetAll				to [rWriter]
grant	execute				on dbo.prReport_GetAll				to [rReader]
go
--	----------------------------------------------------------------------------
--	v.7.03	* .xFilter: vc(8000) -> xml
---	if	exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbFilter') and name='xFilter' and user_type_id=167)
if	not exists	(select 1 from sys.columns where object_id=OBJECT_ID('dbo.tbFilter') and name='xFilter' and user_type_id=241)
begin
	begin tran
		delete from	dbo.tbFilter		---	no point in keeping filter names without definitions!!
	--	alter table	dbo.tbFilter		alter column
	--		xFilter		varchar( 8000 ) null
	--	update	dbo.tbFilter	set	xFilter= null
		alter table	dbo.tbFilter		alter column
			xFilter		xml null					-- filter definition (xml)
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns all filters for given user, [public] first, ordered by name
--	v.7.03
create proc		dbo.prFilter_GetByUser
(
	@idUser		smallint
)
	with encryption
as
begin
--	set	nocount	on
	select	idFilter, idUser, sFilter		--, xFilter
		from	tbFilter	with (nolock)
		where	idUser is null
			or	idUser = @idUser
		order	by	idUser, sFilter
end
go
grant	execute				on dbo.prFilter_GetByUser			to [rWriter]
grant	execute				on dbo.prFilter_GetByUser			to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns an existing filter definition
--	v.7.03
create proc		dbo.prFilter_Get
(
	@idFilter	smallint out
)
	with encryption
as
begin
--	set	nocount	on

	select	xFilter
		from	tbFilter	with (nolock)
		where	idFilter = @idFilter
end
go
grant	execute				on dbo.prFilter_Get					to [rWriter]
grant	execute				on dbo.prFilter_Get					to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing filter
--	v.7.03
create proc		dbo.prFilter_InsUpd
(
	@idFilter	smallint out
,	@idUser		smallint			-- public, if null
,	@sFilter	varchar( 64 )		-- filter name
,	@xFilter	xml					-- filter definition (xml)
)
	with encryption
as
begin
	declare		@id		smallint

	set	nocount	on

	-- check that filter name is unique per user
	select	@id= idFilter
		from	tbFilter
		where	(idUser = @idUser	or	@idUser is null	and	idUser is null)
			and	sFilter = @sFilter

	if	@id <> @idFilter	return	-1		-- name is already in use

	begin	tran

		if	@idFilter > 0
		begin
			update	tbFilter	set	idUser= @idUser, sFilter= @sFilter, xFilter= @xFilter, dtUpdated= getdate( )
				where	idFilter = @idFilter
		end
		else
		begin
			insert	tbFilter	(  idUser,  sFilter,  xFilter )
					values		( @idUser, @sFilter, @xFilter )
			select	@idFilter=	scope_identity( )
		end

	commit
end
go
grant	execute				on dbo.prFilter_InsUpd				to [rWriter]
grant	execute				on dbo.prFilter_InsUpd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Deletes an existing filter
--	v.7.03
create proc		dbo.prFilter_Del
(
	@idFilter	smallint out
)
	with encryption
as
begin
	declare		@id		smallint

	set	nocount	on

	-- check that filter is not referenced by a schedule
	select	top 1	@id= idFilter
		from	tbSchedule
		where	idFilter = @idFilter

	if	@id = @idFilter		return	-1		-- filter is in use

	begin	tran

		delete	from	tbFilter
			where	idFilter = @idFilter

	commit
end
go
grant	execute				on dbo.prFilter_Del					to [rWriter]
grant	execute				on dbo.prFilter_Del					to [rReader]
go
--	----------------------------------------------------------------------------
--	v.7.03	* .iResult: smallint -> int
if	not exists	(select 1 from sys.default_constraints where name='tdSchedule_Result')
begin
	begin tran
		alter table	dbo.tbSchedule	alter column
			iResult		int not null		-- for last run: 0=Success, !0==Error code
		alter table	dbo.tbSchedule	add
			constraint	tdSchedule_Result	default( 0 )	for iResult
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns an existing schedule
--	v.7.03
create proc		dbo.prSchedule_Get
(
	@idSchedule	smallint out
)
	with encryption
as
begin
--	set	nocount	on
	select	s.tiRecur, s.tiWkDay, s.siMonth, s.sSchedule, s.dtLastRun, s.dtNextRun, s.iResult
		,	s.idUser, s.idFilter, s.idReport, s.sSendTo, s.bActive, s.dtCreated, s.dtUpdated
		,	cast(case when s.bActive > 0 then 1 else 0 end as tinyint) [tiActive],	u.sUser
		from	tbSchedule	s	with (nolock)
		inner join	tb_User	u	with (nolock)	on	u.idUser = s.idUser
		where	s.idSchedule = @idSchedule
end
go
grant	execute				on dbo.prSchedule_Get				to [rWriter]
grant	execute				on dbo.prSchedule_Get				to [rReader]
go
--	----------------------------------------------------------------------------
--	Returns a list of schedules, waiting to be executed
--	v.7.03
create proc		dbo.prSchedule_GetToRun
	with encryption
as
begin
--	set	nocount	on
	select	s.idSchedule, s.tiRecur, s.tiWkDay, s.siMonth, dtLastRun, dtNextRun		--, iResult
		,	s.idUser [idAuthor], u.sFirst + ' ' + u.sLast [sAuthor], s.idReport, s.sSendTo	--, bActive, dtCreated, dtUpdated
		,	s.idFilter, f.idUser, f.sFilter, f.xFilter
		from	tbSchedule	s	with (nolock)
		inner join	tbFilter f	with (nolock)	on	f.idFilter = s.idFilter
		inner join	tb_User u	with (nolock)	on	u.idUser = s.idUser
		where	s.bActive > 0	and	s.dtNextRun < getdate( )
end
go
grant	execute				on dbo.prSchedule_GetToRun			to [rWriter]
grant	execute				on dbo.prSchedule_GetToRun			to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a new or updates an existing schedule
--	v.7.03
create proc		dbo.prSchedule_InsUpd
(
	@idSchedule	smallint out
,	@tiRecur	tinyint				-- hi 3 bits: 32=Daily, 64=Weekly, 128=Monthly;  lo 5 bits: either 1..31 (D,W), or 1=1st, 2=2nd, 4=3rd, 8=4th, 16=Last
,	@tiWkDay	tinyint				-- 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
,	@siMonth	smallint			-- 1=Jan, 2=Feb, 4=Mar, 8=Apr, 16=May, 32=Jun, 64=Jul, 128=Aug, 256=Sep, 512=Oct, 1024=Nov, 2048=Dec
,	@sSchedule	varchar( 255 )		-- auto: spelled out schedule details
--,	@dtLastRun	smalldatetime		-- when last execution started
,	@dtNextRun	smalldatetime		-- when next execution should start, HH:mm part stores the "Run @" value
--,	@iResult	smallint			-- for last run: 0=Success, !0==Error code
,	@idUser		smallint			-- requester
,	@idFilter	smallint
,	@idReport	smallint
,	@sSendTo	varchar( 255 )		-- list of recipient emails
,	@bActive	bit					-- "deletion" marks inactive
)
	with encryption
as
begin
	declare		@id		smallint

	set	nocount	on

	-- check that filter name is unique per user
--	select	@id= idSchedule
--		from	tbSchedule
--		where	sSchedule = @sSchedule

--	if	@id <> @idSchedule	return	-1		-- schedule already exists

	begin	tran

		if	@idSchedule > 0
		begin
			update	tbSchedule	set	tiRecur= @tiRecur, tiWkDay= @tiWkDay, siMonth= @siMonth, sSchedule= @sSchedule
				,	dtNextRun= @dtNextRun, idUser= @idUser		--, dtLastRun= @dtLastRun, iResult= @iResult
				,	idFilter= @idFilter, idReport= @idReport, sSendTo= @sSendTo, bActive= @bActive, dtUpdated= getdate( )
				where	idSchedule = @idSchedule
		end
		else
		begin
			insert	tbSchedule	(  tiRecur,  tiWkDay,  siMonth,  sSchedule,  dtNextRun,  idUser,  idFilter,  idReport,  sSendTo )	--,  dtLastRun,  iResult
					values		( @tiRecur, @tiWkDay, @siMonth, @sSchedule, @dtNextRun, @idUser, @idFilter, @idReport, @sSendTo )	--, @dtLastRun, @iResult
			select	@idSchedule=	scope_identity( )
		end

	commit
end
go
grant	execute				on dbo.prSchedule_InsUpd			to [rWriter]
grant	execute				on dbo.prSchedule_InsUpd			to [rReader]
go
--	----------------------------------------------------------------------------
--	Updates state for an existing schedule
--	v.7.03
create proc		dbo.prSchedule_Upd
(
	@idSchedule	smallint out
--,	@tiRecur	tinyint				-- hi 3 bits: 32=Daily, 64=Weekly, 128=Monthly;  lo 5 bits: either 1..31 (D,W), or 1=1st, 2=2nd, 4=3rd, 8=4th, 16=Last
--,	@tiWkDay	tinyint				-- 1=Mon, 2=Tue, 4=Wed, 8=Thu, 16=Fri, 32=Sat, 64=Sun
--,	@siMonth	smallint			-- 1=Jan, 2=Feb, 4=Mar, 8=Apr, 16=May, 32=Jun, 64=Jul, 128=Aug, 256=Sep, 512=Oct, 1024=Nov, 2048=Dec
--,	@sSchedule	varchar( 255 )		-- auto: spelled out schedule details
,	@dtLastRun	smalldatetime		-- when last execution started
,	@dtNextRun	smalldatetime		-- when next execution should start, HH:mm part stores the "Run @" value
,	@iResult	smallint			-- for last run: 0=Success, !0==Error code
--,	@idUser		smallint			-- requester
--,	@idFilter	smallint
--,	@idReport	smallint
--,	@sSendTo	varchar( 255 )		-- list of recipient emails
--,	@bActive	bit					-- "deletion" marks inactive
)
	with encryption
as
begin
	declare		@id		smallint

	set	nocount	on

	-- check that filter name is unique per user
--	select	@id= idSchedule
--		from	tbSchedule
--		where	sSchedule = @sSchedule

--	if	@id <> @idSchedule	return	-1		-- schedule already exists

	begin	tran

		update	tbSchedule	set	dtLastRun= @dtLastRun, dtNextRun= @dtNextRun, iResult= @iResult
			where	idSchedule = @idSchedule

	commit
end
go
grant	execute				on dbo.prSchedule_Upd				to [rWriter]
grant	execute				on dbo.prSchedule_Upd				to [rReader]
go
--	----------------------------------------------------------------------------
--	Deletes an existing schedule
--	v.7.03
create proc		dbo.prSchedule_Del
(
	@idSchedule	smallint out
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		delete	from	tbSchedule
			where	idSchedule = @idSchedule

	commit
end
go
grant	execute				on dbo.prSchedule_Del				to [rWriter]
grant	execute				on dbo.prSchedule_Del				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's call filter
--	v.7.03
create proc		dbo.pr_SessCall_Ins
(
	@idSess		int
,	@idCall		smallint
,	@siIdx		smallint			-- call-index
--,	@sCall		varchar( 16 )		-- call-text
,	@tVoTrg		time( 0 )
,	@tStTrg		time( 0 )
)
	with encryption
as
begin
	declare		@sCall	varchar( 16 )

	set	nocount	on

	select	@sCall= sCall
		from	tbDefCallP	with (nolock)	where	idIdx = @siIdx
	---	from	tbDefCall	with (nolock)	where	idCall = @idCall

	begin	tran

		insert	tb_SessCall	(  idSess,  idCall,  siIdx,  sCall,  tVoTrg,  tStTrg )
				values		( @idSess, @idCall, @siIdx, @sCall, @tVoTrg, @tStTrg )

	commit
end
go
grant	execute				on dbo.pr_SessCall_Ins				to [rWriter]
grant	execute				on dbo.pr_SessCall_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's room filter
--	v.7.03
create proc		dbo.pr_SessLoc_Ins
(
	@idSess		int
,	@idLoc		smallint
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		insert	tb_SessLoc	(  idSess,  tiCArea )
				values		( @idSess, @idLoc )

	commit
end
go
grant	execute				on dbo.pr_SessLoc_Ins				to [rWriter]
grant	execute				on dbo.pr_SessLoc_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's room filter
--	v.7.03
create proc		dbo.pr_SessDvc_Ins
(
	@idSess		int
,	@idDevice	smallint
)
	with encryption
as
begin
	set	nocount	on

	if not exists	(select 1 from tb_SessDvc with (nolock) where idSess=@idSess and idDevice=@idDevice)
	begin
		begin	tran
			insert	tb_SessDvc	(  idSess,  idDevice )
					values		( @idSess, @idDevice )
		commit
	end
	else
		return	-1		-- room is already included
end
go
grant	execute				on dbo.pr_SessDvc_Ins				to [rWriter]
grant	execute				on dbo.pr_SessDvc_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's staff filter
--	v.7.03
create proc		dbo.pr_SessStaff_Ins
(
	@idSess		int
,	@idStaff	int
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		insert	tb_SessStaff	(  idSess,  idStaff )
				values			( @idSess, @idStaff )

	commit
end
go
grant	execute				on dbo.pr_SessStaff_Ins				to [rWriter]
grant	execute				on dbo.pr_SessStaff_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Inserts a session's shift filter
--	v.7.03
create proc		dbo.pr_SessShift_Ins
(
	@idSess		int
,	@idShift	int
)
	with encryption
as
begin
	set	nocount	on

	begin	tran

		insert	tb_SessShift	(  idSess,  idShift )
				values			( @idSess, @idShift )

	commit
end
go
grant	execute				on dbo.pr_SessShift_Ins				to [rWriter]
grant	execute				on dbo.pr_SessShift_Ins				to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans-up session's filter tables
--	v.7.03
create proc		dbo.pr_Sess_Clr
(
	@idSess		int
)
	with encryption
as
begin
	set	nocount	on
	begin	tran

		delete from	tb_SessStaff	where	idSess = @idSess
		delete from	tb_SessShift	where	idSess = @idSess
		delete from	tb_SessCall		where	idSess = @idSess
		delete from	tb_SessLoc		where	idSess = @idSess
		delete from	tb_SessDvc		where	idSess = @idSess

	commit
end
go
grant	execute				on dbo.pr_Sess_Clr					to [rWriter]
grant	execute				on dbo.pr_Sess_Clr					to [rReader]
go
--	----------------------------------------------------------------------------
--	Cleans-up a session
--	v.7.03	+ @bLog
--			* uses pr_Sess_Clr now
--	v.6.03	+ tb_Type,tbEvType -> tb_LogType	(idType -> idLogType)
--	v.6.02	+ clean-up tb_SessStaff, tb_SessShift
--	v.6.00	prRptSess_Del -> pr_Sess_Del, revised
--			calls pr_User_Logout now and utilizes timeout option
--	v.5.01	encryption added
--	v.4.01
--	v.2.01	+ tbRptSessDvc (prRptSess_Del)
--	v.1.06
alter proc		dbo.pr_Sess_Del
(
	@idSess		int
,	@bLog		bit=	1	--	log logout (for individual session)?
)
	with encryption
as
begin
	declare		@idUser		smallint
	declare		@sIpAddr	varchar( 40 )
	declare		@sMachine	varchar( 32 )
	declare		@tiTout		tinyint
	declare		@dtLastAct	datetime

	set	nocount	on
	begin	tran

		if	@idSess = 0		-- app-end
		begin
			declare	cur		cursor fast_forward for
				select	idUser, sIpAddr, sMachine
					from	tb_Sess

			open	cur
			fetch next from	cur	into	@idUser, @sIpAddr, @sMachine
			while	@@fetch_status = 0
			begin
				exec	dbo.pr_User_Logout	@idSess, 230, @idUser, @sIpAddr, @sMachine
			
				fetch next from	cur	into	@idUser, @sIpAddr, @sMachine
			end
			close	cur
			deallocate	cur

			delete from	tb_SessStaff
			delete from	tb_SessShift
			delete from	tb_SessCall
			delete from	tb_SessLoc
			delete from	tb_SessDvc
			delete from	tb_Sess
		end
		else				-- sess-end
		begin
			if	@bLog > 0
			begin
				select	@tiTout= cast( iValue as tinyint )	from	tb_OptionSys	where	idOption = 1
				select	@idUser= idUser, @sIpAddr= sIpAddr, @sMachine= sMachine, @dtLastAct= dtLastAct
					from	tb_Sess
					where	idSess = @idSess
				select	@tiTout=	case when dateadd( ss, -10, dateadd( mi, @tiTout, @dtLastAct ) ) < getdate( ) then 230 else 229 end
				exec	dbo.pr_User_Logout	@idSess, @tiTout, @idUser, @sIpAddr, @sMachine
			end

			exec	dbo.pr_Sess_Clr		@idSess
	--	-	delete from	tb_SessStaff	where	idSess = @idSess
	--	-	delete from	tb_SessShift	where	idSess = @idSess
	--	-	delete from	tb_SessCall		where	idSess = @idSess
	--	-	delete from	tb_SessLoc		where	idSess = @idSess
	--	-	delete from	tb_SessDvc		where	idSess = @idSess
			delete from	tb_Sess			where	idSess = @idSess
		end

	commit
end
go
grant	execute				on dbo.pr_Sess_Del					to [rWriter]		--	v.7.03
go
--	----------------------------------------------------------------------------
grant	execute				on dbo.prRpt_XltDtEvRng				to [rWriter]
grant	execute				on dbo.prRptSysActDtl				to [rWriter]
grant	execute				on dbo.prRptCallStatSum				to [rWriter]
grant	execute				on dbo.prRptCallStatSumGraph		to [rWriter]
grant	execute				on dbo.prRptCallStatDtl				to [rWriter]
grant	execute				on dbo.prRptCallActSum				to [rWriter]
grant	execute				on dbo.prRptCallActDtl				to [rWriter]
grant	execute				on dbo.prRptStaffAssn				to [rWriter]
grant	execute				on dbo.prRptStaffCover				to [rWriter]
grant	execute				on dbo.pr_SessCall_Set				to [rWriter]		--	v.7.03
go
grant	select, insert, update, delete	on dbo.tb_SessCall		to [rWriter]		--	v.7.03
grant	select, insert, update, delete	on dbo.tb_SessLoc		to [rWriter]		--	v.7.03
grant	select, insert, update, delete	on dbo.tb_SessDvc		to [rWriter]		--	v.7.03
grant	select, insert, update, delete	on dbo.tb_SessStaff		to [rWriter]		--	v.7.03
grant	select, insert, update, delete	on dbo.tb_SessShift		to [rWriter]		--	v.7.03
go

if	exists	( select 1 from tb_Version where idVersion = 703 )
	update	dbo.tb_Version	set	dtCreated= '2013-05-23', siBuild= 4925, dtInstall= getdate( )
		,	sVersion= '7.03.4891 +4925 - report scheduler, schema refactored, filters'
		where	idVersion = 703
else
	insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
		values	( 703,	4925, '2013-05-23', getdate( ),	'7.03.4891 +4925 - report scheduler, schema refactored, filters' )
go
update	tb_Module	set	 dtStart= getdate( ), sVersion= '7.3.4925'
	where	idModule = 1
go

checkpoint
go

use [master]
go
