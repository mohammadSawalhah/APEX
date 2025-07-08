
  CREATE OR REPLACE EDITIONABLE PACKAGE "MOBASHER"."VALIDATIONS_PKG" as
    FUNCTION VALIDATE_EMAIL(
        p_email VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION VALIDATE_Phone(
        p_phone VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION VALIDATE_CR(
        p_cr VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION VALIDATE_ID(
        p_ID VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION VALIDATE_IBAN(
        p_iban varchar2
    ) RETURN BOOLEAN;
end "VALIDATIONS_PKG";
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MOBASHER"."VALIDATIONS_PKG" as
    FUNCTION VALIDATE_EMAIL(
        p_email VARCHAR2
    ) RETURN BOOLEAN IS
        l_regexp VARCHAR2(512);
    BEGIN
        l_regexp := '^[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]+$';
        IF REGEXP_LIKE(p_email, l_regexp) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END VALIDATE_EMAIL;

    FUNCTION VALIDATE_PHONE(
        p_phone VARCHAR2
    ) RETURN BOOLEAN IS
        l_regexp VARCHAR2(512);
    BEGIN
        l_regexp := '^\+{0,1}[0-9]{1,3}[0-9]{8,10}$';
        IF REGEXP_LIKE(p_phone, l_regexp) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END VALIDATE_PHONE;

    --Expand this if needed
    FUNCTION VALIDATE_CR(
        p_cr VARCHAR2
    ) RETURN BOOLEAN IS
        l_regexp VARCHAR2(512);
    BEGIN
        l_regexp := '^[0-9]{10}$';
        IF REGEXP_LIKE(p_cr, l_regexp) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END VALIDATE_CR;

    FUNCTION VALIDATE_ID(
        p_ID VARCHAR2
    ) RETURN BOOLEAN IS
        l_regexp VARCHAR2(512);
    BEGIN 
        l_regexp := '^[0-9]{10}$';
        IF REGEXP_LIKE(p_ID, l_regexp) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END VALIDATE_ID;

    --Should grab most global IBANS, too loose for Saudi IBANS though.
    FUNCTION VALIDATE_IBAN(
        p_iban VARCHAR2
    ) RETURN BOOLEAN IS
        l_regexp VARCHAR2(512);
    BEGIN
        l_regexp := '^[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}[a-zA-Z0-9]{0,16}$';
        IF REGEXP_LIKE(p_iban, l_regexp) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END VALIDATE_IBAN;
end "VALIDATIONS_PKG";
/