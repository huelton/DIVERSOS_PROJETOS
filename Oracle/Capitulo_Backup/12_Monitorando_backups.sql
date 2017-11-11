-- Verificar sessoes rman
SELECT  s.sid, p.spid, s.client_info
FROM    v$process p, v$session s
WHERE   p.addr = s.paddr
AND     CLIENT_INFO LIKE 'rman%';

-- efetuando monitoramento de backups em disco:
SELECT SID, SERIAL#, CONTEXT, SOFAR, TOTALWORK,
       ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM   V$SESSION_LONGOPS
WHERE  OPNAME LIKE 'RMAN%'
AND    OPNAME NOT LIKE '%aggregate%'
AND    TOTALWORK != 0
AND    SOFAR <> TOTALWORK;

-- efetuando monitoramento de backups direto em fita:
SELECT      p.SPID, EVENT, SECONDS_IN_WAIT AS SEC_WAIT, 
            sw.STATE, CLIENT_INFO
FROM        V$SESSION_WAIT sw
JOIN        V$SESSION s
    ON      s.SID=sw.SID       
JOIN        V$PROCESS p
    ON      s.PADDR=p.ADDR
WHERE sw.EVENT LIKE 's%bt%';       

-- verificando trabalho já efetuado e MB/s:
select  s.client_info,
        l.sid,
        l.serial#,
        l.sofar,
        l.totalwork,
        round (l.sofar / l.totalwork*100,2) "%_COMPLETE",
        aio.MB_PER_S,
        aio.LONG_WAIT_PCT
from    v$session_longops l
join    v$session s
  on    s.sid = l.sid
  and   s.serial# = l.serial#
join    (select sid,
                serial,
                100* sum (long_waits) / sum (io_count) as "LONG_WAIT_PCT",
                sum (effective_bytes_per_second)/1024/1024 as "MB_PER_S"
                from v$backup_async_io
                group by sid, serial) aio
  on    aio.sid = s.sid  
  and   aio.serial = s.serial#
where   l.opname like 'RMAN%'
and     l.opname not like '%aggregate%'
and     l.totalwork != 0
and     l.sofar <> l.totalwork
and 

order by 1;

/*  - SOFAR:
        - IC: blocos que foram lidos
        - Backup input rows: blocos que foram lidos a partir dos arquivos sendo backupeados
        - Backup output rows: blocos que foram escritos nos backup pieces
        - Restores: blocos processados referentes aos arquivos que estao sendo restaurados
        - Proxy copies: qtde de arquivos sendo copiados    
    - SID: id da sessão correspondente ao canal do RMAN
    - SERIAL#: numero serial da sessao
    - OPNAME: descrição da linha. Exemplo: RMAN: datafile copy, RMAN: full datafile backup e RMAN: full datafile restore. "RMAN: aggregate input" e "RMAN: aggregate output" são as unicas linhas agregadas
    - CONTEXT: valor 2 se for backup output rows ou 1 para outras linhas exceto proxy copy (que nao atualiza essa coluna)
    - TOTALWORK:
        - IC: total e blocos no arquivo
        - Backup input rows: total de blocos a serem lidos de todos os arquivos processados neste job
        - Backup output rows: 0 porque RMAN nao sabe quantos blocos que ele ira escrever em qq backup piece
        - Restores: qtde total de blocos em todos os arquivos restaurados
        - Proxy copies: total de arquivos sendo copiados
*/

-- ver origem de gargalos do backup ou restore e detalhes do progresso do job (dados ficam em memoria ate dar shutdown na instancia):
SELECT * FROM V$BACKUP_SYNC_IO;
-- ou
SELECT * FROM V$BACKUP_ASYNC_IO;
-- O caminho mais facil para identificar gargalos é descobrir o datafile que tem o maior ratio de LONG_WAITS divido por IO_COUNT, como por exemplo, executando o seguinte SQL:
SELECT   LONG_WAITS/IO_COUNT, FILENAME
FROM     V$BACKUP_ASYNC_IO
WHERE    LONG_WAITS/IO_COUNT > 0
ORDER BY LONG_WAITS/IO_COUNT DESC;