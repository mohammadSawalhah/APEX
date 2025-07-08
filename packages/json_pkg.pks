
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."JSON_PKG" AS  
    FUNCTION get_keys(
      value IN CLOB
    ) RETURN SYS.ODCIVARCHAR2LIST PIPELINED;
    
    FUNCTION get_value(
      value IN CLOB,
      path  IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION dynamic_parse(
        sJson clob
    ) RETURN sys_refcursor;
    
END JSON_PKG;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."JSON_PKG" AS  
    FUNCTION get_keys(
      value IN CLOB
    ) RETURN SYS.ODCIVARCHAR2LIST PIPELINED
    IS
      js   JSON_OBJECT_T := JSON_OBJECT_T( value );
      keys JSON_KEY_LIST;
    BEGIN
      keys := js.get_keys();
      FOR i in 1 .. keys.COUNT LOOP
        PIPE ROW ( keys(i) );
      END LOOP;
    END get_keys;

--<AWS_SECRET>=========================================
--=============================END OF THE FUNCTION=================================
--=================================================================================

    FUNCTION get_value(
      value IN CLOB,
      path  IN VARCHAR2
    ) RETURN VARCHAR2
    IS
      js JSON_OBJECT_T := JSON_OBJECT_T( value );
    BEGIN
      RETURN js.get_string( path );
    END get_value;

--=================================================================================
--=============================END OF THE FUNCTION=================================
--=================================================================================

    FUNCTION dynamic_parse(
        sJson CLOB
    ) RETURN sys_refcursor
      IS
      sGuide CLOB;
      sSQL   CLOB;
      rc     sys_refcursor;
    BEGIN 
      -- initial static part of query
      sSQL := q'^select jt.*
                from json_table (:sJson, '$'
                   columns
                      ID varchar2(32) path '$.ID',
                      ID_ORD varchar2(32) path '$.ID_ORD',
                        nested path '$.Vals[*]'
                              columns (^';

      select json_dataguide(jt.vals)
      into sGuide
      from json_table (sJson, '$'
        columns
            VALS clob format json path '$.Vals'
        ) jt;

      for r in (
        select jt.*
        from json_table (sGuide format json, '$[*]'
          columns
            indx for ordinality,
            path varchar2(30) path '$."o:path"',
            type varchar2(30) path '$.type',
            length number path '$."o:length"'
        ) jt
      )
      loop
        sSQL := sSQL || case when r.indx > 1 then ',' end
          || chr(10) || '                 '
          || '"' || substr(r.path, 3) || '"'
          -- may need to handle other data type more carefully too
          || ' ' || case when r.type = 'string' then 'varchar2(' || r.length || ')' else r.type end
          || q'^ path '^' || r.path || q'^'^';
      end loop;

      -- final static part of query
      sSQL := sSQL || chr(10) || '              )) jt';
      dbms_output.put_line(sSQL);

      open rc for sSQL using sJson;
      return rc;
    END dynamic_parse;

--=================================================================================
--=============================END OF THE FUNCTION=================================
--=================================================================================

END JSON_PKG;
/