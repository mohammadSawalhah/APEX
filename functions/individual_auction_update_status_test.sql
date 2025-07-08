
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."INDIVIDUAL_AUCTION_UPDATE_STATUS_TEST" (
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
            IF l_status = 'UNASSIGNED' THEN

                SELECT SELLER_ID
                  INTO v_seller_id
                  FROM PRODUCTS
                 WHERE ID IN (SELECT PRODUCT_ID FROM INDIVIDUAL_REALESTATE_REQUESTS WHERE RES_PRODUCT_ID = l_product_id);

                SELECT ID  
                  INTO v_request_id
                  FROM INDIVIDUAL_REALESTATE_REQUESTS
                 WHERE RES_PRODUCT_ID = l_product_id;

                INSERT INTO INDIVIDUAL_REALESTATE_DECLINED_REQUESTS (REQUEST_ID, SELLER_ID, DECLINED_REASON)-- , DECLINED_REASON
                   VALUES (v_request_id, v_seller_id, l_reject_reason);--, l_reject_reason

                IF SQL%ROWCOUNT = 0 THEN
                    p_message := '02,' || SYSTEM_CONTROLS.get_translation(p_code => 'inserting_error', p_lang => p_lang);
                    RETURN '-2';
                END IF;

                UPDATE PRODUCTS
                   SET seller_id = null
                 WHERE ID IN (SELECT PRODUCT_ID FROM INDIVIDUAL_REALESTATE_REQUESTS WHERE RES_PRODUCT_ID = l_product_id);

                IF SQL%ROWCOUNT = 0 THEN
                    p_message := '07,' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                    RETURN '-7';
                END IF;

                UPDATE INDIVIDUAL_REALESTATE_REQUESTS
                   SET PROGRESS_STATUS= LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'declined_auction_by_seller', p_lookup_code => 'individual_auction_progress'),
                       STATUS = LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'declined_request_by_seller', p_lookup_code => 'individual_request_status')
                 WHERE ID = v_request_id;

                IF SQL%ROWCOUNT = 0 THEN
                    p_message := '08,' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                    RETURN '-8';
                END IF;
            END IF;

            UPDATE INDIVIDUAL_REALESTATE_REQUESTS
               SET IS_SOLD              = DECODE(l_status,'SOLD', 1, 0),
                --    SELLER_REJECT_REASON = DECODE(l_status,'UNASSIGNED', l_reject_reason, null ),
                   PROGRESS_STATUS      = DECODE(l_status,
                                                'UNASSIGNED', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'declined_auction_by_seller', p_lookup_code => 'individual_auction_progress'),
                                                'SOLD', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'auction_sold', p_lookup_code => 'individual_auction_progress')
                                                ),
                   STATUS               = DECODE(l_status,
                                                'UNASSIGNED', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'declined_request_by_seller', p_lookup_code => 'individual_request_status'),
                                                'SOLD', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_sold', p_lookup_code => 'individual_request_status'),
                                                 LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_assigned', p_lookup_code => 'individual_request_status')
                                                )
             WHERE RES_PRODUCT_ID       = l_product_id;
            
            IF SQL%ROWCOUNT = 0 THEN
                p_message := '03,' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                RETURN '-3';
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
            UPDATE INDIVIDUAL_PORTABLE_REQUESTS
               SET AUCTION_NAME = l_auction_name,
                   AUCTION_LINK = l_auction_link,
                   PROGRESS_STATUS = DECODE(l_status,
                                        'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'final_request_approval', p_lookup_code => 'individual_auction_progress'),
                                        LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'publish_auction', p_lookup_code => 'individual_auction_progress')),
                   AFTER_APPROVAL_STATUS = DECODE(l_status,
                                            'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'wainting_publish', p_lookup_code => 'individual_portable_status'),
                                            LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'auction_published', p_lookup_code => 'individual_portable_status')),
                   REQUEST_STATUS = DECODE(l_status,
                                            'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'wokring_on', p_lookup_code => 'individuals_auctions_status'),
                                            LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'done', p_lookup_code => 'individuals_auctions_status')),
                   STATUS = DECODE(l_status,
                                            'FREE', LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_approved', p_lookup_code => 'individual_request_status'),
                                            LOOKUPS_MNT.lookup_detail_id_by_code (p_lookup_detail_code => 'request_done', p_lookup_code => 'individual_request_status')),
                    IS_PRICE_EDITABLE = 0,
                    IS_EDITABLE = 0
             WHERE RES_PRODUCT_ID = l_product_id;

            IF SQL%ROWCOUNT = 0 THEN
                p_message := '05,' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                RETURN '-5';
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
                p_message := '06,' || SYSTEM_CONTROLS.get_translation(p_code => 'updating_error', p_lang => p_lang);
                RETURN '-6';
            END IF;
        END IF;

        p_message := 'Success';
        RETURN '1';

END;
/