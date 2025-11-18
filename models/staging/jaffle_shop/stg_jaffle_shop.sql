select *
from {{ source('jaffle_shop', 'object_name') }}