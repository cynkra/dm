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
      # A tibble: 5 x 3
        table           remote_table    sql                                           
        <chr>           <chr>           <SQL>                                         
      1 pixar_people    pixar_people    CREATE INDEX film_2021_12_15_16_52_52_68790_1~
      2 academy         academy         CREATE INDEX film_2021_12_15_16_52_52_68790_2~
      3 box_office      box_office      CREATE INDEX film_2021_12_15_16_52_52_68790_3~
      4 genres          genres          CREATE INDEX film_2021_12_15_16_52_52_68790_4~
      5 public_response public_response CREATE INDEX film_2021_12_15_16_52_52_68790_5~
      

