#' Check foreign key reference
#'
#' `dm_is_referenced()` is soft-deprecated, use the information returned from
#' [dm_get_all_fks()] instead.
#'
#' @inheritParams dm_add_pk
#'
#' @rdname deprecated
#' @export
dm_is_referenced <- function(dm, table) {
  deprecate_soft("0.3.0", "dm::dm_is_referenced()", "dm::dm_get_all_fks()")

  check_not_zoomed(dm)
  has_length(dm_get_referencing_tables(dm, !!ensym(table)))
}

#' Get the names of referencing tables
#'
#' `dm_get_referencing_tables()` is soft-deprecated, use the information
#' returned from [dm_get_all_fks()] instead.
#'
#' @inheritParams dm_is_referenced
#' @rdname deprecated
#'
#' @export
dm_get_referencing_tables <- function(dm, table) {
  deprecate_soft("0.3.0", "dm::dm_get_referencing_tables()", "dm::dm_get_all_fks()")

  check_not_zoomed(dm)
  table <- dm_tbl_name(dm, {{ table }})

  def <- dm_get_def(dm)
  i <- which(def$table == table)
  def$fks[[i]]$table
}

create_graph_from_dm <- function(dm, directed = FALSE) {
  def <- dm_get_def(dm)
  def %>%
    select(ref_table = table, fks) %>%
    unnest_list_of_df("fks") %>%
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
