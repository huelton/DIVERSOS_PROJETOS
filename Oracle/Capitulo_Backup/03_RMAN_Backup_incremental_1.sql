$ rman target / catalog rman/rman

-- backup incremental level 0               = full
-- backup incremental level 1               = incremental
-- backup incremental level 1 cumulative    = diferencial

-- Executando backup incremental:
RMAN> backup incremental level 1 database TAG 'inc_diario';

-- Executando backup incremental diferencial:
RMAN> backup incremental level 1 cumulative database TAG 'cumulativo_semanal';