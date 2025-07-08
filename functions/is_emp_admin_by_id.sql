
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."IS_EMP_ADMIN_BY_ID" (
     p_employee_id  IN NUMBER)
     RETURN NUMBER IS
        v_result varchar(255);
        is_admin NUMBER;
    BEGIN 
        SELECT nvl(IS_ADMIN, 0)
          INTO v_result
          FROM MOBASHER_EMPLOYEES
         WHERE ID = p_employee_id;

       RETURN v_result;
end;
/