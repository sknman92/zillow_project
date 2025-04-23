with source as (

    select * from {{ source('mailchimp', 'unsubscribes') }}

),

renamed as (

    select
        "_airbyte_raw_id" AS _airbyte_raw_id,
        "_airbyte_extracted_at" AS _airbyte_extracted_at,
        "_airbyte_generation_id" AS _airbyte_generation_id,
        "_airbyte_meta" AS _airbyte_meta,
        "vip" AS vip,
        "reason" AS reason,
        "list_id" AS list_id,
        "email_id" AS email_id,
        "timestamp" AS timestamp,
        "campaign_id" AS campaign_id,
        "merge_fields" AS merge_fields,
        "email_address" AS email_address,
        "list_is_active" AS list_is_active

    from source

)

select * from renamed