with source as (
    select *
    from {{ ref('snapshot_mailchimp_campaigns') }}
    where dbt_valid_to is null
)

select campaign_id
    , campaign_title
    , emails_sent
    , unsubscribed
    , abuse_reports
    , bounces:"hard_bounces"::NUMBER as hard_bounces
    , bounces:"soft_bounces"::NUMBER as soft_bounces
    , bounces:"syntax_errors"::NUMBER as syntax_errors
    , forwards:"forwards_count"::NUMBER as forwards_count
    , forwards:"forwards_opens"::NUMBER as forwards_open
    , opens
    , clicks
    , last_open
    , last_click
    , extract_time
from source

