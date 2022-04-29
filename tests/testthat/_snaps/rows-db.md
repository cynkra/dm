# insert + delete + truncate message

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2)
      data
    Output
      # Source:   table<test_frame_2022_04_29_00_30_41_11922_16> [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_insert(data, test_db_src_frame(select = 4, where = "z"))
    Message
      Result is returned as lazy table. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying table.
    Output
      # Source:   SQL [4 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <dbl> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
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
      # Source:   table<test_frame_2022_04_29_00_30_42_11922_18> [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      writeLines(conditionMessage(expect_error(rows_insert(data, tibble(select = 4,
        where = "z")))))
    Output
      `x` and `y` must share the same src.
      i set `copy` = TRUE (may be slow).
    Code
      rows_insert(data, test_db_src_frame(select = 4, where = "z"), in_place = FALSE)
    Output
      # Source:   SQL [4 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <dbl> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_insert(data, test_db_src_frame(select = 4, where = "z"), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [4 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 2), in_place = FALSE)
    Output
      # Source:   SQL [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [4 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 2), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select",
        "where"), in_place = FALSE)
    Output
      # Source:   SQL [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = c("select",
        "where"), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = "where",
      in_place = FALSE)
    Output
      # Source:   SQL [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), by = "where",
      in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), in_place = FALSE)
    Output
      # Source:   SQL [1 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      4 z         NA
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      3 <NA>     2.5
      3      4 z       NA  
    Code
      rows_delete(data, test_db_src_frame(select = 1:3, where = "q"), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [1 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      4 z         NA
    Code
      rows_truncate(data, in_place = FALSE)
    Output
      # Source:   SQL [0 x 3]
      # Database: sqlite 3.38.2 [:memory:]
      # ... with 3 variables: select <int>, where <chr>, exists <dbl>
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [1 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      4 z         NA
    Code
      rows_truncate(data, in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [0 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
      # ... with 3 variables: select <int>, where <chr>, exists <dbl>

# update

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2)
      data
    Output
      # Source:   table<test_frame_2022_04_29_00_30_44_11922_38> [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      suppressMessages(rows_update(data, tibble(select = 2:3, where = "w"), copy = TRUE,
      in_place = FALSE))
    Output
      # Source:   SQL [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        1.5
      3      3 w        2.5
    Code
      suppressMessages(rows_update(data, tibble(select = 2:3), copy = TRUE, in_place = FALSE))
    Output
      # Source:   table<test_frame_2022_04_29_00_30_44_11922_38> [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      in_place = FALSE)
    Output
      # Source:   SQL [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      2 b        1.5
      2      3 <NA>     2.5
      3      0 a        0.5
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_update(data, test_db_src_frame(select = 2:3, where = "w"), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        1.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 2, where = "w", exists = 3.5),
      in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 2:3), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
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
      # Source:   table<test_frame_2022_04_29_00_30_45_11922_44> [3 x 2]
      # Database: sqlite 3.38.2 [:memory:]
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      suppressMessages(rows_patch(data, tibble(select = 2:3, where = "patched"),
      copy = TRUE, in_place = FALSE) %>% arrange(select))
    Output
      # Source:     SQL [3 x 2]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where  
         <int> <chr>  
      1      1 a      
      2      2 b      
      3      3 patched
    Code
      suppressMessages(rows_patch(data, tibble(select = 2:3), copy = TRUE, in_place = FALSE))
    Output
      # Source:   table<test_frame_2022_04_29_00_30_45_11922_44> [3 x 2]
      # Database: sqlite 3.38.2 [:memory:]
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 2]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      rows_patch(data, test_db_src_frame(select = 0L, where = "patched"), by = "where",
      in_place = FALSE)
    Output
      # Source:   SQL [3 x 2]
      # Database: sqlite 3.38.2 [:memory:]
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 2]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      rows_patch(data, test_db_src_frame(select = 2:3, where = "patched"), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 2]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where  
         <int> <chr>  
      1      1 a      
      2      2 b      
      3      3 patched
    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
      rows_patch(data, test_db_src_frame(select = 2:3), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 2]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      rows_patch(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 2]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
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
      # Source:   table<test_frame_2022_04_29_00_30_46_11922_52> [3 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_upsert(data, tibble(select = 2:4, where = c("x", "y", "z")), copy = TRUE,
      in_place = FALSE)
    Output
      # Source:   SQL [4 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 z       NA  
    Code
      rows_upsert(data, tibble(select = 2:4), copy = TRUE, in_place = FALSE)
    Output
      # Source:   SQL [4 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 <NA>    NA  
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_upsert(data, test_db_src_frame(select = 0L, where = c("a", "d")), by = "where",
      in_place = FALSE)
    Output
      # Source:   SQL [4 x 3]
      # Database: sqlite 3.38.2 [:memory:]
        select where exists
         <int> <chr>  <dbl>
      1      2 b        1.5
      2      3 <NA>     2.5
      3      0 a        0.5
      4      0 d       NA  
    Code
      data %>% arrange(select)
    Output
      # Source:     SQL [3 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_upsert(data, test_db_src_frame(select = 2:4, where = c("x", "y", "z")),
      in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [4 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 z       NA  
    Code
      rows_upsert(data, test_db_src_frame(select = 4:5, where = c("o", "p"), exists = 3.5),
      in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [5 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 o        3.5
      5      5 p        3.5
    Code
      rows_upsert(data, test_db_src_frame(select = 2:3), in_place = TRUE)
      data %>% arrange(select)
    Output
      # Source:     SQL [5 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
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
      # Source:     SQL [5 x 3]
      # Database:   sqlite 3.38.2 [:memory:]
      # Ordered by: select
        select where exists
         <int> <chr>  <dbl>
      1      0 a        0.5
      2      2 x        1.5
      3      3 y        2.5
      4      4 o        3.5
      5      5 p        3.5

