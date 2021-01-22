-- FUNCTION: public.brand_match_exper(character varying, character varying)

-- DROP FUNCTION public.brand_match_exper(character varying, character varying);

CREATE OR REPLACE FUNCTION brand_match_exper(
	tbla character varying,
	tblb character varying)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
    qryrec record;
    qry2 record;
    qry3 record;
	qry4 record;
    tbl refcursor;
    tbl2 refcursor;
    tbl3 refcursor;
    tbl4 refcursor;

BEGIN
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'brandname'
			) THEN
execute 'alter table "'|| tbla ||'" add column brandname varchar(255)';
raise notice 'alter table % add column brandname varchar(255)',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'new_brand'
			) THEN
execute 'alter table "'|| tbla ||'" add column new_brand int';
raise notice 'alter table % add column new_brand int',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'multiple_brands'
			) THEN
execute 'alter table "'|| tbla ||'" add column multiple_brands character varying';
raise notice 'alter table % add column multiple_brands character varying',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'sic8_description'
			) THEN
execute 'alter table "'|| tbla ||'" add column sic8_description character varying';
raise notice 'alter table % add column multiple_brands character varying',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'micode'
			) THEN
execute 'alter table "'|| tbla ||'" add column micode bigint';
raise notice 'alter table % add column micode bigint',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'trade_name'
			) THEN
execute 'alter table "'|| tbla ||'" add column trade_name character varying';
raise notice 'alter table % add column trade_name character varying',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'business_line'
			) THEN
execute 'alter table "'|| tbla ||'" add column business_line character varying';
raise notice 'alter table % add column business_line character varying',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'matches'
			) THEN
execute 'alter table "'|| tbla ||'" add column matches int';
raise notice 'alter table % add column matches int',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'global_ultimate_business_name'
			) THEN
execute 'alter table "'|| tbla ||'" add column global_ultimate_business_name character varying';
raise notice 'alter table % add column global_ultimate_business_name',tbla;
END IF;
IF NOT EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'parent_business_name'
			) THEN
execute 'alter table "'|| tbla ||'" add column parent_business_name character varying';
raise notice 'alter table % add column parent_business_name',tbla;
END IF;
EXECUTE 'CREATE INDEX ON "'||tbla||'" USING gin
    (multiple_brands COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default';
raise notice 'create index on % multiple_brands',tbla;

IF EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'franchise_name'
			) then
   OPEN tbl for execute
   'select column_name, brand, string, additional_sql
    from information_schema.columns, "'||tblb||'" 
	where table_name = '||quote_literal(tbla) ||' and column_name in (''name'',''trade_name'',''franchise_name'')
   and not string = '''' and string is not null
   and (column_restrictions = '''' or column_restrictions is null)
   and (additional_string = '''' or additional_string is null) ';
else 
   OPEN tbl for execute
   'select column_name, brand, string, column_restrictions, additional_string, additional_sql
    from information_schema.columns, "'||tblb||'" 
	where table_name = '||quote_literal(tbla) ||' and column_name in (''name'',''trade_name'',''fran_name'')
    and not string = '''' and string is not null
   and (column_restrictions = '''' or column_restrictions is null)
   and (additional_string = '''' or additional_string is null) ';
	end if;
    
     LOOP
    Fetch tbl into qryrec;
    Exit when not found;
	raise notice 'updating % with column % and additional_sql: %',quote_literal(qryrec.brand),qryrec.column_name,coalesce(qryrec.additional_sql,' and 1=1');
	
	EXECUTE 'update "'||tbla||'" set new_brand = 1, matches = coalesce(matches,1), brandname = '|| quote_literal(qryrec.brand) ||' where upper('|| qryrec.column_name || ') similar to ' || quote_literal(qryrec.string) || ' 
	 and (brandname is null or brandname = '''') '|| coalesce(qryrec.additional_sql,' and 1=1') || '';
	EXECUTE 'update "'||tbla||'" set matches = coalesce(matches,0) + 1, multiple_brands = coalesce(multiple_brands,'''') ||'';''||' ||quote_literal(qryrec.brand) ||' where upper('|| qryrec.column_name || ') similar to ' || quote_literal(qryrec.string) || ' and (brandname is not null or not brandname = '''')' || coalesce(qryrec.additional_sql,' and 1=1')  || ' and not coalesce(multiple_brands,'''') like '|| quote_literal('%'||qryrec.brand||'%')||''
   ;
   END LOOP;
   Close tbl;

IF EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'franchise_name'
			) then
   OPEN tbl2 for execute
   'select column_name, brand, string, additional_sql, column_restrictions
    from information_schema.columns, "'||tblb||'" 
	where table_name = '||quote_literal(tbla) ||' and column_name = column_restrictions
   and not string = '''' and string is not null
   and not column_restrictions = '''' and column_restrictions is not null
   and (additional_string = '''' or additional_string is null) ';
else 
   OPEN tbl2 for execute
  'select column_name, brand, string, additional_sql, column_restrictions
    from information_schema.columns, "'||tblb||'" 
	where table_name = '||quote_literal(tbla) ||' and column_name = replace(column_restrictions,''franchise_name'',''fran_name'')
   and not string = '''' and string is not null
   and not column_restrictions = '''' and column_restrictions is not null
   and (additional_string = '''' or additional_string is null) ';
	end if;

    LOOP
	
    Fetch tbl2 into qry2;
    Exit when not found;
	raise notice 'updating % with column: % - string: % - and additional_sql: %',quote_literal(qry2.brand),qry2.column_name,quote_literal(qry2.string),coalesce(qry2.additional_sql,' and 1=1');
	
	EXECUTE 'update "'||tbla||'" set new_brand = 1, matches = coalesce(matches,1), brandname = '|| quote_literal(qry2.brand) ||' where upper('|| qry2.column_name || ') similar to ' ||  quote_literal(qry2.string) || ' 
	 and (brandname is null or brandname = '''') '|| coalesce(qry2.additional_sql,' and 1=1')   || ''
	 ;
	EXECUTE 'update "'||tbla||'" set matches = coalesce(matches,0) + 1, multiple_brands = coalesce(multiple_brands,'''') ||'';''||' ||quote_literal(qry2.brand) ||' where upper('|| qry2.column_name || ') similar to ' ||  quote_literal(qry2.string) || ' and (brandname is not null or not brandname = '''')' || coalesce(qry2.additional_sql,' and 1=1')  || ' and not coalesce(multiple_brands,'''') like '|| quote_literal('%'||qry2.brand||'%')||''
	;

END LOOP;
   Close tbl2;
  

IF EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'franchise_name'
			) then
   OPEN tbl3 for execute
   'select aa.column_name as col1, brand, string, bb.column_name as col2, additional_string, additional_sql
    from information_schema.columns aa, "'||tblb||'", information_schema.columns bb
	where aa.table_name = '||quote_literal(tbla) ||' and aa.column_name in (''name'',''trade_name'',''franchise_name'')
  and bb.table_name = '||quote_literal(tbla) ||' and bb.column_name in (''name'',''trade_name'',''franchise_name'')
   and not string = '''' and string is not null
   and (column_restrictions = '''' or column_restrictions is null)
   and not additional_string = '''' and additional_string is not null ';
else 
   OPEN tbl3 for execute
   'select aa.column_name as col1, brand, string, bb.column_name as col2, additional_string, additional_sql
    from information_schema.columns aa, "'||tblb||'", information_schema.columns bb
	where aa.table_name = '||quote_literal(tbla) ||' and aa.column_name in (''name'',''trade_name'',''fran_name'')
  and bb.table_name = '||quote_literal(tbla) ||' and bb.column_name in (''name'',''trade_name'',''fran_name'')
   and not string = '''' and string is not null
   and (column_restrictions = '''' or column_restrictions is null)
   and not additional_string = '''' and additional_string is not null ';
	end if;
    
     LOOP
	 
    Fetch tbl3 into qry3;
    Exit when not found;
	raise notice 'updating % with column % and additional_sql: %',quote_literal(qry3.brand),qry3.col2,coalesce(qry3.additional_sql,' and 1=1');
 
	EXECUTE 'update "'||tbla||'" set new_brand = 1, matches = coalesce(matches,1), brandname = '|| quote_literal(qry3.brand) ||' where upper('|| qry3.col1 || ') similar to ' ||  quote_literal(qry3.string) || ' 
	and '|| qry3.col2 || ' similar to ' || quote_literal(qry3.additional_string) || ' and (brandname is null or brandname = '''') '|| coalesce(qry3.additional_sql,' and 1=1')  || ''
	;
	EXECUTE 'update "'||tbla||'" set matches = coalesce(matches,0) + 1, multiple_brands = coalesce(multiple_brands,'''') ||'';''||' ||quote_literal(qry3.brand) ||' where upper('|| qry3.col1 || ') similar to '||  quote_literal(qry3.string) || ' 
	 and upper('|| qry3.col2 || ') similar to ' || quote_literal(qry3.additional_string) || ' and (brandname is not null or not brandname = '''')' ||coalesce(qry3.additional_sql,' and 1=1')   || ' 
      and not coalesce(multiple_brands,'''') like '|| quote_literal('%'||qry3.brand||'%')||''
		  ;
  END LOOP;
   Close tbl3;

IF EXISTS(select 1
    from information_schema.columns
	where table_name = tbla and column_name = 'franchise_name'
			) then
   OPEN tbl4 for execute
   'select column_name, brand, string, additional_sql
    from information_schema.columns, "'||tblb||'" 
	where table_name = '||quote_literal(tbla) ||' and column_name in (''name'',''trade_name'',''franchise_name'')
    and (string = '''' or string is null)
   and (column_restrictions = '''' or column_restrictions is null)
   and (additional_string = '''' or additional_string is null)
   and not additional_sql = '''' and additional_sql is not null ';
else 
   OPEN tbl4 for execute
   'select column_name, brand, string, column_restrictions, additional_string, additional_sql
    from information_schema.columns, "'||tblb||'" 
	where table_name = '||quote_literal(tbla) ||' and column_name in (''name'',''trade_name'',''fran_name'')
    and (string = '''' or string is null)
   and (column_restrictions = '''' or column_restrictions is null)
   and (additional_string = '''' or additional_string is null)
   and not additional_sql = '''' and additional_sql is not null ';
	end if;
    
     LOOP
	
    Fetch tbl4 into qry4;
    Exit when not found;
	raise notice 'updating % with column % and additional_sql: %',quote_literal(qry4.brand),qry4.column_name, coalesce(qry4.additional_sql,' and 1=1');
  
	EXECUTE 'update "'||tbla||'" set new_brand = 1, matches = coalesce(matches,1), brandname = '|| quote_literal(qry4.brand) ||' '||coalesce(qry4.additional_sql,' where 1=0') || ' and (brandname is null or brandname = '''')' ||''
	;
	EXECUTE 'update "'||tbla||'" set matches = coalesce(matches,1) + 1, multiple_brands = coalesce(multiple_brands,'''') ||'';''||' ||quote_literal(qry4.brand) ||' where (brandname is not null or not brandname = '''') '|| coalesce(qry4.additional_sql,' and 1=1') || ' and not coalesce(multiple_brands,'''') like '|| quote_literal('%'||qry4.brand||'%')||''
	;
 END LOOP;
   Close tbl4;

   RETURN 'Done';
  END;  

$BODY$;

ALTER FUNCTION brand_match_exper(character varying, character varying)
    OWNER TO postgres;
