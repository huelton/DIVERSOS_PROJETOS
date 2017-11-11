-- Consultando tablespaces:
SQL> select * from dba_tablespaces;

-- backupeando tablespace USERS:
RMAN>  BACKUP TABLESPACE USERS;

-- backupeando tablespaces USERS e SOE:
RMAN>  BACKUP TABLESPACE USERS, SOE;

-- backupeando tablespaces SYSTEM e UNDOTBS1:
RMAN>  BACKUP TABLESPACE SYSTEM, UNDOTBS1;

-- Tente executar o comando abaixo e veja o que acontece:
RMAN>  BACKUP TABLESPACE TEMP;
