create table t_cron_job (
  id number not null,
  enabled varchar2(1 byte) default on null 'Y' not null,
  caption varchar2(2000 byte) not null,
  operation varchar2(2000 byte) not null,
  next_date date,
  cron varchar2(2000 byte),
  calendar_id number,
  ref_point varchar2(1 byte),
  rerun_delay number,
  lead_id number,
  lead_delay number,
  usid varchar2(24 byte),
  broken varchar2(1 byte) default on null 'N' not null
) logging;

alter table t_cron_job add check (enabled in ('N', 'Y'));
alter table t_cron_job add check (ref_point in ('E', 'S'));
alter table t_cron_job add check (rerun_delay > 0);
alter table t_cron_job add check (lead_delay > 0);
alter table t_cron_job add check (broken in ('N', 'Y'));

comment on table t_cron_job is 'Задание (cron)';
comment on column t_cron_job.id is 'Идентификатор';
comment on column t_cron_job.enabled is 'Включено';
comment on column t_cron_job.caption is 'Описание';
comment on column t_cron_job.operation is 'Процедура выполнения';
comment on column t_cron_job.next_date is 'Время следующего запуска';
comment on column t_cron_job.cron is 'Выражение (cron)';
comment on column t_cron_job.calendar_id is 'Идентификатор календаря';
comment on column t_cron_job.ref_point is 'Точка отсчета времени следующего запуска';
comment on column t_cron_job.rerun_delay is 'Задержка перезапуска при возникновении ошибки';
comment on column t_cron_job.lead_id is 'Идентификатор ведущего задания';
comment on column t_cron_job.lead_delay is 'Задержка запуска после ведущего задания';
comment on column t_cron_job.usid is 'Уникальный идентификатор сессии';
comment on column t_cron_job.broken is 'Приостановлено';

create index cnjb_ld_idx on t_cron_job(lead_id asc) logging;
create unique index cnjb_pk on t_cron_job(id asc) logging;
alter table t_cron_job add constraint cnjb_pk primary key (id) using index cnjb_pk;



create table t_cron_job_log (
  id number not null,
  job_id number not null,
  plan_time date not null,
  start_time date not null,
  end_time date,
  sid number not null,
  serial# number not null,
  audsid number,
  error_text clob
)
logging partition by range (plan_time) interval (numtoyminterval(1, 'month')) (partition values less than (to_date('01.10.2019','dd.mm.yyyy')));

comment on table t_cron_job_log is 'Лог заданий';
comment on column t_cron_job_log.id is 'Идентификатор';
comment on column t_cron_job_log.job_id is 'Идентификатор задания';
comment on column t_cron_job_log.plan_time is 'Планируемое время запуска';
comment on column t_cron_job_log.start_time is 'Время запуска';
comment on column t_cron_job_log.end_time is 'Время завершения';
comment on column t_cron_job_log.sid is 'Идентификатор сессии';
comment on column t_cron_job_log.serial# is 'Порядковый номер сессии';
comment on column t_cron_job_log.audsid is 'Уникальный идентификатор сессии';
comment on column t_cron_job_log.error_text is 'Текст ошибки';

create unique index jblg_jbpe_unq on t_cron_job_log(job_id asc, plan_time asc) logging;
create unique index jblg_pk on t_cron_job_log(id asc) logging;
alter table t_cron_job_log add constraint jblg_pk primary key (id) using index jblg_pk;
alter table t_cron_job add constraint cnjb_cnjb_ld_fk foreign key (lead_id) references t_cron_job(id) on delete set null;
