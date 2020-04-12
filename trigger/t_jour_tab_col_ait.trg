create or replace trigger t_jour_tab_col_ait after insert on t_jour_tab_col for each row
declare
begin
  pe_jour.put_partition('t_jour_col', :new.id);
end;
/
