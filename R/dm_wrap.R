#' Wrap dm into a single tibble dm
#'
#' @description
#' `r lifecycle::badge("experimental")`
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
#' This function differs from `dm_flatten_to_tbl()` and `dm_squash_to_tbl()` ,
#' which always return a single table, and not a `dm` object.
#'
#' @return A `dm` object.
#' @export
#' @seealso [dm_unwrap_tbl()], [dm_nest_tbl()],
#'   [dm_examine_constraints()],
#'   [dm_examine_cardinalities()].
#' @examples
#' dm_nycflights13() %>%
#'   dm_wrap_tbl(root = airlines)
dm_wrap_tbl <- function(dm, root, strict = TRUE) {
  wrap_plan <- dm_wrap_tbl_plan(dm, {{ root }})

  wrapped_dm <- reduce2(
    wrap_plan$action,
    wrap_plan$table,
    function(dm, f, table) exec(f, dm, table),
    .init = dm
  )

  # inform or fail if we have a cycle
  if (length(wrapped_dm) > 1) {
    if (strict) {
      # FIXME: Detect earlier
      abort("The `dm` is not cycle free and can't be wrapped into a single tibble.")
    }
  }

  wrapped_dm
}

dm_wrap_tbl_plan <- function(dm, root) {
  # process args
  root_name <- dm_tbl_name(dm, {{ root }})

  # initiate graph and positions
  graph <- create_graph_from_dm(dm, directed = TRUE)
  positions <- node_type_from_graph(graph, drop = root_name)

  # build plan of actions to wrap terminal nodes as long as they're not the root
  wrap_plan <- tibble(action = character(0), table = character(0))
  repeat {
    child_name <- names(positions)[positions == "terminal child"][1]
    has_terminal_child <- !is.na(child_name)
    if (has_terminal_child) {
      wrap_plan <- add_row(wrap_plan, action = "dm_nest_tbl", table = child_name)
      graph <- igraph::delete.vertices(graph, child_name)
      positions <- node_type_from_graph(graph, drop = root_name)
    }
    parent_name <- names(positions)[positions == "terminal parent"][1]
    has_terminal_parent <- !is.na(parent_name)
    if (has_terminal_parent) {
      wrap_plan <- add_row(wrap_plan, action = "dm_pack_tbl", table = parent_name)
      graph <- igraph::delete.vertices(graph, parent_name)
      positions <- node_type_from_graph(graph, drop = root_name)
    }
    if (!has_terminal_child && !has_terminal_parent) break
  }
  wrap_plan
}


#' Unwrap a single table dm
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
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

  unwrap_plan <- dm_get_tables(dm) %>%
    imap(dm_unwrap_tbl_plan) %>%
    unlist(recursive = FALSE) %>%
    purrr::discard(~ nrow(.) == 0)

  unwrapped_dm <- reduce(
    unwrap_plan,
    function(dm, row) {
      exec(row$action, dm, row$table, row$col, ptype)
    },
    .init = dm
  )
  unwrapped_dm
}

dm_unwrap_tbl_plan <- function(table, table_name) {
  nms <- names(table)

  children <- nms[map_lgl(table, inherits, "nested")]
  parents <- nms[map_lgl(table, inherits, "packed")]

  unnest_plan <-
    tibble(
      action = "dm_unnest_tbl",
      table = table_name,
      col = children
    ) %>%
    split.data.frame(seq_along(children))

  unpack_plan <-
    tibble(
      action = "dm_unpack_tbl",
      table = table_name,
      col = parents
    ) %>%
    split.data.frame(seq_along(parents))

  unwrap_plan_from_children <-
    # note: we cannot use bind_rows() because of https://github.com/tidyverse/dplyr/issues/6447,
    #   or even vec_rbind() because of https://github.com/r-lib/vctrs/issues/1640
    map(children, ~ dm_unwrap_tbl_plan(vec_c(!!!table[[.x]]), .x)) %>%
    unlist(recursive = FALSE)

  unwrap_plan_from_parents <-
    map(parents, ~ dm_unwrap_tbl_plan(table[[.x]], .x)) %>%
    unlist(recursive = FALSE)

  c(
    unnest_plan,
    unpack_plan,
    unwrap_plan_from_children,
    unwrap_plan_from_parents
  )
}
