expect_identical_graph <- function(g1, g2) {
  expect_true(igraph::identical_graphs(g1, g2))
}

expect_equivalent_dm <- function(
  object,
  expected,
  sort = FALSE,
  ...,
  sort_tables = sort,
  sort_columns = sort,
  sort_keys = sort,
  ignore_on_delete = FALSE,
  ignore_autoincrement = FALSE
) {
  tables1 <- dm_get_tables_impl(object) %>% map(dplyr::collect)
  tables2 <- dm_get_tables_impl(expected) %>% map(dplyr::collect)

  expect_equivalent_tbl_lists(
    tables1,
    tables2,
    sort_tables = sort_tables,
    sort_columns = sort_columns
  )

  if (sort_keys) {
    if (ignore_autoincrement) {
      expect_equivalent_tbl(
        dm_get_all_pks_impl(object) %>% dplyr::select(-autoincrement),
        dm_get_all_pks_impl(expected) %>% dplyr::select(-autoincrement)
      )
    } else {
      expect_equivalent_tbl(dm_get_all_pks_impl(object), dm_get_all_pks_impl(expected))
    }
    expect_equivalent_tbl(
      dm_get_all_fks_impl(object, ignore_on_delete = ignore_on_delete),
      dm_get_all_fks_impl(expected, ignore_on_delete = ignore_on_delete)
    )
  } else {
    if (ignore_autoincrement) {
      expect_equivalent_tbl(
        dm_get_all_pks_impl(object) %>% dplyr::select(-autoincrement),
        dm_get_all_pks_impl(expected) %>% dplyr::select(-autoincrement)
      )
    } else {
      expect_equivalent_tbl(dm_get_all_pks_impl(object), dm_get_all_pks_impl(expected))
    }
    expect_equal(
      dm_get_all_fks_impl(object, ignore_on_delete = ignore_on_delete),
      dm_get_all_fks_impl(expected, ignore_on_delete = ignore_on_delete)
    )
  }
}

expect_equivalent_why <- function(ex1, ex2) {
  if (inherits(my_test_src(), "src_dbi")) {
    ex1 <-
      ex1 %>%
      dplyr::mutate(why = (why != ""))
    ex2 <-
      ex2 %>%
      dplyr::mutate(why = (why != ""))
  }

  expect_identical(ex1, ex2)
}

expect_dm_error <- function(expr, class) {
  expect_error(expr, class = dm_error(class))
}

expect_dm_warning <- function(expr, class) {
  expect_warning(out <- expr, class = dm_warning(class))
  out
}

expect_name_repair_message <- function(expr) {
  expect_message(out <- expr)
  out
}

arrange_if_no_list <- function(tbl) {
  if (inherits(tbl, "tbl_dbi")) {
    dplyr::arrange_all(tbl)
  } else {
    dplyr::arrange(tbl, dplyr::across(dplyr::where(~ !is.list(.))))
  }
}

harmonize_tbl <- function(tbl, ...) {
  tbl %>%
    dplyr::collect() %>%
    dplyr::mutate(...) %>%
    arrange_if_no_list()
}

# are two tables identical minus the `src`
expect_equivalent_tbl <- function(
  tbl_1,
  tbl_2,
  ...,
  .label = NULL,
  .expected_label = NULL,
  .sort_columns = FALSE
) {
  if (.sort_columns) {
    tbl_1 <- dplyr::select(tbl_1, !!!sort(names(tbl_1)))
    tbl_2 <- dplyr::select(tbl_2, !!!sort(names(tbl_2)))
  }
  tbl_1_lcl <- harmonize_tbl(tbl_1, ...)
  tbl_2_lcl <- harmonize_tbl(tbl_2, ...)
  expect_identical(tbl_1_lcl, tbl_2_lcl, label = .label, expected.label = .expected_label)
}

# are two lists of tables identical minus the `src`
expect_equivalent_tbl_lists <- function(
  object,
  expected,
  sort_tables = FALSE,
  sort_columns = FALSE
) {
  expect_equal(length(object), length(expected))
  if (length(object) == length(expected)) {
    if (sort_tables) {
      object <- object[sort(names(object))]
      expected <- expected[sort(names(expected))]
    }

    expect_identical(names(object), names(expected))

    recipe <- tibble(
      tbl_1 = object,
      tbl_2 = expected,
      .label = paste0("object$", names(object)),
      .expected_label = paste0("expected$", names(expected)),
    )
    pwalk(recipe, expect_equivalent_tbl, .sort_columns = sort_columns)
  }
}

expect_snapshot_diagram <- function(diagram, name) {
  skip_if_not_installed("DiagrammeR")
  skip_if_not_installed("DiagrammeRsvg")

  dir <- withr::local_tempdir()
  path <- file.path(dir, name)

  diagram %>%
    DiagrammeRsvg::export_svg() %>%
    writeLines(path)

  expect_snapshot_file(path, compare = compare_file_text)
}

expect_same <- function(object, ...) {
  others <- enquos(...)
  walk(others, function(.x) expect_identical(!!.x, {{ object }}))
}
