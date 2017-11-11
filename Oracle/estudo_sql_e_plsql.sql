
-- CRIAÇÃO DAS TABELAS

CREATE TABLE marca(
    id_marca NUMBER(7) CONSTRAINT pk_marca PRIMARY KEY,
    nome_marca VARCHAR2(120) NOT NULL UNIQUE,
    ativo CHAR(1) NOT NULL,
    CONSTRAINT marca_ativo CHECK(ativo IN('S','s','N','n'))
);

-- CRIAÇÃO SEQUENCE

CREATE SEQUENCE seq_Id_marca
     START WITH 100
     INCREMENT BY 10
     NOCYCLE
     NOCACHE;
     
     

-- CRIAÇÃO TABELA MODELO

CREATE TABLE modelo(
    id_marca NUMBER(7) NOT NULL,
    id_modelo NUMBER(7) NOT NULL,
    nome_modelo VARCHAR2(102) NOT NULL UNIQUE,
    ativo CHAR(1),
    CONSTRAINT modelo_ativo CHECK(ativo IN('S','s','N','n')),
    CONSTRAINT fk_tbl_marca FOREIGN KEY (id_marca) REFERENCES marca(id_marca),
    CONSTRAINT pk_modelo PRIMARY KEY (id_marca, id_modelo)
);

-- CRIAÇÃO TABELA VERSAO

CREATE TABLE versao(
    id_marca NUMBER(7) NOT NULL,
    id_modelo NUMBER(7) NOT NULL,
    id_versao NUMBER(7) NOT NULL,
    nome_versao VARCHAR2(102) NOT NULL UNIQUE,
    ativo CHAR(1),
    CONSTRAINT versao_ativo CHECK(ativo IN('S','s','N','n')),
    CONSTRAINT fk_tbl_modelo FOREIGN KEY (id_marca, id_modelo) 
               REFERENCES modelo(id_marca, id_modelo),
    CONSTRAINT pk_versao PRIMARY KEY (id_marca, id_modelo, id_versao)
);


INSERT INTO marca(id_marca, nome_marca, ativo)  
VALUES (seq_id_marca.nextval, 'FIAT', 'N');

SELECT * FROM marca;

INSERT INTO modelo(id_marca, id_modelo, nome_modelo, ativo)
 VALUES (100, 1, 'UNO', 'N');

SELECT * FROM modelo;


--CRIAÇÃO PROCEDURE INSERIR VEICULO
--*****************************************************************************
CREATE OR REPLACE PROCEDURE prc_inserir_veiculo (
      par_marca IN hr.marca.nome_marca%type,
      par_modelo IN hr.modelo.nome_modelo%type,
      par_versao IN hr.versao.nome_versao%type
      )
IS
vcount_marca NUMBER;
vcount_modelo NUMBER;
vcount_versao_marca NUMBER;
vcount_versao_modelo NUMBER;

vid_marca NUMBER;
vid_modelo NUMBER := 0;
vid_versao NUMBER := 0;

BEGIN
/*INSERIR O NOME DA MARCA NA TABELA MARCA*/
   SELECT COUNT(*) INTO vcount_marca FROM marca
    WHERE nome_marca = par_marca;
    
    IF vcount_marca = 0 THEN
        SELECT seq_id_marca.nextval INTO vid_marca FROM dual;
        INSERT INTO marca (id_marca, nome_marca, ativo)
         VALUES (vid_marca, par_marca, 'N');
          COMMIT;
     ELSE 
         SELECT id_marca INTO vid_marca FROM marca 
          WHERE nome_marca = par_marca;    
     END IF;
    
/*INSERIR O NOME DA MODELO NA TABELA MODELO*/    
  SELECT COUNT(*) INTO vcount_modelo FROM modelo
    WHERE id_marca = par_marca AND nome_mdoelo = par_modelo;
    
    IF vcount_modelo = 0  THEN
        SELECT MAX(id_modelo) INTO vid_modelo FROM modelo 
         WHERE id_marca = vid_marca;
         vid_modelo := NVL(vid_modelo, 0) + 1;
         INSERT INTO modelo(id_marca, id_modelo, nome_modelo, ativo)
         VALUES (vid_marca, vid_modelo, par_modelo, 'N');
         COMMIT;
     ELSE
        SELECT id_modelo INTO vid_modelo FROM modelo 
        WHERE nome_modelo = par_modelo;    
    END IF;

/*INSERIR O NOME DA VERSAO NA TABELA VERSAO*/
   SELECT COUNT(*) INTO vcount_versao_marca FROM versao
    WHERE id_marca = vid_marca AND nome_versao = par_versao;
   SELECT COUNT(*) INTO vcount_versao_modelo FROM versao
    WHERE id_modelo = vid_modelo AND nome_versao = par_versao;
    
    IF vcount_versao_marca = 0 THEN
        SELECT MAX(id_versao) INTO vid_versao FROM versao
         WHERE id_marca = vid_marca;
         vid_versao := NVL(vid_versao, 0) + 1;
           INSERT INTO versao(id_marca, id_modelo, id_versao, nome_versao, ativo)
           VALUES (vid_marca, vid_modelo, vid_versao, par_versao, 'N');
           COMMIT;
         
      ELSE IF vcount_versao_modelo = 0 THEN
        SELECT MAX(id_versao) INTO vid_versao FROM versao
         WHERE id_marca = vid_marca and nome_versao = par_versao;
           INSERT INTO versao(id_marca, id_modelo, id_versao, nome_versao, ativo)
           VALUES (vid_marca, vid_modelo, vid_versao, par_versao, 'N');
           COMMIT;     
       END IF;    
    END IF;

END proc_inserir_veiculo;


/*EXECUTANDO A PROCEDURE*/
SELECT * FROM marca;
SELECT * FROM modelo ORDER BY id_marca;
SELECT * FROM versao;

SELECT nome_marca, nome_modelo, id_modelo, nome_versao, id_versao
  FROM versao 
  NATURAL JOIN marca
  NATURAL JOIN modelo
  ORDER BY nome_modelo, id_versao;

/*EXECUTANDO A PROCEDURE SOMENTE COM A MARCA*/
BEGIN
 PROC_INSERIR_VEICULO('FORD');
END;

BEGIN
 PROC_INSERIR_VEICULO('GM');
END;

/*EXECUTANDO A PROCEDURE COM A MARCA E MODELO*/
BEGIN
 PROC_INSERIR_VEICULO('FORD', 'FIESTA');
END;



/*EXECUTANDO A PROCEDURE MARCA, MODELO E VERSAO*/
BEGIN
 PROC_INSERIR_VEICULO('FORD', 'ESCORT','XL');
END;

BEGIN
 PROC_INSERIR_VEICULO('VOLKSWAGEN', 'GOL','G5');
END;

-- TABELAS
--*****************************************************************************
--PRODUTO

CREATE TABLE produto (
    pro_in_codigo NUMBER(8) NOT NULL,
    pro_st_nome VARCHAR2(40) NOT NULL,
    pro_st_marca VARCHAR2(20),
    pro_dt_inclusao DATE,
    pro_st_usuarioinclusao varchar(50),
    pro_dt_ultimavenda DATE,
    pro_vl_ultimavenda  NUMBER(9,2),
    pro_dt_mariovenda DATE,
    pro_dt_maiorvenda   NUMBER(9,2)
);


CREATE TABLE preco_produto (
    ppr_st_tipopreco VARCHAR2(100),
    pro_in_codigo INTEGER,
    ppr_vl_unitario NUMBER (9,2),
    CONSTRAINT pk_ppr_st_tipopreco PRIMARY KEY (ppr_st_tipopreco)
);



--SQL LIVE PARA EXECUTAR ESSA PROCEDURE
--*****************************************************************************
DECLARE

CURSOR cur_employee(c_id_employee hr.employees.employee_id%type)
IS
 SELECT employee_id, first_name, salary
   FROM hr.employees
   WHERE employee_id = c_id_employee;


v_id_employee   hr.employees.employee_id%type;
v_first_name    hr.employees.first_name%type;
v_salary        hr.employees.salary%type;


BEGIN
OPEN cur_employee(102);
FETCH cur_employee INTO v_id_employee, v_first_name, v_salary;

CLOSE cur_employee;


DBMS_OUTPUT.PUT_LINE('O codigo do empregado é: '|| v_id_employee);
DBMS_OUTPUT.PUT_LINE('O Nome do empregado é: '|| v_first_name);
DBMS_OUTPUT.PUT_LINE('O Salario do empregado é: '|| v_salary);
DBMS_OUTPUT.PUT_LINE('_____________________________________________ ');
DBMS_OUTPUT.PUT_LINE('');
END;


--******************************************************************************


DECLARE

CURSOR cur_employee
IS
 SELECT employee_id, first_name, salary
   FROM hr.employees;
   
v_id_employee   hr.employees.employee_id%type;
v_first_name    hr.employees.first_name%type;
v_salary        hr.employees.salary%type;

BEGIN

FOR ret_employee IN cur_employee  LOOP



CREATE OR REPLACE PROCEDURE teste IS
  
v_employee_id NUMBER;
  
  CURSOR cur_ret_employees
  IS SELECT employee_id, first_name, last_name, salary
       FROM employees
     WHERE employee_id IN (100,102,101);
 
BEGIN
  v_employee_id := 100;
  
  FOR r_employees IN cur_ret_employees LOOP
    
    IF r_employees.employee_id = 100 THEN
       DBMS_OUTPUT.put_line('EMPLOYEE 100');
    END IF;
    DBMS_OUTPUT.put_line('Outro');
  END LOOP;
END;


EXEC teste;



-- PACKAGES
--------------------------------------------------------------------------------
 
 CREATE OR REPLACE PACKAGE funcionario AS
    -- get nome completo do funcionario
    FUNCTION get_nomeCompleto(n_func_id NUMBER)
      RETURN VARCHAR2;
    -- get salario do funcionario
    FUNCTION get_salario(n_func_id NUMBER)
      RETURN NUMBER;
  END funcionario;
  
  
  /*
    Package funcionario body
  */
  CREATE OR REPLACE PACKAGE BODY funcionario AS
    -- get funcionário nomeCompleto
    FUNCTION get_nomeCompleto(n_func_id NUMBER) RETURN VARCHAR2 IS
        v_nomeCompleto VARCHAR2(46);
    BEGIN
      SELECT first_name || ', ' ||  last_name
      INTO v_nomeCompleto
      FROM hr.employees
      WHERE employee_id = n_func_id;
   
      RETURN v_nomeCompleto;
   
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('Funcionario não encontrado!!');
      RETURN NULL;
    WHEN TOO_MANY_ROWS THEN
      RETURN NULL;
    END; 
    
    -- end get_nomeCompleto
   
    -- get salario
    FUNCTION get_salario(n_func_id NUMBER) RETURN NUMBER IS
      n_salario NUMBER(8,2);
    BEGIN
      SELECT salary
      INTO n_salario
      FROM hr.employees
      WHERE employee_id = n_func_id;
   
      RETURN n_salario;
   
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          dbms_output.put_line('Salario não encontrado!!');
          RETURN NULL;
        WHEN TOO_MANY_ROWS THEN
          RETURN NULL;
    END;
  END funcionario;



SET SERVEROUTPUT ON SIZE 1000000;
  DECLARE
    n_salario NUMBER(8,2);
    v_nome   VARCHAR2(46);
    n_func_id NUMBER := &empresa_id;
  BEGIN
   
    v_nome   := funcionario.get_nomeCompleto(n_func_id);
    n_salario := funcionario.get_salario(n_func_id);
   
    IF v_nome  IS NOT NULL AND
      n_salario IS NOT NULL
    THEN
      dbms_output.put_line('Funcionário: ' || v_nome);
      dbms_output.put_line('Recebe salário = ' || n_salario);
    END IF;
  END;
  
  
  --TRIGGER
 ------------------------------------------------------------------------------- 
  
CREATE OR REPLACE TRIGGER jobs_biud

BEFORE INSERT OR UPDATE OR DELETE ON jobs

BEGIN

  IF TO_CHAR (SYSDATE, 'HH24') NOT BETWEEN '08' AND '18' THEN
     RAISE_APPLICATION_ERROR(-20205,'Alterações são permitidas apenas no horário de expediente');
  END IF;

END jobs_biud;


-- TRIGGER
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER employees_biud

BEFORE INSERT OR UPDATE OR DELETE ON hr.employees

BEGIN

  IF (TO_CHAR (SYSDATE,'HH24') NOT BETWEEN '08' AND '18') THEN
     IF DELETING THEN 
         RAISE_APPLICATION_ERROR(-20502,'Deleções na tabela de empregados apenas no horario comercial');
        ELSIF INSERTING THEN
            RAISE_APPLICATION_ERROR(-20502,'Inserções na tabela de empregados apenas no horario comercial');
        ELSIF UPDATING('SALARY') THEN
            RAISE_APPLICATION_ERROR(-20502,'Alterações no salário apenas no horario comercial');
        ELSE
            RAISE_APPLICATION_ERROR(-20504,'Alterações nos empregados apenas no horario comercial');
     END IF;
END IF;

END employees_biud;

UPDATE hr.employees SET salary = 5000 WHERE employee_id = 105;

SELECT * FROM hr.employees WHERE employee_id = 105;


--TRIGGER
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER employees_biur

BEFORE  INSERT OR UPDATE ON employees

 FOR EACH ROW

  BEGIN
    IF NOT (:NEW.job_id IN ('AD_PRES', 'AD_VP')) THEN
       IF :NEW.salary > 15000 THEN
            RAISE_APPLICATION_ERROR (-20202,'Este empregado não pode receber este valor');
       END IF;
     END IF;
  END employees_biur;


--TRIGGER PARA AUDITORIA
--------------------------------------------------------------------------------

create table hr.dept_audit
   ( userid          varchar2(30)
    ,timestamp       date
    ,tipo_dml        CHAR(1)
    ,old_dept_id     NUMBER
    ,old_name        varchar2(30)
    ,old_manager_id  number
    ,old_location_id number
    ,new_dept_id     NUMBER
    ,new_name        varchar2(30)
    ,new_manager_id  number
    ,new_location_id number
     );


CREATE OR REPLACE TRIGGER hr.department_aiudr

 AFTER INSERT OR UPDATE OR DELETE ON hr.departments
   FOR EACH ROW
     DECLARE
        v_DML dept_audit.tipo_dml%TYPE;
     BEGIN
       IF INSERTING THEN 
           v_DML := 'I';
         ELSIF DELETING THEN
           v_DML := 'D';
         ELSIF UPDATING THEN
           v_DML := 'U';
       END IF;
       
   INSERT INTO dept_audit
         (userid              , timestamp            , tipo_dml 
         ,old_dept_id         , old_name             , old_manager_id
         ,old_location_id     , new_dept_id          , new_name
         ,new_manager_id      , new_location_id )

    VALUES (USER , SYSDATE , v_DML 
         ,:OLD.department_id  ,:OLD.department_name  ,:OLD.manager_id 
         ,:OLD.location_id    ,:NEW.department_id    ,:NEW.department_name
         ,:NEW.manager_id     ,:NEW.location_id);
 END;



--INSERIR UM DEPARTAMENTO

INSERT INTO hr.departments(department_id, department_name, manager_id, location_id)
 VALUES (280, 'departament_teste',205, 1700);

 
 -------------------------------------------------------------------------------
 
 
CREATE OR REPLACE TRIGGER regions_bir
   BEFORE INSERT ON regions
     FOR EACH ROW
     DECLARE

       v_region_id regions.region_id%TYPE;

     BEGIN
       SELECT MAX(region_id)+1 INTO v_region_id
         FROM regions; 
         
      :NEW.region_id := v_region_id;

END regions_bir;





--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER derive_commission_pct
    BEFORE INSERT OR UPDATE OF salary ON employees
      FOR EACH ROW
         WHEN (NEW.job_id = 'SA_REP')
       BEGIN
         IF INSERTING THEN 
            :NEW.commission_pct := 0;
           ELSIF :OLD.commission_pct IS NULL THEN 
             :NEW.commission_pct := 0;
         ELSE 
            :NEW.commission_pct := :OLD.commission_pct + 0.05;
         END IF;
       END;






--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER employees_biud

BEFORE INSERT OR UPDATE OR DELETE ON hr.employees

BEGIN

  IF (TO_CHAR (SYSDATE,'HH24') BETWEEN '08' AND '18') THEN
     IF DELETING THEN 
         RAISE_APPLICATION_ERROR(-20502,'Deleções na tabela de empregados apenas no horario comercial');
        ELSIF INSERTING THEN
            RAISE_APPLICATION_ERROR(-20502,'Inserções na tabela de empregados apenas no horario comercial');
        ELSIF UPDATING('SALARY') THEN
            RAISE_APPLICATION_ERROR(-20502,'Alterações no salário apenas no horario comercial');
        ELSE
            RAISE_APPLICATION_ERROR(-20504,'Alterações nos empregados apenas no horario comercial');
     END IF;
END IF;

END employees_biud;

SELECT TO_CHAR(SYSDATE,'MON, DAY DD/MM/YYYY:HH24:MI:SS') FROM DUAL;

UPDATE hr.employees SET salary = 5000 WHERE employee_id = 105;


SELECT * FROM dept_audit;

SELECT * FROM hr.departments;



create table hr.dept_audit
   ( userid          varchar2(30)
    ,timestamp       date
    ,tipo_dml        CHAR(1)
    ,old_dept_id     NUMBER
    ,old_name        varchar2(30)
    ,old_manager_id  number
    ,old_location_id number
    ,new_dept_id     NUMBER
    ,new_name        varchar2(30)
    ,new_manager_id  number
    ,new_location_id number
     );


CREATE OR REPLACE TRIGGER hr.department_aiudr

 AFTER INSERT OR UPDATE OR DELETE ON hr.departments
   FOR EACH ROW
     DECLARE
        v_DML dept_audit.tipo_dml%TYPE;
     BEGIN
       IF INSERTING THEN 
           v_DML := 'I';
         ELSIF DELETING THEN
           v_DML := 'D';
         ELSIF UPDATING THEN
           v_DML := 'U';
       END IF;
       
   INSERT INTO dept_audit
         (userid              , timestamp            , tipo_dml 
         ,old_dept_id         , old_name             , old_manager_id
         ,old_location_id     , new_dept_id          , new_name
         ,new_manager_id      , new_location_id )

    VALUES (USER , SYSDATE , v_DML 
         ,:OLD.department_id  ,:OLD.department_name  ,:OLD.manager_id 
         ,:OLD.location_id    ,:NEW.department_id    ,:NEW.department_name
         ,:NEW.manager_id     ,:NEW.location_id);
 END;

INSERT INTO hr.departments(department_id, department_name, 
                           manager_id, location_id)
 VALUES (280, 'departament_teste',200, 1800);
 
UPDATE hr.departments SET manager_id = 201 WHERE department_id = 280;
 
 DELETE FROM hr.departments WHERE department_id = 280;
 
 
 SELECT * FROM hr.departments
 
 SELECT * FROM  hr.dept_audit WHERE old_dept_id = 280 or new_dept_id = 280;





















