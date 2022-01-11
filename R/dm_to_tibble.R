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

dm_to_tibble <- function(dm, root, silent = FALSE) {
  root_name <- dm_tbl_name(dm, {{ root }})
  dm_msg <- dm_wrap_all_impl(dm, {{ root }}, strict = TRUE)
  if (!silent) {
    inform(paste0(
      "Rebuild a dm from this object using : %>%\n",
      "  dm(", root_name, " = .) %>%\n",
      dm_msg$msg))
  }
  dm_get_tables_impl(dm_msg$dm)[[root_name]]
}

#' Convert a tibble to a dm
#'
#' @param x a wrapped table, as created by `dm_to_tibble()`
#' @param specs a dm (usually the one used in the `dm_to_tibble()` call that
#'   created `table`) or a list containing named elements `pks` and `fks`,
#'   looking like the respective outputs of `dm_get_all_pks()` and `dm_get_all_fks()`
#' @param root the root table (unquoted), optional because we can usually infer it from
#'  `table` and `specs`
#'
#' @noRd
tibble_to_dm <- function(x, specs, root = NULL) {
  # process args
  if (is_dm(specs)) {
    specs <- list(
      pks = dm_get_all_pks(specs),
      fks = dm_get_all_fks(specs)
    )
  }
  root_expr <- enexpr(root)
  all_connected_tables <- union(specs$fks$child_table, specs$fks$parent_table)
  root_name <- names(eval_select_indices(root_expr, all_connected_tables))

  # find root candidates by retrieving table(s) with rightly named parents/children
  nms <- names(x)
  children <- nms[map_lgl(x, inherits, "nested")]
  parents <- nms[map_lgl(x, inherits, "packed")]
  if (length(parents)) {
    candidates_with_correct_parents <-
      specs$fks %>%
      with_groups(child_table, filter, setequal(parent_table, parents)) %>%
      pull(child_table) %>%
      unique()
  } else {
    # children with no fk
    candidates_with_correct_parents <-
      setdiff(specs$fks$parent_table, specs$fks$child_table)
  }
  if (length(children)) {
    candidates_with_correct_children <-
      specs$fks %>%
      with_groups(parent_table, filter, setequal(child_table, children)) %>%
      pull(parent_table) %>%
      unique()
  } else {
    # parents which no fk points to
    candidates_with_correct_children <-
      setdiff(specs$fks$child_table, specs$fks$parent_table)
  }
  candidates <- intersect(
    candidates_with_correct_parents,
    candidates_with_correct_children
  )

  # check root_name's consistency and unambiguity of candidates
  if (!length(root_name)) {
    if (length(candidates) == 0) {
      abort("`x` and `specs` are uncompatible, cannot unwrap `x` to a dm")
    }
    if (length(candidates) > 1) {
      abort(glue(
        "Could not guessed the name of the root table from the input. ",
        "Pick one among: {paste0(\"'\", candidates, \"'\", collapse= \", \")}"
      ))
    }
    root_name <- candidates
  } else {
    if (!root_name %in% candidates) {
      abort(glue("`{root_name}` is not a valid choice for the root table"))
    }
  }

  # define new single tibble dm with pk if relevant
  dm <- dm(!!root_name := x)
  pk <- specs$pks %>%
    filter(table == root_name) %>%
    pull(pk_col) %>%
    unlist()
  if (length(pk)) {
    dm <- dm_add_pk(dm, !!root_name, !!pk)
  }

  # forward to dm_unwrap_all
  dm_unwrap_all(dm, specs)
}

dm_wrap_all <- function(dm, root, silent = FALSE, strict = TRUE) {
  dm_msg <- dm_wrap_all_impl(dm, {{root}}, strict = strict)
  if(!silent) {
    inform(paste0("Rebuild a dm from this object using : %>%\n", dm_msg$msg))
  }
  dm_msg$dm
}

dm_wrap_all_impl <- function(dm, root, strict = TRUE) {
  # process args
  root_name <- dm_tbl_name(dm, {{ root }})

  # initiate graph and positions
  graph <- create_graph_from_dm(dm, directed = TRUE)
  positions <- node_type_from_graph(graph, drop = root_name)
  msgs <- character()

  # wrap terminal nodes as long as they're not the root
  repeat {
    child_name <- names(positions)[positions == "terminal child"][1]
    has_terminal_child <- !is.na(child_name)
    if (has_terminal_child) {
      dm_msg <- dm_nest_tbl_impl(dm, !!child_name)
      dm <- dm_msg$dm
      msgs <- c(msgs, dm_msg$msg)
      graph <- igraph::delete.vertices(graph, child_name)
      positions <- node_type_from_graph(graph, drop = root_name)
    }
    parent_name <- names(positions)[positions == "terminal parent"][1]
    has_terminal_parent <- !is.na(parent_name)
    if (has_terminal_parent) {
      dm_msg <- dm_pack_tbl_impl(dm, !!parent_name)
      dm <- dm_msg$dm
      msgs <- c(msgs, dm_msg$msg)
      graph <- igraph::delete.vertices(graph, parent_name)
      positions <- node_type_from_graph(graph, drop = root_name)
    }
    if (!has_terminal_child && !has_terminal_parent) break
  }

  # inform or fail if we have a cycle
  if (length(dm) > 1) {
    if (strict) {
      abort("The `dm` is not cycle free and can't be wrapped in a single tibble.")
    }
    inform("The `dm` is not cycle free, returning a partially wrapped multi table 'dm'.")
  }

  list(dm = dm, msg = paste(rev(msgs), collapse = " %>%\n"))
}

dm_unwrap_all <- function(dm, specs) {
  # process specs
  if (is_dm(specs)) {
    specs <- list(
      pks = dm_get_all_pks(specs),
      fks = dm_get_all_fks(specs)
    )
  }

  # unwrap all tables and their unwrapped children/parents
  unwrapped_table_names <- character(0)
  repeat {
    to_unwrap <- setdiff(names(dm), unwrapped_table_names)[1]
    done_unwrapping <- is.na(to_unwrap)
    if (done_unwrapping) break
    dm <- dm_unwrap(dm, !!to_unwrap, specs)
    unwrapped_table_names <- c(unwrapped_table_names, to_unwrap)
  }

  dm
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
    "isolated" = abort(glue(
      "`{table_name}` is an isolated table (no parent and no child), ",
      "it cannot be wrapped into a connected table"
    )),
    "intermediate" = {
      fks <- dm_get_all_fks(dm)
      parents <- filter(fks, child_table == table_name) %>% pull(parent_table)
      children <- filter(fks, parent_table == table_name) %>% pull(child_table)
      if (length(parents)) {
        parent_msg <- paste0("\nparents : ", toString(paste0("`", parents, "`")))
      } else {
        parent_msg <- ""
      }
      if (length(children)) {
        children_msg <- paste0("\nchildren: ", toString(paste0("`", children, "`")))
      } else {
        children_msg <- ""
      }
      abort(glue(
        "`{table_name}` is not a terminal parent or child table, ",
        "it's connected to more than one table.{parent_msg}{children_msg}"
      ))
    },
    "terminal child" = dm_nest_tbl(dm, {{ table }}, !!into, silent),
    "terminal parent" = dm_pack_tbl(dm, {{ table }}, !!into, silent)
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
  for (child_name in children) {
    dm <- dm_unnest_tbl(dm, !!table_name, col = !!child_name, specs)
  }

  # unpack parent tables
  for (parent_name in parents) {
    dm <- dm_unpack_tbl(dm, !!table_name, col = !!parent_name, specs)
  }

  dm
}

dm_pack_tbl <- function(dm, table, into = NULL, silent = FALSE) {
  dm_msg <- dm_pack_tbl_impl(dm, {{table}}, into = {{into}})
  if(!silent) {
    inform(paste0("Rebuild a dm from this object using : %>%\n", dm_msg$msg))
  }
  dm_msg$dm
}


dm_pack_tbl_impl <- function(dm, table, into = NULL) {
  # process args
  into <- enquo(into)
  table_name <- dm_tbl_name(dm, {{ table }})

  # retrieve fk and child_name, making sure we have a terminal parent
  # FIXME: fix redundancies and DRY when we decide what we export
  fks <- dm_get_all_fks(dm)
  parents <-
    fks %>%
    filter(child_table == table_name) %>%
    pull(parent_table)
  fk <- filter(fks, parent_table == table_name)
  child_name <- pull(fk, child_table)
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
  by <- with(fk, set_names(unlist(parent_key_cols), unlist(child_fk_cols)))
  packed_data <- pack_join(child_data, table_data, by = by, name = table_name)
  class(packed_data[[table_name]]) <- c("packed", class(packed_data[[table_name]]))

  # output rebuilding code
  child_fk <- capture.output(dput(names(by)))
  parent_pk <- capture.output(dput(unname(by)))
  msg <- glue(
    "  dm_unpack_tbl({child_name}, {table_name}, list(",
    "child_fk = {child_fk}, parent_pk = {parent_pk}))",
    .trim = FALSE
  )

  # update def and rebuild dm
  def$data[def$table == child_name] <- list(packed_data)
  def <- def[def$table != table_name, ]

  list(dm = new_dm3(def), msg = msg)
}

dm_nest_tbl <- function(dm, table, into = NULL, silent = FALSE) {
  dm_msg <- dm_nest_tbl_impl(dm, {{table}}, into = {{into}})
  if(!silent) {
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

  # retrieve fk and parent_name, making sure we have a terminal child
  # FIXME: fix redundancies and DRY when we decide what we export
  fks <- dm_get_all_fks(dm)
  children <-
    fks %>%
    filter(parent_table == table_name) %>%
    pull(child_table)
  fk <- filter(fks, child_table == table_name)
  parent_name <- pull(fk, parent_table)
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
  by <- with(fk, set_names(unlist(child_fk_cols), unlist(parent_key_cols)))
  nested_data <- nest_join(parent_data, table_data, by = by, name = table_name)
  class(nested_data[[table_name]]) <- c("nested", class(nested_data[[table_name]]))

  # output rebuilding code
  child_fk <- capture.output(dput(unname(by)))
  pks <- dm_get_all_pks(dm)
  parent_pk <-
    pks %>%
    filter(table == parent_name) %>%
    pull(pk_col) %>%
    unlist()
  parent_pk <- capture.output(dput(parent_pk))
  child_pk <-
    pks %>%
    filter(table == table_name) %>%
    pull(pk_col) %>%
    unlist()
  child_pk <- capture.output(dput(child_pk))
  msg <- glue(
    "  dm_unnest_tbl({parent_name}, {table_name}, list(",
    "child_fk = {child_fk}, parent_pk = {parent_pk}, child_pk = {child_pk}))",
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

dm_unnest_tbl <- function(dm, table, col, specs) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  col_expr <- enexpr(col)
  new_table_name <- names(eval_select_indices(col_expr, colnames(table)))
  if (is_dm(specs)) {
    specs <- list(
      pks = dm_get_all_pks(specs),
      fks = dm_get_all_fks(specs)
    )
    pk <- specs$pks %>%
      filter(table == new_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <- specs$fks %>%
      filter(child_table == new_table_name, parent_table == table_name) %>%
      with(set_names(unlist(parent_key_cols), unlist(child_fk_cols)))
  } else if(setequal(names(specs), c("pks", "fks"))) {
    #FIXME : handle different specs formats better (validation + DRY + doc)
    pk <- specs$pks %>%
      filter(table == new_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <- specs$fks %>%
      filter(child_table == new_table_name, parent_table == table_name) %>%
      with(set_names(unlist(parent_key_cols), unlist(child_fk_cols)))
    } else {
    if(!is_bare_list(specs) && setequal(names(specs), c("parent_pk", "child_fk"))) {
      abort("`specs` should be a dm or a list")
    }
    pk <- specs[["child_pk"]]
    fk <- set_names(specs[["parent_pk"]], specs[["child_fk"]])
  }

  # retrieve fk and extract nested table
  new_table <- table %>%
    select(!!!fk, !!new_table_name) %>%
    unnest(!!new_table_name) %>%
    distinct()

  # update the dm by adding new table, removing nested col and setting keys
  dm <- dm_add_tbl(dm, !!new_table_name := new_table)
  dm <- dm_select(dm, !!table_name, -all_of(new_table_name))
  if (length(fk)) {
    # need to unname because of #739
    dm <- dm_add_fk(dm, !!new_table_name, !!names(fk), !!table_name, !!unname(fk))
  }
  if (length(pk)) {
    dm <- dm_add_pk(dm, !!new_table_name, !!pk)
  }

  dm
}

dm_unpack_tbl <- function(dm, table, col, specs) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  col_expr <- enexpr(col)
  new_table_name <- names(eval_select_indices(col_expr, colnames(table)))
  if (is_dm(specs)) {
    specs <- list(
      pks = dm_get_all_pks(specs),
      fks = dm_get_all_fks(specs)
    )
    pk <- specs$pks %>%
      filter(table == new_table_name) %>%
      pull(pk_col) %>%
      unlist()

    fk <- specs$fks %>%
      filter(child_table == table_name, parent_table == new_table_name) %>%
      with(set_names(unlist(child_fk_cols), unlist(parent_key_cols)))
  } else if(setequal(names(specs), c("pks", "fks"))) {
    #FIXME : handle different specs formats better (validation + DRY + doc)
    pk <- specs$pks %>%
      filter(table == new_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <- specs$fks %>%
      filter(child_table == table_name, parent_table == new_table_name) %>%
      with(set_names(unlist(child_fk_cols), unlist(parent_key_cols)))
  } else {
    if(!is_bare_list(specs)) {
      abort("`specs` should be a dm or a list")
    }
    pk <- specs[["parent_pk"]]
    fk <- set_names(specs[["child_fk"]], pk)
  }

  # retrieve fk and extract packed table

  new_table <- table %>%
    select(!!!fk, !!new_table_name) %>%
    unpack(!!new_table_name) %>%
    distinct()

  # update the dm by adding new table, removing packed col and setting keys
  dm <- dm_add_tbl(dm, !!new_table_name := new_table)
  dm <- dm_select(dm, !!table_name, -all_of(new_table_name))
  if (length(fk)) {
    # need to unname because of #739
    dm <- dm_add_fk(dm, !!table_name, !!unname(fk), !!new_table_name, !!names(fk))
  }

  if (length(pk)) {
    dm <- dm_add_pk(dm, !!new_table_name, !!pk)
  }

  dm
}
