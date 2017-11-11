-- Consultando control files:
SQL>    select * from v$controlfile;

-- backupeando o atual controlfile (e junto o SPFILE):
RMAN>   BACKUP CURRENT CONTROLFILE;

-- backupeando somente o SPFILE:
RMAN>   BACKUP SPFILE;
