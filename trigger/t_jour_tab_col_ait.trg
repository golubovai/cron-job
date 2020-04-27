create or replace trigger t_jour_tab_col_ait after insert or delete on t_jour_tab_col for each row
declare
begin
  if inserting then
    pe_jour.put_partition('t_jour_col', :new.id);
  elsif deleting then
    pe_jour.drop_partition('t_jour_col', :old.id);
  end if;
end;
/
