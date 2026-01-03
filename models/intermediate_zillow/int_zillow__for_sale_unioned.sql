with all_homes as (
    select *
    from {{ ref('stg_zillow__for_sale_all_homes') }}
),

sfr_homes as (
    select *
    from {{ ref('stg_zillow__for_sale_sfr')}}
),

unioned_homes as (
    select *
    from all_homes

    union all

    select *
    from sfr_homes
),

split_city as (
    select
        regionid,
        sizerank,
        regionname,
        regiontype,
            case 
                when contains(regionname, ',') then split_part(regionname, ',', 1)
                else null
            end as cityname,
        statename,
        date,
        forsaleinventory,
        property_type
    from unioned_homes
),

final_cte as (
    select *
    from split_city
)

select *
from final_cte