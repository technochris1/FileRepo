-- ========================================================
--	Database config script for Microsoft SQL Server 2005+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Arguments:
--		{0} - DB name
--
--	6.04
--		2012-Apr-17	
--	6.05
--		2012-May-23		+ CallDetailsTbl, vuMapDisplay, vwMapUnitDisplay
--		2012-Aug-07		- CallDetailsTbl, vuMapDisplay, vwMapUnitDisplay - no longer needed
--		2012-Aug-13		+ [jp790db] objects (tables, sprocs)
--		2012-Aug-14		+ [jp7980user]
--		2012-Sep-18		* prStaffAssnDef_Exp: added UnitID ?= 0
--	6.06
--		2012-Sep-19		.4645 - 1st official release
--						* prStaff_Exp: RN <-> Aide (4 vs. 1)
--	6.07
--		2012-Oct-10		.4666
--						* prDefLoc_SetLvl: populating Units
--	7.00
--		2012-Dec-05		.4722
--						- prDevice_UpdRoomBeds, + prDevice_UpdRoomBeds7980
--						+ tb_OptionSys[8]
--	7.01
--		2012-Dec-13		.4730
--						* prDevice_UpdRoomBeds7980: fix for rooms without beds
--	7.03
--		2013-Apr-15		.4853
--						* prDevice_UpdRoomBeds7980: fix for room renames
--		2013-Apr-24		.4862
--						* permissions adjust for db7980 (Jeremy's tables)
--						* db7980::prDefLoc_SetLvl
--		2013-May-24		.4892
--						* dbo.Staff:	+ .bLoggedIn
--	7.04
--		2013-May-30		.4898
--						* tb_OptionSys -> tb_OptSys		(pr_OptionSys_GetSmtp -> pr_OptSys_GetSmtp, prStaff_sStaff_Upd, prDevice_InsUpd, prDevice_GetIns,
--		2013-Jun-17		.4916
--						* StaffToPatientAssn:	+ .idRoom
--							* prDevice_UpdRoomBeds7980:	fix for renamed rooms/dial#s
--						* prDevice_UpdRoomBeds7980
--						* prCall_Imp:	tbDefBed -> tbCfgBed
--						* [ArchitecturalConfig], [BedDefinition] -> views on top of tbCfgLoc, tbCfgBed
--		2013-Jun-24		.4923
--						* [Units] -> view on top of tbUnit
--		2013-Jul-17		.4946
--						- view Staffs
--						* trigger Staff.UpdateStaffD2S (comment out ref to Units)
--		2013-Jul-23		.4952
--						+ prStaff_Imp, * UpdateStaffD2S, * InsertStaffD2S
--	7.05
--		2013-Aug-28		.4988
--						* prStaff_Imp
--		2013-Oct-07		.5028
--						* removed all definitions (now in <_schema.sql>) - only configuration is left
--	7.06
--		2015-May-20		.5618
--						* tb_OptSys[7] default: 0 -> 30, semantics reversed

-- ========================================================

use [{0}]
go


--	============================================================================
print	char(10) + '###	Configuring the DB..'
go

update	dbo.tb_Module	set	sDesc =		'7980 Database [' + db_name( ) + ']'
	where	idModule = 1
go
update	dbo.tb_OptSys	set	iValue =	0		-- remove all events
	where	idOption = 7
go


use [master]
go
