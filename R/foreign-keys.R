#' Add foreign keys
#'
#' @description
#' `dm_add_fk()` marks the specified `columns` as the foreign key of table `table` with
#' respect to a key of table `ref_table`.
#' Usually the referenced columns are a primary key in `ref_table`,
#' it is also possible to specify other columns via the `ref_columns` argument.
#' If `check == TRUE`, then it will first check if the values in `columns` are a subset
#' of the values of the key in table `ref_table`.
#'
#' @inheritParams dm_add_pk
#' @param columns The columns of `table` which are to become the foreign key columns that
#'   reference `ref_table`.
#'   To define a compound key, use `c(col1, col2)`.
#' @param ref_table The table which `table` will be referencing.
#' @param ref_columns The column(s) of `table` which are to become the referenced column(s) in `ref_table`.
#'   By default, the primary key is used.
#'   To define a compound key, use `c(col1, col2)`.
#' @param check Boolean, if `TRUE`, a check will be performed to determine if the values of
#'   `columns` are a subset of the values of the key column(s) of `ref_table`.
#' @param on_delete
#'   `r lifecycle::badge("experimental")`
#'
#'   Defines behavior if a row in the parent table is deleted.
#'     - `"no_action"`, the default, means that no action is taken
#'        and the operation is aborted if child rows exist
#'     - `"cascade"` means that the child row is also deleted
#'   This setting is picked up by [copy_dm_to()] with `set_key_constraints = TRUE`,
#'   and might be considered by [dm_rows_delete()] in a future version.
#'
#' @family foreign key functions
#'
#' @rdname dm_add_fk
#'
#' @return An updated `dm` with an additional foreign key relation.
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' nycflights_dm <- dm(
#'   planes = nycflights13::planes,
#'   flights = nycflights13::flights,
#'   weather = nycflights13::weather
#' )
#'
#' nycflights_dm %>%
#'   dm_draw()
#'
#' # Create foreign keys:
#' nycflights_dm %>%
#'   dm_add_pk(planes, tailnum) %>%
#'   dm_add_fk(flights, tailnum, planes) %>%
#'   dm_add_pk(weather, c(origin, time_hour)) %>%
#'   dm_add_fk(flights, c(origin, time_hour), weather) %>%
#'   dm_draw()
#'
#' # Keys can be checked during creation:
#' try(
#'   nycflights_dm %>%
#'     dm_add_pk(planes, tailnum) %>%
#'     dm_add_fk(flights, tailnum, planes, check = TRUE)
#' )
dm_add_fk <- function(dm, table, columns, ref_table, ref_columns = NULL, ...,
                      check = FALSE,
                      on_delete = c("no_action", "cascade")) {
  check_dots_empty()
  check_not_zoomed(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})
  on_delete <- arg_match(on_delete)

  table_obj <- tbl_impl(dm, table_name)
  col_expr <- enexpr(columns)
  col_name <- names(eval_select_indices(col_expr, colnames(table_obj)))

  ref_table_obj <- tbl_impl(dm, ref_table_name)
  ref_col_expr <- enexpr(ref_columns)
  if (is.null(ref_col_expr)) {
    ref_key <- dm_get_pk_impl(dm, ref_table_name)

    if (is_empty(ref_key)) {
      abort_ref_tbl_has_no_pk(ref_table_name)
    }

    ref_col_name <- get_key_cols(ref_key)
  } else {
    ref_col_name <- names(eval_select_indices(ref_col_expr, colnames(ref_table_obj)))
    # check if either a PK or UK already matches ref_col_name
    all_keys <- dm_get_all_pks_impl(dm, ref_table_name) %>%
      rename(uk_col = pk_col) %>%
      bind_rows(dm_get_all_uks_impl(dm, ref_table_name))
    # setequal() could also be used for matching, but IMHO the order should matter
    matches_keys <- map_lgl(all_keys$uk_col, identical, ref_col_name)
    if (!any(matches_keys)) {
      if (check) {
        if (!is_unique_key_se(ref_table_obj, ref_col_name)$unique) {
          abort_not_unique_key(ref_table_name, ref_col_name)
        }
      }
      dm <- dm_add_uk_impl(dm, ref_table_name, ref_col_name)
    }
  }

  # FIXME: COMPOUND:: Clean check with proper error message
  stopifnot(length(ref_col_name) == length(col_name))

  if (check) {
    if (!is_subset(table_obj, !!col_name, ref_table_obj, !!ref_col_name)) {
      abort_not_subset_of(table_name, col_name, ref_table_name, ref_col_name)
    }
  }

  dm_add_fk_impl(dm, table_name, list(col_name), ref_table_name, list(ref_col_name), on_delete)
}

dm_add_fk_impl <- function(dm, table, column, ref_table, ref_column, on_delete) {
  column <- unclass(column)
  ref_column <- unclass(ref_column)

  on_delete <- vec_recycle(on_delete, length(ref_table))

  loc <- which(!duplicated(ref_table))
  n_loc <- length(loc)
  if (n_loc > 1) {
    my_ref_table <- ref_table[[loc[[n_loc]]]]

    my <- ref_table == my_ref_table
    where_other <- which(!my)
    dm <- dm_add_fk_impl(dm, table[where_other], column[where_other], ref_table[where_other], ref_column[where_other], on_delete[where_other])

    table <- table[my]
    column <- column[my]
    ref_column <- ref_column[my]
    on_delete <- on_delete[my]
    # ref_table must be scalar, unlike the others
    ref_table <- my_ref_table
  } else if (n_loc == 0) {
    return(dm)
  } else {
    my_ref_table <- ref_table[[1]]
  }

  def <- dm_get_def(dm)

  i <- which(def$table == ref_table)

  fks <- def$fks[[i]]

  existing <- fks$table == table & !is.na(vec_match(fks$column, column))
  if (any(existing)) {
    if (dm_is_strict_keys(dm)) {
      first_existing <- which(existing)[[1]]
      abort_fk_exists(table[[first_existing]], column[[first_existing]], ref_table)
    }

    stopifnot(all(existing))

    return(dm)
  }

  def$fks[[i]] <- vec_rbind(
    fks,
    new_fk(ref_column, table, column, on_delete)
  )

  new_dm3(def)
}

#' Check if foreign keys exists
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' These functions are deprecated because of their limited use
#' since the introduction of foreign keys to arbitrary columns in dm 0.2.1.
#' Use [dm_get_all_fks()] with table manipulation functions instead.
#'
#' @inheritParams dm_add_fk
#' @export
#' @keywords internal
dm_has_fk <- function(dm, table, ref_table, ...) {
  check_dots_empty()
  check_not_zoomed(dm)

  deprecate_soft("0.2.1", "dm::dm_has_fk()", "dm::dm_get_all_fks()")

  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})
  dm_has_fk_impl(dm, table_name, ref_table_name)
}

dm_has_fk_impl <- function(dm, table_name, ref_table_name) {
  has_length(dm_get_fk_impl(dm, table_name, ref_table_name))
}

#' @rdname dm_has_fk
#' @export
dm_get_fk <- function(dm, table, ref_table, ...) {
  check_dots_empty()
  check_not_zoomed(dm)

  deprecate_soft("0.2.1", "dm::dm_get_fk()", "dm::dm_get_all_fks()")

  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})

  new_keys(dm_get_fk_impl(dm, table_name, ref_table_name))
}

dm_get_fk_impl <- function(dm, table_name, ref_table_name) {
  def <- dm_get_def(dm)
  i <- which(def$table == ref_table_name)

  fks <- def$fks[[i]]
  fks$column[fks$table == table_name]
}

dm_get_fk2_impl <- function(dm, table_name, ref_table_name) {
  # FIXME: Revisit instances of dm_get_fk_impl()
  def <- dm_get_def(dm)
  i <- which(def$table == ref_table_name)

  fks <- def$fks[[i]]
  fks[fks$table == table_name, c("column", "ref_column")]
}

#' Get foreign key constraints
#'
#' @description
#' Get a summary of all foreign key relations in a [`dm`].
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`child_table`}{child table,}
#'     \item{`child_fk_cols`}{foreign key column(s) in child table as list of character vectors,}
#'     \item{`parent_table`}{parent table,}
#'     \item{`parent_key_cols`}{key column(s) in parent table as list of character vectors.}
#'     \item{`on_delete`}{behavior on deletion of rows in the parent table.}
#'   }
#'
#' @inheritParams dm_has_fk
#' @param parent_table One or more table names, as character vector,
#'   to return foreign key information for.
#'   If given, foreign keys are returned in that order.
#'   The default `NULL` returns information for all tables.
#'
#' @family foreign key functions
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_get_all_fks()
#' @export
dm_get_all_fks <- function(dm, parent_table = NULL, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  dm_get_all_fks_impl(dm, parent_table)
}

dm_get_all_fks_impl <- function(dm, parent_table = NULL, ignore_on_delete = FALSE, id = FALSE) {
  def <- dm_get_def(dm)

  dm_get_all_fks_def_impl(def = def, parent_table = parent_table, ignore_on_delete = ignore_on_delete, id = id)
}

dm_get_all_fks_def_impl <- function(def, parent_table = NULL, ignore_on_delete = FALSE, id = FALSE) {
  def_sub <- def[c("table", "fks")]
  names(def_sub)[[1]] <- "parent_table"

  if (!is.null(parent_table)) {
    idx <- match(parent_table, def_sub$parent_table)
    if (anyNA(idx)) {
      abort(paste0("Table not in dm object: ", parent_table[which(is.na(idx))[[1]]]))
    }
    def_sub <- def_sub[idx, ]
  }

  flat <- unnest_list_of_df(def_sub, "fks")

  names(flat) <- c("parent_table", "parent_key_cols", "child_table", "child_fk_cols", "on_delete")
  flat[[2]] <- new_keys(flat[[2]])
  flat[[4]] <- new_keys(flat[[4]])
  out <- flat[c(3:4, 1:2, if (!ignore_on_delete) 5L)]
  if (id) {
    out <-
      out %>%
      group_by(child_table) %>%
      mutate(id = paste0(child_table, "_", row_number())) %>%
      ungroup()
  }
  out
}

#' Remove foreign keys
#'
#' @description
#' `dm_rm_fk()` can remove either one reference between two tables, or multiple references at once (with a message).
#' An error is thrown if no matching foreign key is found.
#'
#' @family foreign key functions
#'
#' @inheritParams dm_rm_pk
#' @param ref_table The table referenced by the `table` argument.
#'   Pass `NULL` to remove all matching keys.
#' @param ref_columns The columns of `table` that should no longer be referencing the primary key of `ref_table`.
#'   To refer to a compound key, use `c(col1, col2)`.
#'
#' @return An updated `dm` without the matching foreign key relation(s).
#'
#' @export
#' @examplesIf rlang::is_installed("nycflights13") && rlang::is_installed("DiagrammeR")
#' dm_nycflights13(cycle = TRUE) %>%
#'   dm_rm_fk(flights, dest, airports) %>%
#'   dm_draw()
dm_rm_fk <- function(dm, table = NULL, columns = NULL, ref_table = NULL, ref_columns = NULL, ...) {
  check_dots_empty()
  check_not_zoomed(dm)

  table_name <- dm_tbl_name_null(dm, {{ table }})
  column_expr <- enexpr(columns)
  ref_table_name <- dm_tbl_name_null(dm, {{ ref_table }})
  ref_column_expr <- enexpr(ref_columns)

  dm_rm_fk_impl(dm, table_name, column_expr, ref_table_name, ref_column_expr)
}

dm_rm_fk_impl <- function(dm, table_name, cols, ref_table_name, ref_cols) {
  def <- dm_get_def(dm)

  # Filter by each argument if given:

  # ref_table_name: keyed by def$table, simplest
  if (is.null(ref_table_name)) {
    idx <- seq_along(def$table)
  } else {
    idx <- which(def$table == ref_table_name)
  }

  # other args: inside def$fks, maintaining list of indexes
  idx_fk <- map(def$fks[idx], ~ seq_len(nrow(.x)))

  # table_name: keep FK entries pointing to the other table
  if (!is.null(table_name)) {
    idx_fk <- map2(def$fks[idx], idx_fk, ~ {
      ii <- (.x$table[.y] == table_name)
      .y[ii]
    })

    # Prune after each step (this also ensures that negative selection works further below)
    keep <- (lengths(idx_fk) > 0)
    idx <- idx[keep]
    idx_fk <- idx_fk[keep]
  }

  # ref_cols: find column names once for each ref_table
  if (!is.null(ref_cols)) {
    idx_fk <- pmap(list(def$fks[idx], idx_fk, def$data[idx]), ~ {
      ii <- tryCatch(
        {
          names_vars <- names(eval_select_indices(ref_cols, colnames(..3)))
          map_lgl(.x$ref_column[.y], identical, names_vars)
        },
        error = function(e) {
          0
        }
      )
      .y[ii]
    })

    # Prune after each step (this also ensures that negative selection works further below)
    keep <- (lengths(idx_fk) > 0)
    idx <- idx[keep]
    idx_fk <- idx_fk[keep]
  }

  # cols: find column inside each fks entry
  if (!is.null(cols)) {
    all_tables <- set_names(def$data, def$table)

    idx_fk <- map2(def$fks[idx], idx_fk, ~ {
      ii <- map2_lgl(.x$table[.y], .x$column[.y], ~ {
        tryCatch(
          {
            names_vars <- names(eval_select_indices(cols, colnames(all_tables[[.x]])))
            identical(.y, names_vars)
          },
          error = function(e) {
            FALSE
          }
        )
      })
      .y[ii]
    })

    # Prune after each step (this also ensures that negative selection works further below)
    keep <- (lengths(idx_fk) > 0)
    idx <- idx[keep]
    idx_fk <- idx_fk[keep]
  }

  # Check if empty
  if (length(idx) == 0) {
    abort_is_not_fkc()
  }

  # Talk about it
  if (is.null(table_name) || is.null(cols) || is.null(ref_table_name)) {
    show_disambiguation <- TRUE
  } else if (!is.null(ref_cols)) {
    show_disambiguation <- FALSE
  } else {
    # Check if all FKs point to the primary key
    show_disambiguation <- !all(map2_lgl(def$fks[idx], def$pks[idx], ~ {
      all(map_lgl(.x$ref_column, identical, .y$column[[1]]))
    }))
  }

  if (show_disambiguation) {
    def_rm <- def[idx, c("table", "pks", "fks")]
    def_rm$fks <- map2(def_rm$fks, idx_fk, vec_slice)
    def_rm$fks <- map2(def_rm$fks, def_rm$pks, ~ {
      .x$need_ref <- !map_lgl(.x$ref_column, identical, .y$column[[1]])
      .x
    })

    disambiguation <-
      def_rm %>%
      select(ref_table = table, fks) %>%
      unnest(-ref_table) %>%
      mutate(ref_col_text = if_else(need_ref, glue(", {deparse_keys(ref_column)})"), "")) %>%
      mutate(text = glue("dm_rm_fk({tick_if_needed(table)}, {deparse_keys(column)}, {tick_if_needed(ref_table)}{ref_col_text})")) %>%
      pull()

    message("Removing foreign keys: %>%\n  ", glue_collapse(disambiguation, " %>%\n  "))
  }

  # Execute
  def$fks[idx] <- map2(def$fks[idx], idx_fk, ~ .x[-.y, ])

  new_dm3(def)
}

#' Foreign key candidates
#'
#' @description `r lifecycle::badge("experimental")`
#'
#' Determine which columns would be good candidates to be used as foreign keys of a table,
#' to reference the primary key column of another table of the [`dm`] object.
#'
#' @inheritParams dm_add_fk
#' @param table The table whose columns should be tested for suitability as foreign keys.
#' @param ref_table A table with a primary key.
#'
#' @details `dm_enum_fk_candidates()` first checks if `ref_table` has a primary key set,
#' if not, an error is thrown.
#'
#' If `ref_table` does have a primary key, then a join operation will be tried using
#' that key as the `by` argument of join() to match it to each column of `table`.
#' Attempting to join incompatible columns triggers an error.
#'
#' The outcome of the join operation determines the value of the `why` column in the result:
#'
#' - an empty value for a column of `table` that is a suitable foreign key candidate
#' - the count and percentage of missing matches for a column that is not suitable
#' - the error message triggered for unsuitable candidates that may include the types of mismatched columns
#'
#' @section Life cycle:
#' These functions are marked "experimental" because we are not yet sure about
#' the interface, in particular if we need both `dm_enum...()` and `enum...()`
#' variants.
#' Changing the interface later seems harmless because these functions are
#' most likely used interactively.
#'
#' @return A tibble with the following columns:
#'   \describe{
#'     \item{`columns`}{columns of `table`,}
#'     \item{`candidate`}{boolean: are these columns a candidate for a foreign key,}
#'     \item{`why`}{if not a candidate for a foreign key, explanation for for this.}
#'   }
#'
#' @family foreign key functions
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_enum_fk_candidates(flights, airports)
#'
#' dm_nycflights13() %>%
#'   dm_zoom_to(flights) %>%
#'   enum_fk_candidates(airports)
#' @export
dm_enum_fk_candidates <- function(dm, table, ref_table, ...) {
  check_dots_empty()
  check_not_zoomed(dm)
  # FIXME: with "direct" filter maybe no check necessary: but do we want to check
  # for tables retrieved with `tbl()` or with `dm_get_tables()[[table_name]]`
  check_no_filter(dm)
  table_name <- dm_tbl_name(dm, {{ table }})
  ref_table_name <- dm_tbl_name(dm, {{ ref_table }})

  ref_tbl_pk <- dm_get_pk_impl(dm, ref_table_name)

  ref_tbl <- tbl_impl(dm, ref_table_name)
  tbl <- tbl_impl(dm, table_name)

  table_name %>%
    enum_fk_candidates_impl(tbl, ref_table_name, ref_tbl, ref_tbl_pk) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

#' @details `enum_fk_candidates()` works like `dm_enum_fk_candidates()` with the zoomed table as `table`.
#'
#' @rdname dm_enum_fk_candidates
#' @param dm_zoomed A `dm` with a zoomed table.
#' @export
enum_fk_candidates <- function(dm_zoomed, ref_table, ...) {
  check_dots_empty()
  check_zoomed(dm_zoomed)
  check_no_filter(dm_zoomed)

  table_name <- orig_name_zoomed(dm_zoomed)
  ref_table_name <- dm_tbl_name(dm_zoomed, {{ ref_table }})

  ref_tbl_pk <- dm_get_pk_impl(dm_zoomed, ref_table_name)

  ref_tbl <- dm_get_tables_impl(dm_zoomed)[[ref_table_name]]
  enum_fk_candidates_impl(table_name, tbl_zoomed(dm_zoomed), ref_table_name, ref_tbl, ref_tbl_pk) %>%
    rename(columns = column) %>%
    mutate(columns = new_keys(columns))
}

enum_fk_candidates_impl <- function(table_name, tbl, ref_table_name, ref_tbl, ref_tbl_pk) {
  if (is_empty(ref_tbl_pk)) {
    abort_ref_tbl_has_no_pk(ref_table_name)
  }
  ref_tbl_cols <- get_key_cols(ref_tbl_pk)

  tbl_colnames <- colnames(tbl)
  tibble(
    column = tbl_colnames,
    why = map_chr(column, ~ check_fk(tbl, table_name, .x, ref_tbl, ref_table_name, ref_tbl_cols))
  ) %>%
    mutate(candidate = ifelse(why == "", TRUE, FALSE)) %>%
    select(column, candidate, why) %>%
    arrange(desc(candidate))
}

check_fk <- function(t1, t1_name, colname, t2, t2_name, pk) {
  stopifnot(length(colname) == length(pk))

  val_names <- paste0("value", seq_along(colname))
  t1_vals <- syms(colname)
  names(t1_vals) <- val_names
  t2_vals <- syms(pk)
  names(t2_vals) <- val_names

  t1_join <-
    t1 %>%
    count(!!!t1_vals) %>%
    ungroup()
  t2_join <-
    t2 %>%
    count(!!!t2_vals) %>%
    ungroup()

  val_names_na_expr <- map(syms(val_names), ~ call("is.na", .x))
  any_value_na_expr <- reduce(val_names_na_expr, ~ call("|", .x, .y))

  # Work around weird bug in R 3.6 and before
  if (getRversion() < "4.0" && inherits(t1_join, "tbl_lazy")) {
    dbplyr::sql_render(t1_join)
  }

  res_tbl <- tryCatch(
    t1_join %>%
      # if value* is NULL, this also counts as a match -- consistent with fk semantics
      filter(!(!!any_value_na_expr)) %>%
      anti_join(t2_join, by = val_names) %>%
      arrange(desc(n), !!!syms(val_names)) %>%
      head(MAX_COMMAS + 1L) %>%
      collect(),
    error = identity
  )

  # return error message if error occurred (possibly types didn't match etc.)
  if (is_condition(res_tbl)) {
    return(conditionMessage(res_tbl))
  }

  # return empty character if candidate
  if (nrow(res_tbl) == 0) {
    return("")
  }

  res_tbl[val_names] <- map(res_tbl[val_names], format, trim = TRUE, justify = "none")
  res_tbl[val_names[-1]] <- map(res_tbl[val_names[-1]], ~ paste0(", ", .x))
  res_tbl$value <- exec(paste0, !!!res_tbl[val_names])

  vals_formatted <- commas(
    glue("{res_tbl$value} ({res_tbl$n})"),
    capped = TRUE
  )
  glue(
    "values of ",
    "{commas(tick(glue('{t1_name}${colname}')), Inf)} not in {commas(tick(glue('{t2_name}${pk}')), Inf)}: {vals_formatted}"
  )
}

fk_table_to_def_fks <- function(table,
                                child_table = "child_table",
                                child_fk_cols = "child_fk_cols",
                                parent_table = "parent_table",
                                parent_key_cols = "parent_key_cols") {
  table %>%
    group_by(!!ensym(parent_table)) %>%
    summarize(
      fks = list_of(new_fk(
        ref_column = as.list(!!ensym(parent_key_cols)),
        table = !!ensym(child_table),
        column = as.list(!!ensym(child_fk_cols)),
        on_delete = on_delete
      ))
    )
}

# Errors ------------------------------------------------------------------

abort_fk_exists <- function(child_table_name, colnames, parent_table_name) {
  abort(
    error_txt_fk_exists(
      child_table_name, colnames, parent_table_name
    ),
    class = dm_error_full("fk_exists")
  )
}

error_txt_fk_exists <- function(child_table_name, colnames, parent_table_name) {
  glue(
    "({commas(tick(colnames))}) is already a foreign key of table ",
    "{tick(child_table_name)} into table {tick(parent_table_name)}."
  )
}

abort_is_not_fkc <- function() {
  abort(
    error_txt_is_not_fkc(),
    class = dm_error_full("is_not_fkc")
  )
}

error_txt_is_not_fkc <- function() {
  "No foreign keys to remove."
}
