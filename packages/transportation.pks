
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."TRANSPORTATION" as
        FUNCTION create_user (
        p_first_name     IN VARCHAR2,
        p_last_name      IN VARCHAR2,
        p_email          IN VARCHAR2,
        p_idntity_no     IN VARCHAR2,
        p_phone_no       IN VARCHAR2,
        p_password       IN VARCHAR2,
        p_check_password IN VARCHAR2,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION TO_GEOJSON (
        lg in VARCHAR2,
        lat in VARCHAR2
    ) RETURN VARCHAR2;
    
        FUNCTION create_request (
        p_user_id                IN NUMBER,
        p_truck_type             IN NUMBER,
        p_make                   IN VARCHAR2,
        p_model                  IN VARCHAR2,
        p_year                   IN NUMBER,
        p_plate_number           IN VARCHAR2,
        p_vin_number             IN VARCHAR2,
        p_serial_number          IN NUMBER,
        p_pickup_longitude       IN NUMBER,
        p_pickup_latitude        IN NUMBER,
        p_arrival_longitude      IN NUMBER,
        p_arrival_latitude       IN NUMBER,
        p_pickup_date            IN DATE,
        p_pickup_contact_number  IN VARCHAR2,
        p_arrival_contact_name   IN VARCHAR2,
        p_arrival_contact_number IN VARCHAR2,
        p_pickup_contact_name    IN VARCHAR2,
        p_pickup_from            IN NUMBER,
        p_arrival_to             IN NUMBER,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER;
        FUNCTION update_user (
        p_user_id        IN NUMBER,
        p_email          IN VARCHAR2,
        p_phone_no       IN VARCHAR2,
        p_whats_phone_no IN VARCHAR2,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER;
end "TRANSPORTATION";
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."TRANSPORTATION" as
    FUNCTION create_user (
        p_first_name     IN VARCHAR2,
        p_last_name      IN VARCHAR2,
        p_email          IN VARCHAR2,
        p_idntity_no     IN VARCHAR2,
        p_phone_no       IN VARCHAR2,
        p_password       IN VARCHAR2,
        p_check_password IN VARCHAR2,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER AS
        v_user_id   NUMBER;
        v_user_type NUMBER;
        v_role_id   NUMBER;
        v_emp_id    NUMBER;
        v_count     NUMBER;
    BEGIN

        IF p_first_name IS NULL OR p_last_name IS NULL OR p_idntity_no IS NULL OR p_email IS NULL OR p_phone_no IS NULL OR
           p_password IS NULL OR p_check_password IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        -- Validations
        IF VALIDATIONS_PKG.VALIDATE_ID(p_idntity_no) = FALSE THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_id', p_lang => p_lang);
            RETURN -3;
        END IF;
        IF VALIDATIONS_PKG.VALIDATE_EMAIL(p_email) = FALSE THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_email', p_lang => p_lang);
            RETURN -4;
        END IF;
        IF VALIDATIONS_PKG.VALIDATE_PHONE(p_phone_no) = FALSE THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
            RETURN -5;
        END IF;
        IF LENGTH(p_password) < 6 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_password', p_lang => p_lang);
            RETURN -6;
        END IF;
        IF p_password <> p_check_password THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_password', p_lang => p_lang);
            RETURN -7;
        END IF;

        --Insertion
        INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG,
                                USER_LANGUAGE_ID, USER_TYPE )
            VALUES ( p_idntity_no, p_first_name || ' '|| p_last_name , p_phone_no, p_phone_no, p_idntity_no || '-TRANSPORTATION', APP_USER_SECURITY.get_hash(p_idntity_no || '-TRANSPORTATION',p_password),
                     p_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'transportation_user', p_lookup_code => 'user_type') )
        RETURNING ID INTO v_user_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -8;
            ROLLBACK;
        END IF;

        -- ADD USER ROLE
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( v_user_id, APP_USER_SECURITY.role_id_by_name('Transportation User'), 'Y', GET_CURRENT_DATE )
        RETURNING ID INTO v_role_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -9;
            ROLLBACK;
        END IF;

        -- ADD trans USER 
        INSERT INTO TRANSPORTATION_USERS ( USER_ID, NAME, IDENTITY_NUMBER, PHONE, EMAIL )
            VALUES ( v_user_id, p_first_name || ' '|| p_last_name, p_idntity_no, p_phone_no, p_email);

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -10;
            ROLLBACK;
        END IF;

        RETURN 1;
        
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                p_message := SQLERRM;
                RETURN -1;
    END;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION TO_GEOJSON (
        lg in VARCHAR2,
        lat in VARCHAR2
    ) RETURN VARCHAR2
    AS
    BEGIN 
        RETURN '{"coordinates":['||lat||','||lg ||'],"type": "point" }';
    END TO_GEOJSON;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION create_request (
        p_user_id                IN NUMBER,
        p_truck_type             IN NUMBER,
        p_make                   IN VARCHAR2,
        p_model                  IN VARCHAR2,
        p_year                   IN NUMBER,
        p_plate_number           IN VARCHAR2,
        p_vin_number             IN VARCHAR2,
        p_serial_number          IN NUMBER,
        p_pickup_longitude       IN NUMBER,
        p_pickup_latitude        IN NUMBER,
        p_arrival_longitude      IN NUMBER,
        p_arrival_latitude       IN NUMBER,
        p_pickup_date            IN DATE,
        p_pickup_contact_number  IN VARCHAR2,
        p_arrival_contact_name   IN VARCHAR2,
        p_arrival_contact_number IN VARCHAR2,
        p_pickup_contact_name    IN VARCHAR2,
        p_pickup_from            IN NUMBER,
        p_arrival_to             IN NUMBER,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER AS
        v_request_id     number;
        v_contact_number VARCHAR2(20);
        v_contact_name   VARCHAR2(255);
    BEGIN
        IF p_truck_type IS NULL OR p_make IS NULL OR p_model IS NULL OR p_year IS NULL OR p_plate_number IS NULL OR
           p_vin_number IS NULL OR p_serial_number IS NULL OR p_pickup_longitude IS NULL OR p_pickup_latitude IS NULL OR
           p_arrival_longitude IS NULL OR p_arrival_latitude IS NULL OR p_pickup_date IS NULL OR p_arrival_to IS NULL OR p_pickup_from IS NULL THEN
               p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        IF p_pickup_from = 0 AND p_arrival_to = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_choice', p_lang => p_lang);
            RETURN -3;
        END IF;

        IF p_pickup_from = 0 THEN
            SELECT PHONE, PERSONAL_NAME
              INTO v_contact_number, v_contact_name
              FROM APP_USERS
             WHERE ID = p_user_id;

            IF v_contact_number = p_arrival_contact_number AND v_contact_name = p_arrival_contact_name THEN
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_choice', p_lang => p_lang) || '4';
                RETURN -4;
            END IF;
            INSERT INTO TRANSPORTATION_REQUESTS(user_id,TRUCK_TYPE,PRODUCT_NAME,MAKE,MODEL,YEAR,PLATE_NUMBER,VIN_NUMBER,SERIAL_NUMBER,
                                            PICKUP_LONGITUDE,PICKUP_LATITUDE,ARRIVAL_LONGITUDE,ARRIVAL_LATITUDE,IS_ACTIVE,PICKUP_DATE,PICKUP_CONTACT_NUMBER,
                                            ARRIVAL_CONTACT_NAME,ARRIVAL_CONTACT_NUMBER,PICKUP_CONTACT_NAME)
             VALUES (p_user_id, p_truck_type, LOOKUPS_MNT.vehicle_make_by_id (p_make) || ' ' || LOOKUPS_MNT.vehicle_model_by_id (p_model) || ' ' || p_year || ' - (VIN:' || SUBSTR(p_vin_number, - 6) || ')', 
                     p_make,p_model,p_year,p_plate_number,p_vin_number,p_serial_number,
                     p_pickup_longitude,p_pickup_latitude,p_arrival_longitude,p_arrival_latitude, 1, p_pickup_date,
                     v_contact_number,p_arrival_contact_name,p_arrival_contact_number,v_contact_name);
            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -5;
            ROLLBACK;
            END IF;
        ELSIF p_arrival_to = 0 THEN 
            SELECT PHONE, PERSONAL_NAME
              INTO v_contact_number, v_contact_name
              FROM APP_USERS
             WHERE ID = p_user_id;

            IF v_contact_number = p_pickup_contact_number AND v_contact_name = p_pickup_contact_name THEN
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_choice', p_lang => p_lang)|| '6';
                RETURN -6;
            END IF;
            INSERT INTO TRANSPORTATION_REQUESTS(user_id,TRUCK_TYPE,PRODUCT_NAME,MAKE,MODEL,YEAR,PLATE_NUMBER,VIN_NUMBER,SERIAL_NUMBER,
                                            PICKUP_LONGITUDE,PICKUP_LATITUDE,ARRIVAL_LONGITUDE,ARRIVAL_LATITUDE,IS_ACTIVE,PICKUP_DATE,PICKUP_CONTACT_NUMBER,
                                            ARRIVAL_CONTACT_NAME,ARRIVAL_CONTACT_NUMBER,PICKUP_CONTACT_NAME)
             VALUES (p_user_id, p_truck_type, LOOKUPS_MNT.vehicle_make_by_id (p_make) || ' ' || LOOKUPS_MNT.vehicle_model_by_id (p_model) || ' ' || p_year || ' - (VIN:' || SUBSTR(p_vin_number, - 6) || ')', 
                    p_make,p_model,p_year,p_plate_number,p_vin_number,p_serial_number,
                     p_pickup_longitude,p_pickup_latitude,p_arrival_longitude,p_arrival_latitude, 1, p_pickup_date,
                     p_pickup_contact_number,v_contact_name,v_contact_number,p_pickup_contact_name);
            IF SQL%ROWCOUNT = 0 THEN
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -7;
            ROLLBACK;
            END IF;
        ELSE
            IF p_arrival_contact_number = p_pickup_contact_number AND p_arrival_contact_name = p_pickup_contact_name THEN
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_choice', p_lang => p_lang) || '8';
                RETURN -8;
            END IF;

            INSERT INTO TRANSPORTATION_REQUESTS(user_id,TRUCK_TYPE,PRODUCT_NAME,MAKE,MODEL,YEAR,PLATE_NUMBER,VIN_NUMBER,SERIAL_NUMBER,
                                            PICKUP_LONGITUDE,PICKUP_LATITUDE,ARRIVAL_LONGITUDE,ARRIVAL_LATITUDE,IS_ACTIVE,PICKUP_DATE,PICKUP_CONTACT_NUMBER,
                                            ARRIVAL_CONTACT_NAME,ARRIVAL_CONTACT_NUMBER,PICKUP_CONTACT_NAME)
             VALUES (p_user_id, p_truck_type, LOOKUPS_MNT.vehicle_make_by_id (p_make) || ' ' || LOOKUPS_MNT.vehicle_model_by_id (p_model) || ' ' || p_year || ' - (VIN:' || SUBSTR(p_vin_number, - 6) || ')', 
                     p_make,p_model,p_year,p_plate_number,p_vin_number,p_serial_number,
                     p_pickup_longitude,p_pickup_latitude,p_arrival_longitude,p_arrival_latitude, 1, p_pickup_date,
                     p_pickup_contact_number,p_arrival_contact_name,p_arrival_contact_number,p_pickup_contact_name);
            IF SQL%ROWCOUNT = 0 THEN
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -9;
            ROLLBACK;
            END IF;
        END IF;
        RETURN 1;
        
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                p_message := SQLERRM;
                RETURN -1;
    END create_request;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION update_user (
        p_user_id        IN NUMBER,
        p_email          IN VARCHAR2,
        p_phone_no       IN VARCHAR2,
        p_whats_phone_no IN VARCHAR2,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message        OUT VARCHAR2
    ) RETURN NUMBER AS
    BEGIN
        IF p_user_id IS NULL OR p_email IS NULL OR p_phone_no IS NULL OR p_whats_phone_no IS NULL THEN
               p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
               RETURN -2;
        END IF;
        IF VALIDATIONS_PKG.VALIDATE_EMAIL(p_email) = FALSE THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_email', p_lang => p_lang);
            RETURN -3;
        END IF;
        IF VALIDATIONS_PKG.VALIDATE_PHONE(p_phone_no) = FALSE THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
            RETURN -4;
        END IF;
        IF VALIDATIONS_PKG.VALIDATE_PHONE(p_whats_phone_no) = FALSE THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
            RETURN -6;
        END IF;

        UPDATE APP_USERS
           SET EMAIL_ADDRESS = p_email,
               PHONE = p_phone_no,
               WHATS_PHONE   = p_whats_phone_no
         WHERE ID = p_user_id;
        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -7;
        ROLLBACK;
        END IF;

        UPDATE TRANSPORTATION_USERS
           SET EMAIL = p_email,
               PHONE = p_phone_no
         WHERE USER_ID = p_user_id;
        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -8;
        ROLLBACK;
        END IF;

        RETURN 1;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                p_message := SQLERRM;
                RETURN -1;
    END;
END TRANSPORTATION;
/