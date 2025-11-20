{{ codegen.generate_base_model(
    source_name='time',
    table_name='internet_speed_test'
) }}



{{ codegen.generate_model_yaml(
    model_names=['stg_amp__base_level']
) }}