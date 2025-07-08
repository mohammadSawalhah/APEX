
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_SELLERS_REQUESTS_DETAILS" BEFORE    
    INSERT OR UPDATE OR DELETE ON SELLERS_REQUESTS_DETAILS    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := SELLERS_REQUESTS_DETAILS_SEQ.nextval;    
        END IF;
        :new.created_date := get_current_date;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := get_current_date;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ELSIF updating THEN
        :new.modified_date := get_current_date;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END;


/
ALTER TRIGGER "MOBASHER"."TR_SELLERS_REQUESTS_DETAILS" ENABLE;