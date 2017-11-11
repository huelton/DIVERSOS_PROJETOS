-- ver informacoes detalhadas sobre archive logs backupeados:
    SELECT * FROM RC_BACKUP_ARCHIVELOG_DETAILS;
    
-- ver informacoes resumidas sobre archive logs backupeados:
    SELECT * FROM RC_BACKUP_ARCHIVELOG_SUMMARY;

-- ver informacoes detalhadas sobre control file backupeados:
    SELECT * FROM RC_BACKUP_CONTROLFILE_DETAILS;
    
-- ver informacoes resumidas sobre control file backupeados:
    SELECT * FROM RC_BACKUP_CONTROLFILE_SUMMARY;

-- ver informacoes detalhadas sobre control files e datafiles backupeados:
    SELECT * FROM RC_BACKUP_COPY_DETAILS;
    
-- ver informacoes resumidas sobre control files e datafiles backupeados:
    SELECT * FROM RC_BACKUP_COPY_SUMMARY;

-- ver informacoes detalhadas sobre todos os datafiles backupeados (BS e IC):
    SELECT * FROM RC_BACKUP_DATAFILE_DETAILS;
    
-- ver informacoes resumidas sobre todos os datafiles backupeados (BS e IC):
    SELECT * FROM RC_BACKUP_DATAFILE_SUMMARY;
    
-- ver informacoes detalhadas sobre pecas de backup:
    SELECT * FROM RC_BACKUP_PIECE_DETAILS;
    
-- ver informacoes detalhadas sobre backup sets:
    SELECT * FROM RC_BACKUP_SET_DETAILS;

-- ver informacoes resumidas sobre backup sets:
    SELECT * FROM RC_BACKUP_SET_SUMMARY;

-- ver lista de arquivos de backup de qq tipo que foram marcados como indisponiveis ou expirados:    
    SELECT * FROM RC_UNUSABLE_BACKUPFILE_DETAILS;