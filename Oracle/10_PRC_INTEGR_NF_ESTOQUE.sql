-- ------------------------------------------------------------------------------
-- EXECUTE PRC_INTEGR_NF_ESTOQUE 1,10,'2017-01-30'
-- SELECT * FROM NOTA_FISCAL
-- SELECT * FROM NOTA_FISCAL_ITENS
-- UPDATE NOTA_FISCAL SET INTEGRADA_SUP = 'N' WHERE NUM_NF = '2'
-- SELECT * FROM ESTOQUE
-- SELECT * FROM ESTOQUE_LOTE
-- SELECT * FROM ESTOQUE_MOV
-- -------------------------------------------------------------------------------
 
 ALTER SESSION SET nls_date_format = 'DD/MM/YYYY';

CREATE OR REPLACE PROCEDURE PRC_INTEGR_NF_ESTOQUE ( P_EMP IN NUMBER,
	                                                P_NUM_NF NUMBER,
	                                                P_DATA_MOVTO DATE)
  IS

    V_EXC_SALDO_INSUFICIENTE EXCEPTION;
    V_EXC_DOCT_NAO_EXISTE EXCEPTION;
    V_EXC_INTEGRADO EXCEPTION;

    V_QTD_AUX NUMBER(10,2);
    V_QTD_TOT NUMBER(10,2);
    V_TIP_OPER VARCHAR2(1);
    V_SITUA VARCHAR2(1);
    V_CONT INT;
    V_NUM_NF NUMBER;
    V_MAT_AUX NUMBER;
    V_SALDO_AUX NUMBER(10,2);


BEGIN
 
   --VERIFICANDO DE DOCTO EXISTE E JA ESTA INTEGRADO
   SELECT NUM_NF, TIP_NF, INTEGRADA_SUP, COUNT(*) QTD 
     INTO V_NUM_NF, V_TIP_OPER, V_SITUA, V_CONT
     FROM NOTA_FISCAL
    WHERE COD_EMPRESA = P_EMP 
      AND NUM_NF = P_NUM_NF
    GROUP BY NUM_NF, TIP_NF, INTEGRADA_SUP;

    -- VERIFICA SE EXISTE DOCTO
    IF V_CONT = 0 THEN

      RAISE V_EXC_DOCT_NAO_EXISTE;
    END IF;
    
    -- VERIFICA SE ESTA INTEGRADO
    IF V_CONT = 1 AND V_SITUA = 'S' THEN
       
      RAISE V_EXC_INTEGRADO;
    END IF;

    -- VERIFICA SE NOTA DE ENTRADA PARA DAR ENTRADA EM ESTOQUE
    IF V_TIP_OPER = 'E' THEN
       
          FOR C_NF_IT IN ( 
          	  SELECT A.COD_EMPRESA, A.TIP_NF, B.COD_MAT,
          	         TO_CHAR (SYSDATE, 'DD-MM')||'-'||A.NUM_NF LOTE,
          	         --COMPOSICAO CAMPO LOTE (DIA MES + NUMERO DA NF)
          	         B.QTD
          	         FROM NOTA_FISCAL A
          	         INNER JOIN NOTA_FISCAL_ITENS B
          	         ON A.COD_EMPRESA = B.COD_EMPRESA
          	         AND A.NUM_NF = B.NUM_NF
          	         WHERE A.NUM_NF = P_NUM_NF  -- PARAMETRO
          	         AND A.COD_EMPRESA = P_EMP  -- PARAMETRO
                     AND A.TIP_NF = 'E'
                     AND A.INTEGRADA_SUP = 'N' ) LOOP
 
                 -- EXECUTANDO PROCEDURE QUE MOVIMENTA ESTOQUE PARA DAR ENTRADA NO MATERIAL
                 PRC_MOV_ESTOQUE (C_NF_IT.TIP_NF, P_EMP, C_NF_IT.COD_MAT, C_NF_IT.LOTE, C_NF_IT.QTD, P_DATA_MOVTO);

          END LOOP;

          UPDATE NOTA_FISCAL 
             SET INTEGRADA_SUP = 'S'
           WHERE NUM_NF = P_NUM_NF
             AND COD_EMPRESA = P_EMP;

          COMMIT;

             DBMS_OUTPUT.PUT_LINE('ENTRADA CONCLUIDA!');

    ELSIF V_TIP_OPER = 'S' THEN
       --ABRINDO CURSOR DOS ITENS DA NF
      FOR C_NF_IT IN (
      	      SELECT A.COD_EMPRESA, A.TIP_NF, B.COD_MAT,
          	         --TO_CHAR (SYSDATE, 'DD-MM')||'-'||A.NUM_NF LOTE,
          	         --COMPOSICAO CAMPO LOTE (DIA MES + NUMERO DA NF)
          	         B.QTD
          	         FROM NOTA_FISCAL A
          	         INNER JOIN NOTA_FISCAL_ITENS B
          	         ON A.COD_EMPRESA = B.COD_EMPRESA
          	         AND A.NUM_NF = B.NUM_NF
          	         WHERE A.NUM_NF = P_NUM_NF  -- PARAMETRO
          	         AND A.COD_EMPRESA = P_EMP  -- PARAMETRO
                     AND A.TIP_NF = 'S'
                     AND A.INTEGRADA_SUP = 'N' ) LOOP
 
             -- ABRINDO CURSOR DO MATERIAL EM ESTOQUE DOS ITENS DA NF
             FOR C_ESTOQUE IN (SELECT A.COD_EMPRESA, A.COD_MAT, A.QTD_SALDO
           	                     FROM ESTOQUE A 
           	                    WHERE A.COD_EMPRESA = P_EMP 
           	                      AND A.COD_MAT = C_NF_IT.COD_MAT
           	                   ) LOOP

                -- VERIFICA SE SALDO DISPONIVEL PARA SAIDA
                IF (C_NF_IT.QTD > C_ESTOQUE.QTD_SALDO) THEN

                     RAISE V_EXC_SALDO_INSUFICIENTE;
                END IF;
           
             END LOOP; -- LOOP C_ESTOQUE

          END LOOP; -- LOOP C_NF_IT

    END IF;

    -- GERANDO MOVIMENTACAO DE SAIDA
    IF V_TIP_OPER = 'S' THEN
       --ABRINDO CURSOR DOS ITENS DA NF

          FOR C_NF_IT IN (
      	      SELECT A.COD_EMPRESA, A.TIP_NF, B.COD_MAT,
          	         --TO_CHAR (SYSDATE, 'DD-MM')||'-'||A.NUM_NF LOTE,
          	         --COMPOSICAO CAMPO LOTE (DIA MES + NUMERO DA NF)
          	         B.QTD
          	         FROM NOTA_FISCAL A
          	         INNER JOIN NOTA_FISCAL_ITENS B
          	         ON A.COD_EMPRESA = B.COD_EMPRESA
          	         AND A.NUM_NF = B.NUM_NF
          	         WHERE A.NUM_NF = P_NUM_NF  -- PARAMETRO
          	         AND A.COD_EMPRESA = P_EMP  -- PARAMETRO
                     AND A.TIP_NF = 'S'
                     AND A.INTEGRADA_SUP = 'N' ) LOOP
 
                -- ATRIBUINDO A QUANTIDADE NECESSARIA PARA BAIXA EM ESTOQUE
                V_SALDO_AUX := C_NF_IT.QTD;
                
             FOR C_EST_LOTE IN (SELECT A.COD_EMPRESA, A.COD_MAT, A.LOTE, A.QTD_LOTE
           	                      FROM ESTOQUE_LOTE A 
           	                     WHERE A.COD_EMPRESA = P_EMP 
           	                       AND A.COD_MAT = C_NF_IT.COD_MAT
           	                     ORDER BY A.COD_MAT, A.LOTE
           	                    ) LOOP

                -- SE SALDO IGUAL A ZERO LER PROXIMO MATERIAL
               IF V_SALDO_AUX = 0 THEN

                     EXIT;
               END IF;

               IF (V_SALDO_AUX <= C_EST_LOTE.QTD_LOTE) THEN

                    -- EXECUTANDO PROCEDURE QUE MOVIMENTA ESTOQUE PARA DAR ESNTRADA NO MATERIAL
                    PRC_MOV_ESTOQUE (C_NF_IT.TIP_NF, P_EMP, C_EST_LOTE.COD_MAT, C_EST_LOTE.LOTE, V_SALDO_AUX, P_DATA_MOVTO);

                    -- SUBSTRAINDO QTD BAIXADA
                    V_SALDO_AUX := V_SALDO_AUX - V_SALDO_AUX;
 
               ELSIF (V_SALDO_AUX > C_EST_LOTE.QTD_LOTE) THEN

                      -- EXECUTANDO PROCEDURE QUE MOVIMENTA ESTOQUE PARA DAR ENTRADA NO MATERIAL
                      PRC_MOV_ESTOQUE (C_NF_IT.TIP_NF, P_EMP, C_EST_LOTE.COD_MAT, C_EST_LOTE.LOTE, C_EST_LOTE.QTD_LOTE, P_DATA_MOVTO);

                    V_SALDO_AUX := V_SALDO_AUX - C_EST_LOTE.QTD_LOTE;
 
               END IF;


             END LOOP; -- LOOP C_EST_LOTE

          END LOOP; -- LOOP C_NF_IT


      UPDATE NOTA_FISCAL 
         SET INTEGRADA_SUP = 'S'
       WHERE NUM_NF = P_NUM_NF
         AND COD_EMPRESA = P_EMP;

      COMMIT;

          DBMS_OUTPUT.PUT_LINE('SAIDA CONCLUIDA!');

   END IF;

EXCEPTION
     WHEN V_EXC_SALDO_INSUFICIENTE THEN
       DBMS_OUTPUT.PUT_LINE('SALDO INSUFICIENTE');
       ROLLBACK;

     WHEN V_EXC_DOCT_NAO_EXISTE THEN
       DBMS_OUTPUT.PUT_LINE('DOCUMENTO NAO EXISTE!');
       ROLLBACK;

     WHEN V_EXC_INTEGRADO THEN
       DBMS_OUTPUT.PUT_LINE('DOCTO JA INTEGRADO!');
       ROLLBACK; 
     
     WHEN NO_DATA_FOUND THEN
       DBMS_OUTPUT.PUT_LINE('NAO EXISTE DADOS!');
       ROLLBACK; 

     WHEN OTHERS THEN
       DBMS_OUTPUT.PUT_LINE ('OUTRO CODIGO DE ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
       ROLLBACK; 

END PRC_INTEGR_NF_ESTOQUE ;