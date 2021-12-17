# dm_disambiguate_cols() works as intended

    Code
      dm_for_flatten() %>% dm_disambiguate_cols() %>% dm_paste(options = c("select",
        "keys"))
    Message <simpleMessage>
      Renaming ambiguous columns: %>%
        dm_rename(fact, fact.something = something) %>%
        dm_rename(dim_1, dim_1.something = something) %>%
        dm_rename(dim_2, dim_2.something = something) %>%
        dm_rename(dim_3, dim_3.something = something) %>%
        dm_rename(dim_4, dim_4.something = something)
    Message <cliMessage>
      dm::dm(
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, fact.something) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, dim_1.something) %>%
        dm::dm_select(dim_2, dim_2_pk, dim_2.something) %>%
        dm::dm_select(dim_3, dim_3_pk, dim_3.something) %>%
        dm::dm_select(dim_4, dim_4_pk, dim_4.something) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)

