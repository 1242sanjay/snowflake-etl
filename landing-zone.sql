-- step-1
-- Lets create database and 3 schemas called landing, curated and consumption zone
create or replace database kumar_db;
create or replace schema landing_zone;
create or replace schema curated_zone;
create or replace schema consumption_zone;
show schemas;


-- step-2
-- create order, item & customer table in landing zone
-- landing zone ta bles will be transient tables
-- all the fields in these tables are varchar and not having specific data type to make sure all the data is loaded.
use schema landing_zone;
create or replace transient table landing_item(
    item_id varchar,
    item_desc varchar,
    start_date varchar,
    end_date varchar,
    price varchar,
    item_class varchar,
    item_category varchar
) comment = 'this is item table with in landing schema';

create or replace transient table landing_customer(
    custmer_id varchar,
    salutation varchar,
    first_name varchar,
    last_name varchar,
    birth_day varchar,
    birth_month varchar,
    birth_year varchar,
    birth_country varchar,
    email_address varchar
) comment = 'this is customer table with in landing schema';

create or replace transient table landing_order(
    order_date varchar,
    order_time varchar,
    item_id varchar,
    item_desc varchar,
    customer_id varchar,
    salutation varchar,
    first_name varchar,
    last_name varchar,
    store_id varchar,
    store_name varchar,
    order_quantity varchar,
    sale_price varchar,
    discount_amt varchar,
    coupon_amt varchar,
    net_paid varchar,
    net_paid_tax varchar,
    net_profit varchar
) comment = 'this is order table with in landing schema';

-- step-3
-- Create a file format and have a history data loaded as 1st time load to these landing tables
create or replace file format my_csv_ff
    type = 'csv'
    compression = 'auto'
    field_delimiter = ','
    record_delimiter = '\n'
    skip_header = 1
    field_optionally_enclosed_by = '\042'
    null_if = ('\\N');

-- step-4
-- Now lets load the data (history load or 1st time data load) via WebUI and validate the row counts and first few rows
-- to see tables
show tables;
select * from landing_customer;  -- 20
select * from landing_item ;  -- 21
select * from landing_order;  -- 19



