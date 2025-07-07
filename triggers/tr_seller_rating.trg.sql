
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_SELLER_RATING" BEFORE 
  INSERT OR UPDATE ON SELLER_RATING
  FOR EACH ROW
BEGIN 
    IF INSERTING THEN    
        IF :new.ID IS NULL THEN    
           :new.ID := SELLER_RATING_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ELSIF UPDATING THEN
        :new.modified_date := SYSDATE;
        :new.modified_by := nvl(v('APP_USER'), user);
    ENd IF;
END TR_SELLER_RATING;


/
ALTER TRIGGER "MOBASHER"."TR_SELLER_RATING" ENABLE;