# dm_disambiguate_cols() works as intended

    Code
      dm_for_flatten() %>% dm_disambiguate_cols() %>% dm_paste(options = c("select",
        "keys"))
    Message
      Renaming ambiguous columns: %>%
        dm_rename(fact, something.fact = something) %>%
        dm_rename(dim_1, something.dim_1 = something) %>%
        dm_rename(dim_2, something.dim_2 = something) %>%
        dm_rename(dim_3, something.dim_3 = something) %>%
        dm_rename(dim_4, something.dim_4 = something)
      dm::dm(
        fact,
        dim_1,
        dim_2,
        dim_3,
        dim_4,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something.fact) %>%
        dm::dm_select(dim_1, dim_1_pk_1, dim_1_pk_2, something.dim_1) %>%
        dm::dm_select(dim_2, dim_2_pk, something.dim_2) %>%
        dm::dm_select(dim_3, dim_3_pk, something.dim_3) %>%
        dm::dm_select(dim_4, dim_4_pk, something.dim_4) %>%
        dm::dm_add_pk(dim_1, c(dim_1_pk_1, dim_1_pk_2)) %>%
        dm::dm_add_pk(dim_2, dim_2_pk) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(fact, c(dim_1_key_1, dim_1_key_2), dim_1) %>%
        dm::dm_add_fk(fact, dim_2_key, dim_2) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)

