# dm_meta() contents

    Code
      meta %>% dm_select_tbl(-schemata) %>% dm_zoom_to(table_constraints) %>% filter(
        constraint_type %in% c("PRIMARY KEY", "FOREIGN KEY")) %>% dm_update_zoomed() %>%
        dm_get_tables() %>% map(select, -any_of("column_default"), -contains(
        "catalog"), -contains("schema")) %>% map(arrange_all_but_constraint_name) %>%
        map(collect) %>% map(~ if ("constraint_name" %in% colnames(.x)) {
        .x %>% mutate(constraint_name = as.integer(forcats::fct_inorder(
          constraint_name)))
      } else {
        .x
      }) %>% map(arrange_all) %>% jsonlite::toJSON(pretty = TRUE) %>% gsub(
        schema_name, "schema_name", .) %>% gsub("(_catalog\": \")[^\"]*(\")",
        "\\1catalog\\2", .) %>% writeLines()
    Output
      {
        "tables": [
          {
            "table_name": "tf_1",
            "table_type": "BASE TABLE"
          },
          {
            "table_name": "tf_2",
            "table_type": "BASE TABLE"
          },
          {
            "table_name": "tf_3",
            "table_type": "BASE TABLE"
          },
          {
            "table_name": "tf_4",
            "table_type": "BASE TABLE"
          },
          {
            "table_name": "tf_5",
            "table_type": "BASE TABLE"
          },
          {
            "table_name": "tf_6",
            "table_type": "BASE TABLE"
          }
        ],
        "columns": [
          {
            "table_name": "tf_1",
            "column_name": "a",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_name": "tf_1",
            "column_name": "b",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_2",
            "column_name": "c",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_name": "tf_2",
            "column_name": "d",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_2",
            "column_name": "e",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_2",
            "column_name": "e1",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_3",
            "column_name": "f",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_name": "tf_3",
            "column_name": "f1",
            "ordinal_position": 2,
            "is_nullable": "NO"
          },
          {
            "table_name": "tf_3",
            "column_name": "g",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_4",
            "column_name": "h",
            "ordinal_position": 1,
            "is_nullable": "NO"
          },
          {
            "table_name": "tf_4",
            "column_name": "i",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_4",
            "column_name": "j",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_4",
            "column_name": "j1",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_5",
            "column_name": "k",
            "ordinal_position": 2,
            "is_nullable": "NO"
          },
          {
            "table_name": "tf_5",
            "column_name": "l",
            "ordinal_position": 3,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_5",
            "column_name": "m",
            "ordinal_position": 4,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_5",
            "column_name": "ww",
            "ordinal_position": 1,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_6",
            "column_name": "n",
            "ordinal_position": 2,
            "is_nullable": "YES"
          },
          {
            "table_name": "tf_6",
            "column_name": "o",
            "ordinal_position": 3,
            "is_nullable": "NO"
          },
          {
            "table_name": "tf_6",
            "column_name": "zz",
            "ordinal_position": 1,
            "is_nullable": "YES"
          }
        ],
        "table_constraints": [
          {
            "constraint_name": 1,
            "table_name": "tf_1",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_name": 2,
            "table_name": "tf_2",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_name": 3,
            "table_name": "tf_2",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_name": 4,
            "table_name": "tf_2",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_name": 5,
            "table_name": "tf_3",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_name": 6,
            "table_name": "tf_4",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_name": 7,
            "table_name": "tf_4",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_name": 8,
            "table_name": "tf_5",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_name": 9,
            "table_name": "tf_5",
            "constraint_type": "FOREIGN KEY"
          },
          {
            "constraint_name": 10,
            "table_name": "tf_5",
            "constraint_type": "PRIMARY KEY"
          },
          {
            "constraint_name": 11,
            "table_name": "tf_6",
            "constraint_type": "PRIMARY KEY"
          }
        ],
        "key_column_usage": [
          {
            "constraint_name": 1,
            "table_name": "tf_1",
            "column_name": "a",
            "ordinal_position": 1
          },
          {
            "constraint_name": 2,
            "table_name": "tf_2",
            "column_name": "c",
            "ordinal_position": 1
          },
          {
            "constraint_name": 3,
            "table_name": "tf_2",
            "column_name": "d",
            "ordinal_position": 1
          },
          {
            "constraint_name": 4,
            "table_name": "tf_2",
            "column_name": "e",
            "ordinal_position": 1
          },
          {
            "constraint_name": 4,
            "table_name": "tf_2",
            "column_name": "e1",
            "ordinal_position": 2
          },
          {
            "constraint_name": 5,
            "table_name": "tf_3",
            "column_name": "f",
            "ordinal_position": 1
          },
          {
            "constraint_name": 5,
            "table_name": "tf_3",
            "column_name": "f1",
            "ordinal_position": 2
          },
          {
            "constraint_name": 6,
            "table_name": "tf_4",
            "column_name": "h",
            "ordinal_position": 1
          },
          {
            "constraint_name": 7,
            "table_name": "tf_4",
            "column_name": "j",
            "ordinal_position": 1
          },
          {
            "constraint_name": 7,
            "table_name": "tf_4",
            "column_name": "j1",
            "ordinal_position": 2
          },
          {
            "constraint_name": 8,
            "table_name": "tf_5",
            "column_name": "k",
            "ordinal_position": 1
          },
          {
            "constraint_name": 9,
            "table_name": "tf_5",
            "column_name": "l",
            "ordinal_position": 1
          },
          {
            "constraint_name": 10,
            "table_name": "tf_5",
            "column_name": "m",
            "ordinal_position": 1
          },
          {
            "constraint_name": 11,
            "table_name": "tf_6",
            "column_name": "n",
            "ordinal_position": 1
          },
          {
            "constraint_name": 12,
            "table_name": "tf_6",
            "column_name": "o",
            "ordinal_position": 1
          }
        ],
        "constraint_column_usage": [
          {
            "table_name": "tf_1",
            "column_name": "a",
            "constraint_name": 1,
            "ordinal_position": 1
          },
          {
            "table_name": "tf_3",
            "column_name": "f",
            "constraint_name": 2,
            "ordinal_position": 1
          },
          {
            "table_name": "tf_3",
            "column_name": "f",
            "constraint_name": 3,
            "ordinal_position": 1
          },
          {
            "table_name": "tf_3",
            "column_name": "f1",
            "constraint_name": 2,
            "ordinal_position": 2
          },
          {
            "table_name": "tf_3",
            "column_name": "f1",
            "constraint_name": 3,
            "ordinal_position": 2
          },
          {
            "table_name": "tf_4",
            "column_name": "h",
            "constraint_name": 4,
            "ordinal_position": 1
          },
          {
            "table_name": "tf_6",
            "column_name": "n",
            "constraint_name": 5,
            "ordinal_position": 1
          }
        ]
      }

# dm_from_con() with mariaDB

    

---

    Code
      dm::dm_get_all_fks(my_dm)
    Output
      # A tibble: 8 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 disps       account_id    accounts     id              cascade  
      2 loans       account_id    accounts     id              cascade  
      3 orders      account_id    accounts     id              cascade  
      4 trans       account_id    accounts     id              cascade  
      5 disps       client_id     clients      id              cascade  
      6 cards       disp_id       disps        id              cascade  
      7 accounts    district_id   districts    id              cascade  
      8 clients     district_id   districts    id              cascade  

---

    Code
      dm::dm_get_all_pks(my_dm)
    Output
      # A tibble: 9 x 3
        table     pk_col autoincrement
        <chr>     <keys> <lgl>        
      1 accounts  id     NA           
      2 cards     id     NA           
      3 clients   id     NA           
      4 disps     id     NA           
      5 districts id     NA           
      6 loans     id     NA           
      7 orders    id     NA           
      8 tkeys     id     NA           
      9 trans     id     NA           

---

    

---

    Code
      dm::dm_get_all_fks(my_dm)
    Output
      # A tibble: 3 x 5
        child_table child_fk_cols parent_table  parent_key_cols  on_delete
        <chr>       <keys>        <chr>         <keys>           <chr>    
      1 oseba       id_nesreca    nesreca       id_nesreca       cascade  
      2 nesreca     upravna_enota upravna_enota id_upravna_enota cascade  
      3 oseba       upravna_enota upravna_enota id_upravna_enota cascade  

---

    Code
      dm::dm_get_all_pks(my_dm)
    Output
      # A tibble: 3 x 3
        table         pk_col             autoincrement
        <chr>         <keys>             <lgl>        
      1 ad            ts, ad_id, user_id NA           
      2 nesreca       id_nesreca         NA           
      3 upravna_enota id_upravna_enota   NA           

