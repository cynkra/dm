# `json_pack()` works remotely

    Code
      json_pack(remote, A = starts_with("a"))
    Output
          grp A                              
        <dbl> <chr>                          
      1     1 "{\"a_i\":\"a\",\"a_j\":\"A\"}"
      2     1 "{\"a_i\":\"b\",\"a_j\":\"B\"}"
      3     2 "{\"a_i\":\"c\",\"a_j\":\"C\"}"
      4     2 "{\"a_i\":\"d\",\"a_j\":\"D\"}"
    Code
      json_pack(remote, A = starts_with("a"), .names_sep = "_")
    Output
          grp A                              
        <dbl> <chr>                          
      1     1 "{\"a_i\":\"a\",\"a_j\":\"A\"}"
      2     1 "{\"a_i\":\"b\",\"a_j\":\"B\"}"
      3     2 "{\"a_i\":\"c\",\"a_j\":\"C\"}"
      4     2 "{\"a_i\":\"d\",\"a_j\":\"D\"}"

