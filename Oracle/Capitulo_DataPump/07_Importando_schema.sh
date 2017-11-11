-- ***** 0: PRE-REQS PARA EXECUTAR CADA SCRIPT ABAIXO
sql> DROP USER HR CASCADE;
sql> CREATE USER HR IDENTIFIED BY HR;
sql> GRANT CONNECT, RESOURCE TO HR;
sql> GRANT UNLIMITED TABLESPACE TO HR;
sql> GRANT CREATE JOB TO HR;
sql> GRANT CREATE EXTERNAL JOB TO HR;
sql> GRANT EXECUTE ANY PROGRAM TO HR;
sql> GRANT AQ_ADMINISTRATOR_ROLE TO HR;
sql> GRANT READ, WRITE ON DIRECTORY DP_DIR TO HR;
-- *****************************************************************************************

-- ***** 1: importando somente metadados schema HR ****************
-- conectado com SYS APAGUE o schema HR e seus objetos executando os comando do bloco 0

-- importando metadados do dump gerado no script 4 sem gerar arquivo de log:
$ impdp hr/hr DUMPFILE=DP_DIR:hr_schema.dmp CONTENT=METADATA_ONLY NOLOGFILE=YES

-- verifique se o schema foi recuperado e se os objetos estao vazios:
sql> SELECT * FROM DBA_TABLES WHERE OWNER = 'HR';
sql> SELECT * FROM HR.EMPLOYEES;
-- *********************************************************************************************************


-- ***** 2: importando tudo que esta no dump ***********************************************
-- conectado com SYS APAGUE o schema HR e seus objetos executando os comando do bloco 0

-- importando tudo que foi gerando do dump do script 4:
$ impdp system/oracle DIRECTORY=DP_DIR DUMPFILE=hr_schema.dmp LOGFILE=import_hr_schema.log

 -- verifique se o schema foi recuperado:
sql> SELECT * FROM DBA_TABLES WHERE OWNER = 'HR';
sql> SELECT * FROM HR.EMPLOYEES;
-- *****************************************************************************************


-- ***** 3: importando tudo que esta no dump (mas sem gerar log) ****************************
-- conectado com SYS APAGUE o schema HR e seus objetos executando os comando do bloco 0

-- importando tudo que foi gerado no dump do script 4:
$ impdp hr/hr DIRECTORY=DP_DIR DUMPFILE=hr_schema.dmp TRANSFORM=DISABLE_ARCHIVE_LOGGING:Y LOGFILE=import_hr_schema.log

-- verifique se o schema foi recuperado:
sql> SELECT * FROM DBA_TABLES WHERE OWNER = 'HR';
sql> SELECT * FROM HR.EMPLOYEES;

-- compare o tempo de importacao deste import e do import anterior analisando os logs deles
-- *****************************************************************************************


