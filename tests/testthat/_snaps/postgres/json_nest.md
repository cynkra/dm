# `json_nest()` works remotely

    Code
      query <- remote %>% json_nest(a = starts_with("a")) %>% arrange(grp) %>%
        dbplyr::sql_render()
      gsub("test_frame_[_0-9]+", "test_frame_...", query)
    Output
      <SQL> SELECT "grp", JSON_AGG(JSON_BUILD_OBJECT('a_i', "a_i", 'a_j', "a_j")) AS "a"
      FROM "test_frame_..."
      GROUP BY "grp"
      ORDER BY "grp"
    Code
      remote %>% json_nest(a = starts_with("a")) %>% arrange(grp) %>% collect()
    Output
      # A tibble: 2 x 2
          grp a                                                       
        <dbl> <pq_json>                                               
      1     1 [{"a_i" : "a", "a_j" : "A"}, {"a_i" : "b", "a_j" : "B"}]
      2     2 [{"a_i" : "c", "a_j" : "C"}, {"a_i" : "d", "a_j" : "D"}]
    Code
      query <- remote %>% json_nest(a = starts_with("a"), .names_sep = "_") %>%
        arrange(grp) %>% dbplyr::sql_render()
      gsub("test_frame_[_0-9]+", "test_frame_...", query)
    Output
      <SQL> SELECT "grp", JSON_AGG(JSON_BUILD_OBJECT('i', "a_i", 'j', "a_j")) AS "a"
      FROM "test_frame_..."
      GROUP BY "grp"
      ORDER BY "grp"
    Code
      remote %>% json_nest(a = starts_with("a"), .names_sep = "_") %>% arrange(grp) %>%
        collect()
    Output
      # A tibble: 2 x 2
          grp a                                               
        <dbl> <pq_json>                                       
      1     1 [{"i" : "a", "j" : "A"}, {"i" : "b", "j" : "B"}]
      2     2 [{"i" : "c", "j" : "C"}, {"i" : "d", "j" : "D"}]

