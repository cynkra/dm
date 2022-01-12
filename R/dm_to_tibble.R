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
    pk <- dm_get_all_pks(dm) %>%
      filter(table == root_name) %>%
      pull(pk_col) %>%
      unlist()
    inform(glue(
      "Rebuild a dm from this object using : %>%\n",
      "  dm({root_name} = .) %>%\n",
      if(!length(pk)) "" else "  dm_add_pk({root_name}, {capture.output(dput(pk))}) %>%\n",
      dm_msg$msg,
      .trim = FALSE,
    ))
  }
  dm_get_tables_impl(dm_msg$dm)[[root_name]]
}

#' Convert a tibble to a dm
#'
#' @param x a wrapped table, as created by `dm_to_tibble()`
#' @param prototype a dm (usually the one used in the `dm_to_tibble()`), might be an
#'   empty prototype since only the information about keys will be used
#' @param root the root table (unquoted), optional because we can usually infer it from
#'  `table` and `specs`
#'
#' @noRd
tibble_to_dm <- function(x, prototype, root = NULL) {
  # process args
  check_dm(prototype)
  pks <- dm_get_all_pks(prototype)
  fks <- dm_get_all_fks(prototype)

  root_expr <- enexpr(root)
  all_connected_tables <- union(fks$child_table, fks$parent_table)
  root_name <- names(eval_select_indices(root_expr, all_connected_tables))

  # find root candidates by retrieving table(s) with rightly named parents/children
  nms <- names(x)
  children <- nms[map_lgl(x, inherits, "nested")]
  parents <- nms[map_lgl(x, inherits, "packed")]
  if (length(parents)) {
    candidates_with_correct_parents <-
      fks %>%
      with_groups(child_table, filter, setequal(parent_table, parents)) %>%
      pull(child_table) %>%
      unique()
  } else {
    # children with no fk
    candidates_with_correct_parents <-
      setdiff(fks$parent_table, fks$child_table)
  }
  if (length(children)) {
    candidates_with_correct_children <-
      fks %>%
      with_groups(parent_table, filter, setequal(child_table, children)) %>%
      pull(parent_table) %>%
      unique()
  } else {
    # parents which no fk points to
    candidates_with_correct_children <-
      setdiff(fks$child_table, fks$parent_table)
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
  pk <- pks %>%
    filter(table == root_name) %>%
    pull(pk_col) %>%
    unlist()
  if (length(pk)) {
    dm <- dm_add_pk(dm, !!root_name, !!pk)
  }

  # forward to dm_unwrap_all
  dm_unwrap_all(dm, prototype)
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

dm_unwrap_all <- function(dm, prototype) {
  check_dm(prototype)

  # unwrap all tables and their unwrapped children/parents
  unwrapped_table_names <- character(0)
  repeat {
    to_unwrap <- setdiff(names(dm), unwrapped_table_names)[1]
    done_unwrapping <- is.na(to_unwrap)
    if (done_unwrapping) break
    dm <- dm_unwrap(dm, !!to_unwrap, prototype)
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

dm_unwrap <- function(dm, table, prototype) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  nms <- names(table)

  # detect parent and children tables
  children <- nms[map_lgl(table, inherits, "nested")]
  parents <- nms[map_lgl(table, inherits, "packed")]

  # unnest children tables
  for (child_name in children) {
    dm <- dm_unnest_tbl(dm, !!table_name, col = !!child_name, prototype)
  }

  # unpack parent tables
  for (parent_name in parents) {
    dm <- dm_unpack_tbl(dm, !!table_name, col = !!parent_name, prototype)
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
  keys <- compact(lst(child_fk, parent_pk, parent_fk))
  keys_str <- paste(capture.output(dput(keys)), collapse = " ")
  msg <- glue(
    "  dm_unpack_tbl({child_name}, {table_name}, keys = {keys_str})",
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
  keys <- compact(lst(child_fk, parent_fk, child_pk))
  keys_str <- paste(capture.output(dput(keys)), collapse = " ")
  msg <- glue(
    "  dm_unnest_tbl({parent_name}, {table_name}, keys = {keys_str})",
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

dm_unnest_tbl <- function(dm, table, col, keys) {
  # process args and build names
  parent_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[parent_table_name]]
  col_expr <- enexpr(col)
  new_child_table_name <- names(eval_select_indices(col_expr, colnames(table)))
  if (is_dm(keys)) {
    child_pk <-
      dm_get_all_pks(keys) %>%
      filter(table == new_child_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <-
      dm_get_all_fks(keys) %>%
      filter(child_table == new_child_table_name, parent_table == parent_table_name)
    parent_fk <- unlist(fk$parent_key_cols)
    child_fk <- unlist(fk$child_fk_cols)
  } else {
    if(!is_bare_list(keys) || !all(names2(keys) %in% c("child_pk", "child_fk", "parent_fk"))) {
      abort("`keys` should be a dm or a list of character vectors")
    }
    child_pk <- keys[["child_pk"]]
    parent_fk <- keys[["parent_fk"]]
    child_fk  <- keys[["child_fk"]]
  }

  # retrieve fk and extract nested table
  new_table <- table %>%
    select(!!!set_names(parent_fk, child_fk), !!new_child_table_name) %>%
    unnest(!!new_child_table_name) %>%
    distinct()

  # update the dm by adding new table, removing nested col and setting keys
  dm <- dm_add_tbl(dm, !!new_child_table_name := new_table)
  dm <- dm_select(dm, !!parent_table_name, -all_of(new_child_table_name))
  if (length(parent_fk)) {
    # need to unname because of #739
    dm <- dm_add_fk(dm, !!new_child_table_name, !!child_fk, !!parent_table_name, !!parent_fk)
  }
  if (length(child_pk)) {
    dm <- dm_add_pk(dm, !!new_child_table_name, !!child_pk)
  }

  dm
}

dm_unpack_tbl <- function(dm, table, col, keys) {
  # process args and build names
  child_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[child_table_name]]
  col_expr <- enexpr(col)
  new_parent_table_name <- names(eval_select_indices(col_expr, colnames(table)))
  if (is_dm(keys)) {
    parent_pk <- dm_get_all_pks(keys) %>%
      filter(table == new_parent_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <-  dm_get_all_fks(keys) %>%
      filter(child_table == child_table_name, parent_table == new_parent_table_name)
    child_fk <- unlist(fk$child_fk_cols)
    parent_fk <- unlist(fk$parent_key_cols)
  }  else {
    if(!is_bare_list(keys) || !all(names2(keys) %in% c("parent_pk", "parent_fk", "child_fk"))) {
      abort("`keys` should be a dm or a list containing only elements named `parent_pk`, `parent_fk` or `child_fk`")
    }
    parent_pk <- keys[["parent_pk"]]
    parent_fk <- keys[["parent_fk"]]
    child_fk <- keys[["child_fk"]]
  }

  # retrieve fk and extract packed table

  new_table <- table %>%
    select(!!!set_names(child_fk, parent_fk), !!new_parent_table_name) %>%
    unpack(!!new_parent_table_name) %>%
    distinct()

  # update the dm by adding new table, removing packed col and setting keys
  dm <- dm_add_tbl(dm, !!new_parent_table_name := new_table)
  dm <- dm_select(dm, !!child_table_name, -all_of(new_parent_table_name))
  if (length(child_fk)) {
    # need to unname because of #739
    dm <- dm_add_fk(dm, !!child_table_name, !!child_fk, !!new_parent_table_name, !!parent_fk)
  }

  if (length(parent_pk)) {
    dm <- dm_add_pk(dm, !!new_parent_table_name, !!parent_pk)
  }

  dm
}
