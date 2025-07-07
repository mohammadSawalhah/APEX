
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."HIJRAH_TO_GREGORIAN" ( 
    p_hijrah IN varchar2
) RETURN varchar2 
   
AS 
 v_gregorian varchar2(50);
BEGIN 

SELECT TO_CHAR(TO_DATE( p_hijrah ,'DD/MM/YYYY','NLS_CALENDAR=''arabic hijrah'''),
         'DD/MM/YYYY','NLS_CALENDAR=''gregorian''')  into v_gregorian
FROM   DUAL;


    RETURN v_gregorian; 
END;
/