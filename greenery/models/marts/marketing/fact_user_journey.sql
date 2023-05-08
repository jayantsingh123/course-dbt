
{{
  config(
    materialized='table'
  )
}}

{% set last_activities = [
  'checkout', 'add_to_cart', 'page_view'
]
%}

{% set dict_activity = {'checkout':'order_complete',
 'add_to_cart':'abandon_cart', 'page_view':'abandon_browse'}

%}

-- in this model, we'll define for a given session, what did the user do in this session.
-- in other words, how was the user journey on the website


with aggregate_data as(

select user_id,
       session_id,
       event_type,
       created_at,
       max(created_at) over(partition by user_id, session_id) as last_event_time,
       min(created_at) over(partition by user_id, session_id) as first_event_time 
from {{ ref('stg_events') }}
where event_type in ('page_view', 'checkout', 'add_to_cart')
),

first_activity_cte as(

select user_id,
       session_id,
       first_event_time,
       event_type as first_activity
from aggregate_data
where created_at = first_event_time),

last_activity_cte as(

select user_id,
       session_id,
       last_event_time,
       event_type as last_activity
from aggregate_data
where created_at = last_event_time)

-- next add a session description column defining what happened
-- in this session, did the purchase happen or not.

select first.user_id,
       first.session_id,
       user.state,
       first.first_activity,
       first.first_event_time,
       last.last_activity,
       last.last_event_time,
       {% for event_type in last_activities %}
       case when event_type = '{{ event_type }}' then dict_activity['{{event_type}}']
       else 'Other' end as session_description
       {% endfor %}
     
       
from first_activity_cte  as first
join last_activity_cte as last
on first.user_id = last.user_id
and first.session_id = last.session_id
join {{ ref('dim_users') }} as user
on first.user_id = user.user_id
order by 1