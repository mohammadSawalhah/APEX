
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."SYSTEM_CONTROLS" AS   
    
    g_debug_user    NUMBER;
    g_user_id       NUMBER;

    PROCEDURE set_debug_user;

    FUNCTION p_shared_key RETURN VARCHAR2;

    FUNCTION get_translation (    
        p_code  VARCHAR2,   
        p_lang  VARCHAR2   
    ) RETURN VARCHAR2;

    FUNCTION distance (   
        Lat1 IN NUMBER,   
        Lon1 IN NUMBER,   
        Lat2 IN NUMBER,   
        Lon2 IN NUMBER,   
        Radius IN NUMBER DEFAULT 3963   
    ) RETURN NUMBER;

    FUNCTION get_distance (   
        lat1    IN  NUMBER,   
        lon1    IN  NUMBER,   
        lat2    IN  NUMBER,   
        lon2    IN  NUMBER,   
        radius  IN  NUMBER DEFAULT 3963   
    ) RETURN NUMBER;

    FUNCTION PARSE_XML (   
        p_xml         IN VARCHAR2,   
        P_ELEMENT     IN VARCHAR2,    
        P_ONLY_UPPER  IN NUMBER DEFAULT 1   
    ) RETURN VARCHAR2;  

    PROCEDURE ERROR_LOGS (   
        p_ERROR_TYPE        IN VARCHAR2,   
        p_PROCESS_NAME      IN VARCHAR2,   
        p_ERROR_CODE        IN VARCHAR2,   
        p_ERROR_MESSAGE     IN VARCHAR2,   
        p_LOGGER_NAME       IN VARCHAR2 DEFAULT NULL ,    
        p_OBJECT_TYPE       IN VARCHAR2 DEFAULT NULL ,    
        p_OBJECT_ID         IN VARCHAR2 DEFAULT NULL    
    );

    PROCEDURE RUN_JOB;

    FUNCTION unix_to_date( 
        p_unix_sec NUMBER 
    ) RETURN DATE;

    FUNCTION date_to_unix( 
        p_date DATE 
    ) RETURN NUMBER;

    FUNCTION email_validation( 
        p_email VARCHAR2 
    ) RETURN NUMBER;

    FUNCTION file_extension_by_mimetype ( 
        p_mimetype   VARCHAR2 
    ) RETURN VARCHAR2;

    FUNCTION population (
        p_database_action VARCHAR2,
        p_table_name      VARCHAR2,
        p_params          VARCHAR2 DEFAULT NULL,
        p_condition       VARCHAR2 DEFAULT NULL
    ) RETURN CLOB;

    FUNCTION get_date (
        p_lang   IN VARCHAR2 DEFAULT 'Arabic'
    ) RETURN VARCHAR;

    FUNCTION get_day (
        p_date varchar2,
        p_lang   IN VARCHAR2 DEFAULT 'Arabic'
    ) RETURN VARCHAR;

    FUNCTION send_email ( 
        p_to       IN VARCHAR2,
        p_subject  IN VARCHAR2 DEFAULT 'إشعار بإسناد مهمة جديدة',
        p_html     IN VARCHAR2,
        p_lang     IN VARCHAR2 DEFAULT 'en',
        p_message OUT VARCHAR2
    ) RETURN NUMBER;

    FUNCTION base_url (
        p_is_lab    NUMBER DEFAULT 1,
        p_provider  VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION UPLOAD (
        p_item        IN VARCHAR2, 
        p_bucket_name IN VARCHAR2, 
        p_is_required IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION random_str (
        v_length    NUMBER DEFAULT 100
    ) RETURN VARCHAR2;

END SYSTEM_CONTROLS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."SYSTEM_CONTROLS" AS

    PROCEDURE set_debug_user AS 
    BEGIN 
        g_debug_user := 'app_debug_user'; 
    END set_debug_user;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION p_shared_key  RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Ftjj#-ddtrum5261_gfRdCXooO#165?*234sEEd';
    END p_shared_key;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION get_translation (  
        p_code  VARCHAR2,   
        p_lang  VARCHAR2   
    ) RETURN VARCHAR2 AS   
        v_msg VARCHAR2(4000);   
    BEGIN   
        SELECT decode(p_lang, 'ar', text_ar, text_en)   
          INTO v_msg   
          FROM APP_TRANSLATION   
         WHERE code = p_code 
           AND NVL(IS_ACTIVE, 0) = 1; 

        RETURN v_msg;   
    EXCEPTION   
        WHEN OTHERS THEN     
            RETURN '';
    END get_translation;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION distance (   
        Lat1 IN NUMBER,   
        Lon1 IN NUMBER,   
        Lat2 IN NUMBER,   
        Lon2 IN NUMBER,   
        Radius IN NUMBER DEFAULT 3963   
    ) RETURN NUMBER IS   
     -- Convert degrees to radians   
     DegToRad NUMBER := 57.29577951;   
    BEGIN   
      RETURN(NVL(Radius,0) * ACOS((sin(NVL(Lat1,0) / DegToRad) * SIN(NVL(Lat2,0) / DegToRad)) +   
            (COS(NVL(Lat1,0) / DegToRad) * COS(NVL(Lat2,0) / DegToRad) *   
             COS(NVL(Lon2,0) / DegToRad - NVL(Lon1,0)/ DegToRad))));   
    --   
     -- This routine calculates the distance between two points (given the   
     -- latitude/longitude of those points). It is being used to calculate   
     -- the distance between two locations using GeoDataSource (TM) prodducts   
     --   
     -- Calculate distance between two points lat1,lon1 and lat2,lon2   
     -- Uses radius of earth in kilometers or miles as an argurments   
     --   
     -- Typical radius:  3963.0 (miles) (Default if no value specified)   
     --                  6387.7 (km)   
     --   
     -- Note: NVL function is used on all variables to replace NULL values with 0 (zero).   
     --   
     -- For enquiries, please contact sales@geodatasource.com   
     -- Official Web site: https://www.geodatasource.com   
     --   
     -- Thanks to Bill Dykstra for contributing the source code.   
     --   
     -- GeoDataSource.com (C) All Rights Reserved 2017   
     --   
    END; 

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION get_distance (   
        lat1    IN  NUMBER,   
        lon1    IN  NUMBER,   
        lat2    IN  NUMBER,   
        lon2    IN  NUMBER,   
        radius  IN  NUMBER DEFAULT 3963   
    ) RETURN NUMBER IS     
-- Convert degrees to radians     
        degtorad     NUMBER := 57.29577951;   
        returnvalue  NUMBER;   
        acos_param   NUMBER;   
    BEGIN   
        acos_param := ( sin(nvl(lat1, 0) / degtorad) * sin(nvl(lat2, 0) / degtorad) ) + ( cos(nvl(lat1, 0) / degtorad) * cos(nvl(   
        lat2, 0) / degtorad) * cos(nvl(lon2, 0) / degtorad - nvl(lon1, 0) / degtorad) );     
  -- Check if greater than 1 due to floating point errors     
        IF acos_param > 1 THEN   
            acos_param := 1;   
        END IF;     
  -- Check if less than -1 due to floating point errors     
        IF acos_param < -1 THEN   
            acos_param := -1;   
        END IF;   
        returnvalue := nvl(radius, 0) * acos(acos_param);   
        RETURN returnvalue;   
    END get_distance;    

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION PARSE_XML (   
        p_xml         IN VARCHAR2,   
        P_ELEMENT     IN VARCHAR2,    
        P_ONLY_UPPER  IN NUMBER DEFAULT 1   
    ) RETURN VARCHAR2 IS   
        v_str       VARCHAR2(32000);   
        v_XML       VARCHAR2(32000);   
        v_ELEMENT   VARCHAR2(32000);   
        v_result    VARCHAR2(32000);   
    BEGIN   
        IF P_ONLY_UPPER = 1 THEN   
            v_XML     := Upper(p_xml);   
            v_ELEMENT := upper(p_element);   
        ELSE   
            v_XML     := p_xml;   
            v_ELEMENT := p_element;   
        END IF;
        WHILE v_XML IS NOT NULL LOOP
            v_str := substr(v_XML, instr(v_XML, '<' || v_ELEMENT || '>'));
            v_str := substr(v_str, 0, instr(v_str, '</' || v_ELEMENT || '>') - 1);  
            v_str := replace(v_str, '<' || v_ELEMENT || '>', '');
            IF v_result IS NULL THEN
                v_result := v_str; 
            ELSE
                v_result:=v_result || ',' || v_str;
            END IF;
            v_XML := substr(v_XML, instr(v_XML, '</' || v_ELEMENT || '>'));   
            v_XML := substr(v_XML, length('</' || v_ELEMENT || '>') + 1);   
            IF instr(v_XML, '<' || v_ELEMENT || '>') = 0 THEN   
                v_XML := '';   
            END IF;
        END LOOP;   
        RETURN v_result;   
    END PARSE_XML;   

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    PROCEDURE ERROR_LOGS (
        p_ERROR_TYPE        IN VARCHAR2,
        p_PROCESS_NAME      IN VARCHAR2,
        p_ERROR_CODE        IN VARCHAR2,
        p_ERROR_MESSAGE     IN VARCHAR2,
        p_LOGGER_NAME       IN VARCHAR2 DEFAULT NULL,
        p_OBJECT_TYPE       IN VARCHAR2 DEFAULT NULL,
        p_OBJECT_ID         IN VARCHAR2 DEFAULT NULL
    ) IS   
        PRAGMA AUTONOMOUS_TRANSACTION;    
    BEGIN   
        INSERT INTO error_logs (   
                error_code,   
                error_message,   
                error_date,   
                process_name,   
                error_type,   
                LOGGER_NAME,   
                OBJECT_TYPE,   
                OBJECT_ID   
            ) VALUES (   
                p_ERROR_CODE,   
                p_ERROR_MESSAGE,   
                get_current_date,   
                p_PROCESS_NAME,   
                p_ERROR_TYPE,   
                p_LOGGER_NAME,   
                p_OBJECT_TYPE,   
                p_OBJECT_ID   
            );   
        COMMIT;       
    END ERROR_LOGS;   

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    PROCEDURE RUN_JOB IS
        v_param   NUMBER;
        v_status  NUMBER;
    BEGIN
        -- any JOBS to run will be here Insha allah
        -- PKG.check_function;
        -- PKG2.change_status_fuction(p_status => v_status);
        NULL;
    EXCEPTION
        WHEN OTHERS THEN
            ERROR_LOGS( p_error_type => 'SQL_ERROR', p_process_name => 'SYSTEM_CONTROLS.run_job', p_error_code => sqlcode, p_error_message => sqlerrm, p_logger_name => user );
    END RUN_JOB;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION unix_to_date( 
        p_unix_sec NUMBER 
    ) RETURN DATE IS 
        v_date DATE;
    BEGIN
        v_date := TO_DATE('19700101','YYYYMMDD') + ( 1/ 24/ 60/ 60) * p_unix_sec;
        RETURN v_date;
    END unix_to_date;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION date_to_unix ( 
        p_date DATE 
    ) RETURN NUMBER IS 
        v_unix_sec NUMBER; 
    BEGIN
        v_unix_sec := (p_date - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60 * 1000;
        RETURN v_unix_sec;
    END date_to_unix;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION email_validation ( 
        p_email VARCHAR2 
    ) RETURN NUMBER IS 
        v_isvalid BOOLEAN; 
    BEGIN
        IF REGEXP_LIKE(p_email, '^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') THEN  
            RETURN 1; 
        ELSE 
            RETURN 0; 
        END IF; 
    END email_validation;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION file_extension_by_mimetype ( 
        p_mimetype   VARCHAR2 
    ) RETURN VARCHAR2 IS 
        l_file_extension VARCHAR2(15); 
    BEGIN 
        SELECT DECODE ( 
          p_mimetype, 
           'audio/aac', '.aac', 
           'application/x-abiword', '.abw', 
           'application/octet-stream', '.arc', 
           'video/x-msvideo', '.avi', 
           'application/vnd.amazon.ebook', '.azw', 
           'application/octet-stream', '.bin', 
           'image/bmp', '.bmp', 
           'application/x-bzip', '.bz', 
           'application/x-bzip2', '.bz2', 
           'application/x-csh', '.csh', 
           'text/css', '.css', 
           'text/csv', '.csv', 
           'application/msword', '.doc', 
           'application/vnd.openxmlformats-officedocument.wordprocessingml.document', '.docx', 
           'application/vnd.ms-fontobject', '.eot', 
           'application/epub+zip', '.epub', 
           'application/ecmascript', '.es', 
           'image/gif', '.gif', 
           'text/html', '.htm', 
           'text/html', '.html', 
           'image/x-icon', '.ico', 
           'text/calendar', '.ics', 
           'application/java-archive', '.jar', 
           'image/jpeg', '.jpeg', 
           'image/jpeg', '.jpg', 
           'application/javascript', '.js', 
           'application/json', '.json', 
           'audio/midi audio/x-midi', '.mid', 
           'audio/midi audio/x-midi', '.midi', 
           'video/mpeg', '.mpeg', 
           'application/vnd.apple.installer+xml', '.mpkg', 
           'application/vnd.oasis.opendocument.presentation', '.odp', 
           'application/vnd.oasis.opendocument.spreadsheet', '.ods', 
           'application/vnd.oasis.opendocument.text', '.odt', 
           'audio/ogg', '.oga', 
           'video/ogg', '.ogv', 
           'application/ogg', '.ogx', 
           'font/otf', '.otf', 
           'image/png', '.png', 
           'application/pdf', '.pdf', 
           'application/vnd.ms-powerpoint', '.ppt', 
           'application/vnd.openxmlformats-officedocument.presentationml.presentation', '.pptx', 
           'application/x-rar-compressed', '.rar', 
           'application/rtf', '.rtf', 
           'application/x-sh', '.sh', 
           'image/svg+xml', '.svg', 
           'application/x-shockwave-flash', '.swf', 
           'application/x-tar', '.tar', 
           'image/tiff', '.tif', 
           'image/tiff', '.tiff', 
           'application/typescript', '.ts', 
           'font/ttf', '.ttf', 
           'text/plain', '.txt', 
           'application/vnd.visio', '.vsd', 
           'audio/wav', '.wav', 
           'audio/webm', '.weba', 
           'video/webm', '.webm', 
           'image/webp', '.webp', 
           'font/woff', '.woff', 
           'font/woff2', '.woff2', 
           'application/xhtml+xml', '.xhtml', 
           'application/vnd.ms-excel', '.xls', 
           'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', '.xlsx', 
           'application/xml', '.xml', 
           'application/vnd.mozilla.xul+xml', '.xul', 
           'application/zip', '.zip', 
           'video/3gpp', '.3gp', 
           'video/3gpp2', '.3g2', 
           'application/x-7z-compressed', '.7z', 
           'audio/mp4','.mp4', 
           'video/mp4','.mp4', 
           'application/mp4','.mp4', 
          'text/plain') 
          INTO l_file_extension 
          FROM DUAL; 

        RETURN l_file_extension; 
    END file_extension_by_mimetype;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION population (
        p_database_action VARCHAR2,
        p_table_name      VARCHAR2,
        p_params          VARCHAR2 DEFAULT NULL,
        p_condition       VARCHAR2 DEFAULT NULL
    ) RETURN CLOB IS
        v_count       NUMBER;
        v_result      CLOB;
        v_select_stmt VARCHAR2(4000);
        csr           SYS_REFCURSOR;
        TYPE t        IS TABLE OF SELLERS%rowtype;
        t_sellers     t;
    BEGIN
        IF p_database_action IS NULL OR p_table_name IS NULL THEN
            RETURN 'Missing Data!';
        END IF;

        v_select_stmt := 'SELECT * FROM ' || p_table_name || p_condition;
        DBMS_OUTPUT.put_line('Select: ' || v_select_stmt);

        IF UPPER(p_database_action) = 'SELECTING' THEN
            EXECUTE IMMEDIATE v_select_stmt BULK COLLECT INTO t_sellers;
            
            -- FOR i IN ( v_select_stmt ) LOOP
            --     DBMS_OUTPUT.put_line('string:' || i.ID);
            --     -- EXECUTE IMMEDIATE v_select_stmt;
            -- END LOOP;
        END IF;

        RETURN v_result;
    END population;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION get_date (
        p_lang   IN VARCHAR2 DEFAULT 'Arabic'
    ) RETURN VARCHAR AS
    BEGIN
        RETURN TO_CHAR( SYSDATE, 'yyyy/mm/dd pm', 'NLS_DATE_LANGUAGE = ' || p_lang );
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION get_day (
        p_date varchar2,
        p_lang   IN VARCHAR2 DEFAULT 'Arabic'
    ) RETURN VARCHAR AS
      v_date date ;
    BEGIN
        v_date := to_date(p_date,'dd/mm/yyyy');
        RETURN TO_CHAR( v_date, 'Day', 'NLS_DATE_LANGUAGE = ' || p_lang );
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION send_email ( 
        p_to       IN VARCHAR2,
        p_subject  IN VARCHAR2 DEFAULT 'إشعار بإسناد مهمة جديدة',
        p_html     IN VARCHAR2,
        p_lang     IN VARCHAR2 DEFAULT 'en',
        p_message OUT VARCHAR2
    ) RETURN NUMBER IS
        -- v_url   VARCHAR2(1000) := 'https://backend-node-2.mobasher.sa/send-email';
        v_url   VARCHAR2(1000) := 'https://backend-master.mobasher.sa/send-email';
        v_body  VARCHAR2(32000);
        v_clob  CLOB;
    BEGIN
        IF p_to IS NULL OR p_subject IS NULL OR p_html IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -1;
        END IF;

        v_body := '{
                       "to":"' || p_to || '",
                       "subject":"' || p_subject || '",
                       "html":"' || p_html || '"
                    }';

        apex_web_service.g_request_headers.delete();
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'application/json';

        v_clob := APEX_WEB_SERVICE.make_rest_request ( 
                    p_url         => v_url,
                    p_http_method => 'POST',
                    p_body        => v_body
                );
        
        IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'SYSTEM_CONTROLS.send_email', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || v_url || ' faild with status_code: '
                                       || APEX_WEB_SERVICE.g_status_code
                                       || ' Reason phrase: '
                                       || APEX_WEB_SERVICE.g_reason_phrase
                                    );

            p_message := 'SYSTEM_CONTROLS.send_email Request Error! Status: ' || APEX_WEB_SERVICE.g_status_code || ' Message: ' || v_clob;
            RETURN -2;
        END IF;

        INSERT INTO API_RESULTS (PROCESS_NAME ,RESPONSE, REQUEST_BODY, URL)
            VALUES ( 'send_email', v_clob, v_body, v_url);
        
        IF SQL%ROWCOUNT = 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'error', p_lang => p_lang);
            RETURN -3;
        END IF;

        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN 1;
    END send_email;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION base_url (
        p_is_lab    NUMBER DEFAULT 1,
        p_provider  VARCHAR2
    ) RETURN VARCHAR2 IS
        v_base_url   VARCHAR2(1000);
        v_stmt       VARCHAR2(1000);
    BEGIN
        v_stmt := 'SELECT DECODE(' || p_is_lab || ', 0, BASE_URL, TEST_BASE_URL) FROM ENVIRONMENT_SETTING
                    WHERE UPPER(PROVIDER) = ' || p_provider;
        EXECUTE IMMEDIATE v_stmt;

        DBMS_OUTPUT.PUT_LINE(v_stmt);
        RETURN v_base_url;
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION upload (
        p_item        IN VARCHAR2, 
        p_bucket_name IN VARCHAR2, 
        p_is_required IN NUMBER
    ) RETURN VARCHAR2 IS
        g_oci_base_url     CONSTANT VARCHAR2(1000) := 'https://objectstorage.me-jeddah-1.oraclecloud.com/n/axax2vam4edg';
        l_file_names        APEX_T_VARCHAR2;
        l_file              APEX_APPLICATION_TEMP_FILES%ROWTYPE;
        l_file_name         VARCHAR2(255);
        l_request_url	    VARCHAR2(32767);
        l_result	        CLOB;
        l_request_filename	VARCHAR2(500);
        l_inner_folder  	VARCHAR2(500);
    BEGIN
        l_file_names := apex_string.SPLIT (
                            p_str => p_item,
                            p_sep => ':' );

        IF p_is_required = 1 THEN 
            IF l_file_names.count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'يجب عليك رفع الصورة!');
            END IF;
        END IF;

        IF l_file_names.count > 0 THEN
            BEGIN 
                SELECT *
                  INTO l_file
                  FROM APEX_APPLICATION_TEMP_FILES
                 WHERE NAME = p_item
                   AND APPLICATION_ID = v('APP_ID');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20003, 'NO DATA FOUND -> ' || p_item);
            END;

            -- IF *****
            l_file_name := TO_CHAR(get_current_date, 'YY') 
                                || DBMS_RANDOM.STRING('x', 8)
                                || SYSTEM_CONTROLS.file_extension_by_mimetype(p_mimetype => l_file.MIME_TYPE);

            l_request_url := g_oci_base_url||'/b/'||p_bucket_name||'/o/'||l_file_name;
            
            l_result := APEX_WEB_SERVICE.make_rest_request (
                            p_url                  => l_request_url,
                            p_http_method          => 'PUT',
                            p_body_blob            => l_file.BLOB_CONTENT,
                            p_credential_static_id => 'OCI_AUTH'
                        );

            IF APEX_WEB_SERVICE.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
                SYSTEM_CONTROLS.ERROR_LOGS ( p_error_type    => 'SYSTEM_ERROR',
                                                     p_PROCESS_NAME => 'OCI_OS.put_object - ' || p_item,
                                                     p_error_code    => -2,
                                                     p_error_message => SUBSTR(l_result, 1, 4000),
                                                     p_logger_name   => v('APP_USER')
                                                );
                RAISE_APPLICATION_ERROR(-20001, 'Error with uploading Data!');
            END IF;

        END IF;

        RETURN l_request_url;
    END UPLOAD;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION random_str (
        v_length    NUMBER DEFAULT 100
    ) RETURN VARCHAR2 IS
        l_str   VARCHAR2(4000);
        l_count NUMBER;
        PRAGMA  AUTONOMOUS_TRANSACTION;
    BEGIN
        FOR i IN 1..v_length LOOP
            l_str := l_str || dbms_random.string (
                CASE WHEN dbms_random.value(0, 1) < 0.5 THEN 'l' ELSE 'x' END, 1
            );
        END LOOP;

        SELECT count(1) INTO l_count FROM API_AUTHENTICATOR WHERE API_NAME = 'UPLOAD';

        IF l_count > 0 THEN
            UPDATE API_AUTHENTICATOR
               SET API_KEY = l_str
             WHERE API_NAME = 'UPLOAD';
            COMMIT;
        ELSE
            INSERT INTO API_AUTHENTICATOR (API_KEY, API_NAME)
                VALUES (l_str, 'UPLOAD');
            COMMIT;
        END IF;

        RETURN l_str;
    END random_str;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END system_controls;
/