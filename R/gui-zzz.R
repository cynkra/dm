on_load({
  if (is_installed("shiny")) {
    shiny::registerInputHandler("dm_nodes_edges", force = TRUE, shiny_input_dm_nodes_edges)
  }
})

utils::globalVariables(c(
  ".",
  "child_table",
  "id",
  "name",
  "on_delete",
  "op",
  "parent_table",
  "pk_col",
  NULL
))

"%:::%" <- function(p, f) {
  get(f, envir = asNamespace(p))
}
