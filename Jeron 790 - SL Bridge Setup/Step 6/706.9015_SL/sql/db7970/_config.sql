-- ========================================================
--	Database config script for Microsoft SQL Server 2005+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	6.04	2012-Apr-17	DK
--	6.06
--		2012-Sep-26		+ tb_Module[1] update
--	7.06
--		2015-Mar-11		.5548
--						* optimized layout, added explicit PK names
--		2015-May-12		.5610
--						+ tbTlkMsg.iRepeatCancel
--						* tbTlkRooms.idRoom:	smallint -> int
-- ========================================================

use [{0}]
go

update	dbo.tb_OptSys	set	iValue= 255		-- remove all events
	where	idOption = 7
go
update	dbo.tb_Module	set	sDesc= '7970 Database [' + db_name( ) + ']'
	where	idModule = 1
go


set	xact_abort			on
set ansi_null_dflt_on	on
set nocount				on
set quoted_identifier	on
go

--	============================================================================
print	char(10) + '###	Dropping objects..'
--	(must go in reverse order)
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

--	============================================================================
print	char(10) + '###	Creating tables..'
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


checkpoint
go

use [master]
go
--	============================================================================
print	char(10) + '###	Complete.'
go