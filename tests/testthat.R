library(dm)

search_lib_and_load <- function(pkg) {
  if (!is_installed(pkg)) abort(paste0("Testing package {dm} requires package {", pkg, "}. Please install e.g. from CRAN."))
  library(pkg, character.only = TRUE)
}

search_lib_and_load("testthat")
search_lib_and_load("dbplyr")

test_check("dm")
