1. Create new models to answer the first two questions.
  - What is our overall conversion rate (defined as ratio of number of sessions with checkout to
       overall count of sessions)?
  Response: 

     select count(distinct session_id) as session_cnt,
       count(distinct case when event_type='checkout' then session_id end) as checkout_session_cnt,
       round((checkout_session_cnt / session_cnt)*100, 2) as conversion_rate 
      from stg_events;
    The overall conversion rate is 63 prcent, i.e. out of 100 sessions 63 og them resulted in order placed.

  - What is our conversion rate by product (defined as the # of unique sessions with a purchase event of that product divided by total number of unique sessions that viewed that product)?

  Response: 

     select product_name,
            round(div0(purchase_session_cnt, page_view_cnt) * 100, 2) as conversion_rate
     from fact_product_conversion_rate

    We have created a model, called `fact_product_conversion_rate` which has information regarding count of sessions for a given event type corresponding to a given product.

2. Use macros to simplify the code logic if possible.

  Response: For sure macros open a wide range of possibilities. For this assignment, we have defined a macro called  `event_type_cnt.sql` to count number of events of a given event type for a given session. Please note that this has been implemented using raw sql rather than using dbt packages functionality. Mostly aimed at learning how to define macros. Secondly a macro called `grant.sql` has been defined to provide reporting role access to entire project.

   In addition, a jinja has been defined in the model `fact_product_conversion_rate`, aimed at calculating count of sessions for a given product.

3. In order to grant permissions to reporting role, we have done following changes in `dbt_project.yml` file.
     models:
      greenery:
        # Config indicated by + and applies to all models. Here grabt is a macro defined
   
       +post-hook:
           - "{{ grant(role='reporting') }}" 


4. dbt-utils package has been installed. And the test `dbt_utils.unique_combination_of_columns` has been used to check uniqueness of combination of columns in the model `fact_page_views.sql`.

5. Screenshot for new DAG has been uploaded.
6. For snapshot, following products had inventory change from week 2 to week 3;
    - Pothos
    - Monstera
    - Philodendron
    - String of pearls