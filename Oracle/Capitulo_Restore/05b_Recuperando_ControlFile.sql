-- Verifique e anote o caminho dos control files:
sql> SHOW PARAMETER CONTROL_FILES 
sql> exit

-- Apague o primeiro dos control files:
$   rm caminho_nome_controlfile

-- Faca um shutdown/startup e veja o que acontece...
$       sqlplus / as sysdba
sql>    SHUTDOWN IMMEDIATE;  --- vai dar erro entao execute a seguir um shut abort
sql>    SHUTDOWN ABORT;
sql>    STARTUP;  -- vai dar erro
sql>    exit

-- Faca uma copia do 2o CF atribuindo na copia o nome do 1o CF:
$       cp <caminho_completo_cf2> <caminho_completo_cf1>

-- Derrube o BD e faca novamente um startup
$       sqlplus / as sysdba
sql>    SHUTDOWN ABORT
sql>    STARTUP