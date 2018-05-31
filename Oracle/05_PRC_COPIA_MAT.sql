-- PROCEDURE PARA COPIA DE MATERIAL

CREATE OR REPLACE PROCEDURE PRC_COPIA_MAT (V_EMP_DE IN NUMBER, 
  V_EMP_PARA IN NUMBER,
  V_MAT IN NUMBER)
IS
  -- EXCESSOES
  V_EXECPT_EMP_DE EXCEPTION;
  V_EXECPT_EMP_PARA EXCEPTION;
  V_EXECPT_EMP_MAT_DE EXCEPTION;
  V_EXECPT_EMP_MAT_PARA EXCEPTION;

  -- VARIAVEIS DE APOIO CONTROLE
  V_CONT_EMP_DE NUMBER;
  V_CONT_EMP_PARA NUMBER;
  V_CONT_EMP_MAT_DE NUMBER;
  V_CONT_EMP_MAT_PARA NUMBER;

  BEGIN
     --VERIFICA SE EMPRESA ORIGEM EXISTE (DE)
     SELECT COUNT(*) QTD 
     INTO V_CONT_EMP_DE 
     FROM EMPRESA 
     WHERE COD_EMPRESA=V_EMP_DE;

     IF(V_CONT_EMP_DE = 0) THEN
     RAISE V_EXECPT_EMP_DE;
     END IF;
     
     --VERIFICA SE EMPRESA DESTINO EXISTE (PARA)
     SELECT COUNT(*) QTD 
     INTO V_CONT_EMP_PARA 
     FROM EMPRESA 
     WHERE COD_EMPRESA=V_EMP_PARA;
     
     IF(V_CONT_EMP_PARA = 0) THEN
     RAISE V_EXECPT_EMP_PARA;
     END IF;

     --VERIFICA SE O MATERIAL ORIGEM EXISTE
     SELECT COUNT(*) QTD 
     INTO V_CONT_EMP_MAT_DE 
     FROM MATERIAL 
     WHERE COD_EMPRESA=V_EMP_DE
     AND COD_MAT = V_MAT;
     
     IF(V_CONT_EMP_MAT_DE = 0) THEN
     RAISE V_EXECPT_EMP_MAT_DE;
     END IF;
     
     --VERIFICA SE O MATERIAL DESTINO EXISTE
     SELECT COUNT(*) QTD 
     INTO V_CONT_EMP_MAT_PARA 
     FROM MATERIAL 
     WHERE COD_EMPRESA = V_EMP_PARA
     AND COD_MAT = V_MAT;

     IF(V_CONT_EMP_MAT_PARA = 1) THEN
     RAISE V_EXECPT_EMP_MAT_PARA;
     END IF;        
     
     INSERT INTO MATERIAL 
     SELECT V_EMP_PARA, COD_MAT, DESCRICAO,
     PRECO_UNIT, COD_TIP_MAT
     FROM MATERIAL
     WHERE COD_MAT = V_MAT 
     AND COD_EMPRESA = V_EMP_DE;  
     
     COMMIT;
     
     DBMS_OUTPUT.PUT_LINE('COPIA REALIZADA COM SUCESSO');
     
     EXCEPTION
     WHEN V_EXECPT_EMP_DE THEN
     DBMS_OUTPUT.PUT_LINE('ATENCAO! EMPRESA ORIGEM NAO EXISTE');
     
     WHEN V_EXECPT_EMP_PARA THEN
     DBMS_OUTPUT.PUT_LINE('ATENCAO! EMPRESA DESTINO NAO EXISTE');
     
     WHEN V_EXECPT_EMP_MAT_DE THEN
     DBMS_OUTPUT.PUT_LINE('ATENCAO! MATERIAL NAO EXISTE NA EMPRESA ORIGEM');
     
     WHEN V_EXECPT_EMP_MAT_PARA THEN
     DBMS_OUTPUT.PUT_LINE('ATENCAO! MATERIAL JA EXISTE NA EMPRESA DESTINO');
     WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('OCORREU UM ERRO - '||SQLCODE||' -ERROR- '||SQLERRM);

     END;


     SET SERVEROUTPUT ON

     EXECUTE PRC_COPIA_MAT (9,1,1);
     EXECUTE PRC_COPIA_MAT (1,9,1);
     EXECUTE PRC_COPIA_MAT (1,2,99);
     EXECUTE PRC_COPIA_MAT (1,2,1);
     EXECUTE PRC_COPIA_MAT (1,2,2);
     EXECUTE PRC_COPIA_MAT (1,2,3);


     SELECT * FROM ALL_ERRORS;

     SELECT * FROM MATERIAL;