

with source as (

    select * from {{ source('time', 'internet_speed_test') }}

),

renamed as (

    --Just bring in the proper json from the reformatted upload
    select
    parse_json(json) as json,
    __uploaded
    from source
    where json ILIKE '%"Type": "result"%'
    OR json ILIKE '%"Type":"result"%'


)

select * from renamed
