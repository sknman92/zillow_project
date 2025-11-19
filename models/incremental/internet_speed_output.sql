{{
    config(
        materialized='incremental',
        unique_key='Timestamp'
    )
}}

with internet_speed_output as (
    select
    ROUND(Download, 2) as Download_Mb
    , ROUND(Upload, 2) as Upload_Mb
    , ROUND(Ping, 2) as Ping
    , DATE_TRUNC('second', Timestamp) as Timestamp
    , ROUND(Received, 2) as Mb_Received
    , ROUND(Sent, 2) as Mb_Sent
FROM {{ ref('parsed_internet_speed_testing') }}
)

select *
from internet_speed_output

{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where Timestamp > (select max(Timestamp) from {{ this }}) 
{% endif %}