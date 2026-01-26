{% macro generate_int_model(upstream_model, where_filter=None, case_condition=None, leading_commas=False, case_sensitive_cols=False, materialized=None) %}

{%- set upstream_relation = ref(upstream_model) -%}

{%- set columns = adapter.get_columns_in_relation(upstream_relation) -%}
{% set column_names=columns | map(attribute='name') %}

{%- if materialized is not none -%}
{{ config(materialized=materialized) }}

{%- endif -%}
with upstream as (

    select * from {{ upstream_relation }}
)

select
    {%- if leading_commas %}
    {%- for column in column_names %}
    {{ ", " if not loop.first }}{% if not case_sensitive_cols %}{{ column | lower }}{% else %}{{ adapter.quote(column) }}{% endif %}
    {%- endfor %}
    {%- else %}
    {%- for column in column_names %}
    {% if not case_sensitive_cols %}{{ column | lower }}{% else %}{{ adapter.quote(column) }}{% endif %}{{ "," if not loop.last }}
    {%- endfor %}
    {%- endif %}
    {% if case_condition %}
        , {{caseCondition_constructor(case_condition)}}
    {% endif %}
from upstream
{%- if where_filter %}
    where {{ whereFilter_constructor(where_filter) }}
{%- endif %}

{% endmacro %}