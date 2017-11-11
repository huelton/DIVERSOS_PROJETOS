-- ***** 1: importando tabela JH_CTAS remapeando-a para JH_CTAS_TEMP utilizando dump gerado no script 2 ******
$ impdp hr/hr DUMPFILE=DP_DIR:hr_jhctas.dmp REMAP_TABLE=JH_CTAS:JH_CTAS_TEMP NOLOGFILE=YES

-- verifique se a tabela foi criada:
sql> SELECT * FROM DBA_TABLES WHERE OWNER = 'HR' AND TABLE_NAME IN ('JH_CTAS_TEMP');
sql> SELECT COUNT(1) FROM HR.JH_CTAS_TEMP;
-- ***********************************************************************************************************

-- ***** 2: importando tabela limpando antes linhas existentes e filtrando novas linhas ****************************
$ impdp hr/hr DUMPFILE=DP_DIR:hr_jhctas.dmp REMAP_TABLE=JH_CTAS:JH_CTAS_TEMP QUERY=JH_CTAS:\"WHERE EMPLOYEE_ID=101\" TABLE_EXISTS_ACTION=TRUNCATE NOLOGFILE=YES

-- verifique se a tabela JH_CTAS_TEMP tem somente as linhas filtradas:
sql> SELECT * FROM HR.JH_CTAS_TEMP;
-- *****************************************************************************************
