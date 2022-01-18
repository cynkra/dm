#' Wrap dm into a single tibble
#'
#' `dm_to_tibble()` creates a tibble built from the `root` table and containing
#' all the data related to it through the relationships stored in the dm.
#'
#' @param dm A cycle free dm object.
#' @param root Table to wrap the dm into (unquoted).
#' @param silent Whether to print the code that reverse the transformation. See details.
#'
#' When silent is `FALSE` (default) we print the steps required to achieve
#' the reverse transformation without using a prototype.
#' This is a sequence of calls to [dm()], [dm_unpack_tbl()] and [dm_unnest_tbl()].
#'
#' The reverse transformation is generally not a perfect round trip,
#' since `dm_to_tibble()` keeps only rows related directly or indirectly to
#' rows in the `root` table.
#' Even if all referential constraints are satisfied, rows in parent tables
#' that don't have a corresponding row in the child table are lost.
#'
#' @return A tibble
#' @seealso [tibble_to_dm()], [dm_wrap()], [dm_unwrap()],
#'   [dm_examine_constraints()]
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
