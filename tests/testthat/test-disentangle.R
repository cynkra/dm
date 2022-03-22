test_that("dm_disentangle() works", {
  # using collect() cause otherwise the `src` is printed on DBs
  # nothing should happen if no cycles are detected
  expect_message(
    expect_equivalent_dm(
      dm_disentangle(dm_for_filter()),
      dm_for_filter()
    ),
    "No cycle detected, returning original `dm`."
  )

  # disentangling for each graph component with a cycle
  expect_message(
    expect_equivalent_dm(
      dm_disentangle(dm_for_filter_w_cycle()),
      dm_for_filter_w_cycle() %>%
        dm_rm_tbl(tf_3) %>%
        dm_add_tbl(tf_3_1 = tf_3(), tf_3_2 = tf_3()) %>%
        dm_add_pk(tf_3_1, c(f, f1)) %>%
        dm_add_pk(tf_3_2, c(f, f1)) %>%
        dm_add_fk(tf_2, c(e, e1), tf_3_1) %>%
        dm_add_fk(tf_4, c(j, j1), tf_3_2)
    ),
    "`tf_3` with `tf_3_1`, `tf_3_2`"
  )

  expect_silent(
    expect_equivalent_dm(
      dm_disentangle(
        dm_bind(
          dm_for_disambiguate(),
          dm_for_filter_w_cycle(),
          dm_nycflights_small_cycle()
        ),
        quiet = TRUE
      ),
      dm_bind(
        dm_for_disambiguate(),
        dm_for_filter_w_cycle(),
        dm_nycflights_small_cycle()
      ) %>%
        dm_rm_tbl(airports) %>%
        dm_add_tbl(
          airports_1 = dm_nycflights_small_cycle()$airports,
          airports_2 = dm_nycflights_small_cycle()$airports
        ) %>%
        dm_add_pk(airports_1, faa) %>%
        dm_add_pk(airports_2, faa) %>%
        dm_add_fk(flights, origin, airports_2) %>%
        dm_add_fk(flights, dest, airports_1) %>%
        dm_rm_tbl(tf_3) %>%
        dm_add_tbl(tf_3_1 = tf_3(), tf_3_2 = tf_3()) %>%
        dm_add_pk(tf_3_1, c(f, f1)) %>%
        dm_add_pk(tf_3_2, c(f, f1)) %>%
        dm_add_fk(tf_2, c(e, e1), tf_3_1) %>%
        dm_add_fk(tf_4, c(j, j1), tf_3_2)
    )
  )

  expect_message(
    expect_equivalent_dm(
      dm_for_filter_w_cycle() %>%
        dm_add_tbl(tf_8 = tf_1()) %>%
        dm_add_fk(tf_8, a, tf_1) %>%
        dm_add_tbl(tf_9 = tf_3()) %>%
        dm_add_fk(tf_9, c(f, f1), tf_3) %>%
        dm_disentangle(),
      dm_for_filter_w_cycle() %>%
        dm_rm_tbl(tf_3) %>%
        dm_add_tbl(tf_8 = tf_1(), tf_9 = tf_3(), tf_3_1 = tf_3(), tf_3_2 = tf_3()) %>%
        dm_add_pk(tf_3_1, c(f, f1)) %>%
        dm_add_pk(tf_3_2, c(f, f1)) %>%
        dm_add_fk(tf_2, c(e, e1), tf_3_1) %>%
        dm_add_fk(tf_8, a, tf_1) %>%
        dm_add_fk(tf_9, c(f, f1), tf_3_1) %>%
        dm_add_fk(tf_4, c(j, j1), tf_3_2)
    ),
    "`tf_3` with `tf_3_1`, `tf_3_2`"
  )

  # special case when only 1 PT-CT pair has multiple simple paths between them
  # and there is NO need to replicate the PT
  expect_equivalent_dm(
    entangled_dm_2() %>%
      dm_disentangle(quiet = TRUE),
    entangled_dm_2() %>%
      dm_rm_tbl(e) %>%
      dm_add_tbl(
        e_1 = tf_5() %>% rename(e = k),
        e_2 = tf_5() %>% rename(e = k)
      ) %>%
      dm_add_pk(e_1, e) %>%
      dm_add_pk(e_2, e) %>%
      dm_add_fk(d, d, e_2) %>%
      dm_add_fk(a, a, e_1)
  )

  # special case only 2 PT-CT pairs have multiple simple paths between them
  # but it can be solved by multiplying the one first that
  # has a directed path leading to it from the other PT
  expect_message(
    expect_equivalent_dm(
      entangled_dm_2() %>%
        dm_add_fk(b, b, e) %>%
        dm_disentangle(),
      entangled_dm_2() %>%
        dm_rm_tbl(e) %>%
        dm_add_tbl(
          e_1 = tf_5() %>% rename(e = k),
          e_2 = tf_5() %>% rename(e = k),
          e_3 = tf_5() %>% rename(e = k)
        ) %>%
        dm_add_pk(e_1, e) %>%
        dm_add_pk(e_2, e) %>%
        dm_add_pk(e_3, e) %>%
        dm_add_fk(a, a, e_1) %>%
        dm_add_fk(b, b, e_2) %>%
        dm_add_fk(d, d, e_3)
    ),
    "`e` with `e_1`, `e_2`, `e_3`"
  )
})

test_that("In case of endless cycles", {
  expect_snapshot({
    dm_disentangle(dm_for_card()) %>% dm_get_all_fks()
    dm_disentangle(
      dm_bind(
        dm_for_card(),
        dm_for_card() %>%
          dm_rename_tbl(dc_1_2 = dc_1, dc_2_2 = dc_2, dc_3_2 = dc_3, dc_4_2 = dc_4, dc_5_2 = dc_5, dc_6_2 = dc_6),
        dm_for_filter()
      )
    ) %>%
      dm_get_all_fks()
  })
})

test_that("test naming templates", {
  expect_message(
    expect_equivalent_dm(
      dm_disentangle(dm_for_filter_w_cycle(), naming_template = ".pt_.ntn"),
      dm_disentangle(dm_for_filter_w_cycle(), quiet = TRUE)
    ),
    "`tf_3` with `tf_3_1`, `tf_3_2`"
  )

  expect_message(
    expect_equivalent_dm(
      dm_disentangle(dm_for_filter_w_cycle(), naming_template = ".pt..pkc_.fkc"),
      dm_disentangle(dm_for_filter_w_cycle(), quiet = TRUE) %>%
        dm_rename_tbl(tf_3.f_f1_e_e1 = tf_3_1) %>%
        dm_rename_tbl(tf_3.f_f1_j_j1 = tf_3_2)
    ),
    "`tf_3` with `tf_3.f_f1_e_e1`, `tf_3.f_f1_j_j1`"
  )

  expect_message(
    expect_equivalent_dm(
      dm_disentangle(dm_for_filter_w_cycle(), naming_template = ".ct_lookup_.ntn"),
      dm_disentangle(dm_for_filter_w_cycle(), quiet = TRUE) %>%
        dm_rename_tbl(tf_2_lookup_1 = tf_3_1) %>%
        dm_rename_tbl(tf_4_lookup_2 = tf_3_2)
    ),
    "`tf_3` with `tf_2_lookup_1`, `tf_4_lookup_2`"
  )
})

test_that("more iterations needed", {
  expect_snapshot({
    entangled_dm() %>%
      dm_disentangle() %>%
      dm_get_all_fks()
    entangled_dm() %>%
      dm_disentangle(naming_template = ".pt_.pkc_.ntn") %>%
      dm_get_all_fks()
  })
})
