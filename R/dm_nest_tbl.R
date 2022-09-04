#' Nest a table inside its dm
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dm_nest_tbl()` converts a child table to a nested column in its parent
#' table.
#' The child table should not have children itself (i.e. it needs to be a
#' *terminal child table*).
#'
#' @param dm A dm.
#' @param child_table A terminal table with one parent table.
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
#'
#' nested_dm$airlines
dm_nest_tbl <- function(dm, child_table, into = NULL) {
  # process args
  into <- enquo(into)
  # FIXME: Rename table_name to child_tables_name
  table_name <- dm_tbl_name(dm, {{ child_table }})

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
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dm_pack_tbl()` converts a parent table to a packed column in its child
#' table.
#' The parent table should not have parent tables itself (i.e. it needs to be a
#' *terminal parent table*).
#'
#' @param dm A dm.
#' @param parent_table A terminal table with one child table.
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
#'
#' dm_packed$flights
#'
#' dm_packed$flights$planes
dm_pack_tbl <- function(dm, parent_table, into = NULL) {
  # process args
  into <- enquo(into)
  table_name <- dm_tbl_name(dm, {{ parent_table }})

  fks <- dm_get_all_fks(dm)
  fk <- filter(fks, parent_table == !!table_name)
  children_names <- pull(fk, child_table)

  check_table_can_be_packed(table_name, children_names, fks)
  child_name <- children_names # we checked we had only one

  pks <- dm_get_all_pks(dm)
  pk <- filter(pks, table == !!table_name)
  child_fk <- unlist(fk$child_fk_cols)
  parent_fk <- unlist(fk$parent_key_cols)
  parent_pk <- unlist(pk$pk_col)

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
  #packed_data <- pack_join(child_data, table_data, by = set_names(parent_fk, child_fk), name = table_name)
  #class(packed_data[[table_name]]) <- c("packed", class(packed_data[[table_name]]))
  new_names <- names(table_data)
  fk_lgl <- new_names %in% parent_fk
  pk_lgl <- new_names %in% parent_pk
  new_names[fk_lgl] <- paste0(parent_fk, "=", child_fk)
  new_names[pk_lgl] <- paste0(new_names[pk_lgl], "*")
  new_parent_fk <- new_names[fk_lgl]
  # FIXME: fail if weird names exist already
  table_data <- set_names(table_data, new_names)
  packed_data <- pack_join(
    child_data,
    table_data,
    by = set_names(new_parent_fk, child_fk),
    name = paste0(table_name, "<"),
    keep = TRUE
  )

  # update def and rebuild dm
  def$data[def$table == child_name] <- list(packed_data)
  def <- def[def$table != table_name, ]

  new_dm3(def)
}

check_table_can_be_packed <- function(table_name, children_names, fks) {
  # make sure we have a terminal parent
  parents <-
    fks %>%
    filter(child_table == !!table_name) %>%
    pull(parent_table)

  table_has_parents <- length(parents) > 0
  table_has_one_child <- length(children_names) == 1
  table_is_terminal_parent <- table_has_one_child && !table_has_parents
  if (!table_is_terminal_parent) {
    if (table_has_parents) {
      parent_msg <- paste0("\nparents : ", toString(paste0("`", parents, "`")))
    } else {
      parent_msg <- ""
    }
    table_has_children <- length(children_names) > 0
    if (table_has_children) {
      children_msg <- paste0("\nchildren: ", toString(paste0("`", children_names, "`")))
    } else {
      children_msg <- ""
    }
    abort(glue(
      "`{table_name}` can't be packed because it is not a terminal parent table.",
      "{parent_msg}{children_msg}"
    ))
  }
  invisible(NULL)
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
