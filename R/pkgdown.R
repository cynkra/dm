replay_html_dm_draw <- function(x, ...) {
  unclass(x)
}

# Use custom name to avoid clash if pkgload is active
pkgdown_print_grViz <- function(x, ...) {
  structure(DiagrammeRsvg::export_svg(x), class = "dm_draw")
}

register_pkgdown_methods <- function() {
  if (Sys.getenv("IN_PKGDOWN") == "") {
    return()
  }

  check_suggested(c("DiagrammeR", "DiagrammeRsvg"),
    use = TRUE,
    message = "DiagrammeR and DiagrammeRsvg packages needed for this function to work. Please install it."
  )

  # For dev pkgdown
  s3_register("downlit::replay_html", "dm_draw", replay_html_dm_draw)
  s3_register("pkgdown::pkgdown_print", "grViz", pkgdown_print_grViz)
}
