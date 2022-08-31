# `json_nest()` works remotely

    Code
      remote %>% json_nest(a = starts_with("a")) %>% arrange(grp) %>% show_query()
    Output
      <SQL>
      SELECT *
      FROM (
      SELECT "grp", (SELECT "a_i", "a_j" FROM (SELECT *
      FROM "#test_frame_34_2022_08_31_13_51_42_731328_14985") "*tmp_a*" WHERE ("grp" = "*tmp*"."grp") FOR JSON PATH) AS "a" FROM (SELECT *
      FROM "#test_frame_34_2022_08_31_13_51_42_731328_14985") "*tmp*" GROUP BY "grp"
      ) "q01"
      ORDER BY "grp"
    Code
      remote %>% json_nest(a = starts_with("a")) %>% arrange(grp) %>% collect()
    Output
      # A tibble: 2 x 2
          grp a                                                              
        <dbl> <chr>                                                          
      1     1 "[{\"a_i\":\"a\",\"a_j\":\"A\"},{\"a_i\":\"b\",\"a_j\":\"B\"}]"
      2     2 "[{\"a_i\":\"c\",\"a_j\":\"C\"},{\"a_i\":\"d\",\"a_j\":\"D\"}]"
    Code
      remote %>% json_nest(a = starts_with("a"), .names_sep = "_") %>% arrange(grp) %>%
        show_query()
    Output
      <SQL>
      SELECT *
      FROM (
      SELECT "grp", (SELECT "a_i" "i", "a_j" "j" FROM (SELECT *
      FROM "#test_frame_34_2022_08_31_13_51_42_731328_14985") "*tmp_a*" WHERE ("grp" = "*tmp*"."grp") FOR JSON PATH) AS "a" FROM (SELECT *
      FROM "#test_frame_34_2022_08_31_13_51_42_731328_14985") "*tmp*" GROUP BY "grp"
      ) "q01"
      ORDER BY "grp"
    Code
      remote %>% json_nest(a = starts_with("a"), .names_sep = "_") %>% arrange(grp) %>%
        collect()
    Output
      # A tibble: 2 x 2
          grp a                                                      
        <dbl> <chr>                                                  
      1     1 "[{\"i\":\"a\",\"j\":\"A\"},{\"i\":\"b\",\"j\":\"B\"}]"
      2     2 "[{\"i\":\"c\",\"j\":\"C\"},{\"i\":\"d\",\"j\":\"D\"}]"

