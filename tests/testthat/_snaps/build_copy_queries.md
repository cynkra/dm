# build_copy_queries works

    Code
      dm_pixarfilms() %>% build_copy_queries(src_db, .)
    Output
      $create_table_queries
      # A tibble: 6 x 3
        table           remote_table    sql                                           
        <chr>           <chr>           <SQL>                                         
      1 pixar_films     pixar_films     "CREATE TEMP TABLE pixar_films (\n  `number` ~
      2 pixar_people    pixar_people    "CREATE TEMP TABLE pixar_people (\n  `film` T~
      3 academy         academy         "CREATE TEMP TABLE academy (\n  `film` TEXT,\~
      4 box_office      box_office      "CREATE TEMP TABLE box_office (\n  `film` TEX~
      5 genres          genres          "CREATE TEMP TABLE genres (\n  `film` TEXT,\n~
      6 public_response public_response "CREATE TEMP TABLE public_response (\n  `film~
      
      $index_queries
      # A tibble: 5 x 4
        table           remote_table    remote_table_unquoted sql                     
        <chr>           <chr>           <chr>                 <SQL>                   
      1 pixar_people    pixar_people    pixar_people          CREATE INDEX pixar_peop~
      2 academy         academy         academy               CREATE INDEX academy__f~
      3 box_office      box_office      box_office            CREATE INDEX box_office~
      4 genres          genres          genres                CREATE INDEX genres__fi~
      5 public_response public_response public_response       CREATE INDEX public_res~
      

