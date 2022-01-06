node_type_from_graph <- function(graph, drop = NULL) {
  vertices <- igraph::V(graph)
  n_children <- map_dbl(vertices, ~length(igraph::neighbors(graph, .x, mode = 'in')))
  n_parents  <- map_dbl(vertices, ~length(igraph::neighbors(graph, .x, mode = 'out')))
  node_types <- set_names(rep_along(vertices, "intermediate"), names(vertices))
  node_types[n_parents == 0 & n_children == 1] <- "terminal parent"
  node_types[n_children == 0 & n_parents == 1] <- "terminal child"
  node_types[n_children == 0 & n_parents == 0] <- "isolated"
  node_types[!names(node_types) %in% drop]
}

#' wrap a table from a dm
#'
#' @param dm a dm
#' @param table a table, it needs to have either no parent or no child, but not
#'   both of these.
#' @param into the table to wrap `table` into, optional as it can be guessed
#'   from the foreign keys unambiguously but useful to be explicit.
#' @param silent if not silent (the default), the code to unwrap will be printed
#'
#' @noRd
dm_wrap <- function(dm, table, into = NULL, silent = FALSE) {
  # process args and build name
  into <- enquo(into)
  table_name <- dm_tbl_name(dm, {{ table }})

  # retrieve position of table
  graph <- create_graph_from_dm(dm, directed = TRUE)
  positions <- node_type_from_graph(graph)
  position <- positions[table_name]

  # nest, pack or fail appropriately
  new_dm <- switch(
    position,
    "isolated" =,
    "intermediate" = abort(glue("'{table_name}' is not a terminal parent or child table")),
    "terminal child"  = dm_nest_wrap(dm, {{table}}, !!into, silent),
    "terminal parent" = dm_pack_wrap(dm, {{table}}, !!into, silent)
  )

  new_dm
}

dm_unwrap <- function(dm, table, specs) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  nms <- names(table)

  # detect parent and children tables
  children <- nms[map_lgl(table, inherits, "nested")]
  parents <- nms[map_lgl(table, inherits, "packed")]

  # unnest children tables
  for(child_name in children) {
    dm <- dm_unnest_unwrap(dm, !!table_name, col = !!child_name, specs)
  }

  # unpack parent tables
  for(parent_name in parents) {
    dm <- dm_unpack_unwrap(dm, !!table_name, col = !!parent_name, specs)
  }

  dm
}

dm_pack_wrap <- function(dm, table, into = NULL, silent = FALSE) {
  # process args
  into <- enquo(into)
  table_name <- dm_tbl_name(dm, {{ table }})

  # retrieve fk and child_name
  fk <- dm_get_all_fk(dm) %>% filter(parent_table == table_name)
  child_name <- pull(fk, child_table)

  # check consistency of `into` if relevant
  if(!quo_is_null(into)) {
    into <- dm_tbl_name(dm, !!into)
    if(into != child_name) {
      abort(glue("'{table_name}' can only be packed into '{child_name}'"))
    }
  }

  # fetch def and join tables
  def <- dm_get_def(dm, quiet = TRUE)
  table_data <- def$data[def$table == table_name][[1]]
  child_data <- def$data[def$table == child_name][[1]]
  by <- with(fks, set_names(unlist(parent_key_cols), unlist(child_fk_cols)))
  packed_data <- pack_join(child_data, table_data, by = by, name = table_name)
  class(packed_data[[table_name]]) <- c("packed", class(packed_data[[table_name]]))

  # update def and rebuild dm
  def$data[def$table == child_name] <- list(packed_data)
  def <- def[def$table != table_name,]
  new_dm3(def)
}

dm_nest_wrap <- function(dm, table, into = NULL, silent = FALSE) {
  # process args
  into <- enquo(into)
  table_name <- dm_tbl_name(dm, {{ table }})

  # retrieve fk and parent_name
  fks <- dm_get_all_fks(dm) %>% filter(child_table == table_name)
  parent_name <- pull(fks, parent_table)

  # check consistency of `into` if relevant
  if(!quo_is_null(into)) {
    into <- dm_tbl_name(dm, !!into)
    if(into != parent_name) {
      abort(glue("'{table_name}' can only be packed into '{child_name}'"))
    }
  }

  # fetch def and join tables
  def <- dm_get_def(dm, quiet = TRUE)
  table_data <- def$data[def$table == table_name][[1]]
  parent_data <- def$data[def$table == parent_name][[1]]
  by <- with(fks, set_names(unlist(child_fk_cols), unlist(parent_key_cols)))
  nested_data <- nest_join(parent_data, table_data, by = by, name = table_name)
  class(nested_data[[table_name]]) <- c("nested", class(nested_data[[table_name]]))

  # update def and rebuild dm
  def$data[def$table == parent_name] <- list(nested_data)
  old_parent_table_fks <- def[def$table == parent_name, ][["fks"]][[1]]
  new_parent_table_fks <- filter(old_parent_table_fks, table != table_name)
  def[def$table == parent_name, ][["fks"]][[1]] <- new_parent_table_fks
  def <- def[def$table != table_name, ]
  new_dm3(def)
}

dm_unnest_unwrap <- function(dm, table, col, specs) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  col_expr <- enexpr(col)
  new_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  # retrieve fk and extract nested table
  fk <- specs$fk %>%
    filter(child_table == new_table_name, parent_table == table_name) %>%
    with(set_names(unlist(parent_key_cols), unlist(child_fk_cols)))
  new_table <- table %>%
    select(!!!fk, !!new_table_name) %>%
    unnest(!!new_table_name)

  # update the dm by adding new table, removing nested col and setting keys
  dm <- dm_add_tbl(dm, !!new_table_name := new_table)
  dm <- dm_select(dm, !!table_name, -all_of(new_table_name))
  if(length(fk)) {
    dm <- dm_add_fk(dm, !!new_table_name, !!names(fk), !!table_name, !!fk)
  }
  pk <- specs$pk %>%
    filter(table == new_table_name) %>%
    pull(pk_col) %>%
    unlist()
  if(length(pk)) {
    dm <- dm_add_pk(dm, !!new_table_name, !!pk)
  }

  dm
}

dm_unpack_unwrap <- function(dm, table, col, specs) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  col_expr <- enexpr(col)
  new_table_name <- names(eval_select_indices(col_expr, colnames(table)))
  if(is_dm(specs)) {
    specs <- list(
      pks = dm_get_all_pks(specs),
      fks = dm_get_all_fks(specs)
    )
  }

  # retrieve fk and extract packed table
  fk <- specs$fk %>%
    filter(child_table == table_name, parent_table == new_table_name) %>%
    with(set_names(unlist(child_fk_cols), unlist(parent_key_cols)))
  new_table <- table %>%
    select(!!!fk, !!new_table_name) %>%
    unpack(!!new_table_name)

  # update the dm by adding new table, removing packed col and setting keys
  dm <- dm_add_tbl(dm, !!new_table_name := new_table)
  dm <- dm_select(dm, !!table_name, -all_of(new_table_name))
  if(length(fk)) {
    dm <- dm_add_fk(dm, !!table_name, !!fk, !!new_table_name, !!names(fk))
  }
  pk <- specs$pk %>%
    filter(table == new_table_name) %>%
    pull(pk_col) %>%
    unlist()
  if(length(pk)) {
    dm <- dm_add_pk(dm, !!new_table_name, !!pk)
  }

  dm
}
