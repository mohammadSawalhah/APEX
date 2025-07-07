
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."ARRAY_FROM_OLDSCHOOL" (p_query_string in varchar2, p_key in varchar2) return apex_t_varchar2 is
    l_ret     apex_t_varchar2 := apex_t_varchar2();
    l_usenext boolean := false;
    l_isval   boolean := false;
    l_arr     apex_t_varchar2;
begin
  l_arr := apex_string.split(p_query_string, '\s*[=&]\s*');
  for i in 1 .. l_arr.count loop
    if l_usenext = true and l_isval = true then
      l_ret.extend;
      l_ret(l_ret.count) := l_arr(i);
      l_usenext := false;
    end if;

    if l_arr(i) = p_key and l_isval = false then
      l_usenext := true;
    end if;

    l_isval := not (l_isval);
  end loop;

  return l_ret;
end;
/