create or replace trigger t_jour_tab_ait after insert on t_jour_tab for each row
declare
begin
  pe_jour.put_partition('t_jour_line', :new.id);
end;
/
