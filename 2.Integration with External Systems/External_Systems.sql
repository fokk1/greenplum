CREATE external TABLE plan_ext (
	"date" date ,
	region varchar(20),
	matdirec int4,
	quantity int4,
	distr_chan varchar(100)
)
location (
	'pxf://gp.plan?PROFILE=Jdbc&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.214.212:5432/postgres&USER=intern&PASS=intern&PARTITION_BY=date:date&RANGE=2021-01-10:2021-07-30&INTERVAL=1:month'
) on all
format 'CUSTOM' (FORMATTER='pxfwritable_import')
encoding 'utf8';

create external table sales_ext (
	"date" date,
	region varchar(20),
	material int4,
	distr_chan varchar(100),
	quantity int4,
	check_nm varchar(100),
	check_pos varchar(100)
)
location (
	'pxf://gp.sales?PROFILE=Jdbc&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.214.212:5432/postgres&USER=intern&PASS=intern&PARTITION_BY=date:date&RANGE=2021-01-02:2021-07-26&INTERVAL=1:month'
) on all
format 'CUSTOM' (FORMATTER='pxfwritable_import')
encoding 'utf8';

create external table chanel_ext (
	distr_chan varchar(1),
	txtsh text
)
location (
	'gpfdist://172.16.128.202:8080/chanel.csv'
) on all
format 'csv' (delimiter ';' null '' escape '"' quote '"')
encoding 'utf8'
segment reject limit 10 rows;

create external table price_ext (
	material int4,
	region varchar(4),
	distr_chan varchar(1),
	price int4
)
location (
	'gpfdist://172.16.128.202:8080/price.csv'
) on all
format 'csv' (delimiter ';' null '' escape '"' quote '"')
encoding 'utf8'
segment reject limit 10 rows;

create external table product_ext (
	material int4,
	asgrp int4,
	brand int4,
	matcateg varchar(4),
	matdirec int4,
	txt text
)
location (
	'gpfdist://172.16.128.202:8080/product.csv'
) on all
format 'csv' (delimiter ';' null '' escape '"' quote '"')
encoding 'utf8'
segment reject limit 10 rows;

create external table region_ext (
	region varchar(4),
	txt text
)
location (
	'gpfdist://172.16.128.202:8080/region.csv'
) on all
format 'csv' (delimiter ';' null '' escape '"' quote '"')
encoding 'utf8'
segment reject limit 10 rows;






