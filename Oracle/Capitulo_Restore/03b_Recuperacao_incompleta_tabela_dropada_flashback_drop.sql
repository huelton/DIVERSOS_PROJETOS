-- apagando a tabela
SQL>    sqlplus / as sysdba
SQL>    select count(1) from soe.order_items;
SQL>    drop table soe.order_items;
SQL>    select count(1) from soe.order_items;  -- erro "ORA-00942: table or view does not exist"

-- ver objeto na recyclebin (lixeira):
SQL>    SELECT * FROM DBA_RECYCLEBIN;

-- recuperando a tabela via flashback drop:
SQL>    FLASHBACK TABLE soe.order_items TO BEFORE DROP;

-- verificando se a tabela foi recuperada:
SQL>    select count(1) from soe.order_items;