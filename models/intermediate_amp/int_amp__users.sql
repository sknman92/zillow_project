{{
    config(
        materialized='incremental',
        unique_key='amplitude_id',
        incremental_strategy = 'delete+insert'
    )
}}

with user_base as (

    SELECT DISTINCT amplitude_id
        , user_id
        , SPLIT_PART(SPLIT_PART(user_id, '@', 2), '.', 1) AS company
    FROM {{ ref('stg_amp__base_level') }}
    WHERE user_id IS NOT NULL
)

select *
from user_base