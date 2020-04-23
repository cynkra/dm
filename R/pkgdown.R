register_pkgdown_methods <- function() {
  if (Sys.getenv("IN_PKGDOWN") == "") {
    return()
  }

  replay_html.dm_draw <- function(x, ...) {
    unclass(x)
  }

  print.grViz <- function(x, ...) {
    structure(DiagrammeRsvg::export_svg(x), class = "dm_draw")
  }

  stopifnot(rlang::is_installed(c("DiagrammeR", "DiagrammeRsvg")))
  vctrs::s3_register("pkgdown::replay_html", "dm_draw")
  vctrs::s3_register("base::print", "grViz")
}
