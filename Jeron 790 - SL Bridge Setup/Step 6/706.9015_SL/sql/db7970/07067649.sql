--	============================================================================
--	Database update script for Microsoft SQL Server 2008+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	7.06
--		2020-Sep-09		.7557
--						* prEvent41_Ins
--		2020-Oct-09		.7587
--						* tbRouting	+ .tResp4	(prRouting_Get, prRouting_Set)
--		2020-Nov-05		.7614
--						* prRptRndStatSum, prRptRndStatDtl
--		2020-Nov-09		.7618
--						* prEvent_Maint
--		2020-Nov-18		.7627
--						+ xtCfgPri_tiLvl
--		2020-Dec-02		.7641
--						* tbCfgPri.tiLvl	(prCfgPri_InsUpd)
--		2020-Dec-04		.7643
--						* prCall_GetAll
--		2020-Dec-08		.7647
--						- xtCfgPri_tiLvl
--		2020-Dec-10		.7649
--						* prRptCallStatSum, prRptStfAssn
--						
--	============================================================================

use [{0}]
go
set	xact_abort	on
set ansi_null_dflt_on on
set nocount on
set quoted_identifier on
go

if exists	(select top 1 idVersion from dbo.tb_Version where idVersion >= 706 and siBuild >= 7649 order by siBuild desc)
	raiserror( 'DB is already at target version - 7.06.7649', 18, 0 )
go


go
--	----------------------------------------------------------------------------
--	Inserts event [0x41]
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

	select	@s =	'E41_I( ' + isnull(@cSrcSys,'?') + '-' + isnull(right('00' + cast(@tiSrcGID as varchar), 3),'?') + '-' +
					isnull(right('00' + cast(@tiSrcJID as varchar), 3),'?') + '-' + isnull(right('0' + cast(@tiSrcRID as varchar), 2),'?') + ' /' +
					isnull(cast(@tiBtn as varchar),'?') + ' ''' + isnull(@sSrcDvc,'?') + ''''
	if	@tiBed < 10
		select	@s =	@s + ':' + cast(@tiBed as varchar)
	select	@s =	@s + ', ' + isnull(cast(@idPcsType as varchar),'?') + ' #' + isnull(@sDial,'?') +
					' ' + isnull(cast(@idDvcType as varchar),'?') + '|' + isnull(cast(@idDvc as varchar),'?')
	if	@idPcsType = 64														-- RPP page sent
		select	@s =	@s + ' <' + isnull(cast(@tiSeqNum as varchar),'?') + ':' + isnull(@cStatus,'?') + '>'
	if	len(@sInfo) > 0
		select	@s =	@s + ', ''' + @sInfo + ''''
	select	@s =	@s + ' )'

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

		select	@s =	@s + '=' + isnull(cast(@idEvent as varchar),'?') +	--- ', u=' + isnull(cast(@idUnit as varchar),'?') +
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
--	7.06.7587	+ .tResp4
if	not exists	(select 1 from sys.columns where object_id = OBJECT_ID('dbo.tbRouting') and name = 'tResp4')
begin
	begin tran
		alter table	dbo.tbRouting	add
			tResp4		time( 0 )		null		-- wait interval after shift backup

		exec( '
		update	dbo.tbRouting	set	tResp4 =	tResp0
		update	dbo.tbRouting	set	tResp0 =	case	when	idShift = 0	then	''00:00:00''	else	null	end
			' )
	commit
end
go
--	----------------------------------------------------------------------------
--	Returns call-routing data for given shift [and priority]
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
	select	@idShift	[idShift],	z.siIdx, p.sCall, p.tiShelf, p.tiSpec, p.iColorF, p.iColorB
		,	cast(case when p.tiFlags & 0x02 > 0 then 1 else 0 end as bit)	[bEnabled]
	--	,	case when r.tiRouting is null then z.tiRouting else r.tiRouting end	[tiRouting]
		,	coalesce( r.tiRouting, z.tiRouting )	[tiRouting]
		,	coalesce( r.bOverride, z.bOverride )	[bOverride]
		,	coalesce( r.tResp0, z.tResp0 )			[tResp0]
		,	coalesce( r.tResp1, z.tResp1 )			[tResp1]
		,	coalesce( r.tResp2, z.tResp2 )			[tResp2]
		,	coalesce( r.tResp3, z.tResp3 )			[tResp3]
		,	coalesce( r.tResp4, z.tResp4 )			[tResp4]
		,	coalesce( r.dtUpdated, z.dtUpdated )	[dtUpdated]
	--	,	r.dtUpdated								[dtUpdated]
	/*	,	z.tiRouting	[_tiRouting]
		,	z.bOverride	[_bOverride]
		,	z.tResp0	[_tResp0]
		,	z.tResp1	[_tResp1]
		,	z.tResp2	[_tResp2]
		,	z.tResp3	[_tResp3]
		,	z.dtUpdated	[_dtUpdated]
	*/	,	cast( case when r.tiRouting is null then 0 else 1 end as bit )	[bRoute]
		,	cast( case when r.bOverride is null then 0 else 1 end as bit )	[bOverr]
		,	cast( case when r.tResp0 is null then 0 else 1 end as bit )		[bResp0]
		,	cast( case when r.tResp1 is null then 0 else 1 end as bit )		[bResp1]
		,	cast( case when r.tResp2 is null then 0 else 1 end as bit )		[bResp2]
		,	cast( case when r.tResp3 is null then 0 else 1 end as bit )		[bResp3]
		,	cast( case when r.tResp4 is null then 0 else 1 end as bit )		[bResp4]
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
--	Sets call-routing data for given shift and priority
--	7.06.7587	+ .tResp4
--	7.04.4944
--	7.04.4938
alter proc		dbo.prRouting_Set
(
	@idShift	smallint
,	@siIdx		smallint
,	@tiRouting	tinyint
,	@bOverride	bit
,	@tResp0		time( 0 )
,	@tResp1		time( 0 )
,	@tResp2		time( 0 )
,	@tResp3		time( 0 )
,	@tResp4		time( 0 )
)
	with encryption
as
begin
	declare	@bRecord	bit
		,	@_tiRouting	tinyint
		,	@_bOverride	bit
		,	@_tResp0	time( 0 )
		,	@_tResp1	time( 0 )
		,	@_tResp2	time( 0 )
		,	@_tResp3	time( 0 )
		,	@_tResp4	time( 0 )

	set	nocount	on

	if	@idShift > 0
	begin
		select	@bRecord =	0,	@_tiRouting =	tiRouting,	@_bOverride =	bOverride
			,	@_tResp0 =	tResp0,		@_tResp1 =	tResp1,		@_tResp2 =	tResp2,		@_tResp3 =	tResp3,		@_tResp4 =	tResp4
			from	tbRouting	with (nolock)
			where	idShift = 0			and	siIdx = @siIdx

		if	@tiRouting is null	or	@tiRouting = @_tiRouting
			select	@tiRouting= @_tiRouting
		else
			select	@bRecord=	1

		if	@bOverride is null	or	@bOverride = @_bOverride
			select	@bOverride= @_bOverride
		else
			select	@bRecord=	1

		if	@tResp0 is null	or	@tResp0 = @_tResp0
			select	@tResp0= null
		else
			select	@bRecord=	1

		if	@tResp1 is null	or	@tResp1 = @_tResp1
			select	@tResp1= null
		else
			select	@bRecord=	1

		if	@tResp2 is null	or	@tResp2 = @_tResp2
			select	@tResp2= null
		else
			select	@bRecord=	1

		if	@tResp3 is null	or	@tResp3 = @_tResp3
			select	@tResp3= null
		else
			select	@bRecord=	1

		if	@tResp4 is null	or	@tResp4 = @_tResp4
			select	@tResp4= null
		else
			select	@bRecord=	1
	end
--	print	@idShift
--	print	@bRecord

	begin	tran

		if	@idShift > 0
		begin
			if	@bRecord > 0
			begin
--				select count(*) from tbRouting with (nolock) where idShift = @idShift and siIdx = @siIdx

				if	not	exists	(select 1 from tbRouting with (nolock) where idShift = @idShift and siIdx = @siIdx)
				begin
--					print	'ins'
					insert	tbRouting	(  idShift,  siIdx,  tiRouting,  bOverride,  tResp0,  tResp1,  tResp2,  tResp3,  tResp4 )
							values		( @idShift, @siIdx, @tiRouting, @bOverride, @tResp0, @tResp1, @tResp2, @tResp3, @tResp4 )

					select	@bRecord=	0
				end
		--		else
		--			select	@bRecord=	1		--	no need, already 1
	--				update	tbRouting	set
	--						tiRouting= @tiRouting,	bOverride= @bOverride,	dtUpdated=	getdate( )
	--					,	tResp0= @tResp0,	tResp1= @tResp1,	tResp2= @tResp2,	tResp3= @tResp3
	--					where	idShift = @idShift	and	siIdx = @siIdx
			end
			else
			begin
--				print	'del'
				delete	from	tbRouting
					where	idShift = @idShift	and	siIdx = @siIdx
			end
		--		select	@bRecord=	0		--	no need, already 0
		end
	--	else						--	defaults
		if	@idShift = 0	or	@bRecord > 0
		begin
--			print	'upd'
			update	tbRouting	set
					tiRouting =	@tiRouting,	bOverride =	@bOverride,	dtUpdated=	getdate( )
				,	tResp0 =	@tResp0,	tResp1 =	@tResp1,	tResp2 =	@tResp2,	tResp3 =	@tResp3,	tResp4 =	@tResp4
				where	idShift = @idShift	and	siIdx = @siIdx
		end

	commit
end
go
--	----------------------------------------------------------------------------
--	7.06.7614	* Vo|St -> Good|Fair|Poor
--	7.06.7311
alter proc		dbo.prRptRndStatSum
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
		,		@f100		float

	set	nocount	on

	select	@f100=	100

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

	select	siIdx, tiFlags, lCount - lStNul	as	lCount, sCall,	tVoTrg,	tStTrg
		,	tStAvg, tStMax
--		,	lGood,	case when tStAvg is null	then null	else cast(lGood as float)*100/(lCount-lStNul) end	as	fGood
--		,	lFair,	case when tStAvg is null	then null	else cast(lFair as float)*100/(lCount-lStNul) end	as	fFair
--		,	lPoor,	case when tStAvg is null	then null	else cast(lPoor as float)*100/(lCount-lStNul) end	as	fPoor
--		,	lGood,	case when tStAvg is null	then null	else lGood * @f100 / lCount end	as	fGood
--		,	lFair,	case when tStAvg is null	then null	else lFair * @f100 / lCount end	as	fFair
--		,	lPoor,	case when tStAvg is null	then null	else lPoor * @f100 / lCount end	as	fPoor
		,	lGood,	case when tStAvg is null	then null	else lGood*@f100/(lCount-lStNul) end	as	fGood
		,	lFair,	case when tStAvg is null	then null	else lFair*@f100/(lCount-lStNul) end	as	fFair
		,	lPoor,	case when tStAvg is null	then null	else lPoor*@f100/(lCount-lStNul) end	as	fPoor
--		,	lPoor,	case when tStAvg is null	then null	else (lCount-lStNul-lGood-lFair)*100/(lCount-lStNul) end	as	fPoor
		from
			(select	sc.siIdx,	count(*) as	lCount
				,	min(cp.tiFlags)	as	tiFlags
				,	min(sc.sCall)	as	sCall
				,	min(sc.tVoTrg)	as	tVoTrg
				,	min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ep.tWaitS as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ep.tWaitS)	as	tStMax
				,	sum(case when ep.tWaitS is null									then 1 else 0 end)	as	lStNul
				,	sum(case when 							ep.tWaitS <= sc.tVoTrg	then 1 else 0 end)	as	lGood
				,	sum(case when sc.tVoTrg < ep.tWaitS and ep.tWaitS <= sc.tStTrg	then 1 else 0 end)	as	lFair
				,	sum(case when sc.tStTrg < ep.tWaitS								then 1 else 0 end)	as	lPoor
				from	#tbRpt1		et	with (nolock)
				join	vwEvent_D	ep	with (nolock)	on	ep.idEvent = et.idEvent
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ep.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				group	by	sc.siIdx)	t
		order	by	siIdx desc
end
go
--	----------------------------------------------------------------------------
--	7.06.7614	* Vo|St -> Good|Fair|Poor
--	7.06.7311
alter proc		dbo.prRptRndStatDtl
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
		,		@f100		float

	set	nocount	on

	select	@f100=	100

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
		,	siIdx, tiFlags, lCount - lStNul	as	lCount, sCall,	tVoTrg,	tStTrg
		,	tStAvg, tStMax
		,	lGood,	case when tStAvg is null	then null	else lGood*@f100/(lCount-lStNul) end	as	fGood
		,	lFair,	case when tStAvg is null	then null	else lFair*@f100/(lCount-lStNul) end	as	fFair
		,	lPoor,	case when tStAvg is null	then null	else lPoor*@f100/(lCount-lStNul) end	as	fPoor
		from
			(select	ep.idUnit, ep.idRoom
				,	ep.dEvent, sc.siIdx,	count(*) as	lCount
				,	min(cp.tiFlags)	as	tiFlags
				,	min(sc.sCall)	as	sCall
				,	min(sc.tVoTrg)	as	tVoTrg
				,	min(sc.tStTrg)	as	tStTrg
				,	cast( cast( avg( cast( cast(ep.tWaitS as datetime) as float) ) as datetime) as time(3) )	as	tStAvg
				,	max(ep.tWaitS)	as	tStMax
				,	sum(case when ep.tWaitS is null									then 1 else 0 end)	as	lStNul
				,	sum(case when 							ep.tWaitS <= sc.tVoTrg	then 1 else 0 end)	as	lGood
				,	sum(case when sc.tVoTrg < ep.tWaitS and ep.tWaitS <= sc.tStTrg	then 1 else 0 end)	as	lFair
				,	sum(case when sc.tStTrg < ep.tWaitS								then 1 else 0 end)	as	lPoor
				from	#tbRpt1		et	with (nolock)
				join	vwEvent_D	ep	with (nolock)	on	ep.idEvent = et.idEvent
				join	tb_SessCall	sc	with (nolock)	on	sc.idCall = ep.idCall	and	sc.idSess = @idSess
				join	tbCfgPri	cp	with (nolock)	on	cp.siIdx = sc.siIdx
				group	by	ep.idUnit, ep.idRoom, ep.dEvent, sc.siIdx)	e
		join	tbUnit		u	with (nolock)	on	u.idUnit = e.idUnit
		join	vwRoom		r	with (nolock)	on	r.idDevice = e.idRoom
		order	by	e.idUnit, e.idRoom, e.siIdx desc
end
go
--	----------------------------------------------------------------------------
--	Removes no longer needed events, called on schedule every hour
--	7.06.7618	+ tbEvent_D cascade null
--	7.06.7467	* logging: Trc -> Dbg
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
	declare		@tiLog		tinyint
		,		@s			varchar( 255 )
		,		@dt			datetime
		,		@idEvent	int
		,		@iCount		int
		,		@tiPurge	tinyint			-- FF=keep everything
											-- N=remove auxiliary data older than N days (cascaded)
											-- 0=remove all inactive events from [tbEvent*] (cascaded)
	set	nocount	on

	select	@dt =	getdate( )												-- smalldatetime truncates seconds

	select	@tiLog =	tiLvl	from	dbo.tb_Module	with (nolock)	where	idModule = 1

	select	@tiPurge =	cast(iValue as tinyint)	from	tb_OptSys	with (nolock)	where	idOption = 7

	begin tran

		exec	dbo.prEvent_A_Exp

		if	@tiPurge < 0xFF													-- remove something
		begin

			if	@tiPurge = 0												-- remove all inactive events
			begin
				update	ec	set	ec.idEvtVo =	null						-- implements CASCADE SET NULL
					from	tbEvent_C	ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtVo
					where	a.idEvent is null

				update	ec	set	ec.idEvtSt =	null
					from	tbEvent_C	ec
					left join	tbEvent_A	a	on	a.idEvent = ec.idEvtSt
					where	a.idEvent is null

				update	ed	set	ed.idEvntS =	null						-- implements CASCADE SET NULL
					from	tbEvent_D	ed
					left join	tbEvent_A	a	on	a.idEvent = ed.idEvntS
					where	a.idEvent is null

				update	ed	set	ed.idEvntD =	null
					from	tbEvent_D	ed
					left join	tbEvent_A	a	on	a.idEvent = ed.idEvntD
					where	a.idEvent is null

				delete	e	from	tbEvent	e
					left join	tbEvent_A	a	on	a.idEvent = e.idEvent
					where	a.idEvent is null

				select	@iCount =	@@rowcount

--				if	@tiLog & 0x02 > 0										--	Config?
				if	@tiLog & 0x04 > 0										--	Debug?
--				if	@tiLog & 0x08 > 0										--	Trace?
					if	0 < @iCount
					begin
						select	@s =	'Ev_M( ' + cast(@tiPurge as varchar) + ' ) -' + cast(@iCount as varchar) +
										' in ' + convert(varchar, getdate() - @dt, 114)
	--					exec	dbo.pr_Log_Ins	1, null, null, @s			--	7.06.7276	trace is enough
						exec	dbo.pr_Log_Ins	0, null, null, @s			--	7.06.7467	debug
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
--	7.06.7627	+ xtCfgPri_tiLvl
--	7.06.7647	- xtCfgPri_tiLvl
/*
if	not exists	(select 1 from dbo.sysindexes where id = OBJECT_ID('dbo.tbCfgPri') and name='xtCfgPri_tiLvl')
begin
	begin tran
		create nonclustered index	xtCfgPri_tiLvl	on	dbo.tbCfgPri ( tiLvl )		--	7.06.7627
	commit
end
*/
go
--	----------------------------------------------------------------------------
--	Inserts a call-priority definition
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

	select	@s =	'Pri_U( ' + isnull(cast(@siIdx as varchar),'?') + ', ' +
					isnull(convert(varchar, convert(varbinary(1), @tiFlags), 1),'?') + '|' +
					isnull(convert(varchar, convert(varbinary(1), @tiLvl), 1),'?') + ', ''' + isnull(@sCall,'?') + ''', sh=' +
					isnull(cast(@tiShelf as varchar),'?') +	'|' + isnull(cast(@tiSpec as varchar),'?') + ', ug=' +
					isnull(cast(@siIdxUg as varchar),'?') + ', ot=' +
					isnull(cast(@siIdxOt as varchar),'?') +	'|' + isnull(cast(@tiOtInt as varchar),'?') + ', k=' +
					isnull(convert(varchar, convert(varbinary(4), @iColorF), 1),'?') + ' /' +
					isnull(convert(varchar, convert(varbinary(4), @iColorB), 1),'?') + ', ' +
					isnull(convert(varchar, convert(varbinary(4), @iFilter), 1),'?') + ', ls=' +
					isnull(cast(@tiDome as varchar),'?') + ', t=' +
					isnull(cast(@tiTone as varchar),'?') +	'|' + isnull(cast(@tiToneInt as varchar),'?') + ' )'

	begin	tran

		if	exists	(select 1 from tbCfgPri where siIdx = @siIdx)
			update	tbCfgPri	set		sCall=	@sCall,		tiFlags =	@tiFlags
				,	tiShelf =	@tiShelf,	tiLvl =		@tiLvl,		tiSpec =	@tiSpec,	siIdxUg =	@siIdxUg
				,	siIdxOt =	@siIdxOt,	tiOtInt =	@tiOtInt,	tiDome =	@tiDome,	tiTone =	@tiTone
				,	tiToneInt=	@tiToneInt,	iColorF =	@iColorF,	iColorB =	@iColorB,	iFilter =	@iFilter
				where	siIdx = @siIdx
		else
			insert	tbCfgPri	(  siIdx,  sCall,  tiFlags,  tiShelf,  tiLvl,  tiSpec,  siIdxUg,  siIdxOt,  tiOtInt,  tiDome,  tiTone,  tiToneInt,  iColorF,  iColorB,  iFilter )
					values		( @siIdx, @sCall, @tiFlags, @tiShelf, @tiLvl, @tiSpec, @siIdxUg, @siIdxOt, @tiOtInt, @tiDome, @tiTone, @tiToneInt, @iColorF, @iColorB, @iFilter )

		if	@tiLog & 0x02 > 0												--	Config?
--		if	@tiLog & 0x04 > 0												--	Debug?
--		if	@tiLog & 0x08 > 0												--	Trace?
			exec	dbo.pr_Log_Ins	72, null, null, @s

	commit
end
go
--	----------------------------------------------------------------------------
--	Returns active call-priorities, ordered to be loadable into a table
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
			,	p.tiFlags, p.tiShelf, p.tiLvl, p.tiSpec, p.iColorF, p.iColorB
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
			,	p.tiFlags, p.tiShelf, p.tiLvl, p.tiSpec, p.iColorF, p.iColorB
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
		,		@f100		float

	set	nocount	on

	select	@f100=	100

	exec	dbo.prRpt_XltDtEvRng	@dFrom, @dUpto, @tFrom, @tUpto, @tiShift, @iFrom out, @iUpto out

	set	nocount	off

	if	@tiDvc = 0xFF
		if	@tiShift = 0xFF
			select	idCall, lCount, siIdx, tiSpec
				,	case when tiSpec between 7 and 9	then sCall + ' †' else sCall end		as	sCall
				,	case when tiSpec between 7 and 9	then null else tVoTrg end				as	tVoTrg,		tVoAvg, tVoMax, lVoNul, lVoOnT
				,	case when tiSpec between 7 and 9	then null else tStTrg end				as	tStTrg,		tStAvg, tStMax, lStNul, lStOnT
				,	case when tVoAvg is null	then null else lVoOnT*@f100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*@f100/(lCount-lStNul) end	as	fStOnT
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
				,	case when tVoAvg is null	then null else lVoOnT*@f100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*@f100/(lCount-lStNul) end	as	fStOnT
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
				,	case when tVoAvg is null	then null else lVoOnT*@f100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*@f100/(lCount-lStNul) end	as	fStOnT
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
				,	case when tVoAvg is null	then null else lVoOnT*@f100/(lCount-lVoNul) end	as	fVoOnT
				,	case when tStAvg is null	then null else lStOnT*@f100/(lCount-lStNul) end	as	fStOnT
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
--	7.06.7649	+ h.dtCreated, h.dtUpdated
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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
				select	h.idUnit, u.sUnit, a.idShift, h.sShift, h.tiIdx as tiShift, h.tBeg, h.tEnd, h.idUser,	h.dtCreated as dtCre, h.dtUpdated as dtUpd
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



begin tran
	if	not	exists	( select 1 from tb_Version where siBuild = 7649 )
		insert	dbo.tb_Version ( idVersion, siBuild, dtCreated, dtInstall, sVersion )
			values	( 706,	7649, getdate( ), getdate( ),	'' )

	update	tb_Version	set	dtInstall=	getdate( ),	dtCreated=	'2020-12-10',	sVersion =	'*798?cs, *7980ns, *7983ls, *798?rh'
		where	siBuild = 7649

	update	tb_Module	set	 dtStart =	getdate( ),	sVersion =	'7.6.7649'
		where	idModule = 1

	exec	dbo.pr_Log_Ins	61, null, null, 'Mod_Upg( 001::J7983db, v=7.06.7649 )'
commit
go

checkpoint
go

use [master]
go