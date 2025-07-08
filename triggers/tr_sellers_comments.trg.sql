
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_SELLERS_COMMENTS" BEFORE
    INSERT OR UPDATE OR DELETE ON SELLERS_COMMENTS     
    FOR EACH ROW  
BEGIN     
    IF inserting THEN     
        IF :new.ID IS NULL THEN     
            :new.ID := SELLERS_COMMENTS_SEQ.nextval;     
        END IF;    
        :new.created_by := nvl(v('APP_USER'), user);       
    ELSIF updating THEN     
        :new.modified_date := SYSDATE;     
        :new.modified_by := nvl(v('APP_USER'), user);   
    ENd IF; 
END;


/
ALTER TRIGGER "MOBASHER"."TR_SELLERS_COMMENTS" ENABLE;