create or replace function std7_170.f_load_mart(p_month varchar)
returns int4
language plpgsql
volatile
as $$
declare
    v_table_name text;
    v_sql text;
    v_where_date text;
    v_return int;
begin
    -- Формирование имени таблицы витрины
    v_table_name := 'plan_fact_' || p_month;

    -- Формирование условия для фильтрации по дате
    v_where_date := 'date_trunc(''month'', date) = date_trunc(''month'', to_date(''' || p_month || ''', ''yyyymm'')::date)';

    -- Удаление старых таблиц, если они существуют
    execute 'drop table if exists std7_170.actual_sales_ods';
    execute 'drop table if exists std7_170.plan_sales_ods';
	execute 'drop view if exists std7_170.v_plan_fact';
	execute 'drop table if exists ' || v_table_name;

    -- Создание таблицы actual_sales_ods
    execute '
    create table actual_sales_ods with (appendonly=true, orientation=column, compresstype=zstd, compresslevel=1) as
    select
        region,
        material,
        distr_chan,
        sum(quantity) as sum_quantity,
        rank() over (partition by region order by sum(quantity) desc) as rank
    from std7_170.sales s
    where ' || v_where_date || '
    group by region, material, distr_chan
    distributed by (region)';
    
    raise notice 'ODS table actual_sales_ods создана';

    -- Создание таблицы plan_sales_ods
    execute '
    create table plan_sales_ods with (appendonly=true, orientation=column, compresstype=zstd, compresslevel=1) as
    select
        p.region,
        pr.material,
        p.distr_chan,
        sum(p.quantity) as sum_quantity
    from std7_170.plan p
    join std7_170.product pr using(matdirec)
    where ' || v_where_date || '
    group by pr.material, p.region, p.distr_chan
    distributed by (region)';

    raise notice 'ODS table plan_sales_ods создана';

    -- Создание витрины plan_fact_YYYYMM
    v_sql := '
    create table ' || v_table_name || ' with (appendonly=true, orientation=column, compresstype=zstd, compresslevel=1) as
    select 
        aso.region,
        pr.matdirec,
        aso.distr_chan,
        pso.sum_quantity as plan_quantity,
        aso.sum_quantity as actual_quantity,
        round((aso.sum_quantity::numeric / pso.sum_quantity::numeric) * 100, 2) as procent_achievement_plan,
        aso.material
    from std7_170.actual_sales_ods aso
    join std7_170.plan_sales_ods pso using (region, material, distr_chan)
    join std7_170.product pr using (material)
    where rank = 1';

    -- Выполнение запроса на создание витрины
    execute v_sql;
    raise notice 'Витрина создана: %', v_sql;

	-- создание представления v_plan_fact
	execute 'create view std7_170.v_plan_fact as
		select
			pf.region,
			r.txt as region_txt,
			pf.matdirec,
			pf.distr_chan,
			c.txtsh as distr_chan_txt,
			pf.procent_achievement_plan,
			pf.material,
			p.brand,
			p.txt as material_txt,
			pr.price
		from ' || v_table_name || ' pf
		join std7_170.region r using(region)
		join std7_170.chanel c using(distr_chan)
		join std7_170.product p using(material)
		join std7_170.price pr using(material, region);';

    -- Подсчет количества строк в созданной таблице витрины
    execute 'select count(1) from ' || v_table_name into v_return;

    -- Возврат количества строк
    return v_return;
end;
$$
execute on any;

select * from f_load_mart('202103');
select * from v_plan_fact vpf
order by region;

