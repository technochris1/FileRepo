--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2018-Mar-23		.6656
--						+ prDvc_GetWiFi
--		2018-May-16		.6710
--						* tb_LogType[230]	+ [218-220]
--						* prStaff_SetDuty, prDvc_RegWiFi
--		2018-Jun-12		.6737
--						* pr_Sess_Del, prDvc_UnRegWiFi
--		2018-Jun-19		.6744
--						* prPatient_UpdLoc
--		2018-Jun-25		.6750
--						+ tb_Module[65]
--		2018-Jun-26		.6751
--						* pr_OptSys_Upd, pr_OptUsr_Upd, prCfgDome_Upd, prDevice_InsUpd, prEvent84_Ins
--		2018-Jul-03		.6758
--						* prDevice_InsUpd, prDevice_GetIns
--		2018-Jul-12		.6767
--						+ tbPcsType[0x80..0x82]
--		2018-Jul-18		.6773
--						* prEvent41_Ins
--						* fkRoom_Event:		+ on delete set null
--						* prDevice_InsUpd, prDevice_GetIns
--		2018-Jul-19		.6774
--						+ tbDefCmd[4B], * tbDefCmd[41]
--						* prRptCallActDtl
--		2018-Jul-23		.6778
--						* tb_OptSys[20]
--						+ tb_Option[39], tb_OptSys[39]
--		2018-Jul-25		.6780
--						* tb_Module: - [65]	+ [131]
--						* prDvc_InsUpd
--		2018-Aug-01		.6787
--						+ tb_LogType[228]
--		2018-Aug-03		.6789
--						* prDevice_GetIns
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

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 6789 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.6789', 18, 0 )
go


if	exists	(select 1 from dbo.sysobjects where uid=1 and name='prDvc_GetWiFi')
	drop proc	dbo.prDvc_GetWiFi
go
--	----------------------------------------------------------------------------
--	Returns a Wi-Fi device by the given ID
--	7.06.6656
create proc		dbo.prDvc_GetWiFi
(
	@idDvc		int					-- device
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
		where	idDvc = @idDvc
end
go
grant	execute				on dbo.prDvc_GetWiFi				to [rWriter]
grant	execute				on dbo.prDvc_GetWiFi				to [rReader]
go
--	----------------------------------------------------------------------------
--	7.06.6710	+ [218-220]
--				* [230] -> 'Log-out (forced)'
update	tb_LogType	set	sLogType =	'Log-out (forced)'	where	idLogType = 230;
go
if	not	exists	(select 1 from tb_LogType with (nolock) where idLogType = 218)
begin
	begin tran
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 218, 4, 4, 'Went ON Duty' )			--	7.06.6710
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 219, 4, 4, 'Went on Break' )			--	7.06.6710
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 220, 4, 4, 'Went OFF Duty' )			--	7.06.6710
	commit
end
go
--	----------------------------------------------------------------------------
--	Sets user's Duty and Break states
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

				select	@s =	sFqStaff
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

				select	@s =	sFqStaff +	case when @tiMins > 0 then ' for ' + cast(@tiMins as varchar) + ' min' else '' end
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
--	Registers Wi-Fi devices
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
	begin
		begin	tran

			exec	dbo.prStaff_SetDuty		@idUser, 1, 0

			update	tbDvc	set	idUser =	@idUser,	sDvc =	@sDvc,	sUnits =	@sBrowser
				where	idDvc = @idDvc

		commit
	end

	return	@idLogType
end
go
--	----------------------------------------------------------------------------
--	Cleans-up a given one or all sessions for a module
--	7.06.6737	+ @idModule <> 61 (J7980ns) check
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
	@idSess		int					-- 0 = application-end (delete all sessions)
,	@bLog		bit		=	1		-- log-out user (for individual session)?
,	@idModule	tinyint	=	null	-- indicates app, required if @idSess=0
)
	with encryption
as
begin
	declare		@idLogType	tinyint
		,		@iTout		int

	set	nocount	on

	select	@iTout =	iValue	from	tb_OptSys	where	idOption = 1

	begin	tran

		if	@idSess > 0		-- sess-end
		begin
			if	@bLog > 0
			begin
				select	@idLogType =	case when	@idModule <> 61	and	dateadd( ss, -10, dateadd( mi, @iTout, dtLastAct ) ) < getdate( )
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
--	UnRegisters Wi-Fi devices
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

		update	tbDvc	set	idUser =	null
			where	idDvcType = 0x08		--	wi-fi
			and		(@idDvc = 0		or	idDvc = @idDvc)

		exec	dbo.pr_Sess_Del		@idSess, 1, @idModule

	commit
end
go
--	----------------------------------------------------------------------------
--	Updates patient's room-bed (in response to HL7 notification via cmd x44)
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

		if	@idPatient > 1				-- exempt idPatient = 1 (EMPTY) from moving around	--	7.06.6744
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
--	7.06.6744	* fix: remove idPatient = 1 (EMPTY) from any room
begin
	begin tran
		update	tbRoomBed	set		idPatient=	null,	dtUpdated=	getdate( )
			where	idPatient = 1
	commit
end
go
--	----------------------------------------------------------------------------
--	App modules
--	7.06.6780	- [65]	+ [131]
--	7.06.6750	+ [65]
/*
if	not	exists	(select 1 from dbo.tb_Module where idModule = 65)
begin
	insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
		values	(  65, 'J7980ca',	40,	60,	0,	'7980 Staff Alert App (Android)' )			--	7.06.6750
end
else
	update	dbo.tb_Module	set	sDesc =	'7980 Staff Alert App (Android)'	where	idModule = 65
*/
go
if	not	exists	(select 1 from dbo.tb_Module where idModule = 131)
begin
	begin tran
		insert	dbo.tb_Module ( idModule, sModule, tiModType, tiLvl, bLicense, sDesc )
			values	( 131, 'J7987ca',	40,	60,	0,	'7987 Noti-Fi App (Android)' )				--	7.06.6750, 7.06.6780

		update	dbo.tb_Log	set	idModule =	131	where	idModule = 65
		delete	from	dbo.tb_Module	where	idModule = 65
	commit
end
go
--	----------------------------------------------------------------------------
--	Updates and logs system setting
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

			select	@s =	'OptSys_U [' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s =	@s + ', i=' + isnull(cast(@iValue as varchar), '?') + ' (' + convert(varchar, convert(varbinary(4), @iValue), 1) + ')'
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
--	Updates and logs user setting
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

	select	@k= o.tiDatatype, @i= os.iValue, @f= os.fValue, @t= os.tValue, @s= os.sValue
		from	tb_OptSys	os	with (nolock)
		inner join	tb_Option	o	with (nolock)	on	o.idOption = os.idOption
		where	os.idOption = @idOption		--	v.7.05.5071

	if	@k = 56		and		@iValue <> @i	or
		@k = 62		and		@fValue <> @f	or
		@k = 61		and		@tValue <> @t	or
		@k = 167	and		@sValue <> @s
	begin

		begin	tran
			update	tb_OptUsr	set	iValue= @iValue, fValue= @fValue, tValue= @tValue, sValue= @sValue, dtUpdated= getdate( )
				where	idOption = @idOption	and	idUser = @idUser

	--		if	@idOption = 16	select	@sValue= '************'		--	do not expose SMTP pass

			select	@s= 'OptUsr_U [' + isnull(cast(@idOption as varchar), '?') + ']'

				 if	@k = 56		select	@s =	@s + ', i=' + isnull(cast(@iValue as varchar), '?') + ' (' + convert(varchar, convert(varbinary(4), @iValue), 1) + ')'
			else if	@k = 62		select	@s =	@s + ', f=' + isnull(cast(@fValue as varchar), '?')
			else if	@k = 61		select	@s =	@s + ', t=' + isnull(cast(@tValue as varchar), '?')
			else if	@k = 167	select	@s =	@s + ', s=' + isnull(@sValue, '?')

			exec	dbo.pr_Log_Ins	231, @idUser, null, @s
		commit
	end
end
go
--	----------------------------------------------------------------------------
--	Inserts a Dome Light Show definition
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
	declare		@iTrace		int
		,		@s			varchar( 255 )
		,		@iPrism		int

	set	nocount	on

	select	@iTrace= iValue		from	tb_OptSys	with (nolock)	where	idOption = 8

	select	@s= 'Dome_U( ' + isnull(cast(@tiDome as varchar), '?') + ', ' + convert(varchar, convert(varbinary(4), @iLight0), 1) + ' ' +
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

		if	@iTrace & 0x40 > 0
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6787	+ [228]
--	7.06.6767	* [34]
--				+ [210,211],
--				* 206 -> 210, 207 -> 211
--				* [205..207]
if	not	exists	(select 1 from dbo.tb_LogType where idLogType = 210)
begin
	begin tran
	---	insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 34,  2, 2, 'Service Woke-up' )		--	7.03
		update	dbo.tb_LogType	set	sLogType =	'Service Active'		where	idLogType = 34							--	7.06.6767

		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 210, 1, 16, 'Presence - In' )			--	7.05.5064, 7.06.6767
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 211, 1, 16, 'Presence - Out' )		--	7.05.5064, 7.06.6767
		insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 228, 8, 4, 'Log-in failed (lic)' )	--	7.06.6787

		update	dbo.tb_Log	set	idLogType=	210		where	idLogType = 206
		update	dbo.tb_Log	set	idLogType=	211		where	idLogType = 207

	---	insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 205, 1, 16, 'Page Attempted' )
		update	dbo.tb_LogType	set	sLogType =	'Pager Action'			where	idLogType = 205							--	7.06.6767
	---	insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 206, 1, 16, 'Wi-Fi Action' )			--	7.06.6767
		update	dbo.tb_LogType	set	sLogType =	'Wi-Fi Action'			where	idLogType = 206							--	7.06.6767
	---	insert	dbo.tb_LogType ( idLogType, tiLvl, tiSrc, sLogType )	values	( 207, 1, 16, 'Badge Action' )			--	7.06.6767
		update	dbo.tb_LogType	set	sLogType =	'Badge Action'			where	idLogType = 207							--	7.06.6767
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6767	+ [0x80..0x82]
--				* [9] -> [0x40]
if	not	exists	(select 1 from dbo.tbPcsType where idPcsType = 0x80)
begin
	begin tran
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x40, 'RPP Page Sent' )	--	7.06.6767

		update	dbo.tbEvent41	set	idPcsType=	0x40	where	idPcsType = 9

		delete	from	dbo.tbPcsType	where	idPcsType = 9

		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x80, 'Alert sent' )		--	7.06.6767
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x81, 'Rejected' )		--	7.06.6767
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x82, 'Accepted' )		--	7.06.6767
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x83, 'Upgraded' )		--	7.06.6767
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x84, 'UnRejected' )		--	7.06.6767
		insert	dbo.tbPcsType ( idPcsType, sPcsType )	values	(  0x85, 'UnAccepted' )		--	7.06.6767
	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.6774	+ [4B], * [41]
if	not	exists	(select 1 from dbo.tbDefCmd where idCmd = 0x4B)
begin
	begin tran
	---	insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x41, 'pager activity' )						--	5.01, 7.06.6774
		update	dbo.tbDefCmd	set	sCmd =	'pager activity'		where	idCmd = 0x41				--	7.06.6774
		insert	dbo.tbDefCmd ( idCmd, sCmd )	values	( 0x4B, 'wi-fi activity' )						--	7.06.6774
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts event [0x84] call status
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
					' #' + isnull(@sDial,'?') + ', a=' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') +
					', d=' + isnull(@cDstSys,'?') + '-' + isnull(right('00' + cast(@tiDstGID as varchar), 3),'?') + '-' + isnull(right('00' + cast(@tiDstJID as varchar), 3),'?') + '-' +
					isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ', b=' + isnull(cast(@tiBed as varchar),'?') + 
					', c=' + isnull(cast(@siIdxOld as varchar),'?') + '->' + isnull(cast(@siIdxNew as varchar),'?') + ':"' + isnull(@sCall,'?') + '", i="' + isnull(@sInfo,'?') + '" )'


--	if	@iTrace & 0x4000 > 0
--		exec	dbo.pr_Log_Ins	1, null, null, 'E84_Ins00'

	if	not exists	(select 1 from tbUnit with (nolock) where idUnit = @idUnit and bActive > 0)
		select	@idUnit =	null,	@p =	@p + ' !U'						-- invalid unit


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
		select	@siBed =	0xFFFF,		@tiBed =	null,	@p =	@p + ' !B'
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
		,	@idLogType =	case when	@idOrigin is null	then			-- call placed | presense-in
									case when	@bPresence > 0	then 210	else 191 end			--	7.06.6767
								when	@siIdxNew = 0		then			-- cancelled | presense-out
									case when	@bPresence > 0	then 211	else 193 end			--	7.06.6767
								else										-- escalated | healing
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
--	Inserts event [0x41]
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
--	7.06.6773	+ on delete set null
begin tran
	alter table		dbo.tbRoom		drop	constraint	fkRoom_Event
	alter table		dbo.tbRoom		add
		constraint	fkRoom_Event	foreign key (idEvent)	references	tbEvent	on delete set null
commit
go
--	----------------------------------------------------------------------------
--	Inserts or updates devices during 790 Config download
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@idUnit		smallint
		,		@sUnits		varchar( 255 )
		,		@iAID0		int
	
	set	nocount	on

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	select	@s =	'Dvc_IU( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a=' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ', v=' + isnull(@sCodeVer,'?') +
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

		if	@iTrace & 0x04 > 0
		begin
			select	@s =	@s + ' id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
			exec	dbo.pr_Log_Ins	74, null, null, @s
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	Finds devices and re-activates or inserts if necessary (during run-time)
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
	declare		@s			varchar( 255 )
		,		@iTrace		int
		,		@sSysts		varchar( 255 )
		,		@idParent	smallint
		,		@bActive	bit
		,		@sD			varchar( 16 )
		,		@iA			int

	set	nocount	on

	if	@cSys is null	and	@tiGID is null	and	@tiJID is null	and	@tiRID is null
		return	0															-- empty device

	select	@iTrace =	iValue		from	tb_OptSys	with (nolock)	where	idOption = 8
	select	@sSysts =	sValue		from	tb_OptSys	with (nolock)	where	idOption = 26

	if	charindex('SIP:', @sDevice) = 1										-- SIP-phone
		select	@cDevice =	'P'

	select	@s =	'Dvc_GI( ' + isnull(@cSys,'?') + '-' + right('00' + isnull(cast(@tiGID as varchar),'?'), 3) + '-' +
					right('00' + isnull(cast(@tiJID as varchar),'?'), 3) + '-' + right('0' + isnull(cast(@tiRID as varchar),'?'), 2) +
					', a=' + isnull(cast(convert(varchar, convert(varbinary(4), @iAID), 1) as varchar),'?') + ', t=' + isnull(cast(@tiStype as varchar),'?') +
					', [' + isnull(@cDevice,'?') + '] "' + isnull(@sDevice,'?') + '" #' + isnull(@sDial,'?') + ' )'

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

		if	@tiRID = 0	and	@sD <> @sDevice		or	@iA <> @iAID
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

				if	@iTrace & 0x04 > 0
				begin
					select	@s =	@s + ' id=' + isnull(cast(@idDevice as varchar),'?') + ', p=' + isnull(cast(@idParent as varchar),'?')
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
		,	c.siIdx		--, e.idCall
		,	case	when e41.idEvent > 0	then e41.idPcsType	else cp.tiSpec		end		as	tiSpec
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
--	7.06.6778	* [20]
update	dbo.tb_OptSys	set	 iValue =	iValue | 8	where	idOption = 20	--	0=none, [1=badge], 2=pager, 4=phone, 8=wi-fi, 14=pager|phone|wi-fi
go
--	----------------------------------------------------------------------------
--	7.06.6778	+ [39]
if	not	exists	(select 1 from dbo.tb_Option where idOption = 39)
begin
	begin tran
--		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 38,  61, 'Default shift start time' )					--	7.06.5934,	.6778
		update	dbo.tb_Option	set	sOption =	'Default shift start time'	where	idOption = 38
		insert	dbo.tb_Option ( idOption, tiDatatype, sOption )	values	( 39,  56, 'Default staff level' )						--	7.06.6778

		insert	dbo.tb_OptSys ( idOption, iValue )	values	( 39, 0 )
	commit
end
go
--	----------------------------------------------------------------------------
--	Inserts or updates a device
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

	select	@s= '[' + isnull(cast(@idDvc as varchar), '?') + '], t=' + cast(@idDvcType as varchar) + ', n="' + @sDvc +
				'", b=' + isnull(cast(@sBarCode as varchar), '?') + ', d="' + isnull(cast(@sDial as varchar), '?') +
				'", f=' + cast(@tiFlags as varchar) + ', a=' + cast(@bActive as varchar)
--	exec	dbo.pr_Log_Ins	1, @idUser, null, @s

	begin	tran

		if	exists	(select 1 from tbDvc with (nolock) where idDvc = @idDvc)
		begin
			select	@s= 'Dvc_U( ' + @s + ' )'
				,	@k=	248

			update	tbDvc	set	idDvcType=	@idDvcType,		sDvc =		@sDvc
							,	sDial=		@sDial,			sBarCode =	@sBarCode,		tiFlags =	@tiFlags
							,	idUser =	case when @bActive > 0 then idUser else null end	-- unassign deactivated
							,	sUnits =	@sUnits,		sTeams =	@sTeams,		bActive =	@bActive,	dtUpdated=	getdate( )
				where	idDvc = @idDvc

/*			if	@idDvcType = 0x01		--	badge
				and	@bActive = 0		--	disabled
				update	tbRtlsBadge		set	dtEntered=	null
					where	idBadge = @idDvc
*/		end
		else
		begin
			select	@s= 'Dvc_I( ' + @s + ' ) = '

			insert	tbDvc	(  idDvcType,  sDvc,  sBarCode,  sDial,  tiFlags,  sUnits,  sTeams,  bActive )
					values	( @idDvcType, @sDvc, @sBarCode, @sDial, @tiFlags, @sUnits, @sTeams, @bActive )
			select	@idDvc =	scope_identity( )

			select	@s= @s + cast(@idDvc as varchar)
				,	@k=	247
		end

		if	@idDvcType = 0x08		--	Wi-Fi
			update	tbDvc	set	sBarCode =	cast(@idDvc as varchar)		where	idDvc = @idDvc

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


begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 6789 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	6789, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtCreated=	'2018-08-03',	dtInstall=	getdate( )
		,	sVersion =	'*7983ls, *7983rh, *7980ns, *7980ca, *7980rh, +7987ca, *7981ls'
		where	siBuild = 6789

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.6789'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.6789 )'
commit
go

checkpoint
go

use [master]
go