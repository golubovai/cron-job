create or replace trigger t_job_biut before insert or update of operation, cron, lead_id on t_cron_job for each row
declare
  l_c number;
  l_time date;
begin
  if not dbms_job.is_jobq() then
    if inserting or updating then  
      -- Проверка процедуры выполнения.
      if :old.operation is null or not :new.operation = :old.operation then
        begin
          l_c := dbms_sql.open_cursor();
          dbms_sql.parse(l_c, 'begin ' || :new.operation || ' end;', dbms_sql.native);
          if dbms_sql.is_open(l_c) then
            dbms_sql.close_cursor(l_c);
          end if;
        exception
          when others then
            if dbms_sql.is_open(l_c) then
              dbms_sql.close_cursor(l_c);
            end if;
            pe_cron_job.throw(20, 'Ошибка в процедуре выполнения: ' || dbms_utility.format_error_stack);
        end;
      end if;
      -- Проверка выражения (cron).
      if not :new.cron is null and (:old.cron is null or not :new.cron = :old.cron) then
        begin
          l_time := pe_cron_job.next_date(sysdate, :new.cron, p_calendar_id => :new.calendar_id);
        exception
          when others then
            pe_cron_job.throw(21, 'Ошибка в выражении (cron): ' || dbms_utility.format_error_stack);
        end;
      end if;
    end if;
  end if;
end;
/
