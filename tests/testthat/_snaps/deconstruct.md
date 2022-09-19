# `new_fks_in()` generates expected tibble

    Code
      new_fks_in(child_uuid = "flights-uuid", child_fk_cols = new_keys(list(list(
        "origin", "dest"))), parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_uuid   child_fk_cols parent_key_cols
        <chr>        <keys>        <keys>         
      1 flights-uuid origin, dest  faa            

# `new_fks_out()` generates expected tibble

    Code
      new_fks_out(child_fk_cols = new_keys(list(list("origin", "dest"))),
      parent_uuid = "airports-uuid", parent_key_cols = new_keys(list(list("faa"))))
    Output
      # A tibble: 1 x 3
        child_fk_cols parent_uuid   parent_key_cols
        <keys>        <chr>         <keys>         
      1 origin, dest  airports-uuid faa            

# `dm()` handles missing key column names gracefully

    Code
      dm(x = keyed$x["b"], y = keyed$y) %>% dm_paste()
    Message
      dm::dm(
        x,
        y,
      ) %>%
        dm::dm_add_pk(y, c(a, b))
    Code
      dm(x = keyed$x, y = keyed$y["b"]) %>% dm_paste()
    Message
      dm::dm(
        x,
        y,
      )

# keyed_by()

    Code
      keyed_by(x, y)
    Output
        a 
      "b" 
    Code
      keyed_by(y, x)
    Output
        b 
      "a" 

# joins with other child PK

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1,
            "c": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["c"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0800020b-0c07-030f-0a0e-0105060d0904"]
      } 
    Code
      dm(x, y, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        `<dm_keyed_tbl[,2]>`,
        `<dm_keyed_tbl[,1]>`,
        r,
      ) %>%
        dm::dm_select(`<dm_keyed_tbl[,2]>`, a, c) %>%
        dm::dm_select(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_select(r, a, c) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,2]>`, c) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_add_pk(r, c) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(r, a, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, r, a)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1,
            "c": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["c"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["03000c09-0a07-050d-020e-01040b08060f"]
      } 
    Code
      dm(x, y, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        `<dm_keyed_tbl[,2]>`,
        `<dm_keyed_tbl[,1]>`,
        r,
      ) %>%
        dm::dm_select(`<dm_keyed_tbl[,2]>`, a, c) %>%
        dm::dm_select(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_select(r, b, c) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,2]>`, c) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_add_pk(r, c) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(r, b, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, r, b)

# joins with other child PK and name conflict

    Code
      keyed_build_join_spec(x, y) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "a": 1,
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "b": 1
          }
        ],
        "by": [
          {
            "x": "a",
            "y": "b"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["a"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["a"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["0800020b-0c07-030f-0a0e-0105060d0904"]
      } 
    Code
      dm(x, y, r = left_join(x, y)) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        `<dm_keyed_tbl[,2]>`,
        `<dm_keyed_tbl[,1]>`,
        r,
      ) %>%
        dm::dm_select(`<dm_keyed_tbl[,2]>`, a, b) %>%
        dm::dm_select(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_select(r, a, b) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,2]>`, b) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(r, a, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, r, a)
    Code
      keyed_build_join_spec(y, x) %>% jsonlite::toJSON(pretty = TRUE)
    Output
      {
        "x_tbl": [
          {
            "b": 1
          }
        ],
        "y_tbl": [
          {
            "a": 1,
            "b": 1
          }
        ],
        "by": [
          {
            "x": "b",
            "y": "a"
          }
        ],
        "suffix": [".x", ".y"],
        "new_pk": ["b"],
        "new_fks_in": [
          {
            "child_uuid": "0109020c-0b0a-030e-0d04-05060f070008",
            "child_fk_cols": ["a"],
            "parent_key_cols": ["b"]
          }
        ],
        "new_fks_out": [
          {
            "child_fk_cols": ["b"],
            "parent_uuid": "04080601-0b0a-0c02-0503-0e070f0d0009",
            "parent_key_cols": ["b"]
          }
        ],
        "new_uuid": ["03000c09-0a07-050d-020e-01040b08060f"]
      } 
    Code
      dm(x, y, r = left_join(y, x)) %>% dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        `<dm_keyed_tbl[,2]>`,
        `<dm_keyed_tbl[,1]>`,
        r,
      ) %>%
        dm::dm_select(`<dm_keyed_tbl[,2]>`, a, b) %>%
        dm::dm_select(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_select(r, b, b.y) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,2]>`, b) %>%
        dm::dm_add_pk(`<dm_keyed_tbl[,1]>`, b) %>%
        dm::dm_add_pk(r, b) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(r, b, `<dm_keyed_tbl[,1]>`) %>%
        dm::dm_add_fk(`<dm_keyed_tbl[,2]>`, a, r)

