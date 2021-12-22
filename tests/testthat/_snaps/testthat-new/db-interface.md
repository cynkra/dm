# build_copy_queries snapshot test for pixarfilms

    Code
      pixar_dm %>% build_copy_queries(src_db, ., table_names = names(.) %>%
        repair_table_names_for_db(temporary = FALSE, con = src_db, schema = NULL) %>%
        map(dbplyr::ident_q)) %>% map(as.data.frame)
    Output
      $create_table_queries
                  table      remote_table
      1     pixar_films     `pixar_films`
      2         academy         `academy`
      3      box_office      `box_office`
      4          genres          `genres`
      5 public_response `public_response`
                                                                                                                                                                                                                                                                 sql
      1                                                                                          CREATE TEMP TABLE `pixar_films` (\n  `number` TEXT,\n  `film` TEXT,\n  `release_date` DATE,\n  `run_time` DOUBLE,\n  `film_rating` TEXT,\n  PRIMARY KEY (`film`)\n)
      2                                                                    CREATE TEMP TABLE `academy` (\n  `film` TEXT,\n  `award_type` TEXT,\n  `status` TEXT,\n  PRIMARY KEY (`film`, `award_type`),\n  FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)\n)
      3 CREATE TEMP TABLE `box_office` (\n  `film` TEXT,\n  `budget` DOUBLE,\n  `box_office_us_canada` DOUBLE,\n  `box_office_other` DOUBLE,\n  `box_office_worldwide` DOUBLE,\n  PRIMARY KEY (`film`),\n  FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)\n)
      4                                                                                                 CREATE TEMP TABLE `genres` (\n  `film` TEXT,\n  `genre` TEXT,\n  PRIMARY KEY (`film`, `genre`),\n  FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)\n)
      5         CREATE TEMP TABLE `public_response` (\n  `film` TEXT,\n  `rotten_tomatoes` DOUBLE,\n  `metacritic` DOUBLE,\n  `cinema_score` TEXT,\n  `critics_choice` DOUBLE,\n  PRIMARY KEY (`film`),\n  FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)\n)
      
      $index_queries
                  table      remote_table remote_table_unquoted            index_name
      1         academy         `academy`               academy         academy__film
      2      box_office      `box_office`            box_office      box_office__film
      3          genres          `genres`                genres          genres__film
      4 public_response `public_response`       public_response public_response__film
                                                                     sql
      1                 CREATE INDEX academy__film ON `academy` (`film`)
      2           CREATE INDEX box_office__film ON `box_office` (`film`)
      3                   CREATE INDEX genres__film ON `genres` (`film`)
      4 CREATE INDEX public_response__film ON `public_response` (`film`)
      

