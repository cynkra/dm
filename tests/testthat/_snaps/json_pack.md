# `json_pack()` works

    Code
      df <- tibble::tibble(x1 = 1:3, x2 = 4:6, x3 = 7:9, y = 1:3)
      packed <- json_pack(df, x = c(x1, x2, x3), y = y)
      packed
    Output
      # A tibble: 3 x 2
        x                              y          
        <chr>                          <chr>      
      1 "{\"x1\":1,\"x2\":4,\"x3\":7}" "{\"y\":1}"
      2 "{\"x1\":2,\"x2\":5,\"x3\":8}" "{\"y\":2}"
      3 "{\"x1\":3,\"x2\":6,\"x3\":9}" "{\"y\":3}"

# `json_pack()` works remotely

    Code
      json_pack(iris_remote, Sepal = 1:2, Petal = starts_with("Petal"))
    Output
         Species Sepal                                       Petal                    
         <chr>   <pq_json>                                   <pq_json>                
       1 setosa  {"Sepal.Length" : 5.1, "Sepal.Width" : 3.5} {"Petal.Length" : 1.4, "~
       2 setosa  {"Sepal.Length" : 4.9, "Sepal.Width" : 3}   {"Petal.Length" : 1.4, "~
       3 setosa  {"Sepal.Length" : 4.7, "Sepal.Width" : 3.2} {"Petal.Length" : 1.3, "~
       4 setosa  {"Sepal.Length" : 4.6, "Sepal.Width" : 3.1} {"Petal.Length" : 1.5, "~
       5 setosa  {"Sepal.Length" : 5, "Sepal.Width" : 3.6}   {"Petal.Length" : 1.4, "~
       6 setosa  {"Sepal.Length" : 5.4, "Sepal.Width" : 3.9} {"Petal.Length" : 1.7, "~
       7 setosa  {"Sepal.Length" : 4.6, "Sepal.Width" : 3.4} {"Petal.Length" : 1.4, "~
       8 setosa  {"Sepal.Length" : 5, "Sepal.Width" : 3.4}   {"Petal.Length" : 1.5, "~
       9 setosa  {"Sepal.Length" : 4.4, "Sepal.Width" : 2.9} {"Petal.Length" : 1.4, "~
      10 setosa  {"Sepal.Length" : 4.9, "Sepal.Width" : 3.1} {"Petal.Length" : 1.5, "~
      # ... with more rows
    Code
      json_pack(iris_remote, Sepal = 1:2, Petal = starts_with("Petal"), .names_sep = ".")
    Output
         Species Sepal                           Petal                          
         <chr>   <pq_json>                       <pq_json>                      
       1 setosa  {"Length" : 5.1, "Width" : 3.5} {"Length" : 1.4, "Width" : 0.2}
       2 setosa  {"Length" : 4.9, "Width" : 3}   {"Length" : 1.4, "Width" : 0.2}
       3 setosa  {"Length" : 4.7, "Width" : 3.2} {"Length" : 1.3, "Width" : 0.2}
       4 setosa  {"Length" : 4.6, "Width" : 3.1} {"Length" : 1.5, "Width" : 0.2}
       5 setosa  {"Length" : 5, "Width" : 3.6}   {"Length" : 1.4, "Width" : 0.2}
       6 setosa  {"Length" : 5.4, "Width" : 3.9} {"Length" : 1.7, "Width" : 0.4}
       7 setosa  {"Length" : 4.6, "Width" : 3.4} {"Length" : 1.4, "Width" : 0.3}
       8 setosa  {"Length" : 5, "Width" : 3.4}   {"Length" : 1.5, "Width" : 0.2}
       9 setosa  {"Length" : 4.4, "Width" : 2.9} {"Length" : 1.4, "Width" : 0.2}
      10 setosa  {"Length" : 4.9, "Width" : 3.1} {"Length" : 1.5, "Width" : 0.1}
      # ... with more rows

