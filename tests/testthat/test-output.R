test_that("output", {
  verify_output("out/output.txt", {
    dm_nycflights13(cycle = TRUE)

    dm_nycflights13(cycle = TRUE) %>%
      dm_filter(flights, origin == "EWR")

    dm_nycflights13(cycle = TRUE) %>%
      dm_examine_constraints() %>%
      as_tibble()
  })
})
