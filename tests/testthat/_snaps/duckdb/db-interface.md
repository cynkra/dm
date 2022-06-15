# build_copy_queries snapshot test for pixarfilms

    Code
      pixar_dm %>% build_copy_queries(src_db, ., table_names = names(.) %>%
        repair_table_names_for_db(temporary = FALSE, con = src_db, schema = NULL) %>%
        map(dbplyr::ident_q)) %>% as.list()
    Condition
      Warning:
      duckdb doesn't support foreign keys, these won't be set in the remote database but are preserved in the `dm`
    Output
      $name
      [1] "pixar_films"     "academy"         "box_office"      "genres"         
      [5] "public_response"
      
      $remote_name
      $remote_name$pixar_films
      <IDENT> "pixar_films"
      
      $remote_name$academy
      <IDENT> "academy"
      
      $remote_name$box_office
      <IDENT> "box_office"
      
      $remote_name$genres
      <IDENT> "genres"
      
      $remote_name$public_response
      <IDENT> "public_response"
      
      
      $columns
      $columns[[1]]
      [1] "number"       "film"         "release_date" "run_time"     "film_rating" 
      
      $columns[[2]]
      [1] "film"       "award_type" "status"    
      
      $columns[[3]]
      [1] "film"                 "budget"               "box_office_us_canada"
      [4] "box_office_other"     "box_office_worldwide"
      
      $columns[[4]]
      [1] "film"  "genre"
      
      $columns[[5]]
      [1] "film"            "rotten_tomatoes" "metacritic"      "cinema_score"   
      [5] "critics_choice" 
      
      
      $sql_table
      <SQL> CREATE TEMP TABLE "pixar_films" (
        "number" STRING,
        "film" STRING,
        "release_date" DATE,
        "run_time" DOUBLE,
        "film_rating" STRING,
        PRIMARY KEY ("film")
      )
      <SQL> CREATE TEMP TABLE "academy" (
        "film" STRING,
        "award_type" STRING,
        "status" STRING,
        PRIMARY KEY ("film", "award_type")
      )
      <SQL> CREATE TEMP TABLE "box_office" (
        "film" STRING,
        "budget" DOUBLE,
        "box_office_us_canada" DOUBLE,
        "box_office_other" DOUBLE,
        "box_office_worldwide" DOUBLE,
        PRIMARY KEY ("film")
      )
      <SQL> CREATE TEMP TABLE "genres" (
        "film" STRING,
        "genre" STRING,
        PRIMARY KEY ("film", "genre")
      )
      <SQL> CREATE TEMP TABLE "public_response" (
        "film" STRING,
        "rotten_tomatoes" DOUBLE,
        "metacritic" DOUBLE,
        "cinema_score" STRING,
        "critics_choice" DOUBLE,
        PRIMARY KEY ("film")
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      NULL
      
      $sql_index[[3]]
      NULL
      
      $sql_index[[4]]
      NULL
      
      $sql_index[[5]]
      NULL
      
      
      $index_name
      $index_name[[1]]
      NULL
      
      $index_name[[2]]
      NULL
      
      $index_name[[3]]
      NULL
      
      $index_name[[4]]
      NULL
      
      $index_name[[5]]
      NULL
      
      

# build_copy_queries avoids duplicate indexes

    Code
      as.list(queries)
    Output
      $name
      [1] "parent1"  "parent2"  "child"    "child__a"
      
      $remote_name
      $remote_name$parent1
      <IDENT> "parent1"
      
      $remote_name$parent2
      <IDENT> "parent2"
      
      $remote_name$child
      <IDENT> "child"
      
      $remote_name$child__a
      <IDENT> "child__a"
      
      
      $columns
      $columns[[1]]
      [1] "key"
      
      $columns[[2]]
      [1] "a__key"
      
      $columns[[3]]
      [1] "a__key"
      
      $columns[[4]]
      [1] "key"
      
      
      $sql_table
      <SQL> CREATE TEMP TABLE "parent1" (
        "key" DOUBLE,
        PRIMARY KEY ("key")
      )
      <SQL> CREATE TEMP TABLE "parent2" (
        "a__key" DOUBLE,
        PRIMARY KEY ("a__key")
      )
      <SQL> CREATE TEMP TABLE "child" (
        "a__key" DOUBLE
      )
      <SQL> CREATE TEMP TABLE "child__a" (
        "key" DOUBLE
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      NULL
      
      $sql_index[[3]]
      NULL
      
      $sql_index[[4]]
      NULL
      
      
      $index_name
      $index_name[[1]]
      NULL
      
      $index_name[[2]]
      NULL
      
      $index_name[[3]]
      NULL
      
      $index_name[[4]]
      NULL
      
      

