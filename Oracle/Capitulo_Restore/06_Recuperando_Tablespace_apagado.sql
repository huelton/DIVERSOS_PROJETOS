--- ***** EXECUTE NOVAMENTE O SCRIPT "01_PreReqs_Efetuando_manutencao_e_backup.sql" ANTES DE PROSSEGUIR  *****

-- veja a data/hora atual e apague em seguida o tablespace SOE:
SQL>    select to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') FROM DUAL;  -- anote essa data/hora
SQL>    select * from dba_tablespaces where tablespace_name = 'SOE';
SQL>    DROP TABLESPACE SOE INCLUDING CONTENTS AND DATAFILES;

$       rman target /

-- Obs.: Ao apagar o tablespace, a estrutura do BD e alterada e essas informacoes sao atualizadas no control file. 
--  Verificar se o tablespace apagado NAO aparece apos executar comando abaixo:
RMAN>   report schema;
  
-- Passo 4: Conectar-se no RMAN e restaurar control file para o tempo antes do tablespace ser apagado:
RMAN>   shutdown immediate;
        startup nomount;

  -- Restaurar control file anotado no passo 2 (substituir xxx pelo caminho/nome do arquivo de backup do control file do passo 2):
RMAN>   restore controlfile from '/oracle/bkp/cf_bkp_c-1463279594-20170215-04';
    
  -- Montar BD:
RMAN>   alter database mount;

  --	Verificar se tablespace apagado aparece novamente:
RMAN>   report schema;

-- Restaurar banco de dados para data/hora antes do tablespace ser apagado, substituindo xxx pela data/hora anotada anteriormente:
RMAN> run {
      set until time "TO_DATE('xx/xx/xxxx xx:xx:xx','dd/mm/yyyy hh24:mi:ss')";
      restore database;
      recover database;
      alter database open resetlogs;
        }
    
-- Verificar se o tablespace foi recuperado:
SQL>  select file_name, bytes from dba_data_files where tablespace_name='USERS';      