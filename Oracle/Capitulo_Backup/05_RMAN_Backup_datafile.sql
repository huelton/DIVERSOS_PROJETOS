-- Consultando datafiles:
SQL>    select * from dba_data_files;

-- se o autobackup do controlfile estiver desligado, ao backuper datafile 1, o CF + Spfile sao backupeados tambem
RMAN>   BACKUP DATAFILE 1;

-- backupeando um datafile junto com o atual controlfile:
RMAN>   BACKUP DATAFILE 2 INCLUDE CURRENT CONTROLFILE;

-- backupeando mais de 1 datafile junto com o atual controlfile:
RMAN>   BACKUP DATAFILE 2, 3;