nyc_check <- tibble::tribble(
  ~table, ~kind, ~columns, ~ref_table, ~is_key, ~problem,
  "flights", "FK", "dest", "airports", FALSE, "<reason>",
  "flights", "FK", "tailnum", "planes", FALSE, "<reason>",
  "airlines", "PK", "carrier", NA, TRUE, "",
  "airports", "PK", "faa", NA, TRUE, "",
  "planes", "PK", "tailnum", NA, TRUE, "",
  "flights", "FK", "carrier", "airlines", TRUE, "",
) %>%
  mutate(columns = new_keys(columns)) %>%
  new_dm_examine_constraints()

test_that("`dm_examine_constraints()` works", {

  # case of no constraints:
  expect_identical(
    dm_examine_constraints(dm_test_obj),
    tibble(
      table = character(0),
      kind = character(0),
      columns = new_keys(character()),
      ref_table = character(0),
      is_key = logical(0),
      problem = character(0)
    ) %>%
      new_dm_examine_constraints()
  )

  # case of some constraints, all met:
  walk(
    dm_for_disambiguate_src,
    ~ expect_identical(
      dm_examine_constraints(.),
      tibble(
        table = c("iris_1", "iris_2"),
        kind = c("PK", "FK"),
        columns = new_keys("key"),
        ref_table = c(NA, "iris_1"),
        is_key = TRUE,
        problem = ""
      ) %>%
        new_dm_examine_constraints()
    )
  )

  # case of some constraints, some violated:
  walk(
    dm_nycflights_small_src,
    function(dm_nycflights_small) {
      expect_identical(
        dm_examine_constraints(dm_nycflights_small) %>%
          mutate(problem = if_else(problem == "", "", "<reason>")),
        nyc_check
      )
    }
  )
})

test_that("output", {
  verify_output("out/examine-constraints.txt", {
    dm_nycflights13() %>% dm_examine_constraints()
    dm_nycflights13(cycle = TRUE) %>% dm_examine_constraints()
    dm_nycflights13(cycle = TRUE) %>%
      dm_select_tbl(-flights) %>%
      dm_examine_constraints()
  })
})

test_that("output as tibble", {
  verify_output("out/examine-constraints-as-tibble.txt", {
    dm_nycflights13(cycle = TRUE) %>%
      dm_examine_constraints() %>%
      as_tibble()
  })
})
