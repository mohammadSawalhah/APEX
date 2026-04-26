
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."REJECT_SELLER" (
        p_seller_id       NUMBER,
        p_reject_reason   VARCHAR2,
        p_seller_type     NUMBER,
        p_emp_id          NUMBER
    ) RETURN SELLERS_REQ.function_result IS
        l_function_result SELLERS_REQ.function_result; --Record to hold result (.code and .message)
        v_count           NUMBER;
        l_admin_emp_id    NUMBER;
        l_admin_usr_id    NUMBER;
        l_result          NUMBER;
        l_message         VARCHAR2(500);
    BEGIN
        SAVEPOINT updatestart;

        --Check to make sure SELLER exists
        SELECT COUNT(1) INTO v_count FROM SELLERS
         WHERE ID = p_seller_ID;

        IF v_count = 0 THEN
            l_function_result.code := 10;
            l_function_result.message := 'Seller not found';
            RETURN l_function_result;
        END IF;


        --Update statements and checks follow
        UPDATE SELLERS
           SET REQUEST_STATUS_ID = LOOKUPS_MNT.lookup_detail_id_by_code('rejected', 'request_status'),
               PENDING_TYPE_ID = null,
               IS_ACTIVE = 0
         WHERE ID = p_seller_id;

        IF SQL%Rowcount = 0 THEN
            ROLLBACK TO SAVEPOINT sellerstart;
            l_function_result.code := 20;
            l_function_result.message := 'Failed to update SELLER record';
            RETURN l_function_result;
        END IF;

        -- Update Reject Reason
        -- l_function_result :=
        l_result := APP_OPERATIONS.create_notes (
                        p_emp_id          => p_emp_id,
                        p_object_id       => p_seller_id,
                        p_operation_type  => LOOKUPS_MNT.lookup_detail_id_by_code('request_reject', 'operation_type'),
                        p_note            => p_reject_reason,
                        p_message         => l_message
                );

        -- UPDATE SELLERS_REQUESTS_DETAILS
        --    SET REJECT_REASON = p_reject_reason
        --  WHERE SELLER_ID = p_seller_id;

        -- IF SQL%Rowcount = 0 THEN
        --     ROLLBACK TO SAVEPOINT sellerstart;
        --     l_function_result.code := 25;
        --     l_function_result.message := 'Failed to update reject reason record';
        --     RETURN l_function_result;
        -- END IF;

         IF p_seller_type NOT IN (LOOKUPS_MNT.lookup_detail_id_by_code('governmental', 'seller_type'), LOOKUPS_MNT.lookup_detail_id_by_code('other', 'seller_type')) THEN
            --Check to make sure admin EMPLOYEE exists and grab ID
            SELECT ID into l_admin_emp_id FROM EMPLOYEES
             WHERE SELLER_ID = p_seller_id AND IS_ADMIN = 1;

            IF l_admin_emp_id IS NULL THEN
                l_function_result.code := 15;
                l_function_result.message := 'Admin Employee not found';
            END IF;
            
            UPDATE SELLER_CITIES
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 30;
                l_function_result.message := 'Failed to update SELLER_CITIES';
                RETURN l_function_result;
            END IF;

            UPDATE SELLER_CATEGORIES
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 40;
                l_function_result.message := 'Failed to update SELLER_CATEGORIES';
                RETURN l_function_result;
            END IF;

            UPDATE SELLER_BANK_ACCOUNTS
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 50;
                l_function_result.message := 'Failed to update SELLER_BANK_ACCOUNTS';
                RETURN l_function_result;
            END IF;

            UPDATE EMPLOYEES
               SET IS_ACTIVE = 0
             WHERE SELLER_ID = p_seller_id;

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 60;
                l_function_result.message := 'Failed to update EMPLOYEES';
                RETURN l_function_result;
            END IF;

            UPDATE APP_USER_ROLES
               SET ROLE_ID = APP_USER_SECURITY.role_id_by_name (p_role_name => 'inactive_seller')
             WHERE USER_ID IN (SELECT USER_ID FROM EMPLOYEES WHERE ID = l_admin_emp_id);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 70;
                l_function_result.message := 'Failed to update APP_USERS';
                RETURN l_function_result;
            END IF;

            UPDATE APP_USERS
               SET ACTIVE_FLAG = 'N'
             WHERE ID IN (SELECT USER_ID FROM EMPLOYEES WHERE ID = l_admin_emp_id);

            IF SQL%Rowcount = 0 THEN
                ROLLBACK TO SAVEPOINT sellerstart;
                l_function_result.code := 75;
                l_function_result.message := 'Failed to update APP_USERS';
                RETURN l_function_result;
            END IF;
        END IF;

        COMMIT;
        l_function_result.code := 1;
        l_function_result.message := 'Seller and all associated records rejected';
        RETURN l_function_result;
    END REJECT_SELLER;


    -- DECLARE
--     l_function_result APP_OPERATIONS.function_result;
-- BEGIN 
--         -- Update Reject Reason
--         l_function_result := APP_OPERATIONS.create_notes (
--         p_object_id       => 94,
--         p_operation_type  => LOOKUPS_MNT.lookup_detail_id_by_code('request_reject', 'operation_type'),
--         p_note            => 'p_reject_reason');

--          DBMS_OUTPUT.PUT_LINE(l_function_result.code || ' - ' || l_function_result.message);
-- END;
/