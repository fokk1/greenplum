--facts

CREATE TABLE std7_170.sales (
	"date" date NULL,
	region varchar(20) NULL,
	material int4 NOT NULL,
	distr_chan varchar(100) NULL,
	quantity int4 NULL,
	check_nm varchar(100) NOT NULL,
	check_pos varchar(100) NOT NULL
)
WITH (
    appendonly = true,
    orientation = column,
    compresstype = zstd,
    compresslevel = 1
)
DISTRIBUTED BY (check_nm)
PARTITION BY RANGE(date) 
          (
          START ('2021-01-01'::date) END ('2021-12-31'::date) EVERY ('1 mon'::interval), 
          DEFAULT PARTITION sales_others
          );
         
drop table std7_170.sales;
          
         
CREATE TABLE std7_170.plan (
	"date" date NOT NULL,
	region varchar(20) NOT NULL,
	matdirec int4 NULL,
	quantity int4 NULL,
	distr_chan varchar(100) NOT NULL
)
WITH (
    appendonly = true,
    orientation = column,
    compresstype = zstd,
    compresslevel = 1
)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE(date) 
          (
          START ('2021-01-01'::date) END ('2021-12-31'::date) EVERY ('1 mon'::interval), 
          DEFAULT PARTITION plan_others
          );
         
         
--dimensions 
        
CREATE TABLE std7_170.chanel (
	distr_chan varchar(1) NULL,
	txtsh text NULL
)
DISTRIBUTED REPLICATED;


CREATE TABLE std7_170.price (
	material int4 NOT NULL,
	region varchar(4) NOT NULL,
	distr_chan varchar(1) NOT NULL,
	price int4 NULL
)
DISTRIBUTED REPLICATED;

CREATE TABLE std7_170.product (
	material int4 NULL,
	asgrp int4 NULL,
	brand int4 NULL,
	matcateg varchar(4) NULL,
	matdirec int4 NULL,
	txt text NULL
)
DISTRIBUTED REPLICATED;

CREATE TABLE std7_170.region (
	region varchar(4) NULL,
	txt text NULL
)
DISTRIBUTED REPLICATED;
