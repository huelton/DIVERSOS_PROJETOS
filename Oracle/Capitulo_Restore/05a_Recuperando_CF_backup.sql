-- verifique no RMAN se vc tem algum backup do controlfile e anote o nome do mais recente
RMAN>   BACKUP CURRENT CONTROLFILE;
RMAN>   LIST BACKUP OF CONTROLFILE;
RMAN>   exit

-- verifique se o arquivo do ultimo backup do retorno do comando acima existe no SO, substituindo xxx pelo nome completo do arquivo:
$       ll xxx

-- apague os control files existentes
$       sqlplus / as sysdba
sql>    SHOW PARAMETER CONTROL_FILES
$ rm    caminho_nome_cf1 caminho_nome_cf2

-- localize o arquivo caminho completo do arquivo system01.dbf para preencher o proximo comando:
$ find / -name system01.dbf 2>/dev/null

-- encontre o DBID no system01.dbf:
$ strings caminho_nome_system | grep ", MAXVALUE" | sort | uniq

-- tire o BD do ar
$ sqlplus / as sysdba
sql> SHUTDOWN ABORT
sql> STARTUP NOMOUNT
sql> exit

$     rman target / 

-- entre no rman e configure o DBID com o resultado do comando strings:
RMAN> SET DBID=xxxxxx

-- restaure o backup do controlfile de um arquivo de backup conhecido:
RMAN> restore controlfile from 'caminho_nome_arquivo'

RMAN> ALTER DATABASE MOUNT;
RMAN> ALTER DATABASE OPEN;

-- se voce nao conseguir abrir o BD, faca um RECOVER e depois abra-o ressetando os logs
RMAN> RECOVER DATABASE;
RMAN> ALTER DATABASE OPEN RESETLOGS;

-- finalmente confira se os controlfiles foram realmente recuperados:
$ ll caminho_nome_cf1
$ ll caminho_nome_cf2