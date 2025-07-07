
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_FINANCE_REVIEW_PRODUCTS" BEFORE
    INSERT OR UPDATE OR DELETE ON finance_Review_Products    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := "finance_Review_Products_SEQ".nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        
    ENd IF;
    IF updating THEN    
          
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
END;


/
ALTER TRIGGER "MOBASHER"."TR_FINANCE_REVIEW_PRODUCTS" ENABLE;