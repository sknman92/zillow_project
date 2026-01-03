-- for calculating PoP metrics

with unioned_model as (
    select *
    from {{ ref('int_zillow__for_sale_unioned') }}
),

-- monthly PoP
monthly_PoP as (
    {{ PoP_template(
        table = 'unioned_model',
        metric_col = 'forsaleinventory',
        frequency = 'month',
        partition = ['cityname', 'statename', 'property_type']
    ) }}
),

-- quarterly PoP
quarterly_PoP as (
    {{ PoP_template(
        table = 'unioned_model',
        metric_col = 'forsaleinventory',
        frequency = 'quarter',
        partition = ['cityname', 'statename', 'property_type']
    ) }}
),

-- yearly PoP
yearly_PoP as (
    {{ PoP_template(
        table = 'unioned_model',
        metric_col = 'forsaleinventory',
        frequency = 'year',
        partition = ['cityname', 'statename', 'property_type']
    ) }}
),

unioned_frequncy_PoP as (
    select *
    from monthly_PoP
    union all
    select *
    from quarterly_PoP
    union all
    select *
    from yearly_PoP
)

select *
from unioned_frequncy_PoP
where frequency = 'year'

