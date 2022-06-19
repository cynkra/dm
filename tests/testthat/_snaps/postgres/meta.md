# dm_meta() contents

    Code
      meta %>% dm_get_tables() %>% map(arrange_all) %>% map(collect) %>% jsonlite::toJSON(
        pretty = TRUE) %>% gsub(schema_name, "schema_name", .) %>% gsub(
        "(_catalog\": \").*(\")", "\\1catalog\\2", .) %>% writeLines()
    Output
      {
        "schemata": [
          {
            "catalog_name": "kirill",
            "schema_name": "schema_name"
          }
        ],
        "tables": [
          {
            "table_catalog": "catalog": 1
          }
        ]
      }

