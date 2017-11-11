$ rman target / catalog rman/rman

-- Backup completo (em estrategia incremental):
RMAN> BACKUP INCREMENTAL LEVEL 0 database;

-- Backup completo (em estrategia incremental) com TAG:
RMAN> BACKUP INCREMENTAL LEVEL 0 database TAG 'full_semanal';

-- verificando os backups realizados:
RMAN> LIST BACKUP;

-- criando archival backups mensais:
RMAN> BACKUP INCREMENTAL LEVEL 0 database TAG 'bkp_mensal' KEEP UNTIL TIME 'SYSDATE+31';

