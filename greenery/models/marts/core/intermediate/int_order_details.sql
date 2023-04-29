 {{
 config(
    materialized='table'
  )
}}

select 
   orders.order_id,
   orders.created_at,
   orders.order_cost,
   orders.shipping_cost,
   orders.order_total,
   orders.tracking_id,
   orders.shipping_service,
   orders.estimated_delivery_at,
   datediff('days', orders.created_at, orders.delivered_at) as delivery_period,
   items.quantity,
   products.product_name

from {{ ref('stg_orders') }} as orders
left join {{ ref('stg_order_items') }} as items
on orders.order_id = items.order_id
left join {{ ref('dim_products') }} as products
on items.product_id = products.product_id


