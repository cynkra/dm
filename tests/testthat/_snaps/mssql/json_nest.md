# `json_nest()` works remotely

    Code
      remote %>% json_nest(A = starts_with("a")) %>% arrange(grp) %>% collect()
    Output
      # A tibble: 2 x 2
          grp A                                                              
        <dbl> <chr>                                                          
      1     1 "[{\"a_i\":\"a\",\"a_j\":\"A\"},{\"a_i\":\"b\",\"a_j\":\"B\"}]"
      2     2 "[{\"a_i\":\"c\",\"a_j\":\"C\"},{\"a_i\":\"d\",\"a_j\":\"D\"}]"
    Code
      remote %>% json_nest(A = starts_with("a"), .names_sep = "_") %>% arrange(grp) %>%
        collect()
    Output
      # A tibble: 2 x 2
          grp A                                                              
        <dbl> <chr>                                                          
      1     1 "[{\"a_i\":\"a\",\"a_j\":\"A\"},{\"a_i\":\"b\",\"a_j\":\"B\"}]"
      2     2 "[{\"a_i\":\"c\",\"a_j\":\"C\"},{\"a_i\":\"d\",\"a_j\":\"D\"}]"

