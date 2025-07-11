default_eval <- function() {
  # Only build vignettes in pkgdown for now
  (Sys.getenv("IN_PKGDOWN") != "") || grepl("^cran-", Sys.getenv("GITHUB_HEAD_REF"))
}

knitr::opts_chunk$set(
  error = (Sys.getenv("IN_PKGDOWN") == "") || !dm:::dm_has_financial(),
  # Only build vignettes:
  # - on pkgdown
  # - if not running in GitHub Actions
  # - if running in a branch that starts with CRAN in GitHub Actions
  eval = default_eval(),
  message = TRUE,
  collapse = TRUE,
  comment = "#>"
)

if (rlang::is_installed("fansi")) {
  fansi::set_knit_hooks(knitr::knit_hooks, which = c("output", "message"))
} else if (default_eval() && Sys.getenv("GITHUB_JOB") != "rcc-suggests") {
  cli::cli_abort(
    "{.pkg fansi} required for rendering vignettes but not installed."
  )
}

options(crayon.enabled = knitr::is_html_output(excludes = "gfm"), width = 75, cli.width = 75)

knit_print.grViz <- function(x, ...) {
  x %>%
    DiagrammeRsvg::export_svg() %>%
    c("`````{=html}\n", ., "\n`````\n") %>%
    knitr::asis_output()
}

# If input loads dm or tidyverse, we load it here to omit warnings
input <- readLines(knitr::current_input())
if (rlang::has_length(grep('^library[(]"?dm"?[)]', input))) {
  library(dm)
}
if (rlang::has_length(grep('^library[(]"?dplyr"?[)]', input))) {
  library(dplyr)
}

## Link helper to enable links only on pkgdown
href <- function(title, url) {
  if (Sys.getenv("IN_PKGDOWN") == "") {
    paste0(title, " (", url, ")")
  } else {
    paste0("[", title, "](", url, ")")
  }
}
