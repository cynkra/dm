# insert + delete + truncate message

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      rows_insert(data, test_db_src_frame(select = 4, where = "z"))
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Message <rlang_message>
      Result is returned as lazy table. Use `in_place = FALSE` to mute this message, or `in_place = TRUE` to write to the underlying table.
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

# update

    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
        0:2)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
    Code
      suppressMessages(rows_update(data, tibble(select = 2:3, where = "w"), copy = TRUE,
      in_place = FALSE))
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        1.5
      3      3 w        2.5
    Code
      suppressMessages(rows_update(data, tibble(select = 2:3), copy = TRUE, in_place = FALSE))
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
      in_place = FALSE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
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
      rows_update(data, test_db_src_frame(select = 2:3, where = "w"), in_place = TRUE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        1.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 2, where = "w", exists = 3.5),
      in_place = TRUE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 2:3), in_place = TRUE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
    Code
      rows_update(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      in_place = TRUE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
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
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      suppressMessages(rows_patch(data, tibble(select = 2:3, where = "patched"),
      copy = TRUE, in_place = FALSE) %>% arrange(select))
    Output
        select where  
         <int> <chr>  
      1      1 a      
      2      2 b      
      3      3 patched
    Code
      suppressMessages(rows_patch(data, tibble(select = 2:3), copy = TRUE, in_place = FALSE))
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
      in_place = FALSE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
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
      rows_patch(data, test_db_src_frame(select = 2:3, where = "patched"), in_place = TRUE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data %>% arrange(select)
    Output
        select where  
         <int> <chr>  
      1      1 a      
      2      2 b      
      3      3 patched
    Code
      data <- test_db_src_frame(select = 1:3, where = letters[c(1:2, NA)])
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      rows_patch(data, test_db_src_frame(select = 2:3), in_place = TRUE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data %>% arrange(select)
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 
    Code
      rows_patch(data, test_db_src_frame(select = 0L, where = "a"), by = "where",
      in_place = TRUE)
    Message <simpleMessage>
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
      Found more than one class "blob" in cache; using the first, from namespace 'blob'
      Also defined by 'jsonlite'
    Code
      data %>% arrange(select)
    Output
        select where
         <int> <chr>
      1      1 a    
      2      2 b    
      3      3 <NA> 

