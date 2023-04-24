Part 1. Models:

Question 1. What is user repeat rate? Here, User repeat rate is defined as percentage of users who made two or more orders.

Response: Almost 80 percent of user who made orders, are repeat users.

    sql:   with cte1 as (
             select user_id,
             count(order_id) as order_cnt
             from stg_orders
             group by 1
             having order_cnt >=2),

            -- get users who placed two or more orders
          cte2 as (

              select count(user_id) as two_more_orders
                from cte1),

          -- get total user count
          cte3 as (
            select count(distinct user_id) as user_cnt
                  from stg_orders
                )

      select cte2.two_more_orders,
             cte3.user_cnt,
             round(div0(two_more_orders, user_cnt) * 100,2) as repeat_rate
        from cte2 
        cross join cte3


Question 2. What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again?

Response: This is an open ended question, in my opinion. But given the data we have; we can look at the time elapsed between order creation and order delivered. It is common to see that users who get their orders delivered late are most likely not to purchase from the website again.
Another factor can be inclination of users to use discounts and promotions. Users who come to the website only because of discounts are more likely to make purchase elsewhere, if they're offered higher discounts on other websites.

Question 3. Create marts folder with suitable models.

Response: For product mart, we have created the fact table, fact_page_views.sql. It can help to answer following questions; how to the products compare in page views on a daily basis, as well as how do the products compare in terms of orders placed on daily basis.


     sql:     with page_view as (
 
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
          where event_type = 'checkout'),

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

Next, we also created the core marts with following models;  dim_products.sql, dim_users.sql, fact_order_details.sql.
These models have been placed in core so that they can be used in different marts for various purposes. 

Part 2: Tests

Question 1. Assumpations and tests regarding the models.

Response: We have tried to focus on some singular tests which  may help in assessing th correctness of the data. To this end we have implmented following singular tests:

  (a.) Order created date should be before order delivery date.

     sql: select *
             from {{ ref('stg_orders' ) }}
            where status='delivered'
            and delivered_at < created_at 

   (b.) Zipcode should be integer format

      sql: select *
             from {{ ref('stg_addresses' ) }}
              where not(is_integer(zipcode))
              
With the above tests implemented, we didn't find any data issues in the datasets.

Question 2: How do we plan to alert stakeholders of bad data quality?

Response: We can use slack notifications to update the stakeholders if any required test is failing. Some sort of aitomation, e.g. airlfow can be used as an orchestration toolt to run these tests regularly.


Part 3. dbt snapshots

Question 1 Which products had change in inventory from week 1 to week 2?

Respone: As per this dataset, following products had an inventory change from week 1 to week 2;

 - Pothos (change from 40 to 20)
 - Monstera (change from 77 to 64)
 - Philodenderon (change from 51 to 25)
 - String of pearls (change from 58 to 10)
