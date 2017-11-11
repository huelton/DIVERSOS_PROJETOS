-- listar backup sets:
LIST BACKUP;

-- listar image copies:
LIST COPY;

-- listar encarnacoes dos BDs:
LIST INCARNATION;

-- listar encarnacoes de um BD especifico:
LIST INCARNATION OF DATABASE ORCL;

-- listar scripts salvos no catálogo:
LIST SCRIPT NAMES;

-- listar backups expirados
LIST EXPIRED BACKUP;

-- Ver resumo de todos os backups:
LIST BACKUP SUMMARY;

-- Ver detalhes de um backupset especifico:
LIST BACKUPSET xxx; 

-- Ver detalhes de backupsets com uma tag especifica:
LIST BACKUPSET TAG 'xxx'

-- listar BSs que contem um determinado tablespace:
LIST BACKUP OF TABLESPACE USERS;

-- listar BSs que contem um determinado datafile:
LIST BACKUP OF DATAFILE 2;

-- ver informacoes sobre backups elegiveis para recuperacao (se um bkp incr nao tem um bkp pai, ele nao é exibido):
LIST RECOVERABLE BACKUP OF DATABASE;

-- listar archived redo logs em disco (nao necessariamente backupeados):
LIST ARCHIVELOG ALL;

-- listar backups de archives:
LIST BACKUP OF ARCHIVELOG ALL;

-- listar backups expirados de archives:
LIST EXPIRED BACKUP OF ARCHIVELOG ALL;

-- listar backups de control files:
LIST BACKUP OF CONTROLFILE;

-- listar resumo dos backups de control file:
LIST BACKUP OF CONTROLFILE SUMMARY;
