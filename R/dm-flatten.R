#' Flatten a table in a `dm` by joining its parent tables
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dm_flatten()` updates a table in-place by joining its parent tables into it,
#' and removes the now integrated parent tables from the dm.
#'
#' @inheritParams dm_flatten_to_tbl
#' @param table The table to flatten by joining its parent tables.
#'   An interesting choice could be
#'   for example a fact table in a star schema.
#' @param ... These dots are for future extensions and must be empty.
#' @param parent_tables
#'   `r lifecycle::badge("experimental")`
#'
#'   Unquoted names of the parent tables to be joined into `table`.
#'   The order of the tables here determines the order of the joins.
#'   If `NULL` (the default), all direct parent tables
#'   are joined in non-recursive mode,
#'   or all reachable ancestor tables in recursive mode.
#'   `tidyselect` is supported, see [dplyr::select()] for details on the semantics.
#' @param recursive Logical, defaults to `FALSE`.
#'   If `TRUE`, recursively flatten parent tables before joining them
#'   into `table`.
#'   Uses simple recursion: recursively flattening the parents
#'   and then doing a join in order.
#'   If `FALSE`, fails if a parent table has further parents
#'   (unless `allow_deep` is `TRUE`).
#'   Cannot be `TRUE` when `allow_deep` is `TRUE`.
#' @param allow_deep Logical, defaults to `FALSE`.
#'   Only relevant if `recursive = FALSE`.
#'   If `TRUE`, parent tables with further parents are allowed
#'   and will remain in the result with a
#'   foreign-key relationship to the flattened table.
#'   Cannot be `TRUE` when `recursive` is `TRUE`.
#' @param join The type of join to use when combining parent tables,
#'   see [dplyr::join()].
#'   Defaults to [dplyr::left_join()].
#'   `nest_join` is not supported.
#'   When `recursive = TRUE`, only [dplyr::left_join()],
#'   [dplyr::inner_join()], and [dplyr::full_join()] are supported.
#'
#' @return A [`dm`] object with the flattened table and removed parent tables.
#'
#' @family flattening functions
#'
#' @examplesIf rlang::is_installed("nycflights13")
#' dm_nycflights13() %>%
#'   dm_select_tbl(-weather) %>%
#'   dm_flatten(flights, recursive = TRUE)
#'
#' @export
dm_flatten <- function(
  dm,
  table,
  ...,
  parent_tables = NULL,
  recursive = FALSE,
  allow_deep = FALSE,
  join = left_join
) {
  check_not_zoomed(dm)
  check_no_filter(dm)
  check_dots_empty()
  dm_local_error_call()

  join_name <- as_label(enexpr(join))

  if (join_name == "nest_join") {
    abort_no_flatten_with_nest_join("dm_flatten")
  }

  if (recursive && !(join_name %in% c("left_join", "full_join", "inner_join"))) {
    abort_squash_limited("dm_flatten", "recursive")
  }

  if (recursive && allow_deep) {
    cli::cli_abort(
      "{.arg allow_deep} can't be {.code TRUE} when {.arg recursive} is {.code TRUE}.",
      class = dm_error_full("recursive_and_allow_deep"),
      call = dm_error_call()
    )
  }

  start <- dm_tbl_name(dm, {{ table }})

  parent_tables_quo <- enquo(parent_tables)

  all_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)

  # Find direct parents of start
  direct_parents <- all_fks %>%
    filter(child_table == start) %>%
    pull(parent_table) %>%
    unique()

  # Auto-detect or evaluate parent tables
  if (quo_is_null(parent_tables_quo)) {
    if (recursive) {
      # In recursive mode, default to all reachable ancestor tables
      g <- create_graph_from_dm(dm, directed = TRUE)
      list_of_pts <- get_names_of_connected(g, start, squash = TRUE)
    } else {
      list_of_pts <- direct_parents
    }
  } else {
    vars <- setdiff(src_tbls_impl(dm), start)
    list_of_pts <- eval_select_table(quo(c(!!parent_tables_quo)), vars)
  }

  # Early return if nothing to flatten
  if (is_empty(list_of_pts)) {
    return(dm)
  }

  # Validate: all listed tables must be direct parents (or reachable in recursive mode)
  non_parents <- setdiff(list_of_pts, direct_parents)
  if (length(non_parents) > 0) {
    if (recursive) {
      g <- create_graph_from_dm(dm, directed = TRUE)
      reachable <- get_names_of_connected(g, start, squash = TRUE)
      non_reachable <- setdiff(non_parents, reachable)
      if (length(non_reachable) > 0) {
        abort_tables_not_reachable_from_start("table")
      }
    } else {
      g <- create_graph_from_dm(dm, directed = TRUE)
      reachable <- get_names_of_connected(g, start, squash = TRUE)
      if (all(non_parents %in% reachable)) {
        abort_only_parents("dm_flatten", "table", "recursive")
      } else {
        abort_tables_not_reachable_from_start("table")
      }
    }
  }

  # Non-recursive: check for deeper hierarchy
  if (!recursive) {
    has_parents <- all_fks %>%
      filter(child_table %in% list_of_pts) %>%
      nrow()
    if (has_parents > 0 && !allow_deep) {
      abort_only_parents("dm_flatten", "table", "recursive")
    }
  }

  # Run DFS once for cycle detection and ordering (used by recursive path)
  if (recursive) {
    g <- create_graph_from_dm(dm, directed = TRUE)
    g_sub <- graph_induced_subgraph(g, c(start, list_of_pts))
    if (length(graph_vertices(g_sub)) - 1 != length(graph_edges(g_sub))) {
      abort_no_cycles(g_sub)
    }

    dfs <- graph_dfs(g_sub, start, unreachable = FALSE, dist = TRUE)
    dfs_order <- names(dfs$order) %>% discard(is.na)
  } else {
    dfs_order <- NULL
  }

  out <- dm_flatten_impl(dm, start, list_of_pts, dfs_order, join)

  # Handle allow_deep: transfer FKs from absorbed parents to start
  if (allow_deep) {
    parents <- intersect(direct_parents, list_of_pts)
    out$dm <- dm_flatten_transfer_fks(out$dm, start, parents, out$col_renames, all_fks)
  }

  dm_flatten_explain_renames(out$all_renames)

  out$dm
}

#' Flatten a start table by joining its direct parents
#'
#' Workhorse that performs joining of parent tables into a start table.
#' In recursive mode (`dfs_order` not `NULL`), first recursively flattens each
#' direct parent's own ancestors via a loop, then unconditionally joins
#' the resulting direct parents into the start table.
#'
#' @param dm A `dm` object.
#' @param start Name of the table to flatten into.
#' @param list_of_pts Character vector of parent table names to absorb.
#' @param dfs_order Character vector giving DFS traversal order from the main
#'   function, or `NULL` for non-recursive mode.
#' @param join The join function to use (e.g. [dplyr::left_join()]).
#'
#' @return A list with components:
#'   - `dm`: the updated `dm` with parents joined into `start` and removed.
#'   - `all_renames`: list of rename entries from column disambiguation.
#'   - `col_renames`: named list mapping parent names to their column renames.
#'
#' @noRd
#' @autoglobal
dm_flatten_impl <- function(dm, start, list_of_pts, dfs_order, join) {
  all_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)

  # Find direct parents of start
  direct_parents <- all_fks %>%
    filter(child_table == start) %>%
    pull(parent_table) %>%
    unique()

  all_renames <- list()

  # --- Recursive part: pre-flatten each direct parent's ancestors ---
  if (!is.null(dfs_order)) {
    parents_to_process <- intersect(direct_parents, list_of_pts)
    parents_to_process <- intersect(dfs_order, parents_to_process)

    for (pt in parents_to_process) {
      current_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)
      pt_direct_parents <- current_fks %>%
        filter(child_table == pt) %>%
        pull(parent_table) %>%
        unique()
      pt_parents_in_list <- intersect(pt_direct_parents, list_of_pts)
      pt_parents_in_list <- intersect(pt_parents_in_list, src_tbls_impl(dm))

      if (length(pt_parents_in_list) > 0) {
        # Recurse: flatten pt's ancestors into pt
        out <- dm_flatten_impl(dm, pt, pt_parents_in_list, dfs_order, join)
        dm <- out$dm
        all_renames <- c(all_renames, out$all_renames)
      }
    }
  }

  # --- Non-recursive part: join direct parents into start ---
  current_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)
  parents_to_join <- current_fks %>%
    filter(child_table == start) %>%
    pull(parent_table) %>%
    unique()
  parents_to_join <- intersect(parents_to_join, intersect(direct_parents, list_of_pts))
  parents_to_join <- intersect(parents_to_join, src_tbls_impl(dm))

  out <- dm_flatten_join(dm, start, parents_to_join, join)
  out$all_renames <- c(all_renames, out$all_renames)
  out
}

#' Join parent tables into a start table and remove them
#'
#' Performs sequential `left_join()` operations to merge each parent table into
#' the start table.
#' Conflicting column names are disambiguated by appending
#' `.parent_name` as a suffix.
#' The parent tables are removed from the dm after joining.
#'
#' @param dm A `dm` object.
#' @param start Name of the table to join parents into.
#' @param parents Character vector of parent table names to join.
#' @param join The join function to use (e.g. [dplyr::left_join()]).
#'
#' @return A list with components:
#'   - `dm`: the updated `dm` with parents joined and removed.
#'   - `all_renames`: list of rename entries recording disambiguated columns.
#'   - `col_renames`: named list mapping each parent to its column renames
#'     (used by `dm_flatten_transfer_fks()`).
#'
#' @noRd
#' @autoglobal
dm_flatten_join <- function(dm, start, parents, join) {
  if (is_empty(parents)) {
    return(list(dm = dm, all_renames = list(), col_renames = list()))
  }

  all_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)

  start_tbl <- tbl_impl(dm, start)
  current_cols <- colnames(start_tbl)

  # Track renames per parent for allow_deep FK transfer
  col_renames <- list()
  all_renames <- list()

  for (pt in parents) {
    # Get FK between start and parent
    fk_info <- all_fks %>%
      filter(child_table == start, parent_table == pt)
    if (nrow(fk_info) == 0) {
      abort_tables_not_neighbors(start, pt)
    }
    if (nrow(fk_info) > 1) {
      abort_no_cycles(create_graph_from_dm(dm))
    }

    child_fk_cols <- fk_info$child_fk_cols[[1]]
    parent_key_cols <- fk_info$parent_key_cols[[1]]
    by <- set_names(parent_key_cols, child_fk_cols)

    parent_tbl <- tbl_impl(dm, pt)
    parent_cols <- colnames(parent_tbl)

    # Columns from parent that will appear in the result
    # (all parent columns EXCEPT the key columns used in the join)
    parent_incoming_cols <- setdiff(parent_cols, parent_key_cols)

    # Find conflicts with current columns
    conflicting <- intersect(current_cols, parent_incoming_cols)

    # Rename conflicting columns in parent table
    renames <- character(0)
    if (length(conflicting) > 0) {
      new_names <- paste0(conflicting, ".", pt)
      rename_vec <- set_names(conflicting, new_names)
      parent_tbl <- rename(parent_tbl, !!!rename_vec)
      renames <- set_names(new_names, conflicting)
      all_renames <- c(all_renames, list(list(table = pt, renames = renames)))
    }
    col_renames[[pt]] <- renames

    # Perform the join
    start_tbl <- join(start_tbl, parent_tbl, by = by)

    # Update current columns for next iteration
    current_cols <- colnames(start_tbl)
  }

  # Build result dm
  def <- dm_get_def(dm)
  start_idx <- which(def$table == start)
  def$data[[start_idx]] <- start_tbl

  dm_result <- dm_from_def(def)

  # Remove parent tables
  remaining <- setdiff(def$table, parents)
  remaining <- set_names(remaining)

  list(
    dm = dm_select_tbl_impl(dm_result, remaining),
    all_renames = all_renames,
    col_renames = col_renames
  )
}

#' Report column renames to the user
#'
#' Formats and prints a message describing renamed columns,
#' using the same style as `dm_flatten_to_tbl()`.
#'
#' @param all_renames List of rename entries, each with `table` and `renames`
#'   components.
#'   `renames` is a named character vector mapping old names to new names.
#'
#' @return Called for its side effect (message).
#'   Returns `invisible()`.
#'
#' @noRd
dm_flatten_explain_renames <- function(all_renames) {
  if (is_empty(all_renames)) {
    return(invisible())
  }

  lines <- map_chr(all_renames, function(entry) {
    rename_strs <- paste0(
      tick_if_needed(entry$renames),
      " = ",
      tick_if_needed(names(entry$renames))
    )
    paste0(
      "dm_rename(",
      tick_if_needed(entry$table),
      ", ",
      paste0(rename_strs, collapse = ", "),
      ")"
    )
  })

  message(
    "Renaming ambiguous columns: %>%\n  ",
    paste0(lines, collapse = " %>%\n  ")
  )
}

#' Transfer foreign keys from absorbed parents to the flattened table
#'
#' When `allow_deep = TRUE`, parent tables that reference grandparent tables
#' are absorbed into the start table.
#' This function re-points those FK
#' relationships so that the start table now references the grandparent
#' directly, accounting for column renames and dropped join keys.
#'
#' @param dm A `dm` object (after parents have been joined and removed).
#' @param start Name of the flattened table.
#' @param parents Character vector of parent table names that were absorbed.
#' @param col_renames Named list mapping each parent to its column renames
#'   (from `dm_flatten_join()`).
#' @param all_fks Data frame of all FK relationships from the original dm
#'   (before absorption).
#'
#' @return An updated `dm` with transferred FK relationships.
#'
#' @noRd
#' @autoglobal
dm_flatten_transfer_fks <- function(dm, start, parents, col_renames, all_fks) {
  def <- dm_get_def(dm)

  for (pt in parents) {
    # Find FKs where pt is the child (pt references other tables as parent)
    pt_child_fks <- all_fks %>%
      filter(child_table == pt)

    for (i in seq_len(nrow(pt_child_fks))) {
      gp <- pt_child_fks$parent_table[i]
      # Skip if grandparent is also being absorbed or is the start table
      if (gp %in% parents || gp == start) {
        next
      }

      child_cols <- pt_child_fks$child_fk_cols[[i]]
      parent_cols <- pt_child_fks$parent_key_cols[[i]]

      # Apply renames: if any FK columns were renamed during disambiguation
      renames <- col_renames[[pt]]
      if (length(renames) > 0) {
        for (k in seq_along(child_cols)) {
          if (child_cols[k] %in% names(renames)) {
            child_cols[k] <- renames[[child_cols[k]]]
          }
        }
      }

      # Handle the case where a FK column is the same as the join key
      # (it was dropped during the join, so use start's FK column instead)
      fk_to_parent <- all_fks %>%
        filter(child_table == start, parent_table == pt)
      if (nrow(fk_to_parent) > 0) {
        parent_key <- fk_to_parent$parent_key_cols[[1]]
        start_fk <- fk_to_parent$child_fk_cols[[1]]
        for (k in seq_along(child_cols)) {
          key_idx <- match(child_cols[k], parent_key)
          if (!is.na(key_idx)) {
            child_cols[k] <- start_fk[key_idx]
          }
        }
      }

      # Add FK from start to grandparent
      gp_idx <- which(def$table == gp)
      def$fks[[gp_idx]] <- vec_rbind(
        def$fks[[gp_idx]],
        new_fk(list(parent_cols), start, list(child_cols), "no_action")
      )
    }
  }

  dm_from_def(def)
}
