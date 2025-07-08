
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."EFAA" AS

    FUNCTION activities (
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_status       OUT VARCHAR2,
        p_message      OUT VARCHAR2,
        p_data         OUT VARCHAR2
    ) RETURN CLOB;
    
    FUNCTION create_account (
        p_reference_number IN NUMBER,
        p_lang             IN VARCHAR2 DEFAULT 'en',
        p_message         OUT VARCHAR2
    ) RETURN CLOB;
    
    FUNCTION upload_simple_invoice (
        p_billNumber              IN VARCHAR2,
        p_entityActivityId        IN VARCHAR2,
        p_customerFullName        IN VARCHAR2,
        p_customerMobileNumber    IN VARCHAR2,
        p_issueDate               IN VARCHAR2,
        p_expireDate              IN VARCHAR2,
        p_billItemList            IN CLOB,
        p_lang                    IN VARCHAR2 DEFAULT 'en',
        p_message                OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION cancel_invoice (
        p_bill_number   IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION invoice_details (
        p_bill_number   IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION payment (
        p_bill_number   IN NUMBER,
        p_method        IN VARCHAR2,
        p_date          IN TIMESTAMP,
        p_amount        IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT VARCHAR2
    ) RETURN CLOB;

    PROCEDURE ins_callback (
        p_body    IN VARCHAR2,
        p_id     OUT NUMBER  
    );

    FUNCTION set_callback (
        p_callback_id  IN NUMBER
    ) RETURN NUMBER;

END EFAA;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."EFAA" AS

    g_base_url VARCHAR2(1000);

    FUNCTION authorization_key
    RETURN VARCHAR2 IS
        v_is_lab    NUMBER;
    BEGIN
        v_is_lab := 1;

        SELECT DECODE(v_is_lab, 1, TEST_BASE_URL, BASE_URL) AS BASE_URL
          INTO g_base_url
          FROM ENVIRONMENT_SETTING
         WHERE UPPER(PROVIDER) = 'EFAA';

        RETURN g_base_url;
    END authorization_key;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================
 
    FUNCTION activities (
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_status       OUT VARCHAR2,
        p_message      OUT VARCHAR2,
        p_data         OUT VARCHAR2
    ) RETURN CLOB IS
        v_base_url         VARCHAR2(500);
        v_url              VARCHAR2(1000);
        l_clob             CLOB;
    BEGIN
        v_url := authorization_key || '/activity';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'username';
        apex_web_service.g_request_headers(2).value := '2023060502';
        apex_web_service.g_request_headers(3).name := 'password';
        apex_web_service.g_request_headers(3).value := 'Moh@08679';

        l_clob := apex_web_service.make_rest_request ( 
                    p_url         => v_url,
                    p_http_method => 'GET'
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'EFAA.activities', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_base_url || '/activity'
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := 'EFAA Request Error! Status: ' || apex_web_service.g_status_code;
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);

        -- FOR i IN 1 .. apex_json.get_count ('data') LOOP
        --     p_data := '[{"Id": '||APEX_JSON.get_varchar2 ('data[%d].id', i)||', '||'"activityName": '||APEX_JSON.get_varchar2 ('data[%d].activityName', i)||', '||
        --                 '"activityNameAr": ' || APEX_JSON.get_varchar2 ('data[%d].activityNameAr', i)||', '||'"activityNameEn": ' || APEX_JSON.get_varchar2 ('data[%d].activityNameEn', i)
        --                 ||', '|| '"status": ' || APEX_JSON.get_varchar2 ('data[%d].status', i)||', '||'"iban": ' || APEX_JSON.get_varchar2 ('data[%d].iban', i)||', '||
        --                 '"bankId": ' || APEX_JSON.get_varchar2 ('data[%d].bankId', i)||', '||'"cityId": ' || APEX_JSON.get_varchar2 ('data[%d].cityId', i)||', '||
        --                 '"code": ' || APEX_JSON.get_varchar2 ('data[%d].code', i) || '}]';
        -- END LOOP;

        p_status  := APEX_JSON.get_number('status');
        p_message := APEX_JSON.get_varchar2('message');

        FOR i IN 1 .. apex_json.get_count ('data') LOOP
            p_data := APEX_JSON.get_varchar2('data[%d].id', i);
        END LOOP;

        RETURN l_clob;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN SQLERRM;
    END activities;  

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================
 
    FUNCTION activity_id (
        p_lang          IN VARCHAR2 DEFAULT 'en'
    ) RETURN CLOB IS
        v_base_url         VARCHAR2(500);
        v_url              VARCHAR2(1000);
        v_id               VARCHAR2(50);
        l_clob             CLOB;
    BEGIN
        v_url := authorization_key || '/activity';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'username';
        apex_web_service.g_request_headers(2).value := '2023060502';
        apex_web_service.g_request_headers(3).name := 'password';
        apex_web_service.g_request_headers(3).value := 'Moh@08679';

        l_clob := apex_web_service.make_rest_request ( 
                    p_url         => v_url,
                    p_http_method => 'GET'
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'EFAA.activities', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_base_url || '/activity'
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            -- p_message := 'EFAA Request Error! Status: ' || apex_web_service.g_status_code;
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);

        FOR i IN 1 .. apex_json.get_count ('data') LOOP
            v_id := APEX_JSON.get_varchar2('data[%d].id', i);
        END LOOP;

        RETURN v_id;
    EXCEPTION
        WHEN OTHERS THEN
            -- p_message := SQLERRM; 
            RETURN SQLERRM;
    END activity_id;  

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION create_account (
        p_reference_number IN NUMBER,
        p_lang             IN VARCHAR2 DEFAULT 'en',
        p_message         OUT VARCHAR2
    ) RETURN CLOB IS
        v_base_url         VARCHAR2(500);
        v_body             VARCHAR2(32000);
        v_is_lab           NUMBER;
        l_clob             CLOB;
        v_url              VARCHAR2(1000);
    BEGIN
        IF p_reference_number IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        v_url := authorization_key || '/account/upload/onetime';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'username';
        apex_web_service.g_request_headers(2).value := '2023060502';
        apex_web_service.g_request_headers(3).name := 'password';
        apex_web_service.g_request_headers(3).value := 'Moh@08679';

        v_body := '{
                       "method":"INDIVIDUAL",
                       "type":"NORMAL",
                       "activityId":636,
                       "firstName":"Adel",
                       "secondName":"",
                       "thirdName":"",
                       "lastName":"Shokry",
                       "idType":"IQA",
                       "idNumber":"2546698453",
                       "phoneNumber":"562973961",
                       "referenceNumber":"'|| p_reference_number ||'",
                       "gender":"MALE",
                       "vatNumber":"252155225332558",
                       "streetName":"King Fahad Street",
                       "buildingNumber":"12",
                       "district":1,
                       "city":1,
                       "additionalNumber":"2525",
                       "postalCode":"11111",
                       "idAttachment":"https://qa.e-faa.com.sa/wbiller/static/media/IFSC-AR.1eefc0a2.png"
                    }';

        l_clob := apex_web_service.make_rest_request ( 
                    p_url         => v_url,
                    p_http_method => 'POST',
                    p_body        => v_body
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'EFAA.create_account', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_base_url || '/account/upload/onetime'
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );

            APEX_JSON.parse(l_clob);
            p_message := 'EFAA Request Error! Status: ' || apex_web_service.g_status_code || ' Message: ' || apex_json.get_varchar2('message');
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);
        p_message := apex_json.get_varchar2('message');
        RETURN l_clob;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN '-1';
    END create_account;  

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION upload_simple_invoice (
        p_billNumber              IN VARCHAR2,
        p_entityActivityId        IN VARCHAR2,
        p_customerFullName        IN VARCHAR2,
        p_customerMobileNumber    IN VARCHAR2,
        p_issueDate               IN VARCHAR2,
        p_expireDate              IN VARCHAR2,
        p_billItemList            IN CLOB,
        p_lang                    IN VARCHAR2 DEFAULT 'en',
        p_message                OUT VARCHAR2
    ) RETURN CLOB IS
        v_url               VARCHAR2(1000);
        v_body              VARCHAR2(32000);
        v_activity_id       VARCHAR2(50);
        v_efaa_seq_id       NUMBER;
        l_clob              CLOB;
    BEGIN
        IF p_entityActivityId IS NULL OR p_customerFullName IS NULL OR p_customerMobileNumber IS NULL OR p_billItemList IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        v_url := authorization_key || '/simple/upload';

        INSERT INTO EFAA_LOGS ( BILL_NUMBER, CREATED_DATE, URL )
            VALUES ( p_billNumber, GET_CURRENT_DATE, v_url )
        RETURNING ID INTO v_efaa_seq_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN '-4';
        END IF;

        -- v_activity_id := activities (p_status => , p_message => , p_data => );

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'username';
        apex_web_service.g_request_headers(2).value := '2023060502';
        apex_web_service.g_request_headers(3).name := 'password';
        apex_web_service.g_request_headers(3).value := 'Moh@08679';

        v_body := '{
                    "billNumber": "'|| p_billNumber ||'", 
                    "entityActivityId": '|| p_entityActivityId || ', 
                    "customerFullName": "'|| p_customerFullName || '",
                    "customerMobileNumber": "'|| p_customerMobileNumber || '", 
                    "issueDate": "'|| p_issueDate || '", 
                    "expireDate": "'|| p_expireDate || '", 
                    "billItemList":'|| p_billItemList || '
                }';

        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_url,
                    p_http_method => 'POST',
                    p_body        => v_body
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'EFAA.upload_simple_invoice', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            APEX_JSON.parse(l_clob);
            p_message := 'EFAA Request Error! - Status: ' || apex_web_service.g_status_code || ' - Message: ' || apex_json.get_varchar2('message');
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);
        
        UPDATE EFAA_LOGS
           SET BILL_NUMBER  = SUBSTR(l_clob, INSTR(l_clob, '"billNumber":"') + 14, 11),
               SADAD_NUMBER = SUBSTR(l_clob, INSTR(l_clob, '"sadadNumber":"') + 15, 9),
               STATUS       = SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang),
               CODE         = apex_web_service.g_status_code,
               MESSAGE      = apex_json.get_varchar2('message'),
               RESPONSE     = SUBSTR(l_clob, 1, 4000),
               REQUEST_BODY = v_body
         WHERE ID = v_efaa_seq_id;

        IF SQL%ROWCOUNT = 0 THEN
            UPDATE EFAA_LOGS
               SET STATUS   = SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang),
                   CODE     = apex_web_service.g_status_code,
                   MESSAGE  = apex_json.get_varchar2('message'),
                   RESPONSE = SUBSTR(l_clob, 1, 4000),
                   REQUEST_BODY = v_body
             WHERE ID = v_efaa_seq_id;

            RETURN '-5';
        ELSE
            p_message := apex_json.get_varchar2('message');
            RETURN l_clob;
        END IF;

        RETURN '-6';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN '-1';
    END upload_simple_invoice;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION cancel_invoice (
        p_bill_number   IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT VARCHAR2
    ) RETURN CLOB IS
        v_url               VARCHAR2(1000);
        v_base_url          VARCHAR2(500);
        v_is_lab            NUMBER;
        l_clob              CLOB;
    BEGIN
        IF p_bill_number IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        v_url := authorization_key || '/cancel?billNumber=' || p_bill_number;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'username';
        apex_web_service.g_request_headers(2).value := '2023060502';
        apex_web_service.g_request_headers(3).name := 'password';
        apex_web_service.g_request_headers(3).value := 'Moh@08679';

        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_url,
                    p_http_method => 'PUT'
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'EFAA.cancel_invoice', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            APEX_JSON.parse(l_clob);
            p_message := 'EFAA Request Error! - Status: ' || apex_web_service.g_status_code || ' - Message: ' || apex_json.get_varchar2('message');
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);
        
        UPDATE EFAA_LOGS
           SET STATUS      = SYSTEM_CONTROLS.get_translation(p_code => 'canceled', p_lang => p_lang)
         WHERE BILL_NUMBER = to_char(p_bill_number);

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := 'Logs Updating Error!';
            RETURN '-4';
        END IF;
        
        p_message := apex_json.get_varchar2('message') || ' The Invoice has been canceled successfully';
        RETURN l_clob;

    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN '-1';
    END cancel_invoice;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION invoice_details (
        p_bill_number   IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT VARCHAR2
    ) RETURN CLOB IS
        v_url               VARCHAR2(1000);
        v_base_url          VARCHAR2(500);
        v_is_lab            NUMBER;
        l_clob              CLOB;
    BEGIN
        IF p_bill_number IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        v_url := authorization_key || '/bill/info?billNumber=' || p_bill_number;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'username';
        apex_web_service.g_request_headers(2).value := '2023060502';
        apex_web_service.g_request_headers(3).name := 'password';
        apex_web_service.g_request_headers(3).value := 'Moh@08679';

        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_url,
                    p_http_method => 'GET'
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'EFAA.invoice_details', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            APEX_JSON.parse(l_clob);
            p_message := 'EFAA Request Error! - Status: ' || apex_web_service.g_status_code || ' - Message: ' || apex_json.get_varchar2('message');
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);
        p_message := apex_json.get_varchar2('message');
        RETURN l_clob;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN '-1';
    END invoice_details;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION payment (
        p_bill_number   IN NUMBER,
        p_method        IN VARCHAR2,
        p_date          IN TIMESTAMP,
        p_amount        IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT VARCHAR2
    ) RETURN CLOB IS
        v_url               VARCHAR2(1000);
        v_base_url          VARCHAR2(500);
        v_body              VARCHAR2(32000);
        v_efaa_seq_id       NUMBER;
        v_is_lab            NUMBER;
        l_clob              CLOB;
    BEGIN
        IF p_bill_number IS NULL OR p_method IS NULL OR p_date IS NULL OR p_amount IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        v_url := authorization_key || '/payment';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'username';
        apex_web_service.g_request_headers(2).value := '2023060502';
        apex_web_service.g_request_headers(3).name := 'password';
        apex_web_service.g_request_headers(3).value := 'Moh@08679';

        -- v_body := '{
        --             "billNumber": "'|| p_bill_number ||'", 
        --             "paymentMethod":"'|| p_method ||'", 
        --             "paymentDate":'|| p_date ||',
        --             "paymentAmount":'|| p_amount ||'
        --         }';
        v_body := '{
                  "billNumber": "'|| p_bill_number ||'",
                  "paymentMethod": "'|| p_method ||'",
                  "paymentDate": "'|| p_date ||'",
                  "paymentAmount": '|| p_amount ||'
                }';
/*
    payment methods: [ CASH, CCARD, VISA, MASTER, AMERICAN_EXP, MADA, EFT, ACTDEB, APPLEPAY, EWALLET, CHEQUE ]
*/
        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_url,
                    p_http_method => 'POST',
                    p_body        => v_body
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'EFAA.payment', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            APEX_JSON.parse(l_clob);
            p_message := 'EFAA Request Error! - Status: ' || apex_web_service.g_status_code || ' - Message: ' || apex_json.get_varchar2('message');
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);
        
        UPDATE EFAA_LOGS
           SET STATUS      = SYSTEM_CONTROLS.get_translation(p_code => 'paid', p_lang => p_lang)
         WHERE BILL_NUMBER = to_char(p_bill_number);

        IF SQL%ROWCOUNT = 0 THEN 
            RETURN '-4';
        END IF;
        
        p_message := apex_json.get_varchar2('message');
        RETURN l_clob;

    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN '-1';
    END payment;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    PROCEDURE ins_callback (
        p_body    IN VARCHAR2,
        p_id     OUT NUMBER  
    ) IS
        v_id   NUMBER;
    BEGIN
        INSERT INTO EFAA_CALLBACK (CALLBACK_BODY, STATUS)
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
        v_sadad_number     NUMBER;
        v_body             VARCHAR2(32000);
        v_status           VARCHAR2(500);
        v_efaa_status      VARCHAR2(500);
    BEGIN
        IF p_callback_id IS NULL THEN 
            RETURN -2;
        END IF;

        SELECT CALLBACK_BODY, STATUS 
          INTO v_body, v_status
          FROM EFAA_CALLBACK
         WHERE ID = p_callback_id;

        IF v_status = 1 THEN
            RETURN 1;
        END IF;

        APEX_JSON.parse(v_body);

        v_efaa_status  := apex_json.get_varchar2('paymentStatus');
        v_sadad_number := apex_json.get_varchar2('sadadNumber');

        IF v_efaa_status IS NULL OR v_efaa_status <> 'APPROVED' THEN
            UPDATE EFAA_CALLBACK
               SET STATUS      = -1,
                   EFAA_STATUS = apex_json.get_varchar2('paymentStatus')
             WHERE ID = p_callback_id;

            UPDATE EFAA_LOGS
               SET CALLBACK_STATUS = -1
             WHERE SADAD_NUMBER = TO_NUMBER(v_sadad_number);
            RETURN -3;
        ELSE
            UPDATE EFAA_CALLBACK
               SET STATUS = 1,
                   EFAA_STATUS = apex_json.get_varchar2('paymentStatus')
             WHERE ID = p_callback_id;

            UPDATE EFAA_LOGS
               SET CALLBACK_STATUS = 1
             WHERE SADAD_NUMBER = TO_NUMBER(v_sadad_number);

            IF SQL%ROWCOUNT > 0 THEN
                RETURN 1;
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

END EFAA;
/