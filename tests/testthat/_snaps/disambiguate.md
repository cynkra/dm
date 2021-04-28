# dm_disambiguate_cols() works as intended

    Code
      dm_for_flatten() %>% dm_disambiguate_cols() %>% dm_paste(options = c("select",
        "keys"))
    Message <simpleMessage>
      Renamed columns:
      * something -> fact.something, dim_1.something, dim_2.something, dim_3.something, dim_4.something
    Message <cliMessage>
      dm::dm(fact, dim_1, dim_2, dim_3, dim_4) %>%
        dm::dm_select(fact, fact, dim_1_key, dim_2_key, dim_3_key, dim_4_key, fact.something) %>%
        dm::dm_select(dim_1, dim_1_pk, dim_1.something) %>%
        dm::dm_select(dim_2, dim_2_pk, dim_2.something) %>%
        dm::dm_select(dim_3, dim_3_pk, dim_3.something) %>%
        dm::dm_select(dim_4, dim_4_pk, dim_4.something) %>%
        dm::dm_add_pk(dim_1, dim_1_pk) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(fact, dim_1_key, dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)

