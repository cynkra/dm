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
  expect_snapshot({
    dm_nycflights_small() %>%
      dm_set_colors(
        blue = starts_with("air"),
        green = contains("h")
      ) %>%
      dm_get_colors()
  })

  skip_if_not_installed("testthat", "3.1.1")

  colset <- c(blue = "flights", green = "airports")

  # test splicing
  expect_snapshot(
    variant = if (packageVersion("testthat") > "3.1.0") "testthat-new" else "testthat-legacy",
    {
      dm_nycflights_small() %>%
        dm_set_colors(!!!colset) %>%
        dm_get_colors()
    }
  )
})

test_that("`dm_set_colors()` errors if old syntax used", {
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

  expect_dm_error(
    dm_set_colors(
      dm_nycflights_small(),
      "zzz-bogus" = flights
    ),
    class = "cols_not_avail"
  )
})

test_that("getter", {
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

test_that("get available colors", {
  expect_length(
    dm_get_available_colors(),
    length(colors()) + 1
  )
})

test_that("helpers", {
  expect_snapshot({
    dm_get_all_columns(dm_for_filter())
  })

  expect_snapshot({
    dm_get_all_column_types(dm_for_filter())
  })
})

test_that("output", {
  skip_if_not_installed("testthat", "3.1.1")

  # 444: types
  expect_snapshot_diagram(
    dm_nycflights13() %>%
      dm_draw(column_types = TRUE),
    "nycflight-dm-types.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights13(cycle = TRUE) %>%
      dm_zoom_to(planes) %>%
      # Multi-fk (#37)
      dm_insert_zoomed("planes_copy") %>%
      # Loose table
      dm(loose = tibble(a = 1)) %>%
      # Non-default fk (#402)
      dm(agency = tibble(airline_name = character())) %>%
      dm_add_fk(agency, airline_name, airlines, name) %>%
      dm_draw(),
    "nycflight-dm.svg"
  )

  # empty table corner cases
  expect_snapshot_diagram(
    dm(a = tibble()) %>%
      dm_draw(),
    "single-empty-table-dm.svg"
  )

  expect_snapshot_diagram(
    dm(x = tibble(a = 1), y = tibble(b = 1), a = tibble()) %>%
      dm_draw(view_type = "all"),
    "empty-table-in-dm.svg"
  )
})

test_that("table_description works", {
  expect_error(dm_set_table_description(dm_nycflights_small(), "flight" = "Flüge"))
  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(),
    "table-desc-1-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(backend_opts = list(font_size = list(table_description = 6L))),
    "table-desc-2-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(
        backend_opts = list(font_size = c(table_description = 6L, header = 19L, column = 14L))
      ),
    "table-desc-3-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights13(table_description = TRUE) %>%
      dm_draw(
        backend_opts = list(font_size = c(table_description = 6L, header = 19L, column = 14L))
      ),
    "table-desc-4-dm.svg"
  )
})

test_that("UK support works", {
  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_add_uk(weather, time_hour) %>%
      dm_set_table_description("high in the sky\nflying from NY" = flights) %>%
      dm_draw(view_type = "all"),
    "table-uk-1-dm.svg"
  )

  expect_snapshot_diagram(
    dm_nycflights_small() %>%
      dm_add_fk(flights, time_hour, weather, time_hour) %>%
      dm_set_table_description("Wetter\npogoda" = weather) %>%
      dm_draw(),
    "table-uk-2-dm.svg"
  )
})

test_that("g6R backend renders correctly", {
  skip_if_not_installed("g6R")

  w <- dm_nycflights13() |> dm_draw(backend = "g6R")
  expect_s3_class(w, "g6")
  expect_equal(length(w$x$data$nodes), 5)
  expect_equal(length(w$x$data$edges), 4)

  # node ids match table names
  node_ids <- vapply(w$x$data$nodes, `[[`, character(1), "id")
  expect_setequal(node_ids, c("airlines", "airports", "flights", "planes", "weather"))
})

test_that("g6R backend view_type options work", {
  skip_if_not_installed("g6R")

  # keys_only: only key columns visible
  w_keys <- dm_nycflights13() |> dm_draw(backend = "g6R", view_type = "keys_only")
  airlines_node <- Filter(function(n) n$id == "airlines", w_keys$x$data$nodes)[[1]]
  expect_true(nchar(airlines_node$data$columns) > 0)

  # title_only: no columns shown
  w_title <- dm_nycflights13() |> dm_draw(backend = "g6R", view_type = "title_only")
  airlines_title_node <- Filter(function(n) n$id == "airlines", w_title$x$data$nodes)[[1]]
  expect_equal(airlines_title_node$data$columns, "")

  # all: all columns shown
  w_all <- dm_nycflights13() |> dm_draw(backend = "g6R", view_type = "all")
  flights_node <- Filter(function(n) n$id == "flights", w_all$x$data$nodes)[[1]]
  # flights has more columns in 'all' than 'keys_only'
  n_cols_all <- length(strsplit(flights_node$data$columns, "<br/>")[[1]])
  flights_keys <- Filter(function(n) n$id == "flights", w_keys$x$data$nodes)[[1]]
  n_cols_keys <- length(strsplit(flights_keys$data$columns, "<br/>")[[1]])
  expect_gt(n_cols_all, n_cols_keys)
})

test_that("g6R backend applies colors from dm_set_colors()", {
  skip_if_not_installed("g6R")

  w <- dm_nycflights13() |> dm_draw(backend = "g6R")
  node_colors <- vapply(
    w$x$data$nodes,
    function(n) n$data$color,
    character(1)
  )
  names(node_colors) <- vapply(w$x$data$nodes, `[[`, character(1), "id")

  # flights is blue (#5B9BD5FF -> #5B9BD5), airlines/airports/planes orange
  expect_match(node_colors[["flights"]], "^#[0-9A-Fa-f]{6}$")
  expect_match(node_colors[["airlines"]], "^#[0-9A-Fa-f]{6}$")
  # flights and airlines have different colors
  expect_false(node_colors[["flights"]] == node_colors[["airlines"]])
})

test_that("g6R backend supports column_types", {
  skip_if_not_installed("g6R")

  w <- dm_nycflights13() |> dm_draw(backend = "g6R", column_types = TRUE)
  expect_s3_class(w, "g6")
  # When column_types=TRUE, column HTML should contain type info (span tags)
  airlines_node <- Filter(function(n) n$id == "airlines", w$x$data$nodes)[[1]]
  expect_true(grepl("<span", airlines_node$data$columns))
})

test_that("g6R backend escapes HTML in table/column names", {
  skip_if_not_installed("g6R")

  dm_xss <- dm(
    `<script>` = tibble::tibble(`a&b` = 1L, `c<d>` = "x")
  )
  w <- dm_xss |> dm_draw(backend = "g6R", view_type = "all")
  node <- w$x$data$nodes[[1]]
  # Table name should be escaped in the display name
  expect_false(grepl("<script>", node$data$name, fixed = TRUE))
  expect_true(grepl("&lt;script&gt;", node$data$name, fixed = TRUE))
  # Column names should be escaped
  expect_false(grepl("<d>", node$data$columns, fixed = TRUE))
  expect_true(grepl("&lt;d&gt;", node$data$columns, fixed = TRUE))
})

test_that("DiagrammeR-specific options are soft-deprecated", {
  skip_if_not_installed("DiagrammeR")

  expect_snapshot({
    dm_nycflights13() |>
      dm_draw(graph_attrs = "rankdir=LR") |>
      invisible()
  })

  expect_snapshot({
    dm_nycflights13() |>
      dm_draw(font_size = 14L) |>
      invisible()
  })
})

test_that("backend_opts passes DiagrammeR-specific options correctly", {
  skip_if_not_installed("DiagrammeR")

  # Should work without deprecation warning
  expect_no_warning(
    dm_nycflights13() |>
      dm_draw(backend_opts = list(graph_attrs = "rankdir=LR"))
  )
})
