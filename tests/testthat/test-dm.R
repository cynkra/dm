test_that("can access tables", {
  expect_identical(tbl(cdm_nycflights13(), "airlines"), nycflights13::airlines)
  expect_cdm_error(
    tbl(cdm_nycflights13(), "x"),
    class = "table_not_in_dm"
  )
})

test_that("can create dm with as_dm()", {
  test_obj_df <- as_dm(cdm_get_tables(cdm_test_obj))

  walk(
    cdm_test_obj_src, ~ expect_equivalent_dm(as_dm(cdm_get_tables(.)), test_obj_df)
  )
})

test_that("creation of empty `dm` works", {
  expect_true(
    is_empty(dm())
  )

  expect_true(
    is_empty(new_dm())
  )
})

test_that("'compute.dm()' computes tables on DB", {
    db_src_names <- setdiff(src_names, c("df"))
    skip_if(is_empty(db_src_names))
    walk(
      db_src_names,
      ~expect_true({
          def <- dm_for_filter_src[[.x]] %>% cdm_filter(t1, a > 3) %>% compute() %>% cdm_get_def()
          test <- map_chr(map(def$data, sql_render), as.character)
          all(map_lgl(test, ~ !str_detect(., "WHERE")))})
      )
})
