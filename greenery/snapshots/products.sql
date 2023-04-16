{% snapshot products_snapshot %}

{{
    config(
      target_database='DEV_DB',
      target_schema='DBT_JAYANTSINGGMAILCOM',
      unique_key='product_id',

      strategy='check',
      check_cols=['inventory'],
    )
}}

select * from {{ source('postgres', 'products') }}

{% endsnapshot %}