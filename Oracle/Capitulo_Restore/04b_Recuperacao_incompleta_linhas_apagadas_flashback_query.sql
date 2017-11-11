-- veja a data/hora atual o resultado de um select na tabela soe.customers e apague-a em seguida:
SQL>    sqlplus / as sysdba
SQL>    select to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') FROM DUAL;  -- anote essa data/hora
SQL>    select count(1) from soe.card_details;   -- anote a qtde de linhas totais
SQL>    delete from hr.job_history where rownum < 5;
SQ>     COMMIT;
SQL>    select count(1) from hr.job_history;  -- aqui tem que retornar menos 1000 linhas em relacao a consulta antes do delete

-- identificando as linhas deletadas previamente com FLASHBACK VERSIONS QUERY:
SQL>    SELECT        employee_id,
                      to_char(VERSIONS_STARTTIME, 'dd/mm/yyyy hh24:mi:ss') as v_start,
                      to_char(VERSIONS_ENDTIME, 'dd/mm/yyyy hh24:mi:ss') as v_end,          
                      VERSIONS_OPERATION as v_op,                 
                      VERSIONS_ENDSCN as v_scn
        FROM          hr.job_history
                      VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE
        WHERE         VERSIONS_OPERATION = 'D'
        ORDER  BY     VERSIONS_ENDTIME;
     
-- recuperando as linhas apagadas anteriormente:
SQL>    INSERT INTO   hr.job_history
        SELECT        *
        FROM          hr.job_history
                      VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE
        WHERE         VERSIONS_OPERATION = 'D'
        ORDER  BY     VERSIONS_ENDTIME;
        COMMIT;

-- veja se a qtde de linhas totais esta igual ao valor anotado inicialmente
SQL>    select count(1) from hr.job_history;
