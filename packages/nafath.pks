
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."NAFATH" AS

    FUNCTION authorization_key RETURN VARCHAR2;

    FUNCTION iam_request (
        p_client_id     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_random_no    OUT VARCHAR2,
        p_trans_id     OUT VARCHAR2,
        p_trace        OUT VARCHAR2,
        p_status       OUT VARCHAR2,
        p_message      OUT VARCHAR2
    ) RETURN NUMBER;

    PROCEDURE ins_callback (
        p_body    IN VARCHAR2,
        p_id     OUT NUMBER  
    );
    
    FUNCTION set_callback (
        p_callback_id  IN NUMBER
    ) RETURN NUMBER;
    
END NAFATH;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."NAFATH" AS

    FUNCTION authorization_key
    RETURN VARCHAR2 IS
        v_is_lab         NUMBER;
        v_authorization  VARCHAR2(255); 
    BEGIN
        v_is_lab := 0;

        SELECT DECODE(v_is_lab, 1, TEST_API_KEY, API_KEY) AS BASE_URL
          INTO v_authorization
          FROM ENVIRONMENT_SETTING
         WHERE UPPER(PROVIDER) = 'NAFATH';

        RETURN v_authorization;
    END authorization_key; 
  
--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION iam_request (
        p_client_id     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_random_no    OUT VARCHAR2,
        p_trans_id     OUT VARCHAR2,
        p_trace        OUT VARCHAR2,
        p_status       OUT VARCHAR2,
        p_message      OUT VARCHAR2
    ) RETURN NUMBER IS
        iam_seq_id          NUMBER;
        v_url               VARCHAR2(500);
        v_base_url          VARCHAR2(500);
        v_api_key           VARCHAR2(500);
        v_result            NUMBER;
        v_iam_error         VARCHAR2(500);
        v_body              VARCHAR2(32000);
        v_is_lab            NUMBER;
        v_client_id_no      VARCHAR2(255);
        l_clob              CLOB;
    BEGIN
        IF p_client_id IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        -- SELECT DECODE(v_is_lab, 1, 1000045664, CLIENT_ID_NO)
        --   INTO v_client_id_no
        --   FROM APP_USERS
        --  WHERE ID = p_client_id;

        v_client_id_no := p_client_id;


        v_is_lab := 0;
        BEGIN 
            SELECT DECODE(v_is_lab, 1, TEST_BASE_URL, BASE_URL) AS BASE_URL, authorization_key
              INTO v_base_url, v_api_key
              FROM ENVIRONMENT_SETTING
             WHERE UPPER(PROVIDER) = 'NAFATH';
        EXCEPTION
            WHEN no_data_found THEN     
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -3;
        END;

        INSERT INTO IAM_LOGS ( CLIENT_ID, CREATED_DATE, CLIENT_ID_NO, URL )
            VALUES ( p_client_id, GET_CURRENT_DATE, v_client_id_no, v_base_url || '/nafath/api/v1/client/authorize/' )
        RETURNING ID INTO iam_seq_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -4;
        END IF;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'Authorization';
        apex_web_service.g_request_headers(2).value := 'apikey ' || v_api_key;

        v_body := '{
                    "id": "'    || v_client_id_no ||'",
                    "action": "SpRequest",
                    "service": "DigitalServiceEnrollmentWithoutBio"
                }';

        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_base_url || '/nafath/api/v1/client/authorize/',
                    p_http_method => 'POST',
                    p_body        => v_body);

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'NAFATH.iam_request', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := 'Nafath Request Error! Status: ' || apex_web_service.g_status_code;
            RETURN -100003;
        END IF;

        APEX_JSON.parse(l_clob);
        v_iam_error := apex_json.get_varchar2('message');
        
        IF v_iam_error IS NULL THEN
            UPDATE IAM_LOGS
               SET TRANS_ID = apex_json.get_varchar2('transId'),
                   RANDOM   = apex_json.get_varchar2('random'),
                   STATUS   = apex_json.get_varchar2('status'),
                   CODE     = apex_web_service.g_status_code,
                   MESSAGE  = SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang),
                   RESPONSE = SUBSTR(l_clob, 1, 4000),
                   REQUEST_BODY = v_body
             WHERE ID = iam_seq_id;

            p_trans_id  := apex_json.get_varchar2('transId');
            p_random_no := apex_json.get_varchar2('random');
            p_message   := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
            RETURN 1;
        ELSE
            UPDATE IAM_LOGS
               SET TRACE_ID = apex_json.get_varchar2('trace'),
                   STATUS   = apex_json.get_varchar2('status'),
                   CODE     = apex_web_service.g_status_code,
                   MESSAGE  = apex_json.get_varchar2('message'),
                   RESPONSE = SUBSTR(l_clob, 1, 4000),
                   REQUEST_BODY = v_body
             WHERE ID = iam_seq_id;

            p_status  := apex_json.get_varchar2('status');
            p_trace   := apex_json.get_varchar2('trace');
            p_message := apex_json.get_varchar2('message');
            RETURN -5;
        END IF;

        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        RETURN -6;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN -1;
    END iam_request;  
  
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    PROCEDURE ins_callback (
        p_body    IN VARCHAR2,
        p_id     OUT NUMBER  
    ) IS
        v_id   NUMBER;
    BEGIN
        INSERT INTO IAM_CALLBACK (CALLBACK_BODY, STATUS)
            VALUES (p_body, 0)
        RETURNING ID INTO v_id;
        COMMIT;

        p_id := v_id;

    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END ins_callback;
    
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION set_callback (
        p_callback_id  IN NUMBER
    ) RETURN NUMBER IS
        v_body                     VARCHAR2(32000);
        v_respone                  VARCHAR2(32000);
        v_id_token                 VARCHAR2(31000);
        v_parse_id_token           VARCHAR2(31000);
        l_token                    apex_jwt.t_token;
        l_keys                     apex_t_varchar2;
        v_iam_id                   VARCHAR2(200);
        v_iam_ar_full_name         VARCHAR2(200);
        v_iam_ar_first_name        VARCHAR2(200);
        v_iam_ar_father_name       VARCHAR2(200);
        v_iam_ar_grand_father_name VARCHAR2(200);
        v_iam_ar_family_name       VARCHAR2(200);
        v_iam_en_full_name         VARCHAR2(200);
        v_iam_en_first_name        VARCHAR2(200);
        v_iam_en_father_name       VARCHAR2(200);
        v_iam_en_grand_father_name VARCHAR2(200);
        v_iam_en_family_name       VARCHAR2(200);
        v_iam_ar_two_names         VARCHAR2(200);
        v_iam_en_two_names         VARCHAR2(200);
        v_iam_gender               VARCHAR2(200);
        v_iam_nationality_code     VARCHAR2(200);
        v_iam_ar_nationality       VARCHAR2(200);
        v_iam_en_nationality       VARCHAR2(200);
        v_iam_id_issue_date_g      VARCHAR2(200);
        v_iam_id_issue_date_h      VARCHAR2(200);
        v_iam_id_expire_date_g     VARCHAR2(200);
        v_iam_id_expire_date_h     VARCHAR2(200);
        v_iam_id_version           VARCHAR2(200);
        v_iam_hijri_dob            VARCHAR2(200);
        v_iam_dob                  VARCHAR2(200);
        v_iam_language            VARCHAR2(200);
        v_iam_ar_card_issue_place VARCHAR2(200);
        v_iam_en_card_issue_place VARCHAR2(200);
        v_count                    NUMBER;
        v_base_url                 VARCHAR2(500);
        v_test_base_url            VARCHAR2(500);
        v_result                   NUMBER;
        v_iam_status               VARCHAR2(500);
        v_callback_url             VARCHAR2(500);
        v_user_id                  NUMBER;
        v_id                       NUMBER;
        v_platform                 VARCHAR2(500);
        v_status                   VARCHAR2(500);
    BEGIN
        IF p_callback_id IS NULL THEN 
            RETURN -2;
        END IF;

        SELECT CALLBACK_BODY, STATUS 
          INTO v_body, v_status
          FROM IAM_CALLBACK
         WHERE ID = p_callback_id;

        IF v_status = 1 THEN
            RETURN 1;
        END IF;

        apex_json.parse(v_body);
        v_iam_status := apex_json.get_varchar2('status');
        v_respone    := apex_json.get_varchar2('response');
        l_token      := apex_jwt.decode(v_respone);
        v_iam_id     := apex_json.get_varchar2('PersonId');
        
        apex_json.parse(l_token.payload);
        l_keys := apex_json.get_members('.');

        IF v_iam_status IS NULL OR v_iam_status = 'REJECTED' THEN
            UPDATE IAM_CALLBACK
               SET STATUS     = -1,
                   IAM_STATUS = apex_json.get_varchar2('status')
             WHERE ID = p_callback_id;

            UPDATE IAM_LOGS
               SET STATUS = -1
             WHERE CLIENT_ID_NO = v_iam_id;
            RETURN -3;
        ELSE
            v_iam_id                    := apex_json.get_varchar2('id');
            v_iam_id_version            := apex_json.get_varchar2('idVersion');
            v_iam_ar_first_name         := apex_json.get_varchar2('arFirst');
            v_iam_ar_father_name        := apex_json.get_varchar2('arFather');
            v_iam_ar_grand_father_name  := apex_json.get_varchar2('arGrand');
            v_iam_ar_family_name        := apex_json.get_varchar2('arFamily');
            v_iam_en_first_name         := apex_json.get_varchar2('enFirst');
            v_iam_en_father_name        := apex_json.get_varchar2('enFather');
            v_iam_en_grand_father_name  := apex_json.get_varchar2('enGrand');
            v_iam_en_family_name        := apex_json.get_varchar2('enFamily');
            v_iam_ar_two_names          := apex_json.get_varchar2('arTwoNames');
            v_iam_en_two_names          := apex_json.get_varchar2('enTwoNames');
            v_iam_ar_full_name          := apex_json.get_varchar2('arFullName');
            v_iam_en_full_name          := apex_json.get_varchar2('enFullName');
            v_iam_gender                := apex_json.get_varchar2('gender');
            v_iam_id_issue_date_g       := apex_json.get_varchar2('IdIssueDateG');
            v_iam_id_issue_date_h       := apex_json.get_varchar2('IdIssueDateH');
            v_iam_id_expire_date_g      := apex_json.get_varchar2('idExpiryDateG');
            v_iam_id_expire_date_h      := apex_json.get_varchar2('idExpiryDateH');
            v_iam_nationality_code      := apex_json.get_varchar2('nationality');
            v_iam_language              := apex_json.get_varchar2('language');
            v_iam_ar_nationality        := apex_json.get_varchar2('arNationality');
            v_iam_en_nationality        := apex_json.get_varchar2('enNationality');
            v_iam_dob                   := apex_json.get_varchar2('dobG');
            v_iam_hijri_dob             := apex_json.get_varchar2('dobH');
            v_iam_ar_card_issue_place   := apex_json.get_varchar2('arCardIssuePlace');
            v_iam_en_card_issue_place   := apex_json.get_varchar2('enCardIssuePlace');

            UPDATE IAM_CALLBACK
               SET STATUS     = 1,
                   IAM_STATUS = apex_json.get_varchar2('status')
             WHERE ID = p_callback_id;

            UPDATE IAM_LOGS
               SET STATUS = 1
             WHERE CLIENT_ID_NO = v_iam_id;

            IF SQL%ROWCOUNT > 0 THEN
                SELECT MAX(client_id)
                 INTO v_user_id
                 FROM IAM_LOGS
                WHERE CLIENT_ID_NO = v_iam_id;

                UPDATE APP_USERS
                  SET  iam_id                    = v_iam_id,
                       iam_ar_full_name          = v_iam_ar_full_name,
                       iam_ar_first_name         = v_iam_ar_first_name,
                       iam_ar_father_name        = v_iam_ar_father_name,
                       iam_ar_grand_father_name  = v_iam_ar_grand_father_name,
                       iam_ar_family_name        = v_iam_ar_family_name,
                       iam_en_full_name          = v_iam_en_full_name,
                       iam_en_first_name         = v_iam_en_first_name,
                       iam_en_father_name        = v_iam_en_father_name,
                       iam_en_grand_father_name  = v_iam_en_grand_father_name,
                       iam_en_family_name        = v_iam_en_family_name,
                       iam_ar_two_names          = v_iam_ar_two_names,
                       iam_en_two_names          = v_iam_en_two_names,
                       iam_gender                = v_iam_gender,
                       iam_nationality_code      = v_iam_nationality_code,
                       iam_ar_nationality        = v_iam_ar_nationality,
                       iam_en_nationality        = v_iam_en_nationality,
                       iam_card_issue_date       = v_iam_id_issue_date_g,
                       iam_card_issue_date_h     = v_iam_id_issue_date_h,
                       iam_id_expire_date        = v_iam_id_expire_date_g,
                       iam_id_expire_date_h      = v_iam_id_expire_date_h,
                       iam_id_version            = v_iam_id_version,
                       iam_hijri_dob             = v_iam_hijri_dob,
                       iam_dob                   = v_iam_dob,
                       iam_language              = v_iam_language,
                       iam_ar_card_issue_place   = v_iam_ar_card_issue_place,
                       iam_en_card_issue_place   = v_iam_en_card_issue_place,
                       is_iam                    = 1,
                       status                    = 1
                 WHERE ID = v_user_id;
                 
                IF SQL%rowcount > 0 THEN
                    RETURN 1;
                END IF;
            END IF;
        END IF;
        
        RETURN 0;
    EXCEPTION
        WHEN OTHERS THEN  
            RETURN 0;
    END set_callback;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END NAFATH;
/