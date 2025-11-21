--depends_on {{ ref('marts_amp__comparison_temp') }}

with events as (
    select *
    from {{ ref('int_amp__events') }}
),

locations as (
    select *
    from {{ ref('int_amp__locations') }}
),

users as (
    select *
    from {{ ref('int_amp__users') }}
),

--7035
joined as (
    select *
    from events as e

    left join locations as l
        on e.location_sk_id = l.location_sk_id
        
    left join users as u
        on e.amplitude_id = u.amplitude_id
),

clicks as (
    select
        *,
        row_number() over (partition by session_id, extract_time, page_title order by event_id) as clicks
    from joined
    where event_type = '[Amplitude] Element Clicked'
),

max_clicks as (
    select distinct
        session_id,
        extract_time,
        page_title,
        max(clicks) over (partition by session_id, extract_time, page_title) as max_clicks
    FROM clicks
    order by max_clicks desc
)

select *
from max_clicks