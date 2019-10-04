nyc_check <- tibble::tribble(
  ~table,     ~kind,   ~column,   ~is_key,  ~problem,
  "flights",  "FK",    "tailnum", FALSE,    "<reason>",
  "airlines", "PK",    "carrier", TRUE,     "",
  "airports", "PK",    "faa",     TRUE,     "",
  "planes",   "PK",    "tailnum", TRUE,     "",
  "flights",  "FK",    "carrier", TRUE,     "",
  "flights",  "FK",    "origin",  TRUE,     ""
)

test_that("`cdm_check_constraints()` works", {
  expect_equal(
    cdm_check_constraints(cdm_nycflights13()) %>%
      mutate(problem = if_else(problem == "", "", "<reason>")),
    nyc_check
  )

  expect_equal(
    cdm_check_constraints(dm_for_disambiguate),
    tibble(table = c("iris_1", "iris_2"),
           kind = c("PK", "FK"),
           column = "key",
           is_key = TRUE,
           problem = "")
  )
})
