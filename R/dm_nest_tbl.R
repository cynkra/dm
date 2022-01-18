#' Nest or pack a table inside its dm
#'
#' `dm_nest_tbl()` converts a child table to a nested column in its parent
#' table.
#' The child table should not have children itself (i.e. it needs to be a
#' *terminal child table*).
#'
#' @param dm A dm.
#' @param table A table.
#' @param into The table to wrap `table` into, optional as it can be guessed
#'   from the foreign keys unambiguously but useful to be explicit.
#' @param silent if not silent (the default), the code to unwrap will be printed.
#'
#' @seealso [dm::dm_wrap], [dm::dm_unwrap]
#' @export
dm_nest_tbl <- function(dm, table, into = NULL, silent = FALSE) {
  dm_msg <- dm_nest_tbl_impl(dm, {{ table }}, into = {{ into }})
  if (!silent) {
    inform(paste0("Rebuild a dm from this object using : %>%\n", dm_msg$msg))
  }
  dm_msg$dm
}

dm_nest_tbl_impl <- function(dm, table, into = NULL) {
  # process args
  into <- enquo(into)
  table_name <- dm_tbl_name(dm, {{ table }})

  # retrieve fk and parent_name
  fks <- dm_get_all_fks(dm)

  # retrieve fk and parent_name
  # FIXME: fix redundancies and DRY when we decide what we export
  fks <- dm_get_all_fks(dm)
  children <-
    fks %>%
    filter(parent_table == table_name) %>%
    pull(child_table)
  fk <- filter(fks, child_table == table_name)
  parent_fk <- unlist(fk$parent_key_cols)
  child_fk <- unlist(fk$child_fk_cols)
  child_pk <-
    dm_get_all_pks(dm) %>%
    filter(table == table_name) %>%
    pull(pk_col) %>%
    unlist()
  parent_name <- pull(fk, parent_table)

  # make sure we have a terminal child
  if (length(children) || !length(parent_name) || length(parent_name) > 1) {
    if (length(parent_name)) {
      parent_msg <- paste0("\nparents : ", toString(paste0("`", parent_name, "`")))
    } else {
      parent_msg <- ""
    }
    if (length(children)) {
      children_msg <- paste0("\nchildren: ", toString(paste0("`", children, "`")))
    } else {
      children_msg <- ""
    }
    abort(glue(
      "`{table_name}` can't be nested because it is not a terminal child table.",
      "{parent_msg}{children_msg}"
    ))
  }

  # check consistency of `into` if relevant
  if (!quo_is_null(into)) {
    into <- dm_tbl_name(dm, !!into)
    if (into != parent_name) {
      abort(glue("`{table_name}` can only be packed into `{child_name}`"))
    }
  }

  # fetch def and join tables
  def <- dm_get_def(dm, quiet = TRUE)
  table_data <- def$data[def$table == table_name][[1]]
  parent_data <- def$data[def$table == parent_name][[1]]
  nested_data <- nest_join(parent_data, table_data, by = set_names(child_fk, parent_fk), name = table_name)
  class(nested_data[[table_name]]) <- c("nested", class(nested_data[[table_name]]))

  # output rebuilding code
  if (length(parent_fk) > 1) {
    parent_fk_str <- paste0("c(", toString(parent_fk), ")")
  } else {
    parent_fk_str <- parent_fk
  }
  child_fk_quoted <- paste0('"', child_fk, '"')
  if (length(child_fk) > 1) {
    child_fk_str <- paste0("c(", toString(child_fk_quoted), ")")
  } else {
    child_fk_str <- child_fk_quoted
  }
  child_pk_quoted <- paste0('"', child_pk, '"')
  if (length(child_pk) > 1) {
    child_pk_str <- paste0("c(", toString(child_pk_quoted), ")")
  } else {
    child_pk_str <- child_pk_quoted
  }
  msg <- glue(
    "  dm_unnest_tbl({parent_name}, {table_name}, parent_fk = {parent_fk_str}",
    ", child_fk_names = {child_fk_str}",
    if (length(child_pk)) ", child_pk_names = {child_pk_str})" else ")",
    .trim = FALSE
  )

  # update def and rebuild dm
  def$data[def$table == parent_name] <- list(nested_data)
  old_parent_table_fk <- def[def$table == parent_name, ][["fks"]][[1]]
  new_parent_table_fk <- filter(old_parent_table_fk, table != table_name)
  def[def$table == parent_name, ][["fks"]][[1]] <- new_parent_table_fk
  def <- def[def$table != table_name, ]

  list(dm = new_dm3(def), msg = msg)
}

#' dm_pack_tbl()
#'
#' `dm_pack_tbl()` converts a parent table to a packed column in its child
#' table.
#' The parent table should not have parent tables itself (i.e. it needs to be a
#' *terminal parent table*).
#'
#' @export
#' @rdname dm_nest_tbl
dm_pack_tbl <- function(dm, table, into = NULL, silent = FALSE) {
  dm_msg <- dm_pack_tbl_impl(dm, {{ table }}, into = {{ into }})
  if (!silent) {
    inform(paste0("Rebuild a dm from this object using : %>%\n", dm_msg$msg))
  }
  dm_msg$dm
}

dm_pack_tbl_impl <- function(dm, table, into = NULL) {
  # process args
  into <- enquo(into)
  table_name <- dm_tbl_name(dm, {{ table }})

  # retrieve keys, child and parent
  # FIXME: fix redundancies and DRY when we decide what we export
  fks <- dm_get_all_fks(dm)
  parents <-
    fks %>%
    filter(child_table == table_name) %>%
    pull(parent_table)
  fk <- filter(fks, parent_table == table_name)
  child_fk <- unlist(fk$child_fk_cols)
  parent_fk <- unlist(fk$parent_key_cols)
  parent_pk <-
    dm_get_all_pks(dm) %>%
    filter(table == table_name) %>%
    pull(pk_col) %>%
    unlist()
  child_name <- pull(fk, child_table)

  # make sure we have a terminal parent
  if (length(parents) || !length(child_name) || length(child_name) > 1) {
    if (length(parents)) {
      parent_msg <- paste0("\nparents : ", toString(paste0("`", parents, "`")))
    } else {
      parent_msg <- ""
    }
    if (length(child_name)) {
      children_msg <- paste0("\nchildren: ", toString(paste0("`", child_name, "`")))
    } else {
      children_msg <- ""
    }
    abort(glue(
      "`{table_name}` can't be nested because it is not a terminal parent table.",
      "{parent_msg}{children_msg}"
    ))
  }

  # check consistency of `into` if relevant
  if (!quo_is_null(into)) {
    into <- dm_tbl_name(dm, !!into)
    if (into != child_name) {
      abort(glue("`{table_name}` can only be packed into `{child_name}`"))
    }
  }

  # fetch def and join tables
  def <- dm_get_def(dm, quiet = TRUE)
  table_data <- def$data[def$table == table_name][[1]]
  child_data <- def$data[def$table == child_name][[1]]
  packed_data <- pack_join(child_data, table_data, by = set_names(parent_fk, child_fk), name = table_name)
  class(packed_data[[table_name]]) <- c("packed", class(packed_data[[table_name]]))

  # output rebuilding code
  if (length(child_fk) > 1) {
    child_fk_str <- paste0("c(", toString(child_fk), ")")
  } else {
    child_fk_str <- child_fk
  }
  parent_fk_quoted <- paste0('"', parent_fk, '"')
  if (length(parent_fk) > 1) {
    parent_fk_str <- paste0("c(", toString(parent_fk_quoted), ")")
  } else {
    parent_fk_str <- parent_fk_quoted
  }
  parent_pk_quoted <- paste0('"', parent_pk, '"')
  if (length(parent_pk) > 1) {
    parent_pk_str <- paste0("c(", toString(parent_pk_quoted), ")")
  } else {
    parent_pk_str <- parent_pk_quoted
  }
  msg <- glue(
    "  dm_unpack_tbl({child_name}, {table_name}, child_fk = {child_fk_str}",
    ", parent_fk_names = {parent_fk_str}",
    if (length(parent_pk)) ", parent_pk_names = {parent_pk_str})" else ")",
    .trim = FALSE
  )

  # update def and rebuild dm
  def$data[def$table == child_name] <- list(packed_data)
  def <- def[def$table != table_name, ]

  list(dm = new_dm3(def), msg = msg)
}

# FIXME: can we be more efficient ?
node_type_from_graph <- function(graph, drop = NULL) {
  vertices <- igraph::V(graph)
  n_children <- map_dbl(vertices, ~ length(igraph::neighbors(graph, .x, mode = 'in')))
  n_parents <- map_dbl(vertices, ~ length(igraph::neighbors(graph, .x, mode = 'out')))
  node_types <- set_names(rep_along(vertices, "intermediate"), names(vertices))
  node_types[n_parents == 0 & n_children == 1] <- "terminal parent"
  node_types[n_children == 0 & n_parents == 1] <- "terminal child"
  node_types[n_children == 0 & n_parents == 0] <- "isolated"
  node_types[!names(node_types) %in% drop]
}
