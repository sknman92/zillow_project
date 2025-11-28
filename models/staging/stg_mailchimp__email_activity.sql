with source as (
    select campaign_id
        , email_id  
        , email_address 
        , action
        , timestamp
        , type
        , url
        , hash(ip) as ip_hashed
        , extract_time
        , {{ dbt_utils.generate_surrogate_key(['campaign_id', 'email_id', 'action', 'timestamp', 'type', 'url', 'ip']) }} as email_activity_id
    from {{ source('mailchimp', 'mailchimp_raw_python_email_activity') }}
)

select *
from source



