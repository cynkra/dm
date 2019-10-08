MAX_COMMAS <- 6L

commas <- function(x) {
  if (is_empty(x)) {
    x <- ""
  } else if (length(x) > MAX_COMMAS) {
    length(x) <- MAX_COMMAS + 1L
    x[[MAX_COMMAS + 1L]] <- cli::symbol$ellipsis
  }

  glue_collapse(x, sep = ", ")
}

tick <- function(x) {
  paste0("`", x, "`")
}

default_local_src <- function() {
  src_df(env = .GlobalEnv)
}

dispatch_abort <- function(
  join_name,
  part_cond_abort_filters,
  any_not_reachable,
  g) {
  # argument checking, or filter and recompute induced subgraph
  # for subsequent check
  if (any_not_reachable) {
    abort_tables_not_reachable_from_start()
  }

  # Cycles not yet supported
  if (length(V(g)) - 1 != length(E(g))) {
    abort_no_cycles()
  }
  if (join_name == "nest_join") abort_no_flatten_with_nest_join()
  if (part_cond_abort_filters && join_name %in% c("full_join", "right_join")) abort_apply_filters_first(join_name)
}
