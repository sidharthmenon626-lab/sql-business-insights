/*
Question      : Q4 - Top Products by Net Revenue (After Refunds)
Business Goal : Which products generate the highest net revenue after allocating order-level refunds?
Owner         : Sidharth Menon
Last Updated  : 2026-07-03

Sanity Checks
-------------
1. sum(gross_revenue) ≈ sum(qty * unit_price) from ecom.order_items.
2. sum(refunds_amount) ≈ sum(amount) from ecom.refunds.
3. refunds_amount <= gross_revenue for every product.
*/

with product_revenue as (

    select
          p.product_id
        , p.product_name
        , c.category_name as category
        , sum(oi.qty * oi.unit_price) as gross_revenue
        , count(distinct oi.order_id) as orders_count
        , sum(oi.qty) as units_sold

    from ecom.order_items oi

    join ecom.product_variants pv
        on oi.variant_id = pv.variant_id

    join ecom.products p
        on pv.product_id = p.product_id

    join ecom.categories c
        on p.category_id = c.category_id

    group by
          p.product_id
        , p.product_name
        , c.category_name

)

, product_returns as (

    select
          p.product_id
        , sum(ri.qty) as returns_count

    from ecom.return_items ri

    join ecom.product_variants pv
        on ri.variant_id = pv.variant_id

    join ecom.products p
        on pv.product_id = p.product_id

    group by
        p.product_id

)

, order_refund_totals as (

    select
          order_id
        , sum(amount) as refund_amount

    from ecom.refunds

    group by
        order_id

)

, order_totals as (

    select
          order_id
        , sum(line_total) as order_total

    from ecom.order_items

    group by
        order_id

)

, product_refunds as (

    -- Allocate order-level refunds proportionally across
    -- line items based on each line's contribution to the
    -- total order value.

    select
          p.product_id
        , sum(
              (
                  oi.line_total
                  / nullif(ot.order_total, 0)
              ) * ort.refund_amount
          ) as refunds_amount

    from ecom.order_items oi

    join ecom.product_variants pv
        on oi.variant_id = pv.variant_id

    join ecom.products p
        on pv.product_id = p.product_id

    join order_totals ot
        on oi.order_id = ot.order_id

    join order_refund_totals ort
        on oi.order_id = ort.order_id

    group by
        p.product_id

)

select
      pr.product_id
    , pr.product_name
    , pr.category
    , pr.gross_revenue
    , pr.orders_count
    , pr.units_sold
    , coalesce(ptr.returns_count, 0) as returns_count
    , round(
          coalesce(ptr.returns_count, 0)::numeric
          / nullif(pr.units_sold, 0)
      , 4) as return_rate
    , round(
          coalesce(pf.refunds_amount, 0)
      , 2) as refunds_amount
    , round(
          pr.gross_revenue
          - coalesce(pf.refunds_amount, 0)
      , 2) as net_revenue

from product_revenue pr

left join product_returns ptr
    on pr.product_id = ptr.product_id

left join product_refunds pf
    on pr.product_id = pf.product_id

order by
    net_revenue desc;
