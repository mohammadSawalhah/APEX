
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."AT_GET_ENV_PARAMETER" (p_attribute in varchar2) return varchar2  as
    p_regex varchar2(254) := '=([^&]*)';
    p_result varchar2(254);
    l_query_strings varchar2(254):= owa_util.get_cgi_env('QUERY_STRING');
begin
    if p_attribute is not null then
        p_result := regexp_substr(l_query_strings, p_attribute || p_regex);
        p_result := substr(p_result, instr(p_result, '=') + 1);
    end if;
    return p_result;
end at_get_env_parameter;
/