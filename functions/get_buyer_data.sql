
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GET_BUYER_DATA" ( 
    p_id IN NUMBER 
) RETURN buyertable 
    PIPELINED 
AS 
    v_data CLOB; 
    v_url  VARCHAR2(1000) := 'https://demo.backend.mobasher.sa/apex/buyers/' || p_id; 
BEGIN 
    v_data := apex_web_service.make_rest_request(p_url => v_url, p_http_method => 'GET'); 
    FOR buyer IN ( 
        SELECT 
            jt.id, 
            jt.nidtype, 
            jt.nationalid, 
            jt.name, 
            jt.phone, 
            jt.dateofbirth, 
            jt.balance, 
            jt.active, 
            jt.country, 
            jt.buyertype, 
            jt.commissionername, 
            jt.commissionerphone, 
            jt.commissionernidtype, 
            jt.commissionernationalid, 
            jt.email, 
            jt.secondname, 
            jt.thirdname, 
            jt.fourthname, 
            jt.arfullname, 
            jt.enfullname, 
            jt.gender, 
            jt.arnationality, 
            jt.ennationality, 
            jt.dobg, 
            jt.encardissueplace 
        FROM 
            ( 
                SELECT 
                    v_data AS api 
                FROM 
                    dual 
            ) jte, 
            JSON_TABLE ( jte.api, '$.data[*]' 
                    COLUMNS ( 
                        id NUMBER PATH '$.id', 
                        nidtype VARCHAR2 ( 300 ) PATH '$.nIdType', 
                        nationalid NUMBER PATH '$.nationalID', 
                        name VARCHAR2 ( 300 ) PATH '$.name', 
                        phone NUMBER PATH '$.phone', 
                        dateofbirth DATE PATH '$.dateOfBirth', 
                        balance NUMBER PATH '$.balance', 
                        active VARCHAR2 ( 300 ) PATH '$.active', 
                        country NUMBER PATH '$.country', 
                        buyertype VARCHAR2 ( 300 ) PATH '$.buyerType', 
                        commissionername VARCHAR2 ( 300 ) PATH '$.commissionerName', 
                        commissionerphone NUMBER PATH '$.commissionerPhone', 
                        commissionernidtype VARCHAR2 ( 300 ) PATH '$.commissionerNIdType', 
                        commissionernationalid NUMBER PATH '$.commissionerNationalID', 
                        email VARCHAR2 ( 300 ) PATH '$.email', 
                        secondname VARCHAR2 ( 300 ) PATH '$.secondName', 
                        thirdname VARCHAR2 ( 300 ) PATH '$.thirdName', 
                        fourthname VARCHAR2 ( 300 ) PATH '$.fourthName', 
                        arfullname VARCHAR2 ( 300 ) PATH '$.arFullName', 
                        enfullname VARCHAR2 ( 300 ) PATH '$.enFullName', 
                        gender VARCHAR2 ( 300 ) PATH '$.gender', 
                        arnationality VARCHAR2 ( 300 ) PATH '$.arNationality', 
                        ennationality VARCHAR2 ( 300 ) PATH '$.enNationality', 
                        dobg DATE PATH '$.dobG', 
                        encardissueplace VARCHAR2 ( 300 ) PATH '$.enCardIssuePlace' 
                    ) 
                ) 
            jt 
    ) LOOP 
        PIPE ROW ( buyerrecord(buyer.id, buyer.nidtype, buyer.nationalid, buyer.name, buyer.phone, 
                              buyer.dateofbirth, buyer.balance, buyer.active, buyer.country, buyer.buyertype, 
                              buyer.commissionername, buyer.commissionerphone, buyer.commissionernidtype, buyer.commissionernationalid, 
                              buyer.email, 
                              buyer.secondname, buyer.thirdname, buyer.fourthname, buyer.arfullname, buyer.enfullname, 
                              buyer.gender, buyer.arnationality, buyer.ennationality, buyer.dobg, buyer.encardissueplace) ); 
    END LOOP; 
 
    RETURN; 
END;
/