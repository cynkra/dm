# insert + delete + truncate message

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2)
      data
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_insert(data, test_db_src_frame(select = 4, where = "z"), by = "select",
      conflict = "ignore")
    Output
        select where exists
         <dbl> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5

# insert + delete + truncate

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2)
      data
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      writeLines(conditionMessage(expect_error(rows_insert(data, tibble(select = 4,
        where = "z"), by = "select", conflict = "ignore"))))
    Output
      `x` and `y` must share the same src.
      i set `copy` = TRUE (may be slow).
    Code
      rows_insert(data, test_db_src_frame(select = 4, where = "z"), by = "select",
      conflict = "ignore", in_place = FALSE)
    Output
        select where exists
         <dbl> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_insert(data, test_db_src_frame(select = 4, where = "z"), by = "select",
      conflict = "ignore", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 2), by = "select", unmatched = "ignore",
      in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 2), by = "select", unmatched = "ignore",
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select",
        "where"), unmatched = "ignore", in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select",
        "where"), unmatched = "ignore", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(where = "q"), by = "where", unmatched = "ignore",
      in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(where = "q"), by = "where", unmatched = "ignore",
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3), by = "select", unmatched = "ignore",
      in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      4 z         NA
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3), by = "select", unmatched = "ignore",
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      4 z         NA
    Code
      rows_truncate(data, in_place = FALSE)
    Output
      # ... with 3 variables: select <int>, where <chr>, exists <dbl>
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      4 z         NA
    Code
      rows_truncate(data, in_place = TRUE)
      data %>% arrange(select)
    Output
      # ... with 3 variables: select <int>, where <chr>, exists <dbl>

# update

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2)
      data
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      suppressMessages(rows_update(data, tibble(select = 2:3, where = "w"), copy = TRUE,
      unmatched = "ignore", in_place = FALSE))
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        1.5
      3      3 w        2.5
    Code
      suppressMessages(rows_update(data, tibble(select = 2:3), copy = TRUE,
      unmatched = "ignore", in_place = FALSE))
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      unmatched = "ignore", in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      2 b        1.5
      2      3 <NA>     2.5
      3      0 a        0.5
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_update(data, test_db_src_frame(select = 2:3, where = "w"), by = "select",
      unmatched = "ignore", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        1.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 2, where = "w", exists = 3.5), by = "select",
      unmatched = "ignore", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 2:3), by = "select", unmatched = "ignore",
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      unmatched = "ignore", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      0 a        0.5
      2      2 w        3.5
      3      3 w        2.5

# patch

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
      data
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      suppressMessages(rows_patch(data, tibble(select = 2:3, where = "patched"),
      copy = TRUE, unmatched = "ignore", in_place = FALSE) %>% arrange(select))
    Output
        select where  
         <int> <chr>  
      1      1 a      
      2      2 b      
      3      3 patched
    Code
      suppressMessages(rows_patch(data, tibble(select = 2:3), copy = TRUE, unmatched = "ignore",
      in_place = FALSE))
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      data %>% arrange(select)
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      rows_patch(data, test_db_src_frame(select = 0L, where = "patched"), by = "where",
      unmatched = "ignore", in_place = FALSE)
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      data %>% arrange(select)
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      rows_patch(data, test_db_src_frame(select = 2:3, where = "patched"), by = "select",
      unmatched = "ignore", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where  
         <int> <chr>  
      1      1 a      
      2      2 b      
      3      3 patched
    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
      rows_patch(data, test_db_src_frame(select = 2:3), by = "select", unmatched = "ignore",
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      rows_patch(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      unmatched = "ignore", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 

# upsert

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2, .unique_indexes = list("select", "where"))
      data
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_upsert(data, tibble(select = 2:4, where = c("x", "y", "z")), by = "select",
      copy = TRUE, in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 z       NA  
    Code
      rows_upsert(data, tibble(select = 2:4), by = "select", copy = TRUE, in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 <NA>    NA  
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_upsert(data, test_db_src_frame(select = 0L, where = c("a", "d")), by = "where",
      in_place = FALSE)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      2 b        1.5
      2      3 <NA>     2.5
      3      0 a        0.5
      4      0 d       NA  
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_upsert(data, test_db_src_frame(select = 2:4, where = c("x", "y", "z")),
      by = "select", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 z       NA  
    Code
      rows_upsert(data, test_db_src_frame(select = 4:5, where = c("o", "p"), exists = 3.5),
      by = "select", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 o        3.5
      5      5 p        3.5
    Code
      rows_upsert(data, test_db_src_frame(select = 2:3), by = "select", in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 o        3.5
      5      5 p        3.5
    Code
      rows_upsert(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      0 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 o        3.5
      5      5 p        3.5

