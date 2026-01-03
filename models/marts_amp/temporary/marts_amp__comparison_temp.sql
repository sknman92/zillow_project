with events as (
    select
        event_sk_id,
        session_id,
        event_id,
        event_time,
        client_upload_time,
        client_event_time,
        event_type,
        device_id,
        amplitude_id,
        extract_time,
        location_sk_id,
        event_properties:"[Amplitude] Page Counter"::integer AS page_counter,
        event_properties:"[Amplitude] Page Domain"::string AS page_domain,
        event_properties:"[Amplitude] Page Location"::string AS page_location,
        event_properties:"[Amplitude] Page Path"::string AS page_path,
        event_properties:"[Amplitude] Page Title"::string AS page_title,
        event_properties:"[Amplitude] Page URL"::string AS page_url,
        event_properties:"referrer"::string AS referrer,
        event_properties:"referring_domain"::string AS referring_domain
    FROM {{ ref('stg_amp__base_level') }}
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
    select 
       e.*
       , l.ip_address
       , l.city
       , l.country
       , l.region
       , u.user_id
       , u.company
    from events as e

    full join locations as l
        on e.location_sk_id = l.location_sk_id
        
    full join users as u
        on e.amplitude_id = u.amplitude_id
)

select *
from joined