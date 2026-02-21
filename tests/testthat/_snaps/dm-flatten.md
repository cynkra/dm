# `dm_flatten()` snapshot with `dm_paste()`

    Code
      dm_flatten(dm_for_flatten(), fact) %>% dm_paste(options = c("select", "keys"))
    Message
      Renaming ambiguous columns: %>%
        dm_rename(dim_1, something.dim_1 = something) %>%
        dm_rename(dim_2, something.dim_2 = something) %>%
        dm_rename(dim_3, something.dim_3 = something) %>%
        dm_rename(dim_4, something.dim_4 = something)
      dm::dm(
        fact,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something, something.dim_1, something.dim_2, something.dim_3, something.dim_4)

---

    Code
      dm_flatten(dm_for_flatten(), fact, parent_tables = c(dim_1, dim_2)) %>%
        dm_paste(options = c("select", "keys"))
    Message
      Renaming ambiguous columns: %>%
        dm_rename(dim_1, something.dim_1 = something) %>%
        dm_rename(dim_2, something.dim_2 = something)
      dm::dm(
        fact,
        dim_3,
        dim_4,
      ) %>%
        dm::dm_select(fact, fact, dim_1_key_1, dim_1_key_2, dim_2_key, dim_3_key, dim_4_key, something, something.dim_1, something.dim_2) %>%
        dm::dm_select(dim_3, dim_3_pk, something) %>%
        dm::dm_select(dim_4, dim_4_pk, something) %>%
        dm::dm_add_pk(dim_3, dim_3_pk) %>%
        dm::dm_add_pk(dim_4, dim_4_pk) %>%
        dm::dm_add_fk(fact, dim_3_key, dim_3) %>%
        dm::dm_add_fk(fact, dim_4_key, dim_4)

# `dm_flatten()` recursive snapshot with `dm_paste()`

    Code
      dm_flatten(dm_more_complex(), tf_5, parent_tables = c(tf_4, tf_3), recursive = TRUE) %>%
        dm_paste(options = c("select", "keys"))
    Message
      dm::dm(
        tf_1,
        tf_2,
        tf_5,
        tf_6,
        tf_7,
        tf_6_2,
        tf_4_2,
        a,
        b,
        c,
        d,
        e,
      ) %>%
        dm::dm_select(tf_1, a, b) %>%
        dm::dm_select(tf_2, c, d, e, e1) %>%
        dm::dm_select(tf_5, ww, k, l, m, i, j, j1, g) %>%
        dm::dm_select(tf_6, zz, n, o) %>%
        dm::dm_select(tf_7, p, q) %>%
        dm::dm_select(tf_6_2, p, f, f1) %>%
        dm::dm_select(tf_4_2, r, s, t) %>%
        dm::dm_select(a, a_1, a_2) %>%
        dm::dm_select(b, b_1, b_2, b_3) %>%
        dm::dm_select(c, c_1) %>%
        dm::dm_select(d, d_1, b_1) %>%
        dm::dm_select(e, e_1, b_1) %>%
        dm::dm_add_pk(tf_1, a) %>%
        dm::dm_add_pk(tf_2, c) %>%
        dm::dm_add_pk(tf_5, k) %>%
        dm::dm_add_pk(tf_6, n) %>%
        dm::dm_add_pk(tf_6_2, p) %>%
        dm::dm_add_pk(tf_4_2, r) %>%
        dm::dm_add_pk(a, a_1) %>%
        dm::dm_add_pk(b, b_1) %>%
        dm::dm_add_pk(c, c_1) %>%
        dm::dm_add_pk(d, d_1) %>%
        dm::dm_add_pk(e, e_1) %>%
        dm::dm_add_fk(tf_2, d, tf_1) %>%
        dm::dm_add_fk(tf_5, m, tf_6) %>%
        dm::dm_add_fk(tf_5, l, tf_4_2) %>%
        dm::dm_add_fk(b, b_2, a) %>%
        dm::dm_add_fk(d, b_1, b) %>%
        dm::dm_add_fk(e, b_1, b) %>%
        dm::dm_add_fk(b, b_3, c)

# `dm_flatten()` allow_deep snapshot with `dm_paste()`

    Code
      dm_flatten(dm_deep, A, allow_deep = TRUE) %>% dm_paste(options = c("select",
        "keys"))
    Message
      dm::dm(
        A,
        C,
      ) %>%
        dm::dm_select(A, id, b_id, val_a, c_id, val_b) %>%
        dm::dm_select(C, id, val_c) %>%
        dm::dm_add_pk(C, id) %>%
        dm::dm_add_fk(A, c_id, C)

