# dm_from_con() with mariaDB

    

---

    Code
      dm::dm_get_all_fks(my_dm)
    Output
      # A tibble: 0 x 5
      # ... with 5 variables: child_table <chr>, child_fk_cols <keys>,
      #   parent_table <chr>, parent_key_cols <keys>, on_delete <chr>

---

    Code
      dm::dm_get_all_pks(my_dm)
    Output
      # A tibble: 0 x 3
      # ... with 3 variables: table <chr>, pk_col <keys>, autoincrement <lgl>

