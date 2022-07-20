shiny_input_dm_nodes_edges <- function(x, session, name) {
  # The client shouldn't have to deal with that (and I wonder why we need to
  # do this here even).
  x$nodes <- unlist(x$nodes)
  x$edges <- unlist(x$edges)
  x
}
