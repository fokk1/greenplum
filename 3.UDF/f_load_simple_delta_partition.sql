create or replace function std7_170.f_load_simple_delta_partition(p_table text, p_partition_key text, 
																  p_start_date timestamp, p_end_date timestamp, 
																  p_pxf_table text, p_user_id text, p_pass text)
	returns int4
	language plpgsql
	volatile 
as $$

declare
	v_ext_table text;
	v_temp_table text;
	v_sql text;
	v_pxf text;
	v_result int;
	v_dist_key text;
	v_params text;
	v_where text;
	v_load_interval interval;
	v_start_date date;
	v_end_date date;
	v_table_oid int4;
	v_cnt int8;
begin
	
	v_ext_table = p_table||'_ext';
	v_temp_table = p_table||'_tmp';

	select c.oid
	into v_table_oid
	from pg_class as c 
	inner join pg_namespace as n
	on c.relnamespace = n.oid
	where n.nspname||'.'||c.relname = p_table
	limit 1;

	if v_table_oid = 0 or v_table_oid is null then 
		v_dist_key = 'distributed randomly';
	else
		v_dist_key = pg_get_table_distributedby(v_table_oid);
	end if;

	select coalesce('with (' || array_to_string(reloptions, ', ') || ')', '')
	from pg_class
	into v_params
	where oid = p_table::regclass;

	execute 'drop external table if exists ' ||v_ext_table;

	v_load_interval = '1 month'::interval;
	v_start_date := date_trunc('month', p_start_date);
	v_end_date := date_trunc('month', p_start_date) + v_load_interval;

	v_where = p_partition_key ||' >= '''||v_start_date||'''::date AND '||p_partition_key||' < '''||v_end_date||'''::date';

	v_pxf = 'pxf://'||p_pxf_table||'?PROFILE=Jdbc&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.214.212:5432/postgres&USER='||p_user_id||'&PASS='||p_pass;

	raise notice 'pxf connection string: %', v_pxf;

	v_sql = 'create external table '||v_ext_table||'(like '||p_table||')
			location ( '''||v_pxf||''') on all
			format ''custom'' (formatter = ''pxfwritable_import'')
			encoding ''utf8''';
		
	raise notice 'external table is: %', v_sql;

	execute v_sql;

	v_sql = 'drop table if exists '|| v_temp_table ||';
			 create table '|| v_temp_table ||' (like '||p_table||') ' ||v_params||' '||v_dist_key||';';
			
	raise notice 'temp table is: %', v_sql;

	execute v_sql;

	v_sql = 'insert into '|| v_temp_table ||' select * from '||v_ext_table||' where '||v_where;
	
	execute v_sql;	

	get diagnostics v_cnt = row_count;
	raise notice 'inserted rows: %', v_cnt;

	v_sql = 'alter table '||p_table||' exchange partition for (date '''||v_start_date||''') with table '|| v_temp_table ||' with validation';
	
	raise notice 'exchange partition script: %', v_sql;

	execute v_sql;

	execute 'select count(1) from '||p_table||' where '||v_where into v_result;
	
	return v_result;

end;

$$
execute on any;