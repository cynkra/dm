if (ci_get_env("MODE") == "db-tests") {
  get_stage("install") %>%
    add_step(step_install_cran("devtools"))
}

if (ci_has_env("TIC_DEV_VERSIONS")) {
  get_stage("install") %>%
    add_step(step_install_github(upgrade = "always", c(
      "mllg/backports",
      "r-lib/brio",
      "r-lib/cli",
      "r-dbi/DBI",
      "tidyverse/dplyr",
      "tidyverse/glue",
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
      "brodieG/fansi",
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
    add_code_step(devtools::test(reporter = c("progress", "fail")))
} else if (ci_has_env("TIC_ONLY_STYLER")) {
  if (!ci_is_tag()) {
    # For caching
    get_stage("install") %>%
      add_step(step_install_cran("R.cache")) %>%
      add_code_step(dir.create("~/.Rcache", showWarnings = FALSE))

    # Needs to be at the script stage so that caching works
    get_stage("script") %>%
      add_code_step(styler::cache_info()) %>%
      add_code_step(styler::style_pkg())

    if (ci_has_env("id_rsa")) {
      get_stage("deploy") %>%
        add_code_step(styler::cache_info()) %>%
        add_code_step(styler::style_pkg()) %>%
        add_step(step_setup_ssh()) %>%
        add_step(step_push_deploy())
    }
  }
} else if (ci_has_env("TIC_BUILD_PKGDOWN")) {
  get_stage("install") %>%
    add_step(step_install_github("cynkra/cynkratemplate"))

  do_pkgdown()
} else {
  get_stage("before_script") %>%
    add_code_step({
      pkgload::load_all()
      print(sessioninfo::session_info())
    })

  do_package_checks(error_on = if (getRversion() >= "3.4") "note" else "warning")
}
