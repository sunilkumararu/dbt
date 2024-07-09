-- models/marts/customer_order_summary.sql

-- CTE to get raw order data with product and customer details
with raw_order_data as (
    select
        o.order_id,
        o.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.sign_up_date,
        o.product_id,
        p.product_name,
        p.category,
        o.order_date,
        o.quantity,
        o.total_amount
    from {{ ref('orders') }} o
    join {{ ref('customers') }} c on o.customer_id = c.customer_id
    join {{ ref('products') }} p on o.product_id = p.product_id
),

-- CTE to calculate order statistics
order_stats as (
    select
        customer_id,
        count(order_id) as total_orders,
        sum(quantity) as total_quantity,
        sum(total_amount) as total_spent,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from raw_order_data
    group by customer_id
),

-- CTE to determine the favorite product and category
favorite_product_category as (
    select
        customer_id,
        product_name as favorite_product,
        category as favorite_category
    from (
        select
            customer_id,
            product_name,
            category,
            row_number() over(partition by customer_id order by sum(total_amount) desc) as rnk
        from raw_order_data
        group by customer_id, product_name, category
    ) ranked
    where rnk = 1
)

-- Final select statement to combine everything into the summary table
select
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.sign_up_date,
    os.total_orders,
    os.total_quantity,
    os.total_spent,
    os.first_order_date,
    os.last_order_date,
    fp.favorite_product,
    fp.favorite_category
from order_stats os
join {{ ref('customers') }} c on os.customer_id = c.customer_id
left join favorite_product_category fp on os.customer_id = fp.customer_id
