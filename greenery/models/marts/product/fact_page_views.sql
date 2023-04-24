
{{
  config(
    materialized='table'
  )
}}


with page_view as (
select events.event_id,
       date(events.created_at) as created_at,
       'page_view' as event_type,
       products.product_name
    
from {{ ref('stg_events') }} as events
left join {{ ref('dim_products') }} as products
on events.product_id = products.product_id
where event_type= 'page_view'),

order_placed as (
select events.event_id,
       date(events.created_at) as created_at,
       'checkout' as event_type,
       orders.product_name


from {{ ref('stg_events') }} as events
left join {{ ref('fact_order_details') }} as orders
on events.order_id = orders.order_id
where event_type = 'checkout'
),

cte_union as (
select *
from page_view
union all 
select *
from order_placed)

select created_at,
       product_name,
       count(distinct case when event_type='page_view' then event_id end) as number_of_page_views,
       count(distinct case when event_type='checkout' then event_id end) as number_of_checkouts
       
from cte_union
group by 1,2
order by 1