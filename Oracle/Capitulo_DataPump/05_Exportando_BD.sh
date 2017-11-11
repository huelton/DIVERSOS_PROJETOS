-- tente fazer um export FULL com o usuario HR e veja o erro de falta de privilegios:
$ expdp hr/hr FULL=YES DUMPFILE=orclfs_full.dmp DIRECTORY=DP_DIR

-- conectado com SYS conceda os privilegios abaixo para o usuario HR:
sql> GRANT DATAPUMP_EXP_FULL_DATABASE TO HR;

-- conectado com HR faca um export FULL do BD:
$ expdp hr/hr FULL=YES DUMPFILE=DP_DIR:orclfs_full.dmp LOGFILE=DP_DIR:orclfs_full.log


-- **** EXPORT FULL COM PARALELISMO ***********************************************************************************
-- conectado com SYS crie um novo diretorio e atribua privilegios de leitura/gravacao neste diretorio para o usuario HR:
sql> CREATE DIRECTORY DP_DIR_2 AS '/tmp';
sql> GRANT READ, WRITE ON DIRECTORY DP_DIR_2 TO HR;

-- conectado com HR faca um export FULL do BD utilizando paralelismo com gravacao de arquivos de 200 MB cada em 2 diretorios
$ expdp hr/hr FULL=YES DUMPFILE=DP_DIR:orclfs_full1_%U.dmp DP_DIR_2:orclfs_full2_%U.dmp FILESIZE=20MB PARALLEL=3 LOGFILE=DP_DIR:orclfs_full.log JOB_NAME=exp_full_par REUSE_DUMPFILES=YES
-- ********************************************************************************************************************