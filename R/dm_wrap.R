#' Wrap dm into a single tibble dm
#'
#' `dm_wrap_tbl()` creates a single tibble dm containing the `root` table
#' enhanced with all the data related to it
#' through the relationships stored in the dm.
#' It runs a sequence of [dm_nest_tbl()] and [dm_pack_tbl()] operations
#' on the dm.
#'
#' @param strict Whether to fail for cyclic dms that cannot be wrapped into a
#'   single table, if `FALSE` a partially wrapped dm will be returned.
#' @param dm A cycle free dm object.
#' @param root Table to wrap the dm into (unquoted).
#'
#' @details
#' `dm_wrap_tbl()` is an inverse to `dm_unwrap_tbl()`,
#' i.e., wrapping after unwrapping returns the same information
#' (disregarding row and column order).
#' The opposite is not generally true:
#' since `dm_wrap_tbl()` keeps only rows related directly or indirectly to
#' rows in the `root` table.
#' Even if all referential constraints are satisfied,
#' unwrapping after wrapping loses rows in parent tables
#' that don't have a corresponding row in the child table.
#'
#' @return A dm.
#' @export
#' @seealso [dm_unwrap_tbl()], [dm_nest_tbl()],
#'   [dm_examine_constraints()],
#'   [dm_examine_cardinalities()].
#' @examples
#' dm_nycflights13() %>%
#'   dm_wrap_tbl(root = airlines)
dm_wrap_tbl <- function(dm, root, strict = TRUE) {
  dm_wrap_tbl_impl(dm, {{ root }}, strict = strict)
}

dm_wrap_tbl_impl <- function(dm, root, strict = TRUE) {
  # process args
  root_name <- dm_tbl_name(dm, {{ root }})

  # initiate graph and positions
  graph <- create_graph_from_dm(dm, directed = TRUE)
  positions <- node_type_from_graph(graph, drop = root_name)

  # wrap terminal nodes as long as they're not the root
  repeat {
    child_name <- names(positions)[positions == "terminal child"][1]
    has_terminal_child <- !is.na(child_name)
    if (has_terminal_child) {
      dm <- dm_nest_tbl(dm, !!child_name)
      graph <- igraph::delete.vertices(graph, child_name)
      positions <- node_type_from_graph(graph, drop = root_name)
    }
    parent_name <- names(positions)[positions == "terminal parent"][1]
    has_terminal_parent <- !is.na(parent_name)
    if (has_terminal_parent) {
      dm <- dm_pack_tbl(dm, !!parent_name)
      graph <- igraph::delete.vertices(graph, parent_name)
      positions <- node_type_from_graph(graph, drop = root_name)
    }
    if (!has_terminal_child && !has_terminal_parent) break
  }

  # inform or fail if we have a cycle
  if (length(dm) > 1) {
    if (strict) {
      # FIXME: Detect earlier
      abort("The `dm` is not cycle free and can't be wrapped into a single tibble.")
    }
  }

  dm
}


#' Unwrap a single table dm
#'
#' @description
#' `dm_unwrap_tbl()` unwraps all tables in a dm object so that the resulting dm
#' matches a given ptype dm.
#' It runs a sequence of [dm_unnest_tbl()] and [dm_unpack_tbl()] operations
#' on the dm.
#'
#' @param dm A dm.
#' @param ptype A dm, only used to query names of primary and foreign keys.
#' @return A dm.
#' @seealso [dm_wrap_tbl()], [dm_unnest_tbl()],
#'   [dm_examine_constraints()],
#'   [dm_examine_cardinalities()],
#'   [dm_ptype()].
#' @export
#' @examples
#'
#' roundtrip <-
#'   dm_nycflights13() %>%
#'   dm_wrap_tbl(root = flights) %>%
#'   dm_unwrap_tbl(ptype = dm_ptype(dm_nycflights13()))
#' roundtrip
#'
#' # The roundtrip has the same structure but fewer rows:
#' dm_nrow(dm_nycflights13())
#' dm_nrow(roundtrip)
dm_unwrap_tbl <- function(dm, ptype) {
  check_dm(ptype)
  # unwrap all tables and their unwrapped children/parents
  unwrapped_table_names <- character(0)
  repeat {
    to_unwrap <- setdiff(names(dm), unwrapped_table_names)[1]
    done_unwrapping <- is.na(to_unwrap)
    if (done_unwrapping) break
    dm <- dm_unwrap_tbl1(dm, !!to_unwrap, ptype)
    unwrapped_table_names <- c(unwrapped_table_names, to_unwrap)
  }
  dm
}

dm_unwrap_tbl1 <- function(dm, table, ptype) {
  # process args and build names
  table_name <- dm_tbl_name(dm, {{ table }})
  table <- dm_get_tables_impl(dm)[[table_name]]
  nms <- names(table)

  # detect parent and children tables
  children <- nms[map_lgl(table, inherits, "nested")]
  parents <- nms[map_lgl(table, inherits, "packed")]

  # unnest children tables
  for (child_name in children) {
    dm <- dm_unnest_tbl(dm, !!table_name, col = !!child_name, ptype = ptype)
  }

  # unpack parent tables
  for (parent_name in parents) {
    dm <- dm_unpack_tbl(dm, !!table_name, col = !!parent_name, ptype = ptype)
  }

  dm
}
