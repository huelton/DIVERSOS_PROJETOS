-- conectado com SYS conceda os privilegios abaixo para o usuario HR:
sql> GRANT DATAPUMP_IMP_FULL_DATABASE TO HR;

-- Conectado com HR faca um import FULL do BD:
$ impdp hr/hr FULL=YES DIRECTORY=DP_DIR DUMPFILE=orclfs_full.dmp LOGFILE=imp_orclfs.dmp