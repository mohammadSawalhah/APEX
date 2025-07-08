
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."SELLERS_REQ" as    
    /*
        Holds the result of the function in two internal members
        .code -> Numeric code used to locate where the error occured
        .message -> Contains a short message describing what triggered the error
    */
    TYPE function_result IS RECORD (
        code    NUMBER,
        message VARCHAR2(256)
    );

    /*
        Actual function used to create an inactive seller and associated tables
        SELLERS / SELLER_CITIES / SELLER_CATEGORIES / SELLER_BANK_ACCOUNTS / APP_USERS / EMPLOYEES / APPLICANTS
    */
    FUNCTION CREATE_SIGNUP_REQUEST (
        p_seller_type               NUMBER,
        p_seller_other              VARCHAR2,
        p_tradename_ar              VARCHAR2,
        p_tradename_en              VARCHAR2,
        p_applicant_name            VARCHAR2,
        p_phone_number              VARCHAR2,
        p_email                     VARCHAR2,
        p_cr_number                 VARCHAR2,
        p_tax_number                VARCHAR2,
        p_country_id                NUMBER,
        p_applicant_type            NUMBER,
        p_cities                    VARCHAR2,
        p_activities                VARCHAR2,
        p_bank_id                   NUMBER,
        p_currency_id               NUMBER,
        p_iban                      VARCHAR2,
        p_bank_acc_name             VARCHAR2,
        p_bank_acc_num              VARCHAR2,
        p_admin_name                VARCHAR2,
        p_admin_natid               VARCHAR2,
        p_admin_idtype_id           NUMBER,
        p_admin_job                 VARCHAR2,
        p_admin_email               VARCHAR2,
        p_admin_phone               VARCHAR2,
        p_mnger_name                VARCHAR2,
        p_mnger_natid               VARCHAR2,
        p_mnger_idtype_id           NUMBER,
        p_mnger_job                 VARCHAR2,
        p_mnger_email               VARCHAR2,
        p_mnger_phone               VARCHAR2,
        p_mnger_is_admin            NUMBER,
        p_iban_url                  VARCHAR2,
        p_cr_url                    VARCHAR2,
        p_tax_url                   VARCHAR2,
        p_nat_address_id_url        VARCHAR2,
        p_logo_url                  VARCHAR2,
        p_admin_id_url              VARCHAR2,
        p_admin_auth_url            VARCHAR2,
        p_applicant_auth_url        VARCHAR2,
        p_lang                      VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;

    /*
        Sets Seller and all associated entries in other tables to Active
        SELLERS / SELLER_CITIES / SELLER_CATEGORIES / SELLER_BANK_ACCOUNTS / APP_USERS / EMPLOYEES
    */
    FUNCTION ACTIVATE_SELLER (
        p_seller_id     NUMBER,
        p_seller_type     NUMBER ,
        p_lang            VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;


    FUNCTION CONFIRM_REQUEST(
        p_emp_id        number,
        p_seller_id       number,
        p_lang          VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;

    /*
        Sets Seller and all associated entries in other tables to Inactive/
        (This will deactivate the user's account)
        SELLERS / SELLER_CITIES / SELLER_CATEGORIES / SELLER_BANK_ACCOUNTS / APP_USERS / EMPLOYEES
    */
    FUNCTION DEACTIVATE_SELLER (
        p_seller_id     NUMBER,
        p_lang            VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;

    /*
        Sets the Request_status of the provided seller to "Rejected".
    */
    FUNCTION REJECT_SELLER (
        p_emp_id          NUMBER,
        p_seller_id       NUMBER,
        p_reject_reason   VARCHAR2,
        p_seller_type     NUMBER,
        p_lang            VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;

    FUNCTION UPDATE_SELLER_EMP (
        P_emp_id           NUMBER,
        p_seller_id        NUMBER,
        p_emp_name         VARCHAR2,
        p_national_type_id NUMBER,
        p_national_no      NUMBER,
        p_job              VARCHAR2,
        p_email            VARCHAR2,
        p_phone            NUMBER,
        p_lang            VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;


    FUNCTION UPDATE_SELLER_INFO (
        -- seller table
        p_seller_id        NUMBER,
        P_seller_type_id   NUMBER,
        p_trade_name_ar    VARCHAR2,
        p_trade_name_en    VARCHAR2,
        p_tax_no           NUMBER,
        p_cr_no            NUMBER,
        p_country_id       NUMBER,
        -- seller details requests table
        p_applicant_type   NUMBER,
        p_applicant_name   VARCHAR2,
        p_email            VARCHAR2,
        p_phone            NUMBER,
        -- seller bank details
        p_bank_id          NUMBER,
        p_currency_id      NUMBER,
        p_account_no       VARCHAR2,
        p_iban_no          VARCHAR2,
        p_account_name     VARCHAR2,
        -- cities and categories
        p_cities           VARCHAR2,
        p_categories       VARCHAR2,
        p_lang             VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;


    FUNCTION category_id_by_employee_id (
        p_employee_id  IN NUMBER
        -- p_lang         IN VARCHAR DEFAULT 'ar',
        -- p_message     OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION contract_id_by_seller_id (
        p_seller_id      IN NUMBER,
        p_contract_type  IN varchar2
    ) RETURN NUMBER ;

     FUNCTION CONTRACT_DETAILS_TEMP (
        p_seller_id                NUMBER,
        p_request_details_id       NUMBER,
        p_dependinces_type         NUMBER,
        p_commission_type          NUMBER,
        p_auction_commission       NUMBER DEFAULT NULL,
        p_sold_product_commission  NUMBER DEFAULT NULL,
        p_percentage_commission    NUMBER DEFAULT NULL,
        p_type                     VARCHAR2,
        p_auction_type             NUMBER,
        p_limit_commission         NUMBER DEFAULT NULL,
        p_contract_id              NUMBER,
        p_lang                     VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;

     FUNCTION SELLER_CONTRACT (
        p_seller_id               IN  NUMBER,
        p_request_details_id      IN  NUMBER DEFAULT NULL,
        p_contract_type           IN  VARCHAR2,
        p_contract_start_date     IN  date,
        p_contract_end_date       IN  date,
        p_date                    IN  date DEFAULT SYSDATE,
        p_contract_status         IN  NUMBER DEFAULT 1,
        p_lang                    IN  VARCHAR2 DEFAULT 'ar',
        p_contract_id             OUT NUMBER
        
    ) RETURN function_result;

    FUNCTION ADD_CONTRACT_DETAILS (
        p_request_details_id       NUMBER,
        p_seller_id                NUMBER,
        p_dependinces_type         NUMBER,
        p_commission_type          NUMBER,
        p_auction_commission       NUMBER   DEFAULT NULL,
        p_sold_product_commission  NUMBER   DEFAULT NULL,
        p_percentage_commission    NUMBER   DEFAULT NULL,
        p_contract_notes           VARCHAR2 DEFAULT NULL,
        p_contract_scope           VARCHAR2 DEFAULT NULL,
        p_contract_obligation      VARCHAR2 DEFAULT NULL,
        p_portables_contract_url   VARCHAR2 DEFAULT NULL,
        p_real_estate_contract_url VARCHAR2 DEFAULT NULL,
        p_type                     VARCHAR2,
        p_auction_type             NUMBER,
        p_limit_commission         NUMBER DEFAULT NULL,
        p_contract_id              NUMBER,
        p_lang                     VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result;

END "SELLERS_REQ";
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."SELLERS_REQ" as

    FUNCTION CREATE_SIGNUP_REQUEST (
        p_seller_type               NUMBER,
        p_seller_other              VARCHAR2,
        p_tradename_ar              VARCHAR2,
        p_tradename_en              VARCHAR2,
        p_applicant_name            VARCHAR2,
        p_phone_number              VARCHAR2,
        p_email                     VARCHAR2,
        p_cr_number                 VARCHAR2,
        p_tax_number                VARCHAR2,
        p_country_id                NUMBER,
        p_applicant_type            NUMBER,
        p_cities                    VARCHAR2,
        p_activities                VARCHAR2,
        p_bank_id                   NUMBER,
        p_currency_id               NUMBER,
        p_iban                      VARCHAR2,
        p_bank_acc_name             VARCHAR2,
        p_bank_acc_num              VARCHAR2,
        p_admin_name                VARCHAR2,
        p_admin_natid               VARCHAR2,
        p_admin_idtype_id           NUMBER,
        p_admin_job                 VARCHAR2,
        p_admin_email               VARCHAR2,
        p_admin_phone               VARCHAR2,
        p_mnger_name                VARCHAR2,
        p_mnger_natid               VARCHAR2,
        p_mnger_idtype_id           NUMBER,
        p_mnger_job                 VARCHAR2,
        p_mnger_email               VARCHAR2,
        p_mnger_phone               VARCHAR2,
        p_mnger_is_admin            NUMBER,
        p_iban_url                  VARCHAR2,
        p_cr_url                    VARCHAR2,
        p_tax_url                   VARCHAR2,
        p_nat_address_id_url        VARCHAR2,
        p_logo_url                  VARCHAR2,
        p_admin_id_url              VARCHAR2,
        p_admin_auth_url            VARCHAR2,
        p_applicant_auth_url        VARCHAR2,
        p_lang                      VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result; --Record to hold result (.code and .message)
        v_count NUMBER; --Bucket var to hold existing record checks.
        l_seller_id NUMBER; --DB ID of newly inserted seller.
        l_user_id NUMBER; --DB ID of newly inserted user.
        l_emp_id NUMBER; --DB ID of newly inserted employee.
        v_is_admin NUMBER; --DB ID of newly inserted employee.
        --l_unique_name VARCHAR2(256);
        l_city_id_array APEX_T_VARCHAR2; --Array to store broken up city IDS
        l_cat_id_array APEX_T_VARCHAR2; --Array to store broken up category IDS
    BEGIN
        --<AWS_SECRET>========= VALIDATIONS ===========================================
        -- check if all the main requirments are filled
        IF p_seller_type IS NULL OR p_tradename_ar IS NULL OR p_tradename_en IS NULL OR p_applicant_name IS NULL
           OR p_phone_number IS NULL OR p_email IS NULL THEN
            l_function_result.code := 10;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check if email valid
        IF VALIDATIONS_PKG.VALIDATE_EMAIL(p_email) = false THEN
            l_function_result.code := 35;
            l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_email', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check if phone valid
        IF VALIDATIONS_PKG.VALIDATE_PHONE(p_phone_number) = false THEN
            l_function_result.code := 40;
            l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        -- check if seller type is other then its requirments are filled 
        IF p_seller_type = LOOKUPS_MNT.lookup_detail_id_by_code('other', 'seller_type') AND p_seller_other IS NULL THEN 
            l_function_result.code := 15;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        SELECT COUNT(1)
          INTO v_count
          FROM SELLERS_REQUESTS_DETAILS
         WHERE TRIM(APPLICANT_PHONE_NUMBER) = TRIM(p_phone_number);

        IF v_count > 0 THEN
            l_function_result.code := 16;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'phone_exists', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        IF p_seller_type = LOOKUPS_MNT.lookup_detail_id_by_code('governmental', 'seller_type')
        OR p_seller_type = LOOKUPS_MNT.lookup_detail_id_by_code('other', 'seller_type') THEN
           -- CHECK IF SELLER TRADE NAME IS EXISTS
           SELECT COUNT(1)
             INTO v_count 
             FROM SELLERS
            WHERE TRADE_NAME_EN = p_tradename_en;
           
           IF v_count > 0 THEN
              l_function_result.code := 20;
              l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'tradename_exists', p_lang => p_lang);
              RETURN l_function_result;
            END IF;

           -- CHECK IF APPLICANT EMAIL IS EXISTS
           SELECT COUNT(1)
             INTO v_count 
             FROM SELLERS_REQUESTS_DETAILS
            WHERE APPLICANT_EMAIL = p_email;
           
           IF v_count > 0 THEN
              l_function_result.code := 25;
              l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'applicant_email_exists', p_lang => p_lang);
              RETURN l_function_result;
            END IF;
        ELSE
            -- check if the seller type is not gov or other than the requirments are filled 
            IF p_cr_number IS NULL OR  p_tax_number IS NULL OR p_country_id IS NULL OR p_applicant_type IS NULL OR p_cities IS NULL OR 
               p_activities IS NULL OR p_bank_id IS NULL OR p_currency_id IS NULL OR p_iban IS NULL OR p_bank_acc_name IS NULL OR
               p_bank_acc_num IS NULL OR p_mnger_name IS NULL OR  p_mnger_natid IS NULL OR  p_mnger_idtype_id IS NULL OR  p_mnger_job IS NULL OR
               p_mnger_email IS NULL OR p_mnger_phone IS NULL OR  p_mnger_is_admin IS NULL/* OR  p_iban_url IS NULL OR  p_cr_url IS NULL OR
               p_tax_url IS NULL OR p_logo_url IS NULL OR p_nat_address_id_url IS NULL OR p_admin_id_url IS NULL*/
            THEN
                l_function_result.code := 30;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                RETURN l_function_result;
            END IF; 
            
            -- if applicant type is auth then its requirments are filled 
            -- IF p_applicant_type = LOOKUPS_MNT.lookup_detail_id_by_code('authorized', 'applicant_type') AND p_applicant_auth_url IS NULL 
            -- THEN 
            --      l_function_result.code := 35;
            --      l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            --      RETURN l_function_result;
            -- END IF;
        
           -- CHECK IF SELLER CR IS EXISTS
           SELECT COUNT(1)
             INTO v_count 
             FROM SELLERS
            WHERE IDENTITY_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('cr', 'identity_type') AND
                  IDENTITY_NUMBER = p_cr_number;
           
           IF v_count > 0 THEN
              l_function_result.code := 40;
              l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'cr_exists', p_lang => p_lang);
              RETURN l_function_result;
            END IF;

            --check if CR valid
            IF VALIDATIONS_PKG.VALIDATE_CR(p_cr_number) = false THEN
                l_function_result.code := 45;
                l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_cr', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            --================================================= MANAGER CHECKS ===========================================
            -- CHECK IF SELLER MANAGER EMAIL IS EXISTS
            SELECT COUNT(1)
              INTO v_count
              FROM EMPLOYEES
             WHERE NVL(IS_MANAGER, 0) = 1
               AND TRIM(LOWER(EMAIL)) = TRIM(LOWER(p_mnger_email));

            IF v_count > 0 THEN
                l_function_result.code := 85;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'email_exist', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

          -- CHECK IF SELLER MANAGER ID IS EXISTS
            SELECT COUNT(1)
              INTO v_count
              FROM EMPLOYEES
             WHERE NVL(IS_MANAGER, 0) = 1
               AND TRIM(IDENTITY_NUMBER) = TRIM(p_mnger_natid);

            IF v_count > 0 THEN
                l_function_result.code := 90;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'nid_exist', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

          -- CHECK IF SELLER MANAGER (ID AND PHONE) IS EXISTS
            SELECT COUNT(1)
              INTO v_count
              FROM EMPLOYEES
             WHERE NVL(IS_MANAGER, 0) = 1
               AND TRIM(IDENTITY_NUMBER) = TRIM(p_mnger_natid)
               AND TRIM(PHONE) = TRIM(p_mnger_phone);

            IF v_count > 0 THEN
                l_function_result.code := 95;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'nid_exist', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            --check if manager's email valid 
            IF VALIDATIONS_PKG.VALIDATE_EMAIL(p_mnger_email) = false THEN
                l_function_result.code := 55;
                l_function_result.message := 'Manager''s Email format is Invalid';
                RETURN l_function_result;
            END IF;

            --check if  manager's phone valid
            IF VALIDATIONS_PKG.VALIDATE_PHONE(p_mnger_phone) = false THEN
                l_function_result.code := 65;
                l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            --check if  manager's ID valid
            IF VALIDATIONS_PKG.VALIDATE_ID(p_mnger_natid) = false THEN
                l_function_result.code := 75;
                l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_id', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            -- if admin is manager is auth then its requirments are filled 
            IF p_mnger_is_admin = 0 THEN
                IF p_admin_name IS NULL OR p_admin_natid IS NULL OR p_admin_idtype_id IS NULL OR p_admin_job IS NULL OR
                   p_admin_email IS NULL OR p_admin_phone IS NULL --OR p_admin_auth_url IS NULL
                THEN
                    l_function_result.code := 50;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                    RETURN l_function_result;
                END IF;
                    
                --check if admin's email valid 
                IF VALIDATIONS_PKG.VALIDATE_EMAIL(p_admin_email) = false THEN
                    l_function_result.code := 60;
                    l_function_result.message := 'Admin''s Email format is Invalid';
                    RETURN l_function_result;
                END IF;

                --check if admin's phone valid
                IF VALIDATIONS_PKG.VALIDATE_PHONE(p_admin_phone) = false THEN
                    l_function_result.code := 70;
                    l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
                    RETURN l_function_result;
                END IF;

                --check if admin's ID valid
                IF VALIDATIONS_PKG.VALIDATE_ID(p_admin_natid) = false THEN
                    l_function_result.code := 80;
                    l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_id', p_lang => p_lang);
                    RETURN l_function_result;
                END IF;

              -- CHECK IF SELLER ADMIN EMAIL IS EXISTS
                SELECT COUNT(1)
                  INTO v_count
                  FROM EMPLOYEES
                 WHERE NVL(IS_ADMIN, 0) = 1
                   AND TRIM(LOWER(EMAIL)) = TRIM(LOWER(p_admin_email));

                IF v_count > 0 THEN
                    l_function_result.code := 100;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'email_exist', p_lang => p_lang);
                    RETURN l_function_result;
                END IF;

              -- CHECK IF SELLER ADMIN ID IS EXISTS
                SELECT COUNT(1)
                  INTO v_count
                  FROM EMPLOYEES
                 WHERE NVL(IS_ADMIN, 0) = 1
                   AND TRIM(IDENTITY_NUMBER) = TRIM(p_admin_natid);

                IF v_count > 0 THEN
                    l_function_result.code := 105;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'nid_exist', p_lang => p_lang);
                    RETURN l_function_result;
                END IF;

              -- CHECK IF SELLER ADMIN (ID AND PHONE) IS EXISTS
                SELECT COUNT(1)
                  INTO v_count
                  FROM EMPLOYEES
                 WHERE NVL(IS_ADMIN, 0) = 1
                   AND TRIM(IDENTITY_NUMBER) = TRIM(p_admin_natid)
                   AND TRIM(PHONE) = TRIM(p_admin_phone);

                IF v_count > 0 THEN
                    l_function_result.code := 110;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'nid_exist', p_lang => p_lang);
                    RETURN l_function_result;
                END IF;
            END IF;
        END IF;

        --================================================ INSERTION ================================================
        --Insert inactive pending seller into DB. 
        INSERT INTO SELLERS (COUNTRY_ID,NAME_AR, NAME_EN, TRADE_NAME_AR, TRADE_NAME_EN, IDENTITY_TYPE_ID, IDENTITY_NUMBER,
                             IS_ACTIVE, SELLER_TYPE_ID, TAX_NUMBER, REQUEST_STATUS_ID, PENDING_TYPE_ID, USER_TYPE_ID, AVATAR_URL, OTHER_SELLER_TYPE, DEFAULT_EMAIL, UNIQUE_NAME)
            VALUES (p_country_id, p_tradename_ar, p_tradename_en, p_tradename_ar, p_tradename_en, LOOKUPS_MNT.lookup_detail_id_by_code('cr', 'identity_type'),
                    p_cr_number, 0, p_seller_type, p_tax_number, LOOKUPS_MNT.lookup_detail_id_by_code('pending', 'request_status'),
                    LOOKUPS_MNT.lookup_detail_id_by_code('pending_approval', 'pending_type'), LOOKUPS_MNT.lookup_detail_id_by_code('seller', 'user_type'), p_logo_url, p_seller_other, p_email, REPLACE(LOWER(TRIM(p_tradename_en)),' ','_'))
        RETURNING ID INTO l_seller_id;

        IF SQL%Rowcount = 0 THEN
            l_function_result.code := 115;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            ROLLBACK;
            RETURN l_function_result;
        END IF;

        --Insert urls and check
        INSERT INTO SELLERS_REQUESTS_DETAILS(APPLICANT_NAME, APPLICANT_PHONE_NUMBER, APPLICANT_EMAIL, APPLICANT_TYPE_ID, SELLER_ID,
                                             APPLICANT_AUTHORIZATION_URL, CR_URL, NATIONAL_ADDRESS_URL, TAX_URL, ADMIN_ID_URL,
                                             ADMIN_AUTHORIZATION_URL, IBAN_URL)
            VALUES(p_applicant_name, p_phone_number, p_email, p_applicant_type, l_seller_id, p_applicant_auth_url, p_cr_url, p_nat_address_id_url,
                   p_tax_url, p_admin_id_url, p_admin_auth_url, p_iban_url);

        IF SQL%Rowcount = 0 THEN
            l_function_result.code := 120;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            ROLLBACK;
            RETURN l_function_result;
        END IF;

        IF p_seller_type NOT IN (LOOKUPS_MNT.lookup_detail_id_by_code('governmental', 'seller_type'), LOOKUPS_MNT.lookup_detail_id_by_code('other', 'seller_type')) THEN
            --Split city IDS to array
            l_city_id_array := APEX_STRING.SPLIT(p_cities, ':');
            
            FOR i IN 1..l_city_id_array.COUNT LOOP
                INSERT INTO SELLER_CITIES (SELLER_ID, CITY_ID, IS_ACTIVE) 
                    VALUES (l_seller_id, TO_NUMBER(l_city_id_array(i)), 0);

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 125;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF; 
            END LOOP;

            --split categories into array
            l_cat_id_array := APEX_STRING.SPLIT(p_activities, ':');
            
            FOR i IN 1..l_cat_id_array.COUNT LOOP
                INSERT INTO SELLER_CATEGORIES (SELLER_ID, CATEGORY_ID, IS_ACTIVE) 
                    VALUES (l_seller_id, TO_NUMBER(l_cat_id_array(i)), 0);

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 130;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF; 
            END LOOP;

            --Insert seller bank information into SELLER_BANK_ACCOUNTS
            INSERT INTO SELLER_BANK_ACCOUNTS (SELLER_ID, BANK_ID, CURRENCY_ID, ACCOUNT_NO, ACCOUNT_NAME, IBAN,
                                              IS_OWNER, IS_ACTIVE, IS_VERIFIED, BANK_CARD_URL)
                VALUES(l_seller_id, p_bank_id, p_currency_id, p_bank_acc_num, p_bank_acc_name, p_iban, 1, 0, 0, p_iban_url);

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 135;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF; 

            -- INSERT USER IN CASE THE MANGER IS ADMIN OR IF NOT
            IF p_mnger_is_admin = 1 THEN
                INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE,
                                        ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE )
                    VALUES ( p_mnger_natid, p_mnger_name, p_mnger_phone, p_mnger_phone, p_mnger_natid,
                             APP_USER_SECURITY.get_hash(p_mnger_natid, p_mnger_natid), p_mnger_email,
                             SYSDATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type') )
                RETURNING ID INTO l_user_id;

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 140;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            ELSE
                INSERT INTO APP_USERS ( CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE,
                                        ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE )
                    VALUES ( p_admin_natid, p_admin_name, p_admin_phone, p_admin_phone, p_admin_natid,
                             APP_USER_SECURITY.get_hash(p_admin_natid, p_admin_natid), p_admin_email,
                             SYSDATE, 'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type') )
                RETURNING ID INTO l_user_id;

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 145;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            END IF;

            -- INSERT USER ROLE
            INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
                VALUES ( l_user_id, APP_USER_SECURITY.role_id_by_name('seller_inactive'), 'Y', sysdate );
            
            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 150;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF; 

            -- IF MANGER IS ADMIN OR IF NOT
            IF p_mnger_is_admin = 1 THEN
                v_is_admin := 1;
                INSERT INTO EMPLOYEES(NAME_AR, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, PHONE, EMAIL,
                                      IS_ADMIN, IS_ACTIVE, SELLER_ID, IS_MANAGER, USER_ID)
                    VALUES(p_mnger_name, LOOKUPS_MNT.lookup_detail_id_by_code('employee','user_type'), p_mnger_idtype_id,
                           p_mnger_natid, p_mnger_job, p_mnger_phone, p_mnger_email, v_is_admin, 0, l_seller_id, p_mnger_is_admin, l_user_id)
                RETURNING ID into l_emp_id;

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 155;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            ELSE
                v_is_admin := 0;
                -- ADD MANAGER
                INSERT INTO EMPLOYEES(NAME_AR, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, PHONE, EMAIL,
                                      IS_ADMIN, IS_ACTIVE, SELLER_ID, IS_MANAGER)
                    VALUES(p_mnger_name, LOOKUPS_MNT.lookup_detail_id_by_code('employee','user_type'), p_mnger_idtype_id,
                           p_mnger_natid, p_mnger_job, p_mnger_phone, p_mnger_email, v_is_admin, 1, l_seller_id, 1)
                RETURNING ID into l_emp_id;

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 160;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;

                -- ADD ADMIN
                INSERT INTO EMPLOYEES(NAME_AR, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, PHONE, EMAIL,
                                      IS_ADMIN, IS_ACTIVE, SELLER_ID, IS_MANAGER, USER_ID)
                    VALUES(p_admin_name, LOOKUPS_MNT.lookup_detail_id_by_code('employee','user_type'), p_admin_idtype_id,
                           p_admin_natid, p_admin_job, p_admin_phone, p_admin_email, 1, 0, l_seller_id, p_mnger_is_admin, l_user_id)
                RETURNING ID into l_emp_id;

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 165;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            END IF;
        END IF;

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := 'Seller added successfully';
        RETURN l_function_result;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            l_function_result.code := 0;
            l_function_result.message := SQLERRM;
            RETURN l_function_result;
    END CREATE_SIGNUP_REQUEST;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================   
   
    FUNCTION ACTIVATE_SELLER (
        p_seller_id       NUMBER,
        p_seller_type     NUMBER,
        p_lang            VARCHAR2 DEFAULT 'ar'  
    ) RETURN function_result IS
        l_function_result function_result; --Record to hold result (.code and .message)
        v_count           NUMBER;
        l_admin_emp_id    NUMBER;
    BEGIN
        SAVEPOINT updatestart;

        --Check to make sure SELLER exists
        SELECT COUNT(1) INTO v_count FROM SELLERS
         WHERE ID = p_seller_ID;

        IF v_count = 0 THEN
            l_function_result.code := 10;
            l_function_result.message := 'Seller not found';
            RETURN l_function_result;
        END IF;

        --Update statements and checks follow
        UPDATE SELLERS
           SET IS_ACTIVE = 1,
               REQUEST_STATUS_ID = LOOKUPS_MNT.lookup_detail_id_by_code('approved', 'request_status'),
               PENDING_TYPE_ID = null
         WHERE ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 20;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE SELLERS_REQUESTS_DETAILS
           SET IS_EDITABLE = 0,
               IS_EDITABLE_PORTABLE_CONTRACT = 0,
               IS_EDITABLE_REALESTATE_CONTRACT = 0,
               IS_EDITABLE_CONTRACT = 0 
         WHERE SELLER_ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 25;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        IF p_seller_type NOT IN (LOOKUPS_MNT.lookup_detail_id_by_code('governmental', 'seller_type'), LOOKUPS_MNT.lookup_detail_id_by_code('other', 'seller_type')) THEN
        
            --Check to make sure admin EMPLOYEE exists and grab ID
            SELECT ID into l_admin_emp_id FROM EMPLOYEES
             WHERE SELLER_ID = p_seller_id AND IS_ADMIN = 1;

            IF l_admin_emp_id IS NULL THEN
                l_function_result.code := 15;
                l_function_result.message := 'Admin Employee not found';
                RETURN l_function_result;
            END IF;
            
            UPDATE SELLER_CITIES
               SET IS_ACTIVE = 1
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 30;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE SELLER_CATEGORIES
               SET IS_ACTIVE = 1
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 40;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE SELLER_BANK_ACCOUNTS
               SET IS_ACTIVE = 1
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 50;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE EMPLOYEES
               SET IS_ACTIVE = 1
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0  THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 60;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE APP_USER_ROLES
               SET ROLE_ID = APP_USER_SECURITY.role_id_by_name (p_role_name => 'seller')
             WHERE USER_ID IN (SELECT USER_ID FROM EMPLOYEES WHERE ID = l_admin_emp_id);

            IF SQL%Rowcount = 0  THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 65;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;
        END IF;

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := 'Seller and all associated records activated';
        RETURN l_function_result;
    END ACTIVATE_SELLER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION CONFIRM_REQUEST(
        p_emp_id        NUMBER,
        p_seller_id       NUMBER,
        p_lang          VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result;
        v_count         NUMBER;
        l_categor_id    NUMBER;
        l_real_estate_id NUMBER;
        l_portable_id   NUMBER;
    BEGIN

        l_categor_id := CATEGORY_ID_BY_EMPLOYEE_ID(p_emp_id);
        SELECT ID INTO l_real_estate_id FROM CATEGORIES WHERE CODE = TRIM('real_estates');
        SELECT ID INTO l_portable_id FROM CATEGORIES WHERE CODE = TRIM('portable');

        IF l_categor_id = l_real_estate_id THEN 
            SELECT COUNT(1) INTO v_count FROM SELLERS_REQUESTS_DETAILS WHERE SELLER_ID = p_seller_id AND REALESTATE_CONFIRMATION = 1;
            IF v_count > 0 THEN
                l_function_result.code := 10;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'seller_already_approved', p_lang => p_lang )|| ' Realestate ';
                RETURN l_function_result;
            END IF;

            UPDATE SELLERS_REQUESTS_DETAILS
               SET REALESTATE_CONFIRMATION = 1
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 20;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF;
        END IF;
        
        IF l_categor_id = l_portable_id  THEN 
            SELECT COUNT(1) INTO v_count FROM SELLERS_REQUESTS_DETAILS WHERE SELLER_ID = p_seller_id AND PORTABLE_CONFIRMATION = 1;
             IF v_count > 0 THEN
                 l_function_result.code := 30;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'seller_already_approved', p_lang => p_lang )|| ' Portable ';
                 RETURN l_function_result;
             END IF;

            UPDATE SELLERS_REQUESTS_DETAILS
               SET PORTABLE_CONFIRMATION = 1
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 40;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF;
        END IF;

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := 'Seller Confirmed successfully';
        RETURN l_function_result;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            l_function_result.code := 0;
            l_function_result.message := SQLERRM  || 'CONFIRM';
            RETURN l_function_result;
    END CONFIRM_REQUEST;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION DEACTIVATE_SELLER (
        p_seller_id       NUMBER,
        p_lang            VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result; --Record to hold result (.code and .message)
        v_count           NUMBER;
        l_admin_emp_id    NUMBER;
        l_admin_usr_id    NUMBER;
    BEGIN
        SAVEPOINT updatestart;

        --Check to make sure SELLER exists
        SELECT COUNT(1) INTO v_count FROM SELLERS
         WHERE ID = p_seller_ID;

        IF v_count = 0 THEN
            l_function_result.code := 10;
            l_function_result.message := 'Seller not found';
            RETURN l_function_result;
        END IF;

        --Check to make sure admin EMPLOYEE exists and grab ID
        SELECT ID into l_admin_emp_id FROM EMPLOYEES
         WHERE SELLER_ID = p_seller_id AND IS_ADMIN = 1;

        IF l_admin_emp_id IS NULL THEN
            l_function_result.code := 15;
            l_function_result.message := 'Admin Employee not found';
        END IF;

        --Update statements and checks follow
        UPDATE SELLERS
           SET IS_ACTIVE = 0,
               REQUEST_STATUS_ID = NULL
         WHERE ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 20;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE SELLER_CITIES
           SET IS_ACTIVE = 0
         WHERE SELLER_ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 30;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE SELLER_CATEGORIES
           SET IS_ACTIVE = 0
         WHERE SELLER_ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 40;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE SELLER_BANK_ACCOUNTS
           SET IS_ACTIVE = 0
         WHERE SELLER_ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 50;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE EMPLOYEES
           SET IS_ACTIVE = 0
         WHERE SELLER_ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 60;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE APP_USER_ROLES
           SET ROLE_ID = APP_USER_SECURITY.role_id_by_name (p_role_name => 'seller_inactive')
         WHERE USER_ID IN (SELECT USER_ID FROM EMPLOYEES WHERE ID = l_admin_emp_id);

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 70;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE APP_USERS
           SET ACTIVE_FLAG = 'N'
         WHERE ID IN (SELECT USER_ID FROM EMPLOYEES WHERE ID = l_admin_emp_id);

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 75;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := 'Seller and all associated records deactivated';
        RETURN l_function_result;
    END DEACTIVATE_SELLER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION REJECT_SELLER (
        p_emp_id          NUMBER,
        p_seller_id       NUMBER,
        p_reject_reason   VARCHAR2,
        p_seller_type     NUMBER,
        p_lang            VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result; --Record to hold result (.code and .message)
        v_count           NUMBER;
        l_admin_emp_id    NUMBER;
        l_admin_usr_id    NUMBER;
        l_result          NUMBER;
        l_message   VARCHAR2(500);
    BEGIN
        SAVEPOINT updatestart;

        --Check to make sure SELLER exists
        SELECT COUNT(1) INTO v_count FROM SELLERS
         WHERE ID = p_seller_ID;

        IF v_count = 0 THEN
            l_function_result.code := 10;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'seller_does_not_exist', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check to make sure seller status not rejected 
        SELECT COUNT(1) INTO v_count FROM SELLERS
         WHERE ID = p_seller_ID AND REQUEST_STATUS_ID = LOOKUPS_MNT.lookup_detail_id_by_code('rejected', 'request_status') ;

        IF v_count > 0 THEN
            l_function_result.code := 15;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'seller_already_rejected', p_lang => p_lang);
            RETURN l_function_result;
        END IF;


        --Update statements and checks follow
        UPDATE SELLERS
           SET REQUEST_STATUS_ID = LOOKUPS_MNT.lookup_detail_id_by_code('rejected', 'request_status'),
               PENDING_TYPE_ID = null,
               IS_ACTIVE = 0
         WHERE ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 20;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        UPDATE SELLERS_REQUESTS_DETAILS
           SET IS_EDITABLE = 0,
               IS_EDITABLE_PORTABLE_CONTRACT = 0,
               IS_EDITABLE_REALESTATE_CONTRACT = 0,
               IS_EDITABLE_CONTRACT = 0
         WHERE SELLER_ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 25;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        -- Update Reject Reason
        l_result := APP_OPERATIONS.create_notes(
            p_user_id         => p_emp_id,
            p_object_id       => p_seller_id,
            p_operation_type  => LOOKUPS_MNT.lookup_detail_id_by_code('request_reject', 'operation_type'),
            p_note            => p_reject_reason,
            p_message         => l_message
        );

        IF l_result <> 1 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 30;
            l_function_result.message := l_message;
            RETURN l_function_result;
        END IF;

         IF p_seller_type NOT IN (LOOKUPS_MNT.lookup_detail_id_by_code('governmental', 'seller_type'), LOOKUPS_MNT.lookup_detail_id_by_code('other', 'seller_type')) THEN
            --Check to make sure admin EMPLOYEE exists and grab ID
            SELECT ID into l_admin_emp_id FROM EMPLOYEES
             WHERE SELLER_ID = p_seller_id AND IS_ADMIN = 1;

            IF l_admin_emp_id IS NULL THEN
                l_function_result.code := 35;
                l_function_result.message := 'Admin Employee not found';
            END IF;
            
            UPDATE SELLER_CITIES
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 40;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE SELLER_CATEGORIES
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 45;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE SELLER_BANK_ACCOUNTS
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 50;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE EMPLOYEES
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 55;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE APP_USER_ROLES
               SET ROLE_ID = APP_USER_SECURITY.role_id_by_name (p_role_name => 'Seller_Inactive') --inactive_seller
             WHERE USER_ID IN (SELECT USER_ID FROM EMPLOYEES WHERE ID = l_admin_emp_id);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 60;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

            UPDATE APP_USERS
               SET ACTIVE_FLAG = 'N'
             WHERE ID IN (SELECT USER_ID FROM EMPLOYEES WHERE ID = l_admin_emp_id);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 65;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN l_function_result;
            END IF;
        END IF;

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := 'Seller and all associated records rejected';
        RETURN l_function_result;
    END REJECT_SELLER;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION UPDATE_SELLER_EMP (
        P_emp_id           NUMBER,
        p_seller_id        NUMBER,
        p_emp_name         VARCHAR2,
        p_national_type_id NUMBER,
        p_national_no      NUMBER,
        p_job              VARCHAR2,
        p_email            VARCHAR2,
        p_phone            NUMBER,
        p_lang            VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result; --Record to hold result (.code and .message)
        v_count     NUMBER;
        l_emp_id    NUMBER;
        l_message   VARCHAR2(500);
    BEGIN
     
     --================================================= VALIDATIONS ===========================================
        -- check if all the main requirments are filled
        IF p_emp_name IS NULL OR p_national_type_id IS NULL OR p_national_no IS NULL OR p_job IS NULL OR p_email IS NULL OR p_phone IS NULL  THEN
            l_function_result.code := 10;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check if email valid
        IF VALIDATIONS_PKG.VALIDATE_EMAIL(p_email) = false THEN
            l_function_result.code := 15;
            l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_email', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check if phone valid
        IF VALIDATIONS_PKG.VALIDATE_PHONE(p_phone) = false THEN
            l_function_result.code := 20;
            l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check if ID valid
        IF VALIDATIONS_PKG.VALIDATE_ID(p_national_no) = false THEN
            l_function_result.code := 25;
            l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_nid', p_lang => p_lang);
            RETURN l_function_result;
        END IF;
            
            UPDATE EMPLOYEES
               SET NAME_AR = p_emp_name,
                   NAME_EN = p_emp_name,
                   IDENTITY_TYPE_ID = p_national_type_id,
                   IDENTITY_NUMBER = p_national_no,
                   JOB = p_job,
                   PHONE = p_phone,
                   EMAIL = p_email
             WHERE SELLER_ID = p_seller_id
                   AND  ID = P_emp_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 40;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF;

            COMMIT;
            l_function_result.code := 1;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
            RETURN l_function_result;

    
    END UPDATE_SELLER_EMP; 

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================
    FUNCTION UPDATE_SELLER_INFO (
        -- seller table
        p_seller_id        NUMBER,
        P_seller_type_id   NUMBER,
        p_trade_name_ar    VARCHAR2,
        p_trade_name_en    VARCHAR2,
        p_tax_no           NUMBER,
        p_cr_no            NUMBER,
        p_country_id       NUMBER,
        -- seller details requests table
        p_applicant_type   NUMBER,
        p_applicant_name   VARCHAR2,
        p_email            VARCHAR2,
        p_phone            NUMBER,
        -- seller bank details
        p_bank_id          NUMBER,
        p_currency_id      NUMBER,
        p_account_no       VARCHAR2,
        p_iban_no          VARCHAR2,
        p_account_name     VARCHAR2,
        -- cities and categories
        p_cities           VARCHAR2,
        p_categories       VARCHAR2,
        p_lang             VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result; --Record to hold result (.code and .message)
        v_count     NUMBER;
        l_emp_id    NUMBER;
        l_message   VARCHAR2(500);
        l_city_id_array APEX_T_VARCHAR2;
        l_cat_id_array APEX_T_VARCHAR2;
    BEGIN
        IF P_seller_type_id IS NULL OR p_trade_name_ar IS NULL OR p_trade_name_en IS NULL  
           OR p_applicant_name IS NULL OR p_email IS NULL OR p_phone IS NULL THEN
            l_function_result.code := 5;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check if email valid
        IF VALIDATIONS_PKG.VALIDATE_EMAIL(p_email) = false THEN
            l_function_result.code := 10;
            l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_email', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        --check if phone valid
        IF VALIDATIONS_PKG.VALIDATE_PHONE(p_phone) = false THEN
            l_function_result.code := 15;
            l_function_result.message :=  SYSTEM_CONTROLS.get_translation(p_code => 'invalid_phone', p_lang => p_lang);
            RETURN l_function_result;
        END IF;

        IF P_seller_type_id NOT IN (LOOKUPS_MNT.lookup_detail_id_by_code('governmental', 'seller_type'),
                                 LOOKUPS_MNT.lookup_detail_id_by_code('other', 'seller_type')) THEN
            IF p_tax_no IS NULL OR p_cr_no IS NULL OR p_country_id IS NULL OR p_applicant_type IS NULL OR p_bank_id IS NULL OR p_currency_id IS NULL OR p_account_no IS NULL OR 
               p_iban_no IS NULL OR p_account_name IS NULL OR p_cities IS NULL OR p_categories IS NULL THEN
                l_function_result.code := 20;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

             --check if CR valid
            IF VALIDATIONS_PKG.VALIDATE_CR(p_cr_no) = false THEN
                l_function_result.code := 25;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_cr', p_lang => p_lang);
                RETURN l_function_result;
            END IF;

             --check if iban valid
            -- IF VALIDATIONS_PKG.VALIDATE_IBAN(p_iban_no) = false THEN
            --     l_function_result.code := 30;
            --     l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'invalid_iban', p_lang => p_lang);
            --     RETURN l_function_result;
            -- END IF;

            UPDATE SELLERS
               SET SELLER_TYPE_ID  = P_seller_type_id,
                   TRADE_NAME_AR   = p_trade_name_ar,
                   TRADE_NAME_EN   = p_trade_name_en,
                   NAME_AR         = p_trade_name_ar,
                   NAME_EN         = p_trade_name_en,
                   IDENTITY_NUMBER = p_cr_no,
                   TAX_NUMBER      = p_tax_no,
                   COUNTRY_ID      = p_country_id
             WHERE ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 35;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF; 
            -- UPDATE SELLERS_REQUESTS_DETAILS TABLE
            
            UPDATE SELLERS_REQUESTS_DETAILS
               SET APPLICANT_TYPE_ID      = p_applicant_type,
                   APPLICANT_NAME         = p_applicant_name,
                   APPLICANT_PHONE_NUMBER = p_phone,
                   APPLICANT_EMAIL        = p_email
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 40;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF; 
            
            -- UPDATE SELLER_BANK_ACCOUNTS TABLE
            UPDATE SELLER_BANK_ACCOUNTS
               SET BANK_ID      = p_bank_id,
                   CURRENCY_ID  = p_currency_id,
                   ACCOUNT_NO   = p_account_no,
                   ACCOUNT_NAME = p_account_name,
                   IBAN         = p_iban_no,
                   IS_OWNER     = 1,
                   IS_ACTIVE    = 0,
                   IS_VERIFIED  = 0 
             WHERE SELLER_ID    = p_seller_id;

            IF SQL%Rowcount = 0 THEN
               l_function_result.code := 45;
               l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
               ROLLBACK;
               RETURN l_function_result;
            END IF; 
            
            -- UPDATE SELLER_CITIES TABLE
            DELETE FROM SELLER_CITIES WHERE SELLER_ID = p_seller_id;
             l_city_id_array := APEX_STRING.SPLIT(p_cities, ',');
                
                FOR i IN 1..l_city_id_array.COUNT LOOP
                    INSERT INTO SELLER_CITIES (SELLER_ID, CITY_ID, IS_ACTIVE) 
                        VALUES (p_seller_id, TO_NUMBER(l_city_id_array(i)), 0);

                    IF SQL%Rowcount = 0 THEN
                        l_function_result.code := 50;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                        ROLLBACK;
                        RETURN l_function_result;
                    END IF; 
                END LOOP;
           
            -- UPDATE SELLER_CATEGORIES TABLE
            DELETE FROM SELLER_CATEGORIES WHERE SELLER_ID = p_seller_id;
             l_cat_id_array := APEX_STRING.SPLIT(p_categories, ',');
                
                FOR i IN 1..l_cat_id_array.COUNT LOOP
                    INSERT INTO SELLER_CATEGORIES (SELLER_ID, CATEGORY_ID, IS_ACTIVE) 
                        VALUES (p_seller_id, TO_NUMBER(l_cat_id_array(i)), 0);

                    IF SQL%Rowcount = 0 THEN
                        l_function_result.code := 55;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                        ROLLBACK;
                        RETURN l_function_result;
                    END IF; 
                END LOOP;
        ELSE
            -- UPDATE SELLERS TABLE
            UPDATE SELLERS
               SET SELLER_TYPE_ID  = P_seller_type_id,
                   TRADE_NAME_AR   = p_trade_name_ar,
                   TRADE_NAME_EN   = p_trade_name_en,
                   NAME_AR         = p_trade_name_ar,
                   NAME_EN         = p_trade_name_en,
                   IDENTITY_NUMBER = p_cr_no,
                   TAX_NUMBER      = p_tax_no,
                   COUNTRY_ID      = p_country_id
             WHERE ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 60;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF; 

            -- UPDATE SELLERS_REQUESTS_DETAILS TABLE
            UPDATE SELLERS_REQUESTS_DETAILS
               SET APPLICANT_NAME         = p_applicant_name,
                   APPLICANT_PHONE_NUMBER = p_phone,
                   APPLICANT_EMAIL        = p_email
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 65;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF; 
        END IF; 
        
        COMMIT;
          l_function_result.code := 1;
          l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
          RETURN l_function_result;
       
    END;   
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION category_id_by_employee_id (
        p_employee_id  IN NUMBER
    ) RETURN NUMBER IS
        v_count         NUMBER;
        dept_name       VARCHAR2(255);
        category_id     NUMBER;
    BEGIN 
        SELECT (SELECT NAME_AR FROM MOBASHER_DEPARTMENTS WHERE ID = DEPARTMENT_ID) 
          INTO dept_name
          FROM MOBASHER_EMPLOYEES WHERE ID = p_employee_id;

        IF SQL%ROWCOUNT = 0 THEN 
            RETURN -2;
            ROLLBACK;
        END IF;

        IF dept_name = 'عقارات' THEN
            SELECT ID INTO category_id FROM CATEGORIES WHERE CODE = 'real_estates';
        ELSIF dept_name = 'منقولات' THEN
            SELECT ID INTO category_id FROM CATEGORIES WHERE CODE = 'portable';
        ELSE
            category_id := -1;
        END IF;

        RETURN category_id;
    END category_id_by_employee_id;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION contract_id_by_seller_id (
        p_seller_id      IN NUMBER,
        p_contract_type  IN varchar2
    ) RETURN NUMBER IS
        v_count         NUMBER;
        contract_id     NUMBER;
    BEGIN 
        

        SELECT ID 
          INTO contract_id 
          FROM SELLERS_CONTRACTS WHERE SELLER_ID = p_seller_id AND CONTRACT_TYPE = p_contract_type AND CONTRACT_STATUS = 1 ;

        IF SQL%ROWCOUNT = 0 THEN 
            RETURN -2;
            ROLLBACK;
        END IF;

 

        RETURN contract_id;
    END contract_id_by_seller_id;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================  

    FUNCTION CONTRACT_DETAILS_TEMP (
        p_seller_id                NUMBER,
        p_request_details_id       NUMBER,
        p_dependinces_type         NUMBER,
        p_commission_type          NUMBER,
        p_auction_commission       NUMBER DEFAULT NULL,
        p_sold_product_commission  NUMBER DEFAULT NULL,
        p_percentage_commission    NUMBER DEFAULT NULL,
        p_type                     VARCHAR2,
        p_auction_type             NUMBER,
        p_limit_commission         NUMBER DEFAULT NULL,
        p_contract_id              NUMBER,
        p_lang                     VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result; 
        v_count     NUMBER;
    BEGIN
        IF p_dependinces_type IS NULL OR p_commission_type IS NULL OR p_auction_type IS NULL THEN
            l_function_result.code := 2;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN l_function_result;  
        END IF; 

        IF p_type = 'real_estate' THEN 
            IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('fixed', 'commission_type') THEN
                IF p_auction_commission IS NULL OR p_sold_product_commission IS NULL THEN
                   l_function_result.code := 5;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                   RETURN l_function_result;  
                END IF;   

                INSERT INTO SELLERS_REQUESTS_CONTRACTS_TEMP(SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, AUCTION_COMMISSION, SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID)
                    VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_auction_commission, p_sold_product_commission, p_type ,p_auction_type,p_limit_commission ,p_contract_id);

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 10;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            END IF; --AMOUNT

            IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('percentage', 'commission_type') THEN
                IF p_percentage_commission IS NULL THEN
                   l_function_result.code := 15;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                   RETURN l_function_result;
                END IF;

                INSERT INTO SELLERS_REQUESTS_CONTRACTS_TEMP(SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, AUCTION_COMMISSION, SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID)
                    VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_percentage_commission, p_percentage_commission, p_type,p_auction_type,p_limit_commission ,p_contract_id);

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 20;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
                
            END IF; --PERCENTAGE

            IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('free', 'commission_type') THEN
                INSERT INTO SELLERS_REQUESTS_CONTRACTS_TEMP(SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, TYPE,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID)
                    VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_type,p_auction_type,p_limit_commission ,p_contract_id);

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 30;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            END IF; --FREE
        END IF; -- REAL ESTATE

        IF p_type = 'portable' THEN
            IF p_commission_type IN (LOOKUPS_MNT.lookup_detail_id_by_code('fixed', 'commission_type'), LOOKUPS_MNT.lookup_detail_id_by_code('percentage', 'commission_type')) THEN
                IF p_percentage_commission IS NULL THEN
                   l_function_result.code := 35;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                   RETURN l_function_result;
                END IF;

                INSERT INTO SELLERS_REQUESTS_CONTRACTS_TEMP(SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,CONTRACT_ID)
                    VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_percentage_commission, p_type,p_auction_type ,p_contract_id);

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 40;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            END IF; --AMOUNT& PERCENTAGE

            IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('free', 'commission_type') THEN
                INSERT INTO SELLERS_REQUESTS_CONTRACTS_TEMP(SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, TYPE,AUCTION_TYPE,CONTRACT_ID)
                    VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_type,p_auction_type ,p_contract_id);

                IF SQL%Rowcount = 0 THEN
                    l_function_result.code := 50;
                    l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                    ROLLBACK;
                    RETURN l_function_result;
                END IF;
            END IF; --FREE
        END IF; -- PORTABLE

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN l_function_result;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            l_function_result.code := 0;
            l_function_result.message := SQLERRM;
            RETURN l_function_result;
       
    END; --FUNCTION
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================  

    FUNCTION SELLER_CONTRACT (
        p_seller_id               IN  NUMBER,
        p_request_details_id      IN  NUMBER DEFAULT NULL,
        p_contract_type           IN  VARCHAR2,
        p_contract_start_date     IN  date,
        p_contract_end_date       IN  date,
        p_date                    IN  date DEFAULT SYSDATE,
        p_contract_status         IN  NUMBER DEFAULT 1,
        p_lang                    IN  VARCHAR2 DEFAULT 'ar',
        p_contract_id             OUT NUMBER
        
    ) RETURN function_result IS
        l_function_result function_result; 
        v_count     NUMBER;
    BEGIN
        IF p_contract_start_date IS NULL OR p_contract_end_date IS NULL THEN
            
           l_function_result.code := 2;
           l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
           RETURN l_function_result;  
            
        END IF; 

        IF p_contract_start_date > p_contract_end_date  THEN 
            l_function_result.code := 2;
            l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN l_function_result;  
        END IF;


        SELECT COUNT(ID)  INTO v_count FROM SELLERS_CONTRACTS 
          WHERE seller_id = p_seller_id 
          AND contract_type = p_contract_type
          AND NVL(contract_status,0) = p_contract_status
        --   AND p_date BETWEEN p_contract_start_date AND p_contract_end_date 
          ;


        IF v_count = 0 THEN 
           INSERT INTO SELLERS_CONTRACTS (SELLER_ID,REQUEST_DETAILS_ID,CONTRACT_TYPE,CONTRACT_START_DATE,CONTRACT_END_DATE,CONTRACT_STATUS)
                    VALUES (p_seller_id,p_request_details_id,p_contract_type,p_contract_start_date,p_contract_end_date,p_contract_status )
                    RETURNING ID INTO p_contract_id;

            IF SQL%Rowcount = 0 THEN
                l_function_result.code := 10;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                ROLLBACK;
                RETURN l_function_result;
            END IF; 
        ELSE 
          SELECT ID  INTO p_contract_id FROM SELLERS_CONTRACTS 
            WHERE seller_id = p_seller_id 
            AND contract_type = p_contract_type
            AND NVL(contract_status,0) = p_contract_status
            -- AND p_date BETWEEN p_contract_start_date AND p_contract_end_date 
            ;
        END IF ;

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN l_function_result;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            l_function_result.code := 0;
            l_function_result.message := SQLERRM;
            RETURN l_function_result;
       
    END; --FUNCTION

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================  

FUNCTION ADD_CONTRACT_DETAILS (
        p_request_details_id       NUMBER,
        p_seller_id                NUMBER,
        p_dependinces_type         NUMBER,
        p_commission_type          NUMBER,
        p_auction_commission       NUMBER   DEFAULT NULL,
        p_sold_product_commission  NUMBER   DEFAULT NULL,
        p_percentage_commission    NUMBER   DEFAULT NULL,
        p_contract_notes           VARCHAR2 DEFAULT NULL,
        p_contract_scope           VARCHAR2 DEFAULT NULL,
        p_contract_obligation      VARCHAR2 DEFAULT NULL,
        p_portables_contract_url   VARCHAR2 DEFAULT NULL,
        p_real_estate_contract_url VARCHAR2 DEFAULT NULL,
        p_type                     VARCHAR2,
        p_auction_type             NUMBER,
        p_limit_commission         NUMBER DEFAULT NULL,
        p_contract_id              NUMBER,
        p_lang                     VARCHAR2 DEFAULT 'ar'
    ) RETURN function_result IS
        l_function_result function_result; 
        v_count                   NUMBER;
        -- v_real_estate_category_id NUMBER;
        -- v_portable_category_id    NUMBER;
        -- v_portable_id             NUMBER;
        -- v_reale_estate_id         NUMBER;
        v_portable_type           NUMBER;
        v_reale_estate_type       NUMBER;
    BEGIN
        SELECT COUNT(1)
          INTO v_count
          FROM SELLERS_REQUESTS_CONTRACTS_TEMP
         WHERE SELLER_ID = p_seller_id;

        SELECT COUNT(1)
          INTO v_portable_type
          FROM SELLERS_REQUESTS_CONTRACTS_TEMP 
         WHERE SELLER_ID = p_seller_id
               AND TYPE = 'portable';

        SELECT COUNT(1)
          INTO v_reale_estate_type
          FROM SELLERS_REQUESTS_CONTRACTS_TEMP 
         WHERE SELLER_ID = p_seller_id
               AND TYPE = 'real_estate';

        -- SELECT CATEGORY_ID
        --   INTO v_real_estate_category_id
        --   FROM SELLER_CATEGORIES
        --  WHERE SELLER_ID = p_seller_id
        --        AND CATEGORY_ID IN (SELECT ID FROM CATEGORIES WHERE CODE = 'real_estates');

        -- SELECT CATEGORY_ID
        --   INTO v_portable_category_id
        --   FROM SELLER_CATEGORIES
        --  WHERE SELLER_ID = p_seller_id
        --        AND CATEGORY_ID IN (SELECT ID FROM CATEGORIES WHERE CODE = 'portable');

        -- SELECT ID
        --   INTO v_reale_estate_id
        --   FROM CATEGORIES
        --   WHERE CODE = 'real_estates';

        -- SELECT ID
        --   INTO v_portable_id
        --   FROM CATEGORIES
        --   WHERE CODE = 'portable';
-- v_real_estate_category_id = v_reale_estate_id AND 
        IF v_count = 0 THEN
            IF p_dependinces_type IS NULL OR p_commission_type IS NULL OR p_auction_type IS NULL THEN 
                l_function_result.code := 2;
                l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                RETURN l_function_result;  
            END IF;

            IF p_type = 'real_estate' THEN

                IF p_real_estate_contract_url IS NULL THEN 
                   l_function_result.code := 2;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                   RETURN l_function_result;  
                END IF;

                IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('fixed', 'commission_type') THEN
                    IF p_auction_commission IS NULL OR p_sold_product_commission IS NULL THEN
                        l_function_result.code := 5;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                        RETURN l_function_result;  
                    END IF;   

                    DELETE FROM SELLERS_REQUESTS_CONTRACTS WHERE CONTRACT_ID = p_contract_id AND TYPE = 'real_estate';

                    INSERT INTO SELLERS_REQUESTS_CONTRACTS (SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, AUCTION_COMMISSION, SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID)
                        VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_auction_commission, p_sold_product_commission, p_type,p_auction_type ,p_limit_commission ,p_contract_id);

                    IF SQL%Rowcount = 0 THEN
                        l_function_result.code := 10;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                        ROLLBACK;
                        RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS_REQUESTS_DETAILS
                       SET IS_EDITABLE_REALESTATE_CONTRACT = 1,
                           IS_EDITABLE_CONTRACT = 1,
                           REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url
                     WHERE ID = p_request_details_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 15;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                   UPDATE SELLERS
                      SET PENDING_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('pending_contract', 'pending_type'),
                      REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url
                    WHERE ID = p_seller_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 20;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;        
                END IF; --AMOUNT

                IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('percentage', 'commission_type') THEN
                    IF p_percentage_commission IS NULL THEN
                       l_function_result.code := 25;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                       RETURN l_function_result;
                    END IF;

                    DELETE FROM SELLERS_REQUESTS_CONTRACTS WHERE CONTRACT_ID = p_contract_id AND TYPE = 'real_estate';

                    INSERT INTO SELLERS_REQUESTS_CONTRACTS (SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, AUCTION_COMMISSION, SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID)
                        VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_percentage_commission, p_percentage_commission, p_type,p_auction_type ,p_limit_commission ,p_contract_id);

                    IF SQL%Rowcount = 0 THEN
                        l_function_result.code := 30;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                        ROLLBACK;
                        RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS_REQUESTS_DETAILS
                       SET IS_EDITABLE_REALESTATE_CONTRACT = 1,
                           IS_EDITABLE_CONTRACT = 1,
                           REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url
                     WHERE ID = p_request_details_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 35;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS
                       SET PENDING_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('pending_contract', 'pending_type'),
                       REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url
                     WHERE ID = p_seller_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 40;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                END IF; --PERCENTAGE

                IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('free', 'commission_type') THEN

                    DELETE FROM SELLERS_REQUESTS_CONTRACTS WHERE CONTRACT_ID = p_contract_id AND TYPE = 'real_estate';

                    INSERT INTO SELLERS_REQUESTS_CONTRACTS (SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, TYPE ,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID)
                        VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_type,p_auction_type ,p_limit_commission ,p_contract_id);

                    IF SQL%Rowcount = 0 THEN
                        l_function_result.code := 50;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                        ROLLBACK;
                        RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS_REQUESTS_DETAILS
                       SET IS_EDITABLE_REALESTATE_CONTRACT = 1,
                           IS_EDITABLE_CONTRACT = 1,
                           REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url
                     WHERE ID = p_request_details_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 55;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS
                      SET PENDING_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('pending_contract', 'pending_type'),
                      REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url 
                    WHERE ID = p_seller_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 60;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                END IF; --FREE

            END IF; --real_estates
            
            IF p_type = 'portable' THEN
                IF p_contract_obligation IS NULL OR p_contract_scope IS NULL OR p_portables_contract_url IS NULL THEN 
                   l_function_result.code := 62;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                   RETURN l_function_result;  
                END IF;
            
                IF p_commission_type IN (LOOKUPS_MNT.lookup_detail_id_by_code('fixed', 'commission_type'), LOOKUPS_MNT.lookup_detail_id_by_code('percentage', 'commission_type')) THEN
                    IF p_percentage_commission IS NULL THEN
                        l_function_result.code := 65;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                        RETURN l_function_result;
                    END IF;

                    DELETE FROM SELLERS_REQUESTS_CONTRACTS WHERE CONTRACT_ID = p_contract_id AND TYPE = 'portable';

                    INSERT INTO SELLERS_REQUESTS_CONTRACTS (SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, SOLD_PRODUCT_COMMISSION, TYPE ,AUCTION_TYPE,CONTRACT_ID )
                        VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_percentage_commission, p_type ,p_auction_type,p_contract_id);

                    IF SQL%Rowcount = 0 THEN
                        l_function_result.code := 70;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                        ROLLBACK;
                        RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS_REQUESTS_DETAILS
                       SET IS_EDITABLE_PORTABLE_CONTRACT = 1,
                           IS_EDITABLE_CONTRACT          = 1,
                           PORTABLE_CONTRACT_URL         = p_portables_contract_url,
                           PORTABLE_CONTRACT_NOTES       = p_contract_notes,
                           PORTABLE_CONTRACT_SCOPE       = p_contract_scope,
                           PORTABLE_MOBASHER_OBLIGATIONS = p_contract_obligation
                     WHERE ID = p_request_details_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 75;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS
                      SET PENDING_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('pending_contract', 'pending_type'),
                      PORTABLE_CONTRACT_URL         = p_portables_contract_url
                    WHERE ID = p_seller_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 80;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;
                END IF; --AMOUNT& PERCENTAGE

                IF p_commission_type = LOOKUPS_MNT.lookup_detail_id_by_code('free', 'commission_type') THEN

                    DELETE FROM SELLERS_REQUESTS_CONTRACTS WHERE CONTRACT_ID = p_contract_id AND TYPE = 'portable';

                    INSERT INTO SELLERS_REQUESTS_CONTRACTS (SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, TYPE ,AUCTION_TYPE,CONTRACT_ID)
                        VALUES (p_seller_id,p_request_details_id, p_dependinces_type, p_commission_type, p_type,p_auction_type,p_contract_id);

                    IF SQL%Rowcount = 0 THEN
                        l_function_result.code := 90;
                        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                        ROLLBACK;
                        RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS_REQUESTS_DETAILS
                       SET IS_EDITABLE_PORTABLE_CONTRACT = 1,
                           IS_EDITABLE_CONTRACT          = 1,
                           PORTABLE_CONTRACT_URL         = p_portables_contract_url,
                           PORTABLE_CONTRACT_NOTES       = p_contract_notes,
                           PORTABLE_CONTRACT_SCOPE       = p_contract_scope,
                           PORTABLE_MOBASHER_OBLIGATIONS = p_contract_obligation
                     WHERE ID = p_request_details_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 95;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                    UPDATE SELLERS
                      SET PENDING_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('pending_contract', 'pending_type'),
                      PORTABLE_CONTRACT_URL         = p_portables_contract_url
                    WHERE ID = p_seller_id;

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 100;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;

                END IF; --FREE
            END IF; --portable

        END IF; -- COUNT =0

        IF v_count > 0 THEN
            IF v_reale_estate_type >= 1  AND p_type = 'real_estate' THEN
               IF p_real_estate_contract_url IS NULL THEN
                  l_function_result.code := 105;
                  l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                  RETURN l_function_result;  
               END IF;

               DELETE FROM SELLERS_REQUESTS_CONTRACTS WHERE CONTRACT_ID = p_contract_id AND TYPE = 'real_estate'; 
                
               FOR i IN (SELECT SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, AUCTION_COMMISSION, SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID
                        FROM SELLERS_REQUESTS_CONTRACTS_TEMP WHERE CONTRACT_ID = p_contract_id AND TYPE = 'real_estate' ORDER BY ID) LOOP
                
                    INSERT INTO SELLERS_REQUESTS_CONTRACTS ( SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE, AUCTION_COMMISSION,
                                                             SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,LIMIT_COMMISSION,CONTRACT_ID)
                        VALUES ( i.SELLER_ID,i.REQUEST_DETAILS_ID, i.DEPENDINCES_TYPE, i.COMMISSION_TYPE, i.AUCTION_COMMISSION, i.SOLD_PRODUCT_COMMISSION, i.TYPE,i.AUCTION_TYPE,i.LIMIT_COMMISSION,i.CONTRACT_ID);

                    IF SQL%Rowcount = 0 THEN 
                       l_function_result.code := 110;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;
                END LOOP;

                DELETE FROM SELLERS_REQUESTS_CONTRACTS_TEMP WHERE CONTRACT_ID = p_contract_id AND TYPE = 'real_estate';

                IF SQL%Rowcount = 0 THEN
                   l_function_result.code := 115;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                   ROLLBACK;
                   RETURN l_function_result;
                END IF;
                
                UPDATE SELLERS_REQUESTS_DETAILS
                   SET IS_EDITABLE_REALESTATE_CONTRACT = 1,
                       IS_EDITABLE_CONTRACT = 1,
                       REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url
                 WHERE ID = p_request_details_id;

                IF SQL%Rowcount = 0 THEN
                   l_function_result.code := 120;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                   ROLLBACK;
                   RETURN l_function_result;
                END IF;

                UPDATE SELLERS
                  SET PENDING_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('pending_contract', 'pending_type'),
                  REAL_ESTATE_CONTRACT_URL = p_real_estate_contract_url
                WHERE ID = p_seller_id;

                IF SQL%Rowcount = 0 THEN
                   l_function_result.code := 125;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                   ROLLBACK;
                   RETURN l_function_result;
                END IF;
            END IF;  --real_estates

            IF  v_portable_type >= 1  AND p_type = 'portable' THEN
               IF p_contract_obligation IS NULL OR p_contract_scope IS NULL OR p_portables_contract_url IS NULL THEN
                 l_function_result.code := 130;
                 l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                 RETURN l_function_result;
               END IF;

               DELETE FROM SELLERS_REQUESTS_CONTRACTS WHERE CONTRACT_ID = p_contract_id AND TYPE = 'portable';

               FOR i IN (SELECT SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE,COMMISSION_TYPE,SOLD_PRODUCT_COMMISSION, TYPE,AUCTION_TYPE,CONTRACT_ID FROM SELLERS_REQUESTS_CONTRACTS_TEMP
                        WHERE CONTRACT_ID = p_contract_id AND TYPE = 'portable' ORDER BY ID) LOOP

                    INSERT INTO SELLERS_REQUESTS_CONTRACTS ( SELLER_ID,REQUEST_DETAILS_ID, DEPENDINCES_TYPE, COMMISSION_TYPE,SOLD_PRODUCT_COMMISSION, TYPE ,AUCTION_TYPE,CONTRACT_ID)
                        VALUES ( i.SELLER_ID,i.REQUEST_DETAILS_ID, i.DEPENDINCES_TYPE, i.COMMISSION_TYPE,i.SOLD_PRODUCT_COMMISSION, i.TYPE,i.AUCTION_TYPE,i.CONTRACT_ID);

                    IF SQL%Rowcount = 0 THEN
                       l_function_result.code := 135;
                       l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                       ROLLBACK;
                       RETURN l_function_result;
                    END IF;
                END LOOP;

                DELETE FROM SELLERS_REQUESTS_CONTRACTS_TEMP WHERE CONTRACT_ID = p_contract_id AND TYPE = 'portable';

                IF SQL%Rowcount = 0 THEN
                   l_function_result.code := 140;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                   ROLLBACK;
                   RETURN l_function_result;
                END IF;

                UPDATE SELLERS_REQUESTS_DETAILS
                   SET IS_EDITABLE_PORTABLE_CONTRACT = 1,
                       IS_EDITABLE_CONTRACT          = 1,
                       PORTABLE_CONTRACT_URL         = p_portables_contract_url,
                       PORTABLE_CONTRACT_NOTES       = p_contract_notes,
                       PORTABLE_CONTRACT_SCOPE       = p_contract_scope,
                       PORTABLE_MOBASHER_OBLIGATIONS = p_contract_obligation
                 WHERE ID = p_request_details_id;

                IF SQL%Rowcount = 0 THEN
                   l_function_result.code := 145;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                   ROLLBACK;
                   RETURN l_function_result;
                END IF;

                UPDATE SELLERS
                  SET PENDING_TYPE_ID = LOOKUPS_MNT.lookup_detail_id_by_code('pending_contract', 'pending_type'),
                  PORTABLE_CONTRACT_URL         = p_portables_contract_url
                WHERE ID = p_seller_id;

                IF SQL%Rowcount = 0 THEN
                   l_function_result.code := 150;
                   l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                   ROLLBACK;
                   RETURN l_function_result;
                END IF;
            END IF; --portable

        END IF; -- COUNT >0

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN l_function_result;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            l_function_result.code := 0;
            l_function_result.message := SQLERRM;
            RETURN l_function_result;
    END; --FUNCTION
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================    

END "SELLERS_REQ";
/