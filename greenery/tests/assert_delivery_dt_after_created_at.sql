-- Therefore return records where order is delivered but created_dt is later than delivery_dt
select *
from {{ ref('stg_orders' ) }}
where status='delivered'
and delivered_at < created_at
