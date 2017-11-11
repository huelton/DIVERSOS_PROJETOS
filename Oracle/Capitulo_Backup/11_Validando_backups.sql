-- Validando datafiles e control files do BD:
VALIDATE DATABASE;

-- validando todos os datafiles e archives por corrompimento fisico e logico:
BACKUP VALIDATE CHECK LOGICAL DATABASE ARCHIVELOG ALL;

-- validando blocos de um datafile:
VALIDATE DATAFILE 2;

-- validando um tablespace:
VALIDATE TABLESPACE SYSTEM;

-- validando um backupset:
VALIDATE BACKUPSET X;

-- Validando o restore de um bd e seus archives:
RESTORE DATABASE VALIDATE;
RESTORE ARCHIVELOG ALL VALIDATE;

-- Consultando blocos corrompidos:
SELECT * FROM V$DATABASE_BLOCK_CORRUPTION;

-- Consultando objetos com blocos corrompidos:
SELECT  DISTINCT owner, segment_name
FROM    v$database_block_corruption dbc
JOIN    dba_extents e 
    ON  dbc.file# = e.file_id 
    AND dbc.block# BETWEEN e.block_id and e.block_id+e.blocks-1
ORDER BY 1,2;


