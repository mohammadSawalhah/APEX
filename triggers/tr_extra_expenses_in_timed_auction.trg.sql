
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_EXTRA_EXPENSES_IN_TIMED_AUCTION" BEFORE 
    INSERT OR UPDATE OR DELETE ON EXTRA_EXPENSES_IN_TIMED_AUCTION     
    FOR EACH ROW  
BEGIN     
    IF inserting THEN     
        IF :new.ID IS NULL THEN     
            :new.ID := EXTRA_EXPENSES_IN_TIMED_AUCTION_SEQ.nextval;     
        END IF; 
        :new.CREATED_DATE := SYSDATE;     
        :new.CREATED_BY := nvl(v('APP_USER'), user);  
    ELSif updating then   
        :new.MODIFIED_DATE := SYSDATE;     
        :new.MODIFIED_BY := nvl(v('APP_USER'), user);   
    ENd IF; 
END;


/
ALTER TRIGGER "MOBASHER"."TR_EXTRA_EXPENSES_IN_TIMED_AUCTION" ENABLE;