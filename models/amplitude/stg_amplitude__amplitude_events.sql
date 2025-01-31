with 

source as (

    select * from {{ source('amplitude', 'amplitude_events') }}

),

renamed as (

    select
        "amplitude_id"
        ,"client_event_time"
        ,"country"
        ,"region"
        ,"city"
        ,"event_time"
        ,"event_type"
        ,"event_properties" --needs parsing

    from source

)

select * from renamed
