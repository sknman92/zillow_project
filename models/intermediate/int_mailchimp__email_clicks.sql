with email as (
    select *
    from {{ ref('stg_mailchimp__email_activity') }}
),

duplicate_clicks as (
    select 
        campaign_id
        , email_id
        , email_address
        , count(action) as total_clicks
        , timestamp
        , type
        , url
        , ip_hashed
        , extract_time
    from email
    group by all
),

final_cte as (
    select *
    , CASE
        when total_clicks > 1 then 'True'
        else 'False'
      end as duplicate_clicks_flag
    from duplicate_clicks
    order by duplicate_clicks_flag desc, total_clicks desc
)

select *
from final_cte