create or replace function std7_170.f_load_full(p_table text, p_file_name text)
	returns int4
	language plpgsql
	volatile
as $$

declare

v_ext_table_name text;
v_sql text;
v_gpfdist text;
v_result int;

begin
	
	v_ext_table_name = p_table ||'_ext';
	
	execute 'truncate table ' ||p_table;
	
	execute 'drop external table if exists ' ||v_ext_table_name;

	v_gpfdist = 'gpfdist://172.16.128.150:8080/'||p_file_name||'.csv';

	v_sql = 'create external table '||v_ext_table_name||'(like '||p_table||')
	location ('''||v_gpfdist||''') on all
	format ''csv'' (header delimiter '';'' null '''' escape ''"'' quote ''"'')
	encoding ''UTF8''';
	
	raise notice 'external table is: %', v_sql;

	execute v_sql;

	execute 'insert into '||p_table||' select * from ' ||v_ext_table_name;
	
	execute 'select count(1) from '||p_table into v_result;

	return v_result;

end;

$$

execute on any;

