{% macro caseCondition_constructor(view_name) %}

{% set seed_filter %}

select * from {{ ref('case_config') }}
where view_name = '{{ view_name }}'

{% endset %}

{% if execute %}

  {{ log('caseCondition_constructor query:\n' ~ seed_filter, info=True) }}

  {% set tbl = run_query(seed_filter) %} {# returning filtered case_config #}
  {% if tbl is none %}
    {{ exceptions.raise_compiler_error('run_query returned None; is the seed built?') }}
  {% endif %}

  {% set rows = tbl.rows %}
    {% set rows_log = [] %}
    {% for r in rows %}
      {% do rows_log.append(r|string) %}
    {% endfor %}
    {{ log('rows: ' ~ (rows_log | tojson), info=True) }}

{# returning case fields #}
{% set case_fields = dbt_utils.get_column_values(table=ref('case_config'), column='field') %}

{{ log('case fields: ' ~ case_fields, info=True) }}

{# building case statements for each field #}

{# collecting case statements for each field #}
{% set case_conditions =  [] %}

{% for case_field in case_fields %}
    
    {# collecting individual case statements for each field #}
    {% set statements = [] %}

    {% for row in rows %}
        {% if row[1] == case_field %} {# filtering rows to current field #}
        {% set field  = row[1] %} {# case field #}
          {{ log('row: ' ~ (row | string), info=True) }}
        {% set condition = row[2] %} {# case condition #}
        {% set value = row[3] %} {# case result #}
            {% if field and value %}
                {# check if `condition` contains any digit (portable; avoid regex) #}
                {% set ns = namespace(has_digit=false) %}
                {% for ch in condition %}
                  {% if ch in '0123456789' %}
                    {% set ns.has_digit = true %}
                    {% break %}
                  {% endif %}
                {% endfor %}
                {% if ns.has_digit %}
                  {% do statements.append("WHEN " ~ field ~ " " ~ condition ~ " THEN " ~ "'" ~ value ~ "'") %}
                {% else %}
                  {% do statements.append("WHEN " ~ field ~ " = '" ~ condition ~ "' THEN " ~ "'" ~ value ~ "'") %}
                {% endif %}
            {% endif %}
        {% endif %}
    {% endfor %}

    {{ log ('case statements: ' ~ statements, info=True)}}

    {# building full case condition for the field #}
    {% set case_statement = 'CASE ' ~ (statements | join(' ')) ~ ' END as "' ~ case_field ~ '"' %}
    {{ log('case_statement: ' ~ case_statement, info=True)}}

    {# appending case statement to case_conditions #}
    {% do case_conditions.append(case_statement) %}
{% endfor %}
{{ log ('case_conditions: ' ~ case_conditions, info=True) }}

{# need to concat case_conditions #}
{%set to_ret = case_conditions | join(', ') %}
{{ log('to_ret: ' ~ to_ret, info=True) }}
{{return(to_ret)}}

{% else %}
  {{ log('Not executing caseCondition_constructor macro', info=True) }}
    {{ return(None) }}
{% endif %}


{% endmacro %}