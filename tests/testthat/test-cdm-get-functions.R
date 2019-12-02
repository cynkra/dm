active_srcs <- tibble(src = names(dbplyr:::test_srcs$get()))
lookup <- tibble(
  src = c("df", "sqlite", "postgres", "mssql"),
  class_src = c("src_local", "src_SQLiteConnection", "src_PqConnection", "src_Microsoft SQL Server"),
  class_con = c(NA_character_, "SQLiteConnection", "PqConnection", "Microsoft SQL Server")
)

test_that("cdm_get_src() works", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))

  expect_cdm_error(
    cdm_get_src(1),
    class = "is_not_dm"
  )

  active_srcs_class <- semi_join(lookup, active_srcs, by = "src") %>% pull(class_src)

  walk2(
    dm_for_filter_src,
    active_srcs_class,
    function(dm_for_filter, active_src) {
      expect_true(inherits(cdm_get_src(dm_for_filter), active_src))
    }
  )
})

test_that("cdm_get_con() works", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_cdm_error(
    cdm_get_con(1),
    class = "is_not_dm"
  )

  expect_cdm_error(
    cdm_get_con(dm_for_filter),
    class = "con_only_for_dbi"
  )

  active_con_class <- semi_join(lookup, filter(active_srcs, src != "df"), by = "src") %>% pull(class_con)
  dm_for_filter_src_red <- dm_for_filter_src[!(names(dm_for_filter_src) == "df")]

  walk2(
    dm_for_filter_src_red,
    active_con_class,
    ~ expect_true(inherits(cdm_get_con(.x), .y))
  )
})


test_that("cdm_get_tables() works", {
  withr::local_options(c(lifecycle_verbosity = "quiet"))
  expect_identical(
    cdm_get_tables(dm_for_filter),
    dm_get_tables(dm_for_filter)
  )
})
