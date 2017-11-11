-- gerar somente estimativa do tamanho do dump das tabelas EMPLOYEES + DEPARTMENTS:
$ expdp hr/hr DIRECTORY=DP_DIR ESTIMATE_ONLY=YES TABLES=employees,departments LOGFILE=hr_tables_estimate.log

-- executar o comando abaixo para exportar tabelas EMPLOYEES e DEPARTMENTS, sem gerar arquivo de log:
$ expdp hr/hr TABLES=employees,departments DUMPFILE=DP_DIR:hr_tables_nologging.dmp NOLOGFILE=YES

-- exportando tabela para posterior exercicio de import:
sql>    CREATE TABLE HR.JH_CTAS AS SELECT * FROM HR.JOB_HISTORY;
$       expdp hr/hr TABLES=JH_CTAS DUMPFILE=DP_DIR:hr_jhctas.dmp NOLOGFILE=YES

