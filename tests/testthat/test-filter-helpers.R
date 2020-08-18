test_that("dm_nrow() works?", {
  expect_identical(
    as.integer(sum(dm_nrow(dm_test_obj()))),
    rows_dm_obj
  )
})

verify_output("out/filter-helpers-compound.txt", {
  dm_nycflights13() %>%
    dm_add_pk(weather, c(origin, time_hour)) %>%
    dm_add_fk(flights, c(origin, time_hour), weather) %>%
    dm_flatten_to_tbl(flights)
})
