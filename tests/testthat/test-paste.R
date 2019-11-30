test_that("generating code for creation of existing 'dm' works", {
  expect_output(
    cdm_paste(empty_dm()),
    "dm()",
    fixed = TRUE
  )

  expect_output(
    cdm_paste(dm_for_filter),
    paste0("dm(t1, t2, t3, t4, t5, t6) %>%\n  cdm_add_pk(t1, a) %>%\n  cdm_add_pk(t2, c) %>%",
           "\n  cdm_add_pk(t3, f) %>%\n  cdm_add_pk(t4, h) %>%\n  cdm_add_pk(t5, k) %>%\n  ",
           "cdm_add_pk(t6, n) %>%\n  cdm_add_fk(t2, d, t1) %>%\n  cdm_add_fk(t2, e, t3) %>%\n  ",
           "cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, l, t4) %>%\n  cdm_add_fk(t5, m, t6)"),
    fixed = TRUE
  )

  # changing the tab width
  expect_output(
    cdm_paste(dm_for_filter, FALSE, 4),
    paste0("dm(t1, t2, t3, t4, t5, t6) %>%\n    cdm_add_pk(t1, a) %>%\n    cdm_add_pk(t2, c) %>%",
           "\n    cdm_add_pk(t3, f) %>%\n    cdm_add_pk(t4, h) %>%\n    cdm_add_pk(t5, k) %>%\n    ",
           "cdm_add_pk(t6, n) %>%\n    cdm_add_fk(t2, d, t1) %>%\n    cdm_add_fk(t2, e, t3) %>%\n    ",
           "cdm_add_fk(t4, j, t3) %>%\n    cdm_add_fk(t5, l, t4) %>%\n    cdm_add_fk(t5, m, t6)"),
    fixed = TRUE
  )

  # we don't care if the tables really exist
  expect_output(
    cdm_paste(dm_for_filter %>% cdm_rename_tbl(t1_new = t1)),
    paste0("dm(t1_new, t2, t3, t4, t5, t6) %>%\n  cdm_add_pk(t1_new, a) %>%\n  cdm_add_pk(t2, c) %>%",
           "\n  cdm_add_pk(t3, f) %>%\n  cdm_add_pk(t4, h) %>%\n  cdm_add_pk(t5, k) %>%\n  ",
           "cdm_add_pk(t6, n) %>%\n  cdm_add_fk(t2, d, t1_new) %>%\n  cdm_add_fk(t2, e, t3) %>%\n  ",
           "cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, l, t4) %>%\n  cdm_add_fk(t5, m, t6)"),
    fixed = TRUE
  )

  # produce `cdm_select()` statements in addition to the rest
  expect_output(
    cdm_paste(cdm_select(dm_for_filter, t5, k = k, m) %>% cdm_select(t1, a), select = TRUE),
    paste0("dm(t1, t2, t3, t4, t5, t6) %>%\n  cdm_select(t1, a) %>%\n  cdm_select(t2, c, d, e) %>%\n  ",
    "cdm_select(t3, f, g) %>%\n  cdm_select(t4, h, i, j) %>%\n  cdm_select(t5, k, m) %>%\n  ",
    "cdm_select(t6, n, o) %>%\n  cdm_add_pk(t1, a) %>%\n  cdm_add_pk(t2, c) %>%\n  cdm_add_pk(t3, f) %>%\n  ",
    "cdm_add_pk(t4, h) %>%\n  cdm_add_pk(t5, k) %>%\n  cdm_add_pk(t6, n) %>%\n  cdm_add_fk(t2, d, t1) %>%\n  ",
    "cdm_add_fk(t2, e, t3) %>%\n  cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, m, t6)"),
    fixed = TRUE)

})
