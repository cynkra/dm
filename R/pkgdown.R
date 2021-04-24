replay_html_dm_draw <- function(x, ...) {
  unclass(x)
}

# Use custom name to avoid clash if pkgload is active
print_grViz <- function(x, ...) {
  structure(DiagrammeRsvg::export_svg(x), class = "dm_draw")
}

register_pkgdown_methods <- function() {
  if (Sys.getenv("IN_PKGDOWN") == "") {
    return()
  }

  stopifnot(rlang::is_installed(c("DiagrammeR", "DiagrammeRsvg")))
  # For dev pkgdown
  vctrs::s3_register("downlit::replay_html", "dm_draw", replay_html_dm_draw)
  vctrs::s3_register("pkgdown::replay_html", "dm_draw", replay_html_dm_draw)
  vctrs::s3_register("base::print", "grViz", print_grViz)
}
