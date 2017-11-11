-- exportando schema HR sem necessidade de especificar parametro SCHEMAS, pois export de schema eh o default:
$ expdp hr/hr DIRECTORY=DP_DIR DUMPFILE=hr_schema.dmp LOGFILE=hr_schema.log

-- exportando schema, sobrescrevendo arquivo dump ja existente e com dados "consistentes":
$ expdp hr/hr SCHEMAS=HR DIRECTORY=DP_DIR DUMPFILE=hr_schema.dmp LOGFILE=hr_schema.log REUSE_DUMPFILES=YES FLASHBACK_TIME=SYSTIMESTAMP

-- exportando schema HR, somente metadados
$ expdp hr/hr DIRECTORY=DP_DIR DUMPFILE=hr_tabelas_metadados.dmp CONTENT=METADATA_ONLY LOGFILE=hr_tabelas_metadados.log

-- exportando schema HR usando um arquivo de parametros, somente dados, excluindo tabelas e com filtro/ordenacao de linhas
-- antes de executar o comando abaixo copie o arquivo dp_file.par para a pasta em que esta sendo executado o comando
$ expdp hr/hr PARFILE=dp_file.par
