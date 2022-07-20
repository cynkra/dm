.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, c("...length"))
  backports::import(pkgname, c("...names"))

  if (getRversion() >= "3.4") {
    dm_financial <<- memoise::memoise(dm_financial, cache = cache_attach())
    dm_financial_sqlite <<- memoise::memoise(dm_financial_sqlite, cache = cache_attach())
  }

  nycflights_subset <<- memoise::memoise(nycflights_subset, cache = cache_attach())

  dm_has_financial <<- memoise::memoise(dm_has_financial, cache = cache_attach())

  check_suggested <<- memoise::memoise(check_suggested)

  register_pkgdown_methods()

  check_version_on_load
  s3_register("waldo::compare_proxy", "dm")

  check_version_on_load("RSQLite", "2.2.8", "to use the {.code returning} argument in {.code rows_*()}.")
  check_version_on_load("dbplyr", "2.2.0", "to use the {.code rows_*()} functions.")

  # rigg(enum_pk_candidates_impl)
  # rigg(build_copy_data)
  # rigg(dm_insert_zoomed_outgoing_fks)
  # rigg(dm_upgrade)
  # rigg(check_df_structure)
  # rigg(dm_insert_zoomed)
  # rigg(dm_select_tbl_impl)
  # rigg(dm_insert_zoomed_outgoing_fks)
  # rigg(dm_rm_pk_impl)
  # rigg(dm_rm_fk_impl)
  # rigg(cdm_rm_fk)

  run_on_load()
}

rigg <- function(fun) {
  name <- deparse(substitute(fun))

  rig <- get("rig", asNamespace("boomer"), mode = "function")

  assign(name, rig(fun, ignore = c("~", "{", "(")), getNamespace("dm"))
}

check_version_on_load <- function(package, version, reason) {
  check_version <- function(...) {
    if (utils::packageVersion(package) < version) {
      message <- c(
        paste0("You need {.pkg {package} >= {version}} ", reason),
        `i` = 'Install with {.pkg `install.packages("{package}")`}'
      )

      cli::cli_inform(message)
    }
  }

  # Always register hook in case package is later unloaded & reloaded
  setHook(packageEvent(package, "onLoad"), check_version)

  # Avoid registration failures during loading (pkgload or regular)
  if (isNamespaceLoaded(package)) {
    check_version()
  }

  invisible()
}
