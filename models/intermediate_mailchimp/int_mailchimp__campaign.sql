with clicks as (
    select *
    from {{ ref('stg_mailchimp__clicks') }}
),

campaigns as (
    select *
    from {{ ref('stg_mailchimp__campaigns') }}
),

clicks_agg_campaigns as (
    select campaign_id
    , url_id
    , url_link
    , sum(clicks) as total_clicks
from clicks
group by 1, 2, 3
),

final_cte as (
     select a.campaign_id
         , a.url_id
         , a.url_link
         , c.campaign_title
         , c.emails_sent
         , c.clicks as campaign_clicks
         , a.total_clicks as url_clicks
         , round((url_clicks/campaign_clicks) * 100, 2) as click_percent
     from clicks_agg_campaigns as a
     join campaigns as c
         on a.campaign_id = c.campaign_id
     order by campaign_id, url_id
 )

select *
from final_cte

