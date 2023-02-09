# error message for non-dm object

    Code
      dm_get_def(structure(list(table = "a"), class = "bogus"))
    Condition
      Error in `abort_is_not_dm()`:
      ! Required class `dm` but instead is `bogus`.

# can upgrade from v1

    Code
      def <- dm_get_def(dm_v1, quiet = TRUE)
      def <- dm_get_def(dm_v1)
    Message
      Upgrading dm object created with dm <= 0.2.1.
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed from v1

    Code
      def <- dm_get_def(dm_v1_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v1_zoomed)
    Message
      Upgrading dm object created with dm <= 0.2.1.
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

# can upgrade from v2

    Code
      def <- dm_get_def(dm_v2, quiet = TRUE)
      def <- dm_get_def(dm_v2)
    Message
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE

# can upgrade zoomed from v2

    Code
      def <- dm_get_def(dm_v2_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v2_zoomed)
    Message
      Upgrading dm object created with dm <= 0.2.4.
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

# can upgrade from v3

    Code
      def <- dm_get_def(dm_v3, quiet = TRUE)
      def <- dm_get_def(dm_v3)
    Message
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE
    Code
      dm_get_all_uks(dm_v3)
    Message
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Output
      # A tibble: 7 x 3
        table uk_col kind       
        <chr> <keys> <chr>      
      1 tf_1  a      PK         
      2 tf_2  c      PK         
      3 tf_3  f, f1  PK         
      4 tf_4  h      PK         
      5 tf_5  k      PK         
      6 tf_6  o      PK         
      7 tf_6  n      implicit UK
    Code
      dm_get_all_pks(dm_v3)
    Message
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Output
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
    Code
      dm_get_all_fks(dm_v3)
    Message
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Output
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action

# can upgrade zoomed from v3

    Code
      def <- dm_get_def(dm_v3_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v3_zoomed)
    Message
      Upgrading dm object created with dm <= 0.3.0.
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

# can upgrade to v4

    Code
      def <- dm_get_def(dm_v4, quiet = TRUE)
      def <- dm_get_def(dm_v4)
    Message
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] FALSE
    Code
      dm_get_all_uks(dm_v4)
    Message
      Upgrading dm object created with dm <= 1.0.3.
    Output
      # A tibble: 7 x 3
        table uk_col kind       
        <chr> <keys> <chr>      
      1 tf_1  a      PK         
      2 tf_2  c      PK         
      3 tf_3  f, f1  PK         
      4 tf_4  h      PK         
      5 tf_5  k      PK         
      6 tf_6  o      PK         
      7 tf_6  n      implicit UK
    Code
      dm_get_all_pks(dm_v4)
    Message
      Upgrading dm object created with dm <= 1.0.3.
    Output
      # A tibble: 6 x 3
        table pk_col autoincrement
        <chr> <keys> <lgl>        
      1 tf_1  a      FALSE        
      2 tf_2  c      FALSE        
      3 tf_3  f, f1  FALSE        
      4 tf_4  h      FALSE        
      5 tf_5  k      FALSE        
      6 tf_6  o      FALSE        
    Code
      dm_get_all_fks(dm_v4)
    Message
      Upgrading dm object created with dm <= 1.0.3.
    Output
      # A tibble: 5 x 5
        child_table child_fk_cols parent_table parent_key_cols on_delete
        <chr>       <keys>        <chr>        <keys>          <chr>    
      1 tf_2        d             tf_1         a               no_action
      2 tf_2        e, e1         tf_3         f, f1           no_action
      3 tf_4        j, j1         tf_3         f, f1           no_action
      4 tf_5        l             tf_4         h               cascade  
      5 tf_5        m             tf_6         n               no_action

# can upgrade zoomed to v4

    Code
      def <- dm_get_def(dm_v4_zoomed, quiet = TRUE)
      def <- dm_get_def(dm_v4_zoomed)
    Message
      Upgrading dm object created with dm <= 1.0.3.
    Code
      dm <- new_dm3(def, zoomed = TRUE)
      dm_validate(dm)
      is_zoomed(dm)
    Output
      [1] TRUE

