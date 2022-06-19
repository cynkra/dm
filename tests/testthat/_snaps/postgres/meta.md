# dm_meta() contents

    Code
      meta %>% dm_get_tables() %>% map(select, -any_of("constraint_name"), -contains(
        "catalog")) %>% map(arrange_all) %>% map(collect) %>% jsonlite::toJSON(
        pretty = TRUE) %>% gsub(schema_name, "schema_name", .) %>% gsub(
        "(_catalog\": \")[^\"]*(\")", "\\1catalog\\2", .) %>% writeLines()
    Output
      {
        "schemata": [
          {
            "schema_name": "schema_name"
          }
        ],
        "tables": [
          {
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "table_type": "BASE TABLE"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "table_type": "BASE TABLE"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "table_type": "BASE TABLE"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "table_type": "BASE TABLE"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "table_type": "BASE TABLE"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "table_type": "BASE TABLE"
          }
        ],
        "columns": [
          {
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "a",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "b",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "c",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "d",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e1",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "ordinal_position": 2,
            "is_nullable": "NO"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "g",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "h",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "i",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j1",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "k",
            "ordinal_position": 2,
            "is_nullable": "NO"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "l",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "m",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "ww",
            "ordinal_position": 1,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "n",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "o",
            "ordinal_position": 3,
            "is_nullable": "NO"
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "zz",
            "ordinal_position": 1,
            "is_nullable": "YES"
          }
        ],
        "table_constraints": [
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "constraint_type": "CHECK"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "CHECK"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "constraint_type": "CHECK"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "constraint_type": "CHECK"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "constraint_type": "CHECK"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "CHECK"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "constraint_type": "CHECK"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "constraint_type": "UNIQUE"
          }
        ],
        "key_column_usage": [
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "a",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "c",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "d",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e1",
            "ordinal_position": 2
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "ordinal_position": 2
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "h",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j1",
            "ordinal_position": 2
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "k",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "l",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "m",
            "ordinal_position": 1
          },
          {
            "constraint_schema": "schema_name",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "o",
            "ordinal_position": 1
          }
        ],
        "constraint_column_usage": [
          {
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "a",
            "constraint_schema": "schema_name",
            "ordinal_position": 1
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "constraint_schema": "schema_name",
            "ordinal_position": 1
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "constraint_schema": "schema_name",
            "ordinal_position": 1
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "constraint_schema": "schema_name",
            "ordinal_position": 2
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "constraint_schema": "schema_name",
            "ordinal_position": 2
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "h",
            "constraint_schema": "schema_name",
            "ordinal_position": 1
          },
          {
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "n",
            "constraint_schema": "schema_name",
            "ordinal_position": 1
          }
        ]
      }

