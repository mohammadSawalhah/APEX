
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GREGORIAN_TO_HIJRAH" ( 
    p_gregorian IN varchar2 
) RETURN varchar2 
    
AS 
v_hijrah varchar2(50);
BEGIN 

select to_char(to_date(p_gregorian,'DD/MM/YYYY','NLS_CALENDAR=''Gregorian'''),
                 'DD/MM/YYYY','NLS_CALENDAR=''Arabic Hijrah''') into v_hijrah
   from dual;

/*select to_char(to_date(p_gregorian,'DD/MM/YYYY','NLS_CALENDAR=''Gregorian'''),
                 'DD/MONTH/YYYY','NLS_CALENDAR=''Arabic Hijrah''') into v_hijrah
   from dual;
*/

    RETURN v_hijrah; 
END;
/