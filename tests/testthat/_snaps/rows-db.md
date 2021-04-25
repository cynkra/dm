# output

    Code
      data <- test_src_frame(select = 1:3, where = letters[c(1:2, NA)], exists = 0.5 +
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
        where = "z")))))
    Output
      `x` and `y` must share the same src, set `copy` = TRUE (may be slow).
    Code
      rows_insert(data, test_src_frame(select = 4, where = "z"))
    Message <message>
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
      rows_insert(data, test_src_frame(select = 4, where = "z"), in_place = FALSE)
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
      rows_update(data, test_src_frame(select = 0L, where = "a"), by = "where",
      in_place = FALSE)
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
      rows_insert(data, test_src_frame(select = 4, where = "z"), in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 b        1.5
      3      3 <NA>     2.5
      4      4 z       NA  
    Code
      rows_update(data, test_src_frame(select = 2:3, where = "w"), in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        1.5
      3      3 w        2.5
      4      4 z       NA  
    Code
      rows_update(data, test_src_frame(select = 2, where = "w", exists = 3.5),
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
      4      4 z       NA  
    Code
      rows_update(data, test_src_frame(select = 2:3), in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      1 a        0.5
      2      2 w        3.5
      3      3 w        2.5
      4      4 z       NA  
    Code
      rows_update(data, test_src_frame(select = 0L, where = "a"), by = "where",
      in_place = TRUE)
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      0 a        0.5
      2      2 w        3.5
      3      3 w        2.5
      4      4 z       NA  
    Code
      rows_truncate(data, in_place = FALSE)
    Output
      # ... with 3 variables: select <int>, where <chr>, exists <dbl>
    Code
      data %>% arrange(select)
    Output
        select where exists
         <int> <chr>  <dbl>
      1      0 a        0.5
      2      2 w        3.5
      3      3 w        2.5
      4      4 z       NA  
    Code
      rows_truncate(data, in_place = TRUE)
      data %>% arrange(select)
    Output
      # ... with 3 variables: select <int>, where <chr>, exists <dbl>

