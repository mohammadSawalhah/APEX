
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."SELLER" AS

    FUNCTION create_seller (
        p_seller_type       IN NUMBER,
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
        p_avatar            IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'ar',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_seller (
        p_seller_id  IN NUMBER,
        p_message   OUT VARCHAR2
    ) RETURN NUMBER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION seller_name (
        p_seller_id  IN NUMBER
    ) RETURN VARCHAR2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION create_employee (
        p_seller_id   IN NUMBER,
        p_id_type     IN NUMBER,
        p_id_no       IN NUMBER,
        p_phone       IN NUMBER,
        p_name        IN VARCHAR2,
        p_email       IN VARCHAR2,
        p_job         IN VARCHAR2,
        p_lang        IN VARCHAR2 DEFAULT 'ar',
        p_message    OUT VARCHAR2
    ) RETURN NUMBER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION create_products (
        p_seller_id       IN NUMBER,
        p_city_id         IN NUMBER,
        p_category_id     IN NUMBER,
        p_subcategory_id  IN NUMBER,
        p_type            IN VARCHAR2,
        p_warranty        IN VARCHAR2,
        p_timeauctions    IN NUMBER DEFAULT NULL,
        p_stock_no        IN NUMBER DEFAULT NULL,
        p_active          IN NUMBER DEFAULT 1,
        p_name_ar         IN VARCHAR2,
        p_name_en         IN VARCHAR2,
        p_desc_ar         IN VARCHAR2 DEFAULT NULL,
        p_desc_en         IN VARCHAR2 DEFAULT NULL,
        p_address_ar      IN VARCHAR2 DEFAULT NULL,
        p_address_en      IN VARCHAR2 DEFAULT NULL,
        p_video_url       IN VARCHAR2 DEFAULT NULL,
        p_map_url         IN VARCHAR2 DEFAULT NULL,
        p_notes           IN VARCHAR2 DEFAULT NULL,
        p_main_image_url  IN VARCHAR2,
        p_images_urls     IN VARCHAR2, 
        p_make            IN VARCHAR2,
        p_model           IN VARCHAR2,
        p_year            IN VARCHAR2,
        p_color           IN VARCHAR2,
        p_fuel_type       IN VARCHAR2,
        p_card_notes      IN VARCHAR2,
        p_odo_meter       IN NUMBER,
        p_is_document     IN NUMBER,
        p_is_inspection   IN NUMBER,
        p_version         IN VARCHAR2 DEFAULT 'V2',
        p_lang            IN VARCHAR2 DEFAULT 'en',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION change_status_to_done (   
        p_master_id IN NUMBER 
    ) RETURN NUMBER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION UPDATE_PRODUCTS(
                -- from products table
        P_product_id                           IN NUMBER,
        p_seller_id                            IN NUMBER,
        p_type                                 IN VARCHAR2,
        p_name_ar                              IN VARCHAR2,
        p_city_id                              IN NUMBER,
        p_video_url                            IN VARCHAR2,
        p_category_id                          IN NUMBER,
        -- p_subcategory_id                       IN NUMBER,
        -- p_other_category                       IN VARCHAR2 DEFAULT NULL,
        p_reference_no                         IN NUMBER,
        p_desc_ar                              IN VARCHAR2,
        p_address_ar                           IN VARCHAR2,
        p_map_url                              IN VARCHAR2,
        --    p_images_url                           IN VARCHAR2,
        --    p_main_image_url                       IN VARCHAR2,
        
        -- from real estate details table
        p_instrument_no                        IN NUMBER,
        p_neighbourhoods_id                    IN NUMBER,
        P_street_name_ar                       IN VARCHAR2,
        p_is_there_mortgage                    IN NUMBER,
        p_is_rights_and_obligations            IN NUMBER,
        p_is_information_that_affect_property  IN NUMBER,
        p_there_mortgage_ar                    IN VARCHAR2,
        p_information_that_affect_property_ar  IN VARCHAR2,
        p_rights_and_obligations_ar            IN VARCHAR2,
        p_usage_id                             IN NUMBER,
        p_facade_id                            IN NUMBER,
        p_ad_sub_type_id                       IN NUMBER,
        p_space                                IN NUMBER,
        p_street_width                         IN NUMBER,
        p_construction_date                    IN DATE,
        p_governorate                          IN VARCHAR2,
        -- from car details table
        p_make_id                              IN NUMBER,
        p_model_id                             IN NUMBER,
        p_year                                 IN NUMBER,
        p_external_color                       IN NUMBER,
        p_odo_meter                            IN NUMBER,
        p_is_document                          IN NUMBER,
        p_is_inspection                        IN NUMBER,
        -- p_document_url                         IN VARCHAR2,
        -- p_inspection_url                       IN VARCHAR2,
        p_fuel_type                            IN NUMBER,
        p_chassis_number                       IN NUMBER,
        -- p_is_drowned                           IN NUMBER,
        -- p_is_burned                            IN NUMBER,
        -- p_is_accident                          IN NUMBER,
        p_vehichle_category                    IN VARCHAR2,
        p_plate_number                         IN VARCHAR2,
        p_sequency_number                      IN VARCHAR2,
        -- p_drowing_info                         IN VARCHAR2,
        -- p_drowing_file_url                     IN VARCHAR2,
        -- p_burn_info                            IN VARCHAR2,
        -- p_burn_file_url                        IN VARCHAR2,
        -- p_accident_info                        IN VARCHAR2,
        -- p_accident_file_url                    IN VARCHAR2,
        -- others
        -- P_dimensions_facade_id                 IN NUMBER,
        -- P_dimensions_description_ar            IN VARCHAR2,
        -- P_service_id                           IN NUMBER,
        -- P_service_description_ar               IN VARCHAR2,
        p_lang                                 IN VARCHAR2 DEFAULT 'ar',
        p_message                             OUT VARCHAR2
    ) RETURN NUMBER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================
    FUNCTION delete_product (
        p_product_id  IN NUMBER,
        p_category_id  IN NUMBER,
        p_message     OUT VARCHAR2
    ) RETURN NUMBER;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END SELLER;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."SELLER" AS   

    FUNCTION create_seller (
        p_seller_type       IN NUMBER,
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
        p_avatar            IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'ar',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER IS
        v_seller_id NUMBER;
        v_user_id   NUMBER;
        v_count     NUMBER;
    BEGIN
        IF p_seller_type IS NULL OR p_name_ar IS NULL OR p_trade_name_ar IS NULL OR p_unique_name IS NULL OR p_email IS NULL OR p_country_id IS NULL OR
           p_emp_name_ar IS NULL OR p_emp_identity_id IS NULL OR p_emp_job IS NULL OR p_emp_email IS NULL OR p_emp_phone IS NULL
        THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        -- CHECK IF SELLER UNIQUE NAME IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM SELLERS
         WHERE UNIQUE_NAME = p_unique_name;

        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'seller_is_exists', p_lang => p_lang);
            RETURN -3;
        END IF;

        -- CHECK IF SELLER ADMIN EMAIL IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE EMAIL_ADDRESS = TRIM(LOWER(p_emp_email));
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'seller_admin_email_is_exists', p_lang => p_lang);
            RETURN -4;
        END IF;

        -- CHECK IF SELLER ADMIN USERNAME IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE USER_NAME = TRIM(p_emp_identity_id);
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'seller_admin_username_is_exists', p_lang => p_lang);
            RETURN -5;
        END IF;

        -- ADD THE USER
        INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG,
                                USER_LANGUAGE_ID, USER_TYPE )
            VALUES ( p_emp_identity_id, p_emp_name_ar, p_emp_phone, p_emp_phone, p_emp_identity_id, APP_USER_SECURITY.get_hash(p_emp_identity_id, p_emp_identity_id),
                     p_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type') )
        RETURNING ID INTO v_user_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -6;
            ROLLBACK;
        END IF;

        -- ADD THE USER ROLE
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( v_user_id, APP_USER_SECURITY.role_id_by_name('seller'), 'Y', GET_CURRENT_DATE );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -7;
            ROLLBACK;
        END IF;

        -- ADD THE SELLER
        INSERT INTO SELLERS ( SELLER_TYPE_ID, NAME_AR, NAME_EN, TRADE_NAME_AR, TRADE_NAME_EN, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, COUNTRY_ID, UNIQUE_NAME, DEFAULT_EMAIL, IS_ACTIVE, AVATAR_URL )
            VALUES ( p_seller_type, p_name_ar, p_name_en, p_trade_name_ar, p_trade_name_en, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type'),
                     p_identity_type, p_identity_id, p_country_id, p_unique_name, p_email, 1, NVL(p_avatar, 'https://objectstorage.me-jeddah-1.oraclecloud.com/n/axax2vam4edg/b/mobasher/o/login-bg.jpg') )
        RETURNING ID INTO v_seller_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -8;
            ROLLBACK;
        END IF;

        -- ADD THE EMPLOYEE
        INSERT INTO EMPLOYEES ( NAME_AR, NAME_EN, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, PHONE, EMAIL, IS_ADMIN, IS_ACTIVE, USER_ID, SELLER_ID )
            VALUES ( p_emp_name_ar, p_emp_name_en, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type'), p_emp_identity_type,
                     p_emp_identity_id, p_emp_job, p_emp_phone, p_emp_email, 1, 1, v_user_id, v_seller_id );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -9;
            ROLLBACK;

            -- DELETE FROM APP_USERS WHERE ID = v_user_id;
            -- DELETE FROM SELLERS WHERE ID = v_seller_id;
        END IF;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SQL_ERROR', p_PROCESS_NAME => 'SELLER.create_seller', p_ERROR_CODE => sqlcode, p_ERROR_MESSAGE => sqlerrm,
                                        p_logger_name => user, p_OBJECT_TYPE => 'SELLERS', p_OBJECT_ID => v_seller_id);
            RETURN -1;

    END create_seller;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_seller (
        p_seller_id  IN NUMBER,
        p_message   OUT VARCHAR2
    ) RETURN NUMBER IS
        v_user_id  NUMBER;
    BEGIN
        SELECT USER_ID
          INTO v_user_id
          FROM EMPLOYEES
         WHERE SELLER_ID = p_seller_id;

        DELETE FROM EMPLOYEES WHERE SELLER_ID = p_seller_id;
        DELETE FROM APP_USERS WHERE ID = v_user_id;
        DELETE FROM APP_USER_ROLES WHERE USER_ID = v_user_id;
        DELETE FROM SELLERS WHERE ID = p_seller_id;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;

    END delete_seller;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION seller_name (
        p_seller_id  IN NUMBER
    ) RETURN VARCHAR2 IS
        v_seller_name  VARCHAR2(255);
    BEGIN
        SELECT NAME_AR
          INTO v_seller_name
          FROM SELLERS
         WHERE ID = p_seller_id;
    
    RETURN v_seller_name;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END seller_name;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION create_employee (
        p_seller_id   IN NUMBER,
        p_id_type     IN NUMBER,
        p_id_no       IN NUMBER,
        p_phone       IN NUMBER,
        p_name        IN VARCHAR2,
        p_email       IN VARCHAR2,
        p_job         IN VARCHAR2,
        p_lang        IN VARCHAR2 DEFAULT 'ar',
        p_message    OUT VARCHAR2
    ) RETURN NUMBER IS
        v_user_id    NUMBER;
        v_count      NUMBER;
    BEGIN
        -- CHECK IF PARAMS IS NULL
        IF p_name IS NULL OR p_id_type IS NULL OR p_id_no IS NULL OR p_phone IS NULL OR p_email IS NULL OR p_job IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        -- CHECK IF ID_NO IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE USER_NAME = TRIM(p_id_no);
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'user_exist', p_lang => p_lang);
            RETURN -3;
        END IF;

        -- CHECK IF EMAIL IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE EMAIL_ADDRESS = TRIM(LOWER(p_email));
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'email_exist', p_lang => p_lang);
            RETURN -4;
        END IF;

        -- CHECK IF PHONE IS EXISTS
        SELECT COUNT(1)
          INTO v_count
          FROM APP_USERS
         WHERE PHONE = TRIM(p_phone);
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'phone_exist', p_lang => p_lang);
            RETURN -5;
        END IF;

        -- CHECK IF EMAIL IS A VALID EMAIL
        IF SYSTEM_CONTROLS.email_validation(p_email) = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_email', p_lang => p_lang);
            RETURN -6;
        END IF;

        -- CHECK IF THIS EMPLOYEE EXISTS UNDER OTHER SELLER
       SELECT COUNT(1)
         INTO v_count
         FROM EMPLOYEES 
        WHERE IDENTITY_NUMBER = TRIM(p_id_no)
          AND SELLER_ID = p_seller_id;

        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'nid_exist', p_lang => p_lang);
            RETURN -7;
        END IF;

        -- CREATE USER
        INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG,
                                USER_LANGUAGE_ID, USER_TYPE )
            VALUES ( p_id_no, p_name, p_phone, p_phone, p_id_no, APP_USER_SECURITY.get_hash(p_id_no, p_id_no), p_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1,
                     LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type') )
        RETURNING ID INTO v_user_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'user_creation', p_lang => p_lang);
            RETURN -8;
            ROLLBACK;
        END IF;

        -- ADD THE ROLE TO THIS USER
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( v_user_id, APP_USER_SECURITY.role_id_by_name('seller'), 'Y', GET_CURRENT_DATE );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'role_creation', p_lang => p_lang);
            RETURN -9;
            ROLLBACK;
        END IF;

        -- CREATE EMPLOYEE
        INSERT INTO EMPLOYEES ( NAME_AR, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, PHONE, EMAIL, IS_ADMIN, IS_ACTIVE, USER_ID, SELLER_ID )
            VALUES ( p_name, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type'), p_id_type,
                     p_id_no, p_job, p_phone, p_email, 0, 1, v_user_id, p_seller_id );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'employee_creation', p_lang => p_lang);
            RETURN -10;
            ROLLBACK;
        END IF;

        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SQL_ERROR', p_PROCESS_NAME => 'SELLER.create_employee', p_ERROR_CODE => sqlcode, p_ERROR_MESSAGE => sqlerrm,
                                        p_logger_name => user, p_OBJECT_TYPE => 'SELLERS', p_OBJECT_ID => p_seller_id);
            RETURN -1;

    END create_employee;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    PROCEDURE ins_product_images (
        p_product_id  IN NUMBER,
        p_master_id   IN NUMBER
    ) IS
    BEGIN
        FOR i IN ( SELECT FRONT_RIGHT_CORNER, FRONT_LEFT_CORNER, BACK_RIGHT_CORNER, BACK_LEFT_CORNER, FRONT_SEATS, BACK_SEATS, ODO_METER
                     FROM SELLER_ASSIGNED_FILES_DETAILS
                    WHERE MASTER_ID = p_master_id )
        LOOP
            INSERT ALL  
              INTO PRODUCT_IMAGES (PRODUCT_ID, IS_ACTIVE, SEQ, URL) VALUES (p_product_id, 1, 1, i.FRONT_RIGHT_CORNER)
              INTO PRODUCT_IMAGES (PRODUCT_ID, IS_ACTIVE, SEQ, URL) VALUES (p_product_id, 1, 2, i.FRONT_LEFT_CORNER)
              INTO PRODUCT_IMAGES (PRODUCT_ID, IS_ACTIVE, SEQ, URL) VALUES (p_product_id, 1, 3, i.BACK_RIGHT_CORNER)
              INTO PRODUCT_IMAGES (PRODUCT_ID, IS_ACTIVE, SEQ, URL) VALUES (p_product_id, 1, 4, i.BACK_LEFT_CORNER)
              INTO PRODUCT_IMAGES (PRODUCT_ID, IS_ACTIVE, SEQ, URL) VALUES (p_product_id, 1, 5, i.FRONT_SEATS)
              INTO PRODUCT_IMAGES (PRODUCT_ID, IS_ACTIVE, SEQ, URL) VALUES (p_product_id, 1, 6, i.BACK_SEATS)
              INTO PRODUCT_IMAGES (PRODUCT_ID, IS_ACTIVE, SEQ, URL) VALUES (p_product_id, 1, 7, i.ODO_METER)
            SELECT * FROM dual;
        END LOOP;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END ins_product_images;

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION create_card_details (
        p_product_id      IN NUMBER,
        p_make            IN NUMBER,
        p_model           IN NUMBER,
        p_year            IN NUMBER,
        p_color           IN NUMBER,
        p_fuel_type       IN NUMBER,
        p_notes           IN VARCHAR2,
        p_odo_meter       IN NUMBER,
        p_is_document     IN NUMBER,
        p_is_inspection   IN NUMBER,
        p_lang            IN VARCHAR2 DEFAULT 'en',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER IS
        v_is_lab      NUMBER := 1;
        v_product_id  NUMBER;
        v_code        NUMBER;
        v_error       VARCHAR2(500);
        v_url         VARCHAR2(500);
        v_base_url    VARCHAR2(500);
        v_body        VARCHAR2(32000);
        l_clob        CLOB;
    BEGIN
        IF p_product_id IS NULL OR p_make IS NULL OR p_model IS NULL OR p_year IS NULL OR p_color IS NULL OR p_fuel_type IS NULL OR p_odo_meter IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -3;
        END IF;

        BEGIN 
            SELECT DECODE(v_is_lab, 1, TEST_BASE_URL, BASE_URL) AS BASE_URL
              INTO v_base_url
              FROM ENVIRONMENT_SETTING
             WHERE UPPER(PROVIDER) = 'MOBASHER';
        EXCEPTION
            WHEN no_data_found THEN     
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -4;
        END;

        v_url := v_base_url || '/cardetails';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        v_body := '{
                    "product": "'|| p_product_id ||'",
                    "vehiclesmake": "'|| p_make ||'",
                    "vehiclesmodel": "'|| p_model ||'",
                    "vehicleexternalcolor": "'|| p_color ||'",
                    "fuelType": "'|| p_fuel_type ||'",
                    "notes": "'|| p_notes ||'",
                    "odometer": "'|| p_odo_meter ||'",
                    "isThereDocument": '|| p_is_document ||',
                    "isThereInspection": '|| p_is_inspection ||',
                    "year": "'|| p_year ||'"
                }';

        l_clob := apex_web_service.make_rest_request ( 
                    p_url         => v_url,
                    p_http_method => 'POST',
                    p_body        => v_body
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SELLER.create_card_details', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := 'create_card_details Request Error!';
            RETURN -100004;
        END IF;

        apex_json.parse(l_clob);
        v_code  := apex_json.get_varchar2('code');
        v_error := apex_json.get_varchar2('message');
        
        IF v_error = 0 THEN
            p_message := apex_json.get_varchar2('message'); 
            RETURN -5;
        ELSE
            p_message    := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        END IF;        
            
        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        RETURN -200;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := 'others: ' || SQLERRM;
            RETURN -1;
    END create_card_details;

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION create_products (
        p_seller_id       IN NUMBER,
        p_city_id         IN NUMBER,
        p_category_id     IN NUMBER,
        p_subcategory_id  IN NUMBER,
        p_type            IN VARCHAR2,
        p_warranty        IN VARCHAR2,
        p_timeauctions    IN NUMBER DEFAULT NULL,
        p_stock_no        IN NUMBER DEFAULT NULL,
        p_active          IN NUMBER DEFAULT 1,
        p_name_ar         IN VARCHAR2,
        p_name_en         IN VARCHAR2,
        p_desc_ar         IN VARCHAR2 DEFAULT NULL,
        p_desc_en         IN VARCHAR2 DEFAULT NULL,
        p_address_ar      IN VARCHAR2 DEFAULT NULL,
        p_address_en      IN VARCHAR2 DEFAULT NULL,
        p_video_url       IN VARCHAR2 DEFAULT NULL,
        p_map_url         IN VARCHAR2 DEFAULT NULL,
        p_notes           IN VARCHAR2 DEFAULT NULL,
        p_main_image_url  IN VARCHAR2,
        p_images_urls     IN VARCHAR2, 
        p_make            IN VARCHAR2,
        p_model           IN VARCHAR2,
        p_year            IN VARCHAR2,
        p_color           IN VARCHAR2,
        p_fuel_type       IN VARCHAR2,
        p_card_notes      IN VARCHAR2,
        p_odo_meter       IN NUMBER,
        p_is_document     IN NUMBER,
        p_is_inspection   IN NUMBER,
        p_version         IN VARCHAR2 DEFAULT 'V2',
        p_lang            IN VARCHAR2 DEFAULT 'en',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER IS
        v_is_lab      NUMBER := 1;
        v_product_id  NUMBER;
        v_code        NUMBER;
        v_error       VARCHAR2(500);
        v_card_msg    VARCHAR2(500);
        v_url         VARCHAR2(500);
        v_base_url    VARCHAR2(500);
        v_body        VARCHAR2(32000);
        l_clob        CLOB;
        v_result      NUMBER;
    BEGIN
        IF p_seller_id IS NULL OR p_type IS NULL OR p_city_id IS NULL OR p_category_id IS NULL OR p_subcategory_id IS NULL OR p_name_ar IS NULL OR p_main_image_url IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        BEGIN 
            SELECT DECODE(v_is_lab, 1, TEST_BASE_URL, BASE_URL) AS BASE_URL
              INTO v_base_url
              FROM ENVIRONMENT_SETTING
             WHERE UPPER(PROVIDER) = 'MOBASHER';
        EXCEPTION
            WHEN no_data_found THEN     
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -3;
        END;

        v_url := v_base_url || '/products';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        v_body := '{
                    "category": "'|| p_category_id ||'",
                    "city": "'|| p_city_id ||'",
                    "stockNo": "'|| p_stock_no ||'",
                    "nameTrans": {
                        "ar-SA": "'|| p_name_ar ||'",
                        "en-US": "'|| p_name_en ||'"
                      },
                    "descriptionTrans": {
                        "ar-SA": "'|| p_desc_ar ||'",
                        "en-US": "'|| p_desc_en ||'"
                      },
                    "addressTrans": {
                        "ar-SA": "'|| p_address_ar ||'",
                        "en-US": "'|| p_address_en ||'"
                      },
                    "videoURL": "'|| p_video_url ||'",
                    "active": '|| p_active ||',
                    "notes": "'|| p_notes ||'",
                    "seller": "'|| p_seller_id ||'",
                    "timedauctions": ['|| p_timeauctions ||'],
                    "map": "'|| p_map_url ||'",
                    "type": "'|| p_type ||'",
                    "warranty": "'|| p_warranty ||'",
                    "subcategory": "'|| p_subcategory_id ||'",
                    "version": "'|| p_version ||'",
                    "mainImageUrl": "'|| p_main_image_url ||'",
                    "imagesUrls": "['|| p_images_urls ||']"
                }';

    -- DBMS_OUTPUT.PUT_LINE(v_url);
    -- DBMS_OUTPUT.PUT_LINE(v_body);
    
        l_clob := apex_web_service.make_rest_request ( 
                    p_url         => v_url,
                    p_http_method => 'POST',
                    p_body        => v_body
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SELLER.create_products', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := 'create_products Request Error!';
            RETURN -100003;
        END IF;

        apex_json.parse(l_clob);
        v_code  := apex_json.get_varchar2('code');
        v_error := apex_json.get_varchar2('message');
        
        IF v_error = 0 THEN
            p_message := apex_json.get_varchar2('message'); 
            RETURN -4;
        ELSE
            v_product_id := apex_json.get_varchar2('id');
        END IF;

        v_result := create_card_details (
                        p_product_id    => v_product_id,
                        p_make          => p_make,
                        p_model         => p_model,
                        p_year          => p_year,
                        p_color         => p_color,
                        p_fuel_type     => p_fuel_type,
                        p_notes         => p_card_notes,
                        p_odo_meter     => p_odo_meter,
                        p_is_document   => p_is_document,
                        p_is_inspection => p_is_inspection,
                        p_message       => v_card_msg
                    );

        IF v_result = 1 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
            RETURN 1;
        ELSE
            p_message := v_card_msg;
            RETURN -5;
        END IF;

        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := 'others: ' || SQLERRM;
            RETURN -1;
    END create_products;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION change_status_to_done (   
        p_master_id IN NUMBER 
    ) RETURN NUMBER IS
        v_count       NUMBER;
        v_product_id  NUMBER;
    BEGIN
        SELECT COUNT(1)
          INTO v_count
          FROM SELLER_ASSIGNED_FILES_DETAILS
         WHERE MASTER_ID = p_master_id
           AND STATUS <> LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'done', p_lookup_code => 'assigned_files_status');

        IF v_count = 0 THEN
            UPDATE SELLER_ASSIGNED_FILES_MASTER
               SET STATUS_ID = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'done', p_lookup_code => 'seller_assigned_files_status')
             WHERE ID = p_master_id;
            
            IF SQL%rowcount = 0 THEN
                RETURN -2;
            END IF;

            UPDATE SELLER_ASSIGNED_FILES
               SET STATUS = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'done', p_lookup_code => 'seller_assigned_files_status')
             WHERE ID IN ( SELECT m.FILE_ID FROM SELLER_ASSIGNED_FILES_MASTER m WHERE m.ID = p_master_id);
        
            -- IF SQL%rowcount > 0 THEN
            --     FOR i IN ( SELECT TYPE, MODEL, MODEL_YEAR, SELLER_ID, CITY_ID, SEQUENCE, FRONT_RIGHT_CORNER, FRONT_LEFT_CORNER,
            --                       BACK_RIGHT_CORNER, BACK_LEFT_CORNER, FRONT_SEATS, BACK_SEATS, ODO_METER
            --                  FROM SELLER_ASSIGNED_FILES_DETAILS
            --                 WHERE MASTER_ID = p_master_id )
            --     LOOP
            --         INSERT INTO PRODUCTS ( NAME_AR, NAME_EN, SELLER_ID, CITY_ID, IS_ACTIVE, STATUS_ID, TYPE_ID, MAIN_IMAGE_URL, STOCK_NO, CATEGORY_ID,
            --                                SUB_CATEGORY_ID, ADDRESS_AR, ADDRESS_EN )
            --             VALUES ( i.TYPE||' '||i.MODEL||' '||i.MODEL_YEAR, i.TYPE||' '||i.MODEL||' '||i.MODEL_YEAR, i.SELLER_ID, i.CITY_ID, 1,
            --                      LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'available', p_lookup_code => 'product_status'),
            --                      LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller_product', p_lookup_code => 'product_type'),
            --                      NVL(i.FRONT_RIGHT_CORNER, 'https://objectstorage.me-jeddah-1.oraclecloud.com/n/axax2vam4edg/b/mobasher/o/23S8KG8USJ.jpeg'),
            --                      i.SEQUENCE, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'vehicles', p_lookup_code => 'category'),
            --                      LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'car', p_lookup_code => 'sub_category'),
            --                      (SELECT NAME_AR FROM CITIES WHERE ID = i.CITY_ID), (SELECT NAME_AR FROM CITIES WHERE ID = i.CITY_ID)
            --                 )
            --             RETURNING ID INTO v_product_id;
                    
                    -- ins_product_images (v_product_id, p_master_id);
                -- END LOOP;

                -- CALL PRODUCT API ->
            -- END IF;

            IF SQL%rowcount = 0 THEN
                RETURN -3;
            END IF;

            RETURN 1;
        END IF;

        RETURN -4;
    EXCEPTION
        WHEN OTHERS THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_error_type => 'SQL_ERROR', p_process_name => 'SELLER.change_status_to_done', p_error_code => sqlcode, p_error_message => sqlerrm, p_logger_name => user );
            RETURN -1;
    END change_status_to_done;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION UPDATE_PRODUCTS(
                -- from products table
        P_product_id                           IN NUMBER,
        p_seller_id                            IN NUMBER,
        p_type                                 IN VARCHAR2,
        p_name_ar                              IN VARCHAR2,
        p_city_id                              IN NUMBER,
        p_video_url                            IN VARCHAR2,
        p_category_id                          IN NUMBER,
        -- p_subcategory_id                       IN NUMBER,
        -- p_other_category                       IN VARCHAR2 DEFAULT NULL,
        p_reference_no                         IN NUMBER,
        p_desc_ar                              IN VARCHAR2,
        p_address_ar                           IN VARCHAR2,
        p_map_url                              IN VARCHAR2,

        -- from real estate details table
        p_instrument_no                        IN NUMBER,
        p_neighbourhoods_id                    IN NUMBER,
        P_street_name_ar                       IN VARCHAR2,
        p_is_there_mortgage                    IN NUMBER,
        p_is_rights_and_obligations            IN NUMBER,
        p_is_information_that_affect_property  IN NUMBER,
        p_there_mortgage_ar                    IN VARCHAR2,
        p_information_that_affect_property_ar  IN VARCHAR2,
        p_rights_and_obligations_ar            IN VARCHAR2,
        p_usage_id                             IN NUMBER,
        p_facade_id                            IN NUMBER,
        p_ad_sub_type_id                       IN NUMBER,
        p_space                                IN NUMBER,
        p_street_width                         IN NUMBER,
        p_construction_date                    IN DATE,
        p_governorate                          IN VARCHAR2,

        -- from car details table
        p_make_id                              IN NUMBER,
        p_model_id                             IN NUMBER,
        p_year                                 IN NUMBER,
        p_external_color                       IN NUMBER,
        p_odo_meter                            IN NUMBER,
        p_is_document                          IN NUMBER,
        p_is_inspection                        IN NUMBER,
        -- p_document_url                         IN VARCHAR2,
        -- p_inspection_url                       IN VARCHAR2,
        p_fuel_type                            IN NUMBER,
        p_chassis_number                       IN NUMBER,
        -- p_is_drowned                           IN NUMBER,
        -- p_is_burned                            IN NUMBER,
        -- p_is_accident                          IN NUMBER,
        p_vehichle_category                    IN VARCHAR2,
        p_plate_number                         IN VARCHAR2,
        p_sequency_number                      IN VARCHAR2,
        -- p_drowing_info                         IN VARCHAR2,
        -- p_drowing_file_url                     IN VARCHAR2,
        -- p_burn_info                            IN VARCHAR2,
        -- p_burn_file_url                        IN VARCHAR2,
        -- p_accident_info                        IN VARCHAR2,
        -- p_accident_file_url                    IN VARCHAR2,

        -- others
        p_lang                                 IN VARCHAR2 DEFAULT 'ar',
        p_message                             OUT VARCHAR2
    ) RETURN NUMBER IS
        v_product_id NUMBER;
        v_count      NUMBER;
    BEGIN 
        -- check if all the requirments are filled
        -- OR p_category_id IS NULL OR p_subcategory_id IS NULL >> *
        IF  p_type IS NULL OR p_city_id IS NULL OR p_address_ar IS NULL OR p_map_url IS NULL OR p_name_ar IS NULL  THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        UPDATE PRODUCTS
           SET TYPE_ID = p_type,
               NAME_AR =  p_name_ar,
               CITY_ID =  p_city_id,
               VIDEO_URL = p_video_url, 
               REFERENCE_NO =  p_reference_no,
               DESCRIPTION_AR = p_desc_ar,
               ADDRESS_AR = p_address_ar, 
               MAP_URL = p_map_url
         WHERE ID = P_product_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
            ROLLBACK;
        END IF;

        -- check if the category id = 1 'real estate' then its required fields are filled
        IF LOOKUPS_MNT.category_code_by_id (p_category_id => p_category_id) = 'real_estates' THEN
            IF p_instrument_no IS NULL OR p_space IS NULL OR p_usage_id IS NULL OR p_ad_sub_type_id IS NULL OR p_is_there_mortgage IS NULL 
               OR p_is_rights_and_obligations IS NULL OR p_is_information_that_affect_property IS NULL THEN
                    p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                    RETURN -4;
            END IF;

            -- UPDATE REAL_STATE_DETAILS **
            UPDATE REAL_STATE_DETAILS
               SET INSTRUMENT_NO = p_instrument_no,
                   GOVERNORATE = p_governorate,
                   NEIGHBOURHOODS_ID = p_neighbourhoods_id,
                   STREET_NAME_AR = p_street_name_ar,
                   STREET_WIDTH = p_street_width,
                   SPACE = p_space,
                   IS_THERE_MORTGAGE = p_is_there_mortgage,
                   IS_RIGHTS_AND_OBLIGATIONS = p_is_rights_and_obligations,
                   IS_INFORMATION_THAT_AFFECT_PROPERTY = p_is_information_that_affect_property,
                   THERE_MORTGAGE_AR = p_there_mortgage_ar,
                   RIGHTS_AND_OBLIGATIONS_AR = p_rights_and_obligations_ar,
                   INFORMATION_THAT_AFFECT_PROPERTY_AR = p_information_that_affect_property_ar,
                   USAGE_ID = p_usage_id,
                   FACADE_ID = p_facade_id,
                --    AD_TYPE_ID = p_type,
                   AD_SUB_TYPE_ID = p_ad_sub_type_id,
                   CONSTRUCTION_DATE = p_construction_date
             WHERE PRODUCT_ID = P_product_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -6;
                ROLLBACK;
            END IF;

        END IF;

        -- check if the category id = 2 'cars' then its required fields are filled
        IF LOOKUPS_MNT.category_code_by_id (p_category_id => p_category_id) = 'portable' THEN
            IF p_make_id IS NULL OR p_model_id IS NULL OR p_chassis_number IS NULL THEN
               p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                RETURN -7;
            END IF;

            UPDATE CAR_DETAILS 
               SET VEHICLE_MAKE_ID = p_make_id, 
                   VEHICLE_MODEL_ID = p_model_id, 
                   VEHICHLE_CATEGORY = p_vehichle_category, 
                   PLATE_NUMBER = p_plate_number, 
                   CHASSIS_NUMBER = p_chassis_number, 
                   SERIAL_NUMBER = p_sequency_number, 
                   YEAR = p_year, 
                   FUEL_TYPE_ID = p_fuel_type,
                   VEHICLE_EXTERNAL_COLOR_ID = p_external_color, 
                   ODO_METER =p_odo_meter, 
                   IS_THERE_DOCUMENT = p_is_document, 
                   IS_THERE_INSPECTION = p_is_inspection
                --    DOCUMENT_URL = p_document_url, 
                --    INSPECTION_URL =  p_inspection_url 
                --    IS_DROWNED = p_is_drowned, 
                --    IS_BURNED = p_is_burned, 
                --    IS_ACCIDENT = p_is_accident, 
                --    DROWING_INFO = p_drowing_info, 
                --    DROWING_FILE_URL = p_drowing_file_url,
                --    BURN_INFO = p_burn_info, 
                --    BURN_FILE_URL = p_burn_file_url, 
                --    ACCIDENT_INFO = p_accident_info, 
                --    ACCIDENT_FILE_URL = p_accident_file_url 
             WHERE PRODUCT_ID = P_product_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -8;
                ROLLBACK;
            END IF;
        END IF; 
        
       RETURN 1; 
    END UPDATE_PRODUCTS;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================
    FUNCTION delete_product (
        p_product_id   IN NUMBER,
        p_category_id  IN NUMBER,
        p_message     OUT VARCHAR2
    ) RETURN NUMBER IS

    BEGIN

        IF LOOKUPS_MNT.category_code_by_id (p_category_id => p_category_id) = 'real_estates' THEN
            DELETE FROM REAL_STATE_DETAILS WHERE PRODUCT_ID = p_product_id;
            DELETE FROM PROPERTY_DIMENSIONS WHERE PRODUCT_ID = p_product_id;
            DELETE FROM PROPERTY_SERVICES WHERE PRODUCT_ID = p_product_id;
        END IF;

        IF LOOKUPS_MNT.category_code_by_id (p_category_id => p_category_id) = 'portable' THEN
            DELETE FROM CAR_DETAILS WHERE PRODUCT_ID = p_product_id;
        END IF;

        DELETE FROM PRODUCTS WHERE ID = p_product_id;
        DELETE FROM PRODUCT_REPORTS WHERE PRODUCT_ID = p_product_id;
        DELETE FROM PRODUCT_IMAGES WHERE PRODUCT_ID = p_product_id;
        
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;

    END delete_product;
--=================================================================================================
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END SELLER;
/