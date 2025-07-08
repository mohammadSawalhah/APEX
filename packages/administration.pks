
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."ADMINISTRATION" AS
    FUNCTION mobasher_employee_id_by_user_id (
        p_user_id   NUMBER
    )RETURN NUMBER;

    FUNCTION is_emp_admin_by_id (
     p_employee_id  IN NUMBER
     )RETURN NUMBER;

END ADMINISTRATION;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."ADMINISTRATION" AS
    FUNCTION mobasher_employee_id_by_user_id (
        p_user_id   NUMBER
    )RETURN NUMBER AS
        l_employee_id NUMBER;
    BEGIN 
        SELECT ID INTO l_employee_id FROM MOBASHER_EMPLOYEES WHERE USER_ID = p_user_id;
        IF SQL%ROWCOUNT = 0 THEN 
            RETURN -2;
        END IF;

        RETURN l_employee_id;
    END mobasher_employee_id_by_user_id;

--<AWS_SECRET>=========================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION is_emp_admin_by_id (
     p_employee_id  IN NUMBER
     ) RETURN NUMBER IS
        v_result varchar(255);
    BEGIN 
        SELECT nvl(IS_ADMIN, 0)
          INTO v_result
          FROM MOBASHER_EMPLOYEES
         WHERE ID = p_employee_id;

       RETURN v_result;
    END is_emp_admin_by_id;



END ADMINISTRATION;
/