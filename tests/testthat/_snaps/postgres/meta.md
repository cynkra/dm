# dm_meta() contents

    Code
      meta %>% dm_get_tables() %>% map(arrange_all) %>% map(collect) %>% jsonlite::toJSON(
        pretty = TRUE) %>% gsub(schema_name, "schema_name", .) %>% gsub(
        "(_catalog\": \")[^\"]*(\")", "\\1catalog\\2", .) %>% writeLines()
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
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "table_type": "BASE TABLE"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "table_type": "BASE TABLE"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "table_type": "BASE TABLE"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "table_type": "BASE TABLE"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "table_type": "BASE TABLE"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "table_type": "BASE TABLE"
          }
        ],
        "columns": [
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "a",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "b",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "c",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "d",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e1",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "ordinal_position": 2,
            "is_nullable": "NO"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "g",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "h",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "i",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j1",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "k",
            "ordinal_position": 2,
            "is_nullable": "NO"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "l",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "m",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "ww",
            "ordinal_position": 1,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "n",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "o",
            "ordinal_position": 3,
            "is_nullable": "NO"
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "zz",
            "ordinal_position": 1,
            "is_nullable": "YES"
          }
        ],
        "table_constraints": [
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "222531_222734_1_not_null",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "constraint_type": "CHECK"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "222531_222741_1_not_null",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "constraint_type": "CHECK"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "222531_222741_2_not_null",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "constraint_type": "CHECK"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "222531_222748_3_not_null",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "constraint_type": "CHECK"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "222531_222757_1_not_null",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "CHECK"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "222531_222774_1_not_null",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "constraint_type": "CHECK"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "222531_222786_2_not_null",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "CHECK"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_1_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_d_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_e_e1_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_3_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_4_j_j1_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_4_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_l_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_m_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_6_n_key",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "constraint_type": "UNIQUE"
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_6_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "constraint_type": "PRIMARY KEY"
          }
        ],
        "key_column_usage": [
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_1_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "a",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_d_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "d",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_e_e1_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_e_e1_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "e1",
            "ordinal_position": 2
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_2",
            "column_name": "c",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_3_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_3_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "ordinal_position": 2
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_4_j_j1_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_4_j_j1_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "j1",
            "ordinal_position": 2
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_4_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "h",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_l_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "l",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_m_fkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "m",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_5",
            "column_name": "k",
            "ordinal_position": 1
          },
          {
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_6_pkey",
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "o",
            "ordinal_position": 1
          }
        ],
        "constraint_column_usage": [
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_1",
            "column_name": "a",
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_d_fkey",
            "ordinal_position": 1
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_e_e1_fkey",
            "ordinal_position": 1
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f",
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_4_j_j1_fkey",
            "ordinal_position": 1
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_2_e_e1_fkey",
            "ordinal_position": 2
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_3",
            "column_name": "f1",
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_4_j_j1_fkey",
            "ordinal_position": 2
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_4",
            "column_name": "h",
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_l_fkey",
            "ordinal_position": 1
          },
          {
            "table_catalog": "catalog",
            "table_schema": "schema_name",
            "table_name": "tf_6",
            "column_name": "n",
            "constraint_catalog": "catalog",
            "constraint_schema": "schema_name",
            "constraint_name": "tf_5_m_fkey",
            "ordinal_position": 1
          }
        ]
      }

