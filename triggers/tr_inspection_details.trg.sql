
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_INSPECTION_DETAILS" BEFORE 
  INSERT OR UPDATE ON INSPECTION_DETAILS
  FOR EACH ROW
BEGIN 
    IF inserting THEN    
        IF :new.ID IS NULL THEN    
           :new.ID := INSPECTION_DETAILS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ELSIF updating THEN
        :new.modified_date := SYSDATE;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END TR_INSPECTION_DETAILS;

/
ALTER TRIGGER "MOBASHER"."TR_INSPECTION_DETAILS" ENABLE;