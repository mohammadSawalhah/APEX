
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_PAYMENT_TRANSACTIONS" BEFORE 
  INSERT OR UPDATE ON PAYMENT_TRANSACTIONS
  FOR EACH ROW
BEGIN 
    IF INSERTING THEN    
        IF :new.ID IS NULL THEN    
           :new.ID := PAYMENT_TRANSACTIONS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
    ELSIF UPDATING THEN
        :new.modified_date := SYSDATE;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END PAYMENT_TRANSACTIONS;


/
ALTER TRIGGER "MOBASHER"."TR_PAYMENT_TRANSACTIONS" ENABLE;