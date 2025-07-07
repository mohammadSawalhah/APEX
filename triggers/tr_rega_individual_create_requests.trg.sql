
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_REGA_INDIVIDUAL_CREATE_REQUESTS" BEFORE 
  INSERT OR UPDATE ON REGA_INDIVIDUAL_CREATE_REQUESTS
  FOR EACH ROW
BEGIN 
    IF INSERTING THEN    
        IF :new.ID IS NULL THEN    
           :new.ID := REGA_INDIVIDUAL_CREATE_REQUESTS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        -- :new.modified_date := SYSDATE;    
        -- :new.modified_by := nvl(v('APP_USER'), user);  
    ELSIF UPDATING THEN
        :new.modified_date := SYSDATE;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END TR_REGA_INDIVIDUAL_CREATE_REQUESTS;

/
ALTER TRIGGER "MOBASHER"."TR_REGA_INDIVIDUAL_CREATE_REQUESTS" ENABLE;