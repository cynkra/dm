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
      

