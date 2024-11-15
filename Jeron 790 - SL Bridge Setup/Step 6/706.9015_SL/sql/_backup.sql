-- ========================================================
--	Database backup script for Microsoft SQL Server 2005+
--	Author:	Dmitriy Khazak		Project: 7983
--
--	Expected arguments:
--		{0} - DB name
--		{1} - full path to .bak file
--		{2} - backup description (name)
--
--	6.03	2012-Feb-13	DK	- args [3] and up
--	6.03	2011-Dec-20	DK	+ arg [3]
--	6.01	2011-Sep-20	DK	+ arg [4]
--	3.01	2011-Jul-18	DK
-- ========================================================

use [master]
go

--	----------------------------------------------------------------------------
--	backup db
--	[128,tbEvent]	can't use in [master]'s context!!
if exists( select 1 from master.sys.databases where [name]='{0}' )
	backup database [{0}] to disk= '{1}'
		with name= '{2}', noformat, init, skip, norewind, nounload, stats= 10
go
