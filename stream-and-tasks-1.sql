-- before we load the delta data we need to enable the stream objects, and all the stream objects will be append only
use schema kumar_db.landing_zone;

create or replace stream landing_item_stm on table landing_item
    append_only = true;

create or replace stream landing_order_stm on table landing_order
    append_only = true;

create or replace stream landing_customer_stm on table landing_customer
    append_only = true;

show streams;



-- create task in curated zone to load the tables
use schema kumar_db.curated_zone;

create or replace task order_curated_tsk
          warehouse = compute_wh 
          schedule  = '1 minute'
      when
          system$stream_has_data('kumar_db.landing_zone.landing_order_stm')
      as
        merge into kumar_db.curated_zone.curated_order curated_order 
        using kumar_db.landing_zone.landing_order_stm landing_order_stm on
        curated_order.order_date = landing_order_stm.order_date and 
        curated_order.order_time = landing_order_stm.order_time and 
        curated_order.item_id = landing_order_stm.item_id and
        curated_order.item_desc = landing_order_stm.item_desc 
      when matched 
         then update set 
            curated_order.customer_id = landing_order_stm.customer_id,
            curated_order.salutation = landing_order_stm.salutation,
            curated_order.first_name = landing_order_stm.first_name,
            curated_order.last_name = landing_order_stm.last_name,
            curated_order.store_id = landing_order_stm.store_id,
            curated_order.store_name = landing_order_stm.store_name,
            curated_order.order_quantity = landing_order_stm.order_quantity,
            curated_order.sale_price = landing_order_stm.sale_price,
            curated_order.discount_amt = landing_order_stm.discount_amt,
            curated_order.coupon_amt = landing_order_stm.coupon_amt,
            curated_order.net_paid = landing_order_stm.net_paid,
            curated_order.net_paid_tax = landing_order_stm.net_paid_tax,
            curated_order.net_profit = landing_order_stm.net_profit
          when not matched then 
          insert (
            order_date ,
            order_time ,
            item_id ,
            item_desc ,
            customer_id ,
            salutation ,
            first_name ,
            last_name ,
            store_id ,
            store_name ,
            order_quantity ,
            sale_price ,
            discount_amt ,
            coupon_amt ,
            net_paid ,
            net_paid_tax ,
            net_profit ) 
          values (
            landing_order_stm.order_date ,
            landing_order_stm.order_time ,
            landing_order_stm.item_id ,
            landing_order_stm.item_desc ,
            landing_order_stm.customer_id ,
            landing_order_stm.salutation ,
            landing_order_stm.first_name ,
            landing_order_stm.last_name ,
            landing_order_stm.store_id ,
            landing_order_stm.store_name ,
            landing_order_stm.order_quantity ,
            landing_order_stm.sale_price ,
            landing_order_stm.discount_amt ,
            landing_order_stm.coupon_amt ,
            landing_order_stm.net_paid ,
            landing_order_stm.net_paid_tax ,
            landing_order_stm.net_profit );

      create or replace task customer_curated_tsk
          warehouse = compute_wh 
          schedule  = '2 minute'
      when
          system$stream_has_data('kumar_db.landing_zone.landing_customer_stm')   
      as
      merge into kumar_db.curated_zone.curated_customer curated_customer 
      using kumar_db.landing_zone.landing_customer_stm landing_customer_stm on
      curated_customer.customer_id = landing_customer_stm.custmer_id
      when matched 
         then update set 
            curated_customer.salutation = landing_customer_stm.salutation,
            curated_customer.first_name = landing_customer_stm.first_name,
            curated_customer.last_name = landing_customer_stm.last_name,
            curated_customer.birth_day = landing_customer_stm.birth_day,
            curated_customer.birth_month = landing_customer_stm.birth_month,
            curated_customer.birth_year = landing_customer_stm.birth_year,
            curated_customer.birth_country = landing_customer_stm.birth_country,
            curated_customer.email_address = landing_customer_stm.email_address
      when not matched then 
        insert (
          customer_id ,
          salutation ,
          first_name ,
          last_name ,
          birth_day ,
          birth_month ,
          birth_year ,
          birth_country ,
          email_address ) 
        values (
          landing_customer_stm.custmer_id ,
          landing_customer_stm.salutation ,
          landing_customer_stm.first_name ,
          landing_customer_stm.last_name ,
          landing_customer_stm.birth_day ,
          landing_customer_stm.birth_month ,
          landing_customer_stm.birth_year ,
          landing_customer_stm.birth_country ,
          landing_customer_stm.email_address );

          
create or replace task item_curated_tsk
          warehouse = compute_wh 
          schedule  = '3 minute'
      when
          system$stream_has_data('kumar_db.landing_zone.landing_item_stm')
      as
      merge into kumar_db.curated_zone.curated_item item using kumar_db.landing_zone.landing_item_stm landing_item_stm on
      item.item_id = landing_item_stm.item_id and 
      item.item_desc = landing_item_stm.item_desc and 
      item.start_date = landing_item_stm.start_date
      when matched 
         then update set 
            item.end_date = landing_item_stm.end_date,
            item.price = landing_item_stm.price,
            item.item_class = landing_item_stm.item_class,
            item.item_category = landing_item_stm.item_category
      when not matched then 
        insert (
          item_id,
          item_desc,
          start_date,
          end_date,
          price,
          item_class,
          item_category) 
        values (
          landing_item_stm.item_id,
          landing_item_stm.item_desc,
          landing_item_stm.start_date,
          landing_item_stm.end_date,
          landing_item_stm.price,
          landing_item_stm.item_class,
          landing_item_stm.item_category);


-- alter task order_curated_tsk resume;
-- alter task customer_curated_tsk resume;
-- alter task item_curated_tsk resume;

-- alter task order_curated_tsk suspend;
-- alter task customer_curated_tsk suspend;
-- alter task item_curated_tsk suspend;


select *  from table(information_schema.task_history()) 
where name in ('CUSTOMER_CURATED_TSK' ,'ITEM_CURATED_TSK','ORDER_CURATED_TSK')
order by scheduled_time;
