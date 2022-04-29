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

  check_version_on_load("RSQLite", "2.2.8", "to use the {.code returning} argument in {.code dm::rows_*()}")

  replace_if_dbplyr_has(get_returned_rows)
  replace_if_dbplyr_has(has_returned_rows)

  register_if_dbplyr_hasnt(rows_insert.tbl_lazy)
  register_if_dbplyr_hasnt(rows_append.tbl_lazy)
  register_if_dbplyr_hasnt(rows_update.tbl_lazy)
  register_if_dbplyr_hasnt(rows_patch.tbl_lazy)
  register_if_dbplyr_hasnt(rows_upsert.tbl_lazy)
  register_if_dbplyr_hasnt(rows_delete.tbl_lazy)

  # rigg(enum_pk_candidates_impl)
  # rigg(build_copy_data)
  # rigg(dm_insert_zoomed_outgoing_fks)
  # rigg(dm_upgrade)
  # rigg(validate_dm)
  # rigg(check_df_structure)
  # rigg(dm_insert_zoomed)
  # rigg(dm_select_tbl_impl)
  # rigg(dm_insert_zoomed_outgoing_fks)
  # rigg(dm_rm_pk_impl)
  # rigg(dm_rm_fk_impl)
  # rigg(cdm_rm_fk)
}

rigg <- function(fun) {
  name <- deparse(substitute(fun))

  rig <- get("rig", asNamespace("boomer"), mode = "function")

  assign(name, rig(fun, ignore = c("~", "{", "(", "<-", "<<-")), getNamespace("dm"))
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
