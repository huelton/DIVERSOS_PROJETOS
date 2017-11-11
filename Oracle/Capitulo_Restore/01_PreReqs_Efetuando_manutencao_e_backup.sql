-- limpando arquivos de backup:
$   rm /orabkp/bkp/*
/**/

-- limpando o catalogo:
RMAN>   RUN {
            CROSSCHECK BACKUP;
            CROSSCHECK COPY;
            CROSSCHECK ARCHIVELOG ALL;
            DELETE NOPROMPT EXPIRED BACKUP;
            DELETE NOPROMPT OBSOLETE;
            DELETE BACKUP OF ARCHIVELOG ALL;
            DELETE ARCHIVELOG ALL;
            }

-- fazendo backup completo nao incremental com archived logs:
RMAN>   BACKUP DATABASE PLUS ARCHIVELOG;

