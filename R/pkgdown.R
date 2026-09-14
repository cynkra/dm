replay_html_dm_draw <- function(x, ...) {
  unclass(x)
}

# Use custom name to avoid clash if pkgload is active
pkgdown_print_grViz <- function(x, ...) {
  structure(DiagrammeRsvg::export_svg(x), class = "dm_draw")
}

register_pkgdown_methods <- function() {
  if (!is_pkgdown_dm()) {
    return()
  }

  # FIXME Should we use Config/Needs/website in DESCRIPTION instead?
  check_suggested(c("DiagrammeR", "DiagrammeRsvg"), "register_pkgdown_methods")

  # For dev pkgdown
  s3_register("downlit::replay_html", "dm_draw", replay_html_dm_draw)
  s3_register("pkgdown::pkgdown_print", "grViz", pkgdown_print_grViz)
}

# pkgdown sets `IN_PKGDOWN` for the entire build process,
# including while it loads the namespaces imported by the package being documented.
# Testing that variable alone would make dm apply its pkgdown-specific behavior
# whenever a package that merely imports dm builds its own site, see #2194.
# pkgdown loads those namespaces with the working directory still at the root of
# the package being documented, so require that this package is dm itself.
# Must neither fail nor warn: called from `.onLoad()`.
is_pkgdown_dm <- function() {
  if (Sys.getenv("IN_PKGDOWN") == "") {
    return(FALSE)
  }

  description <- file.path(getwd(), "DESCRIPTION")
  if (!file.exists(description)) {
    return(FALSE)
  }

  package <- tryCatch(
    suppressWarnings(read.dcf(description, fields = "Package")[[1]]),
    error = function(e) NA_character_
  )

  identical(package, "dm")
}
