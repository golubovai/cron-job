create or replace trigger t_job_aiudt after insert or update or delete of enabled, operation, next_date, broken on t_cron_job for each row
declare
  l_cron_job t_cron_job%rowtype;
begin
  if not dbms_job.is_jobq() then
    l_cron_job.id := :new.id;
    l_cron_job.enabled := :new.enabled;
    l_cron_job.next_date := :new.next_date;
    l_cron_job.usid := :new.usid;
    l_cron_job.broken := :new.broken;
    pe_cron_job.sync_job(l_cron_job); -- Синхронизация данных задания.
  end if;
end;
/
