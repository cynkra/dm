# datamodel-code for drawing

    Code
      dm_get_data_model(dm_for_filter())
    Output
      $tables
        table segment display
      1  tf_1    <NA>    <NA>
      2  tf_2    <NA>    <NA>
      3  tf_3    <NA>    <NA>
      4  tf_4    <NA>    <NA>
      5  tf_5    <NA>    <NA>
      6  tf_6    <NA>    <NA>
      
      $columns
         table column id key  ref ref_col  keyId
      1   tf_1      a  1   1 <NA>    <NA>   <NA>
      2   tf_1      b  2   0 <NA>    <NA>   <NA>
      3   tf_2      c  1   1 <NA>    <NA>   <NA>
      4   tf_2      d  2   0 tf_1       a tf_2_1
      5   tf_2      e  3   0 <NA>    <NA>   <NA>
      6   tf_2     e1  4   0 <NA>    <NA>   <NA>
      7   tf_3      f  1   0 <NA>    <NA>   <NA>
      8   tf_3     f1  2   0 <NA>    <NA>   <NA>
      9   tf_3      g  3   0 <NA>    <NA>   <NA>
      10  tf_4      h  1   1 <NA>    <NA>   <NA>
      11  tf_4      i  2   0 <NA>    <NA>   <NA>
      12  tf_4      j  3   0 <NA>    <NA>   <NA>
      13  tf_4     j1  4   0 <NA>    <NA>   <NA>
      14  tf_5     ww  1   0 <NA>    <NA>   <NA>
      15  tf_5      k  2   1 <NA>    <NA>   <NA>
      16  tf_5      l  3   0 tf_4       h tf_5_1
      17  tf_5      m  4   0 tf_6       n tf_5_2
      18  tf_6     zz  1   0 <NA>    <NA>   <NA>
      19  tf_6      n  2   2 <NA>    <NA>   <NA>
      20  tf_6      o  3   1 <NA>    <NA>   <NA>
      21  tf_3  f, f1 NA   1 <NA>    <NA>   <NA>
      22  tf_2  e, e1 NA   0 tf_3   f, f1 tf_2_2
      23  tf_4  j, j1 NA   0 tf_3   f, f1 tf_4_1
      
      $references
      # A tibble: 5 x 7
        table column ref   ref_col keyId  ref_id ref_col_num
        <chr> <chr>  <chr> <chr>   <chr>   <int>       <int>
      1 tf_2  d      tf_1  a       tf_2_1      1           1
      2 tf_2  e, e1  tf_3  f, f1   tf_2_2      2           1
      3 tf_4  j, j1  tf_3  f, f1   tf_4_1      3           1
      4 tf_5  l      tf_4  h       tf_5_1      4           1
      5 tf_5  m      tf_6  n       tf_5_2      5           1
      
      attr(,"class")
      [1] "data_model"
    Code
      dm_get_data_model(dm_for_filter(), column_types = TRUE)
    Output
      $tables
        table segment display
      1  tf_1    <NA>    <NA>
      2  tf_2    <NA>    <NA>
      3  tf_3    <NA>    <NA>
      4  tf_4    <NA>    <NA>
      5  tf_5    <NA>    <NA>
      6  tf_6    <NA>    <NA>
      
      $columns
         table column id type key  ref ref_col  keyId
      1   tf_1      a  1  int   1 <NA>    <NA>   <NA>
      2   tf_1      b  2  chr   0 <NA>    <NA>   <NA>
      3   tf_2      c  1  chr   1 <NA>    <NA>   <NA>
      4   tf_2      d  2  int   0 tf_1       a tf_2_1
      5   tf_2      e  3  chr   0 <NA>    <NA>   <NA>
      6   tf_2     e1  4  int   0 <NA>    <NA>   <NA>
      7   tf_3      f  1  chr   0 <NA>    <NA>   <NA>
      8   tf_3     f1  2  int   0 <NA>    <NA>   <NA>
      9   tf_3      g  3  chr   0 <NA>    <NA>   <NA>
      10  tf_4      h  1  chr   1 <NA>    <NA>   <NA>
      11  tf_4      i  2  chr   0 <NA>    <NA>   <NA>
      12  tf_4      j  3  chr   0 <NA>    <NA>   <NA>
      13  tf_4     j1  4  int   0 <NA>    <NA>   <NA>
      14  tf_5     ww  1  int   0 <NA>    <NA>   <NA>
      15  tf_5      k  2  int   1 <NA>    <NA>   <NA>
      16  tf_5      l  3  chr   0 tf_4       h tf_5_1
      17  tf_5      m  4  chr   0 tf_6       n tf_5_2
      18  tf_6     zz  1  int   0 <NA>    <NA>   <NA>
      19  tf_6      n  2  chr   2 <NA>    <NA>   <NA>
      20  tf_6      o  3  chr   1 <NA>    <NA>   <NA>
      21  tf_3  f, f1 NA <NA>   1 <NA>    <NA>   <NA>
      22  tf_2  e, e1 NA <NA>   0 tf_3   f, f1 tf_2_2
      23  tf_4  j, j1 NA <NA>   0 tf_3   f, f1 tf_4_1
      
      $references
      # A tibble: 5 x 7
        table column ref   ref_col keyId  ref_id ref_col_num
        <chr> <chr>  <chr> <chr>   <chr>   <int>       <int>
      1 tf_2  d      tf_1  a       tf_2_1      1           1
      2 tf_2  e, e1  tf_3  f, f1   tf_2_2      2           1
      3 tf_4  j, j1  tf_3  f, f1   tf_4_1      3           1
      4 tf_5  l      tf_4  h       tf_5_1      4           1
      5 tf_5  m      tf_6  n       tf_5_2      5           1
      
      attr(,"class")
      [1] "data_model"

