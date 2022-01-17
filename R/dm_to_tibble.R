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

#' Wrap dm into a single tibble
#'
#' `dm_to_tibble()` creates a tibble built from the `root` table and containing
#'   all the data related to it through the relationships stored in the dm.
#'
#' @param dm A cycle free dm object
#' @param root Table to wrap the dm into (unquoted)
#' @param silent Whether to print the code that reverse the transformation. See details.
#'
#' When silent is `FALSE` (default) we print the steps required to achieve
#' the reverse transformation without using a prototype. This is sequence of
#' calls to `dm()`, `dm_unpack_tbl()` and `dm_unnest_tbl()`.
#'
#' The reverse transformation i generally not a perfect round trip since
#' `dm_to_tibble()` keeps only information related to `root`
#'
#' @return A tibble
#' @seealso [dm::tibble_to_dm], [dm::dm_wrap], [dm::dm_unwrap],
#'
#' @export
#'
#' @examples
#' dm_to_tibble(dm_nycflights13(), airlines)
dm_to_tibble <- function(dm, root, silent = FALSE) {
  root_name <- dm_tbl_name(dm, {{ root }})
  dm_msg <- dm_wrap_impl(dm, {{ root }}, strict = TRUE)
  if (!silent) {
    pk <- dm_get_all_pks(dm) %>%
      filter(table == root_name) %>%
      pull(pk_col) %>%
      unlist()
    inform(glue(
      "Rebuild a dm from this object using : %>%\n",
      "  dm({root_name} = .) %>%\n",
      if (!length(pk)) "" else "  dm_add_pk({root_name}, {capture.output(dput(pk))}) %>%\n",
      dm_msg$msg,
      .trim = FALSE,
    ))
  }
  dm_get_tables_impl(dm_msg$dm)[[root_name]]
}

#' Convert a wrapped tibble to a dm
#'
#' @param x A wrapped table, as created by `dm_to_tibble()`
#' @param prototype A dm, might be an empty prototype.
#' @param root The root table (unquoted), optional because we can often
#'   infer it from `x` and `prototype`
#' @export
#' @return A dm
#' @seealso [dm::tibble_to_dm], [dm::dm_wrap], [dm::dm_unwrap]
#'
#' @examples
#' # often we can infer the root table from the prototype
#' flights_wrapped <- dm_to_tibble(dm_nycflights13(), flights, silent = TRUE)
#' tibble_to_dm(flights_wrapped, dm_nycflights13())
#'
#' # other times, it is ambiguous and should be given
#' airlines_wrapped <- dm_to_tibble(dm_nycflights13(), airlines, silent = TRUE)
#' tibble_to_dm(airlines_wrapped, dm_nycflights13(), airlines)
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

  # forward to dm_unwrap
  dm_unwrap(dm, prototype)
}

#' Wrap dm into a single tibble dm
#'
#' `dm_wrap()` creates a single tibble tibble dm containing the `root` table
#'   enhanced with all the data related to it through the relationships stored in the dm.
#'
#' @inheritParams dm_to_tibble
#' @param strict Whether to fail for cyclic dms that cannot be wrapped into a
#'   single table, if `FALSE` a partially wrapped dm will be returned
#'
#' When silent is `FALSE` (default) we print the steps required to achieve
#' the reverse transformation without using a prototype. This is a sequence of
#' calls to `dm_unpack_tbl()` and `dm_unnest_tbl()`.
#'
#' The reverse transformation i generally not a perfect round trip since
#' `dm_to_tibble()` keeps only information related to `root`
#'
#' @return A single table dm
#' @export
#' @seealso [dm::dm_unwrap],  [dm::dm_to_tibble], [dm::tibble_to_dm],
#'   [dm::dm_wrap]
#' @examples
#' dm_wrap(dm_nycflights13(), airlines)
dm_wrap <- function(dm, root, silent = FALSE, strict = TRUE) {
  dm_msg <- dm_wrap_impl(dm, {{ root }}, strict = strict)
  if (!silent) {
    inform(paste0("Rebuild a dm from this object using : %>%\n", dm_msg$msg))
  }
  dm_msg$dm
}

dm_wrap_impl <- function(dm, root, strict = TRUE) {
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
      abort("The `dm` is not cycle free and can't be wrapped into a single tibble.")
    }
    inform("The `dm` is not cycle free, returning a partially wrapped multi table 'dm'.")
  }

  list(dm = dm, msg = paste(rev(msgs), collapse = " %>%\n"))
}


#' Unwrap a single table dm
#'
#' @inheritParams tibble_to_dm
#' @param dm A dm
#' @export
#' @return A dm
#' @seealso [dm::dm_wrap], [dm::dm_to_tibble], [dm::tibble_to_dm],
#'   [dm::dm_wrap]
#' @examples
#' wrapped_dm <- dm_wrap(dm_nycflights13(), airlines, silent = TRUE)
#' dm_unwrap(wrapped_dm, dm_nycflights13())
dm_unwrap <- function(dm, prototype) {
  check_dm(prototype)
  # unwrap all tables and their unwrapped children/parents
  unwrapped_table_names <- character(0)
  repeat {
    to_unwrap <- setdiff(names(dm), unwrapped_table_names)[1]
    done_unwrapping <- is.na(to_unwrap)
    if (done_unwrapping) break
    dm <- dm_unwrap1(dm, !!to_unwrap, prototype)
    unwrapped_table_names <- c(unwrapped_table_names, to_unwrap)
  }
  dm
}

dm_unwrap1 <- function(dm, table, prototype) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  nms <- names(table)

  # detect parent and children tables
  children <- nms[map_lgl(table, inherits, "nested")]
  parents <- nms[map_lgl(table, inherits, "packed")]

  # unnest children tables
  for (child_name in children) {
    dm <- dm_unnest_tbl(dm, !!table_name, col = !!child_name, prototype = prototype)
  }

  # unpack parent tables
  for (parent_name in parents) {
    dm <- dm_unpack_tbl(dm, !!table_name, col = !!parent_name, prototype = prototype)
  }

  dm
}

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

#' Nest or pack a table inside its dm
#'
#' These functions nest or pack a table inside its parent or child
#'
#' @param dm A dm
#' @param table A table
#' @param into The table to wrap `table` into, optional as it can be guessed
#'   from the foreign keys unambiguously but useful to be explicit.
#' @param silent if not silent (the default), the code to unwrap will be printed
#'
#' * `dm_nest_tbl()` will nest a given `table` into its parent, `table` itself
#' should not have children tables (i.e. it needs to be a *terminal child table*)
#' * `dm_pack_tbl()` will pack a given `table` into its child, `table` itself
#' should not have parent tables (i.e. it needs to be a *terminal parent table*)
#' @seealso [dm::dm_wrap], [dm::dm_unwrap],
#'   [dm::dm_to_tibble], [dm::tibble_to_dm]
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

#' Unnest or unpack columns from a wrapped table
#'
#' `dm_unpack_tbl()` and `dm_unnest_tbl()` target a specific column to unpack/unnest
#' from the given table in a given dm. A prototype or a set of keys should be given,
#' not both.
#'
#' @param dm A dm
#' @param table A table
#' @param parent_fk Columns in the table to unnest that the unnested child's foreign keys point to
#' @param child_pk_names Names of the unnested child's primary keys
#' @param child_fk_names Names of the unnested child's foreign keys
#' @param child_fk Foreign key columns of the table to unpack
#' @param parent_pk_names Names of the unpacked parent's primary keys
#' @param parent_fk_names Names of the unpacked parent's foreign keys
#' @param prototype A dm
#' @param col The column to unpack or unnest (unquoted)
#'
#' @return A dm
#' @seealso [dm::dm_wrap], [dm::dm_wrap], [dm::dm_unwrap],
#'   [dm::dm_to_tibble], [dm::tibble_to_dm]
#' @export
#'
#' @examples
#' airlines_wrapped <- dm_wrap(dm_nycflights13(), "airlines")
#'
#' airlines_wrapped %>%
#'   dm_unnest_tbl(airlines, flights, parent_fk = carrier, child_fk_names = "carrier") %>%
#'   dm_unpack_tbl(
#'     flights, weather,
#'     child_fk = c(origin, time_hour),
#'     parent_fk_names = c("origin", "time_hour"),
#'     parent_pk_names = c("origin", "time_hour")
#'   ) %>%
#'   dm_unpack_tbl(
#'     flights, planes,
#'     child_fk = tailnum, parent_fk_names = "tailnum",
#'     parent_pk_names = "tailnum"
#'   ) %>%
#'   dm_unpack_tbl(
#'     flights, airports,
#'     child_fk = origin, parent_fk_names = "faa",
#'     parent_pk_names = "faa"
#'   )
#'
#' airlines_wrapped %>%
#'   dm_unnest_tbl(airlines, flights, prototype = dm_nycflights13()) %>%
#'   dm_unpack_tbl(flights, weather, prototype = dm_nycflights13()) %>%
#'   dm_unpack_tbl(flights, planes, prototype = dm_nycflights13()) %>%
#'   dm_unpack_tbl(flights, airports, prototype = dm_nycflights13())
dm_unnest_tbl <- function(dm, table, col, parent_fk = NULL, child_pk_names = NULL, child_fk_names = NULL, prototype = NULL) {
  parent_fk_expr <- enexpr(parent_fk)
  all_keys_null <-
    is_null(parent_fk_expr) && is_null(child_pk_names) && is_null(child_fk_names)

  # process args and build names
  parent_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[parent_table_name]]
  col_expr <- enexpr(col)
  new_child_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  if (is_null(prototype)) {
    if (all_keys_null) abort("Provide either keys or a prototype, you provided none")
    parent_fk_names <- names(eval_select_indices(parent_fk_expr, colnames(table)))
  } else {
    if (!all_keys_null) abort("Provide either keys or a prototype, you provided both")
    child_pk_names <-
      dm_get_all_pks(prototype) %>%
      filter(table == new_child_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <-
      dm_get_all_fks(prototype) %>%
      filter(child_table == new_child_table_name, parent_table == parent_table_name)
    parent_fk_names <- unlist(fk$parent_key_cols)
    child_fk_names <- unlist(fk$child_fk_cols)
  }

  # extract nested table
  new_table <- table %>%
    select(!!!set_names(parent_fk_names, child_fk_names), !!new_child_table_name) %>%
    unnest(!!new_child_table_name) %>%
    distinct()

  # update the dm by adding new table, removing nested col and setting keys
  dm <- dm_add_tbl(dm, !!new_child_table_name := new_table)
  dm <- dm_select(dm, !!parent_table_name, -all_of(new_child_table_name))
  if (length(parent_fk_names)) {
    dm <- dm_add_fk(dm, !!new_child_table_name, !!child_fk_names, !!parent_table_name, !!parent_fk_names)
  }
  if (length(child_pk_names)) {
    dm <- dm_add_pk(dm, !!new_child_table_name, !!child_pk_names)
  }

  dm
}

#' @export
#' @rdname dm_unnest_tbl
dm_unpack_tbl <- function(dm, table, col, child_fk = NULL, parent_pk_names = NULL, parent_fk_names = NULL, prototype = NULL) {
  child_fk_expr <- enexpr(child_fk)
  all_keys_null <-
    is_null(parent_pk_names) && is_null(parent_fk_names) && is_null(child_fk_expr)

  # process args and build names
  child_table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[child_table_name]]
  col_expr <- enexpr(col)
  new_parent_table_name <- names(eval_select_indices(col_expr, colnames(table)))

  if (is_null(prototype)) {
    if (all_keys_null) abort("Provide either keys or a prototype, you provided none")
    child_fk_names <- names(eval_select_indices(child_fk_expr, colnames(table)))
  } else {
    if (!all_keys_null) abort("Provide either keys or a prototype, you provided both")
    parent_pk_names <- dm_get_all_pks(prototype) %>%
      filter(table == new_parent_table_name) %>%
      pull(pk_col) %>%
      unlist()
    fk <- dm_get_all_fks(prototype) %>%
      filter(child_table == child_table_name, parent_table == new_parent_table_name)
    child_fk_names <- unlist(fk$child_fk_cols)
    parent_fk_names <- unlist(fk$parent_key_cols)
  }

  # extract packed table
  new_table <- table %>%
    select(!!!set_names(child_fk_names, parent_fk_names), !!new_parent_table_name) %>%
    unpack(!!new_parent_table_name) %>%
    distinct()

  # update the dm by adding new table, removing packed col and setting keys
  dm <- dm_add_tbl(dm, !!new_parent_table_name := new_table)
  dm <- dm_select(dm, !!child_table_name, -all_of(new_parent_table_name))
  if (length(child_fk_names)) {
    dm <- dm_add_fk(
      dm,
      !!child_table_name,
      !!child_fk_names,
      !!new_parent_table_name,
      !!parent_fk_names
    )
  }
  if (length(parent_pk_names)) {
    dm <- dm_add_pk(dm, !!new_parent_table_name, !!parent_pk_names)
  }

  dm
}
