# json joins work

    Code
      packed
    Output
      # A tibble: 3 x 3
         col1 key   df2       
        <int> <chr> <list>    
      1     1 a     <json [1]>
      2     1 a     <json [1]>
      3     2 b     <json [1]>
    Code
      packed$df2
    Output
      [[1]]
      [{"col2":3,"col3":"X"}] 
      
      [[2]]
      [{"col2":4,"col3":"Y"}] 
      
      [[3]]
      [{"col2":3.14159265358979,"col3":"Z"}] 
      

---

    Code
      nested
    Output
      # A tibble: 2 x 3
         col1 key   df2       
        <int> <chr> <list>    
      1     1 a     <json [1]>
      2     2 b     <json [1]>
    Code
      nested$df2
    Output
      [[1]]
      [{"col2":3,"col3":"X"},{"col2":4,"col3":"Y"}] 
      
      [[2]]
      [{"col2":3.14159265358979,"col3":"Z"}] 
      

# `json_pack()` works

    Code
      df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
      packed <- json_pack(df, x = c(x1, x2, x3), y = y)
      packed
    Output
      # A tibble: 1 x 2
        x                                                                        y    
        <chr>                                                                    <chr>
      1 "[{\"x1\":1,\"x2\":4,\"x3\":7},{\"x1\":2,\"x2\":5,\"x3\":8},{\"x1\":3,\~ "[{\~

# `json_nest()` works

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

