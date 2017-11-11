-- Ver informacoes sobre o(s) backup(s) executado(s) no dia atual. Contem as seguintes informacoes: nome do BD, status do backup (sucesso, falha ou "em execução"), horario de inicio e fim dos backups, tempo de duração dos backups.

select      db.name, 
            jb.start_time, 
            jb.end_time, 
            jb.time_taken_display, 
            jb.input_type, 
            jb.status
from        rman.rc_database db  -- contem BDs registrados no catalogo
left join   rman.rc_rman_backup_job_details jb -- detalhes de rotinas de backup executadas pelo RMAN
   on       db.db_key = jb.db_key 
   and      jb.end_time >= trunc(sysdate) -- apenas dia atual
where      nvl(jb.input_type, 'NULL') <> 'ARCHIVELOG' -- exluir backup de archive
order      by db.name, jb.end_time desc
