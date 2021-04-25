test_that("API", {
  expect_identical(
    color_quos_to_display(
      flights = "blue",
      airlines = ,
      airports = "orange",
      planes = "green_nb"
    ),
    set_names(
      c("flights", "airlines", "airports", "planes"),
      c("blue", "orange", "orange", "green_nb")
    )
  )
})

test_that("`dm_set_colors()` works", {
  skip_if_not_installed("nycflights13")

  expect_identical(
    dm_set_colors(
      dm_nycflights_small(),
      blue = starts_with("air"),
      green = contains("h")
    ) %>%
      dm_get_colors(),
    set_names(
      src_tbls(dm_nycflights_small()),
      c("#00FF00FF", "default", "#0000FFFF", "#0000FFFF", "#00FF00FF")
    )
  )

  # test splicing
  colset <- c(blue = "flights", green = "airports")

  expect_identical(
    dm_set_colors(
      dm_nycflights_small(),
      !!!colset
    ) %>%
      dm_get_colors(),
    set_names(
      src_tbls(dm_nycflights_small()),
      c("#0000FFFF", "default", "default", "#00FF00FF", "default")
    )
  )
})

test_that("`dm_set_colors()` errors if old syntax used", {
  skip_if_not_installed("nycflights13")
  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      airports = ,
      airlines = "blue",
      flights = ,
      weather = "green"
    ),
    class = "wrong_syntax_set_cols"
  )
})

test_that("`dm_set_colors()` errors with unnamed args", {
  skip_if_not_installed("nycflights13")
  skip_if_src("postgres")

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      airports
    ),
    class = "only_named_args"
  )
})

test_that("last", {
  expect_dm_error(
    color_quos_to_display(
      flights = "blue",
      airlines =
      ),
    class = "last_col_missing"
  )
})

test_that("bad color", {
  skip_if_not(getRversion() >= "3.5")
  skip_if_not_installed("nycflights13")

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      "zzz-bogus" = flights
    ),
    class = "cols_not_avail"
  )
})

test_that("getter", {
  skip_if_src("postgres")
  skip_if_not_installed("nycflights13")

  expect_equal(
    dm_get_colors(dm_nycflights13()),
    c(
      "#ED7D31FF" = "airlines",
      "#ED7D31FF" = "airports",
      "#5B9BD5FF" = "flights",
      "#ED7D31FF" = "planes",
      "#70AD47FF" = "weather"
    )
  )
})

test_that("datamodel-code for drawing", {
  data_model_for_filter <- dm_get_data_model(dm_for_filter(), "column")

  expect_s3_class(
    data_model_for_filter,
    "data_model"
  )

  expect_identical(
    map(data_model_for_filter, nrow),
    list(tables = 6L, columns = 15L, references = 5L)
  )
})

test_that("get available colors", {
  expect_length(
    dm_get_available_colors(),
    length(colors()) + 1
  )
})

test_that("helpers", {
  expect_identical(
    dm_get_all_columns(dm_for_filter()),
    tibble::tribble(
      ~table, ~column, ~id,
      "tf_1",     "a",  1L,
      "tf_1",     "b",  2L,
      "tf_2",     "c",  1L,
      "tf_2",     "d",  2L,
      "tf_2",     "e",  3L,
      "tf_3",     "f",  1L,
      "tf_3",     "g",  2L,
      "tf_4",     "h",  1L,
      "tf_4",     "i",  2L,
      "tf_4",     "j",  3L,
      "tf_5",     "k",  1L,
      "tf_5",     "l",  2L,
      "tf_5",     "m",  3L,
      "tf_6",     "n",  1L,
      "tf_6",     "o",  2L,
    )
  )

  expect_identical(
    dm_get_all_column_types(dm_for_filter()),
    tibble::tribble(
      ~table, ~column, ~id, ~type,
      "tf_1",     "a",  1L, "int",
      "tf_1",     "b",  2L, "chr",
      "tf_2",     "c",  1L, "chr",
      "tf_2",     "d",  2L, "int",
      "tf_2",     "e",  3L, "chr",
      "tf_3",     "f",  1L, "chr",
      "tf_3",     "g",  2L, "chr",
      "tf_4",     "h",  1L, "chr",
      "tf_4",     "i",  2L, "chr",
      "tf_4",     "j",  3L, "chr",
      "tf_5",     "k",  1L, "int",
      "tf_5",     "l",  2L, "chr",
      "tf_5",     "m",  3L, "chr",
      "tf_6",     "n",  1L, "chr",
      "tf_6",     "o",  2L, "chr",
    )
  )
})

test_that("output", {
  skip_if_not_installed("DiagrammeRsvg")
  skip_if_not_installed("nycflights13")

  path <- tempfile(fileext = ".svg")

  dm_nycflights13() %>%
    dm_draw() %>%
    DiagrammeRsvg::export_svg() %>%
    writeLines(path)

  expect_snapshot_file(path, "nycflight-dm.svg", binary = FALSE)

  # Multi-fk (#37)
  dm_nycflights13() %>%
    dm_zoom_to(planes) %>%
    dm_insert_zoomed("planes_copy") %>%
    dm_draw() %>%
    DiagrammeRsvg::export_svg() %>%
    writeLines(path)

  expect_snapshot_file(path, "nycflight-dm-copy.svg", binary = FALSE)
})
