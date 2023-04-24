{{
  config(
    materialized='table'
  )
}}

select  
   users.user_id,
   concat(users.first_name,' ',users.last_name) as name,
   users.email,
   users.phone_number,
   users.created_at,
   users.updated_at,
   address.address,
   address.zipcode,
   address.state,
   address.country 

from {{ ref('stg_users') }} as users
left join {{ ref('stg_addresses') }} as address
on users.address_id = address.address_id