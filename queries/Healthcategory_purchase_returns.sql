/*
Question: Q5 — Category Health: Purchases → Returns

Business Question:
Which categories generate the most revenue, and which have the highest return rates?

Owner: Sidharth Menon

Last Updated: 2026-07-03

Sanity Checks:
- return_rate_pct is between 0 and 100.
- returns <= orders_with_category for every category.
- Sum of category revenue matches paid order line_total within 0.5%.
*/

with category_sales as (

    select
         c.category_name as category
        ,count(distinct oi.order_id) as orders_with_category
        ,sum(oi.qty) as units_sold
        ,sum(oi.line_total) as revenue

    from ecom.order_items oi

    join ecom.orders o
        on oi.order_id = o.order_id

    join ecom.product_variants pv
        on oi.variant_id = pv.variant_id

    join ecom.products p
        on pv.product_id = p.product_id

    join ecom.categories c
        on p.category_id = c.category_id

    where o.payment_status = 'paid'

    group by
         c.category_name

),

category_returns as (

    select
         c.category_name as category
        ,sum(ri.qty) as returns

    from ecom.return_items ri

    join ecom.product_variants pv
        on ri.variant_id = pv.variant_id

    join ecom.products p
        on pv.product_id = p.product_id

    join ecom.categories c
        on p.category_id = c.category_id

    group by
         c.category_name

)

select
     cs.category
    ,cs.orders_with_category
    ,cs.units_sold
    ,cs.revenue
    ,coalesce(cr.returns, 0) as returns
    ,round(
         coalesce(cr.returns, 0) * 100.0
         / nullif(cs.orders_with_category, 0)
        ,2
     ) as return_rate_pct

from category_sales cs

left join category_returns cr
    on cs.category = cr.category

order by
     cs.revenue desc;
