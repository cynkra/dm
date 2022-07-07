test_that("datamodel-code for drawing", {
  local_options(max.print = 10000)

  expect_snapshot({
    dm_get_data_model(dm_for_filter())
    dm_get_data_model(dm_for_filter(), column_types = TRUE)
  })
})

test_that("snapshot test for datamodelr code", {
  data_model <- dm_get_data_model(dm_nycflights13(cycle = TRUE))

  path <- tempfile(fileext = ".dot")
  writeLines(bdm_create_graph(data_model)$dot_code, path)

  expect_snapshot_file(path, "nycflights13.dot")
})
