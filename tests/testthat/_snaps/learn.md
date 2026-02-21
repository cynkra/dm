# Learning keys from SQLite works

    Code
      dm_paste(learned_dm, options = "keys")
    Message
      dm::dm(
        first,
        second,
        third,
      ) %>%
        dm::dm_add_pk(first, id) %>%
        dm::dm_add_pk(second, id) %>%
        dm::dm_add_pk(third, id) %>%
        dm::dm_add_fk(second, first_id, first) %>%
        dm::dm_add_fk(third, first_id, first) %>%
        dm::dm_add_fk(third, second_id, second)

# Learning keys from an attached SQLite database works

    Code
      dm_paste(learned_dm, options = "keys")
    Message
      dm::dm(
        other.child_tbl,
        other.parent_tbl,
      ) %>%
        dm::dm_add_pk(other.child_tbl, id) %>%
        dm::dm_add_pk(other.parent_tbl, id) %>%
        dm::dm_add_fk(other.child_tbl, parent_id, other.parent_tbl)

# dm_from_con() with mariaDB

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
      1 accounts  id     FALSE        
      2 cards     id     FALSE        
      3 clients   id     FALSE        
      4 disps     id     FALSE        
      5 districts id     FALSE        
      6 loans     id     FALSE        
      7 orders    id     FALSE        
      8 tkeys     id     FALSE        
      9 trans     id     FALSE        

---

    Code
      dm::dm_get_all_fks(my_dm)
    Output
      # A tibble: 9 x 5
        child_table              child_fk_cols  parent_table parent_key_cols on_delete
        <chr>                    <keys>         <chr>        <keys>          <chr>    
      1 Accidents.oseba          id_nesreca     Accidents.n~ id_nesreca      cascade  
      2 Accidents.nesreca        upravna_enota  Accidents.u~ id_upravna_eno~ cascade  
      3 Accidents.oseba          upravna_enota  Accidents.u~ id_upravna_eno~ cascade  
      4 Financial_std.Loan_Acc   account_id     Financial_s~ account_id      cascade  
      5 Financial_std.Loan_Acc   loan_id        Financial_s~ loan_id         cascade  
      6 Financial_std.Loan_Order loan_id        Financial_s~ loan_id         cascade  
      7 Financial_std.Loan_Trans loan_id        Financial_s~ loan_id         cascade  
      8 Financial_std.Loan_Order order_id       Financial_s~ order_id        cascade  
      9 Financial_std.Loan_Trans transaction_id Financial_s~ transaction_id  cascade  

---

    Code
      dm::dm_get_all_pks(my_dm)
    Output
      # A tibble: 10 x 3
         table                    pk_col                  autoincrement
         <chr>                    <keys>                  <lgl>        
       1 Accidents.nesreca        id_nesreca              FALSE        
       2 Accidents.upravna_enota  id_upravna_enota        FALSE        
       3 Ad.ad                    ts, ad_id, user_id      FALSE        
       4 Financial_std.Loan_Acc   loan_id, account_id     FALSE        
       5 Financial_std.Loan_Order order_id, loan_id       FALSE        
       6 Financial_std.Loan_Trans transaction_id, loan_id FALSE        
       7 Financial_std.acc        account_id              FALSE        
       8 Financial_std.loan       loan_id                 FALSE        
       9 Financial_std.order      order_id                FALSE        
      10 Financial_std.trans      transaction_id          TRUE         

