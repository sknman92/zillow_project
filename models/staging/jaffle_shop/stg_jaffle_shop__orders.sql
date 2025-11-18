with source as (

    select * from {{ source('jaffle_shop', 'orders') }}

),

renamed as (

    select
        id as order_id
        , user_id as customer_id
        , order_date
        , status
        , row_number() over (partition by customer_id order by order_date, order_id) as user_order_seq
        , status NOT IN ('returned','return_pending') as is_not_returned
        --, _etl_loaded_at

    from source

    where status NOT IN ('pending')
    
)

select * 
from renamed
order by customer_id, user_order_seq
