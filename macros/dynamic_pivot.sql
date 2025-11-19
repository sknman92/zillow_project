{% macro dynamic_pivot(our_model, groupby, header_col, value_col, aggregation='SUM') %}
-- depends on : {{ref(our_model)}}

    {% if execute %}
        
    {%call statement('result', fetch_result=true)%}

    select {{header_col}} from {{ref(our_model)}} group by 1

    {% endcall %}

    {% set values=load_result('result').table.columns[0].values() %}

    select

    {% if groupby!= '' %}
    {{groupby}},    
    {% endif %}

    {% for val in header_col %}
      {{aggregation}}(case when {{header_col}} = '{{val}}' then {{value_col}} else 0 end) as "{{val|replace(' ', '_')}}_{{value_col}}"
      {% if not loop.last %}
        ,
      {% endif %}
    {% endfor %}

    from {{our_model}}

    {% if groupby != '' %}
        groupby {{groupby}}    
    {% endif %}
    
   {% endif %}

{% endmacro %}