
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."TOTAL_SALES" (
    country VARCHAR2 DEFAULT NULL,
    region  VARCHAR2 DEFAULT NULL
) RETURN CLOB SQL_MACRO IS
BEGIN
    RETURN q'{
            SELECT 
                r.country_name            name,
                r.country_region          region, 
                ROUND(SUM(s.amount_sold)) total_sales
            FROM sh.countries r, sh.customers c, sh.sales s
            WHERE r.country_id = c.country_id
            AND c.cust_id = s.cust_id
            AND r.country_name   = NVL(INITCAP(Total_Sales.country), r.country_name)
            AND r.country_region = NVL(INITCAP(Total_Sales.region),  r.country_region)
            GROUP BY r.country_id, r.country_name, r.country_region
        }';
END;
/