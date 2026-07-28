/*
Question      : Q1 - Daily Business Summary with DoD and Same-Weekday WoW
Business      : How are we doing today vs yesterday, and vs the same day last week?
Owner         : Sidharth Menon
Last Updated  : 2026-06-27
Sanity Check  :
  - paid_order_rate is between 0 and 1
  - revenue excludes cancelled orders
  - orders exclude cancelled orders
  - refunds_amount includes only succeeded refunds
*/

with clean_orders as (

    select
         created_at::date as order_date
        ,lower(status) as order_status
        ,payment_status
        ,total
    from ecom.orders

),

daily_metrics as (

    select
         order_date
        ,sum(total) as revenue
        ,count(*) as orders
        ,round(
            sum(total) / nullif(count(*), 0)
            ,2
        ) as aov
    from clean_orders
    where order_status <> 'cancelled'
    group by
         order_date

),

daily_payment_rates as (

    select
         order_date
        ,count(*) filter (
            where payment_status = 'paid'
        )::numeric
        / nullif(count(*), 0) as paid_order_rate

        ,count(*) filter (
            where order_status = 'cancelled'
        )::numeric
        / nullif(count(*), 0) as cancelled_order_rate

    from clean_orders
    group by
         order_date

),

daily_refunds as (

    select
         created_at::date as order_date
        ,sum(amount) as refunds_amount
    from ecom.refunds
    where lower(status) = 'succeeded'
    group by
         created_at::date

),

daily_summary as (

    select
         dm.order_date
        ,dm.revenue
        ,dm.orders
        ,dm.aov
        ,dpr.paid_order_rate
        ,dpr.cancelled_order_rate
        ,coalesce(dr.refunds_amount, 0) as refunds_amount
    from daily_metrics dm
    left join daily_payment_rates dpr
        on dm.order_date = dpr.order_date
    left join daily_refunds dr
        on dm.order_date = dr.order_date

),

final_report as (

    select
         order_date
        ,revenue
        ,orders
        ,aov
        ,paid_order_rate
        ,cancelled_order_rate
        ,refunds_amount

        ,round(
            (
                revenue
                - lag(revenue) over (
                    order by order_date
                )
            )
            /
            nullif(
                lag(revenue) over (
                    order by order_date
                )
                ,0
            )
            ,4
        ) as revenue_vs_yesterday_pct

        ,round(
            (
                revenue
                - lag(revenue, 7) over (
                    order by order_date
                )
            )
            /
            nullif(
                lag(revenue, 7) over (
                    order by order_date
                )
                ,0
            )
            ,4
        ) as revenue_vs_last_weekday_pct

    from daily_summary

)

select
     order_date
    ,revenue
    ,orders
    ,aov
    ,paid_order_rate
    ,cancelled_order_rate
    ,refunds_amount
    ,revenue_vs_yesterday_pct
    ,revenue_vs_last_weekday_pct
from final_report
order by
     order_date;
