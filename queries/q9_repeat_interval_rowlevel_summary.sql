/*
===============================================================================
Q9A — Repeat Purchase Interval (Row-Level)
===============================================================================
Business Question:
How long does each customer take to place their next order?

Output:
- customer_id
- order_id
- order_date
- next_order_date
- days_to_next_order

Business Logic:
- Use the lead() window function to identify the next order placed by each
  customer.
- Partition by customer_id and order by created_at to preserve the
  chronological sequence of orders.
- Calculate the number of days between consecutive orders.
- Retain the final order for each customer, where next_order_date is null,
  as part of the row-level output.

Sanity Check:
- Verified that days_to_next_order >= 0 on every row.
- Result: ✅ Passed. All calculated repeat purchase intervals are
  non-negative, confirming the window function and date difference
  calculation are working correctly.

===============================================================================
*/

with customer_intervals as (

    select
        customer_id
        , order_id
        , created_at::date as order_date
        , lead(created_at::date) over (
            partition by customer_id
            order by created_at
        ) as next_order_date
    from ecom.orders
    where status <> 'cancelled'
)

select
    customer_id
    , order_id
    , order_date
    , next_order_date
    , next_order_date - order_date as days_to_next_order
from customer_intervals
order by
    customer_id
    , order_date;
/*
===============================================================================
Q9B — Repeat Purchase Interval (Summary)

Business Question:
Summarize customer repeat purchase intervals to understand how long customers
typically take to place their next order.

Outputs:
- interval_type
- avg_days_to_next_order
- median_days_to_next_order
- p90_days_to_next_order
- customers_with_repeat_order

Notes:
- Excludes the final order per customer (no next order exists).
- Produces two summaries:
    1. Including same-day repeat purchases.
    2. Excluding same-day repeat purchases.
Sanity Checks
===============================================================================

1. Excluding same-day intervals should never increase the number of repeat
   customers.

2. Median should always be less than or equal to the 90th percentile.

3. Excluding same-day intervals should typically increase (or keep unchanged)
   the average and median repeat purchase interval.
===============================================================================
===============================================================================
*/
with customer_intervals as (

    select
        customer_id
        , created_at::date as order_date
        , lead(created_at::date) over (
            partition by customer_id
            order by created_at
        ) as next_order_date
    from ecom.orders
    where status <> 'cancelled'
)

, repeat_purchase_intervals as (

    select
        customer_id
        , next_order_date - order_date as days_to_next_order
    from customer_intervals
    where next_order_date is not null

)

select
    'including_same_day' as interval_type
    , avg(days_to_next_order) as avg_days_to_next_order
    , percentile_cont(0.5) within group (order by days_to_next_order) as median_days_to_next_order
    , percentile_cont(0.9) within group (order by days_to_next_order) as p90_days_to_next_order
    , count(distinct customer_id) as customers_with_repeat_order
from repeat_purchase_intervals

union all

select
    'excluding_same_day' as interval_type
    , avg(days_to_next_order) as avg_days_to_next_order
    , percentile_cont(0.5) within group (order by days_to_next_order) as median_days_to_next_order
    , percentile_cont(0.9) within group (order by days_to_next_order) as p90_days_to_next_order
    , count(distinct customer_id) as customers_with_repeat_order
from repeat_purchase_intervals
where days_to_next_order > 0;
