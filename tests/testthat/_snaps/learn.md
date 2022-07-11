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
      # A tibble: 9 x 2
        table     pk_cols
        <chr>     <keys> 
      1 accounts  id     
      2 cards     id     
      3 clients   id     
      4 disps     id     
      5 districts id     
      6 loans     id     
      7 orders    id     
      8 tkeys     id     
      9 trans     id     

