/*
===============================================================================
Q10. Attribution Comparison: First-Touch vs Last-Touch Revenue by Channel

Business Question:
How does channel performance differ under first-touch versus last-touch
attribution? Which channels introduce customers into the funnel, and which
channels are responsible for closing conversions?

Output:
- attribution_model
- channel
- revenue
- orders
- share_of_revenue

Logic:
- Rank attribution touches by customer using touched_at in ascending order
  (first touch) and descending order (last touch).
- Join the identified first-touch and last-touch channels back to orders.
- Assign orders without attribution touches to the 'direct' channel.
- Exclude cancelled orders.
- Aggregate revenue and order counts separately for first-touch and
  last-touch attribution.
- Combine both attribution models using UNION ALL.

Sanity Check:
- Total revenue attributed under first_touch should equal total revenue
  attributed under last_touch.
- Both totals should equal total revenue from non-cancelled orders.
- Percentage difference should be less than or equal to 0.5%
  (ideally 0.00%), confirming that attribution reallocates revenue
  without creating or losing it.
===============================================================================
*/

with touch_rankings as (

    select
        s.customer_id
        , at.channel
        , at.touched_at
        , row_number() over (
            partition by s.customer_id
            order by at.touched_at
        ) as rn_first
        , row_number() over (
            partition by s.customer_id
            order by at.touched_at desc
        ) as rn_last
    from ecom.attribution_touches at
    inner join ecom.sessions s
        on at.session_id = s.session_id

),

first_touch as (

    select
        customer_id
        , channel as first_touch_channel
    from touch_rankings
    where rn_first = 1

),

last_touch as (

    select
        customer_id
        , channel as last_touch_channel
    from touch_rankings
    where rn_last = 1

),

orders_with_channels as (

    select
        o.order_id
        , o.customer_id
        , o.total
        , coalesce(ft.first_touch_channel, 'direct') as first_touch_channel
        , coalesce(lt.last_touch_channel, 'direct') as last_touch_channel
    from ecom.orders o
    left join first_touch ft
        on o.customer_id = ft.customer_id
    left join last_touch lt
        on o.customer_id = lt.customer_id
    where lower(o.status) <> 'cancelled'

),

first_touch_summary as (

    select
        'first_touch' as attribution_model
        , first_touch_channel as channel
        , sum(total) as revenue
        , count(order_id) as orders
        , sum(total) / sum(sum(total)) over () as share_of_revenue
    from orders_with_channels
    group by
        first_touch_channel

),

last_touch_summary as (

    select
        'last_touch' as attribution_model
        , last_touch_channel as channel
        , sum(total) as revenue
        , count(order_id) as orders
        , sum(total) / sum(sum(total)) over () as share_of_revenue
    from orders_with_channels
    group by
        last_touch_channel

)

select
    attribution_model
    , channel
    , revenue
    , orders
    , share_of_revenue
from first_touch_summary

union all

select
    attribution_model
    , channel
    , revenue
    , orders
    , share_of_revenue
from last_touch_summary

order by
    attribution_model
    , revenue desc;
