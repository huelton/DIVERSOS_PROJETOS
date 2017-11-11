--1: Configure o ORACLE_SID do BD em que sera criado o catalogo e conecte-se nele:
$> export ORACLE_SID=orcl
$> sqlplus / a sysdba

--2: Crie um tablespace para o catalogo do RMAN:
SQL> create tablespace RMAN_D datafile 'rman.dbf' size 100M
        AUTOEXTEND ON NEXT 100M MAXSIZE 10G;

--3: Crie um usuario para o catalogo do RMAN com os devidos privilegios:
SQL> CREATE USER RMAN IDENTIFIED BY rman DEFAULT TABLESPACE RMAN_D QUOTA UNLIMITED ON RMAN_D;
SQL> GRANT RECOVERY_CATALOG_OWNER TO RMAN;

-- 4: Saia do SQLPlus, conecte-se no rman e crie o catalogo:
SQL>  exit
$     rman catalog rman/rman
RMAN> CREATE CATALOG;

-- 5: Conecte-se no target e registre-o no catalogo:
RMAN> CONNECT TARGET /
RMAN> REGISTER DATABASE;
RMAN> EXIT

-- 6: testando conexao no target + catalogo simultaneamente:
RMAN> rman target / catalog rman/rman