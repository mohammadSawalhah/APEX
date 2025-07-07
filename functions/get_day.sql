
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GET_DAY" ( 
    p_date IN DATE 
) RETURN varchar2 
    
AS 
v_day varchar2(50);
BEGIN 

SELECT TO_CHAR(p_date, 'DAY') into v_day FROM DUAL;

/*SELECT TO_CHAR(p_date, 'DY') into v_day FROM DUAL;*/



    RETURN v_day; 
END;
/