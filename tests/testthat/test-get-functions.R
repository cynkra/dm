active_srcs <- tibble(src = names(dbplyr:::test_srcs$get()))
lookup <- tibble(
  src = c("df", "sqlite", "postgres", "mssql"),
  class_src = c("src_local", "src_SQLiteConnection", "src_PqConnection", "src_Microsoft SQL Server"),
  class_con = c(NA_character_, "SQLiteConnection", "PqConnection", "Microsoft SQL Server")
)

test_that("cdm_get_src() works", {
  active_srcs_class <- semi_join(lookup, active_srcs, by = "src") %>% pull(class_src)

  walk2(
    dm_for_filter_src,
    active_srcs_class,
    ~expect_true(inherits(cdm_get_src(.x), .y))
  )
})

test_that("cdm_get_con() works", {

  expect_error(
    cdm_get_con(dm_for_filter),
    class = cdm_error("no_con_if_local")
  )

  active_con_class <- semi_join(lookup, filter(active_srcs, src != "df"), by = "src") %>% pull(class_con)
  dm_for_filter_src_red <- dm_for_filter_src[!(names(dm_for_filter_src) == "df")]

  walk2(
    dm_for_filter_src_red,
    active_con_class,
    ~expect_true(inherits(cdm_get_con(.x), .y))
  )
})
