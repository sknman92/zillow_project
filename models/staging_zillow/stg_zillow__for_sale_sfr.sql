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
        'sfr_homes' as property_type -- adding property type for clarity
    from {{ source('zillow', 'zillow_for_sale_sfr') }}
)

select *
from source
