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
