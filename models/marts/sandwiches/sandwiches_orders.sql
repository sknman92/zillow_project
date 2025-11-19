--depends_on {{ ref('tmp_orders_with_detail_to_refactor') }}

with sandwiches_customers as (

    select * from {{ ref('sandwiches_customers') }}
  
),

stg_jaffle_shop__orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}
  
),

stg_stripe__successful_payments as (

    select * from {{ ref('stg_stripe__successful_payments') }}
  
),

sandwiches_orders as (
    select 
        a.order_id,
        a.customer_id,
        b.surname,
        b.givenname,
        b.first_order_date,
        b.order_count,
        b.total_lifetime_value,
        c.amount as order_value_dollars,
        a.status as order_status,
        c.status as payment_status
    from stg_jaffle_shop__orders as a

    inner join sandwiches_customers as b 
        on a.customer_id = b.customer_id

    left outer join stg_stripe__successful_payments as c
        on a.order_id = c.order_id
)

select *
from sandwiches_orders