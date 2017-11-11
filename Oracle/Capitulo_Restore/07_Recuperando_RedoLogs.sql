-- *** 1: RECUPERANDO UM MEMBRO PERDIDO OU CORROMPIDO

-- idenfique se um membro de um dos grupos foi perdido ou esta corrompido (status=INVALID):
SELECT  GROUP#, STATUS, MEMBER 
FROM    V$LOGFILE
WHERE   STATUS='INVALID';

-- apague o membro informando o caminho dele (campo member da consulta anterior):
ALTER DATABASE DROP LOGFILE MEMBER 'xxx';

-- recrie o membro que foi previamente apagado (xxx=caminho nome do membro, Y=numero do grupo
ALTER DATABASE ADD LOGFILE MEMBER 'xxx' TO GROUP Y;
