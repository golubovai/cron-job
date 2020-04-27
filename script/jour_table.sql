create table t_jour_col (
  line_id number(38) not null,
  col_id number(38) not null,
  col_value varchar2(2000 byte),
  constraint jrcl_pk primary key (line_id, col_id)
)
organization index logging partition by list (col_id) (partition empty_lp values (0));
comment on table t_jour_col is 'Журнал изменений полей';
comment on column t_jour_col.line_id is 'Идентификатор изменения';
comment on column t_jour_col.col_id is 'Идентификатор колонки';
comment on column t_jour_col.col_value is 'Значение';


create table t_jour_line (
  line_id number(38) not null, 
  time timestamp not null, 
  tab_id number(8) not null, 
  row_id number not null, 
  col_mask number not null, 
  constraint jrle_pk primary key (tab_id, row_id, time, line_id)
)
organization index logging compress 1 including col_mask overflow logging partition by list (tab_id) (partition empty_lp values (0));

comment on table t_jour_line is 'Изменение журнала';
comment on column t_jour_line.line_id is 'Идентификатор изменения';
comment on column t_jour_line.time is 'Время';
comment on column t_jour_line.tab_id is 'Идентификатор таблицы';
comment on column t_jour_line.row_id is 'Идентифыикатор строки';
comment on column t_jour_line.col_mask is 'Битовая маска измененных колонок';

create index jrle_te_idx on t_jour_line(time asc) logging;


create table t_jour_line_ext ( 
  line_id number(38) not null, 
  time timestamp not null, 
  time_utc timestamp as (sys_extract_utc(time)) virtual, 
  machine varchar2(64 byte), 
  os_user varchar2(128 byte) 
) 
logging partition by range ( time_utc ) interval (numtodsinterval(1, 'day')) (partition values less than (to_date('01.10.2019','dd.mm.yyyy')));

comment on table t_jour_line_ext is 'Информация изменения журнала';
comment on column t_jour_line_ext.line_id is 'Идентификатор изменения';
comment on column t_jour_line_ext.time is 'Время';
comment on column t_jour_line_ext.time_utc is 'Время (Utc)';
comment on column t_jour_line_ext.machine is 'Наименование компьютера пользователя';
comment on column t_jour_line_ext.os_user is 'Имя пользователя операционной системы';

alter table t_jour_line_ext add constraint jrleet_pk primary key (line_id);


create table t_jour_tab ( 
  id number(8) not null, 
  obj# number not null,
  seq number not null default 0
) logging;

comment on table t_jour_tab is 'Таблица журнала';
comment on column t_jour_tab.id is 'Идентификатор';
comment on column t_jour_tab.obj# is 'Идентификатор объекта';
comment on column t_jour_tab.seq is 'Максимальная позиция колонки';

create unique index jrtb_oj_unq on t_jour_tab(obj# asc) logging;
create unique index jrtb_pk on t_jour_tab(id asc) logging ;
alter table t_jour_tab add constraint jrtb_pk primary key (id) using index jrtb_pk;


create table t_jour_tab_col (
  id number(8) not null,
  tab_id number(8) not null,
  seq number(4) not null,
  name varchar2(128 byte) not null,
  read_opt varchar2(1 byte) not null
)
logging;

alter table t_jour_tab_col add check (read_opt in ('N', 'Y'));

comment on table t_jour_tab_col is 'Колонка таблицы журнала';
comment on column t_jour_tab_col.id is 'Идентификатор';
comment on column t_jour_tab_col.tab_id is 'Идентификатор таблицы';
comment on column t_jour_tab_col.seq is 'Позиция';
comment on column t_jour_tab_col.name is 'Наименование';
comment on column t_jour_tab_col.read_opt is 'Оптимизировать для чтения';

create unique index jrtbcl_tbne_unq on t_jour_tab_col (tab_id asc, name asc) logging;
create unique index jrtbcl_pk on t_jour_tab_col (id asc) logging;
create index jrtbcl_tb_idx on t_jour_tab_col (tab_id asc) logging;
alter table t_jour_tab_col add constraint jrtbcl_pk primary key (id) using index jrtbcl_pk;
alter table t_jour_tab_col add constraint jrtbcl_jrtb_tb_fk foreign key (tab_id) references t_jour_tab (id) on delete cascade;
