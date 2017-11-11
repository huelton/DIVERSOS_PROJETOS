duplicate database to orclcopy backup location '/home/oracle/app/oracle/bk_dupli'
pfile = '/home/oracle/app/oracle/product/11.2.0/dbs/initorclcopy.ora'
db_file_name_convert (
'/home/oracle/app/oracle/oradata/orcl', '/home/oracle/app/oracle/oradata/orclcopy',
'orcl', 'orclcopy')
logfile
group 1 (
'/home/oracle/app/oracle/oradata/orclcopy/redo01.log',
'/home/oracle/app/oracle/oradata/orclcopy/redo02.log',
'/home/oracle/app/oracle/oradata/orclcopy/redo03.log'
) size 5M;



duplicate target database to orclcopy pfile=/home/oracle/app/oracle/product/11.2.0/dbs/initorclcopy.ora logfile '/home/oracle/app/oracle/oradata/orclcopy/redo01.log' size 100M, '/home/oracle/app/oracle/oradata/orclcopy/redo02.log' size 100M, '/home/oracle/app/oracle/oradata/orclcopy/redo03.log' size 100M;




Recovery Manager complete.
[oracle@fabioprado oradata]$ rman target sys/oracle auxiliary sys/oracle@orclcopy

Recovery Manager: Release 11.2.0.1.0 - Production on Mon Feb 27 17:22:23 2017

Copyright (c) 1982, 2009, Oracle and/or its affiliates.  All rights reserved.

connected to target database: ORCL (DBID=1344731332)
connected to auxiliary database: ORCLCOPY (not mounted)

RMAN> duplicate database to orclcopy backup location '/home/oracle/app/oracle/bk_dupli'
pfile = '/home/oracle/app/oracle/product/11.2.0/dbs/initorclcopy.ora'
db_file_name_convert (
'/home/oracle/app/oracle/oradata/orcl', '/home/oracle/app/oracle/oradata/orclcopy',
'orcl', 'orclcopy')
logfile
group 1 (
'/home/oracle/app/oracle/oradata/orclcopy/redo01.log',
'/home/oracle/app/oracle/oradata/orclcopy/redo02.log',
'/home/oracle/app/oracle/oradata/orclcopy/redo03.log'
) size 5M;2> 3> 4> 5> 6> 7> 8> 9> 10> 11> 

Starting Duplicate Db at 27-FEB-17
using target database control file instead of recovery catalog
allocated channel: ORA_AUX_DISK_1
channel ORA_AUX_DISK_1: SID=129 device type=DISK

contents of Memory Script:
{
   sql clone "create spfile from memory";
}
executing Memory Script

sql statement: create spfile from memory

contents of Memory Script:
{
   shutdown clone immediate;
   startup clone nomount;
}
executing Memory Script

Oracle instance shut down

connected to auxiliary database (not started)
Oracle instance started

Total System Global Area    1068937216 bytes

Fixed Size                     2220200 bytes
Variable Size                482348888 bytes
Database Buffers             578813952 bytes
Redo Buffers                   5554176 bytes

contents of Memory Script:
{
   sql clone "alter system set  db_name = 
 ''ORCL'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   sql clone "alter system set  db_unique_name = 
 ''ORCLCOPY'' comment=
 ''Modified by RMAN duplicate'' scope=spfile";
   shutdown clone immediate;
   startup clone force nomount
   restore clone primary controlfile;
   alter clone database mount;
}
executing Memory Script

sql statement: alter system set  db_name =  ''ORCL'' comment= ''Modified by RMAN duplicate'' scope=spfile

sql statement: alter system set  db_unique_name =  ''ORCLCOPY'' comment= ''Modified by RMAN duplicate'' scope=spfile

Oracle instance shut down

Oracle instance started

Total System Global Area    1068937216 bytes

Fixed Size                     2220200 bytes
Variable Size                482348888 bytes
Database Buffers             578813952 bytes
Redo Buffers                   5554176 bytes

Starting restore at 27-FEB-17
allocated channel: ORA_AUX_DISK_1
channel ORA_AUX_DISK_1: SID=63 device type=DISK

RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03002: failure of Duplicate Db command at 02/27/2017 17:23:17
RMAN-03015: error occurred in stored script Memory Script
RMAN-06026: some targets not found - aborting restore
RMAN-06024: no backup or copy of the control file found to restore

RMAN> exit



!cp -a /home/oracle/app/oracle/product/11.2.0/dbs/soe.dbf /home/oracle/app/oracle/oradata/orcl/soe.dbf

alter database rename file '/home/oracle/app/oracle/product/11.2.0/dbs/soe.dbf' to '/home/oracle/app/oracle/oradata/orcl/soe.dbf';

