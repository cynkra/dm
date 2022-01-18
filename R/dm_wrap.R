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
