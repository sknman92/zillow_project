{% set query %}

    select listagg(distinct method, ', ') as all_methods
    from {{ ref('stg_stripe__payments') }}

{% endset %}

{% if execute %}
{% set payment_method=run_query(query).columns[0].values() %}

{{payment_method}}

{%endif%}