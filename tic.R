get_stage("install") %>%
  add_step(step_run_code(print(gh::gh("/rate_limit"))))

get_stage("after_deploy") %>%
  add_step(step_run_code(print(gh::gh("/rate_limit"))))

if (ci_get_env("MODE") == "db-tests") {
  get_stage("install") %>%
    add_step(step_install_deps()) %>%
    add_step(step_install_cran("devtools"))
}

if (ci_has_env("TIC_DEV_VERSIONS")) {
  get_stage("install") %>%
    add_step(step_install_github(upgrade = "always", c(
      "mllg/backports",
      "r-lib/brio",
      # "r-lib/cli", # https://github.com/r-lib/cli/issues/154
      "r-dbi/DBI",
      "tidyverse/dplyr",
      "tidyverse/glue",
      # "igraph/rigraph", # https://github.com/igraph/rigraph/issues/384
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

if (ci_has_env("TIC_DEV_VERSIONS")) {
  get_stage("script") %>%
    add_code_step(devtools::test(reporter = c("summary")))
} else if (ci_has_env("TIC_ONLY_TESTS")) {
  get_stage("script") %>%
    add_code_step(devtools::test(reporter = c("summary", "fail")))
} else if (ci_has_env("TIC_ONLY_STYLER")) {
  if (!ci_is_tag()) {
    # For caching (and to ensure styler is installed in script stage)
    get_stage("install") %>%
      add_step(step_install_cran("R.cache")) %>%
      add_code_step(dir.create("~/.Rcache", showWarnings = FALSE)) %>%
      add_code_step(styler::cache_info())

    if (ci_has_env("id_rsa")) {
      get_stage("deploy") %>%
        add_code_step(styler::style_pkg()) %>%
        add_step(step_setup_ssh()) %>%
        add_step(step_push_deploy())
    } else {
      get_stage("script") %>%
        add_code_step(styler::style_pkg())
    }
  }
} else if (ci_has_env("TIC_BUILD_PKGDOWN")) {
  get_stage("install") %>%
    add_step(step_install_github("r-lib/pkgdown")) %>%
    add_step(step_install_github("cynkra/cynkratemplate"))

  do_pkgdown(deploy = ci_can_push() && grepl("^master$|^main$|^docs$|^cran-", ci_get_branch()))
} else if (ci_has_env("TIC_CHECK_FINANCIAL")) {
  # How to detect scheduled runs?
  get_stage("install") %>%
    add_code_step(print(Sys.getenv())) %>%
    add_step(step_install_deps())

  get_stage("script") %>%
    add_code_step(dm::dm_financial())
} else {
  get_stage("before_script") %>%
    add_code_step({
      pkgload::load_all()
      print(sessioninfo::session_info())
    })

  if (ci_has_env("TIC_ONLY_IMPORTS")) {
    # VignetteBuilder not installed?
    get_stage("install") %>%
      add_step(step_install_cran("rmarkdown")) %>%
      add_step(step_install_cran("testthat"))

    do_package_checks(dependencies = c("Depends", "Imports"))
  } else {
    do_package_checks(
      error_on = if (getRversion() >= "3.4") "note" else "warning"
    )
  }
}
