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
