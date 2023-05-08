1. dbt snapshots.

  - Which products have inventory change from week 3 to week 4?

  Response: We can obtain the products whose inventory changed most recently using following query.

      select name
       from products_snapshot as table1
        where dbt_valid_to is null
             and dbt_valid_from = (select max(dbt_valid_to)
                        from products_snapshot);


  The products whose inventory change include, 

      - Philodendron,

      - Pothos, 

      - Bamboo, 

      - Monstera, 

      - String of pearls, and

      - ZZ plant.

  - Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory? Did we have any items go out of stock in the last 3 weeks? 

  Response: We can identify products with zero inventory using following query.

      select name
      from products_snapshot
      where inventory=0

   The products include Pothos, and String of Pearls.

   Next, in order to identify the poduct with most fluctuations, we found that the product String of Perals shows wldest fluctustions on a weekly basis with value of around 23 units. This can be answered using following query;



    with raw_data as(
          select name,
                  inventory,
                case when date(dbt_updated_at) = date('2023-04-15') then 'week1'
                     when date(dbt_updated_at) = date('2023-04-22') then 'week2'
                     when date(dbt_updated_at) = date('2023-04-29') then 'week3'
                     when date(dbt_updated_at) = date('2023-05-05') then 'week4'
                     end as week_number
    from products_snapshot)



     ,pivot_data as(

        select *
         from raw_data
          pivot(max(inventory)
                for week_number in ('week1', 'week2', 'week3', 'week4'))
                 as p (product_name, week1, week2, week3, week4))

        /* replace null values by previous weeks value, i.e. inventory hasn't changecd */

     , backfill as (

       select product_name,
              week1,
               coalesce(week2, week1) as week2,
               coalesce(week3, week2, week1) as week3,
                coalesce(week4, week3, week2, week1) as week4
       
         from pivot_data)

        /* get weekly changes */

       , weekly_change as(

          select backfill.product_name,
                 abs(week2-week1) as first_second_week,
                 abs(week3-week2) as second_third_week,
                 abs(week4-week3) as third_fourth_week
       

            from backfill
            )

       , unpivot_data as(
          select * 
             from weekly_change
              unpivot(change for time_interval in (first_second_week, second_third_week, third_fourth_week)))

        select *
           from (select product_name,
             avg(change) as weekly_avg_change
             from unpivot_data
              group by 1) temp
       order by 2 desc
       limit 1;


2. Modeling challenges.

 - How are our users moving through the product funnel?

 Response: In order to answer this quesion, we have defined a model, called `fact_user_journey` in `marts/marketing`. We have filtered the activity to following values, `page_view`, `add_to_cart`, and `checkout`. Using this model, we can find information like;

  - How often the sessions are ending in abandon cart?

  - How often sessions are ending in abandon search?

  - How often sessions are ending in purchase order?

  For example, we can find percent of sessions with abandon browse at granularity of user location. Here is the query;

      select state,
             count(session_id) as session_cnt,
             sum(case when session_description = 'abandon_browse' then 1 else 0 end) as abandon_browse_session_cnt,
             round(div0(abandon_browse_session_cnt, session_cnt),2) as abandon_browse_pct
      from products_snapshot
      group by 1;

 - Which steps in the funnel have largest drop off points?

 Response: We can compute conversion rate on a product level using the model, `fact_product_conversion_rate.sql`.

      select product_name,
             round(div0(purchase_session_cnt, page_view_cnt),2) as conversion_rate
      from fact_product_conversion_rate;

    In addition, an exposure file has been defined in the file `exposure.yml` in the `models` folder. It helps us to track user journey on the greenery ecommerce website.




3. Reflection questions.

   - if your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization? 
   
   Response: Not Applicable

   - if your organization is using dbt, what are 1-2 things you might do differently / recommend to your organization based on learning from this course?

     Response: Our organization is currently using dbt. An improvement will be to incorporate `exposure` feature, which can help users to track dependency of a dashboard/report on a model.

   - if you are thinking about moving to analytics engineering, what skills have you picked that give you the most confidence in pursuing this next step?

     Response: Following two steps will be helpful in transitioning; 

          - first knowledge of dbt fundamentals from this couse, and 

          - second refactoring dbt models.  

       