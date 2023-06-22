test_that("datamodel-code for drawing", {
  local_options(max.print = 10000)

  expect_snapshot({
    dm_get_data_model(dm_for_filter())
    dm_get_data_model(dm_for_filter(), column_types = TRUE)
  })
})

test_that("snapshot test for datamodelr code", {
  dm <- dm_nycflights13(cycle = TRUE)
  data_model <- dm_get_data_model(dm)

  path <- tempfile(fileext = ".dot")
  writeLines(bdm_create_graph(data_model)$dot_code, path)

  expect_snapshot_file(path, "nycflights13.dot")
})

test_that("snapshot test 2 for datamodelr code", {
  dm <- dm_nycflights13(cycle = TRUE)
  data_model <- dm_get_data_model(dm)

  path <- tempfile(fileext = ".dot")
  writeLines(
    bdm_create_graph(
      data_model,
      table_description = list(
        "flights" = "Flüge",
        "planes" = "Flugzeuge\nl'avion\nel & <\"avión flying in the sky\">"
      )
    )$dot_code,
    path
  )

  expect_snapshot_file(path, "nycflights13_table_desc_1.dot")
})

test_that("snapshot test 3 for datamodelr code", {
  dm <- dm_nycflights13(cycle = TRUE)
  data_model <- dm_get_data_model(dm)

  path <- tempfile(fileext = ".dot")
  writeLines(
    bdm_create_graph(
      data_model,
      table_description = list(
        "flights" = "Flüge",
        "planes" = "Flugzeuge\nl'avion\nel & <\"avión flying in the sky\">"
      ),
      font_size_table_description = 10L
    )$dot_code,
    path
  )

  expect_snapshot_file(path, "nycflights13_table_desc_2.dot")
})

test_that("snapshot test 4 for datamodelr code", {
  dm <- dm_nycflights13(cycle = TRUE) %>%
    dm_add_uk(weather, time_hour)
  data_model <- dm_get_data_model(dm)

  path <- tempfile(fileext = ".dot")
  writeLines(
    bdm_create_graph(
      data_model,
      table_description = list(
        "flights" = "Flüge",
        "planes" = "Flugzeuge\nl'avion\nel & <\"avión flying in the sky\">"
      ),
      font_size_table_description = 10L
    )$dot_code,
    path
  )

  expect_snapshot_file(path, "nycflights13_draw_uk_1.dot")
})

test_that("snapshot test 5 for datamodelr code", {
  dm <- dm_nycflights13(cycle = TRUE) %>%
    dm_add_fk(flights, time_hour, weather, time_hour)
  data_model <- dm_get_data_model(dm)

  path <- tempfile(fileext = ".dot")
  writeLines(
    bdm_create_graph(
      data_model,
      table_description = list(
        "flights" = "Flüge",
        "planes" = "Flugzeuge\nl'avion\nel & <\"avión flying in the sky\">"
      ),
      font_size_table_description = 10L
    )$dot_code,
    path
  )

  expect_snapshot_file(path, "nycflights13_draw_uk_2.dot")
})




test_that("snapshot test for weird data models", {
  dm <- dm("a b" = tibble(`c d` = 1)) %>%
    dm_add_pk(`a b`, `c d`)

  data_model <- dm_get_data_model(dm)

  path <- tempfile(fileext = ".dot")
  writeLines(bdm_create_graph(data_model)$dot_code, path)

  expect_snapshot_file(path, "weird.dot")
})
