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
      <IDENT> `pixar_films`
      
      $remote_name$academy
      <IDENT> `academy`
      
      $remote_name$box_office
      <IDENT> `box_office`
      
      $remote_name$genres
      <IDENT> `genres`
      
      $remote_name$public_response
      <IDENT> `public_response`
      
      
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
        `number` TEXT,
        `film` TEXT,
        `release_date` DATE,
        `run_time` DOUBLE,
        `film_rating` TEXT,
        PRIMARY KEY (`film`)
      )
      <SQL> CREATE TEMPORARY TABLE `academy` (
        `film` TEXT,
        `award_type` TEXT,
        `status` TEXT,
        PRIMARY KEY (`film`, `award_type`),
        FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)
      )
      <SQL> CREATE TEMPORARY TABLE `box_office` (
        `film` TEXT,
        `budget` DOUBLE,
        `box_office_us_canada` DOUBLE,
        `box_office_other` DOUBLE,
        `box_office_worldwide` DOUBLE,
        PRIMARY KEY (`film`),
        FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)
      )
      <SQL> CREATE TEMPORARY TABLE `genres` (
        `film` TEXT,
        `genre` TEXT,
        PRIMARY KEY (`film`, `genre`),
        FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)
      )
      <SQL> CREATE TEMPORARY TABLE `public_response` (
        `film` TEXT,
        `rotten_tomatoes` DOUBLE,
        `metacritic` DOUBLE,
        `cinema_score` TEXT,
        `critics_choice` DOUBLE,
        PRIMARY KEY (`film`),
        FOREIGN KEY (`film`) REFERENCES `pixar_films` (`film`)
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      <SQL> CREATE INDEX academy__film ON `academy` (`film`)
      
      $sql_index[[3]]
      <SQL> CREATE INDEX box_office__film ON `box_office` (`film`)
      
      $sql_index[[4]]
      <SQL> CREATE INDEX genres__film ON `genres` (`film`)
      
      $sql_index[[5]]
      <SQL> CREATE INDEX public_response__film ON `public_response` (`film`)
      
      
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
      
      
      $dml
      <SQL> INSERT INTO `genres` (`film`, `genre`)
      SELECT CAST(`film` AS TEXT) AS `film`, CAST(`genre` AS TEXT) AS `genre`
      FROM (
        SELECT NULL AS `film`, NULL AS `genre`
        WHERE (0 = 1)
        UNION ALL
        VALUES
          ('Toy Story', 'Animation'),
          ('Toy Story', 'Adventure'),
          ('Toy Story', 'Comedy'),
          ('Toy Story', 'Family'),
          ('Toy Story', 'Fantasy'),
          ('A Bug''s Life', 'Animation'),
          ('A Bug''s Life', 'Adventure'),
          ('A Bug''s Life', 'Comedy'),
          ('A Bug''s Life', 'Family'),
          ('Toy Story 2', 'Animation'),
          ('Toy Story 2', 'Adventure'),
          ('Toy Story 2', 'Comedy'),
          ('Toy Story 2', 'Family'),
          ('Toy Story 2', 'Fantasy'),
          ('Monsters, Inc.', 'Animation'),
          ('Monsters, Inc.', 'Adventure'),
          ('Monsters, Inc.', 'Comedy'),
          ('Monsters, Inc.', 'Family'),
          ('Monsters, Inc.', 'Fantasy'),
          ('Finding Nemo', 'Animation'),
          ('Finding Nemo', 'Adventure'),
          ('Finding Nemo', 'Comedy'),
          ('Finding Nemo', 'Family'),
          ('The Incredibles', 'Animation'),
          ('The Incredibles', 'Action'),
          ('The Incredibles', 'Adventure'),
          ('The Incredibles', 'Family'),
          ('Cars', 'Animation'),
          ('Cars', 'Comedy'),
          ('Cars', 'Family'),
          ('Cars', 'Sport'),
          ('Ratatouille', 'Animation'),
          ('Ratatouille', 'Adventure'),
          ('Ratatouille', 'Comedy'),
          ('Ratatouille', 'Family'),
          ('Ratatouille', 'Fantasy'),
          ('WALL-E', 'Animation'),
          ('WALL-E', 'Adventure'),
          ('WALL-E', 'Family'),
          ('WALL-E', 'Romance'),
          ('WALL-E', 'Sci-Fi'),
          ('Up', 'Animation'),
          ('Up', 'Adventure'),
          ('Up', 'Comedy'),
          ('Up', 'Family'),
          ('Toy Story 3', 'Animation'),
          ('Toy Story 3', 'Adventure'),
          ('Toy Story 3', 'Comedy'),
          ('Toy Story 3', 'Family'),
          ('Toy Story 3', 'Fantasy'),
          ('Cars 2', 'Animation'),
          ('Cars 2', 'Adventure'),
          ('Cars 2', 'Comedy'),
          ('Cars 2', 'Family'),
          ('Cars 2', 'Sci-Fi'),
          ('Cars 2', 'Sport'),
          ('Brave', 'Animation'),
          ('Brave', 'Adventure'),
          ('Brave', 'Comedy'),
          ('Brave', 'Family'),
          ('Brave', 'Fantasy'),
          ('Monsters University', 'Animation'),
          ('Monsters University', 'Adventure'),
          ('Monsters University', 'Comedy'),
          ('Monsters University', 'Family'),
          ('Monsters University', 'Fantasy'),
          ('Inside Out', 'Animation'),
          ('Inside Out', 'Adventure'),
          ('Inside Out', 'Comedy'),
          ('Inside Out', 'Drama'),
          ('Inside Out', 'Family'),
          ('Inside Out', 'Fantasy'),
          ('The Good Dinosaur', 'Animation'),
          ('The Good Dinosaur', 'Adventure'),
          ('The Good Dinosaur', 'Comedy'),
          ('The Good Dinosaur', 'Drama'),
          ('The Good Dinosaur', 'Family'),
          ('The Good Dinosaur', 'Fantasy'),
          ('Finding Dory', 'Animation'),
          ('Finding Dory', 'Adventure'),
          ('Finding Dory', 'Comedy'),
          ('Finding Dory', 'Family'),
          ('Cars 3', 'Animation'),
          ('Cars 3', 'Adventure'),
          ('Cars 3', 'Comedy'),
          ('Cars 3', 'Family'),
          ('Cars 3', 'Sport'),
          ('Coco', 'Animation'),
          ('Coco', 'Adventure'),
          ('Coco', 'Family'),
          ('Coco', 'Fantasy'),
          ('Coco', 'Music'),
          ('Coco', 'Mystery'),
          ('Incredibles 2', 'Animation'),
          ('Incredibles 2', 'Action'),
          ('Incredibles 2', 'Adventure'),
          ('Incredibles 2', 'Comedy'),
          ('Incredibles 2', 'Family'),
          ('Incredibles 2', 'Sci-Fi'),
          ('Toy Story 4', 'Animation'),
          ('Toy Story 4', 'Adventure'),
          ('Toy Story 4', 'Comedy'),
          ('Toy Story 4', 'Family'),
          ('Toy Story 4', 'Fantasy'),
          ('Onward', 'Animation'),
          ('Onward', 'Adventure'),
          ('Onward', 'Comedy'),
          ('Onward', 'Family'),
          ('Onward', 'Fantasy'),
          ('Soul', 'Animation'),
          ('Soul', 'Adventure'),
          ('Soul', 'Comedy'),
          ('Soul', 'Family'),
          ('Soul', 'Fantasy'),
          ('Soul', 'Music'),
          ('Luca', 'Drama'),
          ('Luca', 'Mystery'),
          ('Luca', 'Romance'),
          ('Turning Red', 'Animation'),
          ('Turning Red', 'Adventure'),
          ('Turning Red', 'Comedy'),
          ('Turning Red', 'Family'),
          ('Turning Red', 'Fantasy'),
          ('Lightyear', 'Animation'),
          ('Lightyear', 'Adventure'),
          ('Lightyear', 'Family'),
          ('Lightyear', 'Fantasy'),
          ('Lightyear', 'Sci-Fi')
      ) AS `values_table`
      <SQL> INSERT INTO `pixar_films` (`number`, `film`, `release_date`, `run_time`, `film_rating`)
      SELECT
        CAST(`number` AS TEXT) AS `number`,
        CAST(`film` AS TEXT) AS `film`,
        CAST(`release_date` AS TEXT) AS `release_date`,
        CAST(`run_time` AS REAL) AS `run_time`,
        CAST(`film_rating` AS TEXT) AS `film_rating`
      FROM (
        SELECT
          NULL AS `number`,
          NULL AS `film`,
          NULL AS `release_date`,
          NULL AS `run_time`,
          NULL AS `film_rating`
        WHERE (0 = 1)
        UNION ALL
        VALUES
          ('1', 'Toy Story', '1995-11-22', 81.0, 'G'),
          ('2', 'A Bug''s Life', '1998-11-25', 95.0, 'G'),
          ('3', 'Toy Story 2', '1999-11-24', 92.0, 'G'),
          ('4', 'Monsters, Inc.', '2001-11-02', 92.0, 'G'),
          ('5', 'Finding Nemo', '2003-05-30', 100.0, 'G'),
          ('6', 'The Incredibles', '2004-11-05', 115.0, 'PG'),
          ('7', 'Cars', '2006-06-09', 117.0, 'G'),
          ('8', 'Ratatouille', '2007-06-29', 111.0, 'G'),
          ('9', 'WALL-E', '2008-06-27', 98.0, 'G'),
          ('10', 'Up', '2009-05-29', 96.0, 'PG'),
          ('11', 'Toy Story 3', '2010-06-18', 103.0, 'G'),
          ('12', 'Cars 2', '2011-06-24', 106.0, 'G'),
          ('13', 'Brave', '2012-06-22', 93.0, 'PG'),
          ('14', 'Monsters University', '2013-06-21', 104.0, 'G'),
          ('15', 'Inside Out', '2015-06-19', 95.0, 'PG'),
          ('16', 'The Good Dinosaur', '2015-11-25', 93.0, 'PG'),
          ('17', 'Finding Dory', '2016-06-17', 97.0, 'PG'),
          ('18', 'Cars 3', '2017-06-16', 102.0, 'G'),
          ('19', 'Coco', '2017-11-22', 105.0, 'PG'),
          ('20', 'Incredibles 2', '2018-06-15', 118.0, 'PG'),
          ('21', 'Toy Story 4', '2019-06-21', 100.0, 'G'),
          ('22', 'Onward', '2020-03-06', 102.0, 'PG'),
          ('23', 'Soul', '2020-12-25', 100.0, 'PG'),
          ('24', 'Luca', '2021-06-18', 151.0, 'N/A'),
          ('25', 'Turning Red', '2022-03-11', NULL, 'N/A'),
          ('26', 'Lightyear', '2022-06-17', NULL, 'N/A')
      ) AS `values_table`
      <SQL> INSERT INTO `academy` (`film`, `award_type`, `status`)
      SELECT
        CAST(`film` AS TEXT) AS `film`,
        CAST(`award_type` AS TEXT) AS `award_type`,
        CAST(`status` AS TEXT) AS `status`
      FROM (
        SELECT NULL AS `film`, NULL AS `award_type`, NULL AS `status`
        WHERE (0 = 1)
        UNION ALL
        VALUES
          ('Toy Story', 'Animated Feature', 'Award not yet introduced'),
          ('Toy Story', 'Original Screenplay', 'Nominated'),
          ('Toy Story', 'Adapted Screenplay', 'Ineligible'),
          ('Toy Story', 'Original Score', 'Nominated'),
          ('Toy Story', 'Original Song', 'Nominated'),
          ('Toy Story', 'Other', 'Won Special Achievement'),
          ('A Bug''s Life', 'Animated Feature', 'Award not yet introduced'),
          ('A Bug''s Life', 'Adapted Screenplay', 'Ineligible'),
          ('A Bug''s Life', 'Original Score', 'Nominated'),
          ('Toy Story 2', 'Animated Feature', 'Award not yet introduced'),
          ('Toy Story 2', 'Original Screenplay', 'Ineligible'),
          ('Toy Story 2', 'Original Song', 'Nominated'),
          ('Monsters, Inc.', 'Animated Feature', 'Nominated'),
          ('Monsters, Inc.', 'Adapted Screenplay', 'Ineligible'),
          ('Monsters, Inc.', 'Original Score', 'Nominated'),
          ('Monsters, Inc.', 'Original Song', 'Won'),
          ('Monsters, Inc.', 'Sound Editing', 'Nominated'),
          ('Finding Nemo', 'Animated Feature', 'Won'),
          ('Finding Nemo', 'Original Screenplay', 'Nominated'),
          ('Finding Nemo', 'Adapted Screenplay', 'Ineligible'),
          ('Finding Nemo', 'Original Score', 'Nominated'),
          ('Finding Nemo', 'Sound Editing', 'Nominated'),
          ('The Incredibles', 'Animated Feature', 'Won'),
          ('The Incredibles', 'Original Screenplay', 'Nominated'),
          ('The Incredibles', 'Adapted Screenplay', 'Ineligible'),
          ('The Incredibles', 'Sound Editing', 'Won'),
          ('The Incredibles', 'Sound Mixing', 'Nominated'),
          ('Cars', 'Animated Feature', 'Nominated'),
          ('Cars', 'Adapted Screenplay', 'Ineligible'),
          ('Cars', 'Original Song', 'Nominated'),
          ('Ratatouille', 'Animated Feature', 'Won'),
          ('Ratatouille', 'Original Screenplay', 'Nominated'),
          ('Ratatouille', 'Adapted Screenplay', 'Ineligible'),
          ('Ratatouille', 'Original Score', 'Nominated'),
          ('Ratatouille', 'Sound Editing', 'Nominated'),
          ('Ratatouille', 'Sound Mixing', 'Nominated'),
          ('WALL-E', 'Animated Feature', 'Won'),
          ('WALL-E', 'Original Screenplay', 'Nominated'),
          ('WALL-E', 'Adapted Screenplay', 'Ineligible'),
          ('WALL-E', 'Original Score', 'Nominated'),
          ('WALL-E', 'Original Song', 'Nominated'),
          ('WALL-E', 'Sound Editing', 'Nominated'),
          ('WALL-E', 'Sound Mixing', 'Nominated'),
          ('Up', 'Best Picture', 'Nominated'),
          ('Up', 'Animated Feature', 'Won'),
          ('Up', 'Original Screenplay', 'Nominated'),
          ('Up', 'Adapted Screenplay', 'Ineligible'),
          ('Up', 'Original Score', 'Won'),
          ('Up', 'Sound Editing', 'Nominated'),
          ('Toy Story 3', 'Best Picture', 'Nominated'),
          ('Toy Story 3', 'Animated Feature', 'Won'),
          ('Toy Story 3', 'Original Screenplay', 'Ineligible'),
          ('Toy Story 3', 'Adapted Screenplay', 'Nominated'),
          ('Toy Story 3', 'Original Song', 'Won'),
          ('Toy Story 3', 'Sound Editing', 'Nominated'),
          ('Cars 2', 'Original Screenplay', 'Ineligible'),
          ('Brave', 'Animated Feature', 'Won'),
          ('Brave', 'Adapted Screenplay', 'Ineligible'),
          ('Monsters University', 'Original Screenplay', 'Ineligible'),
          ('Inside Out', 'Animated Feature', 'Won'),
          ('Inside Out', 'Original Screenplay', 'Nominated'),
          ('Inside Out', 'Adapted Screenplay', 'Ineligible'),
          ('The Good Dinosaur', 'Adapted Screenplay', 'Ineligible'),
          ('Finding Dory', 'Original Screenplay', 'Ineligible'),
          ('Cars 3', 'Original Screenplay', 'Ineligible'),
          ('Coco', 'Animated Feature', 'Won'),
          ('Coco', 'Adapted Screenplay', 'Ineligible'),
          ('Coco', 'Original Song', 'Won'),
          ('Incredibles 2', 'Animated Feature', 'Nominated'),
          ('Incredibles 2', 'Original Screenplay', 'Ineligible'),
          ('Toy Story 4', 'Animated Feature', 'Won'),
          ('Toy Story 4', 'Original Screenplay', 'Ineligible'),
          ('Toy Story 4', 'Original Song', 'Nominated'),
          ('Onward', 'Animated Feature', 'Nominated'),
          ('Onward', 'Adapted Screenplay', 'Ineligible'),
          ('Soul', 'Animated Feature', 'Won'),
          ('Soul', 'Adapted Screenplay', 'Ineligible'),
          ('Soul', 'Original Score', 'Won'),
          ('Soul', 'Sound Editing', 'Nominated'),
          ('Soul', 'Sound Mixing', 'Nominated')
      ) AS `values_table`
      <SQL> INSERT INTO `box_office` (`film`, `budget`, `box_office_us_canada`, `box_office_other`, `box_office_worldwide`)
      SELECT
        CAST(`film` AS TEXT) AS `film`,
        CAST(`budget` AS REAL) AS `budget`,
        CAST(`box_office_us_canada` AS REAL) AS `box_office_us_canada`,
        CAST(`box_office_other` AS REAL) AS `box_office_other`,
        CAST(`box_office_worldwide` AS REAL) AS `box_office_worldwide`
      FROM (
        SELECT
          NULL AS `film`,
          NULL AS `budget`,
          NULL AS `box_office_us_canada`,
          NULL AS `box_office_other`,
          NULL AS `box_office_worldwide`
        WHERE (0 = 1)
        UNION ALL
        VALUES
          ('Toy Story', 30000000.0, 191796233.0, 181757800.0, 373554033.0),
          ('A Bug''s Life', 120000000.0, 162798565.0, 200460294.0, 363258859.0),
          ('Toy Story 2', 90000000.0, 245852179.0, 251522597.0, 497374776.0),
          ('Monsters, Inc.', 115000000.0, 289916256.0, 342400393.0, 632316649.0),
          ('Finding Nemo', 94000000.0, 339714978.0, 531300000.0, 871014978.0),
          ('The Incredibles', 92000000.0, 261441092.0, 370165621.0, 631606713.0),
          ('Cars', 120000000.0, 244082982.0, 217900167.0, 461983149.0),
          ('Ratatouille', 150000000.0, 206445654.0, 417280431.0, 623726085.0),
          ('WALL-E', 180000000.0, 223808164.0, 297503696.0, 521311860.0),
          ('Up', 175000000.0, 293004164.0, 442094918.0, 735099082.0),
          ('Toy Story 3', 200000000.0, 415004880.0, 651964823.0, 1066969703.0),
          ('Cars 2', 200000000.0, 191452396.0, 368400000.0, 559852396.0),
          ('Brave', 185000000.0, 237283207.0, 301700000.0, 538983207.0),
          ('Monsters University', 200000000.0, 268492764.0, 475066843.0, 743559607.0),
          ('Inside Out', 175000000.0, 356461711.0, 501149463.0, 857611174.0),
          ('The Good Dinosaur', 175000000.0, 123087120.0, 209120551.0, 332207671.0),
          ('Finding Dory', 200000000.0, 486295561.0, 542275328.0, 1028570889.0),
          ('Cars 3', 175000000.0, 152901115.0, 231029541.0, 383930656.0),
          ('Coco', 175000000.0, 209726015.0, 597356181.0, 807082196.0),
          ('Incredibles 2', 200000000.0, 608581744.0, 634223615.0, 1242805359.0),
          ('Toy Story 4', 200000000.0, 434038008.0, 639356585.0, 1073394593.0),
          ('Onward', 175000000.0, 61555145.0, 80394976.0, 141950121.0),
          ('Soul', 175000000.0, NULL, 135435315.0, 135435315.0),
          ('Luca', NULL, NULL, NULL, NULL)
      ) AS `values_table`
      <SQL> INSERT INTO `public_response` (`film`, `rotten_tomatoes`, `metacritic`, `cinema_score`, `critics_choice`)
      SELECT
        CAST(`film` AS TEXT) AS `film`,
        CAST(`rotten_tomatoes` AS REAL) AS `rotten_tomatoes`,
        CAST(`metacritic` AS REAL) AS `metacritic`,
        CAST(`cinema_score` AS TEXT) AS `cinema_score`,
        CAST(`critics_choice` AS REAL) AS `critics_choice`
      FROM (
        SELECT
          NULL AS `film`,
          NULL AS `rotten_tomatoes`,
          NULL AS `metacritic`,
          NULL AS `cinema_score`,
          NULL AS `critics_choice`
        WHERE (0 = 1)
        UNION ALL
        VALUES
          ('Toy Story', 100.0, 95.0, 'A', NULL),
          ('A Bug''s Life', 92.0, 77.0, 'A', NULL),
          ('Toy Story 2', 100.0, 88.0, 'A+', 100.0),
          ('Monsters, Inc.', 96.0, 79.0, 'A+', 92.0),
          ('Finding Nemo', 99.0, 90.0, 'A+', 97.0),
          ('The Incredibles', 97.0, 90.0, 'A+', 88.0),
          ('Cars', 74.0, 73.0, 'A', 89.0),
          ('Ratatouille', 96.0, 96.0, 'A', 91.0),
          ('WALL-E', 95.0, 95.0, 'A', 90.0),
          ('Up', 98.0, 88.0, 'A+', 95.0),
          ('Toy Story 3', 98.0, 92.0, 'A', 97.0),
          ('Cars 2', 40.0, 57.0, 'A-', 67.0),
          ('Brave', 78.0, 69.0, 'A', 81.0),
          ('Monsters University', 80.0, 65.0, 'A', 79.0),
          ('Inside Out', 98.0, 94.0, 'A', 93.0),
          ('The Good Dinosaur', 76.0, 66.0, 'A', 75.0),
          ('Finding Dory', 94.0, 77.0, 'A', 89.0),
          ('Cars 3', 69.0, 59.0, 'A', 66.0),
          ('Coco', 97.0, 81.0, 'A+', 89.0),
          ('Incredibles 2', 93.0, 80.0, 'A+', 86.0),
          ('Toy Story 4', 97.0, 84.0, 'A', 94.0),
          ('Onward', 88.0, 61.0, 'A-', 79.0),
          ('Soul', 96.0, 83.0, NULL, 93.0),
          ('Luca', NULL, NULL, NULL, NULL)
      ) AS `values_table`
      

# build_copy_queries avoids duplicate indexes

    Code
      as.list(queries)
    Output
      $name
      [1] "parent1"  "parent2"  "child"    "child__a"
      
      $remote_name
      $remote_name$parent1
      <IDENT> `parent1`
      
      $remote_name$parent2
      <IDENT> `parent2`
      
      $remote_name$child
      <IDENT> `child`
      
      $remote_name$child__a
      <IDENT> `child__a`
      
      
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
        `a__key` DOUBLE,
        FOREIGN KEY (`a__key`) REFERENCES `parent2` (`a__key`)
      )
      <SQL> CREATE TEMPORARY TABLE `child__a` (
        `key` DOUBLE,
        FOREIGN KEY (`key`) REFERENCES `parent2` (`a__key`)
      )
      
      $sql_index
      $sql_index[[1]]
      NULL
      
      $sql_index[[2]]
      NULL
      
      $sql_index[[3]]
      <SQL> CREATE INDEX child__a__key ON `child` (`a__key`)
      
      $sql_index[[4]]
      <SQL> CREATE INDEX child__a__key__1 ON `child__a` (`key`)
      
      
      $index_name
      $index_name[[1]]
      NULL
      
      $index_name[[2]]
      NULL
      
      $index_name[[3]]
      [1] "child__a__key"
      
      $index_name[[4]]
      [1] "child__a__key__1"
      
      
      $dml
      <SQL> INSERT INTO `child` (`a__key`)
      SELECT CAST(`a__key` AS REAL) AS `a__key`
      FROM (
        SELECT NULL AS `a__key`
        WHERE (0 = 1)
        UNION ALL
        VALUES (1.0)
      ) AS `values_table`
      <SQL> INSERT INTO `child__a` (`key`)
      SELECT CAST(`key` AS REAL) AS `key`
      FROM (
        SELECT NULL AS `key`
        WHERE (0 = 1)
        UNION ALL
        VALUES (1.0)
      ) AS `values_table`
      <SQL> INSERT INTO `parent1` (`key`)
      SELECT CAST(`key` AS REAL) AS `key`
      FROM (
        SELECT NULL AS `key`
        WHERE (0 = 1)
        UNION ALL
        VALUES (1.0)
      ) AS `values_table`
      <SQL> INSERT INTO `parent2` (`a__key`)
      SELECT CAST(`a__key` AS REAL) AS `a__key`
      FROM (
        SELECT NULL AS `a__key`
        WHERE (0 = 1)
        UNION ALL
        VALUES (1.0)
      ) AS `values_table`
      

