 -- -----------------------------------------------------
 -- V_FUNCIONARIO
 -- TABELAS FUNCINARIO, CARGOS, CENTRO_CUSTO
 -- SELECT * FROM V_FUNCINARIO
 -- -----------------------------------------------------

 CREATE OR REPLACE VIEW V_FUNCIONARIO
   AS
       SELECT A.COD_EMPRESA,
              A.MATRICULA,
              A.COD_CC,C.NOME_CC,
              A.NOME, A.COD_CARGO,
              B.NOME_CARGO,
              A.DATA_ADMISS,
              A.DATE_DEMISS,
              CASE WHEN A.DATE_DEMISS IS NULL THEN 'ATIVO'
                   ELSE 'DESLIGADO'
              END SITUACAO
              FROM FUNCIONARIO A
              INNER JOIN CARGOS B
              ON A.COD_CARGO = B.COD_CARGO
              AND A.COD_EMPRESA = B.COD_EMPRESA

              INNER JOIN CENTRO_CUSTO C
              ON A.COD_CC = C.COD_CC
              AND A.COD_EMPRESA = C.COD_EMPRESA;


-- TESTANDO VIEW
 SELECT * FROM V_FUNCIONARIO;
