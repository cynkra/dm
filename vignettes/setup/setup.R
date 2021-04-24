knitr::knit_hooks$set(time_it = local({
  now <- NULL
  function(before, options) {
    if (before) {
      # record the current time before each chunk
      now <<- Sys.time()
    } else {
      # calculate the time difference after a chunk
      res <- difftime(Sys.time(), now)
      # return a character string to show the time
      message("Time for this code chunk to run: ", res)
    }
  }
}))

knitr::opts_chunk$set(
  time_it = TRUE,
  error = (Sys.getenv("IN_PKGDOWN") == "") || !dm:::dm_has_financial(),
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
