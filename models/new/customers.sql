-- models/staging/customers.sql

select
    customer_id,
    first_name,
    last_name,
    email,
    sign_up_date
from {{ source('public', 'raw_customers') }}
