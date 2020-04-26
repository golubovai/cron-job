create or replace package pe_cron_job
is
  
  -- Точка отсчета времени следующего запуска.
  c_start_ref_point constant varchar2(1) := 'S'; -- Время запуска.
  c_end_ref_point constant varchar2(1) := 'E'; -- Время завершения.
  
  /**
   * Вызов исключения.
   * @param p_n Номер.
   * @param p_message Сообщение.
   */
  procedure throw(p_n in binary_integer, p_message in varchar2);
  
  /**
   * Следующая дата выражения (cron).
   * @param p_date Текущая дата.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Календарь рабочих/выходных дней.
   * @return Следующая дата.
   */
  function next_date(p_date in date, p_cron in varchar2, p_calendar_id in number default null) return date;
  
  /**
   * Синхронизация задания.
   * @param p_cron_job Строка задания.
   */
  procedure sync_job(p_cron_job in t_cron_job%rowtype);
  
  /**
   * Задание синхронизации списка заданий.
   */
  procedure sync;
  
  /**
   * Получить время запуска текущего задания.
   * @return Время запуска текущего задания.
   */
  function get_next_date return date;
  
  /**
   * Установить следующее время запуска текущего задания.
   * @param p_next_date Следующее время запуска.
   */
  procedure set_next_date(p_next_date in date);
  
  /**
   * Процедура выполнения задания.
   * @param p_id Идентификатор задания.
   * @param p_next_date Следующее время запуска.
   * @param p_broken Приостановлено.
   */
  procedure run(p_id in number, p_next_date in out nocopy date, p_broken in out nocopy boolean);
  
  /**
   * Создание задания.
   * @param p_caption Описание.
   * @param p_operation Процедура выполнения.
   * @param p_enabled Включено.
   * @param p_next_date Время следующего запуска.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Идентификатор календаря.
   * @param p_ref_point Точка отсчета времени слудующего запуска.
   * @param p_rerun_delay Задержка перезапуска при возникновении ошибки.
   * @param p_lead_id Идентификатор ведущего задания.
   * @param p_lead_delay Задержка запуска после ведущего задания.
   * @param p_broken Приостановлено.
   */
  function put(p_caption in varchar2,
               p_operation in varchar2,
               p_enabled in boolean default true,
               p_next_date in date default null,
               p_cron in varchar2 default null,
               p_calendar_id in number default null,
               p_ref_point in varchar2 default null, 
               p_rerun_delay in number default null,
               p_lead_id in number default null,
               p_lead_delay in number default null,
               p_broken in boolean default false) return t_cron_job%rowtype;
  
  /**
   * Изменение задания.
   * @param p_id Идентификатор задания.
   * @param p_caption Описание.
   * @param p_operation Процедура выполнения.
   * @param p_enabled Включено.
   * @param p_next_date Время следующего запуска.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Идентификатор календаря.
   * @param p_ref_point Точка отсчета времени слудующего запуска.
   * @param p_rerun_delay Задержка перезапуска при возникновении ошибки.
   * @param p_lead_id Идентификатор ведущего задания.
   * @param p_lead_delay Задержка запуска после ведущего задания.
   * @param p_broken Приостановлено.
   */
  procedure change(p_id in number,
                   p_caption in varchar2,
                   p_operation in varchar2,
                   p_enabled in boolean,
                   p_next_date in date,
                   p_cron in varchar2,
                   p_calendar_id in number,
                   p_ref_point in varchar2, 
                   p_rerun_delay in number,
                   p_lead_id in number,
                   p_lead_delay in number,
                   p_broken in boolean);
  
  /**
   * Установка процедуры выполнения.
   * @param p_id Идентфикатор задания.
   * @param p_operation Процедура выполнения.
   * @param p_caption Описание.
   */
  procedure set_operation(p_id in number, p_operation in varchar2, p_caption in varchar2 default null);
  
  /**
   * Установка состояния.
   * @param p_id Идентфикатор задания.
   * @param p_enabled Включено.
   */
  procedure set_enabled(p_id in number, p_enabled in boolean);
   
  /**
   * Установка времени следующего запуска задания.
   * @param p_id Идентфикатор задания.
   * @param p_next_date Время следующего запуска.
   */
  procedure set_next_date(p_id in number, p_next_date in date);

  /**
   * Установка выражения (cron) и связанных параметров.
   * @param p_id Идентфикатор задания.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Идентификатор календаря.
   * @param p_ref_point Точка отсчета времени слудующего запуска.
   */
  procedure set_cron(p_id in number, p_cron in varchar2, p_calendar_id in number, p_ref_point in varchar2 default null);
  
  /**
   * Установка задержки перезапуска при возникновении ошибки.
   * @param p_id Идентфикатор задания.
   * @param p_rerun_delay Задержка перезапуска при возникновении ошибки.
   */
  procedure set_rerun_delay(p_id in number, p_rerun_delay in number);
  
  /**
   * Установка ведущего задания.
   * @param p_id Идентфикатор задания.
   * @param p_lead_id Идентификатор ведущего задания.
   * @param p_lead_delay Задержка запуска после ведущего задания.
   */
  procedure set_lead(p_id in number, p_lead_id in number, p_lead_delay in number);
  
  /**
   * Установка приостановки выполенения.
   * @param p_id Идентфикатор задания.
   * @param p_broken Приостановлено.
   */
  procedure set_broken(p_id in number, p_broken in boolean);
  
  /**
   * Удаление задания.
   * @param p_id Идентификатор задания.
   */
  procedure remove(p_id in number);
  
end;
/
create or replace package body pe_cron_job
is

  job_not_found exception;
  pragma exception_init(job_not_found, -23421);

  c_num constant varchar2(10) := '0123456789';
  c_sec constant number := 1 / 86400;
  c_wait_delay constant number := 30 * c_sec; -- Время запуска задания базы данных.
  c_critical_rerun_delay constant number := 60 * c_sec; -- Время повторного запуска задания при критической ошибке.
  
  c_schema constant varchar2(128) := sys_context('userenv', 'current_schema');
  c_what_regex constant varchar2(128) := '^' || c_schema || '\.pe_cron_job.run\([0-9]+\,\ next_date\,\ broken\);$';
  
  -- Данные сессии.
  g_sid number;
  g_serial# number;
  g_audsid number;
  
  -- Время следующего запуска задания для переопределения процессом обработки.
  g_next_date date;
  
  -- Последовательность разрешенных значений.
  type te_seq_t is table of varchar2(1) index by pls_integer;
  -- Параметры разбора.
  type te_opt is record(typ varchar2(3), val pls_integer, day pls_integer);
  -- Компоненты выражения (cron).
  type te_cron_t is table of varchar2(128) index by pls_integer;
  
  /**
   * Вызов исключения.
   * @param p_n Номер.
   * @param p_message Сообщение.
   */
  procedure throw(p_n in binary_integer, p_message in varchar2)
  is
  begin
    raise_application_error(-20000 - p_n, p_message);
  end;
  
  /**
   * Преобразование переменной boolean в строку.
   * @param p_boolean Переменная boolean.
   * @return Строка.
   */
  function boolean_to(p_boolean in boolean) return varchar2
  is
  begin
    if p_boolean is null then
      return '';
    elsif p_boolean then
      return 'Y';
    else
      return 'N';
    end if;
  end;
  
  /**
   * Добавить строку к переменной clob.
   * @param p_clob Переменная clob.
   * @param p_val Строка.
   */
  procedure append(p_clob in out nocopy clob, p_val in varchar2)
  is
  begin
    if p_clob is null then
      dbms_lob.createtemporary(p_clob, true);
    end if;
    dbms_lob.writeappend(p_clob, length(p_val), p_val);
  end;
  
  /**
   * Получение информации о текущей сессии.
   * @param p_sid Идентификатор сессии.
   * @param p_serial# Порядковый номер сессии.
   * @param p_audsid Уникальный идентификатор сессии.
   */
  procedure get_session_info(p_sid out nocopy number, p_serial# out nocopy number, p_audsid out nocopy number)
  is
  begin
    if g_sid is null or g_serial# is null then
      g_sid := dbms_debug_jdwp.current_session_id;
      g_serial# := dbms_debug_jdwp.current_session_serial;
      g_audsid := sys_context('userenv', 'sessionid');
    end if;
    p_sid := g_sid;
    p_serial# := g_serial#;
    p_audsid := g_audsid;
  end;
  
  /**
   * Разбор числа из строки.
   * @param p_nb Строка.
   * @param p_min Минимальное значение.
   * @param p_max Максимальное значение.
   * @return Число.
   */
  function get_num(p_nb in out nocopy varchar2, p_min in binary_integer, p_max in binary_integer default null) return number 
  is
    l_n binary_integer;
  begin
    if p_nb is null then
      throw(1, 'Числовое значение ожидается в интервале ' || p_min || ' .. ' || p_max || '.');
    end if;
    l_n := to_char(p_nb, 'fm99999999999999990');
    if l_n < p_min or l_n > p_max then
      throw(2, 'Числовое значение (' || l_n || ') за границами интервала ' || p_min || ' .. ' || p_max);
    end if;
    p_nb := '';
    return l_n;
  end;
  
  /**
   * Разбор компоненты выражения (cron).
   * @param p_val Компонента выражения.
   * @param p_min Минимальное значение.
   * @param p_max Максимальное значение.
   * @param p_opt Параметры разбора.
   * @param p_sup Вид компоненты: M - день месяца, W - день недели.
   * @param p_sc Специальные символы.
   */
  function parse(p_val in varchar2, 
                 p_min in binary_integer, 
                 p_max in binary_integer,
                 p_opt out nocopy te_opt,
                 p_sup in varchar2 default 'M',
                 p_sc in varchar2 default '/-,') return te_seq_t
  is
    c_alphabet constant varchar2(32767) := c_num || p_sc;
    l_val varchar2(32767) := upper(p_val);
    l_seq_t te_seq_t;
    l_c varchar2(1);
    l_nb varchar2(32767);
    l_st varchar2(1);
    l_s binary_integer;
    l_e binary_integer;

    procedure parse_char(p_st in out nocopy varchar2, p_c in varchar2) is
      l_d binary_integer;
    begin
      if p_st = '/' then -- (min .. max)/(min .. max)(, )
        if p_c in (',', ' ') then
          l_d := get_num(l_nb, 1); -- Devider.
          for i in l_s .. nvl(l_e, p_max) loop
            if mod(i - l_s, l_d) = 0 then
              l_seq_t(i) := '';
            end if;
          end loop;
          l_s := null; l_e := null;
        else
          throw(3, 'Непредвиденный символ (' || p_c || ') после (' || p_st || ').');
        end if;
      elsif p_st = '-' then -- (min .. max)-(min .. max)(/, )
        if p_c in ('/', ',', ' ') then
          l_e := get_num(l_nb, p_min, p_max);
          if p_c in (',', ' ') then
            for i in l_s .. l_e loop
              l_seq_t(i) := '';
            end loop;
            l_s := null; l_e := null;
          end if;
        else
          throw(4, 'Непредвиденный символ (' || p_c || ') после (' || p_st || ').');
        end if;
      elsif p_st = ',' then -- (min .. max),(min .. max)(/-,# )
        if p_c in ('/', '-', ',', '#', ' ') then
          l_s := get_num(l_nb, p_min, p_max);
          if p_c in (',', ' ') then
            l_seq_t(l_s) := ''; l_s := null;
          end if;
        else
          throw(5, 'Непредвиденный символ (' || p_c || ') после (' || p_st || ').');
        end if;
      elsif p_st = 'L' then -- (1 .. 7)L, L(-1 .. -31), L, LW, LH
        if p_c in ('W', 'H') then -- LW, LW
          if p_sup = 'M' then
            p_opt.typ := 'ML' || p_c;
          else
            throw(6, 'Выражение (' || p_st || p_c || ') не поддерживается в этой позиции.');
          end if;
        elsif p_c = ' ' then
          if l_nb is null then -- (1 .. 7)L, L
            if l_s is null then
              p_opt.val := 0; p_opt.day := 7;
            elsif p_sup = 'W' then
              p_opt.day := l_s; l_s := null;
            else
              throw(7, 'Опция (' || p_st || ') не верна здесь.');
            end if;
          else -- L(-1 .. -30)           
            if l_s is null and p_sup = 'M' then
              p_opt.val := get_num(l_nb, -30, -1);
            else
              throw(8, 'Опция (' || p_st || ') не верна здесь.');
            end if;
          end if;
          p_opt.typ := p_sup || 'L';
        else
          throw(9, 'Непредвиденный символ (' || p_c || ') после (' || p_st || ').');
        end if;
      elsif p_st = '#' then -- (1..7)#(1..5)
        if p_sup = 'W' and p_c = ' ' then
          p_opt.val := get_num(l_nb, 1, 5);
          p_opt.day := l_s; l_s := null;
          p_opt.typ := 'W#';
        else
          throw(10, 'Опция (' || p_st || ') не верна здесь.');
        end if;
      elsif p_st in ('W', 'H') then -- (1 .. 31)W, (1 .. 31)H
        if p_c = ' ' then
          if p_opt.typ is null and p_sup = 'M' then
            p_opt.val := get_num(l_nb, 1, 31);
            p_opt.typ := 'M' || p_st;
          else
            throw(11, 'Опция (' || p_st || ') не верна здесь.');
          end if;
        else
          throw(12, 'Непредвиденный символ (' || p_c || ') после (' || p_st || ').');
        end if;
      elsif p_st is null then
        if p_c in ('/', '-', ',', ' ') then
          l_s := get_num(l_nb, p_min, p_max);
          if p_c in (',', ' ') then
            l_seq_t(l_s) := ''; l_s := null;
          end if;
        elsif p_c = 'L' then -- (1 .. 7)L, L(-1 .. -31), LW, LH
          if p_sup = 'W' then
            if l_nb is null then
              l_s := 7;
            else
              l_s := get_num(l_nb, 1, 7);
            end if;
          elsif p_sup = 'M' then -- L(-1 .. -31), LW, LH
            if not l_nb is null then
              throw(2, 'Опция (' || p_c || ') не верна здесь.');
            end if;
          end if;
        elsif p_c = '#' then -- (1..7)#(1..5)
          if p_sup = 'W' then
            l_s := get_num(l_nb, 1, 7);
          else
            throw(13, 'Непредвиденный символ (' || p_c || ').');
          end if;
        end if;
      end if;
      p_st := p_c;
    end;
    
  begin
    if l_val = '*' or p_sup in ('M', 'W') and l_val = '?' then
      l_seq_t(-1) := '';
    else
      if p_sup = 'W' then
        l_val := replace(l_val, 'MON', '1'); l_val := replace(l_val, 'TUE', '2'); l_val := replace(l_val, 'WED', '3'); 
        l_val := replace(l_val, 'THU', '4'); l_val := replace(l_val, 'FRI', '5'); l_val := replace(l_val, 'SAT', '6'); 
        l_val := replace(l_val, 'SUN', '7');
      elsif p_sup = 'M' then
        l_val := replace(l_val, 'JAN', '1');  l_val := replace(l_val, 'FEB', '2');  l_val := replace(l_val, 'MAR', '3'); 
        l_val := replace(l_val, 'APR', '4');  l_val := replace(l_val, 'MAY', '5');  l_val := replace(l_val, 'JUN', '6'); 
        l_val := replace(l_val, 'JUL', '7');  l_val := replace(l_val, 'AUG', '8');  l_val := replace(l_val, 'SEP', '9'); 
        l_val := replace(l_val, 'OCT', '10'); l_val := replace(l_val, 'NOV', '11'); l_val := replace(l_val, 'DEC', '12'); 
      end if;                          
      for i in 1 .. length(l_val) loop
        l_c := substr(l_val, i, 1);
        if instr(c_alphabet, l_c) = 0 then
          throw(14, 'Обнаружен недопустимый символ (' || l_c || ').');
        end if;
        if l_st = 'L' and l_c = '-' or instr(c_num, l_c) > 0 then
          l_nb := l_nb || l_c;
        else
          parse_char(l_st, l_c);
        end if;
      end loop;
      parse_char(l_st, ' ');
    end if;
    return l_seq_t;
  end;
  
  /**
   * Получить числовой день недели.
   * @param p_date Дата.
   * @return Числовой день недели.
   */
  function week_day(p_date in date) return pls_integer deterministic
  is
  begin
    return 1 + trunc(p_date) - trunc(p_date, 'IW');
  end;
  
  /**
   * Получить следующий числовой день недели.
   * @param p_week_day Числовой день недели.
   * @return Следующий числовой день недели.
   */
  function week_day_next(p_week_day in pls_integer) return pls_integer deterministic
  is
  begin
    if p_week_day = 7 then 
      return 1;
    end if;
    return p_week_day + 1;
  end;
  
  /**
   * Получить предыдущий числовой день недели.
   * @param p_week_day Числовой день недели.
   * @return Предыдущий числовой день недели.
   */
  function week_day_prev(p_week_day in pls_integer) return pls_integer deterministic
  is
  begin
    if p_week_day = 1 then 
      return 7;
    end if;
    return p_week_day - 1;
  end;
  
  /**
   * Получить тип дня (выходной/рабочий) с учетом заданного календаря.
   * @param p_date Дата.
   * @param p_calendar_id Идентификатор календаря.
   * @return Тип дня (H - выходной, W - рабочий).
   */
  function get_date_type(p_date in date, p_calendar_id in number default null) return varchar2
  is
  begin
    if p_calendar_id is null then
      if week_day(p_date) in (6, 7) then
        return 'H';
      else
        return 'W';
      end if;
    else
      return null;
    end if;
  end;
  
  /**
   * Разделение даты на компоненты.
   * @param p_date Дата.
   * @param p_year Год.
   * @param p_month Месяц.
   * @param p_day День.
   * @param p_hour Час.
   * @param p_minute Минута.
   * @param p_second Секунда.
   */
  procedure split(p_date in date, p_year out nocopy pls_integer, p_month out nocopy pls_integer, p_day out nocopy pls_integer, p_hour out nocopy pls_integer, p_minute out nocopy pls_integer, p_second out nocopy pls_integer)
  is
  begin
    p_year := extract(year from p_date);
    p_month := extract(month from p_date);
    p_day := extract(day from p_date);
    p_hour := to_char(p_date, 'hh24');
    p_minute := to_char(p_date, 'mi');
    p_second := to_char(p_date, 'ss');
  end;
    
  /**
   * Объединение в дату из компонент.
   * @param p_year Год.
   * @param p_month Месяц.
   * @param p_day День.
   * @param p_hour Час.
   * @param p_minute Минута.
   * @param p_second Секунда.
   */
  function combine(p_year in pls_integer, p_month in pls_integer, p_day in pls_integer, p_hour in pls_integer, p_minute in pls_integer, p_second in pls_integer) return date deterministic
  is
  begin
    return to_date(lpad(p_year,   4, '0') || 
                   lpad(p_month,  2, '0') || 
                   lpad(p_day,    2, '0') || 
                   lpad(p_hour,   2, '0') || 
                   lpad(p_minute, 2, '0') || 
                   lpad(p_second, 2, '0'), 'yyyymmddhh24miss');
  end;
  
  /**
   * Получить следующее время с учетом cron-компонент.
   * @param p_date Дата.
   * @param p_second Секунды.
   * @param p_minute Минуты.
   * @param p_hour Часы.
   * @param p_month_day Дни месяца.
   * @param p_month Месяцы.
   * @param p_week_day Дни недели.
   * @param p_year Годы.
   * @param p_calendar_id Идентификатор календаря.
   *
   */
  function next_date(p_date in date,
                     p_second in varchar2,
                     p_minute in varchar2,
                     p_hour in varchar2,
                     p_month_day in varchar2,
                     p_month in varchar2,
                     p_week_day in varchar2,
                     p_year in varchar2 default null,
                     p_calendar_id in number default null) return date
  is
    l_sup varchar2(1);
    l_second_seq_t te_seq_t; l_second_opt te_opt;
    l_minute_seq_t te_seq_t; l_minute_opt te_opt;
    l_hour_seq_t te_seq_t; l_hour_opt te_opt;
    l_month_day_seq_t te_seq_t; l_month_day_opt te_opt;
    l_month_seq_t te_seq_t; l_month_opt te_opt;
    l_week_day_seq_t te_seq_t; l_week_day_opt te_opt;
    l_year_seq_t te_seq_t; l_year_opt te_opt;
    l_date date := p_date + c_sec;
    l_last_day date;
    l_week_day_ pls_integer;
    l_date_ date;
    l_day_ pls_integer;
    l_week_day_# pls_integer;
    l_step_ pls_integer;
    l_year pls_integer;
    l_month pls_integer;
    l_day pls_integer;
    l_hour pls_integer;
    l_minute pls_integer;
    l_second pls_integer;
    l_level pls_integer := 1;
    
    /**
     * Сброс компонент даты.
     * @param p_level Уровень.
     */
    procedure reset(p_level in pls_integer)
    is
    begin
      l_level := p_level;
      if p_level <= 1 then
        l_month := 1;
      end if;
      if p_level <= 2 then
        l_day := 1;
      end if;
      if p_level <= 3 then
        l_hour := 0;
      end if;
      if p_level <= 4 then
        l_minute := 0;
      end if;
      if p_level <= 5 then
        l_second := 0;
      end if;
    end;
    
  begin
    if l_date is null then
      return null;
    end if;
    if not p_month_day = '?' and not p_week_day = '?' then
      throw(15, 'Одновременное задание дня недели и дня месяца не возможно.');
    elsif not p_month_day = '?' then
      l_sup := 'M';
    elsif not p_week_day = '?' then
      l_sup := 'W';
    end if;
    l_second_seq_t := parse(p_second, 0, 59, l_second_opt);
    l_minute_seq_t := parse(p_minute, 0, 59, l_minute_opt);
    l_hour_seq_t := parse(p_hour, 0, 23, l_hour_opt);    
    l_month_day_seq_t := parse(p_month_day, 1, 31, l_month_day_opt, p_sup => 'M', p_sc => ',-/LWH');
    l_month_seq_t := parse(p_month, 1, 12, l_month_opt);
    l_week_day_seq_t := parse(p_week_day, 1, 7, l_week_day_opt, p_sup => 'W', p_sc => ',-/L#');
    l_year_seq_t := parse(nvl(p_year, '*'), 1, 9999, l_year_opt);
    -- Разделение даты на компоненты.
    split(l_date, l_year, l_month, l_day, l_hour, l_minute, l_second);
    loop
      if l_level = 1 then -- Год.
        if l_year > 9999 or l_year < 1 then
          return null;
        end if;
        if not l_year_seq_t.exists(-1) and not l_year_seq_t.exists(l_year) then
          l_year := l_year_seq_t.next(l_year);
          if l_year is null then
            return null;
          else
            reset(1);
          end if;
        end if;
        l_level := 2;
      end if;
      
      if l_level = 2 then -- Месяц.
        if l_month > 12 then
          l_year := l_year + 1; reset(1); continue;
        end if;
        if not l_month_seq_t.exists(-1) and not l_month_seq_t.exists(l_month) then
          l_month := l_month_seq_t.next(l_month);
          if l_month is null then
            l_year := l_year + 1; reset(1); continue;
          else
            reset(2);
          end if;
        end if;
        l_date := combine(l_year, l_month, l_day, 0, 0, 0);
        l_last_day := last_day(l_date);
        l_level := 3;
      end if;
      
      if l_level = 3 then -- День.
        if l_date > l_last_day then
          l_month := l_month + 1; reset(2); continue;
        end if;
        if l_month_day_opt.typ = 'ML' then -- Последний день месяца (со смещением).
          l_date_ := l_last_day + nvl(l_month_opt.val, 0);
          l_day := to_char(l_date_, 'dd');
        elsif l_month_day_opt.typ in ('MLW', 'MLH') or l_week_day_opt.typ = 'WL' then -- Последний в месяце рабочий день, выходной или заданный день недели.
          l_date_ := l_last_day;
          if l_week_day_opt.typ = 'WL' then
            l_week_day_ := week_day(l_date_);
          end if;
          loop
            exit when l_date_ < l_date or
                      l_month_day_opt.typ = 'MLW' and get_date_type(l_date_, p_calendar_id => p_calendar_id) = 'W' or
                      l_month_day_opt.typ = 'MLH' and get_date_type(l_date_, p_calendar_id => p_calendar_id) = 'H' or
                      l_week_day_opt.typ  = 'WL' and l_week_day_ = l_week_day_opt.day;
            l_date_ := l_date_ - 1;
            l_day := l_day - 1;
            if l_week_day_opt.typ  = 'WL' then
              l_week_day_ := week_day_prev(l_week_day_);
            end if;
          end loop;
        elsif l_month_day_opt.typ in ('MW', 'MH') or l_week_day_opt.typ = 'W#' then -- Ближайший следующий рабочий день, выходной или n-й заданный день недели в месяце.
          l_step_ := 1;
          if l_week_day_opt.typ = 'W#' then
            l_date_ := trunc(l_date, 'mm'); l_day := 1;
            l_week_day_ := week_day(l_date_);
            l_week_day_# := 0;
          else
            l_date_ := l_date;
          end if;
          loop
            if l_week_day_opt.typ = 'W#' then
              if l_week_day_ = l_week_day_opt.day then
                l_week_day_# := l_week_day_# + 1;
                l_step_ := 7;
              else
                if l_week_day_opt.day >= l_week_day_ then
                  l_step_ := l_week_day_opt.day - l_week_day_; 
                else
                  l_step_ := l_week_day_opt.day - l_week_day_ + 7; 
                end if;
              end if;
            end if;
            exit when l_date_ > l_last_day or
                      l_month_day_opt.typ = 'MW' and get_date_type(l_date, p_calendar_id => p_calendar_id) = 'W' or
                      l_month_day_opt.typ = 'MH' and get_date_type(l_date, p_calendar_id => p_calendar_id) = 'H' or
                      l_week_day_opt.typ  = 'W#' and l_week_day_# = l_week_day_opt.val;
            l_date_ := l_date_ + l_step_;
            l_day := l_day + l_step_;
          end loop;
        elsif l_sup = 'M' and not l_month_day_seq_t.exists(-1) and not l_month_day_seq_t.exists(l_day) then
          l_day_ := l_day;
          l_day := l_month_day_seq_t.next(l_day_);
          if l_day is null then
            l_month := l_month + 1; reset(2); continue;
          else
            l_date_ := l_date + (l_day - l_day_);
          end if;
        elsif l_sup = 'W' and not l_week_day_seq_t.exists(-1) then
          l_date_ := l_date;
          l_week_day_ := week_day(l_date_);
          if not l_week_day_seq_t.exists(l_week_day_) then
            loop
              exit when l_date_ > l_last_day or l_week_day_seq_t.exists(l_week_day_);
              l_date_ := l_date_ + 1;
              l_day := l_day + 1;
              l_week_day_ := week_day_next(l_week_day_);
            end loop;
          end if;
        end if;
        
        if l_date_ < l_date or l_date_ > l_last_day then
          l_month := l_month + 1; reset(2); continue;
        elsif l_date_ > l_date then
          reset(3);
        end if;
        l_date := l_date_;
        l_level := 4;
      end if;
      
      if l_level = 4 then -- Час.
        if l_hour > 23 then
          l_day := l_day + 1; l_date := l_date + 1; reset(3); continue;
        end if;
        if not l_hour_seq_t.exists(-1) and not l_hour_seq_t.exists(l_hour) then
          l_hour := l_hour_seq_t.next(l_hour);
          if l_hour is null then
            l_day := l_day + 1; l_date := l_date + 1; reset(3); continue;
          else
            reset(4);
          end if;
        end if;
        l_level := 5;
      end if;
      
      if l_level = 5 then -- Минута.
        if l_minute > 59 then
          l_hour := l_hour + 1; reset(4); continue;
        end if;
        if not l_minute_seq_t.exists(-1) and not l_minute_seq_t.exists(l_minute) then
          l_minute := l_minute_seq_t.next(l_minute);
          if l_minute is null then
            l_hour := l_hour + 1; reset(4); continue;
          else
            reset(5);
          end if;
        end if;
        l_level := 6;
      end if;
      
      if l_level = 6 then -- Секунда.
        if l_second > 59 then
          l_minute := l_minute + 1; reset(5); continue;
        end if;
        if not l_second_seq_t.exists(-1) and not l_second_seq_t.exists(l_second) then
          l_second := l_second_seq_t.next(l_second);
          if l_second is null then
            l_minute := l_minute + 1; reset(5); continue;
          end if;
        end if;
        l_level := 0;
      end if;
      
      if l_level = 0 then
        return combine(l_year, l_month, l_day, l_hour, l_minute, l_second);
      end if;
      
    end loop;
  end;
  
  /**
   * Разбор выражения (cron) на компоненты.
   * @param p_cron Выражение (cron).
   * @return Компоненты выражения.
   */
  function pre_parse(p_cron in varchar2) return te_cron_t
  is
    l_s pls_integer := 1;
    l_e pls_integer;
    l_cron_t te_cron_t;
  begin
    for i in 1 .. 7 loop
      if l_s is null then
        if i < 7 then
          throw(16, 'Неожиданный конец выражения.');
        end if;
        l_cron_t(i) := '';
      else
        l_e := instr(p_cron, ' ', l_s);
        if l_e is null then
          l_cron_t(i) := substr(p_cron, l_s);
        else
          l_cron_t(i) := substr(p_cron, l_s, l_e - l_s);
        end if;
        l_s := l_e + 1;
      end if;
    end loop;
    return l_cron_t;
  end;
  
  /**
   * Следующая дата выражения (cron).
   * @param p_date Текущая дата.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Календарь рабочих/выходных дней.
   * @return Следующая дата.
   */
  function next_date(p_date in date, p_cron in varchar2, p_calendar_id in number default null) return date
  is
    l_cron_t te_cron_t := pre_parse(p_cron);
  begin
    return next_date(p_date,
                     l_cron_t(1),
                     l_cron_t(2),
                     l_cron_t(3),
                     l_cron_t(4),
                     l_cron_t(5),
                     l_cron_t(6),
                     l_cron_t(7),
                     p_calendar_id => p_calendar_id);
  end;                  
  
  /**
   * Очистка от прерванных сессий.
   */
  procedure cleanup
  is
  begin
    for i in (select id, usid from t_cron_job where not usid is null) loop
      if not dbms_session.is_session_alive(i.usid) then
        update t_cron_job set usid = null where id = i.id and usid = i.usid;
        commit;
      end if;
    end loop;
  end;

  /**
   * Ожидание наступления заданного времени.
   * @param p_time Время.
   */  
  procedure semi_sleep(p_time in date)
  is
    l_sec number;    
  begin
    loop
      l_sec := (p_time - sysdate) / c_sec;
      exit when l_sec <= 0 or l_sec is null;
      for i in 1 .. l_sec loop
        if i = l_sec then
          dbms_lock.sleep(0.1);
        else
          dbms_lock.sleep(1);
        end if;
      end loop;
    end loop;
  end;
  
  /**
   * Логирование запуска задания.
   * @param p_id Идентификатор задания.
   * @param p_plan_time Планируемое время запуска.
   * @param p_start_time Время запуска.
   * @return Строка лога.
   */
  function start_log(p_id in number, p_plan_time in date, p_start_time in date) return t_cron_job_log%rowtype
  is
    l_cron_job_log t_cron_job_log%rowtype;
  begin
    get_session_info(l_cron_job_log.sid, l_cron_job_log.serial#, l_cron_job_log.audsid);
    begin
      insert into t_cron_job_log(id, job_id, plan_time, start_time, sid, serial#, audsid)
           values (job_log_seq.nextval, p_id, p_plan_time, p_start_time, l_cron_job_log.sid, l_cron_job_log.serial#, l_cron_job_log.audsid)
        returning id, job_id, plan_time, start_time into l_cron_job_log.id, l_cron_job_log.job_id, l_cron_job_log.plan_time, l_cron_job_log.start_time;
      commit;
    exception
      when dup_val_on_index then
        select * into l_cron_job_log from t_cron_job_log where job_id = p_id and plan_time = p_plan_time;
    end;
    return l_cron_job_log;
  end;
  
  /**
   * Логирование завершения задания.
   * @param p_log_id Идентификатор строки лога.
   * @param p_end_time Время завершения.
   * @param p_error_text Текст ошибки.
   */
  procedure end_log(p_log_id in number, p_end_time in date, p_error_text in clob default null)
  is
  begin
    update t_cron_job_log set end_time = p_end_time, error_text = p_error_text where id = p_log_id;
  end;
  
  /**
   * Получить текст задания.
   * @oaram p_id Идентификатор задания.
   * @return Текст задания.
   */
  function get_what(p_id in number) return varchar2 deterministic
  is
  begin
    return c_schema || '.pe_cron_job.run(' || p_id || ', next_date, broken);';
  end;
  
  /**
   * Очистка удаленных заданий и дубликатов.
   */
  function clear_jobs return pls_integer
  is
    l_s pls_integer := 0;
  begin
    for i in (select uj.job
                from user_jobs uj, t_cron_job j
               where uj.log_user = c_schema
                 and uj.priv_user = c_schema
                 and uj.schema_user = c_schema
                 and regexp_like(uj.what, c_what_regex)
                 and uj.what = c_schema || '.pe_cron_job.run(' || to_char(j.id (+)) || ', next_date, broken);'
                 and j.id is null)
    loop     
      begin
        dbms_job.remove(i.job);
        l_s := l_s + 1;
      exception
        when job_not_found then
          null; -- Игнорируем отсутствие задания.
      end;
    end loop;
    return l_s;
  end;
  
  /**
   * Синхронизация задания.
   * @param p_cron_job Строка задания.
   * @param p_only_check Только проверка необходимости синхронизации.
   * @return Результат синхронизации.
   */
  function sync_job(p_cron_job in t_cron_job%rowtype, p_only_check in boolean default false) return boolean
  is
    c_only_check constant boolean := nvl(p_only_check, false);
    l_user_job user_jobs%rowtype;
    l_sync boolean := false;
  begin
    if p_cron_job.usid is null or not dbms_session.is_session_alive(p_cron_job.usid) then -- Активные задания пропускаем.
      l_user_job.what := get_what(p_cron_job.id);
      for user_job in (select uj.*
                         from user_jobs uj
                        where uj.what = l_user_job.what
                     order by uj.job desc)
      loop
        if p_cron_job.enabled = 'N' or p_cron_job.next_date is null then
          l_sync := true;
          if not c_only_check then
            dbms_job.remove(user_job.job);
          end if;
        else
          if l_user_job.job is null then  
            begin
              if not user_job.interval is null or (user_job.next_date is null or not user_job.next_date = p_cron_job.next_date) or not user_job.broken = p_cron_job.broken then
                l_sync := true;
                if not c_only_check then
                  dbms_job.change(user_job.job, l_user_job.what, p_cron_job.next_date - c_wait_delay, null);
                  if p_cron_job.broken = 'Y' and user_job.broken = 'N' then
                    dbms_job.broken(user_job.job, true, next_date => p_cron_job.next_date - c_wait_delay);
                  elsif p_cron_job.broken = 'N' and user_job.broken = 'Y' then
                    dbms_job.broken(user_job.job, false, next_date => p_cron_job.next_date - c_wait_delay);
                  end if;
                end if;
              end if;
              l_user_job.job := user_job.job;
            exception
              when job_not_found then
                null;
            end;
          else -- Дубль задания.
            l_sync := true;
            if not c_only_check then
              begin
                dbms_job.remove(user_job.job);
              exception
                when job_not_found then
                  null; -- Игнорируем отсутствие задания.
              end;
            end if;
          end if;
        end if;
      end loop;
      if l_user_job.job is null and p_cron_job.enabled = 'Y' and not p_cron_job.next_date is null then
        l_sync := true;
        if not c_only_check then
          dbms_job.submit(l_user_job.job, l_user_job.what, next_date => p_cron_job.next_date - c_wait_delay);
          if p_cron_job.broken = 'Y' then
            dbms_job.broken(l_user_job.job, true, next_date => p_cron_job.next_date - c_wait_delay);
          end if;
        end if;
      end if;
    end if;
    return l_sync;
  end;
  
  /**
   * Синхронизация задания.
   * @param p_cron_job Строка задания.
   */
  procedure sync_job(p_cron_job in t_cron_job%rowtype)
  is
  begin
    if sync_job(p_cron_job) then
      null;
    end if;
  end;
  
  /**
   * Получить строку задания.
   * @param p_id Идентификатор задания.
   * @param p_throw Исключение при отсутствии задании.
   * @param p_lock Блокировать задание.
   * @return Строка задания.
   */
  function get(p_id in number, p_throw in boolean default true, p_lock in boolean default false) return t_cron_job%rowtype
  is
    l_cron_job t_cron_job%rowtype;
  begin
    begin
      if nvl(p_lock, false) then
        select * into l_cron_job from t_cron_job where id = p_id for update;
      else
        select * into l_cron_job from t_cron_job where id = p_id;
      end if;
    exception
      when no_data_found then
        if nvl(p_throw, true) then
          throw(20, 'Задание (' || p_id || ') не найдено.');
        end if;
    end;
    return l_cron_job;
  end;
  
  /**
   * Задание синхронизации.
   */
  procedure sync
  is
    l_cron_job t_cron_job%rowtype;
  begin
    if clear_jobs() > 0 then -- Очистка удаленных заданий.
      commit;
    end if;
    -- Синхронизация заданий.
    for job in (select * from t_cron_job) loop
      if sync_job(job, p_only_check => true) then
        begin
          l_cron_job := get(job.id, p_throw => false, p_lock => true);
          if not l_cron_job.id is null then
            sync_job(l_cron_job);
            commit;
          end if;
        exception
          when others then
            rollback;
        end;
      end if;
    end loop;
  end;
  
  /**
   * Получить время запуска текущего задания.
   * @return Время запуска текущего задания.
   */
  function get_next_date return date
  is
  begin
    if not dbms_job.is_jobq() then
      throw(17, 'Процедура может выполняться только из очереди заданий.');
    end if;
    return g_next_date;
  end;
  
  /**
   * Установить следующее время запуска текущего задания.
   * @param p_next_date Следующее время запуска.
   */
  procedure set_next_date(p_next_date in date)
  is
  begin
    if not dbms_job.is_jobq() then
      throw(18, 'Процедура может выполняться только из очереди заданий.');
    end if;
    g_next_date := p_next_date;
  end;
  
  /**
   * Процедура выполнения задания.
   * @param p_id Идентификатор задания.
   * @param p_next_date Следующее время запуска.
   * @param p_broken Приостановлено.
   */
  procedure run(p_id in number, p_next_date in out nocopy date, p_broken in out nocopy boolean)
  is
    l_cron_job t_cron_job%rowtype;
    l_cron_job_log t_cron_job_log%rowtype;
    l_error_text t_cron_job_log.error_text%type;
    l_next_date date;
    l_broken boolean;
  begin
    if not dbms_job.is_jobq() then
      throw(19, 'Процедура может выполняться только из очереди заданий.');
    end if;
    cleanup(); -- Очистка прерванных сессий.
    l_cron_job.usid := dbms_session.unique_session_id;
    loop
      if l_cron_job.id is null then -- Первый запуск.
        update t_cron_job
           set usid = case when next_date <= sysdate + c_wait_delay then l_cron_job.usid end
         where id = p_id
           and enabled = 'Y'
           and (usid is null or usid = l_cron_job.usid)
        returning id, operation, next_date, cron, calendar_id, nvl(ref_point, c_end_ref_point), rerun_delay, usid, broken
             into l_cron_job.id,
                  l_cron_job.operation,
                  l_cron_job.next_date,
                  l_cron_job.cron,
                  l_cron_job.calendar_id,
                  l_cron_job.ref_point,
                  l_cron_job.rerun_delay,
                  l_cron_job.usid,
                  l_cron_job.broken;
        commit;
      else -- Повторный запуск.
        begin
          select operation, cron, calendar_id, nvl(ref_point, c_end_ref_point), rerun_delay, broken
            into l_cron_job.operation,
                 l_cron_job.cron,
                 l_cron_job.calendar_id,
                 l_cron_job.ref_point,
                 l_cron_job.rerun_delay,
                 l_cron_job.broken
            from t_cron_job
           where id = p_id
             and enabled = 'Y'
             and usid = l_cron_job.usid;
        exception
          when no_data_found then
            l_cron_job.id := null; -- Отключен, удален, выполняется в другом процессе.
        end;
      end if;
      p_next_date := null;
      if l_cron_job.id is null or l_cron_job.usid is null then -- Работает, отключен, удален или время запуска не наступило.
        if l_cron_job.usid is null or l_cron_job.broken = 'Y' then -- Время запуска не наступило или приостановлен.
          p_next_date := l_cron_job.next_date - c_wait_delay;
          if l_cron_job.broken = 'Y' then
            p_broken := true;
          end if;
        end if;
        if not l_cron_job.usid is null then -- Работал, но отключен, удален, приостановлен, выполняется в другом процессе.
          update t_cron_job set usid = null where id = p_id and usid = l_cron_job.usid;
          commit;
        end if;
        exit;
      end if;
      -- Ожидание (кратковременное) запуска задания.
      l_cron_job_log.start_time := sysdate;
      semi_sleep(l_cron_job.next_date);
      if l_cron_job.next_date > l_cron_job_log.start_time then -- Произошло ожидание.
        continue; -- Проверка параметров задания перед непосредственным запуском.
      end if;
      -- Запуск задания.
      l_error_text := null;
      begin
        -- Время следующего запуска для переопределения.
        g_next_date := l_cron_job.next_date;
        -- Время запуска.
        l_cron_job_log.start_time := sysdate;
        l_cron_job_log := start_log(p_id, l_cron_job.next_date, l_cron_job_log.start_time);
        if l_cron_job_log.end_time is null then -- Задание не выполнялось в запланированное время.
          execute immediate 'begin ' || l_cron_job.operation || ' end;';
          l_cron_job_log.end_time := sysdate; -- Время завершения.
          end_log(l_cron_job_log.id, l_cron_job_log.end_time);
          commit;
        end if;
        if g_next_date > l_cron_job.next_date and not l_cron_job.cron is null then -- Переопределение времени следующего запуска.
          p_next_date := g_next_date;
        end if;
        -- Запуск ведомых заданий (при отсутствии ошибок выполнения).
        for job in (select *
                      from t_cron_job
                     where enabled = 'Y'
                       and lead_id = l_cron_job.id
                     order by decode(lead_delay, 0, null, lead_delay), id)
        loop
          begin
            update t_cron_job
               set next_date = l_cron_job_log.end_time + nvl(job.lead_delay, 0) * c_sec
             where id = job.id
               and enabled = job.enabled
               and lead_id = job.lead_id returning next_date, usid 
                                              into job.next_date, job.usid;
            if not job.next_date is null then
              if job.lead_delay > 0 then
                sync_job(job); -- Синхронизируем принудительно (не будет запускаться если работает в данный момент).
                commit;
              else
                run(job.id, l_next_date, l_broken);
              end if;
            end if;
          exception
            when others then
              rollback;
              -- Уведомления / логирование.
          end;
        end loop;
      exception
        when others then -- Ошибка выполнения задания.
          rollback;
          l_cron_job_log.end_time := sysdate;
          append(l_error_text, 'При выполнении задания произошла ошибка:' || chr(10) ||
                               dbms_utility.format_error_stack || chr(10) ||
                               dbms_utility.format_call_stack || chr(10) ||
                               dbms_utility.format_error_backtrace);
          end_log(l_cron_job_log.id, l_cron_job_log.end_time, p_error_text => l_error_text);
          commit;
          if l_cron_job.rerun_delay > 0 then -- Перезапуск при возникновении ошибки.
            p_next_date := l_cron_job_log.end_time + l_cron_job.rerun_delay * c_sec;
          end if;
      end;
      if p_next_date is null and not l_cron_job.cron is null then
        if l_cron_job.ref_point = c_start_ref_point then
          p_next_date := next_date(l_cron_job_log.start_time, l_cron_job.cron, p_calendar_id => l_cron_job.calendar_id);
        elsif l_cron_job.ref_point = c_end_ref_point then
          p_next_date := next_date(l_cron_job_log.end_time, l_cron_job.cron, p_calendar_id => l_cron_job.calendar_id);
        end if;
      end if;
      l_cron_job.next_date := p_next_date;
      p_next_date := p_next_date - c_wait_delay;
      if p_next_date is null or p_next_date > l_cron_job_log.end_time then
        l_cron_job.usid := null;
      end if;
      update t_cron_job 
         set next_date = l_cron_job.next_date,
             usid = l_cron_job.usid
       where id = p_id;
      commit;
      exit when l_cron_job.usid is null;
    end loop;
  exception
    when others then -- Критическая ошибка процесса.
      rollback;
      p_next_date := sysdate + c_critical_rerun_delay;
  end;
  
  /**
   * Создание задания.
   * @param p_caption Описание.
   * @param p_operation Процедура выполнения.
   * @param p_enabled Включено.
   * @param p_next_date Время следующего запуска.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Идентификатор календаря.
   * @param p_ref_point Точка отсчета времени слудующего запуска.
   * @param p_rerun_delay Задержка перезапуска при возникновении ошибки.
   * @param p_lead_id Идентификатор ведущего задания.
   * @param p_lead_delay Задержка запуска после ведущего задания.
   * @param p_broken Приостановлено.
   */
  function put(p_caption in varchar2,
               p_operation in varchar2,
               p_enabled in boolean default true,
               p_next_date in date default null,
               p_cron in varchar2 default null,
               p_calendar_id in number default null,
               p_ref_point in varchar2 default null, 
               p_rerun_delay in number default null,
               p_lead_id in number default null,
               p_lead_delay in number default null,
               p_broken in boolean default false) return t_cron_job%rowtype
  is
    l_cron_job t_cron_job%rowtype;
  begin
    l_cron_job.enabled := boolean_to(p_enabled);
    l_cron_job.broken := boolean_to(p_broken);
    insert into t_cron_job(id, enabled, caption, operation, next_date, cron, calendar_id, ref_point, rerun_delay, lead_id, lead_delay, broken)
         values (job_seq.nextval, l_cron_job.enabled, p_caption, p_operation, p_next_date, p_cron, p_calendar_id, p_ref_point, p_rerun_delay, p_lead_id, p_lead_delay, l_cron_job.broken)
      returning id, enabled, caption, operation, next_date, cron, calendar_id, ref_point, rerun_delay, lead_id, lead_delay, broken 
           into l_cron_job.id, l_cron_job.enabled, l_cron_job.caption, l_cron_job.operation, l_cron_job.next_date, l_cron_job.cron, l_cron_job.calendar_id, l_cron_job.ref_point, 
                l_cron_job.rerun_delay, l_cron_job.lead_id, l_cron_job.lead_delay, l_cron_job.broken;
    return l_cron_job;
  end;
  
  /**
   * Изменение задания.
   * @param p_job Строка задания.
   */
  procedure change(p_cron_job in t_cron_job%rowtype)
  is
  begin
    update t_cron_job
       set enabled = p_cron_job.enabled,
           caption = p_cron_job.caption,
           operation = p_cron_job.operation,
           next_date = p_cron_job.next_date,
           cron = p_cron_job.cron,
           calendar_id = p_cron_job.calendar_id,
           ref_point = p_cron_job.ref_point,
           rerun_delay = p_cron_job.rerun_delay,
           lead_id = p_cron_job.lead_id,
           lead_delay = p_cron_job.lead_delay,
           broken = p_cron_job.broken
     where id = p_cron_job.id;
  end;                    
  
  /**
   * Изменение задания.
   * @param p_id Идентификатор задания.
   * @param p_caption Описание.
   * @param p_operation Процедура выполнения.
   * @param p_enabled Включено.
   * @param p_next_date Время следующего запуска.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Идентификатор календаря.
   * @param p_ref_point Точка отсчета времени слудующего запуска.
   * @param p_rerun_delay Задержка перезапуска при возникновении ошибки.
   * @param p_lead_id Идентификатор ведущего задания.
   * @param p_lead_delay Задержка запуска после ведущего задания.
   * @param p_broken Приостановлено.
   */
  procedure change(p_id in number,
                   p_caption in varchar2,
                   p_operation in varchar2,
                   p_enabled in boolean,
                   p_next_date in date,
                   p_cron in varchar2,
                   p_calendar_id in number,
                   p_ref_point in varchar2, 
                   p_rerun_delay in number,
                   p_lead_id in number,
                   p_lead_delay in number,
                   p_broken in boolean)
  is
    l_cron_job t_cron_job%rowtype := get(p_id);
  begin
    l_cron_job.caption := nvl(p_caption, l_cron_job.caption);
    l_cron_job.operation := nvl(p_operation, l_cron_job.operation);
    l_cron_job.enabled := boolean_to(p_enabled);
    l_cron_job.next_date := p_next_date;
    l_cron_job.cron := p_cron;
    l_cron_job.calendar_id := p_calendar_id;
    l_cron_job.ref_point := p_ref_point;
    l_cron_job.rerun_delay := p_rerun_delay;
    l_cron_job.lead_id := p_lead_id;
    l_cron_job.lead_delay := p_lead_delay;
    l_cron_job.broken := boolean_to(p_broken);
    change(l_cron_job);
  end;
  
  /**
   * Установка процедуры выполнения.
   * @param p_id Идентфикатор задания.
   * @param p_operation Процедура выполнения.
   * @param p_caption Описание.
   */
  procedure set_operation(p_id in number, p_operation in varchar2, p_caption in varchar2 default null)
  is
    l_cron_job t_cron_job%rowtype := get(p_id);
  begin
    l_cron_job.caption := nvl(p_caption, l_cron_job.caption);
    l_cron_job.operation := p_operation;
    change(l_cron_job);
  end; 
  
  /**
   * Установка состояния.
   * @param p_id Идентфикатор задания.
   * @param p_enabled Включено.
   */
  procedure set_enabled(p_id in number, p_enabled in boolean)
  is
    l_cron_job t_cron_job%rowtype;
  begin
    if p_id is null then
      l_cron_job.enabled := boolean_to(p_enabled);
      update t_cron_job set enabled = l_cron_job.enabled;
    else
      l_cron_job := get(p_id);
      l_cron_job.enabled := boolean_to(p_enabled);
      change(l_cron_job);
    end if;
  end;
  
  /**
   * Установка времени следующего запуска.
   * @param p_id Идентфикатор задания.
   * @param p_next_date Время следующего запуска.
   */
  procedure set_next_date(p_id in number, p_next_date in date)
  is
    l_cron_job t_cron_job%rowtype := get(p_id);
  begin
    l_cron_job.next_date := p_next_date;
    change(l_cron_job);
  end;
  
  /**
   * Установка выражения (cron) и связанных параметров.
   * @param p_id Идентфикатор задания.
   * @param p_cron Выражение (cron).
   * @param p_calendar_id Идентификатор календаря.
   * @param p_ref_point Точка отсчета времени слудующего запуска.
   */
  procedure set_cron(p_id in number, p_cron in varchar2, p_calendar_id in number, p_ref_point in varchar2 default null)
  is
    l_cron_job t_cron_job%rowtype := get(p_id);
  begin
    l_cron_job.cron := p_cron;
    l_cron_job.calendar_id := p_calendar_id;
    l_cron_job.ref_point := p_ref_point;
    change(l_cron_job);
  end;
  
  /**
   * Установка задержки перезапуска при возникновении ошибки.
   * @param p_id Идентфикатор задания.
   * @param p_rerun_delay Задержка перезапуска при возникновении ошибки.
   */
  procedure set_rerun_delay(p_id in number, p_rerun_delay in number)
  is
    l_cron_job t_cron_job%rowtype := get(p_id);
  begin
    l_cron_job.rerun_delay := p_rerun_delay;
    change(l_cron_job);
  end;
  
  /**
   * Установка ведущего задания.
   * @param p_id Идентфикатор задания.
   * @param p_lead_id Идентификатор ведущего задания.
   * @param p_lead_delay Задержка запуска после ведущего задания.
   */
  procedure set_lead(p_id in number, p_lead_id in number, p_lead_delay in number)
  is
    l_cron_job t_cron_job%rowtype := get(p_id);
  begin
    l_cron_job.lead_id := p_lead_id;
    l_cron_job.lead_delay := p_lead_delay;
    change(l_cron_job);
  end;
  
  /**
   * Установка приостановки выполенения.
   * @param p_id Идентфикатор задания.
   * @param p_broken Приостановлено.
   */
  procedure set_broken(p_id in number, p_broken in boolean)
  is
    l_cron_job t_cron_job%rowtype;
  begin
    if p_id is null then
      l_cron_job.broken := boolean_to(p_broken);
      update t_cron_job set broken = l_cron_job.broken;
    else
      l_cron_job := get(p_id);
      l_cron_job.broken := boolean_to(p_broken);
      change(l_cron_job);
    end if;
  end;
  
  /**
   * Удаление задания.
   * @param p_id Идентификатор задания.
   */
  procedure remove(p_id in number)
  is
  begin
    delete from t_cron_job where id = p_id;
  end;
  
end;
/
