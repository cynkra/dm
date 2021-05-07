.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, c("...length"))

  if (getRversion() >= "3.4") {
    dm_financial <<- memoise::memoise(dm_financial, cache = cache_attach())
    dm_financial_sqlite <<- memoise::memoise(dm_financial_sqlite, cache = cache_attach())
  }

  flights_subset <<- memoise::memoise(flights_subset, cache = cache_attach())
  weather_subset <<- memoise::memoise(weather_subset, cache = cache_attach())

  dm_has_financial <<- memoise::memoise(dm_has_financial, cache = cache_attach())

  register_pkgdown_methods()

  # rigg(enum_pk_candidates_impl)
  # rigg(build_copy_data)
  # rigg(dm_insert_zoomed_outgoing_fks)
  # rigg(dm_upgrade)
  # rigg(validate_dm)
  # rigg(check_df_structure)
  # rigg(dm_insert_zoomed)
  # rigg(dm_select_tbl_impl)
}

rigg <- function(fun) {
  name <- deparse(substitute(fun))

  rig <- get("rig", asNamespace("boomer"), mode = "function")

  assign(name, rig(fun, ignore = c("~", "{", "(", "<-", "<<-")), getNamespace("dm"))
}
