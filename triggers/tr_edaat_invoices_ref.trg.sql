
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_EDAAT_INVOICES_REF" BEFORE
    INSERT OR UPDATE OR DELETE ON EDAAT_INVOICES_REF    
    FOR EACH ROW 
BEGIN    
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := EDAAT_INVOICES_REF_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
END;


/
ALTER TRIGGER "MOBASHER"."TR_EDAAT_INVOICES_REF" ENABLE;