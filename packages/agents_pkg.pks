
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."AGENTS_PKG" AS  
  
    FUNCTION agent_name_by_id (  
        p_id      IN NUMBER,  
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

    -- FUNCTION create_agent (
    --     p_agent_name         IN VARCHAR2,
    --     p_agent_type         IN NUMBER,
    --     p_identity_no        IN VARCHAR2,
    --     p_phone              IN VARCHAR2,
    --     p_whats              IN VARCHAR2,
    --     p_email              IN VARCHAR2,
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
    --     p_agent_type         IN NUMBER,
    --     p_identity_no        IN VARCHAR2,
    --     p_phone              IN VARCHAR2,
    --     p_whats              IN VARCHAR2,
    --     p_email              IN VARCHAR2,
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

    FUNCTION create_agent (
        p_agent_name         IN VARCHAR2,
        p_agent_type         IN VARCHAR2,
        p_identity_no        IN VARCHAR2,
        p_phone              IN VARCHAR2,
        p_whats              IN VARCHAR2,
        p_email              IN VARCHAR2,
        p_bank               IN VARCHAR2,
        p_account_no         IN VARCHAR2,
        p_iban               IN VARCHAR2,
        p_is_active          IN NUMBER DEFAULT 1,
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
        p_agent_type         IN VARCHAR2,
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

END AGENTS_PKG;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."AGENTS_PKG" AS

    FUNCTION AGENT_NAME_BY_ID (
        P_ID IN NUMBER,
        P_LANG IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_NAME VARCHAR2(255);
    BEGIN
        SELECT
            DECODE(P_LANG, 'en', NAME_EN, NAME_AR) AS NAME INTO V_NAME
        FROM
            AGENTS
        WHERE
            ID = P_ID;
        RETURN V_NAME;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END AGENT_NAME_BY_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION AGENT_TYPE_BY_ID (
        P_ID IN NUMBER,
        P_LANG IN VARCHAR2 DEFAULT 'ar'
    ) RETURN VARCHAR2 IS
        V_AGENT_TYPE      APEX_T_VARCHAR2;
        V_AGENT_TYPE_NAME VARCHAR2(2550);
    BEGIN
        SELECT
            APEX_STRING.SPLIT(AGENT_TYPE, ',') INTO V_AGENT_TYPE
        FROM
            AGENTS
        WHERE
            ID = P_ID;
        FOR I IN 1..V_AGENT_TYPE.COUNT LOOP
            IF P_LANG = 'ar' THEN
                V_AGENT_TYPE_NAME := V_AGENT_TYPE_NAME
                                     || LOOKUPS_MNT.LOOKUP_DETAIL_NAME_BY_ID (V_AGENT_TYPE(I), P_LANG)
                                                    || ' - ';
            ELSIF P_LANG = 'en' THEN
                V_AGENT_TYPE_NAME := V_AGENT_TYPE_NAME
                                     || ' - '
                                     || LOOKUPS_MNT.LOOKUP_DETAIL_NAME_BY_ID (V_AGENT_TYPE(I), P_LANG);
            END IF;
        END LOOP;

        RETURN V_AGENT_TYPE_NAME;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END AGENT_TYPE_BY_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION AGENT_TYPE_CODE_BY_ID (
        P_ID IN NUMBER
    ) RETURN VARCHAR2 IS
        V_AGENT_TYPE      APEX_T_VARCHAR2;
        V_AGENT_TYPE_NO   VARCHAR2(255);
        V_AGENT_TYPE_NAME VARCHAR2(2550);
    BEGIN
        SELECT
            APEX_STRING.SPLIT(AGENT_TYPE, ',') INTO V_AGENT_TYPE
        FROM
            AGENTS
        WHERE
            ID = 54;
        FOR I IN 1..V_AGENT_TYPE.COUNT LOOP
            V_AGENT_TYPE_NAME := LOOKUPS_MNT.LOOKUP_DETAIL_CODE_BY_ID (
                P_LOOKUP_DETAIL_ID => V_AGENT_TYPE(I)
            )
            || ','
            || V_AGENT_TYPE_NAME;
        END LOOP;

        RETURN V_AGENT_TYPE_NAME;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END AGENT_TYPE_CODE_BY_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION AGENTS_ID_BY_TYPE (
        P_TYPE IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_COUNT      NUMBER;
        V_AGENT_TYPE VARCHAR2(355);
        V_AGENT_IDS  VARCHAR2(255);
    BEGIN
        IF TRIM(LOWER(P_TYPE)) = TRIM(LOWER('photo')) THEN
            FOR I IN (
                SELECT
                    ID,
                    AGENT_TYPE
                FROM
                    AGENTS
                WHERE
                    IS_ACTIVE = 1
            ) LOOP
                SELECT
                    COUNT(1) INTO V_COUNT
                FROM
                    LOOKUP_DETAIL
                WHERE
                    ID IN (
                        SELECT
                            COLUMN_VALUE
                        FROM
                            APEX_STRING.SPLIT(
                                P_STR => I.AGENT_TYPE,
                                P_SEP => ','
                            )
                    )
                    AND CODE IN ('washing', 'photography', 'washing_photographing');
                IF V_COUNT <> 0 THEN
                    V_AGENT_IDS := I.ID
                                   || ','
                                   || V_AGENT_IDS;
                END IF;
            END LOOP;
        ELSIF TRIM(LOWER(P_TYPE)) = TRIM(LOWER('inspect')) THEN
            FOR I IN (
                SELECT
                    ID,
                    AGENT_TYPE
                FROM
                    AGENTS
                WHERE
                    IS_ACTIVE = 1
            ) LOOP
                SELECT
                    COUNT(1) INTO V_COUNT
                FROM
                    LOOKUP_DETAIL
                WHERE
                    ID IN (
                        SELECT
                            COLUMN_VALUE
                        FROM
                            APEX_STRING.SPLIT(
                                P_STR => I.AGENT_TYPE,
                                P_SEP => ','
                            )
                    )
                    AND CODE = 'inspection';
                IF V_COUNT <> 0 THEN
                    V_AGENT_IDS := I.ID
                                   || ','
                                   || V_AGENT_IDS;
                END IF;
            END LOOP;
        ELSIF TRIM(LOWER(P_TYPE)) = TRIM(LOWER('evaluation')) THEN
            FOR I IN (
                SELECT
                    ID,
                    AGENT_TYPE
                FROM
                    AGENTS
                WHERE
                    IS_ACTIVE = 1
            ) LOOP
                SELECT
                    COUNT(1) INTO V_COUNT
                FROM
                    LOOKUP_DETAIL
                WHERE
                    ID IN (
                        SELECT
                            COLUMN_VALUE
                        FROM
                            APEX_STRING.SPLIT(
                                P_STR => I.AGENT_TYPE,
                                P_SEP => ','
                            )
                    )
                    AND CODE = 'realestate_evaluation';
                IF V_COUNT <> 0 THEN
                    V_AGENT_IDS := I.ID
                                   || ','
                                   || V_AGENT_IDS;
                END IF;
            END LOOP;
        END IF;

        RETURN V_AGENT_IDS;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END AGENTS_ID_BY_TYPE;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION USER_ID_BY_AGENT_ID (
        P_AGENT_ID IN NUMBER
    ) RETURN NUMBER IS
        V_ID NUMBER;
    BEGIN
        SELECT
            ID INTO V_ID
        FROM
            APP_USERS
        WHERE
            OBJECT_TYPE = LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE (
                P_LOOKUP_DETAIL_CODE => 'agent',
                P_LOOKUP_CODE => 'user_type'
            )
            AND OBJECT_VALUE = P_AGENT_ID;
        RETURN V_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END USER_ID_BY_AGENT_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION AGENT_ID_BY_USER_ID (
        P_USER_ID IN NUMBER
    ) RETURN NUMBER IS
        V_AGENT_ID NUMBER;
 
        -- v_user_name VARCHAR2(255);
    BEGIN
        SELECT
            OBJECT_VALUE INTO V_AGENT_ID
        FROM
            APP_USERS
        WHERE
            ID = P_USER_ID;
 
        -- SELECT USER_NAME
        --   INTO v_user_name
        --   FROM APP_USERS
        --  WHERE ID = p_user_id;
        -- SELECT ID
        --   INTO v_agent_id
        --   FROM AGENTS
        --  WHERE IDENTITY_NUMBER = TO_NUMBER(v_user_name);
        RETURN V_AGENT_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END AGENT_ID_BY_USER_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION GROUP_ID_BY_AGENT_ID (
        P_AGENT_ID IN NUMBER
    ) RETURN NUMBER IS
        V_ID NUMBER;
    BEGIN
        SELECT
            GROUP_ID INTO V_ID
        FROM
            AGENTS
        WHERE
            ID = P_AGENT_ID;
        RETURN V_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GROUP_ID_BY_AGENT_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION GROUP_NAME_BY_AGENT_ID (
        P_AGENT_ID IN NUMBER,
        P_LANG IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_NAME VARCHAR2(255);
    BEGIN
        SELECT
            DECODE(P_LANG, 'en', NAME_EN, NAME_AR) AS NAME INTO V_NAME
        FROM
            AGENT_GROUPS
        WHERE
            ID = (
                SELECT
                    GROUP_ID
                FROM
                    AGENTS
                WHERE
                    ID = P_AGENT_ID
            );
        RETURN V_NAME;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END GROUP_NAME_BY_AGENT_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION GROUP_ID_BY_COMPANY_ID (
        P_COMPANY_ID IN NUMBER
    ) RETURN NUMBER IS
        V_ID NUMBER;
    BEGIN
        SELECT
            GROUP_ID INTO V_ID
        FROM
            COMPANIES_AGENTS
        WHERE
            COMPANY_ID = P_COMPANY_ID FETCH FIRST 1 ROW ONLY;
        RETURN V_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GROUP_ID_BY_COMPANY_ID;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION AGENT_IS_PRIVILEGE (
        P_AGENT_ID IN NUMBER,
        P_COMPANY_ID IN NUMBER
    ) RETURN NUMBER IS
        V_RESULT NUMBER;
    BEGIN
        SELECT
            COUNT(1) INTO V_RESULT
        FROM
            COMPANIES_AGENTS
        WHERE
            COMPANY_ID = P_COMPANY_ID
            AND GROUP_ID = GROUP_ID_BY_AGENT_ID(
                P_AGENT_ID => P_AGENT_ID
            )
            AND NVL(IS_ACTIVE, 0) = 1;
        RETURN V_RESULT;
    END AGENT_IS_PRIVILEGE;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    --     FUNCTION create_agent (
    --         p_agent_name         IN VARCHAR2,
    --         p_agent_type         IN NUMBER,
    --         p_identity_no        IN VARCHAR2,
    --         p_phone              IN VARCHAR2,
    --         p_whats              IN VARCHAR2,
    --         p_email              IN VARCHAR2,
    --         p_is_active          IN NUMBER,
    --         p_insurance_type     IN NUMBER,
    --         p_truck_type         IN NUMBER,
    --         p_operation_no       IN VARCHAR2,
    --         p_operation_card_url IN VARCHAR2,
    --         p_identity_url       IN VARCHAR2,
    --         p_registration_url   IN VARCHAR2,
    --         p_lang               IN VARCHAR2 DEFAULT 'ar',
    --         p_message            OUT VARCHAR2
    --     ) RETURN NUMBER IS
    --         v_user_id    NUMBER;
    --         v_role_id    NUMBER;
    --         v_agent_type VARCHAR2(255);
    --         v_agent_id NUMBER;
    --         v_count    NUMBER;
    --     BEGIN
    --         IF p_agent_name IS NULL OR p_agent_type IS NULL OR p_identity_no IS NULL THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
    --             RETURN -2;
    --         END IF;
    --         -- SELECT COUNT(1)
    --         --   INTO v_count
    --         --   FROM AGENTS
    --         --  WHERE IDENTITY_NUMBER = p_identity_
    --         -- IF v_count > 0 THEN
    --         --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'agent_is_exists', p_lang => p_lang); -- TRANS
    --         --     RETURN -3;
    --         -- END IF;
    --         INSERT INTO AGENTS ( NAME_AR, AGENT_TYPE, IDENTITY_NUMBER, EMAIL, PHONE, WHATS, IDENTITY_URL, IS_ACTIVE )
    --                     VALUES ( p_agent_name, p_agent_type, p_identity_no, p_email, p_phone, p_whats, p_identity_url, p_is_active )
    --         RETURNING ID INTO v_agent_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -4;
    --             ROLLBACK;
    --         END IF;
    --         IF p_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
    --             --null
    --             INSERT INTO TRANSPORTATION_AGENT_DETAILS ( AGENT_ID, INSURANCE_TYPE, TRUCK_TYPE, OPERATION_NO, OPERATION_CARD, REGISTRATION_URL, IS_ACTIVE )
    --                         VALUES ( v_agent_id, p_insurance_type, p_truck_type, p_operation_no, p_operation_card_url, p_registration_url, p_is_active );
    --             IF SQL%ROWCOUNT = 0 THEN
    --                 p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --                 RETURN -5;
    --                 ROLLBACK;
    --             END IF;
    --         END IF;
    --         --ADD USER
    --         INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS,
    --                                 CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE, OBJECT_TYPE, OBJECT_VALUE )
    --             VALUES ( p_identity_no, p_agent_name, p_phone, p_whats, p_identity_no, APP_USER_SECURITY.get_hash(p_identity_no, p_identity_no),
    --                      p_email, GET_CURRENT_DATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type'),
    --                      LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type'), v_agent_id )
    --         RETURNING ID INTO v_user_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -6;
    --             ROLLBACK;
    --         END IF;
    --         -- ADD USER ROLE
    --         v_agent_type := LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => p_agent_type );
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
    --         RETURN 1;
    --     EXCEPTION
    --         WHEN OTHERS THEN
    --             ROLLBACK;
    --             p_message := SQLERRM;
    --             RETURN -1;
    --     END create_agent;
    -- --=================================================================================================
    -- --===================================== END OF FUNCTION ===========================================
    -- --=================================================================================================
    --     FUNCTION update_agent (
    --         p_agent_id           IN NUMBER,
    --         p_agent_name         IN VARCHAR2,
    --         p_agent_type         IN NUMBER,
    --         p_identity_no        IN VARCHAR2,
    --         p_phone              IN VARCHAR2,
    --         p_whats              IN VARCHAR2,
    --         p_email              IN VARCHAR2,
    --         p_is_active          IN NUMBER,
    --         p_insurance_type     IN NUMBER,
    --         p_truck_type         IN NUMBER,
    --         p_operation_no       IN VARCHAR2,
    --         p_operation_card_url IN VARCHAR2,
    --         p_identity_url       IN VARCHAR2,
    --         p_registration_url   IN VARCHAR2,
    --         p_lang               IN VARCHAR2 DEFAULT 'ar',
    --         p_message            OUT VARCHAR2
    --     ) RETURN NUMBER IS
    --         v_user_id    NUMBER;
    --         v_role_id    NUMBER;
    --         v_agent_type VARCHAR2(255);
    --         v_current_agent_type NUMBER;
    --         v_count    NUMBER;
    --     BEGIN
    --         -- AGENT_ID
    --         IF p_agent_name IS NULL OR p_agent_type IS NULL OR p_identity_no IS NULL THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
    --             RETURN -2;
    --         END IF;
    --         SELECT AGENT_TYPE
    --           INTO v_current_agent_type
    --           FROM AGENTS
    --          WHERE ID = p_agent_id;
    --         UPDATE AGENTS
    --            SET NAME_AR = p_agent_name,
    --                AGENT_TYPE = p_agent_type,
    --                IDENTITY_NUMBER = p_identity_no,
    --                EMAIL = p_email,
    --                PHONE = p_phone,
    --                WHATS = p_whats,
    --                IDENTITY_URL = p_identity_url,
    --                IS_ACTIVE =  p_is_active
    --          WHERE ID = p_agent_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -3;
    --             ROLLBACK;
    --         END IF;
    --         IF p_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
    --             IF v_current_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
    --                 --UPDATE TRANSPORTATION_AGENT_DETAILS
    --                 -- SELECT COUNT(1)
    --                 --   INTO v_count
    --                 --   FROM TRANSPORTATION_AGENT_DETAILS
    --                 --  WHERE AGENT_ID = p_agent_id;
    --                 -- IF v_count = 0 THEN
    --                 -- --EORRO
    --                 -- END IF;
    --                 UPDATE TRANSPORTATION_AGENT_DETAILS
    --                    SET INSURANCE_TYPE = p_insurance_type,
    --                        TRUCK_TYPE = p_truck_type,
    --                        OPERATION_NO = p_operation_no,
    --                        OPERATION_CARD = p_operation_card_url,
    --                        REGISTRATION_URL = p_registration_url,
    --                        IS_ACTIVE =  p_is_active
    --                  WHERE AGENT_ID = p_agent_id;
    --                 IF SQL%ROWCOUNT = 0 THEN
    --                     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || 'UPDATE';
    --                     RETURN -5;
    --                     ROLLBACK;
    --                 END IF;
    --             ELSIF v_current_agent_type <> LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
    --                 -- INSERT INTO TRANSPORTATION_AGENT_DETAILS
    --                 INSERT INTO TRANSPORTATION_AGENT_DETAILS ( AGENT_ID, INSURANCE_TYPE, TRUCK_TYPE, OPERATION_NO, OPERATION_CARD, REGISTRATION_URL, IS_ACTIVE )
    --                             VALUES ( p_agent_id, p_insurance_type, p_truck_type, p_operation_no, p_operation_card_url, p_registration_url, p_is_active );
    --                 IF SQL%ROWCOUNT = 0 THEN
    --                     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang)|| 'INSERT';
    --                     RETURN -5;
    --                     ROLLBACK;
    --                 END IF;
    --             END IF;
    --         ELSIF  p_agent_type <> LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') AND v_current_agent_type = LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
    --             --DELETE FROM TRANSPORTATION_AGENT_DETAILS
    --             DELETE FROM TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id;
    --             IF SQL%ROWCOUNT = 0 THEN
    --                 p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --                 RETURN -4;
    --             END IF;
    --         END IF;
    --         SELECT ID
    --           INTO v_user_id
    --           FROM APP_USERS
    --          WHERE OBJECT_VALUE = p_agent_id
    --            AND OBJECT_TYPE  = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type');
    --         -- UPDATE USER
    --         UPDATE APP_USERS
    --            SET CLIENT_ID_NO  = p_identity_no,
    --                USER_NAME     = p_identity_no,
    --                PASSWORD      = APP_USER_SECURITY.get_hash(p_identity_no, p_identity_no),
    --                PERSONAL_NAME = p_agent_name,
    --                PHONE         = p_phone,
    --                WHATS_PHONE   = p_whats,
    --                EMAIL_ADDRESS = p_email,
    --                ACTIVE_FLAG   = DECODE(p_is_active, 1, 'Y', 'N')
    --          WHERE ID = v_user_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             -- RAISE_APPLICATION_ERROR(-20001, 'User Modification Error');
    --             RETURN -5;
    --             ROLLBACK;
    --         END IF;
    --         -- ADD USER ROLE
    --         v_agent_type := LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => p_agent_type );
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
    --         UPDATE APP_USER_ROLES
    --            SET ROLE_ID = v_role_id
    --          WHERE USER_ID = v_user_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -6;
    --             ROLLBACK;
    --         END IF;
    --         RETURN 1;
    --     EXCEPTION
    --         WHEN OTHERS THEN
    --             ROLLBACK;
    --             p_message := SQLERRM;
    --             RETURN -1;
    --     END update_agent;
    -- --=================================================================================================
    -- --===================================== END OF FUNCTION ===========================================
    -- --=================================================================================================
    --     FUNCTION delete_agent (
    --         p_agent_id IN NUMBER,
    --         p_lang     IN VARCHAR2 DEFAULT 'ar',
    --         p_message  OUT VARCHAR2
    --     ) RETURN NUMBER IS
    --         v_user_id    NUMBER;
    --         v_agent_type  NUMBER;
    --     BEGIN
    --         SELECT AGENT_TYPE
    --           INTO v_agent_type
    --           FROM AGENTS
    --          WHERE ID = p_agent_id;
    --         SELECT ID
    --           INTO v_user_id
    --           FROM APP_USERS
    --          WHERE OBJECT_VALUE = p_agent_id
    --            AND OBJECT_TYPE  = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'agent', p_lookup_code => 'user_type');
    --         -- DELETE ROLE
    --         DELETE FROM APP_USER_ROLES WHERE USER_ID = v_user_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -2;
    --             ROLLBACK;
    --         END IF;
    --         -- DELETE USER
    --         DELETE FROM APP_USERS WHERE ID = v_user_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -3;
    --             ROLLBACK;
    --         END IF;
    --         --DELETE AGENT
    --         IF v_agent_type =  LOOKUPS_MNT.lookup_detail_id_by_code('transportation', 'agent_type') THEN
    --             DELETE FROM TRANSPORTATION_AGENT_DETAILS WHERE AGENT_ID = p_agent_id;
    --             IF SQL%ROWCOUNT = 0 THEN
    --                 p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --                 RETURN -4;
    --                 ROLLBACK;
    --             END IF;
    --         END IF;
    --         DELETE FROM AGENTS WHERE ID = p_agent_id;
    --         IF SQL%ROWCOUNT = 0 THEN
    --             p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
    --             RETURN -5;
    --             ROLLBACK;
    --         END IF;
    --         RETURN 1;
    --     EXCEPTION
    --         WHEN OTHERS THEN
    --             ROLLBACK;
    --             p_message := SQLERRM;
    --             RETURN -1;
    --     END delete_agent;
    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    
    FUNCTION CREATE_AGENT (
        P_AGENT_NAME IN VARCHAR2,
        P_AGENT_TYPE IN VARCHAR2,
        P_IDENTITY_NO IN VARCHAR2,
        P_PHONE IN VARCHAR2,
        P_WHATS IN VARCHAR2,
        P_EMAIL IN VARCHAR2,
        P_BANK IN VARCHAR2,
        P_ACCOUNT_NO IN VARCHAR2,
        P_IBAN IN VARCHAR2,
        P_IS_ACTIVE IN NUMBER,
        P_INSURANCE_TYPE IN NUMBER,
        P_TRUCK_TYPE IN NUMBER,
        P_OPERATION_NO IN VARCHAR2,
        P_OPERATION_CARD_URL IN VARCHAR2,
        P_IDENTITY_URL IN VARCHAR2,
        P_REGISTRATION_URL IN VARCHAR2,
        P_LANG IN VARCHAR2 DEFAULT 'ar',
        P_MESSAGE OUT VARCHAR2
    ) RETURN NUMBER IS
        V_USER_ID          NUMBER;
        V_ROLE_ID          NUMBER;
        V_AGENT_TYPE       VARCHAR2(255);
        V_AGENT_ID         NUMBER;
        V_COUNT            NUMBER;
        V_AGENT_TYPE_ARRAY APEX_T_VARCHAR2;
    BEGIN
        IF P_AGENT_NAME IS NULL OR P_AGENT_TYPE IS NULL OR P_IDENTITY_NO IS NULL THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'missing_data',
                P_LANG => P_LANG
            );
            RETURN -2;
        END IF;

        INSERT INTO AGENTS (
            NAME_AR,
            -- AGENT_TYPE,
            AGENT_TYPE_V2,
            IDENTITY_NUMBER,
            EMAIL,
            PHONE,
            WHATS,
            IDENTITY_URL,
            BANK_NAME,
            BANK_ACCOUNT_NUMBER,
            IBAN,
            IS_ACTIVE
        ) VALUES (
            P_AGENT_NAME,
            P_AGENT_TYPE,
            P_IDENTITY_NO,
            P_EMAIL,
            P_PHONE,
            P_WHATS,
            P_IDENTITY_URL,
            P_BANK,
            P_ACCOUNT_NO,
            P_IBAN,
            P_IS_ACTIVE
        ) RETURNING ID INTO V_AGENT_ID;
        IF SQL%ROWCOUNT = 0 THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'server_error',
                P_LANG => P_LANG
            );
            RETURN -4;
            ROLLBACK;
        END IF;

        V_AGENT_TYPE_ARRAY := APEX_STRING.SPLIT(P_AGENT_TYPE, ',');
        FOR I IN 1..V_AGENT_TYPE_ARRAY.COUNT LOOP
            IF V_AGENT_TYPE_ARRAY(I) IN (LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE('transportation', 'agent_type')) THEN
                INSERT INTO TRANSPORTATION_AGENT_DETAILS (
                    AGENT_ID,
                    INSURANCE_TYPE,
                    TRUCK_TYPE,
                    OPERATION_NO,
                    OPERATION_CARD,
                    REGISTRATION_URL,
                    IS_ACTIVE
                ) VALUES (
                    V_AGENT_ID,
                    P_INSURANCE_TYPE,
                    P_TRUCK_TYPE,
                    P_OPERATION_NO,
                    P_OPERATION_CARD_URL,
                    P_REGISTRATION_URL,
                    P_IS_ACTIVE
                );
                IF SQL%ROWCOUNT = 0 THEN
                    P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                        P_CODE => 'server_error',
                        P_LANG => P_LANG
                    );
                    RETURN -5;
                    ROLLBACK;
                END IF;
            END IF;
        END LOOP;
 

        --ADD USER
        INSERT INTO APP_USERS (
            CLIENT_ID_NO,
            PERSONAL_NAME,
            PHONE,
            WHATS_PHONE,
            USER_NAME,
            PASSWORD,
            EMAIL_ADDRESS,
            START_DATE,
            ALLOW_CHANGE_PASS,
            CHANGE_PASS_NEXT_LOGIN,
            ACTIVE_FLAG,
            USER_LANGUAGE_ID,
            USER_TYPE,
            OBJECT_TYPE,
            OBJECT_VALUE
        ) VALUES (
            P_IDENTITY_NO,
            P_AGENT_NAME,
            P_PHONE,
            P_WHATS,
            P_IDENTITY_NO,
            APP_USER_SECURITY.GET_HASH(P_IDENTITY_NO, P_IDENTITY_NO),
            P_EMAIL,
            GET_CURRENT_DATE,
            'Y',
            'N',
            'Y',
            1,
            LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE (P_LOOKUP_DETAIL_CODE => 'agent', P_LOOKUP_CODE => 'user_type'),
            LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE (P_LOOKUP_DETAIL_CODE => 'agent', P_LOOKUP_CODE => 'user_type'),
            V_AGENT_ID
        ) RETURNING ID INTO V_USER_ID;
        IF SQL%ROWCOUNT = 0 THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'server_error',
                P_LANG => P_LANG
            );
            RETURN -6;
            ROLLBACK;
        END IF;

        FOR I IN 1..V_AGENT_TYPE_ARRAY.COUNT LOOP
 
            -- ADD USER ROLE
            V_AGENT_TYPE := LOOKUPS_MNT.LOOKUP_DETAIL_CODE_BY_ID (
                P_LOOKUP_DETAIL_ID => V_AGENT_TYPE_ARRAY(I)
            );
            IF V_AGENT_TYPE IN ('washing', 'photography', 'washing_photographing') THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Assigned Agent');
            ELSIF V_AGENT_TYPE = 'exhibition' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Exhibition Agent');
            ELSIF V_AGENT_TYPE = 'transfer_ownership' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Transfer Ownership');
            ELSIF V_AGENT_TYPE = 'inspection' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Inspection');
            ELSIF V_AGENT_TYPE = 'transportation' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Transportation');
            ELSIF V_AGENT_TYPE = 'Insurance' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Insurance');
            ELSIF V_AGENT_TYPE = 'guarantee' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Guarantee');
            ELSIF V_AGENT_TYPE = 'realestate_evaluation' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Real Estate Evaluator');
            ELSE
                RAISE_APPLICATION_ERROR(-20002, 'You Should choose an available role');
            END IF;

            INSERT INTO APP_USER_ROLES (
                USER_ID,
                ROLE_ID,
                ENABLE_FLAG,
                START_DATE
            ) VALUES (
                V_USER_ID,
                V_ROLE_ID,
                'Y',
                GET_CURRENT_DATE
            );
            IF SQL%ROWCOUNT = 0 THEN
                P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                    P_CODE => 'server_error',
                    P_LANG => P_LANG
                );
                RETURN -7;
                ROLLBACK;
            END IF;
        END LOOP;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            P_MESSAGE := SQLERRM;
            RETURN -1;
    END CREATE_AGENT;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION UPDATE_AGENT (
        P_AGENT_ID IN NUMBER,
        P_AGENT_NAME IN VARCHAR2,
        P_AGENT_TYPE IN VARCHAR2,
        P_IDENTITY_NO IN VARCHAR2,
        P_PHONE IN VARCHAR2,
        P_WHATS IN VARCHAR2,
        P_EMAIL IN VARCHAR2,
        P_BANK IN VARCHAR2,
        P_ACCOUNT_NO IN VARCHAR2,
        P_IBAN IN VARCHAR2,
        P_IS_ACTIVE IN NUMBER,
        P_INSURANCE_TYPE IN NUMBER,
        P_TRUCK_TYPE IN NUMBER,
        P_OPERATION_NO IN VARCHAR2,
        P_OPERATION_CARD_URL IN VARCHAR2,
        P_IDENTITY_URL IN VARCHAR2,
        P_REGISTRATION_URL IN VARCHAR2,
        P_LANG IN VARCHAR2 DEFAULT 'ar',
        P_MESSAGE OUT VARCHAR2
    ) RETURN NUMBER IS
        V_USER_ID          NUMBER;
        V_ROLE_ID          NUMBER;
        V_COUNT            NUMBER;
        V_AGENT_TYPE       VARCHAR2(255);
 
        -- v_current_agent_type_array APEX_T_VARCHAR2;
        V_AGENT_TYPE_ARRAY APEX_T_VARCHAR2;
    BEGIN
        IF P_AGENT_NAME IS NULL OR P_AGENT_TYPE IS NULL OR P_IDENTITY_NO IS NULL THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'missing_data',
                P_LANG => P_LANG
            );
            RETURN -2;
        END IF;
        UPDATE AGENTS
        SET
            NAME_AR = P_AGENT_NAME,
            AGENT_TYPE = P_AGENT_TYPE,
            IDENTITY_NUMBER = P_IDENTITY_NO,
            EMAIL = P_EMAIL,
            PHONE = P_PHONE,
            WHATS = P_WHATS,
            IDENTITY_URL = P_IDENTITY_URL,
            BANK_NAME = P_BANK,
            BANK_ACCOUNT_NUMBER = P_ACCOUNT_NO,
            IBAN = P_IBAN,
            IS_ACTIVE = P_IS_ACTIVE
        WHERE
            ID = P_AGENT_ID;
        IF SQL%ROWCOUNT = 0 THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'server_error',
                P_LANG => P_LANG
            )
            || '3';
            RETURN -3;
            ROLLBACK;
        END IF;

        V_AGENT_TYPE_ARRAY := APEX_STRING.SPLIT(P_AGENT_TYPE, ',');
        FOR I IN 1..V_AGENT_TYPE_ARRAY.COUNT LOOP
            IF V_AGENT_TYPE_ARRAY(I) IN (LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE('transportation', 'agent_type')) THEN
                SELECT
                    COUNT(1) INTO V_COUNT
                FROM
                    TRANSPORTATION_AGENT_DETAILS
                WHERE
                    AGENT_ID = P_AGENT_ID;
                IF V_COUNT <> 0 THEN
                    UPDATE TRANSPORTATION_AGENT_DETAILS
                    SET
                        INSURANCE_TYPE = P_INSURANCE_TYPE,
                        TRUCK_TYPE = P_TRUCK_TYPE,
                        OPERATION_NO = P_OPERATION_NO,
                        OPERATION_CARD = P_OPERATION_CARD_URL,
                        REGISTRATION_URL = P_REGISTRATION_URL,
                        IS_ACTIVE = P_IS_ACTIVE
                    WHERE
                        AGENT_ID = P_AGENT_ID;
                    IF SQL%ROWCOUNT = 0 THEN
                        P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                            P_CODE => 'server_error',
                            P_LANG => P_LANG
                        )
                        || '4';
                        RETURN -4;
                        ROLLBACK;
                    END IF;
                ELSIF V_COUNT = 0 THEN
                    INSERT INTO TRANSPORTATION_AGENT_DETAILS (
                        AGENT_ID,
                        INSURANCE_TYPE,
                        TRUCK_TYPE,
                        OPERATION_NO,
                        OPERATION_CARD,
                        REGISTRATION_URL,
                        IS_ACTIVE
                    ) VALUES (
                        P_AGENT_ID,
                        P_INSURANCE_TYPE,
                        P_TRUCK_TYPE,
                        P_OPERATION_NO,
                        P_OPERATION_CARD_URL,
                        P_REGISTRATION_URL,
                        P_IS_ACTIVE
                    );
                    IF SQL%ROWCOUNT = 0 THEN
                        P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                            P_CODE => 'server_error',
                            P_LANG => P_LANG
                        )
                        || '5';
                        RETURN -5;
                        ROLLBACK;
                    END IF;
                END IF;
            ELSIF V_AGENT_TYPE_ARRAY(I) NOT IN (LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE('transportation', 'agent_type')) THEN
                SELECT
                    COUNT(1) INTO V_COUNT
                FROM
                    TRANSPORTATION_AGENT_DETAILS
                WHERE
                    AGENT_ID = P_AGENT_ID;
                IF V_COUNT <> 0 THEN
                    DELETE TRANSPORTATION_AGENT_DETAILS
                    WHERE
                        AGENT_ID = P_AGENT_ID;
                    IF SQL%ROWCOUNT = 0 THEN
                        P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                            P_CODE => 'server_error',
                            P_LANG => P_LANG
                        )
                        || '6';
                        RETURN -6;
                        ROLLBACK;
                    END IF;
                END IF;
            END IF;
        END LOOP;

        SELECT
            ID INTO V_USER_ID
        FROM
            APP_USERS
        WHERE
            OBJECT_VALUE = P_AGENT_ID
            AND OBJECT_TYPE = LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE (
                P_LOOKUP_DETAIL_CODE => 'agent',
                P_LOOKUP_CODE => 'user_type'
            );
 
        -- UPDATE USER
        UPDATE APP_USERS
        SET
            CLIENT_ID_NO = P_IDENTITY_NO,
            USER_NAME = P_IDENTITY_NO,
            PASSWORD = APP_USER_SECURITY.GET_HASH(
                P_IDENTITY_NO,
                P_IDENTITY_NO
            ),
            PERSONAL_NAME = P_AGENT_NAME,
            PHONE = P_PHONE,
            WHATS_PHONE = P_WHATS,
            EMAIL_ADDRESS = P_EMAIL,
            ACTIVE_FLAG = DECODE(
                P_IS_ACTIVE,
                1,
                'Y',
                'N'
            )
        WHERE
            ID = V_USER_ID;
        IF SQL%ROWCOUNT = 0 THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'server_error',
                P_LANG => P_LANG
            )
            || '7';
            RETURN -7;
            ROLLBACK;
        END IF;
        DELETE FROM APP_USER_ROLES
        WHERE
            USER_ID = V_USER_ID;
        FOR I IN 1..V_AGENT_TYPE_ARRAY.COUNT LOOP
 
            -- ADD USER ROLE
            V_AGENT_TYPE := LOOKUPS_MNT.LOOKUP_DETAIL_CODE_BY_ID (
                P_LOOKUP_DETAIL_ID => V_AGENT_TYPE_ARRAY(I)
            );
            IF V_AGENT_TYPE IN ('washing', 'photography', 'washing_photographing') THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Assigned Agent');
            ELSIF V_AGENT_TYPE = 'exhibition' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Exhibition Agent');
            ELSIF V_AGENT_TYPE = 'transfer_ownership' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Transfer Ownership');
            ELSIF V_AGENT_TYPE = 'inspection' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Inspection');
            ELSIF V_AGENT_TYPE = 'transportation' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Transportation');
            ELSIF V_AGENT_TYPE = 'Insurance' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Insurance');
            ELSIF V_AGENT_TYPE = 'guarantee' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Guarantee');
            ELSIF V_AGENT_TYPE = 'realestate_evaluation' THEN
                V_ROLE_ID := APP_USER_SECURITY.ROLE_ID_BY_NAME('Real Estate Evaluator');
            ELSE
                RAISE_APPLICATION_ERROR(-20002, 'You Should choose an available role');
            END IF;

            INSERT INTO APP_USER_ROLES (
                USER_ID,
                ROLE_ID,
                ENABLE_FLAG,
                START_DATE
            ) VALUES (
                V_USER_ID,
                V_ROLE_ID,
                'Y',
                GET_CURRENT_DATE
            );
            IF SQL%ROWCOUNT = 0 THEN
                P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                    P_CODE => 'server_error',
                    P_LANG => P_LANG
                )
                || '8';
                RETURN -8;
                ROLLBACK;
            END IF;
        END LOOP;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            P_MESSAGE := SQLERRM;
            RETURN -1;
    END UPDATE_AGENT;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
    FUNCTION DELETE_AGENT (
        P_AGENT_ID IN NUMBER,
        P_LANG IN VARCHAR2 DEFAULT 'ar',
        P_MESSAGE OUT VARCHAR2
    ) RETURN NUMBER IS
        V_USER_ID    NUMBER;
        V_AGENT_TYPE APEX_T_VARCHAR2;
    BEGIN
        SELECT
            APEX_STRING.SPLIT(AGENT_TYPE, ',') INTO V_AGENT_TYPE
        FROM
            AGENTS
        WHERE
            ID = P_AGENT_ID;
        SELECT
            ID INTO V_USER_ID
        FROM
            APP_USERS
        WHERE
            OBJECT_VALUE = P_AGENT_ID
            AND OBJECT_TYPE = LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE (
                P_LOOKUP_DETAIL_CODE => 'agent',
                P_LOOKUP_CODE => 'user_type'
            );
 
        -- DELETE ROLE
        DELETE FROM APP_USER_ROLES
        WHERE
            USER_ID = V_USER_ID;
        IF SQL%ROWCOUNT = 0 THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'server_error',
                P_LANG => P_LANG
            )
            || '2';
            RETURN -2;
            ROLLBACK;
        END IF;
 

        -- DELETE USER
        DELETE FROM APP_USERS
        WHERE
            ID = V_USER_ID;
        IF SQL%ROWCOUNT = 0 THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'server_error',
                P_LANG => P_LANG
            )
            || '3';
            RETURN -3;
            ROLLBACK;
        END IF;
 

        --DELETE AGENT
        FOR I IN 1..V_AGENT_TYPE.COUNT LOOP
            IF V_AGENT_TYPE(I) = LOOKUPS_MNT.LOOKUP_DETAIL_ID_BY_CODE('transportation', 'agent_type') THEN
                DELETE FROM TRANSPORTATION_AGENT_DETAILS
                WHERE
                    AGENT_ID = P_AGENT_ID;
                IF SQL%ROWCOUNT = 0 THEN
                    P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                        P_CODE => 'server_error',
                        P_LANG => P_LANG
                    )
                    || '4';
                    RETURN -4;
                    ROLLBACK;
                END IF;
            END IF;
        END LOOP;
        DELETE FROM AGENTS
        WHERE
            ID = P_AGENT_ID;
        IF SQL%ROWCOUNT = 0 THEN
            P_MESSAGE := SYSTEM_CONTROLS.GET_TRANSLATION(
                P_CODE => 'server_error',
                P_LANG => P_LANG
            )
            || '5';
            RETURN -5;
            ROLLBACK;
        END IF;

        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            P_MESSAGE := SQLERRM;
            RETURN -1;
    END DELETE_AGENT;
 

    --=================================================================================================
    --===================================== END OF FUNCTION ===========================================
    --=================================================================================================
END AGENTS_PKG;
/