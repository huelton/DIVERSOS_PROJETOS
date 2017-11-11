-- Passo 1: Verifique se o BD nao esta em modo archivelog:
SELECT LOG_MODE FROM V$DATABASE; 
-- Obs.: Se o retorno for igual a NOARCHIVELOG execute os proximos passos, caso contrario o BD ja esta em modo archive log, neste caso, ignore os proximo passos.

-- Passo 2: Se o BD estiver aberto (online) configure o nome desejado para os arquivos de Archived Logs:
ALTER SYSTEM SET log_archive_format = '%d_%t_%s_%r.arc' SCOPE=SPFILE;
 /*
    Variaveis para usar no nome dos archives:
        %d = ID do BD
        %s = Numero sequencial do log
        %t = Numero da thread
        %r = ID de resetlogs: assegura que nomes unicos sejam criados junto a multiplas encarnacoes do BD

        Obs.: Existem mais variaveis % que podem ser utilizadas para definir o padrao de nomenclatura dos archive logs.
*/

-- Passo 3: Configure o caminho (local) onde os Archived Logs serao gravados:
$  mkdir /orabkp/arc
$  mkdir /orabkp/bkp
SQL> ALTER SYSTEM SET LOG_ARCHIVE_DEST_1 = 'LOCATION=/orabkp/arc' SCOPE=BOTH;
-- Obs.: Substitua /disk1/archive pelo nome do disco e diretorio desejado para gravar os archive logs.
 
-- Passo 4: Reinicie o BD em modo exclusivo:
SHUTDOWN IMMEDIATE;
STARTUP MOUNT EXCLUSIVE;

-- Passo 5: Altere a configuracao do BD para o modo Archived Log:
ALTER DATABASE ARCHIVELOG;
             
-- Passo 6: Inicialize a geracao de Archive Logs:
ARCHIVE LOG START;
  
-- Passo 7: Abra o BD:
ALTER DATABASE OPEN;
   
-- Passo 8: Verifique se agora o BD esta em modo archivelog:   
SELECT LOG_MODE FROM V$DATABASE;
