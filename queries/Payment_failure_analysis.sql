/*
Question      : Q6 - Payment Failure Analysis (Method x Top Error Code)
Business      : Which payment methods fail most, and what's the top reason?
Owner         : Sidharth Menon
Last Updated  : 2026-07-02
Sanity Check  :
  - failure_rate is between 0 and 1
  - top_error_share_of_failures is between 0 and 1
  - failures <= attempts for every method
Pattern note  : Classic top-N-per-group. CTE 1 aggregates attempts/failures per
                method; CTE 2 ranks error codes per method with row_number() and
                the final join keeps rn = 1. A plain group by cannot pick the top
                error per method.
*/

with payment_method_performance as (
    select
         pm.method_name as payment_method
        ,count(pi.payment_intent_id) as attempts
        ,count(*) filter (where pi.status = 'failed') as failures
        ,count(*) filter (where pi.status = 'failed')::numeric
            / nullif(count(pi.payment_intent_id), 0) as failure_rate
    from ecom.payment_intents pi
    join ecom.payment_methods pm
        on pi.payment_method_id = pm.payment_method_id
    group by
        pm.method_name
),

payment_error_counts as (
    select
         pm.method_name as payment_method
        ,pt.error_code
        ,pt.error_message
        ,count(*) as error_count
    from ecom.payment_transactions pt
    join ecom.payment_intents pi
        on pt.payment_intent_id = pi.payment_intent_id
    join ecom.payment_methods pm
        on pi.payment_method_id = pm.payment_method_id
    where pt.status = 'failed'
    group by
         pm.method_name
        ,pt.error_code
        ,pt.error_message
),

ranked_payment_errors as (
    select
         payment_method
        ,error_code
        ,error_message
        ,error_count
        ,row_number() over (
            partition by payment_method
            order by error_count desc
        ) as rn
    from payment_error_counts
)

select
     pmp.payment_method
    ,pmp.attempts
    ,pmp.failures
    ,pmp.failure_rate
    ,rpe.error_code as top_error_code
    ,rpe.error_message as top_error_message
    ,rpe.error_count::numeric
        / nullif(pmp.failures, 0) as top_error_share_of_failures
from payment_method_performance pmp
left join ranked_payment_errors rpe
    on pmp.payment_method = rpe.payment_method
    and rpe.rn = 1
;
