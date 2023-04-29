{{
  config(
    materialized='table'
  )
}}

{% set event_types = ["page_view", "add_to_cart"] %}


with view_cart_cte as (

select product_name,
       {% for event_type in event_types %}
  count( distinct case when event_type = '{{ event_type }}' then session_id else null end) as {{ event_type }}_cnt
  {% if not loop.last %},{% endif %}
  {% endfor %}
from {{ ref('stg_events') }} as events
join {{ ref('dim_products') }} as prod
on events.product_id = prod.product_id
group by 1
),

checkout_cte as(

  select product_name,
       count(distinct session_id) as purchase_session_cnt
from {{ ref('stg_events') }} as events
join {{ ref('int_order_details') }} as orders
on events.order_id = orders.order_id
where event_type = 'checkout'
group by 1
)

select view_cart_cte.product_name,
       view_cart_cte.page_view_cnt,
       view_cart_cte.add_to_cart_cnt,
       checkout_cte.purchase_session_cnt

from view_cart_cte
left join checkout_cte
on view_cart_cte.product_name = checkout_cte.product_name
