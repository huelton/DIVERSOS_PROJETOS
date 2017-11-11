-- obtenha o numero do datafile e bloco corrompido no alert log e monte o comando abaixo:
RMAN>   RECOVER DATAFILE x BLOCK y; 

-- recupere todos os blocos corrompidos lista na visao V$DATABASE_BLOCK_CORRUPTION:
RMAN>   RECOVER CORRUPTION LIST;