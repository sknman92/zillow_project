{{
    config(
        materialized='incremental',
        unique_key = 'email_activity_id'
    )
}}

with source as (
    select *
        , {{ dbt_utils.generate_surrogate_key(['campaign_id', 'email_id', 'action', 'timestamp', 'type', 'url' ,'extract_time']) }} as email_activity_id
    from {{ source('mailchimp', 'mailchimp_raw_python_email_activity') }}
    where type != 'open'
)

select *
from source

{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where timestamp > (select max(timestamp) from {{ this }}) 
{% endif %}




