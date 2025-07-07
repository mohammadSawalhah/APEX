
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_PRODUCTS" BEFORE
    INSERT OR UPDATE OR DELETE ON PRODUCTS    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := PRODUCTS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
    IF updating THEN    
        :new.modified_date := SYSDATE; 
        IF :new.modified_by IS NULL THEN
        :new.modified_by := nvl(v('APP_USER'), user);  
        END IF;
    ENd IF;
END;

/
ALTER TRIGGER "MOBASHER"."TR_PRODUCTS" ENABLE;