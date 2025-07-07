
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."PRODUCT" AS

     FUNCTION create_products (
         -- from products table
         p_seller_id                            IN NUMBER,
         p_type                                 IN VARCHAR2,
         p_name_ar                              IN VARCHAR2,
         p_city_id                              IN NUMBER,
         p_video_url                            IN VARCHAR2,
         p_category_id                          IN NUMBER,
         p_subcategory_id                       IN NUMBER,
         p_other_category                       IN VARCHAR2 DEFAULT NULL,
         p_reference_no                         IN NUMBER,
         p_desc_ar                              IN VARCHAR2,
         p_address_ar                           IN VARCHAR2,
         p_map_url                              IN VARCHAR2,
      --    p_images_url                           IN VARCHAR2,
         p_main_image_url                       IN VARCHAR2,

         -- from real estate details table
         p_instrument_no                        IN NUMBER,
         p_neighbourhoods_id                    IN NUMBER,
         P_street_name_ar                       IN VARCHAR2,
         p_is_there_mortgage                    IN NUMBER,
         p_is_rights_and_obligations            IN NUMBER,
         p_is_information_that_affect_property  IN NUMBER,
         p_there_mortgage_ar                    IN VARCHAR2,
         p_information_that_affect_property_ar  IN VARCHAR2,
         p_rights_and_obligations_ar            IN VARCHAR2,
         p_usage_id                             IN NUMBER,
         p_facade_id                            IN NUMBER,
         p_ad_sub_type_id                       IN NUMBER,
         p_space                                IN NUMBER,
         p_street_width                         IN NUMBER,
         p_construction_date                    IN DATE,
         p_governorate                          IN VARCHAR2,
                           
         -- from car details table
         p_make_id                              IN NUMBER,
         p_model_id                             IN NUMBER,
         p_year                                 IN NUMBER,
         p_external_color                       IN NUMBER,
         p_odo_meter                            IN NUMBER,
         p_is_document                          IN NUMBER,
         p_is_inspection                        IN NUMBER,
         p_document_url                         IN VARCHAR2,
         p_inspection_url                       IN VARCHAR2,
         p_fuel_type                            IN NUMBER,
         p_chassis_number                       IN NUMBER,
         p_is_drowned                           IN NUMBER,
         p_is_burned                            IN NUMBER,
         p_is_accident                          IN NUMBER,
         p_vehichle_category                    IN VARCHAR2,
         p_plate_number                         IN VARCHAR2,
         p_sequency_number                      IN VARCHAR2,
         p_drowing_info                         IN VARCHAR2,
         p_drowing_file_url                     IN VARCHAR2,
         p_burn_info                            IN VARCHAR2,
         p_burn_file_url                        IN VARCHAR2,
         p_accident_info                        IN VARCHAR2,
         p_accident_file_url                    IN VARCHAR2,

         -- others
         p_lang                                 IN VARCHAR2 DEFAULT 'ar',
         p_message                             OUT VARCHAR2,
         p_id                                  OUT VARCHAR2
) RETURN NUMBER;
--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION UPDATE_PRODUCTS(
                -- from products table
        P_product_id                           IN NUMBER,
        p_seller_id                            IN NUMBER,
        p_type                                 IN VARCHAR2,
        p_name_ar                              IN VARCHAR2,
        p_city_id                              IN NUMBER,
        p_video_url                            IN VARCHAR2,
        p_category_id                          IN NUMBER,
        p_subcategory_id                       IN NUMBER,
        -- p_other_category                       IN VARCHAR2 DEFAULT NULL,
        p_reference_no                         IN NUMBER,
        p_desc_ar                              IN VARCHAR2,
        p_address_ar                           IN VARCHAR2,
        p_map_url                              IN VARCHAR2,
        --    p_images_url                           IN VARCHAR2,
        --    p_main_image_url                       IN VARCHAR2,
        
        -- from real estate details table
        p_instrument_no                        IN NUMBER,
        p_neighbourhoods_id                    IN NUMBER,
        P_street_name_ar                       IN VARCHAR2,
        p_is_there_mortgage                    IN NUMBER,
        p_is_rights_and_obligations            IN NUMBER,
        p_is_information_that_affect_property  IN NUMBER,
        p_there_mortgage_ar                    IN VARCHAR2,
        p_information_that_affect_property_ar  IN VARCHAR2,
        p_rights_and_obligations_ar            IN VARCHAR2,
        p_usage_id                             IN NUMBER,
        p_facade_id                            IN NUMBER,
        p_ad_sub_type_id                       IN NUMBER,
        p_space                                IN NUMBER,
        p_street_width                         IN NUMBER,
        p_construction_date                    IN DATE,
        p_governorate                          IN VARCHAR2,
        -- from car details table
        p_make_id                              IN NUMBER,
        p_model_id                             IN NUMBER,
        p_year                                 IN NUMBER,
        p_external_color                       IN NUMBER,
        p_odo_meter                            IN NUMBER,
        p_is_document                          IN NUMBER,
        p_is_inspection                        IN NUMBER,
        -- p_document_url                         IN VARCHAR2,
        -- p_inspection_url                       IN VARCHAR2,
        p_fuel_type                            IN NUMBER,
        p_chassis_number                       IN NUMBER,
        -- p_is_drowned                           IN NUMBER,
        -- p_is_burned                            IN NUMBER,
        -- p_is_accident                          IN NUMBER,
        p_vehichle_category                    IN VARCHAR2,
        p_plate_number                         IN VARCHAR2,
        p_sequency_number                      IN VARCHAR2,
        -- p_drowing_info                         IN VARCHAR2,
        -- p_drowing_file_url                     IN VARCHAR2,
        -- p_burn_info                            IN VARCHAR2,
        -- p_burn_file_url                        IN VARCHAR2,
        -- p_accident_info                        IN VARCHAR2,
        -- p_accident_file_url                    IN VARCHAR2,
        -- others
        -- P_dimensions_facade_id                 IN NUMBER,
        -- P_dimensions_description_ar            IN VARCHAR2,
        -- P_service_id                           IN NUMBER,
        -- P_service_description_ar               IN VARCHAR2,
        p_lang                                 IN VARCHAR2 DEFAULT 'ar',
        p_message                             OUT VARCHAR2
    ) RETURN NUMBER;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_product (
        p_product_id     IN NUMBER,
        p_category_id    IN NUMBER,
        p_subcategory_id IN NUMBER,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2
    ) RETURN NUMBER;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION category_code_by_id (
        p_category_id NUMBER
    ) RETURN VARCHAR2;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION sub_category_code_by_id (
        p_sub_category_id NUMBER
    ) RETURN VARCHAR2;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION product_status_id_by_product_id (
        p_product_id NUMBER
    ) RETURN NUMBER;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END PRODUCT;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."PRODUCT" AS

 FUNCTION create_products (
        -- from products table
         p_seller_id                            IN NUMBER,
         p_type                                 IN VARCHAR2,
         p_name_ar                              IN VARCHAR2,
         p_city_id                              IN NUMBER,
         p_video_url                            IN VARCHAR2,
         p_category_id                          IN NUMBER,
         p_subcategory_id                       IN NUMBER,
         p_other_category                       IN VARCHAR2 DEFAULT NULL,
         p_reference_no                         IN NUMBER,
         p_desc_ar                              IN VARCHAR2,
         p_address_ar                           IN VARCHAR2,
         p_map_url                              IN VARCHAR2,
      --    p_images_url                           IN VARCHAR2,
         p_main_image_url                       IN VARCHAR2,

         -- from real estate details table
         p_instrument_no                        IN NUMBER,
         p_neighbourhoods_id                    IN NUMBER,
         P_street_name_ar                       IN VARCHAR2,
         p_is_there_mortgage                    IN NUMBER,
         p_is_rights_and_obligations            IN NUMBER,
         p_is_information_that_affect_property  IN NUMBER,
         p_there_mortgage_ar                    IN VARCHAR2,
         p_information_that_affect_property_ar  IN VARCHAR2,
         p_rights_and_obligations_ar            IN VARCHAR2,
         p_usage_id                             IN NUMBER,
         p_facade_id                            IN NUMBER,
         p_ad_sub_type_id                       IN NUMBER,
         p_space                                IN NUMBER,
         p_street_width                         IN NUMBER,
         p_construction_date                    IN DATE,
         p_governorate                          IN VARCHAR2,
                           
         -- from car details table
         p_make_id                              IN NUMBER,
         p_model_id                             IN NUMBER,
         p_year                                 IN NUMBER,
         p_external_color                       IN NUMBER,
         p_odo_meter                            IN NUMBER,
         p_is_document                          IN NUMBER,
         p_is_inspection                        IN NUMBER,
         p_document_url                         IN VARCHAR2,
         p_inspection_url                       IN VARCHAR2,
         p_fuel_type                            IN NUMBER,
         p_chassis_number                       IN NUMBER,
         p_is_drowned                           IN NUMBER,
         p_is_burned                            IN NUMBER,
         p_is_accident                          IN NUMBER,
         p_vehichle_category                    IN VARCHAR2,
         p_plate_number                         IN VARCHAR2,
         p_sequency_number                      IN VARCHAR2,
         p_drowing_info                         IN VARCHAR2,
         p_drowing_file_url                     IN VARCHAR2,
         p_burn_info                            IN VARCHAR2,
         p_burn_file_url                        IN VARCHAR2,
         p_accident_info                        IN VARCHAR2,
         p_accident_file_url                    IN VARCHAR2,

         -- others
         p_lang                                 IN VARCHAR2 DEFAULT 'ar',
         p_message                             OUT VARCHAR2,
         p_id                                  OUT VARCHAR2
) RETURN NUMBER IS
         v_product_id NUMBER;
         v_count      NUMBER;
BEGIN
    -- check if all the requirments are filled
    IF p_seller_id IS NULL OR p_type IS NULL OR p_city_id IS NULL OR p_category_id IS NULL OR p_subcategory_id IS NULL OR p_name_ar IS NULL OR
       p_address_ar IS NULL OR p_map_url IS NULL OR p_main_image_url IS NULL THEN
        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
        RETURN -2;
    END IF;
    
    INSERT INTO PRODUCTS (SELLER_ID,TYPE_ID,NAME_AR,CITY_ID, VIDEO_URL,CATEGORY_ID,SUB_CATEGORY_ID,OTHER_CATEGORY,
    REFERENCE_NO,DESCRIPTION_AR,ADDRESS_AR,MAP_URL,MAIN_IMAGE_URL,STATUS,IS_ACTIVE)
        VALUES   (p_seller_id, p_type,p_name_ar, p_city_id, p_video_url, p_category_id, p_subcategory_id,p_other_category,
        p_reference_no, p_desc_ar, p_address_ar, p_map_url, p_main_image_url,LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'available', p_lookup_code => 'product_status'), 1)
    RETURNING ID INTO v_product_id;

    IF SQL%ROWCOUNT = 0 THEN 
        p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
        RETURN -5;
        ROLLBACK;
    END IF;
    p_id := v_product_id;

    -- check if the category id = 1 'real estate' then its required fields are filled
    IF PRODUCT.category_code_by_id (p_category_id => p_category_id) = 'real_estates' THEN
        IF p_instrument_no IS NULL OR p_is_there_mortgage IS NULL OR p_is_rights_and_obligations IS NULL OR
           p_is_information_that_affect_property IS NULL OR p_usage_id IS NULL OR p_ad_sub_type_id IS NULL OR p_space IS NULL THEN
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                RETURN -3;
        END IF;

        -- Check if instrument no exists
         SELECT COUNT(1)
           INTO v_count
          FROM  REAL_STATE_DETAILS r,
                PRODUCTS p
          WHERE p.ID = r.PRODUCT_ID
                AND r.INSTRUMENT_NO = TRIM(p_instrument_no)
                AND p.SELLER_ID = p_seller_id;
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'instrument_number_exists', p_lang => p_lang);
            RETURN -4;
            ROLLBACK;
        END IF;

        INSERT INTO REAL_STATE_DETAILS (PRODUCT_ID,AD_TYPE_ID,INSTRUMENT_NO, NEIGHBOURHOODS_ID,STREET_NAME_AR, IS_THERE_MORTGAGE, IS_RIGHTS_AND_OBLIGATIONS, IS_INFORMATION_THAT_AFFECT_PROPERTY,
            THERE_MORTGAGE_AR, RIGHTS_AND_OBLIGATIONS_AR, INFORMATION_THAT_AFFECT_PROPERTY_AR, USAGE_ID, FACADE_ID, AD_SUB_TYPE_ID, SPACE, STREET_WIDTH, CONSTRUCTION_DATE, GOVERNORATE, IS_ACTIVE)
            VALUES (v_product_id, null, p_instrument_no, p_neighbourhoods_id, p_street_name_ar, p_is_there_mortgage, p_is_rights_and_obligations, p_is_information_that_affect_property ,p_there_mortgage_ar,
                   p_rights_and_obligations_ar, p_information_that_affect_property_ar, p_usage_id, p_facade_id, p_ad_sub_type_id, p_space, p_street_width, p_construction_date, p_governorate, 1);
        
        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -6;
            ROLLBACK;
        END IF;
    END IF;

    -- check if the category id = 2  and sub category = 1 'cars' then its required fields are filled
    IF PRODUCT.category_code_by_id (p_category_id => p_category_id) = 'portable' AND PRODUCT.sub_category_code_by_id (p_sub_category_id => p_subcategory_id) = 'cars' THEN
        IF p_make_id IS NULL OR p_model_id IS NULL OR p_chassis_number IS NULL THEN
           p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -7;
        END IF;

        -- Check if chassis no exists
         SELECT COUNT(1)
           INTO v_count
          FROM  CAR_DETAILS c,
                PRODUCTS p
          WHERE p.ID = c.PRODUCT_ID
                AND c.CHASSIS_NUMBER = TRIM(p_chassis_number)
                AND p.SELLER_ID = p_seller_id;
        
        IF v_count > 0 THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'chassis_number_exists', p_lang => p_lang);
            RETURN -8;
            ROLLBACK;
        END IF;

        INSERT INTO CAR_DETAILS ( PRODUCT_ID, VEHICLE_MAKE_ID, VEHICLE_MODEL_ID, YEAR, VEHICLE_EXTERNAL_COLOR_ID, ODO_METER, IS_THERE_DOCUMENT, IS_THERE_INSPECTION, DOCUMENT_URL,
                                  INSPECTION_URL, FUEL_TYPE_ID, CHASSIS_NUMBER, IS_DROWNED, IS_BURNED, IS_ACTIVE, IS_ACCIDENT, VEHICHLE_CATEGORY, PLATE_NUMBER, SERIAL_NUMBER,
                                  DROWING_INFO, DROWING_FILE_URL, BURN_INFO, BURN_FILE_URL, ACCIDENT_INFO, ACCIDENT_FILE_URL )
            VALUES ( v_product_id, p_make_id, p_model_id, p_year, p_external_color, p_odo_meter, p_is_document, p_is_inspection, p_document_url, p_inspection_url, p_fuel_type,
                     p_chassis_number, p_is_drowned, p_is_burned, 1, p_is_accident, p_vehichle_category, p_plate_number, p_sequency_number, p_drowing_info, p_drowing_file_url,
                     p_burn_info, p_burn_file_url, p_accident_info, p_accident_file_url );

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -9;
            ROLLBACK;
        END IF;
    END IF; 

    RETURN 1;
END create_products;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION UPDATE_PRODUCTS(
                -- from products table
        P_product_id                           IN NUMBER,
        p_seller_id                            IN NUMBER,
        p_type                                 IN VARCHAR2,
        p_name_ar                              IN VARCHAR2,
        p_city_id                              IN NUMBER,
        p_video_url                            IN VARCHAR2,
        p_category_id                          IN NUMBER,
        p_subcategory_id                       IN NUMBER,
        -- p_other_category                       IN VARCHAR2 DEFAULT NULL,
        p_reference_no                         IN NUMBER,
        p_desc_ar                              IN VARCHAR2,
        p_address_ar                           IN VARCHAR2,
        p_map_url                              IN VARCHAR2,

        -- from real estate details table
        p_instrument_no                        IN NUMBER,
        p_neighbourhoods_id                    IN NUMBER,
        P_street_name_ar                       IN VARCHAR2,
        p_is_there_mortgage                    IN NUMBER,
        p_is_rights_and_obligations            IN NUMBER,
        p_is_information_that_affect_property  IN NUMBER,
        p_there_mortgage_ar                    IN VARCHAR2,
        p_information_that_affect_property_ar  IN VARCHAR2,
        p_rights_and_obligations_ar            IN VARCHAR2,
        p_usage_id                             IN NUMBER,
        p_facade_id                            IN NUMBER,
        p_ad_sub_type_id                       IN NUMBER,
        p_space                                IN NUMBER,
        p_street_width                         IN NUMBER,
        p_construction_date                    IN DATE,
        p_governorate                          IN VARCHAR2,

        -- from car details table
        p_make_id                              IN NUMBER,
        p_model_id                             IN NUMBER,
        p_year                                 IN NUMBER,
        p_external_color                       IN NUMBER,
        p_odo_meter                            IN NUMBER,
        p_is_document                          IN NUMBER,
        p_is_inspection                        IN NUMBER,
        -- p_document_url                         IN VARCHAR2,
        -- p_inspection_url                       IN VARCHAR2,
        p_fuel_type                            IN NUMBER,
        p_chassis_number                       IN NUMBER,
        -- p_is_drowned                           IN NUMBER,
        -- p_is_burned                            IN NUMBER,
        -- p_is_accident                          IN NUMBER,
        p_vehichle_category                    IN VARCHAR2,
        p_plate_number                         IN VARCHAR2,
        p_sequency_number                      IN VARCHAR2,
        -- p_drowing_info                         IN VARCHAR2,
        -- p_drowing_file_url                     IN VARCHAR2,
        -- p_burn_info                            IN VARCHAR2,
        -- p_burn_file_url                        IN VARCHAR2,
        -- p_accident_info                        IN VARCHAR2,
        -- p_accident_file_url                    IN VARCHAR2,

        -- others
        p_lang                                 IN VARCHAR2 DEFAULT 'ar',
        p_message                             OUT VARCHAR2
    ) RETURN NUMBER IS
        v_product_id NUMBER;
        v_count      NUMBER;
    BEGIN 
        -- check if all the requirments are filled
        -- OR p_category_id IS NULL OR p_subcategory_id IS NULL >> *
        IF  p_type IS NULL OR p_city_id IS NULL OR p_address_ar IS NULL OR p_map_url IS NULL OR p_name_ar IS NULL  THEN
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
            RETURN -2;
        END IF;

        UPDATE PRODUCTS
           SET SUB_CATEGORY_ID = p_subcategory_id,
               TYPE_ID         = p_type,
               NAME_AR         = p_name_ar,
               CITY_ID         = p_city_id,
               VIDEO_URL       = p_video_url, 
               REFERENCE_NO    = p_reference_no,
               DESCRIPTION_AR  = p_desc_ar,
               ADDRESS_AR      = p_address_ar, 
               MAP_URL         = p_map_url
         WHERE ID = P_product_id;

        IF SQL%ROWCOUNT = 0 THEN 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
            RETURN -3;
            ROLLBACK;
        END IF;

        -- check if the category id = 1 'real estate' then its required fields are filled
        IF LOOKUPS_MNT.category_code_by_id (p_category_id => p_category_id) = 'real_estates' THEN
            IF p_instrument_no IS NULL OR p_space IS NULL OR p_usage_id IS NULL OR p_ad_sub_type_id IS NULL OR p_is_there_mortgage IS NULL 
               OR p_is_rights_and_obligations IS NULL OR p_is_information_that_affect_property IS NULL THEN
                    p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                    RETURN -4;
            END IF;

            -- UPDATE REAL_STATE_DETAILS **
            UPDATE REAL_STATE_DETAILS
               SET INSTRUMENT_NO = p_instrument_no,
                   GOVERNORATE = p_governorate,
                   NEIGHBOURHOODS_ID = p_neighbourhoods_id,
                   STREET_NAME_AR = p_street_name_ar,
                   STREET_WIDTH = p_street_width,
                   SPACE = p_space,
                   IS_THERE_MORTGAGE = p_is_there_mortgage,
                   IS_RIGHTS_AND_OBLIGATIONS = p_is_rights_and_obligations,
                   IS_INFORMATION_THAT_AFFECT_PROPERTY = p_is_information_that_affect_property,
                   THERE_MORTGAGE_AR = p_there_mortgage_ar,
                   RIGHTS_AND_OBLIGATIONS_AR = p_rights_and_obligations_ar,
                   INFORMATION_THAT_AFFECT_PROPERTY_AR = p_information_that_affect_property_ar,
                   USAGE_ID = p_usage_id,
                   FACADE_ID = p_facade_id,
                --    AD_TYPE_ID = p_type,
                   AD_SUB_TYPE_ID = p_ad_sub_type_id,
                   CONSTRUCTION_DATE = p_construction_date
             WHERE PRODUCT_ID = P_product_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -6;
                ROLLBACK;
            END IF;

        END IF;

        -- check if the category id = 2 and sub category = 1 'cars' then its required fields are filled
        IF PRODUCT.category_code_by_id (p_category_id => p_category_id) = 'portable' AND PRODUCT.sub_category_code_by_id (p_sub_category_id => p_subcategory_id) = 'cars' THEN
            IF p_make_id IS NULL OR p_model_id IS NULL OR p_chassis_number IS NULL THEN
               p_message := SYSTEM_CONTROLS.get_translation(p_code => 'missing_data', p_lang => p_lang);
                RETURN -7;
            END IF;

            UPDATE CAR_DETAILS 
               SET VEHICLE_MAKE_ID = p_make_id, 
                   VEHICLE_MODEL_ID = p_model_id, 
                   VEHICHLE_CATEGORY = p_vehichle_category, 
                   PLATE_NUMBER = p_plate_number, 
                   CHASSIS_NUMBER = p_chassis_number, 
                   SERIAL_NUMBER = p_sequency_number, 
                   YEAR = p_year, 
                   FUEL_TYPE_ID = p_fuel_type,
                   VEHICLE_EXTERNAL_COLOR_ID = p_external_color, 
                   ODO_METER =p_odo_meter, 
                   IS_THERE_DOCUMENT = p_is_document, 
                   IS_THERE_INSPECTION = p_is_inspection
                --    DOCUMENT_URL = p_document_url, 
                --    INSPECTION_URL =  p_inspection_url 
                --    IS_DROWNED = p_is_drowned, 
                --    IS_BURNED = p_is_burned, 
                --    IS_ACCIDENT = p_is_accident, 
                --    DROWING_INFO = p_drowing_info, 
                --    DROWING_FILE_URL = p_drowing_file_url,
                --    BURN_INFO = p_burn_info, 
                --    BURN_FILE_URL = p_burn_file_url, 
                --    ACCIDENT_INFO = p_accident_info, 
                --    ACCIDENT_FILE_URL = p_accident_file_url 
             WHERE PRODUCT_ID = P_product_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang);
                RETURN -8;
                ROLLBACK;
            END IF;
        END IF; 
        
       RETURN 1; 
    END UPDATE_PRODUCTS;
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION delete_product (
        p_product_id     IN NUMBER,
        p_category_id    IN NUMBER,
        p_subcategory_id IN NUMBER,
        p_lang           IN VARCHAR2 DEFAULT 'ar',
        p_message       OUT VARCHAR2
    ) RETURN NUMBER IS
        v_count number;
    BEGIN
        IF product.product_status_id_by_product_id (p_product_id => p_product_id) = LOOKUPS_MNT.lookup_detail_id_by_code(p_lookup_detail_code => 'available',p_lookup_code =>'product_status') THEN 
          
            UPDATE PRODUCT_REPORTS
               SET IS_ACTIVE = 0 
             WHERE PRODUCT_ID = p_product_id;

            UPDATE PRODUCT_IMAGES
               SET IS_ACTIVE = 0 
             WHERE PRODUCT_ID = p_product_id;
            
            UPDATE PRODUCTS
               SET IS_ACTIVE = 0, 
                   IS_DELETED = 1
             WHERE ID = p_product_id;

            IF SQL%ROWCOUNT = 0 THEN 
                p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang) || 'PRODUCT';
                RETURN -8;
                ROLLBACK;
            END IF;

            IF LOOKUPS_MNT.category_code_by_id (p_category_id => p_category_id) = 'real_estates' THEN
                UPDATE PROPERTY_DIMENSIONS
                   SET IS_ACTIVE = 0
                 WHERE PRODUCT_ID = p_product_id;

                UPDATE PROPERTY_SERVICES
                   SET IS_ACTIVE = 0
                 WHERE PRODUCT_ID = p_product_id;

                UPDATE REAL_STATE_DETAILS
                   SET IS_ACTIVE = 0
                 WHERE PRODUCT_ID = p_product_id;

                IF SQL%ROWCOUNT = 0 THEN 
                    p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang)|| 'REAL';
                    RETURN -4;
                    ROLLBACK;
                END IF;
            END IF;

            IF PRODUCT.category_code_by_id (p_category_id => p_category_id) = 'portable' AND PRODUCT.sub_category_code_by_id (p_sub_category_id => p_subcategory_id) = 'cars' THEN
                UPDATE CAR_DETAILS
                   SET IS_ACTIVE = 0 
                 WHERE PRODUCT_ID = p_product_id;

                IF SQL%ROWCOUNT = 0 THEN 
                    p_message := SYSTEM_CONTROLS.get_translation(p_code => 'server_error', p_lang => p_lang)|| 'CARS';
                    RETURN -5;
                    ROLLBACK;
                END IF;
            END IF;


            RETURN 1;
        ELSE 
            p_message := SYSTEM_CONTROLS.get_translation(p_code => 'unallowed_delete', p_lang => p_lang);
            RETURN -3;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_message := SQLERRM;
            RETURN -1;
    END delete_product;
--=================================================================================================
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION category_code_by_id (
        p_category_id NUMBER
    ) RETURN VARCHAR2 AS
        l_category_code VARCHAR2(255);
    BEGIN
        SELECT code
          INTO l_category_code
          FROM categories
         WHERE id = p_category_id;

        RETURN l_category_code;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;
--=================================================================================================
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION sub_category_code_by_id (
        p_sub_category_id NUMBER
    ) RETURN VARCHAR2 AS
        l_category_code VARCHAR2(255);
    BEGIN
        SELECT code
          INTO l_category_code
          FROM SUB_CATEGORIES
         WHERE id = p_sub_category_id;

        RETURN l_category_code;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;
--=================================================================================================
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION product_status_id_by_product_id (
        p_product_id NUMBER
    ) RETURN NUMBER AS
        l_status_id NUMBER;
    BEGIN
        SELECT STATUS
          INTO l_status_id
          FROM products
         WHERE id = p_product_id;

        RETURN l_status_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;
--=================================================================================================
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END PRODUCT;
/