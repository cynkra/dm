nyc_check <- tibble::tribble(
  ~table,     ~kind,   ~column,   ~is_key,  ~problem,
  "flights",  "FK",    "dest",    FALSE,    "<reason>",
  "flights",  "FK",    "tailnum", FALSE,    "<reason>",
  "airlines", "PK",    "carrier", TRUE,     "",
  "airports", "PK",    "faa",     TRUE,     "",
  "planes",   "PK",    "tailnum", TRUE,     "",
  "flights",  "FK",    "carrier", TRUE,     ""
)

test_that("`cdm_check_constraints()` works", {

  walk(
    dm_nycflights_small_src,
    ~ expect_identical(
      cdm_check_constraints(.) %>%
        mutate(problem = if_else(problem == "", "", "<reason>")),
      nyc_check
      )
    )

  walk(
    dm_for_disambiguate_src,
    ~ expect_identical(
      cdm_check_constraints(.),
      tibble(table = c("iris_1", "iris_2"),
             kind = c("PK", "FK"),
             column = "key",
             is_key = TRUE,
             problem = "")
      )
    )
})
