-- landing zone table
select * from kumar_db.landing_zone.landing_customer;  -- 20  --> 21 --> 20 --> 22
select * from kumar_db.landing_zone.landing_item ;     -- 21  --> 22 --> 21 --> 23
select * from kumar_db.landing_zone.landing_order;     -- 19  --> 20 --> 19 --> 21

-- delete from kumar_db.landing_zone.landing_customer where customer_id in ('AAAAAAAAPOJJJDAA');
-- delete from kumar_db.landing_zone.landing_item  where item_id in ('AAAAAAAACDLBXPPP');
-- delete from kumar_db.landing_zone.landing_order where item_id in ('AAAAAAAACDLBXPPP');

 -- landing zone stream
select * from kumar_db.landing_zone.landing_customer_stm;  -- 0 --> 1 --> 0 append only --> 2
select * from kumar_db.landing_zone.landing_item_stm;      -- 0 --> 1 --> 0 append only --> 2
select * from kumar_db.landing_zone.landing_order_stm;     -- 0 --> 1 --> 0 append only --> 2


-- task set-1
select *  from table(information_schema.task_history()) 
where name in ('CUSTOMER_CURATED_TSK' ,'ITEM_CURATED_TSK','ORDER_CURATED_TSK')
order by scheduled_time desc;

-- curated_zone table
select * from kumar_db.curated_zone.curated_customer; -- 20  --> 21 --> 20 --> 22
select * from kumar_db.curated_zone.curated_item;     -- 21  --> 22 --> 21 --> 23
select * from kumar_db.curated_zone.curated_order;    -- 19  --> 20 --> 19 --> 21

-- delete from kumar_db.curated_zone.curated_customer where customer_id in ('AAAAAAAAPOJJJDAA');
-- delete from kumar_db.curated_zone.curated_item where item_id in ('AAAAAAAACDLBXPPP');
-- delete from kumar_db.curated_zone.curated_order where item_id in ('AAAAAAAACDLBXPPP');

-- curated_zone stream   
select * from kumar_db.curated_zone.curated_customer_stm;  -- 0 --> 1 --> 1 --> 2
select * from kumar_db.curated_zone.curated_item_stm;      -- 0 --> 1 --> 1 --> 2
select * from kumar_db.curated_zone.curated_order_stm;     -- 0 --> 1 --> 1 --> 2

-- task set-2
select *  from table(information_schema.task_history()) 
where name in ('ITEM_CONSUMPTION_TSK' ,'CUSTOMER_CONSUMPTION_TSK','ORDER_FACT_TSK')
order by scheduled_time desc;

-- consumption_zone table
select * from kumar_db.consumption_zone.customer_dim;  -- 20 --> 21 --> 21 --> 22
select * from kumar_db.consumption_zone.item_dim;      -- 21 --> 22 --> 22 --> 23
select * from kumar_db.consumption_zone.order_fact;    -- 5  --> 6  --> 5  --> 7



select $1 from @delta_orders_s3/orders02.csv;
select $1 from @delta_customer_s3/customer02.csv;

list @kumar_db.landing_zone.delta_customer_s3;
