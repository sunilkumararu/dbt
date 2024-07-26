-- models/staging/orders.sql

select
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    total_amount
from "ilufzqee"."public"."raw_orders"