
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."BUYER" AS

    FUNCTION create_buyer (
        p_buyer_type       IN NUMBER,
        p_name_ar           IN VARCHAR2,
        p_name_en           IN VARCHAR2,
        p_trade_name_ar     IN VARCHAR2,
        p_trade_name_en     IN VARCHAR2,
        p_unique_name       IN VARCHAR2,
        p_identity_type     IN NUMBER,
        p_identity_id       IN NUMBER,
        p_email             IN VARCHAR2,
        p_country_id        IN NUMBER,
        p_emp_name_ar       IN VARCHAR2,
        p_emp_name_en       IN VARCHAR2,
        p_emp_identity_type IN NUMBER,
        p_emp_identity_id   IN NUMBER,
        p_emp_job           IN VARCHAR2,
        p_emp_email         IN VARCHAR2,
        p_emp_phone         IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'ar',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION delete_buyer (
        p_buyer_id  IN NUMBER,
        p_message   OUT VARCHAR2
    ) RETURN NUMBER;

END buyer;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."BUYER" AS   

    FUNCTION create_buyer (
        p_buyer_type       IN NUMBER,
        p_name_ar           IN VARCHAR2,
        p_name_en           IN VARCHAR2,
        p_trade_name_ar     IN VARCHAR2,
        p_trade_name_en     IN VARCHAR2,
        p_unique_name       IN VARCHAR2,
        p_identity_type     IN NUMBER,
        p_identity_id       IN NUMBER,
        p_email             IN VARCHAR2,
        p_country_id        IN NUMBER,
        p_emp_name_ar       IN VARCHAR2,
        p_emp_name_en       IN VARCHAR2,
        p_emp_identity_type IN NUMBER,
        p_emp_identity_id   IN NUMBER,
        p_emp_job           IN VARCHAR2,
        p_emp_email         IN VARCHAR2,
        p_emp_phone         IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'ar',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER IS
        v_buyer_id NUMBER;
        v_user_id     NUMBER;
        v_count       NUMBER;
    BEGIN
        IF p_buyer_type IS NULL OR p_name_ar IS NULL OR p_trade_name_ar IS NULL OR p_unique_name IS NULL OR p_email IS NULL OR p_country_id IS NULL OR
           p_emp_name_ar IS NULL OR p_emp_identity_id IS NULL OR p_emp_job IS NULL OR p_emp_email IS NULL OR p_emp_phone IS NULL
        THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        -- CHECK IF buyer UNIQUE NAME IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM BUYERS
         WHERE ID = p_unique_name;
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'buyer_is_exists', p_lang => p_lang);
            RETURN -3;
        END IF;

        -- CHECK IF buyer ADMIN EMAIL IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE EMAIL_ADDRESS = TRIM(LOWER(p_emp_email));
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'buyer_admin_email_is_exists', p_lang => p_lang);
            RETURN -4;
        END IF;

        -- CHECK IF buyer ADMIN USERNAME IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE USER_NAME = TRIM(p_emp_identity_id) || '-buyer';
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'buyer_admin_username_is_exists', p_lang => p_lang);
            RETURN -5;
        END IF;

        -- ADD THE USER
        INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG,
                                USER_LANGUAGE_ID, USER_TYPE )
            VALUES ( p_emp_identity_id, p_emp_name_ar, p_emp_phone, p_emp_phone, p_emp_identity_id || '-employee', APP_USER_SECURITY.get_hash(p_emp_identity_id, p_emp_identity_id),
                     p_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'buyer', p_lookup_code => 'user_type') )
        RETURNING ID INTO v_user_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -6;
            ROLLBACK;
        END IF;

        -- ADD THE USER ROLE
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( v_user_id, APP_USER_SECURITY.role_id_by_name('buyer'), 'Y', GET_CURRENT_DATE );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -7;
            ROLLBACK;
        END IF;

        -- ADD THE buyer
        -- INSERT INTO BUYERS ( buyer_TYPE_ID, NAME_AR, NAME_EN, TRADE_NAME_AR, TRADE_NAME_EN, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, COUNTRY_ID, UNIQUE_NAME, DEFAULT_EMAIL, IS_ACTIVE, AVATAR_URL )
        --     VALUES ( p_buyer_type, p_name_ar, p_name_en, p_trade_name_ar, p_trade_name_en, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'buyer', p_lookup_code => 'user_type'),
        --              p_identity_type, p_identity_id, p_country_id, p_unique_name, p_email, 1, 'https://objectstorage.me-jeddah-1.oraclecloud.com/n/axax2vam4edg/b/mobasher/o/default_avatar.jfif' )
        -- RETURNING ID INTO v_buyer_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -8;
            ROLLBACK;
        END IF;

        -- ADD THE EMPLOYEE
        -- INSERT INTO EMPLOYEES ( NAME_AR, NAME_EN, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, PHONE, EMAIL, IS_ADMIN, IS_ACTIVE, USER_ID )
        --     VALUES ( p_emp_name_ar, p_emp_name_en, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'buyer', p_lookup_code => 'user_type'), p_emp_identity_type,
        --              p_emp_identity_id, p_emp_job, p_emp_phone, p_emp_email, 1, 1, v_user_id, v_buyer_id );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -9;
            ROLLBACK;

            -- DELETE FROM APP_USERS WHERE ID = v_user_id;
            -- DELETE FROM buyerS WHERE ID = v_buyer_id;
        END IF;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SQL_ERROR', p_PROCESS_NAME => 'buyer.create_buyer', p_ERROR_CODE => sqlcode, p_ERROR_MESSAGE => sqlerrm,
                                        p_logger_name => user, p_OBJECT_TYPE => 'buyerS', p_OBJECT_ID => v_buyer_id);
            RETURN -1;

    END create_buyer;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_buyer (
        p_buyer_id  IN NUMBER,
        p_message   OUT VARCHAR2
    ) RETURN NUMBER IS
        v_user_id  NUMBER;
    BEGIN
        -- SELECT USER_ID
        --   INTO v_user_id
        --   FROM EMPLOYEES
        --  WHERE buyer_ID = p_buyer_id;

        -- DELETE FROM EMPLOYEES WHERE SELLER_ID = p_seller_id;
        DELETE FROM APP_USERS WHERE ID = v_user_id;
        DELETE FROM APP_USER_ROLES WHERE USER_ID = v_user_id;
        -- DELETE FROM SELLERS WHERE ID = p_seller_id;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;

    END delete_buyer;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END buyer;
/