{{
    config(
        materialized='incremental'
    )
}}


with events_base as (

    SELECT
        event_sk_id,
        row_number() over (partition by session_id, event_id, device_id, location_sk_id, amplitude_id, extract_time order by client_upload_time) as row_number,
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
        
events_base_deduped as (
    select *
    from events_base
    where row_number = 1
    )

select *
from events_base_deduped

{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where extract_time > (select max(extract_time) from {{ this }}) 
{% endif %}