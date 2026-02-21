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
#'   (reachable via foreign keys) are joined.
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
  allow_deep = FALSE
) {
  check_not_zoomed(dm)
  check_no_filter(dm)
  check_dots_empty()

  if (recursive && allow_deep) {
    cli::cli_abort(
      "{.arg allow_deep} can't be {.code TRUE} when {.arg recursive} is {.code TRUE}.",
      class = dm_error_full("recursive_and_allow_deep")
    )
  }

  start <- dm_tbl_name(dm, {{ table }})

  vars <- setdiff(src_tbls_impl(dm), start)
  list_of_pts <- eval_select_table(quo(c({{ parent_tables }})), vars)

  out <- dm_flatten_impl(dm, start, list_of_pts, recursive, allow_deep)

  dm_flatten_explain_renames(out$all_renames)

  out$dm
}

#' @autoglobal
dm_flatten_impl <- function(dm, start, list_of_pts, recursive, allow_deep) {
  all_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)

  # Find direct parents of start
  direct_parents <- all_fks %>%
    filter(child_table == start) %>%
    pull(parent_table) %>%
    unique()

  # Auto-detect: use all direct parents
  auto_detect <- is_empty(list_of_pts)
  if (auto_detect) {
    list_of_pts <- direct_parents
  }

  # Early return if nothing to flatten
  if (is_empty(list_of_pts)) {
    return(list(dm = dm, all_renames = list()))
  }

  # Validate: all listed tables must be direct parents
  non_parents <- setdiff(list_of_pts, direct_parents)
  if (length(non_parents) > 0) {
    if (recursive) {
      # In recursive mode, non-direct-parents are OK if reachable
      g <- create_graph_from_dm(dm, directed = TRUE)
      reachable <- get_names_of_connected(g, start, squash = TRUE)
      non_reachable <- setdiff(non_parents, reachable)
      if (length(non_reachable) > 0) {
        abort_tables_not_reachable_from_start()
      }
    } else {
      g <- create_graph_from_dm(dm, directed = TRUE)
      reachable <- get_names_of_connected(g, start, squash = TRUE)
      if (all(non_parents %in% reachable)) {
        abort_only_parents()
      } else {
        abort_tables_not_reachable_from_start()
      }
    }
  }

  all_renames <- list()

  if (recursive) {
    # Run DFS upfront to determine join order and detect cycles
    g <- create_graph_from_dm(dm, directed = TRUE)
    g_sub <- graph_induced_subgraph(g, c(start, list_of_pts))
    if (length(graph_vertices(g_sub)) - 1 != length(graph_edges(g_sub))) {
      abort_no_cycles(g_sub)
    }

    dfs <- graph_dfs(g_sub, start, unreachable = FALSE, dist = TRUE)
    dfs_order <- names(dfs$order) %>% discard(is.na)

    # Up-front reduction: recursively flatten each direct parent's ancestors
    out <- dm_flatten_reduce_parents(dm, start, list_of_pts, direct_parents, dfs_order)
    dm <- out$dm
    all_renames <- out$all_renames
  } else {
    # Non-recursive: check for deeper hierarchy
    has_parents <- all_fks %>%
      filter(child_table %in% list_of_pts) %>%
      nrow()
    if (has_parents > 0 && !allow_deep) {
      abort_only_parents()
    }
  }

  # Determine which direct parents to join into start
  current_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)
  parents_to_join <- current_fks %>%
    filter(child_table == start) %>%
    pull(parent_table) %>%
    unique()
  parents_to_join <- intersect(parents_to_join, intersect(direct_parents, list_of_pts))
  parents_to_join <- intersect(parents_to_join, src_tbls_impl(dm))

  out <- dm_flatten_join(dm, start, parents_to_join, allow_deep)
  out$all_renames <- c(all_renames, out$all_renames)
  out
}

#' @autoglobal
dm_flatten_reduce_parents <- function(dm, start, list_of_pts, direct_parents, dfs_order) {
  parents_to_process <- intersect(direct_parents, list_of_pts)
  parents_to_process <- intersect(dfs_order, parents_to_process)

  # For each direct parent, recursively flatten its ancestors first
  reduce(
    parents_to_process,
    function(acc, pt) {
      dm <- acc$dm
      current_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)
      pt_parents <- current_fks %>%
        filter(child_table == pt) %>%
        pull(parent_table) %>%
        unique()
      pt_parents_in_list <- intersect(pt_parents, list_of_pts)
      pt_parents_in_list <- intersect(pt_parents_in_list, src_tbls_impl(dm))

      if (length(pt_parents_in_list) > 0) {
        out <- dm_flatten_impl(dm, pt, pt_parents_in_list, recursive = TRUE, allow_deep = FALSE)
        list(dm = out$dm, all_renames = c(acc$all_renames, out$all_renames))
      } else {
        acc
      }
    },
    .init = list(dm = dm, all_renames = list())
  )
}

#' @autoglobal
dm_flatten_join <- function(dm, start, parents, allow_deep) {
  if (is_empty(parents)) {
    return(list(dm = dm, all_renames = list()))
  }

  all_fks <- dm_get_all_fks_impl(dm, ignore_on_delete = TRUE)

  start_tbl <- tbl_impl(dm, start)
  current_cols <- colnames(start_tbl)

  # Track renames per parent (old_name -> new_name)
  parent_col_renames <- list()
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
    parent_col_renames[[pt]] <- renames

    # Perform the join
    start_tbl <- left_join(start_tbl, parent_tbl, by = by)

    # Update current columns for next iteration
    current_cols <- colnames(start_tbl)
  }

  # Build result dm
  def <- dm_get_def(dm)
  start_idx <- which(def$table == start)
  def$data[[start_idx]] <- start_tbl

  # Handle allow_deep: transfer FKs from parents to start
  if (allow_deep) {
    def <- dm_flatten_transfer_fks(def, dm, start, parents, parent_col_renames, all_fks)
  }

  dm_result <- dm_from_def(def)

  # Remove parent tables
  remaining <- setdiff(def$table, parents)
  remaining <- set_names(remaining)

  list(dm = dm_select_tbl_impl(dm_result, remaining), all_renames = all_renames)
}

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

#' @autoglobal
dm_flatten_transfer_fks <- function(def, dm, start, parents, parent_col_renames, all_fks) {
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
      renames <- parent_col_renames[[pt]]
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

  def
}
