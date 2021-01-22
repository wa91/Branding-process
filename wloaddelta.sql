-- FUNCTION: public.wloaddelta(text, text)

-- DROP FUNCTION public.wloaddelta(text, text);

CREATE OR REPLACE FUNCTION public.wloaddelta(
	ctry text,
	nm text)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

begin

if ''||ctry||'' like '%tt%' and ''||ctry||'' like '%usa%' then
execute 'CREATE TABLE '|| ctry ||'
		 (
NAME character varying, BRANDNAME character varying, PB_ID character varying, TRADE_NAME character varying, GEO_COUNTRY character varying, LOCATION_NAME character varying, DISTRICT  character varying, STATE character varying,  STABB character varying, POST_CODE character varying,  FORMATTED_ADDRESS character varying,  MAIN_ADDRESS_LINE character varying, ADDRESS_LAST_LINE character varying,  HTTP character varying,  BUSINESS_LINE character varying,  SIC1 character varying,  SIC2 character varying, SIC character varying,  sic8_description character varying, MICODE integer, TRADE_DIVISION character varying, TRADE_GROUP character varying, CAT_ALIAS character varying, SUB_CAT_ALIAS character varying,  COUNTRY_BUNDLES character varying, GROUPING character varying
 )
		 WITH (
			OIDS=FALSE
		 )
	';
elseif ''||ctry||'' like '%tt%' then
execute 'CREATE TABLE '|| ctry ||'
		 (
NAME character varying, BRANDNAME character varying, PB_ID character varying, TRADE_NAME character varying, GEO_COUNTRY character varying, LOCATION_NAME character varying, DISTRICT  character varying, STATE character varying,  STABB character varying, POST_CODE character varying,  FORMATTED_ADDRESS character varying,  MAIN_ADDRESS_LINE character varying, ADDRESS_LAST_LINE character varying,  HTTP character varying,  BUSINESS_LINE character varying,  SIC1 character varying,  SIC2 character varying, SIC character varying,  sic8_description character varying, MICODE integer, TRADE_DIVISION character varying, TRADE_GROUP character varying, CAT_ALIAS character varying, SUB_CAT_ALIAS character varying,  GROUPING character varying
 )
		 WITH (
			OIDS=FALSE
		 )
	';
elseif ''||ctry||'' like '%usa%' then
execute 'CREATE TABLE '|| ctry ||'
		 ( pb_id character varying(20) COLLATE pg_catalog."default",
    stable_id character varying(20) COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    trade_name text COLLATE pg_catalog."default",
    franchise_name text COLLATE pg_catalog."default",
    http text COLLATE pg_catalog."default",
    business_line text COLLATE pg_catalog."default",
    sic8 character varying(20) COLLATE pg_catalog."default",
    sic8_description text COLLATE pg_catalog."default",
    parent_business_name text COLLATE pg_catalog."default",
    domestic_ultimate_business_name text COLLATE pg_catalog."default",
    global_ultimate_business_name text COLLATE pg_catalog."default",
    main_address_line text COLLATE pg_catalog."default",
    address_last_line text COLLATE pg_catalog."default",
    formattedaddress text COLLATE pg_catalog."default",
    record_type character varying(1) COLLATE pg_catalog."default",
	something varchar(1),
	micode bigint,
	groupcode varchar(5)
		 )
		 WITH (
			OIDS=FALSE
		 )
	';
else execute 'CREATE TABLE '|| ctry ||'
		 ( pb_id character varying(20) COLLATE pg_catalog."default",
    stable_id character varying(20) COLLATE pg_catalog."default",
    name text COLLATE pg_catalog."default",
    trade_name text COLLATE pg_catalog."default",
    franchise_name text COLLATE pg_catalog."default",
    http text COLLATE pg_catalog."default",
    business_line text COLLATE pg_catalog."default",
    sic8 character varying(20) COLLATE pg_catalog."default",
    sic8_description text COLLATE pg_catalog."default",
    parent_business_name text COLLATE pg_catalog."default",
    domestic_ultimate_business_name text COLLATE pg_catalog."default",
    global_ultimate_business_name text COLLATE pg_catalog."default",
    main_address_line text COLLATE pg_catalog."default",
    address_last_line text COLLATE pg_catalog."default",
    formattedaddress text COLLATE pg_catalog."default",
    record_type character varying(1) COLLATE pg_catalog."default",
	micode bigint,
	groupcode varchar(5)
		 )
		 WITH (
			OIDS=FALSE
		 )
	';
end if;

execute 'ALTER TABLE '|| ctry ||'  OWNER TO postgres';
execute 'copy '||ctry||' from ''E:/brands/'||ctry||'.txt'' WITH DELIMITER ''|'' quote E''\b'' CSV;';

if ''||ctry||'' like '%dnb%' then

execute '	
CREATE INDEX 
    ON public.'||ctry||' USING gin
    (franchise_name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;
	
CREATE INDEX 
    ON public.'||ctry||' USING gin
    (global_ultimate_business_name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;
	
CREATE INDEX 
    ON public.'||ctry||' USING gin
    (domestic_ultimate_business_name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;
';
end if;

execute '
CREATE INDEX 
    ON public.'||ctry||' USING gin
    (name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX 
    ON public.'||ctry||' USING gin
    (trade_name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;
	
	
CREATE INDEX 
    ON public.'||ctry||' USING gin
    (sic8_description COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;
	
CREATE INDEX ON public.'||ctry||' (micode);';

execute 'select brand_match_exper('''||ctry||''','''||nm||'_query_strings'');';
	
execute 'create index on '||ctry||'(brandname);
create index on '||ctry||'(pb_id);
alter table '||ctry||' add column old_brand text;';

execute 'update '||ctry||' set old_brand = bb.brandname from brand_lookup_'||nm||' bb where  '||ctry||'.pb_id::bigint = bb.pb_id;

copy(select  * from '||ctry||' 
	 where brandname is not null and ( not old_brand = brandname or old_brand is null) 
	 ) to ''E:\brands\branded_'||ctry||'.txt'' csv header delimiter ''|''
	 ';
	
	
return 1;  
EXCEPTION WHEN OTHERS THEN
			RAISE NOTICE 'Error: % %', SQLERRM, SQLSTATE;
			return 0;
END	;

$BODY$;

ALTER FUNCTION public.wloaddelta(text, text)
    OWNER TO postgres;
