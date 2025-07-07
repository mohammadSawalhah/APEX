
  CREATE OR REPLACE EDITIONABLE FUNCTION "MOBASHER"."FIND_GAPS" (  
  tab            dbms_tf.table_t,   
  date_cols      dbms_tf.columns_t  
) RETURN VARCHAR2 sql_macro AS  
BEGIN  
  RETURN 'find_gaps.tab match_recognize (   
          order by ' || find_gaps.date_cols ( 1 ) || ', ' || find_gaps.date_cols ( 2 ) || '    
          measures     
            max ( ' || find_gaps.date_cols ( 2 ) || ' ) start_gap,   
            next ( ' || find_gaps.date_cols ( 1 ) || ' ) end_gap  
          all rows per match  
          pattern ( ( gap | {-no_gap-} )+ )    
          define
            gap as max ( ' || find_gaps.date_cols ( 2 ) || ' ) < (   
              next ( ' || find_gaps.date_cols ( 1 ) || ' )  
            )    
        )';  
END find_gaps;
/