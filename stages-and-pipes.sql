-- storage integration
create or replace storage integration aws_S3_integration
type = external_stage
storage_provider = 'S3'
enabled = true
storage_aws_role_arn = 'arn:aws:iam::396913714134:role/aws-snowflake'
storage_allowed_locations = ('s3://aws-snow-bucket/');

desc storage integration aws_s3_integration;

-- order stage
create or replace stage delta_orders_s3
url = 's3://aws-snow-bucket/delta/orders/'
storage_integration = aws_s3_integration
comment = 'feed delta order files';

-- item stage
create or replace stage delta_items_s3
url = 's3://aws-snow-bucket/delta/items/'
storage_integration = aws_s3_integration
comment = 'feed delta item files';

-- customer stage
create or replace stage delta_customer_s3
url = 's3://aws-snow-bucket/delta/customers/'
storage_integration = aws_s3_integration
comment = 'feed delta customer files';

show stages;

-- Create pipe objects for each of the tables
create or replace pipe order_pipe
    auto_ingest = true
    as 
        copy into landing_order from @delta_orders_s3
        file_format = (type=csv COMPRESSION=none)
        pattern='.*order.*[.]csv'
        ON_ERROR = 'CONTINUE';

create or replace pipe item_pipe
    auto_ingest = true
    as 
        copy into landing_item from @delta_items_s3
        file_format = (type=csv COMPRESSION=none)
        pattern='.*item.*[.]csv'
        ON_ERROR = 'CONTINUE';

create or replace pipe customer_pipe
    auto_ingest = true
    as 
        copy into landing_customer from @delta_customer_s3
        file_format = (type=csv COMPRESSION=none)
        pattern='.*customer.*[.]csv'
        ON_ERROR = 'CONTINUE';

show pipes;

-- lets check if the pipes are running or not
select system$pipe_status('order_pipe');
select system$pipe_status('item_pipe');
select system$pipe_status('customer_pipe');

ALTER PIPE order_pipe SET PIPE_EXECUTION_PAUSED = TRUE;
ALTER PIPE item_pipe SET PIPE_EXECUTION_PAUSED = TRUE;
ALTER PIPE customer_pipe SET PIPE_EXECUTION_PAUSED = TRUE;
