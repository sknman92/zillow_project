{% macro whereFilter_constructor(view_name) %}

{% set seed_filter %}

select * from {{ ref('where_config') }}
where view_name = '{{ view_name }}'

{% endset %}

{%- if execute -%}

{%- set result = run_query(seed_filter) -%}

    {%- set where_filters = [] -%}
    
    {# iterating through rows and build where conditions #}
    {%- for row in result.rows -%}
        {%- set field = row[1] -%}
        {%- set value = row[2] -%}
        {%- if field and value -%}
            {%- do where_filters.append(field ~ " = '" ~ value ~ "'") -%}
        {%- endif -%}
    {%- endfor -%}
    
    {%- set where_clause = where_filters | join(' AND ') -%}
    {{ log('where_clause: ' ~ where_clause, info=True) }}
    {{ return(where_clause) }}
{%- else -%}
    {{ return('') }}
{%- endif -%}

{% endmacro %}