{{
    config(
        materialized='incremental',
        unique_key='clicks_id'
    )
}}

with source as (
    select 
        url_link
        , url_id
        , campaign_id
        , email_id
        , email_address
        , clicks
        , extract_time
        ,  {{ dbt_utils.generate_surrogate_key(['url_link', 'url_id', 'campaign_id', 'email_id', 'email_address']) }} as clicks_id
    from {{ source('mailchimp', 'mailchimp_raw_python_clicks') }}
)

select *
from source

{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where extract_time > (select max(extract_time) from {{ this }}) 
{% endif %}


