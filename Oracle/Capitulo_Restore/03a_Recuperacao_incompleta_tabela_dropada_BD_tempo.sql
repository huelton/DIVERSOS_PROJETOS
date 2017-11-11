-- veja a data/hora atual o resultado de um select na tabela soe.customers e apague-a em seguida:
SQL>    sqlplus / as sysdba
SQL>    select to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') FROM DUAL;  -- anote essa data/hora
SQL>    select count(1) from soe.order_items;
SQL>    drop table soe.order_items;
SQL>    select count(1) from soe.order_items;  -- erro "ORA-00942: table or view does not exist"
SQL>    shutdown immediate;
SQL>    startup mount;
SQL>    exit;

-- recupere a tabela preenchendo a data/hora com o valor recuperado no passo anterior: 
$       rman target / 
RMAN>   run {
            set until time "TO_DATE('xx/xx/xxxx xx:xx:xx','dd/mm/yyyy hh24:mi:ss')";            
            restore database;
            recover database;
            alter database open resetlogs;
            }
RMAN>   exit
            
-- confira se a tabela foi recuperada:            
SQL>    sqlplus / as sysdba
SQL>    select count(1) from soe.order_items;



