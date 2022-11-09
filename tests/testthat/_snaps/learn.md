# dm_from_con() with mariaDB

    

---

    Code
      dm::dm_get_all_fks(my_dm)
    Output
      # A tibble: 8 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 disps       account_id    accounts     id              no_action
      2 loans       account_id    accounts     id              no_action
      3 orders      account_id    accounts     id              no_action
      4 trans       account_id    accounts     id              no_action
      5 disps       client_id     clients      id              no_action
      6 cards       disp_id       disps        id              no_action
      7 accounts    district_id   districts    id              no_action
      8 clients     district_id   districts    id              no_action

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
      1 oseba       id_nesreca    nesreca       id_nesreca       no_action
      2 nesreca     upravna_enota upravna_enota id_upravna_enota no_action
      3 oseba       upravna_enota upravna_enota id_upravna_enota no_action

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

