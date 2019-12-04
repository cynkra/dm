#' Is a table of a [`dm`] referenced by another table?
#'
#' @inheritParams dm_add_pk
#'
#' @return `TRUE` if at least one foreign key exists that points to the primary
#' key of the `table` argument, `FALSE` otherwise.
#'
#' @family functions utilizing foreign key relations
#'
#' @examples
#' cdm_is_referenced(cdm_nycflights13(), airports)
#' cdm_is_referenced(cdm_nycflights13(), flights)
#'
#' @export
dm_is_referenced <- function(dm, table) {
  has_length(dm_get_referencing_tables(dm, !!ensym(table)))
}

#' Get the names of the tables of a [`dm`] that reference a given table.
#'
#' @inheritParams dm_is_referenced
#'
#' @return Character vector of the names of the tables that point to the primary
#' key of `table`.
#'
#' @family functions utilizing foreign key relations
#'
#' @examples
#' cdm_get_referencing_tables(cdm_nycflights13(), airports)
#' cdm_get_referencing_tables(cdm_nycflights13(), flights)
#'
#' @export
dm_get_referencing_tables <- function(dm, table) {
  table <- as_name(ensym(table))
  check_correct_input(dm, table)

  def <- dm_get_def(dm)
  i <- which(def$table == table)
  def$fks[[i]]$table
}

create_graph_from_dm <- function(dm, directed = FALSE) {
  def <- dm_get_def(dm)
  def %>%
    select(ref_table = table, fks) %>%
    unnest(fks) %>%
    select(table, ref_table) %>%
    igraph::graph_from_data_frame(directed = directed, vertices = def$table)
}

get_names_of_connected <- function(g, start, squash) {
  dfs <- igraph::dfs(g, start, unreachable = FALSE, dist = TRUE)
  # `purrr::discard()` in case `list_of_pts` is `NA`
  if (squash) {
    setdiff(names(dfs[["order"]]), start) %>% discard(is.na)
  } else {
    # FIXME: Enumerate outgoing edges
    setdiff(names(dfs[["order"]]), c(start, names(dfs$dist[dfs$dist > 1]))) %>% discard(is.na)
  }
}
