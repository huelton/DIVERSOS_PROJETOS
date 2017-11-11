-- atualizar status dos backups:
RMAN> CROSSCHECK BACKUP;
RMAN> CROSSCHECK COPY;

-- atualizar status dos archived logs:
RMAN> CROSSCHECK ARCHIVELOG ALL;

-- verificando backups expirados:
RMAN> LIST EXPIRED BACKUP;

-- verificando backups obsoletos:
RMAN> REPORT OBSOLETE;

-- apagando backups expirados:
RMAN> DELETE NOPROMPT EXPIRED BACKUP;

-- apagando backups obsoletos:
RMAN> DELETE NOPROMPT OBSOLETE;

-- apagando backups de archived logs:
RMAN> DELETE BACKUP OF ARCHIVELOG ALL;

-- adicionando backups nao catalogados:
RMAN> CATALOG START WITH '/orabkp/bkp2'

-- alterando status do backup para indisponivel:
RMAN> CHANGE BACKUPSET 3 UNAVAILABLE;



