{{
    config(
        materialized='incremental',
        unique_key='ip_address',
        incremental_strategy = 'delete+insert'
    )
}}

with location_base as (
    SELECT
        distinct
        location_sk_id,
        ip_address,
        city,
        country,
        region
    FROM {{ ref('stg_amp__base_level') }}
    where ip_address is not null
    
)

select *
from location_base