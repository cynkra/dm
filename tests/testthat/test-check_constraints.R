nyc_check <- tibble::tribble(
  ~table,    ~kind,   ~column, ~ref_table, ~is_key,   ~problem,
  "flights",  "FK",    "dest", "airports",   FALSE, "<reason>",
  "flights",  "FK", "tailnum",   "planes",   FALSE, "<reason>",
  "airlines", "PK", "carrier",         NA,    TRUE,         "",
  "airports", "PK",     "faa",         NA,    TRUE,         "",
  "planes",   "PK", "tailnum",         NA,    TRUE,         "",
  "flights",  "FK", "carrier", "airlines",    TRUE,         "",
)

test_that("`cdm_check_constraints()` works", {

  # case of no constraints:
  expect_equal(
    cdm_check_constraints(cdm_test_obj),
    tibble(
      table = character(0),
      kind = character(0),
      column = character(0),
      ref_table = character(0),
      is_key = logical(0),
      problem = character(0)
    )
  )

  # case of some constraints, all met:
  walk(
    dm_for_disambiguate_src,
    ~ expect_identical(
      cdm_check_constraints(.),
      tibble(
        table = c("iris_1", "iris_2"),
        kind = c("PK", "FK"),
        column = "key",
        ref_table = c(NA, "iris_1"),
        is_key = TRUE,
        problem = ""
      )
    )
  )

  # case of some constraints, some violated:
  walk(
    dm_nycflights_small_src,
    function(dm_nycflights_small) {
      expect_identical(
        cdm_check_constraints(dm_nycflights_small) %>%
          mutate(problem = if_else(problem == "", "", "<reason>")),
        nyc_check
      )
    }
  )
})
