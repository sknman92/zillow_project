{{ config(materialized='view') }}

with source as (
    select
        regionid,
        sizerank,
        regionname,
        regiontype,
        statename,
        date,
        forsaleinventory,
        'all_homes' as property_type -- adding property type for clarity
    from {{ source('zillow', 'zillow_for_sale_all_homes') }}
)

select *
from source
