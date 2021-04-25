knitr::opts_chunk$set(
  error = (Sys.getenv("IN_PKGDOWN") == "") || !dm:::dm_has_financial(),
  # Only build vignettes:
  # - on pkgdown
  # - if not running in GitHub Actions
  # - if running in a branch that starts with CRAN in GitHub Actions
  eval = (Sys.getenv("IN_PKGDOWN") != "") || (Sys.getenv("GITHUB_WORKFLOW") == "") || grepl("^cran-", Sys.getenv("GITHUB_HEAD_REF")),
  message = TRUE,
  collapse = TRUE,
  comment = "#>"
)
fansi::set_knit_hooks(knitr::knit_hooks, which = c("output", "message"))
options(crayon.enabled = knitr::is_html_output(excludes = "gfm"), width = 75, cli.width = 75)

knit_print.grViz <- function(x, ...) {
  x %>%
    DiagrammeRsvg::export_svg() %>%
    c("`````{=html}\n", ., "\n`````\n") %>%
    knitr::asis_output()
}

# If input loads dm...
input <- readLines(knitr::current_input())
if (rlang::has_length(grep("^library[(]dm[)]", input))) {
  # we load it here to omit warnings
  library(dm)
}
