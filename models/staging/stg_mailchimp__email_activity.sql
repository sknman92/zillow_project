with source as (
    select *
    from {{ source('mailchimp', 'mailchimp_raw_python_email_activity') }}
)

select *
from source





