# build_copy_queries snapshot test for pixarfilms

    Code
      pixar_dm %>% build_copy_queries(src_db, ., table_names = names(.) %>%
        repair_table_names_for_db(temporary = FALSE, con = src_db, schema = NULL) %>%
        map(dbplyr::ident_q)) %>% as.list()
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
      <SQL> CREATE TEMPORARY TABLE "pixar_films" (
        "number" STRING,
        "film" STRING,
        "release_date" DATE,
        "run_time" DOUBLE,
        "film_rating" STRING,
        PRIMARY KEY ("film")
      )
      <SQL> CREATE TEMPORARY TABLE "academy" (
        "film" STRING,
        "award_type" STRING,
        "status" STRING,
        PRIMARY KEY ("film", "award_type"),
        FOREIGN KEY ("film") REFERENCES "pixar_films" ("film")
      )
      <SQL> CREATE TEMPORARY TABLE "box_office" (
        "film" STRING,
        "budget" DOUBLE,
        "box_office_us_canada" DOUBLE,
        "box_office_other" DOUBLE,
        "box_office_worldwide" DOUBLE,
        PRIMARY KEY ("film"),
        FOREIGN KEY ("film") REFERENCES "pixar_films" ("film")
      )
      <SQL> CREATE TEMPORARY TABLE "genres" (
        "film" STRING,
        "genre" STRING,
        PRIMARY KEY ("film", "genre"),
        FOREIGN KEY ("film") REFERENCES "pixar_films" ("film")
      )
      <SQL> CREATE TEMPORARY TABLE "public_response" (
        "film" STRING,
        "rotten_tomatoes" DOUBLE,
        "metacritic" DOUBLE,
        "cinema_score" STRING,
        "critics_choice" DOUBLE,
        PRIMARY KEY ("film"),
        FOREIGN KEY ("film") REFERENCES "pixar_films" ("film")
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      <SQL> CREATE INDEX academy__film ON "academy" ("film")
      
      $sql_index[[3]]
      <SQL> CREATE INDEX box_office__film ON "box_office" ("film")
      
      $sql_index[[4]]
      <SQL> CREATE INDEX genres__film ON "genres" ("film")
      
      $sql_index[[5]]
      <SQL> CREATE INDEX public_response__film ON "public_response" ("film")
      
      
      $index_name
      $index_name[[1]]
      NULL
      
      $index_name[[2]]
      [1] "academy__film"
      
      $index_name[[3]]
      [1] "box_office__film"
      
      $index_name[[4]]
      [1] "genres__film"
      
      $index_name[[5]]
      [1] "public_response__film"
      
      

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
      <SQL> CREATE TEMPORARY TABLE "parent1" (
        "key" DOUBLE,
        PRIMARY KEY ("key")
      )
      <SQL> CREATE TEMPORARY TABLE "parent2" (
        "a__key" DOUBLE,
        PRIMARY KEY ("a__key")
      )
      <SQL> CREATE TEMPORARY TABLE "child" (
        "a__key" DOUBLE,
        FOREIGN KEY ("a__key") REFERENCES "parent2" ("a__key")
      )
      <SQL> CREATE TEMPORARY TABLE "child__a" (
        "key" DOUBLE,
        FOREIGN KEY ("key") REFERENCES "parent2" ("a__key")
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      NULL
      
      $sql_index[[3]]
      <SQL> CREATE INDEX child__a__key ON "child" ("a__key")
      
      $sql_index[[4]]
      <SQL> CREATE INDEX child__a__key__1 ON "child__a" ("key")
      
      
      $index_name
      $index_name[[1]]
      NULL
      
      $index_name[[2]]
      NULL
      
      $index_name[[3]]
      [1] "child__a__key"
      
      $index_name[[4]]
      [1] "child__a__key__1"
      
      

