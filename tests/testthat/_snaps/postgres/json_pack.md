# `json_pack()` works remotely

    Code
      query <- json_pack(remote, a = starts_with("a")) %>% dbplyr::sql_render()
      gsub("test_frame_[_0-9]+", "test_frame_...", query)
    Output
      <SQL> SELECT "grp", JSON_BUILD_OBJECT('a_i', "a_i", 'a_j', "a_j") AS "a"
      FROM "test_frame_..."
    Code
      json_pack(remote, a = starts_with("a"))
    Output
          grp a                         
        <dbl> <pq_json>                 
      1     1 {"a_i" : "a", "a_j" : "A"}
      2     1 {"a_i" : "b", "a_j" : "B"}
      3     2 {"a_i" : "c", "a_j" : "C"}
      4     2 {"a_i" : "d", "a_j" : "D"}
    Code
      query <- json_pack(remote, a = starts_with("a"), .names_sep = "_") %>% dbplyr::sql_render()
      gsub("test_frame_[_0-9]+", "test_frame_...", query)
    Output
      <SQL> SELECT "grp", JSON_BUILD_OBJECT('i', "a_i", 'j', "a_j") AS "a"
      FROM "test_frame_..."
    Code
      json_pack(remote, a = starts_with("a"), .names_sep = "_")
    Output
          grp a                     
        <dbl> <pq_json>             
      1     1 {"i" : "a", "j" : "A"}
      2     1 {"i" : "b", "j" : "B"}
      3     2 {"i" : "c", "j" : "C"}
      4     2 {"i" : "d", "j" : "D"}

