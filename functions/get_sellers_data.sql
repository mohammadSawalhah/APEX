
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GET_SELLERS_DATA" RETURN sellerstable 
    PIPELINED 
AS
    v_data CLOB; 
    -- v_url  VARCHAR2(1000) := 'https://backend-master.mobasher.sa/apex/sellers'; 
    v_url  VARCHAR2(1000) := 'https://demo.backend.mobasher.sa/apex/sellers'; 
    -- v_url  VARCHAR2(1000) := 'https://f03d-188-55-160-54.ngrok-free.app/apex/sellers'; 
    -- v_url  VARCHAR2(1000) := 'https://api-new.mobasher.sa/apex/sellers'; 
BEGIN 
    v_data := apex_web_service.make_rest_request(p_url => v_url, p_http_method => 'GET'); 
    FOR seller IN ( 
        SELECT 
            jt.id, 
            jt.name, 
            jt.auctionsno, 
            jt.containersno, 
            jt.successfulauctionsno, 
            jt.pendingauctionsno, 
            jt.LastAuctionContainerDate, 
            jt.sellerCategory, 
            jt.AuctionsNotpayed, 
            jt.ProductsNotpayed 
        FROM JSON_TABLE (v_data, '$.sellers[*]' 
                    COLUMNS ( 
                        id NUMBER PATH '$.id', 
                        name VARCHAR2 ( 300 ) PATH '$.name', 
                        auctionsno NUMBER PATH '$.auctionsNo', 
                        containersno NUMBER PATH '$.containersNo', 
                        successfulauctionsno NUMBER PATH '$.successfulAuctionsNo', 
                        pendingauctionsno NUMBER PATH '$.pendingAuctionsNo', 
                        LastAuctionContainerDate TIMESTAMP PATH '$.LastAuctionContainerDate', 
                        sellerCategory VARCHAR2 ( 300 ) PATH '$.sellerCategory', 
                        AuctionsNotpayed number PATH '$.paymentIncompleteContainersNo', 
                        ProductsNotpayed  number PATH '$.paymentIncompleteAuctionsNo' 
                    ) 
                ) 
            jt 
    ) LOOP 
        PIPE ROW ( sellersrecord(seller.id, seller.name, seller.auctionsno, seller.containersno, seller.successfulauctionsno, 
                                seller.pendingauctionsno,seller.LastAuctionContainerDate,seller.sellerCategory,seller.AuctionsNotpayed,seller.ProductsNotpayed) ); 
    END LOOP; 
 
    RETURN; 
END;
/