/*
===============================================================================
Q8 - Customer LTV + Bucket Share of Revenue

Business Question:
    Who are our top spenders, and what share of revenue do they represent?

Output:
    - customer_id
    - first_order_date
    - last_order_date
    - total_orders
    - total_revenue
    - aov
    - ltv_bucket
    - ltv_bucket_share_of_revenue

Notes:
    - Excludes cancelled orders.
    - Calculates customer lifetime metrics.
    - Buckets customers by lifetime revenue.
    - Uses window functions to calculate each bucket's share of total revenue.
===============================================================================
*/

with customer_ltv as (

    select
        customer_id
        , min(created_at::date) as first_order_date
        , max(created_at::date) as last_order_date
        , count(*) as total_orders
        , sum(total) as total_revenue
        , sum(total) / nullif(count(*), 0) as aov
    from
        ecom.orders
    where
        lower(status) <> 'cancelled'
    group by
        customer_id

),

customer_ltv_bucketed as (

    select
        customer_id
        , first_order_date
        , last_order_date
        , total_orders
        , total_revenue
        , aov
        , case
            when total_revenue between 0 and 999 then '0-999'
            when total_revenue between 1000 and 4999 then '1000-4999'
            when total_revenue between 5000 and 19999 then '5000-19999'
            else '20000+'
          end as ltv_bucket
    from
        customer_ltv

)

select
    customer_id
    , first_order_date
    , last_order_date
    , total_orders
    , total_revenue
    , aov
    , ltv_bucket
    , sum(total_revenue) over (partition by ltv_bucket)
        / nullif(sum(total_revenue) over (), 0) as ltv_bucket_share_of_revenue
from
    customer_ltv_bucketed
order by
    total_revenue desc;
