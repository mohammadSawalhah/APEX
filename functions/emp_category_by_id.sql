
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."EMP_CATEGORY_BY_ID" (
     p_employee_id  IN NUMBER)
     RETURN NUMBER IS
        v_count         NUMBER;
        is_admin        NUMBER;
        dept_name       VARCHAR2(255);
        category_id     varchar(255);
    BEGIN 
        SELECT (SELECT NAME_AR FROM MOBASHER_DEPARTMENTS WHERE ID = DEPARTMENT_ID) 
          INTO dept_name
          FROM MOBASHER_EMPLOYEES WHERE ID = p_employee_id;
          
        SELECT (SELECT IS_ADMIN FROM MOBASHER_DEPARTMENTS WHERE ID = DEPARTMENT_ID) 
          INTO is_admin
          FROM MOBASHER_EMPLOYEES WHERE ID = p_employee_id;

        IF dept_name = 'عقارات' THEN
            SELECT ID INTO category_id FROM CATEGORIES WHERE CODE = 'real_estates';
        ELSIF dept_name = 'منقولات' THEN
            SELECT ID INTO category_id FROM CATEGORIES WHERE CODE = 'portable';
        -- ELSIF is_admin = 1 THEN
        --     SELECT listagg(ID, ',') INTO category_id FROM CATEGORIES WHERE CODE in ('portable', 'real_estates') ;
        ELSE
            category_id := -1;
        END IF;
    -- dbms_output.put_line(category_id);
        RETURN category_id;
END;
/