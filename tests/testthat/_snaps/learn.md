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
        child_table child_fk_cols  parent_table  parent_key_cols  on_delete
        <chr>       <keys>         <chr>         <keys>           <chr>    
      1 Loan_Acc    account_id     acc           account_id       cascade  
      2 Loan_Acc    loan_id        loan          loan_id          cascade  
      3 Loan_Order  loan_id        loan          loan_id          cascade  
      4 Loan_Trans  loan_id        loan          loan_id          cascade  
      5 oseba       id_nesreca     nesreca       id_nesreca       cascade  
      6 Loan_Order  order_id       order         order_id         cascade  
      7 Loan_Trans  transaction_id trans         transaction_id   cascade  
      8 nesreca     upravna_enota  upravna_enota id_upravna_enota cascade  
      9 oseba       upravna_enota  upravna_enota id_upravna_enota cascade  

---

    Code
      dm::dm_get_all_pks(my_dm)
    Output
      # A tibble: 10 x 3
         table         pk_col                  autoincrement
         <chr>         <keys>                  <lgl>        
       1 Loan_Acc      loan_id, account_id     FALSE        
       2 Loan_Order    order_id, loan_id       FALSE        
       3 Loan_Trans    transaction_id, loan_id FALSE        
       4 acc           account_id              FALSE        
       5 ad            ts, ad_id, user_id      FALSE        
       6 loan          loan_id                 FALSE        
       7 nesreca       id_nesreca              FALSE        
       8 order         order_id                FALSE        
       9 trans         transaction_id          TRUE         
      10 upravna_enota id_upravna_enota        FALSE        

