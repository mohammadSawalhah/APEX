
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GET_SELLERS_DATA_FOR_UPDATE_CATE" RETURN sellerstable 
    PIPELINED 
AS 
    v_data CLOB; 
    v_url  VARCHAR2(1000) := 'https://demo.backend.mobasher.sa/apex/sellers'; 
BEGIN 
    v_data := apex_web_service.make_rest_request(p_url => v_url, p_http_method => 'GET'); 
    FOR seller IN ( 
        SELECT 
            jt.id, 
            jt.name, 
            jt.sellerCategory, 
            jt.categorie_id, 
            jt.categorie_key 
        FROM 
            ( 
                SELECT 
                    v_data AS api 
                FROM 
                    dual 
            ) jte, 
            JSON_TABLE ( jte.api, '$.sellers[*]' 
                    COLUMNS ( 
                        id NUMBER PATH '$.id', 
                        name VARCHAR2 ( 300 ) PATH '$.name', 
                        sellerCategory VARCHAR2 ( 300 ) PATH '$.sellerCategory',
                         NESTED PATH '$.categories[*]' 
                                            COLUMNS ( 
                                                categorie_id number PATH '$.id', 
                                                categorie_key VARCHAR2 ( 1000 CHAR ) PATH '$.key'
                                                
 
                                            )  

                       
                    ) 
                ) 
            jt 
    ) LOOP 
        PIPE ROW ( sellersrecord(seller.id, seller.name, null, null, null, 
                                null,null,seller.categorie_key,seller.categorie_id,null) ); 
    END LOOP; 
 
    RETURN; 
END;
/