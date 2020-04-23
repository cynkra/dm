replay_html.dm_draw <- function(x, ...) {
  unclass(x)
}

print.grViz <- function(x, ...) {
  structure(DiagrammeRsvg::export_svg(x), class = "dm_draw")
}
