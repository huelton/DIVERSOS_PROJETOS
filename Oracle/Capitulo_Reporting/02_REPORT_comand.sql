-- relata quais datafiles precisam de backup, conforme politica de retencao especificada:
REPORT NEED BACKUP;

-- relata quais datafiles precisam de mais que 1 backup incremental durante a recuperacao:
REPORT NEED BACKUP INCREMENTAL 1;

-- relata datafiles que precisam de backup porque algum objeto sofreu operacoes do tipo irrecuperaveis (tais como NOLOGGING ou direct-path:
REPORT UNRECOVERABLE;

-- relata o nome de todos os datafiles (permanentes e temporarios) e tablespaces atuais do BD:
REPORT SCHEMA;

-- relata o nome de todos os datafiles (permanentes e temporarios) e tablespaces do BD em um determinado ponto no tempo:
REPORT SCHEMA AT TIME 'SYSDATE-14';

-- relata backups Full, data file copies e de archived redo logs que podem ser deletados porque nao sao mais necessarios:
REPORT OBSOLETE;

-- ****** para testar o comando REPORT NEED BACKUP execute os comandos abaixo:
SQL>    CREATE TABLESPACE TESTE DATAFILE '/home/oracle/app/oracle/oradata/orcl/teste.dbf' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED;
RMAN>   REPORT NEED BACKUP;
RMAN>   BACKUP TABLESPACE TESTE;
RMAN>   REPORT NEED BACKUP;






