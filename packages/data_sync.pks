
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."DATA_SYNC" as
    FUNCTION add_seller (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION add_employee (
        p_emp_id            IN VARCHAR2,
        p_emp_nid           IN VARCHAR2,
        p_emp_name          IN VARCHAR2,
        p_emp_phone         IN VARCHAR2,
        p_emp_email         IN VARCHAR2,
        p_emp_nid_type      IN VARCHAR2,
        P_emp_job           IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION vehicle_stuff (
        p_id                IN VARCHAR2,
        p_make_id           IN VARCHAR2,
        p_name_ar           IN VARCHAR2,
        p_name_en           IN VARCHAR2,
        p_type              IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION update_seller_employee (
        p_body        IN CLOB,
        p_type        IN VARCHAR2,
        p_employee_id IN VARCHAR2 DEFAULT null,
        p_lang        IN VARCHAR2 DEFAULT 'en',
        p_message    OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION update_seller (
        p_body      IN CLOB,
        p_type      IN VARCHAR2,
        -- p_seller_id IN VARCHAR2 DEFAULT null,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT VARCHAR2
    ) RETURN CLOB;

END DATA_SYNC;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."DATA_SYNC" as
    FUNCTION add_seller (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT VARCHAR2
    ) RETURN CLOB AS
        l_user_id           NUMBER;
        l_employee_id       NUMBER;
        l_seller_id         NUMBER;
        l_country_id        NUMBER;
        l_seller_nid        NUMBER;
        l_emp_nid           NUMBER;
        l_seller_nid_type   VARCHAR2(255);
        l_seller_name       VARCHAR2(255);
        l_seller_type       VARCHAR2(255);
        l_trade_name        VARCHAR2(255);
        l_seller_email      VARCHAR2(255);
        l_uniques_name      VARCHAR2(255);
        l_emp_name          VARCHAR2(255);
        l_emp_phone         VARCHAR2(255);
        l_emp_email         VARCHAR2(255);
        l_emp_job           VARCHAR2(255);
        l_emp_nid_type      VARCHAR2(255);
        l_categories        APEX_T_VARCHAR2;
        l_cities            APEX_T_VARCHAR2;
        l_categoryIDs       CLOB;
        l_cityIDs           CLOB;
    BEGIN
        -- VALIDATIOND
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;
        
        SELECT jt.id, jt.nidType, jt.sellerType, jt.country, jt.nationalID, jt.nameTrans, jt.tradeNameTrans, jt.defaultEmail, jt.sellerName, jt.categories, jt.cities, 
               jt.empNationalID, jt.empNIdType, jt.empName, jt.phone, jt.email, jt.job
          INTO l_seller_id, l_seller_nid_type, l_seller_type, l_country_id, l_seller_nid, l_seller_name, l_trade_name, l_seller_email, l_uniques_name, l_categoryIDs, 
               l_cityIDs, l_emp_nid, l_emp_nid_type, l_emp_name, l_emp_phone, l_emp_email, l_emp_job
          FROM
          JSON_TABLE (p_body,
             '$'
                COLUMNS (
                    id             number path '$.id',
                    nidType        varchar2(100)  path '$.nidType',
                    sellerType     varchar2(100)  path '$.sellerType',
                    country        number path '$.country',
                    nationalID     number path '$.nationalID',
                    nameTrans      varchar2(100)  path '$.nameTrans',
                    tradeNameTrans varchar2(100)  path '$.tradeNameTrans',
                    defaultEmail   varchar2(100)  path '$.defaultEmail',
                    sellerName     varchar2(100)  path '$.sellerName',
                    categories     varchar2(100) format json path '$.categories',
                    cities         varchar2(100) format json path '$.cities',
                    empNationalID  number path '$.empNationalID',
                    empNIdType    varchar2(100)  path '$.empNIdType',
                    empName       varchar2(100)  path '$.empName',
                    phone         varchar2(100)  path '$.phone',
                    email         varchar2(100)  path '$.email',
                    job           varchar2(100)  path '$.job'
                )
        ) AS jt;

        -- ADD THE SELLER
        INSERT INTO SELLERS (
            ID, COUNTRY_ID, NAME_AR, NAME_EN, TRADE_NAME_AR, TRADE_NAME_EN, UNIQUE_NAME,  SELLER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, DEFAULT_EMAIL, USER_TYPE_ID, IS_ACTIVE
            ) VALUES (
                l_seller_id, l_country_id, l_seller_name, l_seller_name, l_trade_name, l_trade_name, l_uniques_name, DECODE(upper(l_seller_type),'GOVERNMENTAL', 490,'COMMERCIAL', 491, 'ORGANIZER', 492, 'ONCE', 493, -1),
                DECODE(upper(l_seller_nid_type), 'CR', 33, 'NID', 11, 'RE', 12, -1), l_seller_nid, l_seller_email, 
                LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type'), 1
            );

        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in add the seller';
            RETURN '-3';
        END IF;

        -- ADD THE CATEGORIES
        l_categoryIDs := REPLACE(to_char(l_categoryIDs), '[');
        l_categoryIDs := REPLACE(l_categoryIDs, ']');
        l_categories := APEX_STRING.split ( p_str => l_categoryIDs,  p_sep => ',' );

        IF l_categories.count > 0 THEN
            FOR i IN 1 .. l_categories.count LOOP
                INSERT INTO SELLER_CATEGORIES (SELLER_ID, CATEGORY_ID, IS_ACTIVE)
                    VALUES (TO_NUMBER(l_seller_id), TO_NUMBER(l_categories(i)), 1);
                
                -- IF SQL%Rowcount = 0 THEN
                --     ROLLBACK;
                --     p_message := 'Error in add the seller category';
                --     RETURN '-4';
                -- END IF;
            END LOOP;
        END IF;

        -- -- ADD THE CITIES
        l_cityIDs := REPLACE(to_char(l_cityIDs), '[');
        l_cityIDs := REPLACE(l_cityIDs, ']');
        l_cities := APEX_STRING.split ( p_str => l_cityIDs,  p_sep => ',' );

        IF l_cities.count > 0 THEN
            FOR j IN 1 .. l_cities.count LOOP
                INSERT INTO SELLER_CITIES (SELLER_ID, CITY_ID, IS_ACTIVE)
                    VALUES (TO_NUMBER(l_seller_id), TO_NUMBER(l_cities(j)), 1);
                
                -- IF SQL%Rowcount = 0 THEN
                --     ROLLBACK;
                --     p_message := 'Error in add the seller city';
                --     RETURN '-5';
                -- END IF;
            END LOOP;
        END IF;

        -- ADD THE USER
        INSERT INTO APP_USERS (
            CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE
            ) VALUES (
                l_emp_nid, l_emp_name, l_emp_phone, l_emp_phone, l_emp_nid, APP_USER_SECURITY.get_hash(l_emp_nid, l_emp_nid), l_emp_email, SYSDATE, 'Y', 'N', 'Y', 1,
                LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type')
            ) RETURNING ID INTO l_user_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in add the user';
            RETURN '-6';
        END IF;

        -- ADD THE USER ROLE
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( l_user_id, APP_USER_SECURITY.role_id_by_name('seller'), 'Y', sysdate );
        
        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in add the role';
            RETURN '-7';
        END IF;

        -- ADD THE SELLER ACCOUNT ADMIN
        INSERT INTO EMPLOYEES (
            NAME_AR, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, PHONE, EMAIL,SELLER_ADMIN, IS_ADMIN,  IS_MANAGER, IS_ACTIVE, SELLER_ID, USER_ID
            ) VALUES (
                l_emp_name, LOOKUPS_MNT.lookup_detail_id_by_code('employee', 'user_type'), DECODE(upper(l_emp_nid_type), 'CR', 33, 'NID', 11, 'RE', 12, -1),
                l_emp_nid, l_emp_job, l_emp_phone, l_emp_email, l_seller_id, 1, 0, 1, l_seller_id, l_user_id
            ) RETURNING ID INTO l_employee_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in add the employee';
            RETURN '-8';
        END IF;
        
        UPDATE SELLERS
           SET ADMIN_ID = l_employee_id
         WHERE ID = l_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in update the seller';
            RETURN '-9';
        END IF;

        p_message := 'Success';
        RETURN '1';
    END add_seller;

--<AWS_SECRET>=========================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION add_employee (
        p_emp_id            IN VARCHAR2,
        p_emp_nid           IN VARCHAR2,
        p_emp_name          IN VARCHAR2,
        p_emp_phone         IN VARCHAR2,
        p_emp_email         IN VARCHAR2,
        p_emp_nid_type      IN VARCHAR2,
        P_emp_job           IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER AS
        l_user_type NUMBER;
        l_user_id   NUMBER;
    BEGIN
        -- VALIDATIOND
        IF p_emp_id IS NULL OR p_emp_name IS NULL OR p_emp_phone IS NULL OR p_emp_email IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        -- ADD THE USER
        INSERT INTO APP_USERS (
            CLIENT_ID_NO, PERSONAL_NAME, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS, CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE
            ) VALUES (
                p_emp_nid, p_emp_name, p_emp_phone, p_emp_phone, p_emp_nid, APP_USER_SECURITY.get_hash(p_emp_nid, p_emp_nid), p_emp_email, SYSDATE, 'Y', 'N', 'Y', 1,
                LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'administration', p_lookup_code => 'user_type')
            ) RETURNING ID, USER_TYPE INTO l_user_id, l_user_type;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in add the user';
            RETURN -4;
        END IF;

        -- ADD THE USER ROLE
        INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
            VALUES ( l_user_id, APP_USER_SECURITY.role_id_by_name('Mobasher Administration'), 'Y', sysdate );
        
        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in add the role';
            RETURN -5;
        END IF;

        -- ADD THE EMPLOYEE
        INSERT INTO MOBASHER_EMPLOYEES (
            ID, NAME_AR, NID_TYPE_ID, NID, JOB, PHONE, EMAIL, IS_ADMIN, IS_MANAGER, IS_ACTIVE, USER_ID, USER_TYPE_ID
            ) VALUES (
                p_emp_id, p_emp_name, DECODE(upper(p_emp_nid_type), 'CR', 33, 'NID', 11, 'RE', 12, -1),
                p_emp_nid, P_emp_job, p_emp_phone, p_emp_email, 0, 0, 1, l_user_id, l_user_type
            );

        IF SQL%Rowcount = 0 THEN
            ROLLBACK;
            p_message := 'Error in add the employee';
            RETURN -6;
        END IF;

        p_message := 'Success';
        RETURN 1;
    END add_employee;

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION vehicle_stuff (
        p_id                IN VARCHAR2,
        p_make_id           IN VARCHAR2,
        p_name_ar           IN VARCHAR2,
        p_name_en           IN VARCHAR2,
        p_type              IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message          OUT VARCHAR2
    ) RETURN NUMBER AS
    BEGIN
        -- VALIDATIOND
        IF p_id IS NULL OR p_name_ar IS NULL OR p_type IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        IF lower(p_type) = 'model' AND p_make_id IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang) || ' - the makeID is required';
            RETURN -3;
        END IF;

        IF lower(p_type) = 'make' THEN
            INSERT INTO VEHICLE_MAKE (ID, NAME_AR, NAME_EN) VALUES (p_id, p_name_ar, p_name_en);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in add the make';
                RETURN -4;
            END IF;
        ELSIF lower(p_type) = 'model' THEN
            INSERT INTO VEHICLE_MODEL (ID, NAME_AR, NAME_EN, VEHICLE_MAKE_ID) VALUES (p_id, p_name_ar, p_name_en, p_make_id);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in add the model';
                RETURN -5;
            END IF;
        ELSIF lower(p_type) = 'color' THEN
            INSERT INTO VEHICLE_EXTERNAL_COLOR (ID, NAME_AR, NAME_EN) VALUES (p_id, p_name_ar, p_name_en);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in add the exretnal color';
                RETURN -6;
            END IF;

            INSERT INTO VEHICLE_INNER_COLOR (ID, NAME_AR, NAME_EN) VALUES (p_id, p_name_ar, p_name_en);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in add the inner color';
                RETURN -7;
            END IF;
        END IF;

        p_message := 'Success';
        RETURN 1;
    END vehicle_stuff;

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION update_seller_employee (
        p_body        IN CLOB,
        p_type        IN VARCHAR2,
        p_employee_id IN VARCHAR2 DEFAULT null,
        p_lang        IN VARCHAR2 DEFAULT 'en',
        p_message    OUT VARCHAR2
    ) RETURN CLOB AS
        l_user_id           NUMBER;
        l_employee_id       NUMBER;
        l_seller_id         NUMBER;
        l_is_active         VARCHAR2(255);
        l_national_id_type  VARCHAR2(255);
        l_national_id       NUMBER;
        l_emp_name          VARCHAR2(255);
        l_job               VARCHAR2(255);
        l_job_no            VARCHAR2(255);
        l_country_call_key  VARCHAR2(255);
        l_phone             NUMBER;
        l_avatar            VARCHAR2(2000);
        l_is_admin          VARCHAR2(255);
        l_email             VARCHAR2(255);
    BEGIN
        IF p_type IS NULL THEN
            p_message := 'Missing type';
            RETURN '-2';
        END IF;
        IF  p_body IS NULL THEN
            p_message := 'Missing body';
            RETURN '-3';
        END IF;
        SELECT jt.sellerId, jt.active, jt.nIdType, jt.nationalID, jt.empName, jt.job, jt.jobNo, jt.countryCallKey, jt.phone, jt.avatar, jt.isAdmin, jt.email
          INTO l_seller_id, l_is_active, l_national_id_type, l_national_id, l_emp_name, l_job, l_job_no, l_country_call_key, l_phone, l_avatar, l_is_admin, l_email
              FROM
              JSON_TABLE ( p_body,
                 '$'
                    COLUMNS (
                        sellerId   number path '$.sellerId',
                        active     varchar2(255) path '$.active',
                        nIdType    varchar2(255) path '$.nIdType',
                        nationalID number path '$.nationalID',
                        empName    varchar2(255) path '$.empName',
                        job        varchar2(255) path '$.job',
                        jobNo      varchar2(255) path '$.jobNo',
                        countryCallKey      varchar2(255) path '$.countryCallKey',
                        phone      number path '$.phone',
                        avatar     varchar2(2000) path '$.avatar',
                        isAdmin    varchar2(255) path '$.isAdmin',
                        email      varchar2(255) path '$.email'
                    )
            ) AS jt;

        IF p_type = 'deactivateSellerEmployee' THEN
            SELECT USER_ID
              INTO l_user_id
              FROM EMPLOYEES
             WHERE SELLER_ID = l_seller_id
               AND IDENTITY_NUMBER = TO_NUMBER(p_employee_id);
            
            UPDATE EMPLOYEES
               SET IS_ACTIVE = 0
             WHERE USER_ID = l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in deactivate the user ||4';
                RETURN '-4';
            END IF;

            UPDATE APP_USERS
               SET ACTIVE_FLAG = 'N'
              WHERE ID = l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in deactivate the user ||5';
                RETURN '-5';
            END IF;

            UPDATE APP_USER_ROLES
               SET ENABLE_FLAG = 'N'
              WHERE USER_ID = l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in deactivate the role ||6';
                RETURN '-6';
            END IF;

        ELSIF p_type = 'activateSellerEmployee' THEN

            SELECT USER_ID
              INTO l_user_id
              FROM EMPLOYEES
             WHERE SELLER_ID = l_seller_id
               AND IDENTITY_NUMBER = p_employee_id;
            
            UPDATE EMPLOYEES
               SET IS_ACTIVE = 1
             WHERE USER_ID = l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in activate the employee ||7';
                RETURN '-7';
            END IF;

            UPDATE APP_USERS
               SET ACTIVE_FLAG = 'Y'
              WHERE ID = l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in activate the user ||8';
                RETURN '-8';
            END IF;

            UPDATE APP_USER_ROLES
               SET ENABLE_FLAG = 'Y'
              WHERE USER_ID = l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in activate the role ||9';
                RETURN '-9';
            END IF;

        ELSIF p_type = 'updateSellerEmployee' THEN

            SELECT USER_ID
              INTO l_user_id 
              FROM EMPLOYEES
             WHERE SELLER_ID       = l_seller_id
               AND IDENTITY_NUMBER = TO_NUMBER(p_employee_id);

            UPDATE EMPLOYEES
               SET NAME_AR          = l_emp_name,
                   IDENTITY_TYPE_ID = TO_NUMBER(DECODE(upper(l_national_id_type), 'CR', 33, 'NID', 11, 'RE', 12, -1)),
                   IDENTITY_NUMBER  = l_national_id,
                   JOB              = l_job,
                   JOB_NO           = l_job_no,
                   COUNTRY_CALL_KEY = l_country_call_key,
                   PHONE            = l_phone,
                   EMAIL            = l_email,
                   AVATAR_URL       = l_avatar --,
                --    IS_ADMIN         = DECODE (l_is_admin, 'TRUE', 1, 'FALSE', 0),
                --    IS_active        = DECODE (l_is_active, 'TRUE', 1, 'FALSE', 0)
             WHERE USER_ID = l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in update the employee ||10';
                RETURN '-10';
            END IF;

            UPDATE APP_USERS
               SET PERSONAL_NAME  = l_emp_name,
                   EMAIL_ADDRESS  = l_email,
                   WHATS_PHONE    = l_phone,
                   PHONE          = l_phone,
                   USER_PHOTO_URL = l_avatar
             WHERE ID = l_user_id;
            
            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in update the user ||11';
                RETURN '-11';
            END IF;

        ELSIF p_type = 'addSellerEmployee' THEN

            INSERT INTO APP_USERS (CLIENT_ID_NO, PERSONAl_name, PHONE, WHATS_PHONE, USER_NAME, PASSWORD, EMAIL_ADDRESS, START_DATE, ALLOW_CHANGE_PASS,
                                   CHANGE_PASS_NEXT_LOGIN, ACTIVE_FLAG, USER_LANGUAGE_ID, USER_TYPE)
                 VALUES ( l_national_id, l_emp_name, l_phone, l_phone, l_national_id, APP_USER_SECURITY.get_hash(l_national_id, l_national_id), l_email, SYSDATE,
                          'Y', 'N', 'Y', 1, LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'seller', p_lookup_code => 'user_type')
                ) RETURNING ID INTO l_user_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in add the user ||12';
                RETURN '-12';
            END IF;

            -- ADD THE USER ROLE
            INSERT INTO APP_USER_ROLES ( USER_ID, ROLE_ID, ENABLE_FLAG, START_DATE )
                VALUES ( l_user_id, APP_USER_SECURITY.role_id_by_name('seller'), 'Y', sysdate );
            
            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in add the role ||13';
                RETURN '-13';
            END IF;

            INSERT INTO EMPLOYEES ( NAME_AR, USER_TYPE_ID, IDENTITY_TYPE_ID, IDENTITY_NUMBER, JOB, COUNTRY_CALL_KEY, PHONE, EMAIL, IS_ADMIN, IS_MANAGER, IS_ACTIVE, SELLER_ID, USER_ID, AVATAR_URL)
                 VALUES ( l_emp_name,LOOKUPS_MNT.lookup_detail_id_by_code('employee', 'user_type'),DECODE(upper(l_national_id_type), 'CR', 33, 'NID', 11, 'RE', 12, -1), l_national_id,
                          l_job, l_country_call_key, l_phone, l_email, 0, 0, 1, l_seller_id ,l_user_id, l_avatar);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK;
                p_message := 'Error in add the employee ||14';
                RETURN '-14';
            END IF;
        END IF;
        -- p_message := 'SUCCESS';

        p_message := 'Success';
        RETURN '1';
  END update_seller_employee;

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

    FUNCTION update_seller (
        p_body      IN CLOB,
        p_type      IN VARCHAR2,
        -- p_seller_id IN VARCHAR2 DEFAULT null,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT VARCHAR2
    ) RETURN CLOB AS
        l_user_id                    NUMBER;
        l_check_exist                varchar2(255);
        l_seller_id                  NUMBER;
        l_country                    NUMBER;
        l_national_id                NUMBER;
        l_rating                     NUMBER;
        l_national_type              VARCHAR2(255);
        l_default_email              VARCHAR2(255);
        l_name_ar                    VARCHAR2(255);
        l_name_en                    VARCHAR2(255);
        l_trade_name_ar              VARCHAR2(255);
        l_trade_name_en              VARCHAR2(255);
        l_seller_name                VARCHAR2(255);
        l_address_ar                 VARCHAR2(4000);
        l_address_en                 VARCHAR2(4000);
        l_about_company_ar           VARCHAR2(4000);
        l_about_company_en           VARCHAR2(4000);
        l_general_terms_ar           VARCHAR2(4000);
        l_general_terms_en           VARCHAR2(4000);
        l_wall_paper                 VARCHAR2(4000);
        l_wall_paper_type            VARCHAR2(255); -- "IMAGE","MAP","NONE"
        l_map_url                    VARCHAR2(4000);
        l_facebook_url               VARCHAR2(4000);
        l_twitter_url                VARCHAR2(4000);
        l_instagram_url              VARCHAR2(4000);
        l_youtube_url                VARCHAR2(4000);
        l_is_infath_agent            varchar2(255);
        l_is_infath_agent_active     varchar2(255);
        l_sar_agent                  varchar2(255);
        l_is_sar_agent_active        varchar2(255);
        l_accounting_way             varchar2(255); -- "FIXED","VARIABLE"
        l_is_allow_use_sadaad        varchar2(255);
        l_val_license_no             varchar2(255);
        l_val_license_ex_date        varchar2(255);
        l_avatar_url                 varchar2(4000);
        l_our_partners               varchar2(255);
        l_our_partners_display_order varchar2(4000);
        l_categoryIDs                CLOB;
        l_cityIDs                    CLOB;
        l_categories                 APEX_T_VARCHAR2;
        l_cities                     APEX_T_VARCHAR2;
        BEGIN
            IF p_type IS NULL THEN
                p_message := 'Missing type';
                RETURN '-2';
            END IF;
            IF  p_body IS NULL THEN
                p_message := 'Missing body';
                RETURN '-3';
            END IF;
            SELECT jt.sellerID, jt.country, jt.nationalID, jt.rating, jt.nIdType, jt.defaultEmail, jt.namesAr, jt.nameEn, jt.tradeNamesAr, jt.tradeNameEn,
                   jt.sellerName, jt.addresAr, jt.addresEn, jt.aboutCompanysAr, jt.aboutCompanyEn, jt.generalTermAr, jt.generalTermsEn, jt.wallPaper, jt.wallPaperType,
                   jt.map, jt.facebookUrl, jt.twitterUrl, jt.instagramUrl, jt.youtubeUrl, jt.infathAgent, jt.infathAgentActive, jt.sarAgent, jt.sarAgentActive, jt.accountingWay,
                   jt.isAllowUseSadaad, jt.valLicenseNo, jt.valLicenseExDate, jt.avatar, jt.ourPartners, jt.ourPartnersDisplayOrder, jt.categories, jt.cities
              INTO l_seller_id, l_country, l_national_id, l_rating, l_national_type, l_default_email, l_name_ar, l_name_en, l_trade_name_ar, l_trade_name_en,
                   l_seller_name, l_address_ar, l_address_en, l_about_company_ar, l_about_company_en, l_general_terms_ar, l_general_terms_en, l_wall_paper, l_wall_paper_type,
                   l_map_url, l_facebook_url, l_twitter_url, l_instagram_url, l_youtube_url, l_is_infath_agent, l_is_infath_agent_active, l_sar_agent, l_is_sar_agent_active, l_accounting_way,
                   l_is_allow_use_sadaad, l_val_license_no, l_val_license_ex_date, l_avatar_url, l_our_partners, l_our_partners_display_order, l_categoryIDs, l_cityIDs
                  FROM
                  JSON_TABLE ( p_body,
                     '$'
                        COLUMNS (
                            sellerID                number path '$.sellerID',
                            country                 number path '$.country',
                            nationalID              number path '$.nationalID',
                            rating                  number path '$.rating',
                            nIdType                 varchar2 (255)  path '$.nIdType',
                            defaultEmail            varchar2 (255)  path '$.defaultEmail',
                            namesAr                 varchar2 (255)  path '$.namesAr',
                            nameEn                  varchar2 (255)  path '$.nameEn',
                            tradeNamesAr            varchar2 (255)  path '$.tradeNamesAr',
                            tradeNameEn             varchar2 (255)  path '$.tradeNameEn',
                            sellerName              varchar2 (255)  path '$.sellerName',
                            addresAr                varchar2 (2000) path '$.addresAr',
                            addresEn                varchar2 (2000) path '$.addresEn',
                            aboutCompanysAr         varchar2 (2000) path '$.aboutCompanysAr',
                            aboutCompanyEn          varchar2 (2000) path '$.aboutCompanyEn',
                            generalTermAr           varchar2 (2000) path '$.generalTermAr',
                            generalTermsEn          varchar2 (2000) path '$.generalTermsEn',
                            wallPaper               varchar2 (2000) path '$.wallPaper',
                            wallPaperType           varchar2 (255)  path '$.wallPaperType',
                            map                     varchar2 (2000) path '$.map',
                            facebookUrl             varchar2 (2000) path '$.facebookUrl',
                            twitterUrl              varchar2 (2000) path '$.twitterUrl',
                            instagramUrl            varchar2 (2000) path '$.instagramUrl',
                            youtubeUrl              varchar2 (2000) path '$.youtubeUrl',
                            infathAgent             varchar2 (255)  path '$.infathAgent',
                            infathAgentActive       varchar2 (255)  path '$.infathAgentActive',
                            sarAgent                varchar2 (255)  path '$.sarAgent',
                            sarAgentActive          varchar2 (255)  path '$.sarAgentActive',
                            accountingWay           varchar2 (255)  path '$.accountingWay',
                            isAllowUseSadaad        varchar2 (255)  path '$.isAllowUseSadaad',
                            valLicenseNo            varchar2 (255)  path '$.valLicenseNo',
                            valLicenseExDate        varchar2 (255)  path '$.valLicenseExDate',
                            avatar                  varchar2 (255)  path '$.avatar',
                            ourPartners             varchar2 (255)  path '$.ourPartners',
                            ourPartnersDisplayOrder varchar2 (2000) path '$.ourPartnersDisplayOrder',
                            categories              varchar2 (1000) format json path '$.categories',
                            cities                  varchar2 (1000) format json path '$.cities'
                        )
                ) AS jt;

            IF p_type = 'deactivateSeller' THEN
                UPDATE SELLERS
                   SET IS_ACTIVE = 0
                 WHERE ID = l_seller_id;
                 
                IF SQL%Rowcount = 0 THEN
                    ROLLBACK;
                    p_message := 'Error in deactivate the seller ||4';
                    RETURN '-4';
                END IF;
                UPDATE SELLER_CATEGORIES
                SET IS_ACTIVE = 0
                WHERE SELLER_ID = l_seller_id;

                IF SQL%Rowcount = 0 THEN
                    ROLLBACK;
                    p_message := 'Error in deactivate the category ||15';
                    RETURN '-15';
                END IF;

                UPDATE SELLER_CITIES
                SET IS_ACTIVE = 0
                WHERE SELLER_ID = l_seller_id;

                IF SQL%Rowcount = 0 THEN
                    ROLLBACK;
                    p_message := 'Error in deactivate the cities ||16';
                    RETURN '-16';
                END IF;
                FOR i IN (SELECT USER_ID FROM EMPLOYEES WHERE SELLER_ID = l_seller_id) LOOP

                    UPDATE EMPLOYEES
                       SET IS_ACTIVE = 0
                     WHERE USER_ID = i.USER_ID;

                    IF SQL%Rowcount = 0 THEN
                        ROLLBACK;
                        p_message := 'Error in deactivate the employee ||5';
                        RETURN '-5';
                    END IF;

                    UPDATE APP_USERS
                       SET ACTIVE_FLAG = 'N'
                     WHERE ID = i.USER_ID;

                    UPDATE APP_USER_ROLES
                       SET ENABLE_FLAG = 'N'
                     WHERE USER_ID = i.USER_ID;

                    IF SQL%Rowcount = 0 THEN
                        ROLLBACK;
                        p_message := 'Error in deactivate the user ||6';
                        RETURN '-6';
                    END IF;

                    IF SQL%Rowcount = 0 THEN
                        ROLLBACK;
                        p_message := 'Error in deactivate the user ||7';
                        RETURN '-7';
                    END IF;
                END LOOP;

            ELSIF p_type = 'activateSeller' THEN
                UPDATE SELLERS
                   SET IS_ACTIVE = 1
                 WHERE ID = l_seller_id;
                 
                IF SQL%Rowcount = 0 THEN
                    ROLLBACK;
                    p_message := 'Error in activate the seller ||8';
                    RETURN '-8';
                END IF;
                UPDATE SELLER_CATEGORIES
                SET IS_ACTIVE = 1
                WHERE SELLER_ID = l_seller_id;

                IF SQL%Rowcount = 0 THEN
                    ROLLBACK;
                    p_message := 'Error in deactivate the category ||16';
                    RETURN '-16';
                END IF;

                UPDATE SELLER_CITIES
                SET IS_ACTIVE = 1
                WHERE SELLER_ID = l_seller_id;

                IF SQL%Rowcount = 0 THEN
                    ROLLBACK;
                    p_message := 'Error in deactivate the cities ||18';
                    RETURN '-18';
                END IF;
                FOR i IN (SELECT USER_ID FROM EMPLOYEES WHERE SELLER_ID = l_seller_id) LOOP

                    UPDATE EMPLOYEES
                       SET IS_ACTIVE = 1
                     WHERE USER_ID = i.USER_ID;

                    IF SQL%Rowcount = 0 THEN
                        ROLLBACK;
                        p_message := 'Error in activate the employee ||9';
                        RETURN '-9';
                    END IF;

                    UPDATE APP_USERS
                       SET ACTIVE_FLAG = 'Y'
                     WHERE ID = i.USER_ID;

                    UPDATE APP_USER_ROLES
                       SET ENABLE_FLAG = 'Y'
                     WHERE USER_ID = i.USER_ID;

                    IF SQL%Rowcount = 0 THEN
                        ROLLBACK;
                        p_message := 'Error in activate the user ||10';
                        RETURN '-10';
                    END IF;

                    IF SQL%Rowcount = 0 THEN
                        ROLLBACK;
                        p_message := 'Error in activate the user ||11';
                        RETURN '-11';
                    END IF;
                END LOOP;
            ELSIF p_type = 'updateSeller' THEN

                UPDATE sellers
                SET COUNTRY_ID              = l_country,
                    IDENTITY_NUMBER         = l_national_id,
                    RATING                  = l_rating,
                    IDENTITY_TYPE_ID        = TO_NUMBER (DECODE (upper(l_national_type), 'CR', 33, 'NID', 11, 'RE', 12, -1)),
                    DEFAULT_EMAIL           = l_default_email,
                    NAME_AR                 = l_name_ar,
                    NAME_EN                 = l_name_en,
                    TRADE_NAME_AR           = l_trade_name_ar,
                    TRADE_NAME_EN           = l_trade_name_en,
                    UNIQUE_NAME             = l_seller_name,
                    ADDRESS_AR              = l_address_ar,
                    ADDRESS_EN              = l_address_en,
                    ABOUT_COMPANY_AR        = l_about_company_ar,
                    ABOUT_COMPANY_EN        = l_about_company_en,
                    GENERAL_TERMS_AR        = l_general_terms_ar,
                    GENERAL_TERMS_EN        = l_general_terms_en,
                    WALL_PAPER_URL          = l_wall_paper,
                    WALL_PAPER_TYPE_ID      = DECODE (UPPER(l_wall_paper_type), 'IMAGE', 169, 'MAP', 170,'NONE', 171, -1),
                    MAP_URL                 = l_map_url,
                    FACEBOOK_URL            = l_facebook_url,
                    TWITTER_URL             = l_twitter_url,
                    INSTAGRAM_URL           = l_instagram_url,
                    YOUTUBE_URL             = l_youtube_url,
                    IS_INFATH_AGENT         = DECODE (UPPER(l_is_infath_agent), 'TRUE', 1, 'FALSE', 0, -1),
                    IS_INFATH_AGENT_ACTIVE  = DECODE (UPPER(l_is_infath_agent_active), 'TRUE', 1, 'FALSE', 0, -1),
                    IS_SAR_AGENT            = DECODE (UPPER(l_sar_agent), 'TRUE', 1, 'FALSE', 0, -1),
                    IS_SAR_AGENT_ACTIVE     = DECODE (UPPER(l_is_sar_agent_active), 'TRUE', 1, 'FALSE', 0, -1),
                    ACCOUNTING_WAY          = DECODE (UPPER(l_accounting_way), 'FIXED', 494, 'VARIABLE', 495, -1 ),
                    IS_ALLOW_USED_SADAAD    = DECODE (UPPER(l_is_allow_use_sadaad), 'TRUE', 1, 'FALSE', 0, -1),
                    VAL_LICENSE_NUMBER      = l_val_license_no,
                    VAL_LICENSE_EXPIRE_DATE = To_date(l_val_license_ex_date, 'MM/DD/YYYY'),
                    AVATAR_URL              = l_avatar_url
                WHERE ID = l_seller_id;

                IF SQL%Rowcount = 0 THEN
                    ROLLBACK;
                    p_message := 'Error in update the seller ||12';
                    RETURN '-12';
                END IF;

                -- UPDATE THE CATEGORIES
                l_categoryIDs := REPLACE(to_char(l_categoryIDs), '[');
                l_categoryIDs := REPLACE(l_categoryIDs, ']');
                l_categories := APEX_STRING.split ( p_str => l_categoryIDs,  p_sep => ',' );

                IF l_categories.count > 0 THEN
                    FOR i IN 1 .. l_categories.count LOOP
                        SELECT COUNT(ID) INTO l_check_exist FROM SELLER_CATEGORIES WHERE SELLER_ID = l_seller_id AND CATEGORY_ID = TO_NUMBER(l_categories(i));
                        IF l_check_exist = 0 THEN
                            INSERT INTO SELLER_CATEGORIES (SELLER_ID, CATEGORY_ID, IS_ACTIVE)
                                VALUES (TO_NUMBER(l_seller_id), TO_NUMBER(l_categories(i)), 1);
                            IF SQL%Rowcount = 0 THEN
                                ROLLBACK;
                                p_message := 'Error in update category ||14';
                                RETURN '-14';
                            END IF;
                        END IF;
                    END LOOP;
                END IF;

                -- UPDATE THE CITIES
                l_cityIDs := REPLACE(to_char(l_cityIDs), '[');
                l_cityIDs := REPLACE(l_cityIDs, ']');
                l_cities := APEX_STRING.split ( p_str => l_cityIDs,  p_sep => ',' );

                IF l_cities.count > 0 THEN
                    FOR j IN 1 .. l_cities.count LOOP
                        SELECT COUNT(ID) INTO l_check_exist FROM SELLER_CITIES WHERE SELLER_ID = l_seller_id AND CITY_ID = TO_NUMBER(l_cities(j));
                        IF l_check_exist = 0 THEN
                            INSERT INTO SELLER_CITIES (SELLER_ID, CITY_ID, IS_ACTIVE)
                                VALUES (TO_NUMBER(l_seller_id), TO_NUMBER(l_cities(j)), 1);
                            
                            IF SQL%Rowcount = 0 THEN
                                ROLLBACK;
                                p_message := 'Error in update city ||14';
                                RETURN '-14';
                            END IF;
                        END IF;
                    END LOOP;
                END IF;
            END IF;

        p_message := 'Success';
        RETURN '1';
  END update_seller;

--=================================================================================================
--===================================== END OF FUNCTION ===========================================
--=================================================================================================

END DATA_SYNC;
/