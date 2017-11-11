$ rman target / catalog rman/rman

-- Configurando exclusao dos tablespaces SOE e UNDOTBS1:
CONFIGURE EXCLUDE FOR TABLESPACE SOE;
CONFIGURE EXCLUDE FOR TABLESPACE UNDOTBS1;

-- backup completo:
RMAN> BACKUP AS COPY DATABASE;

-- backup de tablespace:
RMAN> BACKUP AS COPY TABLESPACE UNDOTBS1;

-- backup de datafile:
BACKUP AS COPY DATAFILE 2;

-- Ressetando configuracao de exclusao dos tablespaces SOE e UNDOTBS1:
CONFIGURE EXCLUDE FOR TABLESPACE SOE CLEAR;
CONFIGURE EXCLUDE FOR TABLESPACE UNDOTBS1 CLEAR;

-- verificando o backup realizado:
RMAN> LIST BACKUP;
