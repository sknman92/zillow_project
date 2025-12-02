with email_clicks as (
    select *
    from {{ ref('int_mailchimp__email_clicks') }}
),

time_lag as (
    select *
    , lag(timestamp, 1) over (
        partition by campaign_id, email_id, email_address, url, ip_hashed, duplicate_clicks_flag
        order by timestamp
    ) as previous_time
    from email_clicks
),

time_diff as (
    select *
        , DATEDIFF('second', previous_time, timestamp) AS seconds_diff
    from time_lag
),

agg as (
    select
        campaign_id,
        email_id,
        email_address,
        url,
        ip_hashed,
        count_if(seconds_diff < 5) as clicks_within_5_seconds,
        count(*) as total_clicks
    from time_diff
    group by 1,2,3,4,5
    order by 1, 2, 3, 4, 6
),

campaign as (
    select *
    from {{ ref('stg_mailchimp__campaigns') }}
),

final_cte as (
    select a.*
    , c.campaign_title
    from agg as a
    join campaign as c 
        on a.campaign_id = c.campaign_id
)

select *
from final_cte