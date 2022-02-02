#' Nest a table inside its dm
#'
#' `dm_nest_tbl()` converts a child table to a nested column in its parent
#' table.
#' The child table should not have children itself (i.e. it needs to be a
#' *terminal child table*).
#'
#' @param dm A dm.
#' @param child_tables A table. Support for nesting multiple tables at once
#'   is planned but not implemented yet.
#' @param into The table to nest `child_tables` into, optional as it can be guessed
#'   from the foreign keys unambiguously but useful to be explicit.
#'
#' @seealso [dm::dm_wrap_tbl()], [dm::dm_unwrap_tbl()], [dm_pack_tbl()]
#' @export
#' @examples
#' nested_dm <-
#'   dm_nycflights13() %>%
#'   dm_select_tbl(airlines, flights) %>%
#'   dm_nest_tbl(flights)
#'
#' nested_dm
#' nested_dm$airlines
dm_nest_tbl <- function(dm, child_tables, into = NULL) {
  # process args
  into <- enquo(into)
  # FIXME: Rename table_name to child_tables_name
  table_name <- dm_tbl_name(dm, {{ child_tables }})

  # retrieve fk and parent_name
  fks <- dm_get_all_fks(dm)

  # retrieve fk and parent_name
  # FIXME: fix redundancies and DRY when we decide what we export
  fks <- dm_get_all_fks(dm)
  children <-
    fks %>%
    filter(parent_table == !!table_name) %>%
    pull(child_table)
  fk <- filter(fks, child_table == !!table_name)
  parent_fk <- unlist(fk$parent_key_cols)
  child_fk <- unlist(fk$child_fk_cols)
  child_pk <-
    dm_get_all_pks(dm) %>%
    filter(table == !!table_name) %>%
    pull(pk_col) %>%
    unlist()
  parent_name <- pull(fk, parent_table)

  # make sure we have a terminal child
  if (length(children) || !length(parent_name) || length(parent_name) > 1) {
    if (length(parent_name)) {
      parent_msg <- paste0("\nparents: ", toString(paste0("`", parent_name, "`")))
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

  # update def and rebuild dm
  def$data[def$table == parent_name] <- list(nested_data)
  old_parent_table_fk <- def[def$table == parent_name, ][["fks"]][[1]]
  new_parent_table_fk <- filter(old_parent_table_fk, table != table_name)
  def[def$table == parent_name, ][["fks"]][[1]] <- new_parent_table_fk
  def <- def[def$table != table_name, ]

  new_dm3(def)
}

#' dm_pack_tbl()
#'
#' `dm_pack_tbl()` converts a parent table to a packed column in its child
#' table.
#' The parent table should not have parent tables itself (i.e. it needs to be a
#' *terminal parent table*).
#'
#' @param dm A dm.
#' @param parent_tables A table. Support for packing multiple tables at once
#'   is planned but not implemented yet.
#' @param into The table to pack `parent_tables` into, optional as it can be guessed
#'   from the foreign keys unambiguously but useful to be explicit.
#'
#' @seealso [dm::dm_wrap_tbl()], [dm::dm_unwrap_tbl()], [dm_nest_tbl()].
#' @export
#' @examples
#' dm_packed <-
#'   dm_nycflights13() %>%
#'   dm_pack_tbl(planes)
#'
#' dm_packed
#' dm_packed$flights
#' dm_packed$flights$planes
dm_pack_tbl <- function(dm, parent_tables, into = NULL) {
  # process args
  into <- enquo(into)
  # FIXME: Rename to parent_tables_name
  table_name <- dm_tbl_name(dm, {{ parent_tables }})

  # retrieve keys, child and parent
  # FIXME: fix redundancies and DRY when we decide what we export
  fks <- dm_get_all_fks(dm)
  parents <-
    fks %>%
    filter(child_table == !!table_name) %>%
    pull(parent_table)
  fk <- filter(fks, parent_table == !!table_name)
  child_fk <- unlist(fk$child_fk_cols)
  parent_fk <- unlist(fk$parent_key_cols)
  parent_pk <-
    dm_get_all_pks(dm) %>%
    filter(table == !!table_name) %>%
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

  # update def and rebuild dm
  def$data[def$table == child_name] <- list(packed_data)
  def <- def[def$table != table_name, ]

  new_dm3(def)
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
