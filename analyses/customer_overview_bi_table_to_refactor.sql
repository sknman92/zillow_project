with customer_enriched as (
    select 
        c.c_custkey,
        c.c_name,
        c.c_nationkey,
        n.n_name as nation_name,
        r.r_name as region_name,
        c.c_mktsegment,
        l.first_order_date,
        l.last_order_date
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER c
     join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
        on c.c_nationkey = n.n_nationkey
     join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
        on n.n_regionkey = r.r_regionkey
   left join (select 
        o.o_custkey,
        min(o.o_orderdate) as first_order_date,
        max(o.o_orderdate) as last_order_date
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
    group by o.o_custkey) l on c.c_custkey = l.o_custkey 
    
),
customer_order_summary as (
    select
        o.o_custkey,
        count(distinct o.o_orderkey) as total_orders,
        count(distinct case when l.l_returnflag = 'N' then o.o_orderkey end) as non_returned_orders,
        sum(case when l.l_returnflag = 'N' then l.l_extendedprice * (1 - l.l_discount) else 0 end) as total_revenue,
        avg(case when l.l_returnflag = 'N' then l.l_extendedprice * (1 - l.l_discount) else null end) as avg_non_returned_order_value,
        array_agg(distinct o.o_orderkey) as order_keys,
        MAX(n.avg_last3_revenue) as avg_last3_revenue
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
    join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
        on o.o_orderkey = l.l_orderkey
    left join 
    (-- find average revenue from 3 most recent orders
        WITH ranked AS (
  SELECT 
    o.o_custkey,
    l.l_extendedprice * (1 - l.l_discount) AS revenue,
    RANK() OVER (PARTITION BY o.o_custkey ORDER BY o.o_orderdate DESC) AS rnk
  FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS o
  JOIN SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM l
    ON o.o_orderkey = l.l_orderkey
  WHERE l.l_returnflag = 'N'
)
SELECT 
  o_custkey,
  AVG(CASE WHEN rnk <= 3 THEN revenue ELSE NULL END) AS avg_last3_revenue
FROM ranked
GROUP BY o_custkey) n on o.o_custkey = n.o_custkey 
    group by o.o_custkey
),

customer_overview as(
select
e.c_custkey as custkey
, e.c_name as custname
, e.nation_name
, e.region_name
, e.c_mktsegment as mktsegment
, e.first_order_date
, e.last_order_date
, coalesce(s.total_orders,0) as total_orders
, coalesce(s.non_returned_orders,0) as non_returned_orders
, coalesce(s.total_revenue,0) as total_revenue
, s.avg_non_returned_order_value
, s.order_keys
, s.avg_last3_revenue
, reference_date
from customer_enriched e
left join customer_order_summary s on e.c_custkey = s.o_custkey
Cross join
(--as data is out of date, find a reference date instead of today
    select max(o_orderdate) as reference_date
    from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS)
)
select  
custkey
,custname
, region_name
, nation_name
, mktsegment
, first_order_date
, last_order_date
, datediff(day, last_order_date, reference_date) as days_since_last_order
, total_orders
, non_returned_orders
, case when total_orders = 0 then 0 else (1 - (non_returned_orders/total_orders))*100 end as return_rate
, total_revenue
, avg_non_returned_order_value
, avg_last3_revenue
, -- if recent revenue is within 10% of avg then flat, else up or down 
case when (avg_last3_revenue / avg_non_returned_order_value) > 1.1 then 'up'
when (avg_last3_revenue / avg_non_returned_order_value) < 0.90 then 'down'
else 'flat' end as revenue_trend
, COALESCE(datediff(day, first_order_date, last_order_date),0) as customer_tenure_days
, coalesce(datediff(day, last_order_date, reference_date)<=90, FALSE) as is_active
, PERCENT_RANK() OVER (ORDER BY total_revenue desc) <= 0.2 as is_high_value
, --churn risk if not active and revenue trending down 
COALESCE(datediff(day, last_order_date, reference_date)>90 and avg_last3_revenue < avg_non_returned_order_value,TRUE) as is_churn_risk
from customer_overview
order by custkey asc
;