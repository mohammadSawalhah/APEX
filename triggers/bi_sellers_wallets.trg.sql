
  CREATE OR REPLACE EDITIONABLE TRIGGER "MOBASHER"."BI_SELLERS_WALLETS" 
  before insert OR UPDATE on SELLERS_WALLETS              
  for each row 
begin  
   IF inserting THEN    
        IF :new.ID IS NULL THEN    
            :new.ID := SELLERS_WALLETS_SEQ.nextval;    
        END IF;
        :new.created_date := SYSDATE;    
        :new.ADD_BALANCE_DATE := SYSDATE;    
        :new.created_by := nvl(v('APP_USER'), user);    
        
    ENd IF;
    IF updating THEN    
          
        :new.modified_date := SYSDATE;    
        :new.modified_by := nvl(v('APP_USER'), user);  
    ENd IF;
end;


/
ALTER TRIGGER "MOBASHER"."BI_SELLERS_WALLETS" ENABLE;