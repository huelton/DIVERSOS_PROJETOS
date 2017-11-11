-- ver informacoes sobre archive logs restauraveis:
SELECT * FROM V$BACKUP_ARCHIVELOG_DETAILS;

-- ver informacoes sobre CONTROL FILE restauraveis:
SELECT * FROM V$BACKUP_CONTROLFILE_DETAILS;

-- ver informacoes sobre datafiles restauraveis
SELECT * FROM V$BACKUP_DATAFILE_DETAILS;

-- ver informacoes sobre todas as copias de control file e datafile disponiveis:
SELECT * FROM V$BACKUP_COPY_DETAILS;

-- ver informacoes sobre faixas de blocos de corrompidos em datafile backups:
SELECT * FROM V$BACKUP_CORRUPTION;

-- ver informacoes sobre control files e datafiles em BSs:
SELECT * FROM V$BACKUP_DATAFILE;

-- ver informacoes sobre todos os backups do RMAN (IC e BS) e archived logs:
SELECT * FROM V$BACKUP_FILES;

-- ver informacoes sobre peças de backups:
SELECT * FROM V$BACKUP_PIECE;

-- ver informacoes detalhadas sobre peças de backups disponiveis:
SELECT * FROM V$BACKUP_PIECE_DETAILS;

-- ver informacoes sobre backup sets:
SELECT * FROM V$BACKUP_SET;

-- ver informacoes detalhadas sobre backup sets:
SELECT * FROM V$BACKUP_SET_DETAILS;

-- ver informacoes sobre spfiles contidos no BSs:
SELECT * FROM V$BACKUP_SPFILE;

-- ver informacoes detalhadas sobre spfiles contidos no BSs:
SELECT * FROM V$BACKUP_SPFILE_DETAILS;

-- ver informacoes sobre blocos de BD que se corromperam apos o ultimo backup:
SELECT * FROM V$DATABASE_BLOCK_CORRUPTION;

-- ver status de arquivos precisando de recuperacao de midia:
SELECT * FROM V$RECOVER_FILE;

-- ver informacoes sobre areas de recuperacao:
SELECT * FROM V$RECOVER;

-- ver informacoes sobre jobs de backups:
SELECT * FROM V$RMAN_BACKUP_JOB_DETAILS;

-- ver configuracoes persistentes do RMAN:
SELECT * FROM V$RMAN_CONFIGURATION;

-- ver mensagens do RMAN:
SELECT * FROM V$RMAN_OUTPUT;

-- ver informacoes sobre jobs de backup finalizados e em andamento:
SELECT * FROM V$RMAN_STATUS;

