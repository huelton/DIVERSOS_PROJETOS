-- veja o retorno do comando abaixo, anote o file_id, o tablespace_name e execute-o o resultado da coluna COMANDO para apagar o datafile do tablespace users:
SQL>    select file_id, TABLESPACE_NAME, 'rm ' || file_name as comando from dba_data_files where tablespace_name = 'USERS';

-- execute o comando abaixo para ver existe algum problema no BD:
RMAN>   VALIDATE DATABASE;

-- recupere o BD com o Data Recovery Advisor (DRA): http://www.fabioprado.net/2013/07/recuperando-se-de-falhas-com-o-data.html
RMAN>   list failure;                   -- mostra a falha
RMAN>   advise failure;                 -- analisa a falha
RMAN>   repair failure preview;         -- visualiza o script de reparo
RMAN>   repair failure;                 -- executa o script de reparo

-- execute o comando abaixo e veja se o problema foi solucionado:
RMAN>   VALIDATE DATABASE;     
