
 with cte as (
        select
        "amplitude_id"
        ,"client_event_time"
        ,"country"
        ,"region"
        ,"city"
        ,"event_time"
        ,"event_type"
        ,"event_properties" --needs parsing
        ,value::string as value
        ,key::string as col
    from {{ ref("stg_amplitude__amplitude_events") }},
    lateral flatten("event_properties")
    )

SELECT *
FROM (
    SELECT * FROM cte
) 
PIVOT (
    MAX(value) FOR col IN (
        '[Amplitude] Session Replay ID',
        '[Amplitude] Page Counter',
        '[Amplitude] Page Domain',
        '[Amplitude] Page Location',
        '[Amplitude] Page Path',
        '[Amplitude] Page Title',
        '[Amplitude] Page URL',
        'referring_domain'
    )
)