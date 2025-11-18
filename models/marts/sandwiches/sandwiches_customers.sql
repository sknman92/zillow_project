with stg_jaffle_shop__customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}
  
),

stg_jaffle_shop__orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}
  
),

stg_stripe__successful_payments as (

    select * from {{ ref('stg_stripe__successful_payments') }}
  
), 

sandwiches_customers as (
    select 
        b.customer_id as customer_id,
        b.name as full_name,
        b.last_name as surname,
        b.first_name as givenname,
        min(order_date) as first_order_date,
        min(case when a.is_not_returned then order_date end) as first_non_returned_order_date,
        max(case when a.is_not_returned then order_date end) as most_recent_non_returned_order_date,
        COALESCE(max(user_order_seq),0) as order_count,
        COALESCE(count(case when a.status != 'returned' then 1 end),0) as non_returned_order_count,
        sum(case when a.is_not_returned then c.amount else 0 end) as total_lifetime_value,
        sum(case when a.is_not_returned then c.amount else 0 end)/NULLIF(count(case when a.is_not_returned then 1 end),0) as avg_non_returned_order_value,
        array_agg(distinct a.order_id) as order_ids
    from stg_jaffle_shop__customers as b

    inner join stg_jaffle_shop__orders as a
        on b.customer_id = a.customer_id

    left outer join stg_stripe__successful_payments as c
        on a.order_id = c.order_id

    group by 1,2,3,4
    )

select *
from sandwiches_customers