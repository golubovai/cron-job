create or replace package pe_jour
is

  type te_row_t is table of varchar2(2000) index by varchar2(128);

  /**
   * Сброс индексов данных изменения таблиц и колонок журнала.
   * @param p_obj# Идентификатор объекта таблицы.
   */
  procedure clear(p_obj# in number);
  
  /**
   * Запись изменений журнала.
   */
  procedure flush;

  /**
   * Добавление изменения строки.
   * @param p_row_id Идентификатор строки.
   * @param p_time Время изменения.
   * @param p_tab_id Идентификатор таблицы.
   */
  procedure put_line(p_row_id in number, p_time in timestamp);

  /**
   * Добавление изменения колонки.
   * @param p_col_name Наименование колонки.
   * @param p_b Значение до изменения.
   * @param p_a Значение после изменения.
   * @param p_ch Признак изменения колонки.
   */
  procedure put_col(p_col_name in varchar2, p_b in varchar2, p_a in varchar2, p_ch in varchar2);
  
  procedure put_col_char(p_col_name in varchar2, p_b in char, p_a in char, p_ch in varchar2);

  procedure put_col_raw(p_col_name in varchar2, p_b in raw, p_a in raw, p_ch in varchar2);
  
  procedure put_col_rowid(p_col_name in varchar2, p_b in rowid, p_a in rowid, p_ch in varchar2);

  procedure put_col(p_col_name in varchar2, p_b in number, p_a in number, p_ch in varchar2);
  
  procedure put_col(p_col_name in varchar2, p_b in date, p_a in date, p_ch in varchar2);
  
  procedure put_col(p_col_name in varchar2, p_b in urowid, p_a in urowid, p_ch in varchar2);
  
  procedure put_col(p_col_name in varchar2, p_b in time_unconstrained, p_a in time_unconstrained, p_ch in varchar2);
  
  procedure put_col(p_col_name in varchar2, p_b in timestamp_tz_unconstrained, p_a in timestamp_tz_unconstrained, p_ch in varchar2);
  
  procedure put_col(p_col_name in varchar2, p_b in timestamp_ltz_unconstrained, p_a in timestamp_ltz_unconstrained, p_ch in varchar2);
  
  procedure put_col(p_col_name in varchar2, p_b in dsinterval_unconstrained, p_a in dsinterval_unconstrained, p_ch in varchar2);
  
  procedure put_col(p_col_name in varchar2, p_b in yminterval_unconstrained, p_a in yminterval_unconstrained, p_ch in varchar2);
  
  /**
   * Добавление партиции в таблицу.
   * @param p_tab_name Наименование таблицы.
   * @param p_value Значение.
   */
  procedure put_partition(p_tab_name in varchar2, p_value in number);

  /**
   * Удаление партиции из таблицы.
   * @param p_tab_name Наименование таблицы.
   * @param p_value Значение.
   */  
  procedure drop_partition(p_tab_name in varchar2, p_value in number);

  /**
   * Создание триггера.
   * @param p_tab_name Наименование таблицы.
   * @param p_sync Синхронизация или установка.
   * @param p_init Инициализация начальных значений колонок таблицы.
   */
  procedure set_trigger(p_tab_name in varchar2, 
                        p_sync in boolean default false,
                        p_init in boolean default true);
  
  /**
   * Удаление триггера.
   * @param p_tab_name Наименование таблицы.
   * @param p_sync Синхронизация или установка.
   * @param p_init Инициализация начальных значений колонок таблицы.
   */
  procedure drop_trigger(p_tab_name in varchar2);
  
  /**
   * Получение идентификатора объекта таблицы.
   * @param p_tab_name Наименование таблицы.
   * @return Идентификатор объекта таблицы.
   */
  function get_tab_obj#(p_tab_name in varchar2) return number;
  
  /**
   * Получение идентификатора таблицы.
   * @param p_tab_name Наименование таблицы.
   * @return Идентификатор таблицы.
   */
  function get_tab_id(p_tab_name in varchar2) return number;
  
  /**
   * Получить идентификатор колонки.
   * @param p_tab_obj# Идентификатор объекта таблицы.
   * @param p_col_name Наименование колонки.
   * @return Идентификатор колонки.
   */
  function get_col_id(p_tab_obj# in number, p_col_name in varchar2) return number;
  
  /**
   * Получить значение колонки строки на момент времени.
   * @param p_tab_id Идентификатор таблицы.
   * @param p_col_id Идентификатор колонки.
   * @param p_row_id Идентификатор строки.
   * @param p_time Время.
   */
  function get_col_val_(p_tab_id in number, p_col_id in number, p_row_id in number, p_time in timestamp with time zone) return varchar2;
  
  /**
   * Получить значение колонки строки на момент времени.
   * @param p_tab_name Наименование таблицы.
   * @param p_col_name Наименование колонки.
   * @param p_row_id Идентификатор строки.
   * @param p_time Время.
   */
  function get_col_val(p_tab_name in varchar2, p_col_name in varchar2, p_row_id in number, p_time in timestamp with time zone) return varchar2;
  
  /**
   * Получение значений колонок строки на момент времени.
   * @param p_tab_name Наименование таблицы.
   * @param p_row_id Идентификатор строки.
   * @param p_time Время.
   */
  function get_row_val(p_tab_name in varchar2, p_row_id in number, p_time in timestamp with time zone) return te_row_t;
  
end;
/
create or replace package body pe_jour
is

  c_sec constant number := 1/86400;
  
  c_schema constant varchar2(128) := sys_context('userenv', 'current_schema');
  
  -- Форматы данных.
  c_number_format constant varchar2(3) := 'tm9';
  c_date_format constant varchar2(12) := 'yyyydddsssss';
  c_timestamp_format constant varchar2(16) := 'yyyydddsssssxff9';
  c_timestamp_tz_format constant varchar2(23) := 'yyyydddsssssxff9tzh:tzm';
  
  -- Идентификация субъекта.
  g_machine varchar2(64) := sys_context('userenv', 'host');
  g_os_user varchar2(128) := sys_context('userenv', 'os_user');

  -- Данные изменений таблиц журнала.
  type te_val_t is table of t_jour_val%rowtype index by pls_integer;
  g_val t_jour_val%rowtype;
  g_val_t te_val_t;
  g_idx pls_integer;
  g_val_idx pls_integer;
  g_obj# number;
  
  -- Время жизни данных.
  c_tab_lt constant number := 15 * c_sec;
  -- Данные колонок таблиц журнала.
  type te_tab_col_t is table of t_jour_tab_col%rowtype index by varchar2(192);
  g_tab_col_t te_tab_col_t;
  -- Время повторной инициализации.
  type te_tab_exp_t is table of date index by varchar2(64);
  g_tab_exp_t te_tab_exp_t;
  
  /**
   * Вызов исключения.
   * @param p_n Номер ошибки.
   * @param p_message Сообщение.
   */
  procedure throw(p_n in binary_integer, p_message in varchar2)
  is
  begin
    raise_application_error(-22000 - p_n, p_message, true);
  end;
  
  /**
   * Операции сравнения базовых типов.
   */
  function equal(p_a in varchar2 character set any_cs, p_b in varchar2 character set any_cs) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal_char(p_a in char character set any_cs, p_b in char character set any_cs) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal_raw(p_a in raw, p_b in raw) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal_rowid(p_a in rowid, p_b in rowid) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in number, p_b in number) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in date, p_b in date) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in urowid, p_b in urowid) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in time_unconstrained, p_b in time_unconstrained) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in timestamp_tz_unconstrained, p_b in timestamp_tz_unconstrained) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in timestamp_ltz_unconstrained, p_b in timestamp_ltz_unconstrained) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in dsinterval_unconstrained, p_b in dsinterval_unconstrained) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  function equal(p_a in yminterval_unconstrained, p_b in yminterval_unconstrained) return boolean
  is
  begin
    if p_a is null and p_b is null then
      return true;
    else
      return coalesce(p_a = p_b, false);
    end if;
  end;
  
  /**
   * Инициализация данных колонок таблицы журнала.
   * @param p_obj# Идентификатор объекта таблицы.
   */
  procedure init_tab_t(p_obj# in number)
  is
    c_time constant date := sysdate;
    l_idx varchar2(192);
  begin
    if not g_tab_exp_t.exists(p_obj#) or g_tab_exp_t(p_obj#) < c_time then
      l_idx := g_tab_col_t.next(p_obj# || '*');
      while not l_idx is null loop
        g_tab_col_t.delete(l_idx);
        l_idx := g_tab_col_t.next(l_idx);
      end loop;
      l_idx := p_obj# || '*';
      for tab_col in (select tc.id, tc.tab_id, tc.seq, tc.name, tc.data_typ, tc.read_opt, tc.act
                        from t_jour_tab t, t_jour_tab_col tc
                       where t.obj# = p_obj#
                         and tc.tab_id = t.id
                         and tc.act = 'Y')
      loop
        g_tab_col_t(l_idx || tab_col.name) := tab_col;
      end loop;
      g_tab_exp_t(p_obj#) := c_time + c_tab_lt;
    end if;
  end;
  
  /**
   * Получение идентификатора таблицы журнала.
   * @param p_obj# Идентификатор объекта таблицы.
   * @return Идентификатор таблицы журнала.
   */
  function get_tab_id(p_obj# in number) return number
  is
    l_idx varchar2(64);
    l_tab_id number;
  begin
    if p_obj# is null then
      return null;
    end if;
    init_tab_t(p_obj#);
    l_idx := p_obj# || '*';
    l_idx := g_tab_col_t.next(l_idx);
    if l_idx like p_obj# || '*%' then
      l_tab_id := g_tab_col_t(l_idx).tab_id;
    end if;
    return l_tab_id;
  end;
  
  /**
   * Получение данных колонки таблицы журнала.
   * @param p_obj# Идентификатор объекта таблицы.
   * @param p_col_name Наименование колонки.
   * @return Данные колонки таблицы журнала.
   */
  function get_tab_col(p_obj# in number, p_col_name in varchar2) return t_jour_tab_col%rowtype
  is
    l_idx varchar2(192);
    l_tab_col t_jour_tab_col%rowtype;
  begin
    if p_obj# is null then
      return null;
    end if;
    init_tab_t(p_obj#);
    l_idx := p_obj# || '*' || p_col_name;
    if g_tab_col_t.exists(l_idx) then
      l_tab_col := g_tab_col_t(l_idx);
    end if;
    return l_tab_col;
  end;

  procedure clear(p_obj# in number)
  is
  begin
    g_idx := null;
    g_val.ch_id := 0;
    g_val_idx := 0;
    g_obj# := p_obj#;
    g_val.tab_id := get_tab_id(g_obj#);
  end;

  /**
   * Запись изменений журнала.
   * @param p_size Предельное число накопленных изменений.
   */
  procedure int_flush(p_size in pls_integer)
  is
    type te_ch_id_t is table of number;
    l_ch_id_t te_ch_id_t;
    type te_idx_t is table of pls_integer index by pls_integer;
    l_idx_t te_idx_t;
    l_ch_id number;
  begin
    if g_idx = g_val_idx then
      g_val.ch_id := g_val.ch_id - 1;
    end if;
    if g_val_idx > p_size then
      -- Генерация идентификаторов всех изменений.
      select jour_line_seq.nextval bulk collect into l_ch_id_t from dual connect by level <= g_val.ch_id;
      
      l_ch_id := 0;
      for i in 1 .. g_val_idx loop
        if g_val_t(i).ch_id > l_ch_id then
          l_ch_id := g_val_t(i).ch_id;
          l_idx_t(l_ch_id) := i;
        end if;
        g_val_t(i).ch_id := l_ch_id_t(g_val_t(i).ch_id);
      end loop;
      
      
      forall i in 1 .. g_val_idx
        insert into t_jour_val(ch_id, time, tab_id, row_id, col_id, col_val) 
             values (g_val_t(i).ch_id,
                     g_val_t(i).time,
                     g_val_t(i).tab_id,
                     g_val_t(i).row_id,
                     g_val_t(i).col_id,
                     g_val_t(i).col_val);
      forall i in values of l_idx_t
        insert into t_jour_val_ext(ch_id, time, machine, os_user) 
             values (g_val_t(i).ch_id, g_val_t(i).time, g_machine, g_os_user);
      g_val.ch_id := 0;
      g_val_idx := 0;
    end if;
  end;
  
  procedure flush
  is
  begin
    int_flush(0);
  end;
  
  procedure put_line(p_row_id in number, p_time in timestamp)
  is
  begin
    int_flush(256);
    g_idx := g_val_idx;
    g_val.ch_id := g_val.ch_id + 1;
    g_val.time := sys_extract_utc(p_time);
    g_val.row_id := p_row_id;
  end;
  
  /**
   * Добавление изменения колонки.
   * @param p_tab_col Данные колонки.
   * @param p_col_value Значение колонки.
   */
  procedure put_col(p_tab_col in t_jour_tab_col%rowtype, p_col_val in varchar2)
  is
  begin
    g_val.col_id := p_tab_col.id;
    g_val.col_val := p_col_val;
    g_val_idx := g_val_idx + 1;
    g_val_t(g_val_idx) := g_val;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in varchar2, p_a in varchar2, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, p_a);
      end if;
    end if;
  end;
  
  procedure put_col_char(p_col_name in varchar2, p_b in char, p_a in char, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal_char(p_b, p_a) then
        put_col(l_tab_col, p_a);
      end if;
    end if;
  end;

  procedure put_col_raw(p_col_name in varchar2, p_b in raw, p_a in raw, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal_raw(p_b, p_a) then
        put_col(l_tab_col, utl_raw.cast_to_varchar2(p_a));
      end if;
    end if;
  end;
  
  procedure put_col_rowid(p_col_name in varchar2, p_b in rowid, p_a in rowid, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal_rowid(p_b, p_a) then
        put_col(l_tab_col, rowidtochar(p_a));
      end if;
    end if;
  end;

  procedure put_col(p_col_name in varchar2, p_b in number, p_a in number, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, to_char(p_a, c_number_format, 'nls_numeric_characters=.,'));
      end if;
    end if;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in date, p_a in date, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, to_char(p_a, c_date_format));
      end if;
    end if;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in urowid, p_a in urowid, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, p_a);
      end if;
    end if;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in time_unconstrained, p_a in time_unconstrained, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, to_char(p_a, c_timestamp_format));
      end if;
    end if;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in timestamp_tz_unconstrained, p_a in timestamp_tz_unconstrained, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, to_char(p_a, c_timestamp_tz_format));
      end if;
    end if;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in timestamp_ltz_unconstrained, p_a in timestamp_ltz_unconstrained, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, to_char(sys_extract_utc(p_a), c_timestamp_format));
      end if;
    end if;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in dsinterval_unconstrained, p_a in dsinterval_unconstrained, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, to_char(p_a));
      end if;
    end if;
  end;
  
  procedure put_col(p_col_name in varchar2, p_b in yminterval_unconstrained, p_a in yminterval_unconstrained, p_ch in varchar2)
  is
    l_tab_col t_jour_tab_col%rowtype;
  begin
    l_tab_col := get_tab_col(g_obj#, p_col_name);
    if not l_tab_col.id is null then
      if l_tab_col.read_opt = 'Y' or p_ch = 'Y' or p_ch = '?' and not equal(p_b, p_a) then
        put_col(l_tab_col, to_char(p_a));
      end if;
    end if;
  end;
  
  function get_tab_obj#(p_tab_name in out nocopy varchar2, p_tab_owner out nocopy varchar2) return number
  is
    l_tab_owner varchar2(128);
    l_tab_name varchar2(128);
    l_postfix varchar2(128);
    l_link varchar2(128);
    l_type number;
    l_obj# number;
  begin
    dbms_utility.name_resolve(p_tab_name, 0, l_tab_owner, l_tab_name, l_postfix, l_link, l_type, l_obj#);
    p_tab_name := null;
    if l_type = 2 then
      p_tab_owner := l_tab_owner;
      p_tab_name := l_tab_name;
    else
      l_obj# := null;
    end if;
    return l_obj#;
  end;
  
  function get_tab_obj#(p_tab_name in varchar2) return number
  is
    l_tab_name varchar2(128) := p_tab_name;
    l_tab_owner varchar2(128);
  begin
    return get_tab_obj#(l_tab_name, l_tab_owner);
  end;
  
  function get_tab_id(p_tab_name in varchar2) return number
  is
  begin
    return get_tab_id(get_tab_obj#(p_tab_name));
  end;
  
  function get_col_id(p_tab_obj# in number, p_col_name in varchar2) return number
  is
  begin
    return get_tab_col(p_tab_obj#, p_col_name).id;
  end;
  
  procedure put_partition(p_tab_name in varchar2, p_value in number)
  is
    l_obj# number;
    l_tab_name varchar2(128) := p_tab_name;
    l_tab_owner varchar2(128);
    pragma autonomous_transaction;
  begin
    l_obj# := get_tab_obj#(l_tab_name, l_tab_owner);
    if l_obj# is null then
      throw(1, 'Таблица (' || p_tab_name || ') не найдена.');
    end if;
    execute immediate 'alter table "' || l_tab_owner || '"."' || l_tab_name || '" add partition id_' || to_char(p_value, c_number_format) || '_lp values (' || to_char(p_value, c_number_format) || ')';
  end;
  
  procedure drop_partition(p_tab_name in varchar2, p_value in number)
  is
    l_obj# number;
    l_tab_name varchar2(128) := p_tab_name;
    l_tab_owner varchar2(128);
    pragma autonomous_transaction;
  begin
    l_obj# := get_tab_obj#(p_tab_name);
    l_obj# := get_tab_obj#(l_tab_name, l_tab_owner);
    if l_obj# is null then
      throw(2, 'Таблица (' || p_tab_name || ') не найдена.');
    end if;
    begin
      execute immediate 'alter table "' || l_tab_owner || '"."' || l_tab_name || '" drop partition id_' || to_char(p_value, c_number_format) || '_lp';
    exception
      when others then
        null;
    end;
  end;
  
  procedure append(p_clob in out nocopy clob, p_val in varchar2)
  is
  begin
    if p_clob is null then
      dbms_lob.createtemporary(p_clob, true, dur => dbms_lob.call);
    end if;
    dbms_lob.writeappend(p_clob, length(p_val), p_val);
  end;
  
  procedure set_trigger(p_tab_name in varchar2, 
                        p_sync in boolean default false,
                        p_init in boolean default true)
  is
    c_sync constant boolean := nvl(p_sync, false);
    c_init constant boolean := nvl(p_init, true);
    l_init boolean;
    l_tab_owner varchar2(128);
    l_tab_name varchar2(128) := p_tab_name;
    l_obj# number;
    l_jour_tab t_jour_tab%rowtype;
    l_idx_owner varchar2(128);
    l_idx_name varchar2(128);
    l_col_name varchar2(128);
    l_sql clob;
    l_init_sql clob;
    l_suf varchar2(128);
  begin
    l_obj# := get_tab_obj#(l_tab_name, l_tab_owner);
    if l_obj# is null then
      throw(3, 'Таблица (' || p_tab_name || ') не найдена.');
    end if;
    -- Блокировка таблицы при инициализации начальных значений.
    if c_init then
      execute immediate 'lock table "' || l_tab_owner || '"."' || l_tab_name || '" in share mode';
    else
      execute immediate 'lock table "' || l_tab_owner || '"."' || l_tab_name || '" in share update mode';
    end if;
    -- Поиск подходящего первичного ключа.
    begin
      select i.owner, i.index_name
        into l_idx_owner, l_idx_name
        from all_constraints c, all_indexes i
       where c.owner = l_tab_owner
         and c.table_name = l_tab_name
         and c.constraint_type = 'P'
         and c.status = 'ENABLED'
         and c.validated = 'VALIDATED'
         and i.owner = c.owner
         and i.index_name = c.index_name
         and i.index_type in ('NORMAL', 'NORMAL/REV', 'IOT - TOP')
         and i.table_type = 'TABLE'
         and i.uniqueness = 'UNIQUE'
         and i.status = 'VALID'
         and i.temporary = 'N';
    exception
      when no_data_found then
        throw(4, 'Не найден первичный ключ в таблице (' || l_tab_name || ') необходимый для идентификации строки в журнале изменений.');
    end;
    -- Проверка состава колонок первичного ключа.
    select min(ic.column_name)
      into l_col_name
      from all_ind_columns ic,
           all_tab_columns tc
     where ic.index_owner = l_idx_owner
       and ic.index_name = l_idx_name
       and tc.owner = l_tab_owner
       and tc.table_name = l_tab_name
       and tc.column_name = ic.column_name 
     group by ic.index_name having max(ic.column_position) = 1
                               and max(tc.data_type) = 'NUMBER';
    if l_col_name is null then
      throw(5, 'Состав или тип данных колонок индекса первичного ключа (' || l_idx_name || ') не подходит для использования в журнале изменений.');
    end if;
    if c_sync then
      begin
        select id, seq into l_jour_tab.id, l_jour_tab.seq from t_jour_tab where obj# = l_obj# for update;
      exception
        when no_data_found then
          throw(6, 'Таблица (' || l_tab_name || ') не журналирует изменения.');
      end;
      append(l_sql, 'create or replace ');
    else
      insert into t_jour_tab(id, obj#, seq) values (jour_id_seq.nextval, l_obj#, 0) returning id, seq into l_jour_tab.id, l_jour_tab.seq;
      if c_init then -- Скрипт инициализации начальных значений.
        append(l_init_sql, 'declare' || chr(10));
        append(l_init_sql, '  l_time timestamp with time zone := systimestamp();' || chr(10));
        append(l_init_sql, 'begin' || chr(10));
        append(l_init_sql, '  "' || c_schema || '".pe_jour.clear(' || l_obj# || ');' || chr(10));
        append(l_init_sql, '  for i in (select * from "' || l_tab_owner || '"."' || l_tab_name || '") loop' || chr(10));
        append(l_init_sql, '    "' || c_schema || '".pe_jour.put_line( i."' || l_col_name || '",' || 
                                                                      ' l_time);' || chr(10));   
      end if;
      -- Скрипт создания триггера.
      append(l_sql, 'create ');      
    end if;
    append(l_sql, 'trigger "' || c_schema || '"."' || l_tab_name || '_JCT" for insert or update or delete on "' || 
                  l_tab_name || '" compound trigger' || chr(10));
    append(l_sql, '  before statement' || chr(10));
    append(l_sql, '  is' || chr(10));
    append(l_sql, '  begin' || chr(10));
    append(l_sql, '    ' || c_schema || '.pe_jour.clear(' || l_obj# || ');' || chr(10));
    append(l_sql, '  end before statement;' || chr(10));
    append(l_sql, '  after each row' || chr(10));
    append(l_sql, '  is' || chr(10));
    append(l_sql, '    l_ch varchar2(1);' || chr(10));
    append(l_sql, '  begin' || chr(10));
    append(l_sql, '    if inserting or deleting then' || chr(10));
    append(l_sql, '      l_ch := ''Y'';' || chr(10));
    append(l_sql, '    end if;' || chr(10));
    append(l_sql, '    "' || c_schema || '".pe_jour.put_line(nvl(:old."' || l_col_name || '", :new."' || l_col_name || '"), ' || 
                                                            'systimestamp());' || chr(10));   
    for i in (select tc.column_name, 
                     tc.data_type,
                     (select id
                        from t_jour_tab_col
                       where tab_id = l_jour_tab.id
                         and name = tc.column_name
                         and data_typ = tc.data_type
                         and act = 'Y') col_id
                from all_tab_cols tc
               where tc.owner = l_tab_owner
                 and tc.table_name = l_tab_name
                 and tc.data_length <= 2000
                 and tc.hidden_column = 'NO'
                 and tc.virtual_column = 'NO')
    loop
      l_suf := case when i.data_type in ('CHAR', 'RAW', 'ROWID') then '_' || lower(i.data_type) end;
      if c_sync then
        if i.col_id is null then
          update t_jour_tab_col
             set act = 'N'
           where tab_id = l_jour_tab.id
             and name = i.column_name
             and act = 'Y';
          l_jour_tab.seq := l_jour_tab.seq + 1;
          insert into t_jour_tab_col(id, tab_id, seq, name, data_typ) values (jour_id_seq.nextval, l_jour_tab.id, l_jour_tab.seq, i.column_name, i.data_type);
          if c_init then
            append(l_init_sql, '    "' || c_schema || '".pe_jour.put_col' || l_suf || '(''' || i.column_name || ''', null, i."' || i.column_name || '", ''Y'');' || chr(10));
            l_init := true;
          end if;
        end if;
      else
        l_jour_tab.seq := l_jour_tab.seq + 1;
        insert into t_jour_tab_col(id, tab_id, seq, name, data_typ) values (jour_id_seq.nextval, l_jour_tab.id, l_jour_tab.seq, i.column_name, i.data_type);
        if c_init then
          append(l_init_sql, '    "' || c_schema || '".pe_jour.put_col' || l_suf || '(''' || i.column_name || ''', null, i."' || i.column_name || '", ''Y'');' || chr(10));
          l_init := true;
        end if;
      end if;
      append(l_sql, '    "' || c_schema || '".pe_jour.put_col' || l_suf || '(''' || i.column_name || ''',' || 
                                                                         ' :old."' || i.column_name || '",' ||
                                                                         ' :new."' || i.column_name || '",' || 
                                                                         ' nvl(l_ch, case when updating(''' || i.column_name || ''') then ''?'' else ''N'' end));' || chr(10));
    end loop;
    append(l_sql, '  end after each row;' || chr(10));
    append(l_sql, '  after statement' || chr(10));
    append(l_sql, '  is' || chr(10));
    append(l_sql, '  begin' || chr(10));
    append(l_sql, '    "' || c_schema || '".pe_jour.flush;' || chr(10));
    append(l_sql, '  end after statement;' || chr(10));
    append(l_sql, 'end;');
    if l_init then
      append(l_init_sql, '  end loop;' || chr(10));
      append(l_init_sql, '  "' || c_schema || '".pe_jour.flush;' || chr(10));
      append(l_init_sql, 'end;' || chr(10));
      execute immediate l_init_sql;
    end if;
    update t_jour_tab set seq = l_jour_tab.seq where id = l_jour_tab.id;
    execute immediate l_sql;
  end;
  
  procedure drop_trigger(p_tab_name in varchar2)
  is
    l_tab_owner varchar2(128);
    l_tab_name varchar2(128) := p_tab_name;
    l_obj# number;
    l_id number;
  begin
    l_obj# := get_tab_obj#(l_tab_name, l_tab_owner);
    if l_obj# is null then
      throw(7, 'Таблица (' || p_tab_name || ') не найдена.');
    end if;
    begin
      select id into l_id from t_jour_tab where obj# = l_obj# for update;
    exception
      when no_data_found then
        throw(8, 'По таблице (' || l_tab_name || ') журналирование изменений не производится.');
    end;
    delete from t_jour_tab_col where tab_id = l_id;
    delete from t_jour_tab where id = l_id;
    execute immediate 'drop trigger "' || c_schema || '"."' || l_tab_name || '_JCT"';
  end;
  
  function get_col_val_(p_tab_id in number, p_col_id in number, p_row_id in number, p_time in timestamp with time zone) return varchar2
  is
    c_time constant timestamp with time zone := coalesce(p_time, systimestamp());
    l_col_val t_jour_val.col_val%type;
  begin
    if not p_tab_id is null and not p_col_id is null then
      for i in (select col_val
                  from (select --+ index_desc(l jrvl_pk)
                               l.col_val
                          from t_jour_val l 
                         where l.tab_id = p_tab_id
                           and l.row_id = p_row_id
                           and l.time <= sys_extract_utc(c_time)
                           and l.col_id = p_col_id
                      order by l.tab_id desc, l.row_id desc, l.time desc, l.col_id desc, l.ch_id desc) where rownum = 1)
      loop
        l_col_val := i.col_val;
      end loop;
    end if;
    return l_col_val;
  end;
  
  function get_col_val(p_tab_name in varchar2, p_col_name in varchar2, p_row_id in number, p_time in timestamp with time zone) return varchar2
  is
    c_time constant timestamp with time zone := coalesce(p_time, systimestamp());
    l_obj# number;
    l_tab_col t_jour_tab_col%rowtype;
    l_col_val t_jour_val.col_val%type;
  begin
    l_obj# := get_tab_obj#(p_tab_name);
    l_tab_col := get_tab_col(l_obj#, p_col_name);
    return get_col_val(l_tab_col.tab_id, l_tab_col.id, p_row_id, c_time); 
  end;
  
  function get_row_val(p_tab_name in varchar2, p_row_id in number, p_time in timestamp with time zone) return te_row_t
  is
    c_time constant timestamp with time zone := coalesce(p_time, systimestamp());
    l_obj# number;
    l_idx varchar2(192);
    l_tab_col t_jour_tab_col%rowtype;
    l_row_t te_row_t;
  begin
    l_obj# := get_tab_obj#(p_tab_name);
    init_tab_t(l_obj#);
    l_idx := l_obj# || '*';
    l_idx := g_tab_col_t.next(l_idx);
    loop
      exit when l_idx is null;
      l_tab_col := g_tab_col_t(l_idx);
      l_row_t(l_tab_col.name) := get_col_val_(l_tab_col.tab_id, l_tab_col.id, p_row_id, p_time);
      l_idx := g_tab_col_t.next(l_idx);
    end loop;
    return l_row_t;
  end;

end;
/
