-- -------------------------------------------------------------------------------
-- PRC_GERA_NF
-- TABELAS ORIGEM: PED_VENDAS, PED_VENDAS_ITENS, PED_COMPRAS, PED_COMPRAS_ITENS
-- TABELAS DESTINO: NOTA_FISCAL, NOTA_FISCAL_ITENS
-- PARAMETROS: TIP_NF, DOCTO, CFOP, DATA_EMIS, DATA_ENTREGA
-- EXEC PRC_GERA_NF 'S',4,'5.101','2017-01-30','2017-01-30'
-- DROP PROCEDURE PRC_GERA_NF
-- --------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE PRC_GERA_NF ( P_EMP IN NUMBER,
                                          TIP_NF IN VARCHAR2,
                                          DOCTO IN NUMBER,
                                          CFOP VARCHAR2,
                                          DATA_EMIS DATE,
                                          DATA_ENTREGA DATE)
IS 
  
    EXC_LANC_FUTURO   EXCEPTION;
    EXC_TIP_NF        EXCEPTION;
    EXC_PED_N_EXISTE  EXCEPTION;
    EXC_QTD_PED_VEND  EXCEPTION;
    EXC_QTD_PED_COMP  EXCEPTION;

    V_SEQ_MAT INT;
    V_TOTAL_NF NUMBER(10,2) := 0;
    QTD_PED_V INT;
    QTD_PED_C INT;
    V_NUM_NF  NUMBER;
    V_DATA DATE := TRUNC(SYSDATE);

BEGIN

    -- VERIFICA DATA DA EMISSAO OU MAIOR QUE ATUAL
    IF (DATA_EMIS > V_DATA) THEN
        
        RAISE EXC_LANC_FUTURO;
    END IF;
    
    -- VERIFICA  QTD_PED_C TIPO MOVIMENTO
    IF (TIP_NF NOT IN ('S', 'E')) THEN
        
        RAISE EXC_TIP_NF;
    END IF;

    -- VERIFICA SE PEDIDO DE VENDA EXISTE
    SELECT COUNT(*) QTD
      INTO QTD_PED_V
      FROM PED_VENDAS A
     WHERE A.NUM_PEDIDO = DOCTO
       AND A.COD_EMPRESA = P_EMP 
       AND A.SITUACAO <> 'F';

    IF (TIP_NF = 'S' AND QTD_PED_V = 0) THEN
        
        RAISE EXC_QTD_PED_VEND;
    END IF;

    -- VERIFICA SE PEDIDO DE COMPRA EXISTE
    SELECT COUNT(*) QTD
      INTO QTD_PED_C
      FROM PED_COMPRAS A
     WHERE A.NUM_PEDIDO = DOCTO
       AND A.COD_EMPRESA = P_EMP 
       AND A.SITUACAO <> 'F';  
     
    IF (TIP_NF = 'E' AND QTD_PED_C = 0) THEN
        
        RAISE EXC_QTD_PED_COMP;
    END IF;

-- INICIO NOTA FISCAL DE SAIDA OU ENTRADA

  IF TIP_NF = 'S' THEN

     -- CURSOR FOR PARA LER PEDIDO DE SAIDA
     FOR C_NF IN (SELECT A.COD_EMPRESA, A.NUM_PEDIDO, A.ID_CLIENTE ID_CLIFOR, A.COD_PAGTO
                    FROM PED_VENDAS A
                   WHERE A.NUM_PEDIDO = DOCTO
                     AND A.COD_EMPRESA = P_EMP
                     AND A.SITUACAO <> 'F' ) LOOP  -- FINALIZADO

     -- INSERINDO DADOS DO CURSOR FOR C_NF
     INSERT INTO NOTA_FISCAL (COD_EMPRESA, NUM_NF, TIP_NF, COD_CFOP, ID_CLIFOR,
                              COD_PAGTO, DATA_EMISSAO, DATA_ENTREGA, TOTAL_NF,
                              INTEGRADA_FIN, INTEGRADA_SUP)
            VALUES (P_EMP, NULL, TIP_NF, CFOP, C_NF.ID_CLIFOR, C_NF.COD_PAGTO, 
            	    DATA_EMIS, DATA_ENTREGA , 0, 'N', 'N')
            RETURNING NUM_NF INTO V_NUM_NF; -- PEGANDO VALOR DO NF INSERIDO E ATRIBUIDO VALOR

            -- APRESENTANDO VALORES CABECALHO
            DBMS_OUTPUT.PUT_LINE('NUM_NF:  ' || V_NUM_NF       ||
                                 ' TIPO NF: ' || TIP_NF         ||
                                    ' CFOP: ' || CFOP           ||
                                ' COD CFOP: ' || C_NF.ID_CLIFOR ||  
                               ' COD PAGTO: ' || C_NF.COD_PAGTO ||  
                            ' DATA EMISSAO: ' || DATA_EMIS      ||
                            ' DATA_ENTREGA: ' || DATA_ENTREGA   || 
                                ' TOTAL_NF: ' || 0              || 
                           ' INTEGRADA FIN: ' || 'N'            || 
                           ' INTEGRADA SUP: ' || 'N'            );
 
     -- INICIO CURSOR DETALHES NF            
     -- CURSOR DETALHE PED INICIO
     FOR C_NF_IT IN (SELECT A.SEQ_MAT, A.COD_MAT, A.QTD, A.VAL_UNIT
          FROM PED_VENDAS_ITENS A
         WHERE A.NUM_PEDIDO = DOCTO
           AND COD_EMPRESA = P_EMP
         ORDER BY A.SEQ_MAT) LOOP

     	 -- INSERINDO DADOS DO CURSOR FOR C_NF_IT
     	 INSERT INTO NOTA_FISCAL_ITENS (COD_EMPRESA, NUM_NF, SEQ_MAT, COD_MAT, QTD, VAL_UNIT, PED_ORIG)
                -- APRESENTANDO VALORES
                VALUES (P_EMP, V_NUM_NF,C_NF_IT.SEQ_MAT,C_NF_IT.COD_MAT,C_NF_IT.QTD, C_NF_IT.VAL_UNIT, DOCTO );
                  -- ATRIBUINDO VALORES 
                  DBMS_OUTPUT.PUT_LINE ( 'SEQ: ' || C_NF_IT.SEQ_MAT    ||
                                    ' COD MAT: ' || C_NF_IT.COD_MAT    ||
                                        ' QTD: ' || C_NF_IT.QTD        ||
                                   ' VAL UNIT: ' || C_NF_IT.VAL_UNIT   );  
         -- SELECT TOTAL_NF        
         V_TOTAL_NF := V_TOTAL_NF + ( C_NF_IT.QTD * C_NF_IT.VAL_UNIT );

  END LOOP; -- FINAL DO CURSOR DETALHES
      -- FINAL DO CURSOR NF IT
        
     -- ATUALIZANDO TOTAL NFE
     UPDATE NOTA_FISCAL 
        SET TOTAL_NF = V_TOTAL_NF 
      WHERE NUM_NF = V_NUM_NF 
        AND COD_EMPRESA = P_EMP;

     -- ATUALIZANDO STATUS PARA FECHADO NF
     UPDATE PED_VENDAS 
        SET SITUACAO = 'F' 
      WHERE NUM_PEDIDO = DOCTO
        AND COD_EMPRESA = P_EMP;

   END LOOP; -- CURSOR NF CABECALHO
     -- FINAL CURSOR NF

  ELSIF TIP_NF = 'E' THEN

      FOR C_NF IN (SELECT A.COD_EMPRESA, A.NUM_PEDIDO, A.ID_FOR AS ID_CLIFOR, A.COD_PAGTO
      	             FROM PED_COMPRAS A
                    WHERE A.NUM_PEDIDO = DOCTO
                      AND A.COD_EMPRESA = P_EMP
                      AND A.SITUACAO <> 'F' ) LOOP  --FINALIZADO
         
         -- INSERINDO DADOS DO CURSOR FOR
         INSERT INTO NOTA_FISCAL (COD_EMPRESA, NUM_NF, TIP_NF, COD_CFOP, ID_CLIFOR,
                              COD_PAGTO, DATA_EMISSAO, DATA_ENTREGA, TOTAL_NF,
                              INTEGRADA_FIN, INTEGRADA_SUP)
            VALUES (P_EMP, NULL, TIP_NF, CFOP, C_NF.ID_CLIFOR, C_NF.COD_PAGTO, 
            	    DATA_EMIS, DATA_ENTREGA , 0, 'N', 'N')
            RETURNING NUM_NF INTO V_NUM_NF; -- PEGANDO VALOR DO NF INSERIDO E ATRIBUIDO VALOR

            -- APRESENTANDO VALORES CABECALHO
            DBMS_OUTPUT.PUT_LINE( 'NUM_NF:  ' || V_NUM_NF       ||
                                 ' TIPO NF: ' || TIP_NF         ||
                                    ' CFOP: ' || CFOP           ||
                                ' COD CFOP: ' || C_NF.ID_CLIFOR ||  
                               ' COD PAGTO: ' || C_NF.COD_PAGTO ||  
                            ' DATA EMISSAO: ' || DATA_EMIS      ||
                            ' DATA_ENTREGA: ' || DATA_ENTREGA   || 
                                ' TOTAL_NF: ' || 0              || 
                           ' INTEGRADA FIN: ' || 'N'            || 
                           ' INTEGRADA SUP: ' || 'N'            );
 
     -- INICIO CURSOR DETALHES NF            
     -- CURSOR DETALHE PED INICIO
     FOR C_NF_IT IN (SELECT A.SEQ_MAT, A.COD_MAT, A.QTD, A.VAL_UNIT
          FROM PED_COMPRAS_ITENS A
         WHERE A.NUM_PEDIDO = DOCTO
           AND COD_EMPRESA = P_EMP
         ORDER BY A.SEQ_MAT) LOOP

             -- INSERINDO DADOS DO CURSOR FOR C_NF_IT
     	     INSERT INTO NOTA_FISCAL_ITENS (COD_EMPRESA, NUM_NF, SEQ_MAT, COD_MAT, QTD, VAL_UNIT, PED_ORIG)
                -- APRESENTANDO VALORES
                VALUES (P_EMP, V_NUM_NF,C_NF_IT.SEQ_MAT,C_NF_IT.COD_MAT,C_NF_IT.QTD, C_NF_IT.VAL_UNIT, DOCTO );
                  -- ATRIBUINDO VALORES 
                  DBMS_OUTPUT.PUT_LINE ( 'SEQ: ' || C_NF_IT.SEQ_MAT    ||
                                    ' COD MAT: ' || C_NF_IT.COD_MAT    ||
                                        ' QTD: ' || C_NF_IT.QTD        ||
                                   ' VAL UNIT: ' || C_NF_IT.VAL_UNIT   );  
         -- SELECT TOTAL_NF        
         V_TOTAL_NF := V_TOTAL_NF + ( C_NF_IT.QTD * C_NF_IT.VAL_UNIT );

   END LOOP; -- CURSOR NF IT

        -- ATUALIZANDO TOTAL NF
        UPDATE NOTA_FISCAL 
           SET TOTAL_NF = V_TOTAL_NF
         WHERE NUM_NF = V_NUM_NF
           AND COD_EMPRESA = P_EMP;

        -- ATUALIZANDO STATUS PARA FECHADO NF
        UPDATE PED_COMPRAS
           SET SITUACAO = 'F'
         WHERE NUM_PEDIDO = DOCTO
           AND COD_EMPRESA = P_EMP;

   END LOOP;   -- CURSOR NF CABECALHO

      -- FINAL CURSOR NF

END IF;

     COMMIT;
     DBMS_OUTPUT.PUT_LINE('FINALIZADA COM SUCESSO! '); 

 -- VALIDAÇÕES FINAIS

EXCEPTION
   WHEN EXC_LANC_FUTURO THEN
   DBMS_OUTPUT.PUT_LINE('NAO PERMITIDO LANCAMENTO FUTUROS!');
   ROLLBACK;

   WHEN EXC_TIP_NF THEN
   DBMS_OUTPUT.PUT_LINE('OPERACAO NAO PERMITIDA!');
   ROLLBACK;

   WHEN EXC_QTD_PED_VEND THEN
   DBMS_OUTPUT.PUT_LINE('NAO A PEDIDO DE VENDAS DISPONIVEL PARA SAIDA!');
   ROLLBACK;

   WHEN EXC_QTD_PED_COMP THEN
   DBMS_OUTPUT.PUT_LINE('NAO A PEDIDO DE COMPRAS DISPONIVEL PARA ENTRADA!');

   WHEN NO_DATA_FOUND THEN
   DBMS_OUTPUT.PUT_LINE('NAO EXISTE DADOS!');

   WHEN OTHERS THEN
   DBMS_OUTPUT.PUT_LINE ('OUTROS CODIGOS DE ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);
   DBMS_OUTPUT.PUT_LINE ('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
   ROLLBACK;      

END PRC_GERA_NF;


-- SELECT * FROM PED_VENDAS;
-- SELECT * FROM PED_COMPRAS;
-- SELECT * FROM NOTA_FISCAL;
-- SELECT * FROM NOTA_FISCAL_ITENS;

SET SERVEROUTPUT ON

EXECUTE PRC_GERA_NF (2,'S', 1, '5.101', '21/01/2018', '22/01/2018');
EXECUTE PRC_GERA_NF (1,'S', 2, '5.101', '21/01/2018', '22/01/2018');
EXECUTE PRC_GERA_NF (1,'S', 3, '5.101', '21/01/2018', '22/01/2018');
EXECUTE PRC_GERA_NF (1,'S', 4, '5.101', '21/01/2018', '22/01/2018');
EXECUTE PRC_GERA_NF (2,'E', 1, '1.101', '21/01/2018', '22/01/2018');
EXECUTE PRC_GERA_NF (1,'E', 2, '1.101', '21/01/2018', '22/01/2018');
EXECUTE PRC_GERA_NF (1,'E', 3, '1.101', '21/01/2018', '22/01/2018');




