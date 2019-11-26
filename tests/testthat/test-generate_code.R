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
           "cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, l, t4) %>%\n  cdm_add_fk(t5, m, t6) "),
    fixed = TRUE
  )

  # `t1_new` does not exist in environment, so a warning is issued
  expect_warning(
    expect_output(
      cdm_paste(dm_for_filter %>% cdm_rename_tbl(t1_new = t1)),
      paste0("dm(t1_new, t2, t3, t4, t5, t6) %>%\n  cdm_add_pk(t1_new, a) %>%\n  cdm_add_pk(t2, c) %>%",
             "\n  cdm_add_pk(t3, f) %>%\n  cdm_add_pk(t4, h) %>%\n  cdm_add_pk(t5, k) %>%\n  ",
             "cdm_add_pk(t6, n) %>%\n  cdm_add_fk(t2, d, t1_new) %>%\n  cdm_add_fk(t2, e, t3) %>%\n  ",
             "cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, l, t4) %>%\n  cdm_add_fk(t5, m, t6) "),
      fixed = TRUE
    )
  )

  # if `select = TRUE` it wants to compare column names, but it can't for `t1_new`, so skipping comparisons and warning about it
  # in addition it still warns about not finding table `t1_new` (warnings[1])
  warnings <- capture_warnings(expect_output(cdm_paste(dm_for_filter %>% cdm_rename_tbl(t1_new = t1), select = TRUE)))
  expect_match(
    warnings[1],
    "The following tables do not exist"
  )
  expect_match(
    warnings[2],
    "Ignoring `select = TRUE`"
  )

  # produce `cdm_select()` statements in addition to the rest
  expect_output(
    cdm_paste(cdm_select(dm_for_filter, t5, k = k, m) %>% cdm_select(t1, a), select = TRUE),
    paste0("dm(t1, t2, t3, t4, t5, t6) %>%\n  cdm_select(t1, a) %>%\n  cdm_select(t5, k, m) %>%\n  cdm_add_pk(t1, a) %>%",
           "\n  cdm_add_pk(t2, c) %>%\n  cdm_add_pk(t3, f) %>%\n  cdm_add_pk(t4, h) %>%\n  cdm_add_pk(t5, k) %>%",
           "\n  cdm_add_pk(t6, n) %>%\n  cdm_add_fk(t2, d, t1) %>%\n  cdm_add_fk(t2, e, t3) %>%",
           "\n  cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, m, t6) "),
    fixed = TRUE)

  expect_warning(
    expect_output(
      cdm_paste(cdm_zoom_to_tbl(dm_for_filter, t1) %>% mutate(a_new = a) %>% cdm_update_zoomed_tbl(), select = TRUE),
      paste0("dm(t1, t2, t3, t4, t5, t6) %>%\n  cdm_add_pk(t1, a) %>%\n  cdm_add_pk(t2, c) %>%",
             "\n  cdm_add_pk(t3, f) %>%\n  cdm_add_pk(t4, h) %>%\n  cdm_add_pk(t5, k) %>%\n  ",
             "cdm_add_pk(t6, n) %>%\n  cdm_add_fk(t2, d, t1) %>%\n  cdm_add_fk(t2, e, t3) %>%\n  ",
             "cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, l, t4) %>%\n  cdm_add_fk(t5, m, t6) "),
      fixed = TRUE
    )
  )

  expect_warning(
    expect_output(cdm_paste(dm_for_filter, env = new_environment())),
    "The following tables do not exist",
    fixed = TRUE
  )

  skip_if_not("postgres" %in% src_names)
  expect_warning(
    expect_output(
      cdm_paste(dm_for_filter_src$postgres),
      paste0("dm(t1, t2, t3, t4, t5, t6) %>%\n  cdm_add_pk(t1, a) %>%\n  cdm_add_pk(t2, c) %>%",
             "\n  cdm_add_pk(t3, f) %>%\n  cdm_add_pk(t4, h) %>%\n  cdm_add_pk(t5, k) %>%\n  ",
             "cdm_add_pk(t6, n) %>%\n  cdm_add_fk(t2, d, t1) %>%\n  cdm_add_fk(t2, e, t3) %>%\n  ",
             "cdm_add_fk(t4, j, t3) %>%\n  cdm_add_fk(t5, l, t4) %>%\n  cdm_add_fk(t5, m, t6) "),
      fixed = TRUE
    ),
    "Tables with the same names as",
    fixed = TRUE
  )

})
