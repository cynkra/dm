# build_copy_queries snapshot test for pixarfilms

    Code
      pixar_dm %>% build_copy_queries(src_db, .) %>% as.list()
    Output
      $name
      [1] "pixar_films"     "academy"         "box_office"      "genres"         
      [5] "public_response"
      
      $remote_name
            pixar_films           academy        box_office            genres 
          "pixar_films"         "academy"      "box_office"          "genres" 
        public_response 
      "public_response" 
      
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
      <SQL> CREATE TEMPORARY TABLE `pixar_films` (
        `number` VARCHAR(255),
        `film` VARCHAR(255),
        `release_date` DATE,
        `run_time` DOUBLE,
        `film_rating` VARCHAR(255),
        PRIMARY KEY (`film`)
      )
      <SQL> CREATE TEMPORARY TABLE `academy` (
        `film` VARCHAR(255),
        `award_type` VARCHAR(255),
        `status` VARCHAR(255),
        PRIMARY KEY (`film`, `award_type`)
      )
      <SQL> CREATE TEMPORARY TABLE `box_office` (
        `film` VARCHAR(255),
        `budget` DOUBLE,
        `box_office_us_canada` DOUBLE,
        `box_office_other` DOUBLE,
        `box_office_worldwide` DOUBLE,
        PRIMARY KEY (`film`)
      )
      <SQL> CREATE TEMPORARY TABLE `genres` (
        `film` VARCHAR(255),
        `genre` VARCHAR(255),
        PRIMARY KEY (`film`, `genre`)
      )
      <SQL> CREATE TEMPORARY TABLE `public_response` (
        `film` VARCHAR(255),
        `rotten_tomatoes` DOUBLE,
        `metacritic` DOUBLE,
        `cinema_score` VARCHAR(255),
        `critics_choice` DOUBLE,
        PRIMARY KEY (`film`)
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
      
      

# build_copy_queries snapshot test for dm_for_filter()

    Code
      dm_for_filter() %>% build_copy_queries(src_db, .) %>% as.list()
    Output
      $name
      [1] "tf_1" "tf_3" "tf_6" "tf_2" "tf_4" "tf_5"
      
      $remote_name
        tf_1   tf_3   tf_6   tf_2   tf_4   tf_5 
      "tf_1" "tf_3" "tf_6" "tf_2" "tf_4" "tf_5" 
      
      $columns
      $columns[[1]]
      [1] "a" "b"
      
      $columns[[2]]
      [1] "f"  "f1" "g" 
      
      $columns[[3]]
      [1] "zz" "n"  "o" 
      
      $columns[[4]]
      [1] "c"  "d"  "e"  "e1"
      
      $columns[[5]]
      [1] "h"  "i"  "j"  "j1"
      
      $columns[[6]]
      [1] "ww" "k"  "l"  "m" 
      
      
      $sql_table
      <SQL> CREATE TEMPORARY TABLE `tf_1` (
        `a` INT AUTO_INCREMENT,
        `b` VARCHAR(255),
        PRIMARY KEY (`a`)
      )
      <SQL> CREATE TEMPORARY TABLE `tf_3` (
        `f` VARCHAR(255),
        `f1` INT,
        `g` VARCHAR(255),
        PRIMARY KEY (`f`, `f1`)
      )
      <SQL> CREATE TEMPORARY TABLE `tf_6` (
        `zz` INT,
        `n` VARCHAR(255),
        `o` VARCHAR(255),
        PRIMARY KEY (`o`),
        UNIQUE (`n`)
      )
      <SQL> CREATE TEMPORARY TABLE `tf_2` (
        `c` VARCHAR(255),
        `d` INT,
        `e` VARCHAR(255),
        `e1` INT,
        PRIMARY KEY (`c`)
      )
      <SQL> CREATE TEMPORARY TABLE `tf_4` (
        `h` VARCHAR(255),
        `i` VARCHAR(255),
        `j` VARCHAR(255),
        `j1` INT,
        PRIMARY KEY (`h`)
      )
      <SQL> CREATE TEMPORARY TABLE `tf_5` (
        `ww` INT,
        `k` INT,
        `l` VARCHAR(255),
        `m` VARCHAR(255),
        PRIMARY KEY (`k`)
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
      
      $sql_index[[6]]
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
      
      $index_name[[6]]
      NULL
      
      

# build_copy_queries avoids duplicate indexes

    Code
      as.list(queries)
    Output
      $name
      [1] "parent1"  "parent2"  "child"    "child__a"
      
      $remote_name
      $remote_name$parent1
      <Id> table = parent1
      
      $remote_name$parent2
      <Id> table = parent2
      
      $remote_name$child
      <Id> table = child
      
      $remote_name$child__a
      <Id> table = child__a
      
      
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
      <SQL> CREATE TEMPORARY TABLE `parent1` (
        `key` DOUBLE,
        PRIMARY KEY (`key`)
      )
      <SQL> CREATE TEMPORARY TABLE `parent2` (
        `a__key` DOUBLE,
        PRIMARY KEY (`a__key`)
      )
      <SQL> CREATE TEMPORARY TABLE `child` (
        `a__key` DOUBLE
      )
      <SQL> CREATE TEMPORARY TABLE `child__a` (
        `key` DOUBLE
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
      
      

