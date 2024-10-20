create or replace function std7_170.f_load_write_log(p_log_type text, p_log_message text, p_location text)
	returns void
	language plpgsql
	volatile
as $$
	
	

declare 
	v_log_type text;
	v_log_message text;
	v_sql text;
	v_location text;
	v_res text;
	
begin 
	v_log_type = upper(p_log_type);
	v_location = lower(p_location);
	if v_log_type not in ('ERROR', 'INFO') then 
		raise exception 'illegal log type! Use one of: ERROR, INFO';
	end if;
	
	raise notice '%: %: <%> Location[%]', clock_timestamp(), v_log_type, p_log_message, v_location;
	
	v_log_message := replace(p_log_message, '''', '''''');
	
	v_sql := '
		insert into std7_170.logs(log_id, log_type, log_msg, log_location, is_error, log_timestamp, log_user)
		values (
			'||nextval('std7_170.log_id_seq')||',
			'''||v_log_type||''',
			'||coalesce(''''||v_log_message||'''', '''empty''')||',
			'||coalesce(''''||v_location||'''', 'null')||',
			'||case when v_log_type = 'ERROR' then true else false end||',
			current_timestamp, current_user
		);
	';
	
	raise notice 'insert sql is: %', v_sql;
	v_res := dblink('adb_server', v_sql);
	end;
	


$$
execute on any;