
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."AWS4_S3_PKG" AS   
    TYPE t_bucket IS RECORD (   
        bucket_name    VARCHAR2(255),   
        creation_date  DATE   
    );   
    TYPE t_bucket_list IS   
        TABLE OF t_bucket INDEX BY BINARY_INTEGER;   
    TYPE t_bucket_tab IS   
        TABLE OF t_bucket;   
	-- NOTE this is changed to capture the version ID cmoore february 2017   
    TYPE t_object IS RECORD (   
        key            VARCHAR2(4000),   
        size_bytes     NUMBER,   
        last_modified  DATE,   
        version_id     VARCHAR2(4000)   
    );   
    TYPE t_object_list IS   
        TABLE OF t_object INDEX BY BINARY_INTEGER;   
    TYPE t_object_tab IS   
        TABLE OF t_object;   
    TYPE t_owner IS RECORD (   
        user_id    VARCHAR2(200),   
        user_name  VARCHAR2(200)   
    );   
    TYPE t_grantee IS RECORD (   
        grantee_type  VARCHAR2(20),  -- CanonicalUser or Group   
        user_id       VARCHAR2(200),      -- for users   
        user_name     VARCHAR2(200),    -- for users   
        group_uri     VARCHAR2(200),    -- for groups   
        permission    VARCHAR2(20)     -- FULL_CONTROL, WRITE, READ_ACP   
    );   
    TYPE t_grantee_list IS   
        TABLE OF t_grantee INDEX BY BINARY_INTEGER;   
    TYPE t_grantee_tab IS   
        TABLE OF t_grantee;   
  -- bucket regions   
  -- see http://aws.amazon.com/articles/3912?_encoding=UTF8-jiveRedirect=1#s3   
  -- Updated 09FEB2017 cmoore   
	-- see http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region   
    g_region_us_standard CONSTANT VARCHAR2(255) := 'us-east-1';   
    g_region_us_east_virginia CONSTANT VARCHAR2(255) := 'us-east-1';   
    g_region_us_west_oregon CONSTANT VARCHAR2(255) := 'us-west-2';   
    g_region_eu_ireland CONSTANT VARCHAR2(255) := 'eu-west-1';   
    g_region_asia_pacific_tokyo CONSTANT VARCHAR2(255) := 'ap-northeast-1';   
    g_region_asia_pacific_singapor CONSTANT VARCHAR2(255) := 'ap-southeast-1';   
    g_region_asia_pacific_sydney CONSTANT VARCHAR2(255) := 'ap-southeast-2';   
    g_region_south_america_sao_p CONSTANT VARCHAR2(255) := 'sa-east-1';   
	-- The following sites are AWS Version 4 only   
    g_region_eu_london CONSTANT VARCHAR2(255) := 'eu-west-2';   
    g_region_us_east_ohio CONSTANT VARCHAR2(255) := 'us-east-2';   
    g_region_canada_central_1 CONSTANT VARCHAR2(255) := 'ca-central-1';   
    g_region_us_west_california CONSTANT VARCHAR2(255) := 'us-west-1';   
    g_region_asia_pacific_mumbai CONSTANT VARCHAR2(255) := 'ap-south-1';   
    g_region_asia_pacific_seoul CONSTANT VARCHAR2(255) := 'ap-northeast-2';   
    g_region_eu_frankfurt CONSTANT VARCHAR2(255) := 'eu-central-1';   
  -- predefined access policies   
  -- see http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?RESTAccessPolicy.html   
    g_acl_private CONSTANT VARCHAR2(255) := 'private';   
    g_acl_public_read CONSTANT VARCHAR2(255) := 'public-read';   
    g_acl_public_read_write CONSTANT VARCHAR2(255) := 'public-read-write';   
    g_acl_authenticated_read CONSTANT VARCHAR2(255) := 'authenticated-read';   
    g_acl_bucket_owner_read CONSTANT VARCHAR2(255) := 'bucket-owner-read';   
    g_acl_bucket_owner_full_ctrl CONSTANT VARCHAR2(255) := 'bucket-owner-full-control';   
--------------------------------------------------------------------------------   
-- 													S E C T I O N		   
--   
--						Functions and Procedures used for HTTPS auth and call   
--						These should be kept alphabetized   
--------------------------------------------------------------------------------   
    PROCEDURE delete_object (   
        p_bucket  IN  VARCHAR2,   
        p_object  IN  VARCHAR2   
    );   
    FUNCTION get_bucket_list RETURN t_bucket_list;   
    FUNCTION get_bucket_tab RETURN t_bucket_tab   
        PIPELINED;   
    FUNCTION get_object_blob (   
        p_bucket         IN  VARCHAR2,   
        p_canonical_uri  IN  VARCHAR2   
    ) RETURN BLOB;   
    PROCEDURE get_object_list (   
        p_bucket       IN   VARCHAR2,   
        p_prefix       IN   VARCHAR2,   
        p_max_keys     IN   NUMBER,   
        p_object_list  OUT  t_object_list   
    );   
    FUNCTION get_object_url (   
        p_bucket         IN  VARCHAR2,   
        p_canonical_uri  IN  VARCHAR2,   
        p_date           IN  DATE,   
        p_expiry         IN  NUMBER DEFAULT 3600   
    ) RETURN VARCHAR2;   
    FUNCTION put_object ( 
        p_bucket      IN  VARCHAR2, 
        p_blob        IN  BLOB, 
        p_object_key  IN  VARCHAR2, 
        p_mimetype    IN  VARCHAR2 
    ) RETURN NUMBER ;   
    FUNCTION delete_object2 ( 
        p_bucket      IN  VARCHAR2, 
        p_object      IN  VARCHAR2 
    ) RETURN NUMBER; 
END aws4_s3_pkg;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."AWS4_S3_PKG" AS    
-----------------------------------------------------------------------------------------    
--    
-- AWS Signature Version 4 - reference below    
-- http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html    
--    
-- In tribute of Morten Braten and Jason Straub, I have including their work with     
-- attributions and left their formatting in place.    
--    
-- Date: February 2017    
-- Author: Christina Moore    
--    
-- Modifications:    
--		cmoore 03MAY 2017    
--				escape ampersand in S3 filenames    
--				Added function to download BLOB from a URL via HTTPS    
--				Added function to get Object Blob from AWS via HTTPS    
-- 
--		cmoore 29APR 2019 
--				With Oracle 12.2 there have been significant problems with the resolution of SSL Certs and the use of the  
--				Oracle wallet for sites with multi-DNS (wildcard) certs.  
--				At Storm Petrel, we have opted to setup a Proxy/Reverse proxy to strip the SSL before Oracle sees it. 
--				there is a series of host entries in /etc/hosts that correspond to URLs called 
--				and vhost entries on the HTTPS_Proxy server (Apache) 
-- 
--	cmoore jun2021 
--			removed aws4_md5 functions (varchar/blob) 
--			consolidated the REST calls with internal procedure rest_request_clob  
--				and tested 
-- 
-----------------------------------------------------------------------------------------    
-- the following global settings will need to be changed for your environment    
    g_aws_id                 VARCHAR2(20) := '<AWS_KEY_ID>'; 
    g_aws_key                VARCHAR2(40) := '<AWS_SECRET>'; -- AWS secret key    
    g_wallet_path            CONSTANT VARCHAR2(100) := 'file:/u01/install/DB/wallet'; 
    g_wallet_pwd             CONSTANT VARCHAR2(100) := 'Aa@_100200300'; 
    g_https_host             CONSTANT VARCHAR2(100) := 's3.amazonaws.com'; 
    g_gmt_offset             NUMBER := -3; -- your timezone GMT adjustment    
    g_aws_region             VARCHAR2(40) := g_region_asia_pacific_mumbai; 
    g_aws_service            VARCHAR2(40) := 's3';    
	-- this information appears within the XML data that returns.     
    g_aws_namespace_s3       CONSTANT VARCHAR2(255) := 'http://s3.amazonaws.com/doc/2006-03-01/'; 
    g_aws_namespace_s3_full  CONSTANT VARCHAR2(255) := 'xmlns="' || g_aws_namespace_s3 || '"';
    g_iso8601_format         CONSTANT VARCHAR2(30) := 'YYYYMMDD"T"HH24MISS"Z"'; 
    g_date_format_xml        CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS".000Z"'; 
    g_aws4_auth              CONSTANT VARCHAR2(30) := 'AWS4-HMAC-SHA256'; 
    g_package                CONSTANT VARCHAR2(30) := 'aws4_s3_pkg'; 
    crlf                     CONSTANT VARCHAR2(2) := chr(13) || chr(10);
    cr                       CONSTANT VARCHAR2(2) := chr(13); 
    lf                       CONSTANT VARCHAR2(1) := chr(10); -- USE THIS FOR NEW LINE!!!!    
    amp                      CONSTANT VARCHAR2(1) := chr(38); 
    slsh                     CONSTANT VARCHAR2(3) := '%2F';	    
	-- this is the SHA256 HASH of a empty string. It is used when the request is null    
    g_null_hash              CONSTANT VARCHAR2(100) := 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';    
-- Keys for testing with ?UKASZ ADAMCZAK blog ( http://czak.pl/2015/09/15/s3-rest-api-with-curl.html)    
-- Keys also work for testing with AWS page http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html    
-- uncomment these if you want to run through his example to re-verify the hashing logic    
--  g_aws_id                 	varchar2(20) := '<AWS_KEY_ID>'; -- AWS access key ID    
--  g_aws_key                	varchar2(40) := 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'; -- AWS secret key 
--------------------------------------------------------------------------------    
-- 													S E C T I O N		    
--    
--	Private Functions and Procedures AWS4 Signature and HTTPS Request    
--    
--------------------------------------------------------------------------------    
    FUNCTION aws4_escape ( 
        p_url IN VARCHAR2 
    ) RETURN VARCHAR2    
	------------------------------------------------------------------------------    
	-- Function: 	AWS4 Escape    
	-- Author:		Christina Moore    
	-- Date:			03MAY2017    
	-- Version:		0.1    
	--    
	-- Returns		the AWS4 escape value    
	-- 	    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------	    
     AS 
        l_return VARCHAR2(1000); 
    BEGIN 
        l_return := p_url; 
        l_return := utl_url.escape(l_return); 
        l_return := replace(l_return, amp, '%26'); 
        RETURN l_return; 
    END aws4_escape; 
    PROCEDURE validate_http_method ( 
        p_http_method  IN  VARCHAR2, 
        p_procedure    IN  VARCHAR2 
    ) AS    
	------------------------------------------------------------------------------    
	-- Function: 	Validate_HTTP_Method    
	-- Author:		Christina Moore    
	-- Date:			07FEB2017    
	-- Version:		0.1    
	--    
	-- Confirms HTTP method - GET, POST    
	--    
	-- Revisions:    
    -- 	added 'HEAD'			cmoore 20oct2018 
	--    
	------------------------------------------------------------------------------    
        l_valid BOOLEAN := false; 
    BEGIN 
        CASE p_http_method 
            WHEN 'GET' THEN 
                l_valid := true; 
            WHEN 'POST' THEN 
                l_valid := true; 
            WHEN 'PUT' THEN 
                l_valid := true; 
            WHEN 'DELETE' THEN 
                l_valid := true; 
            WHEN 'HEAD' THEN 
                l_valid := true; -- cmoore 20oct2018 
            ELSE 
                l_valid := false; 
        END CASE; -- p_http_method   
        IF NOT l_valid THEN 
            raise_application_error(-20000, 'HTTP Method is not valid in ' 
                                            || g_package 
                                            || '.' 
                                            || p_procedure); 
        END IF; -- l_valid 
    END validate_http_method; 
    FUNCTION aws4_sha256 ( 
        p_string VARCHAR2 
    ) RETURN VARCHAR2 AS    
	------------------------------------------------------------------------------    
	-- Function: 	AWS4_sha256    
	-- Author:		Christina Moore    
	-- Date:			04FEB2017    
	-- Version:		0.1    
	--    
	-- SHA256 hash on the string provided    
	-- AWS requires that the hash is in lower case    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
        l_return  VARCHAR2(2000); 
        l_hash    RAW(2000); 
        l_source  RAW(2000); 
    BEGIN 
        l_source := utl_i18n.string_to_raw(p_string, 'AL32UTF8'); 
        l_hash := dbms_crypto.hash(src => l_source, typ => dbms_crypto.hash_sh256); 
        l_return := lower(rawtohex(l_hash)); 
        RETURN l_return; 
    END aws4_sha256; 
    FUNCTION aws4_sha256 ( 
        p_blob IN BLOB 
    ) RETURN VARCHAR2 AS    
	------------------------------------------------------------------------------    
	-- Function: 	AWS4_sha256    
	-- Author:		Christina Moore    
	-- Date:			04FEB2017    
	-- Version:		0.1    
	--    
	-- SHA256 hash on the blob provided    
	-- AWS requires that the hash is in lower case    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
        l_return       VARCHAR2(2000); 
        l_hash         RAW(2000); 
        l_source       RAW(2000); 
        l_blob_amount  INTEGER := 2000; 
        l_blob_buffer  VARCHAR2(4000); 
        l_blob_pos     INTEGER := 1; 
    BEGIN    
	--l_source		:= utl_i18n.string_to_raw(P_STRING,'AL32UTF8');    
        -- l_hash := dbms_crypto.hash(src => p_blob, typ => dbms_crypto.hash_sh256); 
        l_return := lower(rawtohex(l_hash)); 
        RETURN l_return; 
    END aws4_sha256; 
    FUNCTION aws4_signing_key ( 
        p_string_to_sign  VARCHAR2, 
        p_date            DATE 
    ) RETURN VARCHAR2    
	------------------------------------------------------------------------------    
	-- Function: 	AWS4_SIGNING_KEY    
	-- Author:		Christina Moore    
	-- Date:			04FEB2017    
	-- Version:		0.1    
	--    
	-- Parameters    
	--	String-to-Sign	- the string to sign, see AWS documentation     
	--										and function signature string in this packages    
	--	Date - current date    
	--    
	-- Follows the guidence of the AWS Signature Version 4 documentation    
	-- http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html    
	-- In accordance with the documentation, the StringToSign is provided to the function    
	-- The date is provided so that debugging against known standards is possible.    
	--     
	-- Note that the String to Sign is a complicated multi-line effort that starts with    
	-- AWS-HMAC-SHA256    
	-- This String to Sign is generated in Function ...    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
     AS 
        l_return                   VARCHAR2(2000); 
        l_date_string              VARCHAR2(50); 
        l_key_bytes_raw            RAW(2000); 
        l_source                   RAW(2000); 
        l_date_key                 RAW(2000); 
        l_date_region_key          RAW(2000); 
        l_date_region_service_key  RAW(2000); 
        l_signing_key              RAW(2000); 
        l_signature                RAW(2000); 
        l_date                     DATE;    
    BEGIN    
	-- For testing in accordance with     
	--   http://czak.pl/2015/09/15/s3-rest-api-with-curl.html    
	--   use 15 Sep 2015 12:45:00 GMT to get known results    
        l_date_string := to_char(p_date, 'YYYYMMDD');    
	-- per AWS documentation    
	-- 2 Signing Key    
	-- DateKey = HMAC-SHA256("AWS4" + "<SecretAccessKey>","<yyyymmdd>")    
        l_key_bytes_raw := utl_i18n.string_to_raw('AWS4' || g_aws_key, 'AL32UTF8'); 
        l_source := utl_i18n.string_to_raw(l_date_string, 'AL32UTF8'); 
        -- l_date_key := dbms_crypto.mac(src => l_source, typ => dbms_crypto.hmac_sh256, key => l_key_bytes_raw);    
	-- DateRegionKey = HMAC-SHA256(DateKey,"<aws-region>")    
        l_source := utl_i18n.string_to_raw(g_aws_region, 'AL32UTF8'); 
        -- l_date_region_key := dbms_crypto.mac(src => l_source, typ => dbms_crypto.hmac_sh256, key => l_date_key);    
	-- DateRegionServiceKey = HMAC-SHA256(DateRegionKey,"<aws-service>")    
        l_source := utl_i18n.string_to_raw(g_aws_service, 'AL32UTF8'); 
        -- l_date_region_service_key := dbms_crypto.mac(src => l_source, typ => dbms_crypto.hmac_sh256, key => l_date_region_key);    
	-- SigningKey = HMAC-SHA256(DateRegionServiceKey, "aws4_request")    
        l_source := utl_i18n.string_to_raw('aws4_request'); 
        -- l_signing_key := dbms_crypto.mac(src => l_source, typ => dbms_crypto.hmac_sh256, key => l_date_region_service_key); 
	-- 3. Signature    
	-- signature = hex(HMAC-SHA256(SigningKey, StringToSign))    
        l_source := utl_i18n.string_to_raw(p_string_to_sign); 
        -- l_signature := dbms_crypto.mac(src => l_source, typ => dbms_crypto.hmac_sh256, key => l_signing_key); 
        l_return := lower(rawtohex(l_signature)); 
        RETURN l_return; 
    END aws4_signing_key; 
    FUNCTION iso_8601 ( 
        p_date      IN  TIMESTAMP, 
        p_timezone  IN  VARCHAR2 DEFAULT 'UTC' 
    ) RETURN VARCHAR2 AS    
	------------------------------------------------------------------------------    
	-- Function: 	ISO_8601    
	-- Author:		Christina Moore    
	-- Date:			04FEB2017    
	-- Version:		0.1    
	--    
	-- Generates a varchar date in the ISO_8601 format. The function    
	-- Also converts from the provided timezone to UTC/GMT. It does     
	-- assume with default that your work and server is on UTC.    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
        l_timestamp  TIMESTAMP; 
        l_iso_8601   VARCHAR2(60); 
    BEGIN    
	-- convert the date/time to UTC/Zulu/GMT    
        SELECT 
            CAST(p_date  AS TIMESTAMP WITH TIME ZONE) /*AT TIME ZONE 'GMT'*/ 
        INTO l_timestamp 
        FROM 
            dual;    
	-- convert the format to ISO_8601/JSON format    
        IF l_timestamp IS NOT NULL THEN 
            l_iso_8601 := to_char(l_timestamp, g_iso8601_format); 
        ELSE 
            l_iso_8601 := NULL; 
        END IF; 
        RETURN l_iso_8601; 
    END iso_8601; 
    FUNCTION canonical_request ( 
        p_bucket             IN   VARCHAR2, 
        p_http_method        IN   VARCHAR2, 
        p_canonical_uri      IN   VARCHAR2, 
        p_query_string       IN   VARCHAR2, 
        p_date               IN   DATE, 
        p_payload_hash       IN   VARCHAR2, 
        p_canonical_request  OUT  VARCHAR2, 
        p_url                OUT  VARCHAR2 
    ) RETURN VARCHAR2 AS    
	------------------------------------------------------------------------------    
	-- Function: 	Canonical Request    
	-- Author:		Christina Moore    
	-- Date:			25FEB2017    
	-- Version:		0.3    
	--    
	-- Generates the Canonical Request and the corresponding URL    
	-- as documented by AWS.    
	-- http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html    
	-- Their standard defintion looks like this:    
	--		<HTTPMethod>\n    
	--		<CanonicalURI>\n    
	--		<CanonicalQueryString>\n    
	--		<CanonicalHeaders>\n    
	--		<SignedHeaders>\n    
	--		<HashedPayload>    
	--     
	-- If AWS returns errors the cause is most likely found in the canonical     
	-- request.Even the signature doesn't match error. This is still likely     
	-- found in your canonical request.     
	--    
	-- There are variations and judgement calls to make. For example, the AWS    
	-- documentation will show you both of these two URL    
	-- 		Option 1    
	-- https://s3.amazonaws.com/examplebucket?prefix=somePrefix    
	--		Option 2    
	-- https://examplebucket.s3.amazonaws.com?prefix=somePrefix    
	--    
	-- What matters is that you stick to one patch until you hit a wall, then    
	-- change paths and use the other option. In my errors, I have found that     
	-- Option 1 tends to be more robust. Option 2 tends to be shown with the    
	-- introductory examples.    
	--    
	-- 25FEB2017 cmoore - additional notes on the Options above. The ap-south-1    
	-- also called us-standard doesn't follow the same canonical rules as other    
	-- newer buckets. What works for eu-central-1 does not work for ap-south-1.    
	-- so I added an 'IF' statement.     
	--    
	-- Revisions:    
	--		0.2		cmoore 11feb2017    
	--		left and right parens need to be escaped in the canonical request    
	--		0.3		cmoore 25feb2017    
	--			encountered error PermanentRedirect when using Option 1 above for eu-central-1.     
	--			Changing to option 2	    
	--		0.4		cmoore 26feb2017    
	--			with canonical URI, need to know if there is or is not a slash    
	--		0.5	cmoore 03MAY2017    
	--			using local escape URL function    
	--    
	------------------------------------------------------------------------------    
        l_canonical_request  VARCHAR2(4000); 
        l_http_method        VARCHAR2(20); 
        l_query_string       VARCHAR2(1000); 
        l_uri                VARCHAR2(1000); 
        l_header             VARCHAR2(1000); 
        l_signed_hdr         VARCHAR2(1000); 
        l_content_length     VARCHAR2(100); 
        l_bucket             VARCHAR2(100); 
        l_host               VARCHAR2(100); 
        l_request_hashed     VARCHAR2(100); 
    BEGIN 
        validate_http_method(p_http_method, 'canonical_request'); 
        l_query_string := aws4_escape(p_query_string);    
	-- Strip the ? in case someone adds the question-mark    
        IF substr(p_query_string, 1, 1) = '?' THEN 
            l_query_string := substr(l_query_string, 2); 
        END IF; -- '? is first    
	-- clean up the query string to meet AWS standards    
	-- you do not want the slash in the query portion of the URL    
        l_query_string := replace(l_query_string, '/', '%2F');    
	-- the ( and ) are unreserved characters in accordance to Oracle    
	-- https://docs.oracle.com/database/121/ARPLS/u_url.htm#ARPLS71584    
        l_query_string := replace(l_query_string, '(', '%28'); 
        l_query_string := replace(l_query_string, ')', '%29');    
	-- manage the canonical URI    
        IF p_bucket IS NOT NULL THEN 
            IF g_aws_region IN ( 'ap-south-1' ) THEN    
			-- Option 1     
                l_host := 'host:s3.amazonaws.com'; 
                l_uri := aws4_escape('/' 
                                     || p_bucket 
                                     || p_canonical_uri); 
                p_url := aws4_escape('https://s3.amazonaws.com/' 
                                     || p_bucket 
                                     || p_canonical_uri); 
            ELSE    
			-- Option 2    
                CASE 
                    WHEN p_canonical_uri IS NULL THEN 
                        l_uri := '/'; 
                    WHEN p_canonical_uri = '/' THEN 
                        l_uri := '/'; 
                    ELSE 
                        IF substr(p_canonical_uri, 1, 1) = '/' THEN 
                            l_uri := aws4_escape(p_canonical_uri); 
                        ELSE 
                            l_uri := aws4_escape('/' || p_canonical_uri); 
                        END IF; -- does canonical URI start with slash, add one if no    
                END CASE; 
                l_host := 'host:' 
                          || p_bucket 
                          || '.s3.' 
                          || g_aws_region 
                          || '.amazonaws.com'; 
                p_url := aws4_escape('https://' 
                                     || p_bucket 
                                     || '.s3.' 
                                     || g_aws_region 
                                     || '.amazonaws.com' 
                                     || p_canonical_uri); 
            END IF; -- ap-south-1 or not    
        ELSE 
            l_host := 'host:s3.amazonaws.com'; 
            l_uri := aws4_escape(p_canonical_uri); 
            p_url := aws4_escape('https://s3.amazonaws.com'); 
        END IF; -- p_bucket null?    
        l_header := l_host 
                    || lf 
                    || 'x-amz-content-sha256:' 
                    || p_payload_hash 
                    || lf 
                    || 'x-amz-date:' 
                    || iso_8601(p_date) 
                    || lf; -- this needs extra line?    
        l_signed_hdr := 'host;x-amz-content-sha256;x-amz-date'; 
        l_canonical_request := p_http_method || lf; 
        l_canonical_request := l_canonical_request 
                               || l_uri 
                               || lf; 
        l_canonical_request := l_canonical_request 
                               || l_query_string 
                               || lf; 
        l_canonical_request := l_canonical_request 
                               || l_header 
                               || lf; 
        l_canonical_request := l_canonical_request 
                               || l_signed_hdr 
                               || lf; 
        l_canonical_request := l_canonical_request || p_payload_hash;    
	-- this value can assist with troubleshooting errors from AWS    
        p_canonical_request := l_canonical_request; 
        IF p_query_string IS NOT NULL THEN 
            IF substr(p_query_string, 1, 1) <> '?' THEN 
                p_url := p_url || '?'; 
            END IF; -- '? is first    
		--l_query_string	:= replace(P_QUERY_STRING,'/','%2F');    
            p_url := p_url || l_query_string; 
        END IF; -- query string null?    
        l_request_hashed := lower(aws4_sha256(l_canonical_request)); 
        RETURN l_request_hashed; 
    END canonical_request; 
    FUNCTION signature_string ( 
        p_request_hashed  IN  VARCHAR2, 
        p_date            IN  DATE 
    ) RETURN VARCHAR2 AS    
	------------------------------------------------------------------------------    
	-- Function: 	Signature String    
	-- Author:		Christina Moore    
	-- Date:			04FEB2017    
	-- Version:		0.1    
	--    
	-- Creates the StringToSign, in accordance with AWS API Documentation    
	-- http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html    
	-- 	    
	--		"AWS4-HMAC-SHA256" + "\n" +    
	--		timeStampISO8601Format + "\n" +    
	--		<Scope> + "\n" +    
	--		Hex(SHA256Hash(<CanonicalRequest>))    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
        l_response        VARCHAR2(100); 
        l_date_string     VARCHAR2(50); 
        l_time_string     VARCHAR2(50); 
        l_string_to_sign  VARCHAR2(4000); 
    BEGIN 
        l_time_string := iso_8601(p_date); 
        l_date_string := to_char(p_date, 'YYYYMMDD'); 
        l_string_to_sign := g_aws4_auth || lf; 
        l_string_to_sign := l_string_to_sign 
                            || l_time_string 
                            || lf; 
        l_string_to_sign := l_string_to_sign 
                            || l_date_string 
                            || '/' 
                            || g_aws_region 
                            || '/s3/aws4_request' 
                            || lf; 
        l_string_to_sign := l_string_to_sign || p_request_hashed; 
        RETURN ( l_string_to_sign ); 
    END signature_string; 
    FUNCTION aws4_signature ( 
        p_request_hashed  IN  VARCHAR2, 
        p_date            IN  DATE 
    ) RETURN VARCHAR2 AS    
	------------------------------------------------------------------------------    
	-- Function: 	AWS4 Signature    
	-- Author:		Christina Moore    
	-- Date:			04FEB2017    
	-- Version:		0.1    
	--    
	-- Parameters    
	--	Request Hashed	- the Canonical Request that has been hashed    
	--	Date - the date likely sysdate    
	--     
	-- Gets the String-To-Sign and hands it to the AWS Signing Key    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
        l_signature    VARCHAR2(100); 
        l_sign_string  VARCHAR2(4000); 
    BEGIN 
        l_sign_string := signature_string(p_request_hashed => p_request_hashed, p_date => p_date); 
        l_signature := aws4_signing_key(l_sign_string, p_date); 
        RETURN l_signature; 
    END aws4_signature; 
    FUNCTION prep_aws_data ( 
        p_bucket             IN   VARCHAR2, 
        p_http_method        IN   VARCHAR2, 
        p_canonical_uri      IN   VARCHAR2, 
        p_query_string       IN   VARCHAR2, 
        p_date               IN   DATE, 
        p_payload_hash       IN   VARCHAR2, 
        p_content_length     IN   NUMBER DEFAULT NULL, 
        p_canonical_request  OUT  VARCHAR2, 
        p_url                OUT  VARCHAR2 
    ) RETURN VARCHAR2 AS    
	------------------------------------------------------------------------------    
	-- Function: 	Prep AWS Data    
	-- Author:		Christina Moore    
	-- Date:			04FEB2017    
	-- Version:		0.1    
	--    
	-- Returns		the AWS4 signature    
	-- Parameters    
	--	Bucket - name of the bucket    
	-- 	HTTP Method - GET, POST, PUT    
	-- 	Canonical URI	- most likely the /. Cleaner when using prefices    
	-- 	Query String - These are likely derived from AWS parameters in their documentation    
	--	Date - most likely sysdate    
	--	Payload Hash - the SHA256 hash of the payload or a empty line (a constant)    
	-- 	Canonical Request - this is returned to aid in debugging    
	--	URL - needed to make the HTTPS call    
	--    
	-- http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html    
	-- Task 1		Creates a Canonical Request    
	--					And creates the URL so that they match. AWS docs are soft on this    
	-- Task 2		Creates as String to Sign    
	-- Task 3		Calculates Signature    
	-- 	    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
        l_request_hashed  VARCHAR2(100); 
        l_signature       VARCHAR2(100); 
        l_url             VARCHAR2(4000); 
    BEGIN 
        l_request_hashed := canonical_request(p_bucket => p_bucket, p_http_method => p_http_method, p_canonical_uri => p_canonical_uri, 
                                             p_query_string => p_query_string, 
                                             p_date => p_date, 
                                             p_canonical_request => p_canonical_request, 
                                             p_payload_hash => p_payload_hash, 
                                             p_url => p_url); 
        l_signature := aws4_signature(p_request_hashed => l_request_hashed, p_date => p_date); 
        RETURN l_signature; 
    END prep_aws_data;    
    FUNCTION rest_request_clob ( 
        p_bucket            IN   VARCHAR2, 
        p_http_method       IN   VARCHAR2, 
        p_object            IN   VARCHAR2, 
        p_query_string      IN   VARCHAR2 DEFAULT NULL, 
        p_http_status_code  OUT  VARCHAR2 
    ) RETURN CLOB 
-------------------------------------------------------------------------------- 
-- REQUEST_REQUEST_CLOB returns clob 
--		cmoore june 2021 
--		consolidates code for setting request headers and REST requests 
-- 
-- 
-------------------------------------------------------------------------------- 
     AS 
        l_date               DATE; 
        l_date_string        VARCHAR2(50); 
        l_time_string        VARCHAR2(50); 
        l_payload_hash       VARCHAR2(100); 
        l_http_method        VARCHAR2(10); 
        l_request_hashed     VARCHAR2(4000); 
        l_canonical_request  VARCHAR2(4000); 
        l_signature          VARCHAR2(4000); 
        l_url                VARCHAR2(4000); 
        l_clob               CLOB; 
        l_xml                XMLTYPE; 
        l_count              NUMBER := 0; 
        l_procedure          VARCHAR2(40) := g_package || '.object_head'; 
    BEGIN 
        l_date := systimestamp; -- cmoore 20oct2018 
        l_date_string := to_char(l_date, 'YYYYMMDD'); 
        l_time_string := iso_8601(l_date); 
        l_payload_hash := g_null_hash; 
        l_signature := prep_aws_data(p_bucket => p_bucket, p_http_method => p_http_method, p_canonical_uri => p_object, 
                                    p_query_string => NULL, 
                                    p_date => l_date, 
                                    p_canonical_request => l_canonical_request, 
                                    p_payload_hash => l_payload_hash, 
                                    p_url => l_url); 
        apex_web_service.g_request_headers.DELETE(); 
        apex_web_service.g_request_headers(1).name := 'Authorization'; 
        apex_web_service.g_request_headers(1).value := g_aws4_auth 
                                                       || ' Credential=' 
                                                       || g_aws_id 
                                                       || '/' 
                                                       || l_date_string 
                                                       || '/' 
                                                       || g_aws_region 
                                                       || '/s3/aws4_request,' 
                                                       || ' SignedHeaders=host;x-amz-content-sha256;x-amz-date,' 
                                                       || ' Signature=' 
                                                       || l_signature; 
        apex_web_service.g_request_headers(2).name := 'x-amz-content-sha256'; 
        apex_web_service.g_request_headers(2).value := l_payload_hash; 
        apex_web_service.g_request_headers(3).name := 'x-amz-date'; 
        apex_web_service.g_request_headers(3).value := l_time_string; 
        l_clob := apex_web_service.make_rest_request(p_url => l_url, p_http_method => p_http_method, 
                                                    p_wallet_path => g_wallet_path, 
                                                    p_wallet_pwd => g_wallet_pwd, 
                                                    p_https_host => g_https_host); 
        p_http_status_code := apex_web_service.g_status_code; 
        RETURN l_clob; 
    END rest_request_clob; 
--------------------------------------------------------------------------------    
-- 													S E C T I O N		    
--    
--	Private Functions and Procedures AWS S3 Interactions    
--    
--------------------------------------------------------------------------------    
    PROCEDURE check_for_errors ( 
        p_clob IN CLOB 
    ) AS 
        l_xml XMLTYPE; 
    BEGIN    
  /*    
  Purpose:   	check for errors (clob) in data returned from HTTPS call    
							Overloaded procedure CLOB vs XML    
  Remarks:    
  Who     Date        Description    
  ------  ----------  -------------------------------------    
  MBR     15.01.2011  Created    
	cmoroe	07FEB2017		Modified, reformatted    
  */ 
        IF 
            ( p_clob IS NOT NULL ) 
            AND ( length(p_clob) > 0 ) 
        THEN 
            l_xml := xmltype(p_clob); 
            IF l_xml.existsnode('/Error') = 1 THEN 
            --debug_pkg.print (l_xml); 
                raise_application_error(-20000, l_xml.extract('/Error/Message/text()').getstringval()); 
            END IF; 
        END IF; -- p_clob is not null and > 0    
    END check_for_errors; 
    PROCEDURE check_for_errors ( 
        p_xml IN XMLTYPE 
    ) AS 
    BEGIN    
  /*    
  Purpose:		check for errors (XMLType)    
							Overloaded procedure CLOB vs XML    
  Remarks:    
  Who     Date        Description    
  ------  ----------  -------------------------------------    
  MBR     15.01.2011  Created    
	cmoore	07FEB2017		modified, consolidated procedure, formatted    
  */ 
        IF p_xml.existsnode('/Error') = 1 THEN 
            --debug_pkg.print (p_xml); 
            raise_application_error(-20000, p_xml.extract('/Error/Message/text()').getstringval()); 
        END IF; -- error found in xml    
    END check_for_errors; 
    FUNCTION check_for_redirect ( 
        p_clob IN CLOB 
    ) RETURN VARCHAR2 AS 
        l_xml          XMLTYPE; 
        l_returnvalue  VARCHAR2(4000); 
    BEGIN    
  /*    
  Purpose:   check for redirect    
  Remarks:   Used by the "delete bucket" procedure, by Jeffrey Kemp    
             see http://code.google.com/p/plsql-utils/issues/detail?id=14    
             "One thing I found when testing was that if the bucket is not in     
						 the US standard region, Amazon seems to respond with a     
						 TemporaryRedirect error. If the same request is re-requested to     
						 the indicated URL it works."    
  Who     Date        Description    
  ------  ----------  -------------------------------------    
  MBR     16.02.2013  Created, based on code by Jeffrey Kemp    
  */ 
        IF 
            ( p_clob IS NOT NULL ) 
            AND ( length(p_clob) > 0 ) 
        THEN 
            l_xml := xmltype(p_clob); 
            IF l_xml.existsnode('/Error') = 1 THEN 
                IF l_xml.extract('/Error/Code/text()').getstringval = 'TemporaryRedirect' THEN 
                    l_returnvalue := l_xml.extract('/Error/Endpoint/text()').getstringval; 
                    --debug_pkg.printf('Temporary Redirect to %1', l_returnvalue); 
                END IF; -- TemporaryRedirect found    
            END IF; -- there is an error    
        END IF; -- clob not null and length > 0    
        RETURN l_returnvalue; 
    END check_for_redirect; 
    FUNCTION get_blob_from_https ( 
        p_url          IN  VARCHAR2, 
        p_auth         IN  VARCHAR2 DEFAULT NULL, 
        p_hash         IN  VARCHAR2 DEFAULT NULL, 
        p_time_string  IN  VARCHAR2 DEFAULT NULL 
    ) RETURN BLOB AS    
	------------------------------------------------------------------------------    
	-- Function: 	Prep AWS Data    
	-- Author:		MBR \ Christina Moore    
	-- Date:			01JAN 2008 \ 04FEB2017    
	-- Version:		0.1    
	--    
	-- Returns		a blob from a HTTPS URL    
	-- Parameters    
	--	URL - url, must be https    
	-- 	AUTH - used for header values    
	-- 	HASH - used for header values    
	-- 	Time String - used for header values    
	--    
	-- 	    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
        l_http_request   utl_http.req; 
        l_http_response  utl_http.resp; 
        l_raw            RAW(32767); 
        l_returnvalue    BLOB; 
    BEGIN 
        dbms_lob.createtemporary(l_returnvalue, false); 
        utl_http.set_wallet(g_wallet_path, g_wallet_pwd); 
        l_http_request := utl_http.begin_request(p_url); 
        IF p_auth IS NOT NULL THEN 
            utl_http.set_header(l_http_request, 'Authorization', p_auth); 
        END IF; -- P_AUTH is not null    
        IF p_hash IS NOT NULL THEN 
            utl_http.set_header(l_http_request, 'x-amz-content-sha256', p_hash); 
        END IF; -- P_AUTH is not null	    
        IF p_time_string IS NOT NULL THEN 
            utl_http.set_header(l_http_request, 'x-amz-date', p_time_string); 
        END IF; -- P_AUTH is not null	    
        l_http_response := utl_http.get_response(l_http_request); 
        BEGIN 
            LOOP 
                utl_http.read_raw(l_http_response, l_raw, 32767); 
                dbms_lob.writeappend(l_returnvalue, utl_raw.length(l_raw), l_raw); 
            END LOOP; 
        EXCEPTION 
            WHEN utl_http.end_of_body THEN 
                utl_http.end_response(l_http_response); 
        END; 
        RETURN l_returnvalue; 
    EXCEPTION 
        WHEN OTHERS THEN 
            utl_http.end_response(l_http_response); 
            dbms_lob.freetemporary(l_returnvalue); 
            RAISE; 
    END get_blob_from_https;    
-------------------------------------------------------------------------------- 
-- 													S E C T I O N		 
-- 
--	Functions and Procedures used for HTTPS authentication and call 
-------------------------------------------------------------------------------- 
    FUNCTION bucket_head ( 
        p_bucket IN VARCHAR2 
    ) RETURN BOOLEAN 
-------------------------------------------------------------------------------- 
-- Function: 	Bucket head 
-- Author:		Christina Moore 
-- Date:			20 oct 2018 / jun 2021 
-- Version:		2.0 
-- 
-- Working fine. 
-- 
-- Revisions: 
--	june 2021 	cmoore	updated to use rest_request_clob 
-- 
-------------------------------------------------------------------------------- 
/* 
declare  
	l_bucket_ok				boolean := false; 
	P_BUCKET					varchar2(100) := 'dev.xxx'; 
begin 
	l_bucket_ok := aws4_s3_pkg.bucket_head (P_BUCKET); 
	if l_bucket_ok then 
		dbms_output.put_line(P_BUCKET || ' is ok'); 
	else 
		dbms_output.put_line(P_BUCKET || ' is NOT VALID'); 
	end if; 
end; 
*/ AS 
        l_clob              CLOB; 
        l_http_status_code  VARCHAR2(10); 
        l_procedure         VARCHAR2(40) := g_package || '.bucket_head'; 
    BEGIN 
        l_clob := rest_request_clob(p_bucket => p_bucket, p_http_method => 'GET', p_object => '/', p_query_string => NULL, 
                                   p_http_status_code => l_http_status_code); 
        IF apex_web_service.g_status_code = '200' THEN 
            RETURN true; 
        ELSE 
            RETURN false; 
        END IF; -- status code 
    END bucket_head;    
--------------------------------------------------------------------------------    
-- 													S E C T I O N		    
--    
--						Functions and Procedures used for HTTPS auth and call    
--						These should be kept alphabetized    
--------------------------------------------------------------------------------    
    PROCEDURE delete_object ( 
        p_bucket  IN  VARCHAR2, 
        p_object  IN  VARCHAR2 
    )  
	------------------------------------------------------------------------------    
	-- Function: 	Delete Object    
	-- Author:		Christina Moore    
	-- Date:			11FEB2017 / jun 2021 
	-- Version:		2.0  
	--    
	-- Deletes an AWS S3 object    
	-- Parameters    
	-- 	Bucket - bucket name, lower case, exact as in S3    
	--  Object - the object complete with prefix and name    
	--     
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
     AS    
	------------------------------------------------------------------------------    
	--    
	--	Sample Code for Calling Function    
	--    
	------------------------------------------------------------------------------    
/*    
begin    
	aws4_s3_pkg.delete_object(    
		p_bucket 			=> 'my-bucket',    
		p_object			=> '/13 January 2014 letter to aunt.docx'    
		);    
end;    
*/ 
        l_http_status_code  VARCHAR2(10); 
        l_clob              CLOB; 
        l_procedure         VARCHAR2(40) := g_package || '.delete_object';   
    BEGIN 
                l_clob := rest_request_clob( 
                    p_bucket => lower(p_bucket),  
                    p_http_method => 'DELETE',  
                    p_object => p_object, 
                    p_query_string => NULL, 
                    p_http_status_code => l_http_status_code); 
        check_for_errors(l_clob); 
    END delete_object; 
    FUNCTION get_bucket_list RETURN t_bucket_list    
	------------------------------------------------------------------------------    
	-- Function: 	Get Bucket List    
	-- Author:		Christina Moore    
	-- Date:			10FEB2017 / jun 2021 
	-- Version:		2.0   
	--    
	-- Gets all of the buckets owned by the credentials provided    
	-- Parameters    
	-- 	t_bucket_list	- array of buckets, see the sample calling code    
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------       
	------------------------------------------------------------------------------    
	--    
	--	Sample Code for Calling Function    
	--    
	------------------------------------------------------------------------------    
/*    
declare    
  l_bucket_list					aws4_s3_pkg.t_bucket_list;    
begin    
	l_bucket_list :=	aws4_s3_pkg.get_bucket_list;    
	for i in 1 .. l_bucket_list.count loop    
		dbms_output.put('Bucket: ');    
		dbms_output.put(l_bucket_list(i).bucket_name);    
		dbms_output.put(' Created: ');    
		dbms_output.put_line(l_bucket_list(i).creation_date);    
	end loop;    
end;    
*/ AS 
        l_clob              CLOB; 
        l_xml               XMLTYPE; 
        l_count             NUMBER := 0; 
        l_bucket_list       t_bucket_list; 
        l_http_status_code  VARCHAR2(10); 
        l_procedure         VARCHAR2(40) := g_package || '.get_bucket_list'; 
    BEGIN 
        l_clob := rest_request_clob( 
                    p_bucket => NULL,  
                    p_http_method => 'GET',  
                    p_object => '/',  
                    p_query_string => NULL, 
                    p_http_status_code => l_http_status_code); 
        IF l_http_status_code = '200' THEN             
            IF 
                ( l_clob IS NOT NULL ) 
                AND ( length(l_clob) > 0 ) 
            THEN 
                l_xml := xmltype(l_clob); 
                check_for_errors(l_xml); 
                FOR l_rec IN ( 
                    SELECT 
                        extractvalue(value(t), '*/Name', g_aws_namespace_s3_full)                  AS bucket_name, 
                        extractvalue(value(t), '*/CreationDate', g_aws_namespace_s3_full)          AS creation_date 
                    FROM 
                        TABLE ( xmlsequence(l_xml.extract('//ListAllMyBucketsResult/Buckets/Bucket', g_aws_namespace_s3_full)) ) t 
                ) LOOP 
                    l_count := l_count + 1; 
                    l_bucket_list(l_count).bucket_name := l_rec.bucket_name; 
                    l_bucket_list(l_count).creation_date := to_date(l_rec.creation_date, g_date_format_xml); 
                END LOOP; -- loop xml data    
            END IF; -- is clob from S3 null?  
        END IF; -- status code = 200       
        RETURN l_bucket_list; 
    END get_bucket_list; 
    FUNCTION get_bucket_tab RETURN t_bucket_tab 
        PIPELINED 
    AS 
        l_bucket_list t_bucket_list; 
    BEGIN    
        l_bucket_list := get_bucket_list; 
        FOR i IN 1..l_bucket_list.count LOOP 
            PIPE ROW ( l_bucket_list(i) ); 
        END LOOP; 
        RETURN; 
    END get_bucket_tab; 
    FUNCTION get_object_blob ( 
        p_bucket         IN  VARCHAR2, 
        p_canonical_uri  IN  VARCHAR2 
    ) RETURN BLOB    
		------------------------------------------------------------------------------ 
	-- Function: 	Get Object BLOB 
	-- Author:		Christina Moore 
	-- Date:			03MAY2017 
	-- Version:		0.1 
	-- 
	-- Returns a BLOB  
	-- Parameters 
	-- 	Bucket - bucket name, lower case, exact as in S3 
	--  Canonical URI - filename for the AWS S3 object 
	--  
	--  
	-- Revisions: 
	-- 		JUN 2021	rewritten with make_request_b and simplifying code 
	-- 
	------------------------------------------------------------------------------ 
/* sample procedure call 
declare 
	l_blob	blob; 
    l_clob		clob;    
	l_url 	varchar2(1000); 
	l_key		varchar2(1000); 
begin 
for x in ( 
	select  
		doc_pk, 
		name, 
		doc_mimetype, 
		doc_filename, 
		s3_bucket, 
		s3_filename 
	from tg_document 
	where doc_pk = 492966 
) loop 
	if substr(x.s3_filename, 1, 1) <> '/' then 
		l_key := '/' || x.s3_filename; 
	else 
		l_key := x.s3_filename; 
	end if; -- start with slash? 
	dbms_output.put_line(l_key);	    
	l_url := aws4_s3_pkg.get_object_url (    
		P_BUCKET 				=> x.s3_bucket,    
		P_CANONICAL_URI	=> l_key,    
		P_DATE					=> localtimestamp    
		);    
	dbms_output.put_line(l_url);    
	l_blob := aws4_s3_pkg.get_object_blob (    
		P_BUCKET 				=> x.s3_bucket,    
		P_CANONICAL_URI	=> l_key);    
	insert into aws_blob (    
		aws_blob,    
		created_date,    
		blob_mimetype,    
		blob_filename    
	) values (    
		l_blob,    
		get_current_date,    
		x.doc_mimetype,    
		x.doc_filename    
	);    
end loop;    
end;    
*/ AS 
        l_url        VARCHAR2(4000); 
        l_blob       BLOB; 
        l_procedure  VARCHAR2(100) := g_package || '.get_object_blob'; 
    BEGIN 
        l_url := aws4_s3_pkg.get_object_url( 
                    p_bucket => p_bucket,  
                    p_canonical_uri => p_canonical_uri,  
                    p_date => sysdate); 
        l_blob := apex_web_service.make_rest_request_b( 
                    p_url => l_url,  
                    p_http_method => 'GET', 
                    p_wallet_path => g_wallet_path, 
                    p_wallet_pwd => g_wallet_pwd); 
        RETURN l_blob; 
    END get_object_blob; 
    FUNCTION get_object_blob2 ( 
        p_url IN VARCHAR2 
    ) RETURN BLOB 
	------------------------------------------------------------------------------ 
	-- Function: 	Get Object BLOB 
	-- Author:		Christina Moore 
	-- Date:			04JUN2021 
	-- Version:		2 
	-- 
	-- Returns a BLOB  
	-- Parameters 
	-- 	URL after being prepared by aws4_s3_pkg.get_object_url 
	--  
	--  
	-- Revisions: 
	-- 
	------------------------------------------------------------------------------ 
     AS 
        l_blob       BLOB; 
        l_procedure  VARCHAR2(100) := g_package || '.get_object_blob2'; 
    BEGIN 
        l_blob := apex_web_service.make_rest_request_b(p_url => p_url, p_http_method => 'GET', 
                                                      p_wallet_path => g_wallet_path, 
                                                      p_wallet_pwd => g_wallet_pwd); 
        RETURN l_blob; 
    END get_object_blob2; 
    PROCEDURE get_object_list ( 
        p_bucket       IN   VARCHAR2, 
        p_prefix       IN   VARCHAR2, 
        p_max_keys     IN   NUMBER, 
        p_object_list  OUT  t_object_list 
    )    
-------------------------------------------------------------------------------- 
	-- Function: 	Get Object list    
	-- Author:		Christina Moore    
	-- Date:			10FEB2017    
	-- Version:		2.0    
	--    
	-- Get a list of the Objects within a bucket    
	-- Parameters    
	-- 	Bucket - bucket name, lower case, exact as in S3    
	--  Prefix - the folder (AWS calls it a prefix)    
	--	Max Keys	-- maximum number of objects to return (1000 is a hard max)    
	-- Results are returned in P_OBJECT_LIST    
	--     
	-- Prefix - do not shart with a slash    
	-- Max Keys is a parameter sent to AWS. If the number of keys exceeds the    
	-- max keys, you will get TRUE on IsTruncated. if you ask for 10 keys    
	-- and there are more than 10 keys, you will get 10 keys and     
	-- IsTruncated = TRUE.     
	--     
	-- Revisions:   
    --		jun 2021 - consolidate with rest_request_clob 
	--    
	------------------------------------------------------------------------------    
     AS    
	------------------------------------------------------------------------------    
	--    
	--	Sample Code for Calling Function    
	--    
	------------------------------------------------------------------------------    
/*    
declare    
  l_object_list					aws4_s3_pkg.t_object_list;    
begin    
	aws4_s3_pkg.get_object_list(    
		p_bucket 			=> 'tempest-software',    
		p_prefix			=> 'STORMPETREL/000000161/000000125/',    
		p_max_keys		=> 1000,    
		p_object_list	=> l_object_list    
		);    
	-- how many items returned    
	dbms_output.put_line('Object Count = ' || to_char(l_object_list.count));    
	-- list the objects    
	for i in 1 .. l_object_list.count loop    
		dbms_output.put('Object: ');    
		dbms_output.put(l_object_list(i).key);    
		dbms_output.put(' Size Bytes: ');    
		dbms_output.put(l_object_list(i).size_bytes);    
		dbms_output.put(' Last: ');    
		dbms_output.put_line(l_object_list(i).last_modified);    
	end loop;    
end;    
*/ 
        l_query_string       VARCHAR2(4000); 
        l_query_string_root  VARCHAR2(4000); 
        l_more               BOOLEAN := true; 
        l_count              PLS_INTEGER := 0; 
        l_max_keys           NUMBER := 100000; -- safety valve on loop    
        l_clob               CLOB; 
        l_xml                XMLTYPE; 
        l_object_list        t_object_list; 
        l_last_key           VARCHAR2(1000); 
        l_http_status_code   VARCHAR2(10); 
        l_procedure          VARCHAR2(40) := g_package || '.get_object_list';    
    BEGIN   
	-- List Object Version 2 requires list-type=2    
        l_query_string := 'list-type=2'; 
        IF p_max_keys IS NOT NULL THEN 
            l_query_string := l_query_string 
                              || amp 
                              || 'max-keys=' 
                              || trim(to_char(p_max_keys));		-- cmoore 29APR2019 change equal to %3D 
            l_max_keys := p_max_keys; 
        END IF; -- max keys null    
        IF p_prefix IS NOT NULL THEN 
            l_query_string := l_query_string 
                              || '&prefix=' 
                              || p_prefix; 
        END IF; 
        l_query_string_root := l_query_string; 
        WHILE 
            l_more 
            AND l_count < l_max_keys 
        LOOP 
            l_clob := rest_request_clob( 
                        p_bucket => lower(p_bucket),  
                        p_http_method => 'GET',  
                        p_object => '/', 
                        p_query_string => l_query_string, 
                        p_http_status_code => l_http_status_code); 
        IF l_http_status_code = '200' THEN 
            IF 
                ( l_clob IS NOT NULL ) 
                AND ( dbms_lob.getlength(l_clob) > 0 ) 
            THEN 
                l_xml := xmltype(l_clob); 
                check_for_errors(l_xml); 
                FOR l_rec IN ( 
                    SELECT 
                        extractvalue(value(t), '*/Key', g_aws_namespace_s3_full)                   AS key, 
                        extractvalue(value(t), '*/Size', g_aws_namespace_s3_full)                  AS size_bytes, 
                        extractvalue(value(t), '*/LastModified', g_aws_namespace_s3_full)          AS last_modified 
                    FROM 
                        TABLE ( xmlsequence(l_xml.extract('//ListBucketResult/Contents', g_aws_namespace_s3_full)) ) t 
                ) LOOP 
                    l_count := l_count + 1; 
                    l_object_list(l_count).key := l_rec.key; 
                    l_object_list(l_count).size_bytes := l_rec.size_bytes; 
                    l_object_list(l_count).last_modified := to_date(l_rec.last_modified, g_date_format_xml); 
                END LOOP; -- loop xml data    
			-- check if this is the last set of data or not    
                l_xml := l_xml.extract('//ListBucketResult/IsTruncated/text()', g_aws_namespace_s3_full); 
                IF 
                    l_xml IS NOT NULL 
                    AND l_xml.getstringval = 'true' 
                THEN 
                    l_last_key := l_object_list(l_object_list.last).key; 
                    l_more := true; 
                ELSE 
                    l_more := false; 
                    l_last_key := NULL; 
                END IF; -- end of the list?    
            END IF; -- AWS clob is not null   		    
		-- Prepare for the next iteration    
            l_query_string := l_query_string_root 
                              || amp 
                              || 'start-after=' 
                              || l_last_key; 
        ELSE  
			-- kill the loop 
                l_more := false; 
                l_count := l_max_keys; 
            END IF; -- status code <> '200'                       
        END LOOP; -- get all records and safety valve    
        p_object_list := l_object_list; 
    END get_object_list; 
    FUNCTION get_object_url ( 
        p_bucket         IN  VARCHAR2, 
        p_canonical_uri  IN  VARCHAR2, 
        p_date           IN  DATE, 
        p_expiry         IN  NUMBER DEFAULT 3600 
    ) RETURN VARCHAR2    
	------------------------------------------------------------------------------    
	-- Function: 	Signature String    
	-- Author:		Christina Moore    
	-- Date:			09FEB2017    
	-- Version:		0.1    
	--    
	-- Created the URL to download an object from AWS S3    
	-- Parameters    
	-- 	Bucket - bucket name, lower case, exact as in S3    
	--	Canonical URI - the document key e.g. folder and document name. Do not include the bucket, do include slsh 
	-- 	Date	- the date    
	--  Expiry	- expiration of the request in seconds. Defaults to 5 min    
	--     
	--    
	-- Revisions:    
	--	0.1		cmoore 03MAY2017    
	--		using local URL escape function to accommodate the ampersand    
	------------------------------------------------------------------------------    
    /* sample call 
select 
	aws4_s3_pkg.get_object_url ( 
		P_BUCKET						=>'xxxxxxx', 
		P_CANONICAL_URI			=>'/MVI_0016.MP4', 
		P_DATE							=>sysdate, 
		P_EXPIRY						=>3600 
		) as url 
from dual; 
*/ AS 
        l_bucket          VARCHAR2(50); 
        l_date_string     VARCHAR2(50); 
        l_time_string     VARCHAR2(50); 
        l_expiry          VARCHAR2(10); 
        l_host            VARCHAR2(50); 
        l_url             VARCHAR2(4000); 
        l_req_canonical   VARCHAR2(1000); 
        l_algo            VARCHAR2(4000); 
        l_request         VARCHAR2(4000); 
        l_request_hashed  VARCHAR2(1000); 
        l_string_to_sign  VARCHAR2(4000); 
        l_signature       VARCHAR2(1000); 
        l_procedure       VARCHAR2(100) := g_package || '.get_object_url'; 
    BEGIN 
        IF p_bucket IS NULL THEN 
            raise_application_error(-20000, 'Bucket Name is null in ' || l_procedure); 
        ELSE 
            l_bucket := lower(p_bucket); 
        END IF; 
        l_date_string := to_char(p_date, 'YYYYMMDD'); 
        l_time_string := iso_8601(p_date); 
        l_expiry := trim(to_char(p_expiry));    
	-- manage the bucket name    
        l_host := 'host:s3.amazonaws.com'; 
        l_url := 'https://s3.amazonaws.com/' || l_bucket;    
	-- manage the canonical URI    
	-- cmoore 03MAY2017 - Oracle Escape does not escape the ampersand    
        l_url := aws4_escape(l_url || p_canonical_uri); 
        l_req_canonical := aws4_escape('/' 
                                       || p_bucket 
                                       || p_canonical_uri);    
	-- manage the algorithm    
        l_algo := 'X-Amz-Algorithm=AWS4-HMAC-SHA256&' 
                  || 'X-Amz-Credential=' 
                  || g_aws_id 
                  || slsh 
                  || l_date_string 
                  || slsh 
                  || g_aws_region 
                  || slsh 
                  || 's3' 
                  || slsh 
                  || 'aws4_request' 
                  || amp 
                  || 'X-Amz-Date=' 
                  || l_time_string 
                  || amp 
                  || 'X-Amz-Expires=' 
                  || l_expiry 
                  || amp 
                  || 'X-Amz-SignedHeaders=host'; 
        l_url := l_url 
                 || '?' 
                 || l_algo;    
	-- Build the Canonical Request    
        l_request := 'GET' || lf; 
        l_request := l_request 
                     || l_req_canonical 
                     || lf; 
        l_request := l_request 
                     || l_algo 
                     || lf; 
        l_request := l_request 
                     || l_host 
                     || lf; 
        l_request := l_request || lf; 
        l_request := l_request 
                     || 'host' 
                     || lf; 
        l_request := l_request || 'UNSIGNED-PAYLOAD';    
	-- Hash the Canonical Request	    
        l_request_hashed := lower(aws4_sha256(l_request));       
	-- Generate the String to Sign    
        l_string_to_sign := signature_string(p_request_hashed => l_request_hashed, p_date => p_date);     
	-- Generate the Signature    
        l_signature := aws4_signing_key(p_string_to_sign => l_string_to_sign, p_date => p_date);    
	-- add signature to the URL    
        l_url := l_url 
                 || amp 
                 || 'X-Amz-Signature=' 
                 || l_signature;    
	-- Return the URL    
        RETURN l_url; 
    END get_object_url; 
    PROCEDURE object_head ( 
        p_bucket         IN   VARCHAR2, 
        p_prefix         IN   VARCHAR2, 
        p_object         IN   VARCHAR2, 
        p_etag           OUT  VARCHAR2, 
        p_length         OUT  NUMBER, 
        p_create_date    OUT  DATE, 
        p_modified_date  OUT  DATE 
    )  
-------------------------------------------------------------------------------- 
-- Function: 	object head 
-- Author:		Jaydip Bosamiya 
-- Date:			24 oct 2018 
-- Version:		2.0 
-- 
-- Revisions: 
-- 	25 apr 2019 cmoore, changing HTTPS call to use wallet from lookup 
--	08JUN2021	cmoore - consolidated call for internal procedure:  
--			rest_request_clob 
-------------------------------------------------------------------------------- 
/* 
declare  
	P_BUCKET					varchar2(100) := 'xxxx'; 
  P_PREFIX					varchar2(100) := '/'; 
  P_OBJECT					varchar2(100) := '/gems4/122/0000000015304/0000000015790/0000000008537/FEMA_Form_90-91_911_-__16-JAN-18-2034.pdf'; 
  l_object_info     varchar2(4000); 
  l_etag            varchar2(4000); 
  l_length          number; 
  l_crt_date        date; 
  l_mod_date        date; 
begin 
	aws4_s3_pkg.object_head (P_BUCKET,P_PREFIX,P_OBJECT,l_etag,l_length,l_crt_date,l_mod_date); 
	dbms_output.put_line('l_etag='||l_etag); 
  dbms_output.put_line('l_length='||l_length); 
  dbms_output.put_line('l_crt_date='||l_crt_date); 
  dbms_output.put_line('l_mod_date='||l_mod_date); 
  dbms_output.put_line(l_object_info); 
end; 
*/ AS 
        l_http_status_code  VARCHAR2(20); 
        l_clob              CLOB; 
        l_xml               XMLTYPE; 
        l_count             NUMBER := 0; 
        l_procedure         VARCHAR2(40) := g_package || '.object_head'; 
    BEGIN 
        l_clob := rest_request_clob(p_bucket => p_bucket, p_http_method => 'HEAD', p_object => p_object, 
                                   p_query_string => NULL, 
                                   p_http_status_code => l_http_status_code); 
        IF l_http_status_code = '200' THEN 
            FOR i IN 1..apex_web_service.g_headers.count LOOP 
                l_clob := l_clob 
                          || apex_web_service.g_headers(i).name 
                          || ':'; 
                l_clob := l_clob 
                          || apex_web_service.g_headers(i).value 
                          || lf; 
                CASE 
                    WHEN lower(apex_web_service.g_headers(i).name) = 'etag' THEN 
                        p_etag := apex_web_service.g_headers(i).value; 
                    WHEN lower(apex_web_service.g_headers(i).name) = 'content-length' THEN 
                        p_length := apex_web_service.g_headers(i).value; 
                    WHEN lower(apex_web_service.g_headers(i).name) = 'date' THEN 
                        p_create_date := to_timestamp_tz(apex_web_service.g_headers(i).value, 'Dy, DD Mon YYYY HH24:MI:SS TZR'); 
                    WHEN lower(apex_web_service.g_headers(i).name) = 'last-modified' THEN 
                        p_modified_date := to_timestamp_tz(apex_web_service.g_headers(i).value, 'Dy, DD Mon YYYY HH24:MI:SS TZR'); 
                    ELSE 
                        NULL; 
                END CASE; 
            END LOOP; 
        END IF; 
    END object_head; 
 
    FUNCTION put_object ( 
        p_bucket      IN  VARCHAR2, 
        p_blob        IN  BLOB, 
        p_object_key  IN  VARCHAR2, 
        p_mimetype    IN  VARCHAR2 
    ) RETURN NUMBER   
	------------------------------------------------------------------------------    
	-- Function: 	Put Object    
	-- Author:		Christina Moore    
	-- Date:			11FEB2017    
	-- Version:		0.1    
	--    
	-- Puts a blob on S3    
	-- Parameters    
	-- 	Bucket - bucket name, lower case, exact as in S3    
	-- 	BLOB	- the blob    
	--	Object key - the filename plus the prefix     
	-- 	Mimetype - the mimetype of the blob    
	--     
	--    
	-- Revisions:    
	--    
	------------------------------------------------------------------------------    
	------------------------------------------------------------------------------    
	--    
	--	Sample Code for Calling Procedure    
	--    
	------------------------------------------------------------------------------    
/*    
declare    
	l_filename				varchar2(100);    
	l_blob						blob;    
	l_mimetype				varchar2(100);    
	l_content_length	number;    
begin    
	select    
		doc_blob,    
		doc_mimetype,    
		doc_filename,    
		dbms_lob.getlength(doc_blob)    
	into    
		l_blob,    
		l_mimetype,    
		l_filename,    
		l_content_length    
	from tg_document    
	where doc_pk = 5;    
	--dbms_output.put_line('filename:' || l_filename);    
	--dbms_output.put_line('Mime Type: ' || l_mimetype);    
	--dbms_output.put_line('Content Length: ' || trim(to_char(l_content_length)));    
	l_filename := '/' || l_filename;    
	aws4_s3_pkg.put_object(    
		P_BUCKET				=> 'xxxxxxxxx', 
		P_BLOB					=> l_blob,    
		P_OBJECT_KEY		=> l_filename,    
		P_MIMETYPE			=> l_mimetype    
	);    
end;    
*/ 
    AS   
        l_date               DATE; 
        l_date_string        VARCHAR2(50); 
        l_time_string        VARCHAR2(50); 
        l_http_method        VARCHAR2(10); 
        l_query_string       VARCHAR2(4000); 
        l_query_string_root  VARCHAR2(4000); 
        l_canonical_uri      VARCHAR2(100) := '/'; 
        l_signature          VARCHAR2(4000); 
        l_canonical_request  VARCHAR2(4000); -- used for debugging    
        l_url                VARCHAR2(4000); 
        l_payload_hash       VARCHAR2(100); 
        l_clob               CLOB; 
        l_xml                XMLTYPE; 
        l_content_length     NUMBER;    
        l_procedure          VARCHAR2(100) := g_package || '.put_object'; 
	-- notes on debugging    
	-- 1. this calls the Alexandria DEBUG_PKG    
	-- 2. You'll need to go into that package body and set m_debugging := true    
	-- 3. You'll need to compile the Alexandria DEBUG_PKG Body    
	-- 4. You'll then also need to turn the local debug option to true    
        l_debug              BOOLEAN := false; 
    BEGIN 
        l_date := systimestamp - (3/24); 
        l_date_string := to_char(l_date, 'YYYYMMDD'); 
        l_time_string := iso_8601(l_date); 
        l_http_method := 'PUT'; 
        l_query_string := '';    
	-- calculate the payload hash    
        l_payload_hash := aws4_sha256(p_blob);    
	-- calculate the content length    
        l_content_length := dbms_lob.getlength(p_blob); 
        l_signature := prep_aws_data( 
                        p_bucket => p_bucket,  
                        p_http_method => l_http_method,  
                        p_canonical_uri => p_object_key, 
                        p_query_string => l_query_string, 
                        p_date => l_date, 
                        p_content_length => l_content_length, 
                        p_canonical_request => l_canonical_request, 
                        p_payload_hash => l_payload_hash, 
                        p_url => l_url); 
        apex_web_service.g_request_headers.DELETE(); 
        apex_web_service.g_request_headers(1).name := 'Authorization'; 
        apex_web_service.g_request_headers(1).value := g_aws4_auth 
                                                       || ' Credential=' 
                                                       || g_aws_id 
                                                       || '/' 
                                                       || l_date_string 
                                                       || '/' 
                                                       || g_aws_region 
                                                       || '/s3/aws4_request,' 
                                                       || ' SignedHeaders=host;x-amz-content-sha256;x-amz-date,' 
                                                       || ' Signature=' 
                                                       || l_signature; 
        apex_web_service.g_request_headers(2).name := 'x-amz-content-sha256'; 
        apex_web_service.g_request_headers(2).value := l_payload_hash; 
        apex_web_service.g_request_headers(3).name := 'x-amz-date'; 
        apex_web_service.g_request_headers(3).value := l_time_string; 
        apex_web_service.g_request_headers(4).name := 'Content-Type'; 
        apex_web_service.g_request_headers(4).value := nvl(p_mimetype, 'application/octet-stream'); 
        apex_web_service.g_request_headers(5).name := 'Content-Length'; 
        apex_web_service.g_request_headers(5).value := l_content_length; 
        l_clob := apex_web_service.make_rest_request( 
                    p_url => l_url,  
                    p_http_method => l_http_method, 
                    p_wallet_path => g_wallet_path, 
                    p_wallet_pwd => g_wallet_pwd, 
                    p_body_blob => p_blob, 
                    p_https_host => g_https_host
                ); 
        IF l_clob IS NOT NULL THEN 
            SYSTEM_CONTROLS.ERROR_LOGS(p_ERROR_TYPE => 'SYSTEM_ERROR',p_PROCESS_NAME => 'aws4_s3_pkg.put_object',p_ERROR_CODE => -2,p_ERROR_MESSAGE => SUBSTR(l_clob, 1, 4000), p_logger_name => user); 
            DBMS_OUTPUT.PUT_LINE(l_clob); 
            DBMS_OUTPUT.PUT_LINE(l_date_string); 
            DBMS_OUTPUT.PUT_LINE(l_time_string); 
            DBMS_OUTPUT.PUT_LINE(l_date); 
            RETURN -2; 
        ELSE 
            RETURN 1; 
        END IF;          
    END put_object;
 
    FUNCTION delete_object2 ( 
        p_bucket      IN  VARCHAR2, 
        p_object      IN  VARCHAR2 
    ) RETURN NUMBER  AS   
        l_date               DATE; 
        l_date_string        VARCHAR2(50); 
        l_time_string        VARCHAR2(50); 
        l_http_method        VARCHAR2(10); 
        l_query_string       VARCHAR2(4000); 
        l_query_string_root  VARCHAR2(4000); 
        l_canonical_uri      VARCHAR2(100) := '/'; 
        l_signature          VARCHAR2(4000); 
        l_canonical_request  VARCHAR2(4000); -- used for debugging    
        l_url                VARCHAR2(4000); 
        l_payload_hash       VARCHAR2(100); 
        l_clob               CLOB; 
        l_xml                XMLTYPE; 
        l_content_length     NUMBER;    
        l_procedure          VARCHAR2(100) := g_package || '.delete_object'; 
	-- notes on debugging    
	-- 1. this calls the Alexandria DEBUG_PKG    
	-- 2. You'll need to go into that package body and set m_debugging := true    
	-- 3. You'll need to compile the Alexandria DEBUG_PKG Body    
	-- 4. You'll then also need to turn the local debug option to true    
        l_debug              BOOLEAN := false; 
    BEGIN 
        l_date := systimestamp - (3/24); 
        l_date_string := to_char(l_date, 'YYYYMMDD'); 
        l_time_string := iso_8601(l_date); 
        l_http_method := 'DELETE'; 
        l_query_string := '';    
	-- calculate the payload hash    
        l_payload_hash := g_null_hash;    
	-- calculate the content length    
    --    l_content_length := dbms_lob.getlength(p_blob); 
        l_signature := prep_aws_data( 
                        p_bucket => p_bucket,  
                        p_http_method => l_http_method,  
                        p_canonical_uri => p_object, 
                        p_query_string => l_query_string, 
                        p_date => l_date, 
           --             p_content_length => l_content_length, 
                        p_canonical_request => l_canonical_request, 
                        p_payload_hash => l_payload_hash, 
                        p_url => l_url); 
        apex_web_service.g_request_headers.DELETE(); 
        apex_web_service.g_request_headers(1).name := 'Authorization'; 
        apex_web_service.g_request_headers(1).value := g_aws4_auth 
                                                       || ' Credential=' 
                                                       || g_aws_id 
                                                       || '/' 
                                                       || l_date_string 
                                                       || '/' 
                                                       || g_aws_region 
                                                       || '/s3/aws4_request,' 
                                                       || ' SignedHeaders=host;x-amz-content-sha256;x-amz-date,' 
                                                       || ' Signature=' 
                                                       || l_signature; 
        apex_web_service.g_request_headers(2).name := 'x-amz-content-sha256'; 
        apex_web_service.g_request_headers(2).value := l_payload_hash; 
        apex_web_service.g_request_headers(3).name := 'x-amz-date'; 
        apex_web_service.g_request_headers(3).value := l_time_string;/* 
        apex_web_service.g_request_headers(4).name := 'Content-Type'; 
        apex_web_service.g_request_headers(4).value := nvl(p_mimetype, 'application/octet-stream'); 
        apex_web_service.g_request_headers(5).name := 'Content-Length'; 
        apex_web_service.g_request_headers(5).value := l_content_length;*/ 
        l_clob := apex_web_service.make_rest_request( 
                    p_url => l_url,  
                    p_http_method => l_http_method, 
                    p_wallet_path => g_wallet_path, 
                    p_wallet_pwd => g_wallet_pwd/*, 
                    p_body_blob => p_blob, 
                    p_https_host => g_https_host*/); 
        IF l_clob IS NOT NULL THEN 
            SYSTEM_CONTROLS.ERROR_LOGS(p_ERROR_TYPE => 'SYSTEM_ERROR',p_PROCESS_NAME => 'aws4_s3_pkg.put_object',p_ERROR_CODE => -2,p_ERROR_MESSAGE => SUBSTR(l_clob, 1, 4000), p_logger_name => user); 
            DBMS_OUTPUT.PUT_LINE(l_clob); 
            DBMS_OUTPUT.PUT_LINE(l_date_string); 
            DBMS_OUTPUT.PUT_LINE(l_time_string); 
            DBMS_OUTPUT.PUT_LINE(l_date); 
            RETURN -2; 
        ELSE 
            RETURN 1; 
        END IF;    
    END delete_object2; 
END aws4_s3_pkg;
/