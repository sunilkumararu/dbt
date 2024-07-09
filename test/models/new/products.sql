-- models/staging/products.sql

select
    product_id,
    product_name,
    category,
    price
from {{ source('public', 'products') }}
