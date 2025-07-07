
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."QUERY_STRING_ARRAY" (p_key IN VARCHAR2) RETURN APEX_T_VARCHAR2 IS
    l_query_string APEX_T_VARCHAR2;
    l_return       APEX_T_VARCHAR2 := APEX_T_VARCHAR2();
BEGIN
    l_query_string := APEX_STRING.split(owa_util.get_cgi_env('QUERY_STRING'), '&');
        FOR i IN 1 .. l_query_string.count LOOP
            IF l_query_string(i) LIKE p_key || '=%' THEN
                DBMS_OUTPUT.PUT_LINE(l_query_string(i));
                IF replace(l_query_string(i), p_key || '=', '') IS NOT NULL THEN
                    l_return.EXTEND;
                    l_return(l_return.count) := replace(l_query_string(i), p_key || '=', '');
                END IF;
            END IF;
        END LOOP;
    RETURN l_return;
END;
/