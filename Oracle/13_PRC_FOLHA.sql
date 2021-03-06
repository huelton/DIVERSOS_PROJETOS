-- CORRIGINDO DATA DE ADMISSÃO

SELECT * FROM FUNCIONARIO
 WHERE TO_CHAR(DATA_ADMISS,'YYYY') = '1917';

UPDATE FUNCIONARIO 
   SET DATA_ADMISS = TO_CHAR(DATA_ADMISS,'DD/MM')|| '/2017'
 WHERE TO_CHAR(DATA_ADMISS,'YYYY') = '1917';
 COMMIT;

 SELECT MATRICULA, TO_CHAR(DATA_ADMISS,'DD/MM/YYYY') 
   FROM FUNCIONARIO
  WHERE TO_CHAR(DATA_ADMISS,'YYYY') = '1917';
  
-- --------------------------------------------------------------
-- SELECT * FROM FOLHA_PAGTO
-- PROCEDURE FOLHA PAGTO
-- GERA INFORMAÇÕES PARA PAGAMENTO
-- TABELAS ORIGEM SALARIO
-- TABELA DE FUNCIONARIO VERIFICADO ADMISSAO E DEMISSAO
-- TAB PARAMETROS, PARAM_INSS, PARAM_IRRF
-- TABELAS DESTINO FOLHA PAGTO
-- PARAMETROS, RES_REF, ANO_REF, DATA_PAGTO
-- EXEC PRC_FOLHA 3, 2017, '2017-03-05'
-- SELECT * FROM FOLHA_PAGTO
-- --------------------------------------------------------------

CREATE OR REPLACE PROCEDURE PRC_FOLHA (P_EMP IN NUMBER,
                                       P_MES_REF IN VARCHAR2,
                                       P_ANO_REF IN VARCHAR2,
                                       P_DATA_PAGTO DATE )
 IS
    SALARIO_LIQ DECIMAL(10,2);
    VAL_INSS DECIMAL(10,2);
    VAL_IRPF DECIMAL(10,2);
    VAL_ISENT_IRPF DECIMAL(10,2);

BEGIN
   
   -- APAGANDO REGISTRO PARA RECALCULAR
   DBMS_OUTPUT.PUT_LINE('APAGANDO REGISTROS PARA RECALCULO');
     
   DELETE 
     FROM FOLHA_PAGTO 
    WHERE MES_REF = P_MES_REF
      AND ANO_REF = P_ANO_REF
      AND COD_EMPRESA = P_EMP;
      
      -- DECLARANDO CURSOR PARA LER SALARIO BRUTO
  FOR SAL_BRUTO IN (SELECT A.COD_EMPRESA, A.MATRICULA,
                               A.SALARIO AS SALARIO_BRUTO
                          FROM SALARIO A
                         INNER JOIN FUNCIONARIO B
                            ON A.MATRICULA = B.MATRICULA
                           AND A.COD_EMPRESA = B.COD_EMPRESA
                         WHERE B.DATA_ADMISS <= LAST_DAY('01/'||P_MES_REF||'/'||P_ANO_REF)
                           AND A.COD_EMPRESA = P_EMP
                           AND B.DATE_DEMISS IS NULL) LOOP
                           
     -- INSERT DE VALORES BRUTOS
     INSERT INTO FOLHA_PAGTO(COD_EMPRESA, MATRICULA, TIPO_PGTO, TIPO, EVENTO,
                              MES_REF, ANO_REF, DATA_PAGTO, VALOR )
            VALUES (SAL_BRUTO.COD_EMPRESA, SAL_BRUTO.MATRICULA,'F','P','SAL BRUTO',
                     P_MES_REF, P_ANO_REF, P_DATA_PAGTO, SAL_BRUTO.SALARIO_BRUTO);

    -- DECLARANDO CURSOR PARA CALCULAR INSS
    FOR C_INSS IN (SELECT A.PCT AS PCT_INSS
                     FROM  PARAM_INSS A
                    WHERE SAL_BRUTO.SALARIO_BRUTO
                  BETWEEN A.VALOR_DE AND A.VALOR_ATE
                      AND P_MES_REF 
                  BETWEEN TO_CHAR(A.VIGENCIA_INI, 'MM') AND TO_CHAR(A.VIGENCIA_FIM, 'MM') 
                      AND P_ANO_REF 
                  BETWEEN TO_CHAR(A.VIGENCIA_INI, 'YYYY') AND TO_CHAR(A.VIGENCIA_FIM, 'YYYY') 
                  ) LOOP

        -- REGRA DE TETO DE INSS QUANDO MAIOR QUE 5531.31
        IF SAL_BRUTO.SALARIO_BRUTO > 5531.31 THEN

            VAL_INSS := 608.44;
            C_INSS.PCT_INSS := 0; 

        ELSE 
        
             VAL_INSS := SAL_BRUTO.SALARIO_BRUTO/100 * C_INSS.PCT_INSS;

        END IF;

      -- INSERINDO REGISTRO NA FOLHA DE PAGTO
     INSERT INTO FOLHA_PAGTO(COD_EMPRESA, MATRICULA, TIPO_PGTO, TIPO, EVENTO,
                              MES_REF, ANO_REF, DATA_PAGTO, VALOR )
            VALUES (SAL_BRUTO.COD_EMPRESA, SAL_BRUTO.MATRICULA,'F','D','INSS',
                     P_MES_REF, P_ANO_REF, P_DATA_PAGTO, VAL_INSS);

       -- DECLARANDO CURSOR PARA CALC IRRF
       -- SELECIONANDO VALORES
       -- SELECT * FROM PARAM_IRRF
       FOR C_IRRF IN (SELECT A.PCT AS PCT_IRRF, A.VAL_ISENT
                        FROM  PARAM_IRRF A
                       WHERE SAL_BRUTO.SALARIO_BRUTO
                     BETWEEN A.VALOR_DE AND A.VALOR_ATE
                         AND P_MES_REF 
                     BETWEEN TO_CHAR(A.VIGENCIA_INI, 'MM') AND TO_CHAR(A.VIGENCIA_FIM, 'MM') 
                         AND P_ANO_REF 
                     BETWEEN TO_CHAR(A.VIGENCIA_INI, 'YYYY') AND TO_CHAR(A.VIGENCIA_FIM, 'YYYY') 
                      ) LOOP

           -- CALCULO DO IR
           VAL_IRPF := ((SAL_BRUTO.SALARIO_BRUTO - VAL_INSS)/100) * C_IRRF.PCT_IRRF - C_IRRF.VAL_ISENT;

           -- INSERINDO REGISTRO IR
           INSERT INTO FOLHA_PAGTO(COD_EMPRESA, MATRICULA, TIPO_PGTO, TIPO, EVENTO,
                              MES_REF, ANO_REF, DATA_PAGTO, VALOR )
                VALUES (SAL_BRUTO.COD_EMPRESA, SAL_BRUTO.MATRICULA,'F','D','IRRF',
                     P_MES_REF, P_ANO_REF, P_DATA_PAGTO, VAL_IRPF);

          -- CALCULANDO SALARIO LIQUIDO
          SALARIO_LIQ := SAL_BRUTO.SALARIO_BRUTO - (VAL_INSS + VAL_IRPF);

          INSERT INTO FOLHA_PAGTO(COD_EMPRESA, MATRICULA, TIPO_PGTO, TIPO, EVENTO,
                              MES_REF, ANO_REF, DATA_PAGTO, VALOR )
                 VALUES (SAL_BRUTO.COD_EMPRESA, SAL_BRUTO.MATRICULA,'F','P','SALARIO LIQUIDO',
                     P_MES_REF, P_ANO_REF, P_DATA_PAGTO, SALARIO_LIQ);

        END LOOP; -- FIM CALC INSS

     END LOOP; -- FIM CALC IRRF

  END LOOP; -- FIM SALARIO_BRUTO 


     DBMS_OUTPUT.PUT_LINE('CALCULO FINALIZADO');
     COMMIT;

     EXCEPTION

       WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('NAO EXISTE DADOS!');
         ROLLBACK;

       WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE ('OUTRO CODIGO DE ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
          DBMS_OUTPUT.PUT_LINE ('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
          ROLLBACK;

  END PRC_FOLHA;

   -- EXECUTANDO PROCEDURE
   -- PARAMETRO EMPRESA, MES_REF, ANO_REF, DATA_PAGTO

   SET SERVEROUTPUT ON;

   EXECUTE PRC_FOLHA (1,'01','2018','05/02/2018');

   SELECT * FROM FOLHA_PAGTO;