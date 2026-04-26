
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."GET_BUYERS_DATA" ( 
    p_id IN NUMBER 
) RETURN BuyerTable 
    PIPELINED 
AS 
    v_id number ; 
    v_nIdType varchar2(300) ; 
    v_nationalID number ; 
    v_name varchar2(300) ; 
    v_phone number ; 
    v_dateOfBirth date ; 
    v_balance number ; 
    v_active varchar2(300) ; 
    v_country number ; 
    v_buyerType varchar2(300) ; 
    v_commissionerName varchar2(300); 
    v_commissionerPhone number; 
    v_commissionerNIdType varchar2(300); 
    v_commissionerNationalID number ; 
    v_email varchar2(300) ; 
    v_secondName varchar2(300) ; 
    v_thirdName varchar2(300) ; 
    v_fourthName varchar2(300) ; 
    v_arFullName varchar2(300)  ; 
    v_enFullName varchar2(300) ; 
    v_gender varchar2(300) ; 
    v_arNationality varchar2(300)  ; 
    v_enNationality varchar2(300) ; 
    v_dobG date ; 
    v_enCardIssuePlace varchar2(300); 
 
BEGIN 
     
    FOR i IN (select distinct buyer   
 
from  
TABLE ( get_sellerauctions_data(p_id) )  
 
where  
 status = 'SOLD') LOOP 
        
    SELECT id, nidtype, nationalid, name, phone, 
   dateofbirth, balance, active, country, 
   buyertype,commissionername, commissionerphone, 
   commissionernidtype, commissionernationalid,email, 
   secondname, thirdname, fourthname, arfullname, enfullname, 
   gender, arnationality, ennationality, dobg, encardissueplace  
   INTO  
   v_id, v_nidtype, v_nationalid, v_name, v_phone, 
   v_dateofbirth, v_balance, v_active, v_country, v_buyertype, 
   v_commissionername, v_commissionerphone, v_commissionernidtype, v_commissionernationalid, 
   v_email, 
   v_secondname, v_thirdname, v_fourthname, v_arfullname, v_enfullname, 
   v_gender, v_arnationality, v_ennationality, v_dobg, v_encardissueplace 
       FROM table(GET_BUYER_DATA(i.buyer)); 
PIPE ROW ( BuyerRecord(v_id, v_nidtype, v_nationalid, v_name, v_phone, 
                              v_dateofbirth, v_balance, v_active, v_country, v_buyertype, 
                              v_commissionername, v_commissionerphone, v_commissionernidtype, v_commissionernationalid, 
                              v_email, 
                              v_secondname, v_thirdname, v_fourthname, v_arfullname, v_enfullname, 
                              v_gender, v_arnationality, v_ennationality, v_dobg, v_encardissueplace) ); 
 
 
 
 
    END LOOP; 
 
    RETURN; 
END;
/