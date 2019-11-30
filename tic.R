if (ci_has_env("TIC_DEV_VERSIONS")) {
  get_stage("install") %>%
    add_step(step_install_github(c(
      "mllg/backports",
      "r-lib/cli",
      "r-dbi/DBI",
      "tidyverse/dplyr",
      "rstudio/DT",
      "r-lib/glue",
      "igraph/rigraph",
      "r-lib/lifecycle",
      "tidyverse/magrittr",
      "tidyverse/purrr",
      "r-lib/rlang",
      "tidyverse/tibble",
      "tidyverse/tidyr",
      "r-lib/tidyselect",
      "r-lib/vctrs",
      "rich-iannone/DiagrammeR",
      "rich-iannone/DiagrammeRsvg",
      "tidyverse/dbplyr",
      "tidyverse/fansi",
      "yihui/knitr",
      "hadley/nycflights13",
      "rstudio/rmarkdown",
      "r-dbi/RPostgres",
      "r-lib/rprojroot",
      "r-dbi/RSQLite",
      "r-lib/testthat",
      "tidyverse/tidyverse"
    )))
}

if (ci_has_env("TIC_ONLY_TESTS")) {
  get_stage("script") %>%
    add_code_step(devtools::test())
} else {
  do_package_checks()

  if (ci_has_env("TIC_BUILD_PKGDOWN")) {
    do_pkgdown()
  }
}
