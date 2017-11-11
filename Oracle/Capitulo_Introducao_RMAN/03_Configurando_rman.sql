-- 1: conectar-se no RMAN:
$   rman target / catalog rman/rman

-- 2: ver configuracoes do RMAN:
RMAN>   show all;
-- ou 
SQL>    select * from v$rman_configuration;

-- 3: configurando destino dos backups em disco:
RMAN>   CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/orabkp/bkp/df_bkp_%d_s%s_p%p_%t';

/*
%p: piece number
%s: backup set number
%t: timestamp
%d: database ID
%F: dbid + dia, mes, ano e unique sequence
*/

-- 4: alterando p/ fazer backup automatico do control file:
RMAN>   CONFIGURE CONTROLFILE AUTOBACKUP ON;

-- 5: alterando destino e nome do bkp automatico do control file:
RMAN>   CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/orabkp/bkp/cf_bkp_%F';
    
-- 6: configurando a retencao dos backups para 7 dias:
RMAN>   CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

-- 7: configurando a retencao dos backups para redundancia de 1 copia:
RMAN>   CONFIGURE RETENTION POLICY TO REDUNDANCY 1;

-- 8: configurando a retencao dos archived logs:
RMAN>   CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 1 TIMES TO DISK;