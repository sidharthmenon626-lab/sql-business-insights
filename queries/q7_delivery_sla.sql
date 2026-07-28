/*
Q7 — Delivery SLA Breach by Carrier × Shipping Method

Business question:
"Who's missing the 5-day SLA, and by how much?"

SLA:
delivery_days = delivered_at::date - shipped_at::date
Late if delivery_days > 5.

Output:
carrier
shipping_method
delivered_orders
avg_delivery_days
median_delivery_days
p90_delivery_days
late_deliveries
late_rate

Sanity checks:
avg_delivery_days <= p90_delivery_days on every row
late_rate between 0 and 1
*/

with delivered_shipments as (

    select
         sc.carrier_name as carrier
        ,sm.method_name as shipping_method
        ,s.delivered_at::date - s.shipped_at::date as delivery_days
    from ecom.shipments s

    inner join ecom.shipping_methods sm
        on s.shipping_method_id = sm.shipping_method_id

    inner join ecom.shipping_carriers sc
        on s.carrier_id = sc.carrier_id

    where s.delivered_at is not null

)

select
     carrier
    ,shipping_method
    ,count(*) as delivered_orders
    ,avg(delivery_days) as avg_delivery_days
    ,percentile_cont(0.5) within group (order by delivery_days)
        as median_delivery_days
    ,percentile_cont(0.9) within group (order by delivery_days)
        as p90_delivery_days
    ,sum(
        case
            when delivery_days > 5 then 1
            else 0
        end
    ) as late_deliveries
    ,sum(
        case
            when delivery_days > 5 then 1
            else 0
        end
    )::numeric
        / nullif(count(*), 0) as late_rate
from delivered_shipments
group by
     carrier
    ,shipping_method
order by
     late_rate desc
    ,p90_delivery_days desc;
