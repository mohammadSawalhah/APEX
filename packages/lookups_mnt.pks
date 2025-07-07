
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."LOOKUPS_MNT" AS  
    FUNCTION lookup_code_by_id (  
        p_lookup_id NUMBER  
    ) RETURN VARCHAR2;  
    
    FUNCTION lookup_code_by_detail_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2; 
    
    FUNCTION lookup_id_by_code (  
        p_lookup_code VARCHAR2  
    ) RETURN NUMBER;  
    
    FUNCTION lookup_linked_id_by_linked_detail_id (  
        p_linked_detail_id   NUMBER 
    ) RETURN VARCHAR2; 
    
    FUNCTION lookup_detail_code_by_id (
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2;  
    
    FUNCTION lookup_detail_id_by_code (  
        p_lookup_detail_code VARCHAR2, 
        p_lookup_code        VARCHAR2 
    ) RETURN NUMBER;  
    
    FUNCTION lookup_detail_name_by_id (  
        p_lookup_detail_id   NUMBER,  
        p_lang               VARCHAR2  
    ) RETURN VARCHAR2;  
    
    FUNCTION lookup_detail_name_by_code (  
        p_lookup_detail_code VARCHAR2, 
        p_lookup_code        VARCHAR2,  
        p_lang               VARCHAR2  
    ) RETURN VARCHAR2;  
    
    FUNCTION lookup_linked_detail_id_by_id (  
        p_lookup_detail_id   NUMBER 
    ) RETURN VARCHAR2; 
    
    FUNCTION color_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2;  
    
    FUNCTION bg_color_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2;  
    
    FUNCTION classes_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2;  
    
    FUNCTION icon_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2;  
    
    FUNCTION image_url_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2;  
    
    FUNCTION image_url_by_code (  
        p_lookup_detail_code VARCHAR2, 
        p_lookup_code        VARCHAR2  
    ) RETURN VARCHAR2;  
    
    FUNCTION detail_id_validation (  
        p_lookup_code      VARCHAR2,       
        p_lookup_detail_id NUMBER  
    ) RETURN NUMBER;  
    
    FUNCTION detail_id_seq (  
        p_lookup_detail_id NUMBER  
    ) RETURN NUMBER; 

    -- FUNCTION lookup_detail_name_by_id_detail_id_base (  
    --     p_lookup_detail_id   NUMBER, 
    --     p_lookup_base_id     NUMBER, 
    --     p_lang               VARCHAR2  
    -- ) RETURN VARCHAR2;


    FUNCTION vehicle_make_by_id (
        p_vehicle_make_id NUMBER
    ) RETURN VARCHAR2;

--<AWS_SECRET>=========================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================
    
    FUNCTION vehicle_model_by_id (
        p_vehicle_model_id NUMBER
    ) RETURN VARCHAR2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION vehicle_color_by_id (
        p_vehicle_color_id NUMBER
    ) RETURN VARCHAR2;
    
--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION city_by_id (
        p_city_id NUMBER,
        p_lang    VARCHAR2
    ) RETURN VARCHAR2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION category_by_id (
        p_category_id NUMBER
    ) RETURN VARCHAR2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION category_code_by_id (
        p_category_id NUMBER
    ) RETURN VARCHAR2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION sub_category_by_id (
        p_sub_category_id NUMBER
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

    FUNCTION neighbourhood_by_id (
        p_neighbourhood_id NUMBER
    ) RETURN VARCHAR2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION vin_number_by_id (
        p_id    NUMBER
    ) RETURN VARCHAR2;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION personal_name_by_id (
        p_id    NUMBER
    ) RETURN VARCHAR2;

END lookups_mnt;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."LOOKUPS_MNT" AS  
  
    FUNCTION lookup_code_by_id(  
        p_lookup_id   NUMBER  
    ) RETURN VARCHAR2 IS   
        v_result   VARCHAR2(1000);  
    BEGIN  
        SELECT CODE  
          INTO v_result  
          FROM LOOKUP_BASE  
         WHERE ID = p_lookup_id;  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_code_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION lookup_code_by_detail_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2 IS   
        v_result   VARCHAR2(1000);  
    BEGIN  
        SELECT CODE  
          INTO v_result  
          FROM LOOKUP_BASE  
         WHERE ID = ( SELECT LINKED_LOOKUP_ID FROM LOOKUP_DETAIL WHERE ID = p_lookup_detail_id); 
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_code_by_detail_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////     

    FUNCTION lookup_id_by_code(  
        p_lookup_code   VARCHAR2  
    ) RETURN NUMBER IS   
        v_result   NUMBER;  
    BEGIN  
        SELECT ID  
          INTO v_result  
          FROM LOOKUP_BASE  
         WHERE CODE = p_lookup_code;  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_id_by_code;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION lookup_linked_id_by_linked_detail_id (  
        p_linked_detail_id   NUMBER 
    ) RETURN VARCHAR2 IS   
        v_result   VARCHAR2(400);  
    BEGIN  
        SELECT LINKED_ID 
          INTO v_result  
          FROM LOOKUP_BASE  
         WHERE ID = p_linked_detail_id;  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_linked_id_by_linked_detail_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION lookup_detail_code_by_id(  
        p_lookup_detail_id   NUMBER  
    ) RETURN VARCHAR2 IS   
        v_result   VARCHAR2(1000);  
    BEGIN  
        SELECT CODE  
          INTO v_result  
          FROM LOOKUP_DETAIL  
         WHERE ID = p_lookup_detail_id;  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_detail_code_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION lookup_detail_id_by_code(  
        p_lookup_detail_code   VARCHAR2, 
        p_lookup_code          VARCHAR2  
    ) RETURN NUMBER IS   
        v_result   NUMBER;  
    BEGIN  
        SELECT ID  
          INTO v_result  
          FROM LOOKUP_DETAIL  
         WHERE CODE = p_lookup_detail_code 
           AND LINKED_LOOKUP_ID = lookup_id_by_code(p_lookup_code => p_lookup_code);  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_detail_id_by_code;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION lookup_detail_name_by_id (  
        p_lookup_detail_id   NUMBER, 
        p_lang               VARCHAR2  
    ) RETURN VARCHAR2 IS   
        v_result   VARCHAR2(400);  
    BEGIN  
        SELECT DECODE(NVL(p_lang, 'ar'), 'ar', NAME_AR, NAME_EN)  
          INTO v_result  
          FROM LOOKUP_DETAIL  
         WHERE ID = p_lookup_detail_id;  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_detail_name_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION lookup_detail_name_by_code (  
        p_lookup_detail_code VARCHAR2, 
        p_lookup_code        VARCHAR2,  
        p_lang               VARCHAR2 
    ) RETURN VARCHAR2 IS   
        v_result   VARCHAR2(400);  
    BEGIN  
        SELECT DECODE(NVL(p_lang, 'ar'), 'ar', NAME_AR, NAME_EN)  
          INTO v_result  
          FROM LOOKUP_DETAIL  
         WHERE CODE = p_lookup_detail_code 
           AND LINKED_LOOKUP_ID = lookup_id_by_code(p_lookup_code => p_lookup_code);  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_detail_name_by_code;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION lookup_linked_detail_id_by_id (  
        p_lookup_detail_id   NUMBER 
    ) RETURN VARCHAR2 IS   
        v_result   VARCHAR2(400);  
    BEGIN  
        SELECT LINKED_DETAIL_ID 
          INTO v_result  
          FROM LOOKUP_DETAIL  
         WHERE ID = p_lookup_detail_id;  
        RETURN v_result;   
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END lookup_linked_detail_id_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION color_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2 IS  
        v_color lookup_detail.color%TYPE;  
    BEGIN  
        SELECT  
            color  
        INTO v_color  
        FROM  
            lookup_detail  
        WHERE  
            id = p_lookup_detail_id;  
        RETURN v_color;  
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END color_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION bg_color_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2 IS  
        v_bg_color lookup_detail.background_color%TYPE;  
    BEGIN  
        SELECT  
            background_color  
        INTO v_bg_color  
        FROM  
            lookup_detail  
        WHERE  
            id = p_lookup_detail_id;  
        RETURN v_bg_color;  
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END bg_color_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION classes_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2 IS  
        v_classes lookup_detail.classes%TYPE;  
    BEGIN  
        SELECT  
            classes  
        INTO v_classes  
        FROM  
            lookup_detail  
        WHERE  
            id = p_lookup_detail_id;  
        RETURN v_classes;  
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END classes_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

    FUNCTION icon_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2 IS  
        v_icon lookup_detail.icon%TYPE;  
    BEGIN  
        SELECT icon  
          INTO v_icon  
          FROM lookup_detail  
         WHERE id = p_lookup_detail_id;  
        RETURN v_icon;  
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN NULL;  
    END icon_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION image_url_by_id (  
        p_lookup_detail_id NUMBER  
    ) RETURN VARCHAR2 IS  
        v_img_url lookup_detail.IMAGE_URL%TYPE;  
    BEGIN  
        SELECT IMAGE_URL  
          INTO v_img_url  
          FROM lookup_detail  
         WHERE id = p_lookup_detail_id;  
        RETURN v_img_url;  
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN '';  
    END image_url_by_id;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION image_url_by_code (  
        p_lookup_detail_code VARCHAR2, 
        p_lookup_code        VARCHAR2  
    ) RETURN VARCHAR2 IS  
        v_img_url lookup_detail.IMAGE_URL%TYPE;  
    BEGIN  
        SELECT IMAGE_URL  
          INTO v_img_url  
          FROM lookup_detail  
         WHERE CODE = p_lookup_detail_code 
           AND LINKED_LOOKUP_ID = lookup_id_by_code(p_lookup_code => p_lookup_code);  
        RETURN v_img_url;  
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN '';  
    END image_url_by_code;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION detail_id_validation (  
        p_lookup_code      VARCHAR2,       
        p_lookup_detail_id NUMBER  
    ) RETURN NUMBER IS  
        v_result   NUMBER;  
    BEGIN  
        SELECT COUNT(1)  
          INTO v_result  
          FROM lookup_detail  
         WHERE id = p_lookup_detail_id 
           AND LINKED_LOOKUP_ID = lookup_id_by_code( p_lookup_code => p_lookup_code);  
        IF v_result > 0 THEN 
            RETURN 1;  
        ELSE 
            RETURN 0;  
        END IF; 
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN 0;  
    END detail_id_validation;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION detail_id_seq (  
        p_lookup_detail_id NUMBER  
    ) RETURN NUMBER IS  
        v_result   NUMBER;  
    BEGIN  
        SELECT SEQ 
          INTO v_result  
          FROM lookup_detail  
         WHERE id = p_lookup_detail_id;  
        RETURN v_result;  
    EXCEPTION  
        WHEN no_data_found THEN  
            RETURN 0;  
    END detail_id_seq;  
    
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    -- FUNCTION lookup_detail_name_by_id_detail_id_base (  
    --     p_lookup_detail_id   NUMBER, 
    --     p_lookup_base_id   NUMBER, 
    --     p_lang               VARCHAR2  
    -- ) RETURN VARCHAR2 IS   
    --     v_result   VARCHAR2(400);  
    -- BEGIN  
    --     SELECT DECODE(NVL(p_lang, 'ar'), 'ar', NAME_AR, NAME_EN)  
    --       INTO v_result  
    --       FROM LOOKUP_DETAIL  
    --      WHERE ID = p_lookup_detail_id AND LINKED_LOOKUP_ID = p_lookup_base_id;  
    --     RETURN v_result;   
    -- EXCEPTION  
    --     WHEN no_data_found THEN  
    --         RETURN NULL;  
    -- END lookup_detail_name_by_id_detail_id_base;  

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

    FUNCTION vehicle_make_by_id (
        p_vehicle_make_id NUMBER
    ) RETURN VARCHAR2 AS
        l_vehicle_make VARCHAR2(255);
    BEGIN
        SELECT name_ar
          INTO l_vehicle_make
          FROM vehicle_make
         WHERE id = p_vehicle_make_id;

        RETURN l_vehicle_make;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION vehicle_model_by_id (
        p_vehicle_model_id NUMBER
    ) RETURN VARCHAR2 AS
        l_vehicle_model VARCHAR2(255);
    BEGIN
        SELECT name_ar
          INTO l_vehicle_model
          FROM vehicle_model
         WHERE id = p_vehicle_model_id;

        RETURN l_vehicle_model;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION vehicle_color_by_id (
        p_vehicle_color_id NUMBER
    ) RETURN VARCHAR2 AS
        l_vehicle_color VARCHAR2(255);
    BEGIN
        SELECT name_ar
          INTO l_vehicle_color
          FROM vehicle_external_color
         WHERE id = p_vehicle_color_id;

        RETURN l_vehicle_color;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION city_by_id (
        p_city_id NUMBER,
        p_lang    VARCHAR2
    ) RETURN VARCHAR2 AS
        l_city VARCHAR2(255);
    BEGIN
        SELECT DECODE(NVL(p_lang, 'ar'), 'ar', NAME_AR, NAME_EN)
          INTO l_city
          FROM cities
         WHERE id = p_city_id;

        RETURN l_city;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION category_by_id (
        p_category_id NUMBER
    ) RETURN VARCHAR2 AS
        l_category VARCHAR2(255);
    BEGIN
        SELECT name_ar
          INTO l_category
          FROM categories
         WHERE id = p_category_id;

        RETURN l_category;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

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

    FUNCTION sub_category_by_id (
        p_sub_category_id NUMBER
    ) RETURN VARCHAR2 AS
        l_sub_category VARCHAR2(255);
    BEGIN
        SELECT name_ar
          INTO l_sub_category
          FROM sub_categories
         WHERE id = p_sub_category_id;

        RETURN l_sub_category;
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
        l_sub_category VARCHAR2(255);
    BEGIN
        SELECT code
          INTO l_sub_category
          FROM sub_categories
         WHERE id = p_sub_category_id;

        RETURN l_sub_category;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION neighbourhood_by_id (
        p_neighbourhood_id NUMBER
    ) RETURN VARCHAR2 AS
        l_neighbourhood VARCHAR2(255);
    BEGIN
        SELECT name_ar
          INTO l_neighbourhood
          FROM neighbourhoods
         WHERE id = p_neighbourhood_id;

        RETURN l_neighbourhood;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION vin_number_by_id (
        p_id    NUMBER
    ) RETURN VARCHAR2 AS
        l_vin_number VARCHAR2(255);
    BEGIN
        SELECT chassis_number
          INTO l_vin_number
          FROM seller_assigned_files_details
         WHERE id = p_id;

        RETURN l_vin_number;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

    FUNCTION personal_name_by_id (
        p_id    NUMBER
    ) RETURN VARCHAR2 AS
        l_personal_name VARCHAR2(255);
    BEGIN
        SELECT PERSONAL_NAME
          INTO l_personal_name
          FROM APP_USERS
         WHERE id = p_id;

        RETURN l_personal_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '';
    END;

--=================================================================================================  
--===================================== END OF FUNCTION ===========================================  
--=================================================================================================

END LOOKUPS_MNT;
/