# dm_meta() data model

    Code
      dm_meta(my_test_src()) %>% dm_paste(options = c("select", "keys", "color"))
    Message
      dm::dm(
        schemata,
        tables,
        columns,
        table_constraints,
        key_column_usage,
        constraint_column_usage,
      ) %>%
        dm::dm_select(schemata, catalog_name, schema_name) %>%
        dm::dm_select(tables, table_catalog, table_schema, table_name, table_type) %>%
        dm::dm_select(columns, table_catalog, table_schema, table_name, column_name, ordinal_position, column_default, is_nullable) %>%
        dm::dm_select(table_constraints, constraint_catalog, constraint_schema, constraint_name, table_catalog, table_schema, table_name, constraint_type) %>%
        dm::dm_select(key_column_usage, constraint_catalog, constraint_schema, constraint_name, table_catalog, table_schema, table_name, column_name, ordinal_position) %>%
        dm::dm_select(constraint_column_usage, table_catalog, table_schema, table_name, column_name, constraint_catalog, constraint_schema, constraint_name, ordinal_position) %>%
        dm::dm_add_pk(schemata, c(catalog_name, schema_name)) %>%
        dm::dm_add_pk(tables, c(table_catalog, table_schema, table_name)) %>%
        dm::dm_add_pk(columns, c(table_catalog, table_schema, table_name, column_name)) %>%
        dm::dm_add_pk(table_constraints, c(constraint_catalog, constraint_schema, constraint_name)) %>%
        dm::dm_add_pk(key_column_usage, c(constraint_catalog, constraint_schema, constraint_name, ordinal_position)) %>%
        dm::dm_add_pk(constraint_column_usage, c(constraint_catalog, constraint_schema, constraint_name, ordinal_position)) %>%
        dm::dm_add_fk(tables, c(table_catalog, table_schema), schemata) %>%
        dm::dm_add_fk(columns, c(table_catalog, table_schema, table_name), tables) %>%
        dm::dm_add_fk(table_constraints, c(table_catalog, table_schema, table_name), tables) %>%
        dm::dm_add_fk(key_column_usage, c(table_catalog, table_schema, table_name, column_name), columns) %>%
        dm::dm_add_fk(constraint_column_usage, c(table_catalog, table_schema, table_name, column_name), columns) %>%
        dm::dm_add_fk(key_column_usage, c(constraint_catalog, constraint_schema, constraint_name), table_constraints) %>%
        dm::dm_add_fk(constraint_column_usage, c(constraint_catalog, constraint_schema, constraint_name), table_constraints) %>%
        dm::dm_add_fk(constraint_column_usage, c(constraint_catalog, constraint_schema, constraint_name, ordinal_position), key_column_usage) %>%
        dm::dm_set_colors(`#0000FFFF` = schemata) %>%
        dm::dm_set_colors(`#A52A2AFF` = tables) %>%
        dm::dm_set_colors(`#A52A2AFF` = columns) %>%
        dm::dm_set_colors(`#008B00FF` = table_constraints) %>%
        dm::dm_set_colors(`#FFA500FF` = key_column_usage) %>%
        dm::dm_set_colors(`#FFA500FF` = constraint_column_usage)

