
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."SYSTEM_INTEGRATION" as

    FUNCTION UPLOAD_FILES (
        p_file           IN BLOB,
        p_file_name      IN VARCHAR2,
        p_mime_type      IN VARCHAR2,
        p_bucket         IN VARCHAR2 DEFAULT 'v2',
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2,
        p_returned_url  OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION UPLOAD_AWS (
        p_file  BLOB
    ) RETURN NUMBER;

    FUNCTION send_products (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB
    ) RETURN CLOB;

    FUNCTION send_auction (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION edit_auction (
        p_body       IN CLOB,
        p_id         IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION edit_auction_products (
        p_body          IN CLOB,
        p_auction_id    IN VARCHAR2,
        p_seller_id     IN VARCHAR2,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION send_auction_products (
        p_body       IN CLOB,
        p_auction_id IN VARCHAR2,
        p_seller_id  IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION delete_auction_product (
        p_auction_id IN VARCHAR2,
        p_product_id IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION dynamic_sql (
        p_fields     IN VARCHAR2,
        p_table      IN VARCHAR2,
        p_condition  IN VARCHAR2 DEFAULT NULL,
        p_populate   IN VARCHAR2 DEFAULT NULL,
        p_order_by   IN VARCHAR2 DEFAULT ' asc '
    ) RETURN SYS_REFCURSOR;

    FUNCTION send_individual_realestate_auction_old (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB,
        p_status    OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION send_individual_realestate_auction (
        p_product_id    IN NUMBER,
        p_seller_id     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2,
        p_status       OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION send_individual_car_auction (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2,
        p_status    OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION dynamic_sql_v2 (
        p_fields IN VARCHAR2,
        p_table  IN VARCHAR2
    ) RETURN CLOB;

    FUNCTION columns_names (
        p_table IN VARCHAR2
    ) RETURN CLOB;

    FUNCTION products (
        p_id IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION services_agent_request (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION send_services_agent_file (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB
    ) RETURN CLOB;

    FUNCTION send_vehicle_images (
        p_body       IN CLOB,
        p_seller_id  IN NUMBER,
        p_product_id IN NUMBER,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB
    ) RETURN CLOB;

    FUNCTION auction_containers (
        p_seller_id     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT CLOB
    ) RETURN CLOB;

    FUNCTION auction_container_details (
        p_auction_id    IN VARCHAR2,
        p_seller_id     IN VARCHAR2,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT CLOB
    ) RETURN CLOB;

    FUNCTION delete_auction_container (
        p_auction_id    IN VARCHAR2,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT CLOB
    ) RETURN CLOB;

    FUNCTION urway (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT CLOB
    ) RETURN CLOB;

    FUNCTION urway_integration (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT CLOB
    ) RETURN CLOB;

    FUNCTION individual_realestate_seller_assign (
        p_body       IN CLOB,
        p_id         IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION nafith (
        p_id            IN VARCHAR2,
        p_buyer_id      IN VARCHAR2,
        p_total_price   IN VARCHAR2,
        p_token         IN VARCHAR2,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT CLOB,
        p_status       OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION sned_SMS (
        p_body          IN CLOB,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION individual_auction_update_status (
        p_body          IN CLOB,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION upload (
        p_blob          IN BLOB,
        p_auth          IN VARCHAR2,
        p_mimetype      IN VARCHAR2,
        p_product_name  IN VARCHAR2,
        p_product_id    IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION individual_republish_allowed (
        p_body       IN CLOB,
        p_id         IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION check_payment_status (
        p_track_id  IN VARCHAR2,
        p_message  OUT CLOB
    ) RETURN CLOB;

END "SYSTEM_INTEGRATION";
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."SYSTEM_INTEGRATION" as

    FUNCTION g_base_url
      RETURN VARCHAR2 IS
        l_is_lab   NUMBER;
        l_base_url VARCHAR2(1000);
    BEGIN
        l_is_lab := 1;

        SELECT DECODE(l_is_lab, 1, TEST_BASE_URL, BASE_URL) AS BASE_URL
          INTO l_base_url
          FROM ENVIRONMENT_SETTING
         WHERE UPPER(PROVIDER) = 'MOBASHER';

        RETURN l_base_url;
    END g_base_url;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION upload_files (
        p_file           IN BLOB,
        p_file_name      IN VARCHAR2,
        p_mime_type      IN VARCHAR2,
        p_bucket         IN VARCHAR2 DEFAULT 'v2',
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2,
        p_returned_url  OUT VARCHAR2
    ) RETURN NUMBER AS
        l_request_url	    VARCHAR2(32767);
        l_result	        CLOB;
        l_object            JSON_OBJECT_T;
        l_array             JSON_ARRAY_T;
    BEGIN
        l_array := new JSON_ARRAY_T;

        IF p_file IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'should_upload_file', p_lang => p_lang);
            RETURN -2;
        END IF;

        IF p_file_name IS NULL OR p_mime_type IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -3;
        END IF;

        -- DBMS_CLOUD.create_credential (
        --     credential_name => 'OCI_AUTH',
        --     user_ocid       => 'ocid1.user.oc1..aaaaaaaajot34an3girbk755rwyuakza4hs6vhdnqcmw3ehhxriq6lk2twba',
        --     tenancy_ocid    => 'ocid1.tenancy.oc1..aaaaaaaavtni6inttcsamnvt4zdgbdwngrtuz24vc4hiomhwjqdqfgj7uo2a',
        --     private_key     => '-----BEGIN PRIVATE KEY-----MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDLru9QiOA0R0ef+mTNgRhpZ5Ech8bZraUWICD5+eGPn2uFlLabcV64zqbR21pykddPs8LZ62MDP/5wiPAjcBy91WyNJcXNspD/RohCPW90itvj5VKW30bkneCozugOq0d2MQhAOzyFr/FMKoStqNIRSlQxx0cKzdj+IzDHmUG2SX/R4orRuwIsTAD43ucNMks2AhAi8VMyXv7ukmzrQn7HsBlmydqc6BOVotEvvrNh8mN+1ugfjsOHq8obpqXZCi0naAkUbgXxFB0csC4vZKmcIyU/6EHbEaIFv+eZIL1doHVt431ZvvLNcEqEvimg3nXRctoG7Os3UnHJNWzVtXvZAgMBAAECggEAM7M8pYmIt1xcbtwE2DDrfF3AdKh2LeyombwgArONsIH7rdV4oG4fZ/N0XpI6HBiuuVlcnSnlYP7OW8w2gBhGA114Bz/OPI8VxOYnUgD8GG3isK8VzpvwB7mXO+IA/zA0nGiHup4Ol7R4ICgus1HFuIPQaS429yQW7zMJf7CEAHulB6mCHEQ5Xzwi8wZ/HzYpTdiERWxM1iQAsu5+JsInuNYzqXilTQgTgyu47qC9twV7D5qGvrXg8Cf87T/IAU95kmuQQNLKfomFXu3JmhZdnFEN9so9o6wGbe/qTaGUA8n/W/alL0DKArniD+JJaVyPaUYuJesKpYs5j886kRvczQKBgQD8asDCyyx+pk1MXwxMY8CpNInDPnfT8VMs13reAHTH5b444NuVGVYl5GYiuNU8FY5tG2ZbufqeNoKwykzjWofvP4jr91jLCzk/QjX1qiIy/APVuJeYY6cboY6WZcLH4ZUT0kMaYqw9Ccjib7/O1mbMBSItdxjBlgNH3deezCk/ewKBgQDOkxc6UzChK+IUIoDG/MWyQbUWB+Bewrfn1hHNKa3lvjJhjTSC8+fah2fM8fgoTyBy1wTpJONcDldzM+J9Pb5SvpCSc1q1JRq/rwAZWAf5OTRIKNZfWm2OGhqBsvn3EGGS+imcMwO7c0r/WK968cWg77toRzwbtZA+Q3E4YxtHuwKBgAJEv1jA1LSKsBUooYaqOtgKddaAYDlSaOn1QdBu9p25Td1a//42DRUoGVbkjF4O34nRfjkC0eLMIJ6QIuLENIaM7qEYRv8EKc6MvMlpbwdARpSMJSikdKMF768gWQDM4TcdY6cADgY6aUjHslScjq30udrowBs1SvBBaSevNAuzAoGACWFkjKF6c9cqTP/EGUUhNRcGwhlZdvQgpcZyyH48B1K7tvJSkB/DR4kejY/vVOVC8/QPpQanzGZaUkDo6AcFvXwp1HyogdFNhabMulnlAsw2M5CnK21PzEQjMACQmUeFJsd1XEJ0yO5TWYUNcufHsacxO2sAr8Fu62Tkn0rg0kECgYBRcjPkWAzKeHUpxyKOQmnYdsljYHTR1O9gKhq5dfuNBBHivxnde7QZ9i7eTnXDW/J8L3UJ70FuGHWE+uK6ink+CvrBtZrubEG5rtbE1YoDdMnlXymwkd9MLiDwyxg2HCS+pR21vc8uVDOv7TfXeEYTT2mv60ydPjWdR7nREu0Y/w==-----END PRIVATE KEY-----',
        --     fingerprint     => 'e7:1e:b5:30:fe:ee:79:5a:df:21:40:41:2a:84:f7:7b'
        -- );
        -- return 111;

        l_request_url := 'https://objectstorage.me-jeddah-1.oraclecloud.com/n/axax2vam4edg/b/'|| p_bucket ||'/o/'|| p_file_name || SYSTEM_CONTROLS.file_extension_by_mimetype(p_mimetype => p_mime_type);

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_request_url,
                        p_http_method          => 'PUT',
                        p_body_blob            => p_file,
                        p_credential_static_id => 'OCI_AUTH'
                    );
        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS(p_ERROR_TYPE => 'UPLOAD_FILES_API', p_PROCESS_NAME => 'SYSTEM_INTEGRATION.upload_files', p_ERROR_CODE => -2, p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000), p_OBJECT_TYPE => p_message, p_logger_name => USER);
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'uploading_error', p_lang => p_lang);
            RETURN -4;
        END IF;

        l_array.APPEND(l_request_url);
        p_returned_url := l_array.to_string;
        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN 1;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END upload_files;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION UPLOAD_AWS (
        p_file  BLOB
    ) RETURN NUMBER IS
        l_request_url	    VARCHAR2(32767);
        l_result	        CLOB;
        v_body      	    CLOB;
    BEGIN
        -- v_body := '{ "files":"'|| p_file ||'" }';

        apex_web_service.g_request_headers.DELETE;
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name  := 'Authorization';
        apex_web_service.g_request_headers(2).value := 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ODIwMSwiaWF0IjoxNzAwNDg2MDQxLCJleHAiOjE3MDMwNzgwNDF9.lx5lF6wC0aTLu849fWcqaef511T4AZ-rsc1t-LI9Ysw';

        l_result := APEX_WEB_SERVICE.make_rest_request (
              p_url => 'https://services.mobasher.sa/upload',
              p_http_method => 'POST',
              p_body_blob  => p_file
        );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            -- SYSTEM_CONTROLS.ERROR_LOGS ( p_error_type    => 'SYSTEM_ERROR',
            --                                  p_process_name  => 'OCI_OS.put_object_P10 - App: ' || :APP_ID,
            --                                  p_error_code    => -2,
            --                                  p_error_message => SUBSTR(l_result, 1, 4000),
            --                                  p_logger_name   => :APP_USER
            --                             );
            RAISE_APPLICATION_ERROR(-20004, 'Error with uploading Data! ' || APEX_WEB_SERVICE.g_status_code);
            RETURN 0;
        END IF;

        -- IF SQL%ROWCOUNT = 0 THEN
        --         RAISE_APPLICATION_ERROR(-20003, 'خطأ في رفع المرفق!');
        -- END IF;
        RETURN 1;
    END UPLOAD_AWS;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_products (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    CLOB;
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_body := p_body;
        l_url  := 'https://backend-master.mobasher.sa/apex/vehicle';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        -- apex_web_service.g_request_headers(2).name := 'API_KEY';
        -- apex_web_service.g_request_headers(2).value := 'Showshow-Nownow';
        
        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_url,
                        p_http_method          => 'POST',
                        p_body                 => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226, 524 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SEND_PRODUCTS_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_products',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := 'Error with status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';

        --     INSERT INTO API_RESULTS (PROCESS_NAME, RESPONSE, REQUEST, URL)
        --         VALUES ( 'send_products_api', substr(l_result, 1, 4000), substr(l_body, 1, 4000), l_url);

        --       IF SQL%ROWCOUNT = 0 THEN
        --         p_message := 'Log Error';
        --         RETURN '-4';
        --     END IF;
        END IF;

        p_message := l_result;
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END send_products;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_auction (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://sandbox.mobasher.sa/api/v2/auction-containers/seller';
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_url,
                        p_http_method          => 'POST',
                        p_body                 => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SEND_AUCTION_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_auction',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := l_result || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'send_auction_api', l_result, l_body, l_url);

        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1'; 
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END send_auction;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION edit_auction (
        p_body       IN CLOB,
        p_id         IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://sandbox.mobasher.sa/api/v2/auction-containers/seller/' || p_id;
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'PATCH',
                        p_body              => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'edit_AUCTION_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.edit_auction',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := l_result || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;
        
        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'edit_auction_api', l_result, l_body, l_url);
        
        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END edit_auction;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION edit_auction_products (
        p_body          IN CLOB,
        p_auction_id    IN VARCHAR2,
        p_seller_id     IN VARCHAR2,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://sandbox.mobasher.sa/api/v2/auctions/' || p_auction_id;
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'sellerId';
        apex_web_service.g_request_headers(2).value := p_seller_id;

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'PATCH',
                        p_body              => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'edit_auction_products_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.edit_auction',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := l_result || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'edit_auction_products_api', l_result, l_body, l_url);
        
        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END edit_auction_products;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_auction_products (
        p_body       IN CLOB,
        p_auction_id IN VARCHAR2,
        p_seller_id  IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://sandbox.mobasher.sa/api/v2/auctions';
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name := 'containerId';
        apex_web_service.g_request_headers(2).value := p_auction_id;
        apex_web_service.g_request_headers(3).name := 'sellerId';
        apex_web_service.g_request_headers(3).value := p_seller_id;

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'POST',
                        p_body              => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'send_auction_products_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_auction_products',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := l_result || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'send_auction_products_api', l_result, l_body, l_url);

        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END send_auction_products;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_auction_product (
        p_auction_id IN VARCHAR2,
        p_product_id IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_auction_id IS NULL OR p_product_id IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://sandbox.mobasher.sa/api/v2/auction//container/' || p_auction_id;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'DELETE'
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'delete_auction_product_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.delete_auction_product',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := l_result || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'delete_auction_product_api', l_result, l_body, l_url);

        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END delete_auction_product;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_individual_realestate_auction_old (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB,
        p_status    OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(5000);
        l_body    CLOB;
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://backend-master.mobasher.sa/products';
        -- l_url := 'https://demo.backend.mobasher.sa/products';
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_url,
                        p_http_method          => 'POST',
                        p_body                 => l_body
                    );


        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SEND_INDIVIDUAL_REALESTATE_AUCTION_old_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_individual_realestate_auction_old',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_status  := APEX_WEB_SERVICE.g_status_code;
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     -- VALUES ('send_individual_realestate_auction_old_api', SUBSTR(l_result, 1, 4000), SUBSTR(l_body, 1, 4000), l_url);

        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_status  := APEX_WEB_SERVICE.g_status_code;
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END send_individual_realestate_auction_old;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_individual_realestate_auction (
        p_product_id    IN NUMBER,
        p_seller_id     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2,
        p_status       OUT VARCHAR2
    ) RETURN CLOB AS
        l_result                    CLOB;                l_status                    VARCHAR2(5000);
        l_url	                    VARCHAR2(5000);      l_body                      VARCHAR2(32700);
        v_name                      VARCHAR2(1000);      v_val_license_url           VARCHAR2(5000);
        v_city_id                   VARCHAR2(1000);      v_mediation_contract_url    VARCHAR2(5000);
        v_category_id               VARCHAR2(1000);      v_is_property_rated         VARCHAR2(1000);
        v_sub_category_id           VARCHAR2(1000);      v_property_rated_url        VARCHAR2(5000);
        v_main_image                VARCHAR2(2000);      v_is_fully_owned            VARCHAR2(1000);
        v_images_urls               VARCHAR2(10000);     v_owned_percentage          VARCHAR2(1000);
        v_description               VARCHAR2(1000);      v_is_fully_sell             VARCHAR2(1000);
        v_neighbourhoods_id         VARCHAR2(1000);      v_sell_percentage           VARCHAR2(1000);
        v_street_name_ar            VARCHAR2(1000);      v_sell_authorization_url    VARCHAR2(5000);
        v_usage_id                  VARCHAR2(1000);      v_minimum_sell_price        VARCHAR2(1000);
        v_facade_id                 VARCHAR2(1000);      v_instrument_url            VARCHAR2(5000);
        v_property_type_id          VARCHAR2(1000);      v_license_type              VARCHAR2(1000);
        v_space                     VARCHAR2(1000);      v_license_expiry_date       VARCHAR2(1000);
        v_instrument_no             VARCHAR2(1000);      v_urls                      APEX_T_VARCHAR2;
        v_buyer_id                  VARCHAR2(1000);      header                      json_object_t;
        v_is_instrument_valid       VARCHAR2(1000);      realestate_object           json_object_t;
        v_requester_as              VARCHAR2(1000);      buyer_realestate_object     json_object_t;
        v_is_accepted_terms         VARCHAR2(1000);      lengths_object              json_object_t;
        v_authorization_number      VARCHAR2(1000);      services_object             json_object_t;
        v_authorization_date        VARCHAR2(1000);      name_object                 json_object_t;
        v_authorization_address     VARCHAR2(1000);      description_object          json_object_t;
        v_authorization_url         VARCHAR2(1000);      street_name_object          json_object_t;
        v_val_license_number        VARCHAR2(1000);      images_urls_array           json_array_t;
    BEGIN
        IF p_product_id IS NULL OR p_seller_id IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        header                  := json_object_t();
        realestate_object       := json_object_t();
        buyer_realestate_object := json_object_t();
        lengths_object          := json_object_t();
        services_object         := json_object_t();
        name_object             := json_object_t();
        description_object      := json_object_t();
        street_name_object      := json_object_t();
        images_urls_array       := json_array_t();

        SELECT p.NAME_AR, p.CITY_ID, p.CATEGORY_ID, p.SUB_CATEGORY_ID, p.MAIN_IMAGE_URL, p.IMAGES_URLS, p.DESCRIPTION_AR, r.NEIGHBOURHOODS_ID, r.STREET_NAME_AR,
               DECODE(LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => r.USAGE_ID), 'residential', 'RESIDENTIAL', 'commercial', 'RE_COMMERCIAL', 'industrial', 'INDUSTRIAL', 'farming',
               'AGRICULTURAL', 'public_property', 'RE_GENERAL', 'commercial_residential', 'COMMERCIAL_AND_RESIDENTIAL', 'industrial_commercial', 'COMMERCIAL_AND_INDUSTRIAL'),
               UPPER(LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => r.FACADE_ID)), UPPER(LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => r.PROPERTY_TYPE_ID)),
               r.SPACE, r.INSTRUMENT_NO, i.BUYER_ID, i.IS_INSTRUMENT_VALID, i.IS_ACCEPT_TERMS_AND_CONDITIONS, i.AUTHORIZATION_NUMBER, TO_CHAR(i.AUTHORIZATION_DATE, 'YYYY-MM-DD'), i.AUTHORIZATION_ADDRESS,
               i.AUTHORIZATION_URL, i.VAL_LICENSE_NUMBER, i.LICENSE_TYPE, TO_CHAR(i.LICENSE_EXPIRY_DATE, 'YYYY-MM-DD'), i.VAL_LICENSE_URL, i.MEDIATION_CONTRACT_URL, i.IS_PROPERTY_RATED, i.PROPERTY_RATED_URL,
               i.IS_FULLY_OWNED, i.OWNED_PERCENTAGE, i.IS_FULLY_SELL, i.SELL_PERCENTAGE, i.SELL_AUTHORIZATION_URL, i.MINIMUM_SELL_PRICE, i.INSTRUMENT_URL,
               DECODE(LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => i.REQUESTER_AS), 'owner', 'HIMSELF', 'authorized', 'AGENT', 'real_estate_marketer', 'MARKTER')
          INTO v_name, v_city_id, v_category_id, v_sub_category_id, v_main_image, v_images_urls, v_description, v_neighbourhoods_id, v_street_name_ar, v_usage_id, v_facade_id, v_property_type_id,
               v_space, v_instrument_no, v_buyer_id, v_is_instrument_valid, v_is_accepted_terms, v_authorization_number, v_authorization_date, v_authorization_address,
               v_authorization_url, v_val_license_number, v_license_type, v_license_expiry_date, v_val_license_url, v_mediation_contract_url, v_is_property_rated, v_property_rated_url,
               v_is_fully_owned, v_owned_percentage, v_is_fully_sell, v_sell_percentage, v_sell_authorization_url, v_minimum_sell_price, v_instrument_url, v_requester_as
          FROM PRODUCTS p,
               REAL_STATE_DETAILS r,
               INDIVIDUAL_REALESTATE_REQUESTS i
         WHERE p.ID = r.PRODUCT_ID
           AND p.ID = i.PRODUCT_ID
           AND p.ID = p_product_id;
        
        FOR i IN (SELECT UPPER(LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => SERVICE_ID)) AS SERVICE, DESCRIPTION_AR
                    FROM PROPERTY_SERVICES
                   WHERE PRODUCT_ID = p_product_id)
        LOOP
            services_object.put(i.SERVICE, i.DESCRIPTION_AR);
        END LOOP;

        FOR j IN (SELECT UPPER(LOOKUPS_MNT.lookup_detail_code_by_id (p_lookup_detail_id => FACADE_ID)) AS FACADE, DESCRIPTION_AR
                    FROM PROPERTY_DIMENSIONS
                   WHERE PRODUCT_ID = p_product_id)
        LOOP
            lengths_object.put(j.FACADE, j.DESCRIPTION_AR);
        END LOOP;

        name_object.put('ar-SA', TRIM(v_street_name_ar));
        description_object.put('ar-SA', TRIM(v_description));
        street_name_object.put('ar-SA', TRIM(v_name));

        v_urls := APEX_STRING.split ( p_str => v_images_urls, p_sep => ',' );

        IF v_urls.count > 1 THEN
            FOR k IN 1 .. v_urls.count LOOP
                images_urls_array.append(v_urls(k));
            END LOOP;
        ELSIF v_urls.count = 1 THEN
            images_urls_array.append(v_images_urls);
        END IF;

        -- REAL-ESTATE object
        realestate_object.put('id',                 'id');
        realestate_object.put('neighbourhood',      TRIM(v_neighbourhoods_id));
        realestate_object.put('streetNameTrans',    name_object);
        realestate_object.put('usingFor',           TRIM(v_usage_id));
        realestate_object.put('realEstateFacade',   TRIM(v_facade_id));
        realestate_object.put('propertyType',       TRIM(v_property_type_id));
        realestate_object.put('theSpace',           TRIM(v_space));
        realestate_object.put('sakNo',              TRIM(v_instrument_no));
        realestate_object.put('limitsAndLenghts',   lengths_object);
        realestate_object.put('properties',         services_object);

        -- BUYER REAL-ESTATE object
        buyer_realestate_object.put('id',                       'id');
        buyer_realestate_object.put('buyer',                    TRIM(v_buyer_id));
        buyer_realestate_object.put('instrumentValid',          TRIM(v_is_instrument_valid));
        buyer_realestate_object.put('acceptTerms',              TRIM(v_is_accepted_terms));
        buyer_realestate_object.put('participantAs',            TRIM(v_requester_as));
        buyer_realestate_object.put('agentNo',                  TRIM(v_authorization_number));
        buyer_realestate_object.put('agentDate',                TRIM(v_authorization_date));
        buyer_realestate_object.put('agentPlace',               TRIM(v_authorization_address));
        buyer_realestate_object.put('agentDocumentUrl',         TRIM(v_authorization_url));
        buyer_realestate_object.put('valLicenseNo',             TRIM(v_val_license_number));
        buyer_realestate_object.put('valLicenseType',           TRIM(v_license_type));
        buyer_realestate_object.put('valLicenseExDate',         TRIM(v_license_expiry_date));
        buyer_realestate_object.put('valDocumentUrl',           TRIM(v_val_license_url));
        buyer_realestate_object.put('brokerageContractUrl',     TRIM(v_mediation_contract_url));
        buyer_realestate_object.put('hasEvaluated',             TRIM(v_is_property_rated));
        buyer_realestate_object.put('evaluatedUrl',             TRIM(v_property_rated_url));
        buyer_realestate_object.put('fullyOwned',               TRIM(v_is_fully_owned));
        buyer_realestate_object.put('ownedPercentage',          TRIM(v_owned_percentage));
        buyer_realestate_object.put('fullySold',                TRIM(v_is_fully_sell));
        buyer_realestate_object.put('soldPercentage',           TRIM(v_sell_percentage));
        buyer_realestate_object.put('sellUrl',                  TRIM(v_sell_authorization_url));
        buyer_realestate_object.put('minimumAcceptablePrice',   TRIM(v_minimum_sell_price));
        buyer_realestate_object.put('instrumentUrl',            TRIM(v_instrument_url));

        -- MAIN object
        header.put('realestatedetail',  realestate_object);
        header.put('buyerrealestate',   buyer_realestate_object);
        header.put('seller',            p_seller_id);
        header.put('nameTrans',         street_name_object);
        header.put('descriptionTrans',  description_object);
        header.put('city',              TRIM(v_city_id));
        header.put('category',          TRIM(v_category_id));
        header.put('subcategory',       TRIM(v_sub_category_id));
        header.put('mainImageUrl',      TRIM(v_main_image));
        header.put('imagesUrls',        images_urls_array);
        header.put('type',              'INDIVIDUAL_PRODUCT');


        l_url := 'https://backend-master.mobasher.sa/products';
        -- l_url := 'https://demo.backend.mobasher.sa/products';
        l_body := header.to_clob();

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_url,
                        p_http_method          => 'POST',
                        p_body                 => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SEND_INDIVIDUAL_REALESTATE_AUCTION_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_individual_realestate_auction',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_status  := APEX_WEB_SERVICE.g_status_code;
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ('send_individual_realestate_auction_api', SUBSTR(l_result, 1, 32767), SUBSTR(l_body, 1, 32767), l_url);

        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;

        realestate_object       := json_object_t();
        buyer_realestate_object := json_object_t();
        lengths_object          := json_object_t();
        services_object         := json_object_t();
        name_object             := json_object_t();
        street_name_object      := json_object_t();
        images_urls_array       := json_array_t();

        p_status  := APEX_WEB_SERVICE.g_status_code;
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN SUBSTR(l_result, 1, 4000);
    END send_individual_realestate_auction;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_individual_car_auction (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2,
        p_status    OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            p_status := '-2';
            RETURN '-2';
        END IF;

        l_url := 'https://backend-master.mobasher.sa/products';
        -- l_url := 'https://demo.backend.mobasher.sa/products';
        -- l_url := 'https://api-new.mobasher.sa/products';
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_url,
                        p_http_method          => 'POST',
                        p_body                 => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SEND_INDIVIDUAL_CAR_AUCTION_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_individual_car_auction',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_status  := APEX_WEB_SERVICE.g_status_code;
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE, REQUEST_BODY, URL)
        --     VALUES ('send_individual_car_auction_api', l_result, l_body, l_url);

        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     p_status := '-4';
        --     RETURN '-4';
        -- END IF;
    
        p_status  := APEX_WEB_SERVICE.g_status_code;
        p_message := l_result;
        RETURN '1';
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN SQLERRM;
    END send_individual_car_auction;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION dynamic_sql (
        p_fields     IN VARCHAR2,
        p_table      IN VARCHAR2,
        p_condition  IN VARCHAR2 DEFAULT NULL,
        p_populate   IN VARCHAR2 DEFAULT NULL,
        p_order_by   IN VARCHAR2 DEFAULT ' asc '
    ) RETURN SYS_REFCURSOR AS
        TYPE curtype IS  REF CURSOR;
        src_cur          curtype;
        v_stmt           VARCHAR2(32000);
        v_condition      VARCHAR2(500) := NULL;
        l_alias          APEX_T_VARCHAR2;
        l_tables         APEX_T_VARCHAR2;
        v_fields         VARCHAR2(5000);
        v_product_images VARCHAR2(5000) := NULL;
        v_images_columns VARCHAR2(5000) := NULL;
        v_rel_condition  VARCHAR2(5000) := NULL;
        v_group_by       VARCHAR2(5000) := NULL;
        v_order_by       VARCHAR2(10)    := NULL;
        v_car_columns    VARCHAR2(5000) := NULL;
        v_fields_without_alias      VARCHAR2(5000) := NULL;
        v_car_columns_without_alias VARCHAR2(5000) := NULL;
    BEGIN
        IF p_condition IS NOT NULL THEN
            v_condition := ' WHERE p.';
        END IF;

        IF UPPER(p_order_by) NOT IN ('ASC', 'DESC') OR p_order_by IS NULL THEN
            v_order_by := 'ASC';
        ELSE
            v_order_by := p_order_by;
        END IF;

        IF p_fields IS NULL THEN
            v_fields := 'p.ID,LOOKUPS_MNT.city_by_id(p_city_id => p.city_id) as city,LOOKUPS_MNT.category_by_id(p_category_id => p.category_id) as category,LOOKUPS_MNT.sub_category_by_id(p_sub_category_id => p.sub_category_id) as sub_category,
                         SELLER.seller_name (p_seller_id => p.SELLER_ID) as seller,p.STOCK_NO,p.NAME_AR,p.NAME_EN,p.DESCRIPTION_AR,p.DESCRIPTION_EN,p.NOTES_AR,p.NOTES_EN,p.ADDRESS_AR,p.ADDRESS_EN,p.MAIN_IMAGE_URL,
                         p.VIDEO_URL,p.MAP_URL,LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => p.TYPE_ID, p_lang => ''en'') TYPE,LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id =>p.WARRANTY_ID, p_lang => ''en'') as WARRANTY,
                         LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => p.STATUS, p_lang => ''en'') as STATUS,p.WARRANTY_NOTES_AR,p.WARRANTY_NOTES_EN,p.YOUTUBE_URL,p.OTHER_CATEGORY,p.REFERENCE_NO,p.IS_ACTIVE,
                         p.CREATED_BY, p.CREATED_DATE, p.MODIFIED_BY, p.MODIFIED_DATE';
            v_fields_without_alias := 'p.ID,LOOKUPS_MNT.city_by_id(p_city_id => p.city_id),LOOKUPS_MNT.category_by_id(p_category_id => p.category_id),LOOKUPS_MNT.sub_category_by_id(p_sub_category_id => p.sub_category_id),
                         SELLER.seller_name (p_seller_id => p.SELLER_ID),p.STOCK_NO,p.NAME_AR,p.NAME_EN,p.DESCRIPTION_AR,p.DESCRIPTION_EN,p.NOTES_AR,p.NOTES_EN,p.ADDRESS_AR,p.ADDRESS_EN,p.MAIN_IMAGE_URL,
                         p.VIDEO_URL,p.MAP_URL,LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => p.TYPE_ID, p_lang => ''en''),LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => p.WARRANTY_ID, p_lang => ''en''),
                         LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => p.STATUS, p_lang => ''en''),p.WARRANTY_NOTES_AR,p.WARRANTY_NOTES_EN,p.YOUTUBE_URL,p.OTHER_CATEGORY,p.REFERENCE_NO,p.IS_ACTIVE,
                         p.CREATED_BY,p.CREATED_DATE,p.MODIFIED_BY,p.MODIFIED_DATE';
        ELSE
            l_alias := APEX_STRING.split ( p_str => p_fields, p_sep => ',' );

            IF l_alias.count > 1 THEN
                FOR i IN 1 .. l_alias.count LOOP
                    l_alias(i) := 'p.' || l_alias(i) || ',';
                    v_fields := v_fields || l_alias(i);
                END LOOP;

                v_fields := SUBSTR(v_fields, 0, LENGTH(v_fields) - 1);
            ELSE
                v_fields := 'p.' || p_fields;
            END IF;
        END IF;

        IF upper(p_table) = 'PRODUCTS' THEN
            IF p_condition IS NULL THEN
                IF p_populate IS NULL THEN
                    v_images_columns := ',''[''||listagg(m.url, '','')||'']'' images_urls';
                    v_product_images := ', PRODUCT_IMAGES m ';
                    v_condition := ' WHERE p.ID = m.PRODUCT_ID(+) ';
                    IF p_fields IS NULL THEN
                        v_group_by := ' group by ' || v_fields_without_alias;
                    ELSE
                        v_group_by := ' group by ' || v_fields;
                    END IF;
                ELSIF upper(p_populate) = 'CAR_DETAILS' THEN
                    v_images_columns := ',''[''||listagg(m.url, '','')||'']'' images_urls';
                    v_car_columns :=    ',r.ID car_id,LOOKUPS_MNT.vehicle_make_by_id (p_vehicle_make_id => r.VEHICLE_MAKE_ID) vehicle_make,
                                        LOOKUPS_MNT.vehicle_model_by_id (p_vehicle_model_id => r.VEHICLE_MODEL_ID) vehicle_model,
                                        LOOKUPS_MNT.vehicle_color_by_id (p_vehicle_color_id => r.VEHICLE_EXTERNAL_COLOR_ID) vehicle_external_color,
                                        r.NOTES_AR NOTES,r.ODO_METER,r.IS_THERE_DOCUMENT,r.IS_THERE_INSPECTION,r.DOCUMENT_URL,r.INSPECTION_URL,
                                        r.YEAR,r.CHASSIS_NUMBER,r.IS_DROWNED,r.IS_BURNED,
                                        LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.TRANSMISSION_ID, p_lang => ''ar'') TRANSMISSION,
                                        r.FUEL_TYPE_ID FUEL_TYPE';
                    v_car_columns_without_alias := ',r.ID,LOOKUPS_MNT.vehicle_make_by_id (p_vehicle_make_id => r.VEHICLE_MAKE_ID),
                                        LOOKUPS_MNT.vehicle_model_by_id (p_vehicle_model_id => r.VEHICLE_MODEL_ID),
                                        LOOKUPS_MNT.vehicle_color_by_id (p_vehicle_color_id => r.VEHICLE_EXTERNAL_COLOR_ID),
                                        r.NOTES_AR,r.ODO_METER,r.IS_THERE_DOCUMENT,r.IS_THERE_INSPECTION,r.DOCUMENT_URL,r.INSPECTION_URL,
                                        r.YEAR,r.CHASSIS_NUMBER,r.IS_DROWNED,r.IS_BURNED,
                                        LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.TRANSMISSION_ID, p_lang => ''ar''),
                                        r.FUEL_TYPE_ID';
                    v_product_images := ', PRODUCT_IMAGES m, CAR_DETAILS r ';
                    v_condition := ' WHERE p.ID = m.PRODUCT_ID(+) AND p.ID = r.PRODUCT_ID(+) ';
                    IF p_fields IS NULL THEN
                        v_group_by := ' group by ' || v_fields_without_alias || v_car_columns_without_alias;
                    ELSE
                        v_group_by := ' group by ' || v_fields || v_car_columns_without_alias;
                    END IF;
                ELSIF upper(p_populate) = 'REAL_STATE_DETAILS' THEN
                    v_images_columns := ',''[''||listagg(m.url, '','')||'']'' images_urls';
                    v_car_columns :=    ',r.ID,r.PRODUCT_ID,LOOKUPS_MNT.neighbourhood_by_id (p_neighbourhood_id => r.NEIGHBOURHOODS_ID) AS NEIGHBOURHOOD,r.STREET_NAME_AR,r.STREET_NAME_EN,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.USAGE_ID, p_lang => ''ar'') AS USAGE,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.FACADE_ID, p_lang => ''ar'') AS FACADE,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.PROPERTY_TYPE_ID, p_lang => ''ar'') AS PROPERTY_TYPE,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.AD_SUB_TYPE_ID, p_lang => ''ar'') AS AD_SUB_TYPE,
                                            r.STREET_WIDTH,r.ADVERTISER_ID,r.ADVERTISER_LICENSE_NO,r.ADVERTISER_NAME_AR,r.ADVERTISER_NAME_EN,r.ADVERTISER_NO,r.SPACE,
                                            r.AUTH_NO,r.ADVERTISER_PHONE,r.INSTRUMENT_NO,r.CONSTRUCTION_DATE,r.IS_ACTIVE,r.CREATED_BY,r.CREATED_DATE,r.MODIFIED_BY,r.MODIFIED_DATE,r.THERE_MORTGAGE_AR,
                                            r.THERE_MORTGAGE_EN,r.RIGHTS_AND_OBLIGATIONS_AR,r.RIGHTS_AND_OBLIGATIONS_EN,r.INFORMATION_THAT_AFFECT_PROPERTY_AR,r.INFORMATION_THAT_AFFECT_PROPERTY_EN,
                                            r.GOVERNORATE,r.IS_THERE_MORTGAGE,r.IS_RIGHTS_AND_OBLIGATIONS,r.IS_INFORMATION_THAT_AFFECT_PROPERTY,r.METER_PRICE';
                    v_car_columns_without_alias := ',r.ID,r.PRODUCT_ID,LOOKUPS_MNT.neighbourhood_by_id (p_neighbourhood_id => r.NEIGHBOURHOODS_ID),r.STREET_NAME_AR,r.STREET_NAME_EN,
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.USAGE_ID, p_lang => ''ar''),
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.FACADE_ID, p_lang => ''ar''),
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.PROPERTY_TYPE_ID, p_lang => ''ar''),
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.AD_SUB_TYPE_ID, p_lang => ''ar''),
                                                    r.STREET_WIDTH,r.ADVERTISER_ID,r.ADVERTISER_LICENSE_NO,r.ADVERTISER_NAME_AR,r.ADVERTISER_NAME_EN,r.ADVERTISER_NO,r.SPACE,
                                                    r.AUTH_NO,r.ADVERTISER_PHONE,r.INSTRUMENT_NO,r.CONSTRUCTION_DATE,r.IS_ACTIVE,r.CREATED_BY,r.CREATED_DATE,r.MODIFIED_BY,r.MODIFIED_DATE,r.THERE_MORTGAGE_AR,
                                                    r.THERE_MORTGAGE_EN,r.RIGHTS_AND_OBLIGATIONS_AR,r.RIGHTS_AND_OBLIGATIONS_EN,r.INFORMATION_THAT_AFFECT_PROPERTY_AR,r.INFORMATION_THAT_AFFECT_PROPERTY_EN,
                                                    r.GOVERNORATE,r.IS_THERE_MORTGAGE,r.IS_RIGHTS_AND_OBLIGATIONS,r.IS_INFORMATION_THAT_AFFECT_PROPERTY,r.METER_PRICE';
                    v_product_images := ', PRODUCT_IMAGES m, REAL_STATE_DETAILS r ';
                    v_condition := ' WHERE p.ID = m.PRODUCT_ID(+) AND p.ID = r.PRODUCT_ID(+) ';
                    IF p_fields IS NULL THEN
                        v_group_by := ' group by ' || v_fields_without_alias || v_car_columns_without_alias;
                    ELSE
                        v_group_by := ' group by ' || v_fields || v_car_columns_without_alias;
                    END IF;
                END IF;
            ELSE
                IF p_populate IS NULL THEN
                    v_images_columns := ',''[''||listagg(m.url, '','')||'']'' images_urls';
                    v_product_images := ', PRODUCT_IMAGES m ';
                    v_rel_condition  := ' AND p.ID = m.PRODUCT_ID(+) ';
                    IF p_fields IS NULL THEN
                        v_group_by := ' group by ' || v_fields_without_alias;
                    ELSE
                        v_group_by := ' group by ' || v_fields;
                    END IF;
                ELSIF upper(p_populate) = 'CAR_DETAILS' THEN
                    v_images_columns := ',''[''||listagg(m.url, '','')||'']'' images_urls';
                    v_car_columns :=    ',r.ID car_id,LOOKUPS_MNT.vehicle_make_by_id (p_vehicle_make_id => r.VEHICLE_MAKE_ID) vehicle_make,
                                        LOOKUPS_MNT.vehicle_model_by_id (p_vehicle_model_id => r.VEHICLE_MODEL_ID) vehicle_model,
                                        LOOKUPS_MNT.vehicle_color_by_id (p_vehicle_color_id => r.VEHICLE_EXTERNAL_COLOR_ID) vehicle_external_color,
                                        r.NOTES_AR NOTES,r.ODO_METER,r.IS_THERE_DOCUMENT,r.IS_THERE_INSPECTION,r.DOCUMENT_URL,r.INSPECTION_URL,
                                        r.YEAR,r.CHASSIS_NUMBER,r.IS_DROWNED,r.IS_BURNED,
                                        LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.TRANSMISSION_ID, p_lang => ''ar'') TRANSMISSION,
                                        r.FUEL_TYPE_ID FUEL_TYPE';
                    v_car_columns_without_alias := ',r.ID,LOOKUPS_MNT.vehicle_make_by_id (p_vehicle_make_id => r.VEHICLE_MAKE_ID),
                                        LOOKUPS_MNT.vehicle_model_by_id (p_vehicle_model_id => r.VEHICLE_MODEL_ID),
                                        LOOKUPS_MNT.vehicle_color_by_id (p_vehicle_color_id => r.VEHICLE_EXTERNAL_COLOR_ID),
                                        r.NOTES_AR,r.ODO_METER,r.IS_THERE_DOCUMENT,r.IS_THERE_INSPECTION,r.DOCUMENT_URL,r.INSPECTION_URL,
                                        r.YEAR,r.CHASSIS_NUMBER,r.IS_DROWNED,r.IS_BURNED,
                                        LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.TRANSMISSION_ID, p_lang => ''ar''),
                                        r.FUEL_TYPE_ID';
                    v_product_images := ', PRODUCT_IMAGES m, CAR_DETAILS r ';
                    v_rel_condition  := ' AND p.ID = m.PRODUCT_ID(+) AND p.ID = r.PRODUCT_ID(+) ';
                    IF p_fields IS NULL THEN
                        v_group_by := ' group by ' || v_fields_without_alias || v_car_columns_without_alias;
                    ELSE
                        v_group_by := ' group by ' || v_fields || v_car_columns_without_alias;
                    END IF;
                ELSIF upper(p_populate) = 'REAL_STATE_DETAILS' THEN
                    v_images_columns := ',''[''||listagg(m.url, '','')||'']'' images_urls';
                    v_car_columns :=    ',r.ID,r.PRODUCT_ID,LOOKUPS_MNT.neighbourhood_by_id (p_neighbourhood_id => r.NEIGHBOURHOODS_ID) AS NEIGHBOURHOOD,r.STREET_NAME_AR,r.STREET_NAME_EN,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.USAGE_ID, p_lang => ''ar'') AS USAGE,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.FACADE_ID, p_lang => ''ar'') AS FACADE,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.PROPERTY_TYPE_ID, p_lang => ''ar'') AS PROPERTY_TYPE,
                                            LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.AD_SUB_TYPE_ID, p_lang => ''ar'') AS AD_SUB_TYPE,
                                            r.STREET_WIDTH,r.ADVERTISER_ID,r.ADVERTISER_LICENSE_NO,r.ADVERTISER_NAME_AR,r.ADVERTISER_NAME_EN,r.ADVERTISER_NO,r.SPACE,
                                            r.AUTH_NO,r.ADVERTISER_PHONE,r.INSTRUMENT_NO,r.CONSTRUCTION_DATE,r.IS_ACTIVE,r.CREATED_BY,r.CREATED_DATE,r.MODIFIED_BY,r.MODIFIED_DATE,r.THERE_MORTGAGE_AR,
                                            r.THERE_MORTGAGE_EN,r.RIGHTS_AND_OBLIGATIONS_AR,r.RIGHTS_AND_OBLIGATIONS_EN,r.INFORMATION_THAT_AFFECT_PROPERTY_AR,r.INFORMATION_THAT_AFFECT_PROPERTY_EN,
                                            r.GOVERNORATE,r.IS_THERE_MORTGAGE,r.IS_RIGHTS_AND_OBLIGATIONS,r.IS_INFORMATION_THAT_AFFECT_PROPERTY,r.METER_PRICE';
                    v_car_columns_without_alias := ',r.ID,r.PRODUCT_ID,LOOKUPS_MNT.neighbourhood_by_id (p_neighbourhood_id => r.NEIGHBOURHOODS_ID),r.STREET_NAME_AR,r.STREET_NAME_EN,
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.USAGE_ID, p_lang => ''ar''),
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.FACADE_ID, p_lang => ''ar''),
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.PROPERTY_TYPE_ID, p_lang => ''ar''),
                                                    LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.AD_SUB_TYPE_ID, p_lang => ''ar''),
                                                    r.STREET_WIDTH,r.ADVERTISER_ID,r.ADVERTISER_LICENSE_NO,r.ADVERTISER_NAME_AR,r.ADVERTISER_NAME_EN,r.ADVERTISER_NO,r.SPACE,
                                                    r.AUTH_NO,r.ADVERTISER_PHONE,r.INSTRUMENT_NO,r.CONSTRUCTION_DATE,r.IS_ACTIVE,r.CREATED_BY,r.CREATED_DATE,r.MODIFIED_BY,r.MODIFIED_DATE,r.THERE_MORTGAGE_AR,
                                                    r.THERE_MORTGAGE_EN,r.RIGHTS_AND_OBLIGATIONS_AR,r.RIGHTS_AND_OBLIGATIONS_EN,r.INFORMATION_THAT_AFFECT_PROPERTY_AR,r.INFORMATION_THAT_AFFECT_PROPERTY_EN,
                                                    r.GOVERNORATE,r.IS_THERE_MORTGAGE,r.IS_RIGHTS_AND_OBLIGATIONS,r.IS_INFORMATION_THAT_AFFECT_PROPERTY,r.METER_PRICE';
                    v_product_images := ', PRODUCT_IMAGES m, REAL_STATE_DETAILS r ';
                    v_rel_condition  := ' AND p.ID = m.PRODUCT_ID(+) AND p.ID = r.PRODUCT_ID(+) ';
                    IF p_fields IS NULL THEN
                        v_group_by := ' group by ' || v_fields_without_alias || v_car_columns_without_alias;
                    ELSE
                        v_group_by := ' group by ' || v_fields || v_car_columns_without_alias;
                    END IF;
                ELSE
                    v_images_columns := ',''[''||listagg(m.url, '','')||'']'' images_urls';
                    v_product_images := ', PRODUCT_IMAGES m ';
                    v_rel_condition  := ' AND p.ID = m.PRODUCT_ID(+) ';
                    IF p_fields IS NULL THEN
                        v_group_by := ' group by ' || v_fields_without_alias;
                    ELSE
                        v_group_by := ' group by ' || v_fields;
                    END IF;
                END IF;
            END IF;
        END IF;

        v_stmt := 'SELECT ' || v_fields || v_images_columns || v_car_columns ||
                  ' FROM ' || p_table || ' p ' || v_product_images ||
                  v_condition || p_condition || v_rel_condition || v_group_by ||
                  ' ORDER BY ID ' || v_order_by;

    dbms_output.put_line(v_stmt);
        OPEN src_cur FOR v_stmt;
        RETURN src_cur;

    -- EXCEPTION
    --     WHEN OTHERS THEN
    --         RETURN sqlerrm;
    END dynamic_sql;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION dynamic_sql_v2 (
        p_fields IN VARCHAR2,
        p_table  IN VARCHAR2
    ) RETURN CLOB
      IS
        CURSOR src_cur IS SELECT * FROM EMP;
        v_sql     VARCHAR2(32000);
        v_column  VARCHAR2(32000);
        header    json_object_t;
        items     json_object_t;
        j_array_a json_array_t;
    BEGIN
        items  := json_object_t();
        header := json_object_t();
        j_array_a := json_array_t();

        v_sql :=  p_fields || ',';
    /*
    SELECT 'application/json' , dynamic_sql_v2(p_fields => 'EMPNO,ENAME,HIREDATE' , p_table => 'emp') from dual
    */
        FOR i IN src_cur
        LOOP
            FOR j IN ( SELECT column_name FROM user_tab_columns WHERE table_name = 'EMP' ) LOOP
                v_column := j.column_name;

                IF INSTR(v_sql , j.column_name) > 0 THEN
                    items.put(j.column_name, v_column);
                END IF;
            END LOOP;

            -- IF INSTR(v_sql , 'ENAME,') > 0 THEN
            --     items.put('ENAME', i.ENAME);
            -- END IF;

            j_array_a.append( items); 
            items := json_object_t();
        END LOOP;

        header.put('items' ,j_array_a);
        RETURN header.to_clob(); 

    EXCEPTION
        WHEN OTHERS THEN 
            header.put('items', sqlerrm);
            header.put('message', sqlerrm);
            RETURN header.to_clob(); 
    END dynamic_sql_v2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION columns_names (
        p_table IN VARCHAR2
    ) RETURN CLOB AS
        TYPE columns_names IS RECORD ( name VARCHAR2(255) );
        TYPE cols_names IS TABLE OF columns_names INDEX BY PLS_INTEGER;
        cols cols_names;
        j_array json_array_t;
    BEGIN
        j_array := json_array_t();

        EXECUTE IMMEDIATE 'SELECT column_name FROM user_tab_columns WHERE UPPER(table_name) = UPPER( ''' || p_table || ''' )'
            BULK COLLECT INTO cols;

        FOR i IN 1..cols.count LOOP
            j_array.append(cols(i).name);
        END LOOP;

        RETURN j_array.to_clob();
    END columns_names;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION products (
        p_id IN VARCHAR2 DEFAULT NULL
    ) RETURN CLOB AS
        header      json_object_t;
        realestate  json_object_t;
        product     json_object_t;
        j_array     json_array_t;
    BEGIN
        header      := json_object_t();
        realestate  := json_object_t();
        product     := json_object_t();
        j_array     := json_array_t();

        FOR i IN (
            SELECT p.ID, p.NAME_AR, p.MAIN_IMAGE_URL, r.INSTRUMENT_NO, r.SPACE,
                   LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.USAGE_ID, p_lang => 'ar') AS USAGE,
                   LOOKUPS_MNT.lookup_detail_name_by_id (p_lookup_detail_id => r.PROPERTY_TYPE_ID, p_lang => 'ar') AS TYPE,
                   (SELECT NAME_AR FROM NEIGHBOURHOODS WHERE ID = r.NEIGHBOURHOODS_ID) AS NEIGHBOURHOOD
              FROM PRODUCTS p, REAL_STATE_DETAILS r
             WHERE p.ID = r.PRODUCT_ID)
        LOOP
            -- REAL-ESTATE object
            realestate.put('sakNo',              i.INSTRUMENT_NO);
            realestate.put('theSpace',           i.SPACE);
            realestate.put('usingFor',           i.USAGE);
            realestate.put('propertyType',       i.TYPE);
            realestate.put('neighbourhood',      i.NEIGHBOURHOOD);

            -- MAIN object
            product.put('id',                i.ID);
            product.put('name',              i.NAME_AR);
            product.put('mainImageUrl',      i.MAIN_IMAGE_URL);
            product.put('realEstateDetails', realestate);

            -- j_array.append(product);
            realestate  := json_object_t();
            product     := json_object_t();
        END LOOP;
        
        -- header.put('items', j_array);
        header.put('items', product);
        RETURN header.to_clob();
    END products;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION services_agent_request (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT VARCHAR2
    ) RETURN NUMBER IS
        v_request_id            VARCHAR2(255);
        v_buyer_id              VARCHAR2(255);
        v_agent_id              VARCHAR2(255);
        v_product_name          VARCHAR2(255);
        v_vin_number            VARCHAR2(255);
        v_plate_number          VARCHAR2(255);
        v_year                  VARCHAR2(255);
        v_image_url             VARCHAR2(4000);
        v_buyer_nid_url         VARCHAR2(4000);
        v_seller_form_url       VARCHAR2(4000);
        v_seller_waiver_url     VARCHAR2(4000);
        v_seller_delegation_url VARCHAR2(4000);
        v_count                 NUMBER;
    BEGIN
        IF p_body IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        APEX_JSON.parse(p_body);

        v_request_id            := APEX_JSON.get_varchar2('id');
        v_buyer_id              := APEX_JSON.get_varchar2('buyer');
        v_agent_id              := APEX_JSON.get_varchar2('agent');
        v_product_name          := APEX_JSON.get_varchar2('product_name');
        v_vin_number            := APEX_JSON.get_varchar2('vin_number');
        v_plate_number          := APEX_JSON.get_varchar2('plate_number');
        v_year                  := APEX_JSON.get_varchar2('year');
        v_image_url             := APEX_JSON.get_varchar2('image_url');
        v_buyer_nid_url         := APEX_JSON.get_varchar2('buyer_nid_url');
        v_seller_form_url       := APEX_JSON.get_varchar2('seller_form_url');
        v_seller_waiver_url     := APEX_JSON.get_varchar2('seller_waiver_url');
        v_seller_delegation_url := APEX_JSON.get_varchar2('seller_delegation_url');

        SELECT COUNT(1)
          INTO v_count
          FROM SERVICES_AGENT_REQUESTS
         WHERE VIN_NUMBER = v_vin_number;

        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'vin_number_exists', p_lang => p_lang);
            RETURN -3;
        END IF;

        INSERT INTO SERVICES_AGENT_REQUESTS (
            REQUEST_ID, BUYER_ID, AGENT_ID, PRODUCT_NAME, VIN_NUMBER, PLATE_NUMBER, YEAR, BUYER_NID_URL, SELLER_FORM_URL, SELLER_WAIVER_URL, SELLER_DELEGATION_URL, IMAGE_URL
        ) VALUES (
            TO_NUMBER(v_request_id), TO_NUMBER(v_buyer_id), TO_NUMBER(v_agent_id), v_product_name, v_vin_number, v_plate_number, v_year, v_buyer_nid_url, v_seller_form_url, v_seller_waiver_url,
            v_seller_delegation_url, v_image_url
        );
         
        IF SQL%rowcount = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'insertion_error', p_lang => p_lang);
            RETURN 0;
        END IF;
        
        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN 1;
    EXCEPTION
        WHEN OTHERS THEN  
            RETURN 0;
    END services_agent_request;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_services_agent_file (
        p_body       IN CLOB,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    CLOB;
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url  := 'https://ed38-188-51-162-33.ngrok-free.app/apex/transferResult';
        -- l_url  := 'https://backend-master.mobasher.sa/apex/vehicle';
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_url,
                        p_http_method          => 'PUT',
                        p_body                 => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SEND_SERVICES_AGENT_FILE_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_services_agent_file',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE, REQUEST, URL)
        --     VALUES ( 'send_services_agent_file_api', l_result, l_body, l_url);

        p_message := l_result;
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN l_result;
    END send_services_agent_file;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_vehicle_images (
        p_body       IN CLOB,
        p_seller_id  IN NUMBER,
        p_product_id IN NUMBER,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT CLOB
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    CLOB;
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url  := 'https://backend-master.mobasher.sa/products/' || p_seller_id || '/' || p_product_id;
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_url,
                        p_http_method          => 'PATCH',
                        p_body                 => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'SEND_VEHICLE_IMAGES_API',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.send_vehicle_images',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME, RESPONSE, REQUEST, URL)
        --     VALUES ( 'send_vehicle_images_api', l_result, l_body, l_url);

        p_message := SUBSTR(l_result, 1, 4000) || ' - ' || l_url;
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN SUBSTR(l_result, 1, 4000);
    END send_vehicle_images;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION auction_containers (
        p_seller_id     IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT CLOB
    ) RETURN CLOB IS
        v_url       VARCHAR2(2000);
        l_clob      CLOB;
    BEGIN
        v_url := 'https://sandbox.mobasher.sa/api/v2/auction-containers/seller/' || p_seller_id;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_url,
                    p_http_method => 'GET'
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SYSTEM_INTEGRATION.auction_containers', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := l_clob || ' - Status: ' || apex_web_service.g_status_code;
            RETURN '-100003';
        END IF;

        p_message := SUBSTR(l_clob, 1, 4000);
        RETURN '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN l_clob;
    END auction_containers;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION auction_container_details (
        p_auction_id    IN VARCHAR2,
        p_seller_id     IN VARCHAR2,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT CLOB
    ) RETURN CLOB IS
        v_url               VARCHAR2(2000);
        l_clob              CLOB;
    BEGIN
        IF p_auction_id IS NULL OR p_seller_id IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        v_url := 'https://sandbox.mobasher.sa/api/v2/auction-containers/seller/'|| p_seller_id ||'/'|| p_auction_id;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_url,
                    p_http_method => 'GET'
                );
        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SYSTEM_INTEGRATION.auction_container_details', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := l_clob || ' - Status: ' || apex_web_service.g_status_code;
            RETURN '-100003';
        END IF;

        p_message := SUBSTR(l_clob, 1, 4000);
        RETURN '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN l_clob;
    END auction_container_details;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_auction_container (
        p_auction_id    IN VARCHAR2,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT CLOB
    ) RETURN CLOB IS
        v_url               VARCHAR2(2000);
        l_clob              CLOB;
    BEGIN
        IF p_auction_id IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        v_url := 'https://sandbox.mobasher.sa/api/v2/auction//container/'|| p_auction_id;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_clob := apex_web_service.make_rest_request( 
                    p_url         => v_url,
                    p_http_method => 'DELETE'
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SYSTEM_INTEGRATION.delete_auction_container', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := l_clob || ' - Status: ' || apex_web_service.g_status_code;
            RETURN '-100003';
        END IF;

        p_message := SUBSTR(l_clob, 1, 4000);
        RETURN '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN l_clob;
    END delete_auction_container;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION urway (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT CLOB
    ) RETURN CLOB AS
        l_clob  CLOB;
        l_url   VARCHAR2(2000);
    BEGIN
        l_url  := 'https://payments-dev.urway-tech.com/URWAYPGService/transaction/jsonProcess/JSONrequest';

        apex_web_service.g_request_headers.delete;
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_clob := APEX_WEB_SERVICE.make_rest_request (
                          p_url         => l_url,
                          p_http_method => 'POST',
                          p_body        => p_body
                    );
        
        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SYSTEM_INTEGRATION.urway', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || l_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := l_clob || ' - Status: ' || apex_web_service.g_status_code;
            RETURN '-100003';
        END IF;

        p_message := SUBSTR(l_clob, 1, 4000);
        RETURN '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN l_clob;
    END urway;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION urway_integration (
        p_body      IN CLOB,
        p_lang      IN VARCHAR2 DEFAULT 'en',
        p_message  OUT CLOB
    ) RETURN CLOB AS
        l_clob  CLOB;
        l_url   VARCHAR2(2000);
    BEGIN
        l_url  := 'https://backend-master.mobasher.sa/payment/requestpayment';

        apex_web_service.g_request_headers.delete;
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_clob := APEX_WEB_SERVICE.make_rest_request (
                          p_url         => l_url,
                          p_http_method => 'POST',
                          p_body        => p_body
                    );
        
        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SYSTEM_INTEGRATION.urway_integration', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || l_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );
            p_message := l_clob || ' - Status: ' || apex_web_service.g_status_code;
            RETURN '-100003';
        END IF;

        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'urway_integration_api', p_message, p_body, l_url);
        
        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;

        p_message := SUBSTR(l_clob, 1, 4000);
        RETURN '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN l_clob;
    END urway_integration;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION inspection_details (
        p_vin_number    IN NUMBER,
        p_lang          IN VARCHAR2 DEFAULT 'en',
        p_message      OUT CLOB
    ) RETURN CLOB AS
        l_clob  CLOB;
        l_url   VARCHAR2(2000);
    BEGIN
        p_message := l_clob;
        RETURN '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM; 
            RETURN l_clob;
    END inspection_details;


--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION individual_realestate_seller_assign (
        p_body       IN CLOB,
        p_id         IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        -- l_url := 'https://0452-188-54-161-147.ngrok-free.app/' || p_id;
        l_url := 'https://backend-master.mobasher.sa/products/' || p_id;
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'PUT',
                        p_body              => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'INDIVIDUAL_REALESTATE_SELLER_ASSIGN',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.individual_realestate_seller_assign',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;
        
        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'individual_realestate_seller_assign', l_result, l_body, l_url);
        
        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN SUBSTR(l_result, 1, 4000);

    END individual_realestate_seller_assign;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION nafith (
        p_id          IN VARCHAR2,
        p_buyer_id    IN VARCHAR2,
        p_total_price IN VARCHAR2,
        p_token       IN VARCHAR2,
        p_lang        IN VARCHAR2 DEFAULT 'ar',
        p_message     OUT CLOB,
        p_status      OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	      VARCHAR2(32700);
        l_body        VARCHAR2(32700);
        l_result      CLOB;
        v_status_code VARCHAR2(32700);
        v_status_msg  VARCHAR2(32700);
    BEGIN
        IF p_id IS NULL OR p_buyer_id IS NULL OR p_total_price IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://backend-master.mobasher.sa/wallets';
        -- l_url := 'https://demo.backend.mobasher.sa/wallets';

        l_body := '{
                    "auctionId":"'|| p_id ||'",
                    "auctionType":"BUYER_VEHICLE",
                    "moneyMovementType":"OUT",
                    "totalPrice":'|| p_total_price ||',
                    "insuranceType":"NAFITH",
                    "usedFor":"BUYER_VEHICLE",
                    "buyer":'|| p_buyer_id ||'
                }';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';
        apex_web_service.g_request_headers(2).name  := 'Authorization';
        apex_web_service.g_request_headers(2).value := 'Bearer ' || p_token;

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'POST',
                        p_body              => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'NAFITH',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.nafith',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;
        
        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'nafith', l_result, l_body, l_url);
        
        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;

        p_status := APEX_WEB_SERVICE.g_status_code;
        p_message := l_result;
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN SUBSTR(l_result, 1, 4000);
    END nafith;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION sned_SMS (
        p_body          IN CLOB,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://backend-master.mobasher.sa/sendSms';
        -- l_url := 'https://demo.backend.mobasher.sa/sendSms';

        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'POST',
                        p_body              => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'sned_SMS',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.sned_SMS',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;
        
        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'sned_SMS', l_result, l_body, l_url);
        
        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN SUBSTR(l_result, 1, 4000);
    END sned_SMS;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION individual_auction_update_status (
        p_body          IN CLOB,
        p_lang          IN VARCHAR2 DEFAULT 'ar',
        p_message      OUT VARCHAR2
    ) RETURN CLOB AS
        l_auction_name  VARCHAR2(2000);
        l_auction_link  VARCHAR2(2000);
        l_status        VARCHAR2(2000);
        l_product_id    VARCHAR2(2000);
        l_category      VARCHAR2(2000);
        l_reject_reason VARCHAR2(2000);
        v_seller_id     NUMBER;
        v_request_id     NUMBER;
    BEGIN
        APEX_JSON.parse(p_body);

        l_auction_name  := APEX_JSON.get_varchar2('auctionName');
        l_auction_link  := APEX_JSON.get_varchar2('auctionLink');
        l_status        := APEX_JSON.get_varchar2('status');
        l_product_id    := APEX_JSON.get_varchar2('productID');
        l_category      := APEX_JSON.get_varchar2('category');
        -- l_reject_reason := APEX_JSON.get_varchar2('l_reject_reason');

        IF l_category = 'REAL_ESTATES' THEN
            IF l_status = 'ON_AUCTION' THEN
                UPDATE INDIVIDUAL_REALESTATE_REQUESTS
                   SET PROGRESS_STATUS      = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'publish_auction', p_lookup_code => 'individual_auction_progress'),
                       STATUS               = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_done', p_lookup_code => 'individual_request_status')
                 WHERE RES_PRODUCT_ID       = l_product_id;
                
                IF SQL%ROWCOUNT = 0 THEN
                    p_message := '03,' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                    RETURN '-3';
                END IF;
            END IF;

            UPDATE PRODUCTS
               SET STATUS = DECODE(l_status,
                                        'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'available', p_lookup_code => 'product_status'),
                                        'UNASSIGNED', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'available', p_lookup_code => 'product_status'),
                                        'ON_AUCTION', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'on_auction', p_lookup_code => 'product_status'),
                                        'SOLD', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'sold', p_lookup_code => 'product_status'),
                                        'OFFER', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'offer', p_lookup_code => 'product_status'),
                                        'PAYMENT_PENDING', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'payment_pending', p_lookup_code => 'product_status')
                                    )
             WHERE ID IN (SELECT PRODUCT_ID FROM INDIVIDUAL_REALESTATE_REQUESTS WHERE RES_PRODUCT_ID = l_product_id);

            IF SQL%ROWCOUNT = 0 THEN
                p_message := '04,' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                RETURN '-4';
            END IF;
        ELSE
            IF l_status = 'ON_AUCTION' THEN
                UPDATE INDIVIDUAL_PORTABLE_REQUESTS
                   SET AUCTION_NAME = l_auction_name,
                       AUCTION_LINK = l_auction_link,
                       AUCTION_ID   = extract_number(AUCTION_LINK),
                       PROGRESS_STATUS = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'publish_auction', p_lookup_code => 'individual_auction_progress'),
                       AFTER_APPROVAL_STATUS = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'auction_published', p_lookup_code => 'individual_portable_status'),
                       REQUEST_STATUS = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'done', p_lookup_code => 'individuals_auctions_status'),
                       STATUS = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_done', p_lookup_code => 'individual_request_status'),
                       IS_PRICE_EDITABLE = 0,
                       IS_EDITABLE = 0
                 WHERE RES_PRODUCT_ID = l_product_id;

                IF SQL%ROWCOUNT = 0 THEN
                    p_message := '05, ' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                    RETURN '-5';
                END IF;
            END IF;

            UPDATE PRODUCTS
               SET STATUS = DECODE(l_status,
                                        'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'available', p_lookup_code => 'product_status'),
                                        'ON_AUCTION', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'on_auction', p_lookup_code => 'product_status'),
                                        'SOLD', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'sold', p_lookup_code => 'product_status'),
                                        'OFFER', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'offer', p_lookup_code => 'product_status'),
                                        'PAYMENT_PENDING', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'payment_pending', p_lookup_code => 'product_status')
                                    )
             WHERE ID IN (SELECT PRODUCT_ID FROM INDIVIDUAL_PORTABLE_REQUESTS WHERE RES_PRODUCT_ID = l_product_id);

            IF SQL%ROWCOUNT = 0 THEN
                p_message := '06, ' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                RETURN '-6';
            END IF;
        END IF;

        p_message := 'Success';
        RETURN '1';
    --     l_auction_name  VARCHAR2(2000);
    --     l_auction_link  VARCHAR2(2000);
    --     l_status        VARCHAR2(2000);
    --     l_category      VARCHAR2(2000);
    --     l_product_id    VARCHAR2(2000);
    -- BEGIN
    --     APEX_JSON.parse(p_body);

    --     l_auction_name := APEX_JSON.get_varchar2('auctionName');
    --     l_auction_link := APEX_JSON.get_varchar2('auctionLink');
    --     l_status       := APEX_JSON.get_varchar2('status');
    --     l_product_id   := APEX_JSON.get_varchar2('productID');
    --     -- l_status       := APEX_JSON.get_varchar2('category');

    --     UPDATE INDIVIDUAL_PORTABLE_REQUESTS
    --        SET AUCTION_NAME = l_auction_name,
    --            AUCTION_LINK = l_auction_link,
    --            PROGRESS_STATUS = DECODE(l_status,
    --                                 'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'final_request_approval', p_lookup_code => 'individual_auction_progress'),
    --                                 LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'publish_auction', p_lookup_code => 'individual_auction_progress')),
    --            AFTER_APPROVAL_STATUS = DECODE(l_status,
    --                                     'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'wainting_publish', p_lookup_code => 'individual_portable_status'),
    --                                     LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'auction_published', p_lookup_code => 'individual_portable_status')),
    --            REQUEST_STATUS = DECODE(l_status,
    --                                     'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'wokring_on', p_lookup_code => 'individuals_auctions_status'),
    --                                     LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'done', p_lookup_code => 'individuals_auctions_status')),
    --            STATUS = DECODE(l_status,
    --                                     'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_approved', p_lookup_code => 'individual_request_status'),
    --                                     LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_done', p_lookup_code => 'individual_request_status')),
    --             IS_PRICE_EDITABLE = 0,
    --             IS_EDITABLE = 0
    --      WHERE RES_PRODUCT_ID = l_product_id;

    --     IF SQL%ROWCOUNT = 0 THEN
    --         p_message := 'Updation auction details error';
    --         RETURN '-2';
    --     END IF;

    --     UPDATE PRODUCTS
    --        SET STATUS = DECODE(l_status,
    --                                 'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'available', p_lookup_code => 'product_status'),
    --                                 'ON_AUCTION', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'on_auction', p_lookup_code => 'product_status'),
    --                                 'SOLD', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'sold', p_lookup_code => 'product_status'),
    --                                 'OFFER', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'offer', p_lookup_code => 'product_status'),
    --                                 'PAYMENT_PENDING', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'payment_pending', p_lookup_code => 'product_status')
    --                             )
    --      WHERE ID IN (SELECT PRODUCT_ID FROM INDIVIDUAL_PORTABLE_REQUESTS WHERE RES_PRODUCT_ID = l_product_id);

    --     IF SQL%ROWCOUNT = 0 THEN
    --         p_message := 'Updating product status error';
    --         RETURN '-3';
    --     END IF;

    --     p_message := 'Success';
    --     RETURN '1';

    END individual_auction_update_status;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION upload (
        p_blob          IN BLOB,
        p_auth          IN VARCHAR2,
        p_mimetype      IN VARCHAR2,
        p_product_name  IN VARCHAR2,
        p_product_id    IN NUMBER
    ) RETURN VARCHAR2 IS
        g_oci_base_url      CONSTANT VARCHAR2(1000) := 'https://objectstorage.me-jeddah-1.oraclecloud.com/n/axax2vam4edg';
        l_file_name         VARCHAR2(255);
        l_request_url	    VARCHAR2(32767);
        l_count	            NUMBER;
        l_result	        CLOB;
        l_request_id        NUMBER := 2;
        l_product_id        NUMBER := 1;
        l_buyer_phone       NUMBER;
        l_message           VARCHAR2(1000);
        sms_object          json_object_t;
    BEGIN
        sms_object := json_object_t();

        IF p_blob IS NULL OR p_auth IS NULL OR p_mimetype IS NULL OR p_product_name IS NULL OR p_product_id IS NULL THEN
            RETURN 'Missing Data!';
        END IF;

        SELECT count(1)
          INTO l_count
          FROM API_AUTHENTICATOR
         WHERE API_KEY = p_auth
           AND SYSDATE BETWEEN GENERATED_DATE AND EXPIRED_DATE;

        IF l_count <> 1 THEN
            RETURN 'Invalid or Expired Token!';
        END IF;

        l_file_name := TO_CHAR(get_current_date, 'YY') 
                            || DBMS_RANDOM.STRING('x', 8)
                            || SYSTEM_CONTROLS.file_extension_by_mimetype(p_mimetype => p_mimetype);

        l_request_url := g_oci_base_url || '/b/individual_portables/o/' || l_file_name;
        
        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url                  => l_request_url,
                        p_http_method          => 'PUT',
                        p_body_blob            => p_blob,
                        p_credential_static_id => 'OCI_AUTH'
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS ( p_error_type    => 'SYSTEM_ERROR',
                                                 p_PROCESS_NAME => 'OCI_OS.put_object',
                                                 p_error_code    => -2,
                                                 p_error_message => SUBSTR(l_result, 1, 4000),
                                                 p_logger_name   => 'Mobasher Upload'
                                            );
            RAISE_APPLICATION_ERROR(-20001, 'Error with uploading Data!');
        END IF;

        SELECT id, product_id, buyer_phone
          INTO l_request_id, l_product_id, l_buyer_phone
          FROM individual_portable_requests
         WHERE res_product_id = p_product_id;

        INSERT INTO INDIVIDUAL_PORTABLE_SOLD (REQUEST_ID, PRODUCT_ID, PRODUCT_NAME, INVOICE_URL)
            VALUES (l_request_id, l_product_id, 'p_product_name', l_request_url);
        
        IF SQL%ROWCOUNT = 0 THEN
            RETURN 'Error during insert the data';
        END IF;

        -- NOTIFY THE SELLER THAT THE BUYER UPLOAD THE INVOICE
        sms_object.put('to',  '+9660' || TRIM(l_buyer_phone));
        sms_object.put('msg', 'إشعار بتحديث حالة مزادك بأنه تم الدفع من قبل المشتري وإرفاق الفاتورة، لمعرفة العرض الرجاء زيارة منصة مباشر');

        l_result := SYSTEM_INTEGRATION.sned_SMS (
                    p_body      => sms_object.to_clob(),
                    p_message   => l_message
                );
        sms_object := json_object_t();

        RETURN l_request_url;
    END upload;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION individual_republish_allowed (
        p_body       IN CLOB,
        p_id         IN VARCHAR2,
        p_lang       IN VARCHAR2 DEFAULT 'ar',
        p_message   OUT VARCHAR2
    ) RETURN CLOB AS
        l_url	  VARCHAR2(2000);
        l_body    VARCHAR2(32700);
        l_result  CLOB;
    BEGIN
        IF p_body IS NULL THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;
        -- l_url := 'https://demo.backend.mobasher.sa/products/' || p_id;
        l_url := 'https://backend-master.mobasher.sa/products/' || p_id;
        l_body := p_body;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'PUT',
                        p_body              => l_body
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'individual_auction_update_status_after_republish_allowed',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.individual_auction_update_status_after_republish_allowed',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;
        
        -- INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
        --     VALUES ( 'individual_auction_update_status_after_republish_allowed', l_result, l_body, l_url);
        
        -- IF SQL%ROWCOUNT = 0 THEN
        --     p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
        --     RETURN '-4';
        -- END IF;
    
        p_message := SUBSTR(l_result, 1, 4000);
        RETURN '1';

    EXCEPTION
        WHEN OTHERS THEN
            RETURN SUBSTR(l_result, 1, 4000);

    END individual_republish_allowed;


--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION check_payment_status (
        p_track_id  IN VARCHAR2,
        p_message  OUT CLOB
    ) RETURN CLOB AS
        l_url	  VARCHAR2(5000);
        l_result  CLOB;
    BEGIN
        IF p_track_id IS NULL THEN
            p_message := 'Missing data';
            RETURN '-2';
        END IF;

        l_url := 'https://demo.backend.mobasher.sa/payment/checkpayment/' || p_track_id;

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name  := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        l_result := APEX_WEB_SERVICE.make_rest_request (
                        p_url               => l_url,
                        p_http_method       => 'GET'
                    );

        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.ERROR_LOGS( p_ERROR_TYPE => 'check_payment_status',
                                        p_PROCESS_NAME => 'SYSTEM_INTEGRATION.check_payment_status',
                                        p_ERROR_CODE => -2,
                                        p_ERROR_MESSAGE => SUBSTR(l_result, 1, 4000),
                                        p_OBJECT_TYPE => p_message,
                                        p_logger_name => USER
                                    );
            p_message := SUBSTR(l_result, 1, 4000) || ' - Status: ' || APEX_WEB_SERVICE.g_status_code;
            RETURN '-3';
        END IF;
        
        INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE,REQUEST_BODY, URL)
            VALUES ( 'check_payment_status', l_result, p_track_id, l_url);
        
        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => 'en');
            RETURN '-4';
        END IF;
    
        p_message := l_result;
        RETURN '1';
    END check_payment_status;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END "SYSTEM_INTEGRATION";
/