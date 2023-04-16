For project 1, we retrieve following data from newly created tables.

Question 1. How many users do we have?

Response: There are 130 users

sql: select count(user_id)
       from stg_users;

Question 2. On average, how many orders do we receive per hour?

Response: Approximately 15 orders are placed in a hour.

sql:  with order_cnt as  (
select 
date_part('hour', created_at) as created_hr,
count(order_id) as order_cnt
from stg_orders
group by 1
order by 1)

select avg(order_cnt)
from order_cnt;



Question 3. On average, how long does an order take from being placed to being delivered?

Response: It takes on an average 93 hours for delivery of an order

sql: select 
   avg(time_delay)
from(
select order_id,
       created_at,
       delivered_at,
       datediff('hour', created_at, delivered_at) as time_delay
from stg_orders
where status='delivered') temp;

Question 4. How many users have only made one purchase? Two purchases? Three+ purchases?

Response: 25 users made single purchase, 28 users made two purchases. And 71 users made 3+ purchases.

sql: with cte1 as
(select user_id,
       count(order_id) as order_cnt,
       case when order_cnt = 1 then 'One'
            when order_cnt = 2 then 'Two'
            else 'Three+' end as order_bucket
from stg_orders
group by 1)

select order_bucket,
       count(user_id) as user_cnt
from cte1
group by 1;

Question 5. On average, how many unique sessions do we have per hour?

Response: 39 sessions per hour.


sql: with hr_session_cnt as 
(select date_part('hour', created_at) as created_hr,
       count(distinct session_id) as session_cnt
from stg_events
group by 1)

select avg(session_cnt)
from hr_session_cnt;