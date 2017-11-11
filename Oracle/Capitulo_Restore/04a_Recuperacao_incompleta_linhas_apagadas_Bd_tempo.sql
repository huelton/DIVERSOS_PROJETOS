--- ***** EXECUTE NOVAMENTE O SCRIPT "01_PreReqs_Efetuando_manutencao_e_backup.sql" ANTES DE PROSSEGUIR  *****

-- veja a data/hora atual o resultado de um select na tabela soe.customers e apague-a em seguida:
SQL>    sqlplus / as sysdba
SQL>    select to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') FROM DUAL;  -- anote essa data/hora
SQL>    select count(1) from hr.job_history;
SQL>    delete from hr.job_history where rownum < 5;
SQL>    select count(1) from hr.job_history;  -- aqui tem que retornar menos 1000 linhas
SQL>    shutdown immediate;
SQL>    startup mount;
SQL>    exit;

-- recupere a tabela preenchendo a data/hora com o valor recuperado no passo anterior: 
$       rman target / catalog /
RMAN>   run {
            set until time "TO_DATE('xx/xx/xxxx xx:xx:xx','dd/mm/yyyy hh24:mi:ss')";            
            restore database;
            recover database;
            alter database open resetlogs;
            }
RMAN>   exit
            
-- confira se os dados da tabela foram recuperados:            
SQL>    sqlplus / as sysdba
SQL>    select count(1) from hr.job_history;

