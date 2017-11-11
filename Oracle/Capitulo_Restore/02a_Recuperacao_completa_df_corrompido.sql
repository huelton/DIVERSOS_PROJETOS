-- veja o retorno do comando abaixo, anote o file_id e execute o resultado da coluna COMANDO para apagar o datafile do tablespace users:
SQL>    select file_id, 'rm ' || file_name as comando from dba_data_files where tablespace_name = 'USERS';

-- execute o comando abaixo para ver existe algum problema no BD:
RMAN>   VALIDATE DATABASE;

-- recuperando o datafile perdido:
RMAN>   RUN
        {
          SQL 'alter database datafile 4 offline';
          RESTORE datafile 4;  
          RECOVER datafile 4;
          SQL 'alter database datafile 4 online';
        }

-- execute o comando abaixo e veja se o problema foi solucionado:
RMAN>   VALIDATE DATABASE;        
        


