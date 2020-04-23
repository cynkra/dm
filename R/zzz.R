.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, c("...length"))

  if (getRversion() >= "3.4") {
    dm_financial <<- memoise::memoise(dm_financial, cache = cache_attach())
    dm_financial_sqlite <<- memoise::memoise(dm_financial_sqlite, cache = cache_attach())
  }

  flights_subset <<- memoise::memoise(flights_subset, cache = cache_attach())
  weather_subset <<- memoise::memoise(weather_subset, cache = cache_attach())

  if (Sys.getenv("IN_PKGDOWN") != "") {
    stopifnot(rlang::is_installed(c("DiagrammeR", "DiagrammeRsvg")))
    vctrs::s3_register("pkgdown::replay_html", "dm_draw")
    vctrs::s3_register("base::print", "grViz")
  }
}
