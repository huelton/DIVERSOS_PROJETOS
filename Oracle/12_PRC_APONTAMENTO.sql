-- -------------------------------------------------------------
-- PARAMETROS, ID_ORDEM, COD_MAT_PROD, QTD_APONT LOTE
-- CONSISTENCIA DE ESTOQUE
-- ORDEM_PROD SITUACAO = A NAO GEROU PEDIDO DE COMPRAS
-- ORDEM_PROD SITUACAO = P GEROU PEDIDO DE COMPRAS
-- ORDEM_PROD SITUACAO = F FINALIZADA
-- -------------------------------------------------------------

-- SELECT * FROM ORDEM_PROD

-- SELECT * FROM ORDEM_PROD
-- EXC PROC_APONTAMENTO 1,1,10,TESTE1

CREATE OR REPLACE PROCEDURE  PRC_APONTAMENTO ( P_EMP IN NUMBER,
                                               P_ID_ORDEM IN INT,
                                               P_COD_MAT_PROD IN NUMBER,
                                               P_QTD_APON IN NUMBER,
                                               P_LOTE_PROD VARCHAR2)

  IS 

    V_ORDER_N_EXISTE      EXCEPTION;
    V_MAT_NEC_INSUF       EXCEPTION;
    V_SALDO_INSUF_ORDEM   EXCEPTION;

    V_CONT_OP             INT;
    P_QTD_PLAN            DECIMAL(10,2);
    P_QTD_PROD             DECIMAL(10,2);

    P_SALDO               DECIMAL(10,2);
    P_SALDO_AUX           DECIMAL(10,2);

    P_DATA_MOVTO          DATE;
    P_ID_APON             INT;
    P_QTD_ATEND           DECIMAL(10,2);
    P_COD_MAT_AUX         INT;

BEGIN
   
     -- ATRIBUINDO VALOR A VARIAVEL P_DATA_MOVTO
     SELECT SYSDATE INTO P_DATA_MOVTO FROM DUAL;

     -- PRIMEIRA ETAPA APONTAMENTO ATUALIZA ORDEM E MOVIMENTA ESTOQUE
     -- PRIMEIRO IF CHECK DE EXISTE ORDEM E SE POSSUI SALDO PARA SELECAO

      SELECT COUNT(*) CONT, A.QTD_PLAN, A.QTD_PROD
        INTO V_CONT_OP, P_QTD_PLAN, P_QTD_PROD
        FROM ORDEM_PROD A
       WHERE A.COD_MAT_PROD = P_COD_MAT_PROD
         AND A.ID_ORDEM = P_ID_ORDEM
         AND A.COD_EMPRESA = P_EMP
         AND A.SITUACAO = 'P'
         GROUP BY A.QTD_PLAN, A.QTD_PROD; -- APENAS ORDEM PLANEJADAS

         -- ATRIBUINDO SALDO
         P_SALDO := P_QTD_PLAN - P_QTD_PROD;
        
         -- VERIFICA SE EXISTE ORDEM
         IF V_CONT_OP = 0 THEN

            RAISE V_ORDER_N_EXISTE;

            -- VERIFICA SE A OP DISPONIVEL TEM SALDO SUFICIENTE
            -- VERIFICANDO QTD APONTADA > SALDO PARA NAO PERMITIR APONTAMENTO
         ELSIF V_CONT_OP = 1 AND P_SALDO < P_QTD_APON THEN
         
             RAISE V_SALDO_INSUF_ORDEM;

         END IF;   

    FOR C_MAT_NECES IN (SELECT B.COD_MAT_NECES, B.QTD_NECES * P_QTD_APON AS QTD_NECES,
    	                       NVL(C.QTD_SALDO, 0) SALDO,
    	                       NVL(C.QTD_SALDO, 0) - (B.QTD_NECES * P_QTD_APON) AS SALDO_DISP
    	                  FROM ORDEM_PROD A
    	                 INNER JOIN FICHA_TECNICA B
    	                    ON A.COD_MAT_PROD = B.COD_MAT_PROD
    	                   AND A.COD_EMPRESA = B.COD_EMPRESA
    	                  LEFT JOIN ESTOQUE C
                            ON B.COD_MAT_NECES = C.COD_MAT
                           AND A.COD_EMPRESA = B.COD_EMPRESA
                         WHERE A.ID_ORDEM = P_ID_ORDEM  -- PARAMETRO DE OP
                           AND A.COD_EMPRESA = P_EMP    -- PARAMETRO DE EMPRESA
    	                 ) LOOP

         -- VERIFICACOES
         IF C_MAT_NECES.SALDO_DISP <= 0 THEN

            RAISE V_MAT_NEC_INSUF;
         END IF;

    END LOOP; -- FIM CURSOR C_MAT_NECES

    -- DECLARANDO CURSOR DE APONTAMENTO

    -- SELECIONANDO VALORES
    FOR C_APONT IN ( SELECT A.ID_ORDEM, A.COD_MAT_PROD, A.QTD_PLAN, A.QTD_PROD
                       FROM ORDEM_PROD A
                      WHERE A.COD_MAT_PROD = P_COD_MAT_PROD
                        AND A.ID_ORDEM = P_ID_ORDEM
                        AND A.COD_EMPRESA = P_EMP
                        AND A.SITUACAO = 'P') LOOP -- APENAS ORDEM PLANEJADA

        -- ATRIBUINDO VALORES
        P_SALDO := C_APONT.QTD_PLAN - C_APONT.QTD_PROD;
        P_SALDO_AUX := P_SALDO;

        -- INSERT NA TABELA APONTAMENTOS PARA  RASTREABILIDADE
        INSERT INTO APONTAMENTOS  (COD_EMPRESA, ID_APON, ID_ORDEM, COD_MAT_PROD, 
        	                       QTD_APON, DATA_APON, LOGIN, LOTE)
               VALUES (P_EMP, NULL, P_ID_ORDEM, P_COD_MAT_PROD, P_QTD_APON, 
               	       SYSDATE, USER, P_LOTE_PROD)
               RETURNING ID_APON INTO P_ID_APON;
        
        -- EXECUTA PRC_GERA_ESTOQUE
        PRC_MOV_ESTOQUE ('E', P_EMP, P_COD_MAT_PROD, 
        	              P_LOTE_PROD, P_QTD_APON, P_DATA_MOVTO);

        -- UPDATE SALDO DA ORDEM
        DBMS_OUTPUT.PUT_LINE('APONTAMENTO');
        DBMS_OUTPUT.PUT_LINE( 'ORDEM: '         || P_ID_ORDEM ||
                             ' MAT PRODUZIDO: ' || P_COD_MAT_PROD ||
                             ' QTD: '           || P_QTD_APON ||
                             ' LOTE: ' || P_LOTE_PROD);
        
        UPDATE ORDEM_PROD
           SET QTD_PROD = P_QTD_PROD + P_QTD_APON
         WHERE ID_ORDEM = P_ID_ORDEM
           AND COD_MAT_PROD = P_COD_MAT_PROD
           AND COD_EMPRESA = P_EMP;
         
         -- ATRIBUINDO VALORES
         P_SALDO := P_QTD_PLAN - (C_APONT.QTD_PROD + P_QTD_APON);
         P_SALDO_AUX := P_SALDO;

    END LOOP; -- FIM LOOP APONTAMENTO

    -- INICIO DO SEGUNDO BLOCO CONSUMINDO NECESSIDADES E MOVIMENTO ESTOQUE

    -- ZERANDO VARIAVEIS
        DBMS_OUTPUT.PUT_LINE('MATERIAIS CONSUMIDOS');

    -- DECLARANDO CURSOR DE NECESSIDADES
    -- SELECIONANDO VALORES
    FOR C_NECESSIDADES IN (SELECT A.ID_ORDEM, A.SITUACAO, A.COD_MAT_PROD,
    	                          A.QTD_PLAN, B.COD_MAT_NECES, B.QTD_NECES,
    	                          P_QTD_APON QTD_APON, 
    	                          P_QTD_APON*B.QTD_NECES QTD_NECES_CONS
    	                     FROM ORDEM_PROD A
    	                    INNER JOIN FICHA_TECNICA B
    	                       ON A.COD_MAT_PROD = B.COD_MAT_PROD
    	                      AND A.COD_EMPRESA = B.COD_EMPRESA
    	                    WHERE A.SITUACAO = 'P'
    	                      AND A.ID_ORDEM = P_ID_ORDEM --PARAMETRO DE ORDEM
                              AND A.COD_MAT_PROD = P_COD_MAT_PROD -- PARAMETRO MAT_PROD
                              AND A.COD_EMPRESA = P_EMP) LOOP -- PARAMETRO COD_EMPRESA
                             
         -- ABRINDO CURSOR NECESSIDADES
         -- DECLARANDO CURSOR PARA ALIMENTAR CONSUMO E MOVIMENTAR ESTOQUE
         FOR C_EST_CONS IN (SELECT C.COD_MAT, C.QTD_LOTE, C.LOTE
                              FROM ESTOQUE_LOTE C
                             WHERE C.COD_MAT = C_NECESSIDADES.COD_MAT_NECES
                               AND C.COD_EMPRESA = P_EMP -- PARAMETRO EMPRESA
                               AND C.QTD_LOTE > 0
                             ORDER BY C.COD_MAT, C.LOTE) LOOP
                
             -- ABRINDO CURSOR
             -- ATRIBUINDO VALORES A VARIAVEIS
             P_SALDO :=  C_NECESSIDADES.QTD_NECES_CONS;
             P_SALDO_AUX := P_SALDO;

           -- TESTES
           -- VERIFICACOES DE TROCA DE MATERIAL
             IF P_COD_MAT_AUX <> C_NECESSIDADES.COD_MAT_NECES THEN
                 
                 P_QTD_ATEND := 0;

             END IF;

         	-- VERIFICACOES DE SALDO <= 0
            IF P_SALDO <= 0 THEN
                 
                 P_QTD_ATEND := 0;

            END IF;
            
            -- VERIFICANDO SE SALDO_AUX MAIOR IGUAL A QTD_LOTE
            IF P_SALDO_AUX >= C_EST_CONS.QTD_LOTE THEN
                 
                 -- ATRIBUINDO VALORES
                 P_QTD_ATEND := C_EST_CONS.QTD_LOTE;
                 P_SALDO := P_SALDO - C_NECESSIDADES.QTD_NECES_CONS;
                 P_SALDO_AUX := P_SALDO_AUX - C_EST_CONS.QTD_LOTE;

            -- VERIFICANDO SE SALDO AUX MENOR A QTD_LOTE
            ELSIF P_SALDO_AUX < C_EST_CONS.QTD_LOTE THEN

                 -- ATRIBUINDO VALORES
                 P_SALDO := C_NECESSIDADES.QTD_NECES_CONS;
                 P_QTD_ATEND := P_SALDO_AUX;
                 P_SALDO_AUX := P_SALDO_AUX - P_QTD_ATEND;

            END IF;

            -- IF PARA INSERIR APENAS O RETORNO COM O SALDO >= 0 E QTD_ATEND > 0
            IF P_SALDO_AUX >= 0 AND P_QTD_ATEND > 0 THEN

               -- EXECUTANDO PROCEDURE DE MOV_ESTOQUE DENTRO DO IF, RECEBENDO VARIAVEIS
               -- INSERT NA TABELA CONSUMO PARA RASTREABILIDADE
               INSERT INTO CONSUMO 
                     VALUES (P_ID_APON, P_EMP, C_NECESSIDADES.COD_MAT_NECES,
                     	     P_QTD_ATEND, C_EST_CONS.LOTE);

               -- EXECUTA PRC GERA ESTOQUE COM MOV SAIDA
               PRC_MOV_ESTOQUE ('S', P_EMP, C_NECESSIDADES.COD_MAT_NECES, 
               	                 C_EST_CONS.LOTE, P_QTD_ATEND, P_DATA_MOVTO);

               -- ATRIBUINDO VALOR VARIAVEL
               P_COD_MAT_AUX := C_NECESSIDADES.COD_MAT_NECES;
               -- PRINT
               DBMS_OUTPUT.PUT_LINE( 'COD MAT: '     || C_NECESSIDADES.COD_MAT_NECES ||
                                     ' QTD_ATEND: '  || P_QTD_ATEND ||
                                     ' LOTE: '       || C_EST_CONS.LOTE  ||
                                     ' SALDO AUX: '  || P_QTD_ATEND);

            END IF;

            -- SE SALDO AUXILIAR IGUAL A ZERO SAI DO LOOP E INICIA PROXIMO MATERIAL
            IF P_SALDO_AUX = 0 THEN

                EXIT;
            END IF;

         END LOOP; -- FIM LOOP C_EST_CONS

    END LOOP; -- FIM LOOP C_NECESSIDADES

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('FINALIZADO COM SUCESSO!');

 EXCEPTION
    WHEN V_ORDER_N_EXISTE THEN
         DBMS_OUTPUT.PUT_LINE('ORDEM NAO EXISTE OU SEM SALDO/PARAMETROS INCORRETOS');
         ROLLBACK;

    WHEN V_MAT_NEC_INSUF THEN
         DBMS_OUTPUT.PUT_LINE('MATERIAIS NECESSARIOS INSUFICIENTE');
         ROLLBACK;
    
    WHEN V_SALDO_INSUF_ORDEM THEN
         DBMS_OUTPUT.PUT_LINE('SALDO INSUFICIENTE DA ORDEM');
         ROLLBACK;
 
    WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('NAO EXISTE DADOS!');
         ROLLBACK;

    WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE ('OUTRO CODIGO DE ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
          DBMS_OUTPUT.PUT_LINE ('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
          ROLLBACK;


END PRC_APONTAMENTO;