# `json_pack()` works

    Code
      df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
      packed <- json_pack(df, x = c(x1, x2, x3), y = y)
    Output
      Complete! Processed total of 3 rows.
      Complete! Processed total of 3 rows.
    Code
      packed
    Output
      # A tibble: 3 x 2
        x                              y          
        <chr>                          <chr>      
      1 "{\"x1\":1,\"x2\":4,\"x3\":7}" "{\"y\":1}"
      2 "{\"x1\":2,\"x2\":5,\"x3\":8}" "{\"y\":2}"
      3 "{\"x1\":3,\"x2\":6,\"x3\":9}" "{\"y\":3}"

