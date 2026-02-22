# `json_nest()` and `json_unnest()` work

    Code
      df <- tibble::tibble(x = c(1, 1, 1, 2, 2, 3), y = 1:6, z = 6:1)
      nested <- json_nest(df, data = c(y, z))
      nested
    Output
      # A tibble: 3 x 2
            x data                                                     
        <dbl> <chr>                                                    
      1     1 "[{\"y\":1,\"z\":6},{\"y\":2,\"z\":5},{\"y\":3,\"z\":4}]"
      2     2 "[{\"y\":4,\"z\":3},{\"y\":5,\"z\":2}]"                  
      3     3 "[{\"y\":6,\"z\":1}]"                                    

# `json_nest()` fails with unnamed elements

    Code
      json_nest(df, c(y, z))
    Condition
      Error in `json_nest()`:
      ! All elements of `...` must be named.

# `json_unnest()` fails without cols argument

    Code
      json_unnest(df)
    Condition
      Error in `json_unnest()`:
      ! The `cols` argument must be provided.

