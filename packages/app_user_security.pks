
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."APP_USER_SECURITY" AS   
    FUNCTION get_hash (   
        p_username  IN  VARCHAR2,   
        p_password  IN  VARCHAR2   
    ) RETURN VARCHAR2;

/*  PROCEDURE add_user (
        p_username  IN  VARCHAR2,   
        p_password  IN  VARCHAR2
    );   
*/   
      PROCEDURE change_password (   
        p_username      IN  VARCHAR2,   
        p_old_password  IN  VARCHAR2,   
        p_new_password  IN  VARCHAR2  , 
        p_lang          IN VARCHAR2 default 'ar'   
    );

    PROCEDURE valid_user (   
        p_username  IN  VARCHAR2,   
        p_password  IN  VARCHAR2, 
        p_lang          IN VARCHAR2 default 'ar'   
    );
    
    FUNCTION valid_user (   
        p_username  IN  VARCHAR2,   
        p_password  IN  VARCHAR2   
    ) RETURN BOOLEAN;

    PROCEDURE valid_user_by_user_type (
        p_username  IN  VARCHAR2,
        p_password  IN  VARCHAR2,
        p_lang      IN VARCHAR2 default 'ar'
    );
    
    FUNCTION valid_user_by_user_type (
        p_username  IN  VARCHAR2,
        p_password  IN  VARCHAR2
    ) RETURN BOOLEAN;
    
    FUNCTION valid_Authorization (   
        p_username  IN  VARCHAR2,   
        p_page_id   IN  NUMBER,  
        p_item_name IN  VARCHAR2    
    ) RETURN BOOLEAN;   
    
    PROCEDURE app_add_privilliges (  
        p_prvileges_ids  IN  VARCHAR2,  
        p_role_id        IN  NUMBER,  
        p_app_user       IN  VARCHAR2,  
        p_app_id         IN  NUMBER
    );  
    
    FUNCTION app_validate_privilege (  
        p_app_id   IN  NUMBER,  
        p_page_id  IN  NUMBER,  
        p_user     IN  VARCHAR2  
    ) RETURN BOOLEAN;    
    
    FUNCTION user_personal_name (  
        p_user_id     NUMBER  
    ) RETURN VARCHAR2;   
    
    FUNCTION Personal_name_From_User (  
        p_user_name     VARCHAR2  
    ) RETURN VARCHAR2;
    
    FUNCTION user_menu_privilege (  
        p_user_id       IN  NUMBER,  
        p_object_type   IN  VARCHAR2,  
        p_object_value  IN  NUMBER,  
        p_page_id       IN NUMBER  
    ) RETURN NUMBER;
    
    FUNCTION user_is_iam (  
        p_user_id    IN NUMBER  
    ) RETURN NUMBER;
    
    FUNCTION user_role_iam (  
        p_user_id    IN NUMBER  
    ) RETURN NUMBER;

    FUNCTION ins_signup (
        p_client_id_no  IN NUMBER,
        p_phone         IN VARCHAR2,
        p_whats_phone   IN VARCHAR2,
        p_user_name     IN VARCHAR2,
        p_password      IN VARCHAR2,
        p_password_conf IN VARCHAR2,
        p_email         IN VARCHAR2,
        p_language      IN NUMBER,
        p_user_role     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_user_id      OUT NUMBER,
        p_message      OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION check_otp (
        p_phone     IN VARCHAR2,   
        p_otp       IN NUMBER,   
        p_lang      IN VARCHAR2 DEFAULT 'ar',
        p_success  OUT VARCHAR2,   
        p_message  OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION role_id_by_name (
        p_role_name   IN VARCHAR2
    ) RETURN NUMBER;

    -- FUNCTION role_name_by_id (
    --     p_role_id   IN NUMBER
    -- ) RETURN VARCHAR2;

END APP_USER_SECURITY;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."APP_USER_SECURITY" AS   
   
    FUNCTION get_hash (   
        p_username  IN  VARCHAR2,   
        p_password  IN  VARCHAR2   
    ) RETURN VARCHAR2 AS   
    BEGIN
        RETURN DBMS_CRYPTO.hash (
                    src => UTL_I18N.string_to_raw (upper(p_username) || 'client' || upper(p_password), 'AL32UTF8'),
                    typ => DBMS_CRYPTO.hash_md5
                );                                                
        -- RETURN DBMS_OBFUSCATION_TOOLKIT.md5 (
        --             input_string => upper(p_username)  
        --             || 'client'  
        --             || upper(p_password)
        --         );                                                       
    END get_hash;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

/*  PROCEDURE add_user (p_username  IN  VARCHAR2,   
                      p_password  IN  VARCHAR2) AS   
  BEGIN   
    INSERT INTO app_users (   
      id,   
      username,   
      password   
    )   
    VALUES (   
      app_users_seq.NEXTVAL,   
      UPPER(p_username),   
      get_hash(p_username, p_password)   
    );   
    COMMIT;   
  END add_user;   
 */   

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

      PROCEDURE change_password (   
        p_username      IN VARCHAR2,   
        p_old_password  IN VARCHAR2,   
        p_new_password  IN VARCHAR2, 
        p_lang          IN VARCHAR2 default 'ar'   
    ) AS   
        v_rowid ROWID;   
    BEGIN   
        SELECT ROWID
          INTO v_rowid
          FROM app_users
         WHERE upper(user_name) = upper(p_username)
           AND password = get_hash(p_username, p_old_password)
        FOR UPDATE;

        UPDATE app_users   
           SET password = get_hash(p_username, p_new_password)  
         WHERE ROWID = v_rowid;   
        COMMIT;
        
    EXCEPTION   
        WHEN no_data_found THEN   
            raise_application_error(-20000, SYSTEM_CONTROLS.get_translation(p_code => 'invalid_user_pass', p_lang => p_lang));
    END change_password;   

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    PROCEDURE valid_user (   
        p_username  IN  VARCHAR2,   
        p_password  IN  VARCHAR2, 
        p_lang      IN  VARCHAR2 default 'ar'   
    ) AS   
        v_dummy VARCHAR2(1);   
    BEGIN
        SELECT '1'   
          INTO v_dummy   
          FROM app_users   
         WHERE upper(user_name) = upper(p_username)
           AND PASSWORD = get_hash(p_username, p_password);
        --    AND NVL(STATUS, 0) = 1; 
    EXCEPTION   
        WHEN no_data_found THEN   
            raise_application_error(-20000, SYSTEM_CONTROLS.get_translation(p_code => 'invalid_user_pass', p_lang => p_lang));    
    END valid_user;   

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION valid_user (   
        p_username  IN  VARCHAR2,   
        p_password  IN  VARCHAR2   
    ) RETURN BOOLEAN AS   
        v_user_is_iam   NUMBER;  
        v_role_is_iam   NUMBER;    
        v_role_is_saudi NUMBER;   
        v_exist         NUMBER;  
        v_user_id       NUMBER;  
    BEGIN
        -- FOR INTEGRATE WITH CURRENT SYSTEM
        IF v('IS_API') = 1 THEN
            RETURN true;
        END IF;

        valid_user(upper(p_username), p_password);
        RETURN true;   
    EXCEPTION   
        WHEN OTHERS THEN   
            RETURN false;   
    END valid_user;   

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    PROCEDURE valid_user_by_user_type (
        p_username  IN  VARCHAR2,
        p_password  IN  VARCHAR2,
        p_lang      IN VARCHAR2 default 'ar'
    ) AS
        v_dummy VARCHAR2(1);
    BEGIN
        
        SELECT '1'
          INTO v_dummy
          FROM app_users
         WHERE upper(user_name) = upper(p_username)
           AND PASSWORD = get_hash(p_username, p_password)
           AND USER_TYPE = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'transportation_user', p_lookup_code => 'user_type');
        --    AND NVL(STATUS, 0) = 1; 
    EXCEPTION   
        WHEN no_data_found THEN
            raise_application_error(-20000, SYSTEM_CONTROLS.get_translation(p_code => 'invalid_user_pass', p_lang => p_lang));
    END;
--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================
    
    FUNCTION valid_user_by_user_type (
        p_username  IN  VARCHAR2,
        p_password  IN  VARCHAR2
    ) RETURN BOOLEAN AS
        v_user_id  NUMBER;
    BEGIN
        -- FOR INTEGRATE WITH CURRENT SYSTEM
        IF v('IS_API') = 1 THEN
            RETURN true;
        END IF;

        valid_user_by_user_type(upper(p_username) || ' -TRANSPORTATION', p_password);
        RETURN true;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN false;
    END;


--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION valid_Authorization (   
        p_username  IN  VARCHAR2,   
        p_page_id   IN  NUMBER,  
        p_item_name IN  VARCHAR2    
    ) RETURN BOOLEAN  AS   
    BEGIN   
        --valid_user(upper(p_username), p_password);   
        RETURN true;   
    EXCEPTION   
        WHEN OTHERS THEN   
            RETURN false;   
    END valid_Authorization;   

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    PROCEDURE app_add_privilliges (  
        p_prvileges_ids  IN  VARCHAR2,  
        p_role_id        IN  NUMBER,  
        p_app_user       IN  VARCHAR2,  
        p_app_id         IN  NUMBER  
    ) AS
        CURSOR privs_ids IS  
        SELECT ID  
          FROM APP_APPLICATION_PRIVILEGES  
         START WITH ID IN (
                SELECT column_value  
                  FROM TABLE ( APEX_STRING.split(p_prvileges_ids, ':') ) )  
        CONNECT BY  
            PRIOR LIST_ENTRY_ID = LIST_ENTRY_PARENT_ID  
        ORDER SIBLINGS BY  
            DISPLAY_SEQUENCE;

        l_count NUMBER;  
    BEGIN
        DELETE FROM APP_ROLE_PRIVILEGES
         WHERE ROLE_ID = p_role_id
           AND PRIVILEGE_ID IN (SELECT ID FROM APP_APPLICATION_PRIVILEGES WHERE APPLICATION_ID = p_app_id);
        --    AND PRIVILEGE_ID IN (SELECT PRIVILEGE_ID FROM APP_APPLICATION_PRIVILEGES WHERE APPLICATION_ID = p_app_id);
        COMMIT;

        FOR i IN privs_ids LOOP
            SELECT COUNT(1)
              INTO l_count
              FROM dual
             WHERE i.ID IN (
                    SELECT column_value
                      FROM TABLE ( APEX_STRING.split(p_prvileges_ids, ':') ) );

            IF l_count = 1 THEN
                INSERT INTO app_role_privileges (
                    role_id,
                    privilege_id,
                    created_by,
                    creation_date
                ) VALUES (
                    p_role_id,
                    i.ID,
                    p_app_user,
                    GET_CURRENT_DATE
                );
            END IF;
        END LOOP;
    END app_add_privilliges;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION app_validate_privilege (
        p_app_id   NUMBER,
        p_page_id  NUMBER,
        p_user     VARCHAR2
    ) RETURN BOOLEAN IS
        v_access_priv  NUMBER;
        v_count        NUMBER;
    BEGIN
        IF p_app_id IN ( 113, 136 ) THEN
            RETURN true;
        END IF;

        IF p_app_id IN ( 102, 103, 124, 118, 136 ) AND p_page_id IN (9998, 2008) THEN
            RETURN true;
        END IF;

        BEGIN
            SELECT 1
              INTO v_count
              FROM APP_USERS
             WHERE upper(user_name) = upper(p_user)
               AND get_current_date BETWEEN START_DATE AND NVL(END_DATE,get_current_date)
               AND NVL(ACTIVE_FLAG,'N') = 'Y';
        EXCEPTION
            WHEN no_data_found THEN
                RETURN false;
        END;

        SELECT COUNT(1)  
          INTO v_count  
          FROM app_application_privileges  
         WHERE application_id = p_app_id  
           AND page_id = p_page_id;

        IF v_count = 0 THEN
            RETURN true;  
        ELSE
            SELECT nvl(MAX(1), 0)  
              INTO v_access_priv  
              FROM app_users                   a,  
                   app_user_roles              b,  
                   app_roles                   c,  
                   app_application_privileges  d,  
                   app_role_privileges         e  
             WHERE upper(user_name) = upper(p_user)  
              AND a.ID = b.user_id
              AND b.role_id = c.ID
              AND d.ID = e.privilege_id
              AND c.ID = e.role_id
              AND b.enable_flag = 'Y'
              AND c.active_flag = 'Y'
              AND d.application_id = p_app_id
              AND ( d.page_id = p_page_id OR p_page_id IN ( 9999/*, 9998, 2008, 2*/ ) );

            IF v_access_priv > 0 THEN
                RETURN true; 
            ELSE
                RETURN false;
            END IF;
        END IF;
    END app_validate_privilege;

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION user_personal_name (  
        p_user_id   NUMBER  
    ) RETURN VARCHAR2 IS  
        v_user_personal_name  VARCHAR2(255);  
    BEGIN  
        SELECT PERSONAL_NAME  
          INTO v_user_personal_name  
          FROM APP_USERS  
         WHERE ID = p_user_id;

        RETURN v_user_personal_name;  
    EXCEPTION  
        WHEN no_data_found THEN  
           RETURN NULL;  
    END user_personal_name;  

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION personal_name_from_user (  
            p_user_name  VARCHAR2  
    ) RETURN VARCHAR2 IS  
        v_user_personal_name  VARCHAR2(255);  
    BEGIN  
        SELECT max(PERSONAL_NAME)  
          INTO v_user_personal_name  
          FROM APP_USERS  
         WHERE upper(user_name) = upper(p_user_name);

        RETURN v_user_personal_name;  
    END PERSONAL_NAME_FROM_USER;  

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION user_menu_privilege (  
        p_user_id       IN NUMBER,  
        p_object_type   IN VARCHAR2,  
        p_object_value  IN NUMBER,  
        p_page_id       IN NUMBER  
    ) RETURN NUMBER  IS  
        v_user_personal_name   VARCHAR2(255);  
    BEGIN  
        CASE p_page_id  
            WHEN 151 THEN/*  
                SELECT NVL(PERSONAL_NAME,0)  
                INTO v_user_personal_name  
                FROM  
                    app_users  
                WHERE  
                    upper(user_name) = upper(p_user_name);*/  
                RETURN 1;    
            ELSE      
                RETURN 1;      
        END CASE;  
        RETURN 1;  
    END user_menu_privilege;  

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION user_is_iam (  
        p_user_id       IN NUMBER  
    ) RETURN NUMBER  IS  
        v_user_is_iam   NUMBER;  
        v_role_is_iam   NUMBER;    
    BEGIN  
        SELECT NVL(IS_REQUIRED_NAFATH,0)  
          INTO v_role_is_iam  
          FROM APP_ROLES AR  
         WHERE ar.ID IN (SELECT aur.ROLE_ID FROM APP_USER_ROLES aur WHERE aur.USER_ID = p_user_id)
           AND EXISTS (SELECT arp.ROLE_ID 
                         FROM APP_ROLE_PRIVILEGES arp 
                        WHERE arp.ROLE_ID = ar.ID 
                          AND arp.PRIVILEGE_ID IN (SELECT aar.ID 
                                                     FROM APP_APPLICATION_PRIVILEGES aar 
                                                    WHERE aar.APPLICATION_ID = v('APP_ID')));  
        IF v_role_is_iam = 1 THEN   
            SELECT NVL(IS_IAM,0)   
              INTO v_user_is_iam  
              FROM APP_USERS   
             WHERE ID = p_user_id;

            RETURN v_user_is_iam;      
        END IF;
             
        RETURN 1;  
    END user_is_iam;  

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION user_role_iam (  
        p_user_id       IN NUMBER  
    ) RETURN NUMBER  IS  
        v_user_is_iam   NUMBER;  
        v_role_is_iam   NUMBER;    
        v_exist         NUMBER;    
    BEGIN  
        SELECT NVL(IS_REQUIRED_NAFATH,0) 
          INTO v_role_is_iam  
          FROM APP_ROLES ar  
         WHERE ar.ID IN (SELECT aur.ROLE_ID FROM APP_USER_ROLES aur WHERE aur.USER_ID = p_user_id)
          AND EXISTS (SELECT arp.ROLE_ID FROM APP_ROLE_PRIVILEGES arp WHERE arp.ROLE_ID = ar.ID AND arp.PRIVILEGE_ID IN (SELECT aar.ID FROM APP_APPLICATION_PRIVILEGES aar WHERE aar.APPLICATION_ID = v('APP_ID')));  
        
        IF v_role_is_iam = 1 THEN   
            SELECT NVL(IS_IAM,0)   
              INTO v_user_is_iam  
              FROM APP_USERS   
             WHERE ID = p_user_id;      
        END IF;
        
        RETURN 1;  
    EXCEPTION  
        WHEN OTHERS THEN   
          RETURN 0;     
    END user_role_iam;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION ins_signup (
        p_client_id_no  IN NUMBER,
        p_phone         IN VARCHAR2,
        p_whats_phone   IN VARCHAR2,
        p_user_name     IN VARCHAR2,
        p_password      IN VARCHAR2,
        p_password_conf IN VARCHAR2,
        p_email         IN VARCHAR2,
        p_language      IN NUMBER,
        p_user_role     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_user_id      OUT NUMBER,
        p_message      OUT VARCHAR2
    ) RETURN NUMBER IS
        v_user_id    NUMBER;
        v_count      NUMBER;
    BEGIN        
        IF p_client_id_no IS NULL OR p_phone IS NULL OR p_user_name IS NULL OR p_password IS NULL OR p_password_conf IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;
        
        -- CHECK IF CLIENT IDENTITY NUMBER IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE CLIENT_ID_NO = p_client_id_no;
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'client_id_no_exists', p_lang => p_lang);
            RETURN -3;
        END IF;

        -- CHECK IF CLIENT PHONE NUMBER IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE PHONE = p_phone;
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'client_phone_exists', p_lang => p_lang);
            RETURN -4;
        END IF;

        -- CHECK IF THE PASSWORD AND PASSWORD CONFIRMATION ARE IDENTICAL
        IF p_password <> p_password_conf THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'password_do_not_match_password_conf', p_lang => p_lang);
            RETURN -5;
        END IF;
        
        -- ADD THE USER
        INSERT INTO APP_USERS ( CLIENT_ID_NO, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, STATUS, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID )
            VALUES ( p_client_id_no, p_phone, p_whats_phone, p_user_name, GET_HASH(p_user_name, p_password), p_email, GET_CURRENT_DATE, 0, 'Y', 'N', 'Y', p_language )
        RETURNING ID INTO v_user_id;
        COMMIT;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -6;
        END IF;

        p_user_id := v_user_id;

        -- ADD THE ROLE TO THE USER
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( v_user_id, p_user_role, 'Y', GET_CURRENT_DATE);

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -7;
        END IF;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN -1;

    END ins_signup;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION check_otp (
        p_phone     IN VARCHAR2,   
        p_otp       IN NUMBER,   
        p_lang      IN VARCHAR2 DEFAULT 'ar',
        p_success  OUT VARCHAR2,   
        p_message  OUT VARCHAR2
    ) RETURN NUMBER IS
        v_phone          VARCHAR2(255);   
        v_error_code     NUMBER;   
        v_error_message  VARCHAR2(255);   
        v_result         NUMBER;   
    BEGIN   
        IF p_phone IS NULL OR p_otp IS NULL THEN
            p_success := 'false';
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data' , p_lang => p_lang);
            RETURN -2;
        END IF;
        
        SELECT COUNT(1)   
          INTO v_result   
          FROM BUYER_CONFIRMATION_CODES    
         WHERE PHONE = v_phone
           AND CODE = p_otp; 

            IF v_result > 0 THEN   
                SELECT COUNT(1)   
                  INTO v_result   
                  FROM BUYER_CONFIRMATION_CODES    
                 WHERE PHONE = v_phone   
                   AND CODE = p_otp   
                   AND EXPIRY_DATE >= get_current_date;    

                IF v_result > 0 THEN   
                    p_success := 'true';   
                    p_message := SYSTEM_CONTROLS.get_translation (p_code =>'success' , p_lang =>  p_lang);   
                    RETURN v_result ;    
                ELSE   
                    p_success := 'false';   
                    p_message := SYSTEM_CONTROLS.get_translation(p_code => 'code_expired' , p_lang => p_lang);
                    RETURN -3;
                END IF;
            ELSE
                p_success := 'false';
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_code' , p_lang => p_lang);
                RETURN -4;
            END IF;

        RETURN -5;
    EXCEPTION   
        WHEN OTHERS THEN          
            SYSTEM_CONTROLS.ERROR_LOGS (
                p_ERROR_TYPE => 'SQL_ERROR',
                p_PROCESS_NAME => 'APP_USER_SECURITY.check_otp',
                p_ERROR_CODE => sqlcode,
                p_ERROR_MESSAGE => sqlerrm,
                p_LOGGER_NAME => nvl(v('APP_USER'), user),
                p_OBJECT_TYPE => 'p_otp_type',
                p_OBJECT_ID => v_phone
            );
            RETURN -1;
    END check_otp;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION valid_user_phone (
        p_username  IN  VARCHAR2,
        p_password  IN  VARCHAR2,
        p_lang      IN  VARCHAR2 default 'ar'
    ) RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT 1
          INTO v_count
          FROM BUYER_CONFIRMATION_CODES    
         WHERE PHONE = p_username   
           AND CODE = p_password   
           AND EXPIRY_DATE >= get_current_date;
    EXCEPTION   
        WHEN no_data_found THEN   
            raise_application_error(-20000, SYSTEM_CONTROLS.get_translation(p_code => 'invalid_user_pass', p_lang => p_lang));    
    END valid_user_phone;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION role_id_by_name (
        p_role_name   IN VARCHAR2
    ) RETURN NUMBER IS
        v_role_id  NUMBER;
    BEGIN
        SELECT ID
          INTO v_role_id
          FROM APP_ROLES
         WHERE REPLACE(UPPER(ROLE_NAME), ' ', '_') = REPLACE((UPPER(p_role_name)), ' ', '_');
        
        RETURN v_role_id;
    END role_id_by_name;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    -- FUNCTION role_name_by_id (
    --     p_role_id   IN NUMBER
    -- ) RETURN VARCHAR2 IS
    --     v_role_name  VARCHAR2;
    -- BEGIN
    --     SELECT (UPPER(p_role_name)
    --       INTO v_role_name
    --       FROM APP_ROLES
    --      WHERE ID = p_role_id;
        --  WHERE REPLACE(UPPER(ROLE_NAME), ' ', '_') = REPLACE((UPPER(p_role_name)), ' ', '_');
        
    --     RETURN v_role_name;
    -- END role_name_by_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END APP_USER_SECURITY;
/