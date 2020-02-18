test_that("output", {
  verify_output("out/examine-constraints.txt", {
    dm_nycflights13() %>% dm_examine_constraints()
    dm_nycflights13(cycle = TRUE) %>% dm_examine_constraints()
    dm_nycflights13(cycle = TRUE) %>%
      dm_select_tbl(-flights) %>%
      dm_examine_constraints()
  })
})
