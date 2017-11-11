-- executar script abaixo conectado com SYS:
SET SERVEROUTPUT ON
DECLARE
    v_cont NUMBER;              -- var contador do loop
    v_h1 NUMBER;                -- var para recuperar identificador do job do Data Pump    
    v_job_state VARCHAR2(30);   -- var para manter rastreamento do estado do job
    v_le ku$_LogEntry;          -- var para controlar mensagens de erro progresso do job
    v_js ku$_JobStatus;         -- var para controlar o status do job
    v_jd ku$_JobDesc;           -- var para verificar descricao do job
    v_sts ku$_Status;           -- var para verificar status de objetos sendo exportados
    v_job_name VARCHAR2(10) := 'EXP_HR1'; -- nome do job do export
BEGIN
    -- Criando o job do Data Pump para fazer um export de SCHEMA:
    v_h1 := DBMS_DATAPUMP.OPEN(OPERATION => 'EXPORT', JOB_MODE => 'SCHEMA', REMOTE_LINK => NULL, JOB_NAME => v_job_name, VERSION => 'LATEST');

    -- Especificando o nome do job do DIRETORIO onde o dump sera gerado:
    DBMS_DATAPUMP.ADD_FILE(HANDLE => v_h1, FILENAME => v_job_name || '.dmp', DIRECTORY => 'DP_DIR');

    -- Filtrando somente schema HR:
    DBMS_DATAPUMP.METADATA_FILTER(HANDLE => v_h1, NAME => 'SCHEMA_EXPR', VALUE => 'IN (''HR'')');

    -- Inicializando o job de export em modo assincrono:
    DBMS_DATAPUMP.START_JOB(HANDLE => v_h1);
        
    v_job_state := 'UNDEFINED';
    -- Monitorando a execucao do job ate que ele termine: 
    while (v_job_state != 'COMPLETED') and (v_job_state != 'STOPPED') loop
        dbms_datapump.get_status(v_h1, dbms_datapump.ku$_status_job_error +
                            dbms_datapump.ku$_status_job_status + dbms_datapump.ku$_status_wip,-1,v_job_state,v_sts);
        v_js := v_sts.job_status;

        -- exibe mensagem enquanto o trabalho do job estiver progredindo ou erros ocorrerem: 
        if (bitand(v_sts.mask,dbms_datapump.ku$_status_wip) != 0)then
            v_le := v_sts.wip;
        else
            if (bitand(v_sts.mask,dbms_datapump.ku$_status_job_error) != 0) then
                v_le := v_sts.error;
            else
                v_le := null;
            end if;
        end if;
    
        if v_le is not null then
            v_cont := v_le.FIRST;
            
            while v_cont is not null 
            loop
                dbms_output.put_line(v_le(v_cont).LogText);
                v_cont := v_le.NEXT(v_cont);
            end loop;
        end if;
    end loop;  -- termino do loop de monitoramento
    
    -- exibe mensagem notificando que a execucao do job terminou:
    dbms_output.put_line('O job terminou com o estado: ' || v_job_state);
    dbms_datapump.detach(HANDLE => v_h1);
END;