{{
    config(
        materialized='incremental'
    )
}}

with amp_events_raw as (
    select *
    from {{ source('amp', 'AMPLITUDE_EVENTS_RAW_PYTHON') }}
),

amp_events_parsed as (

    SELECT 
        json_data:"$insert_id"::VARCHAR AS insert_id,
        json_data:"$insert_key"::VARCHAR AS insert_key,
        json_data:"$schema"::VARCHAR AS schema,
        json_data:"adid"::VARCHAR AS adid,
        json_data:"amplitude_attribution_ids"::VARCHAR AS amplitude_attribution_ids,
        json_data:"amplitude_event_type"::VARCHAR AS amplitude_event_type,
        json_data:"amplitude_id"::INTEGER AS amplitude_id,
        json_data:"app"::INTEGER AS app,
        json_data:"city"::VARCHAR AS city,
        json_data:"client_event_time"::VARCHAR AS client_event_time,
        json_data:"client_upload_time"::VARCHAR AS client_upload_time,
        json_data:"country"::VARCHAR AS country,
        json_data:"data"::VARCHAR AS data,
        json_data:"data_type"::VARCHAR AS data_type,
        json_data:"device_brand"::VARCHAR AS device_brand,
        json_data:"device_carrier"::VARCHAR AS device_carrier,
        json_data:"device_family"::VARCHAR AS device_family,
        json_data:"device_id"::VARCHAR AS device_id,
        json_data:"device_manufacturer"::VARCHAR AS device_manufacturer,
        json_data:"device_model"::VARCHAR AS device_model,
        json_data:"device_type"::VARCHAR AS device_type,
        json_data:"dma"::VARCHAR AS dma,
        json_data:"event_id"::INTEGER AS event_id,
        json_data:"event_properties"::variant AS event_properties,
        json_data:"event_time"::VARCHAR AS event_time,
        json_data:"event_type"::VARCHAR AS event_type,
        json_data:"global_user_properties"::VARCHAR AS global_user_properties,
        json_data:"group_properties"::VARCHAR AS group_properties,
        json_data:"groups"::VARCHAR AS groups,
        json_data:"idfa"::VARCHAR AS idfa,
        json_data:"ip_address"::VARCHAR AS ip_address,
        json_data:"is_attribution_event"::VARCHAR AS is_attribution_event,
        json_data:"language"::VARCHAR AS language,
        json_data:"library"::VARCHAR AS library,
        json_data:"location_lat"::VARCHAR AS location_lat,
        json_data:"location_lng"::VARCHAR AS location_lng,
        json_data:"os_name"::VARCHAR AS os_name,
        json_data:"os_version"::VARCHAR AS os_version,
        json_data:"partner_id"::VARCHAR AS partner_id,
        json_data:"paying"::VARCHAR AS paying,
        json_data:"plan"::VARCHAR AS plan,
        json_data:"platform"::VARCHAR AS platform,
        json_data:"processed_time"::VARCHAR AS processed_time,
        json_data:"region"::VARCHAR AS region,
        json_data:"sample_rate"::VARCHAR AS sample_rate,
        json_data:"server_received_time"::VARCHAR AS server_received_time,
        json_data:"server_upload_time"::VARCHAR AS server_upload_time,
        json_data:"session_id"::INTEGER AS session_id,
        json_data:"source_id"::VARCHAR AS source_id,
        json_data:"start_version"::VARCHAR AS start_version,
        json_data:"user_creation_time"::VARCHAR AS user_creation_time,
        json_data:"user_id"::VARCHAR AS user_id,
        json_data:"user_properties"::VARCHAR AS user_properties,
        json_data:"uuid"::VARCHAR AS uuid,
        json_data:"version_name"::VARCHAR AS version_name,
        TO_TIMESTAMP(json_data:"extract_time"::STRING, 'YYYY_MM_DD_"T"HH24-MI-SS') AS extract_time,

        --- surrogate keys
        {{ dbt_utils.generate_surrogate_key(['ip_address', 'city', 'country', 'region']) }} as location_sk_id,
        {{ dbt_utils.generate_surrogate_key(['session_id', 'event_id', 'device_id', 'amplitude_id', 'location_sk_id', 'extract_time']) }} as event_sk_id

    FROM amp_events_raw)

select *
from amp_events_parsed

{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where extract_time > (select max(extract_time) from {{ this }}) 
{% endif %}