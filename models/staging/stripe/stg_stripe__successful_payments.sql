with stg_stripe__payments as (
    select *
    from {{ ref('stg_stripe__payments') }}
    where status not in ('fail')
)

select *
from stg_stripe__payments