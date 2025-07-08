
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."AGENTS_PKG" AS  
  
    FUNCTION agent_name_by_id (  
        p_id   IN NUMBER,  
        p_lang IN VARCHAR2  
    ) RETURN VARCHAR2;

    FUNCTION agent_type_by_id (  
        p_id   IN NUMBER,  
        p_lang IN VARCHAR2 DEFAULT 'ar'
    ) RETURN VARCHAR2;

    FUNCTION agent_type_code_by_id (
        p_id IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION agents_id_by_type (
        p_type IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION user_id_by_agent_id (  
        p_agent_id IN NUMBER  
    ) RETURN NUMBER;  

    FUNCTION agent_id_by_user_id (  
        p_user_id IN NUMBER  
    ) RETURN NUMBER;  
    
    FUNCTION group_id_by_agent_id (  
        p_agent_id IN NUMBER  
    ) RETURN NUMBER;  
    
    FUNCTION group_name_by_agent_id (  
        p_agent_id IN NUMBER,  
        p_lang   IN VARCHAR2  
    ) RETURN VARCHAR2; 
    
    FUNCTION group_id_by_company_id (  
        p_company_id IN NUMBER  
    ) RETURN NUMBER;  
    
    FUNCTION agent_is_privilege (  
        p_agent_id  IN NUMBER,   
        p_company_id IN NUMBER  
    ) RETURN NUMBER; 

    FUNCTION create_agent (
        p_agent_name         IN VARCHAR2,
        p_agent_type         IN NUMBER,
        p_identity_no        IN VARCHAR2,
        p_phone              IN VARCHAR2,
        p_whats              IN VARCHAR2,
        p_email              IN VARCHAR2,
        p_bank               IN VARCHAR2,
        p_account_no         IN VARCHAR2,
        p_iban               IN VARCHAR2,
        p_is_active          IN NUMBER,
        p_insurance_type     IN NUMBER,
        p_truck_type         IN NUMBER,
        p_operation_no       IN VARCHAR2,
        p_operation_card_url IN VARCHAR2,
        p_identity_url       IN VARCHAR2,
        p_registration_url   IN VARCHAR2,
        p_lang               IN VARCHAR2 DEFAULT 'ar',
        p_message            OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION update_agent (
        p_agent_id           IN NUMBER,
        p_agent_name         IN VARCHAR2,
        p_agent_type         IN NUMBER,
        p_identity_no        IN VARCHAR2,
        p_phone              IN VARCHAR2,
        p_whats              IN VARCHAR2,
        p_email              IN VARCHAR2,
        p_bank               IN VARCHAR2,
        p_account_no         IN VARCHAR2,
        p_iban               IN VARCHAR2,
        p_is_active          IN NUMBER,
        p_insurance_type     IN NUMBER,
        p_truck_type         IN NUMBER,
        p_operation_no       IN VARCHAR2,
        p_operation_card_url IN VARCHAR2,
        p_identity_url       IN VARCHAR2,
        p_registration_url   IN VARCHAR2,
        p_lang               IN VARCHAR2 DEFAULT 'ar',
        p_message            OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION delete_agent (
        p_agent_id IN NUMBER,
        p_lang     IN VARCHAR2 DEFAULT 'ar',
        p_message  OUT VARCHAR2
    ) RETURN NUMBER;

    -- FUNCTION create_agent (
    --     p_agent_name         IN VARCHAR2,
    --     p_agent_type         IN VARCHAR2,
    --     p_identity_no        IN VARCHAR2,
    --     p_phone              IN VARCHAR2,
    --     p_whats              IN VARCHAR2,
    --     p_email              IN VARCHAR2,
    --     p_bank               IN VARCHAR2,
    --     p_account_no         IN VARCHAR2,
    --     p_iban               IN VARCHAR2,
    --     p_is_active          IN NUMBER,
    --     p_insurance_type     IN NUMBER,
    --     p_truck_type         IN NUMBER,
    --     p_operation_no       IN VARCHAR2,
    --     p_operation_card_url IN VARCHAR2,
    --     p_identity_url       IN VARCHAR2,
    --     p_registration_url   IN VARCHAR2,
    --     p_lang               IN VARCHAR2 DEFAULT 'ar',
    --     p_message            OUT VARCHAR2
    -- ) RETURN NUMBER;

    -- FUNCTION update_agent (
    --     p_agent_id           IN NUMBER,
    --     p_agent_name         IN VARCHAR2,
    --     p_agent_type         IN VARCHAR2,
    --     p_identity_no        IN VARCHAR2,
    --     p_phone              IN VARCHAR2,
    --     p_whats              IN VARCHAR2,
    --     p_email              IN VARCHAR2,
    --     p_bank               IN VARCHAR2,
    --     p_account_no         IN VARCHAR2,
    --     p_iban               IN VARCHAR2,
    --     p_is_active          IN NUMBER,
    --     p_insurance_type     IN NUMBER,
    --     p_truck_type         IN NUMBER,
    --     p_operation_no       IN VARCHAR2,
    --     p_operation_card_url IN VARCHAR2,
    --     p_identity_url       IN VARCHAR2,
    --     p_registration_url   IN VARCHAR2,
    --     p_lang               IN VARCHAR2 DEFAULT 'ar',
    --     p_message            OUT VARCHAR2
    -- ) RETURN NUMBER;


    -- FUNCTION delete_agent (
    --     p_agent_id IN NUMBER,
    --     p_lang     IN VARCHAR2 DEFAULT 'ar',
    --     p_message  OUT VARCHAR2
    -- ) RETURN NUMBER;


END AGENTS_PKG;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."AGENTS_PKG" AS  
  
    FUNCTION agent_name_by_id (  
        p_id      IN NUMBER,  
        p_lang IN VARCHAR2  
    ) RETURN VARCHAR2 IS  
        v_name VARCHAR2(255);  
    BEGIN  
        SELECT DECODE(p_lang, 'en', NAME_EN, NAME_AR) AS name  
          INTO v_name  
          FROM AGENTS  
         WHERE ID = p_id;  
        RETURN v_name;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN '';  
    END agent_name_by_id;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION agent_type_by_id (  
        p_id   IN NUMBER,  
        p_lang IN VARCHAR2 DEFAULT 'ar' 
    ) RETURN VARCHAR2 IS  
        v_agent_type APEX_T_VARCHAR2;
        v_agent_type_name VARCHAR2(2550);
    BEGIN  
    SELECT APEX_STRING.SPLIT(AGENT_TYPE, ',') INTO v_agent_type FROM AGENTS WHERE ID = p_id;
    FOR i IN 1..v_agent_type.COUNT LOOP
        IF p_lang = 'ar' THEN
            v_agent_type_name := v_agent_type_name  || LOOKUPS_MNT.lookup_detail_name_by_id (v_agent_type(i), 'ar') || ' - ';
        ELSIF p_lang = 'en' THEN
            v_agent_type_name := v_agent_type_name || ' - ' || LOOKUPS_MNT.lookup_detail_name_by_id (v_agent_type(i), p_lang) ;
        END IF;
    END LOOP;

        RETURN v_agent_type_name;  

    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN '';  
    END agent_type_by_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION agent_type_code_by_id (
        p_id IN NUMBER
    ) RETURN VARCHAR2 IS
        v_agent_type APEX_T_VARCHAR2;
        v_agent_type_no VARCHAR2(255);
        v_agent_type_name VARCHAR2(2550);
    BEGIN
        SELECT APEX_STRING.SPLIT(AGENT_TYPE_V2, ',') INTO v_agent_type FROM AGENTS WHERE ID = 54;
        FOR i IN 1..v_agent_type.COUNT LOOP
            v_agent_type_name := LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => v_agent_type(i)) || ',' || v_agent_type_name;
        END LOOP;

        RETURN v_agent_type_name;

    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN '';  
    END agent_type_code_by_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION agents_id_by_type (
        p_type IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_count      NUMBER;
        v_agent_type VARCHAR2(355);
        v_agent_ids  VARCHAR2(255);
    BEGIN
        IF TRIM(LOWER(p_type)) = TRIM(LOWER('photo')) THEN 
            FOR i IN (SELECT ID, AGENT_TYPE FROM AGENTS WHERE IS_ACTIVE = 1) LOOP

                SELECT COUNT(1)
                  INTO v_count
                  FROM LOOKUP_DETAIL
                 WHERE ID IN (SELECT column_value FROM APEX_STRING.split( p_str => i.AGENT_TYPE, p_sep => ',' ))
                   AND CODE IN ('washing', 'photography', 'washing_photographing');

                IF v_count <> 0 THEN
                    v_agent_ids := i.ID || ','|| v_agent_ids;
                END IF;

            END LOOP;
        ELSIF TRIM(LOWER(p_type)) = TRIM(LOWER('inspect')) THEN
            FOR i IN (SELECT ID, AGENT_TYPE FROM AGENTS WHERE IS_ACTIVE = 1) LOOP

                SELECT COUNT(1)
                  INTO v_count
                  FROM LOOKUP_DETAIL
                 WHERE ID IN (SELECT column_value FROM APEX_STRING.split( p_str => i.AGENT_TYPE, p_sep => ',' ))
                   AND CODE = 'inspection';

                IF v_count <> 0 THEN
                    v_agent_ids := i.ID || ','|| v_agent_ids;
                END IF;

            END LOOP;
        ELSIF TRIM(LOWER(p_type)) = TRIM(LOWER('evaluation')) THEN
            FOR i IN (SELECT ID, AGENT_TYPE FROM AGENTS WHERE IS_ACTIVE = 1) LOOP

                SELECT COUNT(1)
                  INTO v_count
                  FROM LOOKUP_DETAIL
                 WHERE ID IN (SELECT column_value FROM APEX_STRING.split( p_str => i.AGENT_TYPE, p_sep => ',' ))
                   AND CODE = 'realestate_evaluation';

                IF v_count <> 0 THEN
                    v_agent_ids := i.ID || ','|| v_agent_ids;
                END IF;

            END LOOP;
        END IF;

        RETURN v_agent_ids;

    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN '';  
    END agents_id_by_type;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION user_id_by_agent_id (  
        p_agent_id IN NUMBER  
    ) RETURN NUMBER IS  
        v_id NUMBER;  
    BEGIN
        SELECT ID  
          INTO v_id  
          FROM APP_USERS
         WHERE OBJECT_TYPE = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type')
           AND OBJECT_VALUE = p_agent_id;

        RETURN v_id;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN null;  
    END user_id_by_agent_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION agent_id_by_user_id (  
        p_user_id IN NUMBER  
    ) RETURN NUMBER IS  
        v_agent_id NUMBER; 
        -- v_user_name VARCHAR2(255); 
    BEGIN

        SELECT OBJECT_VALUE
        INTO v_agent_id
        FROM APP_USERS 
       WHERE ID = p_user_id;

        RETURN v_agent_id;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN null;  
    END agent_id_by_user_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION group_id_by_agent_id (  
        p_agent_id IN NUMBER  
    ) RETURN NUMBER IS  
        v_id NUMBER;  
    BEGIN  
        SELECT GROUP_ID  
          INTO v_id  
          FROM AGENTS  
         WHERE ID = p_agent_id;

        RETURN v_id;
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN null;  
    END group_id_by_agent_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION group_name_by_agent_id (  
        p_agent_id IN NUMBER,  
        p_lang   IN VARCHAR2  
    ) RETURN VARCHAR2 IS  
        v_name VARCHAR2(255);  
    BEGIN  
        SELECT DECODE(p_lang,'en',NAME_EN ,NAME_AR) AS name  
          INTO v_name  
          FROM AGENT_GROUPS  
         WHERE ID = (SELECT GROUP_ID FROM AGENTS WHERE ID = p_agent_id);
         
        RETURN v_name;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN '';  
    END group_name_by_agent_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================  

    FUNCTION group_id_by_company_id (  
        p_company_id IN NUMBER  
    ) RETURN NUMBER IS  
        v_id NUMBER;  
    BEGIN  
        SELECT GROUP_ID  
          INTO v_id  
          FROM COMPANIES_AGENTS  
         WHERE COMPANY_ID = p_company_id  
        FETCH FIRST 1 ROW ONLY;

        RETURN v_id;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN null;  
    END group_id_by_company_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--================================================================================================= 
    
    FUNCTION agent_is_privilege (  
        p_agent_id   IN NUMBER,   
        p_company_id IN NUMBER  
    ) RETURN NUMBER IS  
        v_result  NUMBER;  
    BEGIN  
        SELECT COUNT(1)  
          INTO v_result  
          FROM COMPANIES_AGENTS 
         WHERE COMPANY_ID = p_company_id  
           AND GROUP_ID = group_id_by_agent_id( p_agent_id => p_agent_id )  
           AND NVL(IS_ACTIVE, 0) = 1;
           
        RETURN v_result;   
    END agent_is_privilege;
    
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION create_agent (
        p_agent_name         IN VARCHAR2,
        p_agent_type         IN NUMBER,
        p_identity_no        IN VARCHAR2,
        p_phone              IN VARCHAR2,
        p_whats              IN VARCHAR2,
        p_email              IN VARCHAR2,
        p_bank               IN VARCHAR2,
        p_account_no         IN VARCHAR2,
        p_iban               IN VARCHAR2,
        p_is_active          IN NUMBER,
        p_insurance_type     IN NUMBER,
        p_truck_type         IN NUMBER,
        p_operation_no       IN VARCHAR2,
        p_operation_card_url IN VARCHAR2,
        p_identity_url       IN VARCHAR2,
        p_registration_url   IN VARCHAR2,
        p_lang               IN VARCHAR2 DEFAULT 'ar',
        p_message            OUT VARCHAR2
    ) RETURN NUMBER IS
        v_user_id          NUMBER;
        v_role_id          NUMBER;
        v_agent_type       VARCHAR2(255);
        v_agent_id         NUMBER;
        v_count            NUMBER;

    BEGIN 
        IF p_agent_name IS NULL OR p_agent_type IS NULL OR p_identity_no IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        -- SELECT COUNT(1)
        --   INTO v_count
        --   FROM AGENTS
        --  WHERE IDENTITY_NUMBER = p_identity_
        -- IF v_count > 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'agent_is_exists', p_lang => p_lang); -- TRANS
        --     RETURN -3;
        -- END IF;

        INSERT INTO AGENTS ( NAME_AR, AGENT_TYPE, IDENTITY_NUMBER, EMAIL, PHONE, WHATS, IDENTITY_URL, BANK_NAME, BANK_ACCOUNT_NUMBER, IBAN, IS_ACTIVE )
                    VALUES ( p_agent_name, p_agent_type, p_identity_no, p_email, p_phone, p_whats, p_identity_url, p_bank, p_account_no, p_iban, p_is_active ) 
        RETURNING ID INTO v_agent_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -4;
            ROLLBACK;
        END IF;

        IF p_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
            INSERT INTO TRANSPORTATION_AGENT_DETAILS ( AGENT_ID, INSURANCE_TYPE, TRUCK_TYPE, OPERATION_NO, OPERATION_CARD, REGISTRATION_URL, IS_ACTIVE )
                        VALUES ( v_agent_id, p_insurance_type, p_truck_type, p_operation_no, p_operation_card_url, p_registration_url, p_is_active );

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -5;
                ROLLBACK;
            END IF;
        END IF;
        
        --ADD USER
        INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS,
                                CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE, OBJECT_TYPE, OBJECT_VALUE )
            VALUES ( p_identity_no, p_agent_name, p_phone, p_whats, p_identity_no, APP_USER_SECURITY.get_hash(p_identity_no, p_identity_no),
                     p_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type'),
                     LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type'), v_agent_id )
        RETURNING ID INTO v_user_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -6;
            ROLLBACK;
        END IF;

        -- ADD USER ROLE
        v_agent_type := LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => p_agent_type );
        IF v_agent_type IN ('washing', 'photography', 'washing_photographing') THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Assigned Agent');
        ELSIF v_agent_type = 'exhibition' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Exhibition Agent');
        ELSIF v_agent_type = 'transfer_ownership' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Transfer Ownership');
        ELSIF v_agent_type = 'inspection' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Inspection');
        ELSIF v_agent_type = 'transportation' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Transportation');
        ELSIF v_agent_type = 'Insurance' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Insurance');
        ELSIF v_agent_type = 'guarantee' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Guarantee');
        ELSIF v_agent_type = 'realestate_evaluation' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Real Estate Evaluator');
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'You Should choose an available role');
        END IF;

        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( v_user_id, v_role_id, 'Y', GET_CURRENT_DATE );

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
    END create_agent;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION update_agent (
        p_agent_id           IN NUMBER,
        p_agent_name         IN VARCHAR2,
        p_agent_type         IN NUMBER,
        p_identity_no        IN VARCHAR2,
        p_phone              IN VARCHAR2,
        p_whats              IN VARCHAR2,
        p_email              IN VARCHAR2,
        p_bank               IN VARCHAR2,
        p_account_no         IN VARCHAR2,
        p_iban               IN VARCHAR2,
        p_is_active          IN NUMBER,
        p_insurance_type     IN NUMBER,
        p_truck_type         IN NUMBER,
        p_operation_no       IN VARCHAR2,
        p_operation_card_url IN VARCHAR2,
        p_identity_url       IN VARCHAR2,
        p_registration_url   IN VARCHAR2,
        p_lang               IN VARCHAR2 DEFAULT 'ar',
        p_message            OUT VARCHAR2
    ) RETURN NUMBER IS 
        v_user_id    NUMBER;
        v_role_id    NUMBER;
        v_agent_type VARCHAR2(255);
        v_current_agent_type NUMBER;
        v_count    NUMBER;
    BEGIN 
        IF p_agent_name IS NULL OR p_agent_type IS NULL OR p_identity_no IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        SELECT AGENT_TYPE
          INTO v_current_agent_type
          FROM AGENTS
         WHERE ID = p_agent_id;

        UPDATE AGENTS
           SET NAME_AR = p_agent_name,
               AGENT_TYPE = p_agent_type,
               IDENTITY_NUMBER = p_identity_no,
               EMAIL = p_email,
               PHONE = p_phone,
               WHATS = p_whats,
               IDENTITY_URL = p_identity_url,
               BANK_NAME = p_bank,
               BANK_ACCOUNT_NUMBER = p_account_no, 
               IBAN = p_iban,
               IS_ACTIVE =  p_is_active
         WHERE ID = p_agent_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
            ROLLBACK;
        END IF;

        IF p_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
            IF v_current_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
                -- SELECT COUNT(1)
                --   INTO v_count
                --   FROM TRANSPORTATION_AGENT_DETAILS
                --  WHERE AGENT_ID = p_agent_id;
                -- IF v_count = 0 THEN
                -- --EORRO
                -- END IF;   
                UPDATE TRANSPORTATION_AGENT_DETAILS
                   SET INSURANCE_TYPE = p_insurance_type,
                       TRUCK_TYPE = p_truck_type,
                       OPERATION_NO = p_operation_no,
                       OPERATION_CARD = p_operation_card_url,
                       REGISTRATION_URL = p_registration_url,
                       IS_ACTIVE =  p_is_active
                 WHERE AGENT_ID = p_agent_id;

                IF SQL%ROWCOUNT = 0 THEN 
                    p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || 'UPDATE';
                    RETURN -5;
                    ROLLBACK;
                END IF;

            ELSIF v_current_agent_type <> LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
                -- INSERT INTO TRANSPORTATION_AGENT_DETAILS
                INSERT INTO TRANSPORTATION_AGENT_DETAILS ( AGENT_ID, INSURANCE_TYPE, TRUCK_TYPE, OPERATION_NO, OPERATION_CARD, REGISTRATION_URL, IS_ACTIVE )
                            VALUES ( p_agent_id, p_insurance_type, p_truck_type, p_operation_no, p_operation_card_url, p_registration_url, p_is_active );

                IF SQL%ROWCOUNT = 0 THEN 
                    p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang)|| 'INSERT';
                    RETURN -5;
                    ROLLBACK;
                END IF;
            END IF;

        ELSIF  p_agent_type <> LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') AND v_current_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
        
            --DELETE FROM TRANSPORTATION_AGENT_DETAILS
            DELETE FROM TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -4;
            END IF;

        END IF;


        SELECT ID
          INTO v_user_id
          FROM APP_USERS
         WHERE OBJECT_VALUE = p_agent_id
           AND OBJECT_TYPE  = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type');

        -- UPDATE USER
        UPDATE APP_USERS
           SET CLIENT_ID_NO  = p_identity_no,
               USER_NAME     = p_identity_no,
               PASSWORD      = APP_USER_SECURITY.get_hash(p_identity_no, p_identity_no),
               PERSONAL_NAME = p_agent_name,
               PHONE         = p_phone,
               WHATS_PHONE   = p_whats,
               EMAIL_ADDRESS = p_email,
               ACTIVE_FLAG   = DECODE(p_is_active, 1, 'Y', 'N')
         WHERE ID = v_user_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            -- RAISE_APPLICATION_ERROR(-20001, 'User Modification Error');
            RETURN -5;
            ROLLBACK;
        END IF;

        -- ADD USER ROLE
        v_agent_type := LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => p_agent_type );
        IF v_agent_type IN ('washing', 'photography', 'washing_photographing') THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Assigned Agent');
        ELSIF v_agent_type = 'exhibition' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Exhibition Agent');
        ELSIF v_agent_type = 'transfer_ownership' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Transfer Ownership');
        ELSIF v_agent_type = 'inspection' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Inspection');
        ELSIF v_agent_type = 'transportation' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Transportation');
        ELSIF v_agent_type = 'Insurance' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Insurance');
        ELSIF v_agent_type = 'guarantee' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Guarantee');
        ELSIF v_agent_type = 'realestate_evaluation' THEN
            v_role_id := APP_USER_SECURITY.role_id_by_name('Real Estate Evaluator');
        ELSE
            RAISE_APPLICATION_ERROR(-20002, 'You Should choose an available role');
        END IF;

        UPDATE APP_USER_ROLES
           SET ROLE_ID = v_role_id
         WHERE USER_ID = v_user_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -6;
            ROLLBACK;
        END IF;

        RETURN 1;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;
    END update_agent;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_agent (
        p_agent_id IN NUMBER,
        p_lang     IN VARCHAR2 DEFAULT 'ar',
        p_message  OUT VARCHAR2
    ) RETURN NUMBER IS 
        v_user_id    NUMBER;
        v_agent_type  NUMBER;
    BEGIN 

        SELECT AGENT_TYPE
          INTO v_agent_type
          FROM AGENTS
         WHERE ID = p_agent_id;

        SELECT ID
          INTO v_user_id
          FROM APP_USERS
         WHERE OBJECT_VALUE = p_agent_id
           AND OBJECT_TYPE  = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type');

        -- DELETE ROLE
        DELETE FROM APP_USER_ROLES WHERE USER_ID = v_user_id;
        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -2;
            ROLLBACK;
        END IF;

        -- DELETE USER
        DELETE FROM APP_USERS WHERE ID = v_user_id;
        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
            ROLLBACK;
        END IF;

        --DELETE AGENT
        IF v_agent_type =  LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
            DELETE FROM TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id; 
            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -4;
                ROLLBACK;
            END IF;
        END IF; 

        DELETE FROM AGENTS WHERE ID = p_agent_id;
        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -5;
            ROLLBACK;
        END IF;

        RETURN 1;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;

    END delete_agent;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    -- FUNCTION create_agent (
    --     p_agent_name         IN VARCHAR2,
    --     p_agent_type         IN VARCHAR2,
    --     p_identity_no        IN VARCHAR2,
    --     p_phone              IN VARCHAR2,
    --     p_whats              IN VARCHAR2,
    --     p_email              IN VARCHAR2,
    --     p_bank               IN VARCHAR2,
    --     p_account_no         IN VARCHAR2,
    --     p_iban               IN VARCHAR2,
    --     p_is_active          IN NUMBER,
    --     p_insurance_type     IN NUMBER,
    --     p_truck_type         IN NUMBER,
    --     p_operation_no       IN VARCHAR2,
    --     p_operation_card_url IN VARCHAR2,
    --     p_identity_url       IN VARCHAR2,
    --     p_registration_url   IN VARCHAR2,
    --     p_lang               IN VARCHAR2 DEFAULT 'ar',
    --     p_message            OUT VARCHAR2
    -- ) RETURN NUMBER IS
    --     v_user_id          NUMBER;
    --     v_role_id          NUMBER;
    --     v_agent_type       VARCHAR2(255);
    --     v_agent_id         NUMBER;
    --     v_count            NUMBER;
    --     v_agent_type_array APEX_T_VARCHAR2;

    -- BEGIN 
    --     IF p_agent_name IS NULL OR p_agent_type IS NULL OR p_identity_no IS NULL THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
    --         RETURN -2;
    --     END IF;

    --     INSERT INTO AGENTS ( NAME_AR, AGENT_TYPE, IDENTITY_NUMBER, EMAIL, PHONE, WHATS, IDENTITY_URL, BANK_NAME, BANK_ACCOUNT_NUMBER, IBAN, IS_ACTIVE )
    --                 VALUES ( p_agent_name, p_agent_type, p_identity_no, p_email, p_phone, p_whats, p_identity_url, p_bank, p_account_no, p_iban, p_is_active ) 
    --     RETURNING ID INTO v_agent_id;

    --     IF SQL%ROWCOUNT = 0 THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --         RETURN -4;
    --         ROLLBACK;
    --     END IF;

    --     v_agent_type_array := APEX_STRING.SPLIT(p_agent_type, ',');
    --     FOR i IN 1..v_agent_type_array.COUNT LOOP

    --         IF v_agent_type_array(i) IN (LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type')) THEN 
    --             INSERT INTO TRANSPORTATION_AGENT_DETAILS ( AGENT_ID, INSURANCE_TYPE, TRUCK_TYPE, OPERATION_NO, OPERATION_CARD, REGISTRATION_URL, IS_ACTIVE )
    --                         VALUES ( v_agent_id, p_insurance_type, p_truck_type, p_operation_no, p_operation_card_url, p_registration_url, p_is_active );

    --             IF SQL%ROWCOUNT = 0 THEN 
    --                 p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --                 RETURN -5;
    --                 ROLLBACK;
    --             END IF;
    --         END IF;
    --     END LOOP;
        
    --     --ADD USER
    --     INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS,
    --                             CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE, OBJECT_TYPE, OBJECT_VALUE )
    --         VALUES ( p_identity_no, p_agent_name, p_phone, p_whats, p_identity_no, APP_USER_SECURITY.get_hash(p_identity_no, p_identity_no),
    --                  p_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type'),
    --                  LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type'), v_agent_id )
    --     RETURNING ID INTO v_user_id;

    --     IF SQL%ROWCOUNT = 0 THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --         RETURN -6;
    --         ROLLBACK;
    --     END IF;

    --     FOR i IN 1..v_agent_type_array.COUNT LOOP
    --     -- ADD USER ROLE
    --         v_agent_type := LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => v_agent_type_array(i) );
    --         IF v_agent_type IN ('washing', 'photography', 'washing_photographing') THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Assigned Agent');
    --         ELSIF v_agent_type = 'exhibition' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Exhibition Agent');
    --         ELSIF v_agent_type = 'transfer_ownership' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Transfer Ownership');
    --         ELSIF v_agent_type = 'inspection' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Inspection');
    --         ELSIF v_agent_type = 'transportation' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Transportation');
    --         ELSIF v_agent_type = 'Insurance' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Insurance');
    --         ELSIF v_agent_type = 'guarantee' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Guarantee');
    --         ELSE
    --             RAISE_APPLICATION_ERROR(-20002, 'You Should choose an available role');
    --         END IF;

    --         INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
    --             VALUES ( v_user_id, v_role_id, 'Y', GET_CURRENT_DATE );

    --         IF SQL%ROWCOUNT = 0 THEN 
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -7;
    --             ROLLBACK;
    --         END IF;
    --     END LOOP;

    --     RETURN 1;

    -- EXCEPTION
    --     WHEN OTHERS THEN
    --         ROLLBACK;
    --         p_message := SQLERRM;
    --         RETURN -1;
    -- END create_agent;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    -- FUNCTION update_agent (
    --     p_agent_id           IN NUMBER,
    --     p_agent_name         IN VARCHAR2,
    --     p_agent_type         IN VARCHAR2,
    --     p_identity_no        IN VARCHAR2,
    --     p_phone              IN VARCHAR2,
    --     p_whats              IN VARCHAR2,
    --     p_email              IN VARCHAR2,
    --     p_bank               IN VARCHAR2,
    --     p_account_no         IN VARCHAR2,
    --     p_iban               IN VARCHAR2,
    --     p_is_active          IN NUMBER,
    --     p_insurance_type     IN NUMBER,
    --     p_truck_type         IN NUMBER,
    --     p_operation_no       IN VARCHAR2,
    --     p_operation_card_url IN VARCHAR2,
    --     p_identity_url       IN VARCHAR2,
    --     p_registration_url   IN VARCHAR2,
    --     p_lang               IN VARCHAR2 DEFAULT 'ar',
    --     p_message            OUT VARCHAR2
    -- ) RETURN NUMBER IS 
    --     v_user_id            NUMBER;
    --     v_role_id            NUMBER;
    --     v_count              NUMBER;
    --     v_agent_type         VARCHAR2(255);
    --     -- v_current_agent_type_array APEX_T_VARCHAR2;
    --     v_agent_type_array         APEX_T_VARCHAR2;
    -- BEGIN 
    --     IF p_agent_name IS NULL OR p_agent_type IS NULL OR p_identity_no IS NULL THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
    --         RETURN -2;
    --     END IF;

    --     -- SELECT APEX_STRING.SPLIT(AGENT_TYPE, ',')
    --     --   INTO v_current_agent_type_array
    --     --   FROM AGENTS
    --     --  WHERE ID = p_agent_id;

    --     UPDATE AGENTS
    --        SET NAME_AR = p_agent_name,
    --            AGENT_TYPE = p_agent_type,
    --            IDENTITY_NUMBER = p_identity_no,
    --            EMAIL = p_email,
    --            PHONE = p_phone,
    --            WHATS = p_whats,
    --            IDENTITY_URL = p_identity_url,
    --            BANK_NAME = p_bank,
    --            BANK_ACCOUNT_NUMBER = p_account_no, 
    --            IBAN = p_iban,
    --            IS_ACTIVE =  p_is_active
    --      WHERE ID = p_agent_id;


    --     IF SQL%ROWCOUNT = 0 THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '3';
    --         RETURN -3;
    --         ROLLBACK;
    --     END IF;

    --     v_agent_type_array := APEX_STRING.SPLIT(p_agent_type, ',');

    --     FOR i IN 1..v_agent_type_array.COUNT LOOP
    --         IF v_agent_type_array(i) IN (LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type')) THEN
    --             SELECT COUNT(1) INTO v_count FROM TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id;
    --                 IF v_count <> 0 THEN
    --                     UPDATE TRANSPORTATION_AGENT_DETAILS
    --                        SET INSURANCE_TYPE = p_insurance_type,
    --                            TRUCK_TYPE = p_truck_type,
    --                            OPERATION_NO = p_operation_no,
    --                            OPERATION_CARD = p_operation_card_url,
    --                            REGISTRATION_URL = p_registration_url,
    --                            IS_ACTIVE =  p_is_active
    --                      WHERE AGENT_ID = p_agent_id;

    --                     IF SQL%ROWCOUNT = 0 THEN 
    --                         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '4';
    --                         RETURN -4;
    --                         ROLLBACK;
    --                     END IF;
    --                 ELSIF v_count = 0 THEN
    --                     INSERT INTO TRANSPORTATION_AGENT_DETAILS ( AGENT_ID, INSURANCE_TYPE, TRUCK_TYPE, OPERATION_NO, OPERATION_CARD, REGISTRATION_URL, IS_ACTIVE )
    --                          VALUES ( p_agent_id, p_insurance_type, p_truck_type, p_operation_no, p_operation_card_url, p_registration_url, p_is_active );

    --                     IF SQL%ROWCOUNT = 0 THEN 
    --                         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '5';
    --                         RETURN -5;
    --                         ROLLBACK;
    --                     END IF;
    --                 END IF;
    --         ELSIF v_agent_type_array(i) NOT IN (LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type')) THEN
    --             SELECT COUNT(1) INTO v_count FROM TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id;
    --             IF v_count <> 0 THEN
    --                 DELETE TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id;
    --                 IF SQL%ROWCOUNT = 0 THEN 
    --                     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '6';
    --                     RETURN -6;
    --                     ROLLBACK;
    --                 END IF; 
    --             END IF;
    --         END IF;
    --     END LOOP;

    --     SELECT ID
    --       INTO v_user_id
    --       FROM APP_USERS
    --      WHERE OBJECT_VALUE = p_agent_id
    --        AND OBJECT_TYPE  = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type');

    --     -- UPDATE USER
    --     UPDATE APP_USERS
    --        SET CLIENT_ID_NO  = p_identity_no,
    --            USER_NAME     = p_identity_no,
    --            PASSWORD      = APP_USER_SECURITY.get_hash(p_identity_no, p_identity_no),
    --            PERSONAL_NAME = p_agent_name,
    --            PHONE         = p_phone,
    --            WHATS_PHONE   = p_whats,
    --            EMAIL_ADDRESS = p_email,
    --            ACTIVE_FLAG   = DECODE(p_is_active, 1, 'Y', 'N')
    --      WHERE ID = v_user_id;

    --     IF SQL%ROWCOUNT = 0 THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang)|| '7' ;
    --         RETURN -7;
    --         ROLLBACK;
    --     END IF;

    --     DELETE FROM APP_USER_ROLES WHERE USER_ID = v_user_id;
    --     FOR i IN 1..v_agent_type_array.COUNT LOOP
    --     -- ADD USER ROLE
    --         v_agent_type := LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => v_agent_type_array(i) );
    --         IF v_agent_type IN ('washing', 'photography', 'washing_photographing') THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Assigned Agent');
    --         ELSIF v_agent_type = 'exhibition' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Exhibition Agent');
    --         ELSIF v_agent_type = 'transfer_ownership' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Transfer Ownership');
    --         ELSIF v_agent_type = 'inspection' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Inspection');
    --         ELSIF v_agent_type = 'transportation' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Transportation');
    --         ELSIF v_agent_type = 'Insurance' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Insurance');
    --         ELSIF v_agent_type = 'guarantee' THEN
    --             v_role_id := APP_USER_SECURITY.role_id_by_name('Guarantee');
            -- ELSIF v_agent_type = 'realestate_evaluation' THEN
            --     v_role_id := APP_USER_SECURITY.role_id_by_name('Real Estate Evaluator');
    --         ELSE
    --             RAISE_APPLICATION_ERROR(-20002, 'You Should choose an available role');
    --         END IF;

    --         INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
    --             VALUES ( v_user_id, v_role_id, 'Y', GET_CURRENT_DATE );

    --         IF SQL%ROWCOUNT = 0 THEN 
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '8';
    --             RETURN -8;
    --             ROLLBACK;
    --         END IF;

    --     END LOOP;

    --     RETURN 1;

    -- EXCEPTION
    --     WHEN OTHERS THEN
    --         ROLLBACK;
    --         p_message := SQLERRM;
    --         RETURN -1;
    -- END update_agent;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    -- FUNCTION delete_agent (
    --     p_agent_id IN NUMBER,
    --     p_lang     IN VARCHAR2 DEFAULT 'ar',
    --     p_message  OUT VARCHAR2
    -- ) RETURN NUMBER IS 
    --     v_user_id    NUMBER;
    --     v_agent_type  APEX_T_VARCHAR2;
    -- BEGIN 

    --     SELECT APEX_STRING.SPLIT(AGENT_TYPE, ',')
    --       INTO v_agent_type
    --       FROM AGENTS
    --       WHERE ID = p_agent_id;

    --     SELECT ID
    --       INTO v_user_id
    --       FROM APP_USERS
    --      WHERE OBJECT_VALUE = p_agent_id
    --        AND OBJECT_TYPE  = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type');

    --     -- DELETE ROLE
    --     DELETE FROM APP_USER_ROLES WHERE USER_ID = v_user_id;
    --     IF SQL%ROWCOUNT = 0 THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '2';
    --         RETURN -2;
    --         ROLLBACK;
    --     END IF;

    --     -- DELETE USER
    --     DELETE FROM APP_USERS WHERE ID = v_user_id;
    --     IF SQL%ROWCOUNT = 0 THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '3';
    --         RETURN -3;
    --         ROLLBACK;
    --     END IF;

    --     --DELETE AGENT
    --     FOR i IN 1..v_agent_type.COUNT LOOP
    --         IF v_agent_type(i) = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
    --             DELETE FROM TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id; 
    --             IF SQL%ROWCOUNT = 0 THEN 
    --                 p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '4';
    --                 RETURN -4;
    --                 ROLLBACK;
    --             END IF;
    --         END IF;
    --     END LOOP;

    --     DELETE FROM AGENTS WHERE ID = p_agent_id;
    --     IF SQL%ROWCOUNT = 0 THEN 
    --         p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || '5';
    --         RETURN -5;
    --         ROLLBACK;
    --     END IF;

    --     RETURN 1;

    -- EXCEPTION
    --     WHEN OTHERS THEN
    --         ROLLBACK;
    --         p_message := SQLERRM;
    --         RETURN -1;
    -- END delete_agent;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END AGENTS_PKG;
/