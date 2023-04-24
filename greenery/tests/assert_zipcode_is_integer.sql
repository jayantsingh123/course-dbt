-- return records where zipcode is not integer
select *
from {{ ref('stg_addresses' ) }}
where not(is_integer(zipcode))