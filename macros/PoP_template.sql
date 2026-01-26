{% macro PoP_template(table, metric_col, frequency, partition) -%}

with current_previous_values as (
    select 
        date_trunc('{{ frequency }}', date) as period,
        {{ partition | join(', ') }},
        sum({{ metric_col }}) as current_value,
        lag(sum({{ metric_col }} )) over (partition by {{ partition | join(', ') }} order by date_trunc('{{ frequency }}', date)) as previous_value
    from {{ table }}
    group by 1, {{ partition | join(', ') }}
)

select 
    *,
    (current_value - previous_value) as value_change,
    round(((current_value - previous_value) / previous_value) * 100, 2) as perc_change,
    '{{ frequency }}' as frequency
from current_previous_values

{%- endmacro %}