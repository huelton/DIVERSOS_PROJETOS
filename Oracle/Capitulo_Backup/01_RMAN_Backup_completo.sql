$ rman target / catalog rman/rman

-- backup completo nao incremental:
RMAN> BACKUP DATABASE;

-- backup completo nao incremental com archived logs:
RMAN> BACKUP DATABASE PLUS ARCHIVELOG;

-- verificando o backup realizado:
RMAN> LIST BACKUP;
