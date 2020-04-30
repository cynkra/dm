.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, c("...length"))

  if (getRversion() >= "3.4") {
    dm_financial <<- memoise::memoise(dm_financial, cache = cache_attach())
    dm_financial_sqlite <<- memoise::memoise(dm_financial_sqlite, cache = cache_attach())
  }

  flights_subset <<- memoise::memoise(flights_subset, cache = cache_attach())
  weather_subset <<- memoise::memoise(weather_subset, cache = cache_attach())

  register_pkgdown_methods()

  replace_if_dplyr_has(rows_insert)
  replace_if_dplyr_has(rows_update)
  replace_if_dplyr_has(rows_patch)
  replace_if_dplyr_has(rows_upsert)
  replace_if_dplyr_has(rows_delete)
  register_if_dplyr_hasnt(rows_insert.data.frame)
  register_if_dplyr_hasnt(rows_update.data.frame)
  register_if_dplyr_hasnt(rows_patch.data.frame)
  register_if_dplyr_hasnt(rows_upsert.data.frame)
  register_if_dplyr_hasnt(rows_delete.data.frame)
}
