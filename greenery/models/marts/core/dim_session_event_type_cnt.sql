{{
  config(
    materialized='table'
  )
}}


select session_id,
       {{ event_type_cnt() }}
from {{ ref('stg_events') }}
group by 1
