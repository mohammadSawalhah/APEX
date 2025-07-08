
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."REGA" AS

    FUNCTION advertisement_validator (
        p_adLicense_number  IN NUMBER,
        p_advertiser_id     IN NUMBER,
        p_id_type           IN NUMBER,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message          OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION advertisement_create_ad_license (
        p_body              IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message           OUT VARCHAR2
    ) RETURN CLOB;

    FUNCTION insert_response (
        p_body              IN CLOB,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message           OUT VARCHAR2
    ) RETURN NUMBER;

END "REGA";
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."REGA" as

    g_base_url              CONSTANT VARCHAR2(1000) := 'https://integration-gw.nhc.sa/nhc/prod';
    g_client_id             CONSTANT VARCHAR2(1000) := '';
    g_client_secret         CONSTANT VARCHAR2(1000) := '';
    g_test_base_url         CONSTANT VARCHAR2(1000) := 'https://integration-gw.housingapps.sa/nhc/dev';
    g_test_client_id        CONSTANT VARCHAR2(1000) := 'ffcc52e8cae6de3c61b675ee95cac832';
    g_test_client_secret    CONSTANT VARCHAR2(1000) := 'c682758679ffbf8abc36763791d7e753';

--<AWS_SECRET>=========================================================  
--================================= END OF GLOBAL VARIABLES =======================================
--=================================================================================================

    FUNCTION advertisement_validator  (
        p_adLicense_number  IN NUMBER,
        p_advertiser_id     IN NUMBER,
        p_id_type           IN NUMBER,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message           OUT VARCHAR2
    ) RETURN CLOB IS
        l_url       VARCHAR2(1000);
        l_clob      CLOB;
        v_reda_id   NUMBER;
    BEGIN
        IF p_adLicense_number IS NULL OR p_advertiser_id IS NULL OR p_id_type IS NULL THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        -- l_url := 'hhttps://demo.backend.mobasher.sa/rega-integration';
        l_url := 'https://backend-general.mobasher.sa/rega?adLicenseNumber=' || p_adLicense_number || '&advertiserId=' || p_advertiser_id || '&idType=' || p_id_type;

        INSERT INTO REGA_LOGS ( ADLICENSE_NUMBER, ADVERTISER_NUMBER, ID_TYPE, URL )
            VALUES ( p_adLicense_number, p_advertiser_id, p_id_type, l_url )
        RETURNING ID INTO v_reda_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN '-3';
        END IF;

        l_clob := apex_web_service.make_rest_request ( 
                    p_url         => l_url,
                    p_http_method => 'GET'
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'REGA.create_account', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || l_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );

            APEX_JSON.parse(l_clob);
            p_message := 'REGA Request Error with Status: ' || apex_web_service.g_status_code || ' Message: ' || apex_json.get_varchar2('Header.Status.Description');
            RETURN '-100003';
        END IF;

        APEX_JSON.parse(l_clob);

        UPDATE REGA_LOGS
           SET CODE         = APEX_JSON.get_varchar2('Header.Status.Code'),
               MESSAGE      = APEX_JSON.get_varchar2('Header.Status.Description'),
               STATUS       = SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang),
               RESPONSE     = SUBSTR(l_clob, 1, 4000)
         WHERE ID = v_reda_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := 'Updating Error! - ' || v_reda_id;
            RETURN '-4';
        END IF;

        p_message := apex_json.get_varchar2('Header.Status.Description') || ' - ' || apex_json.get_varchar2('Body.result.message');
        RETURN l_clob;
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM || ' - Request Status: ' || apex_web_service.g_status_code || ' -- '
                                 || APEX_JSON.get_varchar2('Header.Status.Code') || ' -- '
                                 || APEX_JSON.get_varchar2('Header.Status.Description');
            RETURN l_clob;
    END advertisement_validator;

--=================================================================================================  
--=================================== END OF THE FUNCTION =========================================
--=================================================================================================

    FUNCTION advertisement_create_ad_license (
        p_body              IN VARCHAR2,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message           OUT VARCHAR2
    ) RETURN CLOB IS
        json        apex_json.t_values;
        l_url       VARCHAR2(1000);
        v_body       VARCHAR2(32000);
        l_clob      CLOB;
        v_reda_id   NUMBER;
    BEGIN
        IF p_body IS NULL  THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN '-2';
        END IF;

        l_url := 'https://demo.backend.mobasher.sa/rega-integration/createADLicense';
        -- l_url := 'https://backend-master.mobasher.sa/rega-integration/createADLicense';

        INSERT INTO REGA_LOGS ( REQUEST_BODY, URL )
            VALUES ( SUBSTR(p_body, 1, 4000), l_url )
        RETURNING ID INTO v_reda_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN '-3';
        END IF;

        apex_web_service.g_request_headers.DELETE;
        apex_web_service.g_request_headers(1).name := 'Content-Type';
        apex_web_service.g_request_headers(1).value := 'multipart/form-data';

        l_clob := apex_web_service.make_rest_request ( 
                    p_url         => l_url,
                    p_http_method => 'POST',
                    p_body        => p_body
                );

        IF apex_web_service.g_status_code NOT IN ( 200, 201, 202, 203, 204, 205, 206, 207, 226 ) THEN
            SYSTEM_CONTROLS.error_logs( p_error_type => 'REST_ERROR', p_process_name => 'REGA.create_account', p_error_code => - 100003,
                                        p_error_message => 'REST Request to '
                                       || l_url
                                       || ' faild with status_code: '
                                       || apex_web_service.g_status_code
                                       || ' Reason phrase: '
                                       || apex_web_service.g_reason_phrase
                                    );

            APEX_JSON.parse(json, l_clob);
            p_message := 'REGA Request Error! Status: ' || apex_web_service.g_status_code || ' Message: ' || apex_json.get_varchar2('message') || ' Error: ' || apex_json.get_clob('errors');
            RETURN l_clob;
        END IF;

        APEX_JSON.parse(json, l_clob);

        UPDATE REGA_LOGS
           SET CODE         = apex_web_service.g_status_code,
               MESSAGE      = apex_json.get_varchar2('message'),
               STATUS       = SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang),
               RESPONSE     = SUBSTR(l_clob, 1, 4000)
         WHERE ID = v_reda_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := 'Updating Error! - ' || v_reda_id;
            RETURN '-4';
        END IF;

        p_message := l_clob;
        RETURN '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_message := SQLERRM || ' - Request Status: ' || apex_web_service.g_status_code || ' -- ' || apex_json.get_varchar2(p_path => 'Header.Status.Description', p0 => 1, p_values => json);
            RETURN l_clob;

END advertisement_create_ad_license;

--=================================================================================================  
--=================================== END OF THE FUNCTION =========================================
--=================================================================================================

    FUNCTION insert_response (
        p_body              IN CLOB,
        p_lang              IN VARCHAR2 DEFAULT 'en',
        p_message           OUT VARCHAR2
    ) RETURN NUMBER IS
        l_platform_owner_id                         NUMBER;
        l_platform_name                             VARCHAR2(255);
        l_ad_license_number                         VARCHAR2(255);
        l_ad_license_creation_date                  DATE;
        l_ad_license_end_date                       DATE;
        l_title_deed_number                         VARCHAR2(255);      
        l_brokerage_and_marketing_license_number    VARCHAR2(255);                       
        l_is_valid                                  VARCHAR2(255);
        l_advertiser_id                             VARCHAR2(255);  
        -- l_deed_number                               VARCHAR2(255); -- duplicated
        l_advertiser_name                           VARCHAR2(255); 
        l_advertiser_phone_number                   VARCHAR2(255); 
        l_is_constrained                            VARCHAR2(255); 
        l_is_pawned                                 VARCHAR2(255); 
        l_is_halted                                 VARCHAR2(255); 
        l_is_testment                               VARCHAR2(255); 
        l_rer_constraints                           CLOB;
        l_street_width                              VARCHAR2(255); 
        l_property_area                             VARCHAR2(255); 
        l_property_price                            VARCHAR2(255); 
        l_land_total_price                          VARCHAR2(255); 
        l_land_total_annual_rent                    VARCHAR2(255); 
        l_number_of_rooms                           VARCHAR2(255); 
        l_property_type                             VARCHAR2(255); 
        l_property_age                              VARCHAR2(255); 
        l_advertisement_type                        VARCHAR2(255); 
        l_location                                  CLOB;
        l_region                                    VARCHAR2(255); 
        l_region_code                               VARCHAR2(255);                            
        l_city                                      VARCHAR2(255); 
        l_city_code                                 VARCHAR2(255); 
        l_district                                  VARCHAR2(255); 
        l_district_code                             VARCHAR2(255); 
        l_street                                    VARCHAR2(255); 
        l_postal_code                               VARCHAR2(255); 
        l_building_number                           VARCHAR2(255); 
        l_additional_number                         VARCHAR2(255); 
        l_longitude                                 VARCHAR2(255); 
        l_latitude                                  VARCHAR2(255); 
        l_property_face                             VARCHAR2(255);   
        l_plan_number                               VARCHAR2(255); 
        l_land_number                               VARCHAR2(255); 
        l_obligations_on_the_property               VARCHAR2(255);                 
        l_guarantees_and_their_duration             VARCHAR2(255);                          
        l_compliance_with_the_saudi_building_code   VARCHAR2(255);                    
        l_channels                                  CLOB;
        l_property_usages                           CLOB;  
        l_property_utilities                        CLOB;  
        l_ad_license_url                            VARCHAR2(255);   
        l_ad_source                                 VARCHAR2(255); 
        l_title_deed_type_name                      VARCHAR2(255);          
        l_location_descriptionon_moj_deed           VARCHAR2(255);                 
        l_notes                                     VARCHAR2(255);         
        l_borders_moj                               CLOB;
        l_north_limit_name                           VARCHAR2(255);     
        l_north_limit_description                    VARCHAR2(255);     
        l_north_limit_length_char                    VARCHAR2(255);     
        l_east_limit_name                            VARCHAR2(255);     
        l_east_limit_description                     VARCHAR2(255);     
        l_east_limit_length_char                     VARCHAR2(255);     
        l_west_limit_name                            VARCHAR2(255);     
        l_west_limit_description                     VARCHAR2(255);     
        l_west_limit_length_char                     VARCHAR2(255);     
        l_south_limit_name                           VARCHAR2(255);     
        l_south_limit_description                    VARCHAR2(255);     
        l_south_limit_length_char                    VARCHAR2(255);  
        l_rerborders_rer                             CLOB;  
        -- l_response                                   CLOB;

    BEGIN

        -- APEX_JSON.parse(p_body);
/*
        DECLARE
           l_nums   json_array_t := json_array_t ('["Good", "Morning", "seham"]');
        BEGIN
            FOR i IN 0 .. l_nums.get_size - 1 LOOP
                DBMS_OUTPUT.put_line (l_nums.get_string(i));
           END LOOP;
        END;
*/
        -- l_platform_owner_id                         := APEX_JSON.get_number('platformOwnerId');
        -- l_platform_name                             := APEX_JSON.get_varchar2('platformName');        
        -- l_ad_license_number                         := APEX_JSON.get_varchar2('adLicenseNumber');             
        -- l_ad_license_creation_date                  := APEX_JSON.get_date('creationDate');                    
        -- l_ad_license_end_date                       := APEX_JSON.get_date('adLicenseEndDate');                
        -- l_title_deed_number                         := APEX_JSON.get_varchar2('titleDeedNumber');             
        -- l_brokerage_and_marketing_license_number    := APEX_JSON.get_varchar2('brokerageAndMarketingLicenseNumber');                                     
        -- -- l_is_valid                                  := APEX_JSON.get_boolean ('isValid'); adObject
        -- l_is_valid                                  := case when (APEX_JSON.get_boolean ('adObject.isValid')) = true then 1 else 0 end;
        -- l_advertiser_id                             := APEX_JSON.get_varchar2('adObject.advertiserId');        
        -- l_deed_number                               := APEX_JSON.get_varchar2('adObject.deedNumber');        
        -- l_advertiser_name                           := APEX_JSON.get_varchar2('adObject.advertiserName');            
        -- l_advertiser_phone_number                   := APEX_JSON.get_varchar2('adObject.phoneNumber');                    
        -- l_is_constrained                            := APEX_JSON.get_varchar2('adObject.isConstrained');   --decode         
        -- l_is_pawned                                 := APEX_JSON.get_varchar2('adObject.isPawned');    --decode
        -- l_is_halted                                 := APEX_JSON.get_varchar2('adObject.isHalted');    --decode
        -- l_is_testment                               := APEX_JSON.get_varchar2('adObject.isTestment');  --decode       
        -- l_rer_constraints                           := APEX_JSON.get_clob('adObject.rerConstraints');                                       
        -- l_street_width                              := APEX_JSON.get_varchar2('adObject.streetWidth');            
        -- l_property_area                             := APEX_JSON.get_varchar2('adObject.propertyArea');            
        -- l_property_price                            := APEX_JSON.get_varchar2('adObject.propertyPrice');                
        -- l_land_total_price                          := APEX_JSON.get_varchar2('adObject.landTotalPrice');                
        -- l_land_total_annual_rent                    := APEX_JSON.get_varchar2('adObject.landTotalAnnualRent');                        
        -- l_number_of_rooms                           := APEX_JSON.get_varchar2('adObject.numberOfRooms');                
        -- l_property_type                             := APEX_JSON.get_varchar2('adObject.propertyType');            
        -- l_property_age                              := APEX_JSON.get_varchar2('adObject.propertyAge');            
        -- l_advertisement_type                        := APEX_JSON.get_varchar2('adObject.advertisementType');                                         
        -- l_location                                  := APEX_JSON.get_clob('adObject[%d].location');   -- array  
        -- l_region                                    := APEX_JSON.get_varchar2('adObject.location.region');     
        -- l_region_code                               := APEX_JSON.get_varchar2('adObject.location.regionCode');     
        -- l_city                                      := APEX_JSON.get_varchar2('adObject.location.city');     
        -- l_city_code                                 := APEX_JSON.get_varchar2('adObject.location.cityCode');     
        -- l_district                                  := APEX_JSON.get_varchar2('adObject.location.district');     
        -- l_district_code                             := APEX_JSON.get_varchar2('adObject.location.districtCode');     
        -- l_street                                    := APEX_JSON.get_varchar2('adObject.location.street');     
        -- l_postal_code                               := APEX_JSON.get_varchar2('adObject.location.postalCode');     
        -- l_building_number                           := APEX_JSON.get_varchar2('adObject.location.buildingNumber');     
        -- l_additional_number                         := APEX_JSON.get_varchar2('adObject.location.additionalNumber');     
        -- l_longitude                                 := APEX_JSON.get_varchar2('adObject.location.longitude');     
        -- l_latitude                                  := APEX_JSON.get_varchar2('adObject.location.latitude');    
        -- l_property_face                             := APEX_JSON.get_varchar2('adObject.propertyFace');            
        -- l_plan_number                               := APEX_JSON.get_varchar2('adObject.planNumber');            
        -- l_land_number                               := APEX_JSON.get_varchar2('adObject.landNumber');            
        -- l_obligations_on_the_property               := APEX_JSON.get_varchar2('adObject.obligationsOnTheProperty');                            
        -- l_guarantees_and_their_duration             := APEX_JSON.get_varchar2('adObject.guaranteesAndTheirDuration');                            
        -- -- l_compliance_with_the_saudi_building_code   := APEX_JSON.get_boolean ('complianceWithTheSaudiBuildingCode'); 
        -- l_compliance_with_the_saudi_building_code   := case when (APEX_JSON.get_boolean ('adObject.complianceWithTheSaudiBuildingCode')) = true then 1 else 0 end;                                 
        -- l_channels                                  := APEX_JSON.get_clob('adObject[%d].channels');      -- array  
        -- l_property_usages                           := APEX_JSON.get_clob('adObject[%d].propertyUsages');    -- array              
        -- l_property_utilities                        := APEX_JSON.get_clob('adObject[%d].propertyUtilities');   -- array                  
        -- l_ad_license_url                            := APEX_JSON.get_varchar2('adObject.adLicenseUrl');                 
        -- l_ad_source                                 := APEX_JSON.get_varchar2('adObject.adSource');          
        -- l_title_deed_type_name                      := APEX_JSON.get_varchar2('adObject.titleDeedTypeName');                      
        -- l_location_descriptionon_moj_deed           := APEX_JSON.get_varchar2('adObject.locationDescriptionOnMOJDeed');                                  
        -- l_notes                                     := APEX_JSON.get_varchar2('adObject.notes');      
        -- l_borders_moj                               := APEX_JSON.get_clob('adObject[%d].borders');
        -- l_north_limit_name                          := APEX_JSON.get_varchar2('adObject.borders.northLimitName');     
        -- l_north_limit_description                   := APEX_JSON.get_varchar2('adObject.borders.northLimitDescription');     
        -- l_north_limit_length_char                   := APEX_JSON.get_varchar2('adObject.borders.northLimitLengthChar');     
        -- l_east_limit_name                           := APEX_JSON.get_varchar2('adObject.borders.eastLimitName');     
        -- l_east_limit_description                    := APEX_JSON.get_varchar2('adObject.borders.eastLimitDescription');     
        -- l_east_limit_length_char                    := APEX_JSON.get_varchar2('adObject.borders.eastLimitLengthChar');     
        -- l_west_limit_name                           := APEX_JSON.get_varchar2('adObject.borders.westLimitName');     
        -- l_west_limit_description                    := APEX_JSON.get_varchar2('adObject.borders.westLimitDescription');     
        -- l_west_limit_length_char                    := APEX_JSON.get_varchar2('adObject.borders.westLimitLengthChar');     
        -- l_south_limit_name                          := APEX_JSON.get_varchar2('adObject.borders.southLimitName');     
        -- l_south_limit_description                   := APEX_JSON.get_varchar2('adObject.borders.southLimitDescription');     
        -- l_south_limit_length_char                   := APEX_JSON.get_varchar2('adObject.borders.southLimitLengthChar');          
        -- l_rerborders_rer                            := APEX_JSON.get_clob('adObject[%d].rerBorders');             
        -- l_response                                  := p_body;

        -- INSERT INTO REGA_INDIVIDUAL_CREATE_REQUESTS (PLATFORM_OWNER_ID, PLATFORM_NAME, AD_LICENSE_NUMBER, AD_LICENSE_CREATION_DATE, AD_LICENSE_END_DATE, TITLE_DEED_NUMBER, BROKERAGE_AND_MARKETING_LICENSE_NUMBER, 
        --                                             IS_VALID, ADVERTISER_ID, DEED_NUMBER, ADVERTISER_NAME, ADVERTISER_PHONE_NUMBER, IS_CONSTRAINED, IS_PAWNED, IS_HALTED, IS_TESTMENT, RER_CONSTRAINTS, STREET_WIDTH, 
        --                                             PROPERTY_AREA, PROPERTY_PRICE, LAND_TOTAL_PRICE, LAND_TOTAL_ANNUAL_RENT, NUMBER_OF_ROOMS, PROPERTY_TYPE, PROPERTY_AGE, ADVERTISEMENT_TYPE, LOCATION, PROPERTY_FACE, 
        --                                             PLAN_NUMBER, LAND_NUMBER, OBLIGATIONS_ON_THE_PROPERTY, GUARANTEES_AND_THEIR_DURATION, COMPLIANCE_WITH_THE_SAUDI_BUILDING_CODE, CHANNELS, PROPERTY_USAGES, 
        --                                             PROPERTY_UTILITIES, AD_LICENSE_URL, AD_SOURCE, TITLE_DEED_TYPE_NAME, LOCATION_DESCRIPTIONON_MOJ_DEED, NOTES, BORDERS_MOJ, RERBORDERS_RER, REGION, REGION_CODE, CITY, CITY_CODE, 
        --                                             DISTRICT, DISTRICT_CODE, STREET, POSTAL_CODE, BUILDING_NUMBER, ADDITIONAL_NUMBER, LONGITUDE, LATITUDE, NORTH_LIMIT_NAME, NORTH_LIMIT_DESCRIPTION, NORTH_LIMIT_LENGTH_CHAR, 
        --                                             EAST_LIMIT_NAME, EAST_LIMIT_DESCRIPTION, EAST_LIMIT_LENGTH_CHAR, WEST_LIMIT_NAME, WEST_LIMIT_DESCRIPTION, WEST_LIMIT_LENGTH_CHAR, SOUTH_LIMIT_NAME, SOUTH_LIMIT_DESCRIPTION, 
        --                                             SOUTH_LIMIT_LENGTH_CHAR, RESPONSE
        --     ) VALUES (
        --         l_platform_owner_id, l_platform_name, l_ad_license_number, l_ad_license_creation_date, l_ad_license_end_date, l_title_deed_number, l_brokerage_and_marketing_license_number, l_is_valid, 
        --         l_advertiser_id, l_deed_number, l_advertiser_name, l_advertiser_phone_number, DECODE(l_is_constrained,'true',1,'false',0), DECODE(l_is_pawned,'true',1,'false',0), DECODE(l_is_halted,'true',1,'false',0), 
        --         DECODE(l_is_testment,'true',1,'false',0), l_rer_constraints, l_street_width, l_property_area, l_property_price, 
        --         l_land_total_price, l_land_total_annual_rent, l_number_of_rooms, l_property_type, l_property_age, l_advertisement_type, l_location, l_property_face, l_plan_number, l_land_number, l_obligations_on_the_property, 
        --         l_guarantees_and_their_duration, l_compliance_with_the_saudi_building_code, l_channels, l_property_usages, l_property_utilities, l_ad_license_url, l_ad_source, l_title_deed_type_name, 
        --         l_location_descriptionon_moj_deed, l_notes, l_borders_moj, l_rerborders_rer, l_region, l_region_code, l_city, l_city_code, l_district, l_district_code, l_street, l_postal_code, l_building_number, l_additional_number,
        --         l_longitude, l_latitude, l_north_limit_name, l_north_limit_description, l_north_limit_length_char, l_east_limit_name, l_east_limit_description, l_east_limit_length_char, l_west_limit_name, l_west_limit_description,
        --         l_west_limit_length_char, l_south_limit_name, l_south_limit_description, l_south_limit_length_char, l_response
        --     );

        -- IF SQL%ROWCOUNT = 0 THEN 
        --     p_message := 'Insertion Error! ';
        --     RETURN '-2';
        -- END IF;


        SELECT jt.platformOwnerId, jt.platformName, jt.adLicenseNumber, jt.creationDate, jt.adLicenseEndDate, jt.titleDeedNumber, jt.brokerageAndMarketingLicenseNumber, jt.isValid, jt.advertiserId, jt.advertiserName, jt.phoneNumber, 
               jt.isConstrained, jt.isPawned, jt.isHalted, jt.isTestment, jt.rerConstraints,  jt.streetWidth, jt.propertyArea, jt.propertyPrice, jt.landTotalPrice, jt.landTotalAnnualRent, jt.numberOfRooms, jt.propertyType, jt.propertyAge, 
               jt.advertisementType, jt.location,  jt.region, jt.regionCode, jt.city, jt.cityCode, jt.district, jt.districtCode, jt.street, jt.postalCode, jt.buildingNumber, jt.additionalNumber, jt.longitude, jt.latitude, jt.propertyFace, 
               jt.planNumber, jt.landNumber, jt.obligationsOnTheProperty, jt.guaranteesAndTheirDuration, jt.complianceWithTheSaudiBuildingCode, ArrayToStr(jt.channels),  ArrayToStr(jt.propertyUsages),  ArrayToStr(jt.propertyUtilities),  
               jt.adLicenseUrl, jt.adSource, jt.titleDeedTypeName, jt.locationDescriptionOnMOJDeed, jt.notes, jt.borders,  jt.northLimitName, jt.northLimitDescription, jt.northLimitLengthChar, jt.eastLimitName, jt.eastLimitDescription, 
               jt.eastLimitLengthChar, jt.westLimitName, jt.westLimitDescription, jt.westLimitLengthChar, jt.southLimitName, jt.southLimitDescription, jt.southLimitLengthChar, ArrayToStr(jt.rerBorders)

          INTO l_platform_owner_id, l_platform_name, l_ad_license_number, l_ad_license_creation_date, l_ad_license_end_date, l_title_deed_number, l_brokerage_and_marketing_license_number, l_is_valid, l_advertiser_id, l_advertiser_name, l_advertiser_phone_number, 
               l_is_constrained, l_is_pawned, l_is_halted, l_is_testment, l_rer_constraints, l_street_width, l_property_area, l_property_price, l_land_total_price, l_land_total_annual_rent, l_number_of_rooms, l_property_type, l_property_age, 
               l_advertisement_type, l_location, l_region, l_region_code, l_city, l_city_code, l_district, l_district_code, l_street, l_postal_code, l_building_number, l_additional_number, l_longitude, l_latitude, l_property_face, 
               l_plan_number, l_land_number, l_obligations_on_the_property, l_guarantees_and_their_duration, l_compliance_with_the_saudi_building_code, l_channels, l_property_usages, l_property_utilities, l_ad_license_url, l_ad_source, 
               l_title_deed_type_name, l_location_descriptionon_moj_deed, l_notes, l_borders_moj, l_north_limit_name, l_north_limit_description, l_north_limit_length_char, l_east_limit_name, l_east_limit_description, l_east_limit_length_char, 
               l_west_limit_name, l_west_limit_description, l_west_limit_length_char, l_south_limit_name, l_south_limit_description, l_south_limit_length_char, l_rerborders_rer
          FROM
          JSON_TABLE ( p_body,
             '$'
                COLUMNS (
                    platformOwnerId                     number path '$.platformOwnerId' ,
                    platformName                        varchar2(100)  path '$.platformName',
                    adLicenseNumber                     varchar2(100)  path '$.adLicenseNumber' ,
                    creationDate                        date  path '$.creationDate', 
                    adLicenseEndDate                    date  path '$.adLicenseEndDate',
                    titleDeedNumber                     varchar2(100) path '$.titleDeedNumber',
                    brokerageAndMarketingLicenseNumber  varchar2(100) path '$.brokerageAndMarketingLicenseNumber',
                    isValid                             varchar2(100) path '$.adObject.isValid',
                    advertiserId                        varchar2(100) path '$.adObject.advertiserId',
                    advertiserName                      varchar2(100) path '$.adObject.advertiserName',
                    phoneNumber                         varchar2(100) path '$.adObject.phoneNumber',
                    isConstrained                       varchar2(100) path '$.adObject.isConstrained',
                    isPawned                            varchar2(100) path '$.adObject.isPawned',
                    isHalted                            varchar2(100) path '$.adObject.isHalted',
                    isTestment                          varchar2(100) path '$.adObject.isTestment',
                    rerConstraints                      varchar2(100) path '$.adObject.rerConstraints', -- array
                    streetWidth                         varchar2(100) path '$.adObject.streetWidth',
                    propertyArea                        varchar2(100) path '$.adObject.propertyArea',
                    propertyPrice                       varchar2(100) path '$.adObject.propertyPrice',
                    landTotalPrice                      varchar2(100) path '$.adObject.landTotalPrice',
                    landTotalAnnualRent                 varchar2(100) path '$.adObject.landTotalAnnualRent',
                    numberOfRooms                       varchar2(100) path '$.adObject.numberOfRooms',
                    propertyType                        varchar2(100) path '$.adObject.propertyType',
                    propertyAge                         varchar2(100) path '$.adObject.propertyAge',
                    advertisementType                   varchar2(100) path '$.adObject.advertisementType', 
                    location                            varchar2(4000) format json path '$.adObject.location', -- obj
                    region                              varchar2(100) path '$.adObject.location.region', 
                    regionCode                          varchar2(100) path '$.adObject.location.regionCode', 
                    city                                varchar2(100) path '$.adObject.location.city', 
                    cityCode                            varchar2(100) path '$.adObject.location.cityCode', 
                    district                            varchar2(100) path '$.adObject.location.district', 
                    districtCode                        varchar2(100) path '$.adObject.location.districtCode', 
                    street                              varchar2(100) path '$.adObject.location.street', 
                    postalCode                          varchar2(100) path '$.adObject.location.postalCode', 
                    buildingNumber                      varchar2(100) path '$.adObject.location.buildingNumber', 
                    additionalNumber                    varchar2(100) path '$.adObject.location.additionalNumber', 
                    longitude                           varchar2(100) path '$.adObject.location.longitude', 
                    latitude                            varchar2(100) path '$.adObject.location.latitude',
                    propertyFace                        varchar2(100) path '$.adObject.propertyFace',
                    planNumber                          varchar2(100) path '$.adObject.planNumber',
                    landNumber                          varchar2(100) path '$.adObject.landNumber',
                    obligationsOnTheProperty            varchar2(100) path '$.adObject.obligationsOnTheProperty',
                    guaranteesAndTheirDuration          varchar2(100) path '$.adObject.guaranteesAndTheirDuration', 
                    complianceWithTheSaudiBuildingCode  varchar2(100) path '$.adObject.complianceWithTheSaudiBuildingCode',
                    channels                            varchar2(100) format json path '$.adObject.channels', --arr
                    propertyUsages                      varchar2(100) format json path '$.adObject.propertyUsages', --arr
                    propertyUtilities                   varchar2(100) format json path '$.adObject.propertyUtilities', --arr
                    adLicenseUrl                        varchar2(100) path '$.adObject.adLicenseUrl', 
                    adSource                            varchar2(100) path '$.adObject.adSource',
                    titleDeedTypeName                   varchar2(100) path '$.adObject.titleDeedTypeName',
                    locationDescriptionOnMOJDeed        varchar2(100) path '$.adObject.locationDescriptionOnMOJDeed',
                    notes                               varchar2(100) path '$.adObject.notes',
                    borders                             varchar2(4000) format json path '$.adObject.borders', -- obj
                    northLimitName                      varchar2(100) path '$.adObject.borders.northLimitName',                      
                    northLimitDescription               varchar2(100) path '$.adObject.borders.northLimitDescription',          
                    northLimitLengthChar                varchar2(100) path '$.adObject.borders.northLimitLengthChar',          
                    eastLimitName                       varchar2(100) path '$.adObject.borders.eastLimitName',  
                    eastLimitDescription                varchar2(100) path '$.adObject.borders.eastLimitDescription',          
                    eastLimitLengthChar                 varchar2(100) path '$.adObject.borders.eastLimitLengthChar',     
                    westLimitName                       varchar2(100) path '$.adObject.borders.westLimitName',  
                    westLimitDescription                varchar2(100) path '$.adObject.borders.westLimitDescription',          
                    westLimitLengthChar                 varchar2(100) path '$.adObject.borders.westLimitLengthChar',      
                    southLimitName                      varchar2(100) path '$.adObject.borders.southLimitName',  
                    southLimitDescription               varchar2(100) path '$.adObject.borders.southLimitDescription',          
                    southLimitLengthChar                varchar2(100) path '$.adObject.borders.southLimitLengthChar',        
                    rerBorders                          varchar2(100) format json path '$.adObject.rerBorders' -- array
                )
        ) AS jt;

        INSERT INTO REGA_INDIVIDUAL_CREATE_REQUESTS (PLATFORM_OWNER_ID, PLATFORM_NAME, AD_LICENSE_NUMBER, AD_LICENSE_CREATION_DATE, AD_LICENSE_END_DATE, TITLE_DEED_NUMBER, 
                                BROKERAGE_AND_MARKETING_LICENSE_NUMBER, IS_VALID, REGA_ADVERTISER_ID, ADVERTISER_NAME, ADVERTISER_PHONE_NUMBER, IS_CONSTRAINED, IS_PAWNED, IS_HALTED, 
                                IS_TESTMENT, RER_CONSTRAINTS, STREET_WIDTH, PROPERTY_AREA, PROPERTY_PRICE, LAND_TOTAL_PRICE, LAND_TOTAL_ANNUAL_RENT, NUMBER_OF_ROOMS, PROPERTY_TYPE, 
                                PROPERTY_AGE, ADVERTISEMENT_TYPE, LOCATION, REGION, REGION_CODE, CITY, CITY_CODE, DISTRICT, DISTRICT_CODE, STREET, POSTAL_CODE, BUILDING_NUMBER, 
                                ADDITIONAL_NUMBER, LONGITUDE, LATITUDE, PROPERTY_FACE,  PLAN_NUMBER, LAND_NUMBER, OBLIGATIONS_ON_THE_PROPERTY, GUARANTEES_AND_THEIR_DURATION, 
                                COMPLIANCE_WITH_THE_SAUDI_BUILDING_CODE, CHANNELS, PROPERTY_USAGES, PROPERTY_UTILITIES, AD_LICENSE_URL, AD_SOURCE, TITLE_DEED_TYPE_NAME, 
                                LOCATION_DESCRIPTIONON_MOJ_DEED, NOTES, BORDERS_MOJ, NORTH_LIMIT_NAME, NORTH_LIMIT_DESCRIPTION, NORTH_LIMIT_LENGTH_CHAR, EAST_LIMIT_NAME, 
                                EAST_LIMIT_DESCRIPTION, EAST_LIMIT_LENGTH_CHAR, WEST_LIMIT_NAME, WEST_LIMIT_DESCRIPTION, WEST_LIMIT_LENGTH_CHAR, SOUTH_LIMIT_NAME, 
                                SOUTH_LIMIT_DESCRIPTION, SOUTH_LIMIT_LENGTH_CHAR, RERBORDERS_RER, RESPONSE
        ) VALUES (
            l_platform_owner_id, l_platform_name, l_ad_license_number, l_ad_license_creation_date, l_ad_license_end_date, l_title_deed_number, l_brokerage_and_marketing_license_number, 
            DECODE(l_is_valid,'true',1,'false',0), l_advertiser_id, l_advertiser_name, l_advertiser_phone_number, DECODE(l_is_constrained,'true',1,'false',0), 
            DECODE(l_is_pawned,'true',1,'false',0), DECODE(l_is_halted,'true',1,'false',0), DECODE(l_is_testment,'true',1,'false',0), l_rer_constraints, l_street_width, l_property_area, 
            l_property_price, l_land_total_price, l_land_total_annual_rent, l_number_of_rooms, l_property_type, l_property_age, l_advertisement_type, l_location, l_region, l_region_code, 
            l_city, l_city_code, l_district, l_district_code, l_street, l_postal_code, l_building_number, l_additional_number, l_longitude, l_latitude,l_property_face, l_plan_number, 
            l_land_number, l_obligations_on_the_property, l_guarantees_and_their_duration, DECODE(l_compliance_with_the_saudi_building_code,'true',1,'false',0), l_channels, 
            l_property_usages, l_property_utilities, l_ad_license_url, l_ad_source, l_title_deed_type_name, l_location_descriptionon_moj_deed, l_notes, l_borders_moj, l_north_limit_name, 
            l_north_limit_description, l_north_limit_length_char, l_east_limit_name, l_east_limit_description, l_east_limit_length_char, l_west_limit_name, l_west_limit_description, 
            l_west_limit_length_char, l_south_limit_name, l_south_limit_description, l_south_limit_length_char,  l_rerborders_rer, p_body
        );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := 'Insertion Error! ';
            RETURN '-2';
        END IF;

        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'success', p_lang => p_lang);
        RETURN 1;

    END insert_response;

--=================================================================================================  
--=================================== END OF THE FUNCTION =========================================
--=================================================================================================
END "REGA";
/