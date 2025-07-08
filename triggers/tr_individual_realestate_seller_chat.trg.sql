
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_SELLER_CHAT" 
   BEFORE INSERT OR UPDATE 
   ON INDIVIDUAL_REALESTATE_SELLER_CHAT 
   FOR EACH ROW 
      BEGIN 
         IF INSERTING THEN 
            IF :new.ID IS NULL THEN    
                  :new.ID := INDIVIDUAL_REALESTATE_SELLER_CHAT_SEQ.nextval;    
            END IF;
            IF :new.CREATED_BY IS NULL THEN
            :new.CREATED_BY := nvl(v('APP_USER'), user);
            END IF;
            :new.CREATED_DATE := SYSDATE; 
         END IF; 

         IF updating THEN    
            :new.MODIFIED_DATE := SYSDATE;    
            :new.MODIFIED_BY := nvl(v('APP_USER'), user);  
         END IF;
      END;

/
ALTER TRIGGER "MOBASHER"."TR_INDIVIDUAL_REALESTATE_SELLER_CHAT" ENABLE;