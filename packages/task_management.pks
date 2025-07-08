
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."TASK_MANAGEMENT" AS

    FUNCTION create_task (
        p_department_id  IN NUMBER,
        p_status_id      IN VARCHAR2,
        p_priority_id    IN VARCHAR2,
        p_name_ar        IN VARCHAR2,
        p_description    IN VARCHAR2,
        p_notes          IN VARCHAR2,
        p_start_date     IN DATE,
        p_end_date       IN DATE,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2,
        p_task_id       OUT NUMBER
    ) RETURN NUMBER;

    FUNCTION update_task (
        p_task_id        IN NUMBER,
        p_department_id  IN NUMBER,
        p_status_id      IN VARCHAR2,
        p_suspend_notes  IN VARCHAR2 DEFAULT NULL,
        p_priority_id    IN VARCHAR2,
        p_name_ar        IN VARCHAR2,
        p_description    IN VARCHAR2,
        p_notes          IN VARCHAR2,
        p_start_date     IN DATE,
        p_end_date       IN DATE,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION delete_task (
        p_task_id    IN NUMBER,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION create_employee (
        p_employee_dep        IN NUMBER,
        p_employee_name       IN VARCHAR2,
        p_employee_job        IN VARCHAR2,
        p_employee_active     IN NUMBER,
        p_employee_admin      IN NUMBER,
        p_employee_nid_type IN NUMBER,
        p_employee_phone      IN NUMBER,
        p_employee_nid      IN NUMBER,
        p_employee_email      IN VARCHAR2,
        p_employee_manager    IN NUMBER,
        p_lang                IN VARCHAR2 DEFAULT 'ar',
        p_message             OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION update_employee (
        p_employee_id         IN NUMBER,
        p_employee_dep        IN NUMBER,
        p_employee_name       IN VARCHAR2,
        p_employee_job        IN VARCHAR2,
        p_employee_active     IN NUMBER,
        p_employee_admin      IN NUMBER,
        p_employee_nid_type   IN NUMBER,
        p_employee_phone      IN NUMBER,
        p_employee_nid        IN NUMBER,
        p_employee_email      IN VARCHAR2,
        p_employee_manager    IN NUMBER,
        p_lang                IN VARCHAR2 DEFAULT 'ar',
        p_message             OUT VARCHAR2
    ) RETURN NUMBER;
 
END TASK_MANAGEMENT;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."TASK_MANAGEMENT" AS

    FUNCTION create_task (
        p_department_id  IN NUMBER,
        p_status_id      IN VARCHAR2,
        p_priority_id    IN VARCHAR2,
        p_name_ar        IN VARCHAR2,
        p_description    IN VARCHAR2,
        p_notes          IN VARCHAR2,
        p_start_date     IN DATE,
        p_end_date       IN DATE,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2,
        p_task_id       OUT NUMBER
    ) RETURN NUMBER  AS
        v_attachements  APEX_T_VARCHAR2;        
    BEGIN
        IF p_department_id IS NULL OR p_status_id IS NULL OR p_priority_id IS NULL OR p_name_ar IS NULL OR p_start_date IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        INSERT INTO MOBASHER_TASKS (DEPARTMENT_ID, STATUS_ID, PRIORITY_ID, NAME_AR, DESCRIPTION, NOTES, START_DATE, END_DATE)
            VALUES (p_department_id, p_status_id, p_priority_id, p_name_ar, p_description, p_notes, p_start_date, p_end_date)
        RETURNING ID INTO p_task_id;

        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
        END IF;

        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN 1;
    END;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION update_task (
        p_task_id        IN NUMBER,
        p_department_id  IN NUMBER,
        p_status_id      IN VARCHAR2,
        p_suspend_notes  IN VARCHAR2 DEFAULT NULL,
        p_priority_id    IN VARCHAR2,
        p_name_ar        IN VARCHAR2,
        p_description    IN VARCHAR2,
        p_notes          IN VARCHAR2,
        p_start_date     IN DATE,
        p_end_date       IN DATE,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2
    ) RETURN NUMBER AS
    BEGIN
        IF p_task_id IS NULL OR p_department_id IS NULL OR p_status_id IS NULL OR p_priority_id IS NULL OR p_name_ar IS NULL OR p_start_date IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        IF p_status_id = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'suspend', p_lookup_code => 'mobasher_tasks_status') AND 
           p_suspend_notes IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        UPDATE MOBASHER_TASKS
           SET DEPARTMENT_ID    = p_department_id,
               STATUS_ID        = p_status_id,
               SUSPEND_NOTES    = p_suspend_notes,
               PRIORITY_ID      = p_priority_id,
               NAME_AR          = p_name_ar,
               DESCRIPTION      = p_description,
               NOTES            = p_notes,
               START_DATE       = p_start_date,
               END_DATE         = p_end_date
         WHERE ID = p_task_id;

        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
        END IF;

        RETURN 1;
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_task (
        p_task_id    IN NUMBER,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN NUMBER  AS
    BEGIN
        DELETE FROM MOBASHER_TASK_ATTACHEMENTS
         WHERE TASK_ID = p_task_id;

        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -2;
        END IF;

        DELETE FROM MOBASHER_TASKS
         WHERE ID = p_task_id;

        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
        END IF;

        RETURN 1;
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION create_employee (
        p_employee_dep        IN NUMBER,
        p_employee_name       IN VARCHAR2,
        p_employee_job        IN VARCHAR2,
        p_employee_active     IN NUMBER,
        p_employee_admin      IN NUMBER,
        p_employee_nid_type IN NUMBER,
        p_employee_phone      IN NUMBER,
        p_employee_nid      IN NUMBER,
        p_employee_email      IN VARCHAR2,
        p_employee_manager    IN NUMBER,
        p_lang                IN VARCHAR2 DEFAULT 'ar',
        p_message             OUT VARCHAR2
    ) RETURN NUMBER IS
        v_user_id   NUMBER;
        v_user_type NUMBER;
        v_role_id   NUMBER;
        v_emp_id    NUMBER;
        v_count     NUMBER;
    BEGIN 
        IF p_employee_dep IS NULL OR p_employee_name IS NULL OR p_employee_job IS NULL OR p_employee_active IS NULL OR
           p_employee_admin IS NULL OR p_employee_nid_type IS NULL OR p_employee_phone IS NULL OR p_employee_nid IS NULL OR
           p_employee_email IS NULL OR p_employee_manager is null THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG,
                                USER_LANGUAGE_ID, USER_TYPE )
            VALUES ( p_employee_nid, p_employee_name, p_employee_phone, p_employee_phone, p_employee_nid, APP_USER_SECURITY.get_hash(p_employee_nid,p_employee_nid),
                     p_employee_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'administration', p_lookup_code => 'user_type') )
        RETURNING ID, USER_TYPE INTO v_user_id, v_user_type;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -4;
            ROLLBACK;
        END IF;

        INSERT INTO MOBASHER_EMPLOYEES ( USER_ID, USER_TYPE_ID ,DEPARTMENT_ID, NAME_AR, JOB, IS_ACTIVE, IS_ADMIN, NID_TYPE_ID, PHONE, NID, EMAIL, IS_MANAGER )
                    VALUES ( v_user_id, v_user_type ,p_employee_dep, p_employee_name, p_employee_job, p_employee_active, p_employee_admin, p_employee_nid_type, p_employee_phone,
                            p_employee_nid, p_employee_email, p_employee_manager ) 
        RETURNING ID INTO v_emp_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -6;
            ROLLBACK;
        END IF;

        -- ADD USER ROLE
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( v_user_id, APP_USER_SECURITY.role_id_by_name('Mobasher Administration'), 'Y', GET_CURRENT_DATE )
        RETURNING ID INTO v_role_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -7;
            ROLLBACK;
        END IF;
        
        RETURN 1;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;
    END create_employee;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION update_employee (
        p_employee_id        IN NUMBER,
        p_employee_dep        IN NUMBER,
        p_employee_name       IN VARCHAR2,
        p_employee_job        IN VARCHAR2,
        p_employee_active     IN NUMBER,
        p_employee_admin      IN NUMBER,
        p_employee_nid_type   IN NUMBER,
        p_employee_phone      IN NUMBER,
        p_employee_nid        IN NUMBER,
        p_employee_email      IN VARCHAR2,
        p_employee_manager    IN NUMBER,
        p_lang                IN VARCHAR2 DEFAULT 'ar',
        p_message             OUT VARCHAR2
    ) RETURN NUMBER IS
        v_user_id   NUMBER;
        v_user_type NUMBER;
        v_emp_id    NUMBER;
        v_count     NUMBER;
    BEGIN
        IF p_employee_dep IS NULL OR p_employee_name IS NULL OR p_employee_job IS NULL OR p_employee_active IS NULL OR
           p_employee_admin IS NULL OR p_employee_nid_type IS NULL OR p_employee_phone IS NULL OR p_employee_nid IS NULL OR
           p_employee_email IS NULL OR p_employee_manager is null THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        SELECT USER_ID
          INTO v_user_id
          FROM MOBASHER_EMPLOYEES
         WHERE ID = p_employee_id;

        IF p_employee_active = 0 THEN

            UPDATE MOBASHER_EMPLOYEES
               SET IS_ACTIVE = p_employee_active
            WHERE  ID = p_employee_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -3;
                ROLLBACK;
            END IF;

            UPDATE APP_USERS
               SET ACTIVE_FLAG = 'N'
             WHERE ID = v_user_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -4;
                ROLLBACK;
                SELECT USER_ID
                  INTO v_user_id
                  FROM MOBASHER_EMPLOYEES
                 WHERE ID = p_employee_id;
            END IF;

            UPDATE APP_USER_ROLES
               SET ENABLE_FLAG = 'N'
             WHERE USER_ID = v_user_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -5;
                ROLLBACK;
            END IF;
        END IF;
        IF p_employee_active = 1 THEN
        
            UPDATE MOBASHER_EMPLOYEES
               SET DEPARTMENT_ID = p_employee_dep,
                   NAME_AR       = p_employee_name,
                   JOB           = p_employee_job,
                   IS_ADMIN      = p_employee_admin,
                   NID_TYPE_ID   = p_employee_nid_type,
                   PHONE         = p_employee_phone,
                   NID           = p_employee_nid,
                   EMAIL         = p_employee_email,
                   IS_MANAGER    = p_employee_manager,
                   IS_ACTIVE     = p_employee_active
            WHERE  ID = p_employee_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -6;
                ROLLBACK;
            END IF;

            UPDATE APP_USERS
               SET ACTIVE_FLAG = 'Y'
             WHERE ID = v_user_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -7;
                ROLLBACK;
            END IF;

            UPDATE APP_USER_ROLES
               SET ENABLE_FLAG = 'Y'
             WHERE USER_ID = v_user_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -8;
                ROLLBACK;
            END IF;
        END IF;


        RETURN 1;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;
    END;
    
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END TASK_MANAGEMENT;
/