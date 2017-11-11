-- Consultando archived logs:
SQL>    select * from v$archived_log;

-- backupeando todos os archived logs:
RMAN>   BACKUP ARCHIVELOG ALL;

-- backupeando todos os archived logs e deletando-os em seguida:
RMAN>   BACKUP ARCHIVELOG ALL DELETE ALL INPUT;

-- backupeando os archived logs de uma determinada faixa de data/horario:
RMAN>   BACKUP ARCHIVELOG FROM TIME  'SYSDATE-1' UNTIL TIME 'SYSDATE';
  
-- backupeando os archived logs de uma determinada faixa de SEQUENCE:  
RMAN>   BACKUP ARCHIVELOG FROM  SEQUENCE X UNTIL SEQUENCE Y;