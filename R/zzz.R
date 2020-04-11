.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, c("...length"))

  dm_financial <<- memoise::memoise(dm_financial)
  dm_financial_sqlite <<- memoise::memoise(dm_financial_sqlite)
}
