/*
===============================================================================
question:      q3 - funnel conversion by acquisition channel
business:      where in the funnel does each channel's traffic leak?
owner:         sidharth menon
last updated:  2026-07-01
sanity check:
    - all conversion rates are between 0 and 1
    - sessions >= product_view_sessions >= add_to_cart_sessions
      >= begin_checkout_sessions >= purchase_sessions
    - sessions before 2026-04-19 are excluded because event
      instrumentation began on that date
===============================================================================
*/

with instrumented_sessions as (

    select
         session_id

    from ecom.sessions

    where started_at::date >= '2026-04-19'

),

session_channels as (

    select
         ins.session_id
        ,coalesce(sc.channel, 'direct') as channel

    from instrumented_sessions ins

    left join ecom.session_channels sc
        on ins.session_id = sc.session_id

),

session_funnel_stages as (

    select
         ins.session_id
        ,max(
            case
                when se.event_type = 'product_view' then 1
                else 0
            end
        ) as product_view
        ,max(
            case
                when se.event_type = 'add_to_cart' then 1
                else 0
            end
        ) as add_to_cart
        ,max(
            case
                when se.event_type = 'begin_checkout' then 1
                else 0
            end
        ) as begin_checkout
        ,max(
            case
                when se.event_type = 'purchase' then 1
                else 0
            end
        ) as purchase

    from instrumented_sessions ins

    left join ecom.session_events se
        on ins.session_id = se.session_id

    group by
         ins.session_id

),

channel_funnel as (

    select
         sc.channel
        ,count(*) as sessions
        ,sum(sfs.product_view) as product_view_sessions
        ,sum(sfs.add_to_cart) as add_to_cart_sessions
        ,sum(sfs.begin_checkout) as begin_checkout_sessions
        ,sum(sfs.purchase) as purchase_sessions

    from session_channels sc

    inner join session_funnel_stages sfs
        on sc.session_id = sfs.session_id

    group by
         sc.channel

),

final_report as (

    select
         cf.channel
        ,cf.sessions
        ,cf.product_view_sessions
        ,cf.add_to_cart_sessions
        ,cf.begin_checkout_sessions
        ,cf.purchase_sessions
        ,cf.add_to_cart_sessions::numeric
            / nullif(cf.product_view_sessions, 0) as view_to_cart_rate
        ,cf.begin_checkout_sessions::numeric
            / nullif(cf.add_to_cart_sessions, 0) as cart_to_checkout_rate
        ,cf.purchase_sessions::numeric
            / nullif(cf.begin_checkout_sessions, 0) as checkout_to_purchase_rate
        ,cf.purchase_sessions::numeric
            / nullif(cf.sessions, 0) as session_to_purchase_rate

    from channel_funnel cf

)

select
     fr.channel
    ,fr.sessions
    ,fr.product_view_sessions
    ,fr.add_to_cart_sessions
    ,fr.begin_checkout_sessions
    ,fr.purchase_sessions
    ,fr.view_to_cart_rate
    ,fr.cart_to_checkout_rate
    ,fr.checkout_to_purchase_rate
    ,fr.session_to_purchase_rate

from final_report fr

order by
     fr.sessions desc;
