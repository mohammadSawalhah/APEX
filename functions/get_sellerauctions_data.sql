
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GET_SELLERAUCTIONS_DATA" ( 
    p_id IN NUMBER 
) RETURN sellerauctionstable 
    PIPELINED 
AS 
    v_data CLOB; 
    v_url  VARCHAR2(1000) := 'https://demo.backend.mobasher.sa/apex/sellers/' || p_id; 
BEGIN 
    v_data := apex_web_service.make_rest_request(p_url => v_url, p_http_method => 'GET'); 
    FOR sellerauction IN ( 
        SELECT 
            jt.totalContainers, 
            jt.id, 
            jt.successfulproductscount, 
            jt.productscount, 
            jt.name, 
            jt.type, 
            jt.status, 
            jt.product_id, 
            jt.ar_sa, 
            jt.sakNo, 
            jt.auctioncontainer_id, 
            jt.startPrice, 
            jt.lastBid , 
            jt.paymentStatus , 
            jt.subTotal, 
            jt.totalPrice , 
            jt.totalDiscount , 
            jt.buyer , 
            jt.isTransferToInfath, 
            jt.transferReceiptNo, 
            jt.transferDate, 
            jt.InfathUrl, 
            jt.sadadInvoiceNo, 
            jt.sadadUrl , 
            jt.rechargeDate , 
            jt.insurance, 
            jt.iban , 
            jt.item_id, 
            jt.item_ar_SA , 
            jt.item_price , 
            jt.item_quantity , 
            jt.item_totalPrice , 
            jt.auction_ID 
        FROM 
            ( 
                SELECT 
                    v_data AS api 
                FROM 
                    dual 
            ) jte, 
            JSON_TABLE ( jte.api, '$.data[*]' 
                    COLUMNS ( 
                        totalContainers NUMBER PATH '$.totalContainers', 
                        NESTED PATH '$.auctioncontainers[*]' 
                            COLUMNS ( 
                                id NUMBER PATH '$.id', 
                                successfulproductscount NUMBER PATH '$.successfulProductsCount', 
                                productscount NUMBER PATH '$.productsCount', 
                                name VARCHAR2 ( 300 CHAR ) PATH '$.name', 
                                type VARCHAR2 ( 300 CHAR ) PATH '$.type', 
                                NESTED PATH '$.auctions[*]' 
                                    COLUMNS ( 
                                        status VARCHAR2 ( 300 CHAR ) PATH '$.status', 
                                        product_id number PATH '$.id', 
                                        ar_sa VARCHAR2 ( 1000 CHAR ) PATH '$."ar-SA"', 
                                        sakNo VARCHAR2 ( 1000 CHAR ) PATH '$.sakNo', 
                                        auctioncontainer_id number PATH '$.auctioncontainer', 
                                        startPrice number PATH '$.startPrice', 
                                        lastBid number PATH '$.lastBid', 
                                        paymentStatus VARCHAR2 ( 1000 CHAR ) PATH '$.paymentStatus', 
                                        subTotal number PATH '$.subTotal', 
                                        totalPrice number PATH '$.totalPrice', 
                                        totalDiscount number PATH '$.totalDiscount', 
                                        buyer number PATH '$.buyer', 
                                        isTransferToInfath varchar2(20) PATH '$.isTransferToInfath', 
                                        transferReceiptNo varchar2(300) PATH '$.transferReceiptNo', 
                                        transferDate date PATH '$.transferDate', 
                                        sadadInvoiceNo number PATH '$.sadadInvoiceNo', 
                                        rechargeDate timestamp PATH '$.rechargeDate', 
                                        insurance number PATH '$.insurance', 
                                        iban varchar2(100) PATH '$.iban', 
                                         
                                        InfathUrl varchar2(3000) PATH '$.transferReceipts.url', 
                                        sadadUrl  varchar2(3000) PATH '$.invoiceUrl.url', 
 
                                        NESTED PATH '$.auctioninvoicedetails[*]' 
                                            COLUMNS ( 
                                                item_id number PATH '$.id', 
                                                item_ar_SA VARCHAR2 ( 1000 CHAR ) PATH '$."ar-SA"', 
                                                item_price number PATH '$.price', 
                                                item_quantity number PATH '$.quantity', 
                                                item_totalPrice number PATH '$.totalPrice', 
                                                auction_ID number PATH '$.auctionID' 
 
                                            ) 
                                        
 
 
 
                                         
                                             
                                    ) 
 
                                             
                            ) 
                    ) 
                ) 
            jt 
    ) LOOP 
        PIPE ROW ( sellerauctionsrecord( 
            sellerauction.totalContainers  , 
            sellerauction.id  , 
            sellerauction.successfulproductscount  , 
            sellerauction.productscount  , 
            sellerauction.name  , 
            sellerauction.type  , 
            sellerauction.status , 
            sellerauction.product_id  , 
            sellerauction.ar_sa  , 
            sellerauction.sakNo  , 
            sellerauction.auctioncontainer_id  , 
            sellerauction.startPrice  , 
            sellerauction.lastBid  , 
            sellerauction.paymentStatus  , 
            sellerauction.subTotal  , 
            sellerauction.totalPrice  , 
            sellerauction.totalDiscount  , 
            sellerauction.buyer  , 
            sellerauction.isTransferToInfath, 
            sellerauction.transferReceiptNo, 
            sellerauction.transferDate, 
            sellerauction.InfathUrl, 
            sellerauction.sadadInvoiceNo, 
            sellerauction.sadadUrl, 
            sellerauction.rechargeDate, 
            sellerauction.insurance, 
            sellerauction.iban , 
            sellerauction.item_id  , 
            sellerauction.item_ar_SA  , 
            sellerauction.item_price  , 
            sellerauction.item_quantity  , 
            sellerauction.item_totalPrice  , 
            sellerauction.auction_ID ) ); 
    END LOOP; 
 
    RETURN; 
END;
/