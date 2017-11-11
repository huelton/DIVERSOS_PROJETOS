-- Efetuando backups com compressao de dados:
BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG;

-- Efetuando backups com criptografia:
set encryption on identified by 'L!eFLW@Bf=U,ptC>' only;

-- Fazendo um backup critogrado e quebrando arquivos de backup em secoes:
BACKUP SECTION SIZE 1G TABLESPACE USERS;

-- Restaurando o backup previamente criptogrado:
set encryption on identified by 'L!eFLW@Bf=U,ptC>' only;
RESTORE TABLESPACE USERS;

-- Tirando criptografia do tablespace USERS e desabilitando a criptografia:
set encryption off;
configure encryption algorithm clear;
configure encryption for tablespace users CLEAR;

-- Efetuando backup com paralelismo:
CONFIGURE DEVICE TYPE DISK PARALLELISM 2;
CONFIGURE CHANNEL 1 DEVICE TYPE DISK FORMAT '/tmp/%U';
CONFIGURE CHANNEL 2 DEVICE TYPE DISK FORMAT '/orabkp/bkp/%U';
BACKUP SECTION SIZE 100M TABLESPACE SYSAUX;

-- Restaurando configuracoes efetuadas previamente:
CONFIGURE DEVICE TYPE DISK CLEAR;
CONFIGURE CHANNEL 1 DEVICE TYPE DISK CLEAR;
CONFIGURE CHANNEL 2 DEVICE TYPE DISK CLEAR;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/orabkp/bkp/df_bkp_%d_s%s_p%p_%t';
  

  
  
