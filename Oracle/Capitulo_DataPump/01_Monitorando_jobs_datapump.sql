--- ***** PREPARANDO O AMBIENTE PARA A GERACAO DOS DUMPS ************
-- criando diretorio para armazenar os dumps:
$ mkdir /orabkp/dumps

-- crie um diretorio no BD apontando para o diretorio /orabkp/dumps do SO:
sql> CREATE DIRECTORY DP_DIR AS '/orabkp/dumps';

-- atribua privilegios de leitura/escrita no diretorio DP_DIR para o usuario HR:
sql> GRANT READ, WRITE ON DIRECTORY DP_DIR TO HR;
--- *******************************************************************

-- verificar jobs do datapump:
sql> select * from dba_datapump_jobs;
sql> SELECT * FROM DBA_DATAPUMP_SESSIONS;

--   verificar % de execucao do job (se ele for um job longo):
sql>  select      sid, serial#, round(sofar/totalwork*100,2)  percent_completed
      from        v$session_longops
      where       opname like upper('&NOME_JOB%')
      and         sofar!= totalwork;