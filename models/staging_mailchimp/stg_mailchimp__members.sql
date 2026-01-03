with source as (
    select *
    from {{ ref('snapshot_mailchimp_members') }}
    where dbt_valid_to is null
)

select *
from source

