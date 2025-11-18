with stg_stripe as (
    select *
    from {{ ref('stg_stripe__payments') }}
    where status not in ('fail')
)

select *
from stg_stripe