*
Q2 - Monthly Cohort Retention

Business Question:
For each customer's first successful purchase month,
how many customers returned in Month 1, Month 2 and Month 3?

Owner: Sidharth Menon
Last Updated: 2026-06-30

Business Rules:
- Cohort month is defined as the customer's first non-cancelled order.
- Cancelled orders do not count towards retention.
- Censored months are shown as NULL.

Sanity Checks:
- Retention rates are between 0 and 1.
- Censored months display NULL instead of 0.
*/

with customer_first_order_month as (

    select
         customer_id
        ,date_trunc('month', min(created_at))::date as cohort_month
    from ecom.orders
    where status <> 'cancelled'
    group by
         customer_id

),

customer_order_months as (

    select distinct
         customer_id
        ,date_trunc('month', created_at)::date as order_month
    from ecom.orders
    where status <> 'cancelled'

),

customer_month_offsets as (

    select
         cfom.customer_id
        ,cfom.cohort_month
        ,com.order_month
        ,(
            (
                extract(year from com.order_month)
                - extract(year from cfom.cohort_month)
            ) * 12
            +
            (
                extract(month from com.order_month)
                - extract(month from cfom.cohort_month)
            )
        )::int as month_offset

    from customer_first_order_month cfom

    left join customer_order_months com
        on cfom.customer_id = com.customer_id

),

cohort_sizes as (

    select
         cohort_month
        ,count(customer_id) as cohort_size
    from customer_first_order_month
    group by
         cohort_month

),

cohort_retention as (

    select
         cohort_month

        ,count(distinct customer_id) filter (
            where month_offset = 1
        ) as m1_retained

        ,count(distinct customer_id) filter (
            where month_offset = 2
        ) as m2_retained

        ,count(distinct customer_id) filter (
            where month_offset = 3
        ) as m3_retained

    from customer_month_offsets

    group by
         cohort_month

),

latest_order_month as (

    select
         date_trunc('month', max(created_at))::date as max_order_month
    from ecom.orders
    where status <> 'cancelled'

),

final_report as (

    select
         cs.cohort_month
        ,cs.cohort_size

        ,case
            when cs.cohort_month + interval '1 month' <= lom.max_order_month
                then coalesce(cr.m1_retained, 0)
            else null
         end as m1_retained

        ,case
            when cs.cohort_month + interval '2 month' <= lom.max_order_month
                then coalesce(cr.m2_retained, 0)
            else null
         end as m2_retained

        ,case
            when cs.cohort_month + interval '3 month' <= lom.max_order_month
                then coalesce(cr.m3_retained, 0)
            else null
         end as m3_retained

        ,case
            when cs.cohort_month + interval '1 month' <= lom.max_order_month
                then round(
                    coalesce(cr.m1_retained, 0)::numeric
                    / nullif(cs.cohort_size, 0),
                    4
                )
            else null
         end as m1_retention_rate

        ,case
            when cs.cohort_month + interval '2 month' <= lom.max_order_month
                then round(
                    coalesce(cr.m2_retained, 0)::numeric
                    / nullif(cs.cohort_size, 0),
                    4
                )
            else null
         end as m2_retention_rate

        ,case
            when cs.cohort_month + interval '3 month' <= lom.max_order_month
                then round(
                    coalesce(cr.m3_retained, 0)::numeric
                    / nullif(cs.cohort_size, 0),
                    4
                )
            else null
         end as m3_retention_rate

    from cohort_sizes cs

    left join cohort_retention cr
        on cs.cohort_month = cr.cohort_month

    cross join latest_order_month lom

)

select
     cohort_month
    ,cohort_size
    ,m1_retained
    ,m2_retained
    ,m3_retained
    ,m1_retention_rate
    ,m2_retention_rate
    ,m3_retention_rate
from final_report
order by
     cohort_month asc;
